                    nam       CP/M
                    ttl       CP/M Emulator for OS-9 6809
                    ;         2013                Luis Antoniosi

                    use       defsfile

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    org       0



; special purpose regs
PC                  rmb       2
SP                  rmb       2
*IR			rmb		2
; general purpose regs
AF                  rmb       2
BC                  rmb       2
DE                  rmb       2
HL                  rmb       2
; index regs
IX                  rmb       2
IY                  rmb       2
; mirror regs
AF_                 rmb       2
BC_                 rmb       2
DE_                 rmb       2
HL_                 rmb       2
; reg aliases
PCH                 equ       PC
PCL                 equ       PC+1
SPH                 equ       SP
SPL                 equ       SP+1
*I			equ		IR
*R			equ		IR+1
A                   equ       AF
F                   equ       AF+1
B                   equ       BC
C                   equ       BC+1
D                   equ       DE
E                   equ       DE+1
H                   equ       HL
L                   equ       HL+1
IXH                 equ       IX
IXL                 equ       IX+1
IYH                 equ       IY
IYL                 equ       IY+1

SF                  equ       %10000000
ZF                  equ       %01000000
YF                  equ       %00100000
HF                  equ       %00010000
XF                  equ       %00001000
PF                  equ       %00000100
NF                  equ       %00000010
CF                  equ       %00000001

EX                  equ       $0c
S1                  equ       $0d
S2                  equ       $0e
CR                  equ       $20
R0                  equ       $21
R1                  equ       $22
R2                  equ       $23

M_HF                equ       $20
M_NF                equ       $08
M_ZF                equ       $04
M_VF                equ       $02
M_CF                equ       $01



TMP0                rmb       2
TMP1                rmb       2

term                rmb       1                   ; N native, V VT-52, K Kaypro-II
escmode             rmb       3

dta                 rmb       2                   ; disk transfer address
seekpos             rmb       4                   ; 32-bit file pointer

; emulator variables
logpath             rmb       1
dirpath             rmb       1
sgn_code            rmb       1
himem               rmb       2                   ; application high memory
tpasize             rmb       2                   ; buffer size
biostbl             rmb       2
filepath            rmb       1                   ; file path number
oldecho             rmb       1
oldalf              rmb       1
argc                rmb       2
filename            rmb       12                  ; file name parser
optbuf              rmb       32
args                rmb       32                  ; 16 max args

                    org       $100

VAR_SIZE            equ       .                   ; work variables size
STACK_SIZE          equ       64                  ; reserved stack size

                    org       $0
TPASTART            equ       .
tpa                 rmb       (56*1024-VAR_SIZE-STACK_SIZE)

size                equ       .

stdin               equ       0
stdout              equ       1
stderr              equ       2

name                fcs       /CPM/
                    fcb       edition

welcome             fcc       "CP/M Z-80 Emulator for OS-9/6809 Level 2"
                    fcb       $0a,$0d
                    fcc       "v1.02 - 2015 Luis Felipe Antoniosi"
                    fcb       $0a,$0d,$0a,$0d

start
                    lbsr      _init
                    lbsr      _getargs
                    lbsr      _makefcb
                    lbsr      _open
                    tst       <filepath
                    beq       @end
                    lbsr      _read
                    lbsr      _close
                    lbsr      _emu
@end                lbra      _exit



_getargs            ldy       #$80
                    clr       ,y
                    clr       1,y
                    clr       argc,u
                    clr       argc+1,u
                    leay      args,u
                    cmpb      #4
                    bcs       @pre
                    lda       ,x
                    cmpa      #'-
                    bne       @pre
                    lda       1,x
                    cmpa      #'k
                    bne       @isVT
                    subb      #3
                    leax      3,x
                    lda       #'K
                    sta       <term
                    bra       @pre
@isVT               cmpa      #'v
                    bne       @pre
                    subb      #3
                    leax      3,x
                    lda       #'V
                    sta       <term
@pre                tstb                          ; check arg string
                    beq       @noargs
                    decb
                    beq       @endtail
                    pshs      b,x,y
                    ldy       #$80
@next               lda       ,x+
                    cmpa      #$20
                    beq       @found
                    decb
                    beq       @emptytail
                    bra       @next
@found              leax      -1,x
                    stb       ,y+
@copytail           lda       ,x+
                    sta       ,y+
                    decb
                    bne       @copytail
                    clr       ,y
@emptytail          puls      b,x,y
@endtail            lda       ,x+
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


_makefcb            ldy       #$5C
                    lbsr      _clrfcb
                    lbsr      _clrfcb
                    rts


_icept              stb       sgn_code,u
                    rti

_echo_on
                    lda       #stdin
                    ldb       #SS.Opt
                    leax      optbuf,u
                    os9       I$GetStt

                    lda       #1
                    sta       (PD.EKO-PD.OPT),x

                    lda       #stdin
                    ldb       #SS.Opt
                    leax      optbuf,u
                    os9       I$SetStt
                    rts

_echo_off
                    lda       #stdin
                    ldb       #SS.Opt
                    leax      optbuf,u
                    os9       I$GetStt

                    clr       (PD.EKO-PD.OPT),x

                    lda       #stdin
                    ldb       #SS.Opt
                    leax      optbuf,u
                    os9       I$SetStt
                    rts


_init               pshs      a,b,x,y
                    ldd       #0
                    os9       F$Mem               ; get memory boundaries
                    lbcs      _abort

                    subd      #VAR_SIZE
                    clrb                          ; round down $100 page
                    tfr       a,dp                ; set direct page
                    tfr       d,u
                    subd      #STACK_SIZE
                    std       <tpasize            ; compute tpa size
                    std       <himem

                    clr       sgn_code,u
                    leax      _icept,pcr
                    os9       F$Icpt
                    lbcs      _abort

                    lda       #stdin
                    ldb       #SS.Opt
                    leax      <optbuf,u
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



                    clr       <escmode
                    lda       #'N
                    sta       <term

                    leax      welcome,pcr
                    ldy       #80
                    lda       #stdout
                    os9       I$Write
                    puls      a,b,x,y,pc

_deinit

                    lda       #stdin
                    ldb       #SS.Opt
                    leax      optbuf,u
                    os9       I$GetStt

                    leax      optbuf,u
                    lda       oldecho,u
                    sta       (PD.EKO-PD.OPT),x
                    lda       oldalf,u
                    sta       (PD.ALF-PD.OPT),x
                    lda       #stdin
                    ldb       #SS.Opt
                    os9       I$SetStt
                    rts


                    use       os9core.asm

                    use       file.asm

                    use       parity.asm

                    use       flags.asm

                    use       instbl.asm

                    use       z80.asm

                    use       bdos.asm

                    emod
eom                 equ       *
                    end
