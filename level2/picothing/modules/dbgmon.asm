********************************************************************
* dbgmon - Debug monitor routines for Pico-Thing
*
* Resides at $FC00-$FDFF in the kernel page (always mapped).
* Callable from anywhere via JSR to fixed entry points.
*
* Entry points (jump table):
*   $FC00  PrintChar  - print character in A
*   $FC03  Print2Hex  - print byte in A as 2 hex digits
*   $FC06  Print4Hex  - print D (A=hi, B=lo) as 4 hex digits
*   $FC09  PrintStr   - print null-terminated string at X
*   $FC0C  PrintCR    - print CR+LF
*   $FC0F  PrintRegs  - dump registers to ACIA
*   $FC12  IllegalOp  - 6309 illegal opcode trap handler (does not return)
*
* All routines preserve all registers unless noted.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2025       Initial version

                    org       $FC00

                    use       picothing.d

********************************************************************
* Jump table - fixed entry points
*
JT.PChr             jmp       PrintChar
JT.P2Hx             jmp       Print2Hex
JT.P4Hx             jmp       Print4Hex
JT.PStr             jmp       PrintStr
JT.PCR              jmp       PrintCR
JT.PReg             jmp       PrintRegs
JT.IlOp             jmp       IllegalOp

********************************************************************
* PrintChar - print character in A to ACIA
*
* Entry: A = character to print
* Exit:  all registers preserved
*
PrintChar           pshs      cc,a
PChr.Wait           lda       >ACIA.Ctrl read ACIA status
                    bita      #$02      TDRE set?
                    beq       PChr.Wait no, wait
                    lda       1,s       reload original A from stack
                    sta       >ACIA.Data send character
                    puls      cc,a,pc   restore CC and A and return

********************************************************************
* Print2Hex - print byte in A as 2 hex digits
*
* Entry: A = byte to print
* Exit:  all registers preserved
*
Print2Hex           pshs      cc,a
                    lsra                high nybble first
                    lsra
                    lsra
                    lsra
                    bsr       PNybble   print high nybble
                    lda       1,s       reload original A
                    bsr       PNybble   print low nybble
                    puls      cc,a,pc   restore CC and A and return

PNybble             anda      #$0F
                    adda      #'0
                    cmpa      #'9
                    bls       PNyb.Go
                    adda      #7        adjust for A-F
PNyb.Go             bra       PrintChar

********************************************************************
* Print4Hex - print 16-bit value in D as 4 hex digits
*
* Entry: D = 16-bit value (A=high byte, B=low byte)
* Exit:  all registers preserved
*
Print4Hex           pshs      cc,d
                    bsr       Print2Hex print high byte in A
                    tfr       b,a
                    bsr       Print2Hex print low byte (was in B)
                    puls      cc,d,pc   restore CC, D, and return

********************************************************************
* PrintStr - print null-terminated string
*
* Entry: X = pointer to null-terminated string
* Exit:  all registers preserved
*
PrintStr            pshs      cc,a,x
PStr.Loop           lda       ,x+
                    beq       PStr.Done
                    bsr       PrintChar
                    bra       PStr.Loop
PStr.Done           puls      cc,a,x,pc

********************************************************************
* PrintCR - print CR+LF
*
* Exit:  all registers preserved
*
PrintCR             pshs      cc,a
                    lda       #$0D
                    bsr       PrintChar
                    lda       #$0A
                    bsr       PrintChar
                    puls      cc,a,pc

********************************************************************
* PrintRegs - dump all registers to ACIA
*
* Prints: CC=xx A=xx B=xx DP=xx X=xxxx Y=xxxx U=xxxx S=xxxx\r\n
*
* The caller's registers are captured on entry via pshs.
* S printed is the value BEFORE the pshs (adjusted).
*
PrintRegs           pshs      cc,a,b,dp,x,y,u save all registers
* stack frame: 0=CC 1=A 2=B 3=DP 4-5=X 6-7=Y 8-9=U (10 bytes)
                    leax      str.CC,pcr
                    bsr       PrintStr
                    lda       0,s       CC
                    bsr       Print2Hex
                    leax      str.A,pcr
                    bsr       PrintStr
                    lda       1,s       A
                    bsr       Print2Hex
                    leax      str.B,pcr
                    bsr       PrintStr
                    lda       2,s       B
                    bsr       Print2Hex
                    leax      str.DP,pcr
                    bsr       PrintStr
                    lda       3,s       DP
                    bsr       Print2Hex
                    leax      str.X,pcr
                    bsr       PrintStr
                    lda       4,s       X high
                    ldb       5,s       X low
                    bsr       Print4Hex
                    leax      str.Y,pcr
                    bsr       PrintStr
                    lda       6,s       Y high
                    ldb       7,s       Y low
                    bsr       Print4Hex
                    leax      str.U,pcr
                    bsr       PrintStr
                    lda       8,s       U high
                    ldb       9,s       U low
                    bsr       Print4Hex
                    leax      str.S,pcr
                    bsr       PrintStr
                    tfr       s,d
                    addd      #10       adjust for pshs frame
                    bsr       Print4Hex
                    bsr       PrintCR
                    puls      cc,a,b,dp,x,y,u,pc

str.CC              fcn       "         CC="
str.A               fcn       "         A="
str.B               fcn       "         B="
str.DP              fcn       "         DP="
str.X               fcn       "         X="
str.Y               fcn       "         Y="
str.U               fcn       "         U="
str.S               fcn       "         S="

********************************************************************
* IllegalOp - 6309 illegal opcode / division-by-zero trap handler
*
* The 6309 vectors through $FFF0 on illegal opcode or /0.
* It pushes the entire register set (same as SWI):
*   S+0=CC S+1=A S+2=B S+3=DP S+4-5=X S+6-7=Y S+8-9=U S+10-11=PC
* PC points to the illegal opcode itself.
*
* Prints banner + all stacked registers + task register, then halts.
*
IllegalOp           orcc      #$50      mask interrupts
                    leax      str.ILL,pcr
                    lbsr      PrintStr
* print stacked PC (most useful info)
                    leax      str.PC,pcr
                    lbsr      PrintStr
                    lda       10,s      PC high
                    ldb       11,s      PC low
                    lbsr      Print4Hex
* dump stacked registers
                    leax      str.CC,pcr
                    lbsr      PrintStr
                    lda       0,s       CC
                    lbsr      Print2Hex
                    leax      str.A,pcr
                    lbsr      PrintStr
                    lda       1,s       A
                    lbsr      Print2Hex
                    leax      str.B,pcr
                    lbsr      PrintStr
                    lda       2,s       B
                    lbsr      Print2Hex
                    leax      str.DP,pcr
                    lbsr      PrintStr
                    lda       3,s       DP
                    lbsr      Print2Hex
                    leax      str.X,pcr
                    lbsr      PrintStr
                    lda       4,s       X high
                    ldb       5,s       X low
                    lbsr      Print4Hex
                    leax      str.Y,pcr
                    lbsr      PrintStr
                    lda       6,s       Y high
                    ldb       7,s       Y low
                    lbsr      Print4Hex
                    leax      str.U,pcr
                    lbsr      PrintStr
                    lda       8,s       U high
                    ldb       9,s       U low
                    lbsr      Print4Hex
                    leax      str.S,pcr
                    lbsr      PrintStr
                    tfr       s,d
                    addd      #12       adjust for exception frame
                    lbsr      Print4Hex
* print current task register
                    leax      str.TK,pcr
                    lbsr      PrintStr
                    lda       >DAT.Task read task register
                    lbsr      Print2Hex
                    lbsr      PrintCR
* halt forever
ILL.Halt            bra       ILL.Halt

str.ILL             fcn       "***      ILLEGAL OP"
str.PC              fcn       "         PC="
str.TK              fcn       "         TK="

                    fill      $FF,$FE00-* pad to end of region

                    end
