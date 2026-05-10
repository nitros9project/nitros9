********************************************************************
* List - List a text file
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   4      ????/??/??
* Prehistoric.
*
*   5      ????/??/??
* Copyright notice removed from object.
* Stack and param space reserved.
* From Tandy OS-9 Level One VR 02.00.00.

 nam List
 ttl List a text file

 ifp1
 use defsfile
 endc

tylg set Prgrm+Objct
atrv set ReEnt+rev
rev set $00
edition set 5

 mod eom,name,tylg,atrv,start,size

BUFSIZ set 200

 org 0
filepath rmb 1 input path number
parmptr rmb 2 paramter ptr
readbuff rmb BUFSIZ reserve buffer
 rmb 250 reserve stack
 rmb 200 room for parameter list
size equ .

name fcs /List/
 fcb edition

start stx <parmptr save parameter pointer
 lda #READ. read access mode
 os9 I$Open open file
 bcs LIST50 branch if error
 sta <filepath else save path to file
 stx <parmptr and updated parm pointer
 
LIST20 lda <filepath get path
 leax readbuff,u point X to read buffer
 ldy #200 read up to 200 bytes
 os9 I$ReadLn read it!
 bcs LIST30 branch if error
 lda #1 standard output
 os9 I$WritLn write line to stdout
 bcc LIST20 branch if ok
 bra LIST50 else exit
 
LIST30 cmpb #E$EOF did we get an EOF error?
 bne LIST50 exit if not
 lda <filepath else get path
 os9 I$Close and close it
 bcs LIST50 branch if error
 ldx <parmptr get param pointer
 lda ,x get char
 cmpa #C$CR end of command line?
 bne start branch if not
 clrb else clear carry
LIST50 os9 F$Exit and exit

 emod
eom equ *
 end
