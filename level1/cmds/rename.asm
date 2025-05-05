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
edition set 6

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
 rmb 256 stack space
 rmb 200 room for params
size equ .

name fcs /Rename/
 fcb edition

start cmpd #$0004 at least 3 chars + CR on cmd line?
 lbcs bpnam branch if less than
 stx <parmptr save parameter pointer
* find file
 lda #WRITE. write mode
 os9 I$Open open file to rename in write mode
 bcc RENM10 branch if ok
 cmpb #E$FNA file not accessible?
 bne Exit branch if any other error
 ldx <parmptr else get pointer to file
 lda #DIR.+WRITE. and try open as directory
 os9 I$Open try opening again
 bcs Exit branch if error
RENM10 stx <nextparm save off updated param pointer
* get options
 ldb #SS.Opt get path options
 leax <PD.OPT,u get direct page option ptr
 os9 I$GetStt get path options
 bcs Exit branch if error
 os9 I$Close close path to file
 bcs Exit branch if error
 ldb <PD.DTP get device type
 cmpb #DT.RBF RBF type device?
 bne bpnam branch if not
 bsr PFNS process file names
 bcs Exit branch if error
* move data directory to file's directory
 ldx <oldnam get old name ptr
 lda #C$CR get carriage return
 sta -1,x terminate directory name
 ldx <parmptr get directory name ptr
 lda #READ.+WRITE. change data directory
 os9 I$ChgDir change directory
 bcs Exit branch if errors
 ldx <nextparm get new name ptr
 ldb <newsiz+1 get new name size
 decb get name end offset
 lda b,x get last name byte
 ora #$80 set sign
 sta b,x update byte
 incb re-adjust name size
 cmpb <oldsiz names same size?
 bne RENM20 branch if not
 leay ,x copy new name ptr
 ldx <oldnam get old name ptr
 os9 F$CmpNam compare names
 bcc RENM30 branch if the same
RENM20 ldx <nextparm get new name ptr
 lda #READ.
 os9 I$Open try to open file
 bcc bpnam err: name in use
 cmpb #E$PNNF path name not in use?
 bne bpnam branch if not
RENM30 leax <Dot,pcr point to .
 lda #DIR.!UPDAT. open as directory in update mode
 os9 I$Open do it!
 bcs Exit branch if error
 ldx <PD.DCP get file directory entry ptr
 ldu <PD.DCP+2
 os9 I$Seek seek to position
 bcs Exit branch if error
 ldx <nextparm get new name ptr
 ldy <newsiz get new name size
 os9 I$Write write new name
 bcs Exit
 os9 I$Close close directory
 bcs Exit
 clrb
Exit os9 F$Exit

bpnam ldb #E$BPNam err: bad path name
 bra Exit

Dot fcc "." current directory name
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

