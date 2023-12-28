********************************************************************
* MRAM - myram RAM Disk driver
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   4      1998/10/10  Boisy G. Pitre
* Given to me by Gene Heskett.

                    opt       d68
                    opt       w110
* set printer to 15 cpi!

                    nam       MRAM
                    ttl       OS9 RAM Disk driver

**********************************************
* A version of MyRam that can be assembled to
* run on either 6809 or 6309.
* As no irq's are handled here, compensatory
* changes to register offsets vs stack are not
* required, therefore not used as defines either.
* This does require an "os9defs" that can switch
* register offsets etc according to the value
* assigned to "h6309" and "TRUE", and a late
* copy of Chris Burkes "xsm" assembler

                    ifp1
                    use       defsfile
                    endc

rev                 set       $02
edition             set       4

****************************************
* this is required because regular
* os-9 doesn't treat a native mode
* marked module correctly, result
* crash at worst, device table full
* and nothing else works at best.

                    ifne      H6309
tylg                set       Drivr+Obj6309
atrv                set       ReEnt+ModNat+rev
                    else
tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
                    endc

RD.MAP              set       -2                  ,x of course!
FDlocat             set       -3                  loc for root FD
DIRloca             set       -4                  loc for root
                    mod       eom,name,tylg,atrv,start,size
                    org       0
u0000               rmb       2
u0002               rmb       2
u0004               rmb       2
u0006               rmb       5
u000B               rmb       2
u000D               rmb       2                   is RD.MAP & FDlocat
u000F               rmb       1
u0010               rmb       32
OurDesc             rmb       2
OurLink             rmb       1                   to control our self link
Initstt             rmb       2
u0035               rmb       1
u0036               rmb       2                   number of 8k ramblocks needed
u0038               rmb       2                   only 2 used
u003A               rmb       2
FatScra             rmb       2                   define FatScratch pad areas
MP.SIZ              rmb       2                   ditto
u0040               rmb       6
u0046               rmb       10                  actually 1, our tasknum
u0050               rmb       $C0-.
u00C0               rmb       $100-.
size                equ       .
mode                fcb       $BF

name                fcs       /MRAM/
                    fcb       edition

start               equ       *                   the usual jump table for drivers
                    lbra      Init
                    lbra      Read
                    lbra      Write
                    lbra      SGtat               these return errors
                    lbra      SGtat
                    lbra      Term
Init                equ       *
                    lbsr      Initchk             have we been init'd?
                    bcs       DoInit
                    andcc     #$FE                clr the carry
                    rts                           don't do twice
DoInit              inc       OurLink,u           so it'll get relinked
                    andcc     #$FE                kill the carry if set
                    leax      u000F,u             U is mem assigned area
                    sty       OurDesc,u           save for later recovery
                    pshs      u,x                 building stack image -4
* the stack image is:
*                    sp+2=u, usually $4D00
*                    sp  =x, usually $4D0F
                    ldu       #$0028              location of time packet
                    leax      DD.DAT,x            set x to target location
                    ifne      H6309
                    ldw       #$0005              we want to move 5 bytes
                    tfm       u+,x+               do it
                    else
                    ldb       #$05                number of byte to move
GTime               lda       ,u+
                    sta       ,x+
                    decb
                    bne       GTime
                    endc
                    ldu       2,s
                    ldx       ,s
                    ldb       #$01
                    stb       u0006,u
                    ldx       <D.Proc             <$50 current process ptr
                    ldd       P$User,x            $08,x
                    ldx       ,s                  get x back
* building a dummy sector zero's first $33 bytes
* which is all assembled starting at offset $0F
* of our initial scratchpad assignment
                    std       $0B,x               DD.OWNer of dummy sector zero
                    ldd       #$0001
                    std       $06,x               DD.BIT sectors per cluster
                    lda       $0D,y               DD.ATT disk attributes
                    sta       $0D,x
                    ldd       <$1B,y              IT.SCT
                    std       $01,x               put totsecs in DD.TOT+1

* this could be simplicated to straight 6809 code
                    ifne      H6309

                    lsrd                          /2 but this is one cycle quicker at 3
                    lsrd                          /4
                    lsrd                          /8 8 sectors per byte

                    else

                    lsra                          where this is 2 per 8 bit register
                    rorb                          or 4 cycles for full 16 bit shift
                    lsra
                    rorb
                    lsra
                    rorb

                    endc
                    std       RD.MAP,x            s/b at $400D-E
                    subd      #$0001              it grabs extra page otherwise
                    std       $04,x               DD.MAP (size) addr $13&14
****************************************************
* set the location of the root FD.SCT intelligently!
* this is where the devpack version failed miserably,
* it was fixed at $0002, whole thing dead at 512k & up
* furinstance, with sct=1300, d=$0260 right here,
* therefore the FAT occupies 3 full sectors starting
* at sector $01
                    tfr       a,b
                    incb                          to next page so it skips sector zero
                    incb                          and point to sector AFTER the FAT
                    clra                          simplicating it
                    std       $09,x               DD.DIR+1 fd location!
* save a copy to locate the root FD
                    stb       FDlocat,x           save copy for FD loc
* save a copy to locate the root dir
                    incb                          to next sector
                    stb       DIRloca,x           s/b @ $400B-C
*****************************************
* now lets go get enough memory to build the FAT
                    lda       RD.MAP,x            get msb, maybe $00
* if over $800 sectors, regs.a won't be zero!
                    inca                          round up increment to cover all
                    clrb                          make even page boundary
                    os9       F$SRqMem
                    lbcs      L0178
                    ldx       2,s                 get U back
                    std       MP.SIZ,x            and save it
                    stu       FatScra,x           save FAT loc
                    ldx       ,s                  and get x back
                    pshs      u                   U is new mem area start -6
* the stack image is:
*                    sp+4=u, usually $4D00
*                    sp+2=x, usually $4D0F
*                    sp  =   usually $4000
                    ldu       $04,s               get orig $4D00 u back
* How many 8k blocks of mem do we need?
                    ldd       RD.MAP,x            already been /8
                    addd      #$0003              we'll shift out, but need d2 carry
                    ifne      H6309
                    lsrd                          /16
                    lsrd                          /32 but its 5 cycles faster!
                    else
                    lsra
                    rorb                          /16
                    lsra
                    rorb                          /32
                    endc

* D is now how many blocks we need
                    std       <u0036,u            8k blocks ram needed
                    leax      >u00C0,u            if <$20 blocks we
                    cmpd      #$0020              allow 512k in this map
                    bls       L008D               if go, fits this page
* else table of blocks won't fit from $C0-$FF,
* ask for another (d*2) pages

                    ifne      H6309
                    asld                          else ask for more memory
                    else
                    lslb
                    rola
                    endc
                    os9       F$SRqMem            get new U
                    lbcs      L017C               no more avail!
* we'll use this instead of $xxC0
* the stack image is:
*                    sp+4=u, usually $4D00
*                    sp+2=x, usually $4D0F
*                    sp  =   usually $4000
* save for later release
                    leax      ,u                  ok ,set x to new mem ptr
                    ldu       $04,s               and get old u back
L008D               equ       *
                    stx       <u0038,u            $4EC0 for small disk

                    ifne      H6309
                    ldw       <u0036,u            number of blocks req
                    else
                    ldy       <u0036,u
                    endc

* Where did we start?
L0094               ldb       #$01                ask for one 8K block
                    os9       F$AllRAM            os9 manual doesn't say but
                    lbcs      L017C               returns B=# of blk allocated
                    std       ,x++                make list of blocks

                    ifne      H6309
                    decw                          that we own for later release
                    else
                    leay      -1,y
                    endc

                    bne       L0094

                    ifeq      H6309
                    ldy       <OurDesc,u          we destroyed our descriptor pointer
                    endc

                    leax      <u0040,u            orig U here
                    ldd       [u0038,u]           addr of # of blocks we own
                    std       <$40,x              save at 4E80-81
                    os9       F$AllTsk
* this reserves a task #, then sets hardware
* and DAT ram to this processes addr info
                    lbcs      L017C
                    lda       <D.SysTsk           from dp reference
                    ldb       $06,x               x our task number!
* now we can move the dummy sector zero
* to the first sector
* the stack image now is:
*                    sp+4=u, usually $4D00
*                    sp+2=x, usually $4D0F
*                    sp  =   usually $4000
                    ldx       $02,s               get source ptr
                    ldy       #$001F              byte count
                    pshs      u                   save this puppy, simplicates
* the stack image is:
*                    sp+6=u, usually $4D00
*                    sp+4=x, usually $4D0F
*                    sp+2=   usually $4000
*                    sp  =   our current U, $4D00?
                    ldu       #$0000              destination ptr
                    os9       F$Move              our dummy sector 0
                    leax      >L018A,pcr          devices volume name
                    leau      ,y
                    ldy       #$000E              length of name string etc
* write 10 zeros for DD.BT-DD.NAM & the name section
                    os9       F$Move              and move that into sector zero
                    puls      u                   get our reference back
* now lets make RBF a bit happier by copying
* the opts section of the descriptor into
* sector zero too.
* the stack image is:
*                    sp+4=u, usually $4D00
*                    sp+2=x, usually $4D0F
*                    sp+0=   usually $4000
                    ldx       OurDesc,u
                    leax      $12,x               point to opts in desc
                    ldu       #$003F              point to start of opts in sector 0
                    ldy       #$000F
                    os9       F$Move
                    ldu       4,s
* That moved enough info into what RBF thinks is sector
* zero of this device to tell RBF what it is & how big,
* where root dir is located etc.
FatLoop             equ       *
* Now lets move the FAT into ramdisk space
* the stack image is:
*                    sp+4=u, usually $4D00
*                    sp+2=x, usually $4D0F
*                    sp  =   usually $4000
                    ldx       $02,s               test valid
                    ldd       RD.MAP,x            saved bitmap siz
* using size of bitmap for fat, save it in w

                    ifne      H6309
                    tfr       d,w                 there is a method
                    else
                    std       <u0002,u
                    endc

* now add enough for even page boundary
                    inca
                    clrb                          now D is overall size
                    ldx       ,s                  bitmap addr
* now we know how big it is
                    leay      d,x
                    pshs      y                   save ending addr (page)
* the stack image is:
*                    sp+6=u, usually $4D00
*                    sp+4=x, usually $4D0F
*                    sp+2=   usually $4000
*                    sp  =   top of fat, $4100
L00DC               equ       *

                    ifne      H6309
                    leay      w,x                 set y=where active fat ends
                    else
                    pshs      d
                    ldd       <u0002,u
                    leay      d,x
                    puls      d
                    endc

                    pshs      y                   stack the end of active
* the stack image is:
*                    sp+8=u, usually $4D00
*                    sp+6=x, usually $4D0F
*                    sp+4=   usually $4000
*                    sp+2=   top of fat, $4100
*                    sp  =   end of active fat, $403D?
                    ldx       $04,s               s/b the fat workspace base addr
                    ldb       #$FF                allocate 1st 8 'sectors'
L00E2               stb       ,x+
                    stb       ,x+                 make basic alloc $10 sectors
L00E5               clr       ,x+                 and mark the rest clear
                    cmpx      ,s                  to end of active
                    bcs       L00E5               (was bcs)till the end of the fat
* should show the end of the fat in x
L00EA               stb       ,x+                 then mark full
                    cmpx      $02,s               for remainder of last page
                    bcs       L00EA               (wonder if this s/b bls too!)
* the stack image is:
*                    sp+8=u, usually $4D00
*                    sp+6=x, usually $4D0F
*                    sp+4=   usually $4000
*                    sp+2=   top of fat, $4100
*                    sp  =   end of active fat, $403D?
                    ldu       $08,s               get our base page back
                    lda       <D.SysTsk           u00D0 note dp, is D.SysTsk
                    ldb       <u0046,u            assigned P$Task
                    pshs      d                   save it for following move
* the stack image is:
*                    sp+A=u, usually $4D00
*                    sp+8=x, usually $4D0F
*                    sp+6=   usually $4000
*                    sp+4=   top of fat, $4100
*                    sp+2=   end of active fat, $403D?
*                    sp  =   our task numbers
                    ldd       $04,s               get end of fat
                    subd      $06,s               should leave fatsize in d
                    tfr       d,y                 size to y
                    puls      d                   restore our tsknums
* the stack image is:
*                    sp+8=u, usually $4D00
*                    sp+6=x, usually $4D0F
*                    sp+4=   usually $4000
*                    sp+2=   top of fat, $4100
*                    sp  =   end of active fat, $403D?
                    ldu       #$0100              start of FAT
                    ldx       $04,s
                    os9       F$Move
* we're done with the fat, its moved into the space
* for the device. Now make a dummy FD in the same
* memory area
                    leas      $02,s               don't need end of active fat anymore
MkRoot1             clr       ,x+
                    cmpx      ,s                  clearing the mem,done w/fat
                    bcs       MkRoot1
* the stack image is:
*                    sp+6=u, usually $4D00
*                    sp+4=x, usually $4D0F
*                    sp+2=   usually $4000
*                    sp+0=   top of fat, $4100
                    ldx       $02,s
                    ldu       $04,s
* Ok, now lets make an FD sector for the root dir
FDmaker             equ       *
                    lda       u000D,u             DD.ATT
                    sta       ,x
                    ldd       u000B,u
                    std       $01,x
                    ldb       #$01                this is the link count
                    stb       $08,x
                    ldd       #$0040
                    std       $0B,x
                    ldb       DIRloca,u
                    stb       <$12,x
                    ldd       #$0010
* Now a bit more intelligence applied
                    subb      DIRloca,u
                    std       <$13,x
                    lda       <D.SysTsk           u00D0
* the stack image is:
*                    sp+6=u, usually $4D00
*                    sp+4=x, usually $4D0F
*                    sp+2=   usually $4000
*                    sp+0=   top of fat, $4100
                    ldu       $06,s
                    ldb       <u0046,u
                    pshs      x
* the stack image is:
*                    sp+8=u, usually $4D00
*                    sp+6=x, usually $4D0F
*                    sp+4=   usually $4000
*                    sp+2=   top of fat, $4100
*                    sp  =   saved bottom of work area
                    ldx       $06,s
* now set u to actual offset of FDlocation

                    ifne      H6309
                    lde       FDlocat,x           this is why we saved it
                    clrf
                    tfr       w,u                 neat huh?
                    else
                    pshs      d
                    lda       FDlocat,x
                    clrb
                    tfr       d,u
                    puls      d
                    endc

                    puls      x
* the stack image is:
*                    sp+6=u, usually $4D00
*                    sp+4=x, usually $4D0F
*                    sp+2=   usually $4000
*                    sp+0=   top of fat, $4100
                    ldy       #$0100
                    os9       F$Move
                    leay      <$16,x              why only $16, the dir is $40!
                    pshs      y
* the stack image is:
*                    sp+8=u, usually $4D00
*                    sp+6=x, usually $4D0F
*                    sp+4=   usually $4000
*                    sp+2=   top of fat, $4100
*                    sp  =   saved top of work area
L0144               clr       ,x+
                    cmpx      ,s
                    bcs       L0144
                    leas      $02,s               get rid of that
* the stack image is:
*                    sp+6=u, usually $4D00
*                    sp+4=x, usually $4D0F
*                    sp+2=   usually $4000
*                    sp+0=   top of fat, $4100
                    ldx       $02,s               s/b right
                    leay      $40,x
                    pshs      y
DClr                clr       ,x+
                    cmpx      ,s
                    bcs       DClr
                    leas      $02,s
                    ldx       $02,s               get it back again
                    ldd       #$2EAE
                    std       ,x
                    stb       <$20,x
* again, I've gotta apply some smarts to locating it
                    ldx       $04,s
                    ldb       FDlocat,x
                    clra
                    ldx       $02,s
                    std       <$1E,x
                    std       <$3E,x
                    lda       <D.SysTsk           u00D0
* the stack image is:
*                    sp+6=u, usually $4D00
*                    sp+4=x, usually $4D0F
*                    sp+2=   usually $4000
*                    sp+0=   top of fat, $4100
                    ldu       $06,s
                    ldb       <u0046,u
                    ldy       #$0040
                    ldx       $04,s

                    ifne      H6309
                    lde       DIRloca,x
                    clrf
                    tfr       w,u
                    else
                    pshs      d
                    lda       DIRloca,x
                    clrb
                    tfr       d,u
                    puls      d
                    endc

                    ldx       $02,s
                    os9       F$Move
                    ldx       $04,s
                    lda       RD.MAP,x
                    inca
                    clrb
                    leas      $02,s
* the stack image is:
*                    sp+4=u, usually $4D00
*                    sp+2=x, usually $4D0F
*                    sp+0=   usually $4000
                    puls      u
* the stack image is:
*                    sp+2=u, usually $4D00
*                    sp+0=x, usually $4D0F
                    os9       F$SRtMem            give back FatScra
L0178               leas      $02,s               skip the x offset
                    puls      u                   get orig assignment back!

                    ifne      H6309
                    ldw       <L018A,pcr
                    stw       Initstt,u           crash time?
                    else
                    pshs      d
                    ldd       <L018A,pcr
                    std       Initstt,u
                    puls      d
                    endc

                    clrb
                    rts                           puls  pc,u U allready pulled, use rts

L017C               leas      $04,s
                    puls      pc,u
L018A               fcs       /Gene's RamDisk/
Initchk             equ       *
                    ifne      H6309
                    ldw       Initstt,u           <L018A,pcr
                    cmpw      <L018A,pcr          Initstt,u
                    beq       InitOk
                    else
                    pshs      d
                    ldd       Initstt,u
                    cmpd      <L018A,pcr
                    puls      d
                    beq       InitOk
                    endc
                    comb
                    ldb       E$NotRdy            else report error
InitOk              equ       *                   relocated to give exit report
                    rts

Read                equ       *
* First, have we been assigned any memory?
                    bsr       Initchk
* Now, if carry is clear, we have some memory, go
                    bcc       ReadOk
                    rts                           return the error condition

ReadOk              tst       OurLink,u
                    beq       ReadOk1
                    bsr       Linkus              bsr  ChkLink
ReadOk1             pshs      u
                    bsr       L01C2
                    bcs       L01C0
                    tfr       d,x
                    lda       <u0046,u
                    ldb       <D.SysTsk           u00D0
                    ldu       $08,y
                    bra       L01B9
************ A separate linker
Linkus              pshs      x
                    ldx       PD.DVT,y
                    inc       V$USRS,x
*        ldy   OurDesc,u
*        ldd   M$Name,y
*        leax  d,y point to device name
*        ldd   <D.Proc this is temp
*        pshs  d save it as no time slicing
*        ldd   <D.SysPrc takes place while
*        std   <D.Proc this is in effect!
*        clra  any type/lang
*        os9   I$Attach
*        puls  d
*        std   <D.Proc
*        bcc   LinkusOK
*        os9   F$Exit take error with us
LinkusOK            puls      x                   and restore our entry values
                    clr       OurLink,u           so we don't re-attach us again
                    rts

Write               equ       *
                    bsr       Initchk
                    bcc       WriteOk
                    rts
WriteOk             tst       OurLink,u           has it been done?
                    beq       WriteOk1
                    bsr       Linkus
WriteOk1            pshs      u
                    bsr       L01C2
                    bcs       L01C0
                    pshs      b,a
                    lda       <D.SysTsk
                    ldb       <u0046,u
                    ldx       $08,y
                    puls      u
L01B9               ldy       #$0100
                    os9       F$Move
L01C0               puls      pc,u
L01C2               pshs      x
                    tstb
                    bne       L01F1
L01C7               cmpx      <u0010,u
                    bcc       L01F1
                    tfr       x,d

                    ifne      H6309
                    lsrd                          /2
                    lsrd                          /4
                    lsrd                          /8
                    lsrd                          /16
                    else
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    endc

                    andb      #$FE
L01D8               ldx       <u0038,u
                    beq       L01F5
                    ldd       d,x
                    beq       L01F5
                    leax      <u0040,u
                    std       <$40,x
                    os9       F$SetTsk
                    lda       $01,s
                    anda      #$1F
                    clrb
                    puls      pc,x
L01F1               ldb       #$F1                load the error code
                    bra       L01F7
L01F5               ldb       #$F4                load the error code
L01F7               orcc      #$01                set the carry
                    puls      pc,x                and go home with the error
SGtat               comb
                    ldb       #$D0                #E$IllMode
                    rts
Term                equ       *
                    pshs      u
                    ifne      H6309
                    ldw       <u0036,u
                    else
                    ldy       <u0036,u
                    endc

                    ldu       <u0038,u
                    beq       L022A
L020A               ldb       #$01                is now the same as F$AllRAM loop in
                    ldx       ,u++                the Init routine
                    beq       L0213               this fixed some loose
                    os9       F$DelRAM            ends mmap showed
L0213               equ       *

                    ifne      H6309
                    decw                          was leay  -$01,y
                    else
                    leay      -1,y
                    endc

                    bne       L020A
                    ldu       ,s
                    ldd       <u0036,u
                    cmpd      #$0020
                    bls       L022A

                    ifne      H6309
                    lsld
                    else
                    lslb
                    rora
                    endc

                    ldu       <u0038,u
                    os9       F$SRtMem
L022A               clra                          to remove, clrb here
                    clrb
                    puls      u
                    std       Initstt,u           and "comment" us out
                    rts

                    emod
eom                 equ       *
                    end

* a parking place for the snoop code
*        pshs  cc
*        os9   F$RegDmp lets take a look
*        puls  cc
* end of the snoop code, 4 %&$# lines!

