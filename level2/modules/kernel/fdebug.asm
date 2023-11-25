******************************************************
* F$Debug entry point
*
* Enter the debugger (or reboot)
*
* Input:  A = Function code
*

FDebug         equ       *
* Determine if this is a system process or super user
* Only they have permission to reboot
               lda       R$A,u
               cmpa      #255                reboot request
               bne       leave               nope
               ldx       <D.Proc
               ldd       P$User,x            get user ID
               beq       REBOOT
               comb      
               ldb       #E$UnkSvc
leave          rts       

* NOTE: HIGHLY MACHINE DEPENDENT CODE!
* THIS CODE IS SPECIFIC TO THE COCO 3!
REBOOT         orcc      #IntMasks           turn off IRQ's
               clrb      
               stb       >DAT.Regs           map in block 0
               stb       >$0071              cold reboot
               lda       #$38                bottom of DECB block mapping
               sta       >DAT.Regs           map in block zero
               stb       >$0071              and cold reboot here, too
               ldu       #$0000              force code to go at offset $0000
               leax      ReBootLoc,pc        reboot code
               ldy       #CodeSize
cit.loop       lda       ,x+
               sta       ,u+
               leay      -1,y
               bne       cit.loop
               clr       >$FEED              cold reboot
               clr       >$FFD8              go to low speed
               jmp       >$0000              jump to the reset code

ReBootLoc                
               ldd       #$3808              block $38, 8 times
               ldx       #DAT.Regs           where to put it
Lp             sta       8,x                 put into map 1
               sta       ,x+                 and into map 0
               inca      
               decb                          count down
               bne       Lp

               lda       #$4C                standard DECB mapping
               sta       >$FF90
               clr       >DAT.Task           go to map type 0
               clr       >$FFDE              and to all-ROM mode
               ldd       #$FFFF
*         clrd              executes as CLRA on a 6809
               fdb       $104F
               tstb                          is it a 6809?
               bne       Reset               yup, skip ahead
*         ldmd  #$00        go to 6809 mode!
               fcb       $11,$3D,$00
Reset          jmp       [$FFFE]             do a reset
CodeSize       equ       *-ReBootLoc
