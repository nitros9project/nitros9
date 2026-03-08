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
*   $FFC3-$FFC4   Virtual MC6850 ACIA (serial console)
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
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2025       Initial version

picothing           SET       1         conditional assembly symbol
TkPerSec            SET       50        ticks per second (50Hz timer)

*
* DAT (Dynamic Address Translator)
*
DAT.BlCt            EQU       8         blocks per address space
DAT.BlSz            EQU       (256/DAT.BlCt)*256 8KB block size
DAT.ImSz            EQU       DAT.BlCt*2 16 bytes per DAT image (2 bytes per block, low byte = page)
DAT.Task            EQU       $FFC0     task register (Pico)
DAT.Regs            EQU       $FE00     DAT RAM base address
DAT.TkCt            EQU       32        number of task slots
DAT.BlMx            EQU       $FE       max user-allocatable block number
DAT.Free            EQU       $333E     free block marker (matches CoCo3/wildbits convention)
DAT.BMSz            EQU       $100      block map size (256 physical pages)
DAT.WrPr            EQU       0         write protect (not supported)
DAT.WrEn            EQU       0         write enable (not supported)
KrnBlk              SET       $07       physical page number of the kernel (page 7)
HW.Page             EQU       $FF       high byte of I/O address space

*
* Virtual MC6850 ACIA (serial console, via Pico at $FFC3-$FFC4)
*
ACIABase            EQU       $FFC3     6850 base address
ACIA.Ctrl           EQU       ACIABase+0 status (read) / control (write)
ACIA.Data           EQU       ACIABase+1 receive (read) / transmit (write)

*
* Virtual 50 Hz Tick Timer (via Pico at $FFC8-$FFC9)
*
* Minimal tick timer using Pico SDK hardware alarm.
* Fires IRQ at 50Hz.  Reading the status register acknowledges the IRQ.
*
TICK.Ctrl           EQU       $FFC8     write: bit 0 = enable (1) / disable (0)
TICK.Stat           EQU       $FFC9     read: bit 7 = IRQ pending; cleared on read

*
* PATA Hard Disk (in I/O space $FF00-$FFBF)
*
* Note: the Pico maps the 16-bit ATA data word at PTIDEBase+0, shifting
* all other task-file registers up by one vs standard ATA.  Use
* defs/ide_picothing.d (not ide.d) for register offsets.
*
PTIDEBase           EQU       $FF00     PATA base address

*
* Boot
*
Bt.Start            EQU       $E800     boot_picothing at $E800 (padded to 1024), krn at $EC00
SHIFTBIT            EQU       0         no shift key on serial console

*
* Debug shared buffer ($FFD0-$FFDF)
*
* 16 bytes of Pico/6809 shared memory. The 6809 writes trace markers
* here; the Pico can read them for debug display. The Pico overwrites
* this range during many console actions, so nothing persistent goes here.
*
DBG.Base            EQU       $FFD0     debug buffer base
DBG.IRQ             EQU       $FFD0     user-state IRQ entry marker
DBG.SWI2            EQU       $FFD1     user-state SWI2 entry marker
DBG.CWAI            EQU       $FFD2     F$NProc cwai idle loop counter
DBG.TICK            EQU       $FFD3     clock timeslice handler entry counter
DBG.WAKE            EQU       $FFD4     sleep queue wake counter
DBG.SIRQ            EQU       $FFD5     system-state IRQ (S.SysIRQ/FastIRQ) counter
DBG.POLL            EQU       $FFD6     DoPoll entry counter (clock module)
DBG.TRACE           EQU       $FFD7     general trace marker (single byte, working range)
DBG.PC              EQU       $FFD8     captured PC from FastIRQ (2 bytes, big-endian)
DBG.IDEX            EQU       $FFDA     IDE: hardware address X (2 bytes, big-endian)
DBG.IDES            EQU       $FFDC     IDE: Status register value read by StatusWait
DBG.DrvW            EQU       $FFDD     sc6850 Write call counter
DBG.DrvR            EQU       $FFDE     sc6850 Read call counter
DBG.DrvI            EQU       $FFDF     sc6850 IRQSvc call counter

*
* Debug monitor entry points ($FC00-$FDFF, always mapped in kernel page)
*
DBG.PrintChar       EQU       $FC00     print character in A
DBG.Print2Hex       EQU       $FC03     print byte in A as 2 hex digits
DBG.Print4Hex       EQU       $FC06     print D as 4 hex digits
DBG.PrintStr        EQU       $FC09     print null-terminated string at X
DBG.PrintCR         EQU       $FC0C     print CR+LF
DBG.PrintRegs       EQU       $FC0F     print CC,A,B,DP,X,Y,U,S
DBG.IllegalOp       EQU       $FC12     6309 illegal opcode trap (does not return)

                  ENDC

