***************************************

* Edit/input line.

* This routine does not use cursor positioning,
* instead it uses backspacing, etc. This means it
* can be used without a GOTOXY module, however it
* is a bit slow, especially when lines get longer than
* one line. If the buffer contains data, you will be
* able to edit; to enter new data pass a buffer of
* blanks.

* OTHER MODULES NEEDED: STRLEN,IS_PRINT, FPUTS, FPUTC, FGETC, MEMMOVE

* ENTRY: X=null terminated string to edit
*        A=input path (normally 0)
*        B=output path (normally 1)

* EXIT: B=key used to end editing
*       CC carry set if error (GetStt, Setstt, Write, Read, etc.)
*         B=error code, if any

                    nam       Edit/Input          Line
                    ttl       Assembler Library Module


                    section   .text

* these variable are all referenced via the
* U stack pointer.

modPD               equ       0                   first buffer of copy of path descriptor
echo                equ       $04                 echo mode
bso                 equ       $02                 backspace mode
bse                 equ       $12                 backspace echo char
bsp                 equ       $09                 backspace char
int                 equ       $10                 interupt char
qut                 equ       $11                 quit char
bell                equ       $13                 line-overflow char

maxsize             equ       35                  temp variable
dupPD               equ       38                  2nd path desc.

vsize               equ       dupPD+32            variable stack size
strptr              equ       vsize+2             x on stack
inpath              equ       vsize+0             a on stack
outpath             equ       inpath+1            b on stack

LINEDIT
                    pshs      a,b,x,y,u
                    leas      -vsize,s            variable storage area
                    tfr       s,u                 point U to var. area
                    lbsr      STRLEN
                    std       maxsize,u           save max leng.
                    lbeq      exit

* get 2 copies of path descriptor, one to restore with, one to modify

                    lda       outpath,u
                    leax      dupPD,u
                    clrb                          SS.OPT
                    os9       I$GetStt
                    bcs       err1
                    leax      modPD,u
                    clrb
                    os9       I$GetStt
                    bcs       err1

                    clrb
                    clr       echo,u              turn off echo
                    clr       int,u               ignore keyboard interupt
                    clr       qut,u               ignore quit
                    clr       bso,u               backspace overstrike
                    os9       I$SetStt
err1
                    lbcs      exit

* parse string and change all controls to space

fixloop
                    lda       ,x+
                    beq       fixx
                    lbsr      IS_PRINT            is it printable?
                    beq       fixloop             yes, test next
                    lda       #$20                change control to space
                    sta       -1,x
                    bra       fixloop
fixx

* print string at current cursor pos....

                    lda       outpath,u
                    ldy       maxsize,u
                    ldx       strptr,u            get string start
                    lbsr      FPUTS               print string
                    bra       shiftl1             go to line start

loop
                    pshs      a                   save outpath
                    lda       inpath,u
                    lbsr      FGETC               get one char
                    tfr       a,b                 keypress to B
                    puls      a                   restore outpath
                    lbcs      out
                    cmpb      bsp,u               backspace?
                    bne       delete              no, try next

* backspace one position

                    sty       -2,s                test y
                    beq       loop                ignore if already at start
                    lbsr      bs                  do a backspace
                    leax      -1,x
                    bra       loop

* Delete char at cursor

delete
                    cmpb      #$10                delete char?
                    bne       inspace             no, try next
                    pshs      d,x,y
                    ldd       maxsize,u           max leng
                    subd      4,s                 -current pos
                    tfr       x,y                 destination
                    leax      1,x                 source
                    lbsr      MEMMOVE
                    leax      d,y                 end of string
                    lda       #$20                put space at end of string
                    sta       -1,x
                    tfr       y,x

del1
                    puls      d                   get outpath and char
                    lbsr      FPUTS               reprint string
                    ldy       maxsize,u

del2
                    cmpy      2,s                 back up to current cur pos
                    beq       del3
                    lbsr      bs
                    bra       del2

del3
                    puls      x,y                 clean up and loop

del4
                    bra       loop


inspace
                    cmpb      #$11                insert space?
                    bne       shiftl              no, try next
                    pshs      d,x,y
                    ldd       maxsize,u
                    subd      4,s
                    subd      #1
                    leay      1,x                 X=source, Y=dest
                    lbsr      MEMMOVE
                    ldb       #$20                insert space in hole
                    stb       ,x
                    bra       del1                go reprint and loop

* move cursor to start of line

shiftl
                    cmpb      #$18                shift left?
                    bne       shiftr              no, try next

shiftl1
                    bsr       startln             backup to start of line
                    ldx       strptr,u            reset x to start of line
                    bra       asciix              go loop

* move cursor to end of line

shiftr
                    cmpb      #$19                shift right?
                    bne       right

shiftr1
                    cmpy      maxsize,u
                    bhs       del4                back to loop
                    ldb       ,x+                 move to end by printing string
                    lbsr      FPUTC
                    leay      1,y
                    bra       shiftr1

* move 1 pos right

right
                    cmpb      #$09
                    bne       maybasci
                    ldb       ,x                  get current char and insert it
                    lbeq      loop                at end, don't move

* insert ascii char into buffer

maybasci
                    tstb                          insert ascii into buffer
                    lbmi      out                 not ascii
                    cmpb      #$20
                    lblo      out
                    cmpy      maxsize,u           room for this?
                    blo       ascii               yes, insert it
                    ldb       bell,u
                    lbsr      FPUTC
                    bra       asciix              to main loop

ascii
                    stb       ,x+
                    lbsr      FPUTC
                    leay      1,y
asciix
                    lbra      loop

out
                    pshs      b                   save keypress
                    bsr       startln
                    ldx       strptr,u
                    lbsr      FPUTS


                    leax      dupPD,u             get original pd
                    lda       outpath,u
                    clrb
                    os9       I$SetStt
                    puls      a                   get keypress
                    bcc       out1
                    tfr       b,a                 set error to A
out1
                    sta       outpath,s           set B to error/keypress

* when exiting CARRY will be set if error. B will contain
* either the keypress or the error code.

exit
                    leas      vsize,s
                    puls      a,b,x,y,u,pc

* move cursor to start of line

startln
                    sty       -2,s
                    beq       startlnx            exit if at start
startln1
                    bsr       bs
                    bne       startln1

startlnx
                    rts

bs
                    pshs      b
                    ldb       bse,u
                    lbsr      FPUTC
                    leay      -1,y
                    puls      b,pc

                    endsect
