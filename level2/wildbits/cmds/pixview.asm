********************************************************************
* 
* 
* 
* 
* 
* Pixview - by Matt Massie
* 
*
* 
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* started  2026/07/02 - 2026/07/12
* ------------------------------------------------------------------


                    nam       pixview
                    ttl       NitrOS-9 pixview


                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

finalpath           rmb       62        filepath 29 file + 29 folder + 4 drive
key                 rmb       1         key pressed
currPath            rmb       1         current path for file read
bmblock             rmb       1         bitmap block#
mapaddr             rmb       2         Address for mapped block
currBlk             rmb       2         current mapped in block, (need to read into X)
blkCnt              rmb       1         Counter for block loop
clutheader          rmb       2
clutdata            rmb       2
pixvpath            rmb       80        partner clut/pixmap path built by DoPixV
pixfn               rmb       2         file-name start pointer within finalpath  
optmode             rmb       1         0 = view+pause+off, 1 = -on (leave image up)
                    rmb       250       stack space
size                equ       .

                    mod       eom,name,tylg,atrv,start,size

name                fcs       /pixview/
                    fcb       edition

* On entry from F$Fork: X = parameter string (CR-terminated), Y = memory top,
* U = data base.
*
* Command line forms:
*   pixmap                 -> "Pixmap -h for help"
*   pixmap -h              -> help (one line per I$WritLn)
*   pixmap <path|file>     -> show the image, wait for space, restore text
*   pixmap -on <path|file> -> show the image and LEAVE it on, exit at once
*   pixmap -off            -> switch the display back to text
*
* The file may be a full path (/dd/sys/backgrounds/pixmapbeach) or a bare
* name (pixmapbeach) - the scan below defaults the file-name start to the
* whole string, so a name with no '/' simply has an empty directory prefix.
start               clr       <optmode            default: view, pause, then text
* ---- skip leading spaces ----
sksp@               lda       ,x
                    cmpa      #$20
                    bne       sk1@
                    leax      1,x
                    bra       sksp@
sk1@                cmpa      #C$CR               no arguments at all?
                    lbeq      nousage
                    cmpa      #'-                 an option?
                    bne       cpstart@            no - treat as a file name
* ---- parse the option ----
                    lda       1,x                 char after '-'
                    lbsr      toLower
                    cmpa      #'h
                    lbeq      dohelp
                    cmpa      #'o
                    lbne      nousage            unknown option
                    lda       2,x                 char after "-o"
                    lbsr      toLower
                    cmpa      #'n
                    beq       opton@
                    cmpa      #'f
                    lbeq      dooff
                    lbra      nousage
* ---- -on <file>: show the image and leave it enabled ----
opton@              lda       #1
                    sta       <optmode
                    leax      3,x                 step past "-on"
opsp@               lda       ,x                  skip spaces before the file name
                    cmpa      #$20
                    bne       opfn@
                    leax      1,x
                    bra       opsp@
opfn@               cmpa      #C$CR               -on with no file name
                    lbeq      nousage
* ---- copy the file name / path (X, CR-terminated) into finalpath.
*      Guard the copy so an over-long path cannot run past the buffer. ----
cpstart@            leay      finalpath,u         Y = destination
                    clrb                          B = chars copied
cppar@              lda       ,x+
                    sta       ,y+
                    cmpa      #C$CR               copied the terminator? done
                    beq       cpdone@
                    incb
                    cmpb      #61                 room left (62 incl. the $0D)?
                    blo       cppar@
                    lda       #C$CR               too long - force-terminate
                    sta       ,y
cpdone@             lbsr      bitmap         allocate bitmap
* finalpath now holds the selected path (CR-terminated), copied from the parameter.
* The clut/pixmap marker is the PREFIX of the file name (e.g. clutbeach / pixmapbeach),
* with the base name (beach) shared. Locate the file name (after the last '/'), test its
* leading marker, and build the partner = <dir prefix> + <other marker> + <base name>.
* pixmapload and clutload each want X pointing at a $0D-terminated path.
                    leax      finalpath,u         scan from start of path
                    leay      finalpath,u         Y = file name start (default whole path)
fnsl@               lda       ,x+
                    cmpa      #C$CR
                    beq       fnsd@
                    cmpa      #$2F                '/'
                    bne       fnsl@
                    leay      ,x                  remember byte after this '/'
                    bra       fnsl@
fnsd@               sty       pixfn,u             save file name start
* does the file name begin with "clut"?
                    tfr       y,x                 X = file name start
                    leay      CLUTSFX,pcr
                    ldb       #CLUTLEN
ckclut@             lda       ,x+
                    cmpa      ,y+
                    bne       ispix@              not "clut" -> treat as "pixmap"
                    decb
                    bne       ckclut@
* file name begins "clut": finalpath = clut, partner = pixmap
                    lda       #CLUTLEN            own marker length to skip (4)
                    leax      PIXMAPSFX,pcr       partner marker
                    ldb       #PIXMAPLEN          partner marker length (6)
                    lbsr      bldpix              pixvpath = dir + "pixmap" + base
                    leax      finalpath,u         X -> clut path
                    lbsr      clutload            load palette first
                    leax      pixvpath,u          X -> pixmap path
                    lbsr      pixmapload          load pixmap
                    bra       pixshow@
* otherwise treat as "pixmap": finalpath = pixmap, partner = clut
ispix@              lda       #PIXMAPLEN         own marker length to skip (6)
                    leax      CLUTSFX,pcr         partner marker
                    ldb       #CLUTLEN            partner marker length (4)
                    lbsr      bldpix              pixvpath = dir + "clut" + base
                    leax      pixvpath,u          X -> clut path
                    lbsr      clutload            load palette first
                    leax      finalpath,u         X -> pixmap path
                    lbsr      pixmapload          load pixmap
* Show the image: graphics on, print the file name, wait for the space bar,
* graphics off, exit. GOn leaves text visible over the bitmap, so the name
* appears on top of the image. The wait loop reads and discards any other
* key, which also drains a stray keystroke left over from the launch.
pixshow@            lbsr      GOn
                    lda       <optmode
                    cmpa      #1                  -on: leave the image up, no name,
                    beq       rdone               no pause - exit right away
* print the file name over the image (pixfn = start of the name within
* finalpath, which is $0D-terminated, so I$WritLn stops at the terminator),
* then the prompt. Only the plain "pixview <clut*|pixmap*>" form reaches
* here: -on exited above, and -off never loads an image at all.
                    ldx       pixfn,u             X = file name start
                    ldy       #62                 upper bound - the $0D ends it
                    lda       #1                  path 1 = stdout
                    os9       I$WritLn
                    leax      PRESSSP,pcr         "Press space to continue"
                    lbsr      putln
                    clr       <key
dbgpau@             lbsr      Inkey
                    cmpa      #32                 space ends the view
                    bne       dbgpau@
                    lbsr      GOff
* Standalone program: terminate with F$Exit - a forked process must never
* RTS. The parent (File Manager) sits in F$Wait and redraws its own screen
* when we exit, exactly like te / hexed / basic09.
rdone               clrb                          B = 0: no error
                    os9       F$Exit

* ---- no arguments (or an unrecognised option): one-line usage ----
nousage             leax      UsageMsg,pcr
                    lbsr      putln
                    bra       rdone
* ---- -h : help, one row per I$WritLn ----
dohelp              leax      Help1,pcr
                    lbsr      putln
                    leax      Help2,pcr
                    lbsr      putln
                    leax      Help3,pcr
                    lbsr      putln
                    leax      Help4,pcr
                    lbsr      putln
                    bra       rdone
* ---- -off : switch the display back to text. GOff is NOT used here: it also
*      unlinks the CLUT and frees the bitmap, neither of which we allocated
*      on this path, so it would act on garbage. GText only sets text mode. ----
dooff               lbsr      GText
                    bra       rdone

* Build pixvpath = <dir prefix of finalpath, up to the saved file-name start (pixfn)>
*                + <partner marker (string at X, length B)>
*                + <base name = finalpath file name with its own A-byte marker skipped,
*                   copied through the trailing $0D>
* entry:  A = own marker length to skip in the source file name
*         X = pointer to the partner marker string
*         B = length of the partner marker string
*         pixfn = pointer to the file-name start within finalpath
* exit:   pixvpath holds the assembled $0D-terminated path
* note:   U (data base) preserved; A,B,X,Y are scratch
bldpix              pshs      a,b,x               0,s=skip 1,s=plen 2,s=pstr
                    leay      pixvpath,u          Y = destination buffer
* phase 1: copy directory prefix (finalpath start .. pixfn-1)
                    leax      finalpath,u         X = source
bpdir@              cmpx      pixfn,u             reached the file name?
                    beq       bpmrk@
                    lda       ,x+
                    sta       ,y+
                    bra       bpdir@
* phase 2: append the partner marker
bpmrk@              ldx       2,s                 X = partner marker string
                    ldb       1,s                 B = partner marker length
bpmc@               lda       ,x+
                    sta       ,y+
                    decb
                    bne       bpmc@
* phase 3: append the base name (file name past its own marker, through $0D)
                    ldx       pixfn,u             X = file name start
                    ldb       ,s                  B = own marker length
                    abx                           X = base name start
bpbc@               lda       ,x+
                    sta       ,y+
                    cmpa      #C$CR               copy through the terminator
                    bne       bpbc@
                    puls      a,b,x,pc


********************************************************************
* Convert Alpha Char to Lowercase
*
toLower             cmpa      #'A
                    blo       x@
                    cmpa      #'Z
                    bhi       x@
                    ora       #32
x@                  rts

*                   **** Get a new bitmap 0
bitmap              pshs      x,y,u,b,a
                    ldy       #$0                 Bitmap #0
                    ldx       #$0                 Screentype = 320x240 (1=320x200)
                    lda       #$1                 Path #1
                    ldb       #SS.AScrn           Assign and create bitmap
                    os9       I$SetStt
                    bcc       storeblk            No error, store block#
                    cmpb      #E$WADef            Check if window already defined
                    lbne      bmperror            if other error, then end else continue
storeblk            tfr       x,d
                    stb       <bmblock            Store bitmap block# for later use

setBMClut
*                   **** Assign CLUT2 to BM0
                    ldx       #0                  CLUT #0
                    ldy       #0                  Bitmap #0
                    lda       #1                  Path #1
                    ldb       #SS.Palet           Assign Clut # to Bitmap #
                    os9       I$SetStt

setlayer
*                   **** Assign BM2 to Layer2
                    ldx       #0                  Layer #0
                    ldy       #0                  Bitmap #0
                    lda       #1                  Path #1
                    ldb       #SS.PScrn           Position Bitmap # on Layer #
                    os9       I$SetStt
bitmapdone          puls      x,y,u,b,a,pc

*                    **** Turn on Graphics
*                   **** Switch the display back to text only.
*                        Unlike GOff this does NOT unlink the CLUT or free the
*                        bitmap - it is used by -off, which never loaded an image.
GText               pshs      x,y,u,b,a
                    ldx       #FX_TXT             Turn on Text, all else off
                    ldy       #FT_OMIT            Don't change $FFC1
                    lda       #$01                Path #1
                    ldb       #SS.DScrn           Display Screen with new settings
                    os9       I$SetStt
                    lbcs      bmperror
* release the bitmap page a previous -on left mapped in
                    ldy       #0                  BM 0-2
                    lda       #0
                    ldb       #SS.FScrn           Free Bitmap
                    os9       I$SetStt
                    clrb
                    puls      x,y,u,b,a,pc

*                   **** Write one $0D-terminated line at X to stdout
putln               pshs      x,y,b,a
                    ldy       #80                 upper bound - the $0D ends it
                    lda       #1                  path 1 = stdout
                    os9       I$WritLn
                    puls      x,y,b,a,pc

GOn                 pshs      x,y,u,b,a
                    ldx       #$0F
                    ldy       #FT_OMIT            Don't change $FFC1
                    lda       #$01                Path #1
                    ldb       #SS.DScrn           Display Screen with new settings 
                    os9       I$SetStt            
                    lbcs      bmperror             
                    puls      x,y,u,b,a,pc

*                   **** Turn off bitmap
GOff                pshs      x,y,u,b,a
                    ldx       #FX_GRF             Turn on Bitmaps and Graphics
                    ldy       #FT_OMIT            Don't change $FFC1
                    lda       #$01                Path #1
                    ldb       #SS.DScrn           Display Screen with new settings 
                    os9       I$SetStt            
                    lbcs      bmperror

*                   **** Turn off Graphics
                    ldx       #FX_TXT             Turn on Text, all else off
                    ldy       #FT_OMIT            Don't change $FFC1
                    lda       #$01                Path #1
                    ldb       #SS.DScrn           Display Screen with new settings 
                    os9       I$SetStt            
                    lbcs      bmperror

*                   **** Unlink CLUT
                    lbsr      unlinkclut

*                   **** Deallocate Bitmap memory
                    ldy       #$0                 Bitmap 0
                    lda       #$1                 Path #1
                    ldb       #SS.FScrn           Free Screen Ram
                    os9       I$SetStt
                    lbcs      bmperror
                    clrb
                    puls      x,y,u,b,a,pc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clut Load
; extry:  x is address of file path/name
; Loads CLUT from file or link
clutload
*                   **** Try to link CLUT data module
*                   **** If Link fails, then Load the module from default chx
                    pshs      a,b,x,y,u
                    lda       #0                  F$Load a=langauge, 0=any
                    os9       F$Link              Try linking module
                    beq       cont@               Load CLUT if no error, if error, try load
                    os9       F$Load              Load and set Y=entry point of module
                    lbcs      err@
cont@               stu       <clutheader         save module ptr (unlinked later in GOff)
                    sty       <clutdata
*                   **** Define palette CLUT#2 with data at Y
                    ldx       #$0                 CLUT #0
                    lda       #$1                 Path #1
                    ldb       #SS.DfPal           Define Palette
                    os9       I$SetStt
err@                puls      a,b,x,y,u,pc        return (do NOT fall into unlinkclut)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Unlink Clut
; extry:  none
; unlink the current clut module from memory
unlinkclut          pshs      u
                    ldu       <clutheader
                    os9       F$Unlink
                    puls      u,pc


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Open Pixmap
; entry:  x is address of file path/name
; This loads the image from the file into bitmap 0
pixmapload          pshs      a,u
                    lda       #READ.
                    os9       I$Open
                    lbcs      loaderror
                    sta       <currPath
                    lda       #$36                First BMBlock for Bitmap 0
                    sta       <bmblock
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
                    lbra      loaderror
noerr@              stu       <mapaddr
                    puls      u

                    lda       <currPath
                    ldx       <mapaddr
                    ldy       #$2000
                    os9       I$Read
                    bcc       noerr@
                    cmpb      #E$EOF
                    beq       loaddone
                    lbra      loaderror
noerr@              inc       <blkCnt

                    pshs      u
                    ldu       <mapaddr
                    ldb       #1
                    os9       F$ClrBlk
                    puls      u
                    
                    lda       <blkCnt
                    cmpa      #$0A
                    beq       loaddone
                    inc       <currBlk+1
                    bra       loadimage

loaddone            lda       <currPath
                    os9       I$Close
loaderror           puls      a,u,pc
bmperror            os9       F$Exit

********************************************************************
* INKEY routine from alib
*
INKEY          clra                           std in
               ldb       #SS.Ready
               os9       I$GetStt             see if key ready
               bcc       getit
               cmpb      #E$NotRdy            no keys ready=no error
               bne       exit@                other error, report it
               clra                           no error
               bra       exit@
getit          lbsr      FGETC                go get the key
               tsta
exit@          rts

FGETC          pshs      a,x,y
               ldy       #1                   number of char to print
               tfr       s,x                  point x at 1 char buffer
               os9       I$Read
               puls      a,x,y,pc


PIXMAPSFX           fcc       "pixmap"
PIXMAPLEN           equ       *-PIXMAPSFX
CLUTSFX             fcc       "clut"
CLUTLEN             equ       *-CLUTSFX

* usage / help text - each line is $0D-terminated so I$WritLn emits one row
UsageMsg            fcc       "Pixview -h for help"
                    fcb       C$CR
Help1               fcc       "Pixview -h for help"
                    fcb       C$CR
Help2               fcc       "Pixview /dd/sys/backgrounds/pixmapbeach"
                    fcb       C$CR
Help3               fcc       "Pixview -on filename"
                    fcb       C$CR
Help4               fcc       "Pixview -off"
                    fcb       C$CR

PRESSSP             fcc       "Press space to continue"
                    fcb       C$CR
PRESSSPLEN          equ       *-PRESSSP
                    emod
eom                 equ       *
                    end

