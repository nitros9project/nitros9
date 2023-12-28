********************************************************************
* ROMInfo - NitrOS-9 ROM Relocation Code
*
* $Id: rominfo.asm,v 1.1 2004/04/05 03:34:39 boisy Exp $
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      1998/05/03  Boisy G. Pitre
* Created for the Coyota project and later productized.

                    nam       ROMInfo
                    ttl       NitrOS-9 ROM Relocation Code

                    ifp1
                    use       defsfile
                    endc

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       1

* Tested (for level 1) on XRoar
* The ROMPak must be autostarting by firing FIRQ
*
                    ifne      ROMPak
                    jmp       $C000+start+3       Offset 3 due to this line
PakOffs             equ       $C000-$8000
                    else
PakOffs             equ       0
                    endc

                    mod       eom,name,tylg,atrv,start,size

size                equ       .

name                fcs       /ROMInfo/
                    fcb       edition

start               equ       *

                    ifne      H6309
                    ldmd      #3                  go to native mode, FIRQ saves all registers
                    endc

                    ifgt      Level-1

* NitrOS-9 Level 2 - CoCo 3
* Bring the CoCo 3 to sanity
                    orcc      #IntMasks           disable FIRQ, IRQ
                    clr       $FFD9               go into fast mode
                    lda       #$0A                CC3 Mode, No MMU, 32K Int. ROM
                    sta       $FF90
                    clr       $FFDE               RAM/ROM mode (upper 16K ROM at $C000)

* Setup MMU
                    ldx       #DAT.Regs
                    leay      MMUTbl,pcr
                    ifne      H6309
                    ldw       #16
                    tfm       y+,x+
                    else
                    ldb       #16
MMULoop             lda       ,y+
                    sta       ,x+
                    decb
                    bne       MMULoop
                    endc

* Set up CoCo 3 Video Registers at $FF98-$FF9F
                    ldd       #$0000
                    std       $FF98
                    std       $FF9A
                    std       $FF9E
                    ldd       #$0FE0
                    std       $FF9C

* Initialize PIAs
                    ldx       #PIA1Base           RG - Initialize the PIA 1
                    ldd       #$FF34
                    clr       1,x
                    clr       3,x
                    deca
                    sta       ,x
                    lda       #$F8
                    sta       2,x
                    stb       1,x
                    stb       3,x
                    clr       2,x
                    lda       #$02
                    sta       ,x

                    lda       #$FF                RG - Initialize the PIA 0
                    ldx       #PIA0Base
                    clr       1,x
                    clr       3,x
                    clr       ,x
                    sta       2,x
                    stb       1,x
                    stb       3,x

                    tfr       b,dp
                    clr       2,x


                    lda       #$CA                RG - CC2 mode, MMU, constant DRAM, 32K internal ROM
                    sta       $FF90

                    bra       RelROM

* MMU
MMUTbl
                    fcb       $38,$39,$3A,$3B,$3C,$3D,$3E,$3F
                    fcb       $38,$39,$3A,$3B,$3C,$3D,$3E,$3F

* ROM relocation code -- copies the boot track into $2600 and JMPs to it
RelROM              ldx       #$EC00              src address (boot track in ROM)
                    ldy       #$2600              dst address (RAM)
                    ifne      H6309
                    ldw       #$1200
                    tfm       x+,y+
                    else
copyloop            ldd       ,x++                get 2 bytes from src
                    std       ,y++                put 2 bytes to dst
                    cmpx      #$EC00+$1200        at end?
                    blo       copyloop            nope, copy more...
                    endc
                    jmp       $2602               jump to OS rel code

                    else

* NitrOS-9 Level 1 - CoCo 1/2
                    ldx       #PIA1Base           PIA1
                    clr       -3,x                clear PIA0 Control Register A
                    clr       -1,x                clear PIA0 Control Register B
                    clr       -4,x                set PIA0 side A to input
                    ldd       #$FF34
                    sta       -2,x                set PIA0 side B to output
                    stb       -3,x                enable PIA0 peripheral reg, disable PIA0
                    stb       -1,x                MPU interrupts, set CA2, CA1 to outputs
                    clr       1,x                 $FF20 = DDR, motoroff
                    clr       3,x                 $FF22 = DDR, sound disabled
                    deca                          A = $FE after deca
                    sta       ,x                  bits 1-7 are outputs, bit 0 is input on PIA1 side A
                    lda       #$F8
                    sta       2,x                 bits 0-2 are inputs, bits 3-7 are outputs on B side
                    stb       1,x                 enable peripheral registers, disable PIA1 MPU
                    stb       3,x                 interrupts and set CA2, CB2 as outputs
                    clr       2,x                 set 6847 mode to alphanumeric
                    ldb       #$02
                    stb       ,x                  make RS-232 output marking
                    clrb
                    tfr       b,dp                B = 0
                    ldb       #$04
                    clr       -2,x
                    bitb      2,x

                    ifne      ROMPak
                    lda       #$36                inhibit ROMPak autostart FIRQ
                    else
                    lda       #$37
                    endc
                    sta       PIA1Base+3

                    lda       PIA0Base+3
                    ora       #$01
                    sta       PIA0Base+3

                    lda       PIA1Base+2
                    anda      #$07
                    sta       PIA1Base+2

* VDG Mode
                    sta       $FFC0
                    sta       $FFC2
                    sta       $FFC4

* 64K DRAM (M0=0, M1=1)
                    sta       $FFDA               RESET M0
                    sta       $FFDD               SET   M1

* ROM relocation code -- copies the boot track into $2600
RelROM              ldx       #$AE00+PakOffs      src address (ROM)
                    ldy       #$2600              dst address (RAM)
                    ifne      H6309
                    ldw       #$1200
                    tfm       x+,y+
                    else
copyloop            ldd       ,x++                get 2 bytes from src
                    std       ,y++                put 2 bytes to dst
                    cmpx      #$AE00+$1200+PakOffs at end?
                    bne       copyloop            nope, copy more...
                    endc
* BOOT relocation code -- copies the bootfile into $2600+$1200
RelBOOT             ldx       #$8000+PakOffs
                    ldy       #$2600+$1200
                    ifne      H6309
                    ldw       #$2E00
                    tfm       x+,y+
                    else
cpy2loop            ldd       ,x++
                    std       ,y++
                    cmpx      #$8000+$2E00+PakOffs
                    blo       cpy2loop
                    endc
                    jmp       $2602               jump to OS rel code

                    endc

                    emod
eom                 equ       *
                    end

