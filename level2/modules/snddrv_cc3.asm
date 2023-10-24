********************************************************************
* SndDrv - Sound Driver for CoCo 3
*
* $Id$
*
* Should be fully compatible with old SS.Tone.
* (needs cleaning up for space)
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          1988/08/24  Kevin Darling
*          First working version.
*
*          1988/11/14  Kevin Darling
* Bell version for critics <grin>.
*
*   3      1998/09/26  Boisy G. Pitre
* Upgrade to edition 3 from Monk-o-Ware.

                    nam       SndDrv
                    ttl       Sound Driver for CoCo 3

                    ifp1
                    use       defsfile
                    use       cocovtio.d
                    endc

* SYSTEM MAP GLOBALS:

rev                 set       0
edition             set       3

                    mod       sndlen,sndnam,systm+objct,reent+rev,entry,0

sndnam              fcs       "SndDrv"
                    fcb       edition

*******************************************************
entry               lbra      init                init codriver
                    lbra      getstt
                    lbra      setstt              ss.tone
                    lbra      term                terminate

*******************************************************
* INIT: set bell vector for F$Alarm

init                leax      Bell,pcr
                    stx       >WGlobal+G.BelVec   save bell vector
getstt
term
okend               clrb
                    rts

*******************************************************
* SETSTT: do SS.Tone ($98) calls
* SS.Tone 98
* regs: X=vol,duration, Y=tone
* Y=path desc

setstt              ldx       PD.RGS,y            get user regs
                    ldd       #$1000              check for 1-4095 range
                    subd      R$Y,x               on passed Y
                    lble      BadArgs             ..okay if less
                    cmpd      #$1000              ..else err on $1000
                    lbge      BadArgs             ..
                    tfr       d,y                 set tone to D

                    ldd       R$X,x               get vol, duration
                    stb       >WGlobal+G.TnCnt    save duration
                    ldb       #1                  fake cycles
                    anda      #$3F                make volume ok
                    bra       BellTone            ..do it

BadArgs             comb
                    ldb       #E$IllArg
                    rts

*******************************************************
* Bell ($07):
* can destroy D,Y

Bell                inc       >WGlobal+G.BelTnF   set bell flag
* lda #230/4 start value
* ldb #230/2-18 cycle repeats
* ldd #60*256+96
                    ldd       #$3E60
                    ldy       #$0060              bell freq

* COMMON SS.TONE and BELL ROUTINE:
* A=volume byte (0-63)
* B=cycle repeats (1 means use G.TnCnt as countdown)
* Y=freq

BellTone            lsla                          set A for PIA D/A bits
                    lsla
                    lbeq      okend               okay end if just setting it
                    ora       #2                  add printer port bit
                    pshs      a,b,x
                    ldx       #PIA0Base           save current PIA setting
                    lda       1,x
                    ldb       3,x
                    pshs      a,b

                    ifne      H6309
                    andd      #$F7F7              set for sound
                    else
                    anda      #$F7                set for sound
                    andb      #$F7
                    endc
                    sta       1,x
                    stb       3,x
                    leax      $20,x               save PIA2 setting
                    lda       3,x
                    pshs      a
                    ora       #8                  and set it too
                    sta       3,x
                    bra       ToneLoop            ..enter main play loop

BellLoop            lda       3,s                 only bell does this countdown
                    deca
                    deca
                    sta       3,s
                    anda      #$F7
                    ora       #$02
                    bra       Loop2
ToneLoop            ldd       3,s                 get D/A byte, repeat cnt
Loop2               bsr       SendByte            send it (Y=tone delay)
                    lda       #2                  go back to zero
                    bsr       SendByte            send it
                    decb                          count-1 (SS.Tone always=0!)
                    bne       BellLoop            ..loop if bell cycles only <<

                    ldb       >WGlobal+G.BelTnF   is it bell?
                    bne       ToneExit            ..yes, end
                    ldb       >WGlobal+G.TnCnt    else get ticks left
                    bne       ToneLoop            and do again if any, else...

* Note: G.TnCnt is counted down by vtio at 60hz.

ToneExit            clr       >WGlobal+G.BelTnF   clear bell flag
                    puls      a                   reset PIA's as before:
                    sta       3,x
                    leax      -$20,x
                    puls      a,b
                    sta       1,x
                    stb       3,x
                    clrb                          okay
                    puls      a,b,x,pc            end tone/bell.

SendByte            pshs      y                   save delay
                    sta       ,x                  store D/A byte
SendDely            leay      -1,y                delay
                    bne       SendDely            for tone
                    puls      y,pc                retn.

                    emod
sndlen              equ       *
                    end

