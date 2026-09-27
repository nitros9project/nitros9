# CoPico → Video Pico message protocol

The messages the 6809 sends to the Video Pico, and what it reads back. The
command stream is the CoCo3 windowing display codes (the protocol Basic09 GFX2
emits), so matching them makes GFX2 and `minted`/`ded` work unmodified.
Reference implementation to match is `level2/cmds/grfdrv.asm`.

The shipped guest driver is the standalone **`vcon`** (`vconw.asm`). Passages
naming **`copico`** describe the deferred co-module design and are kept as
reference; the register window and the byte streams are the same for both.
The firmware side is `pico-thing-video` (`vid_link.cpp`, `vid_console.cpp`).

## Register window (`$FF10`–`$FF17`)

MC6850-shaped. **Read it one byte at a time** — never a 16-bit load (`LDD`,
`LDX`, `LDU`) across `$FF10`/`$FF11`: reads have side effects, and a 16-bit
load is the only way to put two window accesses on consecutive bus cycles.

| Address | Read | Write |
|---|---|---|
| `$FF10` VID.Data | next **input** byte (keyboard; see *Keyboard input*) | next **command** byte (this document) |
| `$FF11` VID.Stat / Ctl | b0 RDRF, b1 TDRE, b2 READY, b5–3 protocol version (= 1), b6 MOUSE (moved since last pass), b7 IRQ (mirrors `!IRQ`) | b0 soft reset (flushes both FIFOs), b1 loopback, b7 RIE |
| `$FF12` VID.Mouse | next byte of the 7-byte mouse snapshot | any value: take a sample and home the index |
| `$FF13` VID.Info | next byte of the 6-byte surface description | any value: home the index |
| `$FF14`–`$FF17` | scratch | scratch |

- **The version field is the liveness check.** A reset, reflashing or unpowered
  Pico does not drive the bus: `$FF` reads as RDRF+TDRE+READY. Test
  `((stat >> 3) & 7) == 1` before believing any other bit; on a mismatch,
  discard output at once rather than waiting for TDRE.
- **Poll TDRE before EVERY command byte**, `GPLoad` payload included. A byte
  written into a full FIFO (2 KB) is dropped, and because the stream is framed
  by fixed parameter counts, one lost byte shifts every parameter after it.
- **`!IRQ`**: while Ctl RIE is set, `!IRQ` is asserted whenever RDRF is.
  RIE is off after reset.
- **VID.Mouse** snapshot, big-endian: buttons (b0 left, b1 right, b2 middle),
  buttons pressed since the last pass, X hi, X lo, Y hi, Y lo, wheel (signed).
  Presses and wheel accumulate between passes and clear when a pass starts, so
  a slow poll misses no click. Write `$FF12`, then read seven bytes: each pass
  is then self-framing. Coordinates are raw panel pixels (1024×480). The guest
  owns click counting, timers and hit-testing.
- **VID.Info**: width hi/lo, height hi/lo (pixels), text columns, text rows —
  of the selected window's working area (see *Window lifecycle*).
- **A monitor that dumps the window consumes input** by reading `$FF10` and
  steps the mouse index by reading `$FF12`.

## Wire format

Two streams share the link:

1. **Text/control bytes** — any byte `< $1B` or `>= $20` that is not part of an
   escape. Forwarded raw; the Pico's text layer interprets them (see the last
   section).
2. **Graphics commands** — `$1B` (ESC) + a **sub-code** (`$20`–`$55`) + a fixed
   number of parameter bytes. The sub-code is the message opcode: it is unique
   per command (unlike the grfdrv function code, which several commands share).
   The parameter count is fixed per opcode (below) and the Pico frames each
   message by that count alone — **there is no length byte**, and sending one
   would be read as the first parameter and desynchronise everything after it.
   Every sub-code in `$20`–`$55`, implemented or not, is framed by its count,
   so an unimplemented command is consumed cleanly.

**Coordinates are 16-bit, big-endian, X before Y** (verified from `SetDPtr`:
`ldq ,x` → X hi, X lo, Y hi, Y lo). A "point" parameter is therefore 4 bytes.

**Drawing uses a current draw pointer.** Most primitives take only a
*destination* point and operate from the pointer set by the last `SetDPtr`,
`LineM`, etc. Relative (`R…`) variants treat their point as a signed delta from
the pointer.

**Colours are palette-register indices** (0–15 on CoCo3; widen for the Pico).
`Palette` maps a register to an actual colour value.

---

## A. Window lifecycle

| ESC | Name | Params (bytes) | Video-Pico action |
|-----|------|----------------|--------------------|
| `1B 20` | DWSet | 8: id, type, colStart, rowStart, width, height, foreClr, backClr | Create/redefine device window `id` of `type` (screen mode) at the char-grid position/size; set fore/back palette regs. A window that will not fit the panel is **clamped, not rejected**; the guest reads the actual geometry back (see below). |
| `1B 21` | Select | 1: id | Make window `id` the **output target** — where text and graphics go. It does NOT change what is on screen. `id 0` = root = the physical panel. |
| `1B 26` | DWShow | 1: id | **Pico-Thing addition:** make window `id` the one **on screen**. |
| `1B 22` | OWSet | 7: style, colStart, rowStart, width, height, foreClr, backClr | Open an overlay window. **Framed but currently inert.** |
| `1B 23` | OWEnd | 0 | Close the overlay. **Framed but currently inert.** |
| `1B 24` | DWEnd | 0 | Close the target window; if it was on screen, the root is shown. |
| `1B 25` | CWArea | 4: colStart, rowStart, width, height | Set the working area inside the window (reversible: `DWSet` restores the whole window). `VID.Info` reports it. |

`type` selects the screen mode (CoCo3: 40/80-col text, 640×2, 320×4, 640×4,
320×16). Define your own mode numbers for the Pico's richer modes; keep the
CoCo values working for compatibility.

**Window identity — Pico-Thing divergence from CoCo3 (deliberate).** On CoCo3
window identity rides on the device path (`/w1`…`/w7`) and never reaches the byte
stream. The Pico-Thing link is a single stateless pipe with no per-path window
state, so identity is carried *in* the stream instead: `DWSet` and `Select` each
take a leading `id` byte (guest-chosen id space, no allocation protocol; `DWSet`
is re-definable — same id, new geometry). `id 0` is the root = the physical panel,
so `Select 0` returns to it. This lets a guest switch between long-lived *sibling*
windows (multiple text screens / shells), which a pure nesting stack cannot
express. Overlays (`OWSet`/`OWEnd`) would nest on the current window and carry no
id (they are not implemented yet). The extra `id` byte and the divergence are
noted in the firmware framing table.

**`Select` and `DWShow` are separate on purpose.** A driver selects a window
before every write burst; if that also switched the display, a background shell
would steal the panel once per line. Text written to a window that is not shown
goes into its parked screen and appears when it is shown. A window is a
rectangle of the one text grid, parked in PSRAM while not shown. **Graphics is
one plane, belonging to no window**: the window only sets where coordinates
start and where pixels are clipped (`DWProtSw` lifts the clip for graphics;
text always stays inside its window).

**Read-back keeps the guest's model truthful.** Because `DWSet` clamps rather than
rejects, the guest must read the *actual* built geometry rather than assume its
request stood. After `Select`, the `VID.Info` register (`$FF13`) reports the
current window's working area in the same 6-byte block used for the panel (width
hi/lo, height hi/lo, text cols, text rows, big-endian, pixels first;
write-homes-the-index). The driver answers `SS.ScSiz` straight from that, so a
program's screen size *is* its window; `Select 0` reports the panel. This one
read-back is the whole window read-back channel — no error channel and no
allocated-id read-back are needed, and the guest's window rectangle can never
silently diverge from what the firmware built (which is what keeps guest-side
mouse hit-testing correct).

## B. Colour & palette

| ESC | Name | Params | Action |
|-----|------|--------|--------|
| `1B 30` | DefPal | 0 | Reset palette to defaults. |
| `1B 31` | Palette | 2: register(0–15), colourValue | Load one palette register. **`colourValue` = CoCo3 GIME 6-bit RGB** (`RGBRGB`: bit5=R1 bit4=G1 bit3=B1 bit2=R0 bit1=G0 bit0=B0, value 0–63) — keeps GFX2/CoCo palette programming compatible; the video Pico LUT-expands each 2-bit channel to its RGB332 plane (e.g. `{0,2,5,7}`). Deeper/direct colour would be a future free opcode. |
| `1B 32` | FColor | 1: register | Set foreground palette register. |
| `1B 33` | BColor | 1: register | Set background palette register. |
| `1B 34` | Border | 1: register | Set border palette register. **Accepted but inert** (the panel is active edge to edge). |

## C. Get/Put buffers (off-screen bitmaps, all Pico-side)

| ESC | Name | Params | Action |
|-----|------|--------|--------|
| `1B 29` | DefGPB | 4: group, buffer, lenHi, lenLo | Allocate a get/put buffer of `len` bytes. (verified: `ldq ,x` = group/buffer/length) |
| `1B 2A` | KillBuf | 2: group, buffer | Free a get/put buffer. Killing one currently selected as the font or cursor **drops that selection back to the built-in default** — never a dangling pointer or a crash (see the note in section F). |
| `1B 2B` | GPLoad | 9: group, buffer, screenType, Xsize(2), Ysize(2), bufSize(2) — **then `bufSize` bytes of image data follow in the stream** | Load an image into a buffer. The 9 bytes are a header; the pixel payload streams after it (the one variable-length message — see notes). `screenType 1` = RGB332 (`0` reserved/invalid). |
| `1B 2C` | GetBlk | 10: group, buffer, X, Y, Xsize, Ysize | Copy a screen rectangle **into** the buffer. |
| `1B 2D` | PutBlk | 6: group, buffer, X, Y | Blit the buffer **to** the screen at X,Y. |

Note: `GetBlk` reads screen→buffer *on the Pico*; the data does not return over
the link. Program-visible read-back (pixel value, mouse, window info) is a
separate GetStat channel, not one of these messages.

**Buffer storage, identity and pixel format (agreed):**

- **Identity** — a `(group, buffer)` byte pair. `group` lets a caller allocate a
  whole set and free it in one `KillBuf`.
- **Storage** — Pico-side, in a **2 MB PSRAM pool**, not the scarce SRAM.
  Allocation is a bump pointer: a freed buffer's bytes are reused only once
  **every** buffer has been freed, when the pool starts again (a deliberate
  refusal to write an allocator that can fragment). A guest that cycles buffers
  forever should free them all now and then. Up to 32 buffers at once; a
  `DefGPB` that does not fit is ignored. `GetBlk`/`PutBlk` are guest-initiated
  block moves, not per-frame work.
- **Pixel format** — **raw RGB332, row-major, `Xsize*Ysize` bytes, no padding**:
  the framebuffer's own format, so `GetBlk`/`PutBlk` are row `memcpy`s with no
  conversion on either path. This is the only pixel layout on the wire, and it
  is carried only by `GPLoad` (`screenType 1`; `0` is reserved so an all-zero /
  truncated header is rejected rather than rendered as garbage).

## D. Fill pattern & draw logic

| ESC | Name | Params | Action |
|-----|------|--------|--------|
| `1B 2E` | PSet | 2: group, buffer | **Pattern Set** — use this get/put buffer as the pattern for every subsequent pixel-plotting primitive, `PutBlk` included (`buffer 0` = disable → solid). *(this is pattern-set, NOT plot-point — verified.)* |
| `1B 2F` | LSet | 1: logicType | Set the pixel mix mode for all subsequent drawing: **`0` normal (default), `1` AND, `2` OR, `3` XOR**. |

**Pattern rule (agreed; matches CoCo3 GrfDrv except where marked):**

- **Scope** — the pattern applies to every pixel-plotting primitive: `Point`,
  `Line`, `Box`, `Bar`, `Circle`/`Ellipse`/`Arc` outlines, `FCircle`/`FEllipse`,
  `FFill` and `PutBlk`. The graphics cursor and mouse pointer are exempt (they
  are overlays, as GrfDrv exempts its graphics cursor).
- **Combine** — each pixel is written as `colour AND pattern pixel`, then mixed
  by the `LSet` mode. The colour is `FColor` for drawing primitives and the
  source pixel for `PutBlk`, so a stamp is `image AND pattern`. GrfDrv ANDs
  palette indices; the Pico ANDs RGB332 bytes. With a white foreground the
  pattern shows verbatim; a `0` in the pattern writes `0` (not transparent).
- **Anchor** — the tile is indexed from the **window** origin and follows each
  pixel as it is plotted (not the primitive's start point), so abutting fills
  line up.
- **Pico extensions** — the tile is whatever size its buffer is (GrfDrv fixes
  it at 32×8), and `PutBlk` tiles per pixel like every other primitive (GrfDrv's
  slow PUT freezes one pattern byte at the destination, an apparent oversight).

**Mix modes combine with the graphics plane, not the screen.** An XOR across a
window of text combines with the drawing underneath, not the glyphs; `GetBlk`
reads the graphics plane too. `logicType 0` (normal/replace) is the default and
the cheapest.

**Performance (measured on the board, full 1024×480 panel):** patterned `Bar`
12.5 ms, plain `FFill` 13.2 ms, patterned `FFill` 16.0 ms — patterns and mix
modes are drawn a span at a time, not per pixel. About 10 ms of each is the
Pico writing its PSRAM copy of the graphics plane, a floor. A guest never waits
on a command directly; it waits on TDRE while the Pico catches up.

## E. Draw pointer & drawing primitives (coordinates 2 bytes each)

| ESC | Name | Params | Action |
|-----|------|--------|--------|
| `1B 40` | SetDPtr | 4: X, Y | Move draw pointer (absolute). |
| `1B 41` | RSetDPtr | 4: dX, dY | Move draw pointer (relative). |
| `1B 42` | Point | 4: X, Y | Plot one point at X,Y (absolute); pointer follows. |
| `1B 43` | RPoint | 4: dX, dY | Plot one point (relative). |
| `1B 44` | Line | 4: X, Y | Line from pointer to X,Y (absolute). |
| `1B 45` | RLine | 4: dX, dY | Line, relative. |
| `1B 46` | LineM | 4: X, Y | Line to X,Y and move pointer to the endpoint. |
| `1B 47` | RLineM | 4: dX, dY | Line-and-move, relative. |
| `1B 48` | Box | 4: X, Y | Rectangle outline, pointer→X,Y (absolute). |
| `1B 49` | RBox | 4: dX, dY | Box, relative. |
| `1B 4A` | Bar | 4: X, Y | Filled rectangle, pointer→X,Y (absolute). |
| `1B 4B` | RBar | 4: dX, dY | Bar, relative. |
| `1B 4E` | PutGC | 4: X, Y | **Put Graphics Cursor**: move the graphics (mouse-sprite) cursor to X,Y — erase it from the old spot and redraw it there using the `GCSet` pattern. |
| `1B 4F` | FFill | 0 | Flood-fill the area at the draw pointer (4-connected, bounded by any colour other than the one under the pointer). A large fill is spread over several render passes, and **no later byte is interpreted until it finishes**, so what the guest sends next cannot land in its path. |
| `1B 50` | Circle | 2: radius | Circle centred at the pointer. |
| `1B 51` | Ellipse | 4: Xradius, Yradius | Ellipse centred at the pointer. |
| `1B 52` | Arc | 12: Xradius(2), Yradius(2), clipStartX(2), clipStartY(2), clipEndX(2), clipEndY(2) | Ellipse outline centred at the draw pointer, keeping only the points on one side of the clip line, as GrfDrv does. The clip line's ends are **signed offsets from the centre**, not screen positions. See the Arc clip rule below. |
| `1B 53` | FCircle | 2: radius | Filled circle. |
| `1B 54` | FEllipse | 4: Xradius, Yradius | Filled ellipse. |

**Arc clip rule** (from GrfDrv, `level2/cmds/grfdrv.asm`): with clip line
ends (x1,y1) and (x2,y2), a point at offset (dx,dy) from the centre is kept
when:

- **Vertical line** (x1 = x2, and a single-point line counts as vertical):
  if y1 < y2, dx ≥ x1; otherwise dx ≤ x1. GrfDrv's comments on these two
  cases say the opposite of its code; the firmware follows the code.
- **Horizontal line** (y1 = y2): if x1 < x2, dy ≤ y1; otherwise dy ≥ y1.
- **Otherwise**: (dx − x2)(y1 − y2) ≤ (dy − y2)(x1 − x2).

The clip region, pattern and `LSet` mix mode apply as for any outline. Each
point of a circle, ellipse or arc is plotted once, so XOR drawing keeps the
extreme pixels at the top, bottom, left and right.

## F. Text attributes, fonts, cursor

| ESC | Name | Params | Action |
|-----|------|--------|--------|
| `1B 35` | ScaleSw | 1: on/off | Coordinate scaling on/off. **Accepted but inert:** coordinates are raw panel pixels. |
| `1B 36` | DWProtSw | 1: on/off | Window protect on/off. **Graphics only:** off lets drawing leave the window (coordinates still measure from its corner); text always stays inside, since wrap and scroll are defined by the window. |
| `1B 39` | GCSet | 2: group, buffer | Set the graphics (mouse) cursor sprite from a buffer. |
| `1B 3A` | Font | 2: group, buffer | Select the text font from a buffer (a **loadable** face, not a firmware index). |
| `1B 3C` | TCharSw | 1: on/off | Transparent-character (background show-through) on/off. |
| `1B 3D` | Bold | 1: on/off | Bold text on/off. |
| `1B 3F` | PropSw | 1: on/off | Proportional spacing on/off. **Accepted but inert:** proportional text is a separate text layer, not a flag on this cell grid (cursor, wrap, scroll, the dirty map and the parked window screens are all column-indexed, and a variable-width glyph has no column). A guest that needs it is a design conversation, not a missing case. |

**Font buffer layout (agreed):** 256 glyphs, **16 bytes each, one byte per row
(8×16 cell), glyph N at offset `N*16`, 4096 bytes total** — byte-for-byte the
face the firmware already carries, so a loaded font drops into the same blitter
with no repacking. A **short** buffer (fewer than `16*(N+1)` bytes) cannot
address glyph N; such a glyph renders **blank** rather than reading past the end.

**Graphics-cursor sprite (GCSet, agreed):** RGB332 pixels, dimensions taken from
the buffer's own `Xsize`/`Ysize` (nothing to add to GCSet — `GPLoad` already
carried them), **capped at 16×16** (larger uses the top-left). Transparency is a
**key colour `$E3`** (bright magenta, `RRRGGGBB` = `111 000 11`) — no separate
mask plane. The **hotspot is `(0,0)` by definition** (GCSet carries no hotspot
field): a guest must draw its sprite so the point pixel is top-left, as the
current arrow does.

**Selection is a resolved pointer (guest-visible):** selecting a face (`Font`)
or sprite (`GCSet`) resolves the buffer to a pointer **once**, at selection time
— a full-screen refresh asks for 3840 cells, so a per-glyph buffer-table lookup
would be felt. The consequence a guest must know: `KillBuf` on the buffer a face
or sprite is currently using **reverts that selection to the built-in default**
(not a dangling pointer, not garbage). Reselect after reloading if you kill and
rebuild a face in place.

## Free opcodes (extension slots)

Unused in the CoCo3 set, free for Pico-native commands (deep palette, big
modes, blits, etc.) without breaking GFX2. Each is framed with **zero**
parameters today; giving one parameters is additive, since no existing count
moves.

`1B 28  1B 37  1B 38  1B 3B  1B 3E  1B 4C  1B 4D  1B 55`

(`1B 26` was on this list; it is now `DWShow`. `1B 27` is now `Tone`.)
Allocate new commands from the low end, `1B 28` next.

## Sound

| ESC | Name | Params (bytes) | Video-Pico action |
|-----|------|----------------|--------------------|
| `1B 27` | Tone | 4: pitch(2), duration, volume | **Pico-Thing addition:** play a square-wave note on the speaker output (GP40, the same one the `07` bell uses). The parameters are the CoCo 3 `SS.Tone` values: `pitch` 1–4095 is CoCo 3 relative pitch, big-endian, sounding at 1789772.5 / (16 × (4096 − pitch)) Hz as on a 1.79 MHz CoCo 3 (4000 ≈ 1165 Hz); `duration` is in 1/60 s ticks, and 0 stops any note now; `volume` is 0–63 (0 silent, higher values clamped). A pitch outside 1–4095, or one above 20 kHz, is silent. The note starts at once, replaces any note or bell already sounding, and does not hold up the byte stream: there is one voice and no queue. |

The window driver answers `SS.Tone` with this command, refusing a pitch
outside 1–4095 and doing nothing at volume 0 as the CoCo 3 sound driver does,
and returns when the note has finished, so a BASIC09 program's notes
(`RUN GFX2("Tone",pitch,duration,volume)`) play one after another.

---

## Text / control-code layer (raw bytes, not `1B` escapes)

Forwarded verbatim; the Pico's text renderer must react to the CoCo3/OS-9 text
control codes. The common set (match grfdrv/vtio exactly when implementing):

| Byte | Action |
|------|--------|
| `01` | Home cursor |
| `02` x y | Position cursor (x = col+$20, y = row+$20, one byte each) |
| `03` | Erase line |
| `04` | Erase to end of line |
| `05` `20`/`21` | Cursor off / on |
| `06` | Cursor right |
| `07` | Bell: a 1 kHz tone for 120 ms, a PWM square wave on GP40 (test point TP613), which needs a low-pass filter, amplifier and speaker fitted there. A `07` that is a parameter byte (a cursor position or coordinate) is part of its command and does not ring |
| `08` | Cursor left (backspace) |
| `09` | Cursor up |
| `0A` | Cursor down (line feed) |
| `0B` | Erase to end of window |
| `0C` | Clear window / home |
| `0D` | Carriage return |
| `0E`–`1A`, `1C`–`1E` | Ignored |
| `1F` s | Attribute / line code (sub-code `s`, below) |
| `20`–`FF` | Printable glyph (CP437 font) |

*(`$02`, `$05` and `$1F` carry a fixed number of following bytes; the rest are
single bytes. `$05 $20` turns the cursor off, `$05 $21` on. `minted`/`ded` rely
on `$02`, `$0C`, `$01`; `ded` also uses `$1F $20`/`$21`, and `minted` uses
`$1F $30`/`$31` when it finds a CoCo3 window.)*

**The `$1F` family** (CoCo3 GrfDrv semantics, `L1483`; firmware `d032fdb`).
Always exactly two bytes; an unknown sub-code is consumed and does nothing.

| Code | Action |
|------|--------|
| `1F 20` / `1F 21` | Inverse video on / off, per window (follows the `Select` target; cleared by `DWSet` and link reset). True reverse video - the glyph mask is inverted, so the cell shows the foreground colour and the glyph the background (over graphics, the glyph shows the drawing). It also applies to erases (`$03 $04 $0B $0C`) and to the blank line left by insert/delete, as GrfDrv's default attribute does. |
| `1F 22` / `1F 23` | Underline on / off - **accepted and ignored** (see below) |
| `1F 24` / `1F 25` | Blink on / off - **accepted and ignored** |
| `1F 30` | Insert line: a blank line at the cursor row; the rows below move down and the window's bottom row is lost |
| `1F 31` | Delete line: the cursor row is removed; the rows below move up and the bottom row is cleared |

Insert and delete act on the current window's working area only (after any
`CWArea`), leave the cursor where it is, clear the row when the cursor is on the
bottom row, and work on a window that is not on screen. Underline and blink are
ignored because the text cell's attribute byte had one free bit, now used by
inverse; a second attribute plane would cost 3,840 bytes of SRAM the device
build does not have.

---

## Keyboard input (`$FF10` VID.Data, read side)

What the keys do for a user — window switching, signals, line editing, Shell+
history, minted — is in [picothing-keys.md](picothing-keys.md). This section
is the bytes.

The Pico cooks each USB key-down into **one plain byte** — no tags, no key-up.
Auto-repeat happens on the Pico: after 500 ms, 20 per second, and **never queued
behind a byte the guest has not read**, so a busy guest gets a slower repeat,
never a backlog that keeps typing after release. Function keys and the lock keys
do not repeat. The input FIFO holds 256 bytes.

| Key | Byte(s) | Notes |
|---|---|---|
| Letters, digits, punctuation | ASCII | UK layout; Caps Lock XOR Shift for letters |
| £ / ¬ | `$9C` / `$AA` | CP437, matching the display font |
| Ctrl + letter / `@[\]^_` | `$00`–`$1F` | C0 controls, as a terminal folds them |
| Enter, keypad Enter | `$0D` | CR — the OS-9 line terminator |
| Backspace / Tab / Esc | `$08` / `$09` / `$1B` | |
| F1–F12 | `$80`–`$8B` | reserved for the guest; nothing else produces this range. VConW spends F1–F8 on window switching (`/V0`, `/W1`–`/W7`) and drops F9–F12 |
| Up / Down / Left / Right | plain `$0C` / `$0A` / `$08` / `$09`; Shift `$1C` / `$1A` / `$18` / `$19`; Ctrl `$13` / `$12` / `$10` / `$11` | the CoCo keyboard's bytes (VTIO `KeyTbl`), which `minted` uses for page, delete and line-end moves; Shift wins over Ctrl, as in VTIO. Plain Left is Backspace's byte and plain Right is Tab's — indistinguishable. Shift+Left is Ctrl-X (SCF line-kill), Ctrl+Up/Right are XOFF/XON — all as on a CoCo |
| Keypad, Num Lock on (default) | `0`–`9` `.` `/` `*` `-` `+` | same bytes as the main keys |
| Keypad, Num Lock off | 8/2/4/6 → the arrows, Shift and Ctrl included | 7/1/9/3/0/. as the editing keys below; 5 sends nothing |
| Caps Lock, Num Lock | nothing | toggles only |
| Insert, Home, Page Up, Delete, End, Page Down | **nothing** | see the proposal below |
| Print Screen, Scroll Lock, Pause | nothing | |

**PROPOSED, not implemented — the editing keys.** OS-9 has no convention for
these; neither the CoCo keyboard nor the Wildbits PS/2 driver produces them.
Proposal: continue the function-key block, a range **nothing else produces**,
for the guest to spend as it likes — Home `$8C`, End `$8D`, Page Up `$8E`,
Page Down `$8F`, Insert `$90`, Delete `$91`; keypad 7/1/9/3/0/. with Num Lock
off would send the same. No byte the Pico sends today lands there, so no guest
can already rely on these values. The obvious alternative for Delete is `$7F`
(ASCII DEL), set aside only because what `$7F` should do in SCF is the guest's
decision. Open questions: accept these values (or `$7F` for Delete)? should
`vcon` map any onto SCF editing characters or pass them raw? should all six
auto-repeat (proposed: yes, they are navigation)? The firmware sends nothing for
them until this is agreed.

---

## Notes for the copico side

- **Send the sub-code as the message opcode**, not the grfdrv function code —
  Line/RLine/LineM/RLineM share grf `$4A`; Box/RBox share `$4C`; Bar/RBar `$4E`;
  Point/RPoint `$48`; Circle/FCircle `$50`; Ellipse/FEllipse `$52`. Only the
  sub-code distinguishes them. (Adjust the skeleton's `V.CallCde` to hold the
  sub-code.)
- **All these messages are fire-and-forget.** No reply comes back over the Write
  link. A future GetStat (`SS.*`) request/response channel handles read-backs.
- **`GPLoad` is the one variable-length message.** Its 9 bytes are a header; a
  further `bufSize` bytes of image data follow. `copico`'s fixed-count framing
  covers only the 9 header bytes, so `GPLoad` needs special handling — read
  `bufSize` from the header, then stream that many trailing bytes to the Pico
  (the CoCo3 `cowin` handler does the same, pulling the payload from the path
  after the header).
- **Coordinate scaling**: decide whether coords arrive already scaled to pixels
  or normalized (with `ScaleSw` controlling it, as on CoCo3). Keeping the Pico
  the scaler lets GFX2's device-independent coords fill any Pico resolution.

---

# GetStat / SetStat read-back channel

The Write stream (above) is fire-and-forget. Status calls (`SS.*`) are the
*read-back* path. The CoCo3 window module (`cowin`) services these GetStat
codes: `SS.ScSiz`, `SS.ScTyp`, `SS.Palet`, `SS.DfPal`, `SS.FBRgs`, `SS.ScInf`,
`SS.MnSel` (plus `SS.Mouse`/`SS.Cursr`/`SS.Joy` on the input side). Reaching
`copico`, they arrive at `CoGetStt` ($06) / `CoSetStt` ($09).

## Design principle: three sources, round-trip only for pixels

Do **not** round-trip the Pico for most status calls. There are three sources,
in cost order:

1. **Local config shadow** — values `copico` itself set (it wrote them). Answered
   with zero link traffic.
2. **Input** — keyboard and mouse. Keystrokes arrive as bytes on `VID.Data`
   (RDRF, optionally `!IRQ`); the mouse is the polled `VID.Mouse` snapshot. No
   query and no tagged frames: the guest reads registers.
3. **Synchronous round-trip to the Pico** — only for reading *rendered pixels*
   (GFX2 `POINT`). The one thing neither shadow can know.

## Tier 1 — answered from copico's local shadow (no link traffic)

*(This tier describes the deferred `copico` co-module design, kept as reference.
The **shipped** standalone `vcon` driver holds no per-window shadow; it answers
`SS.ScSiz` by reading the window-relative `VID.Info` register directly — see
"Read-back keeps the guest's model truthful" under Window lifecycle. The rest of
this tier applies only if the co-module is ever revived.)*

| SS code | Returns | Shadow source |
|---------|---------|---------------|
| `SS.ScSiz` | window X/Y size | set at `DWSet`/`CWArea` |
| `SS.ScTyp` | screen type | `DWSet` |
| `SS.Palet` | 16 palette registers | `Palette`/`DefPal` |
| `SS.DfPal` | default palettes | constant table |
| `SS.FBRgs` | fore/back/border registers | `FColor`/`BColor`/`Border` |
| `SS.ScInf` | window geometry | see gotcha below |

Return values go into the caller's register stack (`R$X`/`R$Y`/`R$U`/`R$A`/`R$B`)
exactly as `cowin` fills them — `copico` just sources them from its shadow
instead of grfdrv's tables. So `copico` must **maintain a per-window shadow** of
everything it sends (type, size, palette, colours, scale flag, draw pointer).

**Gotcha — `SS.ScInf`:** on CoCo3 this returns the physical video-RAM offset and
8K-block count so a program can write the framebuffer *directly*. Pico-Thing has
no CPU-visible framebuffer (the Pico owns it), so that contract cannot be
honoured. Return an error (or a "no direct video" marker) so callers fall back
to the display-code path instead of poking nonexistent video RAM.

## Tier 2 — input, read from the register window

*(This replaces the earlier plan of tagged input frames over a UART, which was
never built.)*

| SS code | Returns | Source |
|---------|---------|--------|
| `SS.Mouse` | mouse packet (x, y, buttons) | the `VID.Mouse` snapshot; the driver keeps click counts and timers |
| `SS.Cursr` | cursor info | driver state |
| `SS.Joy` | joystick value | **none** — no joystick on this device |
| `SS.MnSel` | next menu event | not implemented |
| `SS.KySns` | keys held | **none** — the link carries characters, not key state (see below) |

Keyboard characters come through `Read`, from `VID.Data`.

**No key-state channel.** CoCo3 `vtio` and the Wildbits driver keep held-key
bits (arrows, Shift, Ctrl, Alt) for `SS.KySns` — games and the keyboard mouse
use them. This link sends a byte per key-down and nothing on release, so a
program polling `SS.KySns` sees no keys. Adding it would be a snapshot register
in the style of `VID.Mouse`; not planned yet.

## Tier 3 — the synchronous round-trip (the real read-back channel)

Needed only to read a rendered pixel back.

**`QGetPix`** — read the pixel colour at X,Y.
- Request (copico → Pico): query opcode + X(2) + Y(2).
- Reply (Pico → copico): the colour byte.

Transport for the return path (the command link is write-only), two options:

- **(a) Mailbox registers** — a reply-data register + a "reply-ready" status bit.
  `copico` writes the query, polls the ready bit with a **bounded** wait (mirror
  `clock2_ds12885`'s `ldx #$1000` UIP timeout — never hang the OS on a missing
  reply), reads the byte, and times out to a safe default (colour 0) on silence.
- **(b) Tagged reply over the input UART** — the Pico returns the reply as an
  input frame with a "query-reply" tag; the ISR drops it in a reply slot and
  sets a flag; the query waits (bounded) on that flag. One physical return wire,
  shared with input, but reply latency is tied to ISR servicing.

Use (a) for `POINT` (it wants a prompt synchronous answer); (b) if you prefer a
single return channel. Either way: **bounded wait + safe default**, and mask
IRQs / hold a link lock across request+reply so a concurrent draw or query from
another process cannot interleave and hand you the wrong reply.

**Framing the query:** flag it as reply-generating by reserving one of the free
display sub-codes (e.g. `$1B $27` = `QGetPix`) so it rides the same command
stream but the Pico knows to answer, or by using a dedicated query register
(writing it implies "reply expected") separate from the command register. *(Not
built. Option (b) no longer applies: there is no input UART, only
`VID.Data`.)*

## SetStat (`CoSetStt`)

Writable status — `SS.GIP` (global input parameters: key-repeat, mouse
resolution), cursor setup, etc. These are fire-and-forget config: forward them
to the Pico as ordinary command frames. No reply needed. *(Not built: the key
repeat is fixed at 500 ms / 20 per second in the Pico. Making it settable needs
a free `$1B` sub-code for `SS.GIP` to carry, agreed on both sides.)*
