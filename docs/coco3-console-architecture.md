# The CoCo3 OS-9 Level 2 console: how it hangs together

How the windowing console is assembled from OS-9 modules, and how a shell's
window relates to text and graphics modes. Companion to
[copico-video-protocol.md](copico-video-protocol.md) — that documents the
display-code protocol; this documents the machinery that carries it.

## 1. The module stack

Everything is a **character device** under OS-9's SCF (Sequential Character File
manager). A program never touches video hardware; it opens a path and reads and
writes bytes. The stack from application to silicon:

```
  shell / Basic09 GFX2 / any program
        │  (I$Write / I$Read / I$GetStt on a path)
        ▼
  IOMan            I/O manager — routes the syscall to the file manager
        ▼
  SCF              the character-device file manager (line editing, echo, ...)
        ▼
  VTIO             the ONE SCF driver all console windows share
        │  splits the byte stream:
        │    • text + control codes → the screen-type co-module
        │    • $1B graphics commands → the graphics co-module
        │    • input (keys/mouse/joy) ← keydrv/joydrv, buffered by the ISR
        ▼
  co-modules       per-screen-type renderers, called by VTIO:
                     CoVDG (VDG 32-col text), CoWin/CoGrf (graphics windows),
                     plus CoWP/CoHR/Co42/Co80/CoVGA/CoDPlus for add-on text HW
        ▼
  GrfDrv           the shared graphics engine (loaded once on first graphics
                   window); does the actual GIME programming + bitmap drawing
        ▼
  GIME             the hardware: video RAM, palette, scan-out
```

Two supporting subroutine modules hang off VTIO for input/sound: **keydrv**
(keyboard), **joydrv** (joystick/mouse), **snddrv** (sound) — entries kept in
VTIO's global area (`G.KeyEnt`/`G.JoyEnt`/`G.SndEnt`).

## 2. Devices, windows, and screens — three different things

- **Device descriptor** — an OS-9 module naming a window path: `/TERM`, `/W`,
  `/W1`…`/W15`. It's a normal SCF descriptor (`term_win80.asm`, `w1.asm`, …)
  whose tail carries window parameters: screen type (`sty`), size (`szx`×`szy`),
  cursor start, and foreground/background/border colours. `/TERM` is the boot
  console (80×24, type 2). `/W` has window number `$FF` = "grab the next free
  window" (dynamic); `/W1`…`/W15` are fixed-number windows.

- **Window** — a live region you draw into. VTIO keeps up to **32 window tables**
  (`$40` bytes each), `Wt.*` fields: which screen it's on (`Wt.STbl`), overlay
  parent (`Wt.BLnk`, `$FF` = base window), position, size, cursor, scaling.

- **Screen** — a physical display surface (a chunk of video RAM in a GIME mode).
  VTIO keeps up to **16 screen tables** (`$20` bytes each), `St.*` fields incl.
  `St.Sty` (screen type). **The GIME shows one screen at a time.**

The relationships:

```
  descriptor  ──opens──▶  window  ──lives on──▶  screen  ──one visible──▶ GIME
   /TERM,/W..              (≤32)                  (≤16)
```

- A **base device window** owns a screen (created by `DWSet`).
- An **overlay window** (`OWSet`) shares its parent's screen — it's a
  sub-rectangle drawn into the same bitmap, saving/restoring what it covers.
- Several base windows = several screens; **CLEAR / SHIFT-CLEAR cycles which
  screen the GIME displays** (next/previous), so windows behave like Unix
  virtual terminals. Input routes to whichever window is active.

## 3. Window *type* vs screen *type* — the key to text vs graphics

Two independent "type" ideas, and the graphics story lives in the gap between
them:

- **Window type** (`V.WinType`) selects the **co-module** that renders the
  window: `0` = WindInt/GrfInt (graphics, via CoWin/CoGrf), `2` = VDGInt (VDG
  text, via CoVDG). VTIO indexes its co-module table (`G.CoTble`) by this.

- **Screen type** (`St.Sty`, the descriptor's `sty`) selects the **GIME video
  mode**. In grfdrv these split by the high bit: **high bit set = hardware
  text** (GIME character mode — no pixel access), **high bit clear = graphics
  bitmap** (40/80-wide × 2/4/16 colours).

So a window is either:

- **Hardware-text** — GIME renders characters from a text buffer. Fast, low RAM,
  but **no pixels**: you cannot draw graphics here.
- **Graphics bitmap** — a pixel buffer. GrfDrv rasterises everything into it.

## 4. How a shell window interacts with graphics modes

This is the crux. **The shell never knows or cares what mode its window is in.**
It only writes characters to its path. What happens to them depends on the
window's screen type:

- On a **hardware-text window**, VTIO → CoVDG (or a hardware-text co-module) puts
  the character into the GIME text buffer. Graphics `$1B` commands are
  meaningless here (no bitmap) and are rejected/ignored.

- On a **graphics window**, VTIO → CoWin/CoGrf → **GrfDrv rasterises each shell
  character into the bitmap as a little font glyph**, and GFX2's `$1B` drawing
  commands draw into the *same* bitmap. **Text and graphics therefore coexist in
  one window** — the shell prompt and a `RUN GFX2(...,"LINE",...)` share the
  pixels. This is why a CoCo3 graphics screen shows both a shell and drawings at
  once.

Consequences you actually feel:

- **To mix shell text and graphics, the window must be a graphics-type screen.**
  A `/W` window whose descriptor `sty` is a graphics type gives you both; a
  hardware-text `/TERM` gives you fast text but no drawing.
- **Switching a window's mode** = `DWEnd` (tear the window down) then `DWSet`
  with a new screen type. The path stays open; the surface underneath changes.
  (MultiVue and interactive programs do exactly this.)
- **Fonts, colours, cursor** on a graphics window are all GrfDrv's doing — the
  "text" is really graphics, so `Font`, `FColor`, `Bold`, proportional spacing,
  etc. all apply to shell text too.

## 5. How a shell gets a window in the first place

1. Boot: **init** forks **sysgo**, which forks the first **shell** with its
   standard paths on `/TERM` (the 80×24 boot console). That window/screen is
   created when `/TERM` is first opened.
2. **GrfDrv is loaded on demand** — the first time a *graphics* window is opened,
   CoWin `F$Load`s `grfdrv` (from `../CMDS/grfdrv`) and caches its entry in
   `G.GrfEnt`. Text-only boots never pay for it.
3. Extra logins/windows: **TSMon** watches `/W`-type devices; opening one (or a
   program opening `/W`) grabs a fresh window+screen, and login forks a shell
   onto it. That's how you get multiple shells on CLEAR-switchable screens.
4. A program can `I$Open` `/W` itself to claim a scratch graphics window, draw,
   and close it.

## 6. Mapping to Pico-Thing (why this matters here)

The Pico-Thing port keeps the **top** of this stack and moves the **bottom**
across the link:

| CoCo3 | Pico-Thing |
|-------|------------|
| IOMan / SCF | unchanged |
| VTIO | `vtio_picothing` (thin: framing + input buffer) |
| CoVDG / CoWin / CoGrf | `copico` (one co-module; text + `$1B` both marshalled) |
| GrfDrv (rasteriser on the 6809) | **the Video Pico** (rasteriser across the link) |
| GIME video RAM | the Video Pico's framebuffer |
| keydrv/joydrv (PIA scan) | input frames the Video Pico pushes over the UART |

Design implications that follow directly from this architecture:

- **Window and screen tables stay 6809-side** (they're OS-9 state — paths,
  processes, CLEAR-switching, overlays). The Pico is only a renderer. That's the
  "cooked primitives, OS-9 owns window state" decision, and it's *why* it's the
  right one: windows/screens are an OS-9 abstraction, not a hardware one.
- **The text/graphics split becomes a policy choice, not a hardware limit.** On
  CoCo3, hardware-text vs bitmap is a GIME mode. On Pico-Thing every window can
  be a graphics surface (the Video Pico always has a framebuffer), so shell text
  and GFX2 can coexist in *every* window — the hardware-text-only case simply
  goes away.
- **`copico` is one co-module doing what CoVDG + CoWin/CoGrf did** — because the
  Video Pico renders both text glyphs and graphics, there's no need for separate
  text/graphics co-modules per screen type.
- **Screen switching (CLEAR)** still lives in `vtio_picothing`: it tells the
  Video Pico which screen to scan out (a `Select`-style message), exactly as VTIO
  repoints the GIME today.
