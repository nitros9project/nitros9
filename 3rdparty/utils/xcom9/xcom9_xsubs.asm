         ttl  XCom9  Xmodem subroutines
         page
*
*        XMODEM Operator Command
*
XtotBpos set   40
XtotEpos set   73
XerrPos  set   59
XctrMsg  fcb   C$CR,C$LF,1,00,00,00
XYoff    equ   *-XctrMsg
         fcc   "Xmodem Counts  ToTal Blocks Tx/Rx=...... "
         fcc   "Consec Errs=.. Total Errs=......  "
CRCOffMsg equ   *-XctrMsg
         fcc   "    "
LXctrMsg equ   *-XctrMsg
CRCmess  fcc   "CRC"
TxRxPrmt fcb   C$CR,C$LF
         fcc   "Send or Receive [S/R]? "
LTxRxprm equ   *-TxRxPrmt
lfprmt   fcb   C$CR,C$LF
         fcc   "add/strip line feeds? (Y/N): "
llfprmt  equ   *-lfprmt
GMT590   equ   *
         lda   xmdmflg         are we in xmodem mode?
         beq   gmt590a         go if not
         lbsr  gmt695          exit with cancel msg if yes
         rts
gmt590a  ldd   #0
         sta   lastchr
         sta   XerrCtr
         std   XchrCtr
         sta   NXblkNum
         sta   OXblkNum
         std   XtotBlks
         std   XtotErrs
         sta   XcrcTyp         set to checksum
         sta   CNAKsent
gmt590c  lbsr  gmt813          set stdin opts to normal
         ifeq  mylev-2
         lda   #1              Inverse
         ldb   #1              Save
         ldx   #0              Start 0,0
         ldy   #$5001          Size 80x1
         lbsr  OpenWin
         endc
         lda   #stdout
         leax  TxRxPrmt,pcr    prompt for send or receive
         ldy   #LTxRxPrm
         os9   I$Write
         lda   #stdin
         leax  ch,u           get users reply to prompt
         ldy   #1              1 character, S or R
         os9   I$Read
         lda   ,x
         cmpa  #$0D            CR?
         bne   asklf           continue xmodem setup if no
         ifeq  mylev-2
         lbsr  CloseWin
         endc
         lbra  gmt595z
asklf
         leax  lfprmt,pcr
         ldy   #llfprmt
         lda   #stdout
         os9   I$Write         ask line feeds?
         leax  lfflg,u
         ldy   #1
         lda   #stdin
         os9   I$Read          get response
         lda   lfflg
         anda  #$5F            convert to upper
         cmpa  #'Y             check for Y or N
         beq   ynlf
         cmpa  #'N
         bne   asklf
ynlf     sta   lfflg           and store in flag
         ifeq  mylev-2
         lbsr  CloseWin
         endc
         lda   ch              get first char read in
         lbsr  gmt860          convert to UC
         cmpa  #'R
         bne   gmt591          go if not
         lbsr  gmt450          prompt for path name to receive to
         bcs   gmt590c         couldnt set up path try again
         ldd   lorcvptr,u      point to start of rcv buffer
         std   rcvptr,u
         lbsr  gmt814          clear all non essential mpath opts
         lbsr  gmt660          send initial NAK
         ldd   IniTMO,pcr      get 1st timeout value a=mins, b=secs
         lbsr  gmt780          setup timeout time
         bmi   gmt595z         if minus fatal error - exit xmodem
         lda   #XS.WSOH        set xmodem state to waiting for blk
         sta   xstate
         clr   Xsndflg
         clr   xmdmflg
         com   xmdmflg         sho we in xmodem mode right now
         lbsr  gmt410          show status settings
         lbsr  gmt790          show xmodem counters
         bra   gmt595          finish setup
*
gmt591   cmpa  #'S             does user want to send?
         lbne  gmt590c         repeat prompt if not
         lbsr  gmt460          setup and open file to send
         lbcs  gmt590c         couldnt setup file prompt again
         clr   sndflg          dont need this in xmodem mode
gmt593   clr   XsBlkNum        first blk number is 1
         lbsr  gmt740          get data from disk put in buffer
*                              740 will setup Xsndflg correctly
         lda   #XS.IniS        set state to waiting
         sta   xstate              for user to give Go cmd
         clr   xmdmflg
         com   xmdmflg         set flag to show in xmodem mode
         lbsr  gmt817          Clear waiting characters
         lbra  gmt670          Go send file
gmt595   equ   *
gmt595z  lbsr  gmt811          set stdin opts to XCom9 mode
         rts
*
*        XMODEM ROUTINES 600 & 700 Series
*
*
GMT600   equ   *               main xmodem processor
         lda   xstate
         cmpa  #XS.WSoh        we waiting for start of block? (rcv mode)
         bne   gmt602          go if not
         bsr   gmt610          see if blk hdr  avail or if timed out
         rts
*
gmt602   cmpa  #XS.RDat        in middle of data block? (rcv mode)
         bne   gmt603          go if not
         bsr   gmt620          get some data or see if timed out
         rts
*
gmt603   cmpa  #XS.WRsp        waiting for Rx to send an Ack? (or Nak)
         bne   gmt609          ignore state if not
         lbsr  gmt630          go get resp or time out
gmt609   rts
*
GMT610   equ   *               process start of data blk
         lda   mpth
         ldb   #SS.Ready
         os9   I$GetStt        any chrs on mdm path?
         bcc   gmt611          go if yes
         lbsr  gmt770          check if timeout
         bmi   gmt610z         go if too many errs/timeouts
         bcc   gmt610z         if no timeout then nothing to do yet
         lbsr  gmt660          non fatal timeout - send NAK
         clra                  be sure minus an carry are off
gmt610z  orcc   #SetCarry      valid header not received
         rts
gmt611   ldy   #1              get only 1 char from mdm path
         leax  ch,u
         os9   I$Read
         bcs   gmt610z         if error ignore for now
         sty   chlen
         lda   ch              get char read
         lbsr  gmt700          check if valid first char
         bmi   gmt610z         xmodem ended someway
         bcs   gmt610z         no work to do
         lda   ch              get the valid char (should be SOH)
         ldx   rcvptr,u
         sta   ,x+             save the char in rcv buff
         stx   rcvptr,u        update rcv ptr
         ldd   XchrCtr
         addd  #1              bump char ctr (should be 1)
         std   XchrCtr
         lda   #XS.RDat        and set state to ...
         sta   Xstate          ... receiving data
         rts
*
GMT620   equ   *               process middle & end of data blk
         lbsr  gmt640          get chrs from mdm port; process them
         lbmi  gmt629          go if fatal error occured
         lbcs  gmt629          go if nothing to do
GMT621   ldd   XChrCtr         get chr count in rx buff
         beq   NotCRCln
         pshs  d
         lda   XcrcTyp
         beq   NotCRCln
         puls  d
         addd  #-1
         pshs  d
NotCRCln
         puls  d
         cmpd  XblkSiz        is blk complete?
         lblo   gmt629         go if not
         lbgt   gmt626         fatal if too many in block - go abort
gmt625   ldx   lorcvptr,u      point to start of buffer (SOH)
         leax  1,x             point x to block numbers
         lbsr  gmt710          go check blk numbers update X
         lbmi   gmt629         go if 710 aborted xmodem
         lbcs   gmt628         bad blk numbers - send a NAK
         lda   XcrcTyp
         beq   chkchk
         pshs  x
         ldd   XdatSiz
         addd  #-1
         lbsr  CalcCRC
         puls  x
         tfr   d,y
         ldd   XdatSiz
         leax  d,x
         cmpy  ,x
         bne   gmt628
         bra   CRCok
chkchk
         lbsr  gmt720          calculate LRC in A - update X
         cmpa  ,x              does LRC match?
         bne   gmt628          no match - go send NAK
CRCok
         ldx   lorcvptr,u      go to start of buff again
         ldd   ,x++            get blk numb into B - update x
         cmpb  OXblkNum        we know blk num is good but is it re-Tx?
         beq   gmt627          go send an ACK if yes
         stb   OXblkNum        ELSE update last good blk numb ...
         ldd   XtotBlks
         addd  #1              and  update total good blks ctr ...
         std   XtotBlks
         leax  1,x             inc x by 1 to first data byte
         ldb   lfflg
         cmpb  #'N             remove lfs?
         beq   normlf          if not...
         tfr   x,y
         pshs  x
         ldd   XdatSiz
         pshs  d
         clra
         clrb
         pshs  d
rmreclf  lda   ,x+
         cmpa  #$0A
         beq   endrmlf
         sta   ,y+
         puls  d
         addd  #1
         pshs  d
endrmlf  ldd   XdatSiz
         addd  #-1
         std   XdatSiz
         cmpd  #0
         bne   rmreclf
         puls  d
         tfr   d,y
         puls  d
         std   XdatSiz
         puls  x
         bra   writxmod
normlf   ldy   XdatSiz        number of data bytes
writxmod lda   rpth
         os9   I$Write         write to disk
         bcc   gmt627          go if no errors
         os9   F$Perr          sho error
gmt626   lda   mpth
         leax  XCAN.,pcr
         ldy   #1
         os9   I$Write         send cancel to far end
         lbsr  gmt698          abort xmodem with h/w err
         rts                   return to caller
gmt627   lbsr  gmt665          +ve ack nowlegement and new timeout
         rts
gmt628   lbsr  gmt650          bump err count return minus if too many
         bmi   gmt629          dont send nak if too many errs
         lbsr  gmt660          send nak msg &setup new timeout
gmt629   rts
*
GMT630   equ   *               receive a response
         lda   mpth
         ldb   #SS.Ready
         os9   I$GetStt        is any data for me yet?
         bcc   gmt633          if yes go check response
         lbsr  gmt770          check if timed out
         bmi   gmt630a         too many timouts xmodem killed already
         bcc   gmt630a         if no timeout do nothing
         lbsr  gmt694          abort xmodem if timeout on txmit
gmt630a  rts                   no data and no timeout - do nothing
gmt633   equ   *           data ready on modem path
         leax  ch,u            point to buffer
         ldy   #1              read only 1 char
         os9   I$Read
         lda   ch              get char
         cmpa  #C$ACK          is it +ve ack?
         bne   gmt633c         go if not
*                              ACK recvd
         lda   Xsndflg
         cmpa  #XS.Seot        was eot last thing we sent?
         bne   gmt633a         go if not
         lbsr  gmt690          tell normal end/stop xmodem
         rts                   return with minus and carry set
gmt633a  lbsr  gmt740          prepare next buffer to send
         clr   XerrCtr         clear consecutive err ctr
         lbsr  gmt790          show the counters
         bra   gmt635          go send the block
*
gmt633c  cmpa  #C$CAN          does far end want to cancel?
         bne   gmt633e         go if not
         lbsr  gmt691          end xmodem with msg
         clra
         coma                  set minus and carry bits
         rts
*
gmt633e
         cmpa  #'C
         bne   NotCRCtx
         lbsr  gmt650          bad response bump error ctr
         bmi   gmt639          go if too many errors
         lda   #'C
         sta   XcrcTyp
         bra   gmt635
NotCRCtx
         cmpa  #C$NAK
         bne   gmt630          if not this was trash - get next chr
         lbsr  gmt650          bad response bump error ctr
         bmi   gmt639          go if too many errors
gmt635   equ   *  send a previously formatted buffer (ACK or NAK rcvd)
         lbsr  gmt730          send the block
         ldd   TxTMO,pcr       time to wait for ack
         lbsr  gmt780          setup timeout time
         bmi   gmt639          abort if fatal error
         lda   #XS.WRSP        set state to ...
         sta   xstate          ... waiting for response
         clra                  clear carry and minus bits
gmt639   rts
*
GMT640   equ   *               Rcv parts of a data blk
*                              returns minus set if xmodem aborted
*                                      carry set if no data for caller
         lda   mpth
         ldb   #SS.Ready
         os9   I$GetStt        any chrs on mdm path?
         bcc   gmt641          go if yes
         lbsr  gmt770          check if timeout
         bmi   gmt640z         go if too many errors
         bcc   gmt640z         if no timeout then nothing to do yet
         bsr   gmt660          non fatal timeout - send NAK
         clra                  be sure minus an carry are off
gmt640z  orcc  #SetCarry       tell caller no data yet
         rts
*
gmt641   equ   *               read chrs from modem path
         leax  ch,u
         stx   bpoint
         stx   obp
         clr   chlen
         clr   chlen+1
         clr   escrec
         clr   chlast
         lbsr  gmt816          get as many chrs as possble
*
gmt642   leay  ch,u            point to mdm buff
         ldx   rcvptr,u        point to disk buff
         ldd   chlen           get number of chars read into B
         beq   gmt642e         go if none read
gmt642d  lda   ,y+             copy chrs from mdmbuff to disk buff
         sta   ,x+
         decb
         bne   gmt642d
gmt642e  stx   rcvptr,u        copy done
         ldd   chlen           get number of chars read into B
         addd  XchrCtr         update chrs in rcv buff
         std   XchrCtr
         lda   #XS.RDat
         sta   xstate          got header now getting rest of data
         clrb                  tell caller no errs and data available
gmt649   rts                   all done
*
GMT650   equ   *               bump err ctr check against limit
         pshs  x,y
         inc   XerrCtr
         ldd   XtotErrs
         addd  #1
         std   XtotErrs        bump total errors
         lbsr  gmt790          show new error count
         ldb   XerrLim,pcr
         cmpb  XerrCtr         too many errors?
         ble   gmt650z         go if yes (carry an minus set)
         clrb                  clear carry and minus bits
         puls  x,y,pc
gmt650z  lbsr  gmt693          abort with err limit msg
         puls  x,y,pc          return with minus bit set
*
GMT660   equ   *               come here if rcvd chr not an ACK
         lda   mpth            get path to purge
         lbsr  gmt817          purge the line of chrs
         lbsr  gmt760          write nak msg to modem
         bra   gmt666
*
GMT665   equ   *               send +ve reply
         lbsr  gmt765          send ACK msg to modem
         clr   XerrCtr         start err count over
         lbsr  gmt790          show on crt
gmt666   ldd   RxTmo,pcr       get timeout value for Rx
         lbsr  gmt780          setup timeout time
         lda   #XS.WSoh        setup to wait ...
         sta   xstate          ... for next block
         clr   XchrCtr         no current chars in buffer
         clr   XchrCtr+1
         ldd   lorcvptr,u      and setup pointers that way too
         std   rcvptr,u
         rts
*
GMT670   equ   *               start xmodem transfer by Go cmd
         lda   #XS.WRsp        set state to waiting for response
         sta   xstate
         clr   xmdmflg
         com   xmdmflg         now we really in xmodem mode
         lbsr  gmt814          clear all non essential mpth opts
         ldd   TxTmo,pcr       setup initial timeout
         lbsr  gmt780
         lbsr  gmt410          sho option settings
         lbsr  gmt790          sho xmodem counts
         rts
*
*        Xmodem end routines   all return with carry and minus set
*
XeNorml  fcb   C$CR,C$LF,C$BELL
         fcc   "Exit Xmodem - Normal End"
         fcb   C$CR,C$LF
LXeNorml equ   *-XeNorml
GMT690   leax  XeNorml,pcr      setup msg pointers
         ldy   #LxeNorml
         lbra  gmt699           go do actual ending
*
XeCanRx  fcb   C$CR,C$LF,C$BELL
         fcc   "Exit Xmodem - Cancel Recvd"
         fcb   C$CR,C$LF
LXeCanRx equ   *-XeCanRx
GMT691   leax  XeCanRx,pcr      setup msg pointers
         ldy   #LxeCanRx
         lbra  gmt699           go do actual ending
*
XeEotRx  fcb   C$CR,C$LF,C$BELL
         fcc   "Exit Xmodem - EOT Recvd"
         fcb   C$CR,C$LF
LXeEotRx equ   *-XeEotRx
GMT692   equ   *                Normal end of receive
         lda   ascflg           are we in ascii mode?
         beq   gmt692b          go if not
         leax  ch,u
         ldy   #1
         lda   #C$CR            make last chr on file a <cr>
         sta   ch
         lda   rpth
         os9   I$Write
gmt692b  lda   rpth
         os9   I$Close          no need to flush buffer done by 620
         clr   rpth             so 699 doesnt try to close it
         leax  XeEotRx,pcr      setup msg pointers
         ldy   #LxeEotRx
         lbra  gmt699           go do actual ending
*
XeErrs   fcb   C$CR,C$LF,C$BELL
         fcc   "Exit Xmodem - Too Many Errors"
         fcb   C$CR,C$LF
LXeErrs  equ   *-XeErrs
GMT693   leax  XeErrs,pcr      setup msg pointers
         ldy   #LxeErrs
         lbra  gmt699           go do actual ending
*
XeTxTmo  fcb   C$CR,C$LF,C$BELL
         fcc   "Exit Xmodem - Transmit Timeout"
         fcb   C$CR,C$LF
LXeTxTmo equ   *-XeTxTmo
GMT694   equ   *               sending timeout
         leax  XeTxTmo,pcr
         ldy   #LXeTxTmo
         lbra  gmt699
*
XeOCan   fcb   C$CR,C$LF,C$BELL
         fcc   "Exit Xmodem - Operator Cancel"
         fcb   C$CR,C$LF
LXeOCan  equ   *-XeOCan
GMT695   equ   *               operator cancel
         lda   mpth
         lbsr  gmt817          purge line of all chars
         leax  XCAN.,pcr       send a cancel command to far end
         ldy   #1
         lda   mpth
         os9   I$Write
         leax  XeOCan,pcr      setup msg pointers
         ldy   #LxeOCan
         lbra  gmt699           go do actual ending
*
XeSync   fcb   C$CR,C$LF,C$BELL
         fcc   "Exit Xmodem - Block Sync Err"
         fcb   C$CR,C$LF
LXeSync  equ   *-XeSync
GMT696   leax  XeSync,pcr      setup msg pointers
         ldy   #LxeSync
         lbra  gmt699           go do actual ending
*
XeFatal  fcb   C$CR,C$LF,C$BELL
         fcc   "Exit Xmodem - Fatal H/W Err"
         fcb   C$CR,C$LF
LXeFatal equ   *-XeFatal
GMT698   leax  XeFatal,pcr      setup msg pointers
         ldy   #LxeFatal
         lbra  gmt699           go do actual ending
*
GMT699   equ   *               End Xmodem. X,Y point to message
         pshs  x,y
         lbsr  gmt790          show xmodem counts
         puls  x,y
         lda   #stdout
         os9   I$Write         writeout reason for ending
         lda   #XS.Idle
         sta   xstate
         clr   xmdmflg         do it now so 855 works right
         lda   spth            any send pth open?
         beq   gmt699a         go if not
         os9   I$Close
         clr   spth
gmt699a  clr   sndflg
         lda   rpth            any rcv pth open?
         beq   gmt699d         go if not
         lda   ascflg          are we in ascii mode?
         beq   gmt699c         go if not
         lda   #C$CR           put <CR> at end of buff if yes
         ldx   rcvptr,u
         sta   ,x+
         stx   rcvptr,u
gmt699c  lbsr  gmt855          flush buffer to disk so even if error
         lda   rpth                    still get some data
         os9   I$Close
         clr   rpth
gmt699d  clr   rcvflg
         lda   mpth
         lbsr  gmt817          purge mdm line of all chrs
         lbsr  gmt812          set opts on modem port
         clra
         coma                  set carry and minus bits to show ended
         rts
*
*  700 Series - Xmodem Sub-subroutines
*
GMT700   equ   *       Rcv Mode-check char in A to see if valid 1st chr
*                              ret carry clr if caller has work to do
         cmpa  #C$SOH          is it soh
         beq   sohrec
         cmpa  #C$STX
         bne   gmt700c         go if not
         ldd   #1024
         std   XdatSiz
         ldd   #1028
         std   XblkSiz
         bra   stxrec
sohrec
         ldd   #128
         std   XdatSiz
         ldd   #132
         std   XblkSiz
stxrec
         lda   CNAKsent
         cmpa  #3
         beq   NotCRCrx
         lda   #3
         sta   CNAKsent
         lda   #'C
         sta   XcrcTyp
NotCRCrx
         clra                  show more work to do
         rts
*
gmt700c  cmpa  #C$CAN          is it cancel?
         bne   gmt700e         go if not
         lbsr  gmt691          end xmodem with cancel message
         rts                   minus and carry bits set by 691
*
gmt700e  cmpa  #C$EOT          is it end of txmission
         bne   gmt700g
         lbsr  gmt765          send an ACK
         lbsr  gmt692          end xmodem with eot
         rts                   minus and carry bits set by 692
*
gmt700g  equ   *               any other chr at start of blk is trash
         lbsr  gmt650          bump err count abort if too many
*  should we purge line at this point ?????
gmt700k  orcc  #SetCarry       Set   carry caller has nothing to do
         rts
*
GMT710   equ   *               check block number for validity
         lda   ,x              check integrity of rcvd blk num
         anda  1,x             blk num and its complement give zero?
         bne   gmt710y         if not go non fatal error
         lda   OxblkNum        get previous valid blk num
         cmpa  ,x              is it same as rcvd one?
         beq   gmt710z         if yes good blk number
         inca                  generate new blk num MOD 256
         cmpa  ,x              is it same as rcvd one?
         beq   gmt710z         if yes good blk numb
         lbsr  gmt696          else fatal sync err  abort xmodem
gmt710y  orcc  #SetCarry       non fatal or fatal error
         rts
gmt710z  leax  2,x             update x to first data byte
         clra                  clear carry = good blk numb
         rts
*
GMT720   equ   *               calculate checksum return valu in A
*                              on entry X points to first data byte
         ldy   XdatSiz         number of chars in sum
         clra                  set lrc sum to zero
gmt720a  adda  ,x+             add a chr to sum
         leay  -1,y            decrease chr count
         bne   gmt720a         go if all chrs not done
         rts                   return with LRC in A and X=>LRC positn
*
GMT730   equ   *               send a previously formatted buffer
         leax  sndsoh,u        start of buffer address
         ldy   sndctr,u        not always 132 bytes - might be EOT
         lda   XcrcTyp
         beq   txchksum
         leay  1,y             One more byte
         ldd   XdatSiz
         addd  #-1
         pshs  x,y
         leax  3,x
         pshs  x
         lbsr  CalcCRC
         puls  x
         tfr   d,y
         ldd   XdatSiz
         leax  d,x
         sty   ,x
         puls  x,y
txchksum
         lda   mpth
         os9   I$Write
         rts
*
GMT740   equ   *               read disk file and format the buffer
         lda   spth
         lbeq  gmt748          go send eot if no path open
         clr   chcount
         clr   chcount+1
         clr   readerr
         leax  sndtxt,u        address of data portion of send buff
readdisk ldd   chcount
         cmpd  XdatSiz        number of data bytes in xmodem blk
         beq   bufffull
         lda   lastchr
         cmpa  #$0D            CR?
         bne   noaddlf
         ldb   lfflg           add line feeds?
         cmpb  #'N
         beq   noaddlf
         lda   #$0A            add line feed
         sta   ,x+
         pshs  a
         ldd   chcount
         addd  #1
         std   chcount
         puls  a
         sta   lastchr
         bra   readdisk
noaddlf  ldy   #1
         lda   spth
         os9   I$Read          read the disk file
         pshs  cc,b
         ldd   chcount
         addd  #1
         std   chcount
         lda   ,x+
         sta   lastchr
         puls  cc,b
         bcc   readdisk        go if read ok
         lda   XFILL.,pcr
         sta   -1,x
         sta   lastchr
         stb   readerr
         bra   readdisk
bufffull ldb   readerr
         beq   gmt746          buffer loaded....
         lda   spth
         os9   I$Close         close file if read error
         clr   spth
         ldb   readerr
         cmpb  #E$EOF          was error EOF?
         beq   gmt746          buffer loaded....
         os9   F$Perr          sho error number if not
         leax  rderr,pcr
         ldy   #Lrderr
         lda   #stdout
         os9   I$Write         tell user disk read error and path name
         lbsr  gmt698          fatal h/w error abort xmodem
         rts
*
gmt746   lda   #C$SOH          now format the buffer for xmodem protocol
         ldb   XdatSiz
         beq   smblk
         lda   #C$STX
smblk
         leax  sndsoh,u
         sta   ,x+             put in soh
         inc   Xsblknum
         lda   Xsblknum
         sta   ,x+             put in blk num
         coma
         sta   ,x+             and its complement
         lbsr  gmt720          calculate lrc - update x
gmt747   sta   ,x              put it into buffer
         ldd   XblkSiz
         std   sndctr,u        set byte ctr for gmt730
         lda   #XS.Sdat        sho data as last thing we sent
         sta   Xsndflg
         ldd   XtotBlks        update numb of blks
         addd  #1                read from file
         std   XtotBlks
         clra                  clear carry and minus bits
         rts
*
gmt748   equ   *               end of file so send eot
         lda   #C$EOT          but build a real buffer
         sta   sndsoh,u        in case resend needed bec rx didnt ACK
         ldd   #1
         std   sndctr,u
         lda   #XS.Seot        sho eot as last thing we sent
         sta   Xsndflg
         clra                  clear carry and minus bits
         rts
*
GMT760   leax  XNAK.,pcr       point to nak msg
         pshs  a
         lda   CNAKsent
         cmpa  #3
         beq   sendnak
         inca
         sta   CNAKsent
         leax  CNAK.,pcr
sendnak
         puls  a
         bra   gmt768
GMT765   leax  XACK.,pcr       point to ack msg
gmt768   ldy   #1
         lda   mpth
         os9   I$Write
         rts
*
*      Timing routines
*
TimYr    set   0               offset from start of time packet
TimMth   set   TimYr+1
TimDay   set   TimMth+1
TimHrs   set   TimDay+1
TimMin   set   TimHrs+1
TimSec   set   TimMin+1
*
GMT770   equ   *               check for timeout -
*                              if too many abrt xmdem set carry & Minus
*                              return carry set if timeout but < limit
*                              clr carry if no timeout yet
         leax  Xcurtim,u
         os9   F$Time          get the current time
         bcc   gmt770a         go if time got ok
         lbsr  gmt698          fatal hardware error
         rts
gmt770a  equ   *
         leay  XendTim,u       point to time at which timeout occurs
         ldd   TimYr,y         get max allowed Yr & Mth
         cmpd  TimYr,x         compare to current Yr& Mth
         blt   gmt772          go if timeout
         bgt   gmt774          go if no timeout
         ldd   TimDay,y        get max allowed Day & hr
         cmpd  TimDay,x        compare to current Day & Hr
         blt   gmt772          go if timeout
         bgt   gmt774          go if no timeout
         ldd   TimMin,y        get max allowed Min & Sec
         cmpd  TimMin,x        compare to current Min & Sec
         bge   gmt774          go if no timeout
gmt772   lbsr  gmt650          bump error ctr abrt if too many (minus)
gmt773   orcc  #SetCarry       tell caller timeout occured
         rts
gmt774   clra                  clear carry for caller
         rts
*
GMT780   equ   *               setup new ending time
*                              (A) mins and (B) secs from now
         leax  XcurTim,u
         os9   F$Time          get current time
         bcc   gmt780a
         lbsr  gmt698          cant get time msg is fatal 698 sets M&C
         rts
gmt780a  pshs  a,b             save mins and secs to next timeout
         ldd   TimYr,x         get yr and mth
         std   XendTim+TimYr,U
         ldd   TimDay,x        get day and hour
         std   XendTim+TimDay,U store
         puls  a,b             restore mins and secs to next timeout
         addb  TimSec,x        add num of secs to delay
         cmpb  #60             is it too big?
         blt   gmt782          go if not
         inca                  bump minutes
         subb  #60             adjust seconds
gmt782   stb   XendTim+timSec,U new ending seconds
         adda  TimMin,x        new minutes
         cmpa  #60             minutes too big?
         blt   gmt783          go if not
         suba  #60
         inc   XendTim+TimHrs,U bump the hrs
gmt783   sta   XendTim+TimMin,U adjust the mins
         clra                  clear carry and minus
         rts                   dont bother with days - at worst it will
*                              cause an extra timeout at midnite
*
GMT790   equ   *               show xmodem counters
         ifeq  mylev-2
         lda   #1              Inverse
         clrb                  No save
         ldx   #0              At 0,0
         ldy   #$5001          Size 80x1
         lbsr  OpenWin
         endc
         pshs  x,y
         leax  msgbuf,u
         ldb   #LXctrMsg
         leay  XctrMsg,pcr     addr of msg text
         lbsr  gmt807          block move to msgbuf
         lda   XcrcTyp
         beq   ischksum
         leax  msgbuf+CRCOffMsg,u
         ldb   #3
         leay  CRCmess,pcr
         lbsr  gmt807
ischksum
         lda   XdatSiz
         beq   isxmdm
         lda   #'Y
         sta   msgbuf+XYoff,u
isxmdm
         ldd   XtotBlks        convert xtotblks
         lbsr  gmt830          .. to BCD in DecAcc
         leax  msgbuf+XtotBpos,u dest ptr
         ldb   #3                byte count
         lbsr  gmt838          convert bcd to ascii
         ldd   XtotErrs        convert total errs
         lbsr  gmt830          .. to BCD in DecAcc
         leax  msgbuf+XtotEpos,u dest ptr and ..
         ldb   #3                byte count ...
         lbsr  gmt838          for bcd to ascii convert
         clra
         ldb   XerrCtr         consecutive err ctr to D
         lbsr  gmt830          convert to bcd
         leax  msgbuf+XerrPos,u dest ptr and ...
         ldb   #1               byte count ...
         lbsr  gmt838          for bcd to ascii convert
         leax  msgbuf,u        msg buff addr
         ldy   #LXctrMsg       length
         lda   #stdout
         os9   I$Write
         ifeq  mylev-2
         lbsr  CloseWin
         endc
         clrb                  clear carry and B
         puls  x,y,pc          clean stack and retrun
*

CalcCRC
         clr   CRCAcc,u
         clr   CRCAcc+1,u      Clear CRC
         stx   buffptr,u       Set pointer to start of buffer
         std   buffcnt,u       Initialize counter
crcloop
         ldx   buffptr,u
         lda   ,x+             Get next character
         stx   buffptr,u       Increment pointer
         clrb
         eora  CRCAcc,u
         eorb  CRCAcc+1,u      Exclusive or
         std   CRCAcc,u        Store it
         clr   icount,u
         clr   icount+1,u      Clear icount
forloop
         ldd   CRCAcc,u
         anda  #$80            Test hi bit
         clrb
         tfr   d,y             Save result in y
         ldd   CRCAcc,u        Shift CRC 1 bit left
         aslb
         rola
         cmpy  #0
         lbeq  NotHi           Check hi bit
         eora  #$10            Hi bit set
         eorb  #$21
NotHi
         std   CRCAcc,u        Hi bit not set
         ldd   icount,u        Get icount
         addd  #1              Icrement
         std   icount,u        Save icount
         cmpd  #8              Is it 8 yet?
         lblt  forloop         If not, do it again
         ldd   buffcnt,u       Get buffcnt
         addd  #-1             Decrement
         std   buffcnt,u       Save it
         lbge  crcloop         Loop if not less than 0 yet
Return
         ldd   CRCAcc,u
         rts

