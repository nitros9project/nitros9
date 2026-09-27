# Smart-Pico high-level window commands

The management command set for the "smart Video Pico" model, where the Pico owns
window geometry and compositing (not just rasterising). This sits *above* the
draw primitives in [copico-video-protocol.md](copico-video-protocol.md): those
draw pixels; these create, place, show, and stack the surfaces the pixels land
on. Architecture context: [coco3-console-architecture.md](coco3-console-architecture.md).

## The Pico's display model

Fixed by the hardware:

- **One display, fixed resolution.** No mode switches ever. Every "mode" is a
  *region* of this one display.
- **One global graphics plane** — a single framebuffer at the display resolution,
  the bottom layer. All graphics drawing (the `$1B` primitives) lands here.
- **Many text screenbuffers** — independent character grids, each a floating
  layer *above* the graphics plane. Multiple can exist; visibility and stacking
  are controlled per screen.
- **Compositor order is fixed: graphics plane at the bottom, text screens on top**
  (by z-order). A text screen's cell background is either **opaque** (hides the
  graphics under it) or **transparent** (the graphics plane shows through, only
  glyph pixels are drawn). Transparency is how "text over graphics" — a shell on
  a graphics window — works.

Consequences to keep in mind:

- **Graphics is global and singular.** Switching between text screens does *not*
  change the graphics plane; it persists underneath. To blank graphics, clear the
  plane or cover it with an opaque text screen.
- **A CoCo3 "graphics window"** (shell text *and* GFX2 in one window) becomes a
  transparent-background text screen positioned over a graphics region at the same
  rectangle — bound together by `copico`.
- **Compatibility "modes" are geometry, not modes.** A VDG 32×16 window is a text
  screen of 32×16 cells at a chosen cell size in a sub-rectangle; an 80-column
  window is 80×24 small cells full width; a 320×192 graphics mode is a graphics
  region of that pixel size (scaled/placed by the Pico). The resolution never
  changes — `copico`/OS-9 turns each CoCo3 "screen type" into a geometry preset
  and issues the commands below.

## Object model

| Object | Count | Owner | Key attributes |
|--------|-------|-------|----------------|
| Graphics plane | 1 (global) | Pico | the framebuffer; a "current region" for clipped drawing |
| Text screen | many | Pico | id, grid (cols×rows), cell size, origin, colours, bg mode, z, visible, focus |
| Compositor | 1 | Pico | graphics plane then visible text screens by z |
| Window ↔ path ↔ process binding | — | **OS-9 (6809)** | which text-screen id / graphics region a path uses; which process owns it |

The last row is the line that never moves: the Pico owns geometry and pixels;
OS-9 owns which process a surface belongs to and where its input goes.

## Wire format

Management frames use a distinct opcode range so the Pico's link handler can tell
them from draw sub-codes and text bytes:

- `$20`–`$55` — draw primitives (the protocol doc), act on the current graphics region
- `$80`–`$8F` — text-screen management
- `$90`–`$9F` — graphics-plane / region management
- `$A0`–`$AF` — compositor / display
- other bytes — text/control characters for the current target text screen

Coordinates and sizes are 16-bit big-endian (as in the protocol doc); ids, cols,
rows, cell sizes, z, colours and flags are one byte each.

## A. Text-screen management (`$80`–`$8F`)

| Op | Name | Params | Pico action |
|----|------|--------|-------------|
| `80` | TNew | id, cols, rows, cellW, cellH, originX(2), originY(2), bgMode, fg, bg | Create/configure a text screen: a `cols×rows` grid of `cellW×cellH` cells at `origin` on the display. `bgMode` 0 = opaque (fill bg), 1 = transparent (graphics shows through cell backgrounds). |
| `81` | TFree | id | Destroy the text screen and free its buffer. |
| `82` | TShow | id, z | Make it visible at stacking order `z` (higher = nearer the top). |
| `83` | THide | id | Hide it (buffer kept). |
| `84` | TFocus | id | Direct keyboard input to this screen (input focus). |
| `85` | TMove | id, originX(2), originY(2) | Reposition on the display (overlays, panels). |
| `86` | TResize | id, cols, rows, cellW, cellH | Change grid/cell size in place. |
| `87` | TClear | id | Clear the grid to its background. |
| `88` | TTarget | id | Route subsequent text/attribute writes to this screen (set current target). |

## B. Graphics-plane / region management (`$90`–`$9F`)

There is one plane; a "graphics window" is a *region* of it so several can share
the plane without colliding.

| Op | Name | Params | Pico action |
|----|------|--------|-------------|
| `90` | GRegion | originX(2), originY(2), width(2), height(2) | Set the current graphics window: subsequent `$20`–`$55` draw primitives are clipped to, and addressed relative to, this rectangle. |
| `91` | GReset | — | Reset the current region to the whole graphics plane. |
| `92` | GClear | — | Clear the current region (to background / transparent). |
| `93` | GScale | mode | How coordinates map to the region (1:1 pixels, or scaled so a compat resolution like 320×192 fills the region). |

## C. Compositor / display (`$A0`–`$AF`)

| Op | Name | Params | Pico action |
|----|------|--------|-------------|
| `A0` | Present | — | (Optional) flip/refresh if double-buffered; no-op if the Pico composites continuously. |
| `A1` | Background | colour | Set the fill shown where nothing is drawn (below the graphics plane). |

Compositing itself is implicit and always the same: graphics plane, then each
visible text screen in ascending `z`, glyphs over transparent-or-opaque cells.

## Input, focus, and CLEAR

The Pico *supplies* keyboard and mouse and pushes events to the 6809 as tagged
UART frames (per the GetStat channel spec): `key`, `mouse` (x,y,buttons),
`joystick`, `query-reply`.

- **Focus is OS-9's decision, not the Pico's.** The Pico reports raw input; the
  6809 routes a keystroke to the process owning the focused window and issues
  `TFocus` when it changes focus. This keeps process/signal ownership on the 6809.
- **CLEAR / SHIFT-CLEAR** arrive as ordinary key events. The 6809 picks the
  next/previous window and issues `TShow`/`THide`/`TFocus` — the Pico does not
  cycle screens on its own (it can't know the OS-9 window order or which are
  logged in).
- **Mouse** coordinates are display-space; the 6809 maps them to the window under
  the cursor (or the focused window) and delivers `SS.Mouse`.

## Mapping: CoCo3 window ops → smart-Pico commands

This is `copico`'s job — translate the display-code window operations it receives
into these management commands:

| CoCo3 op (from the byte stream) | Smart-Pico command(s) |
|---|---|
| `DWSet`, text type | `TNew` (geometry from the type preset) + `TShow` + `TFocus` |
| `DWSet`, graphics type | `GRegion` for the window's rectangle (+ a transparent `TNew` if it also carries a shell) |
| `Select` | `TFocus(id)` + raise `TShow` z |
| `OWSet` (overlay) | `TNew` a smaller screen at the overlay rect, higher z (text overlay); or a sub-`GRegion` (graphics overlay) |
| `OWEnd` | `TFree` the overlay screen (its buffer restore is automatic — the layer below is intact) |
| `DWEnd` | `TFree` (text) / release the region (graphics) |
| `CWArea` | `TResize` / adjust `GRegion` |
| `FColor`/`BColor`/`Border`/`Palette` | forwarded; apply to the target text screen or the graphics plane |
| text + control bytes | `TTarget(id)` when the active window changes, then the bytes to that screen |
| `$1B` draw primitives | `GRegion(id's rect)` when the active graphics window changes, then the primitives |

`copico` sends `TTarget`/`GRegion` only when the active window changes (tracked
against `G.CurDev`), so steady-state output is just the bytes — no per-write
overhead.

## What each side owns (the invariant)

- **Pico owns:** the framebuffer, all text screenbuffers, cell/font rendering,
  palette, cursor drawing, clipping, stacking, compositing, and the physical
  keyboard/mouse.
- **OS-9 (6809) owns:** paths and the SCF cooking on them (echo, line edit,
  EOF/interrupt/quit, pause), the window ↔ path ↔ process binding, focus policy
  (issuing `TFocus`), input routing and signals, and turning CoCo3 screen types
  into geometry.

Overlay save/restore, screen switching pixels, and per-mode rendering — the bulk
of the old `cowin`/`grfdrv` — are gone from the 6809 entirely; they become
`TShow`/`THide`/`TFree` and the Pico's compositor.
