;;; F$CmpNam
;;;
;;; Compare two names.
;;;
;;; Entry:  X = Address of the first name.
;;;         Y = Address of the second name.
;;;         B = Length of the first name.
;;;
;;; Exit: CC = Carry flag clear if names match; otherwise, set.
;;;
;;; F$CmpNam compares two names and indicates whether they match. Use this call with F$PrsNam. The second name
;;; must have the most significant bit (bit 7) of the last character set.

               ifgt      Level-1

* User state entry
               ldy       M$Size,x            get module size in module header
FCmpNam        ldx       <D.Proc             get current process ptr
               leay      P$DATImg,x          point to the DAT image
               ldx       R$X,u               get pointer to the first name
               pshs      y,x                 preserve 'em
               bra       GetName2
* System state entry
FSCmpNam       ldx       <D.Proc             get current process descriptor pointer
               leay      P$DATImg,x          point to its DAT image
               ldx       R$X,u               get pointer to the first name
               pshs      x,y
               ldy       <D.SysDAT           get pointer to system DAT
GetName2       ldx       R$Y,u               get pointer to the second name
               pshs      y,x                 preserve them
               ldd       R$D,u               get length
               leax      4,s                 point to the first name's info packet
               leay      ,s                  point to the second name's info packet
               bsr       L07DE               go compare 'em
               leas      8,s                 purge stack
               rts                           return to caller

* Compare 2 names
*
* Input:  D = Length of the first name (only requires B)
*         X = Pointer to the first name's info packet
*             0,X = DAT image pointer
*             2,X = Pointer to name
*         Y = Pointer to the second name's info packet
*             0,Y = DAT image pointer
*             2,Y = Pointer to name
*         U = Register stack ptr
L07DE          pshs      d,x,y,u             preserve registers
               tfr       x,u                 U=pointer to the first name packet
               pulu      x,y                 get DAT pointer to Y and name pointer to X
               lbsr      AdjBlk0             adjust X to use block 0
               pshu      x,y                 put them back
               ldu       4,s                 get pointer to the second name's packet
               pulu      x,y                 get DAT pointer to Y and name pointer to X
               lbsr      AdjBlk0             adjust X to block 0
               bra       L07F6               go compare the names

L07F2          ldu       4,s                 get pointer to second name's packet
               pulu      x,y                 get DAT pointer to Y and name pointer to X
L07F6          lbsr      LDAXY               map in the block & grab a byte from name
               pshu      x,y                 put updated DAT & name pointer back
               pshs      a                   save the character
               ldu       3,s                 pointer to the first name packet
               pulu      x,y                 get DAT pointer to Y and name pointer to X
               lbsr      LDAXY               get byte from the first name
               pshu      y,x                 put pointers back
               eora      ,s
               tst       ,s+                 was it high bit?
               bmi       L0816               yes, check if last character in the second name
               decb      
               beq       L0813
               anda      #$DF                match?
               beq       L07F2               yes, check next character
L0813          comb                          set carry
               puls      d,x,y,u,pc

L0816          decb                          done whole name?
               bne       L0813               no, exit with no match
               anda      #$5F                match?
               bne       L0813               yes, keep checking
               clrb                          names match, clear carry
               puls      d,x,y,u,pc          restore & return to caller

               else      

;;; F$CmpNam
;;;
;;; Compare two names for a match.
;;;
;;; Entry:  B = The length of the first name.
;;;         X = The address of the first name.
;;;         Y = The address of the second name.
;;;
;;; Exit:  CC = Carry flag clear if names match; set if names don't match.
;;;
;;; F$CmpNam compares two names and indicates whether they match. Use this call with F$PrsNam. The second name
;;; must have the most significant bit of the last character set.

FCmpNam        ldb       R$B,u               get length of the first name
               leau      R$X,u               point U to the caller's R$X
               pulu      y,x                 load caller's R$X and R$Y into X and Y in one call
CmpNam         pshs      y,x,b,a             save registers
loop@          lda       ,y+                 get character of second name and increment pointer
               bmi       hibitset@           branch if hi-bit set
               decb                          decrement length
               beq       nomatch@            if counter is zero, length is different, so not a match
               eora      ,x+                 XOR with character in same position from first name and increment pointer
               anda      #$DF                make result case insensitive
               beq       loop@               if zero, characters match, so continue to next character
nomatch@       orcc      #Carry              set carry to indicate no match
               puls      pc,y,x,b,a          restore registers and return to caller
hibitset@      decb                          more?
               bne       nomatch@            branch if so, length is different so not a match.
               eora      ,x                  XOR with character in same position from first name
               anda      #$5F                make result case insensitive
               bne       nomatch@            if not zero, not a match
               puls      y,x,b,a             restore registers
Match          andcc     #^Carry             clear carry to indicate a match
               rts                           return to caller

               endc      
