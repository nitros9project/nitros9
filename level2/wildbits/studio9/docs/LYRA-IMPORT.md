# Lyra import

Load Score lists `.lyr` (case-insensitive) alongside `.ume` and `.mid`. s9d calls
s9y with the already-open input path. On success the save name becomes `.ume`;
the Lyra input is never overwritten. s9y is included in the normal module list
and UMusE3 unlinks it on exit.

## Supported

Lyra version 2 (`2Z`); each voice starts at its file-relative header pointer
($10-$1F), as in play.as. Header fields occupy $0000-$0150; voice data may
start at $0151 or later, with no even-address requirement. Each voice
keeps its own notation part and original MIDI channel. Lyra and MIDI use the
same staff selector: the midpoint of each part's complete pitch range chooses
treble (G4+), alto (C4+), tenor (F3+), or bass. MIDI channel 10 uses percussion.
The assignment is fixed before score emission; a low outlier does not move a
whole voice to bass. The existing importer layout provides five staves.
Notes/rests from whole to 64th, dots, triplets, same-pitch ties, accidentals,
header key/time signature, octave/loco markers, instrument program changes,
volume and complete channel MIDI-byte messages/realtime bytes are supported.
The importer merges buffered voice streams and appends events in chronological
order. It validates the entire input before replacing the score. Errors while
allocating the replacement score can still leave a partial import, as with MIDI.

Lyra pitch flags specify the sounding accidental for each note; the header key
does not additionally alter playback pitches. Notation tracks accidentals per
voice and pitch, resets at bar lines, and prints naturals where necessary to
cancel the key signature or a preceding accidental. Preserved MIDI note events
retain the source pitches and gate lengths. Instrument setup is read from the
sixteen header instrument entries. Casio CZ-230, CT-460,
MT-540 and Kawai MS-710 patches use the translation tables from `play.as`;
unrecognized synths retain valid MIDI program numbers. Fixed percussion table
entries use GM channel 10. In-stream `$9n` markers select header instrument n
for the current voice; the following byte is a display position. These become
ordinary UME channel/instrument events referencing editable INSTRS slots 0-15.
Inline MIDI program changes allocate slots 16-63.
Since 2026-09-27 the header entry's NAME takes part (BluBayou.LYR): an entry named
after a CZ-230S rhythm-machine pattern (ROCK 2, DISCO, SWING ...) is a drum part and
becomes percussion whatever its number selects; a number past the synth's table, or a
table row with no mapping, is resolved from the name (SAKUHAC to Shakuhachi, LOSTRIG to
Contrabass ...); a name nobody knows keeps the old rule. In the CZ-230S table the
Symphonic and String Ensemble rows are String Ensemble 1 (String Ensemble 2 is GM's
slow-attack strings and swelled every pad chord in) and the Pipe Organ rows are Church
Organ. The `play` command carries the same tables and the same faults (proposal). Playback looks up these slots,
so subsequent INSTRS edits change the sound. Display flags do not suppress voices.

## Limits

- Only `2Z` files, not other Lyra versions or disk-container files.
- Footer macros are ignored, empty or not, and SysEx/system-common byte sequences
  are dropped (as the MIDI-file importer drops a SysEx); the rest of the score
  imports. Before 2026-09-27 a nonempty macro or a SysEx rejected the whole file. An orphan tie starts a
  note; a changed-pitch tie starts a new attack, matching `Play`.
- Titles and footer annotations are not imported.
- Tempo follows the Lyra 2.85 binary's slow-NTSC timing loop: each 1/48-quarter
  unit costs `marker * (8 * master + 12) + 296` CPU cycles at 894886 Hz.
  Default master 32 / marker 40 becomes 102 quarter notes per minute. Meter
  converts this to UME's denominator beats (dotted beats for 6/8 and 9/8).
  BPM is rounded once; original MIDI-I/O overhead and native timer quantization
  mean this is a timing model, not a claim of cycle-exact hardware playback.
- Per-voice fractional gates shorten MIDI sound without moving note starts or
  changing notation durations. The original rounding is preserved:
  `duration - floor(duration/8) * (8 - fraction)`. Zero/blank means full length.
  An immediately tied same-pitch note sustains across the boundary.
- Imported tempo records carry a 16-bit BPM value (low byte at offset 3, high
  byte at offset 4, `LY` tag at offsets 6-7). Updated s9p recognizes this tag;
  legacy byte-tempo records keep their original meaning. Older UME players do
  not understand the extension. Playback still has the player's timer resolution.
- 30,000 parsed/emitted events and 65,534 ticks maximum.
- At most 48 additional distinct inline MIDI programs beyond the 16 header
  instrument definitions, matching UME's 64 editable instrument slots.

## C ABI / stack audit

Entry receives `(command, path)` at S+2 and S+4. `pshs y,u` saves four bytes;
a private `iframe` is reserved. The path low byte is `iframe+9`. Every normal
return releases exactly `iframe` then restores Y/U/PC. Failure resets S to the
saved frame root before reporting, then uses the same epilogue. I$Read saves
Y/U, checks the actual byte count before restoring both. I$Seek saves X/Y/U and
restores them even on failure. The eight-byte notation save in ly_sound has four
word pushes and four word pops. No shared direct-page scratch is allocated.

s9d's import dispatcher saves a two-byte importer ID, pushes three C arguments,
then removes eight bytes after the loader returns. It closes the input path and
retains the import result. Existing browser tests assert the entry stack pointer
on return for both MIDI and Lyra dispatch.

## References

- https://sites.google.com/site/dabarnstudio/home/coco-music-file-formats/lyra-file-format
- Lyra user manual, Master Tempo and key-command sections (inverse tempo controls,
  per-note accidentals and ties).
- `level1/wildbits/cmds/play.as`, LyraRange, LyraLengths, LyraSubSeq. Its playback
  timing and event shortcuts are not used as a notation-format specification.

## Verification

`tools/test_lyra_import.py` executes assembled 6809 code, checks native score
callbacks, buffered merges, note timing, ties, per-note accidentals, channels,
program/volume/tempo, MIDI bytes, truncation, unsupported events, allocation
failure, and S/Y/U restoration. `test_score_browser.py` checks .lyr recognition,
loader arguments, return stack and .ume save naming. These CPU tests do not
replace MAME testing of the actual overlay-loading path.
