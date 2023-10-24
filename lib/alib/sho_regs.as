************************************

* Display the 6809 registers to standard error

* OTHER MODULES NEEDED: BIN2HEX, BIN_HEX,  PUTS


* ENTRY: none
* EXIT: none


* NOTE: The value used for PC is that of the calling routine
*       S is assumed to be 2 greater than actual to comp for
*       the subroutine call...


                    nam       Show                Register Values
                    ttl       Assembler Library Module


                    section   .data

count               rmb       1                   counter for 9 regs.
buffer              rmb       8                   buffer for ascii strings
cc.r                rmb       1                   offsets to access values
a.r                 rmb       1
b.r                 rmb       1
dp.r                rmb       1
x.r                 rmb       2
y.r                 rmb       2
u.r                 rmb       2
s.r                 rmb       2
pc.r                rmb       2

                    endsect

                    section   .text

SHO_REGS
                    leas      -2,s                room for copy of <S>
                    pshs      cc,a,b,dp,x,y,u     save rest
                    leas      -cc.r,s             room for ascii strings
                    tfr       s,x
                    leax      pc.r,x              get old <S>
                    stx       s.r,s               stick on stack
                    leay      cc.r,s              point to regs
                    leau      text,pcr            register names
                    clr       count,s             int. counter

* now we loop and display all the registers

loop1
                    leax      buffer,s            point to ascii buffer
                    ldd       ,u++                get reg. name
                    std       ,x++
                    lda       #'=                 add a "="
                    sta       ,x+
                    lda       count,s             1st 4 are 1 byte
                    cmpa      #4
                    bhs       loop2               no, do a 2byte
                    ldb       ,y+                 get single value
                    lbsr      BIN2HEX
                    std       ,x                  save ascii number
                    clr       2,x
                    bra       report              go report
loop2
                    cmpa      #9                  done all?
                    bhs       exit                yes, go home
                    ldd       ,y++                get reg value
                    lbsr      BIN_HEX             convert it

* report reg. value

report
                    leax      buffer,s            start of buffer
                    lda       #2                  std err
                    lbsr      FPUTS               print it
                    ldb       #$20                space
                    lbsr      FPUTC
                    inc       count,s             do next reg
                    bra       loop1

exit
                    ldb       #$0d
                    lda       #2
                    lbsr      FPUTC               start new line
                    leas      cc.r,s              clear up stack
                    puls      cc,a,b,dp,x,y,u
                    leas      2,s
                    rts                           go home

text
                    fcc       /cc/
                    fcc       / a/
                    fcc       / b/
                    fcc       /dp/
                    fcc       / x/
                    fcc       / y/
                    fcc       / u/
                    fcc       / s/
                    fcc       /pc/

                    endsect
