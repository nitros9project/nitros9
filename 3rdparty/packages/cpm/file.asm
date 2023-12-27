

_open               pshs      a,b,x,y
                    ldd       argc,u
                    cmpd      #0
                    beq       @empty
                    ldx       args,u              ; file name
                    lda       #READ.
                    os9       I$Open
                    bcs       @error
                    sta       <filepath
                    clra
                    puls      a,b,x,y,pc
@error              lbsr      _abort
@empty              comb
                    puls      a,b,x,y,pc





_close              pshs      a,b,x,y
                    lda       <filepath
                    beq       @end
                    os9       I$Close
                    clr       <filepath
@end                puls      a,b,x,y,pc





_read               pshs      a,b,x,y
                    ldx       #$100               ; store on 0x100 of TPA
@read               lda       <filepath
                    ldb       #SS.EOF
                    os9       I$GetStt
                    bcs       @eof
                    ldy       #$100
                    os9       I$Read
                    lbcs      @error
                    cmpy      #0                  ; read until EOF
                    beq       @eof
                    tfr       y,d
                    leax      d,x
                    cmpx      <himem              ; check memory overflow
                    bcc       @outmem
                    bra       @read
@eof                puls      a,b,x,y,pc
@outmem             ldb       #E$MemFul
@error              lbsr      _abort
                    puls      a,b,x,y,pc

_clrfcb             exg       x,y
                    clr       ,x+
                    ldd       #$2020
                    std       ,x++
                    std       ,x++
                    std       ,x++
                    std       ,x++
                    std       ,x++
                    sta       ,x+
                    ldd       #0
                    std       ,x++
                    std       ,x++
                    exg       x,y
                    rts
