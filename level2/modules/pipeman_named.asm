********************************************************************
* PipeMan - OS-9 Level Two Named Pipe File Manager
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          1986/02/23  Kent D. Meyers
* Pipeman Modified to Include the SS.Ready I$GETSTT Call.
*
*          1986/03/26  Kent D. Meyers
* Major Bug Corrected.
*
*          1988/06/29  Kent D. Meyers
* Upgraded to Level II version.
*
*          1988/11/11  Chris J. Burke
* Added new labels and special defs.
* Added code to detect EOF in SS.Ready
* Reformatted to make the module easier to understand during coding.
*
*          1988/12/03  Chris J. Burke
* Added named pipes, etc for Level 2 upgrade, includes SS.SSig,
* SS.Relea, SS.Attr, SS.FD
*
*   1      1988/12/26  Chris J. Burke
* Release 1.0 for Tandy CoCo OS-9.

                    nam       PipeMan
                    ttl       OS9 Level Two Named Pipe File Manager

*
*   Copyright 1981, 1985, 1986, 1988 by Microware Systems Corporation
*   All Rights Reserved
*
*   Named pipe code by Burke & Burke.
*   All rights assigned to Microware Systems Corporation.
*
*   This file contains proprietary information of Microware Systems
*   Corporation.  Persons accessing this file will be held strictly
*   accountable for their use of the information herein.
*

*
*   PIPEMAN
*
*   Pipe File Manager
*
*   WARNING
*   -------
*
*   Opening an existing named pipe emulates IOMan's I$Close and
*   I$Dup calls.  This file manager contains subroutines that
*   mimic the current operation of IOMan.  Any changes to IOMan's
*   FMEXEC, I$Close or I$Dup calls must also be made to this code.
*
*   Device Driver Static Storage Layout
*   -----------------------------------
*
*   $00-$01 V.List  Pointer in system map to pipe buffer for 1st
*                   pipe (16 bits).
*
*   Pipe Buffer Data Structure
*   --------------------------
*
*   $00-$01 PP.PD   Pointer to shared path descriptor
*   $02-$03 PP.Next Pointer to next pipe buffer in system map
*   $04-$05 PP.Prev Pointer to previous pipe buffer in system map
*   $06-$07 PP.Rsv2 Reserved
*
*   $08     PP.Data Data buffer begins at this offset
*
*   Path Descriptor Data Structure
*   ------------------------------
*
*   $00     PD.PD   Path number
*   $01     PD.MOD  Access permissions
*   $02     PD.CNT  Number of open images (e.g. I$DUP)
*   $05     PD.CPR  Current process ID
*   $06-$07 PD.RGS  Address of caller's register stack
*   $08-$09 PD.BUF  System space pipe buffer base pointer
*** PP.Read must have bit 4 clear; PP.Writ must be PP.Read XOR 4
*  $0A      PD.Read No bytes -- offset only
*   $0A     PD.RPID Process ID of reader waiting on signal
*   $0B     PD.RCT  Number of blocked readers
*   $0C     PD.RSIG Signal to send reader
*   $0D     PD.REOR Read EOR character
*  $0E      PD.Writ No bytes -- offset only
*   $0E     PD.WPID Process ID of writer waiting on signal
*   $0F     PD.WCT  Number of blocked writers
*   $10     PD.WSIG Signal to send writer
*   $11     PD.WEOR Write EOR character (dummy)
*** End of special section
*   $12-$13 PD.End  Pointer to end of pipe buffer
*   $14-$15 PD.NxtI Next in pointer
*   $16-$17 PD.NxtO Next out pointer
*   $18     PD.RFlg "Ready" flag
*   $19     PD.Wrtn "Written" flag
*   $1A-$1B PD.BCnt # queue elements currently bufered
*   $1C     PD.Own  Process ID of pipe original creator
*   $1D     PD.Keep Non-zero if this pipe has been kept open artificially
*   $1E-$1F PD.QSiz Max. size of queue (in elements)
*   .
*   .
*   $20     PD.DTP  Device type $02 = PIPE
*   $21     PD.ESiz Size of each queue element
*   $22-$23 PD.ECnt Max. elements in queue
*   $23-$3F PD.Name Pipe name (after moving PD.ECnt to PD.QSiz)
*

                    page
*
*   Global equates
*
                    ifp1
                    use       defsfile
                    use       pipe.d
                    endc

*
*   Local Equates
*

XVER                equ       3                   ;Version

*   ASCII CONTROL CHARACTERS

CR                  equ       $0D

*   CONDITION CODES

*   PIPEMAN SPECIAL OFFSETS.

PM.CPR              equ       PD.RPID-PD.READ
PM.CNT              equ       PD.RCT-PD.READ
PM.SIG              equ       PD.RSIG-PD.READ
PM.EOR              equ       PD.REOR-PD.READ

*   IOMAN special offsets.
*
*   This constant is IOMAN release-dependent.
*   It is the number of bytes between the entry stack
*   pointer and the stacked PD pointer saved by *IOMAN*.
*   Currently, the stack looks like this:
*
*       A   PL
*       9   PH  <IOMAN post-SOPEN return address>
*       8   UL
*       7   UH
*       6   YL  +
*       5   YH  <PD pointer saved by IOMAN>
*       4   XL
*       3   XH
*       2   A
*       1   PL
* SP->  0   PH  <post OPEN/CREATE return address>
*               <start of stack to be used by PIPEMAN>

IOMAGIC             equ       5                   ;5 bytes to PD pointer

*   Local pipe buffer equates

CInit               equ       %00100000           ;Set this bit to override PD queue parameters

*   Conditional assembly

ANON                set       0                   ;Anonymous pipes only
NAMED               set       1                   ;Anonymous and named pipes
MSGS                set       2                   ;Both types of pipes, and message queues
WIZBANG             set       NAMED               ;What features are we providing?

NODIR               set       0                   ;Don't allow DIR on pipe devices
YESDIR              set       1                   ;Allow DIR on pipe devices
PIPEDIR             set       YESDIR              ;Does DIR work on pipes?

SLOWPD              set       0                   ;Slow PD location algorithm
QUICKPD             set       1                   ;Fast PD location algorithm
PDALGO              set       QUICKPD             ;How to convert PD to system path #

RECKLES             set       0                   ;Don't check for certain errors
CAREFUL             set       1                   ;Check for certain errors
CAUTION             set       CAREFUL

                    page
*
*   Module Header
*

edition             set       1

                    mod       MODSIZE,MODNAM,FlMgr+Objct,ReEnt+XVER,JmpTbl,$0000

*   Module Name

MODNAM              fcs       "PipeMan"
                    fcb       edition

*   Jump table

JmpTbl              lbra      Create
                    lbra      Open
                    lbra      MakDir
                    lbra      ChgDir
                    lbra      Delete
                    lbra      Seek
                    lbra      Read
                    lbra      Write
                    lbra      ReadLn
                    lbra      WriteLn
                    lbra      GetStt
                    lbra      SetStt
                    lbra      Close

                    page
*
*   Create a named or anonymous pipe
*
*   The size of the queue is determined by examining
*   the path descriptor, since this information has
*   been copied there from the device descriptor.
*
*   Reg-U points to stacked registers of user.
*   Reg-Y points to path descriptor
*
*   If success, carry clear and X points to pipe buffer
*

*   Create function allows user to override both element
*   count and element size.  Override is enabled if if bit
*   5 of the access mode is set.  For override, if MS bit
*   of Reg-Y is clear, just use Reg-Y as queue element
*   count.  If MS bit of Reg-Y is set, use LS byte of
*   Reg-Y as element size ($00 = no change) and bottom 7
*   bits of MS byte of Reg-Y as element count ($00 = no change)

Create              equ       *

                    lda       R$A,U               ;Get access mode
                    bita      #CInit
                    beq       Open

*   Handle queue size override

                    ldd       R$Y,U               ;Get queue size initializer
                    bpl       SetCnt              ; (branch if just setting count)

*   Set element size and count

                    tstb
                    beq       Creat00             ; (branch if using default size)

                    stb       PD.ESiz,Y           ;Reg-B = size of each element

Creat00             anda      #$7F
                    beq       Open                ; (branch if using default count)

                    tfr       a,B
                    clra

*   Set number of elements in queue from Reg-D

SetCnt              std       PD.ECnt,Y           ;Reg-D = number of elements

*   Enter here for normal OPEN

Open                equ       *

*   Move number of elements in queue to make room for name

                    ldd       PD.ECnt,Y
                    std       PD.QSiz,Y

*   Parse pathname

                    clrb                          ;Assume anonymous pipe
                    clra                          ;Assume not 1st pipe
                    ldx       R$X,U               ;Point at file name in user's space
                    pshs      U,Y,X,D             ;Save file name, PD, reg. base, 1st & anon flag

*       Caller's Regs Ptr
*       PD Ptr
*       Path name uptr
*       Named flag
*  SP-> First flag

                    os9       F$PrsNam            ;Error if driver name (e.g. /pipe) invalid
                    bcs       BadName

*   See if named or anonymous pipe requested.

                    lbsr      GtNext              ;Return CC=MI if at end of path name
                    cmpa      #'/
                    beq       HasName

*   /pipe____
*    X   Y
*   Pipe is anonymous -- set up dummy name in PD.
*   Stack must match the named pipe setup

NotName             tfr       Y,X                 ;Skip any trailing blanks
                    os9       F$PrsNam            ; (should return carry set)
                    ldd       #1                  ;Length of dummy name
                    pshs      Y,X,D

                    ldy       10,S                ;Get PD pointer
                    clr       PD.Name,Y           ; and set dummy name

                    bra       GoCheck

*   /pipe/foo____
*    X   Y
*   Pipe is named -- check length and flag on stack

HasName             tfr       Y,X
                    os9       F$PrsNam            ;Scan off the name
                    bcs       BadName

                    cmpb      #NameMax            ;Check length of name
                    bhi       BadName

*   Length OK.  X points to start of name, Y to end of name,
*   B has name length.
*   Save registers & length, and do final parse to skip white

                    com       1,S                 ;Set "named" flag
                    clra
                    pshs      Y,X,D

                    tfr       Y,X
                    os9       F$PrsNam            ;Error if trying for pipe subdirectory
                    bcc       BadNam2

*   /pipe/foo____
*            X   Y
*   Need to get the pipe name into our address space
*   Use the PD for a temporary buffer.

NameOK              ldx       <D.Proc             ;Pointer to caller's PD
                    lda       P$Task,X            ; get caller's DAT image #
                    ldx       <D.SysPrc           ;Pointer to our PD
                    ldb       P$Task,X            ; get system's DAT image #
                    ldy       0,S                 ;Byte count
                    ldx       2,S                 ;Source address
                    ldu       10,S                ;Get PD pointer and convert to . . .
                    leau      PD.Name,U           ;Destination address
                    lbsr      MovSet              ;Move block, set MSB of last byte.

*   Wow!  Everybody's in the same address space now.

*   Since this is a named pipe, force mode to UPDATE.
*   Also, do not permit DIR. access

                    ldx       10,S
                    lda       PD.MOD,X
                    bita      #DIR.
                    bne       BadNam2

                    ora       #(READ.+WRITE.)
                    sta       PD.MOD,X

*   See if this is an existing pipe.  To do this, we
*   must get the linked list head pointer from the
*   device driver's static storage.
*
*   Stack looks like this:
*
*   C   2   Sysmap Reg Pointer
*   A   2   Sysmap PD Pointer
*   8   2   Usrmap Path name pointer
*   7   1   Named pipe flag
*   6   1   First pipe flag
*   4   2   Usrmap Pipe name end pointer
*   2   2   Usrmap Pipe name start pointer
*   0   2   Name length
*   sp->

GoCheck             ldx       10,S                ;Get PD pointer
                    ldx       PD.DEV,X            ;Get device table pointer
                    ldu       V$Stat,X            ;Get static storage pointer
                    ldx       V.List,U            ;Get pointer to head of pipe bfr linked list
                    bne       Not1st              ; (reg-X = $0000 if no previous pipes)

*   This is the 1st pipe for this descriptor.
*   Reg-X = $0000
*   Set flag and process as a new pipe.

                    com       6,S                 ;This is the first pipe
                    bra       NewPipe             ;This is a new pipe

*   No time like the present for some error handlers

*   Generic error, cleaning stack

BadXit2             leas      8,S
                    coma                          ;Set carry
                    rts

*   Bad Pathname -- 2 versions, depending on
*   how much junk is on the stack.

BadNam2             leas      6,S                 ;Clean stack
BadName             ldb       #E$BPNam
                    bra       BadXit2

*   Not Enough System RAM

TooBig              ldb       #E$NoRAM
BadExit             leas      6,S                 ;Clean stack
                    bra       BadXit2

*   Look up the pipe name, unless the pipe is anonymous.
*
*   Reg-U points to driver static storage.
*   Reg-X points to next pipe buffer to check.

Not1st              tst       7,S                 ;Unnamed pipes are always new
                    beq       NewPipe

                    ldy       10,S                ;point at PD
                    leay      PD.Name,Y           ; then point at name in PD

*   Main loop.  Always at least 1 pipe buffer to check first time through.
*   Reg-X points to buffer to check, or $0000 if none.
*   Reg-Y points to desired pipe name.

ChkLoop             pshs      X
                    ldx       PP.PD,X             ;Point at PD for this pipe buffer
                    leax      PD.Name,X           ; and then point at name stored in PD
                    lbsr      Compare
                    puls      X
                    lbeq      OldPipe             ; (got a match)

                    ldd       PP.Next,X           ;Don't fall off the edge
                    beq       NewPipe             ; (end of list)

                    tfr       D,X                 ;Advance to next buffer
                    bra       ChkLoop

*   Pipe name not found.  Create a new pipe.
*
*   Reg-U points to driver static storage.
*   Reg-X points to last pipe buffer checked ($0000 if 1st pipe)

NewPipe             ldy       10,S                ;Get PD pointer

                    ifeq      (PIPEDIR-YESDIR)
                    lda       PD.MOD,Y            ;Check pipe attributes
                    bita      #DIR.
                    beq       NEWP1

*   Initialize pipe characteristics for DIR. bit set

                    lbsr      SizDirP
*         beq    XYZZY       ;Special if no pipes created
                    endc

*   Normal (non-dir) processing

NewP1               ldd       PD.QSiz,Y           ;Get max element count
                    bne       DoNew               ; (graceful operation if no count)

*   Default pipe parameters if none in PD.

                    ldd       #$0100              ;Assume 256 byte buffer, 1 byte element
                    sta       PD.ESiz,Y           ;Reg-A = 1
                    subd      #PP.Data            ;Compute elements for total size = 256
                    std       PD.QSiz,Y           Use parameters in PD

DoNew               lbsr      ECtoBC              ;Convert element count to byte count in D
                    bcs       TooBig              ; (carry set if too big)

*   Carry has exit status
*   Reg-D = # bytes for queue, w/o overhead
*   Reg-X = previous buffer
*   Reg-U = driver static storage

                    tfr       U,Y                 ;Save static storage pointer

                    addd      #PP.Data            ;Add in overhead
                    bcs       TooBig

                    pshs      D                   ;Save buffer size
                    os9       F$SrqMem            ;Attempt to allocate buffer
                    puls      D                   ;Recover size, clean stack, lose error msg
                    bcs       TooBig

*   Found enough memory for pipe buffer.
*
*   Pointer in Reg-U
*   Size in Reg-D
*   Previous buffer in Reg-X.
*   Driver static storage in Reg-Y.
*
*   Initialize the buffer

                    pshs      U,D                 ;Save buffer pointer & size

*   Clear pipe buffer header

                    ldb       #PP.Data            ;Size of header
ClrBuf              clr       ,U+
                    decb
                    bne       ClrBuf

                    puls      D,U

*   Initialize path descriptor and other fields of pipe buffer
*   for new pipe.
*
*   Pointer in Reg-U
*   Size in Reg-D
*   Previous buffer in Reg-X.
*   Driver static storage in Reg-Y.
*
*   IOMan has already prefilled the PD to $00 and
*   has set PD.CNT for this path to 1.

                    pshs      Y,X                 ;Save static storage pointer & prev.buff

                    ldy       (4+10),S            ;Get PD pointer to Reg-Y
                    sty       PP.PD,U             ;Save pointer to PD in pipe buffer

                    leax      D,U                 ;Point to end of pipe.buff + 1
                    stx       PD.End,Y

                    leax      PP.Data,U           ;Initial Next in & Next out pointers
                    stx       PD.NxtI,Y
                    stx       PD.NxtO,Y

                    ldx       <D.Proc             ;Save ID of original creator
                    lda       P$ID,X
                    sta       PD.Own,Y

                    puls      Y,X                 ;Recover static storage pointer and prev.buff

                    stx       PP.Prev,U           ;Save address of previous buffer ($0 if none)
                    bne       LinkIn              ; (branch if this isn't the 1st pipe)

*   Special -- this is the first pipe.
*   Set PP.Next to $0000 and store buffer address in device memory.
*
*   Reg-U = pointer to new buffer.
*   Reg-X = $0000.
*   Reg-Y = static storage

**  Zero prefill of PP header covers this
**        stx     PP.Next,U       ;No next buffer
**        stx     PP.Prev,U       ;No previous buffer
                    stu       V.List,Y            ;Point driver static at this buffer
                    bra       IsAsOld

*   There are other named pipes.  Link this one in correctly
*   after the last one checked.
*
*   Reg-U = pointer to new buffer.
*   Reg-X = Pointer to previous buffer.
*   Reg-Y = static storage.

LinkIn              ldd       PP.Next,X           ;Get old's next (could be $0000)
                    stu       PP.Next,X           ;Set old's next pointing at new
                    std       PP.Next,U           ;Set new's next where old's was
                    stx       PP.Prev,U           ;Set new's prev pointing at old
                    pshs      X,D
                    ldx       0,S                 ;Point X at original old's next
                    beq       Link9               ; (branch if no next -- $0000 set already)
                    stu       PP.Prev,X           ;Set prev of old's original next to new
Link9               puls      D,X

*   Now we look pretty much like a new access to an old pipe.
*   Fix up pointers to match "old pipe" code

IsAsOld             tfr       U,X                 ;Point Reg-X at pipe buffer
                    tfr       Y,U                 ;Point Reg-U at driver static storage
                    ldy       10,S                ;Recover PD pointer
                    stx       PD.BUF,Y            ;Set up buffer pointer in PD
                    bra       OpnXit              ; (go to common trailer code)

*   Pipe name found.  Set up to access an old pipe.
*
*   Reg-U points to driver static storage.
*   Reg-X points to matching pipe buffer.
*
*   We need to make this look like a DUP call, so
*   there's some nasty code here to give back the
*   PD allocated by IOMan and go get the "original"
*   PD for this named pipe.

OldPipe             equ       *

***                                                       ***
*   WARNING -- This code emulates IOMan's I$Close and I$Dup *
***                                                       ***

*
*   Processing to give back the new path descriptor and use
*   the original PD that the pipe was opened with.
*
*       Fake close of PD passed by IOMan
*       Fake dup of named pipe's "master" PD
*       Fix PD pointer saved on IOMAN's stack
*
*   All of the subroutines preserve all regs, except as noted
*   This section MUST preserve Reg-X and Reg-U.  There must
*   be exactly 14 bytes on the stack at this point.

                    ldy       10,S                ;Get IOMAN PD pointer (original Reg-Y)

*   Detach the path.

                    pshs      U
                    ldu       PD.DEV,Y            ; Get device pointer
                    os9       I$Detach            ; Detach to compensate for IOMAN Attach
                    puls      U

*   Decrement use count

                    dec       PD.CNT,Y            ;Decrement use count

*   Give back unwanted PD

*** This is the way I did it originally
                    pshs      X
                    lda       PD.PD,Y             ;Get system path number
                    ldx       <D.PthDBT           ;Point at path table index
                    os9       F$Ret64             ; and give back descriptor
                    puls      X
*** This is the way the OSK named pipe manager does it.
*** I had to translate, of course, but the translated
*** version doesn't work right.
*        pshs    U,X
*        lda     PD.PD,Y         ;Get system path #
*        ldx     <D.PthDBT       ;Point at path table index
*        ldu     <D.SysDis       ;Point at system SVC dispatch table
*        jsr     [(F$Ret64*2),U] ;Do a RET64
*        puls    X,U

*   Stack clean.
*   Update IOMAN variables.
*   Reg-Y = where IOMAN thinks the PD is.

                    ifeq      (CAUTION-CAREFUL)
                    cmpy      (14+IOMAGIC),S      ;Make sure the stack looks right (PD matches)
                    beq       OKMagic

*   Stack is wrong; declare bad magic!

                    comb
                    ldb       #E$Bug
                    leas      14,S
                    rts
                    endc

*   Stack is right; go fix PD pointers

OKMagic             ldy       PP.PD,X             ;Get PD pointer of existing named pipe PD.
                    sty       10,S                ;Point PD pointer at existing PD
                    sty       (14+IOMAGIC),S      ;Save new IOMAN PD pointer in IOMAN stack
                    inc       PD.CNT,Y            ;Increment use count

*   End of dangerous code
*   This section MUST have preserved Reg-X and Reg-U

*   Exit code.
*
*   Reg-U points to driver static storage.
*   Reg-Y points to PD.
*   Reg-X points to matching pipe buffer.
*
*   Advance caller's path name pointer

OpnXit              equ       *

*   Fix use count based on PD.Keep

                    lda       PD.CNT,Y
                    suba      PD.Keep,Y
                    sta       PD.CNT,Y            ;Get rid of any artificial openings
                    clr       PD.Keep,Y

                    ifeq      (PIPEDIR-YESDIR)
*   Handle prefill of pipe directory buffer

                    lda       PD.Mod,Y            ;Is this a DIR. open?
                    bita      #DIR.
                    beq       OpnXt2

                    lbsr      FilDirP             ;Send directory info to pipe
                    endc

OpnXt2              ldu       12,S                ;Point at caller's registers
                    ldd       4,S                 ;Get revised path name pointer
                    std       R$X,U

                    leas      14,S                ;Clean the stack

*   Successful exit.  Reg-X points to pipe buffer.

                    clrb
                    rts

                    page
*
*   Compare pipe names.
*
*   Can't use F$CmpNam here because the strings
*   are in system space.
*
*   Path names are pointed to by Reg-X and Reg-Y.
*   Case is ignored.  Returns NE if not equal, else
*   EQ.
*

Compare             pshs      Y,X,A               ;Reg-A is temp. storage

*   Main comparison loop

Cmp001              lda       ,X+
                    anda      #%11011111          ;Cheap and fast TOUPPER
                    sta       0,S

                    lda       ,Y+
                    anda      #%11011111          ;Cheap and fast TOUPPER
                    bmi       Cmp.Y               ; (exit if we find end of Y-string)

                    cmpa      0,S
                    beq       Cmp001

*   Names don't match.  Return CC=NE

                    puls      A,X,Y,PC

*   End of "Y" string.  "X" character either matches or
*   it doesn't.  Return CC accordingly.

Cmp.Y               cmpa      0,S
                    puls      A,X,Y,PC

*
*   Convert element count in D to byte count in D.
*   Return carry set if too big.
*
*   Reg-Y = PD pointer
*   Reg-D = Element count
*

ECtoBC              pshs      D
                    lda       PD.ESiz,Y           ;Get size of each element
                    ldb       0,S                 ;Get MSB of element count
                    mul
                    pshs      D
                    lda       PD.ESiz,Y           ;Get size of each element
                    ldb       (2+1),S             ;Get LSB of element count
                    mul
                    adda      1,S                 ;C-bit set if too big
                    tst       ,S++                ;Z-bit clear if too big, C-bit OK
                    leas      2,S
                    bcs       EB.err
                    bne       EB.err

*   OK exit
                    andcc     #^Carry
                    rts

*   Error exit
EB.err              orcc      #Carry
                    rts

*   Get next character of path name.
*   Reg-Y set up as if just did a PRSNAM.

GtNext              ldx       <D.Proc
                    ldb       P$Task,X
                    tfr       Y,X
                    os9       F$LDABX
                    rts

                    page
*
*   Error hook
*
MAKDIR              equ       *
CHGDIR              equ       *
UNKNOWN             comb
                    ldb       #E$UNKSVC
                    rts

                    page
*
*   Close a pipe
*
*   If there are any other pipe users, leave the pipe
*   around.  Also, if the pipe is named and contains
*   any data, leave the pipe around even if there are
*   no remaining pipe users.
*
*   PD.Keep will be non-zero if the pipe has been kept
*   open artificially.
*
*   This routine is called each time a path to the pipe
*   is closed.
*

CLOSE               equ       *

*   Account for extra use count if pipe artificially kept open.
*   Then see if this is the last user of the pipe

                    lda       PD.Keep,Y           ;Account for extra pipe images
                    nega
                    clr       PD.Keep,Y
                    adda      PD.CNT,Y
                    sta       PD.CNT,Y            ;Set correct PD.CNT value
                    bne       READERS             ; and branch if any users left

*   No open paths to this pipe.
*   If it's named and not empty, leave it around anyway.

                    tst       PD.Name,Y           ;Named pipe?
                    beq       CLOSE2

                    ldd       PD.BCnt,Y           ;How many elements buffered on named pipe?
                    beq       CLOSE2

*   Leave this named pipe around for a while

                    inc       PD.CNT,Y            ;Create an extra image
                    inc       PD.Keep,Y           ; and remember that we did it
                    bra       CLOXIT

*   Delete the pipe.
*   Y = PD pointer.

CLOSE2              bsr       ZapPipe
                    bra       CloXit              ;No error

*   Open paths left.  What kind?

READERS             cmpa      PD.RCT,Y            ;Are all open paths readers?
                    bne       WRITERS

*   All other open paths are readers.
*   Send signal to next reader (let him read a bit)

                    leax      PD.Read,Y
                    bra       SENDSIG

*   Not all readers.  What kind?

WRITERS             cmpa      PD.WCT,Y            ;Are all open paths writers?
                    bne       CloXit

*   All other open paths are writers.
*   Send signal to next writer (let him write a bit)

                    leax      PD.Writ,Y

*   Send signal to next reader or writer

SENDSIG             lda       PM.CPR,X            ;Process ID to signal
                    beq       CLOXIT

                    ldb       PM.SIG,X            ;Signal code to send
                    beq       CLOXIT

*   Committed to send signal:  clear the flag and send it

                    clr       PM.SIG,X            ;Force no pending signal
                    os9       F$SEND

*   Done with close

CLOXIT              clrb
                    rts

                    page
*
*   Delete a named pipe.
*
*   Reg-Y = PD
*   Reg-U = caller's registers
*   Reg-X = path name
*

Delete              lda       #Read.
                    sta       PD.MOD,Y            ;Need only READ permission
                    pshs      U,Y,X,A             ;***Match stack set up by IOMAN
                    lbsr      Open                ;Try to open the pipe
                    puls      U,Y,X,A             ;***Clean up special stack
                    bcs       BadDel

*   Disconnect from pipe, but keep pointer.
*   Then check to see if we're the only user.
*
*   Note -- The call to OPEN updated PD.CNT
*   and cleared PD.Keep.

                    dec       PD.CNT,Y            ;Don't count ourselves
                    beq       DoDel               ;If count is zero, OK to delete

*   Pipe is in use.  Return E$FNA

FNAXIT              comb
                    ldb       #E$FNA

*   Exit w/ carry set and error code in B

BadDel              rts

*   Perform the delete.

DoDel               bsr       ZapPipe
                    clrb
                    rts

*
*   Return all memory for the pipe buffer specified
*   in the path descriptor, and remove it from the linked list.
*
*   Reg-Y = PD pointer
*   Pipe buffer pointer is at PD.BUF,Y
*

ZapPipe             ldu       PD.DEV,Y            ;Get device table pointer
                    ldu       V$Stat,U            ;Get static storage pointer

                    ldx       PD.BUF,Y            ;Point to pipe's buffer
                    ldd       PP.Next,X           ;Save pointer to current and next in list
                    pshs      D
                    ldd       PP.Prev,X           ;Save pointer to previous in list
                    pshs      D

*   Reg-D has pointer to previous.  If zero, we're zapping head of list.
*   Z-bit is already set accordingly

                    bne       OldHead

*   New head of list.
*   Reg-X still points to buffer to be deleted

                    ldd       2,S                 ;Get pointer to next (may be $0000)
                    std       V.List,U            ; and set as new head
                    pshs      X,D
                    ldx       0,S                 ;Point Reg-X at next, set CC
                    beq       Zap9
                    clr       (PP.Prev+0),X       ; and set no prev for next
                    clr       (PP.Prev+1),X
Zap9                puls      D,X                 ;Point back at pipe to delete
                    bra       ZapIt

*   No new head of list.  Just delete from linked list.
*   We know there is a previous buffer.
*
*   Reg-X points to buffer to be deleted.
*   Reg-D points to previous buffer.

OldHead             ldu       PP.Next,X           ;Get U pointing at our next (may be $0000)
                    exg       D,X                 ;Point X at our prev, D at us
                    stu       PP.Next,X           ;Save new next for out prev
                    beq       Zap8
                    stx       PP.Prev,U           ;Point our next's prev at our original prev
Zap8                exg       D,X

*   All cleaned up. Give back the buffer
*   Reg-X points to buffer, Reg-Y points to PD.

ZapIt               ldd       PD.End,Y
                    pshs      X
                    subd      0,S                 ;Get total bytes to Reg-D
                    puls      U                   ;Point at buffer, clean stack
                    os9       F$SRtMem

*   Exit with whatever error F$SRtMem produces

                    leas      4,S                 ;Clean stack
                    rts

                    page
*
*   Dummy hook
*
SEEK                equ       *
Dummy               clrb
                    rts

                    page
*
*   GETSTT processing
*
*   Supports the following codes:
*
*   SS.Opt          Option section
*   SS.Ready        # bytes in queue
*   SS.Siz          Size of queue
*   SS.EOF          Queue empty
*   SS.FD           Bogus file descriptor   (WIZBANG==MSGS)
*   SS.ScSiz        Screen Size
*
*   SS.Opt handled in IOMAN, etc.
*   SS.Ready code by Kent Meyers, modified by Chris Burke
*   SS.Siz, SS.EOF, SS.FD, SS.ScSiz by Chris Burke
*

GETSTT              lda       R$B,U               Get User B Register ++
                    cmpa      #SS.READY           Test for Ready Call ++
                    bne       NotSSRDY

*   Process SS.Rdy -- return # elements in queue
*   If more than 255, return 255.

G.Rdy               ldb       #255
                    tst       (PD.BCnt+0),Y
                    bne       G.Rdy0              ;Accomodate large queues (256 or more bytes)
                    ldb       (PD.BCnt+1),X       ;Get element count LSB

*   Reg-B has LSB of element count, CC set based on value

                    beq       RDNRDY              ;Not Ready if no characters

G.Rdy0              stb       R$B,U               ;Return count in B

SST.OK              equ       *
SST.Ign             equ       *

G.OK                clrb                          No Error ++
                    tfr       CC,A
                    sta       R$CC,U
                    rts                           Return ++

*   No characters for SS.Ready

RDNRDY              tst       PD.Wrtn,Y           Anybody writing to pipe?
                    bne       NOTEOF              (not OK if so)

*   No writer

                    ldb       PD.CNT,Y            Exactly one path open to pipe?
                    decb
                    bne       NOTEOF              (OK if no, e.g. nobody or > 1)

*   Internal error

IntErr              comb
                    ldb       #255
                    rts

NOTEOF              comb                          Set Error Flag ++
                    ldb       #E$NOTRDY           Get Error Code ++
                    rts                           Return ++

*   Not SS.Ready.  Check for SS.Siz

NotSSRdy            cmpa      #SS.Size            Test for Size call
                    bne       NotSSSiz

*   Process SS.Siz -- return size of queue in ELEMENTS.

G.Siz               ldd       PD.QSiz,Y           ;Get max. # of queue elements
                    std       R$U,U
                    clr       (R$X+0),U           Set 16 MSB's to $0000
                    clr       (R$X+1),U
GOK001              bra       G.OK

*   Not SS.Siz.  Check for SS.EOF

NotSSSiz            cmpa      #SS.EOF
                    bne       NotSSEOF

*   Process SS.EOF
*   Handle like SS.Rdy, but preserve Reg-B

G.EOF               bsr       G.Siz
                    ldb       #0                  ;NOT clrb -- preserve carry
                    stb       R$B,U
                    bcc       G.OK                ;No error if ready

                    ldb       #E$EOF              ;Carry is already set
                    rts

*   Not SS.EOF.  Check for SS.FD

                    ifeq      (PIPEDIR-YESDIR)
NotSSEOF            cmpa      #SS.FD
                    bne       NotSSFD

*   Process SS.FD

                    lbsr      DoSSFD
                    bra       G.OK                ;Successful always
                    else
NotSSEOF            equ       *
                    endc

*   Not SS.FD.  Check for SS.ScSiz

NotSSFD             cmpa      #SS.ScSiz           ;Force UNKNOWN here
                    lbeq      UnKnown

NotSCSZ             equ       *

NotSSAT             equ       *

*   Process unknown GETSTT

*        lbra    UNKNOWN
                    bra       G.OK
*        bra     NotEOF

                    page
*
*   SETSTT processing
*
*   Supports the following codes:
*
*   SS.Opt          Option section
*   SS.Siz          No effect unless size=0; then clears pipe buffer
*   SS.FD           No effect
*   SS.SSig         Set signal on data available
*   SS.Relea        Release signal
*
*   SS.Opt handled in IOMAN, etc.
*   SS.Siz, SS.SSig, SS.Relea by Chris Burke, modified
*   from OSK.
*

SetStt              lda       R$B,U               Get User B Register ++
                    cmpa      #SS.Opt
                    beq       SST.Ign             ; (ignore)
                    cmpa      #SS.FD
                    beq       SST.Ign

*   Check for SS.SIZ

                    cmpa      #SS.Size
                    bne       NoS.Siz

                    ldd       R$U,U               ;Get caller's size
                    bne       SST.Ign

*   Clear the pipe

                    ldx       PD.Buf,Y
                    leau      PP.Data,X
                    stu       PD.NxtI,Y
                    stu       PD.NxtO,Y
                    clr       (PD.BCnt+0),Y
                    clr       (PD.BCnt+1),Y
                    clr       PD.RFlg,Y
                    clr       PD.Wrtn,Y

QST.OK              bra       SST.OK

*   Check for SS.SSig

NoS.Siz             cmpa      #SS.SSig
                    bne       NoS.Sig

                    leax      PD.Read,Y           ;Point at read packet
                    tst       PM.Cpr,X            ;Error if already somebody waiting
                    bne       NOTEOF

*   Set signal trap

                    lda       PD.CPR,Y            ;Set process ID
                    sta       PM.CPR,X
                    lda       (R$X+1),U           ;Get signal code
                    sta       PM.Sig,X
                    tst       PD.BCnt,Y           ;Immediate signal if
                    lbne      SendSig

                    bra       QST.OK

*   Check for release of signal

NoS.Sig             cmpa      #SS.Relea
                    bne       NoS.Rel

                    leax      PD.Read,Y           ;Point at read packet
                    lda       PM.CPR,X
                    cmpa      PD.CPR,Y            ;Our process set it?
                    bne       QST.OK

*   Release signal trap

                    clrb
                    lbra      Switch

*   Not SS.Relea.  Check for SS.Attr

NoS.Rel             cmpa      #SS.Attr
                    bne       NoS.Atr

*   Change attributes if allowed

                    ldx       <D.Proc
                    lda       P$ID,X              ;Are we superuser?
                    beq       SAT.OK
                    tst       PD.Own,Y            ;Is creator still attached?
                    bne       SAT.XX

                    sta       PD.Own,Y            ;Inherit pipe if owner abandoned it

SAT.XX              cmpa      PD.Own,Y
                    lbne      FNAXit              ;If can't match PID, E$FNA error

*   Change attributes.
*   Reg-U points at caller's registers

SAT.OK              lda       R$A,U
                    ora       #(READ.+WRITE.)     ;We insist . . .
                    sta       PD.MOD,Y
                    bra       QST.OK

*   Unknown SETSTT

NoS.Atr             lbra      Unknown

                    page
*
*   Read CR-terminated line or element count from
*   pipe with no editing.  Note that this call is
*   not well defined for element sizes other than
*   1 byte.
*

READLN              ldb       PD.ESiz,Y
                    decb
                    bne       RddEOF              ;EOF error if more than 1 byte per element

                    ldb       #CR
                    stb       PD.REOR,Y
                    bra       READ001

*
*   Read element count from pipe with no editing.
*
*   Note that if there are fewer elements in the pipe
*   than the user wants to read, and there are no writers
*   for the pipe, we return all elements followed by E$EOF.
*

READ                clr       PD.REOR,Y

*   Generic read.  PD.REOR = terminator if non-null

READ001             leax      PD.Read,Y           ;Get PID of reader (us)
                    lbsr      GETFREE
                    bcs       RddRTS

                    ldd       R$Y,U               ;Desired element count
                    beq       RddXit

*   Set up for outer loop -- push zero element count
*   and space for buffer pointers on stack.

                    clra
                    clrb
                    pshs      D                   ;Initial count of elements read
                    leas      -4,S
                    ldx       R$X,U               ;Initial buffer start address
                    bra       RddNext

*   Enter here to block on read.  If there are no writers,
*   return E$EOF.

CantRdd             pshs      X                   ;Save buffer pointer

                    leax      PD.Read,Y
                    lbsr      SigSlp
                    lbcs      RddDone

*   Inner loop to read bytes.
*   Here for initial attempt to read,
*   or to retry after blocking

READOK              ldx       <D.PROC             ;Point to our task descriptor
                    ldb       P$TASK,X            ++LII
                    puls      X                   ++LII Recover current buffer pointer

*   Inner read loop.  Read one element.
*   Note that we could use F$Move for elements larger
*   than 1 byte, because queue size is always an even
*   multiple of element size.

RddMore             lbsr      DOREAD              ;Get byte to A, or CS
                    bcs       CantRdd

                    os9       F$STABX             ;Put byte in caller's buffer
                    leax      1,X
                    tst       PD.REOR,Y           ;Is there an EOR character?
                    beq       NotRdLn

                    cmpa      PD.REOR,Y           ;Did we match it?
                    beq       RddEOL

NotRdLn             cmpx      0,S                 ;Compare current addr. to end addr
                    blo       RddMore             ; and loop until done

*   Done with element.  Check for next.

                    pshs      X                   ;Save buffer pointer

                    bsr       CntDn               ;Update queue count, etc
                    cmpd      R$Y,U               ;Got all elements?
                    bhs       RddTail

*   Outer loop -- read one element at a time.
*
*   X = next data pointer
*   Y = PD pointer

RddNext             stx       0,S                 ;Set new start address
                    ldb       PD.ESiz,Y           ;Size of one element
                    clra
                    addd      0,S                 ;Compute end address of current element bfr
                    std       2,S
                    bra       READOK              ;Go to element reading loop

*   Read an EOL.  Advance element count

RddEOL              pshs      X                   ;Save buffer pointer
                    bsr       CntDn

*   Read everything, or aborting

RddDone             ldd       4,S                 ;Get element count

*   Tail end of read

RddTail             std       R$Y,U
                    leas      6,S                 ;Clean stack
                    bne       RddSome             ;Success if read more than 0 elements

*   EOF error if no bytes read

RddEOF              comb
                    ldb       #E$EOF
                    bra       RddXit

*   Successful exit

RddSome             clrb

RddXit              leax      PD.Read,Y
                    lbra      SWITCH

*   Decrement queued count, inc read count

CntDn               ldd       #-1
                    bra       CUpDn

*   Increment queued count, inc written count

CntUp               ldd       #1

CUpDn               addd      PD.BCnt,Y           ;Modify count of elements queued
                    std       PD.BCnt,Y

*   Bump I/O count

IOCnt               ldd       (2+4),S             ;Bump count of elements read/written
                    addd      #1
                    std       (2+4),S
RDDRTS              rts

                    page
*
*   Write CR-terminated line or element count to
*   pipe with no editing
*

WRITELN             ldb       PD.ESiz,Y
                    decb
                    bne       RddEOF              ;EOF error if more than 1 byte per element

                    ldb       #CR
                    stb       PD.WEOR,Y
                    bra       Wrt001

*
*   Write byte count to pipe with no editing.
*

WRITE               clr       PD.WEOR,Y

*   Generic entry point

Wrt001              leax      PD.Writ,Y
                    lbsr      GETFREE             ;Check I/O queue
                    bcs       WrtXit

                    ldd       R$Y,U               ;Element count
                    beq       WrtXit

*   Set up for outer loop -- push zero element count
*   and space for buffer pointers on stack.

                    clra
                    clrb
                    pshs      D                   ;Initial count of elements read
                    leas      -4,S
                    ldx       R$X,U               ;Initial buffer start address
                    bra       WrtNext

*   Enter here to block on write

CantWrt             pshs      X

                    leax      PD.Writ,Y
                    lbsr      SigSlp
                    bcs       WrtErr

*   Begin (or resume) write

WRITOK              ldx       <D.PROC             ++LII
                    ldb       P$TASK,X            ;Get our DAT image #
                    puls      X                   ++LII

*   Main write loop

WrtMore             os9       F$LDABX             ;Get a byte from caller's buffer
                    lbsr      DOWRITE
                    bcs       CantWrt

                    leax      1,X
                    tst       PD.WEOR,Y           ;EOL character defined?
                    beq       NotWrLn

                    cmpa      PD.WEOR,Y
                    beq       WrtEOL

*   See if at end of buffer

NotWrLn             cmpx      0,S
                    blo       WrtMore

*   Done with element.  Check for next.

                    pshs      X                   ;Save buffer pointer

                    bsr       CntUp
                    cmpd      R$Y,U               ;Put all elements?
                    bhs       WrtTail

*   Outer loop -- write one element at a time.

WrtNext             stx       0,S                 ;Set new start address
                    ldb       PD.ESiz,Y           ;Size of one element
                    clra
                    addd      0,S                 ;Compute end address of current element bfr
                    std       2,S
                    bra       WRITOK              ;Go to element reading loop

*   Wrote an EOL.  Advance element count

WrtEOL              pshs      X                   ;Save buffer pointer
                    bsr       CntUp

*   Wrote everything, or aborting

WrtDone             ldd       4,S                 ;Get element count

*   Tail end of write

WrtTail             std       R$Y,U
                    leas      6,S                 ;Clean stack

*   Successful exit

WrtSome             clrb

WrtXit              leax      PD.Writ,Y
                    bra       SWITCH

*   Error exit

WrtErr              pshs      B
                    ldd       (4+1),S
                    std       R$Y,U
                    puls      B

                    leas      6,S
                    bra       WrtXit

                    page
*
*   I/O queue manipulation routines
*

GETFREE             lda       PM.CPR,X            ;Is any process using this resource?
                    beq       SETPMCPR            ; (branch if not)

                    cmpa      PD.CPR,Y            ;Does caller control this resource?
                    beq       OURDEVIC            ; (branch if so)

                    inc       PM.CNT,X            ;Bump # of active r/w images
                    ldb       PM.CNT,X
                    cmpb      PD.CNT,Y            ;See if equal to # of open images
                    bne       SETQUEUE            ; (if not, run everybody else to free it)

                    lbsr      SENDSIG             ;Yes -- wake up next process

*   Process number in Reg-A
*   Put the process into the I/O queue and
*   sleep until a signal wakes us up

SETQUEUE            os9       F$IOQU
                    dec       PM.CNT,X            ;Caller is asleep, so 1 less active
                    pshs      X
                    ldx       <D.PROC
                    ldb       P$SIGNAL,X          ;Get caller's signal
                    puls      X
                    beq       GETFREE             ;Loop until there's a signal

                    coma                          ;Error if caller is waiting
                    rts

*   Nobody using the resource.  Grab it.

SETPMCPR            ldb       PD.CPR,Y
                    stb       PM.CPR,X            ;Make caller "owner"

*   Exit -- caller owns the pipe

OURDEVIC            clrb
                    rts

*
*   Set a wakeup signal for the calling process
*

SigSlp              ldb       PM.CNT,X            ;Active image count
                    incb
                    cmpb      PD.CNT,Y            ;Everybody active?
                    bne       SgSlp01             ; (if not, try sending signals)

*   Nobody on the other end to signal.
*   Error if anonymous, else hang out a bit.

                    tst       PD.Name,Y           ;If anonymous pipe & nobody left, error
                    beq       WRITEROR

*   Named pipe and nobody to signal.  Not an error if data in pipe.

                    tst       PD.BCnt,Y           ;Number of items in pipe
                    beq       WRITEROR

*   Send signal to other end of pipe (may not be one, though)

SgSlp01             stb       PM.CNT,X
                    ldb       #S$WAKE
                    stb       PM.SIG,X            ;Force caller's signal to "wakeup"
                    clr       PD.CPR,Y
                    pshs      X
                    tfr       X,D                 ;Switch from reader to writer or vis-a-vis
                    eorb      #4
                    tfr       D,X
                    lbsr      SENDSIG             ;Send signal to opposite end of pipe
                    ldx       #0
                    os9       F$SLEEP             ;Caller sleeps until signaled
                    ldx       <D.PROC
                    ldb       P$SIGNAL,X
                    puls      X
                    dec       PM.CNT,X            ;Caller is asleep, so 1 less active
                    tstb
                    bne       GOTSIGNL            ;Error if opposite end set no signal

                    clrb
                    rts

*   WRITE ERROR hook

WRITEROR            ldb       #E$WRITE

*   Generic error hook

GOTSIGNL            coma
                    rts

*
*   Release this end of the pipe, and
*   send a signal to the other end.
*
*   Enter pointing to variables for
*   this end; exit pointing to variables
*   for opposite end.
*

SWITCH              pshs      CC,B,U
                    clr       PM.CPR,X            ;No process controlling current end
                    tfr       X,D
                    eorb      #4                  ;Switch to other end (MAGIC)
                    tfr       D,X
                    lbsr      SENDSIG             ;Awaken other end
                    puls      CC,B,U,PC

*
*   Write one byte to queue described in path
*   descriptor.  Return CS if queue full.
*   Doesn't update count of ELEMENTS queued.
*

DOWRITE             pshs      B,X
                    ldx       PD.NxtI,Y
                    ldb       PD.RFlg,Y
                    beq       SETREADY            ;(say data available)

                    cmpx      PD.NxtO,Y
                    bne       STORDATA            ;(branch if queue not full)

*   Error -- queue is full

                    comb
                    puls      B,X,PC

*   Mark data available in queue

SETREADY            ldb       #1
                    stb       PD.RFlg,Y

*   Put data in Reg-A into queue, and advance
*   pointer to next in w/ wrap

STORDATA            sta       ,X+
                    cmpx      PD.End,Y
                    blo       WTNOWRAP

                    ldx       PD.BUF,Y
                    leax      PP.Data,X

WTNOWRAP            stx       PD.NxtI,Y

* Don't step Character Input Counter.

                    clr       PD.Wrtn,Y
                    puls      B,X,PC

*
*   Read one byte from queue described in path
*   descriptor.  Return CS if none available.
*   Doesn't update count of ELEMENTS queued.
*

DOREAD              lda       PD.RFlg,Y           ;Any data?
                    bne       DATAREDY

*   No data -- return CS

                    comb
                    rts

*   Get data from queue

DATAREDY            pshs      X
                    ldx       PD.NxtO,Y           ;Get next out pointer
                    lda       ,X+
                    cmpx      PD.End,Y
                    blo       RDNOWRAP

                    ldx       PD.BUF,Y
                    leax      PP.Data,X

*   Save updated next out pointer

RDNOWRAP            stx       PD.NxtO,Y
                    cmpx      PD.NxtI,Y
                    bne       NOTEMPTY

                    clr       PD.RFlg,Y           ;Mark queue empty

*   Don't decrement Character Input Counter.

NOTEMPTY            equ       *

*   Exit with character in Reg-A

                    andcc     #^Carry             ;Clear carry
                    puls      X,PC

                    page
*
*   Utility placed here to not make assembly listing obsolete.
*

MovSet              os9       F$Move              ;Do inter-process block move

*   Force set MSB at end of name

                    tfr       Y,D                 ;Byte count to D
                    decb
                    lda       B,U                 ;Get last byte of name
                    ora       #%10000000
                    sta       B,U

                    rts

                    ifeq      (PIPEDIR-YESDIR)

*
*   Find out how many pipes there are for the
*   current device, and set up device descriptor
*   so that pipe buffer will hold 32 bytes of
*   data for each.
*
*   Reg-Y = PD pointer
*
*   Exit with size set up in PD.
*   CC=EQ if no pipes.
*

SizDirP             pshs      X,D

                    clrb                          ;Clear count of pipes
                    ldx       PD.Dev,Y
                    ldx       V$Stat,X            ;Point at static storage
                    ldx       V.List,X            ;Get head of linked list
                    beq       GotCnt

*   There are some pipes.  Count them.

PCount              incb
                    ldx       PP.Next,X           ;Track down linked list
                    bne       PCount

*   Now Reg-B = pipe count.  Need 32 bytes per pipe.

GotCnt              incb                          ;Add one for us!
                    lda       #32
                    mul
                    std       PD.QSiz,Y           ;Set element count for this pipe
                    lda       #1
                    sta       PD.ESiz,Y           ;Set element size to 1 byte

                    puls      D,X,PC

*
*   Fill pipe buffer with directory data.
*
*   The data is organized like an RBF directory:
*
*   Offset      Data
*   --------    --------------------------------
*   $00-$1C     Pipe name
*   $1D         DAT task number of pipe buffer
*   $1E-$1F     Address of pipe buffer in task
*
*
FilDirP             pshs      U,X,D

                    ldx       PD.Dev,Y
                    ldx       V$Stat,X            ;Point at static storage
                    ldx       V.List,X            ;Get head of linked list
                    beq       GotFil

*   Write data for pipe buffer @X to pipe with PD @Y

FD000               ldu       PP.PD,X             ;Point at PD for pipe to be dumped
                    leau      PD.Name,u
                    ldb       #NameMax

FD001               lda       ,u+                 ;Write pipe name
                    bsr       QWrite
                    decb
                    bne       FD001

                    ldu       <D.SysPrc           ;Get system DAT image number
                    lda       P$Task,u
                    bsr       QWrite

                    pshs      X                   ;Get pipe buffer pointer
                    lda       ,S+
                    bsr       QWrite
                    lda       ,S+
                    bsr       QWrite

*   Advance to next pipe buffer

                    ldx       PP.Next,X
                    bne       FD000

*   All done.  Restore regs & exit

GotFil              puls      D,X,U,PC

*   Byte saver

QWrite              lbra      DoWrite

*
*   Immortal entry point
*
Immort              coma
                    sbcb      #38
                    lsrb
                    fcb       $42                 ;SBCB op-code

*   Fall through to SS.FD processing

*
*   Routine to process SS.FD call on an open pipe.
*   Creates a pseudo-FD in the user's buffer (@R$X).
*   Desired byte count in R$Y.
*
*   The pseudo-file descriptor sector includes the following:
*
*   Offset      Description
*   --------    --------------------------------------
*   $00         Attributes
*   $01-$02     Owner's *PROCESS* ID
*   $03-$07     Zeros (date of last access)
*   $08         Use count
*   $09-$0C     Number of items queued
*   $0D-$0F     Zeros (creation date)
*   $10-$FF     Zeros (segment list -- at least 5 zeros needed)
*

DoSSFD              pshs      D,X,Y,U

                    ldb       #(16+5)             ;Clear data on stack
SSFD01              clr       ,-S
                    decb
                    bne       SSFD01

*   Set attributes
                    lda       PD.Mod,Y
                    sta       FD.ATT,S

*   Set owner's process ID
                    lda       PD.Own,Y
                    sta       (FD.OWN+1),S

*   Set use count
                    lda       PD.CNT,Y
                    sta       FD.LNK,S

*   Set queue count

                    ldd       PD.BCNT,Y
                    std       (FD.SIZ+2),S

*   Now copy the data into the caller's buffer

                    ldx       <D.SysPrc           ;Pointer to our PD
                    lda       P$Task,X            ; get system's DAT image # (source)
                    ldx       <D.Proc             ;Pointer to caller's PD
                    ldb       P$Task,X            ; get caller's DAT image # (dest)
                    ldy       R$Y,U               ;Byte count
                    leax      0,S                 ;Source address
                    ldu       R$X,U               ;Destination address
                    os9       F$Move              ;Do the move

*   All done.

                    leas      (16+5),S
                    puls      U,X,Y,D,PC

                    endc

                    emod

MODSIZE             equ       *

                    end

