* Included in diag; all mutable state is indexed from U.
dispatch            fdb dmatest-dispatch,mathstart-dispatch,fpustart-dispatch
                    fdb psgstart-dispatch,sidstart-dispatch,oplstart-dispatch
                    fdb midistart-dispatch,pcmstart-dispatch,spritestart-dispatch,memtest-dispatch
                    fdb irqstart-dispatch,linestart-dispatch
                    fdb bitmaptest-dispatch,ethstart-dispatch,rtcstart-dispatch
                    fdb wifistart-dispatch,speedstart-dispatch,inputstart-dispatch,mousestart-dispatch
                    fdb inputstart-dispatch     K: N/A (gray, key ignored) off the K2, so no machine check here
descriptions        fdb dmahelp-descriptions,mathhelp-descriptions,fpuhelp-descriptions
                    fdb soundhelp-descriptions,soundhelp-descriptions,soundhelp-descriptions
                    fdb midihelp-descriptions,pcmhelp-descriptions,spritehelp-descriptions,memhelp-descriptions
                    fdb irqhelp-descriptions,linehelp-descriptions
                    fdb bitmaphelp-descriptions,ethhelp-descriptions,rtchelp-descriptions
                    fdb wifihelp-descriptions,speedhelp-descriptions,keyhelp-descriptions,mousehelp-descriptions
                    fdb keyhelp-descriptions
dmahelp             fcc "DMA: fill, copy, OR, AND, XOR, MASK in owned memory; readback."
                    fcb 0
mathhelp            fcc "Integer math: changing operands, hardware vs CPU reference."
                    fcb 0
fpuhelp             fcc "FPU: multiply 2x3, divide 6/4, add 1.5+2.25; exact IEEE results."
                    fcb 0
soundhelp           fcc "Write-only tone output for 2 s, then silenced. Confirm by ear."
                    fcb 0
midihelp            fcc "Channel 1 piano chord: MIDI OUT + SAM2695 for 2 s, then Note Off."
                    fcb 0
soundlive1          fcc "Sound on: it stops by itself after 2 s."
                    fcb 0
soundlive2          fcc "Sound stopped after 2 s."
                    fcb 0
keyhelp             fcc "Keys: each key as the OS delivers it, no PS/2 register read. Esc stops."
                    fcb 0
mousehelp           fcc "OS mouse (SS.Mouse or VICKY X/Y), read only; the PS/2 port is not touched."
                    fcb 0
spritehelp          fcc "32 colored 8x8 sprites bounce in the live view for 5 s, as sprites.asm."
                    fcb 0
memhelp             fcc "Owned 8K RAM walking bits/address patterns, not a full L2 map."
                    fcb 0
linehelp            fcc "Lines: bitmap 0 cleared, a fan of engine lines over the text. Esc ends."
                    fcb 0
bitmaphelp          fcc "Pattern readback in owned RAM, then the Wildbits logo in bitmap 0. Esc ends."
                    fcb 0
settle              pshs x
                    ldx #256
settleloop          leax -1,x
                    bne settleloop
                    puls x,pc
mathstart           ldd #$FFFF
                    std >MATH_MUL_A
                    std >MATH_MUL_B
                    lbsr settle
                    ldd >MATH_MUL_P
                    cmpd #$FFFE
                    lbne mathbad
                    ldd >MATH_MUL_P+2
                    cmpd #1
                    lbne mathbad
                    ldd #1000
                    std >MATH_DIV_SOR
                    ldd #512
                    std >MATH_DIV_END
                    lbsr settle
                    ldd >MATH_DIV_QUOT
                    lbne mathbad
                    ldd >MATH_DIV_REM
                    cmpd #512
                    lbne mathbad
                    ldd #$FFFF
                    std >MATH_ADD_A
                    std >MATH_ADD_A+2
                    clra
                    clrb
                    std >MATH_ADD_B
                    ldd #1
                    std >MATH_ADD_B+2
                    lbsr settle
                    ldd >MATH_ADD_RES
                    lbne mathbad
                    ldd >MATH_ADD_RES+2
                    lbne mathbad
                    lbsr setpass
                    lbra inputstart
mathlive            inc operand+1,u
                    clr operand,u
                    ldd operand,u
                    std >MATH_MUL_A
                    ldd #3
                    std >MATH_MUL_B
                    lbsr settle
                    lda operand+1,u
                    ldb #3
                    mul
                    std expected+2,u
                    ldd >MATH_MUL_P+2
                    std result+2,u
                    cmpd expected+2,u
                    lbne mathbad
                    ldd >MATH_MUL_P
                    lbne mathbad
                    lda vbase,u
                    ldb #3
                    lbsr at
                    leax mathlabel,pcr
                    lbsr putz
                    ldd operand,u
                    lbsr hex16
                    ldd result+2,u
                    lbsr hex16
                    lda operand+1,u
                    anda #63
                    sta col,u
                    lda vbase,u
                    adda #2
                    ldb #3
                    lbsr at
                    ldb #64
mathbar             lda #' '
                    tst col,u
                    beq mathbarout
                    lda #'#'
                    dec col,u
mathbarout          lbsr putchar
                    decb
                    bne mathbar
                    rts
mathbad             clr running,u
                    lbsr setfail
                    leax badmath,pcr
                    lbra message
fpustart            clr memphase,u
                    lbra inputstart
fpulive             clr >FPMATH_CTRL2
                    leax fpuvectors,pcr
                    ldb memphase,u
                    lda #8
                    mul
                    leax d,x
                    ldd ,x
                    std >FPMATH_IN0
                    ldd 2,x
                    std >FPMATH_IN1
                    ldd 4,x
                    std expected,u
                    lda 6,x
                    sta >FPMATH_CTRL0
                    lda 7,x
                    sta >FPMATH_CTRL1
                    clra
                    clrb
                    std >FPMATH_IN0+2
                    std >FPMATH_IN1+2
                    std expected+2,u
                    lda #10
                    sta >FPMATH_CTRL2
                    lbsr settle
                    ldd >FPMATH_OUT
                    std result,u
                    cmpd expected,u
                    bne fpubad
                    ldd >FPMATH_OUT+2
                    std result+2,u
                    bne fpubad
                    lda vbase,u
                    ldb #3
                    lbsr at
                    leax fpulabel,pcr
                    lbsr putz
                    lda memphase,u
                    lbsr hex8
                    ldd result,u
                    lbsr hex16
                    ldd result+2,u
                    lbsr hex16
                    inc memphase,u
                    lda memphase,u
                    cmpa #3
                    blo fpuret
                    clr memphase,u
                    lbsr setpass
fpuret              rts
fpubad              clr running,u
                    lbsr setfail
                    leax badfpu,pcr
                    lbra message
fpuvectors          fdb $4000,$4040,$40C0
                    fcb 0,0
                    fdb $40C0,$4080,$3FC0
                    fcb 0,1
                    fdb $3FC0,$4010,$4070
                    fcb $40,2
* Reject a discontinuous CPU-to-physical span instead of DMAing unrelated RAM.
checkcontiguous     ldx pixbase,u
                    leax 8191,x
                    lbsr physicaladdr
                    ldd physical+1,u
                    addd #8191
                    pshs d
                    lda physical,u
                    adca #0
                    cmpa phys,u
                    puls d
                    bne contiguousbad
                    cmpd phys+1,u
                    bne contiguousbad
                    andcc #$FE
                    rts
contiguousbad       ldb #E$MemFul
                    orcc #1
                    rts
* Use palette entry 14 for the app only; restore foreground/background on exit.
* setpalette (2026-10-09, user: "copy the font into the diag program at build time in case the system being tested
* doesn't have the font or palette"): the system's two text LUTs and font bank 0 are saved, then diag's own palette
* (diagpal.inc, from modules/palette.asm - the core's power-up table) goes into both LUTs and its CP437 font
* (diagfont.inc, from sys/fonts/phoenixegafont.asm) into bank 0. restorepalette puts the system's back.
setpalette          lda #TEXT_LUT_BLK
                    lbsr mapio
                    leax TEXT_LUT_FG,x      the foreground LUT, the background LUT right after it
                    leay lutsave,u
                    ldb #TXT_LUT_SIZE*2
spsave@             lda ,x+
                    sta ,y+
                    decb
                    bne spsave@
                    tst lvl2,u              Level 2: the palette through the console (shadowed per terminal), no font
                    beq mt_spl1
                    lbsr unmap
                    leax diagpal,pcr
                    leay diagpal,pcr
                    lbsr palesc
                    lbsr glyphsin
                    inc paletteowned,u
                    rts
mt_spl1             leax -TXT_LUT_SIZE*2,x
                    leay diagpal,pcr
                    ldb #TXT_LUT_SIZE
spload@             lda ,y+
                    sta TXT_LUT_SIZE,x      the background LUT
                    sta ,x+                 the foreground LUT
                    decb
                    bne spload@
                    lbsr unmap
* The font straight into font memory again (2026-10-10, user: "with rc25 the k2 keyboard stops after 1 keypress
* after exiting diag"): the SS.FntChar route (grfdrv DoFontGetSet) maps the font block into grfdrv's slot 2 and
* sets MMU_MEM_CTRL without putting either back - 768 calls left grfdrv's map changed. Until that call is fixed,
* the font is copied as in 1.1 (mapio, IRQs masked for the copy).
                    lda #FONT_BLK
                    lbsr mapio
                    leax FONT_0_OFFSET,x
                    leay fontsave,u
                    lbsr fontcopy           the system's font out
                    leax -FONT_BANK_SIZE,x
                    tfr x,y
                    leax diagfont,pcr
                    lbsr fontcopy           diag's in
                    lbsr unmap
                    inc paletteowned,u
                    rts
restorepalette      tst paletteowned,u
                    beq palrestret
                    tst lvl2,u
                    beq mt_rpl1
                    leax lutsave,u
                    leay lutsave+TXT_LUT_SIZE,u
                    lbsr palesc
                    lbsr glyphsout
                    clr paletteowned,u
                    rts
mt_rpl1             lda #TEXT_LUT_BLK
                    lbsr mapio
                    leax TEXT_LUT_FG,x
                    leay lutsave,u
                    ldb #TXT_LUT_SIZE*2
rplut@              lda ,y+
                    sta ,x+
                    decb
                    bne rplut@
                    lbsr unmap
                    lda #FONT_BLK
                    lbsr mapio
                    leay FONT_0_OFFSET,x
                    leax fontsave,u
                    lbsr fontcopy
                    lbsr unmap
                    clr paletteowned,u
palrestret          rts
* glyphsin / glyphsout (2026-10-11, multiterminal): Level 2's font is the system's (bannerfont), whose $B3-$C3
* are its own graphics, so the four frame characters taken from there - BoxV2, BoxTR, BoxBR, BoxTeeR - go in
* from diagfont through SS.FntChar on path 0 (font bank 0, which grfdrv keeps per terminal), the system's four
* saved first and put back at exit. The frame's other characters are the same in both fonts. A driver that
* refuses leaves the system font alone.
glyphsin            pshs d,x,y
                    clr glyphsok,u
                    leax fontsave,u         the system's four first
                    leay glyphtab,pcr
mt_gi1              ldb ,y
                    beq mt_gi8
                    pshs y
                    clra
                    tfr d,y                 Y = the character, A = 0: path 0, bank 0
                    ldb #SS.FntChar
                    os9 I$GetStt
                    puls y
                    bcs mt_gi9
                    leax 8,x
                    leay 1,y
                    bra mt_gi1
mt_gi8              leay glyphtab,pcr       then diag's
mt_gi2              ldb ,y
                    beq mt_gi7
                    pshs y
                    lda #8
                    mul
                    leax diagfont,pcr
                    leax d,x
                    ldy ,s
                    ldb ,y
                    clra
                    tfr d,y
                    ldb #SS.FntChar
                    os9 I$SetStt
                    puls y
                    bcs mt_gi9
                    leay 1,y
                    bra mt_gi2
mt_gi7              inc glyphsok,u
mt_gi9              puls d,x,y,pc
glyphsout           pshs d,x,y
                    tst glyphsok,u
                    beq mt_go9
                    leax fontsave,u
                    leay glyphtab,pcr
mt_go1              ldb ,y
                    beq mt_go8
                    pshs y
                    clra
                    tfr d,y
                    ldb #SS.FntChar
                    os9 I$SetStt
                    puls y
                    leax 8,x
                    leay 1,y
                    bra mt_go1
mt_go8              clr glyphsok,u
mt_go9              puls d,x,y,pc
glyphtab            fcb BoxV2,BoxTR,BoxBR,BoxTeeR,0
* palesc (2026-10-11, multiterminal): the text palette through the console - X = 16 foreground entries, Y = 16
* background entries (B, G, R, A each) as 1B 60 / 1B 61 n R G B A, which Level 2 vtio keeps per terminal (GF.Pal:
* the live LUT, or the terminal's buffer when it is in the background)
palesc              pshs d,x,y
                    lda #$60
                    bsr pal16
                    ldx 4,s
                    lda #$61
                    bsr pal16
                    puls d,x,y,pc
* pal16: A = $60 or $61, X = 16 entries: one escape each
pal16               pshs a
                    clrb
mt_p16a             pshs b,x
                    leay linebuf,u
                    lda #VT_ESC
                    sta ,y
                    lda 3,s                 $60 / $61
                    sta 1,y
                    stb 2,y                 the entry
                    lda 2,x                 red
                    sta 3,y
                    lda 1,x                 green
                    sta 4,y
                    lda ,x                  blue
                    sta 5,y
                    lda 3,x                 alpha
                    sta 6,y
                    tfr y,x
                    ldy #7
                    lbsr conwrite
                    puls b,x
                    leax 4,x
                    incb
                    cmpb #16
                    blo mt_p16a
                    puls a,pc
* fontcopy: FONT_BANK_SIZE bytes from X to Y, a word at a time; X and Y advance past them
fontcopy            ldd #FONT_BANK_SIZE/2
fc1@                pshs d
                    ldd ,x++
                    std ,y++
                    puls d
                    subd #1
                    bne fc1@
                    rts
diagpal
                    use diagpal.inc
diagfont
                    use diagfont.inc
                    use diaglogo.asm
* Readback expectations are calculated independently of the DMA destination.
dmatest             lda >DMA.Base+DMA_STATUS_REG
                    lbmi engineblocked
                    clr dmaop,u
                    leax source,u
                    clrb
srcinit             stb ,x+
                    incb
                    bne srcinit
dmaeach             leax destination,u
                    lda #$55
                    clrb
dstinit             sta ,x+
                    decb
                    bne dstinit
                    clr >DMA.Base+DMA_CTRL_REG
                    lda dmaop,u
                    cmpa #4
                    bhi dmafill
                    sta >DMA.Base+DMA_OP_REG
                    leax source,u
                    lbsr physicaladdr
                    lda phys,u
                    sta >DMA.Base+DMA_SOURCE_ADDR_H
                    ldd phys+1,u
                    std >DMA.Base+DMA_SOURCE_ADDR_M
                    lda #DMA_CTRL_Enable
                    bra dmaset
dmafill             clr >DMA.Base+DMA_OP_REG
                    lda #$5A
                    sta >DMA.Base+DMA_FILL_BYTE
                    lda #DMA_CTRL_Enable+DMA_CTRL_Fill
dmaset              sta sndvalue,u
                    leax destination,u
                    lbsr physicaladdr
                    lda phys,u
                    sta >DMA.Base+DMA_DEST_ADDR_H
                    ldd phys+1,u
                    std >DMA.Base+DMA_DEST_ADDR_M
                    ldd #256
                    std >DMA.Base+DMA_SIZE_X_H
                    clr >DMA.Base+DMA_SIZE_Y_H
                    clr >DMA.Base+DMA_SIZE_Y_L
                    lda sndvalue,u
                    sta >DMA.Base+DMA_CTRL_REG
* no completion interrupt (2026-10-10, user: "did you leave it in a state where IRQS were pending"): the status
* is polled, and an INT_DMA that nothing acknowledged stayed pending after diag (keyboard off the rails on the
* Jr2, warm restarts that froze)
                    ora #DMA_CTRL_Start_Trf
                    sta >DMA.Base+DMA_CTRL_REG
                    ldd #120
                    std waitcount,u
                    ldx #2
                    os9 F$Sleep
dmawait             lda >DMA.Base+DMA_STATUS_REG
                    bpl dmacompare
                    lbsr tick
                    ldd waitcount,u
                    subd #1
                    std waitcount,u
                    bne dmawait
                    lbsr setfail
                    lbra engineblocked
* No write to the IRQ controller (2026-10-10): DMA interrupts are never enabled, so INT_DMA is left as it is
dmacompare          clr >DMA.Base+DMA_CTRL_REG
                    leax source,u
                    leay destination,u
                    clr mismatch,u
                    clr mismatch+1,u
                    clrb
dmacmpbyte          lda ,x+
                    pshs b                  stack +0: byte counter
                    ldb dmaop,u
                    beq dmaexpect
                    cmpb #1
                    beq dmaor
                    cmpb #2
                    beq dmaand
                    cmpb #3
                    beq dmaxor
                    cmpb #4
                    beq dmamask
                    lda #$5A
                    bra dmaexpect
dmaor               ora #$55
                    bra dmaexpect
dmaand              anda #$55
                    bra dmaexpect
dmaxor              eora #$55
                    bra dmaexpect
dmamask             sta memgot,u
                    anda #$F0
                    bne masklow
                    lda memgot,u
                    ora #$50
                    sta memgot,u
masklow             lda memgot,u
                    anda #$0F
                    bne maskdone
                    lda memgot,u
                    ora #5
                    sta memgot,u
maskdone            lda memgot,u
dmaexpect           cmpa ,y+
                    beq dmanextbyte
                    ldd mismatch,u
                    addd #1
                    std mismatch,u
dmanextbyte         puls b
                    decb
                    bne dmacmpbyte
                    lda vbase,u
                    adda dmaop,u
                    ldb #3
                    lbsr at
                    leax dmalabel,pcr
                    lbsr putz
                    lda dmaop,u
                    lbsr hex8
                    ldd mismatch,u
                    lbsr hex16
                    ldd mismatch,u
                    bne dmabad
                    inc dmaop,u
                    lda dmaop,u
                    cmpa #6
                    lblo dmaeach
                    clr >DMA.Base+DMA_OP_REG
                    lbsr setpass
                    lbra dmapreview
dmabad              clr >DMA.Base+DMA_OP_REG
                    lbra setfail
engineblocked       leax enginebusy,pcr
                    lbra message
dmapreview          leax destination,u
                    lda vbase,u
                    adda #DmaPrevOff
                    sta row,u
                    ldb #4
dmapreviewrow       pshs b,x
                    lda row,u
                    ldb #3
                    lbsr at
                    puls b,x
                    pshs b
                    ldb #16
dmapreviewbyte      lda ,x+
                    lbsr hex8
                    lda #' '
                    lbsr putchar
                    decb
                    bne dmapreviewbyte
                    inc row,u
                    puls b
                    decb
                    bne dmapreviewrow
                    rts
* listen (2026-10-10, user: "the sounds need to stop after 2 seconds and not require a manual stop"): the sound
* runs SoundTicks main-loop passes, then soundlive silences it; its live line says so
listen              lda #4
                    lbsr setstatus
                    lda #1
                    sta running,u
                    sta soundon,u
                    lda selection,u
                    sta soundchoice,u
                    lda #SoundTicks
                    sta soundleft,u
                    lda vbase,u
                    lbsr clearrow
                    leax soundlive1,pcr
                    lbra putz
* soundlive: one main-loop pass of a sound test; the last one silences it
soundlive           dec soundleft,u
                    bne sndl1@
                    lbsr stopsound
                    clr running,u
                    leax soundlive2,pcr
                    lbra message
sndl1@              rts
psgstart            lda #$8C
                    sta >PSG_BOTH_PORT
                    lda #$11
                    sta >PSG_BOTH_PORT
                    lda #$92
                    sta >PSG_BOTH_PORT
                    lbra listen
sidstart            lda #$18
                    ldb #15
                    lbsr sidwrite
                    lda #0
                    ldb #$D6
                    lbsr sidwrite
                    lda #1
                    ldb #$1C
                    lbsr sidwrite
                    lda #5
                    ldb #$09
                    lbsr sidwrite
                    lda #6
                    ldb #$F0
                    lbsr sidwrite
                    lda #4
                    ldb #$11
                    lbsr sidwrite
                    lbra listen
sidwrite            pshs cc
                    orcc #IntMasks
                    ora #SID_SELECT_BOTH
                    sta >SID_SELECT_PORT
                    stb >SID_DATA_PORT
                    puls cc,pc
oplstart            leax oplinit,pcr
oplinitloop         lda ,x+
                    cmpa #$FF
                    beq oplready
                    ldb ,x+
                    pshs x
                    lbsr oplwrite
                    puls x
                    bra oplinitloop
oplready            lbra listen
oplwrite            sta >OPL3_ADDR0_PORT
                    pshs b
                    lbsr settle
                    puls b
                    stb >OPL3_DATA0_PORT
                    lbsr settle
                    rts
* U PCM (2026-10-10, user: "add a stereo PCM tone test to diag"): the rc25 stereo PCM output - a tone on the left,
* then the right, then both, about two seconds in all, then silence. Software timed (a counted delay per half
* wave), so the pitch follows the CPU speed; Ready ($FF9E bit 0) is polled before every sample. A core without the
* registers never shows Ready and the test says so. The names are local: wildbits.d has no PCM entries yet.
PcmLeftH            equ $FF9A               left sample, high byte (staged)
PcmRightH           equ $FF9C               right sample, high byte; each low byte follows its high byte
PcmStatus           equ $FF9E               bit 0: Ready
PcmReady            equ %00000001
PcmAmp              equ $2000               a quarter of full scale
PcmHalfL            equ 900                 delay loops per half wave: left (the lower tone)
PcmHalfR            equ 600                 right
PcmHalfB            equ 750                 both
PcmCountL           equ 700                 half waves per tone
PcmCountR           equ 1050
PcmCountB           equ 840
pcmstart            ldb #100
pcm_pcs1            lda >PcmStatus          Ready within 100 polls?
                    bita #PcmReady
                    bne pcm_pcs2
                    decb
                    bne pcm_pcs1
                    lbsr setfail
                    leax pcmabsent,pcr
                    lbra message
pcm_pcs2            lda #1                  left
                    ldx #PcmHalfL
                    ldy #PcmCountL
                    lbsr pcmtone
                    lda #2                  right
                    ldx #PcmHalfR
                    ldy #PcmCountR
                    lbsr pcmtone
                    lda #3                  both
                    ldx #PcmHalfB
                    ldy #PcmCountB
                    lbsr pcmtone
                    clra
                    clrb
                    lbsr pcmboth            silence
                    lda #4                  LISTEN
                    lbsr setstatus
                    leax pcmplayed,pcr
                    lbra message
* pcmtone: A = channels (1 left, 2 right, 3 both), X = delay loops per half wave, Y = half waves: a square wave
pcmtone             sta pcmmask,u
                    stx pcmhalf,u
                    ldd #PcmAmp
                    std pcmlevel,u
pcm_pt1             ldd pcmlevel,u          the next half wave's level, the sign flipped
                    coma
                    comb
                    addd #1
                    std pcmlevel,u
                    lda pcmmask,u
                    bita #1
                    beq pcm_pt2
                    ldd pcmlevel,u
                    ldx #PcmLeftH
                    lbsr pcmput
pcm_pt2             lda pcmmask,u
                    bita #2
                    beq pcm_pt3
                    ldd pcmlevel,u
                    ldx #PcmRightH
                    lbsr pcmput
pcm_pt3             ldx pcmhalf,u
pcm_pt4             leax -1,x
                    bne pcm_pt4
                    leay -1,y
                    bne pcm_pt1
                    rts
* pcmboth: D on both channels
pcmboth             ldx #PcmLeftH
                    lbsr pcmput
                    ldx #PcmRightH
* pcmput: D = a sample, X = its channel's high-byte register: Ready waited for, then high and low. Keeps D, X, Y.
pcmput              pshs a
pcm_pp1             lda >PcmStatus
                    bita #PcmReady
                    beq pcm_pp1
                    puls a
                    sta ,x
                    stb 1,x
                    rts
pcmhelp             fcc "PCM stereo (rc25): left tone, right tone, both, then silence. Listen."
                    fcb 0
pcmabsent           fcc "PCM: no Ready at $FF9E - this core has no PCM output (rc25+)."
                    fcb 0
pcmplayed           fcc "PCM: left, right and both tones played - confirm by ear."
                    fcb 0
midistart           leax midion,pcr
                    lbsr sendmidi
                    bcs midifail
                    lbra listen
midifail            lbsr setfail
                    leax midibusy,pcr
                    lbra message
sendmidi            ldb ,x+
                    pshs b,x               +0 count, +1 pointer, preserved across sleeps
                    ldd #120
                    std waitcount,u
midiwait            lda >MIDI.Base+MIDI_CTRL
                    bita #MIDI.TxEmpty
                    bne midisend
                    lbsr tick
                    ldd waitcount,u
                    subd #1
                    std waitcount,u
                    bne midiwait
                    puls b,x
                    orcc #1
                    rts
midisend            puls b,x
midibyte            lda ,x+
                    sta >MIDI.Base+MIDI_DATA
                    decb
                    bne midibyte
                    andcc #$FE
                    rts
stopsound           tst soundon,u
                    beq soundoffret
                    lda soundchoice,u
                    cmpa #3
                    beq psgstop
                    cmpa #4
                    beq sidstop
                    cmpa #5
                    beq oplstop
                    leax midioff,pcr
                    lbsr sendmidi
                    bcs soundoffret         retain ownership if Note Off wasn't sent
                    clr soundon,u
                    rts
psgstop             lda #$9F
                    sta >PSG_BOTH_PORT
                    clr soundon,u
                    rts
sidstop             lda #4
                    clrb
                    lbsr sidwrite
                    clr soundon,u
                    rts
oplstop             lda #$B0
                    clrb
                    lbsr oplwrite
                    clr soundon,u
soundoffret         rts
* P and K (2026-10-10, user: "ps/2 keyboard test should do the same" as M): the keys come through the OS alone
* (the main loop's I$Read); diag reads no PS/2 register. A line is drawn when a key arrives, not every pass. K
* adds the K2 optical keyboard controller's status and count (its own registers, not PS/2).
inputstart          lda keycount,u          the first pass draws
                    deca
                    sta kdrawn,u
                    lda #1
                    sta running,u
                    lda #3
                    lbra setstatus
inputlive           lda keycount,u
                    cmpa kdrawn,u
                    beq inputret            no new key: nothing drawn
                    sta kdrawn,u
                    lda vbase,u
                    ldb #3
                    lbsr at
                    leax inputlabel,pcr
                    lbsr putz
                    lda lastkey,u
                    lbsr hex8
                    leax inputcount,pcr
                    lbsr putz
                    lda keycount,u
                    lbsr hex8
                    lda selection,u
                    cmpa #TestK2Keys
                    bne inputret
                    leax inputk2,pcr
                    lbsr putz
                    lda >OKB.Base+OKB.Stat
                    lbsr hex8
                    lda >OKB.Base+OKB.CntHi
                    lbsr hex8
                    lda >OKB.Base+OKB.CntLo
                    lbsr hex8
inputret            rts
* N IRQ loopback (2026-10-10, user: "if there's a way to trigger an irq by some loopback mechanism than that's the
* way to test, just for one tick per whatever irq you can trigger"). Five sources diag can fire itself, each on its
* own line: Timer 0 (the I/O clock), Timer 1 (frames), DMA completion, the RTC's periodic interrupt and VIA0's
* timer 1. A source the OS has unmasked is its own (its handler acknowledges it) and is left alone. A masked one
* is armed, its pending bit cleared (one write) and seen clear, fired, read again after its ticks, then put back
* as it was and its pending bit cleared again (one write). The controller is never polled in a loop.
TmrEnable           equ %00000001               timer control (TimerInterfaceJr.v): count
TmrClear            equ %00000010               hold the counter at 0
TmrUp               equ %00001000               count up
TmrCmpCtl           equ T0_CMP_CTR-T0_CTR       the compare control register (0: no clear or reload on a match)
TmrCmp              equ T0_CMP-T0_CTR           the compare value, high byte first
ViaT1Bit            equ %01000000               VIA IER/IFR: timer 1
ViaSetBit           equ %10000000               VIA IER: set the bits written (clear when 0)
RtcPIE              equ %00000100               bq4802 enables: periodic interrupt
RtcRate             equ %00001001               bq4802 rates RS3-RS0: a 7.8125 ms period
IrqStuckWait        equ 30                      DMA: ticks allowed for the fill to finish
* irqsources: group, bit, ticks to wait, then the label, arm, fire and stop routines (offsets from irqsources)
IsGroup             equ 0
IsBit               equ 1
IsTicks             equ 2
IsLabel             equ 3
IsArm               equ 5
IsFire              equ 7
IsStop              equ 9
IsEntry             equ 11
irqsources          fcb 0,INT_TIMER_0,2
                    fdb irqlt0-irqsources,tmr0arm-irqsources,tmr0fire-irqsources,tmr0stop-irqsources
                    fcb 0,INT_TIMER_1,5
                    fdb irqlt1-irqsources,tmr1arm-irqsources,tmr1fire-irqsources,tmr1stop-irqsources
                    fcb 0,INT_DMA,2
                    fdb irqldma-irqsources,dmairqarm-irqsources,dmairqfire-irqsources,dmairqstop-irqsources
                    fcb 1,INT_RTC,3
                    fdb irqlrtc-irqsources,rtcirqarm-irqsources,rtcirqfire-irqsources,rtcirqstop-irqsources
                    fcb 1,INT_VIA0,2
                    fdb irqlvia-irqsources,via0arm-irqsources,via0fire-irqsources,via0stop-irqsources
                    fcb $FF
irqstart            clr chkerrs,u
                    clr chkfail,u
                    clr chkfail+1,u
                    clr irqidx,u
                    leay irqsources,pcr
irs1@               lda ,y
                    cmpa #$FF
                    beq irs9@
                    sty irqent,u
                    lbsr irqone
                    ldy irqent,u
                    leay IsEntry,y
                    inc irqidx,u
                    bra irs1@
irs9@               tst chkerrs,u
                    bne irqfailed
                    lbsr setpass
                    leax irqok,pcr
                    lbra message
irqfailed           lbsr setfail
                    leax irqbad,pcr
                    lbra failsum
* irqone: irqent = a source's entry: its line, then the loopback when the source is masked
irqone              ldy irqent,u
                    ldd IsLabel,y
                    leax irqsources,pcr
                    leax d,x
                    lda vbase,u
                    adda irqidx,u
                    lbsr chkline
                    ldy irqent,u
                    lda IsGroup,y
                    sta irqgrp,u
                    lda IsBit,y
                    sta irqbit,u
                    leax irqgmsg,pcr            "G0 $10 "
                    lbsr putz
                    lda irqgrp,u
                    adda #'0
                    lbsr putchar
                    leax irqdollar,pcr
                    lbsr putz
                    lda irqbit,u
                    lbsr hex8
                    lda #' '
                    lbsr putchar
                    ldx #INT_MASK_0
                    ldb irqgrp,u
                    lda b,x
                    bita irqbit,u
                    bne io1@
                    leax irqosmsg,pcr           unmasked: the OS's, not touched
                    lbra putz
io1@                ldb #IsArm
                    lbsr irqcall
                    lbsr tick
                    lbsr irqclear
                    lbsr irqread
                    beq io2@
                    inc chkerrs,u               still pending after the clear: stuck
                    leax irqstuck,pcr
                    bra io4@
io2@                ldb #IsFire
                    lbsr irqcall
                    ldy irqent,u
                    ldb IsTicks,y
io3@                lbsr tick
                    decb
                    bne io3@
                    leax irqfired,pcr
                    lbsr irqread                keeps X
                    bne io4@
                    inc chkerrs,u
                    leax irqnever,pcr
io4@                lbsr putz
                    ldb #IsStop
                    lbsr irqcall
                    lbsr tick
                    lbsr irqclear
                    lbra chkverdict
* irqcall: B = IsArm, IsFire or IsStop: that routine of the source at irqent
irqcall             pshs b
                    ldy irqent,u
                    ldd b,y
                    leax irqsources,pcr
                    leax d,x
                    puls b
                    jmp ,x
* irqclear: the source's pending bit written (cleared); irqread: Z clear when it is pending
irqclear            ldx #INT_PENDING_0
                    ldb irqgrp,u
                    lda irqbit,u
                    sta b,x
                    rts
irqread             pshs x
                    ldx #INT_PENDING_0
                    ldb irqgrp,u
                    lda b,x
                    anda irqbit,u
                    puls x,pc
* The timers: armed held at 0 with a compare value ahead; fired by counting up; stopped back at reset (0, 0)
tmr0arm             ldx #T0_CTR
                    ldd #$1000                  4,096 I/O clocks
                    bra tmrarm
tmr1arm             ldx #T1_CTR
                    ldd #2                      two frames
tmrarm              pshs d
                    lda #TmrClear
                    sta ,x
                    clr TmrCmpCtl,x
                    clr TmrCmp,x
                    puls d
                    std TmrCmp+1,x
                    rts
tmr0fire            ldx #T0_CTR
                    bra tmrfire
tmr1fire            ldx #T1_CTR
tmrfire             lda #TmrEnable+TmrUp
                    sta ,x
                    rts
tmr0stop            ldx #T0_CTR
                    bra tmrstop
tmr1stop            ldx #T1_CTR
tmrstop             lda #TmrClear
                    sta ,x
                    clr ,x
                    clr TmrCmp,x
                    clr TmrCmp+1,x
                    clr TmrCmp+2,x
                    rts
* DMA: a 256-byte fill of the owned destination buffer with its completion interrupt enabled, waited for, then
* the engine cleared (the interrupt line drops then if it is held)
dmairqarm           clr >DMA.Base+DMA_CTRL_REG
                    rts
dmairqfire          lda >DMA.Base+DMA_STATUS_REG
                    bmi dif9@                   busy: never started (the read then finds nothing)
                    clr >DMA.Base+DMA_OP_REG
                    lda #$5A
                    sta >DMA.Base+DMA_FILL_BYTE
                    leax destination,u
                    lbsr physicaladdr
                    lda phys,u
                    sta >DMA.Base+DMA_DEST_ADDR_H
                    ldd phys+1,u
                    std >DMA.Base+DMA_DEST_ADDR_M
                    ldd #256
                    std >DMA.Base+DMA_SIZE_X_H
                    clr >DMA.Base+DMA_SIZE_Y_H
                    clr >DMA.Base+DMA_SIZE_Y_L
                    lda #DMA_CTRL_Enable+DMA_CTRL_Fill+DMA_CTRL_Int_En
                    sta >DMA.Base+DMA_CTRL_REG
                    ora #DMA_CTRL_Start_Trf
                    sta >DMA.Base+DMA_CTRL_REG
                    ldb #IrqStuckWait
dif1@               lda >DMA.Base+DMA_STATUS_REG
                    bpl dif2@
                    lbsr tick
                    decb
                    bne dif1@
dif2@               clr >DMA.Base+DMA_CTRL_REG
dif9@               rts
dmairqstop          clr >DMA.Base+DMA_CTRL_REG
                    rts
* The RTC: the periodic interrupt at 7.8 ms, its rates and enables put back after, the flags read (cleared)
rtcirqarm           ldx #RTC.Base
                    lda RTC_RATES,x
                    sta irqsave,u
                    lda RTC_ENABLE,x
                    sta irqsave+1,u
                    anda #^RtcPIE
                    sta RTC_ENABLE,x
                    lda irqsave,u
                    anda #$F0                   the watchdog bits kept
                    ora #RtcRate
                    sta RTC_RATES,x
                    lda RTC_FLAGS,x             PF cleared
                    rts
rtcirqfire          ldx #RTC.Base
                    lda RTC_ENABLE,x
                    ora #RtcPIE
                    sta RTC_ENABLE,x
                    rts
rtcirqstop          ldx #RTC.Base
                    lda irqsave+1,u
                    sta RTC_ENABLE,x
                    lda irqsave,u
                    sta RTC_RATES,x
                    lda RTC_FLAGS,x
                    rts
* VIA0: timer 1 one-shot (4,096 clocks) with its interrupt enabled; ACR and the timer's enable put back after
via0arm             ldx #VIA0.Base
                    lda VIA_IER,x
                    sta irqsave,u
                    lda VIA_ACR,x
                    sta irqsave+1,u
                    lda #ViaT1Bit               timer 1's interrupt off
                    sta VIA_IER,x
                    lda irqsave+1,u
                    anda #$3F                   timer 1 one-shot, PB7 untouched by it
                    sta VIA_ACR,x
                    lda VIA_T1CL,x              its flag cleared
                    rts
via0fire            ldx #VIA0.Base
                    clr VIA_T1CL,x
                    lda #$10
                    sta VIA_T1CH,x              loads and starts timer 1
                    lda #ViaSetBit+ViaT1Bit
                    sta VIA_IER,x
                    rts
via0stop            ldx #VIA0.Base
                    lda #ViaT1Bit
                    sta VIA_IER,x
                    lda VIA_T1CL,x
                    lda irqsave+1,u
                    sta VIA_ACR,x
                    lda irqsave,u
                    anda #ViaT1Bit
                    beq vs9@
                    ora #ViaSetBit
                    sta VIA_IER,x
vs9@                rts
irqhelp             fcc "Each masked IRQ source fired once: timers, DMA, RTC, VIA0; then restored."
                    fcb 0
irqlt0              fcc "Timer 0 (I/O clock)  "
                    fcb 0
irqlt1              fcc "Timer 1 (frames)     "
                    fcb 0
irqldma             fcc "DMA completion       "
                    fcb 0
irqlrtc             fcc "RTC periodic         "
                    fcb 0
irqlvia             fcc "VIA0 timer 1         "
                    fcb 0
irqgmsg             fcc "group "
                    fcb 0
irqdollar           fcc " bit $"
                    fcb 0
irqosmsg            fcc "unmasked: the OS's own, not fired"
                    fcb 0
irqstuck            fcc "stuck: still pending after a clear "
                    fcb 0
irqfired            fcc "fired, cleared "
                    fcb 0
irqnever            fcc "never fired "
                    fcb 0
irqok               fcc "IRQ: every masked source fired once and was put back."
                    fcb 0
irqbad              fcc "IRQ: FAIL - "
                    fcb 0
* Two walking-bit polarities and address signatures in owned memory only.
memtest             clr memphase,u
                    clr mismatch,u
                    clr mismatch+1,u
memround            ldx pixbase,u
                    ldy #8192
memfill             lbsr mempattern
                    sta ,x+
                    leay -1,y
                    bne memfill
                    ldx pixbase,u
                    ldy #8192
memcheck            lbsr mempattern
                    cmpa ,x+
                    beq memchecknext
                    ldd mismatch,u
                    addd #1
                    std mismatch,u
memchecknext        leay -1,y
                    bne memcheck
                    inc memphase,u
                    lda memphase,u
                    cmpa #17
                    blo memround
                    ldd mismatch,u
                    bne memfailed
                    lbsr setpass
                    leax memok,pcr
                    lbra message
memfailed           lbsr setfail
                    leax memfailmsg,pcr
                    lbra message
mempattern          pshs b
                    ldb memphase,u
                    cmpb #16
                    beq memaddress
                    andb #7
                    lda #1
memshift            tstb
                    beq mempolarity
                    lsla
                    decb
                    bra memshift
mempolarity         ldb memphase,u
                    bitb #8
                    beq mempatternret
                    coma
                    bra mempatternret
memaddress          tfr x,d
                    pshs b                  stack +0: address low byte
                    eora ,s+
                    eora #$A5
mempatternret       puls b,pc
* M Mouse (2026-10-10, user: "the diag Mouse test 100% messes up the IRQ/PS2 sequence, mouse is out of sync now";
* "FIX THIS BUG IMMEDIATELY!!"): diag never touches the PS/2 port - no command to the mouse, no MS_IN read. A byte
* sent or taken behind the mouse driver misframes its 3-byte packets for good (it never resyncs). The position
* comes from the OS: SS.Mouse, or, where that call is missing, the X/Y the driver keeps in VICKY (read only).
* The grid is drawn once; after that only a change is drawn - the status line and the two rows the X left and
* entered - so the console (grfdrv, IRQs masked while it draws) is not rewriting 20 lines every pass.
* mouseos: SS.Mouse (X and Y in pixels, A = buttons) -> mousex, mousey on the grid, result = buttons. Carry: no
* SS.Mouse.
mouseos             pshs u
                    lda #1
                    ldb #SS.Mouse
                    os9 I$GetStt
                    puls u
                    bcs mouseno
mouseset            sta result,u            A = buttons, X and Y = the position in pixels
                    pshs y
                    lda #MouseXDiv
                    lbsr wsdiv16x8
                    tfr x,d
                    cmpd #MouseCols-1
                    bls mo1@
                    ldd #MouseCols-1
mo1@                std mousex,u
                    puls x
                    lda #MouseYDiv
                    lbsr wsdiv16x8
                    tfr x,d
                    cmpd #MouseRows-1
                    bls mo2@
                    ldd #MouseRows-1
mo2@                std mousey,u
                    andcc #^1
mouseno             rts
* mousevicky: the position the OS mouse driver keeps in VICKY (MS_XH-MS_YL), read only; no buttons
mousevicky          ldx >MS_XH
                    ldy >MS_YH
                    clra
                    bra mouseset
* mouseread: the position by whichever way mousestart found
mouseread           tst mouseosok,u
                    beq mousevicky
                    lbsr mouseos
                    bcc mr9@
                    clr mouseosok,u         SS.Mouse stopped answering: VICKY from now on
                    bra mousevicky
mr9@                rts
MouseCols           equ 64                  the grid: 64 x 20 cells over the 640 x 480 screen
MouseRows           equ 20
MouseXDiv           equ 640/MouseCols
MouseYDiv           equ 480/MouseRows
mousestart          clr result,u
                    clr mouseosok,u
                    lbsr mouseos
                    bcs ms1@
                    inc mouseosok,u         1: SS.Mouse; 0: VICKY's registers
                    bra ms2@
ms1@                lbsr mousevicky
ms2@                lbsr mousestat
                    clra
ms3@                lbsr mouserow           the whole grid, once
                    inca
                    cmpa #MouseRows
                    blo ms3@
                    lbra inputstart
mouselive           ldd mousex,u
                    std mprevx,u
                    ldd mousey,u
                    std mprevy,u
                    lda result,u
                    sta mprevb,u
                    lbsr mouseread
                    ldd mousex,u
                    cmpd mprevx,u
                    bne ml1@
                    ldd mousey,u
                    cmpd mprevy,u
                    bne ml1@
                    lda result,u
                    cmpa mprevb,u
                    bne ml1@
                    rts                     nothing moved: nothing drawn
ml1@                lbsr mousestat
                    lda mprevy+1,u          the row the X left
                    lbsr mouserow
                    lda mousey+1,u          and the row it is on
                    lbra mouserow
* mousestat: the status line (the position in grid cells, the buttons)
mousestat           pshs d,x
                    lda vbase,u
                    ldb #3
                    lbsr at
                    leax mousestatus,pcr
                    lbsr putz
                    ldd mousex,u
                    lbsr hex16
                    ldd mousey,u
                    lbsr hex16
                    lda result,u
                    anda #7
                    lbsr hex8
                    puls d,x,pc
* mouserow: A = a grid row (0 to MouseRows-1): drawn, with the X when the mouse is on it. Keeps A.
mouserow            pshs a,b,x,y
                    leax linebuf,u
                    ldb #MouseCols
                    lda #'.'
mrw1@               sta ,x+
                    decb
                    bne mrw1@
                    lda ,s
                    cmpa mousey+1,u
                    bne mrw2@
                    leax linebuf,u
                    ldb mousex+1,u
                    lda #'X'
                    sta b,x
mrw2@               lda ,s
                    adda vbase,u
                    adda #MouseGridOff
                    ldb #3
                    lbsr at
                    leax linebuf,u
                    ldy #MouseCols
                    lbsr conwrite
                    puls a,b,x,y,pc
* restoregraphics: L's display put back through the OS - the engine stopped, the line-write enable as found, the
* master control as found (SS.DScrn), bitmap 0's CLUT as found (SS.Palet), bitmap 0 freed (SS.FScrn) if L
* allocated it. The layers are never touched.
restoregraphics     tst gfxowned,u
                    lbeq gfxrestret
                    tst lvl2,u              Level 2: the driver owns the engine and its enable
                    bne rg_l2
                    lda #BITMAP_BLK
                    lbsr mapio
                    clr TyVKY_LD_OFFSET,x
                    lbsr unmap
                    lda oldline,u
                    sta >VKY_DRAWLINE_REG
rg_l2               lda gfxmcr,u
                    ldb gfxmcr+1,u
                    lbsr gfxmcrset
                    tst lvl2,u              Level 2: layer 0 back to its own source
                    beq mt_rg1
                    pshs u
                    ldb gfxlay0,u
                    clra
                    tfr d,y
                    ldx #0
                    lda #1
                    ldb #SS.PScrn
                    os9 I$SetStt
                    puls u
mt_rg1              lbsr bgrestore
                    pshs u                  bitmap 0 back on its own CLUT
                    lda gfxbmctl,u
                    lsra
                    anda #3
                    tfr a,b
                    clra
                    tfr d,x
                    ldy #LineBM
                    lda #1
                    ldb #SS.Palet
                    os9 I$SetStt
                    puls u
                    tst gfxalloc,u
                    beq rg_rg9
                    pshs u
                    lda #1
                    ldb #SS.FScrn
                    ldy #LineBM
                    os9 I$SetStt
                    puls u
rg_rg9              clr gfxowned,u
gfxrestret          rts
* gfxmcrget: A = VICKY master control low byte, B = high, from the OS (GetStat SS.DScrn). Keeps X and Y.
gfxmcrget           pshs x,y
                    pshs u
                    lda #1
                    ldb #SS.DScrn
                    os9 I$GetStt
                    puls u
                    tfr x,d                 B = the low byte
                    pshs b
                    tfr y,d                 B = the high byte
                    puls a
                    puls x,y,pc
* gfxmcrset: A = master control low byte, B = high, through the OS (SetStat SS.DScrn). Keeps D, X and Y.
gfxmcrset           pshs d,x,y,u
                    tfr a,b
                    clra
                    tfr d,x
                    ldb 1,s
                    clra
                    tfr d,y
                    lda #1
                    ldb #SS.DScrn
                    os9 I$SetStt
                    puls d,x,y,u,pc
lineidle            lda #BITMAP_BLK
                    lbsr mapio
                    lda TyVKY_LD_OFFSET,x
                    sta memgot,u
                    ldd TyVKY_LD_OFFSET+2,x
                    std pixelcount,u
                    lbsr unmap
                    ldd pixelcount,u
                    bne lineisbusy
                    lda memgot,u
                    bita #TyVKY_LD_GO
                    beq lineisidle
                    bita #TyVKY_LD_DONE
                    bne lineisidle
lineisbusy          orcc #1
                    rts
lineisidle          andcc #$FE
                    rts
* L lines (2026-10-10, user: "for the lines test, enable bitmap layer 1 and draw a sequence of lines inside the view
* port area so it blends with the text page, do not use direct hardware registers for requesting the bitmap and
* sprites layers"; then "scratch the layer re-order efforts", "draw lines on bitmap 0, cleared first"). The display
* goes through the OS, Level 1 and Level 2 alike: SS.AScrn gives bitmap 0 (320 x 240) and its first block - or,
* when it already exists (E$WADef), that block - SS.DfPal and SS.Palet give it diag's colors on CLUT 3, SS.DScrn
* turns on graphics, bitmaps and the text overlay. The layers are left as they are. Bitmap 0 is cleared by a DMA
* 2D fill, then the line engine draws a fan of lines into it (control selects BM0 - no bitmap register is written)
* inside the live view's rows and columns. The lines stay until the test stops (Esc); restoregraphics then puts
* the display back. Bitmap 0's control byte is READ once (GetStat SS.Palet returns nothing) so its CLUT can be put
* back.
LineBM              equ 0                   the bitmap L draws in
LineClut            equ 3                   its CLUT
LineLines           equ 16                  lines in the fan
LineX0              equ 8                   the fan's corner: column 2 of the text, the view's first row
LineY0              equ ViewTop*4
LineY1              equ ViewBot*4+3         the view's last row (a text row is 4 bitmap lines)
LineXStep           equ 20                  the fan's ends, 20 pixels apart
LineX1              equ 77*4+3              the view's last dot: column 77's last (the border's right side)
LineBorder          equ 4                   white border lines after the fan (linetab)
linestart           tst lvl2,u
                    bne ln_ls1
                    lbsr lineidle
                    bcc ln_ls1
                    lbra engineblocked
ln_ls1              lbsr bgbitmap
                    lbcs lsfail2
                    lbra ln_draw
* bgbitmap (2026-10-11, user: "the S and L tests clear the bg black. I needed it to be the same bg as Diag (blue)"):
* bitmap 0 through the OS for L, and on Level 2 for S as a backdrop - SS.AScrn (or the bitmap already there), its
* control byte, diag's 16 colors on CLUT 3, cleared, and on Level 2 put on layer 0. Level 2 has no call for VICKY's
* graphics background color, so there the bitmap is cleared to ColBack (diag's blue) and shows behind the overlaid
* text; Level 1 clears it to 0 and bgset colors the background as before. The master control is NOT changed here.
* Carry: X = the message (no bitmap, or the clear did not finish); restoregraphics undoes what was done.
bgbitmap            clr gfxalloc,u          (before the call: clr would clear its carry)
                    pshs u                  bitmap 0, 320 x 240
                    lda #1
                    ldb #SS.AScrn
                    ldx #0
                    ldy #LineBM
                    os9 I$SetStt
                    puls u
                    bcc ln_ls2
                    cmpb #E$WADef           already there: X is its first block, it stays allocated
                    beq ln_ls3
                    leax linenobm,pcr
                    orcc #1
                    rts
ln_ls2              inc gfxalloc,u          L allocated it: SS.FScrn at the end
ln_ls3              stx gfxblk,u
                    lbsr gfxmcrget
                    sta gfxmcr,u
                    stb gfxmcr+1,u
                    tst lvl2,u
                    beq ln_l1a
                    pshs u                  Level 2: bitmap 0's control byte from the driver's mirror (SS.BmBlk)
                    lda #1
                    ldb #SS.BmBlk
                    ldy #LineBM
                    os9 I$GetStt
                    puls u
                    bcc ln_l2a
                    lda #1                  no answer: enabled, CLUT 0
ln_l2a              sta gfxbmctl,u
* Level 2 starts every terminal with all three layers blank (grfdrv DispRegs / GF.TermNew: source 7), so a
* bitmap shows only when a layer points at it (2026-10-11, user: "Lines test not working in multi-term (vt) 1st
* or 2nd window"). Layer 0's source is read once (read only - the driver has no getter) to put it back on stop.
                    lda >VKY_LAYER_CTRL_0
                    anda #7
                    sta gfxlay0,u
                    bra ln_l1b
ln_l1a              lda #BITMAP_BLK         bitmap 0's control byte as found (read only): its CLUT
                    lbsr mapio
                    lda $1000,x
                    sta gfxbmctl,u
                    lbsr unmap
                    lda >VKY_DRAWLINE_REG
                    sta oldline,u
ln_l1b              equ *
                    inc gfxowned,u          from here on restoregraphics puts it all back
* diag's 16 colors into CLUT 3 (a 1 KB table built in pixraw; entries 16-255 black) and bitmap 0 onto it
                    ldx pixbase,u
                    leay diagpal,pcr
                    ldb #TXT_LUT_SIZE
ln_lsc1             lda ,y+
                    sta ,x+
                    decb
                    bne ln_lsc1
                    leay logopal,pcr        the logo's colors from entry LogoBase (2026-10-11)
                    ldb #LogoColors*4
ln_lsc3             lda ,y+
                    sta ,x+
                    decb
                    bne ln_lsc3
                    ldd #1024-TXT_LUT_SIZE-LogoColors*4
ln_lsc2             clr ,x+
                    subd #1
                    bne ln_lsc2
                    pshs u
                    ldx #LineClut
                    ldy pixbase,u
                    lda #1
                    ldb #SS.DfPal
                    os9 I$SetStt
                    ldx #LineClut
                    ldy #LineBM
                    lda #1
                    ldb #SS.Palet
                    os9 I$SetStt
                    puls u
* bitmap 0 cleared: a DMA 2D fill, 320 x 240 (color 0 on Level 1, ColBack on Level 2)
                    lbsr lineclear
                    bcc ln_bg1
                    leax lineclrbad,pcr
                    rts
ln_bg1              tst lvl2,u
                    beq ln_bg2
                    pshs u                  Level 2: bitmap 0 on layer 0 (SS.PScrn / SS.Layer)
                    ldx #0
                    ldy #LineBM
                    lda #1
                    ldb #SS.PScrn
                    os9 I$SetStt
                    puls u
ln_bg2              andcc #^1
                    rts
* on screen: graphics, bitmaps, and the text over them
ln_draw             equ *
                    lda gfxmcr,u
                    ora #Mstr_Ctrl_Text_Mode_En+Mstr_Ctrl_Text_Overlay+Mstr_Ctrl_Graph_Mode_En+Mstr_Ctrl_Bitmap_En
                    ldb gfxmcr+1,u
                    lbsr gfxmcrset
                    lbsr bgset
                    tst lvl2,u              Level 2: one batch through SS.BmLine
                    beq ln_l1c
                    lbsr linesl2
                    lbcs lsfail2x
                    lbra ln_done
ln_l1c              lda oldline,u
                    ora #VKY_DRAWLINE_EN
                    sta >VKY_DRAWLINE_REG
* the fan: LineLines lines from the corner to the view's last row, one color each; then (user 2026-10-10: "YOU WILL
* ADD A SQUARE BORDER MADE FROM LINES") the view's border, four white lines
                    clr linecase,u
ln_lsl1             lbsr lineone
                    lbcs lstimeout
                    inc linecase,u
                    lda linecase,u
                    cmpa #LineLines+LineBorder
                    blo ln_lsl1
ln_done             lbsr setpass
                    lda #1                  shown until the test stops
                    sta running,u
                    leax linedone,pcr
                    lbra message
lstimeout           leax linetimeout,pcr
                    bra lsfail2
lsfail2x            leax linenotlive,pcr
                    cmpb #E$NotRdy
                    beq lsfail2
                    leax linetimeout,pcr
lsfail2             lbsr setfail
                    lbsr message
                    lbra restoregraphics
lineslive           rts
* linesl2 (2026-10-11, multiterminal): the same 20 lines as records (X0, X1, Y0, Y1, color, 0) in pixraw, sent
* through SS.BmLine - the driver enables the engine and feeds it; a short batch (its FIFO full) is resumed a tick
* later. Carry, B = the error: E$NotRdy when the terminal is not the one on screen, or no progress in 2 s.
linesl2             ldx pixbase,u
                    stx lnptr,u
                    clr linecase,u
mt_lsr1             lbsr linerec
                    inc linecase,u
                    lda linecase,u
                    cmpa #LineLines+LineBorder
                    blo mt_lsr1
                    lda #LineLines+LineBorder
                    sta lnleft,u
                    ldd #120
                    std waitcount,u
mt_lsr2             ldx lnptr,u
                    ldb lnleft,u
                    clra
                    pshs u
                    tfr d,u
                    ldy #LineBM
                    lda #1
                    ldb #SS.BmLine
                    os9 I$SetStt
                    tfr u,x                 X = the records drawn
                    puls u
                    bcs mt_lsr9
                    tfr x,d
                    pshs b
                    lda lnleft,u
                    suba ,s
                    sta lnleft,u
                    puls b
                    tstb
                    beq mt_lsr8               nothing went: wait for the FIFO
                    lda #8
                    mul
                    addd lnptr,u
                    std lnptr,u
                    tst lnleft,u
                    beq mt_lsr7
mt_lsr8             lbsr tick
                    ldd waitcount,u
                    subd #1
                    std waitcount,u
                    bne mt_lsr2
                    ldb #E$NotRdy+1         a timeout: any code but E$NotRdy
mt_lsr9             orcc #1
                    rts
mt_lsr7             andcc #^1
                    rts
* linerec: X = an 8-byte record for line linecase (the fan, then the border), filled; X advances past it
linerec             pshs y
                    lda linecase,u
                    cmpa #LineLines
                    bhs mt_lrb
                    ldd #LineX0
                    std ,x
                    lda linecase,u
                    ldb #LineXStep
                    mul
                    addd #LineX0
                    std 2,x
                    lda #LineY0
                    sta 4,x
                    lda #LineY1
                    sta 5,x
                    lda linecase,u
                    anda #$0F
                    cmpa #$0F               colors 1-15
                    blo mt_lr1
                    lda #$0E
mt_lr1              inca
                    sta 6,x
                    bra mt_lr9
mt_lrb              suba #LineLines
                    ldb #6
                    mul
                    leay linetab,pcr
                    leay d,y
                    ldd ,y
                    std ,x
                    ldd 2,y
                    std 2,x
                    ldd 4,y
                    std 4,x
                    lda #ColText            white
                    sta 6,x
mt_lr9              clr 7,x
                    leax 8,x
                    puls y,pc
* lineclear: bitmap 0 (gfxblk) filled with 0 by a DMA 2D fill. Carry: the engine never finished.
lineclear           tst lvl2,u
                    lbne lineclr2
                    clr >DMA.Base+DMA_CTRL_REG
                    clr >DMA.Base+DMA_OP_REG
                    clr >DMA.Base+DMA_FILL_BYTE
                    ldb gfxblk+1,u          the block -> its physical address (block x $2000)
                    tfr b,a
                    lsra
                    lsra
                    lsra
                    sta >DMA.Base+DMA_DEST_ADDR_H
                    andb #7
                    lslb
                    lslb
                    lslb
                    lslb
                    lslb
                    stb >DMA.Base+DMA_DEST_ADDR_M
                    clr >DMA.Base+DMA_DEST_ADDR_L
                    ldd #320
                    std >DMA.Base+DMA_SIZE_X_H
                    std >DMA.Base+DMA_DST_STRIDE_Y_H
                    ldd #240
                    std >DMA.Base+DMA_SIZE_Y_H
                    lda #DMA_CTRL_Enable+DMA_CTRL_1D_2D+DMA_CTRL_Fill
                    sta >DMA.Base+DMA_CTRL_REG
                    ora #DMA_CTRL_Start_Trf
                    sta >DMA.Base+DMA_CTRL_REG
                    ldd #120
                    std waitcount,u
ln_lcl1             lda >DMA.Base+DMA_STATUS_REG
                    bpl ln_lcl2
                    lbsr tick
                    ldd waitcount,u
                    subd #1
                    std waitcount,u
                    bne ln_lcl1
                    orcc #1
                    rts
ln_lcl2             clr >DMA.Base+DMA_CTRL_REG
                    andcc #^1
                    rts
* lineclr2 (2026-10-11, multiterminal): Level 2 - SS.BmClear fills bitmap 0 with 0 (wait mode 0: armed, then
* GetStat SS.BmClear polled once a tick until it reads 0). Carry: refused, or not done in 2 s.
lineclr2            pshs u
                    lda #1
                    ldb #SS.BmClear
                    ldx #ColBack            wait mode 0, fill ColBack (diag's blue: Level 2 has no background-color call)
                    ldy #LineBM             arm at once, bitmap 0
                    os9 I$SetStt
                    puls u
                    bcs mt_lc2b
                    ldd #120
                    std waitcount,u
mt_lc2w             pshs u
                    lda #1
                    ldb #SS.BmClear
                    os9 I$GetStt
                    puls u
                    bcs mt_lc2b
                    cmpx #0
                    beq mt_lc2k
                    lbsr tick
                    ldd waitcount,u
                    subd #1
                    std waitcount,u
                    bne mt_lc2w
mt_lc2b             orcc #1
                    rts
mt_lc2k             andcc #^1
                    rts
* linetab: the border - X0, X1 (words), Y0, Y1 (bytes): top, bottom, left, right
linetab             fdb LineX0,LineX1
                    fcb LineY0,LineY0
                    fdb LineX0,LineX1
                    fcb LineY1,LineY1
                    fdb LineX0,LineX0
                    fcb LineY0,LineY1
                    fdb LineX1,LineX1
                    fcb LineY0,LineY1
* lineone: line number linecase (the fan, then the border) into bitmap 0 - from (LineX0, LineY0) to (LineX0 + n*LineXStep, LineY1)
* in color n+1 - then waited for (engine done, its FIFO drained). Carry: it never finished.
lineone             lda #BITMAP_BLK
                    lbsr mapio
                    lda #TyVKY_LD_RESET
                    sta TyVKY_LD_OFFSET,x
                    lda #TyVKY_LD_ENABLE
                    sta TyVKY_LD_OFFSET,x
                    lda linecase,u
                    cmpa #LineLines
                    blo ln_fan
                    suba #LineLines         a border line: linetab
                    ldb #6
                    mul
                    pshs y
                    leay linetab,pcr
                    leay d,y
                    ldd ,y                  X0
                    std TyVKY_LD_OFFSET+2,x
                    ldd 2,y                 X1
                    std TyVKY_LD_OFFSET+4,x
                    ldd 4,y                 Y0, Y1
                    std TyVKY_LD_OFFSET+6,x
                    puls y
                    lda #ColText            white
                    sta TyVKY_LD_OFFSET+1,x
                    bra ln_go
ln_fan              lda linecase,u
                    anda #$0F
                    cmpa #$0F               colors 1-15
                    blo ln_lo1
                    lda #$0E
ln_lo1              inca
                    sta TyVKY_LD_OFFSET+1,x
                    ldd #LineX0
                    std TyVKY_LD_OFFSET+2,x
                    lda linecase,u
                    ldb #LineXStep
                    mul
                    addd #LineX0
                    std TyVKY_LD_OFFSET+4,x
                    lda #LineY0
                    sta TyVKY_LD_OFFSET+6,x
                    lda #LineY1
                    sta TyVKY_LD_OFFSET+7,x
ln_go               lda #TyVKY_LD_ENABLE+TyVKY_LD_GO+TyVKY_LD_BM0
                    sta TyVKY_LD_OFFSET,x
                    lbsr unmap
                    ldd #120
                    std waitcount,u
ln_lo2              lda #BITMAP_BLK
                    lbsr mapio
                    lda TyVKY_LD_OFFSET,x
                    sta memgot,u
                    ldd TyVKY_LD_OFFSET+2,x
                    std pixelcount,u
                    lbsr unmap
                    lda memgot,u
                    bita #TyVKY_LD_DONE
                    beq ln_lo3
                    ldd pixelcount,u
                    beq ln_lo4
ln_lo3              lbsr tick
                    ldd waitcount,u
                    subd #1
                    std waitcount,u
                    bne ln_lo2
                    orcc #1
                    rts
ln_lo4              lda #BITMAP_BLK         the engine rearmed (GO clear)
                    lbsr mapio
                    lda #TyVKY_LD_ENABLE
                    sta TyVKY_LD_OFFSET,x
                    lbsr unmap
                    andcc #^1
                    rts
bitmaptest          clr mode,u
                    clr mismatch,u
                    clr mismatch+1,u
                    ldx pixbase,u
                    ldy #7680
bitmapfill          tfr x,d
                    andb #15
                    stb ,x+
                    leay -1,y
                    bne bitmapfill
                    ldx pixbase,u
                    ldy #7680
bitmapcheck         tfr x,d
                    andb #15
                    cmpb ,x+
                    beq bitmapnext
                    ldd mismatch,u
                    addd #1
                    std mismatch,u
bitmapnext          leay -1,y
                    bne bitmapcheck
* the logo (2026-10-11, user: "convert the wblogo.png to .asm and use it in the Bitmap test in diag, center it in
* the viewport when shown"; "i want the pic to ride in the command but not be too big"): bitmap 0 through the OS
* (bgbitmap - diag's blue behind it on Level 2), the Wildbits logo (diaglogo.asm, 304 x 85, 7 colors) drawn into
* it centered in the live view, graphics on; it stays until the test stops (restoregraphics takes it down).
                    lbsr bgbitmap
                    bcs bm_fail
                    lbsr logodraw
                    bcs bm_fail
                    lda gfxmcr,u
                    ora #Mstr_Ctrl_Text_Mode_En+Mstr_Ctrl_Text_Overlay+Mstr_Ctrl_Graph_Mode_En+Mstr_Ctrl_Bitmap_En
                    ldb gfxmcr+1,u
                    lbsr gfxmcrset
                    lbsr bgset
                    lda #1                  shown until the test stops
                    sta running,u
                    ldd mismatch,u
                    beq bm_ok
                    lbsr setfail
                    leax bmlogobad,pcr
                    lbra message
bm_ok               lbsr setpass
                    leax bmlogo,pcr
                    lbra message
bm_fail             lbsr setfail            X = why: no bitmap, its clear, or a block not mapped
                    lbsr message
                    lbra restoregraphics
* logodraw: the logo's rows decoded into pixraw, one at a time, and written into bitmap 0 (gfxblk) from
* (LogoX0, LogoY0); transparent pixels are skipped, so the bitmap's own fill shows through. Carry: X = why.
LogoBase            equ TXT_LUT_SIZE/4      CLUT 3 entry of the logo's color 1, after diag's 16
LogoX0              equ 4+(ViewIn*4-LogoW)/2   centered in the live view: x 4-315 inside the borders
LogoY0              equ ViewTop*4+(ViewRows*4-LogoH)/2   and its rows
logodraw            leay logodata,pcr
                    sty logoptr,u
                    ldd #LogoY0*320+LogoX0  the row's offset in the bitmap (under 64K for every row)
                    std logooff,u
                    clr logorow,u
ld_row              ldx pixbase,u           decode one row
                    ldy logoptr,u
                    ldd #LogoW
                    std logocnt,u
ld_run              lda ,y+                 %LLLLCCCC, or %0000CCCC and a length byte
                    tfr a,b
                    andb #$0F
                    lsra
                    lsra
                    lsra
                    lsra
                    bne ld_len
                    lda ,y+
ld_len              sta loglen,u
                    tstb
                    beq ld_put
                    addb #LogoBase-1        a color: its CLUT entry
ld_put              stb ,x+
                    deca
                    bne ld_put
                    ldd logocnt,u
                    subb loglen,u
                    sbca #0
                    std logocnt,u
                    bne ld_run
                    sty logoptr,u
                    ldd logooff,u           the row into the bitmap: one or two blocks
                    anda #$1F
                    std seginoff,u          offset in its block
                    ldd logooff,u
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra
                    sta segblk,u            its block of the bitmap
                    ldy pixbase,u
                    ldd #$2000
                    subd seginoff,u         room left in the block
                    cmpd #LogoW
                    blo ld_two
                    ldd #LogoW
                    std segcnt,u
                    lbsr logoseg
                    bcs ld_bad
                    bra ld_next
ld_two              std segcnt,u
                    pshs d
                    lbsr logoseg
                    puls d
                    bcs ld_bad
                    pshs d                  the rest from the next block's start
                    ldd #LogoW
                    subd ,s++
                    std segcnt,u
                    clr seginoff,u
                    clr seginoff+1,u
                    inc segblk,u
                    lbsr logoseg
                    bcs ld_bad
ld_next             ldd logooff,u
                    addd #320
                    std logooff,u
                    inc logorow,u
                    lda logorow,u
                    cmpa #LogoH
                    lblo ld_row
                    andcc #^1
                    rts
ld_bad              leax logonomap,pcr
                    orcc #1
                    rts
* logoseg: segcnt bytes from Y into bitmap block segblk at seginoff, the zero (transparent) ones skipped; Y
* advances. Level 1 maps the block in diag's window (mapio); Level 2 asks the OS (F$MapBlk, F$ClrBlk) - the bitmap
* memory is the terminal's own, as pixview and shellbg write theirs. Carry: Level 2 could not map it.
logoseg             lda gfxblk+1,u
                    adda segblk,u
                    tst lvl2,u
                    bne lsg_l2
                    lbsr mapio              Level 1: X = the window
                    bsr lsg_copy
                    lbsr unmap
                    andcc #^1
                    rts
lsg_l2              pshs y
                    tfr a,b
                    clra
                    tfr d,x
                    ldb #1
                    pshs u
                    os9 $4F                 F$MapBlk (Level 2; Level 1's defs do not name it)
                    tfr u,x
                    puls u
                    puls y
                    bcs lsg_r
                    stx logowin,u
                    bsr lsg_copy
                    pshs u
                    ldu logowin,u
                    ldb #1
                    os9 $50                 F$ClrBlk
                    puls u
                    andcc #^1
lsg_r               rts
* lsg_copy: X = the block's window
lsg_copy            ldd seginoff,u
                    leax d,x
lsg_1               lda ,y+
                    beq lsg_2
                    sta ,x
lsg_2               leax 1,x
                    ldd segcnt,u
                    subd #1
                    std segcnt,u
                    bne lsg_1
                    rts
* S sprites (2026-10-10, user: "for the sprites test, duplicate what the sprites.asm test does, bounce 32 colored
* sprites around the viewport for 5 seconds"): as tests/sprites.asm - sprite n a solid 8x8 of color n+1 in
* graphics LUT1 (the shell's LUT0 is left alone), its pixels at physical + n*64 in diag's contiguous 8K buffer,
* records written through the SPRITE_BLK window with IRQs masked, positions on a grid and velocities from the
* sprite number - but 32 sprites bouncing inside the live view, one step a main-loop pass (about 60 a second),
* and after SprTicks passes the test stops itself and hides them. The master control comes from and goes back to
* the OS (SS.DScrn). The record's LUT field is bits 2:1, so LUT 1 is SPRITE_LUT0 alone. Like sprites.asm (ed.6)
* LUT1 is not restored: the graphics LUTs did not read back on the bench.
SprCount            equ 32
SprTicks            equ 300                 main-loop passes: about 5 s
SprXMin             equ 32+LineX0           sprite X/Y count from 32 off screen: the view's left column
SprXMax             equ 32+LineX1+1-8       its rightmost whole sprite
SprYMin             equ 32+LineY0           the view's first row
SprYMax             equ 32+LineY1+1-8       its last whole sprite
SprCtrl             equ SPRITE_Ctrl_Enable+SPRITE_LUT0+SPRITE_SIZE0+SPRITE_SIZE1
SprTabOff           equ SprCount*64          the records in pixraw, after the pixels
SprLutOff           equ SprTabOff+SprCount*SPR_REC_SIZE   LUT1's 33 entries, after the records
spritestart         lbsr gfxmcrget
                    sta sprmcr,u
                    stb sprmcr+1,u
                    tst lvl2,u              Level 2: diag's blue behind the sprites - bitmap 0 (bgbitmap), set
                    beq spr_nb              up before the pixels, since its CLUT table passes through pixraw
                    lbsr bgbitmap           (no bitmap: the sprites still run, on the black background)
spr_nb              equ *
* the pixels: sprite n is 64 bytes of color n+1
                    ldx pixbase,u
                    lda #1
spr_px1             ldb #64
spr_px2             sta ,x+
                    decb
                    bne spr_px2
                    inca
                    cmpa #SprCount
                    bls spr_px1
* the state, x(2) y(2) dx(1) dy(1): an 8 x 4 grid; dx 1-4 from bits 1:0 (odd: leftwards), dy 1-4 from bits 3:2
* (bit 1 set: upwards)
                    leax sprstate,u
                    clrb
spr_st1             pshs b
                    andb #7                 column 0-7
                    lda #36
                    mul
                    addd #SprXMin+4
                    std ,x
                    ldb ,s
                    lsrb
                    lsrb
                    lsrb                    row 0-3
                    lda #22
                    mul
                    addd #SprYMin+4
                    std 2,x
                    ldb ,s
                    andb #3
                    incb
                    lda ,s
                    anda #1
                    beq spr_dx
                    negb
spr_dx              stb 4,x
                    ldb ,s
                    lsrb
                    lsrb
                    andb #3
                    incb
                    lda ,s
                    anda #2
                    beq spr_dy
                    negb
spr_dy              stb 5,x
                    leax 6,x
                    puls b
                    incb
                    cmpb #SprCount
                    blo spr_st1
* LUT1: color 0 black, then 32 colors - k = n-1 = %RRGGB: blue 96 or 255, green 36 + 73*GG, red 64 + 63*RR
                    ldx pixbase,u           built in pixraw after the records, then put in place by sprlutset
                    leax SprLutOff,x
                    ldd #0
                    std ,x
                    std 2,x
                    leax 4,x
                    clra
spr_lut             pshs a
                    ldb #96
                    bita #1
                    beq spr_lb
                    ldb #255
spr_lb              stb ,x                  blue
                    lsra
                    anda #3
                    ldb #73
                    mul
                    addb #36
                    stb 1,x                 green
                    lda ,s
                    lsra
                    lsra
                    lsra
                    anda #3
                    ldb #63
                    mul
                    addb #64
                    stb 2,x                 red
                    clr 3,x
                    leax 4,x
                    puls a
                    inca
                    cmpa #SprCount
                    blo spr_lut
                    lbsr sprlutset
                    lbcs sprfail
* the records: enabled, LUT 1, 8x8, depth 0, pixels at physical + n*64, the state's position
                    lda physical,u
                    sta spraddr,u
                    ldd physical+1,u
                    std spraddr+1,u
                    lda #SprCount
                    sta sprloop,u
                    ldx pixbase,u           the table in pixraw after the pixels; sprpublish puts it on screen
                    leax SprTabOff,x
                    leay sprstate,u
spr_rec             lda #SprCtrl
                    sta SPR_CTRL,x
                    lda spraddr,u
                    sta SPR_ADDY_H,x
                    ldd spraddr+1,u
                    std SPR_ADDY_M,x
                    addd #64
                    std spraddr+1,u
                    bcc spr_rc
                    inc spraddr,u
spr_rc              ldd ,y
                    std SPR_X_H,x
                    ldd 2,y
                    std SPR_Y_H,x
                    leax SPR_REC_SIZE,x
                    leay 6,y
                    dec sprloop,u
                    bne spr_rec
                    tst lvl2,u              Level 2: the table registered with the driver (SS.SprReg)
                    beq spr_pub
                    pshs u
                    ldx pixbase,u
                    leax SprTabOff,x
                    ldy #0                  auto: X is in this process's map
                    ldu #SprCount
                    lda #1
                    ldb #SS.SprReg
                    os9 I$SetStt
                    puls u
                    lbcs sprfail
spr_pub             lbsr sprpublish
                    lbcs sprfail
* on screen: graphics, sprites and the text over them
                    lda sprmcr,u
                    ora #Mstr_Ctrl_Text_Mode_En+Mstr_Ctrl_Text_Overlay+Mstr_Ctrl_Graph_Mode_En+Mstr_Ctrl_Sprite_En
                    tst gfxowned,u          the blue bitmap behind them (Level 2)
                    beq spr_mc
                    ora #Mstr_Ctrl_Bitmap_En
spr_mc              equ *
                    ldb sprmcr+1,u
                    lbsr gfxmcrset
                    lbsr bgset
                    inc spriteon,u
                    ldd #SprTicks
                    std sprleft,u
                    lbra inputstart
* spritelive: one main-loop pass - every sprite stepped and reflected, the positions posted; the last pass stops it
spritelive          tst spriteon,u
                    beq spl_r
                    leax sprstate,u
                    ldb #SprCount
spl_b1              pshs b
                    lbsr sprbounce
                    leax 6,x
                    puls b
                    decb
                    bne spl_b1
                    lda #SprCount
                    sta sprloop,u
                    ldx pixbase,u
                    leax SprTabOff,x
                    leay sprstate,u
spl_p1              ldd ,y
                    std SPR_X_H,x
                    ldd 2,y
                    std SPR_Y_H,x
                    leax SPR_REC_SIZE,x
                    leay 6,y
                    dec sprloop,u
                    bne spl_p1
                    lbsr sprpublish
                    ldd sprleft,u
                    subd #1
                    std sprleft,u
                    bne spl_r
                    lbsr restoresprite
                    lbsr restoregraphics
                    clr running,u
                    leax spritedone,pcr
                    lbra message
spl_r               rts
* sprbounce: X = a sprite's state: one step, reflected at the view's edges (as sprites.asm's Bounce). Keeps X.
sprbounce           ldb 4,x
                    sex
                    addd ,x
                    std ,x
                    cmpd #SprXMin
                    ble sbn_fx
                    cmpd #SprXMax
                    blt sbn_ny
sbn_fx              neg 4,x
sbn_ny              ldb 5,x
                    sex
                    addd 2,x
                    std 2,x
                    cmpd #SprYMin
                    ble sbn_fy
                    cmpd #SprYMax
                    blt sbn_done
sbn_fy              neg 5,x
sbn_done            rts
* restoresprite: the 32 records disabled, the master control as found (SS.DScrn), the background color back
restoresprite       tst spriteon,u
                    beq spriterestret
                    ldx pixbase,u
                    leax SprTabOff,x
                    ldb #SprCount
spr_hide            clr SPR_CTRL,x
                    leax SPR_REC_SIZE,x
                    decb
                    bne spr_hide
                    lbsr sprpublish
                    tst lvl2,u              Level 2: the table given up (the driver turns the records off)
                    beq spr_h2
                    pshs u
                    ldu #0
                    lda #1
                    ldb #SS.SprReg
                    os9 I$SetStt
                    puls u
spr_h2              equ *
                    lda sprmcr,u
                    ldb sprmcr+1,u
                    lbsr gfxmcrset
                    lbsr bgrestore
                    clr spriteon,u
spriterestret       rts
spritedone          fcc "Sprites: 32 bounced for 5 s - confirm by eye. Hidden again."
                    fcb 0
spritenot           fcc "Sprites: the driver refused the sprite table or LUT (Level 2)."
                    fcb 0
* sprfail: a Level 2 sprite call failed - nothing is shown; the test fails
sprfail             lbsr restoregraphics
                    lbsr setfail
                    leax spritenot,pcr
                    lbra message
* sprpublish (2026-10-11, multiterminal): the 32 records in pixraw on screen - Level 2 through SS.SprPush (the
* driver copies the registered table; a background terminal keeps it for its switch back), Level 1 copied into
* the SPRITE_BLK records. Carry: Level 2 refused.
sprpublish          tst lvl2,u
                    beq mt_spp1
                    pshs u
                    ldy #0                  from record 0
                    ldu #SprCount
                    lda #1
                    ldb #SS.SprPush
                    os9 I$SetStt
                    puls u
                    rts
mt_spp1             lda #SPRITE_BLK
                    lbsr mapio
                    leax SPRITE_REC_OFF,x
                    ldy pixbase,u
                    leay SprTabOff,y
                    lda #SprCount*SPR_REC_SIZE/2
                    sta sprloop,u
mt_spp2             ldd ,y++
                    std ,x++
                    dec sprloop,u
                    bne mt_spp2
                    lbsr unmap
                    andcc #^1
                    rts
* sprlutset (2026-10-11, multiterminal): the 33 LUT1 entries in pixraw into graphics LUT1 - Level 2 through
* SS.ClutWrite (the terminal's own CLUT copy), Level 1 copied into FONT_BLK. Carry: Level 2 refused.
sprlutset           ldx pixbase,u
                    leax SprLutOff,x
                    tst lvl2,u
                    beq mt_slu1
                    pshs u
                    ldy #$0100              CLUT 1, from entry 0
                    ldu #SprCount+1
                    lda #1
                    ldb #SS.ClutWrite
                    os9 I$SetStt
                    puls u
                    rts
mt_slu1             tfr x,y
                    lda #FONT_BLK
                    lbsr mapio
                    leax GRPH_LUT1_OFF,x
                    lda #(SprCount+1)*2
                    sta sprloop,u
mt_slu2             ldd ,y++
                    std ,x++
                    dec sprloop,u
                    bne mt_slu2
                    lbsr unmap
                    andcc #^1
                    rts
* bgset / bgrestore (2026-10-10, user: "the bg turns black during the lines test, as well as the sprites test, leave
* the text bg blue"): with the text overlaid on graphics VICKY ignores the text background and shows its graphics
* background color (and a bitmap's color 0) instead - black. The OS has no call for that color, so its three
* registers are written directly: saved, set to diag's ColBack, put back on stop. Keep X and Y.
bgset               tst lvl2,u              Level 2: no shadow for it - left alone (user 2026-10-11)
                    bne bgs9@
                    tst bgowned,u
                    bne bgs9@
                    pshs x,y
                    ldx #TXT.Base
                    ldd BACKGROUND_COLOR_B,x
                    std bgsave,u
                    lda BACKGROUND_COLOR_R,x
                    sta bgsave+2,u
                    leay diagpal,pcr
                    leay ColBack*4,y        B, G, R
                    lda ,y
                    sta BACKGROUND_COLOR_B,x
                    lda 1,y
                    sta BACKGROUND_COLOR_G,x
                    lda 2,y
                    sta BACKGROUND_COLOR_R,x
                    inc bgowned,u
                    puls x,y
bgs9@               rts
bgrestore           tst bgowned,u
                    beq bgr9@
                    pshs x
                    ldx #TXT.Base
                    ldd bgsave,u
                    std BACKGROUND_COLOR_B,x
                    lda bgsave+2,u
                    sta BACKGROUND_COLOR_R,x
                    clr bgowned,u
                    puls x
bgr9@               rts
oplinit             fcb $20,$01,$23,$01,$40,$3F,$43,$00,$60,$F0,$63,$F0
                    fcb $80,$77,$83,$77,$C0,$31,$A0,$98,$B0,$31,$FF
midion              fcb 11,$C0,0,$90,60,80,64,80,67,80,72,80
midioff             fcb 9,$80,60,0,64,0,67,0,72,0
badmath             fcc "FAIL: integer result differs from CPU reference."
                    fcb 0
badfpu              fcc "FAIL: FPU output differs from exact IEEE reference."
                    fcb 0
midibusy            fcc "MIDI TX did not drain within the bounded wait; chord not sent."
                    fcb 0
mathlabel           fcc "Multiply operand / result (hex): $"
                    fcb 0
fpulabel            fcc "FPU case / IEEE result (hex): $"
                    fcb 0
dmalabel            fcc "DMA operation / mismatched bytes (hex): $"
                    fcb 0
inputlabel          fcc "Console key $"
                    fcb 0
inputcount          fcc ", keys $"
                    fcb 0
inputk2             fcc ", K2 keyboard status/count $"
                    fcb 0
mousestatus         fcc "Mouse X / Y / buttons (hex): $"
                    fcb 0
memok               fcc "PASS: 8192 owned bytes passed 17 patterns. System RAM untouched."
                    fcb 0
memfailmsg          fcc "FAIL: owned RAM readback differs from written pattern."
                    fcb 0
linenobm            fcc "Lines: SS.AScrn gave no bitmap 0."
                    fcb 0
lineclrbad          fcc "Lines: the DMA clear of bitmap 0 did not finish."
                    fcb 0
bmlogo              fcc "Bitmap: readback OK; the Wildbits logo in bitmap 0. Esc ends."
                    fcb 0
bmlogobad           fcc "Bitmap: readback FAILED; the Wildbits logo in bitmap 0. Esc ends."
                    fcb 0
logonomap           fcc "Bitmap: a block of bitmap 0 could not be mapped (F$MapBlk)."
                    fcb 0
linenotlive         fcc "Lines: this terminal is not on screen (SS.BmLine: E$NotRdy)."
                    fcb 0
linedone            fcc "Lines: 16-line fan and white border in bitmap 0. Esc ends."
                    fcb 0
linelabel0          fcc "Horizontal line pixels $"
                    fcb 0
linelabel1          fcc "Diagonal line pixels $"
                    fcb 0
expectedlabel       fcc " of $"
                    fcb 0
linetimeout         fcc "Lines: a line did not finish within 2 s."
                    fcb 0
* T Real-time clock (2026-10-10, user: "add RTC test to diag"). Read-only: the clock is never set; RTC_UTI alone is
* set and cleared round each read, as clock2_wildbits does, so the registers hold still while they are read.
*   1 RTC_SEC..RTC_YEAR and RTC_CENTURY: the date and time shown, every field checked as BCD inside its range
*   2 RTC_CTRL: the hour mode and battery run (RTC_STOP) shown, not judged
*   3 the OS clock (F$Time) shown under it
*   4 the seconds: two second edges watched, each exactly one second on (BCD, 59 wraps to 00), the OS ticks of the
*     whole second between them shown; no edge within RtcWait ticks means the clock is stopped
RtcWait             equ 150                     OS ticks allowed for one RTC second
RtcMinute           equ 60                      seconds in a minute
RtcPM               equ $80                     RTC_HRS in 12-hour mode: the PM bit
rtcstart            clr chkerrs,u
                    clr chkfail,u
                    clr chkfail+1,u
                    lbsr rtcread
* 1: the clock registers
                    lda vbase,u
                    leax rtcl1,pcr
                    lbsr chkline
                    lda rtccent,u
                    lbsr hex8
                    lda rtcregs+RTC_YEAR,u
                    lbsr hex8
                    leay rtcshow,pcr
rtcs1@              lda ,y+                     a separator, then the register after it; 0 ends
                    beq rtcs2@
                    lbsr putchar
                    ldb ,y+
                    leax rtcregs,u
                    lda b,x
                    lbsr hex8
                    bra rtcs1@
rtcs2@              leax rtcdow,pcr
                    lbsr putz
                    lda rtcregs+RTC_DOW,u
                    lbsr hex8
                    lbsr rtcfields
                    lbsr chkverdict
* 2: RTC_CTRL
                    lda vbase,u
                    adda #1
                    leax rtcl2,pcr
                    lbsr chkline
                    lda rtcctrl,u
                    lbsr hex8
                    leax rtc12h,pcr
                    lda rtcctrl,u
                    bita #RTC_24HR
                    beq rtcc1@
                    leax rtc24h,pcr
rtcc1@              lbsr putz
                    leax rtcnobatt,pcr
                    lda rtcctrl,u
                    bita #RTC_STOP
                    beq rtcc2@
                    leax rtcbatt,pcr
rtcc2@              lbsr putz
* 3: the OS clock, years counted from 1900
                    lda vbase,u
                    adda #2
                    leax rtcl3,pcr
                    lbsr chkline
                    leax ostime,u
                    os9 F$Time
                    lda ostime,u
                    ldb #$19                    the century, printed as two digits by hex8
                    cmpa #100
                    blo rtco1@
                    suba #100
                    ldb #$20
rtco1@              pshs a
                    tfr b,a
                    lbsr hex8
                    puls a
                    lbsr rtcdec2
                    leay ostime+1,u
                    leax ossep,pcr
rtco2@              lda ,x+                     a separator, then the next field; 0 ends
                    beq rtco3@
                    lbsr putchar
                    lda ,y+
                    lbsr rtcdec2
                    bra rtco2@
* 4: the seconds tick
rtco3@              lda vbase,u
                    adda #3
                    leax rtcl4,pcr
                    lbsr chkline
                    lbsr rtcsec
                    sta rtcsecs,u
                    lbsr rtcedge                the first edge: the ticks before it are part of a second
                    bcs rtcstopped
                    sta rtcsecs+1,u
                    lbsr rtcedge                the second edge: a whole second of OS ticks
                    bcs rtcstopped
                    sta rtcsecs+2,u
                    lda rtcsecs+1,u
                    lbsr hex8
                    leax rtcarrow,pcr
                    lbsr putz
                    lda rtcsecs+2,u
                    lbsr hex8
                    leax rtccomma,pcr
                    lbsr putz
                    lda rtcticks,u
                    lbsr rtcdec3
                    leax rtcticksl,pcr
                    lbsr putz
                    lda rtcsecs,u
                    lbsr rtcnext
                    cmpa rtcsecs+1,u
                    beq rtct1@
                    inc chkerrs,u
rtct1@              lda rtcsecs+1,u
                    lbsr rtcnext
                    cmpa rtcsecs+2,u
                    beq rtct2@
                    inc chkerrs,u
rtct2@              lbsr chkverdict
                    bra rtctally
rtcstopped          inc chkerrs,u
                    leax rtcstop,pcr
                    lbsr putz
                    lbsr chkverdict
rtctally            tst chkerrs,u
                    bne rtcfailed
                    lbsr setpass
                    leax rtcok,pcr
                    lbra message
rtcfailed           lbsr setfail
                    leax rtcbad,pcr
                    lbra failsum
* rtcread: RTC_SEC..RTC_YEAR into rtcregs, RTC_CENTURY and RTC_CTRL beside them, all under UTI
rtcread             ldx #RTC.Base
                    lda RTC_CTRL,x
                    ora #RTC_UTI
                    sta RTC_CTRL,x
                    leay rtcregs,u
                    ldb #RTC_YEAR+1
rtcr1@              lda ,x+
                    sta ,y+
                    decb
                    bne rtcr1@
                    ldx #RTC.Base
                    lda RTC_CENTURY,x
                    sta rtccent,u
                    lda RTC_CTRL,x
                    anda #^RTC_UTI
                    sta rtcctrl,u
                    sta RTC_CTRL,x
                    rts
* rtcfields: every field of rtcregs and rtccent checked; each one out of range counts in chkerrs
rtcfields           leay rtcranges,pcr
rtcf1@              ldb ,y+                     the register; $FF ends
                    cmpb #$FF
                    beq rtcf2@
                    leax rtcregs,u
                    lda b,x
                    lbsr rtcbcd
                    leay 2,y
                    bcc rtcf1@
                    inc chkerrs,u
                    bra rtcf1@
rtcf2@              lda rtcregs+RTC_HRS,u       the hour by the hour mode
                    leay rtchr24,pcr
                    ldb rtcctrl,u
                    bitb #RTC_24HR
                    bne rtcf3@
                    anda #^RtcPM
                    leay rtchr12,pcr
rtcf3@              lbsr rtcbcd
                    bcc rtcf4@
                    inc chkerrs,u
rtcf4@              lda rtccent,u
                    leay rtccentury,pcr
                    lbsr rtcbcd
                    bcc rtcf5@
                    inc chkerrs,u
rtcf5@              rts
* rtcbcd: A = a field, Y = its lowest and highest values (BCD): carry set unless A is two BCD digits within them
rtcbcd              pshs a
                    anda #$0F
                    cmpa #9
                    puls a
                    bhi rtcbcdbad
                    cmpa #$99
                    bhi rtcbcdbad
                    cmpa ,y
                    blo rtcbcdbad
                    cmpa 1,y
                    bhi rtcbcdbad
                    andcc #^1
                    rts
rtcbcdbad           orcc #1
                    rts
* rtcsec: A = RTC_SEC (BCD), read under UTI. Keeps B and X.
rtcsec              pshs b,x
                    ldx #RTC.Base
                    lda RTC_CTRL,x
                    ora #RTC_UTI
                    sta RTC_CTRL,x
                    ldb RTC_SEC,x
                    anda #^RTC_UTI
                    sta RTC_CTRL,x
                    tfr b,a
                    puls b,x,pc
* rtcedge: A = the current second: one-tick sleeps until it changes -> A = the new second, rtcticks = the ticks;
* carry set when RtcWait ticks pass without a change
rtcedge             sta rtcprev,u
                    clr rtcticks,u
rtce1@              lbsr tick               one tick (F$Sleep X=1 only yields)
                    inc rtcticks,u
                    lbsr rtcsec
                    cmpa rtcprev,u
                    bne rtce2@
                    lda rtcticks,u
                    cmpa #RtcWait
                    blo rtce1@
                    orcc #1
                    rts
rtce2@              andcc #^1
                    rts
* rtcnext: A = a BCD second -> the one after it (59 wraps to 00)
rtcnext             lbsr wsbcd2bin
                    incb
                    cmpb #RtcMinute
                    blo rtcn1@
                    clrb
rtcn1@              tfr b,a
                    lbra wsbin2bcd
* rtcdec2: A = 0-99 printed as two digits. Keeps D, X and Y.
rtcdec2             pshs d
                    lbsr wsbyte2dig
                    lda <wsdec
                    lbsr putchar
                    lda <wsdec+1
                    lbsr putchar
                    puls d,pc
* rtcdec3: A = 0-255 printed without a leading zero hundreds digit. Keeps D, X and Y.
rtcdec3             pshs d
                    ldb #'0'-1
rtcd1@              incb
                    suba #100
                    bcc rtcd1@
                    adda #100
                    cmpb #'0'
                    beq rtcd2@
                    pshs a
                    tfr b,a
                    lbsr putchar
                    puls a
rtcd2@              lbsr rtcdec2
                    puls d,pc
* rtcranges: register, lowest, highest (BCD); the hour and century are checked after it
rtcranges           fcb RTC_SEC,$00,$59
                    fcb RTC_MIN,$00,$59
                    fcb RTC_DAY,$01,$31
* RTC_DOW: 0 allowed - clock2_wildbits sets RTC_SEC..RTC_YEAR but never the day of the week (2026-10-10)
                    fcb RTC_DOW,$00,$07
                    fcb RTC_MONTH,$01,$12
                    fcb RTC_YEAR,$00,$99
                    fcb $FF
rtchr24             fcb $00,$23
rtchr12             fcb $01,$12
rtccentury          fcb $00,$99
rtcshow             fcb '-',RTC_MONTH,'-',RTC_DAY,' ',RTC_HRS,':',RTC_MIN,':',RTC_SEC,0
ossep               fcc "-- ::"
                    fcb 0
rtchelp             fcc "RTC: date/time BCD ranges, RTC_CTRL, OS clock, two 1 s ticks. Read-only."
                    fcb 0
rtcok               fcc "RTC: registers valid and the seconds advance one at a time."
                    fcb 0
rtcbad              fcc "RTC: FAIL - "
                    fcb 0
rtcl1               fcc "Clock registers      "
                    fcb 0
rtcl2               fcc "RTC_CTRL             "
                    fcb 0
rtcl3               fcc "OS clock (F$Time)    "
                    fcb 0
rtcl4               fcc "Seconds tick         "
                    fcb 0
rtcdow              fcc "  day of week "
                    fcb 0
rtc24h              fcc " 24-hour"
                    fcb 0
rtc12h              fcc " 12-hour"
                    fcb 0
rtcbatt             fcc ", runs on battery"
                    fcb 0
rtcnobatt           fcc ", stops without power"
                    fcb 0
rtcarrow            fcc " -> "
                    fcb 0
rtccomma            fcc ", "
                    fcb 0
rtcticksl           fcc " OS ticks for 1 s "
                    fcb 0
rtcstop             fcc "stopped: the second never changed "
                    fcb 0
* W WizFi360 (2026-10-10, user: "add WizFi test which should reset the chip and purge/show it's "ready" message
* until 5 seconds of silence"; "run ntptime over wizfi ... then use the results to set the rtc, so diag might set
* the rtc twice using WizFi and/or Ethernet"). The module is driven directly through its FIFO port, as E drives the
* W6100; no /wz path may be reading the FIFO meanwhile. Six lines, each with its own verdict:
*   1 the control and reset registers: the reset register (2026-10-07 cores) must be there
*   2 the chip held in reset 100 ms with both FIFOs and serial ends, released at 115,200 baud (the module's
*     factory rate, which a reset returns it to; the port is left there)
*   3 the boot text: every line shown until WfQuietTicks ticks pass with no byte; "ready" must be among them
*   4 Wi-Fi: "WIFI GOT IP" (the module rejoins its saved network by itself), waited for up to WfIpWait more ticks
*   5 the time, ntptime's way: AT+CIPSNTPCFG=1,<tz>,"pool.ntp.org","time.nist.gov", then AT+CIPSNTPTIME? until
*     the module's clock leaves 1970; tz is "tz" in w6100ipconfig (0, UTC, without it), as E uses
*   6 the RTC and the OS clock set from it (ntpsetrtc, E's routine)
* The names of the reset register's bits are wb/wizfi's (defs/wildbits.d there); this branch's wildbits.d still
* has the rc22 layout, so they are spelled here with a Wf prefix.
WfCtrlReg           equ WizFi.Base              rate code (bits 4-0), RX empty (bit 6), TX empty (bit 7)
WfResetReg          equ WizFi.Base+1            WizFi.ChipRst/FifoRst/UartRst; bit 7 reads 1 when present
WfDataReg           equ WizFi.Base+2            the FIFO port
WfRxEmptyBit        equ %01000000
WfHasResetBit       equ %10000000
WfChipRstBit        equ %00000001
WfFifoRstBit        equ %00000010
WfUartRstBit        equ %00000100
WfRate115200        equ 10                      rate code 10: 115,200, the reset value
WfHold              equ 6                       ticks the chip is held in reset (100 ms)
WfQuietTicks        equ 300                     ticks of silence that end the boot text (5 s)
WfBootMax           equ 1800                    ticks the boot text may run before it is called endless (30 s)
WfIpWait            equ 600                     more ticks for WIFI GOT IP (10 s)
WfAtWait            equ 180                     ticks for an AT command's OK or ERROR (3 s)
WfNtpTries          equ 15                      AT+CIPSNTPTIME? queries, one a second
WfShowMax           equ 14                      module lines shown in the live view
WfPollMax           equ 512                     bytes taken per poll
WfReadyF            equ %00000001               wfflags: "ready" seen
WfIpF               equ %00000010               "WIFI GOT IP"
WfOkF               equ %00000100               an "OK" line
WfErrF              equ %00001000               an "ERROR" line
WfTimeF             equ %00010000               +CIPSNTPTIME with a year from 2000 on, parsed into ntp*
wifistart           clr chkerrs,u
                    clr ntpskip,u
                    clr chkfail,u
                    clr chkfail+1,u
                    clr wfflags,u
                    clr wfshow,u
                    clr wfshown,u
                    clr wflen,u
                    clr wfbytes,u
                    clr wfbytes+1,u
                    lbsr netconfig              nettz, as E has it
* 1: the registers
                    lda vbase,u
                    leax wfl1,pcr
                    lbsr chkline
                    lda >WfCtrlReg
                    sta wfctl,u
                    lda >WfResetReg
                    sta wfrst,u
                    leax wfctlmsg,pcr
                    lbsr putz
                    lda wfctl,u
                    lbsr hex8
                    leax wfrstmsg,pcr
                    lbsr putz
                    lda wfrst,u
                    lbsr hex8
                    lda wfrst,u
                    bita #WfHasResetBit
                    bne wfs1@
                    inc chkerrs,u
                    leax wfnoreset,pcr
                    lbsr putz
                    lbsr chkverdict
                    lbra wftally
wfs1@               lda #' '
                    lbsr putchar
                    lbsr chkverdict
* 2: the chip reset
                    lda vbase,u
                    adda #1
                    leax wfl2,pcr
                    lbsr chkline
                    lda #WfChipRstBit+WfFifoRstBit+WfUartRstBit
                    sta >WfResetReg
                    lda #WfRate115200
                    sta >WfCtrlReg
                    ldb #WfHold
wfs2@               lbsr tick
                    decb
                    bne wfs2@
                    clr >WfResetReg             released at 115,200
                    leax wfheld,pcr
                    lbsr putz
                    lbsr chkverdict
* 3: the boot text until WfQuietTicks ticks without a byte
                    lda vbase,u
                    adda #2
                    leax wfl3,pcr
                    lbsr chkline
                    lda #1
                    sta wfshow,u
                    clr wfquiet,u
                    clr wfquiet+1,u
                    ldd #WfBootMax
                    std wfleft,u
                    lda #60
                    sta wfprog,u
wfb1@               lbsr tick
                    lbsr wfpoll
                    ldd wfquiet,u
                    addd #1
                    std wfquiet,u
                    cmpd #WfQuietTicks
                    bhs wfb2@
                    dec wfprog,u                once a second: the bytes so far
                    bne wfb3@
                    lda #60
                    sta wfprog,u
                    lbsr wfbootrow
wfb3@               ldd wfleft,u
                    subd #1
                    std wfleft,u
                    bne wfb1@
wfb2@               lbsr wfbootrow
                    ldd wfbytes,u
                    bne wfb4@
                    inc chkerrs,u               nothing at all: no module, or no answer
                    leax wfsilent,pcr
                    bra wfb6@
wfb4@               ldd wfleft,u
                    bne wfb5@
                    inc chkerrs,u               never quiet
                    leax wfendless,pcr
                    bra wfb6@
wfb5@               leax wfquietmsg,pcr
wfb6@               lbsr putz
                    leax wfreadymsg,pcr
                    lda wfflags,u
                    bita #WfReadyF
                    bne wfb7@
                    inc chkerrs,u
                    leax wfnoready,pcr
wfb7@               lbsr putz
                    lbsr chkverdict
                    clr wfshow,u
* 4: Wi-Fi, up to WfIpWait more ticks for WIFI GOT IP
                    lda vbase,u
                    adda #3
                    leax wfl4,pcr
                    lbsr chkline
                    ldd #WfIpWait
                    std wfleft,u
wfi1@               lda wfflags,u
                    bita #WfIpF
                    bne wfi2@
                    lbsr tick
                    lbsr wfpoll
                    ldd wfleft,u
                    subd #1
                    std wfleft,u
                    bne wfi1@
                    inc chkerrs,u
                    leax wfnoip,pcr
                    lbsr putz
                    lbsr chkverdict
                    lbra wfn9@                  no network: no time
wfi2@               leax wfgotip,pcr
                    lbsr putz
                    lbsr chkverdict
* 5: the time from the module's SNTP client
                    lda vbase,u
                    adda #4
                    leax wfl5,pcr
                    lbsr chkline
                    leax wfcfg1,pcr             AT+CIPSNTPCFG=1,<tz>,"pool.ntp.org","time.nist.gov"
                    lbsr wfsend
                    lda nettz,u
                    bpl wfn1@
                    ldb #'-
                    stb >WfDataReg
                    nega
wfn1@               lbsr wfsenddec
                    leax wfcfg2,pcr
                    lbsr wfsend
                    lbsr wfcommand
                    bcs wfn8@
                    lda #WfNtpTries
                    sta wftries,u
wfn2@               ldb #60                     a second for the module's clock to be set
wfn3@               lbsr tick
                    lbsr wfpoll
                    decb
                    bne wfn3@
                    leax wftimecmd,pcr
                    lbsr wfsend
                    lbsr wfcommand
                    lda wfflags,u
                    bita #WfTimeF
                    bne wfn4@
                    dec wftries,u
                    bne wfn2@
                    leax wfnosync,pcr
                    bra wfn7@
wfn4@               lbsr ntpshow
                    lbsr chkverdict
* 6: the RTC and the OS clock
                    lda vbase,u
                    adda #5
                    leax wfl6,pcr
                    lbsr chkline
                    lbsr ntpsetrtc
                    leax wfset,pcr
                    lbsr putz
                    lbsr chkverdict
                    bra wftally
* no time is not W's failure (2026-10-10, user: "same for wizfi, do not fail wizfi if the ntp -> rtc fails within
* wizfi"): SKIP, nothing counted; T, run after E and W in the Z run, checks the RTC
wfn8@               leax wfnocfg,pcr
wfn7@               inc ntpskip,u
                    lbsr putz
                    leax ethvskip,pcr
                    lbsr putz
wfn9@               lda vbase,u
                    adda #5
                    leax wfl6,pcr
                    lbsr chkline
                    leax wfnotset,pcr
                    lbsr putz
wftally             tst chkerrs,u
                    bne wffailed
                    lbsr setpass
                    leax wfok,pcr
                    tst ntpskip,u
                    beq wft1@
                    leax wfoknt,pcr
wft1@               lbra message
wffailed            lbsr setfail
                    leax wfbad,pcr
                    lbra failsum
* wfbootrow: line 3's progress: the bytes received so far, after its label; the cursor left after them
wfbootrow           pshs d,x
                    lda vbase,u
                    adda #2
                    ldb #3+21
                    lbsr at
                    ldd wfbytes,u
                    lbsr wfdec16
                    leax wfbytesmsg,pcr
                    lbsr putz
                    puls d,x,pc
* wfcommand: CR LF sent, then up to WfAtWait ticks for OK or ERROR -> carry clear on OK. Keeps D.
wfcommand           pshs d
                    lda #C$CR
                    sta >WfDataReg
                    lda #C$LF
                    sta >WfDataReg
                    lda wfflags,u
                    anda #^(WfOkF+WfErrF)
                    sta wfflags,u
                    ldd #WfAtWait
                    std wfleft,u
wfc1@               lbsr tick
                    lbsr wfpoll
                    lda wfflags,u
                    bita #WfOkF
                    bne wfc8@
                    bita #WfErrF
                    bne wfc9@
                    ldd wfleft,u
                    subd #1
                    std wfleft,u
                    bne wfc1@
wfc9@               orcc #1
                    puls d,pc
wfc8@               andcc #^1
                    puls d,pc
* wfsend: X = a zero-terminated string into the TX FIFO. Keeps D.
wfsend              pshs a
wfsd1@              lda ,x+
                    beq wfsd2@
                    sta >WfDataReg
                    bra wfsd1@
wfsd2@              puls a,pc
* wfsenddec: A = 0-99 sent as decimal digits, no leading zero. Keeps X and Y.
wfsenddec           lbsr wsbyte2dig
                    lda <wsdec
                    cmpa #'0
                    beq wfsdc1@
                    sta >WfDataReg
wfsdc1@             lda <wsdec+1
                    sta >WfDataReg
                    rts
* wfpoll: the RX FIFO drained (at most WfPollMax bytes): each byte counted and ends the quiet; printable ones
* build wfline, CR or LF completes it (wfgotline). Keeps D, X and Y.
wfpoll              pshs d,x,y
                    ldy #WfPollMax
wfp1@               lda >WfCtrlReg
                    bita #WfRxEmptyBit
                    bne wfp9@
                    lda >WfDataReg
                    ldx wfbytes,u
                    leax 1,x
                    stx wfbytes,u
                    clr wfquiet,u
                    clr wfquiet+1,u
                    cmpa #C$CR
                    beq wfp3@
                    cmpa #C$LF
                    beq wfp3@
                    cmpa #$20
                    blo wfp8@
                    cmpa #$7E
                    bhi wfp8@
                    ldb wflen,u
                    cmpb #WfLineMax
                    blo wfp2@
                    lbsr wfgotline              a full line: shown, the rest starts the next
                    clrb
wfp2@               leax wfline,u
                    sta b,x
                    inc wflen,u
                    bra wfp8@
wfp3@               tst wflen,u
                    beq wfp8@
                    lbsr wfgotline
wfp8@               leay -1,y
                    bne wfp1@
wfp9@               puls d,x,y,pc
* wfgotline: wfline complete: what it says noted in wfflags, shown while wfshow is set (up to WfShowMax lines),
* then emptied. Keeps D, X and Y.
wfgotline           pshs d,x,y
                    leax wfline,u
                    ldb wflen,u
                    clr b,x
                    clr wflen,u
                    lda #WfReadyF
                    leay wfready,pcr
                    bsr wfnote
                    lda #WfIpF
                    leay wfgotipstr,pcr
                    bsr wfnote
                    lda #WfErrF
                    leay wferror,pcr
                    bsr wfnote
                    ldd wfline,u                "OK" alone
                    cmpd #'O*256+'K
                    bne wfg1@
                    tst wfline+2,u
                    bne wfg1@
                    lda wfflags,u
                    ora #WfOkF
                    sta wfflags,u
wfg1@               leay wftimestr,pcr
                    bsr wffind
                    bcs wfg2@
                    lbsr wfparse                X = the date after "+CIPSNTPTIME:"
wfg2@               tst wfshow,u
                    beq wfg9@
                    lda wfshown,u
                    cmpa #WfShowMax
                    bhs wfg9@
                    inc wfshown,u
                    leax wfline,u
                    lbsr message
wfg9@               puls d,x,y,pc
* wfnote: Y = a string, A = its flag: set in wfflags when wfline holds the string. Keeps A.
wfnote              bsr wffind
                    bcs wfnt9@
                    pshs a
                    ora wfflags,u
                    sta wfflags,u
                    puls a
wfnt9@              rts
* wffind: Y = a zero-terminated string: carry clear when wfline holds it, X then just past it. Keeps D and Y.
wffind              pshs d,x,y
                    leax wfline,u
wff1@               pshs x,y                    stack +0: this trial's start and the string
wff2@               lda ,y+
                    beq wff8@
                    cmpa ,x+
                    beq wff2@
                    puls x,y
                    tst ,x+
                    bne wff1@
                    orcc #1
                    puls d,x,y,pc
wff8@               leas 4,s                    the trial's start and string
                    stx 2,s                     X returned just past the match
                    andcc #^1
                    puls d,x,y,pc
* wfparse: X = "Thu Oct 10 18:00:00 2026" (asctime's layout; the day may be one digit) -> ntpdow, ntpmon,
* ntpmday, ntphh, ntpmm, ntpss, ntpyear, ntpcent, ntpyy; WfTimeF set when the year is 2000 or later (the
* module's clock reads 1970 until SNTP has answered)
wfparse             pshs d,x,y
                    bsr wfskip
                    leay wfdays,pcr
                    lda #7
                    lbsr wfmatch3
                    stb ntpdow,u
                    bsr wfskip
                    leay wfmonths,pcr
                    lda #12
                    lbsr wfmatch3
                    stb ntpmon,u
                    bsr wfskip
                    bsr wfnum
                    stb ntpmday,u
                    bsr wfskip
                    bsr wfnum
                    stb ntphh,u
                    leax 1,x
                    bsr wfnum
                    stb ntpmm,u
                    leax 1,x
                    bsr wfnum
                    stb ntpss,u
                    bsr wfskip
                    bsr wfnum
                    std ntpyear,u
                    cmpd #2000
                    blo wfpa9@
                    tfr d,x
                    lda #100
                    lbsr wsdiv16x8              X = the century, B = the year in it
                    stb ntpyy,u
                    tfr x,d
                    stb ntpcent,u
                    lda wfflags,u
                    ora #WfTimeF
                    sta wfflags,u
wfpa9@              puls d,x,y,pc
* wfskip: X past spaces
wfskip              lda ,x
                    cmpa #' '
                    bne wfsk9@
                    leax 1,x
                    bra wfskip
wfsk9@              rts
* wfnum: X = decimal digits -> D = their value, X past them
wfnum               ldd #0
wfnm1@              pshs d                      stack +0: the value so far
                    ldb ,x
                    subb #'0
                    cmpb #9
                    bhi wfnm9@
                    leax 1,x
                    pshs b                      stack +0: the digit, +1: the value
                    ldd 1,s
                    lslb
                    rola
                    pshs d                      stack +0: the value x2
                    lslb
                    rola
                    lslb
                    rola
                    addd ,s++                   x10
                    addb ,s+
                    adca #0
                    leas 2,s
                    bra wfnm1@
wfnm9@              puls d,pc
* wfmatch3: X = three letters, Y = a table of A three-letter names -> B = 1 + its place (1 when none), X past
wfmatch3            pshs a
                    ldb #1
wfm1@               lda ,x
                    cmpa ,y
                    bne wfm2@
                    lda 1,x
                    cmpa 1,y
                    bne wfm2@
                    lda 2,x
                    cmpa 2,y
                    beq wfm9@
wfm2@               leay 3,y
                    incb
                    cmpb ,s
                    bls wfm1@
                    ldb #1
wfm9@               leax 3,x
                    puls a,pc
* wfdec16: D printed in decimal without leading zeros. Keeps D, X and Y.
wfdec16             pshs d,x,y
                    tfr d,x
                    clr ,-s                     the digits' end marker
wfd1@               lda #10
                    lbsr wsdiv16x8              X = X / 10, B = the digit
                    addb #'0
                    pshs b
                    cmpx #0
                    bne wfd1@
wfd2@               puls a
                    tsta
                    beq wfd3@
                    lbsr putchar
                    bra wfd2@
wfd3@               puls d,x,y,pc
wifihelp            fcc "WizFi360: chip reset, boot text to 5 s quiet (ready), Wi-Fi, SNTP -> RTC."
                    fcb 0
wfl1                fcc "WizFi registers      "
                    fcb 0
wfl2                fcc "Chip reset           "
                    fcb 0
wfl3                fcc "Boot text            "
                    fcb 0
wfl4                fcc "Wi-Fi                "
                    fcb 0
wfl5                fcc "SNTP time            "
                    fcb 0
wfl6                fcc "RTC and OS clock     "
                    fcb 0
wfctlmsg            fcc "control $"
                    fcb 0
wfrstmsg            fcc ", reset $"
                    fcb 0
wfnoreset           fcc ": no reset register "
                    fcb 0
wfheld              fcc "held 100 ms, released at 115,200 baud "
                    fcb 0
wfbytesmsg          fcc " bytes"
                    fcb 0
wfquietmsg          fcc ", 5 s quiet"
                    fcb 0
wfsilent            fcc ", never a byte"
                    fcb 0
wfendless           fcc ", not quiet in 30 s"
                    fcb 0
wfreadymsg          fcc ", ready "
                    fcb 0
wfnoready           fcc ", no ready "
                    fcb 0
wfgotip             fcc "WIFI GOT IP "
                    fcb 0
wfnoip              fcc "no WIFI GOT IP: not on a network "
                    fcb 0
wfnocfg             fcc "AT+CIPSNTPCFG not answered OK "
                    fcb 0
wfnosync            fcc "the module's clock never left 1970 "
                    fcb 0
wfset               fcc "set "
                    fcb 0
wfnotset            fcc "not set: no time"
                    fcb 0
wfok                fcc "WizFi: reset, ready, on the network, SNTP time; RTC set."
                    fcb 0
wfoknt              fcc "WizFi: reset, ready, on the network; no SNTP time (SKIP) - T checks the RTC."
                    fcb 0
wfbad               fcc "WizFi: FAIL - "
                    fcb 0
wfcfg1              fcc "AT+CIPSNTPCFG=1,"
                    fcb 0
wfcfg2              fcc ',"pool.ntp.org","time.nist.gov"'
                    fcb 0
wftimecmd           fcc "AT+CIPSNTPTIME?"
                    fcb 0
wfready             fcc "ready"
                    fcb 0
wfgotipstr          fcc "WIFI GOT IP"
                    fcb 0
wferror             fcc "ERROR"
                    fcb 0
wftimestr           fcc "+CIPSNTPTIME:"
                    fcb 0
wfdays              fcc "SunMonTueWedThuFriSat"
wfmonths            fcc "JanFebMarAprMayJunJulAugSepOctNovDec"
* E Ethernet (2026-10-09, user: "add Ethernet to the test suite of diag, perform unique and fundamental tests with
* the w6100 chip, stuff found in w6100eth.as for starters"). K2 only: the Jr2 does not decode the W6100 adapter.
* Seven checks, each line on the live view with its own verdict; nothing on the network is configured or sent:
*   1 the adapter's address latches (written one way, read back through the swapped offsets - no chip access)
*   2 the chip ID and version (CIDR0/1, VER0/1)
*   3 SYSR: the chip strapped for the parallel (indirect) bus, not SPI; its lock bits shown
*   4 IDM_ARH, the chip's address-high register, written and read back through the MR path
*   5 walking ones and zeros through PINGSEQR0 (a R/W register with no side effect): every data bit both ways
*   6 PINGIDR0/1 written with different bytes and read back (address bit 0), then both restored
*   7 PHYSR: cable, link, speed and duplex (shown, not judged)
* A transfer the adapter never finishes counts as a failure (ethbusy). Register names: defs/wildbits.d.
EthPatA             equ %01011010               test patterns: alternate bits, then their complements
EthPatB             equ %10100101
EthWait             equ $FFFF                   busy polls before a transfer is called stuck
* E is N/A (gray, its key ignored) off the K2 (markna), so it never runs there
ethstart            clr ethbusy,u
                    clr chkerrs,u
                    clr ntpskip,u
                    clr chkfail,u
                    clr chkfail+1,u
                    lda #W61_BLK_COMMON
                    sta ethblk,u
                    lbsr ethbridge
                    lbsr ethchipid
                    lbsr ethsysr
                    lbsr etharh
                    lbsr ethwalk
                    lbsr ethpingid
                    lbsr ethphy
                    lbsr ethnet
                    tst ethbusy,u
                    beq ethtally
                    lbsr setfail
                    leax ethl8,pcr
                    lbra message
ethtally            tst chkerrs,u
                    bne ethfailed
                    lbsr setpass
                    leax ethok,pcr
                    tst ntpskip,u
                    beq etht1@
                    leax ethoknt,pcr
etht1@              lbra message
ethfailed           lbsr setfail
                    leax ethbad,pcr
* failsum: X = "<test>: FAIL - " printed as a new line, then the first BAD line's label (2026-10-10, user: a
* summary in the live view pointing at "the BAD lines in the live view")
failsum             lbsr message
                    ldx chkfail,u
                    beq fs1@
                    lbra putz
fs1@                rts
* chkline: A = the row, X = its label: positioned at column 3, label printed, the error count noted for chkverdict
chkline             lbsr clearrow
                    stx chklabel,u
                    lbsr putz
                    ldb chkerrs,u
                    stb chkmark,u
                    rts
* chkverdict: OK when no error was counted since chkline, else BAD
chkverdict          leax ethvok,pcr
                    ldb chkerrs,u
                    cmpb chkmark,u
                    beq ethv1
                    ldd chkfail,u           the first BAD line is the one the summary names
                    bne ethv2
                    ldd chklabel,u
                    std chkfail,u
ethv2               leax ethvbad,pcr
ethv1               lbra putz
* ethcheck: A = the byte read, B = the byte expected: printed, an error counted on a mismatch. Keeps A.
ethcheck            pshs a,b
                    lbsr hex8
                    lda #'/'
                    lbsr putchar
                    lda 1,s
                    lbsr hex8
                    lda #' '
                    lbsr putchar
                    puls a,b
                    pshs b
                    cmpa ,s+
                    beq ethc1
                    inc chkerrs,u
ethc1               rts
* The adapter. ethgo: A = W6100.Enable + selects; Start clear, then set (the edge starts it), then the wait.
ethgo               sta >W6100.Base+WIZ_CTRL
                    ora #W6100.Start
                    sta >W6100.Base+WIZ_CTRL
ethbusywait         pshs x
                    ldx #EthWait
ethw1               lda >W6100.Base+WIZ_CTRL
                    bita #W6100.Busy
                    beq ethw2
                    leax -1,x
                    bne ethw1
                    inc ethbusy,u
ethw2               puls x,pc
* ethsetarh: A = the chip's address high byte, into IDM_ARH. Keeps B.
ethsetarh           sta >W6100.Base+WIZ_MR
                    lda #W6100.Enable+W6100.SelARH
                    lbra ethgo
* ethread: X = a register in block ethblk -> B = its byte. Keeps X.
ethread             tfr x,d
                    stb ethlo,u
                    lbsr ethsetarh
                    lda ethblk,u
                    sta >W6100.Base+WIZ_ADDR_H
                    lda ethlo,u
                    sta >W6100.Base+WIZ_ADDR_L
                    lda #W6100.Enable+W6100.SelRead
                    lbsr ethgo
                    ldb >W6100.Base+WIZ_WRVAL
                    rts
* ethwrite: X = a register in block ethblk, B = the byte. Keeps X.
ethwrite            stb ethval,u
                    tfr x,d
                    stb ethlo,u
                    lbsr ethsetarh
                    lda ethblk,u
                    sta >W6100.Base+WIZ_ADDR_H
                    lda ethlo,u
                    sta >W6100.Base+WIZ_ADDR_L
                    lda ethval,u
                    sta >W6100.Base+WIZ_WRVAL
                    lda #W6100.Enable
                    lbra ethgo
* 1: the address latches - WIZ_ADDR_L read back at WIZ_ADDR_H and the other way round; the chip is not involved
ethbridge           lda vbase,u
                    leax ethl1,pcr
                    lbsr chkline
                    lda #EthPatA
                    sta >W6100.Base+WIZ_ADDR_L
                    lda >W6100.Base+WIZ_ADDR_H
                    ldb #EthPatA
                    lbsr ethcheck
                    lda #EthPatB
                    sta >W6100.Base+WIZ_ADDR_H
                    lda >W6100.Base+WIZ_ADDR_L
                    ldb #EthPatB
                    lbsr ethcheck
                    clr >W6100.Base+WIZ_ADDR_H
                    clr >W6100.Base+WIZ_ADDR_L
                    lbra chkverdict
* 2: the chip ID and version, four registers at address high byte 0
ethchipid           lda vbase,u
                    adda #1
                    leax ethl2,pcr
                    lbsr chkline
                    ldx #W61_CIDR0
                    leay ethids,pcr
ethid1              lbsr ethread
                    tfr b,a
                    ldb ,y+
                    lbsr ethcheck
                    leax 1,x
                    cmpx #W61_VER1
                    bls ethid1
                    lbra chkverdict
* 3: SYSR - parallel bus mode expected (IND set, SPI clear); the three lock bits shown
ethsysr             lda vbase,u
                    adda #2
                    leax ethl3,pcr
                    lbsr chkline
                    ldx #W61_SYSR
                    lbsr ethread
                    stb ethval,u
                    tfr b,a
                    anda #W61_SYSR_IND+W61_SYSR_SPI
                    ldb #W61_SYSR_IND
                    lbsr ethcheck
                    leax ethlocks,pcr
                    lbsr putz
                    lda ethval,u
                    lbsr hex8
                    lda #' '
                    lbsr putchar
                    lbra chkverdict
* 4: IDM_ARH written and read back (the MR path), both patterns
etharh              lda vbase,u
                    adda #3
                    leax ethl4,pcr
                    lbsr chkline
                    lda #EthPatA
                    bsr etharh1
                    lda #EthPatB
                    bsr etharh1
                    lbra chkverdict
etharh1             sta ethval,u
                    lbsr ethsetarh
                    lda #W6100.Enable+W6100.SelARH+W6100.SelRead
                    lbsr ethgo
                    lda >W6100.Base+WIZ_MR
                    ldb ethval,u
                    lbra ethcheck
* 5: walking ones then walking zeros through PINGSEQR0, the original value restored after
ethwalk             lda vbase,u
                    adda #4
                    leax ethl5,pcr
                    lbsr chkline
                    ldx #W61_PINGSEQR0
                    lbsr ethread
                    stb ethsave,u
                    clr ethcount,u
                    ldb #1                  walking one: 1, 2, 4 ... 128
ethwk1              lbsr ethtry
                    ldb ethpat,u
                    lslb
                    bne ethwk1
                    ldb #1                  walking zero: the complements
                    comb
ethwk2              lbsr ethtry
                    ldb ethpat,u
                    comb
                    lslb
                    beq ethwk3
                    comb
                    bra ethwk2
ethwk3              ldb ethsave,u
                    lbsr ethwrite
                    lda ethcount,u
                    lbsr hex8
                    leax ethbits,pcr
                    lbsr putz
                    tst ethcount,u
                    beq ethwk4
                    inc chkerrs,u
ethwk4              lbra chkverdict
* ethtry: X = the register, B = a pattern: written, read back, a mismatch counted in ethcount
ethtry              stb ethpat,u
                    lbsr ethwrite
                    lbsr ethread
                    cmpb ethpat,u
                    beq ethtry1
                    inc ethcount,u
ethtry1             rts
* 6: PINGIDR0/1 - different bytes in neighbouring registers read back apart, then the originals restored
ethpingid           lda vbase,u
                    adda #5
                    leax ethl6,pcr
                    lbsr chkline
                    ldx #W61_PINGIDR0
                    lbsr ethread
                    stb ethsave,u
                    ldx #W61_PINGIDR1
                    lbsr ethread
                    stb ethsave+1,u
                    ldx #W61_PINGIDR0
                    ldb #EthPatA
                    lbsr ethwrite
                    ldx #W61_PINGIDR1
                    ldb #EthPatB
                    lbsr ethwrite
                    ldx #W61_PINGIDR0
                    lbsr ethread
                    tfr b,a
                    ldb #EthPatA
                    lbsr ethcheck
                    ldx #W61_PINGIDR1
                    lbsr ethread
                    tfr b,a
                    ldb #EthPatB
                    lbsr ethcheck
                    ldx #W61_PINGIDR0
                    ldb ethsave,u
                    lbsr ethwrite
                    ldx #W61_PINGIDR1
                    ldb ethsave+1,u
                    lbsr ethwrite
                    lbra chkverdict
* 7: PHYSR, shown only - a test bench without a cable is not a fault of the chip
ethphy              lda vbase,u
                    adda #6
                    leax ethl7,pcr
                    lbsr chkline
                    ldx #W61_PHYSR
                    lbsr ethread
                    stb ethval,u
                    tfr b,a
                    lbsr hex8
                    leax ethcabin,pcr
                    lda ethval,u
                    bita #W61_PHYSR_CAB
                    beq ethp1
                    leax ethcabout,pcr
ethp1               lbsr putz
                    leax ethlinkdn,pcr
                    lda ethval,u
                    bita #W61_PHYSR_LNK
                    beq ethp3
                    leax ethlinkup,pcr
                    lbsr putz
                    leax eth100,pcr
                    lda ethval,u
                    bita #W61_PHYSR_SPD
                    beq ethp2
                    leax eth10,pcr
ethp2               lbsr putz
                    leax ethfull,pcr
                    lda ethval,u
                    bita #W61_PHYSR_DPX
                    beq ethp3
                    leax ethhalf,pcr
ethp3               lbra putz
* 8-13 (2026-10-10, user: "for ethernet test, have it ping google.com and the idea is to bring the link up and show
* fail or pass"; "ethernet should try to find the #.#.#.x gateway, try all 256 before failing", "start at 1.1 and work
* up to 1.max", "have ethernet test reveal the discovered gateway"; "get the time from nttp server over ethernet as
* the ping, and apply to the rtc"), the w6100 tools' way: the settings from /DD/SYS/w6100ipconfig (w6100eth,
* w6100tel; their keywords and defaults, plus "tz"), names looked up at the "dns" server over UDP on socket 0
* (w6100tel's DnsResolve), the chip's SOCKET-less PING4 (w6100eth). Sixteen-bit socket registers are read until
* two reads agree, as the datasheet asks of registers that change while they are read.
*   8 the link: PHYSR's link bit within EthLinkWait ticks (nothing more is tried without it)
*   9 the settings written to SHAR, GAR, SUBR and SIPR (NETLCKR unlocked first), SIPR and GAR read back
*  10 the gateway: the configured one if google.com can be looked up through it, else x.x.x.1 upward to .254 of
*     this board's /24 (not itself): each that answers a short PING4 is tried as the gateway; the one found shown
*  11 google.com's address (A record; CNAMEs and compressed names skipped)
*  12 PING4 to it: a reply passes, the chip's timeout or EthPingWait ticks fails
*  13 NTP: pool.ntp.org's time (UTC + the "tz" hours) written to the RTC and the OS clock
EthResetWait        equ 30                      ticks for the chip to answer after its software reset
DhcpStOpen          equ 1                       the DHCP steps, for the failure line
DhcpStDiscover      equ 2
DhcpStOffer         equ 3
DhcpStRequest       equ 4
DhcpStAck           equ 5
EthLinkWait         equ 300                     OS ticks (about 5 s) for the PHY link
DhcpServerPort      equ 67                      DHCP (RFC 2131)
DhcpClientPort      equ 68
DhcpTries           equ 3
DhcpPackets         equ 8                       packets read for one reply before giving up
DhcpOp              equ 0                       BOOTP fields
DhcpHtype           equ 1
DhcpHlen            equ 2
DhcpXid             equ 4
DhcpFlags           equ 10
DhcpYiaddr          equ 16
DhcpChaddr          equ 28
DhcpCookie          equ 236
DhcpOptions         equ 240
DhcpBootRequest     equ 1
DhcpBootReply       equ 2
DhcpHtypeEth        equ 1
DhcpBroadcast       equ $8000                   answer by broadcast: no address yet
DhcpXidHi           equ $5742                   the transaction ID, "WBIT"
DhcpXidLo           equ $4954
DhcpMagicHi         equ $6382                   the options' magic cookie 99.130.83.99
DhcpMagicLo         equ $5363
DhcpOptPad          equ 0
DhcpOptMask         equ 1
DhcpOptRouter       equ 3
DhcpOptDns          equ 6
DhcpOptReqIP        equ 50
DhcpOptType         equ 53
DhcpOptServer       equ 54
DhcpOptParams       equ 55
DhcpOptEnd          equ 255
DhcpDiscover        equ 1
DhcpOffer           equ 2
DhcpRequest         equ 3
DhcpAck             equ 5
DhcpNak             equ 6
EthPingWait         equ 180                     OS ticks for a PING4 reply or timeout (w6100eth's PING.RETRIES)
EthUdpWait          equ 200                     OS ticks for socket 0 to open
EthSendWait         equ 120                     OS ticks for SENDOK
EthRxWait           equ 240                     ticks for an answer (about 4 s; DHCP servers may probe first)
EthDnsTries         equ 3
EthScanTries        equ 1                       DNS tries through a scanned gateway
EthCmdWait          equ $4000                   polls for a socket command to be accepted
EthScanRtr          equ 500                     SLRTR while scanning: 50 ms (100 us units), no retries
EthScanLast         equ 254                     the scan's last host
EthValCol           equ 24                      the result column of a live-view line
EthDnsPort          equ 53
EthDnsSrc           equ $C002                   UDP source port for DNS (w6100tel's)
EthNtpPort          equ 123
EthNtpSrc           equ $C004                   UDP source port for NTP
EthNtpTries         equ 3
EthDnsId            equ $D1A6                   the queries' ID, checked in the answers
DnsFlagsRD          equ $0100                   a standard query, recursion desired
DnsTypeA            equ 1
DnsClassIN          equ 1
DnsHdrLen           equ 12
DnsRcode            equ %00001111               the answer's error code (flags, low byte)
DnsQTail            equ 4                       QTYPE and QCLASS after a question's name
DnsRrType           equ 0                       answer record: type,
DnsRrLen            equ 8                       data length
DnsRrData           equ 10                      and data
DnsPtr              equ %11000000               a name's compression pointer
NtpLen              equ 48                      an NTP packet
NtpRequest          equ %00011011               LI 0, version 3, mode 3 (client)
NtpFlags            equ 0
NtpStratum          equ 1
NtpTxSecs           equ 40                      transmit time: seconds since 1900, big-endian
NtpModeMask         equ %00000111
NtpModeServer       equ 4
NtpDay              equ 86400
NtpDayHi            equ NtpDay/65536
NtpDayLo            equ NtpDay-NtpDayHi*65536
NtpHour             equ 3600
NtpMinute           equ 60
NtpWeek             equ 7
NtpEpoch            equ 1900                    NTP's year 0; 1 January 1900 was a Monday
NtpYearDays         equ 365
NtpFeb              equ 2
NtpCentury          equ 100
NetTypeIP           equ 1                       netkeys value types
NetTypeMAC          equ 2
NetTypeTZ           equ 3
NetKeyEnd           equ $FF
NetTab              equ $09
NetLower            equ $20                     ASCII: the lower-case bit
NetCfgRead          equ 512                     the w6100 tools read the file's first 512 bytes
* the chip reset first (2026-10-10, user: "why is the ethernet test in diag failing on get IP"): no socket or setting
* left by an earlier run or another program carries into this one; the PHY renegotiates within the link wait
ethnet              lda #W61_BLK_COMMON
                    sta ethblk,u
                    ldx #W61_CHPLCKR
                    ldb #W61_CHPLCKR_UNLOCK
                    lbsr ethwrite
                    ldx #W61_SYCR0
                    clrb                        RST = 0: reset
                    lbsr ethwrite
                    ldd #EthResetWait           the chip answering again (its ID) within EthResetWait ticks
                    std netwait,u
ethr1@              lbsr tick
                    ldx #W61_CIDR0
                    lbsr ethread
                    cmpb #W61_CIDR0_ID
                    beq ethr2@
                    ldd netwait,u
                    subd #1
                    std netwait,u
                    bne ethr1@
ethr2@              lda vbase,u
                    adda #7
                    leax ethl9,pcr
                    lbsr chkline
                    ldd #EthLinkWait
                    std netwait,u
ethn1@              ldx #W61_PHYSR
                    lbsr ethread
                    bitb #W61_PHYSR_LNK
                    bne ethn2@
                    lbsr tick
                    ldd netwait,u
                    subd #1
                    std netwait,u
                    bne ethn1@
                    leax ethndown,pcr
                    lbra ethnbad                no link: nothing more can be tried
ethn2@              leax ethnup,pcr
                    lbsr putz
                    lbsr chkverdict
* 9: Get IP (2026-10-10, user: "why would you not let the router assign the IP??", "It should be "Get IP" and then
* get the router-assigned IP"): DHCP from 0.0.0.0 gives the address, mask, gateway and DNS server; without an
* answer the line is BAD and the w6100ipconfig / default settings are used, the gateway then found by the scan.
                    lda vbase,u
                    adda #8
                    leax ethl10,pcr
                    lbsr chkline
                    lbsr netconfig
                    lda #W61_BLK_COMMON
                    sta ethblk,u
                    ldx #W61_NETLCKR
                    ldb #W61_NETLCKR_UNLOCK
                    lbsr ethwrite
                    leax netmac,u
                    ldy #W61_SHAR
                    ldb #NetMACLen
                    lbsr netblkwr
                    leax netzero,pcr            no address yet: DHCP runs from 0.0.0.0
                    ldy #W61_SIPR
                    ldb #NetIPLen
                    lbsr netblkwr
                    ldy #W61_GAR
                    ldb #NetIPLen               (netblkwr returns B = 0)
                    lbsr netblkwr
                    ldy #W61_SUBR
                    ldb #NetIPLen
                    lbsr netblkwr
                    lbsr netdhcp
                    bcs gi1@
                    lda #1
                    sta netdhcpok,u
                    leax netip,u
                    lbsr netpip
                    leax ethndhcp,pcr
                    lbsr putz
                    bra gi2@
gi1@                clr netdhcpok,u
                    inc chkerrs,u
                    leax ethnodhcp,pcr
                    lbsr putz
                    leax dhcpsteps,pcr          the step it stopped at
                    ldb dhcpstage,u
gi3@                decb
                    beq gi5@
gi4@                tst ,x+
                    bne gi4@
                    bra gi3@
gi5@                lbsr putz
                    lda #W61_BLK_S0REG          and the socket's status
                    sta ethblk,u
                    ldx #W61_Sn_SR
                    lbsr ethread
                    tfr b,a
                    lbsr hex8
                    leax ethnsemi,pcr
                    lbsr putz
                    leax netip,u
                    lbsr netpip
                    ldx netsrcmsg,u
                    lbsr putz
gi2@                lda #W61_BLK_COMMON
                    sta ethblk,u
                    leax netgw,u
                    ldy #W61_GAR
                    ldb #NetIPLen
                    lbsr netblkwr
                    leax netmask,u
                    ldy #W61_SUBR
                    ldb #NetIPLen
                    lbsr netblkwr
                    leax netip,u
                    ldy #W61_SIPR
                    ldb #NetIPLen
                    lbsr netblkwr
                    ldb #NetIPLen
                    lbsr netblkchk
                    leax netgw,u
                    ldy #W61_GAR
                    ldb #NetIPLen
                    lbsr netblkchk
                    lbsr chkverdict
* 10: the gateway, found if need be; 11: google.com's address comes with it
                    lda vbase,u
                    adda #9
                    leax ethl11,pcr
                    lbsr chkline
                    leax netgw,u
                    lbsr netpip
                    tst netdhcpok,u
                    beq gw1@
                    leax ethndhcp,pcr
                    lbsr putz
gw1@                lda #EthDnsTries
                    lbsr netgwtry
                    bcc ethn3@
                    lbsr netscan
                    bcc ethn4@
                    lda vbase,u
                    adda #9
                    ldb #EthValCol
                    lbsr at
                    leax ethnnogw,pcr
                    lbra ethnbad
ethn4@              lda vbase,u
                    adda #9
                    ldb #EthValCol
                    lbsr at
                    leax netgw,u
                    lbsr netpip
                    leax ethnfound,pcr
                    lbsr putz
ethn3@              lbsr chkverdict
                    lda vbase,u
                    adda #10
                    leax ethl12,pcr
                    lbsr chkline
                    leax nethost,u
                    lbsr netpip
                    lbsr chkverdict
* 12: PING4 as w6100eth does (2026-10-10, user: "ping whatever w6100eth.as is pinging"; "the eth test needs to work
* on anybody's K2"): its target, "server" in w6100ipconfig, or - with no file - the gateway DHCP gave
                    lda vbase,u
                    adda #11
                    leax ethl13,pcr
                    lbsr chkline
                    ldd netsrv,u                no server set: the gateway
                    bne pt1@
                    ldd netsrv+2,u
                    bne pt1@
                    ldd netgw,u
                    std netsrv,u
                    ldd netgw+2,u
                    std netsrv+2,u
                    leax netsrv,u
                    lbsr netpip
                    leax ethngwtag,pcr
                    lbsr putz
                    bra pt2@
pt1@                leax netsrv,u
                    lbsr netpip
pt2@
                    lda #W61_BLK_COMMON
                    sta ethblk,u
                    leax netsrv,u
                    ldy #W61_SLDIPR
                    ldb #NetIPLen
                    lbsr netblkwr
* w6100eth's ping exactly (2026-10-10, user): SLRTR and SLRCR at reset, SLIRCLR, SLCR = PING4, SLIR polled
* once a tick for EthPingWait (w6100eth's PING.RETRIES) ticks
                    lbsr netsldefault
                    lbsr netping
                    bcc ethn5@
                    leax ethnoreply,pcr
                    lbsr putz
                    inc chkerrs,u
                    bra ethn6@
ethn5@              leax ethnreply,pcr
                    lbsr putz
ethn6@              lbsr chkverdict
* 13: NTP into the RTC and the OS clock
                    lda vbase,u
                    adda #12
                    leax ethl14,pcr
                    lbsr chkline
                    lda #EthDnsTries
                    leax dnsntp,pcr
                    ldb #DnsNtpLen
                    leay ntphost,u
                    lbsr netresolve
                    bcs ethn7@
                    lbsr netntp
                    bcs ethn7@
                    lbsr ntpdate
                    lbsr ntpsetrtc
                    lbsr ntpshow
                    lbra chkverdict
* no time is not E's failure (2026-10-10, user: "if rtc setting fails in ethernet, do not fail rtc, as the rtc test
* will catch that"): the line says so with SKIP, nothing is counted; T, run after E and W in the Z run, checks the RTC
ethn7@              inc ntpskip,u
                    leax ethnontp,pcr
                    lbsr putz
                    leax ethvskip,pcr
                    lbra putz
* ethnbad: X = what went wrong, printed and counted
ethnbad             lbsr putz
                    inc chkerrs,u
                    lbra chkverdict
* netdhcp: DISCOVER, OFFER, REQUEST, ACK (RFC 2131) from 0.0.0.0:68 to 255.255.255.255:67 on socket 0, the
* broadcast flag set so the server answers by broadcast; the ACK's address, mask, router and DNS server go into
* netcfg (an option the server leaves out keeps its setting). Carry: no lease in DhcpTries rounds.
netdhcp             lda #DhcpStOpen
                    sta dhcpstage,u
                    ldd #DhcpClientPort
                    leax netbcast,pcr
                    ldy #DhcpServerPort
                    lbsr netopen
                    bcs dh9@
                    lda #DhcpTries
                    sta nettry,u
dh1@                lda #DhcpStDiscover
                    sta dhcpstage,u
                    lda #DhcpDiscover
                    lbsr dhcpbuild
                    leax dhcpbuf,u
                    ldd #DhcpLen
                    lbsr netsend
                    bcs dh2@
                    lda #DhcpStOffer
                    sta dhcpstage,u
                    lda #DhcpOffer
                    lbsr dhcpwait
                    bcs dh2@
                    lda #DhcpStRequest
                    sta dhcpstage,u
                    lda #DhcpRequest
                    lbsr dhcpbuild
                    leax dhcpbuf,u
                    ldd #DhcpLen
                    lbsr netsend
                    bcs dh2@
                    lda #DhcpStAck
                    sta dhcpstage,u
                    lda #DhcpAck
                    lbsr dhcpwait
                    bcc dh8@
dh2@                dec nettry,u
                    bne dh1@
                    ldb #W61_Sn_CR_CLOSE
                    lbsr netsockcmd
dh9@                orcc #1
                    rts
dh8@                ldb #W61_Sn_CR_CLOSE
                    lbsr netsockcmd
                    andcc #^1
                    rts
* dhcpbuild: A = the message type: dhcpbuf = a BOOTP request from netmac with the DHCP options (REQUEST also
* names the offered address and the server), zero-padded to DhcpLen
dhcpbuild           pshs a
                    leax dhcpbuf,u
                    ldd #DhcpLen
db1@                clr ,x+
                    subd #1
                    bne db1@
                    leax dhcpbuf,u
                    lda #DhcpBootRequest
                    sta DhcpOp,x
                    lda #DhcpHtypeEth
                    sta DhcpHtype,x
                    lda #NetMACLen
                    sta DhcpHlen,x
                    ldd #DhcpXidHi
                    std DhcpXid,x
                    ldd #DhcpXidLo
                    std DhcpXid+2,x
                    ldd #DhcpBroadcast
                    std DhcpFlags,x
                    leax DhcpChaddr,x
                    leay netmac,u
                    ldb #NetMACLen
db2@                lda ,y+
                    sta ,x+
                    decb
                    bne db2@
                    leax dhcpbuf+DhcpCookie,u
                    ldd #DhcpMagicHi
                    std ,x++
                    ldd #DhcpMagicLo
                    std ,x++
                    lda #DhcpOptType
                    sta ,x+
                    lda #1
                    sta ,x+
                    puls a
                    sta ,x+
                    cmpa #DhcpRequest
                    bne db3@
                    lda #DhcpOptReqIP
                    sta ,x+
                    lda #NetIPLen
                    sta ,x+
                    ldd dhcpip,u
                    std ,x++
                    ldd dhcpip+2,u
                    std ,x++
                    lda #DhcpOptServer
                    sta ,x+
                    lda #NetIPLen
                    sta ,x+
                    ldd dhcpserver,u
                    std ,x++
                    ldd dhcpserver+2,u
                    std ,x++
db3@                leay dhcpparams,pcr
                    ldb #DhcpParamsLen
db4@                lda ,y+
                    sta ,x+
                    decb
                    bne db4@
                    rts
* dhcpwait: A = the message type wanted: packets read until a reply to our transaction of that type (OFFER: its
* address and server kept; ACK: address, mask, router, DNS into netcfg). Carry: a NAK, nothing within EthRxWait,
* or DhcpPackets packets without it.
dhcpwait            sta dhcpwant,u
                    lda #DhcpPackets
                    sta dhcpleft,u
dw1@                lbsr netwaitrx
                    lbcs dw9@
                    lbsr netrecv
                    lbcs dw7@
                    leax netbuf+W61_UDP4_HDR,u
                    stx dhcpbase,u
                    tfr x,d
                    addd netlen,u
                    std dhcpend,u
                    lda DhcpOp,x
                    cmpa #DhcpBootReply
                    lbne dw7@
                    ldd DhcpXid,x
                    cmpd #DhcpXidHi
                    lbne dw7@
                    ldd DhcpXid+2,x
                    cmpd #DhcpXidLo
                    lbne dw7@
                    ldd DhcpCookie,x
                    cmpd #DhcpMagicHi
                    lbne dw7@
                    ldd DhcpCookie+2,x
                    cmpd #DhcpMagicLo
                    lbne dw7@
                    clr dhcptype,u
                    ldd netmask,u               options the server leaves out keep the settings
                    std dhcpmask,u
                    ldd netmask+2,u
                    std dhcpmask+2,u
                    ldd netgw,u
                    std dhcprouter,u
                    ldd netgw+2,u
                    std dhcprouter+2,u
                    ldd netdns,u
                    std dhcpdns,u
                    ldd netdns+2,u
                    std dhcpdns+2,u
                    leay DhcpOptions,x
dw2@                cmpy dhcpend,u              the options: code, length, value
                    lbhs dw5@
                    lda ,y+
                    cmpa #DhcpOptPad
                    beq dw2@
                    cmpa #DhcpOptEnd
                    lbeq dw5@
                    ldb ,y+
                    stb dhcpolen,u
                    cmpa #DhcpOptType
                    bne dw3@
                    ldb ,y
                    stb dhcptype,u
                    bra dw4@
dw3@                cmpa #DhcpOptServer
                    bne dw31@
                    leax dhcpserver,u
                    bra dw39@
dw31@               cmpa #DhcpOptMask
                    bne dw32@
                    leax dhcpmask,u
                    bra dw39@
dw32@               cmpa #DhcpOptRouter
                    bne dw33@
                    leax dhcprouter,u
                    bra dw39@
dw33@               cmpa #DhcpOptDns
                    bne dw4@
                    leax dhcpdns,u
dw39@               ldb dhcpolen,u              the option's first address, when it holds one
                    cmpb #NetIPLen
                    blo dw4@
                    ldd ,y
                    std ,x
                    ldd 2,y
                    std 2,x
dw4@               ldb dhcpolen,u              past the value
                    clra
                    leay d,y
                    lbra dw2@
dw5@                lda dhcptype,u
                    cmpa #DhcpNak
                    beq dw9@
                    cmpa dhcpwant,u
                    bne dw7@
                    ldx dhcpbase,u
                    cmpa #DhcpOffer
                    bne dw6@
                    ldd DhcpYiaddr,x            OFFER: the address offered
                    std dhcpip,u
                    ldd DhcpYiaddr+2,x
                    std dhcpip+2,u
                    andcc #^1
                    rts
dw6@                ldd DhcpYiaddr,x            ACK: the lease
                    std netip,u
                    ldd DhcpYiaddr+2,x
                    std netip+2,u
                    ldd dhcpmask,u
                    std netmask,u
                    ldd dhcpmask+2,u
                    std netmask+2,u
                    ldd dhcprouter,u
                    std netgw,u
                    ldd dhcprouter+2,u
                    std netgw+2,u
                    ldd dhcpdns,u
                    std netdns,u
                    ldd dhcpdns+2,u
                    std netdns+2,u
                    andcc #^1
                    rts
dw7@                dec dhcpleft,u
                    lbne dw1@
dw9@                orcc #1
                    rts
* netgwtry: A = DNS tries: GAR = netgw, then google.com looked up through it -> nethost. Carry: no answer.
netgwtry            pshs a
                    lda #W61_BLK_COMMON
                    sta ethblk,u
                    leax netgw,u
                    ldy #W61_GAR
                    ldb #NetIPLen
                    lbsr netblkwr
                    puls a
                    leax dnsgoogle,pcr
                    ldb #DnsGoogleLen
                    leay nethost,u
                    lbra netresolve
* netscan: x.x.x.1 upward to x.x.x.EthScanLast of this board's /24, itself skipped, each shown as it is tried:
* one that answers a short PING4 is tried as the gateway (netgwtry). Carry: none works. netgw = the one found.
* SLRTR and SLRCR are shortened for the scan, then set to their reset values (w6100eth's settings): putting
* back what was read left the next PING4 with the scan's values (1.8, 2026-10-10)
netscan             lda #W61_BLK_COMMON
                    sta ethblk,u
                    ldx #W61_SLRTR
                    ldd #EthScanRtr
                    pshs b
                    tfr a,b
                    lbsr ethwrite
                    leax 1,x
                    puls b
                    lbsr ethwrite
                    ldx #W61_SLRCR
                    clrb
                    lbsr ethwrite
                    ldd netip,u
                    std netcand,u
                    lda netip+2,u
                    sta netcand+2,u
                    lda #1
                    sta netcand+3,u
sc1@                lda netcand+3,u
                    cmpa netip+3,u
                    beq sc3@
                    lda vbase,u
                    adda #9
                    ldb #EthValCol
                    lbsr at
                    leax ethnscan,pcr
                    lbsr putz
                    leax netcand,u
                    lbsr netpip
                    lda #W61_BLK_COMMON
                    sta ethblk,u
                    leax netcand,u
                    ldy #W61_SLDIPR
                    ldb #NetIPLen
                    lbsr netblkwr
                    lbsr netping
                    bcs sc3@
                    ldd netcand,u               it answered: is it the way out?
                    std netgw,u
                    ldd netcand+2,u
                    std netgw+2,u
                    lda #EthScanTries
                    lbsr netgwtry
                    bcc sc8@
sc3@                lda netcand+3,u
                    inca
                    sta netcand+3,u
                    cmpa #EthScanLast
                    bls sc1@
                    bsr netsldefault
                    orcc #1
                    rts
sc8@                bsr netsldefault
                    andcc #^1
                    rts
* netsldefault: SLRTR and SLRCR at their reset values; B = the SLRCR value (netsldefault: the reset one)
netsldefault        ldb #W61_SLRCR_RESET
netslset            pshs b
                    lda #W61_BLK_COMMON
                    sta ethblk,u
                    ldx #W61_SLRTR
                    ldd #W61_SLRTR_RESET
                    pshs b
                    tfr a,b
                    lbsr ethwrite
                    leax 1,x
                    puls b
                    lbsr ethwrite
                    ldx #W61_SLRCR
                    puls b
                    lbra ethwrite
* netping: PING4 to SLDIPR (already written). Carry: the chip's timeout, or no reply within EthPingWait ticks.
netping             lda #W61_BLK_COMMON
                    sta ethblk,u
                    bsr netslclear
                    ldx #W61_SLCR
                    ldb #W61_SLCR_PING4
                    lbsr ethwrite
                    ldd #EthPingWait
                    std netwait,u
pg1@                ldx #W61_SLIR
                    lbsr ethread
                    bitb #W61_SLIR_PING4
                    bne pg3@
                    bitb #W61_SLIR_TOUT
                    bne pg2@
                    lbsr tick
                    ldd netwait,u
                    subd #1
                    std netwait,u
                    bne pg1@
pg2@                bsr netslclear
                    orcc #1
                    rts
pg3@                bsr netslclear
                    andcc #^1
                    rts
netslclear          ldx #W61_SLIRCLR
                    ldb #W61_SLIR_ALL
                    lbra ethwrite
* netconfig: netcfg = the defaults, then what /DD/SYS/w6100ipconfig sets; netsrcmsg = which of the two
netconfig           leax netdefaults,pcr
                    leay netcfg,u
                    ldb #NetCfgLen
nc1@                lda ,x+
                    sta ,y+
                    decb
                    bne nc1@
                    leax netcfgpath,pcr
                    lda #READ.
                    os9 I$Open
                    bcs nc3@
                    sta netpath,u
                    leax netbuf,u
                    ldy #NetCfgRead
                    os9 I$Read
                    bcs nc2@
                    leax netbuf,u
                    stx netptr,u
                    tfr y,d
                    leax d,x
                    stx netend,u
                    lda netpath,u
                    os9 I$Close
                    lbsr netparse
                    leax ethnfile,pcr
                    stx netsrcmsg,u
                    rts
nc2@                lda netpath,u
                    os9 I$Close
nc3@                leax ethndefs,pcr
                    stx netsrcmsg,u
                    rts
* netparse: the file's lines, "keyword value" or "keyword = value"; '#' or '*' starts a comment (w6100tel's
* ParseConfig)
netparse            ldd netptr,u
                    cmpd netend,u
                    lbhs np9@
                    lbsr netblanks
                    ldx netptr,u
                    cmpx netend,u
                    bhs np9@
                    lda ,x
                    cmpa #'#
                    beq np8@
                    cmpa #'*
                    beq np8@
                    cmpa #C$CR
                    beq np8@
                    cmpa #C$LF
                    beq np8@
                    lbsr netkeyword
                    bcs np8@
                    lda nettype,u
                    cmpa #NetTypeIP
                    bne np6@
                    lbsr netparseip
                    bra np8@
np6@                cmpa #NetTypeMAC
                    bne np7@
                    lbsr netparsemac
                    bra np8@
np7@                cmpa #NetTypeTZ
                    bne np8@
                    lbsr netparsetz
np8@                lbsr netnextline
                    bra netparse
np9@                rts
netblanks           ldx netptr,u
nb1@                cmpx netend,u
                    bhs nb3@
                    lda ,x
                    cmpa #C$SPAC
                    beq nb2@
                    cmpa #NetTab
                    bne nb3@
nb2@                leax 1,x
                    bra nb1@
nb3@                stx netptr,u
                    rts
netnextline         ldx netptr,u
nn1@                cmpx netend,u
                    bhs nn3@
                    lda ,x+
                    cmpa #C$CR
                    beq nn2@
                    cmpa #C$LF
                    bne nn1@
nn2@                cmpx netend,u
                    bhs nn3@
                    ldb ,x
                    cmpb #C$LF
                    beq nn4@
                    cmpb #C$CR
                    bne nn3@
nn4@                leax 1,x
nn3@                stx netptr,u
                    rts
* netkeyword: the line's keyword looked up in netkeys -> nettype, netdest; netptr at its value. Carry: unknown.
netkeyword          leax netkeys,pcr
                    stx netkw,u
nk1@                ldx netkw,u
                    ldb ,x
                    cmpb #NetKeyEnd
                    beq nk9@
                    stb nettype,u
                    ldd 1,x
                    leay d,u
                    sty netdest,u
                    leax 3,x
                    ldy netptr,u
nk2@                lda ,x+
                    beq nk4@
                    ldb ,y+
                    cmpb #'A
                    blo nk3@
                    cmpb #'Z
                    bhi nk3@
                    addb #NetLower
nk3@                pshs a
                    cmpb ,s+
                    beq nk2@
                    bra nk6@
nk4@                cmpy netend,u
                    bhs nk5@
                    lda ,y
                    cmpa #C$SPAC
                    beq nk5@
                    cmpa #NetTab
                    beq nk5@
                    cmpa #'=
                    beq nk5@
                    cmpa #C$CR
                    beq nk5@
                    cmpa #C$LF
                    bne nk6@
nk5@                sty netptr,u
                    lbsr netvalue
                    andcc #^1
                    rts
nk6@                ldx netkw,u
                    leax 3,x
nk7@                lda ,x+
                    bne nk7@
                    stx netkw,u
                    bra nk1@
nk9@                orcc #1
                    rts
netvalue            ldx netptr,u
nv1@                cmpx netend,u
                    bhs nv3@
                    lda ,x
                    cmpa #C$SPAC
                    beq nv2@
                    cmpa #NetTab
                    beq nv2@
                    cmpa #'=
                    bne nv3@
nv2@                leax 1,x
                    bra nv1@
nv3@                stx netptr,u
                    rts
netparseip          ldy netdest,u
                    clr netoctet,u
npi1@               lbsr netdecbyte
                    bcs npi2@
                    stb ,y+
                    inc netoctet,u
                    lda netoctet,u
                    cmpa #NetIPLen
                    beq npi2@
                    ldx netptr,u
                    cmpx netend,u
                    bhs npi2@
                    lda ,x
                    cmpa #'.
                    bne npi2@
                    leax 1,x
                    stx netptr,u
                    bra npi1@
npi2@               rts
* netparsetz: "tz" hours from UTC, optionally signed (2026-10-10)
netparsetz          ldx netptr,u
                    clr nettmp,u                the sign: 0 plus, 1 minus
                    lda ,x
                    cmpa #'-
                    bne ptz1@
                    inc nettmp,u
                    bra ptz2@
ptz1@               cmpa #'+
                    bne ptz3@
ptz2@               leax 1,x
                    stx netptr,u
ptz3@               lbsr netdecbyte
                    bcs ptz9@
                    tst nettmp,u
                    beq ptz4@
                    negb
ptz4@               ldx netdest,u
                    stb ,x
ptz9@               rts
* netdecbyte: a decimal number at netptr -> B (its low byte), netptr past it; carry: no digit there. Keeps Y.
netdecbyte          ldx netptr,u
                    clr netacc,u
                    clr netacc+1,u
                    ldb ,x
                    subb #'0
                    bcs ndb3@
                    cmpb #9
                    bhi ndb3@
ndb1@               ldb ,x
                    subb #'0
                    bcs ndb2@
                    cmpb #9
                    bhi ndb2@
                    pshs b
                    ldd netacc,u            netacc = netacc * 10 + the digit
                    aslb
                    rola
                    std nettmpw,u
                    aslb
                    rola
                    aslb
                    rola
                    addd nettmpw,u
                    addb ,s+
                    adca #0
                    std netacc,u
                    leax 1,x
                    bra ndb1@
ndb2@               stx netptr,u
                    ldb netacc+1,u
                    andcc #^1
                    rts
ndb3@               stx netptr,u
                    orcc #1
                    rts
netparsemac         ldy netdest,u
                    clr netoctet,u
npm1@               lbsr nethexbyte
                    bcs npm3@
                    stb ,y+
                    inc netoctet,u
                    lda netoctet,u
                    cmpa #NetMACLen
                    beq npm3@
                    ldx netptr,u
                    cmpx netend,u
                    bhs npm3@
                    lda ,x
                    cmpa #':
                    beq npm2@
                    cmpa #'-
                    bne npm3@
npm2@               leax 1,x
                    stx netptr,u
                    bra npm1@
npm3@               rts
* nethexbyte: one or two hex digits at netptr -> B; carry: none there
nethexbyte          ldx netptr,u
                    lda ,x
                    lbsr nethexnib
                    bcs nh3@
                    aslb
                    aslb
                    aslb
                    aslb
                    stb nettmp,u
                    leax 1,x
                    lda ,x
                    lbsr nethexnib
                    bcs nh2@
                    orb nettmp,u
                    leax 1,x
                    stx netptr,u
                    andcc #^1
                    rts
nh2@                ldb nettmp,u            a single digit
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    stx netptr,u
                    andcc #^1
                    rts
nh3@                stx netptr,u
                    orcc #1
                    rts
nethexnib           cmpa #'0
                    blo nx9@
                    cmpa #'9
                    bhi nx1@
                    tfr a,b
                    subb #'0
                    andcc #^1
                    rts
nx1@                anda #^NetLower
                    cmpa #'A
                    blo nx9@
                    cmpa #'F
                    bhi nx9@
                    tfr a,b
                    subb #'A-10
                    andcc #^1
                    rts
nx9@                orcc #1
                    rts
* netpip: X = an IPv4 address, printed dotted with a space after it. Keeps X.
netpip              pshs b,x
                    ldb #NetIPLen
pip1@               lda ,x+
                    lbsr netdec
                    decb
                    beq pip2@
                    lda #'.
                    lbsr putchar
                    bra pip1@
pip2@               lda #' '
                    lbsr putchar
                    puls b,x,pc
* netdec: A = 0-255 printed without leading zeros. Keeps D, X and Y.
netdec              pshs d
                    ldb #'0-1
dd1@                incb
                    suba #100
                    bcc dd1@
                    adda #100
                    pshs b                  stack +0: the hundreds digit
                    lbsr wsbyte2dig
                    puls a
                    cmpa #'0
                    beq dd2@
                    lbsr putchar
                    bra dd3@                hundreds printed: tens always
dd2@                lda <wsdec
                    cmpa #'0
                    beq dd4@
dd3@                lda <wsdec
                    lbsr putchar
dd4@                lda <wsdec+1
                    lbsr putchar
                    puls d,pc
* netblkwr: X = bytes, Y = the first register, B = the count; written in block ethblk. Keeps X and Y.
netblkwr            pshs b,x,y
nbw1@               ldb ,x+
                    pshs x
                    tfr y,x
                    lbsr ethwrite
                    puls x
                    leay 1,y
                    dec ,s
                    bne nbw1@
                    puls b,x,y,pc
* netblkchk: X = the bytes expected, Y = the first register, B = the count: read back from block ethblk, each
* difference counted in chkerrs. Keeps X and Y.
netblkchk           pshs b,x,y
nbc1@               pshs x
                    tfr y,x
                    lbsr ethread
                    puls x
                    cmpb ,x+
                    beq nbc2@
                    inc chkerrs,u
nbc2@               leay 1,y
                    dec ,s
                    bne nbc1@
                    puls b,x,y,pc
* netwr16: X = a socket 0 register, D = its 16-bit value (high byte first). Keeps X and D.
netwr16             pshs d
                    lda #W61_BLK_S0REG
                    sta ethblk,u
                    ldb ,s
                    lbsr ethwrite
                    leax 1,x
                    ldb 1,s
                    lbsr ethwrite
                    leax -1,x
                    puls d,pc
* netrd16: X = a socket 0 register -> D, read until two reads agree. Keeps X and Y.
netrd16             bsr netrd16x
                    std netprev,u
                    bsr netrd16x
                    cmpd netprev,u
                    bne netrd16
                    rts
netrd16x            lda #W61_BLK_S0REG
                    sta ethblk,u
                    lbsr ethread
                    stb netsval,u
                    leax 1,x
                    lbsr ethread
                    leax -1,x
                    lda netsval,u
                    rts
* netsockcmd: B = a socket 0 command, written to Sn_CR and waited on until the chip takes it (Sn_CR reads 0)
netsockcmd          pshs x,y
                    ldx #W61_Sn_CR
                    lda #W61_BLK_S0REG
                    sta ethblk,u
                    lbsr ethwrite
                    ldy #EthCmdWait
nsc1@               lbsr ethread
                    tstb
                    beq nsc2@
                    leay -1,y
                    bne nsc1@
nsc2@               puls x,y,pc
* netopen: socket 0 opened for UDP from port D, to the IPv4 address at X, port Y. Carry: it did not open.
netopen             pshs d,x,y                  stack +0: source port, +2: address, +4: port
* closed first (2026-10-10): an open socket keeps its old port and ignores OPEN
                    ldb #W61_Sn_CR_CLOSE
                    lbsr netsockcmd
                    ldy #EthUdpWait
nop1@               ldx #W61_Sn_SR
                    lbsr ethread
                    cmpb #W61_Sn_SR_CLOSED
                    beq nop2@
                    lbsr tick
                    leay -1,y
                    bne nop1@
nop2@               equ *
                    lda #W61_BLK_S0REG
                    sta ethblk,u
                    ldx #W61_Sn_MR
                    ldb #W61_Sn_MR_UDP4
                    lbsr ethwrite
                    ldx #W61_Sn_PORTR
                    ldd ,s
                    lbsr netwr16
                    ldb #W61_Sn_CR_OPEN
                    lbsr netsockcmd
                    ldy #EthUdpWait
no1@                ldx #W61_Sn_SR
                    lbsr ethread
                    cmpb #W61_Sn_SR_UDP
                    beq no2@
                    lbsr tick
                    leay -1,y
                    bne no1@
                    ldb #W61_Sn_CR_CLOSE
                    lbsr netsockcmd
                    orcc #1
                    puls d,x,y,pc
no2@                ldx 2,s
                    ldy #W61_Sn_DIPR
                    ldb #NetIPLen
                    lbsr netblkwr
                    ldx #W61_Sn_DPORTR
                    ldd 4,s
                    lbsr netwr16
                    andcc #^1
                    puls d,x,y,pc
* netwaitrx: a packet in socket 0's RX buffer within EthRxWait ticks. Carry: none came.
netwaitrx           ldy #EthRxWait
nw1@                ldx #W61_Sn_RX_RSR
                    lbsr netrd16
                    cmpd #W61_UDP4_HDR
                    bhs nw2@
                    lbsr tick
                    leay -1,y
                    bne nw1@
                    orcc #1
                    rts
nw2@                andcc #^1
                    rts
* netresolve: X = a DNS query, B = its length, A = tries, Y = 4 bytes for the address: the first A record from
* netdns:53 (w6100tel's DnsResolve). Carry: no answer.
netresolve          stx netq,u
                    stb netqlen,u
                    sta nettry,u
                    sty netout,u
                    ldd #EthDnsSrc
                    leax netdns,u
                    ldy #EthDnsPort
                    lbsr netopen
                    bcs nr9@
nr3@                ldx netq,u
                    ldb netqlen,u
                    clra
                    lbsr netsend
                    bcs nr6@
                    lbsr netwaitrx
                    bcs nr6@
                    lbsr netrecv
                    bcs nr6@
                    leax netbuf+W61_UDP4_HDR,u
                    ldd netlen,u
                    ldy netout,u
                    lbsr netparsedns
                    bcc nr8@
nr6@                dec nettry,u
                    bne nr3@
                    ldb #W61_Sn_CR_CLOSE
                    lbsr netsockcmd
nr9@                orcc #1
                    rts
nr8@                ldb #W61_Sn_CR_CLOSE
                    lbsr netsockcmd
                    andcc #^1
                    rts
* netntp: the time from ntphost:123 -> ntpsecs (seconds since 1900). Carry: no usable answer.
netntp              ldd #EthNtpSrc
                    leax ntphost,u
                    ldy #EthNtpPort
                    lbsr netopen
                    bcs nt9@
                    lda #EthNtpTries
                    sta nettry,u
nt1@                leax ntpquery,pcr
                    ldd #NtpLen
                    lbsr netsend
                    bcs nt2@
                    lbsr netwaitrx
                    bcs nt2@
                    lbsr netrecv
                    bcs nt2@
                    ldd netlen,u
                    cmpd #NtpLen
                    blo nt2@
                    leax netbuf+W61_UDP4_HDR,u
                    lda NtpFlags,x
                    anda #NtpModeMask
                    cmpa #NtpModeServer
                    bne nt2@
                    tst NtpStratum,x
                    beq nt2@
                    ldd NtpTxSecs,x
                    std ntpsecs,u
                    ldd NtpTxSecs+2,x
                    std ntpsecs+2,u
                    ldb #W61_Sn_CR_CLOSE
                    lbsr netsockcmd
                    andcc #^1
                    rts
nt2@                dec nettry,u
                    bne nt1@
                    ldb #W61_Sn_CR_CLOSE
                    lbsr netsockcmd
nt9@                orcc #1
                    rts
* netsend: X = the bytes, D = the count: into socket 0's TX buffer at Sn_TX_WR, then SEND and SENDOK waited
* for. Carry: the chip's timeout or none within EthSendWait ticks.
netsend             pshs x                  stack +0: the next byte
                    std netsendn,u
                    ldx #W61_Sn_TX_WR
                    lbsr netrd16
                    std netrd,u
                    lda #W61_BLK_S0TX
                    sta ethblk,u
ns1@                ldx ,s
                    ldb ,x+
                    stx ,s
                    ldx netrd,u
                    lbsr ethwrite
                    leax 1,x
                    stx netrd,u
                    ldd netsendn,u
                    subd #1
                    std netsendn,u
                    bne ns1@
                    ldx #W61_Sn_TX_WR
                    ldd netrd,u
                    lbsr netwr16
                    ldx #W61_Sn_IRCLR
                    ldb #W61_Sn_IR_SENDOK+W61_Sn_IR_TIMEOUT
                    lbsr ethwrite
                    ldb #W61_Sn_CR_SEND
                    lbsr netsockcmd
                    ldy #EthSendWait
ns2@                ldx #W61_Sn_IR
                    lbsr ethread
                    bitb #W61_Sn_IR_SENDOK
                    bne ns3@
                    bitb #W61_Sn_IR_TIMEOUT
                    bne ns4@
                    lbsr tick
                    leay -1,y
                    bne ns2@
ns4@                orcc #1
                    puls x,pc
ns3@                ldx #W61_Sn_IRCLR
                    ldb #W61_Sn_IR_SENDOK
                    lbsr ethwrite
                    andcc #^1
                    puls x,pc
* netrecv: one UDP packet from socket 0's RX buffer into netbuf (its W61_UDP4_HDR header, then the payload);
* netlen = the payload length; Sn_RX_RD advanced and RECV given either way. Carry: too long for netbuf (dropped).
netrecv             ldx #W61_Sn_RX_RD
                    lbsr netrd16
                    std netrd,u
                    lda #W61_BLK_S0RX
                    sta ethblk,u
                    ldx netrd,u
                    lbsr ethread
                    stb netlen,u
                    leax 1,x
                    lbsr ethread
                    stb netlen+1,u
                    lda netlen,u
                    anda #W61_UDP4_LENH
                    sta netlen,u
                    ldd netlen,u
                    addd #W61_UDP4_HDR
                    std nettotal,u
                    cmpd #NetBufSize
                    bhi nrc3@
                    std netcount,u
                    ldx netrd,u
                    leay netbuf,u
nrc1@               lbsr ethread
                    stb ,y+
                    leax 1,x
                    ldd netcount,u
                    subd #1
                    std netcount,u
                    bne nrc1@
                    bsr netrxdone
                    andcc #^1
                    rts
nrc3@               bsr netrxdone
                    orcc #1
                    rts
netrxdone           ldd netrd,u
                    addd nettotal,u
                    ldx #W61_Sn_RX_RD
                    lbsr netwr16
                    ldb #W61_Sn_CR_RECV
                    lbra netsockcmd
* netparsedns: X = a DNS answer, D = its length, Y = 4 bytes for the address: the first A record's address.
* Carry: not our ID, an error code, no A record, or a record past the end (w6100tel's DnsParseResp).
netparsedns         sty dnsout,u
                    pshs d
                    tfr x,d
                    addd ,s++
                    std dnsend,u
                    ldd ,x
                    cmpd #EthDnsId
                    lbne pd9@
                    lda 3,x
                    anda #DnsRcode
                    lbne pd9@
                    ldd 6,x
                    std dnsan,u
                    lbeq pd9@
                    ldd 4,x
                    std dnsqd,u
                    leax DnsHdrLen,x
                    stx dnscp,u
pd1@                ldd dnsqd,u             the questions skipped
                    beq pd2@
                    lbsr netskipname
                    ldx dnscp,u
                    leax DnsQTail,x
                    stx dnscp,u
                    ldd dnsqd,u
                    subd #1
                    std dnsqd,u
                    bra pd1@
pd2@                ldd dnsan,u             the answers until an A record
                    lbeq pd9@
                    lbsr netskipname
                    ldx dnscp,u
                    cmpx dnsend,u
                    lbhs pd9@
                    ldd DnsRrType,x
                    cmpd #DnsTypeA
                    bne pd3@
                    ldd DnsRrLen,x
                    cmpd #NetIPLen
                    bne pd3@
                    leax DnsRrData,x
                    ldy dnsout,u
                    ldd ,x
                    std ,y
                    ldd 2,x
                    std 2,y
                    andcc #^1
                    rts
pd3@                ldd DnsRrLen,x
                    leax DnsRrData,x
                    leax d,x
                    stx dnscp,u
                    ldd dnsan,u
                    subd #1
                    std dnsan,u
                    bra pd2@
pd9@                orcc #1
                    rts
* netskipname: dnscp moved past a name (labels, or a compression pointer)
netskipname         ldx dnscp,u
sn1@                cmpx dnsend,u
                    bhs sn2@
                    lda ,x
                    beq sn2@
                    tfr a,b
                    andb #DnsPtr
                    cmpb #DnsPtr
                    beq sn3@
                    leax 1,x
                    leax a,x
                    bra sn1@
sn2@                leax 1,x
                    stx dnscp,u
                    rts
sn3@                leax 2,x
                    stx dnscp,u
                    rts
* ntpdate: ntpsecs + nettz hours -> ntpcent, ntpyy, ntpmon, ntpmday, ntphh, ntpmm, ntpss, ntpdow (1 = Sunday)
ntpdate             ldd ntpsecs,u
                    std ntpnum,u
                    ldd ntpsecs+2,u
                    std ntpnum+2,u
                    lda nettz,u
                    beq nd3@
                    bpl nd1@
                    nega
nd1@                pshs a                      stack +0: hours left
                    ldd #0
nd2@                addd #NtpHour
                    dec ,s
                    bne nd2@
                    leas 1,s
                    std ntpspan,u                the zone's seconds
                    tst nettz,u
                    bmi nd4@
                    ldd ntpnum+2,u
                    addd ntpspan,u
                    std ntpnum+2,u
                    ldd ntpnum,u
                    adcb #0
                    adca #0
                    std ntpnum,u
                    bra nd3@
nd4@                ldd ntpnum+2,u
                    subd ntpspan,u
                    std ntpnum+2,u
                    ldd ntpnum,u
                    sbcb #0
                    sbca #0
                    std ntpnum,u
nd3@                ldd #NtpDayHi               days and the second of the day
                    std ntpden,u
                    ldd #NtpDayLo
                    std ntpden+2,u
                    lbsr ntpdiv
                    ldd ntpnum+2,u
                    std ntpdays,u
                    ldd ntprem,u
                    std ntpnum,u
                    ldd ntprem+2,u
                    std ntpnum+2,u
                    clr ntpden,u
                    clr ntpden+1,u
                    ldd #NtpHour
                    std ntpden+2,u
                    lbsr ntpdiv
                    lda ntpnum+3,u
                    sta ntphh,u
                    clr ntpnum,u
                    clr ntpnum+1,u
                    ldd ntprem+2,u
                    std ntpnum+2,u
                    ldd #NtpMinute
                    std ntpden+2,u
                    lbsr ntpdiv
                    lda ntpnum+3,u
                    sta ntpmm,u
                    lda ntprem+3,u
                    sta ntpss,u
                    ldx ntpdays,u               the day of the week
                    leax 1,x
                    lda #NtpWeek
                    lbsr wsdiv16x8
                    incb
                    stb ntpdow,u
                    ldd #NtpEpoch               the year
                    std ntpyear,u
ny1@                lbsr ntpleapyear
                    ldd #NtpYearDays
                    addb ntpleap,u
                    adca #0
                    std ntpspan,u
                    ldd ntpdays,u
                    cmpd ntpspan,u
                    blo ny2@
                    subd ntpspan,u
                    std ntpdays,u
                    ldd ntpyear,u
                    addd #1
                    std ntpyear,u
                    bra ny1@
ny2@                leay ntpmonths,pcr          the month
                    lda #1
                    sta ntpmon,u
nm1@                ldb ,y+
                    lda ntpmon,u
                    cmpa #NtpFeb
                    bne nm2@
                    addb ntpleap,u
nm2@                clra
                    std ntpspan,u
                    ldd ntpdays,u
                    cmpd ntpspan,u
                    blo nm3@
                    subd ntpspan,u
                    std ntpdays,u
                    inc ntpmon,u
                    bra nm1@
nm3@                ldb ntpdays+1,u
                    incb
                    stb ntpmday,u
                    ldx ntpyear,u               century and year of the century
                    lda #NtpCentury
                    lbsr wsdiv16x8
                    stb ntpyy,u
                    tfr x,d
                    stb ntpcent,u
                    rts
* ntpleapyear: ntpleap = 1 when ntpyear is a leap year (1900 is not; 1901-2099 every fourth)
ntpleapyear         clr ntpleap,u
                    ldd ntpyear,u
                    cmpd #NtpEpoch
                    beq nl9@
                    andb #3
                    bne nl9@
                    inc ntpleap,u
nl9@                rts
* ntpdiv: ntpnum / ntpden (32 bits each, unsigned) -> ntpnum the quotient, ntprem the remainder
ntpdiv              clr ntprem,u
                    clr ntprem+1,u
                    clr ntprem+2,u
                    clr ntprem+3,u
                    lda #32
                    sta ntpcnt,u
dv1@                lsl ntpnum+3,u
                    rol ntpnum+2,u
                    rol ntpnum+1,u
                    rol ntpnum,u
                    rol ntprem+3,u
                    rol ntprem+2,u
                    rol ntprem+1,u
                    rol ntprem,u
                    ldd ntprem+2,u
                    subd ntpden+2,u
                    pshs d
                    ldd ntprem,u
                    sbcb ntpden+1,u
                    sbca ntpden,u
                    bcs dv2@
                    std ntprem,u
                    puls d
                    std ntprem+2,u
                    inc ntpnum+3,u
                    bra dv3@
dv2@                leas 2,s
dv3@                dec ntpcnt,u
                    bne dv1@
                    rts
* ntpsetrtc: the date and time into the RTC under UTI, 24-hour, running on battery (RTC_STOP), the day of the
* week and century included; then the OS clock by F$STime (clock2_wildbits writes the same into the RTC again)
ntpsetrtc           ldx #RTC.Base
                    lda RTC_CTRL,x
                    ora #RTC_UTI|RTC_24HR|RTC_STOP
                    sta RTC_CTRL,x
                    lda ntpss,u
                    lbsr wsbin2bcd
                    sta RTC_SEC,x
                    lda ntpmm,u
                    lbsr wsbin2bcd
                    sta RTC_MIN,x
                    lda ntphh,u
                    lbsr wsbin2bcd
                    sta RTC_HRS,x
                    lda ntpmday,u
                    lbsr wsbin2bcd
                    sta RTC_DAY,x
                    lda ntpdow,u
                    lbsr wsbin2bcd
                    sta RTC_DOW,x
                    lda ntpmon,u
                    lbsr wsbin2bcd
                    sta RTC_MONTH,x
                    lda ntpyy,u
                    lbsr wsbin2bcd
                    sta RTC_YEAR,x
                    lda ntpcent,u
                    lbsr wsbin2bcd
                    sta RTC_CENTURY,x
                    lda RTC_CTRL,x
                    anda #^RTC_UTI
                    sta RTC_CTRL,x
                    ldd ntpyear,u
                    subd #NtpEpoch
                    stb ntptime,u
                    lda ntpmon,u
                    sta ntptime+1,u
                    lda ntpmday,u
                    sta ntptime+2,u
                    lda ntphh,u
                    sta ntptime+3,u
                    lda ntpmm,u
                    sta ntptime+4,u
                    lda ntpss,u
                    sta ntptime+5,u
                    leax ntptime,u
                    os9 F$STime
                    rts
* ntpshow: "YYYY-MM-DD HH:MM:SS UTC-5 "
ntpshow             lda ntpcent,u
                    lbsr rtcdec2
                    lda ntpyy,u
                    lbsr rtcdec2
                    lda #'-
                    lbsr putchar
                    lda ntpmon,u
                    lbsr rtcdec2
                    lda #'-
                    lbsr putchar
                    lda ntpmday,u
                    lbsr rtcdec2
                    lda #' '
                    lbsr putchar
                    lda ntphh,u
                    lbsr rtcdec2
                    lda #':
                    lbsr putchar
                    lda ntpmm,u
                    lbsr rtcdec2
                    lda #':
                    lbsr putchar
                    lda ntpss,u
                    lbsr rtcdec2
                    leax ethnutc,pcr
                    lbsr putz
                    lda nettz,u
                    beq ns9@
                    ldb #'+
                    tsta
                    bpl ns8@
                    ldb #'-
                    nega
ns8@                exg a,b
                    lbsr putchar
                    tfr b,a
                    lbsr netdec
ns9@                lda #' '
                    lbra putchar
ntpmonths           fcb 31,28,31,30,31,30,31,31,30,31,30,31
netzero             fcb 0,0,0,0
netbcast            fcb 255,255,255,255
dhcpparams          fcb DhcpOptParams,3,DhcpOptMask,DhcpOptRouter,DhcpOptDns,DhcpOptEnd
DhcpParamsLen       equ *-dhcpparams
ntpquery            fcb NtpRequest
                    zmb NtpLen-1
dnsgoogle           fdb EthDnsId,DnsFlagsRD,1,0,0,0  one question:
                    fcb 6
                    fcc "google"
                    fcb 3
                    fcc "com"
                    fcb 0
                    fdb DnsTypeA,DnsClassIN
DnsGoogleLen        equ *-dnsgoogle
dnsntp              fdb EthDnsId,DnsFlagsRD,1,0,0,0
                    fcb 4
                    fcc "pool"
                    fcb 3
                    fcc "ntp"
                    fcb 3
                    fcc "org"
                    fcb 0
                    fdb DnsTypeA,DnsClassIN
DnsNtpLen           equ *-dnsntp
* w6100eth's defaults (DNS from w6100tel), used only when no DHCP server answers, in netcfg's order: MAC, IP,
* mask, gateway, DNS, server (none: the gateway is pinged), tz (hours from UTC; 0 unless the file sets "tz")
netdefaults         fcb $02,$00,$00,$12,$34,$56
                    fcb 192,168,1,222
                    fcb 255,255,255,0
                    fcb 192,168,1,254
                    fcb 8,8,8,8
                    fcb 0,0,0,0                    the ping target: none, so the gateway
                    fcb 0                          UTC; "tz" in the file for local time
netcfgpath          fcc "/DD/SYS/w6100ipconfig"
                    fcb C$CR
* netkeys: value type, netcfg field, keyword (lower case), 0; the w6100 tools' keywords and tz
netkeys             fcb NetTypeMAC
                    fdb netmac
                    fcc "mac"
                    fcb 0
                    fcb NetTypeIP
                    fdb netip
                    fcc "ip"
                    fcb 0
                    fcb NetTypeIP
                    fdb netmask
                    fcc "mask"
                    fcb 0
                    fcb NetTypeIP
                    fdb netmask
                    fcc "netmask"
                    fcb 0
                    fcb NetTypeIP
                    fdb netmask
                    fcc "subnet"
                    fcb 0
                    fcb NetTypeIP
                    fdb netgw
                    fcc "gateway"
                    fcb 0
                    fcb NetTypeIP
                    fdb netgw
                    fcc "gw"
                    fcb 0
                    fcb NetTypeIP
                    fdb netdns
                    fcc "dns"
                    fcb 0
                    fcb NetTypeIP
                    fdb netsrv
                    fcc "server"
                    fcb 0
                    fcb NetTypeIP
                    fdb netsrv
                    fcc "target"
                    fcb 0
                    fcb NetTypeIP
                    fdb netsrv
                    fcc "ping"
                    fcb 0
                    fcb NetTypeTZ
                    fdb nettz
                    fcc "tz"
                    fcb 0
                    fcb NetKeyEnd
ethl9               fcc "Link                 "
                    fcb 0
ethl10              fcc "Get IP               "
                    fcb 0
ethl11              fcc "Gateway              "
                    fcb 0
ethl12              fcc "google.com (DNS)     "
                    fcb 0
ethl13              fcc "Ping server          "
                    fcb 0
ethl14              fcc "NTP -> RTC, OS clock "
                    fcb 0
ethnup              fcc "up "
                    fcb 0
ethndown            fcc "down after 5 s "
                    fcb 0
ethnfile            fcc "(w6100ipconfig) "
                    fcb 0
ethndhcp            fcc "(DHCP) "
                    fcb 0
ethnodhcp           fcc "no DHCP "
                    fcb 0
* dhcpsteps: by DhcpStOpen..DhcpStAck, each followed by the socket status in hex
dhcpsteps           fcc "open, SR $"
                    fcb 0
                    fcc "DISCOVER, SR $"
                    fcb 0
                    fcc "OFFER, SR $"
                    fcb 0
                    fcc "REQUEST, SR $"
                    fcb 0
                    fcc "ACK, SR $"
                    fcb 0
ethnsemi            fcc "; "
                    fcb 0
ethndefs            fcc "(default) "
                    fcb 0
ethnscan            fcc "scan "
                    fcb 0
ethnfound           fcc "found by scan   "
                    fcb 0
ethnnogw            fcc "none of .1-.254 reaches the DNS server "
                    fcb 0
ethnreply           fcc "reply "
                    fcb 0
ethnoreply          fcc "no reply "
                    fcb 0
ethnontp            fcc "no answer from pool.ntp.org "
                    fcb 0
ethngwtag           fcc "(gateway) "
                    fcb 0
ethnutc             fcc " UTC"
                    fcb 0
ethids              fcb W61_CIDR0_ID,W61_CIDR1_ID,W61_VER0_ID,W61_VER1_ID
ethhelp             fcc "K2 W6100: chip, link, DHCP, gateway, DNS, PING4 server/gateway, NTP->RTC."
                    fcb 0
ethok               fcc "Ethernet: chip, link, DHCP, gateway, DNS, ping and NTP all pass; RTC set."
                    fcb 0
ethoknt             fcc "Ethernet: chip, link, DHCP, gateway, DNS and ping pass; no NTP (SKIP)."
                    fcb 0
ethbad              fcc "Ethernet: FAIL - "
                    fcb 0
ethl1               fcc "Adapter latches      "
                    fcb 0
ethl2               fcc "Chip ID/version      "
                    fcb 0
ethl3               fcc "SYSR bus mode        "
                    fcb 0
ethl4               fcc "IDM_ARH round trip   "
                    fcb 0
ethl5               fcc "PINGSEQR0 walk 1s/0s "
                    fcb 0
ethl6               fcc "PINGIDR0/1 apart     "
                    fcb 0
ethl7               fcc "PHYSR                "
                    fcb 0
ethl8               fcc "An adapter transfer never finished (busy stuck)"
                    fcb 0
ethlocks            fcc "SYSR "
                    fcb 0
ethbits             fcc " bad bits of 16 "
                    fcb 0
ethvok              fcc " OK "
                    fcb 0
ethvbad             fcc " BAD"
                    fcb 0
ethvskip            fcc " SKIP"
                    fcb 0
ethcabin            fcc " cable in,"
                    fcb 0
ethcabout           fcc " cable OUT,"
                    fcb 0
ethlinkup           fcc " link up,"
                    fcb 0
ethlinkdn           fcc " link down"
                    fcb 0
eth100              fcc " 100 Mbps,"
                    fcb 0
eth10               fcc " 10 Mbps,"
                    fcb 0
ethfull             fcc " full duplex"
                    fcb 0
ethhalf             fcc " half duplex"
                    fcb 0
* C CPU speed (2026-10-09, user: 'add cpu speed test (wildspeed) to the diag as "S" option'): wildspeed edition 5's
* measurement (level1/wildbits/cmds/wildspeed.asm), unchanged: for each bus-cycle class, align on an RTC second
* edge, run calibrated chunks of a cycle-counted loop with IRQs masked for WsSecs seconds, and turn the chunk
* (2026-10-10, user: "FIX THE WONKY PS/2 sync bug"): 1 s windows, IRQs masked only inside them - 3 s windows
* plus an IRQ-off wait for the edge held the PS/2 FIFOs (256 bytes; a moving mouse sends ~120 a second) unread
* for up to 4 s, and the bytes they dropped misframed the mouse driver for good. The factors are 1/4 scale so
* they fit 16 bits at 1 s; wsfinish shifts the product back.
* count into MHz*100 = hi16(chunks * factor + $8000). The loops address their counters in the direct page (the
* ws* variables open the data area), as wildspeed's do, so its cycle counts and factors hold. The software clock
* ends ~WsSecs*7 seconds slow (setime / ntptime resync it).
WsSecs              equ 1                       RTC seconds per class window (IRQs masked)
WsScale             equ 4                       the factors' scale-down; wsfinish multiplies back (2 bit shifts)
WsEpi               equ 53                      the epilogue below, counted once a chunk
WsItFet             equ 2333                    fetch : nop 2 nop 2 leay 5 bne 3 = 12 a pass
WsCyFet             equ WsItFet*12+4+WsEpi
WsItRam             equ 700                     RAM rd/wr: 8 x lda/sta ,x (4) + 8 = 40
WsCyRam             equ WsItRam*40+9+WsEpi
WsItIo              equ 583                     IO rd/wr: 8 x lda/sta >ext (5) + 8 = 48
WsCyIoRd            equ WsItIo*48+4+WsEpi
WsCyIoWr            equ WsItIo*48+9+WsEpi
WsCyRtc             equ WsItRam*40+7+WsEpi      RTC rd: 8 x lda ,x (bus-stretched) + 8
WsItMul             equ 292                     internal: 8 x mul (11) + 8 = 96
WsCyMul             equ WsItMul*96+4+WsEpi
* factor = round(65536 * cycles / (WsSecs * 10000 * WsScale)); lwasm evaluates in 32 bits
WsFFet              equ (65536*WsCyFet+(WsSecs*5000*WsScale))/(WsSecs*10000*WsScale)
WsFRam              equ (65536*WsCyRam+(WsSecs*5000*WsScale))/(WsSecs*10000*WsScale)
WsFIoRd             equ (65536*WsCyIoRd+(WsSecs*5000*WsScale))/(WsSecs*10000*WsScale)
WsFIoWr             equ (65536*WsCyIoWr+(WsSecs*5000*WsScale))/(WsSecs*10000*WsScale)
WsFRtc              equ (65536*WsCyRtc+(WsSecs*5000*WsScale))/(WsSecs*10000*WsScale)
WsFMul              equ (65536*WsCyMul+(WsSecs*5000*WsScale))/(WsSecs*10000*WsScale)
* the perceived blend's weights (sum 100), as wildspeed's
WsWFet              equ 45
WsWRamRd            equ 25
WsWRamWr            equ 12
WsWIoRd             equ 6
WsWIoWr             equ 4
WsWRtc              equ 3
WsWMul              equ 5
WsEdgeOuter         equ 16                      wsalign: passes of 65,536 RTC reads before giving up
WsValCol            equ 43                      where "measuring..." starts; the value's two spaces cover it
* Every class loop ends each chunk with the same epilogue (53 cycles, WsEpi): chunk + 1, then the RTC second against
* the target. It is written out in each loop, as wildspeed has it, so the counted cycles stay exact.
speedstart          tfr cc,a                CC as found (interrupts on), put back at both ends (2026-10-10)
                    sta wscc,u
                    lda vbase,u
                    leax wsl0,pcr
                    lbsr wsbegin
* class 0: fetch / internal
                    lbsr wsalign
                    lbcs wsstuck
ws0c@               ldy #WsItFet            4
ws0i@               nop                     2
                    nop                     2
                    leay -1,y               5
                    bne ws0i@               3
                    ldd <wschunks           5
                    addd #1                 4
                    std <wschunks           5
                    ldx #RTC.Base           3
                    lda RTC_CTRL,x          5
                    ora #(RTC_UTI|RTC_24HR) 2
                    sta RTC_CTRL,x          5
                    lda RTC_SEC,x           5
                    ldb RTC_CTRL,x          5
                    andb #^(RTC_UTI)        2
                    stb RTC_CTRL,x          5
                    cmpa <wstarget          4
                    bne ws0c@               3
                    ldx #WsFFet
                    lbsr wsfinish
                    std <wsresult
                    tfr d,x
                    lda vbase,u
                    lbsr wsshowx
* class 1: RAM read
                    lda vbase,u
                    adda #1
                    leax wsl1,pcr
                    lbsr wsbegin
                    lbsr wsalign
                    lbcs wsstuck
ws1c@               leax wsscratch,u        5
                    ldy #WsItRam            4
ws1i@               lda ,x
                    lda ,x
                    lda ,x
                    lda ,x
                    lda ,x
                    lda ,x
                    lda ,x
                    lda ,x
                    leay -1,y
                    bne ws1i@
                    ldd <wschunks
                    addd #1
                    std <wschunks
                    ldx #RTC.Base
                    lda RTC_CTRL,x
                    ora #(RTC_UTI|RTC_24HR)
                    sta RTC_CTRL,x
                    lda RTC_SEC,x
                    ldb RTC_CTRL,x
                    andb #^(RTC_UTI)
                    stb RTC_CTRL,x
                    cmpa <wstarget
                    bne ws1c@
                    ldx #WsFRam
                    lbsr wsfinish
                    std <wsresult+2
                    tfr d,x
                    lda vbase,u
                    adda #1
                    lbsr wsshowx
* class 2: RAM write
                    lda vbase,u
                    adda #2
                    leax wsl2,pcr
                    lbsr wsbegin
                    lbsr wsalign
                    lbcs wsstuck
ws2c@               leax wsscratch,u
                    ldy #WsItRam
ws2i@               sta ,x
                    sta ,x
                    sta ,x
                    sta ,x
                    sta ,x
                    sta ,x
                    sta ,x
                    sta ,x
                    leay -1,y
                    bne ws2i@
                    ldd <wschunks
                    addd #1
                    std <wschunks
                    ldx #RTC.Base
                    lda RTC_CTRL,x
                    ora #(RTC_UTI|RTC_24HR)
                    sta RTC_CTRL,x
                    lda RTC_SEC,x
                    ldb RTC_CTRL,x
                    andb #^(RTC_UTI)
                    stb RTC_CTRL,x
                    cmpa <wstarget
                    bne ws2c@
                    ldx #WsFRam
                    lbsr wsfinish
                    std <wsresult+4
                    tfr d,x
                    lda vbase,u
                    adda #2
                    lbsr wsshowx
* IO classes (2026-10-10, from the RTL: IRQ_Controller_Jr.v drops any interrupt event in the clock of a write to
* $FE20-$FE2F, and the Jr2 PS/2 keyboard interrupt is one pulse per FIFO empty->non-empty, so millions of INT_MASK_0
* writes lost key interrupts for good): MATH_MUL_A, fixed I/O with no side effect, is read and written instead
* class 3: fixed-IO read
                    lda vbase,u
                    adda #3
                    leax wsl3,pcr
                    lbsr wsbegin
                    lbsr wsalign
                    lbcs wsstuck
ws3c@               ldy #WsItIo
ws3i@               lda >MATH_MUL_A
                    lda >MATH_MUL_A
                    lda >MATH_MUL_A
                    lda >MATH_MUL_A
                    lda >MATH_MUL_A
                    lda >MATH_MUL_A
                    lda >MATH_MUL_A
                    lda >MATH_MUL_A
                    leay -1,y
                    bne ws3i@
                    ldd <wschunks
                    addd #1
                    std <wschunks
                    ldx #RTC.Base
                    lda RTC_CTRL,x
                    ora #(RTC_UTI|RTC_24HR)
                    sta RTC_CTRL,x
                    lda RTC_SEC,x
                    ldb RTC_CTRL,x
                    andb #^(RTC_UTI)
                    stb RTC_CTRL,x
                    cmpa <wstarget
                    bne ws3c@
                    ldx #WsFIoRd
                    lbsr wsfinish
                    std <wsresult+6
                    tfr d,x
                    lda vbase,u
                    adda #3
                    lbsr wsshowx
* class 4: fixed-IO write (MATH_MUL_A, its own value back)
                    lda vbase,u
                    adda #4
                    leax wsl4,pcr
                    lbsr wsbegin
                    lbsr wsalign
                    lbcs wsstuck
ws4c@               lda >MATH_MUL_A
                    ldy #WsItIo
ws4i@               sta >MATH_MUL_A
                    sta >MATH_MUL_A
                    sta >MATH_MUL_A
                    sta >MATH_MUL_A
                    sta >MATH_MUL_A
                    sta >MATH_MUL_A
                    sta >MATH_MUL_A
                    sta >MATH_MUL_A
                    leay -1,y
                    bne ws4i@
                    ldd <wschunks
                    addd #1
                    std <wschunks
                    ldx #RTC.Base
                    lda RTC_CTRL,x
                    ora #(RTC_UTI|RTC_24HR)
                    sta RTC_CTRL,x
                    lda RTC_SEC,x
                    ldb RTC_CTRL,x
                    andb #^(RTC_UTI)
                    stb RTC_CTRL,x
                    cmpa <wstarget
                    bne ws4c@
                    ldx #WsFIoWr
                    lbsr wsfinish
                    std <wsresult+8
                    tfr d,x
                    lda vbase,u
                    adda #4
                    lbsr wsshowx
* class 5: RTC read (the external bus, RDY-stretched)
                    lda vbase,u
                    adda #5
                    leax wsl5,pcr
                    lbsr wsbegin
                    lbsr wsalign
                    lbcs wsstuck
ws5c@               ldx #RTC.Base+RTC_SEC
                    ldy #WsItRam
ws5i@               lda ,x
                    lda ,x
                    lda ,x
                    lda ,x
                    lda ,x
                    lda ,x
                    lda ,x
                    lda ,x
                    leay -1,y
                    bne ws5i@
                    ldd <wschunks
                    addd #1
                    std <wschunks
                    ldx #RTC.Base
                    lda RTC_CTRL,x
                    ora #(RTC_UTI|RTC_24HR)
                    sta RTC_CTRL,x
                    lda RTC_SEC,x
                    ldb RTC_CTRL,x
                    andb #^(RTC_UTI)
                    stb RTC_CTRL,x
                    cmpa <wstarget
                    bne ws5c@
                    ldx #WsFRtc
                    lbsr wsfinish
                    std <wsresult+10
                    tfr d,x
                    lda vbase,u
                    adda #5
                    lbsr wsshowx
* class 6: internal (dead) cycles
                    lda vbase,u
                    adda #6
                    leax wsl6,pcr
                    lbsr wsbegin
                    lbsr wsalign
                    lbcs wsstuck
ws6c@               ldy #WsItMul
ws6i@               mul
                    mul
                    mul
                    mul
                    mul
                    mul
                    mul
                    mul
                    leay -1,y
                    bne ws6i@
                    ldd <wschunks
                    addd #1
                    std <wschunks
                    ldx #RTC.Base
                    lda RTC_CTRL,x
                    ora #(RTC_UTI|RTC_24HR)
                    sta RTC_CTRL,x
                    lda RTC_SEC,x
                    ldb RTC_CTRL,x
                    andb #^(RTC_UTI)
                    stb RTC_CTRL,x
                    cmpa <wstarget
                    bne ws6c@
                    ldx #WsFMul
                    lbsr wsfinish
                    std <wsresult+12
                    tfr d,x
                    lda vbase,u
                    adda #6
                    lbsr wsshowx
* perceived = sum(weight * MHz*100) / 100, in 32 bits
                    clra
                    clrb
                    std <wsacc
                    std <wsacc+2
                    leay wsweights,pcr
                    leax wsresult,u
                    ldb #7
wsbl@               pshs b,x,y
                    ldd ,x
                    ldx ,y
                    lbsr wsaccmul
                    puls b,x,y
                    leax 2,x
                    leay 2,y
                    decb
                    bne wsbl@
                    ldx #0
wsdiv@              ldd <wsacc+2
                    subd #100
                    std <wsacc+2
                    lda <wsacc+1
                    sbca #0
                    sta <wsacc+1
                    lda <wsacc
                    sbca #0
                    sta <wsacc
                    bcs wsdivd@             negative: X is the quotient
                    leax 1,x
                    bra wsdiv@
wsdivd@             pshs x
                    lda vbase,u
                    adda #7
                    leax wsl7,pcr
                    lbsr wsbegin
                    puls x
                    lda vbase,u
                    adda #7
                    lbsr wsshowx
                    lda wscc,u
                    tfr a,cc
                    lbsr setpass
                    leax speedok,pcr
                    lbra message
* wsstuck: the RTC second never changed - no timebase, so no measurement (2026-10-10)
wsstuck             lda wscc,u
                    tfr a,cc
                    lbsr setfail
                    leax wsnortc,pcr
                    lbra message
* wsbegin: A = the row, X = the class label: printed with "measuring..." in the value's place
wsbegin             lbsr clearrow
                    lbsr putz
                    leax wsmeas,pcr
                    lbra putz
* wsalign: spin to an RTC second edge with IRQs on, then mask them for the window; the target WsSecs on; the
* chunk count zeroed. A second that does not change within WsEdgeOuter x 65,536 reads ends the test. Carry: no
* edge (IRQs still on).
wsalign             lbsr wsrtcsec
                    sta <wsstart
                    lda #WsEdgeOuter
                    sta <wsguard
                    ldy #0
wsal1@              lbsr wsrtcsec
                    cmpa <wsstart
                    bne wsal3@
                    leay -1,y
                    bne wsal1@
                    dec <wsguard
                    bne wsal1@
                    orcc #1
                    rts
wsal3@              orcc #IntMasks          the edge: the window starts, IRQs off until wsfinish
                    sta <wsstart
                    lbsr wsbcd2bin
                    addb #WsSecs
                    cmpb #60
                    blo wsal2@
                    subb #60
wsal2@              tfr b,a
                    lbsr wsbin2bcd
                    sta <wstarget
                    clra
                    clrb
                    std <wschunks
                    rts
* wsfinish: IRQs back on; D = round(chunks * X * WsScale / 65536) = MHz*100
wsfinish            andcc #^IntMasks
                    ldd <wschunks
                    lbsr wsmul16
                    ldb #2                  x WsScale (4): the product two bits left
wsf0@               lsl <wsprod+3
                    rol <wsprod+2
                    rol <wsprod+1
                    rol <wsprod
                    decb
                    bne wsf0@
                    ldd <wsprod+2
                    cmpd #$8000
                    ldd <wsprod             (ldd keeps the carry cmpd set)
                    blo wsf1@
                    addd #1
wsf1@               rts
* wsaccmul: wsacc += D * X
wsaccmul            lbsr wsmul16
                    ldd <wsprod+2
                    addd <wsacc+2
                    std <wsacc+2
                    ldd <wsprod
                    adcb <wsacc+1
                    stb <wsacc+1
                    adca <wsacc
                    sta <wsacc
                    rts
* wsshowx: A = the row, X = MHz*100: shown as "  nn.nn Mhz" from column WsValCol, the two spaces over the "me"
* of "measuring..." (2026-10-10, user)
wsshowx             ldb #WsValCol
                    lbsr at
                    lda #' '
                    lbsr putchar
                    lbsr putchar
                    lda #100
                    lbsr wsdiv16x8          X = whole MHz, B = hundredths
                    pshs b
                    tfr x,d
                    tfr b,a
                    lbsr wsbyte2dig
                    ldd <wsdec
                    std <wsint
                    puls a
                    lbsr wsbyte2dig
                    lda <wsint
                    cmpa #'0'
                    bne wss1@
                    lda #' '
wss1@               lbsr putchar
                    lda <wsint+1
                    lbsr putchar
                    lda #'.'
                    lbsr putchar
                    lda <wsdec
                    lbsr putchar
                    lda <wsdec+1
                    lbsr putchar
                    leax wsmhz,pcr
                    lbra putz
* wsrtcsec: A = the RTC seconds (BCD), registers latched for the read. Keeps X.
wsrtcsec            pshs x,b
                    ldx #RTC.Base
                    lda RTC_CTRL,x
                    ora #(RTC_UTI|RTC_24HR)
                    sta RTC_CTRL,x
                    ldb RTC_SEC,x
                    lda RTC_CTRL,x
                    anda #^(RTC_UTI)
                    sta RTC_CTRL,x
                    tfr b,a
                    puls x,b,pc
* wsbcd2bin: A (BCD) -> B (binary)
wsbcd2bin           clrb
wsbb1@              cmpa #$10
                    bcs wsbb2@
                    addd #$F00A             A - $10, B + 10
                    bra wsbb1@
wsbb2@              pshs a
                    addb ,s+
                    rts
* wsbin2bcd: A (0-59) -> A (BCD)
wsbin2bcd           pshs b
                    clrb
wsbd1@              cmpa #10
                    bcs wsbd2@
                    suba #10
                    addb #$10
                    bra wsbd1@
wsbd2@              pshs b
                    adda ,s+
                    puls b,pc
* wsmul16: D * X -> wsprod (32 bits); D = its high word
wsmul16             std <wsmula
                    stx <wsmulb
                    clr <wsprod
                    clr <wsprod+1
                    lda <wsmula+1
                    ldb <wsmulb+1
                    mul
                    std <wsprod+2
                    lda <wsmula
                    ldb <wsmulb+1
                    mul
                    addd <wsprod+1
                    std <wsprod+1
                    bcc wsm1@
                    inc <wsprod
wsm1@               lda <wsmula+1
                    ldb <wsmulb
                    mul
                    addd <wsprod+1
                    std <wsprod+1
                    bcc wsm2@
                    inc <wsprod
wsm2@               lda <wsmula
                    ldb <wsmulb
                    mul
                    addd <wsprod
                    std <wsprod
                    ldd <wsprod
                    rts
* wsdiv16x8: X / A -> X quotient, B remainder
wsdiv16x8           pshs a
                    clr <wsrem
                    ldb #16
wsdv1@              pshs x
                    lsl 1,s
                    rol ,s
                    puls x
                    rol <wsrem
                    lda <wsrem
                    cmpa ,s
                    blo wsdv2@
                    suba ,s
                    sta <wsrem
                    leax 1,x
wsdv2@              decb
                    bne wsdv1@
                    ldb <wsrem
                    puls a,pc
* wsbyte2dig: A (0-99) -> wsdec = two ASCII digits
wsbyte2dig          clrb
wsbt1@              cmpa #10
                    blo wsbt2@
                    suba #10
                    incb
                    bra wsbt1@
wsbt2@              adda #'0'
                    sta <wsdec+1
                    tfr b,a
                    adda #'0'
                    sta <wsdec
                    rts
wsweights           fdb WsWFet,WsWRamRd,WsWRamWr,WsWIoRd,WsWIoWr,WsWRtc,WsWMul
speedhelp           fcc "CPU speed: 7 bus-cycle classes x 3 RTC s, IRQs masked (~28 s)."
                    fcb 0
speedok             fcc "CPU speed measured. Software clock ~21 s slow: setime or ntptime."
                    fcb 0
wsl0                fcc "Fetch/internal       nop,nop,leay,bne "
                    fcb 0
wsl1                fcc "RAM read             8 x lda ,x       "
                    fcb 0
wsl2                fcc "RAM write            8 x sta ,x       "
                    fcb 0
wsl3                fcc "IO read              8 x lda >FEE0    "
                    fcb 0
wsl4                fcc "IO write             8 x sta >FEE0    "
                    fcb 0
wsl5                fcc "RTC/ext-bus rd       8 x lda RTC_SEC  "
                    fcb 0
wsl6                fcc "Internal             8 x mul          "
                    fcb 0
wsl7                fcc "Perceived            45/25/12/6/4/3/5 "
                    fcb 0
wsmeas              fcc "    measuring...      "
                    fcb 0
wsnortc             fcc "CPU: the RTC second never changed (no timebase). Run T; E or W sets it."
                    fcb 0
wsmhz               fcc " Mhz        "
                    fcb 0
