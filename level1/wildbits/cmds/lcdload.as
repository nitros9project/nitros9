********************************************************************
* 
* 
* 
* 
* 
* Lcdload - by Matt Massie
* 
*
* 
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* started  2026/07/14 - 2026/07/20
* ------------------------------------------------------------------
*
*   1      2026/07/20
* Initial version.  Sends a raw RGB565 bitmap file to the Sitronix
* ST7789V LCD controller on the Wildbits K2. Pixel data is transferred a full
* 16 bit word at a time (register D) directly to the LCD data port
* for decent load times.
*
* Syntax:  lcdload [<pathlist>]
*
* If no pathlist is given on the command line, the file
* "/dd/NitrOS9LCD" is opened by default.

                    nam       lcdload
                    ttl       Lcd loader for NitrOS-9 Wildbits K2

                    ifp1
                    use       defsfile
                    endc

                    setdp     $00

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

********************************************************************
* Hardware I/O ports - Sitronix ST7789V LCD controller
*
LCD.CMD             equ       $FF70               command register (8 bit, write)
LCD.DAT             equ       $FF71               data register (8 bit, write)
LCD.PIX             equ       $FF72               pixel data port (16 bit, write - D reg)

********************************************************************
* Data area - addressed via the direct page (U points to the base
* of this area on entry, and OS-9 sets DP to match).
*
                    org       0
Vpath               rmb       1                   path number of the open bitmap file
BUFSIZE             equ       256                 read buffer size (must stay even)
Vbuffer             rmb       BUFSIZE             pixel data read buffer
Vcount              rmb       2                   bytes actually returned by last I$Read
                    rmb       200                 stack space
size                equ       .

name                fcs       /lcdload/
                    fcb       edition

DfltName            fcc       "/dd/NitrOS9LCD"
                    fcb       C$CR
DfltNameL           equ       *-DfltName

NoFileMsg           fcc       /lcdload: can't open bitmap file/
                    fcb       C$CR
NoFileMsgL          equ       *-NoFileMsg

********************************************************************
* Mainline
*
* On entry:  X = start of parameter area (command line)
*            Y = end of parameter area
*            U = data area/direct page base
*            D = size of parameter area (bytes)
*
start               bsr       SkipSpaces          skip any leading blanks on the command line
                    cmpa      #C$CR               anything left besides the terminator?
                    bne       GotName             yes - a pathlist was given, use it
                    leax      >DfltName,pcr       no - fall back to the default pathlist
GotName             pshs      x                   hang on to the pathlist pointer

                    lbsr      Init7789            initialize the ST7789V controller

                    puls      x                   recover the pathlist pointer
                    lda       #READ.
                    os9       I$Open              open the bitmap file
                    lbcs      OpenErr
                    sta       <Vpath              remember the path number

* Main transfer loop - pull a buffer's worth of pixel bytes in with
* one I$Read call, then blast them out to the LCD a full 16 bit word
* (register D) at a time so we are not paying a system call for
* every pixel.
ReadLoop            lda       <Vpath
                    leax      <Vbuffer,u
                    ldy       #BUFSIZE
                    os9       I$Read              read a buffer full of pixel data
                    sty       <Vcount             remember how many bytes came back
                    bcs       RdDone              carry set - end of file or an error

                    ldy       <Vcount
                    beq       ReadLoop            (shouldn't happen) nothing read, try again
                    leax      <Vbuffer,u
SendLoop            ldd       ,x++                grab one pixel (16 bits) from the buffer
                    std       LCD.PIX             ...and write the whole word to the LCD
                    leay      -2,y
                    bne       SendLoop
                    bra       ReadLoop

RdDone              cmpb      #E$EOF              normal end of file?
                    beq       CloseUp
                    bsr       ReportErr           something else went wrong, report it

CloseUp             lda       <Vpath
                    os9       I$Close             close the bitmap file
                    bcc       ExitOk
                    bsr       ReportErr

ExitOk              clrb                          no error
                    os9       F$Exit              back to OS-9

OpenErr             pshs      b                   save the error code
                    leax      >NoFileMsg,pcr
                    ldy       #NoFileMsgL
                    lda       #2                   standard error path
                    os9       I$WritLn
                    puls      b
ReportErr           os9       F$PErr              print the OS-9 error message for code in B
                    os9       F$Exit              and give up

********************************************************************
* Skip leading spaces on the command line. Returns X pointing at the
* first non-space character, and A holding that character.
*
SkipSpaces          lda       ,x+
                    cmpa      #C$SPAC
                    beq       SkipSpaces
                    leax      -1,x
                    rts

********************************************************************
* Send the command byte in A to the LCD command register.
*
SendCmd             sta       LCD.CMD
                    rts

* Send the data byte in A to the LCD data register.
*
SendDat             sta       LCD.DAT
                    rts

********************************************************************
* Init7789 - run the Sitronix ST7789V power up / configuration
* sequence, ending with a RAMWR command so the controller is ready
* to receive a stream of pixel words.
*
Init7789            equ       *

* Turn off sleep mode
                    lda       #$11
                    lbsr      SendCmd

* MADCTL - memory access control (36 decimal = $24 in the original)
                    lda       #$24
                    lbsr      SendCmd
                    lda       #$00
                    lbsr      SendDat

* COLMOD - interface pixel format
                    lda       #$3A
                    lbsr      SendCmd
                    lda       #$05
                    lbsr      SendDat

* PORCTRL - porch setting
                    lda       #$B2
                    lbsr      SendCmd
                    lda       #$0C
                    lbsr      SendDat
                    lda       #$0C
                    lbsr      SendDat
                    lda       #$00
                    lbsr      SendDat
                    lda       #$33
                    lbsr      SendDat
                    lda       #$33
                    lbsr      SendDat

* GCTRL - gate control
                    lda       #$B7
                    lbsr      SendCmd
                    lda       #$35
                    lbsr      SendDat

* VCOMS - VCOM setting
                    lda       #$BB
                    lbsr      SendCmd
                    lda       #$35
                    lbsr      SendDat

* LCMCTRL - LCM control
                    lda       #$C0
                    lbsr      SendCmd
                    lda       #$2C
                    lbsr      SendDat

* VDVVRHEN - VDV and VRH command enable
                    lda       #$C2
                    lbsr      SendCmd
                    lda       #$01
                    lbsr      SendDat

* VRHS - VRH set
                    lda       #$C3
                    lbsr      SendCmd
                    lda       #$13
                    lbsr      SendDat

* VDVS - VDV set
                    lda       #$C4
                    lbsr      SendCmd
                    lda       #$20
                    lbsr      SendDat

* FRCTRL2 - frame rate control (unlabeled in the original source)
                    lda       #$C6
                    lbsr      SendCmd
                    lda       #$0F
                    lbsr      SendDat

* PWCTRL1 - power control
                    lda       #$D0
                    lbsr      SendCmd
                    lda       #$A4
                    lbsr      SendDat
                    lda       #$A1
                    lbsr      SendDat
                    lda       #$D0
                    lbsr      SendCmd
                    lda       #$A4
                    lbsr      SendDat

* PVGAMCTRL - positive voltage gamma control
                    lda       #$E0
                    lbsr      SendCmd
                    lda       #$F0
                    lbsr      SendDat
                    lda       #$00
                    lbsr      SendDat
                    lda       #$04
                    lbsr      SendDat
                    lda       #$04
                    lbsr      SendDat
                    lda       #$04
                    lbsr      SendDat
                    lda       #$05
                    lbsr      SendDat
                    lda       #$29
                    lbsr      SendDat
                    lda       #$33
                    lbsr      SendDat
                    lda       #$3E
                    lbsr      SendDat
                    lda       #$38
                    lbsr      SendDat
                    lda       #$12
                    lbsr      SendDat
                    lda       #$12
                    lbsr      SendDat
                    lda       #$28
                    lbsr      SendDat
                    lda       #$30
                    lbsr      SendDat

* NVGAMCTRL - negative voltage gamma control
                    lda       #$E1
                    lbsr      SendCmd
                    lda       #$F0
                    lbsr      SendDat
                    lda       #$07
                    lbsr      SendDat
                    lda       #$0A
                    lbsr      SendDat
                    lda       #$0D
                    lbsr      SendDat
                    lda       #$0B
                    lbsr      SendDat
                    lda       #$07
                    lbsr      SendDat
                    lda       #$28
                    lbsr      SendDat
                    lda       #$33
                    lbsr      SendDat
                    lda       #$3E
                    lbsr      SendDat
                    lda       #$36
                    lbsr      SendDat
                    lda       #$14
                    lbsr      SendDat
                    lda       #$14
                    lbsr      SendDat
                    lda       #$29
                    lbsr      SendDat
                    lda       #$32
                    lbsr      SendDat

* CASET - column address set
                    lda       #$2A
                    lbsr      SendCmd
                    lda       #$00
                    lbsr      SendDat
                    lda       #$00
                    lbsr      SendDat
                    lda       #$00
                    lbsr      SendDat
                    lda       #$F0
                    lbsr      SendDat

* RASET - row address set
                    lda       #$2B
                    lbsr      SendCmd
                    lda       #$00
                    lbsr      SendDat
                    lda       #$00
                    lbsr      SendDat
                    lda       #$01
                    lbsr      SendDat
                    lda       #$3F
                    lbsr      SendDat

* INVON - display inversion on
                    lda       #$21
                    lbsr      SendCmd

* SLPOUT - sleep out (sent a second time, matching the original)
                    lda       #$11
                    lbsr      SendCmd

* DISPON - display on
                    lda       #$29
                    lbsr      SendCmd

* RAMWR - memory write; the controller is now ready for a stream of
* pixel words, which the transfer loop above sends to LCD.PIX
                    lda       #$2C
                    lbsr      SendCmd

                    rts

                    emod
eom                 equ       *
                    end
