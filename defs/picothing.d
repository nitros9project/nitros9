                  IFNE    PICOTHING.D-1

PICOTHING.D         SET       1

********************************************************************
* picothing.d - Pico-Thing MC6809 Board Hardware Definitions
*
* Custom MC6809 board with:
*   - 2MB RAM in 8kB pages (256 physical pages)
*   - 256-byte DAT RAM at $FE00-$FEFF for address translation
*   - Pi Pico providing virtual peripherals at $FFC0-$FFFF
*
* Memory Map:
*   $0000-$FDFF   RAM (DAT-translated)
*   $FE00-$FEFF   DAT RAM (32 tasks * 8 regs * 1 byte = 256 bytes)
*   $FF00-$FFBF   I/O space (PATA HD, etc.)
*   $FFC0         Task register (Pico)
*   $FFC4-$FFC5   Virtual MC6850 ACIA (serial console)
*   $FFC6-$FFC7   Virtual MC6850 ACIA (auxiliary)
*   $FFC8-$FFC9   Virtual 50Hz tick timer (fires IRQ)
*   $FFF0-$FFFF   6809 hardware vectors (provided by Pico)
*
* DAT Structure:
*   The 256-byte DAT RAM is indexed by {task_reg[4:0], addr[15:13]}.
*   - task_reg: 5-bit task number (0-31), held in Pico register at $FFC0
*   - addr[15:13]: top 3 bits of 6809 address select one of 8 page slots
*   - Each byte is the 8-bit physical page number (0-255)
*   - Task 0 base: DAT.Regs + 0*8 = $FE00
*   - Task 1 base: DAT.Regs + 1*8 = $FE08  (matches CoCo3's DAT.Regs+8)
*   - Task 2 base: DAT.Regs + 2*8 = $FE10
*   - ... etc
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2025       Initial version

picothing           SET       1         conditional assembly symbol
TkPerSec            SET       50        ticks per second (50Hz timer)

*
* Physical address space
*
HW.Page             EQU       $FF       high byte of I/O address space
IO.Base             EQU       HW.Page*256 base of I/O address space

*
* DAT (Dynamic Address Translator)
*
DAT.BlCt            EQU       8         blocks per address space
DAT.BlSz            EQU       (256/DAT.BlCt)*256 block size
DAT.ImSz            EQU       DAT.BlCt*2 16 bytes per DAT image (2 bytes per block, low byte = page)
DAT.Task            EQU       IO.Base+$C0 task register (Pico)
DAT.Regs            EQU       $FE00     DAT RAM base address
DAT.TkCt            EQU       32        number of task slots
DAT.BlMx            EQU       $FE       max user-allocatable block number
DAT.Free            EQU       $33FF     free block marker (page $FF = no RAM in hardware)
DAT.BMSz            EQU       $100      block map size
DAT.WrPr            EQU       0         write protect (not supported)
DAT.WrEn            EQU       0         write enable (not supported)
KrnBlk              SET       $FF       physical page number of the kernel

* Start of protected upper memory (DAT RAM and I/O).
UserMemLimit        equ       $FE00

*
* Virtual MC6850 ACIA — console (via Pico at $FFC4-$FFC5)
*
ACIABase            EQU       IO.Base+$C4 console 6850 base address
ACIA.Ctrl           EQU       ACIABase+0 status (read) / control (write)
ACIA.Data           EQU       ACIABase+1 receive (read) / transmit (write)

*
* Virtual MC6850 ACIA — auxiliary (via Pico at $FFC6-$FFC7)
*
AuxBase             EQU       IO.Base+$C6 auxiliary 6850 base address
Aux.Ctrl            EQU       AuxBase+0 status (read) / control (write)
Aux.Data            EQU       AuxBase+1 receive (read) / transmit (write)

*
* Virtual 50 Hz Tick Timer (via Pico at $FFC8-$FFC9)
*
* Minimal tick timer using Pico SDK hardware alarm.
* Fires IRQ at 50Hz.  Reading the status register acknowledges the IRQ.
*
TICK.Ctrl           EQU       IO.Base+$C8 write: bit 0 = enable (1) / disable (0)
TICK.Stat           EQU       IO.Base+$C9 read: bit 7 = IRQ pending; cleared on read

*
* SystemWatchpoint control (Pico at $FFCA)
*
* Writing a non-zero value arms the vector watchpoint: the $FFF0-$FFFF
* vector region becomes read-only and any write there traps via NMI.
* Writing zero disarms it.
*
WatchCtl            EQU       IO.Base+$CA hardware vector watchpoint control

*
* PATA Hard Disk (in I/O space $FF00-$FFBF)
*
* Note: the Pico maps the 16-bit ATA data word at PTIDEBase+0, shifting
* all other task-file registers up by one vs standard ATA.  Use
* defs/ide_picothing.d (not ide.d) for register offsets.
*
PTIDEBase           EQU       IO.Base+$00 PATA base address

*
* Video Pico — second RP2350 graphics/console coprocessor (via GAL at $FF10-$FF11)
*
* Two MC6850-shaped registers with separate hardware read and write arrays, so
* the read and write meanings share an offset.  VID.Data moves one byte each
* way; VID.Stat carries the flow-control and status bits when read, or takes a
* control command when written.  All access is polled — there is no interrupt
* dependency (VID.Stat bit 7 is reserved for a future interrupt flag).
*
VID.Data            EQU       IO.Base+$10 read receive byte / write transmit byte
VID.Stat            EQU       IO.Base+$11 read status / write control
* VID.Info: read-only panel-geometry info block.  Write any value to home
* the walk index, then read six bytes: width hi, width lo, height hi,
* height lo, text columns, text rows (big-endian, pixels first).  The
* values come from the pico renderer's own geometry, so they never drift
* from what is drawn; the index wraps, so an over-long read restarts.
VID.Info            EQU       IO.Base+$13 panel geometry (write=home, read x6)

* VID.Stat status bits (read from VID.Stat)
VID.RDRF            EQU       %00000001 receive data available
VID.TDRE            EQU       %00000010 transmit space free
VID.RDY             EQU       %00000100 video pico alive and initialised
VID.VerMsk          EQU       %00111000 protocol version mask (bits 5-3)
* Version 1 in the VID.VerMsk position - the driver's liveness check.  An
* absent/rebooting pico floats the bus to $FF (version 7) or reads $00
* (version 0); a live pico reads version 1, so a version mismatch means the
* device is not present and the rest of the status byte must not be believed.
VID.Ver1            EQU       %00001000 protocol version 1 (live device)

* VID.Ctl control bits (write to VID.Stat)
VID.Rset            EQU       %00000001 soft reset: flush the fifos
VID.Loop            EQU       %00000010 loopback: transmit bytes echo to receive

*
* Battery-backed RTC — DS12885 in Motorola mode (via GAL at $FF32-$FF33)
*
* MC146818-register-compatible.  Index/data pair: write the register
* number to RTC.Idx, then read or write the value at RTC.Dat.  Each
* access is two steps and must not be interrupted (mask IRQs around it).
* 14 clock/control registers plus 114 bytes of NVRAM at $0E-$7F.
*
RTC.Idx             EQU       IO.Base+$32 register-select (index) port
RTC.Dat             EQU       IO.Base+$33 data port

*
* Boot
*
* REL preloads the whole bootfile, krn included, so that it ends at
* Bt.End, and passes its start in X and its size in Y; the kernel adopts
* it in place, so there is no boot module and no F$Boot (the Wildbits
* scheme).  $FC00-$FDFF holds the Pico's debug monitor, so the bootfile
* ends below it.  At Level 2 krn is the last module and sits at $EC00,
* inside the fixed $E000-$FFFF window (KrnFixW); at Level 1 it is the
* first.
*
BtPreld             EQU       1         REL preloads the bootfile
KrnFixW             EQU       1         the kernel window is the fixed page KrnBlk
Bt.End              EQU       $FC00     the bootfile ends here
RAMBlks             EQU       $100      fixed RAM: 2MB in 8K blocks
Bt.Start            EQU       $EC00     where krn sits at Level 2
SHIFTBIT            EQU       0         no shift key on serial console

*
* Debug monitor entry points always present in kernel space
*
DBG.PrintChar       EQU       $FC00     print character in A
DBG.Print2Hex       EQU       $FC03     print byte in A as 2 hex digits
DBG.Print4Hex       EQU       $FC06     print D as 4 hex digits
DBG.PrintStr        EQU       $FC09     print null-terminated string at X
DBG.PrintCR         EQU       $FC0C     print CR+LF
DBG.PrintRegs       EQU       $FC0F     print CC,A,B,DP,X,Y,U,S
DBG.IllegalOp       EQU       $FC12     6309 illegal opcode trap (does not return)

                  ENDC

