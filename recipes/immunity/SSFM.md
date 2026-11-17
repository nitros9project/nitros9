# V9958 text screens (SuperSprite-FM+) for NitrOS-9 Level 2, i-MMU-nity port

This adds 40x24 or 80x24 text consoles on the Yamaha V9958 of John
Whitworth's SuperSprite-FM+ to the CoCo 1/2 / Dragon i-MMU-nity port. They
have true lower case, per-screen colours, reverse video, alternate colours
or blinking (80 columns), scrolling working areas and overlay windows.

The VDG keeps running (it still produces the clock interrupt); only its
picture is routed away, with the board's video multiplexer.

Hardware used for development and testing: Dragon 64 with HD63C09, i-MMU-nity
1 MB, Tandy MPI with a CoCo-SDC and the SuperSprite-FM+. XRoar was used to
check the structure (screen switching, commands), but it has no V9958, so
nothing can be seen there.

## Two build modes

| `SSFM` | What you get |
|---|---|
| `0` | Nothing changes (the default). |
| `1` | One extra V9958 text screen, `/V9`, next to the VDG consoles. CLEAR and SHIFT-CLEAR switch between all of them. |
| `2` | `/Term` and `/V1` ... `/V7` are all V9958 screens (up to 8). The VDG only shows the boot messages. |

CoVDG stays the module that VTIO links; with `SSFM` > 0 it gets a second
"personality" for the V9958 screens (VTIO links a module named `CoVDG` for
every device whose parity byte has bit 7 clear, so a separate co-module was not
possible without changing VTIO). It must be built with `HIRES=0`.

## Files

In `level2/immunity/modules`:

| File | Purpose |
|---|---|
| `ssfm.asm` | The V9958 personality of CoVDG: control codes, escape sequences, GetStat/SetStat, Init/Term/select. |
| `vdp9958.asm` | The VDP layer: ports, register tables, text routines, areas, overlays. |
| `vdpfont.asm` | A 96-glyph 6x8 font (screen code = ASCII - 32). |
| `v9win.asm` | Descriptor of `/V9` (`SSFM=1`). |
| `covdg.asm` | The existing file, patched: small `IFNE SSFM` hooks at Init, Term, Write, GetStat, SetStat, the select entry and DispAlfa. |
| `term_vdg.asm`, `vdgwin.asm` | Patched so the descriptors of `/Term`, `/V1` ... get 40x24 or 80x24 when `SSFM=2`. |

In `recipes/immunity`: `immunity.mak` (patched, the build options below) and
`ssfm_startup.awk` (adds the SuperSprite line to the startup text).

## Build options (`immunity.mak`)

| Option | Default | Meaning |
|---|---|---|
| `SSFM` | `0` | `0` off, `1` extra `/V9` screen, `2` all consoles. |
| `SSFM_COLS` | `80` | `40` or `80` columns for every V9958 screen (the VDP has a single mode). |
| `SSFM_MPI` | `1` | `1`: board jumpered to `$FF58`-`$FF5E` (MPI / MultiPack). `0`: `$FF78`-`$FF7E` (Y-cable module). |
| `SSFM_SLOTSW` | `0` | `1`: select the board's MPI slot (`$FF7F`) around every VDP access. Needed when the SuperSprite is in another slot than the disk controller and the `$FF58` range is used. |
| `SSFM_SLOT` | `0` | Value written to `$FF7F` for that: slot #0 = 0, #1 = 17, #2 = 34, #3 = 51. |
| `SSFM_DEBUG` | `0` | `1`: `INIZ /V9` switches the monitor to the V9958 at once (`SSFM=1` only; for bring-up). |

Example, Dragon with the SuperSprite in MPI slot #0 and the SDC in slot #1:

```
make clean
make SSFM=2 SSFM_COLS=80 SSFM_MPI=1 SSFM_SLOTSW=1 SSFM_SLOT=0
```

Run `make clean` after changing an option: they are compile-time flags. The
disk's `startup` file gets an extra welcome line with `SSFM` > 0.

## Using the screens

* `INIZ` only attaches a device. A screen becomes selectable with CLEAR once
  something has opened it (a shell, or `display ... >/V1`): VTIO's CLEAR search
  relies on state that is set at `SS.Open`, and selecting a never-opened
  device would hang the machine.
* Typical use: `INIZ /V1` then `SHELL I=/V1&`, then CLEAR to get there.
* Output to a screen is drawn in its VRAM page even when another screen is
  displayed; CLEAR shows it.
* The page-pause value (`PD.PAG`) of the paths follows the working area's
  height, so `MDIR -E` pauses after as many lines as the window has.

## VRAM layout

* Each screen has a page of `$2000` bytes at `n * $2000` (`/Term` = 0,
  `/V1` ... `/V7` = 1 ... 7): name table at `+$0000`, blink table at `+$0A00`
  (80 columns).
* The font is shared, in page 0: `$0800` (40 columns) or `$1000` (80). The
  256 glyph slots hold the normal glyphs (codes 0-95) and an inverted copy
  (codes 128-223) used for reverse video.
* The upper 64K holds the area saved under overlay windows, 8 KB per screen at
  `$10000 + n * $2000`.
* Screen switching (CLEAR) only writes `R#2`, `R#3`, `R#7`, `R#10` and `R#12`;
  no text is copied.

## Colours

* The palette (16 entries) is shared by all screens. Power-up and `DefColr`
  load the manual's order (0 white, 1 blue, 2 black, 3 green, 4 red,
  5 yellow, 6 magenta, 7 cyan, 8-15 lighter versions), with values taken from
  an MSX2 palette. Edit `VdpDefPal` in `vdp9958.asm` to change it.
* Text and background colours are per screen (`R#7`); default: palette 5 on
  palette 1. The alternate pair (`R#12`) is per screen too; default palette 12
  on palette 1.
* `R#8` is set to `$28` (`VR` + `TP`, sprites enabled). `TP` makes no difference in the text modes: on the V9938/V9958 colour code 0 is transparent in Text 1 and Text 2 whatever the `TP` bit says (no `R#8` value changed it on a SuperSprite-FM+). The normal background colour (`R#7` low nibble) is the backdrop, so it obeys the palette, and palette entry 0 can be used for it.
* Colour 0 as a foreground would therefore be invisible. Because CoCo 3 programs expect palette 0 (white by default) to be usable as a text colour, `V9FG0` = 1 (the default, in `vdp9958.asm`) draws colour 0 as a foreground (`1B 32`, the foreground of DWSet, the alternate foreground) with palette entry 8 (colour 0 as a background, normal or alternate, obeys the palette and is not changed), and `1B 31 0 ct` sets entry 8 as well as entry 0. With the default palette both are white. Entry 8 should not be redefined separately if colour 0 is also used as a foreground. Set `V9FG0` to 0 to turn this off.
* The border follows the background; `1b 34` is accepted and ignored.

## Control codes

Coordinates are relative to the working area, `+$20` encoded.

| Code | Effect |
|---|---|
| `01` | Home the cursor. |
| `02 x y` | Move the cursor (ignored if outside the area). |
| `03` | Erase the current line (cursor to column 0). |
| `04` | Erase from the cursor to the end of the line. |
| `05 20` / `05 21` | Cursor off / on. |
| `06`, `08` | Right, left. They wrap between rows like CoVDG's linear cursor, which SCF's line editing needs for commands that span several rows. |
| `09`, `0A` | Up, down; down at the last row scrolls the area. |
| `0B` | Erase from the cursor to the end of the area. |
| `0C` | Clear the working area and home the cursor. |
| `0D` | Carriage return. |
| `0E` ... `1A` | Graphics codes: accepted, no effect. |
| `1F 20` / `1F 21` | Reverse video on / off. |
| `1F 22` / `1F 23` | Underline: accepted, no effect. |
| `1F 24` / `1F 25` | Alternate colours (or blinking) on / off for the characters printed from now on. 80 columns, see below. |
| `1F 30` / `1F 31` | Insert a line at the cursor row / delete the cursor row. |

## Escape sequences (`1B`)

| Sequence | Effect |
|---|---|
| `1B 20 STY CPX CPY SZX SZY PRN1 PRN2 PRN3` | DWSet. The rectangle becomes the device window and the working area. The whole page is cleared first, then the cursor goes to the window's top left. `STY` is ignored; `PRN1`/`PRN2` set the foreground and background (palette numbers); `PRN3` is ignored. An empty rectangle or one that does not fit returns error 195 (illegal window definition). |
| `1B 21` | Select, CoVDG's code. |
| `1B 22 SVS CPX CPY SZX SZY PRN1 PRN2` | OWSet: open an overlay on the rectangle (relative to the device window). With `SVS` <> 0 the area under it is saved and the overlay cleared; with 0 neither. Colours are those of the parent (`PRN1`/`PRN2` ignored). Illegal coordinates: error 189; no room to save: `E$NoRAM`. |
| `1B 23` | OWEnd: close the top overlay and restore what it covered, the previous window, working area and cursor. Error 195 if there is none. |
| `1B 25 CPX CPY SZX SZY` | CWArea: restrict the working area to a rectangle relative to the origin of the current window (the device window, or the top overlay), not to the current working area; so a smaller area can always be enlarged again, up to the window. The cursor goes to its top left. The whole window is cleared, inside the new area and outside it, so old and new text never mix. `1B 28 00` (below) switches that off, and then all the text stays on the screen, as in CoWin (the cursor is the underscore and replaces the character under it, so on a screen full of text it is easy to miss): a program can protect a header or a menu while a body area scrolls. Error 195 if the rectangle is empty or outside the window. A bigger window than the device window needs a new DWSet. |
| `1B 30` | DefColr: default palette. |
| `1B 31 PRN CTN` | Palette register `PRN` (0-15) := CoCo 3 colour `CTN` (0-63; bits 0 blue low, 1 green low, 2 red low, 3 blue high, 4 green high, 5 red high), converted to the V9958's 3 bits per channel. |
| `1B 32 PRN`, `1B 33 PRN` | Foreground / background colour of the screen (palette number). While alternate colours are on (`1F 24`), they set the alternate pair instead. |
| `1B 34 PRN` | Border: accepted, no effect. |
| other `1B xx ...` | The parameter bytes of every windowing command (fonts, buffers, drawing ...) are swallowed with the right counts, so they are not printed; they have no effect. |

Only the top overlay can be written to. To go back to a lower one, close the
ones above it with OWEnd. Overlays may overlap each other; they must lie inside
the device window.

## Alternate colours and blinking (80 columns)

Text 2 has a blink table with one bit per cell. A flagged cell is shown in the
`R#12` colours. With `R#13 = $F0` (the default) they are steady, giving four
colours on the screen: two foregrounds over one background if the alternate
background equals the normal one. `R#13` sets the timing: the high nibble is
the time shown in the `R#12` colours, the low nibble the time shown in the
`R#7` colours, so for instance `$88` makes flagged cells blink slowly (see the
poke command below). `R#13` is global for all screens.

Flags are only maintained inside areas and overlays whose left edge and width
are multiples of 8 columns. Elsewhere `1F 24` sets nothing, and scrolling,
inserting or deleting lines drops the flags of the rows involved (printing and
erasing always work exactly). 40 columns has no blink table, so there `1F 24`
has no effect.

## GetStat / SetStat

* `SS.ScSiz`: the working area's size. `SS.Cursr`: cursor position and the
  character under it.
* `SS.Open` marks the device selectable by CLEAR and sets the page-pause
  length. `SS.ComSt` (`xmode`, `tmode`) is accepted and ignored: these screens
  always have true lower case.

## Private commands (not in the manual)

Parameters are raw bytes, without `+$20`.

| Sequence | Effect |
|---|---|
| `1B 28 n` | `n` <> 0: CWArea clears the whole window (the default). `n` = 0: it leaves all the text as it is. Per screen. |
| `1B 3E RR VV` | Write VDP register `RR` := `VV`. A wrong value can blank the display; CLEAR to another screen and back rewrites `R#2`, `R#3`, `R#7`, `R#10`, `R#12`. |
| `1B 3B HH LL VV` | Write VRAM byte `$HHLL` := `VV` (lower 64K). |
| `1B 38 HH LL` | Print the VRAM byte at `$HHLL` in hex at the cursor. |
| `1B 37` | Print five state bytes of the screen in hex: alternate flag, flag table in use, columns, page, reverse. |

For example `display 1b 3e 0d 88 >/V1` makes the flagged characters blink, and
`display 1b 3e 0d f0 >/V1` makes them steady again.

## Limits

* One geometry (40 or 80 columns) for all screens: the VDP has one mode.
* No graphics on these screens, and no underline.
* Overlays use their parent's colours; they cannot have colours of their own.
* Up to 8 screens (`/Term`, `/V1` ... `/V7`), limited by the 8 KB per screen
  assumed for the save area in the upper 64K of a 128 KB VRAM.
* Not for `HIRES` builds.

## Notes for maintainers

* The statics of a V9958 screen live in unused fields of CoVDG's `VD.*` area
  (`VD.Palet`, `VD.HR2`, ...), see the aliases at the top of `ssfm.asm`.
* `V.PORT` is read at `Init` to get the screen number (the descriptor's
  address, `$FFC0` + n); VTIO replaces it with the device-table pointer at
  `SS.Open`.
* Most of the text routines were tested in a small 6809 interpreter against a
  reference model of the screen (random sequences of printing, erasing,
  scrolling, inserting, areas and overlays), and then on the real hardware.
* lwasm treats symbols case-insensitively here: labels must not differ only in
  case.
