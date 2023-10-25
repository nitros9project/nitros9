********************************************************************
* Boot Common - Common code for NitrOS-9 booters
*
* $Id$
*
* This common file is not a stand-alone module, but is 'used' by boot module
* source files to bring in support for booting from RBF file systems that have
* either standard or new-style fragmented bootfiles.
*
* This code uses several static variables which are expected to be defined in
* the main boot source code.  See a booter like boot_1773.asm for an example on
* how to write a booter which uses this code.
*
* Important Notes:
* For certain devices, only the lower 16 bits of DD.BT are used.  This special
* case allows us to save some code by ignoring the loading LSN bits 23-16 in
* DD.BT and FDSL.A.  Booters for such devices (floppy, RAMPak) should have the
* following line in their code to take advantage of this optimization:
*
* LSN24BIT equ 0
*
* Floppy booters require the acquistion of DD.TKS and DD.FMT from LSN0 to make
* certain decisions about the boot process.  In most cases, non-floppy booters
* do not need these values.  Hence, floppy booters should have this line in their
* source code file:
*
* FLOPPY equ 1
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2005/10/14  Boisy G. Pitre
* Created as a stand-alone file.
*
*          2005/10/16  Boisy G. Pitre
* Further optimizations made
*
*          2006/01/04  P.Harvey-Smith.
* Added pointer to loaded LSN0 to data passed to hardware dependent section.
*
*          2007/08/23  Boisy G. Pitre
* Added 'subd #$00FF' to counteract earlier 'addd #$00FF'.  We need to undo
* to give F$SRqMem the right amount of memory to allocate.
*
*          2007/08/24  Boisy G. Pitre
* We no longer use F$SRqMem to get the 256 byte buffer for LSN0, but
* instead allocate the memory temporarily off the stack.  This gives us
* two system ram pages that were not available before, and also prevents
* a needless system call.
* Note: For Level 1, we actually use the page above the stack at $500-$5FF
* to hold LSN0 during the bootfile acquisition process. This is because the
* system stack is only 256 bytes and we are using more than that.  Since
* the module directory table is at $400-$4FF, we must do this; otherwise, we
* would overwrite the bottom portion of the module directory table and corrupt
* it (it's already setup by krn before boot is called!)

start               orcc      #IntMasks           ensure IRQs are off (necessary?)
* allocate memory on stack for vars and sector buffer
                    ifeq      Level-1
* Level 1: stack is only 256 bytes and its bottom runs against moddir ptrs..
* so cheat and use free page just above stack as 256-byte disk buffer
                    leas      -size,s
                    tfr       s,u                 get pointer to data area
                    ldx       #$500
                    else
                    leas      -size-256,s
                    tfr       s,u                 get pointer to data area
                    leax      size,u              point U to 256 byte sector buffer
                    endc
                    pshs      u                   save pointer to data area
                    stx       blockloc,u

* Initialize Hardware
                    ldy       Address,pcr         get hardware address
                    lbsr      HWInit

* Read LSN0
                    ifne      LSN24BIT
                    clrb                          MSB sector
                    endc
                    ldx       #0                  LSW sector
                    lbsr      HWRead              read LSN 0
                    bcs       error               branch if error

                    ifgt      Level-1
                    lda       #'0                 --- loaded in LSN0'
                    jsr       <D.BtBug            ---
                    endc

                    stx       LSN0Ptr,u           Save LSN0 pointer
* Pull relevant values from LSN0
                    ifne      FLOPPY
                    lda       DD.TKS,x            number of tracks on this disk
                    ldb       DD.FMT,x            disk format byte
                    std       ddtks,u             TAKE NOTE!  ASSUMES ADJACENT VARS!
                    endc
                    ldd       DD.BSZ,x            os9boot size in bytes
                    beq       FragBoot            if zero, do frag boot
                    std       bootsize,u
* Old style boot -- make a fake FD segment right from LSN0!
                    leax      DD.BT,x
                    addd      #$00FF              round up to next page
* Important note: We are making an assumption that the upper 8 bits of the
* FDSL.B field will always be zero.  That is a safe assumption, since an
* FDSL.B value of $00FF would mean the file is 65280 bytes.  A bootfile
* under NitrOS-9 cannot be this large, and therefore this assumption
* is safe.
                    sta       FDSL.B+1,x          save file size
                    ifne      LSN24BIT
                    clr       FDSL.S,x            make next segment entry 0
                    endc
                    clr       FDSL.S+1,x
                    clr       FDSL.S+2,x
                    subd      #$00FF              undo previous add #$00FF
                    bra       GrabBootMem

Back2Krn            lbsr      HWTerm              call HW termination routine
                    ldx       blockimg,u          pointer to start of os9boot in memory
                    clrb                          clear carry
                    ldd       bootsize,u
error
                    ifeq      Level-1
                    leas      2+size,s            reset the stack    same as PULS U
                    else
                    leas      2+size+256,s        reset the stack    same as PULS U
                    endc
                    rts                           return to kernel


* NEW! Fragmented boot support!
*FragBoot ldb   bootloc,u  MSB fd sector location
*         ldx   bootloc+1,u LSW fd sector location
FragBoot            ldb       DD.BT,x             MSB fd sector location
                    ldx       DD.BT+1,x           LSW fd sector location
                    lbsr      HWRead              get fd sector
                    ldd       FD.SIZ+2,x          get file size (we skip first two bytes)
                    std       bootsize,u
                    leax      FD.SEG,x            point to segment table

GrabBootMem
                    ifgt      Level-1
                    os9       F$BtMem
                    else
                    os9       F$SRqMem
                    endc
                    bcs       error
* Save off alloced mem from F$SRqMem into blockloc,u and restore
* the statics pointer in U
                    tfr       u,d                 save pointer to requested memory
                    ldu       ,s                  recover pointer to data stack
                    std       blockloc,u
                    std       blockimg,u

* Get os9boot into memory
BootLoop            stx       seglist,u           update segment list
                    ifne      LSN24BIT
                    ldb       FDSL.A,x            MSB sector location
                    endc
BL2                 ldx       FDSL.A+1,x          LSW sector location
                    ifne      LSN24BIT
                    bne       BL3
                    tstb
                    endc
                    beq       Back2Krn
BL3                 lbsr      HWRead
                    inc       blockloc,u          point to next input sector in mem

                    ifgt      Level-1
                    lda       #'.                 show .'
                    jsr       <D.BtBug
                    endc

                    ldx       seglist,u           get pointer to segment list
                    dec       FDSL.B+1,x          get segment size
                    beq       NextSeg             if <=0, get next segment

                    ldd       FDSL.A+1,x          update sector location by one
                    addd      #1
                    std       FDSL.A+1,x
                    ifne      LSN24BIT
                    ldb       FDSL.A,x
                    adcb      #0
                    stb       FDSL.A,x
                    endc
                    bra       BL2

NextSeg             leax      FDSL.S,x            advance to next segment entry
                    bra       BootLoop
