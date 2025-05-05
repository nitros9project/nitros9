********************************************************************
* Del - File deletion utility
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   5      ????/??/??  Kim Kempf
* From Tandy OS-9 Level One VR 02.00.00.
*
*   6      2003/01/13  Boisy G. Pitre
* Now option can be anywhere on command line, and all files will be
* deleted.  Also made smaller.
*
*   6      2025/05/05  Boisy G. Pitre
* Added Microware comments from Soren Roug's Microware sources.

 nam Del
 ttl File deletion utility

 ifp1
 use defsfile
 endc

DOHELP set 0

tylg set Prgrm+Objct
atrv set ReEnt+rev
rev set $00
edition set 6

 mod eom,name,tylg,atrv,start,size

 org 0
amode rmb 1
 rmb 250 stack room
stack rmb 200 parameter room
size equ .

name fcs /Del/
 fcb edition

 ifne DOHELP
HelpMsg fcb C$LF
 fcc "Use: Del [-x] <path> {<path>} [-x]"
 fcb C$CR
 endc

start lda ,x get first char on command line
 cmpa #C$CR carriage return?
 beq ShowHelp if so, no params, show help
 lda #READ.
 sta <amode default to non-sys delete
 pshs x save param pointer
 bsr GetOpts get opts
 puls x get param pointer
Del07 lda <amode
 os9 I$DeletX
 bcs Exit branch if error
 lda ,x get next byte
 cmpa #C$CR end of line?
 bne Del07 branch if more
ExitOk clrb
Exit os9 F$Exit

GetOpts ldd ,x+ parse parameters
 cmpa #C$SPAC
 beq GetOpts skip spaces
 cmpa #C$COMA
 beq GetOpts skip commas
 cmpa #C$CR
 beq Return skip carriage return
 cmpa #'- option delimiter
 bne SkipName no, branch
 eorb #'X
 andb #$DF is it execution directory option?
 bne ShowHelp branch if not
 lda #EXEC. get execution mode
 sta <amode save it
 ldd #C$SPAC*256+C$SPAC get two spaces
 std -1,x write over option

SkipName lda ,x+ get char
 cmpa #C$SPAC
 beq GetOpts skip spaces
 cmpa #C$COMA
 beq GetOpts skip commas
CheckCR cmpa #C$CR
 bne SkipName branch if not
Return rts

ShowHelp equ *
 ifne DOHELP
 leax >HelpMsg,pcr
 ldy #80
 lda #2 stderr
 os9 I$WritLn write help
 endc
 bra ExitOk

 emod
eom equ *
 end
