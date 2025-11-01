********************************************************************
* psg - F256 Picture Viewer
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2025/10/31  Roger Taylor
* Created.

               nam       view
               ttl       Picture viewer

               ifp1
               use       defsfile
               endc

tylg           set       Prgrm+Objct
atrv           set       ReEnt+rev
rev            set       $00
edition        set       1

               mod       eom,name,tylg,atrv,start,size

*        [Data Section - Variables and Data Structures Here]
SHIFTBIT       equ       %00000001

	ORG	$0
CHARID	RMB	2	ALWAYS BM
FILESIZE	RMB	4	Intel format
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
ENDHEAD	EQU	*

 org $0

* Offsets for parameters accessed directly (there can be more, but they are handled in loops)
                    org       0
currBlk             rmb       2         $36 32 Variable currBlk BMLoad
mapaddr             rmb       2         $38 34 Variable mapaddr BMLoad
bmblock             rmb       1         $40 3C first bitmap block
steep               rmb       1         $41 3D line variables
currPath            rmb       1         $46 42 Variable  currPath BMLoad
blkCnt              rmb       1         $47 43 Variable blkCnt BMLoad
slperr              rmb       2         $48 44 Slope error
d                   rmb       2         $4A 46 Decision
cnt                 rmb       2         $4C 48 count 
radius              rmb       1         $4E 4A radius
ssize               rmb       2
lut                 rmb       2
layer               rmb       2
offset              rmb       2      
enable              rmb       2
endian              rmb       1

color               rmb       2
pixaddr             rmb       2
bitmapnum           rmb       2
filepath            rmb       1
filebyte            rmb       1
clutnum             rmb       2
fmemupper           rmb       2
fmemsize            rmb       2
tmp                 rmb       4
ofsintoblk          rmb       4

HEADER rmb	ENDHEAD
BIT4PX	RMB	1

BUFBLK	rmb	1
BUFCPU	rmb	2
BUFMSB	rmb	1
BUFNSB	rmb	1
BUFLSB	rmb	1
BUFEND	rmb	3
EOF	rmb	1		END-OF-FILE FLAG
EOB	rmb	1		END-OF-BUFFER FLAG
MONTYP	rmb	1		user's monitor type  0=rgb  1=cmp  2=monochrome
GIM432	rmb	1
PMODE	rmb	1
DISKBY	rmb	1		dskpop val
WIDTH	rmb	2		image width
HEIGHT	rmb	2		image height
COLORS	rmb	2
RGBCOL	equ	*		allow STQ <RGBCOL for setting r,g,b,color all at once
RED	rmb	1
GREEN	rmb	1
BLUE	rmb	1
	rmb	1		filler to make RGBCOL structure 4 bytes long
REDCOM	rmb	1
GRNCOM	rmb	1
BLUCOM	rmb	1
	rmb	1
WINDOW	rmb	2
RESCAL	rmb	1
CENTER	rmb	1
CENTX	rmb	2		main screen x offset
CENTY	rmb	2
PX	rmb	2		true pixel location x,y
PY	rmb	2
LEFTX	rmb	2		image offset from main x,y
TOPY	rmb	2
RIGHTX	rmb	2
BOTY	rmb	2
NEWX	rmb	2		final x,y
NEWY	rmb	2
SCBYTE	rmb	2
LASTPY	rmb	2		FOR NOT REPLOTTING OVER SAME LINE
PTITLE	rmb	2
PTYPE	rmb	2
MAPLOC	rmb	2
SCRBLK	rmb	1
REDMSK	rmb	1
GRNMSK	rmb	1
BLUMSK	rmb	1
PMASK	rmb	1
PMASK2	rmb	1
ALTROW	rmb	1
GRYMSK	rmb	1
MOD8K	rmb	1
DSKBUF	rmb	2
GRNBYT	rmb	2
SECBYT	rmb	2
LSTGRN	rmb	1
FGRANS	rmb	1
GRAN	rmb	2
INPPOS	rmb	1
RES640	rmb	1
LEAST	rmb	2
MATCH	rmb	1
HOLD	rmb	2
HOLD2	rmb	2
RESMSB	rmb	1
RESNSB	rmb	1
RESLSB	rmb	1
SUBTYP	rmb	1
CYCMOD	rmb	1
PALTYP	rmb	1
GRYTYP	rmb	1
CLSRED	rmb	1
CLSGRN	rmb	1
CLSBLU	rmb	1
EDFOFS	rmb	2
BCOLOR	rmb	2
AUTOAR	rmb	1
BAUD	rmb	2
LDELAY	rmb	2
SLDISK	rmb	1
DITHER	rmb	1
METHOD	rmb	1
GOTIMG	rmb	1
SCRCOL	rmb	1
SCRRES	rmb	1
VIDEO	rmb	1
AUTO	rmb	1
MEDTYP	rmb	1
PROBYP	rmb	1
hpalno	rmb	1	hardware palette # to render to
hrdpal	rmb	2	address of chosen hardware palette

	       rmb	 250
size           equ       .
name           fcs       /view/
               fcb       edition

inittext       fcc       /Picture Viewer 0.2 by Roger Taylor/
	       fcb       $0d

clutpathname   fcn       "/dd/cmds/xtclut"

start
                    clra
                    clrb
                    os9       F$Mem
                    lbcs      err
                    sty       fmemupper
                    std       fmemsize

                    lda       #READ.
                    os9       I$Open
                    lbcs      err
                    sta       filepath

                    clra                      Path #
                    sta       currPath        Store current path

                    ldd       #0
                    std       clutnum
                    lbsr      LoadClut
                    lbsr      CreateBitmap
                    lbsr      Bitmap2Layer
                    lbsr      GrOn

                    ldd       #$0200
                    std       color


demo                bsr       Cls                 Updates currBlk
                    bcs       err
                    ldd       color
                    addd      #$0100              Fractional increment of color in MSB
                    std       color

keyloop@            lbsr      INKEY               Inkey routine with handlers for intergace
                    cmpa      #$0D                $0D=ok shift+$0d=cancel
                    bne       demo

bye                 clrb
err                 pshs      cc,b
                    lbsr      GrOff
                    puls      b,cc
                    os9       F$Exit

error_ds3           puls      u,y,x,a
error_ds2           os9       F$Exit

* Simple CLS uses Pixel
Cls                 ldd       #$0000
                    std       <PY
                    std       <PX
px@                 bsr       SetPixel
                    ldd       <PX
                    addd      #1
                    std       <PX
                    cmpd      #320
                    blo       px@
                    clr       <PX
                    clr       <PX+1
                    ldd       <PY
                    addd      #1
                    std       <PY
                    cmpd      #200
                    blo       px@
x@                  rts

SetPixel            bsr       GetXYBlk            Returns relative 8K block # in reg.b, offset into the block in reg.x
                    stx       ofsintoblk
                    bsr       MapInBlock          Maps in the associated block # of the bitmap screen
                    bcs       x@
                    ldd       ofsintoblk
                    adda      mapaddr
                    tfr       d,x
                    ldb       color
                    stb       ,x                  write pixel             
x@                  rts                           Return to the caller
MapInBlock          addb      bmblock
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
exit@               rts


* Convert PX/PY into relative 8K block #
* and offset into that block.
* (PY*320) is the same as (PY*256)+(PY*64)
* Then add PX, divide by 32 to get 8K block of the pixel.
GetXYBlk            pshs      d

                    lda       <PY+1               PY*256
                    clrb
                    std       ,s

                    lda       <PY+1               *64 and /64 are the same here but a MUL uses more cycles
                    clrb
                    lsra
                    rorb
                    lsra
                    rorb
                    addd      ,s                  (PY*256)+(PY*64)

                    addd      <PX
                    TFR       D,X
                    LSRA
                    LSRA
                    LSRA
	            LSRA
	            LSRA
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
                    clra                          Path #
                    ldb       #SS.DScrn           Display Screen with new settings
                    os9       I$SetStt            Turn on Graphics
                    bcs       x@
                    clrb
x@                  rts

GrOff               ldx       #%00000001          Turn Text on BM_TXT = %00000001
                    ldy       #%11111111          Don't change FFC1  FT_OMIT = %11111111
                    lda       ,s                  Path # from stack 
                    clra
                    ldb       #SS.DScrn           Display screen with new settings
                    os9       I$SetStt
                    bcs       x@                  Error
                    ldy       #2                  BM 0-2
par2@               lda       #0
                    ldb       #SS.FScrn           Free Bitmap
                    os9       I$SetStt
                    bcs       x@                  Error
                    clrb                          No Error
x@                  rts                           return to the caller
                    

LoadClut            pshs      a,x,y,u             Preserve regs
                    leax      clutpathname,pcr    6th parameter Get CLUT path
                    lda       #0                  F$Load a=language, 0=Any
                    os9       F$Link              Try linking module
                    beq       cont@               Load CLUT if no error
                    os9       F$Load              Load and set y=entry point
                    bcs       x@
cont@               ldx       clutnum
                    clra                          Path #
                    ldb       #SS.DfPal           Define Palette CLUT#0 with Y data
                    os9       I$SetStt
                    os9       F$Unlink            Clut defined now this saves 8K for Basic09         
                    bcs       x@
                    ldu       5,s                 F$Link,F$Load,F$Unlink all trash U
                    **** Set CLUT0 to BM0
                    ldx       clutnum             CLUT #
                    ldy       bitmapnum           Bitmap # 1st param
                    clra                          Path #
                    ldb       #SS.Palet           Assign CLUT # to Bitmap #
                    os9       I$SetStt
                    clrb
x@                  puls      u,y,x,a,pc

CreateBitmap        ldy       #0
                    sty       bitmapnum
                    ldx       #0                  2nd parameter screentype 0=320x240 1=320x200
                    clra                          Path #
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
                    clra                          Path #
                    ldb       #SS.PScrn           Position Bitmap # to Layer #
                    os9       I$SetStt
                    rts


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

ReadFileByte        pshs      b,x,y
                    lda       filepath
                    leax      filebyte,u
                    ldy       #1
                    os9       I$Read
                    lda       filebyte,u
                    puls      b,x,y,pc


               emod
eom            equ *
               end