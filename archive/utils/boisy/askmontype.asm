                    nam       askmontype
                    ttl       Prompts for monitor type and sets accordingly

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

key                 rmb       1
orgopts             rmb       32
modopts             rmb       32
stack               rmb       200
size                equ       .

name                equ       *
                    fcs       /askmontype/
start               equ       *
                    leax      >CurOff,pcr
                    ldy       #CurOffL
                    lbsr      WriteMsg
                    clra
                    clrb
                    leax      orgopts,u
                    os9       I$GetStt
                    leax      modopts,u
                    os9       I$GetStt
                    clr       4,x
                    clr       16,x
                    clr       17,x
                    clrb
                    os9       I$SetStt
AskMon              leax      >MonSelct,pcr
                    ldy       #MonSelL
                    lbsr      WriteMsg
AskMon2             lbsr      ReadKey
                    cmpa      #'1
                    beq       TV
                    cmpa      #'2
                    beq       Mono
                    cmpa      #'3
                    beq       RGB
                    leax      >Bell,pcr
                    ldy       #BellL
                    lbsr      WriteMsg
                    bra       AskMon2
TV                  ldx       #$0000              TV/composite monitor
                    bra       ChgMon
Mono                ldx       #$0002              monochrome monitor
                    bra       ChgMon
RGB                 ldx       #$0001              RGB monitor
ChgMon              ldd       #$01*256+SS.Montr
                    os9       I$SetStt            make the monitor setting
                    leax      >CurOn,pcr
                    ldy       #CurOnL
                    lbsr      WriteMsg
                    leax      orgopts,u
                    clra
                    clrb
                    os9       I$SetStt
                    clrb
L0069               os9       F$Exit

ReadKey             pshs      y,x,b
                    clra                          stdin
                    leax      key,u
                    ldy       #$0001
                    os9       I$Read
                    lda       key,u
                    puls      pc,y,x,b

WriteMsg            pshs      y,x,b,a
                    lda       #1                  stdout
                    os9       I$Write
                    puls      pc,y,x,b,a


CurOff              fdb       $0520
CurOffL             equ       *-CurOff
CurOn               fdb       $0521
CurOnL              equ       *-CurOn

MonSelct            fcb       $0C
                    fcb       $02,$20,$22
                    fcc       /    SELECT YOUR DISPLAY TYPE/
                    fcb       $0A,$0D,$0A,$0D,$0A,$0D
                    fcc       "    (1) TV/Composite Monitor"
                    fcb       $0A,$0D,$0A,$0D
                    fcc       /    (2) Monochrome Monitor/
                    fcb       $0A,$0D,$0A,$0D
                    fcc       /    (3) RGB Monitor/
                    fcb       $0A,$0D
MonSelL             equ       *-MonSelct

Bell                fcb       $07
BellL               equ       *-Bell

L0193               fcc       "sub"
                    fcb       $0D

                    emod
eom                 equ       *
                    end

