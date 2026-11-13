* A=open path. Reject non-RBF before interpreting option/FD/directory bytes.
* Preserve A/X/Y/U; return B and carry as an OS-9 error result.
RequireRBF          pshs      a,x,y,u   ; preserve a,x,y,u on stack
                    leas      -32,s     ; point S at -32,s
                    leax      ,s        ; point X at ,s
                    ldb       #SS.Opt   ; load B from #SS.Opt
                    os9       I$GetStt  ; invoke OS-9 I$GetStt service
                    bcs       rbfgret@  ; branch on carry or error rbfgret@
                    lda       ,s        ; load A from ,s
                    cmpa      #DT.RBF   ; compare A with #DT.RBF
                    beq       rbfgok@   ; branch when equal or zero rbfgok@
                    ldb       #E$BTyp   ; load B from #E$BTyp
                    coma                ; complement A and set carry
                    bra       rbfgret@  ; continue unconditionally rbfgret@
rbfgok@             clrb                ; clear accumulator B and carry
rbfgret@            leas      32,s      ; point S at 32,s
                    puls      a,x,y,u,pc ; restore a,x,y,u,pc from stack
