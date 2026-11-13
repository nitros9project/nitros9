********************************************************************
* Rename - Rename a file
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   6      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.
*
*          2025/05/05  Boisy Pitre
* Added Microware comments from Soren Roug's Microware source archive.

 nam Rename
 ttl Rename a file

 ifp1
 use defsfile
 endc

tylg set Prgrm+Objct
atrv set ReEnt+rev
rev set $00
edition set 8

 mod eom,name,tylg,atrv,start,size

*
* Data Storage Definitions
*
 org 0
parmptr rmb 2 directory name ptr
oldnam rmb 2 old file name ptr
oldsiz rmb 1 old file name size
nextparm rmb 2 new file name ptr
newsiz rmb 2 new file name size
sourceptr rmb 2
parentpath rmb 1
packet rmb 60 old and new zero-padded basenames
 rmb 256 stack space
 rmb 200 room for params
size equ .

name fcs /Rename/
 fcb edition

* Split the source path without opening the child: only its parent needs
* write permission. SS.Rename takes X=old[30]+new[30], Y=60 on that parent.
start cmpd #4
 lbcs bpnam
SkipLeading lda ,x
 cmpa #C$SPAC
 bne SourceReady
 leax 1,x
 bra SkipLeading
SourceReady stx <parmptr
 stx <sourceptr
ScanSource lda ,x+
 bmi SourceEnd
 cmpa #C$SPAC
 bhi ScanSource
SourceEnd cmpa #C$CR
 lbeq bpnam
SkipNew lda ,x
 cmpa #C$SPAC
 beq NextNew
 cmpa #C$COMA
 bne NewReady
NextNew leax 1,x
 bra SkipNew
NewReady stx <nextparm
 pshs u
 lbsr PFNS
 puls u
 lbcs Exit
 ldb <oldsiz
 cmpb #29
 lbhi bpnam
 tstb
 lbeq bpnam
 leax packet,u
 ldb #60
ClearPacket clr ,x+
 decb
 bne ClearPacket
 ldx <oldnam
 leay packet,u
 ldb <oldsiz
 lbsr CopyName
 ldx <nextparm
 leay packet+30,u
 ldb <newsiz+1
 lbsr CopyName
 ldx <oldnam
 cmpx <sourceptr
 beq ParentReady
 lda #C$CR
 sta -1,x
ParentReady ldx <parmptr
 lda #DIR.!WRITE.
 os9 I$Open
 bcs Exit
 sta <parentpath
 leax packet,u
 ldy #60
 ldb #SS.Rename
 os9 I$SetStt
 pshs b,cc
 lda <parentpath
 os9 I$Close
 bcs CloseError
 puls b,cc
 bcs Exit
 clrb                          Successful SetStt need not clear B
 bra Exit
CloseError pshs b
 ldb 1,s
 bitb #1
 puls b
 beq CloseFailure
 puls b,cc
 bra Exit
CloseFailure leas 2,s
Exit os9 F$Exit
bpnam ldb #E$BPNam
 bra Exit
CopyName lda ,x+
 anda #$7F
 sta ,y+
 decb
 bne CopyName
 rts
Dot fcc "."
 fcb C$CR

PFNS ldx <parmptr get directory name ptr
 bsr RBFPNam parse name
 ldu <parmptr get directory name ptr
 lda ,u get first byte
 cmpa #PDELIM is it pathlist delimiter?
 beq PFNS10 branch if so
 lda ,y get next byte
 cmpa #PDELIM is it pathlist delimiter?
 beq PFNS10 branch if so
 leau <Dot,pcr get directory name ptr
 stu <parmptr s
 bra PFNS20
PFNS10 leax ,y move to next name
 bsr RBFPNam parse name
 bcs PFNERR branch if error
PFNS20 stx <oldnam set beginning of last name
 stb <oldsiz set old name size
 leax ,y get beginning of next name
 bsr RBFPNam parse name
 bcc PFNS20 branch if good name
 ldb <oldsiz was last name '.' type?
 beq PFNERR branch if so
 ldx <nextparm get new name ptr
 os9 F$PrsNam parse name
 bcs PFNERR branch if error
 lda ,y get next byte
 cmpa #PDELIM is it pathlist delimiter?
 beq PFNERR branch if so
 cmpb #30 is name too big?
 bcc PFNERR branch if so
 stx <nextparm save new name ptr
 clra
 std <newsiz save new name size
 rts
 
PFNERR comb
 ldb #E$BPNam err: bad path name
 rts
 
RBFPNam os9 F$PrsNam is there normal name?
 bcc RBFPN50 branch if so
 clrb clear byte count
 leau ,x copy pathlist ptr
RBFPN10 lda ,u+ get next character
 bpl RBFPN20 branch if not last character
 incb count character
 cmpa #C$PERD!$80 is it directory name?
 bne RBFPN30 branch if so
RBFPN20 incb count character
 cmpa #C$PERD is it directory name?
 beq RBFPN10 branch if so
RBFPN30 decb uncount last character
 beq RBFPN40 branch if no name
 leay -1,u get end-of-name ptr
 cmpb #$03 legal directory name?
 bcc RBFPN40 branch if not
 clrb clear carry
 bra RBFPN50
RBFPN40 coma set carry
RBFPN50 rts

 emod
eom equ *
 end

