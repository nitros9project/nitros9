* A=open path. Reject non-RBF before interpreting option/FD/directory bytes.
* Preserve A/X/Y/U; return B and carry as an OS-9 error result.
RequireRBF          pshs      a,x,y,u
                    leas      -32,s
                    leax      ,s
                    ldb       #SS.Opt
                    os9       I$GetStt
                    bcs       rbfgret@
                    lda       ,s
                    cmpa      #DT.RBF
                    beq       rbfgok@
                    ldb       #E$BTyp
                    coma
                    bra       rbfgret@
rbfgok@             clrb
rbfgret@            leas      32,s
                    puls      a,x,y,u,pc
