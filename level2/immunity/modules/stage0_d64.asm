********************************************************************
* stage0_d64 - DragonDOS boot loader for the Dragon 64 + i-MMU-nity
*
* The Level 2 kernel track (REL $130 + BOOT $1D0 + KRN $F00 = $1200
* bytes) doesn't fit the $1000-byte DragonDOS boot area (LSN 2-17), so
* the disk carries the kernel track where a CoCo disk has it (track 34,
* side 0, written by "os9 gen -t") and this loader in the boot area
* (written by "os9 gen -d -t").
*
* DragonDOS BOOT loads the boot area to $2600, checks for "OS" and jumps
* to $2602 with the MMU off. This code copies itself to $3800, reads
* cylinder 34 side 0, sectors 1-18, to $2600-$37FF and jumps to REL at
* $2602, which then runs exactly as on the CoCo.
*
* Polled I/O: the WD2797 DRQ reaches the CPU through PIA1 CB1 (FIRQ,
* masked) and wakes SYNC; NMI stays disabled in the drive latch, so no
* vector is needed. Every other interrupt source is switched off first,
* because a masked IRQ would also wake SYNC.
* No timeout: a sector that is never found (no DRQ) hangs in SYNC. The
* character at $0400 (top left) changes on every sector attempt.
*
* Assembled with ASROM (raw binary).
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2026/10/16
* First version.

                    nam       stage0_d64
                    ttl       DragonDOS boot loader for i-MMU-nity

KTrack              equ       34                  kernel track (cylinder, side 0)
KSects              equ       18                  sectors per track
KLoad               equ       $2600               kernel track load address
HiAddr              equ       $3800               where this loader runs
Screen              equ       $0400               DragonDOS text screen

DDCtl               equ       $04                 drive 0, motor on, MFM, NMI off
StepCode            equ       3                   slowest step rate

                    org       KLoad
                    fcc       /OS/                DragonDOS BOOT signature
Start               orcc      #$50                IRQ and FIRQ masked
                    lds       #$3F00              stack above loader, below 16K
                    leax      Hi,pcr
                    ldu       #HiAddr
                    ldy       #HiSize
CopyLp              lda       ,x+
                    sta       ,u+
                    leay      -1,y
                    bne       CopyLp
                    jmp       >HiAddr

* Everything below runs at HiAddr: position independent code only.
Hi                  lda       #$FF
                    tfr       a,dp
                    setdp     $FF

* Silence every source that could wake SYNC
                    lda       <$01                PIA0 CRA: HSYNC IRQ off
                    anda      #$FE
                    sta       <$01
                    lda       <$03                PIA0 CRB: VSYNC IRQ off
                    anda      #$FE
                    sta       <$03
                    lda       <$21                PIA1 CRA: printer ACK IRQ off
                    anda      #$FE
                    sta       <$21
                    lda       <$06                ACIA: DTR off disables its IRQs
                    anda      #$FE
                    sta       <$06

* Drive 0 on, give the motor time to spin up
                    lda       #DDCtl
                    sta       <$48
                    ldx       #$C350
Spin                nop
                    nop
                    leax      -1,x
                    bne       Spin

                    ldb       #$D0                force interrupt
                    bsr       Cmd
                    ldb       #$00+StepCode       restore
                    bsr       Cmd
                    lda       #KTrack
                    sta       <$43
                    ldb       #$10+StepCode       seek
                    bsr       Cmd
                    ldx       #$222E              head settle
Settle              leax      -1,x
                    bne       Settle

                    lda       #$37                PIA1 CRB: CB1 (DRQ) flag on
                    sta       <$23

                    ldx       #KLoad
                    ldy       #1                  first sector
Sector              lda       #8                  retries
                    pshs      a
Retry               inc       >Screen             progress
                    tfr       y,d
                    stb       <$42                sector register
                    lda       <$22                clear a stale DRQ flag
                    ldb       #$88                read sector, side 0
                    stb       <$40
                    clrb                          256 bytes
Read                sync
                    lda       <$43
                    sta       ,x+
                    lda       <$22                clear the DRQ flag
                    decb
                    bne       Read
                    bsr       Wait
                    bita      #$1C                RNF, CRC or lost data?
                    beq       Good
                    leax      -256,x
                    dec       ,s
                    bne       Retry
Fail                bra       Fail                give up (screen shows count)

Good                leas      1,s
                    leay      1,y
                    cmpy      #KSects+1
                    bne       Sector

                    lda       #$34                PIA1 CRB: CB1 flag off
                    sta       <$23
                    clra
                    tfr       a,dp
                    jmp       >KLoad+2            REL

* Issue command B, wait until not busy. Exit: A=status
Cmd                 stb       <$40
                    ldb       #20                 let the WD set BUSY
Dly                 decb
                    bne       Dly
Wait                lda       <$40
                    bita      #$01
                    bne       Wait
                    rts

HiSize              equ       *-Hi
                    end
