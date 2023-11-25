               section   code

* DWDiskInit - Initialize DriveWire.
*
DWDiskInit     lbsr      DWInit              initialize F256 hardware
* Send initialization opcode to host
               lda       #OP_INIT            load the op-code
               pshs      a                   save it on the stack
               leax      ,s                  point X to the stack
               ldy       #$0001              we want to write one byte
               lbsr      DWWrite             write it to the host
               leax      opreadexbuffer,u    point X to the read buffer
               stx       blockloc,u          store it in the static storage
               puls      a,pc                and return

* DWDiskRead - Read a 256 byte sector from a DriveWire host.
*
*   Entry: B = bits 23-16 of LSN
*          X = bits 15-0  of LSN
*          blockloc,u = ptr to 256 byte sector
*
*   Exit:  X = ptr to data (i.e. ptr in blockloc,u)
*          Carry Clear = OK, Set = Error
*
DWDiskRead               
               pshs      cc,d,x              preserve registers
* Send out op code and 3 byte LSN
               lda       #OP_READEX          load A with READ opcode
Read2          ldb       #0                  drive number
               std       ,s                  store on stack
               leax      ,s                  point to bytes on stack
               ldy       #5                  all five of them
               lbsr      DWWrite             send to the host
* Get 256 bytes of sector data
               ldx       blockloc,u          get the read buffer pointer
               ldy       #256                load the number of bytes we want to read
               lbsr      DWRead              read bytes from host
               bcs       reader@             branch if checksum error
               bne       reader2@            branch if not all bytes received
* Send two byte checksum
               pshs      y                   save the 2 bytes of checksum on the stack
               leax      ,s                  point to the stack
               ldy       #2                  load the counter to write
               lbsr      DWWrite             write the checksum
               ldy       #1                  load the counter to read
               lbsr      DWRead              read the response from the host
               leas      2,s                 point recover the stack
               bcs       readex@             branch if error
               bne       reader2@            branch if error
               ldb       ,s                  get the host's response to our checksum
               beq       readex@             branch if 0
               cmpb      #E_CRC              is it a CRC error?
               bne       reader@             branch if not
               lda       #OP_REREADEX        else perform a re-read
               bra       Read2               and go do it
readex@        leas      5,s                 clean up stack
               ldx       blockloc,u          get the block pointer
               clrb                          clear carry
               rts                           return
reader2@       ldb       #E$Read             return a read error code
reader@        leas      5,s                 clean up stack
               orcc      #Carry              set the carry
               rts                           return

               use       ../level1/f256/modules/dwinit_f256.asm
               use       ../level1/f256/modules/dwread_f256.asm
               use       ../level1/f256/modules/dwwrite_f256.asm

               endsect   
