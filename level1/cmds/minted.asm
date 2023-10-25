*
* MinTED Minimalist Text Editor for OS-9 6809
*
*
* This is freeware and open source. Use it as you wish.
* 2013 Luis Antoniosi
*

                    nam       MinTED
                    ttl       MinTED for OS-9 6809
                    ;         2013                Luis Antoniosi

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $03
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    org       0

undo_item           struct
previous            rmb       2
next                rmb       2
scrline             rmb       2
cx                  rmb       1
cy                  rmb       1
key                 rmb       1
topstr              rmb       2
                    endstruct

                    org       0

sgn_code            rmb       1
cx                  rmb       1
cy                  rmb       1
tcx                 rmb       1
key                 rmb       1
edited              rmb       1

width               rmb       2
height              rmb       2
cntlin              rmb       2
curstr              rmb       2                   ; temp cur str
curptr              rmb       2                   ; temp cur ptr
topstr              rmb       2                   ; top screen current string
topptr              rmb       2                   ; top screen string pointer
topscr              rmb       2                   ;
curlen              rmb       2                   ; current string len
curmsiz             rmb       2                   ; current malloc size
gotocmd             rmb       3                   ; cursor locate cmd
malsize             rmb       2
remsize             rmb       2
delstr              rmb       2
renderall           rmb       1
currows             rmb       1

strlen              rmb       2
prevchar            rmb       1
curchar             rmb       1
strptr              rmb       2                   ; first string pointer
scrline             rmb       2                   ; current top screen line
curline             rmb       2                   ; current cursor screen line
scrlines            rmb       2                   ; total screen lines
undoptr             rmb       2                   ; undo first item
undoflag            rmb       1                   ;
termcap             rmb       1                   ; terminal capabilities
himem               rmb       2                   ; application high memory
bufsize             rmb       2                   ; buffer size
scrbuf              rmb       2                   ; screen buffer addr
scrsize             rmb       2                   ; screen buffer size
membuf              rmb       2                   ; memory buffer addr
memsize             rmb       2                   ; memory buffer size
memstart            rmb       2                   ; memory start chunck


oldecho             rmb       1                   ; original term echo3
oldalf              rmb       1                   ; original term auto line-feed
filepath            rmb       1                   ; file path number
argc                rmb       2                   ; number of args
optbuf              rmb       32                  ; SS/GS OPT buffer
filename            rmb       256                 ; filename
readbuf             rmb       256                 ; read buffer
args                rmb       256                 ; 128 max args
VAR_SIZE            equ       .                   ; work variables size
STACK_SIZE          equ       256                 ; reserved stack size

                    ifeq      Level-1
buffer              rmb       (20*1024-VAR_SIZE)
                    else
buffer              rmb       (54*1024-VAR_SIZE)
                    endc


size                equ       .

stdin               equ       0
stdout              equ       1
stderr              equ       2

K$Shift             equ       $10
K$Up                equ       $0c
K$Down              equ       $0a
K$Left              equ       $08
K$Right             equ       $09

K$ShiftUp           equ       $1c
K$ShiftDown         equ       $1a
K$ShiftLeft         equ       $18
K$ShiftRight        equ       $19

K$CtrlUp            equ       $13
K$CtrlDown          equ       $12
K$CtrlLeft          equ       $10
K$CtrlRight         equ       $11

K$CtrlK             equ       $0b
K$CtrlD             equ       $04
K$CtrlW             equ       $17
K$CtrlR             equ       $12
K$CtrlS             equ       $13
K$CtrlO             equ       $0f
K$CtrlG             equ       $07
K$CtrlU             equ       $15
VDG_CAP             equ       $00                 ; vdg defaul terminal
WIN_CAP             equ       $01                 ; window capabilities (Level 2)


name                fcs       /MinTED/
                    fcb       edition

errPNNF             fcn       "Path               Name not found"
errMF               fcn       "Memory             full"
errRF               fcn       "Error              reading file"
errWF               fcn       "Error              writing file"
errBreak            fcn       "                   - press break"
msgConfirm          fcn       "Exit               without saving (y/n)?"
msgSave             fcn       "Save               file (y/n)?"
msgRename           fcn       "Rename/Save        as: "
msgSaving           fcn       "Saving             "
msgLineNo           fcn       "Go                 to line: "

msgHelp             fcc       "Minted: Minimalist Text Editor"
                    fcb       $0a,$0d
                    fcb       $0a,$0d
                    fcc       "Hot keys:"
                    fcb       $0a,$0d
                    fcb       $0a,$0d
                    fcc       "Ctrl+S      = Save file"
                    fcb       $0a,$0d
                    fcc       "Ctrl+R      = Rename file"
                    fcb       $0a,$0d
                    fcc       "Ctrl+K      = Delete line"
                    fcb       $0a,$0d
                    fcc       "Ctrl+D      = Duplicate line"
                    fcb       $0a,$0d
                    fcc       "Ctrl+O      = Online help"
                    fcb       $0a,$0d
                    fcc       "Ctrl+E      = Exit"
                    fcb       $0a,$0d
                    fcc       "Ctrl+G      = Go to line"
                    fcb       $0a,$0d
                    fcc       "Ctrl+U      = Undo"
                    fcb       $0a,$0d
                    fcc       "Cursor Keys = Move cursor"
                    fcb       $0a,$0d
                    fcc       "Shift+Left  = Delete left"
                    fcb       $0a,$0d
                    fcc       "Shift+Right = Delete right"
                    fcb       $0a,$0d
                    fcc       "Shift+Up    = Page up"
                    fcb       $0a,$0d
                    fcc       "Shift+Down  = Page down"
                    fcb       $0a,$0d
                    fcc       "Ctrl+Left   = Go to line begin"
                    fcb       $0a,$0d
                    fcn       "Ctrl+Right         = Go to line end"

brkpnt              rts

start               lbsr      _getargs
                    lbsr      _init

                    lbsr      _open
                    tst       <filepath
                    beq       @skip
                    lbsr      _read
                    lbsr      _close
@skip               lbsr      _cntlines
                    lbsr      _renderall
                    lbsr      _navigate
                    lbsr      _cls
                    lbsr      _curon
@end                lbra      _exit


_getargs            clr       argc,u
                    clr       argc+1,u
                    leay      args,u
@pre                tstb                          ; check arg string
                    beq       @noargs
                    decb
                    lda       ,x+
                    cmpa      #13                 ; linefeed ?
                    beq       @endargs
                    cmpa      #32                 ; space delimiter ?
                    beq       @pre
                    leax      -1,x
                    stx       ,y++
                    leax      1,x
                    inc       argc+1,u            ; inc arg count
@arg                tstb
                    beq       @endargs            ; has ended ?
                    decb
                    lda       ,x+
                    cmpa      #13                 ; linefeed ?
                    beq       @endargs
                    cmpa      #32                 ; space delimiter ?
                    bne       @arg
@endline            leax      -1,x
                    clr       ,x+                 ; set null termination
                    bra       @pre
@endargs            clr       -1,x
@noargs             rts

_icept              stb       sgn_code,u
                    rti

_init               clr       sgn_code,u
                    leax      _icept,pcr
                    os9       F$Icpt
                    lbcs      _abort

                    lda       #stdin
                    ldb       #SS.Opt
                    leax      optbuf,u
                    os9       I$GetStt

                    lda       (PD.EKO-PD.OPT),x
                    sta       oldecho,u
                    clr       (PD.EKO-PD.OPT),x

                    lda       (PD.ALF-PD.OPT),x
                    sta       oldalf,u
                    clr       (PD.ALF-PD.OPT),x

                    lda       #stdin
                    ldb       #SS.Opt
                    leax      optbuf,u
                    os9       I$SetStt

                    lda       #1
                    ldb       #SS.ScSiz
                    os9       I$GetStt            ; get screen dimensions
                    lbcs      _abort
                    stx       width,u
                    sty       height,u
                    lda       width+1,u
                    ldb       height+1,u
                    mul
                    std       scrsize,u           ; compute screen size
                    leax      buffer,u
                    stx       scrbuf,u
                    leax      d,x
                    stx       membuf,u            ; compute memory buffer
                    dec       height+1,u          ;

                    ldd       #0
                    os9       F$Mem               ; get memory boundaries
                    lbcs      _abort
                    leay      -STACK_SIZE,y
                    sty       himem,u
                    subd      #VAR_SIZE
                    subd      #STACK_SIZE
                    subd      scrsize,u
                    std       bufsize,u           ; compute buffer size

                    lbsr      _meminit            ; init memory manager
                    lbsr      _strinit

                    lda       #VDG_CAP
                    sta       termcap,u
                    lda       #1
                    ldb       #SS.ScTyp
                    os9       I$GetStt            ; get screen dimensions
                    lbcs      @nonwin
                    lda       #WIN_CAP
                    sta       termcap,u
@nonwin             rts

_deinit             pshs      a,b,x,y,cc
                    leax      optbuf,u
                    lda       oldecho,u
                    sta       (PD.EKO-PD.OPT),x
                    lda       oldalf,u
                    sta       (PD.ALF-PD.OPT),x
                    lda       #stdin
                    ldb       #SS.Opt
                    os9       I$SetStt
                    lbsr      _curon
                    puls      a,b,x,y,cc,pc


curoff              fcb       $05,$20
curon               fcb       $05,$21
clrlin              fcb       $0b
cls                 fcb       $0c
home                fcb       $01
insline             fcb       $1f,$30
delline             fcb       $1f,$31


_clrlin             pshs      a,b,x,y
                    lda       #stdout
                    leax      clrlin,pcr
                    ldy       #1
                    os9       I$Write             ; turn off cursor
                    lbcs      _abort
                    puls      a,b,x,y,pc

_curon              pshs      a,b,x,y
                    lda       #stdout
                    leax      curon,pcr
                    ldy       #2
                    os9       I$Write             ; turn off cursor
                    lbcs      _abort
                    puls      a,b,x,y,pc

_curoff             pshs      a,b,x,y
                    lda       #stdout
                    leax      curoff,pcr
                    ldy       #2
                    os9       I$Write             ; turn off cursor
                    lbcs      _abort
                    puls      a,b,x,y,pc

_cls                pshs      a,b,x,y
                    lda       #stdout
                    leax      cls,pcr
                    ldy       #1
                    os9       I$Write             ; turn off cursor
                    lbcs      _abort
                    puls      a,b,x,y,pc

_home               pshs      a,b,x,y
                    lda       #stdout
                    leax      home,pcr
                    ldy       #1
                    os9       I$Write             ; turn off cursor
                    lbcs      _abort
                    puls      a,b,x,y,pc


_insline            tst       termcap
                    bne       @l2
                    clr       <renderall
                    com       <renderall
                    rts
@l2                 pshs      a,b,x,y
                    lda       #stdout
                    leax      insline,pcr
                    ldy       #2
                    os9       I$Write             ; turn off cursor
                    lbcs      _abort
                    puls      a,b,x,y,pc


_delline            tst       termcap
                    bne       @l2
                    clr       <renderall
                    com       <renderall
                    rts
@l2                 pshs      a,b,x,y
                    lda       #stdout
                    leax      delline,pcr
                    ldy       #2
                    os9       I$Write             ; turn off cursor
                    lbcs      _abort
                    puls      a,b,x,y,pc


_exit               lbsr      _deinit
                    ldd       #0
                    os9       F$Exit


_abort              lbsr      _deinit
                    clra
                    os9       F$Exit


_error              leax      errPNNF,pcr
                    cmpb      #E$PNNF
                    beq       @print
                    leax      errMF,pcr
                    cmpb      #E$MemFul
                    beq       @print
                    leax      errRF,pcr
                    cmpb      #E$Read
                    beq       @print
                    leax      errWF,pcr
                    cmpb      #E$Write
                    beq       @print
                    lbra      _abort
@print              lbsr      _cls
                    clra
                    ldb       <height+1
                    lbsr      _gotoxy
                    lbsr      _strlen
                    tfr       d,y
                    lda       #stdout
                    os9       I$Write
                    leax      errBreak,pcr
                    lbsr      _strlen
                    tfr       d,y
                    lda       #stdout
                    os9       I$Write
                    clr       <sgn_code
@loop               ldb       <sgn_code
                    cmpb      #S$Abort
                    bne       @loop
                    clr       <sgn_code
                    lbsr      _renderall
                    rts




_help               lbsr      _curoff
                    lbsr      _cls
                    leax      msgHelp,pcr
                    lbsr      _strlen
                    tfr       d,y
                    lda       #stdout
                    os9       I$Write
                    clr       <sgn_code
@loop               lda       #stdin
                    ldy       #1
                    leax      key,u
                    os9       I$Read
                    ldb       <sgn_code
                    cmpb      #S$Abort
                    bne       @loop
                    clr       <sgn_code
                    lbsr      _renderall
                    rts


_meminit            ldx       <membuf
                    stx       <memstart
                    clr       ,x+
                    clr       ,x
                    rts

; x address
; d new size
; return x: new block address
_mrealloc           pshs      a,b,y
                    leax      -2,x                ; get memory header
                    addd      #2                  ; add header size
                    std       <malsize            ; store new size
                    ldd       ,x                  ; get current size
                    anda      #~$80
                    cmpd      <malsize            ; compare new size
                    lbeq      @end                ; return if the same
                    bcc       @split              ; new size smaller, then split
                    leay      d,x
                    ldy       ,y
                    cmpy      #0
                    beq       @endchain           ; end of chain ?
                    tfr       x,y
                    ldx       <malsize
                    leax      -2,x                ; adjust header size
                    lbsr      _malloc             ; otherwise make new allocation
                    bcs       @fail
                    subd      #2
                    pshs      u,x,y
                    leau      2,y                 ; old chunk data
                    tfr       d,y
@loop               lda       ,u+
                    sta       ,x+
                    leay      -1,y
                    bne       @loop               ; transfer data to new chunk
                    puls      u,x,y
                    exg       x,y
                    leax      2,x
                    lbsr      _mfree
                    exg       x,y
                    clra
                    lbra      @ret                ; return new address
@split              ldd       ,x
                    anda      #~$80
                    leay      d,x                 ; get next chunk
                    ldd       ,y
*			cmpd	#0				; is the end of the chain ?
                    beq       @endchain
                    ldd       ,x
                    anda      #~$80
                    subd      <malsize
                    cmpd      #8                  ; worth spliting it ?
                    bmi       @end
                    std       <remsize
                    ldd       <malsize
                    leay      d,x
                    ora       #$80
                    std       ,x                  ; set new size
                    ldd       <remsize            ; restore remaining size
                    std       ,y                  ; set new chunk
                    clra                          ; clear carry
                    bra       @end
@endchain           ldd       <malsize
                    leay      d,x
                    leay      2,y
                    cmpy      <himem
                    bcc       @outmem
                    leay      -2,y
                    ora       #$80
                    std       ,x
                    clr       ,y+
                    clr       ,y
                    bra       @end
@fail               tfr       y,x
@outmem             comb
                    leax      2,x
                    puls      a,b,y,pc
@end                clrb
                    leax      2,x
@ret                puls      a,b,y,pc


_malloc             pshs      a,b,y
                    tfr       x,y
@try                lbsr      __malloc
                    bcs       @memful
                    puls      a,b,y,pc
@memful             ldd       <undoptr
                    beq       @error
                    lbsr      _undo_del
                    tfr       y,x
                    bra       @try
@error              comb
                    puls      a,b,y,pc

; x block size
; return x: block address
__malloc            pshs      a,b,y
                    leax      2,x
                    stx       <malsize
                    ldx       <memstart
                    ldd       ,x
@checkused          bita      #$80
                    beq       @computesiz
@nextchunk          ldd       ,x
                    anda      #~$80
                    leax      d,x
                    ldd       ,x
                    bra       @checkused
@computesiz         cmpd      #0
                    beq       @endchain
                    subd      <malsize
                    bmi       @nextchunk
                    cmpd      #8                  ; space for a small chunk ?
                    bpl       @split
                    ldd       ,x
                    ora       #$80
                    sta       ,x
                    bra       @found
@split              std       <remsize            ; remain size
                    ldd       <malsize
                    leay      d,x
                    ora       #$80
                    std       ,x
                    ldd       <remsize
                    std       ,y
                    bra       @found
@endchain           ldd       <malsize
                    leay      d,x
                    leay      2,y
                    cmpy      <himem
                    bcc       @outmem
                    leay      -2,y
                    clr       ,y+
                    clr       ,y
                    ora       #$80
                    std       ,x
                    bra       @found
@outmem             ldx       #0
                    comb
                    bra       @end
@found              leax      2,x
                    clra
@end                puls      a,b,y,pc

; mfree
; x address
_mfree              pshs      a,b,x,y
                    leax      -2,x
                    ldd       ,x
                    anda      #~$80
                    std       ,x
                    leay      d,x
                    ldd       ,y
                    bita      #$80
                    bne       @end
                    addd      ,x
                    std       ,x                  ; coalesce ajacent chunks
@end                puls      a,b,x,y,pc

; memcpy
; x tgt
; y src
; d size
_memcpy             pshs      a,b,x,y
@loop               pshs      a
                    lda       ,y+
                    sta       ,x+
                    puls      a
                    subd      #1
                    bne       @loop
                    puls      a,b,x,y,pc


; Strings manager
; Each string lies on a malloc chunk allocation and has a 4 byte header for:
;
; Prev str addr | Next str addr
;
; The maximum string size is inferred from the malloc struct.
; The current string size is the null character on it.



_strinit            ldd       #0
                    std       <strptr             ; clears struct
                    rts



; append string to the end of the chain
; x string size
; y previous string ptr
; return x : str ptr
_strapp             pshs      a,b,y
                    leax      5,x
                    cmpy      #0
                    beq       @first
@next               ldd       2,y
                    cmpd      #0
                    beq       @last
                    tfr       d,y
                    bra       @next
@last               lbsr      _malloc
                    bcs       @fail
                    stx       2,y
                    sty       ,x
                    clr       2,x
                    clr       3,x
                    clr       4,x
                    clr       5,x
                    puls      a,b,y,pc
@first              lbsr      _malloc
                    bcs       @fail
                    ldd       #0
                    std       ,x
                    std       2,x
                    std       4,x
                    stx       <strptr
                    puls      a,b,y,pc
@fail               comb
                    ldx       #0
                    puls      a,b,y,pc

; dettach the string
; x string ptr
_strdet             pshs      a,b,y
                    ldy       ,x                  ; previous
                    ldd       2,x                 ; next
                    cmpy      #0
                    beq       @first
                    std       2,y                 ; previous->next = next
                    exg       d,y
                    cmpy      #0
                    beq       @free
                    std       ,y                  ; next->previous = previous
@free               puls      a,b,y,pc
@first              std       <strptr             ; strptr = next
                    exg       d,y
                    cmpy      #0
                    beq       @free
                    std       ,y                  ; next->previous = 0
                    bra       @free

; delete the string
; x string ptr
_strdel             pshs      a,b,y
                    ldy       ,x                  ; previous
                    ldd       2,x                 ; next
                    cmpy      #0
                    beq       @first
                    std       2,y                 ; previous->next = next
                    exg       d,y
                    cmpy      #0
                    beq       @free
                    std       ,y                  ; next->previous = previous
@free               lbsr      _mfree
                    puls      a,b,y,pc
@first              std       <strptr             ; strptr = next
                    exg       d,y
                    cmpy      #0
                    beq       @free
                    std       ,y                  ; next->previous = 0
                    bra       @free

; resize string
; x str ptr
; d new size
; return x new str
_strres             pshs      a,b,y
                    addd      #5
                    lbsr      _mrealloc
                    bcs       @error
                    ldy       ,x                  ; previous
                    beq       @first
                    stx       2,y                 ; previous->next = this
@next               ldy       2,x                 ; next
                    beq       @last
                    stx       ,y                  ; next->previous = this
@last               puls      a,b,y,pc
@first              stx       <strptr
                    bra       @next
@error              puls      a,b,y,pc




; strlen
; x str first char
; return d string len
_strlen             pshs      x
                    ldd       #0
@isnull             tst       ,x+
                    beq       @null
                    addd      #1
                    bra       @isnull
@null               puls      x,pc





; memcpy
; x tgt
; y src
_strcpy             pshs      a,x,y
@loop               lda       ,y+
                    sta       ,x+
                    bne       @loop
                    puls      a,x,y,pc




_strrows            pshs      x,y
                    ldy       #1
@wrap               ldb       <width+1
@isnull             lda       ,x+
                    beq       @null
                    cmpa      #$0d
                    beq       @null
                    decb
                    bne       @isnull
                    leay      1,y
                    bra       @wrap
@null               tfr       y,d
                    puls      x,y,pc

; insert string of x size
; y previous string ptr
; return new x pointer
_strins             pshs      a,b,y
                    leax      5,x
                    lbsr      _malloc
                    lbcs      @error
                    ldd       #0
                    std       ,x
                    std       2,x
                    std       4,x
                    sty       ,x
                    ldd       2,y
                    stx       2,y
                    std       2,x
                    beq       @last
                    tfr       d,y
                    stx       ,y
@last               lda       #1
                    sta       4,x
@error              puls      y,a,b,pc

_reset              pshs      a,b,x,y
                    ldd       #0
                    lbsr      _meminit            ; init memory manager
                    lbsr      _strinit
                    std       <curline
                    std       <scrlines
                    std       <undoptr
                    std       <cx
                    clr       <tcx
                    clr       <renderall
                    clr       <undoflag
                    ldd       #1
                    std       <scrline
                    clr       filename,u
                    clr       <filepath
                    clr       <edited
                    puls      a,b,x,y,pc


_open               pshs      a,b,x,y
                    lbsr      _reset
                    ldd       argc,u
                    cmpd      #0
                    beq       @empty
                    leax      filename,u
                    ldy       args,u              ; file name
                    lbsr      _strcpy
                    lda       #READ.
                    os9       I$Open
                    bcs       @error
                    sta       <filepath
                    clra
                    puls      a,b,x,y,pc
@error              lbsr      _error
@empty              comb
                    puls      a,b,x,y,pc



_close              pshs      a,b,x,y
                    lda       <filepath
                    beq       @end
                    os9       I$Close
                    clr       <filepath
@end                puls      a,b,x,y,pc



@backspace          pshs      a,b
                    ldd       <strlen
                    beq       @end
                    subd      #1
                    std       <strlen
                    ldx       <curstr
                    leax      5,x
                    leax      d,x
                    clr       ,x
@end                puls      a,b,pc
_appchar
                    cmpa      #$09
                    beq       @tab
                    cmpa      #$08
                    beq       @backspace
                    cmpa      #$0d
                    beq       __appchar
                    cmpa      #$20
                    bcc       __appchar
                    rts
@tab
_tab                set       0
_stack              set       1
                    pshs      a,b
                    leas      -_stack,s
                    ldb       <strlen+1
                    decb
                    andb      #$03
                    stb       _tab,s
                    ldb       #4
                    subb      _tab,s
                    lda       #32
@loop               bsr       __appchar
                    decb
                    bne       @loop
@skip               leas      _stack,s
                    puls      a,b,pc
; append character to current string
; x string
; a char
__appchar           pshs      a,b,x
                    ldx       <curstr
                    ldd       -2,x
                    anda      #~$80
                    subd      #7
                    cmpd      <strlen
                    bgt       @append
                    addd      #32
                    lbsr      _strres
                    bcs       @error
                    stx       <curstr
                    std       <curlen
@append             leax      5,x
                    ldd       <strlen
                    leax      d,x
                    addd      #1
                    std       <strlen
                    lda       ,s
                    sta       <prevchar
                    clrb
                    std       -1,x
@error              puls      a,b,x,pc




_read               pshs      a,b,x,y
                    ldy       #0
                    sty       <curstr
                    clr       <prevchar
@read               lda       <filepath,u
                    ldb       #SS.EOF
                    os9       I$GetStt
                    lbcs      @eof
                    ldy       #256
                    leax      readbuf,u
                    os9       I$Read
                    lbcs      @error
                    cmpy      #0
                    lbeq      @eof
                    tfr       y,d
                    leay      readbuf,u           ; y = readbuf
@nextlin            ldx       #256
                    stx       <curlen
                    pshs      y
                    ldy       <curstr
                    lbsr      _strapp             ; append new line
                    puls      y
                    lbcs      @outmem
                    stx       <curstr             ; save current string
                    leax      -2,x
                    stx       <memstart
                    ldx       #1
                    stx       <strlen
@loop               lda       ,y+
                    cmpa      #$0a                ; ignore NL
                    beq       @checkcr
                    cmpa      #$0d
                    beq       @newline
@continue           lbsr      _appchar
@skip               decb
                    bne       @loop
                    lda       <filepath
                    ldb       #SS.EOF
                    os9       I$GetStt
                    bcs       @eof
                    ldy       #256
                    leax      readbuf,u
                    os9       I$Read
                    bcs       @error
                    cmpy      #0
                    lbeq      @eof
                    tfr       y,d
                    leay      readbuf,u           ; y = readbuf
                    bra       @loop
@backspace
@newline            lbsr      _appchar
                    sta       <prevchar
                    pshs      b
                    ldx       <curstr
                    ldd       <strlen
                    lbsr      _strres             ; resize trailing string
                    puls      b
                    decb
                    bne       @nextlin
                    lbra      @read
@checkcr            sta       <curchar
                    lda       <prevchar
                    cmpa      #$0d
                    beq       @skip
                    lda       #$0d
                    bra       @newline
@eof                ldx       <curstr
                    ldd       <strlen
                    addd      #1
                    lbsr      _strres             ; resize trailing string
                    ldx       <membuf
                    stx       <memstart
                    puls      a,b,x,y,pc
@outmem             ldb       #E$MemFul
@error              lbsr      _error
                    puls      a,b,x,y,pc




_cntlines           pshs      a,b,x,y
                    ldx       #0
                    stx       <scrlines
                    ldy       <strptr
                    cmpy      #0
                    beq       @last
@next               pshs      y
                    leay      5,y
                    clr       <cntlin
@wrap               ldx       <scrlines
                    leax      1,x
                    stx       <scrlines
                    inc       <cntlin
                    ldx       width,u
@count              ldb       ,y+
                    beq       @endline
                    cmpb      #$0d
                    beq       @endline
                    leax      -1,x
                    beq       @wrap
                    bra       @count
@endline            puls      y
                    lda       <cntlin
                    sta       4,y
                    ldd       2,y
                    cmpd      #0
                    beq       @last
                    tfr       d,y
                    bra       @next
@last               ldd       <scrlines
                    bne       @end
                    ldy       #0                  ; insert empty line
                    ldx       #16
                    lbsr      _strapp
                    lda       #1
                    sta       4,x
@end                puls      a,b,x,y,pc




_rename             pshs      a,b,x,y
@repeat             clra
                    ldb       <height+1
                    decb
                    lbsr      _gotoxy
                    lbsr      _clrlin
                    ldb       <height+1
                    lbsr      _gotoxy
                    lbsr      _clrlin
                    leax      msgRename,pcr
                    lbsr      _strlen
                    tfr       d,y
                    lda       #stdout
                    os9       I$Write
                    leax      optbuf,u
                    clr       (PD.EKO-PD.OPT),x
                    com       (PD.EKO-PD.OPT),x
                    lda       #stdin
                    ldb       #SS.Opt
                    os9       I$SetStt
                    clr       <sgn_code
                    leax      readbuf,u
                    ldy       #128
                    lda       #stdin
                    os9       I$ReadLn
                    ldb       <sgn_code
                    cmpb      #S$Abort
                    beq       @abort
                    cmpy      #0
                    beq       @repeat
                    cmpy      #1
                    beq       @repeat
                    tfr       y,d
                    leax      filename,u
                    leay      readbuf,u
                    clr       d,y
                    lbsr      _memcpy
@end                leax      optbuf,u
                    clr       (PD.EKO-PD.OPT),x
                    lda       #stdin
                    ldb       #SS.Opt
                    os9       I$SetStt
                    lbsr      _renderall
                    clr       <sgn_code
                    puls      a,b,x,y,pc
@abort              leax      optbuf,u
                    clr       (PD.EKO-PD.OPT),x
                    lda       #stdin
                    ldb       #SS.Opt
                    os9       I$SetStt
                    lbsr      _renderall
                    clr       <sgn_code
                    comb
                    puls      a,b,x,y,pc



_confirm            pshs      a,b,x,y
                    clra
                    ldb       <height+1
                    decb
                    lbsr      _gotoxy
                    lbsr      _clrlin
                    ldb       <height+1
                    lbsr      _gotoxy
                    lbsr      _clrlin
                    lbsr      _strlen
                    tfr       d,y
                    lda       #stdout
                    os9       I$Write
                    lda       #stdin
                    ldy       #1
                    leax      key,u
                    os9       I$Read
                    ldb       <sgn_code
                    cmpb      #S$Abort
                    beq       @cancel
                    lda       <key
                    cmpa      #'Y
                    beq       @exit
                    cmpa      #'y
                    beq       @exit
@cancel             lbsr      _renderall
                    clr       <sgn_code
                    puls      a,b,x,y,pc
@exit               clr       <sgn_code
                    comb
                    puls      a,b,x,y,pc



_save               pshs      a,b,x,y
                    leax      msgSave,pcr
                    lbsr      _confirm
                    lbcc      @end
                    tst       filename,u
                    bne       @renamed
                    lbsr      _rename
                    lbcs      @end
@renamed
                    clra
                    ldb       <height+1
                    decb
                    lbsr      _gotoxy
                    lbsr      _clrlin
                    ldb       <height+1
                    lbsr      _gotoxy
                    lbsr      _clrlin
                    leax      msgSaving,pcr
                    lbsr      _strlen
                    tfr       d,y
                    lda       #stdout
                    os9       I$Write
                    leax      filename,u
                    os9       I$Delete            ; deletes previous file
                    lda       #WRITE.
                    ldb       #%00011011
                    leax      filename,u
                    os9       I$Create
                    bcs       @error
                    sta       <filepath
                    ldy       <strptr
                    beq       @close
@next               pshs      y
                    leax      5,y
                    lbsr      _strlen
                    tfr       d,y
                    lda       <filepath
                    os9       I$Write
                    lbcs      @error
                    puls      y
                    ldy       2,y
                    bne       @next
@close              lbsr      _close
                    clr       <edited
@end                lbsr      _renderall
                    puls      a,b,x,y,pc
@error              pshs      b
                    lbsr      _close
                    puls      b
                    lbsr      _error
                    puls      a,b,x,y,pc



_gotolin            pshs      a,b,x,y
@repeat             clra
                    ldb       <height+1
                    decb
                    lbsr      _gotoxy
                    lbsr      _clrlin
                    ldb       <height+1
                    lbsr      _gotoxy
                    lbsr      _clrlin
                    leax      msgLineNo,pcr
                    lbsr      _strlen
                    tfr       d,y
                    lda       #stdout
                    os9       I$Write
                    leax      optbuf,u
                    clr       (PD.EKO-PD.OPT),x
                    com       (PD.EKO-PD.OPT),x
                    lda       #stdin
                    ldb       #SS.Opt
                    os9       I$SetStt
                    clr       <sgn_code
                    leax      readbuf,u
                    ldy       #128
                    lda       #stdin
                    os9       I$ReadLn
                    ldb       <sgn_code
                    cmpb      #S$Abort
                    beq       @abort
                    cmpy      #0                  ; no input ?
                    beq       @repeat
                    cmpy      #1
                    beq       @repeat             ; only enter ?
                    ldd       #0
                    std       <curline
                    leax      readbuf,u
                    leay      -1,y
@loop
                    lda       <curline
                    ldb       #10
                    mul
                    stb       <curline
                    lda       <curline+1
                    ldb       #10
                    mul
                    clr       <curline+1
                    addd      <curline
                    std       <curline
                    clra
                    ldb       ,x+
                    subb      #'0
                    cmpb      #10
                    lbcc      @repeat
                    addd      <curline
                    std       <curline
                    leay      -1,y
                    bne       @loop
                    ldd       <curline
                    beq       @abort
                    cmpd      <scrlines
                    beq       @go
                    bcc       @abort
@go                 std       <scrline
                    clr       <cx
                    clr       <cy
@end                leax      optbuf,u
                    clr       (PD.EKO-PD.OPT),x
                    lda       #stdin
                    ldb       #SS.Opt
                    os9       I$SetStt
                    lbsr      _renderall
                    clr       <sgn_code
                    puls      a,b,x,y,pc
@abort              leax      optbuf,u
                    clr       (PD.EKO-PD.OPT),x
                    lda       #stdin
                    ldb       #SS.Opt
                    os9       I$SetStt
                    lbsr      _renderall
                    clr       <sgn_code
                    comb
                    puls      a,b,x,y,pc

; a start row
; b end row
_scrdraw            pshs      a,b,x,y
_col                set       0
_row                set       2
_curstr             set       4
_scrstart           set       6
_stack              set       8
                    leas      -_stack,s
                    pshs      a,b
                    ldx       <scrbuf
                    ldb       <width+1
                    mul
                    leax      d,x
                    ldb       1,s
                    subb      ,s
                    lda       <width+1
                    mul
                    tfr       d,y
                    lda       #32
@cls                sta       ,x+                 ; clear buffer
                    leay      -1,y
                    bne       @cls
                    puls      d
                    tfr       d,y
                    ldb       <width+1
                    mul
                    ldx       <scrbuf
                    leax      d,x
                    stx       _scrstart,s
                    tfr       y,d
                    ldx       <scrline
                    leax      a,x
                    lbsr      _gotoline           ; find top screen ptrs
                    sta       _row,s
                    subb      _row,s
                    stb       _row,s
                    ldb       <width+1
                    stb       _col,s
                    ldx       <topstr
                    stx       _curstr,s
                    ldx       <topptr
                    ldy       _scrstart,s
@cont               lda       ,x+
                    beq       @nextstr
                    cmpa      #$0d
                    beq       @nextstr
                    sta       ,y+
                    dec       _col,s
                    beq       @nextlin
                    bra       @cont
@nextlin            dec       _row,s
                    beq       @end
                    ldb       <width+1
                    stb       _col,s
                    lda       <height+1
                    inca
                    suba      _row,s
                    mul
                    ldy       <scrbuf
                    leay      d,y
                    bra       @cont
@nextstr            ldx       _curstr,s
                    ldx       2,x
                    beq       @end
                    stx       _curstr,s
                    leax      5,x
                    bra       @nextlin
@end                leas      _stack,s
                    puls      a,b,x,y,pc


; render screen
; a start row
; b end row
_render             pshs      a,b,x,y
                    ldx       <scrbuf
                    ldb       <width+1
                    mul
                    leax      d,x
                    lda       1,s
                    suba      ,s
                    ldb       <width+1
                    mul
                    tfr       d,y
                    lda       1,s
                    cmpa      <height+1
                    bcs       @cont
                    leay      -1,y
@cont               lda       #stdout
                    os9       I$Write
                    lbcs      _abort
                    puls      a,b,x,y,pc


_renderdown         pshs      a,b
                    tst       termcap
                    beq       @renderall
                    tst       <renderall
                    bne       @renderall
                    lbsr      _curoff
                    lbsr      _home
                    lbsr      _delline
                    ldd       <height
                    decb
                    lbsr      _gotoxy
                    tfr       b,a
                    incb
                    incb
                    lbsr      _scrdraw
                    lbsr      _render
                    puls      a,b,pc
@renderall          lbsr      _renderall
                    puls      a,b,pc

_renderall          pshs      a,b
                    clr       <renderall
                    lbsr      _curoff
                    lbsr      _home
                    ldd       <height
                    incb
                    lbsr      _scrdraw
                    ldd       <scrlines
                    cmpd      <height
                    bcs       @draw
                    ldd       <height
@draw               incb
                    lbsr      _render
                    lbsr      _clrlin
                    puls      a,b,pc

_renderup           pshs      a,b
                    tst       termcap
                    beq       @renderall
                    tst       <renderall
                    bne       @renderall
                    lbsr      _curoff
                    lbsr      _home
                    lbsr      _insline
                    ldd       #$0001
                    lbsr      _scrdraw
                    lbsr      _render
                    puls      a,b,pc
@renderall          lbsr      _renderall
                    puls      a,b,pc



; find top string ptr for the current scrline
; x scr line
_gotoline           pshs      a,b,x,y
                    stx       <cntlin
                    ldx       #0
                    ldy       <strptr
                    cmpy      #0
                    beq       @end
                    ldd       #0
@next               addb      4,y
                    adca      #0
                    cmpd      <cntlin
                    bcc       @found
                    leay      2,y
                    ldy       ,y
                    beq       @last
                    bra       @next
@found
                    subb      4,y
                    sbca      #0
                    addd      #1
                    tfr       d,x
                    ldd       <cntlin
                    stx       <cntlin
                    subd      <cntlin
                    leax      5,y
@wrap               lda       <width+1
                    mul
                    leax      d,x
                    bra       @end
@last               leax      5,y
@end                stx       <topptr
                    sty       <topstr
                    puls      a,b,x,y,pc




; goto cursor
; a = col
; b = row
_gotoxy             pshs      a,b,x,y
                    leax      gotocmd,u
                    addd      #$2020
                    std       1,x
                    lda       #$02
                    sta       ,x
                    lda       #stdout
                    ldy       #3
                    os9       I$Write
                    puls      a,b,x,y,pc


; set cursor position and text
_setpos             pshs      a,b,x,y
                    clra
                    ldb       <cy
                    addd      <scrline
                    tfr       d,x
                    lbsr      _gotoline
                    clra
                    ldb       <cx
                    cmpb      #-1
@rcheck             beq       @lcheck
                    tfr       d,y
                    ldx       <topptr
                    lbsr      _strlen
                    std       <strlen
                    leax      d,x
                    lda       -1,x
                    cmpa      #$0d
                    bne       @notenter
                    ldd       <strlen
                    subd      #1
                    std       <strlen
@notenter           ldd       <strlen
                    ldx       <topptr
                    cmpy      <strlen
                    lbcs      @wrapdown
                    cmpy      <width
                    bcc       @wrapdown
                    stb       <cx
                    puls      a,b,x,y,pc
@lcheck             clr       <cx
                    ldx       <topstr
                    leax      5,x
                    cmpx      <topptr
                    bne       @wrapup
                    clra
                    ldb       <cy
                    addd      <scrline
                    cmpd      #1
                    lbeq      @lreset
                    clra
                    subd      #1
                    tfr       d,x
                    lbsr      _gotoline
                    ldx       <topptr
                    lbsr      _strlen
                    decb
                    stb       <cx
                    stb       <tcx
                    lbsr      _up
                    puls      a,b,x,y
                    lbra      _setpos
@lreset             clr       <cx
                    clr       <tcx
                    puls      a,b,x,y,pc
@wrapup             ldb       <width+1
                    decb
                    stb       <cx
                    stb       <tcx
                    lbsr      _up
                    puls      a,b,x,y
                    lbra      _setpos
@wrapdown           cmpy      <width
                    lbcs      @end
                    clr       <cx
                    clr       <tcx
                    lbsr      _down
                    puls      a,b,x,y
                    lbra      _setpos
@end                puls      a,b,x,y,pc

_navigate           pshs      a,b,x,y
_input
@input              lbsr      _setpos
@locate             ldd       <cx
                    lbsr      _gotoxy
                    lbsr      _curon
                    lda       #stdin
                    ldy       #1
                    leax      key,u
                    os9       I$Read
                    ldb       <sgn_code
                    cmpb      #S$Abort
                    lbeq      @end
_redo               lda       <key
@up
                    cmpa      #K$Up
                    bne       @down
                    lbsr      _up
                    lbra      @input
@down
                    cmpa      #K$Down
                    bne       @pageup
                    lbsr      _down
                    lbra      @input
@pageup
                    cmpa      #K$Shift|K$Up
                    bne       @pagedown
                    lbsr      _pageup
                    lbra      @input
@pagedown
                    cmpa      #K$Shift|K$Down
                    bne       @right
                    lbsr      _pagedown
                    lbra      @input
@right
                    cmpa      #K$Right
                    bne       @left
                    lbsr      _right
                    lbra      @input
@left
                    cmpa      #K$Left
                    bne       @backspace
                    lbsr      _left
                    lbra      @input
@backspace
                    cmpa      #K$ShiftLeft
                    bne       @delete
                    lbsr      _backspace
                    lbra      @input
@delete
                    cmpa      #K$ShiftRight
                    bne       @enter
                    ldd       <cx
                    pshs      a,b
                    lbsr      _right
                    lbsr      _setpos
                    puls      a,b
                    cmpd      <cx
                    lbeq      @input
                    lbsr      _backspace
                    lbra      @input
@enter              cmpa      #$0d
                    bne       @char
                    lbsr      _splitline
                    lbra      @input
@char               cmpa      #$20
                    blo       @ctrl_r
                    lbsr      _inschar
                    lbra      @input
@ctrl_r             cmpa      #K$CtrlR
                    bne       @ctrl_s
                    lbsr      _rename
                    lbra      @input
@ctrl_s             cmpa      #K$CtrlS
                    bne       @ctrl_o
                    lbsr      _save
                    lbra      @input
@ctrl_o             cmpa      #K$CtrlO
                    bne       @ctrl_k
                    lbsr      _help
                    lbra      @input
@ctrl_k             cmpa      #K$CtrlK
                    bne       @ctrl_d
                    lbsr      _killine
                    lbra      @input
@ctrl_d             cmpa      #K$CtrlD
                    bne       @ctrl_g
                    lbsr      _dupline
                    lbra      @input
@ctrl_g             cmpa      #K$CtrlG
                    bne       @ctrl_u
                    lbsr      _gotolin
                    lbra      @input
@ctrl_u             cmpa      #K$CtrlU
                    bne       @ctrl_left
                    lbra      _undo_undo
@ctrl_left          cmpa      #K$CtrlLeft
                    bne       @ctrl_right
                    lbsr      _dohome
                    lbra      @input
@ctrl_right         cmpa      #K$CtrlRight
                    bne       @continue
                    lbsr      _doend
                    lbra      @input
@continue           lbra      @input
@end                lda       #stdin
                    ldy       #1
                    leax      key,u
                    os9       I$Read
                    tst       <edited
                    beq       @return
                    clr       <sgn_code
                    leax      msgConfirm,pcr
                    lbsr      _confirm
                    lbcc      @input
@return             puls      a,b,x,y,pc


_execute
_left               clra
                    ldb       <cx
                    decb
                    stb       <cx
                    stb       <tcx
                    lbra      @end
_right              clra
                    ldb       <cx
                    tfr       d,y
                    ldx       <topptr
                    lbsr      _strlen
                    std       <strlen
                    beq       @notenter
                    leax      d,x
                    lda       -1,x
                    cmpa      #$0d
                    bne       @notenter
                    ldd       <strlen
                    subd      #1
                    std       <strlen
@notenter           ldd       <strlen
                    ldx       <topptr
                    cmpy      <strlen
                    lbcc      _linedown
                    tfr       y,d
                    incb
                    stb       <cx
                    stb       <tcx
                    lbra      @end
_linedown           clra
                    ldb       <cy
                    incb
                    addd      <scrline
                    tfr       d,y
                    cmpy      <scrlines
                    lbhi      @end
                    clr       <cx
                    clr       <tcx
                    lbra      _down
_pagedown           ldd       <scrline
                    addd      <height
                    cmpd      <scrlines
                    lbpl      @end
                    std       <scrline
                    ldd       <scrlines
                    subd      <height
                    bcs       _top
                    addd      #1
                    cmpd      <scrline
                    bcs       _bottom
                    lbsr      _renderall
                    lbra      @end
_pageup             ldd       <scrline
                    subd      <height
                    bcs       _top
                    std       <scrline
                    lbsr      _renderall
                    lbra      @end
_top                ldd       #1
                    std       <scrline
                    lbsr      _renderall
                    lbra      @end
_down               ldb       <tcx
                    stb       <cx
                    clra
                    ldb       <cy
                    addd      <scrline
                    cmpd      <scrlines
                    lbpl      @end
                    clra
                    ldb       <cy
                    incb
                    cmpb      <height+1
                    bgt       _godown
                    stb       <cy
                    lbra      @end
_bottom             ldd       <scrlines
                    subd      <height
                    std       <scrline
                    lbsr      _renderall
                    lbra      @end
_godown             clra
                    ldb       <cy
                    addd      <scrline
                    cmpd      <scrlines
                    lbpl      @end
                    ldd       scrline,u
                    addd      #1
                    std       scrline,u
                    lbsr      _renderdown
                    lbra      @end
_up                 ldb       <tcx
                    stb       <cx
                    lda       <cy
                    deca
                    bmi       _goup
                    sta       <cy
                    ldd       <scrline
                    addd      <cy
                    lbra      @end
_goup               ldd       <scrline
                    subd      #1
                    lbeq      @end
                    std       <scrline
                    lbsr      _renderup
                    lbra      @end
_backspace          lbsr      __backspace
                    lbra      @end
@end                rts



__backspace         pshs      a,b,x,y
                    clr       <edited
                    com       <edited
                    ldx       <topptr
                    lbeq      @end
                    lbsr      _strrows
                    std       <cntlin
                    ldx       <topptr
                    ldb       <cx
                    beq       @isjoin
                    decb
                    stb       <cx
                    stb       <tcx
                    leax      b,x
@domove             lda       ,x
                    lbsr      _undo_push
@move               lda       1,x
                    sta       ,x+
                    bne       @move
                    lbra      @count
@isjoin             ldy       <topstr
                    leay      5,y
                    cmpy      <topptr
                    beq       @joinline
                    lda       <cx
                    deca
                    sta       <cx
                    sta       <tcx
                    leax      -1,x
                    bra       @domove
@joinline           ldx       <topstr
                    leax      5,x
                    lbsr      _strlen
                    std       <malsize
                    ldd       <scrline
                    addb      <cy
                    adca      #0
                    cmpd      #1
                    lbeq      @end
                    clr       <renderall
                    com       <renderall
                    tst       <cy
                    bne       @ntop
                    ldd       <scrline
                    subd      #1
                    std       <scrline
                    inc       <cy
                    lbsr      _setpos
@ntop               ldx       <topptr
                    ldy       <topstr
                    stx       <delstr
                    ldd       <scrline
                    dec       <cy
                    addb      <cy
                    adca      #0
                    tfr       d,x
                    lbsr      _gotoline
                    ldx       <topptr
                    lbsr      _strlen
                    decb
                    stb       <cx
                    stb       <tcx
                    ldx       <topstr
                    leax      5,x
                    lbsr      _strlen
                    addd      <malsize
                    addd      #2
                    ldx       <topstr
                    lbsr      _strres
                    lbcs      @error
                    stx       <curstr
                    leax      5,x
                    lbsr      _strlen
                    std       <strlen
                    leax      d,x
                    clr       -1,x                ; remove car ret
                    ldx       <delstr
                    lda       #$0d
                    lbsr      _undo_push
@jmove              lda       ,x+
                    beq       @endjoin
                    lbsr      __appchar
                    lbcs      @error
                    bra       @jmove
@endjoin            ldd       <scrline
                    addb      <cy
                    adca      #0
                    tfr       d,x
                    lbsr      _gotoline
                    ldx       <topstr
                    tfr       y,x
                    lbsr      _strdel
                    ldd       #0
                    std       <cntlin
@count              ldx       <topptr
                    lbsr      _strrows
                    cmpd      <cntlin
                    beq       @render
                    ldx       <topstr
                    leax      5,x
                    lbsr      _strrows
                    stb       -1,x
                    clra
                    ldb       <cy
                    cmpb      <height+1
                    bcc       @btm
                    incb
@btm                lbsr      _gotoxy
                    lda       <cy
                    beq       @top
                    deca
                    ldb       <height+1
                    incb
                    lbsr      __cntlines
                    lbsr      _renderdel
                    bra       @end
@render             lda       <cy
                    beq       @top
                    deca
                    inc       <cntlin+1
@top                tfr       a,b
                    addb      <cntlin+1
                    lbsr      __cntlines
                    lbsr      _renderdel
@end                puls      a,b,x,y,pc
@error              ldb       #E$MemFul
                    lbsr      _error
                    lbsr      __cntlines
                    puls      a,b,x,y,pc



_renderdel          pshs      a,b
                    tst       <renderall
                    bne       @renderall
                    cmpa      <height+1
                    blo       @aLower
                    lda       <height+1
                    deca
@aLower             cmpb      <height+1
                    bls       @bLower
                    ldb       <height+1
                    incb
@bLower
                    lbsr      _curoff
                    pshs      a,b
                    tfr       a,b
                    clra
                    lbsr      _gotoxy
                    ldd       <height
                    incb
                    lbsr      _scrdraw
                    puls      a,b
                    lbsr      _render
                    puls      a,b,pc
@renderall          lbsr      _renderall
                    puls      a,b,pc



__cntlines          pshs      a,b,x,y
                    ldd       <height
                    addd      #2
                    std       <cntlin
                    ldx       #0
                    stx       <scrlines
                    ldy       <strptr
                    cmpy      #0
                    beq       @last
@next               leax      5,y
                    ldd       <scrlines
                    addd      #2
                    subd      <scrline
                    bcs       @nonvis
                    cmpd      <cntlin
                    bhi       @nonvis
                    lbsr      _strrows
                    clra
                    stb       4,y
@nonvis             clra
                    ldb       4,y
                    addd      <scrlines
                    std       <scrlines
                    ldy       2,y
                    bne       @next
@last               puls      a,b,x,y,pc


_killine            lda       #K$CtrlD
                    lbsr      _undo_push
                    clr       <edited
                    com       <edited
                    ldx       <topstr
                    ldd       2,x
                    beq       @last
                    lbsr      _strdet
                    bra       @end
@last               ldd       ,x
                    beq       @first
                    lbsr      _strdet
                    ldy       ,x
                    lbsr      _up
                    bra       @end
@first              leax      5,x
                    ldd       #$0d00
                    std       ,x
                    lda       #1
                    sta       -1,x
@end                lbsr      __cntlines
                    ldd       <scrline
                    addb      <cy
                    adca      #0
                    cmpd      <scrlines
                    bcs       @update
                    beq       @update
                    ldd       <scrlines
                    subd      <scrline
                    cmpd      <height
                    bcc       @reset
                    stb       <cy
                    bra       @update
@reset              ldd       <scrlines
                    std       <scrline
                    clr       <cy
@update             lda       #0
                    ldb       <height+1
                    incb
                    lbsr      _renderdel
                    rts

_dupline            lda       #K$CtrlK
                    lbsr      _undo_push
                    clr       <edited
                    com       <edited
                    ldx       <topstr
                    leax      5,x
                    lbsr      _strlen
                    tfr       d,x
                    leax      1,x
                    ldy       <topstr
                    lbsr      _strins
                    lbcs      @error
                    lda       4,y
                    sta       4,x
                    leay      5,y
                    leax      5,x
@loop               lda       ,y+
                    sta       ,x+
                    bne       @loop
                    lbsr      __cntlines
                    lbsr      _down
                    lda       #0
                    ldb       <height+1
                    incb
                    lbsr      _renderdel
                    rts
@error              ldb       #E$MemFul
                    lbsr      _error
                    lbsr      __cntlines
                    rts

_splitline          lda       #K$ShiftRight
                    lbsr      _undo_push
                    clr       <edited
                    com       <edited
                    ldx       <topptr
                    ldb       <cx
                    leax      b,x
                    lbsr      _strlen
                    addb      #16
                    std       <malsize
                    tfr       d,x
                    ldy       <topstr
                    lbsr      _strins
                    lbcs      @error
                    ldb       <cx
                    ldy       <topptr
                    leay      b,y
                    leax      5,x
                    pshs      y
@move               lda       ,y+
                    beq       @endloop
                    sta       ,x+
                    bra       @move
@endloop            puls      y
                    ldd       #$0d00
                    std       ,y
                    clr       ,x
                    lbsr      __cntlines
                    lda       <cy
                    pshs      a
                    lbsr      _down
                    clr       <cx
                    clr       <tcx
                    lbsr      _setpos
                    ldd       <scrlines
                    cmpd      <height
                    bcc       @tobtm
                    puls      a
                    bra       @draw
@tobtm              puls      a
                    ldb       <height+1
@draw               incb
                    lbsr      _renderdel
                    rts
@error              ldb       #E$MemFul
                    lbsr      _error
@count              lbsr      __cntlines
                    rts




_inschar            lda       #K$ShiftRight
                    lbsr      _undo_push
                    lda       <key
                    clr       <edited
                    com       <edited
                    sta       <curchar
                    ldx       <topstr
                    leax      5,x
                    lbsr      _strrows
                    stb       <currows
                    lbsr      _strlen
                    std       <strlen
                    ldd       -7,x
                    anda      #~$80
                    subd      #2                  ; malloc header
                    std       <malsize
                    subd      #6                  ; str header + null char
                    lbcs      @error
                    subd      <strlen
                    lbcs      @error
                    beq       @expand
                    bra       @insert
@expand             ldx       <topstr
                    ldd       <malsize
                    addd      #10                 ;
                    lbsr      _strres
                    lbcs      @error
                    clra
                    ldb       <cy
                    addd      <scrline
                    tfr       d,x
                    lbsr      _gotoline
@insert             ldx       <topptr
                    ldb       <cx
                    leax      b,x
                    tfr       x,y
                    clrb
@goend              incb
                    lda       ,y+
                    bne       @goend
@move               lda       ,-y
                    sta       1,y
                    decb
                    bne       @move
                    lda       <curchar
                    sta       ,x
                    lbsr      __cntlines
                    lbsr      _right
                    ldx       <topstr
                    leax      5,x
                    lbsr      _strrows
                    cmpb      <currows
                    beq       @renderdel
                    clr       <renderall
                    com       <renderall
@renderdel
                    ldx       <topptr
                    lbsr      _strrows
                    lda       <cy
                    addb      <cy
                    lbsr      _renderdel
                    rts
@error              ldb       #E$MemFul
                    lbsr      _error
                    rts


_dohome             ldd       <topptr
                    subd      <topstr
                    addd      #5
@loop               subd      <width
                    beq       @same
                    bcs       @same
                    pshs      a,b
                    lbsr      _up
                    puls      a,b
                    bra       @loop
@same               clr       <cx
                    clr       <tcx
                    lbsr      _setpos
                    lbsr      _renderall
                    rts

_doend              lbsr      brkpnt
                    ldx       <topptr
                    lbsr      _strlen
@loop               subd      <width
                    beq       @same
                    bcs       @same
                    pshs      a,b
                    lbsr      _down
                    puls      a,b
                    bra       @loop
@same               addd      <width
                    decb
                    stb       <cx
                    stb       <tcx
                    lbsr      _setpos
                    lbsr      _renderall
                    rts


_undo_push          tst       <undoflag
                    lbne      @skip
                    pshs      a,b,x,y,u
                    ldx       <undoptr
                    beq       @first
@loop
                    ldy       2,x
                    beq       @last
                    tfr       y,x
                    bra       @loop
@last               tfr       x,y
                    ldx       #sizeof{undo_item}
                    lbsr      _malloc
                    lbcs      @error
                    stx       2,y
                    sty       ,x
                    clr       2,x
                    clr       3,x
                    bra       @set
@first              ldx       #sizeof{undo_item}
                    lbsr      _malloc
                    lbcs      @error
                    stx       <undoptr
                    ldy       #0
                    sty       ,x
                    sty       2,x
@set                sta       undo_item.key,x
                    ldd       <cx
                    std       undo_item.cx,x
                    ldd       <topstr
                    std       undo_item.topstr,x
                    ldd       <scrline
                    std       undo_item.scrline,x
                    puls      a,b,x,y,u,pc
@error              ldb       #E$MemFul
                    lbsr      _error
                    puls      a,b,x,y,u,pc
@skip               clr       <undoflag
                    rts

_undo_pop           ldx       <undoptr
                    beq       @end
@next               ldd       2,x
                    beq       @last
                    tfr       d,x
                    bra       @next
@last               ldd       #0
                    ldy       ,x
                    beq       @first
                    std       2,y
                    bra       @pop
@first              std       <undoptr
@pop                lbsr      _mfree
@end                rts


_undo_del           pshs      a,b,x,y
                    ldx       <undoptr
                    cmpx      #0
                    beq       @end
                    ldd       #0
                    std       <undoptr
                    lbsr      _mfree
                    ldy       2,x
                    beq       @last
                    ldd       #0
                    std       ,y
                    sty       <undoptr
@last               lda       undo_item.key,x
                    cmpa      #K$CtrlD
                    bne       @end
                    ldx       undo_item.topstr,x
                    lbsr      _mfree
@end                puls      a,b,x,y,pc



_undo_undo          lbsr      _undo_pop
                    cmpx      #0
                    beq       @end
                    lda       undo_item.key,x
                    cmpa      #K$CtrlD
                    bne       @dokey
                    clr       undo_item.key,x
                    ldd       undo_item.cx,x
                    std       <cx
                    ldd       undo_item.scrline,x
                    std       <scrline
                    addb      <cy
                    adca      #0
                    exg       d,x
                    lbsr      _gotoline
                    exg       d,x
                    ldx       undo_item.topstr,x
                    ldd       ,x
                    beq       @first
                    ldd       2,x
                    beq       @last
                    ldy       <topstr
                    ldy       ,y
                    ldd       2,y
                    std       2,x                 this->next = prev->next
                    sty       ,x                  this->prev = prev
                    stx       2,y                 prev->next = this
                    ldy       2,x
                    stx       ,y                  next->prev = this
@refr               clr       <renderall
                    com       <renderall
                    lbsr      __cntlines
                    exg       x,d
                    lbsr      _setpos
                    lbsr      _renderall
@end                lbra      _input
@last               ldy       <strptr
@next               ldd       2,y
                    beq       @found
                    tfr       d,y
                    bra       @next
@found              stx       2,y
                    sty       ,x
                    bra       @refr
@first              ldy       <strptr
                    sty       2,x
                    stx       ,y
                    stx       <strptr
                    bra       @refr
@dokey              clr       <renderall
                    com       <renderall
                    ldd       undo_item.cx,x
                    std       <cx
                    ldd       undo_item.scrline,x
                    std       <scrline
                    exg       x,d
                    lbsr      _setpos
                    exg       x,d
                    lda       undo_item.key,x
                    sta       <key
                    clr       <undoflag
                    com       <undoflag
                    lbra      _redo

                    emod
eom                 equ       *
                    end
                    end
