* MIDI importer callbacks. X is a record/map pointer, D the final tick.
* Only these routines touch the main score; the importer validates before calling Init.
* Init: X = the 16 part keys (non-zero = the part exists), X+16 the 16 staff
* bytes (0 treble, 1 alto, 2 tenor, 3 bass, 4 percussion), X+96 the 16 MIDI
* channels. The score gets those five staves in that order, top to bottom;
* styinit spaces them equally.
MidiScoreInit       pshs      x,y,u
                    clra
                    clrb
                    pshs      d
                    jsr       [>pMidiNewScore]
                    leas      2,s
                    clra
                    clrb
                    std       <nevents
                    std       <nparts
                    std       <curind
                    std       <keysig
                    std       <transp
                    std       <velo
                    clr       >UmeData_reserved_03F3
                    ldx       #staves
                    ldu       #7*10+17*4
ms_zero@            clr       ,x+
                    leau      -1,u
                    cmpu      #0                  LEAU does not set Z; clear every staff/part byte
                    bne       ms_zero@
                    ldx       ,s
                    clrb
ms_part@            pshs      b,x                 b = part slot, x = its key byte
                    lda       ,x
                    beq       ms_skip@
                    lda       96,x                the MIDI channel
                    incb                          the part number, 1..16
                    clr       <nparts
                    stb       <nparts+1
                    ldx       #MidiChanTbl
                    sta       b,x
                    pshs      b                   STACK SAVE: part number, 1..16
                    tfr       a,b                 MIDI channel is zero based and need not equal part-1
                    lda       #1
                    ldx       #MidiChanOn
                    sta       b,x                 enable the assigned channel, including channel zero
                    puls      b
                    ldx       #MidiPartOn
                    sta       b,x                 enable the imported part
                    ldx       1,s
                    lda       16,x                its staff (0 treble .. 4 percussion)
                    pshs      a
                    clra
                    aslb
                    rola
                    aslb
                    rola
                    ldx       #parts
                    leax      d,x
                    puls      b
                    clra
                    std       ,x
ms_skip@            puls      b,x
                    leax      1,x
                    incb
                    cmpb      #16
                    blo       ms_part@
                    leax      ms_levels,pcr
                    ldu       #$0103
                    ldb       #8
ms_level@           lda       ,x+
                    sta       ,u+
                    decb
                    bne       ms_level@
                    lda       #1
                    sta       <UmeData_midievts                enable preserved inline MIDI events
                    ldd       #5
                    std       <nstaves
                    ldx       #staves
                    clra
                    clrb
                    std       2,x                 staff 1: treble clef (clefs entry 0)
                    ldd       #5
                    std       12,x                staff 2: alto clef (clefs entry 5)
                    ldd       #6
                    std       22,x                staff 3: tenor clef (clefs entry 6)
                    ldd       #1
                    std       32,x                staff 4: bass clef (clefs entry 1)
                    ldd       #4
                    std       42,x                staff 5: percussion clef (clefs entry 4)
                    jsr       [>pMidiStaffInit]
                    ldd       #1
                    puls      x,y,u,pc

* Append: the record at X goes behind everything already in the score. The
* importer's merged stream arrives in order, so this is its normal path.
MidiScoreAppend     pshs      x,y,u
                    leas      -6,s
                    ldd       <nevents
                    std       ,s
                    bra       ms_insert@
* Fix: the duration bytes 3-4 of the event at index D, from the record at X
* (a note's length is only known when it ends).
MidiScoreFix        pshs      x,y,u
                    pshs      d
                    jsr       [>pMidiEventPtr]
                    leas      2,s
                    tfr       d,u
                    cmpu      #0
                    beq       msf_fail@
                    ldx       ,s
                    ldd       3,x
                    std       3,u
                    ldd       #1
                    puls      x,y,u,pc
msf_fail@           clra
                    clrb
                    puls      x,y,u,pc
* Insert after equal-time events, except bars precede them (event zero is the
* opening bar, as in a native score). No pointer survives a mapper call.
MidiScoreAdd        pshs      x,y,u
                    leas      -6,s
                    clra
                    clrb
                    std       ,s                  lower bound
                    ldd       <nevents
                    std       2,s                 exclusive upper bound
ms_find@            ldd       ,s
                    cmpd      2,s
                    bhs       ms_insert@
                    addd      2,s
                    lsra
                    rorb
                    std       4,s                 midpoint
                    pshs      d
                    jsr       [>pMidiEventPtr]
                    leas      2,s
                    tfr       d,u
                    cmpu      #0
                    lbeq      ms_fail@
                    ldx       6,s
                    ldd       1,u
                    cmpd      1,x
                    blo       ms_after@
                    bhi       ms_before@
                    tst       ,x
                    bne       ms_after@
                    tst       5,x
                    bne       ms_after@
ms_before@          ldd       4,s
                    std       2,s
                    bra       ms_find@
ms_after@           ldd       4,s
                    addd      #1
                    std       ,s
                    bra       ms_find@
ms_insert@          ldd       ,s
                    cmpd      <nevents
                    bne       ms_shift@
* i2p grows the score pages. An append needs no shifting or EventEndTime scan:
* the incoming MIDI record already contains its complete timestamp.
                    pshs      d
                    jsr       [>pMidiEventPtr]
                    leas      2,s
                    cmpd      #0
                    beq       ms_fail@
                    pshs      d
                    ldd       <nevents
                    addd      #1
                    std       <nevents
                    puls      d
                    bra       ms_copy@
ms_shift@           pshs      d
                    jsr       [>UmeData_pmakroom]
                    leas      2,s
ms_copy@            equ       *
                    tfr       d,u
                    cmpu      #0
                    beq       ms_fail@
                    ldx       6,s
                    ldd       ,x
                    std       ,u
                    ldd       2,x
                    std       2,u
                    ldd       4,x
                    std       4,u
                    ldd       6,x
                    std       6,u
                    ldd       #1
                    bra       ms_added@
ms_fail@            clra
                    clrb
ms_added@           leas      6,s
                    puls      x,y,u,pc

* Done: the bar lines went in with the events (midi_bars.inc); X = how many.
* The normal Read Score caller performs reinit/redraw and naming afterwards.
MidiScoreDone       pshs      x,y,u
                    stx       <nbars
                    clra
                    clrb
                    std       <gind
                    std       <xgoal
                    std       <curind
                    std       <UmeData_gbar
                    std       <UmeData_gbarind
                    std       <UmeData_lftind
                    std       <UmeData_ritind
                    incb
                    stb       <rfr_scr
                    stb       <UmeData_rfr_bar
                    ldd       #1
                    puls      x,y,u,pc

ms_levels           fcb       1,34,77,87,97,107,117,127    the default MIDI volume levels
