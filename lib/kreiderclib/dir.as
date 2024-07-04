                    section   code
                    
                    export    _chdir
                    export    _chxdir

_chdir              lda       #1
L0002               ldx       2,s
                    os9       I$ChgDir
                    lbra      _sysret
_chxdir             lda       #4
                    bra       L0002

                    endsect

