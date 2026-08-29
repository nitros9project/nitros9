# WildBits DriveWire Serial Driver Hardening

**Dates:** 2026-08-28 / 2026-08-29
**Files changed:**
- `level1/wildbits/modules/dwinit_wildbits_serial.asm` (baud divisor)
- `level1/wildbits/modules/dwread_wildbits_serial.asm` (timeout purge)
- `level1/wildbits/modules/dwwrite_wildbits_serial.asm` (bounded TX wait)
- `level1/modules/rbdw.asm` (protocol completion + error-path resync,
  all additions `ifne wildbits` so other ports assemble byte-identical)

## Background

DriveWire on the K2 had a long-standing failure pattern under sustained
`/x1` traffic: successful transfers, then an error #244 (`E$Read`),
then cascades of strange errors (#214, #216, #254) ending in a machine
frozen at the shell. The campaign found one root cause in the FPGA core
and a chain of structural weaknesses in the driver stack. Each fix was
validated against DriveWire 4 server logs captured in the field; each
subsequent log exposed the next layer.

## Root cause 1 (FPGA core, fixed in v8_rc3): UART baud error

The UART's baud generator ran from the raw 25.175MHz clock, where no
divisor lands on a standard rate: the closest speed to 230,400 was
**224,777 baud (-2.4%)** — just inside 8N1 tolerance, so links worked
until sustained traffic found the margin. The v8_rc3 cores add a
fractional clock-enable running the baud generator at exactly
22.1184MHz, making standard rates exact. The paired driver change is
`dwinit` writing divisor **5** (= 230,400 exactly) instead of 6.
Core and disk deploy as a pair; either half alone leaves the UART at a
dead rate. Field result: frequent crash-under-load became a rare,
occasional #244 — which exposed everything below.

## Root cause 2 (driver): DWWrite could hang the machine forever

`DWWrite` waited on the transmitter-empty flag with no timeout, inside
an interrupt-masked section — the driver's only true infinite-spin
path. **Fix:** the drain wait is bounded (~65k polls per byte); a
wedged transmitter now abandons the packet and surfaces as an ordinary
error with interrupts restored.

## Root cause 3 (protocol): aborting a read desynced the SERVER

On a failed sector read the stock driver jumps to its error exit
without sending the 2-byte checksum the server is still blocked
waiting for. The server then consumes the next command's first bytes
as "the checksum" — server-side frame slip, visible in the DW4 log as
`UNKNOWN OPCODE` warnings and requests for garbage LSNs.
**Fix (`ReadAbort`):** on any failed read, send a deliberately-wrong
checksum and collect the status byte before erroring out, so both
parsers stay framed. Field-verified: `UNKNOWN OPCODE` disappeared from
subsequent failure logs.

## Root cause 4 (driver): an off-by-N stream never resyncs itself

A byte lost mid-sector leaves every later transfer shifted: reads
complete *promptly* with wrong data, so a timeout-based purge never
fires, every checksum fails at the server, and the "status byte" the
client reads is actually a shifted data byte — which the stock driver
returned verbatim as the error code. That is where the mystery #214 /
#216 / #254 reports came from.
**Fixes:** a receive purge (`PurgeRX`) runs on **every** failed
transaction, not only timeouts; and a status byte that is neither OK
nor E$CRC is treated as proof of desync (purge + honest #244) instead
of being passed through as an error number.

## Root cause 5 (server-side stalls): the late sector remainder

The remaining field failure had a distinct signature: the server log
shows `OP_READEX took ~620ms` — a Java GC / scheduler stall in the DW4
server mid-sector. The client times out, aborts cleanly, purges — and
finds a silent line, *because the server is still stalled*. The server
then wakes and transmits the rest of the sector into a client that has
stopped listening: 16 bytes land in the RX FIFO, the rest overrun, and
(in this 16750 core) the overrun can wedge FIFO pointer state in a way
that byte-draining never clears. Every later transfer arrives corrupt;
RBF's directory searches read garbage (#216 Path Not Found on
subsequent files); the OS descends into an unbounded retry storm that
presents as a freeze (interrupts are masked for nearly the whole duty
cycle while the DW4 log keeps scrolling).
**Fixes (2026-08-29, current build):**
- `PurgeRX` now strobes the UART's **FCR RX-FIFO hardware reset** on
  entry, clearing any overrun-wedged FIFO state.
- The purge idle window was stretched from ~0.6ms to **~200-350ms**,
  long enough to outlast a server stall and consume the late-arriving
  sector remainder in real time before declaring the line clean.

## Root cause 6 (driver): the retry loop SUSTAINED a lagged stream

The decisive field log (2026-08-29 13:14, first error #216 then lockup)
showed the post-stall end-state exactly: every read *completes* — the
server always receives a full checksum and answers — yet every checksum
fails, forever, with sane opcodes and no timeouts. That is a client
running **one response behind**: a whole stale response (256 bytes +
status) queued ahead in the stream. Each read consumes the *previous*
transaction's data, fails the server CRC, gets E$CRC — and the E$CRC
retry path went straight back to OP_REREADEX **without purging**, so
the retry re-read the stale response and the desync sustained itself
through all retries, then through RBF's retries: the freeze. Worse, a
stale status of $00 was *accepted with wrong sector data* — the source
of the #216 (directory search over garbage) and the LSN 0/65537
retry-storm targets (corrupted drive table).
**Fixes (2026-08-29, current build):**
- **Purge before every retry**: the E$CRC/REREADEX path now runs
  PurgeRX first, so a retry always reads fresh, aligned data — a
  lagged stream self-heals in one retry instead of freezing.
- **Trailing-byte check on status OK**: on a synced line the server
  sends *nothing* after the status byte. If a byte trails it (watched
  ~200µs; a lagged flowing stream delivers the next byte within ~43µs
  at 230400), the "OK" belonged to the previous transaction — the read
  is retried instead of silently accepting wrong data.
- **Abort long-listen**: when an aborted read's status never arrives
  (server deep in a stall), the driver now listens up to ~2s for the
  late burst to start before declaring the line clean, so a stall
  longer than the purge window can no longer establish the lag. A
  status-read timeout after the checksum leg takes the same path.

## What was audited and deliberately not changed

- `rbdw` retries only server-reported CRC failures (8 `OP_REREADEX`
  attempts); serial-level timeouts fail immediately — unchanged.
- Every exit path in the driver stack restores the caller's interrupt
  mask from the stack; no error exit leaves IRQs masked.
- The SHELLMODS merge order and the DriveWire modules' presence in the
  boot list are recipe-level changes documented separately.

## Expected behavior after the current build

- A server stall or line glitch costs **one** #244 (~1s of masked
  time), after which the very next operation succeeds.
- No error-code roulette (#214/#216/#254), no cascades, no freeze.
- Optional future polish: 64-byte FIFO mode in DWInit (widens the
  interrupt-window overrun margin from ~700µs to ~2.8ms); reducing DW4
  JVM pauses server-side (more heap / low-pause GC) shrinks how often
  the stall path is exercised at all.

## Field validation (2026-08-29, rbdw $252)

A 2-hour K2 dsave marathon over /x1 (14.7MB of DW4 server log): the
server stalled 8 times (224-641ms, Java GC). Seven stalls were
absorbed **invisibly** — the driver aborted cleanly, resynced, and
RBF never saw an error. One surfaced as a single #244 on one file;
the next command succeeded immediately, and the affected file was
verified intact at the destination (`cmp` match). Zero UNKNOWN
OPCODEs, zero error cascades, zero freezes. Each stall leaves exactly
two WARN lines in the server log (the deliberate abort checksum's
"CRC check failed" + the stall duration) — that is the expected,
healthy signature.

## Deployment pairing

Disks built from this branch require the BAUDCE-fixed cores. Minimum:
`wildbits_k2_6809_v8_rc3` / `wildbits_jr2_6809_v8_rc3` (2026-08-28, the
fractional-BAUDCE fix in `SuperIO_JR.v`). Driver hardening itself has no
core dependency beyond that baud pairing.

**Current cores (2026-09-03): `wildbits_k2_6809_v8_rc10` and
`wildbits_jr2_6809_v8_rc7`.** Both carry the sprite-engine fixes (rc7); the K2
adds the hardware typematic engine (rc8), the shared flash/cartridge/RTC
write-strobe policy (rc9) and 24-tick turbo fast RAM writes (rc10). The Jr2
has had the write-strobe policy since rc6 and needs no rc8/rc9 counterpart.

Core and disk ship together in the parity kits
(`FoenixMgrWin/parity_wildbits_k2_v8_rc10`, `parity_wildbits_jr2_v8_rc7`):
each kit holds that machine's core, the matching `l2_wildbits*.dsk`, the FEU
booter/f0 blocks and the install script, so a kit is always a consistent
pair. Mixing a kit disk with an older core, or an older disk with a newer
core, reintroduces the 2.4% baud mismatch described above.

Module fingerprints for `mdir -e` verification: `dwio_serial` = $37A,
`rbdw` = $252 (current: retry purge + trailing-byte check + abort
long-listen), $211 (FIFO reset + long purge), $20C (no FIFO reset),
$1E6 (abort only), $1CF (stock).
