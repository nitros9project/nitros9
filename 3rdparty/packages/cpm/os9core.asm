curoff              fcb       $05,$20
curon               fcb       $05,$21
insline             fcb       $1f,$30
delline             fcb       $1f,$31
cls                 fcb       $0c
home                fcb       $01
revon               fcb       $1f,$20
revoff              fcb       $1f,$21


_exit               lbsr      _deinit
                    ldd       #0
                    os9       F$Exit


_abort              pshs      b
                    lbsr      _deinit
                    puls      b
                    clra
                    os9       F$Exit

_delline            lda       #stdout
                    leax      delline,pcr
                    ldy       #2
                    os9       I$Write
                    rts

_insline            lda       #stdout
                    leax      insline,pcr
                    ldy       #2
                    os9       I$Write
                    rts

_curon              lda       #stdout
                    leax      curon,pcr
                    ldy       #2
                    os9       I$Write
                    rts

_curoff             lda       #stdout
                    leax      curoff,pcr
                    ldy       #2
                    os9       I$Write
                    rts

_cls                lda       #stdout
                    leax      cls,pcr
                    ldy       #1
                    os9       I$Write
                    rts

_revon              lda       #stdout
                    leax      revon,pcr
                    ldy       #2
                    os9       I$Write
                    rts

_revoff             lda       #stdout
                    leax      revoff,pcr
                    ldy       #2
                    os9       I$Write
                    rts

_home               lda       #stdout
                    leax      home,pcr
                    ldy       #1
                    os9       I$Write
                    lbcs      _abort
                    rts

