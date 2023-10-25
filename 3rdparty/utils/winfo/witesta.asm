                    nam       WItesta
                    ttl       Asm test of WInfo subroutine
*
* Witesta - copyright November,1987 by Ron Lammardo
*  This program placed into the Public Domain as a demonstration
*  detailing use of the WInfo subroutine from an ASM
*  calling program
*
* Syntax : Witesta <device name>
*
                    ifp1
                    use       defsfile
                    endc

typelang            set       prgrm+objct
attrev              set       reent+revision
revision            set       1

zeroadr             equ       *

                    mod       Eom,Mname,Typelang,Attrev,Start,Datend

mname               fcs       /WItesta/
                    fcb       1
                    org       0
window              rmb       2
nameln              rmb       2
current             rmb       2
bytect              rmb       1
hexbuff             rmb       6
dispcnt             rmb       1
                    rmb       252
                    use       winfodefs
buffer              rmb       2000
                    rmb       256
datend              equ       .

minedtn             set       1                   lowest edition Winfo we can use

winfo               fcc       /winfo/             subroutine module name
                    fcb       $0d

errmsg1             fcb       $0d,$0a
                    fcc       /You must use WInfo edition #/
err1sz              equ       *-errmsg1
errmsg2             fcc       / or higher/
                    fcb       $0d
err2sz              equ       *-errmsg2

msg1                fcc       /WI$Stat   :/
                    fcb       1
                    fcc       /WI$VDG    :/
                    fcb       1
                    fcc       /WI$Sty    :/
                    fcb       1
                    fcc       /WI$Block  :/
                    fcb       1
                    fcc       /WI$BlCnt  :/
                    fcb       1
                    fcc       /WI$Offst  :/
                    fcb       2
                    fcc       /WI$Cpx    :/
                    fcb       1
                    fcc       /WI$Cpy    :/
                    fcb       1
                    fcc       /WI$Szx    :/
                    fcb       1
                    fcc       /WI$Szy    :/
                    fcb       1
                    fcc       /WI$CWCpx  :/
                    fcb       1
                    fcc       /WI$CWCpy  :/
                    fcb       1
                    fcc       /WI$CWSzx  :/
                    fcb       1
                    fcc       /WI$CWSy   :/
                    fcb       1
                    fcc       /WI$Curx   :/
                    fcb       1
                    fcc       /WI$Cury   :/
                    fcb       1
                    fcc       /WI$BPR    :/
                    fcb       2
                    fcc       /WI$CBsw   :/
                    fcb       1
                    fcc       /WI$FGPRN  :/
                    fcb       1
                    fcc       /WI$BGPRN  :/
                    fcb       1
                    fcc       /WI$BDPRN  :/
                    fcb       1
                    fcc       /WI$Lset   :/
                    fcb       1
                    fcc       /WI$FntGr  :/
                    fcb       1
                    fcc       /WI$FntBf  :/
                    fcb       1
                    fcc       /WI$PstGr  :/
                    fcb       1
                    fcc       /WI$PstBf  :/
                    fcb       1
                    fcc       /WI$GcrGr  :/
                    fcb       1
                    fcc       /WI$GcrBf  :/
                    fcb       1
                    fcc       /WI$DrCrx  :/
                    fcb       2
                    fcc       /WI$DrCry  :/
                    fcb       2
                    fcc       /WI$Edtn   :/
                    fcb       1
                    fcc       /WI$WEAdr  :/
                    fcb       2
                    fcc       /WI$Devm   :/
                    fcb       2
                    fcc       /           /
                    fcb       5
palreg              fcc       /WI$PRegs  :/
                    fcb       16

spaces              fcc       /                /
creturn             fcb       $0d


start               equ       *
                    stx       <window             address of command line parameter start
                    subd      #1                  back off 1 for <cr>
                    std       <nameln             save the length of the device name
                    pshs      a,b,u,x             save all registers

* attempt link to subroutine

                    lda       #sbrtn+objct        module type for link
                    leax      winfo,pcr           module name for link
                    os9       F$Link              link to the module
                    bcc       pshparms            go push params if link succesful
                    cmpb      #E$MNF              see if its module not found error
                    lbne      exit                if not..exit

* attempt load & link of subroutine

                    lda       #sbrtn+objct        module type for link
                    leax      winfo,pcr           module name for link
                    os9       F$Load              load/link to the module
                    lbcs      exit                ...exit on error

pshparms            equ       *
                    puls      a,b,u,x             return registers
                    ldx       #wi$size            size of return buffer
                    pshs      x                   put on stack
                    leax      winfobuf,u          param2 (return buffer)
                    pshs      x                   put on stack
                    ldx       <nameln             size of param 1
                    pshs      x                   put on stack
                    ldx       <window             address of param 1 (window name)
                    pshs      x                   put on stack
                    ldx       #0002               paramcount
                    pshs      x                   put on stack
                    jsr       ,y                  jump to the subroutine

* return from subroutine
*
* normally we'd check for carry set and WI$Stat,
* but here we want to display status messages
*

                    lda       #sbrtn+objct        module type
                    leax      winfo,pcr           module name
                    os9       F$UnLoad            unlink/remove the module
                    lbcs      exit                ...exit on error

                    lda       #minedtn            lowest edition WInfo that this prgm can use
                    cmpa      WI$Edtn,u           check with edition # returned
                    lbhi      lowedtn             go display message if edition to low
                    leay      winfobuf,u
                    sty       <current
                    leax      msg1,pcr
                    clr       dispcnt
prtloop             equ       *
                    ldy       #11
                    lda       #1
                    os9       i$write
                    leax      11,x
                    ldb       ,x+
                    stb       <bytect
                    cmpb      #2
                    bne       checkhi
                    ldy       <current
                    ldd       ,y++
                    sty       <current
                    bra       printit
checkhi             cmpb      #1
                    bne       prtpalet
                    ldy       <current
                    clra
                    ldb       ,y+
                    sty       <current
printit             equ       *
                    leay      hexbuff,u
                    lbsr      u$gethex
                    pshs      x
                    tfr       y,x
                    ldy       #4
                    ldb       <bytect
                    cmpb      #2
                    beq       print010
                    ldd       #$2020
                    std       ,x
print010            lda       #1
                    os9       i$write
                    lbcs      exit
                    ldy       #8
                    tst       <dispcnt
                    beq       printsp
                    clr       <dispcnt
                    leax      creturn,pcr
                    ldy       #1
                    bra       prntfill
printsp             leax      spaces,pcr
                    inc       <dispcnt
prntfill            equ       *
                    lda       #1
                    os9       I$writln
                    lbcs      exit
                    puls      x
                    bra       prtloop

prtpalet            equ       *
                    ldy       <current
                    leay      wi$pregs,u          skip filler bytes
                    sty       <current
                    pshs      x
                    leax      creturn,pcr
                    ldy       #8
                    lda       #1
                    os9       i$writln
                    leax      palreg,pcr
                    ldy       #11
                    lda       #1
                    os9       i$write
                    lbcs      exit
                    puls      x
nocr                equ       *
                    ldb       #8
prt010              pshs      b
                    ldy       <current
                    ldd       ,y++
                    sty       <current
                    leay      hexbuff,u
                    lbsr      u$gethex
                    ldd       2,y
                    std       3,y
                    lda       #$20
                    sta       2,y
                    sta       5,y
                    tfr       y,x
                    ldy       #6
                    lda       #1
                    os9       i$write
                    lbcs      exit
                    puls      b
                    decb
                    beq       prtmsg
                    cmpb      #4
                    bne       prt010
                    pshs      b
                    leax      creturn,pcr
                    ldy       #8
                    lda       #1
                    os9       i$writln
                    leax      spaces,pcr
                    ldy       #11
                    lda       #1
                    os9       i$write
                    lbcs      exit
                    puls      b
                    bra       prt010

prtmsg              equ       *
                    leax      hexbuff,u
                    lda       #$0d
                    sta       ,x
                    ldy       #1
                    lda       #1
                    os9       i$writln
                    ldx       <current
                    ldy       #40
                    lda       #1
                    os9       i$write


clrexit             clrb
exit                os9       F$exit



lowedtn             equ       *
                    leax      errmsg1,pcr
                    ldy       #err1sz
                    lda       #2
                    os9       I$Write
                    lbcs      exit
                    ldb       #minedtn
                    leay      hexbuff,u
                    lbsr      U$Gethex
                    leax      2,y
                    ldy       #2
                    lda       #2
                    os9       I$Write
                    lbcs      exit
                    leax      errmsg2,pcr
                    ldy       #err2sz
                    lda       #2
                    os9       I$Writln
                    bcs       exit
                    bra       clrexit

**********************************************************************
*                                                                     *
* U$gethex - converts binary integer to hexidecimal                   *
*                                                                     *
* Entry: y=address of 4 byte string for hexidecimal number            *
*        d=integer to convert                                         *
*                                                                     *
* Exit:  y=same as entry                                              *
*                                                                     *
***********************************************************************
U$GetHex            equ       *
                    pshs      y
                    pshs      b
                    bsr       u$gth010
                    puls      a
                    bsr       u$gth010
                    puls      y,pc
u$gth010            pshs      a
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       u$gth020
                    puls      a
                    anda      #$0f
                    bsr       u$gth020
                    rts
u$gth020            adda      #$30
                    cmpa      #$3a
                    blt       u$gth030
                    adda      #$7
u$gth030            sta       ,y+
                    rts



                    emod
eom                 equ       *

