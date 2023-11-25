;;; F$SSvc
;;;
;;; Add or replace system calls.
;;;
;;; Entry:  Y = The address of the system call initialization table.
;;;
;;; Exit:   None.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; F$SSvc adds or replaces system calls in the kernel's user and system mode system call tables. Y holds the address of a
;;; table that contains the function codes and offsets for system call routines. The table has the following format:
;;;
;;; Relative
;;; Address      Use
;;; ----------------------------------
;;;| $00	       Function code      |<-- First entry
;;;| $01         Offset from byte 3   |
;;;| $02         to function handler  |
;;;|..................................|
;;;| $03	       Function code      |	<-- Second entry
;;;| $04         Offset From byte 6   |
;;;| $05         to function handler  |
;;;|..................................|
;;;|                                  |
;;;|           More Entries           |
;;;|                                  |
;;;|..................................|
;;;|               $80                | End-of-table mark
;;; ----------------------------------
;;;
;;; If the most significant bit of the function code is set, the kernel updates the system table only; otherwise, both
;;; system and user tables are updated.
;;; The function request codes are in the range $29-$34. I/O calls are in the range $80-$90.
;;; To use a privileged system call, you must be executing a program that's executing in the system state.
;;; The system call handler routine must process the system call and return from the subroutine with an RTS instruction.
;;; The handler routing may alter all CPU registers, except SP.
;;; U holds the address of the register stack to the system call hander as shown in the following diagram:
;;;
;;;               Relative
;;;               Address     Name
;;; -----------------------------------
;;; U -->	CC        $00       R$CC
;;;          A        $01       R$A (R$D)
;;;          B        $02       R$B
;;;         DP        $03       R$DP
;;;          X        $04       R$X
;;;          Y        $06       R$Y
;;;          U        $08       R$U
;;;         PC        $0A       R$PC

FSSvc          ldy       R$Y,u               get pointer to table
               bra       InstallSvc          install the service
* Main move loop
loop@
               ifgt      Level-1
*>>>>>>>> Level 2
               clra                          clear the MSB of the table offset
               lslb                          multiply the function # by 2 to get the offset into the table
               tfr       d,u                 copy it to U
               ldd       ,y++                get the vector to the function handler
               leax      d,y                 offset X from current Y
               ldd       <D.SysDis           get the system dispatch table pointer
               stx       d,u                 save the vector into place
               bcs       InstallSvc          if it was a privileged call, skip ahead
               ldd       <D.UsrDis           else get the user dispatch table pointer
               stx       d,u                 and save the vector into place
*<<<<<<<< Level 2
               else
*>>>>>>>> Level 1
               tfr       b,a                 put the system call code in A
               anda      #$7F                kill the high bit
               cmpa      #$7F                is the system call code $7F? (I/O handler)
               beq       ok@                 branch if so
               cmpa      #$37                compare against highest call allowed
               bcs       ok@                 branch if less than or equal to the highest call
               comb                          else set the carry flag
               ldb       #E$ISWI             and indicate an illegal code
               rts                           return to the caller
ok@            lslb                          B = B * 2
               ldu       <D.SysDis           get the system dispatch table pointer
               leau      b,u                 U points to entry in table
               ldd       ,y++                get the address of the routine in the table
               leax      d,y                 set X to the absolute address
               stx       ,u                  and store in the system table
               bcs       InstallSvc          branch if this is a system service call only
               stx       <$70,u              else store in user table also
*<<<<<<<< Level 1
               endc
InstallSvc     ldb       ,y+                 get the system call code in B
               cmpb      #$80                are we at the end of the table?
               bne       loop@               branch if not
               rts                           return to the caller
