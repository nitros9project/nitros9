***********************************************************************
* grep - Pattern matching utility
*
* Usage:  grep <-i> <-n> "pattern" [file]
* Options:
*    -i  case insensitive match
*    -n  show line number with match
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  01/01   1991/??/??  Boisy Gene Pitre
* Created.

maxlinelen          equ       254

                    section   bss
maskbyte            rmb       1                   byte used for masking case
path                rmb       1                   path of file (or standard input)
pattlen             rmb       1                   size of pattern
tmpval              rmb       1                   temporary byte
startpos            rmb       1                   the position in the line we start our search at
stoppos             rmb       1                   the position in the line we end our search at
counter             rmb       1                   counter for pattern size
linesiz             rmb       1                   size of input line
pattern             rmb       80                  line buffer
numflag             rmb       1                   print line numbers if set
linecnt             rmb       3                   up to 999999 lines
linestr             rmb       7                   buffer for 6-digit number+space
line                rmb       maxlinelen+1        line buffer
stack               rmb       200
params              rmb       200
                    endsect
                    
                    section   code

__start             clr       <path               clear path (assume standard input)
                    clr       <numflag
                    clr       <linecnt
                    clr       <linecnt+1
                    clr       <linecnt+2
                    clr       <maskbyte           assume no case masking

Parse               lda       ,x+                 get char off cmd line
                    cmpa      #C$SPAC             is it a space?
                    beq       Parse               yep, get next char
                    cmpa      #C$CR               is it a CR?
                    beq       Done                yep, premature, we're done
                    cmpa      #'-                 is it a dash?
                    beq       Parse2              yeah, go to option handler
                    cmpa      #'"                 is it a quote?
                    beq       GetStr              yep, go to pattern handler
                    bra       Done                else wrong usage, we're done

Parse2              lda       ,x+                 get char after dash
                    anda      #$DF                and mask it
                    cmpa      #'N                 is it an N for line numbers?
                    bne       Parse3              nope, try I
                    sta       <numflag            set the line numbers flag
                    bra       Parse               and resume parsing
Parse3              cmpa      #'I                 is it a I for case insensitivity?
                    bne       Done                nope, bad option, we're done
                    lda       #%00100000          assume masking
                    sta       <maskbyte           else clear the mask byte
                    bra       Parse               and go back to parsing routine

GetStr              leay      <pattern,u          point to pattern buffer
                    clr       <pattlen            and clear the size variable

Store               lda       ,x+                 get char
                    cmpa      #'"                 is it the ending quote?
                    beq       ChckFile            yep, see if a file was specified
                    cmpa      #C$CR               is it a CR?
                    beq       Done                yep, in middle of quote! we're done
                    ora       <maskbyte           else mask char
                    sta       ,y+                 and save it in buffer
                    inc       <pattlen            increment the size by one
                    bra       Store               and get the next char

EOF                 cmpb      #E$EOF              is error an end-of-file?
                    bne       Error               nope, other error
                    bra       Done                else we're done
                    
Done                clrb                          clear error register
Error               os9       F$Exit              and exit!

ChckFile            lda       ,x                  get char
                    cmpa      #C$CR               is it a CR?
                    beq       ReadIn              yep, we'll use StdIn
                    cmpa      #C$SPAC             is it a space?
                    bne       GetFile             nope, its a filename char
                    leax      1,x                 else increment X
                    bra       ChckFile            and get the next char

GetFile             lda       #READ.              open for read
                    os9       I$Open
                    bcs       Error
                    sta       <path               and save the path

ReadIn              ldy       #maxlinelen         maximum characters to read
                    leax      <line,u             point X to line buffer
                    lda       <path               load A with path number
                    lbsr      FGETS_NOCR
                    bcs       EOF                 if error, check for EOF
                    tfr       y,d                 transfer read size into D (we only care about B)
                    subb      <pattlen            subtract pattern length from length of line just read in
                    bmi       ReadIn              if negative, line is longer than pattern
                    stb       <stoppos            else B is the end position of our search
                    clr       <startpos           clear the starting pos
                    
* count lines in BCD, 6-digit version (3 bytes)
                    lda       <linecnt+2
                    inca
                    daa
                    sta       <linecnt+2
                    bcc       Match
                    adca      <linecnt+1
                    daa
                    sta       <linecnt+1
                    bcc       Match
                    adca      <linecnt
                    daa
                    sta       <linecnt

* Comparison
* X = the line to search
* startpos,u = position in line to start our search
* stoppos,u = position in line to stop our search
* pattlen,u = the length of our search pattern
Match               lda       <startpos           get the start position
                    cmpa      <stoppos            is it at or past the stop position?
                    bgt       ReadIn              if so, we're done
                    inc       <startpos           increment for next time
                    ldb       <pattlen            load B with pattern size
                    stb       <tmpval             save it as temporary
                    leay      <pattern,u          point Y to pattern
l@                  ldb       a,x                 else load A with char at X (line)
                    orb       <maskbyte           mask it
                    pshs      b                   save it on the stack
                    ldb       ,y+                 load A with char at Y (pattern)
                    cmpb      ,s+                 compare it with saved byte
                    bne       Match               not the same, start over
                    inca                          increment A as index into next char to compare
                    dec       <tmpval             decrement pattern length
                    bne       l@                  continue if we have more pattern to match
                    
doline              tst       <numflag
                    bne       bcdtoasc

PrnLine             leax      <line,u             point to line buffer
PrnLine2
                    lbsr      PUTS                print the string
                    lbsr      PUTCR               put a CR
                    lbcs      Error               exit if error
                    lbra      ReadIn              else get next line

bcdtoasc
                    leay      <linestr,u
                    ldb       <linecnt
                    bsr       btod                convert all 6 digits
                    ldb       <linecnt+1
                    bsr       btod
                    ldb       <linecnt+2
                    bsr       btod
                    clr       ,y
                    leax      <linestr+1,u        but print only last 5
* to print 6 digits change previous line to leax linestr,u
                    lbsr      PUTS                print the number
                    ldb       #':
                    lbsr      PUTC
                    bra       PrnLine

btod                pshs      b
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    bsr       btod2
                    puls      b
btod2               andb      #$0F
                    addb      #'0
                    stb       ,y+
                    rts
                    
                    endsection