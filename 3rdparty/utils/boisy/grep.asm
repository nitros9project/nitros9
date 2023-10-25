***************************************************************************
* GREP - Pattern matching utility
*
* The usage for GREP is:
*
*        Grep <-c> "pattern" [file]    (in that order)
*
*        The -c option tells grep to search with case sensitivity.
*        The pattern must be enclosed in double quotes (").
*        If no file is specified, input is taken from StdIn
*
*        Use:  asm #16K grep.a o=grep
*        You may have to modify the "use" directive...
*
*        I got tired of waiting for someone to write this, so I took
*        the challenge.  I'm sure there are others who could use this.
*        As always, you're free to distribute this source as long as
*        long as this header is intact with the code.  Enjoy!
*
*
* By: Boisy G. Pitre
*     Southern Station, Box 8455
*     Hattiesburg, MS  39406-8455
*     Internet:  bgpitre@seabass.st.usm.edu
*

                    nam       grep
                    ttl       pattern matching utility

                    ifp1
                    use       defsfile
                    endc

                    mod       Size,Name,Prgrm+Objct,ReEnt+1,Start,Fin

Name                fcs       /Grep/
Ed                  fcb       $01

MaskByte            rmb       1                   Byte used for masking case
Path                rmb       1                   path of file (or StdIn)
StrSiz              rmb       1                   Size of pattern
Counter             rmb       1                   Counter for pattern size
ByteCmp             rmb       1                   Buffer to store masked byte
LineSiz             rmb       2                   Size of input line
SrchStr             rmb       80                  Line buffer
numflag             rmb       1                   print line numbers if set
linecnt             rmb       3                   up to 999999 lines
linestr             rmb       7                   buffer for 6-digit number+space
Line                rmb       250                 Line max is 250 chars
Stack               rmb       200
Params              rmb       200
Fin                 equ       .

HelpMsg             fcc       /Usage:  Grep <-c> <-n> "pattern" [file]/
                    fcb       C$CR
HelpLen             equ       *-HelpMsg

Start               clr       Path                Clear path (assume StdIn)
                    clr       numflag
                    clr       linecnt
                    clr       linecnt+1
                    clr       linecnt+2
                    lda       #%00100000          Assume masking
                    sta       MaskByte

Parse               lda       ,x+                 Get char off cmd line
                    cmpa      #C$SPAC             is it a space?
                    beq       Parse               yep, get next char
                    cmpa      #C$CR               is it a CR?
                    beq       Help                Yep, premature, so show help
                    cmpa      #'-                 is it a dash?
                    beq       Parse2              yeah, go to option handler
                    cmpa      #'"                 is it a quote?
                    beq       GetStr              yep, go to pattern handler
                    bra       Help                else wrong usage, show help

Parse2              lda       ,x+                 get char after dash
                    anda      #$DF                and mask it
                    cmpa      #'N                 is it an N for line numbers?
                    bne       Parse3              nope, try C
                    sta       numflag             set the line numbers flag
                    bra       Parse               and resume parsing
Parse3              cmpa      #'C                 is it a C for case sensitivity?
                    bne       Help                nope, bad option, show help
                    clr       MaskByte            else clear the mask byte
                    bra       Parse               and go back to parsing routine

GetStr              leay      SrchStr,u           point to pattern buffer
                    clr       StrSiz              and clear the size variable

Store               lda       ,x+                 get char
                    cmpa      #'"                 is it the ending quote?
                    beq       ChckFile            yep, see if a file was specified
                    cmpa      #C$CR               is it a CR?
                    beq       Help                Yep, in middle of quote!  show help
                    ora       MaskByte            else mask char
                    sta       ,y+                 and save it in buffer
                    inc       StrSiz              increment the size by one
                    bra       Store               and get the next char

EOF                 cmpb      #E$EOF              Is error an end-of-file?
                    bne       Error               nope, other error
                    bra       Done                else we're done

Help                leax      <HelpMsg,pcr        Point to help message
                    ldy       #HelpLen            load length
                    lda       #2                  to StdErr
                    os9       I$WritLn            and write
                    bcs       Error               exit if error

Done                clrb                          clear error register
Error               os9       F$Exit              and exit!

ChckFile            lda       ,x                  get char
                    cmpa      #C$CR               is it a CR?
                    beq       ReadIn              yep, we'll use StdIn
                    cmpa      #C$SPAC             is it a space?
                    bne       GetFile             nope, its a filename char
                    leax      1,x                 else increment X
                    bra       ChckFile            and get the next char

GetFile             lda       #READ.              Open for read
                    os9       I$Open
                    bcs       Error
                    sta       Path                and save the path

ReadIn              ldy       #250                max. read = 250 chars
                    leax      Line,u              point X to line buffer
                    lda       Path                load A with path number
                    os9       I$ReadLn            and get a line of chars
                    bcs       EOF                 if error, check for EOF
                    sty       LineSiz             save bytes read
* count lines in BCD, 6-digit version (3 bytes)
                    lda       linecnt+2
                    adda      #1
                    daa
                    sta       linecnt+2
                    bcc       Match
                    adca      linecnt+1
                    daa
                    sta       linecnt+1
                    bcc       Match
                    adca      linecnt
                    daa
                    sta       linecnt

Match               ldb       StrSiz              load B with pattern size
                    stb       Counter             store it in counter
                    leay      SrchStr,u           point Y to pattern

Loop                dec       LineSiz+1           decrement line size counter
                    beq       ReadIn              if at end, read in another line
                    lda       ,x+                 else load A with char at X (line)
                    ora       MaskByte            mask it
                    sta       ByteCmp             store it in comparison location
                    lda       ,y+                 load A with char at Y (pattern)
                    cmpa      ByteCmp             compare it with saved byte
                    beq       GetNext
                    bra       Match               else start from beginning of pattern
GetNext             dec       Counter             decrement counter
                    beq       doline              if at end, print the line (match!)
                    bra       Loop                else check next char

doline              tst       <numflag
                    bne       bcdtoasc

PrnLine             leax      Line,u              point to line buffer
                    ldy       #250                max. chars = 250
PrnLine2
                    lda       #1                  to StdOut
                    os9       I$WritLn            and write the line
                    bcs       Error               exit if error
                    bra       ReadIn              else get next line

bcdtoasc
                    leay      linestr,u
                    ldb       <linecnt
                    bsr       btod                convert all 6 digits
                    ldb       <linecnt+1
                    bsr       btod
                    ldb       <linecnt+2
                    bsr       btod
                    ldb       #C$SPAC
                    stb       ,y
                    leax      linestr+1,u         but print only last 5
                    ldy       #256
* to print 6 digits change previous 2 lines to leax linestr,u/ldy #257
                    bra       PrnLine2

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

                    emod
Size                equ       *
                    end

