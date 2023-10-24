                    nam       JoyPoll
                    ttl       Joystick poll utility

                    ifp1
                    use       defsfile
                    endc

                    mod       eom,Name,Prgrm+Objct,ReEnt+1,Start,Fin

Name                fcs       /AutoEx/
Ed                  fcb       $02

outpath             rmb       1
outline             rmb       80
SubEnt              rmb       2
RetAddr             rmb       2
JoyNum              rmb       2
JoyX                rmb       2
JoyY                rmb       2
JoyB                rmb       2
LastJoyX            rmb       2
LastJoyY            rmb       2
LastJoyB            rmb       2
opts                rmb       OPTCNT
Stack               rmb       200
Fin                 equ       .

ParmCnt             equ       0
Addr1               equ       2
Size1               equ       4
Addr2               equ       6
Size2               equ       8
Addr3               equ       10
Size3               equ       12
Addr4               equ       14
Size4               equ       16
StackEnd            equ       Size4

submod              fcs       "JoyStk"
outdev              fcs       "/T1"

Start               lda       #Sbrtn+Objct
                    leax      submod,pcr
                    pshs      u
                    os9       F$Link
                    puls      u
                    bcc       GoOn
error               os9       F$Exit
GoOn                sty       <SubEnt             save entry pointer

* Initialize our static storage
                    ldd       #$FFFF
                    std       <LastJoyX
                    std       <LastJoyY
                    std       <LastJoyB

* Populate our storage area with parameters for the module
                    leas      -StackEnd,s
                    ldd       #$04
                    std       ParmCnt,s
                    ldb       #$02
                    std       Size1,s
                    std       Size2,s
                    std       Size3,s
                    std       Size4,s
                    leax      JoyNum,u
                    decb
                    std       ,x
                    stx       Addr1,s
                    leax      JoyX,u
                    stx       Addr2,s
                    leax      JoyY,u
                    stx       Addr3,s
                    leax      JoyB,u
                    stx       Addr4,s

* Open path to output device
                    leax      outdev,pcr
                    lda       #WRITE.
                    os9       I$Open
                    bcs       error
                    sta       <outpath

* Set up no pause for both stdout and newly opened output path
                    ldb       #SS.Opt
                    leax      opts,u
                    os9       I$GetStt
                    bcs       error
                    clr       (PD.PAU-PD.OPT),x
                    os9       I$SetStt
                    bcs       error
                    lda       #1
                    os9       I$GetStt
                    bcs       error
                    clr       (PD.PAU-PD.OPT),x
                    os9       I$SetStt
                    bcs       error

* Here's where the action is
FLoop               ldx       <SubEnt
                    jsr       ,x                  call subroutine module

* See if our new values match our last values?
                    ldd       <JoyX               get joystick X
                    cmpd      <LastJoyX           same as last?
                    bne       CopyVals            branch if not
                    ldd       <JoyY               get joystick Y
                    cmpd      <LastJoyY           same as last?
                    bne       CopyVals            branch if not
                    ldd       <JoyB               get joystick button
                    cmpd      <LastJoyB           same as last?
                    beq       Nap

* Copy current values to 'last' values
CopyVals            ldd       <JoyB
                    std       <LastJoyB
                    ldd       <JoyY
                    std       <LastJoyY
                    ldd       <JoyX
                    std       <LastJoyX

                    leax      <outline,u
                    bsr       OutDec3             output joystick X
                    lda       #C$SPAC
                    sta       ,x+
                    ldd       JoyY,u
                    bsr       OutDec3             output joystick Y
                    lda       #C$SPAC
                    sta       ,x+
                    ldd       JoyB,u
                    bsr       OutDec3             output joystick button
                    lda       #C$CR
                    sta       ,x+
                    lda       <outpath
                    leax      <outline,u
                    ldy       #80
                    os9       I$WritLn            write line
                    lda       #$01                stdout
                    os9       I$WritLn            write line to screen

* Take a small nap
Nap                 ldx       #60*1               1 seconds
                    os9       F$Sleep             go to sleep
                    bra       FLoop


* Print 3 Decimal Digits from D to ,X
OutDec3             pshs      a
                    lda       #'0
                    sta       ,x
                    sta       1,x
                    puls      a
Hundred             subd      #100
                    bcs       PreTen
                    inc       ,x
                    bra       Hundred
PreTen              addd      #100
Ten                 subd      #10
                    bcs       PreOne
                    inc       1,x
                    bra       Ten
PreOne              addb      #$30+10
                    stb       2,x
                    leax      3,x
                    rts

                    emod
eom                 equ       *
                    end


