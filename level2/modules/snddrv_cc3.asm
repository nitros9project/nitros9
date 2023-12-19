********************************************************************
* SndDrv - Sound Driver for CoCo 3
* NOTE: Does not use ANY of current 8 byte data area.
* It also never modifies U, so U is the same on exit as entry
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
*
*   4      2020/07/15  L. Curtis Boyle (EOU Beta 6)
* Slightly optimized for size/speed.

                    nam       SndDrv
                    ttl       Sound Driver for CoCo 3

                    ifp1
                    use       defsfile
                    use       cocovtio.d
                    endc

* SYSTEM MAP GLOBALS:

rev                 set       0
edition             set       4

                    mod       sndlen,sndnam,Systm+Objct,ReEnt+rev,entry,0

sndnam              fcs       "SndDrv"
                    fcb       edition

*******************************************************
entry               bra       init                Init codriver
                    fcb       $12                 could be a constant
                    bra       getstt              (returns no error; no getstt calls)
                    fcb       $12                 could be a constant
                    bra       setstt              SS.Tone only (so far)
                    fcb       $12                 could be a constant
                    bra       term                Terminate
                    fcb       $12                 could be a constant

*******************************************************
* INIT: set bell vector for F$Alarm

init                leax      Bell,pcr
                    stx       >WGlobal+G.BelVec   save bell vector
* GetStat/Term return no error - may want a GetStat for sound capabilities and/or device kind
* (digital samples, synthesize, mono vs. polyphonic (and maybe how many voices allowed),etc?
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
                    ble       BadArgs
                    cmpd      #$1000
                    bge       BadArgs
                    tfr       d,y                 legal value, move tone to Y
                    ldd       R$X,x               get vol, duration
                    stb       >WGlobal+G.TnCnt    save duration
                    ldb       #1                  flag to use G.TnCnt for duration counter
                    anda      #$3F                make volume ok
                    bra       BellTone            do it

BadArgs             comb                          Exit with Illegal Argument error
                    ldb       #E$IllArg
                    rts

*******************************************************
* Bell ($07) (called via Bell vector G.BelVec):
* can destroy D,Y
* Special KeyClick Addition:
* Entry: B=$08 (KeyClick), then use shorter, different pitch, for keyclick
*   any other B (which will be $00 for Writing a Bell ($07) char or Clock Alarm call, or
*   $9B if F$Debug call
Bell                inc       >WGlobal+G.BelTnF   set bell flag
                    cmpb      #KeyClick           Special Keyclick tone/duration?
                    bne       NormBell            No, do normal Bell
                    ldd       #$3001              A=Start volume (48), B=duration counter (1):# of 8 cycle delays between DAC writes
                    ldy       #$0100              bell freq (4096-256, so 3840 if comparing to SS.Tone value)
                    bra       BellTone

NormBell            ldd       #$3E60              A=start volume (62), B=duration counter (96):# of 8 cycle delays between DAC writes
                    ldy       #$0060              bell freq (4096-96, so 4000 if comparing to SS.Tone value)
* COMMON SS.TONE and BELL ROUTINE:
* A=volume byte (0-63)
* B=cycle repeats (1 means use G.TnCnt as countdown)
* Y=freq
BellTone            lsla                          set A for PIA D/A bits
                    lsla
                    beq       okend               okay end if just setting it
                    ora       #%00000010          (2) add printer port bit
                    pshs      d,x
                    ldx       #PIA0Base           save current PIA setting
                    lda       1,x
                    ldb       3,x
                    pshs      d
                    IFNE      H6309
                    andd      #$F7F7              set for sound
                    ELSE
                    anda      #$F7                set for sound
                    andb      #$F7
                    ENDC
                    sta       1,x
                    stb       3,x
                    leax      $20,x               save PIA2 setting
                    lda       3,x
                    pshs      a
                    ora       #%00001000          (8) and set it too
                    sta       3,x
                    bra       ToneLoop            enter main play loop

* Stack at this point:
* 0,s = PIA2 ($FF23) saved setting
* 1,s = PIA0 ($FF01) saved setting
* 2,s = PIA0 ($FF03) saved setting
* 3,s = Current 6 bit DAC bits (already shifted to upper 6)
* 4,s = Duration counter (1=use G.TnCnt instead, otherwise Bell setting)
BellLoop            lda       3,s                 only bell does this countdown
                    deca
                    deca
                    sta       3,s
                    anda      #%11110111          $F7 Clear bit 3
                    ora       #%00000010          $02 Set bit 1
                    bra       Loop2

ToneLoop            ldd       3,s                 get D/A byte, repeat cnt
Loop2               bsr       SendByte            send it (Y=tone delay in 8 cycle increments)
                    lda       #2                  go back to zero
                    bsr       SendByte            send it
                    decb                          count-1 (SS.Tone always=0!)
                    bne       BellLoop            loop if bell cycles only <<
                    ldb       >WGlobal+G.BelTnF   is it bell?
                    bne       ToneExit            yes, end
                    ldb       >WGlobal+G.TnCnt    else get ticks left
                    bne       ToneLoop            and do again if any, else...
* Note: G.TnCnt is counted down by vtio at 60hz.
ToneExit            clr       >WGlobal+G.BelTnF   clear bell flag
                    puls      a                   reset PIA's as before:
                    sta       3,x
                    leax      -$20,x
                    puls      d
                    sta       1,x
                    stb       3,x
                    clrb                          restore X, and return without error
                    puls      d,x,pc

* Send value to DAC, then delay for Y * 8 CPU cycles
SendByte            pshs      y                   save delay
                    sta       ,x                  store D/A byte
SendDely            leay      -1,y                (5 cyc) delay
                    bne       SendDely            (3 cyc) for tone
                    puls      y,pc                restore delay counter for next run through & return

                    emod
sndlen              equ       *
                    end

