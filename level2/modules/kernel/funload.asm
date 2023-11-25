**************************************************
* System Call: F$UnLoad
*
* Function: Unlink a module by name
*
* Input:  A = Module type
*         X = Pointer to module name
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FUnLoad        pshs      u                   preserve register stack pointer
               lda       R$A,u               get module type
               ldx       <D.Proc             get current process pointer
               leay      P$DATImg,x          point to DAT image
               ldx       R$X,u               get pointer to name
               os9       F$FModul            find it in module directory
               puls      y                   restore register stack pointer
               bcs       L0A4F               couldn't find it, return error
               stx       R$X,y               save update name pointer
               ifne      H6309
               ldw       MD$Link,u           get link count
               beq       L0A21               already 0 check if it's a I/O module
               decw                          subtract 1
               stw       MD$Link,u           save it back
               else      
               ldx       MD$Link,u           get module link count
               beq       L0A21               branch if zero
               leax      -1,x                else decrement
               stx       MD$Link,u
               endc      
               bne       L0A4E               not zero, don't remove from memory, return

* Link count is zero, check if module can be removed from memory
L0A21          cmpa      #FlMgr              is it a I/O module?
               blo       L0A4B               no, remove module from memory

* Special handling for I/O module deletion
               clra      
               ldx       [MD$MPDAT,u]        get 1st 2 blocks in DAT image of module
               ldy       <D.SysDAT           get pointer to system DAT image
L0A2B          adda      #2
               cmpa      #DAT.ImSz           done entire DAT?
               bcc       L0A4B               yes, delete the module from memory
               cmpx      a,y                 find block?
               bne       L0A2B               no, keep looking
               lsla                          multiply by 16 to calculate the offset
               lsla      
               lsla      
               lsla      
               clrb      
               addd      MD$MPtr,u           add in the pointer
               tfr       d,x                 copy it to X
               os9       F$IODel             delete the device from memory
               bcc       L0A4B               no error, skip ahead

               ifne      H6309
               ldw       MD$Link,u           put link count back
               incw      
               stw       MD$Link,u
               else      
               ldx       MD$Link,u           put link count back
               leax      1,x
               stx       MD$Link,u
               endc      
               rts                           Return with error

* Delete module from memory
L0A4B          lbsr      DelMod              Delete module from memory
L0A4E          clrb                          clear errors
L0A4F          rts                           return
