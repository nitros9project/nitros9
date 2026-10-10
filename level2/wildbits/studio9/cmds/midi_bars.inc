* Bar lines for the MIDI importer (pass 1). The merged stream arrives in time
* order, so a bar line due at a boundary is appended the moment the first event
* at or beyond it shows up - in front of that event, as in a native score. The
* score starts empty (Init clears the count), so the first bar line is the one
* at tick 0, numbered 1.
* A time signature resets the boundary to its own tick; when no bar line stands
* there yet and events at that tick are already down, one is inserted in front
* of them (the one case that still shifts anything, and only the equal-time tail).
mi_bars             ldd       ibound,u
mi_barloop@         cmpd      irec+1,u
                    bhi       mi_barsig@
                    lbsr      mi_barat
                    ldd       ibound,u
                    addd      ibarlen,u
                    bcc       mi_barnext@
                    ldd       #$FFFF
mi_barnext@         std       ibound,u
                    bra       mi_barloop@
mi_barsig@          tst       irec,u
                    bne       mi_barsdone@
                    lda       irec+5,u
                    cmpa      #$0A
                    bne       mi_barsdone@
                    ldd       irec+1,u
                    cmpd      ilastb,u
                    beq       mi_barslen@
                    lbsr      mi_barins
mi_barslen@         ldb       irec+6,u            beats
                    lda       #192
                    mul
                    std       ibarlen,u
                    ldb       irec+7,u            beat unit 1,2,4,8,16,32
mi_barsdiv@         cmpb      #1
                    beq       mi_barsset@
                    lsr       ibarlen,u
                    ror       ibarlen+1,u
                    lsrb
                    bra       mi_barsdiv@
mi_barsset@         ldd       irec+1,u
                    addd      ibarlen,u
                    bcc       mi_barsb@
                    ldd       #$FFFF
mi_barsb@           std       ibound,u
mi_barsdone@        rts
* The record for a bar line at the time in D, numbered in sequence.
mi_barrec           leax      ibar,u
                    std       1,x
                    std       ilastb,u
                    clr       ,x
                    ldd       ibarno,u
                    std       3,x
                    addd      #1
                    std       ibarno,u
                    clr       5,x
                    clr       6,x
                    clr       7,x
                    rts
mi_barat            equ       *
                    ifdef     UME_SCOPE_S9I
                    pshs      d
                    cmpd      ifirstnote,u
                    bhi       mi_openrestret@
                    lbsr      mi_openrests
mi_openrestret@     puls      d
                    endc
                    lbsr      mi_barrec
                    pshs      y,u
                    ldy       iframe,u
                    lbsr      MidiScoreAppend
                    bra       mi_barback
mi_barins           lbsr      mi_barrec
                    pshs      y,u
                    ldy       iframe,u
                    lbsr      MidiScoreAdd
mi_barback          puls      y,u
                    lbeq      mi_memory
                    rts
* After the last event: bar lines up to the final tick, then the closing one
* (unless the stream already closed on a bar line at that tick).
mi_finish           ldd       ibound,u
mi_fin@             cmpd      imax,u
                    bhs       mi_finlast@
                    lbsr      mi_barat
                    ldd       ibound,u
                    addd      ibarlen,u
                    bcc       mi_finnext@
                    ldd       imax,u
mi_finnext@         std       ibound,u
                    bra       mi_fin@
mi_finlast@         ldd       ilastb,u
                    cmpd      imax,u
                    beq       mi_findone@
                    ldd       ibound,u
                    lbsr      mi_barat
mi_findone@         rts

                    ifdef     UME_SCOPE_S9I
* Notate opening silence across whole or partial measures, once per interval.
* D is the closing tick. Preserve all MIDI timestamps and note durations.
mi_openrests        pshs      d,x
                    ldd       irestend,u
                    pshs      d                   STACK OFFSET: opening-rest frame, current tick
mor_piece@          ldd       2,s                 STACK OFFSET: opening-rest frame, closing tick
                    subd      ,s
                    cmpd      #3
                    blo       mor_done@
                    tfr       d,x                 remaining silence
                    ldd       #384
                    clr       ibar+3,u
mor_duration@       pshs      d
                    cmpx      ,s++
                    bhs       mor_chosen@
                    lsra
                    rorb
                    inc       ibar+3,u
                    bra       mor_duration@
mor_chosen@         pshs      d                   STACK OFFSET: opening-rest frame, piece length
                    ldd       2,s                 STACK OFFSET: opening-rest frame plus length, current tick
                    std       ibar+1,u
                    clr       ibar+4,u
                    lda       #$20
                    sta       ibar+5,u
                    clr       ibar+6,u
                    lda       #$82                notation only; imported MIDI owns playback
                    sta       ibar+7,u
                    clrb
mor_part@           leax      imap,u
                    tst       b,x
                    beq       mor_next@
                    pshs      b                   STACK OFFSET: opening-rest frame, part slot
                    incb
                    stb       ibar,u
                    leax      ibar,u
                    pshs      y,u
                    ldy       iframe,u
                    lbsr      MidiScoreAdd
                    puls      y,u
                    lbeq      mi_memory
                    puls      b
mor_next@           incb
                    cmpb      #16
                    blo       mor_part@
                    puls      d                   piece length
                    addd      ,s
                    std       ,s
                    bra       mor_piece@
mor_done@           leas      2,s
                    ldd       ,s                  STACK OFFSET: opening-rest frame, closing tick
                    std       irestend,u
                    puls      d,x,pc
                    endc
