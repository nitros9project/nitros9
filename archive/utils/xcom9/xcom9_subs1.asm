         ttl  Command routines
*
*        shell command subroutine
*
shlname  fcs   "SHELL"
shlprmt  equ   *
         fcb   $0C
         fcc   "<< XCOM9 shell gateway >>"
         fcb   $0A
         fcc   "Use EX<ENTER> or <ESC> to exit."
spram    fcb   $0D
Lshlprmt equ   *-shlprmt
GMT400
         ifeq  mylev-2
         lda   #0              Normal colors
         ldb   #1              Save on
         ldx   #0              start Start Position=0,0
         ldy   #$5018          Size= 80x24 window
         lbsr  OpenWin
         endc
         lbsr  gmt813          set console options to standard
         ldy   #Lshlprmt
         leax  shlprmt,pcr
         lda   #stdout
         OS9   I$WritLn
*      set up for fork
         pshs  u
         leau  spram,pcr
         leax  shlname,pcr
         clrb                  no extra memory
         lda   #prgrm+objct    shell module type
         os9   F$Fork          start shell
         puls  u
         OS9   F$Wait          wait for shell to finish
         tstb                  check shell return code
         beq   gmt409          go if no error
         os9   F$Perr          show error in shell
gmt409   lbsr  gmt811          set console options for modem
         ifeq  mylev-2
         lbsr  CloseWin
         endc
pgm      lbsr  gmt801          beep all done
         rts
*
*        display options settings
*
*        options display offsets
Optmsg   equ   *
         fcb   C$CR,C$LF,$0C
         fcc   "~ASC  ~ECH  FLO=  ,    ~MDM"
         fcc   "  ~RCV=             ~SND="
         fcc   "             ~VU ~XMD"
Loptmsg  equ   *-optmsg
Oasc     equ   3                   ~ - 6
Oech     equ   Oasc+6              ~ - 11
Ofon     equ   Oech+10             xx  21
Ofoff    equ   Ofon+3              zz  24
Omdm     equ   Ofoff+4             ~   28
Orcv     equ   Omdm+6              ~   34
Orcvnam  equ   Orcv+5              rrr 39
Orcvlen  equ   12
Osnd     equ   Orcvnam+Orcvlen+1   ~   52
Osndnam  equ   Osnd+5              sss 57
Osndlen  equ   12
Oview    equ   Osndnam+Osndlen+1   ~   70
Oxmdm    equ   Oview+4             ~   76
GMT410   equ   *
         ifeq  mylev-2
         lda   #1              Inverse
         ldb   #0              No save
         ldx   #0              Start Position=0,0
         ldy   #$5001          Size= 80x1
         lbsr  OpenWin
         endc
         ldb   #Loptmsg
         leax  msgbuf,u        scratch area for options msg
         leay  optmsg,pcr      src ptr
         lbsr  gmt807          block move
         leax  msgbuf+orcvnam,u
         leay  rpthnam,u
         ldb   #orcvlen        max chars to copy
         lbsr  gmt808          copy pth name to buffer
         leax  msgbuf+osndnam,u
         leay  spthnam,u
         ldb   #osndlen
         lbsr  gmt808
         lda   xonchr
         lbsr  gmt880          convert binary to ascii hex
         std   Ofon+msgbuf,u
         lda   xoffchr
         lbsr  gmt880
         std   Ofoff+msgbuf,u
         leax  msgbuf,u
         ldb   #C$Spac
         lda   ascflg          is ascii flg off?
         beq   gmt411a         go if yes
         stb   oasc,x          erase not symbol (~)
gmt411a  lda   echflg
         beq   gmt411b
         stb   oech,x
gmt411b  lda   mdmflg
         beq   gmt411c
         stb   omdm,x
gmt411c  lda   rcvflg
         beq   gmt411e
         stb   orcv,x
gmt411e  lda   sndflg
         beq   gmt411f
         stb   osnd,x
gmt411f  lda   xmdmflg
         beq   gmt411g
         stb   oxmdm,x
gmt411g  lda   vuflg
         beq   gmt412
         stb   oview,x
gmt412   ldy   #Loptmsg
         lda   #stdout
         os9   I$Write
         bcc   gmt419
         os9   F$Perr
gmt419   equ   *
         ifeq  mylev-2
         lbsr  CloseWin
         endc
         rts
*
*
*
*        display command menu (HELP command)
*
Menumsg  equ   *
         fcb   5,32     Turn off cursor
         fcb   C$CR
         fcb   C$LF
         fcb   $0C
         fcc   "@  Send break if supported"
         fcb   $0D,$0A
         fcc   "$  Shell command"
         fcb   $0D,$0A
         fcc   "/  Change directory"
         fcb   $0D,$0A
         fcc   "A toggle Ascii,strip CTRL codes"
         fcb   $0D,$0A
         fcc   "B  set Baud rate"
         fcb   $0D,$0A
         fcc   "D  Auto dial (RS232 Pak only)"
         fcb   $0D,$0A
         fcc   "E  toggle local Echo mode"
         fcb   $0D,$0A
         fcc   "F  specify Flow ctl (xon/xoff)"
         fcb   $0D,$0A
         fcc   "O  show Option settings"
         fcb   $0D,$0A
         fcc   "Q  Quit - end XCom9"
         fcb   $0D,$0A
         fcc   "R  Receive a file ASCII"
         fcb   $0D,$0A
         fcc   "S  Send a file ASCII"
         fcb   $0D,$0A
         ifeq mylev-2
         fcc   "T  Ext transfer protocol(s)"
         fcb   $0D,$0A
         endc
         fcc   "X  send/receive XMODEM protocol"
         fcb   $0D,$0A
         fcc   "Y  send/receive YMODEM protocol"
         fcb   $0D,$0A
         fcc "CTRL-R Opens/Closes rec Buff"
Lmenumsg equ   *-menumsg
EWind   fcb   $1B,$23
         fcb   5,33     Turn on cursor
LEWind   equ   *-EWind
GMT420   equ   *
         ifeq  mylev-2
         lda   #1       Inverse
         ldb   #1       Save
         ldx   #$1703   Start Position=23,3
         ldy   #$2010   32x16
         lbsr  OpenWin
         endc
         lda   #stdout
         leax  menumsg,pcr
         ldy   #Lmenumsg
         OS9   I$Write
         ifeq  mylev-2
         leax  -1,s
         ldy   #1
         lda   #0
         OS9   I$Read
         lbsr  CloseWin
         endc
         leax  EWind,PCR
         ldy   #LEWind
         lda   #stdout
         OS9   I$Write
         rts
*
*        prompt for xon/xoff chars
*              (note these are chars from remote to our modem port
*               NOT that we send to remote)
*
xonprmt  fcb  C$CR,C$LF,C$BELL,$0C
         fcc   "Enter XON as 2 hex digits: "
Lxonprmt equ   *-xonprmt
xoffprmt fcb  C$CR,C$LF,C$BELL,$0C
         fcc   "Enter XOFF as 2 hex digits: "
Lxofprmt equ   *-xoffprmt
GMT430   lbsr  gmt813              set std options on stdin

         ifeq  mylev-2
         lda   #1                  Inverse
         ldb   #1                  Save
         ldx   #0                  Start Position=0,0
         ldy   #$5001              Size= 80x1
         lbsr  OpenWin
         endc
gmt431
         leax  xonprmt,pcr
         ldy   #lxonprmt
         lda   #stdout
         os9   I$Write
         lbsr  gmt890          get a hex byte in a
         bcs   gmt431          go if invalid hex
         sta   xonchr
gmt432   leax  xoffprmt,pcr
         ldy   #Lxofprmt
         lda   #stdout
         os9   I$Write
         lbsr  gmt890
         bcs   gmt432
         sta   xoffchr
         lbsr  gmt812          activate the xon/xoff options
         lbsr  gmt811          clear most stdin options
         ifeq  mylev-2
         lbsr  CloseWin
         endc
         rts
*
*
*        Send a BREAK - 6551 acia version
*
*
*              Send A Break (long spacing condition)
*                           6551 ACIA only
GMT440   equ   *               send a break - 6551 only
*                 seems to lose any data occurring immediately
*                 after the break
CmdReg   equ   2               offset to chip cmd register
BrkMask  equ   %00001100       bits in CSR to set for break
RecIntD  equ   %00000010       disable rcv interrupt bit (or)
*
         bra   SendBrk
GetAdd
         pshs  x,y,u
         ldx   parmptr         get ptr to dev name string
         lda   ,x
         cmpa  #'/             does name begin with slash?
         bne   gmt440a         go if not
         leax  1,x             mem module names have no slashes
gmt440a  lda   #Devic+objct    module type
         os9   F$Link          link to module return ptr in U
         bcc   gmt440b
         bra   gmt440y
gmt440b  ldd   M$Port+1,u      get low 16 bits of chip address
         pshs  d               save 16bit chip address
         os9   F$Unlink        dev descr no more use
         bcc   gmt440c
         leas  2,s
         bra   gmt440y
*
gmt440c  puls  d               d points to chip hardware
         puls  x,y,u,pc
SendBrk
         bsr   GetAdd
         pshs  x,y,u
         tfr   d,y
         lda   CmdReg,y        get csr value
         pshs  a               Save it
         ora   #BrkMask        set break bits
         ora   #RecIntD        disable interupts
         sta   CmdReg,y        zap the chip
         ldx   TiksPbrk,pcr    how many tiks to wait for a break
         os9   F$Sleep         leave chip zapped
         puls  a               get the proper csr value
         sta   CmdReg,y        clear break/setup chip
         puls  x,y,u,pc        normal exit - clean stack and return
gmt440y  os9   F$Perr          error exit
gmt440z  puls  x,y,u,pc        clean stack and return
*
*        Setup the RCV path to disk
*
rcvprmt  equ   *
         fcc   "Filename to receive to (e.g. /d1/rxfile)? "
Lrcvprmt equ   *-rcvprmt
GMT450   lda   rpth            is path active
         beq   gmt451          go if not
         lda   ascflg          is mode ascii?
         beq   gmt450c         go if not
         ldx   rcvptr,u        get current buff pos
         lda   #C$CR           be sure file ends with
         sta   ,x+              a CR
         stx   rcvptr,u
gmt450c  lbsr  gmt855          flush rcv buffer
         lda   rpth
         os9   I$Close
         clr   rpth
         clr   rcvflg
gmt451
         ifeq  mylev-2
         lda   #1              Inverse
         ldb   #1              Save
         ldx   #0              Start Position=0,0
         ldy   #$5001          Size= 80x1
         lbsr  OpenWin
         endc
         leax  rcvprmt,pcr
         leay  rpthnam,u
         ldb   #Lrcvprmt
         lbsr  gmt950          prompt and get path name
         bcs   gmt459          go if only 1 char
         leax  rpthnam,u
         lda   #WRITE.
         ldb   #READ.+WRITE.+EXEC. attributes
         os9   I$Create
         bcc   gmt456
         os9   F$PERR
         leax  rpthnam,u
         lbsr  gmt990          tell user open error
         orcc  #SetCarry       and tell caller too
         lbra  eovlay
gmt456   sta   rpth
         clr   rcvflg
         com   rcvflg          make rx active
         lbsr  gmt801          beep to tell user now ready
         andcc #ClrCarry       and tell caller ok
         bra   eovlay
gmt459   lbsr  gmt801          beep to tell user rcv file closed
         orcc  #SetCarry       tell caller no file open
eovlay   equ   *
         ifeq  mylev-2
         lbsr  CloseWin
         endc
         rts
macro    pshs  a
         lda   spth
         beq   omspth
         OS9   I$Close
omspth   clr   spth
         clr   sndflg
         clr   smode
         leay  macrofl,PCR
         leax  spthnam,u
         ldb   #lmacrofl
         lbsr  gmt807
         leax  spthnam,u
         puls  a
         sta   lmacrofl,x
         lda   #$0D
         sta   lmacrofl+1,x
         lbra  macopen
*
*
*
*        Setup the SND path from disk
*
sndprmt  equ   *
         FCB   C$CR,C$LF,C$BELL
         fcc   "Filename to send (e.g. /d1/txfile)? "
Lsndprmt equ   *-sndprmt
GMT460   lda   spth            is path active
         beq   gmt461          go if not
         os9   I$Close
gmt461   clr   spth
         clr   sndflg
         clr   smode
         ifeq  mylev-2
         lda   #1              Inverse
         ldb   #1              Save
         ldx   #0              Start Position=0,0
         ldy   #$5001          Size= 80x1
         lbsr  OpenWin
         endc
         leax  sndprmt,pcr
         leay  spthnam,u
         ldb   #Lsndprmt
         lbsr  gmt950          prompt and get path name
         bcs   gmt461z         go if only 1 char
         leax  spthnam,u
macopen
         lda   #READ.
         os9   I$Open
         bcc   gmt462
         os9   F$PERR
         clr   spth
         clr   sndflg
         leax  spthnam,u
         lbsr  gmt990          tell user open error
gmt461z  orcc  #SetCarry       tell caller no file
         lbra  eovlay
gmt462   sta   spth
         clr   sndflg
         com   sndflg          make sender active
gmt464   andcc #ClrCarry       and tell caller ok
gmt464z  lbra  eovlay
*
*
Sgoprmt  fcb   C$LF,C$CR
         fcc   "Y:<CR> waits for a colon, Y<CR> waits for a <CR>"
         fcb   C$CR,C$LF
         fcc   "Wait for prompt char between lines? "
Lsgoprmt  equ   *-Sgoprmt
GMT465   equ   *               set mode of file sending
         clr   smode           set mode as not stop and go
         lbsr  gmt813          set stdin options
         ifeq  mylev-2
         lda   #1              Inverse
         ldb   #1              Save
         ldx   #0              Start Position=0,0
         ldy   #$5002          Size= 80x2
         lbsr  OpenWin
         endc
gmt466b
         leax  sgoprmt,pcr
         ldy   #Lsgoprmt
         lda   #stdout
         os9   I$Write         prompt user for send mode
         leax  ch,u
         ldy   #8              should be y,chr or n
         os9   I$ReadLn        allow editing
         bcs   gmt466b         bad read try again
         lda   ch              get first char
         lbsr  gmt860          make it upper case
         cmpa  #'Y             is it Y?
         bne   gmt469z         go if not
         lda   ch+1            get next char
         cmpa  #C$Spac         is it space
         bne   gmt466c         if not go make it prompt char
         lda   ch+2            else third char is prompt char
gmt466c  anda  #Poff           be sure no parity
         sta   smode           set smode to prompt char
gmt469z  lbsr  gmt811          set stdin options to comm mode
         ifeq  mylev-2
         lbsr  CloseWin
         endc
         rts
***********************
* Set baud routine
* Added 01/31/88 by
* The Doctor
*
baudprmt fcb   $0D,$0A
crlf     equ   *-baudprmt
         fcb   $0C
         fcc   "(1) 300        (2) 600"
         fcb   $0D,$0A
         fcc   "(3)1200        (4)2400"
         fcb   $0D,$0A
         fcc   "(5)4800        (6)9600"
         fcb   $0D,$0A
         fcc   "(7)19200"
         fcb   $0D,$0A
         fcc   "Select baud ->"
lbdprmt  equ   *-baudprmt
parprmt  fcb   $0D,$0A,$0C
         fcc   "N)one          S)pace parity"
         fcb   $0D,$0A
         fcc   "E)ven parity   O)dd parity"
         fcb   $0D,$0A
         fcc   "Select parity (None=8 bits) ->"
lparprmt equ   *-parprmt
setbaud  lbsr  gmt813              set std options on stdin
         ifeq  mylev-2
         lda   #1
         ldb   #1
         ldx   #$1709
         ldy   #$2005
* If you haven't figured it out by now...
         lbsr  OpenWin
         endc
getbaud
         leax  baudprmt,PCR
         ldy   #lbdprmt
         lda   #stdout
         os9   I$Write
         lda   #0
         pshs  a
         leax  ,s
         ldy   #1
         os9   I$Read
         puls  a
         cmpa  #'1
         blo   getbaud
         cmpa  #'7
         bhi   getbaud
         anda  #$0F
         pshs  a
getpar   leax  parprmt,pcr
         ldy   #lparprmt
         lda   #stdout
         os9   I$Write
         pshs  a
         leax  ,s
         ldy   #1
         lda   #0
         os9   I$Read
         puls  a
         anda  #$5F
         cmpa  #'N
         bne   parity
         clra
         puls  b
         andb  #$7
         pshs  b
         bra   setpar
parity
         puls  b
         orb   #$20
         pshs  b
         cmpa  #'S
         bne   NotSpace
         lda   #$E0
         bra   setpar
NotSpace
         cmpa  #'E
         bne   NotEven
         lda   #$60
         bra   setpar
NotEven
         cmpa  #'O
         bne   getpar
         lda   #$20
setpar
         puls  b
         tfr   d,y
         sty   baudpar
         lda   mpth
         ldb   #$28
         os9   I$SetStt
         lbcs  gmt208
         lbsr  gmt811          clear most stdin options
         leax  baudprmt,PCR
         ldy   #crlf
         lda   #stdout
         os9   I$Write
         ifeq  mylev-2
         lbsr  CloseWin
         endc
         clr   cmdflg
         rts
*******************************
* Define ASCII translate table
* By
*   The Doctor
*
chngmess
         fcb   $0A,$0D,$0C
         fcc   ">> ASCII Translate Mode <<"
         fcb   $0A,$0D,$0A,$0D
         fcc   "Press <ENTER> to use defaults."
         fcb   $0A,$0D
         fcc   "Change translation? (Y/N):"
lchng    equ   *-chngmess
cls      fcb   $0A,$0D,$0C,$05,$21
         ifeq  mylev-2
         fcb   $1B,$23
         endc
lcls     equ   *-cls
from     fcb   $0A,$0D,$0C
         fcc   "ASCII code to change in hex: "
lfrom    equ   *-from
to       fcb   $0A,$0D,$0C
         fcc   "Change to: "
lto      equ   *-to
again    fcb   $0A,$0D,$0C
         fcc   "Change another? (Y/N):"
lagain   equ   *-again
deftab
         ifeq  mylev-2
         lda   #1
         ldb   #1
         ldx   #$1709
         ldy   #$2005
         lbsr  OpenWin
         endc
redeftab
         leax   chngmess,PCR
         ldy   #lchng
         lda   #stdout
         os9   I$Write
         pshs  a
         leax  ,s
         ldy   #1
         lda   #0
         os9   I$Read
         puls  a
         anda  #$5F
         cmpa  #13
         bne   chkn
         leax  cls,PCR
         ldy   #lcls
         lda   #stdout
         os9   I$Write
         leax  TranTab,u
         leay  AscFiltr,PCR
         ldb   #32
         lbra  gmt807     copy in defaults
chkn
         cmpa  #'N
         bne   chky
         leax  cls,pcr
         ldy   #lcls
         lda   #stdout
         os9   I$Write
         rts
chky
         cmpa  #'Y
         bne   redeftab
         lbsr  gmt813          Setup input options
         ldb   #0
         leax  TranTab,u
         pshs  x
fillloop stb   ,x+
         incb
         cmpb  #32
         bne   fillloop
*******************************
* Above loop sets no
* translation
*
domod
         leax  from,PCR
         ldy   #lfrom
         lda   #stdout
         os9   I$Write
         lbsr  gmt890      get asc code
         bcs   domod       if invalid do again
         cmpa  #$1F
         bhi   domod
         sta   ascflg      store here temporarily
doto
         leax  to,PCR
         ldy   #lto
         lda   #stdout
         os9   I$Write     write prompt
         lbsr  gmt890      get input
         bcs   doto        if not valid input
         puls  x           x points to table
         pshs  x           save it again
         ldb   ascflg
         sta   b,x         Store translation in table
what
         leax  again,PCR   Ask "do it again"
         ldy   #lagain
         lda   #stdout
         os9   I$Write     Write prompt
         leas  -1,s        Make space on stack
         lda   #0          stdin
         leax  ,s          Point x at buffer
         ldy   #1          1 character
         os9   I$Read      read i character
         puls  a           Get the character in a
         anda  #$5F        Make it upper case
         cmpa  #'N
         beq   endmod      No, end
         cmpa  #'Y
         beq   domod       Yes, again
         bra   what        Not 'Y' or 'N'!
endmod
         puls  x           Get x off stack!
         leax  cls,PCR     Clear screen / close window
         ldy   #lcls
         lda   #stdout
         os9   I$Write     Do it ^
         lbsr  gmt811
         lda   #$FF
         sta   ascflg      Set ascii mode
         rts
************************************
* Auto dial until carrier detected *
* RS232 Pak only                   *
************************************
dialprmt equ *
         fcb   $0D,$0A,$0C
         fcc   "Enter dial string: "
ldial    equ   *-dialprmt
nummess  equ *
         fcb   $05,$20
         fcc  "Dialing: "
lnummess equ   *-nummess
dial
         ifeq  mylev-2
         lda   #1
         ldb   #1
         ldx   #0
         ldy   #$5001
         lbsr  OpenWin
         endc
         leax  dialprmt,PCR
         ldy   #ldial
         lda   #stdout
         OS9   I$Write         Write input prompt
         lbsr  gmt813          Setup input options
         leax  dialbuff,u      Point x at buffer for input
         ldy   #32             32 Characters maximum
         lda   #0              stdin
         OS9   I$Readln        Get input
         cmpy  #1              Nothing but a CR?
         lbeq  enddial         If so, abort
         pshs  x,y             Save number, leng
         leax  cls,PCR
         ldy   #lcls
         lda   #stdout
         OS9   I$Write         Close window/clear screen
         puls  x,y             Recover dial string
         pshs  x,y             And save registers again
         bsr   printnum
         bra   dialloop        start dialing
printnum pshs  x,y             Save pointers to #
         ifeq  mylev-2
         lda   #1
         ldb   #1
         ldx   #0
         ldy   #$5001
         lbsr  OpenWin
         endc
         leax  nummess,PCR     Print "Dialing: "
         ldy   #lnummess
         lda   #stdout
         OS9   I$write
         puls  x,y             Recover number
         OS9   I$write         Print it
         rts
dialloop puls  x,y             Recover dial string
         pshs  x,y             And save registers again
         lda   mpth            Path to modem
         OS9   I$Write         Dial number
         ldx   #1000           Delay to wait for connect
         OS9   F$Sleep         Wait
         lda   #0              stdin
         ldb   #1              Check for input
         OS9   I$GetStt        Check for key press
         bcc   enddloop        If key pressed abort
         leax  cls,PCR         clear screen or close window codes
         lda   #stdout
         ldy   #lcls
         OS9   I$Write         do it ^
clrloop  lbsr  gmt220          print any modem input
         lda   mpth
         ldb   #1
         OS9   I$GetStt        Check for any more modem input
         bcc   clrloop         And print it if any
         lbsr  GetAdd
         tfr   d,y             Put port address in y
         lda   1,y             Get RS232 status
         anda  #32             Check for carrier
         beq   dialalrm        End if carrier
         puls  x,y             Recover dial string
         pshs  x,y             And save registers again
         bsr   printnum
         lda   mpth
         OS9   I$Close         Hangup modem
         ldx   #100            Delay to keep phone hung up
         OS9   F$Sleep         Wait
         ldx   parmptr         Get modem path name
         lda   #Updat.
         OS9   I$Open          Reopen modem path
         sta   mpth            And store the path number
         lbsr  gmt812          Reset tmode options on modem
         bra   dialloop
enddloop puls  x,y             Discard x,y on stack
enddial  leax  cls,PCR         Clear screen or close window
         ldy   #lcls
         lda   #stdout
         OS9   I$write         Do it ^
exitdial lbra  gmt811          Set tmode options for term
dialalrm lbsr  gmt801          Sound a beep
         ldb   #1              Check for input
         lda   #stdin
         OS9   I$GetStt
         bcs   dialalrm        No key yet, beep again
         puls  x,y
         bra   exitdial
*******************************
* Change directory subroutine *
*******************************
dirprmt
         fcb   $0A,$0C
         fcc   "Enter new data directory:"
         fcb   $0D
ldirprmt equ   *-dirprmt
chdir
         ifeq  mylev-2
         lda   #1              Inverse
         ldb   #1              Save
         ldx   #1              Position 0,1
         ldy   #$2002          Size 32x2
         lbsr  OpenWin
         endc
         lbsr  gmt813          Setup input options
getdir
         leax  dirprmt,PCR
         ldy   #ldirprmt
         lda   #stdout
         OS9   I$Writln
         leax  ch,u
         ldy   #32
         lda   #stdin
         OS9   I$ReadLn
         bcs   dirend
         lda   #3
         OS9   I$ChgDir
         pshs  b
         ifeq  mylev-2
         lbsr  CloseWin
         endc
         puls  b
         bcc   dirend
         lbsr  gmt811
         lda   #stdout
         OS9   F$PErr
dirend
         lbra  gmt811

         ifeq  mylev-2
shlprm   fcc   "-p"
         fcb   $0D
lshlprm  equ   *-shlprm
shfile   fcc   "/dd/cmds/exttran"
         fcb   $0D
exttran
         lda   #1
         ldb   #1
         ldx   #$1709
         ldy   #$2005
         lbsr  OpenWin
         lbsr  gmt813          set console options to standard
         clra
         os9   I$Dup
         sta   insav
         clra
         os9   I$Close
         leax  shfile,pcr
         lda   #1
         os9   I$Open
         bcs   abortext
         lda   #1
         os9   I$Dup
         sta   outsav
         lda   #1
         os9   I$Close
         lda   mpth
         os9   I$Dup
         pshs  u
         ldy   #lshlprm
         leau  shlprm,pcr
         leax  shlname,pcr
         clrb
         lda   #prgrm+objct    shell module type
         os9   F$Fork          start shell
         puls  u
         OS9   F$Wait          wait for shell to finish
         clra
         os9   I$Close
         lda   insav
         os9   I$Dup
         lda   #1
         os9   I$Close
         lda   outsav
         os9   I$Dup
         lda   outsav
         os9   I$Close
extabort
         lda   insav
         os9   I$Close
         lbsr  gmt811          set console options for modem
         lbsr  CloseWin
         clrb
         rts
abortext
         lda   insav
         os9   I$Dup
         bra   extabort
         endc
*
