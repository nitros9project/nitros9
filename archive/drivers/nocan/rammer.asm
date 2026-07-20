********************************************************************
* rammer - Nitros-9 level 2 ram disk
*
* $id: rammer.asm,v 1.0 2004/02/06 01:00:00 Gault exp $
*
* Alan Dekok's version of rammer - based on original Keving Darling version
*
* note: Highly modified for use on non-standard Coco systems. RAM not
*       taken from 2Meg OS-9 memory!
*
* edt/rev  yyyy/mm/dd  modified by
* comment
* ------------------------------------------------------------------
*   4      ????/??/??  ???
* original Kevin Darling version.
*
*   5      2000/03/14  L. Curtis Boyle
* several changes
*
*   5r2    2000/05/09  L. Curtis Boyle
* Allowed driver to go past 400k, attempted some fixes for handling /md,
* so that setting vfy=0 on /r0 would not completely crash the system.
* Fixed some error reporting bugs that would crash the system, and
* moved entry table to between read/write to allow short branches to both.
*
*   6r2    2004/2/2   R. Gault
* Highly modified for use with nocan 8/64meg board & emulators.
* The RAM disk uses no OS-9 memory, just memory above 2Meg. The size of
* the drive is by default 6Meg, 14Meg, or 62Meg but can be changed by altering
* the descriptor, r0.

* H6309 set 1  0=6809  1=6309
Nocan               set       1                   0=64Meg Nocan 1=8Meg MESS and Nocan3 2=16Meg Collyer

* Select the correct pair for the system RAM

                    ifeq      Nocan-1
*MaxLSN is $5FFF      for 8Meg system use 6Meg RAM disk
MaxMSB              set       0
MaxLSW              set       $5FFF
                    endc

                    ifeq      Nocan
*MaxLSN is $3DFFF     for 64Meg system use 62Meg RAM disk
MaxMSB              set       3
MaxLSW              set       $DFFF
                    endc

                    ifeq      Nocan-2
*MaxLSN is $DFFF      for 16Meg system use 14Meg RAM disk
MaxMSB              set       0
MaxLSW              set       $DFFF
                    endc

                    nam       rammer
                    ttl       nitros-9 level 2 ram disk

                    ifp1
                    use       defsfile
                    endc

tylg                set       drivr+objct
atrv                set       reent+rev
rev                 set       1
edition             set       6

                    mod       eom,name,tylg,atrv,start,size


u0000               rmb       drvbeg+drvmem       reserve room for 1 entry drive table
ff9b                rmb       1
stack               rmb       25
size                equ       .

                    fcb       dir.+share.+pread.+pwrit.+pexec.+read.+write.+exec.

name                fcs       /Rammer/
                    fcb       edition

start               lbra      init
                    lbra      read
                    lbra      write
                    lbra      getstat
                    lbra      getstat             actually setstat (no calls, so same routine)
                    lbra      term                terminate (returns memory)

* terminate routine - deallocates ram
term                clrb                          exit without error
                    rts

* init routine - only gets called once.
* called if you iniz the device as well
* entry: y=address of device descriptor
*        u=device mem area
* note: all of device mem (except v.port) is cleared to 0's
init                lda       #1
                    sta       v.ndrv,u            only can handle 1 drive descriptor
                    leax      drvbeg,u            point to start of drive table
                    lda       #$ff
                    sta       ,x                  set DD.TOT to bad value
                    sta       V.TRAK,x            set track to bad value
                    ifeq      Nocan-1
* This may be the wrong place to read this byte. It may be necessary
* to read it prior to each sector read/write if the video bits are
* altered by a user's program.
                    lda       >$9B                save default $FF9B image for future use
                    sta       ff9b,u
                    endc
                    clrb                          no error & return
                    rts

* entry: b:x=lsn to read
*        y=path dsc. ptr
*        u=device mem ptr
read                pshs      y,x                 preserve path & device mem ptrs
                    bsr       ovtest
                    bcs       error
                    bsr       l00c8               calculate mmu block & offset for sector
                    bsr       l00ae               transfer sector from ram drive to pd.buf
                    puls      y,x                 restore ptrs
                    cmpx      #0                  sector 0?
                    bne       getstat             no, exit without error
                    ldx       pd.buf,y            get buffer ptr
                    leay      drvbeg,u            point to start of drive table
                    ifne      H6309
                    ldw       #dd.siz             copy the info we need into drive table
                    tfm       x+,y+
                    else
                    ldb       #dd.siz             copy the info we need into drive table
readlp              lda       ,x+
                    sta       ,y+
                    decb
                    bne       readlp
                    endc
* getstat/setstat - no calls, just exit w/o error
getstat             clrb
                    rts

error               leas      2,s
error2              ldb       #247                seek error
                    rts

ovtest              cmpb      #MaxMSB             prevent access to LSN > than "hardware" supports
                    bls       good
                    cmpx      #MaxLSW
                    bls       good
                    orcc      #1
                    rts
good                andcc     #$FE
                    rts

* entry: b:x = lsn to write
*        y=path dsc. ptr
*        u=device mem ptr
write               equ       *
                    bsr       ovtest
                    bcs       error2
                    bsr       l00c8               calculate mmu block & offset for sector
                    exg       x,y                 x=sector buffer ptr, y=offset within mmu block
* transfer between rbf sector buffer & ram drive image sector buffer
* called by both read and write (with x,y swapping between the two)
l00ae               orcc      #intmasks           shut irq's off
                    ifeq      Nocan
                    sta       >$ff80              Nocan64; map ram drive block into MMU block #0
                    endc
                    ifeq      Nocan-1
                    sta       >$FF9B              Nocan3 or MESS
                    endc
                    ifeq      Nocan-2
                    sta       >$FF70              Collyer
                    endc
                    stb       >$ffa0
                    ifne      H6309
                    ldw       #$0100              256 byte transfer
                    tfm       x+,y+               copy between the two buffers
                    else
                    clrb
writelp             lda       ,x+
                    sta       ,y+
                    decb
                    bne       writelp
                    endc
                    ifeq      Nocan
                    clr       >$ff80              Nocan64
                    endc
                    ifeq      Nocan-1
                    ldb       ff9b,u              Nocan3 or MESS
                    stb       >$FF9B
                    endc
                    ifeq      Nocan-2
                    clr       >$FF70              Collyer
                    endc
                    clr       >$ffa0              remap in system block 0
                    andcc     #^(intmasks)        turn irq's back on
                    rts

* subroutine to calculate mmu block # and offset based on sector # requested
* entry: y=path dsc. ptr
*        u=device mem ptr
*        b:x=LSN to calculate for beyond 2megs; ie. $200000
* that means ram drive has minimum value at $ff80 of 1 and
* mmu block number = lsn/32 + $100
* exit:  a=mmu block # to send to $ff80
*        b=mmu block # to send to $ffa0
*        x=offset within mmu block to get sector from (always <8k)
*        y=sector buffer ptr
l00c8               equ       *
                    pshs      b,x
                    lda       2,s
                    anda      #$1f
                    clrb
                    tfr       d,x                 regX now offset into MMU block
                    ifeq      H6309
                    lsl       2,s                 lsn*8/$10=lsn/$20
                    rol       1,s
                    rol       ,s
                    lsl       2,s
                    rol       1,s
                    rol       ,s
                    lsl       2,s
                    rol       1,s
                    rol       ,s
                    ldd       ,s
                    else
                    ldw       ,s++
                    lda       ,s+
                    lsla
                    rolw
                    lsla
                    rolw
                    lsla                          this value now not needed
                    rolw
                    tfr       w,d
                    endc
                    inca                          make it past the 2megs of os-9
                    ifeq      Nocan-1
                    lsla                          shift it to MMU bits 5&6 for Nocan3 or MESS
                    lsla
                    lsla
                    lsla
* !!! This next line could be a problem if video bits are altered.
* It would require reading the bits prior to every sector read/write!!!
                    ora       ff9b,u              OR in video bits
                    endc
                    ifeq      H6309
                    leas      3,s
                    endc
                    ldy       pd.buf,y            get sector buffer address
                    rts

                    emod
eom                 equ       *
                    end

