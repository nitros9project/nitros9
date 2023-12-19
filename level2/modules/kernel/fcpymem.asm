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
                    ifne      H6309
* F$CpyMem for NitrOS-9 Level Two
* Notes:
* We currently check to see if the end of the buffer we are
* copying to will overflow past $FFFF, and exit if it does.
* Should this be changed to check if it overflows past the
* data area of a process, or at least into Vector page RAM
* and I/O ($FE00-$FFFF)???
*
FCpyMem             ldd       R$Y,u               get byte count
                    beq       L0A01               nothing there so nothing to move, return
                    addd      R$U,u               add it caller's buffer start ptr.
                    cmpa      #$FE                Is it going to overwrite Vector or I/O pages?
                    bhs       L0A01               Yes, exit without error
                    leas      -$10,s              make a buffer for DAT image
                    leay      ,s                  point to it
                    pshs      y,u                 Preserve stack buffer ptr & register stack pointer
                    ldx       <D.Proc             Get caller's task #
                    ldf       P$Task,x            get task # of caller
                    leay      P$DATImg,x          Point to DAT image in callers's process dsc.
                    ldx       R$D,u               get caller's DAT image pointer
                    lde       #$08                counter (for double byte moves)
                    ldu       ,s                  get temp. stack buffer pointer

* This loop copies the DAT image from the caller's process descriptor into
* a temporary buffer on the stack
L09C7               equ       *
                    clrd                          Clear offset to 0
                    bsr       L0B02               Short cut OS9 F$LDDDXY
                    std       ,u++                save it to buffer
                    leax      2,x                 Bump ptr
                    dece                          Decrement loop counter
                    bne       L09C7               Keep doing until 16 bytes is done

                    ldu       2,s                 Get back register stack pointer
                    lbsr      L0CA6               Short cut OS9 F$ResTsk
                    bcs       L09FB               If error, deallocate our stack & exit with error
                    tfr       b,e                 New temp task # into E
                    lslb                          Multiply by 2 for 2 byte entries
                    ldx       <D.TskIPt           Get ptr to task image table
* Make new temporary task use the memory blocks from the requested DAT image
*   from the caller, to help do a 1 shot F$Move command, because in general
* the temporary DAT image is not associated with a task.
                    ldu       ,s                  Get pointer to DAT image we just copied
                    stu       b,x                 Point new task image table to our DAT image copy
                    ldu       2,s                 Get back data area pointer
                    tfr       w,d                 Move temp & caller's task #'s into proper regs.
                    pshs      a                   Save new task #
                    bsr       L0B25               F$Move the memory into the caller's requested area
* BAD Bug! Well, maybe not.  F$Move NEVER returns an error code
* but if it did, we'd skip the $RelTsk, and have an orphan task
* left over.
*         bcs   L09FB        If error, purge stack & return with error code
                    puls      b                   Get back new task #
                    lbsr      L0CC3               Short cut OS9 F$RelTsk
L09FB               leas      <$14,s              Purge our stack buffer & return
                    rts

L0A01               clrb                          No error & exit
                    rts


                    else

* F$CpyMem for OS-9 Level Two- 6809 - for back in KRN
* Entry: U=ptr to stack contents from caller (parameters)
FCpyMem             ldd       R$Y,u               Get # of bytes to copy
                    beq       L0A01               If 0, exit
                    addd      R$U,u               plus dest buff
* LCB - Added check to match 6309 version
                    cmpa      #$FE                Is it going to overwrite Vector or I/O pages?
                    bhs       L0A01               Yes, exit without error
                    leas      -$10,s              Make room on stack for temp DAT image
                    leay      ,s                  Point to it
                    pshs      y,u                 Save temp DAT img & register stack ptrs
                    ldx       <D.Proc             Get current process descriptor ptr
                    lda       #8                  # of 16 bit words to copy
                    ldb       P$Task,x            Get current process;s task #
                    pshs      d                   save ctr & caller task #
                    leay      P$DATImg,x          Point to DAT image of caller
                    ldx       R$D,u               Get caller's ptr to the DAT image they provided
                    ldu       2,s                 Get temp DAT IMG Ptr
L09C7               clra                          Set offset to offset to 0
                    clrb
                    bsr       L0B02               Short cut OS9 F$LDDDXY
                    std       ,u++                to our temp DAT img
                    leax      2,x                 2 bytes per entry
                    dec       ,s                  copy all 8 sets of 2 bytes
                    bne       L09C7
                    ldu       4,s                 get callers register stack pr back
                    lbsr      L0CA6               short cut os9 F$ResTsk (returns in B, destroys A)
                    bcs       L09FB               If error, deallocate our stack & exit with error
                    stb       ,s                  Save copy of new temp task # (overtop temp ctr)
* 0,s   =new temp task #
* 1,s   =task # of caller
* 2-3,s =temp DAT image buffer ptr
* 4-5,s =callers register stack ptr
* 6-21,s=temp DAT image
                    lslb                          *2 for 2 byte entries
                    ldx       <D.TskIPt           Get ptr to task image table
* Use new temporary task for 1 shot F$Move command
                    ldu       2,s                 Get ptr to DAT image we just copied
                    stu       b,x                 Point new task image table to our DAT image copy
                    ldu       4,s                 Get back callers register stack ptr
                    ldd       ,s+                 A=temp task #,B=callers task #, eat temp task#
* 0,s   =task # of caller
* 1-2,s =temp DAT image buffer ptr
* 3-4,s =callers register stack ptr
* 5-20,s=temp DAT image
                    sta       ,s                  Save temp task #
                    bsr       L0B25               Shortcut F$Move memory into callers requested area
                    puls      b                   get back temp task #
                    lbsr      L0CC3               Shortcut OS9 F$RelTsk
                    leas      -2,s                Adjust stack for fall thru
L09FB               leas      $16,s               Purge our stack buffer ptr & return
                    rts

L0A01               clrb
                    rts
                    ENDC
