*******************************************************************
* REL - Relocation routine
*
* $Id$
*
* This module MUST occupy the last 256 bytes of ROM ($FF00-$FFFF)
* due to the way the Corsham board is designed.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2017/05/08  Boisy G. Pitre
* Created for Corsham 6809
*

                    nam       REL
                    ttl       Relocation routine

                    ifp1
                    use       defsfile
                    endc

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $05
edition             set       5

Begin               mod       eom,name,tylg,atrv,start,size

                    org       0
size                equ       .                   REL doesn't require any memory

name                fcs       /REL/
                    fcb       edition

*************************************************************************
* Entry point for Level 1

Start
* Initialize UART
                    ldx       #UARTBase           POINT TO CONTROL PORT ADDRESS
                    lda       #3                  RESET ACIA PORT CODE
                    sta       ,x                  STORE IN CONTROL REGISTER
                    lda       #$11                SET 8 DATA, 2 STOP AN 0 PARITY
                    sta       ,x                  STORE IN CONTROL REGISTER
                    tst       1,x                 ANYTHING IN DATA REGISTER?

* INITIALIZE DAT RAM --- LOADS $F-$0 IN LOCATIONS $0-$F
* OF DAT RAM, THUS STORING COMPLEMENT OF MSB OF ADDRESS
* IN THE DAT RAM. THE COMPLEMENT IS REQUIRED BECAUSE THE
* OUTPUT OF IC11, A 74S189, IS THE INVERSE OF THE DATA
* STORED IN IT.
;
; Also note that the upper nibble contains the non-inverted
; bank number for extended addressing.  This loop sets up all
; translations to point to block 0, which is good.
;
InitDAT             ldx       #DATREGS            point to DAT RAM
                    lda       #$0F                get complement of zero
datlp@              sta       ,x+                 STORE & POINT TO NEXT RAM LOCATION
                    deca                          GET COMP. VALUE FOR NEXT LOCATION
                    bne       datlp@              ALL 16 LOCATIONS INITIALIZED ?


* NOTE: IX NOW CONTAINS $0000, DAT RAM IS NO LONGER
*       ADDRESSED, AND LOGICAL ADDRESSES NOW EQUAL
*       PHYSICAL ADDRESSES.
TSTPAT              equ       $55AA               TEST PATTERN

                    lda       #$F0
                    sta       ,x                  STORE $F0 AT $FFFF
                    ldx       #$D0A0              ASSUME RAM TO BE AT $D000-$DFFF
                    ldy       #TSTPAT             LOAD TEST DATA PATTERN INTO "Y"
tstram@             ldu       ,x                  SAVE DATA FROM TEST LOCATION
                    sty       ,x                  STORE TEST PATTERN AT $D0A0
                    cmpy      ,x                  IS THERE RAM AT THIS LOCATION ?
                    beq       CNVADR              IF MATCH THERE'S RAM, SO SKIP
                    leax      -$1000,x            ELSE POINT 4K LOWER
                    cmpx      #$F0A0              DECREMENTED PAST ZER0 YET ?
                    bne       tstram@             IF NOT CONTINUE TESTING FOR RAM
                    bra       InitDAT             ELSE START ALL OVER AGAIN

* THE FOLLOWING CODE STORES THE COMPLEMENT OF
* THE MS CHARACTER OF THE FOUR CHARACTER HEX
* ADDRESS OF THE FIRST 4K BLOCK OF RAM LOCATED
* BY THE ROUTINE "TSTRAM" INTO THE DAT RAM. IT
* IS STORED IN RAM IN THE LOCATION THAT IS
* ADDRESSED WHEN THE PROCESSOR ADDRESS IS $D---,
* THUS IF THE FIRST 4K BLOCK OF RAM IS FOUND
* WHEN TESTING LOCATION $70A0, MEANING THERE
* IS NO RAM PHYSICALLY ADDRESSED IN THE RANGE
* $8000-$DFFF, THEN THE COMPLEMENT OF THE
* "7" IN THE $70A0 WILL BE STORED IN
* THE DAT RAM. THUS WHEN THE PROCESSOR OUTPUTS
* AN ADDRESS OF $D---, THE DAT RAM WILL RESPOND
* BY RECOMPLEMENTING THE "7" AND OUTPUTTING THE
* 7 ONTO THE A12-A15 ADDRESS LINES. THUS THE
* RAM THAT IS PHYSICALLY ADDRESSED AT $7---
* WILL RESPOND AND APPEAR TO THE 6809 THAT IT
* IS AT $D--- SINCE THAT IS THE ADDRESS THE
* 6809 WILL BE OUTPUTING WHEN THAT 4K BLOCK
* OF RAM RESPONDS.


CNVADR              stu       ,x                  RESTORE DATA AT TEST LOCATION
                    tfr       x,d                 PUT ADDR. OF PRESENT 4K BLOCK IN D
                    coma                          COMPLEMENT MSB OF THAT ADDRESS
                    lsra                          PUT MS 4 BITS OF ADDRESS IN
                    lsra                          LOCATION D0-D3 TO ALLOW STORING
                    lsra                          IT IN THE DYNAMIC ADDRESS
                    lsra                          TRANSLATION RAM.
                    sta       $FFFD               STORE XLATION FACTOR IN DAT "D"


* THE FOLLOWING CHECKS TO FIND THE REAL PHYSICAL ADDRESSES
* OF ALL 4K BLKS OF RAM IN THE SYSTEM. WHEN EACH 4K BLK
* OF RAM IS LOCATED, THE COMPLEMENT OF IT'S REAL ADDRESS
* IS THEN STORED IN A "LOGICAL" TO "REAL" ADDRESS XLATION
* TABLE THAT IS BUILT FROM $DFD0 TO $DFDF. FOR EXAMPLE IF
* THE SYSTEM HAS RAM THAT IS PHYSICALLY LOCATED (WIRED TO
* RESPOND) AT THE HEX LOCATIONS $0--- THRU $F---....

*  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
* 4K 4K 4K 4K 4K 4K 4K 4K -- 4K 4K 4K 4K -- -- --

* ....FOR A TOTAL OF 48K OF RAM, THEN THE TRANSLATION TABLE
* CREATED FROM $DFD0 TO $DFDF WILL CONSIST OF THE FOLLOWING....

*  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
* 0F 0E 0D 0C 0B 0A 09 08 06 05 00 00 04 03 F1 F0


* HERE WE SEE THE LOGICAL ADDRESSES OF MEMORY FROM $0000-$7FFF
* HAVE NOT BEEN SELECTED FOR RELOCATION SO THAT THEIR PHYSICAL
* ADDRESS WILL = THEIR LOGICAL ADDRESS; HOWEVER, THE 4K BLOCK
* PHYSICALLY AT $9000 WILL HAVE ITS ADDRESS TRANSLATED SO THAT
* IT WILL LOGICALLY RESPOND AT $8000. LIKEWISE $A,$B, AND $C000
* WILL BE TRANSLATED TO RESPOND TO $9000,$C000, AND $D000
* RESPECTIVELY. THE USER SYSTEM WILL LOGICALLY APPEAR TO HAVE
* MEMORY ADDRESSED AS FOLLOWS....

*  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
* 4K 4K 4K 4K 4K 4K 4K 4K 4K 4K -- -- 4K 4K -- --


                    ldy       #LRARAM             ;POINT TO LOGICAL/REAL ADDR. TABLE
                    sta       13,y                ;STORE $D--- XLATION FACTOR AT $DFDD
                    clr       14,y                ;CLEAR $DFDE
                    lda       #$F0                ;DESTINED FOR IC8 AN MEM EXPANSION ?
                    sta       15,y                ;STORE AT $DFDF
                    lda       #$0C                ;PRESET NUMBER OF BYTES TO CLEAR
CLRLRT              clr       a,y                 ;CLEAR $DFDC THRU $DFD0
                    deca                          ;. 1 FROM BYTES LEFT TO CLEAR
                    bpl       CLRLRT              ;CONTINUE IF NOT DONE CLEARING
FNDRAM              leax      -$1000,x            ;POINT TO NEXT LOWER 4K OF RAM
                    cmpx      #$F0A0              ;TEST FOR DECREMENT PAST ZERO
                    beq       FINTAB              ;SKIP IF FINISHED
                    ldu       ,x                  ;SAVE DATA AT CURRENT TEST LOCATION
                    ldy       #TSTPAT             ;LOAD TEST DATA PATTERN INTO Y REG.
                    sty       ,x                  ;STORE TEST PATT. INTO RAM TEST LOC.
                    cmpy      ,x                  ;VERIFY RAM AT TEST LOCATION
                    bne       FNDRAM              ;IF NO RAM GO LOOK 4K LOWER
                    stu       ,x                  ;ELSE RESTORE DATA TO TEST LOCATION
                    ldy       #LRARAM             ;POINT TO LOGICAL/REAL ADDR. TABLE
                    tfr       x,d                 ;PUT ADDR. OF PRESENT 4K BLOCK IN D
                    lsra                          ;PUT MS 4 BITS OF ADDR. IN LOC. D0-D3
                    lsra                          ;TO ALLOW STORING IT IN THE DAT RAM.
                    lsra
                    lsra
                    tfr       a,b                 ;SAVE OFFSET INTO LRARAM TABLE
                    eora      #$0F                ;INVERT MSB OF ADDR. OF CURRENT 4K BLK
                    sta       b,y                 ;SAVE TRANSLATION FACTOR IN LRARAM TABLE
                    bra       FNDRAM              ;GO TRANSLATE ADDR. OF NEXT 4K BLK
FINTAB              lda       #$F1                ;DESTINED FOR IC8 AND MEM EXPANSION ?
                    ldy       #LRARAM             ;POINT TO LRARAM TABLE
                    sta       14,y                ;STORE $F1 AT $DFCE

* THE FOLLOWING CHECKS TO SEE IF THERE IS A 4K BLK OF
* RAM LOCATED AT $C000-$CFFF. IF NONE THERE IT LOCATES
* THE NEXT LOWER 4K BLK AN XLATES ITS ADDR SO IT
* LOGICALLY RESPONDS TO THE ADDRESS $C---.


                    lda       #$0C                ;PRESET NUMBER HEX "C"
FINDC               ldb       a,y                 ;GET ENTRY FROM LRARAM TABLE
                    bne       FOUNDC              ;BRANCH IF RAM THIS PHYSICAL ADDR.
                    deca                          ;ELSE POINT 4K LOWER
                    bpl       FINDC               ;GO TRY AGAIN
                    bra       XFERTF
FOUNDC              clr       a,y                 ;CLR XLATION FACTOR OF 4K BLOCK FOUND
                    stb       $C,y                ;GIVE IT XLATION FACTOR MOVING IT TO $C---

* THE FOLLOWING CODE ADJUSTS THE TRANSLATION
* FACTORS SUCH THAT ALL REMAINING RAM WILL
* RESPOND TO A CONTIGUOUS BLOCK OF LOGICAL
* ADDRESSES FROM $0000 AND UP....

                    clra                          ;START AT ZERO
                    tfr       y,x                 ;START POINTER "X" START OF "LRARAM" TABLE.
COMPRS              ldb       a,y                 ;GET ENTRY FROM "LRARAM" TABLE
                    beq       PNTNXT              ;IF IT'S ZER0 SKIP
                    clr       a,y                 ;ELSE ERASE FROM TABLE
                    stb       ,x+                 ;AND ENTER ABOVE LAST ENTRY- BUMP
PNTNXT              inca                          ;GET OFFSET TO NEXT ENTRY
                    cmpa      #$0C                ;LAST ENTRY YET ?
                    blt       COMPRS

* THE FOLLOWING CODE TRANSFER THE TRANSLATION
* FACTORS FROM THE LRARAM TABLE TO IC11 ON
* THE MP-09 CPU CARD.

XFERTF              ldx       #DATREGS            ;POINT TO DAT RAM
                    ldb       #$10                ;GET NO. OF BYTES TO MOVE
FETCH               lda       ,y+                 ;GET BYTE AND POINT TO NEXT
                    sta       ,x+                 ;POKE XLATION FACTOR IN IC11
                    decb                          ;SUB 1 FROM BYTES TO MOVE
                    bne       FETCH               ;CONTINUE UNTIL 16 MOVED

* Initialization is complete at this point
* Jump into Kernel at $F011
                    jmp       $F011               jump into Krn

* Entry
* A = character to output
CharOut             pshs      b                   SAVE A ACCUM AND IX
fetch@              ldb       UARTBase            FETCH PORT STATUS
                    bitb      #2                  TEST TDRE, OK TO XMIT ?
                    beq       fetch@              IF NOT LOOP UNTIL RDY
                    sta       UARTBase+1          XMIT CHAR.
                    puls      b,pc                restore and leave

* Entry
* X = nil terminated string
StringOut           pshs      a,x
loop@               lda       ,x+
                    beq       done@
                    bsr       CharOut
                    bra       loop@
done@               puls      a,x,pc

                    fill      $39,$100-*-EOMSize

EOMTop              equ       *

* I/O routines jump table (known locations)
LFFE9               fdb       $FF00+CharOut
LFFEB               fdb       $FF00+StringOut

                    emod
eom                 equ       *

                    fdb       $0000
Vectors             fdb       $0100               SWI3
                    fdb       $0103               SWI2
                    fdb       $010F               FIRQ
                    fdb       $010C               IRQ
                    fdb       $0106               SWI
                    fdb       $0109               NMI
                    fdb       $FF00+Start         start of REL

EOMSize             equ       *-EOMTop

                    end
