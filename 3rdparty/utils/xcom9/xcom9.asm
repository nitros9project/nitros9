         Nam   XCom9
         ttl  XCOM9 Version 12 (CoCo II/III version)
*              XCom9   - Modem program   FEB 1985
****************************************************************************
* Program originally developed by Greg Morse, released by permission to:   *
* Barry C. Nelson (AKA: The Doctor) on May 11, 1988. This program NOT to be*
* confused with Gimix Xcom9, Version 10                                    *
****************************************************************************
* Thanks Greg!                                                             *
****************************************************************************
*                  "FREEWARE": If you like this program
*                              send a donation to:
*
*                  The Doctor
*                  11530 NE 7 Ave.
*                  N Miami, FL 33161
*
*+++++++++
 ifp1
 use defsfile
 endc
*---------
*
* Revision History -
*        Nov 17 84 version 1 - no xmodem support - no signals
*        Jan 20 85 version 2 - added vuflg and acia read ahead on mdm
*        Feb 15 85 version 3 - major rewrite to add xmodem support
*        MAR 15 85 version 4 - prompt mode for send added
*        APR  8 85 version 5 - added break command/finished xmodem
*                            - sent to users group
*        Feb  1 88 version 6 - added set baud & parity command(The Doctor)
*        Feb  1 88 version 7 - added definable ascii filter   (The Doctor)
*        Mar  1 88 version 8 - added overlay windows on level2(The Doctor)
*        Mar  4 88 version 9 - added auto redial              (The Doctor)
*        May 11 88 version 10- Macro keys                     (The Doctor)
*        May 15 88 version 11- Change directory               (The Doctor)
*                  "           Add/Strip line feed
*        Dec 29 88 revision 1- Fixed send break.
*                              Fixed position dependency port bug.
*                                                             (The Doctor)
*        May 24 89 version 12  added ymodem/xmodem crc support
*                              fixed 1200 baud ctrl code bug  (The Doctor)
version  equ   12
 MOD GmtLen,GmtNam,Prgrm+Objct,Reent+Version,GmtXqt,GmtMem
*+++++++++
 use xcom9_ram.asm
*---------
*+++++++++
 use xcom9_const.asm
*---------
         ttl  Code space Initialization routines
         page
GMTNAM   FCS   "XCom9"
editn    fcb   12
         page
*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GMTSIG   equ   *               Trap os9 signals here
         lda   #SetSig         ;;; note interrupts disabled here
gmtsig5  cmpb  Panic,pcr       ;;; is operator killing pgm?
         bne   gmtsig9         ;;; go if not
         sta   kildflg,u       ;;; set killed switch
gmtsig9  rti                   ;;;
* ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GMTXQT   EQU   *               entry point
         cmpd  #1              any parameters?
         bgt   gmt100          go if parameters
gmt010   lbsr  gmt980          print usage message
         lbsr  gmt420          show cmd menu
gmt098   clrb
gmt099   os9   F$Exit
*
*        open modem path
*
GMT100   equ   *
         leas  stktop,U        move stack so disk buffs can expand
         stx   parmptr
         std   DecAcc          save parm len in temp area
         leay  -2,x            buff top= parmbot-1 -1 for CR at eof
         sty   hircvptr,U      top of rcv buff limit
         lda   #Updat.         X points to modem path
         os9   I$Open
         bcc   gmt105
         OS9   F$Perr          show error
         leax  Mbadpth,pcr
         ldy   #Lbadpth
         lda   #stdout
         os9   I$Write
         ldx   parmptr         get pointer to called for path
         ldy   DecAcc          len of parm string
         os9   I$WritLn        write out parm string
         lbsr  gmt980          show usage message
         bra   gmt098          exit pgm
*
*        initialize Ram area
*
gmt105   equ   *               mdm path open ok
         sta   mpth            save mdm pth number
         leax  ch,u            point at start of buffer
         stx   bpoint          save pointer
         stx   obp
         ldd   #lkeybuf        length of buffer
         abx
         leax  -1,x
         stx   ebp
         clr   escrec
         clr   chlen
         clr   chlen+1
         clr   dummy
         lda   #C$Null          clr pth options are to nulls
         ldb   #topopts-pthopts
         leax  pthopts,u
         lbsr  gmt806           fill mem blk subrtn
         lda   #C$Spac          clr pth names to spaces
         ldb   #pathstop-pathsbot
         leax  pathsbot,u
         lbsr  gmt806          fill mem blk subrtn
         ldb   #32
         leax  TranTab,u       dest ptr
         leay  AscFiltr,PCR    source ptr
         lbsr  gmt807          Copy default filter parms
         ldb   #Lpgmstat       length of area
         leax  pgmstate,u      dest ptr
         leay  defstate,pcr    source ptr
         lbsr  gmt807          block move subroutine
         ldd   dxonchr,pcr     get default xon and xoff chars
         std   xonchr          setup defaults in ram
         lda   dcmdchr,pcr     get command prefix char
         sta   cmdchr
         clr   rpth
         clr   spth
         clr   smode
         lda   #XS.Idle        xmodem idle state
         sta   Xstate          set up
*
*        setup disk buffer pointers
*
         leax  sndsoh,u
         stx   LoSndptr,u
         stx   sndptr,u
         leax  sndBtop,u
         stx   HiSndptr,u
*
         leax  rcvtxt,u
         stx   LoRcvptr,u
         stx   rcvptr,u
*              Hircvptr set = (X)-2 on entry = bot of parm area
         bra   gmt110              go init path options
         page
*
*        initialize run time path options areas
*
GMT110   lda   #stdin
         ldb   #SS.opt
         leax  iconopt,u
         os9   I$GetStt        save console option settings
         lbcs  gmt099          abort if error
         lda   pd.alf-pd.opt,x
         sta   pd.alf-pd.opt+conopt,u copy auto line feed option
         lda   pd.par-pd.opt,x        copy all hardware affecting opts
         sta   pd.par-pd.opt+conopt,u
         lda   pd.bau-pd.opt,x
         sta   pd.bau-pd.opt+conopt,u
         ldd   pd.d2p-pd.opt,x
         std   pd.d2p-pd.opt+conopt,u
*
         lda   mpth
         ldb   #SS.opt
         leax  imopt,U
         os9   I$GetStt        save modem pth options
         tfr   pc,y
         lbcs  gmt190          exit with err msg if GetStt error
         lda   pd.par-pd.opt,x        copy all hardware affecting opts
         sta   pd.par-pd.opt+mopt,u
         ldb   pd.bau-pd.opt,x
         stb   pd.bau-pd.opt+mopt,u
         std   baudpar
         ldd   pd.d2p-pd.opt,x
         std   pd.d2p-pd.opt+mopt,u
*
         lbsr  gmt811          set run time console options
         lbsr  gmt812          set run time modem options
gmt119   equ   *
         leax  gmtsig,pcr      setup trap
         OS9   F$ICPT          to handle quit signal
         leax  HintMsg,PCR
         ldy   #LHintMsg
         lda   #stdout
         OS9   I$Write
         lbsr  gmt801          issue beep
         bra   gmt120          go to main loop
*
         ttl  XCom9   Main processing loop
         page

*
*        MAIN PROCESSING LOOP
*
GMT120   equ   *
         lda   kildflg         are we killed?
         bne   gmt191          go if yes
         bsr   gmt200          process any keyboard input
         lda   xmdmflg         are we in xmodem mode?
         bne   gmt124          go if yes
*
gmt122   equ   *               not in xmodem mode
         lbsr  gmt220          process modem input
         lda   sndflg          time to send more of disk file?
         beq   gmt120          go if not
         lbsr  gmt230          send chunk of disk file
         bra   gmt120          go repeat loop
*
gmt124   equ   *               xmodem mode
         clr   chlen
         clr   chlen+1
         leax  ch,u
         stx   bpoint
         lda   Xstate          is xmodem
         cmpa  #XS.IniS        started yet?
         beq   gmt124b         go if not
         lbsr  gmt600          do xmodem
         bra   gmt120
gmt124b  lbsr  gmt220          process modem input
         bra   gmt120
*
GMT190   equ   *               clean up and exit pgm with err msg
         lbsr  gmt804          sho pc,cc,a,b at time of err
GMT191   equ   *               exit with no err msg
         lbsr  gmt813          restore console options
         lda   xmdmflg         are we in xmodem mode?
         beq   gmt192          go if not
         lbsr  gmt695          exit xmodem mode by op command
gmt192   lda   rpth
         beq   gmt193          go if no rcv pth open
         lda   ascflg          in ascii mode?
         beq   gmt192b         go if not
         ldb   #C$CR           store a CR  as last chr in file
         ldx   rcvptr,u
         stb   ,x+
         stx   rcvptr,u
gmt192b  lbsr  gmt855          flush the rcv buff to disk
gmt193   lda   mpth
         ldb   #SS.opt
         leax  imopt,u
         os9   I$SetStt        restore modem path options
         clrb
gmt194   OS9   F$Exit          end
*
         ttl  first level subroutines
         page
*        FIRST LEVEL SUBROUTINES
*
GMT200   equ   *               process keyboard input 1 chr at a time
         lda   #stdin
         ldb   #SS.Ready
         os9   I$GetStt        any data ready?
         bcc   gmt201          go if yes
         cmpb  #E$NotRdy
         tfr   pc,y            save pc for err msg
         bne   Gmt190          abort if real error
         rts                   return if no data
gmt201   equ   *
         ldy   #1              number of chars to get
gmt201a
         cmpy  #8
         ble   inok
         ldy   #8
inok
         leax  och,u           buffer to put them in
         lda   #stdin          path to use
         os9   I$Read
         sty   chinpt
         bcc   gmt202
         lda   #'?             substitute invalid char?
         sta   och
gmt202   lda   och              get char for furhter proc
         cmpa  #$0D            CR?
         bne   ncr
         lda   echflg
         beq   rcr
         leax  addlf,PCR
         ldy   #ladd
         lda   #stdout
         os9   I$Write
rcr
         lda   #$0D
         ldy   chlen
         leax  och,u
ncr
         ldb   cmdflg          was prev char a cmd prefix?
         bne   gmt206          go if yes
*     we are not yet in command mode
         cmpa  cmdchr          curr char cmd prefix?
         bne   gmt203          if not go handle as data
         clr   cmdflg
         com   cmdflg          set cmdflg mode for next char
         lbsr  gmt800          issue beep for command
         rts
gmt203   cmpa  #TGLR           is curr char tgl receiver
         bne   gmt205          go if not
         ldb   rpth            is a path open?
         beq   gmt203a         go if not
         com   rcvflg          toggle the flag
         lbra  gmt410          show options
gmt203a  rts
gmt205   leax  och,u            addr of buffer
         ldy   chinpt          len of buffer
         lda   xmdmflg         are we in xmodem mode?
         beq   gmt205a         go if not
         lda   xstate          get xmodem state
         cmpa  #XS.IniS        is xmodem started yet?
         beq   gmt205b         if not go send to modem port
         rts                   when running xmodem dont mix in kbrd
gmt205a  lda   sndflg          are we sending file? not in xmodem
         bne   gmt205c         dont merg krbd data if yes
gmt205b  lbsr  gmt820          send to modem - maybe
gmt205c  lda   echflg          is local echo on?
         beq   gmt205z         bypass logging if not (mdm port will log)
         lbsr  gmt850          log to disk   - maybe
gmt205z  rts
*
*   we are in command mode - process command char
*
gmt206   lbsr  gmt860          convert to upper case - maybe
         clr   escrec
         clr   chlen
         clr   chlen+1
         leax  ch,u
         stx   obp
         stx   bpoint
         ifeq  mylev-2
         pshs  a
         leax  EWind,PCR
         ldy   #LEWind
         lda   #stdout
         OS9   I$Write
         puls  a
         endc
         cmpa  #'0
         blo   notmacro
         cmpa  #'9
         bhi   notmacro
         clr   cmdflg
         lbra  macro
notmacro
         cmpa  #dircmd
         bne   shellchk
         lbsr  chdir
         clr   cmdflg
         rts
shellchk
         cmpa  #shlcmd
         bne   gmt207
         lbsr  gmt400          do shell command
         clr   cmdflg
         rts
gmt207   cmpa  #optcmd
         bne   gmt207a
         lbsr  gmt410          sho option settings
         clr   cmdflg
         rts
gmt207a  cmpa  #hlpcmd
         bne   gmt207b
         lbsr  gmt420          sho cmd menu
         clr   cmdflg
         rts
gmt207b  cmpa  #qutcmd         quit?
         bne   gmt207c         go if not
         clr   kildflg
         com   kildflg
         clr   cmdflg
         rts
gmt207c  cmpa  #echcmd
         bne   gmt207d
         com   echflg
         lbsr  gmt811          set echo option on path
         clr   cmdflg
         lbra  gmt410
gmt207d  cmpa  #asccmd         toggle parity stripping?
         bne   gmt207e         go if not
         com   ascflg
         pshs  cc
         lbsr  gmt410
         puls  cc
         beq   notascii
         lbsr  deftab
notascii
         clr   cmdflg
         rts
gmt207e  cmpa  #ymdmcmd
         bne   gmt207f
         ldd   #1024
         std   XDatSiz
         ldd   #1028
         std   XBlkSiz
         lbsr  gmt590          setup for ymodem
         clr   cmdflg
         rts
gmt207f  cmpa  #flocmd
         bne   gmt207g
         lbsr  gmt430          get xon/xoff chars
         clr   cmdflg
         lbra  gmt410
gmt207g  cmpa  #rcvcmd
         bne   gmt207k
         lbsr  gmt450          open receiver path
         clr   cmdflg
         lbra  gmt410
gmt207k  cmpa  #sndcmd
         bne   gmt207l
         lbsr  gmt460          open file to send
         bcs   gmt207kz        go if file not opened
         lbsr  gmt465          check sending mode
gmt207kz clr   cmdflg
         lbra  gmt410
gmt207l
         ifeq  mylev-2
         cmpa  #etrcmd         external transfer protocol?
         bne   gmt207m         go if not
         lbsr  exttran
         clr   cmdflg
         rts
         endc
gmt207m  cmpa  #xprcmd
         bne   gmt207n
         ldd   #128
         std   XDatSiz
         ldd   #132
         std   XBlkSiz
         lbsr  gmt590          setup for xmodem
         clr   cmdflg
         rts
gmt207n  cmpa  #adlcmd
         bne   gmt207o
         lbsr  dial
         clr   cmdflg
         rts
gmt207o  cmpa  #C$CR           null command?
         beq   gmt209
         cmpa  #brkcmd         send break?
         bne   gmt207p
         lbsr  gmt440
         clr   cmdflg
         rts
gmt207p  cmpa  #baucmd         change baud rate?
         lbeq  setbaud
gmt207t  cmpa  #TGLR
         beq   gmt207u
         cmpa  cmdchr
         bne   gmt207v
gmt207u  leax  och,u            come here to send special
         ldy   #1              chars like ^R,^N
         sta   och              to modem
         sty   chinpt
         lbsr  gmt820          send to modem - maybe
         clr   cmdflg
         rts
*
gmt207v  lbsr  gmt920          print inv cmd msg
         clr   cmdflg
         rts
gmt208   lbsr  gmt802          show not implemented msg
gmt209   clr   cmdflg          clear command state?
         rts
*
*        process modem input   time critical
*
GMT220   equ   *
         lda   mpth
         ldb   #SS.Ready
         os9   I$GetStt        newer versions ret # of chars in B
         bcc   gmt221          go if char is avail
         cmpb  #E$NotRdy
         beq   gmt220z
         tfr   pc,y            save pc for err msg
         lbsr  gmt804          sho error msg
gmt220z
         clr   chlast
         lda   escrec
         bne   gmt226
         rts
gmt221   equ   *               get char from modem path
*        GetStt leaves A=path number, B=number of chars
         lbsr  gmt816          read as many as possible on modem pth
         ldd   chlen           were any chars read?
         beq   gmt228a         go if not
         lda   ascflg          are we in ascii mode?
         beq   gmt226          go if not
         lbsr  gmt810          ascify a ch buffer
gmt226   equ   *
         ldd   chlen
         cmpd  #lkeybuf-10
         bhs   outputc
         lda   chlast
         beq   outputc
         clr   escrec
         ldx   obp
         lda   -1,x
         cmpa  #$1B
         bne   escchk
         cmpa  ,x
         bne   escchk
         pshs  x
         lbsr  IDReq
         puls  x
         clra
         sta   ,x
         sta   -1,x
escchk
         clrb
escloop
         lda   ,x+
         cmpa  #$05
         beq   escchar
         cmpa  #$1F
         beq   escchar
         cmpa  #$1B
         bne   noescch
         lda   ,x
         cmpa  #$1B            ESC ESC?
         bne   escchar
         pshs  x,b
         lbsr  IDReq
         puls  x,b
         clra
         sta   ,x
         sta   -1,x
escchar
         inc   escrec
noescch
         incb
         cmpb  chlast
         bne   escloop
         lda   escrec
         beq   outputc
         ldx   #5
         os9   F$Sleep
         rts
outputc
         leax  ch,u
         stx   obp
         stx   bpoint          reset pointer
         lda   vuflg           sho mdm data on crt?
         beq   gmt228          go if not
         ldy   chlen
         lda   echflg
         lbne  echout
         lda   #stdout
         OS9   I$Write         sho mdm traffic on crt
gmt228   lbsr  gmt850          log   it maybe
gmt228a  ldb   spth            sending file open?
         beq   gmt228z         go if not
         ldb   smode           are we in stop and go mode?
         beq   gmt228z         go if not
         leax  ch-1,u          offset = len-1
         ldd   chlen           point to last char in the buffer
         lda   d,x             get it
         anda  #Poff           mask parity
         cmpa  smode           is it the char that ends the prompt?
         bne   gmt228z         go if not
         clr   sndflg
         com   sndflg          unstop the sender
gmt228z
         clra
         clrb
         std   chlen           clear length received
         rts                   back to mainline gmt120
*
*        send a disk file
*
GMT230   lda   spth            is a send path open?
         beq   gmt233          go if not
         leax  sndtxt,u
         ldy   #MaxTxSiz       should be less than acia buff siz (70-80)
         ldb   smode           are we in stop and go mode?
         beq   gmt231b         go if not
         ldy   #datasiz        if yes expect cr in here somewhere
gmt231b  lda   spth
         os9   I$ReadLn        Y is adjusted for bytes read
         bcc   gmt234          go if no read errs
         cmpb  #E$EOF          end of file error?
         beq   gmt232          if yes go close the file
         OS9   F$Perr          if not print err msg number
         leax  rderr,pcr
         ldy   #Lrderr
         lda   #stdout         print warning message
         OS9   I$Write
gmt232   lda   spth
         os9   I$Close
gmt233   clr   spth
         clr   sndflg
         clr   smode
         lbsr  gmt801          beep user at EOF
gmt233z  rts
gmt234   equ   *               x points to buf, y=len
         lda   ascflg          are we in ascii mode?
         beq   gmt234b         go if not
         tfr   y,d
         subd  #1              calc offset to last char
         lda   d,x             get last char
         cmpa  #C$CR           is it carr ret
         bne   gmt234b         go if not
         pshs  x
         tfr   y,d             length again
         leax  d,x             point one past the CarrRet
         lda   #C$LF
         sta   ,x              turn cr into cr/lf
         leay  1,y             bump send count
         puls  x               restore start of buffer
gmt234b  lbsr  gmt820          send to modem     maybe
         lbsr  gmt840          send to screen  - maybe
         ldb   smode           are we in stop and go mode?
         beq   gmt234z         go if not
         clr   sndflg          mark us as stopped if yes
gmt234z  rts
rderr    fcb   C$LF,C$BELL
         fcc   "Error reading file to txmit"
         fcb   C$CR,C$LF
Lrderr   equ   *-rderr
addlf    fcb   $0A,$0D
ladd     equ   *-addlf
echout
         pshs  x,y
         lda   ,x
         cmpa  #$0D
         bne   notacr
         leax  addlf,PCR
         ldy   #ladd
         bra   outecho
notacr
         cmpa  #$0A
         beq   skiplf
         ldy   #1
outecho
         lda   #stdout
         os9   I$Write
skiplf
         puls  x,y
         leax  1,x
         leay  -1,y
         cmpy  #0
         bne   echout
         leax  ch,u
         ldy   chlen
         lbra  gmt228
         ifeq  mylev-1
IDTerm   fcc   "XCOM9 Ver 12 Level 1"
         fcb   $0D
LIDTerm  equ   *-IDTerm
         else
IDTerm   fcc   "XCOM9 Ver 12 Level 2"
         fcb   $0D
LIDTerm  equ   *-IDTerm
         endc
IDReq
         leax  IDTerm,PCR
         ldy   #LIDTerm
         lda   mpth
         OS9   I$Write
         lda   #stdout
         ldb   #SS.ScSiz
         OS9   I$GetStt
         pshs  y
         tfr   x,d
         lbsr  gmt830
         leax  och,u
         ldb   #1
         lbsr  gmt838
         lda   #$0D
         leax  och,u
         sta   2,x
         ldy   #3
         lda   mpth
         OS9   I$Write
         puls  d
         lbsr  gmt830
         leax  och,u
         ldb   #1
         lbsr  gmt838
         lda   #$0D
         leax  och,u
         sta   2,x
         ldy   #3
         lda   mpth
         OS9   I$Write
         rts
*+++++++++
 use   xcom9_subs1.asm     command processing (400-580)
*---------
*+++++++++
 use   xcom9_xsubs.asm     xmodem processing (590-790)
*---------
*+++++++++
 use   xcom9_subs2.asm     utility routines (800-990)
*---------
*+++++++++
 ifeq  mylev-2
 use   xcom9_wind.asm      Level2 Window Handling
 endc
*---------
         emod                  CRC bytes
GMTLEN   equ   *
