********************************************************************
* Basic09 - BASIC for OS-9
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
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
* NitrOS9 V1.21 mods
* 06/17/94 - Changed intercept routine @ L07B5: Replaced LSL <u0034/COMA/
*            ROR <u0034/RTI with OIM #$80,<u0034/RTI/NOP/NOP
*          - Changed routine @ start:
*               FROM                TO
*          4   LEAU >$100,u    4   LDW #$100
*          1   CLRA            2   CLR ,-s
*          1   CLRB            3   TFM s,u+
*          2   STD  ,--u       2   LEAS 1,s
*          3   CMPU ,s         1   NOP
*          2   BHI  L07C9      1   NOP
* Bytes:  15                  15
*          - Changed CLRA/LDB #$01 to LDD #$0001 @ end of start
* 06/22/94 - Changed L0DBB (reset temp buffer to empty state) to use PSHS D
*          - LDA #1 / STA <u007D / LDD <u0080 / STD <u0082 / PULS PC,D
*            (saves 5 cycles) ALSO WORKS AS 6809 MOD
*          - Changed BEQ L08E3 to BEQ L08E5 @ L08D3 (Std in for commands)
*          - Changed numerous CLRA/CLRB and COMA/COMB to CLRD & COMD respectiv
*            just to shorten source
* 06/27/94 - Added 2nd TFM to init routine to clear out $400-$4ff
* 06/28/94 - Changed BRA L5632 @ L5614 to PULS PC,U,A (6809 TOO)
* 12/22/94 - BIG TEST: TOOK OUT NOP'D CODE - SEE IF IT STILL WORKS
*          - IT DOESN'T - MOVED ALL NOPS TO JUST BEFORE ICPT ROUTINE TO
*            SEE IF THE SEPARATION OF CODE & DATA MAKES A DIFFERENCE
*          - THIS APPEARS TO WORK...THEREFORE, SOME REFERENCES TO THE DATA
*            AT THE BEGINNING OF BASIC09 IS STILL BEING REFERRED TO BY OFFSETS
*            IN THE CODE, THAT HAVE NOT BEEN FIXED UP YET.
* 12/23/94 - AFTER FIXING L03F0 TABLE, ATTEMPTED TO REMOVE 'TEST'
* 12/28/94 - Worked, changed 16 bit,pc's to 8 bit,pc's @:
*            L0DFC  leax L0E5F,pc  *
*            L1436  leax L1434,pc  *
*            L15B3  leax L15AA,pc  *
*            L1B97  leax L1B93,pc  *  (Doesn't seem to be referenced)
*            L39E0  leax L39DA,pc  *
*            L4751  leax L474D,pc  *
*            L479F  leax L479A,pc  *
*            L4812  leax L4805,pc  *
*            L4B03  leau L4AF4,pc  *
*            L4B0A  leau L4AF9,pc  *
*            L5791  leax L5723,pc  *
* 01/03/95 - Changed a ChgDir @ L397D to do it in READ mode, not UPDATE
* 01/04/95 - Changed L0C18 - 3 CLR ,Y+ to LEAY 3,Y
*            Changed LEAU ,Y / STD ,--U / STA ,-U to LEAU -3,y/STD ,u/
*              STD 2,u
*          - Changed LDA #$02 / LDB #SS.Size to LDD #$02*256+SS.Size @ L0D6B
*              (create output file)
*          - Replaced BEQ L2D17 @ L2D0B with BEQ L2CE1, removed L2D17 altog-
*            ether, change LBSR L2A26 @ L2D0B with LBRA L2A26
* 01/09/95 - Attempted to change both CLRA/CLRB (CLRD)'s @ L0F96 to CLRA for
*            F$Load/F$Link (since neither require B)
*          - Changed L0C83 frm LBSR L12CF to LBSR L1371
*          - Changed L12CF from LDA #C$CR/LBRA L1373 to LBRA L1371
* 01/12/95 - Attempted to remove LDD <U002F / ADDD $F,x @ L1A2E, move TFR
*            D,Y to earlier in code when [u002F]+($F,x) is calculated
* 01/17/95 - Removed useless CMPB #$00 @ L1E9B
*          - Moved L1FF5 label to an earlier RTS, removed original (saves 1 by
*          - Removed useless CMPA #$00 @ L2115
* 01/19/95 - Changed STB <u00A4 / STA <u00A3 to STD <u00A3 @ L236A
*          - Changed LDA <u00A3/CMPA <u00A3 to LDA <u00A3/ORCC #Zero @ L218E
*             (1 cycle faster)
*          - Changed L243F: took out LEAY -1,y, added BRA L2453 (saves 2 cycle
*             from original method)
* 01/20/95 - Changed L1B09 from to auto-inc Y, skip LEAY 1,Y entirely, & chang
*            LEAY 5,Y to LEAY 4,Y (+2 cyc if [,y]=$4F, but -3 cyc on any other
*            value)
*          - Changed L1B6D: changed CLRA / LDB D,X to to ABX / LDB ,X (3 cyc
*            faster on 6809/2 cyc faster on 6309)
*          - Mod @ L233E: Changed LBSR L2430 to LBSR L2432 (just did
*            L245D call, and 2nd call to it will return same Y anyways)
*          - Changed CLR ,Y+ to STB ,Y+ @ L2494
*          - Attempted to move L2368 routine to just before L239D routine to
*            change LBRA L2415 to BRA L2415. Changed L23EC from LBRA L236A to
*            STD <u00A3 / BRA L2415
*          - Changed LBHS L2A0D / BRA L27CE @ L27A3 to BLO L27CE / LBRA L2A0D
*          - Attempted Mod @ L2D2C - Changed LEAX B,X to ABX
* 01/23/95 - Made following mods involving L2E3B routine:
*            Changed CMPA #0 to TSTA, reversed L2EDC's LDA <u00D1 & LEAY 3,Y
*            so TSTA not needed, changed BRA L2E3B to BRA L2E41 @: L2E89,
*            L2E8F, L2E95, L2E9F. Changed BRA L2E3B to BRA L2E3C @ L2EDC
*          - Changed LDA #1 to INCA @ L2E3B (since A=0 at this point)
*          - Took out CMPA #0, changed LDD #$0060 to LDB #$60 @ L2EE3
*          - Changed TST <u00D0 to LDA <u00D0 (saves 2 cyc) and following 4
*            lines @ L2F5E to version on right (+1 byte, -5 cycles):
*            lda #5             ldd #$ffff
*            sta <u00D1         std <u00D4
*            ldd #$ffff         lda #5
*            bra L2FB9          sta <u00D1
*              (std <u00D4/     rts
*               lda <u00D1/rts
* 01/31/95 - Moved L308D to just before L26CE (eliminates LBRA)
* 02/03/95 - Changed LBRA L1EC9 @ L216B to LBRA L233E (saves extra LBRA, saves
*            5/4 cycles)
* 02/13/95 - Moved JSR <u001B / FCB 8 from L3C29 to just after L4F77 to change
*            LBSR to BSR
* 02/14/95 - Moved 3 text strings that are only referred to once to their res-
*            pective routines in the code: L07AA to near L1882, L078B to near
*            L198A, and L0799 to L1211
*          - Moved JSR <u001E / FCB 4 from L010A to after L090F (called twice
*            from just before here)
*          - Attempted to move JSR <u001E / fcb 2 from L010D to just before
*            L0AC3 (change some LBSR's to BSR's)
*          - Moved L0110 (JSR <u001E / fcb 0) to just before L0DF6
*          - Moved L0113 (JSR <u0021 / fcb 0) to just before L0DF6
* 02/15/95 - Moved L0116 (JSR <u0024 / fcb 0) to just after L082E
*          - Moved L0119 (JSR <u0024 / fcb 0) to just after L0DFC
*          - Moved L011C (JSR <u0024 / fcb 2) to just after L0DFC
*          - Moved L011F (JSR <u002A / fcb 2) to just after L1394
*          - Moved L0122 (JSR <u001E / fcb A) to just before L1606
*          - Moved L0125 (JSR <u001E / fcb 6) to just after L19D1
*          - Moved L0128 (JSR <u001E / fcb 6) to just after L0B51
*          - Moved L012B (JSR <u0021 / fcb 6) to just after L110A
*          - Moved L012E (JSR <u0021 / fcb 4) to just after L119E
*          - REMARKED OUT L0131 JSR VECTOR - NOT CALLED IN BASIC09
*          - Moved L0134 (JSR <u0024 / fcb C) to just after L104E
*          - Moved L0137 (JSR <u0024 / fcb 8) to just after L119E
*          - Moved L013A (JSR <u002A / fcb 0) to just after L175A
*          - Moved L1CC1 (JSR <u001B / fcb 2) to just after L1E1C
*          - Moved L1CC4 (JSR <u001B / fcb 4) to just after L1E1F
*          - Moved L1CC7 (JSR <u001B / fcb 6) to replace LBRA L1CC7 @ L1E1C
*            & embedded JSR <u001B/fcb 4 @ L2428 since LBRA, not LBSR
*          - Moved L1CCA (JSR <u002A / fcb 0) to just after L239D
*          - Moved L1CCD (JSR <u001B / fcb $12) to just after L22C7
*          - Took out 2nd TST <u0035 / BNE L194C @ L191C
*          - Eliminated L2572 since duplicate of L1CC1, & not speed crucial
*          - Eliminated L2575 since duplicate of L1CC7, changed LBRA L2575 @
*            L2A0D to LBRA L1CC7
* 02/16/95 - Moved L2578 (JSR <u001B / fcb $14) to end of L2FDA (replacing
*            LBRA to it)
*          - Moved L257B (JSR <u001E / fcb 8) to end of L3069
*          - Moved L257E (JSR <u001E / fcb 6) to end of L310B
*          - Eliminated L3206 since duplicate of L1CC7, changed 3 LBRA calls
*            to it to go to L1CC7 instead (saves 3 bytes)
*          - Moved L3209 to just after table @ L323F, changed table entry from
*            L35F0 to L3209, eliminated L35F0 LBRA entirely
*          - Moved L320C (JSR <u001B / fcb $E) to end of L39A0
* 02/24/95 - Eliminated L320F since dupe of L1CC1, change appropriate LBSR's @
*            L3A1B & L3A23
*          - Moved L3212 (JSR <u001B / fcb 0) to end of L3A89
* 02/27/95 - Moved L3215 (JSR <u001B / fcb $A) to end of L3BF3
*          - Moved L3218 (JSR <u001B / fcb $10) to end of L3A42
*          - Took out L321B (JSR <u001E/fcb 6), replaced LBRA to it @ L35CA
*            with JSR/fcb
*          - Moved L321E (JSR <u0027/fcb 4) to end of L347E
*          - Moved L3221 (JSR <u0027/fcb $A) to end of L348E
*          - Moved L3224 (JSR <u0027/fcb 2) to before L3A8A, and moved 2 lines
*            from L35BB to here too)
*          - Moved L3227 (JSR <u0027/fcb $C) to after L381C
*          - Moved L322A (JSR <u0027/fcb $E) to after L381C
*          - Moved L322D (JSR <u0027/fcb 0) to after L3BFF
*          - Moved L3230 (JSR <u002A/fcb 2), even though dupe of L011F, to
*            after L3779
* 02/28/95 - Embedded L3233 (JSR <u001B/fcb $18) @ L35F3 & L3A23, changed LBSR
*            @ L3371 to point to L35F3 version
*          - Moved L3236 (JSR <u001B/fcb $16) to after L3391
*          - L3239 (JSR <u001B/fcb $1A) is NEVER CALLED IN BASIC09.
*            Removed L3239 entirely
*          - Embedded L323C (JSR <u001B/fcb $1C) @ L34DC since LBRA
*          - Changed LDB #0 @ L388F to CLRB
*          - Embedded L3C2C (JSR <u0024/fcb 6 (error handler)) @ L3DD5,L3E78,
*            L3F2E,L44C2,L458C,L491C,L4FC7) Moved it to just after L40CC.
*          - Changed LDB #0 @ L4409 to CLRB (part of Boolean routines)
*          - Changed LDB #0 @ L5046 to CLRB
*          - Removed L3C2F (dupe of L011F), changed LBSR's @ L471F & L4FAA to
*            it
*          - Moved L3C32 to after L505E (shorten LEAX)
* 03/01/95 - Modified Integer Multiply to use MULD @ L3EE1
* 03/10/95 - Modified Negate of REAL #'s to use EIM @ L3FA4 (saves 4 cyc)
*          - Changed L3FBB (Real add with dest var=0) to use LDQ/STQ (saves
*            6 cyc)
* 03/13/95 - Changed NEGA/NEGB/SBCA #0 to NEGD @ L4512 & L4591
*          - Changed BPL L451E to BPL L451F @ L4512 (eliminates 2nd useless
*            TSTA)
* 03/15/95 - Changed LDB $B,y/ANDB #$FE/STB $B,y & LDB 5,y/ANDB #$FE/STB $B,y
*            to AIM's @ L3FE5 (Real Add & Subtract)
*          - Changed ADCB 3,y/ADCA 2,y to ADCD 2,y @ L4039 (Real Add/Subtact)
*          - Changed SBCB 3,y/SBCA 2,y TO SBCD 2,y @ L400B (Real Add/Subtact)
*          - Changed LDA 5,y/ANDA #$FE/STA 5,y to AIM #$FE,5,y @ L45AE (ABS
*            for real #'s
*          - Changed NEGA/NEGB/SBCA #0 to NEGD @ L45B5 (ABS for Integers)
*          - Ditched special checks for 0 or 2 in Integer Multiply (L3EC1),
*            since overhead from checks is as slow or slower as straight MULD
*            except in dest. var=0's case
* 03/16/95 - Changed 2 LDD/STD's @ L3F93 to LDQ/STQ
* 03/18/95 - Changed Integer Divide (and MOD) routines to use DIVQ
* 03/20/95 - Changed L3F7C (copy Real # to temp var from inc'd X) to use
*            LDQ/STQ/LDB #4/ABX
*          - Moved Integer MOD routine (L46A2) to nearer divide (changes LBSR
*            to BSR)
* 04/23/95 - Changed Real Add/Subtract mantissa shift (L4082-L40C9) to use
*            <u0014 (unused in BASIC09) to hold shift count instead of stack
*            (saves 2 cyc for STA vs. PSHS, saves 1 cyc per DEC, & saves 5 cyc
*            by eliminating LEAS 1,s) (6809)
* 04/26/95 - Split real add/subtract out & made two versions: 6809 & 6309
* 06/09/95 - Modified 6309 REAL add/subtract routine - now 13-15% faster
* 06/20/95 - Took out useless LDB 2,s @ L412D (Real Multiply)
* 07/18/95 - Changed sign fix in Real Add @ L4071 to use TFR w,d/lsrb/lslb/orb
*            ,y/std $a,y
*          - Split real multiply out & made two versions: 6809 & 6309
* 08/11/95 - Removed useless LEAS 1,s in Init routine
*          - Split real divide out & made two versions: 6809 & 6309
* 08/15/95 - Removed useless: STA <u00BD in start, useless CLR <u0035 @ L07FC,
*            Changed LDD #1 to LDB #1/STD <u002D to STB <u002E in start, and
*            L07FC/L082E routine to use W instead of stack for base address
*          - Changed 'bye <CR>' buffer fill @ L08E5 to use LDQ/STQ
* 11/12/95 - Changed L3405 to use INCD instead of ADDD #1 (NEXT Integer STEP 1
*          - Changed L341E to TFR A,E instead of PSHS A, changed TST ,S+ to
*            TSTE (NEXT Integer STEP <>1)
* 11/16/95 - Changed to L345E (REAL NEXT STEP 1) to do direct call to REAL add
*            routine (changed BSR L321E/BSR L34DC to LBSR L3FB1)
*          - As per above, changed same call @ L34A5 (REAL NEXT STEP <>1), and
*            eliminated L321E completely
*          - @ L347E & L34CC, eliminated L3221 calls, replaced BSR L3221's
*            with LBSR L4449 (Real Compare) (in REAL NEXT, both cases)
* 11/25/95 - Remove L50A1 & L509E (calls to REAL Multiply & REAL divide),
*            changed L529B to call them directly (prints exponents?)
* 11/30/95 - Changed L3AF9 to use SUBR (saves 1 byte/9 cyc on RUN (mlsub)
* 12/05/95 - Changed L3A48 (called by REM) to use ABX instead of CLRA/LEAX D,X
*            (used to jump ahead in I-Code to skip remark text)
*          - Attempted to just move L33DF (NEXT) & L34E5 (FOR) Tables to just
*            after L3446 for 8 bit offsets - also removed LSLB @ L33EA
* 02/12/95 - Changed routines around L57EB to skip ORCC if not necessary (blo&
*            bcs)
*          - Changed LEAX to 8 bit from 16 @ L4B89
* 06/07/14 - Changed Date$ to conform with Y2K changes in F$Time. RG
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
u0017               rmb       2                   Address for above (inited to L3D41)
u0019               rmb       2                   Inited to L3C32 (JSR <u001B / FCB $1A)
* The following vectors all contain a JMP >$xxxx set up from the module header
u001B               rmb       3                   Jump vector #1  (Inited to L00DC)
u001E               rmb       3                   Jump vector #2  (Inited to L1CA5)
u0021               rmb       3                   Jump vector #3  (Inited to L255A)
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
                    fdb       L255A               $21 jump vector
                    fdb       L31E8               $24 jump vector
                    fdb       L3C09               $27 jump vector
                    fdb       L5084               $2A jump vector
                    fdb       $0000               End of jump vector table marker

name                fcs       /Basic09/

L0022               fdb       $1607               Edition #22 ($16)

* Intro screen

                    ifne      F256
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

L00EC               fdb       L0F91-L00EC         Function 0
                    fdb       L1287-L00EC         Function 2   Print error message (B=Error code)
                    fdb       L0899-L00EC         Function 4
                    fdb       L088F-L00EC         Function 6
                    fdb       L18BE-L00EC         Function 8
                    fdb       L0E73-L00EC         Function A
                    fdb       L0E6D-L00EC         Function C
                    fdb       L0E8F-L00EC         Function E
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
L0671               fdb       L0E6D-L0671
                    fcs       'BYE'
L0676               fdb       L094A-L0676
                    fcs       'DIR'
L067B               fdb       L1590-L067B
                    fcs       'EDIT'
L0681               fdb       L1590-L0681
                    fcs       'E'
L0684               fdb       L0D02-L0684
                    fcs       'LIST'
L068A               fdb       L0DC7-L068A
                    fcs       'RUN'
L068F               fdb       L0E98-L068F
                    fcs       'KILL'
L0695               fdb       L0CF4-L0695
                    fcs       'SAVE'
L069B               fdb       L0AC3-L069B
                    fcs       'LOAD'
L06A1               fdb       L0A32-L06A1
                    fcs       'RENAME'
L06A9               fdb       L0B51-L06A9
                    fcs       'PACK'
L06AF               fdb       L0918-L06AF
                    fcs       'MEM'
L06B4               fdb       L0A24-L06B4
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
L06D0               fdb       L094A-L06D0
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
L07B5               lda       R$DP,s              Get DP register from stack
                    tfr       a,dp                Put into real DP
                    stb       <u0035              Save signal code

                    ifne      H6309
                    oim       #$80,<u0034         Set high bit (flag signal was received)
                    else
                    lsl       <u0034              Set high bit (flag signal was received)
                    coma
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
                    pshs      u                   Save start of data mem on stack
                    leau      >$100,u             Point to end of DP
                    clra                          Clear all of DP to $00
                    clrb
L07C9               std       ,--u
                    cmpu      ,s
                    bhi       L07C9
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
L07FC               os9       I$Close
                    inca
                    cmpa      #$10                Do until 3-15 are closed
                    blo       L07FC
                    lda       #$02                Create duplicate path for error path
                    os9       I$Dup
                    sta       <u00BE              Preserve duplicate's path #
                    leax      <L07B5,pc           Point to intercept routine and set it up with
                    os9       F$Icpt              it's memory area @ start of param area
                    leax      >L000D-$d,pc        Point to beginning of module header
                    ifne      H6309
                    tfr       x,w                 Move it to W
                    else
                    pshs      x
                    endc
                    ldx       <u0000              Point X to start of data mem
* Set up some JMP tables from the module header
                    leax      <$1B,x              Point $1b bytes into it
                    leay      >L000D,pc           Point to module header extensions
L082E               lda       #$7E                Opcode for JMP Extended instruction
                    sta       ,x+                 Store in table
                    ldd       ,y++                Get jump offset from module header extension
                    ifne      H6309
                    addr      w,d                 Add to start of module address
                    else
                    addd      ,s
                    endc
                    std       ,x++                Store as destination of JMP
                    ldd       ,y                  Keep installing JMP tables until 0000 found
                    bne       L082E
                    ifeq      H6309
                    leas      2,s                 eat X on stack
                    endc
                    bsr       L0116               Go init <$50 vars, & some table ptrs
                    puls      y                   Get parameter ptr
                    leax      >L0140,pc           Point to main command token list
                    stx       <u009E              Save it
                    ldb       ,y                  Get char from params
                    cmpb      #C$CR               Carriage return?
                    ifne      F256
                    lbeq      BannerGo               Yes, go print the title screen L08A6
				else
				beq       L08A6
				endc
* Optional filename specified when BASIC09 called
                    leax      <L0860,pc           No, point to initial entry of routine
                    pshs      y                   Preserve param ptr
                    bsr       L0870
                    lbsr      L0F91
                    bcc       L088F
                    lbsr      L0AC3               Go open path to name (Y=ptr to it)
                    bra       L088F

L0116               jsr       <u0024              JMP to L31E8 (default from module header)
                    fcb       $00                 Function code 0

L0860               puls      y                   Get original contents of <u00B7
                    bsr       L086D
                    ldx       <u0004              Get ptr to module list
                    ldd       ,x                  Get ptr to 1st module (initially 0 (none))
                    std       <u002F              Save it
                    lbsr      L0DC7
L086D               leax      <L08B2,pc           Get ptr >1st entry into routine
L0870               puls      u                   Get RTS address
                    bsr       L0899               Push 2 bytes from <B7 onto stack, RTS=L0860
                    pshs      u                   Save RTS address from BSR L0870
                    clr       <u0034              Clear out signal recieved flag
                    ldd       <u0000              Get start of data mem
                    addd      <u0002              Add size of data mem
                    subd      <u0008              Subtract all BASIC09 reserved stuff ($500 bytes)
                    subd      <u000A              Subtract # bytes used by user's programs (not Data)
                    std       <u000C              Save # bytes free in workspace for user's programs
                    leau      2,s                 Point U to L0860 ptr on stack
                    stu       <u0046              Save ptr to it
                    stu       <u0044              And again
                    leas      -$FE,s              Bump stack ptr back 254 bytes
                    jmp       [<-2,u]             Jump to L0860 address on stack

L088F               lds       <u00B7
                    puls      d
                    std       <u00B7
L0896               lbra      L0DBB               Reset temp buffer size & ptrs to defaults

L0899               ldd       <u00B7              Get some other stack ptr?
                    pshs      d                   Preserve it
                    sts       <u00B7              Save stack ptr
                    ldd       2,s                 Get RTS address to L0870 or L0860
                    stx       2,s                 Save ptr to L0860 or L086D on stack
                    tfr       d,pc                Return to L0870 (just after BSR L0899)

L08A6               leax      >L0024,pc           Point to intro screen credits
                    bsr       L08D0               Copy to temp buffer/print to Std error
                    leax      name,pc             Point to 'Basic09'
                    bsr       L08D0               Copy to temp buffer/print to Std error

L08B2               bsr       L086D
                    leax      >L073F+1,pc         Point to 'Ready'
                    bsr       L08D0               Copy to temp buffer/print to Std error
                    leax      >L07A8,pc           Point to 'B:' prompt
                    leay      >L0668,pc           Point to system mode command table
                    clr       <u0084
                    bsr       L08D3               Get command & execute it
                    bcc       L088F               Did it, no problem
                    bsr       L08CC               Unknown command, print 'What?'
                    bra       L088F               Resume normal operation

L08CC               leax      >L0745,pc           Point to 'What?'
L08D0               lbra      L125F               Copy to temp buffer/print to Std error

* Get next command from keyboard & execute it
* Entry: Y=Ptr to command table
* Exit: Carry set if command doesn't exist
L08D3               pshs      y,x                 Preserve command tbl ptr & ptr to prompt (ex B:)
                    clr       <u0035              Clear out last signal received
                    lbsr      L126B               Go print a message if we have to to std err
                    bsr       L0896               S/B LBSR L0DBB (saves 3 cycles)
                    lda       <u00BD              Get current input path #
                    beq       L08E5               If Std In, skip ahead
                    os9       I$Close             Otherwise, close it
                    clr       <u00BD              Force input path # to 0 (Std In)
L08E5               lbsr      L0B2D               ReadLn up to 256 bytes from std in
                    bcc       L08F8               No error on read, continue
                    cmpb      #E$EOF              <ESC> key?
                    bne       L0915               No, exit routine with error
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
L08F8               ldx       2,s                 Get command tbl ptr back
                    lda       #$80                Mask to check for end of entry (high bit set)
                    bsr       L010A               Go parse line, y=ptr to offset in command found
                    bne       L090F               '$' or <CR> command found, skip ahead
                    lbsr      L010D               ???Go check for a procedure name, B=size
                    beq       L0915               None, exit with carry set
                    leax      $03,x               Point to system mode table 2
                    lda       #C$SPAC             ???
                    bsr       L010A               Go parse line, y=ptr to offset in command found
                    beq       L0915               No command found, exit with carry set
* Command found in table
L090F               ldd       ,x                  Get offset
                    leas      4,s                 Eat stack
                    jmp       d,x                 Call routine

L010A               jsr       <u001E
                    fcb       $04

* Command not found
L0915               coma                          Set carry & exit
                    puls      pc,y,x

* Entry: Y=Ptr to string of chars
L0918               lbsr      L0A90               Go find 1st non-space/comma char
                    bne       L093C               Found one, skip ahead
                    leax      ,y                  Point X to char
                    ldd       <u0008              Get ptr to start of I-Code workspace
                    addd      <u000A              Add to size of all programs in workspace
                    inca                          Bump up by 256 bytes
                    subd      <u0000              Subtract start of data mem ptr
                    pshs      d                   Preserve size
                    lbsr      L1748               ??? Check something
                    bcs       L0946               Error, exit with carry set
                    cmpd      ,s++                Check with previously calculated size
                    blo       L0948               Will fit, continue
                    os9       F$Mem               Won't fit, request the required data mem size
                    bcs       L093C               Can't get it, skip ahead
                    subd      #$0001              Bump gotten size down by 1 byte
                    std       <u0002              Save new data mem size
L093C               lbsr      L0DBB               Reset temp buffer size & ptrs
                    ldd       <u0002              Get data mem size
                    bsr       L09BA               ???
L0943               lbra      L1264               Print temp buff contents to std error

L0946               leas      2,s                 Eat something off stack
L0948               coma                          Exit with carry set
                    rts

* Debug & System mode - DIR
L094A               leax      ,y
                    lbsr      L0D5F
* System mode - <CR>
L094F               leax      >L0760,pc           Point to basic09 DIR header
                    lbsr      L125F               Print it out to Std err
                    ldy       <u0004              Get Ptr to list of modules in BASIC09 workspace
                    bra       L099B               Go print directory

* Entry: X=Ptr to module in memory
* Prints module names out of modules in work-space.
* A '*' indicates the current module, a '-' indicates packed or other language
*   module
L095B               pshs      y,x                 Preserve ? & module ptr
                    lda       #C$SPAC             Space char as default
                    tst       M$Type,x            Check type/language
                    beq       L0965               If source code in workspace, skip ahead
                    lda       #'-                 '- char indicates packed or other language code
L0965               lbsr      L1373               Add char in A to temp text buffer
                    lda       #C$SPAC             Default to space again
                    cmpx      <u002F              Is this the 'current' module?
                    bne       L0970               No, skip ahead
                    lda       #'*                 '*' to indicate current module
L0970               lbsr      L1373               Append that char to temp text buffer
                    ldd       M$Name,x            Get offset to name of module
                    leax      d,x                 Point to name
                    lbsr      L135A               ??? Print it out
                    ldd       #$11*256+M$Size     A=??, B=offset from module ptr to get data
                    bsr       L09AD               Go print program size
                    ldd       #$1C*256+M$Mem      A=??, B=offset from module ptr to get data
                    bsr       L09AD               Go print data area size
                    ldd       M$Mem,x             Get data area size required by module
                    addd      #$0040              Add 64 to it
                    cmpd      <u000C              Bigger than bytes free in workspace for user?
                    blo       L0993               Legal data area size, continue
                    lda       #'?                 Data area too big for current buffer space, print
                    lbsr      L1373               a '?' beside data area size
L0993               bsr       L0943               Print line out to std error path
                    puls      y,x                 Get ??? & module ptr back
                    tst       <u0035              Any signals pending?
                    bne       L099F               Yes, skip ahead
L099B               ldx       ,y++                Get ptr to module
                    bne       L095B               There is one, go print it's entry out
L099F               ldd       <u000C              None left, get # bytes free in BASIC09 workspace
                    bsr       L09BA               Go convert to ASCII
                    leax      >L074A,pc           Point to 'free'
                    lbsr      L1261               Print it out to Std err
                    lbra      L0D51               Close std err; Dup path @ <BE & return from there

* Entry: A=???, b=offset from module header to get 2 byte # from
L09AD               pshs      b                   Preserve B
                    ldb       #$10                Sub function (uses table @ L50B2)
                    lbsr      L011F               Call <2A (inited to L5084), function 2
                    puls      b                   Restore B
                    ldx       2,s                 Get module ptr back
                    ldd       b,x                 Get size to print

* Convert # in D to ASCII version (decimal)
L09BA               pshs      y,x,d               Preserve End of data mem ptr,?,Data mem size
                    pshs      d                   Preserve data mem size again
                    leay      <L09ED,pc           Point to decimal table (for integers)
L09C1               ldx       #$2F00
L09C4               puls      d                   Get data mem size
L09C6               leax      >$0100,x            Bump X up to $3000
                    subd      ,y                  Subtract value from table
                    bhs       L09C6               No underflow, keep subtracting current power of 10
                    addd      ,y++                Restore to before underflow state
                    pshs      d                   Preserve remainder of this power
                    ldd       ,y                  Get next lower power of 10
                    tfr       x,d                 Promptly overwrite it with X (doesn't chg flags)
                    beq       L09E6               If finished table, skip ahead
                    cmpd      #$3000              Just went through once?
                    beq       L09C1               Yes, reset X & do again
                    lbsr      L1373               Go save A @ [<u0082]
                    ldx       #$2F01              Reset X differently
                    bra       L09C4               Go do again

L09E6               lbsr      L1373               Go save A @ [<u0082]
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
L09FF               incb                          Bump size up by 1
                    lda       ,y+                 Get char from user's line
                    cmpa      #C$CR               Hit end yet?
                    bne       L09FF               No, keep looking
                    clra                          parameter line never >255 chars
                    tfr       d,y                 Move size of parameter area to Y for Fork
                    leax      >L0277,pc           Point to 'SHELL'
                    lda       #Objct              ML program
                    clrb                          Size of data area=0 pages
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
L0A24               lda       #DIR.+READ.         Open Data directory in Update mode
                    bra       L0A2A

* System Mode - CHX
L0A28               lda       #DIR.+EXEC.         Open Execution Directory
L0A2A               leax      ,y                  Point to directory we are changing to
                    os9       I$ChgDir            Change dir
                    bcs       L0A86               Error, exit with it
                    rts                           No error, return

L0A32               bsr       L0A9D
                    lbsr      L0F6E
                    bcs       L0A8C
                    pshs      x
                    ldx       ,x
                    tst       6,x
                    bne       L0A8C
                    bsr       L0A90               Go check char @ Y for space or comma
                    beq       L0A48               It is a space or comma, skip ahead
L0A45               comb                          Set carry, restore X & return
                    puls      pc,x

L0A48               bsr       L010D               Call <u001E, function 2
                    beq       L0A45
                    pshs      y
                    lbsr      L0F6E
                    bcs       L0A58
                    cmpx      $02,s
                    bne       L0A84
L0A58               ldx       $02,s
                    lbsr      L1A2E
                    puls      x
                    ldy       <u004A
L0A62               lda       ,x+
                    sta       ,y+
                    bpl       L0A62
                    sty       <u00AB
                    ldx       [,s++]
                    ldd       $04,x
                    leay      d,x
                    ldb       <$18,x
                    lda       <u00A6
                    sta       <$18,x
                    clra
                    lbsr      L19B1
                    addd      <u005E
                    std       <u005E
L0A81               lbra      L1995

L0A84               ldb       #$2C                Multiply-defined procedure error
* Error
L0A86               lbsr      L1287
L0A89               lbra      L088F

L0A8C               ldb       #$2B                Unknown procedure error
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
L0AA2               ldy       <u002F              Get ptr to 'current' module
                    beq       L0AAC               None, use 'Program' as default
                    ldd       M$Name,y            Get offset to module name
                    leay      d,y                 Point Y to module name & return
                    rts

L0AAC               leay      >L074F,pc           Point Y to 'Program'
L0AB0               rts

L0AB1               ldb       #$2B                Unknown procedure error
                    bra       L0ABD

L0AB5               ldb       #$20                Memory full error
L0AB7               pshs      b
                    bsr       L0A81
                    puls      b
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
                    bsr       L0B2D               Go read a line into temp input buffer
                    bsr       L0B3C               Go check if it starts with 'PROCEDURE'
                    bne       L0AB1               No, exit with Unknown Procedure Error
L0AD4               bsr       L010D               Yes, call function
                    beq       L0AB1
                    pshs      y
                    lbsr      L0F6E
                    bcs       L0AE8
                    ldy       ,s
                    leay      -$01,y
                    lbsr      L0E98
L0AE8               ldy       ,s
                    lbsr      L0EFD
                    lbsr      L1A2E
                    puls      x
                    lbsr      L125F
L0AF6               ldb       <u0035              Get last received signal code
                    bne       L0AB7               Got a signal, use it as error code & abort load
                    bsr       L0B2D               Go get line of source from file
                    bcs       L0AB7               Error on read, exit with it
                    lda       <u000C              Get MSB of bytes free in workspace
                    cmpa      #$02                At least $2ff (767) bytes free?
                    blo       L0AB5               No, exit with memory full error
                    bsr       L0B3C               Check for word PROCEDURE
                    beq       L0B14               Found it, skip ahead
                    ldy       <u0080              Get temp buff ptr
                    ldd       <u0060
                    std       <u005C
                    lbsr      L1606
                    bra       L0AF6

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
L0B2D               lda       <u00BD              Get path # to file
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
L0B43               lda       ,x+                 Get byte from 'procedure'
                    eora      ,y+                 Check (with case conversion) if it matches buffer
                    anda      #$DF
                    bne       L0B50               No, exit
* NOTE: SHOULD MAKE LDA -1,X SINCE FASTER
                    tst       -1,x                Was that the last letter of 'procedure'?
                    bpl       L0B43               No, keep checking
                    clra                          Yes, no error & return
L0B50               rts

L0B51               lbsr      L0C83
                    ldu       <u0046
                    bra       L0B79

L0128               jsr       <u0021
                    fcb       $02

* Entry: X=Ptr to possible filename
L0B58               ldy       ,y                  Get module header ptr from somewhere
                    tst       6,y                 Check type of module
                    lbne      L0E68               If anything but 0, exit with Line with Compiler error
                    lda       <$17,y              Get flag byte
                    rora                          Shift out Line with compiler error bit
                    lbcs      L0E68               Has error, exit with it
                    ldd       $0D,y               ???
                    leay      d,y                 Point to that offset in module
                    ldd       -3,y
                    lslb                          Multiply by 2
                    rola
                    inca                          Add $100
                    cmpd      <u000C              Compare with bytes free in workspace
                    lbhi      L0F69               If higher, exit with memory full error
L0B79               ldy       ,--u
                    bne       L0B58
                    ldd       #(EXEC.+WRITE.)*256+UPDAT.+EXEC. Exec. dir & rd/wt/ex attribs
                    lbsr      L0D6B               Go create file (0 byte length)
                    ldy       <u0046
                    stu       <u0046
                    lbra      L0C7A

L0B8C               pshs      y
                    lbsr      L1A2E
                    clr       <u00D9
                    bsr       L0128               JSR <u0021, function 2 (L255A)
                    inc       <u00D9
                    ldx       <u0062
                    leay      ,x
* NOTE: <u0000 UNECESSARY FOR LEVEL II
                    ldd       <u0000              Get start of data area ptr
                    addd      <u0002              Get ptr to end of data area
                    tfr       d,u                 Move to U
                    ldd       -3,x
                    beq       L0C18
                    pshs      u                   Save size of data area
L0BA8               pshs      d
                    leax      1,x
                    ldd       ,x
                    pshu      d
                    clr       ,x+
                    clr       ,x+
L0BB4               lda       ,x+                 Find hi-bit set char
                    bpl       L0BB4
                    puls      d
                    subd      #1
                    bne       L0BA8
                    ldy       <u005E
                    bra       L0BD1

L0BC4               ldd       ,y
                    ldx       <u0062
                    leax      d,x
                    ldd       1,x
                    sty       1,x
                    std       ,y++
L0BD1               lbsr      L1BC2
                    bcc       L0BC4
                    puls      u
                    ldx       <u0062
                    ldd       -3,x
                    leay      ,x
L0BDE               leau      -2,u
                    pshs      u,d
                    clra
                    ldu       1,x
                    beq       L0C04
                    pshs      x
                    tfr       y,d
                    subd      <u0062
                    bra       L0BF3

L0BEF               std       ,u
                    leau      ,x
L0BF3               ldx       ,u
                    bne       L0BEF
                    std       ,u
                    puls      x
                    lda       ,x
                    sta       ,y+
                    ldu       [<2,s]
                    stu       ,y++
L0C04               leax      3,x
L0C06               ldb       ,x+
                    cmpa      #$A0
                    bne       L0C0E
                    stb       ,y+
L0C0E               tstb
                    bpl       L0C06
                    puls      u,d
                    subd      #1
                    bne       L0BDE
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
L0C52               eora      b,x                 Calculate header parity
                    decb
                    bpl       L0C52               Do all of header
                    sta       M$Parity,x          Save header parity
                    ldy       M$Size,x            Get module size
                    leay      -3,y                Minus CRC bytes themselves
                    os9       F$CRC               Calculate module CRC
* If u not used after this, could change to com ,u/com 1,u/com 2,u
                    com       ,u+                 Last stage of CRC calc: Complement all 3 bytes
                    com       ,u+
                    com       ,u+
                    ldy       M$Size,x            Get module size again (including CRC)
                    lda       #2                  Path 2 for file
                    os9       I$Write             Write out entire module
                    lda       #%11000000          Packed & CRC just made flags
                    sta       <$17,x              Save them
                    lbcs      L0DB6               If error on write, go deal with it
                    puls      y
L0C7A               ldx       ,--y
                    lbne      L0B8C
                    lbra      L0D51               Go close file, reopen path from <BE, rts from there

L0C83               bsr       L0C9D
                    lda       ,y                  Get char
                    cmpa      #C$CR               Is it CR?
                    bne       L0C9A               No, point X to it & return
                    ldx       <u0046              Get ???
                    ldx       [<-2,x]
                    ldd       M$Name,x            Get offset to module name
                    leax      d,x                 Point X to module name
                    lbsr      L135A               Go set up temp buffer with name
                    lbsr      L1371               Append CR to end of temp buffer
L0C9A               leax      ,y
                    rts

L0C9D               ldu       <u0046              Get table end ptr
                    stu       <u0044              Save as current table ptr
                    lbsr      L0A90               Go get char (bump y past it if , or space)
                    beq       L0CC6               If comma or space, skip ahead
                    cmpb      #'*                 Is it a '*'?
                    bne       L0CCB               No, skip ahead
                    ldx       <u0004              Get ptr to workspace module ptr list
L0CAC               ldd       ,x                  Get 1st possible entry
                    beq       L0CB4               Empty, skip ahead
                    tfr       x,d                 Move ptr to D
                    leax      2,x                 Bump ptr up to next entry
L0CB4               std       ,--u                Save entry
                    bne       L0CAC
                    stu       <u0044              Save new ptr
                    lda       ,y                  Get char from temp buffer
                    cmpa      #C$CR               CR?
                    beq       L0CC2               Yes, save ptr & return
                    leay      1,y                 No, bump ptr up by 1
L0CC2               sty       <u0082              Save current pos in temp buffer & return
                    rts

L0CC6               lbsr      L010D               JSR <u001E, function 2
                    bne       L0CD9
L0CCB               sty       <u0082              Save current pos in temp buffer
                    lbsr      L0AA2               Point Y to Name of current module (or 'Program')
                    lbsr      L0F6E               Go check if module exists in BASIC09 workspace
                    bcc       L0CE1               Yes, skip ahead
L0CD6               lbra      L0A8C               No, return with Unknown Procedure error

L0CD9               lbsr      L0F6E               Check if module exists in BASIC09 workspace
                    bcs       L0CD6               No, return Unknown Procedure error
                    sty       <u0082              Save Ptr to end of fname as current pos in tmp buf
L0CE1               stx       ,--u                Save ptr to start of module name
                    ldy       <u0082              Get Ptr to end of filename
                    lbsr      L0A90               Point Y to next char (or past ',' or space)
                    bne       L0CF0               Not comma or space, skip ahead
                    lbsr      L010D               JSR <u001E, function 2
                    bne       L0CD9
L0CF0               clra
                    clrb
                    bra       L0CB4

L0CF4               tst       <u000C              >256 bytes free for user?
                    lbeq      L0F69               No, exit with Memory Full error
                    lda       #$80                Set hi-bit flag
                    sta       <u0084
                    bsr       L0C83
                    bra       L0D06

L0D02               bsr       L0C9D
                    leax      ,y
L0D06               stx       <u005C
                    bsr       L0D5F
                    ldy       <u0046
                    stu       <u0046
                    bra       L0D49

L0D11               pshs      y
                    ldy       [,y]
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
                    lbsr      L0899               ??? The <u00B7 stack swap
                    lbsr      L10E4               ??? DEBUG list command
L0D38               lbra      L088F               Restore <u00B7, reset temp buff

L0D3B               tst       <u0084              Test flags
                    bmi       L0D47
                    ldx       [,s]
                    lbsr      L1A2E
                    lbsr      L0128
L0D47               puls      y
L0D49               ldx       ,--y
                    bne       L0D11
L0D4D               bsr       L0D51
                    bra       L0D38

L0D51               pshs      b                   Preserve B
                    lda       #2
                    os9       I$Close             Close path #2 (error)
                    lda       <u00BE              Get Duplicate error path #
                    os9       I$Dup               Dupe the path
                    puls      pc,b                Restore B & return

L0D5F               lbsr      L0A90               Point Y to next char (or past ',' or space)
                    cmpb      #C$CR               Was it a CR?
                    beq       L0DB5               Yes, skip ahead
                    stx       <u0082              Save current pos in temp buffer
                    ldd       #$020B              Write access mode & pr r w attributes
* Create output file
* Entry: A=access mode
*        B=file attributes
*        X=Ptr to filename to create
L0D6B               pshs      u,x,d               Preserve regs
                    lda       #$02                Close std error path
                    os9       I$Close
                    ldd       ,s                  Get access mode & file attributes back
                    os9       I$Create            Attempt to create the file
                    bcc       L0DB3               Did it, skip ahead
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
                    clra
                    leax      ,--s                Make 2 byte buffer on stack
                    ldy       #2                  Get up to 2 chars from user
                    os9       I$ReadLn
                    puls      d                   Get chars from read buffer
                    eora      #$59                Check for Y
                    anda      #$DF                Force case
                    bne       L0D4D               User didn't hit Y or y, exit
                    ldd       #2*256+SS.Size      Path #2, set file size call
                    ldx       #0                  Set size to 0 bytes
                    leau      ,x
                    os9       I$SetStt            Truncate file size to 0 bytes
                    bcs       L0DB6               If error, skip ahead
L0DB3               puls      pc,u,y,d            Restore regs & return

L0DB5               rts

L0DB6               bsr       L0D51               Close & dupe error path
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
L0DC7               lbsr      L010D               <1E,func. 2 (Get string size/make FCS type if var name)
                    bne       L0DDF               There is >0 chars that qualify as name, skip ahead
                    pshs      y                   Save ptr to string name in question
* NOTE: MAY WANT TO CHANGE ENTRY POINT, SINCE L0A9D CALLS L010D AGAIN
                    lbsr      L0A9D               Get ptr & size of name, or use current (or 'Program')
                    ldx       ,s                  Get ptr to string name in question again
L0DD3               lda       ,y+                 Get char from name we _will_ use
                    sta       ,x+                 Save over top of string name in question
                    bpl       L0DD3               Copy whole string (including last hi-bit byte)
                    lda       #C$CR               Append CR to end
                    sta       ,x
                    puls      y                   Point to beginning of new string
L0DDF               lbsr      L0F91               Y=Ptr to end of string+1, X=Ptr to module ptr entry
                    lbcs      L0A8C               Module not in workspace, exit with Unknown Procedure
                    ldx       ,x                  Get ptr to module
                    stx       <u002F              Save as 'current module'
                    lda       M$Type,x            Get type/language byte
                    beq       L0DF6               If type & language are 0, skip ahead
                    anda      #LangMask           Just want language type
                    cmpa      #ICode              BASIC09 I-Code?
                    bne       L0E68               No, Line With Compiler Error
                    bra       L0DFC               Yes, skip ahead

L0110               jsr       <u001E
                    fcb       $00

L0113               jsr       <u0021
                    fcb       $00

* Type/Language byte of 0
L0DF6               lda       <$17,x              Get flags from module
                    rora                          Shift out Line with Compiler error flag
                    bcs       L0E68               There is an error, report it
* Current module has no obvious errors
L0DFC               bsr       L0110               <1E, fnc. 0 (1F9E normally) (do token?)
                    ldy       <u004A              Get ptr to end of currently used I-code workspace
                    ldb       ,y                  Get last char/token in workspace
                    cmpb      #'=                 Is it an = sign?
                    beq       L0E68
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
                    bcs       L0E68               Compiled line has error, report it
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
                    leax      <L0E5F,pc           Point to routine
                    lbsr      L0899
                    ldx       <u004A              Get ptr to next free byte in I-code workspace
                    bsr       L0119
                    lbsr      L0DBB
                    ldx       <u002F              Get ptr to start of current module
                    bsr       L011C
                    bra       L0E65

L0119               jsr       <u0024
                    fcb       $04

L011C               jsr       <u0024
                    fcb       $02

L0E5F               puls      x,d                 Restore bytes free in workspace & ptr to next free
                    std       <u004A              Save old next free byte in I-code workspace
                    stx       <u000C              Save old # bytes free in workspace for user
L0E65               lbra      L088F

L0E68               ldb       #$33                Line with compiler error
                    lbra      L0A86               Go report it

* System mode - BYE
L0E6D               bsr       L0E8F
                    clrb                          Exit without error
                    os9       F$Exit

L0E73               lbsr      L010D
                    beq       L0E8B
                    lbsr      L0F6E
                    bcs       L0E8B
                    ldu       <u0046

                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc

                    pshu      x,d
                    inca
                    sta       <u0035
                    bsr       L0E9F
                    clr       <u0035
                    rts

L0E8B               comb                          Set carry for error
                    ldb       #$2B                Divide by 0 error
                    rts

L0E8F               ldy       <u0082              Get ptr to current pos in temp buffer
                    lda       #$2A                '*'
                    sta       ,y                  Save in temp buffer
                    sta       <u0035              Save as last signal received
L0E98               lbsr      L0C9D
                    clr       <u002F              Clear out ptr to start of 'current' module
                    clr       <u002F+1
L0E9F               ldu       <u0046              Get default ??? tbl ptr
                    stu       <u0044              Save as current ??? tbl ptr
                    bra       L0EE3

L0EA5               ldx       ,x                  Get ptr to module
                    ldb       M$Type,x            Get module type
                    beq       L0EC0               If nothing (un-compiled or errors?), skip ahead
                    cmpb      #Sbrtn+ICode        Basic09 I-Code?
                    bne       L0EB5               No, skip ahead
                    ldb       <$17,x              Get I-Code flag byte
                    lslb                          Shift out the packed bit
                    bmi       L0EC0               If (CRC just made?) flag set, skip ahead
L0EB5               pshs      u                   Preserved U
                    leau      ,x                  Point U to module start
                    os9       F$UnLink            Unlink the I-Code module
                    puls      u                   Restore U
                    bra       L0EDE

L0EC0               tst       <u0035              Any signal code?
                    bne       L0EE3               Yes, skip ahead
                    ldx       ,u                  No, get ptr to module
                    lbsr      L0FB6               Go remove it from workspace pointers (?)
                    ldy       ,x                  Get ptr to module again
                    ldd       <u000A              Get current total size of used I-Code space
                    subd      M$Size,y            Subtract deleted module's size
                    std       <u000A              Save new size of used I-Code space
                    ldd       M$Size,y            Get size of module being removed
                    addd      <u000C              Add to bytes free in I-Code space
                    std       <u000C              Save new # bytes free in I-Code space
                    ldd       <u004A              Get ptr to end of used I-Code space+1
                    subd      M$Size,y            Bump it back to not include the deleted module
                    std       <u004A              Save new ptr to where next added I-Code goes
L0EDE               ldd       #$FFFF              Module ptr unused marker
                    std       [,u]                Mark it
* Compress list of modules in I-Code workspace (get rid of all deleted ones)
L0EE3               ldx       ,--u                Get previous module ptr
                    bne       L0EA5               There is one, go remove it too
                    ldx       <u0004              Get ptr to list of modules is I-Code workspace
                    tfr       x,y                 Move it to Y
L0EEB               ldd       ,x++                Get module ptr
                    cmpd      #$FFFF              Unused one?
                    beq       L0EEB               Yes, try next
L0EF3               std       ,y++                Save it
                    bne       L0EEB               Until a $0000 is hit
                    cmpd      ,y                  Is the next entry a 0 too?
                    bne       L0EF3               No, keep Storing until we hit a 0
                    rts                           Otherwise, return

L0EFD               bsr       L0F6E
                    bcs       L0F02
                    rts

* Set up module header info?
L0F02               pshs      u,x
                    tfr       x,d
                    cmpb      #$FE
                    beq       L0F69
                    ldx       <u000C              Get # bytes free in I-Code workspace for user
                    cmpx      #$00FF              <255 bytes left free?
                    blo       L0F69               Yes, skip ahead
                    leax      <-$1C,x             Bump # bytes free down by 28 bytes
                    ldu       <u004A              Get ptr to current I-code line start
* Clear out entire header of packed RUNB module
* 6809/6309 mod: should use sta (after clra) instead of clr b,u
* Wait until L0F69 is checked-does it need A?
                    ldb       #$FF                Pre-init B for loop below
L0F18               incb                          Next position
                    clr       b,u                 Clear byte
                    cmpb      #$18                Done all $18 bytes?
                    bne       L0F18               No, keep going
* Copy module name to $19
L0F1F               incb                          Bump B to $19
                    leax      -1,x                Bump X back
                    beq       L0F69               If hit 0, exit with memory full error
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
                    stu       [,s]
                    pshs      b
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
                    std       ,x++
                    stx       <u004A              ??? Save end of module ptr?
                    puls      pc,u,x              Restore regs & return

L0F69               ldb       #$20                BASIC09 memory full error (or too many modules)
                    lbra      L0A86

* Entry: Y=Ptr to module name
* Exit:  D=Ptr to string/file name
*          Carry set if adding new module to module list
*          Carry clear if replacing existing module in module list
*        X=Ptr to module directory entry we are adding/changing
*        Y=Ptr to end of filename+1
L0F6E               pshs      u,y                 Preserve regs
                    ldx       <u0004              Get ptr to list of modules in BASIC09 workspace
L0F72               ldy       ,s                  Get ptr to string we are checking for
                    ldu       ,x++                Get ptr to module in workspace
                    beq       L0F8E               None left to check, exit with carry set
                    ldd       M$Name,u            Get offset to name
                    leau      d,u                 Point to name of module
L0F7D               lda       ,y+                 Get char from name we are looking for
                    eora      ,u+
                    anda      #$DF                Force case
                    bne       L0F72               Doesn't match, try next module
                    clra                          Clear carry (module found)
                    tst       -1,u                Was it the last char in existing module name?
                    bpl       L0F7D               No, keep checking
L0F8A               leax      -2,x                Point X to module ptr entry change (or add from F8E)
                    puls      pc,u,d              Restore U, get string ptr into D & exit

L0F8E               coma                          Set carry (flag new module being added)
                    bra       L0F8A               Point to module ptr entry we are going to add

* Check if module is in BASIC09 workspace, try to add if it isn't
* Entry: Y=Ptr to module name to look for (hi-bit terminated with CR on end)
* Exit:  Carry clear if module in workspace
*        Carry set if module NOT in workspace
*        X=Ptr to module ptr entry ($400-$4FF) where module was found
*        D=Ptr to module name
*        Y=Ptr to last char of module name+1
L0F91               bsr       L0F6E               Go see if we should add or replace module
                    bcs       L0F96               Adding new module, skip ahead
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
L0F96               pshs      u,y,x               Preserve regs
                    ldb       1,s                 Get LSB of module directory ptr
                    cmpb      #$FE                At end of table?
                    beq       L0F69               Yes, exit with Memory full error (too many modules)
                    leax      ,y                  Point X to module name
                    clra                          Type/language=wildcard (don't care)
                    os9       F$Link              See if it's already in memory & map it in
                    bcc       L0FB0               Yes, mapped in so skip ahead
                    ldx       2,s                 Get ptr to Module name again
                    clra                          Type/language=wildcard (don't care)
                    os9       F$Load              Try loading it & linking it in
                    bcs       L0FB4               Error, exit with it
L0FB0               stx       2,s                 Save ptr to last byte of module name+1 in Y
                    stu       [,s]                Save ptr to module in module ptr entry
L0FB4               puls      pc,u,y,x            Restore regs & return

* Entry: X=Ptr to module copy we are putting in I-Code workspace (at end of it)
*        Y=???
* Exit:  X=Ptr to where module was moved to
L0FB6               pshs      y,x                 Preserve regs
                    ldd       <u0008              Get ptr to start of I-Code workspace
                    addd      <u000A              Add to total size of used I-Code workspace
                    tfr       d,y                 Move ptr to end of I-Code workspace to Y
                    ldx       ,x                  Get ptr to module we are adding to I-Code workspace
                    sty       [,s]                Save ptr to where it is going over old one on stck
                    ldd       M$Size,x            Get size of module we are adding
                    bsr       L0FE3
                    pshs      y,x,d
                    ldx       <u0004              Get ptr to list of modules in BASIC09 workspace
                    bra       L0FDB

L0FCD               cmpd      2,s
                    blo       L0FDB
                    cmpd      4,s
                    bhi       L0FDB
                    subd      ,s
                    std       -2,x
L0FDB               ldd       ,x++                Get possible module ptr
                    bne       L0FCD               Found one, process
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
L0FE3               pshs      u,y,x,d             Preserve regs
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
L0FF2               lda       ,x                  Get 1st byte of source copy
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

L0FF8               lda       ,y                  Get byte from source location
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
                    bne       L0FF8               No, go bck
                    puls      a
                    sta       ,x
                    leax      1,y
                    stx       2,s
                    leau      1,u
                    tfr       u,d
                    addd      ,s
                    bne       L0FF2
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
                    lbsr      L08D3               Go process debug mode command
                    bcc       L104E               Legit cmd executed, get next debug mode cmd
                    lda       <u0035              Get last signal received
                    bne       L1064               There was one, go check for abort
                    lbsr      L08CC               None, print 'What?'
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
                    lbra      L088F               Done, reset temp buffers & ptrs to defaults

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
                    lbhs      L0F69               No, return with BASIC09 memory full error
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
                    lbsr      L0899
                    ldx       <u005E
                    bsr       L0137               JSR <$24, function 8
                    lbra      L088F               Swap stacks, reset temp buffer, return from there

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
                    lbsr      L0F6E
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
                    rts

L1590               lbsr      L0A9D
                    lbsr      L0EFD
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
                    lbsr      L08D3               Get next command from keyboard & execute it
                    bcc       L15AA               Legit command done, get next one
                    tst       <u0035              Signal received?
                    bne       L15AA               Yes, go process it
                    leax      <L15AA,pc           Point to routine (loop)
                    pshs      x                   Save it (for possible rts address?)
                    ldx       <u0080              Get ptr to start of temp buffer
                    lsl       ,x                  Clear out hi bit in 1st char in temp buffer
                    lsr       ,x
                    lbsr      L1748               ???
                    lbcs      L08CC               If carry set, print 'What?'
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
                    lbsr      L10EE
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
                    lbra      L08CC               Print 'What?' & return from there

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
                    lbsr      L0FE3
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
                    lbsr      L0FE3
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
L1987               lbra      L08CC

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
                    lbsr      L0FE3
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
                    lbsr      L0FB6               ??? Go move module in workspace?
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
                    bne       L1B12
                    rts

L1B19               ldb       ,y
                    clra
                    leay      d,y
                    rts

L1B1F               ldb       -1,y
L1B21               andb      #$04
L1B23               lda       #$60
                    pshs      d
                    lda       #$85
                    sta       -1,y
                    ldx       <u0062
                    ldd       -3,x
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
                    tfr       x,d
                    subd      <u0062
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
                    bcs       L1BD4
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
                    leax      d,x
                    stx       4,s                 Modify RTS address
                    puls      pc,x,d              restore X & D and RTS to new address

* 2 byte/entry vector table (JMP >$1E calls have there function byte after
*  the JMP containing the offset to which of these entries to uses)
L1CB5               fdb       L1F9E-L1CB5         $00 function
                    fdb       L2430-L1CB5         $02 function
                    fdb       L252A-L1CB5         $04 function
                    fdb       L2508-L1CB5         $06 function
                    fdb       L24BD-L1CB5         $08 function
                    fdb       L1E29-L1CB5         $0A function

* Data of some sort: Appears to be special symbols
L1CD0               fdb       33                  (# of entries-33)
                    fcb       $03                 (# bytes to skip to start of next?)

L1CD3               fcb       L2368-L239D
                    fcb       $d9,$0a             (token & type of operator???)
                    fcs       '<>'

                    fcb       L2368-L239D
                    fcb       $d9,$0a
                    fcs       '><'

                    fcb       L2368-L239D
                    fcb       $e4,$0a
                    fcs       '<='

                    fcb       L2368-L239D
                    fcb       $e4,$0a
                    fcs       '=<'

                    fcb       L2368-L239D
                    fcb       $e1,$0a
                    fcs       '>='

                    fcb       L2368-L239D
                    fcb       $e1,$0a
                    fcs       '=>'

                    fcb       L2368-L239D
                    fcb       $52,$08
                    fcs       ':='

                    fcb       L2368-L239D
                    fcb       $f1,$05
                    fcs       '**'

                    fcb       L2368-L239D
                    fcb       $38,$01
                    fcs       '(*'

                    fcb       L2368-L239D
                    fcb       $3e,$02
                    fcs       '\'

                    fcb       L2368-L239D
                    fcb       $d3,$0a
                    fcs       '>'

                    fcb       L2368-L239D
                    fcb       $d6,$0a
                    fcs       '<'

                    fcb       L2368-L239D
                    fcb       $dd,$09
                    fcs       '='

                    fcb       L2368-L239D
                    fcb       $e7,$05
                    fcs       '+'

                    fcb       L2368-L239D
                    fcb       $ea,$05
                    fcs       '-'

                    fcb       L2368-L239D
                    fcb       $ec,$05
                    fcs       '*'

                    fcb       L2368-L239D
                    fcb       $ee,$05
                    fcs       '/'

                    fcb       L2368-L239D
                    fcb       $f0,$05
                    fcs       '^'

                    fcb       L2368-L239D
                    fcb       $4c,$0c
                    fcs       ':'

                    fcb       L2368-L239D
                    fcb       $4f,$0c
                    fcs       '['

                    fcb       L2368-L239D
                    fcb       $50,$0c
                    fcs       ']'

                    fcb       L2368-L239D
                    fcb       $51,$0c
                    fcs       ';'

                    fcb       L2368-L239D
                    fcb       $54,$0b
                    fcs       '#'

                    fcb       L2368-L239D
                    fcb       $26,$01
                    fcs       '?'

                    fcb       L2368-L239D
                    fcb       $37,$01
                    fcs       '!'

                    fcb       L233E-L239D         Recurse to the search routine again (eat LF)
                    fcb       $00,$0c
                    fcb       $80+C$LF            Line feed

                    fcb       L2368-L239D
                    fcb       $4b,$0c
                    fcs       ','

                    fcb       L2368-L239D
                    fcb       $4d,$0c
                    fcs       '('

                    fcb       L2368-L239D
                    fcb       $4e,$0c
                    fcs       ')'

                    fcb       L2371-L239D
                    fcb       $89,$0c
                    fcs       '.'

                    fcb       L23BE-L239D
                    fcb       $90,$06
                    fcs       '"'

                    fcb       L239D-L239D
                    fcb       $91,$06
                    fcs       '$'

                    fcb       L2368-L239D
                    fcb       $3f,$02
                    fcb       $80+C$CR            Carriage return

* Jump table for type 1 commands (see L0140)
*                           Command  Token
L1D60               fdb       L211B-L1D60         ???      0   Illegal statement construction error
                    fdb       L1E82-L1D60         PARAM    1
                    fdb       L1E72-L1D60         TYPE     2
                    fdb       L1E82-L1D60         DIM      3
                    fdb       L1ED3-L1D60         DATA     4
                    fdb       L2029-L1D60         STOP     5
                    fdb       L210B-L1D60         BYE      6
                    fdb       L210B-L1D60         TRON     7
                    fdb       L210B-L1D60         TROFF    8
                    fdb       L2029-L1D60         PAUSE    9
                    fdb       L210B-L1D60         DEG      A
                    fdb       L210B-L1D60         RAD      B
                    fdb       L210B-L1D60         RETURN   C
                    fdb       L2123-L1D60         LET      D
                    fdb       L211B-L1D60         ???      E   Illegal Statement Construction err
                    fdb       L1EE1-L1D60         POKE     F
                    fdb       L1EEA-L1D60         IF       10
                    fdb       L1EFF-L1D60         ELSE     11
                    fdb       L210B-L1D60         ENDIF    12
                    fdb       L1F03-L1D60         FOR      13
                    fdb       L1F24-L1D60         NEXT     14
                    fdb       L1F2E-L1D60         WHILE    15
                    fdb       L1F3D-L1D60         ENDWHILE 16
                    fdb       L210B-L1D60         REPEAT   17
                    fdb       L1F39-L1D60         UNTIL    18
                    fdb       L210B-L1D60         LOOP     19
                    fdb       L1F3D-L1D60         ENDLOOP  1A
                    fdb       L1F41-L1D60         EXITIF   1B
                    fdb       L1F3D-L1D60         ENDEXIT  1C
                    fdb       L1F4C-L1D60         ON       1D
                    fdb       L213C-L1D60         ERROR    1E
                    fdb       L1F87-L1D60         GOTO     1F
                    fdb       L211B-L1D60         ???      20  Illegal Statement Construction err
                    fdb       L1F87-L1D60         GOSUB    21
                    fdb       L211B-L1D60         ???      22  Illegal Statement Construction err
                    fdb       L1FB4-L1D60         RUN      23
                    fdb       L213C-L1D60         KILL     24
                    fdb       L1FF6-L1D60         INPUT    25
                    fdb       L2029-L1D60         PRINT    26 (Also '?')
                    fdb       L213C-L1D60         CHD      27
                    fdb       L213C-L1D60         CHX      28
                    fdb       L2093-L1D60         CREATE   29
                    fdb       L2093-L1D60         OPEN     2A
                    fdb       L2083-L1D60         SEEK     2B
                    fdb       L205A-L1D60         READ     2C
                    fdb       L2067-L1D60         WRITE    2D
                    fdb       L2071-L1D60         GET      2E
                    fdb       L2071-L1D60         PUT      2F
                    fdb       L20D2-L1D60         CLOSE    30
                    fdb       L20DC-L1D60         RESTORE  31
                    fdb       L213C-L1D60         DELETE   32
                    fdb       L213C-L1D60         CHAIN    33
                    fdb       L213C-L1D60         SHELL    34
                    fdb       L20E0-L1D60         BASE     35
                    fdb       L20E0-L1D60         ???      36
                    fdb       L20F8-L1D60         REM      37 (Also '!')
                    fdb       L20F8-L1D60         (*       38
                    fdb       L2029-L1D60         END      39

L1DD4               lda       <u000A+1            Get LSB of # bytes used by all programs (not data)
L1DD6               pshs      a                   Save it
                    ldx       <u00A7
                    lda       #C$CR               Byte to look for
L1DDC               lsl       ,x                  Clear out high bit? (if so, use AIM instead)
                    lsr       ,x
                    cmpa      ,x+                 Find byte we want?
                    bne       L1DDC               No, keep looking
                    ldx       <u00A7              Get ptr to end of string name+1
                    bsr       L1E1F               Print string out
                    ldd       <u00B9
                    subd      <u00A7
                    pshs      b
                    ldx       <u00AF
                    stx       <u00AB
                    ldy       <u00A7
                    lda       #$3D
                    lbsr      L2415
                    lbsr      L20F8
                    lbsr      L2415
                    lda       #C$SPAC             Block copy Spaces (TFM)
                    ldx       <u0080              Get start address
L1E04               sta       ,x+                 Fill with spaces
                    dec       ,s
                    bpl       L1E04
                    ldd       #$5E0D              Add ^ (CR) (part of debug?)
                    std       -$01,x
                    ldx       <u0080              Get start ptr again
                    bsr       L1E1F               Go print the debug line
                    puls      d
                    bsr       L1CC1
                    ldx       <u0046
                    stx       <u0044
L1CC7               jsr       <u001B              ??? Reset temp buff to defaults, SP restore from B7
                    fcb       $06

L1CC1               jsr       <u001B              Print error code to screen
                    fcb       $02

L1E1F               ldy       #$0100              Size=256 bytes
                    lda       <u002E              Get path
                    os9       I$WritLn            Write it & return
                    rts

L1CC4               jsr       <u001B              ??? Save SP @ <u00B7, muck around
                    fcb       $04

L1E29               puls      x
                    bsr       L1CC4
                    lbsr      L1F90
                    lbsr      L214C
                    sty       <u00A7
                    ldx       <u00AB
                    stx       <u00AF
L1E3B               bsr       L1E4C               Go process command/variable/constant
                    lda       <u00A3              Get token
                    lbsr      L2415               Add to I-code line bffr & make sure no overflow
                    cmpa      #$3E                Was it a $3E?
                    beq       L1E3B               Yes, go get next one
                    cmpa      #$3F                Was it a $3F?
                    bne       L1DD4               No, do something
                    bra       L1CC7               Yes, Call <u001B, function 6

L1E4C               lbsr      L233E               Go find command (or variable/constant name)
                    lda       <u00A4              Get command type
                    cmpa      #$01                (Is it a normal command?)
                    bne       L1E62               No, check next
* Command type 1 goes here
                    ldb       <u00A3              Get entry # (token) into JMP offset table
                    clra                          Make 16 bit for signed jump
                    ifne      H6309
                    lsld                          Multiply by 2 (2 bytes/entry)
                    else
                    lslb
                    rola
                    endc
                    leax      >L1D60,pc           Point to Basic09 COMMANDS vector table
                    ldd       d,x                 Get offset
                    jmp       d,x                 Execute command's routine

L1E62               cmpa      #$02                Command type 2?
                    lbne      L2126               No, go process functions, etc.
* Command type 2 goes here
L1E68               pshs      x
                    ldx       <u00AB
                    leax      -$01,x
                    stx       <u00AB
                    puls      pc,x

L1E72               lbsr      L2167
                    cmpa      #$DD
                    lbne      L211F
                    bsr       L1E68
                    lda       #$53
                    lbsr      L2415

L1E82               lbsr      L2167
                    cmpa      #$4D
                    bne       L1E9B
                    lbsr      L216E
                    bne       L1E96
                    lbsr      L216E
                    bne       L1E96
                    lbsr      L216E
L1E96               lbsr      L22BF
                    bsr       L1EC9
L1E9B               lbsr      L21A1
                    beq       L1E82
                    cmpa      #$4C
                    bne       L1EC3
                    bsr       L1EC9
                    ldb       <u00A4              Get token
                    beq       L1EC1               If 0, skip ahead
                    cmpb      #$03
                    bne       L1ECC
                    cmpa      #$44
                    bne       L1EC1
                    bsr       L1EC9
                    cmpa      #$4F
                    bne       L1EC3
                    lbsr      L216E
                    cmpa      #$50
                    bne       L1ECC
L1EC1               bsr       L1EC9
L1EC3               cmpa      #$51
                    beq       L1E82
                    bra       L1E68

L1EC9               lbra      L233E

L1ECC               lda       #$18
                    bra       L1F36

L1ED0               lbsr      L2415
L1ED3               bsr       L1F1D
                    lbsr      L21A1
                    beq       L1ED0
L1EDA               lda       #$55
L1EDC               lbsr      L2415
                    bra       L1F2B

L1EE1               lbsr      L213C
                    lbsr      L21A6
                    lbra      L2139

L1EEA               bsr       L1F39
                    cmpa      #$45
                    bne       L1EFB
                    lbsr      L2415
                    lbsr      L214C
                    bcc       L1F3F
                    lbra      L1E4C

L1EFB               lda       #$26
                    bra       L1F36

L1EFF               bsr       L1F2B
                    bra       L1F49

L1F03               lbsr      L2193
                    lbsr      L212D
                    lda       <u00A3
                    cmpa      #$46
                    bne       L1F20
                    bsr       L1F1B
                    lda       <u00A3
                    cmpa      #$47
                    bne       L1EDA
                    bsr       L1F1B
                    bra       L1EDA

L1F1B               bsr       L1EDC
L1F1D               lbra      L213C

L1F20               lda       #$27
                    bra       L1F36

L1F24               lbsr      L2193
                    bsr       L1F2B
                    bsr       L1F2B
L1F2B               lbra      L2176

L1F2E               bsr       L1F39
                    cmpa      #$48
                    beq       L1F47
                    lda       #$1F
L1F36               lbra      L1DD6

L1F39               bsr       L1F1D
                    bra       L1EDA

L1F3D               bsr       L1F2B
L1F3F               bra       L1F8D

L1F41               bsr       L1F39
                    cmpa      #$45
                    bne       L1EFB
L1F47               bsr       L1FB1
L1F49               lbra      L1E4C

L1F4C               ldd       <u00AB
                    pshs      y,d
                    lbsr      L233E
                    cmpa      #$1E
                    bne       L1F60
                    leas      $04,s
                    bsr       L1F8D
                    cmpa      #$1F
                    beq       L1F8A
                    rts

L1F60               puls      y,d
                    std       <u00AB
                    bsr       L1F39
                    ldx       <u00AB
                    leax      -1,x
                    pshs      x
                    cmpa      #$1F
                    beq       L1F7C
                    cmpa      #$21
                    beq       L1F7C
                    lda       #$21
                    bra       L1F36

L1F78               bsr       L1FB1
                    lda       #$3A
L1F7C               inc       [,s]
                    bsr       L1F8A
                    lbsr      L21A1
                    beq       L1F78
                    puls      pc,x

L1F87               lbsr      L210E
L1F8A               lbsr      L2156
L1F8D               lbra      L210B

L1F90               sty       <u00A7              Save ptr to end of string name
                    ldx       <u004A              ??? Get ptr to start of I-code
                    stx       <u00AF              Save it
                    stx       <u00AB              And again as current I-code line end ptr
                    clr       <u00BB              Clear <u00BB & <u00BC
                    clr       <u00BC
L1FF5               rts

* Entry: Y=Ptr to end of string name+1
L1F9E               bsr       L1F90               Set up some ptrs
                    inc       <u00A0              ??? Set flag? (think it is 3-way flag)
                    lbsr      L210B               ??? Go process source line? (A returns token)
                    bsr       L1FC0               Go check for "(" command grouping start
                    clr       <u00A0              ??? Clear flag?
                    lda       <u00A3              Get 1st byte from command table (token)?
                    cmpa      #$3F                Was it a carriage return token?
                    lbne      L1DD4               No, go process token
L1FB1               lbra      L2415               Add token to I-code buffer, check for overflow

L1FB4               lbsr      L210E
                    pshs      x
                    lbsr      L2193
                    ldb       #$23
                    stb       [,s++]
* Check for "(" token (start of group of operations)
L1FC0               cmpa      #$4D                Token $4D  - "(" group start token?
                    bne       L1FF5               No, return
* Process "( )" command grouping
L1FC4               bsr       L1FB1               No, go call L2415 (X=Tble ptr, D=Token/type bytes?)
                    ldd       <u00AB              Get ptr to current I-code line end
                    pshs      y,d                 Save with source ptr(?)
                    lbsr      L233E               Process next command/line #/variable name
                    ldd       #$0005              Token types 0 & 5
                    cmpa      <u00A4              Just processed command token type 0?
                    beq       L1FD8               Yes, skip ahead
                    stb       <u00A4              No, replace with type 5 (AND,OR,XOR,NOT)
                    bra       L1FDB               Skip ahead

L1FD8               lbsr      L2182               Go check for Illegal Statement Construction
L1FDB               puls      y,d                 Get ptr to last char+1 & current I-code line end
                    std       <u00AB              Save original I-code line end ptr
                    ldb       <u00A4              Get token type
                    cmpb      #$05                Type 5 (AND,OR,XOR,NOT)?
                    beq       L1FE8               Yes, skip ahead
                    lbsr      L225D               No, go force token $E & check for I-code overflow
L1FE8               lbsr      L2314
                    lbsr      L21A1
                    beq       L1FC4
                    pshs      a
                    lbra      L22F7

L1FF6               sty       <u00A9
                    lbsr      L2186
                    bne       L2007
                    sty       <u00A9
                    bsr       L2022
                    bsr       L1FB1
                    bsr       L1F8D
L2007               ldy       <u00A9
                    cmpa      #$90
                    bne       L201A
                    lbsr      L233E
                    lbsr      L1F8D
L2014               bsr       L2022
L2016               lda       #$4B
                    bsr       L2080
L201A               bsr       L2073
                    lbsr      L219B
                    beq       L2016
L2021               rts

L2022               lbsr      L219B
                    beq       L2021
                    bra       L207D

L2029               sty       <u00A9
                    lbsr      L2186
                    beq       L203A
                    cmpa      #$49
                    beq       L203E
L2035               ldy       <u00A9
                    bra       L2045

L203A               cmpa      #$49
                    bne       L2054
L203E               lbsr      L2139
                    bra       L2054

L2043               bsr       L2080
L2045               lbsr      L245D
                    cmpa      #C$CR
L204A               lbeq      L210B
                    cmpa      #'\
                    beq       L204A
                    bsr       L2085
L2054               lbsr      L219B
                    beq       L2043
                    rts

L205A               sty       <u00A9
                    lbsr      L2186
                    beq       L2014
                    ldy       <u00A9
                    bra       L201A

L2067               sty       <u00A9
                    lbsr      L2186
                    beq       L2054
                    bra       L2035
L2071               bsr       L2078
L2073               inc       <u00BC
                    lbra      L2180

L2078               lbsr      L2186
                    bne       L20D7
L207D               lbsr      L21A6
L2080               lbra      L2415

L2083               bsr       L2078
L2085               lbra      L213C

* Data table for file access modes?
L2088               fcb       $2c,%00000001       Read mode?
                    fcb       $2d,%00000010       Write mode?
                    fcb       $f7,%00000011       Update mode?
                    fcb       $f8,%00000100       Execution dir mode?
                    fcb       $f9,%10000000       Directory mode?
                    fcb       $00                 End of table marker

L2093               lbsr      L233E
                    cmpa      #$54
                    bne       L20D7
                    bsr       L2073
                    bsr       L207D
                    bsr       L2085
                    lda       <u00A3              Get token
                    cmpa      #$4C
                    bne       L2114
                    lda       #$4A
                    bsr       L2080
                    clr       ,-s
L20AC               bsr       L210B
                    leax      <L2088,pc           Point to table (modes?)
L20B1               cmpa      ,x++
                    bhi       L20B1               We need higher entry #, keep looking
                    bne       L20C7               Illegal, return error
                    ldb       -1,x                Get mode (read/write/update)???
                    orb       ,s                  Merge with mode on stack???
                    stb       ,s                  Save new mode???
                    bsr       L210B
                    cmpa      #$E7
                    beq       L20AC
                    lda       ,s+
                    bne       L2080
L20C7               lda       #$0F                Illegal mode error?
                    bra       L20D9

L20CB               lbsr      L21A1
                    bne       L2114
                    bsr       L2080
L20D2               lbsr      L2186
                    beq       L20CB
L20D7               lda       #$1C                Missing Path Number error
L20D9               lbra      L1DD6

L20DC               bsr       L214C
                    bra       L210B

L20E0               lbsr      L245D
                    leay      1,y
                    suba      #$30                Convert ASCII digit to binary
                    beq       L210B               If 0, skip ahead
                    cmpa      #1
                    lbne      L21C9               If anything but 0 or 1, Illegal operand error
                    bsr       L210E               If 1, skip ahead
                    lda       #$36
                    lbsr      L2415
                    bra       L210B

L20F8               ldx       <u00AB              Get ptr to current I-Code end
                    lbsr      L245D
                    clra
L20FE               lbsr      L2415
                    inc       ,x
                    lda       ,y+                 Get char
                    cmpa      #C$CR               CR?
                    bne       L20FE               Nope, keep going
                    leay      -1,y                Bump ptr back to CR

L210B               lbsr      L233E               Check for command/constant/variable names
L210E               ldx       <u00AD              Get ptr to end of I-code line
                    stx       <u00AB              Make it the current end ptr
                    lda       <u00A3              Get token & return
L2114               rts

L2115               lda       <u00A4              Get token type
                    beq       L2114               If 0, return
L211B               lda       #12                 Exit with Illegal Statement Construction error
                    bra       L20D9

L211F               lda       #$1B                Missing Assignment Statement error
L2121               bra       L20D9

L2123               lbsr      L233E

* Token types >2 go here
L2126               bsr       L2115
                    inc       <u00BC
                    lbsr      L21FC
L212D               lda       <u00A3              Get token
                    cmpa      #$52                ??? Is it ':='?
                    beq       L2139               Yes, skip ahead
                    cmpa      #$DD                ??? Is it '='?
                    bne       L211F               No, exit with Missing Assignment statement error
                    lda       #$53                Token=$53
L2139               lbsr      L2415               Go append to I-Code buffer
L213C               lda       #$39
L213E               ldx       <u0044
                    clrb
                    lbsr      L22BA
L2144               bsr       L21B4
                    lbsr      L2262
                    bcc       L2144
L214B               rts

L214C               lbsr      L245D
                    lbsr      L246E
                    bcs       L214B
                    lda       #$3A                Go append $3A token to I-Code buffer
L2156               bsr       L217D
                    lbsr      L23A6
                    beq       L2163
                    ldd       ,x
                    lbgt      L240C
L2163               lda       #$10                Illegal Number error
                    bra       L2121

L2167               bsr       L216B
                    bsr       L2115
L216B               lbra      L233E

L216E               lda       #$8E
                    bsr       L2156
                    bsr       L216B
                    bra       L21A1

L2176               clra
                    bsr       L217D
                    bsr       L217D
                    bra       L218E

L217D               lbra      L2415

L2180               bsr       L216B
L2182               bsr       L2115
                    bra       L21FC

L2186               bsr       L210B
                    cmpa      #$54
                    bne       L2192
                    bsr       L2139
* 6809/6309 MOD: If A not required, CLRA
L218E               lda       <u00A3
                    orcc      #Zero
L2192               rts

L2193               bsr       L216B
                    lbsr      L2115
L2198               lbra      L210B

L219B               lda       <u00A3
                    cmpa      #$51
                    beq       L21A5
L21A1               lda       <u00A3
                    cmpa      #$4B
L21A5               rts

L21A6               bsr       L21A1
                    beq       L21A5
                    lda       #$1D
                    bra       L21CB

L21AE               clrb
                    bsr       L21F5
                    lbsr      L210E
L21B4               bsr       L21EA
                    bsr       L21CE
                    cmpa      #$4D
                    beq       L21AE
                    ldb       <u00A4
                    cmpb      #$06
                    beq       L2198
                    cmpb      #$04
                    bne       L2182
                    lbra      L22CA

L21C9               lda       #$12                Illegal operand error
L21CB               lbra      L1DD6

L21CE               cmpa      #$CD
                    beq       L21E3
                    cmpa      #$EA
                    bne       L21A5
                    lda       ,y
                    lbsr      L246E
                    bcc       L21ED
                    cmpa      #$2E
                    beq       L21ED
                    lda       #$CE
L21E3               ldb       #$07
                    bsr       L21F5
                    lbsr      L210E
L21EA               lbra      L233E

L21ED               leay      -1,y
                    lbsr      L1E68
                    lbra      L237A

L21F5               ldx       <u0044
                    std       ,--x
                    stx       <u0044
                    rts

L21FC               ldd       #$8500
L21FF               pshs      d
                    ldd       <u00A1
                    bsr       L21F5
                    puls      d
                    bsr       L21F5
                    lbsr      L210E
                    lbsr      L210B
                    clrb
                    cmpa      #$4D
                    beq       L2226
L2214               cmpa      #$89
                    bne       L2247
                    bsr       L2257
                    bsr       L2247
                    bsr       L21EA
                    lbsr      L2115
                    ldd       #$8900
                    bra       L21FF

L2226               bsr       L2257
                    incb
                    pshs      b
                    lbsr      L2314
                    lbsr      L21A1
                    bne       L223E
                    ldb       ,s+
                    cmpb      #$03
                    blo       L2226
                    lda       #$2A
                    lbra      L1DD6

L223E               bsr       L22BF
                    lbsr      L210B
                    puls      b
                    bra       L2214

L2247               clr       <u00BC
                    ldx       <u0044
                    addb      ,x++
                    lbsr      L2413
                    ldd       ,x++
                    stx       <u0044
                    lbra      L240C

L2257               tst       <u00BC
                    beq       L228A
                    clr       <u00BC
L225D               lda       #$0E
L225F               lbra      L2415

L2262               ldb       <u00A3              Get token
                    clra
                    cmpb      #$4E
                    beq       L228B
                    tstb
                    bpl       L2273
                    bsr       L1CCD
                    bita      #$08
                    bne       L228B
L2273               ldx       <u0044
L2275               ldd       ,x++
                    cmpa      #$4D
                    beq       L22C5
                    bsr       L225F
                    tstb
                    bne       L2275
                    cmpa      #$39
                    bne       L2287
                    lbsr      L1E68
L2287               stx       <u0044
                    coma
L228A               rts

L228B               anda      #$07
                    tfr       a,b
                    ldx       <u0044
                    bra       L2297

L2293               lda       ,x++
                    bsr       L230F
L2297               cmpb      1,x
                    blo       L2293
                    bhi       L22B8
                    cmpb      #6
                    beq       L22B8
                    tstb
                    bne       L2293
                    lda       ,x++
                    cmpa      #$4D
                    bne       L22B0
                    stx       <u0044
                    bsr       L22FE
                    bra       L2262

L22B0               cmpa      #$39
                    beq       L2307
                    bsr       L230F
                    bra       L2287

L22B8               lda       <u00A3              Get token
L22BA               std       ,--x
                    stx       <u0044
L22BE               rts

L22BF               lda       <u00A3              Get token
                    cmpa      #$4E                ??? ^ or ** (power)?
                    beq       L22BE               Yes, return
L22C5               lda       #$25
L22C7               lbra      L1DD6

L1CCD               jsr       <u001B
                    fcb       $12

L22CA               lbsr      L1E68
                    lda       <u00A3              Get token
                    pshs      a                   Save it
                    bsr       L22FE
                    ldb       ,s
                    bsr       L1CCD
                    leax      <L22F7,pc           Point to routine
                    pshs      x
                    anda      #$03
                    beq       L230B
                    cmpa      #2
                    beq       L231B
                    bhi       L2322
                    ldb       2,s
                    cmpb      #$92
                    beq       L2331
                    cmpb      #$94
                    beq       L2331
                    cmpb      #$BE
                    beq       L2326
                    bra       L2312

L22F7               bsr       L22BF
                    puls      a
                    lbsr      L2415
L22FE               lbra      L210B

L2301               lda       <u00A3
                    cmpa      #$4D
                    beq       L22BE
L2307               lda       #$22
                    bra       L22C7

L230B               leas      2,s
                    puls      a
L230F               lbra      L2415

L2312               bsr       L2301
L2314               clra
                    lbsr      L213E
                    lbra      L1E68

L231B               bsr       L2312
L231D               lbsr      L21A6
                    bra       L2314

L2322               bsr       L231B
                    bra       L231D

L2326               bsr       L2301
                    bsr       L22FE
                    cmpa      #$54
                    beq       L2314
                    lbra      L20D7

L2331               bsr       L2301
                    incb
                    lbsr      L2413
                    lbra      L2180

L233A               lda       #$0A                Unrecognized symbol error
                    bra       L22C7

* Search for operator's loop? (An LF is eaten and it returns here)
L233E               ldd       <u00AB              Get current I-code line's end ptr
                    std       <u00AD              Dupe it here
                    lbsr      L245D               Find first non-space/LF char
                    sty       <u00B9              Save ptr to it
                    lbsr      L2432               Check for variable name
                    lbne      L23E1               None, check for command names
                    lda       ,y                  Get first char of possible variable name
                    lbsr      L246E               Does it start with a number (0-9)?
                    bcc       L237A               Yes, skip ahead
                    leax      >L1CD0+3,pc         No, point to Operator's table
                    lda       #$80                Get high bit mask to check for end of entry
                    lbsr      L252A               Go find entry
                    beq       L233A               None, exit with Unrecognized symbol error
                    ldb       ,x                  Get offset
                    leau      <L239D,pc           Point to base routine
                    jmp       b,u                 Go to subroutine

* '.' goes here
L2371               lda       ,y                  Get char from source
                    lbsr      L246E
                    bcs       L2368
                    leay      -1,y
* Starts with numeric (0-9) value
L237A               bsr       L23A6
                    bne       L238F
                    ldd       #$8F05              Token=$85, count=5
L2381               sta       <u00A3
L2383               bsr       L23D6
                    lda       ,x+
                    decb
                    bpl       L2383
                    lda       #6
                    sta       <u00A4              Save type (?) as 6
                    rts

L238F               ldd       #$8E02
                    tst       ,x
                    bne       L2381
                    ldd       #$8D01
                    leax      1,x
                    bra       L2381

* Almost all operators come here
L2368               ldd       1,x                 Get the 2 mystery bytes
* Command found comes here with D=2 byte # in command table
L236A               std       <u00A3              Save token & type byte
                    bra       L2415

* '$' goes here
L239D               leay      -1,y                Bump source ptr back by 1
                    bsr       L23A6
                    ldd       #$9102
                    bra       L2381

L23A6               lbsr      L245D               Find 1st non-space/lf char
                    leax      ,y                  Point x to the char
                    ldy       <u0044
                    bsr       L1CCA               Call vector <2A, function 00
                    exg       x,y
                    bcs       L23BA               If error from vector, illegal literal error
                    lda       ,x+
                    cmpa      #2
                    rts

L1CCA               jsr       <u002A
                    fcb       $00

L23BA               lda       #$16                Illegal literal error
                    bra       L23DA

* '"' goes here
L23BE               bsr       L2368
                    bra       L23C4

L23C2               bsr       L2415
L23C4               lda       ,y+                 Get char from source
                    cmpa      #C$CR               End of line already?
                    beq       L23D8               Yes, no ending quote error
                    cmpa      #'"                 Is it the quote?
                    bne       L23C2               No, keep looking
                    cmpa      ,y+                 Double quote?
                    beq       L23C2               Yes, do something
                    leay      -1,y                No, set src ptr back to next char
                    lda       #$FF                Go save $FF at this point in I-code line
L23D6               bra       L2415

L23D8               lda       #$29                No Ending Quote error
L23DA               lbra      L1DD6               Deal with error

L23DD               lda       #$31                Undefined Variable error
                    bra       L23DA

* Check for command names
L23E1               ldx       <u009E              Get ptr to commmands token list
                    lbsr      L2528               Go find command
                    beq       L23EF               No command found, skip ahead
                    stx       <u00A1              Save ptr to command's 2 byte # in table
                    ldd       ,x                  Get 2 byte # from command's entry in table
L23EC               std       <u00A3              Save token & type bytes
                    bra       L2415               Go check size of I-code line

L23EF               tst       <u00A0
                    bmi       L23DD
                    ldx       <u0062
                    lbsr      L2528
                    bne       L2401
                    tst       <u00A0
                    bne       L23DD
                    lbsr      L2494
L2401               ldd       #$8500
                    bsr       L23EC               Go append token $85, type 0 & check for overflow
                    tfr       x,d
                    subd      <u0062
                    std       <u00A1
L240C               bsr       L2415
                    bsr       L2413
                    lda       <u00A3              Get token & return
                    rts

L2413               tfr       b,a
L2415               pshs      x,d                 Preserve Table ptr & 2 mystery bytes
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

L2430               bsr       L245D               Search for 1st non-space/LF char
L2432               pshs      y                   Save ptr to it on stack
                    ldb       #2                  ??? Flag to indicate non-variable name
                    stb       <u00A5
                    clrb                          Set variable name size to 0
                    bsr       L2478               Check if it is an alphabetic char or underscore
                    bcs       L2459               Nope, skip ahead
                    leay      1,y                 Yes, point to next char
L243F               incb                          Bump up variable name size
                    lda       ,y+                 Get next char
                    bsr       L246A               Check if it is a letter, number or _
                    bcc       L243F               Yes, check next one
                    cmpa      #'$                 Is it a string indicator?
                    bne       L2451               No, skip ahead
                    incb                          Bump up variable name size to include '$'
                    lda       #4                  ??? Flag to indicate variable name?
                    sta       <u00A5
                    bra       L2453               Skip ahead

L2451               leay      -1,y                Bump source ptr back by 1
L2453               lda       #$80                Get high bit (OIM on 6309)
                    ora       -1,y                Set high bit on last char of variable name
                    sta       -1,y                Save it back
L2459               stb       <u00A6              Save size of variable name
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
                    bls       L2491               Yes, exit with carry clear
                    bra       L248E               No, exit with carry set

* Check if char is a letter (or underscore)
* Entry: A=last char gotten (non-space/Lf)
* Exit: Carry clear if A-Z, a-z or '_'
*       Carry set if anything else
L2478               anda      #$7F                Take out any high bit that might exist
                    cmpa      #'A                 Is it lower than a 'A'
                    blo       L2493               Yes, skip ahead (carry set)
                    cmpa      #'Z                 Is it an uppercase letter?
                    bls       L2491               Yes, clear carry & exit
                    cmpa      #'_                 Is it an underscore?
                    beq       L2493               Yes, exit (carry is clear)
                    cmpa      #'a                 Is it a [,\,],^ or inverted quote ($60)?
                    blo       L2493               Yes, skip ahead (carry set)
                    cmpa      #'z                 Is it a lowercase letter?
                    bls       L2491               Yes, exit
L248E               orcc      #$01                Error, non-alpha char
                    rts

L2491               andcc     #$FE                No error, alphabetic char
L2493               rts

L2494               ldx       <u0062
                    ldd       -3,x
                    addd      #1                  INCD
                    std       -3,x
                    ldb       <u00A6              Get size of var name/ (or string?)
                    clra                          D=Size
                    addd      #3                  Add 3 to size
                    sty       <u00A9
                    bsr       L24EE
                    pshs      y
                    lda       <u00A5
                    clrb
                    std       ,y++
                    stb       ,y+
                    ldx       <u00A9
L24B3               lda       ,x+
                    sta       ,y+
                    bpl       L24B3
                    leay      ,x
                    puls      pc,x

L24BD               pshs      u,d
                    ldd       <u000C
                    subd      ,s
                    bcc       L24CA
                    lda       #$20
                    lbra      L1DD6

L24CA               std       <u000C
                    ldd       <u0066
                    subd      ,s
                    std       <u0066
                    ldu       <u00DA
                    ldd       <u00DA
                    subd      ,s
                    std       <u00DA
                    tfr       d,y
                    ldd       <u0066
                    subd      <u00DA
                    addd      <u0068
                    bsr       L2508
                    ldd       <u0068
                    addd      ,s++
                    std       <u0068
                    leax      ,u
                    puls      pc,u

L24EE               pshs      u,d
                    bsr       L24BD
                    subd      ,s
                    std       <u0068
                    leau      ,x
                    leax      $03,y
                    stx       <u0062
                    ldd       <u0064
                    bsr       L2508
                    addd      ,s++
                    std       <u0064
                    leax      ,u
                    puls      pc,u

L2508               pshs      x,d
                    leax      d,u
                    pshs      x
L250E               bitb      #$03
                    beq       L251F
                    lda       ,u+
                    sta       ,y+
                    decb
                    bra       L250E

L2519               pulu      x,d
                    std       ,y++
                    stx       ,y++
L251F               cmpu      ,s
                    blo       L2519
                    clr       ,s++
                    puls      pc,x,d

* Entry point from L23E1
L2528               lda       #%00100000          Bit pattern to test for end of entry
* Entry: X=Table ptr (ex. command table)
*        Y=Source ptr
*        A=Mask to check for end of entry (%10000000)
*        U=??? (just preserved)
* Exit:  X=Ptr to 2 byte # before matching text string
*        Y=Ptr to byte after matching entry in source
*        Zero flag set if no matching entry found
L252A               pshs      u,y,x,a             Save everything on stack
                    ldu       -3,x                Get # of entries in table
                    ldb       -1,x                Get # bytes to skip to next entry
* Loop to find entry (or until table runs out)
L2530               stx       1,s                 Save new table ptr
                    cmpu      #$0000              Done all entries?
                    beq       L2558               Yes, exit
                    leau      -1,u                Bump # entries left down
                    ldy       3,s                 Get source ptr
                    leax      b,x                 Point to next entry
L253F               lda       ,x+                 Get byte from table
                    eora      ,y+                 Match byte from source?
                    beq       L2551               Yes, skip ahead
                    cmpa      ,s                  Just high bit set (end of entry marker)?
                    beq       L2551               Yes, skip ahead
                    leax      -1,x                No, bump table ptr back by 1
L254B               lda       ,x+                 Get byte
                    bpl       L254B               Keep reading until high bit found (end of entry)
                    bra       L2530               Go loop to check this entry

* Found a byte match (with or w/o high bit)
L2551               tst       -1,x                Check the byte
                    bpl       L253F               If not at end of entry, keep looking
                    sty       3,s                 Entry matched, save new source ptr
L2558               puls      pc,u,y,x,a          Restore regs & return

L255A               pshs      x,d                 Preserve regs
                    ldb       [<$04,s]            Get table entry #
                    leax      <L256A,pc           Point to vector table
                    ldd       b,x                 Get vector offset
                    leax      d,x                 Calculate vector
                    stx       4,s                 Replace original RTS address with vector
                    puls      pc,x,d              Restore regs and go to new routine

* Jump table
L256A               fdb       L2C50-L256A         $06e6
                    fdb       L30A0-L256A         $0b36
                    fdb       L2692-L256A         $0128
                    fdb       L26FD-L256A         $0193

* Jump table
L2581               fdb       L2D07-L2581         $0786
                    fdb       L277F-L2581         $01fe
                    fdb       L2728-L2581         $01a7
                    fdb       L2783-L2581         $0202
                    fdb       L292A-L2581         $03a9
                    fdb       L2C88-L2581         $0707
                    fdb       L2D20-L2581         $079f
                    fdb       L2D20-L2581         $079f
                    fdb       L2D20-L2581         $079f
                    fdb       L2C88-L2581         $0707
                    fdb       L2D20-L2581         $079f
                    fdb       L2D20-L2581         $079f
                    fdb       L2D20-L2581         $079f
                    fdb       L2954-L2581         $03D3
                    fdb       L2952-L2581         $03D1
                    fdb       L29A4-L2581         $0423
                    fdb       L2A30-L2581         $04AF
                    fdb       L2A4B-L2581         $04CA
                    fdb       L2A62-L2581         $04E1
                    fdb       L2A74-L2581         $04F3
                    fdb       L2B0C-L2581         $058B
                    fdb       L2B5B-L2581         $05DA
                    fdb       L2B69-L2581         $05E8
                    fdb       L2B81-L2581         $0600
                    fdb       L2B88-L2581         $0607
                    fdb       L2B9C-L2581         $061b
                    fdb       L2BA0-L2581         $061f
                    fdb       L2BA4-L2581         $0623
                    fdb       L2BC1-L2581         $0640
                    fdb       L29AB-L2581         $042a
                    fdb       L2A1A-L2581         $0499
                    fdb       L29CC-L2581         $044b
                    fdb       L308D-L2581         $0b0c
                    fdb       L29CC-L2581         $044b
                    fdb       L308D-L2581         $0b0c
                    fdb       L2C1F-L2581         $069e
                    fdb       L2D07-L2581         $0786
                    fdb       L2C65-L2581         $06e4
                    fdb       L2C88-L2581         $0707
                    fdb       L2D07-L2581         $0786
                    fdb       L2D07-L2581         $0786
                    fdb       L2CC6-L2581         $0745
                    fdb       L2CC6-L2581         $0745
                    fdb       L2CE2-L2581         $0761
                    fdb       L2C65-L2581         $06e4
                    fdb       L2C88-L2581         $0707
                    fdb       L2CF0-L2581         $076f
                    fdb       L2CF0-L2581         $076f
                    fdb       L2CFA-L2581         $0779
                    fdb       L2D18-L2581         $0797
                    fdb       L2D07-L2581         $0786
                    fdb       L2D07-L2581         $0786
                    fdb       L2D07-L2581         $0786
                    fdb       L2D20-L2581         $079f
                    fdb       L2D20-L2581         $079f
                    fdb       L26C8-L2581         $0147
                    fdb       L26C8-L2581         $0147
                    fdb       L2C88-L2581         $0707
                    fdb       L265D-L2581         $00dc
                    fdb       L308D-L2581         $0b0c
                    fdb       L308D-L2581         $0b0c
                    fdb       L26C1-L2581         $0140
                    fdb       L2718-L2581         $0197
                    fdb       L2718-L2581         $0197

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
                    bne       L2675
                    pshs      d
                    leay      -1,y
                    ldd       <u0060
L2669               std       <u00AB
                    ldd       #3
                    lbsr      L2578
                    puls      d
                    bra       L2677

L2675               leay      2,y
L2677               lbsr      L29DE
                    bcc       L268E
                    std       ,x
                    tfr       y,d
                    subd      <u005E
                    leax      2,x
L2684               ldu       ,x
                    std       ,x
L2688               leax      ,u
                    bne       L2684
                    bra       L2692

L268E               lda       #$4B                Multiply-defined Line Number error
                    bsr       L26CE               Go print (Y-<u005E) to std err in hex
L2692               leax      >L2581,pc           Point to table
                    ldb       ,y+                 Get byte
                    bpl       L269F               If high bit off, go get offset from table
                    ldd       #L2952-L2581        Otherwise force to use L2952 offset
                    bra       L26A9               Skip ahead

L269F               lslb                          Multiply by 2
                    clra                          16 bit offset required
                    ldd       d,x                 Get offset
                    cmpd      #L2952-L2581        Is it the special case one?
                    blo       L26BF               If it or any lower offset, go execute it
L26A9               tst       <u00C7              ??? If ?? set, go execute routine
                    bne       L26BF
                    inc       <u00C7              Set flag
                    pshs      d                   Preserve offset
                    tfr       y,d                 ??? Move current location to D
                    subd      <u005E              Subtract something
                    subd      #$0001              Subtract 1 more
                    ldu       <u002F              Get 'current' module ptr
                    std       $15,u               ??? Save some sort of size into module header?
                    puls      d                   Get offset back
L26BF               jmp       d,x                 Jump to routine

L26C1               ldx       <u002F              Get ptr to current module
                    lda       #$01                Flag for Line with Compiler error
                    sta       <$17,x              Save in flag header byte
L26C8               ldb       ,y+                 Get offset byte
                    clra                          Make 16 bit
                    leay      d,y                 Point Y to it & return
                    rts

L308D               ldy       <u0060
                    lda       #$30                Unimplemented Routine error
* ERROR MESSAGE REPORT:
* Prints Hex # address of where error occurs, & error message on screen
* Entry: Y=# to convert to hex after subtracting <u005E
* Exit: Writes out 4 digit hex # & space
L26CE               pshs      y,x,d               Preserve regs
                    ldx       <u002F              Get Ptr to current module
                    lda       #$01                Set Line with compiler error flag in mod. header
                    sta       <$17,x
                    lda       <u0084              Get flag???
                    bmi       L26FB               If high bit set, don't print address
                    ldd       4,s                 Get # to convert (current addr?)
                    subd      <u005E              ??? Subtract start?
                    leas      -5,s                Make 5 byte buffer
                    leax      ,s                  Point X to it
                    bsr       L26FD               Convert D to 4 digit HEX characters
                    lda       #C$SPAC             Add Space
                    sta       ,x+
                    lda       #2                  Std error path
                    leax      ,s                  Point to buffer
                    ldy       #5                  Write out the hex number
                    os9       I$Write
                    leas      5,s                 Eat temporary buffer
                    ldb       ,s                  Get error code
                    lbsr      L1CC1               Print error message
L26FB               puls      pc,y,x,d            Restore regs & return

* Convert 16 bit number to ASCII Hex equivalent (Addresses in LIST?)
* Result is stored at ,X
L26FD               bsr       L2701               Convert A to hex
                    tfr       b,a                 Convert B to hex
L2701               pshs      a                   Preserve byte
                    lsra                          Do high nibble first
                    lsra
                    lsra
                    lsra
                    bsr       L270D               Convert to ASCII Hex equivalent
                    puls      a                   Get back original byte
                    anda      #$0F                Do low nibble now
L270D               adda      #$30                Make ASCII
                    cmpa      #'9                 Past legal numeric?
                    bls       L2715               Yes, save ASCII version
                    adda      #$07                Bump >9 up to A-F for Hex
L2715               sta       ,x+                 Save Hex ASCII version & return
                    rts

L2718               ldb       ,y                  Get char(?)
                    bsr       L2721               Check if it is $3E or $3F > or ?
                    bne       L2720               Neither, return
L271E               leay      1,y                 Yes, bump Y up & return
L2720               rts

L2721               cmpb      #$3F
                    beq       L2727
                    cmpb      #$3E
L2727               rts

L2728               lbsr      L2F43
                    ldb       <u00CF
                    beq       L2733
                    lda       #$4C                Multiply-defined Variable error
                    bsr       L26CE               Go print hex version of (Y-<u005E)
L2733               leay      4,y                 Bump ptr up by 4
                    lda       #$40
                    sta       <u00CE
                    ldd       <u00C1
                    pshs      d
                    clra
                    clrb
                    std       <u00C1
                    bsr       L2787
                    ldd       <u00CC
                    subd      <u0060
                    beq       L277A
                    addd      #3
                    cmpd      <u000C
                    lbcc      L2A0D
                    pshs      y,x
                    lbsr      L257B
                    ldd       <u00C1
                    leau      ,y
                    std       ,y++
                    clr       ,y+
                    ldx       <u0060              Get address of $F offset in header
L2762               ldd       ,x++                Get value there
                    subd      <u0062
                    std       ,y++
                    inc       2,u
                    cmpx      <u00CC
                    blo       L2762
                    tfr       u,d
                    puls      y,x
                    subd      <u0066
                    std       1,x
                    lda       #$25
                    sta       ,x
L277A               puls      d
                    std       <u00C1
                    rts

L277F               lda       #$80
                    bra       L2785

L2783               lda       #$60
L2785               sta       <u00CE
L2787               ldd       <u0060
                    pshs      x,d
                    std       <u00CC
L278D               bsr       L27E0
                    ldb       ,y+
                    cmpb      #$4B
                    beq       L278D
                    cmpb      #$4C
                    beq       L279F
                    leay      -1,y
                    ldb       #$01
                    bra       L27A3

L279F               lbsr      L283A
                    clrb
L27A3               pshs      y,b
                    ldx       3,s
                    ldd       <u00CC
                    std       3,s
                    stx       <u00CC
                    subd      <u00CC
                    lslb                          D=D*2
                    rola
                    addd      3,s
                    cmpd      <u00DA
                    blo       L27CE
                    lbra      L2A0D

L27BC               ldu       ,x++                Get some sort of var ptr
                    tst       ,s
                    beq       L27CB
                    lda       ,u                  Get var type
                    sta       <u00D1              Save it
                    lbsr      L3083               D=size of var in bytes
                    std       <u00D6              Save size
L27CB               lbsr      L2878
L27CE               cmpx      3,s
                    blo       L27BC
                    ldd       <u00CC
                    std       3,s
                    puls      y,b
                    ldb       ,y+
                    cmpb      #$51
                    beq       L278D
                    puls      pc,x,d

L27E0               lbsr      L2F43
                    ldb       <u00CF
                    beq       L27FF
                    lda       #$4C                Multiply-defined Variable error
                    lbsr      L26CE
                    leay      3,y
                    ldb       ,y
                    cmpb      #$4D
                    bne       L27FE
                    leay      1,y
L27F6               bsr       L282E
                    ldb       ,y+
                    cmpb      #$4B
                    beq       L27F6
L27FE               rts

L27FF               ldd       <u00CC
                    addd      #$000A
                    cmpd      <u00DA
                    lbhs      L2A0D
                    ldx       <u00CC
                    ldd       <u00D2
                    std       ,x++
                    leau      ,x
                    clr       ,x+
                    leay      3,y
                    ldb       ,y
                    cmpb      #$4D
                    bne       L282B
                    leay      1,y
L281F               bsr       L282E
                    std       ,x++
                    inc       ,u
                    ldb       ,y+
                    cmpb      #$4B
                    beq       L281F
L282B               stx       <u00CC
                    rts

L282E               ldb       ,y+
                    clra
                    cmpb      #$8D
                    beq       L2837
                    lda       ,y+
L2837               ldb       ,y+
                    rts

L283A               lda       ,y+
                    cmpa      #$85
                    beq       L285B
                    suba      #$40
                    sta       <u00D1              Save var type
                    cmpa      #4                  String type?
                    bne       L2856               No, skip ahead
                    ldb       ,y
                    cmpb      #$4F
                    bne       L2856
                    leay      1,y
                    bsr       L282E
                    leay      1,y
                    bra       L2875

L2856               lbsr      L3083               Go get size of var
                    bra       L2875               Go save size @ u00D6

L285B               leay      -1,y
                    lbsr      L2F43
                    leay      3,y
                    ldb       <u00CF
                    cmpb      #$20
                    beq       L286D
                    lda       #$18                Illegal Type suffix error
                    lbra      L26CE

L286D               ldd       1,x
                    std       <u00D2
                    ldx       <u0066
                    ldd       d,x                 Get size of var
L2875               std       <u00D6              Save size of var & return
                    rts

L2878               ldb       ,x+
                    beq       L28D0
                    pshs      b
                    lslb
                    lslb
                    lslb
                    stb       <u00D0
                    lsrb
                    lsrb
                    leax      b,x
                    addb      #4
                    pshs      u,x
                    lda       <u00D1              Get var type
                    cmpa      #4                  Numeric type?
                    blo       L2893               Yes, skip ahead
                    addb      #2                  If string or complex, add 2 to type
L2893               clra
                    cmpd      <u000C
                    lbhi      L2A0D
                    lbsr      L257B
                    ldx       ,s
                    leau      2,y
                    ldd       #$0001
                    std       ,u++
L28A7               ldd       ,--x
                    std       ,u++
                    bsr       L28F7
                    dec       4,s
                    bne       L28A7
                    lda       <u00D1              Get var type
                    cmpa      #4                  Numeric or string?
                    bls       L28BC               Yes, skip ahead
                    ldd       <u00D2              No, (complex?)
* NOTE: Since 28BC only referred to here, should be able to change std ,u/coma
*   to bra L28C0 (std ,u)
                    std       ,u                  Save ???
                    coma                          Set carry to indicate complex?
L28BC               ldd       <u00D6              Get size of var in bytes
                    bcs       L28C2               If complex, don't save sign again
                    std       ,u                  Save size
L28C2               bsr       L28F7               ??? Do some multiply testing based on size?
                    tfr       y,d
                    puls      u,x
                    subd      <u0066
                    std       1,u
                    leas      1,s
                    bra       L28E0

L28D0               stb       <u00D0
                    lda       <u00D1              Get var type
                    cmpa      #4                  Normal type (numeric/string)?
                    bhi       L28DC               No, skip ahead
                    ldd       <u00D6              Get size of var
                    bra       L28DE               Skip ahead

L28DC               ldd       <u00D2              Get ??? (something with complex type?)
L28DE               std       1,u                 Save size
L28E0               lda       <u00D1              Get var type
                    ora       <u00D0              Keep common bits with ???
                    ora       <u00CE              Keep common bits with ???
                    sta       ,u                  Save ???
                    pshs      x
                    leax      ,u
                    lbsr      L2FEE
                    ldx       <u00CC
                    stu       ,x++
                    stx       <u00CC
                    puls      pc,x

* Check if size of array will be too big
L28F7               pshs      d
                    ldb       2,y
                    mul
                    bne       L2923
                    lda       1,s
                    ldb       2,y
                    mul
                    tsta
                    bne       L2923
                    stb       2,y
                    lda       ,s
                    ldb       3,y
                    mul
                    tsta
                    bne       L2923
                    addb      2,y
                    bcs       L2923
                    stb       2,y
                    lda       1,s
                    ldb       3,y
                    mul
                    adda      2,y
                    bcs       L2923
                    std       2,y
                    puls      pc,d

L2923               lda       #$49                Array Size Overflow error
                    lbsr      L26CE
                    puls      pc,d

L292A               ldu       <u00CA
                    bne       L2936
                    tfr       y,d
                    subd      <u005E
                    std       <u00C8
                    bra       L293C

L2936               tfr       y,d
                    subd      <u005E
                    std       ,u
L293C               lbsr      L2D65
                    lbsr      L2E52
                    ldb       ,y+
                    cmpb      #$4B
                    beq       L293C
                    sty       <u00CA
                    ldd       <u00C8
                    std       ,y++
                    lbra      L271E

L2952               leay      -1,y
L2954               bsr       L2984
                    leay      1,y
                    lbsr      L2D65
                    lbsr      L2E52
                    sta       <u00D1              Save var type
                    lbsr      L2E52
                    cmpa      <u00D1              Same as var type?
                    beq       L2981               Yes, skip ahead
                    cmpa      #2                  Var type from 2E52=Boolean/string/complex?
                    bhi       L297E               Yes, skip ahead (print some hex # out)
                    beq       L2971               Real #, skip ahead
                    lda       #$C8
                    bra       L2973

L2971               lda       #$CB
L2973               ldb       <u00D1              Get var type
                    cmpb      #2                  Boolean/string/complex?
                    bhi       L297E               Yes, skip ahead
                    lbsr      L2FBE               Byte/Integer/Real, go do something
                    bra       L2981

L297E               lbsr      L2A26
L2981               lbra      L2718               ??? Do some checking ,y, return from there

L2984               lda       ,y
                    cmpa      #$0E
                    lbne      L2D65
                    leay      1,y
                    lbsr      L2D65
L2991               lda       -3,y
                    cmpa      #$85
                    bhs       L299F
                    ldd       <u00D2
                    subd      <u0062
                    std       -2,y
                    lda       #$85
L299F               adda      #$6D
                    sta       -3,y
                    rts

L29A4               bsr       L29A6
L29A6               bsr       L2A1A
                    leay      1,y
                    rts

L29AB               ldb       ,y+
                    cmpb      #$1E
                    beq       L29C5
                    leay      -1,y
                    bsr       L29A6
                    ldd       ,y++
L29B7               pshs      d
                    leay      1,y
                    bsr       L29CC
                    puls      d
                    subd      #$0001
                    bne       L29B7
                    rts

L29C5               ldb       ,y+
                    lbsr      L2721
                    beq       L29DD
L29CC               ldd       ,y
                    bsr       L29DE
                    ldd       2,x
                    bcc       L29D7
                    sty       2,x
L29D7               std       ,y
                    inc       -1,y
                    leay      3,y
L29DD               rts

L29DE               ldx       <u0066
                    pshs      d
                    bra       L29ED

L29E4               ldd       ,x
                    anda      #$7F
                    cmpd      ,s
                    beq       L2A08
L29ED               leax      -4,x
                    cmpx      <u00DA
                    bhs       L29E4
                    ldd       <u000C              Get # bytes free in workspace for user
                    subd      #4                  Subtract 4
                    blo       L2A0D               Not enough mem, exit with Memory full error
                    std       <u000C              Save new free space
                    ldd       ,s
                    ora       #$80
                    std       ,x
                    clra
                    clrb
                    std       2,x
                    stx       <u00DA
L2A08               lda       ,x
                    rola
                    puls      pc,d

L2A0D               lda       #32                 Memory full error
                    sta       <u0036              Save error code
                    lbsr      L26CE
                    lbsr      L30EB
                    lbra      L1CC7

L2A1A               lbsr      L2D65
                    lbsr      L2E52
                    cmpa      #2                  Real?
                    beq       L2A2B               Yes, skip ahead
                    blo       L29DD               Byte/Integer, return
L2A26               lda       #$47                Illegal Expression Type error
                    lbra      L26CE

L2A2B               lda       #$C8
                    lbra      L2FBE

L2A30               lbsr      L2BAF
                    lda       3,y
                    cmpa      #$3A
                    beq       L2A3E
                    lda       #$10
                    lbra      L2BA8

L2A3E               pshs      y
                    leay      4,y
                    bsr       L29CC
                    tfr       y,d
                    subd      <u005E
                    std       [,s++]
                    rts

L2A4B               ldd       #$1002
                    lbsr      L2BDD
                    ldu       1,x
                    sty       1,x
                    leay      2,y
                    lbsr      L2718
                    tfr       y,d
                    subd      <u005E
                    std       ,u
                    rts

L2A62               ldd       #$1001
                    lbsr      L2BDD
                    leay      1,y
L2A6A               tfr       y,d
                    subd      <u005E
                    std       [<1,x]
                    lbra      L2C01

L2A74               lbsr      L2F43
                    lbsr      L2EE3
                    cmpa      #$60
                    bne       L2A88
                    lda       <u00D1              Get var type
                    cmpa      #1                  Integer?
                    beq       L2A94               Yes, skip ahead
                    cmpa      #2                  Real?
                    beq       L2A94               Yes, skip ahead
L2A88               lda       #$46                Illegal FOR variable
                    lbsr      L26CE
                    ldd       #$FFFF
                    std       <u00D2
                    bra       L2AA0

* FOR variable is numeric but NOT byte, continue
L2A94               ldb       <u00D0
                    bne       L2A88
                    adda      #$80                Set hi bit on var type
                    sta       ,y                  Save it
                    ldd       1,x
                    std       1,y
L2AA0               ldx       <u0044              Get some sort of var ptr
                    leax      -7,x                Make room for 7 more bytes
                    stx       <u0044              Save new ptr
                    lda       <u00D1              Get var type
                    sta       ,x                  Save it
                    ldd       <u00D2
                    subd      <u0062
                    std       1,x
                    clra
                    clrb
                    std       5,x
                    leay      4,y
                    bsr       L2AF1
                    bsr       L2AD4
                    std       3,x
                    lda       ,y
                    cmpa      #$47
                    bne       L2AC6
                    bsr       L2AD4
                    std       5,x
L2AC6               leay      1,y
                    sty       ,--x
                    lda       #$13
                    sta       ,-x
                    stx       <u0044
                    leay      3,y
L2AD3               rts

L2AD4               ldd       <u00C1
                    pshs      d
                    std       1,y
                    ldx       <u0044
                    lda       ,x
                    leax      >L307E,pc           Point to 5 single bytes table
                    ldb       a,x                 Get value
                    clra                          D=value
                    addd      <u00C1              Add to value & save result
                    std       <u00C1
                    leay      3,y
                    bsr       L2AF1
                    ldx       <u0044
                    puls      pc,d

L2AF1               lbsr      L2D65
                    lbsr      L2E52
                    cmpa      ,u
                    beq       L2AD3
                    cmpa      #$02
                    bcs       L2B07
                    lbne      L2A26
                    lda       #$C8
                    bra       L2B09

L2B07               lda       #$CB                ??? Illegal mode error?
L2B09               lbra      L2FBE

L2B0C               leay      -1,y
                    ldd       #$130B
                    lbsr      L2BDD
                    ldd       2,y
                    cmpd      4,x
                    beq       L2B22
                    lda       #$46                Illegal FOR variable error
                    lbsr      L26CE
                    bra       L2B51

L2B22               addd      <u0062
                    exg       d,x
                    ldx       1,x
                    exg       d,x
                    std       2,y
                    lda       3,x
                    anda      #$02
                    sta       1,y
                    ldd       6,x
                    std       4,y
                    ldd       8,x
                    std       6,y
                    beq       L2B3E
                    inc       1,y
L2B3E               ldu       1,x
                    tfr       y,d
                    subd      <u005E
                    addd      #$0001
                    std       ,u
                    leau      3,u
                    tfr       u,d
                    subd      <u005E
                    std       8,y
L2B51               leay      $B,y
                    lbsr      L2C01
                    leax      7,x
                    stx       <u0044
                    rts

L2B5B               leau      -1,y
                    pshs      u
                    bsr       L2BAF
                    puls      d
                    std       ,y
                    lda       #$15
                    bra       L2BA8

L2B69               ldd       #$1503
                    bsr       L2BDD
                    ldx       1,x
                    ldd       ,x
                    subd      <u005E
                    std       ,y
                    leay      3,y
                    tfr       y,d
                    subd      <u005E
                    std       ,x
                    lbra      L2C01

L2B81               lda       #$17
L2B83               lbsr      L271E
                    bra       L2BD3

L2B88               bsr       L2BAF
                    lda       #$17
L2B8C               leay      -1,y
                    ldb       #$03
                    bsr       L2BDD
                    ldd       1,x
                    subd      <u005E
                    std       $01,y
                    leay      $04,y
                    bra       L2C01

L2B9C               lda       #$19
                    bra       L2B83

L2BA0               lda       #$19
                    bra       L2B8C

L2BA4               bsr       L2BAF
                    lda       #$1B
L2BA8               bsr       L2BD3
                    leay      3,y
                    lbra      L2718

L2BAF               lbsr      L2D65
                    lbsr      L2E52
                    cmpa      #3                  ??? Boolean variable?
                    beq       L2BBE               Yes, skip ahead
                    lda       #$47                Illegal Expression Type error
                    lbsr      L26CE
L2BBE               leay      1,y
                    rts

L2BC1               ldd       #$1B03
                    bsr       L2BDD
                    leau      ,y
                    leay      3,y
                    lbsr      L2A6A
                    stu       ,--x
                    lda       #$1C
                    bra       L2BD8

L2BD3               ldx       <u0044
                    sty       ,--x
L2BD8               sta       ,-x
                    stx       <u0044
                    rts

L2BDD               pshs      a
                    ldx       <u0044
                    bra       L2BE5

L2BE3               leax      3,x
L2BE5               cmpx      <u0046
                    bhs       L2BF3
                    lda       ,x
                    cmpa      #$1C
                    beq       L2BE3
                    cmpa      ,s
                    beq       L2BFF
L2BF3               leas      3,s
                    lda       #$45                Unmatched Control Structure error
                    lbsr      L26CE
                    leay      b,y
                    lbra      L2718

L2BFF               puls      pc,a

L2C01               ldx       <u0044
                    bra       L2C14

L2C05               lda       ,x
                    cmpa      #$1C
                    bne       L2C1A
                    tfr       y,d
                    subd      <u005E
                    std       [<1,x]
                    leax      3,x
L2C14               cmpx      <u0046
                    blo       L2C05
                    bra       L2C1C

L2C1A               leax      3,x
L2C1C               stx       <u0044
                    rts

L2C1F               leay      -1,y
                    lbsr      L2F43
                    lda       <u00CF
                    beq       L2C41
                    cmpa      #$A0
                    beq       L2C4E
                    cmpa      #$60
                    bcs       L2C3A
                    lda       <u00D0
                    bne       L2C3A
                    lda       <u00D1
                    cmpa      #$04
                    beq       L2C4E
L2C3A               lda       #$4C                Multiply-defined Variable error
                    lbsr      L26CE
                    bra       L2C4E

L2C41               lda       #$A0
                    sta       ,x
                    ldd       <u00C5
                    std       1,x
                    addd      #$0002
                    std       <u00C5
L2C4E               leay      3,y
L2C50               ldb       ,y+
                    cmpb      #$4D
                    bne       L2C64
L2C56               lbsr      L2984
                    lbsr      L2E52
                    ldb       ,y+
                    cmpb      #$4B
                    beq       L2C56
                    leay      1,y
L2C64               rts

L2C65               bsr       L2CB2
                    leay      -1,y
                    cmpb      #$90
                    bne       L2C72
                    lbsr      L2D0B
                    leay      1,y
L2C72               lbsr      L2984
                    lbsr      L2E52
                    cmpa      #$05
                    bcs       L2C81
                    lda       #$4D                Illegal Input Variable error
                    lbsr      L26CE
L2C81               lda       ,y+
                    cmpa      #$4B
                    beq       L2C72
                    rts

L2C88               bsr       L2CB2
                    cmpb      #$49
                    bne       L2C92
                    bsr       L2D0B
L2C90               ldb       ,y+
L2C92               cmpb      #$4B
                    beq       L2C90
                    cmpb      #$51
                    beq       L2C90
                    lbsr      L2721
                    beq       L2CC5
                    leay      -1,y
                    lbsr      L2D65
                    lbsr      L2E52
                    cmpa      #$05
                    blo       L2C90
                    lda       #$47                Illegal Expression Type error
                    lbsr      L26CE
                    bra       L2C90

L2CB2               ldb       ,y+
                    cmpb      #$54
                    bne       L2CC5
                    lbsr      L2A1A
L2CBB               ldb       ,y+
                    cmpb      #$4B
                    beq       L2CBB
                    cmpb      #$51
                    beq       L2CBB
L2CC5               rts

L2CC6               leay      1,y
                    lbsr      L2984
                    lbsr      L2E52
                    cmpa      #$01
                    beq       L2CD5
                    lbsr      L2A26
L2CD5               leay      1,y
                    bsr       L2D0B
                    lda       ,y+
                    cmpa      #$4A
                    bne       L2CE1
                    leay      2,y
L2CE1               rts

L2CE2               bsr       L2D02
                    bsr       L2D65
                    lbsr      L2E52
                    cmpa      #$42
                    bls       L2D20
                    lbra      L2A26

L2CF0               bsr       L2D02
                    lbsr      L2984
                    lbsr      L2E52
L2CF8               bra       L2D20

L2CFA               bsr       L2D02
                    cmpb      #$4B
                    beq       L2CFA
                    bra       L2D20

L2D02               leay      1,y
                    lbra      L29A6

L2D07               bsr       L2D0B
                    bra       L2D20

L2D0B               bsr       L2D65
                    lbsr      L2E52
                    cmpa      #4
                    beq       L2CE1               Return
                    lbra      L2A26               Return from there

L2D18               ldb       ,y+
                    cmpb      #$3A
                    lbeq      L29CC
L2D20               lbra      L2718

L2D23               cmpb      #$96
                    bhs       L2D2C
                    lbsr      L2E5F
                    bra       L2D65

* B>=$96 goes here
L2D2C               cmpb      #$F2                If >=$F2, skip ahead
                    lbhs      L308D
                    subb      #$96                Drop B to $00 - $5B
                    leax      >L2601,pc           Point to data table
                    abx                           Point to entry we want
                    ldb       ,x                  Get it
                    lbeq      L308D               If nothing, skip ahead
                    andb      #$1F
                    beq       L2D4A
                    leau      <L2DA2,pc           point to routine
                    lslb
                    jsr       b,u
L2D4A               ldb       ,x                  Get byte
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
                    lbsr      L2FD4
                    bra       L2D65

L2D60               lbsr      L2E3B
                    leay      1,y
L2D65               ldb       ,y
                    bmi       L2D23
                    rts

L2D6A               bsr       L2D6F
                    incb
                    bra       L2D71

L2D6F               ldb       #$C8                (200)
L2D71               lbsr      L2E52
                    cmpa      #$02
                    blo       L2D85
                    beq       L2D7E
                    bsr       L2DC3
                    bra       L2D83

L2D7E               tfr       b,a
                    lbsr      L2FBE
L2D83               lda       #$01
L2D85               rts

L2D86               bsr       L2D8B
                    incb
                    bra       L2D8D

L2D8B               ldb       #$CB
L2D8D               lbsr      L2E52
                    cmpa      #$02
                    beq       L2DA1
                    blo       L2D9A
                    bsr       L2DC3
                    bra       L2D9F

L2D9A               tfr       b,a
                    lbsr      L2FBE
L2D9F               lda       #$02
L2DA1               rts

L2DA2               bra       L2DC0               (offset 0)
L2DA4               bra       L2D6F               (2)
L2DA6               bra       L2D6A               (4)
L2DA8               bra       L2D8B               (6)
L2DAA               bra       L2D86               (8)
L2DAC               bra       L2DDE               ($a)
L2DAE               bra       L2DC8               ($c)
L2DB0               bra       L2DF4               ($e)
L2DB2               bra       L2DF2               ($10)
L2DB4               bra       L2DFF               ($12)
L2DB6               bra       L2E04               ($14)
L2DB8               bra       L2E30               ($16)
L2DBA               bra       L2E2E               ($18)
L2DBC               bra       L2E13               ($1A)
L2DBE               bra       L2E09               ($1C)
L2DC0               lbra      L308D               ($1F)

L2DC3               lda       #$43                Illegal Argument error
                    lbra      L26CE

L2DC8               bsr       L2DE7
                    pshs      a
                    bsr       L2DE7
                    cmpa      ,s+
                    beq       L2DE0
                    lda       #$CB
                    bcc       L2DD7
                    inca
L2DD7               lbsr      L2FBE
                    lda       #$02
                    bra       L2DE4

L2DDE               bsr       L2DE7
L2DE0               cmpa      #$02
                    bne       L2DE6
L2DE4               inc       ,y
L2DE6               rts

L2DE7               bsr       L2E52
                    cmpa      #$02
                    bls       L2DF1
                    bsr       L2DC3
                    lda       #$02
L2DF1               rts

L2DF2               bsr       L2DF4
L2DF4               bsr       L2E52
                    cmpa      #4
                    beq       L2DFE
                    bsr       L2DC3
                    lda       #4
L2DFE               rts

L2DFF               lbsr      L2D6F
                    bra       L2DF4

L2E04               lbsr      L2D6A
                    bra       L2DF4

L2E09               lda       #3
                    bsr       L2E20
                    bne       L2E13
                    ldb       #3
                    bra       L2E1B

L2E13               lda       #4
                    bsr       L2E20
                    bne       L2DC8
                    ldb       #2
L2E1B               addb      ,y
                    stb       ,y
                    rts

L2E20               ldu       <u0044
                    cmpa      ,u+
                    bne       L2E2D
                    cmpa      ,u+
                    bne       L2E2D
                    stu       <u0044
                    clrb
L2E2D               rts

L2E2E               bsr       L2E30
L2E30               bsr       L2E52
                    cmpa      #3
                    beq       L2E3A
                    bsr       L2DC3
                    lda       #3
L2E3A               rts

* Modified since all routines coming here freshly LDA
L2E3B               tsta                          A=0?
L2E3C               bne       L2E41               No, skip ahead
                    inca                          A=1
L2E41               ldu       <u0044
                    cmpa      #5
                    bne       L2E4D
                    ldd       <u00D4
                    std       ,--u
                    lda       #5
L2E4D               sta       ,-u
                    stu       <u0044
                    rts

L2E52               ldu       <u0044
                    lda       ,u+
                    cmpa      #5
                    bne       L2E5C
                    leau      2,u
L2E5C               stu       <u0044
                    rts

L2E5F               cmpb      #$85
                    lblo      L308D
                    cmpb      #$89
                    blo       L2EAB
                    subb      #$8D
                    lblo      L2F07               $8a to $8c go here
                    leau      <L2E75,pc           Point to list of branches
                    lslb                          2 bytes/per branch
                    jmp       b,u                 Call branch

L2E75               bra       L2E87
L2E77               bra       L2E89
L2E79               bra       L2E8F
L2E7B               bra       L2E95
L2E7D               bra       L2E89
L2E7F               bra       L2E9F
L2E81               bra       L2EA8
L2E83               bra       L2E9F
L2E85               bra       L2EA8

L2E87               leay      -1,y
L2E89               leay      3,y
                    lda       #1
                    bra       L2E41

L2E8F               leay      6,y
                    lda       #2
                    bra       L2E41

L2E95               ldb       ,y+
                    cmpb      #$FF
                    bne       L2E95
                    lda       #4
                    bra       L2E41

L2E9F               lbsr      L2991
                    bsr       L2E52
                    lda       #1
                    bsr       L2E41
L2EA8               leay      1,y
                    rts

L2EAB               lbsr      L2F43
                    bsr       L2EE3
                    cmpa      #$60
                    beq       L2EBF
                    cmpa      #$80
                    beq       L2EBF
                    lda       #$12                Illegal Operand error
                    lbsr      L26CE
                    bra       L2EDC

L2EBF               ldb       #$85
                    lbsr      L2F5E
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
                    bne       L2F06
                    ldb       #$60
                    sta       <u00D0
                    stb       <u00CF
                    lda       #$60                Take out, and change following to B's ?
                    ora       <u00D1
                    sta       ,x
                    anda      #$07
                    cmpa      #4
                    bne       L2F01
                    ldd       #$0020
                    std       1,x
L2F01               lbsr      L2FEE
                    lda       <u00CF
L2F06               rts

L2F07               bsr       L2F43
                    ldb       #$89
                    bsr       L2F5E
                    lbsr      L2E52
                    cmpa      #5
                    beq       L2F19
                    ldu       #$FFFF
                    bra       L2F1B

L2F19               ldu       -2,u
L2F1B               pshs      u
                    bsr       L2EDC
                    puls      u
                    cmpu      #$FFFF
                    beq       L2F3E
                    ldb       2,u
                    stb       <u00D6
                    ldd       <u00D2
                    subd      <u0062
                    leau      3,u
L2F31               cmpd      ,u++
                    beq       L2F5D
                    dec       <u00D6
                    bne       L2F31
                    lda       #$14
                    bra       L2F40

L2F3E               lda       #$42                Non-Record Type Operand error
L2F40               lbra      L26CE

L2F43               ldd       1,y
                    addd      <u0062
                    std       <u00D2
                    ldx       <u00D2
L2F4B               lda       ,x
                    anda      #$E0
                    sta       <u00CF
                    lda       ,x
                    anda      #$18
                    sta       <u00D0
                    lda       ,x
                    anda      #$07
                    sta       <u00D1
L2F5D               rts

L2F5E               pshs      b
                    ldb       ,y
                    subb      ,s+
                    bne       L2F73
                    lda       <u00D0
                    beq       L2F9D
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
                    lda       #$41                Wrong Number of Subscripts error
                    lbsr      L26CE
L2F7F               lda       #$C8
                    sta       <u00D8
L2F83               lbsr      L2E52
                    cmpa      #2                  Byte or Integer?
                    blo       L2F97               Yes, skip ahead
                    beq       L2F93               If real, skip ahead
                    lda       #$47                Illegal Expression Type error
                    lbsr      L26CE
                    bra       L2F97

* Real comes here
L2F93               lda       <u00D8
                    bsr       L2FBE
* Byte/Integer come here
L2F97               inc       <u00D8
                    subb      #$08
                    bne       L2F83
L2F9D               lda       <u00D1
                    cmpa      #$05
                    bne       L2FBD
                    ldd       1,x
                    addd      <u0066
                    tfr       d,u
                    ldb       <u00D0
                    beq       L2FB5
                    lsrb                          Divide by 4
                    lsrb
                    addb      #4
                    ldd       b,u
                    bra       L2FB7

L2FB5               ldd       2,u
L2FB7               addd      <u0066
L2FB9               std       <u00D4
                    lda       <u00D1
L2FBD               rts

L2FBE               pshs      x,b
                    ldx       <u000C
                    cmpx      #$0010
                    lbls      L2A0D
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
L2FDE               fdb       L3027-L2FDE         $0049
                    fdb       L303A-L2FDE         $005c
                    fdb       L303E-L2FDE         $0060
                    fdb       L3048-L2FDE         $006a

L2FE6               fdb       L304C-L2FE6         $0066
                    fdb       L3058-L2FE6         $0072
                    fdb       L3058-L2FE6         $0072
                    fdb       L305C-L2FE6         $0076

L2FEE               pshs      u,y,x
                    leay      <L2FDE,pc           Point to 1st jump table
                    ldb       ,x
                    andb      #$E0                Get rid of lowest 5 bits (b1-b5)
                    cmpb      #%01100000          bits 6 & 7 set?
                    beq       L3005               Yes, skip ahead
                    cmpb      #%01000000          Just bit 7 set?
                    beq       L3005               Yes, skip ahead
                    cmpb      #%10000000          Just bit 8 set?
                    bne       L3025               No, skip way ahead
* NOTE: IF TABLE CHANGED TO 8 BIT OFFSET, CHANGE THIS TO LEAY 4,Y
                    leay      8,y                 If just bit 8 set, use 2nd jump table
L3005               ldb       ,x                  Reload the value
                    andb      #%00011000          Just keep bits 4-5
                    beq       L300F               Neither set, skip ahead
                    ldd       6,y                 If either set, use 4th entry
                    bra       L3023               Go to subroutine

L300F               ldb       ,x                  Reload the value
                    andb      #%00000111          Just keep bits 1-3
L3013               cmpb      #%00000100          Just bits 1-2?
                    blo       L3021               Yes, skip ahead
                    bhi       L301D               Bit 3 + at least 1 more bit, skip ahead
                    ldd       2,y                 If just bit 3, use 2nd entry
                    bra       L3023               Go to subroutine

L301D               ldd       4,y                 Bit 3 + (1 or 2), use 3rd entry
                    bra       L3023               Go to subroutine

L3021               ldd       ,y                  Use 1st entry
L3023               jsr       d,y                 Call subroutine
L3025               puls      pc,u,y,x            Restore regs & return

L3027               lda       ,x
                    anda      #$07
                    leay      1,x
                    bsr       L3083
L302F               pshs      d                   USE W
                    ldd       <u00C1
                    std       ,y
                    addd      ,s++
                    std       <u00C1
                    rts

L303A               bsr       L3069
                    bra       L302F

L303E               bsr       L3069
                    addd      <u0066
                    tfr       d,x
                    ldd       ,x
                    bra       L302F

L3048               bsr       L3060
                    bra       L302F

L304C               leay      1,x
L304E               ldd       <u00C3
                    std       ,y
                    addd      #$0004
                    std       <u00C3
                    rts

L3058               bsr       L3069
                    bra       L304E

L305C               bsr       L3060
                    bra       L304E

L3060               ldd       1,x
                    addd      <u0066
                    tfr       d,y
                    ldd       2,y
                    rts

L3069               ldd       #$0004              Requesting 4 bytes of memory from workspace
                    bsr       L257B               Go see if we can get it & allocate it
                    ldx       4,s
                    ldd       1,x
                    std       2,y
                    tfr       y,d
                    subd      <u0066
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
L3083               pshs      x                   Preserve X
                    leax      <L307E,pc           Point to 5 1-byte entry table
                    ldb       a,x                 D=#
                    clra
                    puls      pc,x

* Single byte entry table
L3095               fcb       $01,$02,$03,$07,$08,$09,$37,$38,$3e,$3f,$ff

L30A0               ldd       #$0016
                    std       <u00C1
                    clrb
                    std       <u00C3
                    std       <u00C5
                    sta       <u00C7
                    std       <u00C8
                    std       <u00CA
                    ldx       <u002F              Get ptr to current module
                    sta       <$17,x              Set flags to unpacked, no errors
                    std       <$15,x
L30B8               ldy       <u005E
                    bra       L30E2

L30BD               pshs      y
                    lbsr      L2692
                    puls      x
                    ldb       <u00D9
                    bne       L30E2
                    lda       ,x
                    leau      <L3095,pc           Point to 11 entry 1 byte table
L30CD               cmpa      ,u+                 Hunt through for range our byte is in
                    blo       L30E2               If lower then table entry, skip ahead
                    bne       L30CD               If not equal, keep looking
                    pshs      x                   Equal, preserve X
                    tfr       y,d                 Move ??? to d
                    subd      ,s++
                    leay      ,x
                    ldu       <u004A              Get ptr to next free byte in I-code workspace
                    stu       <u00AB              Save as ptr to current line I-code end
                    lbsr      L2578
L30E2               ldx       <u0060
                    clr       ,x
                    cmpy      <u0060
                    blo       L30BD
L30EB               ldx       <u0066
                    bra       L310B

L30EF               lda       ,x
                    bpl       L310B
                    anda      #$7F
                    sta       ,x
                    ldy       2,x
L30FA               ldu       ,y
                    ldd       ,x
                    std       ,y
                    dec       -1,y
                    lda       #$4A                Undefined Line Number error
                    lbsr      L26CE
                    leay      ,u
                    bne       L30FA
L310B               leax      -4,x
                    cmpx      <u00DA
                    bhs       L30EF
                    ldd       <u0066
                    subd      <u00DA
                    addd      <u000C              Add to bytes free to user
                    std       <u000C              Save as new # bytes free to user
                    ldx       <u0044
                    bra       L3131

L257E               jsr       <u001E
                    fcb       $06

L311D               ldy       1,x
                    lda       #$45                Unmatched Control Structure error
                    lbsr      L26CE
                    lda       ,x
                    cmpa      #$13
                    bne       L312D
                    leax      7,x
L312D               leax      3,x
                    stx       <u0044
L3131               cmpx      <u0046
                    blo       L311D
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
                    std       <u0062
                    ldd       <u002F              Get current module ptr
                    addd      $0F,x
                    std       <u0066
                    ldu       <u0062
                    bra       L31E2

L3188               leax      ,u
                    lbsr      L2F4B
                    lda       <u00CF
                    cmpa      #$60
                    bcs       L31BD
                    cmpa      #$A0
                    bne       L319F
                    ldd       1,x
                    addd      <u00C1
                    std       1,x
                    bra       L31DC

L319F               cmpa      #$80
                    bne       L31BD
                    ldb       <u00D0
                    bne       L31B1
                    lda       <u00D1
                    cmpa      #$04
                    bcc       L31B1
                    leax      1,u
                    bra       L31B7

L31B1               ldd       1,u
                    addd      <u0066
                    tfr       d,x
L31B7               ldd       ,x
                    addd      <u00C5
                    std       ,x
L31BD               lda       <u00D1
                    cmpa      #$05
                    bne       L31DC
                    ldb       <u00D0
                    beq       L31CD               If 0, force to 2
                    lsrb                          Divide by by 4
                    lsrb
                    addb      #4
                    bra       L31CF

L31CD               ldb       #$02
L31CF               clra
                    addd      1,u
                    ldx       <u0066
                    leay      d,x
                    ldd       ,y
                    ldd       d,x
                    std       ,y
L31DC               leau      3,u
L31DE               lda       ,u+
                    bpl       L31DE
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
                    fdb       L32DD-L31F8         Function 1 call
                    fdb       L3B5F-L31F8         Function 2 call
                    fdb       L39FB-L31F8         Function 3 call  (error message)
                    fdb       L33AE-L31F8         Function 4 call
                    fdb       L3A69-L31F8         Function 5 call
                    fdb       L3A73-L31F8         Function 6 call

* Jump table (from L323F+offset)
L323F               fdb       L3A51-L323F
                    fdb       L3A51-L323F
                    fdb       L3A51-L323F
                    fdb       L3A51-L323F
                    fdb       L3A51-L323F
                    fdb       L35DF-L323F
                    fdb       L3209-L323F         Go direct to JSR <1B / fcb $C
                    fdb       L3A69-L323F
                    fdb       L3A73-L323F
                    fdb       L35F3-L323F
                    fdb       L3A5D-L323F
                    fdb       L3A61-L323F
                    fdb       L3619-L323F
                    fdb       L33AE-L323F
                    fdb       L352D-L323F
                    fdb       L35D2-L323F
                    fdb       L33BC-L323F
                    fdb       L33CC-L323F
                    fdb       L33D3-L323F
                    fdb       L34ED-L323F
                    fdb       L33E7-L323F         NEXT routine
                    fdb       L33D6-L323F
                    fdb       L33CC-L323F
                    fdb       L33AE-L323F
                    fdb       L33D6-L323F
                    fdb       L33AE-L323F
                    fdb       L33CC-L323F
                    fdb       L33D6-L323F
                    fdb       L33CC-L323F
                    fdb       L3632-L323F
                    fdb       L39F7-L323F
                    fdb       L3A59-L323F
                    fdb       L33CC-L323F
                    fdb       L3A59-L323F
                    fdb       L35F9-L323F
                    fdb       L3A8A-L323F
                    fdb       L3BF3-L323F
                    fdb       L36EE-L323F
                    fdb       L3856-L323F
                    fdb       L397D-L323F
                    fdb       L398A-L323F
                    fdb       L3688-L323F
                    fdb       L3691-L323F
                    fdb       L36BF-L323F
                    fdb       L37CB-L323F
                    fdb       L38E2-L323F
                    fdb       L3917-L323F
                    fdb       L391E-L323F
                    fdb       L394A-L323F
                    fdb       L3957-L323F
                    fdb       L3970-L323F
                    fdb       L39A0-L323F
                    fdb       L39BC-L323F
                    fdb       L3A3D-L323F
                    fdb       L3A40-L323F
                    fdb       L3A48-L323F
                    fdb       L3A48-L323F
                    fdb       L3397-L323F
                    fdb       L33AC-L323F
                    fdb       L33AC-L323F
                    fdb       L3A4E-L323F
                    fdb       L3A59-L323F
                    fdb       L33AB-L323F
                    fdb       L33AB-L323F
                    fdb       L3551-L323F
                    fdb       L3560-L323F
                    fdb       L356F-L323F
                    fdb       L3551-L323F
                    fdb       L3588-L323F
                    fdb       L35BB-L323F

L3209               jsr       <u001B
                    fcb       $0c

L32CB               fcc       'STOP Encountered'
                    fcb       C$LF,$FF

* Vector #2 from table at L31F8 comes here

L32DD               lda       $17,x               Get something
                    bita      #$01                check if 1st bit is set
                    beq       L32E8               no, skip ahead
                    ldb       #$33
                    bra       L3304

L32E8               tfr       s,d
                    subd      #$0100
                    cmpd      <u0080
                    bhs       L32F6
                    ldb       #$39
                    bra       L3304

L32F6               ldd       <u000C
                    subd      $0B,x
                    blo       L3302
                    cmpd      #$0100
                    bhs       L3307
L3302               ldb       #$20                Memory full error
L3304               lbra      L39FB

L3307               std       <u000C
                    tfr       y,d
                    subd      $0B,x
                    exg       d,u
                    sts       5,u
                    std       7,u
                    stx       3,u
L3316               ldd       #$0001
                    std       <u0042
                    sta       1,u
                    sta       <$13,u
                    stu       <$14,u
                    bsr       L3351
                    ldd       <$13,x
                    beq       L332C
                    addd      <u005E
L332C               std       <u0039
                    ldd       $0B,x
                    leay      d,u
                    pshs      y
                    ldd       <$11,x
                    leay      d,u
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
                    leas      2,s
                    ldx       <u002F
                    ldd       <u005E
                    addd      <$15,x
                    tfr       d,x
                    bra       L3391

L3351               stx       <u002F              Save current module ptr
                    stu       <u0031
                    ldd       $0D,x
                    addd      <u002F              Add to start address of module
                    std       <u0062
                    ldd       $0F,x
                    addd      <u002F              Add to start address of module
                    std       <u0066
                    std       <u0060
                    ldd       M$Exec,x            Get exec offset
                    addd      <u002F              Add to start of module address
                    std       <u005E              Save exec offset
                    ldd       <$14,u
                    std       <u0046
                    std       <u0044
                    rts

L3371               stx       <u005C
                    lda       <u0034              Get signal received flag
                    beq       L338F               Nothing happened, skip ahead
                    bpl       L3382               No signal flagged, skip ahead
                    anda      #$7F                Mask off signal received bit flag
                    sta       <u0034              Save masked version
                    lbsr      L3233               JSR <1B, fcb $18
                    lda       <u0034              Shift out least sig bit
L3382               rora
                    bcc       L338F               Not set, skip ahead
                    leay      ,x
                    lbsr      L3218
                    clr       <u0074
                    bsr       L3236
L338F               bsr       L33AE
L3391               cmpx      <u0060
                    blo       L3371
                    bra       L33A1

L3236               jsr       <u001B
                    fcb       $16

L3397               ldb       ,x
                    lbsr      L384F
                    beq       L33A1
                    lbsr      L3856
L33A1               lbsr      L3A73
                    ldu       <u0031
                    lds       5,u
                    ldu       7,u
L33AB               rts

L33AC               leax      2,x
L33AE               ldb       ,x+
                    bpl       L33B4               Hi bit clear, skip ahead
                    addb      #$40                ??? Wrap it around
L33B4               lslb                          Multiply by 2
                    clra                          Unsigned D
                    ldu       <u000E              Get ptr to L323F
                    ldd       d,u                 Get offset
                    jmp       d,u                 Jump to that routine

L33BC               jsr       <u0016
                    tst       2,y
                    beq       L33CC
                    leax      3,x
                    ldb       ,x
                    cmpb      #$3B
                    bne       L33AB
                    leax      1,x
L33CC               ldd       ,x
                    addd      <u005E
                    tfr       d,x
                    rts

L33D3               leax      1,x
                    rts

* UNTIL
L33D6               jsr       <u0016
                    tst       2,y
                    beq       L33CC               False, go back
                    leax      3,x
                    rts

* NEXT routine
L33E7               leay      <L33DF,pc           Point to table
L33EA               ldb       ,x+                 Get byte
                    ldb       b,y                 Get jump offset
                    ldu       <u0031              Get Base address for variable storage
                    jmp       b,y                 Jump to appropriate routine

L33F3               ldd       ,x
                    leay      d,u
                    bra       L3410

L33F9               ldd       ,x
                    leay      d,u
                    ldd       4,x
                    lda       d,u
                    bpl       L3410
                    bra       L3430

* Integer STEP 1
L3405               ldd       ,x                  Get offset to current FOR/NEXT INTEGER value
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
                    bge       L33CC               Yes, do X=[,x]+[u005E] & return
                    leax      3,x                 Eat 3 bytes from X & return
                    rts

* INTEGER STEP <>1
L341E               ldd       ,x                  Y=ptr to current FOR/NEXT INTEGER value
                    leay      d,u
                    ldd       4,x                 Get STEP value
                    ldd       d,u                 Get current FOR/NEXT counter
                    ifne      H6309
                    tfr       a,e                 Preserve Hi byte (for sign)
                    else
                    pshs      a
                    endc
                    addd      ,y                  Add increment value
                    std       ,y                  Save new current value
                    ifne      H6309
                    tste                          Was STEP negative value?
                    else
                    tst       ,s+
                    endc
                    bpl       L3410               No, go use normal compare routine
L3430               ldd       2,x                 Get offset to TO value
                    leax      6,x                 Eat temp var
                    ldd       d,u                 Get TO value
                    cmpd      ,y                  Hit TO value yet?
                    ble       L33CC               Yes, do X=[,x]+[u005E] & return
                    leax      3,x                 Eat 3 bytes from X & return
                    rts

L343E               ldy       <u0046
                    clrb
                    bsr       L348E
                    bra       L347E

L3446               ldy       <u0046
                    clrb
                    bsr       L348E
                    ldd       4,x
                    addd      #4
                    ldu       <u0031
                    lda       d,u
                    lsra
                    bcc       L347E
                    bra       L34CC

* NEXT table
* IF some of these entry points are moved before this table, 8 bit addressing
* may be used instead of 16
L33DF               equ       *
                    fcb       L3405-L33DF         Integer STEP 1
                    fcb       L341E-L33DF         Integer STEP <>1
                    fcb       L345A-L33DF         Real STEP 1
                    fcb       L34A5-L33DF         Real STEP <>1

* Jump table for FOR (relative to L34E5) (change to 8 bit if possible)
L34E5               equ       *
                    fcb       L33F3-L34E5         $ff0e   INT step 1
                    fcb       L33F9-L34E5         $ff14   INT step <>1
                    fcb       L343E-L34E5         $ff59   REAL step 1
                    fcb       L3446-L34E5         $ff61   REAL step <>1

* REAL NEXT STEP 1
L345A               ldy       <u0046              ??? Get subroutine stack ptr
                    clrb
                    bsr       L348E
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
                    std       ,u
                    ldd       3,y
                    std       2,u
                    endc
                    lda       5,y
                    sta       4,u
* Incrementing REAL STEP value
L347E               ldb       #2
                    bsr       L348E
                    leax      6,x
                    lbsr      L4449               Do REAL # compare
                    lble      L33CC               Loop again if still too small
                    leax      3,x
                    rts

L348E               ldd       b,x
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

L34A5               ldy       <u0046
                    clrb
                    bsr       L348E
                    stu       <u00D2
                    ldb       #$04
                    bsr       L348E
                    lda       4,u
                    sta       <u00D1
                    lbsr      L3FB1               Inc current FOR/NEXT value by STEP (Do REAL Add)
                    ldu       <u00D2
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
                    bcc       L347E               Positive, use that direction check
* Decrementing REAL STEP value
L34CC               ldb       #$02
                    bsr       L348E
                    leax      6,x
                    lbsr      L4449               Do REAL compare
                    lbge      L33CC               Still bigger, keep looping
                    leax      3,x
L34DB               rts

L34DC               ldb       <u0034              Get flag byte
                    bitb      #$01                Least sig bit set?
                    beq       L34DB               No, return
                    jsr       <u001B
                    fcb       $1c

L34ED               ldb       ,x+
                    cmpb      #$82
                    beq       L3515
                    bsr       L3560
                    bsr       L3508
                    ldb       -1,x
                    cmpb      #$47
                    bne       L34FF
                    bsr       L3508
L34FF               lbsr      L33CC
                    leay      >L34E5,pc           Point to table
                    lbra      L33EA

L3508               ldd       ,x++
                    addd      <u0031
                    pshs      d
                    jsr       <u0016
                    ldd       1,y
                    std       [,s++]
                    rts

L3515               bsr       L356F
                    bsr       L3523
                    ldb       -$01,x
                    cmpb      #$47
                    bne       L34FF
                    bsr       L3523
                    bra       L34FF

L3523               ldd       ,x++
                    addd      <u0031
                    pshs      d
                    jsr       <u0016
                    bra       L3579

* LET
L352D               jsr       <u0016              Get var type
L352F               cmpa      #4                  Numeric or Boolean?
                    blo       L3537               Yes, skip ahead
                    pshs      u                   Preserve U
                    ldu       <u003E              ??? Get max var size for string or array
L3537               pshs      u,a                 Save Size or Ptr & var type
                    leax      1,x
                    jsr       <u0016
L353D               puls      a
                    lsla                          x2 for offset into branch table
                    leau      <L3545,pc           Point to branch table
                    jmp       a,u                 Jump to routine

L3545               bra       L355B               LET - Byte
                    bra       L356A               LET - Integer
                    bra       L3579               LET - Real
                    bra       L355B               LET - Boolean
                    bra       L359C               LET - String
                    bra       L35C1               Let - Array

L3551               ldd       ,x
                    addd      <u0031
                    pshs      d
                    leax      3,x
                    jsr       <u0016
* LET - Byte/Boolean
L355B               ldb       2,y                 Get byte/boolean value
                    stb       [,s++]              Save at address on stack, eat stack & return
                    rts

L3560               ldd       ,x
                    addd      <u0031
                    pshs      d
                    leax      3,x
                    jsr       <u0016
* LET - Integer
L356A               ldd       1,y                 Get integer value
                    std       [,s++]              Save at address on stack, eat stack & return
                    rts

L356F               ldd       ,x
                    addd      <u0031
                    pshs      d
                    leax      3,x
                    jsr       <u0016
* LET - Real
L3579               puls      u
                    ldd       1,y                 Copy 5 bytes from Y+1 to U
                    std       ,u
                    ldd       3,y
                    std       2,u
                    lda       5,y
                    sta       4,u
                    rts

L3588               ldd       ,x
                    addd      <u0066
                    tfr       d,u
                    ldd       ,u
                    addd      <u0031
                    pshs      d
                    ldd       2,u
                    pshs      d
                    leax      3,x
                    jsr       <u0016
* LET - String
L359C               puls      u,d
                    tstb
                    bne       L35A2
                    deca
L35A2               sta       <u003E
                    ldy       1,y
                    sty       <u0048
* Block copy up to $FF (string terminator)
L35AA               lda       ,y+
                    sta       ,u+
                    cmpa      #$FF                End of string?
                    beq       L35B9               Yes, skip ahead
                    decb                          Dec string size counter
                    bne       L35AA               More left, continue copying
                    dec       <u003E
                    bpl       L35AA
L35B9               clra
                    rts

* LET - Array
L35C1               puls      u,d
                    cmpd      3,y
                    bls       L35CA
                    ldd       3,y
L35CA               ldy       1,y
                    exg       y,u
                    jsr       <u001E              Return from routine
                    fcb       $06

L35D2               jsr       <u0016
                    ldd       1,y
                    pshs      d
                    jsr       <u0016
                    ldb       2,y
                    stb       [,s++]
                    rts

L35DF               lbsr      L3856
                    lda       <u002E
                    sta       <u007F
                    leax      >L32CB,pc           Point to 'STOP encountered'
                    lbsr      L375F
                    lbra      L1CC7

L35F3               lbsr      L3856
L3233               jsr       <u001B              Use module header jump vector #1
                    fcb       $18

L35F9               ldd       ,x
                    leax      3,x
L35FD               ldy       <u0031
                    ldu       <$14,y
                    cmpu      <u004A
                    bhi       L360D
                    ldb       #$35                Subroutine stack overflow error
                    lbra      L39FB

L360D               stx       ,--u
                    stu       <$14,y
                    stu       <u0046
                    addd      <u005E
                    tfr       d,x
                    rts

L3619               ldy       <u0031
                    cmpy      <$14,y
                    bhi       L3627
                    ldb       #$36                Subroutine stack underflow error
                    lbra      L39FB

L3627               ldu       <$14,y
                    ldx       ,u++
                    stu       <$14,y
                    stu       <u0046
                    rts

L3632               ldd       ,x
                    cmpa      #$1E
                    beq       L366D
                    jsr       <u0016
                    ldd       ,x
                    ifne      H6309
                    lsld
                    lsld
                    else
                    lslb
                    rola
                    lslb
                    rola
                    endc
                    addd      #$0002
                    leau      d,x
                    pshs      u
                    ldd       1,y
                    ble       L366B
                    cmpd      ,x++
                    bhi       L366B
                    subd      #$0001
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
                    ldd       d,x
* 6809 - Change to PSHS B/PULS X,B
                    pshs      d
                    ldb       ,x
                    cmpb      #$22
                    puls      x,d
                    beq       L35FD
                    addd      <u005E
                    tfr       d,x
L366A               rts

L366B               puls      pc,x

L366D               ldu       <u0031
                    cmpb      #$20
                    bne       L3682
                    ldd       2,x
                    addd      <u005E
                    std       <$11,u
                    lda       #$01
                    sta       <$13,u
                    leax      5,x
                    rts

L3682               clr       <$13,u
                    leax      2,x
                    rts

L3688               bsr       L36A6
                    ldb       #%00001011          Read/Write/Public Read
                    os9       I$Create            Create the file
                    bra       L3696

L3691               bsr       L36A6
                    os9       I$Open
L3696               lbcs      L39FB
                    puls      u,b
                    cmpb      #$01
                    bne       L36A2
                    clr       ,u+
L36A2               sta       ,u
                    puls      pc,x

L36A6               leax      1,x
                    lbsr      L3779
                    leax      1,x
                    jsr       <u0016
                    lda       #$03
                    cmpb      #$4A
                    bne       L36B7
                    lda       ,x++
L36B7               ldu       3,s
                    stx       3,s
                    ldx       1,y
                    jmp       ,u

L36BF               lbsr      L37B6
                    jsr       <u0016
                    ldb       #$0E
                    lbsr      L3230
                    lbcs      L39FD
                    rts

* Input prompt?
L36CE               fcc       '? '
                    fcb       $ff

* Illegal input error message
L36D1               fcc       '** Input error - reenter **'
                    fcb       $0d,$ff

L36EE               lda       <u002E
                    lbsr      L37B6
                    lda       #$2C
                    sta       <u00DD
                    pshs      x
L36F9               ldx       ,s
                    ldb       ,x
                    cmpb      #$90
                    bne       L3709
                    jsr       <u0016
                    pshs      x
                    ldx       1,y
                    bra       L370E

L3709               pshs      x
                    leax      <L36CE,pc           Point to '? '
L370E               bsr       L375F
                    puls      x
                    lda       <u007F
                    cmpa      <u002E
                    bne       L371C
                    lda       <u002D
                    sta       <u007F
L371C               ldb       #$06
L371E               bsr       L3230
                    bcc       L3730
                    cmpb      #$03
                    lbne      L39FD
                    lbsr      L3A23
                    clr       <u0036              Clear out error code
                    bra       L36F9

L3730               bsr       L3743
                    bcc       L373B
                    leax      <L36D1,pc           Print 'Input error re-enter'
                    bsr       L375F
                    bra       L36F9

L373B               ldb       ,x+
                    cmpb      #$4B
                    beq       L3730
                    puls      pc,d

L3743               bsr       L3779
                    ldb       ,s
                    addb      #$07
                    ldy       <u0046
                    bsr       L3230
                    lbcc      L353D
                    lda       ,s
L3755               cmpa      #$04
                    bcs       L375B
                    leas      2,s
L375B               leas      3,s
                    coma
                    rts

L375F               pshs      y
                    leas      -6,s
                    leay      ,s
                    stx       1,y
                    ldd       <u0080
                    std       <u0082
                    ldb       #$05
                    bsr       L3230
                    clrb
                    bsr       L3230               call L5084, function 2, sub-function 0 (B)
                    leas      6,s
                    puls      pc,y

L3230               jsr       <u002A              Use module header jump vector #6
                    fcb       $02                 Function code

L3779               lda       ,x+
                    cmpa      #$0E
                    bne       L3783
                    jsr       <u0016
                    bra       L37A8

L3783               suba      #$80
                    cmpa      #$04
                    blo       L379E
                    beq       L3790
                    lbsr      L3224
                    bra       L37A8

L3790               ldd       ,x++
                    addd      <u0066
                    tfr       d,u
                    ldd       2,u
                    std       <u003E
                    ldd       ,u
                    bra       L37A0

L379E               ldd       ,x++
L37A0               addd      <u0031
                    tfr       d,u
                    lda       -3,x
                    suba      #$80
L37A8               puls      y
                    cmpa      #$04
                    blo       L37B2
                    pshs      u
                    ldu       <u003E
L37B2               pshs      u,a
                    jmp       ,y

L37B6               ldb       ,x
                    cmpb      #$54
                    bne       L37C8
                    leax      1,x
                    jsr       <u0016
                    cmpb      #$4B
                    beq       L37C6
                    leax      -1,x
L37C6               lda       2,y
L37C8               sta       <u007F
                    rts

L37CB               ldb       ,x
                    cmpb      #$54
                    bne       L37F5
                    bsr       L37B6
                    clr       <u00DD
                    cmpb      #$4B
                    bne       L37DB
                    leax      -1,x
L37DB               ldb       #$06                Call L5084, function 2, sub-function 6 (B)
                    bsr       L3230               (Do ReadLn into temp buff, max of 256 bytes)
                    bcc       L37EE               No error in ReadLn, skip ahead
                    cmpb      #E$PrcAbt           ??? Process aborted error?
                    beq       L37DB               Yes, try to do ReadLn again
L37E6               lbra      L39FD

L37E9               lbsr      L3743
                    bcs       L37E6
L37EE               ldb       ,x+
                    cmpb      #$4B
                    beq       L37E9
                    rts

L37F5               bsr       L384F
                    beq       L3832
L37F9               bsr       L3802
                    ldb       ,x+
                    cmpb      #$4B
                    beq       L37F9
                    rts

L3802               lbsr      L3779
                    bsr       L3834
                    lda       ,s
                    bne       L380C
                    inca
L380C               cmpa      ,y
                    lbeq      L353D
                    cmpa      #$02
                    blo       L381C
                    beq       L3828
L3818               ldb       #$47                Illegal Expression Type
                    bra       L383C

L381C               lda       ,y                  Get var type
                    cmpa      #$02                Real #?
                    bne       L3818               No, exit with Illegal Expression Type erro
                    bsr       L3227               Call FIX (REAL to INT) routine
                    lbra      L353D

L3227               jsr       <u0027
                    fcb       $0c
L322A               jsr       <u0027
                    fcb       $0e

L3828               cmpa      ,y
                    bcs       L3818
                    bsr       L322A
                    lbra      L353D

L3832               leax      1,x
L3834               pshs      x
                    ldx       <u0039
                    bne       L383F
                    ldb       #$4F                Missing Data Statement error
L383C               lbra      L39FB

L383F               jsr       <u0016
                    cmpb      #$4B
                    beq       L384B
                    ldd       ,x
                    addd      <u005E
                    tfr       d,x
L384B               stx       <u0039
                    puls      pc,x

L384F               cmpb      #$3F
                    beq       L3855
                    cmpb      #$3E
L3855               rts

L3856               lda       <u002E
                    lbsr      L37B6
                    ldd       <u0080
                    std       <u0082
                    ldb       ,x+
                    cmpb      #$49
                    beq       L38A3
L3865               bsr       L384F
                    beq       L388B
L3869               cmpb      #$4B
                    beq       L387F
                    cmpb      #$51
                    beq       L3883
                    leax      -1,x
                    jsr       <u0016
                    ldb       ,y
                    addb      #$01
                    bsr       L389B
                    ldb       -1,x
                    bra       L3865

L387F               ldb       #$0D
                    bsr       L389B
L3883               ldb       ,x+
                    bsr       L384F
                    bne       L3869
                    bra       L388F

L388B               ldb       #$0C                L5084, function 2, sub-function C
                    bsr       L389B               (WritLn a Carriage return)

L388F               clrb                          L5084, function 2, sub-function 0
                    bsr       L389B               (WritLn the temp buffer)
                    lda       <u00DE
                    clr       <u00DE
                    tsta
                    bne       L38A0
L389A               rts

L389B               lbsr      L3230               Call <u002A, function 2
                    bcc       L389A               If no error, return
L38A0               lbra      L39FD               Error from WritLn, report it

L38A3               jsr       <u0016
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
                    beq       L38D2
                    leax      -1,x
                    ldb       #$11
                    lbsr      L3230
                    bcc       L38B5
                    puls      u,d
                    std       <u004A
                    stu       <u0046
                    bra       L38A0

L38D2               leay      <L388F,pc           Point to routine
                    bra       L38DA

L38D7               leay      <L388B,pc           Point to routine
L38DA               puls      u,d
                    std       <u004A
                    stu       <u0046
                    jmp       ,y

L38E2               lda       <u002E
                    lbsr      L37B6
                    ldu       <u0080
                    stu       <u0082
                    ldb       ,x+
                    lbsr      L384F
                    beq       L3914
                    cmpb      #$4B
                    beq       L3902
                    leax      -1,x
                    bra       L3902

L38FA               clra
                    ldb       #$12
                    lbsr      L3230
                    bcs       L38A0
L3902               jsr       <u0016
                    ldb       ,y
                    addb      #$01
                    lbsr      L3230
                    bcs       L38A0
                    ldb       -$01,x
                    lbsr      L384F
                    bne       L38FA
L3914               lbra      L388B

L3917               bsr       L392A
                    os9       I$Read
                    bra       L3923

L391E               bsr       L392A
                    os9       I$Write
L3923               leax      ,u
                    bcc       L3949
L3927               lbra      L39FB

L392A               lbsr      L37B6
                    lbsr      L3779
                    leau      ,x
                    puls      a
                    cmpa      #$04
                    bhs       L3943
                    leax      >L3B5B,pc           Point to 4 entry, 1 byte table
                    ldb       a,x
                    clra
                    tfr       d,y                 Y=table entry
                    bra       L3945

L3943               puls      y
L3945               puls      x
                    lda       <u007F
L3949               rts

L394A               lbsr      L37B6
                    os9       I$Close             Close path
                    bcs       L3927               Error,
                    cmpb      #$4B
                    beq       L394A
                    rts

L3957               ldb       ,x+
                    cmpb      #';
                    beq       L3967
                    ldu       <u002F              Get ptr to current procedure
                    ldd       $13,u
L3962               addd      <u005E
                    std       <u0039
                    rts

L3967               ldd       ,x
                    addd      #$0001
                    leax      3,x
                    bra       L3962

L3970               jsr       <u0016
                    pshs      x
                    ldx       1,y                 Get ptr to full pathlist
                    os9       I$Delete            Delete file
L3979               bcs       L3927               Error, deal with it
                    puls      pc,x                Restore X & return

L397D               jsr       <u0016
                    lda       #READ.              Open directory in Read mode
L3981               pshs      x                   Preserve X
                    ldx       1,y                 Get ptr to full path list
                    os9       I$ChgDir            Change directory
                    bra       L3979

L398A               jsr       <u0016
                    lda       #EXEC.              Execution directory
                    bra       L3981               Go change execution directory

L3990               lbsr      L3779
                    ldy       <u0046
                    leay      -6,y
                    ldb       <u007F
                    clra
                    std       1,y
                    lbra      L353D

L39A0               jsr       <u0016
                    ldy       1,y                 Get what will be param area ptr
                    pshs      u,y,x
                    bsr       L320C
                    puls      u,y,x
                    bsr       L39E0               Set regs for chain to SHELL
                    sts       <u00B1              Save stack ptr
                    lds       <u0080              Get other stack ptr
                    os9       F$Chain             Chain to other program
                    lds       <u00B1              Chain obviously didn't work, get old SP back
                    bra       L39FB               Process error code

L320C               jsr       <u001B
                    fcb       $0e

L39BC               jsr       <u0016
                    pshs      u,x
                    ldy       1,y
                    bsr       L39E0               Do stuff & point X to 'shell'
                    os9       F$Fork              Fork a shell
                    bcs       L39FB               If error, go to error routine
                    pshs      a                   Save process #
L39CC               os9       F$Wait              Wait until child process is done
                    cmpa      ,s                  Got wakeup signal, was it our child?
                    bne       L39CC               No, keep waiting
                    leas      1,s                 Yes, eat process # off of stack
                    tstb                          Error?
                    bne       L39FB               Yes, go to error routine
                    puls      pc,u,x              No, restore regs & return

L39DA               fcc       'SHELL'
                    fcb       C$CR

* Entry: Y=Ptr to parameter area
L39E0               ldx       <u0048
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

L39F7               jsr       <u0016
                    ldb       2,y
* Error routine from forking a shell?
L39FB               stb       <u0036              Save error code
L39FD               ldu       <u0031
                    beq       L3A1B
                    tst       <$13,u
                    beq       L3A14
                    lds       5,u
                    ldx       <$11,u
                    ldd       <$14,u
                    std       <u0046
                    lbra      L3371

L3A14               bsr       L3A23
                    bsr       L3A73
                    lbra      L1CC7

* Entry: B=Error code
L3A1B               lbsr      L1CC1               Print error message
                    lbra      L1CC7

L3A21               fcb       $0E                 Display Alpha code (for VDGInt screen)
                    fcb       $ff                 String terminator

L3A23               leax      <L3A21,pc           Point to force alpha string code
                    lbsr      L375F               Go print it out to shut off any VDGInt gfx screen
                    ldx       <u005C
                    leay      ,x
                    bsr       L3218
                    clr       <u0074
                    lbsr      L3236
                    ldb       <u0036              Get error code
                    lbsr      L1CC1               Print error message
                    jsr       <u001B              Call function & return from there
                    fcb       $18

* BASE 0
L3A3D               clrb                          Save 0 in <42, incx, return
                    bra       L3A42

* BASE 1
L3A40               ldb       #1                  Save 1 in <42, incx, return
L3A42               clra
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

L3A4E               exg       x,pc                Jump to routine pointed to by X
                    rts                           If EXG X,PC done again, return from here

L3A51               leay      ,x
                    bsr       L3218
                    leax      ,y
                    rts

L3A59               ldb       #$33                Line with compiler error
                    bra       L39FB

L3A5D               lda       #$01
                    bra       L3A62

L3A61               clra
L3A62               ldu       <u0031
                    sta       1,u
                    leax      1,x
                    rts

L3A69               lda       <u0034              Get signal flags
                    bita      #$01                LSb set?
                    bne       L3A89               Yes, exit
                    ora       #$01                force it on
                    bra       L3A7B

L3A73               lda       <u0034              Get signal flags
                    bita      #$01                Least sig set?
                    beq       L3A89               Yes, return
                    anda      #$FE                Clear least sig
L3A7B               sta       <u0034              Save modified copy
                    ldd       <u0017              Swap JMP ptrs between L3C32 & L3D41
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
                    beq       L3AB6
                    ldy       <u0048              Get destination ptr for copy
                    ldx       <u003E              Get max size of copy
L3A9A               lda       ,u+                 Get byte
                    leax      -1,x                Bump counter down
                    beq       L3AA8               Finished, skip ahead
                    sta       ,y+                 Save char
                    cmpa      #$FF                String terminator?
                    bne       L3A9A               No, keep copying
                    lda       ,--y                Yes, get last char before terminator
L3AA8               ora       #$80                Set hi bit on last char
                    sta       ,y                  Save it out
                    ldy       <u0048
                    bsr       L3212
                    bcs       L3AF4
                    leau      ,x
L3AB6               ldd       ,u
                    bne       L3AC8
                    ldy       <u00D2
                    leay      3,y
                    bsr       L3212
                    bcs       L3AF4
                    ldd       ,x
                    std       ,u
L3AC8               ldx       ,s
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
                    bsr       L3B5F
                    stx       $B,u
                    puls      x                   Get ptr to module to be called
                    lda       M$Type,x            Get module type/language
                    beq       L3B23               If 0 (un-packed BASIC09), skip ahead
                    cmpa      #$22                Is it a packed RUNB subroutine module?
                    beq       L3B23               Yes, skip ahead
                    cmpa      #$21                Is it an ML subroutine module?
                    beq       L3AF9               Yes, skip ahead
L3AF4               ldb       #$2B                If none of the above, Unknown Procedure Error
L3AF6               lbra      L39FB

* ML subroutine call goes here
* Entry: X=Ptr to ML subroutine module to be called
L3AF9               ldd       5,u
                    pshs      d
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
                    leay      >L32DD,pc           Point to routine
                    jsr       d,x                 Call ML subroutine module
                    ldu       <u0031              Get ptr to U block of data from above
                    lds       5,u                 Get old stack ptr back
                    puls      x                   Get original 5,u value
                    stx       5,u                 Save it back
                    bcc       L3B3C               If no error, resume program
                    bra       L3AF6               Notify user of error from ML subroutine

* BASIC09 or RUNB module subroutine call goes here
L3B23               lbsr      L3A73               If line with compiler err flg set, swap 17/19 vectors
                    lda       <u0034              Get flags
                    anda      #$7F                Mask out pending signal flag
                    sta       <u0034              Save flags back
                    lbsr      L32DD               Go check for line with compiler error/stack ovrflw
                    lda       ,u
                    bita      #$01
                    beq       L3B3C
                    lbsr      L3A69
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
                    lbsr      L3351
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
L3B5F               pshs      u
                    ldb       ,x+
                    clra                          Set flag on stack to 0
                    pshs      x,a
                    cmpb      #$4D
                    bne       L3BE1
                    leay      ,s                  Point Y to flag byte on stack
L3B6C               pshs      y                   Save ptr to flag byte
                    ldb       ,x
                    cmpb      #$0E
                    beq       L3BA3
                    jsr       <u0016
                    leax      -1,x
                    cmpa      #2                  Real variable?
                    beq       L3B86               Yes, skip ahead
                    cmpa      #4                  String/complex type variable?
                    beq       L3B93               Yes, set up string stuff
                    ldd       1,y                 Byte/Integer/Boolean - Get value from var packet
                    std       4,y                 Duplicate it later in var packet
                    lda       ,y                  Get variable type again
L3B86               ldb       #6                  Get size of var packet
                    leau      <L3B5B,pc           Point to var size table
                    subb      a,u                 Calculate ptr to beginning of actual var value
                    leau      b,y                 Bump U to point to first byte of actual var value
                    stu       <u0046              ??? Save some sort of variable ptr?
                    bra       L3BA7

* String being passed?
L3B93               ldu       1,y                 Get ptr to actual string data
                    ldd       <u0048
                    subd      <u004A              Subtract ptr to next free byte in workspace
                    std       <u003E              Save result as ptr to string/complex
                    ldd       <u0048
                    std       <u004A              Save new ptr to next free byte in workspace
                    lda       #4                  Variable type=String/complex
                    bra       L3BA7

L3BA3               leax      1,x
                    jsr       <u0016
L3BA7               puls      y                   Get ptr to flag byte
                    inc       ,y                  Bump up flag
                    cmpa      #4                  Variable type numeric?
                    blo       L3BB3               Yes, skip ahead
                    pshs      u                   String/complex, save var data ptr
                    ldu       <u003E              Get some ptr
L3BB3               pshs      u,a                 Save variable ptr, variable type
                    ldb       ,x+
                    cmpb      #$4B
                    beq       L3B6C
                    leax      1,x
                    stx       1,y
                    leax      <L3B5B,pc           Point to 4 entry, 1 byte table
                    ldu       <u0046
                    stu       <u0040              Save ptr to end of parm packets
L3BC6               puls      b                   Get variable type
                    cmpb      #4                  Is it a numeric type?
                    blo       L3BD0               Yes, go process
                    puls      d                   No, get variable ptr again
                    bra       L3BD3               Go handle string/complex

L3BD0               ldb       b,x                 Get size of variable
                    clra                          D=size
L3BD3               std       ,--u                Save size of variable into parm area
                    puls      d                   Get ptr to variable
                    std       ,--u                Save ptr to variable
                    dec       ,y                  Any vars left to pass?
                    bne       L3BC6               ??? Yes, continue building parm area
                    leay      ,u                  ??? No, point Y to parm area
                    bra       L3BE7

L3BE1               ldy       <u0046
                    sty       <u0040
L3BE7               tfr       y,d
                    subd      <u004A
                    lblo      L3302
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
                    fdb       L4449-L3C19         A Set flags for Real comparison
                    fdb       L453B-L3C19         C FIX (Round & convert REAL to INTEGER)
                    fdb       L4503-L3C19         E FLOAT (Convert INTEGER/BYTE to REAL)

* Function routines
* Negative offsets from base of table @ L3CB5
                    fdb       L4F1E-L3CB5         MID$
                    fdb       L4EE2-L3CB5         LEFT$
                    fdb       L4EFA-L3CB5         RIGHT$
                    fdb       L4EC7-L3CB5         CHR$
                    fdb       L4FA4-L3CB5         STR$ (for INTEGER)
                    fdb       L4FA8-L3CB5         STR$ (for REAL)
                    fdb       L4FF8-L3CB5         DATE$
                    fdb       L4FCC-L3CB5         TAB
                    fdb       L453B-L3CB5         FIX (round & convert REAL to INTEGER)
                    fdb       L45A0-L3CB5         ??? (calls fix but eats 1 var 1st)
                    fdb       L45A7-L3CB5         ??? (calls fix but eats 2 vars 1st)
                    fdb       L4503-L3CB5         FLOAT (convert INTEGER to REAL)
                    fdb       L4534-L3CB5         ??? (calls float though)
                    fdb       L4395-L3CB5         Byte - LNOT
                    fdb       L3EA8-L3CB5         Integer - Negate a number
                    fdb       L3FA4-L3CB5         Real - Negate a number
                    fdb       L4380-L3CB5         Byte - LAND
                    fdb       L4386-L3CB5         Byte - LOR
                    fdb       L438C-L3CB5         Byte - LXOR
                    fdb       L43FF-L3CB5         > : Integer/Byte relational
                    fdb       L4443-L3CB5         > : Real relational
                    fdb       L43D1-L3CB5         > : String relational
                    fdb       L43D7-L3CB5         < : Integer/Byte relational
                    fdb       L4425-L3CB5         < : Real relational
                    fdb       L43B3-L3CB5         < : String relational
                    fdb       L43E7-L3CB5         <> or >< : Integer/Byte relational
                    fdb       L4431-L3CB5         <> or >< : Real relational
                    fdb       L43C5-L3CB5         <> or >< : String relational
                    fdb       L441D-L3CB5         <> or >< : Boolean relational
                    fdb       L43EF-L3CB5         = : Integer/Byte relational
                    fdb       L4437-L3CB5         = : Real relational
                    fdb       L43BF-L3CB5         = : String relational
                    fdb       L4415-L3CB5         = : Boolean relational
                    fdb       L43F7-L3CB5         >= or => : Integer/Byte relational
                    fdb       L443D-L3CB5         >= or => : Real relational
                    fdb       L43CB-L3CB5         >= or => : String Relational
                    fdb       L43DF-L3CB5         <= or =< : Integer/Byte relational
                    fdb       L442B-L3CB5         <= or =< : Real relational
                    fdb       L43B9-L3CB5         <= or =< : String Relational
                    fdb       L3EAF-L3CB5         Integer - Add
                    fdb       L3FB1-L3CB5         Real - Add
                    fdb       L44E5-L3CB5         String add
                    fdb       L3EB8-L3CB5         Integer - Subtract
                    fdb       L3FAB-L3CB5         Real - Subtract
                    fdb       L3EC1-L3CB5         Integer - Multiply
                    fdb       L40CC-L3CB5         Real Multiply
                    fdb       L3F1C-L3CB5         Integer - Divide
                    fdb       L422D-L3CB5         Real Divide
                    fdb       L4336-L3CB5         Real Exponent\ Probably for both ^ & **
                    fdb       L4336-L3CB5         Real Exponent/ Hard coding for 0^x & x^1
                    fdb       L3D6C-L3CB5         DIM
                    fdb       L3D6C-L3CB5         DIM
                    fdb       L3D6C-L3CB5         DIM
                    fdb       L3D6C-L3CB5         DIM
                    fdb       L3D72-L3CB5         PARAM
                    fdb       L3D72-L3CB5         PARAM
                    fdb       L3D72-L3CB5         PARAM
                    fdb       L3D72-L3CB5         PARAM
                    fdb       $0000               Unused function entries (maybe use for LONGINT?)
                    fdb       $0000
                    fdb       $0000
                    fdb       $0000
                    fdb       $0000
                    fdb       $0000

* Jump table (base is L3CB5)
L3CB5               fdb       L3E81-L3CB5         Copy BYTE var to temp pool
                    fdb       L3E97-L3CB5         Copy INTEGER var to temp pool
                    fdb       L3F8D-L3CB5         Copy REAL var to temp pool
                    fdb       L436E-L3CB5         Copy BOOLEAN var to temp pool
                    fdb       L44C7-L3CB5         Copy STRING var to temp pool (max 256 chars)
                    fdb       L3D59-L3CB5         Copy DIM array
                    fdb       L3D59-L3CB5         Copy DIM array
                    fdb       L3D59-L3CB5         Copy DIM array
                    fdb       L3D59-L3CB5         Copy DIM array
                    fdb       L3D68-L3CB5         Copy PARAM array
                    fdb       L3D68-L3CB5         Copy PARAM array
                    fdb       L3D68-L3CB5         Copy PARAM array
                    fdb       L3D68-L3CB5         Copy PARAM array
                    fdb       L3E7D-L3CB5         Copy BYTE constant to temp pool - CHECK IF USED
                    fdb       L3E93-L3CB5         Copy INTEGER constant to temp pool
                    fdb       L3F7C-L3CB5         Copy REAL constant to temp pool
                    fdb       L4497-L3CB5         Copy STRING constant to temp pool
                    fdb       L3E93-L3CB5         Copy INTEGER constant to temp pool
                    fdb       L473F-L3CB5         ADDR
                    fdb       L473F-L3CB5         ADDR
                    fdb       L4751-L3CB5         SIZE
                    fdb       L4751-L3CB5         SIZE
                    fdb       L45F1-L3CB5         POS
                    fdb       L45E3-L3CB5         ERR
                    fdb       L46A2-L3CB5         MOD for Integer #'s
                    fdb       L46AA-L3CB5         MOD for Real #'s
                    fdb       L4DDA-L3CB5         RND
                    fdb       L4B03-L3CB5         PI
                    fdb       L4F77-L3CB5         SUBSTR
                    fdb       L45D5-L3CB5         SGN for Integer
                    fdb       L45C7-L3CB5         SGN for Real
                    fdb       L4A82-L3CB5         Transcendental ???
                    fdb       L4AAF-L3CB5         Transcendental ???
                    fdb       L4ABD-L3CB5         Transcendental ???
                    fdb       L4927-L3CB5         Transcendental ???
                    fdb       L4968-L3CB5         Transcendental ???
                    fdb       L4A03-L3CB5         Transcendental ???
                    fdb       L4864-L3CB5         EXP
                    fdb       L45B5-L3CB5         ABS for Integer #'s
                    fdb       L45AE-L3CB5         ABS for Real #'s
                    fdb       L47AB-L3CB5         LOG
                    fdb       L479F-L3CB5         LOG10
                    fdb       L45F5-L3CB5         SQR \ Square root
                    fdb       L45F5-L3CB5         SQRT/
                    fdb       L4503-L3CB5         FLOAT
                    fdb       L46C6-L3CB5         INT (of real #)
                    fdb       L45F0-L3CB5         ??? RTS
                    fdb       L453B-L3CB5         FIX
                    fdb       L4503-L3CB5         FLOAT
                    fdb       L45F0-L3CB5         ??? RTS
                    fdb       L4705-L3CB5         SQuare of integer
                    fdb       L470E-L3CB5         SQuare of real
                    fdb       L45C0-L3CB5         PEEK
                    fdb       L477A-L3CB5         LNOT of Integer
                    fdb       L471F-L3CB5         VAL
                    fdb       L4EAB-L3CB5         LEN
                    fdb       L4EBD-L3CB5         ASC
                    fdb       L477F-L3CB5         LAND of Integer
                    fdb       L478F-L3CB5         LOR of Integer
                    fdb       L4787-L3CB5         LXOR of Integer
                    fdb       L4769-L3CB5         Force Boolean to TRUE
                    fdb       L476E-L3CB5         Force Boolean to FALSE
                    fdb       L5035-L3CB5         EOF
                    fdb       L4F5F-L3CB5         TRIM$

* Jump table, base is L3D35
L3D35               fdb       L3E87-L3D35         Convert Byte to Int (into temp var)
                    fdb       L3E9D-L3D35         Copy Int var into temp var
                    fdb       L3F93-L3D35         Copy Real var into temp var
                    fdb       L4374-L3D35         ??? Copy Boolean into temp var
                    fdb       L44D7-L3D35         ??? Copy string to expression stack
                    fdb       L44F6-L3D35         ??? Copy D&U regs into temp var type 5

L3D41               ldy       <u0046
                    ldd       <u004A
                    std       <u0048
                    bra       L3D51

L3D4A               lslb                          2 bytes per entry
                    ldu       <u0010              Get ptr to jump table (could be L3CB5)
                    ldd       b,u                 Get offset
                    jsr       d,u                 Call subroutine
L3D51               ldb       ,x+                 Get next byte
                    bmi       L3D4A               If high bit set, need to call another subroutine
                    clra                          Otherwise, clear carry
                    lda       ,y
                    rts

* Copy DIM array to temp var pool
L3D59               bsr       L3D80

* POSSIBLE MAIN ENTRY POINT FOR MATH & STRING ROUTINES
L3D5B               pshs      pc,u                Save U & PC on stack
                    ldu       <u0012              Get ptr to jump table (L3D35)
                    lsla                          A=A*2 for 2 byte entries (note: 8 bit SIGNED)
                    ldd       a,u                 Get offset
                    leau      d,u                 Point to routine
                    stu       2,s                 Save over PC on stack
                    puls      pc,u                Restore U & jump to routine

* Copy PARAM array to temp var pool
L3D68               bsr       L3D78
                    bra       L3D5B

L3D6C               leas      2,s
                    lda       #$F2
                    bra       L3D82

L3D72               leas      $02,s
                    lda       #$F6
                    bra       L3D7A

L3D78               lda       #$89
L3D7A               sta       <u00A3
                    clr       <u003B
                    bra       L3D86

L3D80               lda       #$85
L3D82               sta       <u00A3
                    sta       <u003B
L3D86               ldd       ,x++
                    addd      <u0062
                    std       <u00D2
                    ldu       <u00D2
                    lda       ,u
                    anda      #$E0
                    sta       <u00CF
                    eora      #$80
                    sta       <u00CE
                    lda       ,u
                    anda      #$07
                    ldb       -$03,x
                    subb      <u00A3
                    pshs      d
                    lda       ,u
                    anda      #$18
                    lbeq      L3E3F
                    ldd       1,u
                    addd      <u0066
                    tfr       d,u
                    ldd       ,u
                    std       <u003C
                    lda       1,s
                    bne       L3DC4
                    lda       #$05
                    sta       ,s
                    ldd       2,u
                    std       <u003E
                    clra
                    clrb
                    bra       L3E17

L3DC4               leay      -6,y                Make room for temp var
                    clra                          Force value to 0 (integer)
                    clrb
                    std       1,y                 Save it
                    leau      4,u                 Bump U up
                    bra       L3DD5

L3DCE               ldd       ,u                  Get value from U
                    std       1,y                 Save in var space
                    lbsr      L3EC1               Call Integer Multiply routine
L3DD5               ldd       7,y
                    subd      <u0042
                    cmpd      ,u++
                    blo       L3DE3
                    ldb       #$37                Subscript out of range error
                    jsr       <u0024              Report it
                    fcb       $06

* Array subscript in range, process
L3DE3               addd      1,y
                    std       7,y
                    dec       1,s
                    bne       L3DCE
* NOTE: IF FOLLOWING COMMENTS ARE ACCURATE, SHOULD USE LDA, DECA TRICK
                    lda       ,s                  ??? Get variable type?
                    beq       L3DFF               If Byte, skip ahead
                    cmpa      #$02                Real?
                    blo       L3E03               No, integer, skip ahead
                    beq       L3E0B               Real, skip ahead
                    cmpa      #$04                String?
                    blo       L3DFF               No, boolean - treat same as Byte
                    ldd       ,u                  String - do this
                    std       <u003E
                    bra       L3E0E

* BYTE or BOOLEAN
L3DFF               ldd       7,y                 Get offset to entry in array we want
                    bra       L3E07

* INTEGER
L3E03               ldd       7,y                 Get offset to entry in array we want
                    lslb                          x2 since Integers are 2 bytes/entry
                    rola
L3E07               leay      $C,y
                    bra       L3E17

* REAL
L3E0B               ldd       #5                  x5 since Real's are 5 bytes/entry
L3E0E               std       1,y                 Save for Integer multiply routine
                    lbsr      L3EC1               Go do Integer multiply
                    ldd       1,y                 Get offset to entry we want
                    leay      6,y                 Eat temp var.
L3E17               tst       <u00CE
                    bne       L3E33
                    pshs      d
                    ldd       <u003C
                    addd      <u0031
                    cmpd      <u0040
                    bhs       L3E78
                    tfr       d,u
                    puls      d
                    cmpd      2,u
                    bhi       L3E78
                    addd      ,u
                    bra       L3E73

L3E33               addd      <u003C
                    tst       <u003B
                    bne       L3E71
L3E39               addd      1,y
                    leay      6,y                 Eat temp var.
                    bra       L3E73

L3E3F               lda       ,s                  ??? Get var type
                    cmpa      #$04                Set CC - Is it string type?
                    ldd       1,u
                    blo       L3E51               No, either numeric or boolean, skip ahead
* String or complex
                    addd      <u0066
                    tfr       d,u
                    ldd       2,u
                    std       <u003E
                    ldd       ,u
L3E51               tst       <u003B
                    beq       L3E39
                    addd      <u0031
                    tfr       d,u
                    tst       <u00CE
                    bne       L3E75
                    cmpd      <u0040
                    bhs       L3E78
                    ldd       <u003E
                    cmpd      2,u
                    blo       L3E6D
                    ldd       2,u
                    std       <u003E
L3E6D               ldu       ,u
                    bra       L3E75

L3E71               addd      <u0031
L3E73               tfr       d,u
L3E75               clra
                    puls      pc,d

L3E78               ldb       #$38                Parameter error
                    jsr       <u0024
                    fcb       $06

* Copy Byte constant to temp pool
L3E7D               leau      ,x+
                    bra       L3E87

* Copy Byte variable to temp pool
L3E81               ldd       ,x++                Get offset to variable we want
                    addd      <u0031              Add to start of string pool address
                    tfr       d,u                 Move to indexable register
L3E87               ldb       ,u                  Get BYTE value
                    clra                          Force to integer type
                    leay      -6,y                Make room for new variable
                    std       1,y                 Save integer value
                    lda       #1                  Save type as integer & return
                    sta       ,y
                    rts

* Copy Integer constant to temp pool
L3E93               leau      ,x++
                    bra       L3E9D

* Copy integer var into temp var
L3E97               ldd       ,x++                Get offset to var we want
                    addd      <u0031              Add to start of variable pool
                    tfr       d,u                 Point U to entry
L3E9D               ldd       ,u                  Get Integer
                    leay      -6,y                Make room for variable
                    std       1,y                 Save integer
                    lda       #1                  Integer Type
                    sta       ,y                  Save it & return
                    rts

* INTEGER NEGATE (- IN FRONT OF NUMBER)
                    ifne      H6309
L3EA8               clrd                          Number=0-Number (negate it)
                    else
L3EA8               clra
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
L3EB8               ldd       7,y                 Get integer
                    subd      1,y                 Subtract 2nd #
                    leay      6,y                 Eat temp copy
                    std       1,y                 Save result & return
                    rts

* INTEGER MULTIPLY
                    ifne      H6309
L3EC1               ldd       1,y                 Get temp var integer
                    muld      7,y                 Multiply by answer integer
                    stw       7,y                 Save 16 bit wrapped result
                    leay      6,y                 Eat temp var
                    rts
                    else
L3EC1               ldd       7,y                 Get value that result will go into
                    beq       L3EFA               *0, leave result as 0
                    cmpd      #2                  Special case: times 2?
                    bne       L3ECF               No, check other number
                    ldd       1,y                 Get 2nd number
                    bra       L3EDB               Do quick x2

L3ECF               ldd       1,y                 Get 2nd number
                    beq       L3EDD               *0, go save result as 0
                    cmpd      #2                  Special case: times 2?
                    bne       L3EE1               No, go do regular multiply
                    ldd       7,y                 Get 1st number
L3EDB               lslb
                    rola
L3EDD               std       7,y                 Save answer
                    bra       L3EFA               Eat temp var & return

L3EE1               lda       8,y                 Do 16x16 bit signed multiply, MOD 65536
                    mul
                    sta       3,y
                    lda       8,y
                    stb       8,y
                    ldb       1,y
                    mul
                    addb      3,y
                    lda       7,y
                    stb       7,y
                    ldb       2,y
                    mul
                    addb      7,y
                    stb       7,y
L3EFA               leay      6,y                 Eat temp var & return
                    rts
                    endc
* Integer MOD routine
L46A2               bsr       L3F1C               Go do integer divide
                    ldd       3,y                 Get "hidden" remainder
                    std       1,y                 Save as answer & return
                    rts

                    ifne      H6309
L3F1C               ldd       1,y                 Get # to divide by
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
L3EFD               clr       ,y                  Clear flag (positive result)
                    ldd       7,y                 Get #
                    bpl       L3F0B               If positive or 0, go check other #
                    nega                          Force it to positive (NEGD)
                    negb
                    sbca      #$00
                    std       7,y                 Save positive version
                    com       ,y                  Set flag for negative result
L3F0B               ldd       1,y                 Get other #
                    bpl       L3F17               If positive or 0, go check if it is a 2
                    nega                          Force it to positive (NEGD)
                    negb
                    sbca      #$00
                    std       1,y                 Save positive version
                    com       ,y                  Flip negative/positive result flag
L3F17               cmpd      #2                  Check if dividing by 2
                    rts

* INTEGER DIVIDE
L3F1C               bsr       L3EFD               Go force both numbers to positive, check for /2
                    bne       L3F2E               Normal divide, skip ahead
                    ldd       7,y                 Get # to divide by 2
                    beq       L3F3B               If 0, result is 0, so skip divide
                    asra
                    rorb
                    std       7,y                 Save result
                    ldd       #$0000              Remainder=0 (No CLRD since it fries carry)
                    rolb                          Rotate possible remainder bit into D
                    bra       L3F65               Go save remainder, fix sign & return

L3F2E               ldd       1,y                 Get divisor (integer)
                    bne       L3F37               <>0, skip ahead
                    ldb       #$2D                =0, Divide by 0 error
                    jsr       <u0024              Report error
                    fcb       $06

L3F37               ldd       7,y                 Get dividend (integer)
                    bne       L3F40               Have to do divide, skip ahead
L3F3B               leay      6,y                 ??? Eat temp var? (divisor)
                    std       3,y                 Save result
                    rts

* INTEGER DIVIDE MAIN ROUTINE
* 7-8,y = Dividend (already checked for 0)
* 1-2,y = Divisor (already checked for 0)
* 3,y   = # of powers of 2 shifts to do
L3F40               tsta                          Dividend>256?
                    bne       L3F4B               Yes, skip ahead
                    exg       a,b                 Swap LSB/MSB of dividend
                    std       7,y                 Save it
                    ldb       #8                  # of powers of 2 shifts for 8 bit dividend
                    bra       L3F4D

L3F4B               ldb       #16                 # of powers of 2 shifts for 16 bit dividend
L3F4D               stb       3,y                 Save # shifts required
                    clra
                    clrb
* Main powers of 2 subtract loop for divide
L3F51               lsl       8,y                 Multiply dividend by 2
                    rol       7,y
                    rolb                          Rotate into D
                    rola
                    subd      1,y                 Subtract that power of 2 from divisor
                    bmi       L3F5F               If wraps, add it back in
                    inc       8,y
                    bra       L3F61

L3F5F               addd      1,y
L3F61               dec       3,y                 Dec # shift/subtracts left to do
                    bne       L3F51               Still more, continue
L3F65               std       9,y                 Save remainder
                    tst       ,y                  Positive result?
                    bpl       L3F79               Yes, eat temp var & return
                    nega                          NEGD
                    negb
                    sbca      #$00
                    std       9,y                 Save negative remainder
                    ldd       7,y                 Get actual divide result
                    nega                          NEGD
                    negb
                    sbca      #$00
                    std       7,y                 Save signed result
L3F79               leay      6,y                 Eat temp var & return
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
                    ldd       1,u                 Get bytes 2&3 of real #
                    std       2,y
                    ldd       3,u                 Get bytes 4&5 of real #
                    std       4,y
                    endc
                    rts                           Return

* Negate for REAL #'s
                    ifne      H6309
L3FA4               eim       #1,5,y              Negate sign bit of REAL #
                    else
L3FA4               lda       5,y                 Get LSB of mantissa & sign bit
                    eora      #$01                Reverse the sign bit
                    sta       5,y                 Save it back
                    endc
                    rts                           return

* Subtract for REAL #'s
                    ifne      H6309
L3FAB               eim       #1,5,y              Negate sign bit of real #
                    else
L3FAB               ldb       5,y                 Reverse sign bit on REAL #
                    eorb      #1
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
L4336               pshs      x                   Preserve X
                    ldd       7,y                 Is the number to be raised 0?
                    beq       L4331               Yes, eat temp & return with 0 as result
                    ldx       1,y                 Is the exponent 0?
                    bne       L434F               No, go do normal exponent calculation
                    leay      6,y                 Eat temp var
L4342               ldd       #$0180              Save 1 in Real # format (all #'s to the power of
                    std       1,y                 0 result in 1, except 0 itself, which was trapped
* Possible 6809/6309 Mod: deca/sta 3,y/sta 4,y/sta 5,y (1 byte longer/5 cyc
* faster)
                    clr       3,y                 above)
                    clr       4,y
                    clr       5,y
                    puls      pc,x

L434F               std       1,y
                    stx       7,y
                    ldd       9,y
                    ldx       3,y
                    std       3,y
                    stx       9,y
                    lda       $B,y
                    ldb       5,y
                    sta       5,y
                    stb       $B,y
                    puls      x
                    lbsr      L47AB
                    lbsr      L40CC               Go do real multiply
                    lbra      L4864

* Copy Boolean value into temp var
L436E               ldd       ,x++                Get offset to var from beginning of var pool
                    addd      <u0031              Add to base address for vars
                    tfr       d,u                 Move to index reg
L4374               ldb       ,u                  Get boolean value
                    clra                          Make into Integer type
                    leay      -6,y                Make room for temp var
                    std       1,y                 Save boolean value
                    lda       #3                  Type = BOOLEAN
                    sta       ,y
                    rts

L4380               ldb       8,y                 Single byte LAND
                    andb      2,y
                    bra       L4390

L4386               ldb       8,y                 Single byte LOR
                    orb       2,y
                    bra       L4390

L438C               ldb       8,y                 Single byte LXOR
                    eorb      2,y
L4390               leay      6,y                 Eat temp var
                    std       1,y                 Save result in original var & return
                    rts

L4395               com       2,y                 Single byte LNOT
                    rts

* Main search loop for String comparison operators
L4398               pshs      y,x
                    ldx       1,y                 Get ptr to temp string?
                    ldy       7,y                 Get ptr to var string?
                    sty       <u0048
L43A2               lda       ,y+                 Get char from temp string
                    cmpa      ,x+                 Same as char from var string?
                    bne       L43AC               No, skip ahead
                    cmpa      #$FF                EOS marker?
                    bne       L43A2               No, keep comparing
L43AC               inca                          Inc last char checked
                    inc       -1,x                Inc last char in compare string
                    cmpa      -1,x                Same as last char checked with inc????
                    puls      pc,y,x

* String compare: < (?)
L43B3               bsr       L4398               Go do string compare
                    blo       L4405               If less than, result=TRUE
                    bra       L4409               Else, result=False

* String compare: <= or =< (?)
L43B9               bsr       L4398
                    bls       L4405
                    bra       L4409

* String compare: =
L43BF               bsr       L4398
                    beq       L4405
                    bra       L4409

* String compare: <> or ><
L43C5               bsr       L4398
                    bne       L4405
                    bra       L4409

* String compare: >= or => (?)
L43CB               bsr       L4398
                    bhs       L4405
                    bra       L4409

* String compare: > (?)
L43D1               bsr       L4398
                    bhi       L4405
                    bra       L4409

* For Integer/Byte compares below: Works for signed Integer as well
*  as unsigned Byte
* Integer/Byte compare: <
L43D7               ldd       7,y
                    subd      1,y                 NOTE: SUBD is faster than CMPD
                    blt       L4405
                    bra       L4409

* Integer/Byte compare: <= or =<
L43DF               ldd       7,y
                    subd      1,y
                    ble       L4405
                    bra       L4409

* Integer/Byte compare: <> or ><
L43E7               ldd       7,y
                    subd      1,y
                    bne       L4405
                    bra       L4409

* Integer/Byte compare: =
L43EF               ldd       7,y
                    subd      1,y
                    beq       L4405
                    bra       L4409

* Integer/Byte compare: >= or =>
L43F7               ldd       7,y
                    subd      1,y
                    bge       L4405
                    bra       L4409

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
L4415               ldb       8,y                 Get original BOOLEAN value
                    cmpb      2,y                 Same as comparitive BOOLEAN value?
                    beq       L4405               Yes, result=TRUE
                    bra       L4409               No, result=FALSE

* BOOLEAN <> or >< compare
L441D               ldb       8,y                 Get original BOOLEAN value
                    cmpb      2,y                 Same as comparitive BOOLEAN value?
                    bne       L4405               No, result=TRUE
                    bra       L4409               Yes, result=FALSE

* Real < compare
L4425               bsr       L4449               Go compute flags between real #'s
                    blt       L4405               If < then, result=TRUE
                    bra       L4409               Otherwise, result=FALSE

* Real <= or =< compare
L442B               bsr       L4449
                    ble       L4405
                    bra       L4409

* Real <> or >< compare
L4431               bsr       L4449
                    bne       L4405
                    bra       L4409

* Real = compare
L4437               bsr       L4449
                    beq       L4405
                    bra       L4409

* Real >= or => compare
L443D               bsr       L4449
                    bge       L4405
                    bra       L4409

* Real > compare
L4443               bsr       L4449
                    bgt       L4405
                    bra       L4409

* Set flags for Real comparison
L4449               pshs      y                   Preserve Y
                    andcc     #$F0                Clear out Negative, Zero, Overflow & Carry bits
                    lda       8,y                 Is original REAL var=0?
                    bne       L4461               No, skip ahead
                    lda       2,y                 Is comparitive REAL var=0?
                    beq       L445F               Yes, they are equal so return
L4455               lda       5,y                 Get last byte of Mantissa with sign bit
L4457               anda      #$01                Ditch everything but sign bit
                    bne       L445F               Sign bit set, negative value, return
L445B               andcc     #$F0                Clear out Negative, Zero, Overflow & carry bits
                    orcc      #%00001000          Set Negative flag
L445F               puls      pc,y

L4461               lda       2,y                 Is comparitive REAL var=0?
                    bne       L446B               No, go deal with whole exponent/mantissa mess
                    lda       $B,y                Get sign bit of original var
                    eora      #$01                Invert sign flag
                    bra       L4457               Go set Negative bit appropriately

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
                    bne       L445F               Not equal, exit with appropriate flags set
                    ldd       3,u                 Match so far, compare 2nd & 3rd mantissa bytes
                    cmpd      3,y
                    bne       L4491               Not equal, exit with flags
                    lda       5,u                 Compare last byte of mantissa
                    cmpa      5,y
                    beq       L445F               2 #'s are equal, exit
L4491               blo       L445B               If below, set negative flag & exit
                    andcc     #$F0                Clear negative, zero, overflow & carry bits
                    puls      pc,y                Restore Y & return

*??? Copy string var of some sort <=256 chars max
L4497               clrb                          Max size of string copy=256
                    stb       <u003E              Save it
L449A               ldu       <u0048              Get ptr to string of some sort
                    leay      -6,y                Make room for temp var
                    stu       1,y                 Save ptr to it
                    sty       <u0044              Save temp var ptr
L44A3               cmpu      <u0044              At end of string stack yet?
                    bhs       L44C2               Yes, exit with String stack overflow error
                    lda       ,x+                 Get char from string
                    sta       ,u+                 Save it
                    cmpa      #$FF                EOS?
                    beq       L44BB               Yes, finished copying
                    decb                          Dec size left
                    bne       L44A3               Still room, keep copying
                    dec       <u003E              ???
                    bpl       L44A3               Still good, keep copying
                    lda       #$FF                Append string terminator
                    sta       ,u+
L44BB               stu       <u0048              Save end of string stack ptr
                    lda       #4                  Force var type to string
                    sta       ,y
                    rts

L44C2               ldb       #$2F                String stack overflow
                    jsr       <u0024
                    fcb       $06

L44C7               ldd       ,x++
                    addd      <u0066
                    tfr       d,u
L44CD               ldd       ,u
                    addd      <u0031
                    ldu       2,u
                    stu       <u003E
                    tfr       d,u
L44D7               pshs      x
                    ldb       <u003F
                    bne       L44DF
                    dec       <u003E
L44DF               leax      ,u
                    bsr       L449A
                    puls      pc,x

L44E5               ldu       1,y                 Get ptr to string contents
                    leay      6,y                 Eat temp var
L44E9               lda       ,u+                 Get char from temp var
                    sta       -2,u                Save 1 byte back from original spot
                    cmpa      #$FF                EOS?
                    bne       L44E9               No, keep copying until EOS is hit
                    leau      -1,u                Point U back to EOS
                    stu       <u0048              Save string stack ptr & return
                    rts

L44F6               ldd       <u003E
                    leay      -6,y                Make room for temp var
                    std       3,y                 ???
                    stu       1,y                 ???
                    lda       #5                  Var type =5???
                    sta       ,y
                    rts

L4503               clra                          Force least 2 sig bytes to 0 (and sign to positive)
                    clrb
                    std       4,y
                    ldd       1,y                 Get Exponent & 1st byte of mantissa
                    bne       L4512               Not 0, skip ahead
                    stb       3,y                 Save 0 int 2nd byte of mantissa
                    lda       #2                  Var type=Real
                    sta       ,y
                    rts

L4512               ldu       #$0210              ??? (528)
                    tsta                          Exponent negative?
                    bpl       L451F               No, positive (big number), skip ahead
                    ifne      H6309
                    negd
                    else
                    nega
                    negb
                    sbca      #$00
                    endc
                    inc       5,y
                    tsta                          Check exponent again
L451F               bne       L4526               Exponent <>0, skip ahead
                    ldu       #$0208              ??? If exponent=0, 522
                    exg       a,b
L4526               tsta
                    bmi       L452F
L4529               leau      -1,u                Drop down U counter
                    lslb                          LSLD
                    rola
                    bpl       L4529               Do until hi bit is set
L452F               std       2,y
                    stu       ,y
                    rts

L4534               leay      6,y                 Eat temp var
                    bsr       L4503               ??? Something with reals
                    leay      -6,y                Make room for temp var & return
                    rts

L453B               ldb       1,y                 Get exponent
                    bgt       L454E               If exponent >0, skip ahead
                    bmi       L454A               If exponent <0, skip ahead
                    lda       2,y                 Exponent=0, get 1st byte of mantissa
                    bpl       L454A               If high bit not set, integer result=0
                    ldd       #$0001              High bit set, Integer result=1
                    bra       L4591               Go adjust sign if necessary

L454A               clra                          Integer result=0
                    clrb
                    bra       L4599               Save integer & return

L454E               subb      #$10                Subtract 16 from exponent
                    bhi       L458C
                    bne       L4566
                    ldd       2,y
                    ror       5,y
                    bcc       L4599
                    cmpd      #$8000
                    bne       L458C
                    tst       4,y
                    bpl       L4599
                    bra       L458C

L4566               cmpb      #$F8
                    bhi       L4578
                    pshs      b
                    ldd       2,y
                    std       3,y
                    clr       2,y
                    puls      b
                    addb      #$08
                    beq       L4581
L4578               lsr       2,y
                    ror       3,y
                    ror       4,y
                    incb
                    bne       L4578
L4581               ldd       2,y
                    tst       4,y
                    bpl       L4591
                    addd      #$0001
                    bvc       L4591
L458C               ldb       #$34                Value out of Range for Destination error
                    jsr       <u0024
                    fcb       $06

L4591               ror       5,y                 Get sign bit of converted real #
                    bcc       L4599               Positive, leave integer result alone
                    ifne      H6309
                    negd                          Reverse sign of integer
                    else
                    nega
                    negb
                    sbca      #$00
                    endc
L4599               std       1,y                 Save integer result
                    lda       #1                  Force type to integer & return
                    sta       ,y
                    rts

L45A0               leay      6,y
                    bsr       L453B
                    leay      -6,y
                    rts

L45A7               leay      $C,y                Eat 2 temp vars
                    bsr       L453B
                    leay      -$C,y               Make room for 2 temp vars & return
                    rts

* ABS for Real #'s
                    ifne      H6309
L45AE               aim       #$fe,5,y            Force sign of real # to positive
                    else
L45AE               lda       5,y                 Get sign bit for Real #
                    anda      #$FE                Force to positive
                    sta       5,y                 Save sign bit back & return
                    rts
                    endc

* ABS for Integer's
L45B5               ldd       1,y                 Get integer
                    bpl       L45BF               If positive already, exit
                    ifne      H6309
                    negd                          Force to positive
                    else
                    nega                          NEGD (force to positive)
                    negb
                    sbca      #$00
                    endc
                    std       1,y                 Save positive value back
L45BF               rts

L45C0               clra
                    ldb       [<1,y]
                    std       1,y
                    rts

L45C7               lda       2,y
                    beq       L45DB
                    lda       5,y                 Get sign byte
                    anda      #$01                Just keep sign bit
                    bne       L45DE               Negative #, skip ahead
L45D1               ldb       #$01
                    bra       L45E0

L45D5               ldd       $01,y
                    bmi       L45DE
                    bne       L45D1
L45DB               clrb
                    bra       L45E0

L45DE               ldb       #$FF
L45E0               sex
                    bra       L45EA

L45E3               ldb       <u0036
                    clr       <u0036
L45E7               clra
                    leay      -6,y                Make room for temp var
L45EA               std       1,y                 Save value
                    lda       #1                  Force type to integer & return
                    sta       ,y
L45F0               rts

L45F1               ldb       <u007D
                    bra       L45E7

L45F5               ldb       $05,y
                    asrb
                    lbcs      L4FC7
                    ldb       #$1F
                    stb       <u006E
                    ldd       $01,y
                    beq       L45F0
                    inca
                    asra
                    sta       $01,y
                    ldd       $02,y
                    bcs       L4616
                    lsra
                    rorb
                    std       -$04,y
                    ldd       $04,y
                    rora
                    rorb
                    bra       L461A

L4616               std       -$04,y
                    ldd       $04,y
L461A               std       -$02,y
                    clra
                    clrb
                    std       $02,y
                    std       $04,y
                    std       -$06,y
                    std       -$08,y
                    bra       L4638

L4628               orcc      #$01
                    rol       $05,y
                    rol       $04,y
                    rol       $03,y
                    rol       $02,y
                    dec       <u006E
                    beq       L467A
                    bsr       L468F
L4638               ldb       -$04,y
                    subb      #$40
                    stb       -$04,y
                    ldd       -$06,y
                    sbcb      $05,y
                    sbca      $04,y
                    std       -$06,y
                    ldd       -$08,y
                    sbcb      $03,y
                    sbca      $02,y
                    std       -$08,y
                    bpl       L4628
L4650               andcc     #$FE
                    rol       $05,y
                    rol       $04,y
                    rol       $03,y
                    rol       $02,y
                    dec       <u006E
                    beq       L467A
                    bsr       L468F
                    ldb       -$04,y
                    addb      #$C0
                    stb       -$04,y
                    ldd       -$06,y
                    adcb      $05,y
                    adca      $04,y
                    std       -$06,y
                    ldd       -$08,y
                    adcb      $03,y
                    adca      $02,y
                    std       -$08,y
                    bmi       L4650
                    bra       L4628

L467A               ldd       $02,y
                    bra       L4684

L467E               dec       $01,y
                    lbvs      L40DD
L4684               lsl       $05,y
                    rol       $04,y
                    rolb
                    rola
                    bpl       L467E
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
L46AA               leau      -12,y               Make room for 2 temp vars
                    pshs      y
L46AE               ldd       ,y++
                    std       ,u++
                    cmpu      ,s
                    bne       L46AE
                    leas      2,s
                    leay      -12,u
                    lbsr      L422D
                    bsr       L46C6
                    lbsr      L40CC
                    lbra      L3FAB

L46C6               lda       1,y
                    bgt       L46D3
                    clra
                    clrb
                    std       1,y
                    std       3,y
                    stb       5,y
L46D2               rts

L46D3               cmpa      #$1F
                    bcc       L46D2
                    leau      $06,y
                    ldb       -1,u
                    andb      #$01
                    pshs      u,b
                    leau      $01,y
L46E1               leau      1,u
                    suba      #$08
                    bcc       L46E1
                    beq       L46F5
                    ldb       #$FF
L46EB               lslb
                    inca
                    bne       L46EB
                    andb      ,u
                    stb       ,u+
                    bra       L46F9

L46F5               leau      1,u
L46F7               sta       ,u+
L46F9               cmpu      $01,s
                    bne       L46F7
                    puls      u,b
                    orb       $05,y
                    stb       $05,y
                    rts

L4705               leay      -6,y
                    ldd       7,y
                    std       1,y
                    lbra      L3EC1

L470E               leay      -6,y
                    ldd       $A,y
                    std       4,y
                    ldd       8,y
                    std       2,y
                    ldd       6,y
                    std       ,y
                    lbra      L40CC

L471F               ldd       <u0080
                    ldu       <u0082
                    pshs      u,d
                    ldd       1,y
                    std       <u0080
                    std       <u0082
                    std       <u0048
                    leay      6,y
                    ldb       #9
                    lbsr      L011F
                    puls      u,d
                    std       <u0080
                    stu       <u0082
                    lbcs      L4FC7
                    rts

L473F               lbsr      L3D51
                    leay      -6,y                Make room for new variable packet
                    stu       1,y                 Save size of var
L4746               lda       #$01                ??? Integer type
                    sta       ,y                  ??? Save in variable packet
                    leax      1,x
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

L4751               lbsr      L3D51
                    leay      -6,y                ??? Size of variable packets?
                    cmpa      #4                  String/complex variable?
                    bhs       L4763               Yes, skip ahead
                    leau      <L474D,pc           Point to numeric type size table
                    ldb       a,u                 Get size of var in bytes
                    clra                          D=size
                    bra       L4765               Go save it

L4763               ldd       <u003E              ??? Get integer value
L4765               std       1,y                 ??? Save integer value
                    bra       L4746

* BOOLEAN - TRUE
L4769               ldd       #$00FF              $FF in boolean is True flag
                    bra       L4771

L476E               ldd       #$0000              CLRD ($00 in boolean is False)
L4771               leay      -6,y                Make room for variable packet
                    std       1,y                 Save boolean flag value
                    lda       #3                  Save type as boolean (3)
                    sta       ,y
                    rts

L477A               com       1,y                 Leave as LDD 1,y/COMD/STD 1,y is same speed
                    com       2,y
                    rts

L477F               ldd       1,y                 Get value to AND with out of integer var.
                    anda      7,y                 ANDD (with value in variable)
                    andb      8,y
                    bra       L4795

L4787               ldd       1,y
                    eora      7,y                 EORD
                    eorb      8,y
                    bra       L4795

L478F               ldd       1,y
                    ora       7,y                 ORD
                    orb       8,y
L4795               std       7,y                 Save result after logic applied
                    leay      6,y                 Eat temporary variable packet?
                    rts

L479A               fcb       $ff,$de,$5b,$d8,$aa ??? (.434294482)

L479F               bsr       L47AB
                    leau      <L479A,pc           Point to ???
                    lbsr      L3F93
                    lbra      L40CC

L47AB               pshs      x
                    ldb       5,y
                    asrb
                    lbcs      L4FC7
                    ldd       1,y
                    lbeq      L4FC7
                    pshs      a
                    ldb       #1
                    stb       1,y
                    leay      <-$1A,y
                    leax      <$1B,y
                    leau      ,y
                    lbsr      L4BCC
                    lbsr      L4CC7
                    clra
                    clrb
                    std       <$14,y
                    std       <$16,y
                    sta       <$18,y
                    leax      >L4C7F,pc           Point to routine
                    stx       <$19,y
                    lbsr      L4909
                    leax      <$14,y
                    leau      <$1B,y
                    lbsr      L4BCC
                    lbsr      L4CE1
                    leay      <$1A,y
                    ldb       #$02
                    stb       ,y
                    ldb       $05,y
                    orb       #$01
                    stb       $05,y
                    puls      b
                    bsr       L480A
                    puls      x
                    lbra      L3FB1

L4805               fcb       $00,$b1,$72,$17,$f8 (.693147181) LOG(2) in REAL format

L480A               sex                           Convert to 16 bit number
                    bpl       L480E               If positive, skip ahead
                    negb                          Invert sign on LSB
L480E               anda      #$01
                    pshs      d
L4812               leau      <L4805,pc           Point to Log(2) in REAL format
                    lbsr      L3F93
                    ldb       5,y
                    lda       1,s
                    cmpa      #1
                    beq       L485C               If multiplying by 1, don't bother
                    mul
                    stb       5,y
                    ldb       4,y
                    sta       4,y
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
                    addb      $02,y
                    adca      #$00
                    beq       L4858
L484B               inc       $01,y
                    lsra
                    rorb
                    ror       $03,y
                    ror       $04,y
                    ror       $05,y
                    tsta
                    bne       L484B
L4858               stb       $02,y
                    ldb       $05,y
L485C               andb      #$FE
                    orb       ,s
                    stb       $05,y
                    puls      pc,d

L4864               pshs      x
                    ldb       $01,y
                    beq       L4880
                    cmpb      #$07
                    ble       L4877
                    ldb       $05,y
                    rorb
                    rorb
                    eorb      #$80
                    lbra      L491C

L4877               cmpb      #$E4
                    lble      L4342
                    tstb
                    bpl       L488A
L4880               clr       ,-s
                    ldb       $05,y
                    andb      #$01
                    beq       L48CD
                    bra       L48BB

L488A               lda       #$71
                    mul
                    adda      $01,y
                    ldb       $05,y
                    andb      #$01
                    pshs      b,a
                    eorb      $05,y
                    stb       $05,y
                    ldb       ,s
L489B               lbsr      L480A
                    lbsr      L3FAB
                    ldb       $01,y
                    ble       L48AD
                    addb      ,s
                    stb       ,s
                    ldb       $01,y
                    bra       L489B

L48AD               puls      d
                    pshs      a
                    tstb
                    beq       L48CD
                    nega
                    sta       ,s
                    orb       5,y
                    stb       5,y
L48BB               leau      >L4805,pc           Point to LOG(2) in REAL format
                    lbsr      L3F93
                    lbsr      L3FB1
                    dec       ,s
                    ldb       5,y
                    andb      #$01
                    bne       L48BB
L48CD               leay      <-$1A,y
                    leax      <$1B,y
                    leau      <$14,y
                    lbsr      L4BCC
                    lbsr      L4CC7
                    ldd       #$1000
                    std       ,y
                    clra
                    std       $02,y
                    sta       $04,y
                    leax      >L4C61,pc
                    stx       <$19,y
                    bsr       L4909
                    leax      ,y
                    leau      <$1B,y
                    lbsr      L4BCC
                    lbsr      L4CE1
                    leay      <$1A,y
                    puls      b
                    addb      $01,y
                    bvs       L491C
                    lda       #$02
                    std       ,y
                    puls      pc,x

L4909               lda       #$01
                    sta       <u009A
                    leax      >L4D6F,pc
                    stx       <u0095
                    leax      >$005F,x
                    stx       <u0097
                    lbra      L4B97

L491C               leay      -6,y
                    lbpl      L40DD
                    ldb       #$32                Floating Overflow error
                    jsr       <u0024
                    fcb       $06

L4927               pshs      x
                    bsr       L495D
                    ldd       $01,y
                    lbeq      L4A91
                    cmpd      #$0180
                    bgt       L4943
                    bne       L4946
                    ldd       $03,y
                    bne       L4943
                    lda       $05,y
                    lbeq      L4A0E
L4943               lbra      L4FC7

L4946               lbsr      L49CB
                    leay      <-$14,y
                    leax      <$15,y
                    leau      ,y
                    lbsr      L4BCC
                    lbsr      L4CC7
                    leax      <$1B,y
                    lbra      L4A3E

L495D               ldb       $05,y
                    andb      #$01
                    stb       <u006D
                    eorb      $05,y
                    stb       $05,y
                    rts

L4968               leau      <L49AB,pc
                    pshs      u,x
                    bsr       L495D
                    ldd       $01,y
                    lbeq      L4A0E
                    cmpd      #$0180
                    bgt       L4943
                    bne       L4995
                    ldd       $03,y
                    bne       L4943
                    lda       $05,y
                    bne       L4943
                    lda       <u006D
                    bne       L498E
                    clrb
                    std       $01,y
                    puls      pc,u,x

L498E               leay      6,y                 Eat temp var
                    puls      u,x
                    lbra      L4B03

L4995               bsr       L49CB
                    leay      <-$14,y
                    leax      <$1B,y
                    leau      ,y
                    lbsr      L4BCC
                    lbsr      L4CC7
                    leax      <$15,y
                    lbra      L4A3E

L49AB               lda       5,y
                    bita      #$01
                    beq       L49C5
                    ldu       <u0031
                    tst       1,u
                    beq       L49BF
                    leau      <L49C6,pc           Point to 180 in FP format
                    lbsr      L3F93
                    bra       L49C2

L49BF               lbsr      L4B03
L49C2               lbra      L3FB1

* See if we can move label to RTS above @ L495D, or below @ end of L49CB
L49C5               rts

L49C6               fcb       $08,$b4,$00,$00,$00 180

L49CB               lda       <u006D
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
                    lbsr      L45F5
                    puls      a
                    sta       <u006D
                    rts

L4A03               pshs      x
                    lbsr      L495D
                    ldb       $01,y
                    cmpb      #$18
                    blt       L4A17
L4A0E               leay      6,y
                    lbsr      L4B03
                    dec       1,y
                    bra       L4A6A

L4A17               leay      <-$1A,y
                    ldd       #$1000
                    std       ,y
                    clra
                    std       $02,y
                    sta       $04,y
                    ldb       <$1B,y
                    bra       L4A34

L4A29               asr       ,y
                    ror       1,y
                    ror       2,y
                    ror       3,y
                    ror       4,y
                    decb
L4A34               cmpb      #$02
                    bgt       L4A29
                    stb       <$1B,y
                    leax      <$1B,y
L4A3E               leau      $0A,y
                    lbsr      L4BCC
                    lbsr      L4CC7
                    clra
                    clrb
                    std       <$14,y
                    std       <$16,y
                    sta       <$18,y
                    leax      >L4C2C,pc
                    stx       <$19,y
                    lbsr      L4B89
                    leax      <$14,y
                    leau      <$1B,y
                    lbsr      L4BCC
                    lbsr      L4CE1
                    leay      <$1A,y
L4A6A               lda       $05,y
                    ora       <u006D
                    sta       $05,y
                    ldu       <u0031
                    tst       1,u
                    beq       L4A91
                    leau      >L4AFE,pc
                    lbsr      L3F93
                    lbsr      L40CC
                    bra       L4A91

L4A82               pshs      x
                    lbsr      L4B0A
                    leax      $0A,y
                    bsr       L4A97
                    lda       $05,y
L4A8D               eora      <u009C
L4A8F               sta       $05,y
L4A91               lda       #$02
                    sta       ,y
                    puls      pc,x

L4A97               leau      <$1B,y
                    lbsr      L4BCC
                    lbsr      L4CE1
                    leay      <$14,y
                    leax      >L4D6A,pc           Point to a table of Real #'s
                    leau      1,y
                    lbsr      L4BCC
                    lbra      L40CC

L4AAF               pshs      x
                    bsr       L4B0A
                    leax      ,y
                    bsr       L4A97
                    lda       $05,y
                    eora      <u009B
                    bra       L4A8F

L4ABD               pshs      x
                    bsr       L4B0A
                    leax      $0A,y
                    leau      <$1B,y
                    lbsr      L4BCC
                    lbsr      L4CE1
                    leax      ,y
                    leay      <$14,y
                    leau      $01,y
                    lbsr      L4BCC
                    lbsr      L4CE1
                    ldd       $01,y
                    bne       L4AEB
                    leay      $06,y
                    ldd       #$7FFF
L4AE2               std       $01,y
                    lda       #$FF
                    std       $03,y
                    deca
                    bra       L4AF0

L4AEB               lbsr      L422D
                    lda       $05,y
L4AF0               eora      <u009B
                    bra       L4A8D

L4AF4               fcb       $02,$c9,$0f,$da,$a2 PI (3.14159265)

L4AF9               fcb       $fb,$8e,$fa,$35,$12 -1.74532925 E-02  (Degrees)

L4AFE               fcb       $06,$e5,$2e,$e0,$d4 57.2957795 (radians)

L4B03               leau      <L4AF4,pc           Point to PI in FP format
                    lbra      L3F93

L4B0A               ldu       <u0031
                    tst       1,u
                    beq       L4B1A
                    leau      <L4AF9,pc
                    lbsr      L3F93               Copy 5 bytes from u to 1,y (0,y=2)
                    lbsr      L40CC
L4B1A               clr       <u009B
                    ldb       $05,y
                    andb      #$01
                    stb       <u009C
                    eorb      $05,y
                    stb       $05,y
                    bsr       L4B03
                    inc       $01,y
                    lbsr      L4449
                    blt       L4B36
                    lbsr      L46AA
                    bsr       L4B03
                    bra       L4B38

L4B36               dec       $01,y
L4B38               lbsr      L4449
                    blt       L4B4A
                    inc       <u009B
                    lda       <u009C
                    eora      #$01
                    sta       <u009C
                    lbsr      L3FAB
                    bsr       L4B03
L4B4A               dec       $01,y
                    lbsr      L4449
                    ble       L4B64
                    lda       <u009B
                    eora      #$01
                    sta       <u009B
                    inc       $01,y
                    lda       $0B,y
                    ora       #$01
                    sta       $0B,y
                    lbsr      L3FB1
                    leay      -$06,y
L4B64               leay      <-$14,y
                    leax      >L4C33,pc
                    stx       <$19,y
                    leax      <$1B,y
                    leau      <$14,y
                    bsr       L4BCC
                    lbsr      L4CC7
                    ldd       #$1000
                    std       ,y
                    clra
                    std       $02,y
                    sta       $04,y
                    std       $0A,y
                    std       $0C,y
                    sta       $0E,y
L4B89               leax      >L4D29,pc           Point to some real # table
                    stx       <u0095
                    leax      <L4D6A-L4D29,x      Point to further in table
                    stx       <u0097
                    clr       <u009A
L4B97               ldb       #$25
                    stb       <u0099
                    clr       <u009D
L4B9D               leau      <$1B,y
                    ldx       <u0095
                    cmpx      <u0097
                    bhs       L4BAE
                    bsr       L4BCC
                    leax      5,x                 Point to next entry in 5-byte entry table
                    stx       <u0095              Save new ptr
                    bra       L4BB2

L4BAE               ldb       #$01
                    bsr       L4C1E
L4BB2               leax      ,y
                    leau      5,y
                    bsr       L4BDE
                    tst       <u009A
                    bne       L4BC2
                    leax      $0A,y
                    leau      $0F,y
                    bsr       L4BDE
L4BC2               jsr       [<$19,y]
                    inc       <u009D
                    dec       <u0099
                    bne       L4B9D
                    rts

L4BCC               pshs      y,x
                    lda       ,x
                    ldy       1,x
                    ldx       3,x
                    sta       ,u
                    sty       1,u
                    stx       3,u
                    puls      pc,y,x

L4BDE               ldb       ,x
                    sex
                    ldb       <u009D
                    lsrb
                    lsrb
                    lsrb
                    bcc       L4BE9
                    incb
L4BE9               pshs      b
                    beq       L4BF2
L4BED               sta       ,u+
                    decb
                    bne       L4BED
L4BF2               ldb       #$05
                    subb      ,s+
                    beq       L4BFF
L4BF8               lda       ,x+
                    sta       ,u+
                    decb
                    bne       L4BF8
L4BFF               leau      -5,u
                    ldb       <u009D
                    andb      #$07
                    beq       L4C2B
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
L4C2B               rts

L4C2C               lda       $0A,y
                    eora      ,y
                    coma
                    bra       L4C36

L4C33               lda       <$14,y
L4C36               tsta
                    bpl       L4C4D
                    leax      ,y
                    leau      $0F,y
                    bsr       L4C8F
                    leax      $0A,y
                    leau      $05,y
                    bsr       L4CAB
                    leax      <$14,y
                    leau      <$1B,y
                    bra       L4C8F

L4C4D               leax      ,y
                    leau      $0F,y
                    bsr       L4CAB
                    leax      $0A,y
                    leau      $05,y
                    bsr       L4C8F
                    leax      <$14,y
                    leau      <$1B,y
                    bra       L4CAB

L4C61               leax      <$14,y
                    leau      <$1B,y
                    bsr       L4CAB
                    bmi       L4C8F
                    bne       L4C79
                    ldd       $01,x
                    bne       L4C79
                    ldd       $03,x
                    bne       L4C79
                    ldb       #$01
                    stb       <u0099
L4C79               leax      ,y
                    leau      5,y
                    bra       L4C8F

L4C7F               leax      ,y
                    leau      $05,y
                    bsr       L4C8F
                    cmpa      #$20
                    bcc       L4CAB
                    leax      <$14,y
                    leau      <$1B,y
L4C8F               ldd       3,x
                    addd      3,u
                    std       3,x
                    ldd       1,x
                    bcc       L4CA0
                    addd      #$0001
                    bcc       L4CA0
                    inc       ,x
L4CA0               addd      1,u
                    std       1,x
                    lda       ,x
                    adca      ,u
                    sta       ,x
                    rts

L4CAB               ldd       3,x
                    subd      3,u
                    std       3,x
                    ldd       1,x
                    bcc       L4CBC
                    subd      #$0001
                    bcc       L4CBC
                    dec       ,x
L4CBC               subd      1,u
                    std       1,x
                    lda       ,x
                    sbca      ,u
                    sta       ,x
                    rts

L4CC7               ldb       ,u
                    clr       ,u
                    addb      #$04
                    bge       L4CDE
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
L4CDE               bne       L4CD3
                    rts

L4CE1               lda       ,u                  Get sign of 5 byte #
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
L4DDA               clrd
                    else
L4DDA               clra
                    clrb
                    endc
                    std       <u004C
                    std       <u004E
                    pshs      a                   ??? Save flag (0)
                    lda       2,y
                    beq       L4DFC
                    ldb       5,y                 ??? Get sign/exponent byte
                    bitb      #1                  ??? Negative number?
                    bne       L4DF0               ??? Yes, skip ahead
                    com       ,s                  ??? No, set flag
                    bra       L4DFC

L4DF0               addb      #$FE
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
                    bne       L4E98
                    ldd       <u0050
                    std       2,y
                    ldd       <u0052
                    std       4,y
                    clr       1,y
L4E78               lda       #$1F
                    pshs      a
                    ldd       $02,y
                    bmi       L4E8E
L4E80               dec       ,s
                    beq       L4E8E
                    dec       $01,y
                    lsl       $05,y
                    rol       $04,y
                    rolb
                    rola
                    bpl       L4E80
L4E8E               std       $02,y
                    ldb       $05,y
                    andb      #$FE
                    stb       $05,y
                    puls      pc,b

L4E98               ldd       <u0052
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
                    bsr       L4E78
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

L4EBD               ldd       1,y
                    std       <u0048
                    ldb       [<$01,y]
                    clra
                    bra       L4EB6

L4EC7               ldd       1,y
                    tsta
                    lbne      L4FC7
                    ldu       <u0048
                    stu       1,y
                    stb       ,u+
                    lbsr      L4FEA
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

L4EFA               ldd       1,y
                    ble       L4EF4
                    pshs      x
                    ldd       <u0048
                    subd      1,y
                    subd      #1
                    cmpd      7,y
                    bls       L4F1A
                    tfr       d,x
                    ldu       7,y
L4F10               lda       ,x+
                    sta       ,u+
                    cmpa      #$FF
                    bne       L4F10
                    stu       <u0048
L4F1A               leay      6,y
                    puls      pc,x

L4F1E               ldd       $01,y
                    ble       L4F26
                    ldd       $07,y
                    bgt       L4F2E
L4F26               ldd       $01,y
                    leay      $06,y
                    std       $01,y
                    bra       L4EE2

L4F2E               subd      #$0001
                    beq       L4F26
                    addd      $0D,y
                    cmpd      <u0048
                    bcs       L4F3E
                    leay      $06,y
                    bra       L4EF4

L4F3E               pshs      x
                    tfr       d,x
                    ldb       $02,y
                    ldu       $0D,y
L4F46               lda       ,x+
                    sta       ,u+
                    cmpa      #$FF
                    beq       L4F59
                    decb
                    bne       L4F46
                    dec       1,y
                    bpl       L4F46
                    lda       #$FF
                    sta       ,u+
L4F59               stu       <u0048
                    leay      $0C,y
                    puls      pc,x

L4F5F               ldu       <u0048
                    leau      -1,u
L4F63               cmpu      $01,y
                    beq       L4F70
                    lda       ,-u
                    cmpa      #$20
                    beq       L4F63
                    leau      1,u
L4F70               lda       #$FF
                    sta       ,u+
                    stu       <u0048
                    rts

L4F77               pshs      y,x
                    ldd       <u0048              ??? Get size of string
                    subd      1,y                 Subtract ptr to string to search in
                    addd      7,y                 Add to ptr to string to search for
                    addd      #1                  +1
                    ldx       7,y                 Get ptr to string to search for
                    ldy       1,y                 Get ptr to string to search in
                    bsr       L3C29               Call Substr function (should change to direct LBSR
                    bcc       L4F90               If sub-string match found, skip ahead
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    bra       L4F99

L3C29               jsr       <u001B              Substr string search
                    fcb       $08

L4F90               tfr       y,d
                    ldx       2,s
                    subd      1,x
                    addd      #$0001
L4F99               puls      y,x
                    std       7,y
                    lda       #1
                    sta       6,y
                    leay      6,y
                    rts

L4FA4               ldb       #$02
                    bra       L4FAA

L4FA8               ldb       #$03
L4FAA               lda       <u007D
                    ldu       <u0082
                    pshs      u,x,a
                    lbsr      L011F
                    bcs       L4FC7
                    ldx       <u0082
                    lda       #$FF
                    sta       ,x
                    ldx       $03,s
                    lbsr      L4497
                    puls      u,x,a
                    sta       <u007D
                    stu       <u0082
                    rts

L4FC7               ldb       #$43                Illegal Arguement error
                    jsr       <u0024
                    fcb       $06

L4FCC               pshs      x
                    ldd       1,y
                    blt       L4FC7
                    sty       <u0044
                    ldu       <u0048
                    stu       $01,y
                    lda       #$20
L4FDB               cmpb      <u007D
                    bls       L4FEC
                    sta       ,u+
                    decb
                    cmpu      <u0044
                    blo       L4FDB
                    lbra      L44C2

L4FEA               pshs      x
L4FEC               lda       #$FF
                    sta       ,u+
                    stu       <u0048
                    lda       #$04
                    sta       ,y
                    puls      pc,x

* DATE$ routine
* Minor change to accommodate Y2K changes in year. RG
L4FF8               pshs      x
                    leay      -6,y
                    leax      -6,y
                    ldu       <u0048
                    stu       1,y
                    os9       F$Time              Get time packet
                    bcs       L4FEC               Error, exit
*         bsr   L5021      Start converting
                    lda       ,x+
                    ldb       #'/
                    cmpa      #100
                    blo       Y19
cnty                suba      #100
                    bhs       cnty
                    adda      #100
Y19                 bsr       L5025
                    lda       #'/                 Append /
                    bsr       L501F
                    lda       #'/
                    bsr       L501F
                    lda       #$20
                    bsr       L501F
                    lda       #':
                    bsr       L501F
                    lda       #':
                    bsr       L501F
                    bra       L4FEC

L501F               sta       ,u+
L5021               lda       ,x+                 Get byte from time packet
                    ldb       #'/
L5025               incb
                    suba      #10
                    bcc       L5025
                    stb       ,u+
                    ldb       #':
L502E               decb
                    inca
                    bne       L502E
                    stb       ,u+
                    rts

L5035               lda       2,y                 Get path #
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

L5050               ldb       #$06                6 2-byte entries to copy
                    pshs      y,x,b               Preserve regs
                    tfr       dp,a                Move DP to MSB of D
                    ldb       #$50                Point to [dp]50 (always u0050 in Lvl II)
                    tfr       d,y                 Move to Y
                    leax      >L4DCE,pc           Point to table
L505E               ldd       ,x++                Get 2 bytes
                    std       ,y++                Move into DP
                    dec       ,s                  Do all 6
                    bne       L505E               Until done
                    leax      >L3CB5,pc           Point to jump table
                    stx       <u0010              Save ptr
                    leax      >L3D35,pc           Point to another jump table
                    stx       <u0012              Save ptr
                    lda       #$7E                Get opcode for JMP >xxxx
                    sta       <u0016              Save it
                    leax      >L3D41,pc           Point to routine
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

L5094               fdb       L514E-L5094         Function 0
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
L50B2               fdb       L5511-L50B2         $045f  0
                    fdb       L5675-L50B2         $05c3  1
                    fdb       L5675-L50B2         $05c3  2
                    fdb       L5569-L50B2         $04b7  3
                    fdb       L5665-L50B2         $05b3  4
                    fdb       L565C-L50B2         $05aa  5
                    fdb       L54FC-L50B2         $044a  6
                    fdb       L530A-L50B2         $0258  7
                    fdb       L531D-L50B2         $026b  8
                    fdb       L52E7-L50B2         $0235  9
                    fdb       L5354-L50B2         $02a2  A
                    fdb       L5331-L50B2         $027f  B
                    fdb       L56AB-L50B2         $05f9  C
                    fdb       L569B-L50B2         $05e9  D
                    fdb       L552A-L50B2         $0478  E
                    fdb       L5AC3-L50B2         $0a11  F    Exit with Unimplemented routine err
                    fdb       L568C-L50B2         $05da  10
                    fdb       L576C-L50B2         $06ba  11
                    fdb       L5614-L50B2         $0562  12
                    fdb       L580B-L50B2         $0759  13
L50DA               fdb       L56B4-L50B2         $0602  14

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
L514E               pshs      u
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
                    lbsr      L5390
                    bcc       L5172
                    leax      -1,x
                    cmpa      #$2C
                    bne       L51DE
                    lbra      L51FB

L5172               cmpa      #$24
                    lbeq      L52B2
                    cmpa      #$2B
                    beq       L5182
                    cmpa      #$2D
                    bne       L5184
                    inc       <u0078
L5182               lda       ,x+
L5184               cmpa      #$2E
                    bne       L5190
                    tst       <u0077
                    bne       L51DE
                    inc       <u0077
                    bra       L5182

L5190               lbsr      L57DE
                    bcs       L51E5
                    pshs      a
                    inc       <u0076
                    ldd       4,y
                    ldu       2,y
                    bsr       L51CB
                    std       4,y
                    stu       2,y
                    bsr       L51CB
                    bsr       L51CB
                    addd      4,y
                    exg       d,u
* 6309 mod: ADCD 2,y
                    adcb      3,y
                    adca      2,y
                    bcs       L51D8
                    exg       d,u
                    addb      ,s+
                    adca      #$00
                    bcc       L51BF
                    leau      1,u
                    stu       2,y
                    beq       L51DA
L51BF               std       4,y
                    stu       2,y
                    tst       <u0077
                    beq       L5182
                    inc       <u0079
                    bra       L5182

L51CB               lslb
                    rola
                    exg       d,u
                    rolb
                    rola
                    exg       d,u
                    bcs       L51D6
                    rts

L51D6               leas      2,s
L51D8               leas      1,s
L51DA               ldb       #$3C                I/O conversion: Number out of range error
                    bra       L51E0

L51DE               ldb       #$3B
L51E0               stb       <u0036
                    coma
                    puls      pc,u

L51E5               eora      #$45
                    anda      #$DF
                    beq       L520E
                    leax      -1,x
                    tst       <u0076
                    bne       L51F3
                    bra       L51DE

L51F3               tst       <u0077
                    bne       L523C
                    ldd       2,y
                    bne       L523C
L51FB               ldd       4,y
                    bmi       L523C
                    tst       <u0078
                    beq       L5207
                    nega                          NEGD
                    negb
                    sbca      #$00
L5207               std       1,y
L5209               lda       #$01
                    lbra      L5295

L520E               lda       ,x
                    cmpa      #$2B
                    beq       L521A
                    cmpa      #$2D
                    bne       L521C
                    inc       <u0075
L521A               leax      1,x
L521C               lbsr      L57DC
                    bcs       L51DE
                    tfr       a,b
                    lbsr      L57DC
                    bcc       L522C
                    leax      -1,x
                    bra       L5233

L522C               pshs      a                   Save 1's digit
                    lda       #10                 Multiply by 10 (for 10's digit)
                    mul
                    addb      ,s+
L5233               tst       <u0075
                    bne       L5238
                    negb
L5238               addb      <u0079
                    stb       <u0079
L523C               ldb       #$20
                    stb       1,y
                    ldd       2,y
                    bne       L524D
                    cmpd      4,y
                    bne       L524D
                    clr       1,y
                    bra       L5293

L524D               tsta
                    bmi       L525A
L5250               dec       1,y
                    lsl       5,y
                    rol       4,y
                    rolb
                    rola
                    bpl       L5250
L525A               std       2,y
                    clr       <u0075
                    ldb       <u0079
                    beq       L528B
                    bpl       L5267
                    negb
                    inc       <u0075
L5267               cmpb      #$13
                    bls       L527B
                    subb      #$13
                    pshs      b
                    leau      >L513E,pc
                    bsr       L529B
                    puls      b
                    lbcs      L51DA
L527B               decb
                    lda       #5
                    mul
                    leau      >L50E4,pc
                    leau      b,u
                    bsr       L529B
                    lbcs      L51DA
L528B               lda       5,y
                    anda      #$FE
                    ora       <u0078
                    sta       5,y
L5293               lda       #2                  Real # type
L5295               sta       ,y                  Save it in var packet
                    andcc     #$FE                Clear carry (no error)
                    puls      pc,u

L529B               leay      -6,y                Make room for temp var
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
                    lda       <u0075              Get sign of exponent?
                    lbeq      L4234               Real Divide
                    lbra      L40D3               Real Multiply

L52B2               lbsr      L57DC
                    bcc       L52C7
                    cmpa      #$61
                    blo       L52BD
                    suba      #$20
L52BD               cmpa      #$41
                    blo       L52DC
                    cmpa      #$46
                    bhi       L52DC
                    suba      #$37
L52C7               inc       <u0076
                    ldb       #4                  Loop counter for shift
L52CB               lsl       2,y
                    rol       1,y
                    lbcs      L51DA               If carried right out of byte, error
                    decb
                    bne       L52CB               Do all 4 shifts
                    adda      2,y
                    sta       2,y
                    bra       L52B2

L52DC               leax      -1,x
                    tst       <u0076
                    lbeq      L51DE
                    lbra      L5209

L52E7               pshs      x                   Preserve X
                    ldx       <u0082              Get current pos in temp buffer
                    lbsr      L514E
                    bcc       L52F2
L52F0               puls      pc,x

L52F2               cmpa      #2                  Real #?
                    beq       L52F9               Yes, continue ahead
                    lbsr      L509B               ??? convert to real?
L52F9               lbsr      L5384
                    bcs       L5305
                    ldb       #$3D                Illegal input format error
                    stb       <u0036              Save error code
                    coma                          Set carry
                    puls      pc,x                Restore X & return

L5305               stx       <u0082              Save new current pos in temp buffer
                    clra                          No error
                    puls      pc,x                Restore X & return

L530A               pshs      x                   Preserve X
                    ldx       <u0082              Get current pos in temp buffer
                    lbsr      L514E               ??? (returns A=var type)
                    bcs       L52F0
                    cmpa      #1                  Integer?
                    bne       L532A
                    tst       1,y
                    beq       L52F9
                    bra       L532A

L531D               pshs      x
                    ldx       <u0082              Get current pos in temp buffer
                    lbsr      L514E
                    bcs       L52F0
                    cmpa      #1                  Integer?
                    beq       L52F9               Yes, go back
L532A               ldb       #$3A                I/O Type mismatch error
* TO SAVE ROOM, SINCE ERRORS AREN'T CRUCIAL TO SPEED, MAY WANT THIS TO
* BRANCH TO SAME CODE @ L52F9
                    stb       <u0036
                    coma
                    puls      pc,x

L5331               pshs      u,x
                    leay      -6,y                Make room for temp var
                    ldu       <u004A
                    stu       1,y                 ??? Save some string ptr
                    lda       #4                  Type=String/complex
                    sta       ,y
                    ldx       <u0082
L533F               lda       ,x+
                    bsr       L5396
                    bcs       L5349
                    sta       ,u+
                    bra       L533F

L5349               stx       <u0082
                    lda       #$FF                Flag end of string?
                    sta       ,u+
                    stu       <u0048
                    clra
                    puls      pc,u,x

L5354               pshs      x
                    leay      -6,y
                    lda       #3
                    sta       ,y
                    clr       2,y
                    ldx       <u0082
                    bsr       L5390
                    bcs       L537F
                    cmpa      #'T
                    beq       L5379
                    cmpa      #'t
                    beq       L5379
                    eora      #$46
                    anda      #$DF
                    beq       L537B
                    ldb       #$3A
                    stb       <u0036
                    coma
                    puls      pc,x

L5379               com       2,y
L537B               bsr       L5384
                    bcc       L537B
L537F               stx       <u0082
                    clra
                    puls      pc,x

L5384               lda       ,x+
                    cmpa      #C$SPAC
                    bne       L5396
                    bsr       L5390
                    bcc       L53A5
                    bra       L53A7

L5390               lda       ,x+                 Get char
                    cmpa      #C$SPAC             Space?
                    beq       L5390               Yes, ignore & get next char
L5396               cmpa      <u00DD              Char we are looking for?
                    beq       L53A7               Yes, set carry & exit
                    cmpa      #C$CR               Carriage return?
                    beq       L53A5               Yes, point X to it, set carry & exit
                    cmpa      #$FF                End of string marker?
                    beq       L53A5               Yes, point X to it, set carry & exit
                    andcc     #$FE                Clear carry & return
                    rts

L53A5               leax      -1,x
L53A7               orcc      #$01
                    rts

L53AA               pshs      u,x
                    clra
                    sta       3,y
                    sta       <u0076
                    sta       <u0078
                    lda       #$04
                    sta       <u007E
                    ldd       1,y
                    bpl       L53C1               If positive, skip ahead
                    nega                          NEGD
                    negb
                    sbca      #$00
                    inc       <u0078              Set flag?
L53C1               leau      >L50DA,pc
L53C5               clr       <u007A
                    leau      2,u
L53C9               subd      ,u
                    bcs       L53D1
                    inc       <u007A
                    bra       L53C9

L53D1               addd      ,u
                    tst       <u007A
                    bne       L53DB
                    tst       $03,y
                    beq       L53E6
L53DB               inc       $03,y
                    pshs      a
                    lda       <u007A
                    lbsr      L54EA
                    puls      a
L53E6               dec       <u007E
                    bne       L53C5
                    tfr       b,a
                    lbsr      L54EA
                    leay      $06,y
                    puls      pc,u,x

* NOTE: 6809/6309 mod
L53F3               pshs      u,x
                    clr       <u0075              Replace with CLRA/CLRB/STD <u0075/STD <u0078/
                    clr       <u0078              STD <u007B (smaller & faster)
                    clr       <u007C
                    clr       <u007B
                    clr       <u0079
                    clr       <u0076
                    leau      ,x
                    ldd       #$0A30              Store 10 ASCI 0's at U
L5406               stb       ,u+
                    deca
                    bne       L5406
                    ldd       1,y
                    bne       L5413
                    inca
                    lbra      L54E4

L5413               ldb       5,y
                    bitb      #$01
                    beq       L541F
                    stb       <u0078
                    andb      #$FE
                    stb       5,y
L541F               ldd       1,y                 If this code is legit, why load D? just A?
                    bpl       L5426
                    inc       <u0075
                    nega
L5426               cmpa      #3
                    bls       L5457
                    ldb       #$9A                (154)
                    mul
                    lsra
                    nop       WHY                 ARE THESE HERE?
                    nop
                    tfr       a,b
                    tst       <u0075
                    beq       L5437
                    negb
L5437               stb       <u0079
                    cmpa      #$13
                    bls       L544A
                    pshs      a
                    leau      >L513E,pc
                    lbsr      L529B
                    puls      a
                    suba      #$13
L544A               leau      >L50E4,pc
                    deca
                    ldb       #$05
                    mul
                    leau      d,u
                    lbsr      L529B
L5457               ldd       2,y
                    tst       1,y
                    beq       L5483
                    bpl       L546F
L545F               lsra
                    rorb
                    ror       $04,y
                    ror       $05,y
                    ror       <u007C
                    inc       $01,y
                    bne       L545F
                    std       $02,y
                    bra       L5483

L546F               lsl       $05,y
                    rol       $04,y
                    rolb
                    rola
                    rol       <u007B
                    dec       $01,y
                    bne       L546F
                    std       $02,y
                    inc       <u0079
                    lda       <u007B
                    bsr       L54EA
L5483               ldd       $02,y
                    ldu       $04,y
L5487               clr       <u007B
                    bsr       L54F1
                    std       $02,y
                    stu       $04,y
                    pshs      a
                    lda       <u007B
                    sta       <u007C
                    puls      a
                    bsr       L54F1
                    bsr       L54F1
                    exg       d,u
                    addd      $04,y
                    exg       d,u
                    adcb      $03,y
                    adca      $02,y
                    pshs      a
                    lda       <u007B
                    adca      <u007C
                    bsr       L54EA
                    lda       <u0076
                    cmpa      #$09
                    puls      a
                    beq       L54C1
                    cmpd      #$0000
                    bne       L5487
                    cmpu      #$0000
                    bne       L5487
L54C1               sta       ,y
                    lda       <u0076
                    cmpa      #$09
                    bcs       L54E2
                    ldb       ,y
                    bpl       L54E2
L54CD               lda       ,-x
                    inca
                    sta       ,x
                    cmpa      #$39
                    bls       L54E2
                    lda       #$30
                    sta       ,x
                    cmpx      ,s
                    bne       L54CD
                    inc       ,x
                    inc       <u0079
L54E2               lda       #$09
L54E4               sta       <u0076
                    leay      6,y
                    puls      pc,u,x

L54EA               ora       #$30
                    sta       ,x+
                    inc       <u0076
                    rts

L54F1               exg       d,u
                    lslb
                    rola
                    exg       d,u
                    rolb
                    rola
                    rol       <u007B
                    rts

L54FC               pshs      y,x
                    ldx       <u0080
                    stx       <u0082
                    lda       #$01
                    sta       <u007D
                    ldy       #$0100
                    lda       <u007F
                    os9       I$ReadLn
                    bra       L5524

L5511               pshs      y,x
                    ldd       <u0082
                    subd      <u0080
                    beq       L5528
                    tfr       d,y
                    ldx       <u0080
                    stx       <u0082
                    lda       <u007F
                    os9       I$WritLn
L5524               bcc       L5528
                    stb       <u0036              Save error code
L5528               puls      pc,y,x

L552A               pshs      u,x
                    lda       ,y
                    cmpa      #$02
                    beq       L5536
                    ldu       $01,y
                    bra       L553D

L5536               lda       $01,y
                    bgt       L5542
                    ldu       #$0000
L553D               ldx       #$0000
                    bra       L555E

L5542               ldx       $02,y
                    ldu       $04,y
                    suba      #$20
                    bcs       L554F
                    ldb       #$4E
                    coma
                    bra       L5565

L554F               exg       x,d
                    lsra
                    rorb
                    exg       d,u
                    rora
                    rorb
                    exg       d,x
                    exg       x,u
                    inca
                    bne       L554F
L555E               lda       <u007F
                    os9       I$Seek
                    bcc       L5567
L5565               stb       <u0036              Save error code
L5567               puls      pc,u,x

L5569               pshs      u,x
                    leas      -$0A,s
                    leax      ,s
                    lbsr      L53F3
                    pshs      x
                    lda       #$09
                    leax      9,x
L5578               ldb       ,-x
                    cmpb      #$30
                    bne       L5583
                    deca
                    cmpa      #$01
                    bne       L5578
L5583               sta       <u0076
                    puls      x
                    ldb       <u0079
                    bgt       L55AC
                    negb
                    tfr       b,a
                    cmpb      #$09
                    bhi       L55C6
                    addb      <u0076
                    cmpb      #$09
                    bhi       L55C6
                    pshs      a
                    lbsr      L5643
                    clra
                    bsr       L5612
                    puls      b
                    tstb
                    beq       L55A8
                    lbsr      L5634
L55A8               lda       <u0076
                    bra       L55BF

L55AC               cmpb      #$09
                    bhi       L55C6
                    lbsr      L5643
                    tfr       b,a
                    bsr       L5601
                    bsr       L5612
                    lda       <u0076
                    suba      <u0079
                    bls       L55C1
L55BF               bsr       L5601
L55C1               leas      $0A,s
                    clra
                    puls      pc,u,x

L55C6               bsr       L5643
                    lda       #$01
                    bsr       L5601
                    bsr       L5612
                    lda       <u0076
                    deca
                    bne       L55D4
                    inca
L55D4               bsr       L5601
                    bsr       L55DA
                    bra       L55C1

L55DA               lda       #$45
                    bsr       L5614
                    lda       <u0079
                    deca
                    pshs      a
                    bpl       L55EB
                    neg       ,s
                    bsr       L5647
                    bra       L55ED

L55EB               bsr       L564B
L55ED               puls      b
                    clra
L55F0               subb      #$0A
                    bcs       L55F7
                    inca
                    bra       L55F0

L55F7               addb      #$0A
                    bsr       L55FD
                    tfr       b,a
L55FD               adda      #$30
                    bra       L5614

L5601               tfr       a,b
                    tstb
                    beq       L560D
L5606               lda       ,x+
                    bsr       L5614
                    decb
                    bne       L5606
L560D               rts

L560E               lda       #$20
                    bra       L5614

L5612               lda       #$2E
L5614               pshs      u,a                 Preserve regs
                    leau      <-$40,s             Is stack within 64 bytes of curr. pos in temp buff
                    cmpu      <u0082
                    bhi       L562A               No, skip ahead
                    cmpa      #C$CR               Is char we want added a CR?
                    beq       L562A               Yes, skip ahead
                    lda       #$50                ??? Error code 80? (internal flag byte?)
                    sta       <u0036              ??? Save error code 80?
                    sta       <u00DE              Save here too
                    puls      pc,u,a              Restore regs & return

L562A               ldu       <u0082              Get current pos in temp buffer
                    sta       ,u+                 Save char there
                    stu       <u0082              Save new current pos in temp buffer
                    inc       <u007D              Inc # active chars in temp buffer
L5632               puls      pc,u,a              Restore regs & return

L5634               lda       #$30
L5636               tstb                          Any chars left to do?
                    beq       L563E               No, exit
L5639               bsr       L5614               Save char (check for size within 64 of stack?)
                    decb                          Done all chars?
                    bne       L5639               No, keep adding chars
L563E               rts

L563F               tst       <u0078
                    beq       L560E
L5643               tst       <u0078
                    beq       L563E
L5647               lda       #$2D
                    bra       L5614

L564B               lda       #$2B
                    bra       L5614

L564F               lda       #C$SPAC             Space is fill char
                    bra       L5636               Go add B # of spaces to temp buffer

L5653               bsr       L5614
L5655               lda       ,x+
                    cmpa      #$FF
                    bne       L5653
                    rts

L565C               pshs      x
                    ldx       1,y
L5660               bsr       L5655
                    clra
                    puls      pc,x

L5665               pshs      x
                    leax      >L5143,pc
                    lda       2,y
                    bne       L5660
                    leax      >L5148,pc
                    bra       L5660

L5675               pshs      u,x
                    leas      -5,s
                    leax      ,s
                    lbsr      L53AA
                    bsr       L5643
                    lda       <u0076
                    leax      ,s
                    lbsr      L5601
                    leas      5,s
                    clra
                    puls      pc,u,x

* <u002A Function 2, sub-function $10 - Add B spaces to temp buffer
* Entry: A=# spaces to append to temp buffer
L568C               tfr       a,b                 Move byte we are working with to B
L568E               pshs      u                   Preserve U
                    ldu       <u0082              Get ptr to current pos in temp buffer
                    subb      <u007D              Callers # - # chars active in temp buffer
                    bls       L5698               If 0 or wraps negative, skip ahead
                    bsr       L564F               Go add chars
L5698               clra                          No error?
                    puls      pc,u                Restore U & return

L569B               lbsr      L560E
L569E               lda       <u007D
                    anda      #$0F
                    cmpa      #$01
                    beq       L56B2
                    lbsr      L560E
                    bra       L569E

L56AB               lda       #C$CR
                    clr       <u007D
                    lbsr      L5614
L56B2               clra
                    rts

L56B4               pshs      u
                    lda       #$04
                    leau      ,y
                    tst       ,u
                    bne       L56C1
                    asra
                    leau      1,u
L56C1               sta       <u0086
                    tfr       a,b
                    asrb
                    lbsr      L585D
                    puls      pc,u

L56CB               clrb
                    stb       <u0087
                    cmpa      #$3C
                    beq       L56DE
                    cmpa      #$3E
                    bne       L56D9
                    incb
                    bra       L56DE

L56D9               cmpa      #$5E
                    bne       L56E2
                    decb
L56DE               stb       <u0087
                    lda       ,x+
L56E2               cmpa      #$2C
                    beq       L571E
                    cmpa      #$FF
                    bne       L56FC
                    lda       <u0094
                    beq       L56F2
                    leax      -$01,x
                    bra       L5707

L56F2               ldx       <u008E
                    tst       <u00DC
                    beq       L5700
                    clr       <u00DC
                    bra       L571E

L56FC               cmpa      #$29
                    beq       L5703
L5700               orcc      #$01
                    rts

L5703               lda       <u0094
                    beq       L5700
L5707               dec       <u0092
                    bne       L571C
                    ldu       <u0046
                    pulu      y,a
                    sta       <u0092
                    sty       <u0090
                    stu       <u0046
                    lda       ,x+
                    dec       <u0094
                    bra       L56E2

L571C               ldx       <u0090
L571E               stx       <u008C
                    andcc     #$FE
                    rts

* Print USING format specifiers
L5723               fcc       'I'                 Integer
                    fdb       L5802-L5723
L5726               fcc       'H'                 Hexidecimal
                    fdb       L5802-L5726
L5729               fcc       'R'                 Real
                    fdb       L57F8-L5729
L572C               fcc       'E'                 Exponential
                    fdb       L57F8-L572C
L572F               fcc       'S'                 String
                    fdb       L5802-L572F
L5732               fcc       'B'                 Boolean
                    fdb       L5802-L5732
L5735               fcc       'T'                 Tab
                    fdb       L573F-L5735
L5738               fcc       'X'                 Spaces
                    fdb       L574A-L5738
L573B               fcc       "'"                 Quoted text
                    fdb       L5755-L573B
L573E               fcb       $00                 End of table marker

* 'T' (tab)
L573F               bsr       L56E2
                    bcs       L57A7
                    ldb       <u0086
                    lbsr      L568E
                    bra       L5772

* 'X' (spaces)
L574A               bsr       L56E2
                    bcs       L57A7
                    ldb       <u0086
                    lbsr      L564F
                    bra       L5772

* '' (quoted text)
L5755               cmpa      #$FF                End of string?
                    beq       L57A7               Yes, skip ahead
                    cmpa      #$27                A single quote (')?
                    bne       L5765               No, skip ahead
                    lda       ,x+
                    bsr       L56E2
                    bcs       L57A7
                    bra       L5772

L5765               lbsr      L5614
                    lda       ,x+
                    bra       L5755

L576C               pshs      y,x
                    clr       <u00DC
                    inc       <u00DC
L5772               ldx       <u008C
                    bsr       L57C2
                    bcs       L5791
                    cmpa      #'(                 Repeat char?
                    bne       L57AB
                    lda       <u0092
                    stb       <u0092
                    beq       L57AB
                    inc       <u0094
                    ldu       <u0046
                    ldy       <u0090
                    pshu      y,a
                    stu       <u0046
                    stx       <u0090
                    lda       ,x+
L5791               leay      <L5723,pc           Point to start of specifiers table
                    clrb                          Init Specifier # to 0
L5796               pshs      a                   Preserve original char
                    eora      ,y                  Flip any differing bits
                    anda      #$DF                Mask out uppercase bit
                    puls      a                   Restore original char
                    beq       L57B2               If char matches, skip ahead
                    leay      3,y                 Point to next table entry
                    incb                          Bump up specifier #
                    tst       ,y                  Are we at the end?
                    bne       L5796               Nope, keep looking
L57A7               ldb       #$3F                I/O Format Syntax Error
                    bra       L57AD               Exit with error

L57AB               ldb       #$3E

L57AD               stb       <u0036              Save error code
                    coma                          Set carry
                    puls      pc,y,x              Restore regs & return

* Found specifier match
L57B2               stb       <u0085              Save specifier #
                    ldd       1,y                 Get offset
                    leay      d,y                 Add to base address
                    bsr       L57C2               Get up to 3 digit ASCII #'s, convert to binary
                    bcc       L57BE               Got it, skip ahead
                    ldb       #$01                None found, force to 1
L57BE               stb       <u0086              Save binary version of number
                    jmp       ,y                  Execute PRINT USING specifier routine

* Convert 3 digit ASCII decimal # @ ,X to binary equivalent. Carry clear if
* done, carry set if not ASCII decimal digits present
L57C2               bsr       L57DC               Go try & get ASCII number 0-9
* NOTE: 6809/6309 MOD, CHANGE TO BCS TO RTS, NOT ORCC/RTS
                    bcs       L57ED               None found, Set carry & exit
                    tfr       a,b                 Move binary digit 0-9 to B
                    bsr       L57DC               Try & get another ASCII number 0-9
                    bcs       L57E8               Couldn't, exit with carry clear anyways
                    bsr       L57EE               Convert 2 digit # into binary version (D)
                    bsr       L57DC               Try & get another ASCII number 0-9
                    bcs       L57E8               Couldn't, exit with carry clear anyways
                    bsr       L57EE               Convert this digit & add to previous total
                    tsta                          result <255? (useless, ADCA should set flags)
                    beq       L57D8               Yes, get next char & exit with carry clear
                    clrb                          Force result to 256
L57D8               lda       ,x+                 Get next char
                    bra       L57E8               Exit with carry clear

L57DC               lda       ,x+                 Get char
L57DE               cmpa      #'0                 If not ASCII 0-9, exit with carry set
                    blo       L57ED               (Same as BCS)
                    cmpa      #'9
                    bhi       L57EB
                    suba      #$30                If it is 0-9, convert to binary & exit with
L57E8               andcc     #$FE                carry clear
                    rts

L57EB               orcc      #$01
L57ED               rts

* Entry: A=LSB of ASCII 0-9 converted to binary, B=MSB
* IF NOT CALLED BY OTHER ROUTINES USING IT, MAY WANT TO USE DP LOCATION 14
* INSTEAD OF STACK
L57EE               pshs      a                   Save Low nibble?
                    lda       #10                 Multiply B by 10
                    mul
                    addb      ,s+                 Add to saved nibble
                    adca      #$00                possible carry into D
                    rts

L57F8               cmpa      #'.
                    bne       L57A7
                    bsr       L57C2
                    bcs       L57A7
                    stb       <u0089

L5802               lbsr      L56CB
                    bcs       L57A7
                    puls      y,x
                    inc       <u00DC
L580B               ldb       <u0085
                    lbeq      L58B3
                    decb
                    beq       L5826
                    decb
                    lbeq      L5969
                    decb
                    lbeq      L5A10
                    decb
                    lbeq      L591E
                    lbra      L5904

L5826               jsr       <u0016
                    cmpa      #4                  Numeric?
                    blo       L583C               Yes, skip ahead
                    ldu       1,y                 Get ptr to string data
                    clrb                          Clear count=0
L582F               lda       ,u+                 Get char from string
                    cmpa      #$FF                EOS?
                    beq       L5838               Yes, skip ahead
                    incb                          Bump up count
                    bne       L582F               Do until EOS or 256 chars
L5838               ldu       1,y                 Get string ptr again
                    bra       L585D               Skip ahead with U=ptr to string, B=size of string

L583C               leau      1,y
                    lda       ,y                  Get var type
                    cmpa      #2                  Real #?
                    bne       L5848               No, skip ahead
                    ldb       #5                  Yes, force size to 5 bytes
                    bra       L585D

L5848               cmpa      #1                  Integer?
                    bne       L5852               No, skip ahead
                    ldb       #2                  Yes, size=2 bytes
                    cmpb      <u0086              Same or less than ???
                    blo       L5856               Yes, leave as 2
L5852               ldb       #1                  Anything else (BYTE/BOOLEAN) is 1 byte
                    leau      1,u
L5856               tfr       b,a
                    lsla
                    cmpa      <u0086
                    bhi       L5893
L585D               tst       <u0087
                    beq       L5889
                    bmi       L5870
                    pshs      b
                    lslb
                    pshs      b                   SUBR
                    ldb       <u0086
                    subb      ,s+
                    blo       L5887
                    bra       L587C

L5870               pshs      b
                    lslb
                    pshs      b
                    ldb       <u0086
                    subb      ,s+
                    bcs       L5887
                    asrb
L587C               pshs      b
                    lda       <u0086
                    suba      ,s+
                    sta       <u0086
                    lbsr      L564F
L5887               puls      b
L5889               lda       ,u
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       L58A3
                    beq       L58A1
L5893               lda       ,u+
                    bsr       L58A3
                    beq       L58A1
                    decb
                    bne       L5889
                    ldb       <u0086
                    lbsr      L564F
L58A1               clra
                    rts

L58A3               anda      #$0F
                    cmpa      #$09
                    bls       L58AB
                    adda      #$07
L58AB               lbsr      L55FD
                    dec       <u0086
                    rts

L58B1               coma
                    rts

L58B3               jsr       <u0016
                    cmpa      #$02
                    bcs       L58BE
                    bne       L58B1
                    lbsr      L5098
L58BE               pshs      u,x
                    leas      -5,s
                    leax      ,s
                    lbsr      L53AA
                    ldb       <u0086
                    decb
                    subb      <u0076
                    bpl       L58D5
                    leas      5,s
                    puls      u,x
                    lbra      L5A07

L58D5               tst       <u0087
                    beq       L58E3
                    bmi       L58F4
                    lbsr      L564F
                    lbsr      L563F
                    bra       L58FA

L58E3               lbsr      L563F
                    pshs      b
                    lda       <u0076
                    lbsr      L5601
                    puls      b
                    lbsr      L564F
                    bra       L58FF

L58F4               lbsr      L563F
                    lbsr      L5634
L58FA               lda       <u0076
                    lbsr      L5601
L58FF               leas      5,s
                    clra
                    puls      pc,u,x

L5904               jsr       <u0016              Go get var type
                    cmpa      #3                  Boolean?
                    bne       L58B1               No, set carry & exit
                    pshs      u,x                 Preserve regs
                    leax      >L5143,pc           Point to 'True'
                    ldb       #4                  Size of 'True'
                    lda       2,y                 Get boolean value
                    bne       L5932               $FF is true, so skip ahead
                    leax      >L5148,pc           Point to 'False'
                    ldb       #5                  Size of 'False'
                    bra       L5932               Go deal with it

L591E               jsr       <u0016              Go get var type
                    cmpa      #4                  String?
                    bne       L58B1               No, exit with carry set
                    pshs      u,x                 Preserve regs
                    ldx       1,y                 Get ptr to string
                    ldd       <u0048
                    subd      1,y
                    subd      #1
                    tsta
                    bne       L5936
L5932               cmpb      <u0086
                    bls       L5938
L5936               ldb       <u0086
L5938               tfr       b,a
                    negb
                    addb      <u0086
                    tst       <u0087
                    beq       L594F
                    bmi       L5953
                    pshs      a
                    lbsr      L564F
                    puls      a
                    lbsr      L5601
                    bra       L5966

L594F               pshs      b
                    bra       L595E

L5953               lsrb
                    bcc       L5957
                    incb
L5957               pshs      d
                    lbsr      L564F
                    puls      a
L595E               lbsr      L5601
                    puls      b
                    lbsr      L564F
L5966               clra
                    puls      pc,u,x

L5969               jsr       <u0016              Go get var type
                    cmpa      #2                  Real?
                    beq       L5976               Yes, skip ahead
                    lbcc      L58B1               If carry clear, set carry & exit
                    lbsr      L509B               ??? possible convert?
L5976               pshs      u,x
                    leas      -$0A,s
                    leax      ,s
                    lbsr      L53F3
                    lda       <u0079
                    cmpa      #$09
                    bgt       L5996
                    lbsr      L5A6A
                    lda       <u0086
                    suba      #$02
                    bmi       L5996
                    suba      <u0089
                    bmi       L5996
                    suba      <u008A
                    bpl       L599C
L5996               leas      $0A,s
                    puls      u,x
                    bra       L5A07

L599C               sta       <u0088
                    leax      ,s
                    ldb       <u0087
                    beq       L59AC
                    bmi       L59B2
                    bsr       L59E9
                    bsr       L59BE
                    bra       L59B9

L59AC               bsr       L59BE
                    bsr       L59E9
                    bra       L59B9

L59B2               bsr       L59E9
                    bsr       L59C1
                    lbsr      L563F
L59B9               leas      $0A,s
                    clra
                    puls      pc,u,x

L59BE               lbsr      L563F
L59C1               lda       <u008A
                    lbsr      L5601
                    lbsr      L5612
                    ldb       <u0079
                    bpl       L59F9
                    negb
                    cmpb      <u0089
                    bls       L59D4
                    ldb       <u0089
L59D4               pshs      b
                    lbsr      L5634
                    ldb       <u0089
                    subb      ,s+
                    stb       <u0089
                    lda       <u008B
                    cmpa      <u0089
* 6809/6309 MOD: SHOULD BE BLS L59FB
                    bls       L59E7
                    lda       <u0089
L59E7               bra       L59FB

L59E9               ldb       <u0088
                    lbra      L564F

L59EE               lbsr      L563F
                    lda       <u008A
                    lbsr      L5601
                    lbsr      L5612
L59F9               lda       <u008B
L59FB               lbsr      L5601
                    ldb       <u0089
                    subb      <u008B
                    ble       L5A0F
                    lbra      L5634

L5A07               ldb       <u0086
                    lda       #$2A                * (?)
                    lbsr      L5636
                    clra
L5A0F               rts

L5A10               jsr       <u0016              Go get variable type
                    cmpa      #2                  Real?
                    beq       L5A1D               Yes, skip ahead
                    lbcc      L58B1               If carry clear, set carry & exit
                    lbsr      L509B               ??? Convert to real?
L5A1D               pshs      u,x
                    leas      -$0A,s
                    leax      ,s
                    lbsr      L53F3
                    lda       <u0079
                    pshs      a
                    lda       #1
                    sta       <u0079
                    bsr       L5A6A
                    puls      a
                    ldb       <u0079
                    cmpb      #1
                    beq       L5A39
                    inca
L5A39               ldb       #1
                    stb       <u008A
                    sta       <u0079
                    lda       <u0086
                    suba      #6
                    bmi       L5A4D
                    suba      <u0089
                    bmi       L5A4D
                    suba      <u008A
                    bpl       L5A53
L5A4D               leas      $0A,s
                    puls      u,x
                    bra       L5A07

L5A53               sta       <u0088
                    ldb       <u0087
                    beq       L5A62
                    bsr       L59E9
                    bsr       L59EE
                    lbsr      L55DA
                    bra       L5A67

L5A62               bsr       L59EE
                    lbsr      L55DA
L5A67               lbra      L59B9

L5A6A               pshs      x                   Save ptr to beginning of string number
                    lda       <u0079
                    adda      <u0089
                    bne       L5A78
                    lda       ,x
                    cmpa      #$35
                    bcc       L5A8F
L5A78               deca
                    bmi       L5AAB
                    cmpa      #$07
                    bhi       L5AAB
                    leax      a,x
                    ldb       1,x
                    cmpb      #$35
                    blo       L5AAB
L5A87               inc       ,x                  Inc ASCII digit
                    ldb       ,x                  Get digit
                    cmpb      #'9                 Past 9?
                    bls       L5AAB               No, skip ahead
L5A8F               ldb       #'0                 Wrap to 0
                    stb       ,x
                    leax      -1,x                Bump ptr back
                    cmpx      ,s                  Hit beginning of text string yet?
                    bhs       L5A87               No, loop back & continue
                    ldx       ,s                  Get beginning of text string ptr
                    leax      8,x                 Point 8 bytes past start
L5A9D               lda       ,-x                 Block move bytes from 0-6 to 1-7
                    sta       1,x
                    cmpx      ,s                  Done moving?
                    bhi       L5A9D               No, keep going until done
                    lda       #'1                 Force 1st digit to 1
                    sta       ,x
                    inc       <u0079
L5AAB               puls      x                   Get string ptr back
                    lda       <u0079
                    bpl       L5AB2
                    clra
L5AB2               sta       <u008A
                    nega
                    adda      #$09
                    bpl       L5ABA
                    clra
L5ABA               cmpa      <u0089
                    bls       L5AC0
                    lda       <u0089
L5AC0               sta       <u008B
                    rts

L5AC3               ldb       #48                 Unimplemented routine error
                    stb       <u0036              Save error code
                    coma                          Exit with error
                    rts

				ifne		F256
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
                    bne       isItF256K
                    leax      OUTSTR2,pcr
                    ldy       #STRLEN2
                    lda       #1
                    os9       I$Writln
                    bcs       ERROR
                    bra       CONT
isItF256K           cmpa      #$12
                    bne       isItF256K2
                    leax      OUTSTR3,pcr
                    ldy       #STRLEN3
                    lda       #1
                    os9       I$Writln
                    bcs       ERROR
                    bra       CONT
isItF256K2          cmpa      #$16
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
ERROR               lbra      L08A6
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
                    fcb       $20,$20,$1b,$32,$01
STRLEN              equ       *-OUTSTR
OUTSTR2             fcc       /F256 Jr./
                    fcb       $0D
STRLEN2             equ       *-OUTSTR2
OUTSTR3             fcc       / F256K/
                    fcb       $0D
STRLEN3             equ       *-OUTSTR3
OUTSTR4             fcc       /F256K2/
                    fcb       $0D
STRLEN4             equ       *-OUTSTR4
OUTSTR5             fcc       /F256 Jr2/
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
