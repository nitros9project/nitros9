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
FCpyMem        ldd       R$Y,u               get byte count
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
L09C7          equ       *
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
L09FB          leas      <$14,s              Purge our stack buffer & return
               rts       

L0A01          clrb                          No error & exit
               rts       


               else      

* F$CpyMem for OS-9 Level Two
FCpyMem        ldd       R$Y,u               byte count
               beq       L0A01               ..skip if none
               addd      R$U,u               plus dest buff
               bcs       L0A01
               leas      -$10,s
               leay      ,s
               pshs      a,b,y               save buff end,img ptr
               ldx       <D.Proc
               ldb       P$Task,X
               pshs      b                   save caller task#
               leay      P$DATImg,x
               ldx       R$D,u               X=caller DAT img ptr
               ldb       #8
               pshs      b,u
               ldu       P$Task,s            U=tempdat ptr

L09C7          clra                          D=0000
               clrb      
               os9       F$LDDDXY            move user DAT image
               std       ,u++                to sys tempDAT img
               leax      2,x
               dec       ,s
               bne       L09C7               ..loop

               puls      b,u
               ldx       R$X,u               X=offset
               ldu       R$U,u               U=dest buffer
               ldy       3,s                 Y=tmpDAT

               puls      b
               bra       L09E7

N09D6          leax      $E000,x
               leay      2,y

*------------------------------------------------*
* Copy Loop:

L09E7          cmpx      #$2000
               bcc       N09D6

L09EC          os9       F$LDAXY             get byte
               leax      1,x
               exg       x,u

               os9       F$STABX             store byte
               leax      1,x                 plus one
               cmpx      ,s
               exg       x,u
               bcs       L09E7
               leas      $14,s

L0A01          clrb                          ok
               rts                           end.

               endc      
