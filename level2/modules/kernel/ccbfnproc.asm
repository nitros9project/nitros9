**************************************************
* System Call: F$NProc
*
* Function: Start the next process in the active queue
*
* Input:  None
*
* Output: Control does not return to the caller
*
FNProc                   
               ifgt      Level-1
               ldx       <D.SysPrc           get system process descriptor
               stx       <D.Proc             save it as current
               lds       <D.SysStk           get system stack pointer
               andcc     #^IntMasks          re-enable IRQ's (to allow pending one through)
               else      
               clra      
               clrb      
               std       <D.Proc
               endc      
               fcb       $8C                 skip the next 2 bytes

L0D91          cwai      #^IntMasks          re-enable IRQ's and wait for one
L0D93          orcc      #IntMasks           Shut off interrupts again
               lda       #Suspend            get suspend suspend state flag
               ldx       #D.AProcQ-P$Queue   For start of loop, setup to point to current process

* Loop to find next active process that is not Suspended
L0D9A          leay      ,x                  Point y to previous link (process dsc. ptr)
               ldx       P$Queue,y           Get process dsc. ptr for next active process
               beq       L0D91               None, allow any pending IRQ thru & try again
               bita      P$State,x           There is one, is it Suspended?
               bne       L0D9A               Yes, skip it & try next one

* Found a process in line ready to be started
               ldd       P$Queue,x           Get next process dsc. ptr in line after found one
               std       P$Queue,y           Save the next one in line in previous' next ptr
               stx       <D.Proc             Make new process dsc. the current one
               lbsr      L0C58               Go check or make a task # for the found process
               bcs       L0D83               Couldn't get one, go to next process in line
               lda       <D.TSlice           Reload # ticks this process can run
               sta       <D.Slice            Save as new tick counter for process
               ldu       P$SP,x              get the process stack pointer
               lda       P$State,x           get it's state
               lbmi      L0E29               If in System State, switch to system task (0)
L0DB9          bita      #Condem             Was it condemned by a deadly signal?
               bne       L0DFD               Yes, go exit with Error=the signal code #
               lbsr      TstImg              do a F$SetTsk if the ImgChg flag is set
L0DBD          ldb       <P$Signal,x         any signals?
               beq       L0DF7               no, go on
               decb                          is it a wake up signal?
               beq       L0DEF               yes, go wake it up
               leas      -R$Size,s           make a register buffer on stack
               leau      ,s                  point to it
               lbsr      L02CB               copy the stack from process to our copy of it
               lda       <P$Signal,x         get last signal
               sta       R$B,u               save it to process' B

               ldd       <P$SigVec,x         any intercept trap?
               beq       L0DFD               no, go force the process to F$Exit
               std       R$PC,u              save vector to it's PC
               ldd       <P$SigDat,x         get pointer to intercept data area
               std       R$U,u               save it to it's U
               ldd       P$SP,x              get it's stack pointer
               subd      #R$Size             take off register stack
               std       P$SP,x              save updated SP
               lbsr      L02DA               Copy modified stack back overtop process' stack
               leas      R$Size,s            purge temporary stack
L0DEF          clr       <P$Signal,x         clear the signal

* No signals go here
L0DF7          equ       *
               ifne      H6309
               oim       #$01,<D.Quick
               else      
               ldb       <D.Quick
               orb       #$01
               stb       <D.Quick
               endc      
BackTo1        equ       *
L0DF2          ldu       <D.UsrSvc           Get current User's system call service routine ptr
               stu       <D.XSWI2            Save as SWI2 service routine ptr
               ldu       <D.UsrIRQ           Get IRQ entry point for user state
               stu       <D.XIRQ             Save as IRQ service routine ptr

               ldb       P$Task,x            get task number
               lslb                          2 bytes per entry in D.TskIpt
               ldy       P$SP,x              get stack pointer
               lbsr      L0E8D               re-map the DAT image, if necessary

               ldb       <D.Quick            get quick return flag
               lbra      L0E4C               Go switch GIME over to new process & run

* Process a signal (process had no signal trap)
L0DFD          equ       *
               ifne      H6309
               oim       #SysState,P$State,x Put process into system state
               else      
               ldb       P$State,x
               orb       #SysState
               stb       P$State,x
               endc      
               leas      >P$Stack,x          Point SP to process' stack
               andcc     #^IntMasks          Turn interrupts on
               ldb       <P$Signal,x         Get signal that process received
               clr       <P$Signal,x         Clear out the one in process dsc.
               os9       F$Exit              Exit with signal # being error code

S.SvcIRQ       jmp       [>D.Poll]           Call IOMAN for IRQ polling
