* s9f: Musica II score reader (.mus), called by Read Score with an already open path.
* Four 256-byte waveforms and the five-byte default block precede nine-byte
* music records. Convert their waveform step rates directly to nearest MIDI
* pitches, then encode native notation for the normal player (no SID stage).
                    nam       s9f
                  IFP1
                    use       defsfile
                  ENDC
UME_SCOPE_S9F                  equ       1
                    use       equates.asm
                    mod       eom,name,Prgrm+Objct,ReEnt+1,start,$104C
name                fcs       /s9f/
                    fcb       1


start               pshs      y,u
                    leas      -iframe,s
                    tfr       s,u
                    leax      ,u
                    ldd       #iframe
mf_zero@            clr       ,x+
                    subd      #1
                    bne       mf_zero@
                    sts       iroot,u
                    ldb       iframe+9,u
                    stb       ipath,u
                    lbsr      mf_pass
                    ldd       imax,u
                    lbeq      mf_empty
                    lbsr      mf_pickmeter
                    lbsr      mf_map
                    ldb       #4
                    lbsr      ImportStaffs
                    leax      imap,u
                    ldy       iframe,u
                    lbsr      MidiScoreInit
                    lbeq      mf_memory
                    lbsr      mf_instrs
                    inc       ipass,u
                    lbsr      mf_pass
                    ldd       imax,u
                    cmpd      ilastbar,u
                    beq       mf_closed@
                    lbsr      mf_bar
mf_closed@          ldx       ibarno,u
                    leax      -1,x
                    ldy       iframe,u
                    lbsr      MidiScoreDone
                    lbeq      mf_memory
                    lbsr      mf_spell
                    lda       #1
                    sta       <UmeData_compact                compact imported notation
                    ldd       #1
mf_exit             leas      iframe,s
                    puls      y,u,pc

* One validation or emission pass.
mf_pass             clr       itime,u
                    clr       itime+1,u
                    clr       isrctime,u
                    lda       #1
                    sta       isrctime+1,u          half-tick carry for cumulative upward rounding
                    leax      ipending,u
                    ldb       #4
                    lda       #$FF
mf_pclear@          sta       ,x+
                    decb
                    bne       mf_pclear@
                    clr       imax,u
                    clr       imax+1,u
                    clr       insections,u
                    clr       irepeating,u
                    ldd       #1
                    std       ibarno,u
                    ldd       #$FFFF
                    std       ilastbar,u
                    std       iprevbar,u
                    tst       ipass,u
                    bne       mf_meterkept@
                    leax      imetercnt,u
                    ldb       #11
mf_meterzero@       clr       ,x+
                    decb
                    bne       mf_meterzero@
                    lda       #4
                    sta       ibeats,u
                    sta       ibeatunit,u
mf_meterkept@       ldd       imeasure,u
                    std       inextbar,u
                    ldd       ifirstbar,u
                    beq       mf_nopickup@
                    cmpd      imeasure,u
                    bhs       mf_nopickup@
                    std       inextbar,u
mf_nopickup@        lbsr      mf_prepare
                    ldd       #0
                    lbsr      mf_bar              opening bar
                    tst       ipass,u
                    beq       mf_openready@
                    ldd       ifirstbar,u
                    beq       mf_openready@
                    cmpd      imeasure,u
                    bhs       mf_openready@
                    std       inextbar,u
mf_openready@
                    lbsr      mf_meter
                    lda       itempo,u
                    lbsr      mf_tempo
                    lbsr      mf_marks
mf_loop             tst       irepeating,u
                    beq       mf_read@
                    ldd       ifpos,u
                    cmpd      ireturn,u
                    bne       mf_read@
                    clr       irepeating,u
mf_read@            lbsr      mf_readrec
                    lda       imrec,u
                    lbeq      mf_done
                    lbpl      mf_notes
                    cmpa      #$FF
                    beq       mf_barcmd
                    cmpa      #$FE
                    beq       mf_tempocmd
                    cmpa      #$FD
                    lbeq      mf_repeatbar
                    cmpa      #$FC
                    beq       mf_section
                    cmpa      #$FB
                    beq       mf_repeatsec
                    bra       mf_loop
mf_barcmd           ldd       itime,u
                    lbsr      mf_bar
                    bra       mf_loop
mf_tempocmd         leax      imrec+1,u
                    leay      itones,u
                    ldb       #4
mf_tones@          lda       ,x+
                    anda      #3
                    sta       ,y+
                    decb
                    bne       mf_tones@
                    lbsr      mf_marks
                    lda       imrec+5,u
                    sta       itempo,u
                    lbsr      mf_tempo
                    bra       mf_loop
mf_section          ldb       insections,u
                    cmpb      #9
                    bhs       mf_loop
                    aslb
                    leax      isections,u
                    ldd       ifpos,u              section begins after its marker
                    std       b,x
                    inc       insections,u
                    lbra      mf_loop
mf_repeatsec        tst       irepeating,u
                    lbne      mf_loop
                    ldb       imrec+1,u            Play uses slots 1..8 (slot zero is not selected)
                    lbeq      mf_loop
                    cmpb      #9
                    lbhs      mf_loop
                    cmpb      insections,u
                    lbhs      mf_loop
                    aslb
                    leax      isections,u
                    ldd       b,x
                    lbeq      mf_loop
                    pshs      d
                    ldd       ifpos,u
                    std       ireturn,u
                    inc       irepeating,u
                    puls      d
                    lbsr      mf_seek
                    lbra      mf_loop
mf_repeatbar        tst       irepeating,u
                    lbne      mf_loop
                    ldd       ifpos,u
                    std       ireturn,u
                    inc       irepeating,u
                    ldd       imusic,u
                    lbsr      mf_seek
                    lbra      mf_loop

* A positive record is one duration shared by four frequency words.
mf_notes            clrb
                    exg       a,b
                    cmpb      #$7F
                    bne       mf_notwhole@
                    ldd       #384              whole, in half-native ticks
                    bra       mf_half@
mf_notwhole@        cmpb      #$0B
                    bne       mf_not8trip@
                    ldd       #32               exact eighth triplet
                    bra       mf_half@
mf_not8trip@        cmpb      #$05
                    bne       mf_regular@
                    ldd       #16               exact sixteenth triplet
                    bra       mf_half@
mf_regular@        std       ibase,u
                    addd      ibase,u
                    addd      ibase,u
mf_half@            addb      isrctime+1,u
                    adca      #0
                    std       ibase,u
                    andb      #1
                    stb       isrctime+1,u
                    ldd       ibase,u
                    lsra
                    rorb
                    addd      itime,u
                    lbcs      mf_rangeerr
                    std       inexttime,u
                    clr       ivoice,u
mf_voice@           ldb       ivoice,u
                    aslb
                    leax      imrec+1,u
                    ldd       b,x
                    bne       mf_pitched@
                    clr       ipitchout,u
                    tst       ipass,u
                    lbne      mf_putnote@
                    lbra      mf_nextvoice@
mf_pitched@         std       ipitch,u
                    lbsr      mf_nearest
                    tst       ipass,u
                    bne       mf_putnote@
                    ldb       ivoice,u
                    leax      iseen,u
                    tst       b,x
                    bne       mf_range@
                    inc       b,x
                    leax      ilo,u
                    stb       b,x                 overwritten below; keeps flags independent
                    lda       ipitchout,u
                    sta       b,x
                    leax      ihi,u
                    sta       b,x
                    bra       mf_countnote@
mf_range@           lda       ipitchout,u
                    leax      ilo,u
                    cmpa      b,x
                    bhs       mf_high@
                    sta       b,x
mf_high@            leax      ihi,u
                    cmpa      b,x
                    bls       mf_countnote@
                    sta       b,x
mf_countnote@       lbsr      mf_emit
                    bra       mf_nextvoice@
mf_putnote@         lbsr      mf_change
mf_nextvoice@       inc       ivoice,u
                    lda       ivoice,u
                    cmpa      #4
                    lblo      mf_voice@
                    tst       ipass,u
                    beq       mf_advance@
                    lbsr      mf_grid
mf_advance@         ldd       inexttime,u
                    std       itime,u
                    cmpd      imax,u
                    lbls      mf_loop
                    std       imax,u
                    lbra      mf_loop
mf_done             tst       ipass,u
                    beq       mf_donetime@
                    clr       icont,u
                    lbsr      mf_flushall
mf_donetime@        ldd       itime,u
                    cmpd      imax,u
                    bls       mf_passdone@
                    std       imax,u
mf_passdone@        rts

* Locate the music after an optional five-byte LOADM header, four wave tables,
* and the five-byte defaults (tempo followed by four tone selections).
mf_prepare          ldd       #0
                    lbsr      mf_seek
                    lbsr      mf_byte
                    tsta
                    bne       mf_noheader@
                    ldd       #5
                    bra       mf_wavestart@
mf_noheader@        ldd       #0
mf_wavestart@       lbsr      mf_seek
                    clr       iwave,u
mf_wave@            lbsr      mf_waveclass
                    inc       iwave,u
                    lda       iwave,u
                    cmpa      #4
                    blo       mf_wave@
                    lbsr      mf_byte
                    sta       itempo,u
                    clr       ivoice,u
mf_defread@         lbsr      mf_byte
                    anda      #3
                    ldb       ivoice,u
                    leax      itones,u
                    sta       b,x
                    inc       ivoice,u
                    lda       ivoice,u
                    cmpa      #4
                    blo       mf_defread@
                    ldd       ifpos,u
                    std       imusic,u
                    rts

* Approximate GM defaults only: periodic waves have no acoustic attack envelope.
* Total variation / peak-to-peak removes DC offset and volume. Smooth <=2.5:
* piano; moderate <=4: trumpet; richer: strings. Never infer percussion.
mf_waveclass        lbsr      mf_byte
                    sta       iwavefirst,u
                    sta       iwaveprev,u
                    sta       iwavemin,u
                    sta       iwavemax,u
                    clr       iwavesum,u
                    clr       iwavesum+1,u
                    lda       #255
                    sta       iwavecount,u
mf_wsample@         lbsr      mf_byte
                    cmpa      iwavemin,u
                    bhs       mf_wmax@
                    sta       iwavemin,u
mf_wmax@            cmpa      iwavemax,u
                    bls       mf_wdelta@
                    sta       iwavemax,u
mf_wdelta@          lbsr      mf_wdiff
                    dec       iwavecount,u
                    bne       mf_wsample@
                    lda       iwavefirst,u
                    lbsr      mf_wdiff          close the periodic waveform
                    lda       iwavemax,u
                    suba      iwavemin,u
                    ldb       #5
                    mul
                    lsra
                    rorb
                    cmpd      iwavesum,u
                    bhs       mf_wpiano@
                    lda       iwavemax,u
                    suba      iwavemin,u
                    ldb       #4
                    mul
                    cmpd      iwavesum,u
                    bhs       mf_wbrass@
                    lda       #48              GM strings, zero based
                    bra       mf_wsave@
mf_wbrass@          lda       #56              GM trumpet
                    bra       mf_wsave@
mf_wpiano@          clra                       GM acoustic grand piano
mf_wsave@           ldb       iwave,u
                    leax      iprogs,u
                    sta       b,x
                    rts
mf_wdiff            tfr       a,b
                    suba      iwaveprev,u
                    stb       iwaveprev,u
                    bcc       mf_wabs@
                    nega
mf_wabs@            tfr       a,b
                    clra
                    addd      iwavesum,u
                    std       iwavesum,u
                    rts

* Own the four INSTRS slots instead of inheriting the previous score's patches.
mf_instrs           lda       #1
                    sta       <UmeData_instren
                    ldx       #$075F
                    ldy       #$07EB
                    ldb       #64
mf_iclear@          clr       ,x+
                    lda       #$80
                    sta       ,x+
                    clr       ,y
                    leay      16,y
                    decb
                    bne       mf_iclear@
                    clr       iwave,u
mf_islot@           ldb       iwave,u
                    leax      iprogs,u
                    lda       b,x
                    leax      mf_piano,pcr
                    cmpa      #56
                    bne       mf_inostrump@
                    leax      mf_trumpet,pcr
mf_inostrump@       cmpa      #48
                    bne       mf_iname@
                    leax      mf_strings,pcr
mf_iname@           pshs      x
                    aslb
                    ldx       #$075F
                    ora       #$80
                    leax      b,x
                    sta       1,x
                    lda       iwave,u
                    ldb       #16
                    mul
                    ldy       #$07EB
                    leay      d,y
                    puls      x
                    ldb       #7
mf_incopy@          lda       ,x+
                    sta       ,y+
                    decb
                    bne       mf_incopy@
                    clr       ,y
                    inc       iwave,u
                    lda       iwave,u
                    cmpa      #4
                    blo       mf_islot@
                    rts

* Explicit channel and editable INSTRS slot for all four voices, at startup
* and at each source tone-table change. Channel numbers are zero based.
mf_marks            clr       ivoice,u
mf_mark@            lbsr      mf_record
                    ldb       ivoice,u
                    stb       irec+7,u
                    incb
                    stb       irec+6,u
                    lda       #$16
                    sta       irec+5,u
                    lbsr      mf_emit
                    lbsr      mf_record
                    ldb       ivoice,u
                    leax      itones,u
                    lda       b,x
                    sta       irec+7,u
                    incb
                    stb       irec+6,u
                    lda       #$17
                    sta       irec+5,u
                    lbsr      mf_emit
                    inc       ivoice,u
                    lda       ivoice,u
                    cmpa      #4
                    blo       mf_mark@
                    rts
mf_piano            fcc       /Piano  /
mf_trumpet          fcc       /Trumpet/
mf_strings          fcc       /Strings/

* Buffered byte reader; a zero-byte read before the score terminator is bad.
mf_seek             std       ifpos,u
                    clr       ibpos,u
                    clr       ibpos+1,u
                    clr       iblen,u
                    clr       iblen+1,u
                    rts
mf_byte             ldd       ibpos,u
                    cmpd      iblen,u
                    blo       mf_have@
                    pshs      y,u
                    lda       ipath,u
                    ldx       #0
                    ldu       ifpos,u
                    os9       I$Seek
                    puls      y,u
                    lbcs      mf_bad
                    leax      ibuf,u
                    ldy       #255
                    lda       ipath,u
                    os9       I$Read
                    lbcs      mf_bad
                    sty       iblen,u
                    lbeq      mf_bad
                    clr       ibpos,u
                    clr       ibpos+1,u
mf_have@            leax      ibuf,u
                    ldd       ibpos,u
                    leax      d,x
                    lda       ,x
                    pshs      a
                    ldd       ibpos,u
                    addd      #1
                    std       ibpos,u
                    ldd       ifpos,u
                    addd      #1
                    std       ifpos,u
                    puls      a,pc
mf_readrec          leax      imrec,u
                    pshs      x
                    lbsr      mf_byte
                    puls      x
                    sta       ,x+
                    beq       mf_recorddone@
                    ldb       #8
mf_more@            pshs      b,x
                    lbsr      mf_byte
                    puls      b,x
                    sta       ,x+
                    decb
                    bne       mf_more@
mf_recorddone@      rts

* The author's scale has A4=$123F; arbitrary/chorused rates are rounded to
* nearest MIDI: 69 + round(12*log2(value/$123F)). One pitch drives both the
* notation and native player. No SID word, CPU-loop tuning or octave folding.
mf_nearest          ldd       ipitch,u
                    bsr       Mf2MIDI
                    stb       ipitchout,u
                    cmpb      #24
                    lblo      mf_pitcherr
                    cmpb      #107
                    lbhi      mf_pitcherr
                    rts

* D=unsigned Musica step rate, B=nearest MIDI (0 for silence); preserves X/Y/U.
* Normalize by powers of two, retaining every input bit. Starting at the G7/
* G#7 midpoint, calculate each next half-semitone boundary by multiplying by
* 2^(1/12), in Q16.16. This is the rounded-log calculation without a lookup
* table or floating point. At most 12 comparisons after octave normalization.
Mf2MIDI             cmpd      #0
                    bne       mp_start@
                    clrb
                    rts
mp_start@           pshs      x
                    leas      -mp_frame,s
                    leax      ,s
                    std       mp_value,x
                    lda       #103
                    sta       mp_note,x
                    lda       #12
                    sta       mp_left,x
mp_norm@            ldd       mp_value,x
                    bmi       mp_ready@
                    aslb
                    rola
                    std       mp_value,x
                    lda       mp_note,x
                    suba      #12
                    sta       mp_note,x
                    bra       mp_norm@
mp_ready@           ldd       #MusBoundaryHi
                    std       mp_bound,x
                    ldd       #MusBoundaryLo
                    std       mp_bound+2,x
mp_compare@         ldd       mp_value,x
                    cmpd      mp_bound,x
                    lblo      mp_done@
                    bhi       mp_next@
                    ldd       mp_bound+2,x
                    lbne      mp_done@
mp_next@            inc       mp_note,x
                    dec       mp_left,x
                    lbeq      mp_done@
* T <- T + high32(T * (2^(1/12)-1)). Four 16x16 products retain the fractional
* boundary. Save CC only across the shared multiplier transactions; no OS call
* or wait occurs here. X remains the frame base while CC/return PCs are pushed.
                    pshs      cc
                    orcc      #IntMasks
                    ldd       mp_bound,x
                    std       MATH_MUL_A
                    ldd       #MusRatioHi
                    std       MATH_MUL_B
                    ldd       MATH_MUL_P
                    std       mp_product,x
                    ldd       MATH_MUL_P+2
                    std       mp_product+2,x
                    ldd       mp_bound+2,x
                    std       MATH_MUL_A
                    ldd       #MusRatioLo
                    std       MATH_MUL_B
                    ldd       MATH_MUL_P
                    std       mp_product+4,x
                    ldd       MATH_MUL_P+2
                    std       mp_product+6,x
                    ldd       mp_bound,x
                    std       MATH_MUL_A
                    bsr       mp_cross
                    ldd       mp_bound+2,x
                    std       MATH_MUL_A
                    ldd       #MusRatioHi
                    std       MATH_MUL_B
                    bsr       mp_cross
                    puls      cc
                    ldd       mp_bound+2,x
                    addd      mp_product+2,x
                    std       mp_bound+2,x
                    ldd       mp_bound,x
                    adcb      mp_product+1,x
                    adca      mp_product,x
                    std       mp_bound,x
                    lbra      mp_compare@
mp_done@            ldb       mp_note,x
                    leas      mp_frame,s
                    puls      x,pc

* Add the current 32-bit cross product at bit 16 of the 64-bit product.
mp_cross            ldd       MATH_MUL_P+2
                    addd      mp_product+4,x
                    std       mp_product+4,x
                    ldd       MATH_MUL_P
                    adcb      mp_product+3,x
                    adca      mp_product+2,x
                    std       mp_product+2,x
                    ldd       mp_product,x
                    adcb      #0
                    adca      #0
                    std       mp_product,x
                    rts

mf_note             lbsr      mf_record
                    ldb       ivoice,u
                    incb
                    stb       irec,u
                    ldb       ipitchout,u
                    bne       mf_notrest@
                    lda       #32
                    sta       irec+5,u
                    bra       mf_noteattr@
mf_notrest@         subb      #24
                    clr       itmp,u
mf_oct@             cmpb      #12
                    blo       mf_semi@
                    subb      #12
                    lda       itmp,u
                    adda      #7
                    sta       itmp,u
                    bra       mf_oct@
mf_semi@            leax      mf_steps,pcr
                    lda       b,x
                    adda      itmp,u
                    suba      #23                 native index has C1 = 1; the treble clef offset is 24
                    pshs      b
                    ldb       ivoice,u
                    leax      istf,u
                    ldb       b,x
                    leax      mf_stfofs,pcr
                    adda      b,x
                    puls      b
                    sta       irec+5,u
                    leax      mf_acc,pcr
                    lda       b,x
                    sta       irec+6,u
mf_noteattr@
                    lda       #2
                    sta       irec+7,u
                    lbra      mf_duration

* Musica gives absolute pitches. Native accidental 0 inherits the last sharp;
* 1 forces a natural silently, 4 prints a cancellation. Walk FINAL event order
* (voices finish at different times), matching the player's shared pitch table.
* File I/O is finished: ibuf's first 52 bytes now hold spelling state/index.
mf_spell            lbsr      mf_accreset
                    clr       iaccindex,u
                    clr       iaccindex+1,u
mf_spnext@          ldd       iaccindex,u
                    cmpd      <UmeData_nevents
                    bhs       mf_spdone@
                    ldy       iframe,u
                    pshs      u
                    pshs      d                   STACK ARGUMENT: native event index
                    jsr       [>pMidiEventPtr]
                    leas      2,s
                    puls      u
                    tfr       d,x
                    lbeq      mf_memory
                    ldb       ,x
                    bne       mf_spnote@
                    ldb       5,x
                    cmpb      #6
                    bhi       mf_spadvance@
                    lbsr      mf_accreset
                    bra       mf_spadvance@
mf_spnote@          lda       5,x
                    cmpa      #32                 rest
                    beq       mf_spadvance@
                    decb
                    leay      istf,u
                    ldb       b,y                 staff index
                    leay      mf_stfofs,pcr
                    suba      b,y
                    adda      #24                 native diatonic index, C1 = 1
                    tfr       a,b
                    cmpb      #49
                    bhi       mf_spadvance@
                    leay      iaccstate,u
                    lda       6,x
                    cmpa      #1
                    bne       mf_spsharp@
                    tst       b,y
                    beq       mf_spnatural@
                    lda       #4
                    sta       6,x                 show the natural after a sharp
mf_spnatural@       clr       b,y
                    bra       mf_spadvance@
mf_spsharp@         sta       b,y
mf_spadvance@       ldd       iaccindex,u
                    addd      #1
                    std       iaccindex,u
                    bra       mf_spnext@
mf_spdone@          rts
mf_accreset         leay      iaccstate,u
                    ldb       #50
mf_spclear@         clr       ,y+
                    decb
                    bne       mf_spclear@
                    rts

mf_record           leax      irec,u
                    ldb       #8
mf_recz@            clr       ,x+
                    decb
                    bne       mf_recz@
                    ldd       itime,u
                    std       irec+1,u
                    rts

* Exact decomposition: longest legal value not exceeding the remaining span.
* More pieces get outgoing ties; nothing rounds beyond a measure boundary.
mf_duration         clr       iseglen,u
                    clr       iseglen+1,u
                    clr       itmp+2,u
mf_dbase@           ldb       itmp+2,u
                    aslb
                    leax      mf_durations,pcr
                    ldd       b,x
                    std       ibase,u
                    clr       itmp+3,u
mf_dshift@          ldb       itmp+2,u
                    cmpb      #3
                    bne       mf_dcand@
                    ldb       itmp+3,u
                    cmpb      #8
                    beq       mf_dnext@
mf_dcand@           ldd       ibase,u
                    cmpd      ilen,u
                    bhi       mf_dnext@
                    cmpd      iseglen,u
                    bls       mf_dnext@
                    std       iseglen,u
                    lda       itmp+3,u
                    sta       irec+3,u
                    lda       itmp+2,u
                    sta       irec+4,u
mf_dnext@           lsr       ibase,u
                    ror       ibase+1,u
                    inc       itmp+3,u
                    lda       itmp+3,u
                    cmpa      #9
                    blo       mf_dshift@
                    inc       itmp+2,u
                    lda       itmp+2,u
                    cmpa      #4
                    blo       mf_dbase@
                    rts

* Carry each voice independently. A new four-voice record is not an attack.
mf_change           ldb       ivoice,u
                    leax      ipending,u
                    lda       b,x
                    cmpa      #$FF
                    beq       mf_newhold@
                    cmpa      ipitchout,u
                    beq       mf_holdsame@
                    pshs      b
                    ldb       ipitchout,u
                    pshs      b
                    ldd       itime,u
                    std       ifinish,u
                    clr       icont,u
                    lbsr      mf_flush
                    puls      b
                    stb       ipitchout,u
                    puls      b
                    bra       mf_newhold@
mf_holdsame@        ldd       ilastbar,u
                    std       ifinish,u
                    lda       #1
                    sta       icont,u
                    lbsr      mf_flush          delayed boundary: we now know it continues
                    rts
mf_newhold@         leax      ipending,u
                    lda       ipitchout,u
                    sta       b,x
                    aslb
                    leax      ipstart,u
                    leax      b,x
                    ldd       itime,u
                    std       ,x
                    rts

* Split sustained voices at actual/synthesized bars; preserve MIDI continuity.
mf_grid             ldd       inextbar,u
                    cmpd      inexttime,u
                    bhi       mf_gridout@
                    std       itime,u
                    bne       mf_gridvalid@
                    rts
mf_gridvalid@       cmpd      inexttime,u
                    beq       mf_gridbar@
                    lda       #1
                    sta       icont,u
                    lbsr      mf_flushall
mf_gridbar@         ldd       itime,u
                    lbsr      mf_bar
                    ldd       inextbar,u
                    beq       mf_gridout@        overflow: no further complete bar
                    bra       mf_grid
mf_gridout@         rts
mf_flushall         ldd       itime,u
                    std       ifinish,u
                    clr       ivoice,u
mf_fall@            lbsr      mf_flush
                    inc       ivoice,u
                    lda       ivoice,u
                    cmpa      #4
                    blo       mf_fall@
                    rts
mf_flush            ldb       ivoice,u
                    leax      ipending,u
                    lda       b,x
                    cmpa      #$FF
                    beq       mf_fout@
                    sta       ipitchout,u
                    leax      iseen,u
                    tst       b,x
                    beq       mf_fout@           no staff/part for a wholly unused voice
mf_fpiece@          ldb       ivoice,u
                    aslb
                    leax      ipstart,u
                    leax      b,x
                    ldd       ifinish,u
                    subd      ,x
                    bls       mf_fout@
                    std       ilen,u
                    lbsr      mf_note
                    ldb       ivoice,u
                    aslb
                    leax      ipstart,u
                    leax      b,x
                    ldd       ,x
                    std       irec+1,u
                    addd      iseglen,u
                    std       ,x
                    tst       ipitchout,u
                    beq       mf_femit@          rests never tie
                    cmpd      ifinish,u
                    blo       mf_ftie@
                    tst       icont,u
                    beq       mf_femit@
mf_ftie@            clr       irec+7,u
mf_femit@           lbsr      mf_emit
                    bra       mf_fpiece@
mf_fout@            rts

* PLAY.BIN: quarter = 32 * (tempo or 256) * 137 / 894886 seconds.
* Native tempo counts denominator beats, or dotted beats in compound meter.
* Rounded numerator 12248 for /4, 24495 for /8. Use the existing wide tempo
* record so fast settings do not silently clamp to 255.
mf_tempo            sta       itempo,u
                    tfr       a,b
                    clra
                    tstb
                    bne       mf_tden@
                    inca                       zero is an eight-bit count of 256
mf_tden@            std       ibase,u
                    lda       ibeatunit,u
                    cmpa      #8
                    blo       mf_tplain@
                    lda       ibeats,u
                    cmpa      #9               9/8 is the only compound /8 in mf_meters
                    bne       mf_tplain@
                    ldd       ibase,u
                    addd      ibase,u
                    addd      ibase,u
                    std       ibase,u
mf_tplain@          ldd       #12248
                    pshs      d
                    lda       ibeatunit,u
                    cmpa      #8
                    blo       mf_tnum@
                    ldd       #24495
                    std       ,s
mf_tnum@            ldd       ibase,u
                    lsra
                    rorb
                    addd      ,s++             half divisor for nearest rounding
                    clr       ibest,u
                    clr       ibest+1,u
mf_tdiv@            subd      ibase,u
                    bcs       mf_tvalue@
                    inc       ibest+1,u
                    bne       mf_tdiv@
                    inc       ibest,u
                    bra       mf_tdiv@
mf_tvalue@          lbsr      mf_record
                    ldd       ibest,u
                    stb       irec+3,u
                    sta       irec+4,u
                    ldd       #$4C59            native wide-tempo tag
                    std       irec+6,u
                    lda       #$19
                    sta       irec+5,u
                    lbra      mf_emit

* Native time signature inferred from the most frequent explicit Musica bar
* interval. This gives the notation engine the same meter context as MIDI/Lyra.
mf_meter            lbsr      mf_record
                    lda       ibeats,u
                    sta       irec+6,u
                    lda       ibeatunit,u
                    sta       irec+7,u
                    lda       #$0A
                    sta       irec+5,u
                    lbra      mf_emit

mf_bar              cmpd      ilastbar,u
                    beq       mf_barout@
                    tst       ipass,u
                    bne       mf_baremit@
                    lbsr      mf_meterbar
mf_baremit@         std       ilastbar,u
                    tst       ipass,u
                    beq       mf_firstbar@
                    pshs      d
                    addd      imeasure,u
                    bcc       mf_nextbarok@
                    clra
                    clrb
mf_nextbarok@       std       inextbar,u
                    puls      d
                    bra       mf_barrecord@
mf_firstbar@        cmpd      #0
                    beq       mf_barrecord@
                    pshs      d
                    ldd       ifirstbar,u
                    bne       mf_firstset@
                    ldd       ,s
                    std       ifirstbar,u
mf_firstset@        puls      d
mf_barrecord@
                    pshs      d
                    lbsr      mf_record
                    puls      d
                    std       irec+1,u
                    ldd       ibarno,u
                    std       irec+3,u
                    addd      #1
                    std       ibarno,u
                    lbsr      mf_emit
mf_barout@          rts

* Classify a nonzero bar interval against the normal native meter lengths.
mf_meterbar         pshs      d,x
                    ldx       iprevbar,u
                    stx       itmp+2,u
                    std       iprevbar,u
                    cmpx      #$FFFF
                    beq       mf_mbout@
                    subd      itmp+2,u
                    beq       mf_mbout@
                    std       ibase,u
                    ldd       #$FFFF
                    std       ibest,u
                    clr       itmp,u
                    clr       itmp+1,u
                    leax      mf_barlens,pcr
mf_mbloop@          ldd       ,x++
                    subd      ibase,u
                    bcc       mf_mbabs@
                    coma
                    comb
                    addd      #1
mf_mbabs@           cmpd      ibest,u
                    bhs       mf_mbnext@
                    std       ibest,u
                    lda       itmp,u
                    sta       itmp+1,u
mf_mbnext@          inc       itmp,u
                    lda       itmp,u
                    cmpa      #11
                    blo       mf_mbloop@
                    ldd       ibest,u
                    bne       mf_mbout@          pickups and long sections do not define meter
                    ldb       itmp+1,u
                    leax      imetercnt,u
                    inc       b,x
mf_mbout@           puls      d,x,pc

mf_pickmeter        clr       itmp,u              best count
                    lda       #5                  default candidate: 4/4
                    sta       itmp+1,u
                    clrb
                    leax      imetercnt,u
mf_pmlp@            lda       b,x
                    cmpa      itmp,u
                    bls       mf_pmnext@
                    sta       itmp,u
                    stb       itmp+1,u
mf_pmnext@          incb
                    cmpb      #11
                    blo       mf_pmlp@
                    ldb       itmp+1,u
                    aslb
                    leax      mf_barlens,pcr
                    ldd       b,x
                    std       imeasure,u
                    ldb       itmp+1,u
                    aslb
                    leax      mf_meters,pcr
                    leax      b,x
                    lda       ,x
                    sta       ibeats,u
                    lda       1,x
                    sta       ibeatunit,u
                    rts

mf_emit             tst       ipass,u
                    bne       mf_store@
                    ldd       icount,u
                    addd      #1
                    cmpd      #30000
                    lbhi      mf_rangeerr
                    std       icount,u
                    rts
mf_store@           pshs      y,u
                    leax      irec,u
                    ldy       iframe,u
                    tst       irec,u
                    beq       mf_append@
                    lbsr      MidiScoreAdd       completed voices may start before later events
                    bra       mf_added@
mf_append@          lbsr      MidiScoreAppend
mf_added@           puls      y,u
                    lbeq      mf_memory
                    rts

mf_map              clrb
mf_maploop@         leax      iseen,u
                    tst       b,x
                    beq       mf_mapnext@
                    leax      imap,u
                    pshs      b
                    tfr       b,a
                    adda      #$C0
                    puls      b
                    sta       b,x
                    leax      ichn,u
                    stb       b,x
mf_mapnext@         incb
                    cmpb      #4
                    blo       mf_maploop@
                    rts

mf_pitcherr         leax      mf_pitchmsg,pcr
                    bra       mf_error
mf_bad              leax      mf_badmsg,pcr
                    bra       mf_error
mf_rangeerr         leax      mf_rangemsg,pcr
                    bra       mf_error
mf_empty            leax      mf_emptymsg,pcr
                    bra       mf_error
mf_memory           leax      mf_memmsg,pcr
mf_error            lds       iroot,u
                    clra
                    clrb
                    pshs      d
                    pshs      x
                    ldy       iframe,u
                    jsr       [>UmeData_palert]
                    leas      4,s
                    clra
                    clrb
                    lbra      mf_exit
mf_pitchmsg         fcc       /Musica pitch is outside the native C1-B7 range./
                    fcb       0
mf_badmsg           fcc       /Invalid or truncated Musica II score./
                    fcb       0
mf_rangemsg         fcc       /Musica II score exceeds UME timeline or event limits./
                    fcb       0
mf_emptymsg         fcc       /Musica II file contains no notes./
                    fcb       0
mf_memmsg           fcc       /Not enough score memory for Musica II import./
                    fcb       0

mf_steps            fcb       0,0,1,1,2,3,3,4,4,5,5,6
mf_stfofs           fcb       0,6,8,12,12
mf_acc              fcb       1,2,1,2,1,1,2,1,2,1,2,1
mf_durations        fdb       384,576,672,256
mf_barlens          fdb       72,96,120,144,168,192,216,240,288,336,384
mf_meters           fcb       3,8,2,4,5,8,3,4,7,8,4,4,9,8,5,4,6,4,7,4,8,4

                    use       import_staff.inc
                    use       midi_score.inc
                    emod
eom                 equ       *
