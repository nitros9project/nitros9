**************************************************
* System Call: F$Fork
*
* Function: Starts a new child process
*
* Input:  X = Address of module or filename
*         Y = Parameter area size (256 byte pages)
*         U = Address of parameter area
*         A = Language/Type code
*         B = Optional data area size (256 byte pages)
*
* Output: X = Updated past the name string
*         A = Child's process ID
*
* Error:  CC = C bit set; B = error code
*
FFork               pshs      u                   preserve register stack pointer
                    lbsr      AllPrc              setup a new process descriptor
                    bcc       GotNPrc             went ok, keep going
                    puls      u,pc                restore & return with error

* Copy user # & priority
GotNPrc             pshs      u                   save pointer to new descriptor
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
L0250               lda       ,x+
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
L0261               lda       ,x+
                    sta       ,u+
                    decb
                    bne       L0261
                    ldy       #3
                    endc

* Duplicate 1st 3 paths
GetOPth             lda       ,x+                 get a path #
                    beq       SveNPth             don't exist, go on
                    os9       I$Dup               dupe it
                    bcc       SveNPth             no error, go on
                    clra                          clear it

* As std in/out/err
SveNPth             sta       ,u+                 save new path #
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
L02CF               puls      x
                    pshs      b                   save error
                    lbsr      L05A5               close paths & unlink mem
                    lda       P$ID,x              get bad ID
                    lbsr      L0386               delete proc desc & task #
                    comb                          set carry
                    puls      pc,u,b              pull error code & u & return
