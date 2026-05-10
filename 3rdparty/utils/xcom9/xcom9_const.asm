         ttl  XCom9   Constants
         page
*      XCom9 constants file
*      File uses symbols defined in XCom9.Defs
*
         fcc   "+CONST+" this will show in hex dump for patchers
*
*        default constants     non xmodem mode
*
Dxonchr  fcb   $11             dc1 XON  remote sends to me
Dxoffchr fcb   $13             dc3 XOFF remote sends to me
Xonmsg   fcb   $11,$00         dc1 xon  I send to remote
Lxonmsg  equ   *-Xonmsg
Xoffmsg  fcb   $13,$00         dc3 xoff I send to remote
Lxoffmsg equ   *-xoffmsg
defstate equ   *       initial settings of options
         fcb   0       ascii only     - off
         fcb   $00     local echo     - off
         fcb   $FF     modem          - on
         fcb   0       disk receiving - off
         fcb   0       disk sending   - off
         fcb   $FF     vu mdm traffic - on
         fcb   0       xmodem         - off
         fcb   0       cmdflag        - off
         fcb   0       killed         - off
         ifeq mylev-2
macrofl  fcc   "/dd/macro"
lmacrofl equ   *-macrofl
         else
macrofl  fcc   "/d0/macro"
lmacrofl equ   *-macrofl
         endc
Panic    fcb   C$Panic             panic exit via os9 abort method
TiksPbrk fdb   VtikPsec/3          a break is about 1/3 of a second
amusechr fcc   "#"
CrChr    fcb   C$CR
*
Usgmsg   fcb   C$CR,C$LF,C$BELL
         fcc   "Usage: XCom9 [modem port] [#Mem]"
         fcc   " e.g. XCom9 /T2 #4K"
         fcb   C$LF,C$CR
Lusgmsg  equ   *-usgmsg
Hintmsg  fcb   C$CR,C$LF,$0C
         ifeq  mylev-2
         fcb   $1B,$31,$01,$08
         endc
         fcc   ">>> XCOM9 Version 12 <<<"
         ifeq  mylev-2
         fcb   C$CR,C$LF,C$CR,C$LF
         fcc   "Prefix commands with 'F1'"
         fcb   C$CR,C$LF
         fcc   "Use 'H' cmd for Help, 'O' cmd to show   option settings"
         fcb   C$CR,C$LF
         fcc   "'0' through '9' are defineable"
         fcb   C$CR,C$LF
         fcc   "'0' transmitts the contents of  /dd/macro0, etc..."
         fcb   C$CR,C$LF
         else
         fcb   C$CR,C$LF
         fcc   "Prefix commands with <ALT-1>"
         fcb   C$CR,C$LF
         fcc   "Use 'H' for help"
         fcb   C$CR,C$LF
         fcc   "'0' through '9' are defineable"
         fcb   C$CR,C$LF
         fcc   "'0' transmitts the file"
         fcb   C$CR,C$LF
         fcc   "/d0/macro0, etc..."
         fcb   C$CR,C$LF
         endc
LHintmsg equ   *-Hintmsg
Dcmdchr  fcb   $B1             Default cmd char = 'F1' or ALT-1
*
         fcc   "+XMDM+"
TxTmo    fdb   VTxTmo              hi byte minutes/lo byte secs
RxTmo    fdb   VRxTmo
IniTmo   fdb   VIniTmo
TiksPSec fdb   VTikPSec
ChrWait  fdb   VTikPSec            wait between chars = 1 sec max
XerrLim  fcb   VErrLim             max numb of consecutive errors
DcrcTyp  fcb   0                   0=chksum, non-zero=CCITT
*
XSOH.    fcb   C$SOH               single byte msgs to txmit
XSTX.    fcb   C$STX
XEOT.    fcb   C$EOT
XACK.    fcb   C$ACK
XNAK.    fcb   C$NAK
CNAK.    fcc   "C"
XCAN.    fcb   C$CAN
XFILL.   fcb   $1A                 fill short blk with CP/M eof chrs
*
*
         fcc   "++CTL++"
AscFiltr equ   *                   Translate table for ctl chars when in
*                                  ascii mode. Only used by 810 routine
*           This Value             Replaces this input
         fcb   $00                   00    Null
         fcb   $00                   01    SOH
         fcb   $00                   02    STX
         fcb   $00                   03    ETX
         fcb   $00                   04    EOT
         fcb   $00                   05    ENQ
         fcb   $00                   06    ACK
         fcb   $07                   07    BELL
         fcb   $08                   08    backspace
         fcb   $20                   09    tab replaced by 1 space
LfChr    fcb   $0A                   0A    LF
         fcb   $0D                   0B    VT
         fcb   $0C                   0C    Form Feed
         fcb   $0D                   0D    Carr Ret
         fcb   $00                   0E    SO
         fcb   $00                   0F    SI
         fcb   $00                   10    DLE
         fcb   $00                   11    DC1 (Xon)
         fcb   $00                   12    DC2
         fcb   $00                   13    DC3 (Xoff)
         fcb   $00                   14    DC4
         fcb   $00                   15    NAK
         fcb   $00                   16    SYN
         fcb   $00                   17    ETB
         fcb   $00                   18    CAN
         fcb   $00                   19    EM
         fcb   $00                   1A    SUB (^Z)
         fcb   $00                   1B    ESC
         fcb   $00                   1C    FS
         fcb   $00                   1D    GS
         fcb   $00                   1E    RS
         fcb   $00                   1F    US
*
         fcc   "==="        end of constants area
* ----- end of XCom9.Const file ----------

