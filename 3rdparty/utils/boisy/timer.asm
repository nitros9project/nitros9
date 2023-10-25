************************************************************
* Timer - Benchmarks a program with accuracy to one second
*
* By: Boisy G. Pitre
*     Southern Station, Box 8455
*     Hattiesburg, MS  39406-8455
*     Internet:  bgpitre@seabass.st.usm.edu
*
* Usage:  Timer <program> [params]
*
* Timer is a benchmark utility that is used to rate the speed of an
* OS-9 program.
*

                    nam       Timer
                    ttl       Benchmark utility

                    ifp1
                    use       defsfile
                    endc

                    mod       Size,Name,Prgrm+Objct,ReEnt+1,Start,Fin

Name                fcs       /Timer/
Ed                  fcb       $02

Delim               rmb       1
TempX               rmb       2
Count               rmb       1
ProgName            rmb       70
ParmBuff            rmb       200
OldTime             rmb       6
NewTime             rmb       6
Digit               rmb       2
Stack               rmb       200
Parms               rmb       200
Fin                 equ       .

HelpMsg             fcc       /Usage:  Timer <progname> [params]/
SpCR                fcb       C$SPAC,C$LF,C$CR
HelpLen             equ       *-HelpMsg


Header              fdb       C$LF,C$CR
                    fcc       /Timer Statistics:/
                    fdb       C$LF,C$CR,C$LF,C$CR
                    fcc       /Command line:  /
Header1             fcc       /Date:  /
Header2             fcc       /Start Time:  /
Header3             fcc       /Stop  Time:  /
Colon               fcc       /:/
Slash               fcc       "/"

Start               decb                          Check for params
                    lbeq      Help                if none, show help
                    lda       #C$CR
                    leay      ParmBuff,u          Else put a CR in param buffer
                    sta       ,y

                    leay      ProgName,u          and put progname in progname buffer
GetName             lda       ,x+
                    sta       ,y+
                    cmpa      #C$SPAC             any space after name?
                    beq       PlaceCR             Yep, assume params are on line
                    cmpa      #C$CR               Is next char a CR?
                    bne       GetName             nope, not finished getting name
                    bra       GetTime             else assume no params...

PlaceCR             lda       #C$CR               Put CR behind progname,
                    sta       -1,y

SkipSpac            lda       ,x+                 skip leading spaces
                    cmpa      #C$SPAC
                    beq       SkipSpac
                    leax      -1,x

SaveParm            leay      ParmBuff,u          and store params in param buffer
Loop                lda       ,x+
                    sta       ,y+
                    cmpa      #C$CR               Is char a CR?
                    beq       GetTime             Yep, we're finished parsing
                    bra       Loop                else get next char

GetTime             lda       #Prgrm+Objct        We'll take care of some F$FORK
                    ldb       #8                  params to minimize the time between
                    ldy       #200                grabbing the time and forking.
                    leax      OldTime,u
                    os9       F$Time              Now we get the time
                    lbcs      Error

                    leax      ProgName,u          and point to the program name
                    pshs      u                   save the u pointer value
                    leau      ParmBuff,u          and point u to the param buffer
                    os9       F$Fork              Fork the program
                    bcs       Error
                    os9       F$Wait              and wait for it to complete

                    puls      u                   get the u pointer value
                    leax      NewTime,u           and get the new time
                    os9       F$Time
                    bcs       Error


* Print the Header and command line

                    leax      Header,pcr
                    ldy       #38
                    lda       #2
                    os9       I$Write
                    bcs       Error

                    leax      ProgName,u
                    ldb       #$0d
                    bsr       PrnNam

                    leax      SpCR,pcr
                    ldy       #1
                    lda       #2
                    os9       I$Write
                    bcs       Error

                    leax      ParmBuff,u
                    ldy       #200
                    lda       #2
                    os9       I$WritLn
                    bcs       Error
                    bra       DateShow

**********************************************************************
* PrnNam - Prints a string character-by-character until it encounters
* a specific character in B
*
* Entry: X - Address of string
*        B - Byte character to halt at
*
* Exit:  None
*

PrnNam              lda       #2
                    ldy       #1
Prn2                cmpb      ,x                  compare B to char
                    bne       Prn3                if not equal, print...
                    rts                           else return
Prn3                os9       I$Write             Write out character
                    bcs       Error
                    leax      1,x
                    bra       Prn2


* Print the date

DateShow            leax      Header1,pcr
                    ldy       #7
                    os9       I$Write
                    bcs       Error
                    leax      Slash,pcr
                    lda       ,x
                    sta       Delim,u
                    leax      OldTime,u           Set X to old time packet+3
                    ldb       #2
                    bsr       ShowTime            and sub to showtime
                    bra       OldShow

* We're done!

Done                clrb
Error               os9       F$Exit

* Show the Old Time

OldShow             lda       #2
                    leax      Header2,pcr         Write the old time message
                    ldy       #13
                    os9       I$Write
                    bcs       Error
                    leax      Colon,pcr
                    lda       ,x
                    sta       Delim,u
                    leax      OldTime+3,u         Set X to old time packet+3
                    ldb       #2
                    bsr       ShowTime            and sub to showtime

NewShow             leax      Header3,pcr         Write the new time message
                    ldy       #13
                    os9       I$Write
                    bcs       Error
                    leax      NewTime+3,u         Set X to new time packet+3
                    ldb       #2
                    bsr       ShowTime            and sub to showtime
                    bra       Done

* Help routine

Help                leax      HelpMsg,pcr         Point to the help message
                    ldy       #HelpLen            and load the length
                    lda       #2                  we'll write to StdErr
                    os9       I$Write
                    bcs       Error
                    bra       Done                and leave!

*******************************************************
* ShowTime routine - Prints date/time format
*
* Entry: X - Address of packet
*        B - (Number of bytes to convert)-1
*
* Exit:  None
*

ShowTime            stb       Count,u             store count in counter address
ShowLoop            ldb       ,x+                 load X with byte
                    stx       TempX,u             save the X value
                    pshs      u                   save the U value
                    leau      Digit,u             and point to the digit buffer
                    bsr       Str2Num             sub to the actual conversion routine
                    puls      u                   get the U value
                    lda       #2
                    ldy       #2
                    leax      Digit,u             and write the two digits
                    os9       I$Write
                    bcs       Error
                    tst       Count,u             is count at 0?
                    beq       PutCR               yep, put a CR
                    dec       Count,u             else decrement count
                    ldy       #1                  and print the delimiter
                    leax      Delim,u
                    os9       I$Write
                    bcs       Error
                    ldx       TempX,u             get the X value
                    bra       ShowLoop            and get the next time byte
PutCR               lda       #2
                    ldy       #2
                    leax      SpCR+1,pcr          print a CR for next line
                    os9       I$Write
                    lbcs      Error
Return              rts                           Return to caller!

************************************************************
* Str2Num:  Converts a one byte representation to its string
*           counterpart in the range of 0-255.
*
*  Entry:  U - Address to store text digits
*          B - Byte to convert
*
*  Exit:   None
*

Str2Num             pshs      a,b,u
                    lda       #$2f
                    inca
p1                  subb      #$64
                    bcc       p1
                    sta       ,u+
                    cmpa      #$30
                    bne       p2
                    leau      -1,u
p2                  lda       #$3a
p3                  deca
                    addb      #$0a
                    bcc       p3
                    sta       ,u+
                    addb      #$30
                    stb       ,u+
                    puls      a,b,u
                    rts

                    emod
Size                equ       *
                    end
