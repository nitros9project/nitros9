********************************************************************
* VidLoad - video window bus-load generator for ISR measurement
*
* Hammers the video pico's data register through loopback to drive the
* firmware's bus-interrupt instrumentation with a large, repeatable
* sample.  A normal session polls VID.Stat only a few thousand times, far
* too few for a parts-per-million tail figure; this performs a fixed,
* compiled-in ten million write-then-read pairs and exits.  Because the
* count is fixed rather than timed, two runs - one per video-pico clock -
* execute exactly the same number of accesses, so their latched maxima
* are directly comparable, not just their rates.
*
* Access pattern (specified by the video-pico firmware author):
*   - arm loopback so each written byte echoes into the input fifo and
*     nothing reaches the console, so no rendering perturbs the pico
*   - each iteration writes one byte to VID.Data then reads it back; the
*     read pops the fifo and restages it, which is the expensive handler
*     path the measurement is after (a read of an empty register is cheap
*     and would not exercise it)
*   - touch the window ONE BYTE AT A TIME - never a 16-bit load across
*     VID.Data/VID.Stat, whose two back-to-back bus cycles are the very
*     thing the measurement isolates (a second access landing inside the
*     first handler)
*   - restore the reset at the end (loopback off, fifos flushed)
*
* Protocol: boot fresh (the counters are cumulative since boot and do not
* reset), run this from the serial console, let it finish - it prints
* nothing, so the returning shell prompt is the only completion signal
* and nothing disturbs the render core - then capture "st".  One run per
* boot.  At 1 MHz E the ten million iterations take a minute or two.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2026       Created to measure the bus ISR tail (hang ticket)

                    nam       VidLoad
                    ttl       video window bus-load generator

                  IFP1
                    use       defsfile
                  ENDC

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

* The iteration count is Outer times Inner.  Keep both factors at or
* below 65535 so each fits a 16-bit loop register; their product is the
* fixed number of window write-and-read pairs every run performs.
Outer               equ       2000      outer loop count
Inner               equ       5000      inner loop count (2000 x 5000 = 10,000,000)

                    mod       eom,name,tylg,atrv,start,size

                    org       0
                    rmb       200       working stack
size                equ       .

name                fcs       /VidLoad/
                    fcb       edition

start               lda       #VID.Rset+VID.Loop ; soft reset then loopback on
                    sta       >VID.Stat ; arm the control register
                    lda       #$55      ; an arbitrary byte to circulate
                    ldx       #Outer    ; outer loop counter
OuterLp             ldy       #Inner    ; inner loop counter
InnerLp             sta       >VID.Data ; loopback pushes it into the input fifo
                    lda       >VID.Data ; pop it back - the expensive read path
                    leay      -1,y      ; count this iteration
                    bne       InnerLp   ; until the inner count is exhausted
                    leax      -1,x      ; count this outer pass
                    bne       OuterLp   ; until every iteration has run
                    lda       #VID.Rset ; loopback off, flush the fifos
                    sta       >VID.Stat ; restore the control register
                    clrb                ; success
                    os9       F$Exit    ; the shell prompt signals completion

                    emod
eom                 equ       *
                    end
