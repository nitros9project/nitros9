;;;
;;;  Boot OS9 via CoCoBoot interface
;;;
;;;

CR                  equ       13
SP                  equ       32

DBUF0               equ       $600                ; we'll borrow some memory from basic
DBUF1               equ       $700                ; another buffer
SCRPTR              equ       $0002               ; point to the os screen pointer

DD.BIT              equ       $6                  ; 2B no of sectors per cluster
DD.NAM              equ       $1f                 ; 32B volume name field
DD.DIR              equ       $8                  ; 3B descriptor cluster for root dir

FD.SIZ              equ       $9                  ; 4B size of file in bytes


;;;
;;;
;;;  Low Ram Variables
;;;
;;;
                    org       $2000
RAM                 equ       *
root                rmb       3                   ; 3b lsn of root dir
                    ;;        FCB                 - vars needed to control file access.
sptr                rmb       2                   ; ptr to current segment
dptr                rmb       2                   ; ptr to data buffer
bcount              rmb       2                   ; number of bytes left in buffer
fcounth             rmb       2                   ; number of bytes left in file (high word)
fcount              rmb       2                   ; number of bytes left in file (low word)
                    ;;        and                 a buffer for directory entries
dirbuf              rmb       32                  ;
ksize               rmb       2                   ; "stacked" size of os9 boot file
stack               rmb       64
stackb              ;         bottom              of stack

;;;
;;;
;;; Code
;;;
;;;


                    org       $c000               ; sit low
prestart
                    jmp       start               ; me first, but jump over DATA


BOOT                fcn       "OS9Boot"
KRN                 fcn       "ccbkrn"
str0                fcn       "Loading            OS9Boot"
str1                fcn       "Loading            ccbkrn"
str2                fcn       "Xfr                Control to KRN..."
str3                fcn       "CoCoBoot           SDIO"
str4                fcn       "Vol                Name: "

start
                    orcc      #$50                ; shut off interrupts
                    lds       #stackb             ; set stack
                    ;;        clear               RAM vars
                    ldx       #RAM
                    ldb       #stack-RAM
                    jsr       memz
                    ;;
                    ldx       #$ff90              ; setup gimme
                    jsr       gime                ;
                    clr       $ffa0               ; set mmu bank 0 to phys 0
*	clr	$ffdf		; set SAM RAM mode
                    ;;        setup               screen
                    jsr       scrSetup            ; setup screen
                    ldx       #str3               ; print banner
                    jsr       putscr              ;
x@                  bra       x@
                    ;;        init                SD card
                    jsr       ll_init
                    lbcs      initerr
                    ;;        get                 LSN0
                    ldx       #DBUF0              ; set disk arg
                    stx       DPTR
                    clr       LSN
                    clr       LSN+1
                    clr       LSN+2
                    ;;        Test                for CCPT here !!!!
                    jsr       ccpttest
                    ;;        try                 to mount os9 filesystem
                    jsr       getlsn
                    ;;        print               volume name
                    ldx       #str4
                    jsr       puts
                    ldx       #DBUF0+DD.NAM
                    jsr       putscr
                    ;;        get                 root dir's lsn
                    ldx       #DBUF0+DD.DIR
                    ldu       #root
                    jsr       cpy3
                    ;;        open                boot file
                    ldx       #str0
                    jsr       puts
                    ldx       #BOOT
                    jsr       nopen
                    lbcs      fnferr
                    ldx       #dirbuf+$1d         ; !!! replace with constant
                    ldu       #LSN                ;
                    jsr       cpy3                ; set LSN = lsn of dirent
                    jsr       open                ; and open the file
                    ldd       fcounth             ; check size
                    lbne      toobig              ;
                    ;;        calculate           start address
                    ldd       fcount              ; save os9 size for passing to KRN
                    std       ksize               ;
                    ldd       #$f000              ; f000 - fcount = start address
                    subd      fcount              ;
                    clrb                          ; and round it down
                    tfr       d,x                 ; X = cpu load address
                    cmpx      #$4000              ; cant go lower
                    lblo      toobig
                    ;;        set                 mmu
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra                          ; A = mmu bank no
                    ldy       #$ffa0
                    leay      a,y                 ; Y = beginning mmu
                    ldb       #1                  ; 1 is first os9 system block
a@                  stb       ,y+                 ; store bank no in mmu
                    cmpy      #$ffa7              ; did we move to the last mmu block
                    beq       b@                  ; yes, then quit looping
                    incb                          ; increment bank no
                    bra       a@                  ; repeat
                    ;;        copy                os9boot into memory
b@                  jsr       fload               ; load os9boot into memory
                    jsr       putCR
                    ;;        open                krn file
                    ldx       #str1
                    jsr       puts
                    ldx       #KRN
                    jsr       nopen
                    bcs       fnferr
                    ldx       #dirbuf+$1d         ; !!! replace with constant
                    ldu       #LSN                ;
                    jsr       cpy3                ; set LSN = lsn of dirent
                    jsr       open                ; and open the file
                    ldx       fcounth             ; check size of krn file
                    lbne      krnsize             ; is way too big
                    ldx       fcount              ;
                    cmpx      #$f00               ;
                    lbne      krnsize             ; wrong size
                    ;;        copy                krn file into memory
                    ldx       #$f000
                    jsr       fload               ; load ccbkrn into memory
                    jsr       putCR
                    ;;        clear               out DP page
                    ldx       #0
                    clrb
                    jsr       memz
                    ;;        set                 dp
                    tfr       b,dp
                    ;;        set                 gime mirror
                    ldx       #$90
                    jsr       gime
                    ;;        jump                to OS9
                    ldx       #str2
                    jsr       putscr
                    ldx       $f009               ; KRN relative start address
                    leax      $f000,x             ; make it absolute
                    ldu       #ksize              ; U = ptr to os9boot size
                    orcc      #$50
                    jmp       ,x                  ; jump to kernel (bye!)

iloop               bra       iloop


fnferr              ldx       #p0@
                    jsr       puts
a@                  bra       a@
p0@                 fcn       ":                  FNF Error!"

initerr             ldx       #p0@
                    jsr       puts
a@                  bra       a@
p0@                 fcn       "Driver             Init Error!"

mnterr              ldx       #p0@
                    jsr       puts
a@                  bra       a@
p0@                 fcn       "LSN0:              bad format!"

toobig              ldx       #p0@
                    jsr       puts
a@                  bra       a@
p0@                 fcn       "Too                Big!"

krnsize
                    ldx       #p0@
                    jsr       puts
a@                  bra       a@
p0@                 fcn       "Wrong              Size!"


;;; Test for presence of CCPT partitioning
ccpttest
                    pshs      d,x
                    ldd       DBUF0               ; get magic
                    cmpd      #$4343              ; check for "CC"
                    lbne      no@
                    ldd       DBUF0+2             ; check for "PT"
                    cmpd      #$5054
                    lbne      no@                 ;
no@                 ldx       #p0@
                    jsr       putscr
                    puls      d,x,pc
p0@                 fcn       "CCPT               not found."


;;; Setup Screen for os9 (sigh)
scrSetup
                    pshs      d,x
                    ;;        set                 colors: green on black
                    ldb       #$12
                    stb       $ffbc
                    ldb       #0
                    stb       $ffbd
                    ;;        clear               a screen's worth of video memory
                    ldb       #$3b
                    stb       $ffa0
                    ldx       #$0000
                    ldd       #$2020
a@                  std       ,x++
                    cmpx      #$0400
                    bne       a@
                    ;;        set                 screen pointer up
                    ldd       #8
                    std       SCRPTR
                    clr       $ffa0
                    puls      d,x,pc


;;; Setup memory with gimme setting, aka Do os9's work :(
;;;   takes: X = address
;;;   returns: nothing
;;;   modifies: nothing
gime
                    pshs      d,x,u
                    ldu       #table@
                    lda       #16
a@                  ldb       ,u+
                    stb       ,x+
                    deca
                    bne       a@
                    puls      d,x,u,pc
table@              .dw       $6c00
                    .dw       $0000
                    .dw       $0900
                    .dw       $0000
                    .dw       $0320
                    .dw       $0000
                    .db       $00
                    .dw       $ec01
                    .db       $00



;;; Read file into memory
;;;   takes: X = address to load, file opened.
;;;   modifies: nothing
fload               pshs      b,x
a@                  jsr       readb
                    bcs       done@
                    stb       ,x+
                    bra       a@
done@               puls      b,x,pc



;;; open a file via a name
;;;    takes: X = filename (zero termed)
;;;    returns: dirbuf set to file's FD, C set on error.
nopen
                    pshs      d,x,u
                    ;;        open                root directory
                    ldx       #root
                    ldu       #LSN
                    jsr       cpy3
                    jsr       open
                    ;;        get                 a dirent into buffer
                    ldu       2,s                 ; U = filename
b@                  lda       #32
                    ldx       #dirbuf
a@                  jsr       readb
                    bcs       nfound@
                    stb       ,x+
                    deca
                    bne       a@
                    jsr       os9toz
                    ldx       #dirbuf
                    jsr       strcmp
                    bcc       found@
                    bra       b@
nfound@             coma
                    puls      d,x,u,pc
found@              clra
                    puls      d,x,u,pc


;;; zero mem
;;;   takes: X = ptr, B = number of byte to zero
;;;   returns: nothing
;;;   modifies: nothing
memz
                    pshs      b,x
a@                  clr       ,x+
                    decb
                    bne       a@
                    puls      b,x,pc



;;; strcmp
;;;   takes: X = zstring, U = zstring
;;;   returns: C clear if equal
strcmp
                    pshs      b,x,u
a@                  ldb       ,x+
                    cmpb      ,u+
                    bne       ne@                 ; not equal
                    tstb
                    beq       e@                  ; equal
                    bra       a@                  ; loop
e@                  clrb
                    puls      b,x,u,pc
ne@                 comb
                    puls      b,x,u,pc

;;; change dirbuf's name to a z-string
os9toz
                    pshs      b,x
                    ldx       #dirbuf
                    tst       ,x
                    beq       out@
a@                  ldb       ,x+
                    bpl       a@
                    andb      #$7f
                    stb       -1,x
                    clr       ,x
out@                puls      b,x,pc


;;; Open file
;;;   takes: LSN = lsn of file's FD
;;;   returns: nothing
open
                    pshs      d,x
                    ldx       #DBUF1              ; load dbuf1 with file's FD
                    stx       DPTR
                    jsr       getlsn
                    ldd       #DBUF1+$10          ; first segment
                    std       sptr                ; save ptr
                    jsr       fill                ; and get first sector
                    ;;        set                 fcount
                    ldd       DBUF1+FD.SIZ
                    std       fcounth
                    ldd       DBUF1+FD.SIZ+2
                    std       fcount
                    puls      d,x,pc

;;; get one byte from file
;;;   takes: nothing,
;;;   returns: B = byte, C set on EOF
readb
                    pshs      a,x
                    ldd       fcount              ; is the entire file out of bytes?
                    beq       eof@
                    ldd       bcount
                    bne       a@                  ; if left don't refill
                    ;;        refill              file's data buffer
                    jsr       fill
                    ;;
a@                  ldd       fcount
                    subd      #1
                    std       fcount
                    ldd       bcount
                    subd      #1
                    std       bcount
                    ldx       dptr
                    ldb       ,x+
                    stx       dptr
                    clra
                    puls      a,x,pc
eof@                coma
                    puls      a,x,pc


fill
                    pshs      d,x,u               ; save regs
                    jsr       spin1
                    ldx       sptr
                    ldd       3,x                 ; get sector count
                    bne       a@                  ; no more secs left in seg?
                    ;;        get                 next segment
                    ldx       sptr
                    leax      5,x
                    stx       sptr
                    ;;        fill                buffer
a@                  ldx       sptr                ; copy segment's LSN to args
                    ldu       #LSN                ;
                    jsr       cpy3                ;
                    ldx       #DBUF0              ; set data buffer
                    stx       DPTR                ;
                    jsr       getlsn              ; and get the sector
                    ;;        increment           segment
                    ldx       sptr                ; increment segment's LSN
                    jsr       inc3                ;
                    ldd       3,x                 ; decrement segment's sector count
                    subd      #1                  ;
                    std       3,x                 ;
                    ;;        set                 file dirs
                    ldd       #256
                    std       bcount
                    ldd       #DBUF0
                    std       dptr
                    puls      d,x,u,pc            ; return


;;; Spin the ticker
;;;   takes: nothing
;;;   returns: nothing
;;;   modifies: nothing
spin1
                    pshs      b
                    ldb       #'.
                    jsr       putc
                    puls      b,pc


;;; Copy 3 bytes value
;;;   take: X = src ptr, U = dst ptr
;;;   modifies: nothing
cpy3
                    pshs      d,x,u
                    ldd       ,x++
                    std       ,u++
                    ldb       ,x
                    stb       ,u
                    puls      d,x,u,pc


;;; increment 3 byte value by one
;;;  takes: X = ptr to 3 bytes
;;;  returns: nothing
inc3
                    pshs      d,x
                    ldd       1,x
                    addd      #1
                    std       1,x
                    ldb       ,x
                    adcb      #0
                    stb       ,x
                    puls      d,x,pc


;;; deblocker to translate 256B LSN to a 512B LSN
;;;   takes: args in LSN/DPTR
;;;   modifies: nothing
getlsn
                    pshs      b,x
                    ldx       #LSN                ; get pointer
                    lsr       ,x+
                    ror       ,x+
                    ror       ,x+
                    ldb       #1                  ; 256b lower read
                    bcc       a@
                    negb
a@                  stb       SMALL
                    jsr       ll_read
                    puls      b,x,pc



;;; Dump 128 byte to screen
;;;   takes: X = ptr to data
;;;   modifies: nothing
dump
                    pshs      d,x
                    jsr       putCR
                    lda       #8
                    pshs      a                   ; put row counter
b@                  lda       #8                  ; column counter
                    pshs      x
a@                  ldb       ,x+
                    jsr       putb
                    jsr       putSP
                    deca
                    bne       a@
                    puls      x
                    clr       8,x
                    jsr       putscr
                    dec       ,s
                    bne       b@
                    leas      1,s
                    puls      d,x,pc

;;; Print a Space
putSP
                    pshs      b
                    ldb       #SP
                    jsr       putc
                    puls      b,pc


;;; Print a CR
putCR
                    pshs      d
                    ldb       #$3b
                    stb       $ffa0
                    ldd       SCRPTR
                    addd      #32-8
                    andb      #~$1f
                    addd      #8
                    std       SCRPTR
                    clr       $ffa0
                    puls      d,pc


;;; Print a Z string
;;;   takes: X = ptr to string
;;;   modifies: nothing
puts
                    pshs      b,x
a@                  ldb       ,x+
                    beq       done@
                    jsr       putc
                    bra       a@
done@               puls      b,x,pc

;;; Print a 3 byte value ( in hex )
;;;   takes: X = ptr to value
;;;   modifies: nothing
put3
                    pshs      d,x
                    ldd       ,x++
                    jsr       putw
                    ldb       ,x
                    jsr       putb
                    puls      d,x,pc


;;; Print a word ( in hex)
;;;   takes: D = word
;;;   modifies: nothing
putw
                    pshs      b
                    tfr       a,b
                    bsr       putb
                    puls      b
                    bsr       putb
                    rts

;;; Print a byte (in hex)
;;;   takes: B = byte
;;;   modifies: nothing
putb
                    pshs      d
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    bsr       putn
                    ldb       1,s
                    bsr       putn
                    puls      d,pc

;;; Print a Char
;;;   takes: B = charactor
;;;   modifies: nothing
putc
                    pshs      d,x
                    lda       #$3b                ; put 3b in bank 0
                    sta       $ffa0
                    ldx       SCRPTR
                    stb       ,x+
                    stx       SCRPTR
                    clr       $ffa0               ; put 0 in bank 0
                    puls      d,x,pc


;;; Print a nibble
;;;   takes: B = nibble
;;;   modifies: nothing
putn
                    pshs      b
                    andb      #$f
                    addb      #$30
                    cmpb      #$39
                    bls       a@
                    addb      #7
a@                  jsr       putc
                    puls      b,pc


;;; Print a string followed by a CR
;;;   takes: X = zero termed string
;;;   returns: nothing
;;;   modifies: nothing
putscr
                    jsr       puts
                    jsr       putCR
                    rts



                    include   "sd.asm"

ende                equ       *


                    end       prestartasm"
