********************************************************************
* rbsuper - RBF Super Caching Device Driver
*
* $Id$
*
* (C) 2004 Boisy G. Pitre - Licensed to Cloud-9
*
* RBSuper is the framework for a new type of RBF device driver -- one
* that fetches native-size, or PHYSICAL sectors.  A physical sector is
* a sector that is sized to its device.  For example, all IDE drives and
* pretty much all SCSI drives have 512 byte sectors; CD-ROMs have 2048
* byte sectors.
*
* As a high-level driver, this module is responsible for managing
* the cache, verifying writes, etc.
*
* The actual reading and writing of sectors is performed by the
* low-level driver, which can be designed for any device.
*
* Conditionals:
*   H6309 - if set, assembles for 6309
*   USECS - if set, uses critical section code (slows down driver)
*   HDBDOS - if set, adds code to handle HDB-DOS partitions
* And somewhere this flag has been lost GH 2012/11/13
* Only found when I trashed my systems vdisks
HDBDOS              set       1
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2004/04/10  Boisy G. Pitre
* Created due to Mark's constant harping about a NitrOS-9 driver for
* the SuperIDE Interface.  Here ya go, Marlette.
*
*          2005/12/12  Boisy G. Pitre
* The SS.VarSect call has been moved from the low level driver to rbsuper
* for efficiency.  Also it no longer calls SS.DSize every time it is called.
* Instead, it only calls it the first time, then caches the sector size value
* and returns that value on subsequent calls.
*
*          2005/12/13  Boisy G. Pitre
* Employed a trick to "shift" the idea of where the driver's static
* data starts at the start of each entry point.  This saves about 200
* bytes of memory.
*
* 1        2006/08/20  Boisy G. Pitre
* Fixed bug where linking to a non-existent module in Init would cause a crash
* because IOMan calls the Term routine when Init returns an error.  Added a simple
* one line test in Term to see if a value was non-zero which would indicate if Init
*
* 2        2008/02/05  Boisy G. Pitre
* Fixed bug where DNS HDB flag was being pulled from PD.TYP byte instead of PD.DNS.
*
* 3        2011/12/22  Boisy G. Pitre
* Made a "fast path" for 256 byte sector devices to read/write directly into PD.BUF
* instead of using the cache, for performance reasons.
* Conditionalized critical section code since it may not be needed, and affects performance.

                    nam       rbsuper
                    ttl       RBF Super Caching Device Driver

                    ifp1
                    use       defsfile
                    use       rbsuper.d
                    endc

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       0
edition             set       2

                    mod       eom,name,tylg,atrv,start,V.RBSuper

                    fcb       DIR.+SHARE.+PEXEC.+PREAD.+PWRIT.+EXEC.+UPDAT.

name                fcs       /RBSuper/
                    fcb       edition

start               lbra      Init
                    bra       Read
                    nop
                    lbra      Write
                    lbra      GetStat
                    lbra      SetStat

*
* Term
*
* Entry:
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Term                leau      UOFFSET,u
* Free memory allocated for cache
                    lda       V.CchSize,u         get cache size into A
* Note, the next line fixes a bug where the system would crash when F$Link in Init failed.
* If it fails, V.CchSize will never get set, and since it is set to 0 initally, we assume
* that init failed if V.CchSize is 0 and thus we simply return.
                    beq       ret@
                    tfr       u,x                 move statics ptr into X for safety
                    ldu       V.CchAddr,u         and load U with cache address
                    beq       nofree@
                    os9       F$SRtMem            return cache memory to system
nofree@             tfr       x,u                 and restore statics ptr
* Call low-level driver term
                    ldx       V.LLTerm,u
                    lbsr      LLCall
* Unlink low-level driver
                    ifgt      Level-1
                    ldx       D.Proc              get curr proc ptr
                    ldd       D.SysPrc            get system process desc ptr
                    std       D.Proc              and make current proc
                    endc
                    ldu       V.LLAddr,u          get the address of the low-level module
                    os9       F$Unlink            unlink it
                    ifgt      Level-1
                    stx       D.Proc              restore
                    endc
ret@                rts                           return

*
* Read
*
* Entry:
*    B  = MSB of the disk's LSN
*    X  = LSB of the disk's LSN
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Read                leau      UOFFSET,u
                    cmpx      #$0000              LSN 0?
                    bne       ReadSect            branch if not
                    tstb                          LSN 0?
                    bne       ReadSect            branch if not
                    bsr       ReadSect            else read LSN0
                    bcs       bye                 if error, return
* Code to deal with copying LSN0
                    leax      DRVBEG-UOFFSET,u    point X to start of drive table
                    ldb       PD.DRV,y            get drive number
lsn@                beq       CopyLSN0            branch if zero
                    leax      DRVMEM,x            else increase X by drive table size
                    decb                          decrement drive number
                    bra       lsn@                branch to loop

* X = drive table pointer for PD.DRV
* Copy DD.SIZ bytes (LSN0) from buffer to drive table
CopyLSN0            equ       *
                    ldu       PD.BUF,y
                    ifne      H6309
                    ldw       #DD.SIZ
                    tfm       u+,x+
                    else
                    ldb       #DD.SIZ
CpyLSNLp            pulu      a                   one cycle less than lda ,u+
                    sta       ,x+
                    decb
                    bne       CpyLSNLp
                    endc
rret                rts

                    ifne      HDBDOS
* For HDB-DOS, we must add in drive number
* First, multiply drive number in descriptor by $276 (630 sectors),
* then, add the product to the PSect
ComputeHDB
                    ifne      H6309
                    clra
                    ldb       V.HDBDrive,u
                    muld      #$0276
                    addw      V.PhysSect+1,u
                    stw       V.PhysSect+1,u
                    adcb      V.PhysSect,u
                    stb       V.PhysSect,u
                    else
                    leas      -4,s                make a stack to store product of $276 * DriveNum
                    lda       V.HDBDrive,u        get drive number
                    ldb       #$76
                    mul
                    std       2,s
                    lda       V.HDBDrive,u
                    ldb       #$02
                    mul
                    std       ,s
                    clrb
                    lda       1,s
                    addd      2,s
                    std       2,s
                    bcc       f@
                    inc       ,s
f@                  lda       ,s
                    sta       1,s
                    ldd       2,s
                    addd      V.PhysSect+1,u
                    std       V.PhysSect+1,u
                    lda       1,s
                    adca      V.PhysSect,u
                    sta       V.PhysSect,u
                    leas      4,s
                    endc
                    endc
bye                 rts

* 256 byte sector device: setup for low level driver to put 256 byte sector directly into PD.BUF
Read256
                    lbsr      Log2Phys
* We may not have to do this (and disturb the cache as a result)
*               lda       PD.DRV,y            get current drive number
*               sta       V.LastDrv,u         and make this the current drive
                    lda       #1
                    sta       V.SectCnt,u
                    ldx       PD.BUF,y            put address of PD.BUF directly into cache spot
                    stx       V.CchPSpot,u
* Call low-level driver read
                    ldx       V.LLRead,u
                    lbra      LLCall

* Read Sector
*
* The sector will be read from either the cache or the controller.
* A cache "hit" is verified by two methods:
* 1. Comparing the drive number of the drive for the current path to
*    the drive number of the last path -- if they match, we *MAY*
*    have a cache hit.  If not, we fill the cache
* 2. If #1 matches, then we know the current drive and the last drive
*    are the same.  We then check the logical sector to see if it is
*    in the cache.
*
* Entry:
*    Y = address of path descriptor
*    U = address of device memory area
*    B = Sector bits 23-16
*    X = Sector bits 15-0
*
ReadSect            bsr       PreXfr              to pre-transfer stuff
                    bcs       bye                 branch if error
                    ifne      HDBDOS
                    tst       V.HDBPart,u         HDB-DOS partition?
                    beq       NotHDB
* This is the HDB-DOS partition "read" code path.
* As an HDB-DOS partition, we are interested ONLY in reading the first 256 bytes
* regardless of the size of the cache.
                    lda       V.SectSize,u        get sector size (0=256,1=512,2=1024,etc)
                    leax      SCTTBL,pcr
                    lda       a,x
                    sta       V.Log2Phys,u        set logical sectors per phys
                    lda       #$01                get sector count
                    sta       V.SectCnt,u         and store it
                    sta       V.CchDirty,u        the cache will ALWAYS be dirty in HDB-DOS mode
                    lda       V.LogSect,u         get logical sector stored earlier
                    sta       V.PhysSect,u        save off logical sector as physical one
                    ldd       V.LogSect+1,u       get logical sector stored earlier
                    std       V.PhysSect+1,u      save off logical sector as physical sector
                    lbsr      AddSectorOffset     add in partition offset and HDB-DOS drive
                    bsr       ComputeHDB          and compute HDB-DOS offset
* Set up the pointer to the buffer
                    ldx       V.CchAddr,u         get address of cache
                    stx       V.CchPSpot,u        save in current sector pointer
* Call low-level driver
                    ldx       V.LLRead,u
                    lbsr      LLCall
                    bcs       bye
                    ldx       V.CchAddr,u         get cache pointer which holds HDB-DOS sector
                    bra       CopyXToPDBUF
                    endc
NotHDB
* New: Dec 20, 2011
* Fast path opportunity: if sector size is 256 bytes, call LLRead right into PD.BUF
                    tst       V.SectSize,u        (0=256 byte sector device)
                    beq       Read256
                    bsr       ValidateCache
                    bcs       ex@
* Copy appropriate 256 byte sector from V.CchAddr to PD.BUF,y
                    lda       V.CchSize,u         get hi byte of cache size
                    deca
                    anda      V.LogSect+2,u
                    clrb
                    ldx       V.CchAddr,u
                    leax      d,x
CopyXToPDBUF        pshs      y
                    ldy       PD.BUF,y
                    ifne      H6309
                    ldw       #256
                    tfm       x+,y+
                    clrb
                    puls      y,pc
                    else
                    clr       ,-s
next@               ldd       ,x++
                    std       ,y++
                    inc       ,s
                    bpl       next@
                    clrb
                    puls      a,y,pc
                    endc
ex@                 rts

* ValidateCache
*
* Check if the cache is coherent (i.e. contains requested sector).
* If the cache is NOT coherent, it calls 'FillCache' to fill it.
ValidateCache
* We must determine if the currently requested sector is already in cache.
* First, is this drive the same as the last drive that accessed the cache?
* If not, then we need to fill the cache with sectors from the current drive.
                    tst       V.CchDirty,u        has cache been initialized?
                    bne       nomatch             branch if not
                    lda       PD.DRV,y            get current drive
                    cmpa      V.LastDrv,u         save as last drive to access cache?
                    bne       nomatch             if not, fill cache
* Same drive as last access... is this sector in cache?
                    ldb       V.LogSect,u         save off logical sector
                    cmpb      V.CchBase,u         compare bits 23-16
                    bne       nomatch             branch if not the same
                    lda       V.LogSect+1,u       save off logical sector
                    ldb       V.CchSize,u         get hi byte of cache size
                    decb                          decrement (e.g. 8=7,4=3,2=1,1=0)
                    comb                          invert (e.g. 7=$F8,3=$FC,1=$FE,0=$FF)
                    andb      V.LogSect+2,u       mask out cached sectors
                    cmpd      V.CchBase+1,u       same as what's in cache?
                    beq       exok@               YES, WE HAVE A CACHE HIT!!!
nomatch             bra       FillCache           no, we must fil the cache
*
* PreXfr
*
* Called at read/write to gather info from path descriptor and
* device descriptor.
PreXfr              stb       V.LogSect,u         save off logical sector
                    stx       V.LogSect+1,u       save off logical sector
                    lda       PD.STP,y            get possible HDB-DOS drive number
                    sta       V.HDBDrive,u        save off in our statics
                    lda       PD.TYP,y
                    anda      #TYPH.SSM           lob off all but sector size bits
* SmartCache - check if our current cache can accommodate this sector size
                    cmpa      V.SectSize,u        do we need to expand?
                    bls       no@                 branch if not
* Yes, we need to free our current cache mem and alloc more
                    pshs      a,u                 save regs
                    ldd       V.CchSize,u         get current cache size
                    ldu       V.CchAddr,u         and cache pointer
                    beq       nofree@
                    os9       F$SRtMem            return that memory
nofree@             puls      a,u                 restore regs
                    lbsr      ExpandCache         go expand cache
                    bcs       ex@                 and branch if error
                    sta       V.SectSize,u        save new sector size
no@
                    lda       PD.DNS,y            get DNS byte
                    anda      #DNS.HDB            isolate HDB-DOS flag
                    sta       V.HDBPart,u         and save state
exok@               clrb                          clear carry
                    rts                           return
ex@                 clr       V.SectSize,u        clear sector size to force realloc
                    orcc      #Carry              set carry (indicates error)
                    rts                           return

* FillCache
*
* Fill the cache with sectors from the device.
*
* Destroys: A, B, X
FillCache
                    lda       V.LogSect,u         get logical sector bits 23-16
                    sta       V.CchBase,u         save as cached base
                    lda       V.LogSect+1,u       save off logical sector
                    ldb       V.CchSize,u         get hi byte of cache size (1, 2, 4 or 8)
                    decb                          decrement (e.g. 8=7,4=3,2=1,1=0)
                    comb                          invert (e.g. 7=$F8,3=$FC,1=$FE,0=$FF)
                    andb      V.LogSect+2,u       mask out cached sectors
                    std       V.CchBase+1,u       save as cached base
                    lbsr      Log2Phys            convert logical sectors to physical
                    lda       PD.DRV,y            get current drive number
                    sta       V.LastDrv,u         and make this the currently cached drive
* Set up the transfer
                    ldb       V.CchSize,u         get upper 8 bits of cache size
                    lda       V.SectSize,u        get sector size (0=256,1=512,2=1024,etc)
                    leax      SCTTBL,pcr
                    lda       a,x
                    sta       V.Log2Phys,u
                    lda       V.SectSize,u        get sector size (0=256,1=512,2=1024,etc)
                    beq       ok@
lsr@                lsrb                          divide by 2
                    deca                          decrement
                    bne       lsr@                else divide again
ok@                 stb       V.SectCnt,u         save sector count
                    decb
                    comb
                    andb      V.PhysSect+2,u
                    stb       V.PhysSect+2,u
* Set up the pointer to the buffer
                    ldx       V.CchAddr,u         get pointer to big buffer
                    stx       V.CchPSpot,u        save in current sector pointer
* Call low-level driver read
                    ldx       V.LLRead,u
                    bsr       LLCall
                    bcs       ex@
                    clr       V.CchDirty,u        cache is no longer dirty
                    clrb
                    rts
ex@                 stb       V.CchDirty,u        store error code as dirty flag
                    rts


SCTTBL              fcb       256/256
                    fcb       512/256
                    fcb       1024/256
                    fcb       2048/256

* GetStat/SetStat
*
* Entry:
*    R$B = function code
*    Y   = address of path descriptor
*    U   = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
SetStat             leau      UOFFSET,u
                    ldx       V.LLStSt,u
                    bra       LLCall

SSVarSect           ldb       PD.DRV,y            get drive number
                    leax      V.SSCache,u         point to sector size cache table
                    abx
                    lda       ,x                  get sector size
                    bne       go2@                if not zero, use that value
                    pshs      x
                    ldx       PD.RGS,y
                    pshs      x
                    leas      -R$Size,s
                    sts       PD.RGS,y
                    lda       #SS.DSize
                    sta       R$B,s
                    bsr       gs2                 make a call to low level driver's SS.DSize
* Be sure that no instructions from here to the bcs modify carry
                    lda       R$A,s
                    leas      R$Size,s
                    puls      x
                    stx       PD.RGS,y
                    puls      x
                    bcs       ex@
                    cmpa      #8                  2048 byte sector?
                    beq       go@
                    lsra                          else shift right
                    fcb       $8C                 skip next two bytes (cmpx...)
go@                 lda       #3
                    sta       ,x                  save newly acquired value off into cached size table
go2@                pshs      a
                    lda       PD.TYP,y
                    anda      #^TYPH.SSM
                    ora       ,s+
* Boisy's Notes 3/27/06:
* Notice that we save the true sector size of the device in the PD.TYP byte of
* the path descriptor EACH TIME SS.VarSect is called.  This is important,
* because it alleviates the user from having to set this value in the device
* descriptor in a situation where the device being accessed has a larger sector
* size than what is in the device descriptor.
*
* Note that the value in the device descriptor IS used to initially determine
* the size of the cache at INIT time since we haven't even talked to the
* controller at that time yet to query it for its size.
*               sta       PD.TYP,y            and in path descriptor
                    clrb
ex@                 rts


GetStat             leau      UOFFSET,u
                    ldx       PD.RGS,y            get registers
                    ldb       R$B,x               get caller's B
                    cmpb      #SS.VarSect
                    beq       SSVarSect

gs2                 ldx       V.LLGtSt,u

* Entry: Y = path desc ptr
*        U = statics ptr
*        X = address of routine to call
LLCall
                    ifeq      USECS-1
                    pshs      a                   preserve A for duration of csacq_wait
                    lda       #255                wait the maximum number of counts
                    bsr       csacq_wait          acquire the critical section
                    tsta                          test A for zero
                    puls      a                   restore A
                    beq       cserr               return if A was zero (semaphore wasn't acquired)
                    endc
                    pshs      u,y                 save U and Y
                    jsr       ,x                  call low level routine
                    puls      y,u                 restore U and Y

                    ifeq      USECS-1
* Critical Section Release - clear the critial section to zero, allowing others to use it
csrel               pshs      cc                  preserve CC
                    clr       V.LLSema,u          clear critical section
                    puls      cc,pc               restore CC and return
cserr               comb                          set the carry
                    ldb       #111                and load B with error indicating a semaphore timeout
                    endc
                    rts

                    ifeq      USECS-1
* Critical Section Acquire With Wait
*
* Entry:
*    A = number of times to check before giving up
*
* Exit:
*    A = status (>0 = Critical section acquired, 0 = Critical section not acquired)
*
csacq_wait          pshs      cc                  save CC on stack
                    orcc      #IntMasks           mask interrupts
                    tst       V.LLSema,u          does someone already have the critical section?
                    bne       w@                  if so, then branch
                    inc       V.LLSema,u          else claim critical section (0->1)
e@                  puls      cc,pc               restore CC and return
w@                  deca                          decrement our timeout counter
                    beq       e@                  if zero, we've timed out, return
                    puls      cc                  give interrupts a chance to breathe
                    ifgt      Level-1
* Give up timeslice unless this is the system
                    pshs      x
                    ldx       D.Proc              get proc descriptor
                    cmpx      D.SysPrc            system?
                    beq       wd@                 yep, system cannot sleep
*               ldx       D.AProcQ            get active proc queue
*               beq       wd@                 if empty, return
                    ldx       #$0001
                    os9       F$Sleep             give up timeslice
wd@                 puls      x                   return to caller
                    endc
                    bra       csacq_wait          and try again
                    endc


* Log2Phys - Convert logical sector to physical sector
*
* Stores V.PhysSect,u from V.LogSect,u based on V.SectSize,u
* Also adds IT.SOFF1-IT.SOFF3 to V.PhysSect,u for partitioning.
* Results are placed in V.PhysSect,u
Log2Phys            lda       V.LogSect,u
                    sta       V.PhysSect,u
                    ldd       V.LogSect+1,u
                    std       V.PhysSect+1,u
                    lda       V.SectSize,u
                    beq       AddSectorOffset
DivBy2              lsr       V.PhysSect,u
                    ror       V.PhysSect+1,u
                    ror       V.PhysSect+2,u
                    deca
                    bne       DivBy2
* This routine adds the 3 byte sector offset in the
* device descriptor to the physical sector.
AddSectorOffset
                    ldx       PD.DEV,y
                    ldx       V$DESC,x
                    ldd       IT.SOFF2,x
                    addd      V.PhysSect+1,u
                    std       V.PhysSect+1,u
                    lda       IT.SOFF1,x
                    adca      V.PhysSect,u
                    sta       V.PhysSect,u
logex               rts


* 256 byte sector device: setup for low level driver to put 256 byte sector directly into PD.BUF
Write256
                    bsr       Log2Phys
* We may not have to do this (and disturb the cache as a result)
*               lda       PD.DRV,y            get current drive number
*               sta       V.LastDrv,u         and make this the current drive
                    lda       #1
                    sta       V.SectCnt,u
                    ldx       PD.BUF,y            put address of PD.BUF directly into cache spot
                    stx       V.CchPSpot,u
* Call low-level driver read
                    ldx       V.LLWrite,u
                    bra       LLCall

* Write
*
* Entry:
*    B  = MSB of the disk's LSN
*    X  = LSB of the disk's LSN
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Write               leau      UOFFSET,u
                    lbsr      PreXfr              to pre-transfer stuff
                    bcs       logex               branch if error
                    ifne      HDBDOS
                    lda       V.HDBPart,u         HDB-DOS partition?
                    beq       h@
* HDB-DOS partition code path
                    sta       V.CchDirty,u        cache is dirty
                    lda       V.SectSize,u        get sector size (0=256,1=512,2=1024,3=2048)
                    leax      SCTTBL,pcr
                    lda       a,x
                    sta       V.Log2Phys,u        set logical sectors per phys
                    lda       V.LogSect,u
                    sta       V.PhysSect,u
                    ldd       V.LogSect+1,u
                    std       V.PhysSect+1,u
                    bsr       AddSectorOffset     add in partition offset and HDB-DOS drive
                    lbsr      ComputeHDB          and compute HDB-DOS offset
                    ldx       PD.BUF,y            get path desc buffer
                    stx       V.CchPSpot,u        we write directly from PD.BUF
                    bra       writeit
                    endc
* New: Dec 20, 2011
* Fast path opportunity: if sector size is 256 bytes, call LLRead right into PD.BUF
h@
                    tst       V.SectSize,u        (0=256 byte sector device)
                    beq       Write256
                    lbsr      ValidateCache
                    bcs       logex
* Copy appropriate 256 byte sector from PD.BUF,y to V.CchAddr,u
* Determine where in the cache we copy this 256 byte sector
                    bsr       Log2Phys            compute physical sector from logical sector
                    lda       V.CchSize,u         get hi byte of cache size
                    deca
                    anda      V.LogSect+2,u
                    clrb
                    ldx       V.CchAddr,u
                    leax      d,x
                    stx       V.CchLSpot,u        save for possible verify later
                    pshs      y                   save path desc for now
                    ldy       PD.BUF,y
                    ifne      H6309
                    ldw       #256
                    tfm       y+,x+
                    puls      y
                    else
                    clr       ,-s
loop@               ldd       ,y++
                    std       ,x++
                    inc       ,s
                    bpl       loop@
                    puls      a,y
                    endc
* Now that sector is copied, determine where in cache we start
                    lda       V.LogSect+2,u       get logical sector bits 7-0
                    leax      MASKTBL,pcr         point to base of cache
                    ldb       V.SectSize,u        get sector size in B
                    anda      b,x
                    pshs      a
                    lda       V.CchSize,u         get upper 8 bits of cache size
                    deca
                    anda      ,s+
                    clrb
                    ldx       V.CchAddr,u         point to base of cache
                    leax      d,x
                    stx       V.CchPSpot,u
* Call low-level driver write routine
writeit             lda       #$01
                    sta       V.SectCnt,u
                    ldx       V.LLWrite,u
                    lbsr      LLCall
* If verify flag is on, read back and compare
                    tst       PD.VFY,y            verify flag set?
                    bne       ex@                 if so, we don't verify -- just exit
* Read back physical sector into cache
                    tst       V.HDBPart,u         HDB-DOS partition?
                    beq       o@
* If in HDB-DOS mode, we simply place the base address of the cache into
* V.CchPSpot... and V.CchLSpot for later verify
                    ldx       V.CchAddr,u
                    stx       V.CchPSpot,u
                    stx       V.CchLSpot,u
o@                  lda       #$01
                    sta       V.SectCnt,u
                    ldx       V.LLRead,u
                    lbsr      LLCall
* Now compare PD.BUF to sector in cache just re-read
                    ldx       V.CchLSpot,u        get spot in cache where 256 byte sector is.
                    ldy       PD.BUF,y            get pointer to buffer
                    clra
a@                  ldb       ,x+                 get byte in cache
                    cmpb      ,y+                 compare against byte in PD.BUF
                    bne       err@
                    deca
                    bne       a@
ex@                 clrb
                    rts
err@                comb
                    ldb       #E$Write
                    stb       V.CchDirty,u        make cache dirty due to error
                    rts

*
* Init
*
* Entry:
*    Y  = address of device descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Init                pshs      y                   save device descriptor ptr on stack
                    ldb       #DrvCount           get maximum drives supported
                    stb       V.NDRV,u            save in our device memory
                    leax      DRVBEG,u            point X to the drive tables
                    lda       #$FF
* Invalidate V.NDRV drive tables
drvx                sta       DD.TOT,x
                    sta       DD.TOT+1,x
                    sta       DD.TOT+2,x
                    leax      DRVMEM,x            point to next drive table
                    decb                          decrement counter
                    bne       drvx                if not zero, continue
* Link to low-level driver
                    ldd       IT.LLDRV,y          point to name in descriptor
                    leax      d,y                 point to name in descriptor
                    pshs      u
                    ifgt      Level-1
                    ldd       D.Proc              get curr proc ptr
                    pshs      d                   save on stack
                    ldd       D.SysPrc            get system process desc ptr
                    std       D.Proc              and make current proc
                    endc
                    lda       #Sbrtn+Objct
                    os9       F$Link              link to it
                    ifgt      Level-1
                    puls      x                   get curr proc ptr
                    stx       D.Proc              restore
                    endc
                    tfr       u,x                 transfer module address to X
                    puls      u                   restore U
                    leau      UOFFSET,u
                    bcs       ret@
                    stx       V.LLAddr,u          else save module address
* setup entry points to low-level module
                    leax      V.LLInit,u
                    lda       #6                  number of entry points
l@                  sty       ,x++
                    leay      3,y
                    deca
                    bne       l@
* Call low-level driver init
                    ldy       ,s                  grab path desc ptr
                    ldx       V.LLInit,u
                    lbsr      LLCall
                    bcc       r@
ret@                puls      y,pc
* Allocate cache memory
r@                  lda       IT.TYP,y            get type byte
                    anda      #TYPH.SSM           mask out all but sector size
* Added Dec 20, 2011: save off to V.SectSize (never got initialized until now!)
                    sta       V.SectSize,u        clear out V.SectSize
                    puls      y
* Fall through to ExpandCache

* Entry: A = cache size to expand to (1 = 512, 2 = 1024, 3 = 2048)
* Exit:  D is destroyed
* Note: any previously allocated cache memory must have been
* freed before this call!
*
ExpandCache
                    pshs      a,x
                    leax      CCHTBL,pcr
                    lda       a,x                 get 1, 2, 4 or 8
                    sta       V.CchDirty,u        make cache dirty since we will expand it
                    clrb
                    std       V.CchSize,u         save cache size (256, 512, 1024 or 2048)
                    tfr       u,x
                    os9       F$SRqMem            allocate cache memory
                    stu       V.CchAddr,x         save cache ptr
                    tfr       x,u                 restore mem pointer
ex@                 puls      a,x,pc


CCHTBL              fcb       256/256
                    fcb       512/256
                    fcb       1024/256
                    fcb       2048/256

MASKTBL             fcb       $07,$06,$04,$00

                    emod
eom                 equ       *
                    end
