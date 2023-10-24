********************************************************************
* DMem - Dump memory from system
*
* dmem  <block> <offset> [<length>] ! dump
* dmem -<proc#> <offset> [<length>] ! dump
*
* $Id$
*
* From "Inside OS9 Level II", by Kevin Darling
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   2      ????/??/??  Kevin Darling
* Started.

                    nam       DMem
                    ttl       Dump memory from system

* Disassembled 98/09/14 19:24:59 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       2

                    mod       eom,name,tylg,atrv,entry,msize

acc                 rmb       2
input               rmb       1
offset              rmb       2
dlen                rmb       2
id                  rmb       1
prcdsc              rmb       512
buffer              rmb       4296
msize               equ       .

dat                 equ       prcdsc+$40

name                fcs       /DMem/
                    fcb       edition

hexin               clr       <acc
                    clr       <acc+1

hexin01             lda       ,x+
                    cmpa      #C$SPAC
                    beq       hexrts
                    cmpa      #C$CR
                    beq       hexrts
                    suba      #$30
                    cmpa      #$0A
                    bcs       hex2                0-9
                    anda      #$07                A-F
                    adda      #$09
hex2                lsla
                    lsla
                    lsla
                    lsla
                    sta       <input
                    ldd       <acc                get accumulator
                    rol       <input
                    rolb
                    rola
                    rol       <input
                    rolb
                    rola
                    rol       <input
                    rolb
                    rola
                    rol       <input
                    rolb
                    rola
                    std       <acc
                    bra       hexin01
hexrts              leax      -1,x
                    ldd       <acc
                    rts

entry               lbsr      skipspc             skip leading spaces
                    lbeq      badnum              ..was it CR?
                    cmpa      #'-                 else is it #id?
                    bne       entry0              ..no

                    leax      1,x                 yes, skip '-'
                    bsr       hexin               get id number
                    tfr       b,a
                    pshs      x
                    leax      >prcdsc,u
                    os9       F$GPrDsc            get that process descriptor
                    lbcs      error
                    puls      x
                    bra       entry1

entry0              bsr       hexin               get block #
                    clr       <dat                set in fake DAT image
                    stb       <dat+1

entry1              lbsr      skipspc             get offset
                    lbeq      badnum
                    lbsr      hexin
                    std       <offset
                    lbsr      skipspc             get possible offset
                    beq       entry2

                    lbsr      hexin
                    cmpd      #$1000
                    bls       entry3
                    ldd       #$1000
                    bra       entry3
entry2              ldd       #$0100

entry3              std       <dlen

                    leax      >dat,u
                    tfr       x,d                 D=DAT image pointer
                    ldy       <dlen               Y=count
                    ldx       <offset             X=offset within DAT image
                    pshs      u
                    leau      >buffer,u
                    os9       F$CpyMem
                    puls      u
                    bcs       error

                    ldy       <dlen
                    leax      >buffer,u           point within buffer
                    lda       #$01
                    os9       I$Write

bye                 clrb
error               os9       F$Exit

HelpTxt             fcc       "Use: DMem <block> <offset> [<length>] ! dump"
                    fcb       C$LF
                    fcc       " or: DMem -<id>   <offset> [<length>] ! dump"
                    fcb       C$CR
HelpTxtL            equ       *-HelpTxt

badnum              leax      >HelpTxt,pcr
                    ldy       #HelpTxtL
                    lda       #$02
                    os9       I$WritLn
                    bra       bye

skipspc             lda       ,x+
                    cmpa      #C$SPAC
                    beq       skipspc
                    leax      -1,x
                    cmpa      #C$CR
                    rts

                    emod
eom                 equ       *
                    end
