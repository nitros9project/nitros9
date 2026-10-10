* Common MIDI/Lyra staff selection after the validation pass.
* B = part slots to inspect; U = private importer frame containing ilo/ihi/istf.
* Range midpoint: G4+ treble, C4+ alto, F3+ tenor, lower bass.
* Percussion stays on staff 4. Preserves B/U/Y; clobbers A/X/CC.
ImportStaffs        pshs      b
                    clrb
is_next@            cmpb      ,s
                    bhs       is_done@
                    leax      istf,u
                    lda       b,x
                    cmpa      #4
                    beq       is_advance@
                    leax      ilo,u
                    lda       b,x
                    leax      ihi,u
                    adda      b,x
                    lsra
                    leax      istf,u
                    clr       b,x
                    cmpa      #67
                    bhs       is_advance@
                    inc       b,x
                    cmpa      #60
                    bhs       is_advance@
                    inc       b,x
                    cmpa      #53
                    bhs       is_advance@
                    inc       b,x
is_advance@         incb
                    bra       is_next@
is_done@            puls      b,pc
