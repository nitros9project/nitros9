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


               ifgt      Level-1

FPrsNam        ldx       <D.Proc             get the process descriptor
               leay      <P$DATImg,x         and the DAT image pointer in it
               ldx       R$X,u               get the pathlist from the caller's X
               bsr       ParseNam            parse the pathlist
               std       R$D,u               D contains the length of the name; store it in the caller's D
               bcs       L073E               branch if an error occurred
               stx       R$X,u               X contains the start of the name; store it in the caller's X
               abx                           add the length in B to X
L073E          stx       R$Y,u               X contains the end of the name plus one; store it in the caller's Y
               rts                           return to the caller

* Parse name
ParseNam       equ       *
               pshs      y                   save the DAT image pointer on the stack
               lbsr      AdjBlk0             go find the map block
               pshs      x,y                 save the offset within the block (X) and the block pointer (Y)
               bsr       GoGetAXY            get the byte at X in block Y
               cmpa      #'.                 is the first character a period?
               bne       IsSlash             no, do proper first character checking
               lbsr      L0AC8               do a LDAXY, without changing X or Y
               bsr       ChkFirst            is the next character non-period?
               lda       #'.                 restore the period character the LDAXY destroyed
               bcc       Do.Loop             if it's a non-period character, skip first character checks

IsSlash        cmpa      #PDELIM             is it a slash?
               bne       NotSlash            no, keep X offset and block Y
               bsr       GetChar             go get character
NotSlash       bsr       ChkFirst            check if we have a valid first character
               bcs       NotValid            branch if it isn't valid
Do.Loop        clrb                          initialize the character counter
LastLoop       incb                          add one character
               tsta                          is it the last character of the name?
               bmi       LastChar            yes, return valid
               bsr       GoGetAXY            get next character
               bsr       ChkValid            check if it's valid character
               bcc       LastLoop            branch if valid
LastChar       andcc     #^Carry             else set the carry to indicate an error
               bra       RtnValid            and return to the caller

GetChar
               stx       2,s                 save the current offset over the old offset
               sty       4,s                 save the current block pointer over the old block pointer
GoGetAXY       lbra      LDAXY               get the byte at X in block Y in A, then return

NextLoop       bsr       GetChar             get the next character
NotValid       cmpa      #',                 is it a comma?
               beq       NextLoop            yes, go get the next character
               cmpa      #C$SPAC             is it a space?
               beq       NextLoop            yes, go get the next character
               comb                          else set the carry to indicate an error condition
               ldb       #E$BNam             'Bad Name' error
RtnValid       equ       *
               puls      x,y                 recover tje offset & pointer
               bra       L0720               do a similar exit routine

ChkFirst       pshs      a                   save the character
               anda      #$7F                drop the most significant bit
               bra       ChkRst              skip the dash for the first character check

* Determine if character in A is a valid filename character.
ChkValid       pshs      a                   save the character
               anda      #$7F                drop the most significant bit
               cmpa      #'.                 is it a period?
               beq       ValidChr            yes, return valid character
ChkRest        cmpa      #'-                 is it a dash?
               beq       ValidChr            yes, it's valid
ChkRst         cmpa      #'z                 is it greater than "z"?
               bhi       InvalidC            yes, return an invalid character
               cmpa      #'a                 is it greater than or equal to "a"?
               bhs       ValidChr            yes, return a valid character
               cmpa      #'_                 is it an underscore?
               beq       ValidChr            yes, return a valid character
               cmpa      #'Z                 is it greater than "Z"?
               bhi       InvalidC            yes, return an invalid character
               cmpa      #'A                 is it greater than or equal to "A"?
               bhs       ValidChr            yes, return a valid character
               cmpa      #'9                 is it greater than "9"?
               bhi       InvalidC            yes, return an invalid character
               cmpa      #'0                 is it greater than or equal to "0"?
               bhs       ValidChr            yes, return a valid character
               cmpa      #'$                 is it a dollar symbol?
               beq       ValidChr            yes, return a valid character
InvalidC       coma                          else it's an invalid character; set the carry bit to indicate error
ValidChr       puls      a,pc                return to the caller

               else

FPrsNam        ldx       R$X,u               get pathlist pointer from caller
               bsr       ParseNam            do the parsing of the name
               std       R$D,u               save the length
               bcs       ex@                 branch if the carry is set
               stx       R$X,u               save the updated pathlist pointer
ex@            sty       R$Y,u               and the Y
               rts                           return to the caller

ParseNam       lda       ,x                  get the first character
               cmpa      #PDELIM             is it the pathlist character?
               bne       next@               branch if not
               leax      1,x                 else go past it
next@          leay      ,x                  point Y to X
               clrb                          clear B
               lda       ,y+                 get the next character
               anda      #$7F                mask out the high bit
               bsr       chkrest@            go check the rest
               bcs       comma@              branch if the carry is set
loop@          incb                          increment B
               lda       -1,y                get the previous character
               bmi       ex@                 if high bit is set on this character, we're done
               lda       ,y+                 else get the next character
               anda      #$7F                clear the high bit
               bsr       chkfirst@           and check first
               bcc       loop@               branch if the carry is clear
               lda       ,-y                 else get the previous character
ex@            andcc     #^Carry             clear the carry
               rts                           return to the caller
comma@         cmpa      #C$COMA             is it a comma?
               bne       space@              branch if not
skip@          lda       ,y+                 else get the next character
space@         cmpa      #C$SPAC             is it a space?
               beq       skip@               branch if so
               lda       ,-y                 else get the previous character
               comb                          set the carry
               ldb       #E$BNam             indicate a bad pathname error
               rts                           and return to the caller
* Check for legal characters in a pathlist
chkfirst@      cmpa      #C$PERD             is the character a period?
               beq       Match               branch if so
chkrest@       cmpa      #'0                 is it zero?
               bcs       errex@              branch if less than
               cmpa      #'9                 is it a number?
               bls       Match               branch if it is between 0-9
               cmpa      #'_                 is it an underscore?
               beq       Match               branch if so
               cmpa      #'A                 is it A?
               bcs       errex@              branch if less than
               cmpa      #'Z                 is it Z?
               bls       Match               branch if less than or equal (A-Z)
               cmpa      #'a                 is it a?
               bcs       errex@              branch if less than
               cmpa      #'z                 is it z?
               bls       Match               branch if less than or equal (a-z)
errex@         orcc      #Carry              set the carry
               rts                           return to the caller

               endc
