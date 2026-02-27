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


def xor_checksum(data):
    chk = 0
    for b in data:
        chk ^= b
    return chk


def send_disk(port, baud, image_path, start_lba=0, max_sectors=None):
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

        failed    = 0
        t_start   = time.time()
        t_last    = t_start
        bytes_last = 0

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
            frame = header + data + bytes([chk])

            success = False
            for attempt in range(MAX_RETRIES):
                ser.write(frame)
                resp = ser.read(1)
                if resp == ACK:
                    success = True
                    break
                failed += 1
                if attempt < MAX_RETRIES - 1:
                    sys.stderr.write(
                        f"\r  NAK at LBA {lba} attempt {attempt + 1}/{MAX_RETRIES}   \n"
                    )

            if not success:
                print(f"\nFailed after {MAX_RETRIES} retries at LBA {lba}.")
                return False

            # Progress line every 50 sectors or on the last one
            if n % 50 == 49 or n == total - 1:
                now      = time.time()
                elapsed  = now - t_start
                interval = now - t_last
                done_bytes = (n + 1) * SECTOR_SIZE
                rate     = (done_bytes - bytes_last) / interval if interval > 0 else 0
                avg_rate = done_bytes / elapsed if elapsed > 0 else 0
                pct      = (n + 1) * 100 // total
                eta      = (total - n - 1) * SECTOR_SIZE / avg_rate if avg_rate > 0 else 0
                print(
                    f"\r  {pct:3d}%  LBA {lba:6d}/{start_lba + total - 1}"
                    f"  {rate / 1024:5.1f} KB/s  ETA {int(eta):4d}s"
                    f"  retries={failed}   ",
                    end='', flush=True,
                )
                t_last     = now
                bytes_last = done_bytes

        # Send end-of-transfer
        ser.write(bytes([EOT]))
        resp = ser.read(1)
        print()

        elapsed = time.time() - t_start
        total_bytes = total * SECTOR_SIZE
        print(
            f"\nTransfer complete: {total_bytes} bytes in {elapsed:.1f}s "
            f"({total_bytes / elapsed / 1024:.1f} KB/s avg)  retries={failed}"
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
    args = ap.parse_args()

    ok = send_disk(args.port, args.baud, args.image, args.start_lba, args.sectors)
    sys.exit(0 if ok else 1)


if __name__ == '__main__':
    main()
