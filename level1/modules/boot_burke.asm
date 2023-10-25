********************************************************************
* Boot - Burke & Burke Boot Module
*
* $Id$
*
* Burke & Burke boot module... needs to be patched for OS9Boots that are
* far into the device.
* Track is the literal cylinder #, Cylinder would be including all heads
* of that track
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   2      ????/??/??
* Initial version.

                    nam       Boot
                    ttl       Burke & Burke Boot Module

                    org       0
buffptr             rmb       2                   Pointer to sector buffer in memory
numcyl              rmb       2                   Number of tracks for drive geometry init
sechead             rmb       2                   # of logical sectors/physical sector
numhead             rmb       1                   # of heads (sides)
seccyl              rmb       2                   # of sectors/cylinder (# of heads*sectors per head)
track               rmb       2                   Cylinder number last calculated ($9 - $A)
head                rmb       1                   Drive/head number (drive always 0)
sector              rmb       1                   Sector number (0-63)
vars                equ       13-buffptr          Size of stack variables buffer


                    ifp1
                    use       defsfile
                    endc

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       2

                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       0
size                equ       .

name                fcs       /Boot/
                    fcb       edition

start               ldb       >MPI.Slct           Set up Multipak properly for us
                    lda       #$10
                    mul
                    ldb       #$11
                    mul
                    stb       >MPI.Slct
                    leas      -vars,s             Reserve work area on stack of 13 bytes
                    tfr       s,u                 U points to beginning of 13 byte buffer
                    pshs      u,y,x,b,a           Preserve registers
                    ldd       #$0200              512 bytes for each read from XT-GEN
                    std       numcyl,u            # of cyls on drive
                    sta       sechead+1,u         # of sectors/head
                    sta       numhead,u           # of heads on drive
                    os9       F$SRqMem            Request 512 byte buffer from OS9P1
                    lbcs      L00B6               Error
                    tfr       u,d                 d=Starting address of 512 byte block
                    ldu       $06,s               Get back pointer to 13 byte buffer
                    std       buffptr,u           Preserve buffer pointer

                    clr       >$FF51              Reset controller

                    clr       >$FF53              Set controller mode to 0 (part of init)
                    lbsr      drvtype             Set drive geometry (type of drive)
                    clrb                          Set initial LSN to 0
                    ldx       #$0000
                    lbsr      GetSect             Figure out track/head/sector for LSN0
                    bcs       L00B6               Error occured in read
                    ldy       buffptr,u           Get buffer pointer
                    ldd       DD.NAM+PD.CYL,y     Get real # cylinders on drive
                    std       numcyl,u            Preserve
                    ldd       DD.NAM+PD.SCT,y     Get real # sectors/track
                    std       sechead,u           Preserve
                    lda       DD.NAM+PD.SID,y     Get real # heads
                    sta       numhead,u           Preserve
                    leay      DD.BT,y             Point to OS9Boot information
                    ldd       DD.BSZ-DD.BT,y      Get size of OS9Boot
                    std       ,s                  Preserve on stack
                    ldb       DD.BT-DD.BT,y       Get MSB of starting LSN of OS9Boot
                    ldx       DD.BT-DD.BT+1,y     Get LSW of starting LSN of OS9Boot
                    pshs      x,b                 Push on stack
                    lbsr      drvtype             Set up drive for real drive specs
                    ldd       #$0200              Get size of our buffer
                    ldu       buffptr,u           Get pointer to our 512 byte buffer
                    os9       F$SRtMem            Deallocate our old sector buffer
                    ldd       $03,s               Get back size of OS9Boot
                    inca                          Increase size by 1 block (256 bytes)
                    ifeq      Level-1
                    os9       F$SRqMem
                    else
                    os9       F$BtMem             Allocate memory for boot file
                    endc
                    bcs       L00B0               Error
                    stu       $05,s               Preserve pointer to start of OS9boot memory
                    ldu       $09,s               Get back pointer to local variables
                    ldd       $05,s               Get pointer to start of OS9Boot memory
                    std       buffptr,u           Move disk buffer pointer to there
                    ldd       $03,s               Get size of bootfile
                    beq       L00A9               If zero, do someting
                    pshs      b,a                 Otherwise push on stack
ReadBt              std       ,s                  Store # bytes left in boot on stack
                    ldb       $02,s               Get MSB of start sector of boot
                    ldx       $03,s               Get LSW of start sector of boot
                    bsr       GetSect             Convert to track/head/sector
                    bcs       L00B4               If an error in getting, do something
                    inc       buffptr,u           Bump up buffer pointer by a page
                    ldx       $03,s               Bump up LSW of sector number
                    leax      $01,x
                    stx       $03,s               And put it back
                    bne       L00A0               If no carry over needed, proceed
                    inc       $02,s               Bump up MSB of sector number
L00A0               ldd       ,s                  Get current boot size left to do
                    subd      #$0100              Subtract 256 from it
                    bhi       ReadBt              If not zero yet, keep reading
                    leas      $02,s               Eat our temporary size left
L00A9               leas      $03,s               Eat our current LSN to get
                    clrb                          Clear carry (No error)
                    puls      b,a                 pull off multipak settings (?)
                    bra       BtExit
L00B0               leas      $03,s               Purge stack
                    bra       L00B6
L00B4               leas      $05,s               Purge stack

L00B6               leas      $02,s               Purge stack

BtExit              pshs      a
                    lda       #$FF
                    sta       >$FF51              Reset controller
                    sta       >MPI.Slct           Reset multipak
                    sta       >$FFD9              Double speed on
                    puls      u,y,x,a             Get exit parameters for Boot
                    leas      vars,s              Reset stack
                    rts                           Exit from Boot

* Get 512 byte sector from controller
* Entry X:B = 24 bit Logical sector number to get

GetSect             pshs      x,b                 Preserve registers
                    ldx       #$FFFF              (Init X so it will be 0 in loop)

* 24 bit divide routine. Stack=LSN (3 bytes)
* Entry: u=pointer to our local variable list

cyldiv              leax      $01,x               # of loops through subtract
                    ldd       $01,s               Get original x (0)
                    subd      seccyl,u            Subtract # sector/cylinder
                    std       $01,s               Preserve it back
                    ldb       ,s                  Continue subtract with borrow for 24 bit
                    sbcb      #$00
                    stb       ,s
                    bcc       cyldiv              If not trying to borrow again, continue
                    stx       track,u             Got track #
                    ldd       $01,s               Reset value to last in loop
                    addd      seccyl,u
                    clr       head,u              Set head # to 0?
hddiv               inc       head,u              Increase head #?
                    subd      sechead,u           Subtract # sectors/head?
                    bcc       hddiv               Continue subtracting until it wraps
                    dec       head,u              Adjust head to not include wrap
                    addd      sechead,u           Adjust leftover to not include wrap
                    lsrb                          Divide b by 2 (256 byte sector to 512)
                    stb       sector,u            Preserve sector #
                    leas      $03,s               Clear stack of 24 bit number

                    pshs      cc                  Preserve odd sector flag (carry bit)

                    bsr       cmdstrt             Set up controller for new command
                    lda       #$08                Read sector command
                    ldb       head,u              Drive/head byte (Drive always 0)
                    bsr       dblsend             Send to controller
                    ldd       track,u             Get msb of track
                    lsra                          Move right 2 bits into left two for the
                    rora                          controller
                    rora
                    ora       sector,u            mask in the sector number into remaining 6 bits
*        ldb   track+1,u      Get LSB of track
                    bsr       dblsend             Send to controller
                    ldd       #$0100              1 sector to read/no error correction/3 ms step
                    bsr       dblsend             Send that to controller
                    ldx       buffptr,u           Get pointer to sector buffer
* new code is here
                    puls      cc                  Get back odd sector 1/2 indicator
                    bcc       normal              Even sector, use 1st half
                    bsr       Eat256              Odd sector, use 2nd half
                    bsr       Read256             Read 256 bytes off of controller
                    lbra      chkcmplt            See if command is complete
normal              bsr       Read256             Read 1/2 of sector
                    bsr       Eat256              Eat half of sector
                    lbra      chkcmplt            See if command is complete

Eat256              clrb                          Eat 256 bytes off of controller
Eatlp               lbsr      nxtready            Get byte from controller
                    decb                          counter
                    bne       Eatlp               Keep eating until 256 bytes done
                    clrb
                    rts

* Read 256 bytes from controller
* Entry: X=Pointer to current position in 512 physical sector buffer

Read256             clrb                          Set counter for 256 byte read
ReadLp              lbsr      nxtready            Go get a byte from controller
                    sta       ,x+                 Put in buffer
                    decb                          keep doing until all 256 are read
                    bne       ReadLp

middle              clrb                          Clear carry for no error & return
                    rts

* Send 2 bytes to the controller
* Entry: a=1st byte to send
*        b=2nd byte to send

dblsend             pshs      b,a                 Preserve d for a moment
                    bsr       sendbyte            Go send what is in a to controller
                    tfr       b,a                 Send what was in b to the controller
                    bsr       sendbyte
                    puls      pc,b,a              Return with a and b intact

* Sends a byte to the controller when it is ready for it
* Entry: a=byte to send

sendbyte            pshs      a                   Preserve a for a moment
waitsend            bsr       stable              Make sure status register is stable and get it
                    anda      #%00001011          Mask out bits
                    cmpa      #$09                Is it expecting next byte of data packet?
                    bne       waitsend
                    puls      a                   Yes, get the byte we are sending next
                    sta       >$FF50              Store in data register
                    rts

* Sends out command packet (6 bytes). Hard coded for drive 0, head 0,
* track 0, sector 0, interleave 0, no error correction, 3 ms step rate

cmdpckt             pshs      a                   Preserve command for a moment
                    bsr       cmdstrt             Go initialize controller for command start
                    puls      a                   Get back command byte
                    clrb                          1st option byte to 0
                    bsr       dblsend             Send both to controller
                    clra
                    bsr       dblsend             Send 4 more 0's to controller
                    bsr       dblsend             (sent command byte and 5 zero bytes for command
                    rts                           packet)

cmdstrt             bsr       stable
                    anda      #%00001001          Mask out all but bits 0 and 3
                    bne       cmdstrt             If controller command is not complete or expecting
                    clr       >$FF52              data, keep reading status register until it is ready
                    rts                           Otherwise initialize command start

* Make sure controller's status register is stable

stable              lda       >$FF51              Get status from controller
                    cmpa      >$FF51              Keep getting until it stabilizes
                    bne       stable
                    rts

* Set the drive type (set to 512 track - may be the error)
* Using the initialize drive geometry command
* Exit: Carry set if non-recoverable error

drvtype             lda       #$0C                Initialize drive geometry command
                    bsr       cmdpckt             Go init
                    ldd       numcyl,u            Get # of cylinders on media
                    bsr       dblsend             Send it out (indicates drive has 512 tracks)
                    ldb       sechead+1,u         Get # of sectors/head
                    lda       numhead,u           Get # of heads on media
                    lsrb                          Divide OS9 sectors by 2
                    bsr       sendbyte            Send out # of heads for drive geometry
                    lslb                          Multiply WD sectors by 2 to get OS9 sectors again.
                    mul
                    std       seccyl,u            # sectors per cylinder (all heads on a track)
                    ldd       numcyl,u            Get # of tracks back
                    subd      #$0001              Reduce write track=last track-1
                    bsr       dblsend             Send out reduced write track #
                    bsr       dblsend             Also use as write precomp track #
                    lda       #$04                Maximum ECC burst length correctable=4
                    bsr       sendbyte            Send it out

* Make sure command has completed
* Exit: Carry set if controller reported a non-recoverable error
*       Carry clear if everything went fine

chkcmplt            bsr       stable              When status register is stable get it
                    anda      #%00000111          Keep checking until controller indicates that
                    cmpa      #%00000111          command completion code is ready to be read
                    bne       chkcmplt
                    lda       >$FF50              Get command completion code
                    bita      #%00000010          Was there in error in completing the command?
                    beq       noerror             Nope, everything fine setting drive geometry
                    lda       #$03                Error, Request Sense Status from the drive
                    bsr       cmdpckt             send Request Sense Status code
                    bsr       nxtready            Go get response from controller
                    anda      #%00111111          Mask out all but error type and error code
                    pshs      a                   Preserve it for a second
                    bsr       eat2                Go eat next 4 bytes from controller (remaining 3
                    bsr       eat2                from Sense Status & command completion code)
                    puls      a                   Get back original error byte
                    tsta                          No error occured?
                    beq       noerror             No error; exit without error
                    cmpa      #%00011000          Type 1, error 8 (correctable data error)?
                    beq       noerror             Yes, return without error
                    comb                          Set carry to indicate error
                    rts                           return
noerror             clrb
                    rts

* Reads two byte from controller without caring what they are

eat2                bsr       nxtready

* Waits until next byte coming from controller is ready, then gets it
* Exit: a=byte from controller

nxtready            bsr       stable              Make sure status register is stable and get it
                    anda      #%00001011          Controller ready to send me next byte?
                    cmpa      #%00001011
                    bne       nxtready            Nope, keep waiting
                    lda       >$FF50              Yes, get byte and return
                    rts                           Padding to get $1D0 Size

                    ifgt      Level-1
* L2 kernel file is composed of rel, boot, krn. The size of each of these
* is controlled with filler, so that (after relocation):
* rel  starts at $ED00 and is $130 bytes in size
* boot starts at $EE30 and is $1D0 bytes in size
* krn  starts at $F000 and ends at $FEFF (there is no 'emod' at the end
*      of krn and so there are no module-end boilerplate bytes)
*
* Filler to get to a total size of $1D0. 3 represents bytes after
* the filler: the end boilerplate for the module.
Pad                 fill      $39,$1D0-3-*
                    endc

                    emod
eom                 equ       *
                    end
