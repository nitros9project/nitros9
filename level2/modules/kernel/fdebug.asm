******************************************************
* F$Debug entry point
*
* Enter the debugger (or reboot)
*
* Input:  A = Function code
*

FDebug              equ       *         ; define assembler symbol FDebug
* Determine if this is a system process or super user
* Only they have permission to reboot
                    lda       R$A,u     ; load A from R$A,u
                    cmpa      #255      ; reboot request
                    bne       leave     ; nope
                    ldx       <D.Proc   ; load X from <D.Proc
                    ldd       P$User,x  ; get user ID
                    beq       REBOOT    ; branch if zero is set to REBOOT
                    comb                ; update processor state
                    ldb       #E$UnkSvc ; load B from #E$UnkSvc
leave               rts                 ; return to caller

* NOTE: HIGHLY MACHINE DEPENDENT CODE!
* THIS CODE IS SPECIFIC TO THE COCO 3!
REBOOT              orcc      #IntMasks ; turn off IRQ's
                    clrb                ; clear B
                    stb       >DAT.Regs ; map in block 0
                    stb       >$0071    ; cold reboot
                    lda       #$38      ; bottom of DECB block mapping
                    sta       >DAT.Regs ; map in block zero
                    stb       >$0071    ; and cold reboot here, too
                    ldu       #$0000    ; force code to go at offset $0000
                    leax      ReBootLoc,pc ; reboot code
                    ldy       #CodeSize ; load Y from #CodeSize
cit.loop            lda       ,x+       ; load A from ,x+
                    sta       ,u+       ; store A at ,u+
                    leay      -1,y      ; compute -1,y into Y
                    bne       cit.loop  ; branch if zero is clear to cit.loop
                    clr       >$FEED    ; cold reboot
                    clr       >$FFD8    ; go to low speed
                    jmp       >$0000    ; jump to the reset code

ReBootLoc
                    ldd       #$3808    ; block $38, 8 times
                    ldx       #DAT.Regs ; where to put it
Lp                  sta       8,x       ; put into map 1
                    sta       ,x+       ; and into map 0
                    inca                ; increment A
                    decb                ; count down
                    bne       Lp        ; branch if zero is clear to Lp

                    lda       #$4C      ; standard DECB mapping
                    sta       >$FF90    ; store A at >$FF90
                    clr       >DAT.Task ; go to map type 0
                    clr       >$FFDE    ; and to all-ROM mode
                    ldd       #$FFFF    ; load D from #$FFFF
*         clrd              executes as CLRA on a 6809
                    fdb       $104F     ; define word value(s) $104F
                    tstb                ; is it a 6809?
                    bne       Reset     ; yup, skip ahead
*         ldmd  #$00        go to 6809 mode!
                    fcb       $11,$3D,$00 ; define byte value(s) $11,$3D,$00
Reset               jmp       [$FFFE]   ; do a reset
CodeSize            equ       *-ReBootLoc ; define assembler symbol CodeSize
