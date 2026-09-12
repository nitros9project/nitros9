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

## The burst is masked again (2026-09-12)

Field result of the second cut on the K2: frequent #244s. The trim had read the data burst with
interrupts open, trusting the 64-byte RX FIFO (2.8 ms at 230400) to ride out any handler; a handler
that runs longer than that in the 11 ms of a 256-byte leg loses bytes, and a lost byte is a #244
plus a resync. `DWRead` now masks from the first byte of a leg to its end, as `wb/drivewire_hardening`
read the whole leg, and keeps the trim only where it earns its keep: the WAIT for a late byte still
opens interrupts after `DW_MASKED` polls, so a stalled server costs the caller time, never the
machine its keyboard. Timeouts, purge, `PurgeRX`, `AbWait` and the poll state machine are unchanged.

## Interrupt trim and the poll state machine (2026-09-07, wb/DriveWireCompatible)

**Why.** With the hardening in place every sector transaction still ran from its first byte to
its exit with IRQ and FIRQ masked, including every wait for a stalled server: up to 2.7 s in
`DWRead`, 1.3 s in `PurgeRX`, 6 s in `AbWait`, times eight retries. Worse, `dwio`'s server poll
for virtual-serial data ran a blocking transaction *inside the clock interrupt* every 3, 6 or 40
ticks. Both machines showed the effect as a keyboard that stopped responding for seconds at a
time. The interrupt investigation of 2026-09-07 found the kernel offers no protection either: on
wildbits an interrupt that lands while a driver runs in system state is serviced by `FastIRQ`
with no task switch, so nothing but interrupt time is lost when a driver waits with interrupts on.

**Link arbitration.** The UART is shared between the tick poll and process-side transactions, so
the two must never interleave bytes. `DW.LinkBusy` in the DriveWire statics page is the lock:

- A process transaction takes the link with the new `DW$Settle` entry (offset 12 of `dwio`):
  it marks the link busy, and if the tick poll still has a response owed it collects that
  response first (sleeping a tick between looks, interrupts on), so the first byte the
  transaction reads is really its own. A server that never answers costs `SETTLE_TRIES` ticks
  once, then the line is reset and the poll backs off.
- `rbdw` calls it as `LinkGet` at the start of Read, Write, GetStat/SetStat and the OP_INIT of
  Init, and clears the flag (`LinkPut`) at every exit. Other callers of the link routines
  (`rfm`, `clock2_dw`) are not in the wildbits boot list and were left alone.
- The tick handler returns at once while the flag is set.

**The trim.** With the lock in place `rbdw` no longer masks interrupts around a transaction.
`DWRead` waits for the *first* byte of each leg with the caller's interrupts on and masks from
that byte to the end of the leg (a 256-byte sector burst is 11 ms at 230400; the 16-byte RX
FIFO cannot absorb an interrupt in the middle of it). The timeout purge inside `DWRead`,
`PurgeRX`, `AbWait` and the trailing-byte check all run with interrupts on. `DWWrite` never masks:
the server does not care about gaps between the bytes it receives.

**The poll state machine.** `IRQSvc` never waits for the server now. A firing either sends
OP_SERREAD (state 1, two bytes owed) or collects the owed response with `PollGet` (a short
bounded look per byte; the bytes of one response arrive 43 us apart) and, once it is complete,
processes it through the original handler (`PollProc`) and sends the next request, so the poll
cadence is unchanged. A response that has not arrived stays owed; after `POLL_STALL` firings
the line is reset (`PollPurge`: RX FIFO reset strobe, short drain) and the poll skips
`POLL_HOLD` firings. A multi-read (OP_SERREADM) is capped at `POLL_MAXGRAB` = 16 bytes, the RX
FIFO depth, and its bytes are collected at the next firing as well (`PollDoneM` finishes the
buffer bookkeeping); virtual-serial bulk throughput is therefore bounded by 16 bytes per poll
interval, which no wildbits boot list uses today.

**Module fingerprints** (os9 ident): `dwio_serial` 1202 bytes CRC $D8EDBD, `rbdw` 640 bytes CRC $5AA640 (this branch, uncommitted 2026-09-07 evening); the hardening-only modules were `rbdw` $252 (size) as listed above.

### Bench correction, same evening: the FIFO was never on

Typing during `dir /x3` broke the transaction in flight (a #244 after the timeout, the typed keys
delivered afterwards). The UART core (`uart_16750.vhd`) treats FCR bit 0 as the FIFO enable, and every
FCR write in the DriveWire path had it clear, so the link had been running on a **one-byte** receive
register; the fully-masked transactions read each byte within microseconds and never noticed. With
interrupts on during a wait, a keystroke handler (a few hundred microseconds) or the clock tick
landing as a response started lost bytes. Fixes: `dwinit` now enables the FIFOs in 64-byte mode
inside the DLAB window (2.8 ms of tolerance), the two purge strobes keep bit 0 set, and `DWRead`
waits masked for the first `DW_MASKED` polls (~10 ms) of every leg, taking the caller's interrupt
state only when the server is slow. A prompt server is therefore read exactly as before the trim;
only a stalled one hands the machine its interrupts back.

**Second cut, later the same evening.** With the 64-byte FIFO proven on the bench, the sector burst is
now read with interrupts on as well: `DWRead` masks only the first `DW_MASKED` = 512 polls (~3 ms) of the
wait for a leg's first byte, and from that byte on every wait and every read runs with the caller's
interrupts. Nothing in the link masks for longer than about 3 ms at a stretch; a sustained transfer is
masked roughly a tenth of the time. The FIFO's 2.8 ms of cover exceeds any handler on either machine.
