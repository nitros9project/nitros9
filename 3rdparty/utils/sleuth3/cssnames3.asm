**
**********************************
**                              **
**  CSC OS/9 Name Changer c1982 **
**                              **
** Computer Systems Consultants **
** E. M. (Bud) Pass, Ph.D.      **
** 1454 Latta Lane NW           **
** Conyers, GA 30207            **
**                              **
**********************************
**
                    nam       CSC                 OS/9 Name Changer
**
vn                  equ       $03                 version number
os9lno              equ       $02                 os9 level number ($01=1.1 or $02=1.2/2.x)
coco                equ       $00                 ($00 for coco, $01 for other)

                    use       defsfile

**
                    mod       endmod,namemd,Prgrm+Objct,ReEnt+vn,start,endmem header
**
namemd              fcs       "Chgnam3"
**
                    fcc       "CSC OS/9 Name Changer c1982"
                    fcb       $0d
                    fcc       "All Rights Reserved by"
                    fcb       $0d
                    fcc       "E. M. (Bud) Pass, Ph.D."
                    fcb       $0d
                    fcc       "Computer Systems Consultants, Inc."
                    fcb       $0d
                    fcc       "1454 Latta Lane, Conyers, GA 30207"
                    fcb       $0d
                    fcc       "Telephone Number 404-483-1717/4570"
                    fcb       $0d
*
*
*******************************************
*
* name changer for OS/9
*
* performs a high speed character string
* replacement. word pairs to be swapped
* are read from a wordlist path. program
* is most useful for changes that must
* be done often, paths larger than memory,
* or when the number of pairs is large.
* the original paths are not destroyed.
*
*
* calling format:
*
*    chgnam oldpath newpath wordlist #nnK
*
* oldpath is the path to be processed.
*
* newpath is the destination path that
* will be created.
*
* wordlist contains substitution word list
* containing pairs of words separated by
* a period. alternately the word pair can be
* preceeded, separated, and followed by a
* non-alphanumeric delimiter. this allows
* swapping words that contain a period. the
* maximum total characters (not including
* delimiters) in a word pair is 32. this
* is set during assembly by wpsize equ xx.
* this number must be a power of two.
* a few wordlist examples follow:
*
* old.new      (replace old with new)
* apple.pear   (lower case accepted)
* aPpLe.pear   (note case must be exact}
* " i " me "   (spaces isolate letter)
* .zB406.fms.  (used by super sleuth)
* /1.23/abcd/  (period part of word)
* eliminate    (change word to nothing)
*
*
* #nnK is an optional parameter used to
* increase the OS/9 allocation of memory
* for table space.  by default, about 10k
* is allocated.  the following message:
*
*   table overflow!
*
* is output to the terminal if insufficient
* space is allocated for the wordlist path.
*
*
*******************************************
*
* equates
*
wpsize              equ       $20                 change with caution! (power of 2)
mask                equ       $100-wpsize
tabsiz              equ       $2000               table size default
**
iobfc               equ       0                   function code
iobba               equ       1                   buffer address
iobbl               equ       3                   buffer length
iobfd               equ       5                   path descriptor
iobca               equ       7                   next char address
iobcc               equ       9                   char counter
iobfn               equ       16                  path name
ioblen              equ       64                  length of i/o block
fnmlen              equ       ioblen-iobfn        length of path name
buflen              equ       256                 length of i/o buffer
read                equ       1                   read block raw
rdln                equ       2                   read block edited
write               equ       3                   write block raw
wrln                equ       4                   write block edited
**
                    org       $0000
*
* temps
*
top                 rmb       2                   lowest address entry
topmov              rmb       2                   moving top
middle              rmb       2                   current center
botmov              rmb       2                   moving bottom
bottom              rmb       2                   next empty location
txtend              rmb       2                   end of source text
ramend              rmb       2                   end of text buffer
temp1               rmb       2
temp2               rmb       2
donflg              rmb       1                   path done
dupflg              rmb       1                   duplicate word
delim               rmb       1                   word pair delimiter
dlmflg              rmb       1                   found delimiter
debugr              rmb       1                   debugging flag
count               rmb       1                   character count
wrdbuf              rmb       wpsize              save word pair
wrdend              rmb       2                   word end - for overflow bytes
**
                    rmb       (((.+$00ff)/256)*256)-. round to 256 for buffers
**
tebuff              rmb       buflen              err output buffer
inbuff              rmb       buflen              input buffer
otbuff              rmb       buflen              output buffer
wlbuff              rmb       buflen              word list buffer
**
teblok              rmb       ioblen              std err output iob
inblok              rmb       ioblen              input iob
otblok              rmb       ioblen              output iob
wlblok              rmb       ioblen              word list iob
**
endprg              rmb       (tabsiz+$0100)      table space
**
endmem              equ       .
*
*******************************************
*
* executive program calls subroutines
*
start               equ       *                   starting address
*
execut              bsr       init                set up
                    bsr       parse               read command line
                    lbsr      dummie              insert dummy entries
                    leax      redmsg,pcr
                    lbsr      xstrng
                    lbsr      rdpair              read word list path
                    tst       dupflg,u
                    bne       exit                identical pairs?
newbuf              leax      txtmsg,pcr
                    lbsr      xstrng
                    lbsr      rdtext              read first text buffer
                    leax      promsg,pcr
                    lbsr      xstrng
                    lbsr      process             process output path
                    tst       donflg,u            source path complete?
                    beq       newbuf              read another buffer
                    leax      finmsg,pcr          finished!
                    bra       pntmsg
helpim              leax      hlpmsg,pcr          help
pntmsg              lbsr      xstrng              print message
exit                lbsr      closef
exitrm              ldd       #$0000
                    os9       F$Exit
*
*******************************************
*
* initial set up
*
init                pshs      x
                    leax      top,u
                    ldy       #(endprg-top+tabsiz)
init1               clr       ,x+
                    leay      -$01,y
                    bne       init1
                    puls      x
                    tfr       x,d
                    subd      #$0200
                    clrb                          even bounds for testing
                    std       ramend,u
                    leay      endprg,u
                    tfr       y,d
                    addd      #$01ff
                    clrb                          even bounds for testing
                    std       top,u               start of word pairs
                    rts
*
*******************************************
*
* parse command line for paths to open
*
*
parse               tfr       x,y                 set up iob's
                    lda       #read
                    sta       inblok+iobfc,u
                    sta       wlblok+iobfc,u
                    lda       #wrln
                    sta       teblok+iobfc,u
                    lda       #write
                    sta       otblok+iobfc,u
                    ldd       #$0002
                    std       teblok+iobfd,u
                    ldd       #buflen
                    std       inblok+iobbl,u
                    std       teblok+iobbl,u
                    std       teblok+iobcc,u
                    std       otblok+iobbl,u
                    std       otblok+iobcc,u
                    std       wlblok+iobbl,u
                    leax      inbuff,u
                    stx       inblok+iobba,u
                    stx       inblok+iobca,u
                    leax      tebuff,u
                    stx       teblok+iobba,u
                    stx       teblok+iobca,u
                    leax      otbuff,u
                    stx       otblok+iobba,u
                    stx       otblok+iobca,u
                    leax      wlbuff,u
                    stx       wlblok+iobba,u
                    stx       wlblok+iobca,u
                    lbsr      xcrlf
                    tfr       y,x
                    lda       ,x                  help wanted?
                    cmpa      #$20
                    lblo      helpim
parse1              lda       ,y+                 look for ?
                    cmpa      #$20
                    blo       parse2
                    cmpa      #$3f                ?
                    bne       parse1
                    sta       debugr,u            set debugging switch
parse2              ldd       #(READ.*256)        open input oldpath
                    os9       I$Open
                    lbcs      helpim
                    clrb
                    exg       a,b
                    std       inblok+iobfd,u
                    ldd       #(WRITE.*256)+(READ.+WRITE.+PREAD.) open output newpath
                    os9       I$Create
                    lbcs      helpim
                    clrb
                    exg       a,b
                    std       otblok+iobfd,u
                    ldd       #(READ.*256)        open input wordlist
                    os9       I$Open
                    lbcs      helpim
                    clrb
                    exg       a,b
                    std       wlblok+iobfd,u
                    rts
*
* preset dummy word list into ram
*
dummie              ldx       top,u
                    lda       #$20                space
                    ldb       #wpsize
filspc              sta       ,x+                 dummy start
                    decb
                    bne       filspc
                    lda       #$7f                delete
                    ldb       #wpsize
fillz               sta       ,x+                 dummy end
                    decb
                    bne       fillz
                    stx       bottom,u
                    rts
*
* read word pair and format
*
rdpair              clr       delim,u             no delimiter defined
                    clr       dlmflg,u            no delimiter found
                    leay      wrdbuf,u
                    ldb       #wpsize             max size
                    stb       count,u
rpair               pshs      x                   word list
                    leax      wlblok,u
                    lbsr      gnc                 read char
                    puls      x
                    bvs       redeof
                    bcc       notdon
error3              lda       #$02                error on wordlist path
                    leax      errlrz,pcr
                    ldy       #errlrl
                    os9       I$WritLn
                    lbra      exit
redeof              rts                           all pairs read
*
notdon              tst       delim,u             set yet?
                    bne       delset
                    cmpa      #$0d                null entry?
                    beq       rdpair              ignore empty lines
                    ldb       #$2e                . default
                    stb       delim,u             set to period
                    lbsr      class               alphanumeric?
                    bcc       delset              char still in a
                    sta       delim,u             set delimiter
                    bra       rpair
*
delset              cmpa      #$0d                end of pair?
                    beq       wrdone
                    cmpa      delim,u
                    bne       notdlm              not delimiter?
                    inc       dlmflg,u
                    bra       rpair               get another char
*
notdlm              tst       dlmflg,u            last char=delimiter?
                    beq       nopar
                    ora       #$80                set parity bit
nopar               sta       ,y+
                    clr       dlmflg,u
                    dec       count,u
                    bpl       rpair               get another
                    pshs      x
                    leax      sizmsg,pcr          entry too long
                    lbsr      xstrng
                    puls      x
long                pshs      x
                    leax      wlblok,u
                    lbsr      gnc                 finish word
                    puls      x
                    bcs       error3
                    bvs       redeof
                    cmpa      #$0d                end of line?
                    bne       long
                    ldb       #$80
                    stb       ,y                  terminate
                    bra       badwrd              print bad entry
*
wrdone              clr       ,y+                 mark end of pair
                    dec       count,u             fill out buffer
                    bpl       wrdone
*
* find hole for new word
*
                    ldx       top,u               reset to full size
                    stx       topmov,u
                    ldx       bottom,u
                    stx       botmov,u
fhole               ldd       topmov,u
fhole2              addd      botmov,u
                    rora                          divide by two
                    rorb
                    andb      #mask               round down
                    std       middle,u
                    addd      #wpsize             next word
                    std       temp1,u
                    addd      #wpsize
                    std       temp2,u             next after that
                    ldx       middle,u
                    bsr       compar              wrdbuf vs middle
                    bne       notdup
dbl                 pshs      x                   wrd = string
                    leax      double,pcr
                    lbsr      xstrng
badwrd              inc       dupflg,u
                    leax      wrdbuf,u
pntdup              lda       ,x+
                    bmi       pntdu2
                    pshs      x                   print duplicate
                    leax      teblok,u
                    lbsr      pnc
                    puls      x
                    bra       pntdup
pntdu2              puls      x
                    lbra      rdpair
*
notdup              bcs       trynxt
                    ldx       middle,u            wrd < string
                    stx       botmov,u
                    bra       fhole
*
higher              ldd       middle,u
                    std       topmov,u
                    bra       fhole2
*
trynxt              ldx       temp1,u             next after middle
                    bsr       compar              wrdbuf vs temp1
                    beq       dbl
                    bcs       higher              wrd > temp1
                    ldy       bottom,u            make hole in ram
                    leay      wpsize,y
                    sty       bottom,u            new ram end
                    cmpy      ramend,u            word list too long?
                    blo       fits
                    leax      overms,pcr
                    lbsr      xstrng              print error
                    lbra      exit                close paths
*
fits                leay      wpsize,y            end of space
movdwn              ldd       -(wpsize+2),y
                    std       ,--y                decrement+store
                    cmpy      temp2,u             done?
                    bne       movdwn
                    pshs      x
                    leax      wrdend,u
                    ldb       #wpsize
movwrd              lda       ,-x                 read wrd backwards
                    sta       ,-y                 store in hole
                    decb
                    bne       movwrd
                    puls      x
rdpar2              lbra      rdpair
*
* compare string in x to wrdbuf
*
* enter --- x=string
*  exit --- equal set wrdbuf same
*           carry set wrdbuf larger
*           carry clr wrdbuf smaller
*
compar              leay      wrdbuf,u
compa2              lda       ,x+                 get string char
                    bmi       stdone              string parity
                    cmpa      ,y+                 get wrdbuf char
                    beq       compa2              match so far
                    blt       wlarge              carry set
                    andcc     #$fe                wrd smaller
                    rts
*
stdone              ldb       ,y+                 both parity?
                    bpl       wlarge
                    clrb                          set equal
wlarge              orcc      #$01
                    rts
*
* read text path into ram
*
rdtext              ldy       bottom,u            start of text
rdloop              pshs      x
                    leax      inblok,u
                    lbsr      gnc                 read char
                    puls      x
                    bcc       rdlook
errori              lda       #$02                error on input path
                    leax      errirz,pcr
                    ldy       #errirl
                    os9       I$WritLn
                    lbra      exit
rdlook              bvc       noerr
                    inc       donflg,u            source path complete
                    sty       txtend,u
                    rts
*
noerr               sta       ,y+                 save in buffer
                    cmpy      ramend,u
                    blo       rdloop              read some more
                    sty       txtend,u            source path still open
retrn2              rts
*
* process text
*
process             ldx       bottom,u            start of source
matlop              stx       middle,u            destroy old middle
                    stx       temp1,u             save original position
                    cmpx      txtend,u
                    beq       retrn2              end of buffer
                    ldy       top,u               reset to full size
                    sty       topmov,u
                    ldy       bottom,u
                    sty       botmov,u
fmatch              ldx       temp1,u             start of text word
                    ldd       topmov,u
                    addd      botmov,u
                    rora                          divide by two
                    rorb
                    andb      #mask               round down
                    cmpd      middle,u
                    beq       notfnd              same middle twice
                    std       middle,u
                    ldy       middle,u
                    ldb       #wpsize             count chars
                    stb       count,u
matmor              dec       count,u
                    bmi       matlop              change to nothing
                    lda       ,y+                 get word pair
                    bmi       match               found match
                    cmpa      ,x+
                    beq       matmor              equal so far?
                    blo       down
                    ldy       middle,u
                    sty       botmov,u            move up
                    bra       fmatch
*
down                ldy       middle,u
                    sty       topmov,u
                    bra       fmatch
*
* match not found
*
notfnd              ldx       temp1,u             restore original
                    lda       ,x+
                    pshs      x
                    leax      otblok,u            write original char
                    lbsr      pnc
                    puls      x
                    bcc       matlop
error2              lda       #$02                error on output path
                    leax      errorz,pcr
                    ldy       #errorl
                    os9       I$WritLn
                    lbra      exit
*
* match was found
*
match               anda      #$7f                strip delim
                    beq       matlop
outlop              pshs      x                   write new char
                    leax      otblok,u
                    lbsr      pnc
                    puls      x
                    bcs       error2
                    lda       ,y+                 get replacement
                    bne       outlop
                    lbra      matlop
*
* close all paths
*
closef              ldy       #$0000              close all paths
                    leax      teblok,u            std error output
                    lbsr      fob
closes              ldd       inblok+iobfd,u      source
                    beq       closei
                    sty       inblok+iobfd,u
                    exg       b,a
                    os9       I$Close
                    bcc       closei
                    lda       #$02
                    leax      errirz,pcr
                    ldy       #errirl
                    os9       I$WritLn
closei              leax      otblok,u            destination
                    ldd       iobfd,x
                    beq       closed
                    lbsr      fob
                    bcc       closed
                    lda       #$02
                    leax      errorz,pcr
                    ldy       #errorl
                    os9       I$WritLn
closed              ldd       otblok+iobfd,u
                    beq       closeo
                    sty       otblok+iobfd,u
                    exg       a,b
                    os9       I$Close
                    bcc       closeo
                    lda       #$02
                    leax      errorz,pcr
                    ldy       #errorl
                    os9       I$WritLn
closeo              ldd       wlblok+iobfd,u      word list
                    beq       closew
                    sty       wlblok+iobfd,u
                    exg       a,b
                    os9       I$Close
                    bcc       closew
                    lda       #$02
                    leax      errlrz,pcr
                    ldy       #errlrl
                    os9       I$WritLn
closew              rts
*
* classify character - c clear for alphanumeric
*
class               cmpa      #$30
                    blo       classs
                    cmpa      #$39
                    bls       classc
                    cmpa      #$41
                    blo       classs
                    cmpa      #$5a
                    bls       classc
                    cmpa      #$61
                    blo       classs
                    cmpa      #$7a
                    bls       classc
classs              orcc      #$01                not alphanumeric
                    rts
classc              andcc     #$fe                alphanumeric
                    rts
*
* i/o routines
*
xpdaa               bsr       xoute               print to $04 from a then x
xpdat               lda       ,x+                 print to $04 from x
                    cmpa      #$04
                    bne       xpdaa
                    rts
xcrlf               lda       #$0d                crlf
xoute               pshs      d,x                 print char in a
                    leax      teblok,u
                    bsr       pnc
                    cmpa      #$0d
                    bne       xoutx
                    lbsr      fob
xoutx               puls      d,x,pc
xstrng              pshs      x,y                 output crlf and string
                    bsr       xcrlf
                    ldx       ,s
                    bsr       xpdat
                    leax      teblok,u
                    lbsr      fob
                    puls      x,y,pc
**
**
*
* blocked i/o routines
*
* gnc - get next char
*
* entry - x=i/o block pointer
*
* exit - cs if error, d=error
*        cc if no error
*        vs if eof
*        if cc and vc, a=char
*
* preserves all other registers
*
gnc                 pshs      b,x,y
                    ldd       iobcc,x             get remaining char count
                    bne       gnc1                if chars left
gnc0                lda       iobfd+1,x           a=path descriptor
                    ldy       iobbl,x             buffer length
                    ldb       iobfc,x             function code
                    pshs      x
                    ldx       iobba,x             buffer address
                    cmpb      #read
                    beq       gncrw
                    os9       I$ReadLn            reload buffer edited
                    bra       gncrd
gncrw               os9       I$Read              reload buffer raw
gncrd               puls      x
                    bcs       gnc4                if error
                    sty       iobcc,x             save char count
                    beq       gnc3                if eof
                    ldd       iobba,x             reset char pointer
                    std       iobca,x
                    ldd       iobcc,x             d=char count
gnc1                subd      #$0001              count chars
                    std       iobcc,x
gnc2                ldy       iobca,x             get char
                    lda       ,y+
                    sty       iobca,x             update char pointer
                    tst       debugr,u            check debugging switch
                    beq       gnc2d
                    leax      teblok,u            output a character
                    bsr       pnc
                    cmpa      #$0d
                    bne       gnc2d
                    leax      teblok,u
                    bsr       fob
gnc2d               clrb                          cc, vc
                    puls      b,x,y,pc
gnc3                orcc      #$02                vs for eof
                    puls      b,x,y,pc
gnc4                cmpb      #E$EOF              check error
                    beq       gnc3                for eof
                    orcc      #$01                cs
                    leas      $01,s               remove b
                    puls      x,y,pc              cs, d=error
*
* pnc - put next character
*
* entry - a=char,x=i/o block pointer
*
* exit - cc if no error, a=char
*        cs if error, d=error
*
pnc                 pshs      a,b,y
                    ldd       iobcc,x             get remaining count
                    bne       pnc1                if room
                    lda       iobfd+1,x           a=path descriptor
                    ldb       iobfc,x             function code
                    ldy       iobbl,x             buffer length
                    pshs      x
                    ldx       iobba,x             buffer address
                    cmpb      #write
                    beq       pncrw
                    os9       I$WritLn            dump buffer edited
                    bra       pncwt
pncrw               os9       I$Write             dump buffer raw
pncwt               puls      x
                    bcs       pnc3                if error
pnc0                ldd       iobba,x             update char pointer
                    std       iobca,x
                    ldd       iobbl,x             d=new size
pnc1                subd      #$0001              count chars
                    std       iobcc,x             update count
                    ldy       iobca,x             store char
                    puls      a
                    sta       ,y+
                    sty       iobca,x             update char pointer
pnc2                puls      b,y,pc
pnc3                leas      2,s                 remove a and b
                    clra
                    orcc      #$01                cs, error
                    puls      y,pc                cs, d=error
*
* fob - flush output buffer
*
* entry - x=i/o block pointer
*
* exit - cs if error
*
fob                 pshs      d,y
                    ldd       iobbl,x             get buffer size
                    subd      iobcc,x             determine char count
                    beq       fob1                if empty
                    tfr       d,y                 set char count to write
                    lda       iobfd+1,x           a=path descriptor
                    ldb       iobfc,x             function code
                    pshs      x
                    ldx       iobba,x             buffer address
                    cmpb      #write
                    beq       fobrw
                    os9       I$WritLn            dump buffer edited
                    bra       fobwt
fobrw               os9       I$Write             dump buffer raw
fobwt               puls      x
                    bcs       fob2                if error
fob0                ldd       iobba,x             update char pointer
                    std       iobca,x
fob1                ldd       iobbl,x             restore buffer size
                    std       iobcc,x             reset avail counter
                    clra                          clear errors
                    puls      d,y,pc              return
fob2                leas      2,s                 remove a and b
                    clra
                    orcc      #$01                cs, error
                    puls      y,pc                cs, d=error
*
**
errirz              fcc       "error on input path"
                    fcb       $07,$0d
errirl              equ       *-errirz
errlrz              fcc       "error on work list path"
                    fcb       $07,$0d
errlrl              equ       *-errlrz
errorz              fcc       "error on output path"
                    fcb       $07,$0d
errorl              equ       *-errorz
**
*
* messages
*
hlpmsg              fcc       'order of parameters is: '
                    fcc       'oldpath newpath wordlist #nnK'
                    fcb       $07,$0d,$04
redmsg              fcc       'reading word list'
                    fcb       $07,$04
sizmsg              fcc       'word pair is too long:  '
                    fcb       $07,$04
overms              fcc       'table overflow!'
                    fcb       $07,$04
txtmsg              fcc       'reading text path'
                    fcb       $07,$04
promsg              fcc       'processing output path'
                    fcb       $07,$04
double              fcc       'duplicate word in list: '
                    fcb       $07,$04
finmsg              fcc       'finished!'
                    fcb       $07,$04
**
                    emod
endmod              equ       *
                    end

