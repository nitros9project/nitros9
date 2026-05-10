********************************************************************
* 
* 
* 
* 
* 
* 2025/01/24 SHELLBG by Matt Massie
* 
* NOS9 work by John Federico
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------


                    nam       shellbg
                    ttl       NitrOS-9 Shell BG


                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

progcnt             rmb       1
pxlblk0             rmb       1
pxlblk              rmb       1
pxlblkaddr          rmb       2
currPath            rmb       1         current path for file read
bmblock0            rmb       1
bmblock             rmb       1         bitmap block#
mapaddr             rmb       2         Address for mapped block
currBlk             rmb       2         current mapped in block, (need to read into X)
blkCnt              rmb       1         Counter for block loop
notheme             rmb       1         notheme 0=Theme Found 1=No Theme found load default bg
themenum            rmb       1         pixmap theme number
bytecnt             rmb       2         themefile byte count
clutaddr            rmb       2         clut map address         
bufstrt             rmb       2         buffer start
bufcur              rmb       2         current position buffer
linebuf             rmb       80        buffer
themefile           rmb       32        themefile read buffer        
clutfile            rmb       32        clut filename
pixmapfile          rmb       50        pixmap filename
                    rmb       250       stack space
size                equ       .

name                fcs       /shellbg/
                    fcb       edition

start               clr       <pxlblk0
                    clr       <pxlblk
                    clr       <pxlblkaddr
                    clr       <pxlblkaddr+1
                    clr       <bmblock0
                    clr       <blkcnt
                    clr       <notheme
                    clra
                    ldx       pixmapfile,u        clear pixmap filename
                    ldb       #50
loopclr@            sta       ,x+
                    decb
                    bne       loopclr@
                    lbsr      gettheme            check for theme name
                    lbsr      progbar             initialize progress bar
*                   **** Get a new bitmap 2
                    ldy       #$2                 Bitmap #
                    ldx       #$0                 Screentype = 320x240 (1=320x200)
                    lda       #$1                 Path #
                    ldb       #SS.AScrn           Assign and create bitmap
                    os9       I$SetStt
                    lbcs      error
                    tfr       x,d
                    stb       <bmblock            Store bitmap block# for later use
clutload
*                   **** Try to link CLUT data module
*                   **** If Link fails, then Load the module from default chx
                    ldb       <notheme
                    beq       ldtheme@
                    leax      clutname,pcr        F$Load x=address of path
                    bra       ld@
ldtheme@            leax      clutfile,u
ld@                 lda       #0                  F$Load a=langauge, 0=any
                    os9       F$Link              Try linking module
                    beq       cont@               Load CLUT if no error, if error, try load
                    os9       F$Load              Load and set Y=entry point of module
                    lbcs      error
cont@               ldx       #$2                 CLUT #
                    lda       #$1                 Path #
                    ldb       #SS.DfPal           Define Palette CLUT#0 with data Y
                    os9       I$SetStt
                    stu       <clutaddr           save clut map address
                    ;os9       F$Unlink            Clut defined now this saves 8K
                    lbcs      error

setBMClut
*                   **** Assign CLUT2 to BM2
                    ldx       #2                  CLUT #
                    ldy       #2                  Bitmap #
                    lda       #1                  Path #
                    ldb       #SS.Palet           Assign Clut # to Bitmap #
                    os9       I$SetStt

setlayer
*                   **** Assign BM2 to Layer2               
                    ldx       #2                  Layer #
                    ldy       #2                  Bitmap #
                    lda       #1                  Path # 
                    ldb       #SS.PScrn           Position Bitmap # on Layer #
                    os9       I$SetStt

                    lda       #$36                First BMBlock
                    sta       <bmblock
                    ldb       <notheme
                    beq       ldtheme@
                    leax      pixmap4,pcr         no theme load default bg
                    bra       ld@
ldtheme@            lbsr      getpixmap           loookup theme pixmap 
*                   **** Open Pixmap
ld@                 lda       #READ.
                    os9       I$Open
                    lbcs      error
                    sta       <currPath
                    ldb       <bmblock
                    clra
                    std       <currBlk
                    sta       <blkCnt
loadimage           pshs      u
                    ldb       #1
                    ldx       <currBlk
                    os9       F$MapBlk
                    bcc       noerr@
                    puls      u
                    lbra      error
noerr@              stu       <mapaddr
                    puls      u
                    
                    lda       <currPath
                    ldx       <mapaddr
                    ldy       #$2000
                    os9       I$Read
                    bcc       noerr@
                    cmpb      #E$EOF
                    beq       loaddone
                    lbra      error
noerr@              inc       <blkCnt

                    pshs      u
                    ldu       <mapaddr
                    ldb       #1
                    os9       F$ClrBlk
                    puls      u
                    lbsr      progbar
                    lda       <blkCnt
                    cmpa      #$0A
                    beq       loaddone
                    inc       <currBlk+1
                    bra       loadimage

loaddone            lda       <currPath
                    os9       I$Close
                    lbcs      error

gfxon
                   **** Turn on Graphics
                    ldx       #$0F                #FX_BM+FX_GRF       Turn on Bitmaps and Graphics
                    ldy       #FT_OMIT            Don't change $FFC1
                    lda       #$01                Path #
                    ldb       #SS.DScrn           Display Screen with new settings 
                    os9       I$SetStt            
                    lbcs      error
                    lbsr      progdone
                    bra       clutfree@
;error               stb       $fee0               save error code in Math CoPro
error               pshs      b
                    lbsr      progerr
                    puls      b
clutfree@           pshs      b
                    ldu       <clutaddr
                    lda       #1                  path
                    os9       F$Unlink            Clut defined now this saves 8K
                    puls      b
                    os9       F$Exit

* FALL THROUGH
* Store A at next position in output buffer.
bufchr              pshs      x
                    ldx       <bufcur
                    sta       ,x+
                    stx       <bufcur
                    puls      pc,x

* Append CR to the output buffer then print the output buffer
wrbuf               pshs      y,x,a
                    lda       #C$CR
                    bsr       bufchr
                    ldx       <bufstrt            address of data to write
                    stx       <bufcur             reset output buffer pointer, ready for next line.
                    ldy       #80                 maximum # of bytes - otherwise, stop at CR
                    lda       #$01                to STDOUT
                    os9       I$WritLn
                    puls      pc,y,x,a


* Append string at Y to output buffer. String is terminated by MSB=1
tobuf               pshs      a
bufloop             lda       ,y
                    anda      #$7F
                    bsr       bufchr
                    tst       ,y+
                    bpl       bufloop
                    puls      a
                    rts

* Progress bar
progbar             leax      linebuf,u           get line buffer address
                    stx       <bufstrt            and store it away
                    stx       <bufcur             current output position output buffer
                    lda       #$02                cursor x y
                    lbsr      bufchr
                    lda       #$20                x at position 0 - add $20+x
                    lbsr      bufchr
                    lda       #$2D                y at line D - add $20+y
                    lbsr      bufchr
                    leay      cmdtxt,pcr          cmd banner
                    lbsr      tobuf
                    ldb       <blkCnt             get number of mapped blocks
                    cmpb      #$00                any blocks mapped?
                    beq       next@              
loop@               lda       #$1c                escape control code
                    lbsr      bufchr
                    lda       #$11                was DB
                    lbsr      bufchr
                    decb
                    bne       loop@
next@               ldb       #10                 10 Blocks to load
                    subb      <blkcnt
                    beq       done@
loop2@              lda       #$20                space
                    lbsr      bufchr              
                    decb        
                    bne       loop2@
done@               lda       #']
                    lbsr      bufchr             
                    lbsr      wrbuf               write buffer to screen
                    rts

progdone            leax      linebuf,u           get line buffer address - load done
                    stx       <bufstrt            and store it away
                    stx       <bufcur             current output position output buffer
                    lda       #$02                cursor x y
                    lbsr      bufchr
                    lda       #$20                x at position 0
                    lbsr      bufchr
                    lda       #$2D                y at line D
                    lbsr      bufchr
                    leay      cmdtxt2,pcr         cmd banner
                    lbsr      tobuf
                    ldb       #10                 
loop@               lda       #$1c
                    lbsr      bufchr
                    lda       #$11
                    lbsr      bufchr
                    decb             
                    bne       loop@
                    lda       #']
                    lbsr      bufchr             
done@               lbsr      wrbuf               write buffer to screen
                    rts

progerr             leax      linebuf,u           get line buffer address - load done
                    stx       <bufstrt            and store it away
                    stx       <bufcur             current output position output buffer
                    lda       #$02                cursor x y
                    lbsr      bufchr
                    lda       #$20                x at position 0
                    lbsr      bufchr
                    lda       #$2D                y at line D
                    lbsr      bufchr
                    leay      cmderr,pcr          cmd banner
                    lbsr      tobuf             
done@               lbsr      wrbuf               write buffer to screen
                    rts


* Check for theme file
gettheme            lda       #READ.
                    leax      themename,pcr
                    os9       I$Open
                    lbcs      notheme@           no theme file found
                    sta       <currPath          store current path
                    leax      themefile,u        themefile
                    ldy       #32                #32 bytes/bytes to read
                    os9       I$Read
                    bcc       loaddone@
                    cmpb      #E$EOF
                    beq       loaddone@          load done?
                    bra       err
loaddone@           lda       <currPath
                    os9       I$Close
                    bcc       done@
err                 ldb       #1
                    lda       #'$                $ for tracking errors
                    lbsr      bufchr
done@               pshs      y                  push byte count from read
                    sty       <bytecnt           save byte count
                    leax      clutpre,pcr        add clut prefix
                    leay      clutfile,u         build the clutfilename
                    ldb       #24                24 bytes to prepent to clutname
loopnm@             lda       ,x+
                    sta       ,y+
                    decb
                    bne       loopnm@
                    leax      themefile,u        now add read theme to filename
                    puls      d                  B now contains byte count from read
                    clra
                    pshs      d
loopcl@             lda       ,x+
                    sta       ,y+                build clutfile
                    decb
                    bne       loopcl@
                    leax      pixmappre,pcr      now add pixmap prefix
                    leay      pixmapfile,u       build the pixmap filename
                    ldb       #20                15 !/dd/cmds/pixmap!
looppx@             lda       ,x+
                    sta       ,y+
                    decb
                    bne       looppx@
                    puls      d
                    lbsr      themeidx           lookup theme index
                    leax      linebuf,u
                    leay      themetxt,pcr
                    stx       <bufstrt           and store it away
                    stx       <bufcur            current output position output buffer
                    lbsr      tobuf
                    ldd       <bytecnt           load theme name byte cnt
                    decb                         decrement 1 remove $0D
                    leay      themefile,u
tloop@              lda       ,y+
                    lbsr      bufchr
                    decb
                    bne       tloop@
                    lda       #$20               Space
                    lbsr      bufchr
                    leay      pixmapfile,u
                    lbsr      tobuf                
                    lbsr      wrbuf
                    bra       done2@
notheme@            lda       #$01
                    sta       <notheme
                    lbsr      nothememsg
done2@              rts

themeidx            leax      themefile,u
                    lda       ,x+
                    cmpa      #'w
                    bne       next@
                    lda       ,x+
                    cmpa      #'o
                    bne       next@
                    lda       ,x+
                    cmpa      #'o
                    bne       next@
                    lda       ,x+
                    cmpa      #'d
                    bne       next@
                    lda       #1
                    sta       <themenum
                    lbra       done@
next@               leax      themefile,u
                    lda       ,x+
                    cmpa      #'m
                    bne       next2@
                    lda       ,x+
                    cmpa      #'e
                    bne       next2@
                    lda       ,x+
                    cmpa      #'t
                    bne       next2@
                    lda       ,x+
                    cmpa      #'a
                    bne       next2@
                    lda       ,x+
                    cmpa      #'l
                    bne       next2@
                    lda       #2
                    sta       <themenum
                    lbra       done@
next2@              leax      themefile,u
                    lda       ,x+
                    cmpa      #'s
                    bne       next3@
                    lda       ,x+
                    cmpa      #'t
                    bne       next3@
                    lda       ,x+
                    cmpa      #'o
                    bne       next3@
                    lda       ,x+
                    cmpa      #'n
                    bne       next3@
                    lda       ,x+
                    cmpa      #'e
                    bne       next3@
                    lda       ,x+
                    cmpa      #'2
                    beq       st2@
                    lda       #3
                    sta       <themenum
                    lbra       done@
st2@                lda       #7
                    sta       <themenum
                    lbra       done@                    
next3@              leax      themefile,u
                    lda       ,x+
                    cmpa      #'g
                    bne       next4@
                    lda       ,x+
                    cmpa      #'r
                    bne       next4@
                    lda       ,x+
                    cmpa      #'i
                    bne       next4@
                    lda       ,x+
                    cmpa      #'d
                    bne       next4@
                    lda       #4
                    sta       <themenum
                    lbra       done@
next4@              leax      themefile,u
                    lda       ,x+
                    cmpa      #'m
                    bne       next5@
                    lda       ,x+
                    cmpa      #'e
                    bne       next5@
                    lda       ,x+
                    cmpa      #'a
                    bne       next5@
                    lda       ,x+
                    cmpa      #'d
                    bne       next5@
                    lda       ,x+
                    cmpa      #'o
                    bne       next5@
                    lda       ,x+
                    cmpa      #'w
                    bne       next5@
                    lda       #5
                    sta       <themenum
                    bra       done@
next5@              leax      themefile,u
                    lda       ,x+
                    cmpa      #'b
                    bne       next6@
                    lda       ,x+
                    cmpa      #'e
                    bne       next6@
                    lda       ,x+
                    cmpa      #'a
                    bne       next6@
                    lda       ,x+
                    cmpa      #'c
                    bne       next6@
                    lda       ,x+
                    cmpa      #'h
                    bne       next6@
                    lda       #6
                    sta       <themenum
                    bra       done@
next6@              leax      themefile,u
                    lda       ,x+
                    cmpa      #'s
                    bne       default@
                    lda       ,x+
                    cmpa      #'p
                    bne       default@
                    lda       ,x+
                    cmpa      #'a
                    bne       default@
                    lda       ,x+
                    cmpa      #'c
                    bne       default@
                    lda       ,x+
                    cmpa      #'e
                    bne       default@
                    lda       #8
                    sta       <themenum
                    bra       done@
default@            lda       #4
                    sta       <themenum
done@               rts

getpixmap           lda       <themenum
                    cmpa      #1
                    bne       next@
                    leax      pixmap1,pcr
                    bra       done@
next@               cmpa      #2
                    bne       next2@
                    leax      pixmap2,pcr
                    bra       done@
next2@              cmpa      #3
                    bne       next3@
                    leax      pixmap3,pcr
                    bra       done@
next3@              cmpa      #4
                    bne       next4@
                    leax      pixmap4,pcr
                    bne       done@
next4@              cmpa      #5
                    bne       next5@
                    leax      pixmap5,pcr
                    bra       done@
next5@              cmpa      #6
                    bne       next6@
                    leax      pixmap6,pcr
                    bra       done@
next6@              cmpa      #7
                    bne       next7@
                    leax      pixmap7,pcr
                    bra       done@
next7@              cmpa      #8
                    bne       done@
                    leax      pixmap8,pcr
done@               rts
                    

nothememsg          leax      linebuf,u
                    leay      themetxt2,pcr
                    stx       <bufstrt          and store it away
                    stx       <bufcur           current output position output buffer
                    lbsr      tobuf
                    lbsr      wrbuf
                    rts


clutname            fcs       !/dd/sys/backgrounds/clutgrid!
                    fcb       $0d
themename           fcs       !/dd/sys/backgrounds/theme!
cmdtxt              fcs       /Loading GFX [/
cmdtxt2             fcs       /Loaded  GFX [/
cmderr              fcs       /Loading GFX [  ERROR   ]/
themetxt            fcs       /Theme: /
themetxt2           fcs       /Theme: Default/
clutpre             fcs       !/dd/sys/backgrounds/clutt!
pixmappre           fcs       !/dd/sys/backgrounds/!
pixmap1             fcs       !/dd/sys/backgrounds/pixmapwood!
                    fcb       $0d
pixmap4             fcs       !/dd/sys/backgrounds/pixmapgrid!
                    fcb       $0D
pixmap2             fcs       !/dd/sys/backgrounds/pixmapmetal!
                    fcb       $0D
pixmap3             fcs       !/dd/sys/backgrounds/pixmapstone!
                    fcb       $0d
pixmap5             fcs       !/dd/sys/backgrounds/pixmapmeadow!
                    fcb       $0d
pixmap6             fcs       !/dd/sys/backgrounds/pixmapbeach!
                    fcb       $0d
pixmap7             fcs       !/dd/sys/backgrounds/pixmapstone2!
                    fcb       $0d
pixmap8             fcs       !/dd/sys/backgrounds/pixmapspace!
                    fcb       $0d
                    
                    emod
eom                 equ       *
                    end
