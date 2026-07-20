                  IFNE    IDE_PICOTHING.D-1

IDE_PICOTHING.D     SET       1
IDE.D               SET       1         suppress standard ide.d (offsets differ)

********************************************************************
* ide_picothing.d - IDE register definitions for Pico-Thing
*
* The Pico presents the ATA data register as a 16-bit word at
* PTIDEBase+0 (two bytes wide).  All subsequent task-file registers
* are therefore shifted up by one compared to the standard ATA map.
*
* Standard ATA -> Pico-Thing:
*   DataReg  +0  ->  +0  (16-bit; use LDD/STD, no separate Latch)
*   ErrorReg +1  ->  +2
*   SectCnt  +2  ->  +3
*   SectNum  +3  ->  +4
*   CylLow   +4  ->  +5
*   CylHigh  +5  ->  +6
*   DevHead  +6  ->  +7
*   Status   +7  ->  +8
*   Command  +7  ->  +8
*   (Latch   +8     n/a -- does not exist on Pico-Thing)
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2025       Initial version for Pico-Thing

*
* ATAPI Commands
*
A$READ2             EQU       $A8
A$WRITE2            EQU       $AA
A$READ              EQU       $28
A$WRITE             EQU       $2A
A$STOP              EQU       $1B

*
* ATA Commands
*
S$READ              EQU       $20
S$WRITE             EQU       $30
S$IDENTIFY          EQU       $EC       identify device

*
* IDE Task File Registers (offsets from PTIDEBase)
*
DataReg             EQU       0         data register (16-bit: use LDD/STD)
ErrorReg            EQU       2         error register (read)
Features            EQU       2         features register (write)
SectCnt             EQU       3         sector count
SectNum             EQU       4         sector number (LBA bits 7:0)
CylLow              EQU       5         cylinder low (LBA bits 15:8)
CylHigh             EQU       6         cylinder high (LBA bits 23:16)
DevHead             EQU       7         device/head register
Status              EQU       8         status register (read)
Command             EQU       8         command register (write)
AltStatus           EQU       9         alternate status / device control

*
* Status Register Bits
*
BusyBit             EQU       %10000000 BUSY=1
DrdyBit             EQU       %01000000 drive ready=1
DscBit              EQU       %00010000 seek finished=1
DrqBit              EQU       %00001000 data requested=1
ErrBit              EQU       %00000001 error register valid
RdyTrk              EQU       %01010000 ready and over track
RdyDrq              EQU       %01011000 ready with data

                  ENDC

