********************************************************************
* KeyRpt - Set CoCo keyboard repeat timing
*
* Usage:
*   keyrpt <start> <speed>
*
* <start> and <speed> are decimal byte values in 1/60ths of a second.
* A start value of 0 disables held-key repeat.  A value of 255 leaves
* the corresponding current setting unchanged.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2026/05/29  Codex
* Annotated source and normalized comments.

                    nam       KeyRpt    ; name this OS-9 module
                    ttl       Set CoCo keyboard repeat timing ; describe the module

                  ifp1
                    use       defsfile  ; include system definitions on pass 1
                  endc

DOHELP              set       0         ; set non-zero to include built-in usage text

tylg                set       Prgrm+Objct ; mark module as an executable program
atrv                set       ReEnt+rev ; mark module re-entrant and revisioned
rev                 set       $00       ; set module revision byte
edition             set       1         ; set module edition byte

                    mod       eom,name,tylg,atrv,start,size ; emit OS-9 module header

                    org       0         ; begin direct-page storage
got                 rmb       1         ; remember whether the parser saw any digits
                    rmb       128       ; reserve process stack space
size                equ       .         ; compute required data area size

name                fcs       /KeyRpt/            ; store module name in OS-9 string format
                    fcb       edition   ; append module edition byte

start               bsr       ParseByte ; parse repeat start delay into B
                    bcs       Usage     ; show usage when the first byte is invalid
                    pshs      b         ; save start delay while parsing speed
                    bsr       ParseByte ; parse repeat speed into B
                    bcs       UsagePull ; discard saved delay before reporting syntax error
                    tfr       b,a       ; move speed to A temporarily
                    ldb       ,s+       ; restore start delay into B
                    exg       a,b       ; arrange D as start delay in A, speed in B
                    tfr       d,y       ; pass repeat parameters in Y for SS.GIP
                    bsr       SkipSep   ; skip any trailing spaces or commas
                    cmpa      #C$CR     ; require end of command line after two values
                    bne       Usage     ; reject extra trailing text
                    clra                ; select standard input path 0
                    ldb       #SS.GIP   ; request global input parameter SetStat
                    os9       I$SetStt  ; ask VTIO to update keyboard repeat timing
Exit                clrb                ; return success status in B and clear carry
                    os9       F$Exit    ; terminate process with B as status

UsagePull           leas      1,s       ; drop saved start delay after second parse failed
Usage               equ       *         ; common syntax-error exit path
                    ifne      DOHELP
                    leax      <UsageMsg,pcr ; point X at usage text
                    ldy       #UsageLen ; set number of bytes to write
                    lda       #2        ; write usage text to standard error
                    os9       I$WritLn  ; display the usage line
                    endc
                    bra       Exit      ; exit with the SetStat status in B

ParseByte           bsr       SkipSep   ; move X to the next candidate byte
                    cmpa      #C$CR     ; detect missing value at end of line
                    beq       BadNum    ; fail when no number follows
                    clr       <got      ; clear digit-seen flag
                    clrb                ; clear accumulated byte value
ParseLoop           lda       ,x        ; fetch next parameter character
                    suba      #'0       ; convert ASCII digit candidate to binary
                    bcs       EndNum    ; stop when character is below '0'
                    cmpa      #9        ; test for digit above '9'
                    bhi       EndNum    ; stop when character is not decimal
                    leax      1,x       ; consume this digit
                    pshs      a         ; save digit while multiplying accumulator
                    lda       #10       ; prepare decimal base for multiply
                    mul                 ; multiply accumulated value in B by 10
                    tsta                ; detect overflow above one byte
                    bne       BadPull   ; reject values greater than 255
                    addb      ,s+       ; add saved digit to accumulator
                    bcs       BadNum    ; reject byte overflow after adding digit
                    inc       <got      ; record that at least one digit was parsed
                    bra       ParseLoop ; continue scanning decimal digits

BadPull             leas      1,s       ; discard saved digit before returning failure
BadNum              orcc      #Carry    ; return with carry set for parse failure
                    rts                 ; return to caller

EndNum              tst       <got      ; check whether any digits were consumed
                    beq       BadNum    ; reject an empty field
                    lda       ,x        ; inspect delimiter after the number
                    cmpa      #C$SPAC   ; accept a space separator
                    beq       GoodNum   ; return successful parse
                    cmpa      #C$COMA   ; accept a comma separator
                    beq       GoodNum   ; return successful parse
                    cmpa      #C$CR     ; accept command-line terminator
                    beq       GoodNum   ; return successful parse
                    bra       BadNum    ; reject any other trailing character

GoodNum             andcc     #^Carry   ; return with carry clear for parse success
                    rts                 ; return to caller

SkipSep             lda       ,x        ; read current parameter character
                    cmpa      #C$SPAC   ; check for a space separator
                    beq       SkipNext  ; skip spaces between values
                    cmpa      #C$COMA   ; check for a comma separator
                    bne       SkipDone  ; stop at the first non-separator
SkipNext            leax      1,x       ; advance past a separator
                    bra       SkipSep   ; continue skipping separators
SkipDone            rts                 ; return with A holding first non-separator

                    ifne      DOHELP
UsageMsg            fcc       "Usage: keyrpt <start> <speed>" ; usage text for bad arguments
                    fcb       C$CR      ; terminate usage line with carriage return
UsageLen            equ       *-UsageMsg ; compute usage message length
                    endc

                    emod
eom                 equ       *         ; mark end of module
                    end
