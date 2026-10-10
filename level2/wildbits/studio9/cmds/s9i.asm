* s9i: Standard MIDI File reader, called by Read Score with an already open path.
* Two passes: validate without changing the score, then emit native events.
* SMF 0/1, PPQN timing, running status, overlapping notes. The tracks are merged
* as they are read - one buffered cursor per track, always the track whose next
* event is earliest - so every event and bar line reaches the score by an append:
* no search, no shifting of what is already there. Each part (one instrument) is
* placed on the treble, alto, tenor or bass staff by the middle of its pitch range
* once the first pass has seen it all; MIDI channel 10 goes to the percussion staff.
* Private state is on the stack; no shared scratch DP and no writes to MS_MEN.
                    nam       s9i
                  IFP1
                    use       defsfile
                  ENDC
UME_SCOPE_S9I                  equ       1
                    use       equates.asm
                    mod       eom,name,Prgrm+Objct,ReEnt+1,start,$104C
name                fcs       /s9i/
                    fcb       2
* iprg: program per channel ($80 = none). A part's key is program+1, or $C0+channel
* while the channel has no program (channel 10 always $C9).
* 64 pending notes: channel+1, pitch, start time, track, part+1, event index.
* A note's record goes into the score when it starts (so the score stays in
* time order); its duration is filled in when it ends.
* One track: where its unread bytes sit in the file, how many the chunk still
* owes, running status, its time, the PPQN remainder, when its next event is.

start               pshs      y,u
                    leas      -iframe,s
                    tfr       s,u
                    leax      ,u
                    ldd       #iframe
mi_clear@           clr       ,x+
                    subd      #1
                    bne       mi_clear@
                    ldb       iframe+9,u
                    stb       ipath,u
                    sts       iroot,u
                    leax      iprg,u
                    ldb       #16
                    lda       #$80
mi_noprog@          sta       ,x+
                    decb
                    bne       mi_noprog@
                    ldd       #$FFFF
                    std       ifirstnote,u
                    lbsr      mi_parse
                    tst       iparts,u
                    lbeq      mi_empty
                    lbsr      mi_staves
                    inc       ipass,u
                    leax      imap,u
                    ldy       iframe,u
                    lbsr      MidiScoreInit
                    lbeq      mi_memory
                    lbsr      mi_parse
                    lbsr      mi_finish
                    ldd       imax,u
                    ldx       ibarno,u
                    leax      -1,x                bar lines added
                    ldy       iframe,u
                    lbsr      MidiScoreDone
                    lbeq      mi_memory
                    lda       #1
                    sta       <UmeData_compact                compact notation, independent of raw MIDI timing
                    ldd       #1
mi_exit             leas      iframe,s
                    puls      y,u,pc

* One complete read of the file: header, the chunk table, then the merge.
mi_parse            clr       ifpos,u
                    clr       ifpos+1,u
                    clr       ifpos+2,u
                    clr       ifpos+3,u
                    leax      ifpos,u
                    lbsr      mi_seekx
                    leax      ipool,u
                    ldy       #14
                    lbsr      mi_readn
                    leax      ipool,u
                    ldd       ,x
                    cmpd      #$4D54
                    lbne      mi_bad
                    ldd       2,x
                    cmpd      #$6864
                    lbne      mi_bad
                    ldd       4,x
                    lbne      mi_bad
                    ldd       6,x
                    cmpd      #6
                    lblo      mi_bad
                    addd      #8                  first chunk follows the header
                    std       ifpos+2,u
                    bcc       mi_hdr@
                    inc       ifpos+1,u
mi_hdr@             ldd       8,x
                    cmpd      #1
                    lbhi      mi_format
                    std       itmp,u
                    ldd       10,x
                    lbeq      mi_bad
                    cmpd      #MAXTRK
                    lbhi      mi_tracks
                    std       itracks,u
                    tst       itmp+1,u
                    bne       mi_fmt1@
                    cmpd      #1
                    lbne      mi_bad
mi_fmt1@            ldd       12,x
                    tsta
                    lbmi      mi_format
                    cmpd      #0
                    lbeq      mi_bad
                    std       idiv,u
* The buffer pool is shared out: POOL / tracks bytes each, at most 255.
                    ldx       #0
                    ldd       #POOL
mi_bsz@             subd      itracks,u
                    blo       mi_bszend@
                    leax      1,x
                    bra       mi_bsz@
mi_bszend@          cmpx      #255
                    bls       mi_bszok@
                    ldx       #255
mi_bszok@           stx       ibufsz,u
* Locate every track chunk without reading it: header, then skip its length.
                    leax      itrk0,u
                    stx       itrk,u
                    ldd       itracks,u
                    std       itmp,u
mi_chunk@           leax      ifpos,u
                    lbsr      mi_seekx
                    leax      irec,u
                    ldy       #8
                    lbsr      mi_readn
                    ldd       irec,u
                    cmpd      #$4D54
                    lbne      mi_bad
                    ldd       irec+2,u
                    cmpd      #$726B
                    lbne      mi_bad
                    ldx       itrk,u
                    ldd       irec+4,u
                    std       tleft,x
                    ldd       irec+6,u
                    std       tleft+2,x
                    ldd       ifpos+2,u
                    addd      #8
                    std       tpos+2,x
                    ldd       ifpos,u
                    adcb      #0
                    adca      #0
                    std       tpos,x
                    ldd       tpos+2,x
                    addd      tleft+2,x
                    std       ifpos+2,u
                    ldd       tpos,x
                    adcb      tleft+1,x
                    adca      tleft,x
                    lbcs      mi_bad
                    std       ifpos,u
                    clr       trun,x
                    clr       ttime,x
                    clr       ttime+1,x
                    clr       trem,x
                    clr       trem+1,x
                    clr       tflag,x
                    clr       tbpos,x
                    clr       tblen,x
                    leax      TRKSZ,x
                    stx       itrk,u
                    ldd       itmp,u
                    subd      #1
                    std       itmp,u
                    bne       mi_chunk@
                    leax      iact,u
                    ldd       #64*PENDSZ
mi_aclear@          clr       ,x+
                    subd      #1
                    bne       mi_aclear@
                    clr       ibound,u
                    clr       ibound+1,u
                    ldd       #192
                    std       ibarlen,u
                    ldd       #1
                    std       ibarno,u
                    ldd       #$FFFF
                    std       ilastb,u
* Every track's first delta, so the merge knows where each one starts.
                    leax      itrk0,u
                    stx       itrk,u
                    clr       icur,u
mi_prime@           lbsr      mi_delta
                    ldx       itrk,u
                    leax      TRKSZ,x
                    stx       itrk,u
                    inc       icur,u
                    ldb       icur,u
                    cmpb      itracks+1,u
                    blo       mi_prime@
* The merge: the track whose next event is earliest goes next; on a tie the
* earlier track, so a tempo track's metas precede the notes at the same tick.
mi_select           lda       #$FF
                    sta       itmp+2,u            best track, none yet
                    clr       itmp+3,u
                    leay      itrk0,u
mi_sel@             tst       tflag,y
                    bne       mi_selnext@
                    lda       itmp+2,u
                    cmpa      #$FF
                    beq       mi_seltake@
                    ldd       tnext,y
                    cmpd      itmp,u
                    bhs       mi_selnext@
mi_seltake@         ldd       tnext,y
                    std       itmp,u
                    lda       itmp+3,u
                    sta       itmp+2,u
mi_selnext@         leay      TRKSZ,y
                    inc       itmp+3,u
                    lda       itmp+3,u
                    cmpa      itracks+1,u
                    blo       mi_sel@
                    lda       itmp+2,u
                    cmpa      #$FF
                    lbeq      mi_alldone
                    sta       icur,u
                    ldb       #TRKSZ
                    mul
                    leax      itrk0,u
                    leax      d,x
                    stx       itrk,u
                    ldd       itmp,u
                    std       itime,u
* One event of the current track.
mi_event            lbsr      mi_tbyte
                    tstb
                    bpl       mi_running@
                    stb       istat,u
                    cmpb      #$F0
                    lbhs      mi_system
                    ldx       itrk,u
                    stb       trun,x
                    lbsr      mi_tbyte
                    bra       mi_data@
mi_running@         ldx       itrk,u
                    lda       trun,x
                    lbeq      mi_bad
                    sta       istat,u
mi_data@            tstb
                    lbmi      mi_bad
                    stb       idata,u
                    lda       istat,u
                    anda      #15
                    sta       ichan,u
                    lda       istat,u
                    anda      #$F0
                    cmpa      #$C0
                    beq       mi_channel
                    cmpa      #$D0
                    beq       mi_channel
                    lbsr      mi_tbyte
                    tstb
                    lbmi      mi_bad
                    stb       idata2,u
mi_channel          lbsr      mi_raw
                    lda       istat,u
                    anda      #$F0
                    cmpa      #$C0
                    bne       mi_notprog@
                    ldb       ichan,u
                    leax      iprg,u
                    lda       idata,u
                    sta       b,x
                    lbra      mi_next
mi_notprog@         cmpa      #$90
                    bne       mi_offtest@
                    tst       idata2,u
                    lbne      mi_noteon
mi_offtest@         cmpa      #$80
                    lbeq      mi_noteoff
                    cmpa      #$90
                    lbeq      mi_noteoff
                    lbra      mi_next
mi_alldone          rts
* The event is done: the track's next delta, then back to the merge.
mi_next             lbsr      mi_delta
                    lbra      mi_select
* Preserve every channel message, including polyphonic notes and velocities.
mi_raw              lbsr      mi_record
                    lda       #$40               preserved MIDI; enable on native-score playback
                    sta       irec+6,u
                    lda       #$1E
                    sta       irec+5,u
                    lda       istat,u
                    sta       irec+3,u
                    ldb       idata,u
                    stb       irec+4,u
                    lda       istat,u
                    anda      #$F0
                    cmpa      #$C0
                    beq       mi_one@
                    cmpa      #$D0
                    beq       mi_one@
                    ldb       idata2,u
                    orb       #$80
                    stb       irec+7,u
                    lbra      mi_emit
mi_one@             orb       #$80
                    stb       irec+4,u
                    lbra      mi_emit
mi_send             lbsr      mi_emit
                    lbra      mi_next

mi_system           cmpb      #$FF
                    beq       mi_meta
                    cmpb      #$F0
                    beq       mi_sysex@
                    cmpb      #$F7
                    lbne      mi_bad
mi_sysex@           ldx       itrk,u
                    clr       trun,x
                    lbsr      mi_vlq
                    lbsr      mi_skip
                    lbra      mi_next
mi_meta             ldx       itrk,u
                    clr       trun,x
                    lbsr      mi_tbyte
                    stb       imeta,u
                    lbsr      mi_vlq
                    ldb       imeta,u
                    cmpb      #$2F
                    lbeq      mi_endtrack
                    cmpb      #$51
                    beq       mi_tempo
                    cmpb      #$58
                    beq       mi_meter
                    lbsr      mi_skip
                    lbra      mi_next
mi_tempo            ldd       inum,u
                    lbne      mi_bad
                    ldd       inum+2,u
                    cmpd      #3
                    lbne      mi_bad
                    clr       iden,u
                    lbsr      mi_tbyte
                    stb       iden+1,u
                    lbsr      mi_tbyte
                    stb       iden+2,u
                    lbsr      mi_tbyte
                    stb       iden+3,u
                    ldd       #$0393
                    std       inum,u
                    ldd       #$8700
                    std       inum+2,u
                    lbsr      mi_divide
                    ldd       inum,u
                    lbne      mi_tempoerr
                    ldd       inum+2,u
                    lbeq      mi_tempoerr
                    cmpd      #255
                    lbhi      mi_tempoerr
                    pshs      b
                    lbsr      mi_record
                    puls      b
                    stb       irec+3,u
                    lda       #$19
                    sta       irec+5,u
                    lbra      mi_send
mi_meter            ldd       inum,u
                    lbne      mi_bad
                    ldd       inum+2,u
                    cmpd      #4
                    lbne      mi_bad
                    lbsr      mi_record
                    lbsr      mi_tbyte
                    lbeq      mi_bad
                    cmpb      #32
                    lbhi      mi_bad
                    stb       irec+6,u
                    lbsr      mi_tbyte
                    cmpb      #5
                    lbhi      mi_bad
                    lda       #1
mi_den@             tstb
                    beq       mi_denok@
                    lsla
                    decb
                    bra       mi_den@
mi_denok@           sta       irec+7,u
                    lbsr      mi_tbyte
                    lbsr      mi_tbyte
                    lda       #$0A
                    sta       irec+5,u
                    lbra      mi_send

mi_noteon           ldd       itime,u
                    cmpd      ifirstnote,u
                    bhs       mi_firstset@
                    std       ifirstnote,u
mi_firstset@        tst       ipass,u
                    beq       mi_firstrest@
                    ldd       itime,u
                    cmpd      ifirstnote,u
                    bne       mi_firstrest@
                    lbsr      mi_openrests        finish a partial silent bar before the first note
mi_firstrest@       ldb       idata,u
                    cmpb      #24
                    lblo      mi_pitcherr
                    cmpb      #107
                    lbhi      mi_pitcherr
* A part is an instrument (one may span several channels): its key is the
* channel's program + 1, or $C0 + channel while it has had no program change;
* channel 10 is always its own percussion part (staff 4). Chords share the part.
* A 17th part is an error (mi_polyerr). The part's staff is chosen once, after
* the first pass, from its pitch range (mi_staves).
                    ldb       ichan,u
                    cmpb      #9
                    beq       mi_keych@
                    leax      iprg,u
                    lda       b,x
                    bmi       mi_keych@
                    inca                          program + 1
                    bra       mi_keyed@
mi_keych@           lda       #$C0
                    sta       itmp,u
                    orb       itmp,u
                    tfr       b,a                 $C0 + channel
mi_keyed@           sta       itmp,u
                    clr       imeta,u
mi_voice@           ldb       imeta,u
                    cmpb      iparts,u
                    bhs       mi_newvoice@
                    leax      imap,u
                    lda       b,x
                    cmpa      itmp,u
                    beq       mi_range@
                    inc       imeta,u
                    bra       mi_voice@
mi_newvoice@        cmpb      #16
                    lbhs      mi_polyerr
                    leax      imap,u
                    lda       itmp,u
                    sta       b,x
                    leax      ichn,u
                    lda       ichan,u
                    sta       b,x
                    leax      istf,u
                    clr       b,x
                    lda       ichan,u
                    cmpa      #9
                    bne       mi_pitched@
                    lda       #4
                    sta       b,x
mi_pitched@         lda       idata,u
                    leax      ilo,u
                    sta       b,x
                    leax      ihi,u
                    sta       b,x
                    inc       iparts,u
                    bra       mi_voiceok@
mi_range@           lda       idata,u
                    leax      ilo,u
                    cmpa      b,x
                    bhs       mi_rangehi@
                    sta       b,x
mi_rangehi@         leax      ihi,u
                    cmpa      b,x
                    bls       mi_voiceok@
                    sta       b,x
mi_voiceok@         leax      iact,u
                    ldb       #64
mi_free@            tst       ,x
                    beq       mi_found@
                    leax      PENDSZ,x
                    decb
                    bne       mi_free@
                    lbra      mi_polyerr
mi_found@           lda       ichan,u
                    inca
                    sta       ,x
                    lda       idata,u
                    sta       1,x
                    ldd       itime,u
                    std       2,x
                    lda       icur,u
                    sta       4,x
                    lda       imeta,u
                    inca
                    sta       5,x
                    lbsr      mi_noterec
                    lbra      mi_next
mi_noteoff          leax      iact,u
                    ldb       #64
                    clr       ilen,u
                    clr       ilen+1,u
mi_find@            lda       ichan,u
                    inca
                    cmpa      ,x
                    bne       mi_nextp@
                    lda       idata,u
                    cmpa      1,x
                    bne       mi_nextp@
                    pshs      b
                    ldy       ilen,u
                    beq       mi_oldest@
                    ldd       2,x
                    cmpd      2,y
                    bhs       mi_keep@
mi_oldest@          stx       ilen,u
mi_keep@            puls      b
mi_nextp@           leax      PENDSZ,x
                    decb
                    bne       mi_find@
                    ldx       ilen,u
                    bne       mi_finishnote
                    lbra      mi_next
mi_finishnote       lbsr      mi_note
                    lbra      mi_next
* X = pending note, just started: its record, without a duration yet, goes
* into the score at its start time; the index is kept for the length later.
mi_noterec          stx       iptr,u
                    lbsr      mi_record
                    ldx       iptr,u
                    lda       5,x
                    sta       irec,u
                    ldb       1,x
                    subb      #24
                    clr       itmp,u
mi_oct@             cmpb      #12
                    blo       mi_semi@
                    subb      #12
                    lda       itmp,u
                    adda      #7
                    sta       itmp,u
                    bra       mi_oct@
mi_semi@            leax      mi_steps,pcr
                    lda       b,x
                    adda      itmp,u
                    suba      #23                 native index has C1 = 1; the treble clef offset is 24
                    pshs      b
                    ldb       irec,u
                    decb
                    leax      istf,u
                    ldb       b,x                 its staff
                    leax      mi_stfofs,pcr
                    adda      b,x                 higher by the clef's offset from the treble's 24
                    puls      b
                    sta       irec+5,u
                    leax      mi_acc,pcr
                    lda       b,x
                    sta       irec+6,u
                    lda       #$82               notation only; raw MIDI carries playback
                    sta       irec+7,u
                    lbsr      mi_emit
                    tst       ipass,u
                    beq       mi_norec@
                    ldx       iptr,u
                    ldd       <nevents
                    subd      #1
                    std       6,x                 where the record went
mi_norec@           rts
* X = pending note, ending now: the nearest native duration goes into its
* record in the score; a rounded-up note must finish before the closing bar.
mi_note             stx       iptr,u
                    leax      irec,u
                    clr       3,x
                    clr       4,x
                    ldx       iptr,u
                    ldd       2,x
                    std       irec+1,u
                    ldd       itime,u
                    subd      2,x
                    bne       mi_dur@
                    ldd       #1
mi_dur@             std       ilen,u
                    clr       ,x
* 128th-note notation floor. Native score time is 48 ticks/quarter, so its
* 1.5-tick duration rounds to one tick in the legacy integer duration table.
* Preserve the separately stored raw MIDI timing; only notation is quantized.
* Breve bases 384,576,672,256 (plain, dotted, double-dotted, triplet) shifted
* 0..8; omit 128th triplets.
                    ldd       #$FFFF
                    std       itmp,u
                    clr       itmp+2,u
mi_val@             ldb       itmp+2,u
                    aslb
                    leax      mi_durations,pcr
                    ldd       b,x
                    std       iden,u
                    clr       itmp+3,u
mi_shift@           ldb       itmp+2,u
                    cmpb      #3                  the triplet base
                    bne       mi_cand@
                    ldb       itmp+3,u
                    cmpb      #8                  omit triplets shorter than a plain 128th
                    beq       mi_notbest@
mi_cand@            ldd       iden,u
                    subd      ilen,u
                    bcc       mi_abs@
                    coma
                    comb
                    addd      #1
mi_abs@             cmpd      itmp,u
                    bhs       mi_notbest@
                    std       itmp,u
                    lda       itmp+3,u
                    sta       irec+3,u
                    lda       itmp+2,u
                    sta       irec+4,u
mi_notbest@         lsr       iden,u
                    ror       iden+1,u
                    inc       itmp+3,u
                    lda       itmp+3,u
                    cmpa      #9
                    blo       mi_shift@
                    inc       itmp+2,u
                    lda       itmp+2,u
                    cmpa      #4
                    blo       mi_val@
* A rounded-up note must finish before the closing bar, too.
                    ldb       irec+4,u
                    aslb
                    leax      mi_durations,pcr
                    ldd       b,x
                    pshs      d
                    ldb       irec+3,u
mi_endshift@        tstb
                    beq       mi_endtime@
                    lsr       ,s
                    ror       1,s
                    decb
                    bra       mi_endshift@
mi_endtime@         puls      d
                    addd      irec+1,u
                    lbcs      mi_range
                    cmpd      imax,u
                    bls       mi_endok@
                    std       imax,u
mi_endok@           tst       ipass,u
                    beq       mi_lenok@
                    pshs      y,u
                    ldx       iptr,u
                    ldd       6,x
                    leax      irec,u
                    ldy       iframe,u
                    lbsr      MidiScoreFix
                    puls      y,u
                    lbeq      mi_memory
mi_lenok@           rts
mi_steps            fcb       0,0,1,1,2,3,3,4,4,5,5,6
mi_stfofs           fcb       0,6,8,12,12  treble 24, alto 18, tenor 16, bass 12, percussion drawn as bass
mi_acc              fcb       0,2,0,2,0,0,2,0,2,0,2,0      sharps only: no natural icons
mi_durations        fdb       384,576,672,256

* End of track: this track's unfinished notes end here, at its final tick.
mi_endtrack         ldd       inum,u
                    lbne      mi_bad
                    ldd       inum+2,u
                    lbne      mi_bad
                    leax      iact,u
                    stx       iptr,u
mi_close@           ldx       iptr,u
                    tst       ,x
                    beq       mi_closed@
                    lda       4,x
                    cmpa      icur,u
                    bne       mi_closed@
                    lda       ,x
                    deca
                    ora       #$80
                    sta       istat,u
                    lda       1,x
                    sta       idata,u
                    clr       idata2,u
                    lbsr      mi_raw
                    ldx       iptr,u
                    lbsr      mi_note
mi_closed@          ldx       iptr,u
                    leax      PENDSZ,x
                    stx       iptr,u
                    leay      itrk0,u
                    pshs      y
                    cmpx      ,s++
                    blo       mi_close@
                    ldx       itrk,u
                    inc       tflag,x
                    lbra      mi_select

* After pass 0: every pitched part goes to the staff whose clef centers its
* range - the middle of lowest..highest against G4 (treble), C4 (alto),
* F3 (tenor), below that bass. Percussion parts keep staff 4.
mi_staves           ldb       iparts,u
                    lbra      ImportStaffs
                    use       import_staff.inc

mi_record           leax      irec,u
                    clr       ,x
                    clr       3,x
                    clr       4,x
                    clr       5,x
                    clr       6,x
                    clr       7,x
                    ldd       itime,u
                    std       1,x
                    rts
* Pass 0 counts; pass 1 lays down the bar lines due first, then appends.
mi_emit             tst       ipass,u
                    bne       mi_store@
                    ldd       icount,u
                    addd      #1
                    cmpd      #30000
                    lbhi      mi_range
                    std       icount,u
                    rts
mi_store@           lbsr      mi_bars
                    pshs      y,u
                    leax      irec,u
                    ldy       iframe,u
                    lbsr      MidiScoreAppend
                    puls      y,u
                    lbeq      mi_memory
                    rts
                    use       midi_bars.inc
                    use       midi_read.inc
                    use       midi_score.inc
                    fill      0,$1D00-*           pad to $1D00 bytes so F$Link never puts this overlay in slot 7 and the score page always gets it
                    emod
eom                 equ       *
