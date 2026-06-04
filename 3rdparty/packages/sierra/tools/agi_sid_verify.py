#!/usr/bin/env python3
"""
agi_sid_verify.py
=================

Round-trip verifier for the sidDir/sidSnd sidecar pair.

Parses sidDir, walks each per-sound stream, decodes its 3 voice
streams, and prints a per-sound summary.  Used to verify the on-disk
layout matches the spec in `sid_format.md` and that the engine can
parse it the same way.

Usage:
    python3 agi_sid_verify.py PATH/TO/sidDir PATH/TO/sidSnd [--sound N]
"""

import argparse
import struct
import sys


def parse_sid_dir(path: str):
    """Return list of (offset, length) for each sound slot.  None = absent."""
    with open(path, 'rb') as f:
        raw = f.read()
    n = len(raw) // 4
    out = []
    for i in range(n):
        e = raw[i*4 : i*4+4]
        if e == b'\xff\xff\xff\xff':
            out.append(None)
        else:
            off, length = struct.unpack('>HH', e)
            out.append((off, length))
    return out


def decode_voice(buf: bytes, start: int, label: str, verbose: bool = False):
    notes = []
    pos = start
    while pos + 4 < len(buf):
        dur = (buf[pos] << 8) | buf[pos+1]
        if dur == 0xFFFF:
            break
        freq_lo = buf[pos+2]
        freq_hi = buf[pos+3]
        amp_wave = buf[pos+4]
        sustain = (amp_wave >> 4) & 0x0F
        waveform = amp_wave & 0x0F
        notes.append((dur, freq_lo, freq_hi, sustain, waveform))
        if verbose and len(notes) <= 3:
            sid_freq = (freq_hi << 8) | freq_lo
            wave_name = {0: 'rest', 1: 'tri', 8: 'noise'}.get(waveform, f'?{waveform}')
            print(f"      {label}[{len(notes)-1}] dur={dur:5d} freq={sid_freq:5d} "
                  f"sustain={sustain:2d} wave={wave_name}")
        pos += 5
    return notes, pos + 2  # past terminator


def verify_stream(buf: bytes, sound_idx: int, off: int, length: int, verbose: bool):
    if off + length > len(buf):
        print(f"  sound {sound_idx}: range error (off+len > sidSnd size)")
        return False
    stream = buf[off:off+length]
    if len(stream) < 8:
        print(f"  sound {sound_idx}: stream too short")
        return False
    v1_off, v2_off, v3_off, total_ticks = struct.unpack('>HHHH', stream[:8])
    if not (8 <= v1_off <= v2_off <= v3_off <= len(stream)):
        print(f"  sound {sound_idx}: bad voice offset order "
              f"v1={v1_off} v2={v2_off} v3={v3_off} len={len(stream)}")
        return False
    if verbose:
        print(f"  sound {sound_idx:3d}: total_ticks={total_ticks} "
              f"({total_ticks/60.0:.2f}s)  v1@{v1_off} v2@{v2_off} v3@{v3_off}")
    v1_notes, _ = decode_voice(stream, v1_off, 'v1', verbose)
    v2_notes, _ = decode_voice(stream, v2_off, 'v2', verbose)
    v3_notes, _ = decode_voice(stream, v3_off, 'v3', verbose)
    # Sanity: per-voice total ticks should be == total_ticks (or 0 for empty)
    for name, notes in [('v1', v1_notes), ('v2', v2_notes), ('v3', v3_notes)]:
        voice_ticks = sum(n[0] for n in notes)
        if voice_ticks not in (0, total_ticks):
            print(f"    WARN {name} ticks={voice_ticks} != total {total_ticks}")
    return True


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('sid_dir', help='Path to sidDir file')
    p.add_argument('sid_snd', help='Path to sidSnd file')
    p.add_argument('--sound', type=int, default=None,
                   help='Only verify this sound index (default: all)')
    p.add_argument('-v', '--verbose', action='store_true')
    args = p.parse_args()

    entries = parse_sid_dir(args.sid_dir)
    with open(args.sid_snd, 'rb') as f:
        snd_blob = f.read()
    print(f"# sidDir: {len(entries)} slots; sidSnd: {len(snd_blob)} bytes")
    present = 0
    failed = 0
    for idx, e in enumerate(entries):
        if e is None:
            continue
        if args.sound is not None and idx != args.sound:
            continue
        off, length = e
        ok = verify_stream(snd_blob, idx, off, length, args.verbose or args.sound is not None)
        present += 1
        if not ok:
            failed += 1
    print(f"# {present} sound streams verified, {failed} failures")
    sys.exit(0 if failed == 0 else 1)


if __name__ == '__main__':
    main()
