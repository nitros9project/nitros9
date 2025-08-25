********************************************************************
* Load - Load a module
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   4      ????/??/??
* Prehistoric.
* From Tandy OS-9 Level One VR 02.00.00.

 nam Load
 ttl Load a module

 ifp1
 use defsfile
 endc

tylg set Prgrm+Objct
atrv set ReEnt+rev
rev set $00
edition set 4

 mod eom,name,tylg,atrv,start,size

 org 0
 rmb 250 stack room
 rmb 200 room for params
size equ .

name fcs /Load/
 fcb edition

start os9 F$Load
 bcs Exit
 lda ,x
 cmpa #C$CR end of line?
 bne start ..no; repeat
 clrb
Exit os9 F$Exit

 emod
eom equ *
 end
