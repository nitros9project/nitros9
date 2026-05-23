**************************************************
* System Call: F$CpyMem
*
* Function: Copy external memory
*
* Input:  D = Starting memory block number
*         X = Offset in block to begin copy
*         Y = Byte count
*         U = Caller's destination buffer
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
                  IFNE    H6309   ; begin conditional assembly for H6309
* F$CpyMem for NitrOS-9 Level Two
* Notes:
* We currently check to see if the end of the buffer we are
* copying to will overflow past $FFFF, and exit if it does.
* Should this be changed to check if it overflows past the
* data area of a process, or at least into Vector page RAM
* and I/O ($FE00-$FFFF)???
*
FCpyMem             ldd       R$Y,u     ; get byte count
                    beq       L0A01     ; nothing there so nothing to move, return
                    addd      R$U,u     ; add it caller's buffer start ptr.
                    cmpa      #$FE      ; is it going to overwrite Vector or I/O pages?
                    bhs       L0A01     ; yes, exit without error
                    leas      -$10,s    ; make a buffer for DAT image
                    leay      ,s        ; point to it
                    pshs      y,u       ; preserve stack buffer ptr & register stack pointer
                    ldx       <D.Proc   ; get caller's task #
                    ldf       P$Task,x  ; get task # of caller
                    leay      P$DATImg,x ; point to DAT image in callers's process dsc.
                    ldx       R$D,u     ; get caller's DAT image pointer
                    lde       #$08      ; counter (for double byte moves)
                    ldu       ,s        ; get temp. stack buffer pointer

* This loop copies the DAT image from the caller's process descriptor into
* a temporary buffer on the stack
L09C7               equ       *         ; define assembler symbol L09C7
                    clrd                ; clear offset to 0
                    bsr       L0B02     ; short cut OS9 F$LDDDXY
                    std       ,u++      ; save it to buffer
                    leax      2,x       ; bump ptr
                    dece                ; decrement loop counter
                    bne       L09C7     ; keep doing until 16 bytes is done

                    ldu       2,s       ; get back register stack pointer
                    lbsr      L0CA6     ; short cut OS9 F$ResTsk
                    bcs       L09FB     ; if error, deallocate our stack & exit with error
                    tfr       b,e       ; new temp task # into E
                    lslb                ; multiply by 2 for 2 byte entries
                    ldx       <D.TskIPt ; get ptr to task image table
* Make new temporary task use the memory blocks from the requested DAT image
*   from the caller, to help do a 1 shot F$Move command, because in general
* the temporary DAT image is not associated with a task.
                    ldu       ,s        ; get pointer to DAT image we just copied
                    stu       b,x       ; point new task image table to our DAT image copy
                    ldu       2,s       ; get back data area pointer
                    tfr       w,d       ; move temp & caller's task #'s into proper regs.
                    pshs      a         ; save new task #
                    bsr       L0B25     ; f$Move the memory into the caller's requested area
* BAD Bug! Well, maybe not.  F$Move NEVER returns an error code
* but if it did, we'd skip the $RelTsk, and have an orphan task
* left over.
*         bcs   L09FB        If error, purge stack & return with error code
                    puls      b         ; get back new task #
                    lbsr      L0CC3     ; short cut OS9 F$RelTsk
L09FB               leas      <$14,s    ; purge our stack buffer & return
                    rts                 ; return to caller

L0A01               clrb                ; no error & exit
                    rts                 ; return to caller


                  ELSE

* F$CpyMem for OS-9 Level Two- 6809 - for back in KRN
* Entry: U=ptr to stack contents from caller (parameters)
FCpyMem             ldd       R$Y,u     ; get # of bytes to copy
                    beq       L0A01     ; if 0, exit
                    addd      R$U,u     ; plus dest buff
* LCB - Added check to match 6309 version
                    cmpa      #$FE      ; is it going to overwrite Vector or I/O pages?
                    bhs       L0A01     ; yes, exit without error
                    leas      -$10,s    ; make room on stack for temp DAT image
                    leay      ,s        ; point to it
                    pshs      y,u       ; save temp DAT img & register stack ptrs
                    ldx       <D.Proc   ; get current process descriptor ptr
                    lda       #8        ; # of 16 bit words to copy
                    ldb       P$Task,x  ; get current process;s task #
                    pshs      d         ; save ctr & caller task #
                    leay      P$DATImg,x ; point to DAT image of caller
                    ldx       R$D,u     ; get caller's ptr to the DAT image they provided
                    ldu       2,s       ; get temp DAT IMG Ptr
L09C7               clra                ; set offset to offset to 0
                    clrb                ; clear B
                    bsr       L0B02     ; short cut OS9 F$LDDDXY
                    std       ,u++      ; to our temp DAT img
                    leax      2,x       ; 2 bytes per entry
                    dec       ,s        ; copy all 8 sets of 2 bytes
                    bne       L09C7     ; branch if zero is clear to L09C7
                    ldu       4,s       ; get callers register stack pr back
                    lbsr      L0CA6     ; short cut os9 F$ResTsk (returns in B, destroys A)
                    bcs       L09FB     ; if error, deallocate our stack & exit with error
                    stb       ,s        ; save copy of new temp task # (overtop temp ctr)
* 0,s   =new temp task #
* 1,s   =task # of caller
* 2-3,s =temp DAT image buffer ptr
* 4-5,s =callers register stack ptr
* 6-21,s=temp DAT image
                    lslb                ; *2 for 2 byte entries
                    ldx       <D.TskIPt ; get ptr to task image table
* Use new temporary task for 1 shot F$Move command
                    ldu       2,s       ; get ptr to DAT image we just copied
                    stu       b,x       ; point new task image table to our DAT image copy
                    ldu       4,s       ; get back callers register stack ptr
                    ldd       ,s+       ; A=temp task #,B=callers task #, eat temp task#
* 0,s   =task # of caller
* 1-2,s =temp DAT image buffer ptr
* 3-4,s =callers register stack ptr
* 5-20,s=temp DAT image
                    sta       ,s        ; save temp task #
                    bsr       L0B25     ; shortcut F$Move memory into callers requested area
                    puls      b         ; get back temp task #
                    lbsr      L0CC3     ; shortcut OS9 F$RelTsk
                    leas      -2,s      ; adjust stack for fall thru
L09FB               leas      $16,s     ; purge our stack buffer ptr & return
                    rts                 ; return to caller

L0A01               clrb                ; clear B
                    rts                 ; return to caller
                  ENDC
