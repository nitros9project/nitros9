************************************************************
* More - Prompts lists a file or files one screen at a time.
*        If no files are specified, STDIN is used.
*
*        At the --More-- prompt, press:
*                <ENTER> to go advance one line
*                <BREAK> or 'Q' to quit
*                <SPACE> or any other key to advance one screenful
*
* Usage:  More [-l -w] [file] [...]
*         -l = show the name of the file before viewing
*                 (handy for multiple files)
*         -w = don't allow lines to wrap around.  This option truncates
*                 the line to a length of window's X size - 1.
*
*        If you are using a terminal other than the OS-9 Level II
*        windowing system, you will need to change the reverse
*        on/off sequence as well as the clear line sequence
*
*        NOTE: More works great with Shell+'s wildcards!  It also works
*              well with external terminals.  Just change the Reverse
*              on/off and DelLine bytes to match your terminal's codes.
*              If you are running 'more' on a terminal, it assumes an 80x24
*              terminal screen size.
*
* By: Boisy G. Pitre
*     1204 Love Street
*     Brookhaven, MS  39601
*     Internet:  bgpitre@seabass.st.usm.edu
*

                    ifp1
                    use       defsfile
                    endc

* Terminal specific equates:
XSIZE               equ       80
YSIZE               equ       24
DELNE               equ       $3
REVON               equ       $1f20
REVOFF              equ       $1f21

                    mod       Size,Name,Prgrm+Objct,ReEnt+1,Start,Fin

Name                fcs       /M/
                    fcb       2

Path                rmb       1
Response            rmb       1
XH                  rmb       1
XL                  rmb       1
YH                  rmb       1
YL                  rmb       1
LFlag               rmb       1
FilePtr             rmb       2
Buffer              rmb       250
FileBuf             rmb       60
Stack               rmb       200

* I make the Parms buffer large in case the wildcard expansion is long,
* else the system crashes.  You can alternately use the shell's memory
* modifier (i.e. #4k) to insure a big buffer.
Parms               rmb       4096

Fin                 equ       .

Message             fdb       REVON               Reverse Video on
                    fcc       /--More--/
                    fdb       REVOFF              Reverse Video off
MessLen             equ       *-Message

Header              fdb       C$LF
CR                  fcb       C$CR
                    fcc       /****** File: /
HeadLen             equ       *-Header


DelLine             fcb       DELNE               Delete line char
****** SUBROUTINES
PutHead             pshs      x                   Here, we actually print the header
                    leax      Header,pcr          for the file we are working on.
                    ldy       #HeadLen
                    lda       #1
                    os9       I$Write
                    lbcs      Error
                    puls      x
                    bsr       SaveFile
                    lda       #1
                    leax      FileBuf,u
                    ldy       #60
                    os9       I$WritLn
                    lbcs      Error
                    rts

SaveFile            pshs      x
                    leay      FileBuf,u
SaveF2              lda       ,x+
                    cmpa      #C$SPAC
                    bne       SaveF3
                    lda       #C$CR
SaveF3              sta       ,y+
                    cmpa      #C$CR
                    bne       SaveF2
                    puls      x
                    rts

GetSize             pshs      x
                    lda       #1                  Using stdout...
                    ldb       #SS.ScSiz
                    os9       I$GetStt            Find the X and Y size of window
                    bcs       ChekErr
                    stx       XH                  Save the X value
                    sty       YH                  Save the Y value
                    clr       XH                  Clear high-order byte of X
                    dec       XL                  Decrement the X value
                    dec       YL                  Decrement the Y value
                    dec       YL                  and dec Y again
                    puls      x
                    lda       YL                  Do the initial load of the counter
                    sta       YH
                    rts

ChekErr             cmpb      #E$UnkSvc           If this is true, then we are probably
                    bne       Error               dealing with a terminal, not a hardware
                    lda       #XSIZE              window.  We'll assume 80x24 as the
                    sta       XL                  terminal size.
                    lda       #YSIZE
                    sta       YL
                    clr       XH
                    rts

********* PROGRAM ENTRY
Start               pshs      x                   put away X temporarily,
                    leax      IntSvc,pc           point to the interrupt service routine
                    os9       F$Icpt              and make the system aware of it
                    puls      x                   then get X back for processing
                    clr       Path                Clear the path (assume stdin)
                    clr       LFlag
                    bsr       GetSize

Parse               lda       ,x+                 Parsing of the line is done here
                    cmpa      #C$SPAC
                    beq       Parse
                    cmpa      #'-
                    beq       GetOpt
                    cmpa      #C$CR
                    bne       TestFlag
                    tst       Path
                    beq       Cycle
                    bra       Done

GetOpt              lda       ,x+
                    cmpa      #C$SPAC
                    beq       Parse
                    anda      #$DF
                    cmpa      #'L
                    bne       IsItW
                    com       LFlag
                    bra       Parse
IsItW               cmpa      #'W
                    bne       Done
                    lda       XL
                    deca
                    sta       XH
                    bra       Parse

TestFlag            leax      -1,x                Here, we test to see if the -l
                    tst       LFlag               flag is set (to display the file
                    bne       TestF2              header)  If so, we print it, else
                    bsr       OpenFile
                    bra       ReadLine
TestF2              pshs      x                   we continue with reading...
                    lbsr      PutHead
                    puls      x
                    bsr       OpenFile
                    dec       YH                  Decrement counter twice to take into
                    dec       YH                  account the header (two lines)
                    lda       YH                  See if the count is less than 1
                    cmpa      #1
                    blt       ShowMess            if so, time to show prompt
                    bra       ReadLine            else read the line

OpenFile            lda       #Read.              Prepare for reading
                    os9       I$Open              Then open the file
                    bcs       Error               Exit on error
                    stx       FilePtr             Save X for later use
                    sta       Path                ...else save the path
                    rts

Done                clrb
Error               os9       F$Exit


Cycle               lda       YL                  Get the low order byte
                    sta       YH                  and use the high as a counter
                    bsr       PutCR

ReadLine            lda       Path                Get the path
                    ldy       #250                max chars read = 250
                    leax      Buffer,u            point to the buffer
                    os9       I$ReadLn            and read the line
                    bcs       EOF                 if error, check for EOF
                    tst       XH                  Is high order byte set?
                    beq       WriteOut            Nope, continue as normal
                    pshs      x                   else loop until end of the
                    ldb       XH                  string and place a CR at the
Loop                leax      1,x                 end.
                    decb                          This is unnecessary if the line
                    bne       Loop                is less than XH, but doesn't slow
                    lda       #C$CR               down the processing considerably
                    sta       ,x                  and would take longer if we actually
                    puls      x                   checked to see if a CR existed.

WriteOut            lda       #1                  Prepare to write to stdout
                    os9       I$WritLn            Write!
                    bcs       Error               if error, leave
                    dec       YH                  else decrement the counter
                    bne       ReadLine            if not 0, more lines to show

ShowMess            leax      Message,pc          Prepare to show message
                    ldy       #MessLen
                    lda       #2                  to stderr...
                    os9       I$Write             write it!
                    bcs       Error
                    lda       #2                  Now get response
                    ldy       #1                  of one character
                    leax      Response,u          from stderr
                    os9       I$Read
                    bcs       Error
                    bsr       KillLine
                    bra       TestInp

PutCR               leax      CR,pc
                    lda       #1
                    ldy       #1
                    os9       I$Write
                    bcs       Error
                    rts

KillLine            lda       #2                  Here we send a delete line char
                    ldy       #1                  to clean the prompt.
                    leax      DelLine,pc
                    os9       I$Write
                    bcs       Error
                    rts

EOF                 cmpb      #E$EOF              Check for end-of-file
                    bne       Error               If not, exit w/ error
EOF2                lda       Path                else close the path
                    os9       I$Close
                    tst       Path                If the path is stdin, we can quit
                    lbeq      Done
                    ldx       FilePtr
                    lbra      Parse               command line.

TestInp             lda       Response            Here we test the response at prompt
                    cmpa      #C$CR               is it cr?
                    beq       OneLine             yep, go up one line
                    anda      #$DF                else mask uppercase
                    cmpa      #'Q                 is it Q?
                    beq       IntSvc              Yep, kill prompt and exit
                    cmpa      #'N                 is it N?
                    lbne      Cycle               nope, must be space or other char
                    bsr       KillLine            else Kill the prompt
                    bra       EOF2                and get next file

IntSvc              bsr       KillLine            Interrupt service routine
                    lbra      Done

OneLine             lda       #1                  We go here if <ENTER> was pressed
                    sta       YH,u                to increment only one line
                    lbra      ReadLine

                    emod
Size                equ       *
                    end

