********************************************************************
* CC3Disk - Disto No Halt Super Controller II disk driver
*
* This driver their interrupt driven driver. It is a no halt
* (multitasking) disk driver that uses interrupts. Care must be
* taken that no other hardware will conflict.
*
* $Id$
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------
*  02    Fist disassembled                              tjl 02/08/27

                    nam       CC3Disk
                    ttl       os9 device driver

* Disassembled 02/08/27 11:42:37 by Disasm v1.6 (C) 1988 by RML

* Disto's Super Controller II supports two locations for its
* registers: $FF74 and $FF58

nh_base             equ       $FF74
nh_stat             equ       nh_base
nh_data             equ       nh_base+2

                    ifp1
                    use       defsfile
                    endc


rev                 set       $02

                    mod       eom,name,Drivr+Objct,ReEnt+rev,start,size

* NOTE: This driver only uses one byte of V.TRAK, and the most significiant
*   one, not the LSB as most others do.

* $FF48: READ = Status register Error flags are the most significiant 5 bits
*   %10000000 = Drive not ready
*   %01000000 = Write protect
*   %00100000 = Head is loaded OR Write fault (after any write operation)
*   %00010000 = Seek error
*   %00001000 = CRC error
*   %00000100 = Track 0 (head is @ track 0) OR Lost Data
*   %00000010 = Data Request (need to read or write data register)
*   %00000001 = Busy (command in progress)
* $FF48: WRITE = Command register
*   $03 = Restore
*   $17 = Seek
*   $23 = Step
*   $43 = Step in
*   $53 = Step out
*   $80 = Read sector
*   $a0 = Write sector
*   $c0 = Read Address
*   $e4 = Read Track
*   $f4 = Write Track
*   $d0 = Force interrupt

* $FF40: Control register - WRITE ONLY
*   %10000000 = Halt Flag: 0=Disabled (Wiggle for read/write sync)
*   %01000000 = Select drive 4 / Select side 2
*   %00100000 = Single (1) or Double density (0)
*   %00010000 = Write Precomp select (1)=ON
*   %00001000 = Motors ON (1=on, 0=off)
*   %00000100 = Select drive 3
*   %00000010 = Select drive 2
*   %00000001 = Select drive 1

* $FF49: Track register
* $FF4A: Sector register
* $FF4B: Data register (both directions)

* $FF76: Cache control register
*   %00000000 = Caching off
*   %00001000 = Tell cache controller to send interrupt when device is ready
*               to send/receive a buffer (seek done, etc.)
*   %00000111 = Read cache on - Get next 256 data bytes from controller to cache
*   %00000100 = Write cache on - Next 256 bytes stored in cache are sector
*   %00000110 = Copy Write cache to controller
* $FF74-$FF75 - cache data (read/write): Works the same as WDDisk/Eliminator,
*   with 'ghosting' technique to allow 2 byte read/writes. Should work with
*   TFM on first location

CachCtrl            equ       $ff76               Cache control register
CachDat             equ       $ff74               Cache data register (ghosted to $FF75)

* First $A6 bytes are normal as per RBF section in Tech Ref for 4 drives
* Stuff unique to Disto driver - Starts @ u00A7
norm                rmb       DRVBEG+(DRVMEM*4)   Normal stuff for 4 drives
u00A7               rmb       23                  Driver stuff for Disto driver
size                equ       .

                    org       0                   Sub list for driver area @ u00A7
d0000               rmb       1                   ($a7)  Last drive # accessed
d0001               rmb       1                   ($a8)  Drive's bitmask (for controller)
d0002               rmb       1                   ($a9)  Flag: 0=Same drive as last selected
d0003               rmb       1                   ($aa)  Flag: 0=copy cached Read sector to buffer
*                                 <>0=Just Read sector to cache, don't copy
* Goes from right to left, with 0 bit meaning try a re-read, and 1 meaning
* try to seek to track 0 first. These are LSR'd out, and when byte=0, it
* will totally give up & return an error.
d0004               rmb       1                   ($ab)  # of retries mask/count: normally %10010001.
d0005               rmb       1                   ($ac)  Track #
d0006               rmb       1                   ($ad)  Sector #
d0007               rmb       1                   ($ae)  Head # (0 or 1)
d0008               rmb       1                   ($af)  Current cache command
d0009               rmb       1                   ($b0)  Current controller command
* VIRQ packet
d000A               rmb       2                   ($b1)  Actual counter for VIRQ
d000C               rmb       2                   ($b3)  Reset value for counter
d000E               rmb       1                   ($b5)  'Fake' status register for VIRQ routine
d000F               rmb       1                   ($b6)
d0010               rmb       2                   ($b7-$b8) Copy of LSN (<=65535 for floppies)
d0012               rmb       1                   ($b9)
d0013               rmb       2                   ($ba) Address of 6656 byte buffer for format
d0015               rmb       1                   ($bc) Multi-pak slot settings before CC3Disk called
d0016               rmb       1                   ($bd)
                    fcb       $FF

name                fcs       /CC3Disk/
                    fcb       $A4                 (Edition #) (originally $A3)

* Terminate entry point
Term                leay      >u00A7+d000A,u      Point to IRQ/VIRQ packet (LSN)
                    ldx       #$0000              Flag to delete IRQ entries
                    os9       F$VIRQ              Delete VIRQ entry
                    os9       F$IRQ               Delete IRQ entry
                    ldy       #CachCtrl           Point to cache control register
                    os9       F$IRQ               Delete it's IRQ entry
                    clrb
                    stb       >$FF40              Shut off all drive motors
                    stb       <D.MotOn            Flag drive motor as not running
                    rts                           Exit

* IRQ/VIRQ #1 packet (for drive motor timings)
L0040               fcb       $00                 Flip byte
                    fcb       $01                 Mask byte
                    fcb       $09                 Priority byte

* IRQ #2 packet (presumably for read/write) - if 1st bit of CachCtrl is clear,
*   the cache controller generated the interrupt
L0043               fcb       $80                 Flip byte
                    fcb       $80                 Mask byte
                    fcb       $10                 Priority byte

* Init entry point
* Entry: Y=Ptr to device descriptor
*        X=Ptr to device (static) memory
Init                clr       >CachCtrl           Shut caching off
                    clr       <D.MotOn            Flag drive motor as not running
                    ldx       #$FF48              Point to control register of Controller chip
                    lda       #$D0                Force interrupt
                    sta       ,x                  Tell controller to do that
                    lbsr      L033A               Time delay to allow controller to acknowledge
                    lda       ,x                  Eat ACK from controller
                    ldd       #$FF04              Init last drive accessed & max # of drives
                    sta       >u00A7+d0000,u      Init last drive # accessed to bogus value
                    leax      DRVBEG,u            Point to 1st normal drive table
L0061               sta       DD.TOT,x            Init # of sectors to $FF
                    sta       <V.TRAK,x           Init Current track # to $FF
                    leax      <DRVMEM,x           Point to next drive table
                    decb                          Dec drive counter
                    bne       L0061               Do until all 4 drive table entries done
                    leax      >L023C,pc           Set up NMI routine to go here
                    stx       <D.NMI
                    pshs      u                   Preserve device mem ptr
                    leau      >u00A7+d0000,u      Point to new stuff in device mem
                    leay      d000A+Vi.Stat,u     Point Y into new area
                    tfr       y,d                 Status register from VIRQ packet
                    leay      >L0489,pc           Point to IRQ service routine for drive motors
                    leax      >L0040,pc           Point to IRQ packet for drive motors
                    os9       F$IRQ               Install it (VIRQ will trigger it)
                    puls      u                   Get back device mem ptr
                    bcs       L00BD               Couldn't install, exit with error
                    lda       >$FF7F              Get multi-pak slot status
                    sta       >u00A7+d0015,u      Save it
                    ldd       #CachCtrl           Cache status register
                    leay      >L01F7,pc           Cache handling IRQ routine
                    leax      >L0043,pc           IRQ packet
                    os9       F$IRQ               Install cache handling IRQ
                    bcs       L00BD               Couldn't install, exit with error
                    pshs      cc                  Preserve interrupt status
                    orcc      #IntMasks           Shut off interrupts
                    lda       >$FF23              Disable PIA CART FIRQ's
                    anda      #$FC
                    sta       >$FF23
                    lda       >$FF22              ??? Bleed off PIA IRQ
                    lda       <D.IRQER            Get copy of GIME IRQ register
                    ora       #$01                Enable cartridge IRQ's
                    sta       <D.IRQER            Save copy
                    sta       >IrqEnR             Allow CART IRQ's on GIME
                    puls      cc                  Restore IRQ status
GetStat             clrb                          No error & return
L00BD               rts

Read                lbsr      L0263               Go get track/head/sector #'s
* L0263 returns with U=u00A7
                    clr       d0003,u             Clear flag: We want cached sector copied to bfr
                    ldd       <d0010,u            Get LSN
                    bne       L0113               If <>0, read sector & leave
                    bsr       L0113               Otherwise, read it & make sure disk is compatible
                    bcs       L00BD               Error reading, exit
* New LSN0 read, make sure disk's format is readable by current Drive settings
                    lda       <PD.TYP,y           Get type from disk's LSN0
                    bita      #$40                Standard OS-9 Format?
                    lbne      L04B0               No, do something special
                    ldx       PD.BUF,y            Get ptr to sector buffer
                    pshs      y,x                 Preserve Path dsc. & sector buffer ptrs
                    ldy       <PD.DTB,y           Get ptr to drive table
                    ldb       #DD.RES+1           Get # bytes to copy
L00E0               lda       b,x                 Copy info from Disk's LSN0 to drive table
                    sta       b,y
                    decb                          Do until all 20 bytes copied
                    bpl       L00E0
                    lda       <DD.FMT,y           Get new disk's format
                    ldy       2,s                 Get Path dsc ptr back
                    ldb       <PD.DNS,y           Get Density settings from there
                    bita      #FMT.DNS            New disk single density?
                    beq       L00F8               Yes, no problem reading it
                    bitb      #$01                New disk is dbl dns, is Path dsc. sngl dns?
                    beq       L010E               Yes, incompatible disk
L00F8               bita      #FMT.TDNS           Check track density
                    beq       L0100               48 tpi can always be read, continue
                    bitb      #$02                New disk is 96 tpi, is path descriptor's?
                    beq       L010E               No, it's 48 tpi, incompatible disk
L0100               bita      #FMT.SIDE           Densities are fine, check # heads
                    beq       L010B               1 head is always fine
                    lda       <PD.SID,y           Get path dsc. # heads
                    suba      #2                  Only allowed 2 on floppies
                    blo       L010E               Went negative, too many heads
L010B               clrb                          No error & return
                    puls      pc,y,x
L010E               comb                          Exit with Bad (incompatible) media type error
                    ldb       #E$BTyp
                    puls      pc,y,x

start               lbra      Init                Init
                    bra       Read                Read
                    nop
                    bra       Write               Write
                    nop
                    bra       GetStat             GetStat
                    nop
                    lbra      SetStat             SetStat
                    lbra      Term                Term


* Entry: D=LSN
L0113               lbsr      L02D3               Go seek to track # we want to
                    bcs       L00BD               Error trying to seek, exit with it
                    ldd       #$0780              Cache cmd=07, Controller cmd= Read Sector
                    bsr       L0199               Go read the sector
                    lbcs      L025F               Error occured, exit with Read Error
                    ldx       PD.BUF,y            Get buffer address to store into
                    ldb       #$80                # loops
                    tst       d0003,u             Do we want cached sector copied to buffer @ X?
                    bne       L0138               No, this is just for verify, don't bother
* CACHE READ - CHANGE TO TFM ON 6309
* On 6809, preserve Y instead of B, tfr x to y, do ldx >CachDat/stx ,y++/decb
* to speed up loop by 4*128 cycles (512 cycles)
                    pshs      y                   Save path dsc. ptr
                    tfr       x,y                 Move buffer ptr to Y to free up X
L012D               ldx       >CachDat            Get 2 bytes from cache
                    stx       ,y++                Put them into our buffer
                    decb                          Done all 256 bytes yet?
                    bne       L012D               No, keep going until we do
                    puls      y                   Restore path dsc. ptr
L0138               andcc     #$FE                No error & return
                    rts

Write               lbsr      L0263               Go get track, head & sector #
L013E               bsr       L014D               Go write the sector
                    bcs       L014C               Error, exit
                    tst       <PD.VFY,y           Verify On?
                    bne       L014B               Nope, exit without error
                    bsr       L0171               Go verify sector
                    bcs       L013E               Error, try rewriting it
L014B               clrb                          No error & return
L014C               rts

L014D               lbsr      L02D3               Go seek to proper track
                    bcs       L014C               Error, exit
                    ldx       PD.BUF,y            Get ptr to sector buffer to write
* Physical Cache WRITE
                    ldd       #$0480              Write Cache fill command & # write loops
                    sta       >CachCtrl           Tell cache we are writing to it
                    pshs      y                   Save path dsc. ptr
                    tfr       x,y                 Move buffer ptr to Y
L015D               ldx       ,y++                Get 2 bytes from buffer
                    stx       >CachDat            Send them to the cache
                    decb                          Dec counter
                    bne       L015D               Do until we are done all 256 bytes
                    puls      y                   Get Path dsc. ptr back
                    ldd       #$06A0              Copy Cache to Cntrlr, Write sector cntrlr cmd
                    bsr       L0199               Go copy from cache to controller
                    lbra      L0240               Go check for errors

* Verify written sector
L0171               lda       d0004,u             Get retry count/flags
                    pshs      a                   Save it
                    clr       d0004,u             Clear it out in driver data mem
                    lda       #$FF                Set flag that we don't want cached sector in bfr
                    sta       d0003,u
                    bsr       L0113               Go read the sector into the cache
                    bcs       L0194               Controller error, exit
                    pshs      y                   Save path dsc. ptr
                    tfr       x,y                 Move buffer ptr to Y
L0182               ldx       >CachDat            Get 2 bytes from read cache
                    cmpx      ,y++                Same as original buffer contents from write?
                    bne       L0190               No, Sector written incorrectly
                    decb                          Good so far, check rest of sector
                    bne       L0182
                    bra       L0192               Everything worked fine, exit without error

L0190               orcc      #$01                Set error flag
L0192               puls      y                   Get back path dsc. ptr
L0194               puls      a                   Get retry/count flags back
                    sta       d0004,u             Save them back & return
                    rts
* Send Cache & Controller commands
* Entry: A=cache command
*        B=Controller command ($FF48)
* If an error occurs, it will try again with track 0 seeks interspersed to
* try & re-align the drive head. d0004,u control how many of each are done
L0199               std       d0008,u             Save cache & controller commands
L019B               ldd       d0008,u             Get cache & controller commands
                    bsr       L01B8               Go program cache & wait for drive motors
                    lbsr      L0240               Go get error status from drive command
                    bcc       L01B7               No error, exit
                    lda       >$FF48              Get status register
                    bita      #%01000000          Was it a Write protect error?
                    bne       L01B6               Yes, exit with error code
                    lsr       d0004,u             Shift retry flags over
                    beq       L01B6               If we have done all 8 retries, exit with error
                    bcc       L019B               If bit flag was 0, try re-read/writing sector
                    lbsr      L0346               If bit flag was 1, try seeking to track 0 first
                    bra       L019B               Try read/write again
L01B6               coma                          Exit with error
L01B7               rts

L01B8               pshs      a                   Preserve cache command
                    lda       <D.Proc             Get MSB of current process ptr
                    sta       >V.WAKE-u00A7,u     Save it as MSB of ptr to current process ptr
                    puls      a                   Get back cache command
                    stb       >$FF48              Send step rate/command to controller
                    ora       #$08                Tell cache to send interrupt when device is ready
                    sta       >CachCtrl           Send to cache controller
                    ldb       #%00101000          Drive motors on, double density
                    orb       d0001,u             Mask in drive # bits
                    stb       >$FF40              Send to controller
                    pshs      x                   Preserve drive table ptr
                    bra       L01E5

L01D5               ldx       <D.Proc             Get current process ptr
                    lda       P$State,x           Suspend current process
                    ora       #Suspend
                    sta       P$State,x
                    andcc     #^IntMasks          Turn interrupts back on
                    ldx       #$0001              Sleep for 1 tick
                    lbsr      L0424               Go wait for drive motor

L01E5               orcc      #IntMasks           Shut off interrupts
                    lda       >V.WAKE-u00A7,u     Get MSB of process ptr that is waiting
                    bne       L01D5               None, go suspend process & wait for drive
                    clrb                          Clear carry
                    ldb       #$04                Tell cache we are writing to it
                    stb       >CachCtrl
                    andcc     #^IntMasks          Turn interrupts back on
                    puls      pc,x                Restore drive table ptr & return

* IRQ #2
* Entry: U=ptr to IRQ memory area (u0000,u in here)
L01F7               lda       V.WAKE,u            Get MSB of process descriptor ptr
                    beq       L0233               None, exit (restoring MPI slot selects)
                    ldb       >MPI.Slct           Get current MPI slot settings
                    stb       >u00A7+d0016,u      Save them
                    ldb       >$BC,u              Get original (before CC3Disk) slot settings
                    stb       >MPI.Slct           Set up the MPI for them
                    ldb       #$D0                Force interrupt
                    stb       >$FF48              Send to disk controller
                    ldb       #$04                We are writing to cache
                    stb       >CachCtrl
                    ldb       <D.IRQS             Get IRQ shadow register
                    andb      #$FE                Shut off Cart IRQ bit
                    stb       <D.IRQS             Save it back
                    ldb       <D.IRQER            Get Interrupt enable register copy
                    andb      #$FE                Shut off Cart IRQ bit
                    stb       >IrqEnR             Save to GIME
                    orb       #$01                Turn Cart IRQ back on
                    stb       >IrqEnR             Save to gime
                    clrb                          Clear out process to wake flag
                    stb       V.WAKE,u
                    tfr       d,x
                    lda       $0C,x
                    anda      #$F7
                    sta       $0C,x
                    clrb
                    bra       L0234

L0233               comb                          Set error flag
L0234               lda       >u00A7+d0016,u      Get original MPI slot settings
                    sta       >MPI.Slct           Restore MPI to original state & exit
                    rts

* D.NMI gets redirected to here (only used by SS.WTRK???)
L023C               leas      R$Size,s            Eat register stack generated by NMI
                    puls      y,cc                Get path dsc. ptr & CC (see L03E4)
* Entry point from READ
* CHECK FOR ERROR ON CONTROLLER FROM LAST CONTROLLER COMMAND
L0240               ldb       >$FF48              Get status register
                    clr       >CachCtrl           Shut off cache
                    andb      #%11111000          Just want error bits
                    beq       L0258               No error, exit
                    pshs      x                   Preserve X a moment
                    leax      <ErrTbl-1,pc        Get OS-9 error code #
L024F               leax      1,x

                    bcc       L024F
                    ldb       ,x
                    puls      pc,x                Restore X & return with error
L0258               clrb
L0259               rts

ErrTbl              fcb       E$NotRdy,E$WP,E$Write,E$Seek,E$CRC

L025F               comb                          Exit with Read error
                    ldb       #E$Read
                    rts

* Calculate track, head & sector #'s & check for out of range sector #
L0263               leau      >u00A7,u            Point to driver info
                    clr       d0007,u             Clear head #
                    lda       #%10010001          Retry bit pattern:8 tries, with 3 Seek to 0's
                    sta       d0004,u
                    tstb                          LSN >65535?
                    bne       L027F               Yes, illegal
                    tfr       x,d                 Move LSN to D
                    std       <d0010,u            Save it
                    beq       L02A1               Sector 0, skip ahead
                    ldx       <PD.DTB,y           Get ptr to drive table
                    cmpd      DD.TOT+1,x          Within range of maximum drive can handle?
                    blo       L0285               Yes, continue
L027F               comb                          Exit with bad sector # error
                    ldb       #E$Sect
                    leas      2,s                 Eat 1st RTS address
                    rts
L0285               clr       ,-s                 Set track # to 0
                    bra       L028B               Enter divide loop
L0289               inc       ,s                  Bump up track #
L028B               subd      <DD.SPT,x           Subtract # sectors per track
                    bhs       L0289               Still more sectors left, try subtracting again
                    addd      <DD.SPT,x           Went negative, bump sector count back up
                    lda       <DD.FMT,x           Get # sides & densities
                    lsra                          Bump # sides into carry
                    bcc       L029F               If only 1, done
                    lsr       ,s                  Divide track by 2
                    bcc       L029F               If even, done
                    inc       d0007,u             Bump head up to 1
L029F               puls      a                   Get track #
L02A1               std       d0005,u             Save track & sector #'s
                    clrb                          No error & return
                    rts

* Entry: D=LSN
*        X=Drive table ptr
*        U=u00A7
* Check if drive # is legal
L02A5               clr       d0002,u             Clear flag
                    lda       <PD.DRV,y           Get drive #
                    cmpa      #$04                legal drive #?
                    blo       L02B2               Yes, continue
                    comb                          No, exit with Illegal Unit (drive)
                    ldb       #E$Unit
                    rts
* Make drive bit mask for controller, and check if motor delay needed (?)
L02B2               pshs      x,d                 Preserve Drive table ptr, Drive # & LSB of LSN
                    cmpa      d0000,u             Same as last drive accessed?
                    beq       L02BA               Yes, don't reset flag
                    com       d0002,u             Set flag to indicate different drive
L02BA               sta       d0000,u             Save drive #
                    leax      <L02C8,pc           Point to drive bit mask table
                    ldb       a,x                 Get appropriate bit mask for drive for controller
                    stb       d0001,u             Save it
                    lbsr      L043E
                    puls      pc,x,d              Restore Drive table ptr, LSN & return

* Drive bit mask table (sent to controller)
L02C8               fcb       $01                 Drive 0 mask
                    fcb       $02                 Drive 1 mask
                    fcb       $04                 Drive 2 mask
                    fcb       $40                 Drive 3 mask (side select)

* Entry: A=Track #
*        X=Drive table ptr
* Seek to new track (in A) & update V.TRAK accordingly
* This version only called by SS.WTRK
L02CC               pshs      a                   Preserve track #
                    ldb       <V.TRAK,x           Get current track # on drive
                    bra       L030A
* Entry:D=LSN
*       U=Ptr to driver data mem
*       Y=Path dsc. ptr
* Seek to track # stored @ d0005,u - called by normal WRITE's
L02D3               bsr       L02A5               Set up drive bitmasks & flag
                    bcs       L032D               Error, exit
                    ldd       d0005,u             Get track & sector #'s
                    pshs      a                   Save track #
                    lda       d0007,u             Get head #
                    beq       L02E6               If head 0, skip ahead
                    lda       d0001,u             Get drive's bit mask
                    ora       #%01000000          Mask in side 2 select
                    sta       d0001,u             Save new drive bit mask
L02E6               lda       <PD.TYP,y           Get drive type
                    bita      #%00000010          ??? (Base of sector #???)
                    bne       L02EE               If set, skip ahead
                    incb                          Otherwise, bump up sector #
L02EE               stb       >$FF4A              Save sector # onto controller's sector reg.
                    ldx       <PD.DTB,y           Get drive table ptr
                    ldb       <V.TRAK,x           Get current track
                    lda       <DD.FMT,x           Get disk format; density/sides
                    lsra                          Shift densities to 1st 2 bits
                    eora      <PD.DNS,y           Flip bits with path descriptor's version
                    anda      #%00000010          Just keep track density
                    pshs      a                   Save it
                    lda       1,s                 Get track #
                    tst       ,s+                 96 tpi?
                    beq       L030A               No, skip ahead
                    lsla                          Yes, multiply track # by 2
                    lslb                          Multiply current track # by 2
* Entry: B=Current track #
*        A=Track # we want to go to
L030A               stb       >$FF49              Save current track in track register
                    tst       d0002,u             Same drive as one last accessed?
                    bne       L0318               No, skip ahead
                    ldb       ,s                  Get track # we want to go to
                    cmpb      <V.TRAK,x           Same as current track?
                    beq       L0324               Yes, skip ahead
L0318               sta       >$FF4B              Save track # we want to go to in data register
                    ldb       <PD.STP,y           Get stepping rate
                    andb      #%00000011          Only keep bits we need
                    eorb      #%00011011          Flip some bits for the controller
                    bsr       L032E               Program controller,come back when it ACKs request
L0324               puls      a                   Get back track # to go to
                    sta       <V.TRAK,x           Save as current track #
                    sta       >$FF49              Save into track register
                    clrb                          No error & return
L032D               rts

L032E               lda       #$04                Cache command
                    lbsr      L01B8               Go program drive controller & wait for response
                    lda       >$FF48              Eat status from drive controller
                    clr       >CachCtrl           Shut cache off & return
                    rts

* Another delay loop (for ACK'ing controller commands as received ???)
L033A               clr       <$12,u              Set flag (local to Disto)
                    inc       <$12,u              Setup for 8 rotates (delay loop?)
L0340               rol       <$12,u              Put out Most sig. bit
                    bpl       L0340               Keep going until we hit a 1 bit, then return
                    rts

* SS.Reset (restore head to track 0) system call
L0346               pshs      x,b                 Preserve register ptr & function code
                    lbsr      L02A5               Set up drive # & last drive accessed flag
                    bcs       L036E               Error, exit (BUT DESTROY ERROR #???)
                    ldx       <PD.DTB,y           Get Drive table ptr
                    clr       <V.TRAK,x           Current track #=0
                    lda       #$04                Set counter
L0355               ldb       <PD.STP,y           Get current stepping rate
                    andb      #%00000011          Only keep relevant bits (30,20,12 or 6 ms)
                    eorb      #%01001011          Flip some bits for the controller
                    pshs      a                   Preserve counter
                    bsr       L032E               Program controller,come back when it ACK's request
                    puls      a                   Restore counter
                    deca                          Do it 4 times
                    bne       L0355
                    ldb       <PD.STP,y           Get stepping rate again
                    andb      #%00000011          Just keep relevant bits
                    eorb      #%00001011          Flip some bits for controller
                    bsr       L032E               Program controller,come back when it ACK's request
L036E               puls      pc,x,b              Restore reg. ptr, function code & return to RBF

* SetStt entry point
SetStat             leau      >u00A7,u            Point to driver data area
                    ldx       PD.RGS,y            Get pointer to caller's register stack
                    ldb       R$B,x               Get function code requested
                    cmpb      #SS.WTrk            Write track?
                    beq       L0384               Yes, go do that
                    cmpb      #SS.Reset           Reset drive to track 0?
                    beq       L0346               Yes, go do that
                    comb                          Otherwise, unknown service error
                    ldb       #E$UnkSvc
                    rts

* Format/Write track entry point
L0384               pshs      u,y                 Preserve driver data area & Path dsc. ptrs
                    ldd       #$1A00              Huge buffer for format (6656 bytes)
                    os9       F$SRqMem            Request the memory
                    bcs       L03E2               Couldn't get it, exit with error
                    ldx       2,s                 Get driver data area ptr into X
                    stu       <d0013,x            Save ptr to 6656 byte buffer
                    ldx       <D.Proc             Get current process dsc. ptr
                    lda       P$Task,x            Get it's task #
                    ldb       <D.SysTsk           Get system task #
                    ldy       ,s                  Get path dsc. ptr back
                    ldx       PD.RGS,y            Get caller's register stack ptr
                    ldx       R$X,x               Get ptr to track buffer from caller
                    ldy       #$1A00              Move that data into system mem's buffer
                    os9       F$Move
                    bcs       L03D3               Error moving, return memory to system & exit
                    ldy       ,s                  Get path dsc. ptr back
                    ldu       2,s                 Get driver data ptr back
                    lbsr      L02A5               Set up drive # & flag
                    bcs       L03D3               Error, return memory to system & exit
                    ldx       PD.RGS,y            Get register stack ptr
                    ldb       R$Y+1,x             Get side/density from caller
                    bitb      #$01                Check side
                    beq       L03C4               Side 0, skip ahead
                    lda       d0001,u             Get drive's bit mask
                    ora       #%01000000          Force side 2 bit on
                    sta       d0001,u             Save new drive bit mask
                    sta       d0007,u             Save as side too (with bit 6 on???)
L03C4               lda       R$U+1,x             Get track # to write to
                    ldx       <PD.DTB,y           Get drive table ptr
                    lbsr      L02CC               Go seek to that track
                    bcs       L03D3               Error, return memory & exit
                    ldx       <d0013,u            Get ptr to track buffer
                    bsr       L03E4               Go write the track
L03D3               ldu       2,s                 Get driver data area ptr back
                    pshs      b,cc                Save error status
                    ldu       <d0013,u            Get ptr to system memory track buffer
                    ldd       #$1A00              Return that memory to the system
                    os9       F$SRtMem
                    puls      b,cc                Restore error status
L03E2               puls      pc,u,y              Restore regs & return

* Write track buffer
* Entry: X=ptr to track buffer
*        Y=ptr to path dsc.
*        U=ptr to device driver data mem
L03E4               pshs      y,cc                Preserve regs
                    orcc      #IntMasks           Shut off interrupts
                    ldb       #$F0                Write track command
                    stb       >$FF48              Send to controller
                    ldy       #$FFFF              # tries before we give up on writing track
                    ldd       #$0228              Data request bit mask & Double Density/Motors on
                    orb       d0001,u             Merge in side/drive selects
                    stb       >$FF40              Send to controller
                    orb       #%10101000          Enable halt/Double Dns/Motors on
                    lbsr      L033A               Small delay to let controller ACK command
L03FF               bita      >$FF48              Check DRQ flag on status register
                    bne       L041A               Controller ready, go write the track
                    leay      -$01,y              Bump counter down
                    bne       L03FF               Keep going until counter=0
                    lda       d0001,u             Get drive's bitmask
                    ora       #%00001000          Turn drive motor on
                    sta       >$FF40
                    lda       #$D0                Force interrupt on controller
                    sta       >$FF48
                    puls      y,cc                Restore regs
                    comb
                    ldb       #E$Write            Exit with Write error
                    rts

* Write data buffer to controller - Gets broken out by NMI
* ONLY USED ON WRITE TRACK: PROBABLY BECAUSE CACHE IS ONLY 256 BYTES
*   AND WOULDN'T FIT A WHOLE TRACK ANYWAYS
* Entry: X=current position in source buffer
*        B=Control register for controller
L041A               lda       ,x+                 Get byte from buffer
                    sta       >$FF4B              Save to controller's data register
                    stb       >$FF40              Save controller's control register stuff
                    bra       L041A               Keep going (NMI will break us out)

* Waste time until drives come up to speed
L0424               pshs      d                   Preserve D
                    ldd       <D.Proc             Get current process dsc ptr
                    cmpd      <D.SysPrc           Is the calling process the system?
                    puls      d                   Restore D
                    beq       L0433               Calling process is system, skip ahead
                    os9       F$Sleep             Otherwise, sleep for 40 ticks (.666 sec)
                    rts

* This routine is for the level 2 System state sleep bug. In NitrOS9, it
* could be removed (and the check for it as well, above)
L0433               ldx       #$A000              Time waste counter (40960)
L0436               nop       2                   cycles\
                    nop       2                   cycles \
                    nop       2                   cycles  > 14 cycles/loop, total of
                    leax      -1,x                5 cycles /  573440 cycles, 1/3 sec
                    bne       L0436               3 cycles/
                    rts

* Entry: U=u00A7
* Check if drive motors need time to get to speed,
L043E               pshs      y,x,d               Preserve regs (MAY NOT NEED TO PRESERVE Y)
                    ldd       #$00F0              Actual VIRQ counter to 240
                    std       d000A+Vi.Cnt,u      Save it
                    lda       d0001,u             Get drive's bit mask
                    ora       #%00001000          Mask in 'motors on' bit
                    sta       >$FF40              Send to controller
                    ldx       #$0028              # ticks to sleep to wait for drive to spin up
                    lda       <D.MotOn            Get floppy disk motor-on time out flag
                    bmi       L046B               VIRQ was not installed, try to install it again
                    beq       L0469               If drives aren't up to speed, go wait for them
                    tst       d0002,u             Is this the same drive as last accessed?
                    beq       L046D               Yes, don't have to wait for motors
                    lda       <PD.TYP,y           Get device type
                    bita      #$10                ??? (Do all motors turn on?)
                    beq       L046D               If 0, exit without error (yes, all do)
                    bsr       L0424               Go wait for drive motor
                    ldd       #$00F0              Actual VIRQ counter
                    std       d000A+Vi.Cnt,u      Save into packet
                    bra       L046D               No error & exit

L0469               bsr       L0424               Go wait for drive motor
L046B               bsr       L0470               Install VIRQ to signal us when done
L046D               clrb                          No error & return
                    puls      pc,y,x,d

* Install VIRQ to wait for drive motor to come up to speed
* If VIRQ can not be installed, D.MotOn is set to $80 to indicate this
L0470               lda       #$01                Set drive motor flag to 1 (up to speed)
                    sta       <D.MotOn
                    ldx       #$0001              Install VIRQ
                    leay      d000A,u             Point to 5 byte packet for VIRQ
                    clr       Vi.Stat,y           1 shot VIRQ
                    ldd       #$00F0              Initial VIRQ count
                    os9       F$VIRQ              Enable VIRQ
                    bcc       L0487               No error installing, exit
                    lda       #$80                Couldn't install VIRQ, set motor flag to negative
                    sta       <D.MotOn
L0487               clra                          No error & return
                    rts

* VIRQ/IRQ handler - for drive motors coming up to speed
* Entry: U=ptr to VIRQ memory area (u00A7)
L0489               pshs      a                   Preserve A
                    lda       >V.WAKE-u00A7,u     Get MSB of process dsc. that is waiting
                    beq       L049F               None, skip ahead
* Guess: cache is to send IRQ when drive controller sends cache an NMI
*   indicating that the controller is ready
                    ldb       #%00001100          ??? to cache (includes send interrupt flag)
                    stb       >CachCtrl           Tell cache to send interrupt when ready?
                    lda       #$D8                ??? Force interrupt on controller when it's ready?
                    sta       >$FF48
                    clr       d0004,u             Clear out retry count/flags
                    bra       L04A3               Exit

L049F               lda       <D.DMAReq           Get motor on lock flag
                    beq       L04A7               Not set, so shut them off
L04A3               bsr       L0470               Set up one shot IRQ for motor delay
                    bra       L04AE               Exit

L04A7               sta       >$FF40              Shut drive motors off
                    clr       d000A+Vi.Stat,u     Clear VIRQ as being serviced
                    clr       <D.MotOn            Set drive motor on flag to off
L04AE               puls      pc,a                Restore A & return

* Non-OS9 standard format goes here
* Entry: Y=Path dsc. ptr
L04B0               ldx       <PD.DTB,y           Get drive table pointer
                    ldb       #DD.RES+1           Clear out LSN0 copied info
L04B5               clr       b,x                 Clear them out
                    decb
                    bpl       L04B5               Until done
                    ldb       <PD.CYL+1,y         Get # of tracks
                    lda       <PD.SID,y           Get # of heads
                    mul                           Calculate # cylinders
                    subd      #$0001              Base 0
                    lda       <PD.SCT+1,y         Get # sectors/track
                    sta       DD.TKS,x            Save as track size in sectors
                    sta       <DD.SPT+1,x         and as # sectors/track
                    mul                           Multiply by # tracks <=255 (or it screws up)
                    addd      <PD.T0S,y           Add to # sectors on track 0
                    std       DD.TOT+1,x          Save # sectors on drive
                    lda       #UPDAT.+EXEC.       Set up disk attributes to Read/Write/Exec
                    sta       DD.ATT,x
                    lda       <PD.DNS,y           Get density
                    lsla                          Shift density bits to bits 1-2
                    pshs      a                   Save that a sec
                    lda       <PD.SID,y           Get # sides
                    deca                          0 based (bit 0)
                    ora       ,s+                 Merge in density bits
                    sta       <DD.FMT,x           Save as media format
                    clrb                          No error & return
                    rts

                    emod
eom                 equ       *
