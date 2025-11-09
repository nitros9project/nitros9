********************************************************************
* View - F256 Picture Viewer
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2025/10/31  Roger Taylor
* Created. Currently loads only Windows BMP format.
*
*          2025/11/05  Roger Taylor
* Added ability to load 320x240 images.  If taller, each 240 lines
* starting from the bottom will display on the same screen in series.
*
*          2025/11/08  Roger Taylor
* Add option to show a specific bitmap # if no file is specified.

                    nam       view
                    ttl       Picture viewer

                    ifp1
                    use       defsfile
                    endc

                    setdp     $00

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

*        [Data Section - Variables and Data Structures Here]
SHIFTBIT            equ       %00000001

                    ORG	      $0
CHARID              RMB       2                   ALWAYS BM
FILESIZE            RMB       4                   Intel format
RESERV	RMB	4
HEADSIZE	RMB	4	Intel format; offset to image start
INFOSIZE	RMB	4	Always $28 40T
HWIDTH	RMB	4
HDEPTH	RMB	4
BIPLANE	RMB	2	Always 1
BITS	RMB	2	Bits of color 1,4,8,24
COMPRES	RMB	4	Always 0 if RGB other if RLE
IMGSIZE	RMB	4	Should be HWIDTHxHDEPTHx(color data per pixel)
PELXMTR	RMB	4
PELYMTR	RMB	4
CLRUSED	RMB	4
CLRIMP	RMB	4

colors	rmb	2
RED	rmb	1
GREEN	rmb	1
BLUE	rmb	1
	rmb	1		filler to make RGBCOL structure 4 bytes long

BIT4PX	RMB	1
WIDTH	rmb	2		image width
HEIGHT	rmb	2		image height
 	rmb	1
PX                  rmb       2	                  True pixel location x,y
PY                  rmb       2

blkadj              rmb       1
color               rmb       2
pixaddr             rmb       2
bitmapnum           rmb       2
filepath            rmb       1
filebyte            rmb       1
clutnum             rmb       2
fmemupper           rmb       2
fmemsize            rmb       2
currBlk             rmb       2         $36 32 Variable currBlk BMLoad
mapaddr             rmb       2         $38 34 Variable mapaddr BMLoad
bmblock             rmb       1         $40 3C first bitmap block
steep               rmb       1         $41 3D line variables
currPath            rmb       1         $46 42 Variable  currPath BMLoad
blkCnt              rmb       1         $47 43 Variable blkCnt BMLoad
ssize               rmb       2
lut                 rmb       2
layer               rmb       2
offset              rmb       2      
hexstrdat           rmb       6
HEADER              rmb       56
LineData            rmb       320

pal                 rmb       256*4

                    rmb	      250
size                equ       .
name                fcs       /view/
                    fcb       edition

inittext            fcc       /Picture Viewer 0.4 by Roger Taylor/
                    fcb       $0d

clutpathname        fcn       "/dd/cmds/xtclut"

start
                    clra
                    clrb
                    os9       F$Mem
                    lbcs      err
                    sty       fmemupper
                    std       fmemsize
                    clr       filepath

                    clra
                    clrb
                    std       bitmapnum
                    std       clutnum
                    lda       #1                  Path #
                    sta       currPath            Store current path

                    lda       ,x
                    cmpa      #'-'
                    bne       OpenFile
                    leax      1,x
                    ldb       ,x
                    subb      #'0'
                    cmpb      #2
                    bhi       OpenFile            If bitmap # not 0-2 then assume 0
                    stb       bitmapnum+1
                    stb       clutnum+1
                    leax      1,x

OpenFile            lda       ,x
                    cmpa      #$0D
                    beq       nf@
                    lda       #READ.
                    os9       I$Open
                    lbcs      err
                    sta       filepath
nf@                 lbsr      CreateBitmap
                    lda       filepath
                    beq       nc@
                    clr       <color
                    lbsr      Cls
                    leax      clutpathname,pcr
                    lbsr      LoadClut            Must call with x=pathname or x=0= reg.y
nc@                 lbsr      GrOn

                    lda       filepath
                    beq       nd@
                    lbsr      LOADBMP
nd@                 lbsr      Bitmap2Layer

                    bra       bye

clsdemo             ldd       #$0200
                    std       <color
cls1                bsr       Cls                 Updates currBlk
                    bcs       err
                    ldd       color
                    addd      #$0100              Fractional increment of color in MSB
                    std       <color
keyloop@            lbsr      INKEY               Inkey routine with handlers for intergace
                    cmpa      #$0D                $0D=ok shift+$0d=cancel
                    bne       cls1

bye                 clrb
err                 pshs      cc,b
*                   lbsr      GrOff
                    puls      b,cc
                    os9       F$Exit

error_ds3           puls      u,y,x,a
error_ds2           os9       F$Exit

Cls                 ldb       #9
                    pshs      b
l@                  ldb       ,s
                    bsr       MapRelPicBlk
                    ldx       mapaddr
                    ldy       #$2000
                    ldb       <color
                    tfr       b,a
w@                  std       ,x++
                    leay      -2,y
                    bne       w@
                    dec       ,s
                    bpl       l@
                    puls      b,pc

SetPixel            bsr       GetXYBlk            Returns relative 8K block # in reg.b, offset into the block in reg.x
                    stx       offset
                    bsr       MapRelPicBlk        Maps in the relative block # of the bitmap screen
                    bcs       x@
                    ldd       offset
                    adda      mapaddr
                    tfr       d,x
                    ldb       <color
                    stb       ,x                  write pixel             
x@                  rts                           Return to the caller
MapRelPicBlk        addb      bmblock
                    cmpb      currBlk
                    beq       exit@               Block is already mapped in
                    stb       currBlk
                    pshs      u                   F$ClrBlk will destroy U, so push it
                    ldu       mapaddr
                    cmpu      #-1
                    beq       n@
                    ldb       #1
                    os9       F$ClrBlk
n@                  puls      u                   Restore U from stack                   
                    ldb       currBlk
                    clra
                    tfr       d,x
                    ldb       #1
                    pshs      u                   F$MapBlk with destroy U so push
                    os9       F$MapBlk
                    bcc       ok@
                    puls      u                   restore U from stack
                    bra       exit@
ok@                 stu       mapaddr
                    puls      u                   restore U from stack
                    clrb
exit@               rts


* Convert PX/PY into relative 8K block #
* and offset into that block.
* (PY*320) is the same as (PY*256)+(PY*64)
* Then add PX, divide by 32 to get 8K block of the pixel.
GetXYBlk            pshs      d
                    clr       <blkadj
                    lda       <PY+1               PY*256
                    clrb
                    std       ,s
                    lda       <PY+1
                    clrb
                    lsra
                    rorb
                    lsra
                    rorb
                    addd      ,s                  (PY*256)+(PY*64)
                    pshs      cc
                    addd      <PX
                    pshs      cc
                    clr       ,-s
                    lsr       1,s
                    ror       ,s
                    lsr       2,s
                    ror       ,s
                    tst       ,s+
                    beq       h@
                    pshs      b
                    ldb       #8
                    stb       <blkadj
                    puls      b
h@                  puls      cc
                    puls      cc
                    TFR       D,X
                    LSRA
                    LSRA
                    LSRA
	            LSRA
	            LSRA
                    adda      <blkadj
                    sta       1,s
                    TFR       X,D
                    ANDA      #31
                    tfr       d,x
                    puls      d,pc

*                   FX_TXT  =  %00000001          Text Mode On
*                   FX_OVR  =  %00000010          Overlay Text on Graphics
*                   FX_GRX  =  %00000100          Graphics Mode On
*                   FX_BM   =  %00001000          Bitmap Enable
*                   TileMap =  %00010000          TileMap Enable
*                   Sprite  =  %00100000          Sprite Enable
GrOn                ldx       #%00001111
                    ldy       #%11111111          Don't change FFC1  FT_OMIT = %11111111
                    lda       currPath            Path #
                    ldb       #SS.DScrn           Display Screen with new settings
                    os9       I$SetStt            Turn on Graphics
                    bcs       x@
                    clrb
x@                  rts

GrOff               ldx       #%00000001          Turn Text on BM_TXT = %00000001
                    ldy       #%11111111          Don't change FFC1  FT_OMIT = %11111111
                    lda       currPath            Path #
                    ldb       #SS.DScrn           Display screen with new settings
                    os9       I$SetStt
                    bcs       x@                  Error
                    ldy       #2                  BM 0-2
par2@               lda       currPath            Path #
                    ldb       #SS.FScrn           Free Bitmap
                    os9       I$SetStt
                    bcs       x@                  Error
                    clrb                          No Error
x@                  rts                           return to the caller
                    

* The term for "Color Lookup Table" has been called "PALETTE" for the past 40+ years.
LoadClut            pshs      a,x,y,u             Preserve regs
                    cmpx      #0
                    beq       l@
                    lda       #0                  F$Load a=language, 0=Any
                    os9       F$Link              Try linking module
                    beq       l@                  Use CLUT data if no error
                    os9       F$Load              Load and set y=entry point
                    bcs       x@
l@                  ldx       clutnum
                    lda       currPath            Path #
                    ldb       #SS.DfPal           Define Palette CLUT/Palette#0 with Y data
                    os9       I$SetStt
                    os9       F$Unlink            Clut/Palette defined now this saves 8K for Basic09         
                    bcs       x@
                    ldu       5,s                 F$Link,F$Load,F$Unlink all trash U
                    ldx       clutnum             CLUT/Palette #
                    ldy       bitmapnum           Bitmap # 1st param
                    lda       currPath            Path #
                    ldb       #SS.Palet           Assign CLUT/Palette # to Bitmap #
                    os9       I$SetStt
                    clrb
x@                  puls      u,y,x,a,pc

CreateBitmap        ldy       bitmapnum
                    ldx       #0                  2nd parameter screentype 0=320x240 1=320x200
                    lda       currPath            Path #
                    ldb       #SS.AScrn           Assign and create bitmap
                    os9       I$SetStt         
                    bcc       storeblk            No error store block #
                    cmpb      #E$WADef            Check if window already defined
                    bne       x@
storeblk            tfr       x,d              
                    stb       bmblock             Save BMBlock
x@                  ldb       #-1
                    stb       currBlk             Force first pixel to map in it's 8K block
                    ldd       #-1
                    std       mapaddr
                    clrb
                    rts

**** Assign Bitmap to Layer
Bitmap2Layer        ldx       #0                  Layer # 
                    ldy       bitmapnum           Bitmap #
                    lda       currPath            Path #
                    ldb       #SS.PScrn           Position Bitmap # to Layer #
                    os9       I$SetStt
                    rts

* Intel Long to 6809 Long
LONG                lda       3,x
                    ldb       0,x
                    sta       0,x
                    stb       3,x
                    ldd       1,x
                    exg       a,b
                    std       1,x
                    leax      4,x
                    rts

ReadFileByte        pshs      b,x,y
                    lda       filepath
                    leax      filebyte,u
                    ldy       #1
                    os9       I$Read
                    lda       filebyte
                    puls      b,x,y,pc

ReadLineData        pshs      b,x,y
                    lda       filepath
                    leax      LineData,u
                    ldy       #320
                    os9       I$Read
                    puls      b,x,y,pc

LOADBMP             LDB       #54	          Size of header
                    LEAX      HEADER,u
A@                  lbsr      ReadFileByte
                    STA       ,X+
                    DECB
                    BNE       A@
                    LEAX      HEADER+2,u          Skip over BM
* convert Intel longs to Motorola longs
                    BSR       LONG                convert file size
                    LEAX      4,X                 skip reserved bytes
                    BSR       LONG                convert header size
                    BSR       LONG                convert info size
                    BSR       LONG                convert width
                    BSR       LONG                convert height
                    LEAX      2,X                 skip biplane
                    LDD       ,X                  convert bits of color from Intel to Motorola
                    EXG       A,B
                    STD       ,X++
                    BSR       LONG                compression
                    BSR       LONG                convert image size
                    leax      HEADER,u
                    LDD       ,x
                    CMPD      #'B*256+'M
                    LBNE      FERROR              this will quit with a bad file message

                    ldd       COMPRES,x
                    lbne      RLERR
                    ldd       COMPRES+2,x
                    lbne      RLERR
                    LDD       HWIDTH+2,x
                    STD       <WIDTH
                    LDD       HDEPTH+2,x
                    STD       <HEIGHT
                    ldb       <BITS+1,x	convert bits to color count
                    cmpb      #24
                    BNE       A@
                    LDD       #4096	default to 4096
                    STD       <colors
                    BRA       NOPAL	no palette with 24-bit files
A@                  pshs      b
                    LDD       #1
B@                  lslb
                    rola
                    dec       ,s
                    BNE       B@
                    leas      1,s
                    STD       <colors
                    TFR       D,Y	keep number of colors

* Get palette colors from file and store them.
                    leax      pal,u
A@                  lbsr      ReadFileByte        Read blue
                    STA       ,X+	store red
                    lbsr      ReadFileByte	read green
                    STA       ,X+	store green
                    lbsr      ReadFileByte	read green
                    STA       ,X+	store blue
                    lbsr      ReadFileByte	intensity?
                    lda       #$ff
                    sta       ,x+ intensity?
                    LEAY      -1,Y	next color
                    BNE       A@
                    ldx       #0
                    leay      pal,u
                    lbsr      LoadClut            reg.x must be 0.  reg.y = start of palette
NOPAL               CLR	      <color	clear screen to the first color in the palette
                    lbsr      Cls

                    LDX	      <HEIGHT
                    STX	      <PY	the screen will invert; default starts at 0
                    LDD       <colors

                    CMPD      #4096
                    LBEQ      BIT24	branch if a 24-bit image
                    CMPD      #2
                    LBEQ      BIT1	branch if a two color image
                    CMPD      #16
                    LBEQ      BIT4	branch if a 16 color image

* 8-bit BMP pictures contain a palette, and the colors are single bytes
* Loads in about 3 seconds.
BIT8                LBSR      UPDPY   update height; part of inversion
                    bmi       x@
                    lbsr      ReadLineData
 bcs x@
                    leay      LineData,u
a@                  lda       ,y+
                    sta       <color
                    lbsr      SetPixel
                    LBSR      UPDPX   update pixel number
                    BLO       a@
                    LDB       <WIDTH+1        8-bit bmp files stored in multiples of long numbers
                    ANDB      #3
                    BEQ       BIT8
                    PSHS      B
                    LDB       #4
                    SUBB      ,S+
c@                  lda       ,y+
                    DECB
                    BNE       c@
                    bra       BIT8
x@                  rts

* 16 million colors
* Currently not supported.  Loading works but won't show anything.
BIT24               lbsr ReadFileByte
                    STA	<BLUE
                    lbsr ReadFileByte
                    STA	<GREEN
                    lbsr ReadFileByte
                    STA	<RED
                    lbsr SetPixel
                    LBSR	UPDPX	update horizontal pointer
                    BLO	B@
                    LBSR	UPDPY	update vertical pointer
                    BEQ	X@
	LDB	<WIDTH+1
	LDA	#3	convert to rgb triads
	MUL
	ANDB	#3	test for incomplete long numbers
	BEQ	B@
	PSHS	B
	LDB	#4
	SUBB	,S+
C@	lbsr ReadFileByte	skip over the fillers
	DECB
	BNE	C@
B@	LDD	<PY
	BNE	BIT24
X@	RTS

* 2 color mode
* Currently loads in a very slow manner.
* In Progress: needs to load 40 bytes per line at once, then split each byte into two 8 mono colors.
BIT1	lbsr ReadFileByte
B1LOOP	CLR	<color		(RT)
	LSLA
	BCS	A@
	clrb
	BRA	B@
A@	INC	<color		(RT)
	ldb	#$FF
B@	stb	<RED
        stb     <GREEN
	stb	<BLUE
        ldb     #1
	PSHS	D
	lbsr SetPixel

	LBSR	UPDPX	update horizontal pointer
	BNE	A@
	LBSR	UPDPY	update vertical pointer
	BEQ	D@
	LDB	<WIDTH+1
	BEQ	D@
	LSRB		divide by 8 to get bytes
	LSRB
	LSRB
	ADCB	#0	round up
	ANDB	#3	check for incomplete long
	BEQ	D@
	PSHS	B
	LDB	#4
	SUBB	,S+
B@	lbsr ReadFileByte	skip over the fillers
	DECB
	BNE	B@
D@	PULS	D
	BRA	C@
A@	PULS	D
	LSLB
	BNE	B1LOOP
C@	LDD	<PY
	BNE	BIT1
X@	RTS

* 16 color mode
* Currently loads in a very slow manner.
* In Progress: needs to load 160 bytes per line at once, then split each byte into two 4-bit colors.
BIT4	lbsr ReadFileByte	get two pixels
	TFR	A,B
	ANDB	#15	get low nibble
	STB	BIT4PX,u
	LSRA		get high nibble
	LSRA
	LSRA
	LSRA
	sta	<color		(RT)
	lbsr SetPixel
	LBSR	UPDPX	update horizontal pointer
	BNE	A@
	LBSR	UPDPY	update vertical pointer
	BEQ	X@
	LDB	<WIDTH+1
	BEQ	BIT4
	LSRB		divide by 2 to get bytes
	ADCB	#0	round up
	ANDB	#3	check for incomplete long
	BEQ	BIT4
	PSHS	B
	LDB	#4
	SUBB	,S+
B@	lbsr ReadFileByte	skip over the fillers
	DECB
	BNE	B@
	BRA	BIT4
A@ 	lda	BIT4PX,u	recover second pixel
	sta	<color		(RT)
	lbsr SetPixel
	BSR	UPDPX	update the horizontal pointer
	BNE	BIT4
	BSR	UPDPY	update the vertical pointer
	BEQ	X@
	LDB	<WIDTH+1
	LBEQ	BIT4
	LSRB		divide by 2 to get bytes
	ADCB	#0	round up
	ANDB	#3	check for incomplete long
	LBEQ	BIT4
	PSHS	B	calculate the filler bytes
	LDB	#4
	SUBB	,S+
C@	lbsr ReadFileByte	skip over the fillers
	DECB
	BNE	C@
	LBRA	BIT4
X@	RTS

SNDPLOT
* 	LDX	600	get rgb colors and plot them

	STB	<color		(RT)
	lbsr SetPixel


        leax    pal,u
	ABX
	ABX
	ABX
	ABX
	LDD	,X	get red and green
	STD	<RED
	LDB	2,X	get blue
	STB	<BLUE
        rts

UPDPX	LDD	<PX	update the horizontal pointer
	addd #1
	STD	<PX
	CMPD	<WIDTH
	RTS

* 		update horizontal pointer
UPDPY
 clra
 clrb
	STD	<PX
	LDD	<PY	update the vertical pointer for an upside down image
	subd #1
	STD	<PY
	RTS

FERROR	LEAX	BADFILE,PCR
        ldy     #errlen1
          bra     p@
RLERR	LEAX	RLEFIL,PCR
      ldy     #errlen2
p@      lda     #2           Error path
        os9     I$WritLn
        clrb
        os9     F$Exit

BADFILE	FCC	/This is not a BMP file!/
	FCB	C$LF
errlen1             equ       *-BADFILE
RLEFIL	FCC	/Sorry, this file is run length compressed./
	FCB	C$LF
errlen2             equ       *-RLEFIL


********************************************************************
* I/O stuff
*
INKEY          clra                             std in
               ldb       #SS.Ready
               os9       I$GetStt               see if key ready
               bcc       getit
               cmpb      #E$NotRdy              no keys ready=no error
               bne       exit@                  other error, report it
               clra                             no error
               bra       exit@
getit          lbsr      FGETC                  go get the key
               tsta
exit@          rts

FGETC          pshs      a,x,y
               ldy       #1                     number of char to print
               tfr       s,x                    point x at 1 char buffer
               os9       I$Read
               puls      a,x,y,pc


* PrintCR             pshs      cc,d,x,y
*                     lda       #0
*                     ldy       #1
*                     leax      CRStr,pcr
*                     os9       I$WritLn
*                     puls      cc,d,x,y,pc
* CRStr               fcb       $0d

* PrintSPC            pshs      cc,d,x,y
*                     lda       #0
*                     ldy       #1
*                     leax      SPCStr,pcr
*                     os9       I$WritLn
*                     puls      cc,d,x,y,pc
* SPCStr               fcb       C$SPAC

* PrintHex16          pshs      y,x,b,a,cc
*                     leax      HexStrDat,u

*                     lda       1,s
*                     lsra
*                     lsra
*                     lsra
*                     lsra
*                     bsr       Bin2AscHex
*                     sta       ,x+
*                     lda       1,s
*                     anda      #$F
*                     bsr       Bin2AscHex
*                     sta       ,x+

*                     lda       2,s
*                     lsra
*                     lsra
*                     lsra
*                     lsra
*                     bsr       Bin2AscHex
*                     sta       ,x+
*                     lda       2,s
*                     anda      #$F
*                     bsr       Bin2AscHex
*                     sta       ,x+

*                     lda       #0
*                     ldy       #4
*                     leax      HexStrDat,u
*                     os9       I$WritLn
*  lbsr PrintSPC
*                     puls      cc,d,x,y,pc

* PrintHex8           pshs      y,x,b,a,cc
*                     leax      HexStrDat,u

*                     lda       2,s
*                     lsra
*                     lsra
*                     lsra
*                     lsra
*                     bsr       Bin2AscHex
*                     sta       ,x+
*                     lda       2,s
*                     anda      #$F
*                     bsr       Bin2AscHex
*                     sta       ,x+

*                     lda       #0
*                     ldy       #2
*                     leax      HexStrDat,u
*                     os9       I$WritLn
*  lbsr PrintSPC
*                     puls      cc,d,x,y,pc

* Bin2AscHex          anda      #$0f
*                     cmpa      #9
*                     bls       d@
*                     suba      #10
*                     adda      #'A'
*                     bra       x@
* d@                  adda      #'0'
* x@                  rts


               emod
eom            equ *
               end