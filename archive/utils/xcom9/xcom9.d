         ttl  XCom9 Defs
         page
*
*        XCom9.defs
*
         use  xcom9_levdef.asm     define the symbol MyLev=1 or 2
       ifeq  MyLev-1
MaxRam   equ   1024*2          gives min capture buff of 750 bytes
       endc
       ifeq  MyLev-2
MaxRam   equ   1024*8          gives min capture buff of 6.75KB
       endc

stdin    equ   0
stdout   equ   1
stderr   equ   2
lkeybuf  equ   256             max read size from modem or console
rplysiz  equ   lkeybuf
MaxTxSiz equ   40              less than acia buff size
Poff     equ   %01111111       mask to turn off parity bit
TGLR     equ   $12             cntl-R toggle receive file
ClrCarry equ   %11111110
SetCarry equ   %00000001
SetMinus equ   %00001000
SetSig   equ   %00000001
*
*        Command equates
*
C$Panic  equ   C$QUIT          panic exit - default to os9 abort char
*C$panic equ   $19             panic exit - good alternate choice
brkcmd   equ   '@  send a break on modem port (6850 only)
shlcmd   equ   '$  Shell
asccmd   equ   'A  toggle A(scii only mode -
baucmd   equ   'B  set Baud rate on modem port (req modified acia) -**
adlcmd   equ   'D  Auto dialer
echcmd   equ   'E  toggle local E(cho
flocmd   equ   'F  define chars which F(low cntl me
hlpcmd   equ   'H  H(elp command
optcmd   equ   'O  show O(ption settings
qutcmd   equ   'Q  Q(uit return to os9
rcvcmd   equ   'R  R(eceive a file - log it to disk
sndcmd   equ   'S  S(end a file from disk
etrcmd   equ   'T  Ext file transfer
xprcmd   equ   'X  setup or stop X(modem file transfer
ymdmcmd  equ   'Y  setup or stop Y(modem file transfer
dircmd   equ   '/  Change directory
*
*        XMODEM equates
*
C$SOH    equ   $01  ^A start of block
C$STX    equ   $02  ^B start of text (Ymodem)
C$EOT    equ   $04  ^D end of transmission
C$ACK    equ   $06  ^F block ok
C$NAK    equ   $15  ^U resend block
C$CAN    equ   $18  ^X cancel xmodem
*
*
*        xmodem state variables
*
XS.Idle  equ   0    not in xmodem mode
XS.Wsoh  equ   1    Rx waiting for SOH
XS.Rdat  equ   2    Rx getting data bytes
XS.Wrsp  equ   $10  Tx waiting for response
XS.IniS  equ   $20  Tx waiting users ok to start
*
XS.Sdat  equ   $1   tx blk contains data
XS.Seot  equ   $2   tx blk contains eot
*
*        Timer equates
*
       ifeq  MyLev-2
VTikPsec equ   100  tiks per second only affects BREAK cmd
       endc
       ifeq  MyLev-1
VTikPsec equ   10   tiks per second only affects BREAK cmd
       endc
VTxTmo   equ   $0100 minutes & secs of txmitter timeout (1 min 0 sec)
VRxTmo   equ   $000A minutes & secs of Rxcver timeout   (0 min 10Sec)
VIniTmo  equ   $0016 initial Rx wait                    (0 min 22Sec)
*
VErrLim  equ   10   max numb of consecutive errors
*

