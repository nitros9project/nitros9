* FAT32 OS9Boot loader for the CoCo VHD interface.
* CoCo Level 2 only. Exact $1D0-byte slot, including header and CRC.
* FATBase is the volume's 512-byte LBA; no partition-table scan is performed.
* Requires a valid FAT32 BPB, 512-byte sectors, 1 or 2 FATs, and authoritative
* FAT #0. Finds root short name OS9BOOT, traversing directory/file chains.
* Uses 24-bit 256-byte record addresses: this is the VHD's 4 GiB limit,
* not a restriction on pcf or blkdrv. No embedded file system or boot file.
* Standalone early-boot code: no file manager or device driver required.
* Returns X=loaded file, D=exact bytes, C clear; C set on failure.
* Deliberately small: not a general FAT validator (e.g. no cycle detector).
                    ifp1
                    use       defsfile
                    endc
                    ifndef    FATBase
FATBase             equ       0
                    endc
                    ifndef    DEVADDR
DEVADDR             equ       $FF80
                    endc
                    ifndef    DISKNUM
DISKNUM             equ       0
                    endc
                    ifne      Level-2
                    error     FAT32 VHD Boot requires CoCo Level 2
                    endc
                    iflt      FATBase
                    error     FATBase must be nonnegative
                    endc
                    ifgt      FATBase-$7FFFFF
                    error     FATBase exceeds VHD address space
                    endc
                    iflt      DISKNUM
                    error     VHD unit must be 0 or 1
                    endc
                    ifgt      DISKNUM-1
                    error     VHD unit must be 0 or 1
                    endc
                    org       0
record              rmb       3
cluster             rmb       3
fatstart            rmb       3
database            rmb       3
remaining           rmb       1
spc                 rmb       1
pages               rmb       1
fatcount            rmb       1
buffer              rmb       2
image               rmb       2
bootsize            rmb       2
dest                rmb       2
size                equ       .
                    mod       eom,name,Systm+Objct,ReEnt+1,start,size
name                fcs       /Boot/
start               orcc      #IntMasks
                    leas      -size,s
                    tfr       s,u
* The early kernel starts S below $800. Page $800 is reserved for the
* later system stack (D.SysStk=$900), so it is free during F$Boot. Keeping
* scratch above S avoids the process descriptor at $600 and DMA bank splits.
                    ldd       #$0800
                    std       buffer,u
                    lda       #DISKNUM
                    sta       DEVADDR+6
                    lda       #(FATBase*2)/65536
                    sta       record,u
                    ldd       #(FATBase*2)&65535
                    std       record+1,u
                    lbsr      read
                    ldd       11,x
                    cmpd      #$0002
                    lbne      bad
                    lda       13,x
                    lbeq      bad
                    deca
                    bita      13,x
                    lbne      bad
                    inca
                    sta       spc,u
                    lda       16,x
                    sta       fatcount,u
                    leax      14,x
                    lbsr      word
                    aslb
                    rola
                    std       record+1,u
                    lda       #0
                    rola
                    sta       record,u
                    leay      volume,pcr
                    lbsr      add
                    ldd       record,u
                    std       fatstart,u
                    lda       record+2,u
                    sta       fatstart+2,u
                    ldx       buffer,u
                    leax      36,x
                    lbsr      number
                    std       record+1,u
* For 1/2 FATs, shift 1/2 times: FATSize * FATCount * two VHD records.
geo                 lbsr      shift
                    dec       fatcount,u
                    bne       geo
                    leay      fatstart,u
                    lbsr      add
                    ldd       record,u
                    std       database,u
                    lda       record+2,u
                    sta       database+2,u
                    ldx       buffer,u
                    leax      44,x
                    lbsr      number
                    lbsr      setcluster
                    lbsr      locate
search
entry               tst       ,x
                    beq       bad
                    leay      filename,pcr
                    pshs      x
                    ldb       #11
compare             lda       ,x+
                    cmpa      ,y+
                    bne       mismatch
                    decb
                    bne       compare
                    puls      x
                    bra       found
mismatch            puls      x
                    leax      32,x
                    tfr       x,d
                    tstb
                    bne       entry
                    lbsr      next
                    bra       search
* OS9 boot memory and returned length are 16-bit; reject a rounded overflow.
found               ldd       30,x
                    bne       bad
                    leax      28,x
                    bsr       word
                    std       bootsize,u
                    beq       bad
                    addd      #255
                    bcs       bad
                    sta       pages,u
                    subd      #255
                    pshs      u,x
                    os9       F$BtMem
                    tfr       u,y
                    puls      u,x
                    bcs       error
                    sty       image,u
                    sty       dest,u
                    lda       -8,x
                    sta       record,u
                    leax      -2,x
                    bsr       word
                    bsr       setcluster
                    bsr       locate
load
                    ldy       dest,u
                    clrb
copy                lda       ,x+
                    sta       ,y+
                    decb
                    bne       copy
                    sty       dest,u
                    dec       pages,u
                    beq       loaded
                    bsr       next
                    bra       load
loaded
                    ldx       image,u
                    clrb
                    ldd       bootsize,u
error               leas      size,s
                    rts
bad                 tfr       u,s
                    ldb       #E$BTYP
                    coma
                    bra       error
* Decode a little-endian 24-bit FAT value; VHD cannot address beyond 4 GiB.
number              lda       2,x
                    sta       record,u
word                ldb       ,x
                    lda       1,x
                    rts
setcluster          std       record+1,u
                    std       cluster+1,u
                    lda       record,u
                    sta       cluster,u
                    rts
* Start a cluster: record = database + (cluster-2)*sectors/cluster*2.
* Read its first record here, so a 128-sector cluster's 256-record count
* can wrap to zero initially and then decrement to 255 before next tests it.
locate              ldd       cluster+1,u
                    subd      #2
                    std       record+1,u
                    lda       cluster,u
                    sbca      #0
                    sta       record,u
                    ldb       spc,u
                    stb       remaining,u
                    asl       remaining,u
scale               bsr       shift
                    lsrb
                    bne       scale
                    leay      database,u
                    bsr       add
                    bra       getdata
shift               asl       record+2,u
                    rol       record+1,u
                    rol       record,u
                    rts
* Fetch the next 256-byte record; follow FAT when a cluster is exhausted.
next                tst       remaining,u
                    bne       getdata
                    ldd       cluster,u
                    std       record,u
                    lda       cluster+2,u
                    sta       record+2,u
                    ldb       #6
halve               lsr       record,u
                    ror       record+1,u
                    ror       record+2,u
                    decb
                    bne       halve
                    leay      fatstart,u
                    bsr       add
                    bsr       read
                    ldb       cluster+2,u
                    lslb
                    lslb
                    abx
                    lda       3,x
                    anda      #15
                    bne       bad
                    bsr       number
                    bsr       setcluster
                    bra       locate
getdata             dec       remaining,u
                    bsr       read
                    inc       record+2,u
                    bne       ret
                    inc       record+1,u
                    bne       ret
                    inc       record,u
ret                 rts
add                 ldd       record+1,u
                    addd      1,y
                    std       record+1,u
                    lda       record,u
                    adca      ,y
                    sta       record,u
                    rts
read                lda       record,u
                    sta       DEVADDR
                    ldd       record+1,u
                    std       DEVADDR+1
                    ldx       buffer,u
                    stx       DEVADDR+4
                    clr       DEVADDR+3
                    tst       DEVADDR+3
                    beq       ret
* Abandon nested subroutine calls on a device error.
                    lbra      bad
volume              fcb       (FATBase*2)/65536
                    fdb       (FATBase*2)&65535
filename            fcc       /OS9BOOT    /
* Any growth past $1D0 (including CRC) makes the fill fail at assembly time.
codeend             equ       *
                    fill      $39,464-3-*
                    emod
eom                 equ       *
