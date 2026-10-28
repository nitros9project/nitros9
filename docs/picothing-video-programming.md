# Programming the Pico-Thing video console

What a BASIC09, C or assembly program can do on the Pico-Thing video windows
(`/W0`–`/W7`), what is accepted but does nothing, and what is missing. The
byte-level details of every command are in
[copico-video-protocol.md](copico-video-protocol.md); the keys are in
[picothing-keys.md](picothing-keys.md).

The video console speaks the CoCo 3 window codes, so a program written for a
CoCo 3 window mostly runs unchanged. BASIC09 programs use GFX2, which is on the
Level 2 mega images; C and assembly programs write the same bytes to the path.
`level1/picothing/play/vgfx.b09` is a worked example.

## The screen

- **The panel is 1024×480 pixels, with a 128×30 text grid of 8×16 cells.**
  There is no screen mode to choose: every window is text over graphics.
- **Coordinates are panel pixels, measured from the window's top-left
  corner**, X 0–1023 and Y 0–479 for a full-panel window. They are not scaled:
  a CoCo 3 program that draws for 640×200 draws in the top-left part of the
  panel, squashed vertically.
- **Graphics is one plane shared by every window.** A window sets where
  coordinates start and where drawing is clipped; it does not own pixels.
  Switching windows switches the text, not the drawing.
- **Colours are 16 palette registers, shared by every window**, loaded with
  CoCo 3 6-bit RGB values. On a CoCo 3 each screen has its own palette,
  shared by the windows on it.
- **The eight windows are the eight devices** `/W0`–`/W7`. All of them cover
  the whole panel; F1–F8 show them. A program writes to its own window
  whether or not it is on screen.

## What works

GFX2 names, with the window code each sends. Each one behaves as on a CoCo 3
except where noted.

| Area | GFX2 calls | Notes |
|---|---|---|
| Drawing | `SetDPtr`, `Point`, `Line`, `Box`, `Bar`, `Circle`, `FCircle`, `Ellipse`, `FEllipse`, `Arc`, `Fill`, `Draw` | `Fill` is a 4-connected flood fill from the draw pointer. |
| Colour | `Color`, `Palette`, `DefCol` | 16 registers, shared by all windows. |
| Pattern and mix | `Pattern`, `Logic` (`OFF`, `AND`, `OR`, `XOR`) | Mixing combines with the graphics plane, not with the text over it. A pattern tile can be any size. |
| Buffers | `DefBuff`, `KillBuff`, `Get`, `Put`, `GPLoad` | Buffers live on the video Pico (2 MB). Pixels are RGB332, one byte each; see *Image and font formats* below. |
| Graphics cursor | `GCSet`, `PutGC` | The pointer follows the mouse on screen by itself. |
| Text | `CurHome`, `CurXY`, `CurOn`, `CurOff`, the cursor moves, `ErLine`, `ErEOLine`, `ErEOWndw`, `Clear`, `CrRtn`, `Bell`, `ReVOn`, `ReVOff`, `InsLin`, `DelLin`, `TCharSw`, `BoldSw`, `Font` | |
| Windows | `CWArea`, `DWProtSw` | `DWProtSw` off lets drawing leave the window; text always stays inside. |
| Sound | `Tone`, `Bell` | One voice. `Tone` returns when the note ends. |
| Keyboard | `INPUT`, `GET`, `ONMOUSE` with signal 0 | See *Input* below. |
| Status | `SS.Ready`, `SS.ScSiz`, `SS.ScTyp`, `SS.EOF`, `SS.SSig`, `SS.Relea`, `SS.Tone` | `SS.ScTyp` always reports type 2 (80-column text). `SS.ScSiz` always reports 128×30, after a `CWArea` too. |

## Accepted, does nothing

These are read and dropped, so they do no harm, but they have no effect.

| GFX2 call | Why |
|---|---|
| `OWSet`, `OWEnd` | Overlay windows are not built. Text goes to the window underneath. |
| `Border` | The panel has no border; it is active edge to edge. |
| `ScaleSw` | Coordinates are always panel pixels. |
| `PropSw` | The text is a fixed grid of cells; proportional text would need a different text layer. |
| `UndlnOn`, `UndlnOff`, `BlnkOn`, `BlnkOff` | The text cell has no spare attribute bit. |
| `SetMouse`, `SBar`, `UMBar`, `WnSet` | The driver accepts any SetStat it does not know and does nothing. There is no Multi-Vue. |

## Missing or different

| What | What happens |
|---|---|
| **`DWSet` from a program** | Wrong. The driver defines each window itself, using a form with the window number first. A CoCo 3 `DWSet` from a program is passed through and misread, and the bytes after it are shifted. Do not send it. |
| **`DWEnd` from a program** | Wrong. The video Pico closes the window and sends its output to `/W0`, but the driver still counts the window as open, so from then on everything written to it appears on `/W0`. On `/W0` it does nothing. Do not send it. |
| **Screen types** | There are none. A window cannot be made 40-column or 320×200; the type in `DWSet` is ignored. |
| **`Mouse`** | Fails with error 208 (`E$UnkSvc`): the driver does not answer `SS.Mouse`, although the video Pico reports the mouse. |
| **`ONMOUSE`** | A mouse button sends no signal. With signal 0 the program sleeps until a key is pressed. |
| **`WInfo`** | Fails with error 208: `SS.FBRgs` is not answered. |
| **`GetSel`** | Fails with error 208. There is no Multi-Vue, so menus built with `Menu`, `Item` and `Title` never appear. |
| **Reading pixels back** | Not possible. A CoCo 3 program reads the screen by mapping it with `SS.ScInf`, which fails here, and `Get` copies to a buffer on the Pico, which cannot be read back. |
| **`SS.Palet`, `SS.DfPal`, `SS.FBRgs`, `SS.ScInf`** | Fail with error 208. `SS.ScInf` could never work: there is no framebuffer in the 6809's memory. |
| **`SS.KySns`, `SS.Joy`** | Fail with error 208. The keyboard link carries characters, not held keys, and there is no joystick. |
| **Image formats** | `GPLoad` takes only RGB332 (type 1). A CoCo 3 image (types 5–8) is rejected and its data skipped. |
| **Fonts** | A font is 256 glyphs of 8×16, one byte per row (4096 bytes), loaded as a buffer. CoCo 3 8×8 fonts do not work. |
| **Pointer shapes** | A `GCSet` sprite is RGB332, at most 16×16, with `$E3` as the transparent colour and the hot spot at the top-left. CoCo 3 pointer buffers do not work. |
| **Editing keys** | Insert, Home, Page Up, Delete, End and Page Down send nothing. |

## Image and font formats

A buffer is defined with `DefBuff`, then filled with `GPLoad` or `Get`.

- **Image (`GPLoad` type 1):** width × height bytes, one RGB332 byte per pixel
  (`RRRGGGBB`), row by row, with no padding.
- **Pattern (`Pattern`):** any image buffer. Each pixel drawn is the colour AND
  the pattern pixel, so with a white colour the pattern shows as it is.
- **Font (`Font`):** 4096 bytes, glyph N at byte N×16, one byte per row.
- **Pointer (`GCSet`):** an image of at most 16×16; `$E3` is transparent.

Killing a buffer that is the current font or pointer puts back the built-in
one.

## Input

Keys arrive as plain bytes on the focused window (the one on screen); the
others see no input. F1–F8 switch windows and are not passed on. The bytes
each key sends are in the protocol document.

A program that waits for a key with `SS.SSig`, as the shell does, is woken
when a key arrives. The mouse cannot be read; see above.

## Sending codes from C or assembly

Write the bytes to the window's path with `write()` or `I$Write`. Each command
is `$1B`, a code and a fixed number of parameter bytes, with no length byte;
coordinates are two bytes, high byte first. Sending the wrong number of
parameters shifts every command after it. The codes and their parameters are
in [copico-video-protocol.md](copico-video-protocol.md).
