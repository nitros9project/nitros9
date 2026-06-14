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
                    tfr       s,u
                    pshs      u                   keep frame ptr on stack for later restore

* Initialize the DW hardware (bit-banger or Becker port, selected at assembly time)
                    ldy       Address,pcr
                    lbsr      HWInit

* Step 1: Open "OS9Boot" on the server
                    lbsr      RFMOpen
                    bcs       BootError

* Step 2: Query file size via SS.Size GetStat; result in D
                    lbsr      RFMGetSize
                    bcs       BootError
                    std       bootsize,u

* Step 3: Allocate memory for the image
                    ifgt      Level-1
                    os9       F$BtMem
                    else
                    os9       F$SRqMem
                    endc
                    bcs       BootError

* Save allocated-block address; recover frame pointer into U
                    tfr       u,d                 D = ptr to allocated block
                    ldu       ,s                  recover frame ptr
                    std       blockimg,u

* Step 4: Read the file into the allocated block
                    lbsr      RFMReadAll
                    bcs       BootError

* Step 5: Close the path (ignore any error)
                    lbsr      RFMClose

* Return to kernel: X = image start, D = size, carry clear
                    ldx       blockimg,u
                    ldd       bootsize,u
                    clrb
                    leas      2+size,s            discard frame ptr + frame
                    rts

BootError
                    comb
                    leas      2+size,s
                    rts


************************************************************
* RFMOpen — open "OS9Boot" on the server
*
* Sends 6-byte header then the filename + CR.
* Receives 1-byte error code.
* Exit: carry clear = OK, set = error
************************************************************
RFMOpen
                    pshs      x,y

* Build and send the 6-byte VFM header:
*   [OP_VFM, DW.Open, path#, ppid=0, pid=0, mode=READ.]
* Push last byte first so OP_VFM ends up at the lowest stack address (= X).
                    lda       #READ.
                    pshs      a                   mode
                    clra
                    pshs      a                   pid = 0
                    pshs      a                   ppid = 0
                    lda       #RFMPATH
                    pshs      a                   path#
                    lda       #DW.Open
                    pshs      a                   DW.Open
                    lda       #OP_VFM
                    pshs      a                   OP_VFM  ← lowest address
                    leax      ,s
                    ldy       #6
                    lbsr      DWWrite
                    leas      6,s

* Send filename and CR terminator
                    leax      BootFile,pcr
                    ldy       #BootFileLen
                    lbsr      DWWrite

* Receive 1-byte response
                    leas      -1,s
                    leax      ,s
                    ldy       #1
                    lbsr      DWRead
                    puls      a                   A = error code (0 = success)
                    tsta
                    bne       RFMOpen_err
                    puls      x,y,pc
RFMOpen_err         coma
                    puls      x,y,pc


************************************************************
* RFMGetSize — query OS9Boot file size via SS.Size
*
* Sends 4-byte GetStat packet; receives 4-byte big-endian size.
* We keep only the low 16 bits (adequate for any practical boot image).
* Exit: D = size in bytes, carry clear = OK, set = error (size was 0)
************************************************************
RFMGetSize
                    pshs      x,y

* Build and send: [OP_VFM, DW.GetStt, path#, SS.Size]
                    lda       #SS.Size
                    pshs      a
                    lda       #RFMPATH
                    pshs      a
                    lda       #DW.GetStt
                    pshs      a
                    lda       #OP_VFM
                    pshs      a
                    leax      ,s
                    ldy       #4
                    lbsr      DWWrite
                    leas      4,s

* Receive 4-byte size: [MSW_hi, MSW_lo, LSW_hi, LSW_lo]
                    leas      -4,s
                    leax      ,s
                    ldy       #4
                    lbsr      DWRead
                    ldd       2,s                 low 16 bits of size
                    leas      4,s
                    cmpd      #0
                    bne       RFMGetSize_ok
                    coma                          zero = error
                    puls      x,y,pc
RFMGetSize_ok       clrb                          carry clear
                    puls      x,y,pc


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
                    pshs      x,y,d               save regs (6 bytes on stack)
                    ldx       blockimg,u          X = current write position

ReadChunk
* Build and send: [OP_VFM, DW.Read, path#, hi(CHUNKSIZE), lo(CHUNKSIZE)]
                    ldd       #CHUNKSIZE
                    pshs      d
                    lda       #RFMPATH
                    pshs      a                   path#
                    lda       #DW.Read
                    pshs      a
                    lda       #OP_VFM
                    pshs      a
                    pshs      x                   save write ptr across DWWrite
                    leax      2,s                 X → OP_VFM (skip saved write ptr)
                    ldy       #5
                    lbsr      DWWrite
                    puls      x                   restore write ptr
                    leas      5,s                 remove packet

* Receive 2-byte count (0 = EOF) — push X first to preserve write ptr
                    pshs      x
                    leas      -2,s
                    leax      ,s
                    ldy       #2
                    lbsr      DWRead
                    puls      d                   D = byte count (0 = EOF)
                    puls      x                   restore write ptr
                    cmpd      #0
                    beq       ReadDone            0 = EOF

* Receive D bytes of file data into the boot image.
* DWRead restores X to its entry value, so advance X by count manually.
                    pshs      d                   save count (2 bytes)
                    tfr       d,y                 Y = count
                    lbsr      DWRead              reads Y bytes to X; X NOT advanced
                    ifgt      Level-1
                    lda       #'.
                    jsr       <D.BtBug            show progress dot
                    endc
                    puls      d                   D = count
                    leax      d,x                 X += count (advance write ptr)
                    bra       ReadChunk

ReadDone            clrb
                    puls      d,y,x,pc


************************************************************
* RFMClose — close the VFM path
*
* Sends 3-byte close packet; receives and discards 1-byte response.
************************************************************
RFMClose
                    pshs      x,y

                    lda       #RFMPATH
                    pshs      a
                    lda       #DW.Close
                    pshs      a
                    lda       #OP_VFM
                    pshs      a
                    leax      ,s
                    ldy       #3
                    lbsr      DWWrite
                    leas      3,s

* Receive and discard 1-byte response
                    leas      -1,s
                    leax      ,s
                    ldy       #1
                    lbsr      DWRead
                    leas      1,s

                    puls      x,y,pc


************************************************************
* Hardware init and DW I/O routines
************************************************************
HWInit              use       dwinit.asm
HWTerm              clrb
                    rts

                    use       dwread.asm
                    use       dwwrite.asm

                    ifgt      Level-1
Filler              fill      $39,$1D0-3-2-1-*
                    endc

Address             fdb       $FF41               Becker port base address
WhichDrv            fcb       $00                 (unused — no disk drive)

                    emod
eom                 equ       *
                    end
