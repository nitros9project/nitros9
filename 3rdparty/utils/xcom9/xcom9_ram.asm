         ttl  RAM SPACE
*        page
*
*        RAM MEMORY
*
         ORG   0
chlen    rmb   2                   numb of bytes read on mdm pth
chinpt   rmb   2
ebp      rmb   2                   End of Buffer Pointer
obp      rmb   2                   Old buffer pointer
bpoint   rmb   2                   Buffer pointer
parmptr  rmb   2                   pointer to modem device name
mpth     rmb   1                   modem path number
baudpar  rmb   2                   Current baud/parity
rpth     rmb   1                   disk rcv path number
spth     rmb   1                   disk send path number
smode    rmb   1                   0=blind, any other value = prmpt chr
DecAcc   rmb   4                   decimal accumulator
*
pgmstate equ   .                   state of options settings
ascflg   rmb   1
echflg   rmb   1
mdmflg   rmb   1
rcvflg   rmb   1
sndflg   rmb   1
vuflg    rmb   1
xmdmflg  rmb   1
cmdflg   rmb   1
kildflg  rmb   1
Lpgmstat equ   .-pgmstate
usrconst equ   .
cmdchr   rmb   1
xonchr   rmb   1
xoffchr  rmb   1
escrec   rmb   1
chlast   rmb   1
insav    rmb   1
outsav   rmb   1
lastchr  rmb   1
readerr  rmb   1
chcount  rmb   2
lfflg    rmb   1
*
*        xmodem storage
*
Xstate   rmb   1                   state of xmodem txfer
XcrcTyp  rmb   1                   type of crc calc used CCITT / chksum
CNAKsent rmb   1                   number of "C"s sent
Xsndflg  rmb   1                   type of block to send (eot or data)
XchrCtr  rmb   2                   number of chrs in Rx xmdm buff
XerrCtr  rmb   1                   number of errors
OXblknum rmb   1                   previous blk numb Rx'd
NXblknum rmb   1                   Next blk numb expected
XsblkNum rmb   1                   send blk number
XCurTim  rmb   6                   Current time y m d h m s in binary
XEndTim  rmb   6                   Time at which timeout occurs
XTotBlks rmb   2                   total blocks received
XTotErrs rmb   2                   total errors
XDatSiz  rmb   2
XBlkSiz  rmb   2
*
*
och      rmb   8                   Output to modem buffer
dummy    rmb   1
ch       rmb   lkeybuf+1           I/O buff for modem and console
*
*
pthopts equ   .
conopt   rmb   32                  console opts during XCom9
mopt     rmb   32                  modem opts during XCom9
iconopt  rmb   32                  initial console opts
imopt    rmb   32                  initial modem opts
topopts  equ   .
*
pathsbot equ   .                   area for path names
rpthnam  rmb   40
spthnam  rmb   40
dialbuff rmb   32                  Number to dial
pathstop equ   .
*
MsgBuf   rmb   96                  80 chrs + CR/LF + cursor ctl
TranTab  rmb   32                  ASCII translation table
*
stkbot   rmb   $200 move stack here after startup
stktop   equ   .
stksiz   equ   .-stkbot
dskbufs  equ   .               Send and Receive disk buffer areas
datasiz  equ   256             good size for disk read/write
Losndptr rmb   2
sndptr   rmb   2
Hisndptr rmb   2
SndCtr   rmb   2                   bytes in send buffer
icount   rmb   2
buffptr  rmb   2
buffcnt  rmb   2
CRCAcc   rmb   2

sndbuf   equ   .                   calculate based on sndptr???
sndsoh   rmb   1
sndblk   rmb   1                   xmodem blk number
sndnblk  rmb   1                   1's complement of blk numb
sndtxt   rmb   1024                reserve bytes for xmodem txfer
sndlrc   rmb   2
*         rmb   datasiz+sndbuf-.    reserve remaining bytes for normal Tx
         rmb   datasiz    reserve remaining bytes for normal Tx
sndBTop  equ   .
sndsiz   equ   sndBtop-sndBuf

*
Lorcvptr rmb   2
rcvptr   rmb   2
Hircvptr rmb   2
Rcvbuf   equ   .
rcvsoh   rmb   1
rcvblk   rmb   1
rcvnblk  rmb   1
rcvtxt   rmb   1024
rcvlrc   rmb   2
*         rmb   datasiz+rcvbuf-.    will expand if more memory given
         rmb   datasiz    will expand if more memory given
rcvsiz   equ   .-rcvbuf
eofcr    rmb   1                   for cr at end of run
parmbot  rmb   32                  be sure at least some parm area
parmtop  equ   .
         rmb   MaxRam-.            pad buff area out to max
GmtMem   equ   .
*
