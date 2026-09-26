# K2 RP2040 mailbox commands

Requires the K2 rc18 mailbox core and compatible RP2040 manager firmware 1.x (tested protocol model: 1.16). Jr2 has no onboard supervisor; its bootfile does not include these modules.

K2 Level 1 and Level 2 builds include `RPDrv` and descriptor `rp` in OS9Boot, with `fpga` in CMDS. Both levels use the shared sources in `level1/wildbits/modules` and `level1/wildbits/cmds`. No `iniz` is required before using the command. The boot-resident driver does not access the hardware until `/rp` is opened.

```
fpga
fpga status
fpga log
fpga list
fpga list 3
fpga program 3 /dd/cores/core.bin
fpga flash 3 /dd/cores/core.bin.gz
fpga abort
```

`status` prints one line in words - online/offline, idle/busy, reply waiting, no error or the error code in hex, the firmware major in decimal, supervisor ready/not ready and upload in progress - followed by the recorded actual boot context, source name and path (for example "Booted from: context 3, Internal flash, v8_rc18.bin.gz"). The actual boot source may differ from the saved default after fallback. `log` prints the supervisor's retained boot messages. `list` lists context 1 by default; an explicit argument selects physical context 1 through 4.

The list names each source: Automatic (SD, then flash), SD card, Internal flash, or GOLDEN recovery. Labels show [saved boot setting] and [last booted by RP2040] where applicable. File paths and decimal byte sizes appear on the following indented line; Automatic is a policy and has no file size. The booted label reflects the supervisor boot record, which a later JTAG load may not update. Manager-SD paths are not OS-9 paths.

`program N LOCAL.bin` uploads a raw 9,730,652-byte FPGA image from OS-9 to the supervisor SD card's `CNTXN` directory, retaining the local basename. For example, `fpga program 3 /dd/cores/core.bin` stores `0:/CNTX3/core.bin` on the supervisor SD. The supervisor writes a temporary file and replaces the destination after checking the transmitted size and CRC. An existing image with that basename is replaced.

`flash N LOCAL.gz` programs the replaceable internal-flash slot for physical context N (1 through 4). The supplied firmware requires gzip for internal flash: raw `.bin` is not accepted there. The gzip file must be 18 bytes through 2 MiB, and its trailer must declare a 9,730,652-byte expanded image. The command checks the header/trailer shape; it does not implement a gzip decompressor. Flash preparation erases the selected slot; cancellation or failure can leave that replaceable slot invalid. Embedded GOLDEN recovery is not a programming target.

Both commands read the local file once to compute standard CRC32, rewind, and stream packets of at most 240 bytes. They check every accepted-total reply, recompute CRC while sending, reject a changed/truncated local file, and require successful IMAGE_END with the correct total and inactive upload status. Progress prints accepted bytes in hexadecimal every 60 KiB. These commands store the image; they do not change the saved boot selection or reconfigure the running FPGA.

Ctrl-C/Ctrl-E cancellation stops the transfer and attempts IMAGE_ABORT when the mailbox is idle. An ambiguous append is never blindly resent. If a timed-out command remains busy, no abort is queued behind it; after the mailbox becomes idle, `fpga abort` explicitly cancels an unfinished upload before another attempt. It does not undo a completed flash erase or restore a replaced image.

Changing saved selection, booting a core, downloading images and firmware updating are not CLI options yet.

## Driver API

Open `/rp` with `UPDAT.` ($03). Do not add `SHARE.`: IOMan requires the requested mode to be supported by both the descriptor and driver. The driver enforces a single owner path, preventing another open from interleaving catalog or transfer state. Close releases ownership. An in-flight hardware command is not cancelled by close; reopening reports busy until it completes.

Write one binary request record: command byte, payload-length byte, then 0..240 payload bytes. The last byte submits the command and waits for completion. Read the response-length byte, followed by exactly that many reply bytes. Even a zero-payload reply has a zero-length prefix that must be consumed. The driver refuses another request until the previous reply is drained. Descriptor EOR and auto-LF are zero so SCF does not split CR-containing binary replies or insert LF bytes.

GetStat `$C0`, private to this driver, returns X as status:error and Y as firmware-major:remote-status. SS.Ready returns buffered bytes available in B. The command uses this API rather than accessing hardware registers in user state.

The driver uses FE78-FE7F and FE88-FE8F. Count registers are high-byte first; payload words/dwords are explicitly little-endian. Edition 2 waits at most 300 elapsed 60 Hz ticks normally, 1800 ticks for IMAGE_END, and 7200 ticks for flash-target IMAGE_BEGIN, sleeping between polls with interrupts enabled. After busy clears it waits one real tick before copying the reply, because the supplied FPGA engine clears busy before completing its RX FIFO copy. This conservative per-packet wait limits bulk throughput; a full raw image takes many minutes. No hardware throughput measurement has been made.

Nonce-bearing requests use an empty PING barrier and a fresh four-byte nonce. The command validates nonce, length, catalog generation/index/context and boot-log index. Invalid/stale replies fail rather than display misleading data. A stale catalog should be retried by running `fpga list` again. A timeout does not automatically resubmit an append or programming command.

## Validation limits

Assembly and 6809 CPU tests cover framing, all byte values across 0..240-byte payloads, ownership, unread replies, timeout accounting, early wakeups, tick wrap, stack/register balance, PING barriers, nonce rejection and the native command-to-driver path. OS calls and RP2040 responses are modeled in those tests. SCF raw read/write and status-call conventions were checked against the current source. This is not a physical K2 or full OS-9 runtime test.

Edition 2 adds CPU tests for all four programming contexts, little-endian size/CRC encoding, short reads, malformed accepted totals, local read errors, changed files, cancellation, busy-timeout cleanup, explicit abort, and 239/240/241/255/256/65537-byte transfer boundaries. A real gzip expanding to 9,730,652 bytes passes the complete two-pass command. Raw SD transfer-path tests enter after preflight to exercise smaller fixtures without weakening the production size guard; invalid/truncated raw preflight is tested separately. A complete 9.7 MB raw transfer and physical flash programming remain untested.
