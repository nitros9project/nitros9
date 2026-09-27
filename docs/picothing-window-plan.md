# Pico-Thing `/W` multi-window implementation plan

Multiple `CLEAR`-switched shells on the video display via `/W1`../`/W7` window
devices, per the settled M5 device model. This is the NitrOS-9 (6809) side; the
video pico does the rendering.

## Key insight: reuse `vtio`'s structure, not its renderer

NitrOS-9's CoCo3 windowing already solves "N window devices sharing global
state": `vtio` + a shared global block reached via `D.CCMem`, per-descriptor
window numbers, and per-window static. The co-module was deferred because
*rendering* is firmware-side — that stays deferred. But the *device-management*
half of `vtio` (`/W` descriptors, the shared global, one input path routed to
the focused window) is exactly what multi-window needs. So this is "vtio-lite":
adopt the shared-global skeleton, pipe protocol bytes instead of rasterising.

## Firmware contract (settled, both sides agreed)

Window sub-codes, all guest-issued through the transparent `/W` byte pipe:

- `$20 DWSet id,type,x,y,sx,sy,fg,bg` — define window `id` (char-grid units);
  clamped to the panel; **does not display**. Only `id,x,y,sx,sy` are acted on.
- `$21 Select id` — **output target only**. Subsequent text lands in window
  `id`'s buffer (parked in PSRAM if `id` is not the displayed window). No park,
  no restore, nothing on screen moves. Safe before every write burst.
- `$26 DWShow id` — **visibility only**. Makes `id` the on-screen window; the
  park/restore happens here. This is what `CLEAR`-switching emits.
- `$24 DWEnd` — close the target window; falls back to root if it was displayed.
- `id 0` = root = the physical panel.
- The cursor follows the **displayed** window, not the write target — so writing
  to a background window does not drag the visible cursor (no cursor save/restore
  needed around background writes).
- Geometry read-back: `VID.Info` ($FF13) reports the current window's 6-byte
  block (width/height px, text cols/rows); `SS.ScSiz` answers from it.
- Keyboard is one untagged 256-byte FIFO with no window awareness — whatever
  reads `VID.Data` gets the next key. Input routing is entirely the guest's.

## Components

### 1. Descriptors `/W1`../`/W7` (+ base `/V0`)
SCF descriptors in the `vconw` family, each carrying a **window-number byte**
(as CoCo3's `w1.asm` does) plus size. Built from **one shared source**
parameterised by window number (the `ptidedesc.asm` `-D` pattern). `/V0` stays
the base console (window 0 / root).

### 2. Driver `vconw` (new; plain `vcon` stays the simple base/fallback)
- **Shared global** via `D.CCMem` (allocated by the first Init with `F$SRqMem`):
  the last-selected window (for redundant-`Select` suppression), and later the
  input ring + focus pointer + the single `VID.Stat` poll registration.
- **Per-descriptor static**: this path's window number.
- **Write = output targeting**: emit `Select <this window's id>` before the
  path's bytes, suppressed when unchanged from the global's last-selected. Because
  `Select` is output-target-only, background writes accumulate off-screen with no
  flicker.
- **Read = input routing (Phase 2)**: read from the shared ring only if this
  window is focused, else nap until focus arrives. The single poll drains
  `VID.Data` and signals the focused window's waiting reader. This is also the
  lock fix — reads route through the shared global rather than holding a
  per-device lock during the wait, and each `/W` has its own static, so a blocked
  background shell never blocks another window's writes.

### 3. Focus / `CLEAR`-switching (Phase 2)
The input drainer intercepts `CLEAR`, advances focus to the next defined window,
emits `$26 DWShow`, and updates the global focus pointer so input follows.
Driver-handled, like CoCo3 — no separate window-manager program for basic
switching.

## Phasing (each independently testable in usim)

- **Phase 1 — output-only.** `/W1`../`/W7` + `Select`-per-write + shared
  last-selected. No input routing yet (Read returns `E$NotRdy`). Test: write to
  `/W1` and `/W2`, `DWShow`-switch between them, confirm each accumulates its own
  output off-screen and switching brings it up. Proves output + the split +
  park/unpark.
- **Phase 2 — shared input + focus.** One drainer, focus pointer, keyboard →
  focused window, `CLEAR` cycles focus. Test: `tsmon /w1 &` + `tsmon /w2 &`, log
  in on each, `CLEAR`-switch, type into each; confirm input follows focus,
  background reads block, **no device-lock hang**.
- **Phase 3 — polish.** Base-console integration, the `tsmon /wN &` startup lines
  (now safe), redundant-`Select` suppression edge cases.

## Decisions (settled)
1. **Base console:** keep `/V0` as the base/root.
2. **`D.CCMem`:** reuse it for the Pico-Thing window global (verified free on
   Pico-Thing before relying on it).
3. **New `vconw`** driver — keeps the proven simple `vcon` intact as base/fallback.

## Dependencies & non-scope
- **Needs:** `$26 DWShow` (LANDED, firmware `94925c1`) and background-write-to-
  parked-PSRAM (landed with the split).
- **Not in scope:** rendering (firmware, done), overlays (deferred, no
  save-under), per-window graphics (one global plane).

## `tsmon` resolution
Once Phase 2's per-descriptor locks land, `tsmon /w1 &`, `tsmon /w2 &` give logins
per window with no concurrent-write hang — the original `tsmon /v0 &` request,
satisfied properly. Until then it stays out of `startup` (it would trap the test
commands under the current single-device `vcon`).

## Testing
- Extend `wintest` into a multi-window test (define `/W1`,`/W2`, write to each,
  `DWShow`-switch).
- usim screenshot per phase; input-routing checks in Phase 2.
- Hardware: log in on `/W1`,`/W2`, `CLEAR`-switch.
