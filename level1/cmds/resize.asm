********************************************************************
* Resize - set a terminal's size from the terminal's own answer
*
* Asks the terminal on a path for its size with the VT100 and xterm
* queries, then sets the columns and rows in its device descriptor to
* match, so that SS.ScSiz reports the size the terminal really has
*
* Usage: resize [-p] [/<device>]
*
*   -p         print the size without changing the descriptor
*   /<device>  ask the terminal on this device instead of the
*              standard paths
*
* Without a device it uses the first of the standard input, output and
* error paths that is a character device, so that it still works from a
* procedure file, whose commands read the file as their standard input
*
* It sends both queries at once:
*
*   ESC [ 18 t                    answered ESC [ 8 ; rows ; cols t
*   ESC 7 ESC [ 999 ; 999 H       moves the cursor to the bottom right
*   ESC [ 6 n                     answered ESC [ row ; col R
*   ESC 8                         puts the cursor back
*
* The answer to ESC [ 18 t is used if one comes, and the cursor
* position otherwise.  The position report comes last, so it ends the
* wait.  A terminal that answers neither leaves the descriptor alone
* and the command exits with E$NotRdy.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2026/11/06  Mark Murray
* Created.

                    nam       Resize
                    ttl       Set a terminal's size from the terminal's answer

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

Esc                 equ       $1B                 escape character
IdleTks             equ       25                  ticks to wait for the next byte of an answer
MaxBytes            equ       128                 most bytes read while waiting for the answers
OptSize             equ       32                  size of the path options from SS.Opt
NameSize            equ       32                  size of a device name from SS.DevNm

                    mod       eom,name,tylg,atrv,start,size

                    org       0
RdPath              rmb       1                   path the answers are read from
WrPath              rmb       1                   path the queries are written to
Opened              rmb       1                   set when we opened the path ourselves
PrtOnly             rmb       1                   set when the descriptor is left alone
OptSaved            rmb       1                   set while the path options need restoring
SigCode             rmb       1                   highest signal received
Idle                rmb       1                   ticks left to wait for the next byte
Budget              rmb       1                   bytes left to read
State               rmb       1                   parser state
ParmIdx             rmb       1                   offset of the current parameter
Parms               rmb       6                   up to three parameters of an answer
WinRow              rmb       1                   rows from the window size answer
WinCol              rmb       1                   columns from the window size answer
PosRow              rmb       1                   row from the cursor position answer
PosCol              rmb       1                   column from the cursor position answer
Rows                rmb       1                   rows to report
Cols                rmb       1                   columns to report
InChar              rmb       1                   byte just read
CRCAcc              rmb       3                   module crc accumulator
VarSize             equ       .
OldOpt              rmb       OptSize             path options as we found them
NewOpt              rmb       OptSize             path options while we listen
DevName             rmb       NameSize            name of the device on the path
OutBuf              rmb       16                  the size to print
                    rmb       256                 stack
size                equ       .

name                fcs       /Resize/
                    fcb       edition

Query               fcb       Esc                 ask for the window size in characters
                    fcc       "[18t"
                    fcb       Esc                 save the cursor
                    fcc       "7"
                    fcb       Esc                 move the cursor as far as it goes
                    fcc       "[999;999H"
                    fcb       Esc                 ask for the cursor position
                    fcc       "[6n"
                    fcb       Esc                 restore the cursor
                    fcc       "8"
QueryLen            equ       *-Query

UseMsg              fcc       "Usage: resize [-p] [/<device>]"
                    fcb       C$CR
UseLen              equ       *-UseMsg

NoAnsMsg            fcc       "resize: no answer from the terminal"
                    fcb       C$CR
NoAnsLen            equ       *-NoAnsMsg

TypeMsg             fcc       "resize: not an SCF path"
                    fcb       C$CR
TypeLen             equ       *-TypeMsg

* Clear the variables and read the arguments
start               pshs      x                   ; save the parameter pointer
                    leax      ,u                  ; point to the variables
                    ldb       #VarSize            ; get the size of the variables
clear@              clr       ,x+                 ; clear one
                    decb                          ; count it
                    bne       clear@              ; until all are clear
                    puls      x                   ; get the parameter pointer back
ArgLoop             lda       ,x+                 ; get the next character
                    cmpa      #C$SPAC             ; space?
                    beq       ArgLoop             ; yes, skip it
                    cmpa      #C$CR               ; end of the arguments?
                    beq       ArgsDone            ; yes, go ask the terminal
                    cmpa      #'-                 ; an option?
                    beq       Option              ; yes, go read it
                    cmpa      #PDELIM             ; a device name?
                    bne       Usage               ; no, show the usage
                    tst       <Opened             ; already given a device?
                    bne       Usage               ; yes, show the usage
                    leax      -1,x                ; point back to the start of the name
                    lda       #UPDAT.             ; open it for reading and writing
                    os9       I$Open              ; open the device
                    lbcs      Exit                ; return the error if it failed
                    sta       <RdPath             ; read the answers from it
                    sta       <WrPath             ; and send the queries to it
                    inc       <Opened             ; close it when we are done
                    bra       ArgLoop             ; go read the next argument
Option              lda       ,x+                 ; get the option letter
                    anda      #$DF                ; make it uppercase
                    cmpa      #'P                 ; print only?
                    bne       Usage               ; no, show the usage
                    inc       <PrtOnly            ; leave the descriptor alone
                    lda       ,x                  ; get the character after the option
                    cmpa      #C$SPAC             ; space?
                    beq       ArgLoop             ; yes, go read the next argument
                    cmpa      #C$CR               ; end of the arguments?
                    beq       ArgLoop             ; yes, go finish
Usage               leax      UseMsg,pcr          ; point to the usage message
                    ldy       #UseLen             ; get its length
                    lda       #2                  ; on the standard error path
                    os9       I$WritLn            ; print it
                    ldb       #E$IllArg           ; return an argument error
                    lbra      Exit                ; and exit

* Set the path up so that the answers arrive unchanged
ArgsDone            leax      SigIcpt,pcr         ; point to the signal routine
                    os9       F$Icpt              ; catch signals so the options get restored
TryPath             leax      OldOpt,u            ; point to the buffer for the path options
                    lda       <RdPath             ; on the path the answers would come from
                    ldb       #SS.Opt             ; get the path options
                    os9       I$GetStt            ; read them
                    bcs       NextPath            ; try another path if it failed
                    lda       PD.DTP-PD.OPT,x     ; get the device type
                    cmpa      #DT.SCF             ; a character device?
                    beq       FoundSCF            ; yes, use this path
                    ldb       #E$BTyp             ; no, remember why
NextPath            tst       <Opened             ; were we given the device?
                    bne       PathErr             ; yes, there is no other path to try
                    lda       <RdPath             ; get the path just tried
                    inca                          ; the next standard path
                    cmpa      #2                  ; past the standard error path?
                    bhi       PathErr             ; yes, none of them is a terminal
                    sta       <RdPath             ; read the answers from it
                    sta       <WrPath             ; and send the queries to it
                    bra       TryPath             ; go try it
PathErr             cmpb      #E$BTyp             ; not a character device?
                    lbeq      NotSCF              ; yes, say so
                    lbra      Exit                ; return the error
FoundSCF            leay      NewOpt,u            ; point to the copy
                    ldb       #OptSize            ; get the size of the options
copy@               lda       ,x+                 ; get a byte of the options
                    sta       ,y+                 ; copy it
                    decb                          ; count it
                    bne       copy@               ; until all are copied
                    leax      NewOpt,u            ; point to the copy
                    clr       PD.EKO-PD.OPT,x     ; no echo, so the answers stay off the screen
                    clr       PD.EOF-PD.OPT,x     ; no end of file character, as it is escape
                    clr       PD.UPC-PD.OPT,x     ; no uppercase, which would change the queries
                    lda       <RdPath             ; on the path the answers come from
                    ldb       #SS.Opt             ; set the path options
                    os9       I$SetStt            ; to the copy
                    lbcs      Exit                ; return the error if it failed
                    inc       <OptSaved           ; restore them on the way out

* Send the queries
                    leax      Query,pcr           ; point to the queries
                    ldy       #QueryLen           ; get their length
                    lda       <WrPath             ; on the path for the queries
                    os9       I$Write             ; send them
                    bcc       Listen              ; go wait for the answers if it worked
                    tst       <Opened             ; was the path a device we were given?
                    lbne      Exit                ; yes, return the error
                    lda       #1                  ; use the standard output instead
                    sta       <WrPath             ; for the queries
                    leax      Query,pcr           ; point to the queries
                    ldy       #QueryLen           ; get their length
                    os9       I$Write             ; send them
                    lbcs      Exit                ; return the error if it failed

* Read the answers until the position report ends them, or nothing comes
Listen              lda       #MaxBytes           ; get the most bytes to read
                    sta       <Budget             ; set the count
NewByte             lda       #IdleTks            ; get the ticks to wait for a byte
                    sta       <Idle               ; start waiting
Poll                lda       <SigCode            ; get the signal received
                    cmpa      #S$Abort            ; an abort or anything after it?
                    bhs       Aborted             ; yes, stop
                    lda       <RdPath             ; on the path the answers come from
                    ldb       #SS.Ready           ; is a byte waiting?
                    os9       I$GetStt            ; ask the driver
                    bcc       ReadOne             ; yes, go read it
                    cmpb      #E$NotRdy           ; nothing waiting yet?
                    bne       Heard               ; no, the device cannot tell us, so stop
                    dec       <Idle               ; count a tick
                    beq       Heard               ; stop when the wait is over
                    ldx       #1                  ; one tick
                    os9       F$Sleep             ; wait for it
                    bra       Poll                ; and look again
ReadOne             leax      InChar,u            ; point to the byte buffer
                    ldy       #1                  ; one byte
                    lda       <RdPath             ; from the path the answers come from
                    os9       I$Read              ; read it
                    bcs       Heard               ; stop on an error
                    lda       <InChar             ; get the byte
                    lbsr      Parse               ; add it to the answer
                    bcs       Heard               ; stop when the position report is complete
                    dec       <Budget             ; count the byte
                    bne       NewByte             ; go wait for the next one
Heard               lbsr      Restore             ; put the path options back
                    ldd       <WinRow             ; get the window size answer
                    tsta                          ; was there one?
                    bne       HaveSize            ; yes, use it
                    ldd       <PosRow             ; get the cursor position answer
                    tsta                          ; was there one?
                    bne       HaveSize            ; yes, use it
                    leax      NoAnsMsg,pcr        ; point to the message
                    ldy       #NoAnsLen           ; get its length
                    lda       #2                  ; on the standard error path
                    os9       I$WritLn            ; report that nothing answered
                    ldb       #E$NotRdy           ; return device not ready
                    bra       Exit                ; and exit
Aborted             ldb       <SigCode            ; return the signal
                    bra       Exit                ; and exit
HaveSize            sta       <Rows               ; save the rows
                    stb       <Cols               ; and the columns
                    tst       <PrtOnly            ; leave the descriptor alone?
                    bne       Report              ; yes, just print the size
                    lbsr      SetDesc             ; set the size in the descriptor
                    bcs       Exit                ; return the error if it failed

* Print the size as columns x rows
Report              leax      OutBuf,u            ; point to the output buffer
                    lda       <Cols               ; get the columns
                    lbsr      Decimal             ; put them in the buffer
                    lda       #'x                 ; get the separator
                    sta       ,x+                 ; put it in the buffer
                    lda       <Rows               ; get the rows
                    lbsr      Decimal             ; put them in the buffer
                    lda       #C$CR               ; get the end of the line
                    sta       ,x+                 ; put it in the buffer
                    tfr       x,d                 ; get the end of the buffer
                    leax      OutBuf,u            ; point to the start of the buffer
                    pshs      x                   ; save the start
                    subd      ,s++                ; get the length
                    tfr       d,y                 ; as the count
                    lda       #1                  ; on the standard output path
                    os9       I$WritLn            ; print the size
                    bcs       Exit                ; return the error if it failed
                    clrb                          ; no error

* Restore the path options, close the path we opened and exit
Exit                pshs      b,cc                ; save the exit status
                    bsr       Restore             ; put the path options back
                    tst       <Opened             ; did we open the path?
                    beq       bye@                ; no, leave it open
                    lda       <RdPath             ; get the path
                    os9       I$Close             ; close it
bye@                puls      b,cc                ; get the exit status back
                    os9       F$Exit              ; and exit

NotSCF              leax      TypeMsg,pcr         ; point to the message
                    ldy       #TypeLen            ; get its length
                    lda       #2                  ; on the standard error path
                    os9       I$WritLn            ; report that the path is not a terminal
                    ldb       #E$BTyp             ; return a bad type error
                    bra       Exit                ; and exit

* Put the path options back if we changed them
Restore             tst       <OptSaved           ; did we change them?
                    beq       ret@                ; no, nothing to do
                    clr       <OptSaved           ; only once
                    leax      OldOpt,u            ; point to the options as we found them
                    lda       <RdPath             ; on the path we changed
                    ldb       #SS.Opt             ; set the path options
                    os9       I$SetStt            ; back to how they were
ret@                rts                           ; return

* Signal routine: remember the highest signal for the main loop
* Entry: B = signal code, U = data area
SigIcpt             cmpb      SigCode,u           ; higher than the one already received?
                    bls       ret@                ; no, keep the old one
                    stb       SigCode,u           ; remember it
ret@                rti                           ; return to the program

* Add a byte to the answer being read
* Entry: A = the byte
* Exit:  carry set when a cursor position report has ended
Parse               ldb       <State              ; get the parser state
                    beq       WaitEsc             ; waiting for an escape
                    decb                          ; after an escape?
                    beq       WaitBrkt            ; yes, waiting for the bracket
                    cmpa      #'0                 ; below a digit?
                    blo       NotDigit            ; yes, not a digit
                    cmpa      #'9                 ; above a digit?
                    bhi       NotDigit            ; yes, not a digit
                    suba      #'0                 ; get the digit's value
                    pshs      a                   ; save it
                    leax      Parms,u             ; point to the parameters
                    ldb       <ParmIdx            ; get the offset of the current one
                    abx                           ; point to it
                    ldd       ,x                  ; get its value so far
                    tsta                          ; already above 255?
                    bne       big@                ; yes, leave it there
                    lda       #10                 ; times ten
                    mul                           ; shift it up a digit
                    addb      ,s                  ; add the new digit
                    adca      #0                  ; and its carry
                    std       ,x                  ; save the new value
big@                leas      1,s                 ; drop the digit
                    bra       Going               ; keep reading
NotDigit            cmpa      #';                 ; a parameter separator?
                    bne       NotSemi             ; no, go check for the end
                    ldb       <ParmIdx            ; get the offset of the current one
                    cmpb      #4                  ; already at the third?
                    bhs       Reset               ; yes, not an answer we know
                    addb      #2                  ; move to the next
                    stb       <ParmIdx            ; save the offset
                    bra       Going               ; keep reading
NotSemi             cmpa      #Esc                ; another escape?
                    beq       GotEsc              ; yes, start again
                    cmpa      #'R                 ; a cursor position report?
                    beq       PosRpt              ; yes, go use it
                    cmpa      #'t                 ; a window size report?
                    beq       WinRpt              ; yes, go use it
Reset               clr       <State              ; wait for the next escape
Going               andcc     #^Carry             ; not finished
                    rts                           ; return
WaitBrkt            cmpa      #'[                 ; the bracket after the escape?
                    beq       Bracket             ; yes, start the parameters
                    clr       <State              ; no, wait for the next escape
WaitEsc             cmpa      #Esc                ; an escape?
                    bne       Going               ; no, skip the byte
GotEsc              lda       #1                  ; now after an escape
                    sta       <State              ; save the state
                    bra       Going               ; keep reading
Bracket             ldd       #0                  ; get zero
                    std       <Parms              ; clear the first parameter
                    std       <Parms+2            ; the second
                    std       <Parms+4            ; and the third
                    sta       <ParmIdx            ; start at the first
                    lda       #2                  ; now in the parameters
                    sta       <State              ; save the state
                    bra       Going               ; keep reading

* ESC [ row ; col R, with the cursor at the bottom right
PosRpt              ldb       <ParmIdx            ; get the offset of the last parameter
                    cmpb      #2                  ; exactly two?
                    bne       Reset               ; no, not an answer we know
                    ldd       <Parms+2            ; get the column
                    bsr       Check               ; in range?
                    bcs       Ended               ; no, give up on it
                    pshs      b                   ; save the column
                    ldd       <Parms              ; get the row
                    bsr       Check               ; in range?
                    puls      a                   ; get the column back
                    bcs       Ended               ; give up on it if the row is out of range
                    stb       <PosRow             ; save the row
                    sta       <PosCol             ; and the column
Ended               clr       <State              ; wait for the next escape
                    orcc      #Carry              ; the position report has ended
                    rts                           ; return

* ESC [ 8 ; rows ; cols t
WinRpt              ldb       <ParmIdx            ; get the offset of the last parameter
                    cmpb      #4                  ; exactly three?
                    bne       Reset               ; no, not an answer we know
                    ldd       <Parms              ; get the first parameter
                    cmpd      #8                  ; the size of the text area?
                    bne       Reset               ; no, not an answer we know
                    ldd       <Parms+4            ; get the columns
                    bsr       Check               ; in range?
                    bcs       Reset               ; no, ignore the answer
                    pshs      b                   ; save the columns
                    ldd       <Parms+2            ; get the rows
                    bsr       Check               ; in range?
                    puls      a                   ; get the columns back
                    bcs       Reset               ; ignore the answer if the rows are out of range
                    stb       <WinRow             ; save the rows
                    sta       <WinCol             ; and the columns
                    bra       Reset               ; wait for the next answer

* Check that a size fits in a descriptor byte
* Entry: D = the value
* Exit:  B = the value, carry set unless it is 1 to 255
Check               tsta                          ; above 255?
                    bne       bad@                ; yes, out of range
                    tstb                          ; zero?
                    beq       bad@                ; yes, out of range
                    andcc     #^Carry             ; in range
                    rts                           ; return
bad@                orcc      #Carry              ; out of range
                    rts                           ; return

* Set the columns and rows in the device descriptor
* Exit: carry set and B = error code on failure
SetDesc             leax      DevName,u           ; point to the name buffer
                    lda       <RdPath             ; on the path the answers came from
                    ldb       #SS.DevNm           ; get the device name
                    os9       I$GetStt            ; read it
                    bcs       DescRet             ; return the error if it failed
                    pshs      u                   ; save the data area pointer
                    lda       #Devic              ; a device descriptor
                    os9       F$Link              ; link to it
                    tfr       u,y                 ; point to the descriptor
                    puls      u                   ; get the data area pointer back
                    bcs       DescRet             ; return the error if it failed
                    lda       IT.DVC,y            ; get the device type
                    cmpa      #DT.SCF             ; a character device?
                    bne       BadDesc             ; no, refuse it
                    ldb       M$Opt,y             ; get the size of the options
                    cmpb      #IT.ROW+1-M$DTyp    ; long enough to hold the rows?
                    blo       BadDesc             ; no, refuse it
                    lda       <Cols               ; get the columns
                    sta       IT.COL,y            ; set them
                    lda       <Rows               ; get the rows
                    sta       IT.ROW,y            ; set them
                    ldd       #$FFFF              ; get the crc starting value
                    std       <CRCAcc             ; start the accumulator
                    sta       <CRCAcc+2           ; all three bytes
                    pshs      y,u                 ; save the descriptor and data area pointers
                    tfr       y,x                 ; point to the start of the descriptor
                    ldd       M$Size,x            ; get its size
                    subd      #3                  ; without the crc
                    tfr       d,y                 ; as the count
                    leau      CRCAcc,u            ; point to the accumulator
                    os9       F$CRC               ; work out the crc
                    puls      y,u                 ; get the pointers back
                    bcs       Unlink              ; release the descriptor on an error
                    ldd       M$Size,y            ; get the size of the descriptor
                    leax      d,y                 ; point past its end
                    lda       <CRCAcc             ; get the first crc byte
                    coma                          ; complement it
                    sta       -3,x                ; store it
                    lda       <CRCAcc+1           ; get the second crc byte
                    coma                          ; complement it
                    sta       -2,x                ; store it
                    lda       <CRCAcc+2           ; get the third crc byte
                    coma                          ; complement it
                    sta       -1,x                ; store it
                    clrb                          ; no error
Unlink              pshs      b,cc,u              ; save the status and data area pointer
                    tfr       y,u                 ; point to the descriptor
                    os9       F$UnLink            ; release it
                    puls      b,cc,u,pc           ; return the status
BadDesc             ldb       #E$BTyp             ; return a bad type error
                    orcc      #Carry              ; set the carry
                    bra       Unlink              ; release the descriptor
DescRet             rts                           ; return

* Put a value in decimal into the output buffer, without leading zeros
* Entry: A = the value, X = where it goes
* Exit:  X = past the digits
Decimal             clr       ,-s                 ; no digit yet
                    ldb       #100                ; the hundreds
                    bsr       Digit               ; put that digit in
                    ldb       #10                 ; the tens
                    bsr       Digit               ; put that digit in
                    adda      #'0                 ; make the units a digit
                    sta       ,x+                 ; put it in
                    leas      1,s                 ; drop the flag
                    rts                           ; return

* Entry: A = the value, B = the power of ten, 2,s = the digit flag
* Exit:  A = the remainder
Digit               pshs      b                   ; save the power of ten
                    ldb       #'0-1               ; start below zero
count@              incb                          ; count one more
                    suba      ,s                  ; take the power of ten off
                    bhs       count@              ; until it goes below zero
                    adda      ,s+                 ; put the last one back and drop the power
                    cmpb      #'0                 ; a zero?
                    bne       put@                ; no, always put it in
                    tst       2,s                 ; any digit before it?
                    beq       ret@                ; no, leave the leading zero out
put@                stb       ,x+                 ; put the digit in
                    inc       2,s                 ; a digit is in now
ret@                rts                           ; return

                    emod
eom                 equ       *
                    end

