               ifne      ATARI.D-1
ATARI.D        set       1

********************************************************************
* AtariDefs - NitrOS-9 System Definitions for the Atari XE/XL
*
* This is a high level view of the Atari XE/XL memory map as setup by
* NitrOS-9.
*
*     $0000----> ================================== 
*               |                                  |
*               |      NitrOS-9 Globals/Stack      |
*               |                                  |
*     $0500---->|==================================|
*               |                                  |
*               |               Atari              |
*  $0500-$08BF  |           Screen Memory          |
*               |              (40x24)             |
*               |                                  |
*               |----------------------------------|
*  $08C0-$08FF  |         ANTIC Display List       |
*     $9000---->|----------------------------------|
*               |                                  |
*                 . . . . . . . . . . . . . . . . .
*               |                                  |
*               |   RAM available for allocation   |
*               |       by NitrOS-9 and Apps       |
*               |                                  |
*                 . . . . . . . . . . . . . . . . .
*               |                                  |
*     $C000---->|==================================|
*               |                                  |
*  $C000-$CFFF  |               ROM                |
*               |                                  |
*     $D000---->|==================================|
*               |                                  |
*               |   XEGS Memory Mapped I/O Region  |
*               |(may differ in location on others)|
*               |                                  |
*     $D800---->|==================================|
*               |                                  |
*  $D800-$FFFF  |               ROM                |
*               |                                  |
*               |==================================|
*
* Note that ROM above becomes RAM if booting from DriveWire.
*
* Atari Hardware is documented here:
*   http://user.xmission.com/~trevin/atari/pokey_regs.html
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2012/02/23  Boisy G. Pitre
* Started

               nam       AtariDefs
               ttl       NitrOS-9 System Definitions for the Atari XE/XL



**********************************
* Power Line Frequency Definitions
*
Hz50           equ       1                   Assemble clock for 50 hz power
Hz60           equ       2                   Assemble clock for 60 hz power
               IFNDEF    PwrLnFrq
PwrLnFrq       set       Hz60                Set to Appropriate freq
               ENDC


**********************************
* Ticks per second
*
               IFNDEF    TkPerSec
               ifeq      PwrLnFrq-Hz50
TkPerSec       set       50
               else      
TkPerSec       set       60
               endc      
               ENDC


*************************************************
*
* NitrOS-9 Level 1 Section
*
*************************************************

********************************
* Boot defs for NitrOS-9 Level 1
*
* These defs are not strictly for 'Boot', but are for booting the
* system.
*
Bt.Start       set       $8000
Bt.Size        EQU       $1080               Maximum size of bootfile
Bt.Track       EQU       $0000
Bt.Sec         EQU       0
HW.Page        set       $FF                 Device descriptor hardware page


********************************************************************
* NitrOS-9 Memory Definitions for the Atari XE/XL
*
* The Atari's support chips have certain alignment restrictions for
* things like screen memory, display lists and character maps.  For this
* reason, we reserve some low memory for the screen.
*
* Screen memory range is $0500-$08FF (1K).  Of that, 40*24 (960) bytes
* are for the screen buffer and the remaining 64 bytes are for the
* ANTIC's Display List
G.Cols         equ       40
G.Rows         equ       24
G.ScrStart     equ       $0500
G.ScrEnd       equ       G.ScrStart+(G.Cols*G.Rows)

* The Character Set must be aligned to a 4K address.  We can really only
* guarnatee that in the Krn module, which is always at the end of RAM.  So
* for now, the character set is located at $F800
G.CharSetAddr  equ       $F800

* POKEY requires shadow registers.  We allocate them in the kernel's DP
* (Yes, we are stealing an existing variable that is so old it should be
*  removed from os9defs)
D.IRQENShdw    equ       $02               ; was D.WDBtDr
D.SKCTLShdw    equ       $03               ; was D.SWPage

* The clock interrupt is driven by the unmaskable NMI.  Therefore,
* the rbdw3 driver uses the DWIOSEMA flag in the D.ATARIFLAGS field as
* a signal, setting it before doing an DW operation and clearing it after.
* The clock ISR checks if this flag is set, and, if so, defers the OP_TIME
* command to the server.
DWIOSEMA       equ       %10000000


********************************************************************
* Atari XE/XL Hardware Definitions
*
* These were lifted from the Atari OS disassembly, and represents all
* of the hardware registers available on the Atari XE/XL
*


*************************************************
**	CTIA/GTIA Address Equates
CTIA           equ       $D000               ;CTIA/GTIA area

*	Read/Write Addresses
CONSOL         equ       CTIA+$1F            ;console switches and speaker control

*	Read Addresses
M0PF           equ       CTIA+$00            ;missle 0 and playfield collision
M1PF           equ       CTIA+$01            ;missle 1 and playfield collision
M2PF           equ       CTIA+$02            ;missle 2 and playfield collision
M3PF           equ       CTIA+$03            ;missle 3 and playfield collision

P0PF           equ       CTIA+$04            ;player 0 and playfield collision
P1PF           equ       CTIA+$05            ;player 1 and playfield collision
P2PF           equ       CTIA+$06            ;player 2 and playfield collision
P3PF           equ       CTIA+$07            ;player 3 and playfield collision

M0PL           equ       CTIA+$08            ;missle 0 and player collision
M1PL           equ       CTIA+$09            ;missle 1 and player collision
M2PL           equ       CTIA+$0A            ;missle 2 and player collision
M3PL           equ       CTIA+$0B            ;missle 3 and player collision

P0PL           equ       CTIA+$0C            ;player 0 and player collision
P1PL           equ       CTIA+$0D            ;player 1 and player collision
P2PL           equ       CTIA+$0E            ;player 2 and player collision
P3PL           equ       CTIA+$0F            ;player 3 and player collision

TRIG0          equ       CTIA+$10            ;joystick trigger 0
TRIG1          equ       CTIA+$11            ;joystick trigger 1

TRIG2          equ       CTIA+$12            ;cartridge interlock
TRIG3          equ       CTIA+$13            ;ACMI module interlock

PAL            equ       CTIA+$14            ;PAL/NTSC indicator

* Write Addresses
HPOSP0         equ       CTIA+$00            ;player 0 horizontal position
HPOSP1         equ       CTIA+$01            ;player 1 horizontal position
HPOSP2         equ       CTIA+$02            ;player 2 horizontal position
HPOSP3         equ       CTIA+$03            ;player 3 horizontal position

HPOSM0         equ       CTIA+$04            ;missle 0 horizontal position
HPOSM1         equ       CTIA+$05            ;missle 1 horizontal position
HPOSM2         equ       CTIA+$06            ;missle 2 horizontal position
HPOSM3         equ       CTIA+$07            ;missle 3 horizontal position

SIZEP0         equ       CTIA+$08            ;player 0 size
SIZEP1         equ       CTIA+$09            ;player 1 size
SIZEP2         equ       CTIA+$0A            ;player 2 size
SIZEP3         equ       CTIA+$0B            ;player 3 size

SIZEM          equ       CTIA+$0C            ;missle sizes

GRAFP0         equ       CTIA+$0D            ;player 0 graphics
GRAFP1         equ       CTIA+$0E            ;player 1 graphics
GRAFP2         equ       CTIA+$0F            ;player 2 graphics
GRAFP3         equ       CTIA+$10            ;player 3 graphics

GRAFM          equ       CTIA+$11            ;missle graphics

COLPM0         equ       CTIA+$12            ;player-missle 0 color/luminance
COLPM1         equ       CTIA+$13            ;player-missle 1 color/luminance
COLPM2         equ       CTIA+$14            ;player-missle 2 color/luminance
COLPM3         equ       CTIA+$15            ;player-missle 3 color/luminance

COLPF0         equ       CTIA+$16            ;playfield 0 color/luminance
COLPF1         equ       CTIA+$17            ;playfield 1 color/luminance
COLPF2         equ       CTIA+$18            ;playfield 2 color/luminance
COLPF3         equ       CTIA+$19            ;playfield 3 color/luminance

COLBK          equ       CTIA+$1A            ;background color/luminance

PRIOR          equ       CTIA+$1B            ;priority select
VDELAY         equ       CTIA+$1C            ;vertical delay
GRACTL         equ       CTIA+$1D            ;graphic control
HITCLR         equ       CTIA+$1E            ;collision clear


*************************************************
** POKEY Address Equates
POKEY          equ       $D200               ;POKEY area

*Read Addresses
POT0           equ       POKEY+$00           ;potentiometer 0
POT1           equ       POKEY+$01           ;potentiometer 1
POT2           equ       POKEY+$02           ;potentiometer 2
POT3           equ       POKEY+$03           ;potentiometer 3
POT4           equ       POKEY+$04           ;potentiometer 4
POT5           equ       POKEY+$05           ;potentiometer 5
POT6           equ       POKEY+$06           ;potentiometer 6
POT7           equ       POKEY+$07           ;potentiometer 7

ALLPOT         equ       POKEY+$08           ;potentiometer port state
KBCODE         equ       POKEY+$09           ;keyboard code
RANDOM         equ       POKEY+$0A           ;random number generator
SERIN          equ       POKEY+$0D           ;serial port input
IRQST          equ       POKEY+$0E           ;IRQ interrupt status
IRQST.BREAKDOWN equ       %10000000
IRQST.KEYDOWN  equ       %01000000
IRQST.SERINRDY equ       %00100000
IRQST.SEROUTNEEDED equ       %00010000
IRQST.SEROUTDONE equ       %00001000
IRQST.TIMER4   equ       %00000100
IRQST.TIMER2   equ       %00000010
IRQST.TIMER1   equ       %00000001

SKSTAT         equ       POKEY+$0F           ;serial port and keyboard status

* Write Addresses
AUDF1          equ       POKEY+$00           ;channel 1 audio frequency
AUDC1          equ       POKEY+$01           ;channel 1 audio control

AUDF2          equ       POKEY+$02           ;channel 2 audio frequency
AUDC2          equ       POKEY+$03           ;channel 2 audio control

AUDF3          equ       POKEY+$04           ;channel 3 audio frequency
AUDC3          equ       POKEY+$05           ;channel 3 audio control

AUDF4          equ       POKEY+$06           ;channel 4 audio frequency
AUDC4          equ       POKEY+$07           ;channel 4 audio control

AUDCTL         equ       POKEY+$08           ;audio control
STIMER         equ       POKEY+$09           ;start timers
SKRES          equ       POKEY+$0A           ;reset SKSTAT status
POTGO          equ       POKEY+$0B           ;start potentiometer scan sequence
SEROUT         equ       POKEY+$0D           ;serial port output
IRQEN          equ       POKEY+$0E           ;IRQ interrupt enable
IRQEN.BREAKDOWN equ       %10000000
IRQEN.KEYDOWN  equ       %01000000
IRQEN.SERINRDY equ       %00100000
IRQEN.SEROUTNEEDED equ       %00010000
IRQEN.SEROUTDONE equ       %00001000
IRQEN.TIMER4   equ       %00000100
IRQEN.TIMER2   equ       %00000010
IRQEN.TIMER1   equ       %00000001

SKCTL          equ       POKEY+$0F           ;serial port and keyboard control
SKCTL.FORECEBREAK equ       %10000000
SKCTL.SERMODECTRLMASK equ       %01110000
SKCTL.SERMODEOUT equ       %00100000
SKCTL.SERMODEIN  equ       %00010000
SKCTL.TWOTONEMODE equ       %00001000
SKCTL.FASTPOTSCAN equ       %00000100
SKCTL.KEYBRDSCAN equ       %00000010
SKCTL.KEYDEBOUNCE equ       %00000001


*************************************************
** PIA Address Equates
PIA            equ       $D300               ;PIA area

* Read/Write Addresses
PORTA          equ       PIA+$00             ;port A direction register or jacks 0 and 1
PORTB          equ       PIA+$01             ;port B direction register or memory control

PACTL          equ       PIA+$02             ;port A control
PBCTL          equ       PIA+$03             ;port B control

* PIA bit assignments for XEGS:
* bit 7 0 = Self-Test switched in, but only if OS Rom is also switched in
* bit 6 0 = Missile Command @ $A000 but ony if Basic Rom is switched out
* 
* bit 1 0 = Basic switched in
* bit 0 1 = OS Rom switched in, opposite behaviour for this bit vs all the others relating to Rom. 


*************************************************
** ANTIC Address Equates
ANTIC          equ       $D400               ;ANTIC area

* Read Addresses
VCOUNT         equ       ANTIC+$0B           ;vertical line counter
PENH           equ       ANTIC+$0C           ;light pen horizontal position
PENV           equ       ANTIC+$0D           ;light pen vertical position
NMIST          equ       ANTIC+$0F           ;NMI interrupt status

* Write Addresses
DMACTL         equ       ANTIC+$00           ;DMA control
CHACTL         equ       ANTIC+$01           ;character control
DLISTL         equ       ANTIC+$02           ;low display list address
DLISTH         equ       ANTIC+$03           ;high disply list address
HSCROL         equ       ANTIC+$04           ;horizontal scroll
VSCROL         equ       ANTIC+$05           ;vertical scroll
PMBASE         equ       ANTIC+$07           ;player-missle base address
CHBASE         equ       ANTIC+$09           ;character base address
WSYNC          equ       ANTIC+$0A           ;wait for HBLANK synchronization
NMIEN          equ       ANTIC+$0E           ;NMI enable
NMIRES         equ       ANTIC+$0F           ;NMI interrupt status reset


*************************************************
** Display List Equates
ADLI           equ       $80                 ;display list interrupt
AVB            equ       $40                 ;vertical blank
ALMS           equ       $40                 ;set screen data address
AVSCR          equ       $20
AHSCR          equ       $10
AJMP           equ       $01                 ;jump
AEMPTY1        equ       $00
AEMPTY2        equ       $10
AEMPTY3        equ       $20
AEMPTY4        equ       $30
AEMPTY5        equ       $40
AEMPTY6        equ       $50
AEMPTY7        equ       $60
AEMPTY8        equ       $70
AMODE2         equ       $02
AMODE3         equ       $03
AMODE4         equ       $04
AMODE5         equ       $05
AMODE6         equ       $06
AMODE7         equ       $07
AMODE8         equ       $08
AMODE9         equ       $09
AMODEA         equ       $0A
AMODEB         equ       $0B
AMODEC         equ       $0C
AMODED         equ       $0D
AMODEE         equ       $0E
AMODEF         equ       $0F

               endc      
