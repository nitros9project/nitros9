* Readers and arithmetic for the MIDI importer. Every byte of a track comes
* through its own buffer; the file position is set before each refill, so the
* tracks can be read side by side.
* Seek to the 32-bit offset X points at.
mi_seekx            pshs      y,u
                    lda       ipath,u
                    ldu       2,x
                    ldx       ,x
                    os9       I$Seek
                    puls      y,u
                    lbcs      mi_bad
                    rts
* Exactly Y bytes to X (chunk headers); a short read is a truncated file.
mi_readn            pshs      y
                    lda       ipath,u
                    os9       I$Read
                    puls      x
                    lbcs      mi_bad
                    pshs      x
                    cmpy      ,s++
                    lbne      mi_bad
                    rts
* One byte of the current track. The chunk end is an error here: callers only
* ask for bytes the chunk must still hold.
mi_tbyte            ldx       itrk,u
                    ldd       tleft,x
                    bne       mi_dec@
                    ldd       tleft+2,x
                    lbeq      mi_bad
mi_dec@             ldd       tleft+2,x
                    subd      #1
                    std       tleft+2,x
                    ldd       tleft,x
                    sbcb      #0
                    sbca      #0
                    std       tleft,x
                    ldb       tbpos,x
                    cmpb      tblen,x
                    blo       mi_have@
                    lbsr      mi_fill
                    ldx       itrk,u
                    clrb
mi_have@            pshs      b
                    incb
                    stb       tbpos,x
                    lda       icur,u
                    ldb       ibufsz+1,u
                    mul
                    leay      ipool,u
                    leay      d,y                 this track's buffer
                    puls      b
                    clra
                    leay      d,y
                    ldb       ,y
                    tstb
                    rts
* Refill the current track's buffer from where it left off in the file.
mi_fill             ldx       itrk,u
                    leax      tpos,x
                    lbsr      mi_seekx
                    lda       icur,u
                    ldb       ibufsz+1,u
                    mul
                    leax      ipool,u
                    leax      d,x
                    ldy       ibufsz,u
                    lda       ipath,u
                    os9       I$Read
                    lbcs      mi_bad
                    tfr       y,d
                    ldx       itrk,u
                    stb       tblen,x
                    tstb
                    lbeq      mi_bad
                    clr       tbpos,x
                    clra
                    addd      tpos+2,x
                    std       tpos+2,x
                    ldd       tpos,x
                    adcb      #0
                    adca      #0
                    std       tpos,x
                    rts
mi_vlq              clr       inum,u
                    clr       inum+1,u
                    clr       inum+2,u
                    clr       inum+3,u
                    lda       #4
                    pshs      a
mi_vnext@           lbsr      mi_tbyte
                    pshs      b
                    ldb       #7
mi_vshift@          lsl       inum+3,u
                    rol       inum+2,u
                    rol       inum+1,u
                    rol       inum,u
                    decb
                    bne       mi_vshift@
                    puls      b
                    pshs      b
                    andb      #$7F
                    orb       inum+3,u
                    stb       inum+3,u
                    puls      b
                    tstb
                    bpl       mi_vdone@
                    dec       ,s
                    bne       mi_vnext@
                    lbra      mi_bad
mi_vdone@           leas      1,s
                    rts
mi_skip             ldd       inum,u
                    std       ilen,u
                    ldd       inum+2,u
                    std       ilen+2,u
mi_skiploop@        ldd       ilen,u
                    bne       mi_skipone@
                    ldd       ilen+2,u
                    beq       mi_skipdone@
mi_skipone@         lbsr      mi_tbyte
                    ldd       ilen+2,u
                    subd      #1
                    std       ilen+2,u
                    ldd       ilen,u
                    sbcb      #0
                    sbca      #0
                    std       ilen,u
                    bra       mi_skiploop@
mi_skipdone@        rts
* The current track's next delta -> its time in 48ths of a quarter (the PPQN
* remainder is carried per track), its next-event time, and the final tick.
mi_delta            lbsr      mi_vlq
                    ldb       #4                  x16 (a delta is under 2^28)
mi_sh4@             lsl       inum+3,u
                    rol       inum+2,u
                    rol       inum+1,u
                    rol       inum,u
                    decb
                    bne       mi_sh4@
                    ldd       inum,u
                    std       itmp,u
                    ldd       inum+2,u
                    std       itmp+2,u
                    lsl       inum+3,u            x2, + x16 = x48
                    rol       inum+2,u
                    rol       inum+1,u
                    rol       inum,u
                    lbcs      mi_range
                    ldd       inum+2,u
                    addd      itmp+2,u
                    std       inum+2,u
                    ldd       inum,u
                    adcb      itmp+1,u
                    adca      itmp,u
                    lbcs      mi_range
                    std       inum,u
                    ldx       itrk,u
                    ldd       inum+2,u
                    addd      trem,x
                    std       inum+2,u
                    ldd       inum,u
                    adcb      #0
                    adca      #0
                    std       inum,u
                    lbsr      mi_div16
                    ldx       itrk,u
                    ldd       imod,u
                    std       trem,x
                    ldd       inum+2,u
                    addd      ttime,x
                    lbcs      mi_range
                    std       ttime,x
                    std       tnext,x
                    cmpd      imax,u
                    bls       mi_deltaok@
                    std       imax,u
mi_deltaok@         rts
* inum / idiv: quotient in inum+2, remainder in imod. A quotient that would
* not fit 16 bits is a time past 65535 ticks.
mi_div16            ldd       inum,u
                    cmpd      idiv,u
                    lbhs      mi_range
                    std       imod,u
                    lda       #16
                    pshs      a
mi_dvl@             lsl       inum+3,u
                    rol       inum+2,u
                    rol       imod+1,u
                    rol       imod,u
                    bcs       mi_dvs@
                    ldd       imod,u
                    cmpd      idiv,u
                    blo       mi_dvn@
mi_dvs@             ldd       imod,u
                    subd      idiv,u
                    std       imod,u
                    inc       inum+3,u
mi_dvn@             dec       ,s
                    bne       mi_dvl@
                    puls      a,pc
* Unsigned 32/32 restoring division, quotient in inum, remainder in imod (tempo).
mi_divide           ldd       iden,u
                    bne       mi_divok@
                    ldd       iden+2,u
                    lbeq      mi_bad
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

mi_bad              leax      mi_badmsg,pcr
                    bra       mi_error
mi_format           leax      mi_fmtmsg,pcr
                    bra       mi_error
mi_range            leax      mi_rangemsg,pcr
                    bra       mi_error
mi_empty            leax      mi_emptymsg,pcr
                    bra       mi_error
mi_memory           leax      mi_memmsg,pcr
                    bra       mi_error
mi_polyerr          leax      mi_polymsg,pcr
                    bra       mi_error
mi_pitcherr         leax      mi_pitchmsg,pcr
                    bra       mi_error
mi_tracks           leax      mi_trackmsg,pcr
                    bra       mi_error
mi_tempoerr         leax      mi_tempomsg,pcr
                    bra       mi_error
mi_error            lds       iroot,u
                    clra
                    clrb
                    pshs      d
                    pshs      x
                    ldy       iframe,u
                    jsr       [>UmeData_palert]
                    leas      4,s
                    clra
                    clrb
                    lbra      mi_exit
mi_badmsg           fcc       /Invalid or truncated MIDI file; import stopped./
                    fcb       0
mi_fmtmsg           fcc       /MIDI import needs SMF format 0 or 1 with PPQN timing./
                    fcb       0
mi_rangemsg         fcc       /MIDI exceeds 65535 score ticks or 30000 events./
                    fcb       0
mi_emptymsg         fcc       /MIDI file contains no score events./
                    fcb       0
mi_memmsg           fcc       /Not enough score memory for MIDI import./
                    fcb       0
mi_polymsg          fcc       /MIDI exceeds 64 simultaneous pending notes./
                    fcb       0
mi_pitchmsg         fcc       /MIDI note outside supported pitch range 24-107./
                    fcb       0
mi_trackmsg         fcc       /MIDI file has more than 32 tracks./
                    fcb       0
mi_tempomsg         fcc       /MIDI tempo outside supported range 1-255 BPM./
                    fcb       0
