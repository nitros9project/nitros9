********************************************************************
* Basic09 - BASIC for OS-9
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
*
*  18      1982/10/13  Robert F. Doggett (Microware)
* "PROGRAM" literal changed to "Program"
* Formatted strings could exceed field size
* Formatted boolean output phrases reversed
*
*  18      1982/10/18  Robert F. Doggett (Microware)
* Assembly subroutine errors now recognized
*
*  18      1982/10/19  Robert F. Doggett (Microware)
* Mem directive fixed to take more than 32k
*
*  19      1982/11/02  Robert F. Doggett (Microware)
* Default USING field size 1 if unspecified
* Prevent death on out of range input
*
*  19      1982/11/16  Robert F. Doggett (Microware)
* Compiler var "CNTASS" initialized to fix random crash if T.CXAS inserted by mistake
* Mem comand made to request 1 less byte
*
*  20      1983/01/12  Robert F. Doggett (Microware)
* Changed string terminator from $FF to $00, allowing 8-bit data in string functions
*
*  20      1983/01/17  Microware
* General clean up
*
*  20      1983/01/19  Robert F. Doggett (Microware)
* Changed string terminator from $00 to $FF to maintain I-Code compatability
*
*  20      1983/01/21  Robert F. Doggett (Microware)
* Fixed problem in USING with Real Zero
*
*  20      1983/01/24  Robert F. Doggett (Microware)
* Struct assignment of exactly 256 crashed
* Rename any Proc to number crashed system
*
*  20      1983/01/25  Robert F. Doggett (Microware)
* Startup now clears all DP Globals
* IOBuff could overflow into system stack
*
*  20      1983/02/07  Larry Crane (Microware)
* Kept Opstack from going crazy, killing system when exponentiation overflow occurred
*
*  20      1983/02/10  Robert F. Doggett (Microware)
* Added conditional asm for Tandy ^N
* Prevented DEBUG mode from recursive entry
*
*  20      1983/02/15  Robert F. Doggett (Microware)
* Made aborted RunB return error to Shell
*
*  20      1983/02/17  Robert F. Doggett (Microware)
* Added Microware to copyright notice
* CTL-Q was ignored in asm subroutines
* RunB ON ERROR now intercepts CTL-C, CTL-Q
*
*  21      1983/03/16  Robert F. Doggett (Microware)
* Fixed bug in TRON caused in edition 20
*
*  22      1983/04/27  Robert F. Doggett (Microware)
* Added conditionals for Basic09 minus trig
*
*  22      1983/05/26  MGH (Microware)
* Changed message printed on tandy version
*
*  22      1983/06/28  MGH (Microware)
* Added conditionals for dragon startup msg
*
*  22      2002/10/09  Boisy G. Pitre
* Obtained from Curtis Boyle, marked V1.1.0.
*
*  V1.21   1994/06/17  NitrOS-9 Project
* Changed intercept routine @ INTCPT: Replaced LSL <SigFlag/COMA/
*            ROR <SigFlag/RTI with OIM #$80,<SigFlag/RTI/NOP/NOP
* Changed routine @ start:
*               FROM                TO
*          4   LEAU >$100,u    4   LDW #$100
*          1   CLRA            2   CLR ,-s
*          1   CLRB            3   TFM s,u+
*          2   STD  ,--u       2   LEAS 1,s
*          3   CMPU ,s         1   NOP
*          2   BHI  START0      1   NOP
* Bytes:  15                  15
* Changed CLRA/LDB #$01 to LDD #$0001 @ end of start
*
*  V1.21   1994/06/22  NitrOS-9 Project
* Changed ResetTmpBuf (reset temp buffer to empty state) to use PSHS D
* LDA #1 / STA <TmpBufCount / LDD <TmpBufBase / STD <TmpBufCur / PULS PC,D
*            (saves 5 cycles) ALSO WORKS AS 6809 MOD
* Changed BEQ L08E3 to BEQ ReadLine @ RUNCMD (Std in for commands)
* Changed numerous CLRA/CLRB and COMA/COMB to CLRD & COMD respectiv
*            just to shorten source
*
*  V1.21   1994/06/27  NitrOS-9 Project
* Added 2nd TFM to init routine to clear out $400-$4ff
*
*  V1.21   1994/06/28  NitrOS-9 Project
* Changed BRA OUTCHR99 @ OUTCHR to PULS PC,U,A (6809 TOO)
*
*  V1.21   1994/12/22  NitrOS-9 Project
* BIG TEST: TOOK OUT NOP'D CODE - SEE IF IT STILL WORKS
* IT DOESN'T - MOVED ALL NOPS TO JUST BEFORE ICPT ROUTINE TO
*            SEE IF THE SEPARATION OF CODE & DATA MAKES A DIFFERENCE
* THIS APPEARS TO WORK...THEREFORE, SOME REFERENCES TO THE DATA
*            AT THE BEGINNING OF BASIC09 IS STILL BEING REFERRED TO BY OFFSETS
*            IN THE CODE, THAT HAVE NOT BEEN FIXED UP YET.
*
*  V1.21   1994/12/23  NitrOS-9 Project
* AFTER FIXING L03F0 TABLE, ATTEMPTED TO REMOVE 'TEST'
*
*  V1.21   1994/12/28  NitrOS-9 Project
* Worked, changed 16 bit,pc's to 8 bit,pc's @:
*            PrepInterp  leax INTRTS,pc  *
*            PrintAltRem  leax AltRemStr,pc  *
*            EditPrompt  leax EditCmdLoop,pc  *
*            ScanTokenAlt1  leax ScanTable1,pc  *  (Doesn't seem to be referenced)
*            SYSSUB  leax ShellName,pc  *
*            SizeFnc  leax VarSizeTable3,pc  *
*            Log10Fnc  leax Log10Const,pc  *
*            CNOR20  leax Ln2Const,pc  *
*            CopyPiToStack  leau PiConst,pc  *
*            TrigSetupArg  leau DegConst,pc  *
*            NXTFM3  leax PuFmtTblInt,pc  *
*
*  V1.21   1995/01/03  NitrOS-9 Project
* Changed a ChgDir @ CHDSTM to do it in READ mode, not UPDATE
*
*  V1.21   1995/01/04  NitrOS-9 Project
* Changed FinalizePackMod - 3 CLR ,Y+ to LEAY 3,Y
*            Changed LEAU ,Y / STD ,--U / STA ,-U to LEAU -3,y/STD ,u/
*              STD 2,u
* Changed LDA #$02 / LDB #SS.Size to LDD #$02*256+SS.Size @ OPNCH0
*              (create output file)
* Replaced BEQ L2D17 @ CompileStrExprB with BEQ POPE30, removed L2D17 altog-
*            ether, change LBSR ERIET @ CompileStrExprB with LBRA ERIET
*
*  V1.21   1995/01/09  NitrOS-9 Project
* Attempted to change both CLRA/CLRB (CLRD)'s @ DIRLN1 to CLRA for
*            F$Load/F$Link (since neither require B)
* Changed DEFILE frm LBSR AppendCrReturn to LBSR AppendCR
* Changed AppendCrReturn from LDA #C$CR/LBRA AppendChar to LBRA AppendCR
*
*  V1.21   1995/01/12  NitrOS-9 Project
* Attempted to remove LDD <U002F / ADDD $F,x @ UnbindSetupMod, move TFR
*            D,Y to earlier in code when [CurModPtr]+($F,x) is calculated
*
*  V1.21   1995/01/17  NitrOS-9 Project
* Removed useless CMPB #$00 @ DimParamLoop
* Moved CompileRts label to an earlier RTS, removed original (saves 1 by
* Removed useless CMPA #$00 @ CheckTokType
*
*  V1.21   1995/01/19  NitrOS-9 Project
* Changed STB <CmdType / STA <CmdToken to STD <CmdToken @ SaveCmdToken
* Changed LDA <CmdToken/CMPA <CmdToken to LDA <CmdToken/ORCC #Zero @ GetChanToken
*             (1 cycle faster)
* Changed NAMSY1: took out LEAY -1,y, added BRA FinishNameStr (saves 2 cycle
*             from original method)
*
*  V1.21   1995/01/20  NitrOS-9 Project
* Changed ChkEndMarker from to auto-inc Y, skip LEAY 1,Y entirely, & chang
*            LEAY 5,Y to LEAY 4,Y (+2 cyc if [,y]=$4F, but -3 cyc on any other
*            value)
* Changed LookupByTbl: changed CLRA / LDB D,X to to ABX / LDB ,X (3 cyc
*            faster on 6809/2 cyc faster on 6309)
* Mod @ PRSLF: Changed LBSR NAMSYM to LBSR CheckIdent (just did
*            SkipSpaceLF call, and 2nd call to it will return same Y anyways)
* Changed CLR ,Y+ to STB ,Y+ @ ADDSYM
* Attempted to move OutcodeHex routine to just before PRSHEX routine to
*            change LBRA OUTCOD to BRA OUTCOD. Changed SaveTokAndOut from LBRA SaveCmdToken to
*            STD <CmdToken / BRA OUTCOD
* Changed LBHS PBEXPR / BRA CheckListBound @ PDECL3 to BLO CheckListBound / LBRA PBEXPR
* Attempted Mod @ ExprSpecialTok - Changed LEAX B,X to ABX
*
*  V1.21   1995/01/23  NitrOS-9 Project
* Made following mods involving PushTypeOnStack routine:
*            Changed CMPA #0 to TSTA, reversed VrefSkipToken's LDA <VarTypeCode & LEAY 3,Y
*            so TSTA not needed, changed BRA PushTypeOnStack to BRA PushType @: PushIntLit,
*            PushRealLit, PSLIT, PADDR1. Changed BRA PushTypeOnStack to BRA SetMinType @ VrefSkipToken
* Changed LDA #1 to INCA @ PushTypeOnStack (since A=0 at this point)
* Took out CMPA #0, changed LDD #$0060 to LDB #$60 @ CheckOrDefVar
* Changed TST <VarTypeHi to LDA <VarTypeHi (saves 2 cyc) and following 4
*            lines @ CheckVarSubs to version on right (+1 byte, -5 cycles):
*            lda #5             ldd #$ffff
*            sta <VarTypeCode         std <RealTmpWord
*            ldd #$ffff         lda #5
*            bra CHKV90          sta <VarTypeCode
*              (std <RealTmpWord/     rts
*               lda <VarTypeCode/rts
*
*  V1.21   1995/01/31  NitrOS-9 Project
* Moved UnimplRtnErr to just before ERROR (eliminates LBRA)
*
*  V1.21   1995/02/03  NitrOS-9 Project
* Changed LBRA CallPRSLF @ ARRNA9 to LBRA PRSLF (saves extra LBRA, saves
*            5/4 cycles)
*
*  V1.21   1995/02/13  NitrOS-9 Project
* Moved JSR <JmpVect1 / FCB 8 from Vect1Fn8 to just after SUBFNC to change
*            LBSR to BSR
*
*  V1.21   1995/02/14  NitrOS-9 Project
* Moved 3 text strings that are only referred to once to their res-
*            pective routines in the code: CantFindStr to near SearchNoMatch, RangeStr to near
*            RangeErrMsg, and CalledByStr to PrintCallEntry
* Moved JSR <JmpVect2 / FCB 4 from Vect2Fn4 to after RUNC20 (called twice
*            from just before here)
* Attempted to move JSR <JmpVect2 / fcb 2 from Vect2Fn2 to just before
*            OpenAndLoad (change some LBSR's to BSR's)
* Moved Vect2Fn0 (JSR <JmpVect2 / fcb 0) to just before INTE30
* Moved Vect3Fn0 (JSR <JmpVect3 / fcb 0) to just before INTE30
*
*  V1.21   1995/02/15  NitrOS-9 Project
* Moved CallVect4Fn0 (JSR <JmpVect4 / fcb 0) to just after START15
* Moved Vect4Fn4 (JSR <JmpVect4 / fcb 0) to just after PrepInterp
* Moved Vect4Fn2 (JSR <JmpVect4 / fcb 2) to just after PrepInterp
* Moved Vect6Fn2 (JSR <JmpVect6 / fcb 2) to just after CopyFcsLoop
* Moved Vect2FnA (JSR <JmpVect2 / fcb A) to just before CompileOneLine
* Moved Vect2Fn6 (JSR <JmpVect2 / fcb 6) to just after InsertAdjust
* Moved Vect3Fn2 (JSR <JmpVect2 / fcb 6) to just after DUMP
* Moved Vect3Fn6 (JSR <JmpVect3 / fcb 6) to just after ListLineDone
* Moved Vect3Fn4 (JSR <JmpVect3 / fcb 4) to just after PrintFromBuf
* REMARKED OUT L0131 JSR VECTOR - NOT CALLED IN BASIC09
* Moved Vect4FnC (JSR <JmpVect4 / fcb C) to just after DebugCmdLoop
* Moved Vect4Fn8 (JSR <JmpVect4 / fcb 8) to just after PrintFromBuf
* Moved Vect6Fn0 (JSR <JmpVect6 / fcb 0) to just after EvalNumDone
* Moved Vect1Fn2 (JSR <JmpVect1 / fcb 2) to just after L1E1C
* Moved Vect1Fn4 (JSR <JmpVect1 / fcb 4) to just after PRTLIN
* Moved Vect1Fn6 (JSR <JmpVect1 / fcb 6) to replace LBRA Vect1Fn6 @ L1E1C
*            & embedded JSR <JmpVect1/fcb 4 @ ICodeOverflow since LBRA, not LBSR
* Moved Vect6Fn0b (JSR <JmpVect6 / fcb 0) to just after PRSHEX
* Moved Vect1Fn12 (JSR <JmpVect1 / fcb $12) to just after ERMRP9
* Took out 2nd TST <LastSignal / BNE MoveCmdCleanup @ CheckCRAtCmd
* Eliminated L2572 since duplicate of Vect1Fn2, & not speed crucial
* Eliminated L2575 since duplicate of Vect1Fn6, changed LBRA L2575 @
*            PBEXPR to LBRA Vect1Fn6
*
*  V1.21   1995/02/16  NitrOS-9 Project
* Moved Vect1Fn14 (JSR <JmpVect1 / fcb $14) to end of SetLineEndB (replacing
*            LBRA to it)
* Moved Vect2Fn8 (JSR <JmpVect2 / fcb 8) to end of AlcDescr4Bytes
* Moved Vect2Fn6b (JSR <JmpVect2 / fcb 6) to end of DONE50
* Eliminated L3206 since duplicate of Vect1Fn6, changed 3 LBRA calls
*            to it to go to Vect1Fn6 instead (saves 3 bytes)
* Moved Vect1FnC to just after table @ StmtJmpBase, changed table entry from
*            L35F0 to Vect1FnC, eliminated L35F0 LBRA entirely
* Moved SYSSTM (JSR <JmpVect1 / fcb $E) to end of CHNSTM
*
*  V1.21   1995/02/24  NitrOS-9 Project
* Eliminated L320F since dupe of Vect1Fn2, change appropriate LBSR's @
*            EXCER4 & DEBUG
* Moved Vect1Fn0 (JSR <JmpVect1 / fcb 0) to end of TogTraceDone
*
*  V1.21   1995/02/27  NitrOS-9 Project
* Moved Vect1FnA (JSR <JmpVect1 / fcb $A) to end of EvalAndFn0A
* Moved Vect1Fn10 (JSR <JmpVect1 / fcb $10) to end of BASSTM
* Took out L321B (JSR <JmpVect2/fcb 6), replaced LBRA to it @ POKSTM
*            with JSR/fcb
* Moved L321E (JSR <JmpVect5/fcb 4) to end of NXTRL1
* Moved L3221 (JSR <JmpVect5/fcb $A) to end of NXTRLA
* Moved CallJmpVect5Fn2 (JSR <JmpVect5/fcb 2) to before CopyVarEntry, and moved 2 lines
*            from CallVect5ThenLet to here too)
* Moved ASGSTM (JSR <JmpVect5/fcb $C) to after RddatIntFx
* Moved CallJmpVect5FnE (JSR <JmpVect5/fcb $E) to after RddatIntFx
* Moved CallJmpVect5Fn0 (JSR <JmpVect5/fcb 0) to after InitJmpTables
* Moved CallJmpVect6Fn2 (JSR <JmpVect6/fcb 2), even though dupe of Vect6Fn2, to
*            after ASGVAR
*
*  V1.21   1995/02/28  NitrOS-9 Project
* Embedded Vect1Fn18 (JSR <JmpVect1/fcb $18) @ PrintThenFn18 & DEBUG, changed LBSR
*            @ STMLUP to point to PrintThenFn18 version
* Moved Vect1Fn16 (JSR <JmpVect1/fcb $16) to after StmtLoopEntry
* L3239 (JSR <JmpVect1/fcb $1A) is NEVER CALLED IN BASIC09.
*            Removed L3239 entirely
* Embedded L323C (JSR <JmpVect1/fcb $1C) @ FORSTM since LBRA
* Changed LDB #0 @ PrintFlushBuf to CLRB
* Embedded ReportMathErr (JSR <JmpVect4/fcb 6 (error handler)) @ VarrDimCalc,CMPTRU,
*            IntDivNonZero,StrStkOverflow,FixRangeErr,FPOVRF,IllegalArgErr) Moved it to just after RealMulEntry.
* Changed LDB #0 @ BoolFalse to CLRB (part of Boolean routines)
* Changed LDB #0 @ EofFalse to CLRB
* Removed L3C2F (dupe of Vect6Fn2), changed LBSR's @ ValFnc & STRF10 to
*            it
* Moved Vect1Fn1A to after INIT1 (shorten LEAX)
*
*  V1.21   1995/03/01  NitrOS-9 Project
* Modified Integer Multiply to use MULD @ INML25
*
*  V1.21   1995/03/10  NitrOS-9 Project
* Modified Negate of REAL #'s to use EIM @ NEGRL (saves 4 cyc)
* Changed RaCopyTmpOrig (Real add with dest var=0) to use LDQ/STQ (saves
*            6 cyc)
*
*  V1.21   1995/03/13  NitrOS-9 Project
* Changed NEGA/NEGB/SBCA #0 to NEGD @ FLOAT1 & FIX4A
* Changed BPL L451E to BPL FloatExpPos @ FLOAT1 (eliminates 2nd useless
*            TSTA)
*
*  V1.21   1995/03/15  NitrOS-9 Project
* Changed LDB $B,y/ANDB #$FE/STB $B,y & LDB 5,y/ANDB #$FE/STB $B,y
*            to AIM's @ RaSetSignBits (Real Add & Subtract)
* Changed ADCB 3,y/ADCA 2,y to ADCD 2,y @ RaAddMant (Real Add/Subtact)
* Changed SBCB 3,y/SBCA 2,y TO SBCD 2,y @ RaSubMant (Real Add/Subtact)
* Changed LDA 5,y/ANDA #$FE/STA 5,y to AIM #$FE,5,y @ ABSFNR (ABS
*            for real #'s
* Changed NEGA/NEGB/SBCA #0 to NEGD @ AbsInt (ABS for Integers)
* Ditched special checks for 0 or 2 in Integer Multiply (INMUL),
*            since overhead from checks is as slow or slower as straight MULD
*            except in dest. var=0's case
*
*  V1.21   1995/03/16  NitrOS-9 Project
* Changed 2 LDD/STD's @ CopyRealToTemp to LDQ/STQ
*
*  V1.21   1995/03/18  NitrOS-9 Project
* Changed Integer Divide (and MOD) routines to use DIVQ
*
*  V1.21   1995/03/20  NitrOS-9 Project
* Changed CopyRealConst (copy Real # to temp var from inc'd X) to use
*            LDQ/STQ/LDB #4/ABX
* Moved Integer MOD routine (INDV10) to nearer divide (changes LBSR
*            to BSR)
*
*  V1.21   1995/04/23  NitrOS-9 Project
* Changed Real Add/Subtract mantissa shift (RaShiftMant-RaShiftDone) to use
*            <RealShiftCnt (unused in BASIC09) to hold shift count instead of stack
*            (saves 2 cyc for STA vs. PSHS, saves 1 cyc per DEC, & saves 5 cyc
*            by eliminating LEAS 1,s) (6809)
*
*  V1.21   1995/04/26  NitrOS-9 Project
* Split real add/subtract out & made two versions: 6809 & 6309
*
*  V1.21   1995/06/09  NitrOS-9 Project
* Modified 6309 REAL add/subtract routine - now 13-15% faster
*
*  V1.21   1995/06/20  NitrOS-9 Project
* Took out useless LDB 2,s @ RmulProd2 (Real Multiply)
*
*  V1.21   1995/07/18  NitrOS-9 Project
* Changed sign fix in Real Add @ RaSaveResult to use TFR w,d/lsrb/lslb/orb
*            ,y/std $a,y
* Split real multiply out & made two versions: 6809 & 6309
*
*  V1.21   1995/08/11  NitrOS-9 Project
* Removed useless LEAS 1,s in Init routine
* Split real divide out & made two versions: 6809 & 6309
*
*  V1.21   1995/08/15  NitrOS-9 Project
* Removed useless: STA <ActivePath in start, useless CLR <LastSignal @ START05,
*            Changed LDD #1 to LDB #1/STD <StdinPath to STB <StdoutPath in start, and
*            START05/START15 routine to use W instead of stack for base address
* Changed 'bye <CR>' buffer fill @ ReadLine to use LDQ/STQ
*
*  V1.21   1995/11/12  NitrOS-9 Project
* Changed NXTIN1 to use INCD instead of ADDD #1 (NEXT Integer STEP 1
* Changed NXTINT to TFR A,E instead of PSHS A, changed TST ,S+ to
*            TSTE (NEXT Integer STEP <>1)
*
*  V1.21   1995/11/16  NitrOS-9 Project
* Changed to L345E (REAL NEXT STEP 1) to do direct call to REAL add
*            routine (changed BSR L321E/BSR FORSTM to LBSR RealAdd)
* As per above, changed same call @ NXTRL (REAL NEXT STEP <>1), and
*            eliminated L321E completely
* @ NXTRL1 & NXTRL2, eliminated L3221 calls, replaced BSR L3221's
*            with LBSR RLCMP (Real Compare) (in REAL NEXT, both cases)
*
*  V1.21   1995/11/25  NitrOS-9 Project
* Remove L50A1 & L509E (calls to REAL Multiply & REAL divide),
*            changed CNVOPR to call them directly (prints exponents?)
*
*  V1.21   1995/11/30  NitrOS-9 Project
* Changed RUNS30 to use SUBR (saves 1 byte/9 cyc on RUN (mlsub)
*
*  V1.21   1995/12/05  NitrOS-9 Project
* Changed SkipRemText (called by REM) to use ABX instead of CLRA/LEAX D,X
*            (used to jump ahead in I-Code to skip remark text)
* Attempted to just move NextJmpTbl (NEXT) & ForJmpTbl (FOR) Tables to just
*            after ForRlNxStepAlt for 8 bit offsets - also removed LSLB @ NextGetJmpOff
*
*  V1.21   1995/02/12  NitrOS-9 Project
* Changed routines around BADNUM to skip ORCC if not necessary (blo&
*            bcs)
* Changed LEAX to 8 bit from 16 @ CIRCOR
*
*  V1.21   2014/06/07  RG (NitrOS-9 Project)
* Changed Date$ to conform with Y2K changes in F$Time
*
* Annotated by /annotate-asm (Claude Code) 2026-05-15:
*   - Renamed disassembled labels (L/u prefix) to meaningful names
*   - Applied to basic09.real.add/mul/div.{63,68}.asm include files
********************************

* BASIC09 - Copyright (C) 1980 by Microware & Motorola
***********
* Basic09 & RunB programs have extended memory module headers. Layout is as
*  follows:
*   Offset  | Name       | Purpose
*   --------+------------+----------
*   $0000   |  M$ID      | Module sync bytes ($87CD)
*   $0002   |  M$Size    | Size of module
*   $0004   |  M$Name    | Offset to module name
*   $0006   |  M$Type    | Type/Language ($22 for RUNB modules)
*   $0007   |  M$Revs    | Attributes/Revision level
*   $0008   |  M$Parity  | Header parity check
*   $0009   |  M$Exec    | Execution offset (start of tokenized RUNB code)
*   $000B   |  ???       | Data area size required
*   $000D   |  ???       | ???
*   $0017   |  ???       | Flags:
*           |            |   x0000000 - 1=Packed, 0=Not packed
*           |            |   0x000000 - ??? but 1 when CRC has just been made
*           |            |   0000000x - 1=Line with compiler error
*           |            |              0=No lines with compiler errors
*   $0018   |  ???       | Size of module name

* Version Numbers
B09Vrsn             equ       1
B09Major            equ       1
B09Minor            equ       0

                    nam       Basic09
                    ttl       BASIC for OS-9

                    ifp1
                    use       defsfile
                    endc

                    mod       eom,name,Prgrm+Objct,ReEnt+0,start,size

DpBase              rmb       2                   Start of data memory / DP pointer
DataAreaSz               rmb       2                   Size of Data area (including DP)
ModListPtr               rmb       2                   Ptr to list of Modules in BASIC09 workspace ($400)
Unused06               rmb       1                   ??? NEVER REFERENCED (possibly leftover from RUNB)
Unused07               rmb       1                   ??? NEVER REFERENCED
ICodeBase               rmb       2                   Ptr to start of I-code workspace
ICodeUsed               rmb       2                   # bytes used by all programs for code in user workspace
* Data area sizes are taken from module headers Permanent storage size ($B-$C)
WorkspaceFree               rmb       2                   Bytes free in BASIC09 workspace for user
JmpTblPtr               rmb       2                   Ptr to jump table (StmtJmpBase only) - Only used from EvalDispatch
JmpTbl1               rmb       2                   Inited to VarCopyBase (jump table)
JmpTbl2               rmb       2                   Inited to ExprJmpBase (jump table)
RealShiftCnt               rmb       1                   ??? NEVER REFERENCED
Unused15               rmb       1                   ??? NEVER REFERENCED
JmpOpcode               rmb       1                   JMP ($7e) instruction
JmpTarget               rmb       2                   Address for above (inited to EVAL)
EvalSetup               rmb       2                   Inited to Vect1Fn1A (JSR <JmpVect1 / FCB $1A)
* The following vectors all contain a JMP >$xxxx set up from the module header
JmpVect1               rmb       3                   Jump vector #1  (Inited to VectDispatch)
JmpVect2               rmb       3                   Jump vector #2  (Inited to Vect2Dispatch)
JmpVect3               rmb       3                   Jump vector #3  (Inited to PLREF)
JmpVect4               rmb       3                   Jump vector #4  (Inited to Vect4Dispatch)
JmpVect5               rmb       3                   Jump vector #5  (Inited to Vect5Dispatch)
JmpVect6               rmb       3                   Jump vector #6  (Inited to Vect6Dispatch)
StdinPath               rmb       1                   Standard Input path # (Inited to 0)
StdoutPath               rmb       1                   Standard Output path # (inited to 1)
CurModPtr               rmb       2                   Ptr to start of 'current' module in BASIC09 workspace
VarStorePtr               rmb       2                   Ptr to start of variable storage
UnusedByte33               rmb       1
SigFlag               rmb       1                   Flag: if high bit set, signal has been receieved
LastSignal               rmb       1                   Last signal received
ErrCode               rmb       1                   Error code
UnusedWord37               rmb       2
StrWorkPtr               rmb       1
UnusedByte3A               rmb       1
FldAddrFlag               rmb       1
ParmPktOff               rmb       1
UnusedByte3D               rmb       1
MaxStrSize               rmb       1
UnusedByte3F               rmb       1
ParmEndPtr               rmb       2
ArrayBase               rmb       1
ParmPktCnt               rmb       1
* Next 2 are variable ptrs of some sort, temporary? Permanent?
StrSpaceTop               rmb       2                   Inited to $300 (some table that is built backwards)
SubrStkPtr               rmb       2                   Inited to $300
StrStkPtr               rmb       1
UnusedByte49               rmb       1
ICodeEndPtr               rmb       2                   Ptr to end of currently used I-code workspace+1
RndTmpH               rmb       1
RndTmpL               rmb       1
RndCalcL               rmb       2
RndSeedH               rmb       1                   Inited to $0e
RndSeedH1               rmb       1                   Inited to $12
RndSeedL               rmb       1                   Inited to $14
RndSeedL1               rmb       1                   Inited to $A2
RndMultB0               rmb       1                   Inited to $BB
RndMultB1               rmb       1                   Inited to $40
RndMultB2               rmb       1                   Inited to $E6
RndMultB3               rmb       1                   Inited to $2D
RndIncrH               rmb       1                   Inited to $36
RndIncrL               rmb       1                   Inited to $19
RndAddend               rmb       2                   Inited to $62E9
ICodeCurPtr               rmb       2
ModExecAddr               rmb       2                   Absolute exec address of basic09 module in memory
ModFOff               rmb       2                   Absolute address of $F offset in basic09 mod in mem
ModSymTbl               rmb       2                   Absolute address of $D offset in basic09 mod in mem
ModSzData               rmb       2                   ??? Size of module-$D,x in mod hdr + 3
SymTblSize               rmb       1
UnusedByte67               rmb       1
StorageOff               rmb       1
UnusedByte69               rmb       1
UnusedByte6A               rmb       1
UnusedByte6B               rmb       1
UnusedByte6C               rmb       1
TrigTemp               rmb       1
SqrtCycleCount               rmb       1
UnusedByte6F               rmb       1
UnusedWord70               rmb       2
UnusedWord72               rmb       2
IndentDepth               rmb       1
TmpReal0               rmb       1
TmpReal1               rmb       1
TmpReal2               rmb       1
TmpReal3               rmb       1
TmpReal4               rmb       1
TmpReal5               rmb       1
TmpReal6               rmb       1
TmpReal7               rmb       1
TmpBufCount               rmb       1                   Current # chars active in temp buffer ($100-$1ff)
UnusedByte7E               rmb       1
CurrChanPath               rmb       1
TmpBufBase               rmb       2                   Pointer to start of temp buffer ($100)
TmpBufCur               rmb       2                   Pointer to current position in temp buffer ($100-$1ff)
PackedFlag               rmb       1
* For PrintUsingSpec, the following applies:
* 0=Integer, 1=Hex, 2=Real, 3=Exponential, 4=String, 5=Boolean, 6=Tab,
* 7=Spaces, 8=Quoted text
PrintUsingSpec               rmb       1                   Specifier # for print using
FieldWidth               rmb       1
FieldJustify               rmb       1
FmtTotalFld               rmb       1
FracFieldSz               rmb       1
IntFieldSz               rmb       1
FracDigitCnt               rmb       1
FmtScanPtr               rmb       2
FmtEndPtr               rmb       2
RptBegPtr               rmb       1
UnusedByte91               rmb       1
RptCount               rmb       2
RptFlag               rmb       1
TrigPtr1               rmb       1
UnusedByte96               rmb       1
TrigPtr2               rmb       1
UnusedByte98               rmb       1
TrigIter               rmb       1
TrigNegFlag               rmb       1
TrigSign               rmb       1
TrigSign2               rmb       1
TrigOctant               rmb       1
CmdTablePtr               rmb       2                   Ptr to current command table (normally CmdTable)
BreakFlag               rmb       1                   ??? Flag of some sort?
UnusedWord_A1               rmb       2
CmdToken               rmb       1                   Token # from command table
CmdType               rmb       1                   Command type (flags?) from command table
NameStrType               rmb       1                   Flag type of name string (2=Non variable)
NameStrSz               rmb       1                   Size of current string/variable name (includes '$' on strings)
NameStrEnd               rmb       2                   Ptr to end of name string+1
ScratchPtr               rmb       2                   ??? Ptr of some sort
ICodeLineEnd               rmb       2                   Ptr to current line I-code end
ICodeLineSav               rmb       2                   ??? Dupe of above
ICodeLineSav2               rmb       2                   ??? duped from AB @ SetupCompile
ICodeScanFlag               rmb       2
DebugStepCnt               rmb       2                   # steps to do (debug mode from STEP command)
SavedLinePtr               rmb       2
ExitStkPtr               rmb       2
ErrHandlerPtr               rmb       1
UnusedByte_BA               rmb       1
LoadInitFlag               rmb       1                   ??? (inited to 0 at during load process)
CmplxAsgFlag               rmb       1
ActivePath               rmb       1                   (inited to 0) - Path # of newly opened path
ErrDupPath               rmb       1                   I$Dup path # for duplicate of error path
ScanMatchByte               rmb       2
CurVarSz               rmb       2
ProcSzAcc               rmb       2
ProcLinkAcc               rmb       1
UnusedByte_C6               rmb       1
CmdExecFlag               rmb       1
DataStmtBase               rmb       2
DataStmtCur               rmb       1
UnusedByte_CB               rmb       1
CompListPtr               rmb       1
UnusedByte_CD               rmb       1
VarTypeFlag               rmb       1
VarDefByte               rmb       1
VarTypeHi               rmb       1
VarTypeCode               rmb       1                   Some sort of variable type
SymbolPtr               rmb       2
RealTmpWord               rmb       2
VarByteSize               rmb       2                   Size of var in bytes (from VarTypeCode)
UnusedByte_D8               rmb       1
BinderMode               rmb       1                   Inited to 1
DescrAreaOff               rmb       1
UnusedByte_DB               rmb       1
RescanFlag               rmb       1
ItemSepChar               rmb       1
SavedChar               rmb       1
UnusedByte_DF               rmb       1
UnusedByte_E0               rmb       1
UnusedByte_E1               rmb       1
UnusedByte_E2               rmb       2
UnusedByte_E4               rmb       1
UnusedByte_E5               rmb       1
UnusedByte_E6               rmb       2
UnusedByte_E8               rmb       2
UnusedByte_EA               rmb       1
UnusedByte_EB               rmb       4
UnusedByte_EF               rmb       3
UnusedByte_F2               rmb       1
UnusedByte_F3               rmb       6
UnusedByte_F9               rmb       1
UnusedByte_FA               rmb       4
UnusedByte_FE               rmb       1
UnusedByte_FF               rmb       1
TmpBuf               rmb       $100                256 byte temporary buffer for various things
RevStackBuf               rmb       $100                ??? ($200-$2ff) built backwards 2 bytes/time
Stk300               rmb       $100                BASIC09 stack area ($300-$3ff)
ModPtrList               rmb       $100                List of module ptrs (modules in BASIC09 workspace)
ICodeRunBuf               rmb       $100                I-Code buffer (for running)
ProgramBuf               rmb       $2000-.             Default buffer for BASIC09 programs & data
size                equ       .

* Jump tables installed at $1b in DP: in form of JMP to (address of BASIC09's
* header in memory + 2 byte in table). In other words, jump to LXXXX
JmpVectTbl               fdb       VectDispatch               $1b jump vector
                    fdb       Vect2Dispatch               $1e jump vector
                    fdb       PLREF               $21 jump vector
                    fdb       Vect4Dispatch               $24 jump vector
                    fdb       Vect5Dispatch               $27 jump vector
                    fdb       Vect6Dispatch               $2A jump vector
                    fdb       $0000               End of jump vector table marker

name                fcs       /Basic09/

ModEdition               fdb       $1607               Edition #22 ($16)

* Intro screen

                    ifne      wildbits
IntroScreen               fcb       $0A
				else
IntroScreen               fcb       $0C
IntroText1               fcc       '            BASIC09'
                    fcb       $0A
                    ifne      H6309
                    fcc       '     6309 VERSION 0'
                    else
                    fcc       '     6809 VERSION 0'
                    endc
                    fcb       B09Vrsn+$30
                    fcc       '.0'
                    fcb       B09Major+$30
                    fcc       '.0'
                    fcb       B09Minor+$30
                    fcb       $0A
                    fcc       'COPYRIGHT 1980 BY MOTOROLA INC.'
                    fcb       $0A
                    fcc       '  AND MICROWARE SYSTEMS CORP.'
                    fcb       $0A
                    fcc       '   REPRODUCED UNDER LICENSE'
                    fcb       $0A
                    fcc       '       TO TANDY CORP.'
                    fcb       $0A
                    fcc       '    ALL RIGHTS RESERVED.'
				endc
                    fcb       $8A

* Jump vector @ $1B goes here
VectDispatch               pshs      x,d                 Preserve regs
                    ldb       [<$04,s]            Get function offset
                    leax      <VectOffTbl,pc           Point to vector table
                    ldd       b,x                 Get return offset
                    leax      d,x                 Point to return address
                    stx       $4,s                Change RTS address to it
                    puls      d,x,pc              restore regs and return to new address

* Vector offsets for above routine ($1B vector)

VectOffTbl               fdb       DIRLNK-VectOffTbl         Function 0
                    fdb       PrintSysErr-VectOffTbl         Function 2   Print error message (B=Error code)
                    fdb       SETEXT-VectOffTbl         Function 4
                    fdb       EXIT-VectOffTbl         Function 6
                    fdb       CompareSearch-VectOffTbl         Function 8
                    fdb       KILLEX-VectOffTbl         Function A
                    fdb       BYEBYE-VectOffTbl         Function C
                    fdb       KILALL-VectOffTbl         Function E
                    fdb       ScanTokenT2-VectOffTbl         Function 10
                    fdb       GetPktByte-VectOffTbl         Function 12
                    fdb       InsertICode-VectOffTbl         Function 14
                    fdb       PrintICodeLine-VectOffTbl         Function 16
                    fdb       EnterDebug-VectOffTbl         Function 18
                    fdb       CallEvalSetup-VectOffTbl         Function 1A (Pointed to by <EvalSetup & <JmpTarget)
                    fdb       PrintTraceInfo-VectOffTbl         Function 1C

* UNUSED IN BASIC09
*L0131    jsr   <JmpVect4
*         fcb   $0A

* token/command type & command list?
                    fdb       116                 # entries in table
                    fcb       2                   # bytes to start text

CmdTable               fdb       $0101
KwParam               fcs       'PARAM'
                    fdb       $0201
KwType               fcs       'TYPE'
                    fdb       $0301
KwDim               fcs       'DIM'
                    fdb       $0401
KwData               fcs       'DATA'
                    fdb       $0501
KwStop               fcs       'STOP'
                    fdb       $0601
KwBye               fcs       'BYE'
                    fdb       $0701
KwTron               fcs       'TRON'
                    fdb       $0801
KwTroff               fcs       'TROFF'
                    fdb       $0901
KwPause               fcs       'PAUSE'
                    fdb       $0A01
KwDeg               fcs       'DEG'
                    fdb       $0B01
KwRad               fcs       'RAD'
                    fdb       $0C01
KwReturn               fcs       'RETURN'
                    fdb       $0D01
KwLet               fcs       'LET'
                    fdb       $0F01
KwPoke               fcs       'POKE'
                    fdb       $1001
KwIf               fcs       'IF'
                    fdb       $1101
KwElse               fcs       'ELSE'
                    fdb       $1201
KwEndif               fcs       'ENDIF'
                    fdb       $1301
KwFor               fcs       'FOR'
                    fdb       $1401
KwNext               fcs       'NEXT'
                    fdb       $1501
KwWhile               fcs       'WHILE'
                    fdb       $1601
KwEndwhile               fcs       'ENDWHILE'
                    fdb       $1701
KwRepeat               fcs       'REPEAT'
                    fdb       $1801
KwUntil               fcs       'UNTIL'
                    fdb       $1901
KwLoop               fcs       'LOOP'
                    fdb       $1A01
KwEndloop               fcs       'ENDLOOP'
                    fdb       $1B01
KwExitif               fcs       'EXITIF'
                    fdb       $1C01
KwEndexit               fcs       'ENDEXIT'
                    fdb       $1D01
KwOn               fcs       'ON'
                    fdb       $1E01
KwErrKwd               fcs       'ERROR'
                    fdb       $1F01
KwGoto               fcs       'GOTO'
                    fdb       $2101
KwGosub               fcs       'GOSUB'
                    fdb       $2301
KwRun               fcs       'RUN'
                    fdb       $2401
KwKill               fcs       'KILL'
                    fdb       $2501
KwInput               fcs       'INPUT'
                    fdb       $2601
KwPrint               fcs       'PRINT'
                    fdb       $2701
KwChd               fcs       'CHD'
                    fdb       $2801
KwChx               fcs       'CHX'
                    fdb       $2901
* Aliases for CHD and CHX
                    fcs       'CD'
                    fdb       $2801
                    fcs       'CX'
                    fdb       $2901
KwCreate               fcs       'CREATE'
                    fdb       $2A01
KwOpen               fcs       'OPEN'
                    fdb       $2B01
KwSeek               fcs       'SEEK'
                    fdb       $2C01
KwRead               fcs       'READ'
                    fdb       $2D01
KwWrite               fcs       'WRITE'
                    fdb       $2E01
KwGet               fcs       'GET'
                    fdb       $2F01
KwPut               fcs       'PUT'
                    fdb       $3001
KwClose               fcs       'CLOSE'
                    fdb       $3101
KwRestore               fcs       'RESTORE'
                    fdb       $3201
KwDelete               fcs       'DELETE'
                    fdb       $3301
KwChain               fcs       'CHAIN'
                    fdb       $3401
KwShell               fcs       'SHELL'
                    fdb       $3501
KwBase               fcs       'BASE'
                    fdb       $3701
KwRem               fcs       'REM'
                    fdb       $3901
KwEnd               fcs       'END'
                    fdb       $4003
KwByte               fcs       'BYTE'
                    fdb       $4103
KwInteger               fcs       'INTEGER'
                    fdb       $4203
KwReal               fcs       'REAL'
                    fdb       $4303
KwBoolean               fcs       'BOOLEAN'
                    fdb       $4403
KwString               fcs       'STRING'
                    fdb       $4503
KwThen               fcs       'THEN'
                    fdb       $4603
KwTo               fcs       'TO'
                    fdb       $4703
KwStep               fcs       'STEP'
                    fdb       $4803
KwDo               fcs       'DO'
                    fdb       $4903
KwUsing               fcs       'USING'
                    fdb       $3D03
KwProcedure               fcs       'PROCEDURE'
                    fdb       $9204
KwAddr               fcs       'ADDR'
                    fdb       $9404
KwSize               fcs       'SIZE'
                    fdb       $9604
KwPos               fcs       'POS'
                    fdb       $9704
KwErr               fcs       'ERR'
                    fdb       $9804
KwMod               fcs       'MOD'
                    fdb       $9A04
KwRnd               fcs       'RND'
                    fdb       $9C04
KwSubstr               fcs       'SUBSTR'
                    fdb       $9B04
KwPi               fcs       'PI'
                    fdb       $9F04
KwSin               fcs       'SIN'
                    fdb       $A004
KwCos               fcs       'COS'
                    fdb       $A104
KwTan               fcs       'TAN'
                    fdb       $A204
KwAsn               fcs       'ASN'
                    fdb       $A304
KwAcs               fcs       'ACS'
                    fdb       $A404
KwAtn               fcs       'ATN'
                    fdb       $A504
KwExp               fcs       'EXP'
                    fdb       $A804
KwLog               fcs       'LOG'
                    fdb       $A904
KwLog10               fcs       'LOG10'
                    fdb       $9D04
KwSgn               fcs       'SGN'
                    fdb       $A604
KwAbs               fcs       'ABS'
                    fdb       $AA04
KwSqrt               fcs       'SQRT'
                    fdb       $AA04
KwSqr               fcs       'SQR'
                    fdb       $AC04
KwInt               fcs       'INT'
                    fdb       $AE04
KwFix               fcs       'FIX'
                    fdb       $B004
KwFloat               fcs       'FLOAT'
                    fdb       $B204
KwSq               fcs       'SQ'
                    fdb       $B404
KwPeek               fcs       'PEEK'
                    fdb       $B504
KwLnot               fcs       'LNOT'
                    fdb       $B604
KwVal               fcs       'VAL'
                    fdb       $B704
KwLen               fcs       'LEN'
                    fdb       $B804
KwAsc               fcs       'ASC'
                    fdb       $B904
KwLand               fcs       'LAND'
                    fdb       $BA04
KwLor               fcs       'LOR'
                    fdb       $BB04
KwLxor               fcs       'LXOR'
                    fdb       $BC04
KwTrue               fcs       'TRUE'
                    fdb       $BD04
KwFalse               fcs       'FALSE'
                    fdb       $BE04
KwEof               fcs       'EOF'
                    fdb       $BF04
KwTrimS               fcs       'TRIM$'
                    fdb       $C004
KwMidS               fcs       'MID$'
                    fdb       $C104
KwLeftS               fcs       'LEFT$'
                    fdb       $C204
KwRightS               fcs       'RIGHT$'
                    fdb       $C304
KwChrS               fcs       'CHR$'
                    fdb       $C404
KwStrS               fcs       'STR$'
                    fdb       $C604
KwDateS               fcs       'DATE$'
                    fdb       $C704
KwTab               fcs       'TAB'
                    fdb       $CD05
KwNot               fcs       'NOT'
                    fdb       $D005
KwAnd               fcs       'AND'
                    fdb       $D105
KwOr               fcs       'OR'
                    fdb       $D205
KwXor               fcs       'XOR'
                    fdb       $F703
KwUpdate               fcs       'UPDATE'
                    fdb       $f803
KwExec               fcs       'EXEC'
                    fdb       $f903
KwDir               fcs       'DIR'

* 3 byte packets used by <JmpVect1 calls - Function $12
* 1st byte is used for bit tests, bytes 2-3 are offset from 2nd byte (can be
*   jump address, others seem to be ptrs to text)
PktTable               fcb       $40                 ???
                    fdb       $0000
* label for reference only - remove after all are verified as correct

                    fcb       $00                 ???
                    fdb       KwParam-*             PARAM ($fd49)

                    fcb       $00
                    fdb       KwType-*             TYPE  ($fd4d)

                    fcb       $00
                    fdb       KwDim-*             DIM   ($fd50)

                    fcb       $00
                    fdb       KwData-*             DATA  ($fd52)

                    fcb       $00
                    fdb       KwStop-*             STOP  ($fd55)

                    fcb       $00
                    fdb       KwBye-*             BYE   ($fd58)

                    fcb       $00
                    fdb       KwTron-*             TRON  ($fd5a)

                    fcb       $00
                    fdb       KwTroff-*             TROFF ($fd5d)

                    fcb       $00
                    fdb       KwPause-*             PAUSE ($fd61)

                    fcb       $00
                    fdb       KwDeg-*             DEG   ($fd65)

                    fcb       $00
                    fdb       KwRad-*             RAD   ($fd67)

                    fcb       $00
                    fdb       KwReturn-*             RETURN ($fd69)

                    fcb       $00
                    fdb       KwLet-*             LET    ($fd6e)

                    fcb       $40                 ???
                    fdb       $0000

                    fcb       $00
                    fdb       KwPoke-*             POKE   ($fd6d)

                    fcb       $00
                    fdb       KwIf-*             IF     ($fd70)

                    fcb       $63
                    fdb       KwElse-*             ELSE   ($fd71)

                    fcb       $02
                    fdb       KwEndif-*             ENDIF  ($fd74)

                    fcb       $01
                    fdb       KwFor-*             FOR    ($fd78)

                    fcb       $22
                    fdb       PrintNextKwd-*             (something with NEXT in it) ($0fe7)

                    fcb       $01
                    fdb       KwWhile-*             WHILE ($fd7d)

                    fcb       $62
                    fdb       KwEndwhile-*             ENDWHILE ($fd81)

                    fcb       $01
                    fdb       KwRepeat-*             REPEAT ($fd88)

                    fcb       $02
                    fdb       KwUntil-*             UNTIL ($fd8d)

                    fcb       $01
                    fdb       KwLoop-*             LOOP ($fd91)

                    fcb       $62
                    fdb       KwEndloop-*             ENDLOOP ($fd94)

                    fcb       $02
                    fdb       KwExitif-*             EXITIF ($fd9a)

                    fcb       $63
                    fdb       KwEndexit-*             ENDEXIT ($fd9f)

                    fcb       $00
                    fdb       KwOn-*             ON ($fda5)

                    fcb       $00
                    fdb       KwErrKwd-*             ERROR ($fda6)

                    fcb       $20
                    fdb       PrintGotoKwd-*             Point to something with GOTO ($0f76)

                    fcb       $20
                    fdb       PrintGotoKwd-*             Point to something with GOTO ($0f73)

                    fcb       $20
                    fdb       PrintGosubKwd-*             Point to something with GOSUB ($0f6a)

                    fcb       $20
                    fdb       PrintGosubKwd-*             Point to something with GOSUB ($0f67)

                    fcb       $20
                    fdb       PrintRunKwd-*             Point to something with RUN ($0fb0)

                    fcb       $00
                    fdb       KwKill-*             KILL ($fdad)

                    fcb       $00
                    fdb       KwInput-*             INPUT ($fdb0)

                    fcb       $00
                    fdb       KwPrint-*             PRINT ($fdb4)

                    fcb       $00
                    fdb       KwChd-*             CHD ($fdb8)

                    fcb       $00
                    fdb       KwChx-*             CHX ($fdba)

                    fcb       $00
                    fdb       KwCreate-*             CREATE ($fdbc)

                    fcb       $00
                    fdb       KwOpen-*             OPEN ($fdc1)

                    fcb       $00
                    fdb       KwSeek-*             SEEK ($fdc4)

                    fcb       $00
                    fdb       KwRead-*             READ ($fdc7)

                    fcb       $00
                    fdb       KwWrite-*             WRITE ($fdca)

                    fcb       $00
                    fdb       KwGet-*             GET ($fdce)

                    fcb       $00
                    fdb       KwPut-*             PUT ($fdd0)

                    fcb       $00
                    fdb       KwClose-*             CLOSE ($fdd2)

                    fcb       $00
                    fdb       KwRestore-*             RESTORE ($fdd6)

                    fcb       $00
                    fdb       KwDelete-*             DELETE ($fddc)

                    fcb       $00
                    fdb       KwChain-*             CHAIN ($fde1)

                    fcb       $00
                    fdb       KwShell-*             SHELL ($fde5)

                    fcb       $20
                    fdb       PrintBaseKwd-*             Points to something with BASE ($0f6d)

                    fcb       $20
                    fdb       PrintBaseKwd-*             Points to something with BASE ($0f6a)

                    fcb       $20
                    fdb       PrintRemKwd-*             Points to something with REM ($0fa1)

                    fcb       $20
                    fdb       PrintAltRem-*             Points to something with (* ($0f98)

                    fcb       $00
                    fdb       KwEnd-*             END ($fde8)

                    fcb       $20
                    fdb       PrintLineOffset-*             ??? end of goto/gosub routine ($0f2b)

                    fcb       $20
                    fdb       PrintLineOffset-*             ??? end of goto/gosub routine ($0f28)

                    fcb       $40                 ???
                    fdb       $0000

                    fcb       $20
                    fdb       RemBodyLoop-*             ??? end of REM routine ($0f96)

                    fcb       $40
                    fcc       ' \'                Command statement separator literal

                    fcb       $20
                    fdb       SkipAndSavePos-*             ??? ($0e21)

                    fcb       $10
                    fdb       KwByte-*             BYTE ($fdd8)

                    fcb       $10
                    fdb       KwInteger-*             INTEGER ($fddb)

                    fcb       $10
                    fdb       KwReal-*             REAL ($fde1)

                    fcb       $10
                    fdb       KwBoolean-*             BOOLEAN ($fde4)

                    fcb       $10
                    fdb       KwString-*             STRING ($fdea)

                    fcb       $20
                    fdb       PrintThenKwd-*             ??? Something that points to 'THEN' ($0f5f)

                    fcb       $60
                    fdb       KwTo-*             TO ($fdf2)

                    fcb       $60
                    fdb       KwStep-*             STEP ($fdf3)

                    fcb       $00
                    fdb       KwDo-*             DO ($fdf6)

                    fcb       $00
                    fdb       KwUsing-*             USING ($fdf7)

                    fcb       $20
                    fdb       DecodeFMode-*             ??? Something with file access modes ($0f8a)

                    fcb       $40
                    fcc       ','                 comma
                    fcb       $00

                    fcb       $40
                    fcc       ':'                 colon
                    fcb       $00

                    fcb       $40
                    fcc       '('                 Left parenthesis
                    fcb       $00

                    fcb       $40
                    fcc       ')'                 Right parenthesis
                    fcb       $00

                    fcb       $40
                    fcc       '['                 Left bracket
                    fcb       $00

                    fcb       $40
                    fcc       ']'                 Right bracket
                    fcb       $00

                    fcb       $40
                    fcc       '; '                semi-colon with space

                    fcb       $40
                    fcc       ':='                := (pascal like equals)

                    fcb       $40
                    fcc       '='                 Equals sign
                    fcb       $00

                    fcb       $40
                    fcc       '#'                 number sign
                    fcb       $00

                    fcb       $20
                    fdb       BumpYPlus1-*             ??? Bump Y up by 2 & return ($15ec)

* Guess: These following have to do with printing numeric values???
                    fcb       $20
                    fdb       PrintSymbol-*             ??? ($0E92)

                    fcb       $20
                    fdb       PrintSymbol-*             ??? ($0E8F)

                    fcb       $20
                    fdb       PrintSymbol-*             ??? ($0E8c)

                    fcb       $20
                    fdb       PrintSymbol-*             ??? ($0E89)

                    fcb       $20
                    fdb       PrintSymbol-*             ??? ($0E86)

                    fcb       $20
                    fdb       PrintSymbol-*             ??? ($0E83)

                    fcb       $21
                    fdb       PrintSymbol-*             ??? ($0E80)

                    fcb       $22
                    fdb       PrintSymbol-*             ??? ($0E7D)

                    fcb       $23
                    fdb       PrintSymbol-*             ??? ($0E7A)

                    fcb       $20
                    fdb       AppendDotAndNum-*             ??? (Appends period, does 138A routine) ($0E73)

                    fcb       $21
                    fdb       AppendDotAndNum-*             ??? (Appends period, does 138A routine) ($0E70)

                    fcb       $22
                    fdb       AppendDotAndNum-*             ??? (Appends period, does 138A routine) ($0E6d)

                    fcb       $23
                    fdb       AppendDotAndNum-*             ??? (Appends period, does 138A routine) ($0E6a)

                    fcb       $26
                    fdb       PrintByteLit-*             ??? (print single byte numeric?) ($0E9f)

                    fcb       $27
                    fdb       PrintLineOffset-*             ??? (print 2 byte integer numeric?) ($0Ead)

                    fcb       $24
                    fdb       PrintRealToStr-*             ??? (possibly something with reals?) ($0E7b)

                    fcb       $24
                    fdb       PrintStrLit-*             ??? (string, puts " in) ($0Eb9)

                    fcb       $27
                    fdb       PrintHexStr-*             ??? (string, puts $ in) ($0Ecb)

                    fcb       $11
                    fdb       KwAddr-*             ADDR ($FDac)

                    fcb       $80                 ???
                    fdb       $0000

                    fcb       $11
                    fdb       KwSize-*             SIZE ($FDAC)

                    fcb       $80
                    fdb       $0000               ???

                    fcb       $10
                    fdb       KwPos-*             POS ($FDAC)

                    fcb       $10
                    fdb       KwErr-*             ERR ($FDAE)

                    fcb       $12
                    fdb       KwMod-*             MOD ($FDB0)

                    fcb       $12
                    fdb       KwMod-*             MOD ($FDAD)

                    fcb       $11
                    fdb       KwRnd-*             RND ($FDAF)

                    fcb       $10
                    fdb       KwPi-*             PI ($FDB9)

                    fcb       $12
                    fdb       KwSubstr-*             SUBSTR ($FDAE)

                    fcb       $11
                    fdb       KwSgn-*             SGN ($FDE6)

                    fcb       $11
                    fdb       KwSgn-*             SGN ($FDE3)

                    fcb       $11
                    fdb       KwSin-*             SIN ($FDB1)

                    fcb       $11
                    fdb       KwCos-*             COS ($FDB3)

                    fcb       $11
                    fdb       KwTan-*             TAN ($FDB5)

                    fcb       $11
                    fdb       KwAsn-*             ASN ($FDB7)

                    fcb       $11
                    fdb       KwAcs-*             ACS ($FDB9)

                    fcb       $11
                    fdb       KwAtn-*             ATN ($FDbb)

                    fcb       $11
                    fdb       KwExp-*             EXP ($FDBD)

                    fcb       $11
                    fdb       KwAbs-*             ABS ($FDD0)

                    fcb       $11
                    fdb       KwAbs-*             ABS ($FDCD)

                    fcb       $11
                    fdb       KwLog-*             LOG ($FDB9)

                    fcb       $11
                    fdb       KwLog10-*             LOG10 ($FDBB)

                    fcb       $11
                    fdb       KwSqrt-*             SQRT ($FDC9)

                    fcb       $11
                    fdb       KwSqrt-*             SQRT ($FDC6)

                    fcb       $11
                    fdb       KwInt-*             INT ($FDCE)

                    fcb       $11
                    fdb       KwInt-*             INT ($FDCB)

                    fcb       $11
                    fdb       KwFix-*             FIX ($FDCD)

                    fcb       $11
                    fdb       KwFix-*             FIX ($FDCA)

                    fcb       $11
                    fdb       KwFloat-*             FLOAT ($FDCC)

                    fcb       $11
                    fdb       KwFloat-*             FLOAT ($FDC9)

                    fcb       $11
                    fdb       KwSq-*             SQ ($FDCD)

                    fcb       $11
                    fdb       KwSq-*             SQ ($FDCA)

                    fcb       $11
                    fdb       KwPeek-*             PEEK ($FDCB)

                    fcb       $11
                    fdb       KwLnot-*             LNOT ($FDCE)

                    fcb       $11
                    fdb       KwVal-*             VAL ($FDD1)

                    fcb       $11
                    fdb       KwLen-*             LEN ($FDD3)

                    fcb       $11
                    fdb       KwAsc-*             ASC ($FDD5)

                    fcb       $12
                    fdb       KwLand-*             LAND ($FDD7)

                    fcb       $12
                    fdb       KwLor-*             LOR ($FDDA)

                    fcb       $12
                    fdb       KwLxor-*             LXOR ($FDDC)

                    fcb       $10
                    fdb       KwTrue-*             TRUE ($FDDF)

                    fcb       $10
                    fdb       KwFalse-*             FALSE ($FDE2)

                    fcb       $11
                    fdb       KwEof-*             EOF ($FDE6)

                    fcb       $11
                    fdb       KwTrimS-*             TRIM$ ($FDE8)

                    fcb       $13
                    fdb       KwMidS-*             MID$ ($FDEC)

                    fcb       $12
                    fdb       KwLeftS-*             LEFT$ ($FDEF)

                    fcb       $12
                    fdb       KwRightS-*             RIGHT$ ($FDF3)

                    fcb       $11
                    fdb       KwChrS-*             CHR$ ($FDF8)

                    fcb       $11
                    fdb       KwStrS-*             STR$ ($FDFB)

                    fcb       $11
                    fdb       KwStrS-*             STR$ ($FDF8)

                    fcb       $10
                    fdb       KwDateS-*             DATE$ ($FDFB)

                    fcb       $11
                    fdb       KwTab-*             TAB ($FDFF)

                    fcb       $80
                    fdb       $0000

                    fcb       $80
                    fdb       $0000

                    fcb       $80
                    fdb       $0000

                    fcb       $80
                    fdb       $0000

                    fcb       $80
                    fdb       $0000

                    fcb       $11
                    fdb       KwNot-*             NOT ($FDF2)

                    fcb       $51
                    fcc       '-'                 ??? (Sign as opposed to subtract?) negate (REAL)
                    fcb       $00

                    fcb       $51
                    fcc       '-'                 ??? (Sign as opposed to subtract?) negate (BYTE/INTEGER)
                    fcb       $00

                    fcb       $0A
                    fdb       KwAnd-*             AND ($FDEE)

                    fcb       $09
                    fdb       KwOr-*             OR ($FDF0)

                    fcb       $09
                    fdb       KwXor-*             XOR ($FDF1)

* Would presume that the different duplicates are for different data types
* It appears that BYTE & INTEGER use the same routines, REAL is different,
* STRING/TYPE use a third, and BOOLEAN would be a rarely used 4th
* Order appears to be : REAL/(INTEGER or BYTE)/STRING/BOOLEAN
* 3 - real/integer/string

                    fcb       $4B
                    fcc       '>'                 greater than
                    fcb       $00

                    fcb       $4B
                    fcc       '>'                 greater than
                    fcb       $00

                    fcb       $4B
                    fcc       '>'                 greater than
                    fcb       $00

* 3 - real/integer/string
                    fcb       $4B
                    fcc       '<'                 less than
                    fcb       $00

                    fcb       $4B
                    fcc       '<'                 less than
                    fcb       $00

                    fcb       $4B
                    fcc       '<'                 less than
                    fcb       $00

* 4 - real/integer/string/boolean
                    fcb       $4B
                    fcc       '<>'                not equal to

                    fcb       $4B
                    fcc       '<>'                not equal to

                    fcb       $4B
                    fcc       '<>'                not equal to

                    fcb       $4B
                    fcc       '<>'                not equal to

* 4 - real/integer/string/boolean
                    fcb       $4B
                    fcc       '='                 equal to
                    fcb       $00

                    fcb       $4B
                    fcc       '='                 equal to
                    fcb       $00

                    fcb       $4B
                    fcc       '='                 equal to
                    fcb       $00

                    fcb       $4B
                    fcc       '='                 equal to
                    fcb       $00

* 3 - real/integer/string
                    fcb       $4B
                    fcc       '>='                greater than or equal to

                    fcb       $4B
                    fcc       '>='                greater than or equal to

                    fcb       $4B
                    fcc       '>='                greater than or equal to

* 3 - real/integer/string
                    fcb       $4B
                    fcc       '<='                less than or equal to

                    fcb       $4B
                    fcc       '<='                less than or equal to

                    fcb       $4B
                    fcc       '<='                less than or equal to

* 3 - real/integer/string
                    fcb       $4c
                    fcc       '+'                 plus
                    fcb       $00

                    fcb       $4c
                    fcc       '+'                 plus
                    fcb       $00

                    fcb       $4c
                    fcc       '+'                 plus
                    fcb       $00

* 2 - real/integer
                    fcb       $4C
                    fcc       '-'                 minus
                    fcb       $00

                    fcb       $4C
                    fcc       '-'                 minus
                    fcb       $00

* 2 - real/integer
                    fcb       $4D
                    fcc       '*'                 multiply
                    fcb       $00

                    fcb       $4D
                    fcc       '*'                 multiply
                    fcb       $00

* 2 - real/integer
                    fcb       $4D
                    fcc       '/'                 divide
                    fcb       $00

                    fcb       $4D
                    fcc       '/'                 divide
                    fcb       $00

* 1 - real
                    fcb       $4E
                    fcc       '^'                 exponent
                    fcb       $00

* 1 - real
                    fcb       $4E
                    fcc       '**'                exponent (2nd version)

                    fcb       $20
                    fdb       PrintSymbol-*             ??? ($0D3c)

                    fcb       $21
                    fdb       PrintSymbol-*             ??? ($0D39)

                    fcb       $22
                    fdb       PrintSymbol-*             ??? ($0D36)

                    fcb       $23
                    fdb       PrintSymbol-*             ??? ($0D33)

                    fcb       $20
                    fdb       AppendDotAndNum-*             ??? (Adds period, does 138A) ($0D2C)

                    fcb       $21
                    fdb       AppendDotAndNum-*             ??? (Adds period, does 138A) ($0D29)

                    fcb       $22
                    fdb       AppendDotAndNum-*             ??? (Add period, does 138A) ($0D26)

                    fcb       $23
                    fdb       AppendDotAndNum-*             ??? (Add period, does 138A) ($0D23)

* System Mode commands
                    fdb       2                   # commands this table
                    fcb       2                   # bytes to first command string
SysCmdDollar               fdb       DollarCmd-SysCmdDollar
                    fcs       '$'
SysCmdCR               fdb       DirHdrPrint-SysCmdCR
                    fcb       C$CR+$80            (Carriage return)

                    fdb       16                  # commands this table
                    fcb       2                   # bytes to first command string
SysCmdBye               fdb       BYEBYE-SysCmdBye
                    fcs       'BYE'
SysCmdDir               fdb       DIR-SysCmdDir
                    fcs       'DIR'
SysCmdEdit               fdb       EditCmd-SysCmdEdit
                    fcs       'EDIT'
SysCmdEditE               fdb       EditCmd-SysCmdEditE
                    fcs       'E'
SysCmdList               fdb       PrepSavePath-SysCmdList
                    fcs       'LIST'
SysCmdRun               fdb       INTERP-SysCmdRun
                    fcs       'RUN'
SysCmdKill               fdb       KILLER-SysCmdKill
                    fcs       'KILL'
SysCmdSave               fdb       SAVE-SysCmdSave
                    fcs       'SAVE'
SysCmdLoad               fdb       OpenAndLoad-SysCmdLoad
                    fcs       'LOAD'
SysCmdRename               fdb       RENAME-SysCmdRename
                    fcs       'RENAME'
SysCmdPack               fdb       DUMP-SysCmdPack
                    fcs       'PACK'
SysCmdMem               fdb       CHGMEM-SysCmdMem
                    fcs       'MEM'
SysCmdChd               fdb       CHDDIR-SysCmdChd
                    fcs       'CHD'
SysCmdChx               fdb       ChxDir-SysCmdChx
                    fcs       'CHX'
* Aliases for CHD and CHX
SysCmdCd               fdb       CHDDIR-SysCmdCd
                    fcs       'CD'
SysCmdCx               fdb       ChxDir-SysCmdCx
                    fcs       'CX'

* Debug mode commands (offsets done by current base + offset)
                    fdb       2                   # of entries this table (-3,x)
                    fcb       2                   # of bytes to start of next entry (-1,x)
DbgCmdDollar               fdb       DollarCmd-DbgCmdDollar         base ptr goes here (0,x)
                    fcs       '$'                 base ptr+(-1,x) above points here
DbgCmdCR               fdb       DebugSingleStep-DbgCmdCR
                    fcb       C$CR+$80            (Carriage return)

DbgCmdTable               fdb       14                  # of entries this table (but 13?)
                    fcb       2                   # bytes to next entry
* Debug set #2?
DbgCmdCont               fdb       ContCmd-DbgCmdCont
                    fcs       'CONT'
DbgCmdDir               fdb       DIR-DbgCmdDir
                    fcs       'DIR'
DbgCmdQ               fdb       QuitDebug-DbgCmdQ
                    fcs       'Q'
DbgCmdList               fdb       ListCmd-DbgCmdList
                    fcs       'LIST'
DbgCmdPrint               fdb       CheckPackedPt-DbgCmdPrint
                    fcs       'PRINT'
DbgCmdState               fdb       StateCmd-DbgCmdState
                    fcs       'STATE'
DbgCmdTron               fdb       CheckPackedPt-DbgCmdTron
                    fcs       'TRON'
DbgCmdTroff               fdb       CheckPackedPt-DbgCmdTroff
                    fcs       'TROFF'
DbgCmdDeg               fdb       CheckPackedPt-DbgCmdDeg
                    fcs       'DEG'
DbgCmdRad               fdb       CheckPackedPt-DbgCmdRad
                    fcs       'RAD'
DbgCmdLet               fdb       CheckPackedPt-DbgCmdLet
                    fcs       'LET'
DbgCmdStep               fdb       StepCmd-DbgCmdStep
                    fcs       'STEP'
DbgCmdBreak               fdb       BreakCmd-DbgCmdBreak
                    fcs       'BREAK'
* Some edit mode stuff?
                    fdb       8                   # entries this table
                    fcb       2                   # bytes to start entry
EditCmdL               fdb       EditSetupLine-EditCmdL
                    fcs       'L'
EditCmdLl               fdb       EditSetupLine-EditCmdLl
                    fcs       'l'
EditCmdD               fdb       SubstCmd-EditCmdD
                    fcs       'D'
EditCmdDl               fdb       SubstCmd-EditCmdDl
                    fcs       'd'
EditCmdPlus               fdb       EditModICode-EditCmdPlus
                    fcs       '+'
EditCmdMinus               fdb       EditModICode-EditCmdMinus
                    fcs       '-'
EditCmdCR               fdb       EditModICode-EditCmdCR
                    fcb       C$CR+$80
EditCmdSpace               fdb       InsertAndEdit-EditCmdSpace
                    fcb       C$SPAC+$80

                    fdb       4                   # entries
                    fcb       2                   # bytes to first entry
EditCmdS               fdb       EditWithWild-EditCmdS
                    fcs       'S'
EditCmdC               fdb       EditExact-EditCmdC
                    fcs       'C'
EditCmdR               fdb       MoveLinesCmd-EditCmdR
                    fcs       'R'
EditCmdQuit               fdb       EatStkRebind-EditCmdQuit
                    fcs       'Q'

ReadyPrefix               fcb       $0E
                    fcs       'Ready'
WhatStr               fcs       'What?'
FreeStr               fcs       ' free'
ProgramStr               fcs       'Program'
ProcedureStr               fcs       'PROCEDURE'
                    fcb       C$CR
DirHdrStr               fcb       C$LF
                    fcs       '  Name      Proc-Size  Data-Size'
RewriteStr               fcc       'Rewrite?: '
AlphaModeCode               fcb       $0E
                    fcs       'BREAK: '
OkStr               fcs       'ok'
DebugPrompt               fcs       'D:'
EditPromptStr               fcs       'E:'
ReadyPrompt               fcs       'B:'

* F$Icpt routine
INTCPT               lda       R$DP,s              Get DP register from stack
                    tfr       a,dp                Put into real DP
                    stb       <LastSignal              Save signal code

                    ifne      H6309
                    oim       #$80,<SigFlag         Set high bit (flag signal was received)
                    else
                    lsl       <SigFlag              Set high bit (flag signal was received)
                    coma                    Break flag
                    ror       <SigFlag
                    endc

                    rti                           Return to normal BASIC09

* BASIC09 INIT
start
                    ifne      H6309
                    tfr       u,d                 Save start of data mem into D
                    ldw       #$100               Size of DP area to clear
                    clr       ,-s                 Clear byte on stack
                    tfm       s,u+                clear out DP
                    else
* (orig: START)
                    pshs      u                   Save start of data mem on stack
                    leau      >$100,u             Point to end of DP
                    clra                          Clear all of DP to $00
                    clrb
START0               std       ,--u
                    cmpu      ,s
                    bhi       START0
                    puls      d                   Get start of data mem into D
                    endc

                    leau      ,x                  Point U to Start of parameter area
                    std       <DpBase              Preserve Start of Data memory ptr
                    inca                          Point to $100 in data area
                    sta       <BinderMode              Preserve the 1
                    std       <TmpBufBase              Initialize ptr to start of temp buffer
                    std       <TmpBufCur              Initialize current pos. in temp buffer
                    adda      #$02                D=$300
                    std       <SubrStkPtr              Save subroutine stack ptr
                    std       <StrSpaceTop              Save top of string space ptr
                    inca                          D=$400
                    tfr       d,s                 Point stack to $400 ($300-$3ff)
                    std       <ModListPtr              Save ptr to ptr list of modules in workspace
                    pshs      x                   Preserve start of param area

                    ifne      H6309
                    pshs      b                   Put 0 byte on stack
                    ldw       #$100               Size of area to clear ($400-$4ff)
                    tfm       s,d+                Clear out list of module ptrs (D=$500 at end)
                    leas      1,s                 Eat stack byte
                    else
                    tfr       d,x                 x=$400
                    clra                          d=$0000
ClrLp               sta       ,x+                 Clear byte
                    incb                          Inc counter
                    bne       ClrLp               Do until it wraps
                    tfr       x,d                 Move $500 to D
                    endc

                    std       <ICodeBase              Save ptr to start of I-Code workspace
                    std       <ICodeEndPtr              Save ptr to end of used I-Code workspace
                    tfr       u,d                 Move start of param area ptr to D
                    subd      <DpBase              Calculate size for entire data area
                    std       <DataAreaSz              Preserve size of Data area
                    ldb       #01                 Std Out path
                    stb       <StdoutPath              Save as std output path
                    lda       #$03                Close all paths past the standard 3
START05               os9       I$Close
                    inca
                    cmpa      #$10                Do until 3-15 are closed
                    blo       START05
                    lda       #$02                Create duplicate path for error path
                    os9       I$Dup
                    sta       <ErrDupPath              Preserve duplicate's path #
                    leax      <INTCPT,pc           Point to intercept routine and set it up with
                    os9       F$Icpt              it's memory area @ start of param area
                    leax      >JmpVectTbl-$d,pc        Point to beginning of module header
                    ifne      H6309
                    tfr       x,w                 Move it to W
                    else
                    pshs      x             save BASE 0
                    endc
                    ldx       <DpBase              Point X to start of data mem
* Set up some JMP tables from the module header
                    leax      <$1B,x              Point $1b bytes into it
                    leay      >JmpVectTbl,pc           Point to module header extensions
START15               lda       #$7E                Opcode for JMP Extended instruction
                    sta       ,x+                 Store in table
                    ldd       ,y++                Get jump offset from module header extension
                    ifne      H6309
                    addr      w,d                 Add to start of module address
                    else
                    addd      ,s            make absolute
                    endc
                    std       ,x++                Store as destination of JMP
                    ldd       ,y                  Keep installing JMP tables until 0000 found
                    bne       START15
                    ifeq      H6309
                    leas      2,s                 eat X on stack
                    endc
                    bsr       CallVect4Fn0               Go init <$50 vars, & some table ptrs
                    puls      y                   Get parameter ptr
                    leax      >CmdTable,pc           Point to main command token list
                    stx       <CmdTablePtr              Save it
                    ldb       ,y                  Get char from params
                    cmpb      #C$CR               Carriage return?
                    ifne      wildbits
                    lbeq      BannerGo               Yes, go print the title screen COMAND
				else
				beq       COMAND                         ..yes; enter Basic09 command
				endc
* Optional filename specified when BASIC09 called
                    leax      <START2,pc           No, point to initial entry of routine
                    pshs      y                   Preserve param ptr
                    bsr       SETUP1
                    lbsr      DIRLNK         try to find packed module
                    bcc       EXIT         ..If found; don't do auto-load
                    lbsr      OpenAndLoad               Go open path to name (Y=ptr to it)
                    bra       EXIT         cleanup stack

CallVect4Fn0               jsr       <JmpVect4              JMP to Vect4Dispatch (default from module header)
                    fcb       $00                 Function code 0

START2               puls      y                   Get original contents of <ExitStkPtr
                    bsr       SETUP
                    ldx       <ModListPtr              Get ptr to module list
                    ldd       ,x                  Get ptr to 1st module (initially 0 (none))
                    std       <CurModPtr              Save it
                    lbsr      INTERP         (will exit to COMAN0)
SETUP               leax      <ReadyCmdLoop,pc           Get ptr >1st entry into routine
SETUP1               puls      u                   Get RTS address
                    bsr       SETEXT               Push 2 bytes from <B7 onto stack, RTS=START2
                    pshs      u                   Save RTS address from BSR SETUP1
                    clr       <SigFlag              Clear out signal recieved flag
                    ldd       <DpBase              Get start of data mem
                    addd      <DataAreaSz              Add size of data mem
                    subd      <ICodeBase              Subtract all BASIC09 reserved stuff ($500 bytes)
                    subd      <ICodeUsed              Subtract # bytes used by user's programs (not Data)
                    std       <WorkspaceFree              Save # bytes free in workspace for user's programs
                    leau      2,s                 Point U to START2 ptr on stack
                    stu       <SubrStkPtr              Save ptr to it
                    stu       <StrSpaceTop              And again
                    leas      -$FE,s              Bump stack ptr back 254 bytes
                    jmp       [<-2,u]             Jump to START2 address on stack

EXIT               lds       <ExitStkPtr
                    puls      d             pop previous exit trap
                    std       <ExitStkPtr        reset it
EXNLIN               lbra      ResetTmpBuf               Reset temp buffer size & ptrs to defaults

SETEXT               ldd       <ExitStkPtr              Get some other stack ptr?
                    pshs      d                   Preserve it
                    sts       <ExitStkPtr              Save stack ptr
                    ldd       2,s                 Get RTS address to SETUP1 or START2
                    stx       2,s                 Save ptr to START2 or SETUP on stack
                    tfr       d,pc                Return to SETUP1 (just after BSR SETEXT)

COMAND               leax      >IntroScreen,pc           Point to intro screen credits
                    bsr       PrintMsg               Copy to temp buffer/print to Std error
                    leax      name,pc             Point to 'Basic09'
                    bsr       PrintMsg               Copy to temp buffer/print to Std error

ReadyCmdLoop               bsr       SETUP
                    leax      >ReadyPrefix+1,pc         Point to 'Ready'
                    bsr       PrintMsg               Copy to temp buffer/print to Std error
                    leax      >ReadyPrompt,pc           Point to 'B:' prompt
                    leay      >SysCmdDollar,pc           Point to system mode command table
                    clr       <PackedFlag
* (orig: COMAN0)
                    bsr       RUNCMD               Get command & execute it
                    bcc       EXIT               Did it, no problem
                    bsr       CMDERR               Unknown command, print 'What?'
                    bra       EXIT               Resume normal operation

CMDERR               leax      >WhatStr,pc           Point to 'What?'
PrintMsg               lbra      PrintXToStderr               Copy to temp buffer/print to Std error

* Get next command from keyboard & execute it
* Entry: Y=Ptr to command table
* Exit: Carry set if command doesn't exist
RUNCMD               pshs      y,x                 Preserve command tbl ptr & ptr to prompt (ex B:)
                    clr       <LastSignal              Clear out last signal received
                    lbsr      PrintXThenBuf               Go print a message if we have to to std err
                    bsr       EXNLIN               S/B LBSR ResetTmpBuf (saves 3 cycles)
                    lda       <ActivePath              Get current input path #
                    beq       ReadLine               If Std In, skip ahead
                    os9       I$Close             Otherwise, close it
* (orig: RUNCMD05)
                    clr       <ActivePath              Force input path # to 0 (Std In)
ReadLine               lbsr      INLINE               ReadLn up to 256 bytes from std in
                    bcc       RUNC10               No error on read, continue
                    cmpb      #E$EOF              <ESC> key?
                    bne       RUNC90               No, exit routine with error
                    ifne      H6309
                    ldq       #$6279650d          'bye' <CR>
                    stq       ,y                  Stick it in the keyboard buffer
                    else
                    ldd       #'b*256+'y          Stick the word 'bye' <CR> into the keybrd buffer
                    std       ,y
                    ldd       #'e*256+C$CR        ('e' + CR)
                    std       2,y
                    endc
* Keyboard line read, no errors from ReadLn
RUNC10               ldx       2,s                 Get command tbl ptr back
                    lda       #$80                Mask to check for end of entry (high bit set)
                    bsr       Vect2Fn4               Go parse line, y=ptr to offset in command found
                    bne       RUNC20               '$' or <CR> command found, skip ahead
* (orig: PRCLIT)
                    lbsr      Vect2Fn2               ???Go check for a procedure name, B=size
                    beq       RUNC90               None, exit with carry set
                    leax      $03,x               Point to system mode table 2
                    lda       #C$SPAC             ???
                    bsr       Vect2Fn4               Go parse line, y=ptr to offset in command found
                    beq       RUNC90               No command found, exit with carry set
* Command found in table
RUNC20               ldd       ,x                  Get offset
                    leas      4,s                 Eat stack
                    jmp       d,x                 Call routine

Vect2Fn4               jsr       <JmpVect2
                    fcb       $04

* Command not found
RUNC90               coma                          Set carry & exit
                    puls      pc,y,x

* Entry: Y=Ptr to string of chars
CHGMEM               lbsr      SkipSepChar               Go find 1st non-space/comma char
                    bne       CHGME1               Found one, skip ahead
                    leax      ,y                  Point X to char
                    ldd       <ICodeBase              Get ptr to start of I-Code workspace
                    addd      <ICodeUsed              Add to size of all programs in workspace
                    inca                          Bump up by 256 bytes
                    subd      <DpBase              Subtract start of data mem ptr
                    pshs      d                   Preserve size
                    lbsr      EvalNumExpr               ??? Check something
                    bcs       CHGERR               Error, exit with carry set
                    cmpd      ,s++                Check with previously calculated size
                    blo       CHGER1               Will fit, continue
                    os9       F$Mem               Won't fit, request the required data mem size
                    bcs       CHGME1               Can't get it, skip ahead
                    subd      #$0001              Bump gotten size down by 1 byte
                    std       <DataAreaSz              Save new data mem size
CHGME1               lbsr      ResetTmpBuf               Reset temp buffer size & ptrs
                    ldd       <DataAreaSz              Get data mem size
                    bsr       ItoA               ???
CHGME9               lbra      AddCrPrint               Print temp buff contents to std error

CHGERR               leas      2,s                 Eat something off stack
CHGER1               coma                          Exit with carry set
                    rts

* Debug & System mode - DIR
DIR               leax      ,y
                    lbsr      OPNCHL
* System mode - <CR>
DirHdrPrint               leax      >DirHdrStr,pc           Point to basic09 DIR header
                    lbsr      PrintXToStderr               Print it out to Std err
                    ldy       <ModListPtr              Get Ptr to list of modules in BASIC09 workspace
                    bra       DIR2               Go print directory

* Entry: X=Ptr to module in memory
* Prints module names out of modules in work-space.
* A '*' indicates the current module, a '-' indicates packed or other language
*   module
DIR1               pshs      y,x                 Preserve ? & module ptr
                    lda       #C$SPAC             Space char as default
                    tst       M$Type,x            Check type/language
                    beq       DIR10               If source code in workspace, skip ahead
                    lda       #'-                 '- char indicates packed or other language code
DIR10               lbsr      AppendChar               Add char in A to temp text buffer
                    lda       #C$SPAC             Default to space again
                    cmpx      <CurModPtr              Is this the 'current' module?
                    bne       DIR15               No, skip ahead
                    lda       #'*                 '*' to indicate current module
DIR15               lbsr      AppendChar               Append that char to temp text buffer
                    ldd       M$Name,x            Get offset to name of module
                    leax      d,x                 Point to name
                    lbsr      CopyNameToBuf               ??? Print it out
                    ldd       #$11*256+M$Size     A=??, B=offset from module ptr to get data
                    bsr       DIRNUM               Go print program size
                    ldd       #$1C*256+M$Mem      A=??, B=offset from module ptr to get data
                    bsr       DIRNUM               Go print data area size
                    ldd       M$Mem,x             Get data area size required by module
                    addd      #$0040              Add 64 to it
                    cmpd      <WorkspaceFree              Bigger than bytes free in workspace for user?
                    blo       DIR18               Legal data area size, continue
                    lda       #'?                 Data area too big for current buffer space, print
                    lbsr      AppendChar               a '?' beside data area size
DIR18               bsr       CHGME9               Print line out to std error path
                    puls      y,x                 Get ??? & module ptr back
                    tst       <LastSignal              Any signals pending?
                    bne       DIR3               Yes, skip ahead
DIR2               ldx       ,y++                Get ptr to module
                    bne       DIR1               There is one, go print it's entry out
DIR3               ldd       <WorkspaceFree              None left, get # bytes free in BASIC09 workspace
                    bsr       ItoA               Go convert to ASCII
                    leax      >FreeStr,pc           Point to 'free'
                    lbsr      CopyAndPrint               Print it out to Std err
                    lbra      CLSCHL               Close std err; Dup path @ <BE & return from there

* Entry: A=???, b=offset from module header to get 2 byte # from
DIRNUM               pshs      b                   Preserve B
                    ldb       #$10                Sub function (uses table @ IoJmpBase)
                    lbsr      Vect6Fn2               Call <2A (inited to Vect6Dispatch), function 2
                    puls      b                   Restore B
                    ldx       2,s                 Get module ptr back
                    ldd       b,x                 Get size to print

* Convert # in D to ASCII version (decimal)
ItoA               pshs      y,x,d               Preserve End of data mem ptr,?,Data mem size
                    pshs      d                   Preserve data mem size again
                    leay      <DecTable,pc           Point to decimal table (for integers)
ItoA.A               ldx       #$2F00
ItoA.B               puls      d                   Get data mem size
ItoA.C               leax      >$0100,x            Bump X up to $3000
                    subd      ,y                  Subtract value from table
                    bhs       ItoA.C               No underflow, keep subtracting current power of 10
                    addd      ,y++                Restore to before underflow state
                    pshs      d                   Preserve remainder of this power
                    ldd       ,y                  Get next lower power of 10
                    tfr       x,d                 Promptly overwrite it with X (doesn't chg flags)
                    beq       INVOKE               If finished table, skip ahead
                    cmpd      #$3000              Just went through once?
                    beq       ItoA.A               Yes, reset X & do again
* (orig: ItoA.Z)
                    lbsr      AppendChar               Go save A @ [<TmpBufCur]
                    ldx       #$2F01              Reset X differently
                    bra       ItoA.B               Go do again

INVOKE               lbsr      AppendChar               Go save A @ [<TmpBufCur]
                    leas      2,s                 Eat stack
                    puls      pc,y,x,d            Restore regs & return

* Table of decimal values
DecTable               fdb       $2710               10000
                    fdb       $03E8               1000
                    fdb       $0064               100
                    fdb       $000A               10
                    fdb       $0001               1
                    fdb       $0000               0

* Debug/System '$' goes here
* Entry: Y=Ptr to line typed in by user?
DollarCmd               lbsr      SkipSepChar               Go check char @ Y for space or comma
                    leau      ,y                  Point to start of parameter area
                    clrb                          Current size of parameter area=0
INVK10               incb                          Bump size up by 1
                    lda       ,y+                 Get char from user's line
                    cmpa      #C$CR               Hit end yet?
                    bne       INVK10               No, keep looking
                    clra                          parameter line never >255 chars
                    tfr       d,y                 Move size of parameter area to Y for Fork
                    leax      >KwShell,pc           Point to 'SHELL'
                    lda       #Objct              ML program
                    clrb                          Size of data area=0 pages
* (orig: INVK20)
                    os9       F$Fork              Fork shell out
                    bcs       PrintErrExit               Error, deal with it
                    pshs      a                   Save process # of shell
WaitChild               os9       F$Wait              Wait for death signal
                    cmpa      ,s                  Was it our shell process?
                    bne       WaitChild               No, wait for ours
                    leas      1,s                 Yes, eat process #
                    tstb                          Error status from child?
                    bne       PrintErrExit               Yes, deal with it
                    rts                           No, return
* System Mode - CHD (MOD 93/09/20 - CHANGED FROM UPDAT. TO READ.)
CHDDIR               lda       #DIR.+READ.         Open Data directory in Update mode
                    bra       CHXD10

* System Mode - CHX
ChxDir               lda       #DIR.+EXEC.         Open Execution Directory
CHXD10               leax      ,y                  Point to directory we are changing to
                    os9       I$ChgDir            Change dir
                    bcs       PrintErrExit               Error, exit with it
                    rts                           No error, return

RENAME               bsr       GetProcName
                    lbsr      DIRSCH         Is it in directory?
                    bcs       CMDSEP         No; error - not in workspace
                    pshs      x
                    ldx       ,x            get procedure address
                    tst       6,x           internal (un-typed) procedure?
                    bne       CMDSEP         ..no; sorry
                    bsr       SkipSepChar               Go check char @ Y for space or comma
                    beq       INTE05               It is a space or comma, skip ahead
RENAMErr               comb                          Set carry, restore X & return
                    puls      pc,x          Return error

INTE05               bsr       Vect2Fn2               Call <JmpVect2, function 2
                    beq       RENAMErr
                    pshs      y
                    lbsr      DIRSCH         Is it in directory?
                    bcs       RENA05         ..no; good
                    cmpx      $02,s         renaming same procedure?
                    bne       ERUPRC
RENA05               ldx       $02,s
                    lbsr      UnbindSetupMod         Unbind the procedure
                    puls      x             get ptr to new name
                    ldy       <ICodeEndPtr
RENAM1               lda       ,x+
                    sta       ,y+
                    bpl       RENAM1
                    sty       <ICodeLineEnd        Set end of name ptr
                    ldx       [,s++]        get address of procedure
                    ldd       $04,x
                    leay      d,x           get address of old name
* (orig: ERPRCX)
                    ldb       <$18,x        get size of old name
                    lda       <NameStrSz        Replace it with size of new name
                    sta       <$18,x
                    clra
* (orig: ERREXT)
                    lbsr      InsertICode         Replace old name with new name
                    addd      <ModExecAddr
                    std       <ModExecAddr
RBIND1               lbra      RebindProc

ERUPRC               ldb       #$2C                Multiply-defined procedure error
* Error
PrintErrExit               lbsr      PrintSysErr
ErrorExit               lbra      EXIT

CMDSEP               ldb       #$2B                Unknown procedure error
                    bra       PrintErrExit

* Entry: Y=Ptr to string of chars?
* Exit:  Y=Ptr to char (or up 1 char if space/comma found)
*        B=Char found
SkipSepChar               ldb       ,y+                 Get char
                    cmpb      #',                 Is it a ','?
                    beq       SkipSep9               Yes, return
                    cmpb      #C$SPAC             Is it a space?
                    beq       SkipSep9               Yes, return
                    leay      -1,y                No, normal char, point Y to it
SkipSep9               rts                           Exit with B=char

* Entry: Y=Ptr to 1st char in possible string name
* Exit:  Y=Ptr to module name (or string name)
GetProcName               bsr       Vect2Fn2               Call <JmpVect2 function 2 (string name search again)
                    bne       GetProcName9               Size possible name>0, exit
DEFPRC               ldy       <CurModPtr              Get ptr to 'current' module
                    beq       UseProgName               None, use 'Program' as default
                    ldd       M$Name,y            Get offset to module name
                    leay      d,y                 Point Y to module name & return
* (orig: PRCRE9)
                    rts

UseProgName               leay      >ProgramStr,pc           Point Y to 'Program'
GetProcName9               rts

UnkProcErr               ldb       #$2B                Unknown procedure error
                    bra       CheckEofErr

MemFullErr               ldb       #$20                Memory full error
SaveBndErr               pshs      b
                    bsr       RBIND1         Bind erroneous procedure
                    puls      b             Restore error code
CheckEofErr               cmpb      #E$EOF              End of file error?
                    beq       ErrorExit               Yes, special case
                    bra       PrintErrExit               Exit with it

Vect2Fn2               jsr       <JmpVect2
                    fcb       $02

* Entry: Y=Ptr to string (path name)
* Exit: Path opened to file, path # @ <ActivePath
OpenAndLoad               leax      ,y                  Point to path name
                    lda       #1                  Std out path
                    os9       I$Open              Open path
                    bcs       CheckEofErr               Error, check if it is EOF
                    sta       <ActivePath              Save path #
                    bsr       INLINE               Go read a line into temp input buffer
                    bsr       CheckProcKwd               Go check if it starts with 'PROCEDURE'
                    bne       UnkProcErr               No, exit with Unknown Procedure Error
BindProcLoop               bsr       Vect2Fn2               Yes, call function
                    beq       UnkProcErr
                    pshs      y
                    lbsr      DIRSCH         Is name in directory?
                    bcs       AddToDir         ..no; don't try kill
                    ldy       ,s
                    leay      -$01,y        Must have a preceeding space
* (orig: INTE40)
                    lbsr      KILLER         Destroy any old version that may have existed
AddToDir               ldy       ,s
                    lbsr      DIRADD
                    lbsr      UnbindSetupMod
                    puls      x             Restore proc name ptr
                    lbsr      PrintXToStderr         Print it
LoadLineLoop               ldb       <LastSignal              Get last received signal code
                    bne       SaveBndErr               Got a signal, use it as error code & abort load
                    bsr       INLINE               Go get line of source from file
                    bcs       SaveBndErr               Error on read, exit with it
                    lda       <WorkspaceFree              Get MSB of bytes free in workspace
                    cmpa      #$02                At least $2ff (767) bytes free?
                    blo       MemFullErr               No, exit with memory full error
                    bsr       CheckProcKwd               Check for word PROCEDURE
                    beq       FoundProcHdr               Found it, skip ahead
                    ldy       <TmpBufBase              Get temp buff ptr
                    ldd       <ModFOff
                    std       <ICodeCurPtr        At end of icode-
                    lbsr      CompileOneLine         -insert this line
                    bra       LoadLineLoop         Endloop

FoundProcHdr               ldx       <TmpBufBase              Get ptr to start of temp buffer
                    pshs      y,x                 Save ??? & temp buffer start ptr
SkipToCR               lda       ,x+                 Get char
                    cmpa      #C$CR               Carriage return?
                    bne       SkipToCR               No, keep looking for CR
                    stx       <TmpBufBase              Save CR+1 position as start of temp buffer
                    stx       <TmpBufCur              And as current position in temp buffer
* Is this function to read in a source listing (single procedure) not including
*   PROCEDURE line itself?
                    bsr       Vect3Fn2               JSR <$21, function 2
                    puls      y,x                 Restore ??? & temp buffer start ptr
                    stx       <TmpBufBase              Save temp buffer start ptr again
                    stx       <TmpBufCur              And save current position in temp buffer
                    bra       BindProcLoop               Loop back

* Read line from source code file
INLINE               lda       <ActivePath              Get path # to file
                    ldx       <TmpBufBase              Get address to get data into
                    ldy       #$0100              Up to 256 bytes to be read
                    os9       I$ReadLn            Go read a line
                    ldy       <TmpBufBase              Get ptr to line read & return
                    rts

* Entry: Y=ptr to input buffer
* Exit: Carry clear if word 'PROCEDURE' was found
*       Y=Ptr to 1 byte past 'procedure' in buffer
CheckProcKwd               bsr       Vect2Fn2               Call function
                    leax      >ProcedureStr,pc           Point to 'PROCEDURE'
PRCLI1               lda       ,x+                 Get byte from 'procedure'
                    eora      ,y+                 Check (with case conversion) if it matches buffer
                    anda      #$DF
                    bne       PRCLI9               No, exit
* NOTE: SHOULD MAKE LDA -1,X SINCE FASTER
                    tst       -1,x                Was that the last letter of 'procedure'?
                    bpl       PRCLI1               No, keep checking
                    clra                          Yes, no error & return
PRCLI9               rts                     to user

DUMP               lbsr      DEFILE
                    ldu       <SubrStkPtr
                    bra       DUMP02         Repeat

Vect3Fn2               jsr       <JmpVect3
                    fcb       $02

* Entry: X=Ptr to possible filename
DUMP01               ldy       ,y                  Get module header ptr from somewhere
                    tst       6,y                 Check type of module
                    lbne      ERABRT               If anything but 0, exit with Line with Compiler error
                    lda       <$17,y              Get flag byte
                    rora                          Shift out Line with compiler error bit
                    lbcs      ERABRT               Has error, exit with it
                    ldd       $0D,y               ???
                    leay      d,y                 Point to that offset in module
                    ldd       -3,y          number of entries in symbol tbl
                    lslb                          Multiply by 2
                    rola                    2)
                    inca                          Add $100
                    cmpd      <WorkspaceFree              Compare with bytes free in workspace
                    lbhi      ERMFUL               If higher, exit with memory full error
DUMP02               ldy       ,--u
                    bne       DUMP01         Until end of list
                    ldd       #(EXEC.+WRITE.)*256+UPDAT.+EXEC. Exec. dir & rd/wt/ex attribs
                    lbsr      OPNCH0               Go create file (0 byte length)
                    ldy       <SubrStkPtr
                    stu       <SubrStkPtr        chop out used portion of opstack
                    lbra      DUMP04         Repeat

DumpProcLoop               pshs      y
                    lbsr      UnbindSetupMod         Unbind procedure
                    clr       <BinderMode        Tell binder to smash rems, dims, types, etc.
                    bsr       Vect3Fn2               JSR <JmpVect3, function 2 (PLREF)
                    inc       <BinderMode        Reset
                    ldx       <ModSymTbl        get symbol tbl ptr
                    leay      ,x            (in case of no symbols)
* NOTE: <DpBase UNECESSARY FOR LEVEL II
                    ldd       <DpBase              Get start of data area ptr
                    addd      <DataAreaSz              Get ptr to end of data area
                    tfr       d,u                 Move to U
                    ldd       -3,x
                    beq       FinalizePackMod         No symbols; exit squish phase
* (orig: DUMP1)
                    pshs      u                   Save size of data area
DumpSymEntry               pshs      d
                    leax      1,x
                    ldd       ,x
                    pshu      d             Build stack of save info from symbol table
                    clr       ,x+           Clear out symbol table entry
                    clr       ,x+
DUMP2               lda       ,x+                 Find hi-bit set char
                    bpl       DUMP2         Skip over name to next entry
                    puls      d             Restore symbol table count
                    subd      #1
                    bne       DumpSymEntry         Repeat until whole table copied
                    ldy       <ModExecAddr
                    bra       DUMP4         While not end of icode

DUMP3               ldd       ,y
                    ldx       <ModSymTbl
                    leax      d,x           Actual addr of symbol tbl entry
                    ldd       1,x           get linked list
                    sty       1,x           Make new head
                    std       ,y++          Build link
DUMP4               lbsr      ScanTokenT3
                    bcc       DUMP3         Endwhile
                    puls      u
                    ldx       <ModSymTbl        get old symbol table ptr
                    ldd       -3,x          Number of entries in symbol table
                    leay      ,x            Set beginning of new symbol table
DUMP5               leau      -2,u
                    pshs      u,d           Save number of entries, stack ptr
                    clra
                    ldu       1,x           get header link
                    beq       DUMP8         Branch unreferenced entry
                    pshs      x             Save old symbol ptr
                    tfr       y,d           Copy new symbol ptr
                    subd      <ModSymTbl        Make ptr into offset
                    bra       DUMP7

DUMP6               std       ,u
                    leau      ,x            Copy ptr to next reference
DUMP7               ldx       ,u
                    bne       DUMP6         Branch if there is one
                    std       ,u            Set offset of last
                    puls      x             Retrieve old symbol ptr
                    lda       ,x            get type byte
                    sta       ,y+           Copy it
                    ldu       [<2,s]        get old contents
                    stu       ,y++          Copy them
DUMP8               leax      3,x
DUMP9               ldb       ,x+
                    cmpa      #$A0          Copy name?
                    bne       DUMP10         Branch if not
                    stb       ,y+
DUMP10               tstb
                    bpl       DUMP9
                    puls      u,d
                    subd      #1
                    bne       DUMP5
FinalizePackMod               ldx       <CurModPtr              Get ptr to start of current module
                    ldd       M$Size,x            Get size of module
                    pshs      d                   Save it
                    leay      3,y                 Add size of 24 bit CRC
                    tfr       y,d                 Move ptr to end of module (including CRC bytes)
                    subd      <CurModPtr              Calculate size of module including CRC
                    std       M$Size,x            Save it
                    ldd       ,s                  Get original size of module
                    subd      M$Size,x            Subtract new size
                    std       ,s                  Save size difference
                    addd      <WorkspaceFree              Add to bytes free in workspace
                    std       <WorkspaceFree              Save new # bytes free
                    ldd       <ICodeUsed              Get # bytes used by all programs in workspace
                    subd      ,s++                Subtract size difference
                    std       <ICodeUsed              Save new # bytes used by all programs in workspace
                    addd      <ICodeBase              Add to start ptr of I-code workspace (calculate end)
                    std       <ICodeEndPtr              Save ptr to 1st free byte in I-code workspace
                    ldb       #Sbrtn+ICode        Subroutine module/I-Code type byte
                    stb       M$Type,x            Save in module header
                    ldb       #%10000000          Packed flag
                    stb       <$17,x              Save flags
                    leau      -3,y                Point Y to end of module - CRC bytes
                    ldd       #$FFFF              Init CRC to $FF's
                    std       ,u                  (Header parity too)
                    sta       2,u
                    ldb       #7                  Bytes 0-7 used to calculate header parity
DUMP25               eora      b,x                 Calculate header parity
                    decb
                    bpl       DUMP25               Do all of header
                    sta       M$Parity,x          Save header parity
                    ldy       M$Size,x            Get module size
                    leay      -3,y                Minus CRC bytes themselves
                    os9       F$CRC               Calculate module CRC
* If u not used after this, could change to com ,u/com 1,u/com 2,u
                    com       ,u+                 Last stage of CRC calc: Complement all 3 bytes
                    com       ,u+
                    com       ,u+           (u)=end of procedure
                    ldy       M$Size,x            Get module size again (including CRC)
                    lda       #2                  Path 2 for file
                    os9       I$Write             Write out entire module
                    lda       #%11000000          Packed & CRC just made flags
                    sta       <$17,x              Save them
                    lbcs      CloseAndErr               If error on write, go deal with it
                    puls      y             Retrieve procedure list ptr
DUMP04               ldx       ,--y
                    lbne      DumpProcLoop         Repeat until there are no more
                    lbra      CLSCHL               Go close file, reopen path from <BE, rts from there

DEFILE               bsr       PCDLST
                    lda       ,y                  Get char
                    cmpa      #C$CR               Is it CR?
                    bne       SetXToLine               No, point X to it & return
                    ldx       <SubrStkPtr              Get ???
                    ldx       [<-2,x]       get 1st procedure in list
                    ldd       M$Name,x            Get offset to module name
* (orig: DEFIL1)
                    leax      d,x                 Point X to module name
                    lbsr      CopyNameToBuf               Go set up temp buffer with name
                    lbsr      AppendCR               Append CR to end of temp buffer
SetXToLine               leax      ,y
                    rts

PCDLST               ldu       <SubrStkPtr              Get table end ptr
                    stu       <StrSpaceTop              Save as current table ptr
                    lbsr      SkipSepChar               Go get char (bump y past it if , or space)
                    beq       PCDLS3               If comma or space, skip ahead
                    cmpb      #'*                 Is it a '*'?
                    bne       PCDLS4               No, skip ahead
                    ldx       <ModListPtr              Get ptr to workspace module ptr list
PCDLS1               ldd       ,x                  Get 1st possible entry
                    beq       PCDLS2               Empty, skip ahead
                    tfr       x,d                 Move ptr to D
                    leax      2,x                 Bump ptr up to next entry
PCDLS2               std       ,--u                Save entry
                    bne       PCDLS1         Repeat if not end marker
                    stu       <StrSpaceTop              Save new ptr
                    lda       ,y                  Get char from temp buffer
                    cmpa      #C$CR               CR?
                    beq       PCDL25               Yes, save ptr & return
                    leay      1,y                 No, bump ptr up by 1
PCDL25               sty       <TmpBufCur              Save current pos in temp buffer & return
                    rts

PCDLS3               lbsr      Vect2Fn2               JSR <JmpVect2, function 2
                    bne       FindNameInDir         ..yes; go get em
PCDLS4               sty       <TmpBufCur              Save current pos in temp buffer
                    lbsr      DEFPRC               Point Y to Name of current module (or 'Program')
                    lbsr      DIRSCH               Go check if module exists in BASIC09 workspace
                    bcc       PCDLS5               Yes, skip ahead
PCDLSR               lbra      CMDSEP               No, return with Unknown Procedure error

FindNameInDir               lbsr      DIRSCH               Check if module exists in BASIC09 workspace
                    bcs       PCDLSR               No, return Unknown Procedure error
                    sty       <TmpBufCur              Save Ptr to end of fname as current pos in tmp buf
PCDLS5               stx       ,--u                Save ptr to start of module name
                    ldy       <TmpBufCur              Get Ptr to end of filename
                    lbsr      SkipSepChar               Point Y to next char (or past ',' or space)
                    bne       PCDLS6               Not comma or space, skip ahead
                    lbsr      Vect2Fn2               JSR <JmpVect2, function 2
                    bne       FindNameInDir         ..yes; repeat
PCDLS6               clra
                    clrb                    End mark on opstack
                    bra       PCDLS2         Push it and return

SAVE               tst       <WorkspaceFree              >256 bytes free for user?
                    lbeq      ERMFUL               No, exit with Memory Full error
                    lda       #$80                Set hi-bit flag
                    sta       <PackedFlag
                    bsr       DEFILE         get procedure list, pathname
                    bra       SaveToPath

PrepSavePath               bsr       PCDLST
                    leax      ,y            get I/O ptr (pathname)
SaveToPath               stx       <ICodeCurPtr
                    bsr       OPNCHL         Open output path
                    ldy       <SubrStkPtr        get top of list
                    stu       <SubrStkPtr        Carve out opstack space used
                    bra       NextProcEntry

ListProcEntry               pshs      y
                    ldy       [,y]          get procedure addr
                    sty       <CurModPtr              Save as current module ptr
                    ldd       M$Exec,y            Get exec offset
                    addd      <CurModPtr              Add to start of current module
                    std       <ModExecAddr              Save absolute exec address of current module
                    ldd       $0F,y               Get ???
                    addd      <CurModPtr              Add to start of current module
                    std       <ModFOff              Save this absolute address
                    ldd       $0D,y               Get ???
                    addd      <CurModPtr              Add to start of module
                    std       <ModSymTbl              Save this absolute address
                    tst       M$Type,y            Check type of module
                    bne       RestoreYCont               If anything but unpacked BASIC09, skip ahead
                    leax      <CheckPackErrors,pc           Point to routine
                    lbsr      SETEXT               ??? The <ExitStkPtr stack swap
                    lbsr      ListCmd               ??? DEBUG list command
ExitViaExit               lbra      EXIT               Restore <ExitStkPtr, reset temp buff

CheckPackErrors               tst       <PackedFlag              Test flags
                    bmi       RestoreYCont         ..yes; don't produce error list
                    ldx       [,s]          restore directory ptr
                    lbsr      UnbindSetupMod         Unbind procedure
                    lbsr      Vect3Fn2         Rebind it (show errors)
RestoreYCont               puls      y
NextProcEntry               ldx       ,--y
                    bne       ListProcEntry
OPEXIT               bsr       CLSCHL
                    bra       ExitViaExit         then exit (no error)

CLSCHL               pshs      b                   Preserve B
                    lda       #2            close current command path
                    os9       I$Close             Close path #2 (error)
                    lda       <ErrDupPath              Get Duplicate error path #
                    os9       I$Dup               Dupe the path
                    puls      pc,b                Restore B & return

OPNCHL               lbsr      SkipSepChar               Point Y to next char (or past ',' or space)
                    cmpb      #C$CR               Was it a CR?
                    beq       OPNC99               Yes, skip ahead
                    stx       <TmpBufCur              Save current pos in temp buffer
* (orig: OPNCH1)
                    ldd       #$020B              Write access mode & pr r w attributes
* Create output file
* Entry: A=access mode
*        B=file attributes
*        X=Ptr to filename to create
OPNCH0               pshs      u,x,d               Preserve regs
                    lda       #$02                Close std error path
                    os9       I$Close       eliminate output path
                    ldd       ,s                  Get access mode & file attributes back
                    os9       I$Create            Attempt to create the file
                    bcc       OPNC90               Did it, skip ahead
                    cmpb      #E$CEF              File already exists error?
                    bne       CloseAndErr               No, skip ahead
                    ldd       ,s                  Get access modoe & file attributes again
                    ldx       2,s                 Get ptr to filename again
                    os9       I$Open              Attempt to open the file
                    bcs       CloseAndErr               User not allowed to access, skip ahaead
                    leax      >RewriteStr,pc           Point to 'Rewrite?:'
                    ldy       #10                 Size of rewrite string
                    lda       <ErrDupPath              Get error path #
                    os9       I$WritLn            Prompt user
                    clra                    Std input path
                    leax      ,--s                Make 2 byte buffer on stack
                    ldy       #2                  Get up to 2 chars from user
                    os9       I$ReadLn
                    puls      d                   Get chars from read buffer
                    eora      #$59                Check for Y
                    anda      #$DF                Force case
                    bne       OPEXIT               User didn't hit Y or y, exit
                    ldd       #2*256+SS.Size      Path #2, set file size call
                    ldx       #0                  Set size to 0 bytes
                    leau      ,x
                    os9       I$SetStt            Truncate file size to 0 bytes
                    bcs       CloseAndErr               If error, skip ahead
OPNC90               puls      pc,u,y,d            Restore regs & return

OPNC99               rts

CloseAndErr               bsr       CLSCHL               Close & dupe error path
                    lbra      PrintErrExit               Print error

* Reset temp buffer to empty state
ResetTmpBuf               pshs      d                   Preserve D
                    lda       #1                  # chars in buffer to 1
                    sta       <TmpBufCount              Save it
                    ldd       <TmpBufBase              Get ptr to temp buffer
                    std       <TmpBufCur              Save it as current pos in temp buffer
                    puls      pc,d                Restore D & return

* Get program name (with hi-bit on last char set + CR), pointed to by Y
*   Will be one of following:
*     1) Name pointed to by Y on entry
*     2) Name of 'current' module in BASIC09 workspace
*     3) 'Program' if neither of the above
INTERP               lbsr      Vect2Fn2               <1E,func. 2 (Get string size/make FCS type if var name)
                    bne       INTER1               There is >0 chars that qualify as name, skip ahead
                    pshs      y                   Save ptr to string name in question
* NOTE: MAY WANT TO CHANGE ENTRY POINT, SINCE GetProcName CALLS Vect2Fn2 AGAIN
                    lbsr      GetProcName               Get ptr & size of name, or use current (or 'Program')
                    ldx       ,s                  Get ptr to string name in question again
INTER0               lda       ,y+                 Get char from name we _will_ use
                    sta       ,x+                 Save over top of string name in question
                    bpl       INTER0               Copy whole string (including last hi-bit byte)
                    lda       #C$CR               Append CR to end
                    sta       ,x
                    puls      y                   Point to beginning of new string
INTER1               lbsr      DIRLNK               Y=Ptr to end of string+1, X=Ptr to module ptr entry
                    lbcs      CMDSEP               Module not in workspace, exit with Unknown Procedure
                    ldx       ,x                  Get ptr to module
                    stx       <CurModPtr              Save as 'current module'
                    lda       M$Type,x            Get type/language byte
                    beq       INTE30               If type & language are 0, skip ahead
                    anda      #LangMask           Just want language type
                    cmpa      #ICode              BASIC09 I-Code?
                    bne       ERABRT               No, Line With Compiler Error
                    bra       PrepInterp               Yes, skip ahead

Vect2Fn0               jsr       <JmpVect2
                    fcb       $00

Vect3Fn0               jsr       <JmpVect3
                    fcb       $00

* Type/Language byte of 0
INTE30               lda       <$17,x              Get flags from module
                    rora                          Shift out Line with Compiler error flag
                    bcs       ERABRT               There is an error, report it
* Current module has no obvious errors
PrepInterp               bsr       Vect2Fn0               <1E, fnc. 0 (1F9E normally) (do token?)
                    ldy       <ICodeEndPtr              Get ptr to end of currently used I-code workspace
                    ldb       ,y                  Get last char/token in workspace
                    cmpb      #'=                 Is it an = sign?
                    beq       ERABRT
                    sty       <ModExecAddr
                    sty       <ICodeCurPtr
                    ldx       <ICodeLineEnd              Get ptr to current I-code line end
                    stx       <ModFOff
                    stx       <ICodeEndPtr              Make it ptr to end of in use I-code workspace
                    ldd       <WorkspaceFree              Get # bytes free in workspace for user
                    pshs      y,d
                    bsr       Vect3Fn0
                    puls      y,d
                    std       <WorkspaceFree              Save # bytes now free in workspace for user
                    sty       <ICodeEndPtr              Save updated end of I-code workspace ptr
                    ldx       <CurModPtr              Get ptr to current module
                    lda       <$17,x              Get flag byte
                    rora                          Shift out Line with Compiler error flag bit
                    bcs       ERABRT               Compiled line has error, report it
                    leas      >$0102,s            Eat 258 bytes from stack ???
                    ldd       <DpBase              Get start of data mem ptr
                    addd      <DataAreaSz              Add to Size of data area
                    tfr       d,y                 Move end of data area ptr to Y
                    std       <SubrStkPtr              Save it
                    std       <StrSpaceTop
                    ldu       #$0000
                    stu       <VarStorePtr
                    stu       <DebugStepCnt              # steps per run through program (0=continuous)
                    inc       <DebugStepCnt+1            Set # steps to 1
                    clr       <ErrCode              Clear out last error code
                    ldd       <ICodeEndPtr              Get ptr to next free byte in I-code workspace
                    ldx       <WorkspaceFree              Get # bytes free in workspace for user
                    pshs      x,d                 Save them
                    leax      <INTRTS,pc           Point to routine
                    lbsr      SETEXT
                    ldx       <ICodeEndPtr              Get ptr to next free byte in I-code workspace
                    bsr       Vect4Fn4
                    lbsr      ResetTmpBuf
                    ldx       <CurModPtr              Get ptr to start of current module
                    bsr       Vect4Fn2
                    bra       INTER9         Return

Vect4Fn4               jsr       <JmpVect4
                    fcb       $04

Vect4Fn2               jsr       <JmpVect4
                    fcb       $02

INTRTS               puls      x,d                 Restore bytes free in workspace & ptr to next free
                    std       <ICodeEndPtr              Save old next free byte in I-code workspace
                    stx       <WorkspaceFree              Save old # bytes free in workspace for user
INTER9               lbra      EXIT

ERABRT               ldb       #$33                Line with compiler error
                    lbra      PrintErrExit               Go report it

* System mode - BYE
BYEBYE               bsr       KILALL
                    clrb                          Exit without error
                    os9       F$Exit

KILLEX               lbsr      Vect2Fn2
                    beq       KILERR         ..no; error
                    lbsr      DIRSCH
                    bcs       KILERR         ..error; return it
                    ldu       <SubrStkPtr

                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc

                    pshu      x,d           build procedure list stack
                    inca
                    sta       <LastSignal        signal killer: external only
                    bsr       KILL0
                    clr       <LastSignal
                    rts

KILERR               comb                          Set carry for error
                    ldb       #$2B                Divide by 0 error
                    rts

KILALL               ldy       <TmpBufCur              Get ptr to current pos in temp buffer
                    lda       #$2A                '*'
                    sta       ,y                  Save in temp buffer
                    sta       <LastSignal              Save as last signal received
KILLER               lbsr      PCDLST
                    clr       <CurModPtr              Clear out ptr to start of 'current' module
                    clr       <CurModPtr+1
KILL0               ldu       <SubrStkPtr              Get default ??? tbl ptr
                    stu       <StrSpaceTop              Save as current ??? tbl ptr
                    bra       KILL2         For each member of list, do

KILL1               ldx       ,x                  Get ptr to module
                    ldb       M$Type,x            Get module type
                    beq       KILL15               If nothing (un-compiled or errors?), skip ahead
                    cmpb      #Sbrtn+ICode        Basic09 I-Code?
                    bne       KILL12               No, skip ahead
                    ldb       <$17,x              Get I-Code flag byte
                    lslb                          Shift out the packed bit
                    bmi       KILL15               If (CRC just made?) flag set, skip ahead
KILL12               pshs      u                   Preserved U
                    leau      ,x                  Point U to module start
                    os9       F$UnLink            Unlink the I-Code module
                    puls      u                   Restore U
                    bra       ZapDirEntry         Zap directory entry

KILL15               tst       <LastSignal              Any signal code?
                    bne       KILL2               Yes, skip ahead
                    ldx       ,u                  No, get ptr to module
                    lbsr      SHUFLE               Go remove it from workspace pointers (?)
                    ldy       ,x                  Get ptr to module again
                    ldd       <ICodeUsed              Get current total size of used I-Code space
                    subd      M$Size,y            Subtract deleted module's size
                    std       <ICodeUsed              Save new size of used I-Code space
                    ldd       M$Size,y            Get size of module being removed
                    addd      <WorkspaceFree              Add to bytes free in I-Code space
                    std       <WorkspaceFree              Save new # bytes free in I-Code space
* (orig: KILL18)
                    ldd       <ICodeEndPtr              Get ptr to end of used I-Code space+1
                    subd      M$Size,y            Bump it back to not include the deleted module
* (orig: KILL4)
                    std       <ICodeEndPtr              Save new ptr to where next added I-Code goes
ZapDirEntry               ldd       #$FFFF              Module ptr unused marker
                    std       [,u]                Mark it
* Compress list of modules in I-Code workspace (get rid of all deleted ones)
KILL2               ldx       ,--u                Get previous module ptr
                    bne       KILL1               There is one, go remove it too
                    ldx       <ModListPtr              Get ptr to list of modules is I-Code workspace
                    tfr       x,y                 Move it to Y
KILL3               ldd       ,x++                Get module ptr
                    cmpd      #$FFFF              Unused one?
                    beq       KILL3               Yes, try next
CompressModList               std       ,y++                Save it
                    bne       KILL3               Until a $0000 is hit
                    cmpd      ,y                  Is the next entry a 0 too?
                    bne       CompressModList               No, keep Storing until we hit a 0
                    rts                           Otherwise, return

DIRADD               bsr       DIRSCH
                    bcs       DIRA00         Return if found
                    rts

* Set up module header info?
DIRA00               pshs      u,x
                    tfr       x,d           get directory entry
                    cmpb      #$FE          Is it the last
                    beq       ERMFUL         ..yes; error - memory full
* (orig: DIRAD0)
                    ldx       <WorkspaceFree              Get # bytes free in I-Code workspace for user
                    cmpx      #$00FF              <255 bytes left free?
                    blo       ERMFUL               Yes, skip ahead
                    leax      <-$1C,x             Bump # bytes free down by 28 bytes
                    ldu       <ICodeEndPtr              Get ptr to current I-code line start
* Clear out entire header of packed RUNB module
* 6809/6309 mod: should use sta (after clra) instead of clr b,u
* Wait until ERMFUL is checked-does it need A?
                    ldb       #$FF                Pre-init B for loop below
DIRAD1               incb                          Next position
                    clr       b,u                 Clear byte
                    cmpb      #$18                Done all $18 bytes?
                    bne       DIRAD1               No, keep going
* Copy module name to $19
CopyNameLoop               incb                          Bump B to $19
                    leax      -1,x                Bump X back
                    beq       ERMFUL               If hit 0, exit with memory full error
                    inc       $18,u               Bump up module name size to 1
                    lda       ,y+                 Get char from source (module name)
                    sta       b,u                 Save it
                    bpl       CopyNameLoop               Do until hi-bit terminated
                    incb                          Bump B to 1 byte past module name (start of I-code)
                    stx       <WorkspaceFree              Save # bytes left free in I-Code workspace
                    clra                          MSB of D=0
                    std       $15,u               ???
                    std       M$Exec,u            Save ptr to execution offset
                    std       $F,u                ???
                    stu       [,s]          Store addr of new procedure there
                    pshs      b             Temp save b
                    addd      #$0003              Add 3 to size of module so far (for CRC)
                    std       M$Size,u            Save as current size of module
                    std       $D,u                ??? (Size of I-code ???)
                    addd      <ICodeUsed              Add size to total # bytes used by I-Code
                    std       <ICodeUsed              Save new # bytes used by I-Code
                    ldd       #M$ID12             Module header code
                    std       M$ID,u              Save as module header
                    ldd       #$0019              Ptr to where module name will be
                    std       M$Name,u            Save as module name ptr
                    ldd       #$0081              Type/Lang.=0 (internal to BASIC09)/Sharbl Rev.1
                    std       M$Type,u
                    ldd       #$0016              Minimum data area size=22 bytes
                    std       M$Mem,u
                    puls      b                   Get offset to just past module name back
                    leax      d,u                 Point X to just after filename
                    ldb       #$03                Add $000003 to end
                    sta       ,x+
                    std       ,x++          Initialize procedure's symbol table
                    stx       <ICodeEndPtr              ??? Save end of module ptr?
                    puls      pc,u,x              Restore regs & return

ERMFUL               ldb       #$20                BASIC09 memory full error (or too many modules)
                    lbra      PrintErrExit

* Entry: Y=Ptr to module name
* Exit:  D=Ptr to string/file name
*          Carry set if adding new module to module list
*          Carry clear if replacing existing module in module list
*        X=Ptr to module directory entry we are adding/changing
*        Y=Ptr to end of filename+1
DIRSCH               pshs      u,y                 Preserve regs
                    ldx       <ModListPtr              Get ptr to list of modules in BASIC09 workspace
DIRSC0               ldy       ,s                  Get ptr to string we are checking for
                    ldu       ,x++                Get ptr to module in workspace
                    beq       DIRSC9               None left to check, exit with carry set
                    ldd       M$Name,u            Get offset to name
                    leau      d,u                 Point to name of module
DIRSC2               lda       ,y+                 Get char from name we are looking for
                    eora      ,u+           Is it the same as that in the directory?
                    anda      #$DF                Force case
                    bne       DIRSC0               Doesn't match, try next module
                    clra                          Clear carry (module found)
                    tst       -1,u                Was it the last char in existing module name?
                    bpl       DIRSC2               No, keep checking
DIRSC3               leax      -2,x                Point X to module ptr entry change (or add from F8E)
                    puls      pc,u,d              Restore U, get string ptr into D & exit

DIRSC9               coma                          Set carry (flag new module being added)
                    bra       DIRSC3               Point to module ptr entry we are going to add

* Check if module is in BASIC09 workspace, try to add if it isn't
* Entry: Y=Ptr to module name to look for (hi-bit terminated with CR on end)
* Exit:  Carry clear if module in workspace
*        Carry set if module NOT in workspace
*        X=Ptr to module ptr entry ($400-$4FF) where module was found
*        D=Ptr to module name
*        Y=Ptr to last char of module name+1
DIRLNK               bsr       DIRSCH               Go see if we should add or replace module
                    bcs       DIRLN1               Adding new module, skip ahead
                    rts                           Replacing, exit

* Module not found currently in BASIC09 workspace... try to F$Link or F$Load
*   it in.
* Entry: X=Ptr to 1st free module directory entry in BASIC09 workspace
*        Y=Ptr to module name to add
* Exit:  Carry set & B=error code if still can't link module into workspace
*        Carry clear if linked in
*        Module ptr directory updated with new module
*        Y=Ptr to end of module name+1
*        X=Ptr to module directory entry
DIRLN1               pshs      u,y,x               Preserve regs
                    ldb       1,s                 Get LSB of module directory ptr
                    cmpb      #$FE                At end of table?
                    beq       ERMFUL               Yes, exit with Memory full error (too many modules)
                    leax      ,y                  Point X to module name
                    clra                          Type/language=wildcard (don't care)
                    os9       F$Link              See if it's already in memory & map it in
                    bcc       DIRLN2               Yes, mapped in so skip ahead
                    ldx       2,s                 Get ptr to Module name again
                    clra                          Type/language=wildcard (don't care)
                    os9       F$Load              Try loading it & linking it in
                    bcs       DIRLN9               Error, exit with it
DIRLN2               stx       2,s                 Save ptr to last byte of module name+1 in Y
                    stu       [,s]                Save ptr to module in module ptr entry
DIRLN9               puls      pc,u,y,x            Restore regs & return

* Entry: X=Ptr to module copy we are putting in I-Code workspace (at end of it)
*        Y=???
* Exit:  X=Ptr to where module was moved to
SHUFLE               pshs      y,x                 Preserve regs
                    ldd       <ICodeBase              Get ptr to start of I-Code workspace
                    addd      <ICodeUsed              Add to total size of used I-Code workspace
                    tfr       d,y                 Move ptr to end of I-Code workspace to Y
                    ldx       ,x                  Get ptr to module we are adding to I-Code workspace
                    sty       [,s]                Save ptr to where it is going over old one on stck
                    ldd       M$Size,x            Get size of module we are adding
                    bsr       FLOTUP         "FLOAT" it up to bottom of free space
                    pshs      y,x,d
                    ldx       <ModListPtr              Get ptr to list of modules in BASIC09 workspace
                    bra       SHUFL2

SHUFL1               cmpd      2,s
                    blo       SHUFL2
                    cmpd      4,s           Above the one just shuffled up (external)?
                    bhi       SHUFL2         ..yes
                    subd      ,s            Adjust directory entry of each procedure that was moved down
                    std       -2,x
SHUFL2               ldd       ,x++                Get possible module ptr
                    bne       SHUFL1               Found one, process
                    leas      6,s                 No more modules, eat stack
                    puls      pc,y,x              Restore & return

* Entry: D=Size of module being added to I-Code workspace
*        X=Ptr to source of I-code module being added into I-Code workspace
*        Y=Ptr to destination of new I-Code module
*        U=???
* After PSHS below, stack is thus:
*  0,s = Size of module being added to I-Code buffer
*  2,s = Ptr to current location of I-Code
*  4,s = Ptr to destination of I-Code
*  6,s = Old U ???
*  8,s = RTS address
FLOTUP               pshs      u,y,x,d             Preserve regs
                    ldu       #$0000              Init counter to 0
                    tfr       x,d                 Move source ptr to D
                    subd      4,s                 D=distance between source & destination
                    pshs      x,d                 Preserve Source ptr & distance
*  0,s = Distance between source & destination (signed)
*  2,s = Work copy of ptr to current location of I-Code
*  4,s = Size of module being added to I-Code buffer
*  6,s = Ptr to current location of I-Code
*  8,s = Ptr to destination of I-Code
* 10,s = Old U ???
* 12,s = RTS address
                    addd      4,s                 D=distance between src & dest + size of module
                    beq       FloatUpDone               If result=0 then restore regs & return
FLOTU1               lda       ,x                  Get 1st byte of source copy
                    pshs      a                   Save on stack
*  0,s = 1st byte from source copy
*  1,s = Distance between source & destination (signed)
*  3,s = Work copy of ptr to current location of I-Code
*  5,s = Size of module being added to I-Code buffer
*  7,s = Ptr to current location of I-Code
*  9,s = Ptr to destination of I-Code
* 11,s = Old U ???
* 13,s = RTS address
                    bra       FloatUpCalc

FLOTU3               lda       ,y                  Get byte from source location
                    sta       ,x                  Save in destination location
                    leau      1,u                 Bump counter up
                    tfr       y,x                 Move source location to dest location
FloatUpCalc               tfr       x,d                 ??? Move src ptr to D
                    addd      5,s                 Add to size of module
                    cmpd      9,s                 Compare with dest. address
                    blo       FloatUpCont               Fits, skip ahead
                    addd      1,s                 Won't, add to distance between src/dest
FloatUpCont               tfr       d,y                 Move end address (?) to Y
                    cmpd      3,s                 Same as current location?
                    bne       FLOTU3               No, go bck
                    puls      a
                    sta       ,x            [moveto]=savebyte
                    leax      1,y
                    stx       2,s           Update lowmem
                    leau      1,u           Bytecnt=bytecnt+1
                    tfr       u,d
                    addd      ,s            Total number of bytes moved?
                    bne       FLOTU1         ..no; keep moving
FloatUpDone               leas      4,s                 Eat temp vars
                    puls      pc,u,y,x,d          Restore regs & return

* Enter Debug mode?
EnterDebug               pshs      u,y,x,d
                    lda       <ErrCode              Get last error code
                    cmpa      #$39                System stack overflow error?
                    beq       QuitDebug               Yes, skip ahead
                    tst       <BreakFlag              ??? Some flag set?
                    bne       ExitDebugMode               Yes, skip ahead
                    inc       <BreakFlag              Set flag
                    lda       <LastSignal              Get last signal received
                    bne       CheckAbortSig               Was a signal, skip ahead
                    ldd       <DebugStepCnt              Get # steps to do @ a time for trace
                    subd      #1                  Bump down by 1
                    bhi       StepAndCont               Was >1, skip ahead
                    bmi       DebugCmdLoop               Was 0 or lower, skip ahead
PrintBreak               lbsr      ResetTmpBuf
                    leax      >AlphaModeCode,pc           Force to Alpha mode (if VDG window) & print BREAK
                    lbsr      CopyNameToBuf
                    lbsr      PrintProcKwd
* Debug mode command loop
DebugCmdLoop               leax      >DebugPrompt,pc           Point to 'D:'
                    leay      >DbgCmdDollar,pc           Point to start of debug command table
                    lbsr      RUNCMD               Go process debug mode command
                    bcc       DebugCmdLoop               Legit cmd executed, get next debug mode cmd
                    lda       <LastSignal              Get last signal received
                    bne       CheckAbortSig               There was one, go check for abort
                    lbsr      CMDERR               None, print 'What?'
                    bra       DebugCmdLoop               Go process next debug mode command

Vect4FnC               jsr       <JmpVect4
                    fcb       $0C

CheckAbortSig               cmpa      #S$Abort            <CTRL>-<E> signal?
                    bne       PrintBreak               No, enter debug mode
* Debug 'Q' command (quite debug)
QuitDebug               bsr       Vect4FnC
                    lda       #$03                Error path #3 we will check for
ClosePathLoop               cmpa      <ErrDupPath              Compare with I$Dup error path #
                    beq       NextClsPath               If not path we are looking for, skip ahead
                    os9       I$Close             Same path, close it
NextClsPath               inca                          Next path
                    cmpa      #16                 Done all 16 possible?
                    blo       ClosePathLoop               No, keep going
                    lbra      EXIT               Done, reset temp buffers & ptrs to defaults

* Debug STEP command
* Entry: Y=Ptr to next char on line entered by user
StepCmd               lbsr      SkipSepChar               Go check next char in STEP command
                    bne       StepRateOne               If anything but space or comma, STEP 1
                    leax      ,y                  Otherwise, point X to ASCII of steps specified
                    lbsr      EvalNumExpr               Go get # steps to do into D
                    bcc       SaveStepCnt               No error, continue
                    rts                           Else exit

StepAndCont               bsr       SaveStepCnt
* Debug mode <CR> goes here (single step)
DebugSingleStep               clrb
                    bra       SetStepRate

StepRateOne               ldb       #1                  Step rate of 1
SetStepRate               clra
SaveStepCnt               std       <DebugStepCnt              Save # steps to do
                    lsl       <SigFlag              Set high bit of signal flag
                    coma
                    ror       <SigFlag
                    bra       ClearBreakCont               Continue

* Debug mode CONT command (continuous run)
ContCmd               lbsr      ResetTmpBuf               Reset temp buffer stuff
                    lsl       <SigFlag              Clear high bit of signal flag
                    lsr       <SigFlag
                    ldd       #$0001              1 step till we print out
                    std       <DebugStepCnt              Save it
ClearBreakCont               leas      2,s
                    clr       <BreakFlag
ExitDebugMode               puls      pc,u,y,x,d

CallEvalSetup               ldy       <EvalSetup
                    jsr       ,y
PrintTraceInfo               pshs      u,y,x,d
                    cmpy      <SubrStkPtr              ?? Get current pos in some table
                    beq       TraceInfoDone               If no entries, exit
                    ldb       <TmpBufCount              Get size of temp buff
                    ldx       <TmpBufBase              Get ptr to start of temp buff
                    ldu       <TmpBufCur              Get ptr to end of temp buff+1
                    pshs      u,x,b               Preserve
                    stu       <TmpBufBase              Temporarily set up temp buff to append to current
                    lbsr      ResetTmpBuf
                    lda       #'=                 Append '=' to temp buff
                    lbsr      AppendChar
                    ldb       ,y
                    addb      #$01
                    cmpb      #$06
                    bhs       PrintTraceLine
                    leax      ,y
                    lbsr      PrintReal
PrintTraceLine               lbsr      AddCrPrint
                    puls      u,x,b               Get back temp buff stats
                    stb       <TmpBufCount              Restore temp buff to normal
                    stx       <TmpBufBase
                    stu       <TmpBufCur
TraceInfoDone               puls      pc,u,y,x,d          Restore regs & return

* Debug LIST command
ListCmd               lbsr      PrintProcHdr               Go print PROCEDURE & name
                    tst       <$17,x              Is procedure packed?
                    bmi       ListLineDone               Yes, exit without error
                    ldx       <ModExecAddr
ClearIndent               clr       <IndentDepth
* List out each line loop
ListLineLoop               tst       <LastSignal              Any signals?
                    bne       ListLineDone               Yes, exit without error (Can't list packed modules)
                    leay      ,x                  Point Y to beginning of I-Code module
                    lbsr      ScanNextToken
                    bsr       PrintICodeLine
                    exg       x,y
                    cmpx      <ModFOff
                    blo       ListLineLoop
                    cmpx      <ICodeCurPtr
                    bne       ListLineDone
                    cmpy      <ModFOff
                    blo       ListLineLoop
ListLineDone               clra                          No error & return
                    rts

Vect3Fn6               jsr       <JmpVect3
                    fcb       $06

PrintICodeLine               pshs      u,y,x               Preserve regs
                    lbsr      ResetTmpBuf               Reset temp buffer to empty
                    ldx       <CurModPtr              Get current module ptr
                    tst       <$17,x              Is it packed?
                    bmi       PrintLineRet               Yes,  restore regs & exit
                    ldx       ,s                  Get original X back
                    tfr       y,d
                    subd      ,s
                    bmi       PrintLineDone               Wrap to negative?
                    pshs      x,d
                    addd      #40                 If we needed 64 bytes...
                    cmpd      <WorkspaceFree              would it fit in BASIC09 workspace?
                    lbhs      ERMFUL               No, return with BASIC09 memory full error
                    tst       <PackedFlag
                    bmi       PrintLineElse
                    lda       #C$SPAC
                    cmpx      <ICodeCurPtr
                    bhi       AppendStarCharX
                    beq       AppendStarChar
                    cmpy      <ICodeCurPtr
                    bls       AppendStarCharX
AppendStarChar               lda       #'*                 Append '*' to temp buffer
AppendStarCharX               lbsr      AppendChar               Go append it
                    cmpx      <ModFOff
                    bhs       PrintLineElse
                    tfr       x,d
                    subd      <ModExecAddr
                    ldx       <TmpBufCur              Get current pos. in temp buffer
                    bsr       Vect3Fn6               JSR <JmpVect3 / function 6
                    lda       #C$SPAC             Append space to temp buffer
                    sta       ,x+
                    stx       <TmpBufCur              Save update temp buff ptr
                    lbsr      PrintTmpBuf               Print message out
PrintLineElse               puls      y,d
                    cmpy      <ModFOff
                    bhs       PrintLineDone
                    ldu       <ICodeEndPtr
                    lbsr      CopyVarBlock
                    lbsr      SaveWorkSpc
                    stu       <ICodeCurPtr
                    leax      d,u
                    stx       <ModFOff
                    stx       <ICodeEndPtr
                    leay      ,u
                    tst       <PackedFlag
                    bmi       PrintLineErr
                    leax      ,y
                    lbsr      CheckLineEnd
                    bne       PrintLineErr
                    leax      >KwErr,pc           Point to 'ERR' in basic09 commands
                    lbsr      PrintXThenBuf               Print it out??
PrintLineErr               lbsr      ResetTmpBuf
                    lbsr      ScanICodeLoop
                    lbsr      DecodeICode
                    bsr       RestoreWorkSpc
                    dec       <TmpBufCur+1
PrintLineDone               lbsr      AddCrPrint
PrintLineRet               puls      pc,u,y,x

* Debug mode - PRINT/TRON/TROFF/DEG/RAD/LET commands
CheckPackedPt               ldx       <CurModPtr              Get ptr to start of 'current' module
                    tst       <$17,x              Is it packed?
                    bpl       PrintFromBuf               No, skip ahead
                    coma                          Yes, set carry & return
                    rts

PrintFromBuf               ldy       <TmpBufBase              Get ptr to start of temporary buffer
                    lbsr      Vect2FnA               JSR <1E, function $A
                    bsr       SaveWorkSpc
                    ldx       <ICodeEndPtr
                    lbsr      CheckLineEnd
                    beq       RestoreWorkSpc
                    stx       <ModExecAddr
                    stx       <ICodeCurPtr
                    leay      ,x
                    ldx       <ICodeLineEnd
                    stx       <ModFOff
                    stx       <ICodeEndPtr
                    bsr       Vect3Fn4
                    ldx       <CurModPtr              Get ptr to current module
                    lda       <$17,x              Get original flags
                    clr       <$17,x              Clear flags out
                    tsta                          Were the flags special in any way?
                    bne       RestoreWorkSpc               Yes, skip ahead
                    leax      <RestoreWorkSpc,pc           No, point to the routine instead
                    lbsr      SETEXT
                    ldx       <ModExecAddr
                    bsr       Vect4Fn8               JSR <$24, function 8
                    lbra      EXIT               Swap stacks, reset temp buffer, return from there

Vect3Fn4               jsr       <JmpVect3
                    fcb       $04

Vect4Fn8               jsr       <JmpVect4
                    fcb       $08

RestoreWorkSpc               pshs      u,y,x,d             Preserve regs
                    ldu       <SubrStkPtr              Get reset value ($300) table ptr
                    pulu      y,x,d               Get regs from there
                    sty       <ICodeUsed              Save # bytes used by all code in workspace
                    stx       <WorkspaceFree              Save # bytes free in workspace
                    std       <ICodeEndPtr              Save ptr to next free byte in workspace
                    pulu      y,x,d               Get 6 more bytes
                    sty       <ModFOff
                    stx       <ModExecAddr
                    std       <ICodeCurPtr
SaveSubrStkPt               stu       <SubrStkPtr
                    stu       <StrSpaceTop
                    clra                          No error,restore regs & return
                    puls      pc,u,y,x,d

SaveWorkSpc               pshs      u,y,x,d
                    ldu       <SubrStkPtr
                    ldd       <ICodeCurPtr
                    ldx       <ModExecAddr
                    ldy       <ModFOff
                    pshu      y,x,d
                    ldd       <ICodeEndPtr
                    ldx       <WorkspaceFree
                    ldy       <ICodeUsed
                    pshu      y,x,d
                    bra       SaveSubrStkPt

* Debug mode - STATE command
StateCmd               ldy       <VarStorePtr
                    leax      >ProcedureStr,pc           Point to 'PROCEDURE'
PrintCallEntry               bsr       ResetOutBuf
                    lbsr      CopyNameToBuf
                    ldx       3,y
                    bsr       PrintModName
                    leax      <CalledByStr,pc           Point to 'called by'
                    ldy       7,y
                    bne       PrintCallEntry
ResetOutBuf               lbra      ResetTmpBuf

CalledByStr               fcs       'called by'

* Debug mode - BREAK command
BreakCmd               lbsr      Vect2Fn2               JSR <1E, function 2
                    beq       BreakCmdErr
                    lbsr      DIRSCH
                    bcs       BreakCmdErr
                    ldx       ,x
                    ldy       <VarStorePtr
SearchCallStk               ldy       7,y
                    beq       BreakCmdErr
                    cmpx      3,y
                    bne       SearchCallStk
* 6309, change to OIM #1,,y
                    lsl       ,y                  Set hi bit @ Y
                    coma
                    ror       ,y
                    leax      >OkStr,pc           Point to 'ok'
                    bra       PrintXToStderr

BreakCmdErr               coma
                    rts

PrintProcHdr               bsr       ResetOutBuf
PrintProcKwd               leax      >ProcedureStr,pc           Point to 'PROCEDURE'
                    lbsr      CopyNameToBuf
                    ldx       <CurModPtr              Get ptr to current module
PrintModName               pshs      x                   Save it
                    leax      <$19,x              Point to main code area
                    bsr       CopyAndPrint
                    puls      pc,x

* Copy string pointed to by X to temp buffer & print it to std error
PrintXToStderr               bsr       ResetOutBuf               Set output txt size to 1, curr. temp buff pos=start
CopyAndPrint               lbsr      CopyFcsToBuf               Copy text string to temp buffer @ [TmpBufBase]
AddCrPrint               lbsr      AppendCR               Append a CR on the end of output buffer
                    bsr       PrintTmpBuf               Print out the buffer to std error
                    bra       ResetOutBuf               Reset temp buffer size & ptrs to defaults & return

PrintXThenBuf               bsr       ResetOutBuf
                    lbsr      CopyFcsToBuf
* Print message in temp buffer to std error path
* NOTE: MAY WANT TO CHECK INTO USING <7D FOR SIZE
PrintTmpBuf               pshs      y,x,d               Preserve regs
                    ldd       <TmpBufCur              Get ptr to end of temp buffer+1
                    subd      <TmpBufBase              Calculate size of temp buffer
                    bls       WritlnDone               If 0 or >32k, restore regs & exit
                    tfr       d,y                 Move size to proper reg for WritLn
                    ldx       <TmpBufBase              Point to start of text
                    lda       #$02                Std error path
                    os9       I$WritLn            Write out the temporary buffer
                    bcc       WritlnDone               No error, restore regs & exit
                    bsr       PrintSysErr               Print the error message out
WritlnDone               puls      pc,y,x,d            Restore regs & exit

PrintSysErr               os9       F$PErr              Print error message
                    rts

DecodeICode               ldy       <ICodeCurPtr
                    cmpy      <ModFOff
                    bhs       AppendCrReturn
                    ldb       ,y
                    cmpb      #$3A
                    bne       CheckPackedLst
                    leay      1,y
                    lbsr      PrintLineOffset
                    lbsr      PrintSep
                    ldb       ,y
CheckPackedLst               tst       <PackedFlag
                    bmi       NextToken
                    bsr       GetPktByte
                    ldb       <IndentDepth
                    pshs      b
                    bsr       UpdateIndent
                    puls      a
                    sta       <IndentDepth
                    tfr       b,a
                    lbsr      PrintIndentPad
NextToken               ldb       ,y+
                    bmi       ProcessEndTok
                    bsr       GetPktByte
                    bsr       UpdateIndent
                    bsr       PktProcess
                    bra       ContScanLine

ProcessEndTok               lbsr      DecodeStructRef
ContScanLine               cmpy      <ModFOff
                    blo       NextToken
SaveLinePos               sty       <ICodeCurPtr
AppendCrReturn               lbra      AppendCR

SkipAndSavePos               leas      2,s
                    bra       SaveLinePos

UpdateIndent               sta       ,-s
                    bmi       IndentUpdDone
                    anda      #3
                    beq       IndentUpdDone
                    cmpa      #1
                    bne       DecIndent
                    inc       <IndentDepth
                    bra       IndentUpdDone

DecIndent               decb
                    bpl       CheckIndentPl
                    clrb
CheckIndentPl               cmpa      #3
                    beq       IndentUpdDone
                    dec       <IndentDepth
                    bpl       IndentUpdDone
                    clr       <IndentDepth
IndentUpdDone               lda       ,s+
                    rts

GetPktByte               leax      >PktTable,pc           Point to 3 byte packets for <JmpVect1 calls - $12
                    tstb                          If positive, skip ahead
                    bpl       PktLookup
                    subb      #$2A                Otherwise, bump down by 42
PktLookup               lda       #$03                Multiply by size of each entry
                    mul
                    leax      d,x                 Point to entry
                    lda       ,x                  Get 1st byte & return
                    rts

PktAndProcess               bsr       GetPktByte
PktProcess               leax      1,x
                    anda      #$60
                    beq       PktGetOffset
                    cmpa      #$60
                    bne       PktJumpAbs
                    leay      2,y
PktGetOffset               lda       -1,x
                    pshs      a
                    ldd       ,x
                    leax      d,x
                    puls      a
                    anda      #$18
                    cmpa      #$10
                    beq       CopyFcsToBuf
                    bra       PktNameAndSep

PktJumpAbs               cmpa      #$20
                    bne       PktPrintTokens
                    ldd       ,x
                    jmp       d,x

PktPrintTokens               bsr       PktAutoWrap
                    bsr       PktAppendChar
PktAppendChar               lda       ,x+
                    bne       AppendChar
PktAutoWrap               lda       <TmpBufCount
                    cmpa      #$41
                    bcs       PktPadDone
                    lda       #$0A
                    bsr       AppendChar
                    clr       <TmpBufCount
                    tst       <PackedFlag
                    bmi       PktPadDone
                    lda       <IndentDepth
                    adda      #3
PrintIndentPad               lsla
                    adda      #6
                    ldb       #$10
                    bsr       Vect6Fn2
                    clra
PktPadDone               rts

PktNameAndSep               bsr       PrintSep
CopyNameToBuf               bsr       CopyFcsToBuf
PrintSep               pshs      u,d
                    bsr       PktAutoWrap
                    bcc       PrintSepDone
                    ldu       <TmpBufCur
                    lda       #C$SPAC
                    cmpa      -1,u
                    beq       PrintSepDone
                    cmpu      <TmpBufBase
                    bne       StoreChar
PrintSepDone               puls      pc,u,d

* Append byte in A to temp buffer, check for overflow
AppendCR               lda       #C$CR
* Entry: A=Char (hi-bit stripped)
AppendChar               pshs      u,d                 Preserve regs
                    ldu       <TmpBufCur              ??? Get ptr to temp buffer
StoreChar               sta       ,u+                 Save char in buffer
                    ldd       <TmpBufCur              Get current pos in temp buffer
                    subd      <TmpBufBase              Calc. current size of temp buffer
                    tsta                          Past our max (255 bytes)?
                    bne       AppendCharDone               Yes, exit
                    inc       <TmpBufCount              No, bump up char count
                    stu       <TmpBufCur              Save current pos. in temp buffer+1
AppendCharDone               puls      pc,u,d              Restore & return

AppendDotAndNum               lda       #$2E
                    bsr       AppendChar
PrintSymbol               ldx       ,y++
                    ldd       <ModSymTbl
                    leax      d,x
                    leax      3,x

* Entry: X=ptr to text to output
* Exit: text output is in temp buffer from [TmpBufBase] to [TmpBufCur]-1
*       size of output string is in TmpBufCount
CopyFcsToBuf               pshs      x                   Preserve ptr to text to output
CopyFcsLoop               lda       ,x                  Get 1st char from X
                    anda      #$7F                Strip hi bit
                    bsr       AppendChar               Add byte to temp buffer; check if full
                    tst       ,x+                 Was the high bit set? (last char flag)
                    bpl       CopyFcsLoop               No, keep building output buffer
                    puls      pc,x                Done, restore original text ptr & return

Vect6Fn2               jsr       <JmpVect6
                    fcb       $02

* Called from Debug mode (?) -something with REAL #'s?
PrintRealToStr               ldb       #3
                    ldx       <StrSpaceTop
                    pshs      y,b
                    leay      -1,y
                    bra       CopyRealToBuf

PrintReal               pshs      y,b
* on 6309, use LDQ/STQ, on 6809, uses std -2/-4/-6,x leay -6,x (saves 5 cycles)
CopyRealToBuf               ldd       4,y
                    std       ,--x
                    ldd       2,y
                    std       ,--x
                    ldd       ,y
                    std       ,--x
                    leay      ,x
                    puls      b
                    bra       PrintOffsetStr

PrintByteLit               ldb       ,y
                    clra
                    bra       PrintOffsetHlp

PrintGosubKwd               leax      >KwGosub,pc           Point to 'GOSUB'
                    bra       PrintKwdSep

PrintGotoKwd               leax      >KwGoto,pc           Point to 'GOTO'
PrintKwdSep               bsr       PktNameAndSep
PrintLineOffset               ldd       ,y++
PrintOffsetHlp               pshs      y
                    ldy       <StrSpaceTop
                    leay      -6,y
                    std       1,y
                    ldb       #2
PrintOffsetStr               bsr       Vect6Fn2               JSR <$2A, function 2, sub-function 2
                    puls      pc,y

PrintStrLit               bsr       AppendQuote
PrintStrLoop               lda       ,y+                 Get char
                    cmpa      #$FF                EOS?
                    beq       AppendQuote               Yes, add " to temp buffer
                    bsr       AppendChar               No, add char to buffer
                    cmpa      #'"                 Was it a ?
                    bne       PrintStrLoop               No, keep printing chars
                    bra       PrintStrLit               Yes, add " & continue

AppendQuote               lda       #'"                 Add " to temp buffer
AppendCharJmp               lbra      AppendChar

PrintHexStr               lda       #'$                 Add $ to temp buffer
                    bsr       AppendCharJmp
                    ldb       #$14
                    bsr       Vect6Fn2               JSR <$2A, function 2, sub-function $14
                    leay      2,y
                    rts

PrintBaseKwd               leax      >KwBase,pc           Point to 'BASE'
                    lbsr      CopyNameToBuf
                    lda       -1,y
                    adda      #$FB
                    bra       AppendCharJmp

PrintRunKwd               leax      >KwRun,pc           Point to 'RUN'
PrintKwdSymbol               lbsr      CopyNameToBuf
                    lbra      PrintSymbol

PrintNextKwd               leax      >KwNext,pc           Point to 'NEXT'
                    leay      1,y
                    bsr       PrintKwdSymbol
                    leay      6,y
                    rts

PrintThenKwd               leax      >KwThen,pc           Point to 'THEN'
                    lbsr      PktNameAndSep
                    lda       ,y
                    cmpa      #$3A
                    beq       PrintThenDone
                    inc       <IndentDepth
PrintThenDone               rts

AltRemStr               fcs       '(*'

PrintAltRem               leax      <AltRemStr,pc           Point to alternative REM statement
                    bra       PrintRemBody

PrintRemKwd               leax      >KwRem,pc           Point to 'REM'
PrintRemBody               lbsr      CopyNameToBuf
RemBodyLoop               ldb       ,y+
PrintRemChar               decb
                    beq       PrintThenDone
                    lda       ,y+
                    bsr       AppendCharJmp
                    bra       PrintRemChar

* File opening mode table: 3 bytes per entry
* Byte 1   : Actual mode bit pattern
* Bytes 2&3: Offset (from itself) to keyword describing mode
*   NOTE: keywords are high bit terminated
FileModeTable               fcb       UPDAT.
FileModeUpdat               fdb       KwUpdate-*             Points to 'Update' string
FileModeRead               fcb       READ.
FileModeReadFd               fdb       KwRead-*             Points to 'Read' string
FileModeWrite               fcb       WRITE.
FileModeWrtFd               fdb       KwWrite-*             Points to 'Write' string
FileModeExec               fcb       EXEC.
FileModeExcFd               fdb       KwExec-*             Points to 'Exec' string
FileModeDir               fcb       DIR.
FileModeDirFd               fdb       KwDir-*             Points to 'Dir' string
FileModeEnd               fcb       $00                 End of table marker

DecodeFMode               lda       ,y+                 Get requested file access mode
                    pshs      a                   Preserve on stack
                    lda       #':                 Separator that starts modes
DecodeModeChar               bsr       AppendCharJmp               Parse for char?
                    leax      <FileModeTable-2,pc         Point early for reentry point of loop
ScanModeTable               leax      2,x                 Bump to next entry
                    lda       ,s                  Get requested mode
                    anda      ,x                  AND with mode in table
                    cmpa      ,x+                 Match so far?
                    bne       ScanModeTable               No, check next entry
                    tsta                          Matched cuz we are at end of table?
                    beq       DecodeFModeDone               Yes, exit routine
                    eora      ,s                  Mask out bits that are part of token, not mode
                    sta       ,s                  Preserve raw mode
                    ldd       ,x                  Get offset to text equivalent of mode
                    leax      d,x                 Point to it
                    lbsr      CopyFcsToBuf
                    lda       #'+                 Now check for additional modes
                    tst       ,s
                    bne       DecodeModeChar               Go check them  & update accordingly
DecodeFModeDone               puls      pc,a                Restore A and exit

DecodeStructRef               pshs      u
                    ldu       <StrSpaceTop
                    clr       ,-u                 Clear two bytes on stack
                    clr       ,-u
                    leay      -1,y
StructRefLoop               ldb       ,y
                    bpl       SaveStructPos
                    lbsr      GetPktByte
                    tfr       a,b
                    lda       ,y+
                    bitb      #$80
                    bne       StructRefLoop
                    orb       #$80
                    pshu      d
                    bitb      #$18
                    bne       StructRefLoop
                    andb      #$7F
                    pshu      d
                    bitb      #$04
                    bne       StructAddrRef
                    ldd       ,y++
                    std       2,u
                    bra       StructRefLoop

StructAddrRef               leay      -1,y
                    sty       2,u
                    ldb       ,y+
                    lbsr      LookupOpcode
                    bra       StructRefLoop

SaveStructPos               sty       <ICodeCurPtr
                    leay      ,u
                    clra
                    clrb
                    std       ,--y
                    pshs      d
                    sta       <ScanMatchByte
                    sta       <ICodeScanFlag
ScanStructLoop               ldd       ,u++
                    bitb      #$08
                    beq       ScanFlagClr
                    andb      #$07
                    cmpb      <ScanMatchByte
                    bhi       UpdateScanByte
                    bne       CallPrintDim
                    cmpb      #$06
                    bne       TestScanFlag2
                    tst       <ICodeScanFlag
                    beq       CallPrintDim
                    bra       UpdateScanByte

TestScanFlag2               tst       <ICodeScanFlag
                    beq       UpdateScanByte
CallPrintDim               lbsr      BuildKwdRef
UpdateScanByte               stb       <ScanMatchByte
                    orb       #$80
                    std       ,--y
                    lda       #$01
                    sta       <ICodeScanFlag
                    bra       ScanStructLoop

ScanFlagClr               clr       <ICodeScanFlag
                    bitb      #$03
                    beq       CheckScanBits
                    bitb      #$04
                    bne       CheckScanBits
                    bitb      #$10
                    bne       ScanStoreAddr
                    pulu      x
                    stx       ,--y
ScanStoreAddr               std       ,--y
                    andb      #$03
                    bsr       BuildKwdRef
                    cmpa      #$BE
                    bne       InitTokenKwd
                    ldx       #$54FF
                    stx       ,--y
InitTokenKwd               ldx       #$4B80
                    bra       DecBRepeat

PushRepeatKwd               stx       ,--y
DecBRepeat               decb
                    bne       PushRepeatKwd
                    stb       <ScanMatchByte
ScanLoopCont               bra       ScanStructLoop

CheckScanBits               bitb      #$10
                    bne       PushDScan
                    pulu      x
PushXScan               pshs      x
PushDScan               pshs      d
                    cmpa      #$89
                    blo       LoadStructPair
                    cmpa      #$8C
                    bls       ScanStructLoop
LoadStructPair               ldd       ,y++
                    tstb
                    bmi       StructNegRef
                    beq       StructNullRef
                    ldx       ,y++
                    bra       PushXScan

StructNegRef               pshs      d
                    clr       $01,s
                    bitb      #$10
                    bne       LoadStructPair
                    andb      #$07
                    stb       <ScanMatchByte
                    bra       ScanLoopCont

StructNullRef               ldx       ,u++
                    beq       StructGetPair
                    pshu      x
                    std       ,--y
                    bra       ScanLoopCont

StructPopToken               puls      y
                    ldb       ,y+
                    lbsr      PktAndProcess
StructGetPair               ldd       ,s++
                    beq       StructScanDone
                    bitb      #$04
                    bne       StructPopToken
                    leay      ,s
                    exg       a,b
                    lbsr      PktAndProcess
                    leas      ,y
                    bra       StructGetPair

StructScanDone               ldy       <ICodeCurPtr
                    puls      pc,u

BuildKwdRef               ldx       ,s
                    pshs      x
                    ldx       #$4E00
                    stx       $02,s
                    ldx       #$4DFF
                    stx       ,--y
* (orig: CMDSE9)
                    rts

EditCmd               lbsr      GetProcName
                    lbsr      DIRADD
                    ldy       ,x
                    tst       $06,y
                    bne       EditPackedErr
                    pshs      x
                    lbsr      UnbindSetupMod
                    lbsr      PrintProcHdr
                    ldy       <ModExecAddr
                    bsr       EditUpdatePos
EditCmdLoop               lda       <LastSignal              Get last signal code received
                    cmpa      #S$Abort            <CTRL>-<E>?
                    bne       EditPrompt               No, skip ahead
                    lbsr      EatStkRebind               Yes, ???
EditPrompt               leax      >EditPromptStr,pc           Point to 'E:'
                    leay      >EditCmdL,pc           Point to EDIT mode command table
                    lbsr      RUNCMD               Get next command from keyboard & execute it
                    bcc       EditCmdLoop               Legit command done, get next one
                    tst       <LastSignal              Signal received?
                    bne       EditCmdLoop               Yes, go process it
                    leax      <EditCmdLoop,pc           Point to routine (loop)
                    pshs      x                   Save it (for possible rts address?)
                    ldx       <TmpBufBase              Get ptr to start of temp buffer
                    lsl       ,x                  Clear out hi bit in 1st char in temp buffer
                    lsr       ,x
                    lbsr      EvalNumExpr               ???
                    lbcs      CMDERR               If carry set, print 'What?'
                    lbsr      FindLineAtStart
                    lda       ,x
                    cmpa      #C$CR
                    beq       EditUpdatePos
                    ldy       <TmpBufBase              Get temp buffer ptr
                    bra       InsertAndEdit               Skip ahead

EditPackedErr               coma
                    rts

EditModICode               leax      -1,y
                    lsl       ,x
                    asr       ,x
                    lbsr      ParseLineRef
                    lbsr      AppendIfNoCR
EditUpdatePos               sty       <ICodeCurPtr
                    lbsr      CountLines
                    leax      ,y
                    lbsr      ScanNextToken
                    lbra      EditIndentLine

InsertAndEdit               bsr       CompileOneLine
                    bcc       EditUpdatePos
                    rts

Vect2FnA               jsr       <JmpVect2
                    fcb       $0A

CompileOneLine               tst       <WorkspaceFree
                    beq       MemFullErr2
                    clr       <BreakFlag
                    bsr       Vect2FnA
                    ldx       <ICodeEndPtr
                    lda       ,x
                    cmpa      #$3A
                    bne       EditClearD
                    clra
                    clrb
                    sta       ,-s
                    ldy       <ICodeCurPtr
                    lbsr      FindLine
                    cmpy      <ModFOff
                    bcc       EditFindLine
                    ldd       $01,x
                    cmpd      $01,y
                    bls       EditFindLine
                    inc       ,s
EditFindLine               ldy       <ModExecAddr
                    ldd       1,x
                    lbsr      FindLineAtStart
                    tst       ,s+
                    bne       EditSetCurPos
                    bhs       EditSetCurPos
                    cmpy      <ICodeCurPtr
                    bhs       EditClearD
EditSetCurPos               sty       <ICodeCurPtr
                    cmpy      <ModFOff
                    bhs       EditClearD
                    ldx       <ICodeEndPtr
                    ldd       1,x
                    cmpd      1,y
                    bne       EditClearD
                    pshs      y
                    lbsr      ScanNextToken
                    tfr       y,d
                    subd      ,s++
                    bra       EditAdjustLine

EditClearD               clra
                    clrb
EditAdjustLine               ldy       <ICodeCurPtr
                    lbsr      InsertICode
                    ldx       <ICodeCurPtr
                    bsr       CheckLineEnd
                    bne       EditLineOk
                    leay      ,x
EditLineOk               clra
                    rts

MemFullErr2               ldb       #$20                Memory full error
                    lbsr      PrintSysErr               Print error message
                    coma                          Return with carry set
                    rts

CheckLineEnd               lda       ,x
                    cmpa      #$3A
                    bne       CheckEqSign
                    lda       3,x
CheckEqSign               cmpa      #$3D
                    rts

CountLines               ldx       #$0000
                    ldy       <ModExecAddr
CountLinesLoop               cmpy      <ICodeCurPtr
                    bhs       SaveLineCount
                    leax      1,x
                    lbsr      ScanNextToken
                    cmpy      <ModFOff
                    blo       CountLinesLoop
SaveLineCount               sty       <ICodeCurPtr
                    stx       <SavedLinePtr
                    clra
                    rts

EditSetupLine               bsr       SkipToStar
                    bsr       AppendIfNoCR
                    cmpx      <ModExecAddr
                    bhi       EditIndentLine
                    pshs      y,x
                    lbsr      PrintProcHdr
                    puls      y,x
EditIndentLine               ldd       <ModFOff
                    pshs      d
                    sty       <ModFOff
                    lbsr      ClearIndent         Bind parameters
                    puls      d
                    std       <ModFOff
                    clra
                    rts

AppendIfNoCR               pshs      x,b                 Preserve regs
                    ldx       <TmpBufCur              Get ptr to current pos in temp buffer
                    ldb       ,x                  Get char
                    cmpb      #C$CR               Carriage return?
                    bne       CmdSyntaxErr               No, skip ahead
                    puls      pc,x,b              Yes, restore regs & return

CmdSyntaxErr               leas      5,s                 Eat stack
                    lbra      CMDERR               Print 'What?' & return from there

SkipToStar               lda       ,y+                 Get char
                    cmpa      #C$SPAC             Space?
                    beq       SkipToStar               Yes, keep looking
                    cmpa      #'*                 '*'?
                    bne       FindEditLine               No, skip ahead
                    sty       <TmpBufCur              Found star, save ptr as current pos in temp bffr
                    ldx       <ModExecAddr              Get absolute exec address of basic module
                    ldy       <ModFOff              Get absolute address of $F offest in basic module
                    rts

FindEditLine               leax      -1,y
                    bsr       ParseLineRef
                    bcs       FindLineDone
                    ldx       <ICodeCurPtr
                    cmpy      <ICodeCurPtr
                    bhs       FindLineDone
                    exg       x,y
                    clra
FindLineDone               rts

ParseLineRef               clr       ,-s                 Clear flag?
                    ldd       ,x                  Get 2 chars
                    cmpa      #'+                 1st char a plus?
                    bne       CheckMinusRef               No, skip ahead
                    ldy       <ModFOff              Get address of $F offset for basic module
CheckStarEnd               cmpb      #'*                 2nd char='*'?
                    bne       BumpOneChar               No, skip ahead
                    leax      2,x                 Yes, bump ptr up 2 chars
                    stx       <TmpBufCur              Save as new current pos in temp buffer
                    puls      pc,a

CheckMinusRef               cmpa      #'-                 1st char dash?
                    bne       GetNumericRef               No, skip ahead
                    inc       ,s                  Yes, set flag
                    ldy       <ModExecAddr              Get address of $F offset for basic module
                    bra       CheckStarEnd               Go check for '*'

BumpOneChar               leax      1,x                 Bump ptr up
GetNumericRef               lda       ,x                  Get char from there
                    cmpa      #'0                 Is it numeric?
                    blo       UseOneOffset               No, skip ahead
                    cmpa      #'9                 Totally numeric?
                    bls       ParseLineNum               Yes, skip ahead
UseOneOffset               ldd       #$0001
                    bra       SaveRefPtr

ParseLineNum               bsr       EvalNumExpr
                    bcs       LineRefErr
SaveRefPtr               stx       <TmpBufCur              Save current ptr into temp buff
                    ldy       <ICodeCurPtr
                    tst       ,s+                 Check flag
                    beq       MoveToLine
                    ldy       <ModExecAddr
                    pshs      d
                    ldd       <SavedLinePtr
                    subd      ,s++
                    bhs       MoveToLine
                    clra
                    clrb
MoveToLine               lbsr      CountDownTok
                    clra
                    rts

LineRefErr               ldy       <ICodeCurPtr
                    com       ,s+                 Eat stack & set carry
                    rts

EvalNumExpr               ldy       <SubrStkPtr              ??? Get some sort of variable ptr
                    bsr       Vect6Fn0               JSR <2A, function 0 (Some temp var thing)
                    lda       ,y+                 ??? Get var type?
                    cmpa      #2                  Real?
                    beq       EvalIsReal               Yes, set carry & exit
                    clra                          Clear carry
                    ldd       ,y                  Get integer
                    bne       EvalNumDone               <>0, return with carry clear
EvalIsReal               coma                          Set carry & return
EvalNumDone               rts

Vect6Fn0               jsr       <JmpVect6
                    fcb       $00

EditWithWild               clrb
                    bra       SearchSetup

EditExact               ldb       #1
SearchSetup               leas      -$F,s
                    stb       ,s
                    lda       ,y
                    clr       1,s
                    cmpa      #'*
                    bne       SkipSpacesYP
                    sta       1,s
                    leay      1,y
SkipSpacesYP               ldb       ,y+                 Find first non-space char
                    cmpb      #C$SPAC
                    beq       SkipSpacesYP
                    tfr       b,a                 Move char to A
                    sty       <TmpBufCur              Save as next free pos in temp buffer
                    lbsr      CountMatchChrs
                    stu       2,s
                    lbmi      SearchErrClean
                    tst       ,s
                    beq       CheckCRAtEnd
                    lbsr      CountMatchChrs
                    stu       4,s
                    lbmi      SearchErrClean
CheckCRAtEnd               cmpa      #C$CR
                    beq       SetupReplace
                    lda       ,y+
                    cmpa      #C$CR
                    lbne      SearchErrClean
SetupReplace               ldu       <SubrStkPtr
                    stu       $D,s
* TFM (W=entry (Y-1)-<TmpBufCur)
CopyToStkBuf               lda       ,-y
                    sta       ,-u
                    cmpy      <TmpBufCur              ??? Back to beginning of temp buffer yet?
                    bhi       CopyToStkBuf               No, keep copying
                    stu       <SubrStkPtr
                    stu       <StrSpaceTop
                    ldd       2,s
                    leau      d,u
                    leau      1,u
                    stu       6,s
                    ldy       <ICodeCurPtr
                    sty       $B,s
                    clr       $A,s
                    lbra      SearchNextLine

SearchLoopInit               lbsr      ResetTmpBuf
                    sty       <ICodeCurPtr
                    lbsr      DecodeICode
                    ldy       <TmpBufBase              Get ptr to start of temp buffer
                    leay      5,y
                    lsl       $A,s                Dupe most sig bit into 2nd most sig bit???
                    asr       $A,s
SearchReplLoop               tst       <LastSignal              Any signals received?
                    bne       SearchAbort               Yes, skip ahead
                    ldd       <TmpBufCur
                    subd      $02,s
                    ldx       <SubrStkPtr
                    lbsr      CompareSearch
                    bcs       CheckMoreRepl
                    lda       #$81
                    sta       $A,s
                    tst       ,s
                    beq       CheckMoreRepl
                    ldd       <TmpBufCur
                    addd      4,s
                    subd      2,s
                    subd      <TmpBufBase
                    cmpd      #230
                    bhi       CheckMoreRepl
                    ldx       <TmpBufCur
                    exg       x,y
                    ldd       2,s
                    lbsr      FLOTUP
                    tfr       y,d
                    subd      2,s
                    tfr       d,y
                    ldu       6,s
                    pshs      x,d
CopyStrToY               lda       ,u+                 Get byte
                    sta       ,y+                 Copy it
                    cmpa      #$FF                Hit EOS marker?
                    bne       CopyStrToY               No, keep copying until we do
                    leay      -1,y
                    ldd       ,s++
                    subd      ,s
                    puls      x
                    lbsr      FLOTUP
                    sty       <TmpBufCur
                    ldd       4,s
                    leay      d,x
                    ldd       2,s
                    bne       SearchCont
                    leay      1,y
SearchCont               tst       1,s
                    bne       SearchReplLoop
CheckMoreRepl               tst       $A,s
                    bpl       SearchEndLine
                    ldy       8,s
                    ldd       ,s
                    bne       PrintNotFound
SearchAbort               ldx       $D,s
                    stx       <SubrStkPtr
                    stx       <StrSpaceTop
                    leas      $F,s
                    lbra      EditUpdatePos

PrintNotFound               lbsr      PrintTmpBuf
                    sty       $B,s
                    tst       ,s
                    beq       SearchEndLine
                    leax      ,y
                    lbsr      ScanNextToken
                    lbsr      SaveICodeEndPt
                    sty       <ICodeCurPtr
                    ldy       <TmpBufBase
                    lbsr      CompileOneLine
                    sty       <ICodeCurPtr
                    ldy       8,s
                    lbsr      ScanNextToken
                    cmpy      <ICodeCurPtr
                    bne       SearchNoMatch
                    tst       1,s
                    beq       SearchNoMatch
SearchEndLine               ldy       8,s
                    lbsr      ScanNextToken
SearchNextLine               sty       8,s
                    cmpy      <ModFOff
                    lbcs      SearchLoopInit
SearchNoMatch               lbsr      ResetTmpBuf
                    tst       $A,s
                    bne       SearchRestoreState
                    leax      <CantFindStr,pc           Point to "can't find"
                    lbsr      CopyNameToBuf
                    ldy       <SubrStkPtr
                    lbsr      PrintStrLit
                    lbsr      AddCrPrint
SearchRestoreState               ldy       $B,s
                    sty       <ICodeCurPtr
                    ldx       $D,s
                    stx       <SubrStkPtr
                    stx       <StrSpaceTop
                    leas      $F,s                Eat temp stack
                    lbra      CountLines

CantFindStr               fcs       /can't find:/

CountMatchChrs               ldu       #-1                 Pre-init counter to -1
MatchCharLoop               cmpa      #C$CR               Char a CR?
                    beq       MatchCharDone               Yes, set -1,y to a $FF, set carry & return
                    leau      1,u                 Bump counter up
                    lda       ,y+                 Get next char
                    cmpb      -1,y                Match char in B?
                    bne       MatchCharLoop               No, continue double checking
MatchCharDone               clr       -1,y                Set -1,y to $FF
                    com       -1,y                & set carry & return
                    rts

* CMPR Y,D for this with 18D2
CompareSearch               pshs      d
                    bra       CompareLimitCk

CompareStrAt               pshs      y,x
CompareLoop               lda       ,x+
                    cmpa      #$FF
                    beq       CompareFound
                    cmpa      ,y+
                    beq       CompareLoop
                    puls      y,x
                    leay      1,y
CompareLimitCk               cmpy      ,s
                    bls       CompareStrAt
                    coma
                    puls      pc,d

CompareFound               puls      y,x
                    clra
                    puls      pc,d

MoveLinesCmd               ldd       #100
                    ldx       #10
                    pshs      x,d
                    leax      ,y
                    ldy       <SavedLinePtr
                    lda       ,x
                    cmpa      #'*
                    bne       SkipSpaceNum
* 6309 MOD - use TFR 0,Y - same speed, 2 bytes shorter
                    ldy       #$0000
SkipToNum               leax      1,x
                    lda       ,x
SkipSpaceNum               cmpa      #C$SPAC
                    beq       SkipToNum
                    pshs      y
                    cmpa      #C$CR
                    beq       CheckCRAtCmd
                    lbsr      EvalNumExpr
                    bcs       MoveCmdErr
                    std       2,s
                    lda       ,x+
                    cmpa      #C$CR
                    beq       CheckCRAtCmd
                    lbsr      EvalNumExpr
                    bcs       MoveCmdErr
                    std       4,s
                    bmi       MoveCmdErr
                    lda       ,x
CheckCRAtCmd               cmpa      #C$CR
                    bne       MoveCmdErr
                    bsr       RebindProc
                    ldd       ,s++
                    ldy       <ModExecAddr
                    lbsr      CountDownTok
                    sty       <ICodeCurPtr
                    ldd       ,s
                    lbsr      FindLineAtStart
                    clr       ,-s
                    cmpy      <ICodeCurPtr
                    bcs       RangeErrMsg
                    bsr       CopyLinesHelper
                    cmpx      #$0000
                    ble       RangeErrMsg
                    tst       <LastSignal
                    bne       MoveCmdCleanup
                    inc       ,s
                    bsr       CopyLinesHelper
MoveCmdCleanup               leas      5,s
                    ldx       2,s
                    lbsr      UnbindSetupMod
                    ldy       <ModExecAddr
                    ldd       <SavedLinePtr
                    lbsr      CountDownTok
                    sty       <ICodeCurPtr
                    clra
                    rts

CopyLinesHelper               ldy       <ICodeCurPtr
                    ldx       3,s
CopyLinesLoop               clra
                    clrb
                    lbsr      FindLine
                    cmpy      <ModFOff
                    bhs       CopyLinesDone
                    tst       2,s
                    beq       CopyNextLine
                    stx       1,y
CopyNextLine               lbsr      ScanNextToken
                    tfr       x,d
                    addd      5,s
                    tfr       d,x
                    bpl       CopyLinesLoop
CopyLinesDone               rts

MoveCmdErr               leas      6,s
                    bra       GotoCmdErr

SearchErrClean               leas      $F,s
GotoCmdErr               lbra      CMDERR

RangeErrMsg               leax      <RangeStr,pc           Point to 'RANGE'
                    lbsr      PrintXToStderr               Print it out to std error (From temp buffer)
                    bra       MoveCmdCleanup

RangeStr               fcc       'RANGE'
                    fcb       $87                 Hit bit set- Bell

EatStkRebind               leas      4,s
RebindProc               lbsr      Vect3Fn2               JSR <21, function 2 (dick around with module stuff?)
                    clra
                    rts

SubstCmd               lbsr      SkipToStar
                    lbsr      AppendIfNoCR
                    bsr       SaveICodeEndPt
                    lbra      EditUpdatePos

SaveICodeEndPt               ldd       <ICodeEndPtr
                    std       <ICodeLineEnd
                    tfr       y,d
                    pshs      x
                    subd      ,s++
                    leay      ,x
InsertICode               pshs      u,y,x,d
                    leax      d,y
                    pshs      x
                    ldy       <ICodeLineEnd
                    ldd       <ICodeEndPtr
                    subd      ,s
                    beq       MoveICodeBlk
                    lbsr      FLOTUP
MoveICodeBlk               ldd       <ICodeLineEnd
                    ldu       ,s
                    subd      ,s++
                    bls       InsertAdjust
                    ldy       4,s
                    bsr       Vect2Fn6
InsertAdjust               ldd       <ICodeLineEnd
                    subd      <ICodeEndPtr
                    ldy       4,s
                    leay      d,y
                    sty       4,s
                    subd      ,s++
                    pshs      d
                    addd      <ModFOff
                    std       <ModFOff
                    std       <ICodeEndPtr
                    ldd       <WorkspaceFree              Get # bytes free in workspace for user
                    subd      ,s                  Subtract ?
                    std       <WorkspaceFree              Save new # bytes free for user
                    puls      pc,u,y,x,d          Restore regs & return

Vect2Fn6               jsr       <JmpVect2
                    fcb       $06

CopyVarBlock               pshs      y,x,d
                    leay      d,y
                    leau      d,u
                    andb      #$03
CopyBytesLoop               beq       CopyBlockDone
                    lda       ,-y
                    sta       ,-u
                    decb
                    bra       CopyBytesLoop

CopyWordLoop               ldx       ,--y
                    ldd       ,--y
                    pshu      x,d
CopyBlockDone               cmpy      4,s
                    bne       CopyWordLoop
                    puls      pc,y,x,d

FindLineAtStart               ldy       <ModExecAddr
FindLine               pshs      d
                    bra       FindLineLoop

FindLineNext               lbsr      ScanNextToken
FindLineLoop               cmpy      <ModFOff
                    bhs       FindLineNoFnd
                    lda       ,y
                    cmpa      #':
                    bne       FindLineNext
                    ldd       ,s
                    cmpd      1,y
                    bhi       FindLineNext
                    puls      pc,d

FindLineNoFnd               coma
                    puls      pc,d

* Part of RENAME (?)
UnbindSetupMod               pshs      u,y,x,d             Preserve regs
                    lbsr      SHUFLE               ??? Go move module in workspace?
                    ldx       ,x                  Get some sort of module ptr
                    stx       <CurModPtr              Save as ptr to current procedure
                    ldd       M$Exec,x            Get exec offset
                    addd      <CurModPtr              Calculate exec address in memory
                    std       <ModExecAddr              Save it
                    ldd       $F,x                Get ???
                    addd      <CurModPtr              Add to current mod start
                    tfr       d,y                 Move to Y
                    std       <ModFOff              Save ???
                    std       <ICodeEndPtr
                    ldd       M$Size,x            Get size of module
                    subd      $F,x                Subtract ???
                    pshs      d                   Save on stack
* 6809/6309 NOTE: LDD <U0000 IS UNECESSARY ON LEVEL II OS9
                    ldd       <DpBase              Get start of BASIC09 data mem ptr
                    addd      <DataAreaSz              Add size of data area
                    subd      ,s                  Subtract calculated size
                    tfr       d,u                 Copy ??? size to U
                    std       <SymTblSize
                    puls      d                   Get ??? calculated size
                    bsr       CopyVarBlock
                    ldd       $D,x
                    subd      $F,x
                    subd      #3
                    std       <StorageOff
                    addd      <SymTblSize
                    addd      #3
                    std       <ModSymTbl
                    ldd       M$Size,x            Get module size
                    subd      $D,x                Subtract ???
                    addd      #3                  ??? Add CRC bytes?
                    std       <ModSzData
                    ldy       <ModExecAddr
                    bsr       ScanICodeLoop
                    ldx       <ModSymTbl
                    ldd       -3,x
                    beq       CalcFreeSpace
BuildSymFlags               pshs      d
                    leau      ,x
                    leax      3,x
FindSymNameEnd               ldb       ,x+
                    bpl       FindSymNameEnd
                    lda       #2
                    cmpb      #$A4
                    bne       SaveSymFlag
                    lda       #4
SaveSymFlag               sta       ,u
                    puls      d
                    subd      #1
                    bgt       BuildSymFlags
CalcFreeSpace               ldx       <SymTblSize
                    ldd       <StorageOff
                    leax      d,x
                    stx       <DescrAreaOff
                    stx       <SymTblSize
                    addd      <WorkspaceFree              Add to bytes free in workspace for user
                    std       <WorkspaceFree              Save new # bytes free in workspace for user
                    clr       <StorageOff
                    clr       <UnusedByte69
                    puls      pc,u,y,x,d

* NOTE: CHECK IF ROUTINE CAN BE MOVED TO NEARER TABLE/SUBROUTINE
* ScanICodeByte & ScanICodeAdj are only called within routine itself
* ScanICodeLoop is called from way early in the code, and just before BuildSymFlags
ScanICodeByte               ldb       ,y+
                    bpl       ScanICodeAdj
                    subb      #$2A
ScanICodeAdj               clra
                    leax      >ICodeByteTable,pc           Point to some sort of table
                    ldb       d,x                 Get entry
                    lsrb                          Divide by 16
                    lsrb
                    lsrb
                    lsrb
                    lbsr      DispatchByTbl
ScanICodeLoop               cmpy      <ModFOff
                    blo       ScanICodeByte
                    rts

* 8 bit offset jump table (base of JMP is ICodeScanJmpTbl)
ICodeScanJmpTbl               fcb       ICodeScanRts-ICodeScanJmpTbl
                    fcb       BumpYPlus1b-ICodeScanJmpTbl
                    fcb       BumpYPlus1-ICodeScanJmpTbl
                    fcb       SkipFiveBytes-ICodeScanJmpTbl
                    fcb       SkipRecordFld-ICodeScanJmpTbl
                    fcb       SkipToEOS-ICodeScanJmpTbl
                    fcb       ChkType85-ICodeScanJmpTbl
                    fcb       SkipByBBytes-ICodeScanJmpTbl
                    fcb       ChkEndMarker-ICodeScanJmpTbl
                    fcb       FixupRelOff-ICodeScanJmpTbl
                    fcb       GetFlagBits-ICodeScanJmpTbl
                    fcb       DecPrevByte3-ICodeScanJmpTbl
                    fcb       DecPrevByte2-ICodeScanJmpTbl
                    fcb       DecPrevByte-ICodeScanJmpTbl
                    fcb       FixupNegByte-ICodeScanJmpTbl

* Routines called by above table follow here
FixupNegByte               lda       -1,y
                    adda      #$93
                    sta       -1,y
BumpYPlus1               leay      1,y
BumpYPlus1b               leay      1,y
ICodeScanRts               rts

DecPrevByte               dec       -1,y
DecPrevByte2               dec       -1,y
DecPrevByte3               dec       -1,y
                    rts

FixupRelOff               ldd       ,y
                    addd      <ModExecAddr
                    tfr       d,x
                    ldd       -2,x
                    std       ,y++
                    dec       -3,y
                    rts

ChkType85               lda       ,y+
                    cmpa      #$85
                    bne       SkipVarRef
SkipRecordFld               leay      9,y
                    rts

SkipVarRef               clrb
                    bsr       MarkDelimSym
                    leay      7,y
                    rts

ChkEndMarker               lda       ,y+
                    cmpa      #$4F
                    bne       ScanRts1
                    leay      4,y
ScanRts1               rts

SkipFiveBytes               leay      5,y
                    rts

SkipToEOS               lda       ,y+
                    cmpa      #$FF
                    bne       SkipToEOS         ..No; continue
                    rts

SkipByBBytes               ldb       ,y
                    clra
                    leay      d,y
                    rts

GetFlagBits               ldb       -1,y
AndWith04               andb      #$04
MarkDelimSym               lda       #$60
                    pshs      d             save regs
                    lda       #$85
                    sta       -1,y          of the name as a delimiter
                    ldx       <ModSymTbl
                    ldd       -3,x          get count of free memory
                    ldu       ,y
                    bra       FindSymMatch

SymNextEntry               puls      d
SymDecCount               subd      #$0001
                    beq       SymMatchDone
                    leax      3,x
SkipSymName               tst       ,x+
                    bpl       SkipSymName
FindSymMatch               cmpu      1,x
                    bne       SymDecCount
                    pshs      d
                    lda       ,x
                    anda      #$E0
                    cmpa      2,s
                    bne       SymNextEntry
                    lda       ,x
                    anda      #$18
                    bne       SymNextEntry
                    lda       ,x
                    anda      #$04
                    eora      3,s
                    bne       SymNextEntry
                    tfr       x,d           get symbol table ptr
                    subd      <ModSymTbl        Subtract beginning of symtbl for fun
                    std       ,y++
                    leas      2,s
SymMatchDone               leas      2,s
                    rts

LookupOpcode               tstb                          High bit set?
                    bpl       LookupByTbl               No, skip ahead
                    subb      #$2A                Adjust it down if it was
LookupByTbl               leax      <ICodeByteTable,pc           Point to table
                    abx                           Point X to offset
                    ldb       ,x                  Get single byte
                    andb      #$0F                Mask off high nibble
DispatchByTbl               leax      >ICodeScanJmpTbl,pc           Point to vector offset table
                    ldb       b,x                 Point to routine that is close
                    jmp       b,x                 Go do it

ScanToken               pshs      u                   Preserve U
                    ldb       ,y+                 Get byte
ScanTokenLoop               cmpb      ,u+                 If higher than byte in table, keep going
                    bhi       ScanTokenLoop
                    puls      u                   Get U back
                    beq       ScanTokenRts               If byte matches table entry, return
                    bsr       LookupOpcode               If not, go somewhere else

CheckScanEnd               cmpy      <ModFOff
                    blo       ScanToken
                    coma
ScanTokenRts               puls      pc,u,x,d            Restore regs & return

* 1 byte/entry table
ScanTable1               fcb       $1f
                    fcb       $21
                    fcb       $3a
                    fcb       $ff                 End of table marker

ScanTokenAlt1               pshs      u,x,d
                    leau      <ScanTable1,pc           Point to table
                    bra       CheckScanEnd

* 1 byte/entry table
ScanTable2               fcb       $3E
ScanTable2b               fcb       $3f
ScanTable2End               fcb       $FF                 End of table marker

ScanTokenT2               pshs      u,x,d
                    leau      <ScanTable2,pc           Point to table
                    bra       CheckScanEnd

ScanTokenT2b               pshs      u,x,d
                    leau      <ScanTable2b,pc           Point to 2nd entry in table
                    bra       CheckScanEnd

* Table: 1 byte entries
ScanTable3               fcb       $23,$85,$86,$87,$88,$89,$8A,$8B,$8C
                    fcb       $f2,$f3,$f4,$f5,$f6,$f7,$f8,$f9,$ff

ScanTokenT3               pshs      u,x,d
                    leau      <ScanTable3,pc           Point to table
                    bra       CheckScanEnd

                    ifne      H6309
ScanNextToken               clrd
                    else
ScanNextToken               clra
                    clrb
                    endc

ScanCountLoop               bsr       ScanTokenT2b
                    bcs       ScanCountDone         ..No; not a name, so return
CountDownTok               subd      #$0001
                    bhs       ScanCountLoop
ScanCountDone               rts

* Table - single byte entries - one routine uses it to reference another
* table (1ACC), but divides it by 16 to determine which of that table to use
* Table goes from 1BD5 to 1CA4
ICodeByteTable               fcb       $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$22,$00,$00,$64,$00,$22,$00,$00,$00,$22,$00,$22,$00,$00,$22
                    fcb       $92,$22,$92,$22,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$77,$77,$00,$22,$92,$77,$77,$00,$00
                    fcb       $00,$00,$00,$00,$80,$00,$22,$22,$00,$00,$11,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$22,$a2,$a2,$a2,$a2,$a2,$22,$22,$22,$22,$22
                    fcb       $22,$22,$22,$11,$22,$33,$55,$22,$00,$00,$00,$00,$00,$00,$00,$b0
                    fcb       $00,$00,$00,$00,$b0,$00,$00,$00,$00,$00,$00,$00,$00,$b0,$00,$00
                    fcb       $00,$b0,$00,$b0,$00,$b0,$00,$b0,$00,$b0,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$b0,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$b0,$00,$00,$00,$00,$b0,$c0,$00,$b0,$c0,$00
                    fcb       $b0,$c0,$d0,$00,$b0,$c0,$d0,$00,$b0,$c0,$00,$b0,$c0,$00,$b0,$c0
                    fcb       $00,$b0,$00,$b0,$00,$b0,$00,$00,$e2,$e2,$e2,$e2,$e2,$e2,$e2,$e2

Vect2Dispatch               pshs      x,d                 Preserve regs
                    ldb       [<4,s]              Get function code
Vect2OffsetTbl               leax      <Vect2JmpTbl,pc           Point to table
                    ldd       b,x                 Make offset vector
                    leax      d,x           Save dsctbl end for caller
                    stx       4,s                 Modify RTS address
                    puls      pc,x,d              restore X & D and RTS to new address

* 2 byte/entry vector table (JMP >$1E calls have there function byte after
*  the JMP containing the offset to which of these entries to uses)
Vect2JmpTbl               fdb       CMPRAM-Vect2JmpTbl         $00 function
                    fdb       NAMSYM-Vect2JmpTbl         $02 function
                    fdb       SEARC0-Vect2JmpTbl         $04 function
                    fdb       MOVDWN-Vect2JmpTbl         $06 function
                    fdb       CheckWkspFit-Vect2JmpTbl         $08 function
                    fdb       DIM1-Vect2JmpTbl         $0A function

* Data of some sort: Appears to be special symbols
SpecSymsHdr               fdb       33                  (# of entries-33)
                    fcb       $03                 (# bytes to skip to start of next?)

SpecSymsTbl               fcb       OutcodeHex-PRSHEX
                    fcb       $d9,$0a             (token & type of operator???)
                    fcs       '<>'

                    fcb       OutcodeHex-PRSHEX
                    fcb       $d9,$0a
                    fcs       '><'

                    fcb       OutcodeHex-PRSHEX
                    fcb       $e4,$0a
                    fcs       '<='

                    fcb       OutcodeHex-PRSHEX
                    fcb       $e4,$0a
                    fcs       '=<'

                    fcb       OutcodeHex-PRSHEX
                    fcb       $e1,$0a
                    fcs       '>='

                    fcb       OutcodeHex-PRSHEX
                    fcb       $e1,$0a
                    fcs       '=>'

                    fcb       OutcodeHex-PRSHEX
                    fcb       $52,$08
                    fcs       ':='

                    fcb       OutcodeHex-PRSHEX
                    fcb       $f1,$05
                    fcs       '**'

                    fcb       OutcodeHex-PRSHEX
                    fcb       $38,$01
                    fcs       '(*'

                    fcb       OutcodeHex-PRSHEX
                    fcb       $3e,$02
                    fcs       '\'

                    fcb       OutcodeHex-PRSHEX
                    fcb       $d3,$0a
                    fcs       '>'

                    fcb       OutcodeHex-PRSHEX
                    fcb       $d6,$0a
                    fcs       '<'

                    fcb       OutcodeHex-PRSHEX
                    fcb       $dd,$09
                    fcs       '='

                    fcb       OutcodeHex-PRSHEX
                    fcb       $e7,$05
                    fcs       '+'

                    fcb       OutcodeHex-PRSHEX
                    fcb       $ea,$05
                    fcs       '-'

                    fcb       OutcodeHex-PRSHEX
                    fcb       $ec,$05
                    fcs       '*'

                    fcb       OutcodeHex-PRSHEX
                    fcb       $ee,$05
                    fcs       '/'

                    fcb       OutcodeHex-PRSHEX
                    fcb       $f0,$05
                    fcs       '^'

                    fcb       OutcodeHex-PRSHEX
                    fcb       $4c,$0c
                    fcs       ':'

                    fcb       OutcodeHex-PRSHEX
                    fcb       $4f,$0c
                    fcs       '['

                    fcb       OutcodeHex-PRSHEX
                    fcb       $50,$0c
                    fcs       ']'

                    fcb       OutcodeHex-PRSHEX
                    fcb       $51,$0c
                    fcs       ';'

                    fcb       OutcodeHex-PRSHEX
                    fcb       $54,$0b
                    fcs       '#'

                    fcb       OutcodeHex-PRSHEX
                    fcb       $26,$01
                    fcs       '?'

                    fcb       OutcodeHex-PRSHEX
                    fcb       $37,$01
                    fcs       '!'

                    fcb       PRSLF-PRSHEX         Recurse to the search routine again (eat LF)
                    fcb       $00,$0c
                    fcb       $80+C$LF            Line feed

                    fcb       OutcodeHex-PRSHEX
                    fcb       $4b,$0c
                    fcs       ','

                    fcb       OutcodeHex-PRSHEX
                    fcb       $4d,$0c
                    fcs       '('

                    fcb       OutcodeHex-PRSHEX
                    fcb       $4e,$0c
                    fcs       ')'

                    fcb       PRSPER-PRSHEX
                    fcb       $89,$0c
                    fcs       '.'

                    fcb       StartStrLit-PRSHEX
                    fcb       $90,$06
                    fcs       '"'

                    fcb       PRSHEX-PRSHEX
                    fcb       $91,$06
                    fcs       '$'

                    fcb       OutcodeHex-PRSHEX
                    fcb       $3f,$02
                    fcb       $80+C$CR            Carriage return

* Jump table for type 1 commands (see CmdTable)
*                           Command  Token
CmdJmpBase               fdb       ERMAS9-CmdJmpBase         ???      0   Illegal statement construction error
                    fdb       CompileVarDecl-CmdJmpBase         PARAM    1
                    fdb       TYPES-CmdJmpBase         TYPE     2
                    fdb       CompileVarDecl-CmdJmpBase         DIM      3
                    fdb       PDATA-CmdJmpBase         DATA     4
                    fdb       PRINT-CmdJmpBase         STOP     5
                    fdb       STOP-CmdJmpBase         BYE      6
                    fdb       STOP-CmdJmpBase         TRON     7
                    fdb       STOP-CmdJmpBase         TROFF    8
                    fdb       PRINT-CmdJmpBase         PAUSE    9
                    fdb       STOP-CmdJmpBase         DEG      A
                    fdb       STOP-CmdJmpBase         RAD      B
                    fdb       STOP-CmdJmpBase         RETURN   C
                    fdb       ParseLet-CmdJmpBase         LET      D
                    fdb       ERMAS9-CmdJmpBase         ???      E   Illegal Statement Construction err
                    fdb       CompilePoke-CmdJmpBase         POKE     F
                    fdb       CompileIf-CmdJmpBase         IF       10
                    fdb       CHLREF-CmdJmpBase         ELSE     11
                    fdb       STOP-CmdJmpBase         ENDIF    12
                    fdb       FOR-CmdJmpBase         FOR      13
                    fdb       WHILE-CmdJmpBase         NEXT     14
                    fdb       ERMDO-CmdJmpBase         WHILE    15
                    fdb       CompileEndBlk-CmdJmpBase         ENDWHILE 16
                    fdb       STOP-CmdJmpBase         REPEAT   17
                    fdb       ENDLUP-CmdJmpBase         UNTIL    18
                    fdb       STOP-CmdJmpBase         LOOP     19
                    fdb       CompileEndBlk-CmdJmpBase         ENDLOOP  1A
                    fdb       EXITI8-CmdJmpBase         EXITIF   1B
                    fdb       CompileEndBlk-CmdJmpBase         ENDEXIT  1C
                    fdb       CompileOn-CmdJmpBase         ON       1D
                    fdb       CompileExpr-CmdJmpBase         ERROR    1E
                    fdb       CompileGotoSub-CmdJmpBase         GOTO     1F
                    fdb       ERMAS9-CmdJmpBase         ???      20  Illegal Statement Construction err
                    fdb       CompileGotoSub-CmdJmpBase         GOSUB    21
                    fdb       ERMAS9-CmdJmpBase         ???      22  Illegal Statement Construction err
                    fdb       RUN-CmdJmpBase         RUN      23
                    fdb       CompileExpr-CmdJmpBase         KILL     24
                    fdb       INPUT-CmdJmpBase         INPUT    25
                    fdb       PRINT-CmdJmpBase         PRINT    26 (Also '?')
                    fdb       CompileExpr-CmdJmpBase         CHD      27
                    fdb       CompileExpr-CmdJmpBase         CHX      28
                    fdb       CompileOpenCrt-CmdJmpBase         CREATE   29
                    fdb       CompileOpenCrt-CmdJmpBase         OPEN     2A
                    fdb       CompileSeek-CmdJmpBase         SEEK     2B
                    fdb       READ-CmdJmpBase         READ     2C
                    fdb       PUT8-CmdJmpBase         WRITE    2D
                    fdb       GET-CmdJmpBase         GET      2E
                    fdb       GET-CmdJmpBase         PUT      2F
                    fdb       CompileClose-CmdJmpBase         CLOSE    30
                    fdb       RESTOR-CmdJmpBase         RESTORE  31
                    fdb       CompileExpr-CmdJmpBase         DELETE   32
                    fdb       CompileExpr-CmdJmpBase         CHAIN    33
                    fdb       CompileExpr-CmdJmpBase         SHELL    34
                    fdb       BASE-CmdJmpBase         BASE     35
                    fdb       BASE-CmdJmpBase         ???      36
                    fdb       REM-CmdJmpBase         REM      37 (Also '!')
                    fdb       REM-CmdJmpBase         (*       38
                    fdb       PRINT-CmdJmpBase         END      39

EREVRB               lda       <ICodeUsed+1            Get LSB of # bytes used by all programs (not data)
ERRDIE               pshs      a                   Save it
                    ldx       <NameStrEnd
                    lda       #C$CR               Byte to look for
RUN1               lsl       ,x                  Clear out high bit? (if so, use AIM instead)
                    lsr       ,x            strip any high order bits set
                    cmpa      ,x+                 Find byte we want?
                    bne       RUN1               No, keep looking
                    ldx       <NameStrEnd              Get ptr to end of string name+1
                    bsr       PRTLIN               Print string out
                    ldd       <ErrHandlerPtr        ERROR addr
                    subd      <NameStrEnd        is there more than (size)?
                    pshs      b             save number of spaces to ERROR
                    ldx       <ICodeLineSav2
                    stx       <ICodeLineEnd
                    ldy       <NameStrEnd
                    lda       #$3D
                    lbsr      OUTCOD
                    lbsr      REM
                    lbsr      OUTCOD
                    lda       #C$SPAC             Block copy Spaces (TFM)
                    ldx       <TmpBufBase              Get start address
ERRO07               sta       ,x+                 Fill with spaces
                    dec       ,s
                    bpl       ERRO07         until ERROR addr is reached
                    ldd       #$5E0D              Add ^ (CR) (part of debug?)
                    std       -$01,x
                    ldx       <TmpBufBase              Get start ptr again
                    bsr       PRTLIN               Go print the debug line
                    puls      d
                    bsr       Vect1Fn2
                    ldx       <SubrStkPtr
                    stx       <StrSpaceTop
Vect1Fn6               jsr       <JmpVect1              ??? Reset temp buff to defaults, SP restore from B7
                    fcb       $06

Vect1Fn2               jsr       <JmpVect1              Print error code to screen
                    fcb       $02

PRTLIN               ldy       #$0100              Size=256 bytes
                    lda       <StdoutPath              Get path
                    os9       I$WritLn            Write it & return
                    rts                     Any errors)

Vect1Fn4               jsr       <JmpVect1              ??? Save SP @ <ExitStkPtr, muck around
                    fcb       $04

DIM1               puls      x
                    bsr       Vect1Fn4
                    lbsr      SetupCompile
                    lbsr      CompileOptLineRef
                    sty       <NameStrEnd
                    ldx       <ICodeLineEnd
                    stx       <ICodeLineSav2        Also I-Code buffer ditto
COMPI1               bsr       STATEM               Go process command/variable/constant
                    lda       <CmdToken              Get token
                    lbsr      OUTCOD               Add to I-code line bffr & make sure no overflow
                    cmpa      #$3E                Was it a $3E?
                    beq       COMPI1               Yes, go get next one
                    cmpa      #$3F                Was it a $3F?
                    bne       EREVRB               No, do something
                    bra       Vect1Fn6               Yes, Call <JmpVect1, function 6

STATEM               lbsr      PRSLF               Go find command (or variable/constant name)
                    lda       <CmdType              Get command type
                    cmpa      #$01                (Is it a normal command?)
                    bne       STATE1               No, check next
* Command type 1 goes here
                    ldb       <CmdToken              Get entry # (token) into JMP offset table
                    clra                          Make 16 bit for signed jump
                    ifne      H6309
                    lsld                          Multiply by 2 (2 bytes/entry)
                    else
                    lslb
                    rola                    2
                    endc
                    leax      >CmdJmpBase,pc           Point to Basic09 COMMANDS vector table
                    ldd       d,x                 Get offset
                    jmp       d,x                 Execute command's routine

STATE1               cmpa      #$02                Command type 2?
                    lbne      ParseExprType               No, go process functions, etc.
* Command type 2 goes here
STATE8               pshs      x
                    ldx       <ICodeLineEnd
                    leax      -$01,x        remove last byte from I-Code
                    stx       <ICodeLineEnd
                    puls      pc,x          return

TYPES               lbsr      ParseSymAndChk
                    cmpa      #$DD          is it followed by a "="?
                    lbne      ErrMissAssign
                    bsr       STATE8
                    lda       #$53
* (orig: DIM)
                    lbsr      OUTCOD

CompileVarDecl               lbsr      ParseSymAndChk
                    cmpa      #$4D
                    bne       DimParamLoop
                    lbsr      CompileRecRef
                    bne       PRSP30         ..No commma - go handle left paren
                    lbsr      CompileRecRef
                    bne       PRSP30
* (orig: DIM2)
                    lbsr      CompileRecRef
PRSP30               lbsr      ERMRPR
                    bsr       CallPRSLF
DimParamLoop               lbsr      CHKVAR
                    beq       CompileVarDecl
                    cmpa      #$4C
                    bne       CheckSemicolon         ..No; go look for a semi-colon
                    bsr       CallPRSLF         get type token
                    ldb       <CmdType              Get token
                    beq       DIM25               If 0, skip ahead
* (orig: DIM21)
                    cmpb      #$03
                    bne       ERITYP
                    cmpa      #$44
                    bne       DIM25         ..No; return
                    bsr       CallPRSLF
                    cmpa      #$4F          is it a '['?
                    bne       CheckSemicolon         ..No; end of this entry
                    lbsr      CompileRecRef
* (orig: DIM3)
                    cmpa      #$50          is it followed by a "]"?
                    bne       ERITYP
DIM25               bsr       CallPRSLF
CheckSemicolon               cmpa      #$51
                    beq       CompileVarDecl
                    bra       STATE8         Remove trailing (eol) token and return

CallPRSLF               lbra      PRSLF

ERITYP               lda       #$18
                    bra       ERMDO9

DATA0               lbsr      OUTCOD
PDATA               bsr       NEXT9
                    lbsr      CHKVAR
                    beq       DATA0
TLBNE               lda       #$55
CompileToken               lbsr      OUTCOD
                    bra       IFFAL1

CompilePoke               lbsr      CompileExpr
                    lbsr      CKCOMA         Insure comma follows
                    lbra      ASSIG1

CompileIf               bsr       ENDLUP
                    cmpa      #$45          is it a then token?
                    bne       ERMTHN
                    lbsr      OUTCOD         put then token in I-Code
                    lbsr      CompileOptLineRef         compile (optional GOTO) line ref
                    bcc       EndBlkStop         (STOP)
* (orig: FOR9)
                    lbra      STATEM         No line ref found - process new stmt beginning

ERMTHN               lda       #$26
                    bra       ERMDO9         (ERRDIE) exit via ERROR trap

CHLREF               bsr       IFFAL1
                    bra       EXITI9

FOR               lbsr      ParseProcName
                    lbsr      PREFIX
                    lda       <CmdToken
                    cmpa      #$46          is it followed by TO?
                    bne       ErrFORnoTO
* (orig: ARRNAM)
                    bsr       FARGCN
* (orig: ERINUM)
                    lda       <CmdToken
                    cmpa      #$47
                    bne       TLBNE
                    bsr       FARGCN
                    bra       TLBNE

FARGCN               bsr       CompileToken
NEXT9               lbra      CompileExpr

ErrFORnoTO               lda       #$27
                    bra       ERMDO9

WHILE               lbsr      ParseProcName
                    bsr       IFFAL1
                    bsr       IFFAL1
IFFAL1               lbra      IFFALS

ERMDO               bsr       ENDLUP
                    cmpa      #$48
                    beq       DoExitIf
                    lda       #$1F
ERMDO9               lbra      ERRDIE

ENDLUP               bsr       NEXT9
                    bra       TLBNE

CompileEndBlk               bsr       IFFAL1
EndBlkStop               bra       GOTO9

EXITI8               bsr       ENDLUP
                    cmpa      #$45
                    bne       ERMTHN
DoExitIf               bsr       CMPRA9
EXITI9               lbra      STATEM

CompileOn               ldd       <ICodeLineEnd
                    pshs      y,d           save I-Code ptr & source ptr
                    lbsr      PRSLF         get next symbol
                    cmpa      #$1E          is it ERROR?
                    bne       ON1         ..No; go handle computed GOTO
                    leas      $04,s         Discard saved ICDPTR & SRCPTR
                    bsr       GOTO9         (STOP) get next symbol
                    cmpa      #$1F          is the next symbol a GOTO?
                    beq       CompileLineRef         ..Yes; go parse it
* (orig: ON9)
                    rts

ON1               puls      y,d
                    std       <ICodeLineEnd        Save it
                    bsr       ENDLUP         parse <EXPR> followed by T.LBNE & 2 zero bytes
                    ldx       <ICodeLineEnd
                    leax      -1,x
                    pshs      x             save ptr to LSB of 'count of how many gotos are here'
                    cmpa      #$1F          is it followed by a goto?
                    beq       ON3         ..Yes; good - continue
                    cmpa      #$21
                    beq       ON3
* (orig: ERMGTO)
                    lda       #$21
                    bra       ERMDO9

ON2               bsr       CMPRA9
                    lda       #$3A
ON3               inc       [,s]
                    bsr       CompileLineRef         get line reference
                    lbsr      CHKVAR         is it followed by a comma?
                    beq       ON2         ..Yes; loop until it isn't
                    puls      pc,x

CompileGotoSub               lbsr      ERMASS
CompileLineRef               lbsr      AppendLineRef
GOTO9               lbra      STOP

SetupCompile               sty       <NameStrEnd              Save ptr to end of string name
                    ldx       <ICodeEndPtr              ??? Get ptr to start of I-code
                    stx       <ICodeLineSav2              Save it
                    stx       <ICodeLineEnd              And again as current I-code line end ptr
                    clr       <LoadInitFlag              Clear <LoadInitFlag & <CmplxAsgFlag
                    clr       <CmplxAsgFlag
CompileRts               rts

* Entry: Y=Ptr to end of string name+1
CMPRAM               bsr       SetupCompile               Set up some ptrs
                    inc       <BreakFlag              ??? Set flag? (think it is 3-way flag)
                    lbsr      STOP               ??? Go process source line? (A returns token)
                    bsr       CheckGroupTok               Go check for "(" command grouping start
                    clr       <BreakFlag              ??? Clear flag?
                    lda       <CmdToken              Get 1st byte from command table (token)?
                    cmpa      #$3F                Was it a carriage return token?
                    lbne      EREVRB               No, go process token
CMPRA9               lbra      OUTCOD               Add token to I-code buffer, check for overflow

RUN               lbsr      ERMASS
                    pshs      x             save it for return
                    lbsr      ParseProcName         get procedure name
                    ldb       #$23
                    stb       [,s++]        Reset T.RUN token
* Check for "(" token (start of group of operations)
CheckGroupTok               cmpa      #$4D                Token $4D  - "(" group start token?
                    bne       CompileRts               No, return
* Process "( )" command grouping
RUN3               bsr       CMPRA9               No, go call OUTCOD (X=Tble ptr, D=Token/type bytes?)
                    ldd       <ICodeLineEnd              Get ptr to current I-code line end
                    pshs      y,d                 Save with source ptr(?)
                    lbsr      PRSLF               Process next command/line #/variable name
                    ldd       #$0005              Token types 0 & 5
                    cmpa      <CmdType              Just processed command token type 0?
                    beq       PRSP10               Yes, skip ahead
                    stb       <CmdType              No, replace with type 5 (AND,OR,XOR,NOT)
                    bra       PRSP20               Skip ahead

PRSP10               lbsr      ChkTypeAndVar               Go check for Illegal Statement Construction
PRSP20               puls      y,d                 Get ptr to last char+1 & current I-code line end
                    std       <ICodeLineEnd              Save original I-code line end ptr
                    ldb       <CmdType              Get token type
                    cmpb      #$05                Type 5 (AND,OR,XOR,NOT)?
                    beq       CmpGroupArg               Yes, skip ahead
                    lbsr      OUTCXS               No, go force token $E & check for I-code overflow
CmpGroupArg               lbsr      FARG11
                    lbsr      CHKVAR
                    beq       RUN3         ..Yes; go get another parameter
                    pshs      a
                    lbra      FUNRE1         Check for ')' and put it in I-Code

INPUT               sty       <ScratchPtr
                    lbsr      FORVAR
                    bne       INPUT1
                    sty       <ScratchPtr
                    bsr       CheckIOSep         insure i/o separator follows
                    bsr       CMPRA9         (OUTCOD)
                    bsr       GOTO9         (STOP)
INPUT1               ldy       <ScratchPtr
                    cmpa      #$90          String literal found?
                    bne       INPUT4
                    lbsr      PRSLF
                    lbsr      GOTO9
INPU15               bsr       CheckIOSep
INPUT2               lda       #$4B
                    bsr       JmpOutcod         (OUTCOD) put COMMA in I-Code
INPUT4               bsr       GET10
                    lbsr      PRTSEP         (another) comma?
                    beq       INPUT2
INPUT9               rts

CheckIOSep               lbsr      PRTSEP
                    beq       INPUT9
                    bra       JmpCkcoma

PRINT               sty       <ScratchPtr
                    lbsr      FORVAR         Channel ref?
                    beq       PrintChanUsing
                    cmpa      #$49          Using?
                    beq       PRINT4
PRIN05               ldy       <ScratchPtr
                    bra       PrintListStart         No chl or using; go look for PRINT list

PrintChanUsing               cmpa      #$49
                    bne       CheckPrintSep
PRINT4               lbsr      ASSIG1
                    bra       CheckPrintSep

PRINT3               bsr       JmpOutcod
PrintListStart               lbsr      SkipSpaceLF
                    cmpa      #C$CR         end of line?
PRINT5               lbeq      STOP
                    cmpa      #'\           Other end of line?
                    beq       PRINT5
                    bsr       JmpSimpleStmt
CheckPrintSep               lbsr      PRTSEP
                    beq       PRINT3
                    rts

READ               sty       <ScratchPtr
                    lbsr      FORVAR
                    beq       INPU15
                    ldy       <ScratchPtr
                    bra       INPUT4

PUT8               sty       <ScratchPtr
                    lbsr      FORVAR
                    beq       CheckPrintSep
                    bra       PRIN05         get PRINT list
GET               bsr       PUT0
GET10               inc       <CmplxAsgFlag
                    lbra      ParseVarId         get variable id

PUT0               lbsr      FORVAR
                    bne       ERMCHL
JmpCkcoma               lbsr      CKCOMA
JmpOutcod               lbra      OUTCOD

CompileSeek               bsr       PUT0
JmpSimpleStmt               lbra      CompileExpr

* Data table for file access modes?
FileModeTab2               fcb       $2c,%00000001       Read mode?
                    fcb       $2d,%00000010       Write mode?
                    fcb       $f7,%00000011       Update mode?
                    fcb       $f8,%00000100       Execution dir mode?
                    fcb       $f9,%10000000       Directory mode?
                    fcb       $00                 End of table marker

CompileOpenCrt               lbsr      PRSLF
                    cmpa      #$54
                    bne       ERMCHL
                    bsr       GET10
                    bsr       JmpCkcoma
                    bsr       JmpSimpleStmt
                    lda       <CmdToken              Get token
                    cmpa      #$4C
                    bne       CompileRts2
                    lda       #$4A
* (orig: OPEN10)
                    bsr       JmpOutcod         (OUTCOD)
                    clr       ,-s
OpenModeLoop               bsr       STOP
                    leax      <FileModeTab2,pc           Point to table (modes?)
OPEN20               cmpa      ,x++
                    bhi       OPEN20               We need higher entry #, keep looking
                    bne       IllegalModeErr               Illegal, return error
                    ldb       -1,x                Get mode (read/write/update)???
                    orb       ,s                  Merge with mode on stack???
                    stb       ,s                  Save new mode???
                    bsr       STOP         get next token
                    cmpa      #$E7          more modes?
                    beq       OpenModeLoop
* (orig: ERIMOD)
                    lda       ,s+           get composit mode byte
                    bne       JmpOutcod         (OUTCOD) ..done if non-zero
IllegalModeErr               lda       #$0F                Illegal mode error?
                    bra       ERMCH9         (ERRDIE)

CLOSE0               lbsr      CHKVAR
                    bne       CompileRts2
                    bsr       JmpOutcod
CompileClose               lbsr      FORVAR
                    beq       CLOSE0
ERMCHL               lda       #$1C                Missing Path Number error
ERMCH9               lbra      ERRDIE

RESTOR               bsr       CompileOptLineRef
                    bra       STOP         get next (eol) token, exit

BASE               lbsr      SkipSpaceLF
                    leay      1,y
                    suba      #$30                Convert ASCII digit to binary
                    beq       STOP               If 0, skip ahead
                    cmpa      #1            is it a '1?
                    lbne      ERIOPD               If anything but 0 or 1, Illegal operand error
                    bsr       ERMASS               If 1, skip ahead
                    lda       #$36
                    lbsr      OUTCOD         replace with BASE1 token
                    bra       STOP

REM               ldx       <ICodeLineEnd              Get ptr to current I-Code end
                    lbsr      SkipSpaceLF         Skip spaces
                    clra
JmpOutcod3               lbsr      OUTCOD
                    inc       ,x            Update I-Code byte count
                    lda       ,y+                 Get char
                    cmpa      #C$CR               CR?
                    bne       JmpOutcod3               Nope, keep going
                    leay      -1,y                Bump ptr back to CR

STOP               lbsr      PRSLF               Check for command/constant/variable names
ERMASS               ldx       <ICodeLineSav              Get ptr to end of I-code line
                    stx       <ICodeLineEnd              Make it the current end ptr
                    lda       <CmdToken              Get token & return
CompileRts2               rts

CheckTokType               lda       <CmdType              Get token type
                    beq       CompileRts2               If 0, return
ERMAS9               lda       #12                 Exit with Illegal Statement Construction error
                    bra       ERMCH9         (ERRDIE)

ErrMissAssign               lda       #$1B                Missing Assignment Statement error
GotoErmCh9               bra       ERMCH9

ParseLet               lbsr      PRSLF

* Token types >2 go here
ParseExprType               bsr       CheckTokType
                    inc       <CmplxAsgFlag        Set complex assignment switch
                    lbsr      VARREF
PREFIX               lda       <CmdToken              Get token
                    cmpa      #$52                ??? Is it ':='?
                    beq       ASSIG1               Yes, skip ahead
                    cmpa      #$DD                ??? Is it '='?
                    bne       ErrMissAssign               No, exit with Missing Assignment statement error
* (orig: ASSIG9)
                    lda       #$53                Token=$53
ASSIG1               lbsr      OUTCOD               Go append to I-Code buffer
CompileExpr               lda       #$39
EXPRSN               ldx       <StrSpaceTop
                    clrb                    end marker (user supplied token) precedence=0
                    lbsr      OPRA85         set end mark in opstack
EXPR10               bsr       ParseAtom
                    lbsr      OPRATR         get operator
                    bcc       EXPR10         Repeat until none is present
EXPR90               rts

CompileOptLineRef               lbsr      SkipSpaceLF
                    lbsr      IsDigit         is the next char a number
                    bcs       EXPR90         ..No; return (carry set)
                    lda       #$3A                Go append $3A token to I-Code buffer
AppendLineRef               bsr       JmpOutcod2
                    lbsr      GETNUM
                    beq       REPFCT         Illegal number (real literal)
                    ldd       ,x
                    lbgt      PutSymInCode         Go put line number in I-Code; return
REPFCT               lda       #$10                Illegal Number error
                    bra       GotoErmCh9         (ERRDIE) exit via ERROR trap

ParseSymAndChk               bsr       ARRNA9
                    bsr       CheckTokType
ARRNA9               lbra      PRSLF

CompileRecRef               lda       #$8E
                    bsr       AppendLineRef
                    bsr       ARRNA9         (INSYM)
                    bra       CHKVAR         Test what you've gotten

IFFALS               clra
                    bsr       JmpOutcod2
                    bsr       JmpOutcod2
                    bra       GetChanToken

JmpOutcod2               lbra      OUTCOD

ParseVarId               bsr       ARRNA9
ChkTypeAndVar               bsr       CheckTokType
                    bra       VARREF

FORVAR               bsr       STOP
                    cmpa      #$54
                    bne       CHLRE9
                    bsr       ASSIG1
* 6809/6309 MOD: If A not required, CLRA
GetChanToken               lda       <CmdToken
                    orcc      #Zero         not ALPHA
CHLRE9               rts

ParseProcName               bsr       ARRNA9
                    lbsr      CheckTokType         Insure its a variable
FORVA9               lbra      STOP

PRTSEP               lda       <CmdToken
                    cmpa      #$51          Set found (eq)
                    beq       COMMA9         ..Yes; return
CHKVAR               lda       <CmdToken
                    cmpa      #$4B          is it a ',' token?
COMMA9               rts

CKCOMA               bsr       CHKVAR
                    beq       COMMA9
                    lda       #$1D          Error: illegal literal
                    bra       GotoErrdie2         (ERRDIE)

NODE1               clrb                    Precedence = 0
                    bsr       PUSHOP         push left paren token ON opstack
                    lbsr      ERMASS         remove it from I-Code
ParseAtom               bsr       PREF20
                    bsr       CheckPrefixOp
                    cmpa      #$4D
                    beq       NODE1         ..Yes; go handle a parenthetical expr
                    ldb       <CmdType
                    cmpb      #$06          is it a var ref token?
                    beq       FORVA9         ..Yes; ok-user type
                    cmpb      #$04          is it a reserved word?
                    bne       ChkTypeAndVar         ..No; go process variable reference
* (orig: ERIOP9)
                    lbra      FUNREF         ..Yes; handle it & return

ERIOPD               lda       #$12                Illegal operand error
GotoErrdie2               lbra      ERRDIE

CheckPrefixOp               cmpa      #$CD
                    beq       PREFX2         ..Yes; process as a polish operator
                    cmpa      #$EA
                    bne       COMMA9
* (orig: CHKRPR)
                    lda       ,y            get next source char
                    lbsr      IsDigit         is it a digit?
                    bcc       PREFX3         ..Yes; good - go get number
                    cmpa      #$2E          is it a period (fractional number)?
                    beq       PREFX3         ..Yes; good - go get number
                    lda       #$CE          Change minus token into negation
PREFX2               ldb       #$07
                    bsr       PUSHOP         Push PREFIX oprator ON opstack
                    lbsr      ERMASS         Remove token from I-Code
PREF20               lbra      PRSLF

PREFX3               leay      -1,y
                    lbsr      STATE8         Take '+/-' token out of I-Code buffer
                    lbra      PRSNUM         Parse numeric literal & return

PUSHOP               ldx       <StrSpaceTop
                    std       ,--x          push onto opstack
                    stx       <StrSpaceTop        update opstack ptr
                    rts

VARREF               ldd       #$8500
VARRE0               pshs      d
                    ldd       <UnusedWord_A1        get symbol ptr
                    bsr       PUSHOP         Push SYMPT onto opstack
                    puls      d
                    bsr       PUSHOP         Push smtyp ON opstack
                    lbsr      ERMASS         remove it from I-Code
                    lbsr      STOP         get next symbol
                    clrb                    Number of subsrcripts = 0
                    cmpa      #$4D          is it a '(' (array reference)?
                    beq       VARR25         ..Yes; go get subscript(s)
CheckRecordFld               cmpa      #$89
                    bne       VARRE9
                    bsr       CKCASS
                    bsr       VARRE9
* (orig: VARRE2)
                    bsr       PREF20
                    lbsr      CheckTokType         Add undefined name to symbol table
                    ldd       #$8900        token & SYMTYP = variable ref
                    bra       VARRE0         Process record

VARR25               bsr       CKCASS
                    incb                    Subscript count
                    pshs      b             save subscript count
                    lbsr      FARG11         get subscript expression
                    lbsr      CHKVAR         is it followed by a comma?
                    bne       VARRE3
                    ldb       ,s+           get subscript count
                    cmpb      #$03          is it < 3?
                    blo       VARR25         ..Yes; loop for another
                    lda       #$2A          Error: too many subscripts
                    lbra      ERRDIE         Exit via ERROR trap

VARRE3               bsr       ERMRPR
                    lbsr      STOP         get next symbol
                    puls      b             Restore number of subscripts
                    bra       CheckRecordFld         Go see if its a record or not

VARRE9               clr       <CmplxAsgFlag
                    ldx       <StrSpaceTop        get operator stack ptr
                    addb      ,x++          Pop variable ref token
                    lbsr      OUTCDB         (OUTCOD b)
                    ldd       ,x++          get SYMPT to variable
                    stx       <StrSpaceTop        save opstack ptr
                    lbra      PutSymInCode         Exit

CKCASS               tst       <CmplxAsgFlag
                    beq       NOTFN9         (rts) ..No; don't put in T.CXAS
                    clr       <CmplxAsgFlag        Clear content of assignment flag
OUTCXS               lda       #$0E
CKCAS9               lbra      OUTCOD

OPRATR               ldb       <CmdToken              Get token
                    clra
                    cmpb      #$4E          is it a right paren (pseudo operator)?
                    beq       OPRAT3         ..Yes; go do it with 0 precedence
                    tstb                    Component?
                    bpl       OPRAT1         ..No; not an operator
                    bsr       Vect1Fn12
                    bita      #$08          is it an operator?
                    bne       OPRAT3         ..Yes; good - go process it
OPRAT1               ldx       <StrSpaceTop
OPRAT2               ldd       ,x++
                    cmpa      #$4D          is it an OPEN parenthesis (for precedence)?
                    beq       ErrMissingRParen         ..Yes; error: missinng right parenthesis
                    bsr       CKCAS9         (OUTCOD) put token into I-Code
                    tstb                    This the end of the expression?
                    bne       OPRAT2         ..No; pop some more
                    cmpa      #$39
                    bne       NOTFN1
                    lbsr      STATE8         Remove (T.END) token from I-Code
NOTFN1               stx       <StrSpaceTop
                    coma                    EXPRSN that there wasn't an operator
NOTFN9               rts

OPRAT3               anda      #$07
                    tfr       a,b
                    ldx       <StrSpaceTop        get opstack ptr
                    bra       OPRAT5

OPRAT4               lda       ,x++
                    bsr       FARG09         (OUTCOD) put the operator in I-Code
OPRAT5               cmpb      1,x
                    blo       OPRAT4         ..current is lower; go pop some more
                    bhi       OPRAT8         ..prev prec is lower; go push operator
                    cmpb      #6            Power function?
                    beq       OPRAT8         ..Yes; push operator (right to left evaluation)
                    tstb                    This an ')' token (prec=0)?
                    bne       OPRAT4         ..No; pop the previous OPRATR into I-Code
                    lda       ,x++          Pop operator from stack
                    cmpa      #$4D          Was it a matching '('?
                    bne       OPRAT6         ..No; go check for an end token
                    stx       <StrSpaceTop        save opstack ptr
* (orig: PRSSTR)
                    bsr       FUNRE9         (STOP) get next symbol
                    bra       OPRATR         Go see if it's another operator

OPRAT6               cmpa      #$39
                    beq       ErrMissingLParen         ..Yes; error: missing left paren
                    bsr       FARG09
                    bra       NOTFN1         return not found

OPRAT8               lda       <CmdToken              Get token
OPRA85               std       ,--x
                    stx       <StrSpaceTop        save the opstack ptr
OPRAT9               rts

ERMRPR               lda       <CmdToken              Get token
                    cmpa      #$4E                ??? ^ or ** (power)?
                    beq       OPRAT9               Yes, return
ErrMissingRParen               lda       #$25
ERMRP9               lbra      ERRDIE

Vect1Fn12               jsr       <JmpVect1
                    fcb       $12

FUNREF               lbsr      STATE8
                    lda       <CmdToken              Get token
                    pshs      a                   Save it
                    bsr       FUNRE9         (STOP) get next token
                    ldb       ,s
                    bsr       Vect1Fn12
                    leax      <FUNRE1,pc           Point to routine
                    pshs      x             push Return addr
                    anda      #$03          get number of args of function
                    beq       FARG0         Process 0 argument functions
                    cmpa      #2
                    beq       ParseFarg2         Process 2 argument functions
                    bhi       ParseFarg3         Process 3 argument functions
                    ldb       2,s
                    cmpb      #$92
                    beq       ParseFargVarType
                    cmpb      #$94
                    beq       ParseFargVarType
                    cmpb      #$BE
                    beq       FARGVR
                    bra       FARG1         Process 1 argument functions

FUNRE1               bsr       ERMRPR
                    puls      a             Restore SRCPTR & return
                    lbsr      OUTCOD
FUNRE9               lbra      STOP

CHKLPR               lda       <CmdToken
                    cmpa      #$4D
                    beq       OPRAT9
ErrMissingLParen               lda       #$22
                    bra       ERMRP9         (ERRDIE) exit via ERROR trap

FARG0               leas      2,s
                    puls      a             Restore function token
FARG09               lbra      OUTCOD

FARG1               bsr       CHKLPR
FARG11               clra
                    lbsr      EXPRSN         Go get one expression
                    lbra      STATE8         Remove junk token from I-Code & return

ParseFarg2               bsr       FARG1
GetFarg2nd               lbsr      CKCOMA
                    bra       FARG11         get 2nd arg & return

ParseFarg3               bsr       ParseFarg2
                    bra       GetFarg2nd

FARGVR               bsr       CHKLPR
                    bsr       FUNRE9
                    cmpa      #$54
                    beq       FARG11
                    lbra      ERMCHL         Error: missing channel ref

ParseFargVarType               bsr       CHKLPR
                    incb                    Pre-token
                    lbsr      OUTCDB         out to I-Code
                    lbra      ParseVarId

ERBSYM               lda       #$0A                Unrecognized symbol error
                    bra       ERMRP9         (ERRDIE) exit via ERROR trap

* Search for operator's loop? (An LF is eaten and it returns here)
PRSLF               ldd       <ICodeLineEnd              Get current I-code line's end ptr
                    std       <ICodeLineSav              Dupe it here
                    lbsr      SkipSpaceLF               Find first non-space/LF char
                    sty       <ErrHandlerPtr              Save ptr to it
                    lbsr      CheckIdent               Check for variable name
                    lbne      PRSNAM               None, check for command names
                    lda       ,y                  Get first char of possible variable name
                    lbsr      IsDigit               Does it start with a number (0-9)?
                    bcc       PRSNUM               Yes, skip ahead
                    leax      >SpecSymsHdr+3,pc         No, point to Operator's table
                    lda       #$80                Get high bit mask to check for end of entry
                    lbsr      SEARC0               Go find entry
                    beq       ERBSYM               None, exit with Unrecognized symbol error
                    ldb       ,x                  Get offset
                    leau      <PRSHEX,pc           Point to base routine
                    jmp       b,u                 Go to subroutine

* '.' goes here
PRSPER               lda       ,y                  Get char from source
                    lbsr      IsDigit         is it a decimal digit?
                    bcs       OutcodeHex         ..No; go put record separater in I-Code
                    leay      -1,y          Point to decimal point
* Starts with numeric (0-9) value
PRSNUM               bsr       GETNUM
                    bne       NUMVA3         Real?
                    ldd       #$8F05              Token=$85, count=5
NUMVA0               sta       <CmdToken
StoreNumBytes               bsr       PRSST9
                    lda       ,x+           get next byte of number
                    decb
                    bpl       StoreNumBytes         Loop until end of this entry
                    lda       #6            get 'literal' symbol type
                    sta       <CmdType              Save type (?) as 6
                    rts                     return

NUMVA3               ldd       #$8E02
                    tst       ,x            is this really a byte literal?
                    bne       NUMVA0         ..No; go put integer in I-Code
                    ldd       #$8D01        get byte lit token & size
                    leax      1,x
                    bra       NUMVA0

* Almost all operators come here
OutcodeHex               ldd       1,x                 Get the 2 mystery bytes
* Command found comes here with D=2 byte # in command table
SaveCmdToken               std       <CmdToken              Save token & type byte
                    bra       OUTCOD         Finish variable allocation

* '$' goes here
PRSHEX               leay      -1,y                Bump source ptr back by 1
                    bsr       GETNUM
                    ldd       #$9102
                    bra       NUMVA0

GETNUM               lbsr      SkipSpaceLF               Find 1st non-space/lf char
                    leax      ,y                  Point x to the char
                    ldy       <StrSpaceTop        get error addr
                    bsr       Vect6Fn0b               Call vector <2A, function 00
                    exg       x,y
                    bcs       IllegalLitErr               If error from vector, illegal literal error
* (orig: ERILIT)
                    lda       ,x+
                    cmpa      #2
                    rts

Vect6Fn0b               jsr       <JmpVect6
                    fcb       $00

IllegalLitErr               lda       #$16                Illegal literal error
                    bra       ERNOQ9

* '"' goes here
StartStrLit               bsr       OutcodeHex
                    bra       SKIPSP

StrLitLoop               bsr       OUTCOD
SKIPSP               lda       ,y+                 Get char from source
                    cmpa      #C$CR               End of line already?
                    beq       ErrNoEndQuote               Yes, no ending quote error
                    cmpa      #'"                 Is it the quote?
                    bne       StrLitLoop               No, keep looking
                    cmpa      ,y+                 Double quote?
                    beq       StrLitLoop               Yes, do something
                    leay      -1,y                No, set src ptr back to next char
* (orig: ERNOQU)
                    lda       #$FF                Go save $FF at this point in I-code line
PRSST9               bra       OUTCOD

ErrNoEndQuote               lda       #$29                No Ending Quote error
ERNOQ9               lbra      ERRDIE               Deal with error

UndefVarErr               lda       #$31                Undefined Variable error
                    bra       ERNOQ9

* Check for command names
PRSNAM               ldx       <CmdTablePtr              Get ptr to commmands token list
                    lbsr      SCHALL               Go find command
                    beq       PRSNA2               No command found, skip ahead
                    stx       <UnusedWord_A1              Save ptr to command's 2 byte # in table
                    ldd       ,x                  Get 2 byte # from command's entry in table
SaveTokAndOut               std       <CmdToken              Save token & type bytes
                    bra       OUTCOD               Go check size of I-code line

PRSNA2               tst       <BreakFlag
                    bmi       UndefVarErr
                    ldx       <ModSymTbl
                    lbsr      SCHALL
                    bne       PRSNA3
                    tst       <BreakFlag
                    bne       UndefVarErr
                    lbsr      ADDSYM
PRSNA3               ldd       #$8500
                    bsr       SaveTokAndOut               Go append token $85, type 0 & check for overflow
                    tfr       x,d
                    subd      <ModSymTbl
                    std       <UnusedWord_A1
PutSymInCode               bsr       OUTCOD
                    bsr       OUTCDB
                    lda       <CmdToken              Get token & return
                    rts

OUTCDB               tfr       b,a
OUTCOD               pshs      x,d                 Preserve Table ptr & 2 mystery bytes
                    ldx       <ICodeLineEnd              Get ptr to end of current I-code line
                    sta       ,x+                 Save token for operator
                    stx       <ICodeLineEnd              Save new end of current I-code line ptr
                    ldd       <ICodeLineEnd              Get it again
                    subd      <ICodeEndPtr              Calculate current I-code line size
                    cmpb      #255                Past maximum size?
                    bhs       ICodeOverflow               Yes, generate error
                    clra                          No, no error
                    puls      pc,x,d              Restore regs & return

ICodeOverflow               lda       #$0d                I-Code Overflow error
                    lbsr      Vect1Fn2               Print error message
                    jsr       <JmpVect1              ??? Reset temp buff to defaults, SP restore from B7
                    fcb       $06

NAMSYM               bsr       SkipSpaceLF               Search for 1st non-space/LF char
CheckIdent               pshs      y                   Save ptr to it on stack
                    ldb       #2                  ??? Flag to indicate non-variable name
                    stb       <NameStrType
                    clrb                          Set variable name size to 0
                    bsr       IsAlphaUnder               Check if it is an alphabetic char or underscore
                    bcs       NAMSY9               Nope, skip ahead
                    leay      1,y                 Yes, point to next char
NAMSY1               incb                          Bump up variable name size
                    lda       ,y+                 Get next char
                    bsr       IsAlphaNumUnd               Check if it is a letter, number or _
                    bcc       NAMSY1               Yes, check next one
                    cmpa      #'$                 Is it a string indicator?
                    bne       NAMSY2               No, skip ahead
                    incb                          Bump up variable name size to include '$'
                    lda       #4                  ??? Flag to indicate variable name?
                    sta       <NameStrType
                    bra       FinishNameStr               Skip ahead

NAMSY2               leay      -1,y                Bump source ptr back by 1
FinishNameStr               lda       #$80                Get high bit (OIM on 6309)
                    ora       -1,y                Set high bit on last char of variable name
                    sta       -1,y                Save it back
NAMSY9               stb       <NameStrSz              Save size of variable name
                    puls      pc,y                Restore source ptr & return

* Find first non-space / non-LF char, and point Y to it
SkipSpaceLF               lda       ,y+                 Get char from source
                    cmpa      #C$SPAC             Is it a space?
                    beq       SkipSpaceLF               Yes, get next char
                    cmpa      #C$LF               Is it a line feed?
                    beq       SkipSpaceLF               Yes, get next char
                    leay      -1,y                Found legitimate char, point Y to it
                    rts

* Check if char is letter, number or _
IsAlphaNumUnd               bsr       IsAlphaUnder               Check if next char is letter or _
                    bcc       IsAlphaDone               Yes, exit with carry clear
IsDigit               cmpa      #'0                 Is it a number?
                    blo       IsAlphaDone               No, return with carry set
                    cmpa      #'9                 Is it a number?
                    bls       ALPHA8               Yes, exit with carry clear
                    bra       ALPHA7               No, exit with carry set

* Check if char is a letter (or underscore)
* Entry: A=last char gotten (non-space/Lf)
* Exit: Carry clear if A-Z, a-z or '_'
*       Carry set if anything else
IsAlphaUnder               anda      #$7F                Take out any high bit that might exist
                    cmpa      #'A                 Is it lower than a 'A'
                    blo       IsAlphaDone               Yes, skip ahead (carry set)
                    cmpa      #'Z                 Is it an uppercase letter?
                    bls       ALPHA8               Yes, clear carry & exit
                    cmpa      #'_                 Is it an underscore?
                    beq       IsAlphaDone               Yes, exit (carry is clear)
                    cmpa      #'a                 Is it a [,\,],^ or inverted quote ($60)?
                    blo       IsAlphaDone               Yes, skip ahead (carry set)
                    cmpa      #'z                 Is it a lowercase letter?
                    bls       ALPHA8               Yes, exit
ALPHA7               orcc      #$01                Error, non-alpha char
                    rts

ALPHA8               andcc     #$FE                No error, alphabetic char
IsAlphaDone               rts

ADDSYM               ldx       <ModSymTbl
                    ldd       -3,x
                    addd      #1                  INCD
                    std       -3,x
                    ldb       <NameStrSz              Get size of var name/ (or string?)
                    clra                          D=Size
                    addd      #3                  Add 3 to size
                    sty       <ScratchPtr
                    bsr       EXPSYM
                    pshs      y
                    lda       <NameStrType
                    clrb
                    std       ,y++
                    stb       ,y+
                    ldx       <ScratchPtr
ADDSY1               lda       ,x+
                    sta       ,y+
                    bpl       ADDSY1
                    leay      ,x            get ptr/size ptr
                    puls      pc,x

CheckWkspFit               pshs      u,d
                    ldd       <WorkspaceFree
                    subd      ,s
                    bcc       EXPDS1         ..No
                    lda       #$20          Err: unimplemented routine
                    lbra      ERRDIE

EXPDS1               std       <WorkspaceFree
                    ldd       <SymTblSize
                    subd      ,s
                    std       <SymTblSize
                    ldu       <DescrAreaOff
                    ldd       <DescrAreaOff
                    subd      ,s
                    std       <DescrAreaOff        set descr area offset
                    tfr       d,y
                    ldd       <SymTblSize        get symbol tbl size
                    subd      <DescrAreaOff        Re-adjust
                    addd      <StorageOff        add link size
                    bsr       MOVDWN
                    ldd       <StorageOff        get storage offset
                    addd      ,s++
                    std       <StorageOff
                    leax      ,u
                    puls      pc,u

EXPSYM               pshs      u,d
                    bsr       CheckWkspFit
                    subd      ,s
                    std       <StorageOff
                    leau      ,x
                    leax      $03,y
                    stx       <ModSymTbl
                    ldd       <ModSzData        get procedure ptr
                    bsr       MOVDWN
                    addd      ,s++
                    std       <ModSzData
                    leax      ,u
                    puls      pc,u

MOVDWN               pshs      x,d
                    leax      d,u
                    pshs      x
MOVDW1               bitb      #$03
                    beq       MOVDW3
                    lda       ,u+
                    sta       ,y+
                    decb
                    bra       MOVDW1

MOVDW2               pulu      x,d
                    std       ,y++
                    stx       ,y++
MOVDW3               cmpu      ,s
                    blo       MOVDW2
                    clr       ,s++
                    puls      pc,x,d

* Entry point from PRSNAM
SCHALL               lda       #%00100000          Bit pattern to test for end of entry
* Entry: X=Table ptr (ex. command table)
*        Y=Source ptr
*        A=Mask to check for end of entry (%10000000)
*        U=??? (just preserved)
* Exit:  X=Ptr to 2 byte # before matching text string
*        Y=Ptr to byte after matching entry in source
*        Zero flag set if no matching entry found
SEARC0               pshs      u,y,x,a             Save everything on stack
                    ldu       -3,x                Get # of entries in table
                    ldb       -1,x                Get # bytes to skip to next entry
* Loop to find entry (or until table runs out)
SEARC1               stx       1,s                 Save new table ptr
                    cmpu      #$0000              Done all entries?
                    beq       SearchTableDone               Yes, exit
                    leau      -1,u                Bump # entries left down
                    ldy       3,s                 Get source ptr
                    leax      b,x                 Point to next entry
SEARC3               lda       ,x+                 Get byte from table
                    eora      ,y+                 Match byte from source?
                    beq       SEARC6               Yes, skip ahead
                    cmpa      ,s                  Just high bit set (end of entry marker)?
                    beq       SEARC6               Yes, skip ahead
                    leax      -1,x                No, bump table ptr back by 1
SEARC5               lda       ,x+                 Get byte
                    bpl       SEARC5               Keep reading until high bit found (end of entry)
                    bra       SEARC1               Go loop to check this entry

* Found a byte match (with or w/o high bit)
SEARC6               tst       -1,x                Check the byte
                    bpl       SEARC3               If not at end of entry, keep looking
                    sty       3,s                 Entry matched, save new source ptr
SearchTableDone               puls      pc,u,y,x,a          Restore regs & return

PLREF               pshs      x,d                 Preserve regs
                    ldb       [<$04,s]            Get table entry #
                    leax      <CmpJmpTbl,pc           Point to vector table
                    ldd       b,x                 Get vector offset
                    leax      d,x                 Calculate vector
                    stx       4,s                 Replace original RTS address with vector
                    puls      pc,x,d              Restore regs and go to new routine

* Jump table
CmpJmpTbl               fdb       PrunStmtBody-CmpJmpTbl         $06e6
                    fdb       BIND-CmpJmpTbl         $0b36
                    fdb       PSTMT-CmpJmpTbl         $0128
                    fdb       PRT4HX-CmpJmpTbl         $0193

* Jump table
CompilerBase               fdb       CompileStrExpr-CompilerBase         $0786
                    fdb       PPARAM-CompilerBase         $01fe
                    fdb       PTYPE-CompilerBase         $01a7
                    fdb       SetDimTypeFlag-CompilerBase         $0202
                    fdb       PDataFirst-CompilerBase         $03a9
                    fdb       PPRINT-CompilerBase         $0707
                    fdb       JmpSkpeol-CompilerBase         $079f
                    fdb       JmpSkpeol-CompilerBase         $079f
                    fdb       JmpSkpeol-CompilerBase         $079f
                    fdb       PPRINT-CompilerBase         $0707
                    fdb       JmpSkpeol-CompilerBase         $079f
                    fdb       JmpSkpeol-CompilerBase         $079f
                    fdb       JmpSkpeol-CompilerBase         $079f
                    fdb       PLET-CompilerBase         $03D3
                    fdb       PASSGN-CompilerBase         $03D1
                    fdb       PPOKE-CompilerBase         $0423
                    fdb       PIF-CompilerBase         $04AF
                    fdb       PELSE-CompilerBase         $04CA
                    fdb       PRUN-CompilerBase         $04E1
                    fdb       PFOR-CompilerBase         $04F3
                    fdb       PNEXT-CompilerBase         $058B
                    fdb       PWHILE-CompilerBase         $05DA
                    fdb       PEWHL-CompilerBase         $05E8
                    fdb       PREPT-CompilerBase         $0600
                    fdb       PUNTIL-CompilerBase         $0607
                    fdb       PLOOP-CompilerBase         $061b
                    fdb       PEndloop-CompilerBase         $061f
                    fdb       PEXIF1-CompilerBase         $0623
                    fdb       PEEXT-CompilerBase         $0640
                    fdb       PON-CompilerBase         $042a
                    fdb       CompileNumExpr-CompilerBase         $0499
                    fdb       PGOTO-CompilerBase         $044b
                    fdb       UnimplRtnErr-CompilerBase         $0b0c
                    fdb       PGOTO-CompilerBase         $044b
                    fdb       UnimplRtnErr-CompilerBase         $0b0c
                    fdb       CompileRunStmt-CompilerBase         $069e
                    fdb       CompileStrExpr-CompilerBase         $0786
                    fdb       CompileIOStmt-CompilerBase         $06e4
                    fdb       PPRINT-CompilerBase         $0707
                    fdb       CompileStrExpr-CompilerBase         $0786
                    fdb       CompileStrExpr-CompilerBase         $0786
                    fdb       CompileSeekVar-CompilerBase         $0745
                    fdb       CompileSeekVar-CompilerBase         $0745
                    fdb       PSEEK-CompilerBase         $0761
                    fdb       CompileIOStmt-CompilerBase         $06e4
                    fdb       PPRINT-CompilerBase         $0707
                    fdb       PCLOSE-CompilerBase         $076f
                    fdb       PCLOSE-CompilerBase         $076f
                    fdb       CompileRestore-CompilerBase         $0779
                    fdb       PREST-CompilerBase         $0797
                    fdb       CompileStrExpr-CompilerBase         $0786
                    fdb       CompileStrExpr-CompilerBase         $0786
                    fdb       CompileStrExpr-CompilerBase         $0786
                    fdb       JmpSkpeol-CompilerBase         $079f
                    fdb       JmpSkpeol-CompilerBase         $079f
                    fdb       PREMRK-CompilerBase         $0147
                    fdb       PREMRK-CompilerBase         $0147
                    fdb       PPRINT-CompilerBase         $0707
                    fdb       CompileLineNum-CompilerBase         $00dc
                    fdb       UnimplRtnErr-CompilerBase         $0b0c
                    fdb       UnimplRtnErr-CompilerBase         $0b0c
                    fdb       PERRLN-CompilerBase         $0140
                    fdb       SKPEOL-CompilerBase         $0197
                    fdb       SKPEOL-CompilerBase         $0197

* Table (called from ExprSpecialTok) - If 0, does something @ UnimplRtnErr, otherwise, AND's
*   with $1F, multiplies by 2, and uses result as offset to branch table @
*   ExprArgJmpTbl
BindOpCodeTbl               fcb       $20,$20,$06,$00,$43,$40,$28,$25,$00,$43,$43,$43,$43,$43,$43,$43
                    fcb       $05,$00,$43,$43,$43,$00,$45,$00,$25,$00,$45,$00,$05,$00,$21,$21
                    fcb       $47,$27,$27,$22,$22,$22,$60,$60,$61,$87,$8a,$89,$89,$81,$85,$00
                    fcb       $80,$81,$e0,$e0,$e0,$e0,$e0,$6b,$05,$00,$6c,$6c,$6c,$6d,$00,$00
                    fcb       $6d,$00,$00,$6e,$00,$00,$00,$6e,$00,$00,$00,$6d,$00,$00,$6d,$00
                    fcb       $00,$0d,$00,$00,$06,00,$06,$00,$06,$00,$44,$44

CompileLineNum               ldd       ,y
                    tst       <BinderMode
                    bne       LineNumSkipSmash         ..No
                    pshs      d             save line number
* (orig: PLRE10)
                    leay      -1,y          Backup to token
* (orig: PEIF)
                    ldd       <ModFOff        copy I-Code limit
PLRE20               std       <ICodeLineEnd
                    ldd       #3            Delete three bytes
                    lbsr      Vect1Fn14         Call replacer
                    puls      d             Retrieve line number
                    bra       SearchLineNum

LineNumSkipSmash               leay      2,y
SearchLineNum               lbsr      SRHLIN
                    bcc       PLRE50         bra if already defined
                    std       ,x            Define line number (clear sign)
                    tfr       y,d           copy I-Code ptr
                    subd      <ModExecAddr        Make ptr into offset
* (orig: PLRE40)
                    leax      2,x           get ptr to header link
PLRE30               ldu       ,x
                    std       ,x            set offset in goto
FixupGotoChain               leax      ,u
                    bne       PLRE30         bra if not end
                    bra       PSTMT         Go do stmt

PLRE50               lda       #$4B                Multiply-defined Line Number error
                    bsr       ERROR               Go print (Y-<ModExecAddr) to std err in hex
PSTMT               leax      >CompilerBase,pc           Point to table
                    ldb       ,y+                 Get byte
                    bpl       GetStmtOffset               If high bit off, go get offset from table
                    ldd       #PASSGN-CompilerBase        Otherwise force to use PASSGN offset
                    bra       PSTMT2               Skip ahead

GetStmtOffset               lslb                          Multiply by 2
                    clra                          16 bit offset required
                    ldd       d,x                 Get offset
                    cmpd      #PASSGN-CompilerBase        Is it the special case one?
                    blo       PSTMT3               If it or any lower offset, go execute it
PSTMT2               tst       <CmdExecFlag              ??? If ?? set, go execute routine
                    bne       PSTMT3         Yes; go do it
                    inc       <CmdExecFlag              Set flag
                    pshs      d                   Preserve offset
                    tfr       y,d                 ??? Move current location to D
                    subd      <ModExecAddr              Subtract something
                    subd      #$0001              Subtract 1 more
                    ldu       <CurModPtr              Get 'current' module ptr
                    std       $15,u               ??? Save some sort of size into module header?
                    puls      d                   Get offset back
PSTMT3               jmp       d,x                 Jump to routine

PERRLN               ldx       <CurModPtr              Get ptr to current module
                    lda       #$01                Flag for Line with Compiler error
                    sta       <$17,x              Save in flag header byte
PREMRK               ldb       ,y+                 Get offset byte
                    clra                          Make 16 bit
                    leay      d,y                 Point Y to it & return
                    rts

UnimplRtnErr               ldy       <ModFOff
                    lda       #$30                Unimplemented Routine error
* ERROR MESSAGE REPORT:
* Prints Hex # address of where error occurs, & error message on screen
* Entry: Y=# to convert to hex after subtracting <ModExecAddr
* Exit: Writes out 4 digit hex # & space
ERROR               pshs      y,x,d               Preserve regs
                    ldx       <CurModPtr              Get Ptr to current module
                    lda       #$01                Set Line with compiler error flag in mod. header
                    sta       <$17,x
                    lda       <PackedFlag              Get flag???
                    bmi       ERRO10               If high bit set, don't print address
                    ldd       4,s                 Get # to convert (current addr?)
                    subd      <ModExecAddr              ??? Subtract start?
                    leas      -5,s                Make 5 byte buffer
                    leax      ,s                  Point X to it
                    bsr       PRT4HX               Convert D to 4 digit HEX characters
                    lda       #C$SPAC             Add Space
                    sta       ,x+
                    lda       #2                  Std error path
                    leax      ,s                  Point to buffer
                    ldy       #5                  Write out the hex number
                    os9       I$Write       Print it
                    leas      5,s                 Eat temporary buffer
                    ldb       ,s                  Get error code
                    lbsr      Vect1Fn2               Print error message
ERRO10               puls      pc,y,x,d            Restore regs & return

* Convert 16 bit number to ASCII Hex equivalent (Addresses in LIST?)
* Result is stored at ,X
PRT4HX               bsr       PRT2HX               Convert A to hex
                    tfr       b,a                 Convert B to hex
PRT2HX               pshs      a                   Preserve byte
                    lsra                          Do high nibble first
                    lsra
                    lsra
                    lsra
                    bsr       PRTHEX               Convert to ASCII Hex equivalent
                    puls      a                   Get back original byte
                    anda      #$0F                Do low nibble now
PRTHEX               adda      #$30                Make ASCII
                    cmpa      #'9                 Past legal numeric?
                    bls       PRTHE1               Yes, save ASCII version
                    adda      #$07                Bump >9 up to A-F for Hex
PRTHE1               sta       ,x+                 Save Hex ASCII version & return
                    rts

SKPEOL               ldb       ,y                  Get char(?)
                    bsr       EOLTST               Check if it is $3E or $3F > or ?
                    bne       PEOL10               Neither, return
SKPONE               leay      1,y                 Yes, bump Y up & return
PEOL10               rts

EOLTST               cmpb      #$3F
                    beq       EolTestRts         ..Yes
                    cmpb      #$3E
EolTestRts               rts

PTYPE               lbsr      GETTYP
                    ldb       <VarDefByte        defined?
                    beq       PTYPE1         No; good
                    lda       #$4C                Multiply-defined Variable error
                    bsr       ERROR               Go print hex version of (Y-<ModExecAddr)
PTYPE1               leay      4,y                 Bump ptr up by 4
                    lda       #$40
                    sta       <VarTypeFlag
                    ldd       <CurVarSz        get current variable alocation
                    pshs      d             save it
                    clra
                    clrb                    Allocation for record
                    std       <CurVarSz
                    bsr       PDECLR         Process component declarations
                    ldd       <CompListPtr        get ptr to end of list
                    subd      <ModFOff        get size of declr
                    beq       RestoreVarAlloc         bra if all errors
                    addd      #3            get description area base
                    cmpd      <WorkspaceFree
                    lbcc      PBEXPR
                    pshs      y,x           save symbol ptr & I-Code ptr
                    lbsr      Vect2Fn8         get descr area
                    ldd       <CurVarSz        set rcd size
                    leau      ,y            copy descr ptr
                    std       ,y++
                    clr       ,y+           Clear component count
                    ldx       <ModFOff              Get address of $F offset in header
PTYPE2               ldd       ,x++                Get value there
                    subd      <ModSymTbl        Make ptr into offset
                    std       ,y++          put in descr area
                    inc       2,u           Count component
                    cmpx      <CompListPtr        are there more components?
                    blo       PTYPE2
                    tfr       u,d
* (orig: PTYPE3)
                    puls      y,x
                    subd      <SymTblSize
                    std       1,x           put in symbol tbl
                    lda       #$25
                    sta       ,x            set type byte
RestoreVarAlloc               puls      d
                    std       <CurVarSz        Restore variable allocation
                    rts

PPARAM               lda       #$80
                    bra       PDIM1

SetDimTypeFlag               lda       #$60
PDIM1               sta       <VarTypeFlag
PDECLR               ldd       <ModFOff
                    pshs      x,d
                    std       <CompListPtr        set beginning of component list
PDECL1               bsr       PID
                    ldb       ,y+           get type byte
                    cmpb      #$4B
                    beq       PDECL1
                    cmpb      #$4C
                    beq       PDECL2         Yes; go get it
                    leay      -1,y          Back up to unknown
                    ldb       #$01          set flag for implicit typing
                    bra       PDECL3

PDECL2               lbsr      GetVarType
                    clrb                    Flag for explicit typing
PDECL3               pshs      y,b
                    ldx       3,s           get beginning of component list
                    ldd       <CompListPtr        get end of list
                    std       3,s           save end for looping
                    stx       <CompListPtr
                    subd      <CompListPtr
                    lslb                          D=D*2
                    rola
                    addd      3,s
                    cmpd      <DescrAreaOff
                    blo       CheckListBound
                    lbra      PBEXPR

PDECL4               ldu       ,x++                Get some sort of var ptr
                    tst       ,s            Test flag
                    beq       DefVarCall         bra if explicit
                    lda       ,u                  Get var type
                    sta       <VarTypeCode              Save it
                    lbsr      GETVSZ               D=size of var in bytes
                    std       <VarByteSize              Save size
DefVarCall               lbsr      DEFVAR
CheckListBound               cmpx      3,s
                    blo       PDECL4
                    ldd       <CompListPtr        Mark current position in stack
                    std       3,s
                    puls      y,b           Clean stack, restore I-Code ptr
                    ldb       ,y+           get next token
                    cmpb      #$51          is there another list?
                    beq       PDECL1         Yes
                    puls      pc,x,d

PID               lbsr      GETTYP
                    ldb       <VarDefByte        already defined?
                    beq       PID1         No; good
                    lda       #$4C                Multiply-defined Variable error
                    lbsr      ERROR
                    leay      3,y           Skip varref
                    ldb       ,y            get following token
                    cmpb      #$4D
                    bne       PID20
                    leay      1,y
PID10               bsr       GETSIZ
                    ldb       ,y+
                    cmpb      #$4B
                    beq       PID10         ..Yes
PID20               rts

PID1               ldd       <CompListPtr
                    addd      #$000A
                    cmpd      <DescrAreaOff        Memory full?
                    lbhs      PBEXPR         ..No; abort
                    ldx       <CompListPtr        get component list ptr
                    ldd       <SymbolPtr        get symbol ptr
                    std       ,x++          put in component list
                    leau      ,x            copy ptr to subscript count
                    clr       ,x+           Clear subscript count
                    leay      3,y           Move past id
                    ldb       ,y            get next token
                    cmpb      #$4D
                    bne       PID3
                    leay      1,y           Skip '('
PID2               bsr       GETSIZ
                    std       ,x++          put in component list
                    inc       ,u            Count it
                    ldb       ,y+           get next token
                    cmpb      #$4B          Another subscript?
                    beq       PID2         Yes; get it
PID3               stx       <CompListPtr
                    rts

GETSIZ               ldb       ,y+
                    clra                    Msb
                    cmpb      #$8D          byte?
                    beq       GetsizByte         Yes
* (orig: PVTYPE)
                    lda       ,y+           get msb value
GetsizByte               ldb       ,y+
                    rts

GetVarType               lda       ,y+
                    cmpa      #$85          user type?
                    beq       GetUserType         Yes; handle it
                    suba      #$40          Convert token to type
                    sta       <VarTypeCode              Save var type
                    cmpa      #4                  String type?
                    bne       PVTYP1               No, skip ahead
* (orig: PRPRAM)
                    ldb       ,y            get token after type
                    cmpb      #$4F          '['?
                    bne       PVTYP1         No; do more
* (orig: PVTYP2)
                    leay      1,y           Skip '['
                    bsr       GETSIZ         get size
                    leay      1,y           Skip ']'
                    bra       SaveVarByteSize

PVTYP1               lbsr      GETVSZ               Go get size of var
                    bra       SaveVarByteSize               Go save size @ VarByteSize

GetUserType               leay      -1,y
                    lbsr      GETTYP         get symbol ptr; decode type byte
                    leay      3,y           Move I-Code ptr
                    ldb       <VarDefByte        get definition
                    cmpb      #$20          type definition?
                    beq       PVTYP3         Yes; good
                    lda       #$18                Illegal Type suffix error
                    lbra      ERROR

PVTYP3               ldd       1,x
                    std       <SymbolPtr        save it
                    ldx       <SymTblSize
                    ldd       d,x                 Get size of var
SaveVarByteSize               std       <VarByteSize              Save size of var & return
                    rts

DEFVAR               ldb       ,x+
                    beq       DEFV07
                    pshs      b             save count
                    lslb
                    lslb
                    lslb
                    stb       <VarTypeHi        save it
                    lsrb                    Back
                    lsrb
                    leax      b,x           get ptr to next variable
                    addb      #4            add for offset & totalsize
                    pshs      u,x           save variable stack ptr & symbol ptr
                    lda       <VarTypeCode              Get var type
                    cmpa      #4                  Numeric type?
                    blo       DEFV02               Yes, skip ahead
                    addb      #2                  If string or complex, add 2 to type
DEFV02               clra                    Msb
                    cmpd      <WorkspaceFree        enough room?
                    lbhi      PBEXPR         ..No; abort
                    lbsr      Vect2Fn8         get description area
                    ldx       ,s            get variable stack ptr
                    leau      2,y           get ptr to total size
* (orig: DEFV03)
                    ldd       #$0001        set totalsize
                    std       ,u++          put in descr area
DefVarDimLoop               ldd       ,--x
                    std       ,u++          put in descr area
                    bsr       DIMMUL         Multiply subscript by size
                    dec       4,s           Count down
                    bne       DefVarDimLoop         bra if more
                    lda       <VarTypeCode              Get var type
                    cmpa      #4                  Numeric or string?
                    bls       SaveVarSize               Yes, skip ahead
* (orig: DEFV05)
                    ldd       <SymbolPtr              No, (complex?)
* NOTE: Since 28BC only referred to here, should be able to change std ,u/coma
*   to bra L28C0 (std ,u)
                    std       ,u                  Save ???
                    coma                          Set carry to indicate complex?
SaveVarSize               ldd       <VarByteSize              Get size of var in bytes
                    bcs       DEFV06               If complex, don't save sign again
                    std       ,u                  Save size
DEFV06               bsr       DIMMUL               ??? Do some multiply testing based on size?
                    tfr       y,d           copy descr ptr
                    puls      u,x           get symbol ptr, I-Code ptr
                    subd      <SymTblSize        Make ptr into offset
                    std       1,u           put in symbol tbl
                    leas      1,s           Return scratch
                    bra       DEFV10

DEFV07               stb       <VarTypeHi
                    lda       <VarTypeCode              Get var type
                    cmpa      #4                  Normal type (numeric/string)?
                    bhi       GetComplexPtr               No, skip ahead
* (orig: DEFV08)
                    ldd       <VarByteSize              Get size of var
                    bra       DEFV09               Skip ahead

GetComplexPtr               ldd       <SymbolPtr              Get ??? (something with complex type?)
DEFV09               std       1,u                 Save size
DEFV10               lda       <VarTypeCode              Get var type
                    ora       <VarTypeHi              Keep common bits with ???
                    ora       <VarTypeFlag              Keep common bits with ???
                    sta       ,u                  Save ???
* (orig: START)
                    pshs      x             save variable stack ptr
                    leax      ,u            copy symbol ptr
                    lbsr      ALCSTO         Go allocate storage
                    ldx       <CompListPtr        get component list
                    stu       ,x++          put symbol ptr in list
                    stx       <CompListPtr        save component ptr
                    puls      pc,x

* Check if size of array will be too big
DIMMUL               pshs      d
                    ldb       2,y           get totalsize msb
                    mul
                    bne       DIMERR         ..No
                    lda       1,s
                    ldb       2,y
                    mul
                    tsta
                    bne       DIMERR         ..Yes
                    stb       2,y
                    lda       ,s
                    ldb       3,y           get totalsize lsb
                    mul
                    tsta
                    bne       DIMERR         Yes
                    addb      2,y           add previous partial
                    bcs       DIMERR         bra if overflow
                    stb       2,y           save partial
                    lda       1,s           get multiplier lsb
                    ldb       3,y           get totalsize lsb
                    mul
                    adda      2,y           add previous partial
                    bcs       DIMERR         bra if overflow
                    std       2,y           put in descr area
                    puls      pc,d          Restore size & return

DIMERR               lda       #$49                Array Size Overflow error
                    lbsr      ERROR
                    puls      pc,d          Restore size & return

PDataFirst               ldu       <DataStmtCur
                    bne       PDataUpdate         bra if there was one
                    tfr       y,d           copy I-Code ptr
                    subd      <ModExecAddr
                    std       <DataStmtBase        set first data stmt
                    bra       PDATA2

PDataUpdate               tfr       y,d
                    subd      <ModExecAddr        Make ptr into offset
                    std       ,u
***************
* Process Expressions
PDATA2               lbsr      PEXPRN
                    lbsr      POPOP         Keep opstack clear
                    ldb       ,y+
                    cmpb      #$4B          is there another expression
                    beq       PDATA2         Yes; go do it
                    sty       <DataStmtCur        save ptr to this data stmt
                    ldd       <DataStmtBase        get offset of first stmt
                    std       ,y++          put in this one
                    lbra      SKPONE         Skip end of line

PASSGN               leay      -1,y
PLET               bsr       PASGVR
                    leay      1,y
                    lbsr      PEXPRN         Process expression
                    lbsr      POPOP         get result type
                    sta       <VarTypeCode              Save var type
                    lbsr      POPOP
                    cmpa      <VarTypeCode              Same as var type?
                    beq       PASSG4               Yes, skip ahead
                    cmpa      #2                  Var type from 2E52=Boolean/string/complex?
                    bhi       PAssgComplex               Yes, skip ahead (print some hex # out)
                    beq       PAssgReal               Real #, skip ahead
* (orig: PASSG1)
                    lda       #$C8          Fix real for integer destination
                    bra       PASSG2

PAssgReal               lda       #$CB
PASSG2               ldb       <VarTypeCode              Get var type
                    cmpb      #2                  Boolean/string/complex?
                    bhi       PAssgComplex               Yes, skip ahead
                    lbsr      INSTOK               Byte/Integer/Real, go do something
                    bra       PASSG4

PAssgComplex               lbsr      ERIET
PASSG4               lbra      SKPEOL               ??? Do some checking ,y, return from there

PASGVR               lda       ,y
                    cmpa      #$0E          complex assignment?
                    lbne      PEXPRN         Process variable reference
                    leay      1,y           Skip token
                    lbsr      PEXPRN         Process variable reference
CheckSimpleSym               lda       -3,y
                    cmpa      #$85          simple?
                    bhs       PASGV1
                    ldd       <SymbolPtr
                    subd      <ModSymTbl
                    std       -2,y          put in I-Code
                    lda       #$85
PASGV1               adda      #$6D
                    sta       -3,y          put in I-Code
                    rts

PPOKE               bsr       PPOK30
PPOK30               bsr       CompileNumExpr
                    leay      1,y           Move past next token
                    rts

PON               ldb       ,y+
                    cmpb      #$1E          is this ON ERROR?
                    beq       PON20
                    leay      -1,y          Back up to expression
                    bsr       PPOK30         (piexpr ,y+) call integer expression processor
                    ldd       ,y++          get element count
PON10               pshs      d
                    leay      1,y           Move I-Code ptr to jump position
                    bsr       PGOTO         Call goto processor
                    puls      d             Retrieve element count
                    subd      #$0001        Count down
                    bne       PON10         bra if more
                    rts

PON20               ldb       ,y+
                    lbsr      EOLTST         End of line?
                    beq       PGOTXX
PGOTO               ldd       ,y
                    bsr       SRHLIN         Find/insert line number
                    ldd       2,x           get link/location
                    bcc       PGOT10         bra if defined
                    sty       2,x           set new header
PGOT10               std       ,y
                    inc       -1,y          Bind token
                    leay      3,y           Move past goto & terminator
PGOTXX               rts

SRHLIN               ldx       <SymTblSize
                    pshs      d             save line number
                    bra       SrhlSearchLoop

SRHL10               ldd       ,x
                    anda      #$7F          Clear sign
                    cmpd      ,s            Line number in question?
                    beq       SRHL30
SrhlSearchLoop               leax      -4,x
                    cmpx      <DescrAreaOff        Out of tbl?
                    bhs       SRHL10
                    ldd       <WorkspaceFree              Get # bytes free in workspace for user
                    subd      #4                  Subtract 4
                    blo       PBEXPR               Not enough mem, exit with Memory full error
                    std       <WorkspaceFree              Save new free space
                    ldd       ,s            get line number
                    ora       #$80          set undefined flag
                    std       ,x            put in tbl
                    clra                    End of list link
                    clrb
                    std       2,x
                    stx       <DescrAreaOff        Increase tbl
SRHL30               lda       ,x
                    rola                    Flag to carry
                    puls      pc,d

PBEXPR               lda       #32                 Memory full error
                    sta       <ErrCode              Save error code
                    lbsr      ERROR         Print error message
                    lbsr      CollapseICode         collapse I-code to reasonable state
                    lbra      Vect1Fn6

CompileNumExpr               lbsr      PEXPRN
                    lbsr      POPOP
                    cmpa      #2                  Real?
                    beq       FixRealForInt               Yes, skip ahead
                    blo       PGOTXX               Byte/Integer, return
ERIET               lda       #$47                Illegal Expression Type error
                    lbra      ERROR

FixRealForInt               lda       #$C8
                    lbra      INSTOK

PIF               lbsr      CompileBoolExpr
                    lda       3,y
                    cmpa      #$3A
                    beq       PIF1
                    lda       #$10          get token
                    lbra      PushCtlStruct

PIF1               pshs      y
                    leay      4,y           Move I-Code ptr
                    bsr       PGOTO         Process transfer
                    tfr       y,d           copy I-Code ptr
                    subd      <ModExecAddr
                    std       [,s++]
                    rts

PELSE               ldd       #$1002
                    lbsr      CONCHK         Call control structure check
                    ldu       1,x           get ptr to IF stmt
                    sty       1,x           Replace top of stack
                    leay      2,y           Move I-Code ptr
                    lbsr      SKPEOL         Skip backslashes & eol
                    tfr       y,d
                    subd      <ModExecAddr
                    std       ,u
* (orig: PCHLXX)
                    rts

PRUN               ldd       #$1001
                    lbsr      CONCHK
                    leay      1,y
PEIF1               tfr       y,d
                    subd      <ModExecAddr
                    std       [<1,x]
                    lbra      POPCN

PFOR               lbsr      GETTYP
                    lbsr      CheckOrDefVar         Check if defined, define if not
                    cmpa      #$60          Check if variable
                    bne       PFOR1         Not variable; abort
                    lda       <VarTypeCode              Get var type
                    cmpa      #1                  Integer?
                    beq       PFOR2               Yes, skip ahead
                    cmpa      #2                  Real?
                    beq       PFOR2               Yes, skip ahead
PFOR1               lda       #$46                Illegal FOR variable
                    lbsr      ERROR
                    ldd       #$FFFF        Make SYMPTR illegal
                    std       <SymbolPtr
                    bra       PFOR3

* FOR variable is numeric but NOT byte, continue
PFOR2               ldb       <VarTypeHi
                    bne       PFOR1         No; abort
                    adda      #$80                Set hi bit on var type
                    sta       ,y                  Save it
                    ldd       1,x           get runtime storage offset
                    std       1,y           put in I-Code
PFOR3               ldx       <StrSpaceTop              Get some sort of var ptr
                    leax      -7,x                Make room for 7 more bytes
                    stx       <StrSpaceTop              Save new ptr
                    lda       <VarTypeCode              Get var type
                    sta       ,x                  Save it
                    ldd       <SymbolPtr        get symbol tbl ptr
                    subd      <ModSymTbl        Make ptr into offset
                    std       1,x
                    clra                    D
                    clrb
                    std       5,x           Push it
* (orig: POPE10)
                    leay      4,y           Move I-Code ptr to expression
                    bsr       PIEXPR         Check expression type
                    bsr       FORSUB         Allocate terminal, process expression
                    std       3,x           Clear next procedure offset
                    lda       ,y            get next token
                    cmpa      #$47          is there an increment?
                    bne       PFOR4         No; almost done
                    bsr       FORSUB         Allocate increment, process expression
                    std       5,x           Push increment offset
PFOR4               leay      1,y
                    sty       ,--x          Push I-Code ptr
                    lda       #$13          get structure token
                    sta       ,-x           Push it
                    stx       <StrSpaceTop        save control stack ptr
                    leay      3,y           Move to next stmt
PFOR9               rts

FORSUB               ldd       <CurVarSz
                    pshs      d             save it for return
                    std       1,y           put in I-Code
                    ldx       <StrSpaceTop        get control stack ptr
                    lda       ,x            get type
                    leax      >BytesPerTypeTbl,pc           Point to 5 single bytes table
                    ldb       a,x                 Get value
                    clra                          D=value  Msb
                    addd      <CurVarSz              Add to value & save result
                    std       <CurVarSz        save it
                    leay      3,y           Move to expression
                    bsr       PIEXPR         Process it
                    ldx       <StrSpaceTop        get control stack ptr
                    puls      pc,d          get offset & return

PIEXPR               lbsr      PEXPRN
                    lbsr      POPOP
                    cmpa      ,u
                    beq       PFOR9
                    cmpa      #$02          numeric?
                    bcs       FixIntForFloat         Yes; good (rts)
                    lbne      ERIET         Err - illegal expression type
* (orig: FORTY1)
                    lda       #$C8          Err - illegal expression type
                    bra       FORTY3

FixIntForFloat               lda       #$CB                ??? Illegal mode error?
FORTY3               lbra      INSTOK

PNEXT               leay      -1,y
                    ldd       #$130B
                    lbsr      CONCHK         Call control structure test
                    ldd       2,y           get symbol tbl offset
                    cmpd      4,x           same as for's offset?
                    beq       PNEXT4         Yes; good
                    lda       #$46                Illegal FOR variable error
                    lbsr      ERROR
                    bra       PNEXT6

PNEXT4               addd      <ModSymTbl
                    exg       d,x           Move symbol ptr to ptr register
                    ldx       1,x           get runtime storage offset
                    exg       d,x           Switch back
                    std       2,y           put in I-Code
                    lda       3,x           get type
                    anda      #$02          set code 0=int step 1, 2=real step 1
                    sta       1,y           put in I-Code
                    ldd       6,x           get terminal offset
                    std       4,y           put in I-Code
                    ldd       8,x
                    std       6,y
                    beq       PNEXT5         bra if no increment
                    inc       1,y           set code for step n
PNEXT5               ldu       1,x
                    tfr       y,d           copy I-Code ptr
                    subd      <ModExecAddr        Make ptr into offset
                    addd      #$0001        Make offset of next type byte
                    std       ,u            put in FOR stmt
                    leau      3,u           Move ptr to stmt following FOR
                    tfr       u,d
                    subd      <ModExecAddr        Make it offset
                    std       8,y
PNEXT6               leay      $B,y
                    lbsr      POPCN         Pop endexits and this control structure
                    leax      7,x           Pop extra room for used
                    stx       <StrSpaceTop        get control stack ptr
                    rts

PWHILE               leau      -1,y
                    pshs      u             save it
                    bsr       CompileBoolExpr         get boolean expression
                    puls      d             get ptr to stmt beginning
                    std       ,y
                    lda       #$15
                    bra       PushCtlStruct         Push on ctl stack, skip 'do' token

PEWHL               ldd       #$1503
                    bsr       CONCHK         Call control structure check
                    ldx       1,x           get ptr to while jump ptr
                    ldd       ,x            get ptr to stmt beginning
                    subd      <ModExecAddr        get I-Code offset
                    std       ,y            put in endwhile jump ptr
                    leay      3,y
                    tfr       y,d
                    subd      <ModExecAddr
                    std       ,x            put in while jump ptr
                    lbra      POPCN

PREPT               lda       #$17
PREP10               lbsr      SKPONE
                    bra       PUSHCN

PUNTIL               bsr       CompileBoolExpr
                    lda       #$17          set structure type
PUNT10               leay      -1,y
                    ldb       #$03          Number of bytes to skip if error
                    bsr       CONCHK         Call control structure check
                    ldd       1,x           get ptr to after REPEAT
                    subd      <ModExecAddr
                    std       $01,y         put in I-Code
                    leay      $04,y         Move I-Code ptr to next stmt
                    bra       POPCN

PLOOP               lda       #$19
                    bra       PREP10

PEndloop               lda       #$19
                    bra       PUNT10         Push on operand stack

PEXIF1               bsr       CompileBoolExpr
                    lda       #$1B          get structure token
PushCtlStruct               bsr       PUSHCN
                    leay      3,y           Move I-Code ptr past THEN
                    lbra      SKPEOL

CompileBoolExpr               lbsr      PEXPRN
                    lbsr      POPOP
                    cmpa      #3                  ??? Boolean variable?
                    beq       PBEXP1               Yes, skip ahead
                    lda       #$47                Illegal Expression Type error
                    lbsr      ERROR
PBEXP1               leay      1,y
                    rts

PEEXT               ldd       #$1B03
                    bsr       CONCHK         Call control structure check
                    leau      ,y            get ptr to jump offset
                    leay      3,y           Move I-Code ptr to next stmt
                    lbsr      PEIF1         put in jump offset
                    stu       ,--x          put in control stack
                    lda       #$1C          get structure token
                    bra       PUSHC1

PUSHCN               ldx       <StrSpaceTop
                    sty       ,--x          Push I-Code ptr
PUSHC1               sta       ,-x
                    stx       <StrSpaceTop
                    rts

CONCHK               pshs      a
                    ldx       <StrSpaceTop        get control stack ptr
                    bra       ConchkBoundsCk

ConchkNextEntry               leax      3,x
ConchkBoundsCk               cmpx      <SubrStkPtr
                    bhs       CONCH3
                    lda       ,x            get token
                    cmpa      #$1C
                    beq       ConchkNextEntry
                    cmpa      ,s            correct type?
                    beq       CONCH4
CONCH3               leas      3,s
                    lda       #$45                Unmatched Control Structure error
                    lbsr      ERROR
                    leay      b,y           Skip I-Code
                    lbra      SKPEOL         Push on operand stack

CONCH4               puls      pc,a

POPCN               ldx       <StrSpaceTop
                    bra       PopcnBoundsCk

POPCN1               lda       ,x
                    cmpa      #$1C          endexit?
                    bne       DONE25         No; go pop it
                    tfr       y,d           copy I-Code ptr
                    subd      <ModExecAddr        get I-Code offset
                    std       [<1,x]        put in I-Code
* (orig: POPCN3)
                    leax      3,x           Pop endexit
PopcnBoundsCk               cmpx      <SubrStkPtr
                    blo       POPCN1
                    bra       POPCN9         Return

DONE25               leax      3,x
POPCN9               stx       <StrSpaceTop
                    rts

CompileRunStmt               leay      -1,y
                    lbsr      GETTYP         get & decode type byte
                    lda       <VarDefByte        get definition
                    beq       RunNewProc
                    cmpa      #$A0
                    beq       PRUN20         ..Yes
                    cmpa      #$60
                    bcs       PRUN10         is simple
                    lda       <VarTypeHi        simple?
                    bne       PRUN10         ..No
* (orig: PRUNER)
                    lda       <VarTypeCode        get type
                    cmpa      #$04
                    beq       PRUN20
PRUN10               lda       #$4C                Multiply-defined Variable error
                    lbsr      ERROR
                    bra       PRUN20

RunNewProc               lda       #$A0
                    sta       ,x
                    ldd       <ProcLinkAcc        get next procedure link addr
                    std       1,x           put in symbol tbl
                    addd      #$0002        get next procedure link
                    std       <ProcLinkAcc        save total size
PRUN20               leay      3,y
PrunStmtBody               ldb       ,y+
                    cmpb      #$4D          are there parameters?
                    bne       PRUN40         ..No
PrunParamLoop               lbsr      PASGVR
                    lbsr      POPOP         Keep opstack clean
                    ldb       ,y+
                    cmpb      #$4B
                    beq       PrunParamLoop
                    leay      1,y           Skip stmt terminator
PRUN40               rts

CompileIOStmt               bsr       GetChanRef
                    leay      -1,y          Backup to exprsn
                    cmpb      #$90          prompt string?
                    bne       IOVarLoop         No; go do variable reference
* (orig: PINPU1)
                    lbsr      CompileStrExprB         Process it
                    leay      1,y           Skip comma
IOVarLoop               lbsr      PASGVR
                    lbsr      POPOP
                    cmpa      #$05
                    bcs       IOCheckComma         No; good
* (orig: PINPU2)
                    lda       #$4D                Illegal Input Variable error
                    lbsr      ERROR
IOCheckComma               lda       ,y+
                    cmpa      #$4B          a comma?
                    beq       IOVarLoop
                    rts

PPRINT               bsr       GetChanRef
                    cmpb      #$49          USING?
                    bne       PprintLoop         No; go look for expression
                    bsr       CompileStrExprB
PprintCheckMore               ldb       ,y+
PprintLoop               cmpb      #$4B
                    beq       PprintCheckMore
                    cmpb      #$51
                    beq       PprintCheckMore         ..Yes
                    lbsr      EOLTST
                    beq       PrintSetupDone
* (orig: PRLIT)
                    leay      -1,y          Back up to expression
                    lbsr      PEXPRN
                    lbsr      POPOP
                    cmpa      #$05
                    blo       PprintCheckMore
                    lda       #$47                Illegal Expression Type error
                    lbsr      ERROR
                    bra       PprintCheckMore

GetChanRef               ldb       ,y+
                    cmpb      #$54          is there channel number?
                    bne       PrintSetupDone
                    lbsr      CompileNumExpr         Check variable type & subscripts
SkipPrintSeps               ldb       ,y+
                    cmpb      #$4B          comma?
                    beq       SkipPrintSeps
                    cmpb      #$51          semi-colon?
                    beq       SkipPrintSeps         ..No
PrintSetupDone               rts

CompileSeekVar               leay      1,y
                    lbsr      PASGVR
                    lbsr      POPOP
                    cmpa      #$01
                    beq       POPE20
                    lbsr      ERIET
POPE20               leay      1,y
                    bsr       CompileStrExprB         Process name expression
                    lda       ,y+
                    cmpa      #$4A
                    bne       POPE30         ..No
                    leay      2,y
POPE30               rts

PSEEK               bsr       PIOBGN
                    bsr       PEXPRN
                    lbsr      POPOP
                    cmpa      #$42
                    bls       JmpSkpeol
                    lbra      ERIET         Err - illegal expression type

PCLOSE               bsr       PIOBGN
                    lbsr      PASGVR         Process variable/expression
                    lbsr      POPOP
PcloseSkipEol               bra       JmpSkpeol

CompileRestore               bsr       PIOBGN
                    cmpb      #$4B          Another path?
                    beq       CompileRestore         ..Yes
                    bra       JmpSkpeol

PIOBGN               leay      1,y
                    lbra      PPOK30

CompileStrExpr               bsr       CompileStrExprB
                    bra       JmpSkpeol

CompileStrExprB               bsr       PEXPRN
                    lbsr      POPOP
                    cmpa      #4
                    beq       POPE30               Return
                    lbra      ERIET               Return from there

PREST               ldb       ,y+
                    cmpb      #$3A          line reference?
                    lbeq      PGOTO
JmpSkpeol               lbra      SKPEOL

ExprHighToken               cmpb      #$96
                    bhs       ExprSpecialTok
                    lbsr      ExprSpecialVar         Call specials processor
                    bra       PEXPRN

* B>=$96 goes here
ExprSpecialTok               cmpb      #$F2                If >=$F2, skip ahead
                    lbhs      UnimplRtnErr
                    subb      #$96                Drop B to $00 - $5B
                    leax      >BindOpCodeTbl,pc           Point to data table
                    abx                           Point to entry we want
                    ldb       ,x                  Get it
                    lbeq      UnimplRtnErr               If nothing, skip ahead
                    andb      #$1F          get argument processor code
                    beq       PEXP30         bra if no arguments/operands
                    leau      <ExprArgJmpTbl,pc           point to routine
                    lslb
                    jsr       b,u           Process arguments/operands
PEXP30               ldb       ,x                  Get byte
                    andb      #$E0                Mask out all but hi 3 bits
                    beq       ExprDoToken               If hi 3 bits all 0's, skip ahead
                    clra                          Move hi 3 bits to lo 3 bits in A
                    rolb                          ROLD
                    rola
                    rolb                          ROLD
                    rola
                    rolb                          ROLD
                    rola
                    cmpa      #$07                All 3 bits set?
                    bne       ExprDoToken               No, skip ahead
* (orig: PEXP40)
                    lbsr      SetICodeLineEnd         Delete token
                    bra       PEXPRN

ExprDoToken               lbsr      PushTypeOnStack
                    leay      1,y           Move I-Code ptr
PEXPRN               ldb       ,y
                    bmi       ExprHighToken
                    rts

P2INT               bsr       P1REAL
                    incb
                    bra       CheckExprType

P1REAL               ldb       #$C8                (200)
CheckExprType               lbsr      POPOP
                    cmpa      #$02          numeric?
                    blo       ExprTypeRts
                    beq       PINT10         bra if real
                    bsr       ERRIAR
                    bra       PINT20

PINT10               tfr       b,a
                    lbsr      INSTOK
PINT20               lda       #$01
ExprTypeRts               rts

P2RealAlt               bsr       P1RealAlt
                    incb
                    bra       CheckRealExpr

P1RealAlt               ldb       #$CB
CheckRealExpr               lbsr      POPOP
                    cmpa      #$02
                    beq       PREAXX
                    blo       PREA10
                    bsr       ERRIAR         Report error
* (orig: EXPBRA)
                    bra       PREA20

PREA10               tfr       b,a
                    lbsr      INSTOK
PREA20               lda       #$02
PREAXX               rts

ExprArgJmpTbl               bra       ExprArgUnimpl               (offset 0)
ExprArg1Real               bra       P1REAL               (2)
ExprArg2Int               bra       P2INT               (4)
ExprArg1RealB               bra       P1RealAlt               (6)
ExprArg2RealB               bra       P2RealAlt               (8)
ExprArg1Num               bra       P1NUM               ($a)
ExprArg2Num               bra       P2NUM               ($c)
ExprArg2Str               bra       P1Str               ($e)
ExprArg1Str               bra       P2StrXX               ($10)
ExprArg1R1I               bra       P1S1I               ($12)
ExprArg2I1S               bra       P2Int1Str               ($14)
ExprArg2Bool               bra       P1Bool               ($16)
ExprArg1Bool               bra       P2BoolAlt               ($18)
ExprArg2StrNum               bra       P2SN               ($1A)
ExprArg2BoolStrNum               bra       P2BSN               ($1C)
ExprArgUnimpl               lbra      UnimplRtnErr               ($1F)

ERRIAR               lda       #$43                Illegal Argument error
                    lbra      ERROR

P2NUM               bsr       PNUM
                    pshs      a             save type
                    bsr       PNUM         Process second
                    cmpa      ,s+           Compare results
                    beq       P1NU10         bra if equal
                    lda       #$CB          get conversion token
                    bcc       P2NU10         ..No
                    inca                    token
P2NU10               lbsr      INSTOK
                    lda       #$02          Return type
                    bra       P1NU20

P1NUM               bsr       PNUM
P1NU10               cmpa      #$02
                    bne       P1NUXX         ..No
P1NU20               inc       ,y
P1NUXX               rts

PNUM               bsr       POPOP
                    cmpa      #$02
                    bls       PnumRts         ..Yes
                    bsr       ERRIAR         Report error
                    lda       #$02          Return real
PnumRts               rts

P2StrXX               bsr       P1Str
P1Str               bsr       POPOP
                    cmpa      #4
                    beq       P1STXX
                    bsr       ERRIAR
                    lda       #4
P1STXX               rts

P1S1I               lbsr      P1REAL
                    bra       P1Str         Process string

P2Int1Str               lbsr      P2INT
                    bra       P1Str         Process string

P2BSN               lda       #3
                    bsr       P2ARG         Throw away variable type
                    bne       P2SN         bra if not successful
                    ldb       #3            set increment
                    bra       P2SN10

P2SN               lda       #4
                    bsr       P2ARG
                    bne       P2NUM         bra if not successful
                    ldb       #2            set increment
P2SN10               addb      ,y
                    stb       ,y
                    rts

P2ARG               ldu       <StrSpaceTop
                    cmpa      ,u+           is first correct type?
                    bne       P2ArgRts         ..No
                    cmpa      ,u+           is second correct?
                    bne       P2ArgRts         ..No
                    stu       <StrSpaceTop        Pop arguments/operands
                    clrb                    Z bit
P2ArgRts               rts

P2BoolAlt               bsr       P1Bool
P1Bool               bsr       POPOP
                    cmpa      #3
                    beq       P1BOXX
                    bsr       ERRIAR
                    lda       #3
P1BOXX               rts

* Modified since all routines coming here freshly LDA
PushTypeOnStack               tsta                          A=0?
SetMinType               bne       PushType               No, skip ahead
                    inca                          A=1
PushType               ldu       <StrSpaceTop
                    cmpa      #5            rcd type?
                    bne       PUSHO2         No; do simple
                    ldd       <RealTmpWord        get descr ptr
                    std       ,--u
                    lda       #5
PUSHO2               sta       ,-u
                    stu       <StrSpaceTop        save stack ptr
                    rts

POPOP               ldu       <StrSpaceTop
                    lda       ,u+           get type
                    cmpa      #5            record?
                    bne       POPOP1         ..No
                    leau      2,u           Return descr space
POPOP1               stu       <StrSpaceTop
                    rts

ExprSpecialVar               cmpb      #$85
                    lblo      UnimplRtnErr
                    cmpb      #$89
                    blo       PVREF
                    subb      #$8D          field reference?
                    lblo      PFREF               $8a to $8c go here
                    leau      <ExprSpecialJmp,pc           Point to list of branches
                    lslb                          2 bytes/per branch
                    jmp       b,u                 Call branch

ExprSpecialJmp               bra       PBLIT
ExprSpecInt3               bra       PushIntLit
ExprSpecInt6               bra       PushRealLit
ExprSpecStr               bra       PSLIT
ExprSpecInt3b               bra       PushIntLit
ExprSpecAddr1               bra       PADDR1
ExprSpecAddr2               bra       PADDR2
ExprSpecAddr3               bra       PADDR1
ExprSpecAddr4               bra       PADDR2

PBLIT               leay      -1,y
PushIntLit               leay      3,y
                    lda       #1
                    bra       PushType

PushRealLit               leay      6,y
                    lda       #2
                    bra       PushType

PSLIT               ldb       ,y+
                    cmpb      #$FF
                    bne       PSLIT
                    lda       #4
                    bra       PushType

PADDR1               lbsr      CheckSimpleSym
                    bsr       POPOP
                    lda       #1
                    bsr       PushType
PADDR2               leay      1,y
                    rts

PVREF               lbsr      GETTYP
                    bsr       CheckOrDefVar
                    cmpa      #$60
                    beq       VrefSimpleOrObj         bra if so
                    cmpa      #$80          Object procedure?
                    beq       VrefSimpleOrObj         Real; check for integer result
                    lda       #$12                Illegal Operand error
                    lbsr      ERROR
                    bra       VrefSkipToken

VrefSimpleOrObj               ldb       #$85
                    lbsr      CheckVarSubs         Print line
                    ldb       ,y
                    cmpb      #$85
                    bne       VrefSkipToken
                    ldb       <VarDefByte
                    cmpb      #$60
                    bne       VrefSkipToken
                    cmpa      #5
                    bhs       VrefSkipToken
                    adda      #$80
                    sta       ,y
                    ldd       1,x
                    std       1,y
VrefSkipToken               leay      3,y
                    lda       <VarTypeCode
                    lbra      SetMinType

CheckOrDefVar               lda       <VarDefByte
                    bne       CHKD20
                    ldb       #$60
                    sta       <VarTypeHi
                    stb       <VarDefByte
* (orig: CHKDEF)
                    lda       #$60                Take out, and change following to B's ?
                    ora       <VarTypeCode        set high order bit
                    sta       ,x
                    anda      #$07
                    cmpa      #4
                    bne       CheckNonString         No; error
                    ldd       #$0020
                    std       1,x
CheckNonString               lbsr      ALCSTO
                    lda       <VarDefByte
CHKD20               rts

PFREF               bsr       GETTYP
                    ldb       #$89
                    bsr       CheckVarSubs         End of statement?
                    lbsr      POPOP
                    cmpa      #5
                    beq       GetUserTypePtr
* (orig: PFREF1)
                    ldu       #$FFFF
                    bra       PFREF2

GetUserTypePtr               ldu       -2,u
PFREF2               pshs      u
                    bsr       VrefSkipToken
                    puls      u
                    cmpu      #$FFFF
                    beq       ErrNonRecord
                    ldb       2,u
                    stb       <VarByteSize
                    ldd       <SymbolPtr
                    subd      <ModSymTbl
                    leau      3,u
PFREF3               cmpd      ,u++
                    beq       GETTY9
                    dec       <VarByteSize
                    bne       PFREF3
* (orig: PFREF5)
                    lda       #$14
                    bra       PFREF9

ErrNonRecord               lda       #$42                Non-Record Type Operand error
PFREF9               lbra      ERROR

GETTYP               ldd       1,y
                    addd      <ModSymTbl
                    std       <SymbolPtr
                    ldx       <SymbolPtr
GETTY1               lda       ,x
                    anda      #$E0
                    sta       <VarDefByte
                    lda       ,x
                    anda      #$18
                    sta       <VarTypeHi
                    lda       ,x
                    anda      #$07
                    sta       <VarTypeCode
GETTY9               rts

CheckVarSubs               pshs      b
                    ldb       ,y            Get array base lsb
                    subb      ,s+
                    bne       CalcSubsShift
                    lda       <VarTypeHi
                    beq       CHKV60
                    ldd       #$FFFF
                    std       <RealTmpWord
                    lda       #5
                    sta       <VarTypeCode
                    rts

CalcSubsShift               lslb                          B=B*8
                    lslb
                    lslb
                    cmpb      <VarTypeHi
                    beq       InitSubsCheck
* (orig: CHKV20)
                    lda       #$41                Wrong Number of Subscripts error
* (orig: CHKV30)
                    lbsr      ERROR         Turn on trace
InitSubsCheck               lda       #$C8
                    sta       <UnusedByte_D8
ChkSubsTypeLoop               lbsr      POPOP
                    cmpa      #2                  Byte or Integer?
                    blo       CHKV50               Yes, skip ahead
                    beq       FixRealSubs               If real, skip ahead
* (orig: CHKV40)
                    lda       #$47                Illegal Expression Type error
                    lbsr      ERROR         Get variable address
                    bra       CHKV50

* Real comes here
FixRealSubs               lda       <UnusedByte_D8
                    bsr       INSTOK         Evaluate data value
* Byte/Integer come here
CHKV50               inc       <UnusedByte_D8
                    subb      #$08
                    bne       ChkSubsTypeLoop         bra if not byte
CHKV60               lda       <VarTypeCode
                    cmpa      #$05
                    bne       CHKV99
                    ldd       1,x
                    addd      <SymTblSize
                    tfr       d,u
                    ldb       <VarTypeHi
                    beq       GetSimpleDescr
                    lsrb                          Divide by 4
                    lsrb
                    addb      #4
* (orig: CHKV70)
                    ldd       b,u
                    bra       CHKV80

GetSimpleDescr               ldd       2,u
CHKV80               addd      <SymTblSize
CHKV90               std       <RealTmpWord
                    lda       <VarTypeCode
CHKV99               rts

INSTOK               pshs      x,b
                    ldx       <WorkspaceFree        Get procedure ptr
                    cmpx      #$0010
                    lbls      PBEXPR
                    ldx       <ModFOff
                    sta       ,x+
                    stx       <ICodeLineEnd
                    clrb
                    bsr       SetLineEndB
                    puls      pc,x,b

SetICodeLineEnd               ldd       <ModFOff
                    std       <ICodeLineEnd
                    ldb       #$01
SetLineEndB               clra
Vect1Fn14               jsr       <JmpVect1
                    fcb       $14

* Jump tables (NOTE:SINCE ALL ARE <$80, USE 8 BIT INSTEAD OF 16 BIT OFFSET)
AlcStorJmpTbl1               fdb       ALCSMV-AlcStorJmpTbl1         $0049
                    fdb       ALCSTV-AlcStorJmpTbl1         $005c
                    fdb       ALCARV-AlcStorJmpTbl1         $0060
                    fdb       AlcArrayRv-AlcStorJmpTbl1         $006a

AlcStorJmpTbl2               fdb       AlcParamEntry-AlcStorJmpTbl2         $0066
                    fdb       ALCARP-AlcStorJmpTbl2         $0072
                    fdb       ALCARP-AlcStorJmpTbl2         $0072
                    fdb       AlcParamArr-AlcStorJmpTbl2         $0076

ALCSTO               pshs      u,y,x
                    leay      <AlcStorJmpTbl1,pc           Point to 1st jump table
                    ldb       ,x
                    andb      #$E0                Get rid of lowest 5 bits (b1-b5)
                    cmpb      #%01100000          bits 6 & 7 set?
                    beq       ALCST1               Yes, skip ahead
                    cmpb      #%01000000          Just bit 7 set?
                    beq       ALCST1               Yes, skip ahead
                    cmpb      #%10000000          Just bit 8 set?
                    bne       ALCST6               No, skip way ahead
* NOTE: IF TABLE CHANGED TO 8 BIT OFFSET, CHANGE THIS TO LEAY 4,Y
                    leay      8,y                 If just bit 8 set, use 2nd jump table
ALCST1               ldb       ,x                  Reload the value
                    andb      #%00011000          Just keep bits 4-5
                    beq       AlcSimpleVar               Neither set, skip ahead
                    ldd       6,y                 If either set, use 4th entry
                    bra       ALCST5               Go to subroutine

AlcSimpleVar               ldb       ,x                  Reload the value
                    andb      #%00000111          Just keep bits 1-3
ALCST3               cmpb      #%00000100          Just bits 1-2?
                    blo       AlcUse1stEntry               Yes, skip ahead
                    bhi       AlcUse3rdEntry               Bit 3 + at least 1 more bit, skip ahead
                    ldd       2,y                 If just bit 3, use 2nd entry
                    bra       ALCST5               Go to subroutine

AlcUse3rdEntry               ldd       4,y                 Bit 3 + (1 or 2), use 3rd entry
                    bra       ALCST5               Go to subroutine

AlcUse1stEntry               ldd       ,y                  Use 1st entry
ALCST5               jsr       d,y                 Call subroutine
ALCST6               puls      pc,u,y,x            Restore regs & return

ALCSMV               lda       ,x
                    anda      #$07
                    leay      1,x
                    bsr       GETVSZ
ALCSV1               pshs      d                   USE W
                    ldd       <CurVarSz
                    std       ,y
                    addd      ,s++
                    std       <CurVarSz
                    rts

ALCSTV               bsr       AlcDescr4Bytes
                    bra       ALCSV1

ALCARV               bsr       AlcDescr4Bytes
                    addd      <SymTblSize
                    tfr       d,x
                    ldd       ,x
                    bra       ALCSV1

AlcArrayRv               bsr       ALCARR
                    bra       ALCSV1

AlcParamEntry               leay      1,x
ProcLinkAccum               ldd       <ProcSzAcc
                    std       ,y
                    addd      #$0004
                    std       <ProcSzAcc
                    rts

ALCARP               bsr       AlcDescr4Bytes
                    bra       ProcLinkAccum

AlcParamArr               bsr       ALCARR
                    bra       ProcLinkAccum

ALCARR               ldd       1,x
                    addd      <SymTblSize
                    tfr       d,y
                    ldd       2,y
                    rts

AlcDescr4Bytes               ldd       #$0004              Requesting 4 bytes of memory from workspace
                    bsr       Vect2Fn8               Go see if we can get it & allocate it
                    ldx       4,s           Restore I-Code ptr
                    ldd       1,x           Reset free space
                    std       2,y
                    tfr       y,d
                    subd      <SymTblSize        Get string length
                    std       1,x
                    ldd       2,y
                    rts

Vect2Fn8               jsr       <JmpVect2
                    fcb       $08

* Table of # bytes/var type
BytesPerTypeTbl               fcb       1                   1 byte =Byte
                    fcb       2                   2 bytes=Integer
                    fcb       5                   5 bytes=Real
                    fcb       1                   1 byte =Boolean
                    fcb       $20                 ??? Flag String value? (or default size=32 bytes)

* Entry: A=Variable type (0-4)
* Exit : B=# bytes to represent variable
GETVSZ               pshs      x                   Preserve X
                    leax      <BytesPerTypeTbl,pc           Point to 5 1-byte entry table
                    ldb       a,x                 D=#
                    clra                    Msb
                    puls      pc,x

* Single byte entry table
SpecTermTbl               fcb       $01,$02,$03,$07,$08,$09,$37,$38,$3e,$3f,$ff

BIND               ldd       #$0016
                    std       <CurVarSz
                    clrb
                    std       <ProcSzAcc
                    std       <ProcLinkAcc        Save for future use
                    sta       <CmdExecFlag
                    std       <DataStmtBase
                    std       <DataStmtCur
                    ldx       <CurModPtr              Get ptr to current module
                    sta       <$17,x              Set flags to unpacked, no errors
                    std       <$15,x
BindCmdLoop               ldy       <ModExecAddr
                    bra       DONE

BindNextStmt               pshs      y
                    lbsr      PSTMT         Go input
                    puls      x
                    ldb       <BinderMode
                    bne       DONE
                    lda       ,x
                    leau      <SpecTermTbl,pc           Point to 11 entry 1 byte table
STAR10               cmpa      ,u+                 Hunt through for range our byte is in
                    blo       DONE               If lower then table entry, skip ahead
                    bne       STAR10               If not equal, keep looking
                    pshs      x                   Equal, preserve X
                    tfr       y,d                 Move ??? to d
                    subd      ,s++
                    leay      ,x            Get name ptr
                    ldu       <ICodeEndPtr              Get ptr to next free byte in I-code workspace
                    stu       <ICodeLineEnd              Save as ptr to current line I-code end
                    lbsr      Vect1Fn14
DONE               ldx       <ModFOff
                    clr       ,x
                    cmpy      <ModFOff
                    blo       BindNextStmt
CollapseICode               ldx       <SymTblSize
                    bra       DONE50

DONE05               lda       ,x
                    bpl       DONE50
                    anda      #$7F
                    sta       ,x
                    ldy       2,x
DONE03               ldu       ,y
                    ldd       ,x
                    std       ,y
                    dec       -1,y          More parameters?
                    lda       #$4A                Undefined Line Number error
                    lbsr      ERROR
                    leay      ,u
                    bne       DONE03
DONE50               leax      -4,x
                    cmpx      <DescrAreaOff
                    bhs       DONE05
                    ldd       <SymTblSize
                    subd      <DescrAreaOff
                    addd      <WorkspaceFree              Add to bytes free to user
                    std       <WorkspaceFree              Save as new # bytes free to user
                    ldx       <StrSpaceTop
                    bra       DONE20

Vect2Fn6b               jsr       <JmpVect2
                    fcb       $06

DONE10               ldy       1,x
                    lda       #$45                Unmatched Control Structure error
                    lbsr      ERROR
                    lda       ,x
                    cmpa      #$13
                    bne       DoneForSkip
* (orig: DONE15)
                    leax      7,x
DoneForSkip               leax      3,x
                    stx       <StrSpaceTop        Save I-Code ptr
DONE20               cmpx      <SubrStkPtr
                    blo       DONE10
                    ldu       <SymTblSize
                    ldy       <ModFOff
                    ldd       <ModSzData
                    addd      <StorageOff
                    bsr       Vect2Fn6b
                    ldx       <CurModPtr              Get current module ptr
                    ldd       <DataStmtBase
                    std       <$13,x
                    ldd       <CurVarSz
                    std       <$11,x
                    addd      <ProcLinkAcc
                    std       <ProcLinkAcc
                    std       $0B,x               Save in data area size require in module header
                    ldb       <$18,x              Get size of module name
                    clra
                    addd      #$0019              Add 25 to it (size of BASIC09 header?)
                    std       M$Exec,x            Save as execution address
                    addd      <ModFOff
                    subd      <ModExecAddr
                    std       $0F,x
                    addd      <StorageOff
                    addd      #$0003
                    std       $0D,x
                    subd      #$0003
                    addd      <ModSzData
                    std       M$Size,x            Save as new module size
                    addd      <CurModPtr              Add to current module ptr
                    std       <ICodeEndPtr
                    subd      <ICodeBase
                    std       <ICodeUsed
                    ldd       <CurModPtr              Get current module ptr
                    addd      $D,x
                    std       <ModSymTbl        Save it
                    ldd       <CurModPtr              Get current module ptr
                    addd      $0F,x
                    std       <SymTblSize        Save procedure ptr
                    ldu       <ModSymTbl        Get opstack beginning
                    bra       BindSymDone

BindSymLoop               leax      ,u
                    lbsr      GETTY1
                    lda       <VarDefByte
                    cmpa      #$60
                    bcs       BindChkRecord         bra if not found
                    cmpa      #$A0
                    bne       DONE30
                    ldd       1,x
                    addd      <CurVarSz
                    std       1,x
                    bra       DONE70

DONE30               cmpa      #$80
                    bne       BindChkRecord
                    ldb       <VarTypeHi
                    bne       DONE45
* (orig: PASG00)
                    lda       <VarTypeCode
                    cmpa      #$04
                    bcc       DONE45
                    leax      1,u
                    bra       BindGetPtr

DONE45               ldd       1,u
                    addd      <SymTblSize
                    tfr       d,x
BindGetPtr               ldd       ,x
                    addd      <ProcLinkAcc
                    std       ,x
BindChkRecord               lda       <VarTypeCode
                    cmpa      #$05
                    bne       DONE70
                    ldb       <VarTypeHi
                    beq       DONE60               If 0, force to 2
                    lsrb                          Divide by by 4
                    lsrb
                    addb      #4
                    bra       DONE65

DONE60               ldb       #$02
DONE65               clra
                    addd      1,u
                    ldx       <SymTblSize
                    leay      d,x
                    ldd       ,y
                    ldd       d,x
                    std       ,y
DONE70               leau      3,u
DONE75               lda       ,u+
                    bpl       DONE75
BindSymDone               cmpu      <ICodeEndPtr
                    blo       BindSymLoop
                    rts

* Called by <$24 JMP vector
* Entry: X=byte after the last vector installed ($2D)
*        D=Last vector offset from start of BASIC09's module header
* Based on function code following the JMP that came here, this routine
*  modifies the return address to 1 of 7 routines
Vect4Dispatch               pshs      x,d                 Preserve ptr & offset
                    ldb       [<4,s]              Get function code-style byte
                    leax      <Vect4JmpBase,pc           Point to vector table
                    ldd       b,x                 Get vector offset
                    leax      d,x                 Calculate address
                    stx       4,s                 Modify RTS address
                    puls      pc,x,d              Restore X & D and return to new routine

* Vector table for <$24 calls
Vect4JmpBase               fdb       InitJmpTables-Vect4JmpBase         Function 0 call
                    fdb       EXECUT-Vect4JmpBase         Function 1 call
                    fdb       RPARAM-Vect4JmpBase         Function 2 call
                    fdb       EXCERR-Vect4JmpBase         Function 3 call  (error message)
                    fdb       DispatchStmt-Vect4JmpBase         Function 4 call
                    fdb       TONSTM-Vect4JmpBase         Function 5 call
                    fdb       TOFSTM-Vect4JmpBase         Function 6 call

* Jump table (from StmtJmpBase+offset)
StmtJmpBase               fdb       TraceListLine-StmtJmpBase
                    fdb       TraceListLine-StmtJmpBase
                    fdb       TraceListLine-StmtJmpBase
                    fdb       TraceListLine-StmtJmpBase
                    fdb       TraceListLine-StmtJmpBase
                    fdb       STPSTM-StmtJmpBase
                    fdb       Vect1FnC-StmtJmpBase         Go direct to JSR <1B / fcb $C
                    fdb       TONSTM-StmtJmpBase
                    fdb       TOFSTM-StmtJmpBase
                    fdb       PrintThenFn18-StmtJmpBase
                    fdb       DEGSTM-StmtJmpBase
                    fdb       RADSTM-StmtJmpBase
                    fdb       RETSTM-StmtJmpBase
                    fdb       DispatchStmt-StmtJmpBase
                    fdb       LetStmt-StmtJmpBase
                    fdb       PokeStmt-StmtJmpBase
                    fdb       IFSTM-StmtJmpBase
                    fdb       GTOSTM-StmtJmpBase
                    fdb       SkipOneByte-StmtJmpBase
                    fdb       FORS20-StmtJmpBase
                    fdb       NextDispatch-StmtJmpBase         NEXT routine
                    fdb       WHLSTM-StmtJmpBase
                    fdb       GTOSTM-StmtJmpBase
                    fdb       DispatchStmt-StmtJmpBase
                    fdb       WHLSTM-StmtJmpBase
                    fdb       DispatchStmt-StmtJmpBase
                    fdb       GTOSTM-StmtJmpBase
                    fdb       WHLSTM-StmtJmpBase
                    fdb       GTOSTM-StmtJmpBase
                    fdb       ONSTM-StmtJmpBase
                    fdb       ERRSTM-StmtJmpBase
                    fdb       ELNSTM-StmtJmpBase
                    fdb       GTOSTM-StmtJmpBase
                    fdb       ELNSTM-StmtJmpBase
                    fdb       GSBSTM-StmtJmpBase
                    fdb       CopyVarEntry-StmtJmpBase
                    fdb       EvalAndFn0A-StmtJmpBase
                    fdb       INPSTM-StmtJmpBase
                    fdb       PRTSTM-StmtJmpBase
                    fdb       CHDSTM-StmtJmpBase
                    fdb       ChxdStmt-StmtJmpBase
                    fdb       CRTSTM-StmtJmpBase
                    fdb       OpenFileStmt-StmtJmpBase
                    fdb       SEKSTM-StmtJmpBase
                    fdb       RDSTM-StmtJmpBase
                    fdb       WRTSTM-StmtJmpBase
                    fdb       GETSTM-StmtJmpBase
                    fdb       PutStmt-StmtJmpBase
                    fdb       CLSSTM-StmtJmpBase
                    fdb       RestoreSetPtr-StmtJmpBase
                    fdb       DLTSTM-StmtJmpBase
                    fdb       CHNSTM-StmtJmpBase
                    fdb       ShellStmt-StmtJmpBase
                    fdb       B0STM-StmtJmpBase
                    fdb       B1STM-StmtJmpBase
                    fdb       SkipRemText-StmtJmpBase
                    fdb       SkipRemText-StmtJmpBase
                    fdb       ENDSTM-StmtJmpBase
                    fdb       SkipTwoBytes-StmtJmpBase
                    fdb       SkipTwoBytes-StmtJmpBase
                    fdb       DIREXC-StmtJmpBase
                    fdb       ELNSTM-StmtJmpBase
                    fdb       NULSTM-StmtJmpBase
                    fdb       NULSTM-StmtJmpBase
                    fdb       SBYTAS-StmtJmpBase
                    fdb       RSTS10-StmtJmpBase
                    fdb       ForRealSetup-StmtJmpBase
                    fdb       SBYTAS-StmtJmpBase
                    fdb       SSTRAS-StmtJmpBase
                    fdb       CallVect5ThenLet-StmtJmpBase

Vect1FnC               jsr       <JmpVect1
                    fcb       $0c

StopMsg               fcc       'STOP Encountered'
                    fcb       C$LF,$FF

* Vector #2 from table at Vect4JmpBase comes here

EXECUT               lda       $17,x               Get something
                    bita      #$01                check if 1st bit is set
                    beq       EXEC10               no, skip ahead
                    ldb       #$33          Err: run aborted
                    bra       ExecErr

EXEC10               tfr       s,d
                    subd      #$0100        Need at least 256 bytes
                    cmpd      <TmpBufBase        is there that much?
                    bhs       ExecCheckStack
                    ldb       #$39          Err: system stack overflow
                    bra       ExecErr

ExecCheckStack               ldd       <WorkspaceFree
                    subd      $0B,x         Remove needed variable storage
                    blo       MEMFUL
                    cmpd      #$0100        minimum opstack?
                    bhs       EXEC20
MEMFUL               ldb       #$20                Memory full error
ExecErr               lbra      EXCERR

EXEC20               std       <WorkspaceFree
                    tfr       y,d
                    subd      $0B,x         Make room for vars on u
                    exg       d,u
                    sts       5,u           Save current stack
                    std       7,u           Save caller's storage address
* (orig: SETGLB)
                    stx       3,u           Set procedure address
EXEC30               ldd       #$0001
                    std       <ArrayBase        Default array base to one
                    sta       1,u           Default trig mode to radians
                    sta       <$13,u        Clear error flag
                    stu       <$14,u        Init subroutine stack
                    bsr       RUNS50         Set I.xxxx globals
                    ldd       <$13,x        Get offset of first data statement
                    beq       StoreDataPtr         bra if none
                    addd      <ModExecAddr        Add ptr to I-Code beginning
StoreDataPtr               std       <StrWorkPtr
                    ldd       $0B,x         Get variable storage size
                    leay      d,u           Get ptr to storage end
                    pshs      y             Save it
                    ldd       <$11,x        Get beginning procedure link
                    leay      d,u           Get ptr to it
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    bra       InitVarCheck

InitVarLoop               std       ,y++
InitVarCheck               cmpy      ,s
                    blo       InitVarLoop
                    leas      2,s           Return scratch
                    ldx       <CurModPtr
* (orig: ASGV20)
                    ldd       <ModExecAddr        Get ptr to I-Code beginning
                    addd      <$15,x        Add offset of first executable statement
                    tfr       d,x
                    bra       StmtLoopEntry         Jump into statment loop

RUNS50               stx       <CurModPtr              Save current module ptr
                    stu       <VarStorePtr        Set storage base address
                    ldd       $0D,x
                    addd      <CurModPtr              Add to start address of module
                    std       <ModSymTbl
                    ldd       $0F,x
                    addd      <CurModPtr              Add to start address of module
                    std       <SymTblSize
                    std       <ModFOff
* (orig: ASGRL1)
                    ldd       M$Exec,x            Get exec offset
                    addd      <CurModPtr              Add to start of module address
                    std       <ModExecAddr              Save exec offset
                    ldd       <$14,u
                    std       <SubrStkPtr
                    std       <StrSpaceTop
                    rts

STMLUP               stx       <ICodeCurPtr
                    lda       <SigFlag              Get signal received flag
                    beq       StmtDispatch               Nothing happened, skip ahead
                    bpl       STML10               No signal flagged, skip ahead
                    anda      #$7F                Mask off signal received bit flag
                    sta       <SigFlag              Save masked version
                    lbsr      Vect1Fn18               JSR <1B, fcb $18
                    lda       <SigFlag              Shift out least sig bit
STML10               rora                    Trace bit set?
                    bcc       StmtDispatch               Not set, skip ahead
                    leay      ,x            Copy I-Code ptr
                    lbsr      Vect1Fn10         Move copy to next statement
                    clr       <IndentDepth
                    bsr       Vect1Fn16
StmtDispatch               bsr       DispatchStmt
StmtLoopEntry               cmpx      <ModFOff
                    blo       STMLUP
                    bra       INIT         ..exit

Vect1Fn16               jsr       <JmpVect1
                    fcb       $16

ENDSTM               ldb       ,x
                    lbsr      CheckEolToken         End of line?
                    beq       INIT         ..yes; don't print anything
                    lbsr      PRTSTM         Print message if there is one
INIT               lbsr      TOFSTM
                    ldu       <VarStorePtr        Get storage base address
                    lds       5,u           Reset stack
                    ldu       7,u           Get caller's storage address
NULSTM               rts                     Statements use this return

SkipTwoBytes               leax      2,x
DispatchStmt               ldb       ,x+
                    bpl       LookupStmtIdx               Hi bit clear, skip ahead
                    addb      #$40                ??? Wrap it around
LookupStmtIdx               lslb                          Multiply by 2
                    clra                          Unsigned D
                    ldu       <JmpTblPtr              Get ptr to StmtJmpBase
                    ldd       d,u                 Get offset
                    jmp       d,u                 Jump to that routine

IFSTM               jsr       <JmpOpcode
                    tst       2,y           Test result
                    beq       GTOSTM
                    leax      3,x           Move I-Code ptr
                    ldb       ,x
                    cmpb      #$3B          is it line ref?
                    bne       NULSTM         Yes; do next statement
* (orig: EIFSTM)
                    leax      1,x           Skip line refernce TOKEN
GTOSTM               ldd       ,x
                    addd      <ModExecAddr        Make offset a ptr
                    tfr       d,x           Move to I-Code ptr
                    rts

SkipOneByte               leax      1,x
                    rts

* UNTIL
WHLSTM               jsr       <JmpOpcode
                    tst       2,y           Check result
                    beq       GTOSTM               False, go back
                    leax      3,x           Skip goto & following (do, then)
                    rts

* NEXT routine
NextDispatch               leay      <NextJmpTbl,pc           Point to table
NextGetJmpOff               ldb       ,x+                 Get byte
                    ldb       b,y                 Get jump offset
                    ldu       <VarStorePtr              Get Base address for variable storage
                    jmp       b,y                 Jump to appropriate routine

FOR1IN               ldd       ,x
                    leay      d,u
                    bra       NxtIntCheckTo

NXT1IN               ldd       ,x
                    leay      d,u           Make offset into ptr
                    ldd       4,x
                    lda       d,u           Test increment sign
                    bpl       NxtIntCheckTo
                    bra       NXTIN2

* Integer STEP 1
NXTIN1               ldd       ,x                  Get offset to current FOR/NEXT INTEGER value
                    leay      d,u                 Point Y to it
                    ldd       ,y                  Get current FOR/NEXT counter
                    ifne      H6309
                    incd                          Add 1 to it
                    else
                    addd      #$0001
                    endc
                    std       ,y                  Save it back
NxtIntCheckTo               ldd       2,x                 Get offset to TO variable
                    leax      6,x                 Eat temp var
                    ldd       d,u                 Get TO variable
                    cmpd      ,y                  We hit it yet?
                    bge       GTOSTM               Yes, do X=[,x]+[ModExecAddr] & return
                    leax      3,x                 Eat 3 bytes from X & return
                    rts

* INTEGER STEP <>1
NXTINT               ldd       ,x                  Y=ptr to current FOR/NEXT INTEGER value
                    leay      d,u           Get counter addr
                    ldd       4,x                 Get STEP value
                    ldd       d,u                 Get current FOR/NEXT counter
                    ifne      H6309
                    tfr       a,e                 Preserve Hi byte (for sign)
                    else
                    pshs      a             Save increment sign
                    endc
                    addd      ,y                  Add increment value
                    std       ,y                  Save new current value
                    ifne      H6309
                    tste                          Was STEP negative value?
                    else
                    tst       ,s+           Going up or down?
                    endc
                    bpl       NxtIntCheckTo               No, go use normal compare routine
NXTIN2               ldd       2,x                 Get offset to TO value
                    leax      6,x                 Eat temp var
                    ldd       d,u                 Get TO value
                    cmpd      ,y                  Hit TO value yet?
                    ble       GTOSTM               Yes, do X=[,x]+[ModExecAddr] & return
                    leax      3,x                 Eat 3 bytes from X & return
                    rts

FOR1RL               ldy       <SubrStkPtr
                    clrb
                    bsr       NXTRLA
                    bra       NXTRL1

ForRlNxStepAlt               ldy       <SubrStkPtr
                    clrb
                    bsr       NXTRLA
                    ldd       4,x           Get increment offset
                    addd      #4            Get offset of increment end
                    ldu       <VarStorePtr        Get storage base
                    lda       d,u           Get sign byte
                    lsra                    Sign
                    bcc       NXTRL1
                    bra       NXTRL2

* NEXT table
* IF some of these entry points are moved before this table, 8 bit addressing
* may be used instead of 16
NextJmpTbl               equ       *
                    fcb       NXTIN1-NextJmpTbl         Integer STEP 1
                    fcb       NXTINT-NextJmpTbl         Integer STEP <>1
                    fcb       NXT1RL-NextJmpTbl         Real STEP 1
                    fcb       NXTRL-NextJmpTbl         Real STEP <>1

* Jump table for FOR (relative to ForJmpTbl) (change to 8 bit if possible)
ForJmpTbl               equ       *
                    fcb       FOR1IN-ForJmpTbl         $ff0e   INT step 1
                    fcb       NXT1IN-ForJmpTbl         $ff14   INT step <>1
                    fcb       FOR1RL-ForJmpTbl         $ff59   REAL step 1
                    fcb       ForRlNxStepAlt-ForJmpTbl         $ff61   REAL step <>1

* REAL NEXT STEP 1
NXT1RL               ldy       <SubrStkPtr              ??? Get subroutine stack ptr
                    clrb
                    bsr       NXTRLA         Move counter to opstack
                    leay      -6,y                Make room for REAL variable
                    ldd       #$0180              Initialize it to contain 1.
                    std       1,y
                    clra
                    clrb
                    std       3,y
                    sta       5,y
                    lbsr      RealAdd               Increment counter (Do REAL add)
                    ifne      H6309
                    ldq       1,y                 Copy REAL # from 1,y to ,u
                    stq       ,u
                    else
                    ldd       1,y                 Copy REAL # from 1,y to ,u
                    std       ,u            Restore it
                    ldd       3,y
                    std       2,u
                    endc
                    lda       5,y
                    sta       4,u
* Incrementing REAL STEP value
NXTRL1               ldb       #2
                    bsr       NXTRLA
                    leax      6,x
                    lbsr      RLCMP               Do REAL # compare
                    lble      GTOSTM               Loop again if still too small
                    leax      3,x           Skip loop addr. & stmt term.
                    rts

NXTRLA               ldd       b,x
                    addd      <VarStorePtr              Add to ptr to start of variable storage
                    tfr       d,u
                    leay      -6,y                Make room for variable
                    lda       #$02                Force it to REAL type
                    ldb       ,u                  Copy real # from u to y
                    std       ,y
                    ifne      H6309
                    ldq       1,u
                    stq       2,y
                    else
                    ldd       1,u
                    std       2,y
                    ldd       3,u
                    std       4,y
                    endc
                    rts

NXTRL               ldy       <SubrStkPtr
                    clrb
                    bsr       NXTRLA         Move counter to opstack
                    stu       <SymbolPtr        Save counter addr
                    ldb       #$04
                    bsr       NXTRLA         Move increment to opstack
                    lda       4,u           Get sign byte
                    sta       <VarTypeCode
                    lbsr      RealAdd               Inc current FOR/NEXT value by STEP (Do REAL Add)
                    ldu       <SymbolPtr        Get counter address
                    ifne      H6309
                    ldq       1,y
                    stq       ,u
                    else
                    ldd       1,y
                    std       ,u
                    ldd       3,y
                    std       2,u
                    endc
                    lda       5,y
                    sta       4,u
                    lsr       <VarTypeCode              Check sign
                    bcc       NXTRL1               Positive, use that direction check
* Decrementing REAL STEP value
NXTRL2               ldb       #$02
                    bsr       NXTRLA         Move terminal to opstack
                    leax      6,x
                    lbsr      RLCMP               Do REAL compare
                    lbge      GTOSTM               Still bigger, keep looping
                    leax      3,x           Skip loop addr. & stmt term.
NXTR30               rts

FORSTM               ldb       <SigFlag              Get flag byte
                    bitb      #$01                Least sig bit set?
                    beq       NXTR30               No, return
                    jsr       <JmpVect1
                    fcb       $1c

FORS20               ldb       ,x+
                    cmpb      #$82
                    beq       ForRealInit
                    bsr       RSTS10         Init counter
                    bsr       FORINT         Init terminal
                    ldb       -1,x          Get next TOKEN
                    cmpb      #$47
                    bne       FORS10
                    bsr       FORINT         Init increment
FORS10               lbsr      GTOSTM
                    leay      >ForJmpTbl,pc           Point to table
                    lbra      NextGetJmpOff         Dispatch to assignment

FORINT               ldd       ,x++
                    addd      <VarStorePtr        Make offset into ptr
                    pshs      d             Save it
                    jsr       <JmpOpcode        Process format string
                    ldd       1,y
                    std       [,s++]        Store it
                    rts

ForRealInit               bsr       ForRealSetup
                    bsr       FORRL         Init terminal
                    ldb       -$01,x
                    cmpb      #$47
                    bne       FORS10         bra if not
                    bsr       FORRL         Init increment
                    bra       FORS10

FORRL               ldd       ,x++
                    addd      <VarStorePtr
                    pshs      d             Save it
                    jsr       <JmpOpcode        Evaluate expression
                    bra       ASGRL         Store result

* LET
LetStmt               jsr       <JmpOpcode              Get var type
LetCheckType               cmpa      #4                  Numeric or Boolean?
                    blo       LetSaveType               Yes, skip ahead
                    pshs      u                   Preserve U
                    ldu       <MaxStrSize              ??? Get max var size for string or array
LetSaveType               pshs      u,a                 Save Size or Ptr & var type
                    leax      1,x           Skip assignment TOKEN
                    jsr       <JmpOpcode
LetEvalResult               puls      a
                    lsla                          x2 for offset into branch table
                    leau      <ASGBRA,pc           Point to branch table
                    jmp       a,u                 Jump to routine

ASGBRA               bra       ASGBYT               LET - Byte
                    bra       ASGINT               LET - Integer
                    bra       ASGRL               LET - Real
                    bra       ASGBYT               LET - Boolean
                    bra       ASGSTR               LET - String
                    bra       ASGRCD               Let - Array

SBYTAS               ldd       ,x
                    addd      <VarStorePtr        make offset into ptr
                    pshs      d
                    leax      3,x           move I-Code ptr
                    jsr       <JmpOpcode        Evaluate expression
* LET - Byte/Boolean
ASGBYT               ldb       2,y                 Get byte/boolean value
                    stb       [,s++]              Save at address on stack, eat stack & return
                    rts

RSTS10               ldd       ,x
                    addd      <VarStorePtr
                    pshs      d
                    leax      3,x
                    jsr       <JmpOpcode
* LET - Integer
ASGINT               ldd       1,y                 Get integer value
                    std       [,s++]              Save at address on stack, eat stack & return
                    rts

ForRealSetup               ldd       ,x
                    addd      <VarStorePtr
                    pshs      d
                    leax      3,x
                    jsr       <JmpOpcode        Evaluate expression
* LET - Real
ASGRL               puls      u
                    ldd       1,y                 Copy 5 bytes from Y+1 to U
                    std       ,u
                    ldd       3,y
                    std       2,u
                    lda       5,y           Insert carriage return
                    sta       4,u
                    rts

SSTRAS               ldd       ,x
                    addd      <SymTblSize        Make offset into ptr
                    tfr       d,u
                    ldd       ,u            Get storage offset
                    addd      <VarStorePtr        Make offset into ptr
                    pshs      d             Save it
                    ldd       2,u           Get string max length
                    pshs      d             Save it
                    leax      3,x
                    jsr       <JmpOpcode        Evaluate expression
* LET - String
ASGSTR               puls      u,d
                    tstb
                    bne       ASGSR0
                    deca
ASGSR0               sta       <MaxStrSize
                    ldy       1,y           Get result addr
                    sty       <StrStkPtr        Clean string stack
* Block copy up to $FF (string terminator)
ASGSR1               lda       ,y+
                    sta       ,u+           Store it
                    cmpa      #$FF                End of string?
                    beq       AsgStrDone               Yes, skip ahead
                    decb                          Dec string size counter
                    bne       ASGSR1               More left, continue copying
                    dec       <MaxStrSize
                    bpl       ASGSR1
AsgStrDone               clra                    Carry
                    rts

* LET - Array
ASGRCD               puls      u,d
                    cmpd      3,y           is result smaller?
                    bls       POKSTM         bra if not
                    ldd       3,y           Get result size
POKSTM               ldy       1,y
                    exg       y,u
                    jsr       <JmpVect2              Return from routine
                    fcb       $06

PokeStmt               jsr       <JmpOpcode
                    ldd       1,y
                    pshs      d             Save it
                    jsr       <JmpOpcode
                    ldb       2,y
                    stb       [,s++]
                    rts

STPSTM               lbsr      PRTSTM
                    lda       <StdoutPath
                    sta       <CurrChanPath
                    leax      >StopMsg,pc           Point to 'STOP encountered'
                    lbsr      STROUT         Float it
                    lbra      Vect1Fn6         Call command to exit

PrintThenFn18               lbsr      PRTSTM
Vect1Fn18               jsr       <JmpVect1              Use module header jump vector #1
                    fcb       $18

GSBSTM               ldd       ,x
                    leax      3,x           Skip offset & statement end
GSBST1               ldy       <VarStorePtr
                    ldu       <$14,y        Get subroutine stack ptr
                    cmpu      <ICodeEndPtr        Check for overflow
                    bhi       GSBST2         bra if ok
                    ldb       #$35                Subroutine stack overflow error
                    lbra      EXCERR

GSBST2               stx       ,--u
                    stu       <$14,y        Save sub stack ptr
                    stu       <SubrStkPtr        Reset opstack
                    addd      <ModExecAddr        Make offset a ptr
                    tfr       d,x           Move to I-Code ptr
                    rts

RETSTM               ldy       <VarStorePtr
                    cmpy      <$14,y        Are there any return addrs?
                    bhi       RETST1         bra if so
                    ldb       #$36                Subroutine stack underflow error
                    lbra      EXCERR

RETST1               ldu       <$14,y
                    ldx       ,u++          Pop return addr
                    stu       <$14,y        Save sub stack ptr
                    stu       <SubrStkPtr        Reset opstack
                    rts

ONSTM               ldd       ,x
                    cmpa      #$1E          is this ON ERROR?
                    beq       ONSTM2         Yes; go init error address
                    jsr       <JmpOpcode        Get dispatch value
                    ldd       ,x            Get count (of line nums)
                    ifne      H6309
                    lsld
                    lsld
                    else
                    lslb
                    rola
                    lslb
                    rola
                    endc
                    addd      #$0002        Add for count
                    leau      d,x           Get ptr to next statement
                    pshs      u             Save it
                    ldd       1,y           Get dispatch value
                    ble       ONSTM1         bra if <=0
                    cmpd      ,x++          is it out of range?
                    bhi       ONSTM1         Yes; skip to next statement
                    subd      #$0001        Adjust from 1,2,3,.. to 0,1,2,..
                    ifne      H6309
                    lsld
                    lsld
                    else
                    lslb
                    rola
                    lslb
                    rola
                    endc
                    addd      #$0001
                    ldd       d,x           Get I-Code offset of destination
* 6809 - Change to PSHS B/PULS X,B
                    pshs      d             Save it
* (orig: RSTSTM)
                    ldb       ,x            Get TOKEN following dispatch expression
                    cmpb      #$22          is this ON .. GOSUB?
                    puls      x,d           Get registers ready
                    beq       GSBST1         bra if ON .. GOSUB
                    addd      <ModExecAddr        Make offset into ptr
                    tfr       d,x           Use as I-Code ptr
OnStmtDone               rts

ONSTM1               puls      pc,x

ONSTM2               ldu       <VarStorePtr
                    cmpb      #$20          is it ON ERROR GOTO?
                    bne       ONSTM3         bra if not
                    ldd       2,x           Get I-Code offset
                    addd      <ModExecAddr        Make offset into ptr
                    std       <$11,u
                    lda       #$01          Mark error trap armed
                    sta       <$13,u
                    leax      5,x           Skip to next statement
                    rts

ONSTM3               clr       <$13,u
                    leax      2,x           Skip to next statement
                    rts

CRTSTM               bsr       OPNSUB
                    ldb       #%00001011          Read/Write/Public Read
                    os9       I$Create            Create the file
                    bra       OPNS10

OpenFileStmt               bsr       OPNSUB
                    os9       I$Open        Put record
OPNS10               lbcs      EXCERR
                    puls      u,b           Get TYPE & address
                    cmpb      #$01          is it integer?
                    bne       OPNS20         bra if not
                    clr       ,u+           Clear msb
OPNS20               sta       ,u
                    puls      pc,x

OPNSUB               leax      1,x
                    lbsr      ASGVAR         Get variable address
                    leax      1,x           Skip comma
                    jsr       <JmpOpcode        Get path name
                    lda       #$03
                    cmpb      #$4A          is there declared mode?
                    bne       OPNS30         bra if not
                    lda       ,x++          get mode specified
OPNS30               ldu       3,s
                    stx       3,s           Save I-Code ptr
                    ldx       1,y           Get pathlist ptr
                    jmp       ,u

SEKSTM               lbsr      SETCHL
                    jsr       <JmpOpcode        Get position
                    ldb       #$0E          Set code
                    lbsr      CallJmpVect6Fn2
                    lbcs      EXCER1         bra if error
* (orig: NOCHG)
                    rts

* Input prompt?
InputPromptStr               fcc       '? '
                    fcb       $ff

* Illegal input error message
InputErrStr               fcc       '** Input error - reenter **'
                    fcb       $0d,$ff

INPSTM               lda       <StdoutPath
                    lbsr      SETCHL         Set path number
                    lda       #$2C          use comma as item separator
                    sta       <ItemSepChar        set item separator
                    pshs      x             Save x
INPS10               ldx       ,s
                    ldb       ,x            Get next TOKEN
                    cmpb      #$90          is there prompt?
                    bne       UseDefaultPrompt         No; use default
                    jsr       <JmpOpcode        Evaluate it
* (orig: INPS20)
                    pshs      x             Save I-Code ptr
                    ldx       1,y           Get ptr to string
                    bra       INPS30

UseDefaultPrompt               pshs      x
                    leax      <InputPromptStr,pc           Point to '? '
INPS30               bsr       STROUT
                    puls      x             Restore I-Code ptr
                    lda       <CurrChanPath
                    cmpa      <StdoutPath        proper child dead?
                    bne       RDST05
                    lda       <StdinPath
                    sta       <CurrChanPath
RDST05               ldb       #$06
DoReadLn               bsr       CallJmpVect6Fn2
                    bcc       INPS40         ..continue if no error
                    cmpb      #$03          Keyboard interrupt?
                    lbne      EXCER1
                    lbsr      DEBUG         print line, call debugger
                    clr       <ErrCode              Clear out error code
                    bra       INPS10         Re-issue input request

INPS40               bsr       INPVAR
                    bcc       INPS50         bra if so
                    leax      <InputErrStr,pc           Print 'Input error re-enter'
                    bsr       STROUT         Print error msg
                    bra       INPS10         Check it out

INPS50               ldb       ,x+
                    cmpb      #$4B          Are there more?
                    beq       INPS40         Yes; skip a data entry
                    puls      pc,d          Clean stack & return

INPVAR               bsr       ASGVAR
                    ldb       ,s            Get TYPE
                    addb      #$07          Get code for input of TYPE
                    ldy       <SubrStkPtr        Init opstack ptr
                    bsr       CallJmpVect6Fn2         Set up for system call
                    lbcc      LetEvalResult         Go dispatch for assignment
***************
* Bad Input Handler
* (orig: BADLIN)
                    lda       ,s            Get TYPE
BADLI1               cmpa      #$04
                    bcs       BadInputClean         is simple; do normal clean up
                    leas      2,s           Remove extra bytes
BadInputClean               leas      3,s
                    coma                    Carry
                    rts

***************
* Call CNVIO to Output String
STROUT               pshs      y
                    leas      -6,s
                    leay      ,s
                    stx       1,y
                    ldd       <TmpBufBase        Reset I/O buffer ptr
                    std       <TmpBufCur
                    ldb       #$05
                    bsr       CallJmpVect6Fn2
                    clrb
                    bsr       CallJmpVect6Fn2               call Vect6Dispatch, function 2, sub-function 0 (B)
                    leas      6,s           Clean up stack
                    puls      pc,y

CallJmpVect6Fn2               jsr       <JmpVect6              Use module header jump vector #6
                    fcb       $02                 Function code

ASGVAR               lda       ,x+
                    cmpa      #$0E          is it complex assignment?
                    bne       AsgvSimple         No; do simple
                    jsr       <JmpOpcode        Evaluate it
                    bra       AsgvReturn

AsgvSimple               suba      #$80
                    cmpa      #$04          What type?
                    blo       AsgvLoadOff
                    beq       ASGV30         Yes; done
                    lbsr      CallJmpVect5Fn2         Must be parameter or unbound variable
                    bra       AsgvReturn

ASGV30               ldd       ,x++
                    addd      <SymTblSize
                    tfr       d,u
                    ldd       2,u
                    std       <MaxStrSize        Save it
                    ldd       ,u            Get storage offset
                    bra       ASGV40

AsgvLoadOff               ldd       ,x++
ASGV40               addd      <VarStorePtr
                    tfr       d,u
                    lda       -3,x          Get TOKEN
                    suba      #$80          Change TOKEN to TYPE
AsgvReturn               puls      y
                    cmpa      #$04          need to save size?
                    blo       AsgvSaveAddr
                    pshs      u
                    ldu       <MaxStrSize        get size
AsgvSaveAddr               pshs      u,a
                    jmp       ,y            Return

SETCHL               ldb       ,x
                    cmpb      #$54          is it path token?
                    bne       SETC10         bra if not
                    leax      1,x
                    jsr       <JmpOpcode        Process path number expression
                    cmpb      #$4B          Skip comas if present
                    beq       SETC05         bra if coma last
                    leax      -1,x          Compensate for eval
SETC05               lda       2,y
SETC10               sta       <CurrChanPath
                    rts

RDSTM               ldb       ,x
                    cmpb      #$54
                    bne       RDST30
                    bsr       SETCHL         Set path number
                    clr       <ItemSepChar        use zero as item separator
                    cmpb      #$4B          is it coma?
                    bne       PUSNG2         bra if not
                    leax      -1,x          Back up to it
***************
* List Process Loop
PUSNG2               ldb       #$06                Call Vect6Dispatch, function 2, sub-function 6 (B)
                    bsr       CallJmpVect6Fn2               (Do ReadLn into temp buff, max of 256 bytes)
                    bcc       RDST20               No error in ReadLn, skip ahead
                    cmpb      #E$PrcAbt           ??? Process aborted error?
                    beq       PUSNG2               Yes, try to do ReadLn again
RDSTErr               lbra      EXCER1

RDST10               lbsr      INPVAR
                    bcs       RDSTErr
RDST20               ldb       ,x+
                    cmpb      #$4B
                    beq       RDST10
                    rts

RDST30               bsr       CheckEolToken
                    beq       SKPDAT
ReadDataLoop               bsr       RDDATA
                    ldb       ,x+
                    cmpb      #$4B
                    beq       ReadDataLoop
                    rts

RDDATA               lbsr      ASGVAR
                    bsr       EVLDAT
                    lda       ,s
                    bne       RDDAT1
                    inca
RDDAT1               cmpa      ,y
                    lbeq      LetEvalResult
                    cmpa      #$02
                    blo       RddatIntFx
                    beq       RddatRealExpr
RDDAT2               ldb       #$47                Illegal Expression Type
                    bra       RDDATErr

RddatIntFx               lda       ,y                  Get var type
                    cmpa      #$02                Real #?
                    bne       RDDAT2               No, exit with Illegal Expression Type erro
                    bsr       ASGSTM               Call FIX (REAL to INT) routine
                    lbra      LetEvalResult

ASGSTM               jsr       <JmpVect5
                    fcb       $0c
CallJmpVect5FnE               jsr       <JmpVect5
                    fcb       $0e

RddatRealExpr               cmpa      ,y
                    bcs       RDDAT2         ..No
                    bsr       CallJmpVect5FnE
                    lbra      LetEvalResult

SKPDAT               leax      1,x
EVLDAT               pshs      x
                    ldx       <StrWorkPtr
                    bne       EVLD10
                    ldb       #$4F                Missing Data Statement error
RDDATErr               lbra      EXCERR

EVLD10               jsr       <JmpOpcode
                    cmpb      #$4B
                    beq       EVLD20
                    ldd       ,x            Get descr area offset
                    addd      <ModExecAddr
                    tfr       d,x
EVLD20               stx       <StrWorkPtr
                    puls      pc,x

CheckEolToken               cmpb      #$3F
                    beq       EOLT99
                    cmpb      #$3E
EOLT99               rts

PRTSTM               lda       <StdoutPath
                    lbsr      SETCHL         Set sign
                    ldd       <TmpBufBase
                    std       <TmpBufCur
                    ldb       ,x+           Get status code
* (orig: PRTST3)
                    cmpb      #$49
                    beq       PUSING
PRTST2               bsr       CheckEolToken
                    beq       PRTST7
PrintListCheck               cmpb      #$4B
                    beq       PrintSepCR
                    cmpb      #$51
                    beq       PRTST6
                    leax      -1,x
                    jsr       <JmpOpcode
* (orig: PRTST4)
                    ldb       ,y
                    addb      #$01
                    bsr       IODISP
* (orig: PRTST5)
                    ldb       -1,x
                    bra       PRTST2

PrintSepCR               ldb       #$0D
                    bsr       IODISP
PRTST6               ldb       ,x+
                    bsr       CheckEolToken
                    bne       PrintListCheck
                    bra       PrintFlushBuf

PRTST7               ldb       #$0C                Vect6Dispatch, function 2, sub-function C
                    bsr       IODISP               (WritLn a Carriage return)

PrintFlushBuf               clrb                          Vect6Dispatch, function 2, sub-function 0
                    bsr       IODISP               (WritLn the temp buffer)
                    lda       <SavedChar
                    clr       <SavedChar
                    tsta
                    bne       IOError
PRTST9               rts

IODISP               lbsr      CallJmpVect6Fn2               Call <JmpVect6, function 2
                    bcc       PRTST9               If no error, return
IOError               lbra      EXCER1               Error from WritLn, report it

PUSING               jsr       <JmpOpcode
                    ldd       <ICodeEndPtr
                    std       <FmtEndPtr
                    std       <FmtScanPtr
                    ldu       <SubrStkPtr
                    pshs      u,d
                    clr       <RptFlag
                    ldd       <StrStkPtr
                    std       <ICodeEndPtr
PrintUsingLoop               ldb       -1,x
                    bsr       CheckEolToken
                    beq       PrintUsingNoCR
                    ldb       ,x+
                    bsr       CheckEolToken
                    beq       PUSN25
                    leax      -1,x
                    ldb       #$11
                    lbsr      CallJmpVect6Fn2
                    bcc       PrintUsingLoop
                    puls      u,d
                    std       <ICodeEndPtr
                    stu       <SubrStkPtr
                    bra       IOError

PUSN25               leay      <PrintFlushBuf,pc           Point to routine
                    bra       PUSN35

PrintUsingNoCR               leay      <PRTST7,pc           Point to routine
PUSN35               puls      u,d
                    std       <ICodeEndPtr
                    stu       <SubrStkPtr
                    jmp       ,y

WRTSTM               lda       <StdoutPath
                    lbsr      SETCHL
                    ldu       <TmpBufBase
                    stu       <TmpBufCur        Put str addr on opstack
                    ldb       ,x+
                    lbsr      CheckEolToken
                    beq       WRTS30
                    cmpb      #$4B
                    beq       WRTS20
                    leax      -1,x
                    bra       WRTS20

WRTS10               clra
                    ldb       #$12
                    lbsr      CallJmpVect6Fn2         Move to opstack
                    bcs       IOError
WRTS20               jsr       <JmpOpcode
                    ldb       ,y
                    addb      #$01
                    lbsr      CallJmpVect6Fn2
                    bcs       IOError         bra if so
                    ldb       -$01,x
                    lbsr      CheckEolToken         Get mod(arg,2pi)
                    bne       WRTS10
WRTS30               lbra      PRTST7

GETSTM               bsr       GPSET
                    os9       I$Read
                    bra       PUTSTM90

PutStmt               bsr       GPSET
                    os9       I$Write
PUTSTM90               leax      ,u
                    bcc       GPSE99
PUTErr               lbra      EXCERR

GPSET               lbsr      SETCHL
                    lbsr      ASGVAR
                    leau      ,x
                    puls      a
                    cmpa      #$04
                    bhs       GPSE10
                    leax      >VarSizeTable2,pc           Point to 4 entry, 1 byte table
                    ldb       a,x
                    clra
                    tfr       d,y                 Y=table entry
                    bra       GpseSetupPath

GPSE10               puls      y
GpseSetupPath               puls      x
                    lda       <CurrChanPath
GPSE99               rts

CLSSTM               lbsr      SETCHL
                    os9       I$Close             Close path
                    bcs       PUTErr               Error,
                    cmpb      #$4B
                    beq       CLSSTM
                    rts

RestoreSetPtr               ldb       ,x+
                    cmpb      #';
                    beq       RestoreAbsPtr
                    ldu       <CurModPtr              Get ptr to current procedure
* (orig: RSTS20)
                    ldd       $13,u
SetRestorePtr               addd      <ModExecAddr
                    std       <StrWorkPtr
                    rts

RestoreAbsPtr               ldd       ,x
                    addd      #$0001        Make ptr to end of string - length pattern
                    leax      3,x
                    bra       SetRestorePtr

DLTSTM               jsr       <JmpOpcode
                    pshs      x
                    ldx       1,y                 Get ptr to full pathlist
                    os9       I$Delete            Delete file
DLTS10               bcs       PUTErr               Error, deal with it
                    puls      pc,x                Restore X & return

CHDSTM               jsr       <JmpOpcode
                    lda       #READ.              Open directory in Read mode
CHDS10               pshs      x                   Preserve X
                    ldx       1,y                 Get ptr to full path list
                    os9       I$ChgDir            Change directory
                    bra       DLTS10

ChxdStmt               jsr       <JmpOpcode
                    lda       #EXEC.              Execution directory
                    bra       CHDS10               Go change execution directory

SPATH               lbsr      ASGVAR
                    ldy       <SubrStkPtr        Get opstack ptr
                    leay      -6,y
                    ldb       <CurrChanPath
                    clra
                    std       1,y
                    lbra      LetEvalResult

CHNSTM               jsr       <JmpOpcode
                    ldy       1,y                 Get what will be param area ptr
                    pshs      u,y,x
                    bsr       SYSSTM
                    puls      u,y,x
                    bsr       SYSSUB               Set regs for chain to SHELL
                    sts       <ICodeScanFlag              Save stack ptr
                    lds       <TmpBufBase              Get other stack ptr
                    os9       F$Chain             Chain to other program
                    lds       <ICodeScanFlag              Chain obviously didn't work, get old SP back
                    bra       EXCERR               Process error code

SYSSTM               jsr       <JmpVect1
                    fcb       $0e

ShellStmt               jsr       <JmpOpcode
                    pshs      u,x
                    ldy       1,y
                    bsr       SYSSUB               Do stuff & point X to 'shell'
* (orig: SYSSTM10)
                    os9       F$Fork              Fork a shell
                    bcs       EXCERR               If error, go to error routine
                    pshs      a                   Save process #
ShellWaitLoop               os9       F$Wait              Wait until child process is done
                    cmpa      ,s                  Got wakeup signal, was it our child?
                    bne       ShellWaitLoop               No, keep waiting
                    leas      1,s                 Yes, eat process # off of stack
                    tstb                          Error?
                    bne       EXCERR               Yes, go to error routine
                    puls      pc,u,x              No, restore regs & return

ShellName               fcc       'SHELL'
                    fcb       C$CR

* Entry: Y=Ptr to parameter area
SYSSUB               ldx       <StrStkPtr
                    lda       #C$CR
                    sta       -1,x
* Should be SUBR y,x / TFR y,u / TFR x,y / LEAX <ShellName,pc / clrd / RTS
                    tfr       x,d
                    leax      <ShellName,pc           Point to 'Shell'
                    leau      ,y                  Point U to parameter area
                    pshs      y
                    subd      ,s++
                    tfr       d,y                 Move param area size to Y
                    clra                          Any language/type
                    clrb                          Data area size to 0 pages
                    rts

ERRSTM               jsr       <JmpOpcode
                    ldb       2,y           Zero divisor error
* Error routine from forking a shell?
EXCERR               stb       <ErrCode              Save error code
EXCER1               ldu       <VarStorePtr
                    beq       EXCER4
                    tst       <$13,u        Test divisor
                    beq       EXCER2         ..No
                    lds       5,u
                    ldx       <$11,u
                    ldd       <$14,u
                    std       <SubrStkPtr
* (orig: BYESTM)
                    lbra      STMLUP

EXCER2               bsr       DEBUG
                    bsr       TOFSTM
                    lbra      Vect1Fn6

* Entry: B=Error code
EXCER4               lbsr      Vect1Fn2               Print error message
                    lbra      Vect1Fn6

AlphaScreenCode               fcb       $0E                 Display Alpha code (for VDGInt screen)
                    fcb       $ff                 String terminator

DEBUG               leax      <AlphaScreenCode,pc           Point to force alpha string code
                    lbsr      STROUT               Go print it out to shut off any VDGInt gfx screen
                    ldx       <ICodeCurPtr
                    leay      ,x
                    bsr       Vect1Fn10
                    clr       <IndentDepth        Clear x coordinate sign
                    lbsr      Vect1Fn16         Return pi/2
                    ldb       <ErrCode              Get error code
                    lbsr      Vect1Fn2               Print error message
                    jsr       <JmpVect1              Call function & return from there
                    fcb       $18

* BASE 0
B0STM               clrb                          Save 0 in <42, incx, return
                    bra       BASSTM

* BASE 1
B1STM               ldb       #1                  Save 1 in <42, incx, return
BASSTM               clra
                    std       <ArrayBase
                    leax      1,x
                    rts

Vect1Fn10               jsr       <JmpVect1
                    fcb       $10

* REM/TRON/TROFF/PAUSE/RTS
* Skip # bytes used up by REM text
SkipRemText               ldb       ,x+                 Get # bytes to skip ahead
                    abx                           Point X to next instruction
                    rts

DIREXC               exg       x,pc                Jump to routine pointed to by X
                    rts                           If EXG X,PC done again, return from here

TraceListLine               leay      ,x
                    bsr       Vect1Fn10
                    leax      ,y
                    rts

ELNSTM               ldb       #$33                Line with compiler error
                    bra       EXCERR

DEGSTM               lda       #$01
                    bra       RAD2

RADSTM               clra
RAD2               ldu       <VarStorePtr
                    sta       1,u
                    leax      1,x
                    rts

***************
* Set/Clear Trace Flag
TONSTM               lda       <SigFlag              Get signal flags
                    bita      #$01                LSb set?
                    bne       TogTraceDone               Yes, exit
                    ora       #$01                force it on
                    bra       CHGTRC

TOFSTM               lda       <SigFlag              Get signal flags
                    bita      #$01                Least sig set?
                    beq       TogTraceDone               Yes, return
                    anda      #$FE                Clear least sig
CHGTRC               sta       <SigFlag              Save modified copy
                    ldd       <JmpTarget              Swap JMP ptrs between Vect1Fn1A & EVAL
                    pshs      d
                    ldd       <EvalSetup
                    std       <JmpTarget
                    puls      d
                    std       <EvalSetup
TogTraceDone               rts

Vect1Fn0               jsr       <JmpVect1              Verify/Insert module into workspace
                    fcb       $00

* Copy DIM'd array
CallJmpVect5Fn2               jsr       <JmpVect5
                    fcb       $02

CallVect5ThenLet               bsr       CallJmpVect5Fn2
                    lbra      LetCheckType

* Entry: U=source ptr of copy (or CallJmpVect5Fn2 generates U - Look up in string pool)
CopyVarEntry               bsr       CallJmpVect5Fn2
                    pshs      x
                    ldb       <VarDefByte
                    cmpb      #$A0
                    beq       RUNS10
                    ldy       <StrStkPtr              Get destination ptr for copy
                    ldx       <MaxStrSize              Get max size of copy
RUNS05               lda       ,u+                 Get byte
                    leax      -1,x                Bump counter down
                    beq       RUNS07               Finished, skip ahead
                    sta       ,y+                 Save char
                    cmpa      #$FF                String terminator?
                    bne       RUNS05               No, keep copying
                    lda       ,--y                Yes, get last char before terminator
RUNS07               ora       #$80                Set hi bit on last char
                    sta       ,y                  Save it out
                    ldy       <StrStkPtr
                    bsr       Vect1Fn0
                    bcs       BADPRC
                    leau      ,x
RUNS10               ldd       ,u
                    bne       RUNS20
                    ldy       <SymbolPtr
                    leay      3,y
                    bsr       Vect1Fn0
                    bcs       BADPRC         bra if so
                    ldd       ,x            Return large number
                    std       ,u
RUNS20               ldx       ,s
                    std       ,s
                    ldu       <VarStorePtr
                    lda       <SigFlag              Get flags
                    sta       ,u                  Save them
                    ldb       <ParmPktCnt
                    stb       2,u
                    ldd       <ICodeEndPtr              Get ptr to 1st free byte in I-code workspace
                    std       $D,u                Save it
                    ldd       <ParmEndPtr              Get ptr to end of parm packets being passed
                    std       $F,u
                    ldd       <StrWorkPtr
                    std       9,u
                    bsr       RPARAM
                    stx       $B,u
                    puls      x                   Get ptr to module to be called
                    lda       M$Type,x            Get module type/language
                    beq       RUNS40               If 0 (un-packed BASIC09), skip ahead
                    cmpa      #$22                Is it a packed RUNB subroutine module?
                    beq       RUNS40               Yes, skip ahead
                    cmpa      #$21                Is it an ML subroutine module?
                    beq       RUNS30               Yes, skip ahead
BADPRC               ldb       #$2B                If none of the above, Unknown Procedure Error
RUNERR               lbra      EXCERR

* ML subroutine call goes here
* Entry: X=Ptr to ML subroutine module to be called
RUNS30               ldd       5,u
                    pshs      d             Save I-Code ptr
                    sts       5,u                 Save old stack ptr
                    leas      ,y                  Point stack to all the ptr/size packets for parms
                    ldd       <ParmEndPtr              Get ptr to end of parm packets @ Y
* 6309: Change PSHS/SUBD to SUBR Y,D
                    ifne      H6309
                    subr      y,d                 Calc size of all parm packets being sent
                    lsrd                          /4 to get # of parms being sent
                    lsrd
                    else
                    pshs      y                   Put start of parms packets ptr on stack
                    subd      ,s++                Calculate size of all parm packets being sent
                    lsra                          Divide by 4 (to get # parms being sent)
                    rorb
                    lsra
                    rorb
                    endc
                    pshs      d                   Preserve # parms waiting on stack
                    ldd       M$Exec,x            Get execution offset
* USELESS-ROUTINE CHECKS FOR LINE WITH COMPILER ERROR & POSSIBLE STACK OVERFLOW
* BUT IT NEVER GETS CALLED - UNLESS MEANT FOR SUBROUTINE MODULE
* MAYBE IT SHOULD CALL ROUTINE, MAY BE PROBLEM WITH SOME CRASHES (LIKE EMULATE)
                    leay      >EXECUT,pc           Point to routine
                    jsr       d,x                 Call ML subroutine module
                    ldu       <VarStorePtr              Get ptr to U block of data from above
                    lds       5,u                 Get old stack ptr back
                    puls      x                   Get original 5,u value
                    stx       5,u                 Save it back
                    bcc       SubrCallReturn               If no error, resume program
                    bra       RUNERR               Notify user of error from ML subroutine

* BASIC09 or RUNB module subroutine call goes here
RUNS40               lbsr      TOFSTM               If line with compiler err flg set, swap 17/19 vectors
                    lda       <SigFlag              Get flags
                    anda      #$7F                Mask out pending signal flag
                    sta       <SigFlag              Save flags back
                    lbsr      EXECUT               Go check for line with compiler error/stack ovrflw
                    lda       ,u
                    bita      #$01
                    beq       SubrCallReturn
                    lbsr      TONSTM         Get sqr(1-arg*arg)
                    lda       ,u
                    sta       <SigFlag
SubrCallReturn               ldd       $D,u
                    std       <ICodeEndPtr
                    ldd       $F,u
                    std       <ParmEndPtr              Save end of parm packets ptr
                    ldd       9,u
                    std       <StrWorkPtr
                    ldb       2,u
                    sex
                    std       <ArrayBase
                    ldx       $3,u
                    lbsr      RUNS50
                    ldx       $B,u
                    ldd       <StrSpaceTop
                    subd      <ICodeEndPtr              Subtract ptr to next free byte in workspace
                    std       <WorkspaceFree              Save # bytes free for user
                    rts

* Table of size of variables
VarSizeTable2               fcb       1                   Byte    (type 0)
                    fcb       2                   Integer (type 1)
                    fcb       5                   Real    (type 2)
                    fcb       1                   Boolean (type 3)

* Vector from $31E8
* Entry: U=
*        X=
RPARAM               pshs      u
                    ldb       ,x+
                    clra                          Set flag on stack to 0
                    pshs      x,a
                    cmpb      #$4D
                    bne       RPAR50
                    leay      ,s                  Point Y to flag byte on stack
RparParamLoop               pshs      y                   Save ptr to flag byte
                    ldb       ,x
                    cmpb      #$0E
                    beq       RPAR25
                    jsr       <JmpOpcode
                    leax      -1,x
                    cmpa      #2                  Real variable?
                    beq       RPAR15               Yes, skip ahead
                    cmpa      #4                  String/complex type variable?
                    beq       RPAR20               Yes, set up string stuff
                    ldd       1,y                 Byte/Integer/Boolean - Get value from var packet
                    std       4,y                 Duplicate it later in var packet
                    lda       ,y                  Get variable type again
RPAR15               ldb       #6                  Get size of var packet
                    leau      <VarSizeTable2,pc           Point to var size table
                    subb      a,u                 Calculate ptr to beginning of actual var value
                    leau      b,y                 Bump U to point to first byte of actual var value
                    stu       <SubrStkPtr              ??? Save some sort of variable ptr?
                    bra       RPAR30

* String being passed?
RPAR20               ldu       1,y                 Get ptr to actual string data
                    ldd       <StrStkPtr
                    subd      <ICodeEndPtr              Subtract ptr to next free byte in workspace
                    std       <MaxStrSize              Save result as ptr to string/complex
                    ldd       <StrStkPtr
                    std       <ICodeEndPtr              Save new ptr to next free byte in workspace
                    lda       #4                  Variable type=String/complex
                    bra       RPAR30

RPAR25               leax      1,x
                    jsr       <JmpOpcode
RPAR30               puls      y                   Get ptr to flag byte
                    inc       ,y                  Bump up flag
                    cmpa      #4                  Variable type numeric?
                    blo       RparSaveType               Yes, skip ahead
                    pshs      u                   String/complex, save var data ptr
                    ldu       <MaxStrSize              Get some ptr
RparSaveType               pshs      u,a                 Save variable ptr, variable type
                    ldb       ,x+
                    cmpb      #$4B
                    beq       RparParamLoop
                    leax      1,x           Get scratch for time
                    stx       1,y
                    leax      <VarSizeTable2,pc           Point to 4 entry, 1 byte table
                    ldu       <SubrStkPtr        Get string stack ptr
                    stu       <ParmEndPtr              Save ptr to end of parm packets
RparBuildLoop               puls      b                   Get variable type
                    cmpb      #4                  Is it a numeric type?
                    blo       RPAR40               Yes, go process
                    puls      d                   No, get variable ptr again
                    bra       RPAR45               Go handle string/complex

RPAR40               ldb       b,x                 Get size of variable
                    clra                          D=size
RPAR45               std       ,--u                Save size of variable into parm area
                    puls      d                   Get ptr to variable
                    std       ,--u                Save ptr to variable
                    dec       ,y                  Any vars left to pass?
                    bne       RparBuildLoop               ??? Yes, continue building parm area
                    leay      ,u                  ??? No, point Y to parm area
                    bra       RparSaveSize

RPAR50               ldy       <SubrStkPtr
                    sty       <ParmEndPtr
RparSaveSize               tfr       y,d
                    subd      <ICodeEndPtr
                    lblo      MEMFUL
                    std       <WorkspaceFree
                    puls      pc,u,x,a

EvalAndFn0A               jsr       <JmpOpcode
                    ldy       1,y
                    pshs      x
                    bsr       Vect1FnA
                    puls      pc,x

Vect1FnA               jsr       <JmpVect1
                    fcb       $0a

InitJmpTables               bsr       CallJmpVect5Fn0
                    leax      >StmtJmpBase,pc           Point to huge jump table
                    stx       <JmpTblPtr              Save as address somewhere
                    rts

CallJmpVect5Fn0               jsr       <JmpVect5              Use module header jump vector #5
                    fcb       $00                 Function code

Vect5Dispatch               pshs      x,d                 Preserve regs
                    ldb       [<4,s]              Get function code
                    leax      <Vect5JmpBase,pc           Point to function code jump table
                    ldd       b,x                 Get offset
                    leax      d,x                 Point X to subroutine
                    stx       4,s                 Save overtop original PC
                    puls      pc,x,d              Restore regs & jump to function code routine

Vect5JmpBase               fdb       InterpreterInit-Vect5JmpBase         0
                    fdb       VarRefSetup-Vect5JmpBase         2 Copy DIM'd arrary to temp var pool
                    fdb       RealAdd-Vect5JmpBase         4 Real # add
                    fdb       RealMul-Vect5JmpBase         6 Real # multiply
                    fdb       RealDiv-Vect5JmpBase         8 Real # divide
                    fdb       RLCMP-Vect5JmpBase         A Set flags for Real comparison
                    fdb       FIX-Vect5JmpBase         C FIX (Round & convert REAL to INTEGER)
                    fdb       FLOAT-Vect5JmpBase         E FLOAT (Convert INTEGER/BYTE to REAL)

* Function routines
* Negative offsets from base of table @ VarCopyBase
                    fdb       MIDFNC-VarCopyBase         MID$
                    fdb       LeftFnc-VarCopyBase         LEFT$
                    fdb       RGTFNC-VarCopyBase         RIGHT$
                    fdb       CHRFNC-VarCopyBase         CHR$
                    fdb       STRFNI-VarCopyBase         STR$ (for INTEGER)
                    fdb       StrFnReal-VarCopyBase         STR$ (for REAL)
                    fdb       DATFNC-VarCopyBase         DATE$
                    fdb       TABFNC-VarCopyBase         TAB
                    fdb       FIX-VarCopyBase         FIX (round & convert REAL to INTEGER)
                    fdb       FIXNEX-VarCopyBase         ??? (calls fix but eats 1 var 1st)
                    fdb       FixEat2Vars-VarCopyBase         ??? (calls fix but eats 2 vars 1st)
                    fdb       FLOAT-VarCopyBase         FLOAT (convert INTEGER to REAL)
                    fdb       FLTNEX-VarCopyBase         ??? (calls float though)
                    fdb       BLNOT-VarCopyBase         Byte - LNOT
                    fdb       NEGINT-VarCopyBase         Integer - Negate a number
                    fdb       NEGRL-VarCopyBase         Real - Negate a number
                    fdb       BLAND-VarCopyBase         Byte - LAND
                    fdb       BLXOR-VarCopyBase         Byte - LOR
                    fdb       BlxorOp-VarCopyBase         Byte - LXOR
                    fdb       IntGT-VarCopyBase         > : Integer/Byte relational
                    fdb       RlcmpGT-VarCopyBase         > : Real relational
                    fdb       StrcmpGT-VarCopyBase         > : String relational
                    fdb       INCMLT-VarCopyBase         < : Integer/Byte relational
                    fdb       RLCMLT-VarCopyBase         < : Real relational
                    fdb       STCMLE-VarCopyBase         < : String relational
                    fdb       INCMEQ-VarCopyBase         <> or >< : Integer/Byte relational
                    fdb       RLCMEQ-VarCopyBase         <> or >< : Real relational
                    fdb       StrcmpNE-VarCopyBase         <> or >< : String relational
                    fdb       BlcmpNE-VarCopyBase         <> or >< : Boolean relational
                    fdb       INCMGE-VarCopyBase         = : Integer/Byte relational
                    fdb       RLCMGE-VarCopyBase         = : Real relational
                    fdb       STCMNE-VarCopyBase         = : String relational
                    fdb       BLCMEQ-VarCopyBase         = : Boolean relational
                    fdb       INCMGT-VarCopyBase         >= or => : Integer/Byte relational
                    fdb       RLCMGT-VarCopyBase         >= or => : Real relational
                    fdb       STCMGT-VarCopyBase         >= or => : String Relational
                    fdb       INCMNE-VarCopyBase         <= or =< : Integer/Byte relational
                    fdb       RLCMNE-VarCopyBase         <= or =< : Real relational
                    fdb       STCMEQ-VarCopyBase         <= or =< : String Relational
                    fdb       IntAdd-VarCopyBase         Integer - Add
                    fdb       RealAdd-VarCopyBase         Real - Add
                    fdb       StrConcatBody-VarCopyBase         String add
                    fdb       INSUB-VarCopyBase         Integer - Subtract
                    fdb       RealSubtract-VarCopyBase         Real - Subtract
                    fdb       INMUL-VarCopyBase         Integer - Multiply
                    fdb       RealMulEntry-VarCopyBase         Real Multiply
                    fdb       INDIV-VarCopyBase         Integer - Divide
                    fdb       RealDivEntry-VarCopyBase         Real Divide
                    fdb       RLEXP-VarCopyBase         Real Exponent\ Probably for both ^ & **
                    fdb       RLEXP-VarCopyBase         Real Exponent/ Hard coding for 0^x & x^1
                    fdb       VARADD-VarCopyBase         DIM
                    fdb       VARADD-VarCopyBase         DIM
                    fdb       VARADD-VarCopyBase         DIM
                    fdb       VARADD-VarCopyBase         DIM
                    fdb       FLDREF-VarCopyBase         PARAM
                    fdb       FLDREF-VarCopyBase         PARAM
                    fdb       FLDREF-VarCopyBase         PARAM
                    fdb       FLDREF-VarCopyBase         PARAM
                    fdb       $0000               Unused function entries (maybe use for LONGINT?)
                    fdb       $0000
                    fdb       $0000
                    fdb       $0000
                    fdb       $0000
                    fdb       $0000

* Jump table (base is VarCopyBase)
VarCopyBase               fdb       SVBYTE-VarCopyBase         Copy BYTE var to temp pool
                    fdb       SVINT-VarCopyBase         Copy INTEGER var to temp pool
                    fdb       CopyRealVar-VarCopyBase         Copy REAL var to temp pool
                    fdb       BoolCopy-VarCopyBase         Copy BOOLEAN var to temp pool
                    fdb       SVSTR-VarCopyBase         Copy STRING var to temp pool (max 256 chars)
                    fdb       GETVAR-VarCopyBase         Copy DIM array
                    fdb       GETVAR-VarCopyBase         Copy DIM array
                    fdb       GETVAR-VarCopyBase         Copy DIM array
                    fdb       GETVAR-VarCopyBase         Copy DIM array
                    fdb       GETFLD-VarCopyBase         Copy PARAM array
                    fdb       GETFLD-VarCopyBase         Copy PARAM array
                    fdb       GETFLD-VarCopyBase         Copy PARAM array
                    fdb       GETFLD-VarCopyBase         Copy PARAM array
                    fdb       BYTLIT-VarCopyBase         Copy BYTE constant to temp pool - CHECK IF USED
                    fdb       INTLIT-VarCopyBase         Copy INTEGER constant to temp pool
                    fdb       CopyRealConst-VarCopyBase         Copy REAL constant to temp pool
                    fdb       STRLIT-VarCopyBase         Copy STRING constant to temp pool
                    fdb       INTLIT-VarCopyBase         Copy INTEGER constant to temp pool
                    fdb       ADRFNC-VarCopyBase         ADDR
                    fdb       ADRFNC-VarCopyBase         ADDR
                    fdb       SizeFnc-VarCopyBase         SIZE
                    fdb       SizeFnc-VarCopyBase         SIZE
                    fdb       POSFNC-VarCopyBase         POS
                    fdb       ErrFuncImpl-VarCopyBase         ERR
                    fdb       INDV10-VarCopyBase         MOD for Integer #'s
                    fdb       MODFNR-VarCopyBase         MOD for Real #'s
                    fdb       RNDFNC-VarCopyBase         RND
                    fdb       CopyPiToStack-VarCopyBase         PI
                    fdb       SUBFNC-VarCopyBase         SUBSTR
                    fdb       SGNFNI-VarCopyBase         SGN for Integer
                    fdb       SGNFNR-VarCopyBase         SGN for Real
                    fdb       SINFNC-VarCopyBase         Transcendental ???
                    fdb       COSFNC-VarCopyBase         Transcendental ???
                    fdb       TANFNC-VarCopyBase         Transcendental ???
                    fdb       ASNFNC-VarCopyBase         Transcendental ???
                    fdb       ACSFNC-VarCopyBase         Transcendental ???
                    fdb       ATNFNC-VarCopyBase         Transcendental ???
                    fdb       EXPFNC-VarCopyBase         EXP
                    fdb       AbsInt-VarCopyBase         ABS for Integer #'s
                    fdb       ABSFNR-VarCopyBase         ABS for Real #'s
                    fdb       LnFnc-VarCopyBase         LOG
                    fdb       Log10Fnc-VarCopyBase         LOG10
                    fdb       SQRR05-VarCopyBase         SQR \ Square root
                    fdb       SQRR05-VarCopyBase         SQRT/
                    fdb       FLOAT-VarCopyBase         FLOAT
                    fdb       INTFNR-VarCopyBase         INT (of real #)
                    fdb       RETBYT99-VarCopyBase         ??? RTS
                    fdb       FIX-VarCopyBase         FIX
                    fdb       FLOAT-VarCopyBase         FLOAT
                    fdb       RETBYT99-VarCopyBase         ??? RTS
                    fdb       SQFNCI-VarCopyBase         SQuare of integer
                    fdb       SqRealImpl-VarCopyBase         SQuare of real
                    fdb       PEKFNC-VarCopyBase         PEEK
                    fdb       NOTFNC-VarCopyBase         LNOT of Integer
                    fdb       ValFnc-VarCopyBase         VAL
                    fdb       LenFnc-VarCopyBase         LEN
                    fdb       ASCFNC-VarCopyBase         ASC
                    fdb       ANDFNC-VarCopyBase         LAND of Integer
                    fdb       LorFnc-VarCopyBase         LOR of Integer
                    fdb       ORFNC-VarCopyBase         LXOR of Integer
                    fdb       BoolTrueImpl-VarCopyBase         Force Boolean to TRUE
                    fdb       BoolFalseImpl-VarCopyBase         Force Boolean to FALSE
                    fdb       EOFFNC-VarCopyBase         EOF
                    fdb       TRMFNC-VarCopyBase         TRIM$

* Jump table, base is ExprJmpBase
ExprJmpBase               fdb       BYTVAR-ExprJmpBase         Convert Byte to Int (into temp var)
                    fdb       SQRR20-ExprJmpBase         Copy Int var into temp var
                    fdb       CopyRealToTemp-ExprJmpBase         Copy Real var into temp var
                    fdb       RETBYT10-ExprJmpBase         ??? Copy Boolean into temp var
                    fdb       STRVAR-ExprJmpBase         ??? Copy string to expression stack
                    fdb       RCDVAR-ExprJmpBase         ??? Copy D&U regs into temp var type 5

EVAL               ldy       <SubrStkPtr
                    ldd       <ICodeEndPtr        Init string stack ptr
                    std       <StrStkPtr
                    bra       EVAL20

EvalDispatch               lslb                          2 bytes per entry
                    ldu       <JmpTbl1              Get ptr to jump table (could be VarCopyBase)
                    ldd       b,u                 Get offset
                    jsr       d,u                 Call subroutine
EVAL20               ldb       ,x+                 Get next byte
                    bmi       EvalDispatch               If high bit set, need to call another subroutine
                    clra                          Otherwise, clear carry
                    lda       ,y            Get tos TYPE
                    rts

* Copy DIM array to temp var pool
GETVAR               bsr       VarRefSetup

* POSSIBLE MAIN ENTRY POINT FOR MATH & STRING ROUTINES
ExprDispatch               pshs      pc,u                Save U & PC on stack
                    ldu       <JmpTbl2              Get ptr to jump table (ExprJmpBase)
                    lsla                          A=A*2 for 2 byte entries (note: 8 bit SIGNED)
                    ldd       a,u                 Get offset
                    leau      d,u                 Point to routine
                    stu       2,s                 Save over PC on stack
                    puls      pc,u                Restore U & jump to routine

* Copy PARAM array to temp var pool
GETFLD               bsr       FldRefSetup
                    bra       ExprDispatch

VARADD               leas      2,s
                    lda       #$F2          Set TOKEN for variable
                    bra       VarRefCommon

FLDREF               leas      $02,s
                    lda       #$F6
                    bra       FLDR01

FldRefSetup               lda       #$89
FLDR01               sta       <CmdToken
                    clr       <FldAddrFlag        Set flag for field addr
                    bra       VARR02         Call varref

VarRefSetup               lda       #$85
VarRefCommon               sta       <CmdToken
                    sta       <FldAddrFlag
VARR02               ldd       ,x++
                    addd      <ModSymTbl        Add base to offset
                    std       <SymbolPtr        Set symbol table ptr
                    ldu       <SymbolPtr        Get symbol table ptr
                    lda       ,u            Get TYPE byte
                    anda      #$E0          Get definition
                    sta       <VarDefByte        Set definition
                    eora      #$80          Get flag (0=param; non 0=var)
                    sta       <VarTypeFlag        Set flag
                    lda       ,u            Get TYPE byte
                    anda      #$07          Get TYPE
                    ldb       -$03,x        Get TOKEN
                    subb      <CmdToken        Less base gives subscript count
                    pshs      d             Save TYPE & subscript count
                    lda       ,u            Get TYPE byte
                    anda      #$18          Get SHAPE
                    lbeq      VarrSimpleVar         bra if simple
                    ldd       1,u           Get array description offset
                    addd      <SymTblSize        Add base to offset
                    tfr       d,u
                    ldd       ,u
* (orig: SQRR10)
                    std       <ParmPktOff        Save it
                    lda       1,s           Get subscript count
                    bne       VARR03         bra if count > 0
                    lda       #$05
                    sta       ,s            return TYPE
                    ldd       2,u           Get array total size
                    std       <MaxStrSize        Save it
                    clra
                    clrb                    zero indexing offset
                    bra       VARR11

VARR03               leay      -6,y                Make room for temp var
                    clra                          Force value to 0 (integer)
                    clrb                    partial result
                    std       1,y                 Save it
                    leau      4,u                 Bump U up
                    bra       VarrDimCalc

VARR04               ldd       ,u                  Get value from U
                    std       1,y                 Save in var space
                    lbsr      INMUL               Call Integer Multiply routine
VarrDimCalc               ldd       7,y
                    subd      <ArrayBase        Get subscript-base
                    cmpd      ,u++          in range?
                    blo       VARR5A
                    ldb       #$37                Subscript out of range error
                    jsr       <JmpVect4              Report it
                    fcb       $06

* Array subscript in range, process
VARR5A               addd      1,y
                    std       7,y           Move result to next-on-stack
                    dec       1,s           Count subscript
                    bne       VARR04         bra if more
* NOTE: IF FOLLOWING COMMENTS ARE ACCURATE, SHOULD USE LDA, DECA TRICK
* (orig: VARR14)
                    lda       ,s                  ??? Get variable type?
                    beq       VarrByteOff               If Byte, skip ahead
                    cmpa      #$02                Real?
                    blo       VarrIntOff               No, integer, skip ahead
                    beq       VARR09               Real, skip ahead
                    cmpa      #$04                String?
                    blo       VarrByteOff               No, boolean - treat same as Byte
                    ldd       ,u                  String - do this
                    std       <MaxStrSize
                    bra       VARR10

* BYTE or BOOLEAN
VarrByteOff               ldd       7,y                 Get offset to entry in array we want
                    bra       VarrFinalOff

* INTEGER
VarrIntOff               ldd       7,y                 Get offset to entry in array we want
                    lslb                          x2 since Integers are 2 bytes/entry
                    rola
VarrFinalOff               leay      $C,y
                    bra       VARR11

* REAL
VARR09               ldd       #5                  x5 since Real's are 5 bytes/entry
VARR10               std       1,y                 Save for Integer multiply routine
                    lbsr      INMUL               Go do Integer multiply
                    ldd       1,y                 Get offset to entry we want
                    leay      6,y                 Eat temp var.
VARR11               tst       <VarTypeFlag
                    bne       VARR13         ..No
                    pshs      d             Save element offset
                    ldd       <ParmPktOff        Get parameter packet offset
                    addd      <VarStorePtr        Add base to offset
                    cmpd      <ParmEndPtr        is it there?
                    bhs       CMPTRU
                    tfr       d,u           Copy parameter packet ptr
                    puls      d             Retrieve element offset
                    cmpd      2,u           Still in parameter bounds?
                    bhi       CMPTRU         ..No
* (orig: VARR12)
                    addd      ,u            Add array base ptr to element offset
                    bra       VARR17

VARR13               addd      <ParmPktOff
                    tst       <FldAddrFlag        field ref?
                    bne       VARR16         ..No
VarrAddOffset               addd      1,y
                    leay      6,y                 Eat temp var.
                    bra       VARR17

VarrSimpleVar               lda       ,s                  ??? Get var type
                    cmpa      #$04                Set CC - Is it string type?
                    ldd       1,u           Get symbol table entry
                    blo       VARR15               No, either numeric or boolean, skip ahead
* String or complex
                    addd      <SymTblSize        Add base to offset
                    tfr       d,u
                    ldd       2,u           Get record size
                    std       <MaxStrSize        Save it
                    ldd       ,u            Get record offset
VARR15               tst       <FldAddrFlag
                    beq       VarrAddOffset         bra if so
                    addd      <VarStorePtr        Add storage base to offset
                    tfr       d,u           Copy storage ptr
                    tst       <VarTypeFlag        parameter?
                    bne       VARR18         ..No
                    cmpd      <ParmEndPtr        Will it be longer than original?
                    bhs       CMPTRU         If so old str will do
                    ldd       <MaxStrSize        return addend
                    cmpd      2,u
                    blo       VAR15A
                    ldd       2,u
                    std       <MaxStrSize
VAR15A               ldu       ,u
                    bra       VARR18

VARR16               addd      <VarStorePtr
VARR17               tfr       d,u
VARR18               clra                    Carry
                    puls      pc,d

CMPTRU               ldb       #$38                Parameter error
                    jsr       <JmpVect4
                    fcb       $06

* Copy Byte constant to temp pool
BYTLIT               leau      ,x+
                    bra       BYTVAR

* Copy Byte variable to temp pool
SVBYTE               ldd       ,x++                Get offset to variable we want
                    addd      <VarStorePtr              Add to start of string pool address
                    tfr       d,u                 Move to indexable register
BYTVAR               ldb       ,u                  Get BYTE value
                    clra                          Force to integer type
                    leay      -6,y                Make room for new variable
                    std       1,y                 Save integer value
                    lda       #1                  Save type as integer & return
                    sta       ,y            set TYPE
                    rts

* Copy Integer constant to temp pool
INTLIT               leau      ,x++
                    bra       SQRR20

* Copy integer var into temp var
SVINT               ldd       ,x++                Get offset to var we want
                    addd      <VarStorePtr              Add to start of variable pool
                    tfr       d,u                 Point U to entry
SQRR20               ldd       ,u                  Get Integer
                    leay      -6,y                Make room for variable
                    std       1,y                 Save integer
                    lda       #1                  Integer Type
                    sta       ,y                  Save it & return
                    rts

* INTEGER NEGATE (- IN FRONT OF NUMBER)
                    ifne      H6309
NEGINT               clrd                          Number=0-Number (negate it)
                    else
***************
* Integer Negate
NEGINT               clra
                    clrb
                    endc
                    subd      1,y
                    std       1,y                 Save & return
                    rts

* INTEGER ADD
IntAdd               ldd       7,y                 Get integer
                    addd      1,y                 Add to temp copy of 2nd #
                    leay      6,y                 Eat temp
                    std       1,y                 Save added result & return
                    rts

* INTEGER SUBTRACT
INSUB               ldd       7,y                 Get integer
                    subd      1,y                 Subtract 2nd #
                    leay      6,y                 Eat temp copy
                    std       1,y                 Save result & return
                    rts

* INTEGER MULTIPLY
                    ifne      H6309
INMUL               ldd       1,y                 Get temp var integer
                    muld      7,y                 Multiply by answer integer
                    stw       7,y                 Save 16 bit wrapped result
                    leay      6,y                 Eat temp var
                    rts
                    else
INMUL               ldd       7,y                 Get value that result will go into
                    beq       InmlEatTmpVar               *0, leave result as 0
                    cmpd      #2                  Special case: times 2?
                    bne       InmlCheckB               No, check other number
                    ldd       1,y                 Get 2nd number
                    bra       InmlDoubleB               Do quick x2

InmlCheckB               ldd       1,y                 Get 2nd number
                    beq       INML20               *0, go save result as 0
                    cmpd      #2                  Special case: times 2?
                    bne       INML25               No, go do regular multiply
                    ldd       7,y                 Get 1st number
InmlDoubleB               lslb
                    rola
INML20               std       7,y                 Save answer
                    bra       InmlEatTmpVar               Eat temp var & return

INML25               lda       8,y                 Do 16x16 bit signed multiply, MOD 65536
                    mul                     Lsb * nos lsb
                    sta       3,y           Save partial msb
                    lda       8,y           Get binary byte
                    stb       8,y
                    ldb       1,y
                    mul                     Msb * nos lsb
                    addb      3,y           Add partial msb
                    lda       7,y           Get nos msb
                    stb       7,y
                    ldb       2,y
                    mul
***************
* 16 Bit Shift
* (orig: FPDV47)
                    addb      7,y           Add result msb
                    stb       7,y           Save result msb
InmlEatTmpVar               leay      6,y                 Eat temp var & return
                    rts
                    endc
* Integer MOD routine
INDV10               bsr       INDIV               Go do integer divide
                    ldd       3,y                 Get "hidden" remainder
                    std       1,y                 Save as answer & return
                    rts

                    ifne      H6309
INDIV               ldd       1,y                 Get # to divide by
                    bne       GoodDiv             <>0, go do divide
                    ldb       #$2D                =0, Divide by 0 error
                    jsr       <JmpVect4              Report error
                    fcb       $06

GoodDiv             ldw       7,y                 Get 16 bit signed dividend
                    sexw                          Sign-Extend W into Q
Positive            divq      1,y                 Do 32/16 bit signed division
                    tstw                          Answer positive?
                    ble       CheckD              If <=0, skip ahead
MustPos             tsta                          Is remainder positive?
                    bmi       NegRem              No, have to fix sign on remainder
SaveRem             std       9,y                 Save remainder for MOD
                    stw       7,y                 Save answer for /
                    leay      6,y                 Eat temp var & return
                    rts

* Negative answer comes here
CheckD              beq       CheckZ              If answer is zero, need special stuff for remainder
CheckD1             tsta                          Is remainder negative?
                    bmi       SaveRem             Yes, save remainder
NegRem              negd                          Otherwise, negate remainder
                    bra       SaveRem             Now save it & return

* Zero answer comes here - W is zero, so we can use it's parts
CheckZ              lde       7,y                 Get MSB of dividend
                    bpl       CheckZ1             Positive, don't change negative flag
                    incf                          Negative, bump flag up
CheckZ1             lde       1,y                 Get MSB of divisor
                    bpl       CheckZ2             If positive, leave flag alone
                    incf                          Negative, bump up flag
CheckZ2             cmpf      #1                  If 1, then remainder must be negative
                    beq       CheckZ3             It is negative, go deal with it
                    clrw                          Zero out answer again
                    bra       MustPos

CheckZ3             clrw                          Clear out answer to 0 again
                    bra       CheckD1             Go deal with sign of remainder

                    else
* Calculate sign of result of Integer Divide (,y - 0=positive, FF=negative)
SETSGN               clr       ,y                  Clear flag (positive result)
                    ldd       7,y                 Get #
                    bpl       SetSgnCheck2               If positive or 0, go check other #
                    nega                          Force it to positive (NEGD)
                    negb
                    sbca      #$00
                    std       7,y                 Save positive version
                    com       ,y                  Set flag for negative result
SetSgnCheck2               ldd       1,y                 Get other #
                    bpl       SETSG2               If positive or 0, go check if it is a 2
                    nega                          Force it to positive (NEGD)
                    negb
                    sbca      #$00
                    std       1,y                 Save positive version
                    com       ,y                  Flip negative/positive result flag
SETSG2               cmpd      #2                  Check if dividing by 2
                    rts

* INTEGER DIVIDE
INDIV               bsr       SETSGN               Go force both numbers to positive, check for /2
                    bne       IntDivNonZero               Normal divide, skip ahead
                    ldd       7,y                 Get # to divide by 2
                    beq       INDV20               If 0, result is 0, so skip divide
                    asra                    by shift
                    rorb
                    std       7,y                 Save result
* (orig: INDV15)
                    ldd       #$0000              Remainder=0 (No CLRD since it fries carry)
                    rolb                          Rotate possible remainder bit into D
                    bra       INDV55               Go save remainder, fix sign & return

IntDivNonZero               ldd       1,y                 Get divisor (integer)
                    bne       IntDivCheckDiv               <>0, skip ahead
                    ldb       #$2D                =0, Divide by 0 error
                    jsr       <JmpVect4              Report error
                    fcb       $06

IntDivCheckDiv               ldd       7,y                 Get dividend (integer)
                    bne       INDV25               Have to do divide, skip ahead
INDV20               leay      6,y                 ??? Eat temp var? (divisor)
                    std       3,y                 Save result
                    rts

* INTEGER DIVIDE MAIN ROUTINE
* 7-8,y = Dividend (already checked for 0)
* 1-2,y = Divisor (already checked for 0)
* 3,y   = # of powers of 2 shifts to do
INDV25               tsta                          Dividend>256?
                    bne       IntDiv16Bit               Yes, skip ahead
                    exg       a,b                 Swap LSB/MSB of dividend
                    std       7,y                 Save it
* (orig: INDV30)
                    ldb       #8                  # of powers of 2 shifts for 8 bit dividend
                    bra       INDV35

IntDiv16Bit               ldb       #16                 # of powers of 2 shifts for 16 bit dividend
INDV35               stb       3,y                 Save # shifts required
                    clra
                    clrb                    D
* Main powers of 2 subtract loop for divide
IntDivMainLoop               lsl       8,y                 Multiply dividend by 2
                    rol       7,y           Into D
                    rolb                          Rotate into D
                    rola
                    subd      1,y                 Subtract that power of 2 from divisor
                    bmi       INDV45               If wraps, add it back in
                    inc       8,y           Set bit in quotient
                    bra       INDV50

INDV45               addd      1,y
INDV50               dec       3,y                 Dec # shift/subtracts left to do
                    bne       IntDivMainLoop               Still more, continue
INDV55               std       9,y                 Save remainder
                    tst       ,y                  Positive result?
                    bpl       INDV60               Yes, eat temp var & return
                    nega                          NEGD
                    negb
                    sbca      #$00
                    std       9,y                 Save negative remainder
                    ldd       7,y                 Get actual divide result
                    nega                          NEGD
                    negb
                    sbca      #$00
                    std       7,y                 Save signed result
INDV60               leay      6,y                 Eat temp var & return
                    rts
                    endc

* Copy REAL # from X (moving X to after real number) to temp var
CopyRealConst               leay      -6,y                Make room for temp var
                    ldb       ,x+                 Get hi-byte of real value
                    lda       #2                  Force var type to REAL
                    std       ,y                  Save in temp var
                    ifne      H6309
                    ldq       ,x                  Copy mantissa to temp var
                    stq       2,y
                    ldb       #4                  Bump X up to past end of var
                    abx
                    else
                    ldd       ,x++                Copy rest of real # to temp var & return
                    std       2,y
* (orig: SVREAL)
                    ldd       ,x++
                    std       4,y
                    endc
                    rts

* Copy REAL # from variable pool (pointed to by X) into temp var
CopyRealVar               ldd       ,x++                Get offset into var space for REAL var
                    addd      <VarStorePtr              ??? Add to base address for variable storage?
                    tfr       d,u                 Move ptr to U
* Copy REAL # constant from within BASIC09 (pointed to by U) into temp var
CopyRealToTemp               leay      -6,y                Make room for temp var
                    lda       #2                  Set 1st byte to be 2
                    ldb       ,u                  Get 1st byte of real #
                    std       ,y
                    ifne      H6309
                    ldq       1,u                 Get mantissa for real #
                    stq       2,y                 Save in temp var
                    else
* (orig: RADD10)
                    ldd       1,u                 Get bytes 2&3 of real #
                    std       2,y
                    ldd       3,u                 Get bytes 4&5 of real #
                    std       4,y
                    endc
                    rts                           Return

* Negate for REAL #'s
                    ifne      H6309
NEGRL               eim       #1,5,y              Negate sign bit of REAL #
                    else
NEGRL               lda       5,y                 Get LSB of mantissa & sign bit
                    eora      #$01                Reverse the sign bit
                    sta       5,y                 Save it back
                    endc
                    rts                           return

* Subtract for REAL #'s
                    ifne      H6309
RealSubtract               eim       #1,5,y              Negate sign bit of real #
                    else
RealSubtract               ldb       5,y                 Reverse sign bit on REAL #
                    eorb      #1            Get difference with multiplier
                    stb       5,y
                    endc

                    ifne      H6309
                    use       basic09.real.add.63.asm
                    else
                    use       basic09.real.add.68.asm
                    endc

* REAL Multiply?
RealMulEntry               bsr       RealMul               Go do REAL multiply
                    bcs       ReportMathErr               If error, report it
                    rts                           Return without error

ReportMathErr               jsr       <JmpVect4              Report error
                    fcb       $06

                    ifne      H6309
                    use       basic09.real.mul.63.asm
                    else
                    use       basic09.real.mul.68.asm
                    endc

* Real divide entry point?
RealDivEntry               bsr       RealDiv
                    bcs       LErr
RealDivRts               rts

LErr                jsr       <JmpVect4
                    fcb       $06

                    ifne      H6309
                    use       basic09.real.div.63.asm
                    else
                    use       basic09.real.div.68.asm
                    endc

* Real exponent
RLEXP               pshs      x                   Preserve X
                    ldd       7,y                 Is the number to be raised 0?
                    beq       RdivShiftDone               Yes, eat temp & return with 0 as result
                    ldx       1,y                 Is the exponent 0?
                    bne       REXP20               No, go do normal exponent calculation
                    leay      6,y                 Eat temp var
REXP10               ldd       #$0180              Save 1 in Real # format (all #'s to the power of
                    std       1,y                 0 result in 1, except 0 itself, which was trapped
* Possible 6809/6309 Mod: deca/sta 3,y/sta 4,y/sta 5,y (1 byte longer/5 cyc
* faster)
                    clr       3,y                 above)
                    clr       4,y
                    clr       5,y
                    puls      pc,x

REXP20               std       1,y
                    stx       7,y
                    ldd       9,y
                    ldx       3,y
                    std       3,y
                    stx       9,y           Set it
                    lda       $B,y
                    ldb       5,y           Set iteration count
                    sta       5,y           insert string terminator
                    stb       $B,y
                    puls      x             Restore x
                    lbsr      LnFnc         Get log(x)
                    lbsr      RealMulEntry               Go do real multiply
                    lbra      EXPFNC         Get exp(log(x)*y)

* Copy Boolean value into temp var
BoolCopy               ldd       ,x++                Get offset to var from beginning of var pool
                    addd      <VarStorePtr              Add to base address for vars
                    tfr       d,u                 Move to index reg
RETBYT10               ldb       ,u                  Get boolean value
                    clra                          Make into Integer type
                    leay      -6,y                Make room for temp var
                    std       1,y                 Save boolean value
                    lda       #3                  Type = BOOLEAN
                    sta       ,y
                    rts

BLAND               ldb       8,y                 Single byte LAND
                    andb      2,y           Clear sign bit
                    bra       BLXOR10

BLXOR               ldb       8,y                 Single byte LOR
                    orb       2,y           or first
                    bra       BLXOR10

BlxorOp               ldb       8,y                 Single byte LXOR
                    eorb      2,y           Get difference with dividend
BLXOR10               leay      6,y                 Eat temp var
                    std       1,y                 Save result in original var & return
                    rts

BLNOT               com       2,y                 Single byte LNOT
                    rts

* Main search loop for String comparison operators
STRCMP               pshs      y,x
                    ldx       1,y                 Get ptr to temp string?
                    ldy       7,y                 Get ptr to var string?
                    sty       <StrStkPtr        Update str stack ptr
STRCM1               lda       ,y+                 Get char from temp string
                    cmpa      ,x+                 Same as char from var string?
                    bne       StrcmpNext               No, skip ahead
                    cmpa      #$FF                EOS marker?
                    bne       STRCM1               No, keep comparing
StrcmpNext               inca                          Inc last char checked
                    inc       -1,x                Inc last char in compare string
                    cmpa      -1,x                Same as last char checked with inc????
                    puls      pc,y,x        return CC=result

* String compare: < (?)
***************
* String Compare =<
STCMLE               bsr       STRCMP               Go do string compare
                    blo       BoolTrue               If less than, result=TRUE
                    bra       BoolFalse               Else, result=False

* String compare: <= or =< (?)
***************
* String Compare =
STCMEQ               bsr       STRCMP
                    bls       BoolTrue
                    bra       BoolFalse

* String compare: =
***************
* String Compare <>
STCMNE               bsr       STRCMP
                    beq       BoolTrue
                    bra       BoolFalse

* String compare: <> or ><
StrcmpNE               bsr       STRCMP
                    bne       BoolTrue
                    bra       BoolFalse

* String compare: >= or => (?)
***************
* String Compare >
STCMGT               bsr       STRCMP
                    bhs       BoolTrue
                    bra       BoolFalse

* String compare: > (?)
StrcmpGT               bsr       STRCMP
                    bhi       BoolTrue
                    bra       BoolFalse

* For Integer/Byte compares below: Works for signed Integer as well
*  as unsigned Byte
* Integer/Byte compare: <
INCMLT               ldd       7,y
                    subd      1,y                 NOTE: SUBD is faster than CMPD
                    blt       BoolTrue         if less than go push true
                    bra       BoolFalse         Go push false

* Integer/Byte compare: <= or =<
INCMNE               ldd       7,y
                    subd      1,y
                    ble       BoolTrue         if less or equal go push true
                    bra       BoolFalse         Go push false

* Integer/Byte compare: <> or ><
INCMEQ               ldd       7,y
                    subd      1,y           Take borrow
                    bne       BoolTrue         if not equal go push true
                    bra       BoolFalse         Go push false

* Integer/Byte compare: =
INCMGE               ldd       7,y
                    subd      1,y           Subtract divisor msdb
                    beq       BoolTrue         bra if possibly done
                    bra       BoolFalse         Go push false

* Integer/Byte compare: >= or =>
INCMGT               ldd       7,y
                    subd      1,y           Subtract right operand
                    bge       BoolTrue         if greater or equal go push true
                    bra       BoolFalse         Go push false

* Integer/Byte compare: >
IntGT               ldd       7,y                 Get original var
                    subd      1,y                 > than compare var?
                    ble       BoolFalse               No, boolean result=FALSE
BoolTrue               ldb       #$FF                Boolean result=TRUE
                    bra       BoolSaveResult

BoolFalse               clrb                          Boolean result=FALSE
BoolSaveResult               clra                          Clear hi byte (since result is 1 byte boolean)
                    leay      6,y                 Eat temp var packet
                    std       1,y                 Save result in original var packet
                    lda       #3                  Save var type as Boolean
                    sta       ,y
                    rts

* BOOLEAN = compare
BLCMEQ               ldb       8,y                 Get original BOOLEAN value
                    cmpb      2,y                 Same as comparitive BOOLEAN value?
                    beq       BoolTrue               Yes, result=TRUE
                    bra       BoolFalse               No, result=FALSE

* BOOLEAN <> or >< compare
BlcmpNE               ldb       8,y                 Get original BOOLEAN value
                    cmpb      2,y                 Same as comparitive BOOLEAN value?
                    bne       BoolTrue               No, result=TRUE
                    bra       BoolFalse               Yes, result=FALSE

* Real < compare
RLCMLT               bsr       RLCMP               Go compute flags between real #'s
                    blt       BoolTrue               If < then, result=TRUE
                    bra       BoolFalse               Otherwise, result=FALSE

* Real <= or =< compare
RLCMNE               bsr       RLCMP
                    ble       BoolTrue
                    bra       BoolFalse

* Real <> or >< compare
RLCMEQ               bsr       RLCMP
                    bne       BoolTrue
                    bra       BoolFalse

* Real = compare
RLCMGE               bsr       RLCMP
                    beq       BoolTrue
                    bra       BoolFalse

* Real >= or => compare
RLCMGT               bsr       RLCMP
                    bge       BoolTrue
                    bra       BoolFalse

* Real > compare
RlcmpGT               bsr       RLCMP
                    bgt       BoolTrue
                    bra       BoolFalse

* Set flags for Real comparison
RLCMP               pshs      y                   Preserve Y
                    andcc     #$F0                Clear out Negative, Zero, Overflow & Carry bits
                    lda       8,y                 Is original REAL var=0?
                    bne       RLCM50               No, skip ahead
* (orig: RLCM40)
                    lda       2,y                 Is comparitive REAL var=0?
                    beq       RLCM30               Yes, they are equal so return
RlcmpGetSign               lda       5,y                 Get last byte of Mantissa with sign bit
RLCM15               anda      #$01                Ditch everything but sign bit
                    bne       RLCM30               Sign bit set, negative value, return
RLCM20               andcc     #$F0                Clear out Negative, Zero, Overflow & carry bits
                    orcc      #%00001000          Set Negative flag
RLCM30               puls      pc,y

RLCM50               lda       2,y                 Is comparitive REAL var=0?
                    bne       RlcmpBothNonZero               No, go deal with whole exponent/mantissa mess
                    lda       $B,y                Get sign bit of original var
                    eora      #$01                Invert sign flag
                    bra       RLCM15               Go set Negative bit appropriately

* No zero values in REAL compare-deal with exponent & mantissa
RlcmpBothNonZero               lda       $B,y                Get sign bit byte from original var
                    eora      5,y                 Calculate resulting sign from it with temp var
                    anda      #$01                Only keep sign bit
                    bne       RlcmpGetSign               One of the #'s is neg, other pos, go deal with it
                    leau      6,y                 Both same sign, point U to original var
                    lda       5,y                 Get sign byte from temp var
                    anda      #$01                Just keep sign bit
                    beq       RlcmpCompareMag               If positive, skip ahead
                    exg       u,y                 If negative, swap ptrs to the 2 vars
* POSSIBLE 6309 MOD: DO LDA 1,U / CMPA 1,Y FOR EXPONENT, THEN LDQ / CMPD /
* CMPW FOR MANTISSA
RlcmpCompareMag               ldd       1,u                 Get exponent & 1st mantissa bytes
                    cmpd      1,y                 Compare
                    bne       RLCM30               Not equal, exit with appropriate flags set
                    ldd       3,u                 Match so far, compare 2nd & 3rd mantissa bytes
                    cmpd      3,y           Compare
                    bne       RLCM70               Not equal, exit with flags
                    lda       5,u                 Compare last byte of mantissa
                    cmpa      5,y
                    beq       RLCM30               2 #'s are equal, exit
RLCM70               blo       RLCM20               If below, set negative flag & exit
                    andcc     #$F0                Clear negative, zero, overflow & carry bits
                    puls      pc,y                Restore Y & return

*??? Copy string var of some sort <=256 chars max
STRLIT               clrb                          Max size of string copy=256
                    stb       <MaxStrSize              Save it
STRCAT               ldu       <StrStkPtr              Get ptr to string of some sort
                    leay      -6,y                Make room for temp var
                    stu       1,y                 Save ptr to it
                    sty       <StrSpaceTop              Save temp var ptr
MIDFN4               cmpu      <StrSpaceTop              At end of string stack yet?
                    bhs       StrStkOverflow               Yes, exit with String stack overflow error
                    lda       ,x+                 Get char from string
                    sta       ,u+                 Save it
                    cmpa      #$FF                EOS?
                    beq       STLIT3               Yes, finished copying
                    decb                          Dec size left
                    bne       MIDFN4               Still room, keep copying
                    dec       <MaxStrSize              ???
                    bpl       MIDFN4               Still good, keep copying
                    lda       #$FF                Append string terminator
                    sta       ,u+           Put in string stack
STLIT3               stu       <StrStkPtr              Save end of string stack ptr
                    lda       #4                  Force var type to string
                    sta       ,y
                    rts

StrStkOverflow               ldb       #$2F                String stack overflow
                    jsr       <JmpVect4
                    fcb       $06

SVSTR               ldd       ,x++
                    addd      <SymTblSize
                    tfr       d,u           Make direct page ptr
SvstrGetOff               ldd       ,u
                    addd      <VarStorePtr        Add procedure storage addr
                    ldu       2,u           Get size
                    stu       <MaxStrSize
                    tfr       d,u
STRVAR               pshs      x
                    ldb       <UnusedByte3F
                    bne       STRVAR10
                    dec       <MaxStrSize
STRVAR10               leax      ,u
                    bsr       STRCAT         push string
                    puls      pc,x

StrConcatBody               ldu       1,y                 Get ptr to string contents
                    leay      6,y                 Eat temp var
STCAT2               lda       ,u+                 Get char from temp var
                    sta       -2,u                Save 1 byte back from original spot
                    cmpa      #$FF                EOS?
                    bne       STCAT2               No, keep copying until EOS is hit
                    leau      -1,u                Point U back to EOS
                    stu       <StrStkPtr              Save string stack ptr & return
                    rts

RCDVAR               ldd       <MaxStrSize
                    leay      -6,y                Make room for temp var
                    std       3,y                 ???
                    stu       1,y                 ???
                    lda       #5                  Var type =5???
                    sta       ,y
                    rts

FLOAT               clra                          Force least 2 sig bytes to 0 (and sign to positive)
                    clrb
                    std       4,y           Clr lsdb mantissa
                    ldd       1,y                 Get Exponent & 1st byte of mantissa
                    bne       FLOAT1               Not 0, skip ahead
                    stb       3,y                 Save 0 int 2nd byte of mantissa
                    lda       #2                  Var type=Real
                    sta       ,y            Put on stack
                    rts

FLOAT1               ldu       #$0210              ??? (528)
                    tsta                          Exponent negative?
                    bpl       FloatExpPos               No, positive (big number), skip ahead
                    ifne      H6309
                    negd
                    else
                    nega                    Positive
                    negb
                    sbca      #$00
                    endc
                    inc       5,y           Adjust exponent
* (orig: FLOAT2)
                    tsta                          Check exponent again
FloatExpPos               bne       FloatCheckNorm               Exponent <>0, skip ahead
                    ldu       #$0208              ??? If exponent=0, 522
                    exg       a,b           Msb to D
FloatCheckNorm               tsta                    Result normalized?
                    bmi       FLOAT5         bra if no
FloatNormLoop               leau      -1,u                Drop down U counter
                    lslb                          LSLD
                    rola
                    bpl       FloatNormLoop               Do until hi bit is set
FLOAT5               std       2,y
                    stu       ,y            Save TYPE & exponent
                    rts

FLTNEX               leay      6,y                 Eat temp var
                    bsr       FLOAT               ??? Something with reals
                    leay      -6,y                Make room for temp var & return
                    rts

FIX               ldb       1,y                 Get exponent
                    bgt       FIX1               If exponent >0, skip ahead
                    bmi       FIXZER               If exponent <0, skip ahead
                    lda       2,y                 Exponent=0, get 1st byte of mantissa
                    bpl       FIXZER               If high bit not set, integer result=0
                    ldd       #$0001              High bit set, Integer result=1
                    bra       FIX4A               Go adjust sign if necessary

FIXZER               clra                          Integer result=0
                    clrb
                    bra       FIX5               Save integer & return

FIX1               subb      #$10                Subtract 16 from exponent
                    bhi       FixRangeErr         bra if too large
                    bne       FIX2         bra if in range
                    ldd       2,y           get value
                    ror       5,y           check sign
                    bcc       FIX5         bra if positive
                    cmpd      #$8000        -32768?
                    bne       FixRangeErr         ..No
                    tst       4,y           would it round out?
                    bpl       FIX5         ..No
                    bra       FixRangeErr

FIX2               cmpb      #$F8
                    bhi       FIX3         ..No
                    pshs      b             Save exp
                    ldd       2,y           Shift Mant 1 Byte Right
                    std       3,y
                    clr       2,y
                    puls      b
                    addb      #$08          Bump exp by a byte worth
                    beq       FIX4         if exp=0 skip bit shift
FIX3               lsr       2,y
                    ror       3,y
                    ror       4,y
                    incb                    Exp
                    bne       FIX3         Loop if not yet norm
FIX4               ldd       2,y
                    tst       4,y           Check remainder
                    bpl       FIX4A         if <.5 dont round
                    addd      #$0001        Round up
                    bvc       FIX4A         bra if no overfl
FixRangeErr               ldb       #$34                Value out of Range for Destination error
                    jsr       <JmpVect4
                    fcb       $06

FIX4A               ror       5,y                 Get sign bit of converted real #
                    bcc       FIX5               Positive, leave integer result alone
                    ifne      H6309
                    negd                          Reverse sign of integer
                    else
                    nega                    negative
                    negb
                    sbca      #$00
                    endc
FIX5               std       1,y                 Save integer result
                    lda       #1                  Force type to integer & return
                    sta       ,y
                    rts

FIXNEX               leay      6,y
                    bsr       FIX
                    leay      -6,y
                    rts

FixEat2Vars               leay      $C,y                Eat 2 temp vars
                    bsr       FIX
                    leay      -$C,y               Make room for 2 temp vars & return
                    rts

* ABS for Real #'s
                    ifne      H6309
ABSFNR               aim       #$fe,5,y            Force sign of real # to positive
                    else
***************
* ABS - TYPE Real
ABSFNR               lda       5,y                 Get sign bit for Real #
                    anda      #$FE                Force to positive
                    sta       5,y                 Save sign bit back & return
                    rts
                    endc

* ABS for Integer's
AbsInt               ldd       1,y                 Get integer
                    bpl       ABSIN2               If positive already, exit
                    ifne      H6309
                    negd                          Force to positive
                    else
                    nega                          NEGD (force to positive)
                    negb
                    sbca      #$00
                    endc
                    std       1,y                 Save positive value back
ABSIN2               rts

PEKFNC               clra
                    ldb       [<1,y]
                    std       1,y
                    rts

***************
* SGN - TYPE Real
SGNFNR               lda       2,y
                    beq       SGNZER         Test - TYPE zero
                    lda       5,y                 Get sign byte
                    anda      #$01                Just keep sign bit
                    bne       SGNMIN               Negative #, skip ahead
SGNPLS               ldb       #$01
                    bra       RETINT

***************
* SGN For Integer
SGNFNI               ldd       $01,y
                    bmi       SGNMIN
                    bne       SGNPLS
SGNZER               clrb
                    bra       RETINT

SGNMIN               ldb       #$FF
RETINT               sex                     Prime msb
                    bra       SaveIntResult

ErrFuncImpl               ldb       <ErrCode
                    clr       <ErrCode
ByteIntResult               clra                    Byte Result
                    leay      -6,y                Make room for temp var
SaveIntResult               std       1,y                 Save value
                    lda       #1                  Force type to integer & return
                    sta       ,y
RETBYT99               rts

POSFNC               ldb       <TmpBufCount
                    bra       ByteIntResult

SQRR05               ldb       $05,y
                    asrb                    Sign to carry
                    lbcs      IllegalArgErr
                    ldb       #$1F          Set cycle count
                    stb       <SqrtCycleCount
                    ldd       $01,y         Get exponent & msb
                    beq       RETBYT99         return zero
                    inca                    Exponent for even/odd test
                    asra
                    sta       $01,y         Save it
                    ldd       $02,y         Get msb
                    bcs       SqrtBoolExponent         bra if boolean
                    lsra                    Mantissa for odd exponent
                    rorb
                    std       -$04,y
                    ldd       $04,y
                    rora                    Lsdb
                    rorb
                    bra       SqrtMainCalc

SqrtBoolExponent               std       -$04,y
                    ldd       $04,y         Set x coordinate to 1
SqrtMainCalc               std       -$02,y
                    clra                    Result
                    clrb
                    std       $02,y
                    std       $04,y
                    std       -$06,y
                    std       -$08,y
                    bra       SQRR30         Jump into loop

SQRR25               orcc      #$01
                    rol       $05,y
                    rol       $04,y
                    rol       $03,y
                    rol       $02,y
                    dec       <SqrtCycleCount
                    beq       SqrtFinalShift
                    bsr       SqrtDoubleShift         Call double shifter
SQRR30               ldb       -$04,y
                    subb      #$40
                    stb       -$04,y
                    ldd       -$06,y        Get next lsb
                    sbcb      $05,y         Subtract result
                    sbca      $04,y
                    std       -$06,y
                    ldd       -$08,y        Get msb
                    sbcb      $03,y         Subtract more result
                    sbca      $02,y
                    std       -$08,y
                    bpl       SQRR25         bra if successful subtract
SQRR35               andcc     #$FE
                    rol       $05,y
                    rol       $04,y
                    rol       $03,y
                    rol       $02,y
                    dec       <SqrtCycleCount
                    beq       SqrtFinalShift
                    bsr       SqrtDoubleShift         Call double shifter
                    ldb       -$04,y        Get lsb effected
                    addb      #$C0
                    stb       -$04,y
                    ldd       -$06,y        Get next lsb
                    adcb      $05,y         Add result
                    adca      $04,y
                    std       -$06,y
* (orig: SQRR40)
                    ldd       -$08,y        Get msb
                    adcb      $03,y         add high two bytes
                    adca      $02,y
                    std       -$08,y
                    bmi       SQRR35         if normalized, exit
                    bra       SQRR25

SqrtFinalShift               ldd       $02,y
                    bra       SqrtShiftMain         Do last shift

SqrtShiftNorm               dec       $01,y
                    lbvs      RmulZeroResult
SqrtShiftMain               lsl       $05,y
                    rol       $04,y
                    rolb
                    rola
                    bpl       SqrtShiftNorm         bra if another shift
                    std       $02,y
                    rts

SqrtDoubleShift               bsr       SqrtSingleShift
SqrtSingleShift               lsl       -$01,y
                    rol       -$02,y
                    rol       -$03,y
                    rol       -$04,y
                    rol       -$05,y
                    rol       -$06,y
                    rol       -$07,y
                    rol       -$08,y
                    rts

* Real MOD routine (?)
MODFNR               leau      -12,y               Make room for 2 temp vars
                    pshs      y             Save opstack ptr
MODF10               ldd       ,y++
                    std       ,u++
                    cmpu      ,s            Copied enough?
                    bne       MODF10         ..No
                    leas      2,s           Dump count
                    leay      -12,u         Move opstack ptr to top of stack
                    lbsr      RealDivEntry         Get a/b
                    bsr       INTFNR         Get INT(a/b)
                    lbsr      RealMulEntry         Get b*INT(a/b)
                    lbra      RealSubtract         Get a-b*INT(a/b)

INTFNR               lda       1,y
                    bgt       INTF20         bra if arg>=1
                    clra                    Acc
                    clrb
                    std       1,y           return zero
                    std       3,y
                    stb       5,y
INTF10               rts

INTF20               cmpa      #$1F
                    bcc       INTF10         ..No
                    leau      $06,y         Get ptr to end+1 of arg
                    ldb       -1,u          Get sign byte
                    andb      #$01          Get sign
                    pshs      u,b           Save sign & end ptr
* (orig: INTF30)
                    leau      $01,y
IntfShiftLeft               leau      1,u
                    suba      #$08          Down count
                    bcc       IntfShiftLeft         bra if more to left of binary point
                    beq       INTF50         bra if exact
                    ldb       #$FF          Make mask for byte
IntfMakeMask               lslb
                    inca
                    bne       IntfMakeMask
                    andb      ,u            Get sign difference only
                    stb       ,u+
                    bra       INTF70

INTF50               leau      1,u
INTF60               sta       ,u+
INTF70               cmpu      $01,s
                    bne       INTF60         ..No
                    puls      u,b           Clean stack
                    orb       $05,y         Set sign
                    stb       $05,y
                    rts

SQFNCI               leay      -6,y
                    ldd       7,y           Get value
                    std       1,y           Copy it
                    lbra      INMUL         Go do multiply

SqRealImpl               leay      -6,y
                    ldd       $A,y
                    std       4,y
                    ldd       8,y
                    std       2,y
* (orig: VALFNC)
                    ldd       6,y
                    std       ,y
                    lbra      RealMulEntry         Go do multiply

ValFnc               ldd       <TmpBufBase
                    ldu       <TmpBufCur
                    pshs      u,d
                    ldd       1,y           Get ptr to string
* (orig: RADD90)
                    std       <TmpBufBase
                    std       <TmpBufCur
                    std       <StrStkPtr        Pop string off string stack
                    leay      6,y           Adjust opstack
                    ldb       #9            Set code for convert to real
                    lbsr      Vect6Fn2         Call conversion
                    puls      u,d
                    std       <TmpBufBase        Restore them
                    stu       <TmpBufCur
                    lbcs      IllegalArgErr         abort if error
                    rts

ADRFNC               lbsr      EVAL20
                    leay      -6,y                Make room for new variable packet
                    stu       1,y                 Save size of var
ADRF10               lda       #$01                ??? Integer type
                    sta       ,y                  ??? Save in variable packet
                    leax      1,x           Skip terminal TOKEN
                    rts

* Table to numeric variable type sizes in bytes? (duplicates earlier table @
*  VarSizeTable2)
* Can either leave table here, change leau below to 8 bit pc (faster/1 byte
*   shorter), or eliminate table and point to 3B5B table (4 bytes shorter/same
*   speed)
VarSizeTable3               fcb       $01                 Byte             (type=0)
                    fcb       $02                 Integer size     (type=1)
                    fcb       $05                 Real size        (type=2)
                    fcb       $01                 Boolean          (type=3)

SizeFnc               lbsr      EVAL20
                    leay      -6,y                ??? Size of variable packets?
                    cmpa      #4                  String/complex variable?
                    bhs       TRUFNC               Yes, skip ahead
                    leau      <VarSizeTable3,pc           Point to numeric type size table
                    ldb       a,u                 Get size of var in bytes
                    clra                          D=size  Msb
                    bra       SizeSaveResult               Go save it

TRUFNC               ldd       <MaxStrSize              ??? Get integer value
SizeSaveResult               std       1,y                 ??? Save integer value
                    bra       ADRF10

* BOOLEAN - TRUE
BoolTrueImpl               ldd       #$00FF              $FF in boolean is True flag
                    bra       FALFN2

BoolFalseImpl               ldd       #$0000              CLRD ($00 in boolean is False)
FALFN2               leay      -6,y                Make room for variable packet
                    std       1,y                 Save boolean flag value
                    lda       #3                  Save type as boolean (3)
                    sta       ,y            set TYPE
                    rts

NOTFNC               com       1,y                 Leave as LDD 1,y/COMD/STD 1,y is same speed
                    com       2,y           Complement lsb
                    rts

ANDFNC               ldd       1,y                 Get value to AND with out of integer var.
                    anda      7,y                 ANDD (with value in variable)
                    andb      8,y           clear sign
                    bra       LogicSaveResult

ORFNC               ldd       1,y
                    eora      7,y                 EORD
                    eorb      8,y
                    bra       LogicSaveResult         Save result + cleanup

LorFnc               ldd       1,y
                    ora       7,y                 ORD
                    orb       8,y
***************
* Save Result of Locical Function
LogicSaveResult               std       7,y                 Save result after logic applied
                    leay      6,y                 Eat temporary variable packet?
                    rts

Log10Const               fcb       $ff,$de,$5b,$d8,$aa ??? (.434294482)

Log10Fnc               bsr       LnFnc
                    leau      <Log10Const,pc           Point to ???
                    lbsr      CopyRealToTemp         push on opstack
                    lbra      RealMulEntry         Convert to base 10 log

LnFnc               pshs      x
                    ldb       5,y           Get sign byte
                    asrb                    Sign
                    lbcs      IllegalArgErr         bra if illegal
                    ldd       1,y           Ln(0)?
                    lbeq      IllegalArgErr         bra if so
                    pshs      a             Save exponent
                    ldb       #1            Set exponent to one
                    stb       1,y           Save it
                    leay      <-$1A,y       Make room for cordic
                    leax      <$1B,y        Get ptr to argument
* (orig: ATNSUB)
                    leau      ,y
                    lbsr      CMOVE
                    lbsr      CDENOR         Denormalize it
* (orig: FPZERO)
                    clra
                    clrb
                    std       <$14,y        Set nos to zero
                    std       <$16,y
                    sta       <$18,y
                    leax      >CordExpFuncPtr,pc           Point to routine
                    stx       <$19,y
                    lbsr      CordSetup
                    leax      <$14,y        Get ptr to result
                    leau      <$1B,y
                    lbsr      CMOVE
                    lbsr      CNORM
                    leay      <$1A,y        return cordic TEMP
                    ldb       #$02          Replace TYPE
                    stb       ,y
                    ldb       $05,y         Get sign byte
                    orb       #$01
                    stb       $05,y
                    puls      b             Get argument exponent
                    bsr       CBLN2         Multiply by ln(2)
                    puls      x
                    lbra      RealAdd         Add product to cordic result

Ln2Const               fcb       $00,$b1,$72,$17,$f8 (.693147181) LOG(2) in REAL format

CBLN2               sex                           Convert to 16 bit number
                    bpl       CBLN10               If positive, skip ahead
                    negb                          Invert sign on LSB
CBLN10               anda      #$01
                    pshs      d             Save sign, ABS(exponent)
CNOR20               leau      <Ln2Const,pc           Point to Log(2) in REAL format
                    lbsr      CopyRealToTemp         Move to stack
                    ldb       5,y           Get lsb
                    lda       1,s           Get ABS(exponent)
                    cmpa      #1            one?
                    beq       CBLN40               If multiplying by 1, don't bother
                    mul
                    stb       5,y           Save lsb result
                    ldb       4,y
                    sta       4,y           Set up partial product accumulator
                    lda       1,s
                    mul
                    addb      $04,y
                    adca      #$00
                    stb       $04,y
                    ldb       $03,y
                    sta       $03,y
                    lda       $01,s
                    mul
                    addb      $03,y
                    adca      #$00
                    stb       $03,y
                    ldb       $02,y
                    sta       $02,y
                    lda       $01,s
                    mul
                    addb      $02,y         Add partial
                    adca      #$00          Propagate carry
                    beq       CBLN30         bra if msb clear
CBLN20               inc       $01,y
                    lsra
                    rorb
                    ror       $03,y
                    ror       $04,y
                    ror       $05,y
                    tsta                    Done?
                    bne       CBLN20         ..No
CBLN30               stb       $02,y
                    ldb       $05,y         Get nos ABS value
CBLN40               andb      #$FE
                    orb       ,s            Set sign
                    stb       $05,y         Save it
                    puls      pc,d          return error

EXPFNC               pshs      x
                    ldb       $01,y         Get exponent
                    beq       EXPF21         bra if zero
                    cmpb      #$07          in computable range?
                    ble       EXPF10         bra if so
                    ldb       $05,y         Get sign byte
                    rorb                    sign to carry
                    rorb                    sign to sign
                    eorb      #$80          reverse sign
                    lbra      FPOVRF

EXPF10               cmpb      #$E4
                    lble      REXP10         return one if not
                    tstb                    Exponent positive?
                    bpl       EXPF25         bra if so
EXPF21               clr       ,-s
                    ldb       $05,y         Get arg sign byte
                    andb      #$01          Ge sign
                    beq       EXPF50         bra if done
                    bra       EXPF45         Go finish

EXPF25               lda       #$71
                    mul
                    adda      $01,y
                    ldb       $05,y         Get sign byte
                    andb      #$01          Get sign
                    pshs      b,a           Save count
                    eorb      $05,y         Clear sign
                    stb       $05,y         Replace it
                    ldb       ,s
EXPF30               lbsr      CBLN2
                    lbsr      RealSubtract         Subtract adjustment from argument
                    ldb       $01,y         Get result exponent
                    ble       EXPF40
                    addb      ,s
                    stb       ,s
                    ldb       $01,y
                    bra       EXPF30

EXPF40               puls      d
                    pshs      a             Save result exponent
                    tstb                    Arg positive
                    beq       EXPF50         bra if so
                    nega                    Exponent
                    sta       ,s
                    orb       5,y           Replace sign
                    stb       5,y
EXPF45               leau      >Ln2Const,pc           Point to LOG(2) in REAL format
                    lbsr      CopyRealToTemp
                    lbsr      RealAdd         Add constant
                    dec       ,s
                    ldb       5,y           Get result sign byte
                    andb      #$01          Get sign
                    bne       EXPF45         bra if not positive yet
EXPF50               leay      <-$1A,y
                    leax      <$1B,y
                    leau      <$14,y        Get y' address
                    lbsr      CMOVE         Call mover
                    lbsr      CDENOR         Denormalize
                    ldd       #$1000        Initialize cordic TEMP
                    std       ,y
                    clra
                    std       $02,y
                    sta       $04,y
                    leax      >FPDV45,pc     Get routine addr
                    stx       <$19,y        Save it
                    bsr       CordSetup         Add (u) > (x)
                    leax      ,y
                    leau      <$1B,y        Get address of result
                    lbsr      CMOVE
                    lbsr      CNORM         Normalize it
* (orig: RADD20)
                    leay      <$1A,y        Fix opstack
                    puls      b
                    addb      $01,y         Add new exponent to cordic result
                    bvs       FPOVRF         Bra if overflow
* (orig: ELCOR)
                    lda       #$02          Replace TYPE
                    std       ,y
                    puls      pc,x

CordSetup               lda       #$01
                    sta       <TrigNegFlag
                    leax      >CordAngleTab2,pc     Get entry address
                    stx       <TrigPtr1        Set it
                    leax      >$005F,x      Get end of table address
                    stx       <TrigPtr2
                    lbra      CORDIC

FPOVRF               leay      -6,y
                    lbpl      RmulZeroResult         return zero if too small
                    ldb       #$32                Floating Overflow error
                    jsr       <JmpVect4
                    fcb       $06

ASNFNC               pshs      x
                    bsr       CSIGN
                    ldd       $01,y
                    lbeq      TrigReturnReal
                    cmpd      #$0180
                    bgt       ASNERR
                    bne       AsnFncMain
                    ldd       $03,y
                    bne       ASNERR
                    lda       $05,y
                    lbeq      RETPI2         return pi/2 if arg is one
ASNERR               lbra      IllegalArgErr

AsnFncMain               lbsr      ARCSUB
                    leay      <-$14,y       Make room for cordic
                    leax      <$15,y        Get x-coord ptr
                    leau      ,y            Get stack location
                    lbsr      CMOVE         Move x-coord
                    lbsr      CDENOR         Denormalize it
                    leax      <$1B,y        Get y-coord ptr
                    lbra      AtnFncCordic         Get arctangent

CSIGN               ldb       $05,y
                    andb      #$01          Get sign bit
                    stb       <TrigTemp        Save it
                    eorb      $05,y         Get operand sign difference
                    stb       $05,y         Save it and fall to rladd
                    rts

ACSFNC               leau      <ACSRET,pc
                    pshs      u,x           Save i-code ptr
                    bsr       CSIGN         Call shifter
                    ldd       $01,y
                    lbeq      RETPI2
                    cmpd      #$0180
                    bgt       ASNERR
                    bne       ACSF10
                    ldd       $03,y
                    bne       ASNERR
                    lda       $05,y         Test last byte
                    bne       ASNERR
                    lda       <TrigTemp
                    bne       ACSF05
                    clrb
                    std       $01,y
                    puls      pc,u,x

ACSF05               leay      6,y                 Eat temp var
                    puls      u,x
                    lbra      CopyPiToStack

ACSF10               bsr       ARCSUB
                    leay      <-$14,y       Make room for cordic
                    leax      <$1B,y        Get x-coord ptr
                    leau      ,y
                    lbsr      CMOVE
                    lbsr      CDENOR
                    leax      <$15,y
                    lbra      AtnFncCordic

ACSRET               lda       5,y
                    bita      #$01
                    beq       ACSF25
                    ldu       <VarStorePtr
                    tst       1,u
                    beq       AcsFncPiDiv2
                    leau      <Const180,pc           Point to 180 in FP format
* (orig: ACSF15)
                    lbsr      CopyRealToTemp
                    bra       ACSF20

AcsFncPiDiv2               lbsr      CopyPiToStack
ACSF20               lbra      RealAdd

* See if we can move label to RTS above @ CSIGN, or below @ end of ARCSUB
ACSF25               rts

Const180               fcb       $08,$b4,$00,$00,$00 180

ARCSUB               lda       <TrigTemp
                    pshs      a
                    leay      <-$12,y
                    ldd       #$0201
                    std       $0C,y
                    lda       #$80
                    clrb
                    std       $0E,y
                    clra
                    std       <$10,y
                    ldd       <$12,y
                    std       ,y
                    std       $06,y
                    ldd       <$14,y
                    std       $02,y
                    std       $08,y
                    ldd       <$16,y
                    std       $04,y
                    std       $0A,y
                    lbsr      RealMulEntry
                    lbsr      RealSubtract
                    lbsr      SQRR05
                    puls      a
                    sta       <TrigTemp
                    rts

ATNFNC               pshs      x
                    lbsr      CSIGN
                    ldb       $01,y
                    cmpb      #$18
                    blt       AtnFncCalc
RETPI2               leay      6,y
                    lbsr      CopyPiToStack
                    dec       1,y
                    bra       ATNF35

AtnFncCalc               leay      <-$1A,y
                    ldd       #$1000
                    std       ,y
                    clra
                    std       $02,y
                    sta       $04,y
                    ldb       <$1B,y
                    bra       ATNF30

ATNF20               asr       ,y
                    ror       1,y
                    ror       2,y
                    ror       3,y
                    ror       4,y
                    decb
ATNF30               cmpb      #$02
                    bgt       ATNF20
                    stb       <$1B,y
                    leax      <$1B,y
AtnFncCordic               leau      $0A,y
                    lbsr      CMOVE
                    lbsr      CDENOR
                    clra
                    clrb
                    std       <$14,y
                    std       <$16,y
                    sta       <$18,y
                    leax      >CCIRY0,pc
                    stx       <$19,y
                    lbsr      CIRCOR
                    leax      <$14,y
                    leau      <$1B,y
                    lbsr      CMOVE
                    lbsr      CNORM
                    leay      <$1A,y
ATNF35               lda       $05,y
                    ora       <TrigTemp
                    sta       $05,y
                    ldu       <VarStorePtr
                    tst       1,u
                    beq       TrigReturnReal
                    leau      >RadConst,pc
                    lbsr      CopyRealToTemp
                    lbsr      RealMulEntry
                    bra       TrigReturnReal

SINFNC               pshs      x
                    lbsr      TrigSetupArg
                    leax      $0A,y
                    bsr       TrigCopyNorm
* (orig: SINFN4)
                    lda       $05,y
SINFN2               eora      <TrigSign2
SINFN3               sta       $05,y
TrigReturnReal               lda       #$02
                    sta       ,y
                    puls      pc,x

TrigCopyNorm               leau      <$1B,y
                    lbsr      CMOVE
                    lbsr      CNORM
                    leay      <$14,y
                    leax      >CordK0Const,pc           Point to a table of Real #'s
                    leau      1,y
                    lbsr      CMOVE
                    lbra      RealMulEntry

COSFNC               pshs      x
                    bsr       TrigSetupArg
                    leax      ,y
                    bsr       TrigCopyNorm
                    lda       $05,y
                    eora      <TrigSign
                    bra       SINFN3

TANFNC               pshs      x
                    bsr       TrigSetupArg
                    leax      $0A,y
                    leau      <$1B,y
                    lbsr      CMOVE
                    lbsr      CNORM
                    leax      ,y
                    leay      <$14,y
                    leau      $01,y
                    lbsr      CMOVE
                    lbsr      CNORM
                    ldd       $01,y
                    bne       TANF10
                    leay      $06,y
                    ldd       #$7FFF
TanfZeroDiv               std       $01,y
                    lda       #$FF
                    std       $03,y
                    deca
                    bra       TANF20

TANF10               lbsr      RealDivEntry
                    lda       $05,y
TANF20               eora      <TrigSign
                    bra       SINFN2

PiConst               fcb       $02,$c9,$0f,$da,$a2 PI (3.14159265)

DegConst               fcb       $fb,$8e,$fa,$35,$12 -1.74532925 E-02  (Degrees)

RadConst               fcb       $06,$e5,$2e,$e0,$d4 57.2957795 (radians)

CopyPiToStack               leau      <PiConst,pc           Point to PI in FP format
                    lbra      CopyRealToTemp

TrigSetupArg               ldu       <VarStorePtr
                    tst       1,u
                    beq       TRIG05
                    leau      <DegConst,pc
                    lbsr      CopyRealToTemp               Copy 5 bytes from u to 1,y (0,y=2)
                    lbsr      RealMulEntry
TRIG05               clr       <TrigSign
                    ldb       $05,y
                    andb      #$01
                    stb       <TrigSign2
                    eorb      $05,y
                    stb       $05,y
                    bsr       CopyPiToStack
                    inc       $01,y
                    lbsr      RLCMP
                    blt       TRIG10
* (orig: TRIG20)
                    lbsr      MODFNR
                    bsr       CopyPiToStack
                    bra       TrigHalfPi

TRIG10               dec       $01,y
TrigHalfPi               lbsr      RLCMP
                    blt       TRIG30
                    inc       <TrigSign
                    lda       <TrigSign2
                    eora      #$01
                    sta       <TrigSign2
                    lbsr      RealSubtract
                    bsr       CopyPiToStack
TRIG30               dec       $01,y
                    lbsr      RLCMP
                    ble       TrigCordicSetup
                    lda       <TrigSign
                    eora      #$01
                    sta       <TrigSign
                    inc       $01,y
                    lda       $0B,y
                    ora       #$01
                    sta       $0B,y
                    lbsr      RealAdd
* (orig: TRIG40)
                    leay      -$06,y
TrigCordicSetup               leay      <-$14,y
                    leax      >CordTestResult,pc
                    stx       <$19,y
                    leax      <$1B,y
                    leau      <$14,y
                    bsr       CMOVE
                    lbsr      CDENOR
                    ldd       #$1000
                    std       ,y
                    clra
                    std       $02,y
                    sta       $04,y
                    std       $0A,y
                    std       $0C,y
                    sta       $0E,y
CIRCOR               leax      >CordAngTable,pc           Point to some real # table
                    stx       <TrigPtr1
                    leax      <CordK0Const-CordAngTable,x      Point to further in table
                    stx       <TrigPtr2
                    clr       <TrigNegFlag
CORDIC               ldb       #$25
                    stb       <TrigIter
                    clr       <TrigOctant
CORD10               leau      <$1B,y
                    ldx       <TrigPtr1
                    cmpx      <TrigPtr2
                    bhs       CORD20
                    bsr       CMOVE
                    leax      5,x                 Point to next entry in 5-byte entry table
                    stx       <TrigPtr1              Save new ptr
                    bra       CORD30

CORD20               ldb       #$01
                    bsr       CordShiftRight
CORD30               leax      ,y
                    leau      5,y
                    bsr       CSR
                    tst       <TrigNegFlag
                    bne       CORD40
                    leax      $0A,y
                    leau      $0F,y
                    bsr       CSR
CORD40               jsr       [<$19,y]
                    inc       <TrigOctant
                    dec       <TrigIter
                    bne       CORD10
                    rts

CMOVE               pshs      y,x
                    lda       ,x
                    ldy       1,x
                    ldx       3,x
                    sta       ,u
                    sty       1,u
                    stx       3,u
                    puls      pc,y,x

CSR               ldb       ,x
                    sex
                    ldb       <TrigOctant
                    lsrb
                    lsrb
                    lsrb
                    bcc       CSR05
                    incb
CSR05               pshs      b
                    beq       CSR2
CSR1               sta       ,u+
                    decb
                    bne       CSR1
CSR2               ldb       #$05
                    subb      ,s+
                    beq       CSR35
CSR3               lda       ,x+
                    sta       ,u+
                    decb
                    bne       CSR3
CSR35               leau      -5,u
                    ldb       <TrigOctant
                    andb      #$07
                    beq       CSR5
                    cmpb      #$04
                    bcs       CordShiftRight
                    subb      #$08
                    lda       ,x
CordShiftLeft               lsla
                    rol       4,u
                    rol       3,u
                    rol       2,u
                    rol       1,u
                    rol       ,u
                    incb
                    bne       CordShiftLeft
                    rts

CordShiftRight               asr       ,u
                    ror       1,u
                    ror       2,u
                    ror       3,u
                    ror       4,u
                    decb
                    bne       CordShiftRight
CSR5               rts

CCIRY0               lda       $0A,y
                    eora      ,y
                    coma
                    bra       CTEST

CordTestResult               lda       <$14,y
CTEST               tsta
                    bpl       CordRotatePos
                    leax      ,y
                    leau      $0F,y
                    bsr       CADD
* (orig: CEXP10)
                    leax      $0A,y
                    leau      $05,y
                    bsr       CSUB
                    leax      <$14,y
                    leau      <$1B,y
                    bra       CADD

CordRotatePos               leax      ,y
                    leau      $0F,y
                    bsr       CSUB
                    leax      $0A,y
                    leau      $05,y
                    bsr       CADD
* (orig: CEXP)
                    leax      <$14,y
                    leau      <$1B,y
                    bra       CSUB

***************
* Check For Premature Completion
FPDV45               leax      <$14,y
                    leau      <$1B,y
                    bsr       CSUB
                    bmi       CADD
                    bne       CLN
                    ldd       $01,x
                    bne       CLN
                    ldd       $03,x
                    bne       CLN
                    ldb       #$01
                    stb       <TrigIter
CLN               leax      ,y
                    leau      5,y
                    bra       CADD

CordExpFuncPtr               leax      ,y
                    leau      $05,y
                    bsr       CADD
                    cmpa      #$20
                    bcc       CSUB
                    leax      <$14,y
                    leau      <$1B,y
CADD               ldd       3,x
                    addd      3,u
                    std       3,x
                    ldd       1,x
                    bcc       CaddCarry
* (orig: CADD10)
                    addd      #$0001
                    bcc       CaddCarry
                    inc       ,x
CaddCarry               addd      1,u
                    std       1,x
                    lda       ,x
                    adca      ,u
                    sta       ,x
                    rts

CSUB               ldd       3,x
                    subd      3,u
                    std       3,x
                    ldd       1,x
                    bcc       CsubBorrow
* (orig: CSUB10)
                    subd      #$0001
                    bcc       CsubBorrow
                    dec       ,x
CsubBorrow               subd      1,u
                    std       1,x
                    lda       ,x
                    sbca      ,u
                    sta       ,x
* (orig: CNOR30)
                    rts

CDENOR               ldb       ,u
                    clr       ,u
                    addb      #$04
                    bge       CDEN20
                    negb
                    lbra      CordShiftRight

* Multiply 5 byte number @ ,u  by 2
* Entry: B=# times to multiply
CordMul2Loop               lsl       4,u
                    rol       3,u
                    rol       2,u
                    rol       1,u
                    rol       ,u
                    decb
CDEN20               bne       CordMul2Loop
                    rts

CNORM               lda       ,u                  Get sign of 5 byte #
                    bpl       CnormNegInit               If positive, skip ahead
                    ifne      H6309
                    clrd                          Clr 5 bytes @ u
                    else
                    clra
                    clrb
                    endc
                    std       ,u
                    std       2,u
                    sta       4,u
                    rts

CnormNegInit               ldd       #$2004
CnormShiftLoop               decb
                    lsl       4,u
                    rol       3,u
                    rol       2,u
                    rol       1,u
                    rol       ,u
                    bmi       CnormSaveResult
                    deca
                    bne       CnormShiftLoop
                    clrb
* (orig: FPMUL6)
                    std       ,u
                    rts

CnormSaveResult               lda       ,u
                    stb       ,u
                    ldb       1,u
                    sta       1,u
                    lda       2,u
                    stb       2,u
                    ldb       3,u
                    addd      #$0001
                    andb      #$FE
                    std       3,u
                    bcc       CnormDone
                    inc       2,u
                    bne       CnormDone
                    inc       1,u
                    bne       CnormDone
                    ror       1,u
                    inc       ,u
CnormDone               rts

* Data (all 5 byte entries for real #'s???)
CordAngTable               fcb       $0c,$90,$fd,$aa,$22 2319.85404
                    fcb       $07,$6b,$19,$c1,$58 53.5503032
                    fcb       $03,$eb,$6e,$bf,$26 7.35726888
                    fcb       $01,$fd,$5b,$a9,$ab -1.97935983
                    fcb       $00,$ff,$aa,$dd,$b9
                    fcb       $00,$7f,$f5,$56,$ef
                    fcb       $00,$3f,$fe,$aa,$b7
                    fcb       $00,$1f,$ff,$d5,$56
                    fcb       $00,$0f,$ff,$fa,$ab
                    fcb       $00,$07,$ff,$ff,$55
                    fcb       $00,$03,$ff,$ff,$eb
                    fcb       $00,$01,$ff,$ff,$fd
                    fcb       $00,$01,$00,$00,$00

CordK0Const               fcb       $00,$9b,$74,$ed,$a8 .607252935
CordAngleTab2               fcb       $0b,$17,$21,$7f,$7e 0185.04681
                    fcb       $06,$7c,$c8,$fb,$30
                    fcb       $03,$91,$fe,$f8,$f3
                    fcb       $01,$e2,$70,$76,$e3
                    fcb       $00,$f8,$51,$86,$01
                    fcb       $00,$7e,$0a,$6c,$3a
                    fcb       $00,$3f,$81,$51,$62
                    fcb       $00,$1f,$e0,$2a,$6b
                    fcb       $00,$0f,$f8,$05,$51
                    fcb       $00,$07,$fe,$00,$aa
                    fcb       $00,$03,$ff,$80,$15
                    fcb       $00,$01,$ff,$e0,$03
                    fcb       $00,$00,$ff,$f8,$00
                    fcb       $00,$00,$7f,$fe,$00
                    fcb       $00,$00,$3f,$ff,$80
                    fcb       $00,$00,$1f,$ff,$e0
                    fcb       $00,$00,$0f,$ff,$f8
                    fcb       $00,$00,$07,$ff,$fe
                    fcb       $00,$00,$04,$00,$00

RndInitData               fdb       $0E12,$14A2,$BB40,$E62D,$3619,$62E9

                    ifne      H6309
RNDFNC               clrd
                    else
RNDFNC               clra
                    clrb
                    endc
                    std       <RndTmpH
                    std       <RndCalcL
                    pshs      a                   ??? Save flag (0)
                    lda       2,y
                    beq       RndCalcStart
                    ldb       5,y                 ??? Get sign/exponent byte
                    bitb      #1                  ??? Negative number?
                    bne       RMOVE               ??? Yes, skip ahead
                    com       ,s                  ??? No, set flag
                    bra       RndCalcStart

RMOVE               addb      #$FE
                    addb      1,y
                    lda       4,y
                    std       <RndSeedL
                    ldd       2,y
                    std       <RndSeedH
RndCalcStart               lda       <RndSeedL1
                    ldb       <RndMultB3
                    mul
                    std       <RndCalcL
                    lda       <RndSeedL
                    ldb       <RndMultB3
                    mul
                    addd      <RndTmpL
                    bcc       RndCalcLoop1
                    inc       <RndTmpH
RndCalcLoop1               std       <RndTmpL
                    lda       <RndSeedL1
                    ldb       <RndMultB2
                    mul
                    addd      <RndTmpL
                    bcc       RndCalcLoop2
                    inc       <RndTmpH
RndCalcLoop2               std       <RndTmpL
                    lda       <RndSeedH1
                    ldb       <RndMultB3
                    mul
                    addd      <RndTmpH
                    std       <RndTmpH
                    lda       <RndSeedL
                    ldb       <RndMultB2
                    mul
                    addd      <RndTmpH
                    std       <RndTmpH
                    lda       <RndSeedL1
                    ldb       <RndMultB1
                    mul
                    addd      <RndTmpH
                    std       <RndTmpH
                    lda       <RndSeedH
                    ldb       <RndMultB3
                    mul
                    addb      <RndTmpH
                    stb       <RndTmpH
                    lda       <RndSeedH1
                    ldb       <RndMultB2
                    mul
                    addb      <RndTmpH
                    stb       <RndTmpH
                    lda       <RndSeedL
                    ldb       <RndMultB1
                    mul
                    addb      <RndTmpH
                    stb       <RndTmpH
* NOTE: ON 6809, CHANGE TO LDD <RndSeedL1
                    lda       <RndSeedL1
                    ldb       <RndMultB0
                    mul
                    addb      <RndTmpH
                    stb       <RndTmpH
                    ldd       <RndCalcL
                    addd      <RndAddend
                    std       <RndSeedL
                    ldd       <RndTmpH
* NOTE: 6309 ADCD <RndIncrH
                    adcb      <RndIncrL
                    adca      <RndIncrH
                    std       <RndSeedH
                    tst       ,s+
                    bne       RND2
                    ldd       <RndSeedH
                    std       2,y
                    ldd       <RndSeedL
                    std       4,y
                    clr       1,y
***************
* Normalize the Result
RNDNOR               lda       #$1F
                    pshs      a
                    ldd       $02,y
                    bmi       RNDNR2
FPDV30               dec       ,s
                    beq       RNDNR2
                    dec       $01,y
                    lsl       $05,y
                    rol       $04,y
                    rolb
                    rola
                    bpl       FPDV30
RNDNR2               std       $02,y
                    ldb       $05,y
                    andb      #$FE
                    stb       $05,y
                    puls      pc,b

RND2               ldd       <RndSeedL
                    andb      #$FE                ??? Kill sign bit on real #?
                    std       ,--y
                    ldd       <RndSeedH
                    std       ,--y
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       ,--y
                    bsr       RNDNOR
                    lbra      RealMulEntry

LenFnc               ldd       <StrStkPtr
                    ldu       1,y
                    subd      1,y
                    subd      #1
                    stu       <StrStkPtr
SaveStrLen               std       1,y
                    lda       #1
                    sta       ,y
                    rts

ASCFNC               ldd       1,y
                    std       <StrStkPtr
                    ldb       [<$01,y]
                    clra
                    bra       SaveStrLen

CHRFNC               ldd       1,y
                    tsta
                    lbne      IllegalArgErr
                    ldu       <StrStkPtr
                    stu       1,y
                    stb       ,u+
                    lbsr      ENDS00
                    sty       <StrSpaceTop
                    cmpu      <StrSpaceTop
                    lbhs      StrStkOverflow
                    rts

LeftFnc               ldd       1,y
                    ble       LeftFncTrunc
                    addd      7,y
                    tfr       d,u
                    cmpd      <StrStkPtr
                    bcc       LeftFncDone
                    bsr       AppendEOS
LeftFncDone               leay      6,y
                    rts

LeftFncTrunc               leay      6,y
                    ldu       1,y
                    bra       AppendEOS

RGTFNC               ldd       1,y
                    ble       LeftFncTrunc
                    pshs      x
                    ldd       <StrStkPtr
                    subd      1,y
                    subd      #1
                    cmpd      7,y
                    bls       RGTFN2
                    tfr       d,x
                    ldu       7,y
RgtCopyLoop               lda       ,x+
                    sta       ,u+
                    cmpa      #$FF
                    bne       RgtCopyLoop
                    stu       <StrStkPtr
RGTFN2               leay      6,y
                    puls      pc,x

MIDFNC               ldd       $01,y
                    ble       VARR05
                    ldd       $07,y
                    bgt       MIDFN2
VARR05               ldd       $01,y
                    leay      $06,y
                    std       $01,y
                    bra       LeftFnc

MIDFN2               subd      #$0001
                    beq       VARR05
                    addd      $0D,y
                    cmpd      <StrStkPtr
                    bcs       MIDFN3
                    leay      $06,y
                    bra       LeftFncTrunc

MIDFN3               pshs      x
                    tfr       d,x
                    ldb       $02,y
                    ldu       $0D,y
MidCopyLoop               lda       ,x+
                    sta       ,u+
                    cmpa      #$FF
                    beq       MIDFN5
                    decb
                    bne       MidCopyLoop
                    dec       1,y
                    bpl       MidCopyLoop
                    lda       #$FF
                    sta       ,u+
MIDFN5               stu       <StrStkPtr
                    leay      $0C,y
                    puls      pc,x

TRMFNC               ldu       <StrStkPtr
                    leau      -1,u
TRMFN2               cmpu      $01,y
                    beq       AppendEOS
                    lda       ,-u
                    cmpa      #$20
                    beq       TRMFN2
                    leau      1,u
AppendEOS               lda       #$FF
                    sta       ,u+
                    stu       <StrStkPtr
                    rts

SUBFNC               pshs      y,x
                    ldd       <StrStkPtr              ??? Get size of string
                    subd      1,y                 Subtract ptr to string to search in
                    addd      7,y                 Add to ptr to string to search for
                    addd      #1                  +1
                    ldx       7,y                 Get ptr to string to search for
                    ldy       1,y                 Get ptr to string to search in
***************
* String Compare =>
* (orig: STCMGE)
                    bsr       Vect1Fn8               Call Substr function (should change to direct LBSR
                    bcc       SUBF10               If sub-string match found, skip ahead
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    bra       SUBF20

Vect1Fn8               jsr       <JmpVect1              Substr string search
                    fcb       $08

SUBF10               tfr       y,d
                    ldx       2,s
                    subd      1,x
                    addd      #$0001
SUBF20               puls      y,x
                    std       7,y
                    lda       #1
                    sta       6,y
                    leay      6,y
                    rts

STRFNI               ldb       #$02
                    bra       STRF10         exit

StrFnReal               ldb       #$03
STRF10               lda       <TmpBufCount
                    ldu       <TmpBufCur
                    pshs      u,x,a
                    lbsr      Vect6Fn2
                    bcs       IllegalArgErr
                    ldx       <TmpBufCur
                    lda       #$FF
                    sta       ,x
                    ldx       $03,s
                    lbsr      STRLIT
                    puls      u,x,a
                    sta       <TmpBufCount
                    stu       <TmpBufCur
                    rts

IllegalArgErr               ldb       #$43                Illegal Arguement error
                    jsr       <JmpVect4
                    fcb       $06

TABFNC               pshs      x
                    ldd       1,y
                    blt       IllegalArgErr
                    sty       <StrSpaceTop
                    ldu       <StrStkPtr
                    stu       $01,y
                    lda       #$20
TABF10               cmpb      <TmpBufCount
                    bls       ENDSTR
                    sta       ,u+
                    decb
                    cmpu      <StrSpaceTop
                    blo       TABF10
                    lbra      StrStkOverflow

ENDS00               pshs      x
ENDSTR               lda       #$FF
                    sta       ,u+
                    stu       <StrStkPtr
                    lda       #$04
                    sta       ,y
                    puls      pc,x

* DATE$ routine
* Minor change to accommodate Y2K changes in year. RG
DATFNC               pshs      x
                    leay      -6,y
                    leax      -6,y
                    ldu       <StrStkPtr
                    stu       1,y
                    os9       F$Time              Get time packet
                    bcs       ENDSTR               Error, exit
*         bsr   DateConvert      Start converting
                    lda       ,x+
                    ldb       #'/
                    cmpa      #100
                    blo       Y19
cnty                suba      #100
                    bhs       cnty          <<end patch
                    adda      #100
Y19                 bsr       DATC10
                    lda       #'/                 Append /
                    bsr       DATCNV
                    lda       #'/
                    bsr       DATCNV
                    lda       #$20
                    bsr       DATCNV
                    lda       #':
                    bsr       DATCNV
* (orig: DATC05)
                    lda       #':
                    bsr       DATCNV
                    bra       ENDSTR

DATCNV               sta       ,u+
DateConvert               lda       ,x+                 Get byte from time packet
                    ldb       #'/
DATC10               incb
                    suba      #10
                    bcc       DATC10
                    stb       ,u+
                    ldb       #':
DATC20               decb
                    inca
                    bne       DATC20
                    stb       ,u+
                    rts

EOFFNC               lda       2,y                 Get path #
                    ldb       #SS.EOF             Check if we are at end of file
                    os9       I$GetStt
                    bcc       EofFalse               No, skip ahead
                    cmpb      #E$EOF              Was the error an EOF error?
                    bne       EofFalse               No, skip ahead
                    ldb       #$FF
                    bra       EofReturn

EofFalse               clrb
EofReturn               clra
                    std       1,y
                    lda       #$03
                    sta       ,y
                    rts

***************
* Subroutine INIT
*   Initialize interpreter
InterpreterInit               ldb       #$06                6 2-byte entries to copy
                    pshs      y,x,b               Preserve regs
                    tfr       dp,a                Move DP to MSB of D
                    ldb       #$50                Point to [dp]50 (always RndSeedH in Lvl II)
                    tfr       d,y                 Move to Y
                    leax      >RndInitData,pc           Point to table
INIT1               ldd       ,x++                Get 2 bytes
                    std       ,y++                Move into DP
                    dec       ,s                  Do all 6
                    bne       INIT1               Until done
                    leax      >VarCopyBase,pc           Point to jump table
                    stx       <JmpTbl1              Save ptr
                    leax      >ExprJmpBase,pc           Point to another jump table
                    stx       <JmpTbl2              Save ptr
                    lda       #$7E                Get opcode for JMP >xxxx
                    sta       <JmpOpcode              Save it
                    leax      >EVAL,pc           Point to routine
                    stx       <JmpTarget              Save as destination for above JMP
                    leax      <Vect1Fn1A,pc           Point to JSR <JmpVect1 / FCB $1A
                    stx       <EvalSetup              Save it
                    puls      pc,y,x,b            Restore regs & return

Vect1Fn1A               jsr       <JmpVect1
                    fcb       $1a

* <JmpVect6 goes here
Vect6Dispatch               pshs      x,d                 Preserve regs
                    ldb       [<$04,s]            Get function code
                    leax      <Vect6JmpTbl,pc           Point to table (only functions 0 & 2)
                    ldd       b,x                 Get offset
                    leax      d,x                 Point to routine
                    stx       4,s                 Save over PC on stack
                    puls      pc,x,d              Restore X&D & go to routine

Vect6JmpTbl               fdb       ASCNUM-Vect6JmpTbl         Function 0
                    fdb       Vect6Fn2Disp-Vect6JmpTbl         Function 2

CallVect5FnC               jsr       <JmpVect5
                    fcb       $0c
CallVect5FnE2               jsr       <JmpVect5
                    fcb       $0e

* <JmpVect6 function 2
* Entry: B=Sub-function #
Vect6Fn2Disp               pshs      pc,x,d              Make room for new PC, preserve X & Y
                    lslb                          2 bytes / entry
                    leax      <IoJmpBase,pc           Point to jump offset table
IoSubDisp               ldd       b,x                 Get offset
IoSubJmp               leax      d,x                 Add to base of table
                    stx       4,s                 Save over PC on stack
                    puls      pc,x,d              Restore X&D & JMP to subroutine

* Sub-function jump table (IoJmpBase is the base)
IoJmpBase               fdb       OUTLIN-IoJmpBase         $045f  0
                    fdb       OUTINT-IoJmpBase         $05c3  1
                    fdb       OUTINT-IoJmpBase         $05c3  2
                    fdb       OUTRL-IoJmpBase         $04b7  3
                    fdb       OUTBL-IoJmpBase         $05b3  4
                    fdb       OutStrImpl-IoJmpBase         $05aa  5
                    fdb       INPLIN-IoJmpBase         $044a  6
                    fdb       INPBYT-IoJmpBase         $0258  7
                    fdb       InpIntImpl-IoJmpBase         $026b  8
                    fdb       INPRL-IoJmpBase         $0235  9
                    fdb       INPBL-IoJmpBase         $02a2  A
                    fdb       STRINP-IoJmpBase         $027f  B
                    fdb       OUTCR-IoJmpBase         $05f9  C
                    fdb       SKPZON-IoJmpBase         $05e9  D
                    fdb       SEEK-IoJmpBase         $0478  E
                    fdb       UNIMPL-IoJmpBase         $0a11  F    Exit with Unimplemented routine err
                    fdb       OUTTAB-IoJmpBase         $05da  10
                    fdb       NXTFMT-IoJmpBase         $06ba  11
                    fdb       OUTCHR-IoJmpBase         $0562  12
                    fdb       EXCFMT-IoJmpBase         $0759  13
HexOutEntry               fdb       OUTHEX-IoJmpBase         $0602  14

* Table for Integer conversion
IntConvTable               fdb       10000
                    fdb       1000
                    fdb       100
                    fdb       10

* Table for REAL conversion
RealConvTable               fcb       $04,$a0,$00,$00,$00 10
                    fcb       $07,$c8,$00,$00,$00 100
                    fcb       $0a,$fa,$00,$00,$00 1000
                    fcb       $0e,$9c,$40,$00,$00 10 thousand
                    fcb       $11,$c3,$50,$00,$00 100 thousand
                    fcb       $14,$f4,$24,$00,$00 1 million
                    fcb       $18,$98,$96,$80,$00 10 million
                    fcb       $1b,$be,$bc,$20,$00 100 million
                    fcb       $1e,$ee,$6b,$28,$00 1 billion
                    fcb       $22,$95,$02,$f9,$00 10 billion
                    fcb       $25,$ba,$43,$b7,$40 100 billion
                    fcb       $28,$e8,$d4,$a5,$10 1 trillion
                    fcb       $2c,$91,$84,$e7,$2a 10 trillion
                    fcb       $2f,$b5,$e6,$20,$f4 100 trillion
                    fcb       $32,$e3,$5f,$a9,$32 1 quadrillion
                    fcb       $36,$8e,$1b,$c9,$c0 10 quadrillion
                    fcb       $39,$b1,$a2,$bc,$2e 100 quadrillion
                    fcb       $3c,$de,$0b,$6b,$3a 1 quintillion
RealConvLast               fcb       $40,$8a,$c7,$23,$04 10 quintillion

TrueStr               fcc       'True'
                    fcb       $ff

FalseStr               fcc       'False'
                    fcb       $ff

* <JmpVect4 function 2
***************
* Initialize
ASCNUM               pshs      u
                    leay      -6,y                Make room for temp var
                    clra
                    clrb
* 6809/6309 MOD: Change following 4 lines to STD <TmpReal0, STD <TmpReal2
                    sta       <TmpReal0              ??? Zero out real # in DP?
                    sta       <TmpReal1
                    sta       <TmpReal2
                    sta       <TmpReal3
                    sta       <TmpReal4
                    std       4,y                 ??? Zero out temp real #
                    std       2,y
                    sta       1,y
                    lbsr      SKPDL1
                    bcc       ASCNM3         bra no delimiter
                    leax      -1,x          Back up to delimiter
* (orig: ASCNM1)
                    cmpa      #$2C          Comma delimiter?
                    bne       NumFmtErr         Numeric format error if not
                    lbra      AscnmIntResult         Finish as integer if so

ASCNM3               cmpa      #$24
                    lbeq      INPHEX         Goto hex routine if so
                    cmpa      #$2B          Plus?
                    beq       ASCNM2
                    cmpa      #$2D
                    bne       AscnmDecimal
                    inc       <TmpReal3        Set mant sgn neg
***************
* Process Mantissa or Integer
ASCNM2               lda       ,x+
AscnmDecimal               cmpa      #$2E
                    bne       ASCNM4
                    tst       <TmpReal2        First one found?
                    bne       NumFmtErr         Format error if not
                    inc       <TmpReal2        Set dp flag
                    bra       ASCNM2

***************
* Process digit
ASCNM4               lbsr      CHKDIG
                    bcs       ASCNM7         bra if not
                    pshs      a             save digit val
                    inc       <TmpReal1        Incr digit count
                    ldd       4,y           Get mant ls bytes
                    ldu       2,y
                    bsr       MantMul2
                    std       4,y
                    stu       2,y           save t*2
                    bsr       MantMul2         T*2*2
                    bsr       MantMul2         T*2*2*2 = t*8
                    addd      4,y
                    exg       d,u
* 6309 mod: ADCD 2,y
                    adcb      3,y           T=t*8+t*2 = t*10
                    adca      2,y
                    bcs       MantOvflSave
                    exg       d,u           Swap ms:ls
                    addb      ,s+           Add in new digit val
                    adca      #$00          T*10+d
                    bcc       ASCNM6
                    leau      1,u           Inc MS bytes
                    stu       2,y           Set cc zero bit
                    beq       NRERR         Bra if overfl
ASCNM6               std       4,y
                    stu       2,y           save TEMP MS bytes
                    tst       <TmpReal2        in frac part?
                    beq       ASCNM2         Get another char if not
                    inc       <TmpReal4        Bump exponent
                    bra       ASCNM2

MantMul2               lslb
                    rola
                    exg       d,u
                    rolb
                    rola
                    exg       d,u
                    bcs       ROT32E         Error if overfl
                    rts

ROT32E               leas      2,s
MantOvflSave               leas      1,s
***************
* Range Error
NRERR               ldb       #$3C                I/O conversion: Number out of range error
                    bra       NEXIT

NumFmtErr               ldb       #$3B
NEXIT               stb       <ErrCode
                    coma
                    puls      pc,u

***************
* Process Non-digit char
ASCNM7               eora      #$45
                    anda      #$DF          (upper or lower case e?)
                    beq       AscnmExpPart
                    leax      -1,x          Back up buffer ptr
* (orig: ASCN75)
                    tst       <TmpReal1        Did we get digits?
                    bne       ASNIN1
                    bra       NumFmtErr         Too bad

***************
* Final Processing for TYPE Integer
ASNIN1               tst       <TmpReal2
                    bne       ASNRL1         Has to be TYPE real
                    ldd       2,y           Get mant hi bytes
                    bne       ASNRL1         if not 0 must be real
AscnmIntResult               ldd       4,y
                    bmi       ASNRL1         bra if out of integer range
                    tst       <TmpReal3        Check sign flag
                    beq       ASNIN2         Bra if result positive
                    nega                          NEGD  Result
                    negb
                    sbca      #$00
ASNIN2               std       1,y
ASNIN3               lda       #$01
                    lbra      AscnmSaveType

AscnmExpPart               lda       ,x
                    cmpa      #$2B          Plus sign?
                    beq       ASNEX2
                    cmpa      #$2D
                    bne       ASNEX3
                    inc       <TmpReal0        Set neg exp flag
ASNEX2               leax      1,x
ASNEX3               lbsr      GetAsciiDigit
                    bcs       NumFmtErr
                    tfr       a,b
                    lbsr      GetAsciiDigit
                    bcc       ASNEX5
                    leax      -1,x
                    bra       ASNEX6

ASNEX5               pshs      a                   Save 1's digit
                    lda       #10                 Multiply by 10 (for 10's digit)
                    mul
                    addb      ,s+
ASNEX6               tst       <TmpReal0
                    bne       AscnmAddExp
                    negb                    exp
AscnmAddExp               addb      <TmpReal4
                    stb       <TmpReal4        ..and save for later use
ASNRL1               ldb       #$20
                    stb       1,y
                    ldd       2,y           Get MS bytes exponent
                    bne       ASNRL3         Bra to norm if <>0
                    cmpd      4,y           Check ls bytes
                    bne       ASNRL3         Test MS bytes
                    clr       1,y           number is zero
                    bra       AscnmRealType

***************
* Normalize Mantissa
ASNRL3               tsta
                    bmi       ASNRL5         Bra when normalized
AscnmNormLoop               dec       1,y
                    lsl       5,y
                    rol       4,y
                    rolb
                    rola
                    bpl       AscnmNormLoop         Loop til normallized
ASNRL5               std       2,y
                    clr       <TmpReal0        Clear exp sign flag
                    ldb       <TmpReal4        Get dec exponent
                    beq       ASNRL8         if zero no adj needed
                    bpl       ASNRL6         exp must be pos ..
                    negb                    exp postive
                    inc       <TmpReal0        Set neg exp flag
ASNRL6               cmpb      #$13
                    bls       ASNRL7         Bra if ok
                    subb      #$13          Reduce range otherwise
                    pshs      b             save current exp
                    leau      >RealConvLast,pc     Get add of const 1e+19
                    bsr       CNVOPR         ..and reduce range ..
                    puls      b             Restore exp and proceed
                    lbcs      NRERR         ..exit if oper overflowed
ASNRL7               decb                    Bias from exp
                    lda       #5            Num bytes/entry in table
                    mul                     Tble entry addr
                    leau      >RealConvTable,pc     Get constant tbl addr
                    leau      b,u           Add in entry offset
                    bsr       CNVOPR         and reduce range (mult/div)
                    lbcs      NRERR         Range error ..
ASNRL8               lda       5,y
                    anda      #$FE
                    ora       <TmpReal3        Put in sign bit
                    sta       5,y
AscnmRealType               lda       #2                  Real # type
AscnmSaveType               sta       ,y                  Save it in var packet
                    andcc     #$FE                Clear carry (no error)
                    puls      pc,u

***************
* Subroutine to copy constant from [U] Table ptr
* to Opstack and Perform real Multiply Or
* Divide, Depending on exponent Sign (I.Esgn)
CNVOPR               leay      -6,y                Make room for temp var
                    ifne      H6309
                    ldq       ,u                  Copy real # from ,u to 1,y
                    stq       1,y
                    else
                    ldd       ,u                  Get real # from ,u
                    std       1,y                 Save into real portion of var packet
                    ldd       2,u
                    std       3,y
                    endc
                    ldb       4,u
                    stb       5,y
***************
* Get next char, Test if Decimal+Convert
* (orig: TSTDIG)
                    lda       <TmpReal0              Get sign of exponent?
                    lbeq      RealDiv               Real Divide
                    lbra      RealMul               Real Multiply

INPHEX               lbsr      GetAsciiDigit
                    bcc       InhexDigit         Bra if good
                    cmpa      #$61
                    blo       InhexCheckHex         ..no; continue
                    suba      #$20          Shift to upper case
InhexCheckHex               cmpa      #$41
                    blo       INHEX5         Check for a-f
                    cmpa      #$46
                    bhi       INHEX5
                    suba      #$37          Make binary
InhexDigit               inc       <TmpReal1
                    ldb       #4                  Loop counter for shift
InhexShiftLoop               lsl       2,y
                    rol       1,y
                    lbcs      NRERR               If carried right out of byte, error
                    decb
                    bne       InhexShiftLoop               Do all 4 shifts
                    adda      2,y           Add new digit
                    sta       2,y
                    bra       INPHEX

***************
* Clean Up
INHEX5               leax      -1,x
                    tst       <TmpReal1        Any digits?
                    lbeq      NumFmtErr         Error if not
                    lbra      ASNIN3         Return integer

***************
* Subroutine INPRL
* Look for and Convert a real number from
* the Current Location in the I/O buffer.
* Input:  Y = Opstack ptr
*         Inp Str in I/O buffer
* Output: Res on Opstack
*         Y = Y-6 (New Entry)
*         CC = carry Clr if No Error
*               carry and I.ERR Set if Error
* Global: I.IOPT = Moved to 1St byte Past Input Str
INPRL               pshs      x                   Preserve X
                    ldx       <TmpBufCur              Get current pos in temp buffer
                    lbsr      ASCNUM         Call conv subr
                    bcc       INPRL2         Bra if no error
ITYPER               puls      pc,x

INPRL2               cmpa      #2                  Real #?
                    beq       InprlContinue               Yes, continue ahead
                    lbsr      CallVect5FnE2               ??? convert to real?
InprlContinue               lbsr      SKPDEL
                    bcs       INPRL4         Bra if delim found
                    ldb       #$3D                Illegal input format error
                    stb       <ErrCode              Save error code
                    coma                          Set carry
                    puls      pc,x                Restore X & return

INPRL4               stx       <TmpBufCur              Save new current pos in temp buffer
                    clra                          No error
                    puls      pc,x                Restore X & return

***************
* Subroutine INPBYT
* Look for and Convert Integer in 0-255 Range
* Parameters Identical to INPRL
INPBYT               pshs      x                   Preserve X
                    ldx       <TmpBufCur              Get current pos in temp buffer
                    lbsr      ASCNUM               ??? (returns A=var type)
                    bcs       ITYPER
                    cmpa      #1                  Integer?
                    bne       INPIN1         ERR if not
                    tst       1,y           Check msb
                    beq       InprlContinue         in range if zero
                    bra       INPIN1

InpIntImpl               pshs      x
                    ldx       <TmpBufCur              Get current pos in temp buffer
                    lbsr      ASCNUM
                    bcs       ITYPER
                    cmpa      #1                  Integer?
                    beq       InprlContinue               Yes, go back
INPIN1               ldb       #$3A                I/O Type mismatch error
* TO SAVE ROOM, SINCE ERRORS AREN'T CRUCIAL TO SPEED, MAY WANT THIS TO
* BRANCH TO SAME CODE @ InprlContinue
                    stb       <ErrCode
                    coma
                    puls      pc,x

STRINP               pshs      u,x
                    leay      -6,y                Make room for temp var
                    ldu       <ICodeEndPtr
                    stu       1,y                 ??? Save some string ptr
* (orig: INPST2)
                    lda       #4                  Type=String/complex
                    sta       ,y
                    ldx       <TmpBufCur        Get I/O buf ptr
INPST3               lda       ,x+
                    bsr       CheckItemSep         Call delim test
                    bcs       INPST4         Exit move loop if delim
                    sta       ,u+           Move char to str stack
                    bra       INPST3

INPST4               stx       <TmpBufCur
                    lda       #$FF                Flag end of string?
                    sta       ,u+           Store it
                    stu       <StrStkPtr        Update the ptr
                    clra
                    puls      pc,u,x

INPBL               pshs      x
                    leay      -6,y
                    lda       #3
                    sta       ,y            Set TYPE byte
                    clr       2,y           Set res to false
                    ldx       <TmpBufCur
                    bsr       SKPDL1
                    bcs       INPBL4
                    cmpa      #'T
                    beq       INPB25         Bra if so
                    cmpa      #'t           Lower case t?
                    beq       INPB25         Bra if so
                    eora      #$46          It better be false ..
                    anda      #$DF          (or lower case false)
                    beq       INPBL3         Bra if so
                    ldb       #$3A
                    stb       <ErrCode
                    coma
                    puls      pc,x

INPB25               com       2,y
INPBL3               bsr       SKPDEL
                    bcc       INPBL3         Skip until delimiter encountered
INPBL4               stx       <TmpBufCur
                    clra
                    puls      pc,x

SKPDEL               lda       ,x+
                    cmpa      #C$SPAC       is it a space
                    bne       CheckItemSep         Cont check if not
                    bsr       SKPDL1         Process more
                    bcc       SKPDL3         Back up if only spaces found
                    bra       SKPDL4

SKPDL1               lda       ,x+                 Get char
                    cmpa      #C$SPAC             Space?
                    beq       SKPDL1               Yes, ignore & get next char
CheckItemSep               cmpa      <ItemSepChar              Char we are looking for?
                    beq       SKPDL4               Yes, set carry & exit
                    cmpa      #C$CR               Carriage return?
                    beq       SKPDL3               Yes, point X to it, set carry & exit
                    cmpa      #$FF                End of string marker?
                    beq       SKPDL3               Yes, point X to it, set carry & exit
* (orig: NUMOK)
                    andcc     #$FE                Clear carry & return
                    rts

SKPDL3               leax      -1,x
SKPDL4               orcc      #$01
                    rts

INTSTR               pshs      u,x
                    clra
                    sta       3,y
                    sta       <TmpReal1        Clr digit count
                    sta       <TmpReal3        Clr sign flag
                    lda       #$04
                    sta       <UnusedByte7E        Inz loop count
                    ldd       1,y           Get input num
                    bpl       INST2               If positive, skip ahead
                    nega                          NEGD
                    negb
                    sbca      #$00
                    inc       <TmpReal3              Set flag?
***************
* Set Up for Conversion
INST2               leau      >HexOutEntry,pc
***************
* Conversion Loop
INST3               clr       <TmpReal5
                    leau      2,u           Move to new tble entry
INST4               subd      ,u
                    bcs       INST5         Bra if underflow
                    inc       <TmpReal5        Else bump digit
                    bra       INST4         and loop again

INST5               addd      ,u
                    tst       <TmpReal5        Current dig zero?
                    bne       INST6         if not 0 go output
                    tst       $03,y         All 0's so far?
                    beq       INST7         if so suppress this zero
***************
* Output the Current digit
INST6               inc       $03,y
                    pshs      a
                    lda       <TmpReal5        Get the digit
                    lbsr      PUTDIG         Output it
                    puls      a
***************
* Bottom of Conv Loop
INST7               dec       <UnusedByte7E
                    bne       INST3         Loop if more to conv
                    tfr       b,a           Move units to a
                    lbsr      PUTDIG         ..and output it
                    leay      $06,y         Pop old number
                    puls      pc,u,x        All done ..

* NOTE: 6809/6309 mod
***************
* Subroutine RLASC
* Convert real Binary Value to ASCII
* Decimal Representation
* Input: Y - Opstack ptr, number to Convert
*            is Tos.
*        X - Beg Addr for Output String
* Output: X,X+8 = Fraction Part of Result in ASCII
*                 Dp to Left, Zero Filled
*         I.DEXP = Decimal exponent Val (2'S Compl)
*         I.DCNT = number of Significant digits
*                  of Result (1 to 9)
*         Y = Opstack ptr, Top Item Popped
* Local:  D,CC Destroyed
RLASC               pshs      u,x
                    clr       <TmpReal0              Replace with CLRA/CLRB/STD <TmpReal0/STD <TmpReal3/
                    clr       <TmpReal3              STD <TmpReal6 (smaller & faster)
                    clr       <TmpReal7
                    clr       <TmpReal6
                    clr       <TmpReal4
                    clr       <TmpReal1
                    leau      ,x            Copy ptr
                    ldd       #$0A30              Store 10 ASCI 0's at U
CLRBUF               stb       ,u+
                    deca
                    bne       CLRBUF
                    ldd       1,y           real zero?
                    bne       NMASC0         ..no
                    inca
                    lbra      NMAS11         ..yes; skip conversion stuff

***************
* Process Mantissa Sign
NMASC0               ldb       5,y
                    bitb      #$01          Mask sign bit
                    beq       NMASC1         Bra if pos
                    stb       <TmpReal3        Set sign flag
                    andb      #$FE          Strip sign bit
                    stb       5,y           Replace
***************
* Process exponent Sign
NMASC1               ldd       1,y                 If this code is legit, why load D? just A?
                    bpl       NMASC2         Bra if exp positive
                    inc       <TmpReal0        Set neg exp flag
                    nega                    Abs val exponent
NMASC2               cmpa      #3
                    bls       NMASC5         if so no scaling needed
                    ldb       #$9A                (154)
                    mul
                    lsra                    byte/2 is divide by 512
                    nop       WHY                 ARE THESE HERE?
                    nop
                    tfr       a,b           Copy decimal exp to b
                    tst       <TmpReal0        Was exp pos?
                    beq       NMAS35         Bra if so
                    negb                    Compl
NMAS35               stb       <TmpReal4
                    cmpa      #$13          in table range?
                    bls       NmascScaleIn         Bra if in range
                    pshs      a             save exp
* (orig: NMASC4)
                    leau      >RealConvLast,pc     Get addr of 10e+19
                    lbsr      CNVOPR         and mult/div to scale
                    puls      a             Restore exp
                    suba      #$13
NmascScaleIn               leau      >RealConvTable,pc
                    deca                    exp bias
                    ldb       #$05          5 bytes/entry in table
                    mul                     Entry offset
                    leau      d,u           Add to tbl base addr
                    lbsr      CNVOPR         Scale number
***************
* After Scaling, We Must Denornallize N
* So the Binary Residual exponent is
* Exactly Zero for the Bin>Dec Conv To
* Operate Correctly
NMASC5               ldd       2,y
                    tst       1,y           Check sign of bin exp
                    beq       NMASC8         Bra if no adj needed
                    bpl       NMASC7         L shift required
***************
* exp <0 Right Shift to Denorm
NMASC6               lsra
                    rorb
                    ror       $04,y
                    ror       $05,y
                    ror       <TmpReal7        Shift LS bits to extension
                    inc       $01,y
                    bne       NMASC6         Loop til exp=0
                    std       $02,y         Restore msdb on stack
                    bra       NMASC8

***************
* exp > 0 - Left Shift to Denorm
NMASC7               lsl       $05,y
                    rol       $04,y
                    rolb
                    rola
                    rol       <TmpReal6        Shift MS bits into extension
                    dec       $01,y
                    bne       NMASC7         Loop til exp=0
                    std       $02,y         Replace msdb on stack
                    inc       <TmpReal4        Dec exp (decimal)
                    lda       <TmpReal6        Get ext byte
                    bsr       PUTDIG         MS decimal digit out
***************
* Convert Binary Fraction to Decimal by
* Repetitive Mult by 10.  Mult by Shift And
* Add.  Overflow Across Binary Point is the
* next Decimal Place Value.
NMASC8               ldd       $02,y
                    ldu       $04,y
NMASC9               clr       <TmpReal6
                    bsr       MantMul2Long         F*2
                    std       $02,y
                    stu       $04,y         T=f*2
                    pshs      a
                    lda       <TmpReal6
                    sta       <TmpReal7
                    puls      a
                    bsr       MantMul2Long         F*4
                    bsr       MantMul2Long         F*8
                    exg       d,u
                    addd      $04,y
                    exg       d,u
                    adcb      $03,y
                    adca      $02,y         F*2+f*8=f*10
                    pshs      a
                    lda       <TmpReal6        Add carry to ext byte
                    adca      <TmpReal7
                    bsr       PUTDIG         Output decimal digit
                    lda       <TmpReal1
                    cmpa      #$09
                    puls      a
                    beq       NARND0
                    cmpd      #$0000        Loop until value is 0
                    bne       NMASC9
                    cmpu      #$0000
                    bne       NMASC9
***************
* Round to 9 digits based on remainder of conversion divide
NARND0               sta       ,y
                    lda       <TmpReal1
                    cmpa      #$09
                    bcs       NASC10
                    ldb       ,y            remainder >=.5?
                    bpl       NASC10         if so dont round up
NARND1               lda       ,-x
                    inca                    It
                    sta       ,x            Replace it
                    cmpa      #$39          Overflow?
                    bls       NASC10         if not we're done
                    lda       #$30          This digit is zero ..
                    sta       ,x
                    cmpx      ,s            Was it first digit
                    bne       NARND1         if not keep rounding
                    inc       ,x            Make the zero a one
                    inc       <TmpReal4        Adjust dec exp
NASC10               lda       #$09
NMAS11               sta       <TmpReal1
                    leay      6,y           Clean up opstack
                    puls      pc,u,x        - we're finished.

***************
* Subroutine to Conv+ Output Decimal digit
PUTDIG               ora       #$30
                    sta       ,x+           Out in buffer
                    inc       <TmpReal1        Incr digit count
                    rts

MantMul2Long               exg       d,u
                    lslb
                    rola
                    exg       d,u
                    rolb
                    rola
                    rol       <TmpReal6
                    rts

INPLIN               pshs      y,x
                    ldx       <TmpBufBase
                    stx       <TmpBufCur        Reset I/O ptr
                    lda       #$01
                    sta       <TmpBufCount
                    ldy       #$0100        Size of input buffer
                    lda       <CurrChanPath        Input path
                    os9       I$ReadLn
                    bra       OUTLN1         ..return error status

***************
* Subroutine OUTLIN
* Call OS-9 to Write I/O buffer to Console
OUTLIN               pshs      y,x
                    ldd       <TmpBufCur
                    subd      <TmpBufBase
                    beq       OUTLN2
                    tfr       d,y
                    ldx       <TmpBufBase
                    stx       <TmpBufCur        Reset ptr
* (orig: SEEK60)
                    lda       <CurrChanPath        Output path
                    os9       I$WritLn      Write line
OUTLN1               bcc       OUTLN2
                    stb       <ErrCode              Save error code
OUTLN2               puls      pc,y,x

SEEK               pshs      u,x
                    lda       ,y            Get position TYPE
                    cmpa      #$02          What type?
                    beq       SEEK10
                    ldu       $01,y
                    bra       SEEK20

SEEK10               lda       $01,y
                    bgt       SeekPosRange         bra if positive
                    ldu       #$0000        Seek zero
SEEK20               ldx       #$0000
                    bra       SeekIssue

SeekPosRange               ldx       $02,y
                    ldu       $04,y
                    suba      #$20          Seek in range?
                    bcs       SEEK40         bra if so
                    ldb       #$4E          ERR - seek out of range
                    coma                    Carry
                    bra       SEEK70

SEEK40               exg       x,d
                    lsra
                    rorb
                    exg       d,u
                    rora
                    rorb
                    exg       d,x
                    exg       x,u
                    inca                    Up
* (orig: SEEK50)
                    bne       SEEK40
SeekIssue               lda       <CurrChanPath
                    os9       I$Seek
                    bcc       SEEK80
SEEK70               stb       <ErrCode              Save error code
SEEK80               puls      pc,u,x

OUTRL               pshs      u,x
                    leas      -$0A,s        TEMP buffer on stack
                    leax      ,s
                    lbsr      RLASC
                    pshs      x
                    lda       #$09          Trial digit count
                    leax      9,x           Addr of last digit+1
TRLZER               ldb       ,-x
                    cmpb      #$30          is it zero
                    bne       TRLZ2         if not exit ..
                    deca                    digit count
                    cmpa      #$01          Leave one digit min.
                    bne       TRLZER
TRLZ2               sta       <TmpReal1
                    puls      x             Restore digits addr
                    ldb       <TmpReal4        Get decimal exp
                    bgt       RFMTF2         if =>0 number has int part
                    negb                    exp positve
                    tfr       b,a
                    cmpb      #$09
                    bhi       RFMTE2         Cant format in this mode
                    addb      <TmpReal1        Add # signif. digits
                    cmpb      #$09
                    bhi       RFMTE2         Still cant format
                    pshs      a             save exp
                    lbsr      OutSignOrNone         Output sign
                    clra
                    bsr       OutDecimalPt         Output dec. pt.
                    puls      b             Restore exp
                    tstb
                    beq       RFMTF1
                    lbsr      OUTZER         Output string of zeros
RFMTF1               lda       <TmpReal1
                    bra       OutrlMoreFrac

***************
* Convert for Positive exp
RFMTF2               cmpb      #$09
                    bhi       RFMTE2         if not goto e format
                    lbsr      OutSignOrNone         Output sign
                    tfr       b,a
***************
* Free Format real in "E" Format
* (orig: RLFMTE)
                    bsr       OUTZE1         Move frac digits
* (orig: RFMTF3)
                    bsr       OutDecimalPt         Put out d.p
                    lda       <TmpReal1
                    suba      <TmpReal4        Calc # of frac digits
                    bls       RFMTF4         Done if no frac digits
OutrlMoreFrac               bsr       OUTZE1
***************
* Cleanup and Return
RFMTF4               leas      $0A,s
                    clra
                    puls      pc,u,x

RFMTE2               bsr       OutSignOrNone
                    lda       #$01
                    bsr       OUTZE1
                    bsr       OutDecimalPt
* (orig: OUTEXP)
                    lda       <TmpReal1
                    deca                    for first digit
                    bne       OutrlZeroFrc
                    inca                    At least one zero ..
OutrlZeroFrc               bsr       OUTZE1
                    bsr       OutrlExpStr         Cnv+output exp part
                    bra       RFMTF4

OutrlExpStr               lda       #$45
                    bsr       OUTCHR         Output 'e'
                    lda       <TmpReal4        Get exponent
                    deca                    for scaling
                    pshs      a             save exp val
                    bpl       OutrlExpPos
                    neg       ,s            Make it positive for output
* (orig: OUTEX2)
                    bsr       OUTMIN         Output minus sign
                    bra       OUTEX3

OutrlExpPos               bsr       OutPlusSign
OUTEX3               puls      b
                    clra                    is tens val
OUTEX4               subb      #$0A
                    bcs       OUTEX5         Underflow?
                    inca
                    bra       OUTEX4         Loop til converted

OUTEX5               addb      #$0A
                    bsr       OUTDIG         Output tens place
                    tfr       b,a
OUTDIG               adda      #$30
                    bra       OUTCHR         print and exit

OUTZE1               tfr       a,b
                    tstb                    for 0 count
                    beq       MOVDG2
MOVDG1               lda       ,x+
                    bsr       OUTCHR
                    decb
                    bne       MOVDG1
MOVDG2               rts

***************
* Put Space in Output buffer
OUTSP               lda       #$20
                    bra       OUTCHR

OutDecimalPt               lda       #$2E
***************
* Put char in (A) in Outbuf
OUTCHR               pshs      u,a                 Preserve regs
                    leau      <-$40,s             Is stack within 64 bytes of curr. pos in temp buff
                    cmpu      <TmpBufCur        output buffer overflow?
                    bhi       OUTCHR10               No, skip ahead
                    cmpa      #C$CR               Is char we want added a CR?
                    beq       OUTCHR10               Yes, skip ahead
                    lda       #$50                ??? Error code 80? (internal flag byte?)
                    sta       <ErrCode              ??? Save error code 80?
                    sta       <SavedChar              Save here too
                    puls      pc,u,a              Restore regs & return

OUTCHR10               ldu       <TmpBufCur              Get current pos in temp buffer
                    sta       ,u+                 Save char there
                    stu       <TmpBufCur              Save new current pos in temp buffer
                    inc       <TmpBufCount              Inc # active chars in temp buffer
OUTCHR99               puls      pc,u,a              Restore regs & return

***************
* Output Series of Zeros Specified by B
OUTZER               lda       #$30
OutZeroLoop               tstb                          Any chars left to do?
                    beq       OUTZ3               No, exit
OUTZ2               bsr       OUTCHR               Save char (check for size within 64 of stack?)
                    decb                          Done all chars?
                    bne       OUTZ2               No, keep adding chars
OUTZ3               rts

***************
* Output Sign or Space
SGNSPC               tst       <TmpReal3
                    beq       OUTSP
OutSignOrNone               tst       <TmpReal3
                    beq       OUTZ3
***************
* Output Minus char
OUTMIN               lda       #$2D
                    bra       OUTCHR

OutPlusSign               lda       #$2B
                    bra       OUTCHR

MOVSTR               lda       #C$SPAC             Space is fill char
                    bra       OutZeroLoop               Go add B # of spaces to temp buffer

MOVST0               bsr       OUTCHR
OutStrCharLoop               lda       ,x+
                    cmpa      #$FF          End str?
                    bne       MOVST0         ..No; print it
                    rts

OutStrImpl               pshs      x
                    ldx       1,y           Get str addr
OUTST2               bsr       OutStrCharLoop
                    clra
                    puls      pc,x

OUTBL               pshs      x
                    leax      >TrueStr,pc
                    lda       2,y
                    bne       OUTST2
                    leax      >FalseStr,pc     ..otherwise get addr of false
                    bra       OUTST2         and output..

OUTINT               pshs      u,x
                    leas      -5,s          Make TEMP buffer on stack
                    leax      ,s            Get addr of TEMP buffer
                    lbsr      INTSTR         Convert n to ASCII
                    bsr       OutSignOrNone         Output sign if neg
                    lda       <TmpReal1        Get digit count
                    leax      ,s            Restore TEMP buf ptr
                    lbsr      OUTZE1         Copy digits
                    leas      5,s           Clean stack
                    clra
                    puls      pc,u,x

* <JmpVect6 Function 2, sub-function $10 - Add B spaces to temp buffer
* Entry: A=# spaces to append to temp buffer
***************
* Subroutine OUTTAB
* Tab Output buffer to character
* Position Specified by (A)
OUTTAB               tfr       a,b                 Move byte we are working with to B
TAB               pshs      u                   Preserve U
                    ldu       <TmpBufCur              Get ptr to current pos in temp buffer
                    subb      <TmpBufCount              Callers # - # chars active in temp buffer
                    bls       TAB2               If 0 or wraps negative, skip ahead
                    bsr       MOVSTR               Go add chars
TAB2               clra                          No error?
                    puls      pc,u                Restore U & return

***************
* Subroutine SKPZON
* Skip to Beginning of next Tab Zone
SKPZON               lbsr      OUTSP
SKPZ2               lda       <TmpBufCount
                    anda      #$0F          Get 4 ls bits
                    cmpa      #$01          First digit of group?
                    beq       SKIPZ3         if so done ..
                    lbsr      OUTSP         if not output a space
                    bra       SKPZ2

***************
* Subroutine OUTCR
* Put Eol in I/O Buf
OUTCR               lda       #C$CR
                    clr       <TmpBufCount        Reset character count
                    lbsr      OUTCHR
SKIPZ3               clra
                    rts

OUTHEX               pshs      u
                    lda       #$04          Trial field size
                    leau      ,y
                    tst       ,u            First byte zero?
                    bne       OUTHX2         Go output if not
                    asra                    Reduce field
                    leau      1,u
OUTHX2               sta       <FieldWidth
                    tfr       a,b
                    asrb                    digit count
                    lbsr      HEXOUT         Call conv subr
                    puls      pc,u

PRSJST               clrb
                    stb       <FieldJustify        Left is default
                    cmpa      #$3C          Left?
                    beq       PRJST3
                    cmpa      #$3E          Right?
                    bne       PrjstCaret
                    incb
                    bra       PRJST3

PrjstCaret               cmpa      #$5E
                    bne       FDELIM
                    decb
PRJST3               stb       <FieldJustify
                    lda       ,x+           Get next char
FDELIM               cmpa      #$2C
                    beq       FDEL40
                    cmpa      #$FF
                    bne       FDEL15
                    lda       <RptFlag        in a repeat block?
                    beq       FDEL10         bra if not
                    leax      -$01,x        Back up to end string
                    bra       FDEL30

FDEL10               ldx       <FmtEndPtr
                    tst       <RescanFlag        Legal to RESCAN format?
                    beq       FDEL20         ..no; return error
                    clr       <RescanFlag        Set to no RESCAN legal
                    bra       FDEL40

FDEL15               cmpa      #$29
                    beq       FDEL25         bra if so
FDEL20               orcc      #$01
                    rts

FDEL25               lda       <RptFlag
                    beq       FDEL20         Error if not
FDEL30               dec       <RptCount
                    bne       FDEL35         Bra if more to repeat
                    ldu       <SubrStkPtr        Get repeat stack ptr
                    pulu      y,a           Get previous count & beginning ptr
                    sta       <RptCount        Reset previous count
                    sty       <RptBegPtr        Reset repeat beginning
                    stu       <SubrStkPtr        Update repeat stack ptr
                    lda       ,x+           Get next char
                    dec       <RptFlag        Decrement rpt flag
                    bra       FDELIM         Look for another delim

FDEL35               ldx       <RptBegPtr
FDEL40               stx       <FmtScanPtr
                    andcc     #$FE
                    rts

* Print USING format specifiers
PuFmtTblInt               fcc       'I'                 Integer
                    fdb       PrintUsngCheck-PuFmtTblInt
PuFmtTblHex               fcc       'H'                 Hexidecimal
                    fdb       PrintUsngCheck-PuFmtTblHex
PuFmtTblReal               fcc       'R'                 Real
                    fdb       RFMTP-PuFmtTblReal
PuFmtTblExp               fcc       'E'                 Exponential
                    fdb       RFMTP-PuFmtTblExp
PuFmtTblStr               fcc       'S'                 String
                    fdb       PrintUsngCheck-PuFmtTblStr
PuFmtTblBool               fcc       'B'                 Boolean
                    fdb       PrintUsngCheck-PuFmtTblBool
PuFmtTblTab               fcc       'T'                 Tab
                    fdb       TFMTP-PuFmtTblTab
PuFmtTblSpc               fcc       'X'                 Spaces
                    fdb       XFMTP-PuFmtTblSpc
PuFmtTblQuote               fcc       "'"                 Quoted text
                    fdb       QFMTP-PuFmtTblQuote
PuFmtTblEnd               fcb       $00                 End of table marker

* 'T' (tab)
***************
* Tab Format
TFMTP               bsr       FDELIM
                    bcs       RPTERR
                    ldb       <FieldWidth
                    lbsr      TAB
                    bra       NXTFM1

* 'X' (spaces)
XFMTP               bsr       FDELIM
                    bcs       RPTERR
                    ldb       <FieldWidth
                    lbsr      MOVSTR
                    bra       NXTFM1

* '' (quoted text)
QFMTP               cmpa      #$FF                End of string?
                    beq       RPTERR               Yes, skip ahead
                    cmpa      #$27                A single quote (')?
                    bne       QFMTP2               No, skip ahead
                    lda       ,x+
                    bsr       FDELIM
                    bcs       RPTERR
                    bra       NXTFM1

QFMTP2               lbsr      OUTCHR
                    lda       ,x+
                    bra       QFMTP

NXTFMT               pshs      y,x
                    clr       <RescanFlag
                    inc       <RescanFlag        initialize fmt RESCAN flag
NXTFM1               ldx       <FmtScanPtr
                    bsr       FMTNUM         Look for repeat count
                    bcs       NXTFM3         Bra if not found
                    cmpa      #'(                 Repeat char?
                    bne       FmtErr3E         Error if not
                    lda       <RptCount        Get current repeat count
                    stb       <RptCount        save count
                    beq       FmtErr3E         Dont permit zero count
                    inc       <RptFlag        Set flag
                    ldu       <SubrStkPtr        Get repeat stack ptr
                    ldy       <RptBegPtr        Get repeat beginning ptr
                    pshu      y,a           Push count & ptr
                    stu       <SubrStkPtr        Update repeat stack ptr
                    stx       <RptBegPtr        save repeat beginning ptr
* (orig: NXTFM2)
                    lda       ,x+           Get next chr
NXTFM3               leay      <PuFmtTblInt,pc           Point to start of specifiers table
                    clrb                          Init Specifier # to 0
***************
* Decode Table Lookup Loop
NXTFM4               pshs      a                   Preserve original char
                    eora      ,y                  Flip any differing bits
                    anda      #$DF                Mask out uppercase bit
                    puls      a                   Restore original char
                    beq       FmtSpecFound               If char matches, skip ahead
                    leay      3,y                 Point to next table entry
                    incb                          Bump up specifier #
                    tst       ,y                  Are we at the end?
                    bne       NXTFM4               Nope, keep looking
RPTERR               ldb       #$3F                I/O Format Syntax Error
                    bra       FMEXIT               Exit with error

FmtErr3E               ldb       #$3E

FMEXIT               stb       <ErrCode              Save error code
                    coma                          Set carry
                    puls      pc,y,x              Restore regs & return

* Found specifier match
FmtSpecFound               stb       <PrintUsingSpec              Save specifier #
                    ldd       1,y                 Get offset
                    leay      d,y                 Add to base address
                    bsr       FMTNUM               Get up to 3 digit ASCII #'s, convert to binary
                    bcc       NXTFM51               Got it, skip ahead
                    ldb       #$01                None found, force to 1
NXTFM51               stb       <FieldWidth              Save binary version of number
                    jmp       ,y                  Execute PRINT USING specifier routine

* Convert 3 digit ASCII decimal # @ ,X to binary equivalent. Carry clear if
* done, carry set if not ASCII decimal digits present
FMTNUM               bsr       GetAsciiDigit               Go try & get ASCII number 0-9
* NOTE: 6809/6309 MOD, CHANGE TO BCS TO RTS, NOT ORCC/RTS
                    bcs       SetCarryRts               None found, Set carry & exit
                    tfr       a,b                 Move binary digit 0-9 to B
                    bsr       GetAsciiDigit               Try & get another ASCII number 0-9
                    bcs       ClearCarryRts               Couldn't, exit with carry clear anyways
                    bsr       BLDNUM               Convert 2 digit # into binary version (D)
                    bsr       GetAsciiDigit               Try & get another ASCII number 0-9
                    bcs       ClearCarryRts               Couldn't, exit with carry clear anyways
                    bsr       BLDNUM               Convert this digit & add to previous total
                    tsta                          result <255? (useless, ADCA should set flags)
                    beq       FMTNM2               Yes, get next char & exit with carry clear
                    clrb                          Force result to 256
FMTNM2               lda       ,x+                 Get next char
                    bra       ClearCarryRts               Exit with carry clear

GetAsciiDigit               lda       ,x+                 Get char
CHKDIG               cmpa      #'0                 If not ASCII 0-9, exit with carry set
                    blo       SetCarryRts               (Same as BCS)
                    cmpa      #'9
                    bhi       BADNUM
                    suba      #$30                If it is 0-9, convert to binary & exit with
ClearCarryRts               andcc     #$FE                carry clear
                    rts

BADNUM               orcc      #$01
SetCarryRts               rts

* Entry: A=LSB of ASCII 0-9 converted to binary, B=MSB
* IF NOT CALLED BY OTHER ROUTINES USING IT, MAY WANT TO USE DP LOCATION 14
* INSTEAD OF STACK
BLDNUM               pshs      a                   Save Low nibble?
                    lda       #10                 Multiply B by 10
                    mul
                    addb      ,s+                 Add to saved nibble
                    adca      #$00                possible carry into D
                    rts

RFMTP               cmpa      #'.
                    bne       RPTERR
                    bsr       FMTNUM         Find frac field size
                    bcs       RPTERR
                    stb       <FracFieldSz        save frac size

PrintUsngCheck               lbsr      PRSJST
                    bcs       RPTERR         bra if error
                    puls      y,x           Restore registers
                    inc       <RescanFlag        Fmt rescanning legal now
EXCFMT               ldb       <PrintUsingSpec
                    lbeq      I.FMT         0=integer fmt
                    decb
                    beq       HexFmtImpl         1=hex fmt
                    decb
                    lbeq      R.FMT
                    decb
                    lbeq      ExpFmtImpl
                    decb
                    lbeq      S.FMT
                    lbra      BoolFmtImpl         5=bool fmt

HexFmtImpl               jsr       <JmpOpcode
                    cmpa      #4                  Numeric?
                    blo       H.FMT4               Yes, skip ahead
                    ldu       1,y                 Get ptr to string data
                    clrb                          Clear count=0
H.FMT2               lda       ,u+                 Get char from string
                    cmpa      #$FF                EOS?
                    beq       H.FMT3               Yes, skip ahead
                    incb                          Bump up count
                    bne       H.FMT2               Do until EOS or 256 chars
H.FMT3               ldu       1,y                 Get string ptr again
                    bra       HEXOUT               Skip ahead with U=ptr to string, B=size of string

***************
* Check Types
H.FMT4               leau      1,y
                    lda       ,y                  Get var type
                    cmpa      #2                  Real #?
                    bne       H.FMT6               No, skip ahead
                    ldb       #5                  Yes, force size to 5 bytes
                    bra       HEXOUT

H.FMT6               cmpa      #1                  Integer?
                    bne       HexFmt1Byte               No, skip ahead
                    ldb       #2                  Yes, size=2 bytes
                    cmpb      <FieldWidth              Same or less than ???
                    blo       HexFmtStart               Yes, leave as 2
HexFmt1Byte               ldb       #1                  Anything else (BYTE/BOOLEAN) is 1 byte
                    leau      1,u           Set ptr to result
HexFmtStart               tfr       b,a
                    lsla
                    cmpa      <FieldWidth        Too many for field?
                    bhi       HexStartByte         ..yes; skip 1st half of first byte
HEXOUT               tst       <FieldJustify
                    beq       HEXO10         ..left justify
                    bmi       HexCenterJust
                    pshs      b
                    lslb
                    pshs      b                   SUBR
                    ldb       <FieldWidth
                    subb      ,s+
                    blo       HEXO05
                    bra       HEXO03

HexCenterJust               pshs      b
                    lslb
                    pshs      b
                    ldb       <FieldWidth
                    subb      ,s+
                    bcs       HEXO05
                    asrb
HEXO03               pshs      b
                    lda       <FieldWidth        Decrement field width
                    suba      ,s+           by number of leading spaces
                    sta       <FieldWidth
                    lbsr      MOVSTR
HEXO05               puls      b
HEXO10               lda       ,u
                    lsra
                    lsra                    MS nybble right
                    lsra
                    lsra
                    bsr       HEXCHR         Output it
                    beq       HEXO90         Exit if fld full
HexStartByte               lda       ,u+
                    bsr       HEXCHR
                    beq       HEXO90         Also exit if full
                    decb                    bytecnt
                    bne       HEXO10
                    ldb       <FieldWidth
                    lbsr      MOVSTR
HEXO90               clra
                    rts

***************
* Form Single Hex char + Output
HEXCHR               anda      #$0F
                    cmpa      #$09          Check range
                    bls       HXCHR2
                    adda      #$07          Adj for A-F
HXCHR2               lbsr      OUTDIG
                    dec       <FieldWidth        Decr fld width
                    rts

***************
* Return Format Mismatch Error
FMSMAT               coma
                    rts

I.FMT               jsr       <JmpOpcode
                    cmpa      #$02          What TYPE result?
                    bcs       I.FMT1         Not str if error
                    bne       FMSMAT         bra if not real
                    lbsr      CallVect5FnC         Convert to integer
I.FMT1               pshs      u,x
                    leas      -5,s
                    leax      ,s
                    lbsr      INTSTR         Call the master conv subr
                    ldb       <FieldWidth        Get fld width
                    decb                    One for sign
                    subb      <TmpReal1        then # digits in result
                    bpl       IntFmtJustify         Keep going if fld big enough
                    leas      5,s           Pop old buffer
                    puls      u,x           then regs
                    lbra      FillAsterisks         Go fill it with *** + rts

***************
* Decode Justification
IntFmtJustify               tst       <FieldJustify
                    beq       IntFmtLeft         0=left
                    bmi       IntFmtCenter
                    lbsr      MOVSTR
                    lbsr      SGNSPC         Sign or space
                    bra       IntFmtSignDone

***************
* Right Justify, Zero Fill
IntFmtLeft               lbsr      SGNSPC
                    pshs      b             save fill count
                    lda       <TmpReal1
                    lbsr      OUTZE1
                    puls      b
                    lbsr      MOVSTR         Now the fill
                    bra       IntFmtClean

IntFmtCenter               lbsr      SGNSPC
                    lbsr      OUTZER
IntFmtSignDone               lda       <TmpReal1
                    lbsr      OUTZE1
IntFmtClean               leas      5,s
                    clra
                    puls      pc,u,x

BoolFmtImpl               jsr       <JmpOpcode              Go get var type
                    cmpa      #3                  Boolean?
                    bne       FMSMAT               No, set carry & exit
                    pshs      u,x                 Preserve regs
                    leax      >TrueStr,pc           Point to 'True'
                    ldb       #4                  Size of 'True'
                    lda       2,y                 Get boolean value
                    bne       S.FMT1               $FF is true, so skip ahead
                    leax      >FalseStr,pc           Point to 'False'
                    ldb       #5                  Size of 'False'
                    bra       S.FMT1               Go deal with it

S.FMT               jsr       <JmpOpcode              Go get var type
                    cmpa      #4                  String?
                    bne       FMSMAT               No, exit with carry set
                    pshs      u,x                 Preserve regs
                    ldx       1,y                 Get ptr to string
                    ldd       <StrStkPtr        String Stack ptr
                    subd      1,y           (D)=length of string
                    subd      #1            Don't count eos byte
                    tsta                    than 255 bytes?
                    bne       S.FMT2         ..Yes; too large
S.FMT1               cmpb      <FieldWidth
                    bls       S.FMT3         ..No; continue
S.FMT2               ldb       <FieldWidth
S.FMT3               tfr       b,a
                    negb
                    addb      <FieldWidth        ..Length from field size
                    tst       <FieldJustify        check justify TYPE
                    beq       StrFmtLeft         0=left
                    bmi       S.FMTC         -1=centered
***************
* Left Justify
* (orig: S.FMTL)
                    pshs      a             save length
                    lbsr      MOVSTR         Do the fill
                    puls      a
                    lbsr      OUTZE1         Move it out
                    bra       S.FMTX

StrFmtLeft               pshs      b
                    bra       StrFmtOutput

***************
* Center Justify
S.FMTC               lsrb
                    bcc       S.FMT4         Was it odd?
                    incb                    Add extra char to trailing fill
S.FMT4               pshs      d
                    lbsr      MOVSTR
                    puls      a
StrFmtOutput               lbsr      OUTZE1
                    puls      b             Pop the trailing fill count
                    lbsr      MOVSTR
S.FMTX               clra
                    puls      pc,u,x

R.FMT               jsr       <JmpOpcode              Go get var type
                    cmpa      #2                  Real?
                    beq       R.FMT1               Yes, skip ahead
                    lbcc      FMSMAT               If carry clear, set carry & exit
                    lbsr      CallVect5FnE2               ??? possible convert?
R.FMT1               pshs      u,x
                    leas      -$0A,s
                    leax      ,s
                    lbsr      RLASC         Call the main conversion routine
                    lda       <TmpReal4        Get dec exp val
                    cmpa      #$09          exp must be <10e+10
                    bgt       R.FMTE         Error if bigger
                    lbsr      RNDRL         Call rounding subr
                    lda       <FieldWidth        Get total field size
                    suba      #$02
                    bmi       R.FMTE
                    suba      <FracFieldSz
                    bmi       R.FMTE
                    suba      <IntFieldSz
                    bpl       R.FMT2
***************
* Error Exit When Impossible to Format: Clean Up Stack +
* Call Routine to Fill Field With Asterisks
R.FMTE               leas      $0A,s
                    puls      u,x
                    bra       FillAsterisks         Exit to error filler

***************
* Decode Justification Mode and bra to Formatter Routines
R.FMT2               sta       <FmtTotalFld
                    leax      ,s            Restore buffer ptr
                    ldb       <FieldJustify        Get justify code
                    beq       RealFmtLeft         O=left justify
                    bmi       OUTRNS         -1=center justify(money)
***************
* Left Justify, Leading Sign, Trailing Space Fill
* (orig: R.FMTL)
                    bsr       SPCFIL
***************
* Center (Financial) Justify: Right Justify, Space Fill, Trailing Sign/Space
* (orig: R.FMTC)
                    bsr       RealFmtSignOut
                    bra       R.FMTX

RealFmtLeft               bsr       RealFmtSignOut
                    bsr       SPCFIL
                    bra       R.FMTX

OUTRNS               bsr       SPCFIL
                    bsr       OUTRN
                    lbsr      SGNSPC
***************
* Common Cleanup/Return
R.FMTX               leas      $0A,s
                    clra
                    puls      pc,u,x

RealFmtSignOut               lbsr      SGNSPC
OUTRN               lda       <IntFieldSz
                    lbsr      OUTZE1
                    lbsr      OutDecimalPt         then decimal point
                    ldb       <TmpReal4        Get decimal exponent
                    bpl       OutfpFracDigits         No problem if positive
                    negb
                    cmpb      <FracFieldSz        to many for field?
                    bls       OUTRN1         ..no
                    ldb       <FracFieldSz
OUTRN1               pshs      b
                    lbsr      OUTZER         Output leading zeroes
                    ldb       <FracFieldSz
                    subb      ,s+           Adjust field size for number of zeros printed
                    stb       <FracFieldSz
                    lda       <FracDigitCnt        Get fraction digit count
                    cmpa      <FracFieldSz        Too many for rest of field?
* 6809/6309 MOD: SHOULD BE BLS OUTFP2
                    bls       OUTRN2         ..no
***************
* Output Floation Point number Elements
* (orig: OUTFPN)
                    lda       <FracFieldSz
OUTRN2               bra       OUTFP2

***************
* Output Space-Fill field
SPCFIL               ldb       <FmtTotalFld
                    lbra      MOVSTR         Go do it

OUTFP0               lbsr      SGNSPC
                    lda       <IntFieldSz        Get int field size
                    lbsr      OUTZE1
                    lbsr      OutDecimalPt
OutfpFracDigits               lda       <FracDigitCnt
OUTFP2               lbsr      OUTZE1
                    ldb       <FracFieldSz        Get frac field size
                    subb      <FracDigitCnt        Subtract #signif.
                    ble       BADRTS         Skip fill if <=0
* (orig: OUTFP9)
                    lbra      OUTZER         Output trailing zero fill for rest of field

FillAsterisks               ldb       <FieldWidth
                    lda       #$2A                * (?)
                    lbsr      OutZeroLoop         Print the astericks
                    clra
BADRTS               rts

ExpFmtImpl               jsr       <JmpOpcode              Go get variable type
                    cmpa      #2                  Real?
                    beq       E.FMT0               Yes, skip ahead
                    lbcc      FMSMAT               If carry clear, set carry & exit
                    lbsr      CallVect5FnE2               ??? Convert to real?
E.FMT0               pshs      u,x
                    leas      -$0A,s
                    leax      ,s
                    lbsr      RLASC         Call the general conversion subr
                    lda       <TmpReal4        Get decimal exponent
                    pshs      a             save it
                    lda       #1            Force exponent=1
                    sta       <TmpReal4
                    bsr       RNDRL         Call the rounder
                    puls      a             Restore previous exp (adjusted)
* (orig: E.FMT1)
                    ldb       <TmpReal4
                    cmpb      #1
                    beq       ExpFmtIntDig         Skip if digits didnt shift
                    inca
ExpFmtIntDig               ldb       #1
                    stb       <IntFieldSz        Force one int digit
                    sta       <TmpReal4
                    lda       <FieldWidth        Get total field size
                    suba      #6
                    bmi       ExpFmtErr
                    suba      <FracFieldSz
                    bmi       ExpFmtErr
                    suba      <IntFieldSz
                    bpl       E.FMT2
ExpFmtErr               leas      $0A,s
                    puls      u,x
                    bra       FillAsterisks

E.FMT2               sta       <FmtTotalFld
                    ldb       <FieldJustify
                    beq       ExpFmtLeft
                    bsr       SPCFIL
                    bsr       OUTFP0         Do number+sign
                    lbsr      OutrlExpStr
                    bra       E.FMTX

ExpFmtLeft               bsr       OUTFP0
                    lbsr      OutrlExpStr         Do the exponent
***************
* Common Cleanup/Exit
E.FMTX               lbra      R.FMTX

RNDRL               pshs      x                   Save ptr to beginning of string number
                    lda       <TmpReal4        Get decimal exponent
                    adda      <FracFieldSz        Add # frac digits needed
                    bne       RNDRL1         >>begin patch
                    lda       ,x
                    cmpa      #$35
                    bcc       RndrlCarryZero
RNDRL1               deca                    Adjust for offset
                    bmi       ENDRND         if negative its out of range
                    cmpa      #$07
                    bhi       ENDRND         High range check
                    leax      a,x           Move ptr to ronded digit
                    ldb       1,x           and get next LS digit
                    cmpb      #$35          Five or greater?
                    blo       ENDRND         Don't round if so
***************
* Here to Round Up
RNDRL2               inc       ,x                  Inc ASCII digit
                    ldb       ,x                  Get digit
                    cmpb      #'9                 Past 9?
                    bls       ENDRND               No, skip ahead
RndrlCarryZero               ldb       #'0                 Wrap to 0
                    stb       ,x
                    leax      -1,x                Bump ptr back
                    cmpx      ,s                  Hit beginning of text string yet?
                    bhs       RNDRL2               No, loop back & continue
                    ldx       ,s                  Get beginning of text string ptr
                    leax      8,x                 Point 8 bytes past start
RNDRL3               lda       ,-x                 Block move bytes from 0-6 to 1-7
                    sta       1,x           Move it right
                    cmpx      ,s                  Done moving?
                    bhi       RNDRL3               No, keep going until done
                    lda       #'1                 Force 1st digit to 1
                    sta       ,x
                    inc       <TmpReal4        and adjust exponent
ENDRND               puls      x                   Get string ptr back
                    lda       <TmpReal4        Get dec exp
                    bpl       IPART
                    clra                    Part=0 if neg exp
IPART               sta       <IntFieldSz
                    nega
                    adda      #$09          Compute frac size
                    bpl       FPART
                    clra
FPART               cmpa      <FracFieldSz
                    bls       FPART2
                    lda       <FracFieldSz        Use whatever is smaller
FPART2               sta       <FracDigitCnt
                    rts

***************
* Unimplemented routine error
*  currently used for: Status
UNIMPL               ldb       #48                 Unimplemented routine error
                    stb       <ErrCode              Save error code
                    coma                          Exit with error
                    rts

				ifne		wildbits
BannerGo            leax      NEWLN,pcr
                    ldy       #NEWLNLEN
                    lda       #1
                    os9       I$Writln
                    bcs       BNRERR
                    leax      OUTSTR,pcr
                    ldy       #STRLEN
                    lda       #1
                    os9       I$Write
                    bcs       BNRERR
                    ldx       #$FE00
                    lda       7,x
                    cmpa      #$02
                    bne       isItK
                    leax      OUTSTR2,pcr
                    ldy       #STRLEN2
                    lda       #1
                    os9       I$Writln
                    bcs       BNRERR
                    bra       CONT
isItK           cmpa      #$12
                    bne       isItK2
                    leax      OUTSTR3,pcr
                    ldy       #STRLEN3
                    lda       #1
                    os9       I$Writln
                    bcs       BNRERR
                    bra       CONT
isItK2          cmpa      #$16
                    bne       isItJrJr
                    leax      OUTSTR4,pcr
                    ldy       #STRLEN4
                    lda       #1
                    os9       I$Writln
                    bcs       BNRERR
                    bra       CONT
isItJrJr            cmpa      #$1A
                    bne       BNRERR
                    leax      OUTSTR5,pcr
                    ldy       #STRLEN5
                    lda       #1
                    os9       I$Writln
                    bcs       BNRERR
CONT                leax      BASL2,pcr
                    ldy       #BASLEN2
                    lda       #1
                    os9       I$Write
                    bcs       BNRERR
BNRDONE                ldb       #0
BNRERR               lbra      COMAND
OUTSTR              fcb       $1b,$32,$07,$1c,$13,$1c,$11,$1c,$11
                    fcb       $1c,$11,$1c,$11,$1c,$11,$1c,$05
                    fcb       $1b,$32,$06,$20,$20,$1b,$32,$08,$1c,$10,$1c,$11
                    fcb       $1c,$11,$1c,$11,$1c,$0a,$1b,$32,$06,$20,$20
                    fcb       $1b,$32,$04,$1c,$03,$1c,$11,$1c,$11,$1c,$11,$1c
                    fcb       $11,$1c,$11,$1c,$05
                    fcb       $1b,$32,$06,$20,$1b,$32,$0e,$1c,$11,$1c,$12,$1b,$32,$06
                    fcb       $20,$1b,$32,$05,$1c,$03,$1c,$11,$1c,$11,$1c,$11,$1c,$11
                    fcb       $1c,$05
                    fcb       $1b,$32,$06,$20,$20,$1b,$32,$0f,$1c,$10,$1c,$11
                    fcb       $1c,$11,$1c,$11,$1c,$11,$1c,$11,$1c,$0a
                    fcb       $1b,$32,$06,$20,$20
                    fcb       $1b,$32,$01,$1c,$03,$1c,$11,$1c,$11,$1c,$11,$1c,$11
                    fcb       $1c,$05
                    fcb       $1b,$32,$06,$20,$20,$20,$20,$20,$20,$20,$20
                    fcb       $1b,$32,$01
STRLEN              equ       *-OUTSTR
OUTSTR2             fcc       " Wildbits/Jr"
                    fcb       $0D
STRLEN2             equ       *-OUTSTR2
OUTSTR3             fcc       "  Wildbits/K"
                    fcb       $0D
STRLEN3             equ       *-OUTSTR3
OUTSTR4             fcc       "Wildbits/K2"
                    fcb       $0D
STRLEN4             equ       *-OUTSTR4
OUTSTR5             fcc       "Wildbits/Jr2"
                    fcb       $0D
STRLEN5             equ       *-OUTSTR5
BASL2               fcb       $1b,$32,$07,$1c,$13,$1c,$11,$1b,$32,$06,$20,$20
                    fcb       $20,$1b,$32,$07,$1c,$13,$1c,$11,$1b,$32,$06,$20
                    fcb       $1b,$32,$08,$1c,$10,$1c,$11,$1c,$15,$1b,$32,$06,$20
                    fcb       $1b,$32,$08,$1c,$09,$1c,$11,$1c,$0a,$1b,$32,$06,$20
                    fcb       $1b,$32,$04,$1c,$11,$1c,$12,$1b,$32,$06,$20,$20
                    fcb       $20,$20,$20,$20,$1b,$32,$0e,$1c,$11,$1c,$12,$1b
                    fcb       $32,$06,$20,$1b,$32,$05,$1c,$11,$1c,$12,$1b,$32
                    fcb       $06,$20,$20,$20,$20,$20,$20,$1b,$32,$0f
                    fcb       $1c,$11,$1c,$0c,$1b,$32,$06,$20,$1b,$32,$0f,$1c,$10
                    fcb       $1c,$15,$1c,$0f,$1c,$11,$1b,$32,$06,$20,$20,$1b,$32
                    fcb       $01,$1c,$11,$1c,$12
                    fcb       $1b,$32,$06,$20,$20,$1b,$32,$01,$1c,$13,$1c,$11
                    fcb       $1b,$32,$06,$20,$20,$20,$20,$20,$20,$20
                    fcb       $20,$20,$20,$20,$20,$20,$20,$20,$20,$20
                    fcb       $20,$20,$20,$20,$20,$20,$20,$20,$20,$20
                    fcb       $20,$20,$20
                    fcb       $1b,$32,$07,$1c,$13,$1c,$11,$1c,$11,$1c
                    fcb       $11,$1c,$11,$1c,$11,$1c,$0b
                    fcb       $1b,$32,$06,$20,$1b,$32,$08,$1c,$11,$1c,$11,$1c,$11
                    fcb       $1c,$11,$1c,$11,$1c,$11,$1c,$11
                    fcb       $1b,$32,$06,$20,$1b,$32,$04
                    fcb       $1c,$04,$1c,$11,$1c,$11,$1c,$11,$1c,$11
                    fcb       $1c,$11,$1c,$05,$1b,$32
                    fcb       $06,$20,$1b,$32,$0e,$1c,$11,$1c,$12,$1b,$32,$06
                    fcb       $20,$1b,$32,$05,$1c,$11,$1c,$12,$1b,$32,$06,$20
                    fcb       $20,$20,$20,$20,$20,$1b,$32,$0f,$1c,$11,$1c,$12
                    fcb       $1b,$32,$0f,$1c,$10,$1c,$11,$1c,$15,$1c,$13,$1c,$11
                    fcb       $1b,$32,$06,$20,$20,$1b,$32,$01,$1c,$04,$1c,$11,$1c,$11
                    fcb       $1c,$11,$1c,$11,$1c,$11,$1b,$32,$06,$20,$20,$20,$20,$20
                    fcb       $20,$20,$20,$20,$20,$1b,$32,$01,$40,$44
                    fcb       $72,$50,$69,$74,$72,$65,$1b,$32,$06,$20,$20
                    fcb       $20,$20,$20,$20,$20,$20,$20,$20,$20,$20
                    fcb       $1b,$32,$07,$1c,$13,$1c,$11,$1b,$32,$06,$20,$20
                    fcb       $20,$1b,$32,$07,$1c,$13,$1c,$11,$1b,$32,$06,$20
                    fcb       $1b,$32,$08,$1c,$11,$1c,$11,$1b,$32,$06,$20,$20
                    fcb       $20,$1b,$32,$08,$1c,$11,$1c,$11,$1b,$32,$06,$20
                    fcb       $20,$20,$20,$20,$20,$1b,$32,$04,$1c,$13,$1c,$11
                    fcb       $1b,$32,$06,$20,$1b,$32,$0e,$1c,$11,$1c,$12,$1b
                    fcb       $32,$06,$20,$1b,$32,$05,$1c,$11,$1c,$12,$1b,$32
                    fcb       $06,$20,$20,$20,$20,$20,$20,$1b,$32,$0f
                    fcb       $1c,$11,$1c,$0e,$1c,$10,$1c,$15,$1b,$32,$06,$20
                    fcb       $1b,$32,$0f,$1c,$0d,$1c,$11,$1b,$32,$06,$20,$20
                    fcb       $20,$20,$20,$20,$1b,$32,$01,$1c,$13,$1c,$11
                    fcb       $1b,$32,$06,$20,$20,$20,$20,$20,$1b,$32,$01,$40,$4a,$46
                    fcb       $65,$64,$20,$40,$4E,$69,$74,$72,$6f,$62,$6f,$74,$69
                    fcb       $63,$73,$1b,$32,$06
                    fcb       $20,$20,$20,$20,$20,$20,$20
                    fcb       $1b,$32,$07,$1c,$13,$1c,$11,$1c,$11,$1c
                    fcb       $11,$1c,$11,$1c,$11,$1c,$06
                    fcb       $1b,$32,$06,$20,$1b,$32,$08,$1c,$11,$1c,$15
                    fcb       $1b,$32,$06,$20,$20,$20,$1b,$32,$08,$1c,$09
                    fcb       $1c,$11,$1b,$32,$06,$20,$1b,$32,$04,$1c,$07,$1c,$11
                    fcb       $1c,$11,$1c,$11,$1c,$11,$1c,$11,$1c,$06
                    fcb       $1b,$32,$06,$20,$1b
                    fcb       $32,$0e,$1c,$11,$1c,$12,$1b,$32,$06,$20,$1b,$32
                    fcb       $05,$1c,$04,$1c,$11,$1c,$11,$1c,$11,$1c,$11,$1c,$06
                    fcb       $1b,$32,$06
                    fcb       $20,$20,$1b,$32,$0f,$1c,$09,$1c,$11,$1c,$11,$1c,$11
                    fcb       $1c,$11,$1c,$11,$1c,$15,$1b,$32,$06,$20,$20,$1b,$32
                    fcb       $01,$1c,$07,$1c,$11,$1c,$11,$1c,$11,$1c,$11,$1c,$06
                    fcb       $1b,$32,$06,$20,$20,$20,$20,$20,$20,$20,$20,$1b,$32
                    fcb       $01,$40,$4d,$61,$74,$74,$20,$4d,$61,$73
                    fcb       $73,$69,$65,$1b,$32,$01
BASLEN2             equ       *-BASL2
NEWLN               fcb       $1b,$33,$06,$0c,$0d
NEWLNLEN            equ	*-NEWLN
				endc

                    emod
eom                 equ       *
                    end
