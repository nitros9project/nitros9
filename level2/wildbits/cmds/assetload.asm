********************************************************************
* assetload - load a file into a run of physical memory blocks
*
* Loads fonts, CLUTs, bitmaps, tilesets, tilemaps and sprites from a
* file straight into the physical blocks that will hold them.
*
* Runs as its own process so it has a private 8-slot DAT image: it can
* map several blocks at once and read into them without touching the
* system map (where device static storage lives) or the caller's map.
* An application F$Forks this and F$Waits, so only that application
* blocks for the duration of the read - the rest of the system runs on.
*
* Usage: assetload <path> <startblock> [<blockcount> [<offset>]]
*
*   <path>       file to load.  If it is an OS-9 data module ($87CD)
*                the load starts at the module's M$Exec offset, so the
*                header and name are skipped.  Otherwise the whole file
*                is loaded from offset 0.
*   <startblock> first physical block, in hex (e.g. FD for the font block)
*   <blockcount> how many blocks may be written, in hex.  Defaults to 1.
*                This is a hard limit: the load never writes past
*                <startblock>+<blockcount>-1, so a file bigger than the
*                caller's allocation is truncated instead of running on
*                into blocks it does not own.  Getting this wrong is the
*                one way to do real damage - block FD with a count of 2
*                would walk straight into the text screen at $FE/$FF.
*   <offset>     byte offset within the first block, in hex.  Defaults to 0.
*                Font set 1 lives at $FD+$0800 and the CLUTs at $FD+$1000,
*                $1400, $1800 and $1C00, so sub-block assets need this.
*                It applies to the first pass only; the read is shortened
*                by the same amount so it still stops at the end of the
*                block allowance.
*
* Exits with the error code in B, which the parent picks up from F$Wait.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2026/09/08  Claude
* Created from vtio's FileGetAllData.  That routine ran inside the
* driver, so it leaned on Rd2B2Mem's D.Proc/D.SysPrc swap to steer
* I$Read at the driver's system-map stack.  Here D.Proc is already this
* process, so the swap is gone - keeping it would have aimed the header
* read into the system map.  It also mapped and read one 8K block per
* pass; this maps up to WINBLKS at a time and issues one I$Read across
* the whole window.

                    nam       assetload
                    ttl       load a file into physical memory blocks

                  IFP1
                    use       defsfile
                  ENDC

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

* Blocks mapped per pass.  The module's own code and data take two of
* the eight DAT slots, so six is the most that is reliably free.  If the
* map is tighter than that, MapWindow retries with a smaller window.
WINBLKS             equ       6

                    mod       eom,name,tylg,atrv,start,size

*---------------------------------------------------
* Data area / direct page
*---------------------------------------------------
cmdptr              rmb       2         command line pointer
pathnum             rmb       1         open path number
startblk            rmb       2         first physical block
maxblks             rmb       1         blocks we are allowed to write
blksdone            rmb       1         blocks written so far
curwin              rmb       1         blocks mapped this pass
mapaddr             rmb       2         base of the mapped window
hdrbuf              rmb       2         two-byte header scratch
inoff               rmb       2         offset into the first block
* F$Chain carves the register stack and the parameter area out of this
* same allocation (fchain.asm:95-97 subtracts R$Size and the parameter
* size, and fails the fork with E$IForkP if that underflows), so both
* have to be reserved here on top of our own working stack.
STACKSZ             set       256
PARMSZ              set       256
                    rmb       STACKSZ+PARMSZ
size                equ       .

name                fcs       /assetload/
                    fcb       edition

*---------------------------------------------------
* start - entry from F$Fork
*
* U/DP = data area base, X = SP = parameter area,
* Y    = top of memory, D = parameter size
*---------------------------------------------------
start               stx       <cmdptr   ; save the command line
                    clr       <blksdone
                    clr       <inoff
                    clr       <inoff+1
                    lda       #1        ; default to a single block, so a
                    sta       <maxblks  ; big file cannot overrun a small
*                                                 allocation
                    lbsr      ParseCmd
                    bcs       Die       ; malformed command line

* Open the file.  I$Open parses the pathlist itself and stops at the
* space or CR that follows it, so the pointer into the command line can
* be handed over as-is - no need to copy the name out first.
                    ldx       <cmdptr   ; x -> path text
                    lda       #READ.
                    os9       I$Open
                    bcs       Die
                    sta       <pathnum

* Position at the first byte of payload, then read it in.
                    lbsr      SeekData
                    bcs       Finish
                    lbsr      LoadLoop

Finish              pshs      b         ; keep the real status
                    lda       <pathnum
                    os9       I$Close
                    puls      b

* Exit with B as the status; the parent reads it back from F$Wait.
Die                 os9       F$Exit

*---------------------------------------------------
* SeekData - position the path at the first byte of payload
*
* Reads the first two bytes.  $87CD means an OS-9 module, so the real
* data starts at the offset stored at M$Exec ($09) - that is how the
* fonts in sys/fonts are built.  Anything else is treated as a raw file
* and read from the beginning.
*
* Exit: carry set = error, B = code
*---------------------------------------------------
* I$Seek wants the low half of the position in U, but U is this
* process's data area base and Read2 addresses hdrbuf through it, so
* every seek has to hand U back afterwards.
SeekData            lbsr      Read2     ; fetch the sync bytes
                    bcs       sd_ex
                    ldx       <hdrbuf
                    cmpx      #M$ID12   ; an OS-9 module?
                    beq       sd_mod
* Raw file - rewind to the start.
                    ldx       #0
                    pshs      u
                    ldu       #0
                    lda       <pathnum
                    os9       I$Seek
                    puls      u
                    rts
* Module - read the two bytes at M$Exec and seek there.
sd_mod              ldx       #0
                    pshs      u
                    ldu       #M$Exec
                    lda       <pathnum
                    os9       I$Seek
                    puls      u
                    bcs       sd_ex
                    lbsr      Read2
                    bcs       sd_ex
                    ldx       #0
                    pshs      u
                    ldu       <hdrbuf   ; u = execution offset
                    lda       <pathnum
                    os9       I$Seek
                    puls      u
sd_ex               rts

*---------------------------------------------------
* Read2 - read two bytes into hdrbuf
*
* The driver original went through Rd2B2Mem, which pointed D.Proc at
* D.SysPrc so that I$Read landed on the driver's system-map stack.  Here
* the buffer is in this process's own map and D.Proc already points at
* us, so it is a plain read.  The original also held IntMasks across the
* call, masking interrupts over a blocking disk read.
*
* Exit: carry set = error, B = code
*---------------------------------------------------
Read2               lda       <pathnum
                    leax      <hdrbuf,u
                    ldy       #2
                    os9       I$Read
                    rts

*---------------------------------------------------
* LoadLoop - map a window of blocks and read into it, repeating until
* the file runs out or the caller's block allowance is used up.
*
* Exit: carry set = error, B = code
*---------------------------------------------------
LoadLoop            pshs      u         ; mapWindow/F$ClrBlk reuse U
ll_top              lda       <maxblks
                    suba      <blksdone ; blocks still allowed
                    beq       ll_done   ; allowance used up - stop
                    cmpa      #WINBLKS
                    bls       ll_win
                    lda       #WINBLKS
ll_win              sta       <curwin
                    lbsr      MapWindow ; may shrink curwin
                    bcs       ll_ex
                    stu       <mapaddr
* One read across the whole window.  curwin * $2000 is curwin shifted
* five places into the high byte, with a zero low byte.
                    lda       <curwin
                    lsla
                    lsla
                    lsla
                    lsla
                    lsla
                    clrb
                    subd      <inoff    ; the offset eats into this pass
                    tfr       d,y       ; y = bytes to request
                    pshs      y         ; remember what we asked for
                    ldd       <mapaddr
                    addd      <inoff
                    tfr       d,x       ; x = where the data lands
                    lda       <pathnum
                    os9       I$Read    ; y = bytes actually read
* Unmap before anything else, carrying the read's status and its count
* past the F$ClrBlk.
                    pshs      cc,b
                    pshs      y
                    ldu       <mapaddr
                    ldb       <curwin
                    os9       F$ClrBlk
                    puls      y         ; y = bytes read
                    puls      cc,b      ; restore the read's status
                    clr       <inoff    ; first pass only
                    clr       <inoff+1
                    bcs       ll_eof
* The window is accounted for whether or not it filled.  A short read
* means we reached the end of the file and there is nothing more to do.
                    lda       <curwin
                    adda      <blksdone
                    sta       <blksdone
                    cmpy      ,s++      ; got vs requested
                    blo       ll_done   ; short read - end of file
                    bra       ll_top
* E$EOF here is the ordinary end of a file whose length is an exact
* multiple of the window.  The original reported that as a failure.
ll_eof              leas      2,s       ; drop the requested count
                    cmpb      #E$EOF
                    bne       ll_ex
                    tst       <blksdone ; did anything actually land?
                    beq       ll_ex     ; no - report the E$EOF
ll_done             clrb
                    andcc     #^Carry
ll_ex               puls      u,pc

*---------------------------------------------------
* MapWindow - map <curwin> consecutive blocks starting at
*             <startblk> + <blksdone>
*
* F$MapBlk takes the block count in B and maps consecutive blocks from
* X, handing back the base address in U.  If the process map has no run
* that long, shrink the window and try again rather than giving up.
*
* Exit: U = base address, <curwin> possibly reduced
*       carry set = error, B = code
*---------------------------------------------------
MapWindow           bsr       mw_blk
mw_try              ldb       <curwin
                    os9       F$MapBlk
                    bcc       mw_ok
                    lda       <curwin
                    deca                ; no room - try a smaller window
                    beq       mw_fail
                    sta       <curwin
                    bsr       mw_blk    ; f$MapBlk clobbered X
                    bra       mw_try
mw_ok               andcc     #^Carry
                    rts
mw_fail             comb
                    ldb       #E$MemFul
                    rts
* X = first physical block of this pass
mw_blk              ldd       <startblk
                    addb      <blksdone
                    adca      #0
                    tfr       d,x
                    rts

*---------------------------------------------------
* ParseCmd - pull the block number and count off the command line
*
* <cmdptr> is left pointing at the path, which is the first thing on the
* line.  The path is followed by the start block in hex and, optionally,
* the block count in hex.
*
* Exit: carry set = malformed
*---------------------------------------------------
ParseCmd            ldx       <cmdptr
                    bsr       SkipSpace
                    stx       <cmdptr   ; x -> path
                    cmpa      #C$CR     ; nothing on the line?
                    beq       pc_bad
* Step over the path to the blank that follows it.
pc_skip             lda       ,x+
                    cmpa      #C$CR
                    beq       pc_bad    ; no block number given
                    cmpa      #C$SPAC
                    bne       pc_skip
                    bsr       SkipSpace
                    bsr       ParseHex  ; start block
                    bcs       pc_bad
                    std       <startblk
* The block count is optional; without it maxblks stays at 1.
                    bsr       SkipSpace
                    cmpa      #C$CR
                    beq       pc_ok
                    bsr       ParseHex
                    bcs       pc_ok     ; unreadable - keep the default
                    tstb                ; a count of zero would load
                    beq       pc_blk    ; nothing, so ignore it
                    stb       <maxblks
* The in-block offset is optional too.
pc_blk              bsr       SkipSpace
                    cmpa      #C$CR
                    beq       pc_ok
                    bsr       ParseHex
                    bcs       pc_ok     ; unreadable - keep zero
                    std       <inoff
pc_ok               andcc     #^Carry
                    rts
pc_bad              comb
                    ldb       #E$BPNam
                    rts

*---------------------------------------------------
* SkipSpace - advance X past blanks
* Exit: A = first non-blank, X -> it
*---------------------------------------------------
SkipSpace           lda       ,x
                    cmpa      #C$SPAC
                    bne       ss_ex
                    leax      1,x
                    bra       SkipSpace
ss_ex               rts

*---------------------------------------------------
* ParseHex - read hex digits at X
* Exit: D = value, X past the digits, carry set if there were none
*---------------------------------------------------
ParseHex            pshs      y
                    ldy       #0        ; y accumulates the value
                    clr       ,-s       ; digit counter
ph_lp               lda       ,x
                    cmpa      #$30      ; below '0'?
                    blo       ph_end
                    cmpa      #$39      ; '0'-'9'?
                    bhi       ph_af
                    suba      #$30
                    bra       ph_dig
ph_af               anda      #$DF      ; fold lower case up
                    cmpa      #$41      ; below 'A'?
                    blo       ph_end
                    cmpa      #$46      ; above 'F'?
                    bhi       ph_end
                    suba      #$37      ; 'A' -> 10
ph_dig              pshs      a
                    tfr       y,d       ; value = value * 16
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    addb      ,s+       ; + this digit
                    adca      #0
                    tfr       d,y
                    inc       ,s        ; count it
                    leax      1,x
                    bra       ph_lp
ph_end              tst       ,s+       ; saw at least one digit?
                    beq       ph_bad
                    tfr       y,d
                    puls      y
                    andcc     #^Carry
                    rts
ph_bad              puls      y
                    comb
                    rts

                    emod
eom                 equ       *
                    end
