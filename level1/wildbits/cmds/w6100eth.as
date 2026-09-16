********************************************************************
* 
* W6100 Ethernet - hardware bring-up / PING test
* 
* Verifies that the 6809 can talk to the WIZnet W6100 Ethernet
* controller through the K2's I/O bridge at $FF40-$FF48, prints the
* chip ID/version and PHY link status, loads in a MAC/IP
* configuration, then fires the W6100's built-in SOCKET-less PING4
* command at a target host and reports whether a reply came back.
* No TCP/UDP socket setup is used - the SOCKET-less PING command
* lets the chip build and send/receive the ICMP Echo packet itself,
* which makes this about as small a "hello, network" test as the
* W6100 supports.
*
* w6100eth - by Matt Massie
* 
*
* 
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* started  2026/07/22 - 2026/07/25
* rev2 corrected register protocol against WizNet_8bitDataBus.v -
*      the bridge only latches bytes on write; nothing happens on
*      the WizNet bus until Control[0] is armed and edge-triggered;
*      $FF44/$FF45 aren't a flat 16-bit address; $FF41 loads the
*      high address byte. See notes below and in the access
*      routines (WSetARH/WRegRd/WRegWr/WWaitBusy).
* rev3 chip confirmed as W6100 per vendor spec (a stray "5100L"
*      comment in the board's top-level Verilog briefly pointed the
*      other way - noted for the record, not pursued further).
*      Added the NETLCKR unlock this chip requires before SHAR/GAR/
*      SUBR/SIPR writes take effect (SYSR[NETL] defaults locked;
*      writes are silently ignored otherwise - see W6100 datasheet
*      4.1.60). Also: WizNet_8bitDataBus.v has a data-direction bug
*      independent of any of the above - in the Addy_Phase7 state,
*      the D_OE (bus driver enable) logic is inverted relative to
*      what Decode0 establishes for the read/write direction bit,
*      so reads fight the chip for the bus and writes leave the bus
*      undriven. That's a gateware bug, not fixable from here - see
*      chat for the exact line numbers and a suggested fix. Nothing
*      in this file will produce correct results against real
*      hardware until that's corrected and the FPGA is reflashed.
* ------------------------------------------------------------------
*
* K2 <-> W6100 bridge, as actually implemented in
* WizNet_8bitDataBus.v (NOT as originally documented - see below):
*
*   $FF40  R/W  Control Register   - enable/mode/start bits, busy flag
*   $FF41  R/W  "MR Value"         - loads W6100 IDM_ARH (high addr byte)
*   $FF42       (unused / TBD in the RTL)
*   $FF43  R/W  Single Access Port - data byte for single xfers (IDM_DR)
*   $FF44  R/W  Control Register   - block select byte (IDM_BSR)
*   $FF45  R/W  "Address Lo/Hi"    - low address byte (IDM_ARL)
*   $FF46  R/W  Xfer size lo (burst mode only - unused by this test)
*   $FF47  R/W  Xfer size hi (burst mode only - unused by this test)
*   $FF48  R/W  FIFO port (burst mode only - unused by this test)
*
* The board's original register table calls $FF44/$FF45 "WizNet
* Address Lo/Hi" as if they formed one flat 16-bit address, and
* calls $FF41 an opaque "MR Value". Neither is what the gateware
* actually does - confirmed by tracing every assignment to
* WizNet_A_o (the 2-bit address bus driven to the W6100 chip):
*
*   - the normal address phase drives W6100 ADDR=01 (IDM_ARL) using
*     the byte at $FF45, then ADDR=10 (IDM_BSR) using the byte at
*     $FF44. It NEVER drives ADDR=00 (IDM_ARH).
*   - ADDR=00 (IDM_ARH) is only reachable through a separate "MR"
*     mode (Control[0] mode bits 010=write/110=read), which is
*     hardwired to ADDR=00. That mode is what $FF41 really is: the
*     way to load the W6100's indirect-address HIGH byte.
*
* So a full 16-bit register access is two bridge transactions: an
* "MR write" of the high byte through $FF41, then a normal single
* transfer using $FF44 (block select) + $FF45 (low addr) + $FF43
* (data). See WSetARH/WRegRd/WRegWr below.
*
* On top of the addressing mixup, writing a byte to any of these
* registers only loads a CPU-side latch - it does NOT by itself
* cause any activity on the WizNet bus. Control[0] must be written
* with the enable bit set and the mode bits selecting the desired
* operation, with the Start bit (bit 5) LOW, and then written AGAIN
* with Start HIGH - the 0->1 edge is what actually kicks off the
* transfer. Control[0] bit 7 (read-only) then reports "busy" until
* the transfer completes. This was the main reason the very first
* version of this test got no response at all: it wrote address/
* data bytes into the latches but never armed/triggered a transfer.
*
********************************************************************

                    nam       w6100eth
                    ttl       W6100 Ethernet hardware test

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       2

*-----------------------------------------------------------
* K2 <-> W6100 bridge registers
*
* IMPORTANT: this differs from the original board I/O table and
* from my first pass at this driver. The bridge's own Verilog
* (WizNet_8bitDataBus.v) was traced instruction-by-instruction to
* get this right; its own comments are NOT self-consistent (the
* $FF40-$FF48 table comment near the top of that file and the
* reset-block comments 20 lines later actually disagree with each
* other, and with the real dataflow). What's below is what the
* synthesizable logic (the "always" blocks and the WizNet_A_o
* assignments) actually does, not what any single comment claims.
*
* Two big corrections from the first driver:
*
*  1) Register writes to $FF40/$FF41/$FF43/$FF44/$FF45 only load
*     CPU-side latches. NOTHING happens on the WizNet bus until
*     you separately arm Control[0] (enable + mode bits) with the
*     Start bit LOW, then write it again with the Start bit HIGH.
*     Start is edge-triggered (0->1), so every transaction needs
*     that low-then-high write pair, and you must poll Control[0]
*     bit 7 (busy) until it clears before touching the result.
*     My first driver never did any of this - it just poked bytes
*     into the latches and expected a bus cycle to happen by
*     itself, which is the main reason nothing responded.
*
*  2) The bridge does NOT expose a flat 16-bit address the way the
*     $FF44/$FF45 "Address Lo/Hi" names suggest. Tracing WizNet_A_o:
*       - the address phase drives W6100 ADDR=01 (IDM_ARL) using
*         Control[5] ($FF45), then ADDR=10 (IDM_BSR) using
*         Control[4] ($FF44) - it NEVER drives ADDR=00 (IDM_ARH).
*       - ADDR=00 (IDM_ARH) is only reachable through the separate
*         "MR" mode (Control[0] mode bits = 010 write / 110 read),
*         which is hardwired to ADDR=00. That's what $FF41 ("MR
*         Value") actually is: the way to load the W6100's
*         indirect-address HIGH byte, not a mystery mode register.
*     So a full 16-bit register access is really two transactions:
*       a) an "MR write" of the high byte through $FF41
*       b) a normal single-transfer through $FF44 (block select,
*          i.e. W6100 IDM_BSR) + $FF45 (low address byte) + $FF43
*          (data)
*-----------------------------------------------------------
W.CTRL              equ       $FF40     Control[0] - mode/enable/start/busy
W.MR                equ       $FF41     Control[1] - loads W6100 IDM_ARH (high addr byte)
W.DATA              equ       $FF43     Control[3] - single xfer data in/out (IDM_DR)
W.BSR               equ       $FF44     Control[4] - block select byte (IDM_BSR)
W.ARL               equ       $FF45     Control[5] - low address byte (IDM_ARL)
W.SZLO              equ       $FF46     Control[6] - burst transfer size, low  (unused here)
W.SZHI              equ       $FF47     Control[7] - burst transfer size, high (unused here)
W.FIFO              equ       $FF48     burst FIFO data port (unused here)

* Control[0] bit fields
CTL.ENABLE          equ       %00000001 bit0 - core enable, must be 1 to do anything
CTL.START           equ       %00100000 bit5 - start transfer, edge-triggered (0->1)
CTL.BUSY            equ       %10000000 bit7 (RO) - transfer in progress

* Mode select occupies Control[0] bits[3:1]; combined here with
* CTL.ENABLE (Start left at 0 - OR in CTL.START separately to fire)
CTL.GO.WRSINGLE     equ       %00000001 mode 000: write single + enable
CTL.GO.WRBURST      equ       %00000011 mode 001: write burst  + enable
CTL.GO.WRMR         equ       %00000101 mode 010: write IDM_ARH + enable
CTL.GO.RDSINGLE     equ       %00001001 mode 100: read single  + enable
CTL.GO.RDBURST      equ       %00001011 mode 101: read burst   + enable
CTL.GO.RDMR         equ       %00001101 mode 110: read IDM_ARH + enable

BSR.COMMON          equ       $00       IDM_BSR value for the Common Register block

* --- constants for the /DD/SYS/w6100ipconfig parser ---
CHR.SP              equ       $20
CHR.CR              equ       $0D
T.IP4               equ       1         config value type: dotted-decimal IPv4
T.MAC               equ       2         config value type: colon/dash hex MAC
T.PORT              equ       3         config value type: decimal 16-bit port

*-----------------------------------------------------------
* W6100 Common Register offsets used by this test
* (see W6100 datasheet section 3.1/4.1)
*-----------------------------------------------------------
CIDR0               equ       $0000     Chip ID reg 0   (reset value $61)
CIDR1               equ       $0001     Chip ID reg 1   (reset value $00)
VER0                equ       $0002     Chip version 0  (reset value $46)
VER1                equ       $0003     Chip version 1  (reset value $61)
PHYSR               equ       $3000     PHY status (bit0 = link up)
SLIR                equ       $2102     SOCKET-less interrupt flags (RO)
SLIRCLR             equ       $2128     SOCKET-less interrupt clear (W1)
SLCR                equ       $2130     SOCKET-less command register
SHAR0               equ       $4120     Source MAC address (6 bytes)
GAR0                equ       $4130     Gateway IPv4 address (4 bytes)
SUBR0               equ       $4134     Subnet mask (4 bytes)
SIPR0               equ       $4138     Source (this board's) IPv4 (4 bytes)
SLDIPR0             equ       $418C     SOCKET-less dest IPv4, PING target
NETLCKR             equ       $41F5     Network Lock Register
NETLCKR.UNLOCK      equ       $3A       magic value that unlocks SHAR/GAR/SUBR/SIPR/...

SLCR.PING4          equ       %00100000 PING4 command bit (SLCR bit 5)
SLIR.PING4          equ       %00100000 PING4 reply-received flag
SLIR.TOUT           equ       %10000000 SOCKET-less command timeout flag
SLIR.ALL            equ       $FF       clears every SLIR bit via SLIRCLR

PING.RETRIES        equ       180       ~3 sec @ 60Hz ticks (F$Sleep 1 tick/loop)

                    mod       eom,name,tylg,atrv,start,size

*-----------------------------------------------------------
* Data area (process data - offsets from U, not stored in the
* module image; must come right after 'mod' with no code or
* literal data emitted ahead of it)
*-----------------------------------------------------------
Retries             rmb       1
tmp                 rmb       1
tmpw                rmb       2
RegHi                rmb       1         scratch: target reg addr, high byte
RegLo                rmb       1         scratch: target reg addr, low byte
RegData              rmb       1         scratch: data byte being written
BusyTO              rmb       1         set non-zero if a busy-wait ever times out
* --- config parser scratch ---
cfptr               rmb       2
cfend               rmb       2
kwptr               rmb       2
destp               rmb       2
ptype               rmb       1
acc                 rmb       2
octet               rmb       1
cfpn                rmb       1
* --- decimal-print scratch (for ShowCfg) ---
Num                 rmb       4
digcnt              rmb       1
* --- live network config (defaults copied in, then file overrides) ---
* keep these six contiguous & in this order (CopyDefaults block-copies)
CfgMAC              rmb       6
CfgIP               rmb       4
CfgMask             rmb       4
CfgGW               rmb       4
CfgSrv              rmb       4         remote host: ping target (= file server)
CfgPort             rmb       2         parsed but unused by this test
OutBuf              rmb       48        hex/decimal print scratch
* --- config file read buffer (U-relative access only) ---
ConfBuf             rmb       512
                    rmb       300       stack space
size                equ       .

name                fcs       /w6100eth/
                    fcb       edition

*=====================================================================
* Network settings now come from /DD/SYS/w6100ipconfig at run time
* (see LoadConfig / the parser below). These Def* values are only the
* fallback used when that file is missing or unreadable. Keep the 24
* bytes contiguous & ordered MAC,IP,MASK,GW,SRV,PORT to match Cfg*.
*=====================================================================
DefMAC              fcb       $02,$00,$00,$12,$34,$56    locally-admin MAC
DefIP               fcb       192,168,1,222              this board's IP
DefMask             fcb       255,255,255,0              subnet mask
DefGW               fcb       192,168,1,254              gateway
DefSrv              fcb       192,168,8,254              ping target (= file server)
DefPort             fdb       6809                       (unused by this test)

* config file pathlist (edit to relocate the config file)
CfgPath             fcc       "/DD/SYS/w6100ipconfig"
                    fcb       $0D
*=====================================================================

*=====================================================================
* start
*=====================================================================
start               lbsr      PrBanner

* --- Step 0: loopback test - does a byte written to Control[0]
* ($FF40) read back at all? This exercises ONLY the CPU<->bridge
* latch/readback path (Enable and Start are both left at 0, so
* nothing gets triggered on the WizNet bus and the W6100 chip is
* not involved yet). If this fails, the problem is upstream of
* everything else in this file - the $FF40-$FF48 address decode,
* CS_WizNet_i, CPU_Data_Valid_i, or Reset_i wiring at the FPGA
* top level - and no amount of 6809-side fixing will help until
* that's sorted out.
LOOP.PATTERN        equ       %01001110      arbitrary; avoids bit0(enable),
*                                            bit4(fifo reset), bit5(start),
*                                            bit7(busy, read-only anyway)
                    lda       #LOOP.PATTERN
                    sta       W.CTRL
                    lda       W.CTRL
                    anda      #%01111111      mask off the read-only busy bit
                    cmpa      #LOOP.PATTERN
                    beq       Loop.ok
                    leax      MsgLoopFail,pcr
                    lbsr      PrStr
                    lbsr      PrCRLF
                    leax      MsgLoopFail2,pcr
                    lbsr      PrStr
                    lbsr      PrCRLF
                    lbra      ChipFail
Loop.ok             leax      MsgLoopOK,pcr
                    lbsr      PrStr
                    lbsr      PrCRLF
                    clr       W.CTRL          leave Control[0] clean before Step 1

* --- Step 1: read CIDR0/VER0/VER1, confirm the chip answers ---
                    ldx       #CIDR0
                    lbsr      WRegRd
                    stb       <tmp
                    lda       <BusyTO
                    beq       CIDR.ok
                    leax      MsgBusyTO,pcr
                    lbsr      PrStr
                    lbsr      PrCRLF
                    lbra      ChipFail
CIDR.ok             leax       MsgCIDR,pcr
                    lbsr      PrStr
                    ldb       <tmp
                    lbsr      PrHexByte
                    lbsr      PrCRLF

                    ldx       #VER0
                    lbsr      WRegRd
                    stb       <tmp
                    leax       MsgVER0,pcr
                    lbsr      PrStr
                    ldb       <tmp
                    lbsr      PrHexByte
                    lbsr      PrCRLF

                    ldx       #VER1
                    lbsr      WRegRd
                    stb       <tmp
                    leax       MsgVER1,pcr
                    lbsr      PrStr
                    ldb       <tmp
                    lbsr      PrHexByte
                    lbsr      PrCRLF

* CIDR0 should read back $61 and VER0/VER1 $46/$61 out of reset.
* This is the simplest possible proof the bus/bridge/chip are
* talking; if this fails, nothing past here will work either.
                    ldx       #CIDR0
                    lbsr      WRegRd
                    cmpb      #$61
                    lbne      ChipFail

* --- Step 2: report PHY link status (informational only) ---
                    ldx       #PHYSR
                    lbsr      WRegRd
                    leax       MsgLink,pcr
                    lbsr      PrStr
                    bitb      #%00000001
                    beq       LinkDown
                    leax       MsgUp,pcr
                    bra       LinkPr
LinkDown            leax       MsgDown,pcr
LinkPr              lbsr      PrStr
                    lbsr      PrCRLF

* --- Step 2b: load network settings from /DD/SYS/w6100ipconfig ---
* (or fall back to the built-in Def* values), then show them.
                    lbsr      LoadConfig

* --- Step 3: unlock the network config registers, then load them ---
* SHAR/GAR/SUBR/SIPR writes are silently ignored while SYSR[NETL]
* is locked (the reset default), unless NETLCKR is unlocked first.
* Easy to miss since nothing signals the failure - the write just
* quietly does nothing.
                    ldx       #NETLCKR
                    ldb       #NETLCKR.UNLOCK
                    lbsr      WRegWr

                    leax      CfgMAC,u
                    ldy       #SHAR0
                    ldb       #6
                    lbsr      WBlkWr

                    leax      CfgGW,u
                    ldy       #GAR0
                    ldb       #4
                    lbsr      WBlkWr

                    leax      CfgMask,u
                    ldy       #SUBR0
                    ldb       #4
                    lbsr      WBlkWr

                    leax      CfgIP,u
                    ldy       #SIPR0
                    ldb       #4
                    lbsr      WBlkWr

                    leax      CfgSrv,u
                    ldy       #SLDIPR0
                    ldb       #4
                    lbsr      WBlkWr

                    leax       MsgCfgDone,pcr
                    lbsr      PrStr
                    lbsr      PrCRLF

* --- Step 4: clear old SOCKET-less flags, then fire PING4 ---
                    ldx       #SLIRCLR
                    ldb       #SLIR.ALL
                    lbsr      WRegWr

                    ldx       #SLCR
                    ldb       #SLCR.PING4
                    lbsr      WRegWr

                    leax       MsgPinging,pcr
                    lbsr      PrStr
                    lbsr      PrCRLF

* --- Step 5: poll SLIR for a reply or a timeout ---
                    ldb       #PING.RETRIES
                    stb       <Retries
PingWait            ldx       #SLIR
                    lbsr      WRegRd
                    bitb      #SLIR.PING4
                    lbne      PingOK
                    bitb      #SLIR.TOUT
                    lbne      PingTO
                    ldx       #1               1 tick delay between polls
                    os9       F$Sleep
                    dec       <Retries
                    lbne      PingWait
                    bra       PingTO

PingOK              leax       MsgPingOK,pcr
                    lbsr      PrStr
                    lbsr      PrCRLF
                    bra       AllDone

PingTO              leax       MsgPingTO,pcr
                    lbsr      PrStr
                    lbsr      PrCRLF
                    bra       AllDone

ChipFail            leax       MsgChipFail,pcr
                    lbsr      PrStr
                    lbsr      PrCRLF
                    clrb
                    coma                       non-zero exit code
                    os9       F$Exit

AllDone             clrb
                    os9       F$Exit

*=====================================================================
* WWaitBusy - poll Control[0] (W.CTRL) until the bridge's transfer
*             state machine returns to idle (bit7 clears). Bails
*             out after a generous timeout instead of hanging
*             forever, and records the fact in BusyTO so the main
*             test can report it distinctly from "chip answered
*             but with the wrong value".
*   Exit: A clobbered; BusyTO set to 1 if the wait timed out
*=====================================================================
WWaitBusy           pshs      x
                    ldx       #$FFFF          generous retry budget
WWaitBusy.lp        lda       W.CTRL
                    bpl       WWaitBusy.dn    bit7 clear (N=0) -> done
                    leax      -1,x
                    bne       WWaitBusy.lp
                    lda       #1
                    sta       <BusyTO         note that we gave up waiting
                    puls      x
                    rts
WWaitBusy.dn        clr       <BusyTO
                    puls      x
                    rts

*=====================================================================
* WSetARH - load the W6100 indirect-address HIGH byte (IDM_ARH).
* This is the thing the board calls "MR Value" ($FF41) - tracing
* the bridge's state machine shows the "MR" mode is hardwired to
* W6100 ADDR=00, which is IDM_ARH on the real chip, not a generic
* mode register.
*   Entry: A = high byte of the target 16-bit register offset
*=====================================================================
WSetARH             sta       W.MR            Control[1] -> IDM_ARH value
                    lda       #CTL.GO.WRMR
                    sta       W.CTRL          latch mode+enable, start=0
                    ora       #CTL.START
                    sta       W.CTRL          0->1 edge on Start kicks it off
                    lbsr      WWaitBusy
                    rts

*=====================================================================
* WRegWr - write one byte to a W6100 Common Register at a full
*          16-bit offset (does the ARH load, then the normal
*          block-select + low-address + data + single-write cycle)
*   Entry: X = 16-bit register offset, B = data byte
*=====================================================================
WRegWr              stb       <RegData
                    tfr       x,d             A:B = hi:lo of the target address
                    sta       <RegHi
                    stb       <RegLo
                    lda       <RegHi
                    lbsr      WSetARH         load IDM_ARH
                    lda       #BSR.COMMON
                    sta       W.BSR           Control[4] -> IDM_BSR (block select)
                    lda       <RegLo
                    sta       W.ARL           Control[5] -> IDM_ARL (low addr byte)
                    lda       <RegData
                    sta       W.DATA          Control[3] -> data to write
                    lda       #CTL.GO.WRSINGLE
                    sta       W.CTRL          latch mode+enable, start=0
                    ora       #CTL.START
                    sta       W.CTRL          0->1 edge kicks the write
                    lbsr      WWaitBusy
                    rts

*=====================================================================
* WRegRd - read one byte from a W6100 Common Register at a full
*          16-bit offset
*   Entry: X = 16-bit register offset
*   Exit:  B = data byte read
*=====================================================================
WRegRd              tfr       x,d             A:B = hi:lo of the target address
                    sta       <RegHi
                    stb       <RegLo
                    lda       <RegHi
                    lbsr      WSetARH         load IDM_ARH
                    lda       #BSR.COMMON
                    sta       W.BSR           Control[4] -> IDM_BSR (block select)
                    lda       <RegLo
                    sta       W.ARL           Control[5] -> IDM_ARL (low addr byte)
                    lda       #CTL.GO.RDSINGLE
                    sta       W.CTRL          latch mode+enable, start=0
                    ora       #CTL.START
                    sta       W.CTRL          0->1 edge kicks the read
                    lbsr      WWaitBusy
                    ldb       W.DATA          result of the single-transfer read
                    rts

*=====================================================================
* WBlkWr - write a block of consecutive bytes to consecutive
*=====================================================================
*          W6100 Common Register addresses (e.g. SHAR, GAR, SIPR)
*   Entry: X = pointer to source bytes in this module
*          Y = starting W6100 register offset
*          B = byte count
*=====================================================================
WBlkWr              pshs      x,y,a,b
                    stb       <tmp            byte count
WBlkWr.lp           lda       <tmp
                    beq       WBlkWr.dn
                    pshs      x,y             save source ptr and dest offset
                    lda       ,x              fetch source byte (X unchanged)
                    tfr       y,x             X = W6100 register offset for WRegWr
                    tfr       a,b             B = data byte to write
                    lbsr      WRegWr
                    puls      x,y             restore source ptr and dest offset
                    leax      1,x             advance source pointer
                    leay      1,y             advance destination offset
                    dec       <tmp
                    bra       WBlkWr.lp
WBlkWr.dn           puls      b,a,y,x,pc

*=====================================================================
* PrStr - print a null-terminated string, pointed to by X, to stdout
*=====================================================================
PrStr               pshs      x,y,a,b
                    tfr       x,y             Y = start of string (used for the write)
                    ldd       #0
                    std       <tmpw           length counter
PrStr.len           lda       ,x+
                    beq       PrStr.go
                    ldd       <tmpw
                    addd      #1
                    std       <tmpw
                    bra       PrStr.len
PrStr.go            tfr       y,x             X = start of string again
                    ldy       <tmpw           Y = length
                    lda       #1              path 1 = stdout
                    os9       I$Write
                    puls      b,a,y,x,pc

*=====================================================================
* PrCRLF - print a carriage return / line feed to stdout
*=====================================================================
PrCRLF              pshs      x,y,a
                    leax       CRLF,pcr
                    lda       #1
                    ldy       #2
                    os9       I$Write
                    puls      a,y,x,pc

*=====================================================================
* PrHexByte - print the byte in B as two hex digits to stdout
*=====================================================================
PrHexByte           pshs      x,y,a,b
                    stb       <tmp
                    ldb       <tmp
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    lbsr      PrNibble
                    ldb       <tmp
                    andb      #$0F
                    lbsr      PrNibble
                    puls      b,a,y,x,pc

PrNibble            pshs      x,y,a
                    cmpb      #9
                    bhi       PrNibble.af
                    addb      #'0
                    bra       PrNibble.pr
PrNibble.af         addb      #'A-10
PrNibble.pr         stb       OutBuf,u
                    leax      OutBuf,u
                    lda       #1
                    ldy       #1
                    os9       I$Write
                    puls      a,y,x,pc

*=====================================================================
* PrBanner - print the startup banner
*=====================================================================
PrBanner            pshs      x
                    leax       MsgBanner,pcr
                    lbsr      PrStr
                    lbsr      PrCRLF
                    puls      x,pc

*=====================================================================
* LoadConfig - copy Def* -> Cfg*, then apply /DD/SYS/w6100ipconfig
*              if present, then display the resulting settings.
* This block (LoadConfig..HexNib + PrIP4..D10s + KwTab) is identical
* to the one in w6100recv, so both tools read the same file the same
* way. w6100eth simply uses CfgSrv as the ping target and ignores
* CfgPort; "target" and "ping" are accepted as aliases for "server".
*=====================================================================
LoadConfig          lbsr      CopyDefaults
                    leax      CfgPath,pcr
                    lda       #READ.
                    os9       I$Open
                    bcs       LC.def
                    sta       <cfpn
                    lda       <cfpn
                    leax      ConfBuf,u
                    ldy       #512
                    os9       I$Read
                    bcs       LC.rderr
                    leax      ConfBuf,u
                    stx       <cfptr
                    tfr       x,d
                    pshs      y
                    addd      ,s++            D = ConfBuf + bytes read
                    std       <cfend
                    lda       <cfpn
                    os9       I$Close
                    lbsr      ParseConfig
                    leax      MsgCfgF,pcr
                    lbsr      PrStr
                    lbsr      PrCRLF
                    bra       LC.show
LC.rderr            lda       <cfpn
                    os9       I$Close
LC.def              leax      MsgCfgD,pcr
                    lbsr      PrStr
                    lbsr      PrCRLF
LC.show             lbsr      ShowCfg
                    rts

* CopyDefaults - Def* (ROM) -> Cfg* (RAM), 24 contiguous bytes
CopyDefaults        leax      DefMAC,pcr
                    leay      CfgMAC,u
                    ldb       #24
CD.lp               lda       ,x+
                    sta       ,y+
                    decb
                    bne       CD.lp
                    rts

* ShowCfg - print the active IP/GW/mask and ping target
ShowCfg             leax      MsgLip,pcr
                    lbsr      PrStr
                    leax      CfgIP,u
                    lbsr      PrIP4
                    leax      MsgLgw,pcr
                    lbsr      PrStr
                    leax      CfgGW,u
                    lbsr      PrIP4
                    leax      MsgLmask,pcr
                    lbsr      PrStr
                    leax      CfgMask,u
                    lbsr      PrIP4
                    lbsr      PrCRLF
                    leax      MsgLtgt,pcr
                    lbsr      PrStr
                    leax      CfgSrv,u
                    lbsr      PrIP4
                    lbsr      PrCRLF
                    rts

*=====================================================================
* ParseConfig - parse ConfBuf[cfptr..cfend) into Cfg* fields
*=====================================================================
ParseConfig
NextLine            ldd       <cfptr
                    cmpd      <cfend
                    lbhs      PC.done
                    lbsr      SkipBlanks
                    ldx       <cfptr
                    cmpx      <cfend
                    bhs       PC.done
                    lda       ,x
                    cmpa      #'#
                    beq       SkipLine
                    cmpa      #'*
                    beq       SkipLine
                    cmpa      #CHR.CR
                    beq       SkipLine
                    cmpa      #$0A
                    beq       SkipLine
                    lbsr      MatchKw
                    bcs       SkipLine
                    lda       <ptype
                    cmpa      #T.IP4
                    beq       DoIP4
                    cmpa      #T.MAC
                    beq       DoMAC
                    cmpa      #T.PORT
                    beq       DoPort
                    bra       SkipLine
DoIP4               lbsr      ParseIP4
                    bra       SkipLine
DoMAC               lbsr      ParseMAC
                    bra       SkipLine
DoPort              lbsr      ParsePort
                    bra       SkipLine
SkipLine            lbsr      ToNextLine
                    bra       NextLine
PC.done             rts

SkipBlanks          ldx       <cfptr
SB.lp               cmpx      <cfend
                    bhs       SB.dn
                    lda       ,x
                    cmpa      #CHR.SP
                    beq       SB.adv
                    cmpa      #$09
                    beq       SB.adv
                    bra       SB.dn
SB.adv              leax      1,x
                    bra       SB.lp
SB.dn               stx       <cfptr
                    rts

ToNextLine          ldx       <cfptr
TN.lp               cmpx      <cfend
                    bhs       TN.dn
                    lda       ,x+
                    cmpa      #CHR.CR
                    beq       TN.eol
                    cmpa      #$0A
                    beq       TN.eol
                    bra       TN.lp
TN.eol              cmpx      <cfend
                    bhs       TN.dn
                    ldb       ,x
                    cmpb      #$0A
                    beq       TN.skip
                    cmpb      #CHR.CR
                    beq       TN.skip
                    bra       TN.dn
TN.skip             leax      1,x
TN.dn               stx       <cfptr
                    rts

MatchKw             leax      KwTab,pcr
                    stx       <kwptr
MK.entry            ldx       <kwptr
                    ldb       ,x
                    cmpb      #$FF
                    beq       MK.nomatch
                    stb       <ptype
                    ldd       1,x
                    leay      d,u
                    sty       <destp
                    leax      3,x
                    ldy       <cfptr
MK.cmp              lda       ,x+
                    beq       MK.kwend
                    ldb       ,y+
                    cmpb      #'A
                    blo       MK.nolc
                    cmpb      #'Z
                    bhi       MK.nolc
                    addb      #$20
MK.nolc             pshs      a
                    cmpb      ,s+
                    beq       MK.cmp
                    bra       MK.next
MK.kwend            cmpy      <cfend
                    bhs       MK.matched
                    lda       ,y
                    cmpa      #CHR.SP
                    beq       MK.matched
                    cmpa      #$09
                    beq       MK.matched
                    cmpa      #'=
                    beq       MK.matched
                    cmpa      #CHR.CR
                    beq       MK.matched
                    cmpa      #$0A
                    beq       MK.matched
                    bra       MK.next
MK.matched          sty       <cfptr
                    lbsr      SkipToValue
                    andcc     #$FE
                    rts
MK.next             ldx       <kwptr
                    leax      3,x
MK.skn              lda       ,x+
                    bne       MK.skn
                    stx       <kwptr
                    bra       MK.entry
MK.nomatch          orcc      #$01
                    rts

SkipToValue         ldx       <cfptr
STV.lp              cmpx      <cfend
                    bhs       STV.dn
                    lda       ,x
                    cmpa      #CHR.SP
                    beq       STV.adv
                    cmpa      #$09
                    beq       STV.adv
                    cmpa      #'=
                    beq       STV.adv
                    bra       STV.dn
STV.adv             leax      1,x
                    bra       STV.lp
STV.dn              stx       <cfptr
                    rts

ParseIP4            ldy       <destp
                    clr       <octet
PI.lp               lbsr      ParseDecByte
                    bcs       PI.dn
                    stb       ,y+
                    inc       <octet
                    lda       <octet
                    cmpa      #4
                    beq       PI.dn
                    ldx       <cfptr
                    cmpx      <cfend
                    bhs       PI.dn
                    lda       ,x
                    cmpa      #'.
                    bne       PI.dn
                    leax      1,x
                    stx       <cfptr
                    bra       PI.lp
PI.dn               rts

ParsePort           lbsr      ParseDecByte
                    bcs       PP.dn
                    ldy       <destp
                    ldd       <acc
                    std       ,y
PP.dn               rts

ParseDecByte        ldx       <cfptr
                    clra
                    clrb
                    std       <acc
                    ldb       ,x
                    subb      #'0
                    bcs       PDB.nd
                    cmpb      #9
                    bhi       PDB.nd
PDB.lp              ldb       ,x
                    subb      #'0
                    bcs       PDB.end
                    cmpb      #9
                    bhi       PDB.end
                    lbsr      Acc10Add
                    leax      1,x
                    bra       PDB.lp
PDB.end             stx       <cfptr
                    ldb       <acc+1
                    andcc     #$FE
                    rts
PDB.nd              stx       <cfptr
                    orcc      #$01
                    rts

Acc10Add            pshs      b
                    ldd       <acc
                    aslb
                    rola
                    std       <tmpw
                    ldd       <acc
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    addd      <tmpw
                    addb      ,s+
                    adca      #0
                    std       <acc
                    rts

ParseMAC            ldy       <destp
                    clr       <octet
PM.lp               lbsr      ParseHexByte
                    bcs       PM.dn
                    stb       ,y+
                    inc       <octet
                    lda       <octet
                    cmpa      #6
                    beq       PM.dn
                    ldx       <cfptr
                    cmpx      <cfend
                    bhs       PM.dn
                    lda       ,x
                    cmpa      #':
                    beq       PM.sep
                    cmpa      #'-
                    beq       PM.sep
                    bra       PM.dn
PM.sep              leax      1,x
                    stx       <cfptr
                    bra       PM.lp
PM.dn               rts

ParseHexByte        ldx       <cfptr
                    lda       ,x
                    lbsr      HexNib
                    bcs       PHB.nd
                    aslb
                    aslb
                    aslb
                    aslb
                    stb       <tmp
                    leax      1,x
                    lda       ,x
                    lbsr      HexNib
                    bcs       PHB.one
                    pshs      b
                    ldb       <tmp
                    orb       ,s+
                    leax      1,x
                    stx       <cfptr
                    andcc     #$FE
                    rts
PHB.one             ldb       <tmp
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    stx       <cfptr
                    andcc     #$FE
                    rts
PHB.nd              stx       <cfptr
                    orcc      #$01
                    rts

HexNib              cmpa      #'0
                    blo       HN.bad
                    cmpa      #'9
                    bhi       HN.af
                    tfr       a,b
                    subb      #'0
                    andcc     #$FE
                    rts
HN.af               anda      #$DF
                    cmpa      #'A
                    blo       HN.bad
                    cmpa      #'F
                    bhi       HN.bad
                    tfr       a,b
                    subb      #'A-10
                    andcc     #$FE
                    rts
HN.bad              orcc      #$01
                    rts

*=====================================================================
* PrIP4 - print 4 bytes at X as dotted decimal
*=====================================================================
PrIP4               ldb       ,x+
                    pshs      x
                    lbsr      PrOctet
                    puls      x
                    lbsr      PrDot
                    ldb       ,x+
                    pshs      x
                    lbsr      PrOctet
                    puls      x
                    lbsr      PrDot
                    ldb       ,x+
                    pshs      x
                    lbsr      PrOctet
                    puls      x
                    lbsr      PrDot
                    ldb       ,x+
                    pshs      x
                    lbsr      PrOctet
                    puls      x
                    rts
PrOctet             pshs      b
                    clra
                    clrb
                    std       <Num
                    std       <Num+2
                    puls      b
                    stb       <Num+3
                    lbsr      PrDec32
                    rts
PrDot               pshs      x,y,a
                    lda       #'.
                    sta       OutBuf,u
                    leax      OutBuf,u
                    lda       #1
                    ldy       #1
                    os9       I$Write
                    puls      a,y,x,pc

* PrDec32 - print the 32-bit value in <Num as unsigned decimal
PrDec32             clr       <digcnt
PD.lp               lbsr      Div10Num
                    addb      #'0
                    pshs      b
                    inc       <digcnt
                    lda       <Num
                    ora       <Num+1
                    ora       <Num+2
                    ora       <Num+3
                    bne       PD.lp
PD.pr               puls      b
                    stb       OutBuf,u
                    leax      OutBuf,u
                    lda       #1
                    ldy       #1
                    os9       I$Write
                    dec       <digcnt
                    bne       PD.pr
                    rts

Div10Num            clra
                    ldb       <Num
                    bsr       D10s
                    stb       <Num
                    ldb       <Num+1
                    bsr       D10s
                    stb       <Num+1
                    ldb       <Num+2
                    bsr       D10s
                    stb       <Num+2
                    ldb       <Num+3
                    bsr       D10s
                    stb       <Num+3
                    tfr       a,b
                    rts
D10s                ldx       #0
D10s.lp             cmpd      #10
                    blo       D10s.dn
                    subd      #10
                    leax      1,x
                    bra       D10s.lp
D10s.dn             stx       <tmpw
                    tfr       b,a
                    ldb       <tmpw+1
                    rts

*=====================================================================
* keyword table: fcb type ; fdb Cfg-offset ; fcc name ; fcb 0 ; $FF end
* ("server", "target" and "ping" all set the ping target CfgSrv)
*=====================================================================
KwTab               fcb       T.MAC
                    fdb       CfgMAC
                    fcc       /mac/
                    fcb       0
                    fcb       T.IP4
                    fdb       CfgIP
                    fcc       /ip/
                    fcb       0
                    fcb       T.IP4
                    fdb       CfgMask
                    fcc       /mask/
                    fcb       0
                    fcb       T.IP4
                    fdb       CfgMask
                    fcc       /netmask/
                    fcb       0
                    fcb       T.IP4
                    fdb       CfgMask
                    fcc       /subnet/
                    fcb       0
                    fcb       T.IP4
                    fdb       CfgGW
                    fcc       /gateway/
                    fcb       0
                    fcb       T.IP4
                    fdb       CfgGW
                    fcc       /gw/
                    fcb       0
                    fcb       T.IP4
                    fdb       CfgSrv
                    fcc       /server/
                    fcb       0
                    fcb       T.IP4
                    fdb       CfgSrv
                    fcc       /target/
                    fcb       0
                    fcb       T.IP4
                    fdb       CfgSrv
                    fcc       /ping/
                    fcb       0
                    fcb       T.PORT
                    fdb       CfgPort
                    fcc       /port/
                    fcb       0
                    fcb       $FF

*-----------------------------------------------------------
* Messages
*-----------------------------------------------------------
MsgBanner           fcc       /W6100 Ethernet hardware test/
                    fcb       0
MsgCfgF             fcc       "Config: /DD/SYS/w6100ipconfig"
                    fcb       0
MsgCfgD             fcc       "Config: built-in defaults (no /DD/SYS/w6100ipconfig)"
                    fcb       0
MsgLip              fcc       /  ip /
                    fcb       0
MsgLgw              fcc       /  gw /
                    fcb       0
MsgLmask            fcc       /  mask /
                    fcb       0
MsgLtgt             fcc       /  ping target /
                    fcb       0
MsgCIDR             fcc       /CIDR0 = $/
                    fcb       0
MsgVER0             fcc       /VER0  = $/
                    fcb       0
MsgVER1             fcc       /VER1  = $/
                    fcb       0
MsgLoopFail         fcc       "Loopback FAILED - CPU write to $FF40 did not read back. Check"
                    fcb       0
MsgLoopFail2        fcc       "$FF40-$FF48 address decode, CS_WizNet_i, CPU_Data_Valid_i, Reset_i"
                    fcb       0
MsgLoopOK           fcc       "Loopback OK - CPU can read/write the bridge's Control register"
                    fcb       0
MsgBusyTO           fcc       "Bridge never went idle (busy timeout) - check Control reg wiring/clock"
                    fcb       0
MsgChipFail         fcc       "No response from W6100 - check bus wiring and I/O addresses"
                    fcb       0
MsgLink             fcc       /PHY link: /
                    fcb       0
MsgUp               fcc       /UP/
                    fcb       0
MsgDown             fcc       /DOWN/
                    fcb       0
MsgCfgDone          fcc       "Network config loaded (MAC/GW/SUBNET/IP/target)"
                    fcb       0
MsgPinging          fcc       /Sending SOCKET-less PING4.../
                    fcb       0
MsgPingOK           fcc       /PING reply received - link to host is alive/
                    fcb       0
MsgPingTO           fcc       "No PING reply (timeout) - check IP config/cabling/host"
                    fcb       0
CRLF                fcb       $0D,$0A

                    emod
eom                 equ       *
                    end
