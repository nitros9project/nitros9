#!/usr/bin/env python3
"""
agi_sid_extract.py
==================

Convert PC AGI v2 sound resources into a SID stream sidecar pair for
the NitrOS-9 CoCo3 port:

  sidDir   directory file - 4 bytes per sound, big-endian
  sidSnd   concatenated per-sound SID streams

Input: a PC AGI v2 install (LOGDIR, PICDIR, VIEWDIR, SNDDIR, VOL.0, ...).
Output: sidDir, sidSnd binary files ready to copy onto the OS-9 disks.

ON-DISK FORMAT (subject to change before Phase 2 engine is committed):
---------------------------------------------------------------------

sidDir
  4 bytes per sound index, big-endian:
    offset_hi offset_lo length_hi length_lo
  All-FF entry  ($FF $FF $FF $FF) means "no SID stream for this sound"
  (the engine falls back to the mono DAC path).

  Sound count = filesize / 4.  Matches the count of entries in sndDir.

sidSnd
  Concatenated per-sound streams, no padding.

Per-sound stream
  HEADER (8 bytes, big-endian):
    +0  v1 offset (relative to stream start, BE)
    +2  v2 offset                            (BE)
    +4  v3 offset (merged tone + noise)      (BE)
    +6  total ticks for whole sound          (BE)

  Each voice stream is a run of 5-byte note records:
    +0  duration ticks (BE)   --  0xFFFF terminates the voice
    +2  SID freq_lo   (-> $FF40 / $FF47 / $FF4E)
    +3  SID freq_hi   (-> $FF41 / $FF48 / $FF4F)
    +4  amp_wave byte:
          bits 7..4  sustain nibble (0=silent, 15=loud)
          bits 3..0  waveform enum:
                       0 = rest (engine writes CR=0, gate off, skip freq)
                       1 = triangle + gate (engine writes CR=$11)
                       8 = noise + gate    (engine writes CR=$81)

NOISE MERGE POLICY (extractor-side)
-----------------------------------
Source has 3 tonal voices + 1 noise voice.  SID has 3 voices total, and
voice 3 is shared between tone and noise (one waveform at a time).  We
merge the source's noise stream into voice 3 with this priority:

  - Whenever the source's voice 3 tone is RESTING (atten == 15), noise
    takes voice 3 for that interval.
  - Otherwise the source's voice 3 tone wins (preserves harmony).

This is conservative -- it preserves melody, and accepts losing some
percussion during musical passages.  The extractor reports a per-sound
count of dropped noise ticks so we can audit later.
"""

import argparse
import os
import struct
import sys

# Import the parser (this file lives in the same directory)
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from agi_snd_parser import (
    Note,
    Sound,
    PSG_CLOCK_HZ,
    load_all_sounds,
)


# Default SID clock for MAME's coco_xsid (1 MHz).  Real hardware may
# differ; override with --sid-clock if needed.
DEFAULT_SID_CLOCK_HZ = 1_000_000

# Per-stream cap.  The Phase 2.5 streaming engine in mnln.asm refills
# per-voice ring buffers from sidSnd on demand, so individual stream
# size is no longer a hard ceiling at runtime — but file offset and
# length still need to fit in the 16-bit dir entry, and the 0xFFF0
# sanity cap in SidLookup guards against unsigned-arithmetic overflow.
# We keep a small headroom under 0xFFFF here.
MAX_STREAM_BYTES = 0xFFF0


def psg_freq_to_sid_freq(psg_freq_hz: float, sid_clock_hz: int) -> int:
    """Convert a PSG tone frequency (Hz) to a 16-bit SID freq register value.

    SID freq formula: f_out = sid_clock * freq_reg / 2**24
      so: freq_reg = f_out * 2**24 / sid_clock
    """
    if psg_freq_hz <= 0:
        return 0
    val = round(psg_freq_hz * 16777216 / sid_clock_hz)
    if val < 1:
        val = 1
    if val > 0xFFFF:
        val = 0xFFFF
    return val


def noise_nf_to_sid_freq(nf: int, voice3_freq: int, sid_clock_hz: int) -> int:
    """Map AGI noise NF select (0..3) to SID noise oscillator freq register.

    The PCjr/SN76489 noise oscillator advances on each clock; SID noise
    is similar -- its LFSR is clocked at osc rate.  Map the source's
    noise frequencies to roughly equivalent SID osc frequencies:

        NF 0 -> 1193180/512  Hz ~= 2330 Hz
        NF 1 -> 1193180/1024 Hz ~= 1165 Hz
        NF 2 -> 1193180/2048 Hz ~=  583 Hz
        NF 3 -> borrow voice 3 tone freq

    The audible quality of SID noise depends on osc freq; higher = brighter.
    """
    if nf == 3:
        # Borrow voice 3 tone freq.  Caller passes voice3_freq computed
        # for the same time slice.
        return voice3_freq if voice3_freq else psg_freq_to_sid_freq(2330.0, sid_clock_hz)
    nf_hz = {0: 2330.0, 1: 1165.0, 2: 583.0}[nf]
    return psg_freq_to_sid_freq(nf_hz, sid_clock_hz)


def atten_to_sustain_nibble(atten: int) -> int:
    """Map PSG attenuation (0=loud, 15=silent) to SID sustain (0=silent, 15=loud).

    Both are 4-bit log scales (2 dB per step), so this is just a flip.
    """
    if atten >= 15:
        return 0
    return 0xF - atten


def encode_note(duration: int, sid_freq: int, sustain: int, waveform: int) -> bytes:
    """Pack one 5-byte note record (big-endian duration, lo/hi freq, amp_wave)."""
    if duration > 0xFFFF:
        duration = 0xFFFF  # caller should split if they want exact rendition
    freq_lo = sid_freq & 0xFF
    freq_hi = (sid_freq >> 8) & 0xFF
    amp_wave = ((sustain & 0x0F) << 4) | (waveform & 0x0F)
    return struct.pack('>HBBB', duration, freq_lo, freq_hi, amp_wave)


# Waveform enums in our on-disk format
WAVE_REST = 0
WAVE_TRIANGLE = 1
WAVE_NOISE = 8


def convert_tone_voice(voice_notes, sid_clock_hz: int) -> bytes:
    """Build a SID stream for one tone voice (v1, v2, or v3 tone-only)."""
    out = bytearray()
    for n in voice_notes:
        if n.silent:
            # rest: sustain=0, waveform=rest, freq=0
            out += encode_note(n.duration_ticks, 0, 0, WAVE_REST)
            continue
        sid_freq = psg_freq_to_sid_freq(n.freq_hz or 0.0, sid_clock_hz)
        if sid_freq == 0:
            out += encode_note(n.duration_ticks, 0, 0, WAVE_REST)
            continue
        sustain = atten_to_sustain_nibble(n.attenuation)
        if sustain == 0:
            out += encode_note(n.duration_ticks, 0, 0, WAVE_REST)
            continue
        out += encode_note(n.duration_ticks, sid_freq, sustain, WAVE_TRIANGLE)
    # voice terminator: duration=0xFFFF
    out += struct.pack('>H', 0xFFFF) + b'\x00\x00\x00'
    return bytes(out)


def merge_v3_with_noise(v3_notes, noise_notes, sid_clock_hz: int):
    """Merge source voice 3 + noise into a single SID v3 stream.

    Walk both timelines tick-by-tick (notional), at each note boundary
    decide: if v3 tone is audible -> use tone; else if noise audible
    -> use noise; else rest.

    Returns (stream_bytes, dropped_noise_ticks) for accounting.
    """
    # Build per-tick lookups.  Cheap because most sounds are <100 ticks
    # and the longest is ~7000 ticks.  Total memory is fine for the
    # extractor.
    def expand(notes, is_noise: bool):
        out = []
        for n in notes:
            for _ in range(n.duration_ticks):
                out.append(n)
        return out

    v3_ticks = expand(v3_notes, False)
    nz_ticks = expand(noise_notes, True)
    total = max(len(v3_ticks), len(nz_ticks))
    # Pad shorter to total with implicit rest
    while len(v3_ticks) < total:
        v3_ticks.append(None)
    while len(nz_ticks) < total:
        nz_ticks.append(None)

    # Walk per tick and emit (sustain, waveform, sid_freq) triples
    events = []  # list of (sustain, waveform, sid_freq)
    dropped_noise = 0
    last_v3_sid_freq = 0  # for NF=3 "borrow v3" mapping
    for i in range(total):
        v3 = v3_ticks[i]
        nz = nz_ticks[i]
        v3_audible = (v3 is not None and not v3.silent)
        nz_audible = (nz is not None and not nz.silent)
        if v3_audible:
            # voice 3 tone wins
            sid_freq = psg_freq_to_sid_freq(v3.freq_hz or 0.0, sid_clock_hz)
            sustain = atten_to_sustain_nibble(v3.attenuation)
            last_v3_sid_freq = sid_freq
            if sustain == 0 or sid_freq == 0:
                events.append((0, WAVE_REST, 0))
            else:
                events.append((sustain, WAVE_TRIANGLE, sid_freq))
            if nz_audible:
                dropped_noise += 1
        elif nz_audible:
            sid_freq = noise_nf_to_sid_freq(nz.nf or 0, last_v3_sid_freq, sid_clock_hz)
            sustain = atten_to_sustain_nibble(nz.attenuation)
            if sustain == 0 or sid_freq == 0:
                events.append((0, WAVE_REST, 0))
            else:
                events.append((sustain, WAVE_NOISE, sid_freq))
        else:
            events.append((0, WAVE_REST, 0))

    # Run-length compress events back into notes
    out = bytearray()
    i = 0
    while i < len(events):
        s, w, f = events[i]
        j = i + 1
        while j < len(events) and events[j] == (s, w, f) and (j - i) < 0xFFFE:
            j += 1
        dur = j - i
        out += encode_note(dur, f, s, w)
        i = j
    # terminator
    out += struct.pack('>H', 0xFFFF) + b'\x00\x00\x00'
    return bytes(out), dropped_noise


def encode_sound(snd: Sound, sid_clock_hz: int):
    """Encode one Sound to a SID stream.

    Returns (stream_bytes, info_dict).
    """
    v1 = convert_tone_voice(snd.voices[0], sid_clock_hz)
    v2 = convert_tone_voice(snd.voices[1], sid_clock_hz)
    v3, dropped = merge_v3_with_noise(snd.voices[2], snd.voices[3], sid_clock_hz)

    # Header: 4 BE words: v1_off, v2_off, v3_off, total_ticks
    HEADER_LEN = 8
    v1_off = HEADER_LEN
    v2_off = v1_off + len(v1)
    v3_off = v2_off + len(v2)
    total_ticks = snd.total_ticks
    if total_ticks > 0xFFFF:
        total_ticks = 0xFFFF

    header = struct.pack('>HHHH', v1_off, v2_off, v3_off, total_ticks)
    stream = header + v1 + v2 + v3

    info = {
        'v1_notes': len(snd.voices[0]),
        'v2_notes': len(snd.voices[1]),
        'v3_notes_in': len(snd.voices[2]),
        'noise_notes_in': len(snd.voices[3]),
        'v1_bytes': len(v1),
        'v2_bytes': len(v2),
        'v3_bytes': len(v3),
        'stream_bytes': len(stream),
        'dropped_noise_ticks': dropped,
        'total_ticks': snd.total_ticks,
    }
    return stream, info


def build(game_dir: str, sid_dir_path: str, sid_snd_path: str,
          sid_clock_hz: int, verbose: bool = False):
    sounds = load_all_sounds(game_dir, verbose=verbose)
    # The dir must have one entry per SNDDIR slot (including absent ones).
    # Reparse SNDDIR to know the slot count.
    snddir = os.path.join(game_dir, 'SNDDIR')
    with open(snddir, 'rb') as f:
        snddir_raw = f.read()
    slot_count = len(snddir_raw) // 3
    if verbose:
        print(f"# slots in SNDDIR: {slot_count}, present sounds: {len(sounds)}")

    # Build sidSnd as concatenation; build directory in parallel.
    sound_by_idx = {s.index: s for s in sounds}
    sid_snd = bytearray()
    sid_dir = bytearray()
    totals = {'streams': 0, 'bytes': 0, 'dropped_noise': 0}
    for idx in range(slot_count):
        snd = sound_by_idx.get(idx)
        if snd is None:
            # absent entry
            sid_dir += b'\xff\xff\xff\xff'
            continue
        try:
            stream, info = encode_sound(snd, sid_clock_hz)
        except Exception as e:
            print(f"! sound {idx} encode failed: {e}", file=sys.stderr)
            sid_dir += b'\xff\xff\xff\xff'
            continue
        offset = len(sid_snd)
        length = len(stream)
        if length > MAX_STREAM_BYTES:
            print(
                f"! sound {idx} stream={length} B exceeds extractor cap "
                f"({MAX_STREAM_BYTES} B); marking absent",
                file=sys.stderr,
            )
            sid_dir += b'\xff\xff\xff\xff'
            continue
        if offset > 0xFFFF or length > 0xFFFF:
            print(
                f"! sound {idx} would exceed 16-bit dir entry "
                f"(offset={offset}, length={length}); marking absent",
                file=sys.stderr,
            )
            sid_dir += b'\xff\xff\xff\xff'
            continue
        sid_dir += struct.pack('>HH', offset, length)
        sid_snd += stream
        totals['streams'] += 1
        totals['bytes'] += length
        totals['dropped_noise'] += info['dropped_noise_ticks']
        if verbose:
            print(
                f"  sound {idx:3d}  off=0x{offset:04x}  len={length:5d}  "
                f"v1={info['v1_notes']:4d} v2={info['v2_notes']:4d} "
                f"v3={info['v3_notes_in']:4d}+n{info['noise_notes_in']:4d}  "
                f"dropped_noise={info['dropped_noise_ticks']}"
            )

    if totals['streams'] == 0:
        # Refuse to emit empty/all-FF sidcars: that pattern previously masked
        # the cc3-vs-AGI bootstrap bug (no real streams parsed, but a sidDir
        # of all-FF + empty sidSnd got shipped onto the disk anyway).  Fail
        # the build instead so the user sees the problem.
        print(
            f"!! 0 streams parsed from {game_dir} (SNDDIR has {slot_count} "
            f"slots).  Source is not AGI v2/v3 sound data (likely the CoCo "
            f"port's cc3-converted bundle, or wrong format).",
            file=sys.stderr,
        )
        print(
            "!! Remove $PCASSETS to disable polyphonic SID for this game "
            "(engine will fall back to mono).",
            file=sys.stderr,
        )
        return 2

    # Atomic write: tmp file + rename, so a partial run cannot leave stale
    # sidcars half-written.
    for path, data in ((sid_dir_path, sid_dir), (sid_snd_path, sid_snd)):
        tmp = path + '.tmp'
        with open(tmp, 'wb') as f:
            f.write(data)
        os.replace(tmp, path)

    print(
        f"# wrote {sid_dir_path} ({len(sid_dir)} bytes, {slot_count} dir entries) "
        f"and {sid_snd_path} ({len(sid_snd)} bytes, {totals['streams']} streams)"
    )
    if totals['dropped_noise']:
        print(
            f"# {totals['dropped_noise']} tick(s) of noise were dropped "
            f"because v3 tone was active (preserved melody)."
        )
    return 0


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('game_dir', help='Path to PC AGI v2 install (with SNDDIR + VOL.*)')
    p.add_argument('--sid-dir', default='sidDir',
                   help='Output directory file path (default: sidDir)')
    p.add_argument('--sid-snd', default='sidSnd',
                   help='Output stream file path (default: sidSnd)')
    p.add_argument('--sid-clock', type=int, default=DEFAULT_SID_CLOCK_HZ,
                   help=f'SID master clock in Hz (default: {DEFAULT_SID_CLOCK_HZ})')
    p.add_argument('-v', '--verbose', action='store_true')
    args = p.parse_args()

    rc = build(args.game_dir, args.sid_dir, args.sid_snd,
               args.sid_clock, args.verbose)
    sys.exit(rc or 0)


if __name__ == '__main__':
    main()
