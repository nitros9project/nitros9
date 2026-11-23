* A=directory path, X=result, Y=32/45. Preserve caller pointers and count.
* Try the portable interface first; older RBFs retain raw records/SS.FDInf.
ReadDirCompat       ldb       #SS.ReadDir ; portable enumeration service
                    os9       I$GetStt  ; ask the file manager
                    bcc       compatret@ ; complete portable result
                    cmpb      #E$UnkSvc ; only unsupported service permits fallback
                    bne       compaterror@ ; propagate media/mode/transport errors
                    pshs      a,x,y,u   ; retain path, output, requested size, globals
compatnext@         ldx       1,s       ; output record
                    ldy       #32       ; native RBF directory record size
                    lda       ,s        ; directory path
                    os9       I$Read    ; consume one raw record
                    bcs       compatdone@ ; return EOF or read failure
                    cmpy      #32       ; require a whole directory record
                    bne       compatshort@ ; malformed/truncated directory
                    lda       ,x        ; first name byte
                    beq       compatnext@ ; skip deleted/free records
                    cmpa      #'.+$80   ; skip exact dot entry
                    beq       compatnext@ ; continue enumeration
                    ldd       ,x        ; first two name bytes
                    cmpd      #'.*256+'.+$80 ; skip exact parent entry
                    beq       compatnext@ ; continue enumeration
                    ldy       3,s       ; original requested count
                    cmpy      #32       ; names-only result?
                    beq       compatok@ ; no metadata I/O required
                    lda       29,x      ; high byte of FD sector
                    ldb       #13       ; rbf metadata prefix length
                    tfr       d,y       ; packed sector high/count
                    ldu       30,x      ; low word of FD sector
                    leax      32,x      ; append metadata after name/ID
                    lda       ,s        ; directory path
                    ldb       #SS.FDInf ; legacy metadata lookup
                    os9       I$GetStt  ; obtain attributes, dates and size
                    bra       compatdone@ ; propagate metadata result
compatshort@        ldb       #E$Read   ; incomplete raw directory record
                    coma                ; set carry
                    bra       compatdone@ ; restore caller state
compatok@           clrb                ; successful filtered result
compatdone@         puls      a,x,y,u,pc ; restore pointers without changing CC
compaterror@        coma                ; comparison must not clear original error
compatret@          rts                 ; return
