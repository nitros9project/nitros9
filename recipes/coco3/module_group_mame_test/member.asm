                    use       defsfile
                    mod       eom,name,Sbrtn+Objct,ReEnt+1,entry,0
name
                  IFEQ    GROUP-1
                  IFEQ    MEMBER-1
                    fcs       /ShortA/
                  ELSE
                    fcs       /ShortB/
                  ENDC
                  ENDC
                  IFEQ    GROUP-2
                  IFEQ    MEMBER-1
                    fcs       /LongA/
                  ELSE
                    fcs       /LongB/
                  ENDC
                  ENDC
                  IFEQ    GROUP-3
                  IFEQ    MEMBER-1
                    fcs       /ResidentA/
                  ELSE
                    fcs       /ResidentB/
                  ENDC
                  ENDC
                    fcb       1
entry               ldb       #$A0+MEMBER
                    rts
                  IFEQ    GROUP-2
                  IFEQ    MEMBER-1
                    fill      0,8200-*
                  ENDC
                  ENDC
                    emod
eom                 equ       *
