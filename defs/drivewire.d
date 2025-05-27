                    IFNE      DRIVEWIRE.D-1
DRIVEWIRE.D         SET       1
********************************************************************
* drivewire.d - DriveWire Definitions File
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------
*   1    Started                                        BGP 03/04/03
*   2    Added DWGLOBS area                             BGP 09/12/27

                    nam       drivewire.d
                    ttl       DriveWire Definitions File

* Addresses
BBOUT               equ       $FF20
BBIN                equ       $FF22

 IFNE MEGAMINIMPI
MPIREG      equ    $FF7F        MPI Register
CTSMASK     equ    $F0          Get CTS
CTSSHIFT    equ    $4           Number of shifts for CTS
SCSMASK     equ    $0F          Get SCS

MMMSLT      equ    $05          MPI Slot(SCS) for MegaMiniMPI

* Uart Base Address
MMMU1A      equ    $FF40        Address for UART 1
MMMU2A      equ    $FF50        Address for UART 2
 IFEQ MMMUART-1
MMMUARTB    equ    MMMU1A
 ENDC
 IFEQ MMMUART-2
MMMUARTB    equ    MMMU2A
 ENDC
 IFNDEF MMMUARTB
 ERROR MMMUART not defined, build with -DMMMUART=1 or -DMMMUART-2
 ENDC

* 16550 Register offsets
THR         equ    $00          Transmit Holding Register
RHR         equ    $00          Recieve Holding Resister
IER         equ    $01          Interrupt Enable Register
IIR         equ    $02          Interrupt Identification Register
FCR         equ    $02          FIFO Control Register
LCR         equ    $03          Line Control Register
MCR         equ    $04          Modem Control Register
LSR         equ    $05          Line Status Register
MSR         equ    $06          Modem Status Register
SCR         equ    $07          Scratch Register
RST         equ    $08          Reset
DLL         equ    $00          Divisor Latch LSB
DLM         equ    $01          Divisor Latch MSB
DL16        equ    $0A          16-bit divisor window

* 16550 Line Control Register
LCR5BIT     equ    %00000000
LCR6BIT     equ    %00000001
LCR7BIT     equ    %00000010
LCR8BIT     equ    %00000011
LCRPARN     equ    %00000000
LCRPARE     equ    %00000100
LCRPARO     equ    %00001100
* BREAK
BRKEN       equ    %01000000
BRKDIS      equ    %10111111
* 16550 DLAB
DLABEN      equ    %10000000
DLABDIS     equ    %01111111

* 16550 Baud Rate Definitions
MMMB600        equ    3072
MMMB1200       equ    1536
MMMB2400       equ    768
MMMB4800       equ    384
MMMB9600       equ    192
MMMB19200      equ    96
MMMB38400      equ    48
MMMB57600      equ    32
MMMB115200     equ    16
MMMB230400     equ    8
MMMB460800     equ    4
MMMB921600     equ    2
MMMB1843200    equ    1

* 16550 Line Status Register Defs
LSRDR       equ    %00000001    LSR:Data Ready
LSRTHRE     equ    %00100000    LSR:Transmit Holding Register Empty
LSRTE       equ    %01000000    LSR:Transmit Empty

* 16550 Fifo Control Register
FCRFEN     equ    %00000001    Enable RX and TX FIFOs
FCRFDIS    equ    %11111110    Disable RX and TX FIFOs
FCRRXFCLR  equ    %00000010    Clear RX FIFO
FCRTXFCLR  equ    %00000100    Clear TX FIFO
FCRTRG1B   equ    %00000000    1-Byte FIFO Trigger
FCRTRG4B   equ    %01000000    4-Byte FIFO Trigger
FCRTRG8B   equ    %10000000    8-Byte FIFO Trigger
FCRTRG14B  equ    %11000000    14-Byte FIFO Trigger

* 16550 Modem Control Register
MCRDTREN   equ    %00000001    Enable DTR Output
MCRDTRDIS  equ    %11111110    Disable DTR Output
MCRRTSEN   equ    %00000010    Enable RTS Output
MCRRTSDIS  equ    %11111101    Disable RTS Output
MCRAFEEN   equ    %00100000    Enable Auto Flow Control
MCRAFEDIS  equ    %11011111    Disable Auto Flow Control
 ENDC



* Opcodes
OP_NAMEOBJ_MOUNT    equ       $01                 Named Object Mount
OP_NAMEOBJ_CREATE   equ       $02                 Named Object Create
OP_NOP              equ       $00                 No-Op
OP_RESET1           equ       $FE                 Server Reset
OP_RESET2           equ       $FF                 Server Reset
OP_RESET3           equ       $F8                 Server Reset
OP_DWINIT           equ       'Z                  DriveWire dw3 init/OS9 boot
OP_TIME             equ       '#                  Current time requested
OP_SETTIME          equ       '$                  Current time requested
OP_INIT             equ       'I                  Init routine called
OP_READ             equ       'R                  Read one sector
OP_REREAD           equ       'r                  Re-read one sector
OP_READEX           equ       'R+128              Read one sector
OP_REREADEX         equ       'r+128              Re-read one sector
OP_WRITE            equ       'W                  Write one sector
OP_REWRIT           equ       'w                  Re-write one sector
OP_GETSTA           equ       'G                  GetStat routine called
OP_SETSTA           equ       'S                  SetStat routine called
OP_TERM             equ       'T                  Term routine called
OP_SERINIT          equ       'E
OP_SERTERM          equ       'E+128

* Printer opcodes
OP_PRINT            equ       'P                  Print byte to the print buffer
OP_PRINTFLUSH       equ       'F                  Flush the server print buffer

* Serial opcodes
OP_SERREAD          equ       'C
OP_SERREADM         equ       'c
OP_SERWRITE         equ       'C+128
OP_SERGETSTAT       equ       'D
OP_SERSETSTAT       equ       'D+128

SS.Timer            equ       $81
SS.EE               equ       $82

* for dw vfm
OP_VFM              equ       'V+128

* WireBug opcodes (Server-initiated)
OP_WIREBUG_MODE     equ       'B
* WireBug opcodes (Server-initiated)
OP_WIREBUG_READREGS equ       'R                  Read the CoCo's registers
OP_WIREBUG_WRITEREGS equ       'r                  Write the CoCo's registers
OP_WIREBUG_READMEM  equ       'M                  Read the CoCo's memory
OP_WIREBUG_WRITEMEM equ       'm                  Write the CoCo's memory
OP_WIREBUG_GO       equ       'G                  Tell CoCo to get out of WireBug mode and continue execution

* VPort opcodes (CoCo-initiated)
OP_VPORT_READ       equ       'V
OP_VPORT_WRITE      equ       'v

* Error definitions
E_CRC               equ       $F3                 Same as NitrOS-9 E$CRC

* DW Globals Page Definitions (must be 256 bytes max)
DW.StatCnt          equ       15+16
                    org       $00
DW.StatTbl          rmb       DW.StatCnt          page pointers for terminal device static storage
DW.VIRQPkt          rmb       Vi.PkSz
DW.VIRQNOP          rmb       1


*****************************************
* dw3 subroutine module entry points
*
DW$Init             equ       0
DW$Read             equ       3
DW$Write            equ       6
DW$Term             equ       9



*****************************************
* SCF Multi Terminal Driver Definitions
*
                    org       V.SCF               ;V.SCF: free memory for driver to use
SSigID              rmb       1                   ;process ID for signal on data ready
SSigSg              rmb       1                   ;signal on data ready code
RxDatLen            rmb       1                   ;current length of data in Rx buffer
RxBufSiz            rmb       1                   ;Rx buffer size
RxBufEnd            rmb       2                   ;end of Rx buffer
RxBufGet            rmb       2                   ;Rx buffer output pointer
RxBufPut            rmb       2                   ;Rx buffer input pointer
RxGrab              rmb       1                   ;bytes to grab in multiread
RxBufPtr            rmb       2                   ;pointer to Rx buffer
RxBufDSz            equ       256-.               ;default Rx buffer gets remainder of page...
RxBuff              rmb       RxBufDSz            ;default Rx buffer
SCFDrvMemSz         equ       .

                    ENDC

