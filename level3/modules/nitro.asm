********************************************************************
* NitrOS9 - Sets up NitrOS-9 Level 3
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          ????/??/??  Alan DeKok
* Created.

                    nam       NitrOS9
                    ttl       Sets up NitrOS-9 Level 3

                    ifp1
                    use       defsfile
                    endc

tylg                set       Systm+Obj6309
atrv                set       ReEnt+rev
rev                 set       $04
                    mod       eom,name,tylg,atrv,Start,size
u0000               rmb       0
size                equ       .
name                equ       *
                    fcs       /NitrOS9/
                    fcb       $01

Start               ldd       #$10ff              illegal instruction, /0 trap
                    std       >0
                    ldd       #$0008
                    std       >2
                    ldd       #$20FE
                    std       >4

* allocate a block of RAM for SCF drivers
                    ldu       #eom                get the size of this module
                    leax      eom,pc              point to the next module
                    ldy       #L3.SCF

all.ram             bsr       f.modul             move some modules over
                    tstb                          did we, in fact, move any?
                    beq       all.done            if not, we're done
                    stb       ,y+                 save the starting RAM block number
                    bra       all.ram             and go get another block of RAM

* Verify the rest of the boot: start of old OS9p1 code
all.done            ldd       <D.BtSz             get the size of the boot
                    subr      u,d                 take out the size of the modules we're skipping
* F$VBlock has NO exit conditions, and doesn't change any registers
                    os9       F$VBlock            go verify the rest of the OS9Boot file
* do NOT use U after this!

* set the DAT image of the allocate blocks to be RAMInUse, rather than
* Module In block
                    ldx       <D.SysDAT           point to the system DAT image
                    ldb       $0D,x               grab the block# of the last allocated block
                    incb                          account for block 0: leave SCF & RBF as ModInBlk
                    lda       #RAMInUse           set the RAM to be in use...
                    ldx       <D.BlkMap           point to system block allocation map

set.lp              sta       ,x+                 allocate the RAM
                    decb                          count down
                    bne       set.lp              continue until done

                    ldx       <D.BlkMap           grab the block map again
                    sta       <KrnBlk,x           mark the boot track block as used, too.

* mark block 1 ($2000-$3FFF) in the system memory map as allocated
                    ldx       <D.SysMem           ptr to low system memory
                    ldd       #$0100+L3.Size      RAMInUse, N times
                    leax      $20,x               to the start of block 1 in the block map
blk.lp              sta       ,x+                 set it to be in use
                    decb
                    bne       blk.lp

* U = total size of the crap we've removed
                    ldd       <D.BtSz             size of the bootfile
                    subr      u,d                 take out size of code we've removed
                    std       <D.BtSz
                    ldd       <D.BtPtr
                    addr      u,d                 point to new start of the OS9Booto file
                    pshs      d                   and save for later
                    tfr       u,d                 size of code we've taken out
                    subd      #$00FF              round _down_ a page

                    ldx       <D.SysMem           pt to system memory map
                    ldb       <D.BtPtr            point to start of OS9Boot in memory
                    abx                           go to it

* remove the memory from the system memory map
m.lp                clr       ,x+                 set the RAM to be not in use
                    deca                          count down the number of pages we've moved
                    bne       m.lp                continue
                    bra       x.done

                    leax      -1,x                point to last unused byte
                    tfr       x,d                 move into an address register
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra                          now A=block number of highest block
                    ldb       <D.BtPtr
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    subr      b,a                 same block? (now A=number of blocks to delete)
                    beq       x.done              yes, don't do anything

                    ldu       <D.BlkMap           point to system-wide block map
                    ldx       <D.SysDAT           pointer to system DAT image
                    lslb                          convert to DAT image offset
                    incb                          point to block number, not flag
                    abx                           point to the offset

x.loop              ldb       ,x++                grab a block number
                    clr       b,u                 mark the block as unused
                    deca
                    bne       x.loop              continue until done

x.done              puls      d                   restore ptr to new start of the OS9Boot file
                    std       <D.BtPtr            and save it again
                    clrb
                    rts

*============================================================================
*
* Copy the modules into local memory.
* Copied from [X] to a module called _end
* Entry: X = ptr to start at
*        U = size of stuff deleted so far
* Exit : X = ptr to module after _end module
*        U = total size of stuff deleted

f.modul             pshs      b,x,y,u             save start of area to move, size moved before
* grab the name: is it _end?
is.end              ldd       ,x
                    cmpd      #$87Cd              is it a module?
                    bne       f.exit              no, exit
                    ldd       M$Name,x            get the name pointer
                    ldd       d,x                 get 2 bytes of the name
                    cmpd      #$5F65              '_e'?
                    beq       fnd.end             yes, found it

* skip this module if not at the end yet
                    ldd       M$Size,x            grab the module size
                    leax      d,x                 go to the next module
                    leau      d,u                 add in the size of it
                    bra       is.end              and continue looking for end

f.exit              clrb                          we're done everything
                    puls      a,x,y,u,pc

* copy modules over, and verify
fnd.end             ldy       1,s                 restore ptr to start of area to move
                    tfr       u,w                 new size
                    subw      5,s                 take out old size: W = total size
                    cmpw      #L3.Size*$FF        greater than the room available?
                    bhs       f.exit              yes, exit without allocating RAM

* skip _end module
                    ldd       M$Size,x            get size of the _end module
                    leax      d,x                 skip it
                    leau      d,u
                    stx       1,s                 save new start ptr
                    stu       5,s                 and new size

* we've found blocks to move, so let's allocate some RAM
                    ldb       #L3.Blks            1 block to allocate
                    os9       F$AllRAM            allocate some RAM

                    std       >$0642              map it into system DAT image
                    stb       >$FFA1              map into physical RAM
                    stb       ,s                  save starting block number

                    ifeq      L3.Blks-2           more than 1 block?
                    incb                          yes, go up by a block
                    std       >$0644              map it into the system DAT image
                    stb       >$FFA2              and into the hardware
                    endc

* move the modules to local RAM
                    pshsw     save                size of the block to move
                    ldx       #L3.Start+L3.Size   where to move the stuff to
                    tfm       y+,x+               move it from the OS9Boot file to IOMan local memory

* verify the modules
                    puls      d                   grab the size of the block
                    ldx       #L3.Start+L3.Size   start ptr again
                    os9       F$VBlock            verify the block

* get A = total size (in pages) of stuff moved over
                    addd      #L3.Size+$FF        round up to the nearest block, adding in $20

* start with all local RAM deallocated
                    ldx       #L3.Start           to the start of the block
                    ldb       #L3.Size-1          number of pages to mark as free
clr.lp              clr       b,x                 set them to be all clear.
                    decb
                    bpl       clr.lp              count down until B=-1

* allocate local RAM to the size of the modules we've moved over
                    ldb       #RAMInUse           RAM in use
all.lp              stb       ,x+                 make the page allocated
                    deca                          count down a page
                    bne       all.lp              and continue

                    lda       #'-                 a hyphen
                    jsr       <D.BtBug            print it out

* restore start, size pointers and exit
                    puls      b,x,y,u,pc

                    emod
eom                 equ       *
                    end
