* FAT32 OS9Boot loader for the CoCo VHD interface.
* CoCo Level 2 only: exactly $1D0 bytes, including header and CRC.
* FATBase is the volume's 512-byte LBA; no partition-table scan is performed.
* Supports FAT #0, one/two FATs, 512-byte sectors and fragmented root/file chains.
* Checks the signature, FAT32 BPB layout/version, FAT count, regular-file type,
* reserved clusters and overflow in 24-bit VHD record arithmetic.
* Not a complete filesystem validator: media must have consistent geometry and
* chains. A cycle detector and LFN/subdirectory boot paths are not provided.
*
* U anchors a private stack frame. The first record buffer is $0800, the later
* system-stack page (D.SysStk=$0900), unused while the early kernel S is below it.
* $0900 contains D.SysMem and must never be used as a second DMA buffer.
* After F$BtMem, DMA goes directly into successive page-aligned output pages.
* A FAT read can use the next unfilled page: the following data read replaces it.
* F$BtMem returns the rounded allocation in D, used as the page count.
* The exact file size and image pointer are saved below the private frame;
* Loaded pops X then D. Error unwinds any nested calls directly from U.
* Returns X=image, D=exact size, carry clear; otherwise B=error and carry set.
* Routine placement keeps branches within this fixed slot; use label names,
* not assumed addresses, when changing it.
                    ifp1
                    use       defsfile  ; include OS-9 and hardware definitions
                  ENDC            ; conditional assembly
                    ifndef    FATBase   ; conditional assembly
FATBase             equ       0         ; define the assembly constant
                  ENDC            ; conditional assembly
                    ifndef    DEVADDR   ; conditional assembly
DEVADDR             equ       $FF80     ; define the assembly constant
                  ENDC            ; conditional assembly
                    ifndef    DISKNUM   ; conditional assembly
DISKNUM             equ       0         ; define the assembly constant
                  ENDC            ; conditional assembly
                  IFNE    Level-2 ; conditional assembly
                    error     FAT32     ; vhd Boot requires CoCo Level 2  ; literal text or assembly diagnostic
                  ENDC            ; conditional assembly
                  IFLT    FATBase ; conditional assembly
                    error     FATBase   ; must be nonnegative  ; literal text or assembly diagnostic
                  ENDC            ; conditional assembly
                  IFGT    FATBase-$7FFFFF ; conditional assembly
                    error     FATBase   ; exceeds VHD address space  ; literal text or assembly diagnostic
                  ENDC            ; conditional assembly
                  IFLT    DISKNUM ; conditional assembly
                    error     VHD       ; unit must be 0 or 1  ; literal text or assembly diagnostic
                  ENDC            ; conditional assembly
                  IFGT    DISKNUM-1 ; conditional assembly
                    error     VHD       ; unit must be 0 or 1  ; literal text or assembly diagnostic
                  ENDC            ; conditional assembly
*                   Keep      near branches short while the fixed-size assertion bounds any growth.  ; keep near branches short while the fixed-size assertion bounds any growth.
                    pragma    autobranchlength
                    org       0         ; begin stack-field offsets
* current page-aligned DMA destination.
buffer              rmb       2         ; reserve 2 stack bytes
* remaining allocated output pages.
pages               rmb       1         ; reserve 1 stack bytes
* 256-byte records left in this cluster; zero also encodes 256 initially.
remaining           rmb       1         ; reserve 1 stack bytes
* validated power-of-two sectors per cluster.
spc                 rmb       1         ; reserve 1 stack bytes
* current 24-bit VHD record address.
record              rmb       3         ; reserve 3 stack bytes
* current 24-bit FAT cluster.
cluster             rmb       3         ; reserve 3 stack bytes
* first FAT record address.
fatstart            rmb       3         ; reserve 3 stack bytes
* first data record address.
database            rmb       3         ; reserve 3 stack bytes
* private stack-frame bytes.
size                equ       .         ; define the assembly constant
                    mod       eom,name,Systm+Objct,ReEnt+1,start,size ; emit the OS-9 module header
name                fcs       /Boot/              ; literal text or assembly diagnostic
* increment only when another record is actually requested.
next                tst       remaining,u ; test remaining,u
                    beq       fatlink   ; branch if zero/equal to fatlink
                    inc       record+2,u ; increment record+2,u
                    bne       getdata   ; branch if nonzero/unequal to getdata
                    inc       record+1,u ; increment record+1,u
                    bne       getdata   ; branch if nonzero/unequal to getdata
                    inc       record,u  ; increment record,u
                    beq       bad       ; branch if zero/equal to bad
* read the requested data record into the current output page.
getdata             dec       remaining,u ; decrement remaining,u
                    bra       read      ; continue at read
* FAT entry record = fatstart + cluster / 64.
fatlink
                    ldd       cluster,u ; load D from cluster,u
                    std       record,u  ; store D in record,u
                    lda       cluster+2,u ; load A from cluster+2,u
                    sta       record+2,u ; store A in record+2,u
                    ldb       #6        ; load B from #6
halve               lsr       record,u  ; shift right record,u
                    ror       record+1,u ; rotate right through carry record+1,u
                    ror       record+2,u ; rotate right through carry record+2,u
                    decb                ; decrement the byte/count operand
                    bne       halve     ; branch if nonzero/unequal to halve
                    leay      fatstart,u ; set Y from fatstart,u
                    bsr       add       ; call add
                    bsr       read      ; call read
                    ldb       cluster+2,u ; load B from cluster+2,u
                    lslb                ; scale the FAT entry offset by two
                    lslb                ; scale the FAT entry offset by two
                    abx                 ; index the FAT entry within its 256-byte record
                    bsr       number    ; call number
                    bsr       setcluster ; call setcluster
                    bra       locate    ; continue at locate
* initialize the early-boot frame and select the VHD unit.
start               orcc      #IntMasks ; mask interrupts with #IntMasks
                    leas      -size,s   ; set S from -size,s
                    tfr       s,u       ; transfer registers s,u
                    ldd       #$0800    ; load D from #$0800
                    std       buffer,u  ; store D in buffer,u
                    lda       #DISKNUM  ; load A from #DISKNUM
                    sta       DEVADDR+6 ; store A in DEVADDR+6
                    lda       #(FATBase*2+1)/65536 ; load A from #(FATBase*2+1)/65536
                    sta       record,u  ; store A in record,u
                    ldd       #(FATBase*2+1)&65535 ; load D from #(FATBase*2+1)&65535
                    std       record+1,u ; store D in record+1,u
                    lbsr      read      ; call read
                    ldd       254,x     ; load D from 254,x
                    subd      #$55AA    ; subtract/check the 16-bit operand #$55AA
                    bne       badearly  ; branch if nonzero/unequal to badearly
                    dec       record+2,u ; decrement record+2,u
                    lbsr      read      ; call read
                    ldd       17,x      ; load D from 17,x
                    bne       badearly  ; branch if nonzero/unequal to badearly
                    ldd       22,x      ; load D from 22,x
                    bne       badearly  ; branch if nonzero/unequal to badearly
                    ldd       11,x      ; load D from 11,x
                    subd      #$0002    ; subtract/check the 16-bit operand #$0002
                    bne       badearly  ; branch if nonzero/unequal to badearly
                    lda       13,x      ; load A from 13,x
                    sta       spc,u     ; store A in spc,u
                    beq       badearly  ; branch if zero/equal to badearly
                    deca                ; form SPC minus one for the power-of-two test
                    bita      13,x      ; test attribute/cluster bits with 13,x
                    bne       badearly  ; branch if nonzero/unequal to badearly
                    bra       geometry  ; continue at geometry
* issue one synchronous 256-byte VHD DMA read.
read                lda       record,u  ; load A from record,u
                    sta       DEVADDR   ; store A in DEVADDR
                    ldd       record+1,u ; load D from record+1,u
                    std       DEVADDR+1 ; store D in DEVADDR+1
                    ldx       buffer,u  ; load X from buffer,u
                    stx       DEVADDR+4 ; store X in DEVADDR+4
                    clr       DEVADDR+3 ; clr DEVADDR+3
                    tst       DEVADDR+3 ; test DEVADDR+3
                    bne       badearly  ; branch if nonzero/unequal to badearly
                    rts                 ; return to caller
* add a 24-bit record base and reject carry past bit 23.
add                 ldd       record+1,u ; load D from record+1,u
                    addd      1,y       ; add the low record word from 1,y
                    std       record+1,u ; store D in record+1,u
                    lda       record,u  ; load A from record,u
                    adca      ,y        ; add the high record byte with carry from ,y
                    lbcs      bad       ; reject carry/overflow via bad
                    sta       record,u  ; store A in record,u
                    rts                 ; return to caller
* adopt the decoded cluster; Locate creates its record address.
setcluster          std       cluster+1,u ; store D in cluster+1,u
                    lda       record,u  ; load A from record,u
                    sta       cluster,u ; store A in cluster,u
                    rts                 ; return to caller
* record = database + (cluster - 2) * SPC * 2.
locate              ldd       cluster+1,u ; load D from cluster+1,u
                    subd      #2        ; subtract/check the 16-bit operand #2
                    std       record+1,u ; store D in record+1,u
                    lda       cluster,u ; load A from cluster,u
                    sbca      #0        ; propagate the cluster subtraction borrow from #0
                    bcs       bad       ; reject carry/overflow via bad
                    sta       record,u  ; store A in record,u
                    ldb       spc,u     ; load B from spc,u
                    stb       remaining,u ; store B in remaining,u
                    asl       remaining,u ; shift left remaining,u
* multiply by the cluster size, rejecting dropped high bits.
scale               bsr       shift     ; call shift
                    lsrb                ; advance the power-of-two shift count
                    bne       scale     ; branch if nonzero/unequal to scale
                    leay      database,u ; set Y from database,u
                    bsr       add       ; call add
                    bra       getdata   ; continue at getdata
* return invalid-media error through the common stack unwind.
badearly
                    ldb       #E$BTYP   ; load B from #E$BTYP
                    coma                ; set carry for an OS-9 error
                    lbra      error     ; continue at error
* decode FAT/data addresses while retaining the BPB pointer in X.
geometry
                    leax      14,x      ; set X from 14,x
                    lbsr      word      ; call word
                    aslb                ; double the low reserved-sector byte
                    rola                ; carry into the high reserved-sector byte
                    std       record+1,u ; store D in record+1,u
                    lda       #0        ; load A from #0
                    rola                ; carry into the high reserved-sector byte
                    sta       record,u  ; store A in record,u
                    leay      volume,pcr ; set Y from volume,pcr
                    lbsr      add       ; call add
                    ldd       record,u  ; load D from record,u
                    std       fatstart,u ; store D in fatstart,u
                    lda       record+2,u ; load A from record+2,u
                    sta       fatstart+2,u ; store A in fatstart+2,u
                    ldx       buffer,u  ; load X from buffer,u
                    leax      36,x      ; set X from 36,x
                    lbsr      number    ; call number
                    std       record+1,u ; store D in record+1,u
                    ldb       -20,x     ; load B from -20,x
                    decb                ; decrement the byte/count operand
                    cmpb      #1        ; check the maximum normalized FAT count #1
                    bhi       badearly  ; reject an unsigned excess via badearly
* one shift for one FAT, two shifts for two FATs.
geo                 lbsr      shift     ; call shift
                    decb                ; decrement the byte/count operand
                    bpl       geo       ; repeat while the FAT shift count is nonnegative at geo
                    leay      fatstart,u ; set Y from fatstart,u
                    lbsr      add       ; call add
                    ldd       record,u  ; load D from record,u
                    std       database,u ; store D in database,u
                    lda       record+2,u ; load A from record+2,u
                    sta       database+2,u ; store A in database+2,u
                    leax      8,x       ; x still addresses BPB FATSize at 36; root cluster is at 44
                    ldd       -2,x      ; load D from -2,x
                    bne       bad       ; branch if nonzero/unequal to bad
                    bsr       number    ; call number
                    lbsr      setcluster ; call setcluster
                    lbsr      locate    ; call locate
                    bra       search    ; continue at search
* nearby trampoline for late validation failures.
bad                 lbra      badearly  ; continue at badearly
* reject high cluster bits not representable by this VHD booter.
number              lda       3,x       ; load A from 3,x
                    anda      #15       ; ignore reserved FAT bits with #15
                    bne       bad       ; branch if nonzero/unequal to bad
                    lda       2,x       ; load A from 2,x
                    sta       record,u  ; store A in record,u
* decode a little-endian word without changing X.
word                ldb       ,x        ; load B from ,x
                    lda       1,x       ; load A from 1,x
                    rts                 ; return to caller
* compile-time volume base in VHD records.
volume              fcb       (FATBase*2)/65536 ; emit constant bytes
                    fdb       (FATBase*2)&65535 ; emit constant word
* exact padded 8.3 alias, including the blank extension.
filename            fcc       /OS9BOOT    /       ; literal text or assembly diagnostic
* double a 24-bit record operand with an overflow check.
shift               asl       record+2,u ; shift left record+2,u
                    rol       record+1,u ; rotate left through carry record+1,u
                    rol       record,u  ; rotate left through carry record,u
                    bcs       bad       ; reject carry/overflow via bad
                    rts                 ; return to caller
* recover the image pointer and exact size from the private save stack.
loaded
                    puls      x         ; restore x on the private stack
                    clrb                ; clear carry before returning the exact file size
                    puls      d         ; restore d on the private stack
* discard private state and nested call frames without touching carry.
error               leas      size,u    ; set S from size,u
                    rts                 ; return to caller
* accept only a regular file whose size fits the Boot contract.
found               ldd       30,x      ; load D from 30,x
                    bne       bad       ; branch if nonzero/unequal to bad
                    leax      28,x      ; set X from 28,x
                    bsr       word      ; call word
                    std       ,--s      ; save exact size; STD also tests the full word for zero
                    beq       bad       ; branch if zero/equal to bad
                    pshs      u,x       ; preserve u,x on the private stack
                    os9       F$BtMem   ; os9 F$BtMem
                    tfr       u,y       ; transfer registers u,y
                    puls      u,x       ; restore u,x on the private stack
                    bcs       error     ; reject carry/overflow via error
                    sta       pages,u   ; f$BtMem returns the page-rounded allocation in A
                    pshs      y         ; preserve y on the private stack
                    sty       buffer,u  ; store Y in buffer,u
                    ldd       -8,x      ; load D from -8,x
                    tstb                ; test the remaining count or high cluster byte
                    bne       bad       ; branch if nonzero/unequal to bad
                    sta       record,u  ; store A in record,u
                    leax      -2,x      ; set X from -2,x
                    bsr       word      ; call word
                    bsr       setcluster ; call setcluster
                    bsr       locate    ; call locate
                    bra       load      ; continue at load
* each page is already in place after VHD DMA.
load                dec       pages,u   ; decrement pages,u
                    beq       loaded    ; branch if zero/equal to loaded
                    inc       buffer,u  ; increment buffer,u
                    bsr       next      ; call next
                    bra       load      ; continue at load
* scan complete short-name records, following fragmented root chains.
search
entry               tst       ,x        ; test ,x
                    beq       bad       ; branch if zero/equal to bad
                    leay      filename,pcr ; set Y from filename,pcr
                    pshs      x         ; preserve x on the private stack
                    ldb       #11       ; load B from #11
                    lda       11,x      ; filter non-file aliases before matching the name
                    bita      #$18      ; directories, volume labels and LFN records
                    bne       mismatch  ; B is nonzero and X is already saved
compare             lda       ,x+       ; load A from ,x+
                    cmpa      ,y+       ; cmpa ,y+
                    bne       mismatch  ; branch if nonzero/unequal to mismatch
                    decb                ; decrement the byte/count operand
                    bne       compare   ; branch if nonzero/unequal to compare
mismatch            puls      x         ; restore x on the private stack
                    tstb                ; test the remaining count or high cluster byte
                    beq       found     ; branch if zero/equal to found
                    leax      32,x      ; set X from 32,x
                    tfr       x,d       ; transfer registers x,d
                    tstb                ; test the remaining count or high cluster byte
                    bne       entry     ; branch if nonzero/unequal to entry
                    lbsr      next      ; call next
                    bra       search    ; continue at search
* end of executable code and literals, before slot padding.
codeend             equ       *         ; define the assembly constant
                    fill      $39,464-3-* ; fail assembly if the 464-byte slot is exceeded
                    emod      ;         finish the module and CRC
* complete OS-9 module size.
eom                 equ       *         ; define the assembly constant
