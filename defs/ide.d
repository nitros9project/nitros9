                    IFNE      IDE.D-1
IDE.D               SET       1
********************************************************************
* ide.d - IDE definitions
*
* (C) 2004 Boisy G. Pitre - Licensed to Cloud-9
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2005/12/11  Boisy G. Pitre
* Moved IDE base addresses and I/O offsets to here.

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

*
* IDE Registers
*
DataReg             EQU       0                   Data (1st 8 bits, non-latched)
ErrorReg            EQU       1                   Error # when read
Features            EQU       1                   Features when write
SectCnt             EQU       2                   Sector count
SectNum             EQU       3                   Sector #
CylLow              EQU       4                   Low byte of cylinder
CylHigh             EQU       5                   High byte of cylinder
DevHead             EQU       6                   Device/Head
Status              EQU       7                   Status when read
Command             EQU       7                   Command when write
Latch               EQU       8                   Latch (2nd 8 bits of 16 bit word)

BusyBit             EQU       %10000000           BUSY=1
DrdyBit             EQU       %01000000           drive ready=1
DscBit              EQU       %00010000           seek finished=1
DrqBit              EQU       %00001000           data requested=1
ErrBit              EQU       %00000001           error_reg has it
RdyTrk              EQU       %01010000           ready & over track
RdyDrq              EQU       %01011000           ready w/ data

**** IDE Interface Definitions
                    IFNE      IDE
SDAddr              SET       $FF50
                    ENDC

                    ENDC

