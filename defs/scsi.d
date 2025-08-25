                    IFNE      SCSI.D-1
SCSI.D              SET       1

********************************************************************
* scsi.d - SCSI definitions
*
* (C) 2004 Boisy G. Pitre - Licensed to Cloud-9
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2005/12/11  Boisy G. Pitre
* Moved SCSI base addresses and I/O offsets to here.


*
* SCSI Packet Command Bytes
*
S$REZERO            EQU       $01
S$REQSEN            EQU       $03
S$FORMAT            EQU       $04
S$READ              EQU       $08
S$WRITE             EQU       $0A
S$SEEK              EQU       $0B
S$MODSEL            EQU       $15
S$UNIT              EQU       $1B
S$RCAP              EQU       $25
S$READEX            EQU       $28
S$WRITEX            EQU       $2A

*
* SCSI Status Codes
*
X$ERROR             EQU       $02
X$BUSY              EQU       $08

**** Cloud-9 TC^3 Controller Definitions
                    IFNE      TC3+SB
SDMPI               SET       $02                 Added 2012\11\05 GH
SCSIDATA            EQU       0
SCSISTAT            EQU       1
SCSISEL             EQU       1
SCSIRST             EQU       1                   INVALID, but not used

REQ                 EQU       $01
BUSY                EQU       $02
MSG                 EQU       $04
CMD                 EQU       $08
INOUT               EQU       $10

                    IFNE      SB
SDAddr              SET       $FF1E
                    ELSE
SDAddr              SET       $FF74
                    ENDC

                    ENDC

**** Ken-Ton/LR-Tech Controller Definitions
                    IFNE      KTLR
SCSIDATA            EQU       0
SCSISTAT            EQU       1
SCSISEL             EQU       2
SCSIRST             EQU       3

REQ                 EQU       $01
BUSY                EQU       $02
MSG                 EQU       $04
CMD                 EQU       $08
INOUT               EQU       $10
ACK                 EQU       $20
SEL                 EQU       $40
RST                 EQU       $80

SDAddr              SET       $FF74
                    ENDC

**** Disto 4-N-1/HD-II Controller Definitions
                    IFNE      D4N1+HDII
SDMPI               SET       $02

* Disto SCSI Controller Definitions
SCSIDATA            EQU       0
SCSISTAT            EQU       -2
SCSISEL             EQU       -1
SCSIRST             EQU       -2

SEL                 EQU       $00
BUSY                EQU       $01
ACK                 EQU       $02
MSG                 EQU       $04
INOUT               EQU       $20
CMD                 EQU       $40
REQ                 EQU       $80

                    IFNE      D4N1
SDAddr              SET       $FF5B
                    ELSE
SDAddr              SET       $FF53
                    ENDC
                    ENDC

                    ENDC
