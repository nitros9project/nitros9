********************************************************************
* Link - Link to a module
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   4      ????/??/??
* Prehistoric.
*
*   5      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.

 nam Link
 ttl Link to a module

 ifp1
 use defsfile
 endc

tylg set Prgrm+Objct
atrv set ReEnt+rev
rev set $00
edition set 5

 mod eom,name,tylg,atrv,start,size

 org 0
 rmb 250 stack space
 rmb 200 parameter space
size equ .

name fcs /Link/
 fcb edition

start clra ANY type,revision
 clrb
 os9 F$Link link requested module
 bcs LINK10 ..exit if error
 lda ,x+
 cmpa #C$COMA another?
 beq start ..yes; unlink it
 lda ,-x
 cmpa #C$CR ..end of parameter list?
 bne start ..no; unlink next
 clrb
LINK10 os9 F$Exit

 emod
eom equ *
 end

