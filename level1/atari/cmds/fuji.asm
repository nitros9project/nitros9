****************************************
* Sample kick application for Liber809
* James Wilkinson
* v.2 - March 28, 2012
****************************************

                    nam       Fuji
                    ttl       Fuji Demo

                    ifp1
                    use       defsfile
                    use       atari.d
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       0

* Here are some tweakable options
STACKSZ             set       128                 estimated stack size in bytes
PARMSZ              set       256                 estimated parameter size in bytes

                    mod       eom,name,tylg,atrv,start,size

GRSIZE              equ       40                  ;memory per graphics mode line
GRCOUNT             equ       80                  ;total graphics mode lines
TXTSIZE             equ       40                  ;memory per text mode line
TXTCOUNT            equ       4                   ;total lines of text

CLR0                equ       $10                 ;Fuji
CLR1                equ       $0E                 ;text foreground
CLR2                equ       $00                 ;text background

VOICES              equ       2                   ;number of sound channels to use

                    org       0
CharRead            rmb       1
OrgNMI              rmb       2
Clr0Next            rmb       1
SndAddrs            rmb       VOICES*2
SndDurs             rmb       VOICES
* Finally the stack for any PSHS/PULS/BSR/LBSRs that we might do
                    rmb       STACKSZ+PARMSZ
size                equ       .

name                fcs       /Merge/
                    fcb       edition             change to 6, as merge 5 has problems?


* Screen display areas
                    use       fujimem.asm

* Music data
                    use       fujitune.asm


* Custom display list:
* - 3 empty mode lines, to prevent overscan
* - 2 mode lines of ANTIC mode $2 (text)
* - 80 mode lines of ANTIC mode $D (graphics) with display list interrupts
* - 2 mode lines of ANTIC mode $2 (text)
DList               fcb       AEMPTY8,AEMPTY8,AEMPTY8
                    fcb       ALMS+AMODE2
DListT1             fdbs      FujiTxt1
                    fcb       AMODE2
                    fcb       ALMS+ADLI+AMODED
DListM              fdbs      FujiMem
                    fill      ADLI+AMODED,$4e
                    fcb       AMODED
                    fcb       ALMS+AMODE2
DListT2             fdbs      FujiTxt2
                    fcb       AMODE2
                    fcb       AVB+AJMP
DListPtr            fdbs      DList

****************************************
* Main entry point

start               equ       *
* Initialize POKEY sound
InitPokey           lda       #$03
                    sta       SKCTL               ;set POKEY 2-tone mode
                    lda       #$00
                    sta       AUDCTL              ;set POKEY clock base to 15 KHz
                    lbsr      InitSnd

* Initialize GTIA color registers
InitClr             lda       #CLR0
                    sta       COLPF0
                    lda       #CLR1
                    sta       COLPF1
                    lda       #CLR2
                    sta       COLPF2

* Convert static text, using simplified conversion to ANTIC screen characters
InitTxt             leax      FujiTxt1,pcr
                    ldy       #TXTSIZE*TXTCOUNT
loop@               lda       ,x
                    suba      #$20
                    sta       ,x+
                    leay      -1,y
                    bne       loop@

* Set up custom display list
InitDL              leax      DList,pcr
                    tfr       x,d
                    exg       a,b
                    std       DLISTL              ;point ANTIC to custom display list
                    std       DListPtr,pcr

                    leax      FujiTxt1,pcr
                    tfr       x,d
                    exg       a,b
                    std       DListT1,pcr

                    leax      FujiMem,pcr
                    tfr       x,d
                    exg       a,b
                    std       DListM,pcr

                    leax      FujiTxt2,pcr
                    tfr       x,d
                    exg       a,b
                    std       DListT2,pcr

* Set up and enable non-maskable interrupt
InitNMI             leax      NMIVect,pcr
                    ldy       $FFFC
                    sty       OrgNMI,u
                    stx       $FFFC               ;point 6809 to custom interrupt vector
                    lda       #$C0
                    sta       NMIEN               ;enable both display list and vertical blank interrupts

* Read one character
                    clra
                    ldy       #$0001
                    leax      CharRead,u
                    os9       I$Read

* Now awake, time to quit
                    lda       #$00
                    sta       NMIEN
                    ldy       OrgNMI,u
                    sty       D.NMI
                    ldd       #$00F8
                    std       DLISTL

                    clrb
                    os9       F$Exit

* Initialize sound pointers
InitSnd
                    ldx       #SndAddrs
                    leay      Track0,pcr          ;initialize pointer to track 0
                    sty       ,x++
                    leay      Track1,pcr          ;initialize pointer to track 1
                    sty       ,x
                    rts

* Single vector to handle all non-maskable interrupts
NMIVect             pshs      d,x,y               ;save register used during interrupt
                    lda       NMIST
DLITest@            anda      #%10000000          ;was interrupt generated by display list?
                    beq       VBITest@
                    bsr       DLIVect             ;if so, run DLI routine
VBITest@            lda       NMIST
                    anda      #%01000000          ;was interrupt generated by vertical blank?
                    beq       done@
                    bsr       VBIVect             ;if so, run VBI routine
done@               puls      d,x,y               ;restore register
                    rti

DLIVect             lda       Clr0Next,u          ;get color for next mode line
                    adda      #2                  ;adjust for rainbow effect
                    cmpa      #CLR0               ;skip grey tones
                    bhi       dcycle@
                    adda      #CLR0
dcycle@             sta       Clr0Next,u          ;save shadow for next interrupt
                    sta       WSYNC               ;wait for horizontal sync
                    sta       COLPF0              ;update GTIA color register
                    rts

VBIVect             bsr       SndVect
                    lda       Clr0Next,u          ;get color for next mode line
                    cmpa      #$af                ;adjust for skipped grey tones
                    bhi       vcycle@
                    suba      #CLR0
vcycle@             suba      #$a1                ;reset color for top line of Fuji
                    sta       Clr0Next,u          ;save shadow
                    bsr       DLIVect             ;chain to DLI routine
                    rts

SndVect             ldd       #$0000
                    tfr       d,x                 ;start with voice #0
                    rts

PlayVoice           lda       SndDurs,x
                    bne       UpdateDur           ;skip work if same note keeps playing

LoadNote            tfr       x,d
                    lslb
                    tfr       d,x
                    ldy       SndAddrs,x          ;load from word offset for current note
                    lsrb
                    tfr       d,x
                    leay      2,y
                    lda       ,y
                    sta       SndDurs,x           ;save duration
                    ora       ,y
                    bne       PlayNote
                    pshs      x
                    bsr       InitSnd             ;loop back to beginning at end of tune
                    puls      x
                    bra       LoadNote

PlayNote            leay      -2,y
                    lda       ,y+
                    pshs      a                   ;save frequency
                    lda       ,y
                    pshs      a                   ;save volume
                    tfr       x,d
                    lslb
                    tfr       d,y                 ;y = x * 2
                    puls      a                   ;restore volume
                    adda      #$a0
                    sta       AUDC1,y             ;set pure tone and volume
                    puls      a                   ;restore frequency
                    sta       AUDF1,y             ;set frequency
                    tfr       x,d
                    lslb
                    tfr       d,x
                    ldd       SndAddrs,x          ;load from word offset for current note
                    addd      #$0003
                    std       SndAddrs,x          ;point to next note
                    tfr       x,d
                    lsrb
                    tfr       d,x

UpdateDur           dec       SndDurs,x           ;decrement remaining duration
                    leax      1,x
                    cmpx      #VOICES
                    bne       PlayVoice           ;play next voice
                    rts

                    emod
eom                 equ       *
                    end
