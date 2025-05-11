********************************************************************
* Free - Print disk free space
*
* Author: Robert Doggett
* Defaults to current data directory
* Also shows Volume name, create date, capacity.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   4      ????/??/??
* Buffered Bitmap sector I/O.
*
*   5      1983/01/13
* Added quotes around disk name
*
*   6      1983/04/01
* Increased Bitmap buffer from 256 to 4096 bytes
* From Tandy OS-9 Level One VR 02.00.00.
*
*   7      ????/??/??
* Y2K fixed.
*
*           2025/05/05  Boisy G. Pitre
* Added Microware comments from Soren Roug's Microware sources.

 nam Free
 ttl Print disk free space

 ifp1
 use defsfile
 endc

tylg set Prgrm+Objct
atrv set ReEnt+rev
rev set $00
edition set 7

 mod eom,name,tylg,atrv,start,size

MAPOFF equ $100 Bitmap offset on disk
BITBUFSZ equ 4096 bitmap buffer size

 org 0
zersup rmb 1 0=zero suppression
linpos rmb 2 current line ptr
devpath rmb 1 disk path number
avail rmb 3 available disk space (sectors)
largst rmb 3 largest disk block (sectors)
segmnt rmb 3 temp largest disk block
frlbuf rmb 80 output line buffer
dskbuf rmb DD.NAM+32 device descriptor buffer
bmapend rmb 2  end of bitmap ptr
BITBUFF rmb BITBUFSZ bitmap Buffer
 rmb 250 stack room
 rmb 200 room for params
size equ .

name fcs /Free/
 fcb edition
 ifne DOHELP
HelpMsg fcb C$LF
 fcc "Use: free [/diskname]"
 fcb C$LF
 fcc " tells how many disk sectors are unused"
 fcb C$CR
 endc
HelpSz equ *-HelpMsg
 
CREATE fcs /" created on:/
CAPCTY fcs "Capacity:"
SECTRS fcs " sectors ("
CLUSTR fcs "-sector clusters)"
SPACE fcs " free sectors, largest block"
LONG fcs " sectors"

 pag
**********
* Free
*   Report Disk Free Space
*
start leay frlbuf,u
 sty <linpos reset I/O buffer
 cmpd #$0000
 beq FREE30 ..no parameters, default
 lda ,x+
 cmpa #C$CR empty parameter list?
 beq FREE30 ..yes; use default
 cmpa #PDELIM device name?
 beq FREE10 ..yes; good
FREE05 equ *
 ifne DOHELP
 leax >HelpMsg,pcr point to help message
 ldy #HelpSz max bytes
 lda #$02 stderr
 os9 I$WritLn print usage instructions
 endc
 lbra ExitOk exit
FREE10 leax -$01,x back up to slash
 pshs x
 os9 F$PrsNam parse the device name on cmd line
 puls x
 bcs FREE05 ..error; print err msg
FREE20 lda ,x+
 lbsr FROCHR copy parameter into i/o buffer
* try decb here
 subb #$01
 bcc FREE20 until end of first name found

FREE30 lda #PENTIR add "open disk" character
 lbsr FROCHR
 lbsr FRSPAC
 leax frlbuf,u
 stx <linpos reset i/o buffer
 lda #READ. read mode
 os9 I$Open open disk as random I/O file
 sta <devpath save disk path number
 bcs FREE35 ..error; exit
 leax <dskbuf,u
 ldy #DD.NAM+32
 os9 I$Read read disk device descriptor
FREE35 lbcs Exit ..error; exit
 lbsr FREOL print blank line
 lda #'" get quote char
 lbsr FROCHR insert leading quote
 leay DSKBUF+DD.NAM,u
 lbsr FRNAME put disk name in I/O buffer
 dec <linpos+1 eliminate trailing space
 leay >CREATE,pcr
 lbsr FRNAME put "created" in I/O buffer
 lbsr FRDATE put create date in buffer
 lbsr FREOL print
 
 leay >CAPCTY,pcr
 lbsr FRNAME print "capacity:"
 leax <DSKBUF+DD.TOT,u
 lbsr FRITOA print total disk size
 leay >SECTRS,pcr
 lbsr FRNAME print "sectors ( "
 dec <linpos+1 remove trailing space
 ldd <DSKBUF+DD.BIT
 pshs b,a
 clr ,-s
 leax ,s
 lbsr FRITOA print sectors per cluster
 leas $03,s
 leay >CLUSTR,pcr
 lbsr FRNAME print "-sector clusters"
 lbsr FREOL
 
 clra
 clrb
 sta <avail clear available sector count
 std <avail+1
 sta <segmnt clear current segment size
 std <segmnt+1
 sta <largst clear largest segment size
 std <largst+1
 lda <devpath
 ldx #$0000
 pshs u
 ldu #MAPOFF
 os9 I$Seek seek to bitmap sector
 puls u
 
FREE40 leax >BITBUFF,u bitmap Buffer ptr
 ldd #BITBUFSZ
 cmpd <DSKBUF+DD.MAP
 bls FREE42
 ldd <DSKBUF+DD.MAP
FREE42 leay d,x
 sty <bmapend
 tfr d,y
 lda <devpath
 os9 I$Read read one sector of bitmap
 bcs Exit ..error; exit
FREE45 lda ,x+ count bits
 bsr FRBITS save bit count
 stb ,-s save bit count
 beq FREE70 while bitcount>0 do
FREE50 ldd <avail+1
 addd <DSKBUF+DD.BIT add sectors per bit amount
 std <avail+1
 bcc FREE60
 inc <avail
FREE60 dec ,s decrement bitcount
 bne FREE50
FREE70 leas $01,s goodbye scratch
 cmpx <bmapend end of this bitmap sector?
 bcs FREE45 ..no; get next byte
 ldd <DSKBUF+DD.MAP
 subd #BITBUFSZ dec bitmap size; end of bitmap?
 std <DSKBUF+DD.MAP
 bhi FREE40 ..no; go read next bitmap byte
 bsr FRBT60 Update largest
 
 leax avail,u
 lbsr FRITOA print free sector count
 leay >SPACE,pcr
 bsr FRNAME print "free sectors, largest block is"
 leax largst,u
 lbsr FRITOA print largest contiguous block
 leay >LONG,pcr
 bsr FRNAME print "sectors long"
 bsr FREOL
 
 lda <devpath
 os9 I$Close close disk
 bcs Exit ..error; report it
 
ExitOk clrb return No error
Exit os9 F$Exit

**********
* Frbits
*   Count Free Bits, And Keep
*   Track Of Longest Segment
*
* Passed: (A)=Bitmap Byte
* Returns: (B)=Number Of Bits Set
* Destroys: A
*
FRBITS clrb
 cmpa #$FF none free?
 beq FRBT60 ..right; update current segment
 bsr FRBT10 (8)
FRBT10 bsr FRBT20 (4)
FRBT20 bsr FRBT30 (2)
FRBT30 lsla process high order bit
 bcs FRBT60 ..bra if not free
 incb update bit count
 pshs b,a
 ldd <segmnt+1
 addd <DSKBUF+DD.BIT add in sectors per bit
 std <segmnt+1
 bcc FRBT50
 inc <segmnt
FRBT50 puls pc,b,a return

FRBT60 pshs b,a
 ldd <segmnt end of current segment
 cmpd <largst longer than largest?
 bhi FRBT70 ..yes
 bne FRBT80 ..no
 ldb <segmnt+2
 cmpb <largst+2
 bls FRBT80 ..no
FRBT70 sta <largst update largest size
 ldd <segmnt+1
 std <largst+1
FRBT80 clr <segmnt lear out current segment
 clr <segmnt+1
 clr <segmnt+2
 puls pc,b,a
 
**********
* Frname
*   Print Name, High Bit Delimiter
*
* Passed: (Y)=Ptr To Name
* Destroys: A,CC
*
FRNAME lda ,y
 anda #$7F
 bsr FROCHR
 lda ,y+
 bpl FRNAME
 
**********
* Frochr
*   Put One Char In Output Buffer
*
* Passed: (A)+Char
* Destroys: CC
*
FRSPAC lda #C$SPAC

FROCHR pshs x
 ldx <linpos
 sta ,x+
 stx <linpos
 puls pc,x

**********
* Freol
*   Print Buffer
*
* Destroys: CC
*
FREOL pshs y,x,a
 lda #C$CR
 bsr FROCHR put carriage return in buffer
 leax frlbuf,u
 stx <linpos reset line ptr
 ldy #80
 lda #$01 standard output
 os9 I$WritLn write the line
 puls pc,y,x,a

pag
**********
* Fritoa
*   Convert (Binary) Integer To Ascii
*
* Passed: (X)=Ptr To 3-Byte Integer
* Destroys: A,CC
*
Base fcb $98,$96,$80 10,000,000
 fcb $0f,$42,$40 1,000,000
 fcb $01,$86,$a0 100,000
 fcb $00,$27,$10 10,000
 fcb $00,$03,$e8 1,000
 fcb $00,$00,$64 100
 fcb $00,$00,$0a 10
 fcb $00,$00,$01 1

* Show a 24 bit number as a decimal value with commas
FRITOA lda #10 (table index)
 pshs y,x,b,a save regs
 leay <Base,pcr get power of ten table
 clr <zersup set zero suppression
 ldb ,x get first byte
 ldx $01,x get 2nd and 3rd bytes
FRIT10 lda #-1
FRIT20 inca increment digit being built
 exg d,x
 subd $01,y subtract power of ten
 exg d,x
 sbcb ,y
 bcc FRIT20 ..repeat until underflow
 bsr FRZSUP print, with zero suppression
 exg d,x
 addd $01,y add back overflow
 exg d,x
 adcb ,y
 leay $03,y move to next lower power
 dec ,s done?
 beq FRIT40 ..yes; exit
 lda ,s
 cmpa #$01 units entry?
 bne FRIT30 ..no
 sta <zersup turn off zero suppression
FRIT30 bita #$03 comma field?
 bne FRIT10 ..no; continue
 dec ,s
 tst <zersup zero suppression?
 beq FRIT10 ..yes; continue
 lda #',
 bsr FROCHR print comma
 bra FRIT10 then continue
FRIT40 puls pc,y,x,b,a return

 pag
**********
* Frdate
*   Print "YY/MM/DD HH:MM:SS"
*
FRDATE leax <DSKBUF+DD.DAT,u
 bsr FRPNUM
 bsr FRDT10
FRDT10 lda #$2F
 lbsr FROCHR
 
 clr <zersup set zero suppression
 ldb ,x+
 lda #-1
FRPN10 inca form hundred digit
 subb #100
 bcc FRPN10
 bsr FRZSUP
FRPN05 lda #10
 sta <zersup print at least two digits
FRPN20 deca form tTens digit
 addb #10
 bcc FRPN20
 bsr FRZSUP print
 tfr b,a
 
**********
* Frzsup
*   Print Digit With Zero Suppression
* 
* Passed: (A)=Digit
* Destroys: A,CC
FRZSUP tsta zero?
 beq FRZS10
 sta <zersup ..no; end zero suppression
FRZS10 tst <zersup zero suppression?
 bne FRZS20 ..no; print digit
 rts
 
**********
* Frpnum
*   Print 8-Bit Decimal Number At (,X+)
*
FRPNUM ldb ,x+
 lda #$AE
FRPN30 inca form hundred digit
 subb #100
 bcc FRPN30
 pshs b
 tfr a,b
 bsr FRPN05
 puls b
 bra FRPN05
FRZS20 adda #'0
 lbra FROCHR

 emod
eom equ *
 end
