********************************************************************
* fnxinfo - Foenix F256 information utility
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2024/06/28  Boisy Gene Pitre
* Started.

                    section   bss
bootpath            rmb       2         the bootfile's absolute path pointer
diskpath            rmb       1         path to disk
krnentry            rmb       2         address of kernel entry point
bootaddr            rmb       2         bootfile load address
bootsize            rmb       2         bootfile size in bytes
bootpages           rmb       1         # of 256-byte pages to accommodate the bootfile
bootblocks          rmb       1         # of 8K blocks to accommodate the bootfile
startblock          rmb       1         the starting block number to load the bootfile into
sectorbuffer        rmb       256       holds sectors read from disk
                    endsect

                    section   code

BuildDate           dtb

**********************************************************
* Entry Point
*
* Here's how registers are set when this process is forked:
*
*   +-----------------+  <--  Y          (highest address)
*   !   Parameter     !
*   !     Area        !
*   +-----------------+  <-- X, SP
*   !   Data Area     !
*   +-----------------+
*   !   Direct Page   !
*   +-----------------+  <-- U, DP       (lowest address)
*
*   B = parameter area size
*  PC = module entry point abs. address
*  CC = F=0, I=0, others undefined
*
* The start of the program is here.
**********************************************************
__start
                    bsr       PrintMBoardInfo
                    clrb
                    os9       F$Exit
                    
* F256 identity routine
* Exit: A = $02 (F256K), $12 (F256 Jr.), $1A (F256 Jr2), $16 (F256K2)
F256Type            pshs      x
                    ldx       #SYS0
                    lda       7,x
                    puls      x,pc

* F256 motherboard identity routine
* Exit: D = Two-byte ASCII PCB ID
F256MBType          pshs      x
                    ldx       #SYS0
                    ldd       8,x
                    puls      x,pc

PrintMBoardInfo     bsr       F256Type
                    cmpa      #$02
                    bne       isItF256K@
f256k@              lbsr      PRINTS
                    fcc       "F256 Jr"
                    fcb       $0
                    bra       cont@
isItF256K@          cmpa      #$12
                    bne       isitF256JrJr@
                    lbsr      PRINTS
                    fcc       "F256K"
                    fcb       $0
                    bra       cont@
isitF256JrJr@       cmpa      #$1A
                    bne       isitF256K2@
                    lbsr      PRINTS
                    fcc       "F256 Jr2"
                    fcb       $0
                    bra       cont@
isitF256K2@         cmpa      #$16
                    bne       cont@
                    lbsr      PRINTS
                    fcc       "F256K2"
                    fcb       $0
cont@               lbsr      PRINTS
                    fcc       " - PCBID "
                    fcb       $0
                    bsr       F256MBType
                    exg       a,b
                    lbsr      PUTC
                    exg       a,b
                    lbsr      PUTC
                    lbsr      PRINTS
                    fcc       " - TinyVicky "
                    fcb       $0
                    ldx       #SYS0
                    lda       $0F,x
                    bsr       PutBCD
                    lda       $0E,x
                    bsr       PutBCD
                    lda       $0D,x
                    bsr       PutBCD
                    lda       $0C,x
                    bsr       PutBCD
                    lda       $0B,x
                    bsr       PutBCD
                    lda       $0A,x
                    bsr       PutBCD
                    
                    lda       $FFAF               get MMU slot 7
                    cmpa      #$07                is it 7? (meaning this is loaded from RAM)
                    beq       ram@                branch if so
                    lbsr      PRINTS
                    fcc       / (Flash Mode)/
                    fcb       C$CR
                    fcb       C$CR
                    fcb       $0
                    rts
ram@                lbsr      PRINTS
                    fcc       / (RAM Mode)/
                    fcb       C$CR
                    fcb       C$CR
                    fcb       $0
                    rts
                    



next@               lbsr      PUTS                print it

                    rts
PutBCD                    
                    bsr       BCD2ASCII
                    exg       a,b
                    lbsr      PUTC
                    exg       a,b
                    lbsr      PUTC
                    rts

* Entry:
*   A = BCD byte
*
* Exit:
*   A = ASCII of upper 4 bits of BCD in A
*   B = ASCII of lower 4 bits of BCD in A
BCD2ASCII           pshs      a
                    anda      #$F0
                    lsra
                    lsra
                    lsra
                    lsra
                    adda      #'0
                    cmpa      #$39
                    ble       lo@
                    adda      #$07
lo@                 puls      b
                    andb      #$0F
                    addb      #'0
                    cmpb      #$39
                    ble       ex@
                    addb      #$07
ex@                 rts

                    endsect   0
