;;; F$PrsNam
;;;
;;; Parse a pathlist.
;;;
;;; Entry:  X = The address of the pathlist to parse.
;;;         U = Starting address of the routine’s memory area.
;;;
;;; Exit:   X = The address of the character past the optional "/".
;;;         Y = The address of the last character plus one.
;;;         A = The trailing delimiter character.
;;;         B = The length of the pathlist.
;;;        CC = Carry flag clear to indicate success.
;;;
;;; Error:  B = A non-zero error code.
;;;         Y = The address of the first non-delimiter character.
;;;        CC = Carry flag set to indicate error.
;;;
;;; F$PrsNam scans the input text string for a legal name. It terminates the name with any character that is not a legal name character.
;;; It's useful for processing pathlist arguments passed to a new process.
;;; Because it processes only one name, you need several calls to process a pathlist that has more than one name.
;;; F$PrsNam completes with Y in position for the next element in the pathlist to parse.
;;; If  Y is at the end of a pathlist, a bad path error returns.
;;; It then moves the pointer in Y past any space characters so that it can parse the next pathlist in a command line.
;;;
;;; Before the Parse Name call:
;;;
;;; |  /  |  D  |  0  |  /  |  P  |  A  |  Y  |  R  |  O  |  L  |  L  |
;;;    X
;;;
;;; After the Parse Name call:
;;;
;;; |  /  |  D  |  0  |  /  |  P  |  A  |  Y  |  R  |  O  |  L  |  L  |
;;;          X	     Y              B = 2


FPrsNam             equ       *         ; define assembler symbol
                  IFGT    Level-1 ; begin conditional assembly for Level-1
                    ldx       <D.Proc   ; get the process descriptor
                    leay      <P$DATImg,x ; and the DAT image pointer in it
                  ENDC
                    ldx       R$X,u     ; get the pathlist from the caller's X
                    bsr       ParseNam  ; parse the pathlist
                    std       R$D,u     ; D contains the length of the name; store it in the caller's D
                    bcs       FPrsnamHasEndName ; branch if an error occurred
                    stx       R$X,u     ; X contains the start of the name; store it in the caller's X
                    abx                 ; add the length in B to X
FPrsnamHasEndName   stx       R$Y,u     ; X contains the end of the name plus one; store it in the caller's Y
                    rts                 ; return to the caller

* Parse name
ParseNam            equ       *         ; define assembler symbol
                  IFGT    Level-1 ; begin conditional assembly for Level-1
                    pshs      y         ; save the DAT image pointer on the stack
                    lbsr      AdjBlk0   ; go find the map block
                  ENDC
                    pshs      x,y       ; save the offset within the block (X) and the block pointer (Y)
                    bsr       GoGetAXY  ; get the byte at X in block Y
                    cmpa      #'.       ; is the first character a period?
                    bne       IsSlash   ; no, do proper first character checking
                  IFGT    Level-1 ; begin conditional assembly for Level-1
                    lbsr      FLdMMUBlockData ; do a LDAXY, without changing X or Y
                  ELSE
                    lda       ,x        ; get the next character without moving past it
                  ENDC
                    bsr       ChkFirst  ; is the next character non-period?
                    lda       #'.       ; restore the period character the LDAXY destroyed
                    bcc       Do.Loop   ; if it's a non-period character, skip first character checks

IsSlash             cmpa      #PDELIM   ; is it a slash?
                    bne       NotSlash  ; no, keep X offset and block Y
                    bsr       GetChar   ; go get character
NotSlash            bsr       ChkFirst  ; check if we have a valid first character
                    bcs       NotValid  ; branch if it isn't valid
Do.Loop             clrb                ; initialize the character counter
LastLoop            incb                ; add one character
                    tsta                ; is it the last character of the name?
                    bmi       LastChar  ; yes, return valid
                    bsr       GoGetAXY  ; get next character
                    bsr       ChkValid  ; check if it's valid character
                    bcc       LastLoop  ; branch if valid
LastChar            andcc     #^Carry   ; else set the carry to indicate an error
                    bra       RtnValid  ; and return to the caller

GetChar
                    stx       2,s       ; save the current offset over the old offset
                    sty       4,s       ; save the current block pointer over the old block pointer
GoGetAXY            equ       *         ; define assembler symbol
                  IFGT    Level-1 ; begin conditional assembly for Level-1
                    lbra      LDAXY     ; get the byte at X in block Y in A, then return
                  ELSE
                    lda       ,x+       ; get the byte at X and move past it
                    rts                 ; return to the caller
                  ENDC

NextLoop            bsr       GetChar   ; get the next character
NotValid            cmpa      #',       ; is it a comma?
                    beq       NextLoop  ; yes, go get the next character
                    cmpa      #C$SPAC   ; is it a space?
                    beq       NextLoop  ; yes, go get the next character
                    comb                ; else set the carry to indicate an error condition
                    ldb       #E$BNam   ; 'Bad Name' error
RtnValid            equ       *         ; define assembler symbol
                    puls      x,y       ; recover tje offset & pointer
                  IFGT    Level-1 ; begin conditional assembly for Level-1
                    bra       FFmodulChar ; do a similar exit routine
                  ELSE
                    tfr       x,y       ; on an error Y is the first character that is not a separator
                    bcs       PrsNamEx  ; branch if an error occurred
                    abx                 ; add the length in B to X
                    exg       x,y       ; X is the start of the name and Y is the end of the name plus one
PrsNamEx            rts                 ; return to the caller
                  ENDC

ChkFirst            pshs      a         ; save the character
                    anda      #$7F      ; drop the most significant bit
                    bra       ChkRst    ; skip the dash for the first character check

* Determine if character in A is a valid filename character.
ChkValid            pshs      a         ; save the character
                    anda      #$7F      ; drop the most significant bit
                    cmpa      #'.       ; is it a period?
                    beq       ValidChr  ; yes, return valid character
ChkRest             cmpa      #'-       ; is it a dash?
                    beq       ValidChr  ; yes, it's valid
ChkRst              cmpa      #'z       ; is it greater than "z"?
                    bhi       InvalidC  ; yes, return an invalid character
                    cmpa      #'a       ; is it greater than or equal to "a"?
                    bhs       ValidChr  ; yes, return a valid character
                    cmpa      #'_       ; is it an underscore?
                    beq       ValidChr  ; yes, return a valid character
                    cmpa      #'Z       ; is it greater than "Z"?
                    bhi       InvalidC  ; yes, return an invalid character
                    cmpa      #'A       ; is it greater than or equal to "A"?
                    bhs       ValidChr  ; yes, return a valid character
                    cmpa      #'9       ; is it greater than "9"?
                    bhi       InvalidC  ; yes, return an invalid character
                    cmpa      #'0       ; is it greater than or equal to "0"?
                    bhs       ValidChr  ; yes, return a valid character
                    cmpa      #'$       ; is it a dollar symbol?
                    beq       ValidChr  ; yes, return a valid character
InvalidC            coma                ; else it's an invalid character; set the carry bit to indicate error
ValidChr            puls      a,pc      ; return to the caller
