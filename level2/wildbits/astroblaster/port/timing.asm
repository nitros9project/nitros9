* Foreground frame pacing, with no application IRQ or direct MMU writes.
* U = AP platform state. Preserve X,Y,U; D/CC are returned/scratch.
* WildBits uses TkPerSec=60. D.Tick counts DOWN, resetting each second.
*
* F$TPS/F$XTime have equates but no installed service in this clock module.
* Use the existing L2 F$CpyMem interface, as the system memory commands do.
* The complete 16-byte source DAT image maps system block 0. Only D.Sec
* and D.Tick are read. Kernel F$Move masks IRQ during this two-byte copy,
* so the second boundary cannot split the sampled pair. No global stores.
ReadTickClock    pshs      x,y,u
                    leax      ClockSystemDAT,pcr
                    tfr       x,d
                    ldx       #D.Sec
                    ldy       #ASTRO_CLOCK_BYTES
                    leau      AP_CurrentSecond,u
                    os9       F$CpyMem
                    puls      x,y,u,pc
ClockSystemDAT   fdb       ASTRO_SYSTEM_BLOCK,ASTRO_SYSTEM_BLOCK
                    fdb       ASTRO_SYSTEM_BLOCK,ASTRO_SYSTEM_BLOCK
                    fdb       ASTRO_SYSTEM_BLOCK,ASTRO_SYSTEM_BLOCK
                    fdb       ASTRO_SYSTEM_BLOCK,ASTRO_SYSTEM_BLOCK

InitializeFrameClock
                    bsr       ReadTickClock
                    bcs       FrameClockReturn
RememberClockNow ldd       AP_CurrentSecond,u
                    std       AP_LastSecond,u
                    clr       AP_ClockNeedsSync,u
                    clrb
FrameClockReturn rts

* Return B = elapsed foreground ticks (1..255), C clear; C/B on error/exit.
* The caller advances game logic once per elapsed tick and renders once,
* avoiding duplicate renders when catching up. Long stalls or clock changes
* resync to one tick. An inactive VT resumes from NOW instead of accumulating
* paused time. Speech is serviced between clock samples without busy-waiting.
WaitGameFrame    pshs      x,y
WaitFrameSample  lbsr      ServiceSpeech
                    lbsr      WaitForTerminal
                    bcs       WaitFrameReturn
                    bsr       ReadTickClock
                    bcs       WaitFrameReturn
                    tst       AP_ClockNeedsSync,u
                    beq       WaitFrameCompare
                    bsr       RememberClockNow
                    bra       WaitFrameSleep
WaitFrameCompare ldd       AP_CurrentSecond,u
                    cmpd      AP_LastSecond,u
                    beq       WaitFrameSleep
                    lda       AP_CurrentSecond,u
                    suba      AP_LastSecond,u
                    bpl       WaitFrameSeconds
                    adda      #ASTRO_CLOCK_MINUTE
WaitFrameSeconds ldb       #TkPerSec
                    mul
                    addb      AP_LastTick,u
                    adca      #0
                    subb      AP_CurrentTick,u
                    sbca      #0
                    pshs      d
                    lbsr      RememberClockNow
                    puls      d
                    tsta
                    bne       WaitFrameResync
                    tstb
                    beq       WaitFrameSleep
                    andcc     #$FE
                    bra       WaitFrameReturn
WaitFrameResync  ldb       #1
                    andcc     #$FE
                    bra       WaitFrameReturn
WaitFrameSleep   ldx       #ASTRO_PAUSE_SLEEP
                    tst       AD_Speech+SP_BufferCount,u
                    beq       WaitSleepReady
                    ldx       #1
WaitSleepReady
                    os9       F$Sleep
                    bcc       WaitFrameSample
WaitFrameReturn  puls      x,y,pc
