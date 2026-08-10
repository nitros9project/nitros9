********************************************************************
* 
* 
* 
* 
* 
* File Manager - by Matt Massie
* Includes Work by: John Federico scfg
*
* 
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* started  2025/07/26 - 2026/07/12
* ------------------------------------------------------------------
*  1    2026/07/20
*  Initial version. File Manager - supports 2 directories depth, 255 files per folder.
*  Quick access to edit files with TE, Hex Editor, Run Basic09 Programs, Run select commands
*  or retreive help for commands, view raw pixmap files, play music files (.rsd, .mus, .lyr, .ume),
*  open .bmp files with view, preview fonts with scfg, Run BF files.
*  Standard copy, paste, rename, del, get file attributes.

                    nam       fm
                    ttl       NitrOS-9 Wildbits file manager


                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1
  

                    org       0
SHIFTBIT            equ       %00000001
LEFTBIT             equ       %00100000 
CNTLBIT             equ       %00000010  SS.KySns bit: Ctrl held
oldbg	            rmb       1         callers bg
oldfg	            rmb 	  1         calllers fg
runstop             rmb       1         run or stop flag
opensave            rmb       1         open or save flag
usepipe             rmb       1         use pipe option
filedir             rmb       1         file or dir 0=file 1=dir
i                   rmb       1         variable i
j                   rmb       1         variable j
k                   rmb       1         variable k
key                 rmb       1         key pressed
dirlevel            rmb       1         directory level
x                   rmb       2         mouse x
y                   rmb       2         mouse y
btn                 rmb       1         mouse btn
selx                rmb       1         selx
fdbuf2              rmb       32        file descriptor buffer
fpath2              rmb       1         filepath
curx                rmb       1         cursor x pos scrn
curxbf              rmb       1         cursor buffer pos
curcolcnt           rmb       1         cursor color adavance counter
curcol              rmb       1         cursor color
curcnt              rmb       1         keyloop count of cursor
curbuf              rmb       1         curbuf
errflg              rmb       1         error flag invalid filename           
attr                rmb       1         attr val
FileType            rmb       1
folder              rmb       29        folder str
prevfolder          rmb       29        prev folder
fname               rmb       29        filename
finalpath           rmb       62        filepath 29 file + 29 folder + 4 drive
finallen            rmb       1         finalpath len
pipepath            rmb       1         path for pipe
ssize               rmb       1         screen size
ytemp               rmb       2         mouse y temp
mtemp               rmb       2         max list cnt temp
menu                rmb       1         menu 0=listbox 1=open 2=close 3=drivelist
driveidx            rmb       1         drive index
listlen             equ       70        max length of listbox
LISTMAXROWS         equ       48        max visible rows in list window (y=4 to y=51, border at y=52)
MAXFILES            equ       255       max files loaded: numfonts/listitem are bytes (255 = index limit),
*                                       and 255 * 31 bytes/entry = 7905 fits fntarray (8000)
dirpath             rmb       1
dent                rmb	      DIR.SZ    DIR.SZ defined in rbf.d as 29+3=32
numfonts            rmb	      1         total number of font names loaded
listitem            rmb       1         current item selected
liststart           rmb	      1	        index for top of list
liststartmax        rmb	      1
listmax	            rmb    	  1	        max # of items displayed
listloop            rmb       1         dir window list loop value
valtoascii          rmb       1
canc                rmb       1
bufcur              rmb       2
bufstrt             rmb       2
dclick              rmb       1         double-click: last clicked item ($FF=none pending)
dclicktmr           rmb       1         double-click countdown timer (0=expired)
popts	            rmb       32
fntarray            rmb       8000      6400      3720      array of directory, max 120 of 29+2 len each
drawbuf	            rmb	      1024
oldchars            rmb    	  104
attrbuf             rmb       32
clipboard           rmb       100       copied selected file path (no trailing $0D)
cliplen             rmb       1         length of clipboard contents (0=empty)
savedint            rmb       1         saved keyboard interrupt char (Ctrl-C) for restore
pastebuf            rmb       200       fork parameter buffer: "source dest"+CR
pastelen            rmb       1         length of pastebuf
savedqut            rmb       1         saved keyboard quit char (Ctrl-E) for restore
delok               rmb       1         delete-confirm flag (1 = user typed YES)
newname             rmb       30        typed new filename for rename
newnamelen          rmb       1         length of newname
fnstart             rmb       2         filename-start pointer within finalpath
gfxset              rmb       1         screen settings
                    rmb       250       stack space
size                equ       .

                    mod       eom,name,tylg,atrv,start,size

name                fcs       /fm/
                    fcb       edition

FG                  set       $01         foreground color
BG                  set       $06         background color
TXT                 set       $01         text fg
TXTBG               set       $00         text bg
TXTSEL              set       $07         selected text fg
TXTSELBG            set       $02         selected text bg
TLBC                set       $F2         D5         top left border char
TRBC                set       $F3         B8         top right border char
TTLC                set       $F4         top title left char
TTRC                set       $F5         top title right char
TBL                 set       $F6         top border line
SBL                 set       $F7         side border line
BLBC                set       $F8         bottom left border char
BRBC                set       $F9         bottom right border char
SLD                 set       $FA         solid character
UPAR                set       $FD         up arrow
DNAR                set       $FE         down arrow
LFAR                set       $FC         left arrow
RTAR                set       $FB         right arrow

FILETYPE_PLAY       equ       1
FILETYPE_TE         equ       2
FILETYPE_VIEW       equ       3
FILETYPE_SCFG       equ       4
FILETYPE_CMD        equ       5
FILETYPE_PIX        equ       6
FILETYPE_BF         equ       7
FILETYPE_HELP       equ       8
MAXDRIVELEVEL       equ       2            max supported directory depth
DCLICK_TIMEOUT      equ       30           double-click window in keyloop ticks

start               lbsr      getscrnsz    get screen size
                    pshs      x,y,u,cc     push params                      
                    clr       <i
                    clr       <j
                    clr       <k
                    clr       <key
                    clr       <dirlevel    directory level
                    clr       <x
                    clr       <x+1
                    clr       <y
                    clr       <y+1
                    clr       <ytemp
                    clr       <ytemp+1
                    clr       <mtemp
                    clr       <mtemp+1
                    clr       <btn
                    clr       <selx
                    clr       <usepipe
                    lda       #5           text edit start x pos
                    sta       <curx        cursor pos x
                    clr       <curxbf      cursor buffer pos
                    clr       <curcol      cursor color
                    clr       <curcolcnt
                    clr       <curcnt      cursor loop cnt
                    clr       <curbuf      cursor buffer
                    clr       <errflg
                    clr       <listmax
                    clr       <numfonts
                    clr    	  <listitem	   init list item = 0
                    clr       <liststart   init list start = 0
                    clr       <listloop
                    clr       <attr
                    clr       <canc
                    lda       #$FF
                    sta       <dclick      no click pending
                    clr       <dclicktmr   timer not running
                    clra
                    sta       <driveidx
                    sta       <menu        menu 0
                    sta       <valtoascii
                    lda       #16
                    sta       <selx
                    clr       <bufstrt
                    clr       <bufstrt+1
                    clr       <finallen
                    lda       #$20
                    ldb       #62
clrfinalpath        leax      finalpath,u
                    sta       ,x+
                    decb
                    bne       clrfinalpath
                    lda       #$20
                    ldb       #29
                    leax      fname,u
clrfname            sta       ,x+
                    decb      
                    bne       clrfname
                    lda       #$20
                    ldb       #29
                    leax      folder,u
clrfolder           sta       ,x+
                    decb      
                    bne       clrfolder
                    lda       #$20
                    ldb       #29
                    leax      prevfolder,u
clrfolder2          sta       ,x+
                    decb      
                    bne       clrfolder2
                    lda       #1            run mode
                    sta       <runstop      0=stop 1=run
                    clr       <opensave     0=open 1=save
                    clr       <finallen
                    clr       cliplen,u     clipboard empty
                    puls      x,y,u,cc      restore params
                    lbsr      parseparams
;fontl               lbsr      FNLoad       load font
                    lbsr      getscreen     get gfx settings/switch to txt
                    lbsr      drawscreen    draw the whole screen
                    lbra      afterdraw     continue startup (skip drawscreen body)
drawscreen          lda       #$01                 
                    leax      ScrnInit,pcr  screen init  
                    ldy       #ScrnInitLen
                    os9       I$Write
                    lda       #0            re-home cursor to a safe draw origin
                    ldb       #0            (basic09 may leave it scrolled/shifted)
                    lbsr      CurXY
                    lbsr	 installchars	
** draw screen
                    leas      -1,s          reserve 1 byte for stack
                    lda       #TLBC
                    sta       ,s
                    lda       #$01          stdout
                    ldy       #1            number of characters to print
                    tfr       s,x
                    os9       I$Write
                    leas      1,s           return stack to normal
                    leax      TopLine,pcr
                    ldy       #TopLineLen
                    os9       I$Write
                    leax      Title,pcr
                    ldy       #TitleLen
                    os9       I$Write
                    leax      TopLine,pcr
                    ldy       #TopLineLen
                    os9       I$Write
                    leas      -1,s          reserve 1 byte for stack
                    lda       #TRBC
                    sta       ,s
                    lda       #$01          stdout
                    ldy       #1            number of characters to print
                    tfr       s,x
                    os9       I$Write       end top title and border
                    leas      1,s           return stack to normal
                    lda       #1            start border on line 1
                    sta       <k  
                    lda       #57           # vertical lines to draw
                    sta       <i            store in i
loop@               clra                    x=0
                    ldb       <k            y=1
                    lbsr      CurXY
                    lbsr      SideBorderL
                    lda       #79           x=79
                    ldb       <k            y=1
                    lbsr      CurXY
                    lbsr      SideBorderR
                    inc       <k
                    dec       <i
                    bne       loop@         side border end
                    lda       #1            x=1
                    ldb       #54           y=54
                    lbsr      CurXY
                    lda       <opensave
                    cmpa      #0
                    bne       ffile
                    leax      Selected,pcr
                    ldy       #SelectedLen
                    bra       next2@
ffile               leax      SFilename,pcr
                    ldy       #SFileLen
next2@              lda       #1            stdout
                    os9       I$Write
                    leax      Line12,pcr
                    ldy       #Line12Len
                    os9       I$Write
                    leax      AttrLn,pcr
                    ldy       #AttrLnLen
                    os9       I$Write
                    leax      TopLine,pcr
                    ldy       #TopLineLen
                    os9       I$Write
                    leax      Line3,pcr
                    ldy       #Line3Len
                    os9       I$Write       selected attr title bar end
                    lda       #0            x=0
                    ldb       #58           y=58
                    lbsr      CurXY
                    leas      -1,s          reserve 1 byte for stack
                    lda       #BLBC
                    sta       ,s
                    lda       #$01          stdout
                    ldy       #1            number of characters to print
                    tfr       s,x
                    os9       I$Write
                    leas      1,s           return stack to normal
                    lda       #1            stdout
                    leax      TopLine,pcr
                    ldy       #TopLineLen
                    os9       I$Write
                    leax      TopLine,pcr
                    ldy       #TopLineLen
                    os9       I$Write
                    leax      Line12,pcr
                    ldy       #Line12Len
                    os9       I$Write
                    leax      Line4,pcr
                    ldy       #Line4Len
                    os9       I$Write
                    leas      -1,s          reserve 1 byte for stack
                    lda       #BRBC
                    sta       ,s
                    lda       #$01          stdout
                    ldy       #1            number of characters to print
                    tfr       s,x
                    os9       I$Write
                    leas      1,s           return stack to normal
** draw buttons
                    lda       #57
                    ldb       #56
                    lbsr      CurXY
                    lda       #TXT
                    ldb       #TXTBG
                    lbsr      Color
                    lda       <opensave
                    cmpa      #0
                    bne       fsave
                    leax      OpenLn,pcr
                    ldy       #OpenLnLen
                    bra       next@
fsave               leax      SaveLn,pcr
                    ldy       #SaveLnLen
next@               lda       #1            stdout
                    os9       I$Write
                    lda       #68
                    ldb       #56
                    lbsr      CurXY
                    lda       #1            stdout
                    leax      CancelLn,pcr
                    ldy       #CancelLnLen
                    os9       I$Write
                    lda       <opensave
                    beq       nextdl@
                    lda       #3
                    ldb       #56
                    lbsr      CurXY
                    lda       #RTAR
                    lbsr      byte1scrn
** drive list
nextdl@             lda       #2
                    ldb       #2
                    lbsr      CurXY
                    lda       #1            stdout
                    leax      DriveLn,pcr
                    ldy       #DriveLnLen
                    os9       I$Write
                    lda       #16
                    ldb       #2
                    lbsr      CurXY
                    lda       #1            stdout
                    leax      DrvLst,pcr
                    ldy       #DrvLstLen
                    os9       I$Write
** directory
                    lbsr      ldfontarr
                    lda	      <numfonts
                    lbsr      drawbox
                    lbsr      showhelp
** display dir
                    lbsr	  writelist		write the list of files
                    rts                     end of drawscreen
afterdraw           lbsr	  getopts		get current terminal options
                    lbsr	  keyechooff    turn off key echo
                    lbsr      breakoff      disable Ctrl-C so it can be used to copy

** Keyloop - Main Loop
keyloop             ldb       <runstop      check run stop flag
                    cmpb      #1
                    lbne      scrnrtn
opsave              lda       <opensave
                    cmpa      #1
                    bne       kb
                    lbsr      lineedit      handle filesave
                    inc       <curcolcnt
                    lda       <curcolcnt
                    cmpa      #8
                    bne       curcont
                    inc       <curcol
                    clr       <curcolcnt
                    lda       <curcol
                    cmpa      #16
                    bne       curcont
                    clr       <curcol
curcont             inc       <curcnt
                    lda       <curcnt
                    cmpa      #128
                    blo       kb
                    lbsr      handlecursor
                    cmpa      #192
                    bhi       kb
                    lbsr      handlecursor
kb                  lda       <dclicktmr    double-click timer running?
                    beq       nodclick@     zero = not running, skip
                    deca
                    sta       <dclicktmr
                    bne       nodclick@     still counting down
                    lda       #$FF          timer expired - cancel pending click
                    sta       <dclick
nodclick@           lbsr      handlemouse
                    lbsr      handlekeyboard
                    lda       <key
                    ldb       <menu
                    cmpb      #3            menu level 3
                    bne       nextmenu
                    cmpa	  #13			$0D=ok shift+$0d=cancel
                    bne       nextmenu
                    lda       #1            set cancel flag
                    sta       <canc
                    lda	      #0			Else check for the shift key
	                ldb	      #SS.KySns
	                os9       I$GetStt
	                bita      #SHIFTBIT
	                lbne 	  scrnrtn	    If shiftbit=1,then cancel and quit
                    lda       #0            clr cancel flag
                    sta       <canc		
                    lbra      driveselect   enter pressed                   
nextmenu            ldb       <menu
                    cmpb      #3
                    blo       menukeys
                    bra       nextkey
menukeys            lda       <key
                    cmpa	  #13			$0D=ok shift+$0d=cancel
                    bne       nextkey
                    lda       #1            set cancel flag
                    sta       <canc
                    lda	      #0			Else check for the shift key
	                ldb	      #SS.KySns
	                os9       I$GetStt
	                bita      #SHIFTBIT
	                lbne 	  scrnrtn	    If shiftbit=1,then cancel and quit
                    ldb       <menu
                    cmpb      #2            menu 2 cancel
                    beq       menuopsv
                    lda       #0
                    sta       <canc
menuopsv            lda       <opensave
                    bne       savebtn
                    lbsr      getattr
                    lda       <attr         get file attributes
                    cmpa      #$BF          is it directory?
                    bne       savebtn        not a dir: open file and exit
* double-click path (msidxitm): reset the
* double-click state and clear the activating Enter before entering
* the folder, so nothing re-fires on item 0 in the new view
                    lda       #$FF
                    sta       <dclick
                    clr       <dclicktmr
                    clr       <key
                    lbra      changedir
savebtn             lbra      scrnrtn		enter pressed
nextkey             ldb       <menu
                    cmpb      #4            handle list box menu 4
                    bne       nextkey2
                    lda       <key
                    cmpa	  #13			$0D=ok shift+$0d=cancel
                    bne       nextkey2
                    lda       #1
                    sta       <canc
                    lda	      #0			Else check for the shift key
	                ldb	      #SS.KySns
	                os9       I$GetStt
	                bita      #SHIFTBIT
	                bne 	  scrnrtn	    If shiftbit=1,then cancel and quit
                    lda       #0
                    sta       <canc
                    lbsr      getattr
                    lda       <attr         get file attributes
                    clr       <key
                    cmpa      #$BF          is it directory?
                    lbeq       changedir    handle dir change
	                lbra	  keyloop       user should be providing filename not selecting a file - enter pressed
nextkey2            ldb       <opensave
                    cmpb      #1            if save option no option keys
                    lbeq      keyloop       
                    lda       <key
                    cmpa      #$43          'C' copy selected path to clipboard
                    lbeq      copyclipkey
                    cmpa      #$63          'c' copy selected path to clipboard
                    lbeq      copyclipkey
                    cmpa      #$03          Ctrl-C copy selected path to clipboard
                    lbeq      copyclipkey
                    cmpa      #$16          Ctrl-V paste copied file to current folder
                    lbeq      pasteclipkey
                    cmpa      #$12          Ctrl-R run selected Basic09 program
                    lbeq      runb09key
                    cmpa      #$05          Ctrl-E open selected file in text editor
                    lbeq      runtekey
                    cmpa      #$18          Ctrl-X open selected file in hex editor
                    lbeq      runhexkey
                    cmpa      #$04          Ctrl-D delete selected file (confirm YES)
                    lbeq      rundelkey
                    cmpa      #$0E          Ctrl-N rename selected file (copy + del)
                    lbeq      renamekey
                    cmpa      #$01          Ctrl-A get selected file attribute
                    lbeq      runattrkey
                    cmpa      #$61
                    lbeq      gogetattr
					cmpa      #$06          Ctrl-F make a new directory
                    lbeq      makdirkey
                    cmpa      #$11          Ctrl-Q quit
                    lbne      keyloop
                    lda       #1            Ctrl-Q = quit: flag cancel so the exit path
                    sta       <canc         skips the file-type handler dispatch

*****************************************************************************
scrnrtn             lbsr	  keyechoon
                    lbsr      breakon       restore Ctrl-C before exit
                    lbsr	  cursoron
                    lbsr	  restorchars   restore original font so the handler/shell renders
                    lda	      <oldfg
	                ldb	      <oldbg
                    lbsr      Color
                    lda       #$0C
                    lbsr      byte1scrn
                    lbsr      handleoutput
                    lbsr      CheckType     check filetype
                    lda       #$01                 
                    leax      ScrnExit,pcr  screen exit  
                    ldy       #ScrnExitLen
                    os9       I$Write
                    lbsr      outputfinal
                    lda       <usepipe
                    beq       CPlay         Exit
                    lbra      dopipe
                    bra       Exit
CPlay               lda       <canc         cancel/quit -> exit, do not open a handler
                    lbne      Exit
                    lda       <FileType
                    lbeq      Exit
                    cmpa      #1
                    bne       Edit
                    lbsr      DoPlay
                    lbra      Exit
Edit                cmpa      #2
                    bne       View
                    lbsr      DoTE
                    lbra      Exit
View                cmpa      #3
                    bne       Fonts
                    lbsr      DoView
                    lbra      Exit
Fonts               cmpa      #4
                    bne       Command
                    lbsr      DoSCFG
                    lbra      Exit
Command             cmpa      #5
                    bne       PixV
                    lbsr      DoCMD
                    bra       Exit
PixV                cmpa      #6
                    bne       bf
* ---- restore normal screen colors, then clear, before launching pixview ----
                    lda       #FG
                    ldb       #BG
                    lbsr      Color
                    lda       #$0C
                    lbsr      byte1scrn
                    lbsr      DoPixV        fork /dd/cmds/pixview + wait
                    lbsr      rnredraw      redraw + restore fm terminal mode
                    lda       #$01          text only on exit from fm
                    sta       >gfxset
                    lbra      keyloop       image viewed -> back to the file manager
bf                  cmpa      #7
                    bne       hlp
                    lbsr      DoBF
                    bra       Exit
hlp                 cmpa      #8
                    bne       Exit
                    lbsr      DoHelp2
Exit                lda       <FileType
                    cmpa      #3             do not reset screen if using view bmp
                    beq       Ex@
                    lbsr      setscreen
Ex@                 clrb
                    os9       F$EXit

gogetattr           lbsr      getattr
                    lbra      keyloop

updir               lda       <dirlevel
                    beq       cont@         if root dir skip
                    lda       #0            index item 0 is ..
                    sta       <listitem
                    lbsr      arrayidx
                    leax	  2,x           advance past 2 byte string len
                    ldb       #29
                    leay      folder,u
fldloop@            lda       ,x+           copy current list item to folder
                    sta       ,y+
                    decb
                    bne       fldloop@
                    lda       <dirlevel
                    cmpa      #1
                    bhi       next@
                    bra       clrlist@
next@               leax      folder,u      point to item
                    lda       ,x+
                    cmpa      #$2E          . check for ..
                    bne       clrlist@
                    lda       ,x+
                    cmpa      #$2E          .
                    bne       clrlist@
clrlist@            dec       <dirlevel
                    pshs      a,b,x,y,u
                    clr       <listmax
                    clr       <numfonts
                    clr    	  <listitem		init list item = 0
                    clr       <liststart	init list start = 0
                    clr       <listloop
                    lda       #$FF          reset double-click state
                    sta       <dclick
                    clr       <dclicktmr
                    lbsr      ldfontarr
                    lbsr      writelist
                    puls      a,b,x,y,u
                    lda       <dirlevel
                    cmpa      #1            was dirlevel 2?
                    bne       cont@
                    ldb       #29           folder name = ..
                    leax      prevfolder,u  restore previous folder to current folder
                    leay      folder,u
prevfldloop2@       lda       ,x+
                    sta       ,y+
                    decb
                    bne       prevfldloop2@
cont@               rts

changedir           inc       <dirlevel
                    lda       <listitem     get the current list item
                    lbsr	  arrayidx
                    leax	  2,x           advance past 2 byte string len
                    ldb       #29
                    leay      folder,u
fldloop             lda       ,x+           copy current list item to folder
                    sta       ,y+
                    decb
                    bne       fldloop
                    lda       <dirlevel
                    cmpa      #1
                    bhi       next@
                    ldb       #29
                    leax      folder,u
                    leay      prevfolder,u
prevfldloop         lda       ,x+
                    sta       ,y+
                    decb
                    bne       prevfldloop
next@               leax      folder,u      point to item
                    lda       ,x+
                    cmpa      #$2E          .
                    bne       clrlist
                    lda       ,x+
                    cmpa      #$2E          .
                    bne       clrlist
                    dec       <dirlevel
                    dec       <dirlevel
clrlist             pshs      a,b,x,y,u
                    clr       <listmax
                    clr       <numfonts
                    clr    	  <listitem		init list item = 0
                    clr       <liststart	init list start = 0
                    clr       <listloop
                    lda       #$FF          reset double-click state
                    sta       <dclick
                    clr       <dclicktmr
                    lbsr      ldfontarr
                    lbsr      writelist
                    puls      a,b,x,y,u
                    lda       <dirlevel
                    cmpa      #1            was dirlevel 2?
                    bne       cont@         
                    ldb       #29           the folder name = ..
                    leax      prevfolder,u  restore previous folder to current folder
                    leay      folder,u
prevfldloop2@       lda       ,x+
                    sta       ,y+
                    decb
                    bne       prevfldloop2@
cont@               lbra      nextkey

********************************************************************
* handle output - Open - Save - Cancel on Exit
handleoutput        lda      <canc
                    lbne     cancelmenu2
                    ldb      <dirlevel        check directory level
                    cmpb     #0
                    bne      pathwfolder      need path with folder
                    lbsr     drivenmwrite2     
                    lbsr     filenmwrite2     
                    lbsr     outputfinal
done@               rts 

pathwfolder         lbsr     drivenmwrite2    
                    ldb      <dirlevel
                    cmpb     #MAXDRIVELEVEL
                    bne      folder@
                    lbsr     prevfldnmwrite2
folder@             lbsr     foldernmwrite2   
                    lbsr     filenmwrite2     
                    lbsr     outputfinal
                    rts
                    
filenmwrite         lda      <opensave
                    bne      hsave@
                    lda      <listitem         get selected file item
                    lbsr	 arrayidx
                    leax	 2,x               advance past 2 byte string len
                    bra      hopen@
hsave@              leax     fname,u           output typed filename
hopen@              ldy      #29
                    lda      #$01
                    os9      I$Write
                    rts

filenmwrite2        lda      <opensave
                    bne      hsave@
                    lda      <listitem         get selected file item
                    lbsr	 arrayidx
                    leax	 2,x               advance past 2 byte string len
                    bra      hopen@
hsave@              leax     fname,u           output typed filename
hopen@              lda      <finallen
                    leay     finalpath,u
                    leay     a,y               current path pos
                    ldb      #29               max cnt
fnloop@             lda      ,x+
                    cmpa     #$20
                    beq      done@
                    sta      ,y+
                    lda      <finallen
                    inca
                    sta      <finallen         inc len
                    decb
                    bne      fnloop@
done@               lda      #$0D              add $0D to end of path name
                    sta      ,y+
                    inc      <finallen
                    rts

foldernmwrite       clrb                       count chars till space
                    ldy      #29               max bytes
                    leax     folder,u
loop@               lda      ,x+
                    cmpa     #$20
                    beq      next@
                    incb                       inc byte count
                    leay     -1,y
                    bne      loop@
next@               clra
                    tfr      d,y               bytes to write
                    ;ldy      #29
                    lda      #1
                    leax     folder,u
                    os9      I$Write
                    lda      #$2F        /
                    lbsr     byte1scrn
                    rts

foldernmwrite2      clrb                       count chars till space
                    ldy      #29               max bytes
                    leax     folder,u
loop@               lda      ,x+
                    cmpa     #$20
                    beq      next@
                    incb                       inc byte count
                    leay     -1,y
                    bne      loop@
next@               pshs     b                 save cnt
                    leax     folder,u
                    ldb      <finallen
                    leay     finalpath,u
                    leay     b,y               add offset
                    puls     b                 restore byte count
fdloop@             lda      ,x+
                    sta      ,y+
                    lda      <finallen
                    inca
                    sta      <finallen         inc len
                    decb
                    bne      fdloop@
                    lda      #$2F              /
                    sta      ,y+
                    lda      <finallen
                    inca
                    sta      <finallen         inc len
                    rts


prevfldnmwrite      clrb                       count chars till space
                    ldy      #29               max bytes
                    leax     prevfolder,u
loop@               lda      ,x+
                    cmpa     #$20
                    beq      next@
                    incb                       inc byte count
                    leay     -1,y
                    bne      loop@
next@               clra
                    tfr      d,y               bytes to write
                    ;ldy      #29
                    lda      #1
                    leax     prevfolder,u
                    os9      I$Write
                    lda       #$2F        /
                    lbsr      byte1scrn
                    rts

prevfldnmwrite2     clrb                       count chars till space
                    ldy      #29               max bytes
                    leax     prevfolder,u
loop@               lda      ,x+
                    cmpa     #$20
                    beq      next@
                    incb                       inc byte count
                    leay     -1,y
                    bne      loop@
next@               pshs     b                 save cnt
                    leax     prevfolder,u
                    ldb      <finallen
                    leay     finalpath,u
                    leay     b,y               add offset
                    puls     b                 restore cnt
pvfdloop@           lda      ,x+
                    sta      ,y+
                    lda      <finallen
                    inca
                    sta      <finallen         inc len
                    decb
                    bne      pvfdloop@
                    lda      #$2F              /
                    sta      ,y+
                    lda      <finallen
                    inca
                    sta      <finallen         inc len
                    rts


drivenmwrite        lda       <selx
                    cmpa      #16
                    bne       next@
                    ldb       #0
                    stb       <driveidx
                    leax	  drive0,pcr
                    bra       done@
next@               cmpa      #20
                    bne       next2@
                    ldb       #1
                    stb       <driveidx
                    leax	  drive1,pcr
                    bra       done@
next2@              cmpa      #24
                    bne       next3@
                    ldb       #2
                    stb       <driveidx
                    leax	  drive2,pcr
                    bra       done@
next3@              cmpa      #28
                    bne       next4@
                    ldb       #3
                    stb       <driveidx
                    leax	  drive3,pcr
                    bra       done@
next4@              cmpa      #32
                    bne       next5@
                    ldb       #4
                    stb       <driveidx
                    leax	  drive4,pcr
                    bra       done@
next5@              cmpa      #36
                    bne       next6@
                    ldb       #5
                    stb       <driveidx
                    leax	  drive5,pcr
                    bra       done@
next6@              cmpa      #40
                    bne       done@
                    ldb       #6
                    stb       <driveidx
                    leax      drive6,pcr
done@               ldy       #3
                    lda       #$01
                    os9       I$Write
                    lda       #$2F          /
                    lbsr      byte1scrn
                    rts

drivenmwrite2       lda       <selx
                    cmpa      #16
                    bne       next@
                    ldb       #0
                    stb       <driveidx
                    leax	  drive0,pcr
                    bra       done@
next@               cmpa      #20
                    bne       next2@
                    ldb       #1
                    stb       <driveidx
                    leax	  drive1,pcr
                    bra       done@
next2@              cmpa      #24
                    bne       next3@
                    ldb       #2
                    stb       <driveidx
                    leax	  drive2,pcr
                    bra       done@
next3@              cmpa      #28
                    bne       next4@
                    ldb       #3
                    stb       <driveidx
                    leax	  drive3,pcr
                    bra       done@
next4@              cmpa      #32
                    bne       next5@
                    ldb       #4
                    stb       <driveidx
                    leax	  drive4,pcr
                    bra       done@
next5@              cmpa      #36
                    bne       next6@
                    ldb       #5
                    stb       <driveidx
                    leax	  drive5,pcr
                    bra       done@
next6@              cmpa      #40
                    bne       next7@
                    ldb       #6
                    stb       <driveidx
                    leax      drive6,pcr
                    bra       done@
next7@              cmpa      #44
                    bne       next8@
                    ldb       #7
                    stb       <driveidx
                    leax      drive7,pcr
                    bra       done@
next8@              cmpa      #48
                    bne       done@
                    ldb       #8
                    stb       <driveidx
                    leax      drive8,pcr
done@               leay      finalpath,u       
                    ldb       #3            3 bytes for drive
dloop@              lda       ,x+
                    sta       ,y+
                    decb
                    bne       dloop@   
                    lda       #$2F          / after drive path
                    sta       ,y+
                    lda       #4            final path len 
                    sta       <finallen
                    rts


cancelmenu          leax	  CancelHlp,pcr
                    ldy       #CancelHlpLen
                    lda       #$01
                    os9       I$Write
                    rts

cancelmenu2         leax	  CancelHlp,pcr
                    ldb       #CancelHlpLen
                    stb       <finallen
                    leay      finalpath,u
cloop@              lda       ,x+
                    sta       ,y+
                    decb
                    bne       cloop@
                    lbsr      outputfinal          
                    rts

outputfinal         leax      finalpath,u
                    clra
                    ldb       <finallen
                    tfr       d,y
                    lda       #1
                    os9       I$WritLn
                    rts

********************************************************************
* copyclipkey - entry from keyloop when 'C'/'c' pressed (open mode)
*
copyclipkey         lbsr      copytoclip
                    lbra      keyloop

********************************************************************
* copytoclip
* Build the currently-selected file's full path (drive + folder(s)
* + file) into finalpath using the SAME routines handleoutput uses,
* copy it (without the trailing $0D) into the 100-byte clipboard
* buffer, then restore finallen=0 so a later real open is unaffected.
* Only called in open mode (opensave=0), so filenmwrite2 uses the
* selected list item. Then display it.
*
copytoclip          pshs      a,b,x,y
                    lda       #$20               clear clipboard to spaces first
                    ldb       #100
                    leax      clipboard,u
ccloop@             sta       ,x+
                    decb
                    bne       ccloop@
* blank the clipboard display field: set screen colors then write 41 spaces
* at x=37,y=49 before drawing the new path, so a shorter path can't leave
* old characters behind
                    lda       #FG                normal screen colors
                    ldb       #BG
                    lbsr      Color
                    lda       #37
                    ldb       #48
                    lbsr      CurXY
                    leax      clipboard,u        buffer is all spaces now
                    ldy       #41                fixed field width
                    lda       #$01               stdout
                    os9       I$Write
                    clr       <finallen          build from scratch
                    ldb       <dirlevel
                    bne       cpwfolder@
* root level: drive + file
                    lbsr      drivenmwrite2
                    lbsr      filenmwrite2
                    bra       cpcopy@
* inside folder(s): drive + (prevfolder if deepest) + folder + file
cpwfolder@          lbsr      drivenmwrite2
                    ldb       <dirlevel
                    cmpb      #MAXDRIVELEVEL
                    bne       cpfolder@
                    lbsr      prevfldnmwrite2
cpfolder@           lbsr      foldernmwrite2
                    lbsr      filenmwrite2
* finalpath now holds the path plus a trailing $0D; finallen counts it
cpcopy@             lda       <finallen
                    beq       cpempty@           nothing built
                    deca                         drop the trailing $0D
                    beq       cpempty@           path was empty
                    cmpa      #99                clamp to clipboard capacity-1
                    bls       cpsave@
                    lda       #99
cpsave@             sta       cliplen,u
                    tfr       a,b                b = byte count
                    leax      finalpath,u
                    leay      clipboard,u
cpcloop@            lda       ,x+
                    sta       ,y+
                    decb
                    bne       cpcloop@
                    bra       cprestore@
cpempty@            clr       cliplen,u          clipboard empty
cprestore@          clr       <finallen          restore pristine state for a real open
                    lbsr      showclip
                    puls      a,b,x,y,pc

********************************************************************
* showclip - display the clipboard contents at x=40,y=53
*
showclip            pshs      a,b,x,y
                    bsr       blnkerrmsg
                    lda       cliplen,u
                    beq       scdone@            nothing to show
                    bsr       blankclipt         blank text field
                    lda       #TXT               normal text colors
                    ldb       #TXTBG
                    lbsr      Color
                    lda       #38                cursor x
                    ldb       #45                cursor y
                    lbsr      CurXY
                    leax      clipboard,u
                    clra
                    ldb       cliplen,u
                    tfr       d,y                y = byte count
                    lda       #$01               stdout
                    os9       I$Write
scdone@             puls      a,b,x,y,pc

blankclipt          lda       #FG               normal text colors
                    ldb       #BG
                    lbsr      Color
                    lda       #38                cursor x
                    ldb       #45                cursor y
                    lbsr      CurXY
                    lda       #1              stdout
                    leax      BlankItem,pcr
                    ldy       #29
                    os9       I$Write
                    lda       #38                cursor x
                    ldb       #47                cursor y
                    lbsr      CurXY
                    rts

errormsgln          lda       #8                 cursor x
                    ldb       #52                cursor y
                    lbsr      CurXY
                    lda       #TXT               normal text colors
                    ldb       #TXTBG
                    lbsr      Color
                    rts

blnkerrmsg          lda       #FG               normal text colors
                    ldb       #BG
                    lbsr      Color
                    lda       #8                 cursor x
                    ldb       #52                cursor y
                    lbsr      CurXY
                    lda       #1              stdout
                    leax      BlankItem,pcr
                    ldy       #29
                    os9       I$Write
                    os9       I$Write
                    rts

********************************************************************
* pasteclipkey - entry from keyloop when Ctrl-V pressed (open mode)
*
pasteclipkey        lbsr      pastefile
                    lbra      keyloop

********************************************************************
* pastefile - copy the file whose full path is on the clipboard into
* the CURRENT folder, using the OS-9 copy command via F$Fork.
*   source      = clipboard (full path saved by Ctrl-C)
*   destination = current drive + folder(s) + the filename portion of
*                 the clipboard (everything after its last '/')
* Builds "source dest"+CR in pastebuf, forks /dd/cmds/copy, waits,
* then reloads the listing so the new file shows.
*
pastefile           pshs      a,b,x,y,u
                    lbsr      errormsgln
                    lda       cliplen,u          anything copied yet?
                    lbeq      pdone@
* ---- build destination (current drive + folder) into finalpath ----
                    clr       <finallen
                    ldb       <dirlevel
                    bne       pwfldr@
                    lbsr      drivenmwrite2
                    bra       pfname@
pwfldr@             lbsr      drivenmwrite2
                    ldb       <dirlevel
                    cmpb      #MAXDRIVELEVEL
                    bne       pfldr@
                    lbsr      prevfldnmwrite2
pfldr@              lbsr      foldernmwrite2
* ---- find filename in clipboard: position after the LAST '/' ----
pfname@             leax      clipboard,u        scan pointer
                    leay      clipboard,u        filename start (default: whole string)
                    ldb       cliplen,u
psc@                lda       ,x+
                    cmpa      #'/                $2F
                    bne       psk@
                    leay      ,x                 char just after this '/'
psk@                decb
                    bne       psc@
* X = clipboard+cliplen (end), Y = filename start
                    pshs      x                  save end pointer
                    leax      finalpath,u        dest = finalpath + finallen
                    clra
                    ldb       <finallen
                    leax      d,x
pcp@                cmpy      ,s                 reached end of clipboard?
                    beq       pcpe@
                    lda       ,y+
                    sta       ,x+
                    inc       <finallen
                    bra       pcp@
pcpe@               leas      2,s                drop saved end pointer
* ---- assemble fork parameter: SOURCE + ' ' + DEST + CR in pastebuf ----
                    leax      clipboard,u        source path
                    leay      pastebuf,u
                    ldb       cliplen,u
pbs@                lda       ,x+
                    sta       ,y+
                    decb
                    bne       pbs@
                    lda       #$20               space separator
                    sta       ,y+
                    leax      finalpath,u        destination path
                    ldb       <finallen
pbd@                lda       ,x+
                    sta       ,y+
                    decb
                    bne       pbd@
                    lda       #C$CR              terminate parameter line
                    sta       ,y+
                    lda       cliplen,u          pastelen = cliplen + 1 + finallen + 1
                    adda      <finallen
                    adda      #2
                    sta       pastelen,u
* ---- fork the copy command (like DoView) ----
                    clra
                    ldb       pastelen,u
                    tfr       d,y                Y = parameter length
                    leax      >COPYCMD,pcr       X = command path
                    leau      pastebuf,u         U = parameter pointer (clobbers data base)
                    ldd       #$0100
                    os9       F$Fork
                    bcs       pforked@           fork failed - skip wait
                    os9       F$Wait
pforked@            ldu       6,s                restore data base U (saved at entry)
                    clr       <finallen          restore pristine path state
* the previous load chdir'd INTO the current folder, so opendir's relative
* open of the folder name would now fail; step the data dir back to the
* parent first (opendir re-enters the folder). dirlevel 0 opens the drive
* absolutely, so no chdir is needed there.
                    lda       <dirlevel
                    beq       prefr@
                    leax      pdotdot,pcr
                    lda       #DIR.+READ.
                    os9       I$ChgDir
prefr@              clr       <listmax
                    clr       <numfonts
                    clr       <listitem
                    clr       <liststart
                    clr       <listloop
                    lda       #$FF
                    sta       <dclick
                    clr       <dclicktmr
                    lbsr      ldfontarr
                    lbsr      writelist
pdone@              puls      a,b,x,y,u,pc

********************************************************************
* runb09key - entry from keyloop when Ctrl-R pressed (open mode)
*
runb09key           lbsr      runb09
                    lbra      keyloop

********************************************************************
* runb09 - run the selected file as a Basic09 program via F$Fork:
*   basic09 <drive+folder+file> #15k
* Builds the selected item's full path (like copytoclip), appends
* " #15k", forks /dd/cmds/basic09 and waits. Screen is left as the
* program leaves it (no redraw). Restores finallen afterward.
*
runb09              pshs      a,b,x,y,u
* ---- build selected file path (drive + folder + file) into finalpath ----
                    clr       <finallen
                    ldb       <dirlevel
                    bne       rwfldr@
                    lbsr      drivenmwrite2
                    lbsr      filenmwrite2
                    bra       rparam@
rwfldr@             lbsr      drivenmwrite2
                    ldb       <dirlevel
                    cmpb      #MAXDRIVELEVEL
                    bne       rfldr@
                    lbsr      prevfldnmwrite2
rfldr@              lbsr      foldernmwrite2
                    lbsr      filenmwrite2
* ---- build "path #15k"+CR in pastebuf ----
* ---- build "path"+CR in pastebuf (the #15k is a memory request, not a
*      parameter: it is passed via the F$Fork B register below) ----
rparam@             lda       <finallen          path includes trailing $0D
                    lbeq      rdone@
                    deca                          A = path length (drop $0D)
                    pshs      a                  save path length
                    leax      finalpath,u
                    leay      pastebuf,u
                    ldb       ,s
rcp@                lda       ,x+
                    sta       ,y+
                    decb
                    bne       rcp@
                    lda       #C$CR              terminate parameter line
                    sta       ,y+
                    puls      a                  path length
                    inca                          + CR
                    sta       pastelen,u
* ---- restore normal screen colors, then clear, before launching basic09 ----
                    lda       #FG
                    ldb       #BG
                    lbsr      Color
                    lda       #$0C
                    lbsr      byte1scrn
* ---- enable Ctrl-C and Break so basic09 programs can be interrupted;
*      basic09 inherits the path descriptor. Use breakon (restores from
*      savedint/savedqut) - NOT breakoff, which would overwrite the saves.
*      The return path below re-disables both (clr 16,x / clr 17,x).
                    lbsr	  getopts		     get current terminal options
                    lbsr      keyechoon
                    lbsr	  getopts		     get current terminal options
                    lbsr      cursoron
                    lbsr      getopts            read current device options
                    lbsr      breakon            re-enable Ctrl-C (16) and quit/break (17)
* ---- fork basic09 with a 15K data area (#15k = 60 pages, via B reg) ----
                    clra
                    ldb       pastelen,u
                    tfr       d,y                Y = parameter length
                    leax      >B09CMD,pcr        X = command path
                    leau      pastebuf,u         U = parameter pointer (clobbers data base)
                    ldd       #$0140             A=type, B=64 pages (16K) data area
                    os9       F$Fork
                    bcs       rforked@           fork failed - skip wait
                    os9       F$Wait
rforked@            ldu       6,s                restore data base U (saved at entry)
newscr              clr       <finallen          restore pristine path state
* ---- redraw the FM screen (basic09 took it over) ----
                    lda       <dirlevel          inside a folder? step data dir to the
                    beq       rdraw@             parent so drawscreen's reload succeeds
                    leax      pdotdot,pcr
                    lda       #DIR.+READ.
                    os9       I$ChgDir
rdraw@              lbsr      drawscreen
                    lbsr      showclip           restore the clipboard line
* basic09 turns keyboard echo back on. The up-arrow key code is $0C, which is
* also the screen-clear char, so once echoed it would wipe the screen. Re-apply
* the FM terminal mode (echo off, keyboard interrupt off) here. Don't use
* breakoff - that would overwrite savedint and break the exit restore.
                    lbsr	  getopts		     get current terminal options
                    lbsr      keyechooff
                    lbsr	  getopts		     get current terminal options
                    lbsr      cursoroff
                    lbsr      getopts            read current device options
                    leax      >popts,u
                    clr       4,x                echo off
                    clr       17,x               Ctrl-E (quit) off so it reaches the FM
                    clr       16,x               keyboard interrupt off
                    clra
                    ldb       #SS.Opt
                    os9       I$SetStt
                    lda       #$01               text only on exit from b09
                    sta       >gfxset
                    lda       <listitem
                    beq       rdone@
                    deca
                    lbsr      uparrow
                    inca
                    lbsr      downarrow2
rdone@              puls      a,b,x,y,u,pc

********************************************************************
* runtekey - entry from keyloop when Ctrl-E pressed (open mode):
* open the selected file in the text editor, then return to the FM.
*
runtekey            lbsr      runte
                    lbra      keyloop
********************************************************************
* runte - open the selected file in the text editor (te), then return
* to the file manager. Builds the selected item's full path like runb09,
* runs the DoTE fork/wait handler, then redraws the FM screen.
*
runte               pshs      a,b,x,y,u
* ---- build selected file path (drive + folder + file) into finalpath ----
                    clr       <finallen
                    ldb       <dirlevel
                    bne       ewfldr@
                    lbsr      drivenmwrite2
                    lbsr      filenmwrite2
                    bra       eparam@
ewfldr@             lbsr      drivenmwrite2
                    ldb       <dirlevel
                    cmpb      #MAXDRIVELEVEL
                    bne       efldr@
                    lbsr      prevfldnmwrite2
efldr@              lbsr      foldernmwrite2
                    lbsr      filenmwrite2
eparam@             lda       <finallen          path includes trailing $0D
                    lbeq      edone@             nothing selected - skip
* ---- restore normal screen colors, then clear, before launching te ----
                    lda       #FG
                    ldb       #BG
                    lbsr      Color
                    lda       #$0C
                    lbsr      byte1scrn
* ---- run te on the selected file (existing fork + wait handler) ----
                    lbsr      DoTE
* ---- redraw the FM screen (te took it over) ----
                    clr       <finallen          restore pristine path state
                    lda       <dirlevel          inside a folder? step data dir to the
                    beq       edraw@             parent so drawscreen's reload succeeds
                    leax      pdotdot,pcr
                    lda       #DIR.+READ.
                    os9       I$ChgDir
edraw@              lbsr      drawscreen
                    lbsr      showclip           restore the clipboard line
                    lbsr      reterm             re-apply FM terminal mode (te changed it)
                    lda       <listitem
                    beq       edone@
                    deca
                    lbsr      uparrow
                    inca
                    lbsr      downarrow2
edone@              puls      a,b,x,y,u,pc
********************************************************************
* runhex - open the selected file in the hex editor (hexed), then
* return to the file manager. Same pattern as runte: build the selected
* item's full path, run DoHex (fork + wait), then redraw the FM screen.
*
runhexkey           lbsr      runhex
                    lbra      keyloop
runhex              pshs      a,b,x,y,u
* ---- build selected file path (drive + folder + file) into finalpath ----
                    clr       <finallen
                    ldb       <dirlevel
                    bne       hwfldr@
                    lbsr      drivenmwrite2
                    lbsr      filenmwrite2
                    bra       hparam@
hwfldr@             lbsr      drivenmwrite2
                    ldb       <dirlevel
                    cmpb      #MAXDRIVELEVEL
                    bne       hfldr@
                    lbsr      prevfldnmwrite2
hfldr@              lbsr      foldernmwrite2
                    lbsr      filenmwrite2
hparam@             lda       <finallen          path includes trailing $0D
                    lbeq      hdone@             nothing selected - skip
* ---- restore normal screen colors, then clear, before launching hexed ----
                    lda       #FG
                    ldb       #BG
                    lbsr      Color
                    lda       #$0C
                    lbsr      byte1scrn
* ---- run hexed on the selected file (fork + wait handler) ----
                    lbsr      DoHex
* ---- redraw the FM screen (hexed took it over) ----
                    clr       <finallen          restore pristine path state
                    lda       <dirlevel          inside a folder? step data dir to the
                    beq       hdraw@             parent so drawscreen's reload succeeds
                    leax      pdotdot,pcr
                    lda       #DIR.+READ.
                    os9       I$ChgDir
hdraw@              lbsr      drawscreen
                    lbsr      showclip           restore the clipboard line
                    lbsr      reterm             re-apply FM terminal mode (hexed changed it)
                    lda       <listitem
                    beq       hdone@
                    deca
                    lbsr      uparrow
                    inca
                    lbsr      downarrow2
hdone@              puls      a,b,x,y,u,pc

********************************************************************
* rundel - delete the selected file after the user confirms by typing
* YES (upper case). Builds the selected item's full path like runhex,
* prompts at (37,45), and only forks /dd/cmds/del (DoDel) on YES; then
* refreshes the file list. The prompt is blanked after, either way.
*
rundelkey           lbsr      rundel
                    lbra      keyloop
rundel              pshs      a,b,x,y,u
* ---- build selected file path (drive + folder + file) into finalpath ----
                    lbsr      blankconfirm
                    clr       <finallen
                    ldb       <dirlevel
                    bne       dwfldr@
                    lbsr      drivenmwrite2
                    lbsr      filenmwrite2
                    bra       dparam@
dwfldr@             lbsr      drivenmwrite2
                    ldb       <dirlevel
                    cmpb      #MAXDRIVELEVEL
                    bne       dfldr@
                    lbsr      prevfldnmwrite2
dfldr@              lbsr      foldernmwrite2
                    lbsr      filenmwrite2
dparam@             lda       <finallen          path includes trailing $0D
                    lbeq      ddone@             nothing selected - skip
* ---- confirm (type YES) ----
                    lbsr      confirmdel         sets <delok from the typed reply
                    lda       delok,u
                    beq       dskip@             not YES - do not run del
                    lbsr      DoDel              fork /dd/cmds/del + wait
dskip@              lbsr      blankconfirm       blank the prompt after it runs
                    lda       delok,u
                    lbeq      ddone@             not confirmed - no refresh needed
* ---- refresh the file list (the deleted file is now gone) ----
                    clr       <listitem          file deleted index not valid
                    clr       <finallen          restore pristine path state
                    lda       <dirlevel          inside a folder? step data dir to the
                    beq       ddraw@             parent so drawscreen's reload succeeds
                    leax      pdotdot,pcr
                    lda       #DIR.+READ.
                    os9       I$ChgDir
ddraw@              lbsr      drawscreen
                    lbsr      showclip           restore the clipboard line
                    lbsr      reterm             re-apply FM terminal mode
ddone@              puls      a,b,x,y,u,pc

********************************************************************
* confirmdel - show the confirm prompt at (37,45) and read three keys
* (echoed). Sets <delok = 1 only if the three keys are exactly Y, E, S.
*
confirmdel          lda       #TXTSEL
                    ldb       #TXTSELBG
                    lbsr      Color
                    lda       #37
                    ldb       #45
                    lbsr      CurXY
                    leax      >DelPrompt,pcr
                    ldy       #DelPromptLen
                    lda       #1
                    os9       I$Write
                    lda       #1
                    sta       delok,u            assume YES; any mismatch clears it
                    lbsr      getcharfm          first key
                    pshs      a
                    lbsr      byte1scrn          echo it
                    puls      a
                    cmpa      #'Y
                    beq       cd1@
                    clr       delok,u
cd1@                lbsr      getcharfm          second key
                    pshs      a
                    lbsr      byte1scrn
                    puls      a
                    cmpa      #'E
                    beq       cd2@
                    clr       delok,u
cd2@                lbsr      getcharfm          third key
                    pshs      a
                    lbsr      byte1scrn
                    puls      a
                    cmpa      #'S
                    beq       cd3@
                    clr       delok,u
cd3@                rts

* getcharfm - blocking read of one key from stdin -> A
getcharfm           clra                         path 0 = stdin
                    lbsr      FGETC
                    rts

* blankconfirm - erase the confirmation prompt line
blankconfirm        lda       #FG
                    ldb       #BG
                    lbsr      Color
                    lda       #37
                    ldb       #45
                    lbsr      CurXY
                    leax      >BlankConf,pcr
                    ldy       #BlankConfLen
                    lda       #1
                    os9       I$Write
                    rts

********************************************************************
* rename - OS-9 has no rename, so copy the selected file to a new name
* in the same folder with /dd/cmds/copy, and only if that succeeds delete
* the original with /dd/cmds/del. On a copy failure nothing is deleted and
* an error is shown. Entry: Ctrl-N; new name typed + Enter.
*
* Because OS-9 copy fails if the destination already exists, renaming onto
* an existing name (or the same name) fails safely - the original is only
* deleted after the copy succeeds.
*
renamekey           lbsr      rename
                    lbra      keyloop
rename              pshs      a,b,x,y,u
* ---- build SOURCE path (drive + folder + file) into finalpath ----
                    lbsr      blankconfirm
                    clr       <finallen
                    ldb       <dirlevel
                    bne       rnwfldr@
                    lbsr      drivenmwrite2
                    lbsr      filenmwrite2
                    bra       rnbuilt@
rnwfldr@            lbsr      drivenmwrite2
                    ldb       <dirlevel
                    cmpb      #MAXDRIVELEVEL
                    bne       rnfldr@
                    lbsr      prevfldnmwrite2
rnfldr@             lbsr      foldernmwrite2
                    lbsr      filenmwrite2
rnbuilt@            lda       <finallen          path includes trailing $0D
                    lbeq      rndone@            nothing selected - skip
* ---- prompt for the new name (Enter finalizes) ----
                    lbsr      getnewname         -> newname, newnamelen
                    lda       newnamelen,u
                    lbeq      rncancel@          empty entry - cancel
* ---- locate filename start (char after the last '/') in finalpath ----
                    leax      finalpath,u
                    leay      finalpath,u
                    ldb       <finallen
rnfs@               lda       ,x+
                    cmpa      #'/
                    bne       rnfsk@
                    leay      ,x                 char just after this '/'
rnfsk@              decb
                    bne       rnfs@
                    sty       fnstart,u
* ---- refuse if the new name already exists. 
*      Build the DEST path (folder prefix + newname + CR) into pastebuf and
                    leay      pastebuf,u
                    leax      finalpath,u
rnxpfx@             cmpx      fnstart,u
                    beq       rnxnm@
                    lda       ,x+
                    sta       ,y+
                    bra       rnxpfx@
rnxnm@              leax      newname,u
                    ldb       newnamelen,u
rnxcp@              lda       ,x+
                    sta       ,y+
                    decb
                    bne       rnxcp@
                    lda       #C$CR
                    sta       ,y+
                    leax      pastebuf,u
                    lda       #READ.
                    os9       I$Open
                    bcs       rnxok@             open failed = name is free = proceed
                    os9       I$Close            name is taken - refuse the rename
                    lbsr      errormsgln         position the error line at the bottom
                    lda       #1
                    leax      >RenExists,pcr
                    ldy       #RenExistsLen
                    os9       I$Write
                    lbsr      blankconfirm
                    lbra      rndone@
rnxok@
* ---- assemble "SOURCE DEST"+CR in pastebuf ----
                    leay      pastebuf,u         write pointer
* SOURCE = finalpath minus its trailing CR (finallen-1 chars)
                    leax      finalpath,u
                    lda       <finallen
                    deca
                    tfr       a,b
rncsrc@             lda       ,x+
                    sta       ,y+
                    decb
                    bne       rncsrc@
* separator
                    lda       #$20
                    sta       ,y+
* DEST prefix = finalpath up to the filename start
                    leax      finalpath,u
rncpfx@             cmpx      fnstart,u
                    beq       rncpfd@
                    lda       ,x+
                    sta       ,y+
                    bra       rncpfx@
rncpfd@
* DEST new name
                    leax      newname,u
                    ldb       newnamelen,u
rncnm@              lda       ,x+
                    sta       ,y+
                    decb
                    bne       rncnm@
* terminating CR
                    lda       #C$CR
                    sta       ,y+
* pastelen = Y - pastebuf
                    tfr       y,d
                    leax      pastebuf,u
                    pshs      x
                    subd      ,s++
                    stb       pastelen,u
* ---- position the error line, then copy; do NOT delete if it fails ----
                    lbsr      errormsgln         copy error (if any) prints at the bottom
                    lbsr      DoCopyR            carry set = copy failed
                    lbcs      rnfail@
* ---- copy ok: delete the original (still in finalpath), then refresh ----
                    lbsr      DoDel
                    lbsr      blankconfirm
                    lbsr      rnredraw
                    lbra      rndone@
* ---- copy failed: OS-9's error is already on the bottom line; do NOT
*      delete and do NOT refresh (nothing changed) - just clear the prompt ----
rnfail@             lbsr      blankconfirm
                    lbra      rndone@
rncancel@           lbsr      blankconfirm
rndone@             puls      a,b,x,y,u,pc

********************************************************************
* makdirkey / makdir - Ctrl-F: create a new directory inside the current
* folder. Builds the current directory path (drive [+ folder]) into
* finalpath - the same prefix rename builds, minus the selected file -
* prompts for the new folder name, appends it, and forks /dd/cmds/makdir
* with that path. The full redraw afterwards shows the new folder and also
* wipes anything makdir printed to the screen if it failed.
*
makdirkey           lbsr      makdir
                    lbra      keyloop
makdir              pshs      a,b,x,y,u
* ---- build the current directory path (drive [+ folder]) into finalpath ----
                    lbsr      blankconfirm
                    clr       <finallen
                    ldb       <dirlevel
                    bne       mkfldr@
                    lbsr      drivenmwrite2      "/dX/" (finallen = 4)
                    bra       mkprompt@
mkfldr@             lbsr      drivenmwrite2
                    ldb       <dirlevel
                    cmpb      #MAXDRIVELEVEL
                    bne       mkfld2@
                    lbsr      prevfldnmwrite2
mkfld2@             lbsr      foldernmwrite2     append "folder/"
* ---- prompt for the new folder name ----
mkprompt@           lbsr      getmkdirname       -> newname, newnamelen
                    lda       newnamelen,u
                    lbeq      mkcancel@          empty entry - cancel
* ---- append the name to the path (prefix already ends in '/'), then CR ----
                    lda       <finallen
                    leay      finalpath,u
                    leay      a,y                write pos = finalpath+finallen
                    leax      newname,u
                    ldb       newnamelen,u
mkapp@              lda       ,x+
                    sta       ,y+
                    inc       <finallen
                    decb
                    bne       mkapp@
                    lda       #C$CR
                    sta       ,y+
                    inc       <finallen
* ---- position the error line, then create the directory ----
                    lbsr      errormsgln         a makdir error prints at the bottom
                    lbsr      DoMakDir           carry set = makdir failed
                    lbcs      mkfail@
* ---- success: refresh the listing so the new folder shows ----
                    lbsr      blankconfirm
                    lbsr      rnredraw
                    bra       mkdrain@
* ---- failed: OS-9's error is already on the bottom line; do NOT refresh
*      (nothing changed) - just clear the prompt ----
mkfail@             lbsr      blankconfirm
                    bra       mkdrain@
mkcancel@           lbsr      blankconfirm
* The Enter that finished the folder-name prompt (and any key repeat) can
* still be pending; if it reaches the keyloop it fires as "select item 0"
* and draws that item's attribute in the wrong place. Drain the input and
* clear <key so nothing re-fires.
mkdrain@            lbsr      INKEY
                    tsta
                    bne       mkdrain@
                    clr       <key
mkdone@             puls      a,b,x,y,u,pc

********************************************************************
* getnewname - prompt at (37,45) and read a filename until Enter into
* newname (echoed, backspace supported, max 28 chars). Sets newnamelen.
*
getnewname          lda       #TXTSEL
                    ldb       #TXTSELBG
                    lbsr      Color
                    lda       #37
                    ldb       #45
                    lbsr      CurXY
                    leax      >RenPrompt,pcr
                    ldy       #RenPromptLen
                    lda       #1
                    os9       I$Write
                    clr       newnamelen,u
gnn@                lbsr      getcharfm          A = key (blocking)
                    cmpa      #C$CR              Enter - finished
                    beq       gnndone@
                    cmpa      #$08               backspace
                    beq       gnnbs@
                    cmpa      #$20               ignore control chars
                    blo       gnn@
                    ldb       newnamelen,u
                    cmpb      #28                buffer full?
                    bhs       gnn@
                    leax      newname,u
                    abx
                    sta       ,x                 store the char
                    inc       newnamelen,u
                    lbsr      byte1scrn          echo (A still = char)
                    bra       gnn@
gnnbs@              ldb       newnamelen,u
                    beq       gnn@               nothing to erase
                    dec       newnamelen,u
                    lda       #$08               erase on screen: BS, space, BS
                    lbsr      byte1scrn
                    lda       #$20
                    lbsr      byte1scrn
                    lda       #$08
                    lbsr      byte1scrn
                    bra       gnn@
gnndone@            rts

********************************************************************
* getmkdirname - like getnewname but prompts "Folder name:" for makdir.
* Reads into newname/newnamelen (echoed, backspace, max 28 chars).
*
getmkdirname        lbsr      blnkerrmsg
                    lda       #TXTSEL
                    ldb       #TXTSELBG
                    lbsr      Color
                    lda       #37
                    ldb       #45
                    lbsr      CurXY
                    leax      >MkDirPrompt,pcr
                    ldy       #MkDirPromptLen
                    lda       #1
                    os9       I$Write
                    clr       newnamelen,u
gmk@                lbsr      getcharfm          A = key (blocking)
                    cmpa      #C$CR              Enter - finished
                    beq       gmkdone@
                    cmpa      #$08               backspace
                    beq       gmkbs@
                    cmpa      #$20               ignore control chars
                    blo       gmk@
                    ldb       newnamelen,u
                    cmpb      #28                buffer full?
                    bhs       gmk@
                    leax      newname,u
                    abx
                    sta       ,x                 store the char
                    inc       newnamelen,u
                    lbsr      byte1scrn          echo (A still = char)
                    bra       gmk@
gmkbs@              ldb       newnamelen,u
                    beq       gmk@               nothing to erase
                    dec       newnamelen,u
                    lda       #$08               erase on screen: BS, space, BS
                    lbsr      byte1scrn
                    lda       #$20
                    lbsr      byte1scrn
                    lda       #$08
                    lbsr      byte1scrn
                    bra       gmk@
gmkdone@            rts

********************************************************************
* rnredraw - reload the directory listing after a rename (same steps the
* other handlers use on return).
*
rnredraw            clr       <finallen
                    lda       <dirlevel
                    beq       rnrd@
                    leax      pdotdot,pcr
                    lda       #DIR.+READ.
                    os9       I$ChgDir
rnrd@               lbsr      drawscreen
                    lbsr      showclip
                    lbsr      reterm
                    rts

* showrnerr - show the copy-failed message at (37,45)
showrnerr           lda       #TXTSEL
                    ldb       #TXTSELBG
                    lbsr      Color
                    lda       #37
                    ldb       #45
                    lbsr      CurXY
                    leax      >RenErr,pcr
                    ldy       #RenErrLen
                    lda       #1
                    os9       I$Write
                    rts

********************************************************************
* runattrkey - entry from keyloop when Ctrl-A pressed (open mode):
* get the selected file attributes.
*
runattrkey          lbsr      runattr
                    lbra      keyloop
********************************************************************
* runattr - get the file attributes
*
runattr             pshs      a,b,x,y,u
* ---- build selected file path (drive + folder + file) into finalpath ----
                    lbsr      blnkerrmsg
                    clr       <finallen
                    ldb       <dirlevel
                    bne       ewfldr@
                    lbsr      drivenmwrite2
                    lbsr      filenmwrite2
                    bra       eparam@
ewfldr@             lbsr      drivenmwrite2
                    ldb       <dirlevel
                    cmpb      #MAXDRIVELEVEL
                    bne       efldr@
                    lbsr      prevfldnmwrite2
efldr@              lbsr      foldernmwrite2
                    lbsr      filenmwrite2
eparam@             lda       <finallen     path includes trailing $0D
                    lbeq      edone@        nothing selected - skip
                    lbsr      DoATTR
edone@              puls      a,b,x,y,u,pc

********************************************************************
* line edit
*
lineedit            lda       #5
                    ldb       #56
                    lbsr      CurXY
                    leax      fname,u
                    ldy       #29
                    lda       #$01
                    os9       I$Write
                    rts

handlecursor        lda       <curcol       set cursor color
                    anda      #$0F
                    ldb       #TXTBG
                    lbsr      Color 
                    lda       <curx
                    ldb       #56
                    lbsr      CurXY
                    lda       #SLD          cursor char
                    lbsr      byte1scrn
                    lda       #TXT          restore color
                    ldb       #TXTBG
                    lbsr      Color
                    rts

terightarrow        lda       <curx
                    cmpa      #33           end of filename?
                    lbeq      keyloop
                    inca
                    sta       <curx
                    inc       <curxbf
                    rts

teleftarrow         lda       <curx
                    cmpa      #5            begenning of filename?
                    lbeq      keyloop
                    deca
                    sta       <curx
                    dec       <curxbf
                    rts

teenter             lbsr      checkfilename
                    lda       <errflg
                    cmpa      #1            error?
                    beq       noenter
                    lda       <key
                    rts

noenter             clr       <key
                    rts

tebackspace         clr       <key
                    lda       <curxbf
                    beq       done@
                    dec       <curx
                    dec       <curxbf
                    leax      fname,u
                    lda       #32
                    ldb       <curxbf
                    sta       b,x
done@               rts

savefilechooser     lda       <selx         clr select drive
                    ldb       #2
                    lbsr      CurXY
                    lda       #32
                    lbsr      byte1scrn
                    lda       <selx
                    inca
                    inca
                    inca
                    inca
                    ldb       #2
                    lbsr      CurXY
                    lda       #32
                    lbsr      byte1scrn
                    lda       #2
                    ldb       #5
                    lbsr      CurXY
                    lda       #RTAR
                    lbsr      byte1scrn
                    rts                      4 menu option for save listbox enter

checkfilename       clrb                     count non-space chars
                    leax     fname,u
                    ldy      #29
loop@               lda      ,x+
                    cmpa     #$20
                    bne      foundchar       non-space: count it
cont@               leay     -1,y
                    bne      loop@
                    cmpb     #0              B=0 means all spaces = invalid filename
                    beq      disperr
                    lda      #0              B>0 means valid filename found
                    sta      <errflg         clear error flag
                    rts
foundchar           incb
                    bra      cont@
disperr             lda      #45
                    ldb      #50
                    lbsr     CurXY
                    lda      #1
                    leax     HelpErr,pcr
                    ldy      #HelpErrLen
                    os9      I$Write
                    lda      #1
                    sta      <errflg
                    rts

********************************************************************
* parseparams
*
* Get parameter line from system
parseparams        
getparms            lda       ,x+
                    cmpa      #C$SPAC
                    beq       parseparams   ignore spaces
                    cmpa      #C$CR
                    beq       done       
                    cmpa      #'-
                    bne       getparms
                    lda       ,x+
                    cmpa      #'h            -h : print help and exit
                    beq       arghelp@
                    cmpa      #'s
                    bne       p@
                    lda       #1
                    sta       <opensave
                    sta       <usepipe
                    bra       done
p@                  cmpa      #'p
                    bne       getparms
                    lda       #1
                    sta       <usepipe
done                rts
* -h : print each help line on its own row via I$WritLn, then exit. This
* runs before the screen is taken over, so it lands on the shell screen.
arghelp@            leax      Help1,pcr
                    lbsr      hln@
                    leax      Help2,pcr
                    lbsr      hln@
                    leax      Help3,pcr
                    lbsr      hln@
                    leax      Help4,pcr
                    lbsr      hln@
                    clrb
                    os9       F$Exit
hln@                ldy       #80            upper bound - the $0D ends the line
                    lda       #1             path 1 = stdout
                    os9       I$WritLn
                    rts
Help1               fcc       "NitrOS-9 File Manager"
                    fcb       C$CR
Help2               fcc       "The File Manager supports 2 directories depth, and 255 files per folder."
                    fcb       C$CR
Help3               fcc       "fm            use File Manager"
                    fcb       C$CR
Help4               fcc       "fm -s         use pipe to return filename to caller"
                    fcb       C$CR

********************************************************************
* get file attributes
Attrs               fcc       "dsewrewr"
                    fcb       $FF

* Open the file
getattr             pshs      x,y,u
                    lda       #37
                    ldb       #56
                    lbsr      CurXY
                    lda       <listitem
                    lbsr	  arrayidx
                    leax	  2,x            advance past 2 byte string len
                    clr       <filedir
                    lda       #READ.         open for reading
                    os9       I$Open         open file
                    lbcs      trydir         not file so try dir - branch if error
                    sta       <fpath2        save path number
                    bra       getfd          move on valid file

trydir              inc       <filedir
                    lda       <listitem
                    lbsr	  arrayidx
                    leax	  2,x            advance past 2 byte string len
                    lda       #DIR.+READ.    open as directory
                    os9       I$Open         try one more time
                    lbcs      error          branch if error
                    sta       <fpath2        save off path

* Get file descriptor information
getfd               lda       <fpath2        get path number
                    leax      fdbuf2,pcr     point to buffer for file descriptor
                    ldy       #255           buffer size
                    ldx       #SS.FD         status code for file descriptor
                    os9       I$GetStt       get file descriptor
                    lbcs      closerr        branch if error

* get file attribute
                    leax      fdbuf2,pcr     point to file descriptor buffer
                    lda       FD.ATT,x       get file attributes byte
udtattr             sta       <attr
  
ShowAttrs
                    lda       <filedir
                    cmpa      #0
                    bne       dir
                    ldb       fdbuf2,pcr
                    ldb       #$0B                
                    bra       L0190
dir                 ldb       fdbuf2,pcr
                    ldb       #$BF
                    stb       <attr
L0190               leax      Attrs,pcr       point to attributes
                    leay      attrbuf,pcr     attribute print buffer
                    lda       ,x+             get next attribute byte
L0197               lslb                      move bit 7 into carry
                    bcs       L019C           branch bit 7 was set
                    lda       #'-             print "-" to indicate attribute is off
L019C               sta       ,y+             and save off to Y
                    lda       ,x+             get next character at X
                    bpl       L0197           if hi-bit not set, do again
                    lda       #C$CR           get carriage return
                    sta       ,y+             store it in buffer
                    leax      attrbuf,pcr     point to buffer
                    clrb                      clear B
                    bra       PrintAndExit    print

* Print what's at X to stderr then bail out
PrintAndExit        pshs      b
                    lda       #1              write to stderr
                    ldy       #8              up to 256 bytes
                    os9       I$Write         write line
                    puls      b
                    lda       <fpath2
                    os9       I$Close
                    puls      x,y,u
                    rts

* Error handlers        
closerr             lda       <fpath2
                    os9       I$Close
error               cmpb      #214            no permissions
                    beq       setattr
                    cmpb      #216            bad path
                    bne       errorcont
setattr             lda       #$BF
                    sta       <attr
                    bra       ShowAttrs
errorcont           os9       F$PErr          print error
                    clrb                      return no error code
                    puls      x,y,u
                    rts

********************************************************************
* driveselect - select the drive the current drive menu has selected
*
driveselect         lda       <dirlevel       if in folder and drive changes exit folder
                    beq       dodrv@
                    clr       <dirlevel
                    lda       #$20
                    ldb       #29
                    leax      folder,u
clrfolder@          sta       ,x+
                    decb      
                    bne       clrfolder@
dodrv@              lda       <selx
                    cmpa      #16
                    bne       next@
                    ldb       #0
                    stb       <driveidx
                    leax	  drive0,pcr
                    bra       done@
next@               cmpa      #20
                    bne       next2@
                    ldb       #1
                    stb       <driveidx
                    leax	  drive1,pcr
                    bra       done@
next2@              cmpa      #24
                    bne       next3@
                    ldb       #2
                    stb       <driveidx
                    leax	  drive2,pcr
                    bra       done@
next3@              cmpa      #28
                    bne       next4@
                    ldb       #3
                    stb       <driveidx
                    leax	  drive3,pcr
                    bra       done@
next4@              cmpa      #32
                    bne       next5@
                    ldb       #4
                    stb       <driveidx
                    leax	  drive4,pcr
                    bra       done@
next5@              cmpa      #36
                    bne       next6@
                    ldb       #5
                    stb       <driveidx
                    leax	  drive5,pcr
                    bra       done@
next6@              cmpa      #40
                    bne       next7@
                    ldb       #6
                    stb       <driveidx
                    leax      drive6,pcr
                    bra       done@
next7@              cmpa      #44
                    bne       next8@
                    ldb       #7
                    stb       <driveidx
                    leax      drive7,pcr
                    bra       done@
next8@              cmpa      #48
                    bne       done@
                    ldb       #8
                    stb       <driveidx
                    leax      drive8,pcr
done@               pshs      x             push drive label
                    lda       #9            pos drive label
                    ldb       #2
                    lbsr      CurXY
                    puls      x             restore drive label
                    ldy       #3            3 bytes
                    lda       #1            stdout
                    os9       I$Write
                    clr       <listmax
                    clr       <numfonts
                    clr    	  <listitem		init list item = 0
                    clr       <liststart	init list start = 0
                    clr       <listloop
                    lda       #$FF          reset double-click state
                    sta       <dclick
                    clr       <dclicktmr
                    lbsr      ldfontarr
                    lbsr	  writelist		write the list of files
                    lbra      keyloop


********************************************************************
* handlekeyboard
* handles keypress and routines for interface updates
*
handlekeyboard      lbsr      INKEY
                    sta       <key
                    cmpa      #$0C          all menu levels drive select list
                    lbeq      chkup
                    cmpa      #$0A
                    lbeq      chkdown
	                cmpa      #32
	                lbeq      spacesel
                    lda       <menu
                    cmpa      #4
                    bne       menu3
                    lda       <key
                    cmpa      #8
                    lbeq      updir         left arrow check dirlevel for non root
                    lbra       done@
menu3               cmpa      #3            drive select menu left right sel drive
                    bne       nextkb@
                    lda       <key
                    cmpa      #8
                    lbeq      leftarrow
                    cmpa      #9
                    lbeq      rightarrow
                    bra       done@
nextkb@             cmpa      #0             menu 0
                    bne       done@
                    lda       <opensave
                    cmpa      #1             save menu?
                    beq       savekeys
                    lda       <key
                    cmpa      #8
                    lbeq      updir          left arrow check dirlevel for non root
                    lda       <opensave
                    beq       done@
savekeys            lda       <key
                    cmpa      #$2F            / is handled by file chooser
                    beq       skip@
                    cmpa      #8
                    bne       chkrght
                    lda	      #0			  else check for the shift key
	                ldb	      #SS.KySns
	                os9       I$GetStt
	                bita      #LEFTBIT
	                lbne 	  teleftarrow     If shiftbit=1,then left		
                    lbra      tebackspace     handle backspace    
chkrght             cmpa      #9
                    lbeq      terightarrow
                    cmpa      #13
                    lbeq      teenter
                    cmpa      #$7A            last legal char z
                    bhi       skip@
                    cmpa      #$2D            / legal char but handled by file chooser skip
                    bls       skip@
                    cmpa      #$40            skip : ; < = > ? @
                    bhi       cont@       
                    cmpa      #$3A
                    bhs       skip@
cont@               cmpa      #$5F            _ underline allowed
                    beq       next@
                    cmpa      #$60            skip [ \ ] ^ `
                    bhi       next@
                    cmpa      #$5B
                    bhs       skip@            
next@               lda       <key
                    beq       done@
cont2@              pshs      x
                    leax      fname,u
                    ldb       <curxbf
                    ;subb      #5
                    lda       <key
                    leax      b,x
                    sta       ,x
                    lda       <curx
                    cmpa      #34
                    beq       done2@
                    inc       <curx
                    inc       <curxbf
done2@              puls      x
done@               rts
skip@               clr       <key           done processing key
                    rts


spacesel            lda       <opensave
                    beq       opnmenu
                    lda       <menu
                    cmpa      #4
                    bne       cont@
                    clr       <menu
                    bra       cont2@
opnmenu             lda       <menu          get menu value
                    cmpa      #3
                    bne       cont@
                    clr       <menu
                    bra       cont2@                   
cont@               inc       <menu
cont2@              lda       <menu
                    cmpa      #0
                    lbeq      listsel
                    cmpa      #1
                    lbeq      opensel
                    cmpa      #2
                    lbeq      cancelsel
                    cmpa      #3
                    lbeq      drivesel
                    cmpa      #4
                    lbeq      savefilechooser
                    rts

opensel             lda       #57            open select
                    ldb       #56
                    lbsr      CurXY
                    lda       #RTAR
                    lbsr      byte1scrn
                    lda       #64
                    ldb       #56
                    lbsr      CurXY
                    lda       #LFAR
                    lbsr      byte1scrn
                    ldb       <opensave
                    beq       done@
                    lda       #FG            restore normal screen colors
                    ldb       #BG
                    lbsr      Color
                    lda       #3
                    ldb       #56
                    lbsr      CurXY
                    lda       #$20
                    lbsr      byte1scrn
                    lda       #TXT
                    ldb       #TXTBG
                    lbsr      Color
done@               rts

cancelsel           lda       #57             deselect open
                    ldb       #56
                    lbsr      CurXY
                    lda       #32
                    lbsr      byte1scrn
                    lda       #64
                    ldb       #56
                    lbsr      CurXY
                    lda       #32
                    lbsr      byte1scrn
                    lda       #68             select cancel
                    ldb       #56
                    lbsr      CurXY
                    lda       #RTAR
                    lbsr      byte1scrn
                    lda       #76
                    ldb       #56
                    lbsr      CurXY
                    lda       #LFAR
                    lbsr      byte1scrn
                    lda       #1              cancel
                    sta       <canc
                    rts

drivesel            lda       #68             clear cancel select
                    ldb       #56
                    lbsr      CurXY
                    lda       #32
                    lbsr      byte1scrn
                    lda       #76
                    ldb       #56
                    lbsr      CurXY
                    lda       #32
                    lbsr      byte1scrn
                    lda       <selx
                    ldb       #2
                    lbsr      CurXY
                    lda       #RTAR
                    lbsr      byte1scrn
                    lda       <selx
                    inca
                    inca
                    inca
                    inca
                    ldb       #2
                    lbsr      CurXY
                    lda       #LFAR
                    lbsr      byte1scrn
                    lbsr      showhelpdrive
                    rts

listsel             lbsr      showhelpmain
                    lda       <selx         select cancel
                    ldb       #2
                    lbsr      CurXY
                    lda       #32
                    lbsr      byte1scrn
                    lda       <selx
                    inca
                    inca
                    inca
                    inca
                    ldb       #2
                    lbsr      CurXY
                    lda       #32
                    lbsr      byte1scrn
                    ldb       <opensave
                    beq       done@
                    lda       #FG           restore normal screen colors
                    ldb       #BG
                    lbsr      Color
                    lda       #2
                    ldb       #5
                    lbsr      CurXY
                    lda       #$20
                    lbsr      byte1scrn
                    lda       #TXT
                    ldb       #TXTBG
                    lbsr      Color
                    lda       #3
                    ldb       #56
                    lbsr      CurXY
                    lda       #RTAR
                    lbsr      byte1scrn
done@               rts      

leftarrow           lda       <selx
                    cmpa      #16
                    beq       done@
                    lda       <selx        blank previous right selector
                    adda      #4
                    ldb       #2
                    lbsr      CurXY
                    lda       #32
                    lbsr      byte1scrn
                    lda       <selx
                    suba      #4
                    sta       <selx
                    bsr       drawdrvsel
done@               rts

rightarrow          lda       <selx
                    cmpa      #48
                    beq       done@
                    lda       <selx        blank previous left selector
                    ldb       #2
                    lbsr      CurXY
                    lda       #32
                    lbsr      byte1scrn
                    lda       <selx
                    adda      #4
                    sta       <selx
                    bsr       drawdrvsel
done@               rts

drawdrvsel          lda       <selx
                    ldb       #2
                    lbsr      CurXY
                    lda       #RTAR
                    lbsr      byte1scrn
                    lda       <selx
                    inca
                    inca
                    inca
                    inca
                    ldb       #2
                    lbsr      CurXY
                    lda       #LFAR
                    lbsr      byte1scrn
                    rts

********************************************************************
* drawbox
* filelist border box
drawbox             lda       #TXT          ensure known color state on entry
                    ldb       #TXTBG
                    lbsr      Color
                    lda       #34          up Arrow
                    ldb       #4
                    lbsr      CurXY
                    lda       #UPAR
                    lbsr      byte1scrn
                    lda       #0           fg
                    ldb       #6           bg
                    lbsr      Color
                    lda       #$1C
                    lbsr      byte1scrn
                    lda       #5
                    lbsr      byte1scrn
                    lda       #TXT
                    ldb       #TXTBG
                    lbsr      Color
                    
* draw vertical line
*
                    lda       #5            start border on line 1
                    sta       <k
cont@               lda       #34           x
                    ldb       <k
                    lbsr      CurXY
                    leas      -1,s          reserve 1 byte for stack
                    lda       #SBL
                    sta       ,s
                    lda       #$01          stdout
                    ldy       #1            number of characters to print
                    tfr       s,x
                    os9       I$Write       draw scroll bar border
                    leas      1,s           return stack to normal
                    lda       <k
                    inca
                    sta       <k
                    cmpa      #51
                    bne       cont@
*
                    lda       #34           down Arrow
                    ldb       #51
                    lbsr      CurXY
                    lda       #DNAR
                    lbsr      byte1scrn
                    lda       #0            fg
                    ldb       #6            gb
                    lbsr      Color
                    lda       #$1C
                    lbsr      byte1scrn
                    lda       #6
                    lbsr      byte1scrn
                    lda       #TXT
                    ldb       #TXTBG
                    lbsr      Color
* left border
                    lda       #0            fg
                    ldb       #6            gb
                    lbsr      Color
* top left curved
                    lda       #4
                    ldb       #4
                    lbsr      CurXY
                    lda       #$1C
                    lbsr      byte1scrn
                    lda       #3
                    lbsr      byte1scrn
                    lda       #5            start border on line 1
                    sta       <k
cont2@              lda       #4            x
                    ldb       <k
                    lbsr      CurXY
                    leas      -1,s          reserve 1 byte for stack
                    lda       #SLD          solid block
                    sta       ,s
                    lda       #$01          stdout
                    ldy       #1            number of characters to print
                    tfr       s,x
                    os9       I$Write       end top title and border
                    leas      1,s           return stack to normal
                    lda       <k
                    inca
                    sta       <k
                    cmpa      #51
                    bne       cont2@
                    lda       #4
                    ldb       #51
                    lbsr      CurXY
                    lda       #$1C
                    lbsr      byte1scrn
                    lda       #4
                    lbsr      byte1scrn
                    lda       #TXT
                    ldb       #TXTBG
                    lbsr      Color
                    rts

********************************************************************
* showhelp
*
*
showhelp            lda       #49            was 54
                    ldb       #5
                    lbsr      CurXY
                    lda       #2
                    ldb       #6
                    lbsr      Color
                    lda       #$4E           N
                    lbsr      byte1scrn
                    lda       #8
                    ldb       #6
                    lbsr      Color
                    lda       #$69           i
                    lbsr      byte1scrn
                    lda       #7
                    ldb       #6
                    lbsr      Color
                    lda       #$74           t
                    lbsr      byte1scrn
                    lda       #5
                    ldb       #6
                    lbsr      Color
                    lda       #$72           r
                    lbsr      byte1scrn
                    lda       #1
                    ldb       #6
                    lbsr      Color
                    lda       #$4F           O
                    lbsr      byte1scrn
                    lda       #$53           S 
                    lbsr      byte1scrn
                    lda       #$2D           -
                    lbsr      byte1scrn      
                    lda       #$39           9
                    lbsr      byte1scrn
                    leax      Wild,pcr
                    ldy       #WildLen
                    lda       #01
                    os9       I$Write
                    lda       <opensave
                    beq       dohelp@
                    lda       #37
                    ldb       #18
                    lbsr      CurXY
                    leax      HelpSAve,pcr
                    ldy       #HelpSaveLen
                    lda       #01
                    os9       I$Write
dohelp@             lbsr      showhelpmain
                    rts

showhelpmain        lda       #37
                    ldb       #7
                    lbsr      CurXY
                    lda       #1
                    ldb       #6
                    lbsr      Color
                    lda       <opensave
                    cmpa      #0
                    bne       shelp                 
                    leax      HelpSel,pcr  
                    ldy       #HelpSelLen
                    bra       wrthlp
shelp               leax      HelpSelb,pcr  
                    ldy       #HelpSelLenb
wrthlp              lda       #$01
                    os9       I$Write
                    lda       #37
                    ldb       #9
                    lbsr      CurXY
                    lda       <opensave
                    cmpa      #0
                    bne       shelp2                                     
                    leax      HelpSel2,pcr  
                    ldy       #HelpSel2Len
                    bra       wrthlp2
shelp2              leax      HelpSel2b,pcr  
                    ldy       #HelpSel2Lenb
wrthlp2             lda       #$01
                    os9       I$Write
                    lda       #37
                    ldb       #11
                    lbsr      CurXY
                    leax      HelpSel3,pcr  
                    ldy       #HelpSel3Len
                    lda       #$01
                    os9       I$Write
                    lda       #51
                    ldb       #20
                    lbsr      CurXY
                    lbsr      DoDate
                    lda       #37
                    ldb       #47
                    lbsr      CurXY
                    leax      HelpSel4,pcr  
                    ldy       #HelpSel4Len
                    lda       #$01
                    os9       I$Write
                    lda       #37
                    ldb       #49
                    lbsr      CurXY
                    leax      HelpSel5,pcr  
                    ldy       #HelpSel5Len
                    lda       #$01
                    os9       I$Write
                    lda       #37
                    ldb       #51
                    lbsr      CurXY
                    leax      HelpSel6,pcr  
                    ldy       #HelpSel6Len
                    lda       #$01
                    os9       I$Write
                    lda       #TXT
                    ldb       #TXTBG
                    lbsr      Color
                    lda       #67
                    ldb       #51
                    lbsr      CurXY
                    leax      VerStr,pcr  
                    ldy       #VerStrLen
                    lda       #$01
                    os9       I$Write
                    lda       <opensave
                    beq       done@
                    lda       #37
                    ldb       #14
                    lbsr      CurXY
                    leax      HelpSaveLst,pcr
                    ldy       #HelpSaveLstLen
                    lda       #$01
                    os9       I$Write
                    lda       #37
                    ldb       #16
                    lbsr      CurXY
                    leax      HelpSelb2,pcr  
                    ldy       #HelpSelb2Len
                    lda       #$01
                    os9       I$Write
done@               lda       #TXT
                    ldb       #TXTBG
                    lbsr      Color
                    rts

showhelpdrive       lda       #37
                    ldb       #7
                    lbsr      CurXY
                    lda       #1
                    ldb       #6
                    lbsr      Color
                    lda       #$01                 
                    leax      HelpDrv,pcr  
                    ldy       #HelpDrvLen
                    os9       I$Write
                    lda       #37
                    ldb       #9
                    lbsr      CurXY                 
                    leax      HelpDrv2,pcr  
                    ldy       #HelpDrv2Len
                    os9       I$Write
                    lda       #37
                    ldb       #11
                    lbsr      CurXY
                    leax      HelpSel3,pcr  
                    ldy       #HelpSel3Len
                    lda       #$01
                    os9       I$Write
                    lda       #51
                    ldb       #20
                    lbsr      CurXY
                    lbsr      DoDate
                    lda       #37
                    ldb       #47
                    lbsr      CurXY
                    leax      HelpSel4,pcr  
                    ldy       #HelpSel4Len
                    lda       #$01
                    os9       I$Write
                    lda       #37
                    ldb       #49
                    lbsr      CurXY
                    leax      HelpSel5,pcr  
                    ldy       #HelpSel5Len
                    lda       #$01
                    os9       I$Write
                    lda       #37
                    ldb       #51
                    lbsr      CurXY
                    leax      HelpSel6,pcr  
                    ldy       #HelpSel6Len
                    lda       #$01
                    os9       I$Write
                    lda       #TXT
                    ldb       #TXTBG
                    lbsr      Color
                    lda       #67
                    ldb       #51
                    lbsr      CurXY
                    leax      VerStr,pcr  
                    ldy       #VerStrLen
                    lda       #$01
                    os9       I$Write
                    rts

********************************************************************
* handlemouse
* read x,y,btn values for interface updates
handlemouse         lbsr      Mouse
                    cmpa      #1
                    lbeq      leftclick
done@               rts

leftclick           ldd       <y              drive selector y 16-24
                    cmpd      #16
                    lble      done@
                    cmpd      #24
                    lbhi      msscrollbar
msd0                ldd       <x
                    cmpd      #136
                    lblt      done@
                    cmpd      #152
                    bhi       msd1            next task
                    ldb       #0              drive 0
                    stb       <driveidx
                    leax	  drive0,pcr
                    lbra      msdrv
msd1                ldd       <x
                    cmpd      #168
                    lblt      done@
                    cmpd      #184
                    bhi       msd2
                    ldb       #1              drive 1
                    stb       <driveidx
                    leax	  drive1,pcr
                    lbra      msdrv
msd2                ldd       <x
                    cmpd      #200
                    lblt      done@
                    cmpd      #216
                    bhi       msd3
                    ldb       #2              drive 2
                    stb       <driveidx
                    leax	  drive2,pcr
                    lbra      msdrv 
msd3                ldd       <x
                    cmpd      #232
                    lblt      done@
                    cmpd      #248
                    bhi       msd4
                    ldb       #3              drive 3
                    stb       <driveidx
                    leax	  drive3,pcr
                    lbra      msdrv
msd4                ldd       <x
                    cmpd      #264
                    lblt      done@
                    cmpd      #280
                    bhi       msd5
                    ldb       #4              drive 4
                    stb       <driveidx
                    leax	  drive4,pcr
                    bra       msdrv
msd5                ldd       <x
                    cmpd      #296
                    lblt      done@
                    cmpd      #312
                    bhi       msd6
                    ldb       #5              drive 5
                    stb       <driveidx
                    leax	  drive5,pcr
                    bra       msdrv
msd6                ldd       <x
                    cmpd      #330
                    lblt      done@
                    cmpd      #346
                    bhi       msd7
                    ldb       #6              drive 6
                    stb       <driveidx
                    leax      drive6,pcr
                    lbra      msdrv
msd7                ldd       <x
                    cmpd      #362
                    lblt      done@
                    cmpd      #378
                    bhi       msd8
                    ldb       #7              drive 7
                    stb       <driveidx
                    leax      drive7,pcr
                    bra       msdrv
msd8                ldd       <x
                    cmpd      #394
                    lblt      done@
                    cmpd      #410
                    bhi       msscrollbar
                    ldb       #8              drive 8
                    stb       <driveidx
                    leax      drive8,pcr
msdrv               pshs      x               push drive label
                    lda       #9              pos drive label
                    ldb       #2
                    lbsr      CurXY
                    puls      x               restore drive label
                    ldy       #3              3 bytes
                    lda       #1              stdout
                    os9       I$Write
                    lbsr      mschangedrive
                    lbra       done@
msscrollbar         ldd       <x              check for scroll bar click 272-288
                    cmpd      #272
                    lblt      mslistsel       disabled for later use **
                    cmpd      #288
                    bhi       opencanbtn      not scroll bar so check for open cancel buttons
                    ldd       <y
                    cmpd      #239
                    blt       upclk@
                    lbsr      downarrow2
                    lbra       done@
upclk@              lbsr      uparrow
                    lbra       done@
opencanbtn          ldd       <y
                    cmpd      #448
                    lble       done@
                    cmpd      #456
                    bhi       done@
                    ldd       <x
                    cmpd      #456
                    blt       done@
                    cmpd      #512
                    bhi       mscancsel       cancel right of open
                    lda       <menu           get menu value
                    cmpa      #3              max menu 3
                    bne       cont@
                    clr       <menu
                    bra       cont2@                   
cont@               inc       <menu           increment menu
cont2@              lda       <menu
                    ldb       <menu
                    cmpb      #1
                    bne       msopensel
                    ldb       #0
                    stb       <runstop        exit next keyloop double clicked
                    bra       done@
msopensel           lbra      opensel         open clicked
mscancsel           ldd       <x              y value beween 448 and 456
                    cmpd      #544            x>544 and x<616 cancel btn
                    blt       done@
                    cmpd      #616
                    bhi       done@           next task
                    ldb       #0
                    stb       <runstop        cancel next keyloop double clicked
                    lbra      cancelsel
                    bra       done@
mslistsel           ldd       <x
                    cmpd      #33
                    blo       done@
                    ldd       <y
                    cmpd      #32             reject clicks above list top (row 4 = pixel 32)
                    blo       done@
                    ldd       <y
                    subd      #32             remove 32 pixel offset to list top
                    ldy       #0              y=row counter
                    ldx       #8              start at first boundary (8px per row)
xloop@              std       <ytemp          store y value
                    cmpx      <ytemp
                    bls       nxtitm@         advance if X <= pixel offset
                    bra       msidxitm        X > pixel offset: found the row
nxtitm@             leax      8,x
                    leay      1,y             inc row counter
                    clra
                    ldb       <numfonts       guard: stop at max items
                    std       <mtemp
                    cmpy      <mtemp
                    bls       uptrtn@
done@               rts
uptrtn@             ldd       <ytemp
                    bra       xloop@

mschangedrive       lda       <driveidx       sync selx to the loaded drive so path
                    lsla                      builds use the current drive, not a stale
                    lsla                      one (selx = 16 + driveidx*4)
                    adda      #16
                    sta       <selx
                    lda       <dirlevel       if in folder and drive changes exit folder
                    beq       dodrv@
                    clr       <dirlevel
                    lda       #$20
                    ldb       #29
                    leax      folder,u
clrfolder@          sta       ,x+
                    decb      
                    bne       clrfolder@
dodrv@              clr       <listmax
                    clr       <numfonts
                    clr    	  <listitem		  init list item = 0
                    clr       <liststart	  init list start = 0
                    clr       <listloop
                    lda       #$FF            reset double-click state
                    sta       <dclick
                    clr       <dclicktmr
                    lbsr      ldfontarr
                    lbsr	  writelist
                    rts

********************************************************************
* msidxitm
* called when user clicks on a list item
* Y = row index (1-based from mslistsel loop)
* checks for double-click on the same item within DCLICK_TIMEOUT ticks
* single click: select the item and arm the double-click timer
* double click: run the enter/open action for the selected item
*
msidxitm            exg      d,y              index to d
                    clra
                    exg      a,b              row index to a (1-based, or 0 if click on top pixel)
                    beq      clamp0@          Y=0 means top pixel exactly - clamp to item 0
                    deca                      make 0-based
clamp0@             adda     <liststart       add scroll offset to get true item index
                    sta      <listitem        set as selected item
* Check for double-click: same item, timer still running
                    ldb      <dclick          get last-clicked item
                    cmpb     <listitem        same item as this click?
                    bne      singleclk@       no: arm timer for new single click
                    lda      <dclicktmr       yes: is timer still alive?
                    beq      singleclk@       timer expired: treat as new single click
* Double click confirmed - reset state then run enter action
                    lda      #$FF
                    sta      <dclick          reset pending click
                    clr      <dclicktmr       stop timer
                    lbsr     writelist        refresh list first so highlight is correct
                    lbsr     getattr          get file attributes (same as enter key)
                    lda      <attr
                    cmpa     #$BF             is it a directory?
                    lbeq     changedir        yes: open it
                    lbra     scrnrtn          no: open the file and exit
singleclk@          lda      <listitem        arm timer for this item
                    sta      <dclick
                    lda      #DCLICK_TIMEOUT
                    sta      <dclicktmr       arm timer
* Single click: adjust liststart if needed then redraw
                    lda   	 <liststart	      get the start of the current list
	                cmpa	 <liststartmax    if liststart is at max, don't adjust
	                beq 	 cont1@
	                adda	 #LISTMAXROWS-1   compute index of last visible row
	                cmpa	 <listitem	      is selected item on the last visible row?
	                bne 	 cont1@
	                inc 	 <liststart
cont1@	            lbsr	 writelist	      redraw list
       	            clra
	                rts

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


********************************************************************
* CurXY
*  a = cursor x - b=cursor y
CurXY          adda      #$20                 add offset $20 to x
               addb      #$20                 add offset $20 to y
               pshs      a,b                  preserve x,y  (,s=x  1,s=y)
               leas      -3,s                 reserve 3-byte buffer (,s..2,s)
               lda       #$02                 CURXY command
               sta       ,s                   buf[0]
               lda       3,s                  saved x
               sta       1,s                  buf[1]
               lda       4,s                  saved y
               sta       2,s                  buf[2]
               lda       #$01                 stdout
               ldy       #3                   send all 3 bytes at once
               tfr       s,x
               os9       I$Write
               leas      3,s                  release buffer
               puls      a,b                  restore x,y
               rts

** a=FG Color - b=BG Color
Color          pshs      a,b                  preserve FG,BG  (,s=FG  1,s=BG)
               leas      -6,s                 reserve 6-byte buffer (,s..5,s)
               lda       #$1B                 escape
               sta       ,s                   buf[0]
               lda       #$32                 foreground color option
               sta       1,s                  buf[1]
               lda       6,s                  saved FG
               sta       2,s                  buf[2]
               lda       #$1B                 escape
               sta       3,s                  buf[3]
               lda       #$33                 background color option
               sta       4,s                  buf[4]
               lda       7,s                  saved BG
               sta       5,s                  buf[5]
               lda       #$01                 stdout
               ldy       #6                   send the whole sequence at once
               tfr       s,x
               os9       I$Write
               leas      6,s                  release buffer
               puls      a,b                  restore FG,BG
               rts

SideBorderL    leas      -1,s                 reserve 1 byte for stack
               lda       <k
               cmpa      #54
               bne       cont@
               lda       #TTRC
               bra       cont2@
cont@          lda       #SBL
cont2@         sta       ,s
               lda       #$01          stdout
               ldy       #1            number of characters to print
               tfr       s,x
               os9       I$Write       end top title and border
               leas      1,s           return stack to normal
               rts

SideBorderR    leas      -1,s          reserve 1 byte for stack
               lda       <k
               cmpa      #54
               bne       cont@
               lda       #TTLC
               bra       cont2@
cont@          lda       #SBL
cont2@         sta       ,s
               lda       #$01          stdout
               ldy       #1            number of characters to print
               tfr       s,x
               os9       I$Write       end top title and border
               leas      1,s           return stack to normal
               rts

FNLoad         ldy       #0            font 0
               lda       #0
               leax      fnxfont,pcr   font to load
               ldb       #SS.FntLoadF  load font from file
               os9       I$SetStt
               bcs       error@      
               clrb
error@         rts

* Change drive to current item
getitemidx     lda      <listitem       get current list item
               lbsr 	arrayidx        refernce in x
               rts

* ldfontarr
* 
* read directory and put all the file names in array
*
*
ldfontarr
               lbsr     clrarray
               clr      <numfonts       always reload from index 0 (never append)
               lbsr     opendir	        open the directory
               ldb      <dirlevel
               cmpb     #0
               bne      loop@
        	   lbsr     seekdir 	    skip first two entries (. and ..)
loop@          lda      <numfonts       list full? stop loading before the array overflows
	           cmpa     #MAXFILES       (numfonts is a byte: 256 would wrap to 0 and
	           beq      full@            silently overwrite entries from index 0)
	           lbsr     readdir	        read next directory entry
	           bcs	    exit@
	           leay     dent,u
               lda      ,y              check for 0 deleted file
               beq      loop@
               ;leay     dent,u
	           lda      <numfonts
	           lbsr     toarr
	           inc	    <numfonts
	           bra      loop@
full@	       clrb                     at the item limit - this is NOT an error, so
	           bra      error@           clear B and skip the EOF check (numfonts stays
*                                       at MAXFILES; the rest of the directory is ignored)
exit@	       cmpb     #211	        should be an EOF here
	           bne      error@		    skip clearing b if error to preserve error msg
	           clrb
error@	       pshs     b               not error routine, preserve error code
	           lda      <numfonts       compute liststartmax = max(0, numfonts-LISTMAXROWS)
	           suba     #LISTMAXROWS    how many items beyond one windowful
	           bhi      setlsmax@       positive: there are items off-screen below
	           clra                     negative/zero: everything fits, no scrolling needed
setlsmax@      sta      <liststartmax   highest valid liststart value
	           lda	    #LISTMAXROWS    listmax = min(numfonts, LISTMAXROWS)
	           cmpa     <numfonts
	           blt      setlistlen@
	           lda      <numfonts
setlistlen@    cmpa     #LISTMAXROWS    clamp to visible window height
	           bls      storeit@
	           lda      #LISTMAXROWS    too many rows - cap at window max
storeit@       sta      <listmax
	           puls     b	            pull error code if there is one
	           lda      <dirpath
	           os9	    I$Close
	           rts

* opendir - subroutine to open selected directory
opendir	       lda	     #DIR.+READ.   directory is just a file on the disk
               ldb       <driveidx
               cmpb      #0
               bne       cont@
               ldb       <dirlevel     change directory?
               cmpb      #0
               bne       dir0@
	           leax      drive0,pcr
               lbra      dodir@
dir0@          leax      folder,u      drivecmds
               lbra      dodir@
cont@          cmpb      #1
               bne       cont2@
               ldb       <dirlevel     change directory?
               cmpb      #0
               bne       dir1@
	           leax	     drive1,pcr
               lbra      dodir@
dir1@          leax      folder,u
               lbra      dodir@
cont2@         cmpb      #2
               bne       cont3@
	           ldb       <dirlevel     change directory?
               cmpb      #0
               bne       dir2@
               leax 	 drive2,pcr
               lbra      dodir@
dir2@          leax      folder,u
               lbra      dodir@
cont3@         cmpb      #3
               bne       cont4@
               ldb       <dirlevel     change directory?
               cmpb      #0
               bne       dir3@
	           leax	     drive3,pcr
               bra       dodir@
dir3@          leax      folder,u
               bra       dodir@
cont4@         cmpb      #4
               bne       cont5@
               ldb       <dirlevel     change directory?
               cmpb      #0
               bne       dir4@
	           leax	     drive4,pcr
               bra       dodir@
dir4@          leax      folder,u
               bra       dodir@
cont5@         cmpb      #5
               bne       cont6@
	           ldb       <dirlevel     change directory?
               cmpb      #0
               bne       dir5@
               leax	     drive5,pcr
               bra       dodir@
dir5@          leax      folder,u
               bra       dodir@
cont6@         cmpb      #6
               bne       cont7@
               ldb       <dirlevel
               cmpb      #0
               bne       dir6@
               leax      drive6,pcr
               bra       dodir@
dir6@          leax      folder,u
               bra       dodir@
cont7@         cmpb      #7
               bne       cont8@
               ldb       <dirlevel
               cmpb      #0
               bne       dir7@
               leax      drive7,pcr
               bra       dodir@
dir7@          leax      folder,u
               bra       dodir@
cont8@         cmpb      #8
               bne       done@
               ldb       <dirlevel
               cmpb      #0
               bne       dir8@
               leax      drive8,pcr
               bra       dodir@
dir8@          leax      folder,u
               bra       dodir@
done@          leax      fontdir,pcr
dodir@	       pshs      x,a
	           os9	     I$Open
	           sta	     <dirpath
	           puls 	 x,a
	           os9	     I$ChgDir
	           rts

* seekdir - subroutine to skip first 2 directory entries (. and ..)
seekdir	       lda       <dirpath
               ldx       #$0000
               pshs      u
               ldu       #DIR.SZ*2	   skip the first two entries
               os9       I$Seek		   which are . and ..	
               puls      u
	           rts

*readdir - subroutine to read next directory entry
readdir	       leax      dent,u
               lda       #32
loop@	       deca
	           clr	      a,x
	           bne	      loop@
	           ldy	      #DIR.SZ	   each dir entry is 32 bytes, filename is first 29
	           lda	      <dirpath     name is terminated with high bit set
               leax 	  dent,u
	           os9	      I$Read
	           rts

clrarray       pshs      u,x,y
	           leax      fntarray,u
	           ldu       #$2020
               ldy       #8000         #3720         120 * 29 + 120 * 2 length
loop@          stu       ,x++
	           leay      -2,y
	           bne       loop@
	           puls      u,x,y,pc

* Puts string at y into file arrray at index a
* store string length in first two byts of array item
toarr          pshs      a,x
               bsr       arrayidx      put array index a addr in x
	           pshs      x		       store start address on stack
	           leas      -2,s		   add stack space for string count
	           clr   	 ,s	    	   clear it to 0
	           clr	     1,s
	           leax      2,x		   reserve place in array string for length
arrloop@       lda       ,y		       load char from string
	           anda      #$7F		   strip terminating high bit, if there
               sta       ,x+		   put into array
	           inc	     1,s		   increment string count
               tst       ,y+           test for the high bit, but don't overwrite
               bpl       arrloop@      need the high bit on output
	           puls      x,y		   pull length and string start
	           stx       ,y		       store string length in two byte of array item
               puls      a,x,pc

* calc array item address in x from index a
* multiply 31*index to get offset using math co-processor
* each array entry is 29 bytes (filename) + 2 bytes (length prefix) = 31 bytes
* destroys x
arrayidx       pshs      d,cc
	           orcc      #IntMasks     mask interrups to avoid copro collisions
               sta       $FEE1		   low bit in math copro
               clr       $FEE0		   high bit in math copro
               lda       #31		   multiple by 31, len of row
               sta       $FEE3		   low bit in math copro
               clr       $FEE2		   high bit in math copro
	           ldd       $FEF2
               leax      fntarray,u	   load address of array
               leax      d,x		   add offset
               puls      d,cc,pc	   return

* calc array item address in x from index a
* multiply 31*index to get offset using math co-processor
* each array entry is 29 bytes (filename) + 2 bytes (length prefix) = 31 bytes
* NOTE: identical to arrayidx - use arrayidx for new code
* destroys x
arrayidx2      pshs      d,cc
	           orcc      #IntMasks     mask interrups to avoid copro collisions
               sta       $FEE1		   low bit in math copro
               clr       $FEE0		   high bit in math copro
               lda       #31		   multiple by 31, len of row
               sta       $FEE3		   low bit in math copro
               clr       $FEE2		   high bit in math copro
	           ldd       $FEF2
               leax      fntarray,u	   load address of array
               leax      d,x		   add offset
done@          puls      d,cc,pc	   return

********************************************************************
* vtio commands to control cursor/video
*
* clearscreen
* writes $0C control code to terminal to clear screen
*
* cursoroff
* writes $0520 control code to terminal to turn off cursor
*
* cursoron
* writes $0521 control code to terminal to turn off cursor
*
* Write Reverse Video On
* Turns on reverse video to highlight characters
*
* Write Reverse Video Off
* Turns off reverse video
*
clearscreen    leax	 cmdclrscreen,pcr
	           ldy	 #1
	           bra	 engage@
cursoroff      leax	 cmdcursoroff,pcr
	           ldy	 #2
	           bra	 engage@
cursoron       leax	 cmdcursoron,pcr
	           ldy	 #2
	           bra	 engage@
writerevon     leax	 cmdrevvidon,pcr
	           ldy	 #2
	           bra	 engage@
writerevoff    leax	 cmdrevvidoff,pcr
	           ldy	 #2
engage@	       pshs	 a
	           lda	 #1
	           os9	 I$Write
	           puls      a,pc

cmdclrscreen   fcb	 $0C          clear screen
cmdcursoroff   fcb	 $05,$20	  cursor off
cmdcursoron    fcb	 $05,$21	  cursor on
cmdrevvidon    fcb	 $1F,$20	  reverse video on
cmdrevvidoff   fcb	 $1F,$21	  reverse video off
font0on	       fcb	 $1B,$62      switch to font0


********************************************************************
* writelist
* updates list box
* write up to LISTMAXROWS (48) items from the array into the list window
* list window occupies y=4 to y=51, border at y=52
* colors: normal items    = TXT ($01) on TXTBG ($00) = white on black
*         selected item   = TXTSEL ($01) on TXTSELBG ($02)
* NOTE: explicit Color calls used instead of writerevon/writerevoff because
*       $1F $21 (rev off) restores terminal default BG=$06 (blue) from ScrnInit
*
writelist           leas	 -4,s		add to stack to store x,y coordinates
	                lda 	 #$02
	                sta 	 ,s	        Cursor XY Command
	                lda	     #$25
	                sta  	 1,s		x coordinate
	                lda 	 #$24
	                sta 	 2,s	    y coordinate
	                clr 	 3,s	    list counter (rows drawn so far)
	                lda	     <liststart	initialize array item index to liststart
loop@	            cmpa	 <numfonts	stop if we've run past the last real item
	                bhs	     wrldone@
	                pshs	 a
	                cmpa	 <listitem   selected item?
	                bne 	 norev@
	                lda      #TXTSEL     yes: highlight colors
	                ldb      #TXTSELBG
	                lbsr     Color
	                bra      dopos@
norev@	            lda      #TXT        normal colors
	                ldb      #TXTBG
	                lbsr     Color
dopos@	            lda 	 #1
	                leax	 1,s
	                ldy 	 #3
	                os9	     I$Write
	                puls	 a
	                lbsr	 arrayidx2
	                ldy	     #29
	                leax	 2,x         advance past 2 byte string len
	                pshs     a
	                lda	     #1
	                os9	     I$Write
	                puls     a           a = item index
	                pshs     a           save item index - Color destroys A
	                lda      #TXT        restore normal colors after every row
	                ldb      #TXTBG
	                lbsr     Color
	                puls     a           restore item index
norev2@	            inc	     2,s
	                inc	     3,s
	                inca
	                ldb	     3,s
                    stb      <listloop
	                cmpb     <listmax
	                bne	     loop@
wrldone@            leas	 4,s
                    lbsr     clrlistrows clear any leftover rows below the list
                    lbsr     showitem
	                rts

********************************************************************
* clrlistrows
* after writelist finishes, blank out any rows between the end of
* the new (shorter) list and LISTMAXROWS so old filenames don't bleed through
* called with stack already restored (leas 4,s done before call)
*
clrlistrows         pshs      a,b,x,y
                    lda       <listloop       last row written (0-based count)
                    cmpa      #LISTMAXROWS    if we filled the window nothing to clear
                    bhs       clrdone@
                    lda       <listloop       start clearing from the row after last item
clrloop@            cmpa      #LISTMAXROWS    done when we reach the window limit
                    bhs       clrdone@
* position cursor: raw coords, same encoding as writelist stack frame
* x pre-offset = $25 (col 5), y pre-offset = $24 + row
                    pshs      a
                    lda       #$02            CurXY command byte
                    lbsr      byte1scrn
                    lda       #$25            x pre-offset (col 5)
                    lbsr      byte1scrn
                    puls      a
                    pshs      a
                    adda      #$24            add y base offset
                    lbsr      byte1scrn       send y
* write 29 spaces to blank the row
                    lda       #1              stdout
                    leax      BlankItem,pcr
                    ldy       #29
                    os9       I$Write
                    puls      a
                    inca
                    bra       clrloop@
clrdone@            puls      a,b,x,y
                    rts

********************************************************************
* Ctrl+Up / Ctrl+Down paging
*
* The keyboard dispatch sends the up ($0C) and down ($0A) arrows here.
* If Ctrl is held we page the list by one windowful; otherwise we fall
* through to the normal one-row uparrow / downarrow2 handlers.
*
* ctrlpressed - read the keyboard-sense byte; returns Z=0 if Ctrl is held
* (bita leaves the flags), Z=1 if not. Same test hexed uses.
*
ctrlpressed         lda       #0               path 0 (stdin)
                    ldb       #SS.KySns
                    os9       I$GetStt         A = key-sense bits
                    bita      #CNTLBIT
                    rts
chkup               lbsr      ctrlpressed
                    lbne      pageup           Ctrl held -> page up
                    lbra      uparrow          plain arrow -> move one row
chkdown             lbsr      ctrlpressed
                    lbne      pagedn           Ctrl held -> page down
                    lbra      downarrow2       plain arrow -> move one row
*
* pageup - shift the window and cursor up by one windowful, clamped at the
* top. liststart and listitem both drop by LISTMAXROWS (0 if that would go
* negative), which keeps the selected row visible in the new window.
*
pageup              lda       <numfonts        empty list? nothing to do
                    beq       pgnone@
                    lda       <liststart       liststart = max(liststart-page, 0)
                    suba      #LISTMAXROWS
                    bcc       pu1@
                    clra
pu1@                sta       <liststart
                    lda       <listitem        listitem = max(listitem-page, 0)
                    suba      #LISTMAXROWS
                    bcc       pu2@
                    clra
pu2@                sta       <listitem
                    lbsr      writelist        redraw the window
                    lbsr      showitem         update the bottom preview
pgnone@             clra
                    rts
*
* pagedn - shift the window and cursor down by one windowful. liststart is
* clamped to liststartmax (highest valid top-of-window) and listitem to
* numfonts-1 (last item); moving both by the same page keeps the cursor
* inside the window.
*
pagedn              lda       <numfonts        empty list? nothing to do
                    beq       pgnone2@
                    lda       <liststart       liststart = min(liststart+page, liststartmax)
                    adda      #LISTMAXROWS      liststart<=liststartmax, so no byte overflow
                    cmpa      <liststartmax
                    bls       pd1@
                    lda       <liststartmax
pd1@                sta       <liststart
                    lda       <listitem        listitem = min(listitem+page, numfonts-1)
                    adda      #LISTMAXROWS
                    bcs       pd2@             byte overflow -> clamp to last item
                    cmpa      <numfonts
                    blo       pd3@             already a valid index (< numfonts)
pd2@                lda       <numfonts
                    deca                       last index = numfonts-1
pd3@                sta       <listitem
                    lbsr      writelist        redraw the window
                    lbsr      showitem         update the bottom preview
pgnone2@            clra
                    rts

********************************************************************
* listbox uparrow
* update interface
*
* Scroll logic:
*   if selected item is at the top of the visible window (listitem==liststart)
*   and liststart > 0, scroll the window up by 1 before moving the cursor
*
uparrow	            lda       <listitem        at item 0?
	                beq	      none@            nothing above - do nothing
	                lda       <liststart	   liststart=0?
	                beq	      noscroll@        can't scroll, just move cursor within window
	                cmpa	  <listitem	       is selected item at the top of the window?
	                bne	      noscroll@        no: move within window (two rows change)
* scroll case: whole window content shifts, must full-redraw
	                dec	      <liststart	   scroll window up by 1
	                dec	      <listitem	       move cursor up by 1
	                lbsr	  writelist	       write the new list to the screen
	                clra
	                rts
* no-scroll case: only the old and new selected rows change
noscroll@           lda       <listitem        old selected row index
                    dec       <listitem        new selected row
                    lbsr      drawrow          old row -> normal colors
                    lda       <listitem
                    lbsr      drawrow          new row -> highlight
                    lbsr      showitem         update bottom preview
                    clra
                    rts
none@               clra
                    rts

********************************************************************
* listbox downarrow
* update interface and load new font1
* signals need to be muted while loading to avoid interface flicker
*
* Scroll logic:
*   liststart = index of first visible item
*   listitem  = index of currently selected item
*   visible window = liststart .. liststart+LISTMAXROWS-1
*   when listitem moves past the last visible row, advance liststart by 1
*
downarrow2          lda   	 <listitem
	                inca			           would move past last item?
	                cmpa	 <numfonts
	                bhs 	 none@		       at end: do nothing (bhs = unsigned; bge broke at numfonts>=128)
* determine whether the window must scroll (same condition as before)
	                lda   	 <liststart	       get the start of the current list
	                cmpa	 <liststartmax     if liststart is at max, no more scrolling down
	                beq 	 noscroll@         can't scroll: move within window
	                adda	 #LISTMAXROWS-1    compute index of last visible row
	                cmpa	 <listitem	       is selected item on the last visible row?
	                bne 	 noscroll@         no: move within window (two rows change)
* scroll case: whole window content shifts, must full-redraw
	                inc 	 <liststart	       scroll window down by 1
	                inc 	 <listitem	       move cursor down by 1
	                lbsr	 writelist	       redraw list in listbox
	                clra
	                rts
* no-scroll case: only the old and new selected rows change
noscroll@           lda   	 <listitem        old selected row index
                    inc   	 <listitem        new selected row
                    lbsr  	 drawrow          old row -> normal colors
                    lda   	 <listitem
                    lbsr  	 drawrow          new row -> highlight
                    lbsr  	 showitem         update bottom preview
                    clra
                    rts
none@               clra
                    rts

********************************************************************
* drawrow - redraw ONE list row in place (no full-list redraw)
* entry: A = item index, must be a real item (< numfonts) AND
*            currently visible (liststart <= A < liststart+listmax)
* highlights the row if A == listitem, else normal colors
* leaves terminal color state = normal (TXT/TXTBG), like writelist
*
drawrow             pshs     a               save item index
* position cursor: col 5, row = $24 + (item - liststart)  (raw bytes, as writelist)
                    suba     <liststart      A = 0-based row within window
                    adda     #$24            y pre-offset (row 4 = list top)
                    pshs     a               save y byte
                    lda      #$02            CurXY command
                    lbsr     byte1scrn
                    lda      #$25            x pre-offset = col 5
                    lbsr     byte1scrn
                    puls     a               y byte
                    lbsr     byte1scrn
* choose colors based on whether this is the selected item
                    lda      ,s              peek saved item index
                    cmpa     <listitem
                    bne      norm@
                    lda      #TXTSEL         selected: highlight
                    ldb      #TXTSELBG
                    bra      setcol@
norm@               lda      #TXT            normal
                    ldb      #TXTBG
setcol@             lbsr     Color
* write the 29-char filename
                    puls     a               item index
                    lbsr     arrayidx2       X -> array entry for item A
                    leax     2,x             skip 2-byte length prefix
                    ldy      #29
                    lda      #1              stdout
                    os9      I$Write
* restore normal colors
                    lda      #TXT
                    ldb      #TXTBG
                    lbsr     Color
                    rts

********************************************************************
* show the select file at bottom of screen under selected field
*
showitem            pshs     x,y,u
                    lda      <opensave
                    cmpa     #0
                    bne      skipitem
                    lda      #5
                    ldb      #56
                    lbsr     CurXY
                    lda      #TXTSEL          highlight colors for preview bar
                    ldb      #TXTSELBG
                    lbsr     Color
                    lda      <listitem
                    lbsr	 arrayidx
                    bra      cont@
skipitem            puls     x,y,u
                    rts
cont@               ldy	     #29
	                leax	 2,x         advance past 2 byte string len
	                lda	     #1
	                os9	     I$Write
                    lda      #TXT             restore normal colors
                    ldb      #TXTBG
                    lbsr     Color
                    puls     x,y,u
                    rts

********************************************************************
* getopts
* get current options
* SS.Opt is used to determime current settings for editing function
* such as echo and key off. It reads option section of Path Descriptor.
* Need to use this here to turn off key echo so keypresses won't
* echo to screen.
*
* This is used in conjunctuion with keyecho on/off routines
*
getopts             leax      >popts,u
                    ldb       #SS.Opt
                    clra
                    os9       I$GetStt
                    rts

********************************************************************
* reterm - re-apply the FM terminal mode after a forked program (or the
* image viewer) may have changed it: echo off (opt 4), Ctrl-E/quit off
* (17), keyboard interrupt off (16). Clearing 16 when it is already off
* is a no-op, so this is safe for callers that did not clear it before.
*
reterm              lbsr      getopts            read current device options
                    leax      >popts,u
                    clr       4,x                echo off
                    clr       17,x               Ctrl-E (quit) off so it reaches the FM
                    clr       16,x               keyboard interrupt off
                    clra
                    ldb       #SS.Opt
                    os9       I$SetStt
                    rts

keyechooff          leax      >popts,u
                    clr       4,x
                    clra
                    ldb       #SS.Opt
                    os9       I$SetStt
                    rts

keyechoon           leax      >popts,u
                    lda       #1
                    sta       4,x
                    clra
                    ldb       #SS.Opt
                    os9       I$SetStt
                    rts

********************************************************************
* breakoff - disable the keyboard interrupt char (Ctrl-C) on stdin so
* it is delivered as a normal $03 key instead of aborting the program.
* PD.INT is option offset 16 (sg_kbich), same option buffer as echo (4).
* Saves the original char so it can be restored on exit.
* Call AFTER getopts has populated popts.
*
breakoff            leax      >popts,u
                    lda       16,x               current Ctrl-C interrupt char
                    sta       savedint,u         remember it for restore
                    clr       16,x               disable keyboard interrupt
                    lda       17,x               current Ctrl-E quit char
                    sta       savedqut,u         remember it for restore
                    clr       17,x               disable keyboard quit (Ctrl-E escape)
                    clra
                    ldb       #SS.Opt
                    os9       I$SetStt
                    rts

********************************************************************
* breakon - restore the keyboard interrupt char (Ctrl-C) saved by
* breakoff. Must run on every exit so the shell keeps Ctrl-C (the
* path descriptor is shared with the parent).
*
breakon             leax      >popts,u
                    lda       savedint,u         restore saved Ctrl-C interrupt char
                    sta       16,x
                    lda       savedqut,u         restore saved Ctrl-E quit char
                    sta       17,x
                    clra
                    ldb       #SS.Opt
                    os9       I$SetStt
                    rts

********************************************************************
* Mouse
* Entry: B= #SS.Mouse
*
* Exit: A=Button State
*       X=X Pos
*       Y=Y Pos
*       CC=Carry flag clear success
Mouse               pshs      x,y
                    ldb       #SS.Mouse
                    clra
                    os9       I$GetStt
                    bcs       error@
                    sta       <btn
                    sta       valtoascii,u
                    stx       <x
                    sty       <y
error@              puls      x,y
                    rts


DECTAB$:            fdb       10000,1000,100,10,1,0
                    fcb       $FF

********************************************************************
* installchars
* installs drawing characters into the current font
* this ensures the screen looks the same no matter
* which font is in font0
*
installchars       ldb	      #13
        	       pshs       b
	               leax       oldchars,u  
	               ldy	      #242
loop@	           lda	      #0
	               ldb	      #SS.FntChar
	               os9        I$GetStt
	               bcs	      exit@
	               leax       8,x
	               leay       1,y
	               dec	      ,s
	               bne	      loop@
                   ldb	      #13
;                   pshs       b                   *
	               stb	      ,s
	               leax       topleftbc,pcr
	               ldy	      #242
loop2@	           lda	      #0
	               ldb	      #SS.FntChar
	               os9	      I$SetStt
	               bcs	      exit@
	               leax       8,x
	               leay       1,y
	               dec	      ,s
	               bne        loop2@
exit@	           puls       b,pc

********************************************************************
* restorechars
* if the user exits without making changes, remove
* replace the drawing character with the original
* font characters
*
restorchars        pshs      a,b,x,y,u
                   ldb  	 #13
	               stb  	 ,s
	               leax      oldchars,u
	               ldy  	 #242
loop@	           lda  	 #0
	               ldb  	 #SS.FntChar
	               os9  	 I$SetStt
	               bcs  	 exit@
	               leax      8,x
	               leay      1,y
	               dec  	 ,s
	               bne       loop@
exit@	           puls      a,b,x,y,u,pc		    



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
                    ldx       <bufstrt      address of data to write
                    stx       <bufcur       reset output buffer pointer, ready for next line.
                    ldy       #80           maximum # of bytes - otherwise, stop at CR
                    lda       #$01          to STDOUT
                    os9       I$WritLn
                    puls      pc,y,x,a

; write 1 byte in a to screen
byte1scrn           leas      -1,s          reserve 1 byte for stack
                    sta       ,s
                    lda       #$01          stdout
                    ldy       #1            number of characters to print
                    tfr       s,x
                    os9       I$Write
                    leas      1,s           return stack to normal
                    rts

**In the File Selector (child process):** assembly
* Open the existing pipe for writing
;dopipe              leax    pipename,pcr   same pipe name
;                    lda     #WRITE.        open for writing
;                    os9     I$Open
;                    bcs     writeerror
;                    sta     <pipepath
* Send result back through pipe
dopipe              clra
                    ldb     <finallen
                    tfr     d,y             put length in Y
                    lda     #2
                    leax    finalpath,u     either filename or cancel code
                    os9     I$WritLn
                    bcs     writeerror
* Close pipe and exit
;                    lda     #2              <pipepath
;                    os9     I$Close
                    clrb                    no error - length in b
                    lbsr    setscreen
                    os9     F$Exit          terminate child process
* write pipe error
writeerror          os9     F$PErr          print error
                    ldb     #1              error code      
                    os9     F$Exit          terminate child process

** get screen size
getscrnsz           pshs    a,b,x,y,u,cc
                    lda     #1	            get current screentype	
	                ldb     #SS.ScTyp
                    sta     <ssize          save screen size
** now fg/gb settings
                    lda       #0			load current fg and bd colors
	                ldb	      #SS.FBRgs		initialize old and new fg and bg to current colors
	                os9       I$GetStt		SS.FBRgs returns FG and BG in 1 byte
	                pshs      a		
	                anda      #$0F			bg color in low 4 bits. mask high bits
	                sta       <oldbg		initialize bg vars with current bg
	                puls      a 			pull current colors
	                lsra	 			    shift right x4 to get current fg color     
	                lsra
	                lsra
	                lsra
	                sta	      <oldfg        initialize current fg color with
                    puls    a,b,x,y,u,cc,pc

DoPlay              pshs      x,y,u,b,a
                    clra
                    ldb       <finallen
                    tfr       d,y
                    leax      >PlayCMD,pcr
                    leau      finalpath,u
                    ldd       #$0100
                    os9       F$Fork
                    bcs       restorestack  fork failed
*                   os9       F$Wait        do not wait on entire song to play
restorestack        puls      x,y,u,b,a,pc

DoTE                pshs      x,y,u,b,a
                    clra
                    ldb       <finallen
                    tfr       d,y
                    leax      >TECMD,pcr
                    leau      finalpath,u
                    ldd       #$0100
                    os9       F$Fork
                    bcs       restorestack2  fork failed
                    os9       F$Wait
restorestack2       puls      x,y,u,b,a,pc

DoView              pshs      x,y,u,b,a
                    clra
                    ldb       <finallen
                    tfr       d,y
                    leax      >VIEWCMD,pcr
                    leau      finalpath,u
                    ldd       #$0100
                    os9       F$Fork
                    bcs       restorestack3  fork failed
                    os9       F$Wait
restorestack3       puls      x,y,u,b,a,pc

DoSCFG              pshs      x,y,u,b,a
                    clra
                    ldb       <finallen
                    tfr       d,y
                    leax      >SCFGCMD,pcr
                    leau      >SCFGOPT,u
                    ldd       #$0100
                    os9       F$Fork
                    bcs       restorestack4  fork failed
                    os9       F$Wait
restorestack4       puls      x,y,u,b,a,pc

DoCMD               pshs      x,y,u,b,a
                    clra
                    ldb       <finallen
                    tfr       d,y
                    leax      finalpath,u
                    leau      >SCFGOPT,u
                    ldd       #$0100
                    os9       F$Fork
                    bcs       restorestack5  fork failed
                    os9       F$Wait
restorestack5       puls      x,y,u,b,a,pc

DoHex               pshs      x,y,u,b,a
                    clra
                    ldb       <finallen
                    tfr       d,y
                    leax      >HEXCMD,pcr
                    leau      finalpath,u
                    ldd       #$0100
                    os9       F$Fork
                    bcs       restorestack6  fork failed
                    os9       F$Wait
restorestack6       puls      x,y,u,b,a,pc

* DoPixV - fork /dd/cmds/pixview on the selected file (finalpath). pixview
* is a standalone program now: it owns the bitmap/CLUT/graphics work and
* exits when the user presses space, so the FM just forks and waits.
DoPixV              pshs      x,y,u,b,a
                    clra
                    ldb       <finallen
                    tfr       d,y
                    leax      >PIXVCMD,pcr
                    leau      finalpath,u
                    ldd       #$0100
                    os9       F$Fork
                    bcs       restorestackPV fork failed
                    os9       F$Wait
restorestackPV      puls      x,y,u,b,a,pc

DoDel               pshs      x,y,u,b,a
                    clra
                    ldb       <finallen
                    tfr       d,y
                    leax      >DELCMD,pcr
                    leau      finalpath,u
                    ldd       #$0100
                    os9       F$Fork
                    bcs       restorestackD  fork failed
                    os9       F$Wait
restorestackD       puls      x,y,u,b,a,pc

DoMakDir            pshs      a,b,x,y,u
                    clra
                    ldb       <finallen
                    tfr       d,y
                    leax      >MAKDIRCMD,pcr
                    leau      finalpath,u
                    ldd       #$0100
                    os9       F$Fork
                    bcs       dmkbad@        fork failed
                    os9       F$Wait         B = child exit status
                    tstb
                    bne       dmkbad@        non-zero = makdir failed (OS-9 shows it)
                    puls      a,b,x,y,u
                    andcc     #$FE           clear carry = success
                    rts
dmkbad@             puls      a,b,x,y,u
                    orcc      #$01           set carry = failure
                    rts

DoBF                pshs      x,y,u,b,a
                    clra
                    ldb       <finallen
                    tfr       d,y
                    leax      >BFCMD,pcr
                    leau      finalpath,u
                    ldd       #$0100
                    os9       F$Fork
                    bcs       restorestack8  fork failed
                    os9       F$Wait
restorestack8       puls      x,y,u,b,a,pc

DoDate              pshs      x,y,u,b,a
                    clra
                    ldb       <finallen
                    tfr       d,y
                    leax      >DATECMD,pcr
                    leau      >SCFGOPT,u
                    ldd       #$0100
                    os9       F$Fork
                    bcs       restorestack9  fork failed
                    os9       F$Wait
restorestack9       puls      x,y,u,b,a,pc

********************************************************************
* DoCopyR - fork /dd/cmds/copy with the "SOURCE DEST"+CR line already in
* pastebuf (pastelen), wait, and report the result: carry clear if copy
* succeeded, carry set if the fork failed or copy exited non-zero.
DoCopyR             pshs      a,b,x,y,u
                    clra
                    ldb       pastelen,u
                    tfr       d,y                Y = parameter length
                    leax      >COPYCMD,pcr
                    leau      pastebuf,u         U = parameter (clobbers data base)
                    ldd       #$0100
                    os9       F$Fork
                    bcs       dcrbad@            fork failed
                    os9       F$Wait             B = child exit status
					tstb
                    bne       dcrbad@            non-zero = copy failed (OS-9 shows it)
                    puls      a,b,x,y,u          (restores data base U)
                    andcc     #$FE               clear carry = success
                    rts
dcrbad@             puls      a,b,x,y,u          (restores data base U)
                    orcc      #$01               set carry = failure
                    rts

DoATTR              pshs      x,y,u,b,a
                    lda       #37
                    ldb       #56
                    lbsr      CurXY
                    lda       #TXT
                    ldb       #TXTBG
                    lbsr      Color
                    clra
                    ldb       <finallen
                    tfr       d,y
                    leax      >ATTRCMD,pcr
                    leau      finalpath,u
                    ldd       #$0100
                    os9       F$Fork
                    bcs       restorestack7    fork failed
                    os9       F$Wait
restorestack7       puls      x,y,u,b,a,pc

DoHelp2             pshs      x,y,u,b,a
                    lda      <listitem         get selected file item
                    lbsr	 arrayidx
                    leax	 2,x               advance past 2 byte string len
                    tfr      x,u
                    clra
                    ldb       <finallen
                    tfr       d,y
                    leax      >HELPCMD,pcr
                    ;leau      finalpath,u
                    ldd       #$0100
                    os9       F$Fork
                    bcs       restorestack10 fork failed
                    os9       F$Wait
restorestack10      puls      x,y,u,b,a,pc

CheckType           pshs      x,y,u,a,b
                    leax      finalpath,u        get finalpath
                    lda       <finallen          advance to end of string
                    leax      a,x
                    leax      -5,x               move back to .ext includes 1 byte for $0d
                    clr       <FileType          no filetype set
                    lda       ,x
                    cmpa      #C$CR
                    lbeq      o@                 bye
b@                  leay      FILETYPES,pcr
d@                  lda       ,x                 Get 1st char of sliding window of ".ext"
                    lbeq      o@
                    cmpa      #32
                    lbeq      o@
                    cmpa      #C$CR
                    lbeq      o@
                    cmpa      ,y                 Compare 1st char against current table entry
                    lbne      n@
                    lda       1,x
                    lbsr      toLower
                    cmpa      1,y                Compare 2nd char
                    lbne      n@
                    lda       2,x
                    lbsr      toLower
                    cmpa      2,y                Compare 3rd char
                    lbne      n@
                    lda       3,x
                    lbsr      toLower
                    cmpa      3,y                Compare 4th char
                    lbne      n@
                    lda       4,y
                    sta       <FileType
                    lbra      o@
n@                  leay      5,y
                    ldb       ,y
                    lbne      d@
* extension scan complete - if FileType still 0 try keyword suffix match
                    lda       <FileType
                    lbne      o@                  extension matched, done
* KEYWORDS table format: length(1) + keyword chars(n) + filetype(1), $00 = end
                    leay      KEYWORDS,pcr
kw@                 ldb       ,y                  keyword length (0 = end of table)
                    lbeq      fld@                no more keywords - try folder check
* compute X = start of finalpath + finallen - 1($0D) - keyword_length
* so X points at where the keyword would begin if it's a suffix
                    pshs      b,y                 save length and table pointer
                    leax      finalpath,u
                    lda       <finallen
                    leax      a,x                 X = one past $0D
                    leax      -1,x                X = at $0D
                    clra
                    negb                          negate keyword length
                    leax      b,x                 X = start of keyword in path
* compare keyword (Y+1..Y+len) against path at X, B iterations
                    pshs      b,y                 save again for mismatch recovery
                    leay      1,y                 step Y past length byte to keyword chars
                    ldb       3,s                 reload length from outer pshs (b,y = 3 bytes)
kwcmp@              lda       ,x+                 path char
                    lbsr      toLower
                    cmpa      ,y+                 keyword char
                    lbne      kwno@               mismatch
                    decb
                    lbne      kwcmp@
* full match - filetype byte is now at ,y
                    lda       ,y
                    sta       <FileType
                    leas      6,s                 discard both pshs b,y (2 x 3 bytes = 6)
                    lbra      o@
kwno@               leas      3,s                 discard inner pshs b,y (3 bytes: B+Y)
                    puls      b,y                 restore outer: B=length, Y=entry start
* advance Y to next entry: 1(length) + B(keyword) + 1(filetype)
                    leay      1,y                 skip length byte
                    leay      b,y                 skip keyword chars
                    leay      1,y                 skip filetype byte
                    lbra      kw@
* keyword scan found nothing - try folder name match
* if current folder name matches a FOLDERTYPE entry, all files in it
* get that filetype regardless of filename/extension
fld@                lda       <FileType
                    lbne      o@                  already matched, done
                    lda       <dirlevel           at root? folder name is meaningless
                    lbeq      o@
                    leay      FOLDERTYPE,pcr
ft@                 ldb       ,y                  folder name length (0=end of table)
                    lbeq      o@
                    pshs      b,y                 save length and table pointer (Y=entry start)
                    leax      folder,u            point to current folder name
                    leay      1,y                 step Y past length byte to name chars
ftcmp@              lda       ,x+                 folder char
                    lbsr      toLower
                    cmpa      ,y+                 table char
                    lbne      ftno@               mismatch
                    decb
                    lbne      ftcmp@
* full folder match - filetype byte at ,y
                    lda       ,y
                    sta       <FileType
                    leas      3,s                 discard pshs b,y (3 bytes)
                    lbra      o@
ftno@               puls      b,y                 restore B=length, Y=entry start
* advance Y to next entry from entry START: 1(length) + B(name) + 1(filetype)
                    leay      1,y                 skip length byte
                    leay      b,y                 skip folder name chars
                    leay      1,y                 skip filetype byte
                    lbra      ft@
o@                  puls      x,y,u,a,b,pc
bye                 lbsr      setscreen
                    os9       F$Exit


********************************************************************
* Convert Alpha Char to Lowercase
*
toLower             cmpa      #'A
                    blo       x@
                    cmpa      #'Z
                    bhi       x@
                    ora       #32
x@                  rts

getscreen           pshs      a,b,x,y,u
                    ldb       $FFC0               get screen settings
                    stb       >gfxset
                    ldx       #$01                text only
                    ldy       #FT_OMIT            Don't change $FFC1
                    lda       #$01                Path #
                    ldb       #SS.DScrn           Display Screen with new settings 
                    os9       I$SetStt
                    puls      a,b,x,y,u,pc

setscreen           pshs      a,b,x,y,u
                    clra
                    ldb       >gfxset
                    tfr       d,x                 restore callers screen settings
                    ldy       #FT_OMIT            Don't change $FFC1
                    lda       #$01                Path #
                    ldb       #SS.DScrn           Display Screen with new settings 
                    os9       I$SetStt 
                    puls      a,b,x,y,u,pc

* static data
ScrnInit            fcb       $05,$20,$1B,$20,$04,$00,$00,$00,$00,FG,BG,$00,$0C         curoff setdw clear
ScrnInitLen         equ       *-ScrnInit
ScrnExit            fcb       $05,$21,$1b,$32,$01,$1b,$33,$06,$0C                       curon clear
ScrnExitLen         equ       *-ScrnExit
Title               fcb       TTLC,$20,$46,$49,$4C,$45,$20,$4D,$41,$4E,$41,$47
                    fcb       $45,$52,$20,TTRC
TitleLen            equ       *-Title
TopLine             fcb       TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL
                    fcb       TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL
TopLineLen          equ       *-TopLine
Selected            fcb       TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TTLC,$20,$53,$45,$4C,$45,$43,$54,$45,$44,$20,TTRC
SelectedLen         equ       *-Selected
SFilename           fcb       TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TTLC,$20,$46,$49,$4C,$45,$4E,$41,$4D,$45,$20,TTRC
SFileLen            equ       *-SFilename
OpenLn              fcb       $20,$20,$4F,$50,$45,$4E,$20,$20
OpenLnLen           equ       *-OpenLn
SaveLn              fcb       $20,$20,$53,$41,$56,$45,$20,$20
SaveLnLen           equ       *-SaveLn
CancelLn            fcb       $20,$20,$43,$41,$4E,$43,$45,$4C,$20,$20
CancelLnLen         equ       *-CancelLn
DriveLn             fcb       $44,$52,$49,$56,$45,$3A,$20,$2F,$44,$44,$20
DriveLnLen          equ       *-DriveLn
DrvLst              fcb       $20,$2F,$44,$44,$20,$2F,$53,$30,$20,$2F,$58,$30,$20,$2F,$58,$31
                    fcb       $20,$2F,$58,$32,$20,$2F,$58,$33,$20,$2F,$53,$31,$20,$2F,$43,$30,$20,$2F,$46,$30,$20
DrvLstLen           equ       *-DrvLst
AttrLn              fcb       TTLC,$20,$41,$54,$54,$52,$20,TTRC
AttrLnLen           equ       *-AttrLn
Line12              fcb       TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL
Line12Len           equ       *-Line12
Line2               fcb       TBL,TBL
Line2Len            equ       *-Line2
Line3               fcb       TBL,TBL,TBL
Line3Len            equ       *-Line3
Line4               fcb       TBL,TBL,TBL,TBL
Line4Len            equ       *-Line4
fnxfont             fcs       !/DD/SYS/FONTS/PHOENIXEGAFONT.SB!
                    fcb       $0D
fontdir	            fcc       "/dd/cmds"
                    fcb	      $0D
drive0              fcc       "/DD"
                    fcb       $0D
drive1              fcc       "/S0"
                    fcb       $0D
drive2              fcc       "/X0"
                    fcb       $0D
drive3              fcc       "/X1"
                    fcb       $0D
drive4              fcc       "/X2"
                    fcb       $0D
drive5              fcc       "/X3"
                    fcb       $0D
drive6              fcc       "/S1"
                    fcb       $0D
drive7              fcc       "/C0"
                    fcb       $0D
drive8              fcc       "/F0"
                    fcb       $0D
drivecmds           fcc       "cmds"
                    fcb       $0D
HelpSel             fcb       $20,$20,$20,$20,$20,$55,$73,$65,$20,$1C,UPAR,$20,$26,$20,$1C,DNAR,$20,$41
                    fcb       $72,$72,$6F,$77,$73,$20,$74,$6f,$20,$73,$65,$6C,$65,$63,$74,$20,$66,$69,$6C,$65,$20
HelpSelLen          equ       *-HelpSel 
HelpSave            fcb       $20,$20,$20,$20,$20,$55,$73,$65,$20,$1C,UPAR,$20,$26,$20,$1C,DNAR,$20,$41
                    fcb       $72,$72,$6F,$77,$73,$20,$74,$6f,$20,$73,$65,$6C,$65,$63,$74,$20,$44,$69,$72,$20,$20
HelpSaveLen         equ       *-HelpSave                     
HelpSel2            fcc       !Enter to OPEN file - Shift+Enter to CANCEL!
HelpSel2Len         equ       *-HelpSel2
HelpSelb2           fcc       !Enter to OPEN Dir - Shift+Enter to CANCEL!
HelpSelb2Len        equ       *-HelpSelb2
HelpSel3            fcc       !         Space to TAB or use Mouse!
HelpSel3Len         equ       *-HelpSel3
HelpSel4            fcc       ! ^C-Copy ^V-Paste ^R-RunB09 ^E-TE ^X-Hex !
HelpSel4Len         equ       *-HelpSel4
HelpSel5            fcc       ! ^A-ATTR ^N-Rename ^D-Del ^Up/^Down-Page !
HelpSel5Len         equ       *-HelpSel5
HelpSel6            fcc       ! ^F-MakDir ^Q-Quit !
HelpSel6Len         equ       *-HelpSel6
HelpSelb            fcb       $20,$20,$20,$20,$20,$55,$73,$65,$20,$6b,$65,$79,$62,$6f,$61,$72
                    fcb       $64,$20,$74,$6f,$20,$74,$79,$70,$65,$20,$66,$69,$6c,$65,$6e,$61,$6d,$65,$20,$20,$20
HelpSelLenb         equ       *-HelpSelb                     
HelpSel2b           fcc       !Enter to SAVE file - Shift+Enter to CANCEL!
HelpSel2Lenb        equ       *-HelpSel2b
HelpDrv             fcb       $20,$20,$20,$20,$20,$55,$73,$65,$20,$1C,LFAR,$20,$26,$20,$1C,RTAR,$20,$41
                    fcb       $72,$72,$6F,$77,$73,$20,$74,$6f,$20,$73,$65,$6C,$65,$63,$74,$20,$64,$72,$69,$76,$65
HelpDrvLen          equ       *-HelpDrv
HelpDrv2            fcc       !            Enter to OPEN drive           !
HelpDrv2Len         equ       *-HelpDrv2
HelpSaveLst         fcc       !         Space until list selected        !
HelpSaveLstLen      equ       *-HelpSaveLst
Wild                fcc       " Wildbits"
WildLen             equ       *-Wild
BlankItem           fcb       $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
                    fcb       $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
HelpErr             fcc       ! Error - Invalid Filename !
HelpErrLen          equ       *-HelpErr 
CancelHlp           fcc       !CANCEL!
                    fcb       C$CR
CancelHlpLen        equ       *-CancelHlp
pipename            fcc       "/PIPE"        * Standard pipe device name
                    fcb       0              * Null terminate
  
PlayCMD             fcc       "/dd/cmds/play"
                    fcb       C$CR

TECMD               fcc       "/dd/cmds/te"
                    fcb       C$CR

HEXCMD              fcc       "/dd/cmds/hexed"
                    fcb       C$CR

PIXVCMD             fcc       "/dd/cmds/pixview"
                    fcb       C$CR

VIEWCMD             fcc       "/dd/cmds/view"
                    fcb       C$CR

BFCMD               fcc       "/dd/cmds/bf"
                    fcb       C$CR

SCFGCMD             fcc       "/dd/cmds/scfg"
                    fcb       C$CR

SCFGOPT             fcc       ""
                    fcb       C$CR

DATECMD             fcc       "/dd/cmds/date"
                    fcb       C$CR

MAKDIRCMD           fcc       "/dd/cmds/makdir"
                    fcb       C$CR

DelPrompt           fcc       "Delete file? Type YES: "
DelPromptLen        equ       *-DelPrompt
BlankConf           fcc       "                                        "
BlankConfLen        equ       *-BlankConf
RenPrompt           fcc       "New name: "
RenPromptLen        equ       *-RenPrompt
MkDirPrompt         fcc       "Folder name: "
MkDirPromptLen      equ       *-MkDirPrompt
RenErr              fcc       "Copy failed - not renamed"
RenErrLen           equ       *-RenErr
RenExists           fcc       "Rename failed - name already exists"
RenExistsLen        equ       *-RenExists
VerStr              fcc       " MDM V1.0"
VerStrLen           equ       *-VerStr

COPYCMD             fcc       "/dd/cmds/copy"
                    fcb       C$CR

pdotdot             fcc       ".."
                    fcb       C$CR

B09CMD              fcc       "/dd/cmds/basic09"
                    fcb       C$CR

ATTRCMD             fcc       "/dd/cmds/attr"
                    fcb       C$CR

DELCMD              fcc       "/dd/cmds/del"
                    fcb       C$CR

HELPCMD             fcc       "/dd/cmds/help"
                    fcb       C$CR


topleftbc           fcb       $00,$00,$00,$1F,$18,$1F,$18,$18   ........
toprigtbc           fcb       $00,$00,$00,$F8,$18,$F8,$18,$18   ...x.x..
topltc              fcb       $18,$18,$18,$F8,$18,$F8,$18,$18   ...x.x..
toprtc              fcb       $18,$18,$18,$1F,$18,$1F,$18,$18   ........
topbl               fcb       $00,$00,$00,$FF,$00,$FF,$00,$00   ........
sidebl              fcb       $18,$18,$18,$18,$18,$18,$18,$18   ........
btmlftbc            fcb       $18,$18,$18,$1F,$18,$1F,$00,$00   ........
btmrgtbc            fcb       $18,$18,$18,$F8,$18,$F8,$00,$00   ...x.x..
sldchar             fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF   ........
uparr               fcb       $20,$30,$38,$3C,$38,$30,$20,$00   ...@@@.. $1C Left Select
dnarr               fcb       $04,$0C,$1C,$3C,$1C,$0C,$04,$00   .$f.f$.. $1D Right Select
lftarr              fcb       $00,$00,$10,$38,$7C,$FE,$00,$00   ...8|... $1E Up Select
rgtarr              fcb       $00,$00,$00,$FE,$7C,$38,$10,$00   ....|8.. $1F Down Select

FILETYPES           fcc       ".rsd"
                    fcb       FILETYPE_PLAY
                    fcc       ".mus"
                    fcb       FILETYPE_PLAY
                    fcc       ".lyr"
                    fcb       FILETYPE_PLAY
                    fcc       ".ume"
                    fcb       FILETYPE_PLAY
                    fcc       ".map"
                    fcb       FILETYPE_PLAY
                    fcc       ".b09"
                    fcb       FILETYPE_TE
                    fcc       ".bmp"
                    fcb       FILETYPE_VIEW
                    fcc       ".bf"
                    fcb       $0D
                    fcb       FILETYPE_BF
                    fcb       0                   Mark end of table

* KEYWORDS table - match keyword against end of finalpath (before $0D)
* format: length(1) + keyword(n) + filetype(1), $00 = end of table
KEYWORDS            fcb       8
                    fcc       "password"
                    fcb       FILETYPE_TE         open in text editor
                    fcb       7
                    fcc       "startup"
                    fcb       FILETYPE_TE         open in text editor
                    fcb       5
                    fcc       "theme"
                    fcb       FILETYPE_TE         open in text editor
                    fcb       4
                    fcc       "motd"
                    fcb       FILETYPE_TE         open in text editor
                    fcb       4
                    fcc       "mmap"
                    fcb       FILETYPE_CMD
                    fcb       5
                    fcc       "debug"
                    fcb       FILETYPE_CMD
                    fcb       4
                    fcc       "free"
                    fcb       FILETYPE_CMD
                    fcb       4
                    fcc       "irqs"
                    fcb       FILETYPE_CMD
                    fcb       6
                    fcc       "setime"
                    fcb       FILETYPE_CMD
                    fcb       4
                    fcc       "pmap"
                    fcb       FILETYPE_CMD
                    fcb       5
                    fcc       "procs"
                    fcb       FILETYPE_CMD
                    fcb       5
                    fcc       "rogue"
                    fcb       FILETYPE_CMD
                    fcb       4
                    fcc       "proc"
                    fcb       FILETYPE_CMD
                    fcb       4
                    fcc       "smap"
                    fcb       FILETYPE_CMD
                    fcb       4
                    fcc       "date"
                    fcb       FILETYPE_CMD
                    fcb       4
                    fcc       "scfg"
                    fcb       FILETYPE_CMD
                    fcb       9
                    fcc       "gfxstatus"
                    fcb       FILETYPE_CMD
                    fcb       0                   end of table

* FOLDERTYPE table - if current folder name matches, all files get that filetype
* format: length(1) + foldername(n) + filetype(1), $00 = end of table
FOLDERTYPE          fcb       11
                    fcc       "backgrounds"
                    fcb       FILETYPE_PIX        open all files in backgrounds/ with PIXV
                    fcb       7
                    fcc       "scripts"
                    fcb       FILETYPE_TE         open all files in scripts/ in text editor
                    fcb       7
                    fcc       "basic09"
                    fcb       FILETYPE_TE         open all files in basic09/ in text editor
                    fcb       5
                    fcc       "tests"
                    fcb       FILETYPE_TE         open all files in tests/ in text editor
                    fcb       4
                    fcc       "defs"
                    fcb       FILETYPE_TE         open all files in defs/ in text editor
                    fcb       5
                    fcc       "fonts"
                    fcb       FILETYPE_SCFG       open all files in fonts/ in scfg
                    fcb       2
                    fcc       "bf"
                    fcb       FILETYPE_BF         open all files in bf/ with bf
                    fcb       4
                    fcc       "cmds"
                    fcb       FILETYPE_HELP
                    fcb       0                   end of table

                    emod
eom                 equ       *
                    end
