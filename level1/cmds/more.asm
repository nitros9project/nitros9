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
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      1991/??/??  Boisy Pitre
* Created.
*
*   3      2026/05/21  Codex
* Annotated source, normalized comments, and optimized command size.

                  IFP1
                    use       defsfile  ; pull in OS-9 and project symbols
                  ENDC

* Terminal specific equates:
XSIZE               equ       80        ; default terminal width if SS.ScSiz is unsupported
YSIZE               equ       24        ; default terminal height if SS.ScSiz is unsupported
DELNE               equ       $3        ; terminal delete-line control byte
REVON               equ       $1f20     ; os-9 window reverse-video-on sequence
REVOFF              equ       $1f21     ; os-9 window reverse-video-off sequence

                    mod       Size,Name,Prgrm+Objct,ReEnt+1,Start,Fin ; define the program module header

Name                fcs       /more/    ; compressed module name
                    fcb       2         ; module edition

Path                rmb       1         ; current input path, or zero for standard input
Response            rmb       1         ; one-character response from the --More-- prompt
XH                  rmb       1         ; wrap/truncate column limit, or zero when wrapping
XL                  rmb       1         ; window width minus one
YH                  rmb       1         ; remaining output-line counter for current screen
YL                  rmb       1         ; window height minus two
LFlag               rmb       1         ; nonzero when -l file headers are enabled
FilePtr             rmb       2         ; saved command-line pointer after opening a file
Buffer              rmb       250       ; input line buffer used by I$ReadLn
FileBuf             rmb       60        ; header filename buffer written by I$WritLn
Stack               rmb       200       ; program stack area

* I make the Parms buffer large in case the wildcard expansion is long,
* else the system crashes.  You can alternately use the shell's memory
* modifier (i.e. #4k) to insure a big buffer.
Parms               rmb       4096      ; parameter buffer reserved for expanded command lines

Fin                 equ       .         ; end of direct-page storage

Message             fdb       REVON     ; reverse video on
                    fcc       /--More--/          ; prompt text shown between screenfuls
                    fdb       REVOFF    ; reverse video off
MessLen             equ       *-Message ; prompt sequence length

Header              fdb       C$LF      ; start file header on a new line
CR                  fcb       C$CR      ; carriage return used for output and truncation
                    fcc       /****** File: /     ; file header prefix
HeadLen             equ       *-Header  ; file header prefix length


DelLine             fcb       DELNE     ; delete line char
****** SUBROUTINES
GetSize             pshs      x         ; preserve command-line pointer while probing stdout
                    lda       #1        ; use stdout for the screen-size query
                    ldb       #SS.ScSiz ; request screen-size status
                    os9       I$GetStt  ; find the X and Y size of window
                    bcs       ChekErr   ; fall back to terminal defaults if GetStat failed
                    stx       XH        ; save the X value
                    sty       YH        ; save the Y value
                    clr       XH        ; clear high-order byte of X
                    dec       XL        ; decrement the X value
                    dec       YL        ; decrement the Y value
                    dec       YL        ; and dec Y again
GetSiz2             puls      x         ; restore command-line pointer
                    lda       YL        ; load the initial screen-line count
                    sta       YH        ; prime remaining-line counter
                    rts                 ; return with screen dimensions cached

ChekErr             cmpb      #E$UnkSvc ; test whether the status call is unsupported
                    lbne      Error     ; dealing with a terminal, not a hardware
                    lda       #XSIZE    ; window.  We'll assume 80x24 as the
                    sta       XL        ; terminal size.
                    lda       #YSIZE    ; use the default terminal height
                    sta       YL        ; save fallback height
                    clr       XH        ; disable line truncation unless -w is used
                    bra       GetSiz2   ; restore X and initialize line counter

********* PROGRAM ENTRY
Start               pshs      x         ; put away X temporarily,
                    leax      IntSvc,pc ; point to the interrupt service routine
                    os9       F$Icpt    ; and make the system aware of it
                    puls      x         ; then get X back for processing
                    clr       Path      ; clear the path and assume stdin
                    clr       LFlag     ; clear file-header option flag
                    bsr       GetSize   ; cache screen or terminal size

Parse               lda       ,x+       ; parse the next command-line character
                    cmpa      #C$SPAC   ; check for leading or inter-argument space
                    beq       Parse     ; skip spaces between command-line items
                    cmpa      #'-       ; check for an option marker
                    beq       GetOpt    ; parse option letter after '-'
                    cmpa      #C$CR     ; check for end of command line
                    bne       TestFlag  ; treat non-CR as a pathlist start
                    tst       Path      ; see whether stdin was already consumed
                    bne       Done      ; exit after the final explicit file
                    bra       Cycle     ; page standard input when no filenames are present

GetOpt              lda       ,x+       ; fetch option character
                    cmpa      #C$SPAC   ; a bare '-' followed by space ends this option
                    beq       Parse     ; resume parsing at the next argument
                    anda      #$DF      ; force option letter to uppercase
                    cmpa      #'L       ; test for file-header option
                    bne       IsItW     ; if not -l, check for -w
                    com       LFlag     ; toggle header display flag
                    bra       Parse     ; continue command-line parsing
IsItW               cmpa      #'W       ; test for no-wrap option
                    bne       Done      ; unknown option exits successfully
                    lda       XL        ; load usable screen width
                    deca                ; reserve one more column before truncation
                    sta       XH        ; enable truncation at width minus two
                    bra       Parse     ; continue command-line parsing

TestFlag            leax      -1,x      ; back up X to the start of the pathlist
                    tst       LFlag     ; flag is set (to display the file
                    bne       TestF2    ; header)  If so, we print it, else
                    bsr       OpenFile  ; open the filename at X
                    bra       ReadLine  ; start paging the opened file
TestF2              bsr       PutHead   ; we continue with reading...
                    bsr       OpenFile  ; open the file after printing its header
                    dec       YH        ; decrement counter twice to take into
                    dec       YH        ; account the header (two lines)
                    lda       YH        ; see if the count is less than 1
                    cmpa      #1        ; test whether the header filled the screen
                    blt       ShowMess  ; if so, time to show prompt
                    bra       ReadLine  ; else read the line

OpenFile            lda       #Read.    ; prepare for reading
                    os9       I$Open    ; open the file
                    bcs       Error     ; exit on error
                    stx       FilePtr   ; save X for later use
                    sta       Path      ; ...else save the path
                    rts                 ; return with input path selected

PutHead             pshs      x         ; preserve path pointer while printing the header
                    leax      Header,pcr ; for the file we are working on.
                    ldy       #HeadLen  ; write only the fixed header prefix
                    lda       #1        ; select standard output
                    os9       I$Write   ; emit the header prefix
                    bcs       Error     ; exit on write error
                    ldx       ,s        ; reload original command-line path pointer
                    bsr       SaveFile  ; copy current filename into FileBuf
                    lda       #1        ; select standard output
                    leax      FileBuf,u ; point to CR-terminated filename buffer
                    ldy       #60       ; limit header filename output to FileBuf size
                    os9       I$WritLn  ; write filename line
                    bcs       Error     ; exit on write error
                    puls      x         ; restore command-line path pointer
                    rts                 ; return with X still at path start

SaveFile            leay      FileBuf,u ; point Y at filename copy buffer
SaveF2              lda       ,x+       ; copy next filename character
                    cmpa      #C$SPAC   ; treat command-line space as filename terminator
                    bne       SaveF3    ; keep non-space character unchanged
                    lda       #C$CR     ; convert delimiter space to line terminator
SaveF3              sta       ,y+       ; store character in header filename buffer
                    cmpa      #C$CR     ; stop when the copied name is terminated
                    bne       SaveF2    ; continue copying filename characters
                    rts                 ; return with FileBuf ready for I$WritLn

Done                clrb                ; return success status
Error               os9       F$Exit    ; exit process with B as status

Cycle               lda       YL        ; get the low order byte
                    sta       YH        ; and use the high as a counter
                    bsr       PutCR     ; separate screenfuls with a carriage return

ReadLine            lda       Path      ; get the path
                    ldy       #250      ; max chars read = 250
                    leax      Buffer,u  ; point to the buffer
                    os9       I$ReadLn  ; and read the line
                    bcs       EOF       ; if error, check for EOF
                    tst       XH        ; is high order byte set?
                    beq       WriteOut  ; continue normally when no truncation is active
                    pshs      x         ; else move to the truncation
                    ldb       XH        ; column and place a CR there
                    abx                 ; to end the line early.
                    lda       #C$CR     ; load a carriage return terminator
                    sta       ,x        ; truncate the line at selected column
                    puls      x         ; restore buffer start for output

WriteOut            lda       #1        ; prepare to write to stdout
                    os9       I$WritLn  ; write the current line
                    bcs       Error     ; if error, leave
                    dec       YH        ; else decrement the counter
                    bne       ReadLine  ; if not 0, more lines to show

ShowMess            leax      Message,pc ; prepare to show message
                    ldy       #MessLen  ; use full prompt sequence length
                    lda       #2        ; to stderr...
                    os9       I$Write   ; write it!
                    bcs       Error     ; exit on prompt write error
                    lda       #2        ; now get response
                    ldy       #1        ; of one character
                    leax      Response,u ; from stderr
                    os9       I$Read    ; read one prompt-response character
                    bcs       Error     ; exit on prompt read error
                    bsr       KillLine  ; remove the prompt from the display
                    bra       TestInp   ; decode the user's response

PutCR               leax      CR,pc     ; point to the carriage return byte
                    lda       #1        ; select standard output
                    bra       PutChar   ; write one byte and return

KillLine            lda       #2        ; send a delete line char
                    leax      DelLine,pc ; to clean the prompt.
PutChar             ldy       #1        ; write exactly one control byte
                    os9       I$Write   ; send CR or delete-line sequence
                    bcs       Error     ; exit on write error
                    rts                 ; return after successful one-byte write

EOF                 cmpb      #E$EOF    ; check for end-of-file
                    bne       Error     ; exit with error if not EOF
EOF2                lda       Path      ; else close the path
                    os9       I$Close   ; close current input path
                    tst       Path      ; see whether the path was stdin
                    beq       Done      ; exit after consuming standard input
                    ldx       FilePtr   ; resume parsing after the file path just read
                    lbra      Parse     ; command line.

TestInp             lda       Response  ; test the response at prompt
                    cmpa      #C$CR     ; is it cr?
                    beq       OneLine   ; yep, go up one line
                    anda      #$DF      ; else mask uppercase
                    cmpa      #'Q       ; is it Q?
                    beq       IntSvc    ; kill prompt and exit on Q
                    cmpa      #'N       ; is it N?
                    lbne      Cycle     ; nope, must be space or other char
                    bsr       KillLine  ; else Kill the prompt
                    bra       EOF2      ; and get next file

IntSvc              bsr       KillLine  ; handle interrupt or quit by clearing prompt
                    lbra      Done      ; exit successfully after break or Q

OneLine             lda       #1        ; go here if <ENTER> was pressed
                    sta       YH,u      ; to increment only one line
                    lbra      ReadLine  ; read and output one additional line

                    emod      ;         end module and emit CRC
Size                equ       *         ; final module size
                    end       ;         end assembly source
