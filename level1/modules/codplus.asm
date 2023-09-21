********************************************************************
* CO80 - Dragon Plus 80 columns support for VTIO
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* 2021/04/10 - Initial driver implementation from CoWPRS - lfantoniosi
* ------------------------------------------------------------------

         nam   CODPLUS
         ttl   Dragon Plus Co-Driver for VTIO

BASEADDR equ   $FFE0            
CURSPTR  equ   V.ColPtr         cursor address (wrap at $4000)
DISPPTR  equ   V.Co80X          display start address (wrap at $800)
VRAM     equ   $01

         ifp1
         use   defsfile
         use   cocovtio.d
         endc

tylg     set   Systm+Objct   
atrv     set   ReEnt+rev
rev      set   $01
edition  set   2

         mod   eom,name,tylg,atrv,start,size

u0000    rmb   0
size     equ   .
         fcb   $06 

name     fcs   /CoDPlus/
         fcb   edition

* WordPak Initialization Values (6845 registers)
RegTbl   fcb   $71	R0    Horizontal Total
         fcb   $50	R1    Horizontal Displayed
         fcb   $5D	R2    Horizontal Sync Position
         fcb   $37 	R3    Horz/Vert Sync Widths
         fcb   $19 	R4    Vertical Total
         fcb   $1E 	R5    Vertical Total Adjust
         fcb   $18 	R6    Vertical Displayed
         fcb   $19 	R7    Vertical Sync Position
         fcb   $A2	R8    Mode Control
         fcb   $0A 	R9    Scan Lines/Row
L0034    fcb   $60 	R10   Cursor Start/Blink Rate
         fcb   $0A 	R11   Cursor End Scan Line
         fcb   $00 	R12   Display Start (MSB)
         fcb   $00 	R13   Display End (LSB)
         fcb   $00 	R14   Cursor Position (MSB)
         fcb   $00 	R15   Cursor Position (LSB)
         fcb   $00 	R16   Light Pen Position (MSB)
         fcb   $00 	R17   Light Pen Position (LSB)
         fcb   $00 	R18   Update Address (MSB)
         fcb   $00 	R19   Update Address (LSB)
         fcb   $10 	R20

start    equ   *
         lbra  Init
         lbra  Write
         lbra  GetStat
         lbra  SetStat
         lbra  Term

* Init
Init     pshs  x,y

         ldd   #0
         std   <DISPPTR,u
         std   <CURSPTR,u
         ldx   #BASEADDR
         lbsr  ClrScrn

         clra  
         leax  <RegTbl,pcr	point to initialization values
L0097    ldb   ,x+
         std   BASEADDR	    write to 6545 hardware
         inca
         cmpa  #20
         bcs   L0097

         ldb   <V.COLoad,u
         orb   #ModCoDPlus
         stb   <V.COLoad,u
         clrb  
         puls  x,y,pc

Term     ldb   <V.COLoad,u
         andb  #~ModCoDPlus
L004F    stb   <V.COLoad,u
         clrb  
         rts
   
* GetStat
GetStat  ldx   PD.RGS,y            get caller's regs
         cmpa  #SS.Cursr           Cursr?
         beq   Rt.Cursr            branch if so
         cmpa  #131                get O-PAK max ASCII code
         bne   ScrSz
         lda   #$7e                chargen goes up to 126
         sta   R$A,x
NoErr    clrb
         rts
ScrSz    cmpa  #132                O-PAK Screen Size
         bne   CurType
         lda   #$50
         sta   R$A,x               save in A
         lda   #$19
         sta   R$B,x               save in B
         bra   NoErr
CurType  cmpa  #134                O-PAK Cursor Type
         bne   SetStat
         ldd   #$0101              block cursor / slow blinking rate
         std   R$A,x
         bra   NoErr
* SetStat
SetStat  comb
         ldb   #E$UnkSvc
         rts

* SS.Cursr getstat
Rt.Cursr
         clra
         ldb   <V.C80Y,u
         addb  #$20
         std   R$Y,x
         ldb   <V.C80X,u
         addb  #$20
         std   R$X,x
         lda   <V.CChar,u
         sta   R$A,x
* no operation entry point
NoOp     clrb
         rts
   
* Write
Write
         ldx   #BASEADDR	get HW addr in X
         cmpa  #$0E		    $0E?
         bcs   L00B6		branch if less than
         cmpa  #$1A		    $1A?
         bcs   NoOp		    branch if less than
         cmpa  #C$SPAC		space?
         lbcs  Check1B		branch if less than
         cmpa  #$7e		    $7e?
         bcs   ChrOut		ASCII char, branch if less than
         cmpa  #$C0		    $C0?
         bls   L00A6		branch if lower or same
         anda  #$1F
         suba  #$01
         cmpa  #$19
         bhi   L00B2
         bra   ChrOut
L00A6    cmpa  #$AA		    $AA?
         bcs   L00B2		branch if less than
         ora   #$10
         anda  #$1F
         cmpa  #$1A
         bcc   ChrOut
L00B2    lda   #$A0
         bra   ChrOut

L00B6    leax  >FuncTbl,pcr
         lsla  
         ldd   a,x
         leax  d,x
         pshs  x
         ldx   #BASEADDR
         rts   

* display functions dispatch table
FuncTbl  fdb   NoOp-FuncTbl	$00:no-op (null)
         fdb   CurHome-FuncTbl	$01:HOME cursor
         fdb   CurXY-FuncTbl	$02:CURSOR XY
         fdb   ErLine-FuncTbl	$03:ERASE LINE
         fdb   ErEOL-FuncTbl	$04:ERASE TO EOL
         fdb   CurOnOff-FuncTbl	$05:CURSOR ON/OFF
         fdb   CurRgt-FuncTbl	$06:CURSOR RIGHT
         fdb   NoOp-FuncTbl	$07:no-op (bel:handled in VTIO)
         fdb   CurLft-FuncTbl	$08:CURSOR LEFT
         fdb   CurUp-FuncTbl	$09:CURSOR UP
         fdb   CurDown-FuncTbl	$0A:CURSOR DOWN
         fdb   ErEOS-FuncTbl	$0B:ERASE TO EOS
         fdb   ClrScrn-FuncTbl	$0C:CLEAR SCREEN
         fdb   CrRtn-FuncTbl	$0D:RETURN

* $08 - cursor left
CurLft   ldd   <V.C80X,u	get CO80 X/Y
         bne   L00E8		branch if not at start
         clrb  	
         rts   	
L00E8    deca  
         bge   L00EE
         lda   #79
         decb  
L00EE    std   <V.C80X,u
         lbra  L01CC

* $09 - cursor up
CurUp    ldb   <V.C80Y,u
         beq   L00FF
         decb  
         stb   <V.C80Y,u
         lbra  L01CC
L00FF    clrb  
         rts   

* $0D - move cursor to start of line (carriage return)
CrRtn    clr   <V.C80X,u
         bra   L014C

* ChrOut - output a readable character
* Entry: A = ASCII value of character to output
ChrOut   ora   <V.Invers,u	add inverse video flag
         pshs  a
         ldd   <CURSPTR,u
         anda  #$07
         tfr   d,x
         puls  a
         bsr   VRAMWrite
         ldx   #BASEADDR

* $06 - cursor right
CurRgt   inc   <V.C80X,u
         lda   <V.C80X,u
         cmpa  #79
         ble   L014C
         bsr   CrRtn

* $0A - cursor down (line feed)
CurDown  
         ldb   <V.C80Y,u
         cmpb  #23
         bge   L012E
         incb  
         stb   <V.C80Y,u
         bra   L014F
         
L012E    
         ldd   <DISPPTR,u
         addd  #80
         anda   #$07
         std   <DISPPTR,u
         addd  #80*23
         anda   #$07 
         tfr   d,x
         ldy   #80
         bsr   L0159            clear last line
         lda   #12
         sta   ,x
         ldd   <DISPPTR,u
         sta   $01,x
         lda   #13
         std   ,x               update display start         
L014C    ldb   <V.C80Y,u
L014F    lbra  L01CC

VRAMWrite
         pshs  cc,b
         ldb   #VRAM
         orcc  #$50         disable interrupt
         stb   BASEADDR+2
         sta   ,x+
         clr   BASEADDR+2
         puls  cc,b,pc   

VRAMRead
         pshs  cc,b
         ldb   #VRAM
         orcc  #$50         disable interrupt
         stb   BASEADDR+2
         lda   ,x+
         clr   BASEADDR+2
         puls  cc,b,pc     

* $01 - home cursor
CurHome  clr   <V.C80X,u
         clr   <V.C80Y,u
         ldd   <DISPPTR,u
         std   <CURSPTR,u
         lbra  L01DC

* $03 - erase line
ErLine   lbsr  CrRtn		do a CR
ErEOL    

         ldb   #80
         subb  <V.C80X,u
         clra
         tfr   d,y
         bsr   L0157
         rts

* $0C - clear screen
ClrScrn  bsr   CurHome		do home cursor, then erase to EOS

* $0B - erase to end of screen
ErEOS    ldb   <V.C80Y,u
         lda   #80
         mul
         addb  <V.C80X,u
         adca  #$00
         pshs  a,b          save relative address
         ldd   #80*24
         subd  ,s++         subtract relative address
         tfr   d,y
L0157
         ldd   <CURSPTR,u
         anda  #$07
         tfr   d,x

L0159    
         lda   #32
         ora   <V.Invers,u
ErOUT    
         pshs  a
         lbsr  VRAMWrite
         tfr   x,d
         anda  #$07
         tfr   d,x
         puls  a
         leay  -1,y          
         bne   ErOUT
         ldx   #BASEADDR
L0189    
L018E    
L01A0    clrb  
         rts   

* $02 XX YY - move cursor to col XX-32, row YY-32
CurXY    leax  >L01B0,pcr
         ldb   #$02
L01A8    stx   <V.RTAdd,u
         stb   <V.NGChr,u
         clrb  
         rts   
L01B0    ldx   #BASEADDR	get HW address
         ldb   <V.NChr2,u	get char2 in A
         lda   <V.NChar,u	and char1 in B
         suba  #32		    subtract 32 from B
         blt   L01A0		if less than 0, we're done
         cmpa  #79		    compare against greatest column
         bgt   L01A0		branch if >79
         subb  #32		    else subtract 32 from A
         blt   L01A0		if less than 0, we're done
         cmpb  #24		    compare against greatest row
         bgt   L01A0		branch if >24
         std   <V.C80X,u	else store A/B in new col/row position
L01CC    lda   #80		    multiply B*80 to find new row
         mul   
         addb  <V.C80X,u
         adca  #$00
         addd  <DISPPTR,u
         anda  #$3F
         std   <CURSPTR,u
L01DC    pshs  b,a
         lda   #14		Cursor Position (MSB)
         sta   ,x
         lda   ,s+
         sta   $01,x
         lda   #15		Cursor Position (LSB)
         sta   ,x
         lda   ,s+
         sta   $01,x
         clrb  
         rts   

Check1F  cmpa  #$1F
         bne   Done1B   sould it be WritErr ?
         lda   <V.NChr2,u
         cmpa  #$20
         beq   InvOn
         cmpa  #$21
         beq   InvOff
WritErr  comb  
         ldb   #E$Write
         rts   

InvOn    lda   #$80
         sta   <V.Invers,u
         clrb  
         rts   

InvOff   clr   <V.Invers,u
L020F    clrb  
         rts   

* $05 XX - set cursor off/on/color per XX-32
CurOnOff leax  >L0219,pcr
         ldb   #$01
         bra   L01A8
L0219    ldx   #BASEADDR
         lda   <V.NChr2,u	get next character
         cmpa  #$20		cursor code valid?
         blt   WritErr		no, error
         beq   L022D
         cmpa  #$2A		color code in range?
         bgt   L020F		no, ignore
CurOn    lda   #$60		cursor on (all colors=on)
         bra   L022F
L022D    lda   #$20		cursor off
L022F    ldb   #10		
         stb   ,x
         sta   $01,x
         clrb  
         rts   
* FHL O-PAK compatibility. Needed to run DynaStar 3.0
Check1B  cmpa  #$1B
         bne   Check1F
         ldb   #$01
         stb   <V.NGChr,u
         leax  <Do1B,pcr
         stx   <V.RTAdd,u
Done1B   clrb
         rts

Do1B     ldx   #BASEADDR           get HW addr in X
         lda   <V.NChr2,u
         cmpa  #$41
         lbeq  ErEOL
         cmpa  #$42
         lbeq  ErEOS
         cmpa  #$45
         beq   InsLine
         cmpa  #$46
         beq   DelLine
         cmpa  #$47
         lbeq  MoveRight
         cmpa  #$48
         lbeq  MoveLeft
         clrb
         rts
         
InsLine
         ldb   #22
L3000    pshs  b
         lda   #80
         mul
         addd  <DISPPTR,u
         anda  #$07
         tfr   d,x

         ldb   #80
L3001    lbsr  VRAMRead
         bsr   L3003
         sta   ,-s
         decb
         bne   L3001
         
         ldb   #79
L3002    
         lda   b,s
         lbsr  VRAMWrite
         bsr   L3003
         decb
         bpl   L3002
         
         leas  80,s         
         puls  b
         decb
         cmpb  <V.C80Y,u
         bpl   L3000
         
         leax  -160,x
         ldy   #80
         lbra  L0159            clear cursor line
         
L3003
          pshs  a,b
          tfr   x,d
          anda  #$07
          tfr   d,x
          puls  a,b,pc

DelLine  
         ldb   <V.C80Y,u
         incb
L4000    pshs  b
         lda   #80
         mul
         addd  <DISPPTR,u
         anda  #$07
         tfr   d,x
         ldb   #80
         
L4001    lbsr VRAMRead
         lbsr L3003
         sta   ,-s
         decb
         bne   L4001

         leax  -160,x         
         ldb   #79
         
L4002     
         lda   b,s
         lbsr  VRAMWrite
         bsr   L3003
         decb
         bpl   L4002
         
         leas  80,s         
         puls  b
         incb
         cmpb  #24
         bne   L4000
         
         ldy   #80
         lbra  L0159               clear last line

MoveRight
         ldb   <V.C80Y,u
         lda   #80
         mul
         addd  <DISPPTR,u
         anda  #$07
         tfr   d,x
         ldb   #72
         
L5001    lbsr  VRAMRead
         lbsr  L3003
         sta   ,-s
         decb
         bne   L5001

         leax  -72,x         
         ldb   #8
         lda   #32
         ora   <V.Invers,u
L5002    lbsr  VRAMWrite
         lbsr  L3003
         decb
         bne   L5002

         ldb   #71
L5003    
         lda   b,s
         lbsr  VRAMWrite
         lbsr  L3003
         decb
         bpl   L5003
        
         leas  72,s         
         clrb
         rts


MoveLeft
         ldb   <V.C80Y,u
         lda   #80
         mul
         addd  <DISPPTR,u
         addd  #8
         anda  #$07
         tfr   d,x
         ldb   #72
         
L6001    lbsr  VRAMRead
         lbsr  L3003
         sta   ,-s
         decb
         bne   L6001

         leax  -80,x

         ldb   #71
L6003    
         lda   b,s
         lbsr  VRAMWrite
         lbsr  L3003
         decb
         bpl   L6003

         leas  72,s         
         
         ldb   #8
         lda   #32
         ora   <V.Invers,u
L6002    lbsr  VRAMWrite
         lbsr  L3003
         decb
         bne   L6002
         clrb  
         rts

         emod
eom      equ   *
         end
