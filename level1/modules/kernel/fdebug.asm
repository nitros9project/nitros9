;;; F$Debug
;;;
;;; Enter the debugger, or reboot.
;;;
;;; Entry:  A = Function code.
;;;
;;; Exit:   None.
;;;
;;; F$Debug requires super user privileges; if a non-super user calls F$Debug, it immediately returns.
;;;
;;; Current valid function codes are:
;;    255 = Reboot the computer

FDebug                   
* Determine if this is a system process or super user
* Only they have permission to reboot
               lda       R$A,u               get the function code
               cmpa      #255                is it a reboot request?
               bne       DebugEx@            branch if not
               ldx       <D.Proc             ... else get current process descriptor
               ldd       P$User,x            and obtain user ID
               beq       Reboot              reboot only if super user
               comb                          else set carry
               ldb       #E$UnkSvc           load error
DebugEx@       rts                           return to caller

* NOTE: HIGHLY MACHINE DEPENDENT CODE!
* THIS CODE IS SPECIFIC TO THE COCO!
Reboot         orcc      #IntMasks           mask interrupts
*         clrb
*         stb   >$FFA0              map in block 0
*         stb   >$0071              cold reboot
*         lda   #$38                bottom of DECB block mapping
*         sta   >$FFA0              map in block zero
               stb       >$0071              cold reboot BASIC
               ldu       #$0000              force code to go at offset $0000
               leax      ReBootLoc,pc        point to reboot code
               ldy       #CodeSize           and get size
RCpLoop@       lda       ,x+
               sta       ,u+
               leay      -1,y
               bne       RCpLoop@
*         clr   >$FEED     cold reboot
*         clr   >$FFD8     go to low speed
               jmp       >$0000              jump to the reset code

ReBootLoc                
*         ldd   #$3808       block $38, 8 times
*         ldx   #$FFA0       where to put it
*Lp       sta   8,x        put into map 1
*         sta   ,x+        and into map 0
*         inca
*         decb             count down
*         bne   Lp

*         lda   #$4C       standard DECB mapping
*         sta   >$FF90
*         clr   >$FF91     go to map type 0
               clr       >$FFDE              and to all-ROM mode
               ldd       #$FFFF
*         clrd               executes as CLRA on a 6809
               fdb       $104F               'clrd' executes as a 'clra' on a 6809
               tstb                          is it a 6809?
               bne       Reset               yup, skip ahead
               fcb       $11,$3D,$00         this is a 'ldmd #$00' to go into 6809 mode
Reset          jmp       [$FFFE]             perform a complete reset
CodeSize       equ       *-ReBootLoc

