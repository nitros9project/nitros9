* K2 RP2040 mailbox SCF transport. I$Write: command,length,payload (0..240).
* I$Read: length,payload. One outstanding reply; exclusive path ownership.
* GetStat $C0: X=status:error, Y=firmware-major:remote-status.
* No IRQ handler or interrupt-masked waits. Requires rc19 and firmware 1.x.
                    ifp1
                    use defsfile
                    endc
                    org V.SCF
Owner               rmb 2
Phase               rmb 1
Cmd                 rmb 1
Count               rmb 1
Index               rmb 1
Available           rmb 1
ReadIndex           rmb 1
LastTick            rmb 1
TickDelta           rmb 1
TicksLeft           rmb 2
Packet              rmb 241
MemSize             equ .
                    mod eom,name,Drivr+Objct,ReEnt+1,entry,MemSize
                    fcb READ.+WRITE.
entry               lbra Init
                    lbra Read
                    lbra Write
                    lbra GetStat
                    lbra SetStat
                    lbra Term
name                fcs /RPDrv/
                    fcb 2
Init                clra
                    clrb
                    std Owner,u
                    sta Phase,u
                    sta Available,u
                    rts
Term                lbra Init
Good                clrb
                    rts
BadService          comb
                    ldb #E$UnkSvc
                    rts
BusyError           comb
                    ldb #E$DevBsy
                    rts
BadPacket           clr Phase,u
                    comb
                    ldb #E$BMode
                    rts
NotReady            comb
                    ldb #E$NotRdy
                    rts
CheckOwner          cmpy Owner,u
                    lbne BusyError
                    clrb
                    rts
SetStat             cmpa #SS.ComSt
                    lbeq Good
                    cmpa #SS.Open
                    lbeq Open
                    cmpa #SS.Close
                    lbne BadService
                    cmpy Owner,u
                    lbne Good
* Never reset the hardware FIFO or cancel an in-flight command on close.
* A later open reports busy until the original operation has completed.
                    clra
                    clrb
                    std Owner,u
                    sta Phase,u
                    sta Available,u
                    rts
Open                ldd Owner,u
                    lbne BusyError
                    lda >RP.FwMajor
                    cmpa #1
                    lbne NotReady
                    lda >RP.Status
                    bita #1
                    lbeq NotReady
                    bita #8
                    lbne BusyError
                    sty Owner,u
                    clr Phase,u
                    clr Available,u
                    lda #$83
                    sta >RP.Control
                    lda #1
                    sta >RP.Control
                    lbra Good
GetStat             ldx PD.RGS,y
                    cmpa #SS.ComSt
                    lbeq ComStat
                    cmpa #$C0
                    lbeq Info
                    cmpa #SS.Ready
                    lbne BadService
                    ldb Available,u
                    lbeq NotReady
                    stb R$B,x
                    lbra Good
ComStat             clra
                    clrb
                    std R$Y,x
                    rts
Info                lda >RP.Status
                    ldb >RP.Error
                    std R$X,x
                    lda >RP.FwMajor
                    ldb >RP.Remote
                    std R$Y,x
                    lbra Good
Read                lbsr CheckOwner
                    lbcs Return
                    ldb Available,u
                    lbeq NotReady
                    pshs x
                    leax Packet,u
                    ldb ReadIndex,u
                    abx
                    lda ,x
                    inc ReadIndex,u
                    dec Available,u
                    clrb
                    puls x,pc
Return              rts
Write               pshs a
                    lbsr CheckOwner
                    puls a
                    lbcs Return
                    tst Available,u
                    lbne BusyError
                    ldb Phase,u
                    lbeq CommandByte
                    decb
                    lbeq LengthByte
                    pshs x
                    leax Packet,u
                    ldb Index,u
                    abx
                    sta ,x
                    puls x
                    inc Index,u
                    ldb Index,u
                    cmpb Count,u
                    lbne Good
                    lbra Execute
CommandByte         cmpa #1
                    lblo BadPacket
                    cmpa #$1E
                    lbhi BadPacket
                    sta Cmd,u
                    inc Phase,u
                    lbra Good
LengthByte          cmpa #240
                    lbhi BadPacket
                    sta Count,u
                    clr Index,u
                    inc Phase,u
                    tsta
                    lbne Good
Execute             pshs x,y
                    clr Phase,u
                    lda >RP.Status
                    bita #8
                    lbne ExecBusy
                    ldd >RP.TxCount_H
                    lbne ExecBusy
* Discard old response before submitting this request. Caller handles nonce/PING.
Drain               ldd >RP.RxCount_H
                    lbeq Send
                    lda >RP.RxData
                    lbra Drain
Send                leax Packet,u
                    ldb Count,u
                    lbeq Start
SendByte            lda ,x+
                    sta >RP.TxData
                    decb
                    lbne SendByte
Start               lda Cmd,u
                    sta >RP.Command
                    lda >RP.Status
                    bita #8
                    lbeq ExecError
                    ldd #300
                    pshs d
                    lda Cmd,u
                    cmpa #4
                    beq CommitTimeout
                    cmpa #2
                    bne TimeoutReady
                    lda Packet,u
                    cmpa #2
                    bne TimeoutReady
* RP2040 erases the full flash slot in IMAGE_BEGIN, before replying.
                    ldd #7200
                    std ,s
                    bra TimeoutReady
CommitTimeout       ldd #1800
                    std ,s
TimeoutReady        puls d
                    std TicksLeft,u
                    lda <D.Tick
                    sta LastTick,u
WaitBusy            lda >RP.Status
                    bita #8
                    lbeq Settling
                    lbsr SleepTick
                    lbcs ExecReturn
                    lbra WaitBusy
* BUSY precedes the final RX copy in the supplied engine. Wait a real tick.
Settling            lda <D.Tick
                    sta LastTick,u
SettleLoop          lbsr SleepTick
                    lbcs ExecReturn
                    tst TickDelta,u
                    lbeq SettleLoop
                    lda >RP.Error
                    lbne ExecError
                    ldd >RP.RxCount_H
                    cmpd #240
                    lbhi ExecError
                    stb Packet,u
                    incb
                    stb Available,u
                    clr ReadIndex,u
                    decb
                    lbeq ExecOK
                    leax Packet+1,u
Recv                lda >RP.RxData
                    sta ,x+
                    decb
                    lbne Recv
ExecOK              clrb
ExecReturn          puls x,y,pc
ExecBusy            comb
                    ldb #E$DevBsy
                    lbra ExecReturn
ExecError           comb
                    ldb #E$Write
                    lbra ExecReturn
* SleepTick reports elapsed ticks in TickDelta and updates LastTick.
* 300 ticks normally, 1800 for commit, 7200 for flash erase; early wakes cost zero.
SleepTick           pshs x
                    ldx #1
                    pshs cc
                    andcc #^IntMasks
                    os9 F$Sleep
                    tfr cc,a
                    puls cc
                    anda #1
                    beq Slept
                    orcc #1
                    lbra SleepReturn
Slept
                    lda LastTick,u
                    suba <D.Tick
                    lbpl Delta
                    adda #60
Delta               sta TickDelta,u
                    ldb <D.Tick
                    stb LastTick,u
                    tfr a,b
                    clra
                    pshs d
                    ldd TicksLeft,u
                    subd ,s++
                    std TicksLeft,u
                    lble TimedOut
                    clrb
SleepReturn         puls x,pc
TimedOut            comb
                    ldb #E$NotRdy
                    lbra SleepReturn
                    emod
eom                 equ *
                    end
