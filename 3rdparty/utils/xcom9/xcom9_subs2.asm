         ttl  Low level utility routines
         page
*
*        COMMON LOW LEVEL ROUTINES
*
*
prmtmsg  equ   *
         fcb   $0D,3
         fcc   "<Command>?"
beepmsg  fcb   C$BELL
Lbeepmsg equ   *-beepmsg
Lprmtmsg equ   *-prmtmsg
GMT800   equ   *               cmd prompt subroutine
         pshs  x,y
         ifeq  mylev-2
         lda   #1              inverse
         ldb   #1              save
         ldx   #23             at 0,23
         ldy   #$B01           size 11x1
         lbsr  OpenWin
         endc
         leax  prmtmsg,pcr
         ldy   #Lprmtmsg
         lda   #stdout
         os9   I$Write
         puls  x,y,pc
*
GMT801   equ   *               beep subroutine
         pshs  x,y
         leax  beepmsg,pcr
         ldy   #Lbeepmsg
         lda   #stdout
         os9   I$Write
         puls  x,y,pc
*
GMT802   equ   *                   feature not yet implemented
         pshs  x,y
         leax  Futurmsg,pcr
         ldy   #Lfuturm
         lda   #stdout
         Os9   I$Write
         puls  x,y,pc
Futurmsg fcb   C$Bell,C$CR,C$LF
         fcc   "Feature not avail"
         fcb   $0A,$0D
Lfuturm  equ   *-Futurmsg
*
GMT804   equ   *                   sho Y,CC,A,B at time of err
         pshs  y,x,b,a,cc
         leax  ch,u                use the scf buffer
         ldd   ErrSta,pcr          "^GP"
         std   ,x++
         ldd   ErrSta+2,pcr        "C="
         std   ,x++
         lda   5,s                 get y reg hi byte
         lbsr  gmt880              cnvrt to display fmt
         std   ,x++                save in buffer
         lda   6,s                 get y reg lo byte
         lbsr  gmt880
         std   ,x++
         ldd   ErrSta+4,pcr        " C"
         std   ,x++
         ldd   ErrSta+6,Pcr        "C="
         std   ,x++
         lda   ,s                  cc
         lbsr  gmt880
         std   ,x++
         lda   #C$SPac
         sta   ,x+
         ldd   ErrSta+8,pcr        "D="
         std   ,x++
         lda   1,s                 D hi byte
         lbsr  gmt880
         std   ,x++
         lda   2,s                 d lo byte
         lbsr  gmt880
         std   ,x++
         ldd   errsta+10,pcr
         std   ,x
         ldy   #21
         leax  ch,u
         lda   #stderr
         os9   I$WritLn
         puls  y,x,a,b,cc,pc       clean stack and return
ErrSta   fcb   C$Bell
         fcc   "PC= CC=D="
         fcb   C$CR,C$LF
*
GMT806   equ   *               fill memory
*                       calling seq: a=fill chr, b=len, x=dest ptr
         sta   ,x+
         decb
         bne   gmt806
         rts
*
GMT807   equ   *               block move
*                       calling seq: b=len, x=dest ptr, y=src ptr
         lda   ,y+
         sta   ,x+
         decb
         bne   gmt807
         rts
*
GMT808   equ   *               use to copy pth names in 410 rtn
*                       calling seq: b=len, x=dest ptr, y=src ptr
         lda   ,y+
         cmpa  #C$Spac
         bls   gmt808z
         sta   ,x+
         decb
         bne   gmt808
gmt808z  rts
*
GMT810   pshs  y,x,a,b           asciify a buffer
         leax  ch,u            x points to buffer address
         leay  TranTab,u       Ctl Char filter table address
         ldd   chlen           len of buff to B
         beq   gmt810z         go if no chars in buff
gmt810a  lda   ,x              get a ch from buff
         anda  #Poff           turn off parity bit
         cmpa  #C$Spac         is it control char?
         bhs   gmt810b         go if not
         lda   a,y             get replacement char from filter table
gmt810b  sta   ,x+             save char result char
         decb                  all chars done?
         bne   gmt810a         go if not
gmt810z  puls  y,x,a,b,pc        clr stk and return
*
GMT811   equ   *               set stdin opts to XCom9 settings
         pshs  x
         lda   Panic,pcr
         sta   pd.qut-pd.opt+conopt
         lda   echflg
         sta   pd.eko-pd.opt+conopt
         sta   pd.alf-pd.opt+conopt    auto lf only work on writln
         lda   #stdin
         ldb   #SS.opt
         leax  conopt,u
         os9   I$SetStt
         bcc   gmt811z
         tfr   pc,y                    setup for err msg
         lbra  gmt190
gmt811z  puls  x,pc
*
GMT812   equ   *               setup modem path options
         pshs  x
         lda   xonchr
         ora   #$80            Set high bit to get arround bug.
         sta   pd.xon-pd.opt+mopt
         lda   xoffchr
         sta   pd.xoff-pd.opt+mopt
         lda   mpth
         ldb   #SS.opt
         leax  mopt,u
         os9   I$SetStt
         bcc   gmt812z
         tfr   pc,y            setup for error message
         lbra  gmt190          abort run if error
gmt812z
         ldy   baudpar
         lda   mpth
         ldb   #SS.ComSt
         OS9   I$SetStt
         puls  x,pc
*
GMT813   equ   *               reset stdin opts to standard settings
         pshs  x
         lda   #stdin
         ldb   #SS.opt
         leax  iconopt,u
         os9   I$SetStt
         bcc   gmt813z
         tfr   pc,y
         lbra  gmt190          abort with err msg
gmt813z  puls  x,pc
*
GMT814   equ   *               zero nearly all opts on modem path
         pshs  x
         leax  MsgBuf,u        scratch area for opts
         lda   #C$Null
         ldb   #32
         lbsr  gmt806          fill area with zeroes
         leax  MsgBuf,U
         lda   PD.PAR-PD.OPT+mopt,u     always preserve
         sta   PD.PAR-PD.OPT,X             opts affecting H/W (parity)
         lda   PD.BAU-PD.OPT+mopt,u     speed
         sta   PD.BAU-PD.OPT,X
         ldd   PD.D2P-PD.OPT+mopt,u     echo dev ptr
         std   PD.D2P-PD.OPT,X
         lda   mpth
         ldb   #SS.OPT
         os9   I$SetStt
         bcc   gmt814z
         tfr   pc,y
         lbra  gmt190          abort run if error
gmt814z
         ldd   baudpar
         clra
         andb  #7
         tfr   d,y
         lda   mpth
         ldb   #SS.ComSt
         os9   I$SetStt
         puls  x,pc            clean stack and return
*
GMT816   equ   *               get many chrs on modem path
         pshs  x,y,a           a=pth, b=number of chars
         clra
         tfr   d,y             number of chars to read to y
         ldx   chlen
         abx
         cmpx  #lkeybuf        is it too many?
         blo   gmt816a         go if not
         ldx   #0
         cmpy  #10
         blo   cantread        Buffer is FULL
         ldy   #8
gmt816a
         ldx   bpoint
         stx   obp
         lda   mpth            NO CHANCES always use mpth never mind a
         os9   I$Read          read the pth
         tfr   y,d
         stb   chlast
         bcc   readok          no errors in read
         abx                   unsigned add
         lda   #'?             question chr
         sta   ,x              in end of buff
         bra   storelen
readok
         abx
storelen
         stx   bpoint
         clra
         sta   ,x              Zap next character
         ldx   chlen           get current length
         abx                   add what was read
         stx   chlen           save it
cantread
         tfr   x,d
gmt816z  puls  x,y,a,pc        clean stack and return with B= num chrs
*
GMT817   equ   *               purge modem pth of all chrs
gmt817a  lda   mpth            get path numb
         beq   gmt817z
         ldb   #SS.Ready
         os9   I$GetStt        any input ready?
         bcc   gmt817b         go if yes
         ldx   chrwait,pcr     wait for a bit
         os9   F$Sleep         sleep but maybe not full time
         ldb   #SS.Ready
         lda   mpth
         os9   I$GetStt        now any chrs?
         bcs   gmt817z         go if not
gmt817b
         leax  ch,u
         stx   bpoint
         stx   obp
         clr   chlen
         clr   chlen+1
         clr   escrec
         clr   chlast
         bsr   gmt816          read the chars b=len,a=path - destroys a
         bra   gmt817a         816 maybe only read 1 char
gmt817z  rts
*
*       Called with X pointing to the buffer and Y holding the length
GMT820   equ   *               write to modem port if flag on
         lda   mdmflg          is flg on?
         beq   gmt829          go if not
         pshs  x,y
         lda   mpth
         os9   I$Write
         bcc   gmt828
         os9   F$Perr
         leax  mdmerr,pcr
         ldy   #Lmdmerr
         lda   #stdout
         os9   I$write
gmt828   puls  x,y
gmt829   rts
mdmerr   fcb   C$CR,C$LF,C$BELL
         fcc   "Write err on modem"
Lmdmerr  equ   *-mdmerr
*
*        830 series bin to bcd, bcd to ascii
*
GMT830   equ   *               convert (D) to bcd  in DecAcc
         pshs  b,a             save argument; hi byte will pop first
         ldd   #0
         std   DecAcc
         std   DecAcc+2        init DecAcc to all zeroes
         puls  a               get hi byte
         bsr   gmt834          convert hi byte
         puls  a               get lo byte
         bsr   gmt834
         rts
*
GMT834   equ   *               do 8 bit bcd add to DecAcc
         pshs  a               save byte
         lbsr  gmt836          mult dec acc by 16
         lda   ,s              get byte
         anda  #$F0            hi nybble first
         lsra
         lsra
         lsra
         lsra
         bsr   gmt835          add nybble to DecAcc
         bsr   gmt836          Mult DecAcc by 16
         puls  a               now do
         anda  #$0F            lo nybble
         bsr   gmt835          add nybble to DecAcc
         rts
*
GMT835   equ   *               bcd add lo A nybble to DecAcc
         pshs  x               save x
         leax  DecAcc,u        MSDigit ptr
         pshs  x
         leax  4,x             end ptr
         adda  #0              be sure H bit set right
         daa                   convert nybble to bcd
         adca  ,-x             add in lsdigit of decacc
         daa                   keep result bcd
         sta   ,x              update decacc
         bcc   gmt835z         if no carry then all done
gmt835a  cmpx  ,s              is pointer at MSdigit?
         ble   gmt835z         go if yes
         lda   #1              put carry bit in A
         adda  ,-x             add in next digit
         daa
         sta   ,x
         bcs   gmt835a         if carry set carry on!
gmt835z  leas  2,s             skip over MSDigit ptr
         puls  x,pc            clean stack and return
*
GMT836   equ   *               Multiply DecAcc by 16
         pshs  x
         bsr   gmt836d         *2 (add DecAcc to itself)
         bsr   gmt836d         *4
         bsr   gmt836d         *8
         bsr   gmt836d         *16
         puls  x,pc            clean stack and return
GMT836D  equ   *               BCD add DecAcc to itself
         leax  DecAcc+4,u      point to least sig digit+1
         ldb   #4              length of DecAcc in bytes
         clra                  clear carry
         pshs  cc              save it
gmt836e  lda   ,-x             get 2 bcd digits
         puls  cc              restore carry
         adca  ,x              add digit to itself and carry
         daa                   keep result bcd
         sta   ,x              update DecAcc
         pshs  cc              save carry
         decb                  all bytes in DecAcc done?
         bne   gmt836e         go if not
         puls  cc,pc           clean stack and return
*
GMT838   equ   *               convert DecAcc to ascii
*                              (B) = number of bytes
*                               X=>  ascii buffer
         pshs  y
         leay  DecAcc+4,u      Y=>LSDigit+1
         abx
         abx                   bump x to right hand end of buff
gmt838a  lda   ,-y             get 2 digits
         anda  #$0F            select low one
         adda  #$30            convert to ascii
         sta   ,-x             store in buffer
         lda   ,y              get same 2 digits
         lsra
         lsra
         lsra
         lsra                  select hi one
         adda  #$30            convert to ascii
         sta   ,-x             store in buffer
         decb                  all digits done?
         bne   gmt838a         go if not
         puls  y,pc            clean stack and return
*
GMT840   equ   *               this rtn called only from send disk
         pshs  x,y
         lda   echflg          does he want to see data go out?
         bne   gmt845          go if yes
         lda   vuflg           is he watching data on modem port?
         bne   gmt845z         go if yes (assume other end echoing)
         leax  amusechr,pcr    else sho amuse chr
         ldy   #1
gmt845   lda   #stdout
         OS9   I$Write
gmt845z  puls  x,y,pc          clean stack and return
*
*     850 and 855 capture buffer management
*
GMT850   equ   *               copy ch buffer to dsk buffer
         pshs  x,y
         lda   rcvflg          is rcv flg on?
         beq   gmt854z         go if not
         ldd   chlen           numb of chrs in buff to B
         leay  ch,u            addr of chr buff
         ldx   rcvptr,u        addr of dest
gmt851   tstb                  all chrs copied
         beq   gmt854          go if yes
         lda   ,y+             get chr
         decb                  adjust count of chrs remaining
         cmpa  #10             Line feed?
         beq   gmt851          Strip line feeds
         sta   ,x+             save in dsk buff
         cmpx  hircvptr,u      disk buffer full?
         bls   gmt851          go if not
         stx   rcvptr,u        be sure ptrs accurate to call flush
         bsr   gmt855          write buffer to disk
         ldx   lorcvptr,u      after a flush must be at start
         bra   gmt851          transfer rest of chars
gmt854   stx   rcvptr,u        update pointer
gmt854z  puls  x,y,pc          clean stack and return
*
GMT855   equ   *               flush the disk buffer to disk
*                              not used by xmodem series
         pshs  x,y,a,b
         lda   rpth            is a path open?
         beq   gmt859z         go if not
         leax  XoffMsg,pcr     send xoff to far end during
         ldy   #Lxoffmsg       disk writes
         lda   mpth            even at 300 bps  disks are slo
         os9   I$Write
         ldx   #VtikPsec*2     2 seconds
         OS9   F$Sleep         Give system time time to see xoff
gmt856   ldd   rcvptr,u
         subd  Lorcvptr,u
         tfr   d,y             length of buffer
         ldx   Lorcvptr,u      start of buffer
         lda   rpth            must be valid path
         os9   I$Write
         bcc   gmt859          go if no errors
         os9   F$Perr
         leax  rcverr,pcr
         ldy   #Lrcverr
         lda   #stdout
         os9   I$Write
gmt859   leax  XonMsg,pcr        now send xon
         ldy   #Lxonmsg
         lda   mpth
         os9   I$Write
gmt859z  ldd   lorcvptr,u
         std   rcvptr,u
         puls  a,b,x,y,pc          clean stack and return
rcverr   fcb   C$CR,C$LF,C$BELL
         fcc   "Error writing receive buffer to disk"
Lrcverr  equ   *-rcverr
*
GMT860   equ   *        convert to upper case
casebit  equ   'a-'A
         cmpa  #'a      is char < a
         blo   gmt869   go if yes
         cmpa  #'z      is char > z
         bhi   gmt869   go if yes
         anda  #^casebit       /old syntax  ANDA #!CASEBIT/
gmt869   rts
*
GMT870   equ   *              copy path name x=src, y=dest
         pshs  y
         os9   F$PrsNam        x,y updated; b=numb of chrs in name
         puls  y               ignore the new Y (Note puls no chng Carry
         bcs   gmt879          go if all done
gmt874   lda   ,x+
         sta   ,y+
         decb
         bne   gmt874
         bra   gmt870
gmt879   lda   #C$CR           be sure pth now termed with CR
         sta   ,y
         rts
*
GMT880   equ   *               1 byte in a to 2 hex chars in d
         tfr   a,b
         anda  #$0F            select lo nybble
         bsr   gmt881          convert lo nybble
         exg   a,b             save lo nyb, get orig byte
         lsra
         lsra
         lsra
         lsra                  select hi nybble
gmt881   adda  #$90            lo nybble in A to hex ascii char
         daa
         adca  #$40
         daa
         rts
*           following rtn contains NO error checking
GMT885   equ   *               2 hex chars (UC) in d to binary in a
         subd  #$3030          remove ascii offset
         cmpa  #9              is it A-F
         bls   gmt886          go if not
         suba  #7              $11-$16 --> $0A-$0F; $00<=(A)<=$0F
gmt886   lsla                  move nybble left
         lsla
         lsla
         lsla                  A now in range $F0-$10 (or $00)
         cmpb  #9
         bls   gmt887
         subb  #7
gmt887   pshs  b               b now in range $00 - $0F
         ora   ,s+             merge hi and lo nybbles
         rts
*
GMT890   equ   *        input 2 ascii chars as valid hex digits
         lda   #stdin   return binary in A
         leax  ch,u            scratch area for reply
         ldy   #rplysiz
         os9   I$ReadLn
         bcs   gmt894          go if error
         bsr   gmt895          check if input valid
         bcs   gmt894          go if not
         ldd   ,x              get hex digits in D
         bsr   gmt885          convert to binary in a
         clrb                  clear carry for success
         rts
gmt894   leax  hexerr,pcr      invalid hex digits
         ldy   #Lhexerr
         lda   #stdout
         OS9   I$Write
         orcc  #SetCarry       set carry for error
         rts
gmt895   equ   *               check chars pointed to by x
         clrb                  1st char 0 offset to x
         bsr   gmt896          check it
         bcs   gmt899          error return
         incb                  lo digit
gmt896   equ   *               be sure sign of zero
         lda   b,x             b is 0 or 1 here
         cmpa  #'0             too small?
         blo   gmt898          go if yes
         cmpa  #'9             in range?
         bls   gmt897          go if ok
         lbsr  gmt860          convert to upper case

         sta   b,x             put converted char in buffer
         cmpa  #'A             in range A-F
         blo   gmt898          go if not
         cmpa  #'F             too big?
         bhi   gmt898          go if yes
gmt897   andcc #ClrCarry       clear carry no errors
         rts
gmt898   orcc  #SetCarry       set carry bad hex digits
gmt899   rts
hexerr   fcb   C$CR,C$LF,C$BELL
         fcc   "Bad hex digits"
         fcb   C$CR,C$LF
Lhexerr  equ   *-hexerr
*
         page

*
GMT920   equ   *               print invalid command msg
         leax  invcmd,pcr
         ldy   #Linvcmd
         lda   #stdout
         os9   I$Write
         rts
*
Invcmd   FCB   C$CR,C$LF,C$BELL
         fcc   "Unknown command"
         fcb   $0D,$0A
Linvcmd  equ   *-invcmd
*                          x=prmpt ptr, y=rply ptr, b=prmpt len
GMT950   equ   *               prompt for path name
         pshs  y,b             save reply ptr
         lbsr  gmt813          set stdin opts
         puls  b
         clra
         tfr   d,y             prompt length was in B
         lda   #stdout
         os9   I$Write         issue prompt
         puls  x               reply ptr
         ldy   #rplysiz
         lda   #stdin
         os9   I$ReadLn        read with editing
gmt954   pshs  y               number of chars read
         lbsr  gmt811          clear stdin options
         ldd   ,s              get num ch read
         leay  d,x             y points to 1 past last
         lda   #C$CR           append CR
         sta   ,y
         puls  y               orig length back
         cmpy  #1              only 1 char input?
         beq   gmt955          go if yes
         clrb                  clr carry
         rts
gmt955   orcc  #SetCarry       set carry
         rts
*
GMT980   equ   *               print usage message
         leax  usgmsg,pcr
         ldy   #Lusgmsg
         lda   #stdout
         os9   I$Write
         rts
* usage msg now in XCom9.Consts file so Dcmdchr is easier to patch
*
GMT990   equ   *               bad path message print
         pshs  x               save path name ptr
         lbsr  gmt813          set std opt on stdin (and stderr - bug!)
         leax  Mbadpth,pcr
         ldy   #Lbadpth
         lda   #stdout
         os9   I$Write
         puls  x               get pth name ptr
         ldy   #rplysiz        max num of chars
         os9   I$WritLn        path is term in CR (we hope)
         lbsr  gmt811          set running opts on stdin (& stderr)
         rts
Mbadpth  fcb   C$CR,C$LF,C$BELL
         fcc   "Error on path: "
Lbadpth  equ   *-Mbadpth
*

