********************************************************************
* SndDrv - Sound Driver for the SID on the F256
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2024/01/07  Boisy Pitre
* Started.

					ifp1
					use       defsfile
					use       f256vtio.d
					endc

* SYSTEM MAP GLOBALS:

rev                 set       0
edition             set       1

					mod       sndlen,sndnam,Systm+Objct,ReEnt+rev,entry,0

sndnam              fcs       "SndDrv"
					fcb       edition

*******************************************************
entry               bra       init                Init codriver
					nop                 could be a constant
					bra       getstt              (returns no error; no getstt calls)
					nop                 could be a constant
					bra       setstt              SS.Tone only (so far)
					nop                 could be a constant
					bra       term                Terminate
					nop                could be a constant

*******************************************************

init                leax      Bell,pcr
					stx       >D.Bell   save bell vector
* GetStat/Term return no error - may want a GetStat for sound capabilities and/or device kind
* (digital samples, synthesize, mono vs. polyphonic (and maybe how many voices allowed),etc?
getstt
					clrb
					rts

term                ldd       #$0000
                    std       >D.Bell
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
					stb       >D.TnCnt    save duration
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
Bell                ldd       #$3001              A=Start volume (48), B=duration counter (1):# of 8 cycle delays between DAC writes
					ldy       #$0100              bell freq (4096-256, so 3840 if comparing to SS.Tone value)

* COMMON SS.TONE and BELL ROUTINE:
* A=volume byte (0-63)
* B=cycle repeats (1 means use G.TnCnt as countdown)
* Y=freq
BellTone
					rts

					emod
sndlen              equ       *
					end

