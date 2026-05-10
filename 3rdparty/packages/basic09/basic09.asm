********************************************************************
* Basic09 - BASIC for OS-9
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  18      1982/10/13  Robert F. Doggett (Microware)
* "PROGRAM" literal changed to "Program"
* Formatted strings could exceed field size
* Formatted boolean output phrases reversed
*  18      1982/10/18  Robert F. Doggett (Microware)
* Assembly subroutine errors now recognized
*  18      1982/10/19  Robert F. Doggett (Microware)
* Mem directive fixed to take more than 32k
* ------------------------------------------------------------------
*  19      1982/11/02  Robert F. Doggett (Microware)
* Default USING field size 1 if unspecified
* Prevent death on out of range input
*  19      1982/11/16  Robert F. Doggett (Microware)
* Compiler var "CNTASS" initialized to fix random crash if T.CXAS inserted by mistake
* Mem comand made to request 1 less byte
* ------------------------------------------------------------------
*  20      1983/01/12  Robert F. Doggett (Microware)
* Changed string terminator from $FF to $00, allowing 8-bit data in string functions
*  20      1983/01/17  Microware
* General clean up
*  20      1983/01/19  Robert F. Doggett (Microware)
* Changed string terminator from $00 to $FF to maintain I-Code compatability
*  20      1983/01/21  Robert F. Doggett (Microware)
* Fixed problem in USING with Real Zero
*  20      1983/01/24  Robert F. Doggett (Microware)
* Struct assignment of exactly 256 crashed
* Rename any Proc to number crashed system
*  20      1983/01/25  Robert F. Doggett (Microware)
* Startup now clears all DP Globals
* IOBuff could overflow into system stack
*  20      1983/02/07  Larry Crane (Microware)
* Kept Opstack from going crazy, killing system when exponentiation overflow occurred
*  20      1983/02/10  Robert F. Doggett (Microware)
* Added conditional asm for Tandy ^N
* Prevented DEBUG mode from recursive entry
*  20      1983/02/15  Robert F. Doggett (Microware)
* Made aborted RunB return error to Shell
*  20      1983/02/17  Robert F. Doggett (Microware)
* Added Microware to copyright notice
* CTL-Q was ignored in asm subroutines
* RunB ON ERROR now intercepts CTL-C, CTL-Q
* ------------------------------------------------------------------
*  21      1983/03/16  Robert F. Doggett (Microware)
* Fixed bug in TRON caused in edition 20
* ------------------------------------------------------------------
*  22      1983/04/27  Robert F. Doggett (Microware)
* Added conditionals for Basic09 minus trig
*  22      1983/05/26  MGH (Microware)
* Changed message printed on tandy version
*  22      1983/06/28  MGH (Microware)
* Added conditionals for dragon startup msg
* ------------------------------------------------------------------
*  22      2002/10/09  Boisy G. Pitre
* Obtained from Curtis Boyle, marked V1.1.0.
*
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
* ------------------------------------------------------------------
*  V1.21   1994/06/17  NitrOS-9 Project
* Changed intercept routine @ INTCPT: Replaced LSL <u0034/COMA/
*            ROR <u0034/RTI with OIM #$80,<u0034/RTI/NOP/NOP
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
*  V1.21   1994/06/22  NitrOS-9 Project
* Changed L0DBB (reset temp buffer to empty state) to use PSHS D
* LDA #1 / STA <u007D / LDD <u0080 / STD <u0082 / PULS PC,D
*            (saves 5 cycles) ALSO WORKS AS 6809 MOD
* Changed BEQ L08E3 to BEQ L08E5 @ RUNCMD (Std in for commands)
* Changed numerous CLRA/CLRB and COMA/COMB to CLRD & COMD respectiv
*            just to shorten source
*  V1.21   1994/06/27  NitrOS-9 Project
* Added 2nd TFM to init routine to clear out $400-$4ff
*  V1.21   1994/06/28  NitrOS-9 Project
* Changed BRA OUTCHR99 @ OUTCHR to PULS PC,U,A (6809 TOO)
*  V1.21   1994/12/22  NitrOS-9 Project
* BIG TEST: TOOK OUT NOP'D CODE - SEE IF IT STILL WORKS
* IT DOESN'T - MOVED ALL NOPS TO JUST BEFORE ICPT ROUTINE TO
*            SEE IF THE SEPARATION OF CODE & DATA MAKES A DIFFERENCE
* THIS APPEARS TO WORK...THEREFORE, SOME REFERENCES TO THE DATA
*            AT THE BEGINNING OF BASIC09 IS STILL BEING REFERRED TO BY OFFSETS
*            IN THE CODE, THAT HAVE NOT BEEN FIXED UP YET.
*  V1.21   1994/12/23  NitrOS-9 Project
* AFTER FIXING L03F0 TABLE, ATTEMPTED TO REMOVE 'TEST'
*  V1.21   1994/12/28  NitrOS-9 Project
* Worked, changed 16 bit,pc's to 8 bit,pc's @:
*            L0DFC  leax INTRTS,pc  *
*            L1436  leax L1434,pc  *
*            L15B3  leax L15AA,pc  *
*            L1B97  leax L1B93,pc  *  (Doesn't seem to be referenced)
*            SYSSUB  leax L39DA,pc  *
*            L4751  leax L474D,pc  *
*            L479F  leax L479A,pc  *
*            CNOR20  leax L4805,pc  *
*            L4B03  leau L4AF4,pc  *
*            L4B0A  leau L4AF9,pc  *
*            NXTFM3  leax L5723,pc  *
*  V1.21   1995/01/03  NitrOS-9 Project
* Changed a ChgDir @ CHDSTM to do it in READ mode, not UPDATE
*  V1.21   1995/01/04  NitrOS-9 Project
* Changed L0C18 - 3 CLR ,Y+ to LEAY 3,Y
*            Changed LEAU ,Y / STD ,--U / STA ,-U to LEAU -3,y/STD ,u/
*              STD 2,u
* Changed LDA #$02 / LDB #SS.Size to LDD #$02*256+SS.Size @ OPNCH0
*              (create output file)
* Replaced BEQ L2D17 @ L2D0B with BEQ POPE30, removed L2D17 altog-
*            ether, change LBSR ERIET @ L2D0B with LBRA ERIET
*  V1.21   1995/01/09  NitrOS-9 Project
* Attempted to change both CLRA/CLRB (CLRD)'s @ DIRLN1 to CLRA for
*            F$Load/F$Link (since neither require B)
* Changed DEFILE frm LBSR L12CF to LBSR L1371
* Changed L12CF from LDA #C$CR/LBRA L1373 to LBRA L1371
*  V1.21   1995/01/12  NitrOS-9 Project
* Attempted to remove LDD <U002F / ADDD $F,x @ L1A2E, move TFR
*            D,Y to earlier in code when [u002F]+($F,x) is calculated
*  V1.21   1995/01/17  NitrOS-9 Project
* Removed useless CMPB #$00 @ L1E9B
* Moved L1FF5 label to an earlier RTS, removed original (saves 1 by
* Removed useless CMPA #$00 @ L2115
*  V1.21   1995/01/19  NitrOS-9 Project
* Changed STB <u00A4 / STA <u00A3 to STD <u00A3 @ L236A
* Changed LDA <u00A3/CMPA <u00A3 to LDA <u00A3/ORCC #Zero @ L218E
*             (1 cycle faster)
* Changed NAMSY1: took out LEAY -1,y, added BRA L2453 (saves 2 cycle
*             from original method)
*  V1.21   1995/01/20  NitrOS-9 Project
* Changed L1B09 from to auto-inc Y, skip LEAY 1,Y entirely, & chang
*            LEAY 5,Y to LEAY 4,Y (+2 cyc if [,y]=$4F, but -3 cyc on any other
*            value)
* Changed L1B6D: changed CLRA / LDB D,X to to ABX / LDB ,X (3 cyc
*            faster on 6809/2 cyc faster on 6309)
* Mod @ PRSLF: Changed LBSR NAMSYM to LBSR L2432 (just did
*            L245D call, and 2nd call to it will return same Y anyways)
* Changed CLR ,Y+ to STB ,Y+ @ ADDSYM
* Attempted to move L2368 routine to just before PRSHEX routine to
*            change LBRA OUTCOD to BRA OUTCOD. Changed L23EC from LBRA L236A to
*            STD <u00A3 / BRA OUTCOD
* Changed LBHS PBEXPR / BRA L27CE @ PDECL3 to BLO L27CE / LBRA PBEXPR
* Attempted Mod @ L2D2C - Changed LEAX B,X to ABX
*  V1.21   1995/01/23  NitrOS-9 Project
* Made following mods involving L2E3B routine:
*            Changed CMPA #0 to TSTA, reversed L2EDC's LDA <u00D1 & LEAY 3,Y
*            so TSTA not needed, changed BRA L2E3B to BRA L2E41 @: L2E89,
*            L2E8F, PSLIT, PADDR1. Changed BRA L2E3B to BRA L2E3C @ L2EDC
* Changed LDA #1 to INCA @ L2E3B (since A=0 at this point)
* Took out CMPA #0, changed LDD #$0060 to LDB #$60 @ L2EE3
* Changed TST <u00D0 to LDA <u00D0 (saves 2 cyc) and following 4
*            lines @ L2F5E to version on right (+1 byte, -5 cycles):
*            lda #5             ldd #$ffff
*            sta <u00D1         std <u00D4
*            ldd #$ffff         lda #5
*            bra CHKV90          sta <u00D1
*              (std <u00D4/     rts
*               lda <u00D1/rts
*  V1.21   1995/01/31  NitrOS-9 Project
* Moved L308D to just before ERROR (eliminates LBRA)
*  V1.21   1995/02/03  NitrOS-9 Project
* Changed LBRA L1EC9 @ ARRNA9 to LBRA PRSLF (saves extra LBRA, saves
*            5/4 cycles)
*  V1.21   1995/02/13  NitrOS-9 Project
* Moved JSR <u001B / FCB 8 from L3C29 to just after SUBFNC to change
*            LBSR to BSR
*  V1.21   1995/02/14  NitrOS-9 Project
* Moved 3 text strings that are only referred to once to their res-
*            pective routines in the code: L07AA to near L1882, L078B to near
*            L198A, and L0799 to L1211
* Moved JSR <u001E / FCB 4 from L010A to after RUNC20 (called twice
*            from just before here)
* Attempted to move JSR <u001E / fcb 2 from L010D to just before
*            L0AC3 (change some LBSR's to BSR's)
* Moved L0110 (JSR <u001E / fcb 0) to just before INTE30
* Moved L0113 (JSR <u0021 / fcb 0) to just before INTE30
*  V1.21   1995/02/15  NitrOS-9 Project
* Moved L0116 (JSR <u0024 / fcb 0) to just after START15
* Moved L0119 (JSR <u0024 / fcb 0) to just after L0DFC
* Moved L011C (JSR <u0024 / fcb 2) to just after L0DFC
* Moved L011F (JSR <u002A / fcb 2) to just after L1394
* Moved L0122 (JSR <u001E / fcb A) to just before L1606
* Moved L0125 (JSR <u001E / fcb 6) to just after L19D1
* Moved L0128 (JSR <u001E / fcb 6) to just after DUMP
* Moved L012B (JSR <u0021 / fcb 6) to just after L110A
* Moved L012E (JSR <u0021 / fcb 4) to just after L119E
* REMARKED OUT L0131 JSR VECTOR - NOT CALLED IN BASIC09
* Moved L0134 (JSR <u0024 / fcb C) to just after L104E
* Moved L0137 (JSR <u0024 / fcb 8) to just after L119E
* Moved L013A (JSR <u002A / fcb 0) to just after L175A
* Moved L1CC1 (JSR <u001B / fcb 2) to just after L1E1C
* Moved L1CC4 (JSR <u001B / fcb 4) to just after PRTLIN
* Moved L1CC7 (JSR <u001B / fcb 6) to replace LBRA L1CC7 @ L1E1C
*            & embedded JSR <u001B/fcb 4 @ L2428 since LBRA, not LBSR
* Moved L1CCA (JSR <u002A / fcb 0) to just after PRSHEX
* Moved L1CCD (JSR <u001B / fcb $12) to just after ERMRP9
* Took out 2nd TST <u0035 / BNE L194C @ L191C
* Eliminated L2572 since duplicate of L1CC1, & not speed crucial
* Eliminated L2575 since duplicate of L1CC7, changed LBRA L2575 @
*            PBEXPR to LBRA L1CC7
*  V1.21   1995/02/16  NitrOS-9 Project
* Moved L2578 (JSR <u001B / fcb $14) to end of L2FDA (replacing
*            LBRA to it)
* Moved L257B (JSR <u001E / fcb 8) to end of L3069
* Moved L257E (JSR <u001E / fcb 6) to end of DONE50
* Eliminated L3206 since duplicate of L1CC7, changed 3 LBRA calls
*            to it to go to L1CC7 instead (saves 3 bytes)
* Moved L3209 to just after table @ L323F, changed table entry from
*            L35F0 to L3209, eliminated L35F0 LBRA entirely
* Moved SYSSTM (JSR <u001B / fcb $E) to end of CHNSTM
*  V1.21   1995/02/24  NitrOS-9 Project
* Eliminated L320F since dupe of L1CC1, change appropriate LBSR's @
*            EXCER4 & DEBUG
* Moved L3212 (JSR <u001B / fcb 0) to end of L3A89
*  V1.21   1995/02/27  NitrOS-9 Project
* Moved L3215 (JSR <u001B / fcb $A) to end of L3BF3
* Moved L3218 (JSR <u001B / fcb $10) to end of BASSTM
* Took out L321B (JSR <u001E/fcb 6), replaced LBRA to it @ POKSTM
*            with JSR/fcb
* Moved L321E (JSR <u0027/fcb 4) to end of NXTRL1
* Moved L3221 (JSR <u0027/fcb $A) to end of NXTRLA
* Moved L3224 (JSR <u0027/fcb 2) to before L3A8A, and moved 2 lines
*            from L35BB to here too)
* Moved ASGSTM (JSR <u0027/fcb $C) to after L381C
* Moved L322A (JSR <u0027/fcb $E) to after L381C
* Moved L322D (JSR <u0027/fcb 0) to after L3BFF
* Moved L3230 (JSR <u002A/fcb 2), even though dupe of L011F, to
*            after ASGVAR
*  V1.21   1995/02/28  NitrOS-9 Project
* Embedded L3233 (JSR <u001B/fcb $18) @ L35F3 & DEBUG, changed LBSR
*            @ STMLUP to point to L35F3 version
* Moved L3236 (JSR <u001B/fcb $16) to after L3391
* L3239 (JSR <u001B/fcb $1A) is NEVER CALLED IN BASIC09.
*            Removed L3239 entirely
* Embedded L323C (JSR <u001B/fcb $1C) @ FORSTM since LBRA
* Changed LDB #0 @ L388F to CLRB
* Embedded L3C2C (JSR <u0024/fcb 6 (error handler)) @ L3DD5,CMPTRU,
*            L3F2E,L44C2,L458C,FPOVRF,L4FC7) Moved it to just after L40CC.
* Changed LDB #0 @ L4409 to CLRB (part of Boolean routines)
* Changed LDB #0 @ L5046 to CLRB
* Removed L3C2F (dupe of L011F), changed LBSR's @ L471F & STRF10 to
*            it
* Moved L3C32 to after INIT1 (shorten LEAX)
*  V1.21   1995/03/01  NitrOS-9 Project
* Modified Integer Multiply to use MULD @ INML25
*  V1.21   1995/03/10  NitrOS-9 Project
* Modified Negate of REAL #'s to use EIM @ NEGRL (saves 4 cyc)
* Changed L3FBB (Real add with dest var=0) to use LDQ/STQ (saves
*            6 cyc)
*  V1.21   1995/03/13  NitrOS-9 Project
* Changed NEGA/NEGB/SBCA #0 to NEGD @ FLOAT1 & FIX4A
* Changed BPL L451E to BPL L451F @ FLOAT1 (eliminates 2nd useless
*            TSTA)
*  V1.21   1995/03/15  NitrOS-9 Project
* Changed LDB $B,y/ANDB #$FE/STB $B,y & LDB 5,y/ANDB #$FE/STB $B,y
*            to AIM's @ L3FE5 (Real Add & Subtract)
* Changed ADCB 3,y/ADCA 2,y to ADCD 2,y @ L4039 (Real Add/Subtact)
* Changed SBCB 3,y/SBCA 2,y TO SBCD 2,y @ L400B (Real Add/Subtact)
* Changed LDA 5,y/ANDA #$FE/STA 5,y to AIM #$FE,5,y @ ABSFNR (ABS
*            for real #'s
* Changed NEGA/NEGB/SBCA #0 to NEGD @ L45B5 (ABS for Integers)
* Ditched special checks for 0 or 2 in Integer Multiply (INMUL),
*            since overhead from checks is as slow or slower as straight MULD
*            except in dest. var=0's case
*  V1.21   1995/03/16  NitrOS-9 Project
* Changed 2 LDD/STD's @ L3F93 to LDQ/STQ
*  V1.21   1995/03/18  NitrOS-9 Project
* Changed Integer Divide (and MOD) routines to use DIVQ
*  V1.21   1995/03/20  NitrOS-9 Project
* Changed L3F7C (copy Real # to temp var from inc'd X) to use
*            LDQ/STQ/LDB #4/ABX
* Moved Integer MOD routine (INDV10) to nearer divide (changes LBSR
*            to BSR)
*  V1.21   1995/04/23  NitrOS-9 Project
* Changed Real Add/Subtract mantissa shift (L4082-L40C9) to use
*            <u0014 (unused in BASIC09) to hold shift count instead of stack
*            (saves 2 cyc for STA vs. PSHS, saves 1 cyc per DEC, & saves 5 cyc
*            by eliminating LEAS 1,s) (6809)
*  V1.21   1995/04/26  NitrOS-9 Project
* Split real add/subtract out & made two versions: 6809 & 6309
*  V1.21   1995/06/09  NitrOS-9 Project
* Modified 6309 REAL add/subtract routine - now 13-15% faster
*  V1.21   1995/06/20  NitrOS-9 Project
* Took out useless LDB 2,s @ L412D (Real Multiply)
*  V1.21   1995/07/18  NitrOS-9 Project
* Changed sign fix in Real Add @ L4071 to use TFR w,d/lsrb/lslb/orb
*            ,y/std $a,y
* Split real multiply out & made two versions: 6809 & 6309
*  V1.21   1995/08/11  NitrOS-9 Project
* Removed useless LEAS 1,s in Init routine
* Split real divide out & made two versions: 6809 & 6309
*  V1.21   1995/08/15  NitrOS-9 Project
* Removed useless: STA <u00BD in start, useless CLR <u0035 @ START05,
*            Changed LDD #1 to LDB #1/STD <u002D to STB <u002E in start, and
*            START05/START15 routine to use W instead of stack for base address
* Changed 'bye <CR>' buffer fill @ L08E5 to use LDQ/STQ
*  V1.21   1995/11/12  NitrOS-9 Project
* Changed NXTIN1 to use INCD instead of ADDD #1 (NEXT Integer STEP 1
* Changed NXTINT to TFR A,E instead of PSHS A, changed TST ,S+ to
*            TSTE (NEXT Integer STEP <>1)
*  V1.21   1995/11/16  NitrOS-9 Project
* Changed to L345E (REAL NEXT STEP 1) to do direct call to REAL add
*            routine (changed BSR L321E/BSR FORSTM to LBSR L3FB1)
* As per above, changed same call @ NXTRL (REAL NEXT STEP <>1), and
*            eliminated L321E completely
* @ NXTRL1 & NXTRL2, eliminated L3221 calls, replaced BSR L3221's
*            with LBSR RLCMP (Real Compare) (in REAL NEXT, both cases)
*  V1.21   1995/11/25  NitrOS-9 Project
* Remove L50A1 & L509E (calls to REAL Multiply & REAL divide),
*            changed CNVOPR to call them directly (prints exponents?)
*  V1.21   1995/11/30  NitrOS-9 Project
* Changed RUNS30 to use SUBR (saves 1 byte/9 cyc on RUN (mlsub)
*  V1.21   1995/12/05  NitrOS-9 Project
* Changed L3A48 (called by REM) to use ABX instead of CLRA/LEAX D,X
*            (used to jump ahead in I-Code to skip remark text)
* Attempted to just move L33DF (NEXT) & L34E5 (FOR) Tables to just
*            after L3446 for 8 bit offsets - also removed LSLB @ L33EA
*  V1.21   1995/02/12  NitrOS-9 Project
* Changed routines around BADNUM to skip ORCC if not necessary (blo&
*            bcs)
* Changed LEAX to 8 bit from 16 @ CIRCOR
*  V1.21   2014/06/07  RG (NitrOS-9 Project)
* Changed Date$ to conform with Y2K changes in F$Time
********************************

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

u0000               rmb       2                   Start of data memory / DP pointer
u0002               rmb       2                   Size of Data area (including DP)
u0004               rmb       2                   Ptr to list of Modules in BASIC09 workspace ($400)
u0006               rmb       1                   ??? NEVER REFERENCED (possibly leftover from RUNB)
u0007               rmb       1                   ??? NEVER REFERENCED
u0008               rmb       2                   Ptr to start of I-code workspace
u000A               rmb       2                   # bytes used by all programs for code in user workspace
* Data area sizes are taken from module headers Permanent storage size ($B-$C)
u000C               rmb       2                   Bytes free in BASIC09 workspace for user
u000E               rmb       2                   Ptr to jump table (L323F only) - Only used from L3D4A
u0010               rmb       2                   Inited to L3CB5 (jump table)
u0012               rmb       2                   Inited to L3D35 (jump table)
u0014               rmb       1                   ??? NEVER REFERENCED
u0015               rmb       1                   ??? NEVER REFERENCED
u0016               rmb       1                   JMP ($7e) instruction
u0017               rmb       2                   Address for above (inited to EVAL)
u0019               rmb       2                   Inited to L3C32 (JSR <u001B / FCB $1A)
* The following vectors all contain a JMP >$xxxx set up from the module header
u001B               rmb       3                   Jump vector #1  (Inited to L00DC)
u001E               rmb       3                   Jump vector #2  (Inited to L1CA5)
u0021               rmb       3                   Jump vector #3  (Inited to PLREF)
u0024               rmb       3                   Jump vector #4  (Inited to L31E8)
u0027               rmb       3                   Jump vector #5  (Inited to L3C09)
u002A               rmb       3                   Jump vector #6  (Inited to L5084)
u002D               rmb       1                   Standard Input path # (Inited to 0)
u002E               rmb       1                   Standard Output path # (inited to 1)
u002F               rmb       2                   Ptr to start of 'current' module in BASIC09 workspace
u0031               rmb       2                   Ptr to start of variable storage
u0033               rmb       1
u0034               rmb       1                   Flag: if high bit set, signal has been receieved
u0035               rmb       1                   Last signal received
u0036               rmb       1                   Error code
u0037               rmb       2
u0039               rmb       1
u003A               rmb       1
u003B               rmb       1
u003C               rmb       1
u003D               rmb       1
u003E               rmb       1
u003F               rmb       1
u0040               rmb       2
u0042               rmb       1
u0043               rmb       1
* Next 2 are variable ptrs of some sort, temporary? Permanent?
u0044               rmb       2                   Inited to $300 (some table that is built backwards)
u0046               rmb       2                   Inited to $300
u0048               rmb       1
u0049               rmb       1
u004A               rmb       2                   Ptr to end of currently used I-code workspace+1
u004C               rmb       1
u004D               rmb       1
u004E               rmb       2
u0050               rmb       1                   Inited to $0e
u0051               rmb       1                   Inited to $12
u0052               rmb       1                   Inited to $14
u0053               rmb       1                   Inited to $A2
u0054               rmb       1                   Inited to $BB
u0055               rmb       1                   Inited to $40
u0056               rmb       1                   Inited to $E6
u0057               rmb       1                   Inited to $2D
u0058               rmb       1                   Inited to $36
u0059               rmb       1                   Inited to $19
u005A               rmb       2                   Inited to $62E9
u005C               rmb       2
u005E               rmb       2                   Absolute exec address of basic09 module in memory
u0060               rmb       2                   Absolute address of $F offset in basic09 mod in mem
u0062               rmb       2                   Absolute address of $D offset in basic09 mod in mem
u0064               rmb       2                   ??? Size of module-$D,x in mod hdr + 3
u0066               rmb       1
u0067               rmb       1
u0068               rmb       1
u0069               rmb       1
u006A               rmb       1
u006B               rmb       1
u006C               rmb       1
u006D               rmb       1
u006E               rmb       1
u006F               rmb       1
u0070               rmb       2
u0072               rmb       2
u0074               rmb       1
u0075               rmb       1
u0076               rmb       1
u0077               rmb       1
u0078               rmb       1
u0079               rmb       1
u007A               rmb       1
u007B               rmb       1
u007C               rmb       1
u007D               rmb       1                   Current # chars active in temp buffer ($100-$1ff)
u007E               rmb       1
u007F               rmb       1
u0080               rmb       2                   Pointer to start of temp buffer ($100)
u0082               rmb       2                   Pointer to current position in temp buffer ($100-$1ff)
u0084               rmb       1
* For u0085, the following applies:
* 0=Integer, 1=Hex, 2=Real, 3=Exponential, 4=String, 5=Boolean, 6=Tab,
* 7=Spaces, 8=Quoted text
u0085               rmb       1                   Specifier # for print using
u0086               rmb       1
u0087               rmb       1
u0088               rmb       1
u0089               rmb       1
u008A               rmb       1
u008B               rmb       1
u008C               rmb       2
u008E               rmb       2
u0090               rmb       1
u0091               rmb       1
u0092               rmb       2
u0094               rmb       1
u0095               rmb       1
u0096               rmb       1
u0097               rmb       1
u0098               rmb       1
u0099               rmb       1
u009A               rmb       1
u009B               rmb       1
u009C               rmb       1
u009D               rmb       1
u009E               rmb       2                   Ptr to current command table (normally L0140)
u00A0               rmb       1                   ??? Flag of some sort?
u00A1               rmb       2
u00A3               rmb       1                   Token # from command table
u00A4               rmb       1                   Command type (flags?) from command table
u00A5               rmb       1                   Flag type of name string (2=Non variable)
u00A6               rmb       1                   Size of current string/variable name (includes '$' on strings)
u00A7               rmb       2                   Ptr to end of name string+1
u00A9               rmb       2                   ??? Ptr of some sort
u00AB               rmb       2                   Ptr to current line I-code end
u00AD               rmb       2                   ??? Dupe of above
u00AF               rmb       2                   ??? duped from AB @ L1F90
u00B1               rmb       2
u00B3               rmb       2                   # steps to do (debug mode from STEP command)
u00B5               rmb       2
u00B7               rmb       2
u00B9               rmb       1
u00BA               rmb       1
u00BB               rmb       1                   ??? (inited to 0 at during load process)
u00BC               rmb       1
u00BD               rmb       1                   (inited to 0) - Path # of newly opened path
u00BE               rmb       1                   I$Dup path # for duplicate of error path
u00BF               rmb       2
u00C1               rmb       2
u00C3               rmb       2
u00C5               rmb       1
u00C6               rmb       1
u00C7               rmb       1
u00C8               rmb       2
u00CA               rmb       1
u00CB               rmb       1
u00CC               rmb       1
u00CD               rmb       1
u00CE               rmb       1
u00CF               rmb       1
u00D0               rmb       1
u00D1               rmb       1                   Some sort of variable type
u00D2               rmb       2
u00D4               rmb       2
u00D6               rmb       2                   Size of var in bytes (from u00D1)
u00D8               rmb       1
u00D9               rmb       1                   Inited to 1
u00DA               rmb       1
u00DB               rmb       1
u00DC               rmb       1
u00DD               rmb       1
u00DE               rmb       1
u00DF               rmb       1
u00E0               rmb       1
u00E1               rmb       1
u00E2               rmb       2
u00E4               rmb       1
u00E5               rmb       1
u00E6               rmb       2
u00E8               rmb       2
u00EA               rmb       1
u00EB               rmb       4
u00EF               rmb       3
u00F2               rmb       1
u00F3               rmb       6
u00F9               rmb       1
u00FA               rmb       4
u00FE               rmb       1
u00FF               rmb       1
u0100               rmb       $100                256 byte temporary buffer for various things
u0200               rmb       $100                ??? ($200-$2ff) built backwards 2 bytes/time
u0300               rmb       $100                BASIC09 stack area ($300-$3ff)
u0400               rmb       $100                List of module ptrs (modules in BASIC09 workspace)
u0500               rmb       $100                I-Code buffer (for running)
u0600               rmb       $2000-.             Default buffer for BASIC09 programs & data
size                equ       .

* Jump tables installed at $1b in DP: in form of JMP to (address of BASIC09's
* header in memory + 2 byte in table). In other words, jump to LXXXX
L000D               fdb       L00DC               $1b jump vector
                    fdb       L1CA5               $1e jump vector
                    fdb       PLREF               $21 jump vector
                    fdb       L31E8               $24 jump vector
                    fdb       L3C09               $27 jump vector
                    fdb       L5084               $2A jump vector
                    fdb       $0000               End of jump vector table marker

name                fcs       /Basic09/

L0022               fdb       $1607               Edition #22 ($16)

* Intro screen

                    ifne      wildbits
L0024               fcb       $0A
				else
L0024               fcb       $0C
L0025               fcc       '            BASIC09'
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
L00DC               pshs      x,d                 Preserve regs
                    ldb       [<$04,s]            Get function offset
                    leax      <L00EC,pc           Point to vector table
                    ldd       b,x                 Get return offset
                    leax      d,x                 Point to return address
                    stx       $4,s                Change RTS address to it
                    puls      d,x,pc              restore regs and return to new address

* Vector offsets for above routine ($1B vector)

L00EC               fdb       DIRLNK-L00EC         Function 0
                    fdb       L1287-L00EC         Function 2   Print error message (B=Error code)
                    fdb       SETEXT-L00EC         Function 4
                    fdb       EXIT-L00EC         Function 6
                    fdb       L18BE-L00EC         Function 8
                    fdb       KILLEX-L00EC         Function A
                    fdb       BYEBYE-L00EC         Function C
                    fdb       KILALL-L00EC         Function E
                    fdb       L1BA2-L00EC         Function 10
                    fdb       L12F9-L00EC         Function 12
                    fdb       L19B1-L00EC         Function 14
                    fdb       L110C-L00EC         Function 16
                    fdb       L1026-L00EC         Function 18
                    fdb       L10AC-L00EC         Function 1A (Pointed to by <u0019 & <u0017)
                    fdb       L10B1-L00EC         Function 1C

* UNUSED IN BASIC09
*L0131    jsr   <u0024
*         fcb   $0A

* token/command type & command list?
                    fdb       114                 # entries in table
                    fcb       2                   # bytes to start text

L0140               fdb       $0101
L0142               fcs       'PARAM'
                    fdb       $0201
L0149               fcs       'TYPE'
                    fdb       $0301
L014F               fcs       'DIM'
                    fdb       $0401
L0154               fcs       'DATA'
                    fdb       $0501
L015A               fcs       'STOP'
                    fdb       $0601
L0160               fcs       'BYE'
                    fdb       $0701
L0165               fcs       'TRON'
                    fdb       $0801
L016B               fcs       'TROFF'
                    fdb       $0901
L0172               fcs       'PAUSE'
                    fdb       $0A01
L0179               fcs       'DEG'
                    fdb       $0B01
L017E               fcs       'RAD'
                    fdb       $0C01
L0183               fcs       'RETURN'
                    fdb       $0D01
L018B               fcs       'LET'
                    fdb       $0F01
L0190               fcs       'POKE'
                    fdb       $1001
L0196               fcs       'IF'
                    fdb       $1101
L019A               fcs       'ELSE'
                    fdb       $1201
L01A0               fcs       'ENDIF'
                    fdb       $1301
L01A7               fcs       'FOR'
                    fdb       $1401
L01AC               fcs       'NEXT'
                    fdb       $1501
L01B2               fcs       'WHILE'
                    fdb       $1601
L01B9               fcs       'ENDWHILE'
                    fdb       $1701
L01C3               fcs       'REPEAT'
                    fdb       $1801
L01CB               fcs       'UNTIL'
                    fdb       $1901
L01D2               fcs       'LOOP'
                    fdb       $1A01
L01D8               fcs       'ENDLOOP'
                    fdb       $1B01
L01E1               fcs       'EXITIF'
                    fdb       $1C01
L01E9               fcs       'ENDEXIT'
                    fdb       $1D01
L01F2               fcs       'ON'
                    fdb       $1E01
L01F6               fcs       'ERROR'
                    fdb       $1F01
L01FD               fcs       'GOTO'
                    fdb       $2101
L0203               fcs       'GOSUB'
                    fdb       $2301
L020A               fcs       'RUN'
                    fdb       $2401
L020F               fcs       'KILL'
                    fdb       $2501
L0215               fcs       'INPUT'
                    fdb       $2601
L021C               fcs       'PRINT'
                    fdb       $2701
L0223               fcs       'CHD'
                    fdb       $2801
L0228               fcs       'CHX'
                    fdb       $2901
L022D               fcs       'CREATE'
                    fdb       $2A01
L0235               fcs       'OPEN'
                    fdb       $2B01
L023B               fcs       'SEEK'
                    fdb       $2C01
L0241               fcs       'READ'
                    fdb       $2D01
L0247               fcs       'WRITE'
                    fdb       $2E01
L024E               fcs       'GET'
                    fdb       $2F01
L0253               fcs       'PUT'
                    fdb       $3001
L0258               fcs       'CLOSE'
                    fdb       $3101
L025F               fcs       'RESTORE'
                    fdb       $3201
L0268               fcs       'DELETE'
                    fdb       $3301
L0270               fcs       'CHAIN'
                    fdb       $3401
L0277               fcs       'SHELL'
                    fdb       $3501
L027E               fcs       'BASE'
                    fdb       $3701
L0284               fcs       'REM'
                    fdb       $3901
L0289               fcs       'END'
                    fdb       $4003
L028E               fcs       'BYTE'
                    fdb       $4103
L0294               fcs       'INTEGER'
                    fdb       $4203
L029D               fcs       'REAL'
                    fdb       $4303
L02A3               fcs       'BOOLEAN'
                    fdb       $4403
L02AC               fcs       'STRING'
                    fdb       $4503
L02B4               fcs       'THEN'
                    fdb       $4603
L02BA               fcs       'TO'
                    fdb       $4703
L02BE               fcs       'STEP'
                    fdb       $4803
L02C4               fcs       'DO'
                    fdb       $4903
L02C8               fcs       'USING'
                    fdb       $3D03
L02CF               fcs       'PROCEDURE'
                    fdb       $9204
L02DA               fcs       'ADDR'
                    fdb       $9404
L02E0               fcs       'SIZE'
                    fdb       $9604
L02E6               fcs       'POS'
                    fdb       $9704
L02EB               fcs       'ERR'
                    fdb       $9804
L02F0               fcs       'MOD'
                    fdb       $9A04
L02F5               fcs       'RND'
                    fdb       $9C04
L02FA               fcs       'SUBSTR'
                    fdb       $9B04
L0302               fcs       'PI'
                    fdb       $9F04
L0306               fcs       'SIN'
                    fdb       $A004
L030B               fcs       'COS'
                    fdb       $A104
L0310               fcs       'TAN'
                    fdb       $A204
L0315               fcs       'ASN'
                    fdb       $A304
L031A               fcs       'ACS'
                    fdb       $A404
L031F               fcs       'ATN'
                    fdb       $A504
L0324               fcs       'EXP'
                    fdb       $A804
L0329               fcs       'LOG'
                    fdb       $A904
L032E               fcs       'LOG10'
                    fdb       $9D04
L0335               fcs       'SGN'
                    fdb       $A604
L033A               fcs       'ABS'
                    fdb       $AA04
L033F               fcs       'SQRT'
                    fdb       $AA04
L0345               fcs       'SQR'
                    fdb       $AC04
L034A               fcs       'INT'
                    fdb       $AE04
L034F               fcs       'FIX'
                    fdb       $B004
L0354               fcs       'FLOAT'
                    fdb       $B204
L035B               fcs       'SQ'
                    fdb       $B404
L035F               fcs       'PEEK'
                    fdb       $B504
L0365               fcs       'LNOT'
                    fdb       $B604
L036B               fcs       'VAL'
                    fdb       $B704
L0370               fcs       'LEN'
                    fdb       $B804
L0375               fcs       'ASC'
                    fdb       $B904
L037A               fcs       'LAND'
                    fdb       $BA04
L0380               fcs       'LOR'
                    fdb       $BB04
L0385               fcs       'LXOR'
                    fdb       $BC04
L038B               fcs       'TRUE'
                    fdb       $BD04
L0391               fcs       'FALSE'
                    fdb       $BE04
L0398               fcs       'EOF'
                    fdb       $BF04
L039D               fcs       'TRIM$'
                    fdb       $C004
L03A4               fcs       'MID$'
                    fdb       $C104
L03AA               fcs       'LEFT$'
                    fdb       $C204
L03B1               fcs       'RIGHT$'
                    fdb       $C304
L03B9               fcs       'CHR$'
                    fdb       $C404
L03BF               fcs       'STR$'
                    fdb       $C604
L03C5               fcs       'DATE$'
                    fdb       $C704
L03CC               fcs       'TAB'
                    fdb       $CD05
L03D1               fcs       'NOT'
                    fdb       $D005
L03D6               fcs       'AND'
                    fdb       $D105
L03DB               fcs       'OR'
                    fdb       $D205
L03DF               fcs       'XOR'
                    fdb       $F703
L03E4               fcs       'UPDATE'
                    fdb       $f803
L03EC               fcs       'EXEC'
                    fdb       $f903
L03F2               fcs       'DIR'

* 3 byte packets used by <u001B calls - Function $12
* 1st byte is used for bit tests, bytes 2-3 are offset from 2nd byte (can be
*   jump address, others seem to be ptrs to text)
L03F5               fcb       $40                 ???
                    fdb       $0000
* label for reference only - remove after all are verified as correct

                    fcb       $00                 ???
                    fdb       L0142-*             PARAM ($fd49)

                    fcb       $00
                    fdb       L0149-*             TYPE  ($fd4d)

                    fcb       $00
                    fdb       L014F-*             DIM   ($fd50)

                    fcb       $00
                    fdb       L0154-*             DATA  ($fd52)

                    fcb       $00
                    fdb       L015A-*             STOP  ($fd55)

                    fcb       $00
                    fdb       L0160-*             BYE   ($fd58)

                    fcb       $00
                    fdb       L0165-*             TRON  ($fd5a)

                    fcb       $00
                    fdb       L016B-*             TROFF ($fd5d)

                    fcb       $00
                    fdb       L0172-*             PAUSE ($fd61)

                    fcb       $00
                    fdb       L0179-*             DEG   ($fd65)

                    fcb       $00
                    fdb       L017E-*             RAD   ($fd67)

                    fcb       $00
                    fdb       L0183-*             RETURN ($fd69)

                    fcb       $00
                    fdb       L018B-*             LET    ($fd6e)

                    fcb       $40                 ???
                    fdb       $0000

                    fcb       $00
                    fdb       L0190-*             POKE   ($fd6d)

                    fcb       $00
                    fdb       L0196-*             IF     ($fd70)

                    fcb       $63
                    fdb       L019A-*             ELSE   ($fd71)

                    fcb       $02
                    fdb       L01A0-*             ENDIF  ($fd74)

                    fcb       $01
                    fdb       L01A7-*             FOR    ($fd78)

                    fcb       $22
                    fdb       L1419-*             (something with NEXT in it) ($0fe7)

                    fcb       $01
                    fdb       L01B2-*             WHILE ($fd7d)

                    fcb       $62
                    fdb       L01B9-*             ENDWHILE ($fd81)

                    fcb       $01
                    fdb       L01C3-*             REPEAT ($fd88)

                    fcb       $02
                    fdb       L01CB-*             UNTIL ($fd8d)

                    fcb       $01
                    fdb       L01D2-*             LOOP ($fd91)

                    fcb       $62
                    fdb       L01D8-*             ENDLOOP ($fd94)

                    fcb       $02
                    fdb       L01E1-*             EXITIF ($fd9a)

                    fcb       $63
                    fdb       L01E9-*             ENDEXIT ($fd9f)

                    fcb       $00
                    fdb       L01F2-*             ON ($fda5)

                    fcb       $00
                    fdb       L01F6-*             ERROR ($fda6)

                    fcb       $20
                    fdb       L13C9-*             Point to something with GOTO ($0f76)

                    fcb       $20
                    fdb       L13C9-*             Point to something with GOTO ($0f73)

                    fcb       $20
                    fdb       L13C3-*             Point to something with GOSUB ($0f6a)

                    fcb       $20
                    fdb       L13C3-*             Point to something with GOSUB ($0f67)

                    fcb       $20
                    fdb       L140F-*             Point to something with RUN ($0fb0)

                    fcb       $00
                    fdb       L020F-*             KILL ($fdad)

                    fcb       $00
                    fdb       L0215-*             INPUT ($fdb0)

                    fcb       $00
                    fdb       L021C-*             PRINT ($fdb4)

                    fcb       $00
                    fdb       L0223-*             CHD ($fdb8)

                    fcb       $00
                    fdb       L0228-*             CHX ($fdba)

                    fcb       $00
                    fdb       L022D-*             CREATE ($fdbc)

                    fcb       $00
                    fdb       L0235-*             OPEN ($fdc1)

                    fcb       $00
                    fdb       L023B-*             SEEK ($fdc4)

                    fcb       $00
                    fdb       L0241-*             READ ($fdc7)

                    fcb       $00
                    fdb       L0247-*             WRITE ($fdca)

                    fcb       $00
                    fdb       L024E-*             GET ($fdce)

                    fcb       $00
                    fdb       L0253-*             PUT ($fdd0)

                    fcb       $00
                    fdb       L0258-*             CLOSE ($fdd2)

                    fcb       $00
                    fdb       L025F-*             RESTORE ($fdd6)

                    fcb       $00
                    fdb       L0268-*             DELETE ($fddc)

                    fcb       $00
                    fdb       L0270-*             CHAIN ($fde1)

                    fcb       $00
                    fdb       L0277-*             SHELL ($fde5)

                    fcb       $20
                    fdb       L1402-*             Points to something with BASE ($0f6d)

                    fcb       $20
                    fdb       L1402-*             Points to something with BASE ($0f6a)

                    fcb       $20
                    fdb       L143C-*             Points to something with REM ($0fa1)

                    fcb       $20
                    fdb       L1436-*             Points to something with (* ($0f98)

                    fcb       $00
                    fdb       L0289-*             END ($fde8)

                    fcb       $20
                    fdb       L13CF-*             ??? end of goto/gosub routine ($0f2b)

                    fcb       $20
                    fdb       L13CF-*             ??? end of goto/gosub routine ($0f28)

                    fcb       $40                 ???
                    fdb       $0000

                    fcb       $20
                    fdb       L1443-*             ??? end of REM routine ($0f96)

                    fcb       $40
                    fcc       ' \'                Command statement separator literal

                    fcb       $20
                    fdb       L12D4-*             ??? ($0e21)

                    fcb       $10
                    fdb       L028E-*             BYTE ($fdd8)

                    fcb       $10
                    fdb       L0294-*             INTEGER ($fddb)

                    fcb       $10
                    fdb       L029D-*             REAL ($fde1)

                    fcb       $10
                    fdb       L02A3-*             BOOLEAN ($fde4)

                    fcb       $10
                    fdb       L02AC-*             STRING ($fdea)

                    fcb       $20
                    fdb       L1424-*             ??? Something that points to 'THEN' ($0f5f)

                    fcb       $60
                    fdb       L02BA-*             TO ($fdf2)

                    fcb       $60
                    fdb       L02BE-*             STEP ($fdf3)

                    fcb       $00
                    fdb       L02C4-*             DO ($fdf6)

                    fcb       $00
                    fdb       L02C8-*             USING ($fdf7)

                    fcb       $20
                    fdb       L145E-*             ??? Something with file access modes ($0f8a)

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
                    fdb       L1AE1-*             ??? Bump Y up by 2 & return ($15ec)

* Guess: These following have to do with printing numeric values???
                    fcb       $20
                    fdb       L138A-*             ??? ($0E92)

                    fcb       $20
                    fdb       L138A-*             ??? ($0E8F)

                    fcb       $20
                    fdb       L138A-*             ??? ($0E8c)

                    fcb       $20
                    fdb       L138A-*             ??? ($0E89)

                    fcb       $20
                    fdb       L138A-*             ??? ($0E86)

                    fcb       $20
                    fdb       L138A-*             ??? ($0E83)

                    fcb       $21
                    fdb       L138A-*             ??? ($0E80)

                    fcb       $22
                    fdb       L138A-*             ??? ($0E7D)

                    fcb       $23
                    fdb       L138A-*             ??? ($0E7A)

                    fcb       $20
                    fdb       L1386-*             ??? (Appends period, does 138A routine) ($0E73)

                    fcb       $21
                    fdb       L1386-*             ??? (Appends period, does 138A routine) ($0E70)

                    fcb       $22
                    fdb       L1386-*             ??? (Appends period, does 138A routine) ($0E6d)

                    fcb       $23
                    fdb       L1386-*             ??? (Appends period, does 138A routine) ($0E6a)

                    fcb       $26
                    fdb       L13BE-*             ??? (print single byte numeric?) ($0E9f)

                    fcb       $27
                    fdb       L13CF-*             ??? (print 2 byte integer numeric?) ($0Ead)

                    fcb       $24
                    fdb       L13A0-*             ??? (possibly something with reals?) ($0E7b)

                    fcb       $24
                    fdb       L13E1-*             ??? (string, puts " in) ($0Eb9)

                    fcb       $27
                    fdb       L13F6-*             ??? (string, puts $ in) ($0Ecb)

                    fcb       $11
                    fdb       L02DA-*             ADDR ($FDac)

                    fcb       $80                 ???
                    fdb       $0000

                    fcb       $11
                    fdb       L02E0-*             SIZE ($FDAC)

                    fcb       $80
                    fdb       $0000               ???

                    fcb       $10
                    fdb       L02E6-*             POS ($FDAC)

                    fcb       $10
                    fdb       L02EB-*             ERR ($FDAE)

                    fcb       $12
                    fdb       L02F0-*             MOD ($FDB0)

                    fcb       $12
                    fdb       L02F0-*             MOD ($FDAD)

                    fcb       $11
                    fdb       L02F5-*             RND ($FDAF)

                    fcb       $10
                    fdb       L0302-*             PI ($FDB9)

                    fcb       $12
                    fdb       L02FA-*             SUBSTR ($FDAE)

                    fcb       $11
                    fdb       L0335-*             SGN ($FDE6)

                    fcb       $11
                    fdb       L0335-*             SGN ($FDE3)

                    fcb       $11
                    fdb       L0306-*             SIN ($FDB1)

                    fcb       $11
                    fdb       L030B-*             COS ($FDB3)

                    fcb       $11
                    fdb       L0310-*             TAN ($FDB5)

                    fcb       $11
                    fdb       L0315-*             ASN ($FDB7)

                    fcb       $11
                    fdb       L031A-*             ACS ($FDB9)

                    fcb       $11
                    fdb       L031F-*             ATN ($FDbb)

                    fcb       $11
                    fdb       L0324-*             EXP ($FDBD)

                    fcb       $11
                    fdb       L033A-*             ABS ($FDD0)

                    fcb       $11
                    fdb       L033A-*             ABS ($FDCD)

                    fcb       $11
                    fdb       L0329-*             LOG ($FDB9)

                    fcb       $11
                    fdb       L032E-*             LOG10 ($FDBB)

                    fcb       $11
                    fdb       L033F-*             SQRT ($FDC9)

                    fcb       $11
                    fdb       L033F-*             SQRT ($FDC6)

                    fcb       $11
                    fdb       L034A-*             INT ($FDCE)

                    fcb       $11
                    fdb       L034A-*             INT ($FDCB)

                    fcb       $11
                    fdb       L034F-*             FIX ($FDCD)

                    fcb       $11
                    fdb       L034F-*             FIX ($FDCA)

                    fcb       $11
                    fdb       L0354-*             FLOAT ($FDCC)

                    fcb       $11
                    fdb       L0354-*             FLOAT ($FDC9)

                    fcb       $11
                    fdb       L035B-*             SQ ($FDCD)

                    fcb       $11
                    fdb       L035B-*             SQ ($FDCA)

                    fcb       $11
                    fdb       L035F-*             PEEK ($FDCB)

                    fcb       $11
                    fdb       L0365-*             LNOT ($FDCE)

                    fcb       $11
                    fdb       L036B-*             VAL ($FDD1)

                    fcb       $11
                    fdb       L0370-*             LEN ($FDD3)

                    fcb       $11
                    fdb       L0375-*             ASC ($FDD5)

                    fcb       $12
                    fdb       L037A-*             LAND ($FDD7)

                    fcb       $12
                    fdb       L0380-*             LOR ($FDDA)

                    fcb       $12
                    fdb       L0385-*             LXOR ($FDDC)

                    fcb       $10
                    fdb       L038B-*             TRUE ($FDDF)

                    fcb       $10
                    fdb       L0391-*             FALSE ($FDE2)

                    fcb       $11
                    fdb       L0398-*             EOF ($FDE6)

                    fcb       $11
                    fdb       L039D-*             TRIM$ ($FDE8)

                    fcb       $13
                    fdb       L03A4-*             MID$ ($FDEC)

                    fcb       $12
                    fdb       L03AA-*             LEFT$ ($FDEF)

                    fcb       $12
                    fdb       L03B1-*             RIGHT$ ($FDF3)

                    fcb       $11
                    fdb       L03B9-*             CHR$ ($FDF8)

                    fcb       $11
                    fdb       L03BF-*             STR$ ($FDFB)

                    fcb       $11
                    fdb       L03BF-*             STR$ ($FDF8)

                    fcb       $10
                    fdb       L03C5-*             DATE$ ($FDFB)

                    fcb       $11
                    fdb       L03CC-*             TAB ($FDFF)

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
                    fdb       L03D1-*             NOT ($FDF2)

                    fcb       $51
                    fcc       '-'                 ??? (Sign as opposed to subtract?)
                    fcb       $00

                    fcb       $51
                    fcc       '-'                 ??? (Sign as opposed to subtract?)
                    fcb       $00

                    fcb       $0A
                    fdb       L03D6-*             AND ($FDEE)

                    fcb       $09
                    fdb       L03DB-*             OR ($FDF0)

                    fcb       $09
                    fdb       L03DF-*             XOR ($FDF1)

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
                    fdb       L138A-*             ??? ($0D3c)

                    fcb       $21
                    fdb       L138A-*             ??? ($0D39)

                    fcb       $22
                    fdb       L138A-*             ??? ($0D36)

                    fcb       $23
                    fdb       L138A-*             ??? ($0D33)

                    fcb       $20
                    fdb       L1386-*             ??? (Adds period, does 138A) ($0D2C)

                    fcb       $21
                    fdb       L1386-*             ??? (Adds period, does 138A) ($0D29)

                    fcb       $22
                    fdb       L1386-*             ??? (Add period, does 138A) ($0D26)

                    fcb       $23
                    fdb       L1386-*             ??? (Add period, does 138A) ($0D23)

* System Mode commands
                    fdb       2                   # commands this table
                    fcb       2                   # bytes to first command string
L0668               fdb       L09F9-L0668
                    fcs       '$'
L066B               fdb       L094F-L066B
                    fcb       C$CR+$80            (Carriage return)

                    fdb       14                  # commands this table
                    fcb       2                   # bytes to first command string
L0671               fdb       BYEBYE-L0671
                    fcs       'BYE'
L0676               fdb       DIR-L0676
                    fcs       'DIR'
L067B               fdb       L1590-L067B
                    fcs       'EDIT'
L0681               fdb       L1590-L0681
                    fcs       'E'
L0684               fdb       L0D02-L0684
                    fcs       'LIST'
L068A               fdb       INTERP-L068A
                    fcs       'RUN'
L068F               fdb       KILLER-L068F
                    fcs       'KILL'
L0695               fdb       SAVE-L0695
                    fcs       'SAVE'
L069B               fdb       L0AC3-L069B
                    fcs       'LOAD'
L06A1               fdb       RENAME-L06A1
                    fcs       'RENAME'
L06A9               fdb       DUMP-L06A9
                    fcs       'PACK'
L06AF               fdb       CHGMEM-L06AF
                    fcs       'MEM'
L06B4               fdb       CHDDIR-L06B4
                    fcs       'CHD'
L06B9               fdb       L0A28-L06B9
                    fcs       'CHX'

* Debug mode commands (offsets done by current base + offset)
                    fdb       2                   # of entries this table (-3,x)
                    fcb       2                   # of bytes to start of next entry (-1,x)
L06C1               fdb       L09F9-L06C1         base ptr goes here (0,x)
                    fcs       '$'                 base ptr+(-1,x) above points here
L06C4               fdb       L108B-L06C4
                    fcb       C$CR+$80            (Carriage return)

L06C7               fdb       14                  # of entries this table (but 13?)
                    fcb       2                   # bytes to next entry
* Debug set #2?
L06CA               fdb       L109A-L06CA
                    fcs       'CONT'
L06D0               fdb       DIR-L06D0
                    fcs       'DIR'
L06D5               fdb       L1068-L06D5
                    fcs       'Q'
L06D8               fdb       L10E4-L06D8
                    fcs       'LIST'
L06DE               fdb       L1195-L06DE
                    fcs       'PRINT'
L06E5               fdb       L120A-L06E5
                    fcs       'STATE'
L06EC               fdb       L1195-L06EC
                    fcs       'TRON'
L06F2               fdb       L1195-L06F2
                    fcs       'TROFF'
L06F9               fdb       L1195-L06F9
                    fcs       'DEG'
L06FE               fdb       L1195-L06FE
                    fcs       'RAD'
L0703               fdb       L1195-L0703
                    fcs       'LET'
L0708               fdb       L107C-L0708
                    fcs       'STEP'
L070E               fdb       L1226-L070E
                    fcs       'BREAK'
* Some edit mode stuff?
                    fdb       8                   # entries this table
                    fcb       2                   # bytes to start entry
L0718               fdb       L169E-L0718
                    fcs       'L'
L071B               fdb       L169E-L071B
                    fcs       'l'
L071E               fdb       L199A-L071E
                    fcs       'D'
L0721               fdb       L199A-L0721
                    fcs       'd'
L0724               fdb       L15E7-L0724
                    fcs       '+'
L0727               fdb       L15E7-L0727
                    fcs       '-'
L072A               fdb       L15E7-L072A
                    fcb       C$CR+$80
L072D               fdb       L1601-L072D
                    fcb       C$SPAC+$80

                    fdb       4                   # entries
                    fcb       2                   # bytes to first entry
L0733               fdb       L175B-L0733
                    fcs       'S'
L0736               fdb       L175E-L0736
                    fcs       'C'
L0739               fdb       L18DF-L0739
                    fcs       'R'
L073C               fdb       L1993-L073C
                    fcs       'Q'

L073F               fcb       $0E
                    fcs       'Ready'
L0745               fcs       'What?'
L074A               fcs       ' free'
L074F               fcs       'Program'
L0756               fcs       'PROCEDURE'
                    fcb       C$CR
L0760               fcb       C$LF
                    fcs       '  Name      Proc-Size  Data-Size'
L0781               fcc       'Rewrite?: '
L0791               fcb       $0E
                    fcs       'BREAK: '
L07A2               fcs       'ok'
L07A4               fcs       'D:'
L07A6               fcs       'E:'
L07A8               fcs       'B:'

* F$Icpt routine
INTCPT               lda       R$DP,s              Get DP register from stack
                    tfr       a,dp                Put into real DP
                    stb       <u0035              Save signal code

                    ifne      H6309
                    oim       #$80,<u0034         Set high bit (flag signal was received)
                    else
                    lsl       <u0034              Set high bit (flag signal was received)
                    coma                    Break flag
                    ror       <u0034
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
                    std       <u0000              Preserve Start of Data memory ptr
                    inca                          Point to $100 in data area
                    sta       <u00D9              Preserve the 1
                    std       <u0080              Initialize ptr to start of temp buffer
                    std       <u0082              Initialize current pos. in temp buffer
                    adda      #$02                D=$300
                    std       <u0046              Save subroutine stack ptr
                    std       <u0044              Save top of string space ptr
                    inca                          D=$400
                    tfr       d,s                 Point stack to $400 ($300-$3ff)
                    std       <u0004              Save ptr to ptr list of modules in workspace
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

                    std       <u0008              Save ptr to start of I-Code workspace
                    std       <u004A              Save ptr to end of used I-Code workspace
                    tfr       u,d                 Move start of param area ptr to D
                    subd      <u0000              Calculate size for entire data area
                    std       <u0002              Preserve size of Data area
                    ldb       #01                 Std Out path
                    stb       <u002E              Save as std output path
                    lda       #$03                Close all paths past the standard 3
START05               os9       I$Close
                    inca
                    cmpa      #$10                Do until 3-15 are closed
                    blo       START05
                    lda       #$02                Create duplicate path for error path
                    os9       I$Dup
                    sta       <u00BE              Preserve duplicate's path #
                    leax      <INTCPT,pc           Point to intercept routine and set it up with
                    os9       F$Icpt              it's memory area @ start of param area
                    leax      >L000D-$d,pc        Point to beginning of module header
                    ifne      H6309
                    tfr       x,w                 Move it to W
                    else
                    pshs      x             save BASE 0
                    endc
                    ldx       <u0000              Point X to start of data mem
* Set up some JMP tables from the module header
                    leax      <$1B,x              Point $1b bytes into it
                    leay      >L000D,pc           Point to module header extensions
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
                    bsr       L0116               Go init <$50 vars, & some table ptrs
                    puls      y                   Get parameter ptr
                    leax      >L0140,pc           Point to main command token list
                    stx       <u009E              Save it
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
                    lbsr      L0AC3               Go open path to name (Y=ptr to it)
                    bra       EXIT         cleanup stack

L0116               jsr       <u0024              JMP to L31E8 (default from module header)
                    fcb       $00                 Function code 0

START2               puls      y                   Get original contents of <u00B7
                    bsr       SETUP
                    ldx       <u0004              Get ptr to module list
                    ldd       ,x                  Get ptr to 1st module (initially 0 (none))
                    std       <u002F              Save it
                    lbsr      INTERP         (will exit to COMAN0)
SETUP               leax      <L08B2,pc           Get ptr >1st entry into routine
SETUP1               puls      u                   Get RTS address
                    bsr       SETEXT               Push 2 bytes from <B7 onto stack, RTS=START2
                    pshs      u                   Save RTS address from BSR SETUP1
                    clr       <u0034              Clear out signal recieved flag
                    ldd       <u0000              Get start of data mem
                    addd      <u0002              Add size of data mem
                    subd      <u0008              Subtract all BASIC09 reserved stuff ($500 bytes)
                    subd      <u000A              Subtract # bytes used by user's programs (not Data)
                    std       <u000C              Save # bytes free in workspace for user's programs
                    leau      2,s                 Point U to START2 ptr on stack
                    stu       <u0046              Save ptr to it
                    stu       <u0044              And again
                    leas      -$FE,s              Bump stack ptr back 254 bytes
                    jmp       [<-2,u]             Jump to START2 address on stack

EXIT               lds       <u00B7
                    puls      d             pop previous exit trap
                    std       <u00B7        reset it
EXNLIN               lbra      L0DBB               Reset temp buffer size & ptrs to defaults

SETEXT               ldd       <u00B7              Get some other stack ptr?
                    pshs      d                   Preserve it
                    sts       <u00B7              Save stack ptr
                    ldd       2,s                 Get RTS address to SETUP1 or START2
                    stx       2,s                 Save ptr to START2 or SETUP on stack
                    tfr       d,pc                Return to SETUP1 (just after BSR SETEXT)

COMAND               leax      >L0024,pc           Point to intro screen credits
                    bsr       L08D0               Copy to temp buffer/print to Std error
                    leax      name,pc             Point to 'Basic09'
                    bsr       L08D0               Copy to temp buffer/print to Std error

L08B2               bsr       SETUP
                    leax      >L073F+1,pc         Point to 'Ready'
                    bsr       L08D0               Copy to temp buffer/print to Std error
                    leax      >L07A8,pc           Point to 'B:' prompt
                    leay      >L0668,pc           Point to system mode command table
                    clr       <u0084
* (orig: COMAN0)
                    bsr       RUNCMD               Get command & execute it
                    bcc       EXIT               Did it, no problem
                    bsr       CMDERR               Unknown command, print 'What?'
                    bra       EXIT               Resume normal operation

CMDERR               leax      >L0745,pc           Point to 'What?'
L08D0               lbra      L125F               Copy to temp buffer/print to Std error

* Get next command from keyboard & execute it
* Entry: Y=Ptr to command table
* Exit: Carry set if command doesn't exist
RUNCMD               pshs      y,x                 Preserve command tbl ptr & ptr to prompt (ex B:)
                    clr       <u0035              Clear out last signal received
                    lbsr      L126B               Go print a message if we have to to std err
                    bsr       EXNLIN               S/B LBSR L0DBB (saves 3 cycles)
                    lda       <u00BD              Get current input path #
                    beq       L08E5               If Std In, skip ahead
                    os9       I$Close             Otherwise, close it
* (orig: RUNCMD05)
                    clr       <u00BD              Force input path # to 0 (Std In)
L08E5               lbsr      INLINE               ReadLn up to 256 bytes from std in
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
                    bsr       L010A               Go parse line, y=ptr to offset in command found
                    bne       RUNC20               '$' or <CR> command found, skip ahead
* (orig: PRCLIT)
                    lbsr      L010D               ???Go check for a procedure name, B=size
                    beq       RUNC90               None, exit with carry set
                    leax      $03,x               Point to system mode table 2
                    lda       #C$SPAC             ???
                    bsr       L010A               Go parse line, y=ptr to offset in command found
                    beq       RUNC90               No command found, exit with carry set
* Command found in table
RUNC20               ldd       ,x                  Get offset
                    leas      4,s                 Eat stack
                    jmp       d,x                 Call routine

L010A               jsr       <u001E
                    fcb       $04

* Command not found
RUNC90               coma                          Set carry & exit
                    puls      pc,y,x

* Entry: Y=Ptr to string of chars
CHGMEM               lbsr      L0A90               Go find 1st non-space/comma char
                    bne       CHGME1               Found one, skip ahead
                    leax      ,y                  Point X to char
                    ldd       <u0008              Get ptr to start of I-Code workspace
                    addd      <u000A              Add to size of all programs in workspace
                    inca                          Bump up by 256 bytes
                    subd      <u0000              Subtract start of data mem ptr
                    pshs      d                   Preserve size
                    lbsr      L1748               ??? Check something
                    bcs       CHGERR               Error, exit with carry set
                    cmpd      ,s++                Check with previously calculated size
                    blo       CHGER1               Will fit, continue
                    os9       F$Mem               Won't fit, request the required data mem size
                    bcs       CHGME1               Can't get it, skip ahead
                    subd      #$0001              Bump gotten size down by 1 byte
                    std       <u0002              Save new data mem size
CHGME1               lbsr      L0DBB               Reset temp buffer size & ptrs
                    ldd       <u0002              Get data mem size
                    bsr       ItoA               ???
CHGME9               lbra      L1264               Print temp buff contents to std error

CHGERR               leas      2,s                 Eat something off stack
CHGER1               coma                          Exit with carry set
                    rts

* Debug & System mode - DIR
DIR               leax      ,y
                    lbsr      OPNCHL
* System mode - <CR>
L094F               leax      >L0760,pc           Point to basic09 DIR header
                    lbsr      L125F               Print it out to Std err
                    ldy       <u0004              Get Ptr to list of modules in BASIC09 workspace
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
DIR10               lbsr      L1373               Add char in A to temp text buffer
                    lda       #C$SPAC             Default to space again
                    cmpx      <u002F              Is this the 'current' module?
                    bne       DIR15               No, skip ahead
                    lda       #'*                 '*' to indicate current module
DIR15               lbsr      L1373               Append that char to temp text buffer
                    ldd       M$Name,x            Get offset to name of module
                    leax      d,x                 Point to name
                    lbsr      L135A               ??? Print it out
                    ldd       #$11*256+M$Size     A=??, B=offset from module ptr to get data
                    bsr       DIRNUM               Go print program size
                    ldd       #$1C*256+M$Mem      A=??, B=offset from module ptr to get data
                    bsr       DIRNUM               Go print data area size
                    ldd       M$Mem,x             Get data area size required by module
                    addd      #$0040              Add 64 to it
                    cmpd      <u000C              Bigger than bytes free in workspace for user?
                    blo       DIR18               Legal data area size, continue
                    lda       #'?                 Data area too big for current buffer space, print
                    lbsr      L1373               a '?' beside data area size
DIR18               bsr       CHGME9               Print line out to std error path
                    puls      y,x                 Get ??? & module ptr back
                    tst       <u0035              Any signals pending?
                    bne       DIR3               Yes, skip ahead
DIR2               ldx       ,y++                Get ptr to module
                    bne       DIR1               There is one, go print it's entry out
DIR3               ldd       <u000C              None left, get # bytes free in BASIC09 workspace
                    bsr       ItoA               Go convert to ASCII
                    leax      >L074A,pc           Point to 'free'
                    lbsr      L1261               Print it out to Std err
                    lbra      CLSCHL               Close std err; Dup path @ <BE & return from there

* Entry: A=???, b=offset from module header to get 2 byte # from
DIRNUM               pshs      b                   Preserve B
                    ldb       #$10                Sub function (uses table @ L50B2)
                    lbsr      L011F               Call <2A (inited to L5084), function 2
                    puls      b                   Restore B
                    ldx       2,s                 Get module ptr back
                    ldd       b,x                 Get size to print

* Convert # in D to ASCII version (decimal)
ItoA               pshs      y,x,d               Preserve End of data mem ptr,?,Data mem size
                    pshs      d                   Preserve data mem size again
                    leay      <L09ED,pc           Point to decimal table (for integers)
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
                    lbsr      L1373               Go save A @ [<u0082]
                    ldx       #$2F01              Reset X differently
                    bra       ItoA.B               Go do again

INVOKE               lbsr      L1373               Go save A @ [<u0082]
                    leas      2,s                 Eat stack
                    puls      pc,y,x,d            Restore regs & return

* Table of decimal values
L09ED               fdb       $2710               10000
                    fdb       $03E8               1000
                    fdb       $0064               100
                    fdb       $000A               10
                    fdb       $0001               1
                    fdb       $0000               0

* Debug/System '$' goes here
* Entry: Y=Ptr to line typed in by user?
L09F9               lbsr      L0A90               Go check char @ Y for space or comma
                    leau      ,y                  Point to start of parameter area
                    clrb                          Current size of parameter area=0
INVK10               incb                          Bump size up by 1
                    lda       ,y+                 Get char from user's line
                    cmpa      #C$CR               Hit end yet?
                    bne       INVK10               No, keep looking
                    clra                          parameter line never >255 chars
                    tfr       d,y                 Move size of parameter area to Y for Fork
                    leax      >L0277,pc           Point to 'SHELL'
                    lda       #Objct              ML program
                    clrb                          Size of data area=0 pages
* (orig: INVK20)
                    os9       F$Fork              Fork shell out
                    bcs       L0A86               Error, deal with it
                    pshs      a                   Save process # of shell
L0A17               os9       F$Wait              Wait for death signal
                    cmpa      ,s                  Was it our shell process?
                    bne       L0A17               No, wait for ours
                    leas      1,s                 Yes, eat process #
                    tstb                          Error status from child?
                    bne       L0A86               Yes, deal with it
                    rts                           No, return
* System Mode - CHD (MOD 93/09/20 - CHANGED FROM UPDAT. TO READ.)
CHDDIR               lda       #DIR.+READ.         Open Data directory in Update mode
                    bra       CHXD10

* System Mode - CHX
L0A28               lda       #DIR.+EXEC.         Open Execution Directory
CHXD10               leax      ,y                  Point to directory we are changing to
                    os9       I$ChgDir            Change dir
                    bcs       L0A86               Error, exit with it
                    rts                           No error, return

RENAME               bsr       L0A9D
                    lbsr      DIRSCH         Is it in directory?
                    bcs       CMDSEP         No; error - not in workspace
                    pshs      x
                    ldx       ,x            get procedure address
                    tst       6,x           internal (un-typed) procedure?
                    bne       CMDSEP         ..no; sorry
                    bsr       L0A90               Go check char @ Y for space or comma
                    beq       INTE05               It is a space or comma, skip ahead
RENAMErr               comb                          Set carry, restore X & return
                    puls      pc,x          Return error

INTE05               bsr       L010D               Call <u001E, function 2
                    beq       RENAMErr
                    pshs      y
                    lbsr      DIRSCH         Is it in directory?
                    bcs       RENA05         ..no; good
                    cmpx      $02,s         renaming same procedure?
                    bne       ERUPRC
RENA05               ldx       $02,s
                    lbsr      L1A2E         Unbind the procedure
                    puls      x             get ptr to new name
                    ldy       <u004A
RENAM1               lda       ,x+
                    sta       ,y+
                    bpl       RENAM1
                    sty       <u00AB        Set end of name ptr
                    ldx       [,s++]        get address of procedure
                    ldd       $04,x
                    leay      d,x           get address of old name
* (orig: ERPRCX)
                    ldb       <$18,x        get size of old name
                    lda       <u00A6        Replace it with size of new name
                    sta       <$18,x
                    clra
* (orig: ERREXT)
                    lbsr      L19B1         Replace old name with new name
                    addd      <u005E
                    std       <u005E
RBIND1               lbra      L1995

ERUPRC               ldb       #$2C                Multiply-defined procedure error
* Error
L0A86               lbsr      L1287
L0A89               lbra      EXIT

CMDSEP               ldb       #$2B                Unknown procedure error
                    bra       L0A86

* Entry: Y=Ptr to string of chars?
* Exit:  Y=Ptr to char (or up 1 char if space/comma found)
*        B=Char found
L0A90               ldb       ,y+                 Get char
                    cmpb      #',                 Is it a ','?
                    beq       L0A9C               Yes, return
                    cmpb      #C$SPAC             Is it a space?
                    beq       L0A9C               Yes, return
                    leay      -1,y                No, normal char, point Y to it
L0A9C               rts                           Exit with B=char

* Entry: Y=Ptr to 1st char in possible string name
* Exit:  Y=Ptr to module name (or string name)
L0A9D               bsr       L010D               Call <u001E function 2 (string name search again)
                    bne       L0AB0               Size possible name>0, exit
DEFPRC               ldy       <u002F              Get ptr to 'current' module
                    beq       L0AAC               None, use 'Program' as default
                    ldd       M$Name,y            Get offset to module name
                    leay      d,y                 Point Y to module name & return
* (orig: PRCRE9)
                    rts

L0AAC               leay      >L074F,pc           Point Y to 'Program'
L0AB0               rts

L0AB1               ldb       #$2B                Unknown procedure error
                    bra       L0ABD

L0AB5               ldb       #$20                Memory full error
L0AB7               pshs      b
                    bsr       RBIND1         Bind erroneous procedure
                    puls      b             Restore error code
L0ABD               cmpb      #E$EOF              End of file error?
                    beq       L0A89               Yes, special case
                    bra       L0A86               Exit with it

L010D               jsr       <u001E
                    fcb       $02

* Entry: Y=Ptr to string (path name)
* Exit: Path opened to file, path # @ <u00BD
L0AC3               leax      ,y                  Point to path name
                    lda       #1                  Std out path
                    os9       I$Open              Open path
                    bcs       L0ABD               Error, check if it is EOF
                    sta       <u00BD              Save path #
                    bsr       INLINE               Go read a line into temp input buffer
                    bsr       L0B3C               Go check if it starts with 'PROCEDURE'
                    bne       L0AB1               No, exit with Unknown Procedure Error
L0AD4               bsr       L010D               Yes, call function
                    beq       L0AB1
                    pshs      y
                    lbsr      DIRSCH         Is name in directory?
                    bcs       L0AE8         ..no; don't try kill
                    ldy       ,s
                    leay      -$01,y        Must have a preceeding space
* (orig: INTE40)
                    lbsr      KILLER         Destroy any old version that may have existed
L0AE8               ldy       ,s
                    lbsr      DIRADD
                    lbsr      L1A2E
                    puls      x             Restore proc name ptr
                    lbsr      L125F         Print it
L0AF6               ldb       <u0035              Get last received signal code
                    bne       L0AB7               Got a signal, use it as error code & abort load
                    bsr       INLINE               Go get line of source from file
                    bcs       L0AB7               Error on read, exit with it
                    lda       <u000C              Get MSB of bytes free in workspace
                    cmpa      #$02                At least $2ff (767) bytes free?
                    blo       L0AB5               No, exit with memory full error
                    bsr       L0B3C               Check for word PROCEDURE
                    beq       L0B14               Found it, skip ahead
                    ldy       <u0080              Get temp buff ptr
                    ldd       <u0060
                    std       <u005C        At end of icode-
                    lbsr      L1606         -insert this line
                    bra       L0AF6         Endloop

L0B14               ldx       <u0080              Get ptr to start of temp buffer
                    pshs      y,x                 Save ??? & temp buffer start ptr
L0B18               lda       ,x+                 Get char
                    cmpa      #C$CR               Carriage return?
                    bne       L0B18               No, keep looking for CR
                    stx       <u0080              Save CR+1 position as start of temp buffer
                    stx       <u0082              And as current position in temp buffer
* Is this function to read in a source listing (single procedure) not including
*   PROCEDURE line itself?
                    bsr       L0128               JSR <$21, function 2
                    puls      y,x                 Restore ??? & temp buffer start ptr
                    stx       <u0080              Save temp buffer start ptr again
                    stx       <u0082              And save current position in temp buffer
                    bra       L0AD4               Loop back

* Read line from source code file
INLINE               lda       <u00BD              Get path # to file
                    ldx       <u0080              Get address to get data into
                    ldy       #$0100              Up to 256 bytes to be read
                    os9       I$ReadLn            Go read a line
                    ldy       <u0080              Get ptr to line read & return
                    rts

* Entry: Y=ptr to input buffer
* Exit: Carry clear if word 'PROCEDURE' was found
*       Y=Ptr to 1 byte past 'procedure' in buffer
L0B3C               bsr       L010D               Call function
                    leax      >L0756,pc           Point to 'PROCEDURE'
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
                    ldu       <u0046
                    bra       DUMP02         Repeat

L0128               jsr       <u0021
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
                    cmpd      <u000C              Compare with bytes free in workspace
                    lbhi      ERMFUL               If higher, exit with memory full error
DUMP02               ldy       ,--u
                    bne       DUMP01         Until end of list
                    ldd       #(EXEC.+WRITE.)*256+UPDAT.+EXEC. Exec. dir & rd/wt/ex attribs
                    lbsr      OPNCH0               Go create file (0 byte length)
                    ldy       <u0046
                    stu       <u0046        chop out used portion of opstack
                    lbra      DUMP04         Repeat

L0B8C               pshs      y
                    lbsr      L1A2E         Unbind procedure
                    clr       <u00D9        Tell binder to smash rems, dims, types, etc.
                    bsr       L0128               JSR <u0021, function 2 (PLREF)
                    inc       <u00D9        Reset
                    ldx       <u0062        get symbol tbl ptr
                    leay      ,x            (in case of no symbols)
* NOTE: <u0000 UNECESSARY FOR LEVEL II
                    ldd       <u0000              Get start of data area ptr
                    addd      <u0002              Get ptr to end of data area
                    tfr       d,u                 Move to U
                    ldd       -3,x
                    beq       L0C18         No symbols; exit squish phase
* (orig: DUMP1)
                    pshs      u                   Save size of data area
L0BA8               pshs      d
                    leax      1,x
                    ldd       ,x
                    pshu      d             Build stack of save info from symbol table
                    clr       ,x+           Clear out symbol table entry
                    clr       ,x+
DUMP2               lda       ,x+                 Find hi-bit set char
                    bpl       DUMP2         Skip over name to next entry
                    puls      d             Restore symbol table count
                    subd      #1
                    bne       L0BA8         Repeat until whole table copied
                    ldy       <u005E
                    bra       DUMP4         While not end of icode

DUMP3               ldd       ,y
                    ldx       <u0062
                    leax      d,x           Actual addr of symbol tbl entry
                    ldd       1,x           get linked list
                    sty       1,x           Make new head
                    std       ,y++          Build link
DUMP4               lbsr      L1BC2
                    bcc       DUMP3         Endwhile
                    puls      u
                    ldx       <u0062        get old symbol table ptr
                    ldd       -3,x          Number of entries in symbol table
                    leay      ,x            Set beginning of new symbol table
DUMP5               leau      -2,u
                    pshs      u,d           Save number of entries, stack ptr
                    clra
                    ldu       1,x           get header link
                    beq       DUMP8         Branch unreferenced entry
                    pshs      x             Save old symbol ptr
                    tfr       y,d           Copy new symbol ptr
                    subd      <u0062        Make ptr into offset
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
L0C18               ldx       <u002F              Get ptr to start of current module
                    ldd       M$Size,x            Get size of module
                    pshs      d                   Save it
                    leay      3,y                 Add size of 24 bit CRC
                    tfr       y,d                 Move ptr to end of module (including CRC bytes)
                    subd      <u002F              Calculate size of module including CRC
                    std       M$Size,x            Save it
                    ldd       ,s                  Get original size of module
                    subd      M$Size,x            Subtract new size
                    std       ,s                  Save size difference
                    addd      <u000C              Add to bytes free in workspace
                    std       <u000C              Save new # bytes free
                    ldd       <u000A              Get # bytes used by all programs in workspace
                    subd      ,s++                Subtract size difference
                    std       <u000A              Save new # bytes used by all programs in workspace
                    addd      <u0008              Add to start ptr of I-code workspace (calculate end)
                    std       <u004A              Save ptr to 1st free byte in I-code workspace
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
                    lbcs      L0DB6               If error on write, go deal with it
                    puls      y             Retrieve procedure list ptr
DUMP04               ldx       ,--y
                    lbne      L0B8C         Repeat until there are no more
                    lbra      CLSCHL               Go close file, reopen path from <BE, rts from there

DEFILE               bsr       PCDLST
                    lda       ,y                  Get char
                    cmpa      #C$CR               Is it CR?
                    bne       L0C9A               No, point X to it & return
                    ldx       <u0046              Get ???
                    ldx       [<-2,x]       get 1st procedure in list
                    ldd       M$Name,x            Get offset to module name
* (orig: DEFIL1)
                    leax      d,x                 Point X to module name
                    lbsr      L135A               Go set up temp buffer with name
                    lbsr      L1371               Append CR to end of temp buffer
L0C9A               leax      ,y
                    rts

PCDLST               ldu       <u0046              Get table end ptr
                    stu       <u0044              Save as current table ptr
                    lbsr      L0A90               Go get char (bump y past it if , or space)
                    beq       PCDLS3               If comma or space, skip ahead
                    cmpb      #'*                 Is it a '*'?
                    bne       PCDLS4               No, skip ahead
                    ldx       <u0004              Get ptr to workspace module ptr list
PCDLS1               ldd       ,x                  Get 1st possible entry
                    beq       PCDLS2               Empty, skip ahead
                    tfr       x,d                 Move ptr to D
                    leax      2,x                 Bump ptr up to next entry
PCDLS2               std       ,--u                Save entry
                    bne       PCDLS1         Repeat if not end marker
                    stu       <u0044              Save new ptr
                    lda       ,y                  Get char from temp buffer
                    cmpa      #C$CR               CR?
                    beq       PCDL25               Yes, save ptr & return
                    leay      1,y                 No, bump ptr up by 1
PCDL25               sty       <u0082              Save current pos in temp buffer & return
                    rts

PCDLS3               lbsr      L010D               JSR <u001E, function 2
                    bne       L0CD9         ..yes; go get em
PCDLS4               sty       <u0082              Save current pos in temp buffer
                    lbsr      DEFPRC               Point Y to Name of current module (or 'Program')
                    lbsr      DIRSCH               Go check if module exists in BASIC09 workspace
                    bcc       PCDLS5               Yes, skip ahead
PCDLSR               lbra      CMDSEP               No, return with Unknown Procedure error

L0CD9               lbsr      DIRSCH               Check if module exists in BASIC09 workspace
                    bcs       PCDLSR               No, return Unknown Procedure error
                    sty       <u0082              Save Ptr to end of fname as current pos in tmp buf
PCDLS5               stx       ,--u                Save ptr to start of module name
                    ldy       <u0082              Get Ptr to end of filename
                    lbsr      L0A90               Point Y to next char (or past ',' or space)
                    bne       PCDLS6               Not comma or space, skip ahead
                    lbsr      L010D               JSR <u001E, function 2
                    bne       L0CD9         ..yes; repeat
PCDLS6               clra
                    clrb                    End mark on opstack
                    bra       PCDLS2         Push it and return

SAVE               tst       <u000C              >256 bytes free for user?
                    lbeq      ERMFUL               No, exit with Memory Full error
                    lda       #$80                Set hi-bit flag
                    sta       <u0084
                    bsr       DEFILE         get procedure list, pathname
                    bra       L0D06

L0D02               bsr       PCDLST
                    leax      ,y            get I/O ptr (pathname)
L0D06               stx       <u005C
                    bsr       OPNCHL         Open output path
                    ldy       <u0046        get top of list
                    stu       <u0046        Carve out opstack space used
                    bra       L0D49

L0D11               pshs      y
                    ldy       [,y]          get procedure addr
                    sty       <u002F              Save as current module ptr
                    ldd       M$Exec,y            Get exec offset
                    addd      <u002F              Add to start of current module
                    std       <u005E              Save absolute exec address of current module
                    ldd       $0F,y               Get ???
                    addd      <u002F              Add to start of current module
                    std       <u0060              Save this absolute address
                    ldd       $0D,y               Get ???
                    addd      <u002F              Add to start of module
                    std       <u0062              Save this absolute address
                    tst       M$Type,y            Check type of module
                    bne       L0D47               If anything but unpacked BASIC09, skip ahead
                    leax      <L0D3B,pc           Point to routine
                    lbsr      SETEXT               ??? The <u00B7 stack swap
                    lbsr      L10E4               ??? DEBUG list command
L0D38               lbra      EXIT               Restore <u00B7, reset temp buff

L0D3B               tst       <u0084              Test flags
                    bmi       L0D47         ..yes; don't produce error list
                    ldx       [,s]          restore directory ptr
                    lbsr      L1A2E         Unbind procedure
                    lbsr      L0128         Rebind it (show errors)
L0D47               puls      y
L0D49               ldx       ,--y
                    bne       L0D11
OPEXIT               bsr       CLSCHL
                    bra       L0D38         then exit (no error)

CLSCHL               pshs      b                   Preserve B
                    lda       #2            close current command path
                    os9       I$Close             Close path #2 (error)
                    lda       <u00BE              Get Duplicate error path #
                    os9       I$Dup               Dupe the path
                    puls      pc,b                Restore B & return

OPNCHL               lbsr      L0A90               Point Y to next char (or past ',' or space)
                    cmpb      #C$CR               Was it a CR?
                    beq       OPNC99               Yes, skip ahead
                    stx       <u0082              Save current pos in temp buffer
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
                    bne       L0DB6               No, skip ahead
                    ldd       ,s                  Get access modoe & file attributes again
                    ldx       2,s                 Get ptr to filename again
                    os9       I$Open              Attempt to open the file
                    bcs       L0DB6               User not allowed to access, skip ahaead
                    leax      >L0781,pc           Point to 'Rewrite?:'
                    ldy       #10                 Size of rewrite string
                    lda       <u00BE              Get error path #
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
                    bcs       L0DB6               If error, skip ahead
OPNC90               puls      pc,u,y,d            Restore regs & return

OPNC99               rts

L0DB6               bsr       CLSCHL               Close & dupe error path
                    lbra      L0A86               Print error

* Reset temp buffer to empty state
L0DBB               pshs      d                   Preserve D
                    lda       #1                  # chars in buffer to 1
                    sta       <u007D              Save it
                    ldd       <u0080              Get ptr to temp buffer
                    std       <u0082              Save it as current pos in temp buffer
                    puls      pc,d                Restore D & return

* Get program name (with hi-bit on last char set + CR), pointed to by Y
*   Will be one of following:
*     1) Name pointed to by Y on entry
*     2) Name of 'current' module in BASIC09 workspace
*     3) 'Program' if neither of the above
INTERP               lbsr      L010D               <1E,func. 2 (Get string size/make FCS type if var name)
                    bne       INTER1               There is >0 chars that qualify as name, skip ahead
                    pshs      y                   Save ptr to string name in question
* NOTE: MAY WANT TO CHANGE ENTRY POINT, SINCE L0A9D CALLS L010D AGAIN
                    lbsr      L0A9D               Get ptr & size of name, or use current (or 'Program')
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
                    stx       <u002F              Save as 'current module'
                    lda       M$Type,x            Get type/language byte
                    beq       INTE30               If type & language are 0, skip ahead
                    anda      #LangMask           Just want language type
                    cmpa      #ICode              BASIC09 I-Code?
                    bne       ERABRT               No, Line With Compiler Error
                    bra       L0DFC               Yes, skip ahead

L0110               jsr       <u001E
                    fcb       $00

L0113               jsr       <u0021
                    fcb       $00

* Type/Language byte of 0
INTE30               lda       <$17,x              Get flags from module
                    rora                          Shift out Line with Compiler error flag
                    bcs       ERABRT               There is an error, report it
* Current module has no obvious errors
L0DFC               bsr       L0110               <1E, fnc. 0 (1F9E normally) (do token?)
                    ldy       <u004A              Get ptr to end of currently used I-code workspace
                    ldb       ,y                  Get last char/token in workspace
                    cmpb      #'=                 Is it an = sign?
                    beq       ERABRT
                    sty       <u005E
                    sty       <u005C
                    ldx       <u00AB              Get ptr to current I-code line end
                    stx       <u0060
                    stx       <u004A              Make it ptr to end of in use I-code workspace
                    ldd       <u000C              Get # bytes free in workspace for user
                    pshs      y,d
                    bsr       L0113
                    puls      y,d
                    std       <u000C              Save # bytes now free in workspace for user
                    sty       <u004A              Save updated end of I-code workspace ptr
                    ldx       <u002F              Get ptr to current module
                    lda       <$17,x              Get flag byte
                    rora                          Shift out Line with Compiler error flag bit
                    bcs       ERABRT               Compiled line has error, report it
                    leas      >$0102,s            Eat 258 bytes from stack ???
                    ldd       <u0000              Get start of data mem ptr
                    addd      <u0002              Add to Size of data area
                    tfr       d,y                 Move end of data area ptr to Y
                    std       <u0046              Save it
                    std       <u0044
                    ldu       #$0000
                    stu       <u0031
                    stu       <u00B3              # steps per run through program (0=continuous)
                    inc       <u00B3+1            Set # steps to 1
                    clr       <u0036              Clear out last error code
                    ldd       <u004A              Get ptr to next free byte in I-code workspace
                    ldx       <u000C              Get # bytes free in workspace for user
                    pshs      x,d                 Save them
                    leax      <INTRTS,pc           Point to routine
                    lbsr      SETEXT
                    ldx       <u004A              Get ptr to next free byte in I-code workspace
                    bsr       L0119
                    lbsr      L0DBB
                    ldx       <u002F              Get ptr to start of current module
                    bsr       L011C
                    bra       INTER9         Return

L0119               jsr       <u0024
                    fcb       $04

L011C               jsr       <u0024
                    fcb       $02

INTRTS               puls      x,d                 Restore bytes free in workspace & ptr to next free
                    std       <u004A              Save old next free byte in I-code workspace
                    stx       <u000C              Save old # bytes free in workspace for user
INTER9               lbra      EXIT

ERABRT               ldb       #$33                Line with compiler error
                    lbra      L0A86               Go report it

* System mode - BYE
BYEBYE               bsr       KILALL
                    clrb                          Exit without error
                    os9       F$Exit

KILLEX               lbsr      L010D
                    beq       KILERR         ..no; error
                    lbsr      DIRSCH
                    bcs       KILERR         ..error; return it
                    ldu       <u0046

                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc

                    pshu      x,d           build procedure list stack
                    inca
                    sta       <u0035        signal killer: external only
                    bsr       KILL0
                    clr       <u0035
                    rts

KILERR               comb                          Set carry for error
                    ldb       #$2B                Divide by 0 error
                    rts

KILALL               ldy       <u0082              Get ptr to current pos in temp buffer
                    lda       #$2A                '*'
                    sta       ,y                  Save in temp buffer
                    sta       <u0035              Save as last signal received
KILLER               lbsr      PCDLST
                    clr       <u002F              Clear out ptr to start of 'current' module
                    clr       <u002F+1
KILL0               ldu       <u0046              Get default ??? tbl ptr
                    stu       <u0044              Save as current ??? tbl ptr
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
                    bra       L0EDE         Zap directory entry

KILL15               tst       <u0035              Any signal code?
                    bne       KILL2               Yes, skip ahead
                    ldx       ,u                  No, get ptr to module
                    lbsr      SHUFLE               Go remove it from workspace pointers (?)
                    ldy       ,x                  Get ptr to module again
                    ldd       <u000A              Get current total size of used I-Code space
                    subd      M$Size,y            Subtract deleted module's size
                    std       <u000A              Save new size of used I-Code space
                    ldd       M$Size,y            Get size of module being removed
                    addd      <u000C              Add to bytes free in I-Code space
                    std       <u000C              Save new # bytes free in I-Code space
* (orig: KILL18)
                    ldd       <u004A              Get ptr to end of used I-Code space+1
                    subd      M$Size,y            Bump it back to not include the deleted module
* (orig: KILL4)
                    std       <u004A              Save new ptr to where next added I-Code goes
L0EDE               ldd       #$FFFF              Module ptr unused marker
                    std       [,u]                Mark it
* Compress list of modules in I-Code workspace (get rid of all deleted ones)
KILL2               ldx       ,--u                Get previous module ptr
                    bne       KILL1               There is one, go remove it too
                    ldx       <u0004              Get ptr to list of modules is I-Code workspace
                    tfr       x,y                 Move it to Y
KILL3               ldd       ,x++                Get module ptr
                    cmpd      #$FFFF              Unused one?
                    beq       KILL3               Yes, try next
L0EF3               std       ,y++                Save it
                    bne       KILL3               Until a $0000 is hit
                    cmpd      ,y                  Is the next entry a 0 too?
                    bne       L0EF3               No, keep Storing until we hit a 0
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
                    ldx       <u000C              Get # bytes free in I-Code workspace for user
                    cmpx      #$00FF              <255 bytes left free?
                    blo       ERMFUL               Yes, skip ahead
                    leax      <-$1C,x             Bump # bytes free down by 28 bytes
                    ldu       <u004A              Get ptr to current I-code line start
* Clear out entire header of packed RUNB module
* 6809/6309 mod: should use sta (after clra) instead of clr b,u
* Wait until ERMFUL is checked-does it need A?
                    ldb       #$FF                Pre-init B for loop below
DIRAD1               incb                          Next position
                    clr       b,u                 Clear byte
                    cmpb      #$18                Done all $18 bytes?
                    bne       DIRAD1               No, keep going
* Copy module name to $19
L0F1F               incb                          Bump B to $19
                    leax      -1,x                Bump X back
                    beq       ERMFUL               If hit 0, exit with memory full error
                    inc       $18,u               Bump up module name size to 1
                    lda       ,y+                 Get char from source (module name)
                    sta       b,u                 Save it
                    bpl       L0F1F               Do until hi-bit terminated
                    incb                          Bump B to 1 byte past module name (start of I-code)
                    stx       <u000C              Save # bytes left free in I-Code workspace
                    clra                          MSB of D=0
                    std       $15,u               ???
                    std       M$Exec,u            Save ptr to execution offset
                    std       $F,u                ???
                    stu       [,s]          Store addr of new procedure there
                    pshs      b             Temp save b
                    addd      #$0003              Add 3 to size of module so far (for CRC)
                    std       M$Size,u            Save as current size of module
                    std       $D,u                ??? (Size of I-code ???)
                    addd      <u000A              Add size to total # bytes used by I-Code
                    std       <u000A              Save new # bytes used by I-Code
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
                    stx       <u004A              ??? Save end of module ptr?
                    puls      pc,u,x              Restore regs & return

ERMFUL               ldb       #$20                BASIC09 memory full error (or too many modules)
                    lbra      L0A86

* Entry: Y=Ptr to module name
* Exit:  D=Ptr to string/file name
*          Carry set if adding new module to module list
*          Carry clear if replacing existing module in module list
*        X=Ptr to module directory entry we are adding/changing
*        Y=Ptr to end of filename+1
DIRSCH               pshs      u,y                 Preserve regs
                    ldx       <u0004              Get ptr to list of modules in BASIC09 workspace
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
                    ldd       <u0008              Get ptr to start of I-Code workspace
                    addd      <u000A              Add to total size of used I-Code workspace
                    tfr       d,y                 Move ptr to end of I-Code workspace to Y
                    ldx       ,x                  Get ptr to module we are adding to I-Code workspace
                    sty       [,s]                Save ptr to where it is going over old one on stck
                    ldd       M$Size,x            Get size of module we are adding
                    bsr       FLOTUP         "FLOAT" it up to bottom of free space
                    pshs      y,x,d
                    ldx       <u0004              Get ptr to list of modules in BASIC09 workspace
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
                    beq       L1022               If result=0 then restore regs & return
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
                    bra       L1000

FLOTU3               lda       ,y                  Get byte from source location
                    sta       ,x                  Save in destination location
                    leau      1,u                 Bump counter up
                    tfr       y,x                 Move source location to dest location
L1000               tfr       x,d                 ??? Move src ptr to D
                    addd      5,s                 Add to size of module
                    cmpd      9,s                 Compare with dest. address
                    blo       L100B               Fits, skip ahead
                    addd      1,s                 Won't, add to distance between src/dest
L100B               tfr       d,y                 Move end address (?) to Y
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
L1022               leas      4,s                 Eat temp vars
                    puls      pc,u,y,x,d          Restore regs & return

* Enter Debug mode?
L1026               pshs      u,y,x,d
                    lda       <u0036              Get last error code
                    cmpa      #$39                System stack overflow error?
                    beq       L1068               Yes, skip ahead
                    tst       <u00A0              ??? Some flag set?
                    bne       L10AA               Yes, skip ahead
                    inc       <u00A0              Set flag
                    lda       <u0035              Get last signal received
                    bne       L1064               Was a signal, skip ahead
                    ldd       <u00B3              Get # steps to do @ a time for trace
                    subd      #1                  Bump down by 1
                    bhi       L1089               Was >1, skip ahead
                    bmi       L104E               Was 0 or lower, skip ahead
L1041               lbsr      L0DBB
                    leax      >L0791,pc           Force to Alpha mode (if VDG window) & print BREAK
                    lbsr      L135A
                    lbsr      L124D
* Debug mode command loop
L104E               leax      >L07A4,pc           Point to 'D:'
                    leay      >L06C1,pc           Point to start of debug command table
                    lbsr      RUNCMD               Go process debug mode command
                    bcc       L104E               Legit cmd executed, get next debug mode cmd
                    lda       <u0035              Get last signal received
                    bne       L1064               There was one, go check for abort
                    lbsr      CMDERR               None, print 'What?'
                    bra       L104E               Go process next debug mode command

L0134               jsr       <u0024
                    fcb       $0C

L1064               cmpa      #S$Abort            <CTRL>-<E> signal?
                    bne       L1041               No, enter debug mode
* Debug 'Q' command (quite debug)
L1068               bsr       L0134
                    lda       #$03                Error path #3 we will check for
L106D               cmpa      <u00BE              Compare with I$Dup error path #
                    beq       L1074               If not path we are looking for, skip ahead
                    os9       I$Close             Same path, close it
L1074               inca                          Next path
                    cmpa      #16                 Done all 16 possible?
                    blo       L106D               No, keep going
                    lbra      EXIT               Done, reset temp buffers & ptrs to defaults

* Debug STEP command
* Entry: Y=Ptr to next char on line entered by user
L107C               lbsr      L0A90               Go check next char in STEP command
                    bne       L108E               If anything but space or comma, STEP 1
                    leax      ,y                  Otherwise, point X to ASCII of steps specified
                    lbsr      L1748               Go get # steps to do into D
                    bcc       L1091               No error, continue
                    rts                           Else exit

L1089               bsr       L1091
* Debug mode <CR> goes here (single step)
L108B               clrb
                    bra       L1090

L108E               ldb       #1                  Step rate of 1
L1090               clra
L1091               std       <u00B3              Save # steps to do
                    lsl       <u0034              Set high bit of signal flag
                    coma
                    ror       <u0034
                    bra       L10A6               Continue

* Debug mode CONT command (continuous run)
L109A               lbsr      L0DBB               Reset temp buffer stuff
                    lsl       <u0034              Clear high bit of signal flag
                    lsr       <u0034
                    ldd       #$0001              1 step till we print out
                    std       <u00B3              Save it
L10A6               leas      2,s
                    clr       <u00A0
L10AA               puls      pc,u,y,x,d

L10AC               ldy       <u0019
                    jsr       ,y
L10B1               pshs      u,y,x,d
                    cmpy      <u0046              ?? Get current pos in some table
                    beq       L10E2               If no entries, exit
                    ldb       <u007D              Get size of temp buff
                    ldx       <u0080              Get ptr to start of temp buff
                    ldu       <u0082              Get ptr to end of temp buff+1
                    pshs      u,x,b               Preserve
                    stu       <u0080              Temporarily set up temp buff to append to current
                    lbsr      L0DBB
                    lda       #'=                 Append '=' to temp buff
                    lbsr      L1373
                    ldb       ,y
                    addb      #$01
                    cmpb      #$06
                    bhs       L10D7
                    leax      ,y
                    lbsr      L13AA
L10D7               lbsr      L1264
                    puls      u,x,b               Get back temp buff stats
                    stb       <u007D              Restore temp buff to normal
                    stx       <u0080
                    stu       <u0082
L10E2               puls      pc,u,y,x,d          Restore regs & return

* Debug LIST command
L10E4               lbsr      L124B               Go print PROCEDURE & name
                    tst       <$17,x              Is procedure packed?
                    bmi       L110A               Yes, exit without error
                    ldx       <u005E
L10EE               clr       <u0074
* List out each line loop
L10F0               tst       <u0035              Any signals?
                    bne       L110A               Yes, exit without error (Can't list packed modules)
                    leay      ,x                  Point Y to beginning of I-Code module
                    lbsr      L1BC9
                    bsr       L110C
                    exg       x,y
                    cmpx      <u0060
                    blo       L10F0
                    cmpx      <u005C
                    bne       L110A
                    cmpy      <u0060
                    blo       L10F0
L110A               clra                          No error & return
                    rts

L012B               jsr       <u0021
                    fcb       $06

L110C               pshs      u,y,x               Preserve regs
                    lbsr      L0DBB               Reset temp buffer to empty
                    ldx       <u002F              Get current module ptr
                    tst       <$17,x              Is it packed?
                    bmi       L1193               Yes,  restore regs & exit
                    ldx       ,s                  Get original X back
                    tfr       y,d
                    subd      ,s
                    bmi       L1190               Wrap to negative?
                    pshs      x,d
                    addd      #40                 If we needed 64 bytes...
                    cmpd      <u000C              would it fit in BASIC09 workspace?
                    lbhs      ERMFUL               No, return with BASIC09 memory full error
                    tst       <u0084
                    bmi       L1158
                    lda       #C$SPAC
                    cmpx      <u005C
                    bhi       L113F
                    beq       L113D
                    cmpy      <u005C
                    bls       L113F
L113D               lda       #'*                 Append '*' to temp buffer
L113F               lbsr      L1373               Go append it
                    cmpx      <u0060
                    bhs       L1158
                    tfr       x,d
                    subd      <u005E
                    ldx       <u0082              Get current pos. in temp buffer
                    bsr       L012B               JSR <u0021 / function 6
                    lda       #C$SPAC             Append space to temp buffer
                    sta       ,x+
                    stx       <u0082              Save update temp buff ptr
                    lbsr      L1270               Print message out
L1158               puls      y,d
                    cmpy      <u0060
                    bhs       L1190
                    ldu       <u004A
                    lbsr      L19EF
                    lbsr      L11F2
                    stu       <u005C
                    leax      d,u
                    stx       <u0060
                    stx       <u004A
                    leay      ,u
                    tst       <u0084
                    bmi       L1183
                    leax      ,y
                    lbsr      L1677
                    bne       L1183
                    leax      >L02EB,pc           Point to 'ERR' in basic09 commands
                    lbsr      L126B               Print it out??
L1183               lbsr      L0DBB
                    lbsr      L1AC6
                    lbsr      L128B
                    bsr       L11D5
                    dec       <u0082+1
L1190               lbsr      L1264
L1193               puls      pc,u,y,x

* Debug mode - PRINT/TRON/TROFF/DEG/RAD/LET commands
L1195               ldx       <u002F              Get ptr to start of 'current' module
                    tst       <$17,x              Is it packed?
                    bpl       L119E               No, skip ahead
                    coma                          Yes, set carry & return
                    rts

L119E               ldy       <u0080              Get ptr to start of temporary buffer
                    lbsr      L0122               JSR <1E, function $A
                    bsr       L11F2
                    ldx       <u004A
                    lbsr      L1677
                    beq       L11D5
                    stx       <u005E
                    stx       <u005C
                    leay      ,x
                    ldx       <u00AB
                    stx       <u0060
                    stx       <u004A
                    bsr       L012E
                    ldx       <u002F              Get ptr to current module
                    lda       <$17,x              Get original flags
                    clr       <$17,x              Clear flags out
                    tsta                          Were the flags special in any way?
                    bne       L11D5               Yes, skip ahead
                    leax      <L11D5,pc           No, point to the routine instead
                    lbsr      SETEXT
                    ldx       <u005E
                    bsr       L0137               JSR <$24, function 8
                    lbra      EXIT               Swap stacks, reset temp buffer, return from there

L012E               jsr       <u0021
                    fcb       $04

L0137               jsr       <u0024
                    fcb       $08

L11D5               pshs      u,y,x,d             Preserve regs
                    ldu       <u0046              Get reset value ($300) table ptr
                    pulu      y,x,d               Get regs from there
                    sty       <u000A              Save # bytes used by all code in workspace
                    stx       <u000C              Save # bytes free in workspace
                    std       <u004A              Save ptr to next free byte in workspace
                    pulu      y,x,d               Get 6 more bytes
                    sty       <u0060
                    stx       <u005E
                    std       <u005C
L11EB               stu       <u0046
                    stu       <u0044
                    clra                          No error,restore regs & return
                    puls      pc,u,y,x,d

L11F2               pshs      u,y,x,d
                    ldu       <u0046
                    ldd       <u005C
                    ldx       <u005E
                    ldy       <u0060
                    pshu      y,x,d
                    ldd       <u004A
                    ldx       <u000C
                    ldy       <u000A
                    pshu      y,x,d
                    bra       L11EB

* Debug mode - STATE command
L120A               ldy       <u0031
                    leax      >L0756,pc           Point to 'PROCEDURE'
L1211               bsr       L1223
                    lbsr      L135A
                    ldx       3,y
                    bsr       L1256
                    leax      <L0799,pc           Point to 'called by'
                    ldy       7,y
                    bne       L1211
L1223               lbra      L0DBB

L0799               fcs       'called by'

* Debug mode - BREAK command
L1226               lbsr      L010D               JSR <1E, function 2
                    beq       L1249
                    lbsr      DIRSCH
                    bcs       L1249
                    ldx       ,x
                    ldy       <u0031
L1235               ldy       7,y
                    beq       L1249
                    cmpx      3,y
                    bne       L1235
* 6309, change to OIM #1,,y
                    lsl       ,y                  Set hi bit @ Y
                    coma
                    ror       ,y
                    leax      >L07A2,pc           Point to 'ok'
                    bra       L125F

L1249               coma
                    rts

L124B               bsr       L1223
L124D               leax      >L0756,pc           Point to 'PROCEDURE'
                    lbsr      L135A
                    ldx       <u002F              Get ptr to current module
L1256               pshs      x                   Save it
                    leax      <$19,x              Point to main code area
                    bsr       L1261
                    puls      pc,x

* Copy string pointed to by X to temp buffer & print it to std error
L125F               bsr       L1223               Set output txt size to 1, curr. temp buff pos=start
L1261               lbsr      L1392               Copy text string to temp buffer @ [u0080]
L1264               lbsr      L1371               Append a CR on the end of output buffer
                    bsr       L1270               Print out the buffer to std error
                    bra       L1223               Reset temp buffer size & ptrs to defaults & return

L126B               bsr       L1223
                    lbsr      L1392
* Print message in temp buffer to std error path
* NOTE: MAY WANT TO CHECK INTO USING <7D FOR SIZE
L1270               pshs      y,x,d               Preserve regs
                    ldd       <u0082              Get ptr to end of temp buffer+1
                    subd      <u0080              Calculate size of temp buffer
                    bls       L1285               If 0 or >32k, restore regs & exit
                    tfr       d,y                 Move size to proper reg for WritLn
                    ldx       <u0080              Point to start of text
                    lda       #$02                Std error path
                    os9       I$WritLn            Write out the temporary buffer
                    bcc       L1285               No error, restore regs & exit
                    bsr       L1287               Print the error message out
L1285               puls      pc,y,x,d            Restore regs & exit

L1287               os9       F$PErr              Print error message
                    rts

L128B               ldy       <u005C
                    cmpy      <u0060
                    bhs       L12CF
                    ldb       ,y
                    cmpb      #$3A
                    bne       L12A3
                    leay      1,y
                    lbsr      L13CF
                    lbsr      L135C
                    ldb       ,y
L12A3               tst       <u0084
                    bmi       L12B8
                    bsr       L12F9
                    ldb       <u0074
                    pshs      b
                    bsr       L12D8
                    puls      a
                    sta       <u0074
                    tfr       b,a
                    lbsr      L134E
L12B8               ldb       ,y+
                    bmi       L12C4
                    bsr       L12F9
                    bsr       L12D8
                    bsr       L130C
                    bra       L12C7

L12C4               lbsr      L1489
L12C7               cmpy      <u0060
                    blo       L12B8
L12CC               sty       <u005C
L12CF               lbra      L1371

L12D4               leas      2,s
                    bra       L12CC

L12D8               sta       ,-s
                    bmi       L12F6
                    anda      #3
                    beq       L12F6
                    cmpa      #1
                    bne       L12E8
                    inc       <u0074
                    bra       L12F6

L12E8               decb
                    bpl       L12EC
                    clrb
L12EC               cmpa      #3
                    beq       L12F6
                    dec       <u0074
                    bpl       L12F6
                    clr       <u0074
L12F6               lda       ,s+
                    rts

L12F9               leax      >L03F5,pc           Point to 3 byte packets for <u001B calls - $12
                    tstb                          If positive, skip ahead
                    bpl       L1302
                    subb      #$2A                Otherwise, bump down by 42
L1302               lda       #$03                Multiply by size of each entry
                    mul
                    leax      d,x                 Point to entry
                    lda       ,x                  Get 1st byte & return
                    rts

L130A               bsr       L12F9
L130C               leax      1,x
                    anda      #$60
                    beq       L1318
                    cmpa      #$60
                    bne       L132A
                    leay      2,y
L1318               lda       -1,x
                    pshs      a
                    ldd       ,x
                    leax      d,x
                    puls      a
                    anda      #$18
                    cmpa      #$10
                    beq       L1392
                    bra       L1358

L132A               cmpa      #$20
                    bne       L1332
                    ldd       ,x
                    jmp       d,x

L1332               bsr       L133A
                    bsr       L1336
L1336               lda       ,x+
                    bne       L1373
L133A               lda       <u007D
                    cmpa      #$41
                    bcs       L1357
                    lda       #$0A
                    bsr       L1373
                    clr       <u007D
                    tst       <u0084
                    bmi       L1357
                    lda       <u0074
                    adda      #3
L134E               lsla
                    adda      #6
                    ldb       #$10
                    bsr       L011F
                    clra
L1357               rts

L1358               bsr       L135C
L135A               bsr       L1392
L135C               pshs      u,d
                    bsr       L133A
                    bcc       L136F
                    ldu       <u0082
                    lda       #C$SPAC
                    cmpa      -1,u
                    beq       L136F
                    cmpu      <u0080
                    bne       L1377
L136F               puls      pc,u,d

* Append byte in A to temp buffer, check for overflow
L1371               lda       #C$CR
* Entry: A=Char (hi-bit stripped)
L1373               pshs      u,d                 Preserve regs
                    ldu       <u0082              ??? Get ptr to temp buffer
L1377               sta       ,u+                 Save char in buffer
                    ldd       <u0082              Get current pos in temp buffer
                    subd      <u0080              Calc. current size of temp buffer
                    tsta                          Past our max (255 bytes)?
                    bne       L1384               Yes, exit
                    inc       <u007D              No, bump up char count
                    stu       <u0082              Save current pos. in temp buffer+1
L1384               puls      pc,u,d              Restore & return

L1386               lda       #$2E
                    bsr       L1373
L138A               ldx       ,y++
                    ldd       <u0062
                    leax      d,x
                    leax      3,x

* Entry: X=ptr to text to output
* Exit: text output is in temp buffer from [u0080] to [u0082]-1
*       size of output string is in u007D
L1392               pshs      x                   Preserve ptr to text to output
L1394               lda       ,x                  Get 1st char from X
                    anda      #$7F                Strip hi bit
                    bsr       L1373               Add byte to temp buffer; check if full
                    tst       ,x+                 Was the high bit set? (last char flag)
                    bpl       L1394               No, keep building output buffer
                    puls      pc,x                Done, restore original text ptr & return

L011F               jsr       <u002A
                    fcb       $02

* Called from Debug mode (?) -something with REAL #'s?
L13A0               ldb       #3
                    ldx       <u0044
                    pshs      y,b
                    leay      -1,y
                    bra       L13AC

L13AA               pshs      y,b
* on 6309, use LDQ/STQ, on 6809, uses std -2/-4/-6,x leay -6,x (saves 5 cycles)
L13AC               ldd       4,y
                    std       ,--x
                    ldd       2,y
                    std       ,--x
                    ldd       ,y
                    std       ,--x
                    leay      ,x
                    puls      b
                    bra       L13DC

L13BE               ldb       ,y
                    clra
                    bra       L13D1

L13C3               leax      >L0203,pc           Point to 'GOSUB'
                    bra       L13CD

L13C9               leax      >L01FD,pc           Point to 'GOTO'
L13CD               bsr       L1358
L13CF               ldd       ,y++
L13D1               pshs      y
                    ldy       <u0044
                    leay      -6,y
                    std       1,y
                    ldb       #2
L13DC               bsr       L011F               JSR <$2A, function 2, sub-function 2
                    puls      pc,y

L13E1               bsr       L13F1
L13E3               lda       ,y+                 Get char
                    cmpa      #$FF                EOS?
                    beq       L13F1               Yes, add " to temp buffer
                    bsr       L1373               No, add char to buffer
                    cmpa      #'"                 Was it a ?
                    bne       L13E3               No, keep printing chars
                    bra       L13E1               Yes, add " & continue

L13F1               lda       #'"                 Add " to temp buffer
L13F3               lbra      L1373

L13F6               lda       #'$                 Add $ to temp buffer
                    bsr       L13F3
                    ldb       #$14
                    bsr       L011F               JSR <$2A, function 2, sub-function $14
                    leay      2,y
                    rts

L1402               leax      >L027E,pc           Point to 'BASE'
                    lbsr      L135A
                    lda       -1,y
                    adda      #$FB
                    bra       L13F3

L140F               leax      >L020A,pc           Point to 'RUN'
L1413               lbsr      L135A
                    lbra      L138A

L1419               leax      >L01AC,pc           Point to 'NEXT'
                    leay      1,y
                    bsr       L1413
                    leay      6,y
                    rts

L1424               leax      >L02B4,pc           Point to 'THEN'
                    lbsr      L1358
                    lda       ,y
                    cmpa      #$3A
                    beq       L1433
                    inc       <u0074
L1433               rts

L1434               fcs       '(*'

L1436               leax      <L1434,pc           Point to alternative REM statement
                    bra       L1440

L143C               leax      >L0284,pc           Point to 'REM'
L1440               lbsr      L135A
L1443               ldb       ,y+
L1445               decb
                    beq       L1433
                    lda       ,y+
                    bsr       L13F3
                    bra       L1445

* File opening mode table: 3 bytes per entry
* Byte 1   : Actual mode bit pattern
* Bytes 2&3: Offset (from itself) to keyword describing mode
*   NOTE: keywords are high bit terminated
L144E               fcb       UPDAT.
L144F               fdb       L03E4-*             Points to 'Update' string
L1451               fcb       READ.
L1452               fdb       L0241-*             Points to 'Read' string
L1454               fcb       WRITE.
L1455               fdb       L0247-*             Points to 'Write' string
L1457               fcb       EXEC.
L1458               fdb       L03EC-*             Points to 'Exec' string
L145A               fcb       DIR.
L145B               fdb       L03F2-*             Points to 'Dir' string
L145D               fcb       $00                 End of table marker

L145E               lda       ,y+                 Get requested file access mode
                    pshs      a                   Preserve on stack
                    lda       #':                 Separator that starts modes
L1464               bsr       L13F3               Parse for char?
                    leax      <L144E-2,pc         Point early for reentry point of loop
L1469               leax      2,x                 Bump to next entry
                    lda       ,s                  Get requested mode
                    anda      ,x                  AND with mode in table
                    cmpa      ,x+                 Match so far?
                    bne       L1469               No, check next entry
                    tsta                          Matched cuz we are at end of table?
                    beq       L1487               Yes, exit routine
                    eora      ,s                  Mask out bits that are part of token, not mode
                    sta       ,s                  Preserve raw mode
                    ldd       ,x                  Get offset to text equivalent of mode
                    leax      d,x                 Point to it
                    lbsr      L1392
                    lda       #'+                 Now check for additional modes
                    tst       ,s
                    bne       L1464               Go check them  & update accordingly
L1487               puls      pc,a                Restore A and exit

L1489               pshs      u
                    ldu       <u0044
                    clr       ,-u                 Clear two bytes on stack
                    clr       ,-u
                    leay      -1,y
L1493               ldb       ,y
                    bpl       L14C4
                    lbsr      L12F9
                    tfr       a,b
                    lda       ,y+
                    bitb      #$80
                    bne       L1493
                    orb       #$80
                    pshu      d
                    bitb      #$18
                    bne       L1493
                    andb      #$7F
                    pshu      d
                    bitb      #$04
                    bne       L14B8
                    ldd       ,y++
                    std       2,u
                    bra       L1493

L14B8               leay      -1,y
                    sty       2,u
                    ldb       ,y+
                    lbsr      L1B68
                    bra       L1493

L14C4               sty       <u005C
                    leay      ,u
                    clra
                    clrb
                    std       ,--y
                    pshs      d
                    sta       <u00BF
                    sta       <u00B1
L14D3               ldd       ,u++
                    bitb      #$08
                    beq       L14FE
                    andb      #$07
                    cmpb      <u00BF
                    bhi       L14F2
                    bne       L14EF
                    cmpb      #$06
                    bne       L14EB
                    tst       <u00B1
                    beq       L14EF
                    bra       L14F2

L14EB               tst       <u00B1
                    beq       L14F2
L14EF               lbsr      L1581
L14F2               stb       <u00BF
                    orb       #$80
                    std       ,--y
                    lda       #$01
                    sta       <u00B1
                    bra       L14D3

L14FE               clr       <u00B1
                    bitb      #$03
                    beq       L152D
                    bitb      #$04
                    bne       L152D
                    bitb      #$10
                    bne       L1510
                    pulu      x
                    stx       ,--y
L1510               std       ,--y
                    andb      #$03
                    bsr       L1581
                    cmpa      #$BE
                    bne       L151F
                    ldx       #$54FF
                    stx       ,--y
L151F               ldx       #$4B80
                    bra       L1526

L1524               stx       ,--y
L1526               decb
                    bne       L1524
                    stb       <u00BF
L152B               bra       L14D3

L152D               bitb      #$10
                    bne       L1535
                    pulu      x
L1533               pshs      x
L1535               pshs      d
                    cmpa      #$89
                    blo       L153F
                    cmpa      #$8C
                    bls       L14D3
L153F               ldd       ,y++
                    tstb
                    bmi       L154A
                    beq       L1558
                    ldx       ,y++
                    bra       L1533

L154A               pshs      d
                    clr       $01,s
                    bitb      #$10
                    bne       L153F
                    andb      #$07
                    stb       <u00BF
                    bra       L152B

L1558               ldx       ,u++
                    beq       L1569
                    pshu      x
                    std       ,--y
                    bra       L152B

L1562               puls      y
                    ldb       ,y+
                    lbsr      L130A
L1569               ldd       ,s++
                    beq       L157C
                    bitb      #$04
                    bne       L1562
                    leay      ,s
                    exg       a,b
                    lbsr      L130A
                    leas      ,y
                    bra       L1569

L157C               ldy       <u005C
                    puls      pc,u

L1581               ldx       ,s
                    pshs      x
                    ldx       #$4E00
                    stx       $02,s
                    ldx       #$4DFF
                    stx       ,--y
* (orig: CMDSE9)
                    rts

L1590               lbsr      L0A9D
                    lbsr      DIRADD
                    ldy       ,x
                    tst       $06,y
                    bne       L15E5
                    pshs      x
                    lbsr      L1A2E
                    lbsr      L124B
                    ldy       <u005E
                    bsr       L15F3
L15AA               lda       <u0035              Get last signal code received
                    cmpa      #S$Abort            <CTRL>-<E>?
                    bne       L15B3               No, skip ahead
                    lbsr      L1993               Yes, ???
L15B3               leax      >L07A6,pc           Point to 'E:'
                    leay      >L0718,pc           Point to EDIT mode command table
                    lbsr      RUNCMD               Get next command from keyboard & execute it
                    bcc       L15AA               Legit command done, get next one
                    tst       <u0035              Signal received?
                    bne       L15AA               Yes, go process it
                    leax      <L15AA,pc           Point to routine (loop)
                    pshs      x                   Save it (for possible rts address?)
                    ldx       <u0080              Get ptr to start of temp buffer
                    lsl       ,x                  Clear out hi bit in 1st char in temp buffer
                    lsr       ,x
                    lbsr      L1748               ???
                    lbcs      CMDERR               If carry set, print 'What?'
                    lbsr      L1A0D
                    lda       ,x
                    cmpa      #C$CR
                    beq       L15F3
                    ldy       <u0080              Get temp buffer ptr
                    bra       L1601               Skip ahead

L15E5               coma
                    rts

L15E7               leax      -1,y
                    lsl       ,x
                    asr       ,x
                    lbsr      L16F2
                    lbsr      L16BD
L15F3               sty       <u005C
                    lbsr      L1682
                    leax      ,y
                    lbsr      L1BC9
                    lbra      L16AD

L1601               bsr       L1606
                    bcc       L15F3
                    rts

L0122               jsr       <u001E
                    fcb       $0A

L1606               tst       <u000C
                    beq       L1670
                    clr       <u00A0
                    bsr       L0122
                    ldx       <u004A
                    lda       ,x
                    cmpa      #$3A
                    bne       L165E
                    clra
                    clrb
                    sta       ,-s
                    ldy       <u005C
                    lbsr      L1A10
                    cmpy      <u0060
                    bcc       L162F
                    ldd       $01,x
                    cmpd      $01,y
                    bls       L162F
                    inc       ,s
L162F               ldy       <u005E
                    ldd       1,x
                    lbsr      L1A0D
                    tst       ,s+
                    bne       L1642
                    bhs       L1642
                    cmpy      <u005C
                    bhs       L165E
L1642               sty       <u005C
                    cmpy      <u0060
                    bhs       L165E
                    ldx       <u004A
                    ldd       1,x
                    cmpd      1,y
                    bne       L165E
                    pshs      y
                    lbsr      L1BC9
                    tfr       y,d
                    subd      ,s++
                    bra       L1660

L165E               clra
                    clrb
L1660               ldy       <u005C
                    lbsr      L19B1
                    ldx       <u005C
                    bsr       L1677
                    bne       L166E
                    leay      ,x
L166E               clra
                    rts

L1670               ldb       #$20                Memory full error
                    lbsr      L1287               Print error message
                    coma                          Return with carry set
                    rts

L1677               lda       ,x
                    cmpa      #$3A
                    bne       L167F
                    lda       3,x
L167F               cmpa      #$3D
                    rts

L1682               ldx       #$0000
                    ldy       <u005E
L1688               cmpy      <u005C
                    bhs       L1697
                    leax      1,x
                    lbsr      L1BC9
                    cmpy      <u0060
                    blo       L1688
L1697               sty       <u005C
                    stx       <u00B5
                    clra
                    rts

L169E               bsr       L16CE
                    bsr       L16BD
                    cmpx      <u005E
                    bhi       L16AD
                    pshs      y,x
                    lbsr      L124B
                    puls      y,x
L16AD               ldd       <u0060
                    pshs      d
                    sty       <u0060
                    lbsr      L10EE         Bind parameters
                    puls      d
                    std       <u0060
                    clra
                    rts

L16BD               pshs      x,b                 Preserve regs
                    ldx       <u0082              Get ptr to current pos in temp buffer
                    ldb       ,x                  Get char
                    cmpb      #C$CR               Carriage return?
                    bne       L16C9               No, skip ahead
                    puls      pc,x,b              Yes, restore regs & return

L16C9               leas      5,s                 Eat stack
                    lbra      CMDERR               Print 'What?' & return from there

L16CE               lda       ,y+                 Get char
                    cmpa      #C$SPAC             Space?
                    beq       L16CE               Yes, keep looking
                    cmpa      #'*                 '*'?
                    bne       L16E1               No, skip ahead
                    sty       <u0082              Found star, save ptr as current pos in temp bffr
                    ldx       <u005E              Get absolute exec address of basic module
                    ldy       <u0060              Get absolute address of $F offest in basic module
                    rts

L16E1               leax      -1,y
                    bsr       L16F2
                    bcs       L16F1
                    ldx       <u005C
                    cmpy      <u005C
                    bhs       L16F1
                    exg       x,y
                    clra
L16F1               rts

L16F2               clr       ,-s                 Clear flag?
                    ldd       ,x                  Get 2 chars
                    cmpa      #'+                 1st char a plus?
                    bne       L1707               No, skip ahead
                    ldy       <u0060              Get address of $F offset for basic module
L16FD               cmpb      #'*                 2nd char='*'?
                    bne       L1712               No, skip ahead
                    leax      2,x                 Yes, bump ptr up 2 chars
                    stx       <u0082              Save as new current pos in temp buffer
                    puls      pc,a

L1707               cmpa      #'-                 1st char dash?
                    bne       L1714               No, skip ahead
                    inc       ,s                  Yes, set flag
                    ldy       <u005E              Get address of $F offset for basic module
                    bra       L16FD               Go check for '*'

L1712               leax      1,x                 Bump ptr up
L1714               lda       ,x                  Get char from there
                    cmpa      #'0                 Is it numeric?
                    blo       L171E               No, skip ahead
                    cmpa      #'9                 Totally numeric?
                    bls       L1723               Yes, skip ahead
L171E               ldd       #$0001
                    bra       L1727

L1723               bsr       L1748
                    bcs       L1742
L1727               stx       <u0082              Save current ptr into temp buff
                    ldy       <u005C
                    tst       ,s+                 Check flag
                    beq       L173D
                    ldy       <u005E
                    pshs      d
                    ldd       <u00B5
                    subd      ,s++
                    bhs       L173D
                    clra
                    clrb
L173D               lbsr      L1BCF
                    clra
                    rts

L1742               ldy       <u005C
                    com       ,s+                 Eat stack & set carry
                    rts

L1748               ldy       <u0046              ??? Get some sort of variable ptr
                    bsr       L013A               JSR <2A, function 0 (Some temp var thing)
                    lda       ,y+                 ??? Get var type?
                    cmpa      #2                  Real?
                    beq       L1759               Yes, set carry & exit
                    clra                          Clear carry
                    ldd       ,y                  Get integer
                    bne       L175A               <>0, return with carry clear
L1759               coma                          Set carry & return
L175A               rts

L013A               jsr       <u002A
                    fcb       $00

L175B               clrb
                    bra       L1760

L175E               ldb       #1
L1760               leas      -$F,s
                    stb       ,s
                    lda       ,y
                    clr       1,s
                    cmpa      #'*
                    bne       L1770
                    sta       1,s
                    leay      1,y
L1770               ldb       ,y+                 Find first non-space char
                    cmpb      #C$SPAC
                    beq       L1770
                    tfr       b,a                 Move char to A
                    sty       <u0082              Save as next free pos in temp buffer
                    lbsr      L18AA
                    stu       2,s
                    lbmi      L1985
                    tst       ,s
                    beq       L1791
                    lbsr      L18AA
                    stu       4,s
                    lbmi      L1985
L1791               cmpa      #C$CR
                    beq       L179D
                    lda       ,y+
                    cmpa      #C$CR
                    lbne      L1985
L179D               ldu       <u0046
                    stu       $D,s
* TFM (W=entry (Y-1)-<u0082)
L17A1               lda       ,-y
                    sta       ,-u
                    cmpy      <u0082              ??? Back to beginning of temp buffer yet?
                    bhi       L17A1               No, keep copying
                    stu       <u0046
                    stu       <u0044
                    ldd       2,s
                    leau      d,u
                    leau      1,u
                    stu       6,s
                    ldy       <u005C
                    sty       $B,s
                    clr       $A,s
                    lbra      L1878

L17C1               lbsr      L0DBB
                    sty       <u005C
                    lbsr      L128B
                    ldy       <u0080              Get ptr to start of temp buffer
                    leay      5,y
                    lsl       $A,s                Dupe most sig bit into 2nd most sig bit???
                    asr       $A,s
L17D3               tst       <u0035              Any signals received?
                    bne       L183A               Yes, skip ahead
                    ldd       <u0082
                    subd      $02,s
                    ldx       <u0046
                    lbsr      L18BE
                    bcs       L182F
                    lda       #$81
                    sta       $A,s
                    tst       ,s
                    beq       L182F
                    ldd       <u0082
                    addd      4,s
                    subd      2,s
                    subd      <u0080
                    cmpd      #230
                    bhi       L182F
                    ldx       <u0082
                    exg       x,y
                    ldd       2,s
                    lbsr      FLOTUP
                    tfr       y,d
                    subd      2,s
                    tfr       d,y
                    ldu       6,s
                    pshs      x,d
L180B               lda       ,u+                 Get byte
                    sta       ,y+                 Copy it
                    cmpa      #$FF                Hit EOS marker?
                    bne       L180B               No, keep copying until we do
                    leay      -1,y
                    ldd       ,s++
                    subd      ,s
                    puls      x
                    lbsr      FLOTUP
                    sty       <u0082
                    ldd       4,s
                    leay      d,x
                    ldd       2,s
                    bne       L182B
                    leay      1,y
L182B               tst       1,s
                    bne       L17D3
L182F               tst       $A,s
                    bpl       L1872
                    ldy       8,s
                    ldd       ,s
                    bne       L1845
L183A               ldx       $D,s
                    stx       <u0046
                    stx       <u0044
                    leas      $F,s
                    lbra      L15F3

L1845               lbsr      L1270
                    sty       $B,s
                    tst       ,s
                    beq       L1872
                    leax      ,y
                    lbsr      L1BC9
                    lbsr      L19A5
                    sty       <u005C
                    ldy       <u0080
                    lbsr      L1606
                    sty       <u005C
                    ldy       8,s
                    lbsr      L1BC9
                    cmpy      <u005C
                    bne       L1882
                    tst       1,s
                    beq       L1882
L1872               ldy       8,s
                    lbsr      L1BC9
L1878               sty       8,s
                    cmpy      <u0060
                    lbcs      L17C1
L1882               lbsr      L0DBB
                    tst       $A,s
                    bne       L1899
                    leax      <L07AA,pc           Point to "can't find"
                    lbsr      L135A
                    ldy       <u0046
                    lbsr      L13E1
                    lbsr      L1264
L1899               ldy       $B,s
                    sty       <u005C
                    ldx       $D,s
                    stx       <u0046
                    stx       <u0044
                    leas      $F,s                Eat temp stack
                    lbra      L1682

L07AA               fcs       /can't find:/

L18AA               ldu       #-1                 Pre-init counter to -1
L18AD               cmpa      #C$CR               Char a CR?
                    beq       L18B9               Yes, set -1,y to a $FF, set carry & return
                    leau      1,u                 Bump counter up
                    lda       ,y+                 Get next char
                    cmpb      -1,y                Match char in B?
                    bne       L18AD               No, continue double checking
L18B9               clr       -1,y                Set -1,y to $FF
                    com       -1,y                & set carry & return
                    rts

* CMPR Y,D for this with 18D2
L18BE               pshs      d
                    bra       L18D2

L18C2               pshs      y,x
L18C4               lda       ,x+
                    cmpa      #$FF
                    beq       L18DA
                    cmpa      ,y+
                    beq       L18C4
                    puls      y,x
                    leay      1,y
L18D2               cmpy      ,s
                    bls       L18C2
                    coma
                    puls      pc,d

L18DA               puls      y,x
                    clra
                    puls      pc,d

L18DF               ldd       #100
                    ldx       #10
                    pshs      x,d
                    leax      ,y
                    ldy       <u00B5
                    lda       ,x
                    cmpa      #'*
                    bne       L18FA
* 6309 MOD - use TFR 0,Y - same speed, 2 bytes shorter
                    ldy       #$0000
L18F6               leax      1,x
                    lda       ,x
L18FA               cmpa      #C$SPAC
                    beq       L18F6
                    pshs      y
                    cmpa      #C$CR
                    beq       L191C
                    lbsr      L1748
                    bcs       L1981
                    std       2,s
                    lda       ,x+
                    cmpa      #C$CR
                    beq       L191C
                    lbsr      L1748
                    bcs       L1981
                    std       4,s
                    bmi       L1981
                    lda       ,x
L191C               cmpa      #C$CR
                    bne       L1981
                    bsr       L1995
                    ldd       ,s++
                    ldy       <u005E
                    lbsr      L1BCF
                    sty       <u005C
                    ldd       ,s
                    lbsr      L1A0D
                    clr       ,-s
                    cmpy      <u005C
                    bcs       L198A
                    bsr       L1960
                    cmpx      #$0000
                    ble       L198A
                    tst       <u0035
                    bne       L194C
                    inc       ,s
                    bsr       L1960
L194C               leas      5,s
                    ldx       2,s
                    lbsr      L1A2E
                    ldy       <u005E
                    ldd       <u00B5
                    lbsr      L1BCF
                    sty       <u005C
                    clra
                    rts

L1960               ldy       <u005C
                    ldx       3,s
L1965               clra
                    clrb
                    lbsr      L1A10
                    cmpy      <u0060
                    bhs       L1980
                    tst       2,s
                    beq       L1975
                    stx       1,y
L1975               lbsr      L1BC9
                    tfr       x,d
                    addd      5,s
                    tfr       d,x
                    bpl       L1965
L1980               rts

L1981               leas      6,s
                    bra       L1987

L1985               leas      $F,s
L1987               lbra      CMDERR

L198A               leax      <L078B,pc           Point to 'RANGE'
                    lbsr      L125F               Print it out to std error (From temp buffer)
                    bra       L194C

L078B               fcc       'RANGE'
                    fcb       $87                 Hit bit set- Bell

L1993               leas      4,s
L1995               lbsr      L0128               JSR <21, function 2 (dick around with module stuff?)
                    clra
                    rts

L199A               lbsr      L16CE
                    lbsr      L16BD
                    bsr       L19A5
                    lbra      L15F3

L19A5               ldd       <u004A
                    std       <u00AB
                    tfr       y,d
                    pshs      x
                    subd      ,s++
                    leay      ,x
L19B1               pshs      u,y,x,d
                    leax      d,y
                    pshs      x
                    ldy       <u00AB
                    ldd       <u004A
                    subd      ,s
                    beq       L19C3
                    lbsr      FLOTUP
L19C3               ldd       <u00AB
                    ldu       ,s
                    subd      ,s++
                    bls       L19D1
                    ldy       4,s
                    bsr       L0125
L19D1               ldd       <u00AB
                    subd      <u004A
                    ldy       4,s
                    leay      d,y
                    sty       4,s
                    subd      ,s++
                    pshs      d
                    addd      <u0060
                    std       <u0060
                    std       <u004A
                    ldd       <u000C              Get # bytes free in workspace for user
                    subd      ,s                  Subtract ?
                    std       <u000C              Save new # bytes free for user
                    puls      pc,u,y,x,d          Restore regs & return

L0125               jsr       <u001E
                    fcb       $06

L19EF               pshs      y,x,d
                    leay      d,y
                    leau      d,u
                    andb      #$03
L19F7               beq       L1A06
                    lda       ,-y
                    sta       ,-u
                    decb
                    bra       L19F7

L1A00               ldx       ,--y
                    ldd       ,--y
                    pshu      x,d
L1A06               cmpy      4,s
                    bne       L1A00
                    puls      pc,y,x,d

L1A0D               ldy       <u005E
L1A10               pshs      d
                    bra       L1A17

L1A14               lbsr      L1BC9
L1A17               cmpy      <u0060
                    bhs       L1A2B
                    lda       ,y
                    cmpa      #':
                    bne       L1A14
                    ldd       ,s
                    cmpd      1,y
                    bhi       L1A14
                    puls      pc,d

L1A2B               coma
                    puls      pc,d

* Part of RENAME (?)
L1A2E               pshs      u,y,x,d             Preserve regs
                    lbsr      SHUFLE               ??? Go move module in workspace?
                    ldx       ,x                  Get some sort of module ptr
                    stx       <u002F              Save as ptr to current procedure
                    ldd       M$Exec,x            Get exec offset
                    addd      <u002F              Calculate exec address in memory
                    std       <u005E              Save it
                    ldd       $F,x                Get ???
                    addd      <u002F              Add to current mod start
                    tfr       d,y                 Move to Y
                    std       <u0060              Save ???
                    std       <u004A
                    ldd       M$Size,x            Get size of module
                    subd      $F,x                Subtract ???
                    pshs      d                   Save on stack
* 6809/6309 NOTE: LDD <U0000 IS UNECESSARY ON LEVEL II OS9
                    ldd       <u0000              Get start of BASIC09 data mem ptr
                    addd      <u0002              Add size of data area
                    subd      ,s                  Subtract calculated size
                    tfr       d,u                 Copy ??? size to U
                    std       <u0066
                    puls      d                   Get ??? calculated size
                    bsr       L19EF
                    ldd       $D,x
                    subd      $F,x
                    subd      #3
                    std       <u0068
                    addd      <u0066
                    addd      #3
                    std       <u0062
                    ldd       M$Size,x            Get module size
                    subd      $D,x                Subtract ???
                    addd      #3                  ??? Add CRC bytes?
                    std       <u0064
                    ldy       <u005E
                    bsr       L1AC6
                    ldx       <u0062
                    ldd       -3,x
                    beq       L1A9E
L1A83               pshs      d
                    leau      ,x
                    leax      3,x
L1A89               ldb       ,x+
                    bpl       L1A89
                    lda       #2
                    cmpb      #$A4
                    bne       L1A95
                    lda       #4
L1A95               sta       ,u
                    puls      d
                    subd      #1
                    bgt       L1A83
L1A9E               ldx       <u0066
                    ldd       <u0068
                    leax      d,x
                    stx       <u00DA
                    stx       <u0066
                    addd      <u000C              Add to bytes free in workspace for user
                    std       <u000C              Save new # bytes free in workspace for user
                    clr       <u0068
                    clr       <u0069
                    puls      pc,u,y,x,d

* NOTE: CHECK IF ROUTINE CAN BE MOVED TO NEARER TABLE/SUBROUTINE
* L1AB2 & L1AB8 are only called within routine itself
* L1AC6 is called from way early in the code, and just before L1A83
L1AB2               ldb       ,y+
                    bpl       L1AB8
                    subb      #$2A
L1AB8               clra
                    leax      >L1BD5,pc           Point to some sort of table
                    ldb       d,x                 Get entry
                    lsrb                          Divide by 16
                    lsrb
                    lsrb
                    lsrb
                    lbsr      L1B75
L1AC6               cmpy      <u0060
                    blo       L1AB2
                    rts

* 8 bit offset jump table (base of JMP is L1ACC)
L1ACC               fcb       L1AE5-L1ACC
                    fcb       L1AE3-L1ACC
                    fcb       L1AE1-L1ACC
                    fcb       L1B0F-L1ACC
                    fcb       L1B00-L1ACC
                    fcb       L1B12-L1ACC
                    fcb       L1AFA-L1ACC
                    fcb       L1B19-L1ACC
                    fcb       L1B09-L1ACC
                    fcb       L1AED-L1ACC
                    fcb       L1B1F-L1ACC
                    fcb       L1AEA-L1ACC
                    fcb       L1AE8-L1ACC
                    fcb       L1AE6-L1ACC
                    fcb       L1ADB-L1ACC

* Routines called by above table follow here
L1ADB               lda       -1,y
                    adda      #$93
                    sta       -1,y
L1AE1               leay      1,y
L1AE3               leay      1,y
L1AE5               rts

L1AE6               dec       -1,y
L1AE8               dec       -1,y
L1AEA               dec       -1,y
                    rts

L1AED               ldd       ,y
                    addd      <u005E
                    tfr       d,x
                    ldd       -2,x
                    std       ,y++
                    dec       -3,y
                    rts

L1AFA               lda       ,y+
                    cmpa      #$85
                    bne       L1B03
L1B00               leay      9,y
                    rts

L1B03               clrb
                    bsr       L1B23
                    leay      7,y
                    rts

L1B09               lda       ,y+
                    cmpa      #$4F
                    bne       L1B11
                    leay      4,y
L1B11               rts

L1B0F               leay      5,y
                    rts

L1B12               lda       ,y+
                    cmpa      #$FF
                    bne       L1B12         ..No; continue
                    rts

L1B19               ldb       ,y
                    clra
                    leay      d,y
                    rts

L1B1F               ldb       -1,y
L1B21               andb      #$04
L1B23               lda       #$60
                    pshs      d             save regs
                    lda       #$85
                    sta       -1,y          of the name as a delimiter
                    ldx       <u0062
                    ldd       -3,x          get count of free memory
                    ldu       ,y
                    bra       L1B40

L1B33               puls      d
L1B35               subd      #$0001
                    beq       L1B65
                    leax      3,x
L1B3C               tst       ,x+
                    bpl       L1B3C
L1B40               cmpu      1,x
                    bne       L1B35
                    pshs      d
                    lda       ,x
                    anda      #$E0
                    cmpa      2,s
                    bne       L1B33
                    lda       ,x
                    anda      #$18
                    bne       L1B33
                    lda       ,x
                    anda      #$04
                    eora      3,s
                    bne       L1B33
                    tfr       x,d           get symbol table ptr
                    subd      <u0062        Subtract beginning of symtbl for fun
                    std       ,y++
                    leas      2,s
L1B65               leas      2,s
                    rts

L1B68               tstb                          High bit set?
                    bpl       L1B6D               No, skip ahead
                    subb      #$2A                Adjust it down if it was
L1B6D               leax      <L1BD5,pc           Point to table
                    abx                           Point X to offset
                    ldb       ,x                  Get single byte
                    andb      #$0F                Mask off high nibble
L1B75               leax      >L1ACC,pc           Point to vector offset table
                    ldb       b,x                 Point to routine that is close
                    jmp       b,x                 Go do it

L1B7D               pshs      u                   Preserve U
                    ldb       ,y+                 Get byte
L1B81               cmpb      ,u+                 If higher than byte in table, keep going
                    bhi       L1B81
                    puls      u                   Get U back
                    beq       L1B91               If byte matches table entry, return
                    bsr       L1B68               If not, go somewhere else

L1B8B               cmpy      <u0060
                    blo       L1B7D
                    coma
L1B91               puls      pc,u,x,d            Restore regs & return

* 1 byte/entry table
L1B93               fcb       $1f
                    fcb       $21
                    fcb       $3a
                    fcb       $ff                 End of table marker

L1B97               pshs      u,x,d
                    leau      <L1B93,pc           Point to table
                    bra       L1B8B

* 1 byte/entry table
L1B9F               fcb       $3E
L1BA0               fcb       $3f
L1BA1               fcb       $FF                 End of table marker

L1BA2               pshs      u,x,d
                    leau      <L1B9F,pc           Point to table
                    bra       L1B8B

L1BA9               pshs      u,x,d
                    leau      <L1BA0,pc           Point to 2nd entry in table
                    bra       L1B8B

* Table: 1 byte entries
L1BB0               fcb       $23,$85,$86,$87,$88,$89,$8A,$8B,$8C
                    fcb       $f2,$f3,$f4,$f5,$f6,$f7,$f8,$f9,$ff

L1BC2               pshs      u,x,d
                    leau      <L1BB0,pc           Point to table
                    bra       L1B8B

                    ifne      H6309
L1BC9               clrd
                    else
L1BC9               clra
                    clrb
                    endc

L1BCB               bsr       L1BA9
                    bcs       L1BD4         ..No; not a name, so return
L1BCF               subd      #$0001
                    bhs       L1BCB
L1BD4               rts

* Table - single byte entries - one routine uses it to reference another
* table (1ACC), but divides it by 16 to determine which of that table to use
* Table goes from 1BD5 to 1CA4
L1BD5               fcb       $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
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

L1CA5               pshs      x,d                 Preserve regs
                    ldb       [<4,s]              Get function code
L1CAA               leax      <L1CB5,pc           Point to table
                    ldd       b,x                 Make offset vector
                    leax      d,x           Save dsctbl end for caller
                    stx       4,s                 Modify RTS address
                    puls      pc,x,d              restore X & D and RTS to new address

* 2 byte/entry vector table (JMP >$1E calls have there function byte after
*  the JMP containing the offset to which of these entries to uses)
L1CB5               fdb       CMPRAM-L1CB5         $00 function
                    fdb       NAMSYM-L1CB5         $02 function
                    fdb       SEARC0-L1CB5         $04 function
                    fdb       MOVDWN-L1CB5         $06 function
                    fdb       L24BD-L1CB5         $08 function
                    fdb       DIM1-L1CB5         $0A function

* Data of some sort: Appears to be special symbols
L1CD0               fdb       33                  (# of entries-33)
                    fcb       $03                 (# bytes to skip to start of next?)

L1CD3               fcb       L2368-PRSHEX
                    fcb       $d9,$0a             (token & type of operator???)
                    fcs       '<>'

                    fcb       L2368-PRSHEX
                    fcb       $d9,$0a
                    fcs       '><'

                    fcb       L2368-PRSHEX
                    fcb       $e4,$0a
                    fcs       '<='

                    fcb       L2368-PRSHEX
                    fcb       $e4,$0a
                    fcs       '=<'

                    fcb       L2368-PRSHEX
                    fcb       $e1,$0a
                    fcs       '>='

                    fcb       L2368-PRSHEX
                    fcb       $e1,$0a
                    fcs       '=>'

                    fcb       L2368-PRSHEX
                    fcb       $52,$08
                    fcs       ':='

                    fcb       L2368-PRSHEX
                    fcb       $f1,$05
                    fcs       '**'

                    fcb       L2368-PRSHEX
                    fcb       $38,$01
                    fcs       '(*'

                    fcb       L2368-PRSHEX
                    fcb       $3e,$02
                    fcs       '\'

                    fcb       L2368-PRSHEX
                    fcb       $d3,$0a
                    fcs       '>'

                    fcb       L2368-PRSHEX
                    fcb       $d6,$0a
                    fcs       '<'

                    fcb       L2368-PRSHEX
                    fcb       $dd,$09
                    fcs       '='

                    fcb       L2368-PRSHEX
                    fcb       $e7,$05
                    fcs       '+'

                    fcb       L2368-PRSHEX
                    fcb       $ea,$05
                    fcs       '-'

                    fcb       L2368-PRSHEX
                    fcb       $ec,$05
                    fcs       '*'

                    fcb       L2368-PRSHEX
                    fcb       $ee,$05
                    fcs       '/'

                    fcb       L2368-PRSHEX
                    fcb       $f0,$05
                    fcs       '^'

                    fcb       L2368-PRSHEX
                    fcb       $4c,$0c
                    fcs       ':'

                    fcb       L2368-PRSHEX
                    fcb       $4f,$0c
                    fcs       '['

                    fcb       L2368-PRSHEX
                    fcb       $50,$0c
                    fcs       ']'

                    fcb       L2368-PRSHEX
                    fcb       $51,$0c
                    fcs       ';'

                    fcb       L2368-PRSHEX
                    fcb       $54,$0b
                    fcs       '#'

                    fcb       L2368-PRSHEX
                    fcb       $26,$01
                    fcs       '?'

                    fcb       L2368-PRSHEX
                    fcb       $37,$01
                    fcs       '!'

                    fcb       PRSLF-PRSHEX         Recurse to the search routine again (eat LF)
                    fcb       $00,$0c
                    fcb       $80+C$LF            Line feed

                    fcb       L2368-PRSHEX
                    fcb       $4b,$0c
                    fcs       ','

                    fcb       L2368-PRSHEX
                    fcb       $4d,$0c
                    fcs       '('

                    fcb       L2368-PRSHEX
                    fcb       $4e,$0c
                    fcs       ')'

                    fcb       PRSPER-PRSHEX
                    fcb       $89,$0c
                    fcs       '.'

                    fcb       L23BE-PRSHEX
                    fcb       $90,$06
                    fcs       '"'

                    fcb       PRSHEX-PRSHEX
                    fcb       $91,$06
                    fcs       '$'

                    fcb       L2368-PRSHEX
                    fcb       $3f,$02
                    fcb       $80+C$CR            Carriage return

* Jump table for type 1 commands (see L0140)
*                           Command  Token
L1D60               fdb       ERMAS9-L1D60         ???      0   Illegal statement construction error
                    fdb       L1E82-L1D60         PARAM    1
                    fdb       TYPES-L1D60         TYPE     2
                    fdb       L1E82-L1D60         DIM      3
                    fdb       PDATA-L1D60         DATA     4
                    fdb       PRINT-L1D60         STOP     5
                    fdb       STOP-L1D60         BYE      6
                    fdb       STOP-L1D60         TRON     7
                    fdb       STOP-L1D60         TROFF    8
                    fdb       PRINT-L1D60         PAUSE    9
                    fdb       STOP-L1D60         DEG      A
                    fdb       STOP-L1D60         RAD      B
                    fdb       STOP-L1D60         RETURN   C
                    fdb       L2123-L1D60         LET      D
                    fdb       ERMAS9-L1D60         ???      E   Illegal Statement Construction err
                    fdb       L1EE1-L1D60         POKE     F
                    fdb       L1EEA-L1D60         IF       10
                    fdb       CHLREF-L1D60         ELSE     11
                    fdb       STOP-L1D60         ENDIF    12
                    fdb       FOR-L1D60         FOR      13
                    fdb       WHILE-L1D60         NEXT     14
                    fdb       ERMDO-L1D60         WHILE    15
                    fdb       L1F3D-L1D60         ENDWHILE 16
                    fdb       STOP-L1D60         REPEAT   17
                    fdb       ENDLUP-L1D60         UNTIL    18
                    fdb       STOP-L1D60         LOOP     19
                    fdb       L1F3D-L1D60         ENDLOOP  1A
                    fdb       EXITI8-L1D60         EXITIF   1B
                    fdb       L1F3D-L1D60         ENDEXIT  1C
                    fdb       L1F4C-L1D60         ON       1D
                    fdb       L213C-L1D60         ERROR    1E
                    fdb       L1F87-L1D60         GOTO     1F
                    fdb       ERMAS9-L1D60         ???      20  Illegal Statement Construction err
                    fdb       L1F87-L1D60         GOSUB    21
                    fdb       ERMAS9-L1D60         ???      22  Illegal Statement Construction err
                    fdb       RUN-L1D60         RUN      23
                    fdb       L213C-L1D60         KILL     24
                    fdb       INPUT-L1D60         INPUT    25
                    fdb       PRINT-L1D60         PRINT    26 (Also '?')
                    fdb       L213C-L1D60         CHD      27
                    fdb       L213C-L1D60         CHX      28
                    fdb       L2093-L1D60         CREATE   29
                    fdb       L2093-L1D60         OPEN     2A
                    fdb       L2083-L1D60         SEEK     2B
                    fdb       READ-L1D60         READ     2C
                    fdb       PUT8-L1D60         WRITE    2D
                    fdb       GET-L1D60         GET      2E
                    fdb       GET-L1D60         PUT      2F
                    fdb       L20D2-L1D60         CLOSE    30
                    fdb       RESTOR-L1D60         RESTORE  31
                    fdb       L213C-L1D60         DELETE   32
                    fdb       L213C-L1D60         CHAIN    33
                    fdb       L213C-L1D60         SHELL    34
                    fdb       BASE-L1D60         BASE     35
                    fdb       BASE-L1D60         ???      36
                    fdb       REM-L1D60         REM      37 (Also '!')
                    fdb       REM-L1D60         (*       38
                    fdb       PRINT-L1D60         END      39

EREVRB               lda       <u000A+1            Get LSB of # bytes used by all programs (not data)
ERRDIE               pshs      a                   Save it
                    ldx       <u00A7
                    lda       #C$CR               Byte to look for
RUN1               lsl       ,x                  Clear out high bit? (if so, use AIM instead)
                    lsr       ,x            strip any high order bits set
                    cmpa      ,x+                 Find byte we want?
                    bne       RUN1               No, keep looking
                    ldx       <u00A7              Get ptr to end of string name+1
                    bsr       PRTLIN               Print string out
                    ldd       <u00B9        ERROR addr
                    subd      <u00A7        is there more than (size)?
                    pshs      b             save number of spaces to ERROR
                    ldx       <u00AF
                    stx       <u00AB
                    ldy       <u00A7
                    lda       #$3D
                    lbsr      OUTCOD
                    lbsr      REM
                    lbsr      OUTCOD
                    lda       #C$SPAC             Block copy Spaces (TFM)
                    ldx       <u0080              Get start address
ERRO07               sta       ,x+                 Fill with spaces
                    dec       ,s
                    bpl       ERRO07         until ERROR addr is reached
                    ldd       #$5E0D              Add ^ (CR) (part of debug?)
                    std       -$01,x
                    ldx       <u0080              Get start ptr again
                    bsr       PRTLIN               Go print the debug line
                    puls      d
                    bsr       L1CC1
                    ldx       <u0046
                    stx       <u0044
L1CC7               jsr       <u001B              ??? Reset temp buff to defaults, SP restore from B7
                    fcb       $06

L1CC1               jsr       <u001B              Print error code to screen
                    fcb       $02

PRTLIN               ldy       #$0100              Size=256 bytes
                    lda       <u002E              Get path
                    os9       I$WritLn            Write it & return
                    rts                     Any errors)

L1CC4               jsr       <u001B              ??? Save SP @ <u00B7, muck around
                    fcb       $04

DIM1               puls      x
                    bsr       L1CC4
                    lbsr      L1F90
                    lbsr      L214C
                    sty       <u00A7
                    ldx       <u00AB
                    stx       <u00AF        Also I-Code buffer ditto
COMPI1               bsr       STATEM               Go process command/variable/constant
                    lda       <u00A3              Get token
                    lbsr      OUTCOD               Add to I-code line bffr & make sure no overflow
                    cmpa      #$3E                Was it a $3E?
                    beq       COMPI1               Yes, go get next one
                    cmpa      #$3F                Was it a $3F?
                    bne       EREVRB               No, do something
                    bra       L1CC7               Yes, Call <u001B, function 6

STATEM               lbsr      PRSLF               Go find command (or variable/constant name)
                    lda       <u00A4              Get command type
                    cmpa      #$01                (Is it a normal command?)
                    bne       STATE1               No, check next
* Command type 1 goes here
                    ldb       <u00A3              Get entry # (token) into JMP offset table
                    clra                          Make 16 bit for signed jump
                    ifne      H6309
                    lsld                          Multiply by 2 (2 bytes/entry)
                    else
                    lslb
                    rola                    2
                    endc
                    leax      >L1D60,pc           Point to Basic09 COMMANDS vector table
                    ldd       d,x                 Get offset
                    jmp       d,x                 Execute command's routine

STATE1               cmpa      #$02                Command type 2?
                    lbne      L2126               No, go process functions, etc.
* Command type 2 goes here
STATE8               pshs      x
                    ldx       <u00AB
                    leax      -$01,x        remove last byte from I-Code
                    stx       <u00AB
                    puls      pc,x          return

TYPES               lbsr      L2167
                    cmpa      #$DD          is it followed by a "="?
                    lbne      L211F
                    bsr       STATE8
                    lda       #$53
* (orig: DIM)
                    lbsr      OUTCOD

L1E82               lbsr      L2167
                    cmpa      #$4D
                    bne       L1E9B
                    lbsr      L216E
                    bne       PRSP30         ..No commma - go handle left paren
                    lbsr      L216E
                    bne       PRSP30
* (orig: DIM2)
                    lbsr      L216E
PRSP30               lbsr      ERMRPR
                    bsr       L1EC9
L1E9B               lbsr      CHKVAR
                    beq       L1E82
                    cmpa      #$4C
                    bne       L1EC3         ..No; go look for a semi-colon
                    bsr       L1EC9         get type token
                    ldb       <u00A4              Get token
                    beq       DIM25               If 0, skip ahead
* (orig: DIM21)
                    cmpb      #$03
                    bne       ERITYP
                    cmpa      #$44
                    bne       DIM25         ..No; return
                    bsr       L1EC9
                    cmpa      #$4F          is it a '['?
                    bne       L1EC3         ..No; end of this entry
                    lbsr      L216E
* (orig: DIM3)
                    cmpa      #$50          is it followed by a "]"?
                    bne       ERITYP
DIM25               bsr       L1EC9
L1EC3               cmpa      #$51
                    beq       L1E82
                    bra       STATE8         Remove trailing (eol) token and return

L1EC9               lbra      PRSLF

ERITYP               lda       #$18
                    bra       ERMDO9

DATA0               lbsr      OUTCOD
PDATA               bsr       NEXT9
                    lbsr      CHKVAR
                    beq       DATA0
TLBNE               lda       #$55
L1EDC               lbsr      OUTCOD
                    bra       IFFAL1

L1EE1               lbsr      L213C
                    lbsr      CKCOMA         Insure comma follows
                    lbra      ASSIG1

L1EEA               bsr       ENDLUP
                    cmpa      #$45          is it a then token?
                    bne       ERMTHN
                    lbsr      OUTCOD         put then token in I-Code
                    lbsr      L214C         compile (optional GOTO) line ref
                    bcc       L1F3F         (STOP)
* (orig: FOR9)
                    lbra      STATEM         No line ref found - process new stmt beginning

ERMTHN               lda       #$26
                    bra       ERMDO9         (ERRDIE) exit via ERROR trap

CHLREF               bsr       IFFAL1
                    bra       EXITI9

FOR               lbsr      L2193
                    lbsr      PREFIX
                    lda       <u00A3
                    cmpa      #$46          is it followed by TO?
                    bne       L1F20
* (orig: ARRNAM)
                    bsr       FARGCN
* (orig: ERINUM)
                    lda       <u00A3
                    cmpa      #$47
                    bne       TLBNE
                    bsr       FARGCN
                    bra       TLBNE

FARGCN               bsr       L1EDC
NEXT9               lbra      L213C

L1F20               lda       #$27
                    bra       ERMDO9

WHILE               lbsr      L2193
                    bsr       IFFAL1
                    bsr       IFFAL1
IFFAL1               lbra      IFFALS

ERMDO               bsr       ENDLUP
                    cmpa      #$48
                    beq       L1F47
                    lda       #$1F
ERMDO9               lbra      ERRDIE

ENDLUP               bsr       NEXT9
                    bra       TLBNE

L1F3D               bsr       IFFAL1
L1F3F               bra       GOTO9

EXITI8               bsr       ENDLUP
                    cmpa      #$45
                    bne       ERMTHN
L1F47               bsr       CMPRA9
EXITI9               lbra      STATEM

L1F4C               ldd       <u00AB
                    pshs      y,d           save I-Code ptr & source ptr
                    lbsr      PRSLF         get next symbol
                    cmpa      #$1E          is it ERROR?
                    bne       ON1         ..No; go handle computed GOTO
                    leas      $04,s         Discard saved ICDPTR & SRCPTR
                    bsr       GOTO9         (STOP) get next symbol
                    cmpa      #$1F          is the next symbol a GOTO?
                    beq       L1F8A         ..Yes; go parse it
* (orig: ON9)
                    rts

ON1               puls      y,d
                    std       <u00AB        Save it
                    bsr       ENDLUP         parse <EXPR> followed by T.LBNE & 2 zero bytes
                    ldx       <u00AB
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
                    bsr       L1F8A         get line reference
                    lbsr      CHKVAR         is it followed by a comma?
                    beq       ON2         ..Yes; loop until it isn't
                    puls      pc,x

L1F87               lbsr      ERMASS
L1F8A               lbsr      L2156
GOTO9               lbra      STOP

L1F90               sty       <u00A7              Save ptr to end of string name
                    ldx       <u004A              ??? Get ptr to start of I-code
                    stx       <u00AF              Save it
                    stx       <u00AB              And again as current I-code line end ptr
                    clr       <u00BB              Clear <u00BB & <u00BC
                    clr       <u00BC
L1FF5               rts

* Entry: Y=Ptr to end of string name+1
CMPRAM               bsr       L1F90               Set up some ptrs
                    inc       <u00A0              ??? Set flag? (think it is 3-way flag)
                    lbsr      STOP               ??? Go process source line? (A returns token)
                    bsr       L1FC0               Go check for "(" command grouping start
                    clr       <u00A0              ??? Clear flag?
                    lda       <u00A3              Get 1st byte from command table (token)?
                    cmpa      #$3F                Was it a carriage return token?
                    lbne      EREVRB               No, go process token
CMPRA9               lbra      OUTCOD               Add token to I-code buffer, check for overflow

RUN               lbsr      ERMASS
                    pshs      x             save it for return
                    lbsr      L2193         get procedure name
                    ldb       #$23
                    stb       [,s++]        Reset T.RUN token
* Check for "(" token (start of group of operations)
L1FC0               cmpa      #$4D                Token $4D  - "(" group start token?
                    bne       L1FF5               No, return
* Process "( )" command grouping
RUN3               bsr       CMPRA9               No, go call OUTCOD (X=Tble ptr, D=Token/type bytes?)
                    ldd       <u00AB              Get ptr to current I-code line end
                    pshs      y,d                 Save with source ptr(?)
                    lbsr      PRSLF               Process next command/line #/variable name
                    ldd       #$0005              Token types 0 & 5
                    cmpa      <u00A4              Just processed command token type 0?
                    beq       PRSP10               Yes, skip ahead
                    stb       <u00A4              No, replace with type 5 (AND,OR,XOR,NOT)
                    bra       PRSP20               Skip ahead

PRSP10               lbsr      L2182               Go check for Illegal Statement Construction
PRSP20               puls      y,d                 Get ptr to last char+1 & current I-code line end
                    std       <u00AB              Save original I-code line end ptr
                    ldb       <u00A4              Get token type
                    cmpb      #$05                Type 5 (AND,OR,XOR,NOT)?
                    beq       L1FE8               Yes, skip ahead
                    lbsr      OUTCXS               No, go force token $E & check for I-code overflow
L1FE8               lbsr      FARG11
                    lbsr      CHKVAR
                    beq       RUN3         ..Yes; go get another parameter
                    pshs      a
                    lbra      FUNRE1         Check for ')' and put it in I-Code

INPUT               sty       <u00A9
                    lbsr      FORVAR
                    bne       INPUT1
                    sty       <u00A9
                    bsr       L2022         insure i/o separator follows
                    bsr       CMPRA9         (OUTCOD)
                    bsr       GOTO9         (STOP)
INPUT1               ldy       <u00A9
                    cmpa      #$90          String literal found?
                    bne       INPUT4
                    lbsr      PRSLF
                    lbsr      GOTO9
INPU15               bsr       L2022
INPUT2               lda       #$4B
                    bsr       L2080         (OUTCOD) put COMMA in I-Code
INPUT4               bsr       GET10
                    lbsr      PRTSEP         (another) comma?
                    beq       INPUT2
INPUT9               rts

L2022               lbsr      PRTSEP
                    beq       INPUT9
                    bra       L207D

PRINT               sty       <u00A9
                    lbsr      FORVAR         Channel ref?
                    beq       L203A
                    cmpa      #$49          Using?
                    beq       PRINT4
PRIN05               ldy       <u00A9
                    bra       L2045         No chl or using; go look for PRINT list

L203A               cmpa      #$49
                    bne       L2054
PRINT4               lbsr      ASSIG1
                    bra       L2054

PRINT3               bsr       L2080
L2045               lbsr      L245D
                    cmpa      #C$CR         end of line?
PRINT5               lbeq      STOP
                    cmpa      #'\           Other end of line?
                    beq       PRINT5
                    bsr       L2085
L2054               lbsr      PRTSEP
                    beq       PRINT3
                    rts

READ               sty       <u00A9
                    lbsr      FORVAR
                    beq       INPU15
                    ldy       <u00A9
                    bra       INPUT4

PUT8               sty       <u00A9
                    lbsr      FORVAR
                    beq       L2054
                    bra       PRIN05         get PRINT list
GET               bsr       PUT0
GET10               inc       <u00BC
                    lbra      L2180         get variable id

PUT0               lbsr      FORVAR
                    bne       ERMCHL
L207D               lbsr      CKCOMA
L2080               lbra      OUTCOD

L2083               bsr       PUT0
L2085               lbra      L213C

* Data table for file access modes?
L2088               fcb       $2c,%00000001       Read mode?
                    fcb       $2d,%00000010       Write mode?
                    fcb       $f7,%00000011       Update mode?
                    fcb       $f8,%00000100       Execution dir mode?
                    fcb       $f9,%10000000       Directory mode?
                    fcb       $00                 End of table marker

L2093               lbsr      PRSLF
                    cmpa      #$54
                    bne       ERMCHL
                    bsr       GET10
                    bsr       L207D
                    bsr       L2085
                    lda       <u00A3              Get token
                    cmpa      #$4C
                    bne       L2114
                    lda       #$4A
* (orig: OPEN10)
                    bsr       L2080         (OUTCOD)
                    clr       ,-s
L20AC               bsr       STOP
                    leax      <L2088,pc           Point to table (modes?)
OPEN20               cmpa      ,x++
                    bhi       OPEN20               We need higher entry #, keep looking
                    bne       L20C7               Illegal, return error
                    ldb       -1,x                Get mode (read/write/update)???
                    orb       ,s                  Merge with mode on stack???
                    stb       ,s                  Save new mode???
                    bsr       STOP         get next token
                    cmpa      #$E7          more modes?
                    beq       L20AC
* (orig: ERIMOD)
                    lda       ,s+           get composit mode byte
                    bne       L2080         (OUTCOD) ..done if non-zero
L20C7               lda       #$0F                Illegal mode error?
                    bra       ERMCH9         (ERRDIE)

CLOSE0               lbsr      CHKVAR
                    bne       L2114
                    bsr       L2080
L20D2               lbsr      FORVAR
                    beq       CLOSE0
ERMCHL               lda       #$1C                Missing Path Number error
ERMCH9               lbra      ERRDIE

RESTOR               bsr       L214C
                    bra       STOP         get next (eol) token, exit

BASE               lbsr      L245D
                    leay      1,y
                    suba      #$30                Convert ASCII digit to binary
                    beq       STOP               If 0, skip ahead
                    cmpa      #1            is it a '1?
                    lbne      ERIOPD               If anything but 0 or 1, Illegal operand error
                    bsr       ERMASS               If 1, skip ahead
                    lda       #$36
                    lbsr      OUTCOD         replace with BASE1 token
                    bra       STOP

REM               ldx       <u00AB              Get ptr to current I-Code end
                    lbsr      L245D         Skip spaces
                    clra
L20FE               lbsr      OUTCOD
                    inc       ,x            Update I-Code byte count
                    lda       ,y+                 Get char
                    cmpa      #C$CR               CR?
                    bne       L20FE               Nope, keep going
                    leay      -1,y                Bump ptr back to CR

STOP               lbsr      PRSLF               Check for command/constant/variable names
ERMASS               ldx       <u00AD              Get ptr to end of I-code line
                    stx       <u00AB              Make it the current end ptr
                    lda       <u00A3              Get token & return
L2114               rts

L2115               lda       <u00A4              Get token type
                    beq       L2114               If 0, return
ERMAS9               lda       #12                 Exit with Illegal Statement Construction error
                    bra       ERMCH9         (ERRDIE)

L211F               lda       #$1B                Missing Assignment Statement error
L2121               bra       ERMCH9

L2123               lbsr      PRSLF

* Token types >2 go here
L2126               bsr       L2115
                    inc       <u00BC        Set complex assignment switch
                    lbsr      VARREF
PREFIX               lda       <u00A3              Get token
                    cmpa      #$52                ??? Is it ':='?
                    beq       ASSIG1               Yes, skip ahead
                    cmpa      #$DD                ??? Is it '='?
                    bne       L211F               No, exit with Missing Assignment statement error
* (orig: ASSIG9)
                    lda       #$53                Token=$53
ASSIG1               lbsr      OUTCOD               Go append to I-Code buffer
L213C               lda       #$39
EXPRSN               ldx       <u0044
                    clrb                    end marker (user supplied token) precedence=0
                    lbsr      OPRA85         set end mark in opstack
EXPR10               bsr       L21B4
                    lbsr      OPRATR         get operator
                    bcc       EXPR10         Repeat until none is present
EXPR90               rts

L214C               lbsr      L245D
                    lbsr      L246E         is the next char a number
                    bcs       EXPR90         ..No; return (carry set)
                    lda       #$3A                Go append $3A token to I-Code buffer
L2156               bsr       L217D
                    lbsr      GETNUM
                    beq       REPFCT         Illegal number (real literal)
                    ldd       ,x
                    lbgt      L240C         Go put line number in I-Code; return
REPFCT               lda       #$10                Illegal Number error
                    bra       L2121         (ERRDIE) exit via ERROR trap

L2167               bsr       ARRNA9
                    bsr       L2115
ARRNA9               lbra      PRSLF

L216E               lda       #$8E
                    bsr       L2156
                    bsr       ARRNA9         (INSYM)
                    bra       CHKVAR         Test what you've gotten

IFFALS               clra
                    bsr       L217D
                    bsr       L217D
                    bra       L218E

L217D               lbra      OUTCOD

L2180               bsr       ARRNA9
L2182               bsr       L2115
                    bra       VARREF

FORVAR               bsr       STOP
                    cmpa      #$54
                    bne       CHLRE9
                    bsr       ASSIG1
* 6809/6309 MOD: If A not required, CLRA
L218E               lda       <u00A3
                    orcc      #Zero         not ALPHA
CHLRE9               rts

L2193               bsr       ARRNA9
                    lbsr      L2115         Insure its a variable
FORVA9               lbra      STOP

PRTSEP               lda       <u00A3
                    cmpa      #$51          Set found (eq)
                    beq       COMMA9         ..Yes; return
CHKVAR               lda       <u00A3
                    cmpa      #$4B          is it a ',' token?
COMMA9               rts

CKCOMA               bsr       CHKVAR
                    beq       COMMA9
                    lda       #$1D          Error: illegal literal
                    bra       L21CB         (ERRDIE)

NODE1               clrb                    Precedence = 0
                    bsr       PUSHOP         push left paren token ON opstack
                    lbsr      ERMASS         remove it from I-Code
L21B4               bsr       PREF20
                    bsr       L21CE
                    cmpa      #$4D
                    beq       NODE1         ..Yes; go handle a parenthetical expr
                    ldb       <u00A4
                    cmpb      #$06          is it a var ref token?
                    beq       FORVA9         ..Yes; ok-user type
                    cmpb      #$04          is it a reserved word?
                    bne       L2182         ..No; go process variable reference
* (orig: ERIOP9)
                    lbra      FUNREF         ..Yes; handle it & return

ERIOPD               lda       #$12                Illegal operand error
L21CB               lbra      ERRDIE

L21CE               cmpa      #$CD
                    beq       PREFX2         ..Yes; process as a polish operator
                    cmpa      #$EA
                    bne       COMMA9
* (orig: CHKRPR)
                    lda       ,y            get next source char
                    lbsr      L246E         is it a digit?
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

PUSHOP               ldx       <u0044
                    std       ,--x          push onto opstack
                    stx       <u0044        update opstack ptr
                    rts

VARREF               ldd       #$8500
VARRE0               pshs      d
                    ldd       <u00A1        get symbol ptr
                    bsr       PUSHOP         Push SYMPT onto opstack
                    puls      d
                    bsr       PUSHOP         Push smtyp ON opstack
                    lbsr      ERMASS         remove it from I-Code
                    lbsr      STOP         get next symbol
                    clrb                    Number of subsrcripts = 0
                    cmpa      #$4D          is it a '(' (array reference)?
                    beq       VARR25         ..Yes; go get subscript(s)
L2214               cmpa      #$89
                    bne       VARRE9
                    bsr       CKCASS
                    bsr       VARRE9
* (orig: VARRE2)
                    bsr       PREF20
                    lbsr      L2115         Add undefined name to symbol table
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
                    bra       L2214         Go see if its a record or not

VARRE9               clr       <u00BC
                    ldx       <u0044        get operator stack ptr
                    addb      ,x++          Pop variable ref token
                    lbsr      OUTCDB         (OUTCOD b)
                    ldd       ,x++          get SYMPT to variable
                    stx       <u0044        save opstack ptr
                    lbra      L240C         Exit

CKCASS               tst       <u00BC
                    beq       NOTFN9         (rts) ..No; don't put in T.CXAS
                    clr       <u00BC        Clear content of assignment flag
OUTCXS               lda       #$0E
CKCAS9               lbra      OUTCOD

OPRATR               ldb       <u00A3              Get token
                    clra
                    cmpb      #$4E          is it a right paren (pseudo operator)?
                    beq       OPRAT3         ..Yes; go do it with 0 precedence
                    tstb                    Component?
                    bpl       OPRAT1         ..No; not an operator
                    bsr       L1CCD
                    bita      #$08          is it an operator?
                    bne       OPRAT3         ..Yes; good - go process it
OPRAT1               ldx       <u0044
OPRAT2               ldd       ,x++
                    cmpa      #$4D          is it an OPEN parenthesis (for precedence)?
                    beq       L22C5         ..Yes; error: missinng right parenthesis
                    bsr       CKCAS9         (OUTCOD) put token into I-Code
                    tstb                    This the end of the expression?
                    bne       OPRAT2         ..No; pop some more
                    cmpa      #$39
                    bne       NOTFN1
                    lbsr      STATE8         Remove (T.END) token from I-Code
NOTFN1               stx       <u0044
                    coma                    EXPRSN that there wasn't an operator
NOTFN9               rts

OPRAT3               anda      #$07
                    tfr       a,b
                    ldx       <u0044        get opstack ptr
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
                    stx       <u0044        save opstack ptr
* (orig: PRSSTR)
                    bsr       FUNRE9         (STOP) get next symbol
                    bra       OPRATR         Go see if it's another operator

OPRAT6               cmpa      #$39
                    beq       L2307         ..Yes; error: missing left paren
                    bsr       FARG09
                    bra       NOTFN1         return not found

OPRAT8               lda       <u00A3              Get token
OPRA85               std       ,--x
                    stx       <u0044        save the opstack ptr
OPRAT9               rts

ERMRPR               lda       <u00A3              Get token
                    cmpa      #$4E                ??? ^ or ** (power)?
                    beq       OPRAT9               Yes, return
L22C5               lda       #$25
ERMRP9               lbra      ERRDIE

L1CCD               jsr       <u001B
                    fcb       $12

FUNREF               lbsr      STATE8
                    lda       <u00A3              Get token
                    pshs      a                   Save it
                    bsr       FUNRE9         (STOP) get next token
                    ldb       ,s
                    bsr       L1CCD
                    leax      <FUNRE1,pc           Point to routine
                    pshs      x             push Return addr
                    anda      #$03          get number of args of function
                    beq       FARG0         Process 0 argument functions
                    cmpa      #2
                    beq       L231B         Process 2 argument functions
                    bhi       L2322         Process 3 argument functions
                    ldb       2,s
                    cmpb      #$92
                    beq       L2331
                    cmpb      #$94
                    beq       L2331
                    cmpb      #$BE
                    beq       FARGVR
                    bra       FARG1         Process 1 argument functions

FUNRE1               bsr       ERMRPR
                    puls      a             Restore SRCPTR & return
                    lbsr      OUTCOD
FUNRE9               lbra      STOP

CHKLPR               lda       <u00A3
                    cmpa      #$4D
                    beq       OPRAT9
L2307               lda       #$22
                    bra       ERMRP9         (ERRDIE) exit via ERROR trap

FARG0               leas      2,s
                    puls      a             Restore function token
FARG09               lbra      OUTCOD

FARG1               bsr       CHKLPR
FARG11               clra
                    lbsr      EXPRSN         Go get one expression
                    lbra      STATE8         Remove junk token from I-Code & return

L231B               bsr       FARG1
L231D               lbsr      CKCOMA
                    bra       FARG11         get 2nd arg & return

L2322               bsr       L231B
                    bra       L231D

FARGVR               bsr       CHKLPR
                    bsr       FUNRE9
                    cmpa      #$54
                    beq       FARG11
                    lbra      ERMCHL         Error: missing channel ref

L2331               bsr       CHKLPR
                    incb                    Pre-token
                    lbsr      OUTCDB         out to I-Code
                    lbra      L2180

ERBSYM               lda       #$0A                Unrecognized symbol error
                    bra       ERMRP9         (ERRDIE) exit via ERROR trap

* Search for operator's loop? (An LF is eaten and it returns here)
PRSLF               ldd       <u00AB              Get current I-code line's end ptr
                    std       <u00AD              Dupe it here
                    lbsr      L245D               Find first non-space/LF char
                    sty       <u00B9              Save ptr to it
                    lbsr      L2432               Check for variable name
                    lbne      PRSNAM               None, check for command names
                    lda       ,y                  Get first char of possible variable name
                    lbsr      L246E               Does it start with a number (0-9)?
                    bcc       PRSNUM               Yes, skip ahead
                    leax      >L1CD0+3,pc         No, point to Operator's table
                    lda       #$80                Get high bit mask to check for end of entry
                    lbsr      SEARC0               Go find entry
                    beq       ERBSYM               None, exit with Unrecognized symbol error
                    ldb       ,x                  Get offset
                    leau      <PRSHEX,pc           Point to base routine
                    jmp       b,u                 Go to subroutine

* '.' goes here
PRSPER               lda       ,y                  Get char from source
                    lbsr      L246E         is it a decimal digit?
                    bcs       L2368         ..No; go put record separater in I-Code
                    leay      -1,y          Point to decimal point
* Starts with numeric (0-9) value
PRSNUM               bsr       GETNUM
                    bne       NUMVA3         Real?
                    ldd       #$8F05              Token=$85, count=5
NUMVA0               sta       <u00A3
L2383               bsr       PRSST9
                    lda       ,x+           get next byte of number
                    decb
                    bpl       L2383         Loop until end of this entry
                    lda       #6            get 'literal' symbol type
                    sta       <u00A4              Save type (?) as 6
                    rts                     return

NUMVA3               ldd       #$8E02
                    tst       ,x            is this really a byte literal?
                    bne       NUMVA0         ..No; go put integer in I-Code
                    ldd       #$8D01        get byte lit token & size
                    leax      1,x
                    bra       NUMVA0

* Almost all operators come here
L2368               ldd       1,x                 Get the 2 mystery bytes
* Command found comes here with D=2 byte # in command table
L236A               std       <u00A3              Save token & type byte
                    bra       OUTCOD         Finish variable allocation

* '$' goes here
PRSHEX               leay      -1,y                Bump source ptr back by 1
                    bsr       GETNUM
                    ldd       #$9102
                    bra       NUMVA0

GETNUM               lbsr      L245D               Find 1st non-space/lf char
                    leax      ,y                  Point x to the char
                    ldy       <u0044        get error addr
                    bsr       L1CCA               Call vector <2A, function 00
                    exg       x,y
                    bcs       L23BA               If error from vector, illegal literal error
* (orig: ERILIT)
                    lda       ,x+
                    cmpa      #2
                    rts

L1CCA               jsr       <u002A
                    fcb       $00

L23BA               lda       #$16                Illegal literal error
                    bra       ERNOQ9

* '"' goes here
L23BE               bsr       L2368
                    bra       SKIPSP

L23C2               bsr       OUTCOD
SKIPSP               lda       ,y+                 Get char from source
                    cmpa      #C$CR               End of line already?
                    beq       L23D8               Yes, no ending quote error
                    cmpa      #'"                 Is it the quote?
                    bne       L23C2               No, keep looking
                    cmpa      ,y+                 Double quote?
                    beq       L23C2               Yes, do something
                    leay      -1,y                No, set src ptr back to next char
* (orig: ERNOQU)
                    lda       #$FF                Go save $FF at this point in I-code line
PRSST9               bra       OUTCOD

L23D8               lda       #$29                No Ending Quote error
ERNOQ9               lbra      ERRDIE               Deal with error

L23DD               lda       #$31                Undefined Variable error
                    bra       ERNOQ9

* Check for command names
PRSNAM               ldx       <u009E              Get ptr to commmands token list
                    lbsr      SCHALL               Go find command
                    beq       PRSNA2               No command found, skip ahead
                    stx       <u00A1              Save ptr to command's 2 byte # in table
                    ldd       ,x                  Get 2 byte # from command's entry in table
L23EC               std       <u00A3              Save token & type bytes
                    bra       OUTCOD               Go check size of I-code line

PRSNA2               tst       <u00A0
                    bmi       L23DD
                    ldx       <u0062
                    lbsr      SCHALL
                    bne       PRSNA3
                    tst       <u00A0
                    bne       L23DD
                    lbsr      ADDSYM
PRSNA3               ldd       #$8500
                    bsr       L23EC               Go append token $85, type 0 & check for overflow
                    tfr       x,d
                    subd      <u0062
                    std       <u00A1
L240C               bsr       OUTCOD
                    bsr       OUTCDB
                    lda       <u00A3              Get token & return
                    rts

OUTCDB               tfr       b,a
OUTCOD               pshs      x,d                 Preserve Table ptr & 2 mystery bytes
                    ldx       <u00AB              Get ptr to end of current I-code line
                    sta       ,x+                 Save token for operator
                    stx       <u00AB              Save new end of current I-code line ptr
                    ldd       <u00AB              Get it again
                    subd      <u004A              Calculate current I-code line size
                    cmpb      #255                Past maximum size?
                    bhs       L2428               Yes, generate error
                    clra                          No, no error
                    puls      pc,x,d              Restore regs & return

L2428               lda       #$0d                I-Code Overflow error
                    lbsr      L1CC1               Print error message
                    jsr       <u001B              ??? Reset temp buff to defaults, SP restore from B7
                    fcb       $06

NAMSYM               bsr       L245D               Search for 1st non-space/LF char
L2432               pshs      y                   Save ptr to it on stack
                    ldb       #2                  ??? Flag to indicate non-variable name
                    stb       <u00A5
                    clrb                          Set variable name size to 0
                    bsr       L2478               Check if it is an alphabetic char or underscore
                    bcs       NAMSY9               Nope, skip ahead
                    leay      1,y                 Yes, point to next char
NAMSY1               incb                          Bump up variable name size
                    lda       ,y+                 Get next char
                    bsr       L246A               Check if it is a letter, number or _
                    bcc       NAMSY1               Yes, check next one
                    cmpa      #'$                 Is it a string indicator?
                    bne       NAMSY2               No, skip ahead
                    incb                          Bump up variable name size to include '$'
                    lda       #4                  ??? Flag to indicate variable name?
                    sta       <u00A5
                    bra       L2453               Skip ahead

NAMSY2               leay      -1,y                Bump source ptr back by 1
L2453               lda       #$80                Get high bit (OIM on 6309)
                    ora       -1,y                Set high bit on last char of variable name
                    sta       -1,y                Save it back
NAMSY9               stb       <u00A6              Save size of variable name
                    puls      pc,y                Restore source ptr & return

* Find first non-space / non-LF char, and point Y to it
L245D               lda       ,y+                 Get char from source
                    cmpa      #C$SPAC             Is it a space?
                    beq       L245D               Yes, get next char
                    cmpa      #C$LF               Is it a line feed?
                    beq       L245D               Yes, get next char
                    leay      -1,y                Found legitimate char, point Y to it
                    rts

* Check if char is letter, number or _
L246A               bsr       L2478               Check if next char is letter or _
                    bcc       L2493               Yes, exit with carry clear
L246E               cmpa      #'0                 Is it a number?
                    blo       L2493               No, return with carry set
                    cmpa      #'9                 Is it a number?
                    bls       ALPHA8               Yes, exit with carry clear
                    bra       ALPHA7               No, exit with carry set

* Check if char is a letter (or underscore)
* Entry: A=last char gotten (non-space/Lf)
* Exit: Carry clear if A-Z, a-z or '_'
*       Carry set if anything else
L2478               anda      #$7F                Take out any high bit that might exist
                    cmpa      #'A                 Is it lower than a 'A'
                    blo       L2493               Yes, skip ahead (carry set)
                    cmpa      #'Z                 Is it an uppercase letter?
                    bls       ALPHA8               Yes, clear carry & exit
                    cmpa      #'_                 Is it an underscore?
                    beq       L2493               Yes, exit (carry is clear)
                    cmpa      #'a                 Is it a [,\,],^ or inverted quote ($60)?
                    blo       L2493               Yes, skip ahead (carry set)
                    cmpa      #'z                 Is it a lowercase letter?
                    bls       ALPHA8               Yes, exit
ALPHA7               orcc      #$01                Error, non-alpha char
                    rts

ALPHA8               andcc     #$FE                No error, alphabetic char
L2493               rts

ADDSYM               ldx       <u0062
                    ldd       -3,x
                    addd      #1                  INCD
                    std       -3,x
                    ldb       <u00A6              Get size of var name/ (or string?)
                    clra                          D=Size
                    addd      #3                  Add 3 to size
                    sty       <u00A9
                    bsr       EXPSYM
                    pshs      y
                    lda       <u00A5
                    clrb
                    std       ,y++
                    stb       ,y+
                    ldx       <u00A9
ADDSY1               lda       ,x+
                    sta       ,y+
                    bpl       ADDSY1
                    leay      ,x            get ptr/size ptr
                    puls      pc,x

L24BD               pshs      u,d
                    ldd       <u000C
                    subd      ,s
                    bcc       EXPDS1         ..No
                    lda       #$20          Err: unimplemented routine
                    lbra      ERRDIE

EXPDS1               std       <u000C
                    ldd       <u0066
                    subd      ,s
                    std       <u0066
                    ldu       <u00DA
                    ldd       <u00DA
                    subd      ,s
                    std       <u00DA        set descr area offset
                    tfr       d,y
                    ldd       <u0066        get symbol tbl size
                    subd      <u00DA        Re-adjust
                    addd      <u0068        add link size
                    bsr       MOVDWN
                    ldd       <u0068        get storage offset
                    addd      ,s++
                    std       <u0068
                    leax      ,u
                    puls      pc,u

EXPSYM               pshs      u,d
                    bsr       L24BD
                    subd      ,s
                    std       <u0068
                    leau      ,x
                    leax      $03,y
                    stx       <u0062
                    ldd       <u0064        get procedure ptr
                    bsr       MOVDWN
                    addd      ,s++
                    std       <u0064
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
                    beq       L2558               Yes, exit
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
L2558               puls      pc,u,y,x,a          Restore regs & return

PLREF               pshs      x,d                 Preserve regs
                    ldb       [<$04,s]            Get table entry #
                    leax      <L256A,pc           Point to vector table
                    ldd       b,x                 Get vector offset
                    leax      d,x                 Calculate vector
                    stx       4,s                 Replace original RTS address with vector
                    puls      pc,x,d              Restore regs and go to new routine

* Jump table
L256A               fdb       L2C50-L256A         $06e6
                    fdb       BIND-L256A         $0b36
                    fdb       PSTMT-L256A         $0128
                    fdb       PRT4HX-L256A         $0193

* Jump table
L2581               fdb       L2D07-L2581         $0786
                    fdb       PPARAM-L2581         $01fe
                    fdb       PTYPE-L2581         $01a7
                    fdb       L2783-L2581         $0202
                    fdb       L292A-L2581         $03a9
                    fdb       PPRINT-L2581         $0707
                    fdb       L2D20-L2581         $079f
                    fdb       L2D20-L2581         $079f
                    fdb       L2D20-L2581         $079f
                    fdb       PPRINT-L2581         $0707
                    fdb       L2D20-L2581         $079f
                    fdb       L2D20-L2581         $079f
                    fdb       L2D20-L2581         $079f
                    fdb       PLET-L2581         $03D3
                    fdb       PASSGN-L2581         $03D1
                    fdb       PPOKE-L2581         $0423
                    fdb       PIF-L2581         $04AF
                    fdb       PELSE-L2581         $04CA
                    fdb       PRUN-L2581         $04E1
                    fdb       PFOR-L2581         $04F3
                    fdb       PNEXT-L2581         $058B
                    fdb       PWHILE-L2581         $05DA
                    fdb       PEWHL-L2581         $05E8
                    fdb       PREPT-L2581         $0600
                    fdb       PUNTIL-L2581         $0607
                    fdb       PLOOP-L2581         $061b
                    fdb       L2BA0-L2581         $061f
                    fdb       PEXIF1-L2581         $0623
                    fdb       PEEXT-L2581         $0640
                    fdb       PON-L2581         $042a
                    fdb       L2A1A-L2581         $0499
                    fdb       PGOTO-L2581         $044b
                    fdb       L308D-L2581         $0b0c
                    fdb       PGOTO-L2581         $044b
                    fdb       L308D-L2581         $0b0c
                    fdb       L2C1F-L2581         $069e
                    fdb       L2D07-L2581         $0786
                    fdb       L2C65-L2581         $06e4
                    fdb       PPRINT-L2581         $0707
                    fdb       L2D07-L2581         $0786
                    fdb       L2D07-L2581         $0786
                    fdb       L2CC6-L2581         $0745
                    fdb       L2CC6-L2581         $0745
                    fdb       PSEEK-L2581         $0761
                    fdb       L2C65-L2581         $06e4
                    fdb       PPRINT-L2581         $0707
                    fdb       PCLOSE-L2581         $076f
                    fdb       PCLOSE-L2581         $076f
                    fdb       L2CFA-L2581         $0779
                    fdb       PREST-L2581         $0797
                    fdb       L2D07-L2581         $0786
                    fdb       L2D07-L2581         $0786
                    fdb       L2D07-L2581         $0786
                    fdb       L2D20-L2581         $079f
                    fdb       L2D20-L2581         $079f
                    fdb       PREMRK-L2581         $0147
                    fdb       PREMRK-L2581         $0147
                    fdb       PPRINT-L2581         $0707
                    fdb       L265D-L2581         $00dc
                    fdb       L308D-L2581         $0b0c
                    fdb       L308D-L2581         $0b0c
                    fdb       PERRLN-L2581         $0140
                    fdb       SKPEOL-L2581         $0197
                    fdb       SKPEOL-L2581         $0197

* Table (called from L2D2C) - If 0, does something @ L308D, otherwise, AND's
*   with $1F, multiplies by 2, and uses result as offset to branch table @
*   L2DA2
L2601               fcb       $20,$20,$06,$00,$43,$40,$28,$25,$00,$43,$43,$43,$43,$43,$43,$43
                    fcb       $05,$00,$43,$43,$43,$00,$45,$00,$25,$00,$45,$00,$05,$00,$21,$21
                    fcb       $47,$27,$27,$22,$22,$22,$60,$60,$61,$87,$8a,$89,$89,$81,$85,$00
                    fcb       $80,$81,$e0,$e0,$e0,$e0,$e0,$6b,$05,$00,$6c,$6c,$6c,$6d,$00,$00
                    fcb       $6d,$00,$00,$6e,$00,$00,$00,$6e,$00,$00,$00,$6d,$00,$00,$6d,$00
                    fcb       $00,$0d,$00,$00,$06,00,$06,$00,$06,$00,$44,$44

L265D               ldd       ,y
                    tst       <u00D9
                    bne       L2675         ..No
                    pshs      d             save line number
* (orig: PLRE10)
                    leay      -1,y          Backup to token
* (orig: PEIF)
                    ldd       <u0060        copy I-Code limit
PLRE20               std       <u00AB
                    ldd       #3            Delete three bytes
                    lbsr      L2578         Call replacer
                    puls      d             Retrieve line number
                    bra       L2677

L2675               leay      2,y
L2677               lbsr      SRHLIN
                    bcc       PLRE50         bra if already defined
                    std       ,x            Define line number (clear sign)
                    tfr       y,d           copy I-Code ptr
                    subd      <u005E        Make ptr into offset
* (orig: PLRE40)
                    leax      2,x           get ptr to header link
PLRE30               ldu       ,x
                    std       ,x            set offset in goto
L2688               leax      ,u
                    bne       PLRE30         bra if not end
                    bra       PSTMT         Go do stmt

PLRE50               lda       #$4B                Multiply-defined Line Number error
                    bsr       ERROR               Go print (Y-<u005E) to std err in hex
PSTMT               leax      >L2581,pc           Point to table
                    ldb       ,y+                 Get byte
                    bpl       L269F               If high bit off, go get offset from table
                    ldd       #PASSGN-L2581        Otherwise force to use PASSGN offset
                    bra       PSTMT2               Skip ahead

L269F               lslb                          Multiply by 2
                    clra                          16 bit offset required
                    ldd       d,x                 Get offset
                    cmpd      #PASSGN-L2581        Is it the special case one?
                    blo       PSTMT3               If it or any lower offset, go execute it
PSTMT2               tst       <u00C7              ??? If ?? set, go execute routine
                    bne       PSTMT3         Yes; go do it
                    inc       <u00C7              Set flag
                    pshs      d                   Preserve offset
                    tfr       y,d                 ??? Move current location to D
                    subd      <u005E              Subtract something
                    subd      #$0001              Subtract 1 more
                    ldu       <u002F              Get 'current' module ptr
                    std       $15,u               ??? Save some sort of size into module header?
                    puls      d                   Get offset back
PSTMT3               jmp       d,x                 Jump to routine

PERRLN               ldx       <u002F              Get ptr to current module
                    lda       #$01                Flag for Line with Compiler error
                    sta       <$17,x              Save in flag header byte
PREMRK               ldb       ,y+                 Get offset byte
                    clra                          Make 16 bit
                    leay      d,y                 Point Y to it & return
                    rts

L308D               ldy       <u0060
                    lda       #$30                Unimplemented Routine error
* ERROR MESSAGE REPORT:
* Prints Hex # address of where error occurs, & error message on screen
* Entry: Y=# to convert to hex after subtracting <u005E
* Exit: Writes out 4 digit hex # & space
ERROR               pshs      y,x,d               Preserve regs
                    ldx       <u002F              Get Ptr to current module
                    lda       #$01                Set Line with compiler error flag in mod. header
                    sta       <$17,x
                    lda       <u0084              Get flag???
                    bmi       ERRO10               If high bit set, don't print address
                    ldd       4,s                 Get # to convert (current addr?)
                    subd      <u005E              ??? Subtract start?
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
                    lbsr      L1CC1               Print error message
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
                    beq       L2727         ..Yes
                    cmpb      #$3E
L2727               rts

PTYPE               lbsr      GETTYP
                    ldb       <u00CF        defined?
                    beq       PTYPE1         No; good
                    lda       #$4C                Multiply-defined Variable error
                    bsr       ERROR               Go print hex version of (Y-<u005E)
PTYPE1               leay      4,y                 Bump ptr up by 4
                    lda       #$40
                    sta       <u00CE
                    ldd       <u00C1        get current variable alocation
                    pshs      d             save it
                    clra
                    clrb                    Allocation for record
                    std       <u00C1
                    bsr       PDECLR         Process component declarations
                    ldd       <u00CC        get ptr to end of list
                    subd      <u0060        get size of declr
                    beq       L277A         bra if all errors
                    addd      #3            get description area base
                    cmpd      <u000C
                    lbcc      PBEXPR
                    pshs      y,x           save symbol ptr & I-Code ptr
                    lbsr      L257B         get descr area
                    ldd       <u00C1        set rcd size
                    leau      ,y            copy descr ptr
                    std       ,y++
                    clr       ,y+           Clear component count
                    ldx       <u0060              Get address of $F offset in header
PTYPE2               ldd       ,x++                Get value there
                    subd      <u0062        Make ptr into offset
                    std       ,y++          put in descr area
                    inc       2,u           Count component
                    cmpx      <u00CC        are there more components?
                    blo       PTYPE2
                    tfr       u,d
* (orig: PTYPE3)
                    puls      y,x
                    subd      <u0066
                    std       1,x           put in symbol tbl
                    lda       #$25
                    sta       ,x            set type byte
L277A               puls      d
                    std       <u00C1        Restore variable allocation
                    rts

PPARAM               lda       #$80
                    bra       PDIM1

L2783               lda       #$60
PDIM1               sta       <u00CE
PDECLR               ldd       <u0060
                    pshs      x,d
                    std       <u00CC        set beginning of component list
PDECL1               bsr       PID
                    ldb       ,y+           get type byte
                    cmpb      #$4B
                    beq       PDECL1
                    cmpb      #$4C
                    beq       PDECL2         Yes; go get it
                    leay      -1,y          Back up to unknown
                    ldb       #$01          set flag for implicit typing
                    bra       PDECL3

PDECL2               lbsr      L283A
                    clrb                    Flag for explicit typing
PDECL3               pshs      y,b
                    ldx       3,s           get beginning of component list
                    ldd       <u00CC        get end of list
                    std       3,s           save end for looping
                    stx       <u00CC
                    subd      <u00CC
                    lslb                          D=D*2
                    rola
                    addd      3,s
                    cmpd      <u00DA
                    blo       L27CE
                    lbra      PBEXPR

PDECL4               ldu       ,x++                Get some sort of var ptr
                    tst       ,s            Test flag
                    beq       L27CB         bra if explicit
                    lda       ,u                  Get var type
                    sta       <u00D1              Save it
                    lbsr      GETVSZ               D=size of var in bytes
                    std       <u00D6              Save size
L27CB               lbsr      DEFVAR
L27CE               cmpx      3,s
                    blo       PDECL4
                    ldd       <u00CC        Mark current position in stack
                    std       3,s
                    puls      y,b           Clean stack, restore I-Code ptr
                    ldb       ,y+           get next token
                    cmpb      #$51          is there another list?
                    beq       PDECL1         Yes
                    puls      pc,x,d

PID               lbsr      GETTYP
                    ldb       <u00CF        already defined?
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

PID1               ldd       <u00CC
                    addd      #$000A
                    cmpd      <u00DA        Memory full?
                    lbhs      PBEXPR         ..No; abort
                    ldx       <u00CC        get component list ptr
                    ldd       <u00D2        get symbol ptr
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
PID3               stx       <u00CC
                    rts

GETSIZ               ldb       ,y+
                    clra                    Msb
                    cmpb      #$8D          byte?
                    beq       L2837         Yes
* (orig: PVTYPE)
                    lda       ,y+           get msb value
L2837               ldb       ,y+
                    rts

L283A               lda       ,y+
                    cmpa      #$85          user type?
                    beq       L285B         Yes; handle it
                    suba      #$40          Convert token to type
                    sta       <u00D1              Save var type
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
                    bra       L2875

PVTYP1               lbsr      GETVSZ               Go get size of var
                    bra       L2875               Go save size @ u00D6

L285B               leay      -1,y
                    lbsr      GETTYP         get symbol ptr; decode type byte
                    leay      3,y           Move I-Code ptr
                    ldb       <u00CF        get definition
                    cmpb      #$20          type definition?
                    beq       PVTYP3         Yes; good
                    lda       #$18                Illegal Type suffix error
                    lbra      ERROR

PVTYP3               ldd       1,x
                    std       <u00D2        save it
                    ldx       <u0066
                    ldd       d,x                 Get size of var
L2875               std       <u00D6              Save size of var & return
                    rts

DEFVAR               ldb       ,x+
                    beq       DEFV07
                    pshs      b             save count
                    lslb
                    lslb
                    lslb
                    stb       <u00D0        save it
                    lsrb                    Back
                    lsrb
                    leax      b,x           get ptr to next variable
                    addb      #4            add for offset & totalsize
                    pshs      u,x           save variable stack ptr & symbol ptr
                    lda       <u00D1              Get var type
                    cmpa      #4                  Numeric type?
                    blo       DEFV02               Yes, skip ahead
                    addb      #2                  If string or complex, add 2 to type
DEFV02               clra                    Msb
                    cmpd      <u000C        enough room?
                    lbhi      PBEXPR         ..No; abort
                    lbsr      L257B         get description area
                    ldx       ,s            get variable stack ptr
                    leau      2,y           get ptr to total size
* (orig: DEFV03)
                    ldd       #$0001        set totalsize
                    std       ,u++          put in descr area
L28A7               ldd       ,--x
                    std       ,u++          put in descr area
                    bsr       DIMMUL         Multiply subscript by size
                    dec       4,s           Count down
                    bne       L28A7         bra if more
                    lda       <u00D1              Get var type
                    cmpa      #4                  Numeric or string?
                    bls       L28BC               Yes, skip ahead
* (orig: DEFV05)
                    ldd       <u00D2              No, (complex?)
* NOTE: Since 28BC only referred to here, should be able to change std ,u/coma
*   to bra L28C0 (std ,u)
                    std       ,u                  Save ???
                    coma                          Set carry to indicate complex?
L28BC               ldd       <u00D6              Get size of var in bytes
                    bcs       DEFV06               If complex, don't save sign again
                    std       ,u                  Save size
DEFV06               bsr       DIMMUL               ??? Do some multiply testing based on size?
                    tfr       y,d           copy descr ptr
                    puls      u,x           get symbol ptr, I-Code ptr
                    subd      <u0066        Make ptr into offset
                    std       1,u           put in symbol tbl
                    leas      1,s           Return scratch
                    bra       DEFV10

DEFV07               stb       <u00D0
                    lda       <u00D1              Get var type
                    cmpa      #4                  Normal type (numeric/string)?
                    bhi       L28DC               No, skip ahead
* (orig: DEFV08)
                    ldd       <u00D6              Get size of var
                    bra       DEFV09               Skip ahead

L28DC               ldd       <u00D2              Get ??? (something with complex type?)
DEFV09               std       1,u                 Save size
DEFV10               lda       <u00D1              Get var type
                    ora       <u00D0              Keep common bits with ???
                    ora       <u00CE              Keep common bits with ???
                    sta       ,u                  Save ???
* (orig: START)
                    pshs      x             save variable stack ptr
                    leax      ,u            copy symbol ptr
                    lbsr      ALCSTO         Go allocate storage
                    ldx       <u00CC        get component list
                    stu       ,x++          put symbol ptr in list
                    stx       <u00CC        save component ptr
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

L292A               ldu       <u00CA
                    bne       L2936         bra if there was one
                    tfr       y,d           copy I-Code ptr
                    subd      <u005E
                    std       <u00C8        set first data stmt
                    bra       PDATA2

L2936               tfr       y,d
                    subd      <u005E        Make ptr into offset
                    std       ,u
***************
* Process Expressions
PDATA2               lbsr      PEXPRN
                    lbsr      POPOP         Keep opstack clear
                    ldb       ,y+
                    cmpb      #$4B          is there another expression
                    beq       PDATA2         Yes; go do it
                    sty       <u00CA        save ptr to this data stmt
                    ldd       <u00C8        get offset of first stmt
                    std       ,y++          put in this one
                    lbra      SKPONE         Skip end of line

PASSGN               leay      -1,y
PLET               bsr       PASGVR
                    leay      1,y
                    lbsr      PEXPRN         Process expression
                    lbsr      POPOP         get result type
                    sta       <u00D1              Save var type
                    lbsr      POPOP
                    cmpa      <u00D1              Same as var type?
                    beq       PASSG4               Yes, skip ahead
                    cmpa      #2                  Var type from 2E52=Boolean/string/complex?
                    bhi       L297E               Yes, skip ahead (print some hex # out)
                    beq       L2971               Real #, skip ahead
* (orig: PASSG1)
                    lda       #$C8          Fix real for integer destination
                    bra       PASSG2

L2971               lda       #$CB
PASSG2               ldb       <u00D1              Get var type
                    cmpb      #2                  Boolean/string/complex?
                    bhi       L297E               Yes, skip ahead
                    lbsr      INSTOK               Byte/Integer/Real, go do something
                    bra       PASSG4

L297E               lbsr      ERIET
PASSG4               lbra      SKPEOL               ??? Do some checking ,y, return from there

PASGVR               lda       ,y
                    cmpa      #$0E          complex assignment?
                    lbne      PEXPRN         Process variable reference
                    leay      1,y           Skip token
                    lbsr      PEXPRN         Process variable reference
L2991               lda       -3,y
                    cmpa      #$85          simple?
                    bhs       PASGV1
                    ldd       <u00D2
                    subd      <u0062
                    std       -2,y          put in I-Code
                    lda       #$85
PASGV1               adda      #$6D
                    sta       -3,y          put in I-Code
                    rts

PPOKE               bsr       PPOK30
PPOK30               bsr       L2A1A
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

SRHLIN               ldx       <u0066
                    pshs      d             save line number
                    bra       L29ED

SRHL10               ldd       ,x
                    anda      #$7F          Clear sign
                    cmpd      ,s            Line number in question?
                    beq       SRHL30
L29ED               leax      -4,x
                    cmpx      <u00DA        Out of tbl?
                    bhs       SRHL10
                    ldd       <u000C              Get # bytes free in workspace for user
                    subd      #4                  Subtract 4
                    blo       PBEXPR               Not enough mem, exit with Memory full error
                    std       <u000C              Save new free space
                    ldd       ,s            get line number
                    ora       #$80          set undefined flag
                    std       ,x            put in tbl
                    clra                    End of list link
                    clrb
                    std       2,x
                    stx       <u00DA        Increase tbl
SRHL30               lda       ,x
                    rola                    Flag to carry
                    puls      pc,d

PBEXPR               lda       #32                 Memory full error
                    sta       <u0036              Save error code
                    lbsr      ERROR         Print error message
                    lbsr      L30EB         collapse I-code to reasonable state
                    lbra      L1CC7

L2A1A               lbsr      PEXPRN
                    lbsr      POPOP
                    cmpa      #2                  Real?
                    beq       L2A2B               Yes, skip ahead
                    blo       PGOTXX               Byte/Integer, return
ERIET               lda       #$47                Illegal Expression Type error
                    lbra      ERROR

L2A2B               lda       #$C8
                    lbra      INSTOK

PIF               lbsr      L2BAF
                    lda       3,y
                    cmpa      #$3A
                    beq       PIF1
                    lda       #$10          get token
                    lbra      L2BA8

PIF1               pshs      y
                    leay      4,y           Move I-Code ptr
                    bsr       PGOTO         Process transfer
                    tfr       y,d           copy I-Code ptr
                    subd      <u005E
                    std       [,s++]
                    rts

PELSE               ldd       #$1002
                    lbsr      CONCHK         Call control structure check
                    ldu       1,x           get ptr to IF stmt
                    sty       1,x           Replace top of stack
                    leay      2,y           Move I-Code ptr
                    lbsr      SKPEOL         Skip backslashes & eol
                    tfr       y,d
                    subd      <u005E
                    std       ,u
* (orig: PCHLXX)
                    rts

PRUN               ldd       #$1001
                    lbsr      CONCHK
                    leay      1,y
PEIF1               tfr       y,d
                    subd      <u005E
                    std       [<1,x]
                    lbra      POPCN

PFOR               lbsr      GETTYP
                    lbsr      L2EE3         Check if defined, define if not
                    cmpa      #$60          Check if variable
                    bne       PFOR1         Not variable; abort
                    lda       <u00D1              Get var type
                    cmpa      #1                  Integer?
                    beq       PFOR2               Yes, skip ahead
                    cmpa      #2                  Real?
                    beq       PFOR2               Yes, skip ahead
PFOR1               lda       #$46                Illegal FOR variable
                    lbsr      ERROR
                    ldd       #$FFFF        Make SYMPTR illegal
                    std       <u00D2
                    bra       PFOR3

* FOR variable is numeric but NOT byte, continue
PFOR2               ldb       <u00D0
                    bne       PFOR1         No; abort
                    adda      #$80                Set hi bit on var type
                    sta       ,y                  Save it
                    ldd       1,x           get runtime storage offset
                    std       1,y           put in I-Code
PFOR3               ldx       <u0044              Get some sort of var ptr
                    leax      -7,x                Make room for 7 more bytes
                    stx       <u0044              Save new ptr
                    lda       <u00D1              Get var type
                    sta       ,x                  Save it
                    ldd       <u00D2        get symbol tbl ptr
                    subd      <u0062        Make ptr into offset
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
                    stx       <u0044        save control stack ptr
                    leay      3,y           Move to next stmt
PFOR9               rts

FORSUB               ldd       <u00C1
                    pshs      d             save it for return
                    std       1,y           put in I-Code
                    ldx       <u0044        get control stack ptr
                    lda       ,x            get type
                    leax      >L307E,pc           Point to 5 single bytes table
                    ldb       a,x                 Get value
                    clra                          D=value  Msb
                    addd      <u00C1              Add to value & save result
                    std       <u00C1        save it
                    leay      3,y           Move to expression
                    bsr       PIEXPR         Process it
                    ldx       <u0044        get control stack ptr
                    puls      pc,d          get offset & return

PIEXPR               lbsr      PEXPRN
                    lbsr      POPOP
                    cmpa      ,u
                    beq       PFOR9
                    cmpa      #$02          numeric?
                    bcs       L2B07         Yes; good (rts)
                    lbne      ERIET         Err - illegal expression type
* (orig: FORTY1)
                    lda       #$C8          Err - illegal expression type
                    bra       FORTY3

L2B07               lda       #$CB                ??? Illegal mode error?
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

PNEXT4               addd      <u0062
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
                    subd      <u005E        Make ptr into offset
                    addd      #$0001        Make offset of next type byte
                    std       ,u            put in FOR stmt
                    leau      3,u           Move ptr to stmt following FOR
                    tfr       u,d
                    subd      <u005E        Make it offset
                    std       8,y
PNEXT6               leay      $B,y
                    lbsr      POPCN         Pop endexits and this control structure
                    leax      7,x           Pop extra room for used
                    stx       <u0044        get control stack ptr
                    rts

PWHILE               leau      -1,y
                    pshs      u             save it
                    bsr       L2BAF         get boolean expression
                    puls      d             get ptr to stmt beginning
                    std       ,y
                    lda       #$15
                    bra       L2BA8         Push on ctl stack, skip 'do' token

PEWHL               ldd       #$1503
                    bsr       CONCHK         Call control structure check
                    ldx       1,x           get ptr to while jump ptr
                    ldd       ,x            get ptr to stmt beginning
                    subd      <u005E        get I-Code offset
                    std       ,y            put in endwhile jump ptr
                    leay      3,y
                    tfr       y,d
                    subd      <u005E
                    std       ,x            put in while jump ptr
                    lbra      POPCN

PREPT               lda       #$17
PREP10               lbsr      SKPONE
                    bra       PUSHCN

PUNTIL               bsr       L2BAF
                    lda       #$17          set structure type
PUNT10               leay      -1,y
                    ldb       #$03          Number of bytes to skip if error
                    bsr       CONCHK         Call control structure check
                    ldd       1,x           get ptr to after REPEAT
                    subd      <u005E
                    std       $01,y         put in I-Code
                    leay      $04,y         Move I-Code ptr to next stmt
                    bra       POPCN

PLOOP               lda       #$19
                    bra       PREP10

L2BA0               lda       #$19
                    bra       PUNT10         Push on operand stack

PEXIF1               bsr       L2BAF
                    lda       #$1B          get structure token
L2BA8               bsr       PUSHCN
                    leay      3,y           Move I-Code ptr past THEN
                    lbra      SKPEOL

L2BAF               lbsr      PEXPRN
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

PUSHCN               ldx       <u0044
                    sty       ,--x          Push I-Code ptr
PUSHC1               sta       ,-x
                    stx       <u0044
                    rts

CONCHK               pshs      a
                    ldx       <u0044        get control stack ptr
                    bra       L2BE5

L2BE3               leax      3,x
L2BE5               cmpx      <u0046
                    bhs       CONCH3
                    lda       ,x            get token
                    cmpa      #$1C
                    beq       L2BE3
                    cmpa      ,s            correct type?
                    beq       CONCH4
CONCH3               leas      3,s
                    lda       #$45                Unmatched Control Structure error
                    lbsr      ERROR
                    leay      b,y           Skip I-Code
                    lbra      SKPEOL         Push on operand stack

CONCH4               puls      pc,a

POPCN               ldx       <u0044
                    bra       L2C14

POPCN1               lda       ,x
                    cmpa      #$1C          endexit?
                    bne       DONE25         No; go pop it
                    tfr       y,d           copy I-Code ptr
                    subd      <u005E        get I-Code offset
                    std       [<1,x]        put in I-Code
* (orig: POPCN3)
                    leax      3,x           Pop endexit
L2C14               cmpx      <u0046
                    blo       POPCN1
                    bra       POPCN9         Return

DONE25               leax      3,x
POPCN9               stx       <u0044
                    rts

L2C1F               leay      -1,y
                    lbsr      GETTYP         get & decode type byte
                    lda       <u00CF        get definition
                    beq       L2C41
                    cmpa      #$A0
                    beq       PRUN20         ..Yes
                    cmpa      #$60
                    bcs       PRUN10         is simple
                    lda       <u00D0        simple?
                    bne       PRUN10         ..No
* (orig: PRUNER)
                    lda       <u00D1        get type
                    cmpa      #$04
                    beq       PRUN20
PRUN10               lda       #$4C                Multiply-defined Variable error
                    lbsr      ERROR
                    bra       PRUN20

L2C41               lda       #$A0
                    sta       ,x
                    ldd       <u00C5        get next procedure link addr
                    std       1,x           put in symbol tbl
                    addd      #$0002        get next procedure link
                    std       <u00C5        save total size
PRUN20               leay      3,y
L2C50               ldb       ,y+
                    cmpb      #$4D          are there parameters?
                    bne       PRUN40         ..No
L2C56               lbsr      PASGVR
                    lbsr      POPOP         Keep opstack clean
                    ldb       ,y+
                    cmpb      #$4B
                    beq       L2C56
                    leay      1,y           Skip stmt terminator
PRUN40               rts

L2C65               bsr       L2CB2
                    leay      -1,y          Backup to exprsn
                    cmpb      #$90          prompt string?
                    bne       L2C72         No; go do variable reference
* (orig: PINPU1)
                    lbsr      L2D0B         Process it
                    leay      1,y           Skip comma
L2C72               lbsr      PASGVR
                    lbsr      POPOP
                    cmpa      #$05
                    bcs       L2C81         No; good
* (orig: PINPU2)
                    lda       #$4D                Illegal Input Variable error
                    lbsr      ERROR
L2C81               lda       ,y+
                    cmpa      #$4B          a comma?
                    beq       L2C72
                    rts

PPRINT               bsr       L2CB2
                    cmpb      #$49          USING?
                    bne       L2C92         No; go look for expression
                    bsr       L2D0B
L2C90               ldb       ,y+
L2C92               cmpb      #$4B
                    beq       L2C90
                    cmpb      #$51
                    beq       L2C90         ..Yes
                    lbsr      EOLTST
                    beq       L2CC5
* (orig: PRLIT)
                    leay      -1,y          Back up to expression
                    lbsr      PEXPRN
                    lbsr      POPOP
                    cmpa      #$05
                    blo       L2C90
                    lda       #$47                Illegal Expression Type error
                    lbsr      ERROR
                    bra       L2C90

L2CB2               ldb       ,y+
                    cmpb      #$54          is there channel number?
                    bne       L2CC5
                    lbsr      L2A1A         Check variable type & subscripts
L2CBB               ldb       ,y+
                    cmpb      #$4B          comma?
                    beq       L2CBB
                    cmpb      #$51          semi-colon?
                    beq       L2CBB         ..No
L2CC5               rts

L2CC6               leay      1,y
                    lbsr      PASGVR
                    lbsr      POPOP
                    cmpa      #$01
                    beq       POPE20
                    lbsr      ERIET
POPE20               leay      1,y
                    bsr       L2D0B         Process name expression
                    lda       ,y+
                    cmpa      #$4A
                    bne       POPE30         ..No
                    leay      2,y
POPE30               rts

PSEEK               bsr       PIOBGN
                    bsr       PEXPRN
                    lbsr      POPOP
                    cmpa      #$42
                    bls       L2D20
                    lbra      ERIET         Err - illegal expression type

PCLOSE               bsr       PIOBGN
                    lbsr      PASGVR         Process variable/expression
                    lbsr      POPOP
L2CF8               bra       L2D20

L2CFA               bsr       PIOBGN
                    cmpb      #$4B          Another path?
                    beq       L2CFA         ..Yes
                    bra       L2D20

PIOBGN               leay      1,y
                    lbra      PPOK30

L2D07               bsr       L2D0B
                    bra       L2D20

L2D0B               bsr       PEXPRN
                    lbsr      POPOP
                    cmpa      #4
                    beq       POPE30               Return
                    lbra      ERIET               Return from there

PREST               ldb       ,y+
                    cmpb      #$3A          line reference?
                    lbeq      PGOTO
L2D20               lbra      SKPEOL

L2D23               cmpb      #$96
                    bhs       L2D2C
                    lbsr      L2E5F         Call specials processor
                    bra       PEXPRN

* B>=$96 goes here
L2D2C               cmpb      #$F2                If >=$F2, skip ahead
                    lbhs      L308D
                    subb      #$96                Drop B to $00 - $5B
                    leax      >L2601,pc           Point to data table
                    abx                           Point to entry we want
                    ldb       ,x                  Get it
                    lbeq      L308D               If nothing, skip ahead
                    andb      #$1F          get argument processor code
                    beq       PEXP30         bra if no arguments/operands
                    leau      <L2DA2,pc           point to routine
                    lslb
                    jsr       b,u           Process arguments/operands
PEXP30               ldb       ,x                  Get byte
                    andb      #$E0                Mask out all but hi 3 bits
                    beq       L2D60               If hi 3 bits all 0's, skip ahead
                    clra                          Move hi 3 bits to lo 3 bits in A
                    rolb                          ROLD
                    rola
                    rolb                          ROLD
                    rola
                    rolb                          ROLD
                    rola
                    cmpa      #$07                All 3 bits set?
                    bne       L2D60               No, skip ahead
* (orig: PEXP40)
                    lbsr      L2FD4         Delete token
                    bra       PEXPRN

L2D60               lbsr      L2E3B
                    leay      1,y           Move I-Code ptr
PEXPRN               ldb       ,y
                    bmi       L2D23
                    rts

P2INT               bsr       P1REAL
                    incb
                    bra       L2D71

P1REAL               ldb       #$C8                (200)
L2D71               lbsr      POPOP
                    cmpa      #$02          numeric?
                    blo       L2D85
                    beq       PINT10         bra if real
                    bsr       ERRIAR
                    bra       PINT20

PINT10               tfr       b,a
                    lbsr      INSTOK
PINT20               lda       #$01
L2D85               rts

L2D86               bsr       L2D8B
                    incb
                    bra       L2D8D

L2D8B               ldb       #$CB
L2D8D               lbsr      POPOP
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

L2DA2               bra       L2DC0               (offset 0)
L2DA4               bra       P1REAL               (2)
L2DA6               bra       P2INT               (4)
L2DA8               bra       L2D8B               (6)
L2DAA               bra       L2D86               (8)
L2DAC               bra       P1NUM               ($a)
L2DAE               bra       P2NUM               ($c)
L2DB0               bra       L2DF4               ($e)
L2DB2               bra       L2DF2               ($10)
L2DB4               bra       P1S1I               ($12)
L2DB6               bra       L2E04               ($14)
L2DB8               bra       L2E30               ($16)
L2DBA               bra       L2E2E               ($18)
L2DBC               bra       P2SN               ($1A)
L2DBE               bra       P2BSN               ($1C)
L2DC0               lbra      L308D               ($1F)

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
                    bls       L2DF1         ..Yes
                    bsr       ERRIAR         Report error
                    lda       #$02          Return real
L2DF1               rts

L2DF2               bsr       L2DF4
L2DF4               bsr       POPOP
                    cmpa      #4
                    beq       P1STXX
                    bsr       ERRIAR
                    lda       #4
P1STXX               rts

P1S1I               lbsr      P1REAL
                    bra       L2DF4         Process string

L2E04               lbsr      P2INT
                    bra       L2DF4         Process string

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

P2ARG               ldu       <u0044
                    cmpa      ,u+           is first correct type?
                    bne       L2E2D         ..No
                    cmpa      ,u+           is second correct?
                    bne       L2E2D         ..No
                    stu       <u0044        Pop arguments/operands
                    clrb                    Z bit
L2E2D               rts

L2E2E               bsr       L2E30
L2E30               bsr       POPOP
                    cmpa      #3
                    beq       P1BOXX
                    bsr       ERRIAR
                    lda       #3
P1BOXX               rts

* Modified since all routines coming here freshly LDA
L2E3B               tsta                          A=0?
L2E3C               bne       L2E41               No, skip ahead
                    inca                          A=1
L2E41               ldu       <u0044
                    cmpa      #5            rcd type?
                    bne       PUSHO2         No; do simple
                    ldd       <u00D4        get descr ptr
                    std       ,--u
                    lda       #5
PUSHO2               sta       ,-u
                    stu       <u0044        save stack ptr
                    rts

POPOP               ldu       <u0044
                    lda       ,u+           get type
                    cmpa      #5            record?
                    bne       POPOP1         ..No
                    leau      2,u           Return descr space
POPOP1               stu       <u0044
                    rts

L2E5F               cmpb      #$85
                    lblo      L308D
                    cmpb      #$89
                    blo       PVREF
                    subb      #$8D          field reference?
                    lblo      PFREF               $8a to $8c go here
                    leau      <L2E75,pc           Point to list of branches
                    lslb                          2 bytes/per branch
                    jmp       b,u                 Call branch

L2E75               bra       PBLIT
L2E77               bra       L2E89
L2E79               bra       L2E8F
L2E7B               bra       PSLIT
L2E7D               bra       L2E89
L2E7F               bra       PADDR1
L2E81               bra       PADDR2
L2E83               bra       PADDR1
L2E85               bra       PADDR2

PBLIT               leay      -1,y
L2E89               leay      3,y
                    lda       #1
                    bra       L2E41

L2E8F               leay      6,y
                    lda       #2
                    bra       L2E41

PSLIT               ldb       ,y+
                    cmpb      #$FF
                    bne       PSLIT
                    lda       #4
                    bra       L2E41

PADDR1               lbsr      L2991
                    bsr       POPOP
                    lda       #1
                    bsr       L2E41
PADDR2               leay      1,y
                    rts

PVREF               lbsr      GETTYP
                    bsr       L2EE3
                    cmpa      #$60
                    beq       L2EBF         bra if so
                    cmpa      #$80          Object procedure?
                    beq       L2EBF         Real; check for integer result
                    lda       #$12                Illegal Operand error
                    lbsr      ERROR
                    bra       L2EDC

L2EBF               ldb       #$85
                    lbsr      L2F5E         Print line
                    ldb       ,y
                    cmpb      #$85
                    bne       L2EDC
                    ldb       <u00CF
                    cmpb      #$60
                    bne       L2EDC
                    cmpa      #5
                    bhs       L2EDC
                    adda      #$80
                    sta       ,y
                    ldd       1,x
                    std       1,y
L2EDC               leay      3,y
                    lda       <u00D1
                    lbra      L2E3C

L2EE3               lda       <u00CF
                    bne       CHKD20
                    ldb       #$60
                    sta       <u00D0
                    stb       <u00CF
* (orig: CHKDEF)
                    lda       #$60                Take out, and change following to B's ?
                    ora       <u00D1        set high order bit
                    sta       ,x
                    anda      #$07
                    cmpa      #4
                    bne       L2F01         No; error
                    ldd       #$0020
                    std       1,x
L2F01               lbsr      ALCSTO
                    lda       <u00CF
CHKD20               rts

PFREF               bsr       GETTYP
                    ldb       #$89
                    bsr       L2F5E         End of statement?
                    lbsr      POPOP
                    cmpa      #5
                    beq       L2F19
* (orig: PFREF1)
                    ldu       #$FFFF
                    bra       PFREF2

L2F19               ldu       -2,u
PFREF2               pshs      u
                    bsr       L2EDC
                    puls      u
                    cmpu      #$FFFF
                    beq       L2F3E
                    ldb       2,u
                    stb       <u00D6
                    ldd       <u00D2
                    subd      <u0062
                    leau      3,u
PFREF3               cmpd      ,u++
                    beq       GETTY9
                    dec       <u00D6
                    bne       PFREF3
* (orig: PFREF5)
                    lda       #$14
                    bra       PFREF9

L2F3E               lda       #$42                Non-Record Type Operand error
PFREF9               lbra      ERROR

GETTYP               ldd       1,y
                    addd      <u0062
                    std       <u00D2
                    ldx       <u00D2
GETTY1               lda       ,x
                    anda      #$E0
                    sta       <u00CF
                    lda       ,x
                    anda      #$18
                    sta       <u00D0
                    lda       ,x
                    anda      #$07
                    sta       <u00D1
GETTY9               rts

L2F5E               pshs      b
                    ldb       ,y            Get array base lsb
                    subb      ,s+
                    bne       L2F73
                    lda       <u00D0
                    beq       CHKV60
                    ldd       #$FFFF
                    std       <u00D4
                    lda       #5
                    sta       <u00D1
                    rts

L2F73               lslb                          B=B*8
                    lslb
                    lslb
                    cmpb      <u00D0
                    beq       L2F7F
* (orig: CHKV20)
                    lda       #$41                Wrong Number of Subscripts error
* (orig: CHKV30)
                    lbsr      ERROR         Turn on trace
L2F7F               lda       #$C8
                    sta       <u00D8
L2F83               lbsr      POPOP
                    cmpa      #2                  Byte or Integer?
                    blo       CHKV50               Yes, skip ahead
                    beq       L2F93               If real, skip ahead
* (orig: CHKV40)
                    lda       #$47                Illegal Expression Type error
                    lbsr      ERROR         Get variable address
                    bra       CHKV50

* Real comes here
L2F93               lda       <u00D8
                    bsr       INSTOK         Evaluate data value
* Byte/Integer come here
CHKV50               inc       <u00D8
                    subb      #$08
                    bne       L2F83         bra if not byte
CHKV60               lda       <u00D1
                    cmpa      #$05
                    bne       CHKV99
                    ldd       1,x
                    addd      <u0066
                    tfr       d,u
                    ldb       <u00D0
                    beq       L2FB5
                    lsrb                          Divide by 4
                    lsrb
                    addb      #4
* (orig: CHKV70)
                    ldd       b,u
                    bra       CHKV80

L2FB5               ldd       2,u
CHKV80               addd      <u0066
CHKV90               std       <u00D4
                    lda       <u00D1
CHKV99               rts

INSTOK               pshs      x,b
                    ldx       <u000C        Get procedure ptr
                    cmpx      #$0010
                    lbls      PBEXPR
                    ldx       <u0060
                    sta       ,x+
                    stx       <u00AB
                    clrb
                    bsr       L2FDA
                    puls      pc,x,b

L2FD4               ldd       <u0060
                    std       <u00AB
                    ldb       #$01
L2FDA               clra
L2578               jsr       <u001B
                    fcb       $14

* Jump tables (NOTE:SINCE ALL ARE <$80, USE 8 BIT INSTEAD OF 16 BIT OFFSET)
L2FDE               fdb       ALCSMV-L2FDE         $0049
                    fdb       ALCSTV-L2FDE         $005c
                    fdb       ALCARV-L2FDE         $0060
                    fdb       L3048-L2FDE         $006a

L2FE6               fdb       L304C-L2FE6         $0066
                    fdb       ALCARP-L2FE6         $0072
                    fdb       ALCARP-L2FE6         $0072
                    fdb       L305C-L2FE6         $0076

ALCSTO               pshs      u,y,x
                    leay      <L2FDE,pc           Point to 1st jump table
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
                    beq       L300F               Neither set, skip ahead
                    ldd       6,y                 If either set, use 4th entry
                    bra       ALCST5               Go to subroutine

L300F               ldb       ,x                  Reload the value
                    andb      #%00000111          Just keep bits 1-3
ALCST3               cmpb      #%00000100          Just bits 1-2?
                    blo       L3021               Yes, skip ahead
                    bhi       L301D               Bit 3 + at least 1 more bit, skip ahead
                    ldd       2,y                 If just bit 3, use 2nd entry
                    bra       ALCST5               Go to subroutine

L301D               ldd       4,y                 Bit 3 + (1 or 2), use 3rd entry
                    bra       ALCST5               Go to subroutine

L3021               ldd       ,y                  Use 1st entry
ALCST5               jsr       d,y                 Call subroutine
ALCST6               puls      pc,u,y,x            Restore regs & return

ALCSMV               lda       ,x
                    anda      #$07
                    leay      1,x
                    bsr       GETVSZ
ALCSV1               pshs      d                   USE W
                    ldd       <u00C1
                    std       ,y
                    addd      ,s++
                    std       <u00C1
                    rts

ALCSTV               bsr       L3069
                    bra       ALCSV1

ALCARV               bsr       L3069
                    addd      <u0066
                    tfr       d,x
                    ldd       ,x
                    bra       ALCSV1

L3048               bsr       ALCARR
                    bra       ALCSV1

L304C               leay      1,x
L304E               ldd       <u00C3
                    std       ,y
                    addd      #$0004
                    std       <u00C3
                    rts

ALCARP               bsr       L3069
                    bra       L304E

L305C               bsr       ALCARR
                    bra       L304E

ALCARR               ldd       1,x
                    addd      <u0066
                    tfr       d,y
                    ldd       2,y
                    rts

L3069               ldd       #$0004              Requesting 4 bytes of memory from workspace
                    bsr       L257B               Go see if we can get it & allocate it
                    ldx       4,s           Restore I-Code ptr
                    ldd       1,x           Reset free space
                    std       2,y
                    tfr       y,d
                    subd      <u0066        Get string length
                    std       1,x
                    ldd       2,y
                    rts

L257B               jsr       <u001E
                    fcb       $08

* Table of # bytes/var type
L307E               fcb       1                   1 byte =Byte
                    fcb       2                   2 bytes=Integer
                    fcb       5                   5 bytes=Real
                    fcb       1                   1 byte =Boolean
                    fcb       $20                 ??? Flag String value? (or default size=32 bytes)

* Entry: A=Variable type (0-4)
* Exit : B=# bytes to represent variable
GETVSZ               pshs      x                   Preserve X
                    leax      <L307E,pc           Point to 5 1-byte entry table
                    ldb       a,x                 D=#
                    clra                    Msb
                    puls      pc,x

* Single byte entry table
L3095               fcb       $01,$02,$03,$07,$08,$09,$37,$38,$3e,$3f,$ff

BIND               ldd       #$0016
                    std       <u00C1
                    clrb
                    std       <u00C3
                    std       <u00C5        Save for future use
                    sta       <u00C7
                    std       <u00C8
                    std       <u00CA
                    ldx       <u002F              Get ptr to current module
                    sta       <$17,x              Set flags to unpacked, no errors
                    std       <$15,x
L30B8               ldy       <u005E
                    bra       DONE

L30BD               pshs      y
                    lbsr      PSTMT         Go input
                    puls      x
                    ldb       <u00D9
                    bne       DONE
                    lda       ,x
                    leau      <L3095,pc           Point to 11 entry 1 byte table
STAR10               cmpa      ,u+                 Hunt through for range our byte is in
                    blo       DONE               If lower then table entry, skip ahead
                    bne       STAR10               If not equal, keep looking
                    pshs      x                   Equal, preserve X
                    tfr       y,d                 Move ??? to d
                    subd      ,s++
                    leay      ,x            Get name ptr
                    ldu       <u004A              Get ptr to next free byte in I-code workspace
                    stu       <u00AB              Save as ptr to current line I-code end
                    lbsr      L2578
DONE               ldx       <u0060
                    clr       ,x
                    cmpy      <u0060
                    blo       L30BD
L30EB               ldx       <u0066
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
                    cmpx      <u00DA
                    bhs       DONE05
                    ldd       <u0066
                    subd      <u00DA
                    addd      <u000C              Add to bytes free to user
                    std       <u000C              Save as new # bytes free to user
                    ldx       <u0044
                    bra       DONE20

L257E               jsr       <u001E
                    fcb       $06

DONE10               ldy       1,x
                    lda       #$45                Unmatched Control Structure error
                    lbsr      ERROR
                    lda       ,x
                    cmpa      #$13
                    bne       L312D
* (orig: DONE15)
                    leax      7,x
L312D               leax      3,x
                    stx       <u0044        Save I-Code ptr
DONE20               cmpx      <u0046
                    blo       DONE10
                    ldu       <u0066
                    ldy       <u0060
                    ldd       <u0064
                    addd      <u0068
                    bsr       L257E
                    ldx       <u002F              Get current module ptr
                    ldd       <u00C8
                    std       <$13,x
                    ldd       <u00C1
                    std       <$11,x
                    addd      <u00C5
                    std       <u00C5
                    std       $0B,x               Save in data area size require in module header
                    ldb       <$18,x              Get size of module name
                    clra
                    addd      #$0019              Add 25 to it (size of BASIC09 header?)
                    std       M$Exec,x            Save as execution address
                    addd      <u0060
                    subd      <u005E
                    std       $0F,x
                    addd      <u0068
                    addd      #$0003
                    std       $0D,x
                    subd      #$0003
                    addd      <u0064
                    std       M$Size,x            Save as new module size
                    addd      <u002F              Add to current module ptr
                    std       <u004A
                    subd      <u0008
                    std       <u000A
                    ldd       <u002F              Get current module ptr
                    addd      $D,x
                    std       <u0062        Save it
                    ldd       <u002F              Get current module ptr
                    addd      $0F,x
                    std       <u0066        Save procedure ptr
                    ldu       <u0062        Get opstack beginning
                    bra       L31E2

L3188               leax      ,u
                    lbsr      GETTY1
                    lda       <u00CF
                    cmpa      #$60
                    bcs       L31BD         bra if not found
                    cmpa      #$A0
                    bne       DONE30
                    ldd       1,x
                    addd      <u00C1
                    std       1,x
                    bra       DONE70

DONE30               cmpa      #$80
                    bne       L31BD
                    ldb       <u00D0
                    bne       DONE45
* (orig: PASG00)
                    lda       <u00D1
                    cmpa      #$04
                    bcc       DONE45
                    leax      1,u
                    bra       L31B7

DONE45               ldd       1,u
                    addd      <u0066
                    tfr       d,x
L31B7               ldd       ,x
                    addd      <u00C5
                    std       ,x
L31BD               lda       <u00D1
                    cmpa      #$05
                    bne       DONE70
                    ldb       <u00D0
                    beq       DONE60               If 0, force to 2
                    lsrb                          Divide by by 4
                    lsrb
                    addb      #4
                    bra       DONE65

DONE60               ldb       #$02
DONE65               clra
                    addd      1,u
                    ldx       <u0066
                    leay      d,x
                    ldd       ,y
                    ldd       d,x
                    std       ,y
DONE70               leau      3,u
DONE75               lda       ,u+
                    bpl       DONE75
L31E2               cmpu      <u004A
                    blo       L3188
                    rts

* Called by <$24 JMP vector
* Entry: X=byte after the last vector installed ($2D)
*        D=Last vector offset from start of BASIC09's module header
* Based on function code following the JMP that came here, this routine
*  modifies the return address to 1 of 7 routines
L31E8               pshs      x,d                 Preserve ptr & offset
                    ldb       [<4,s]              Get function code-style byte
                    leax      <L31F8,pc           Point to vector table
                    ldd       b,x                 Get vector offset
                    leax      d,x                 Calculate address
                    stx       4,s                 Modify RTS address
                    puls      pc,x,d              Restore X & D and return to new routine

* Vector table for <$24 calls
L31F8               fdb       L3BFF-L31F8         Function 0 call
                    fdb       EXECUT-L31F8         Function 1 call
                    fdb       RPARAM-L31F8         Function 2 call
                    fdb       EXCERR-L31F8         Function 3 call  (error message)
                    fdb       L33AE-L31F8         Function 4 call
                    fdb       TONSTM-L31F8         Function 5 call
                    fdb       TOFSTM-L31F8         Function 6 call

* Jump table (from L323F+offset)
L323F               fdb       L3A51-L323F
                    fdb       L3A51-L323F
                    fdb       L3A51-L323F
                    fdb       L3A51-L323F
                    fdb       L3A51-L323F
                    fdb       STPSTM-L323F
                    fdb       L3209-L323F         Go direct to JSR <1B / fcb $C
                    fdb       TONSTM-L323F
                    fdb       TOFSTM-L323F
                    fdb       L35F3-L323F
                    fdb       DEGSTM-L323F
                    fdb       RADSTM-L323F
                    fdb       RETSTM-L323F
                    fdb       L33AE-L323F
                    fdb       L352D-L323F
                    fdb       L35D2-L323F
                    fdb       IFSTM-L323F
                    fdb       GTOSTM-L323F
                    fdb       L33D3-L323F
                    fdb       FORS20-L323F
                    fdb       L33E7-L323F         NEXT routine
                    fdb       WHLSTM-L323F
                    fdb       GTOSTM-L323F
                    fdb       L33AE-L323F
                    fdb       WHLSTM-L323F
                    fdb       L33AE-L323F
                    fdb       GTOSTM-L323F
                    fdb       WHLSTM-L323F
                    fdb       GTOSTM-L323F
                    fdb       ONSTM-L323F
                    fdb       ERRSTM-L323F
                    fdb       ELNSTM-L323F
                    fdb       GTOSTM-L323F
                    fdb       ELNSTM-L323F
                    fdb       GSBSTM-L323F
                    fdb       L3A8A-L323F
                    fdb       L3BF3-L323F
                    fdb       INPSTM-L323F
                    fdb       PRTSTM-L323F
                    fdb       CHDSTM-L323F
                    fdb       L398A-L323F
                    fdb       CRTSTM-L323F
                    fdb       L3691-L323F
                    fdb       SEKSTM-L323F
                    fdb       RDSTM-L323F
                    fdb       WRTSTM-L323F
                    fdb       GETSTM-L323F
                    fdb       L391E-L323F
                    fdb       CLSSTM-L323F
                    fdb       L3957-L323F
                    fdb       DLTSTM-L323F
                    fdb       CHNSTM-L323F
                    fdb       L39BC-L323F
                    fdb       B0STM-L323F
                    fdb       B1STM-L323F
                    fdb       L3A48-L323F
                    fdb       L3A48-L323F
                    fdb       ENDSTM-L323F
                    fdb       L33AC-L323F
                    fdb       L33AC-L323F
                    fdb       DIREXC-L323F
                    fdb       ELNSTM-L323F
                    fdb       NULSTM-L323F
                    fdb       NULSTM-L323F
                    fdb       SBYTAS-L323F
                    fdb       RSTS10-L323F
                    fdb       L356F-L323F
                    fdb       SBYTAS-L323F
                    fdb       SSTRAS-L323F
                    fdb       L35BB-L323F

L3209               jsr       <u001B
                    fcb       $0c

L32CB               fcc       'STOP Encountered'
                    fcb       C$LF,$FF

* Vector #2 from table at L31F8 comes here

EXECUT               lda       $17,x               Get something
                    bita      #$01                check if 1st bit is set
                    beq       EXEC10               no, skip ahead
                    ldb       #$33          Err: run aborted
                    bra       L3304

EXEC10               tfr       s,d
                    subd      #$0100        Need at least 256 bytes
                    cmpd      <u0080        is there that much?
                    bhs       L32F6
                    ldb       #$39          Err: system stack overflow
                    bra       L3304

L32F6               ldd       <u000C
                    subd      $0B,x         Remove needed variable storage
                    blo       MEMFUL
                    cmpd      #$0100        minimum opstack?
                    bhs       EXEC20
MEMFUL               ldb       #$20                Memory full error
L3304               lbra      EXCERR

EXEC20               std       <u000C
                    tfr       y,d
                    subd      $0B,x         Make room for vars on u
                    exg       d,u
                    sts       5,u           Save current stack
                    std       7,u           Save caller's storage address
* (orig: SETGLB)
                    stx       3,u           Set procedure address
EXEC30               ldd       #$0001
                    std       <u0042        Default array base to one
                    sta       1,u           Default trig mode to radians
                    sta       <$13,u        Clear error flag
                    stu       <$14,u        Init subroutine stack
                    bsr       RUNS50         Set I.xxxx globals
                    ldd       <$13,x        Get offset of first data statement
                    beq       L332C         bra if none
                    addd      <u005E        Add ptr to I-Code beginning
L332C               std       <u0039
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
                    bra       L333F

L333D               std       ,y++
L333F               cmpy      ,s
                    blo       L333D
                    leas      2,s           Return scratch
                    ldx       <u002F
* (orig: ASGV20)
                    ldd       <u005E        Get ptr to I-Code beginning
                    addd      <$15,x        Add offset of first executable statement
                    tfr       d,x
                    bra       L3391         Jump into statment loop

RUNS50               stx       <u002F              Save current module ptr
                    stu       <u0031        Set storage base address
                    ldd       $0D,x
                    addd      <u002F              Add to start address of module
                    std       <u0062
                    ldd       $0F,x
                    addd      <u002F              Add to start address of module
                    std       <u0066
                    std       <u0060
* (orig: ASGRL1)
                    ldd       M$Exec,x            Get exec offset
                    addd      <u002F              Add to start of module address
                    std       <u005E              Save exec offset
                    ldd       <$14,u
                    std       <u0046
                    std       <u0044
                    rts

STMLUP               stx       <u005C
                    lda       <u0034              Get signal received flag
                    beq       L338F               Nothing happened, skip ahead
                    bpl       STML10               No signal flagged, skip ahead
                    anda      #$7F                Mask off signal received bit flag
                    sta       <u0034              Save masked version
                    lbsr      L3233               JSR <1B, fcb $18
                    lda       <u0034              Shift out least sig bit
STML10               rora                    Trace bit set?
                    bcc       L338F               Not set, skip ahead
                    leay      ,x            Copy I-Code ptr
                    lbsr      L3218         Move copy to next statement
                    clr       <u0074
                    bsr       L3236
L338F               bsr       L33AE
L3391               cmpx      <u0060
                    blo       STMLUP
                    bra       INIT         ..exit

L3236               jsr       <u001B
                    fcb       $16

ENDSTM               ldb       ,x
                    lbsr      L384F         End of line?
                    beq       INIT         ..yes; don't print anything
                    lbsr      PRTSTM         Print message if there is one
INIT               lbsr      TOFSTM
                    ldu       <u0031        Get storage base address
                    lds       5,u           Reset stack
                    ldu       7,u           Get caller's storage address
NULSTM               rts                     Statements use this return

L33AC               leax      2,x
L33AE               ldb       ,x+
                    bpl       L33B4               Hi bit clear, skip ahead
                    addb      #$40                ??? Wrap it around
L33B4               lslb                          Multiply by 2
                    clra                          Unsigned D
                    ldu       <u000E              Get ptr to L323F
                    ldd       d,u                 Get offset
                    jmp       d,u                 Jump to that routine

IFSTM               jsr       <u0016
                    tst       2,y           Test result
                    beq       GTOSTM
                    leax      3,x           Move I-Code ptr
                    ldb       ,x
                    cmpb      #$3B          is it line ref?
                    bne       NULSTM         Yes; do next statement
* (orig: EIFSTM)
                    leax      1,x           Skip line refernce TOKEN
GTOSTM               ldd       ,x
                    addd      <u005E        Make offset a ptr
                    tfr       d,x           Move to I-Code ptr
                    rts

L33D3               leax      1,x
                    rts

* UNTIL
WHLSTM               jsr       <u0016
                    tst       2,y           Check result
                    beq       GTOSTM               False, go back
                    leax      3,x           Skip goto & following (do, then)
                    rts

* NEXT routine
L33E7               leay      <L33DF,pc           Point to table
L33EA               ldb       ,x+                 Get byte
                    ldb       b,y                 Get jump offset
                    ldu       <u0031              Get Base address for variable storage
                    jmp       b,y                 Jump to appropriate routine

FOR1IN               ldd       ,x
                    leay      d,u
                    bra       L3410

NXT1IN               ldd       ,x
                    leay      d,u           Make offset into ptr
                    ldd       4,x
                    lda       d,u           Test increment sign
                    bpl       L3410
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
L3410               ldd       2,x                 Get offset to TO variable
                    leax      6,x                 Eat temp var
                    ldd       d,u                 Get TO variable
                    cmpd      ,y                  We hit it yet?
                    bge       GTOSTM               Yes, do X=[,x]+[u005E] & return
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
                    bpl       L3410               No, go use normal compare routine
NXTIN2               ldd       2,x                 Get offset to TO value
                    leax      6,x                 Eat temp var
                    ldd       d,u                 Get TO value
                    cmpd      ,y                  Hit TO value yet?
                    ble       GTOSTM               Yes, do X=[,x]+[u005E] & return
                    leax      3,x                 Eat 3 bytes from X & return
                    rts

FOR1RL               ldy       <u0046
                    clrb
                    bsr       NXTRLA
                    bra       NXTRL1

L3446               ldy       <u0046
                    clrb
                    bsr       NXTRLA
                    ldd       4,x           Get increment offset
                    addd      #4            Get offset of increment end
                    ldu       <u0031        Get storage base
                    lda       d,u           Get sign byte
                    lsra                    Sign
                    bcc       NXTRL1
                    bra       NXTRL2

* NEXT table
* IF some of these entry points are moved before this table, 8 bit addressing
* may be used instead of 16
L33DF               equ       *
                    fcb       NXTIN1-L33DF         Integer STEP 1
                    fcb       NXTINT-L33DF         Integer STEP <>1
                    fcb       NXT1RL-L33DF         Real STEP 1
                    fcb       NXTRL-L33DF         Real STEP <>1

* Jump table for FOR (relative to L34E5) (change to 8 bit if possible)
L34E5               equ       *
                    fcb       FOR1IN-L34E5         $ff0e   INT step 1
                    fcb       NXT1IN-L34E5         $ff14   INT step <>1
                    fcb       FOR1RL-L34E5         $ff59   REAL step 1
                    fcb       L3446-L34E5         $ff61   REAL step <>1

* REAL NEXT STEP 1
NXT1RL               ldy       <u0046              ??? Get subroutine stack ptr
                    clrb
                    bsr       NXTRLA         Move counter to opstack
                    leay      -6,y                Make room for REAL variable
                    ldd       #$0180              Initialize it to contain 1.
                    std       1,y
                    clra
                    clrb
                    std       3,y
                    sta       5,y
                    lbsr      L3FB1               Increment counter (Do REAL add)
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
                    addd      <u0031              Add to ptr to start of variable storage
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

NXTRL               ldy       <u0046
                    clrb
                    bsr       NXTRLA         Move counter to opstack
                    stu       <u00D2        Save counter addr
                    ldb       #$04
                    bsr       NXTRLA         Move increment to opstack
                    lda       4,u           Get sign byte
                    sta       <u00D1
                    lbsr      L3FB1               Inc current FOR/NEXT value by STEP (Do REAL Add)
                    ldu       <u00D2        Get counter address
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
                    lsr       <u00D1              Check sign
                    bcc       NXTRL1               Positive, use that direction check
* Decrementing REAL STEP value
NXTRL2               ldb       #$02
                    bsr       NXTRLA         Move terminal to opstack
                    leax      6,x
                    lbsr      RLCMP               Do REAL compare
                    lbge      GTOSTM               Still bigger, keep looping
                    leax      3,x           Skip loop addr. & stmt term.
NXTR30               rts

FORSTM               ldb       <u0034              Get flag byte
                    bitb      #$01                Least sig bit set?
                    beq       NXTR30               No, return
                    jsr       <u001B
                    fcb       $1c

FORS20               ldb       ,x+
                    cmpb      #$82
                    beq       L3515
                    bsr       RSTS10         Init counter
                    bsr       FORINT         Init terminal
                    ldb       -1,x          Get next TOKEN
                    cmpb      #$47
                    bne       FORS10
                    bsr       FORINT         Init increment
FORS10               lbsr      GTOSTM
                    leay      >L34E5,pc           Point to table
                    lbra      L33EA         Dispatch to assignment

FORINT               ldd       ,x++
                    addd      <u0031        Make offset into ptr
                    pshs      d             Save it
                    jsr       <u0016        Process format string
                    ldd       1,y
                    std       [,s++]        Store it
                    rts

L3515               bsr       L356F
                    bsr       FORRL         Init terminal
                    ldb       -$01,x
                    cmpb      #$47
                    bne       FORS10         bra if not
                    bsr       FORRL         Init increment
                    bra       FORS10

FORRL               ldd       ,x++
                    addd      <u0031
                    pshs      d             Save it
                    jsr       <u0016        Evaluate expression
                    bra       ASGRL         Store result

* LET
L352D               jsr       <u0016              Get var type
L352F               cmpa      #4                  Numeric or Boolean?
                    blo       L3537               Yes, skip ahead
                    pshs      u                   Preserve U
                    ldu       <u003E              ??? Get max var size for string or array
L3537               pshs      u,a                 Save Size or Ptr & var type
                    leax      1,x           Skip assignment TOKEN
                    jsr       <u0016
L353D               puls      a
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
                    addd      <u0031        make offset into ptr
                    pshs      d
                    leax      3,x           move I-Code ptr
                    jsr       <u0016        Evaluate expression
* LET - Byte/Boolean
ASGBYT               ldb       2,y                 Get byte/boolean value
                    stb       [,s++]              Save at address on stack, eat stack & return
                    rts

RSTS10               ldd       ,x
                    addd      <u0031
                    pshs      d
                    leax      3,x
                    jsr       <u0016
* LET - Integer
ASGINT               ldd       1,y                 Get integer value
                    std       [,s++]              Save at address on stack, eat stack & return
                    rts

L356F               ldd       ,x
                    addd      <u0031
                    pshs      d
                    leax      3,x
                    jsr       <u0016        Evaluate expression
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
                    addd      <u0066        Make offset into ptr
                    tfr       d,u
                    ldd       ,u            Get storage offset
                    addd      <u0031        Make offset into ptr
                    pshs      d             Save it
                    ldd       2,u           Get string max length
                    pshs      d             Save it
                    leax      3,x
                    jsr       <u0016        Evaluate expression
* LET - String
ASGSTR               puls      u,d
                    tstb
                    bne       ASGSR0
                    deca
ASGSR0               sta       <u003E
                    ldy       1,y           Get result addr
                    sty       <u0048        Clean string stack
* Block copy up to $FF (string terminator)
ASGSR1               lda       ,y+
                    sta       ,u+           Store it
                    cmpa      #$FF                End of string?
                    beq       L35B9               Yes, skip ahead
                    decb                          Dec string size counter
                    bne       ASGSR1               More left, continue copying
                    dec       <u003E
                    bpl       ASGSR1
L35B9               clra                    Carry
                    rts

* LET - Array
ASGRCD               puls      u,d
                    cmpd      3,y           is result smaller?
                    bls       POKSTM         bra if not
                    ldd       3,y           Get result size
POKSTM               ldy       1,y
                    exg       y,u
                    jsr       <u001E              Return from routine
                    fcb       $06

L35D2               jsr       <u0016
                    ldd       1,y
                    pshs      d             Save it
                    jsr       <u0016
                    ldb       2,y
                    stb       [,s++]
                    rts

STPSTM               lbsr      PRTSTM
                    lda       <u002E
                    sta       <u007F
                    leax      >L32CB,pc           Point to 'STOP encountered'
                    lbsr      STROUT         Float it
                    lbra      L1CC7         Call command to exit

L35F3               lbsr      PRTSTM
L3233               jsr       <u001B              Use module header jump vector #1
                    fcb       $18

GSBSTM               ldd       ,x
                    leax      3,x           Skip offset & statement end
GSBST1               ldy       <u0031
                    ldu       <$14,y        Get subroutine stack ptr
                    cmpu      <u004A        Check for overflow
                    bhi       GSBST2         bra if ok
                    ldb       #$35                Subroutine stack overflow error
                    lbra      EXCERR

GSBST2               stx       ,--u
                    stu       <$14,y        Save sub stack ptr
                    stu       <u0046        Reset opstack
                    addd      <u005E        Make offset a ptr
                    tfr       d,x           Move to I-Code ptr
                    rts

RETSTM               ldy       <u0031
                    cmpy      <$14,y        Are there any return addrs?
                    bhi       RETST1         bra if so
                    ldb       #$36                Subroutine stack underflow error
                    lbra      EXCERR

RETST1               ldu       <$14,y
                    ldx       ,u++          Pop return addr
                    stu       <$14,y        Save sub stack ptr
                    stu       <u0046        Reset opstack
                    rts

ONSTM               ldd       ,x
                    cmpa      #$1E          is this ON ERROR?
                    beq       ONSTM2         Yes; go init error address
                    jsr       <u0016        Get dispatch value
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
                    addd      <u005E        Make offset into ptr
                    tfr       d,x           Use as I-Code ptr
L366A               rts

ONSTM1               puls      pc,x

ONSTM2               ldu       <u0031
                    cmpb      #$20          is it ON ERROR GOTO?
                    bne       ONSTM3         bra if not
                    ldd       2,x           Get I-Code offset
                    addd      <u005E        Make offset into ptr
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

L3691               bsr       OPNSUB
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
                    jsr       <u0016        Get path name
                    lda       #$03
                    cmpb      #$4A          is there declared mode?
                    bne       OPNS30         bra if not
                    lda       ,x++          get mode specified
OPNS30               ldu       3,s
                    stx       3,s           Save I-Code ptr
                    ldx       1,y           Get pathlist ptr
                    jmp       ,u

SEKSTM               lbsr      SETCHL
                    jsr       <u0016        Get position
                    ldb       #$0E          Set code
                    lbsr      L3230
                    lbcs      EXCER1         bra if error
* (orig: NOCHG)
                    rts

* Input prompt?
L36CE               fcc       '? '
                    fcb       $ff

* Illegal input error message
L36D1               fcc       '** Input error - reenter **'
                    fcb       $0d,$ff

INPSTM               lda       <u002E
                    lbsr      SETCHL         Set path number
                    lda       #$2C          use comma as item separator
                    sta       <u00DD        set item separator
                    pshs      x             Save x
INPS10               ldx       ,s
                    ldb       ,x            Get next TOKEN
                    cmpb      #$90          is there prompt?
                    bne       L3709         No; use default
                    jsr       <u0016        Evaluate it
* (orig: INPS20)
                    pshs      x             Save I-Code ptr
                    ldx       1,y           Get ptr to string
                    bra       INPS30

L3709               pshs      x
                    leax      <L36CE,pc           Point to '? '
INPS30               bsr       STROUT
                    puls      x             Restore I-Code ptr
                    lda       <u007F
                    cmpa      <u002E        proper child dead?
                    bne       RDST05
                    lda       <u002D
                    sta       <u007F
RDST05               ldb       #$06
L371E               bsr       L3230
                    bcc       INPS40         ..continue if no error
                    cmpb      #$03          Keyboard interrupt?
                    lbne      EXCER1
                    lbsr      DEBUG         print line, call debugger
                    clr       <u0036              Clear out error code
                    bra       INPS10         Re-issue input request

INPS40               bsr       INPVAR
                    bcc       INPS50         bra if so
                    leax      <L36D1,pc           Print 'Input error re-enter'
                    bsr       STROUT         Print error msg
                    bra       INPS10         Check it out

INPS50               ldb       ,x+
                    cmpb      #$4B          Are there more?
                    beq       INPS40         Yes; skip a data entry
                    puls      pc,d          Clean stack & return

INPVAR               bsr       ASGVAR
                    ldb       ,s            Get TYPE
                    addb      #$07          Get code for input of TYPE
                    ldy       <u0046        Init opstack ptr
                    bsr       L3230         Set up for system call
                    lbcc      L353D         Go dispatch for assignment
***************
* Bad Input Handler
* (orig: BADLIN)
                    lda       ,s            Get TYPE
BADLI1               cmpa      #$04
                    bcs       L375B         is simple; do normal clean up
                    leas      2,s           Remove extra bytes
L375B               leas      3,s
                    coma                    Carry
                    rts

***************
* Call CNVIO to Output String
STROUT               pshs      y
                    leas      -6,s
                    leay      ,s
                    stx       1,y
                    ldd       <u0080        Reset I/O buffer ptr
                    std       <u0082
                    ldb       #$05
                    bsr       L3230
                    clrb
                    bsr       L3230               call L5084, function 2, sub-function 0 (B)
                    leas      6,s           Clean up stack
                    puls      pc,y

L3230               jsr       <u002A              Use module header jump vector #6
                    fcb       $02                 Function code

ASGVAR               lda       ,x+
                    cmpa      #$0E          is it complex assignment?
                    bne       L3783         No; do simple
                    jsr       <u0016        Evaluate it
                    bra       L37A8

L3783               suba      #$80
                    cmpa      #$04          What type?
                    blo       L379E
                    beq       ASGV30         Yes; done
                    lbsr      L3224         Must be parameter or unbound variable
                    bra       L37A8

ASGV30               ldd       ,x++
                    addd      <u0066
                    tfr       d,u
                    ldd       2,u
                    std       <u003E        Save it
                    ldd       ,u            Get storage offset
                    bra       ASGV40

L379E               ldd       ,x++
ASGV40               addd      <u0031
                    tfr       d,u
                    lda       -3,x          Get TOKEN
                    suba      #$80          Change TOKEN to TYPE
L37A8               puls      y
                    cmpa      #$04          need to save size?
                    blo       L37B2
                    pshs      u
                    ldu       <u003E        get size
L37B2               pshs      u,a
                    jmp       ,y            Return

SETCHL               ldb       ,x
                    cmpb      #$54          is it path token?
                    bne       SETC10         bra if not
                    leax      1,x
                    jsr       <u0016        Process path number expression
                    cmpb      #$4B          Skip comas if present
                    beq       SETC05         bra if coma last
                    leax      -1,x          Compensate for eval
SETC05               lda       2,y
SETC10               sta       <u007F
                    rts

RDSTM               ldb       ,x
                    cmpb      #$54
                    bne       RDST30
                    bsr       SETCHL         Set path number
                    clr       <u00DD        use zero as item separator
                    cmpb      #$4B          is it coma?
                    bne       PUSNG2         bra if not
                    leax      -1,x          Back up to it
***************
* List Process Loop
PUSNG2               ldb       #$06                Call L5084, function 2, sub-function 6 (B)
                    bsr       L3230               (Do ReadLn into temp buff, max of 256 bytes)
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

RDST30               bsr       L384F
                    beq       SKPDAT
L37F9               bsr       RDDATA
                    ldb       ,x+
                    cmpb      #$4B
                    beq       L37F9
                    rts

RDDATA               lbsr      ASGVAR
                    bsr       EVLDAT
                    lda       ,s
                    bne       RDDAT1
                    inca
RDDAT1               cmpa      ,y
                    lbeq      L353D
                    cmpa      #$02
                    blo       L381C
                    beq       L3828
RDDAT2               ldb       #$47                Illegal Expression Type
                    bra       RDDATErr

L381C               lda       ,y                  Get var type
                    cmpa      #$02                Real #?
                    bne       RDDAT2               No, exit with Illegal Expression Type erro
                    bsr       ASGSTM               Call FIX (REAL to INT) routine
                    lbra      L353D

ASGSTM               jsr       <u0027
                    fcb       $0c
L322A               jsr       <u0027
                    fcb       $0e

L3828               cmpa      ,y
                    bcs       RDDAT2         ..No
                    bsr       L322A
                    lbra      L353D

SKPDAT               leax      1,x
EVLDAT               pshs      x
                    ldx       <u0039
                    bne       EVLD10
                    ldb       #$4F                Missing Data Statement error
RDDATErr               lbra      EXCERR

EVLD10               jsr       <u0016
                    cmpb      #$4B
                    beq       EVLD20
                    ldd       ,x            Get descr area offset
                    addd      <u005E
                    tfr       d,x
EVLD20               stx       <u0039
                    puls      pc,x

L384F               cmpb      #$3F
                    beq       EOLT99
                    cmpb      #$3E
EOLT99               rts

PRTSTM               lda       <u002E
                    lbsr      SETCHL         Set sign
                    ldd       <u0080
                    std       <u0082
                    ldb       ,x+           Get status code
* (orig: PRTST3)
                    cmpb      #$49
                    beq       PUSING
PRTST2               bsr       L384F
                    beq       PRTST7
L3869               cmpb      #$4B
                    beq       L387F
                    cmpb      #$51
                    beq       PRTST6
                    leax      -1,x
                    jsr       <u0016
* (orig: PRTST4)
                    ldb       ,y
                    addb      #$01
                    bsr       IODISP
* (orig: PRTST5)
                    ldb       -1,x
                    bra       PRTST2

L387F               ldb       #$0D
                    bsr       IODISP
PRTST6               ldb       ,x+
                    bsr       L384F
                    bne       L3869
                    bra       L388F

PRTST7               ldb       #$0C                L5084, function 2, sub-function C
                    bsr       IODISP               (WritLn a Carriage return)

L388F               clrb                          L5084, function 2, sub-function 0
                    bsr       IODISP               (WritLn the temp buffer)
                    lda       <u00DE
                    clr       <u00DE
                    tsta
                    bne       IOError
PRTST9               rts

IODISP               lbsr      L3230               Call <u002A, function 2
                    bcc       PRTST9               If no error, return
IOError               lbra      EXCER1               Error from WritLn, report it

PUSING               jsr       <u0016
                    ldd       <u004A
                    std       <u008E
                    std       <u008C
                    ldu       <u0046
                    pshs      u,d
                    clr       <u0094
                    ldd       <u0048
                    std       <u004A
L38B5               ldb       -1,x
                    bsr       L384F
                    beq       L38D7
                    ldb       ,x+
                    bsr       L384F
                    beq       PUSN25
                    leax      -1,x
                    ldb       #$11
                    lbsr      L3230
                    bcc       L38B5
                    puls      u,d
                    std       <u004A
                    stu       <u0046
                    bra       IOError

PUSN25               leay      <L388F,pc           Point to routine
                    bra       PUSN35

L38D7               leay      <PRTST7,pc           Point to routine
PUSN35               puls      u,d
                    std       <u004A
                    stu       <u0046
                    jmp       ,y

WRTSTM               lda       <u002E
                    lbsr      SETCHL
                    ldu       <u0080
                    stu       <u0082        Put str addr on opstack
                    ldb       ,x+
                    lbsr      L384F
                    beq       WRTS30
                    cmpb      #$4B
                    beq       WRTS20
                    leax      -1,x
                    bra       WRTS20

WRTS10               clra
                    ldb       #$12
                    lbsr      L3230         Move to opstack
                    bcs       IOError
WRTS20               jsr       <u0016
                    ldb       ,y
                    addb      #$01
                    lbsr      L3230
                    bcs       IOError         bra if so
                    ldb       -$01,x
                    lbsr      L384F         Get mod(arg,2pi)
                    bne       WRTS10
WRTS30               lbra      PRTST7

GETSTM               bsr       GPSET
                    os9       I$Read
                    bra       PUTSTM90

L391E               bsr       GPSET
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
                    leax      >L3B5B,pc           Point to 4 entry, 1 byte table
                    ldb       a,x
                    clra
                    tfr       d,y                 Y=table entry
                    bra       L3945

GPSE10               puls      y
L3945               puls      x
                    lda       <u007F
GPSE99               rts

CLSSTM               lbsr      SETCHL
                    os9       I$Close             Close path
                    bcs       PUTErr               Error,
                    cmpb      #$4B
                    beq       CLSSTM
                    rts

L3957               ldb       ,x+
                    cmpb      #';
                    beq       L3967
                    ldu       <u002F              Get ptr to current procedure
* (orig: RSTS20)
                    ldd       $13,u
L3962               addd      <u005E
                    std       <u0039
                    rts

L3967               ldd       ,x
                    addd      #$0001        Make ptr to end of string - length pattern
                    leax      3,x
                    bra       L3962

DLTSTM               jsr       <u0016
                    pshs      x
                    ldx       1,y                 Get ptr to full pathlist
                    os9       I$Delete            Delete file
DLTS10               bcs       PUTErr               Error, deal with it
                    puls      pc,x                Restore X & return

CHDSTM               jsr       <u0016
                    lda       #READ.              Open directory in Read mode
CHDS10               pshs      x                   Preserve X
                    ldx       1,y                 Get ptr to full path list
                    os9       I$ChgDir            Change directory
                    bra       DLTS10

L398A               jsr       <u0016
                    lda       #EXEC.              Execution directory
                    bra       CHDS10               Go change execution directory

SPATH               lbsr      ASGVAR
                    ldy       <u0046        Get opstack ptr
                    leay      -6,y
                    ldb       <u007F
                    clra
                    std       1,y
                    lbra      L353D

CHNSTM               jsr       <u0016
                    ldy       1,y                 Get what will be param area ptr
                    pshs      u,y,x
                    bsr       SYSSTM
                    puls      u,y,x
                    bsr       SYSSUB               Set regs for chain to SHELL
                    sts       <u00B1              Save stack ptr
                    lds       <u0080              Get other stack ptr
                    os9       F$Chain             Chain to other program
                    lds       <u00B1              Chain obviously didn't work, get old SP back
                    bra       EXCERR               Process error code

SYSSTM               jsr       <u001B
                    fcb       $0e

L39BC               jsr       <u0016
                    pshs      u,x
                    ldy       1,y
                    bsr       SYSSUB               Do stuff & point X to 'shell'
* (orig: SYSSTM10)
                    os9       F$Fork              Fork a shell
                    bcs       EXCERR               If error, go to error routine
                    pshs      a                   Save process #
L39CC               os9       F$Wait              Wait until child process is done
                    cmpa      ,s                  Got wakeup signal, was it our child?
                    bne       L39CC               No, keep waiting
                    leas      1,s                 Yes, eat process # off of stack
                    tstb                          Error?
                    bne       EXCERR               Yes, go to error routine
                    puls      pc,u,x              No, restore regs & return

L39DA               fcc       'SHELL'
                    fcb       C$CR

* Entry: Y=Ptr to parameter area
SYSSUB               ldx       <u0048
                    lda       #C$CR
                    sta       -1,x
* Should be SUBR y,x / TFR y,u / TFR x,y / LEAX <L39DA,pc / clrd / RTS
                    tfr       x,d
                    leax      <L39DA,pc           Point to 'Shell'
                    leau      ,y                  Point U to parameter area
                    pshs      y
                    subd      ,s++
                    tfr       d,y                 Move param area size to Y
                    clra                          Any language/type
                    clrb                          Data area size to 0 pages
                    rts

ERRSTM               jsr       <u0016
                    ldb       2,y           Zero divisor error
* Error routine from forking a shell?
EXCERR               stb       <u0036              Save error code
EXCER1               ldu       <u0031
                    beq       EXCER4
                    tst       <$13,u        Test divisor
                    beq       EXCER2         ..No
                    lds       5,u
                    ldx       <$11,u
                    ldd       <$14,u
                    std       <u0046
* (orig: BYESTM)
                    lbra      STMLUP

EXCER2               bsr       DEBUG
                    bsr       TOFSTM
                    lbra      L1CC7

* Entry: B=Error code
EXCER4               lbsr      L1CC1               Print error message
                    lbra      L1CC7

L3A21               fcb       $0E                 Display Alpha code (for VDGInt screen)
                    fcb       $ff                 String terminator

DEBUG               leax      <L3A21,pc           Point to force alpha string code
                    lbsr      STROUT               Go print it out to shut off any VDGInt gfx screen
                    ldx       <u005C
                    leay      ,x
                    bsr       L3218
                    clr       <u0074        Clear x coordinate sign
                    lbsr      L3236         Return pi/2
                    ldb       <u0036              Get error code
                    lbsr      L1CC1               Print error message
                    jsr       <u001B              Call function & return from there
                    fcb       $18

* BASE 0
B0STM               clrb                          Save 0 in <42, incx, return
                    bra       BASSTM

* BASE 1
B1STM               ldb       #1                  Save 1 in <42, incx, return
BASSTM               clra
                    std       <u0042
                    leax      1,x
                    rts

L3218               jsr       <u001B
                    fcb       $10

* REM/TRON/TROFF/PAUSE/RTS
* Skip # bytes used up by REM text
L3A48               ldb       ,x+                 Get # bytes to skip ahead
                    abx                           Point X to next instruction
                    rts

DIREXC               exg       x,pc                Jump to routine pointed to by X
                    rts                           If EXG X,PC done again, return from here

L3A51               leay      ,x
                    bsr       L3218
                    leax      ,y
                    rts

ELNSTM               ldb       #$33                Line with compiler error
                    bra       EXCERR

DEGSTM               lda       #$01
                    bra       RAD2

RADSTM               clra
RAD2               ldu       <u0031
                    sta       1,u
                    leax      1,x
                    rts

***************
* Set/Clear Trace Flag
TONSTM               lda       <u0034              Get signal flags
                    bita      #$01                LSb set?
                    bne       L3A89               Yes, exit
                    ora       #$01                force it on
                    bra       CHGTRC

TOFSTM               lda       <u0034              Get signal flags
                    bita      #$01                Least sig set?
                    beq       L3A89               Yes, return
                    anda      #$FE                Clear least sig
CHGTRC               sta       <u0034              Save modified copy
                    ldd       <u0017              Swap JMP ptrs between L3C32 & EVAL
                    pshs      d
                    ldd       <u0019
                    std       <u0017
                    puls      d
                    std       <u0019
L3A89               rts

L3212               jsr       <u001B              Verify/Insert module into workspace
                    fcb       $00

* Copy DIM'd array
L3224               jsr       <u0027
                    fcb       $02

L35BB               bsr       L3224
                    lbra      L352F

* Entry: U=source ptr of copy (or L3224 generates U - Look up in string pool)
L3A8A               bsr       L3224
                    pshs      x
                    ldb       <u00CF
                    cmpb      #$A0
                    beq       RUNS10
                    ldy       <u0048              Get destination ptr for copy
                    ldx       <u003E              Get max size of copy
RUNS05               lda       ,u+                 Get byte
                    leax      -1,x                Bump counter down
                    beq       RUNS07               Finished, skip ahead
                    sta       ,y+                 Save char
                    cmpa      #$FF                String terminator?
                    bne       RUNS05               No, keep copying
                    lda       ,--y                Yes, get last char before terminator
RUNS07               ora       #$80                Set hi bit on last char
                    sta       ,y                  Save it out
                    ldy       <u0048
                    bsr       L3212
                    bcs       BADPRC
                    leau      ,x
RUNS10               ldd       ,u
                    bne       RUNS20
                    ldy       <u00D2
                    leay      3,y
                    bsr       L3212
                    bcs       BADPRC         bra if so
                    ldd       ,x            Return large number
                    std       ,u
RUNS20               ldx       ,s
                    std       ,s
                    ldu       <u0031
                    lda       <u0034              Get flags
                    sta       ,u                  Save them
                    ldb       <u0043
                    stb       2,u
                    ldd       <u004A              Get ptr to 1st free byte in I-code workspace
                    std       $D,u                Save it
                    ldd       <u0040              Get ptr to end of parm packets being passed
                    std       $F,u
                    ldd       <u0039
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
                    ldd       <u0040              Get ptr to end of parm packets @ Y
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
                    ldu       <u0031              Get ptr to U block of data from above
                    lds       5,u                 Get old stack ptr back
                    puls      x                   Get original 5,u value
                    stx       5,u                 Save it back
                    bcc       L3B3C               If no error, resume program
                    bra       RUNERR               Notify user of error from ML subroutine

* BASIC09 or RUNB module subroutine call goes here
RUNS40               lbsr      TOFSTM               If line with compiler err flg set, swap 17/19 vectors
                    lda       <u0034              Get flags
                    anda      #$7F                Mask out pending signal flag
                    sta       <u0034              Save flags back
                    lbsr      EXECUT               Go check for line with compiler error/stack ovrflw
                    lda       ,u
                    bita      #$01
                    beq       L3B3C
                    lbsr      TONSTM         Get sqr(1-arg*arg)
                    lda       ,u
                    sta       <u0034
L3B3C               ldd       $D,u
                    std       <u004A
                    ldd       $F,u
                    std       <u0040              Save end of parm packets ptr
                    ldd       9,u
                    std       <u0039
                    ldb       2,u
                    sex
                    std       <u0042
                    ldx       $3,u
                    lbsr      RUNS50
                    ldx       $B,u
                    ldd       <u0044
                    subd      <u004A              Subtract ptr to next free byte in workspace
                    std       <u000C              Save # bytes free for user
                    rts

* Table of size of variables
L3B5B               fcb       1                   Byte    (type 0)
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
L3B6C               pshs      y                   Save ptr to flag byte
                    ldb       ,x
                    cmpb      #$0E
                    beq       RPAR25
                    jsr       <u0016
                    leax      -1,x
                    cmpa      #2                  Real variable?
                    beq       RPAR15               Yes, skip ahead
                    cmpa      #4                  String/complex type variable?
                    beq       RPAR20               Yes, set up string stuff
                    ldd       1,y                 Byte/Integer/Boolean - Get value from var packet
                    std       4,y                 Duplicate it later in var packet
                    lda       ,y                  Get variable type again
RPAR15               ldb       #6                  Get size of var packet
                    leau      <L3B5B,pc           Point to var size table
                    subb      a,u                 Calculate ptr to beginning of actual var value
                    leau      b,y                 Bump U to point to first byte of actual var value
                    stu       <u0046              ??? Save some sort of variable ptr?
                    bra       RPAR30

* String being passed?
RPAR20               ldu       1,y                 Get ptr to actual string data
                    ldd       <u0048
                    subd      <u004A              Subtract ptr to next free byte in workspace
                    std       <u003E              Save result as ptr to string/complex
                    ldd       <u0048
                    std       <u004A              Save new ptr to next free byte in workspace
                    lda       #4                  Variable type=String/complex
                    bra       RPAR30

RPAR25               leax      1,x
                    jsr       <u0016
RPAR30               puls      y                   Get ptr to flag byte
                    inc       ,y                  Bump up flag
                    cmpa      #4                  Variable type numeric?
                    blo       L3BB3               Yes, skip ahead
                    pshs      u                   String/complex, save var data ptr
                    ldu       <u003E              Get some ptr
L3BB3               pshs      u,a                 Save variable ptr, variable type
                    ldb       ,x+
                    cmpb      #$4B
                    beq       L3B6C
                    leax      1,x           Get scratch for time
                    stx       1,y
                    leax      <L3B5B,pc           Point to 4 entry, 1 byte table
                    ldu       <u0046        Get string stack ptr
                    stu       <u0040              Save ptr to end of parm packets
L3BC6               puls      b                   Get variable type
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
                    bne       L3BC6               ??? Yes, continue building parm area
                    leay      ,u                  ??? No, point Y to parm area
                    bra       L3BE7

RPAR50               ldy       <u0046
                    sty       <u0040
L3BE7               tfr       y,d
                    subd      <u004A
                    lblo      MEMFUL
                    std       <u000C
                    puls      pc,u,x,a

L3BF3               jsr       <u0016
                    ldy       1,y
                    pshs      x
                    bsr       L3215
                    puls      pc,x

L3215               jsr       <u001B
                    fcb       $0a

L3BFF               bsr       L322D
                    leax      >L323F,pc           Point to huge jump table
                    stx       <u000E              Save as address somewhere
                    rts

L322D               jsr       <u0027              Use module header jump vector #5
                    fcb       $00                 Function code

L3C09               pshs      x,d                 Preserve regs
                    ldb       [<4,s]              Get function code
                    leax      <L3C19,pc           Point to function code jump table
                    ldd       b,x                 Get offset
                    leax      d,x                 Point X to subroutine
                    stx       4,s                 Save overtop original PC
                    puls      pc,x,d              Restore regs & jump to function code routine

L3C19               fdb       L5050-L3C19         0
                    fdb       L3D80-L3C19         2 Copy DIM'd arrary to temp var pool
                    fdb       L3FB1-L3C19         4 Real # add
                    fdb       L40D3-L3C19         6 Real # multiply
                    fdb       L4234-L3C19         8 Real # divide
                    fdb       RLCMP-L3C19         A Set flags for Real comparison
                    fdb       FIX-L3C19         C FIX (Round & convert REAL to INTEGER)
                    fdb       FLOAT-L3C19         E FLOAT (Convert INTEGER/BYTE to REAL)

* Function routines
* Negative offsets from base of table @ L3CB5
                    fdb       MIDFNC-L3CB5         MID$
                    fdb       L4EE2-L3CB5         LEFT$
                    fdb       RGTFNC-L3CB5         RIGHT$
                    fdb       CHRFNC-L3CB5         CHR$
                    fdb       STRFNI-L3CB5         STR$ (for INTEGER)
                    fdb       L4FA8-L3CB5         STR$ (for REAL)
                    fdb       DATFNC-L3CB5         DATE$
                    fdb       TABFNC-L3CB5         TAB
                    fdb       FIX-L3CB5         FIX (round & convert REAL to INTEGER)
                    fdb       FIXNEX-L3CB5         ??? (calls fix but eats 1 var 1st)
                    fdb       L45A7-L3CB5         ??? (calls fix but eats 2 vars 1st)
                    fdb       FLOAT-L3CB5         FLOAT (convert INTEGER to REAL)
                    fdb       FLTNEX-L3CB5         ??? (calls float though)
                    fdb       BLNOT-L3CB5         Byte - LNOT
                    fdb       NEGINT-L3CB5         Integer - Negate a number
                    fdb       NEGRL-L3CB5         Real - Negate a number
                    fdb       BLAND-L3CB5         Byte - LAND
                    fdb       BLXOR-L3CB5         Byte - LOR
                    fdb       L438C-L3CB5         Byte - LXOR
                    fdb       L43FF-L3CB5         > : Integer/Byte relational
                    fdb       L4443-L3CB5         > : Real relational
                    fdb       L43D1-L3CB5         > : String relational
                    fdb       INCMLT-L3CB5         < : Integer/Byte relational
                    fdb       RLCMLT-L3CB5         < : Real relational
                    fdb       STCMLE-L3CB5         < : String relational
                    fdb       INCMEQ-L3CB5         <> or >< : Integer/Byte relational
                    fdb       RLCMEQ-L3CB5         <> or >< : Real relational
                    fdb       L43C5-L3CB5         <> or >< : String relational
                    fdb       L441D-L3CB5         <> or >< : Boolean relational
                    fdb       INCMGE-L3CB5         = : Integer/Byte relational
                    fdb       RLCMGE-L3CB5         = : Real relational
                    fdb       STCMNE-L3CB5         = : String relational
                    fdb       BLCMEQ-L3CB5         = : Boolean relational
                    fdb       INCMGT-L3CB5         >= or => : Integer/Byte relational
                    fdb       RLCMGT-L3CB5         >= or => : Real relational
                    fdb       STCMGT-L3CB5         >= or => : String Relational
                    fdb       INCMNE-L3CB5         <= or =< : Integer/Byte relational
                    fdb       RLCMNE-L3CB5         <= or =< : Real relational
                    fdb       STCMEQ-L3CB5         <= or =< : String Relational
                    fdb       L3EAF-L3CB5         Integer - Add
                    fdb       L3FB1-L3CB5         Real - Add
                    fdb       L44E5-L3CB5         String add
                    fdb       INSUB-L3CB5         Integer - Subtract
                    fdb       L3FAB-L3CB5         Real - Subtract
                    fdb       INMUL-L3CB5         Integer - Multiply
                    fdb       L40CC-L3CB5         Real Multiply
                    fdb       INDIV-L3CB5         Integer - Divide
                    fdb       L422D-L3CB5         Real Divide
                    fdb       RLEXP-L3CB5         Real Exponent\ Probably for both ^ & **
                    fdb       RLEXP-L3CB5         Real Exponent/ Hard coding for 0^x & x^1
                    fdb       VARADD-L3CB5         DIM
                    fdb       VARADD-L3CB5         DIM
                    fdb       VARADD-L3CB5         DIM
                    fdb       VARADD-L3CB5         DIM
                    fdb       FLDREF-L3CB5         PARAM
                    fdb       FLDREF-L3CB5         PARAM
                    fdb       FLDREF-L3CB5         PARAM
                    fdb       FLDREF-L3CB5         PARAM
                    fdb       $0000               Unused function entries (maybe use for LONGINT?)
                    fdb       $0000
                    fdb       $0000
                    fdb       $0000
                    fdb       $0000
                    fdb       $0000

* Jump table (base is L3CB5)
L3CB5               fdb       SVBYTE-L3CB5         Copy BYTE var to temp pool
                    fdb       SVINT-L3CB5         Copy INTEGER var to temp pool
                    fdb       L3F8D-L3CB5         Copy REAL var to temp pool
                    fdb       L436E-L3CB5         Copy BOOLEAN var to temp pool
                    fdb       SVSTR-L3CB5         Copy STRING var to temp pool (max 256 chars)
                    fdb       GETVAR-L3CB5         Copy DIM array
                    fdb       GETVAR-L3CB5         Copy DIM array
                    fdb       GETVAR-L3CB5         Copy DIM array
                    fdb       GETVAR-L3CB5         Copy DIM array
                    fdb       GETFLD-L3CB5         Copy PARAM array
                    fdb       GETFLD-L3CB5         Copy PARAM array
                    fdb       GETFLD-L3CB5         Copy PARAM array
                    fdb       GETFLD-L3CB5         Copy PARAM array
                    fdb       BYTLIT-L3CB5         Copy BYTE constant to temp pool - CHECK IF USED
                    fdb       INTLIT-L3CB5         Copy INTEGER constant to temp pool
                    fdb       L3F7C-L3CB5         Copy REAL constant to temp pool
                    fdb       STRLIT-L3CB5         Copy STRING constant to temp pool
                    fdb       INTLIT-L3CB5         Copy INTEGER constant to temp pool
                    fdb       ADRFNC-L3CB5         ADDR
                    fdb       ADRFNC-L3CB5         ADDR
                    fdb       L4751-L3CB5         SIZE
                    fdb       L4751-L3CB5         SIZE
                    fdb       POSFNC-L3CB5         POS
                    fdb       L45E3-L3CB5         ERR
                    fdb       INDV10-L3CB5         MOD for Integer #'s
                    fdb       MODFNR-L3CB5         MOD for Real #'s
                    fdb       RNDFNC-L3CB5         RND
                    fdb       L4B03-L3CB5         PI
                    fdb       SUBFNC-L3CB5         SUBSTR
                    fdb       SGNFNI-L3CB5         SGN for Integer
                    fdb       SGNFNR-L3CB5         SGN for Real
                    fdb       SINFNC-L3CB5         Transcendental ???
                    fdb       COSFNC-L3CB5         Transcendental ???
                    fdb       TANFNC-L3CB5         Transcendental ???
                    fdb       ASNFNC-L3CB5         Transcendental ???
                    fdb       ACSFNC-L3CB5         Transcendental ???
                    fdb       ATNFNC-L3CB5         Transcendental ???
                    fdb       EXPFNC-L3CB5         EXP
                    fdb       L45B5-L3CB5         ABS for Integer #'s
                    fdb       ABSFNR-L3CB5         ABS for Real #'s
                    fdb       L47AB-L3CB5         LOG
                    fdb       L479F-L3CB5         LOG10
                    fdb       SQRR05-L3CB5         SQR \ Square root
                    fdb       SQRR05-L3CB5         SQRT/
                    fdb       FLOAT-L3CB5         FLOAT
                    fdb       INTFNR-L3CB5         INT (of real #)
                    fdb       RETBYT99-L3CB5         ??? RTS
                    fdb       FIX-L3CB5         FIX
                    fdb       FLOAT-L3CB5         FLOAT
                    fdb       RETBYT99-L3CB5         ??? RTS
                    fdb       SQFNCI-L3CB5         SQuare of integer
                    fdb       L470E-L3CB5         SQuare of real
                    fdb       PEKFNC-L3CB5         PEEK
                    fdb       NOTFNC-L3CB5         LNOT of Integer
                    fdb       L471F-L3CB5         VAL
                    fdb       L4EAB-L3CB5         LEN
                    fdb       ASCFNC-L3CB5         ASC
                    fdb       ANDFNC-L3CB5         LAND of Integer
                    fdb       L478F-L3CB5         LOR of Integer
                    fdb       ORFNC-L3CB5         LXOR of Integer
                    fdb       L4769-L3CB5         Force Boolean to TRUE
                    fdb       L476E-L3CB5         Force Boolean to FALSE
                    fdb       EOFFNC-L3CB5         EOF
                    fdb       TRMFNC-L3CB5         TRIM$

* Jump table, base is L3D35
L3D35               fdb       BYTVAR-L3D35         Convert Byte to Int (into temp var)
                    fdb       SQRR20-L3D35         Copy Int var into temp var
                    fdb       L3F93-L3D35         Copy Real var into temp var
                    fdb       RETBYT10-L3D35         ??? Copy Boolean into temp var
                    fdb       STRVAR-L3D35         ??? Copy string to expression stack
                    fdb       RCDVAR-L3D35         ??? Copy D&U regs into temp var type 5

EVAL               ldy       <u0046
                    ldd       <u004A        Init string stack ptr
                    std       <u0048
                    bra       EVAL20

L3D4A               lslb                          2 bytes per entry
                    ldu       <u0010              Get ptr to jump table (could be L3CB5)
                    ldd       b,u                 Get offset
                    jsr       d,u                 Call subroutine
EVAL20               ldb       ,x+                 Get next byte
                    bmi       L3D4A               If high bit set, need to call another subroutine
                    clra                          Otherwise, clear carry
                    lda       ,y            Get tos TYPE
                    rts

* Copy DIM array to temp var pool
GETVAR               bsr       L3D80

* POSSIBLE MAIN ENTRY POINT FOR MATH & STRING ROUTINES
L3D5B               pshs      pc,u                Save U & PC on stack
                    ldu       <u0012              Get ptr to jump table (L3D35)
                    lsla                          A=A*2 for 2 byte entries (note: 8 bit SIGNED)
                    ldd       a,u                 Get offset
                    leau      d,u                 Point to routine
                    stu       2,s                 Save over PC on stack
                    puls      pc,u                Restore U & jump to routine

* Copy PARAM array to temp var pool
GETFLD               bsr       L3D78
                    bra       L3D5B

VARADD               leas      2,s
                    lda       #$F2          Set TOKEN for variable
                    bra       L3D82

FLDREF               leas      $02,s
                    lda       #$F6
                    bra       FLDR01

L3D78               lda       #$89
FLDR01               sta       <u00A3
                    clr       <u003B        Set flag for field addr
                    bra       VARR02         Call varref

L3D80               lda       #$85
L3D82               sta       <u00A3
                    sta       <u003B
VARR02               ldd       ,x++
                    addd      <u0062        Add base to offset
                    std       <u00D2        Set symbol table ptr
                    ldu       <u00D2        Get symbol table ptr
                    lda       ,u            Get TYPE byte
                    anda      #$E0          Get definition
                    sta       <u00CF        Set definition
                    eora      #$80          Get flag (0=param; non 0=var)
                    sta       <u00CE        Set flag
                    lda       ,u            Get TYPE byte
                    anda      #$07          Get TYPE
                    ldb       -$03,x        Get TOKEN
                    subb      <u00A3        Less base gives subscript count
                    pshs      d             Save TYPE & subscript count
                    lda       ,u            Get TYPE byte
                    anda      #$18          Get SHAPE
                    lbeq      L3E3F         bra if simple
                    ldd       1,u           Get array description offset
                    addd      <u0066        Add base to offset
                    tfr       d,u
                    ldd       ,u
* (orig: SQRR10)
                    std       <u003C        Save it
                    lda       1,s           Get subscript count
                    bne       VARR03         bra if count > 0
                    lda       #$05
                    sta       ,s            return TYPE
                    ldd       2,u           Get array total size
                    std       <u003E        Save it
                    clra
                    clrb                    zero indexing offset
                    bra       VARR11

VARR03               leay      -6,y                Make room for temp var
                    clra                          Force value to 0 (integer)
                    clrb                    partial result
                    std       1,y                 Save it
                    leau      4,u                 Bump U up
                    bra       L3DD5

VARR04               ldd       ,u                  Get value from U
                    std       1,y                 Save in var space
                    lbsr      INMUL               Call Integer Multiply routine
L3DD5               ldd       7,y
                    subd      <u0042        Get subscript-base
                    cmpd      ,u++          in range?
                    blo       VARR5A
                    ldb       #$37                Subscript out of range error
                    jsr       <u0024              Report it
                    fcb       $06

* Array subscript in range, process
VARR5A               addd      1,y
                    std       7,y           Move result to next-on-stack
                    dec       1,s           Count subscript
                    bne       VARR04         bra if more
* NOTE: IF FOLLOWING COMMENTS ARE ACCURATE, SHOULD USE LDA, DECA TRICK
* (orig: VARR14)
                    lda       ,s                  ??? Get variable type?
                    beq       L3DFF               If Byte, skip ahead
                    cmpa      #$02                Real?
                    blo       L3E03               No, integer, skip ahead
                    beq       VARR09               Real, skip ahead
                    cmpa      #$04                String?
                    blo       L3DFF               No, boolean - treat same as Byte
                    ldd       ,u                  String - do this
                    std       <u003E
                    bra       VARR10

* BYTE or BOOLEAN
L3DFF               ldd       7,y                 Get offset to entry in array we want
                    bra       L3E07

* INTEGER
L3E03               ldd       7,y                 Get offset to entry in array we want
                    lslb                          x2 since Integers are 2 bytes/entry
                    rola
L3E07               leay      $C,y
                    bra       VARR11

* REAL
VARR09               ldd       #5                  x5 since Real's are 5 bytes/entry
VARR10               std       1,y                 Save for Integer multiply routine
                    lbsr      INMUL               Go do Integer multiply
                    ldd       1,y                 Get offset to entry we want
                    leay      6,y                 Eat temp var.
VARR11               tst       <u00CE
                    bne       VARR13         ..No
                    pshs      d             Save element offset
                    ldd       <u003C        Get parameter packet offset
                    addd      <u0031        Add base to offset
                    cmpd      <u0040        is it there?
                    bhs       CMPTRU
                    tfr       d,u           Copy parameter packet ptr
                    puls      d             Retrieve element offset
                    cmpd      2,u           Still in parameter bounds?
                    bhi       CMPTRU         ..No
* (orig: VARR12)
                    addd      ,u            Add array base ptr to element offset
                    bra       VARR17

VARR13               addd      <u003C
                    tst       <u003B        field ref?
                    bne       VARR16         ..No
L3E39               addd      1,y
                    leay      6,y                 Eat temp var.
                    bra       VARR17

L3E3F               lda       ,s                  ??? Get var type
                    cmpa      #$04                Set CC - Is it string type?
                    ldd       1,u           Get symbol table entry
                    blo       VARR15               No, either numeric or boolean, skip ahead
* String or complex
                    addd      <u0066        Add base to offset
                    tfr       d,u
                    ldd       2,u           Get record size
                    std       <u003E        Save it
                    ldd       ,u            Get record offset
VARR15               tst       <u003B
                    beq       L3E39         bra if so
                    addd      <u0031        Add storage base to offset
                    tfr       d,u           Copy storage ptr
                    tst       <u00CE        parameter?
                    bne       VARR18         ..No
                    cmpd      <u0040        Will it be longer than original?
                    bhs       CMPTRU         If so old str will do
                    ldd       <u003E        return addend
                    cmpd      2,u
                    blo       VAR15A
                    ldd       2,u
                    std       <u003E
VAR15A               ldu       ,u
                    bra       VARR18

VARR16               addd      <u0031
VARR17               tfr       d,u
VARR18               clra                    Carry
                    puls      pc,d

CMPTRU               ldb       #$38                Parameter error
                    jsr       <u0024
                    fcb       $06

* Copy Byte constant to temp pool
BYTLIT               leau      ,x+
                    bra       BYTVAR

* Copy Byte variable to temp pool
SVBYTE               ldd       ,x++                Get offset to variable we want
                    addd      <u0031              Add to start of string pool address
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
                    addd      <u0031              Add to start of variable pool
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
L3EAF               ldd       7,y                 Get integer
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
                    beq       L3EFA               *0, leave result as 0
                    cmpd      #2                  Special case: times 2?
                    bne       L3ECF               No, check other number
                    ldd       1,y                 Get 2nd number
                    bra       L3EDB               Do quick x2

L3ECF               ldd       1,y                 Get 2nd number
                    beq       INML20               *0, go save result as 0
                    cmpd      #2                  Special case: times 2?
                    bne       INML25               No, go do regular multiply
                    ldd       7,y                 Get 1st number
L3EDB               lslb
                    rola
INML20               std       7,y                 Save answer
                    bra       L3EFA               Eat temp var & return

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
L3EFA               leay      6,y                 Eat temp var & return
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
                    jsr       <u0024              Report error
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
                    bpl       L3F0B               If positive or 0, go check other #
                    nega                          Force it to positive (NEGD)
                    negb
                    sbca      #$00
                    std       7,y                 Save positive version
                    com       ,y                  Set flag for negative result
L3F0B               ldd       1,y                 Get other #
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
                    bne       L3F2E               Normal divide, skip ahead
                    ldd       7,y                 Get # to divide by 2
                    beq       INDV20               If 0, result is 0, so skip divide
                    asra                    by shift
                    rorb
                    std       7,y                 Save result
* (orig: INDV15)
                    ldd       #$0000              Remainder=0 (No CLRD since it fries carry)
                    rolb                          Rotate possible remainder bit into D
                    bra       INDV55               Go save remainder, fix sign & return

L3F2E               ldd       1,y                 Get divisor (integer)
                    bne       L3F37               <>0, skip ahead
                    ldb       #$2D                =0, Divide by 0 error
                    jsr       <u0024              Report error
                    fcb       $06

L3F37               ldd       7,y                 Get dividend (integer)
                    bne       INDV25               Have to do divide, skip ahead
INDV20               leay      6,y                 ??? Eat temp var? (divisor)
                    std       3,y                 Save result
                    rts

* INTEGER DIVIDE MAIN ROUTINE
* 7-8,y = Dividend (already checked for 0)
* 1-2,y = Divisor (already checked for 0)
* 3,y   = # of powers of 2 shifts to do
INDV25               tsta                          Dividend>256?
                    bne       L3F4B               Yes, skip ahead
                    exg       a,b                 Swap LSB/MSB of dividend
                    std       7,y                 Save it
* (orig: INDV30)
                    ldb       #8                  # of powers of 2 shifts for 8 bit dividend
                    bra       INDV35

L3F4B               ldb       #16                 # of powers of 2 shifts for 16 bit dividend
INDV35               stb       3,y                 Save # shifts required
                    clra
                    clrb                    D
* Main powers of 2 subtract loop for divide
L3F51               lsl       8,y                 Multiply dividend by 2
                    rol       7,y           Into D
                    rolb                          Rotate into D
                    rola
                    subd      1,y                 Subtract that power of 2 from divisor
                    bmi       INDV45               If wraps, add it back in
                    inc       8,y           Set bit in quotient
                    bra       INDV50

INDV45               addd      1,y
INDV50               dec       3,y                 Dec # shift/subtracts left to do
                    bne       L3F51               Still more, continue
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
L3F7C               leay      -6,y                Make room for temp var
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
L3F8D               ldd       ,x++                Get offset into var space for REAL var
                    addd      <u0031              ??? Add to base address for variable storage?
                    tfr       d,u                 Move ptr to U
* Copy REAL # constant from within BASIC09 (pointed to by U) into temp var
L3F93               leay      -6,y                Make room for temp var
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
L3FAB               eim       #1,5,y              Negate sign bit of real #
                    else
L3FAB               ldb       5,y                 Reverse sign bit on REAL #
                    eorb      #1            Get difference with multiplier
                    stb       5,y
                    endc

                    ifne      H6309
                    use       basic09.real.add.63.asm
                    else
                    use       basic09.real.add.68.asm
                    endc

* REAL Multiply?
L40CC               bsr       L40D3               Go do REAL multiply
                    bcs       L3C2C               If error, report it
                    rts                           Return without error

L3C2C               jsr       <u0024              Report error
                    fcb       $06

                    ifne      H6309
                    use       basic09.real.mul.63.asm
                    else
                    use       basic09.real.mul.68.asm
                    endc

* Real divide entry point?
L422D               bsr       L4234
                    bcs       LErr
L4233               rts

LErr                jsr       <u0024
                    fcb       $06

                    ifne      H6309
                    use       basic09.real.div.63.asm
                    else
                    use       basic09.real.div.68.asm
                    endc

* Real exponent
RLEXP               pshs      x                   Preserve X
                    ldd       7,y                 Is the number to be raised 0?
                    beq       L4331               Yes, eat temp & return with 0 as result
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
                    lbsr      L47AB         Get log(x)
                    lbsr      L40CC               Go do real multiply
                    lbra      EXPFNC         Get exp(log(x)*y)

* Copy Boolean value into temp var
L436E               ldd       ,x++                Get offset to var from beginning of var pool
                    addd      <u0031              Add to base address for vars
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

L438C               ldb       8,y                 Single byte LXOR
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
                    sty       <u0048        Update str stack ptr
STRCM1               lda       ,y+                 Get char from temp string
                    cmpa      ,x+                 Same as char from var string?
                    bne       L43AC               No, skip ahead
                    cmpa      #$FF                EOS marker?
                    bne       STRCM1               No, keep comparing
L43AC               inca                          Inc last char checked
                    inc       -1,x                Inc last char in compare string
                    cmpa      -1,x                Same as last char checked with inc????
                    puls      pc,y,x        return CC=result

* String compare: < (?)
***************
* String Compare =<
STCMLE               bsr       STRCMP               Go do string compare
                    blo       L4405               If less than, result=TRUE
                    bra       L4409               Else, result=False

* String compare: <= or =< (?)
***************
* String Compare =
STCMEQ               bsr       STRCMP
                    bls       L4405
                    bra       L4409

* String compare: =
***************
* String Compare <>
STCMNE               bsr       STRCMP
                    beq       L4405
                    bra       L4409

* String compare: <> or ><
L43C5               bsr       STRCMP
                    bne       L4405
                    bra       L4409

* String compare: >= or => (?)
***************
* String Compare >
STCMGT               bsr       STRCMP
                    bhs       L4405
                    bra       L4409

* String compare: > (?)
L43D1               bsr       STRCMP
                    bhi       L4405
                    bra       L4409

* For Integer/Byte compares below: Works for signed Integer as well
*  as unsigned Byte
* Integer/Byte compare: <
INCMLT               ldd       7,y
                    subd      1,y                 NOTE: SUBD is faster than CMPD
                    blt       L4405         if less than go push true
                    bra       L4409         Go push false

* Integer/Byte compare: <= or =<
INCMNE               ldd       7,y
                    subd      1,y
                    ble       L4405         if less or equal go push true
                    bra       L4409         Go push false

* Integer/Byte compare: <> or ><
INCMEQ               ldd       7,y
                    subd      1,y           Take borrow
                    bne       L4405         if not equal go push true
                    bra       L4409         Go push false

* Integer/Byte compare: =
INCMGE               ldd       7,y
                    subd      1,y           Subtract divisor msdb
                    beq       L4405         bra if possibly done
                    bra       L4409         Go push false

* Integer/Byte compare: >= or =>
INCMGT               ldd       7,y
                    subd      1,y           Subtract right operand
                    bge       L4405         if greater or equal go push true
                    bra       L4409         Go push false

* Integer/Byte compare: >
L43FF               ldd       7,y                 Get original var
                    subd      1,y                 > than compare var?
                    ble       L4409               No, boolean result=FALSE
L4405               ldb       #$FF                Boolean result=TRUE
                    bra       L440B

L4409               clrb                          Boolean result=FALSE
L440B               clra                          Clear hi byte (since result is 1 byte boolean)
                    leay      6,y                 Eat temp var packet
                    std       1,y                 Save result in original var packet
                    lda       #3                  Save var type as Boolean
                    sta       ,y
                    rts

* BOOLEAN = compare
BLCMEQ               ldb       8,y                 Get original BOOLEAN value
                    cmpb      2,y                 Same as comparitive BOOLEAN value?
                    beq       L4405               Yes, result=TRUE
                    bra       L4409               No, result=FALSE

* BOOLEAN <> or >< compare
L441D               ldb       8,y                 Get original BOOLEAN value
                    cmpb      2,y                 Same as comparitive BOOLEAN value?
                    bne       L4405               No, result=TRUE
                    bra       L4409               Yes, result=FALSE

* Real < compare
RLCMLT               bsr       RLCMP               Go compute flags between real #'s
                    blt       L4405               If < then, result=TRUE
                    bra       L4409               Otherwise, result=FALSE

* Real <= or =< compare
RLCMNE               bsr       RLCMP
                    ble       L4405
                    bra       L4409

* Real <> or >< compare
RLCMEQ               bsr       RLCMP
                    bne       L4405
                    bra       L4409

* Real = compare
RLCMGE               bsr       RLCMP
                    beq       L4405
                    bra       L4409

* Real >= or => compare
RLCMGT               bsr       RLCMP
                    bge       L4405
                    bra       L4409

* Real > compare
L4443               bsr       RLCMP
                    bgt       L4405
                    bra       L4409

* Set flags for Real comparison
RLCMP               pshs      y                   Preserve Y
                    andcc     #$F0                Clear out Negative, Zero, Overflow & Carry bits
                    lda       8,y                 Is original REAL var=0?
                    bne       RLCM50               No, skip ahead
* (orig: RLCM40)
                    lda       2,y                 Is comparitive REAL var=0?
                    beq       RLCM30               Yes, they are equal so return
L4455               lda       5,y                 Get last byte of Mantissa with sign bit
RLCM15               anda      #$01                Ditch everything but sign bit
                    bne       RLCM30               Sign bit set, negative value, return
RLCM20               andcc     #$F0                Clear out Negative, Zero, Overflow & carry bits
                    orcc      #%00001000          Set Negative flag
RLCM30               puls      pc,y

RLCM50               lda       2,y                 Is comparitive REAL var=0?
                    bne       L446B               No, go deal with whole exponent/mantissa mess
                    lda       $B,y                Get sign bit of original var
                    eora      #$01                Invert sign flag
                    bra       RLCM15               Go set Negative bit appropriately

* No zero values in REAL compare-deal with exponent & mantissa
L446B               lda       $B,y                Get sign bit byte from original var
                    eora      5,y                 Calculate resulting sign from it with temp var
                    anda      #$01                Only keep sign bit
                    bne       L4455               One of the #'s is neg, other pos, go deal with it
                    leau      6,y                 Both same sign, point U to original var
                    lda       5,y                 Get sign byte from temp var
                    anda      #$01                Just keep sign bit
                    beq       L447D               If positive, skip ahead
                    exg       u,y                 If negative, swap ptrs to the 2 vars
* POSSIBLE 6309 MOD: DO LDA 1,U / CMPA 1,Y FOR EXPONENT, THEN LDQ / CMPD /
* CMPW FOR MANTISSA
L447D               ldd       1,u                 Get exponent & 1st mantissa bytes
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
                    stb       <u003E              Save it
STRCAT               ldu       <u0048              Get ptr to string of some sort
                    leay      -6,y                Make room for temp var
                    stu       1,y                 Save ptr to it
                    sty       <u0044              Save temp var ptr
MIDFN4               cmpu      <u0044              At end of string stack yet?
                    bhs       L44C2               Yes, exit with String stack overflow error
                    lda       ,x+                 Get char from string
                    sta       ,u+                 Save it
                    cmpa      #$FF                EOS?
                    beq       STLIT3               Yes, finished copying
                    decb                          Dec size left
                    bne       MIDFN4               Still room, keep copying
                    dec       <u003E              ???
                    bpl       MIDFN4               Still good, keep copying
                    lda       #$FF                Append string terminator
                    sta       ,u+           Put in string stack
STLIT3               stu       <u0048              Save end of string stack ptr
                    lda       #4                  Force var type to string
                    sta       ,y
                    rts

L44C2               ldb       #$2F                String stack overflow
                    jsr       <u0024
                    fcb       $06

SVSTR               ldd       ,x++
                    addd      <u0066
                    tfr       d,u           Make direct page ptr
L44CD               ldd       ,u
                    addd      <u0031        Add procedure storage addr
                    ldu       2,u           Get size
                    stu       <u003E
                    tfr       d,u
STRVAR               pshs      x
                    ldb       <u003F
                    bne       STRVAR10
                    dec       <u003E
STRVAR10               leax      ,u
                    bsr       STRCAT         push string
                    puls      pc,x

L44E5               ldu       1,y                 Get ptr to string contents
                    leay      6,y                 Eat temp var
STCAT2               lda       ,u+                 Get char from temp var
                    sta       -2,u                Save 1 byte back from original spot
                    cmpa      #$FF                EOS?
                    bne       STCAT2               No, keep copying until EOS is hit
                    leau      -1,u                Point U back to EOS
                    stu       <u0048              Save string stack ptr & return
                    rts

RCDVAR               ldd       <u003E
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
                    bpl       L451F               No, positive (big number), skip ahead
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
L451F               bne       L4526               Exponent <>0, skip ahead
                    ldu       #$0208              ??? If exponent=0, 522
                    exg       a,b           Msb to D
L4526               tsta                    Result normalized?
                    bmi       FLOAT5         bra if no
L4529               leau      -1,u                Drop down U counter
                    lslb                          LSLD
                    rola
                    bpl       L4529               Do until hi bit is set
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
                    bhi       L458C         bra if too large
                    bne       FIX2         bra if in range
                    ldd       2,y           get value
                    ror       5,y           check sign
                    bcc       FIX5         bra if positive
                    cmpd      #$8000        -32768?
                    bne       L458C         ..No
                    tst       4,y           would it round out?
                    bpl       FIX5         ..No
                    bra       L458C

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
L458C               ldb       #$34                Value out of Range for Destination error
                    jsr       <u0024
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

L45A7               leay      $C,y                Eat 2 temp vars
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
L45B5               ldd       1,y                 Get integer
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
                    bra       L45EA

L45E3               ldb       <u0036
                    clr       <u0036
L45E7               clra                    Byte Result
                    leay      -6,y                Make room for temp var
L45EA               std       1,y                 Save value
                    lda       #1                  Force type to integer & return
                    sta       ,y
RETBYT99               rts

POSFNC               ldb       <u007D
                    bra       L45E7

SQRR05               ldb       $05,y
                    asrb                    Sign to carry
                    lbcs      L4FC7
                    ldb       #$1F          Set cycle count
                    stb       <u006E
                    ldd       $01,y         Get exponent & msb
                    beq       RETBYT99         return zero
                    inca                    Exponent for even/odd test
                    asra
                    sta       $01,y         Save it
                    ldd       $02,y         Get msb
                    bcs       L4616         bra if boolean
                    lsra                    Mantissa for odd exponent
                    rorb
                    std       -$04,y
                    ldd       $04,y
                    rora                    Lsdb
                    rorb
                    bra       L461A

L4616               std       -$04,y
                    ldd       $04,y         Set x coordinate to 1
L461A               std       -$02,y
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
                    dec       <u006E
                    beq       L467A
                    bsr       L468F         Call double shifter
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
                    dec       <u006E
                    beq       L467A
                    bsr       L468F         Call double shifter
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

L467A               ldd       $02,y
                    bra       L4684         Do last shift

L467E               dec       $01,y
                    lbvs      L40DD
L4684               lsl       $05,y
                    rol       $04,y
                    rolb
                    rola
                    bpl       L467E         bra if another shift
                    std       $02,y
                    rts

L468F               bsr       L4691
L4691               lsl       -$01,y
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
                    lbsr      L422D         Get a/b
                    bsr       INTFNR         Get INT(a/b)
                    lbsr      L40CC         Get b*INT(a/b)
                    lbra      L3FAB         Get a-b*INT(a/b)

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
L46E1               leau      1,u
                    suba      #$08          Down count
                    bcc       L46E1         bra if more to left of binary point
                    beq       INTF50         bra if exact
                    ldb       #$FF          Make mask for byte
L46EB               lslb
                    inca
                    bne       L46EB
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

L470E               leay      -6,y
                    ldd       $A,y
                    std       4,y
                    ldd       8,y
                    std       2,y
* (orig: VALFNC)
                    ldd       6,y
                    std       ,y
                    lbra      L40CC         Go do multiply

L471F               ldd       <u0080
                    ldu       <u0082
                    pshs      u,d
                    ldd       1,y           Get ptr to string
* (orig: RADD90)
                    std       <u0080
                    std       <u0082
                    std       <u0048        Pop string off string stack
                    leay      6,y           Adjust opstack
                    ldb       #9            Set code for convert to real
                    lbsr      L011F         Call conversion
                    puls      u,d
                    std       <u0080        Restore them
                    stu       <u0082
                    lbcs      L4FC7         abort if error
                    rts

ADRFNC               lbsr      EVAL20
                    leay      -6,y                Make room for new variable packet
                    stu       1,y                 Save size of var
ADRF10               lda       #$01                ??? Integer type
                    sta       ,y                  ??? Save in variable packet
                    leax      1,x           Skip terminal TOKEN
                    rts

* Table to numeric variable type sizes in bytes? (duplicates earlier table @
*  L3B5B)
* Can either leave table here, change leau below to 8 bit pc (faster/1 byte
*   shorter), or eliminate table and point to 3B5B table (4 bytes shorter/same
*   speed)
L474D               fcb       $01                 Byte             (type=0)
                    fcb       $02                 Integer size     (type=1)
                    fcb       $05                 Real size        (type=2)
                    fcb       $01                 Boolean          (type=3)

L4751               lbsr      EVAL20
                    leay      -6,y                ??? Size of variable packets?
                    cmpa      #4                  String/complex variable?
                    bhs       TRUFNC               Yes, skip ahead
                    leau      <L474D,pc           Point to numeric type size table
                    ldb       a,u                 Get size of var in bytes
                    clra                          D=size  Msb
                    bra       L4765               Go save it

TRUFNC               ldd       <u003E              ??? Get integer value
L4765               std       1,y                 ??? Save integer value
                    bra       ADRF10

* BOOLEAN - TRUE
L4769               ldd       #$00FF              $FF in boolean is True flag
                    bra       FALFN2

L476E               ldd       #$0000              CLRD ($00 in boolean is False)
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
                    bra       L4795

ORFNC               ldd       1,y
                    eora      7,y                 EORD
                    eorb      8,y
                    bra       L4795         Save result + cleanup

L478F               ldd       1,y
                    ora       7,y                 ORD
                    orb       8,y
***************
* Save Result of Locical Function
L4795               std       7,y                 Save result after logic applied
                    leay      6,y                 Eat temporary variable packet?
                    rts

L479A               fcb       $ff,$de,$5b,$d8,$aa ??? (.434294482)

L479F               bsr       L47AB
                    leau      <L479A,pc           Point to ???
                    lbsr      L3F93         push on opstack
                    lbra      L40CC         Convert to base 10 log

L47AB               pshs      x
                    ldb       5,y           Get sign byte
                    asrb                    Sign
                    lbcs      L4FC7         bra if illegal
                    ldd       1,y           Ln(0)?
                    lbeq      L4FC7         bra if so
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
                    leax      >L4C7F,pc           Point to routine
                    stx       <$19,y
                    lbsr      L4909
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
                    lbra      L3FB1         Add product to cordic result

L4805               fcb       $00,$b1,$72,$17,$f8 (.693147181) LOG(2) in REAL format

CBLN2               sex                           Convert to 16 bit number
                    bpl       CBLN10               If positive, skip ahead
                    negb                          Invert sign on LSB
CBLN10               anda      #$01
                    pshs      d             Save sign, ABS(exponent)
CNOR20               leau      <L4805,pc           Point to Log(2) in REAL format
                    lbsr      L3F93         Move to stack
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
                    lbsr      L3FAB         Subtract adjustment from argument
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
EXPF45               leau      >L4805,pc           Point to LOG(2) in REAL format
                    lbsr      L3F93
                    lbsr      L3FB1         Add constant
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
                    bsr       L4909         Add (u) > (x)
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

L4909               lda       #$01
                    sta       <u009A
                    leax      >L4D6F,pc     Get entry address
                    stx       <u0095        Set it
                    leax      >$005F,x      Get end of table address
                    stx       <u0097
                    lbra      CORDIC

FPOVRF               leay      -6,y
                    lbpl      L40DD         return zero if too small
                    ldb       #$32                Floating Overflow error
                    jsr       <u0024
                    fcb       $06

ASNFNC               pshs      x
                    bsr       CSIGN
                    ldd       $01,y
                    lbeq      L4A91
                    cmpd      #$0180
                    bgt       ASNERR
                    bne       L4946
                    ldd       $03,y
                    bne       ASNERR
                    lda       $05,y
                    lbeq      RETPI2         return pi/2 if arg is one
ASNERR               lbra      L4FC7

L4946               lbsr      ARCSUB
                    leay      <-$14,y       Make room for cordic
                    leax      <$15,y        Get x-coord ptr
                    leau      ,y            Get stack location
                    lbsr      CMOVE         Move x-coord
                    lbsr      CDENOR         Denormalize it
                    leax      <$1B,y        Get y-coord ptr
                    lbra      L4A3E         Get arctangent

CSIGN               ldb       $05,y
                    andb      #$01          Get sign bit
                    stb       <u006D        Save it
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
                    lda       <u006D
                    bne       ACSF05
                    clrb
                    std       $01,y
                    puls      pc,u,x

ACSF05               leay      6,y                 Eat temp var
                    puls      u,x
                    lbra      L4B03

ACSF10               bsr       ARCSUB
                    leay      <-$14,y       Make room for cordic
                    leax      <$1B,y        Get x-coord ptr
                    leau      ,y
                    lbsr      CMOVE
                    lbsr      CDENOR
                    leax      <$15,y
                    lbra      L4A3E

ACSRET               lda       5,y
                    bita      #$01
                    beq       ACSF25
                    ldu       <u0031
                    tst       1,u
                    beq       L49BF
                    leau      <L49C6,pc           Point to 180 in FP format
* (orig: ACSF15)
                    lbsr      L3F93
                    bra       ACSF20

L49BF               lbsr      L4B03
ACSF20               lbra      L3FB1

* See if we can move label to RTS above @ CSIGN, or below @ end of ARCSUB
ACSF25               rts

L49C6               fcb       $08,$b4,$00,$00,$00 180

ARCSUB               lda       <u006D
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
                    lbsr      L40CC
                    lbsr      L3FAB
                    lbsr      SQRR05
                    puls      a
                    sta       <u006D
                    rts

ATNFNC               pshs      x
                    lbsr      CSIGN
                    ldb       $01,y
                    cmpb      #$18
                    blt       L4A17
RETPI2               leay      6,y
                    lbsr      L4B03
                    dec       1,y
                    bra       ATNF35

L4A17               leay      <-$1A,y
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
L4A3E               leau      $0A,y
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
                    ora       <u006D
                    sta       $05,y
                    ldu       <u0031
                    tst       1,u
                    beq       L4A91
                    leau      >L4AFE,pc
                    lbsr      L3F93
                    lbsr      L40CC
                    bra       L4A91

SINFNC               pshs      x
                    lbsr      L4B0A
                    leax      $0A,y
                    bsr       L4A97
* (orig: SINFN4)
                    lda       $05,y
SINFN2               eora      <u009C
SINFN3               sta       $05,y
L4A91               lda       #$02
                    sta       ,y
                    puls      pc,x

L4A97               leau      <$1B,y
                    lbsr      CMOVE
                    lbsr      CNORM
                    leay      <$14,y
                    leax      >L4D6A,pc           Point to a table of Real #'s
                    leau      1,y
                    lbsr      CMOVE
                    lbra      L40CC

COSFNC               pshs      x
                    bsr       L4B0A
                    leax      ,y
                    bsr       L4A97
                    lda       $05,y
                    eora      <u009B
                    bra       SINFN3

TANFNC               pshs      x
                    bsr       L4B0A
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
L4AE2               std       $01,y
                    lda       #$FF
                    std       $03,y
                    deca
                    bra       TANF20

TANF10               lbsr      L422D
                    lda       $05,y
TANF20               eora      <u009B
                    bra       SINFN2

L4AF4               fcb       $02,$c9,$0f,$da,$a2 PI (3.14159265)

L4AF9               fcb       $fb,$8e,$fa,$35,$12 -1.74532925 E-02  (Degrees)

L4AFE               fcb       $06,$e5,$2e,$e0,$d4 57.2957795 (radians)

L4B03               leau      <L4AF4,pc           Point to PI in FP format
                    lbra      L3F93

L4B0A               ldu       <u0031
                    tst       1,u
                    beq       TRIG05
                    leau      <L4AF9,pc
                    lbsr      L3F93               Copy 5 bytes from u to 1,y (0,y=2)
                    lbsr      L40CC
TRIG05               clr       <u009B
                    ldb       $05,y
                    andb      #$01
                    stb       <u009C
                    eorb      $05,y
                    stb       $05,y
                    bsr       L4B03
                    inc       $01,y
                    lbsr      RLCMP
                    blt       TRIG10
* (orig: TRIG20)
                    lbsr      MODFNR
                    bsr       L4B03
                    bra       L4B38

TRIG10               dec       $01,y
L4B38               lbsr      RLCMP
                    blt       TRIG30
                    inc       <u009B
                    lda       <u009C
                    eora      #$01
                    sta       <u009C
                    lbsr      L3FAB
                    bsr       L4B03
TRIG30               dec       $01,y
                    lbsr      RLCMP
                    ble       L4B64
                    lda       <u009B
                    eora      #$01
                    sta       <u009B
                    inc       $01,y
                    lda       $0B,y
                    ora       #$01
                    sta       $0B,y
                    lbsr      L3FB1
* (orig: TRIG40)
                    leay      -$06,y
L4B64               leay      <-$14,y
                    leax      >L4C33,pc
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
CIRCOR               leax      >L4D29,pc           Point to some real # table
                    stx       <u0095
                    leax      <L4D6A-L4D29,x      Point to further in table
                    stx       <u0097
                    clr       <u009A
CORDIC               ldb       #$25
                    stb       <u0099
                    clr       <u009D
CORD10               leau      <$1B,y
                    ldx       <u0095
                    cmpx      <u0097
                    bhs       CORD20
                    bsr       CMOVE
                    leax      5,x                 Point to next entry in 5-byte entry table
                    stx       <u0095              Save new ptr
                    bra       CORD30

CORD20               ldb       #$01
                    bsr       L4C1E
CORD30               leax      ,y
                    leau      5,y
                    bsr       CSR
                    tst       <u009A
                    bne       CORD40
                    leax      $0A,y
                    leau      $0F,y
                    bsr       CSR
CORD40               jsr       [<$19,y]
                    inc       <u009D
                    dec       <u0099
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
                    ldb       <u009D
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
                    ldb       <u009D
                    andb      #$07
                    beq       CSR5
                    cmpb      #$04
                    bcs       L4C1E
                    subb      #$08
                    lda       ,x
L4C0F               lsla
                    rol       4,u
                    rol       3,u
                    rol       2,u
                    rol       1,u
                    rol       ,u
                    incb
                    bne       L4C0F
                    rts

L4C1E               asr       ,u
                    ror       1,u
                    ror       2,u
                    ror       3,u
                    ror       4,u
                    decb
                    bne       L4C1E
CSR5               rts

CCIRY0               lda       $0A,y
                    eora      ,y
                    coma
                    bra       CTEST

L4C33               lda       <$14,y
CTEST               tsta
                    bpl       L4C4D
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

L4C4D               leax      ,y
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
                    stb       <u0099
CLN               leax      ,y
                    leau      5,y
                    bra       CADD

L4C7F               leax      ,y
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
                    bcc       L4CA0
* (orig: CADD10)
                    addd      #$0001
                    bcc       L4CA0
                    inc       ,x
L4CA0               addd      1,u
                    std       1,x
                    lda       ,x
                    adca      ,u
                    sta       ,x
                    rts

CSUB               ldd       3,x
                    subd      3,u
                    std       3,x
                    ldd       1,x
                    bcc       L4CBC
* (orig: CSUB10)
                    subd      #$0001
                    bcc       L4CBC
                    dec       ,x
L4CBC               subd      1,u
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
                    lbra      L4C1E

* Multiply 5 byte number @ ,u  by 2
* Entry: B=# times to multiply
L4CD3               lsl       4,u
                    rol       3,u
                    rol       2,u
                    rol       1,u
                    rol       ,u
                    decb
CDEN20               bne       L4CD3
                    rts

CNORM               lda       ,u                  Get sign of 5 byte #
                    bpl       L4CEE               If positive, skip ahead
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

L4CEE               ldd       #$2004
L4CF1               decb
                    lsl       4,u
                    rol       3,u
                    rol       2,u
                    rol       1,u
                    rol       ,u
                    bmi       L4D05
                    deca
                    bne       L4CF1
                    clrb
* (orig: FPMUL6)
                    std       ,u
                    rts

L4D05               lda       ,u
                    stb       ,u
                    ldb       1,u
                    sta       1,u
                    lda       2,u
                    stb       2,u
                    ldb       3,u
                    addd      #$0001
                    andb      #$FE
                    std       3,u
                    bcc       L4D28
                    inc       2,u
                    bne       L4D28
                    inc       1,u
                    bne       L4D28
                    ror       1,u
                    inc       ,u
L4D28               rts

* Data (all 5 byte entries for real #'s???)
L4D29               fcb       $0c,$90,$fd,$aa,$22 2319.85404
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

L4D6A               fcb       $00,$9b,$74,$ed,$a8 .607252935
L4D6F               fcb       $0b,$17,$21,$7f,$7e 0185.04681
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

L4DCE               fdb       $0E12,$14A2,$BB40,$E62D,$3619,$62E9

                    ifne      H6309
RNDFNC               clrd
                    else
RNDFNC               clra
                    clrb
                    endc
                    std       <u004C
                    std       <u004E
                    pshs      a                   ??? Save flag (0)
                    lda       2,y
                    beq       L4DFC
                    ldb       5,y                 ??? Get sign/exponent byte
                    bitb      #1                  ??? Negative number?
                    bne       RMOVE               ??? Yes, skip ahead
                    com       ,s                  ??? No, set flag
                    bra       L4DFC

RMOVE               addb      #$FE
                    addb      1,y
                    lda       4,y
                    std       <u0052
                    ldd       2,y
                    std       <u0050
L4DFC               lda       <u0053
                    ldb       <u0057
                    mul
                    std       <u004E
                    lda       <u0052
                    ldb       <u0057
                    mul
                    addd      <u004D
                    bcc       L4E0E
                    inc       <u004C
L4E0E               std       <u004D
                    lda       <u0053
                    ldb       <u0056
                    mul
                    addd      <u004D
                    bcc       L4E1B
                    inc       <u004C
L4E1B               std       <u004D
                    lda       <u0051
                    ldb       <u0057
                    mul
                    addd      <u004C
                    std       <u004C
                    lda       <u0052
                    ldb       <u0056
                    mul
                    addd      <u004C
                    std       <u004C
                    lda       <u0053
                    ldb       <u0055
                    mul
                    addd      <u004C
                    std       <u004C
                    lda       <u0050
                    ldb       <u0057
                    mul
                    addb      <u004C
                    stb       <u004C
                    lda       <u0051
                    ldb       <u0056
                    mul
                    addb      <u004C
                    stb       <u004C
                    lda       <u0052
                    ldb       <u0055
                    mul
                    addb      <u004C
                    stb       <u004C
* NOTE: ON 6809, CHANGE TO LDD <u0053
                    lda       <u0053
                    ldb       <u0054
                    mul
                    addb      <u004C
                    stb       <u004C
                    ldd       <u004E
                    addd      <u005A
                    std       <u0052
                    ldd       <u004C
* NOTE: 6309 ADCD <u0058
                    adcb      <u0059
                    adca      <u0058
                    std       <u0050
                    tst       ,s+
                    bne       RND2
                    ldd       <u0050
                    std       2,y
                    ldd       <u0052
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

RND2               ldd       <u0052
                    andb      #$FE                ??? Kill sign bit on real #?
                    std       ,--y
                    ldd       <u0050
                    std       ,--y
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       ,--y
                    bsr       RNDNOR
                    lbra      L40CC

L4EAB               ldd       <u0048
                    ldu       1,y
                    subd      1,y
                    subd      #1
                    stu       <u0048
L4EB6               std       1,y
                    lda       #1
                    sta       ,y
                    rts

ASCFNC               ldd       1,y
                    std       <u0048
                    ldb       [<$01,y]
                    clra
                    bra       L4EB6

CHRFNC               ldd       1,y
                    tsta
                    lbne      L4FC7
                    ldu       <u0048
                    stu       1,y
                    stb       ,u+
                    lbsr      ENDS00
                    sty       <u0044
                    cmpu      <u0044
                    lbhs      L44C2
                    rts

L4EE2               ldd       1,y
                    ble       L4EF4
                    addd      7,y
                    tfr       d,u
                    cmpd      <u0048
                    bcc       L4EF1
                    bsr       L4F70
L4EF1               leay      6,y
                    rts

L4EF4               leay      6,y
                    ldu       1,y
                    bra       L4F70

RGTFNC               ldd       1,y
                    ble       L4EF4
                    pshs      x
                    ldd       <u0048
                    subd      1,y
                    subd      #1
                    cmpd      7,y
                    bls       RGTFN2
                    tfr       d,x
                    ldu       7,y
L4F10               lda       ,x+
                    sta       ,u+
                    cmpa      #$FF
                    bne       L4F10
                    stu       <u0048
RGTFN2               leay      6,y
                    puls      pc,x

MIDFNC               ldd       $01,y
                    ble       VARR05
                    ldd       $07,y
                    bgt       MIDFN2
VARR05               ldd       $01,y
                    leay      $06,y
                    std       $01,y
                    bra       L4EE2

MIDFN2               subd      #$0001
                    beq       VARR05
                    addd      $0D,y
                    cmpd      <u0048
                    bcs       MIDFN3
                    leay      $06,y
                    bra       L4EF4

MIDFN3               pshs      x
                    tfr       d,x
                    ldb       $02,y
                    ldu       $0D,y
L4F46               lda       ,x+
                    sta       ,u+
                    cmpa      #$FF
                    beq       MIDFN5
                    decb
                    bne       L4F46
                    dec       1,y
                    bpl       L4F46
                    lda       #$FF
                    sta       ,u+
MIDFN5               stu       <u0048
                    leay      $0C,y
                    puls      pc,x

TRMFNC               ldu       <u0048
                    leau      -1,u
TRMFN2               cmpu      $01,y
                    beq       L4F70
                    lda       ,-u
                    cmpa      #$20
                    beq       TRMFN2
                    leau      1,u
L4F70               lda       #$FF
                    sta       ,u+
                    stu       <u0048
                    rts

SUBFNC               pshs      y,x
                    ldd       <u0048              ??? Get size of string
                    subd      1,y                 Subtract ptr to string to search in
                    addd      7,y                 Add to ptr to string to search for
                    addd      #1                  +1
                    ldx       7,y                 Get ptr to string to search for
                    ldy       1,y                 Get ptr to string to search in
***************
* String Compare =>
* (orig: STCMGE)
                    bsr       L3C29               Call Substr function (should change to direct LBSR
                    bcc       SUBF10               If sub-string match found, skip ahead
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    bra       SUBF20

L3C29               jsr       <u001B              Substr string search
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

L4FA8               ldb       #$03
STRF10               lda       <u007D
                    ldu       <u0082
                    pshs      u,x,a
                    lbsr      L011F
                    bcs       L4FC7
                    ldx       <u0082
                    lda       #$FF
                    sta       ,x
                    ldx       $03,s
                    lbsr      STRLIT
                    puls      u,x,a
                    sta       <u007D
                    stu       <u0082
                    rts

L4FC7               ldb       #$43                Illegal Arguement error
                    jsr       <u0024
                    fcb       $06

TABFNC               pshs      x
                    ldd       1,y
                    blt       L4FC7
                    sty       <u0044
                    ldu       <u0048
                    stu       $01,y
                    lda       #$20
TABF10               cmpb      <u007D
                    bls       ENDSTR
                    sta       ,u+
                    decb
                    cmpu      <u0044
                    blo       TABF10
                    lbra      L44C2

ENDS00               pshs      x
ENDSTR               lda       #$FF
                    sta       ,u+
                    stu       <u0048
                    lda       #$04
                    sta       ,y
                    puls      pc,x

* DATE$ routine
* Minor change to accommodate Y2K changes in year. RG
DATFNC               pshs      x
                    leay      -6,y
                    leax      -6,y
                    ldu       <u0048
                    stu       1,y
                    os9       F$Time              Get time packet
                    bcs       ENDSTR               Error, exit
*         bsr   L5021      Start converting
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
L5021               lda       ,x+                 Get byte from time packet
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
                    bcc       L5046               No, skip ahead
                    cmpb      #E$EOF              Was the error an EOF error?
                    bne       L5046               No, skip ahead
                    ldb       #$FF
                    bra       L5048

L5046               clrb
L5048               clra
                    std       1,y
                    lda       #$03
                    sta       ,y
                    rts

***************
* Subroutine INIT
*   Initialize interpreter
L5050               ldb       #$06                6 2-byte entries to copy
                    pshs      y,x,b               Preserve regs
                    tfr       dp,a                Move DP to MSB of D
                    ldb       #$50                Point to [dp]50 (always u0050 in Lvl II)
                    tfr       d,y                 Move to Y
                    leax      >L4DCE,pc           Point to table
INIT1               ldd       ,x++                Get 2 bytes
                    std       ,y++                Move into DP
                    dec       ,s                  Do all 6
                    bne       INIT1               Until done
                    leax      >L3CB5,pc           Point to jump table
                    stx       <u0010              Save ptr
                    leax      >L3D35,pc           Point to another jump table
                    stx       <u0012              Save ptr
                    lda       #$7E                Get opcode for JMP >xxxx
                    sta       <u0016              Save it
                    leax      >EVAL,pc           Point to routine
                    stx       <u0017              Save as destination for above JMP
                    leax      <L3C32,pc           Point to JSR <u001B / FCB $1A
                    stx       <u0019              Save it
                    puls      pc,y,x,b            Restore regs & return

L3C32               jsr       <u001B
                    fcb       $1a

* <u002A goes here
L5084               pshs      x,d                 Preserve regs
                    ldb       [<$04,s]            Get function code
                    leax      <L5094,pc           Point to table (only functions 0 & 2)
                    ldd       b,x                 Get offset
                    leax      d,x                 Point to routine
                    stx       4,s                 Save over PC on stack
                    puls      pc,x,d              Restore X&D & go to routine

L5094               fdb       ASCNUM-L5094         Function 0
                    fdb       L50A4-L5094         Function 2

L5098               jsr       <u0027
                    fcb       $0c
L509B               jsr       <u0027
                    fcb       $0e

* <u002A function 2
* Entry: B=Sub-function #
L50A4               pshs      pc,x,d              Make room for new PC, preserve X & Y
                    lslb                          2 bytes / entry
                    leax      <L50B2,pc           Point to jump offset table
L50AA               ldd       b,x                 Get offset
L50AC               leax      d,x                 Add to base of table
                    stx       4,s                 Save over PC on stack
                    puls      pc,x,d              Restore X&D & JMP to subroutine

* Sub-function jump table (L50B2 is the base)
L50B2               fdb       OUTLIN-L50B2         $045f  0
                    fdb       OUTINT-L50B2         $05c3  1
                    fdb       OUTINT-L50B2         $05c3  2
                    fdb       OUTRL-L50B2         $04b7  3
                    fdb       OUTBL-L50B2         $05b3  4
                    fdb       L565C-L50B2         $05aa  5
                    fdb       INPLIN-L50B2         $044a  6
                    fdb       INPBYT-L50B2         $0258  7
                    fdb       L531D-L50B2         $026b  8
                    fdb       INPRL-L50B2         $0235  9
                    fdb       INPBL-L50B2         $02a2  A
                    fdb       STRINP-L50B2         $027f  B
                    fdb       OUTCR-L50B2         $05f9  C
                    fdb       SKPZON-L50B2         $05e9  D
                    fdb       SEEK-L50B2         $0478  E
                    fdb       UNIMPL-L50B2         $0a11  F    Exit with Unimplemented routine err
                    fdb       OUTTAB-L50B2         $05da  10
                    fdb       NXTFMT-L50B2         $06ba  11
                    fdb       OUTCHR-L50B2         $0562  12
                    fdb       EXCFMT-L50B2         $0759  13
L50DA               fdb       OUTHEX-L50B2         $0602  14

* Table for Integer conversion
L50DC               fdb       10000
                    fdb       1000
                    fdb       100
                    fdb       10

* Table for REAL conversion
L50E4               fcb       $04,$a0,$00,$00,$00 10
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
L513E               fcb       $40,$8a,$c7,$23,$04 10 quintillion

L5143               fcc       'True'
                    fcb       $ff

L5148               fcc       'False'
                    fcb       $ff

* <u0024 function 2
***************
* Initialize
ASCNUM               pshs      u
                    leay      -6,y                Make room for temp var
                    clra
                    clrb
* 6809/6309 MOD: Change following 4 lines to STD <u0075, STD <u0077
                    sta       <u0075              ??? Zero out real # in DP?
                    sta       <u0076
                    sta       <u0077
                    sta       <u0078
                    sta       <u0079
                    std       4,y                 ??? Zero out temp real #
                    std       2,y
                    sta       1,y
                    lbsr      SKPDL1
                    bcc       ASCNM3         bra no delimiter
                    leax      -1,x          Back up to delimiter
* (orig: ASCNM1)
                    cmpa      #$2C          Comma delimiter?
                    bne       L51DE         Numeric format error if not
                    lbra      L51FB         Finish as integer if so

ASCNM3               cmpa      #$24
                    lbeq      INPHEX         Goto hex routine if so
                    cmpa      #$2B          Plus?
                    beq       ASCNM2
                    cmpa      #$2D
                    bne       L5184
                    inc       <u0078        Set mant sgn neg
***************
* Process Mantissa or Integer
ASCNM2               lda       ,x+
L5184               cmpa      #$2E
                    bne       ASCNM4
                    tst       <u0077        First one found?
                    bne       L51DE         Format error if not
                    inc       <u0077        Set dp flag
                    bra       ASCNM2

***************
* Process digit
ASCNM4               lbsr      CHKDIG
                    bcs       ASCNM7         bra if not
                    pshs      a             save digit val
                    inc       <u0076        Incr digit count
                    ldd       4,y           Get mant ls bytes
                    ldu       2,y
                    bsr       L51CB
                    std       4,y
                    stu       2,y           save t*2
                    bsr       L51CB         T*2*2
                    bsr       L51CB         T*2*2*2 = t*8
                    addd      4,y
                    exg       d,u
* 6309 mod: ADCD 2,y
                    adcb      3,y           T=t*8+t*2 = t*10
                    adca      2,y
                    bcs       L51D8
                    exg       d,u           Swap ms:ls
                    addb      ,s+           Add in new digit val
                    adca      #$00          T*10+d
                    bcc       ASCNM6
                    leau      1,u           Inc MS bytes
                    stu       2,y           Set cc zero bit
                    beq       NRERR         Bra if overfl
ASCNM6               std       4,y
                    stu       2,y           save TEMP MS bytes
                    tst       <u0077        in frac part?
                    beq       ASCNM2         Get another char if not
                    inc       <u0079        Bump exponent
                    bra       ASCNM2

L51CB               lslb
                    rola
                    exg       d,u
                    rolb
                    rola
                    exg       d,u
                    bcs       ROT32E         Error if overfl
                    rts

ROT32E               leas      2,s
L51D8               leas      1,s
***************
* Range Error
NRERR               ldb       #$3C                I/O conversion: Number out of range error
                    bra       NEXIT

L51DE               ldb       #$3B
NEXIT               stb       <u0036
                    coma
                    puls      pc,u

***************
* Process Non-digit char
ASCNM7               eora      #$45
                    anda      #$DF          (upper or lower case e?)
                    beq       L520E
                    leax      -1,x          Back up buffer ptr
* (orig: ASCN75)
                    tst       <u0076        Did we get digits?
                    bne       ASNIN1
                    bra       L51DE         Too bad

***************
* Final Processing for TYPE Integer
ASNIN1               tst       <u0077
                    bne       ASNRL1         Has to be TYPE real
                    ldd       2,y           Get mant hi bytes
                    bne       ASNRL1         if not 0 must be real
L51FB               ldd       4,y
                    bmi       ASNRL1         bra if out of integer range
                    tst       <u0078        Check sign flag
                    beq       ASNIN2         Bra if result positive
                    nega                          NEGD  Result
                    negb
                    sbca      #$00
ASNIN2               std       1,y
ASNIN3               lda       #$01
                    lbra      L5295

L520E               lda       ,x
                    cmpa      #$2B          Plus sign?
                    beq       ASNEX2
                    cmpa      #$2D
                    bne       ASNEX3
                    inc       <u0075        Set neg exp flag
ASNEX2               leax      1,x
ASNEX3               lbsr      L57DC
                    bcs       L51DE
                    tfr       a,b
                    lbsr      L57DC
                    bcc       ASNEX5
                    leax      -1,x
                    bra       ASNEX6

ASNEX5               pshs      a                   Save 1's digit
                    lda       #10                 Multiply by 10 (for 10's digit)
                    mul
                    addb      ,s+
ASNEX6               tst       <u0075
                    bne       L5238
                    negb                    exp
L5238               addb      <u0079
                    stb       <u0079        ..and save for later use
ASNRL1               ldb       #$20
                    stb       1,y
                    ldd       2,y           Get MS bytes exponent
                    bne       ASNRL3         Bra to norm if <>0
                    cmpd      4,y           Check ls bytes
                    bne       ASNRL3         Test MS bytes
                    clr       1,y           number is zero
                    bra       L5293

***************
* Normalize Mantissa
ASNRL3               tsta
                    bmi       ASNRL5         Bra when normalized
L5250               dec       1,y
                    lsl       5,y
                    rol       4,y
                    rolb
                    rola
                    bpl       L5250         Loop til normallized
ASNRL5               std       2,y
                    clr       <u0075        Clear exp sign flag
                    ldb       <u0079        Get dec exponent
                    beq       ASNRL8         if zero no adj needed
                    bpl       ASNRL6         exp must be pos ..
                    negb                    exp postive
                    inc       <u0075        Set neg exp flag
ASNRL6               cmpb      #$13
                    bls       ASNRL7         Bra if ok
                    subb      #$13          Reduce range otherwise
                    pshs      b             save current exp
                    leau      >L513E,pc     Get add of const 1e+19
                    bsr       CNVOPR         ..and reduce range ..
                    puls      b             Restore exp and proceed
                    lbcs      NRERR         ..exit if oper overflowed
ASNRL7               decb                    Bias from exp
                    lda       #5            Num bytes/entry in table
                    mul                     Tble entry addr
                    leau      >L50E4,pc     Get constant tbl addr
                    leau      b,u           Add in entry offset
                    bsr       CNVOPR         and reduce range (mult/div)
                    lbcs      NRERR         Range error ..
ASNRL8               lda       5,y
                    anda      #$FE
                    ora       <u0078        Put in sign bit
                    sta       5,y
L5293               lda       #2                  Real # type
L5295               sta       ,y                  Save it in var packet
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
                    lda       <u0075              Get sign of exponent?
                    lbeq      L4234               Real Divide
                    lbra      L40D3               Real Multiply

INPHEX               lbsr      L57DC
                    bcc       L52C7         Bra if good
                    cmpa      #$61
                    blo       L52BD         ..no; continue
                    suba      #$20          Shift to upper case
L52BD               cmpa      #$41
                    blo       INHEX5         Check for a-f
                    cmpa      #$46
                    bhi       INHEX5
                    suba      #$37          Make binary
L52C7               inc       <u0076
                    ldb       #4                  Loop counter for shift
L52CB               lsl       2,y
                    rol       1,y
                    lbcs      NRERR               If carried right out of byte, error
                    decb
                    bne       L52CB               Do all 4 shifts
                    adda      2,y           Add new digit
                    sta       2,y
                    bra       INPHEX

***************
* Clean Up
INHEX5               leax      -1,x
                    tst       <u0076        Any digits?
                    lbeq      L51DE         Error if not
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
                    ldx       <u0082              Get current pos in temp buffer
                    lbsr      ASCNUM         Call conv subr
                    bcc       INPRL2         Bra if no error
ITYPER               puls      pc,x

INPRL2               cmpa      #2                  Real #?
                    beq       L52F9               Yes, continue ahead
                    lbsr      L509B               ??? convert to real?
L52F9               lbsr      SKPDEL
                    bcs       INPRL4         Bra if delim found
                    ldb       #$3D                Illegal input format error
                    stb       <u0036              Save error code
                    coma                          Set carry
                    puls      pc,x                Restore X & return

INPRL4               stx       <u0082              Save new current pos in temp buffer
                    clra                          No error
                    puls      pc,x                Restore X & return

***************
* Subroutine INPBYT
* Look for and Convert Integer in 0-255 Range
* Parameters Identical to INPRL
INPBYT               pshs      x                   Preserve X
                    ldx       <u0082              Get current pos in temp buffer
                    lbsr      ASCNUM               ??? (returns A=var type)
                    bcs       ITYPER
                    cmpa      #1                  Integer?
                    bne       INPIN1         ERR if not
                    tst       1,y           Check msb
                    beq       L52F9         in range if zero
                    bra       INPIN1

L531D               pshs      x
                    ldx       <u0082              Get current pos in temp buffer
                    lbsr      ASCNUM
                    bcs       ITYPER
                    cmpa      #1                  Integer?
                    beq       L52F9               Yes, go back
INPIN1               ldb       #$3A                I/O Type mismatch error
* TO SAVE ROOM, SINCE ERRORS AREN'T CRUCIAL TO SPEED, MAY WANT THIS TO
* BRANCH TO SAME CODE @ L52F9
                    stb       <u0036
                    coma
                    puls      pc,x

STRINP               pshs      u,x
                    leay      -6,y                Make room for temp var
                    ldu       <u004A
                    stu       1,y                 ??? Save some string ptr
* (orig: INPST2)
                    lda       #4                  Type=String/complex
                    sta       ,y
                    ldx       <u0082        Get I/O buf ptr
INPST3               lda       ,x+
                    bsr       L5396         Call delim test
                    bcs       INPST4         Exit move loop if delim
                    sta       ,u+           Move char to str stack
                    bra       INPST3

INPST4               stx       <u0082
                    lda       #$FF                Flag end of string?
                    sta       ,u+           Store it
                    stu       <u0048        Update the ptr
                    clra
                    puls      pc,u,x

INPBL               pshs      x
                    leay      -6,y
                    lda       #3
                    sta       ,y            Set TYPE byte
                    clr       2,y           Set res to false
                    ldx       <u0082
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
                    stb       <u0036
                    coma
                    puls      pc,x

INPB25               com       2,y
INPBL3               bsr       SKPDEL
                    bcc       INPBL3         Skip until delimiter encountered
INPBL4               stx       <u0082
                    clra
                    puls      pc,x

SKPDEL               lda       ,x+
                    cmpa      #C$SPAC       is it a space
                    bne       L5396         Cont check if not
                    bsr       SKPDL1         Process more
                    bcc       SKPDL3         Back up if only spaces found
                    bra       SKPDL4

SKPDL1               lda       ,x+                 Get char
                    cmpa      #C$SPAC             Space?
                    beq       SKPDL1               Yes, ignore & get next char
L5396               cmpa      <u00DD              Char we are looking for?
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
                    sta       <u0076        Clr digit count
                    sta       <u0078        Clr sign flag
                    lda       #$04
                    sta       <u007E        Inz loop count
                    ldd       1,y           Get input num
                    bpl       INST2               If positive, skip ahead
                    nega                          NEGD
                    negb
                    sbca      #$00
                    inc       <u0078              Set flag?
***************
* Set Up for Conversion
INST2               leau      >L50DA,pc
***************
* Conversion Loop
INST3               clr       <u007A
                    leau      2,u           Move to new tble entry
INST4               subd      ,u
                    bcs       INST5         Bra if underflow
                    inc       <u007A        Else bump digit
                    bra       INST4         and loop again

INST5               addd      ,u
                    tst       <u007A        Current dig zero?
                    bne       INST6         if not 0 go output
                    tst       $03,y         All 0's so far?
                    beq       INST7         if so suppress this zero
***************
* Output the Current digit
INST6               inc       $03,y
                    pshs      a
                    lda       <u007A        Get the digit
                    lbsr      PUTDIG         Output it
                    puls      a
***************
* Bottom of Conv Loop
INST7               dec       <u007E
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
                    clr       <u0075              Replace with CLRA/CLRB/STD <u0075/STD <u0078/
                    clr       <u0078              STD <u007B (smaller & faster)
                    clr       <u007C
                    clr       <u007B
                    clr       <u0079
                    clr       <u0076
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
                    stb       <u0078        Set sign flag
                    andb      #$FE          Strip sign bit
                    stb       5,y           Replace
***************
* Process exponent Sign
NMASC1               ldd       1,y                 If this code is legit, why load D? just A?
                    bpl       NMASC2         Bra if exp positive
                    inc       <u0075        Set neg exp flag
                    nega                    Abs val exponent
NMASC2               cmpa      #3
                    bls       NMASC5         if so no scaling needed
                    ldb       #$9A                (154)
                    mul
                    lsra                    byte/2 is divide by 512
                    nop       WHY                 ARE THESE HERE?
                    nop
                    tfr       a,b           Copy decimal exp to b
                    tst       <u0075        Was exp pos?
                    beq       NMAS35         Bra if so
                    negb                    Compl
NMAS35               stb       <u0079
                    cmpa      #$13          in table range?
                    bls       L544A         Bra if in range
                    pshs      a             save exp
* (orig: NMASC4)
                    leau      >L513E,pc     Get addr of 10e+19
                    lbsr      CNVOPR         and mult/div to scale
                    puls      a             Restore exp
                    suba      #$13
L544A               leau      >L50E4,pc
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
                    ror       <u007C        Shift LS bits to extension
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
                    rol       <u007B        Shift MS bits into extension
                    dec       $01,y
                    bne       NMASC7         Loop til exp=0
                    std       $02,y         Replace msdb on stack
                    inc       <u0079        Dec exp (decimal)
                    lda       <u007B        Get ext byte
                    bsr       PUTDIG         MS decimal digit out
***************
* Convert Binary Fraction to Decimal by
* Repetitive Mult by 10.  Mult by Shift And
* Add.  Overflow Across Binary Point is the
* next Decimal Place Value.
NMASC8               ldd       $02,y
                    ldu       $04,y
NMASC9               clr       <u007B
                    bsr       L54F1         F*2
                    std       $02,y
                    stu       $04,y         T=f*2
                    pshs      a
                    lda       <u007B
                    sta       <u007C
                    puls      a
                    bsr       L54F1         F*4
                    bsr       L54F1         F*8
                    exg       d,u
                    addd      $04,y
                    exg       d,u
                    adcb      $03,y
                    adca      $02,y         F*2+f*8=f*10
                    pshs      a
                    lda       <u007B        Add carry to ext byte
                    adca      <u007C
                    bsr       PUTDIG         Output decimal digit
                    lda       <u0076
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
                    lda       <u0076
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
                    inc       <u0079        Adjust dec exp
NASC10               lda       #$09
NMAS11               sta       <u0076
                    leay      6,y           Clean up opstack
                    puls      pc,u,x        - we're finished.

***************
* Subroutine to Conv+ Output Decimal digit
PUTDIG               ora       #$30
                    sta       ,x+           Out in buffer
                    inc       <u0076        Incr digit count
                    rts

L54F1               exg       d,u
                    lslb
                    rola
                    exg       d,u
                    rolb
                    rola
                    rol       <u007B
                    rts

INPLIN               pshs      y,x
                    ldx       <u0080
                    stx       <u0082        Reset I/O ptr
                    lda       #$01
                    sta       <u007D
                    ldy       #$0100        Size of input buffer
                    lda       <u007F        Input path
                    os9       I$ReadLn
                    bra       OUTLN1         ..return error status

***************
* Subroutine OUTLIN
* Call OS-9 to Write I/O buffer to Console
OUTLIN               pshs      y,x
                    ldd       <u0082
                    subd      <u0080
                    beq       OUTLN2
                    tfr       d,y
                    ldx       <u0080
                    stx       <u0082        Reset ptr
* (orig: SEEK60)
                    lda       <u007F        Output path
                    os9       I$WritLn      Write line
OUTLN1               bcc       OUTLN2
                    stb       <u0036              Save error code
OUTLN2               puls      pc,y,x

SEEK               pshs      u,x
                    lda       ,y            Get position TYPE
                    cmpa      #$02          What type?
                    beq       SEEK10
                    ldu       $01,y
                    bra       SEEK20

SEEK10               lda       $01,y
                    bgt       L5542         bra if positive
                    ldu       #$0000        Seek zero
SEEK20               ldx       #$0000
                    bra       L555E

L5542               ldx       $02,y
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
L555E               lda       <u007F
                    os9       I$Seek
                    bcc       SEEK80
SEEK70               stb       <u0036              Save error code
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
TRLZ2               sta       <u0076
                    puls      x             Restore digits addr
                    ldb       <u0079        Get decimal exp
                    bgt       RFMTF2         if =>0 number has int part
                    negb                    exp positve
                    tfr       b,a
                    cmpb      #$09
                    bhi       RFMTE2         Cant format in this mode
                    addb      <u0076        Add # signif. digits
                    cmpb      #$09
                    bhi       RFMTE2         Still cant format
                    pshs      a             save exp
                    lbsr      L5643         Output sign
                    clra
                    bsr       L5612         Output dec. pt.
                    puls      b             Restore exp
                    tstb
                    beq       RFMTF1
                    lbsr      OUTZER         Output string of zeros
RFMTF1               lda       <u0076
                    bra       L55BF

***************
* Convert for Positive exp
RFMTF2               cmpb      #$09
                    bhi       RFMTE2         if not goto e format
                    lbsr      L5643         Output sign
                    tfr       b,a
***************
* Free Format real in "E" Format
* (orig: RLFMTE)
                    bsr       OUTZE1         Move frac digits
* (orig: RFMTF3)
                    bsr       L5612         Put out d.p
                    lda       <u0076
                    suba      <u0079        Calc # of frac digits
                    bls       RFMTF4         Done if no frac digits
L55BF               bsr       OUTZE1
***************
* Cleanup and Return
RFMTF4               leas      $0A,s
                    clra
                    puls      pc,u,x

RFMTE2               bsr       L5643
                    lda       #$01
                    bsr       OUTZE1
                    bsr       L5612
* (orig: OUTEXP)
                    lda       <u0076
                    deca                    for first digit
                    bne       L55D4
                    inca                    At least one zero ..
L55D4               bsr       OUTZE1
                    bsr       L55DA         Cnv+output exp part
                    bra       RFMTF4

L55DA               lda       #$45
                    bsr       OUTCHR         Output 'e'
                    lda       <u0079        Get exponent
                    deca                    for scaling
                    pshs      a             save exp val
                    bpl       L55EB
                    neg       ,s            Make it positive for output
* (orig: OUTEX2)
                    bsr       OUTMIN         Output minus sign
                    bra       OUTEX3

L55EB               bsr       L564B
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

L5612               lda       #$2E
***************
* Put char in (A) in Outbuf
OUTCHR               pshs      u,a                 Preserve regs
                    leau      <-$40,s             Is stack within 64 bytes of curr. pos in temp buff
                    cmpu      <u0082        output buffer overflow?
                    bhi       OUTCHR10               No, skip ahead
                    cmpa      #C$CR               Is char we want added a CR?
                    beq       OUTCHR10               Yes, skip ahead
                    lda       #$50                ??? Error code 80? (internal flag byte?)
                    sta       <u0036              ??? Save error code 80?
                    sta       <u00DE              Save here too
                    puls      pc,u,a              Restore regs & return

OUTCHR10               ldu       <u0082              Get current pos in temp buffer
                    sta       ,u+                 Save char there
                    stu       <u0082              Save new current pos in temp buffer
                    inc       <u007D              Inc # active chars in temp buffer
OUTCHR99               puls      pc,u,a              Restore regs & return

***************
* Output Series of Zeros Specified by B
OUTZER               lda       #$30
L5636               tstb                          Any chars left to do?
                    beq       OUTZ3               No, exit
OUTZ2               bsr       OUTCHR               Save char (check for size within 64 of stack?)
                    decb                          Done all chars?
                    bne       OUTZ2               No, keep adding chars
OUTZ3               rts

***************
* Output Sign or Space
SGNSPC               tst       <u0078
                    beq       OUTSP
L5643               tst       <u0078
                    beq       OUTZ3
***************
* Output Minus char
OUTMIN               lda       #$2D
                    bra       OUTCHR

L564B               lda       #$2B
                    bra       OUTCHR

MOVSTR               lda       #C$SPAC             Space is fill char
                    bra       L5636               Go add B # of spaces to temp buffer

MOVST0               bsr       OUTCHR
L5655               lda       ,x+
                    cmpa      #$FF          End str?
                    bne       MOVST0         ..No; print it
                    rts

L565C               pshs      x
                    ldx       1,y           Get str addr
OUTST2               bsr       L5655
                    clra
                    puls      pc,x

OUTBL               pshs      x
                    leax      >L5143,pc
                    lda       2,y
                    bne       OUTST2
                    leax      >L5148,pc     ..otherwise get addr of false
                    bra       OUTST2         and output..

OUTINT               pshs      u,x
                    leas      -5,s          Make TEMP buffer on stack
                    leax      ,s            Get addr of TEMP buffer
                    lbsr      INTSTR         Convert n to ASCII
                    bsr       L5643         Output sign if neg
                    lda       <u0076        Get digit count
                    leax      ,s            Restore TEMP buf ptr
                    lbsr      OUTZE1         Copy digits
                    leas      5,s           Clean stack
                    clra
                    puls      pc,u,x

* <u002A Function 2, sub-function $10 - Add B spaces to temp buffer
* Entry: A=# spaces to append to temp buffer
***************
* Subroutine OUTTAB
* Tab Output buffer to character
* Position Specified by (A)
OUTTAB               tfr       a,b                 Move byte we are working with to B
TAB               pshs      u                   Preserve U
                    ldu       <u0082              Get ptr to current pos in temp buffer
                    subb      <u007D              Callers # - # chars active in temp buffer
                    bls       TAB2               If 0 or wraps negative, skip ahead
                    bsr       MOVSTR               Go add chars
TAB2               clra                          No error?
                    puls      pc,u                Restore U & return

***************
* Subroutine SKPZON
* Skip to Beginning of next Tab Zone
SKPZON               lbsr      OUTSP
SKPZ2               lda       <u007D
                    anda      #$0F          Get 4 ls bits
                    cmpa      #$01          First digit of group?
                    beq       SKIPZ3         if so done ..
                    lbsr      OUTSP         if not output a space
                    bra       SKPZ2

***************
* Subroutine OUTCR
* Put Eol in I/O Buf
OUTCR               lda       #C$CR
                    clr       <u007D        Reset character count
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
OUTHX2               sta       <u0086
                    tfr       a,b
                    asrb                    digit count
                    lbsr      HEXOUT         Call conv subr
                    puls      pc,u

PRSJST               clrb
                    stb       <u0087        Left is default
                    cmpa      #$3C          Left?
                    beq       PRJST3
                    cmpa      #$3E          Right?
                    bne       L56D9
                    incb
                    bra       PRJST3

L56D9               cmpa      #$5E
                    bne       FDELIM
                    decb
PRJST3               stb       <u0087
                    lda       ,x+           Get next char
FDELIM               cmpa      #$2C
                    beq       FDEL40
                    cmpa      #$FF
                    bne       FDEL15
                    lda       <u0094        in a repeat block?
                    beq       FDEL10         bra if not
                    leax      -$01,x        Back up to end string
                    bra       FDEL30

FDEL10               ldx       <u008E
                    tst       <u00DC        Legal to RESCAN format?
                    beq       FDEL20         ..no; return error
                    clr       <u00DC        Set to no RESCAN legal
                    bra       FDEL40

FDEL15               cmpa      #$29
                    beq       FDEL25         bra if so
FDEL20               orcc      #$01
                    rts

FDEL25               lda       <u0094
                    beq       FDEL20         Error if not
FDEL30               dec       <u0092
                    bne       FDEL35         Bra if more to repeat
                    ldu       <u0046        Get repeat stack ptr
                    pulu      y,a           Get previous count & beginning ptr
                    sta       <u0092        Reset previous count
                    sty       <u0090        Reset repeat beginning
                    stu       <u0046        Update repeat stack ptr
                    lda       ,x+           Get next char
                    dec       <u0094        Decrement rpt flag
                    bra       FDELIM         Look for another delim

FDEL35               ldx       <u0090
FDEL40               stx       <u008C
                    andcc     #$FE
                    rts

* Print USING format specifiers
L5723               fcc       'I'                 Integer
                    fdb       L5802-L5723
L5726               fcc       'H'                 Hexidecimal
                    fdb       L5802-L5726
L5729               fcc       'R'                 Real
                    fdb       RFMTP-L5729
L572C               fcc       'E'                 Exponential
                    fdb       RFMTP-L572C
L572F               fcc       'S'                 String
                    fdb       L5802-L572F
L5732               fcc       'B'                 Boolean
                    fdb       L5802-L5732
L5735               fcc       'T'                 Tab
                    fdb       TFMTP-L5735
L5738               fcc       'X'                 Spaces
                    fdb       XFMTP-L5738
L573B               fcc       "'"                 Quoted text
                    fdb       QFMTP-L573B
L573E               fcb       $00                 End of table marker

* 'T' (tab)
***************
* Tab Format
TFMTP               bsr       FDELIM
                    bcs       RPTERR
                    ldb       <u0086
                    lbsr      TAB
                    bra       NXTFM1

* 'X' (spaces)
XFMTP               bsr       FDELIM
                    bcs       RPTERR
                    ldb       <u0086
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
                    clr       <u00DC
                    inc       <u00DC        initialize fmt RESCAN flag
NXTFM1               ldx       <u008C
                    bsr       FMTNUM         Look for repeat count
                    bcs       NXTFM3         Bra if not found
                    cmpa      #'(                 Repeat char?
                    bne       L57AB         Error if not
                    lda       <u0092        Get current repeat count
                    stb       <u0092        save count
                    beq       L57AB         Dont permit zero count
                    inc       <u0094        Set flag
                    ldu       <u0046        Get repeat stack ptr
                    ldy       <u0090        Get repeat beginning ptr
                    pshu      y,a           Push count & ptr
                    stu       <u0046        Update repeat stack ptr
                    stx       <u0090        save repeat beginning ptr
* (orig: NXTFM2)
                    lda       ,x+           Get next chr
NXTFM3               leay      <L5723,pc           Point to start of specifiers table
                    clrb                          Init Specifier # to 0
***************
* Decode Table Lookup Loop
NXTFM4               pshs      a                   Preserve original char
                    eora      ,y                  Flip any differing bits
                    anda      #$DF                Mask out uppercase bit
                    puls      a                   Restore original char
                    beq       L57B2               If char matches, skip ahead
                    leay      3,y                 Point to next table entry
                    incb                          Bump up specifier #
                    tst       ,y                  Are we at the end?
                    bne       NXTFM4               Nope, keep looking
RPTERR               ldb       #$3F                I/O Format Syntax Error
                    bra       FMEXIT               Exit with error

L57AB               ldb       #$3E

FMEXIT               stb       <u0036              Save error code
                    coma                          Set carry
                    puls      pc,y,x              Restore regs & return

* Found specifier match
L57B2               stb       <u0085              Save specifier #
                    ldd       1,y                 Get offset
                    leay      d,y                 Add to base address
                    bsr       FMTNUM               Get up to 3 digit ASCII #'s, convert to binary
                    bcc       NXTFM51               Got it, skip ahead
                    ldb       #$01                None found, force to 1
NXTFM51               stb       <u0086              Save binary version of number
                    jmp       ,y                  Execute PRINT USING specifier routine

* Convert 3 digit ASCII decimal # @ ,X to binary equivalent. Carry clear if
* done, carry set if not ASCII decimal digits present
FMTNUM               bsr       L57DC               Go try & get ASCII number 0-9
* NOTE: 6809/6309 MOD, CHANGE TO BCS TO RTS, NOT ORCC/RTS
                    bcs       L57ED               None found, Set carry & exit
                    tfr       a,b                 Move binary digit 0-9 to B
                    bsr       L57DC               Try & get another ASCII number 0-9
                    bcs       L57E8               Couldn't, exit with carry clear anyways
                    bsr       BLDNUM               Convert 2 digit # into binary version (D)
                    bsr       L57DC               Try & get another ASCII number 0-9
                    bcs       L57E8               Couldn't, exit with carry clear anyways
                    bsr       BLDNUM               Convert this digit & add to previous total
                    tsta                          result <255? (useless, ADCA should set flags)
                    beq       FMTNM2               Yes, get next char & exit with carry clear
                    clrb                          Force result to 256
FMTNM2               lda       ,x+                 Get next char
                    bra       L57E8               Exit with carry clear

L57DC               lda       ,x+                 Get char
CHKDIG               cmpa      #'0                 If not ASCII 0-9, exit with carry set
                    blo       L57ED               (Same as BCS)
                    cmpa      #'9
                    bhi       BADNUM
                    suba      #$30                If it is 0-9, convert to binary & exit with
L57E8               andcc     #$FE                carry clear
                    rts

BADNUM               orcc      #$01
L57ED               rts

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
                    stb       <u0089        save frac size

L5802               lbsr      PRSJST
                    bcs       RPTERR         bra if error
                    puls      y,x           Restore registers
                    inc       <u00DC        Fmt rescanning legal now
EXCFMT               ldb       <u0085
                    lbeq      I.FMT         0=integer fmt
                    decb
                    beq       L5826         1=hex fmt
                    decb
                    lbeq      R.FMT
                    decb
                    lbeq      L5A10
                    decb
                    lbeq      S.FMT
                    lbra      L5904         5=bool fmt

L5826               jsr       <u0016
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
                    bne       L5852               No, skip ahead
                    ldb       #2                  Yes, size=2 bytes
                    cmpb      <u0086              Same or less than ???
                    blo       L5856               Yes, leave as 2
L5852               ldb       #1                  Anything else (BYTE/BOOLEAN) is 1 byte
                    leau      1,u           Set ptr to result
L5856               tfr       b,a
                    lsla
                    cmpa      <u0086        Too many for field?
                    bhi       L5893         ..yes; skip 1st half of first byte
HEXOUT               tst       <u0087
                    beq       HEXO10         ..left justify
                    bmi       L5870
                    pshs      b
                    lslb
                    pshs      b                   SUBR
                    ldb       <u0086
                    subb      ,s+
                    blo       HEXO05
                    bra       HEXO03

L5870               pshs      b
                    lslb
                    pshs      b
                    ldb       <u0086
                    subb      ,s+
                    bcs       HEXO05
                    asrb
HEXO03               pshs      b
                    lda       <u0086        Decrement field width
                    suba      ,s+           by number of leading spaces
                    sta       <u0086
                    lbsr      MOVSTR
HEXO05               puls      b
HEXO10               lda       ,u
                    lsra
                    lsra                    MS nybble right
                    lsra
                    lsra
                    bsr       HEXCHR         Output it
                    beq       HEXO90         Exit if fld full
L5893               lda       ,u+
                    bsr       HEXCHR
                    beq       HEXO90         Also exit if full
                    decb                    bytecnt
                    bne       HEXO10
                    ldb       <u0086
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
                    dec       <u0086        Decr fld width
                    rts

***************
* Return Format Mismatch Error
FMSMAT               coma
                    rts

I.FMT               jsr       <u0016
                    cmpa      #$02          What TYPE result?
                    bcs       I.FMT1         Not str if error
                    bne       FMSMAT         bra if not real
                    lbsr      L5098         Convert to integer
I.FMT1               pshs      u,x
                    leas      -5,s
                    leax      ,s
                    lbsr      INTSTR         Call the master conv subr
                    ldb       <u0086        Get fld width
                    decb                    One for sign
                    subb      <u0076        then # digits in result
                    bpl       L58D5         Keep going if fld big enough
                    leas      5,s           Pop old buffer
                    puls      u,x           then regs
                    lbra      L5A07         Go fill it with *** + rts

***************
* Decode Justification
L58D5               tst       <u0087
                    beq       L58E3         0=left
                    bmi       L58F4
                    lbsr      MOVSTR
                    lbsr      SGNSPC         Sign or space
                    bra       L58FA

***************
* Right Justify, Zero Fill
L58E3               lbsr      SGNSPC
                    pshs      b             save fill count
                    lda       <u0076
                    lbsr      OUTZE1
                    puls      b
                    lbsr      MOVSTR         Now the fill
                    bra       L58FF

L58F4               lbsr      SGNSPC
                    lbsr      OUTZER
L58FA               lda       <u0076
                    lbsr      OUTZE1
L58FF               leas      5,s
                    clra
                    puls      pc,u,x

L5904               jsr       <u0016              Go get var type
                    cmpa      #3                  Boolean?
                    bne       FMSMAT               No, set carry & exit
                    pshs      u,x                 Preserve regs
                    leax      >L5143,pc           Point to 'True'
                    ldb       #4                  Size of 'True'
                    lda       2,y                 Get boolean value
                    bne       S.FMT1               $FF is true, so skip ahead
                    leax      >L5148,pc           Point to 'False'
                    ldb       #5                  Size of 'False'
                    bra       S.FMT1               Go deal with it

S.FMT               jsr       <u0016              Go get var type
                    cmpa      #4                  String?
                    bne       FMSMAT               No, exit with carry set
                    pshs      u,x                 Preserve regs
                    ldx       1,y                 Get ptr to string
                    ldd       <u0048        String Stack ptr
                    subd      1,y           (D)=length of string
                    subd      #1            Don't count eos byte
                    tsta                    than 255 bytes?
                    bne       S.FMT2         ..Yes; too large
S.FMT1               cmpb      <u0086
                    bls       S.FMT3         ..No; continue
S.FMT2               ldb       <u0086
S.FMT3               tfr       b,a
                    negb
                    addb      <u0086        ..Length from field size
                    tst       <u0087        check justify TYPE
                    beq       L594F         0=left
                    bmi       S.FMTC         -1=centered
***************
* Left Justify
* (orig: S.FMTL)
                    pshs      a             save length
                    lbsr      MOVSTR         Do the fill
                    puls      a
                    lbsr      OUTZE1         Move it out
                    bra       S.FMTX

L594F               pshs      b
                    bra       L595E

***************
* Center Justify
S.FMTC               lsrb
                    bcc       S.FMT4         Was it odd?
                    incb                    Add extra char to trailing fill
S.FMT4               pshs      d
                    lbsr      MOVSTR
                    puls      a
L595E               lbsr      OUTZE1
                    puls      b             Pop the trailing fill count
                    lbsr      MOVSTR
S.FMTX               clra
                    puls      pc,u,x

R.FMT               jsr       <u0016              Go get var type
                    cmpa      #2                  Real?
                    beq       R.FMT1               Yes, skip ahead
                    lbcc      FMSMAT               If carry clear, set carry & exit
                    lbsr      L509B               ??? possible convert?
R.FMT1               pshs      u,x
                    leas      -$0A,s
                    leax      ,s
                    lbsr      RLASC         Call the main conversion routine
                    lda       <u0079        Get dec exp val
                    cmpa      #$09          exp must be <10e+10
                    bgt       R.FMTE         Error if bigger
                    lbsr      RNDRL         Call rounding subr
                    lda       <u0086        Get total field size
                    suba      #$02
                    bmi       R.FMTE
                    suba      <u0089
                    bmi       R.FMTE
                    suba      <u008A
                    bpl       R.FMT2
***************
* Error Exit When Impossible to Format: Clean Up Stack +
* Call Routine to Fill Field With Asterisks
R.FMTE               leas      $0A,s
                    puls      u,x
                    bra       L5A07         Exit to error filler

***************
* Decode Justification Mode and bra to Formatter Routines
R.FMT2               sta       <u0088
                    leax      ,s            Restore buffer ptr
                    ldb       <u0087        Get justify code
                    beq       L59AC         O=left justify
                    bmi       OUTRNS         -1=center justify(money)
***************
* Left Justify, Leading Sign, Trailing Space Fill
* (orig: R.FMTL)
                    bsr       SPCFIL
***************
* Center (Financial) Justify: Right Justify, Space Fill, Trailing Sign/Space
* (orig: R.FMTC)
                    bsr       L59BE
                    bra       R.FMTX

L59AC               bsr       L59BE
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

L59BE               lbsr      SGNSPC
OUTRN               lda       <u008A
                    lbsr      OUTZE1
                    lbsr      L5612         then decimal point
                    ldb       <u0079        Get decimal exponent
                    bpl       L59F9         No problem if positive
                    negb
                    cmpb      <u0089        to many for field?
                    bls       OUTRN1         ..no
                    ldb       <u0089
OUTRN1               pshs      b
                    lbsr      OUTZER         Output leading zeroes
                    ldb       <u0089
                    subb      ,s+           Adjust field size for number of zeros printed
                    stb       <u0089
                    lda       <u008B        Get fraction digit count
                    cmpa      <u0089        Too many for rest of field?
* 6809/6309 MOD: SHOULD BE BLS OUTFP2
                    bls       OUTRN2         ..no
***************
* Output Floation Point number Elements
* (orig: OUTFPN)
                    lda       <u0089
OUTRN2               bra       OUTFP2

***************
* Output Space-Fill field
SPCFIL               ldb       <u0088
                    lbra      MOVSTR         Go do it

OUTFP0               lbsr      SGNSPC
                    lda       <u008A        Get int field size
                    lbsr      OUTZE1
                    lbsr      L5612
L59F9               lda       <u008B
OUTFP2               lbsr      OUTZE1
                    ldb       <u0089        Get frac field size
                    subb      <u008B        Subtract #signif.
                    ble       BADRTS         Skip fill if <=0
* (orig: OUTFP9)
                    lbra      OUTZER         Output trailing zero fill for rest of field

L5A07               ldb       <u0086
                    lda       #$2A                * (?)
                    lbsr      L5636         Print the astericks
                    clra
BADRTS               rts

L5A10               jsr       <u0016              Go get variable type
                    cmpa      #2                  Real?
                    beq       E.FMT0               Yes, skip ahead
                    lbcc      FMSMAT               If carry clear, set carry & exit
                    lbsr      L509B               ??? Convert to real?
E.FMT0               pshs      u,x
                    leas      -$0A,s
                    leax      ,s
                    lbsr      RLASC         Call the general conversion subr
                    lda       <u0079        Get decimal exponent
                    pshs      a             save it
                    lda       #1            Force exponent=1
                    sta       <u0079
                    bsr       RNDRL         Call the rounder
                    puls      a             Restore previous exp (adjusted)
* (orig: E.FMT1)
                    ldb       <u0079
                    cmpb      #1
                    beq       L5A39         Skip if digits didnt shift
                    inca
L5A39               ldb       #1
                    stb       <u008A        Force one int digit
                    sta       <u0079
                    lda       <u0086        Get total field size
                    suba      #6
                    bmi       L5A4D
                    suba      <u0089
                    bmi       L5A4D
                    suba      <u008A
                    bpl       E.FMT2
L5A4D               leas      $0A,s
                    puls      u,x
                    bra       L5A07

E.FMT2               sta       <u0088
                    ldb       <u0087
                    beq       L5A62
                    bsr       SPCFIL
                    bsr       OUTFP0         Do number+sign
                    lbsr      L55DA
                    bra       E.FMTX

L5A62               bsr       OUTFP0
                    lbsr      L55DA         Do the exponent
***************
* Common Cleanup/Exit
E.FMTX               lbra      R.FMTX

RNDRL               pshs      x                   Save ptr to beginning of string number
                    lda       <u0079        Get decimal exponent
                    adda      <u0089        Add # frac digits needed
                    bne       RNDRL1         >>begin patch
                    lda       ,x
                    cmpa      #$35
                    bcc       L5A8F
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
L5A8F               ldb       #'0                 Wrap to 0
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
                    inc       <u0079        and adjust exponent
ENDRND               puls      x                   Get string ptr back
                    lda       <u0079        Get dec exp
                    bpl       IPART
                    clra                    Part=0 if neg exp
IPART               sta       <u008A
                    nega
                    adda      #$09          Compute frac size
                    bpl       FPART
                    clra
FPART               cmpa      <u0089
                    bls       FPART2
                    lda       <u0089        Use whatever is smaller
FPART2               sta       <u008B
                    rts

***************
* Unimplemented routine error
*  currently used for: Status
UNIMPL               ldb       #48                 Unimplemented routine error
                    stb       <u0036              Save error code
                    coma                          Exit with error
                    rts

				ifne		wildbits
BannerGo            leax      NEWLN,pcr
                    ldy       #NEWLNLEN
                    lda       #1
                    os9       I$Writln
                    bcs       ERROR
                    leax      OUTSTR,pcr
                    ldy       #STRLEN
                    lda       #1
                    os9       I$Write
                    bcs       ERROR
                    ldx       #$FE00
                    lda       7,x
                    cmpa      #$02
                    bne       isItK
                    leax      OUTSTR2,pcr
                    ldy       #STRLEN2
                    lda       #1
                    os9       I$Writln
                    bcs       ERROR
                    bra       CONT
isItK           cmpa      #$12
                    bne       isItK2
                    leax      OUTSTR3,pcr
                    ldy       #STRLEN3
                    lda       #1
                    os9       I$Writln
                    bcs       ERROR
                    bra       CONT
isItK2          cmpa      #$16
                    bne       isItJrJr
                    leax      OUTSTR4,pcr
                    ldy       #STRLEN4
                    lda       #1
                    os9       I$Writln
                    bcs       ERROR
                    bra       CONT
isItJrJr            cmpa      #$1A
                    bne       ERROR
                    leax      OUTSTR5,pcr
                    ldy       #STRLEN5
                    lda       #1
                    os9       I$Writln
                    bcs       ERROR
CONT                leax      BASL2,pcr
                    ldy       #BASLEN2
                    lda       #1
                    os9       I$Write
                    bcs       ERROR
DONE                ldb       #0
ERROR               lbra      COMAND
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
