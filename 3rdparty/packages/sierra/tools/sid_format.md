# `sidDir` / `sidSnd` on-disk format (v1)

Sidecar files emitted by `agi_sid_extract.py` and consumed by the
polyphonic SID playback engine in `objs/mnln.asm` (Phase 2).

All multi-byte integers are **big-endian** unless explicitly noted; the
6809 reads BE words naturally with `LDD` / `LDX`.  The only LE-ish
fields are the SID frequency low/high bytes stored adjacently in the
order the engine will write them to the SID's `FREQ_LO` then `FREQ_HI`
registers — see "amp_wave" below.

## `sidDir` — directory file

Flat array of 4-byte big-endian entries, one per sound slot in
`sndDir`.  Entry count = `filesize / 4` and matches `sndDir`'s slot
count.

```
+0  2 B  offset of the SID stream within sidSnd
+2  2 B  length of the SID stream in bytes
```

An entry of `FF FF FF FF` means "no SID stream for this sound slot" —
either the slot is absent in `sndDir` or the extractor declined to
encode it.  The engine MUST fall back to the existing mono playback
path for such sounds (which itself falls back to the DAC bit-bang path
when no X-SID is present).

The 16-bit length field bounds the per-sound stream size to <64 KiB.
The 16-bit offset field bounds the whole `sidSnd` file to <64 KiB.
SQ0:R's whole sidSnd is ~52 KiB so there's ~12 KiB of headroom; if a
future game overflows this, the format can be re-versioned with
24-bit offsets.

## `sidSnd` — concatenated streams

A bare concatenation of per-sound SID streams in `sndDir` order.  No
separators, no padding.  Per-stream layout:

### Per-sound stream header (8 bytes, big-endian)

```
+0  2 B  v1 offset (bytes from start of THIS stream)
+2  2 B  v2 offset
+4  2 B  v3 offset  (merged: tone + noise share voice 3)
+6  2 B  total ticks (whole sound duration, 0xFFFF = clamped)
```

`total_ticks` is informational — the engine may use it to estimate
elapsed time for the AGI game clock — but the authoritative end-of-
sound condition is "all voices terminated".  Each voice has its own
terminator independent of total_ticks.

### Per-voice note stream (5 bytes per note)

Each voice runs forwards from its header offset until it hits the
terminator note.

```
+0  2 B  duration (BE, in 1/60 sec ticks).  0xFFFF = end-of-voice.
+2  1 B  SID freq low  (target $FF40 / $FF47 / $FF4E)
+3  1 B  SID freq high (target $FF41 / $FF48 / $FF4F)
+4  1 B  amp_wave:
           bits 7..4  sustain nibble (S nibble of $FF46/$FF4D/$FF54)
                      0 = silence, 15 = max
           bits 3..0  waveform enum:
                      0 = rest  (engine writes CR=0, gate off, skips freq)
                      1 = triangle + gate (engine writes CR=0x11)
                      8 = noise + gate    (engine writes CR=0x81)
```

The waveform enum is a tiny abstract value, not a literal SID control
register byte.  The engine maps it to a real CR value (a 4-entry
jump-table or branch in 6809 is enough).  This keeps the per-note
record at 5 bytes and lets future format revisions add waveforms (pulse,
sawtooth) without renumbering existing values.

Noise (waveform=8) is only legal on voice 3; the extractor never emits
it on v1 or v2.  When the source's noise channel and voice 3 tone are
simultaneously audible, the extractor preserves voice 3 tone and drops
the noise for that tick range — keeping melody intact at the cost of
some percussion in musical passages.  The extractor reports the count
of dropped noise ticks for auditing.

### Worked example: sound 1 (78 bytes, 0.30 s)

A short SFX with all 4 voices participating.

```
HEADER:
00 08    v1 offset = 8
00 12    v2 offset = 18
00 17    v3 offset = 23
00 12    total ticks = 18 (0.30 s at 60 Hz)

V1 (10 bytes, 2 notes + terminator):
  00 03 26 0E F1    dur=3   freq=0x0E26  sustain=15  triangle
  00 03 16 0D F1    dur=3   freq=0x0D16  sustain=15  triangle
  FF FF 00 00 00    terminator

V2 (5 bytes):
  FF FF 00 00 00    terminator (voice empty)

V3 (~55 bytes, merged tone + noise stream):
  00 03 7F 19 F8    dur=3   noise white  sustain=15
  00 06 00 00 00    dur=6   rest
  00 03 7F 19 F8    dur=3   noise
  ... etc
  FF FF 00 00 00    terminator
```

(Real binary will differ slightly — the example is illustrative.)

## Engine reading hints (Phase 2 design)

```asm
* Load sidDir entry for sound number in B:
        ldx     SidDirBase,pcr  ; X = base of loaded sidDir
        ldd     ,x              ; D = 0xFFFF if absent
        lslb                    ; *4 (B was sound number)
        rola
        rolb                    ; etc — actually use 'lda b,x' style
        ; ...
        ldd     b,x             ; D = offset into sidSnd
        ldy     2,x             ; or load length into Y for bounds check
        ; ...

* Per voice, advance pointer through note records:
* U = current voice pointer (5-byte aligned to a note record)
        ldd     ,u              ; D = duration (BE)
        cmpd    #$FFFF
        beq     VoiceDone
        ; load freq and write
        ldb     2,u             ; freq low
        stb     $FF40           ; SID v1 freq lo
        ldb     3,u             ; freq high
        stb     $FF41           ; SID v1 freq hi
        ldb     4,u             ; amp_wave
        ; decode high nibble -> sustain register
        ; decode low nibble  -> control register (or no-write if rest)
        leau    5,u             ; advance to next record
        std     <countdown      ; load this note's countdown
```

See `engine_design.md` for the full integration design (memory layout,
timing source, IRQ rules, fallback behaviour).
