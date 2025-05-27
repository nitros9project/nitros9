********************************************************************
* PRESUB - Sub Battle Simulator (autoex module)
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   0      2003/01/12  Boisy G. Pitre
* Disassembly of original distribution.

                    nam       sub
                    ttl       startup program

* Disassembled 03/01/12 10:22:39 by Disasm v1.5 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       2
u0002               rmb       8
u000A               rmb       3
u000D               rmb       19
u0020               rmb       83
u0073               rmb       311
size                equ       .

name                fcs       /sub/
*         fcb   edition

start               lds       #$0080
                    leax      >CurOff,pcr
                    lbsr      WriteTxt            turn cursor off
ShowMenu            leax      >Menu,pcr
                    lbsr      WriteTxt            show menu
                    lbsr      Read1Chr            read char
                    cmpa      #'1                 is it 1?
                    beq       DoCMP               branch if so
                    cmpa      #'2                 is it 2?
                    beq       DoMONO              branch if so
                    cmpa      #'3                 is it 3?
                    beq       DoRGB               branch if so
                    leax      >Bell,pcr           else ring bell
                    lbsr      WriteTxt
                    bra       ShowMenu            and start over
DoCMP               ldx       #$0000              composite
                    bra       SetMntr
DoMONO              ldx       #$0002              monochrome
                    bra       SetMntr
DoRGB               ldx       #$0001              RGB
SetMntr             ldd       #($01*256)+SS.Montr
                    os9       I$SetStt            set monitor type
                    leax      >SwapDisk,pcr       point to disk swap message
                    lbsr      WriteTxt            write text
                    lbsr      Read1Chr            read char
                    leax      >CurOn,pcr
                    lbsr      WriteTxt            turn on cursor
                    leax      >NewDir,pcr
                    lda       #EXEC.
                    os9       I$ChgDir            change directory
                    bcc       L006C               branch if successful
L0069               os9       F$Exit              else exit
L006C               ldb       #$0C                screen clear character
                    stb       >$0186              store in buffer
                    ldx       #$0186              point X to buffer
                    ldy       #$0001              one byte
                    lda       #$01                to stdout
                    os9       I$Write             write it!
                    ldd       #$1100
                    leax      >SubPrg,pcr
                    ldy       #$0000
                    ldu       #$0082
                    os9       F$Chain             chain to new program
                    bcs       L0069               branch if error
                    ldd       #$0000              code should never get here if chain worked!
                    os9       F$Exit

Read1Chr            pshs      y,x,b               save regs
                    clra                          standard input
                    ldx       #$0186              point to input buffer
                    ldy       #$0001              get 1 char
                    os9       I$Read              do it!
                    lda       >$0186              get char at buffer ptr
                    puls      pc,y,x,b            and return

* Write string routine
* Note: terribly ineffecient
WriteTxt            pshs      y,b,a               save registers
NextByte            ldb       ,x+                 get byte at X
                    beq       WritExit            branch if zero
                    stb       >$0186              else save
                    pshs      x,b,a               save registers again
                    ldx       #$0186              point to buffer
                    ldy       #$0001              1 char
                    lda       #$01                to stdout
                    os9       I$Write             write it
                    puls      x,b,a               pull registers
                    bra       NextByte            go get next char
WritExit            puls      pc,y,b,a            return

CurOff              fcb       $05,$20,$00
CurOn               fcb       $05,$21,$00
Menu                fcb       $0c,$02,$20,$22
                    fcc       /WHAT TYPE OF DISPLAY DO YOU HAVE/
                    fcb       C$LF,C$CR,C$LF,C$CR
                    fcc       /    (1). Television/
                    fcb       C$LF,C$CR,C$LF,C$CR
                    fcc       /    (2). Monochrome Monitor/
                    fcb       C$LF,C$CR,C$LF,C$CR
                    fcc       /    (3). R.G.B. Monitor./
                    fcb       0
SwapDisk            fcb       $0C,$02,$23,$25
                    fcc       /Insert side /
                    fcb       $1f,$24,$32,$1f,$25
                    fcc       / of diskette/
                    fcb       C$LF,C$LF,C$CR
                    fcc       / and press any key to continue/
                    fcb       C$LF,C$LF,C$CR,00
Bell                fcb       C$BELL,$00
NewDir              fcc       !/dd/cmds!
                    fcb       C$CR
SubPrg              fcc       /sub/
                    fcb       C$CR

                    emod
eom                 equ       *
                    end

