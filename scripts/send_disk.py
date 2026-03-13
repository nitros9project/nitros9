#!/usr/bin/env python3
"""
send_disk.py - Send a disk image to the Pico-Thing via serial.

Streams the image to the diskload.c program running on the 6809, which
writes it to the PATA drive sector by sector.

The disk image is read in 512-byte chunks and sent as framed packets:
    SOH  LBA[23:16]  LBA[15:8]  LBA[7:0]  [512 bytes]  XOR-checksum

The 6809 responds ACK (0x06) per sector, or NAK (0x15) to request a retry.

Usage:
    python3 scripts/send_disk.py <port> <disk_image> [options]

Examples:
    python3 scripts/send_disk.py /dev/tty.usbmodem1234 NOS9_6809_L2_v.._picothing.dsk
    python3 scripts/send_disk.py /dev/tty.usbmodem1234 myimage.dsk --start-lba 2
    python3 scripts/send_disk.py /dev/tty.usbmodem1234 myimage.dsk --baud 115200

Notes:
    - The Pico's virtual ACIA may not enforce baud rate; actual transfer
      speed depends on how fast the 6809 can poll the ACIA receive register.
    - The disk image is padded to a 512-byte boundary if necessary.
    - Run a short benchmark first (--sectors 100) to gauge throughput.
Notes on the ring-buffer / chunk-delay issue:
    The 6809 UART ring buffer (io.asm) is only 15 bytes.  If the Pico's
    USB-CDC virtual ACIA delivers bytes faster than the 6809 can drain
    the ring buffer, bytes are silently dropped and the checksum fails.
    Use --chunk-delay to pace the payload into small bursts that the 6809
    can keep up with.  Start with --chunk-delay 2 (2 ms per 8-byte chunk).
    If the Pico firmware properly honours the 6809's RTS signal, no delay
    is needed and the default (0) works fine.
"""

import argparse
import sys
import time

try:
    import serial
except ImportError:
    print("Install pyserial:  pip3 install pyserial", file=sys.stderr)
    sys.exit(1)

SOH         = 0x01
EOT         = 0x04
ACK         = bytes([0x06])
NAK         = bytes([0x15])
SECTOR_SIZE = 512
MAX_RETRIES = 5

# Set to True to enable PackBits RLE compression of sector payloads.
# Both ends must agree: the 6809 diskload.c must be built with -DUSE_PACKBITS.
USE_PACKBITS = True


def xor_checksum(data):
    chk = 0
    for b in data:
        chk ^= b
    return chk


def packbits_encode(data):
    """PackBits RLE encoder.  Returns a bytes object.

    Control byte semantics (matching the decoder in diskload.c):
      0..127   -> next (n+1) bytes are literals   (1-128 bytes)
      129..255 -> repeat next byte (257-n) times   (2-128 copies)
      128      -> end-of-block marker

    The end marker (0x80) is appended automatically.
    """
    out = bytearray()
    i = 0
    n = len(data)
    while i < n:
        # Look for a run of identical bytes (min 3 to be worth encoding)
        if i + 2 < n and data[i] == data[i + 1] == data[i + 2]:
            val = data[i]
            run = 3
            while i + run < n and data[i + run] == val and run < 128:
                run += 1
            out.append((257 - run) & 0xFF)  # 129..255
            out.append(val)
            i += run
        else:
            # Literal run: collect up to 128 non-run bytes
            lit_start = i
            lit_end = i + 1
            while lit_end < n and (lit_end - lit_start) < 128:
                # Stop if the next 3 bytes form a run
                if (lit_end + 2 < n
                        and data[lit_end] == data[lit_end + 1] == data[lit_end + 2]):
                    break
                lit_end += 1
            count = lit_end - lit_start
            out.append(count - 1)            # 0..127
            out.extend(data[lit_start:lit_end])
            i = lit_end
    out.append(0x80)  # end-of-block marker
    return bytes(out)


CHUNK_SIZE = 1   # bytes per timed burst when --chunk-delay is used


def send_disk(port, baud, image_path, start_lba=0, max_sectors=None,
              chunk_delay=0.0):
    with open(image_path, 'rb') as fh:
        image = fh.read()

    # Pad to 512-byte boundary
    if len(image) % SECTOR_SIZE:
        image += bytes(SECTOR_SIZE - len(image) % SECTOR_SIZE)

    total = len(image) // SECTOR_SIZE
    if max_sectors is not None:
        total = min(total, max_sectors)

    print(f"Image:      {image_path}")
    print(f"Size:       {len(image)} bytes  ({total} sectors of {SECTOR_SIZE} bytes)")
    print(f"Port:       {port}  baud={baud}")
    print(f"Start LBA:  {start_lba}")
    if chunk_delay:
        print(f"Chunk mode: {CHUNK_SIZE} bytes every {chunk_delay*1000:.0f} ms"
              f"  (~{CHUNK_SIZE/chunk_delay/1024:.1f} KB/s)")
    print()

    ser = serial.Serial(port, baud, timeout=10)
    try:
        # Flush any stale data
        ser.reset_input_buffer()

        # Wait for the ready signal ('R') from diskload
        print("Waiting for 'R' ready signal from 6809...", end='', flush=True)
        deadline = time.time() + 30
        while time.time() < deadline:
            c = ser.read(1)
            if not c:
                continue
            if c == b'R':
                break
            # Echo any human-readable output from the target
            try:
                sys.stdout.write(c.decode('ascii', errors='replace'))
                sys.stdout.flush()
            except Exception:
                pass
        else:
            print("\nTimeout waiting for ready signal.")
            return False
        print(" OK")

        BAR_WIDTH  = 30
        failed     = 0
        t_start    = time.time()
        # Rolling rate: average over the last RATE_WINDOW sectors
        RATE_WINDOW = 10
        sector_times = []   # (completion_time, cumulative_bytes) ring

        def render_progress(n, lba, retries):
            done       = n + 1
            pct        = done / total
            filled     = int(BAR_WIDTH * pct)
            bar        = '=' * filled + ('>' if filled < BAR_WIDTH else '') \
                         + ' ' * (BAR_WIDTH - filled - (1 if filled < BAR_WIDTH else 0))
            now        = time.time()
            elapsed    = now - t_start
            done_bytes = done * SECTOR_SIZE

            # Rate: slope over the recent window, fall back to overall average
            if len(sector_times) >= 2:
                dt = sector_times[-1][0] - sector_times[0][0]
                db = sector_times[-1][1] - sector_times[0][1]
                rate = db / dt if dt > 0 else 0
            else:
                rate = done_bytes / elapsed if elapsed > 0 else 0

            avg_rate = done_bytes / elapsed if elapsed > 0 else 0
            remaining = (total - done) * SECTOR_SIZE
            eta  = remaining / avg_rate if avg_rate > 0 else 0

            retry_str = f"  retries={retries}" if retries else ''
            sys.stdout.write(
                f"\r  [{bar}] {pct:4.0%}"
                f"  LBA {lba:6d}/{start_lba + total - 1}"
                f"  {rate / 1024:5.1f} KB/s"
                f"  ETA {int(eta):4d}s"
                f"{retry_str}   "
            )
            sys.stdout.flush()

        for n in range(total):
            lba  = start_lba + n
            data = image[n * SECTOR_SIZE:(n + 1) * SECTOR_SIZE]
            chk  = xor_checksum(data)

            header = bytes([
                SOH,
                (lba >> 16) & 0xFF,
                (lba >> 8)  & 0xFF,
                lba         & 0xFF,
            ])
            payload = packbits_encode(data) if USE_PACKBITS else data
            frame = header + payload + bytes([chk])

            success = False
            for attempt in range(MAX_RETRIES):
                if chunk_delay:
                    for i in range(0, len(frame), CHUNK_SIZE):
                        ser.write(frame[i:i + CHUNK_SIZE])
                        time.sleep(chunk_delay)
                else:
                    ser.write(frame)
                resp = ser.read(1)
                if resp == ACK:
                    success = True
                    break
                failed += 1
                if attempt < MAX_RETRIES - 1:
                    sys.stdout.write(
                        f"\r  NAK at LBA {lba} attempt {attempt + 1}/{MAX_RETRIES}"
                        f" — retrying...   \n"
                    )
                    sys.stdout.flush()

            if not success:
                sys.stdout.write(f"\n\nFailed after {MAX_RETRIES} retries at LBA {lba}.\n")
                return False

            now = time.time()
            sector_times.append((now, (n + 1) * SECTOR_SIZE))
            if len(sector_times) > RATE_WINDOW:
                sector_times.pop(0)

            render_progress(n, lba, failed)

        # Send end-of-transfer
        ser.write(bytes([EOT]))
        resp = ser.read(1)
        sys.stdout.write('\n')

        elapsed    = time.time() - t_start
        total_bytes = total * SECTOR_SIZE
        avg_rate   = total_bytes / elapsed if elapsed > 0 else 0
        print(
            f"\nTransfer complete: {total_bytes} bytes in {elapsed:.1f}s"
            f"  ({avg_rate / 1024:.1f} KB/s avg)"
            + (f"  {failed} retries" if failed else '')
        )
        return True

    finally:
        ser.close()


def main():
    ap = argparse.ArgumentParser(
        description='Send a disk image to Pico-Thing via the virtual ACIA serial port'
    )
    ap.add_argument('port',  help='Serial port, e.g. /dev/tty.usbmodem1234')
    ap.add_argument('image', help='Disk image file, e.g. NOS9_6809_L2_v.._picothing.dsk')
    ap.add_argument(
        '--baud', type=int, default=115200,
        help='Baud rate (default 115200; Pico virtual ACIA may ignore this)',
    )
    ap.add_argument(
        '--start-lba', type=int, default=0,
        help='First LBA on the drive to write to (default 0)',
    )
    ap.add_argument(
        '--sectors', type=int, default=None,
        help='Limit transfer to this many sectors (useful for benchmarking)',
    )
    ap.add_argument(
        '--chunk-delay', type=float, default=0.0, metavar='MS',
        help=(
            f'Pace payload in {CHUNK_SIZE}-byte bursts with this delay (ms) between '
            'each burst.  Use when the Pico virtual ACIA floods the 6809 ring '
            'buffer (symptoms: consistent NAK on every sector).  Try 2.'
        ),
    )
    args = ap.parse_args()

    ok = send_disk(args.port, args.baud, args.image, args.start_lba, args.sectors,
                   chunk_delay=args.chunk_delay / 1000.0)
    sys.exit(0 if ok else 1)


if __name__ == '__main__':
    main()
