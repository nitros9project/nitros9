********************************************************************
* fcfg
* foenix configuration editor
*
* by John Federico
*
* Edt/Rev  2024/11/30  Modified by John Federico
* Comment
* ------------------------------------------------------------------
               nam       fcfg
               ttl       fcfg

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
solpath	       rmb       1
oldbg	       rmb       1
oldfg	       rmb	 1
newfg	       rmb	 1
newbg	       rmb	 1
hsize	       rmb	 1
vsize	       rmb	 1
oldhsize       rmb	 1
oldvsize       rmb	 1
listlen	       equ     	 8	       	        max length of listbox
dirpath	       rmb       1
dent	       rmb	 DIR.SZ			DIR.SZ defined in rbf.d as 29+3=32
drawchar       rmb	 1
dbufcur	       rmb	 2
dbufcntH       rmb	 1
dbufcntL       rmb	 1
numfonts       rmb	 1			total number of font names loaded
listitem       rmb	 1			current item selected
liststart      rmb	 1			index for top of list
liststartmax   rmb	 1
listmax	       rmb	 1			max # of items displayed
popts	       rmb	 32
oldchars       rmb	 96
fntarray       rmb	 1550	                array of fonts, max 50 of 29+2 len each
drawbuf	       rmb	 256
	       rmb	 250
size           equ       .
name           fcs       /fcfg/
               fcb       edition

fontdir	       fcc 	 "/dd/sys/fonts"
	       fcb	 $0D
	       

start

	       lda	 #0			load current fg and bd colors
	       ldb	 #SS.FBRgs		initialize old and new fg and bg to current colors
	       os9	 I$GetStt		SS.FBRgs returns FG and BG in 1 byte
	       pshs	 a		
	       anda	 #$0F			bg color in low 4 bits. mask high bits
	       sta	 <oldbg			initialize bg vars with current bg
	       sta	 <newbg
	       puls	 a			pull current colors
	       lsra	 			shift right x4 to get current fg color     
	       lsra
	       lsra
	       lsra
	       sta	 <oldfg	                initialize current fg color with   
	       sta	 <newfg
	       clr	 <numfonts	        init number of fonts = 0
	       clr 	 <listitem		init list item = 0
	       clr	 <liststart		init list start = 0
	       lbsr	 installchars		install drawing chars for screen boxes
	       lbsr	 getopts		get current terminal options
	       lbsr	 keyechooff		turn off key echo
	       lbsr	 ldfontarr	        load font array with filenames from fontdir
	       lbsr	 cursoroff		turn cursor off
	       lbsr	 initscrnsz		init screen size vars and set to 80x30
	       lbsr	 clearscreen		clear wscreen
	       lbsr	 drawbox		draw box around font list
	       lbsr      writefgc		write fg colors from current palette to screen
	       lbsr	 drawfg			draw selection indicator at current color
	       lbsr	 writebgc		write bg colors from current palette to screen
	       lbsr	 drawbg			draw selection indicator at current color
	       lbsr	 writelist		write the list of fonts (max 8)
	       lbsr	 wrtlabels		writes Arrows F/f B/b labels
	       lbsr      printfont		print the current font on the screen
	       lbsr	 hvupdate
	       lbsr	 InstallSignals		install SOL to show different font on screen
keyloop@       lbsr	 handlekeyboard		inkey routine with handlers for intergace
	       cmpa	 #$0D			$0D=ok shift+$0d=cancel
	       bne	 nextkey@		if it is not $0D(return), then continue
	       lda	 #0			Else check for the shift key
	       ldb	 #SS.KySns
	       os9	 I$GetStt
	       bita	 #SHIFTBIT
	       bne	 nochange@	        If shiftbit=1,then cancel and quit
	       bra	 setfont		else, make changes with setfont
nextkey@       cmpa	 #'u			
	       beq	 update@
	       bra	 keyloop@	        loop to keyloop
update@	       lbsr	 printfont              update = redraw font 1
	       bra	 keyloop@		loop to keyloop
setfont
               lbsr	 RemoveSignals		clean up and remove signals and SOL
	       lbsr	 changesettings		apply new settings      
	       bcs	 error@			
	       bra	 exit2@
nochange@
	       lbsr	 RemoveSignals	        exit no changes, remove singals and SOL
	       lbsr	 setoldscreen	       
exit2@	       lbsr	 movecursor		clear screen  and reset termainl
	       lbsr	 keyechoon
	       lbsr	 clearscreen
	       lbsr	 cursoron
	       clrb
error@	       ldy	 #2
	       lda	 #1
	       leax	 font0on,pcr	        make sure font0 is on
	       os9	 I$Write
	       os9       F$Exit

********************************************************************
* handlekeyboard
* handles keypress and routines for interface updates
*
handlekeyboard lbsr      INKEY
               cmpa      #$0C
               beq       uparrow
               cmpa      #$0A
               beq       downarrow
	       cmpa      #'f
	       lbeq      movefg
	       cmpa      #'F
	       lbeq      backfg
	       cmpa      #'b
	       lbeq      movebg
	       cmpa      #'B
	       lbeq      backbg
	       cmpa    	 #'h
	       lbeq	 hchange
	       cmpa	 #'H
	       lbeq	 hchange
	       cmpa	 #'v
	       lbeq	 vchange
	       cmpa	 #'V
	       lbeq	 vchange
               rts

********************************************************************
* listbox uparrow
* update interface and load new font1
* signals need to be muted while loading to avoid interface flicker
*
uparrow	       lda       <liststart	   get the start of the current list
	       beq	 cont1@		   if liststart is 0, then don't need to do anything
	       cmpa	 <listitem	   compare to current list item
	       bne	 cont1@		   if list item is not at the start of the list don't move list
	       dec	 <liststart	   else move list and set list start item to one before
cont1@	       lda	 <listitem         load current item
	       beq	 cont2@		   if current=0 don't change
	       dec	 <listitem	   else subtract 1 to move up
cont2@	       lbsr	 writelist	   write the new list to the screen
	       lbsr	 MuteSignals	   turn off SOL to load font
	       lbsr	 changefont1	   load new font1
	       lbsr	 UnMuteSignals	   turn on SOL to display new font
	       clra
	       rts

********************************************************************
* listbox downarrow
* update interface and load new font1
* signals need to be muted while loading to avoid interface flicker
*
downarrow      lda	 <liststart	   get the start of the current list
	       cmpa	 <liststartmax     if liststart is liststart max, don't adjust list
	       beq	 cont1@
* Adjust list display by 1 item down 	       
	       adda	 #7		   add 7 to start and see if we are at last displayed item
	       cmpa	 <listitem	       
	       bne	 cont1@		   not last item, don't need to move list, continue     
	       inc	 <liststart	   else inc start to move displayed items up 1 line	   
cont1@	       lda	 <listitem	   
	       inca			   increment selected item
	       cmpa	 <numfonts	   are we at max?
	       bge	 cont2@		   yes, just update screen
	       inc	 <listitem	   else increase by 1 and update screen
cont2@	       lbsr	 writelist	   redraw list in listbox
	       lbsr	 MuteSignals	   mute SOL signals
	       lbsr	 changefont1	   load new font1
	       lbsr	 UnMuteSignals	   turn on SOL to display new font
	       clra
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
getopts        leax      >popts,u
               ldb       #SS.Opt
               clra
               os9       I$GetStt
               rts

keyechooff     leax      >popts,u
               clr       4,x
               clra
               ldb       #SS.Opt
               os9       I$SetStt
               rts

keyechoon      leax      >popts,u
               lda       #1
               sta       4,x
               clra
               ldb       #SS.Opt
               os9       I$SetStt
               rts

********************************************************************
* changesettings
* when the user hits return, change the settings to
* match those selected by the user
*

* add full path + filename to drawbuf
changesettings leay	 drawbuf,u
	       leax	 fontdir,pcr	   load fontdir path
	       ldb	 #13
fdirloop@      lda	 ,x+	           add dirname to drawbuf
	       sta	 ,y+
	       decb
	       bne	 fdirloop@
	       lda	 #$2F	           add extra slash
	       sta	 ,y+			
	       lda	 <listitem	   Get the list item
	       lbsr	 arrayidx	   Get the index
	       leax	 1,x
	       ldb	 ,x+
fnameloop@     lda	 ,x+		   add filename to drawbuf
	       sta	 ,y+
	       decb
	       bne	 fnameloop@
	       lda	 #$0D	           add terminating return
	       sta	 ,y			
	       ldy	 #0		   load font into font0
	       leax	 drawbuf,u         with SS.FntLoadF 
	       ldb       #SS.FntLoadF
	       lda	 #0
	       os9	 I$SetStt
	       bcs	 error@
	       bsr	 setnewcolors	   set new fg and bg colors
	       bsr	 setnewscreen
error@	       rts



setnewscreen   leax	drawbuf,u
	       ldy	#$1B20
	       sty	,x++
	       lda	<hsize
	       adda	<vsize
	       sta	,x+
	       ldy	#$0000
	       sty	,x++
	       sty	,x++
	       lda	<newfg
	       ldb	<newbg
	       std	,x++
	       stb	,x
	       lda	#1
	       leax	drawbuf,u
	       ldy	#10
	       os9	I$Write
	       rts

setoldscreen   leax	drawbuf,u
	       ldy	#$1B20
	       sty	,x++
	       lda	<oldhsize
	       adda	<oldvsize
	       sta	,x+
	       ldy	#$0000
	       sty	,x++
	       sty	,x++
	       lda	<oldfg
	       ldb	<oldbg
	       std	,x++
	       stb	,x
	       lda	#1
	       leax	drawbuf,u
	       ldy	#10
	       os9	I$Write
	       rts

********************************************************************
* setnewcolors
* write the 1BXXYY codes to the screen to change the colors
* $1B32XX changes fg color to XX
* $1B33XX changes bg color to XX
*
setnewcolors   leax	 drawbuf,u
	       ldy	 #$1B32
	       sty	 ,x++
	       ldb	 <newfg
	       stb	 ,x+
	       ldy	 #$1B33
	       sty 	 ,x++
	       ldb	 <newbg
	       stb	 ,x
	       leax	 drawbuf,u
	       lda	 #1
	       ldy	 #6
	       os9	 I$Write
	       rts

********************************************************************
* setoldcolors
* write the 1BXXYY codes to the screen to change the colors
* $1B32XX changes fg color to XX
* $1B33XX changes bg color to XX
*
setoldcolors   leax	 drawbuf,u
	       ldy	 #$1B32
	       sty	 ,x++
	       ldb	 <oldfg
	       stb	 ,x+
	       ldy	 #$1B33
	       sty 	 ,x++
	       ldb	 <oldbg
	       stb	 ,x
	       leax	 drawbuf,u
	       lda	 #1
	       ldy	 #6
	       os9	 I$Write
	       rts


********************************************************************
* initscrnsz
* get the current screen size, set up vars and 
* change the screen size for the program to 80x30
* 
*
initscrnsz     lda	#1		    get current screentype	
	       ldb	#SS.ScTyp
	       os9	I$GetStt
size1@	       cmpa	#1
	       bne	size2@
	       clr	<vsize
	       clr	<oldvsize
	       sta	<hsize
	       sta	<oldhsize
	       bra	cont@
size2@	       cmpa	#2
	       bne	size3@
	       clr	<vsize
	       clr	<oldvsize
	       lda	#2
	       sta	<hsize
	       sta	<oldhsize
	       bra  	cont@
size3@	       cmpa     #3
	       bne	size4@
	       lda	#1
	       sta	<hsize
	       sta	<oldhsize
	       lda	#2
	       sta	<vsize
	       sta	<oldvsize
	       bra	cont@
size4@	       cmpa	#4
	       lda      #2
	       sta	<hsize
	       sta	<vsize
	       sta	<oldhsize
	       sta	<oldvsize
cont@	       leax	s80x30,pcr
	       ldy	#7
	       lda	#1
	       os9	I$Write
	       leax	drawbuf,u
	       lda	<oldfg
	       sta	,x+
	       lda	<oldbg
	       sta	,x+
	       sta	,x+
	       leax	drawbuf,u
	       ldy	#3
	       lda	#1
	       os9	I$Write
	       rts


s80x30         fcb      $1B,$20,$02,$00,$00,$00,$00


hchange        lda	<hsize
	       cmpa	#2
	       bne	change80@
	       lda	#1
	       sta	<hsize
	       bra	update@
change80@      lda	#2
	       sta	<hsize
update@	       bra      hvupdate

vchange	       lda	<vsize
	       cmpa	#0
	       bne	change30@
	       lda	#2
	       sta	<vsize
	       bra	hvupdate
change30@      clr	<vsize	       

hvupdate       lda	<hsize
	       cmpa	#1
	       beq	h40@
h80@	       bsr	hposgo
	       bsr	hvwriteselect
	       bsr	hpos2go
	       bsr	hvwriteclear
	       bra	gov@
h40@	       bsr	hposgo
	       bsr	hvwriteclear
	       bsr	hpos2go
	       bsr	hvwriteselect
gov@	       lda	<vsize
	       beq	v30@
v60@	       bsr	vposgo
	       bsr	hvwriteselect
	       bsr	vpos2go
	       bsr	hvwriteclear
	       bra	return@
v30@	       bsr	vposgo
	       bsr	hvwriteclear
	       bsr	vpos2go
	       bsr	hvwriteselect
return@	       rts	       


hvwriteselect  leax	hvselect,pcr
	       bra	hvwrite
hvwriteclear   leax	hvclear,pcr
hvwrite	       ldy	#1
	       lda	#1
	       os9	I$Write
	       rts


hposgo	       leax	hpos,pcr
	       bra	engage@
hpos2go	       leax	hpos2,pcr
	       bra	engage@
vposgo	       leax	vpos,pcr
	       bra	engage@
vpos2go	       leax	vpos2,pcr
engage@	       ldy	#3
	       lda	#1
	       os9	I$Write
	       rts


hpos           fcb	$02,$51,$2E
vpos	       fcb	$02,$5A,$2E
hpos2	       fcb	$02,$51,$2F
vpos2	       fcb	$02,$5A,$2F
hvclear	       fcb	$20
hvselect       fcb	$3E


********************************************************************
* change font 1
* 
* changes font 1 to selected font from list
*
changefont1    leay	 drawbuf,u
	       leax	 fontdir,pcr		load fontdir path
	       ldb	 #13			/dd/sys/fonts (13 chars)
fdirloop@      lda	 ,x+
	       sta	 ,y+
	       decb
	       bne	 fdirloop@
	       lda	 #$2F	                add extra slash
	       sta	 ,y+			
	       lda	 <listitem		Get the list item
	       lbsr	 arrayidx		Get the index
	       leax	 1,x			advance past unused byte
	       ldb	 ,x+			load length of font name
fnameloop@     lda	 ,x+
	       sta	 ,y+			copy font name
	       decb
	       bne	 fnameloop@
	       lda	 #$0D			add terminating $0D
	       sta	 ,y
	       ldy	 #1		        add to font#1
	       leax	 drawbuf,u		dir+filename string
	       ldb       #SS.FntLoadF		call font load
	       lda	 #0
	       os9	 I$SetStt
	       rts


* ldfontarr
* 
* read sys/fonts directory and put all the font file names
* into the list so the user can seleect the new font.
*
ldfontarr
	       lbsr	 clrarray
	       bsr	 opendir	   open the font directory
	       bsr	 seekdir	   skip first two entries (. and ..)
loop@	       bsr	 readdir	   read next directory entry
	       bcs	 exit@
	       leay	 dent,u
	       lda	 <numfonts
	       lbsr	 toarr
	       inc	 <numfonts
	       bra	 loop@
exit@	       cmpb	 #211	           should be an EOF here
	       bne	 error@		   skip clearing b if error to preserve error msg
	       clrb
error@	       pshs	 b                 not error routine, preserve error code
	       ldb	 <numfonts         
	       decb	 #listlen
	       lda	 #listlen
	       cmpa	 <numfonts
	       blt	 setlistlen@
	       lda	 <numfonts
	       clrb
setlistlen@    sta	 <listmax
	       stb	 <liststartmax
	       puls	 b	           pull error code if there is one
	       lda	 <dirpath
	       os9	 I$Close
	       rts

* opendir - subroutine to open fonts directory
opendir	       lda	 #DIR.+READ.	   directory is just a file on the disk
	       leax	 fontdir,pcr
	       pshs	 x,a
	       os9	 I$Open
	       sta	 <dirpath
	       puls	 x,a
	       os9	 I$ChgDir
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
	       clr	 a,x
	       bne	 loop@
	       ldy	 #DIR.SZ	   each dir entry is 32 bytes, filename is first 29
	       lda	 <dirpath          name is terminated with high bit set
	       leax	 dent,u
	       os9	 I$Read
	       rts


********************************************************************
* drawbox
* draws box around font list
* 4 lines and 8 corners
* uses drawHL and drawVL subroutines
*
drawbox        lda	 #$F9		    DC
	       sta	 <drawchar
	       ldb	 #$23		    Row 3 + $20
	       ldx	 #31
	       lda	 #$24	            
	       lbsr	 drawHL

	       lda	 #$FA			df
	       sta	 <drawchar
	       ldb	 #$2C                Row 13 + $20
	       ldx	 #31
	       lda	 #$24
	       lbsr	 drawHL

	       lda	 #$F7                 
	       sta	 <drawchar
	       ldb	 #$24	            Col 4 + $20
	       ldx	 #8
	       lda	 #$24
	       lbsr	 drawVL
	       
	       lda	 #$F8			DE
	       sta	 <drawchar
	       ldb	 #$24
	       ldx	 #8
	       lda	 #$42
	       lbsr	 drawVL

	       lda	 #$F3			corner
	       sta	 <drawchar
	       ldb	 #$23
	       ldx	 #1
	       lda	 #$24
	       lbsr	 drawHL

	       lda	 #$F4			corner
	       sta	 <drawchar
	       ldb	 #$23
	       ldx	 #1
	       lda	 #$42
	       lbsr	 drawHL

	       lda	 #$F5			corner
	       sta	 <drawchar
	       ldb	 #$2C
	       ldx	 #1
	       lda	 #$24
	       lbsr	 drawHL

	       lda	 #$F6
	       sta	 <drawchar
	       ldb	 #$2C
	       ldx	 #1
	       lda	 #$42
	       lbsr	 drawHL
	       
	       rts

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

cmdclrscreen   fcb	 $0C              clear screen
cmdcursoroff   fcb	 $05,$20	  cursor off
cmdcursoron    fcb	 $05,$21	  cursor on
cmdrevvidon    fcb	 $1F,$20	  reverse video on
cmdrevvidoff   fcb	 $1F,$21	  reverse video off
font0on	       fcb	 $1B,$62          switch to font0

movecursor     leay	 drawbuf,u
	       lda	 #$02
	       sta	 ,y+
	       lda	 #$30
	       sta	 ,y+
	       lda	 #$34
	       sta	 ,y+
	       lda	 #1
	       leax	 drawbuf,u
	       ldy	 #$03
	       os9	 I$Write
	       rts



********************************************************************
* writelist
* updates list box
* write max 8 items from the array into the list
*
writelist      leas	 -4,s		add to stack to store x,y coordinates
	       lda	 #$02
	       sta	 ,s	        Cursor XY Command
	       lda	 #$25
	       sta	 1,s		x coordinate
	       lda	 #$24
	       sta	 2,s	        y coordinate
	       clr	 3,s	        list counter
	       lda	 <liststart	initialize array
loop@	       pshs	 a
	       cmpa	 <listitem
	       bne	 norev@
	       bsr	 writerevon
norev@	       lda	 #1
	       leax	 1,s
	       ldy	 #3
	       os9	 I$Write
	       puls	 a
	       lbsr	 arrayidx
	       ldy	 #29
	       leax	 2,x
	       pshs      a
	       lda	 #1
	       os9	 I$Write
	       puls      a
	       cmpa	 <listitem
	       bne	 norev2@
	       bsr	 writerevoff
norev2@	       inc	 2,s
	       inc	 3,s
	       inca
	       ldb	 3,s
	       cmpb	 <listmax
	       bne	 loop@
	       leas	 4,s
	       rts


********************************************************************
* writefgc
* write the foreground colors from the current palette to the screen
* this draws all the colors for the user to select
* start at 40,5 on the screen
writefgc       leax	 drawbuf,u
	       lda	 #$02
	       sta	 ,x+
	       lda	 #$4A		x=40
	       sta	 ,x+
	       lda	 #$25		y=5
	       sta	 ,x+
	       lda	 #01
	       leax	 drawbuf,u
	       ldy	 #3
	       os9	 I$Write
	       ldb	 #0
fgloop@	       leax	 drawbuf,u
	       ldy	 #$1B32
	       sty	 ,x++
	       stb	 ,x+
	       lda	 #$FB
	       sta	 ,x+
	       lda	 #$20
	       sta	 ,x+
	       lda	 #0
	       leax	 drawbuf,u
	       ldy	 #5
	       os9	 I$Write
	       incb
	       cmpb	 #$10
	       bne	 fgloop@
	       leax	 drawbuf,u
	       ldy	 #$1B32
	       sty	 ,x
	       lda	 <oldfg
	       sta	 2,x
	       ldy	 #3
	       lda	 #0
	       os9	 I$Write
	       rts

movefg	       inc	 <newfg
	       lda	 <newfg
	       cmpa	 #$10
	       bne	 drawfg
	       clr	 <newfg
	       bra	 drawfg
backfg	       dec	 <newfg
	       lda	 <newfg
	       cmpa	 #$FF
	       bne	 drawfg
	       lda	 #$0F
	       sta	 <newfg
drawfg	       leax	 drawbuf,u
	       lda	 #$02
	       sta	 ,x+
	       ldy	 #$4A24
	       sty	 ,x++
	       ldb	 #$0
loop@	       cmpb      <newfg
	       bne	 space@
	       ldy	 #$2B20
	       bra	 store@
space@	       ldy	 #$2020
store@	       sty	 ,x++
	       incb
	       cmpb	 #$10
	       bne	 loop@
	       lda	 #0
	       leax	 drawbuf,u
	       ldy	 #35
	       os9	 I$Write
	       lbsr	 setnewcolors
	       lbsr	 printfont
	       lbsr	 setoldcolors
	       clra
	       rts
	       
********************************************************************
* writebgc
* write the background colors from the current palette to the screen
* this draws all the colors for the user to select
* start at 40,5 on the screen* write bgc
* write the current bg colors from the palette to the screen
writebgc       ldb	 <oldbg
	       pshs	 b
	       leax	 drawbuf,u
	       lda	 #$02
	       sta	 ,x+
	       lda	 #$4A		x=40
	       sta	 ,x+
	       lda	 #$2A		y=5
	       sta	 ,x+
	       lda	 #01
	       leax	 drawbuf,u
	       ldy	 #3
	       os9	 I$Write
	       ldb	 #0
bgloop@	       leax	 drawbuf,u
	       ldy	 #$1B33
	       sty	 ,x++
	       stb	 ,x+
	       lda	 #$20
	       sta	 ,x+
	       sty	 ,x++
	       lda	 ,s
	       sta	 ,x+
	       lda	 #$20
	       sta	 ,x+
	       lda	 #0
	       leax	 drawbuf,u
	       ldy	 #8
	       os9	 I$Write
	       incb
	       cmpb	 #$10
	       bne	 bgloop@
	       leas	 1,s
	       clra
	       rts
	       
movebg	       inc	 <newbg
	       lda	 <newbg
	       cmpa	 #$10
	       bne	 drawbg
	       clr	 <newbg
	       bra	 drawbg
backbg	       dec	 <newbg
	       lda	 <newbg
	       cmpa	 #$FF
	       bne	 drawbg
	       lda       #$0F
	       sta	 <newbg
drawbg	       leax	 drawbuf,u
	       lda	 #$02
	       sta	 ,x+
	       ldy	 #$4A29
	       sty	 ,x++
	       ldb	 #$0
loop@	       cmpb      <newbg
	       bne	 space@
	       ldy	 #$2B20
	       bra	 store@
space@	       ldy	 #$2020
store@	       sty	 ,x++
	       incb
	       cmpb	 #$10
	       bne	 loop@
	       lda	 #0
	       leax	 drawbuf,u
	       ldy	 #35
	       os9	 I$Write
	       lbsr	 setnewcolors
	       lbsr	 printfont
	       lbsr	 setoldcolors
	       rts


wrtlabels      leax	 flabel,pcr
	       ldy	 #90
	       lda	 #0
	       os9	 I$Write
	       rts 

clrarray       pshs      u,x,y
	       leax      fntarray,u
	       ldu	 #$2020
	       ldy	 #1550
loop@	       stu	 ,x++
	       leay      -2,y
	       bne	 loop@
	       puls      u,x,y,pc

* Puts string at y into font arrray at index a
* store string length in first two byts of array item
toarr          pshs      a,x
               bsr       arrayidx          put array index a addr in x
	       pshs      x		   store start address on stack
	       leas      -2,s		   add stack space for string count
	       clr	 ,s		   clear it to 0
	       clr	 1,s
	       leax      2,x		   reserve place in array string for length
arrloop@       lda       ,y		   load char from string
	       anda      #$7F		   strip terminating high bit, if there
               sta       ,x+		   put into array
	       inc	 1,s		   increment string count
               tst       ,y+               test for the high bit, but don't overwrite
               bpl       arrloop@          need the high bit on output
	       puls      x,y		   pull length and string start
	       stx	 ,y		   store string length in two byte of array item
               puls      a,x,pc

* calc array item address in x from index a
* multiply 29*index (0-49) to get offset using math co-processor
* destroys x
arrayidx       pshs      d,cc
	       orcc      #IntMasks         mask interrups to avoid copro collisions
               sta       $FEE1		   low bit in math copro
               clr       $FEE0		   high bit in math copro
               lda       #31		   multiple by 31, len of row
               sta       $FEE3		   low bit in math copro
               clr       $FEE2		   high bit in math copro
	       ldd	 $FEF2
               leax      fntarray,u	   load address of array
               leax      d,x		   add offset
               puls      d,cc,pc	   return

* TEST routine to check array contents
writearr       lda	 #0	           initiate loop index counter
loop@	       bsr	 arrayidx		   get addr of item		   
	       ldy	 ,x++		   get length, and advance memory
	       pshs      a			   store a to use a for I$Write
	       lda	 #1
	       os9	 I$Write
	       puls      a			   retrieve a loop index counter
	       inca      			   increment counter
	       cmpa      <numfonts		   are we done?
	       blt	 loop@		   no - then loop
	       rts
		    

*draw horizontal line with drawchar, a=x1, b=y1, x=length
drawHL	       pshs      d,x,y
	       clr	 <dbufcntH		   need to use y for write length
	       clr	 <dbufcntL		   so use 2 bytes to store to load y in one call
	       leay      drawbuf,u		   buffer address
	       lda	 #$02	           use display code $02 X Y
	       sta	 ,y+
	       inc	 <dbufcntL
	       lda       ,s		   load X1 from stack into a
	       std	 ,y++		   b is already Y1, store xy in buffer
	       inc	 <dbufcntL
	       inc	 <dbufcntL		   xy now set
	       lda	 <drawchar		   draw line of drawchar x chars long
loop@	       sta	 ,y+		   
	       inc	 <dbufcntL
	       leax      -1,x
	       bne	 loop@
	       lda	 #$01	           write routine, a=path
	       leax      drawbuf,u 	   x=addr of string
	       ldy	 <dbufcntH		   y=#of bytes
	       os9	 I$Write		   write it
	       puls      pc,d,x,y


* draw vertical line with drawchar, a=x1, b=y1, x=length
drawVL	       pshs      d,x,y                
	       clr	 <dbufcntH		   need to use y for write length
	       clr	 <dbufcntL		   so use 2 bytes to store to load y in one call
	       leay      drawbuf,u		   buffer address
loop@	       lda	 #$02		   use display code $02 X Y
	       sta	 ,y+		   store code in buffer
	       inc	 <dbufcntL
	       lda       ,s
	       std       ,y++	           store xy in buffer
	       inc	 <dbufcntL
	       inc	 <dbufcntL
	       lda	 <drawchar	           xy now set
	       sta	 ,y+		   add drawchar
	       inc	 <dbufcntL
	       incb			   increase y value	
	       leax      -1,x	           decrease length counter
	       bne	 loop@
	       lda	 #$01		   a=path
	       leax      drawbuf,u		   x=str addr
	       ldy	 <dbufcntH		   y=length
	       os9	 I$Write		   write it
	       puls      pc,d,x,y

********************************************************************
* installchars
* installs drawing characters into the current font
* this ensures the screen looks the same no matter
* which font is in font0
*
installchars   ldb	 #12
	       pshs      b
	       leax      oldchars,u
	       ldy	 #243
loop@	       lda	 #0
	       ldb	 #SS.FntChar
	       os9       I$GetStt
	       bcs	 exit@
	       leax      8,x
	       leay      1,y
	       dec	 ,s
	       bne	 loop@
	       ldb	 #12
	       stb	 ,s
	       leax      ccorner1,pcr
	       ldy	 #243
loop2@	       lda	 #0
	       ldb	 #SS.FntChar
	       os9	 I$SetStt
	       bcs	 exit@
	       leax      8,x
	       leay      1,y
	       dec	 ,s
	       bne       loop2@
exit@	       puls      b,pc

********************************************************************
* restorechars
* if the user exits without making changes, remove
* replace the drawing character with the original
* font characters
*
restorchars    ldb	 #12
	       stb	 ,s
	       leax      oldchars,u
	       ldy	 #243
loop@	       lda	 #0
	       ldb	 #SS.FntChar
	       os9	 I$SetStt
	       bcs	 exit@
	       leax      8,x
	       leay      1,y
	       dec	 ,s
	       bne       loop@
exit@	       puls      b,pc		    
		    

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

********************************************************************
* printfont, prints all the characters for preview of the selected font
* mutes the SOL while drawing to eliminate flicker
* change this from loop to screenchars for speed
*
printfont
		lbsr      MuteSignals
	       leax      screenchars,pcr
	       ldy	 #300
	       lda	 #1
	       os9	 I$Write
	       lbsr      UnMuteSignals
	       rts

********************************************************************
* InstallSignals
* Installs signal receiver and
* opens path to SOL driver and installs SOL lines
InstallSignals leax      cfIcptRtn,pcr
	       os9	 F$Icpt
	       lda	 #UPDAT.+SHARE.
	       leax      fsol,pcr
	       os9	 I$Open
	       bcc	 storesol@
	       os9	 F$PErr
	       tfr	 a,b
	       os9	 F$PErr
storesol@      sta	 <solpath
	       ldx	 #260
	       ldy	 #$A0
	       ldb	 #SS.SOLIRQ
	       os9	 I$SetStt
	       lda	 <solpath
	       ldx	 #385
	       ldy	 #$A1
	       ldb	 #SS.SOLIRQ
	       os9	 I$SetStt
	       rts

fsol	       fcc	 \/fSOL\
	       fcb	 $0D

********************************************************************
* cfIcptRtn
* this handles the signals received by SOL
* 
cfIcptRtn      cmpb      #$A0
	       beq	 changefont1@
	       cmpb      #$A1
	       beq	 changefont0@
	       bra	 exit@
changefont1@   lda	 #$0
	       ldb	 #SS.DScrn
	       os9	 I$GetStt	         
	       tfr	 y,d
	       orb       #FT_FSET
	       tfr	 d,y
	       bra	 writeit@
changefont0@   lda	 #$0
	       ldb	 #SS.DScrn
	       os9	 I$GetStt	         
	       tfr	 y,d
	       andb      #~(FT_FSET)
	       tfr	 d,y
writeit@       lda	 #1
	       ldb	 #SS.DScrn
	       os9	 I$SetStt           
exit@          rti

********************************************************************
* Mute Signals
* turns off signals to this process from SOL
* use these to reduce flicker when performing longer procedures
*
MuteSignals    pshs      a,b,x,y
	       lda	 <solpath
	       ldx	 #1
	       ldb	 #SS.SOLMUTE
	       os9	 I$SetStt
changefont0@   lda	 #$0
	       ldb	 #SS.DScrn
	       os9	 I$GetStt
	       tfr	 y,d
	       andb      #~(FT_FSET)
	       tfr	 d,y
writeit@       lda	 #1
	       ldb	 #SS.DScrn
	       os9	 I$SetStt
	       puls      a,b,x,y
	       rts

********************************************************************
* Unmute signals
* turns signals back on
*
UnMuteSignals  pshs	 a,b,x
	       lda	 <solpath
	       ldx	 #0
	       ldb	 #SS.SOLMUTE
	       os9	 I$SetStt
	       puls	 a,b,x
	       rts

********************************************************************
* RemoveSignals
* clean up irqs and signal handling on exit
*
RemoveSignals  lda	 <solpath
	       ldx	 #260
	       ldy	 #0
	       ldb	 #SS.SOLIRQ
	       os9	 I$SetStt
	       lda	 <solpath
	       ldx	 #385
	       ldy	 #0
	       ldb	 #SS.SOLIRQ
	       os9	 I$SetStt
	       lda	 <solpath
	       os9	 I$Close
	       rts
		    


flabel	       fcb	 $02,$58,$27
	       fcb	 $46,$2F,$66
blabel	       fcb	 $02,$58,$2C		    
	       fcb	 $42,$2F,$62
arrowlabel     fcb	 $02,$22,$26,$FC
	       fcb	 $02,$22,$28,$FD
hvlabel	       fcb	 $02,$52,$2E
	       fcb	 $38,$30,$20,$48,$2F,$68,$20,$20,$20
	       fcb	 $36,$30,$20,$56,$2F,$76
	       fcb	 $02,$52,$2F
	       fcb	 $34,$30,$20,$20,$20,$20,$20,$20,$20
	       fcb	 $33,$30
oklabel	       fcb       $02,$41,$3B
	       fcc       \Ok\
	       fcb	 $02,$4A,$3B
	       fcc       \Cancel\
	       fcb	 $02,$3F,$3C
	       fcc	 \Return\
	       fcb	 $02,$47,$3C
	       fcc	 \Shift+Return\
* Custom font characters for box
ccorner1       fcb       $0F,$1F,$3F,$7C,$F8,$F1,$E3,$E6	   *243  F3
ccorner2       fcb	 $F0,$F8,$FC,$3E,$1F,$8F,$C7,$67	   *244  F4
ccorner3       fcb	 $E6,$E3,$F1,$F8,$7C,$3F,$1F,$0F	   *245  F5
ccorner4       fcb	 $67,$C7,$8F,$1F,$3E,$FC,$F8,$F0	   *246  F6
cleftside      fcb	 $E6,$E6,$E6,$E6,$E6,$E6,$E6,$E6	   *247  F7
crightside     fcb	 $67,$67,$67,$67,$67,$67,$67,$67	   *248  F8
ctop	       fcb	 $FF,$FF,$FF,$00,$00,$FF,$FF,$00	   *249  F9
cbottom	       fcb	 $00,$FF,$FF,$00,$00,$FF,$FF,$FF	   *250  FA
cblock	       fcb	 $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	   *251  FB
cuparrow       fcb	 $10,$38,$54,$92,$10,$10,$10,$10	   *252  FC
cdownarrow     fcb	 $10,$10,$10,$10,$92,$54,$38,$10	   *253  FD
ccaret	       fcb	 $00,$00,$00,$00,$81,$42,$24,$18	   *254  FE


* it takes 300 ($12C) chars to print the font in the right place on the screen
* list them all characters plus all the control characters here for speed
* so that the system doesn't have to compute the values
screenchars    fcb	 $02,$28,$34
	       fcb	 $1C,$00,$1C,$01,$1C,$02,$1C,$03,$1C,$04
	       fcb	 $1C,$05,$1C,$06,$1C,$07,$1C,$08,$1C,$09
	       fcb	 $1C,$0A,$1C,$0B,$1C,$0C,$1C,$0D,$1C,$0E
	       fcb	 $1C,$0F,$1C,$10,$1C,$11,$1C,$12,$1C,$13
	       fcb       $1C,$14,$1C,$15,$1C,$16,$1C,$17,$1C,$18
	       fcb       $1C,$19,$1C,$1A,$1C,$1B,$1C,$1C,$1C,$1D
	       fcb       $1C,$1E,$1C,$1F,$20,$21,$22,$23,$24,$25
	       fcb	 $26,$27,$28,$29,$2A,$2B,$2C,$2D,$2E,$2F
	       fcb	 $30,$31,$32,$33,$34,$35,$36,$37,$38,$39
	       fcb	 $3A,$3B,$3C,$3D,$3E,$3F
		    
	       fcb	 $02,$28,$35
	       fcb	 $40,$41,$42,$43,$44,$45,$46,$47,$48,$49
	       fcb	 $4A,$4B,$4C,$4D,$4E,$4F,$50,$51,$52,$53
	       fcb	 $54,$55,$56,$57,$58,$59,$5A,$5B,$5C,$5D
	       fcb	 $5E,$5F,$60,$61,$62,$63,$64,$65,$66,$67
	       fcb	 $68,$69,$6A,$6B,$6C,$6D,$6E,$6F,$70,$71
	       fcb	 $72,$73,$74,$75,$76,$77,$78,$79,$7A,$7B
	       fcb	 $7C,$7D,$7E,$7F,$02,$28,$36
	       
	       fcb	 $80,$81,$82,$83,$84,$85,$86,$87,$88,$89
	       fcb	 $8A,$8B,$8C,$8D,$8E,$8F,$90,$91,$92,$93
	       fcb	 $94,$95,$96,$97,$98,$99,$9A,$9B,$9C,$9D
	       fcb	 $9E,$9F,$A0,$A1,$A2,$A3,$A4,$A5,$A6,$A7
	       fcb	 $A8,$A9,$AA,$AB,$AC,$AD,$AE,$AF,$B0,$B1
	       fcb	 $B2,$B3,$B4,$B5,$B6,$B7,$B8,$B9,$BA,$BB
	       fcb	 $BC,$BD,$BE,$BF,$02,$28,$37

	       fcb	 $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7,$C8,$C9
	       fcb	 $CA,$CB,$CC,$CD,$CE,$CF,$D0,$D1,$D2,$D3
	       fcb	 $D4,$D5,$D6,$D7,$D8,$D9,$DA,$DB,$DC,$DD
	       fcb	 $DE,$DF,$E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7
	       fcb	 $E8,$E9,$EA,$EB,$EC,$ED,$EE,$EF,$F0,$F1
	       fcb	 $F2,$F3,$F4,$F5,$F6,$F7,$F8,$F9,$FA,$FB
	       fcb	 $FC,$FD,$FE,$FF

               emod
eom            equ *
               end