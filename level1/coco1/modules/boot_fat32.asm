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
                    use       defsfile  ; include shared definitions or implementation
                  ENDC            ; conditional assembly
                    ifndef    FATBase   ; conditional assembly
FATBase             equ       0         ; define constant or offset
                  ENDC            ; conditional assembly
                    ifndef    DEVADDR   ; conditional assembly
DEVADDR             equ       $FF80     ; define constant or offset
                  ENDC            ; conditional assembly
                    ifndef    DISKNUM   ; conditional assembly
DISKNUM             equ       0         ; define constant or offset
                  ENDC            ; conditional assembly
                  IFNE    Level-2 ; conditional assembly
                    error     FAT32 VHD Boot requires CoCo Level 2
                  ENDC            ; conditional assembly
                  IFLT    FATBase ; conditional assembly
                    error     FATBase must be nonnegative
                  ENDC            ; conditional assembly
                  IFGT    FATBase-$7FFFFF ; conditional assembly
                    error     FATBase exceeds VHD address space
                  ENDC            ; conditional assembly
                  IFLT    DISKNUM ; conditional assembly
                    error     VHD unit must be 0 or 1
                  ENDC            ; conditional assembly
                  IFGT    DISKNUM-1 ; conditional assembly
                    error     VHD unit must be 0 or 1
                  ENDC            ; conditional assembly
                    org       0         ; set storage origin
record              rmb       3         ; reserve storage
cluster             rmb       3         ; reserve storage
fatstart            rmb       3         ; reserve storage
database            rmb       3         ; reserve storage
remaining           rmb       1         ; reserve storage
spc                 rmb       1         ; reserve storage
pages               rmb       1         ; reserve storage
fatcount            rmb       1         ; reserve storage
buffer              rmb       2         ; reserve storage
image               rmb       2         ; reserve storage
bootsize            rmb       2         ; reserve storage
dest                rmb       2         ; reserve storage
size                equ       .         ; define constant or offset
                    mod       eom,name,Systm+Objct,ReEnt+1,start,size ; emit OS-9 module header
name                fcs       /Boot/              ; module name or literal text
start               orcc      #IntMasks ; set selected CC bits with #IntMasks
                    leas      -size,s   ; point S at -size,s
                    tfr       s,u       ; transfer registers s,u
* The early kernel starts S below $800. Page $800 is reserved for the
* later system stack (D.SysStk=$900), so it is free during F$Boot. Keeping
* scratch above S avoids the process descriptor at $600 and DMA bank splits.
                    ldd       #$0800    ; load D from #$0800
                    std       buffer,u  ; save D in buffer,u
                    lda       #DISKNUM  ; load A from #DISKNUM
                    sta       DEVADDR+6 ; save A in DEVADDR+6
                    lda       #(FATBase*2)/65536 ; load A from #(FATBase*2)/65536
                    sta       record,u  ; save A in record,u
                    ldd       #(FATBase*2)&65535 ; load D from #(FATBase*2)&65535
                    std       record+1,u ; save D in record+1,u
                    lbsr      read      ; call helper read
                    ldd       11,x      ; load D from 11,x
                    cmpd      #$0002    ; compare D with #$0002
                    lbne      bad       ; branch when unequal or nonzero bad
                    lda       13,x      ; load A from 13,x
                    lbeq      bad       ; branch when equal or zero bad
                    deca                ; decrement accumulator A
                    bita      13,x      ; test A against 13,x
                    lbne      bad       ; branch when unequal or nonzero bad
                    inca                ; increment accumulator A
                    sta       spc,u     ; save A in spc,u
                    lda       16,x      ; load A from 16,x
                    sta       fatcount,u ; save A in fatcount,u
                    leax      14,x      ; point X at 14,x
                    lbsr      word      ; call helper word
                    aslb                ; shift or rotate accumulator B
                    rola                ; shift or rotate accumulator A
                    std       record+1,u ; save D in record+1,u
                    lda       #0        ; load A from #0
                    rola                ; shift or rotate accumulator A
                    sta       record,u  ; save A in record,u
                    leay      volume,pcr ; point Y at volume,pcr
                    lbsr      add       ; call helper add
                    ldd       record,u  ; load D from record,u
                    std       fatstart,u ; save D in fatstart,u
                    lda       record+2,u ; load A from record+2,u
                    sta       fatstart+2,u ; save A in fatstart+2,u
                    ldx       buffer,u  ; load X from buffer,u
                    leax      36,x      ; point X at 36,x
                    lbsr      number    ; call helper number
                    std       record+1,u ; save D in record+1,u
* For 1/2 FATs, shift 1/2 times: FATSize * FATCount * two VHD records.
geo                 lbsr      shift     ; call helper shift
                    dec       fatcount,u ; decrement fatcount,u
                    bne       geo       ; branch when unequal or nonzero geo
                    leay      fatstart,u ; point Y at fatstart,u
                    lbsr      add       ; call helper add
                    ldd       record,u  ; load D from record,u
                    std       database,u ; save D in database,u
                    lda       record+2,u ; load A from record+2,u
                    sta       database+2,u ; save A in database+2,u
                    ldx       buffer,u  ; load X from buffer,u
                    leax      44,x      ; point X at 44,x
                    lbsr      number    ; call helper number
                    lbsr      setcluster ; call helper setcluster
                    lbsr      locate    ; call helper locate
search
entry               tst       ,x        ; test ,x
                    beq       bad       ; branch when equal or zero bad
                    leay      filename,pcr ; point Y at filename,pcr
                    pshs      x         ; preserve x on stack
                    ldb       #11       ; load B from #11
compare             lda       ,x+       ; load A from ,x+
                    cmpa      ,y+       ; compare A with ,y+
                    bne       mismatch  ; branch when unequal or nonzero mismatch
                    decb                ; decrement accumulator B
                    bne       compare   ; branch when unequal or nonzero compare
                    puls      x         ; restore x from stack
                    bra       found     ; continue unconditionally found
mismatch            puls      x         ; restore x from stack
                    leax      32,x      ; point X at 32,x
                    tfr       x,d       ; transfer registers x,d
                    tstb                ; test accumulator B
                    bne       entry     ; branch when unequal or nonzero entry
                    lbsr      next      ; call helper next
                    bra       search    ; continue unconditionally search
* OS9 boot memory and returned length are 16-bit; reject a rounded overflow.
found               ldd       30,x      ; load D from 30,x
                    bne       bad       ; branch when unequal or nonzero bad
                    leax      28,x      ; point X at 28,x
                    bsr       word      ; call helper word
                    std       bootsize,u ; save D in bootsize,u
                    beq       bad       ; branch when equal or zero bad
                    addd      #255      ; add to D: #255
                    bcs       bad       ; branch on carry or error bad
                    sta       pages,u   ; save A in pages,u
                    subd      #255      ; subtract from D: #255
                    pshs      u,x       ; preserve u,x on stack
                    os9       F$BtMem   ; invoke OS-9 F$BtMem service
                    tfr       u,y       ; transfer registers u,y
                    puls      u,x       ; restore u,x from stack
                    bcs       error     ; branch on carry or error error
                    sty       image,u   ; save Y in image,u
                    sty       dest,u    ; save Y in dest,u
                    lda       -8,x      ; load A from -8,x
                    sta       record,u  ; save A in record,u
                    leax      -2,x      ; point X at -2,x
                    bsr       word      ; call helper word
                    bsr       setcluster ; call helper setcluster
                    bsr       locate    ; call helper locate
load
                    ldy       dest,u    ; load Y from dest,u
                    clrb                ; clear accumulator B and carry
copy                lda       ,x+       ; load A from ,x+
                    sta       ,y+       ; save A in ,y+
                    decb                ; decrement accumulator B
                    bne       copy      ; branch when unequal or nonzero copy
                    sty       dest,u    ; save Y in dest,u
                    dec       pages,u   ; decrement pages,u
                    beq       loaded    ; branch when equal or zero loaded
                    bsr       next      ; call helper next
                    bra       load      ; continue unconditionally load
loaded
                    ldx       image,u   ; load X from image,u
                    clrb                ; clear accumulator B and carry
                    ldd       bootsize,u ; load D from bootsize,u
error               leas      size,s    ; point S at size,s
                    rts                 ; return to caller
bad                 tfr       u,s       ; transfer registers u,s
                    ldb       #E$BTYP   ; load B from #E$BTYP
                    coma                ; complement A and set carry
                    bra       error     ; continue unconditionally error
* Decode a little-endian 24-bit FAT value; VHD cannot address beyond 4 GiB.
number              lda       2,x       ; load A from 2,x
                    sta       record,u  ; save A in record,u
word                ldb       ,x        ; load B from ,x
                    lda       1,x       ; load A from 1,x
                    rts                 ; return to caller
setcluster          std       record+1,u ; save D in record+1,u
                    std       cluster+1,u ; save D in cluster+1,u
                    lda       record,u  ; load A from record,u
                    sta       cluster,u ; save A in cluster,u
                    rts                 ; return to caller
* Start a cluster: record = database + (cluster-2)*sectors/cluster*2.
* Read its first record here, so a 128-sector cluster's 256-record count
* can wrap to zero initially and then decrement to 255 before next tests it.
locate              ldd       cluster+1,u ; load D from cluster+1,u
                    subd      #2        ; subtract from D: #2
                    std       record+1,u ; save D in record+1,u
                    lda       cluster,u ; load A from cluster,u
                    sbca      #0        ; subtract from A with borrow: #0
                    sta       record,u  ; save A in record,u
                    ldb       spc,u     ; load B from spc,u
                    stb       remaining,u ; save B in remaining,u
                    asl       remaining,u ; shift left remaining,u
scale               bsr       shift     ; call helper shift
                    lsrb                ; shift or rotate accumulator B
                    bne       scale     ; branch when unequal or nonzero scale
                    leay      database,u ; point Y at database,u
                    bsr       add       ; call helper add
                    bra       getdata   ; continue unconditionally getdata
shift               asl       record+2,u ; shift left record+2,u
                    rol       record+1,u ; rotate left through carry record+1,u
                    rol       record,u  ; rotate left through carry record,u
                    rts                 ; return to caller
* Fetch the next 256-byte record; follow FAT when a cluster is exhausted.
next                tst       remaining,u ; test remaining,u
                    bne       getdata   ; branch when unequal or nonzero getdata
                    ldd       cluster,u ; load D from cluster,u
                    std       record,u  ; save D in record,u
                    lda       cluster+2,u ; load A from cluster+2,u
                    sta       record+2,u ; save A in record+2,u
                    ldb       #6        ; load B from #6
halve               lsr       record,u  ; shift right unsigned record,u
                    ror       record+1,u ; rotate right through carry record+1,u
                    ror       record+2,u ; rotate right through carry record+2,u
                    decb                ; decrement accumulator B
                    bne       halve     ; branch when unequal or nonzero halve
                    leay      fatstart,u ; point Y at fatstart,u
                    bsr       add       ; call helper add
                    bsr       read      ; call helper read
                    ldb       cluster+2,u ; load B from cluster+2,u
                    lslb                ; shift or rotate accumulator B
                    lslb                ; shift or rotate accumulator B
                    abx                 ; add unsigned B to X
                    lda       3,x       ; load A from 3,x
                    anda      #15       ; mask A with #15
                    bne       bad       ; branch when unequal or nonzero bad
                    bsr       number    ; call helper number
                    bsr       setcluster ; call helper setcluster
                    bra       locate    ; continue unconditionally locate
getdata             dec       remaining,u ; decrement remaining,u
                    bsr       read      ; call helper read
                    inc       record+2,u ; increment record+2,u
                    bne       ret       ; branch when unequal or nonzero ret
                    inc       record+1,u ; increment record+1,u
                    bne       ret       ; branch when unequal or nonzero ret
                    inc       record,u  ; increment record,u
ret                 rts                 ; return to caller
add                 ldd       record+1,u ; load D from record+1,u
                    addd      1,y       ; add to D: 1,y
                    std       record+1,u ; save D in record+1,u
                    lda       record,u  ; load A from record,u
                    adca      ,y        ; add to A with carry: ,y
                    sta       record,u  ; save A in record,u
                    rts                 ; return to caller
read                lda       record,u  ; load A from record,u
                    sta       DEVADDR   ; save A in DEVADDR
                    ldd       record+1,u ; load D from record+1,u
                    std       DEVADDR+1 ; save D in DEVADDR+1
                    ldx       buffer,u  ; load X from buffer,u
                    stx       DEVADDR+4 ; save X in DEVADDR+4
                    clr       DEVADDR+3 ; clear DEVADDR+3
                    tst       DEVADDR+3 ; test DEVADDR+3
                    beq       ret       ; branch when equal or zero ret
* Abandon nested subroutine calls on a device error.
                    lbra      bad       ; continue unconditionally bad
volume              fcb       (FATBase*2)/65536 ; emit byte data
                    fdb       (FATBase*2)&65535 ; emit word data
filename            fcc       /OS9BOOT    /       ; module name or literal text
* Any growth past $1D0 (including CRC) makes the fill fail at assembly time.
codeend             equ       *         ; define constant or offset
                    fill      $39,464-3-* ; pad to the required layout
                    emod      ;         finish module and CRC
eom                 equ       *         ; define constant or offset
