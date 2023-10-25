zeropage            equ       0
vectors             equ       $fff0
lowstart            equ       $1000

                    use       ../defsfile
                    org       lowstart

mapaddr             equ       MMU_SLOT_1
mapstart            equ       (mapaddr-MMU_SLOT_0)*$2000

main
reset
                    orcc      #IntMasks           turn off interrupts
                    clra
                    tfr       a,dp
                    clr       >MMU_IO_CTRL        map in I/O page 0
                    lda       #$FF                set the all bits on flag
                    sta       INT_MASK_0          mask set 0 interrupts
                    sta       INT_MASK_1          mask set 1 interrupts
                    lds       #$0500              set the stack pointer

                    lbsr      init_display        initalize the display

                    leax      hello,pcr           point to the hello banner
                    ldy       #hellolen           get the length
                    lbsr      I_Write             write out the message

                    leax      krnstart,pcr        start searching where
                    ldy       #$FF00
                    lbsr      FindKrn
                    bcs       nope@
                    jmp       ,x
nope@
                    leax      notfound,pcr
                    ldy       #notfoundlen
                    lbsr      I_Write
loop@               cwai      #IntMasks
                    bra       loop@

hello               .str      "**                 Booter **"
                    fcb       $0D
hellolen            equ       *-hello

notfound            .strz     "OS-9               kernel not found"
notfoundlen         equ       *-notfound

lastpos             fdb       mapstart

* Entry: A = path (ignored)
*        X = string to write
*        Y = length to write
I_Write             pshs      d,u
                    leau      lastpos,pcr
                    ldu       ,u
more@               lda       ,x+
                    sta       ,u+
                    cmpu      #mapstart+80*60
                    bne       next@
                    ldu       #mapstart
next@               leay      -1,y
                    cmpy      #0000
                    bne       more@
                    leax      lastpos,pcr
                    stu       ,x
                    puls      d,u,pc

* Entry: X = address to start hunting for module
*        Y = address to stop hunting for module
FindKrn             pshs      y
                    leax      -1,x
findloop@           leax      1,x
                    cmpx      ,s
                    beq       done@
                    ldd       ,x
                    cmpd      #$87*256+$CD
                    bne       findloop@
                    ldd       4,x                 get offset to name
                    leau      d,x
                    ldd       ,u
                    cmpd      #'K*256+'r
                    bne       findloop@
                    lda       2,u
                    cmpa      #'n+128
                    bne       findloop@
                    ldd       9,x
                    leax      d,x
                    clrb
                    puls      y,pc
done@               comb
                    puls      y,pc

* Initialize display.
init_display
                    pshs      cc
                    orcc      #IntMasks

                    lda       #Mstr_Ctrl_Text_Mode_En
                    sta       MASTER_CTRL_REG_L
                    clr       MASTER_CTRL_REG_H
                    clr       BORDER_CTRL_REG
                    clr       BORDER_COLOR_R
                    clr       BORDER_COLOR_G
                    clr       BORDER_COLOR_B
                    clr       VKY_TXT_CURSOR_CTRL_REG

* Initialize gamma.
                    lda       #$C0
                    sta       mapaddr
                    ldd       #0
x1@                 tfr       d,x
                    stb       mapstart,x
                    stb       mapstart+$400,x
                    stb       mapstart+$800,x
                    incb
                    bne       x1@

* Initialize palette.
                    leax      palette,pcr
                    ldy       #TEXT_LUT_FG
                    bsr       copypal

                    leax      palette,pcr
                    ldy       #TEXT_LUT_BG
                    bsr       copypal

* Install font.
                    lda       #$C1
                    sta       mapaddr
                    leax      font,pcr
                    ldy       #mapstart
loop@               ldd       ,x++
                    std       ,y++
                    cmpy      #mapstart+2048
                    bne       loop@

* Set foreground/background character LUT values.
                    lda       #$C3
                    sta       mapaddr
                    ldd       #$10*256+$10
                    bsr       clr

* Clear text screen.
                    lda       #$C2
                    sta       mapaddr
                    ldd       #$20*256+$20
                    bsr       clr
                    puls      cc,pc

copypal             ldu       #64
loop@               ldd       ,x++
                    std       ,y++
                    ldd       ,x++
                    std       ,y++
                    leau      -4,u
                    cmpu      #0000
                    bne       loop@
                    rts

* Clear screen memory.
clr                 ldx       #mapstart
loop@               std       ,x++
                    cmpx      #mapstart+80*61
                    bne       loop@
                    rts

palette             fcb       $00,$00,$00,$00
                    fcb       $ff,$ff,$ff,$00
                    fcb       $00,$00,$88,$00
                    fcb       $ee,$ff,$aa,$00
                    fcb       $cc,$4c,$cc,$00
                    fcb       $55,$cc,$00,$00
                    fcb       $aa,$00,$00,$00
                    fcb       $77,$dd,$dd,$00
                    fcb       $55,$88,$dd,$00
                    fcb       $00,$44,$66,$00
                    fcb       $77,$77,$ff,$00
                    fcb       $33,$33,$33,$00
                    fcb       $77,$77,$77,$00
                    fcb       $66,$ff,$aa,$00
                    fcb       $ff,$88,$00,$00
                    fcb       $bb,$bb,$bb,$00

font
                    use       "../modules/8x8.fcb"

krnstart            equ       *

                    end       main

