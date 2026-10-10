* s9o: Orchestra-90 CC music-language reader (.orc / .asc, the CompuServe ORCH SIG text files). C overlay ABI as
* s9i/s9y: (command, open path). Two passes over the text: pass zero validates, counts and collects each
* voice's pitch range (the staff comes from it); pass one builds the score. Y is the caller's C static base.
* Language (Tandy manual 26-2205, chapters 4 and 6, appendix A): notes are diatonic steps from middle C
* (0 = C4, +1 = D4 ... +G = E6, -1 = B3 ... -F = B1), single hex-like digits with an optional +/- clef
* override; '$' = rest; W H Q I S T X set the duration for the notes that follow ('.' dotted, ':' triplet);
* '# & %' accidentals and ', ; ' "' articulations follow the note; V1-V5 voices (one part each), M ends a
* measure (every voice restarts at its beginning), Pnn parts, Rnn repeats a part, (...)n repeats notation,
* K key, N beat unit, = tempo (hex), U voice transposition in steps, < > semitones, * @ <- clefs, Y register
* per voice, J register definition: the eight harmonic weights (S = sine, R = random) are matched against the
* five default registers and appendix D's forty-one instrument definitions for a General MIDI program.
                    nam       s9o
                  IFP1
                    use       defsfile
                  ENDC
UME_SCOPE_S9O                  equ       1
                    use       equates.asm
                    mod       eom,name,Prgrm+Objct,ReEnt+1,start,$104C
name                fcs       /s9o/
                    fcb       1
* frame (U): the names the shared includes expect first
* the reader
* the language state

start               pshs      y,u
                    leas      -iframe,s
                    tfr       s,u
                    sts       iroot,u
                    leax      4,u
                    ldy       #iframe-4
oz@                 clr       ,x+
                    leay      -1,y
                    bne       oz@
                    ldb       iframe+9,u          the C path (low byte)
                    stb       ipath,u
                    lbsr      o_pass              pass zero: validate and count
                    ldd       imax,u
                    lbeq      o_bad
                    lbsr      o_mapfill
                    ldb       #5
                    lbsr      ImportStaffs
                    leax      imap,u
                    ldy       iframe,u
                    lbsr      MidiScoreInit
                    lbeq      mi_memory
                    lbsr      o_instrs            the INSTRS table from the registers
                    inc       ipass,u
                    lbsr      o_pass
                    ldd       imax,u
                    std       ibound,u            mi_finish closes the score with a bar at ibound
                    lbsr      mi_finish
                    ldd       imax,u
                    ldx       ibarno,u
                    leax      -1,x
                    ldy       iframe,u
                    lbsr      MidiScoreDone
                    ldd       #1
o_exit              leas      iframe,s
                    puls      y,u,pc
o_bad               leax      o_badmsg,pcr
                    lbra      o_error
o_toolong           leax      o_longmsg,pcr
                    lbra      o_error

* one pass over the whole text
o_pass              clr       icount,u
                    clr       icount+1,u
                    clr       imax,u
                    clr       imax+1,u
                    clr       itime,u
                    clr       itime+1,u
                    ldd       #$FFFF
                    std       ilastb,u
                    std       ibound,u            the bar lines are laid at every M, never by ibarlen
                    ldd       #1
                    std       ibarno,u
                    ldd       #192
                    std       ibarlen,u
                    clr       ovoice,u
                    clr       oclef,u
                    clr       onext,u
                    lda       #3
                    sta       odur,u              a quarter until a duration letter says otherwise
                    sta       ounit,u
                    clr       odmod,u
                    clr       oksig,u
                    clr       oopt,u
                    clr       otransp,u
                    lda       #$C0
                    sta       otempo,u
                    clr       omstart,u
                    clr       omstart+1,u
                    clr       omlen,u
                    clr       omlen+1,u
                    clr       omcount,u
                    clr       oflag,u
                    clr       onslot,u
                    clr       orpin,u
                    lda       #$FF
                    sta       orpend,u
                    leax      ovtime,u
                    ldb       #10
op1@                clr       ,x+
                    decb
                    bne       op1@
                    leax      ovreg,u
                    ldb       #5
op2@                lda       #3                  register D, as the compiler's defaults
                    sta       ,x
                    clr       5,x                 U 0
                    lda       #$FF
                    sta       10,x                no marker yet
                    clr       15,x                not percussion
                    leax      1,x
                    decb
                    bne       op2@
                    lbsr      o_accclr
                    leax      opart,u
                    ldy       #512
op3@                clr       ,x+
                    leay      -1,y
                    bne       op3@
                    tst       ipass,u
                    bne       op4@
                    leax      oreg,u
                    leay      o_defregs,pcr       Y = the default register table
                    ldb       #50
op3b@               lda       ,y+
                    sta       ,x+
                    decb
                    bne       op3b@
                    leax      oregdef,u
                    ldb       #5
op3c@               clr       ,x+
                    decb
                    bne       op3c@
op4@                clra
                    clrb
                    lbsr      o_seek
                    clr       otempoflag,u
* the scan loop
o_loop              ldd       obase,u
                    addb      obpos,u
                    adca      #0
                    std       otok,u
                    lbsr      o_getc
                    lbeq      o_end
                    cmpa      #'/
                    beq       o_comment
                    cmpa      #C$SPAC
                    lbls      o_loop
                    cmpa      #'a
                    blo       o_up@
                    cmpa      #'z
                    bhi       o_up@
                    suba      #32                 lower case as upper
o_up@               cmpa      #'0
                    blo       o_sym
                    cmpa      #'9
                    lbls      o_note
                    cmpa      #'A
                    blo       o_sym
                    cmpa      #'G
                    lbls      o_note
                    cmpa      #'Z
                    bhi       o_sym
                    suba      #'H
                    leax      o_cmdtab,pcr
                    asla
                    ldd       a,x
                    leax      o_cmdtab,pcr
                    jmp       d,x
o_comment           lbsr      o_getc
                    lbeq      o_end
                    cmpa      #C$CR
                    lbeq      o_loop
                    cmpa      #C$LF
                    lbeq      o_loop
                    bra       o_comment
o_sym               cmpa      #'$
                    lbeq      o_rest
                    cmpa      #'+
                    beq       o_plus
                    cmpa      #'-
                    beq       o_minus
                    cmpa      #'*
                    beq       o_treble
                    cmpa      #'@
                    beq       o_bass
                    cmpa      #$5F                the CoCo's left arrow (SHIFT 0)
                    beq       o_perc
                    cmpa      #'`                 Four Star's percussion clef
                    beq       o_perc
                    cmpa      #'.
                    beq       o_dot
                    cmpa      #':
                    beq       o_triplet
                    cmpa      #'=
                    lbeq      o_tempo
                    cmpa      #'<
                    lbeq      o_down
                    cmpa      #'>
                    lbeq      o_upsemi
                    cmpa      #'(
                    lbeq      o_rpopen
                    cmpa      #')
                    lbeq      o_rpclose
                    lbra      o_loop              anything else (a stray modifier) is ignored
o_plus              lda       #1
                    sta       onext,u
                    lbra      o_loop
o_minus             lda       #2
                    sta       onext,u
                    lbra      o_loop
o_treble            clr       oclef,u
                    lbra      o_loop
o_bass              lda       #1
                    sta       oclef,u
                    lbra      o_loop
o_perc              lda       #2
                    sta       oclef,u
                    lbra      o_loop
o_dot               lda       odmod,u
                    cmpa      #2
                    lbhs      o_loop
                    inc       odmod,u
                    lbra      o_loop
o_triplet           lda       #3
                    sta       odmod,u
                    lbra      o_loop
* the command letters H..Z (A..G are notes)
o_cmdtab            fdb       o_durH-o_cmdtab,o_durI-o_cmdtab,o_jreg-o_cmdtab,o_key-o_cmdtab
                    fdb       o_ignore1-o_cmdtab,o_measure-o_cmdtab,o_unit-o_cmdtab,o_option-o_cmdtab
                    fdb       o_part-o_cmdtab,o_durQ-o_cmdtab,o_repeat-o_cmdtab,o_durS-o_cmdtab
                    fdb       o_durT-o_cmdtab,o_utrans-o_cmdtab,o_voice-o_cmdtab,o_durW-o_cmdtab
                    fdb       o_durX-o_cmdtab,o_yreg-o_cmdtab,o_zmap-o_cmdtab
o_durW              lda       #1
                    bra       o_setdur
o_durH              lda       #2
                    bra       o_setdur
o_durQ              lda       #3
                    bra       o_setdur
o_durI              lda       #4
                    bra       o_setdur
o_durS              lda       #5
                    bra       o_setdur
o_durT              lda       #6
                    bra       o_setdur
o_durX              lda       #7
o_setdur            sta       odur,u
                    clr       odmod,u
                    lbra      o_loop
o_ignore1           lbsr      o_getc              L: not a command - one character eaten
                    lbra      o_loop
o_zmap              lbsr      o_getc              Z n: stereo, nothing here
                    lbra      o_loop
o_option            lbsr      o_hex
                    anda      #3
                    sta       oopt,u
                    lbra      o_loop
o_voice             lbsr      o_hex
                    deca
                    cmpa      #4
                    lbhi      o_loop              V0, V6..: left alone
                    sta       ovoice,u
                    lbra      o_loop
o_unit              lbsr      o_getp
                    ldb       #2
                    cmpa      #'H
                    beq       o_unitset@
                    incb
                    cmpa      #'Q
                    beq       o_unitset@
                    incb
                    cmpa      #'I
                    beq       o_unitset@
                    incb
                    cmpa      #'S
                    beq       o_unitset@
                    incb
                    cmpa      #'T
                    beq       o_unitset@
                    lbsr      o_ungetc
                    lbra      o_loop
o_unitset@          stb       ounit,u
                    lbra      o_loop
o_key               lbsr      o_hex
                    cmpa      #7
                    bls       o_kok@
                    lda       #7
o_kok@              sta       oksig,u
                    lbsr      o_getc
                    cmpa      #'&
                    bne       o_keyok@
                    neg       oksig,u
o_keyok@            cmpa      #'#
                    beq       o_keyrec@
                    cmpa      #'&
                    beq       o_keyrec@
                    cmpa      #'%
                    beq       o_keyrec@
                    lbsr      o_ungetc
o_keyrec@           lbsr      o_accclr
                    lbsr      o_record
                    ldd       omstart,u
                    std       irec+1,u
                    lda       #$0B
                    sta       irec+5,u
                    lda       oksig,u
                    sta       irec+6,u
                    lbsr      o_emit
                    lbra      o_loop
o_tempo             lbsr      o_hex
                    asla
                    asla
                    asla
                    asla
                    sta       otmp,u
                    lbsr      o_hex
                    ora       otmp,u
                    sta       otempo,u
                    lbsr      o_temporec
                    lbra      o_loop
o_down              lbsr      o_hex
                    nega
                    bra       o_semi@
o_upsemi            lbsr      o_hex
o_semi@             sta       otransp,u
                    lbra      o_loop
o_utrans            lbsr      o_getp
                    clr       otmp,u
                    cmpa      #'-
                    bne       o_ut1@
                    inc       otmp,u
                    bra       o_ut2@
o_ut1@              cmpa      #'+
                    beq       o_ut2@
                    lbsr      o_ungetc
o_ut2@              lbsr      o_hex
                    tst       otmp,u
                    beq       o_ut3@
                    nega
o_ut3@              ldb       ovoice,u
                    leax      ovtrans,u
                    sta       b,x
                    lbra      o_loop
o_yreg              lbsr      o_getp
                    suba      #'A
                    lbmi      o_loop              not a letter: ignored
                    cmpa      #4
                    bls       o_yok@
                    lda       #4                  F.. = E
o_yok@              ldb       ovoice,u
                    leax      ovreg,u
                    sta       b,x
                    lbra      o_loop
* J r S/R dddddddd v : a register definition (pass zero only - the table is kept across the passes)
o_jreg              lbsr      o_getp
                    suba      #'A
                    sta       otmp,u
                    lbsr      o_getp              the wave letter
                    cmpa      #'T
                    bne       o_jnott@
                    lbsr      o_hex               "JATn": unknown, skipped
                    lbra      o_loop
o_jnott@            cmpa      #'R
                    beq       o_jwv@
                    cmpa      #'S
                    beq       o_jwv@
                    lbsr      o_ungetc            not a definition: the letter is read again
                    lbra      o_loop
o_jwv@              lbsr      o_ungetc
                    lda       otmp,u
                    cmpa      #4
                    lbhi      o_jeatall@          a register beyond E: the definition is skipped
                    tst       ipass,u
                    beq       o_jkeep@
o_jeatall@          equ       *
                    ldb       #10                 pass one: eat the definition
o_jeat@             lbsr      o_getc
                    decb
                    bne       o_jeat@
                    lbra      o_loop
o_jkeep@            ldb       #10
                    mul
                    leax      oreg,u
                    leax      d,x
                    pshs      x                   o_getc uses X
                    lbsr      o_getp
                    puls      x
                    sta       ,x+                 R or S (checked above)
                    ldb       #9
o_jdig@             pshs      b,x
                    lbsr      o_hex
                    puls      b,x
                    sta       ,x+
                    decb
                    bne       o_jdig@
                    ldb       otmp,u
                    leax      oregdef,u
                    lda       #1
                    sta       b,x
                    lbra      o_loop
* ( ... )n : the notation between the parentheses plays n+1 times
o_rpopen            ldd       obase,u
                    addb      obpos,u
                    adca      #0
                    std       orpstart,u
                    clr       orpcount,u
                    lbra      o_loop
o_rpclose           lbsr      o_hex
                    inc       orpcount,u
                    cmpa      orpcount,u
                    lblo      o_loop              done
                    ldd       orpstart,u
                    lbsr      o_seek
                    lbra      o_loop
* M: the measure ends - every voice restarts at the new measure start; a bar line goes down there
o_measure           lbsr      o_endm
o_mskip@            lbsr      o_getc              the measure string runs to a space or the end of the line
                    lbeq      o_end
                    cmpa      #C$SPAC
                    lbls      o_loop
                    bra       o_mskip@
* P nn: a part begins (its offset is kept for R); R nn: the named part is replayed after the settings that follow
o_part              tst       orpin,u
                    lbne      o_rpdone           inside a replay: the next part ends it
                    lbsr      o_endm
                    lbsr      o_hex2
                    tfr       a,b
                    clra
                    aslb
                    rola
                    leax      opart,u
                    leax      d,x
                    ldd       obase,u
                    addb      obpos,u
                    adca      #0
                    std       ,x
                    lbra      o_loop
o_repeat            tst       orpin,u
                    lbne      o_rpdone
                    lbsr      o_endm
                    lbsr      o_hex2
                    sta       orpend,u
                    lbra      o_loop
* a replay ends (P, R or the end of the text met while replaying): back to where the R line went on
o_rpdone            lbsr      o_endmeasure
                    clr       orpin,u
                    ldd       orpsave,u
                    lbsr      o_seek
                    lbra      o_loop
o_end               tst       orpin,u
                    lbne      o_rpdone
                    lbsr      o_endm
                    lda       omcount,u
                    bmi       o_endmeter@         the meter is out already
                    lda       #$FF
                    sta       omcount,u
                    ldd       omlen,u
                    bne       o_endmlen@
                    ldd       #192
o_endmlen@          lbsr      o_meter             fewer than four measures: what there was
o_endmeter@         tst       otempoflag,u
                    bne       o_endtempo@
                    lbsr      o_temporec
o_endtempo@         rts
* the measure ends and a pending R starts its replay (the caller's token is read again afterwards)
o_endm              lbsr      o_endmeasure
                    tst       orpend,u
                    bmi       o_endm9@
                    lbsr      o_startreplay
                    leas      2,s
                    lbra      o_loop
o_endm9@            rts
* the measure ends: the start moves on by the longest voice; a pending part replay starts here
o_endmeasure        pshs      a,b,x
                    clra
                    clrb
                    leax      ovtime,u
                    pshs      a,b
                    ldy       #5
o_em1@              ldd       ,x++
                    cmpd      ,s
                    bls       o_em2@
                    std       ,s
o_em2@              leay      -1,y
                    bne       o_em1@
                    puls      a,b
                    pshs      a,b                 the measure's length
                    tst       oflag,u
                    beq       o_em4@              nothing was played: no measure
                    lda       omcount,u
                    bmi       o_em3@              the meter is out already
                    ldd       ,s
                    cmpd      omlen,u
                    bls       o_em2b@
                    std       omlen,u             the longest measure so far (a pickup measure is short)
o_em2b@             inc       omcount,u
                    lda       omcount,u
                    cmpa      #4
                    blo       o_em3@
                    lda       #$FF
                    sta       omcount,u
                    ldd       omlen,u
                    lbsr      o_meter             the time signature from the first four measures
o_em3@              ldd       omstart,u
                    addd      ,s
                    bcs       o_emlong@
                    std       omstart,u
                    cmpd      imax,u
                    bls       o_em4@
                    std       imax,u
o_em4@              leas      2,s
                    leax      ovtime,u
                    ldb       #10
o_em5@              clr       ,x+
                    decb
                    bne       o_em5@
                    clr       ovoice,u
                    clr       oclef,u
                    clr       onext,u
                    clr       oflag,u
                    lda       oopt,u
                    bita      #2
                    bne       o_em6@
                    lbsr      o_accclr
o_em6@              puls      a,b,x,pc
o_emlong@           lbra      o_toolong
* R nn takes effect: the part's text is read again from its P line
o_startreplay       ldb       orpend,u
                    lda       #$FF
                    sta       orpend,u
                    clra
                    aslb
                    rola
                    leax      opart,u
                    leax      d,x
                    ldd       ,x
                    beq       o_srnone@           an undefined part: nothing to replay
                    pshs      a,b
                    ldd       otok,u              the token that triggered the replay is read again afterwards
                    std       orpsave,u
                    puls      a,b
                    lbsr      o_seek
                    inc       orpin,u
o_srnone@           rts

* a note or a rest
o_rest              lda       #1
                    sta       orest,u
                    clr       oglyph,u
                    lbsr      o_ticks
                    lbsr      o_noterec
                    lbra      o_advance
o_note              cmpa      #'9
                    bls       o_nd@
                    suba      #7                  A..G = 10..16
o_nd@               suba      #'0
                    sta       oval,u
                    clr       orest,u
                    lda       oclef,u
                    cmpa      #2
                    lbeq      o_drum
                    ldb       onext,u
                    clr       onext,u
                    tstb
                    bne       o_nsign@
                    ldb       oclef,u
                    incb
o_nsign@            cmpb      #2
                    bne       o_nstep@
                    neg       oval,u
o_nstep@            ldb       ovoice,u
                    leax      ovtrans,u
                    lda       oval,u
                    adda      b,x
                    sta       oval,u              the step, transposed
                    lbsr      o_ticks
                    lbsr      o_modifiers
                    lbsr      o_pitchof
                    lbsr      o_noterec
                    lbsr      o_sound
                    lbra      o_advance
o_drum              lbsr      o_ticks
                    lbsr      o_modifiers
                    ldb       oval,u
                    leax      o_drums,pcr
                    lda       b,x
                    sta       opitch,u
                    ldb       ovoice,u
                    leax      ovperc,u
                    lda       #1
                    sta       b,x
                    lda       oartic,u            the percussion clef reverses the articulation
                    beq       o_drumart@
                    lda       #1
                    sta       oartic,u
o_drumart@          lbsr      o_noterec
                    lbsr      o_sound
* the voice moves on by the note's length
o_advance           ldb       ovoice,u
                    aslb
                    leax      ovtime,u
                    leax      b,x                 the voice's elapsed time
                    ldd       otick,u
                    addd      ,x
                    bcs       o_advlong@
                    std       ,x
                    lda       #1
                    sta       oflag,u
                    lbra      o_loop
o_advlong@          lbra      o_toolong
* the modifiers after a note: accidentals, then articulation (any order, any count)
o_modifiers         clr       oglyph,u
                    clr       oartic,u
                    clr       otmp+1,u            1 when an accidental was given
o_mod1@             lbsr      o_getc
                    cmpa      #'#
                    beq       o_msharp@
                    cmpa      #'&
                    beq       o_mflat@
                    cmpa      #'%
                    beq       o_mnat@
                    cmpa      #''
                    beq       o_mart1@
                    cmpa      #'"
                    beq       o_mart2@
                    cmpa      #';
                    beq       o_mart3@
                    cmpa      #',
                    beq       o_mart4@
                    lbsr      o_ungetc
                    rts
o_msharp@           lda       #1
                    bra       o_macc@
o_mflat@            lda       #-1
                    bra       o_macc@
o_mnat@             clra
o_macc@             ldb       otmp+1,u
                    beq       o_mfirst@
                    adda      otmp+2,u            ## && %# %&
o_mfirst@           sta       otmp+2,u
                    inc       otmp+1,u
                    bra       o_mod1@
o_mart1@            lda       #1
                    bra       o_mart@
o_mart2@            lda       #2
                    bra       o_mart@
o_mart3@            lda       #3
                    bra       o_mart@
o_mart4@            lda       #4
o_mart@             sta       oartic,u
                    bra       o_mod1@
* the note's sounding pitch: key signature, the measure's accidentals, the explicit one; C4 = 60
o_pitchof           lda       oval,u
                    adda      #35                 the step -15..16 becomes 20..51 (B1..E6)
                    ldb       #7
                    clr       otmp+3,u
o_po1@              cmpa      #7
                    blo       o_po2@
                    suba      #7
                    inc       otmp+3,u            the octave
                    bra       o_po1@
o_po2@              sta       otmp,u              the letter step 0 = C
                    leax      o_semis,pcr
                    lda       a,x
                    ldb       otmp+3,u
                    pshs      a
                    lda       #12
                    mul
                    addb      ,s+                 12 * octave + the letter's semitones (octave 5 = C4)
                    stb       opitch,u
* the accidental in force
                    lbsr      o_acctab
                    ldb       oval,u
                    addb      #15
                    cmpb      #31
                    bhi       o_pokey@            transposed off the table: the key signature alone
                    tst       otmp+1,u
                    beq       o_pokeep@
                    lda       otmp+2,u
                    adda      #4
                    sta       b,x                 explicit: remembered for the measure
                    lda       otmp+2,u
                    ldb       #2                  sharp glyph
                    tsta
                    bgt       o_poglyph@
                    ldb       #4                  natural glyph
                    beq       o_poglyph@
                    ldb       #7                  flat glyph
o_poglyph@          stb       oglyph,u
                    bra       o_poapply@
o_pokeep@           lda       b,x
                    beq       o_pokey@
                    suba      #4
                    bra       o_poapply@
o_pokey@            lda       otmp,u              the letter: is it in the key signature?
                    ldb       oksig,u
                    beq       o_ponone@
                    bmi       o_poflats@
                    leax      o_sharps,pcr
                    bra       o_pokl@
o_poflats@          negb
                    leax      o_flats,pcr
o_pokl@             cmpa      ,x+
                    beq       o_pokfound@
                    decb
                    bne       o_pokl@
o_ponone@           clra
                    bra       o_poapply@
o_pokfound@         lda       #1
                    tst       oksig,u
                    bpl       o_poapply@
                    nega
o_poapply@          adda      opitch,u
                    adda      otransp,u
o_pofold@           cmpa      #24
                    bhs       o_pohi@
                    adda      #12                 below C1: up an octave
                    bra       o_pofold@
o_pohi@             cmpa      #107
                    bls       o_podone@
                    suba      #12                 above B7: down an octave
                    bra       o_pohi@
o_podone@           sta       opitch,u
                    rts
* X = the accidental table in force (shared, or the voice's with O1)
o_acctab            leax      oacc,u
                    lda       oopt,u
                    bita      #1
                    beq       o_at9@
                    lda       ovoice,u
                    ldb       #32
                    mul
                    leax      ovacc,u
                    leax      d,x
o_at9@              rts
o_accclr            pshs      a,b,x
                    leax      oacc,u
                    ldd       #192
o_ac1@              clr       ,x+
                    subd      #1
                    bne       o_ac1@
                    puls      a,b,x,pc
* the duration in ticks from the current W..X letter and its modifier: 384 576 672 256 >> code
o_ticks             ldb       odmod,u
                    aslb
                    leax      o_lengths,pcr
                    ldd       b,x
                    pshs      d
                    ldb       odur,u
o_tk1@              lsr       ,s
                    ror       1,s
                    decb
                    bne       o_tk1@
                    puls      d
                    std       otick,u
                    rts
* the notation record: part = voice + 1, at the voice's time; slot from the step, glyph, $82 (imported)
o_noterec           tst       oflag,u
                    bne       o_nrbar@
                    tst       ipass,u             the measure's first note: its bar line goes down first
                    beq       o_nrcount@
                    ldd       omstart,u
                    cmpd      ilastb,u
                    beq       o_nrbar@
                    lbsr      mi_barat
                    bra       o_nrbar@
o_nrcount@          ldd       icount,u
                    addd      #1
                    std       icount,u
o_nrbar@            lbsr      o_record
                    lda       ovoice,u
                    inca
                    sta       irec,u
                    lda       odur,u
                    sta       irec+3,u
                    lda       odmod,u
                    sta       irec+4,u
                    tst       orest,u
                    beq       o_nr1@
                    lda       #32
                    sta       irec+5,u
                    bra       o_nr2@
o_nr1@              lda       oclef,u
                    cmpa      #2
                    bne       o_nrpitch@
                    lda       oval,u              a drum: its step on the percussion staff
                    bra       o_nrslot@
o_nrpitch@          lda       oval,u
o_nrslot@           suba      #3
                    ldb       ovoice,u
                    leax      istf,u
                    ldb       b,x
                    leax      o_stfofs,pcr
                    adda      b,x
                    sta       irec+5,u
                    lda       oglyph,u
                    sta       irec+6,u
o_nr2@              lda       #$82
                    sta       irec+7,u
                    ldb       ovoice,u
                    leax      imap,u
                    lda       #1
                    sta       b,x
                    lbsr      o_marks             a register change is marked before the note
                    lbra      o_emit
* the raw MIDI note on at the note's time and the note off at its gate: the player plays these
o_sound             tst       ipass,u
                    bne       o_snd1@
                    lda       opitch,u            pass zero: the voice's range
                    ldb       ovoice,u
                    leax      iseen,u
                    tst       b,x
                    bne       o_sndlo@
                    inc       b,x
                    leax      ilo,u
                    sta       b,x
                    leax      ihi,u
                    sta       b,x
                    bra       o_snd1@
o_sndlo@            leax      ilo,u
                    cmpa      b,x
                    bhs       o_sndhi@
                    sta       b,x
o_sndhi@            leax      ihi,u
                    cmpa      b,x
                    bls       o_snd1@
                    sta       b,x
o_snd1@             lbsr      o_record
                    lbsr      o_channel
                    ora       #$90
                    sta       irec+3,u
                    lda       opitch,u
                    sta       irec+4,u
                    lda       #100+$80
                    sta       irec+7,u
                    lbsr      o_raw
                    lbsr      o_record
                    lbsr      o_channel
                    ora       #$80
                    sta       irec+3,u
                    lda       opitch,u
                    sta       irec+4,u
                    lda       #$80
                    sta       irec+7,u
* the gate: full, 7/8, 3/4, 1/2, 1/2 (a drum: 1/8)
                    ldd       otick,u
                    lda       oartic,u
                    beq       o_gatefull@
                    cmpa      #1
                    bne       o_gate2@
                    ldd       otick,u
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    pshs      d
                    ldd       otick,u
                    subd      ,s++
                    bra       o_gateset@
o_gate2@            cmpa      #2
                    bne       o_gate3@
                    ldd       otick,u
                    lsra
                    rorb
                    lsra
                    rorb
                    pshs      d
                    ldd       otick,u
                    subd      ,s++
                    bra       o_gateset@
o_gate3@            ldd       otick,u
                    lsra
                    rorb
                    bra       o_gateset@
o_gatefull@         ldd       otick,u
o_gateset@          addd      irec+1,u
                    std       irec+1,u
                    lbra      o_raw
* A = the voice's MIDI channel (9 for the percussion clef)
o_channel           lda       oclef,u
                    cmpa      #2
                    bne       o_ch1@
                    lda       #9
                    rts
o_ch1@              lda       ovoice,u
                    rts
* a voice whose register changed since its last mark gets channel ($16) and instrument ($17) records
o_marks             ldb       ovoice,u
                    leax      ovreg,u
                    lda       b,x
                    leax      ovlast,u
                    cmpa      b,x
                    beq       o_mk9@
                    sta       b,x
                    leax      irec,u
                    ldd       ,x
                    pshs      d
                    ldd       2,x
                    pshs      d
                    ldd       4,x
                    pshs      d
                    ldd       6,x
                    pshs      d
                    lbsr      o_record
                    lda       ovoice,u
                    inca
                    sta       irec+6,u
                    lbsr      o_channel
                    sta       irec+7,u
                    lda       #$16
                    sta       irec+5,u
                    lbsr      o_emit
                    lbsr      o_record
                    lda       ovoice,u
                    inca
                    sta       irec+6,u
                    ldb       ovoice,u
                    leax      ovreg,u
                    ldb       b,x
                    leax      oregslot,u
                    lda       b,x
                    sta       irec+7,u
                    lda       #$17
                    sta       irec+5,u
                    lbsr      o_emit
                    leax      irec,u
                    puls      d
                    std       6,x
                    puls      d
                    std       4,x
                    puls      d
                    std       2,x
                    puls      d
                    std       ,x
o_mk9@              rts
* records
o_record            leax      irec,u
                    ldb       #8
o_rc1@              clr       ,x+
                    decb
                    bne       o_rc1@
                    ldb       ovoice,u
                    aslb
                    leax      ovtime,u
                    ldd       b,x
                    addd      omstart,u
                    std       irec+1,u
                    std       itime,u
                    rts
o_raw               lda       #$1E
                    sta       irec+5,u
                    lda       #$40
                    sta       irec+6,u
* every record goes in by time (a voice's notes come after the earlier voices' in the text)
o_emit              tst       ipass,u
                    beq       o_count@
                    leax      irec,u
                    ldy       iframe,u
                    lbsr      MidiScoreAdd
                    lbeq      mi_memory
                    rts
o_count@            ldd       icount,u
                    addd      #1
                    cmpd      #30000
                    lbhi      o_bad
                    std       icount,u
                    rts
* the tempo: beats per minute = 15360 / value (C0 = 80, 80 = 120); a NUTEMPO ($19) record at the measure start
o_temporec          lda       #1
                    sta       otempoflag,u
                    clra
                    ldb       otempo,u
                    lbeq      o_bad
                    std       otmp,u              the divisor
                    ldd       #15360
                    clr       otmp+2,u
                    clr       otmp+3,u
o_tp1@              subd      otmp,u
                    bcs       o_tp2@
                    pshs      d
                    ldd       otmp+2,u
                    addd      #1
                    std       otmp+2,u
                    puls      d
                    bra       o_tp1@
o_tp2@              lbsr      o_record
                    ldd       omstart,u
                    std       irec+1,u
                    ldd       otmp+2,u
                    sta       irec+4,u
                    stb       irec+3,u
                    ldd       #$4F52              'OR'
                    std       irec+6,u
                    lda       #$19
                    sta       irec+5,u
                    lbra      o_emit
* the time signature: beats from the first measure's length (D) and the N unit, at tick 0
o_meter             pshs      d
                    ldd       #384
                    ldb       ounit,u
                    pshs      b
                    ldd       #384
o_mt1@              lsra
                    rorb
                    dec       ,s
                    bne       o_mt1@
                    leas      1,s                 D = the beat's ticks
                    std       otmp,u
                    puls      d
                    clr       otmp+2,u
o_mt2@              subd      otmp,u
                    bcs       o_mt3@
                    inc       otmp+2,u
                    bra       o_mt2@
o_mt3@              addd      otmp,u
                    lsl       otmp+1,u            a remainder over half a beat rounds up
                    rol       otmp,u
                    cmpd      otmp,u
                    blo       o_mt4@
                    inc       otmp+2,u
o_mt4@              tst       otmp+2,u
                    bne       o_mt5@
                    inc       otmp+2,u
o_mt5@              lbsr      o_record
                    clr       irec+1,u
                    clr       irec+2,u
                    lda       #$0A
                    sta       irec+5,u
                    lda       otmp+2,u
                    sta       irec+6,u
                    lda       #1
                    ldb       ounit,u
o_mt6@              decb
                    beq       o_mt7@
                    asla
                    bra       o_mt6@
o_mt7@              sta       irec+7,u
                    lbra      o_emit
* INSTRS: one slot per register A..E, the GM program matched from the harmonic weights, a 7-character name
o_instrs            lda       #1
                    sta       <UmeData_instren                enable ordinary instrument changes
                    ldx       #$075F
                    ldy       #$07EB
                    ldb       #64
o_ic1@              clr       ,x+
                    lda       #$80
                    sta       ,x+
                    clr       ,y
                    leay      16,y
                    decb
                    bne       o_ic1@
                    clr       otmp,u              the register
o_ic2@              lda       otmp,u
                    ldb       #10
                    mul
                    leax      oreg,u
                    leax      d,x
                    lbsr      o_gmmatch           A = program, X = the name
                    ldb       otmp,u
                    pshs      x
                    leax      oregslot,u
                    stb       b,x                 slot = register index
                    leax      oregprog,u
                    sta      b,x
                    aslb
                    ldx       #$075F
                    leax      b,x
                    ora       #$80
                    sta       1,x
                    lda       otmp,u
                    ldb       #16
                    mul
                    ldy       #$07EB
                    leay      d,y
                    puls      x
                    ldb       #7
o_ic3@              lda       ,x+
                    sta       ,y+
                    decb
                    bne       o_ic3@
                    clr       ,y
                    inc       otmp,u
                    lda       otmp,u
                    cmpa      #5
                    blo       o_ic2@
                    rts
* the nearest known register: X = wave, 8 weights, volume. Both spectra are scaled to a loudest
* partial of 15 before comparing (sum of |w' - k'|), so the register's volume plays no part. A random
* wave is a drum. Returns A = the GM program, X = its 7-character name.
o_gmmatch           lda       ,x
                    cmpa      #'R
                    bne       o_gm1@
                    leax      o_drumname,pcr
                    lda       #118
                    rts
o_gm1@              leax      1,x
                    stx       ogwbase,u
                    clr       otmp+1,u            wm: the register's loudest partial
                    ldb       #8
o_gmmax@            lda       ,x+
                    cmpa      otmp+1,u
                    bls       o_gmm1@
                    sta       otmp+1,u
o_gmm1@             decb
                    bne       o_gmmax@
                    tst       otmp+1,u
                    bne       o_gm2@
                    inc       otmp+1,u
* the register scaled to 15: w * 15 / wm, rounded, into ognorm
o_gm2@              ldx       ogwbase,u
                    leay      ognorm,u
                    ldb       #8
                    stb       oglyph,u
o_gmn@              lda       ,x+
                    ldb       #15
                    mul
                    pshs      x
                    ldx       #0
o_gmdiv@            subb      otmp+1,u
                    sbca      #0
                    bcs       o_gmdivd@
                    leax      1,x
                    bra       o_gmdiv@
o_gmdivd@           addb      otmp+1,u            the remainder back
                    aslb                          twice the remainder against wm: round up
                    cmpb      otmp+1,u
                    blo       o_gmround@
                    leax      1,x
o_gmround@          tfr       x,d
                    puls      x
                    stb       ,y+
                    dec       oglyph,u
                    bne       o_gmn@
                    ldd       #$FFFF
                    std       ogdist,u
                    leay      o_known,pcr
o_gme@              tst       ,y
                    lbeq      o_gmdone
                    clr       ogcur,u
                    clr       ogcur+1,u
                    leax      ognorm,u
                    stx       ogwp,u
                    leax      7,y
                    stx       ogep,u
                    ldb       #8
                    stb       oglyph,u
o_gmp@              ldx       ogwp,u
                    lda       ,x+
                    stx       ogwp,u
                    ldx       ogep,u
                    suba      ,x+
                    stx       ogep,u
                    bcc       o_gmabs@
                    nega
o_gmabs@            tfr       a,b
                    clra
                    addd      ogcur,u
                    std       ogcur,u
                    dec       oglyph,u
                    bne       o_gmp@
                    ldd       ogcur,u
                    cmpd      ogdist,u
                    bhs       o_gmnext@
                    std       ogdist,u
                    sty       ogbest,u
o_gmnext@           leay      17,y
                    lbra      o_gme@
o_gmdone            ldy       ogbest,u
                    lda       16,y                the program
                    leax      ,y                  the name
                    rts
* after pass zero: each voice's channel and, for a percussion voice, its staff
o_mapfill           leax      imap,u
                    clrb
o_mf1@              lda       ovperc+0,u
                    pshs      x
                    leax      ovperc,u
                    lda       b,x
                    puls      x
                    beq       o_mf2@
                    lda       #4
                    sta       16,x
                    lda       #9
                    sta       96,x
                    bra       o_mf3@
o_mf2@              stb       96,x
o_mf3@              leax      1,x
                    incb
                    cmpb      #5
                    blo       o_mf1@
                    rts
* the reader: a 64-byte window on the file, one character at a time, with one pushback and a seek
o_getc              lda       ounget,u
                    beq       o_gc1@
                    clr       ounget,u
                    tsta
                    rts
o_gc1@              tst       oeof,u
                    bne       o_gceof@
                    ldb       obpos,u
                    cmpb      oblen,u
                    blo       o_gc2@
                    ldd       obase,u
                    addb      oblen,u
                    adca      #0
                    std       obase,u
                    clr       obpos,u
                    clr       oblen,u
                    leax      obuf,u
                    ldy       #64
                    pshs      u
                    lda       ipath,u
                    os9       I$Read
                    puls      u
                    bcs       o_gcend@
                    tfr       y,d
                    tstb
                    beq       o_gcend@
                    stb       oblen,u
                    clrb
o_gc2@              leax      obuf,u
                    lda       b,x
                    inc       obpos,u
                    tsta
                    bne       o_gc9@
                    lda       #C$SPAC             a NUL in the text reads as a space
o_gc9@              rts
o_gcend@            inc       oeof,u
o_gceof@            clra
                    rts
o_ungetc            sta       ounget,u
                    rts
* o_getp: the next character that is not a blank or a line end (a command's digit may sit on the next line)
o_getp              lbsr      o_getc
                    beq       o_gp9@
                    cmpa      #C$SPAC
                    bls       o_getp
o_gp9@              rts
o_seek              pshs      x,y,u
                    std       obase,u
                    clr       obpos,u
                    clr       oblen,u
                    clr       oeof,u
                    clr       ounget,u
                    tfr       d,u
                    ldx       #0
                    ldy       4,s
                    lda       ipath,y
                    os9       I$Seek
                    puls      x,y,u
                    lbcs      o_bad
                    rts
* one hex digit -> A (a non-digit is pushed back and reads as 0)
o_hex               lbsr      o_getp
                    cmpa      #'a
                    blo       o_hx1@
                    suba      #32
o_hx1@              cmpa      #'0
                    blo       o_hxno@
                    cmpa      #'9
                    bls       o_hxd@
                    cmpa      #'A
                    blo       o_hxno@
                    cmpa      #'F
                    bhi       o_hxno@
                    suba      #7
o_hxd@              suba      #'0
                    rts
o_hxno@             lbsr      o_ungetc
                    clra
                    rts
o_hex2              lbsr      o_hex
                    asla
                    asla
                    asla
                    asla
                    sta       otmp+3,u
                    lbsr      o_hex
                    ora       otmp+3,u
                    rts

mi_memory           leax      o_memmsg,pcr
                    bra       o_error
o_error             lds       iroot,u
                    clra
                    clrb
                    pshs      d
                    pshs      x
                    ldy       iframe,u
                    jsr       [>UmeData_palert]
                    leas      4,s
                    clra
                    clrb
                    lbra      o_exit

o_lengths           fdb       384,576,672,256
o_semis             fcb       0,2,4,5,7,9,11
o_sharps            fcb       3,0,4,1,5,2,6       F C G D A E B
o_flats             fcb       6,2,5,1,4,0,3       B E A D G C F
o_stfofs            fcb       0,6,8,12,12
o_drums             fcb       35,36,38,40,42,44,46,49,51,37,39,41,43,45,47,48
o_drumname          fcc       /SynDrum/
* the compiler's default registers (wave, eight weights, volume)
o_defregs           fcb       'S,$E,$F,$A,$5,0,0,0,0,$E      A trumpet
                    fcb       'S,$4,$8,$F,$8,0,0,0,0,$F      B oboe
                    fcb       'S,$E,$0,$5,$0,0,0,0,0,$A      C clarinet
                    fcb       'S,$F,$4,$0,$8,0,0,0,0,$B      D organ
                    fcb       'S,$4,$F,$2,$8,0,0,0,0,$D      E violin
* the known registers: 7-character name, the eight weights scaled to a loudest partial of 15, a spare byte, the GM
* program (17 bytes). The five defaults as the manual gives them twice (chapter 6 and 7), then appendix D.
o_known             fcc       /Trumpet/
                    fcb       $E,$F,$A,$5,$0,$0,$0,$0,0,56
                    fcc       /Oboe   /
                    fcb       $4,$8,$F,$8,$0,$0,$0,$0,0,68
                    fcc       /Oboe   /
                    fcb       $4,$8,$F,$8,$F,$2,$0,$0,0,68
                    fcc       /Clarnet/
                    fcb       $F,$0,$5,$0,$0,$0,$0,$0,0,71
                    fcc       /Clarnet/
                    fcb       $E,$0,$5,$0,$F,$0,$0,$0,0,71
                    fcc       /Organ  /
                    fcb       $F,$4,$0,$8,$0,$0,$0,$0,0,19
                    fcc       /Violin /
                    fcb       $4,$F,$2,$8,$0,$0,$0,$0,0,40
                    fcc       /Violin /
                    fcb       $4,$F,$2,$8,$1,$4,$0,$0,0,40
                    fcc       /Flute  /
                    fcb       $F,$3,$C,$6,$0,$0,$0,$0,0,73
                    fcc       /Flute  /
                    fcb       $F,$2,$0,$2,$0,$0,$0,$0,0,73
                    fcc       /Mellphn/
                    fcb       $D,$F,$F,$B,$0,$4,$0,$2,0,60
                    fcc       /Flute  /
                    fcb       $9,$F,$4,$9,$0,$4,$0,$2,0,73
                    fcc       /Flute  /
                    fcb       $8,$B,$F,$0,$4,$4,$0,$0,0,73
                    fcc       /Violin /
                    fcb       $4,$9,$F,$B,$6,$4,$0,$2,0,40
                    fcc       /Cello  /
                    fcb       $8,$A,$F,$8,$0,$3,$0,$3,0,42
                    fcc       /Viola  /
                    fcb       $6,$C,$F,$3,$0,$3,$0,$9,0,41
                    fcc       /Violin /
                    fcb       $B,$D,$F,$2,$0,$4,$0,$2,0,40
                    fcc       /Cello  /
                    fcb       $A,$3,$F,$5,$5,$3,$0,$8,0,42
                    fcc       /Bassoon/
                    fcb       $F,$0,$D,$3,$3,$3,$0,$3,0,70
                    fcc       /Bugle  /
                    fcb       $A,$C,$E,$F,$8,$6,$0,$4,0,56
                    fcc       /Clarion/
                    fcb       $0,$F,$0,$F,$0,$F,$0,$C,0,19
                    fcc       /Dulzian/
                    fcb       $4,$0,$4,$F,$B,$8,$0,$4,0,70
                    fcc       /Bazu   /
                    fcb       $3,$8,$3,$D,$3,$8,$0,$F,0,111
                    fcc       /EngHorn/
                    fcb       $9,$4,$F,$9,$2,$4,$0,$9,0,69
                    fcc       /FrHorn /
                    fcb       $F,$B,$D,$D,$0,$0,$0,$0,0,60
                    fcc       /Reed   /
                    fcb       $0,$3,$F,$3,$0,$C,$0,$9,0,111
                    fcc       /Schalmi/
                    fcb       $6,$3,$0,$6,$C,$F,$0,$9,0,20
                    fcc       /Sackbut/
                    fcb       $F,$9,$3,$3,$0,$0,$0,$0,0,57
                    fcc       /Sax    /
                    fcb       $F,$C,$6,$0,$0,$4,$0,$2,0,65
                    fcc       /Tuba   /
                    fcb       $F,$F,$8,$F,$F,$F,$0,$F,0,58
                    fcc       /Stentor/
                    fcb       $C,$F,$C,$E,$6,$0,$0,$0,0,60
                    fcc       /Trombon/
                    fcb       $E,$F,$F,$E,$A,$6,$0,$2,0,57
                    fcc       /Waldhrn/
                    fcb       $D,$F,$F,$2,$2,$2,$F,$1,0,60
                    fcc       /Banjo  /
                    fcb       $3,$8,$D,$F,$F,$F,$0,$5,0,105
                    fcc       /Bells  /
                    fcb       $A,$0,$0,$F,$0,$0,$0,$A,0,14
                    fcc       /Celesta/
                    fcb       $5,$F,$0,$5,$0,$5,$0,$5,0,8
                    fcc       /Chimes /
                    fcb       $3,$F,$0,$3,$0,$0,$0,$3,0,14
                    fcc       /Glocken/
                    fcb       $0,$F,$0,$0,$0,$0,$0,$F,0,9
                    fcc       /Harp   /
                    fcb       $F,$6,$0,$3,$3,$3,$6,$0,0,46
                    fcc       /Marimba/
                    fcb       $8,$0,$0,$F,$0,$0,$0,$0,0,12
                    fcc       /Zink   /
                    fcb       $0,$B,$0,$B,$0,$F,$0,$F,0,56
                    fcc       /VoxHumn/
                    fcb       $F,$0,$0,$F,$F,$F,$0,$F,0,52
                    fcc       /Sarruso/
                    fcb       $2,$6,$F,$0,$6,$4,$0,$2,0,70
                    fcc       /Ophicld/
                    fcb       $F,$F,$F,$F,$F,$F,$0,$F,0,58
                    fcc       /SoloSax/
                    fcb       $F,$C,$A,$0,$0,$0,$0,$0,0,65
                    fcc       /Clarnet/
                    fcb       $F,$0,$F,$0,$D,$3,$0,$3,0,71
                    fcc       /Corno  /
                    fcb       $0,$F,$0,$9,$0,$4,$0,$0,0,60
                    fcc       /MiniBel/
                    fcb       $4,$0,$0,$8,$0,$0,$0,$F,0,9
                    fcc       /Strings/
                    fcb       $4,$F,$4,$4,$4,$4,$0,$4,0,48
                    fcc       /Piano  /
                    fcb       $F,$C,$9,$6,$3,$3,$0,$3,0,0
                    fcb       0
o_badmsg            fcc       /Invalid Orchestra-90 music file./
                    fcb       0
o_longmsg           fcc       /Orchestra-90 score exceeds UME 65534-tick timeline./
                    fcb       0
o_memmsg            fcc       /Not enough memory for Orchestra-90 score./
                    fcb       0
                    use       midi_bars.inc
                    use       midi_score.inc
                    use       import_staff.inc
                    fill      0,$1D00-*           pad to $1D00 bytes so F$Link never puts this overlay in slot 7 and the score page always gets it
                    emod
eom                 equ       *
                    ifgt      eom-$2000
                    error     s9o exceeds its 8 KB overlay slot
                    endc
