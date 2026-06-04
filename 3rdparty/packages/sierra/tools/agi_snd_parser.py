#!/usr/bin/env python3
"""
AGI v2/v3 sound resource parser.

Reads a Sierra AGI game's SNDDIR + VOL.* files and yields each sound
resource as 4 voice streams of (duration_ticks, divisor, attenuation,
noise_fb, noise_nf) tuples.

Handles both:
  - AGI v2 resources: 5-byte header (sig, vol, length), raw body.
  - AGI v3 resources: 7-byte header (sig, vol|flags, len_unc, len_cmp),
    body optionally LZW-compressed (when len_cmp < len_unc).

Auto-detects the format per resource by trying v2 first, then v3 raw,
then v3 LZW, validating each candidate against a structural model of
the sound body (4 voice offsets within range + each voice stream
terminating with 0xFFFF on a 5-byte boundary).

Spec references:
  http://wiki.scummvm.org/index.php/AGI/Specifications/Sound
  http://wiki.scummvm.org/index.php/AGI/Specifications/Formats
  ScummVM engines/agi/{loader_v2,loader_v3,sound_pcjr,lzw}.cpp
"""

import os
import struct
import sys
from dataclasses import dataclass
from typing import Optional


PSG_CLOCK_HZ = 111860  # 3.579545 MHz / 32 (PCjr SN76489)


@dataclass
class Note:
    duration_ticks: int           # 1/60 s ticks
    divisor: Optional[int]        # 10-bit PSG divisor (None for noise)
    freq_hz: Optional[float]      # None for noise, 0.0 for "divisor==0" silence
    attenuation: int              # 0=loud, 15=silent
    fb: Optional[int]             # noise only: 0=periodic 1=white
    nf: Optional[int]             # noise only: 0..3, 3=borrow v3 freq

    @property
    def silent(self) -> bool:
        if self.attenuation >= 0xF:
            return True
        if self.divisor == 0:
            return True
        return False


@dataclass
class Sound:
    index: int                    # SNDDIR entry index
    vol: int                      # VOL file number
    offset: int                   # offset into VOL file
    voices: list                  # 4 lists of Note: v1 tone, v2 tone, v3 tone, noise

    @property
    def total_ticks(self) -> int:
        return max((sum(n.duration_ticks for n in v) for v in self.voices), default=0)


def parse_dir(dir_path: str):
    """Parse a 3-byte-per-entry AGI v2 directory file.

    Returns list of (vol, offset) or None for absent entries.
    """
    with open(dir_path, 'rb') as f:
        raw = f.read()
    n = len(raw) // 3
    out = []
    for i in range(n):
        b0, b1, b2 = raw[i*3], raw[i*3+1], raw[i*3+2]
        if b0 == 0xFF and b1 == 0xFF and b2 == 0xFF:
            out.append(None)
        else:
            vol = b0 >> 4
            off = ((b0 & 0x0F) << 16) | (b1 << 8) | b2
            out.append((vol, off))
    return out


def read_vol_resource(vol_path: str, offset: int) -> bytes:
    """Read one AGI sound resource body (uncompressed) from a VOL file.

    Tries the on-disk header as AGI v2 (5 bytes), AGI v3 raw (7 bytes,
    len_cmp == len_unc), and AGI v3 LZW-compressed (7 bytes, body
    decompressed to len_unc bytes), in that order, returning the first
    candidate whose body validates as a well-formed sound resource.
    """
    with open(vol_path, 'rb') as f:
        f.seek(offset)
        hdr = f.read(7)
        if len(hdr) < 7:
            raise ValueError(f"short header read at {vol_path}+{offset}")
        sig = (hdr[0] << 8) | hdr[1]
        if sig != 0x1234:
            raise ValueError(
                f"bad signature {sig:#06x} at {vol_path}+{offset} "
                "(not AGI v2/v3 / not at start of resource)"
            )

        len_unc = hdr[3] | (hdr[4] << 8)
        len_cmp = hdr[5] | (hdr[6] << 8)

        # --- candidate 1: AGI v2 (5-byte header, raw body of size len_unc) ---
        f.seek(offset + 5)
        body_v2 = f.read(len_unc)
        if _is_valid_sound_body(body_v2):
            return body_v2

        # --- candidate 2: AGI v3 raw (7-byte header, body of size len_cmp) ---
        if len_cmp == len_unc:
            f.seek(offset + 7)
            body_v3raw = f.read(len_cmp)
            if _is_valid_sound_body(body_v3raw):
                return body_v3raw

        # --- candidate 3: AGI v3 LZW-compressed ---
        if 0 < len_cmp <= len_unc * 4:
            f.seek(offset + 7)
            compressed = f.read(len_cmp)
            if len(compressed) == len_cmp:
                try:
                    body_v3lzw = lzw_expand(compressed, len_unc)
                except (ValueError, IndexError):
                    body_v3lzw = None
                if body_v3lzw and _is_valid_sound_body(body_v3lzw):
                    return body_v3lzw

        raise ValueError(
            f"no candidate parse valid at {vol_path}+{offset} "
            f"(len_unc={len_unc} len_cmp={len_cmp})"
        )


def _is_valid_sound_body(body: bytes) -> bool:
    """Structural validator: 8-byte voice offset table + 4 voice streams,
    each terminated by 0xFFFF on a 5-byte boundary before end of body.
    """
    if len(body) < 8:
        return False
    v_offsets = struct.unpack_from('<HHHH', body, 0)
    # All voice offsets must be past the offset table and within body
    for off in v_offsets:
        if off < 8 or off >= len(body):
            return False
    # Each voice stream must reach a 0xFFFF terminator on a 5-byte
    # boundary without falling off the end
    for off in v_offsets:
        pos = off
        terminated = False
        while pos + 1 < len(body):
            duration = body[pos] | (body[pos+1] << 8)
            if duration == 0xFFFF:
                terminated = True
                break
            if pos + 5 > len(body):
                break
            pos += 5
        if not terminated:
            return False
    return True


def lzw_expand(compressed: bytes, expected_length: int) -> bytes:
    """Sierra AGI v3 LZW decompressor.

    Ported line-for-line from ScummVM engines/agi/lzw.cpp (Lance Ewing, 1997).
    Variable-width codes (9..12 bits), code 0x100 = reset, 0x101 = end.
    """
    START_BITS = 9
    MAXBITS = 12
    TABLE_SIZE = 18041
    RESET_CODE = 0x100
    END_CODE = 0x101

    in_bytes = compressed
    in_len = len(in_bytes)
    in_pos = [0]

    prefix_code = [0] * TABLE_SIZE
    append_char = bytearray(TABLE_SIZE)
    decode_stack = bytearray(8192)

    state = {
        'bits': START_BITS,
        'max_value': (1 << START_BITS) - 1,
        'max_code': (1 << START_BITS) - 2,
        'buf': 0,
        'count': 0,
    }

    def set_bits(value):
        if value == MAXBITS:
            return True
        state['bits'] = value
        state['max_value'] = (1 << value) - 1
        state['max_code'] = state['max_value'] - 1
        return False

    def input_code():
        while state['count'] <= 24:
            if in_pos[0] < in_len:
                b = in_bytes[in_pos[0]]
                in_pos[0] += 1
            else:
                b = 0
            state['buf'] |= b << state['count']
            state['count'] += 8
        r = (state['buf'] & 0x7FFF) % (1 << state['bits'])
        state['buf'] >>= state['bits']
        state['count'] -= state['bits']
        return r

    def decode_string(buf_start, code):
        i = 0
        pos = buf_start
        while code > 255:
            if pos >= len(decode_stack):
                raise ValueError("lzw: decode stack overflow")
            decode_stack[pos] = append_char[code]
            pos += 1
            code = prefix_code[code]
            i += 1
            if i >= 4000:
                raise ValueError("lzw: error in code expansion")
        decode_stack[pos] = code
        return pos

    out = bytearray()

    set_bits(START_BITS)
    lzwnext = 257

    lzwold = input_code()
    c = lzwold
    lzwnew = input_code()

    while len(out) < expected_length and lzwnew != END_CODE:
        if lzwnew == RESET_CODE:
            lzwnext = 258
            set_bits(START_BITS)
            lzwold = input_code()
            c = lzwold
            out.append(c & 0xFF)
            lzwnew = input_code()
        else:
            if lzwnew >= lzwnext:
                decode_stack[0] = c & 0xFF
                s = decode_string(1, lzwold)
            else:
                s = decode_string(0, lzwnew)
            c = decode_stack[s]
            # Output reversed
            for i in range(s, -1, -1):
                if len(out) >= expected_length:
                    break
                out.append(decode_stack[i])
            if lzwnext > state['max_code']:
                set_bits(state['bits'] + 1)
            if lzwnext < TABLE_SIZE:
                prefix_code[lzwnext] = lzwold
                append_char[lzwnext] = c
                lzwnext += 1
            lzwold = lzwnew
            lzwnew = input_code()

    return bytes(out)


def parse_sound_body(body: bytes):
    """Parse the body of an AGI v2 sound resource into 4 voice streams.

    Body layout: 8-byte header of 4 LE u16 voice offsets, then 5-byte note
    entries per voice, terminated by 0xFFFF duration.
    """
    if len(body) < 8:
        raise ValueError(f"sound body too short: {len(body)}")
    v_offsets = struct.unpack_from('<HHHH', body, 0)

    voices = []
    for ch in range(4):
        start = v_offsets[ch]
        notes = []
        if start >= len(body):
            voices.append(notes)
            continue
        pos = start
        while pos + 1 < len(body):
            duration = body[pos] | (body[pos+1] << 8)
            if duration == 0xFFFF:
                break
            if pos + 5 > len(body):
                break
            b2 = body[pos+2]
            b3 = body[pos+3]
            b4 = body[pos+4]
            attenuation = b4 & 0x0F
            if ch == 3:
                divisor = None
                freq = None
                fb = (b3 >> 2) & 0x01
                nf = b3 & 0x03
            else:
                divisor = ((b2 & 0x3F) << 4) | (b3 & 0x0F)
                freq = (PSG_CLOCK_HZ / divisor) if divisor else 0.0
                fb = None
                nf = None
            if duration != 0:
                notes.append(Note(
                    duration_ticks=duration,
                    divisor=divisor,
                    freq_hz=freq,
                    attenuation=attenuation,
                    fb=fb,
                    nf=nf,
                ))
            pos += 5
        voices.append(notes)
    return voices


def load_all_sounds(game_dir: str, verbose: bool = False):
    """Iterate SNDDIR and return parsed Sound objects.

    Absent / unreadable entries are silently skipped (or warned about
    when verbose).  This is robust against repackaged installs (e.g.
    GOG SQ1) whose SNDDIR contains entries pointing at volumes that
    were never shipped with the AGI subset.
    """
    snddir = os.path.join(game_dir, 'SNDDIR')
    entries = parse_dir(snddir)
    sounds = []
    skipped = 0
    for idx, entry in enumerate(entries):
        if entry is None:
            continue
        vol, off = entry
        vol_path = os.path.join(game_dir, f'VOL.{vol}')
        if not os.path.exists(vol_path):
            vol_path = os.path.join(game_dir, f'vol.{vol}')
        if not os.path.exists(vol_path):
            if verbose:
                sys.stderr.write(
                    f"# skipping sound {idx}: VOL.{vol} not present\n"
                )
            skipped += 1
            continue
        try:
            body = read_vol_resource(vol_path, off)
            voices = parse_sound_body(body)
        except (ValueError, OSError) as e:
            if verbose:
                sys.stderr.write(
                    f"# skipping sound {idx} at VOL.{vol}+{off:#x}: {e}\n"
                )
            skipped += 1
            continue
        sounds.append(Sound(index=idx, vol=vol, offset=off, voices=voices))
    if skipped and verbose:
        sys.stderr.write(f"# {skipped} sound entries skipped (missing/invalid)\n")
    return sounds


def validate_dir(game_dir: str, max_attempts: int = 16):
    """Probe a PCASSETS directory to confirm it contains real AGI sound data
    (rather than the CoCo-port cc3-converted bundles or other garbage).

    Walks SNDDIR, attempting to parse up to ``max_attempts`` present entries
    via the same code path the extractor uses.  Returns
    ``(parsed_count, attempted_count)``.

    Caller interprets:
       ``attempted_count == 0``                 -> not enough data to decide
       ``attempted_count > 0 and parsed == 0``  -> wrong format (e.g. cc3)
       ``parsed > 0``                           -> looks like real AGI

    Cheap (parses headers + does structural check, no waveform decode).
    """
    snddir = os.path.join(game_dir, "SNDDIR")
    if not os.path.exists(snddir):
        return 0, 0
    try:
        entries = parse_dir(snddir)
    except Exception:
        return 0, 0
    parsed = 0
    attempted = 0
    for idx, entry in enumerate(entries):
        if entry is None:
            continue
        vol, off = entry
        vp = os.path.join(game_dir, f"VOL.{vol}")
        if not os.path.exists(vp):
            vp = os.path.join(game_dir, f"vol.{vol}")
        if not os.path.exists(vp):
            continue
        attempted += 1
        try:
            body = read_vol_resource(vp, off)
        except Exception:
            if attempted >= max_attempts:
                break
            continue
        if _is_valid_sound_body(body):
            parsed += 1
        if attempted >= max_attempts:
            break
    return parsed, attempted


def summarize(snd: Sound) -> str:
    lines = []
    lines.append(
        f"sound.{snd.index:03d}  vol={snd.vol} off={snd.offset:#x}  "
        f"total={snd.total_ticks} ticks ({snd.total_ticks/60.0:.2f}s)"
    )
    for ch, voice in enumerate(snd.voices):
        if not voice:
            lines.append(f"  v{ch}: empty")
            continue
        ticks = sum(n.duration_ticks for n in voice)
        non_silent = sum(1 for n in voice if not n.silent)
        kind = 'noise' if ch == 3 else 'tone'
        lines.append(
            f"  v{ch} ({kind}): {len(voice)} notes ({non_silent} audible), "
            f"{ticks} ticks ({ticks/60.0:.2f}s)"
        )
        for n in voice[:3]:
            if ch == 3:
                lines.append(
                    f"      noise dur={n.duration_ticks} fb={n.fb} "
                    f"nf={n.nf} atten={n.attenuation}"
                )
            else:
                f = n.freq_hz if n.freq_hz is not None else 0.0
                lines.append(
                    f"      tone dur={n.duration_ticks} div={n.divisor} "
                    f"freq={f:.1f}Hz atten={n.attenuation}"
                )
    return '\n'.join(lines)


def main():
    import argparse
    p = argparse.ArgumentParser(description="Parse AGI v2 sound resources")
    p.add_argument('game_dir', help='Path to PC AGI game install dir')
    p.add_argument('--sound', type=int, default=None,
                   help='Only show this sound index (default: summarize all)')
    p.add_argument('--full', action='store_true',
                   help='Dump every note (not just first 3 per voice)')
    args = p.parse_args()

    sounds = load_all_sounds(args.game_dir)
    print(f"# {len(sounds)} sound resources in {args.game_dir}")
    for s in sounds:
        if args.sound is not None and s.index != args.sound:
            continue
        print(summarize(s))
        if args.full:
            for ch, voice in enumerate(s.voices):
                for i, n in enumerate(voice):
                    if ch == 3:
                        print(
                            f"  v{ch}[{i}] noise dur={n.duration_ticks} "
                            f"fb={n.fb} nf={n.nf} atten={n.attenuation}"
                        )
                    else:
                        f = n.freq_hz if n.freq_hz is not None else 0.0
                        print(
                            f"  v{ch}[{i}] tone dur={n.duration_ticks} "
                            f"div={n.divisor} freq={f:.1f}Hz atten={n.attenuation}"
                        )


if __name__ == '__main__':
    main()
