********************************************************************
* msspeed - show or set the PS/2 mouse speed
*
*   msspeed       print the current speed
*   msspeed n     set it, n = 1-8
*
* The speed is for the whole machine and stays until it is set again
* (put an msspeed line in the startup file to keep one across a boot).
* It is SS.MsCfg's high byte (defs/wildbits.d): 1-8 = resolution 1, 1,
* 2, 2, 4, 4, 8, 8 counts/mm, the even ones with the mouse's 2:1
* scaling (acceleration).  5 is what mousedrv sets at boot.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2026/10/14  jfed6000
* Started.

                    nam       msspeed
                    ttl       Mouse speed command

                  IFP1
                    use       defsfile
                  ENDC

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    org       0
linebuf             rmb       40
                    rmb       200       stack
size                equ       .

name                fcs       /msspeed/
                    fcb       edition

start               lda       ,x+       ; the first non-blank parameter
                    cmpa      #C$SPAC
                    beq       start
                    cmpa      #C$CR
                    beq       show      ; none: show the speed
                    suba      #'0
                    beq       usage     ; 1-8 only
                    cmpa      #MS.SpdMax
                    bhi       usage
                    clrb                ; ss.MsCfg high byte = the speed
                    tfr       d,x
                    clra                ; path 0
                    ldb       #SS.MsCfg
                    os9       I$SetStt
                    bcs       exit
show                clra                ; path 0
                    ldb       #SS.MsCfg
                    os9       I$GetStt
                    bcs       exit
                    tfr       x,d       ; a = the speed, 0 = no mouse
                    leay      linebuf,u
                    tsta
                    beq       nomouse
                    leax      SpdTxt,pcr
                    bsr       AppStr
                    adda      #'0
                    sta       ,y+
                    cmpa      #'0+MS.SpdDef
                    bne       eol
                    leax      DefTxt,pcr
                    bsr       AppStr
                    bra       eol
nomouse             leax      NoTxt,pcr
                    bsr       AppStr
eol                 lda       #C$CR
                    sta       ,y
                    leax      linebuf,u
                    ldy       #40
                    lda       #1        ; stdout
                    os9       I$WritLn
                    clrb
exit                os9       F$Exit

usage               leax      UseTxt,pcr
                    ldy       #UseLen
                    lda       #2        ; stderr
                    os9       I$WritLn
                    ldb       #E$IllArg
                    os9       F$Exit

* AppStr - copy the 0-ended string at X to Y.  A kept.
AppStr              pshs      a
as1                 lda       ,x+
                    beq       as2
                    sta       ,y+
                    bra       as1
as2                 puls      a,pc

SpdTxt              fcc       /mouse speed /
                    fcb       0
DefTxt              fcc       / (default)/
                    fcb       0
NoTxt               fcc       /no mouse/
                    fcb       0
UseTxt              fcc       /usage: msspeed [1-8]  (1 slowest, 8 fastest; 5 default)/
                    fcb       C$CR
UseLen              equ       *-UseTxt

                    emod
eom                 equ       *
                    end
