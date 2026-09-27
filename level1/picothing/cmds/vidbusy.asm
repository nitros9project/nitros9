********************************************************************
* VidBusy - video console write-load generator for ISR measurement
*
* The companion to vidload, and the CEILING to its floor.  Where vidload
* arms loopback so the render core stays idle and every read pops the
* fifo (isolating read-handler cost under scanline-DMA interference),
* vidbusy leaves loopback OFF and writes a printable byte every
* iteration.  Those writes reach the console for real, so the render core
* is saturated - continuous wrap-and-scroll for the whole run - and the
* write handler is exercised under genuine rendering contention.  That is
* the number that matters for a faster part: at 3 MHz a write-handler
* tail that spans a bus cycle cannot be hidden.
*
* The loop body is byte-for-byte the same shape as vidload's - one 8-bit
* store to VID.Data then one 8-bit load from it - so the ONLY differences
* between the two programs are the renderer load and the read-path cost.
* Specifics fixed by the video-pico firmware author:
*   - keep the read in even though it is cheap here (loopback off means
*     the input fifo is empty, so the read does no pop-and-restage work);
*     dropping it would change the access pattern and the loop timing and
*     confound the comparison with vidload
*   - the written byte is printable with no carriage return, so the
*     console wraps and scrolls without pause - deliberately harsher than
*     any real NitrOS-9 output, because this is the ceiling not a
*     simulation
*   - no TDRE flow control: writes WILL be dropped once the 2 KB command
*     fifo fills and the renderer falls behind, and that is fine - the
*     write handler ran regardless, which is what is measured, and the
*     6809 sets the pace so the run length is unaffected.  Polling TDRE
*     would add Stat reads and change the access pattern
*
* Same protocol as vidload: boot fresh, run from the serial console, wait
* for the shell prompt to return, then capture "st".  Read the WRITE line
* for this program (vidload gives the READ line); the two programs' read
* figures are not comparable, so do not put them side by side.  One run
* per boot; the counters are cumulative since boot.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2026       Created to bracket the bus ISR tail (hang ticket)

                    nam       VidBusy
                    ttl       video console write-load generator

                  IFP1
                    use       defsfile
                  ENDC

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

* The iteration count is Outer times Inner, matching vidload exactly so
* both programs perform the same number of window accesses.
Outer               equ       2000      outer loop count
Inner               equ       5000      inner loop count (2000 x 5000 = 10,000,000)

                    mod       eom,name,tylg,atrv,start,size

                    org       0
                    rmb       200       working stack
size                equ       .

name                fcs       /VidBusy/
                    fcb       edition

start               ldb       #$55      ; a printable byte ('U') to draw
                    ldx       #Outer    ; outer loop counter
OuterLp             ldy       #Inner    ; inner loop counter
InnerLp             stb       >VID.Data ; write it to the console (renderer draws it)
                    lda       >VID.Data ; cheap read - keeps the access pattern
                    leay      -1,y      ; count this iteration
                    bne       InnerLp   ; until the inner count is exhausted
                    leax      -1,x      ; count this outer pass
                    bne       OuterLp   ; until every iteration has run
                    clrb                ; success
                    os9       F$Exit    ; the shell prompt signals completion

                    emod
eom                 equ       *
                    end
