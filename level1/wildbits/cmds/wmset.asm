********************************************************************
* wmset - write a WM8776 codec register live, for balancing by ear
*
* Usage:  wmset <reg> <value>        both hex, e.g.  wmset 03 E4
*         wmset                      with no args, prints usage
*
* The codec control port is at CODEC.Base ($FE70) in FIXED I/O, so it
* needs no MMU mapping and works from any task.  A write is 16 bits:
*   [6:0] register  [8] UPDATE  [7:0] value
* i.e. D = (reg<<9) | $100 | value.  The UPDATE bit is always set here,
* which is what makes an attenuation change take effect immediately.
*
* The two knobs worth turning (see the kit README):
*   R03/R04  DAC attenuation      $FF = 0dB, 0.5dB per step down
*   R00/R01  headphone attenuation $79 = 0dB, 1dB per step down
* Change left and right together or the image shifts.
*
* Headphone master — everything, including the synth (wmset 00 xx / 01 xx, 1 dB per step, higher = louder)
* value	cut	how it sounds
* 79	0 dB	loudest possible		K2 (headphone jack)
* 73	−6 dB	a bit quieter		
* 6C	−13 dB	half as loud		Jr2
* 66	−19 dB	quiet		
* 60	−25 dB	very quiet
*
* DAC attenuation — SID, PSG, .mus (wmset 03 xx / 04 xx, 0.5 dB per step, higher = louder)
* value	cut	how it sounds
* FF	0 dB	loudest possible		
* FD	−1 dB	nearly full		Jr2
* F5	−5 dB	a little quieter		
* EB	−10 dB	about half as loud		
* E5	−13 dB	noticeably quieter
* DF	−16 dB	quieter
* D7	−20 dB	quieter still		K2 (headphone jack)
* DB	−18 dB	quiet		
* CB	−26 dB	very quiet
*
* Jr2 balanced on 9/5/2026 with $00/$01 = $6C  03/04 = $FD  
* K2 balanced on 9/5/2026 at the HEADPHONE jack with $00/$01 = $79  03/04 = $D7
*    ($DF first; -20dB after play moved Lyra volume onto CC11 expression, which
*    left .mus a little ahead of .lyr on the K2 headphones)
*    (.mus level with .lyr; synth reaches the K2 mix ~15dB below the Jr2's).
*    K2 RCA (stereo out) NOT tuned - parked. Values live in vtio InitCODEC (K2 block).
*
* What reaches the WM8776's DAC on the K2 (SoundChips2DAC_Interface → audio_out → I2S → CODEC_DAC_BCLK/LRCK/DAT):
* source	core	channels	how it enters the sum
* SID	two 6581 cores (left, right; a "mono" chip-select writes both)	stereo	first term, 16-bit signed
* PSG	SN76489	mono → both	left and right PSG outputs are added together and the same sum fed to both channels
* OPL3	YMF262 core	stereo	third term
*

* Edt/Rev  YYYY/MM/DD  Modified by
* ------------------------------------------------------------------
*   1      2026/09/05  assembled for the wm8776-balance kit

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    org       0
regnum              rmb       1                   register number  0..127
regval              rmb       1                   value to write
size                equ       .

name                fcs       /wmset/
                    fcb       edition

usemsg              fcc       /Usage: wmset <reg> <value>   (hex, e.g. wmset 03 E4)/
                    fcb       C$CR
usemsgl             equ       *-usemsg

* X points at the command line on entry
start               clr       regnum,u
                    clr       regval,u
                    lbsr      SkipSpc
                    cmpa      #C$CR               nothing typed?
                    lbeq      Usage
                    lbsr      GetHex              first argument -> register
                    lbcs      Usage
                    stb       regnum,u
                    lbsr      SkipSpc
                    cmpa      #C$CR               second argument missing?
                    lbeq      Usage
                    lbsr      GetHex              second argument -> value
                    lbcs      Usage
                    stb       regval,u

* Build the 16-bit codec word:
*   bits 15..9 = register, bit 8 = UPDATE, bits 7..0 = value
* so the high byte is (reg<<1)|1 and the low byte is the value.
                    lda       regnum,u
                    anda      #$7F                registers are 7 bits
                    lsla                          reg << 1, leaving bit 0 for UPDATE
                    ora       #$01                set UPDATE so the change takes effect
                    ldb       regval,u
                    ldx       #CODEC.Base
                    lbsr      SendToCODEC
                    clrb
                    os9       F$Exit

* NOTE: global on purpose - the branches cross an os9 call, and the os9
* macro breaks @-local label scope in lwasm (same trap as keydrv_k2).
Usage               leax      usemsg,pcr
                    ldy       #usemsgl
                    lda       #$02                stderr
                    os9       I$WritLn
                    ldb       #$01
                    os9       F$Exit

********************************************************************
* SendToCODEC - same handshake vtio uses: wait for the busy bit to
* clear, load the two halves, then strobe the control register.
SendToCODEC         pshs      d
w@                  lda       CODECCtrl,x
                    lsra
                    bcs       w@
                    puls      d
                    sta       CODECCmdHi,x
                    stb       CODECCmdLo,x
                    lda       #$01
                    sta       CODECCtrl,x
                    rts

********************************************************************
* SkipSpc - advance X past spaces, return the character in A
SkipSpc             lda       ,x
                    cmpa      #C$SPAC
                    bne       ex@
                    leax      1,x
                    bra       SkipSpc
ex@                 rts

********************************************************************
* GetHex - parse up to two hex digits at X into B.  Carry set = bad.
GetHex              clrb
                    lbsr      HexDig
                    bcs       bad@
                    stb       ,-s                 first nybble
                    lbsr      HexDig
                    bcs       one@                only one digit - that is fine
                    lda       ,s+
                    lsla
                    lsla
                    lsla
                    lsla
                    pshs      b
                    ora       ,s+
                    tfr       a,b
                    andcc     #^Carry
                    rts
one@                puls      b
                    andcc     #^Carry
                    rts
bad@                orcc      #Carry
                    rts

* HexDig - one hex digit at X into B, X advanced.  Carry set = not hex.
HexDig              lda       ,x
                    cmpa      #'0
                    blo       no@
                    cmpa      #'9
                    bhi       af@
                    suba      #'0
                    bra       ok@
af@                 anda      #$DF                fold to upper case
                    cmpa      #'A
                    blo       no@
                    cmpa      #'F
                    bhi       no@
                    suba      #'A-10
ok@                 tfr       a,b
                    leax      1,x
                    andcc     #^Carry
                    rts
no@                 orcc      #Carry
                    rts

                    emod
eom                 equ       *
                    end
