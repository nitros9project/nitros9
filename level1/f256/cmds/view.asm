********************************************************************
* psg - F256 Picture Viewer
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2025/10/25  R Taylor
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
Return              rmb       2         $00    Return address of caller
PCount              rmb       2         $02    # of parameters following
PrmPtr1             rmb       2         $04 00 pointer to 1st parameter data
PrmLen1             rmb       2         $06 02 length of 1st parameter
PrmPtr2             rmb       2         $08 04 pointer to 2nd parameter data
PrmLen2             rmb       2         $0A 06 length of 2nd parameter
PrmPtr3             rmb       2         $0C 08 pointer to 3rd parameter data
PrmLen3             rmb       2         $0E 0A length of 3rd parameter
PrmPtr4             rmb       2         $10 0C pointer to 4th parameter data
PrmLen4             rmb       2         $12 0E length of 4th parameter
PrmPtr5             rmb       2         $14 10 pointer to 5th parameter data
PrmLen5             rmb       2         $16 12 length of 5th parameter
PrmPtr6             rmb       2         $18 14 pointer to 6th parameter data
PrmLen6             rmb       2         $1A 16 length of 6th parameter
PrmPtr7             rmb       2         $1C 18 pointer to 7th parameter data
PrmLen7             rmb       2         $1E 1A length of 7th parameter
PrmPtr8             rmb       2         $20 1C pointer to 8th parameter data
PrmLen8             rmb       2         $22 1E length of 8th parameter
X1                  rmb       2         $24 20 Universal X1 Variable
Y1                  rmb       2         $26 22 Universal Y1 Variable
X2                  rmb       2         $28 24 Universal X2 Variable
Y2                  rmb       2         $2A 26 Universal Y2 Variable
dx                  rmb       2         $2C 28
dy                  rmb       2         $2E 2A
dx2                 rmb       2         $30 2C
dy2                 rmb       2         $32 2E
p                   rmb       2         $34 30
currBlk             rmb       2         $36 32 Variable currBlk BMLoad
mapaddr             rmb       2         $38 34 Variable mapaddr BMLoad
pxlblk0             rmb       1         $3A 36 Variable for Pixel
pxlblk              rmb       1         $3C 38 Variable for Pixel
pxlblkaddr          rmb       2         $3E 3A
bmblock             rmb       1         $40 3C first bitmap block
steep               rmb       1         $41 3D line variables
univ8a              rmb       1         $42 3E
univ8b              rmb       1         $43 3F
univ8c              rmb       1         $44 40
univ8d              rmb       1         $45 41
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
stkdepth            equ       .

bitmapnum rmb 2
filepath      rmb 1
clutnum rmb 2
filebuf             rmb       2
fmemupper           rmb       2
fmemsize            rmb       2


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
COLOR	rmb	2
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

inittext       fcc       /Picture Viewer 0.1 by Roger Taylor/
	       fcb       $0d

clutpathname   fcn       "/dd/cmds/xtclut"

start
                    clra
                    clrb
                    os9       F$Mem
                    lbcs      err
                    sty       fmemupper
                    std       fmemsize

                *     lda       #READ.
                *     os9       I$Open
                *     lbcs      err
                *     sta       filepath

                    ldd       #0
                    std       clutnum
                    ldd       #0
                    std       bitmapnum

* A few moments later...

                    ldy       bitmapnum
                    ldx       #0                  2nd parameter screentype 0=320x240 1=320x200
                    clra                          Path #
                    ldb       #SS.AScrn           Assign and create bitmap
                    os9       I$SetStt         
                    bcc       storeblk            No error store block #
                    cmpb      #E$WADef            Check if windows already defined
                    bne       error_ds2
storeblk            tfr       x,d              
                    std       bmblock             Save BMBlock                

Clut                pshs      a,x,y,u             Preserve regs
                    leax      clutpathname,pcr    6th parameter Get CLUT path
                    lda       #0                  F$Load a=language, 0=Any
                    os9       F$Link              Try linking module
                    beq       cont@               Load CLUT if no error
                    os9       F$Load              Load and set y=entry point
                    bcs       error_ds3
cont@               ldx       clutnum
                    clra                          Path #
                    ldb       #SS.DfPal           Define Palette CLUT#0 with Y data
                    os9       I$SetStt
                    os9       F$Unlink            Clut defined now this saves 8K for Basic09         
                    bcs       error_ds3
                    ldu       5,s                 F$Link,F$Load,F$Unlink all trash U
                    **** Set CLUT0 to BM0
                    ldx       clutnum             CLUT #
                    ldy       bitmapnum           Bitmap # 1st param
                    clra                          Path #
                    ldb       #SS.Palet           Assign CLUT # to Bitmap #
                    os9       I$SetStt
                    
                    puls      u,y,x,a

                    **** Assign Bitmap to Layer
                    ldx       #0                  Layer # 
                    ldy       bitmapnum           Bitmap #
                    clra                          Path #
                    ldb       #SS.PScrn           Position Bitmap # to Layer #
                    os9       I$SetStt

                    ldx       #$2F                ;#%00001000+%00000100    Turn on Bitmaps and Graphics FX_BM = %00001000  FX_GRX = %00000100
                    ldx       #%00001111
*                     FX_OVR = %00000010          Overlay Text on Graphics
*                     FX_TXT = %00000001          Text Mode On
*                     Sprite = %00100000          Sprite Enable
*                     TileMap= %00010000          TileMap Enable
                    ldy       #%11111111          Don't change FFC1  FT_OMIT = %11111111
                    clra                          Path #
                    ldb       #SS.DScrn           Display Screen with new settings
                    os9       I$SetStt            Turn on Graphics
                    clrb                          no error

                    bsr       Cls
                    bsr       Pixel

keyloop@            lbsr      INKEY               Inkey routine with handlers for intergace
                    cmpa      #$0D                $0D=ok shift+$0d=cancel
                    bne       keyloop@

bye                 clrb
err                 pshs      cc,b
                    lbsr      Goff
                    puls      b,cc
                    os9       F$Exit


error_ds3           puls      u,y,x,a
error_ds2           os9       F$Exit


Pixel               clra                      Path #
                    sta       currPath      store current path
                    ldd       bmblock             get first bitmap block
                    std       currBlk       store current block

                    ldb       #1
                    ldx       currBlk       restore current block
                    pshs      u                F$MapBlk with destroy U so push
                    os9       F$MapBlk
                    bcc       noerr@
                    puls      u                restore U from stack
                    lbra      err@
noerr@              stu       mapaddr     since U is pushed add 2 to variable ref.
                    puls      u                restore U from stack
                    lda       currPath      load path
                    ldx       mapaddr       map address in X
                    leax      (24*320),x
                    ldy       #320           number of bytes to clear
                    ldd       #$aaaa         same color byte x 2
p@                  std       ,x++                write pixel             
                    leay      -2,y                decrement Y pointer
                    bne       p@                  done?
                    pshs      u                   F$ClrBlk will destroy U, so push it
                    ldu       mapaddr             since U is pushed add 2 to variable ref.
                    ldb       #1
                    os9       F$ClrBlk
                    puls      u                restore U from stack                   
                    lda       currPath      restore path
err@                rts                        return to the caller


Cls                 clra                      Path #
                    sta       currPath      store current path
                    ldd       bmblock             get first bitmap block
                    std       currBlk       store current block
                    clra                       clear block cnt
                    sta       blkCnt       store block cnt
clearimage          ldb       #1
                    ldx       currBlk       restore current block
                    pshs      u                F$MapBlk with destroy U so push
                    os9       F$MapBlk
                    bcc       noerr@
                    puls      u                restore U from stack
                    lbra      errcl2
noerr@              stu       mapaddr     since U is pushed add 2 to variable ref.
                    puls      u                restore U from stack
                    lda       currPath      load path
                    ldx       mapaddr       map address in X
                    ldy       #$2000           number of bytes to clear
                    ldd       #$0000         same color byte x 2
pixelloop           std       ,x++              write pixel             
                    leay      -2,y             decrement Y pointer
                    bne       pixelloop        done?
cont@               inc       blkCnt        increment blk cnt
                    pshs      u                F$ClrBlk will destroy U, so push it
                    ldu       mapaddr     since U is pushed add 2 to variable ref.
                    ldb       #1
                    os9       F$ClrBlk
                    puls      u                restore U from stack                   
                    lda       blkCnt        load block cnt
                    cmpa      #$0A             is it the end?
                    beq       cleardone
                    inc       currBlk+1     increment current block
                    bra       clearimage
cleardone           lda       currPath      restore path
errcl2              rts                        return to the caller



Goff                ldx       #%00000001       Turn Text on BM_TXT = %00000001
                    ldy       #%11111111       Don't change FFC1  FT_OMIT = %11111111
                    lda       ,s               Path # from stack 
                    clra
                    ldb       #SS.DScrn        Display screen with new settings
                    os9       I$SetStt
                    bcs       error_ds         Error

                    ldy       #2               BM 0-2
par2@               lda       #0
                    ldb       #SS.FScrn        Free Bitmap
                    os9       I$SetStt
                    bcs       error_ds         Error

                    clrb                       No Error
error_ds            rts                        return to the caller
                    

********************************************************************
* INKEY routine from alib
*
INKEY          clra                          std in
               ldb       #SS.Ready
               os9       I$GetStt            see if key ready
               bcc       getit
               cmpb      #E$NotRdy           no keys ready=no error
               bne       exit@               other error, report it
               clra                          no error
               bra       exit@
getit          lbsr      FGETC               go get the key
               tsta
exit@          rts

FGETC          pshs      a,x,y
               ldy       #1                  number of char to print
               tfr       s,x                 point x at 1 char buffer
               os9       I$Read
               puls      a,x,y,pc



               emod
eom            equ *
               end