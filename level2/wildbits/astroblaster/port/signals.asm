* Process-local signal handling; never install an application hardware ISR.
* U = platform static base, also supplied to F$Icpt as the handler data base.
* WatchTerminal is for the main program, not a library caller with an
* existing intercept routine. No resource acquisition precedes this call.
WatchTerminal      leax      AstroSignal,pcr
                    os9       F$Icpt
                    bcs       WatchReturn
                    ldx       #ASTRO_VT_SIGNALS
                    lda       #ASTRO_OUTPUT_PATH
                    ldb       #SS.WSig
                    os9       I$SetStt
                    bcs       WatchReturn
                    inc       AP_WatchesTerminal,u
                    clrb
WatchReturn        rts

UnwatchTerminal    tst       AP_WatchesTerminal,u
                    beq       UnwatchOK
                    ldx       #0
                    lda       #ASTRO_OUTPUT_PATH
                    ldb       #SS.WSig
                    os9       I$SetStt
                    bcs       UnwatchReturn
                    clr       AP_WatchesTerminal,u
UnwatchOK          clrb
UnwatchReturn      rts

* OS-9 enters with B=signal, U=registered static base. Return with RTI.
* Do not draw, free memory, send sound, or make blocking calls from here.
* S$Kill cannot be intercepted; normal abort/interrupts request main-loop exit.
AstroSignal        cmpb      #S$WinBg
                    beq       AstroBackground
                    cmpb      #S$WinFg
                    beq       AstroForeground
                    cmpb      #S$Wake
                    beq       AstroSignalReturn
                    stb       AP_ExitSignal,u
AstroSignalReturn  rti
AstroBackground    lda       #1
                    sta       AP_Paused,u
                    rti
AstroForeground    clr       AP_Paused,u
                    lda       #1
                    sta       AP_ClockNeedsSync,u
                    rti

* Main-context background wait, not a frame-rate timer. Preserve X,Y,U.
* Return C clear when foreground; C set/B=signal on requested exit, or
* C set/B=OS error if sleeping fails. Never draw here; the only hardware
* touched is the sound service and the speech port, to silence them.
* A finite sleep avoids losing a foreground signal between testing the
* flag and sleeping forever. F$Sleep(1) merely yields; 2 waits a tick.
WaitForTerminal    pshs      x
TerminalWaitCheck  lbsr      SyncSoundPause
                    lbsr      PauseSpeech
                    ldb       AP_ExitSignal,u
                    bne       TerminalWaitExit
                    tst       AP_Paused,u
                    beq       TerminalWaitReady
                    ldx       #ASTRO_PAUSE_SLEEP
                    os9       F$Sleep
                    bcc       TerminalWaitCheck
                    puls      x,pc
TerminalWaitReady  clrb
                    puls      x,pc
TerminalWaitExit   orcc      #1
                    puls      x,pc
