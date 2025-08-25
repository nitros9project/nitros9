********************************************************************
* Login - Timeshare login utility
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   7      ????/??/??
* Beginning of history
*
*   8      1982/12/02  WGP
* Conditionals added for LI, LII assembly
*
*   9      1982/12/03  KKK
* Optimized MOTD code for LI
*
*  16      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.
*
*  17      1999/05/11  Boisy G. Pitre
* Fixed for years 1900-2155.
*
*  18      2002/07/20  Boisy G. Pitre
* Changed icpt routine rts to rti, put in conditionals for Level One
* not to execute the os9 F$SUser command.
*
*  19      2010/01/29  Boisy G. Pitre
* Changed icpt routine to honor the S$HUP signal and exit

 nam Login
 ttl Timeshare login utility

 ifp1
 use defsfile
 endc

tylg set Prgrm+Objct
atrv set ReEnt+rev
rev set $00
edition set 19

 mod eom,name,tylg,atrv,start,size

NUMTRIES set 3

MAXTRY set 3 Num of login attempts permitted
LINSIZ set 80 Input line buffer size
normal equ 0 normal screen size
small equ 1 small screen size
Screen equ normal normal screen size
PSWBSZ equ 128 Password file max rcd length
C$PWDL set C$COMA Password rcd field delimiter

 org 0
u0000 rmb 1
passpath rmb 1
motdpath rmb 1
retries rmb 1
defuid rmb 1 user's process id
priority rmb 1
passline rmb 2 password file buffer ptr
rdbufptr rmb 2 password file buffer ptr
buffnext rmb 2 input line buffer ptr
convbyte rmb 1 significant digit flag
timebuff rmb 5 system date/time
linebuff rmb PSWBSZ password file buffer
readbuff rmb LINSIZ input line buffer
outbuf rmb LINSIZ
popts rmb PD.OPT buffer for terminal path options
stack rmb 251
size equ .

name fcs /Login/
 fcb edition


initmod fcs "init"

**********
* Password Record Format
*
* User name (comma delimiter)
* Password
* User Id (decimal 0-65535)
* Priority (decimal, 1-255 high)
* Execution Directory
* Data directory
* Execution Command
*
* Maximum Record Size = PSWBSZ (128)
**********
 pag
passfile fcc "SYS/PASSWORD"
 fcb C$CR
UName fcb C$LF
 fcc "User name?: "
UNameLen equ *-UName

Who fcc "Who?"
 fcb C$CR

Pass fcc "Password: "
PassLen equ *-Pass
nvPass fcc "Invalid password."
 fcb C$CR

ProcNum fcb C$LF
 fcc "Process #"
ProcNumL equ *-ProcNum

lo1 fcc " logged on "
lo1len equ *-lo1

lo2 fcc " logged on "
 fcb C$LF
lo2len equ *-lo2

Welcome fcc "Welcome!"
 fcb C$CR

DirNotFnd fcc "Directory not found."
 fcb C$CR

Syntax fcb C$LF
 fcc "Syntax Error in password file"

onthe fcc "on the "
onthel equ *-onthe

Sorry fcb C$LF
 fcc "It's been nice communicating with you."
 fcb C$LF
 fcc "Better luck next time."
 fcb C$CR

MOTDStr fcc "SYS/MOTD"
 fcb C$CR

root fcc "...... " path to root

IcptRtn
 cmpb #S$HUP
 lbeq Exit
 rti note, was rts in original code

* Entry: X = pointer to start of nul terminated string
* Exit:  D = length of string
strlen pshs x
 ldd #-1
go@ addd #$0001
 tst ,x+
 bne go@
 puls x,pc

 pag
**********
* Login
*   Login New User, Establishing (From Password File)
*   User-Id, Priority, Exec-Dir, Data-Dir, Shell-Program
start pshs y,x save registers
 leax <IcptRtn,pcr point to intercept routine
 os9 F$Icpt install it
 ifgt Level-1
 bcs LOG01 branch if error
 ldy #$0000 super user ID
 os9 F$SUser set user ID to super user
 endc
LOG01 puls y,x restore registers
 lbcs Exit branch if error
*         clr   <u0000
 leay >outbuf,u
 sty <buffnext
 leay >readbuff,u
 sty <rdbufptr
 std ,--s save param size
 beq LOG04 ..zero; don't copy param
LOG03 lda ,x+ ..zero; don't copy param
 sta ,y+
 cmpa #C$CR
 bne LOG03
LOG04
*         lda   #$01
*         ldb   #SS.ScSiz
*         os9   I$GetStt
*         bcc   L01A4
*         cmpb  #E$UnkSvc
*         beq   L01AB
*         lbra  LOG50
*L01A4    cmpx  #51
*         bcc   L01AB
*         inc   <u0000
L01AB lda #READ.
 leax >root,pcr point to root dir string
 os9 I$ChgDir and change to that directory
 lda #READ.
 leax >passfile,pcr
 os9 I$Open open password file
 lbcs Exit ..error; exit
 sta <passpath and save path
 lda #NUMTRIES max # of bad password tries
 sta <retries initialize the retry counter
 ldd ,s++ any parameter given?
 beq LOG05 ..no
 ldx <rdbufptr
 lda ,x any parameter given?
 cmpa #C$CR
 bne LOG15 ..yes; don't print header prompt
LOG05
*         tst   <u0000
*         beq   L01E1
*         leax  >NrrwMsg,pcr
*         ldy   #NrrwMsgL
*         bra   L01E9
L01E1
 leax initmod,pcr
 clra
 pshs u
 os9 F$Link
 tfr u,x
 puls u
 bcs LOG10
 pshs x
 ldd OSName,x point to OS name in INIT module
 leax d,x point to install name in INIT module
 lbsr strlen
 tfr d,y
 lbsr copystr
 lbsr putspace
 leax onthe,pcr
 ldy #onthel
 lbsr copystr

 puls x
 ldd InstallName,x
 leax d,x point to install name in INIT module
 lbsr strlen
 tfr d,y
 lbsr strandtime
 lbsr WRITA

LOG10 dec <retries
 leax >Sorry,pcr
 lbmi TOOB10 ..yes; print error, exit
 leax >readbuff,u
 stx <rdbufptr
 leax >UName,pcr
 ldy #UNameLen
 lbsr INPLIN print "user name: ", get input
 bcs LOG20
LOG15 lbsr readpassword find name in password file
 bcc LOG30 ..found; continue
LOG20 leax >Who,pcr
LOG25 lbsr writeX print "who?"
 bra LOG10
 
LOG30 lbsr CHKNAM password given?
 bcc LOG40 ..yes; continue
 ldx <rdbufptr
 lda ,x
 cmpa #C$CR end of line?
 bne LOG35
 lda #C$PWDL
 sta ,x+
 stx <rdbufptr
 lbsr killecho disable terminal echo
 leax >Pass,pcr
 ldy #PassLen
 lbsr INPLIN print "password: ", get input
 lbsr setopts
 bcs LOG20 ..error; retry
 lbsr CHKNAM valid password?
 bcc LOG40 ..yes; continue
LOG35 leax >readbuff,u
 stx <rdbufptr
 lbsr SEAR10 maybe another user has same name?
 bcc LOG30 ..yes; check this password
 leax >nvPass,pcr
 bra LOG25 print "try again", restart
 
LOG40 lda <passpath
 os9 I$Close close password file
 lbsr GETNUM user number from password file
 tfr d,y
 ifgt Level-1
 os9 F$SUser set new user index
 endc
 lbsr GETNUM priority from password file
 tsta less than 256?
 lbne TOOBAD ..no; password file error
 tstb
 lbeq TOOBAD
 stb <priority
 os9 F$ID get process id
 sta <defuid save off
 lda #READ.
 leax >MOTDStr,pcr
 os9 I$Open
 bcc LOG50 ..error
 clra
LOG50 sta <motdpath save MOTD path number
 lda #EXEC.
 bsr CHGDIR set user's execution dir
 lda #READ.+WRITE.
 bsr CHGDIR set user's data dir
 leax >ProcNum,pcr
 ldy #ProcNumL
 lbsr copystr print "user # "
 leax defuid,u
 lbsr PRTNUM print number
*         tst   <u0000
*         beq   L02A8
*         leax  >lo2,pcr
*         ldy   #lo2len
*         bra   L02B0
L02A8 leax >lo1,pcr
 ldy #lo1len
L02B0 bsr strandtime print "logged on" (time)
 leax >Welcome,pcr
 bsr writeX print "welcome!"
 lbsr MOTD print message of the day
 clrb return no error
 ldx <passline get password line in X
 leau ,x module/path ptr
LOG80 lda ,u+
 cmpa #'0 skip to first separator
 bcc LOG80
 cmpa #C$PWDL
 beq LOG82 skip comma
 leau -passpath,u
LOG82 lda ,u+
 cmpa #C$SPAC
 beq LOG82 skip spaces
 leau -passpath,u
 pshs u save param ptr
 ldy #$0000
LOG85 lda ,u+
 leay $01,y update param size
 cmpa #C$CR
 bne LOG85
 puls u
 lda <defuid
 ldb <priority
 os9 F$SPrior set priority
 ldd #256
 os9 F$Chain chain to user's shell
 os9 F$PErr
Exit os9 F$Exit exit if error

CHGDIR ldx <passline
 os9 I$ChgDir change directory
 bcs CHDERR
 ldx <passline
CHGD10 lda ,x+ skip over dir name
 cmpa #C$CR end of line?
 beq TOOBAD ..yes; syntax error
 cmpa #C$PWDL delimeter (comma)?
 bne CHGD10 ..no; skip
 lda #C$SPAC
CHGD20 cmpa ,x+ also skip any spaces
 beq CHGD20
 leax ,-x back up to non-blank
 stx <passline
 rts
 
CHDERR leax >DirNotFnd,pcr
 bra TOOB10
 
TOOBAD leax >Syntax,pcr
TOOB10 bsr writeX
 clrb return no error
 os9 F$Exit

* Entry: X = ptr to string to write
writeX ldy #256
 lda #$01 print to std output path
 os9 I$WritLn
 rts

strandtime
 bsr copystr print message
 lbsr putspace
 lbsr putspace print spaces
 lbra DATTIM print date,time

* Entry: X = ptr to string to copy
*        Y = length of string
copystr
 cmpy #$0000
 beq copyex
 lda ,x+
 lbsr puta
 leay -$01,y
 bne copystr
copyex rts

INPLIN bsr copystr print prompt
 lbsr writestr
 ldx <rdbufptr
 ldy #LINSIZ
 clra
 os9 I$ReadLn
 rts

killecho pshs x,b,a save regs
 leax >popts,u ptr to options buffer
 ldb #SS.Opt get path options
 clra for stdin
 os9 I$GetStt get status
 bcs notscf branch if error
 lda (PD.OPT-PD.FST),x get path type
 cmpa #DT.SCF SCF device?
 bne notscf branch if not
 lda (PD.EKO-PD.FST),x get echo option
 pshs a save path echo flag
 clr (PD.EKO-PD.FST),x disable SCF's auto-Echo
 bsr setopts re-write path options
 puls a restore echo control
 sta (PD.EKO-PD.FST),x
 puls pc,x,b,a return
 
notscf lda #$FF
 sta (PD.OPT-PD.FST),x set unknown device type
 puls pc,x,b,a return
 
setopts pshs x,b,a,cc save regs
 leax >popts,u
 lda (PD.OPT-PD.FST),x
 cmpa #DT.SCF SCF device?
 bne KILECH10 ..no; exit
 ldb #SS.Opt re-write options
 clra on std input file
 os9 I$SetStt
KILECH10 puls pc,x,b,a,cc return

readpassword
 pshs u
 lda <passpath get path to password file
 ldx #$0000 seek to file position zero
 leau ,x
 os9 I$Seek reset password file
 puls u
SEAR10 lda <passpath
 leax >linebuff,u read a line from the password file
 ldy #PSWBSZ
 os9 I$ReadLn read one password record
 bcs SEAR90 branch if error
 stx <passline else save pointer to line
 bsr CHKNAM compare names in buffers
 bcs SEAR10 ..not equal; repeat
 stx <passline
SEAR90 rts return

CHKNAM ldx <passline
 ldy <rdbufptr
CHKN10 lda ,x+ get next char from passwd rcd
 cmpa #C$PWDL ..field delimiter?
 beq CHKN90 ..yes; return found
 cmpa #C$CR ..end of record?
 beq CHKN80 ..yes; return found
 eora ,y+
 anda #$FF-$20 char match?
 beq CHKN10 ..yes; keep looking
CHKNER comb return error
 rts
 
CHKN80 leax -$01,x
CHKN90 lda ,y+
 cmpa #C$PWDL
 beq CHKN99 skip trailing delimiter
 cmpa #'0
 bcc CHKNER ..error if not delimeter
 leay -$01,y
CHKN99 lda ,y+
 cmpa #C$SPAC skip spaces
 beq CHKN99
 leay -$01,y
 sty <rdbufptr save updated line ptr
 stx <passline
 clrb return carry clear
 rts
 
MOTD10 lbsr writeX print the line
MOTD lda <motdpath MOTD path number
 beq MOTD99 ..sorry
 leax >readbuff,u load MOTD buffer pointer
 ldy #LINSIZ maximum bytes to read
 os9 I$ReadLn read a MOTD line
 bcc MOTD10 exit if error
 lda <motdpath load MOTD path number
 os9 I$Close close MOTD path
MOTD99 clrb return no error
 rts return

**********
* Getnum
*   Get 16-Bit Ascii Number At Bufptr
*
* Returns: (D)=(Unsigned) Binary Number
*          Bufptr (Updated)
GETNUM ldx <passline
 clra
 clrb
 pshs y,x,b,a
 pshs b
GETN10 ldb ,x+ get next digit
 cmpb #C$PERD
 bne GETN20
 tsta
 lbne TOOBAD
 ldb $02,s
 stb ,s
 clr $02,s
 bra GETN10
GETN20 subb #'0 convert to binary
 cmpb #9 numeric?
 bhi GETN90 ..no; exit
 clra
 ldy #10
GETN30 addd $01,s plus previous sum * 10
 lbcs TOOBAD
 leay -$01,y
 bne GETN30
 std $01,s save new sum
 bra GETN10 ..repeat
 
GETN90 lda -$01,x
 cmpa #C$PWDL followed by delimiter?
 lbne TOOBAD
 stx <passline
 lda ,s+
 beq GETN99
 tst ,s
 lbne TOOBAD
 sta ,s
GETN99 puls pc,y,x,b,a return

*****
* Datime
*   Print: Mm/Dd/Yy Hh:Mm:Ss
*
DATTIM leax timebuff,u
 os9 F$Time get current time
 bsr Y2K put Y2K compliant time string
 bsr putspace put space
 bsr DTIM50
 bra WRITA
DTIM50 bsr PRTNUM
 bsr putcolon
putcolon lda #':
 bra DTIM60
Y2K lda #19 start out in 19th century
 ldb ,x get year
CntyLp subb #100 subtract
 bcs GotCntry if carry set, we have century
 inca
 bra CntyLp continue
GotCntry addb #100
 stb ,x
 tfr a,b
PrCnty bsr PRTN05
 bsr PRTNUM
 bsr Slash
Slash lda #'/
DTIM60 bsr puta add slash to buffer


*****
* Prtnum
*   Print 8-Bit Ascii Number In (,X+)
*
PRTNUM ldb ,x+
PRTN05 lda #'0-1
 clr <convbyte ..no significant digits
PRTN10 inca form Hundreds digit
 subb #100
 bcc PRTN10
 bsr ZERSUP print if not zero
 lda #'9+1
PRNT20 deca form Tens digit
 addb #10
 bcc PRNT20
 bsr puta print
 tfr b,a
 adda #'0 form units digit
 bra puta
 
ZERSUP inc <convbyte
 cmpa #'0
 bne puta
 dec <convbyte
 bne puta
 rts

putspace lda #C$SPAC
puta pshs x
 ldx <buffnext
 sta ,x+
 stx <buffnext
 puls pc,x

WRITA pshs a
 lda #C$CR
 bsr puta
 puls a
writestr pshs y,x,b,a
 leax >outbuf,u
 ldd <buffnext
 stx <buffnext
 subd <buffnext
 tfr d,y
 lda #$01
 os9 I$WritLn
 puls pc,y,x,b,a

 emod
eom equ *
 end
