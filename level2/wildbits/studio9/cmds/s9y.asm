* s9y: Lyra 2Z reader. C overlay ABI matches s9i: (command, open path).
* Two passes, eight buffered voice cursors merged by score time. Pass zero
* validates before replacing the score. Y is the caller's C static base.
* Format: DaBarnStudio Lyra File Format; pitch reference: Wildbits play.as.
                    nam       s9y
                  IFP1
                    use       defsfile
                  ENDC
UME_SCOPE_S9Y                  equ       1
                    use       equates.asm
                    use       midi.d
                    mod       eom,name,Prgrm+Objct,ReEnt+1,start,$104C
name                fcs       /s9y/
                    fcb       1
* Voice cursor: pos/end/time words, octave/eof/buffer position/length bytes, 64-byte buffer.

start               pshs      y,u
                    leas      -iframe,s
                    tfr       s,u
                    sts       iroot,u
                    leax      4,u
                    ldy       #iframe-4
ly_zero@            clr       ,x+
                    leay      -1,y
                    bne       ly_zero@
                    clr       ipass,u
                    ldb       iframe+9,u           C path low byte; saved Y/U add four bytes
                    stb       ipath,u
                    clra
                    clrb
                    lbsr      ly_seek
                    leax      iheader,u
                    ldy       #$151
                    lbsr      ly_read
                    ldd       iheader,u
                    cmpd      #$325A
                    lbne      ly_headerbad
                    lda       iheader+2,u
                    suba      #'0
                    cmpa      #7
                    lbhi      ly_bad
                    lda       iheader+3,u
                    cmpa      #'S
                    beq       ly_keyok@
                    cmpa      #'F
                    lbne      ly_bad
ly_keyok@           lda       iheader+4,u
                    suba      #'0
                    beq       ly_bad
                    cmpa      #9
                    bhi       ly_bad
                    lda       iheader+5,u
                    cmpa      #'1
                    beq       ly_meterok@
                    cmpa      #'2
                    beq       ly_meterok@
                    cmpa      #'4
                    beq       ly_meterok@
                    cmpa      #'8
                    bne       ly_bad
ly_meterok@         ldd       iheader+$22,u
                    cmpd      #$151
                    lblo      ly_bad
                    lbsr      ly_pass
                    ldd       imax,u
                    lbeq      ly_bad
                    ldb       #8
                    lbsr      ImportStaffs
                    leax      imap,u
                    ldy       iframe,u
                    lbsr      MidiScoreInit
                    lbeq      mi_memory
                    inc       ipass,u
                    lbsr      ly_pass
                    lbsr      mi_finish
                    ldd       imax,u
                    ldx       ibarno,u
                    leax      -1,x
                    ldy       iframe,u
                    lbsr      MidiScoreDone
                    ldd       #1
ly_exit             leas      iframe,s
                    puls      y,u,pc
ly_bad              leax      ly_badmsg,pcr
                    lbra      ly_error
ly_headerbad        leax      ly_headmsg,pcr
                    lbra      ly_error
ly_toolong          leax      ly_longmsg,pcr
                    lbra      ly_error

ly_pass             clr       93,u                inline MIDI running status
                    clr       95,u                inline MIDI data count
                    clr       icur,u
                    clr       imax,u
                    clr       imax+1,u
                    clr       ibound,u
                    clr       ibound+1,u
                    ldd       #1
                    std       ibarno,u
                    lda       iheader+4,u
                    suba      #'0
                    ldb       #192
                    mul
                    std       ibarlen,u
                    ldb       iheader+5,u
                    subb      #'0
ly_barlen@          lsrb
                    beq       ly_barset@
                    lsr       ibarlen,u
                    ror       ibarlen+1,u
                    bra       ly_barlen@
ly_barset@          lda       #16
                    sta       inpatch,u
                    ldd       #$FFFF
                    std       ilastb,u
                    lbsr      ly_seedacc
                    leax      itracks,u
ly_init@            stx       itrk,u
                    ldb       icur,u
                    aslb
                    leay      iheader+$10,u       file-relative voice offsets, as in play.as
                    ldd       b,y
                    std       tpos,x
                    clr       teof,x
                    cmpd      #0
                    beq       ly_absent@
                    cmpd      #$151
                    lblo      ly_bad
                    cmpd      iheader+$22,u
                    lbhs      ly_bad
                    bra       ly_bound@
ly_absent@          inc       teof,x
ly_bound@           ldd       iheader+$22,u
                    std       tend,x
                    leay      iheader+$10,u
                    ldb       #8
ly_limit@           pshs      b
                    ldd       ,y++
                    cmpd      tpos,x
                    bls       ly_limnext@
                    cmpd      tend,x
                    bhs       ly_limnext@
                    std       tend,x
ly_limnext@         puls      b
                    decb
                    bne       ly_limit@
                    clr       ttime,x
                    clr       ttime+1,x
                    clr       toct,x
                    clr       tbpos,x
                    clr       tblen,x
                    clr       tactive,x
                    clr       tpvalid,x
                    ldd       ibarlen,u
                    std       tbar,x
                    lbsr      ly_resetacc
                    ldd       #$FFFF
                    std       tofftime,x
                    ldb       icur,u
                    aslb
                    aslb
                    leay      iheader+$131,u
                    lda       b,y
                    suba      #'0
                    beq       ly_fullgate@
                    cmpa      #8
                    bls       ly_gateinit@
ly_fullgate@        lda       #8                  blank/zero headers mean full length
ly_gateinit@        sta       tgate,x
                    lda       #100
                    sta       tvel,x
                    leax      TSZ,x
                    inc       icur,u
                    ldb       icur,u
                    cmpb      #8
                    lblo      ly_init@
                    clr       itime,u
                    clr       itime+1,u
                    lbsr      ly_record
                    lda       #$0A
                    sta       irec+5,u
                    lda       iheader+4,u
                    suba      #'0
                    sta       irec+6,u
                    lda       iheader+5,u
                    suba      #'0
                    sta       irec+7,u
                    lbsr      ly_emit
                    lbsr      ly_record
                    lda       #$0B
                    sta       irec+5,u
                    ldb       iheader+2,u
                    subb      #'0
                    lda       iheader+3,u
                    cmpa      #'F
                    bne       ly_keysig@
                    negb
ly_keysig@          sex
                    stb       irec+6,u
                    lbsr      ly_emit
                    lbsr      ly_setup
                    ldb       #40
                    lbsr      ly_tempo
* Earliest voice first; each voice keeps its identity even on shared MIDI channels.
ly_select           ldd       #$FFFF
                    std       42,u                best time
                    clr       44,u                scan index
                    ldy       #0
                    leax      itracks,u
ly_scan@            tst       teof,x
                    bne       ly_scnext@
                    ldd       ttime,x
                    cmpd      tofftime,x
                    bls       ly_scanwhen@
                    ldd       tofftime,x
ly_scanwhen@        cmpd      42,u
                    bhs       ly_scnext@
                    std       42,u
                    tfr       x,y
                    lda       44,u
                    sta       icur,u
ly_scnext@          leax      TSZ,x
                    inc       44,u
                    lda       44,u
                    cmpa      #8
                    blo       ly_scan@
                    cmpy      #0
                    beq       ly_passdone
                    sty       itrk,u
                    ldd       42,u
                    std       itime,u
                    cmpd      tofftime,y
                    bne       ly_source@
                    lbsr      ly_off             timed release, not a new score position
                    lbra      ly_select
ly_source@          lbsr      ly_word
                    std       lycode,u
                    beq       ly_endvoice
                    lbsr      ly_record
                    lda       lycode,u
                    lbmi      ly_event
                    lbra      ly_note
ly_endvoice         lbsr      ly_off
                    ldx       itrk,u
                    inc       teof,x
                    lbra      ly_select
ly_passdone         tst       95,u
                    lbne      ly_bad
                    rts

ly_word             ldx       itrk,u
                    tst       tpvalid,x
                    beq       ly_fetch@
                    clr       tpvalid,x
                    ldd       tpref,x
                    rts
ly_fetch@           ldb       tbpos,x
                    cmpb      tblen,x
                    blo       ly_buffer@
                    ldd       tend,x
                    subd      tpos,x
                    cmpd      #2
                    lblo      ly_bad
                    cmpd      #64
                    bls       ly_chunk@
                    ldd       #64
ly_chunk@           stb       tblen,x
                    clr       tbpos,x
                    pshs      d
                    ldd       tpos,x
                    lbsr      ly_seek
                    ldx       itrk,u
                    ldd       tpos,x
                    addd      ,s
                    std       tpos,x
                    leax      tbuf,x
                    puls      y
                    lbsr      ly_read
                    ldx       itrk,u
                    clrb
ly_buffer@          leay      tbuf,x
                    leay      b,y
                    inc       tbpos,x
                    inc       tbpos,x
                    ldd       ,y
                    rts
* Helpers preserve the importer frame U on all OS-9 paths.
ly_seek             pshs      x,y,u
                    tfr       d,u
                    ldx       #0
                    ldy       4,s
                    lda       ipath,y
                    os9       I$Seek
                    puls      x,y,u
                    lbcs      ly_bad
                    rts
ly_read             pshs      y,u
                    lda       ipath,u
                    os9       I$Read
                    bcs       ly_short@
                    cmpy      ,s
                    puls      y,u
                    lbne      ly_bad
                    rts
ly_short@           puls      y,u
                    lbra      ly_bad

ly_record           leax      irec,u
                    ldb       #8
ly_recclr@          clr       ,x+
                    decb
                    bne       ly_recclr@
                    ldd       itime,u
                    std       irec+1,u
                    rts
ly_note             anda      #7
                    lbeq      ly_select          zero-duration placeholders have no sounding note
                    ldb       lycode,u
                    bitb      #8
                    bne       ly_norest@          a rest: the pending markers wait for a sounding note
                    pshs      a
                    lbsr      ly_flush            the voice's pending markers go out first, at this note's time
                    lbsr      ly_record           the note's record again (the flush used irec)
                    puls      a
ly_norest@          sta       irec+3,u
                    ldb       lycode,u
                    andb      #$50
                    cmpb      #$50
                    beq       ly_plain@
                    cmpb      #$40
                    bne       ly_trip@
                    inc       irec+4,u
                    bra       ly_plain@
ly_trip@            cmpb      #$10
                    bne       ly_plain@
                    ldb       #3
                    stb       irec+4,u
ly_plain@           ldb       irec+4,u
                    aslb
                    leax      ly_lengths,pcr
                    ldd       b,x
                    pshs      d
                    ldb       irec+3,u
ly_dur@             lsr       ,s
                    ror       1,s
                    decb
                    bne       ly_dur@
                    puls      d
                    std       idur,u
                    ldb       icur,u
                    leax      imap,u
                    lda       #1
                    sta       b,x
                    leax      iheader+$121,u
                    lda       b,x
                    cmpa      #15
                    lbhi      ly_bad
                    pshs      b
                    leax      iperc,u
                    ldb       a,x
                    beq       ly_nondrum@
                    lda       #9
ly_nondrum@         puls      b
                    leax      ichn,u
                    sta       b,x
                    incb
                    stb       irec,u
                    ldb       lycode,u
                    bitb      #8
                    beq       ly_pitch@
                    lda       #32
                    sta       irec+5,u
                    bra       ly_noteready@
ly_pitch@           ldb       ivalue,u
                    andb      #$3F
                    cmpb      #57
                    lbhi      ly_bad
                    lda       #20                 D7 (MIDI 98): index 44 with C1 = 1, less the treble clef offset 24
                    pshs      b
                    suba      ,s+
                    ldx       itrk,u
                    adda      toct,x
                    sta       irec+5,u
ly_staff@           ldb       icur,u
                    leax      istf,u
                    ldb       b,x
                    leax      ly_stfofs,pcr
                    lda       irec+5,u
                    adda      b,x
                    sta       irec+5,u
                    lbsr      ly_accidental
ly_noteready@       lda       lycode,u
                    bita      #$20
                    bne       ly_tienote@
                    pshs      d
                    lbsr      ly_sound
                    puls      d
                    bra       ly_notedraw@
ly_tienote@         lbsr      ly_sound
ly_notedraw@        lda       #$82
                    sta       irec+7,u
                    lbsr      ly_emit
                    lbsr      ly_gate
                    ldx       itrk,u
                    ldd       ttime,x
                    addd      idur,u
                    lbcs      ly_toolong
                    cmpd      #$FFFF
                    lbeq      ly_toolong
                    std       ttime,x
                    cmpd      imax,u
                    bls       ly_next@
                    std       imax,u
ly_next@            lbra      ly_select
ly_event            anda      #$F0
                    cmpa      #$80
                    lbeq      ly_macro
                    cmpa      #$C0
                    beq       ly_octave
                    cmpa      #$D0
                    lbeq      ly_loco
                    cmpa      #$90
                    lbeq      ly_program
                    cmpa      #$A0
                    bne       ly_evvolume@
                    ldb       ivalue,u
                    lbsr      ly_tempo
                    lbra      ly_select
ly_evvolume@        cmpa      #$E0
                    bne       ly_evclock@
                    ldb       lycode,u
                    andb      #7
                    leax      iheader+$129,u
                    lda       b,x
                    cmpa      #127
                    lbhi      ly_bad
                    ldx       itrk,u
                    sta       tvel,x
                    lbra      ly_select
ly_evclock@         cmpa      #$B0
                    lbeq      ly_midibyte
                    cmpa      #$F0
                    beq       ly_next@            external clock switch: no score duration
                    lbra      ly_unsupported
* Empty named footer macros occur in the collection (REFLECT); no MIDI bytes to send. A macro with content,
* or one past the four the footer holds, is dropped (the score imports without it) instead of rejecting the file.
ly_macro            ldb       lycode,u
                    andb      #15
                    cmpb      #3
                    lbhi      ly_select
                    lda       #56
                    mul
                    addd      iheader+$22,u
                    addd      #6
                    lbsr      ly_seek
                    leax      imacro,u
                    ldy       #56
                    lbsr      ly_read
                    leax      imacro+13,u
                    ldb       #43
ly_mempty@          lda       ,x+
                    cmpa      #C$SPAC
                    beq       ly_mnext@
                    cmpa      #C$CR
                    beq       ly_mnext@
                    tsta
                    lbne      ly_select           content: the macro is dropped, the score goes on
ly_mnext@           decb
                    bne       ly_mempty@
                    lbra      ly_select
ly_octave           ldx       itrk,u
                    lda       #7
                    tst       ivalue,u
                    bmi       ly_octset@
                    lda       #-7
ly_octset@          sta       toct,x
                    lbra      ly_next@
ly_loco             ldx       itrk,u
                    clr       toct,x
                    lbra      ly_next@
* Accidental state is per voice/pitch and resets at a measure. Seed it from
* the displayed key signature, then explicitly cancel when Lyra's pitch flags
* request a natural. This changes notation only, never the source MIDI pitch.
ly_resetacc         pshs      a,b,x,y
                    leay      iaccseed,u
                    leax      tacc,x
                    ldb       #64
ly_accopy@          lda       ,y+
                    sta       ,x+
                    decb
                    bne       ly_accopy@
                    puls      a,b,x,y,pc
* Build the key template once per pass; each bar reset is only a 64-byte copy.
ly_seedacc          pshs      a,b,x,y
                    leay      iaccseed,u
                    clrb
ly_acseed@          pshs      b
                    lda       #1                  D at Lyra pitch index zero
ly_acmod@           tstb
                    beq       ly_ackey@
                    deca
                    bpl       ly_acnext@
                    lda       #6
ly_acnext@          decb
                    bra       ly_acmod@
ly_ackey@           leax      ly_sharps,pcr
                    ldb       iheader+3,u
                    cmpb      #'S
                    beq       ly_actab@
                    leax      ly_flats,pcr
ly_actab@           ldb       iheader+2,u
                    subb      #'0
ly_ackloop@         tstb
                    beq       ly_acnatural@
                    cmpa      ,x+
                    beq       ly_acfound@
                    decb
                    bra       ly_ackloop@
ly_acnatural@       clra
                    bra       ly_acstore@
ly_acfound@         lda       #1
                    ldb       iheader+3,u
                    cmpb      #'S
                    beq       ly_acstore@
                    nega
ly_acstore@         sta       ,y+
                    puls      b
                    incb
                    cmpb      #64
                    blo       ly_acseed@
                    puls      a,b,x,y,pc
ly_accidental       ldx       itrk,u
                    ldd       ttime,x
                    cmpd      tbar,x
                    blo       ly_acpitch@
                    lbsr      ly_resetacc
ly_acbar@           ldd       tbar,x
                    addd      ibarlen,u
                    bcs       ly_aclast@
                    std       tbar,x
                    cmpd      ttime,x
                    bls       ly_acbar@
                    bra       ly_acpitch@
ly_aclast@          ldd       #$FFFF
                    std       tbar,x
ly_acpitch@         ldb       ivalue,u
                    andb      #$3F
                    leax      tacc,x
                    lda       ivalue,u
                    anda      #$C0
                    beq       ly_aczero@
                    cmpa      #$C0
                    beq       ly_aczero@
                    cmpa      #$40
                    bne       ly_acflat@
                    lda       #1
                    bra       ly_accompare@
ly_acflat@          lda       #$FF
                    bra       ly_accompare@
ly_aczero@          clra
ly_accompare@       cmpa      b,x
                    beq       ly_acdone@
                    sta       b,x
                    tsta
                    beq       ly_acnatglyph@
                    bmi       ly_acflatglyph@
                    lda       #2
                    bra       ly_acglyph@
ly_acflatglyph@     lda       #7
                    bra       ly_acglyph@
ly_acnatglyph@      lda       #4                  visible natural; code 1 is silent cancellation
ly_acglyph@         sta       irec+6,u
ly_acdone@          rts
* Preserve the notation record while emitting its exact MIDI transitions.
ly_sound            leax      irec,u
                    ldd       6,x
                    pshs      d
                    ldd       4,x
                    pshs      d
                    ldd       2,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    lda       lycode,u
                    bita      #8
                    lbne      ly_srest@
                    ldb       ivalue,u
                    andb      #$3F
                    leax      ly_pitches,pcr
                    lda       b,x
                    ldx       itrk,u
                    ldb       toct,x
                    beq       ly_spitch@
                    bmi       ly_slow@
                    adda      #12
                    bra       ly_spitch@
ly_slow@            suba      #12
ly_spitch@          sta       45,u
                    ldb       ivalue,u
                    andb      #$C0
                    cmpb      #$C0
                    beq       ly_sready@
                    cmpb      #$40
                    bne       ly_sflat@
                    inc       45,u
                    bra       ly_sready@
ly_sflat@           cmpb      #$80
                    bne       ly_skey@
                    dec       45,u
                    bra       ly_sready@
ly_skey@            bra       ly_sready@          Lyra flags already encode the sounding pitch
ly_sready@          ldb       icur,u
                    leax      iheader+$121,u
                    ldb       b,x
                    leax      iperc,u
                    lda       b,x
                    beq       ly_snormal@
                    sta       45,u
ly_snormal@         lbsr      ly_range
                    lda       lycode,u
                    bita      #$20
                    beq       ly_retrigger@
                    ldx       itrk,u
                    tst       tactive,x
                    beq       ly_retrigger@
                    lda       45,u
                    cmpa      tpitch,x
                    bne       ly_retrigger@      changed pitch is a new attack, as in play.as
                    lda       tchannel,x
                    ldb       icur,u
                    leax      ichn,u
                    cmpa      b,x
                    bne       ly_retrigger@      patch changes can move a voice off percussion
                    bra       ly_srestore@
ly_retrigger@       lbsr      ly_off
                    lbsr      ly_record
                    ldb       icur,u
                    leax      ichn,u
                    lda       b,x
                    ldx       itrk,u
                    sta       tchannel,x
                    ora       #$90
                    sta       irec+3,u
                    lda       45,u
                    sta       irec+4,u
                    ldx       itrk,u
                    sta       tpitch,x
                    inc       tactive,x
                    lda       tvel,x
                    ora       #$80
                    sta       irec+7,u
                    lbsr      ly_raw
                    bra       ly_srestore@
ly_srest@           lbsr      ly_off
ly_srestore@        leax      irec,u
                    puls      d
                    std       ,x
                    puls      d
                    std       2,x
                    puls      d
                    std       4,x
                    puls      d
                    std       6,x
                    rts
ly_off              ldx       itrk,u
                    ldd       #$FFFF
                    std       tofftime,x
                    tst       tactive,x
                    beq       ly_offdone@
                    clr       tactive,x
                    lbsr      ly_record
                    ldx       itrk,u
                    lda       tchannel,x       release on the channel used by this note-on
                    ora       #$80
                    sta       irec+3,u
                    ldx       itrk,u
                    lda       tpitch,x
                    sta       irec+4,u
                    lda       #$80
                    sta       irec+7,u
                    lbsr      ly_raw
ly_offdone@         rts
* Schedule releases in the same chronological merge as note starts. Keep the
* full notation duration: shortening a gate must not move ANY voice's onset.
* Read one pair ahead to keep an immediately tied same-pitch note sounding.
* No C arguments. U is the private frame; stack holds only gate arithmetic.
ly_gate             ldx       itrk,u
                    tst       tactive,x
                    beq       ly_gdone@
                    lda       tgate,x
                    cmpa      #8
                    beq       ly_gdone@
                    lbsr      ly_word
                    ldx       itrk,u
                    std       tpref,x
                    inc       tpvalid,x
                    bita      #$20
                    beq       ly_gcalc@
                    bita      #$88                not a rest or event
                    bne       ly_gcalc@
                    cmpb      ivalue,u
                    beq       ly_gdone@
ly_gcalc@           ldd       idur,u
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb                         Lyra rounds duration/8 BEFORE multiplying
                    pshs      b
                    lda       #8
                    suba      tgate,x
                    ldb       ,s+
                    mul
                    pshs      d
                    ldd       idur,u
                    subd      ,s++               duration - floor(duration/8)*(8-fraction)
                    addd      itime,u
                    bcs       ly_gdone@           main duration overflow check follows
                    std       tofftime,x
ly_gdone@           rts
* Collect the complete sounding range in pass zero; never move a part mid-score.
* No stack arguments; preserves U/Y and the saved notation record in ly_sound.
ly_range            tst       ipass,u
                    bne       ly_rngdone@
                    ldb       icur,u
                    leax      ichn,u
                    lda       b,x
                    cmpa      #9
                    bne       ly_rngpitch@
                    leax      istf,u
                    lda       #4
                    sta       b,x
ly_rngpitch@        lda       45,u
                    leax      iseen,u
                    tst       b,x
                    bne       ly_rnglo@
                    inc       b,x
                    leax      ilo,u
                    sta       b,x
                    leax      ihi,u
                    sta       b,x
                    rts
ly_rnglo@           leax      ilo,u
                    cmpa      b,x
                    bhs       ly_rnghi@
                    sta       b,x
ly_rnghi@           leax      ihi,u
                    cmpa      b,x
                    bls       ly_rngdone@
                    sta       b,x
ly_rngdone@         rts
ly_raw              lda       #$1E
                    sta       irec+5,u
                    lda       #$40
                    sta       irec+6,u
                    lbra      ly_emit
* MIDI-byte markers form ordinary MIDI messages; do not send incomplete data.
ly_midibyte         ldb       ivalue,u
                    cmpb      #$F8
                    lbhs      ly_realtime
                    cmpb      #$80
                    blo       ly_mididata
                    tst       95,u
                    lbne      ly_bad
                    cmpb      #$F0
                    blo       ly_mstatus@
* SysEx / system-common ($F0-$F7) is dropped, as s9i drops a .mid SysEx (mi_sysex@): running status
* cleared, so the data bytes that follow are ignored until the next channel status; the score still imports.
                    clr       93,u
                    clr       95,u
                    lbra      ly_select
ly_mstatus@         stb       93,u
                    andb      #$F0
                    lda       #1
                    cmpb      #$C0
                    beq       ly_midineed@
                    cmpb      #$D0
                    beq       ly_midineed@
                    inca
ly_midineed@        sta       94,u
                    lbra      ly_select
ly_mididata         tst       93,u
                    lbeq      ly_select          MIDI data without running status is ignored by a receiver
                    ldb       95,u
                    leax      96,u
                    lda       ivalue,u
                    sta       b,x
                    inc       95,u
                    ldb       95,u
                    cmpb      94,u
                    lblo      ly_select
                    clr       95,u
                    lda       93,u
                    sta       irec+3,u
                    lda       96,u
                    ldb       94,u
                    cmpb      #1
                    bne       ly_miditwo@
                    ora       #$80
                    sta       irec+4,u
                    bra       ly_midisend@
ly_miditwo@         sta       irec+4,u
                    lda       97,u
                    ora       #$80
                    sta       irec+7,u
ly_midisend@        lda       irec+3,u
                    anda      #$F0
                    cmpa      #$C0
                    beq       ly_midipatch
                    lbsr      ly_raw
                    lbra      ly_select
ly_midipatch        lda       irec+3,u
                    anda      #15
                    sta       98,u
                    lda       irec+4,u
                    anda      #$7F
                    sta       99,u
                    ldb       #16
                    leax      ipatches,u
ly_mpscan@          cmpb      inpatch,u
                    bhs       ly_mpnew@
                    cmpa      b,x
                    beq       ly_mpuse@
                    incb
                    bra       ly_mpscan@
ly_mpnew@           cmpb      #64
                    lbhs      ly_unsupported
                    sta       b,x
                    inc       inpatch,u
                    tst       ipass,u
                    beq       ly_mpuse@
                    pshs      b
                    aslb
                    ldx       #$075F
                    leax      b,x                 slot <= 63, so 2*slot stays positive for b,x
                    ora       #$80
                    sta       1,x
                    puls      b
ly_mpuse@           stb       pselect,u
                    clr       pvoice,u
ly_mpvoice@         ldb       pvoice,u
                    leax      iheader+$121,u
                    lda       b,x
                    cmpa      98,u
                    bne       ly_mpnext@
                    leax      iperc,u
                    clr       a,x
                    lda       pvoice,u
                    ldb       pselect,u
                    lbsr      ly_instr
ly_mpnext@          inc       pvoice,u
                    lda       pvoice,u
                    cmpa      #8
                    blo       ly_mpvoice@
                    lbra      ly_select
ly_realtime         andb      #$0F
                    orb       #$80
                    stb       irec+3,u
                    lda       #$1F
                    sta       irec+5,u
                    lda       #$40
                    sta       irec+6,u
                    lbsr      ly_emit
                    lbra      ly_select
* Lyra $9n selects header instrument n for this voice. Byte 2 is a
* drawing position, NOT a MIDI program number (original Lyra 2.85 $1B9E).
ly_program          ldb       lycode,u
                    andb      #15
                    stb       pselect,u
                    leax      ipatches,u
                    lda       b,x
                    tsta
                    bmi       ly_drumset@
                    clra
ly_drumset@         anda      #$7F
                    pshs      a
                    ldb       icur,u
                    leax      iheader+$121,u
                    ldb       b,x
                    leax      iperc,u
                    puls      a
                    sta       b,x
                    lda       icur,u
                    ldb       pselect,u
                    lbsr      ly_instr
                    lbra      ly_select
* A = zero-based voice, B = native instrument slot. Balanced local saves;
* U stays the private frame. Emit ordinary channel/instrument events so
* INSTRS edits are looked up at play time, not bypassed as raw MIDI bytes.
* A select emits nothing: it records the voice's pending channel and instrument (only when they differ
* from the last marker given), and ly_flush emits them at the voice's next note, just before it.
* A later select that returns to the marker already given cancels the pending one: Lyra writes selects
* in pairs (such as $9C,$94), and the first must not reach the part. A percussion select also cancels a
* pending melodic program.
ly_instr            sta       pvoice,u
                    stb       pselect,u
                    ldb       pvoice,u
                    leax      imap,u
                    tst       b,x
                    beq       ly_idone@
                    leax      iheader+$121,u
                    lda       b,x
                    leax      iperc,u
                    tst       a,x
                    beq       ly_ichan@
                    lda       #9
ly_ichan@           leax      ichn,u
                    sta       b,x
                    leax      ilastc,u
                    cmpa      b,x
                    bne       ly_ipendc@
                    lda       #$FF                the channel already given: nothing pending
ly_ipendc@          leax      pendc,u
                    sta       b,x
                    ldb       pselect,u
                    leax      ipatches,u
                    lda       #$FF                nothing pending unless a new melodic slot
                    tst       b,x
                    bmi       ly_ipendi@          fixed percussion note, no melodic program
                    lda       pselect,u
                    ldb       pvoice,u
                    leax      ilast,u
                    cmpa      b,x
                    bne       ly_ipendi@
                    lda       #$FF                the instrument already given: nothing pending
ly_ipendi@          ldb       pvoice,u
                    leax      pendi,u
                    sta       b,x
ly_idone@           rts
* ly_flush: the pending channel and instrument markers of voice icur, emitted now (at itime, the note's time);
* the last-given tables updated. pvoice/pselect are its scratch (ly_instr is never inside a note).
ly_flush            ldb       icur,u
                    stb       pvoice,u
                    leax      pendc,u
                    lda       b,x
                    cmpa      #$FF
                    beq       ly_fl1@
                    sta       pselect,u
                    lda       #$FF
                    sta       b,x
                    lbsr      ly_record
                    ldb       pvoice,u
                    lda       pselect,u
                    leax      ilastc,u
                    sta       b,x
                    sta       irec+7,u
                    incb
                    stb       irec+6,u
                    lda       #$16
                    sta       irec+5,u
                    lbsr      ly_emit
ly_fl1@             ldb       pvoice,u
                    leax      pendi,u
                    lda       b,x
                    cmpa      #$FF
                    beq       ly_fl9@
                    sta       pselect,u
                    lda       #$FF
                    sta       b,x
                    lbsr      ly_record
                    ldb       pvoice,u
                    lda       pselect,u
                    leax      ilast,u
                    sta       b,x
                    sta       irec+7,u
                    incb
                    stb       irec+6,u
                    lda       #$17
                    sta       irec+5,u
                    lbsr      ly_emit
ly_fl9@             rts
* Initial channel patches: same synth-prefix selection and tables as play.as.
ly_setup            leax      iperc,u
                    ldb       #16
ly_pzero@           clr       ,x+
                    decb
                    bne       ly_pzero@
                    leax      ilastc,u            no marker given yet, nothing pending, any voice
                    ldb       #64
                    lda       #$FF
ly_pnone@           sta       ,x+
                    decb
                    bne       ly_pnone@
                    leax      ly_patchnames,pcr
ly_pmap@            ldd       ,x++
                    beq       ly_pnomap@
                    leay      ly_patchnames,pcr
                    leay      d,y
                    sty       ipatchmap,u
                    lda       ,x+
                    sta       ipatchlen,u
                    leay      iheader+$104,u
ly_pmatch@          lda       ,x+
                    beq       ly_pfound@
                    ldb       ,y+
                    cmpb      #'a
                    blo       ly_pupper@
                    cmpb      #'z
                    bhi       ly_pupper@
                    subb      #32
ly_pupper@          pshs      b
                    cmpa      ,s+
                    beq       ly_pmatch@
ly_pskip@           lda       ,x+
                    bne       ly_pskip@
                    bra       ly_pmap@
ly_pnomap@          clr       ipatchlen,u
ly_pfound@          clr       ipatchidx,u
ly_pchan@           ldb       ipatchidx,u
                    leax      ipatches,u
                    clr       b,x
                    lda       ipatchidx,u
                    ldb       #14
                    mul
                    leax      iheader+$26,u
                    leax      d,x
                    clr       45,u
                    ldy       #3
ly_pdigit@          ldb       ,x+
                    cmpb      #C$SPAC
                    beq       ly_pdnext@
                    subb      #'0
                    cmpb      #9
                    bhi       ly_pnext@
                    pshs      b
                    lda       45,u
                    ldb       #10
                    mul
                    tsta
                    lbne      ly_poverflow@
                    addb      ,s+
                    bcs       ly_pnext@
                    stb       45,u
ly_pdnext@          leay      -1,y
                    bne       ly_pdigit@
* X = the entry's name (after "NNN "). A rhythm-pattern name is a drum part whatever the number says;
* otherwise the number through the synth's table; a number past it, or a row mapped to nothing, is decided by the name;
* a name nobody knows falls back to the number itself when it is a MIDI program, else the entry stays unmapped.
                    leax      1,x
                    leay      ly_rhythms,pcr
                    lbsr      ly_namematch
                    bcs       ly_pstore@
                    ldb       45,u
                    cmpb      ipatchlen,u
                    bhs       ly_pbyname@
                    ldy       ipatchmap,u
                    clra
                    ldb       d,y
                    bne       ly_pstore@          a mapped row
ly_pbyname@         leay      ly_tonenames,pcr
                    lbsr      ly_namematch
                    bcs       ly_pstore@
                    ldb       45,u
                    cmpb      #127
                    bhi       ly_pnext@
ly_pstore@          lda       ipatchidx,u
                    leax      ipatches,u
                    stb       a,x
                    tstb
                    bpl       ly_pnext@
                    andb      #$7F
                    leax      iperc,u
                    stb       a,x
ly_pnext@           inc       ipatchidx,u
                    lda       ipatchidx,u
                    cmpa      #16
                    lblo      ly_pchan@
                    tst       ipass,u
                    beq       ly_pinitial@
                    lda       #1
                    sta       <UmeData_instren                enable ordinary instrument changes
                    ldx       #$075F
                    ldy       #$07EB
                    ldb       #64
ly_pclear@          clr       ,x+
                    lda       #$80
                    sta       ,x+
                    clr       ,y
                    leay      16,y
                    decb
                    bne       ly_pclear@
                    clr       ipatchidx,u
ly_pnative@         ldb       ipatchidx,u
                    leax      ipatches,u
                    lda       b,x
                    pshs      b
                    aslb
                    ldx       #$075F
                    leax      b,x
                    ora       #$80
                    sta       1,x
                    puls      a
                    pshs      a
                    ldb       #16
                    mul
                    ldy       #$07EB
                    leay      d,y
                    puls      a
                    ldb       #14
                    mul
                    leax      iheader+$2A,u
                    leax      d,x
                    ldb       #7
ly_pname@           lda       ,x+
                    cmpa      #32
                    bhs       ly_pchar@
                    lda       #32
ly_pchar@           sta       ,y+
                    decb
                    bne       ly_pname@
                    clr       ,y
                    inc       ipatchidx,u
                    lda       ipatchidx,u
                    cmpa      #16
                    blo       ly_pnative@
ly_pinitial@        clr       ipatchidx,u
ly_pvoice@          ldb       ipatchidx,u
                    leax      iheader+$121,u
                    lda       b,x
                    exg       a,b
                    lbsr      ly_instr
                    inc       ipatchidx,u
                    lda       ipatchidx,u
                    cmpa      #8
                    blo       ly_pvoice@
                    rts
ly_poverflow@       leas      1,s
                    lbra      ly_pnext@
ly_patchnames       fdb       CASIO_CZ230S-ly_patchnames
                    fcb       CASIO_CZ230S_END-CASIO_CZ230S
                    fcc       /CASIO CZ-230/
                    fcb       0
                    fdb       CASIO_CZ230S-ly_patchnames
                    fcb       CASIO_CZ230S_END-CASIO_CZ230S
                    fcc       /CZ-230/
                    fcb       0
                    fdb       CASIO_CT460-ly_patchnames
                    fcb       CASIO_CT460_END-CASIO_CT460
                    fcc       /CASIO CT-460/
                    fcb       0
                    fdb       CASIO_MT540-ly_patchnames
                    fcb       CASIO_MT540_END-CASIO_MT540
                    fcc       /CASIO MT-540/
                    fcb       0
                    fdb       KAWAI_MS710-ly_patchnames
                    fcb       KAWAI_MS710_END-KAWAI_MS710
                    fcc       /KAWAI MS-710/
                    fcb       0
                    fdb       0
* Lyra 2.85 $1D0B timing loop, NTSC slow clock (894886 Hz):
* each 1/48-quarter unit takes marker*(8*master+12)+296 cycles when idle.
* 296 is the fixed eight-voice scan/MIDI-poll/padding overhead. Actual MIDI
* transfers add small data-dependent overhead in Lyra, not score time here.
* Native s9 tempo counts denominator beats (dotted beats in compound meter),
* so numerator is (60*894886/192)*denominator, divided by cycles per unit
* and by 3 in compound meter. Round once after all factors, not twice.
ly_tempo            tstb
                    lbeq      ly_bad
                    stb       47,u
                    ldd       iheader+6,u
                    lbeq      ly_bad
                    std       imod+2,u
                    clr       imod,u
                    clr       imod+1,u
                    ldb       #3
ly_m8@              lsl       imod+3,u
                    rol       imod+2,u
                    rol       imod+1,u
                    rol       imod,u
                    decb
                    bne       ly_m8@
                    ldd       imod+2,u
                    addd      #12
                    std       imod+2,u
                    ldd       imod,u
                    adcb      #0
                    adca      #0
                    std       imod,u
                    clr       iden,u
                    clr       iden+1,u
                    clr       iden+2,u
                    clr       iden+3,u
ly_tmadd@           ldd       iden+2,u
                    addd      imod+2,u
                    std       iden+2,u
                    ldd       iden,u
                    adcb      imod+1,u
                    adca      imod,u
                    std       iden,u
                    dec       47,u
                    bne       ly_tmadd@
                    ldd       iden+2,u
                    addd      #296
                    std       iden+2,u
                    ldd       iden,u
                    adcb      #0
                    adca      #0
                    std       iden,u
                    ldd       #$0004
                    std       inum,u
                    ldd       #$4464              round(60*894886/192) = 279652
                    std       inum+2,u
                    ldb       iheader+5,u
                    subb      #'0
ly_tden@            lsrb
                    beq       ly_compound@
                    lsl       inum+3,u
                    rol       inum+2,u
                    rol       inum+1,u
                    rol       inum,u
                    bra       ly_tden@
ly_compound@        lda       iheader+5,u
                    cmpa      #'8
                    bne       ly_round@
                    lda       iheader+4,u
                    cmpa      #'6
                    beq       ly_tm3@
                    cmpa      #'9
                    bne       ly_round@
ly_tm3@             ldd       iden,u
                    std       imod,u
                    ldd       iden+2,u
                    std       imod+2,u
                    lsl       iden+3,u
                    rol       iden+2,u
                    rol       iden+1,u
                    rol       iden,u
                    ldd       iden+2,u
                    addd      imod+2,u
                    std       iden+2,u
                    ldd       iden,u
                    adcb      imod+1,u
                    adca      imod,u
                    std       iden,u
ly_round@           ldd       iden,u
                    std       imod,u
                    ldd       iden+2,u
                    std       imod+2,u
                    lsr       imod,u
                    ror       imod+1,u
                    ror       imod+2,u
                    ror       imod+3,u
                    ldd       inum+2,u
                    addd      imod+2,u
                    std       inum+2,u
                    ldd       inum,u
                    adcb      imod+1,u
                    adca      imod,u
                    std       inum,u
                    lbsr      mi_divide
                    ldd       inum,u
                    lbne      ly_bad
                    ldd       inum+2,u
                    lbeq      ly_bad
                    pshs      d
                    lbsr      ly_record
                    puls      d
                    sta       irec+4,u
                    stb       irec+3,u
                    ldd       #$4C59
                    std       irec+6,u
                    lda       #$19
                    sta       irec+5,u
                    lbra      ly_emit
ly_emit             tst       ipass,u
                    beq       ly_count@
                    lbsr      mi_bars
                    leax      irec,u
                    ldy       iframe,u
                    lbsr      MidiScoreAppend
                    lbeq      mi_memory
                    rts
ly_count@           ldd       icount,u
                    addd      #1
                    cmpd      #30000
                    lbhi      ly_bad
                    std       icount,u
                    rts
mi_memory           leax      ly_memmsg,pcr
                    bra       ly_error
ly_unsupported      leax      ly_unsupmsg,pcr
ly_error            lds       iroot,u
                    clra
                    clrb
                    pshs      d
                    pshs      x
                    ldy       iframe,u
                    jsr       [>UmeData_palert]
                    leas      4,s
                    clra
                    clrb
                    lbra      ly_exit
mi_divide           ldd       iden,u
                    bne       mi_divok@
                    ldd       iden+2,u
                    lbeq      ly_bad
mi_divok@           clr       imod,u
                    clr       imod+1,u
                    clr       imod+2,u
                    clr       imod+3,u
                    lda       #32
                    pshs      a
mi_divloop@         lsl       inum+3,u
                    rol       inum+2,u
                    rol       inum+1,u
                    rol       inum,u
                    rol       imod+3,u
                    rol       imod+2,u
                    rol       imod+1,u
                    rol       imod,u
                    ldd       imod,u
                    cmpd      iden,u
                    blo       mi_divnext@
                    bhi       mi_sub@
                    ldd       imod+2,u
                    cmpd      iden+2,u
                    blo       mi_divnext@
mi_sub@             ldd       imod+2,u
                    subd      iden+2,u
                    std       imod+2,u
                    ldd       imod,u
                    sbcb      iden+1,u
                    sbca      iden,u
                    std       imod,u
                    inc       inum+3,u
mi_divnext@         dec       ,s
                    bne       mi_divloop@
                    leas      1,s
                    rts

ly_sharps           fcb       3,0,4,1,5,2,6
ly_flats            fcb       6,2,5,1,4,0,3
ly_pitches          fcb       98,96,95,93,91,89,88,86,84,83,81,79,77,76,74,72,71,69,67,65,64,62,60,59,57,55,53,52,50,48,47,45,43,41,40,38,36,35,33,31,29,28,26,24,23,21,19,17,16,14,12,11,9,7,5,4,2,0
ly_lengths          fdb       384,576,672,256
ly_stfofs           fcb       0,6,8,12,12
* ly_namematch: X = a header entry's name, Y = a keyword table (keyword, 0, value; empty keyword ends
* it). Carry set and B = the value of the first keyword that is a prefix of the name, letters case-folded. X kept.
ly_namematch        pshs      a,x
ly_nmentry@         tst       ,y
                    beq       ly_nmnone@
                    ldx       1,s                 the name, from its first character
ly_nmchar@          lda       ,y+
                    beq       ly_nmfound@         the whole keyword matched
                    ldb       ,x+
                    cmpb      #'a
                    blo       ly_nmcmp@
                    cmpb      #'z
                    bhi       ly_nmcmp@
                    subb      #32
ly_nmcmp@           pshs      b
                    cmpa      ,s+
                    beq       ly_nmchar@
ly_nmskip@          lda       ,y+                 the rest of this keyword ...
                    bne       ly_nmskip@
                    leay      1,y                 ... and its value
                    bra       ly_nmentry@
ly_nmfound@         ldb       ,y
                    puls      a,x
                    orcc      #Carry
                    rts
ly_nmnone@          puls      a,x
                    andcc     #^Carry
                    rts
ly_badmsg           fcc       /Invalid or truncated Lyra 2Z score./
                    fcb       0
ly_headmsg          fcc       /Not a Lyra 2Z file: invalid header./
                    fcb       0
ly_longmsg          fcc       /Lyra score exceeds UME 65534-tick timeline./
                    fcb       0
ly_memmsg           fcc       /Not enough memory for Lyra score./
                    fcb       0
ly_unsupmsg         fcc       /Unsupported Lyra MIDI or event macro or cross-pitch tie./
                    fcb       0
                    use       lyra_patches.inc
                    use       midi_bars.inc
                    use       midi_score.inc
                    use       import_staff.inc
                    fill      0,$1D00-*           pad to $1D00 bytes so F$Link never puts this overlay in slot 7 and the score page always gets it
                    emod
eom                 equ       *
                    ifgt      eom-$2000
                    error     s9y exceeds its 8 KB overlay slot
                    endc


