********************************************************************
* mdir - Show module directory
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   5      ????/??/??
*
*   6      2003/01/14  Boisy G. Pitre
* Changed option to -e, optimized slightly.
*
*   7      2003/08/25  Rodney V. Hamilton
* Fixed leading zero suppression, more optimizations.

 nam mdir
 ttl Show module directory

 use defsfile

* Set to 1 to include screen size checks for varying monitor widths
INCLUDE_SCREENSIZE_CODE equ 1

tylg set Prgrm+Objct
atrv set ReEnt+rev
rev set $00
edition set 7
stdout set 1

 mod eom,name,tylg,atrv,start,size

 org 0
mdstart rmb 2
mdend rmb 2
parmptr rmb 2
zflag rmb 1 suppress leading zeros flag
bufptr rmb 2
datebuf rmb 3
timebuf rmb 3
nmwdth rmb 1 name field width
strtcol rmb 1 last starting column
 ifne INCLUDE_SCREENSIZE_CODE
narrow rmb 1
 endc
buffer rmb 80
 rmb 200 stack
 rmb 250 parameters
size equ .

name fcs /mdir/
 fcb edition

tophead fcb C$LF
 fcs "  Module directory at "
ltitle fcb C$LF
 fcc "Addr Size Typ Rev Attr Use Module name"
 fcb C$LF
 fcc "---- ---- --- --- ---- --- ------------"
 fcb C$CR
 ifne INCLUDE_SCREENSIZE_CODE
stitle fcb C$LF
 fcc "Addr Size Ty Rv At Uc   Name"
 fcb C$LF
 fcc "---- ---- -- -- -- -- ---------"
 fcb C$CR
 endc
 
start stx <parmptr
 clr <zflag
 ifne INCLUDE_SCREENSIZE_CODE
 clr <narrow assume wide output
 lda #stdout standard output
 ldb #SS.ScSiz we need screen size
 os9 I$GetStt get it
 bcc ScSzOk branch if we got it
 cmpb #E$UnkSvc not a known service request error?
 lbne Exit if not, exit
 bra Do80
ScSzOk cmpx #80 80 columns?
 blt Chk51 branch if less than
 endc
Do80 ldd #$0C30
 ifne INCLUDE_SCREENSIZE_CODE
 bra SetSize
Chk51 cmpx #51 51 columns?
 blt Do32
Do51 ldd #$0C28
 bra SetSize
Do32 inc <narrow
 ldd #$0A15
 endc
SetSize
 std <nmwdth
 leay >tophead,pcr
 leax <buffer,u
 stx <bufptr
 lbsr CopyStr
 leax datebuf,u
 os9 F$Time
 leax timebuf,u
 lbsr PrtTim
 lbsr PrtBuf
 ldx >D.ModDir MUST use ext addr for page 0
 stx <mdstart
 ldd >D.ModDir+2
 std <mdend
 leax -MD$ESize,x
* Check for 'E' given as argument
 ldy <parmptr
 ldd ,y+
 andb #$DF
 cmpd #$2D45 -E ?
 bne PrtTtl40
 leax >ltitle,pcr
 ifne INCLUDE_SCREENSIZE_CODE
 tst <narrow
 beq PrtTtl
 leax >stitle,pcr
 endc
 
PrtTtl ldy #80 max. length to write
 lda #stdout
 os9 I$WritLn
 ldx <mdstart
 bra ChkEnt40
loop ldy MD$MPtr,x
 beq PrtTtl40 skip if unused slot
 ldd M$Name,y
 leay d,y
 lbsr CopyStr
PrtTtl10 lbsr OutSP
 ldb <bufptr+1
 subb #$12
 cmpb <strtcol
 bhi PrtTtl30
PrtTtl20 subb <nmwdth
 bhi PrtTtl20
 bne PrtTtl10
 bra PrtTtl40
PrtTtl30 lbsr PrtBuf
PrtTtl40 leax MD$ESize,x
 cmpx <mdend
 bcs loop
 lbsr PrtBuf
 bra ExitOk
 
*
* A module entry is 2 two byte pointers.
* If the first pointer is $0000, then the slot is unused
ChkEnt ldy MD$MPtr,x ptr=0?
 beq ChkEnt35 yes, skip unused slot
 ldd MD$MPtr,x address (faster than tfr)
 bsr Out4HS
 ldd M$Size,y size
 bsr Out4HS
 ifne INCLUDE_SCREENSIZE_CODE
 tst <narrow
 bne ChkEnt10
 endc
 bsr OutSP
ChkEnt10 lda M$Type,y type/lang
 bsr out2HS
 ifne INCLUDE_SCREENSIZE_CODE
 tst <narrow
 bne ChkEnt20
 endc
 bsr OutSP
ChkEnt20 lda M$Revs,y revision
 anda #RevsMask
 bsr out2HS
 ldb M$Revs,y attributes
 lda #'r
 bsr PrAtt bit 7 (ReEnt)
 ifne INCLUDE_SCREENSIZE_CODE
 tst <narrow
 bne ChkEnt30
 endc
 lda #'w bit 6 (ModProt:1=writable)
 bsr PrAtt
 lda #'3 bit 5 (ModNat:6309 Native mode)
 bsr PrAtt
 lda #'? bit 4 undefined
 bsr PrAtt
ChkEnt30 bsr OutSP
 bsr OutSP
 lda MD$Link,x user count
 bsr out2HS
 ldd M$Name,y
 leay d,y module name
 bsr CopyStr
 bsr PrtBuf
ChkEnt35 leax MD$ESize,x
ChkEnt40 cmpx <mdend
 bcs ChkEnt

ExitOk clrb
Exit os9 F$Exit

Out4HS inc <zflag suppress leading zeros
 inc <zflag
 bsr Byt2Hex
 dec <zflag
 tfr b,a
out2HS bsr Byt2Hex
 bra OutSP

Byt2Hex inc <zflag suppress leading zero
 pshs a
 lsra
 lsra
 lsra
 lsra
 bsr Byt2Hex10
 puls a
 anda #$0F is this a zero?
Byt2Hex10 bne Byt2Hex20 no, print it
 tst <zflag still suppressing zeros?
 bgt OutZSP yes, count it and print space
Byt2Hex20 clr <zflag nonzero, print all the rest
 adda #'0
 cmpa #'9
 bls ApndA
 adda #$07 Make it A-F
 bra ApndA

OutZSP dec <zflag countdown to last digit
OutSP lda #C$SPAC append a space
*
* append a char (in reg a) to buffer
*
ApndA pshs x
 ldx <bufptr
 sta ,x+
 stx <bufptr
 puls pc,x
*
* process attribute flag bit
*
PrAtt rolb
 bcs ApndA
 lda #'.
 bra ApndA
*
* Copy an FCS string to buffer
*
CopyStr lda ,y
 anda #$7F
 bsr ApndA
 lda ,y+
 bpl CopyStr
 rts
*
* Append a CR to buffer and write it
*
PrtBuf pshs y,x,a
 lda #C$CR
 bsr ApndA
 leax <buffer,u
 stx <bufptr
 ldy #80
 lda #stdout
 os9 I$WritLn
 puls pc,y,x,a

* Write the time to the buffer as HH:MM:SS
PrtTim bsr Byt2ASC
 bsr Colon
Colon lda #':
 bsr ApndA

* Convert byte in B to ASCII
* Entry: B = byte to convert 
Byt2ASC ldb ,x+
Hundreds subb #100
 bcc Hundreds
* code to print 100's digit removed - max time field value is 59
Tens lda #'9+1
TensLoop deca
 addb #10
 bcc TensLoop
 bsr ApndA
 tfr b,a
 adda #'0
 bra ApndA

 emod
eom equ *
 end
 