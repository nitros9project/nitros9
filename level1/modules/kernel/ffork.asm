;;; F$Fork
;;;
;;; Links or loads a module and create a new process.
;;;
;;; Entry:  A = The type/language byte.
;;;         B = Size of the optional data area (in pages).
;;;         X = Address of the module name or filename.
;;;         Y = Size of the parameter area (in pages). The default is 0.
;;;         U = Starting address of the parameter area. This must be at least one page.
;;;
;;; Exit:   A = New process I/O number.
;;;         X = Address of the last byte of the name plus 1.
;;;        CC = Carry flag clear to indicate success.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; F$Fork creates a new child process of the calling process. It also sets up the child process’ memory,
;;; 6809 registers, and standard I/O paths.
;;;
;;; Upon success, X hold the address of the character past the name. For example, before the call:
;;;
;;;   X
;;;  _|__________________
;;; | T | E | S | T | \n |
;;;  --------------------
;;;
;;; And after the call:
;;;
;;;                    X
;;;  __________________|_
;;; | T | E | S | T | \n |
;;;  --------------------
;;;
;;; When the system call starts, it parses the passed name, then searches
;;; the module directory to see if the module is already in memory. If it is,
;;; then F$Fork calls F$Link and inserts it into the active process queue.
;;;
;;; If F$Link fails, then F$Fork calls F$Load to load the module from the current execution directory on the disk.
;;; It looks for a filename that matches the address of module name passed in X. If more than one module exists in the
;;; file, only the first one has its link count set. The first module in a file is the primary module.
;;;
;;; F$Fork then inspects the primary module to determine its data area, then allocates contiguous RAM for that amount.
;;; If the allocation succeeds, F$Fork copies the parameters at U into the data area, then sets the registers for the
;;; child process like this:
;;;
;;;   ------------------  <- Y (Highest address)
;;;  |  Parameter area  |
;;;  |------------------| <- X, SP
;;;  |                  |
;;;  |     Data area    |
;;;  |                  |
;;;  |------------------|
;;;  |                  |
;;;  |    Direct page   |
;;;  |                  |
;;;   ------------------  <- U, DP (Lowest address)
;;;
;;; D holds the size of the parameter area in bytes, the PC points to the primary module's execution entry point, and
;;; CC's FIRQ and IRQ mask flags are clear.
;;;
;;; Registers Y and U (the top-of-memory and bottom-of-memory pointers, respectively) always have values at page
;;; boundaries.
;;; If the parent process doesn't specify the size of the parameter area, the size defaults to zero.
;;; The minimum data area size is one page.
;;;
;;; When the shell processes a command line, it passes a string in the parameter area. The string is a copy of the parameter
;;; part of the command line. To simplify string-oriented processing, the shell also inserts an end-of-line character at the
;;; end of the parameter string.
;;;
;;; X points to the starting byte of the parameter string. If the command line includes the optional memory size specification
;;; (#n or #nK), the shell passes that size as the requested memory size when executing F$Fork.
;;;
;;; If any part of F$Fork is unsuccessful, it terminates and returns an error to the caller.
;;;
;;; The child and parent processes execute at the same time unless the parent calls F$Wait immediately after F$Fork.
;;; In this case, the parent waits until the child dies before it resumes execution.
;;;
;;; Be careful when recursively calling a program that uses F$Fork. Another new child process appears with each new execution
;;; and continues until the process table becomes full.
;;;
;;; Don't call F$Fork with a memory size of zero.

               ifeq      Level-1

FFork          ldx       <D.PrcDBT           get the pointer to the process descriptor table
               os9       F$All64             allocate a 64 byte page of RAM
               bcs       errex@              branch if error
               ldx       <D.Proc             get the parent (current) process descriptor
               pshs      x                   save it on the stack
               ldd       P$User,x            get the user ID of the parent process
               std       P$User,y            save it in the child process descriptor
               lda       P$Prior,x           get the priority of the parent process
               clrb                          B = 0
               std       P$Prior,y           store it in the child process descriptor
               ldb       #SysState           get system state flag into B
               stb       P$State,y           set the System State flag in the child process descriptor
               sty       <D.Proc             make the child process the current process
**** I/O related process descriptor setup
               ldd       <P$NIO,x            get the parent process' Net I/O pointer
               std       <P$NIO,y            save it in the child process descriptor
               ldd       <P$NIO+2,x          copy next two bytes
               std       <P$NIO+2,y          over to child process descriptor
               leax      <P$DIO,x            point X to the the parent process' Disk I/O section
               leay      <P$DIO,y            point Y to the child process' Disk I/O section
               ldb       #DefIOSiz           get the size of the section
loop@          lda       ,x+                 get byte at x and increment
               sta       ,y+                 save byte at y and increment
               decb                          decrement loop counter
               bne       loop@               branch if not done
* It so happens that X and Y are now pointing to P$PATH in the process descriptor, so
* there's no need to load them explicitly.
* Duplicate stdin/stdout/stderr.
               ldb       #$03                copy first three paths from parent to child
duploop@       lda       ,x+                 get next available path in parent process descriptor
               pshs      b                   save the count (fixes a bug where I$Dup will continue forever if IOMan is not installed)
               os9       I$Dup               duplicate it
               bcc       dupok@              branch if ok
               clra                          else if error, just make it zero
dupok@         sta       ,y+                 store it in the child process descriptor
               puls      b                   restore the count
               decb                          decrement the counter
               bne       duploop@            and branch back if not done
**** I/O related process descriptor setup
               bsr       SetupPrc            set up process
               bcs       ex@                 branch if an error occured
               puls      y                   get the parent process descriptor
               sty       <D.Proc             and make it the current process
               lda       P$ID,x              get the process ID of child process descriptor
               sta       R$A,u               store it in caller's A
               ldb       P$CID,y             get child ID of parent process descriptor
               sta       P$CID,y             store child process ID in parent's child process ID
               lda       P$ID,y              get process ID of parent process
               std       P$PID,x             store it in child's process descriptor
               ldb       P$State,x           update state of the child process descriptor
               andb      #^SysState          turn off system state
               stb       P$State,x           save back to process descriptor
               os9       F$AProc             insert the child process into active queue
               rts                           return to the caller
ex@            pshs      b                   save off B to stack
               os9       F$Exit              and exit
               comb                          set carry
               puls      x,b                 restore X and B
               stx       <D.Proc             save X to process descriptor
               rts                           return
errex@         comb                          set carry
               ldb       #E$PrcFul           error is process table is full
               rts                           and return

               else

FFork          pshs      u                   preserve register stack pointer
               lbsr      AllPrc              setup a new process descriptor
               bcc       GotNPrc             went ok, keep going
               puls      u,pc                restore & return with error

* Copy user # & priority
GotNPrc        pshs      u                   save pointer to new descriptor
               ldx       <D.Proc             get current process pointer
               ifne      H6309
               ldq       P$User,x            Get user # & priority from forking process
               std       P$User,u            Save user # in new process
               ste       P$Prior,u           Save priority in new process
               else
               ldd       P$User,x
               std       P$User,u
               lda       P$Prior,x
               sta       P$Prior,u
               endc
* Copy network I/O pointers to new descriptor
               ifeq      Network-1
               pshs      x,u
               leax      >P$NIO,x            point to current NIO pointers
               leau      >P$NIO,u            point to buffer for new ones
               ifne      H6309
               ldw       #NefIOSiz           get size
               tfm       x+,u+               move 'em
               else
               ldb       #NefIOSiz
L0250          lda       ,x+
               sta       ,u+
               decb
               bne       L0250
               endc
               puls      x,u                 restore pointers to descriptors
               endc
* Copy I/O pointers to new descriptor
               leax      P$DIO,x
               leau      P$DIO,u
               ifne      H6309
               ldw       #DefIOSiz
               tfm       x+,u+
* Copy Standard paths to new descriptor
               lde       #3                  get # paths
               else
               ldb       #DefIOSiz
L0261          lda       ,x+
               sta       ,u+
               decb
               bne       L0261
               ldy       #3
               endc

* Duplicate 1st 3 paths
GetOPth        lda       ,x+                 get a path #
               beq       SveNPth             don't exist, go on
               os9       I$Dup               dupe it
               bcc       SveNPth             no error, go on
               clra                          clear it

* As std in/out/err
SveNPth        sta       ,u+                 save new path #
               ifne      H6309
               dece                          done?
               else
               leay      -1,y
               endc
               bne       GetOPth             no, keep going
* Link to new module & setup task map
               ldx       ,s                  get pointer to new descriptor
               ldu       2,s                 get pointer to register stack
               lbsr      L04B1               link to module & setup register stack
               bcs       L02CF               exit if error
               pshs      d
               os9       F$AllTsk            allocate the task & setup MMU
               bcs       L02CF               Error, skip ahead

* Copy parameters to new process
               lda       P$PagCnt,x          get memory page count
               clrb
               subd      ,s                  calculate destination
               tfr       d,u                 set parameter destination pointer
               ldb       P$Task,x            get source task #
               ldx       <D.Proc             get destination task #
               lda       P$Task,x
               leax      ,y                  point to parameters
               puls      y                   restore parameter count
               os9       F$Move              move parameters to new process

* Setup the new stack
               ldx       ,s                  get pointer to process descriptor
               lda       <D.SysTsk           get task #
               ldu       P$SP,x              get new stack pointer
               leax      >(P$Stack-R$Size),x point to register stack
               ldy       #R$Size             get size of register stack
               os9       F$Move              move the register stack over
               puls      u,x
               os9       F$DelTsk
               ldy       <D.Proc
               lda       P$ID,x
               sta       R$A,u
               ldb       P$CID,y
               sta       P$CID,y
               lda       P$ID,y
               std       P$PID,x
               ifne      H6309
               aim       #^SysState,P$State,x switch to non-system state
               else
               lda       P$State,x
               anda      #^SysState
               sta       P$State,x
               endc
* Put date & time of creation into descriptor
*         pshs   x          preserve process pointer
*         leax   P$DatBeg,x point to time buffer
*         os9    F$Time     put date/time into it
*         puls   x          restore pointer
               os9       F$AProc             and start the process
               rts                           return

* Fork error goes here
L02CF          puls      x
               pshs      b                   save error
               lbsr      L05A5               close paths & unlink mem
               lda       P$ID,x              get bad ID
               lbsr      L0386               delete proc desc & task #
               comb                          set carry
               puls      pc,u,b              pull error code & u & return

               endc