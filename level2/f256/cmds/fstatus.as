********************************************************************
* fstatus - show f256 registers
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------


                    section   bss
freeblks            rmb       2
mapsiz              rmb       2
* pages per block (ie, MS byte of block size)
ppblk               rmb       1
* 0: print number with leading spaces. 1: print number with leading 0.
leadzero            rmb       1
* u0006,7,8 store a 24-bit block begin/end address.
u0006               rmb       1
u0007               rmb       1
u0008               rmb       1
bufstrt             rmb       2
bufcur              rmb       2
linebuf             rmb       80
bitmapinfo          rmb       12
clutdata            rmb       100
MAPADDR             rmb       2
PDATA               rmb       5
mmuvals             rmb       8
                    endsect

                    section   code
Hdr                 fcs       "F256 Registers"
                    fcs       " BM CLUT ADDRESS STATUS"
                    fcs       " -- ---- ------- --------"



__start             leax      linebuf,u           get line buffer address
                    stx       <bufstrt            and store it away
                    stx       <bufcur             current output position output buffer

                    lbsr      wrbuf               print CR
                    leay      <Hdr,pcr
                    lbsr      tobuf               1st line of header to output buffer
                    lbsr      wrbuf               ..print it
                    lbsr      tobuf               2nd line of header to output buffer
                    lbsr      wrbuf               ..print it
                    lbsr      tobuf               3rd line of header to output buffer
                    lbsr      wrbuf               ..print it
                    
* Map in CLUT 0 and Bitmap bank
                    pshs      u                   preserve u
                    ldx       #$C1                Block $C1 has clut data
                    ldb       #$01                need 1 block
                    os9       F$MapBlk            map it into process address space
                    lbcs      exiterr
                    stu       <MAPADDR
                    puls      u
                    ldb       #20                 Need first 20 CLUT entries
                    ldx       <MAPADDR            Set up x with address of MAPBLK
                    leax      $1000,x             Need an offset of $1000 for CLUT0
                    leay      clutdata,u          y = buffer for data
clutloop            lda       ,x+                 copy CLUT data to buffer
                    sta       ,y+
                    decb
                    bne       clutloop            loop until done
                    ldb       #20                 Want last 20 CLUT Entries
                    ldx       <MAPADDR
                    leax      $13EC,x             
clutloop2           lda       ,x+                 Copy clut data to buffer
                    sta       ,y+
                    decb
                    bne       clutloop2
* Read in Bitmap registers
                    pshs      u
                    ldu       <MAPADDR            u is address of mapped block
                    ldb       #$01                clearing 1 block
                    os9       F$ClrBlk            remove block from DAT Image
                    ldx       #$C0                need to map in BM registers block
                    ldb       #$01
                    os9       F$MapBlk            Map in Bitmap registers
                    lbcs      exiterr
                    stu       <MAPADDR
                    puls      u
                    ldx       <MAPADDR            Get new mapped block
                    leax      $1000,x             bitmap registers are $1000 offset
                    leay      bitmapinfo,u
                    ldd       ,x++
                    std       ,y++
                    ldd       ,x++
                    std       ,y++
                    leax      4,x                 increment by 4 to get to next set
                    ldd       ,x++
                    std       ,y++
                    ldd       ,x++
                    std       ,y++
                    leax      4,x                 increment by 4 to get to next set
                    ldd       ,x++
                    std       ,y++
                    ldd       ,x++
                    std       ,y++
                    pshs      u                   clear MapBlk from DAT Image
                    ldu       <MAPADDR            u is address of mapped block
                    ldb       #$01                 clearing 1 block
                    os9       F$ClrBlk            remove block from DAT Image
                    puls      u
* Output bitmap info
                    ldb       #0
                    leax      bitmapinfo,u
outloop             lda       #C$SPAC             Add Space to buffer
                    lbsr      bufchr
                    tfr       b,a                 OUTPUT BITMAP#
                    lbsr      bufval
                    lda       #C$SPAC             Add Space to buffer
                    lbsr      bufchr
                    lda       #C$SPAC             Add Space to buffer
                    lbsr      bufchr
                    lda       ,x                  Add CLUT# to buffer
                    anda      #%00000110
                    lsra
                    lbsr      bufval
                    lda       #C$SPAC             Add Space to buffer
                    lbsr      bufchr
                    lda       #C$SPAC             Add Space to buffer
                    lbsr      bufchr
                    lda       #C$SPAC             Add Space to buffer
                    lbsr      bufchr              
                    lda       3,x                 Add BM Address to Buffer
                    lbsr      bufval
                    lda       2,x
                    lbsr      bufval
                    lda       1,x
                    lbsr      bufval
                    lda       #C$SPAC             Add Space to buffer
                    lbsr      bufchr
                    lda       ,x
                    leay      disabletxt,pcr
                    anda      #$01
                    beq       contbm0
                    leay      enabletxt,pcr
contbm0             lbsr      tobuf
                    lbsr      wrbuf
                    leax      4,x
                    incb
                    cmpb      #3
                    bne       outloop
* Write out VICKY MCR and Layers                
                    leay      addrFFC0,pcr
                    lbsr      tobuf
                    lda       $FFC0
                    lbsr      bufval
                    lda       #C$SPAC
                    lbsr      bufchr
                    lda       $FFC0
gamma@              bita      #%01000000           test for gamma
                    beq       sprite@
                    leay      gamtxt,pcr
                    lbsr      tobuf
sprite@             bita      #%00100000           test for sprites
                    beq       tiles@
                    leay      spritetxt,pcr
                    lbsr      tobuf
tiles@              bita      #%00010000
                    beq       bitmap@
                    leay      tiletxt,pcr
                    lbsr      tobuf
bitmap@             bita      #%00001000
                    beq       graph@
                    leay      bmtxt,pcr
                    lbsr      tobuf
graph@              bita      #%00000100
                    beq       overlay@
                    leay      grftxt,pcr
                    lbsr      tobuf
overlay@            bita      #%00000010
                    beq       textmode@
                    leay      ovrlytxt,pcr
                    lbsr      tobuf
textmode@           bita      #%00000001
                    beq       writescrnset@
                    leay      txttxt,pcr
                    lbsr      tobuf
writescrnset@       lbsr      wrbuf
                    leay      addrFFC1,pcr
                    lbsr      tobuf
                    lda       $FFC1
                    lbsr      bufval
                    lda       #C$SPAC
                    lbsr      bufchr
                    lda       $FFC1
                    leay      fs0txt,pcr
                    bita      #%00100000
                    beq       fsbuf@
                    leay      4,y
fsbuf@              lbsr      tobuf
                    leay      fo0txt,pcr
                    bita      #%00010000
                    beq       fobuf@
                    leay      4,y
fobuf@              lbsr      tobuf
                    leay      ms0txt,pcr
                    bita      #%00001000
                    beq       msbuf@
                    leay      4,y
msbuf@              lbsr      tobuf
                    leay      sytxt,pcr
                    bita      #%00000100
                    beq       dybuf@
                    leay      3,y
dybuf@              lbsr      tobuf
                    leay      sxtxt,pcr
                    bita      #%00000010
                    beq       dxbuf@
                    leay      3,y
dxbuf@              lbsr      tobuf
                    leay      clk60txt,pcr
                    bita      #%00000001
                    beq       clkbuf@
                    leay      5,y
clkbuf@             lbsr      tobuf                 
                    lbsr      wrbuf
                    leay      addrFFC2,pcr
                    lbsr      tobuf
                    lda       $FFC2
                    lbsr      bufval
                    lda       #C$SPAC
                    lbsr      bufchr
                    lda       $FFC2
                    leay      oeqtxt,pcr
                    lbsr      tobuf
                    pshs      a
                    anda      #$50
                    lsra
                    lsra
                    leay      laytxt,pcr
                    leay      a,y
                    lbsr      tobuf
                    leay      zeqtxt,pcr
                    lbsr      tobuf
                    puls      a
                    anda      #$05
                    lsla
                    lsla
                    leay      laytxt,pcr
                    leay      a,y
                    lbsr      tobuf
                    lbsr      wrbuf
                    leay      addrFFC3,pcr
                    lbsr      tobuf
                    lda       $FFC3
                    lbsr      bufval
                    lda       #C$SPAC
                    lbsr      bufchr
                    leay      teqtxt,pcr
                    lbsr      tobuf
                    lda       $FFC3
                    anda      #$05
                    lsla
                    lsla
                    leay      laytxt,pcr
                    leay      a,y
                    lbsr      tobuf
                    lbsr      wrbuf


*write out CLUT data
                    leay      cluttxt,pcr
                    lbsr      tobuf
                    lbsr      wrbuf
                    leax      clutdata,u
                    ldb       #20
clutoutloop         lda       ,x+
                    lbsr      bufval
                    lda       #C$SPAC
                    lbsr      bufchr
                    decb
                    bne       clutoutloop
                    lbsr      wrbuf
                    ldb       #20
clutoutloop2        lda       ,x+
                    lbsr      bufval
                    lda       #C$SPAC
                    lbsr      bufchr
                    decb
                    bne       clutoutloop2
                    lbsr      wrbuf
* All of the entries have been printed. Print the trailer and totals.
*alldone             leay      >Ftr,pcr
*                    lbsr       tobuf               1st line of footer to output buffer
*                    lbsr       wrbuf               ..print it
*                    lbsr       tobuf               2nd line of footer to output buffer
* Successful exit
                    clrb
exiterr             os9       F$Exit

bitmap0txt          fcs       "Bitmap "
bitmap1txt          fcs       "Bitmap 1 ("
bitmap2txt          fcs       "Bitmap 2 ("
cluttxt             fcs       "CLUT0 FIRST AND LAST 20 VALUES: "
enabletxt           fcs       "Enabled"
disabletxt          fcs       "Disabled"
addresstxt          fcs       "Address: "
addrFFC0            fcs       "FFC0: "
addrFFC1            fcs       "FFC1: "
addrFFC2            fcs       "FFC2: "
addrFFC3            fcs       "FFC3: "
mmutxt              fcs       "MMU:  "
mmubtxt             fcs       "WINT: "
mmumem              fcs       " MMU_MEM_CTRL: "
editxt              fcs       "EDIT: "
gamtxt              fcs       "GAMMA "
spritetxt           fcs       "SPRITE "
tiletxt             fcs       "TILE "
bmtxt               fcs       "BM "
grftxt              fcs       "GRF "
ovrlytxt            fcs       "OVRLY "
txttxt              fcs       "TXT"
fs0txt              fcs       "FS0 "
fs1txt              fcs       "FS1 "
fo0txt              fcs       "FO0 "
fo1txt              fcs       "FO1 "
ms0txt              fcs       "MS0 "
ms1txt              fcs       "MS1 "
sytxt               fcs       "SY "
dytxt               fcs       "DY "
sxtxt               fcs       "SX "
dxtxt               fcs       "DX "
clk60txt            fcs       "CLK60"
clk70txt            fcs       "CLK70"
zeqtxt              fcs       "0="
oeqtxt              fcs       "1="
teqtxt              fcs       "2="
laytxt              fcs       "BM0 "
                    fcs       "BM1 "
                    fcs       "BM2 "
                    fcs       "XX  "
                    fcs       "TM0 "
                    fcs       "TM1 "

* convert value in D to ASCII hex (4 chars). Append to output buffer, then append "SPACE" to output buffer
buf4hex             pshs      b,a
                    bsr       bufval
                    tfr       b,a
                    bsr       bufval
                    lda       #C$SPAC             append a space
                    bsr       bufchr
                    puls      pc,b,a

* convert value in u0006,7,8 to ASCII hex (6 chars). Append to output buffer, then append "SPACE" to output buffer
buf6hex             lda       <u0006
                    bsr       bufval
                    lda       <u0007
                    bsr       bufval
                    lda       <u0008
                    bsr       bufval
                    lda       #C$SPAC             append a space
                    bra       bufchr

* convert value in A to ASCII hex (2 chars). Append to output buffer.
bufval              pshs      a                   preserve original value
                    lsra                          shift 4 bits
                    lsra                          to get high 4 bits
                    lsra
                    lsra
                    bsr       L014F               do high 4 bits then rts and do low 4
                    puls      a                   pull original value for low 4 bits
L014F               anda      #$0F                mask high bit and process low 4 bits

* FALL THROUGH
* Convert digit to ASCII with leading spaces, add to output buffer
* A is a 0-9 or A-F or $F0.
* Add $30 converts 0-9 to ASCII "0" - "9"), $F0 to ASCII "SPACE"
* leaves A-F >$3A so a further 7 is added so $3A->$41 etc. (ASCII "A" - "F")
L015C               adda      #$30
                    cmpa      #$3A
                    bcs       bufchr
                    adda      #$07

* FALL THROUGH
* Store A at next position in output buffer.
bufchr              pshs      x
                    ldx       <bufcur
                    sta       ,x+
                    stx       <bufcur
                    puls      pc,x

* Append CR to the output buffer then print the output buffer
wrbuf               pshs      y,x,a
                    lda       #C$CR
                    bsr       bufchr
                    ldx       <bufstrt            address of data to write
                    stx       <bufcur             reset output buffer pointer, ready for next line.
                    ldy       #80                 maximum # of bytes - otherwise, stop at CR
                    lda       #$01                to STDOUT
                    os9       I$WritLn
                    puls      pc,y,x,a

* Append string at Y to output buffer. String is terminated by MSB=1
tobuf               pshs      a
bufloop             lda       ,y
                    anda      #$7F
                    bsr       bufchr
                    tst       ,y+
                    bpl       bufloop
                    puls      a
                    rts

DecTbl              fdb       10000,1000,100,10,1
                    fcb       $FF

* value in ?? is a number of blocks. Convert to bytes by multiplying by the page size.
* Convert to ASCII decimal, append to output buffer, append "k" to output buffer
L0199               pshs      y,x,b,a
                    lda       <ppblk
                    pshs      a
                    lda       $01,s
                    lsr       ,s
                    lsr       ,s
                    bra       L01A9

L01A7               lslb
                    rola
L01A9               lsr       ,s
                    bne       L01A7
                    leas      1,s
                    leax      <DecTbl,pcr
                    ldy       #$2F20
L01B6               leay      >256,y
                    subd      ,x
                    bcc       L01B6
                    addd      ,x++
                    pshs      b,a
                    tfr       y,d
                    tst       ,x
                    bmi       L01DE
                    ldy       #$2F30
                    cmpd      #'0*256+C$SPAC
                    bne       L01D8
                    ldy       #$2F20
                    lda       #C$SPAC
L01D8               bsr       bufchr
                    puls      b,a
                    bra       L01B6

L01DE               lbsr       bufchr
                    lda       #'k
                    lbsr      bufchr
                    leas      $02,s
                    puls      pc,y,x,b,a

printmmu            leay      mmutxt,pcr
                    lbsr      tobuf
                    pshs      cc
                    orcc      #IntMasks
                    lda       MMU_MEM_CTRL
                    pshs      a
                    lda       #$11
                    sta       MMU_MEM_CTRL
                    ldx       #$FFA8
                    ldb       #8
pmloop              lda       ,x+
                    lbsr      bufval
                    lda       #C$SPAC
                    lbsr      bufchr
                    decb
                    bne       pmloop
                    leay      mmumem,pcr
                    lbsr      tobuf
                    lda       MMU_MEM_CTRL
                    lbsr      bufval
                    puls      a
                    sta       MMU_MEM_CTRL
                    puls      cc
                    lbsr      wrbuf
                    rts

pnoccmmu            leay      mmubtxt,pcr
                    lbsr      tobuf
                    ldx       #$FFA8
                    ldb       #8
pnoccloop           lda       ,x+
                    lbsr      bufval
                    lda       #C$SPAC
                    lbsr      bufchr
                    decb
                    bne       pnoccloop
                    leay      mmumem,pcr
                    lbsr      tobuf
                    lda       MMU_MEM_CTRL
                    lbsr      bufval
                    lbsr      wrbuf
                    rts

editmmu             leay      editxt,pcr
                    lbsr      tobuf
                    lda       #$11
                    sta       MMU_MEM_CTRL
                    ldx       #$FFA8
                    ldb       #8
editmmuloop         lda       ,x+
                    lbsr      bufval
                    lda       #C$SPAC
                    lbsr      bufchr
                    decb
                    bne       editmmuloop
                    leay      mmumem,pcr
                    lbsr      tobuf
                    lda       MMU_MEM_CTRL
                    lbsr      bufval
                    lbsr      wrbuf
                    lda       #$01
                    sta       MMU_MEM_CTRL
                    rts             

printu              lda       #85
                    lbsr      bufchr
                    tfr       u,d
                    lbsr      buf4hex
                    lbsr      wrbuf
                    rts

printit             ldb       #12
                    leax      bitmapinfo,u
testbmi             lda       ,x+
                    lbsr      bufval
                    decb
                    bne       testbmi
                    lbsr      wrbuf
                    rts

                    endsect