********************************************************************
* SSPak - Speech-Sound Pak Text-To-Speech Driver
*
* $Id$
*
* by Bruce Isted (CIS 76625,2273)
* released to the Public Domain 87/05/03
*
*    This driver supports only the Speech-Sound Pak's text-to-speech mode.
* Bit 7 is cleared and control codes are filtered to ensure that only carriage
* returns and characters in the range of $20-$7F (inclusive) are passed.  A
* character count and automatic buffer flush is used, which should prevent
* buffer overflow in the Speech-Sound Pak.
*
*    Due to way the COCO's sound select circuitry is tied in with other sound
* sources and the joysticks, only one will function at a time.  This means
* that while the Speech-Sound Pak is active other sound sources and/or the
* joysticks cannot be used.  Speech output is enabled only when a carriage
* return is received, or when the buffer is flushed.  Speech output is
* disabled as soon as the Speech-Sound Pak is finished speaking the string
* received before the carriage return or buffer flush.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      1987/05/03  Bruce Isted
* Created.

                    nam       SSPak
                    ttl       Speech-Sound Pak Text-To-Speech Driver

                    ifp1
                    use       defsfile
                    endc

BuffCnt             equ       200                 character count before flushing buffer (0-255)
BusyBit             equ       %10000000           SSPak busy status bit (active low)
CharMask            equ       %01111111           printable ASCII character mask
CRA                 equ       $01                 PIA CRA offset
CRB                 equ       $03                 PIA CRB offset
MUXBit              equ       %00001000           COCO sound MUX control/select bit position
SpeakBit            equ       %01000000           SSPak speech status bit (active low)
SSPData             equ       $01                 SSPak data register offset
SSPReset            equ       $00                 SSPak reset register offset
SSPStat             equ       $01                 SSPak status register offset

rev                 equ       $00
edition             set       1

                    mod       SEnd,SNam,Drivr+Objct,ReEnt+rev,SEntry,SMem

                    org       V.SCF               SCF manager data area
Count               rmb       1                   character counter
SMem                equ       .

                    fcb       SHARE.+PWRIT.+WRITE. device capabilities

SNam                fcs       "SSPak"
                    fcb       edition

SEntry              lbra      SInit
                    lbra      SRead
                    lbra      SWrite
                    lbra      SGetStat
                    lbra      SSetStat
                    lbra      STerm

SInit               equ       *
STerm               equ       *
                    ldx       V.PORT,u
                    ldb       #$01
                    stb       SSPReset,x          reset SSPak
                    clrb
                    stb       SSPReset,x          end SSPak reset
                    rts

SRead               comb
                    ldb       #E$BMode
                    rts

SWrite              anda      #CharMask           strip MSBit of character
                    cmpa      #C$CR               carriage return?
                    beq       SpkOut              yes, go enable SSPak speech output
                    inc       Count,u             increment character counter
                    cmpa      #C$SPAC             higher than space?
                    bhi       WritChar            yes, go write character to SSPak
                    lda       #C$SPAC             only space allowed through here
                    ldb       Count,u             get current character count
                    cmpb      #BuffCnt            time to flush buffer?
                    blo       WritChar            no, go write space to SSPak
SpkOut              clr       Count,u             reset character count
                    ldy       #PIA0Base
                    lda       CRA,y               get PIA0 CRA
                    ldb       CRB,y               get PIA0 CRB
                    pshs      d                   save them
                    anda      #^MUXBit            clear PIA0 CA2 control LSBit
                    orb       #MUXBit             set PIA0 CB2 control LSBit
                    sta       CRA,y               * set COCO sound MUX to cartridge input
                    stb       CRB,y               *
                    ldy       #PIA1Base
                    ldb       CRB,y               get PIA1 CRB
                    pshs      b                   save it
                    orb       #MUXBit             set PIA1 CB2 control LSBit
                    stb       CRB,y               enable COCO sound MUX
                    lda       #C$CR               load execute speech character
                    bsr       WritChar            go write command character to SSPak
                    bsr       SSWait              go wait until SSPak has finished
                    puls      b                   recover original PIA1 CRB
                    stb       CRB,y               disable COCO sound MUX
                    puls      d                   recover original PIA0 CRA & CRB
                    ldy       #PIA0Base
                    sta       CRA,y               *restore COCO sound MUX to previous setting
                    stb       CRB,y               *
                    clrb
                    rts
WritChar            bsr       BusyWait            go check if SSPak is busy
                    sta       SSPData,x           write character to SSPak
                    clrb
                    rts

SGetStat            equ       *
SSetStat            equ       *
                    comb
                    ldb       #E$UnkSvc
                    rts

BusyWait            ldx       V.PORT,u
                    ldb       SSPStat,x           get SSPak status
                    andb      #BusyBit            SSPak busy?
                    beq       BusyWait            yes, go check again
                    ldb       SSPStat,x           *allow for slow busy bit
                    andb      #BusyBit            *
                    beq       BusyWait            *
                    ldb       SSPStat,x           *allow for very slow busy bit
                    andb      #BusyBit            *
                    beq       BusyWait            *
                    rts

SSWait              ldx       V.PORT,u
                    ldb       SSPStat,x           get SSPak status
                    andb      #SpeakBit           SSPak speech active yet?
                    bne       SSWait              no, go check again
SSWait0             ldx       #$0001              sleep remainder of tick
                    os9       F$Sleep
                    ldx       V.PORT,u
                    ldb       SSPStat,x           get SSPak status
                    andb      #SpeakBit           SSPak speech still active?
                    beq       SSWait0             yes, go sleep some more
                    rts

                    emod
SEnd                equ       *
                    end

