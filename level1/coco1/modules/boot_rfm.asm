********************************************************************
* Boot - RFM Boot Module
*
* Boots NitrOS-9 by fetching OS9Boot as a plain file from the
* DriveWire host via the VFM protocol, instead of reading 256-byte
* disk sectors from a virtual disk image.
*
* Protocol sequence:
*   1. OP_RFM / DW.Open  : open "OS9Boot" on the server
*   2. OP_RFM / DW.GetStt (SS.Size) : learn the file size
*   3. F$BtMem / F$SRqMem : allocate memory for the image
*   4. Loop OP_RFM / DW.Read : stream the file into RAM until EOF
*   5. OP_RFM / DW.Close : close the path
*   6. Return X=image ptr, D=size to kernel
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2026/06/14  Boisy G. Pitre
* Created.

                    nam       Boot
                    ttl       RFM Boot Module

                    ifp1
                    use       defsfile
                    use       drivewire.d
                    use       rfm.d
                    endc

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       0
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

* Stack frame — allocated off the hardware stack at boot time
                    org       0
blockimg            rmb       2                   pointer to start of loaded OS9Boot image
bootsize            rmb       2                   size of OS9Boot in bytes
rfmpacket           rmb       6                   VFM packet for RFM operations
response            rmb       4                   response from the server
size                equ       .

name                equ       *
                    fcs       /Boot/
                    fcb       edition

* VFM path number used for all RFM calls (arbitrary, must be non-zero only
* when the kernel is managing paths — 0 is safe here since boot predates the kernel)
RFMPATH             equ       0

* Maximum bytes to request per DW.Read call
CHUNKSIZE           equ       256

* Filename sent to the server — CR-terminated, no device prefix
BootFile            fcc       "OS9Boot"
                    fcb       C$CR
BootFileLen         equ       *-BootFile

BootError
                    coma
                    leas      size,s
                    rts

************************************************************
* Entry point — called by the kernel immediately after the
* boot module is located.
*
* Exit: X  = ptr to OS9Boot image in RAM
*       D  = image size in bytes
*       CC = carry clear (success) or set (error)
************************************************************
start
                    orcc      #IntMasks           IRQs off throughout boot

* Allocate stack frame and save its address in U
                    leas      -size,s
                    leau      0,s

* Initialize the DW hardware
                    lbsr      DWInit

* Step 1: Open "OS9Boot" on the server
************************************************************
* RFMOpen — open "OS9Boot" on the server
*
* Sends 6-byte header then the filename + CR.
* Receives 1-byte error code.
* Exit: carry clear = OK, set = error
************************************************************
RFMOpen
* Build and send the 6-byte VFM header:
*   [OP_VFM, DW.Open, path#, ppid=0, pid=0, mode=READ.]
* Push last byte first so OP_VFM ends up at the lowest stack address (= X).
                    lda       #READ.
                    sta       rfmpacket+5,u
                    clra
                    clrb
                    std       rfmpacket+3,u               ppid = 0, pid = 0
                    sta       rfmpacket+2,u               path# (always 0)
                    ldd       #OP_VFM*256+DW.Open
                    std       rfmpacket,u               OP_VFM  ← lowest address
                    leax      rfmpacket,u
                    ldy       #6
                    lbsr      DWWrite

* Send filename and CR terminator
                    leax      BootFile,pcr
                    ldy       #BootFileLen
                    lbsr      DWWrite

* Receive 1-byte response
                    leax      response,u
                    ldy       #1
                    lbsr      DWRead
                    ldb       ,x             B = error code (0 = success)
                    bne       BootError

* Step 2: Query file size via SS.Size GetStat; result in D
************************************************************
* RFMGetSize — query OS9Boot file size via SS.Size
*
* Sends 4-byte GetStat packet; receives 4-byte big-endian size.
* We keep only the low 16 bits (adequate for any practical boot image).
* Exit: D = size in bytes, carry clear = OK, set = error (size was 0)
************************************************************
RFMGetSize
* Build and send: [OP_VFM, DW.GetStt, path#, SS.Size]
                    lda       #SS.Size
                    sta       rfmpacket+3,u
                    ldd       #DW.GetStt*256
                    std       rfmpacket+1,u
                    leax      rfmpacket,u
                    ldy       #4
                    lbsr      DWWrite

* Receive 4-byte size: [MSW_hi, MSW_lo, LSW_hi, LSW_lo]
                    leax      response,u
                    ldy       #4
                    lbsr      DWRead
                    ldd       response+2,u                 low 16 bits of size
                    std       bootsize,u

* Step 3: Allocate memory for the image
                    pshs      u
                    ifgt      Level-1
                    os9       F$BtMem
                    else
                    os9       F$SRqMem
                    endc
                    tfr       u,x                U = ptr to allocated block
                    puls      u
                    bcs       bye
                    
* Save allocated-block address; recover frame pointer into U
                    stx       blockimg,u

* Step 4: Read the file into the allocated block
************************************************************
* RFMReadAll — stream the entire file into RAM
*
* Sends repeated DW.Read requests (binary, not ReadLn) until the
* server signals EOF with a zero count byte.
*
* Entry: blockimg,u = destination address
* Exit:  carry clear = OK
************************************************************
RFMReadAll
* Comment out next line since we fall through from above and X is already set
*                    ldx       blockimg,u          X = current write position

ReadChunk
* Build and send: [OP_VFM, DW.Read, path#, hi(CHUNKSIZE), lo(CHUNKSIZE)]
                    ldd       #CHUNKSIZE
                    std       rfmpacket+3,u
                    ldd       #DW.Read*256        RFM op + path# (0)
                    std       rfmpacket+1,u
                    pshs      x                   save write ptr across DWWrite
                    leax      rfmpacket,u               X → OP_VFM
                    ldy       #5
                    lbsr      DWWrite

* Receive 2-byte count (0 = EOF) — push X first to preserve write ptr
                    leax      response,u
                    ldy       #2
                    lbsr      DWRead
                    puls      x                 D = byte count (0 = EOF) and write pointer
                    ldd       response,u
                    cmpd      #0
                    beq       ReadDone            0 = EOF

* Receive D bytes of file data into the boot image.
* DWRead restores X to its entry value, so advance X by count manually.
                    tfr       d,y                 Y = count
                    lbsr      DWRead              reads Y bytes to X; X NOT advanced
                    ifgt      Level-1
                    lda       #'.
                    jsr       <D.BtBug            show progress dot
                    endc
                    ldd       response,u
                    leax      d,x                 X += count (advance write ptr)
                    bra       ReadChunk

ReadDone            

* Step 5: Close the path (ignore any error)
************************************************************
* RFMClose — close the VFM path
*
* Sends 3-byte close packet; receives and discards 1-byte response.
************************************************************
RFMClose
                    ldd       #DW.Close*256       RFM op + path# (0)
                    std       rfmpacket+1,u
                    leax      rfmpacket,u
                    ldy       #3
                    lbsr      DWWrite

* Receive and discard 1-byte response
                    leax      response,u
                    ldy       #1
                    lbsr      DWRead

* Return to kernel: X = image start, D = size, carry clear
                    ldx       blockimg,u
                    clrb
                    ldd       bootsize,u
bye                 leas      size,s            discard stack
                    rts


************************************************************
* Hardware init and DW I/O routines
************************************************************
                    use       dwinit.asm
                    use       dwread.asm
                    use       dwwrite.asm

                    ifgt      Level-1
Filler              fill      $39,$1D3-3-2-1-*
                    endc

                    emod
eom                 equ       *
                    end
