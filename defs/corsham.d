               ifne      CORSHAM.D-1
CORSHAM.D      set       1

********************************************************************
* corsham.d - NitrOS-9 System Definitions for the Corsham 6809
*
* This is a high level view of the Corsham 6809 memory map as setup by
* NitrOS-9.
*
*     $0000----> ==================================
*               |                                  |
*               |      NitrOS-9 Globals/Stack      |
*               |                                  |
*     $0500---->|==================================|
*               |                                  |
*                 . . . . . . . . . . . . . . . . .
*               |                                  |
*               |   RAM available for allocation   |
*               |       by NitrOS-9 and Apps       |
*               |                                  |
*                 . . . . . . . . . . . . . . . . .
*               |                                  |
*     $E000---->|==================================|
*               |                                  |
*  $E000-$EFFF  |    Memory Mapped I/O Region      |
*               |                                  |
*     $F000---->|==================================|
*               |                                  |
*  $F000-$FFFF  |               ROM                |
*               |                                  |
*               |==================================|
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2017/04/29  Boisy G. Pitre
* Started

               nam       corsham.d
               ttl       NitrOS-9 System Definitions for the Corsham 6809

**********************************
* Ticks per second
*
               IFNDEF    TkPerSec
TkPerSec       SET       50
               ENDC


*************************************************
*
* NitrOS-9 Level 1 Section
*
*************************************************

HW.Page        set       $E0                 Device descriptor hardware page


********************************************************************
* NitrOS-9 Memory Definitions for the Corsham 6809
*

********************************************************************
* Corsham 6809 Hardware Definitions
*

DATREGS		equ	$FFF0	DAT RAM CHIP


S.CharOut		EQU		$FFE9
S.StringOut	EQU		$FFEB

PSETWR         equ    $F006                         ; PIA Set Write Mode
PSETRE         equ    $F009                         ; PIA Set Read Mode
PREAD          equ    $F00F                         ; PIA Read Byte
PWRITE         equ    $F00C                         ; PIA Write Byte
CSETIMR        equ    $1E                           ; Set Timer Command to Arduino
RACK           equ    $82                           ; Command Ack from Arduino

CONSLOT		equ	1	console slot
SDSLOT		equ	6	SD card slot
SLOTSIZ		equ	16
IOBASE		equ	$E000

;----------------------------------------------------
;
; Which slot the parallel board is in.  This needs to
; be set for the system in use.  As long as the user
; programs only call functions in here, no other
; file/application should know which slot the board
; is in.

PIA0Base		equ	SDSLOT*SLOTSIZ+IOBASE
UARTBase		equ	CONSLOT*SLOTSIZ+IOBASE

PIAREGA         equ     0         ;data reg A
PIADDRA         equ     0         ;data dir reg A
PIACTLA         equ     1       ;control reg A
PIAREGB         equ     2       ;data reg B
PIADDRB         equ     2       ;data dir reg B
PIACTLB         equ     3       ;control reg B

;----------------------------------------------------
; Bits in the B register
;
DIRECTION       equ     %00000001
PSTROBE         equ     %00000010
ACK             equ     %00000100
;

		org	$DFC0
C.STACK		RMB	2	TOP OF INTERNAL STACK / USER VECTOR
C.SWI3		RMB	2	SOFTWARE INTERRUPT VECTOR #3
C.SWI2		RMB	2	SOFTWARE INTERRUPT VECTOR #2
C.FIRQ		RMB	2	FAST INTERRUPT VECTOR
C.IRQ		RMB	2	INTERRUPT VECTOR
C.SWI		RMB	2	SOFTWARE INTERRUPT VECTOR
SVCVO		RMB	2	SUPERVISOR CALL VECTOR ORGIN
SVCVL		RMB	2	SUPERVISOR CALL VECTOR LIMIT
LRARAM		RMB	16	LRA ADDRESSES

Bt.Start	EQU	$F000	Start address of the boot ROM in memory
Bt.Size		EQU	$1000
Bt.Track	EQU	0
Bt.Sec  	EQU	0

;*****************************************************
; Parallel port protocol
;
; This is the header file for making applications
; compliant with The Remote Disk Protocol Guide which
; is on the Corsham Technologies web page somewhere:
;
;    www.corshamtech.com
;
; This was updated 06/13/2015 to be compliant with the
; official specification, so the opcode values changed.
;
;=====================================================
; Commands from host to Arduino
;
PC_GET_VERSION	equ	$01
PC_PING		equ	$05	;ping Arduino
PC_LED_CONTROL	equ	$06	;LED control
PC_GET_CLOCK	equ	$07	;Get RTC
PC_SET_CLOCK	equ	$08	;Set RTC
PC_GET_DIR	equ	$10	;Get directory
PC_GET_MOUNTED	equ	$11	;Get mounted drive list
PC_MOUNT	equ	$12	;Mount drive
PC_UNMOUNT	equ	$13	;Unmount drive
PC_GET_STATUS	equ	$14	;Get status for one drive
PC_DONE		equ	$15	;Stop data
PC_ABORT	equ	PC_DONE
PC_READ_FILE	equ	$16	;Read regular file (non-DSK)
PC_READ_BYTES	equ	$17	;Read sequential bytes
PC_RD_SECTOR	equ	$18	;Read FLEX sector
PC_WR_SECTOR	equ	$19	;Write FLEX sector
PC_GET_MAX	equ	$1a	;Get maximum drives
PC_WRITE_FILE   equ	$1b	;Open file for writing
PC_WRITE_BYTES	equ	$1c	;Data to be written
PC_SAVE_CONFIG	equ	$1d	;Save current config data to file
PC_SET_TIMER	equ	$1e	;Turn on/off RTC timer
PC_READ_LONG	equ	$1f	;read sector using long sector num
PC_WRITE_LONG	equ	$20	;write sector using long sec number
;
;=====================================================
; Responses from Arduino to host
;
PR_VERSION_INFO	equ	$81	;Contains version information
PR_ACK		equ	$82	;ACK (no additional information)
PR_NAK		equ	$83	;NAK - one status byte follows
PR_PONG		equ	$85	;Reply to a ping
PR_CLOCK_DATA	equ	$87	;Clock data
PR_DIR_ENTRY	equ	$90	;Directory entry
PR_DIR_END	equ	$91	;End of directory entries
PR_FILE_DATA	equ	$92	;File data
PR_STATUS	equ	$93	;Drive status
PR_SECTOR_DATA	equ	$94	;Sector data
PR_MOUNT_INFO	equ	$95	;Mount entry
PR_MAX_DRIVES	equ	$96	;Maximum number of drives
;
;=====================================================
; Error codes for NAK events
;
ERR_NONE	equ	00
ERR_NOT_MOUNTED	equ	10
ERR_MOUNTED	equ	11
ERR_NOT_FOUND	equ	12
ERR_READ_ONLY	equ	13
ERR_BAD_DRIVE	equ	14
ERR_BAD_TRACK	equ	15
ERR_BAD_SECTOR	equ	16
ERR_READ_ERROR	equ	17

;=====================================================
; PIO subroutine module offsets
;
		org	0
PIO$Init		rmb	3
PIO$Read		rmb	3
PIO$Write		rmb	3
PIO$Term		rmb	3

               endc
