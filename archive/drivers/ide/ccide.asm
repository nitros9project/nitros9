********************************************************************
* CCIDE - IDE device driver for CoCo
*
* DO NOT FORGET TO SET H6309 FLAG IN DEFSFILE APPROPRIATELY FOR 6809 VS.
*   6309 CODE WHEN ASSEMBLING!!
*
*  Driver originally from Jim Hathaway, originally 8-bit only
*  Converted to 16 bit by Alan DeKok
*  Disassembled (OK, so I didn't have the source version at first!)
*     by Eddie Kuns, ATA specs followed carefully and sector buffering
*     on writes handled more carefully
* This driver uses 16-bit transfers *only*
* Check with Glenside - can we switch to 16 bit only, so there is less to
*   maintain? With the cacheing stuff, the speed is fairly decent, although
*   some 6309 optimizations are still possible (cache copies, drive table
*   copies, hardware divide for CHS translation, etc.)
*
* NOTE: Currently, will return RAW error #'s from drive (see ATA bit flags
*   in error register). After driver finalized, switch back to OS9 error
*   codes.
* NOTE 2: drvrbusy checks are done even before hardware access, because
*  some variables are shared in the driver memory, and if a 2nd request
*  comes in in the middle of it, the vars might be changed at a dangerous
*  time. Note if you have two IDE controllers: since they get separate driver
*  memory from each other, that both controllers CAN be active at the same
*  time.
* BIG NOTE ON OLDER ATA-1 DRIVES!!!
* SOME DRIVES (MY MINISCRIBE 8051A INCLUDED) HAVE A TRANSLATION MODE THAT
* _IS_BUILT_INTO_THE_IDE_ROM_ITSELF! THE BAD PART IS, THE "IDENTIFY DRIVE"
* COMMAND _DOES_NOT_ TAKE THIS INTO CONSIDERATION, BUT RETURNS THE "NATIVE"
* DRIVE SPECS FOR CYLINDERS, HEADS & SECTORS PER TRACK. TO GET THE FULL
* CAPACITY OF THE DRIVE, WITHOUT ERRORS, YOU _MUST_ SET YOUR DEVICE
* DESCRIPTOR BASED ON THE HARDWARE _TRANSLATED_ SETTINGS, _NOT_ THE _NATIVE_
* SETTINGS (DESCRIBED IN THE IDENTIFY DRIVE COMMAND)! AS A REAL WORLD
* EXAMPLE, ON MY MINISCRIBE 8051A:
*   Drives "Native"  mode (as well as the Identify Drive command) returns:
*     745 cylinders, 4 heads & 28 sectors/cylinder.
*  HOWEVER, the "Translation" mode (which is checked off on the sticker on
*    the drive itself from the manufacturer), says:
*    Translated: 5 heads, 17 sectors. At this point, you will have to figure
*      out the # of cylinders, by computing the # of sectors TOTAL for the
*      drive in it's native mode (745*4*28 in the above example, or 83,440
*      sectors), and then dividing that value by (# of sectors/track * # of
*      heads) in the translation mode, and rounding down. In the above case,
*      83,440/(5*17)=981.647, so use 981 (which in hex is $03d5).
* Therefore, the proper device descriptor for this drive is:
*  cyl=3d5 sid=5 sct=22 t0s=22  (Actually, t0s is ignored by CCIDE)
*    The sct=22 is because the value is hexidecimal (it means 34 sectors/
*    track), and is double the 17 I mentioned above because OS9 sectors are
*    half the size of IDE sectors (256 bytes vs. 512 bytes). If this drive
*    had been shipped in "Native" mode, it would use the following:
*  cyl=2E9 sid=4 sct=38 t0s=38, which is what the IDENTIFY DRIVE command
*    reports.
* You can verify the highest cylinder # by setting the OFS in the descriptor
*   to what you think is the highest cylinder # (total # of cylinders-1 ...
*   remember that CHS cylinder numbers start at 0!), and then try to read
*   enough sectors to cover the whole track. If you go one past that value,
*   you should start getting errors if you have the right cylinder count.
* This is kind of a dumb system, but I assume it had something to do with
* IBM PC BIOS in the early days of IDE.
*A LITTLE LATER, WHEN THE DRIVER IS STABLE, MAY WANT TO ADD ANOTHER BIT FLAG
*  TO DRIVEFLG, SET UP BY A FIRST TIME READ: 8 BIT ACCEPTED. THEN, USE THE 8
*  BIT TRANSFER MODE IF POSSIBLE (LIKE I DID WITH LBA). THIS SHOULD ALLOW
*  MUCH FASTER SECTOR ACCESS ON A NITROS9 SYSTEM, AND IT WOULD BE INTERESTING
*  TO SEE HOW MANY DRIVES ACCEPT THAT MODE (SUPPOSED TO RETURN AN 'ABORTED'
*  FLAG IF IT DOES NOT).
* NOTE: RBF WILL ASSIGN NEW DEVICE MEM (,U PTR) TO _EACH_ CONTROLLER ON IT'S
*   OWN, BASED ON THE BASE ADDRESS FROM THE DEVICE DESCRIPTOR. THEREFORE,
*   CCIDE SHOULD BE SET UP FOR _2_ DRIVES MAX (PER CONTROLLER), AND LET RBF
*   TAKE CARE OF MULTIPLE CONTROLLERS.
*    The exception to this is when using partitions; since they will have a
*    separate descriptor for each partition, they will need a separate drive
*    table entry. Each table entry is $26 (38) bytes each, so it is not a lot.
*    Should make the device table fill up the rest of a 256 byte page (with
*    all other variables allocated), since OS9 will force System RAM pages to
*    even multiples of 256 anyways. Once full 8k block caching is implemented,
*    some of the two 256 byte sector buffers currently in system RAM could be
*    reused for more drive table entries as well. With current system RAM
*    requirements in driver, this would allow 5 device table entries without
*    taking any more system RAM then it is already. These can be shared in
*    whatever combination you need for your (up to) 2 physical drives.
* ALSO, RBF CALLS THE INIT ROUTINE ONLY ONCE PER _DRIVER_, NOT DRIVE!
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------
* 5      Source as distributed by Glenside                  99/05/02
*        Added comments from 8 bit driver               BGP 99/05/07
* 6      Driver now gets address from descriptor, made  BGP 99/05/10
*        minor optimizations, added symbols
* 7      Change to use real 16 bits                     LCB 99/09/06
*        partitions (both LBA & CHS)                     to 99/10/31
*        better error reporting
*        slightly optimized read
*        Half sector & LSN0 caches for current drive
*        Auto-sense/run LBA & CHS modes
*        Full CHS calculations (up to 4096 cylinders)
*          for ATA-1 old drive compatibility
* 8      Attempted to add support for removable media   LCB 00/05/27
*         commands (Door Lock/Unlock, Acknowledge Media  to 00/??/??
*         Change)
*        Attempt 'generic' ATA command system call
* Constants - change if needed
* NUMDRIVE is LOGICAL drives (partitions), NOT physical drives-use 5,11,etc
* 5=768 byte data area, 11=1024 byte data area
NUMDRIVE            equ       11                  Max. # of device descriptors per controller address
MAXWAIT             equ       60*5                Max. # clock ticks to give up on read/write (5 sec)
HDSclPwr            equ       2048                Set to 2048 as start ^2 cylinder (CHS translate)

* New definitions in Device Descriptor
PartOfs             equ       $26                 2 byte partition offset

* Definitions for DD.DNS
PhysDriv            equ       %00000001           Physical drive # (0=Master, 1=Slave)
ForceCHS            equ       %00000010           Force driver to use CHS mode

* New GetStat/SetStat calls:
* SS.DrInf call shares call # with SS.ScInf from NitrOS9 WindInt (info)
SS.DrInf            equ       $8f                 Drive info call (see routine for parms)
* Subcall #'s fro SS.DrInf (Y register on entry)
ATAIdent            equ       0                   ATA (handles ATAPI & plain ATA)

* IDE & ATAPI Commands (ATAPI stuff not implemented yet, and LBA is mandatory)
ReadRtry            equ       $20                 Read sector with retry
WritRtry            equ       $30                 Write sector with retry
Diagnost            equ       $90                 Execute drive diagnostic
Identify            equ       $EC                 Identify drive command
DoorLock            equ       $DE                 Lock drive
DoorUnLk            equ       $DF                 Unlock (eject) drive
AckMdChg            equ       $DB                 Acknowledge media change

PIIdent             equ       $A1                 Identify ATAPI drive command

* IDE Status Register
Busy                equ       %10000000           Drive busy (1=busy)
DrvReady            equ       %01000000           Drive ready (1=ready to accept command)
WriteFlt            equ       %00100000           Drive Write Fault (1=Write fault?)
SeekDone            equ       %00010000           Seek Complete (1=Seek complete)
DataReq             equ       %00001000           Data Request (1=drive ready for read/write data)
CorrData            equ       %00000100           Corrected Data (1=correctable data error was done)
Index               equ       %00000010           1=1 disk revolution completed
ErrorFnd            equ       %00000001           1=Error detected - see error register

* IDE hardware offsets
DataReg             equ       0                   Data (1st 8 bits, non-latched)
Error               equ       1                   Error # when read
Features            equ       1                   Features when write
SectCnt             equ       2                   Sector count
SectNum             equ       3                   Sector #
CylLow              equ       4                   Low byte of cylinder
CylHigh             equ       5                   High byte of cylinder
DevHead             equ       6                   Device/Head
Status              equ       7                   Status when read
Command             equ       7                   Command when write
Latch               equ       8                   Latch (2nd 8 bits of 16 bit word)

* Special flags (Mini extra drive table - 1 byte per drive) - starts at
*    DriveFlg,u
* These are set by inquiring the drive, NOT from the descriptor
* Should add a GETSTAT to allow user to access these for any drive
Unused              equ       %10000000           Entry is un-initialized
DrvMode             equ       %00000001           0=CHS mode, 1=LBA mode
ATAPI               equ       %00000010           0=Device is ATA,1=Device is ATAPI
Remove              equ       %00000100           0=Fixed Drive, 1=Removable media
ReadOnly            equ       %00001000           0=Read & write allowed, 1=Read only (CD-ROM)
*                           Could also use to write-protect hard drive
                    nam       CCIDE
                    ttl       IDE device driver for CoCo

                    ifp1
                    use       defsfile
                    endc

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             equ       8

                    mod       eom,name,tylg,atrv,start,size

* NOTE: OS9 WILL ALWAYS ASSIGN DRIVER MEM SPACE ON AN EVEN 256 BYTE PAGE,
*   SO TAKE ADVANTAGE OF "EXTRA" SPACE!

                    org       0
                    rmb       DRVBEG+(DRVMEM*NUMDRIVE)
* Start of driver-specific statics
SlpCntr             rmb       2                   # ticks left before we give up on a read/write
PhysDrv             rmb       1                   Physical drive # (for quick lookup)
DriveFlg            rmb       NUMDRIVE            1 byte per drive (bit flags)
OS9LSN              rmb       3                   LSN of current OS-9 256-byte sector
* IDE spec can handle 28 bits (4 bits of 4th byte) for LBA mode. Since OS9
*   can't get that high anyways, we only work with 3, and then use the offset
*   partition value to bump it up beyond the 4 GB mark.
OS9PSN              rmb       3                   PSN of current OS9 sector (512 byte)
DrivMask            rmb       1                   Drive # (0 or 1) for IDE (in proper bit position)
idecmd              rmb       1                   1 byte IDE command code
identcmd            rmb       1                   1 byte IDE Identify drive code

* Following flag is because the IDE interface can NOT access a 2nd drive
*   while the 1st drive is completing a read or write. Because of shared
*   device memory variables, this flag is set even on cached entries.
drvrbusy            rmb       1                   Driver busy flag (0=not busy)

* Following for CHS mode drives only!
Head                rmb       1                   Head # (s/b base 0)
Cylinder            rmb       2                   Cylinder #
CHSSect             rmb       1                   CHS mode sector #
CHSSPT              rmb       2                   CHS mode sectors/track

* Buffer/cache variables
LSN0Flag            rmb       1                   $FF=Not LSN0, $00=LSN0
Sect0Drv            rmb       1                   Drive # of LSN0 currently buffered ($FF=none)
Sect0Ofs            rmb       2                   Offset value for current LSN0 buffered drive
TempHalf            rmb       3                   Temp spot to hold other half calculation
HalfDrv             rmb       1                   Drive # of HalfBuff buffered ($FF=none)
HalfOfs             rmb       2                   Offset value for drive for current cached sector
HalfSct             rmb       3                   OS9 sector # of half sector not asked for
TempOfs             rmb       2                   Temporary copy of partition offset

* NOTE: When 8k block buffering is added, move both of these to that block.
*   Of course, if removable media, re-read LSN0 physically every time. At that
*   time, we should make tables here instead (32 entries per drive up to the
*   maximum # of drives) of LSN #'s buffered (3 bytes/entry).
Sect0               rmb       256                 Buffer for LSN0
HalfBuff            rmb       256                 Buffer for other half of 512 byte phys. sector
size                equ       .

                    fcb       $FF                 mode byte

name                fcs       /CCIDE/             module name

* INIT - appears to only be called on 1ST try on ANY IDE device IF link counts
*   are 0.
* Y = address of path descriptor (but
* U = address of driver memory (ie, of V.PAGE)
* Inits the drive table, and the DriveFlg table
Init                ldd       #$8000+NUMDRIVE     Flag that special drive flags are all unused
                    leax      DriveFlg,u
DrvFlgLp            sta       ,x+
                    decb
                    bne       DrvFlgLp
GoInit              leax      DRVBEG,u            Point to start of drive tables
                    ldd       #$FF00+NUMDRIVE
                    stb       V.NDRV,u            Max # of drives
                    sta       Sect0Drv,u          Flag that no LSN0 is buffered
                    sta       HalfDrv,u           Flag that we have no half sector buffered
NextDrv             sta       DD.TOT,x            Set Total # of sectors to illegal value
                    sta       V.TRAK,x            Non 0, so 1st seek can read Track 0
                    leax      DRVMEM,x            Point to next drive
                    decb                          Dec # of drives left
                    bne       NextDrv             Still more, init them too
                    clrb                          No error & return
                    rts

* Do drive diagnostic (use CHS mode) - Do not worry about ATAPI at this point
* Entry: U=driver mem ptr
*        Y=path descriptor
*        B=Identify command
* Exit:  CC clear - drive ready to send info
*        CC set   - error from drive, B contains raw error register
* TRASHES X - does timeout (CHECK - WILL SOME DRIVES TAKE TOO LONG?)
* This is called by INIT, and should also be called by a GETSTAT at some
*  point.
Ident               pshs      y                   Save path descriptor
                    stb       identcmd,u          Save which Ident we are doing
                    ldy       V.PORT,u            Get IDE controller address
DoIdent             lda       DrivMask,u          Get drive # requested
                    ora       #%10100000          Mask in head 0 & CHS mode
                    std       DevHead,y           Send drive/head to controller, and IDENTIFY
* Note, if person booting from ROM, drive may not have spun up yet. See if
*   we can check some sort of status or error flag that indicates drive is
*   still firing up, if this is a problem.
                    ldx       #$a000              Arbitrary amount of time to give up
WaitIdnt            lda       Status,y            Get Status register
                    bmi       NoErr               Busy, drop counter
                    bita      #ErrorFnd           Error?
                    beq       NoErr               No, continue
                    ldb       Error,y             Get error code
                    bra       BadIdent

NoErr               cmpa      #DrvReady+SeekDone+DataReq Drive ready to send Identify data?
                    beq       GotIdent            Yep, exit out
                    leax      -1,x                Drop timer
                    bne       WaitIdnt            Keep trying
                    ldb       #E$NotRdy           Timed out, device not ready error
BadIdent            coma                          Flag error
                    puls      y,pc                Restore path descriptor & return

GotIdent            clrb                          No error
                    puls      y,pc                Restore path descriptor & return

* Send Identify drive command (ATA or ATAPI - see identcmd,u), update DriveFlg
*   table
* PLEASE NOTE: The 2 identify commands are mutually exclusive; it will fail
*  with an 'Aborted' error if the wrong Identify is used.
*  UNLIKE A NORMAL READ OF A SECTOR, THE INFORMATION CONTAINED IN THE IDENTIFY
*  DRIVE COMMAND IS ALL IN INTEL ORDER WORD (16 BITS)
* Entry: Y=Ptr to path descriptor
*        U=Ptr to driver memory
* X IS DESTROYED!
* Exit:  CC=0 if DriveFlg properly updated
*          & A=DriveFlg value from update entry in table
*        CC=1, B=error if Identify Drive failed
*        DriveFlg,u - the proper flags for the specified controller/drive are
*                     updated
*        Sect0 contains 1st 256 bytes, HalfBuff contains 2nd half
IdentDrv            lbsr      WaitDrv             Wait for IDE to be ready
                    ldb       #Identify
                    bsr       Ident               Send identify drive command to controller
                    bcc       DoInfo              Worked, Do info
                    bitb      #%00000100          Error, Aborted Flag set?
                    beq       ExitIdnt            No, exit with other error
                    ldb       #PIIdent            Try ATAPI identify
                    bsr       Ident
                    bcs       ExitIdnt            That didn't work either, abort
DoInfo              leax      Sect0,u             Point to buffer
* NOTE: INIT routine only gets called when the DRIVER is Initing...not every
*   device. Hence, READ/WRITE must check the DriveFlg settings and make sure
*   the hi bit is clear for the drive it is using, to indicate that it HAS
*   been set properly from an Identify Drive command.
* Read in 1st 256 bytes of Identify Drive buffer, parse out info we need
*   for our special flag table
                    lbsr      Read256             Generic 256 byte copy from IDE routine
                    ldb       #$FF                Since we made it this far, flag that HalfBuff
                    stb       HalfDrv,u           & Sect0Drv are now bogus
                    stb       Sect0Drv,u
                    clra                          Set current flags to all off
                    leax      Sect0,u             Point to start of buffer again
                    ldb       ,x                  Get general config low byte
                    andb      #%10000000          Removable cartridge bit set?
                    beq       CheckLBA            No, check LBA mode
                    ora       #Remove             Set removable media flag
CheckLBA            ldb       99,x                Get LBA mode byte
                    andb      #%00000010          LBA allowed on this drive?
                    beq       ChkATAPI            No
                    ora       #DrvMode            Yes, set LBA flag
ChkATAPI            ldb       identcmd,u          Get Identify drive command type
                    cmpb      #PIIdent            ATAPI?
                    bne       SetFlg              No, set drive flags
                    ora       #ATAPI              Set ATAPI flag
SetFlg              ldb       PD.DNS,y            Get special settings flags
                    bitb      #ForceCHS           Force CHS mode on?
                    beq       LeavAlon            No
                    anda      #^DrvMode           Yes, force to CHS mode
LeavAlon            ldb       PD.DRV,y            Get Logical drive #
                    leax      DriveFlg,u          Point to drive flags table
                    sta       b,x                 Save flags
                    pshs      a                   Save for exit
                    leax      HalfBuff,u          Point to 2nd buffer
                    lbsr      Read256             Identify info part 2
                    lbsr      WaitOK              Make sure drive finished command
                    puls      a                   Restore flags byte
ExitIdnt            rts                           No error, return

* Entry: U=driver memory ptr
*        Y=path descriptor ptr
GetStat             ldx       PD.RGS,y            Get ptr to callers register stack
                    lda       R$B,x               Get function code
                    cmpa      #SS.DrInf           Drive info command?
                    bne       NextGet             No, try next
                    ldd       R$Y,x               Get sub-function type
                    beq       GoodFunc
                    comb                          Only sub-functions 0 allowed for IDE
                    ifge      Level-2
                    ldb       #E$IllArg
                    else
                    ldb       #187
                    endc
ExitGet             rts

GoodFunc            pshs      x,y,u               Preserve regs
                    bsr       IdentDrv            Get either ATA or ATAPI Identify info
                    bcc       GotInfo             Something wrong, return
                    puls      x,y,u,pc            Restore regs, return with error

GotInfo             leay      Sect0,u             Point to start of 512 byte buffer
                    ldx       #256                # of two byte entries in buffer
SwapLoop            ldd       ,y                  Swap all words to Motorola order
                    exg       a,b
                    std       ,y++
                    leax      -1,x
                    bne       SwapLoop
                    leay      Sect0,u             Point to start of buffer again
                    ldx       114,y               Get Current Capacity, swap to Motorola
                    ldd       116,y
                    stx       116,y
                    std       114,y
                    ldx       120,y               Get LBA sector count, swap to Motorola
                    ldd       122,y
                    stx       122,y
                    std       120,y
                    ifge      Level-2
                    lda       <D.SysTsk           Get system task #
                    ldx       <D.Proc             Get user task ptr
                    ldb       P$Task,x            Get user's task #
                    leax      Sect0,u             Point to source buffer
                    ldu       ,s                  Get ptr to PD.RGS
                    ldu       R$X,u               Get Destination ptr
                    ldy       #512                Move 512 bytes to caller
                    os9       F$Move
                    else
                    endc
                    puls      x,y,u               Restore regs to normal
                    bcc       SetUserR            No error, set exit registers for caller
                    rts

SetUserR            ldd       #512                # of bytes returned=512 (Callers Y)
                    std       R$Y,x
                    clrb                          Device type=ATA
                    lda       identcmd,u          Get which Identify Drive command worked
                    cmpa      #PIIdent            ATAPI?
                    bne       SaveType            No, save ATA as type
                    incb
SaveType            lda       PD.DRV,y            Get logical drive #
                    leay      DriveFlg,u          Point to drive flag table
                    lda       a,y                 Get drive flags
                    std       R$D,x               Save drive flags & device type
                    clrb
                    rts

NextGet             comb
                    ldb       #E$UnkSvc
                    rts

SetStat             clrb
                    rts

start               lbra      Init
                    lbra      Read
                    lbra      FWrite
                    lbra      GetStat
                    lbra      SetStat
                    clrb                          Term routine (does nothing)
                    rts

NotBsy              lda       #$FF
                    sta       drvrbusy,u
                    rts

* Checks if driver is busy, retries & possibly sleeps if it is.
* Set's driver to busy again when done.
* A reg is destroyed, all others are preserved
ChekBusy            lda       #64                 # of fast retries for driver
BsyTst              tst       drvrbusy,u          Is current driver/controller already in use?
                    beq       NotBsy              No, continue
                    deca
                    bne       BsyTst              Try up to 64 times
                    pshs      x                   Otherwise, sleep a tick & try again
                    ldx       #1
                    os9       F$Sleep
                    puls      x
                    bra       ChekBusy

* Save OS9 LSN & Physical PSN (not including any partition offset)
* Also saves sector # of other half that is buffered
* Will have to add check later for ATAPI stuff, up to 2048 bytes/sector
*   for CD ROM
* Entry: U=ptr to driver mem
*        B:X=OS9 LSN
* Exit:  B:X=OS9 LSN
*      OS9PSN updated (512 byte Physical sector # that IDE needs)
*      TempHalf updated to cached LSN # (Use HalfDrv to figure out if legit
*        or not)
*      TempOfs updated to current partition offset
*      Zero flag set if LSN0 was requested (also saved at LSN0Flag,u)
*      PhysDrv set to physical drive #
SavLSN              pshs      b,x                 Save work copy of LSN
                    lda       PD.DNS,y            Make copy of physical drive #
                    anda      #PhysDriv
                    sta       PhysDrv,u
                    clra                          Flag: LSN0
                    stb       OS9LSN,u            Save OS-9 LSN
                    beq       dox                 Could be LSN0
                    inca                          Not LSN0
dox                 stx       OS9LSN+1,u
                    beq       doPSN               Is LSN0
                    inca                          Not LSN0
doPSN               sta       LSN0Flag,u          Save LSN0 flag (0=Yes, anything else, no)
                    stb       OS9PSN,u            Save OS-9 PSN
                    stx       OS9PSN+1,u
                    lsr       OS9PSN,u            Divide LSN by 2 for PSN (512 bytes/sector)
                    ror       OS9PSN+1,u
                    ror       OS9PSN+2,u
                    bcc       Even                Even sector requested, half will be odd (+1)
* Subtract 1 from current LSN
                    ldd       1,s
                    subd      #1
                    std       1,s
                    ldb       ,s
                    sbcb      #0
                    bra       SaveExit

* Add 1 to current LSN
Even                ldd       1,s
                    addd      #1
                    std       1,s
                    ldb       ,s
                    adcb      #0
SaveExit            ldx       1,s
                    stb       TempHalf,u          Save buffered sector #
                    stx       TempHalf+1,u
                    leas      3,s                 Eat temp stack
                    ldx       PD.DEV,y            Get ptr to device table entry
                    ldx       V$DESC,x            Get device descriptor ptr
                    ldx       PartOfs,x           Get partition offset value
                    stx       TempOfs,u           Save copy of it
                    ldb       OS9LSN,u            Restore LSN
                    ldx       OS9LSN+1,u
                    lda       LSN0Flag,u          Set CC bits for LSN0 compare
                    rts

* READ
* Entry: Y = address of path descriptor
*        U = address of device memory (ie, of V.PAGE)
*        B = MSB of OS-9 disk LSN
*        X = LSB of OS-9 disk LSN
* Eventually change LSN stuff to use a bit from descriptor as to whether
*   buffered LSN0 or not. (After that, add in for general 8k block buffering
*   or not).
* Later, add check for DriveFlg that sees if device has removable media. If
*   not, and caching for each logical drive is done, keep PERMANENT copy of
*   LSN0 at all times, and just copy it when requested (WRITE will update copy
*   if new LSN0 is written).
* MAKE SURE WRITE ROUTINE UPDATES CACHING STUFF CORRECTLY!
Read                lbsr      ChekBusy            Wait for driver to be unbusy
                    bsr       SavLSN              Save LSN/PSN, PartOfs & HalfSect info
                    bne       NotLSN0             Not LSN0, skip ahead
* Theoretically, following REM'ed out lines will handle removable media:
*         lda   DriveFlg,u     Get drive flag settings
*         bita  #Remove        Removable media?
*         bne   NotLSN0        Yes, LSN0 may change from disk swap

* LSN0 - 1st see if buffered
                    lda       PhysDrv,u           Get requested physical drive #
                    cmpa      Sect0Drv,u          Same drive in LSN0 cache?
                    bne       PhysRead            No, go physically read off of drive
                    ldx       TempOfs,u           Get copy of partition offset
                    cmpx      Sect0Ofs,u          Same as cached LSN0 offset?
                    bne       PhysRead            No, physically read the sector
* LSN0 buffered goes here - later add check against DriveFlg with removable
*   media bit - if non-removable, copy from cache, otherwise to physical read
                    leax      Sect0,u             Point to LSN0 cache
                    bra       CopyBuff            Copy to caller's PD.BUF, exit from there

* Not LSN0 - see if normal sector is currently cached.
* Entry: B:X=LSN
NotLSN0             cmpb      HalfSct,u           Same as cached sector?
                    bne       PhysRead
                    cmpx      HalfSct+1,u         Same as cached sector?
                    bne       PhysRead
                    lda       PhysDrv,u           Same drive as cached?
                    cmpa      HalfDrv,u
                    bne       PhysRead            No, need physical read of sector
                    ldd       TempOfs,u           Get current request's Partition offset
                    cmpd      HalfOfs,u           Same as cached?
                    bne       PhysRead            No, physical read of sector
* Non-LSN0 sector is cached - if removable drive, force physical read unless
*   we somehow monitor disk swaps (some media require Eject commands)
                    leax      HalfBuff,u          Point to cached sector
* Copy sector from cache buffer to caller's buffer
* Entry: X=Ptr to cache buffer (either Sect0, or HalfBuff)
CopyBuff            clrb                          256 counter
                    ldy       PD.BUF,y            Point to caller's buffer
CpyLoop             lda       ,x+                 Copy it
                    sta       ,y+
                    decb
                    bne       CpyLoop
                    clr       drvrbusy,u          Flag driver not busy
                    rts

* Not buffered in any way - physical read required - update cache tags AFTER
*   read, or flag with $FF if failed.
* Entry: Y=Ptr to path descriptor
*        U=Driver mem
PhysRead            lbsr      InitRead            Tell IDE to read sector
                    bcc       DoRead              No error, do read
FlagBad             lda       #$FF                If IDE can't even initiate read, flag both
                    sta       Sect0Drv,u          LSN0 and HalfBuff as bad
                    sta       HalfDrv,u
                    lbra      RprtErr

* Entry: Y=path dsc. ptr
*        U=Driver mem ptr
DoRead              lda       OS9LSN+2,u          Get LSB of OS9 sector #
                    lsra                          Shift 1/2 512 sector flag out
                    bcs       DoOdd               Odd sector, buffer even one 1st
                    ldx       PD.BUF,y            Get pointer to caller's buffer
                    bsr       Read256             Copy 1st half of HD sector there
                    leax      HalfBuff,u          Point to cache buffer
                    bsr       Read256             Copy 2nd half of HD sector there
                    bra       FinRead             Finish the Read command on IDE

* Copy to cache 1st (Odd sector # request)
DoOdd               leax      HalfBuff,u          Point to cache buffer
                    bsr       Read256             1st half goes there
                    ldx       PD.BUF,y            Get pointer to caller's buffer
                    bsr       Read256             2nd half goes there
FinRead             lbsr      WaitOK              Wait for drive to complete command
                    bcc       DoneRead            No error, exit
                    lbra      RprtErr             Exit with error

* Update HalfSct vars to whatever is in TempHalf
GoodCach            ldd       TempHalf,u          Copy Buffered LSN to HalfSct
                    std       HalfSct,u
                    lda       TempHalf+2,u
                    sta       HalfSct+2,u
                    ldd       TempOfs,u           Get partition offset
                    std       HalfOfs,u           Save it
                    lda       PhysDrv,u           Copy drive # to HalfDrv
                    sta       HalfDrv,u
                    rts

* Entry: Read command complete on IDE.
*   Y=ptr to path descriptor
*   U=ptr to driver mem
DoneRead            bsr       GoodCach            Update HalfSct stuff with Temp stuff
                    ldb       LSN0Flag,u          Was this LSN0?
                    bne       GoodExit            No, leave
* LSN0 just physically read - update drive table
* CHANGE EVENTUALLY TO CHECK IF NON-REMOVABLE MEDIA; IF IT IS, DON'T BOTHER
*   WITH THESE CHECKS!
                    sta       Sect0Drv,u          Save which drive LSN0 is buffered
                    ldd       TempOfs,u           Restore partition offset again
                    std       Sect0Ofs,u          Save for LSN0
                    leax      Sect0,u             Point to LSN0 buffer
                    clrb                          256 counter
                    pshs      y                   Save path dsc. ptr
                    ldy       PD.BUF,y            Point to caller's buffer
LSN0Loop            lda       ,y+                 Copy LSN0 from callers buffer to LSN0 cache
                    sta       ,x+
                    decb
                    bne       LSN0Loop
                    puls      y                   Restore path dsc. ptr
                    leax      Sect0,u             Point to LSN0 cache again
CopyTbl1            lbsr      CpyDrvTb            Copy LSN0 stuff to drive table
GoodExit            clr       drvrbusy,u          No error & return
                    rts

* Initiate the 512 byte READ sequence
* Entry: U=Driver mem ptr
*        Y=Path dsc. ptr (?)
* Exit:  CC=0 if no error
*        CC=1 if error
*            B=Error code
InitRead            ldb       #ReadRtry           Read sector (with retry) IDE command
                    lbra      SetIDE              Send to IDE, return from there (w or w/o err)

* Copy 256 bytes of data from IDE controller (after READ, etc.)
* Entry: X=ptr to 256 byte destination buffer
*        U=ptr to driver memory
* Exit: 256 bytes copied
*        B is destroyed, A=0
*        Y is preserved
Read256             lda       #$20                # of loops (of 8 bytes)
                    pshs      y,a                 Save y & counter
                    ldy       V.PORT,u            Get ptr to IDE controller for this drive
ReadLp              lda       ,y                  Get 16 bits of data, and save in buffer, 8
                    ldb       Latch,y             times
                    std       ,x
                    lda       ,y
                    ldb       Latch,y
                    std       2,x
                    lda       ,y
                    ldb       Latch,y
                    std       4,x
                    lda       ,y
                    ldb       Latch,y
                    std       6,x
                    leax      8,x                 Bump ptr up
                    dec       ,s                  Done all bytes?
                    bne       ReadLp              No, keep going
                    puls      a,y,pc              Restore Y & return

* WRITE - Can use cache data, or preread sector
* Y = address of path descriptor
* U = address of device memory (ie, of V.PAGE)
* B = MSB of OS-9 disk LSN
* X = LSB of OS-9 disk LSN
* 1st , see if other half is buffered in HalfBuff
FWrite              lbsr      ChekBusy            Wait for driver to be unbusy
                    lbsr      SavLSN              Save LSN info, set LSN0Flag for later
                    ldb       TempHalf,u          Get OS9 LSN of 'other half' of 512 byte sector
                    cmpb      HalfSct,u           Same MSB of buffered sector #?
                    bne       ChkLSN1             No, check if LSN1
                    ldx       TempHalf+1,u        LSW of 'other half'
                    cmpx      HalfSct+1,u         Same as LSW of buffered sector #?
                    bne       ChkLSN1             No, check if LSN1
                    ldd       HalfOfs,u           Same partition as buffered sector's drive?
                    cmpd      TempOfs,u
                    bne       ChkLSN1             No, check if LSN1
                    lda       PhysDrv,u           Same physical drive as buffered sector's drive?
                    cmpa      HalfDrv,u           Same as buffered sector's drive?
                    bne       ChkLSN1             No, check is LSN1
* Buffered sector IS the other half of current write sector...no preread nec-
*   essary.
                    lbsr      InitWrit            Send Write command to IDE, setup mode, etc.
                    bcc       GoodWrit            No problems, continue with Write
                    lbra      FlagBad             Flag caches as bad, exit with error

* See if request is for LSN1, in which case we may have LSN0 buffered
ChkLSN1             ldb       OS9LSN,u            Get MSB of sector to write
                    bne       PreRead             Not 0, need physical preread
                    ldx       OS9LSN+1,u          Get LSW of sector to write
                    cmpx      #1                  LSN=1?
                    bne       PreRead             Not LSN1, need to preread sector
                    lda       PhysDrv,u           Get physical drive #
                    cmpa      Sect0Drv,u          Same as buffered LSN0?
                    bne       PreRead             No, need physical preread
                    ldd       TempOfs,u           Get partition offset of requested sector
                    cmpd      Sect0Ofs,u          Same as buffered?
                    bne       PreRead
* We have LSN0 buffered for an LSN1 write
                    lbsr      InitWrit            Send Write to IDE
                    bcc       ContWrt1            Successful, continue
                    lbra      RprtErr

ContWrt1            leax      Sect0,u             Point to buffered Sector 0
                    bsr       Write256            Write to IDE
                    ldx       PD.BUF,y            Get ptr to caller's LSN1 buffer
                    bsr       Write256            Write to IDE
                    bra       FinWrite            Complete the write command

* Nothing buffered, pre-read sector in so we have other half to write.
* Note that OS9PSN is already set to the correct physical sector.
PreRead             lbsr      InitRead            Send Read command to IDE
                    bcc       GotPreRd            No problem, continue
                    lbra      FlagBad             Flag caches as bad; exit with error

GotPreRd            lda       OS9LSN+2,u          Get least sig. byte of LSN to write
                    lsra                          Odd or even sector?
                    bcc       ReadOdd             Even write sector requested
* Odd write requested
                    leax      HalfBuff,u          Point to 1/2 sector cache
                    lbsr      Read256             Read it in
                    bsr       Eat256              Bleed off other half (not needed)
                    bra       FinPre

* Even sector to write - buffer odd one
ReadOdd             bsr       Eat256              Bleed 1st half
                    leax      HalfBuff,u          Read in 2nd half
                    lbsr      Read256
FinPre              lbsr      WaitOK              Get OK from controller
                    bcc       DonePre             Good, continue
BadExit             lbra      RprtErr             Error, exit with it

DonePre             lbsr      GoodCach            Update HalfSct stuff only
                    lbsr      InitWrit            Initialize Write command
                    bcs       BadExit
* Now, onto the write
GoodWrit            ldb       OS9LSN+2,u          Get least sig. byte of LSN
                    lsrb                          Odd or even sector to write?
                    bcs       BuffWOdd            Write fully buffered Odd
* We are writing even portion, odd is in cache
                    ldx       PD.BUF,y            Get ptr to caller's 256 byte buffer
                    bsr       Write256            Write to IDE
                    leax      HalfBuff,u          Point to cached sector
                    bsr       Write256            Write to IDE
                    bra       FinWrite

BuffWOdd            leax      HalfBuff,u          Point to cached sector
                    bsr       Write256            Write to IDE
                    ldx       PD.BUF,y            Point to caller's 256 byte buffer
                    bsr       Write256            Write to IDE
FinWrite            lbsr      WaitOK              Wait for IDE to be done command
                    bcc       DoneWrit            No error, done writing
                    lbra      RprtErr             Error, exit with it

* Write 256 bytes from ,x to IDE
* Entry: X=ptr to 256 buffer to write
*        U=driver mem ptr
* Exit: 256 bytes written
*        B is destroyed, A=0
*        X=end of buffer+1
*        Y is preserved
Write256            lda       #$20                # of 8 byte loops
                    pshs      y,a                 Save Y & loop counter
                    ldy       V.PORT,u            Get IDE base address
WritLp              ldd       ,x                  Copy 256 bytes from buffer to IDE
                    stb       Latch,y
                    sta       ,y
                    ldd       2,x
                    stb       Latch,y
                    sta       ,y
                    ldd       4,x
                    stb       Latch,y
                    sta       ,y
                    ldd       6,x
                    stb       Latch,y
                    sta       ,y
                    leax      8,x
                    dec       ,s
                    bne       WritLp
                    puls      a,y,pc              Restore regs & return

* Eat 256 bytes from IDE (hopefully, triggering latch will skip having to
*  read even bytes)
* Entry: U=driver memory ptr
*        Y=Path descriptor ptr
* Exit: 256 bytes bled off of sector buffer on IDE
* All regs preserved
Eat256              pshs      d,x                 Save regs
                    ldb       #$20                32 loops
                    ldx       V.PORT,u            Get pointer to IDE
EatLp               lda       ,x                  Read seems to be a pre-trigger
                    lda       ,x                  Eat each 16 bit trigger byte
                    lda       ,x
                    lda       ,x
                    decb
                    bne       EatLp
                    puls      d,x,pc              Restore regs & return

* Write command to IDE completed successfully
* Update cache (copy PD.BUF to Cache if even sector, so a sequential
*   write will have the 1st half cached, or leave current cache alone if
*   odd). Also, check if LSN0. If it is, copy to LSN0 cache, updating
*   vars, and copy drive table info
DoneWrit            ldb       LSN0Flag,u          Was it sector 0?
                    beq       WritLSN0            Yes, special processing for that
                    ldb       OS9LSN+2,u          Get LSB of sector #
                    lsrb                          Odd/Even?
                    bcc       CpyCache            Even, copy to Cache
* Odd sector written, leave cache as is
                    clr       drvrbusy,u          Exit without error
                    rts

* Copy PD.BUF sector to HalfBuff cache, update cache tags
CpyCache            lda       PhysDrv,u           Set cache vars for PD.BUF sector
                    sta       HalfDrv,u
                    ldd       TempOfs,u
                    std       HalfOfs,u
                    ldd       OS9LSN,u
                    std       HalfSct,u
                    lda       OS9LSN+2,u
                    sta       HalfSct+2,u
                    leax      HalfBuff,u          Point to 1/2 sector cache
CachBuff            clrb
                    ldy       PD.BUF,y            Get ptr to callers buffer
CachLp              lda       ,y+                 Copy even sector to cache (in case of sequential
                    sta       ,x+                 writes)
                    decb
                    bne       CachLp
                    clr       drvrbusy,u
                    rts

* We wrote LSN0 - 1st, update LSN0 cache tags, then copy PD.BUF to Sect0,
*   then update drive table entry.
* Entry: U=drive mem ptr
*        Y=path dsc. ptr
WritLSN0            lda       PhysDrv,u           Copy cache tag stuff for Sect0 cache
                    sta       Sect0Drv,u
                    ldd       TempOfs,u
                    std       Sect0Ofs,u
                    leax      Sect0,u             Point to LSN0 cache
                    bsr       CachBuff            Copy from PD.BUF to Sect0 buff
                    leax      Sect0,u             Point to LSN0 cache again
                    clr       drvrbusy,u
                    lbra      CpyDrvTb            Copy info to drive table, exit from there

* Initialize Write sequence to IDE
* Entry: U=driver mem ptr
*        Y=Ptr to path descriptor
* Exits back to calling routine. CC=0 if command ready on controller
*  CC=1, B=Raw IDE error code if command failed
InitWrit            ldb       #WritRtry           IDE Write w/ Retry command
                    bra       SetIDE              Send to IDE, return from there w or w/o error

* After read or write, check drive status
* Exit: CC=0, command ok, CC=1, Error from IDE (B=Raw error code)
*   X=Ptr to hardware address
WaitOK              ldx       V.PORT,u            Get status register
WaitLp              tst       Status,x            Still busy, wait till unbusy
                    bmi       WaitLp
                    lda       #ErrorFnd           Check Error flag
                    bita      Status,x            Error from controller?
                    bne       RprtErr             Yes, go get error
                    clrb                          No, exit without error
                    rts

* Entry: B=Error code from IDE
RprtErr             lsrb
                    bcc       ChkTk0
SctrExit            ldb       #E$Sect             Bad sector # for Addres Mark Not Found
                    bra       ExitErr

ChkTk0              lsrb
                    bcc       ChkMdChg
SeekExit            ldb       #E$Seek             Seek error for Track 0 not found
                    bra       ExitErr

ChkMdChg            lsrb
                    bcc       ChkAbrt
MdChExit            ldb       #E$DIDC             Media changed error
                    bra       ExitErr

ChkAbrt             lsrb
                    bcc       ChkIdnf
                    ldb       #E$UnkSvc           Unknown service error for aborted command
                    bra       ExitErr

ChkIdnf             lsrb
                    bcs       SctrExit            Sector error for ID not found
                    lsrb
                    bcs       MdChExit            Media changed error for Media Change
                    lsrb
                    bcc       ChkBBK
                    ldb       #E$CRC              CRC Error for Uncorrectable data
                    bra       ExitErr

ChkBBK              lsrb
                    bcs       ReadExit            Read error for Bad Block Detected
* Error flag set, but no error condition
                    lbra      ENotRdy             Assume drive not ready

ReadExit            ldb       #E$Read
ExitErr             clr       drvrbusy,u          Flag driver not busy
                    coma                          Set carry & exit
                    rts

BadUnit             ldb       #E$Unit
                    bra       ExitErr

CmdErr              ldb       Error,x             Get Error register
                    bra       RprtErr

* Send IDE command (read or write)
* Entry: B  = IDE command code
*        Y = address of path descriptor
*        U = address of device memory (ie, of V.PAGE)
* trashes D and X
* Exit: CC=0 if command exited with data ready on controller
*       CC=1, B=error if problem.
SetIDE              stb       idecmd,u            Save copy of IDE command
                    ldb       PD.DRV,y            Get logical drive #
                    cmpb      #NUMDRIVE           Within range?
                    bhs       BadUnit             No, exit with error
                    leax      DriveFlg,u          Point to special drive flags table
                    lda       b,x                 Get flags for our drive
                    bpl       TblReady            Properly initialized, figure out mode
                    lbsr      IdentDrv            NOT Initialized, get mode info
                    bcs       CmdErr              Error doing IDENTIFY DRIVE command, exit
TblReady            anda      #DrvMode            Just need CHS/LBA mode for now
                    bne       DoLBA               LBA mode, go do
* Do CHS mode
                    ldd       PD.SCT,y            Get # of OS9 (256) sectors/track
                    lsra                          Convert to 512 byte sectors/track
                    rorb
                    std       CHSSPT,u            Save for Calc routine
                    ldx       PD.DTB,y            Get pointer to device table
                    lbsr      CalcCHS             Go calculate cyl/head/sector stuff
                    bcs       CmdErr              Error calculating, exit
                    lbsr      WaitDrv             Go wait for the drive (preserves y)
                    bcs       CmdErr              Error waiting for drive, exit
* Do sector #, then Drive/Head, then Cyl, then sector count, then command
                    pshs      y                   Save path descriptor ptr
                    ldy       V.PORT,u            Get IDE hardware address
                    lda       CHSSect,u           Get IDE sector #
                    sta       SectNum,y           Save to controller
                    lda       Head,u              Get IDE head #
                    ora       #%10100000          Set CHS mode
                    ora       DrivMask,u          Merge drive #
                    sta       DevHead,y           Save to controller
                    ldd       Cylinder,u          Get 16 bit cylinder # (4095 max)
                    addd      TempOfs,u           Add partition offset cylinder
                    bcs       SeekErr             If it overflowed, SEEK error
                    sta       CylHigh,y           Save to controller
                    stb       CylLow,y
                    bra       SendCmd             Send sector count & IDE command

* Do LBA mode IDE command here
DoLBA               bsr       WaitDrv             Wait for controller to be ready
                    pshs      y                   Save path descriptor ptr
                    ldy       V.PORT,u            Get IDE hardware address
* Copy LBA sector # to controller, including device/head (LBA 24-27)
                    ldd       OS9PSN+1,u          Get bits 0-15 of PSN
                    stb       SectNum,y           Save bits 0-7
                    sta       CylLow,y            Save bit 8-15
                    clra
                    ldb       OS9PSN,u            D=PSN bits 16-23 (24 & up set to 0 for OS9)
                    addd      TempOfs,u           Add partition offset cylinder
                    cmpa      #$0f                Overflow past LBA bits?
                    bhi       SeekErr             Yes, SEEK error
                    stb       CylHigh,y           Save bits 16-23
                    ora       #%11100000          Set LBA mode
                    ora       DrivMask,u          Merge drive #
                    sta       DevHead,y           Save to controller
* Send sector count (1) & command to controller, get results
SendCmd             ldx       #MAXWAIT            Get # 1/60th sec. ticks to wait on drive
                    stx       SlpCntr,u           Save it for sleep routine (if needed)
                    ldd       #$0140              Sector count to 1, fast retry to 64 tries
                    sta       SectCnt,y           Send to controller
                    lda       idecmd,u            Get command to send
                    sta       Command,y           Send to controller
CmdLp               lda       Status,y            Get status of drive command
                    bmi       CmdLp               IDE still busy, no other bits are valid
                    bita      #ErrorFnd           Not busy anymore, is there an error?
                    bne       TransErr            Yes, figure out what (don't forget to PULS Y!)
                    bita      #DataReq            Is data ready for us yet?
                    bne       CmdDone             Yes, exit
                    decb                          Dec counter
                    bne       CmdLp               Keep trying
                    ldx       SlpCntr,u           Get sleep tick counter
                    leax      -1,x                Drop it by one
                    beq       NoWay               Done count, give up with device not ready error
                    stx       SlpCntr,u           Save new sleep counter
                    ldx       #1                  Fast retry didn't work, sleep a tick
                    os9       F$Sleep
                    ldb       #$40                64 fast retries again
                    bra       CmdLp               Try again

SeekErr             lbsr      SeekExit            Seek error & exit
                    puls      y,pc

NoWay               puls      y
                    bra       ENotRdy

TransErr            lbsr      CmdErr              Get error code
                    puls      y,pc                Exit with it, restore path dsc. ptr

CmdDone             clrb                          Command complete, return with no error
                    puls      y,pc                Restore path dsc. ptr

* Wait for IDE controller to be ready
* Entry: Y=path dsc. ptr
*        U=driver mem ptr
* Exit: CC=0 - controller ready for command
*       CC=1 - Error message in B
*       DrivMask,u - contains drive # bit ready for IDE masking
* PRESERVES X&Y
WaitDrv             pshs      x,y                 Preserve regs
                    ldx       #$A000              (1/2 to 1/3 second busy check)
                    lda       PD.DNS,y            Get physical drive #
                    anda      #PhysDriv           No bad drive # possible
                    lsla                          Move drive # into proper bit for Drive/head
                    lsla
                    lsla
                    lsla
                    sta       DrivMask,u          Save drive mask for IDE
                    ldy       V.PORT,u            Get controller address for drive selected
RdyIni1             tst       Status,y            IDE busy?
                    bpl       IDEReady            No, return
                    leax      -1,x                Dec counter
                    bne       RdyIni1             Try again
                    puls      x,y                 Restore regs
ENotRdy             clr       drvrbusy,u
                    comb                          Tried too long; give up with error
                    ldb       #E$NotRdy
                    rts

IDEReady            puls      x,y                 Restore regs
                    clrb                          IDE ready, return
                    rts

* Copy LSN0 stuff into drive table
* Entry: X=ptr to 256 byte buffer containing LSN0 Sector.
* Exit: X,D is destroyed
CpyDrvTb            pshs      y                   Save path desc. ptr
                    ldb       PD.DRV,y            Get LOGICAL drive #
                    lda       #DRVMEM             Copy useful information to our LSN 0 buffer
                    mul                           Point to proper entry in drive table
                    leay      DRVBEG,u
                    leay      d,y
                    lda       #DD.SIZ
LSN0Cp              ldb       ,x+
                    stb       ,y+
                    deca
                    bne       LSN0Cp
                    puls      y,pc                Restore path desc. ptr & return

* Notes: PhysSN is the physical sector number to send to the controller,
* not the LSN...so it must be translated from the LSN (for IDE, divide by
* 2, unless using ATAPI CDROM, in which case divide by 8).
* Note that the head returned from this routine is base 0, so that the
* lowest head # returned would be 0 (for the first head). This matches
* the IDE spec (which can also only go up to 16 heads).
* The cylinder returned is also base 0, same as IDE.
* The sector returned is base 0, but IDE needs base 1.
* Vars used from elsewhere - OS9PSN,u   - Physical (IDE 512) sector #
*                          - Head,u     - IDE head #
*                          - Cylinder,u - IDE Cylinder #
*                          - CHSSect,u  - IDE sector (512) #
*                          - CHSSPT,u   - IDE (512 byte) sctrs/track)

* LSN division routine variable definitions: all on temp stack
                    org       0
S.SclPwr            rmb       2                   scale power
S.SclAmt            rmb       3                   scale amount
S.Cyl               rmb       2                   cylinder number
S.PSN               rmb       3                   physical sector number (work copy)
S.Head              rmb       1                   head number
S.Frame             equ       .                   size of stack frame

* Entry:   U=ptr to driver data area
*          Y=Ptr to path descriptor
*          X=Ptr to current drives' entry in drive table (DD.TOT, etc.)
*   OS9PSN,u-  Three byte Physical (512 byte) sector #)
* Exit:    U=ptr to driver data area
*          Y=ptr to path descriptor
*          X=Drive table ptr
*     Head,u=Head # in CHS mode
* Cylinder,u=Cylinder # in CHS mode
*  CHSSect,u=Sector # in CHS mode
* CC=0, no error, above 3 vars. are legit
* CC=1, error, error return in B
CalcCHS             leas      -S.Frame,s          make room for LSN division variables
                    ldb       OS9PSN,u
                    stb       S.PSN,s             initialize PSN MSB
                    ldd       OS9PSN+1,u
                    std       S.PSN+1,s           initialize PSN LSBs
                    ldd       #$0000
                    sta       S.Head,s            initialize head number
                    std       S.Cyl,s             initialize cylinder number
                    ldd       S.PSN+1,s           get PSN LSBs
                    subd      CHSSPT,u            less sectors/track
                    bhs       NotTrk0
                    tst       S.PSN,s             PSN MSB = 0?
                    beq       DivDone             yes, sector in track 0, go save info
                    dec       S.PSN,s             PSN MSB less 1
NotTrk0             std       S.PSN+1,s           save remaining PSN LSBs
                    inc       S.Head,s            set to next head (1)
                    inc       V.TRAK+1,x          mark track as non-0 for SetUpWD
                    ldb       CHSSPT+1,u          get IDE sectors per track
                    lda       PD.SID,y            Get # of disk heads
                    deca                          less track 0
                    mul                           calculate sectors remaining in cylinder 0
                    std       S.SclPwr,s          save it temporarily
                    ldd       S.PSN+1,s           get remaining PSN LSBs
                    subd      S.SclPwr,s          less sectors remaining in cylinder 0
                    bhs       NotCyl0
                    tst       S.PSN,s             remaining PSN MSB = 0?
                    beq       CalcHead            sector in cylinder 0, go get head number
                    dec       S.PSN,s             remaining PSN MSB less 1
NotCyl0             std       S.PSN+1,s           save remaining PSN LSBs
                    inc       S.Cyl+1,s           set cylinder to 1
                    clr       S.Head,s            reset head number to 0
                    lda       PD.SID,y            get disk sides
                    ldb       CHSSPT+1,u          get sectors per track
NrmlDiv             clr       S.SclAmt+2,s        initialize scale amount LSB
                    lsla                          HD prescale = heads x 8
                    lsla                          This is the max we can do with a 16 head
                    lsla                          drive, using 8 bit MUL.
                    mul                           calculate scale amount MSBs
                    std       S.SclAmt,s          save scale amount MSBs
                    ldd       #HDSclPwr           Set hard drive scale power
                    std       S.SclPwr,s          save scale power
DivLoop             lda       S.PSN,s             get remaining PSN MSB
                    cmpa      S.SclAmt,s          remaining PSN > scale amount?
                    blo       DivLoop1            no, go set up next scale amount & power
                    bhi       DivLoop2            yes, go do subtraction
                    ldd       S.PSN+1,s           get remaining PSN LSBs
                    subd      S.SclAmt+1,s        remaining PSN >= scale amount?
                    blo       DivLoop1            no, go set up next scale amount & power
                    std       S.PSN+1,s           save remaining PSN LSBs
                    bra       DivLoop3

DivLoop2            ldd       S.PSN+1,s           get remaining PSN LSBs
                    subd      S.SclAmt+1,s        less scale amount LSBs
                    std       S.PSN+1,s           save remaining PSN LSBs
DivLoop3            lda       S.PSN,s             get remaining PSN MSB
                    sbca      S.SclAmt,s          less scale amount MSB and borrow (if any)
                    sta       S.PSN,s             save remaining PSN MSB
                    ldd       S.Cyl,s             get cylinder number
                    addd      S.SclPwr,s          add scale power
                    std       S.Cyl,s             save cylinder number
DivLoop1            lsr       S.SclAmt,s          * divide scale amount by two
                    ror       S.SclAmt+1,s
                    ror       S.SclAmt+2,s
                    lsr       S.SclPwr,s          * divide scale power by two
                    ror       S.SclPwr+1,s
                    bcc       DivLoop
CalcHead            ldd       S.PSN+1,s           get remaining PSN LSBs
NextHead            subd      CHSSPT,u            less sectors per track (head)
                    blo       DivDone             underflow, go save info
                    std       S.PSN+1,s           save remaining PSN LSBs
                    inc       S.Head,s            increment head number
                    bra       NextHead

DivDone             ldd       S.Cyl,s             get cylinder number
                    cmpd      PD.CYL,y            cylinder number OK?
                    bhs       LSNErrSF            no, go return error
                    std       Cylinder,u
                    lda       S.PSN+2,s           get sector number (remaining PSN LSB)
                    inca                          IDE needs base 1
                    sta       CHSSect,u
                    ldb       S.Head,s            get head number
                    stb       Head,u
                    leas      S.Frame,s           restore stack pointer
                    clrb
                    rts

LSNErrSF            leas      S.Frame,s           restore stack pointer
LSNErr              comb
                    ldb       #E$Sect             Exit with Bad sector # error
                    rts

                    emod
eom                 equ       *
                    end
