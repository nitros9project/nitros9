* MIDI DIN input: ONLY the interrupt handler reads the hardware RX FIFO.
* UME reads the captured bytes through /mi; no drawing/output in system IRQ.
                    use       defsfile
                    mod       eom,name,Drivr+Objct,ReEnt+1,start,size
                    org       V.SCF
Ring                rmb       2
Head                rmb       2
Tail                rmb       2
Count               rmb       2
Active              rmb       1
LastSec             rmb       1
LastTick            rmb       1
OldMask             rmb       1
Lost                rmb       2
size                equ       .
* 2026-10-02 (user): a plain SCF serial input like a 6551 /t2 - the IRQ fills the ring, Read pops it - but
* "midi in is input-only": READ. here and in the mi descriptor (no SHARE.), and Write is refused.
                    fcb       READ.
name                fcs       /MIDrv/
                    fcb       3
start               lbra      Init
                    lbra      Read
                    lbra      Bad
                    lbra      GetStat
                    lbra      SetStat
                    lbra      Term
Init                clra
                    clrb
                    std       Head,u
                    std       Tail,u
                    std       Count,u
                    std       Lost,u
                    clr       Active,u
                    pshs      u
                    ldd       #2048
                    os9       F$SRqMem
                    tfr       u,x
                    puls      u
                    bcs       initret@
                    stx       Ring,u
                    ldd       #INT_PENDING_3
                    leax      Packet,pcr
                    leay      Service,pcr
                    os9       F$IRQ
                    bcs       initfree@
                    pshs      cc
                    orcc      #IntMasks
                    lda       >INT_MASK_3
                    anda      #INT_MIDI_RX
                    sta       OldMask,u
                    lda       >INT_MASK_3
                    anda      #^INT_MIDI_RX
                    sta       >INT_MASK_3
* The core raises INT_MIDI_RX only on the Rx FIFO's empty -> non-empty EDGE. Bytes queued before this Init
* (a keyboard's active sensing, earlier playing) mean that edge is gone and no IRQ would ever come: drain them
* now and clear the pending bit, so the next byte makes a fresh edge.
                    lbsr      Service
                    puls      cc
                    clrb
initret@            rts
initfree@           pshs      b,u
                    ldu       Ring,u
                    ldd       #2048
                    os9       F$SRtMem
                    puls      b,u
                    orcc      #Carry
                    rts
Packet              fcb       0,INT_MIDI_RX,$F1
* Clear the edge BEFORE draining. A later empty->nonempty edge remains pending.
Service             lda       #INT_MIDI_RX
                    sta       >INT_PENDING_3
rx@                 lda       >MIDI.Base
                    bita      #MIDI.RxEmpty
                    bne       done@
                    lda       >MIDI.Base+1
                    pshs      a                   STACK BYTE: captured RX byte
                    ldd       Count,u
                    cmpd      #2048
                    bhs       overflow@
                    ldx       Ring,u
                    ldd       Head,u
                    leax      d,x
                    puls      a
                    sta       ,x
                    ldd       Head,u
                    addd      #1
                    anda      #7
                    std       Head,u
                    ldd       Count,u
                    addd      #1
                    std       Count,u
                    bra       stamp@
overflow@           leas      1,s
                    ldd       Lost,u
                    addd      #1
                    std       Lost,u
stamp@              lda       >D.Sec
                    sta       LastSec,u
                    lda       >D.Tick
                    sta       LastTick,u
                    lda       #1
                    sta       Active,u
                    bra       rx@
* Wake a reader suspended in Read (Level 2 pattern of mc6850.asm: V.WAKE = MSB of its process descriptor).
done@               clrb
                    lda       V.WAKE,u
                    beq       ret@
                    stb       V.WAKE,u
                    tfr       d,x
                    lda       P$State,x
                    anda      #^Suspend
                    sta       P$State,x
ret@                clrb
                    rts
* I$Read (dump /mi, list /mi): wait for the IRQ service to queue a byte. A signal (S$Intrpt or lower) or a
* condemned process ends the wait with an error. UME never comes here: it reads with GetStat $D7 (ReadNow).
Read                pshs      x                   the caller's X survives the sleep path too
rdloop@             bsr       ReadNow
                    bcc       rdret@              A = the byte
                    pshs      cc
                    orcc      #IntMasks
                    ldd       Count,u
                    bne       rdagain@            a byte arrived between ReadNow and the mask
                    ldd       >D.Proc
                    sta       V.WAKE,u            MSB of the process descriptor; Service clears Suspend
                    tfr       d,x
                    lda       P$State,x
                    ora       #Suspend
                    sta       P$State,x
                    andcc     #^IntMasks
                    ldx       #1
                    os9       F$Sleep
                    orcc      #IntMasks
                    clr       V.WAKE,u
                    ldx       >D.Proc
                    ldb       P$Signal,x
                    beq       rdstate@
                    cmpb      #S$Intrpt
                    bls       rderr@              B = the signal, returned as the error
rdstate@            ldb       P$State,x
                    bitb      #Condem
                    beq       rdagain@
                    ldb       #E$PrcAbt
rderr@              puls      cc
                    orcc      #Carry
                    puls      x,pc
rdagain@            puls      cc
                    bra       rdloop@
rdret@              puls      x,pc
* Non-blocking: A = the oldest captured byte, or carry + E$NotRdy when the ring is empty.
ReadNow             pshs      cc,x
                    orcc      #IntMasks
                    ldd       Count,u
                    beq       empty@
                    subd      #1
                    std       Count,u
                    ldd       Tail,u
                    ldx       Ring,u
                    leax      d,x
                    lda       ,x
                    pshs      a
                    ldd       Tail,u
                    addd      #1
                    anda      #7
                    std       Tail,u
                    puls      a
                    puls      cc,x
                    andcc     #^Carry
                    rts
empty@              puls      cc,x
                    ldb       #E$NotRdy
                    orcc      #Carry
                    rts
* SS.Ready reports captured bytes. Private $D6 returns X=count, B=activity.
GetStat             cmpa      #$D7
                    bne       gsready@
                    lbsr      ReadNow
                    bcs       gsret@
                    ldx       PD.RGS,y
                    sta       R$B,x
                    clrb
gsret@              rts
gsready@            cmpa      #SS.Ready
                    beq       ready@
                    cmpa      #$D6
                    bne       Bad
                    pshs      cc
                    orcc      #IntMasks
                    tst       Active,u
                    beq       status@
                    lda       >D.Sec
                    suba      LastSec,u
                    beq       same@
                    cmpa      #1
                    beq       next@
                    cmpa      #$C5                0 - 59 (minute rollover)
                    bne       expire@
next@               lda       LastTick,u
                    adda      #60
                    bra       age@
same@               lda       LastTick,u
age@                suba      >D.Tick
                    cmpa      #6                  visible 100 ms activity pulse
                    blo       status@
expire@             clr       Active,u
status@             ldx       PD.RGS,y
                    ldd       Count,u
                    std       R$X,x
                    ldb       Active,u
                    stb       R$B,x
                    puls      cc
                    clrb
                    rts
ready@              pshs      cc
                    orcc      #IntMasks
                    ldd       Count,u
                    beq       notready@
                    tsta
                    beq       count@
                    ldb       #255
count@              ldx       PD.RGS,y
                    stb       R$B,x
                    puls      cc
                    clrb
                    rts
notready@           puls      cc
                    ldb       #E$NotRdy
                    orcc      #Carry
                    rts
* SCF sends SS.Open on every I$Open and SS.Close on every I$Close, and fails the open when the driver errors
* (scf.asm InvokeDriverOpen). Rejecting them made every open of /mi fail (dump /mi: 203 from its DIR retry; UME's
* OpenMidiInput left MidiInPath 0). Nothing to do for either: the IRQ capture runs from Init to Term.
SetStat             cmpa      #SS.ComSt
                    beq       ssok@
                    cmpa      #SS.Open
                    beq       ssok@
                    cmpa      #SS.Close
                    bne       Bad
ssok@               clrb
                    rts
Bad                 ldb       #E$UnkSvc
                    orcc      #Carry
                    rts
Term                pshs      cc
                    orcc      #IntMasks
                    lda       >INT_MASK_3
                    ora       #INT_MIDI_RX
                    sta       >INT_MASK_3
                    ldx       #0
                    leay      Service,pcr
                    os9       F$IRQ
                    lda       >INT_MASK_3
                    anda      #^INT_MIDI_RX
                    ora       OldMask,u
                    sta       >INT_MASK_3
                    pshs      u
                    ldu       Ring,u
                    ldd       #2048
                    os9       F$SRtMem
                    puls      u
                    puls      cc
                    clrb
                    rts
                    emod
eom                 equ       *
                    end
