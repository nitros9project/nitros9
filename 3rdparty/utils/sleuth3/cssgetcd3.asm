
***************************************
**
getin               pshs      y                   get next instr
                    ldx       #$ffff
                    stx       maddr,u
                    lbsr      getty               get type
                    clra                          clear instr
                    cmpb      #$4b                chk ign
                    lbeq      getjk
                    cmpb      #$52                chk rmb
                    lbeq      getjk
                    ldx       maddr,u             chk for m/z
                    tst       disif,u             chk source
                    bne       getdk
                    cmpx      #$ffff              from memory
                    beq       getmz
                    lda       $05,x               get desired data
                    ldb       ,x                  chk type
                    cmpb      #$5a                for z
                    lbeq      getjk
getmz               ldd       saddr,u             compute addr
                    addd      oaddr,u             offset
                    lbra      getid
getdk               cmpx      #$ffff              from disk
                    lbeq      getjk
                    lda       $05,x               get desired locn/data
                    ldb       ,x                  chk type
                    cmpb      #$5a
                    lbeq      getjk               skip if z
                    ldd       saddr,u             data addr
                    subd      $01,x               start addr
                    addd      $06,x               add extent byte address
                    tfr       a,b
                    lda       $05,x
                    adca      #$00
                    andb      #$fe                truncate to 512 bytes
                    cmpd      inlrec,u            chk curr locn
                    beq       getsl
getss               std       inlrec,u            set curr locn
                    pshs      y,u
                    exg       a,b
                    tfr       d,x
                    clrb                          byte addr=0
                    tfr       d,y
                    tfr       x,d
                    clra
                    tfr       d,x
                    lda       inblok+iobfd+1,u    file desc
                    tfr       y,u
                    os9       I$Seek              seek
                    puls      u,y                 reset stack
                    bcc       getts
geter               lda       #$02                return error
                    leax      errirz,pcr
                    ldy       #errirl
                    os9       I$WritLn
                    lbsr      ende3               close files
                    lbsr      stopin              stop input
                    clr       escswt,u
                    lbra      askin               abort
getts               ldx       inblok+iobba,u      read the block
                    ldy       #buflen
                    lda       inblok+iobfd+1,u
                    os9       I$Read
                    bcs       geter               error
                    cmpy      #$0000
                    bcs       geter               eof
                    ldx       maddr,u             restore map ptr
getsl               ldd       saddr,u             data addr
                    subd      $01,x               start addr
                    addd      $06,x               disk byte address
                    anda      #$01                mask to 512 bytes
                    leax      inbuff,u            input buffer addr
                    pshs      x
                    addd      ,s++
getid               std       maddr,u             disk and memory
                    lda       [maddr,u]
getjk               ldx       saddr,u             update pointers
                    stx       daddr,u
                    leax      $01,x
                    stx       saddr,u
                    sta       instr,u
                    inc       fllth,u             update length
                    tst       flisw,u             save instrs?
                    beq       getxx
                    ldx       iaddr,u
                    leax      $01,x
                    sta       ,x
                    stx       iaddr,u
getxx               puls      y,pc
**
getty               pshs      y                   return memory type
                    ldx       types,u
                    lda       defalt,u            default type
                    sta       insty,u
                    ldd       saddr,u
getnx               cmpx      typee,u
                    beq       gettx
                    cmpd      $01,x
                    beq       getn4
getn1               bls       getix
getn2               cmpd      $03,x
                    beq       getn4
getn3               bhi       getix
getn4               pshs      b                   have table hit
                    ldb       ,x
                    cmpb      #$4d                chk m
                    bne       getn5
                    stx       maddr,u             save table location
                    clrb                          and set type
                    bra       getn9
getn5               cmpb      #$5a                chk z
                    bne       getn9
                    stx       maddr,u             save table location
                    ldb       insty,u             chk type
                    cmpb      #$4b
                    bne       getn9
                    clrb
getn9               stb       insty,u
                    puls      b
getix               leax      $08,x
                    bra       getnx
gettx               ldb       insty,u
                    puls      y,pc
