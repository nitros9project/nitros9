********************************************************************
* SCF - NitrOS-9 Sequential Character File Manager
*
* This contains an added SetStat call to allow placing prearranged data
* into the keyboard buffer of ANY SCF related device.
*
* Usage:
*
* Entry: X = Pointer to the string
*        Y = Length of the string
*        A = Path number
*        B = SS.Fill ($A0) (syscall SETSTAT function call number)
* NOTE: If high bit of Y is set, no carriage return will be appended to
*       the read buffer (used in Shellplus V2.2 history)
*
* This also includes Kevin Darlings SCF Editor patches.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          1993/04/20  ???
* V1.09:
* - Speeded up L05CC (write char to device) routine by a few cycles
* - Slightly optimized Insert char.
* - Move branch table so Read & ReadLn are 1 cycle faster each; fixed
*   SS.Fill so size is truncated @ 256 bytes.
* - Added NO CR option to SS.Fill (for use with modified Shellplus V2.2
*   command history).
*
*          1993/04/21  ???
* Slight speedup to some of ReadLn parsing, TFM's in Open/Close.
* - More optimization to read/write driver calls
* - Got rid of branch table @ L05E3 for speed
*
*          1993/05/21  ???
* V1.10:
* Added Boisy Pitre's patch for non-sharable devices.
* - Saved 4 cycles in routine @ L042B
* - Modified Boisy's routine to not pshs/puls B (saves 2 cycles).
* - Changed buffer prefill of CR's to save 1 byte.
*
*          1993/07/27  ???
* V1.11:
* Changed a BRA to a LBRA to a straight LBRA in L0322.
* - Optimized path option character routine @ L032C
*
*          1993/08/03  ???
* Modified vector table @ L033F to save 1 cycle on PD.PSC
* - Sped up uppercase conversion checks for ReadLn & WritLn
* - Changed 2 BRA's to L02F9 to do an LBRA straight to L05F8 (ReadLn loop)
* - Moved L0565 routine so Reprint line, Insert & Delete char (on ReadLn)
*   are 1 cycle faster / char printed
* - Changed 2 references to L0420 to go straight to L0565
* - Sped up ReadLn loop by 2 or 3 cycles per char read
*
*          1993/09/21  ???
* V1.12:
* Sped up L0435 by 1 or 2 cycles (depending on branch)
* - Changed LDD ,S to TFR X,D (saves 1 cycle) @ L04F1 (Write & WritLn)
* - Modified L04F1 to use W without TFR (+1 byte, -3 cycles) (Write)
*
*          1993/11/09  ???
* Took LDX #0/LDU PD.BUF,y from L03B5 & merged in @ L028A, L02EF & L0381.
* Also changed BEQ @ L03A5 to skip re-loading X with 0.
*
*          1993/11/10  ???
* Moved L04B2 routine to allow a couple of BSR's instead of LBSR's In READ.
* - Moved driver call right into READ loop (should save 25 cycles/char read)
* - Moved driver call right into L0565 (should save 12 cycles/char written on echo,
*   line editing, etc.)
*
*          1993/11/26  ???
* Moved L02FE (ReadLn parsing) to end where ReadLn routine is moved L03E2
* so Read loop would be optimized for it (read char from driver) instead of
* L042B (write filled buffer to caller).
* Changed LDA #C$NULL to CLRA.
*
*          1993/12/01  ???
* Modified device write call (L056F) to preserve Y as well, to cut down on
* PSHS/PULS.
* - Changed L03E2 & L03DA to exit immediately if PD.DEV or PD.DV2 (depending
* on which routine) is empty (eliminated redundant LEAX ,X).
*
*          1994/05/31  ???
* Attempted mode to L03F1 to eliminate LDW #D$READ, changed:
*      LDX V$DRIV,x
*      ADDW M$Exec,x
*      JSR w,x
* to:
*      LDW V$DRIV,x
*      ADDW M$Exec,w
*      JSR D$READ,w
* Did same to L05C9 & L056F (should speed up each by 1 cycle)
*
*          1994/06/07  ???
* Attempted to modify all M$Exec calls to use new V$DRIVEX (REQUIRES NEW IOMAN)
* - L01FA (Get/SetStat), L03F1 (Read), L05C9 (Write), L056F (Write)
* - Changed L046A to use LDB V.BUSY,x...CMPB ,s...TFR B,A
*
*          1994/06/08  ???
* Changed TST <PD.EKO,y in read loop (L02BC) to LDB PD.EKO,y
* - Changed LEAX 1,X to LDB #1/ABX @ L02C4
* - Changed LEAX >L033F,pc @ L032C to use < (8 bit) version
* - Modified L02E5 to use D instead of X, allowing TSTA, and faster exit on 0 byte
*   just BRAnching to L0453
*
*          1994/06/09  ???
* Changed LEAX 1,X to LDB #1/ABX @ L053D, L05F8, L0312, L0351, L03B8
* - Changed to L0573: All TST's changed to LDB's
* - Changed Open/Create init to use LEAX,PC instead of BSR/PULS X
* - Changed TST PD.CNT,y to LDA PD.CNT,y @ close
* - Eliminated L010D, changed references to it to go to L0129
* - Eliminated useless LEAX ,X @ L0182, and changed BEQ @ L0182 to go to L012A
*   instead of L0129 (speeds CLOSE by 5 or 10 cycles)
* - Moved L06B9 into L012B, eliminate BSR/RTS, plus
* - Changed TST V.TYPE,x to LDB V.TYPE,x
* - Moved L0624 to just before L05F8 to eliminate BRA L05F8 (ReadLn)
* - Changed TST PD.EKO,y @ L0413 to LDB PD.EKO,y
* - Moved L0413-L0423 routines to later in code to allow short branches
* - As result of above, changed 6 LBxx to Bxx
* - Changed TST PD.MIN,y @ L04BB to LDA PD.MIN,y
* - Changed TST PD.RAW,y/TST PD.UPC,y @ L0523 to LDB's
* - Changed TST PD.ALF,y @ L052A to LDB
* - L053D: Moved TST PD.RAW,y to before LDA -1,u to speed up WRITE, changed it to LDB
*
*          1994/06/10  ???
* Changed TST PD.ALF,y to LDB @ L052A
* - Changed CLR V.WAKE,u to CLRA/STA V.WAKE,u @ L03F1 (Read)
* - Changed CLR V.BUSY,u to CLRA/STA V.BUSY,u @ L045D
* - Changed CLR PD.MIN,y to CLRA/STA PD.MIN,y, moved before LDA P$ID,x @ L04A7
* - Changed CLR PD.RAW,y @ L04BB to STA PD.RAW, since A already 0 to get there
* - Changed CLR V.PAUS,u to CLRA/STA V.PAUS,u @ L05A2
* - Changed TST PD.RAW,y to LDA PD.RAW,y @ L05A2
* - Changed TST PD.ALF,y to LDA PD.ALF,y @ L05A2
* - Changed CLR V.WAKE,u to CLRB/STB V.WAKE,u @ L05C9
* - Changed CLR V.WAKE,u to CLRB/STB V.WAKE,u @ L056F
* - Changed TST PD.UPC,y to LDB PD.UPC,y @ L0322
* - Changed TST PD.DLO,y/TST PD.EKO,y to LDB's @ L03A5
*
*          1994/06/16  ???
* Changed TST PD.UPC,y to LDB PD.UPC,y @ L0322
* - Changed TST PD.BSO,y to LDB PD.BSO,y @ L03BF
* - Changed TST PD.EKO,y to LDB PD.EKO,y @ L03BF
*
*          2002/10/11  Boisy G. Pitre
* Merged NitrOS-9 and TuneUp versions for single-source maintenance.  Note that
* the 6809 version of TuneUp never seemed to call GrfDrv directly to do fast screen
* writes (see note around g.done label).
*
*  16r2    2002/05/16  Boisy G. Pitre
* Removed pshs/puls of b from sharable code segment for non-NitrOS-9 because it was
* not needed.
*
*  16r3    2002/08/16  Boisy G. Pitre
* Now uses V$DRIVEX.
*
*  16r4    2004/07/12  Boisy G. Pitre
* 6809 version now calls the FAST TEXT entry point of GrfDrv.
*
*  17      2010/01/15  Boisy G. Pitre
* Fix for bug described in Artifact 2932883 on SF
* Also added Level 1 conditionals for eventual backporting

*
*  17      2010/01/15  Boisy G. Pitre
* Handling of device exclusivity using the SHARE. bit has been rearchitected.
* The '93 patch looked at the mode bytes in the descriptor and driver and
* determined that if both were set, then only one path would be allowed to
* be opened on the device at a time.
* I now believe this is wrong.
* The mode bytes in the device driver and descriptor are capability bytes.
* They advertise what the device is capable of doing (READ, WRITE, etc) so
* the mode bytes alone do not convey action, but merely what is possible.
* When the user calls I$Open on a device, he passes the desired mode byte
* in RegA and IOMan checks to make sure that all bits in that register are
* set in the mode bytes of the driver and descriptor.  So once we get into
* the Open call of this file manager, we know that all set bits in RegA are
* also set in the mode bytes of the driver and descriptor.
*
* For SHARE., what we SHOULD be doing is checking the number of open paths
* on the device.  If the SHARE. bit is set in RegA, then we check if a path
* is already open and if so, return the E$DevBsy error.
* Likewise, if SHARE. is not set in RegA, we check the path at the head of
* the open path list, and if ITS mode byte has the SHARE. bit set, we exit
* with E$DevBsy too.  The idea is that if the SHARE. bit is set on the newly
* opened path or an existing path, then there can "be only one."
*
*  18      2010/01/23  Boisy G. Pitre
* SCF has successfully been backported to NitrOS-9 Level 1.
* SCF now returns on carry set after calling SS.Open.  Prior to this
* change, SS.ComSt would be called right after SS.Open even if SS.Open
* failed. This caused misery with the scdwn driver wildcard feature.
*
* EOU Version 1.0.0
*          2022/08/01  LCB
* slight optimization in ReadLn chars when echo is turned on & a control
* code other than CR was received. Saves 2 bytes/3 cyc for that case (other
* chars no change. (L0418)
* 2 lbsr's changed to bsr's (both CPU's) - bsr L0403 in g.loop & bsr L0565 in L0634
*
*          2026/07/11  Codex
* Annotated source and normalized comments.

                    nam       SCF       ; set module name to SCF
                    ttl       NitrOS-9 Sequential Character File Manager ; set assembly title

                    use       defsfile  ; include defsfile definitions
                    use       scf.d     ; include scf.d definitions
                  IFGT    Level-1 ; assemble following block when Level-1 is true
                    use       cocovtio.d ; include cocovtio.d definitions
                  ENDC    ;       end conditional assembly block

tylg                set       FlMgr+Objct ; define assembly-time symbol tylg
atrv                set       ReEnt+rev ; define assembly-time symbol atrv
rev                 set       0         ; define assembly-time symbol rev
edition             equ       18        ; define constant edition

                    mod       eom,SCFName,tylg,atrv,SCFEnt,0 ; emit OS-9 module header

SCFName             fcs       /SCF/                      ; store compressed string /SCF/
                    fcb       edition   ; store byte value edition

* Default input buffer setting for SCF devices when Opened/Created
*               123456789!123456789!1234567890
*msg      fcc   'by B.Nobel,C.Boyle,W.Gale-1993'
msg                 fcc       'www.nitros9.org'          ; store character string 'www.nitros9.org'
msgsize             equ       *-msg     ; size of default input buffer message
                    fcb       C$CR      ; 2nd CR for buffer pad fill
blksize             equ       256-msgsize ; size of blank space after it

* Return bad pathname error
opbpnam             puls      y         ; restore y from stack
bpnam               comb                ; set carry for error
                    ldb       #E$BPNam  ; get error code
oerr                rts                 ; return to caller

* I$Create/I$Open entry point
* Entry: Y= Path dsc. ptr
open                ldx       PD.DEV,y  ; get device table pointer
                    stx       PD.TBL,y  ; save it
                    ldu       PD.RGS,y  ; get callers register stack pointer
                    pshs      y         ; save path descriptor pointer
                    ldx       R$X,u     ; get pointer to device pathname
                    os9       F$PrsNam  ; parse it
                    bcs       opbpnam   ; error, exit
                    tsta                ; end of pathname?
                    bmi       open1     ; yes, go on
                    leax      ,y        ; point to actual device name
                    os9       F$PrsNam  ; parse it again
                    bcc       opbpnam   ; return to caller with bad path name if more
open1               sty       R$X,u     ; save updated name pointer to caller
                    puls      y         ; restore path descriptor pointer
                    ldd       #256      ; get size of input buffer in bytes
                    os9       F$SRqMem  ; allocate it
                    bcs       oerr      ; can't allocate it return with error
                    stu       PD.BUF,y  ; save buffer address to path descriptor
                    leax      <msg,pc   ; get ptr to init string
                  IFNE    H6309   ; assemble following block when H6309 is true
                    ldw       #msgsize  ; get size of default message
                    tfm       x+,u+     ; copy it into buffer (leaves X pointing to 2nd CR)
                    ldw       #blksize  ; size of rest of buffer
                    tfm       x,u+      ; fill rest of buffer with CR's
                  ELSE    ;       select alternate assembly branch
CopyMsg             lda       ,x+       ; load a from ,x+
                    sta       ,u+       ; store a into ,u+
                    decb                ; decrement b counter
                    cmpa      #C$CR     ; compare a with #C$CR
                    bne       CopyMsg   ; branch if comparison was not equal to CopyMsg
CopyCR              sta       ,u+       ; store a into ,u+
                    decb                ; decrement b counter
                    bne       CopyCR    ; branch if comparison was not equal to CopyCR
                  ENDC    ;       end conditional assembly block
                    ldu       PD.DEV,y  ; get device table entry address
                    beq       bpnam     ; doesn't exist, exit with bad pathname error
                    ldx       V$STAT,u  ; get devices' static storage address
                    lda       PD.PAG,y  ; get devices page length
                    sta       V.LINE,x  ; save it to devices static storage
                    ldx       V$DESC,u  ; get descriptor address
                    ldd       PD.D2P,y  ; get offset to device name (duplicate from dev dsc)
                    beq       L00CF     ; none, skip ahead
                  IFNE    H6309   ; assemble following block when H6309 is true
                    addr      d,x       ; point to device name in descriptor
                    lda       PD.MOD,y  ; get device mode (Read/Write/Update)
                    lsrd                ; ??? (swap Read/Write bits around in A?)
                  ELSE    ;       select alternate assembly branch
                    leax      d,x       ; compute address d,x into x
                    lda       PD.MOD,y  ; get device mode (Read/Write/Update)
                    lsra                ; shift a right one bit
                    rorb                ; continue SCF file-manager flow
                  ENDC    ;       end conditional assembly block
                    lsra                ; shift a right one bit
                    rolb                ; continue SCF file-manager flow
                    rola                ; continue SCF file-manager flow
                    rorb                ; continue SCF file-manager flow
                    rola                ; continue SCF file-manager flow
                  IFGT    Level-1 ; assemble following block when Level-1 is true
                    pshs      y         ; save path descriptor pointer temporarily
                    ldy       <D.Proc   ; get current process pointer
                    ldu       <D.SysPrc ; get system process descriptor pointer
                    stu       <D.Proc   ; make system current process
                  ENDC    ;       end conditional assembly block
                    os9       I$Attach  ; attempt to attach to device name in device desc.
                  IFGT    Level-1 ; assemble following block when Level-1 is true
                    sty       <D.Proc   ; restore old current process pointer
                    puls      y         ; restore path descriptor pointer
                  ENDC    ;       end conditional assembly block
                    bcs       OpenErr   ; couldn't attach to device, detach & exit with error
                    stu       PD.DV2,y  ; save new output (echo) device table pointer
*         ldu   PD.DEV,y     Get device table pointer
L00CF               ldu       V$STAT,u  ; point to it's static storage
                  IFNE    H6309   ; assemble following block when H6309 is true
                    clrd                ; clear d to zero
                  ELSE    ;       select alternate assembly branch
                    clra                ; clear a and carry state for success/zero value
                    clrb                ; clear b and carry state for success/zero value
                  ENDC    ;       end conditional assembly block
                    std       PD.PLP,y  ; clear out path descriptor list pointer
                    sta       PD.PST,y  ; clear path status: Carrier not lost
                    pshs      d         ; save 0 on stack
                    ldx       V.PDLHd,u ; get path descriptor list header pointer
* 05/25/93 mod - Boisy Pitre's non-sharable device patches
* 01/15/10 mod - Boisy Pitre redoes his non-sharable device patch
                    beq       Yespath   ; no paths open, so we know we can open it
* IOMan has already vetted the mode byte of the driver and the descriptor
* and compared it to REGA of I$Open (now in PD.MOD of this current path).
* here we know there is at least one path open for this device.
* in order to properly support SHARE. (device exclusivity), we get the
* mode byte for the path we are opening and see if the SHARE. bit is set.
* if so, then we return error since we cannot have exclusivity to the device.
                  IFNE    H6309   ; assemble following block when H6309 is true
                    tim       #SHARE.,PD.MOD,y ; test memory bits at #SHARE.,PD.MOD,y
                  ELSE    ;       select alternate assembly branch
                    lda       PD.MOD,y  ; load a from PD.MOD,y
                    bita      #SHARE.   ; test a bits against #SHARE.
                  ENDC    ;       end conditional assembly block
                    bne       NoShare   ; branch if comparison was not equal to NoShare
* we now know that the path's mode doesn't have the SHARE. bit set, so
* we need to look at the mode of the path in the list header pointer to
* see if ITS SHARE. bit is set (meaning it wants exclusive access to the
* port).  If so we bail out
                  IFNE    H6309   ; assemble following block when H6309 is true
                    tim       #SHARE.,PD.MOD,x ; test memory bits at #SHARE.,PD.MOD,x
                  ELSE    ;       select alternate assembly branch
                    lda       PD.MOD,x  ; load a from PD.MOD,x
                    bita      #SHARE.   ; test a bits against #SHARE.
                  ENDC    ;       end conditional assembly block
                    beq       CkCar     ; check carrier status
NoShare             leas      2,s       ; eat extra stack (including good path count)
                    comb                ; complement b to set carry for error return
                    ldb       #E$DevBsy ; non-sharable device busy error
                    bra       OpenErr   ; go detach device & exit with error

Yespath             sty       V.PDLHd,u ; save path descriptor ptr
                    bra       L00F8     ; go open the path

L00E6               tfr       d,x       ; change to PD.PLP path descriptor
CkCar               ldb       PD.PST,x  ; get Carrier status
                    bne       L00EF     ; carrier was lost, don't update count
                    inc       1,s       ; carrier not lost, bump up count of good paths
L00EF               ldd       PD.PLP,x  ; get path descriptor list pointer
                    bne       L00E6     ; there is one, go make it the current one
                    sty       PD.PLP,x  ; save path descriptor ptr as path dsc. list ptr
L00F8               lda       #SS.Open  ; internal open call
                    pshs      a         ; save it on the stack
                    inc       2,s       ; bump counter of good paths up by 1
                    lbsr      L025B     ; do the SS.Open call to the driver
                    lda       2,s       ; get counter of good paths
                    leas      3,s       ; eat stack
* NEW: return with error if SS.Open return error
                    bcs       L010F     ; +++BGP+++
                    deca                ; bump down good path count
                    bne       L0129     ; if more still open, exit without error
                    blo       L010F     ; if negative, something went wrong
                    lbra      L0250     ; set parity/baud & return

* we come here if there was an error in Open (after I$Attach and F$SRqMem!)
L010F               bsr       RemoveFromPDList ; error, go clear stuff out
OpenErr             pshs      b,cc      ; preserve error status
                    bsr       L0136     ; detach device
                    puls      pc,b,cc   ; restore error status & return

* I$Close entry point
close               pshs      cc        ; preserve interrupt status
                    orcc      #IntMasks ; disable interrupts
                    ldx       PD.DEV,y  ; get device table pointer
                    bsr       L0182     ; check it
                    ldx       PD.DV2,y  ; get output device table pointer
                    bsr       L0182     ; check it
                    puls      cc        ; restore interrupts
                    lda       PD.CNT,y  ; any open images?
                    beq       L012B     ; no, go on
L0129               clra                ; clear carry
L012A               rts                 ; return

* Detach device & return buffer memory
L012B               bsr       RemoveFromPDList ; unlink this path descriptor from the device list
                    lda       #SS.Close ; get setstat code for close
                    ldx       PD.DEV,y  ; get pointer to device table
                    ldx       V$STAT,x  ; get static mem ptr
                    ldb       V.TYPE,x  ; get device type    \ WON'T THIS SCREW UP WITH
                    bmi       L0136     ; window, skip ahead / MARK OR SPACE PARITY???
                    pshs      x,a       ; save close code & X for SS.Close calling routine
                    lbsr      L025B     ; not window, go call driver's SS.Close routine
                    leas      3,s       ; purge stack
L0136               ldu       PD.DV2,y  ; get output device pointer
                    beq       L013D     ; nothing there, go on
                    os9       I$Detach  ; detach it
L013D               ldu       PD.BUF,y  ; get buffer pointer
                    beq       L0147     ; none defined go on
                    ldd       #256      ; get buffer size
                    os9       F$SRtMem  ; return buffer memory to system
L0147               clra                ; clear carry
                    rts                 ; return

* Remove path descriptor from device path descriptor linked list
* Entry: Y = path descriptor
RemoveFromPDList
                    ldx       #1        ; load x from #1
                    pshs      cc,d,x,y,u ; save cc,d,x,y,u on stack
                    ldu       PD.DEV,y  ; get device table pointer
                    beq       L017B     ; none, skip ahead
                    ldu       V$STAT,u  ; get static storage pointer
                    beq       L017B     ; none, skip ahead
                    ldx       V.PDLHd,u ; get path descriptor list header
                    beq       L017B     ; none, skip ahead
                    ldd       PD.PLP,y  ; get path descriptor list pointer
                    cmpy      V.PDLHd,u ; is the passed path descriptor the same?
                    bne       L0172     ; branch if not
                    std       V.PDLHd,u ; store d into V.PDLHd,u
                    bne       L017B     ; branch if comparison was not equal to L017B
                    clr       4,s       ; clear LSB of X on stack
                    bra       L017B     ; return

* D = path descriptor to store
L016D               ldx       PD.PLP,x  ; advance to next path descriptor in list
                    beq       L0180     ; branch if at end of linked list
L0172               cmpy      PD.PLP,x  ; is the passed path descriptor the same?
                    bne       L016D     ; branch if not
                    std       PD.PLP,x  ; store
                  IFNE    H6309   ; assemble following block when H6309 is true
L017B               clrd                ; clear d to zero
                  ELSE    ;       select alternate assembly branch
L017B               clra                ; clear a and carry state for success/zero value
                    clrb                ; clear b and carry state for success/zero value
                  ENDC    ;       end conditional assembly block
                    std       PD.PLP,y  ; store d into PD.PLP,y
L0180               puls      cc,d,x,y,u,pc ; restore cc,d,x,y,u,pc and return


* Check path number?
* Entry: X=Ptr to device table (just LDX'd)
*        Y=Path dsc. ptr
L0182               beq       L012A     ; no device table, return to caller
                    ldx       V$STAT,x  ; get static storage pointer
                    ldb       PD.PD,y   ; get system path number from path dsc.
                    lda       PD.CPR,y  ; get ID # of process currently using path
                    pshs      d,x,y     ; save everything
                    cmpa      V.LPRC,x  ; current process same as last process using path?
                    bne       L01CA     ; no, return
                  IFGT    Level-1 ; assemble following block when Level-1 is true
                    ldx       <D.Proc   ; get current process pointer
                  ELSE    ;       select alternate assembly branch
                    ldx       >D.Proc   ; get current process pointer
                  ENDC    ;       end conditional assembly block
                    leax      P$Path,x  ; point to local path table
                    clra                ; start path # = 0 (Std In)
L0198               cmpb      a,x       ; same path as one is process' local path list?
                    beq       L01CA     ; yes, return
                    inca                ; move to next path
                    cmpa      #NumPaths ; done all paths?
                    blo       L0198     ; no, keep going
                    pshs      y         ; preserve path descriptor pointer
                  IFNE    H6309   ; assemble following block when H6309 is true
                    lda       #SS.Relea ; release signals SetStat
                    ldf       #D$PSTA   ; get Setstat offset
                  ELSE    ;       select alternate assembly branch
                    ldd       #SS.Relea*256+D$PSTA ; load d from #SS.Relea*256+D$PSTA
                  ENDC    ;       end conditional assembly block
                    bsr       L01FA     ; execute driver setstat routine
                    puls      y         ; restore path pointer
                  IFGT    Level-1 ; assemble following block when Level-1 is true
                    ldx       <D.Proc   ; get current process pointer
                  ELSE    ;       select alternate assembly branch
                    ldx       >D.Proc   ; get current process pointer
                  ENDC    ;       end conditional assembly block
                    lda       P$PID,x   ; get parent process ID
                    sta       ,s        ; save it
                  IFGT    Level-1 ; assemble following block when Level-1 is true
                    os9       F$GProcP  ; get pointer to parent process descriptor
                  ELSE    ;       select alternate assembly branch
                    ldx       <D.PrcDBT ; load x from <D.PrcDBT
                    os9       F$Find64  ; call OS-9 service F$Find64
                  ENDC    ;       end conditional assembly block
                    leax      P$Path,y  ; point to local path table
                    ldb       1,s       ; get path number
                    clra                ; get starting path number
L01B9               cmpb      a,x       ; same path?
                    beq       L01C4     ; yes, go on
                    inca                ; move to next path
                    cmpa      #NumPaths ; done all paths?
                    blo       L01B9     ; no, keep checking
                    clr       ,s        ; clear process ID
L01C4               lda       ,s        ; get process ID
                    ldx       2,s       ; get static storage pointer
                    sta       V.LPRC,x  ; store it as last process
L01CA               puls      d,x,y,pc  ; restore & return

* I$GetStt entry point
getstt              lda       PD.PST,y  ; path status ok?
                    lbne      L04C6     ; no, terminate process
                    ldx       PD.RGS,y  ; get register stack pointer
                    lda       R$B,x     ; get function code
                    bne       L01F8     ; if not SS.Opt, call driver with function code
* ($00) SS.Opt Getstat - All of PD.OPT is already set up, *except* parity/baud, so we need to grab that
                    pshs      a,x,y     ; preserve registers (LCB: why X? SS.ComSt doesn't use X)
                    lda       #SS.ComSt ; get code for Comstat
                    sta       R$B,x     ; save it in callers B
                    ldu       R$Y,x     ; preserve callers Y
                    pshs      u         ; save u on stack
                    bsr       L01F8     ; call SS.ComSt GetStat in driver (puts parity/baud into callers Y)
                    puls      u         ; restore callers Y
                    puls      a,x,y     ; restore registers
                    sta       R$B,x     ; save SS.Opt code back into caller's B
                    ldd       R$Y,x     ; get com stat (baud/parity)
                    stu       R$Y,x     ; put original callers Y back
                    bcs       L01F6     ; return if error
                    std       PD.PAR,y  ; update path descriptor with baud/parity
L01F6               clrb                ; clear carry
L01F7               rts                 ; return

* Execute device driver Get/Set Status routine
* Entry: A=GetStat/SetStat code
*        Y=path descriptor ptr
                  IFNE    H6309   ; assemble following block when H6309 is true
L01F8               ldf       #D$GSTA   ; get Getstat driver entry offset
L01FA               ldx       PD.DEV,y  ; get device table pointer
                    ldu       V$STAT,x  ; get static storage pointer
                  IFGT    Level-1 ; assemble following block when Level-1 is true
                    ldx       V$DRIVEX,x ; get execution pointer of driver
                  ELSE    ;       select alternate assembly branch
                    pshs      d         ; save d on stack
                    ldx       V$DRIV,x  ; get driver module
                    ldd       M$EXEC,x  ; point to entry point in driver
                    leax      d,x       ; compute address d,x into x
                    puls      d         ; restore d from stack
                  ENDC    ;       end conditional assembly block
                    pshs      y,u       ; preserve registers
                    jsr       f,x       ; execute driver
                    puls      y,u,pc    ; restore & return
                  ELSE    ;       select alternate assembly branch
L01F8               ldb       #D$GSTA   ; load b from #D$GSTA
L01FA               ldx       PD.DEV,y  ; load x from PD.DEV,y
                    ldu       V$STAT,x  ; load u from V$STAT,x
                  IFGT    Level-1 ; assemble following block when Level-1 is true
                    ldx       V$DRIVEX,x ; load x from V$DRIVEX,x
                  ELSE    ;       select alternate assembly branch
                    pshs      d         ; save d on stack
                    ldx       V$DRIV,x  ; get driver module
                    ldd       M$EXEC,x  ; load d from M$EXEC,x
                    leax      d,x       ; compute address d,x into x
                    puls      d         ; restore d from stack
                  ENDC    ;       end conditional assembly block
                    pshs      u,y       ; save u,y on stack
LC486               jsr       b,x       ; call subroutine at b,x
                    puls      y,u,pc    ; restore y,u,pc and return
                  ENDC    ;       end conditional assembly block

* I$SetStt entry point
setstt              lbsr      L04A2     ; call distant local routine L04A2
L0212               bsr       L021B     ; check codes
                    pshs      cc,b      ; preserve registers
                    lbsr      L0453     ; wait for device
                    puls      cc,b,pc   ; restore & return

putkey              cmpa      #SS.Fill  ; buffer preload?
                    bne       L01FA     ; no, go execute driver setstat
                    pshs      u,y,x     ; save u,y,x on stack
                  IFGT    Level-1 ; assemble following block when Level-1 is true
                    ldx       <D.Proc   ; get current process pointer
                  ELSE    ;       select alternate assembly branch
                    ldx       >D.Proc   ; get current process pointer
                  ENDC    ;       end conditional assembly block
                    lda       R$Y,u     ; get flag byte for CR/NO CR
                    pshs      a         ; save it
                  IFGT    Level-1 ; assemble following block when Level-1 is true
                    lda       P$Task,x  ; get task number
                    ldb       <D.SysTsk ; get system task
                  IFNE    H6309   ; assemble following block when H6309 is true
                    ldx       R$X,u     ; get pointer to data to move
                    ldf       R$Y+1,u   ; get number of bytes (max size of 256 bytes)
                    ldu       PD.BUF,y  ; get input buffer pointer
                    clre                ; high byte of Y
                    tfr       w,y       ; move size into proper register for F$Move
                  ELSE    ;       select alternate assembly branch
                    pshs      d         ; save d on stack
                    clra                ; clear a and carry state for success/zero value
                    ldb       R$Y+1,u   ; load b from R$Y+1,u
                    ldx       R$X,u     ; load x from R$X,u
                    ldu       PD.BUF,y  ; load u from PD.BUF,y
                    tfr       d,y       ; transfer d,y
                    puls      d         ; restore d from stack
                  ENDC    ;       end conditional assembly block
* X=Source ptr from caller, Y=# bytes to move, U=Input buffer ptr
                    os9       F$Move    ; move it
                    bcs       putkey1   ; exit if error
                    tfr       y,d       ; move number of bytes to D
                  ELSE    ;       select alternate assembly branch
loop                lda       ,x+       ; load a from ,x+
                    sta       ,u+       ; store a into ,u+
                    leay      -1,y      ; compute address -1,y into y
                    bne       loop      ; branch if comparison was not equal to loop
                  ENDC    ;       end conditional assembly block
                    lda       ,s        ; get CR flag
                    bmi       putkey1   ; don't want CR appended, exit
                    lda       #C$CR     ; get code for carriage return
                    sta       b,u       ; put it in buffer to terminate string
putkey1             puls      a,x,y,u,pc ; eat stack & return

                  IFNE    H6309   ; assemble following block when H6309 is true
L021B               ldf       #D$PSTA   ; get driver entry offset for setstat
                  ELSE    ;       select alternate assembly branch
L021B               ldb       #D$PSTA   ; get driver entry offset for setstat
                  ENDC    ;       end conditional assembly block
                    lda       R$B,u     ; get function code from caller
                    bne       putkey    ; not SS.OPT, go check buffer load
* SS.OPT SETSTAT
                    ldx       PD.PAU,y  ; get current pause & page
                  IFGT    Level-1 ; assemble following block when Level-1 is true
                    pshs      y,x       ; preserve Path pointer & pause/page
                    ldx       <D.Proc   ; get current process pointer
                    lda       P$Task,x  ; get task number
                    ldb       <D.SysTsk ; get system task number
                    ldx       R$X,u     ; get callers destination pointer
                    leau      PD.OPT,y  ; point to path options
                    ldy       #OPTCNT   ; get option length
                    os9       F$Move    ; move it to caller
                    puls      y,x       ; restore Path pointer & page/pause status
                    bcs       L01F7     ; return if error from move
                  ELSE    ;       select alternate assembly branch
                    pshs      x,y       ; save x,y on stack
                    ldx       R$X,u     ; load x from R$X,u
                    leay      PD.OPT,y  ; compute address PD.OPT,y into y
                    ldb       #OPTCNT   ; load b from #OPTCNT
optloop             lda       ,x+       ; load a from ,x+
                    sta       ,y+       ; store a into ,y+
                    decb                ; decrement b counter
                    bne       optloop   ; branch if comparison was not equal to optloop
                    puls      x,y       ; restore x,y from stack
                  ENDC    ;       end conditional assembly block
                  IFEQ    H6309   ; assemble following block when H6309 is true
                    pshs      x         ; save x on stack
                  ENDC    ;       end conditional assembly block
                    ldd       PD.PAU,y  ; get new page/pause status
                  IFNE    H6309   ; assemble following block when H6309 is true
                    cmpr      d,x       ; same as old?
                  ELSE    ;       select alternate assembly branch
                    cmpd      ,s++      ; compare d with ,s++
                  ENDC    ;       end conditional assembly block
                    beq       L0250     ; yes, go on
                    ldu       PD.DEV,y  ; get device table pointer
                    ldu       V$STAT,u  ; get static storage pointer
                    beq       L0250     ; go on if none
                    stb       V.LINE,u  ; update new line count
L0250               ldx       PD.PAR,y  ; get parity/baud
                    lda       #SS.ComSt ; get code for ComSt
                    pshs      a,x       ; preserve them
                    bsr       L025B     ; update parity & baud
                    puls      a,x,pc    ; restore & return

* Update path Parity & baud
L025B               pshs      x,y,u     ; preserve everything
                    ldx       PD.RGS,y  ; get callers register pointer
                    ldu       R$Y,x     ; get his Y
                    lda       R$B,x     ; get his B
                    pshs      a,x,y,u   ; preserve it all
                    ldd       $10,s     ; get current parity/baud
                    std       R$Y,x     ; put it in callers Y
                    lda       $0F,s     ; get function code
                    sta       R$B,x     ; put it in callers B
                    lbsr      L04A7     ; wait for device to be ready
                    lbsr      L0212     ; send it to driver
                    puls      a,x,y,u   ; restore callers registers
                    stu       R$Y,x     ; put back his Y
                    sta       R$B,x     ; put back his B
                    bcc       L0282     ; return if no error
                    cmpb      #E$UnkSvc ; unknown service request?
                    beq       L0282     ; yes, return
                    coma                ; set carry
L0282               puls      x,y,u,pc  ; restore & return

* I$Read entry point
read                lbsr      L04A2     ; go wait for device to be ready for us
                    bcc       L028A     ; no error, go on
L0289               rts                 ; return with error

L028A               inc       PD.RAW,y  ; make sure we do Raw read
                    ldx       R$Y,u     ; get number of characters to read
                    beq       L02DC     ; return if zero
                    pshs      x         ; save character count
                    ldx       #0        ; load x from #0
                    ldu       PD.BUF,y  ; get buffer address
                    bsr       L03E2     ; read 1 character from device
                    bcs       L02A4     ; return if error
                    tsta                ; character read zero?
                    beq       L02C4     ; yes, go try again
                    cmpa      PD.EOF,y  ; end of file character?
                    bne       L02BC     ; no, keep checking
L02A2               ldb       #E$EOF    ; get EOF error code
L02A4               leas      2,s       ; purge stack
                    pshs      b         ; save error code
                    bsr       L02D5     ; return
                    comb                ; set carry
                    puls      b,pc      ; restore & return

******************************
*
* SCF file manager entry point
*
* Entry: Y = Path descriptor pointer
*        U = Callers register stack pointer
*

SCFEnt              lbra      open      ; create path
                    lbra      open      ; open path
                    lbra      bpnam     ; makdir
                    lbra      bpnam     ; chgdir
                    lbra      L0129     ; delete (return no error)
                    lbra      L0129     ; seek (return no error)
                    bra       read      ; read character
                    nop
                    lbra      write     ; write character
                    lbra      readln    ; readLn
                    lbra      writln    ; writeLn
                    lbra      getstt    ; get Status
                    lbra      setstt    ; set Status
                    lbra      close     ; close path

* MAIN READ LOOP (no editing)
L02AD               tfr       x,d       ; move character count to D
                    tstb                ; past buffer end?
                    bne       L02B7     ; no, go get character from device
* Not often used: only when buffer is full
                    bsr       L042B     ; move buffer to caller's buffer
                    ldu       PD.BUF,y  ; reset buffer pointer back to start
* Main char by char read loop
L02B7               bsr       L03E2     ; get a character from device
                    bcs       L02A4     ; exit if error
L02BC               ldb       PD.EKO,y  ; echo turned on?
                    beq       L02C4     ; no, don't write it to device
                    lbsr      L0565     ; send it to device write
L02C4               ldb       #1        ; bump up char count
                    abx                 ; add b to x for indexed byte advance
                    sta       ,u+       ; save character in local buffer
                    beq       L02CF     ; go try again if it was a null
                    cmpa      PD.EOR,y  ; end of record charcter?
                    beq       L02D3     ; yes, return
L02CF               cmpx      ,s        ; done read?
                    blo       L02AD     ; no, keep going till we are

L02D3               leas      2,s       ; purge stack
L02D5               bsr       L042B     ; move local buffer to caller
                    ldu       PD.RGS,y  ; get register stack pointer
                    stx       R$Y,u     ; save number of characters read
L02DC               bra       L0453     ; update path descriptor and return

* Read character from device
L03E2               pshs      u,y,x     ; preserve regs
                    ldx       PD.DEV,y  ; get device table pointer for input
                    beq       L0401     ; none, exit
                    ldu       PD.DV2,y  ; get device table pointer for echoed output
                    beq       L03F1     ; no echoed output device, skip ahead
L03EA               ldu       V$STAT,u  ; get device static storage ptr for echo device
                    ldb       PD.PAG,y  ; get lines per page
                    stb       V.LINE,u  ; store it in device static
L03F1               tfr       u,d       ; yes, move echo device' static storage to D
                    ldu       V$STAT,x  ; get static storage ptr for input
                    std       V.DEV2,u  ; save echo device's static storage into input device
                    clra                ; clear a and carry state for success/zero value
                    sta       V.WAKE,u  ; flag input device to be awake
                  IFGT    Level-1 ; assemble following block when Level-1 is true
                    ldx       V$DRIVEX,x ; get driver execution pointer
                  ELSE    ;       select alternate assembly branch
                    pshs      d         ; save d on stack
                    ldx       V$DRIV,x  ; get driver module
                    ldd       M$EXEC,x  ; get driver execution pointer
                    leax      d,x       ; compute address d,x into x
                    puls      d         ; restore d from stack
                  ENDC    ;       end conditional assembly block
                    jsr       D$READ,x  ; execute READ routine in driver
L0401               puls      pc,u,y,x  ; restore regs & return

* Move buffer to caller
* Entry: Y=Path dsc. ptr
*        X=# chars to move
L042B               pshs      y,x       ; preserve path dsc. ptr & char. count
                    ldd       ,s        ; get # bytes to move
                    beq       L0451     ; exit if none
                    tstb                ; uneven # bytes (not even page of 256)?
                    bne       L0435     ; yes, go on
                    deca                ; >256, so bump MSB down
L0435               clrb                ; force to even page
                    ldu       PD.RGS,y  ; get callers register stack pointer
                    ldu       R$X,u     ; get ptr to caller's buffer
                  IFNE    H6309   ; assemble following block when H6309 is true
                    addr      d,u       ; offset to even page into buffer
                    clre                ; clear MSB of count
                    ldf       1,s       ; lSB of count on even page?
                    bne       L0442     ; no, go on
                    ince                ; make it even 256
L0442
                  IFGT    Level-1 ; assemble following block when Level-1 is true
                    lda       <D.SysTsk ; get source task number
                  ENDC    ;       end conditional assembly block
                  ELSE    ;       select alternate assembly branch
                    leau      d,u       ; compute address d,u into u
                    clra                ; clear a and carry state for success/zero value
                    ldb       1,s       ; load b from 1,s
                    bne       L0442     ; no, go on
                    inca                ; advance a counter
L0442               pshs      d         ; save d on stack
                  IFGT    Level-1 ; assemble following block when Level-1 is true
                    lda       <D.SysTsk ; get source task number
                  ENDC    ;       end conditional assembly block
                  ENDC    ;       end conditional assembly block
                  IFGT    Level-1 ; assemble following block when Level-1 is true
                    ldx       <D.Proc   ; get destination task number
                    ldb       P$Task,x  ; load b from P$Task,x
                    ldx       PD.BUF,y  ; get buffer pointer
                  IFNE    H6309   ; assemble following block when H6309 is true
                    tfr       w,y       ; put count into proper register
                  ELSE    ;       select alternate assembly branch
                    puls      y         ; restore y from stack
                  ENDC    ;       end conditional assembly block
                    os9       F$Move    ; move it to caller
                  ELSE    ;       select alternate assembly branch
                    ldx       PD.BUF,y  ; get buffer pointer
                  IFEQ    H6309   ; assemble following block when H6309 is true
                    puls      y         ; restore y from stack
                  ELSE    ;       select alternate assembly branch
                    tfr       w,y       ; transfer w,y
                  ENDC    ;       end conditional assembly block
                    pshs      u         ; save u on stack
L0443               lda       ,x+       ; load a from ,x+
                    sta       ,u+       ; store a into ,u+
                    leay      -1,y      ; compute address -1,y into y
                    bne       L0443     ; branch if comparison was not equal to L0443
                    puls      u         ; restore u from stack
                  ENDC    ;       end conditional assembly block
L0451               puls      pc,y,x    ; restore & return

* I$ReadLn entry point
readln              bsr       L04A2     ; go wait for device to be ready for us
                    bcc       L02E5     ; no error, continue
                    rts                 ; error, exit with it

L02E5               ldd       R$Y,u     ; get character count
                    beq       L0453     ; if none, mark device as un-busy
                    tsta                ; past 256 bytes?
                    beq       L02EF     ; no, go on
                    ldd       #$0100    ; get new character count
L02EF               pshs      d         ; save character count
                    ldd       #$FFFF    ; get maximum character count
                    std       PD.MAX,y  ; store it in path descriptor
                    ldx       #0        ; set character count so far to 0
                    ldu       PD.BUF,y  ; get buffer ptr
                    lbra      L05F8     ; go process readln

* Wait for device - Clears out V.BUSY if either Default or output devices are
* no longer busy
* Modifies X and A
L0453
                  IFGT    Level-1 ; assemble following block when Level-1 is true
                    ldx       <D.Proc   ; get current process
                  ELSE    ;       select alternate assembly branch
                    ldx       >D.Proc   ; get current process
                  ENDC    ;       end conditional assembly block
                    lda       P$ID,x    ; get it's process ID
                    ldx       PD.DEV,y  ; get device table pointer from our path dsc.
                    bsr       L045D     ; check if it's busy
                    ldx       PD.DV2,y  ; get output device table pointer
L045D               beq       L0467     ; doesn't exist, exit
                    ldx       V$STAT,x  ; get static storage pointer for our device
                    cmpa      V.BUSY,x  ; same process as current process?
                    bne       L0467     ; no, device busy return
                    clra                ; clear a and carry state for success/zero value
                    sta       V.BUSY,x  ; yes, mark device as free for use
L0467               rts                 ; return

L0468               pshs      x,a       ; preserve device table entry pointer & process ID
L046A               ldx       V$STAT,x  ; get device static storage address
                    ldb       V.BUSY,x  ; get active process ID
                    beq       L048A     ; no active process, device not busy go reserve it
                    cmpb      ,s        ; is it our own process?
                    beq       L049F     ; yes, return without error
                    bsr       L0453     ; go wait for device to no longer be busy
                    tfr       b,a       ; get process # busy using device
                    os9       F$IOQu    ; put our process into the IO Queue
                    inc       PD.MIN,y  ; mark device as not mine
                  IFGT    Level-1 ; assemble following block when Level-1 is true
                    ldx       <D.Proc   ; get current process
                  ELSE    ;       select alternate assembly branch
                    ldx       >D.Proc   ; get current process
                  ENDC    ;       end conditional assembly block
                    ldb       P$Signal,x ; get signal code
                    lda       ,s        ; get our process id # again for L046A
                    beq       L046A     ; no signal go try again
                    coma                ; set carry
                    puls      x,a,pc    ; restore device table ptr (eat a) & return

* Mark device as busy;copy pause/interrupt/quit/xon/xoff chars into static mem
L048A               sta       V.BUSY,x  ; make it as process # busy on this device
                    sta       V.LPRC,x  ; save it as the last process to use device
                    lda       PD.PSC,y  ; get pause character from path dsc.
                    sta       V.PCHR,x  ; save copy in static storage (faster later)
                    ldd       PD.INT,y  ; get keyboard interrupt & quit chars
                    std       V.INTR,x  ; save copies in static mem
                    ldd       PD.XON,y  ; get XON/XOFF chars
                    std       V.XON,x   ; save them in static mem too
L049F               clra                ; no error & return
                    puls      pc,x,a    ; restore A=Process #,X=Dev table entry ptr

* Wait for device?
L04A2               lda       PD.PST,y  ; get path status (carrier)
                    bne       L04C4     ; if carrier was lost, hang up process
L04A7
                  IFGT    Level-1 ; assemble following block when Level-1 is true
                    ldx       <D.Proc   ; get current process ID
                  ELSE    ;       select alternate assembly branch
                    ldx       >D.Proc   ; get current process ID
                  ENDC    ;       end conditional assembly block
                    clra                ; clear a and carry state for success/zero value
                    sta       PD.MIN,y  ; flag device is mine
                    lda       P$ID,x    ; get process ID #
                    ldx       PD.DEV,y  ; get device table pointer
                    bsr       L0468     ; busy?
                    bcs       L04C1     ; no, return
                    ldx       PD.DV2,y  ; get output device table pointer
                    beq       L04BB     ; go on if it doesn't exist
                    bsr       L0468     ; busy?
                    bcs       L04C1     ; no, return
L04BB               lda       PD.MIN,y  ; device mine?
                    bne       L04A2     ; no, go wait for it
                    sta       PD.RAW,y  ; mark device with editing
L04C1               ldu       PD.RGS,y  ; get register stack pointer
                    rts                 ; return

* Hangup process
L04C4               leas      2,s       ; purge return address
L04C6               ldb       #E$HangUp ; get hangup error code
                    cmpa      #S$Abort  ; termination signal (or carrier lost)?
                    blo       L04D3     ; yes, increment status flag & return
                    lda       PD.CPR,y  ; get current process ID # using path
                    ldb       #S$Kill   ; get kill signal
                    os9       F$Send    ; send it to process
L04D3               inc       PD.PST,y  ; set path status
                    orcc      #Carry    ; set carry
                    rts                 ; return

* I$WritLn entry point
writln              bsr       L04A2     ; go wait for device to be ready for us
                    bra       L04E1     ; go write

* I$Write entry point
write               bsr       L04A2     ; go wait for device to be ready for us
                    inc       PD.RAW,y  ; mark device for raw write
L04E1               ldx       R$Y,u     ; get number of characters to write
                    lbeq      L055A     ; zero so return
                    pshs      x         ; save character count
                    ldx       #$0000    ; get write data offset
                    bra       L04F1     ; go write data

L04EC               tfr       u,d       ; move current position in PD.BUF to D
                    tstb                ; at 256 (end of PD.BUF)?
                    bne       L0523     ; no, keep writing from current PD.BUF

* Get new block of data to write into [PD.BUF]
* Only allows up to 32 bytes at a time, and puts them in the last 32 bytes of
* the 256 byte [PD.BUF] buffer. This way, can use TFR U,D/TSTB to see if fin-
* ished.
* NOTE: 32 bytes max for 6809, to keep "lockout" of grfdrv down to less CPU time
L04F1               pshs      y,x       ; save write offset & path descriptor pointer
                    tfr       x,d       ; move data offset to D
                    ldu       PD.RGS,y  ; get register stack pointer
                    ldx       R$X,u     ; get pointer to user's WRITE string
                  IFNE    H6309   ; assemble following block when H6309 is true
                    addr      d,x       ; point to where we are in it now
                    ldw       R$Y,u     ; get # chars of original write
                    subr      d,w       ; calculate # chars we have left to write
                    cmpw      #64       ; more than 64?
                    bls       L0508     ; no, go on
                    ldw       #64       ; max size per chunk 6309=64
L0508               ldd       PD.BUF,y  ; get buffer ptr
                    inca                ; point to PD.BUF+256 (1 byte past end
                    subr      w,d       ; subtract data size
                  ELSE    ;       select alternate assembly branch
                    leax      d,x       ; point to where we are in it now
                    ldd       R$Y,u     ; get # chars of original write
                    subd      ,s        ; calculate # chars we have left to write
                    cmpd      #32       ; more than 32?
                    bls       L0508     ; no, go on
                    ldd       #32       ; max size per chunk 6809=32
L0508               pshs      d         ; save buffered chunk size on stack
                    ldd       PD.BUF,y  ; get buffer ptr
                    inca                ; point to PD.BUF+256 (1 byte past end)
                    subd      ,s        ; subtract data size
                  ENDC    ;       end conditional assembly block
                    tfr       d,u       ; move it to U
                    lda       #C$CR     ; put a carriage return 1 byte before start
                    sta       -1,u      ; of write portion of buffer
                  IFGT    Level-1 ; assemble following block when Level-1 is true
                    ldy       <D.Proc   ; get current process pointer
                    lda       P$Task,y  ; get the task number
                    ldb       <D.SysTsk ; get system task number
                  IFNE    H6309   ; assemble following block when H6309 is true
                    tfr       w,y       ; get number of bytes to move
                  ELSE    ;       select alternate assembly branch
                    puls      y         ; restore y from stack
                  ENDC    ;       end conditional assembly block
                    os9       F$Move    ; move data to buffer
                  ELSE    ;       select alternate assembly branch
                  IFNE    H6309   ; assemble following block when H6309 is true
                    pshs      u         ; move data to buffer (level 1)
                    tfm       x+,u+     ; transfer memory block x+,u+
                    puls      u         ; restore u from stack
                  ELSE    ;       select alternate assembly branch
                    puls      y         ; move data to buffer (level 1)
                    pshs      u         ; save u on stack
L0509               lda       ,x+       ; load a from ,x+
                    sta       ,u+       ; store a into ,u+
                    leay      -1,y      ; compute address -1,y into y
                    bne       L0509     ; branch if comparison was not equal to L0509
                    puls      u         ; restore u from stack
                  ENDC    ;       end conditional assembly block
                  ENDC    ;       end conditional assembly block
                    puls      y,x       ; restore path descriptor pointer and data offset

* at this point, we have
* 0,s = end address of characters to write
* X = number of characters written
* Y = PD pointer
* U = pointer to data buffer to write
* Level 2: Use callcode $06 to call grfdrv (old DWProtSW from previous versions,
*   now unused by GrfDrv
L0523
                  IFGT    Level-1 ; assemble following block when Level-1 is true
                    ldb       PD.PAR,y  ; get device parity: bit 7 set = window
                    cmpb      #$80      ; is it even potentially a CoWin window?
                    bne       L0524     ; no, skip the rest of the crap
                    clrb                ; set to no uppercase conversion
                    lda       PD.RAW,y  ; get raw output flag
                    bne       g.raw     ; if non-zero, we do raw writes: no conversion
                    ldb       PD.UPC,y  ; get uppercase conversion flag: 1 = do uppercase
g.raw               pshs      b,x,y,u   ; save length, PD, data buffer pointers
                    lbsr      get.wptr  ; get window table ptr into Y
                    bcs       no.wptr   ; do old method on error
* now we find out the number of non-control characters to write...
g.fast              lda       5,s       ; grab page number
                    inca                ; go to the next page
                    clrb                ; at the top of it
                    subd      5,s       ; take out number of bytes left to write
                    pshs      b         ; max. number of characters
                    clrb                ; always <256 characters to write
g.loop              lda       ,u+       ; get a character
                    cmpa      #$20      ; is it a control character?
                    blo       g.done    ; yes, we're done this stint
                    tst       1,s       ; get uppercase conversion flag
                    beq       g.loop1   ; don't convert
                    bsr       L0403     ; do a lower-uppercase conversion, if necessary
                    sta       -1,u      ; save again
g.loop1             incb                ; done one more character
                    cmpb      ,s        ; done as many as we can?
                    bne       g.loop    ; branch if comparison was not equal to g.loop
g.done              leas      1,s       ; kill max. count of characters to use
                    cmpb      #1        ; one or fewer characters?
                    bls       no.wptr   ; yes, go use old method
* now we call grfdrv...
                    ldu       5,s       ; get start pointer again
                    abx                 ; done B more characters...
                    stx       1,s       ; save on-stack
                    lbsr      call.grf  ; go call grfdrv: no error possible on return
                    leau      b,u       ; go up B characters in U, too
                    stu       5,s       ; save old U, too
                    puls      b,x,y,u   ; restore registers
                    bra       L0544     ; do end-buffer checks and continue

no.wptr             puls      b,x,y,u   ; restore all registers
                  ENDC    ;       end conditional assembly block
L0524               lda       ,u+       ; get character to write
                    ldb       PD.RAW,y  ; raw mode?
                    bne       L053D     ; yes, go write it
                    ldb       PD.UPC,y  ; force uppercase?
                    beq       L052A     ; no, continue
                    bsr       L0403     ; make it uppercase
L052A               cmpa      #C$LF     ; is it a Line feed?
                    bne       L053D     ; no, go print it
                    lda       #C$CR     ; get code for carriage return
                    ldb       PD.ALF,y  ; auto Line feed?
                    bne       L053D     ; yes, go print carriage return first
                    bsr       L0573     ; print carriage return
                    bcs       L055D     ; if error, go wait for device
                    lda       #C$LF     ; now, print the line feed

* Write character to device (call driver)
L053D               bsr       L0573     ; go write it to device
                    bcs       L055D     ; if error, go wait for device
                    ldb       #1        ; bump up # chars we have written
                    abx                 ; add b to x for indexed byte advance
L0544               cmpx      ,s        ; done whole WRITE call?
                    bhs       L0554     ; yes, go save # chars written & exit
                    ldb       PD.RAW,y  ; raw mode?
                    lbne      L04EC     ; yes, keep writing
                    lda       -1,u      ; get the char we wrote
                    lbeq      L04EC     ; nUL, keep writing
                    cmpa      PD.EOR,y  ; end of record?
                    lbne      L04EC     ; no, keep writing
L0554               leas      2,s       ; eof record, stop & Eat end of buffer ptr???
L0556               ldu       PD.RGS,y  ; get callers register pointer
                    stx       R$Y,u     ; save character count to callers Y
L055A               lbra      L0453     ; mark device write clear and return

* Check for forced uppercase
L0403               cmpa      #'a       ; less then 'a'?
                    blo       L0412     ; yes, leave it
                    cmpa      #'z       ; higher than 'z'?
                    bhi       L0412     ; yes, leave it
                    suba      #$20      ; make it uppercase
L0412               rts                 ; return

L055D               leas      2,s       ; purge stack
                    pshs      b,cc      ; preserve registers
                    bsr       L0556     ; wait for device
                    puls      pc,b,cc   ; restore & return

* Check for end of page (part of send char to driver)
L0573               pshs      u,y,x,a   ; preserve registers
                    ldx       PD.DEV,y  ; get device table pointer
                    cmpa      #C$CR     ; carriage return?
                    bne       L056F     ; no, go print it
                    ldu       V$STAT,x  ; get pointer to device stactic storage
                    ldb       V.PAUS,u  ; pause request?
                    bne       L0590     ; yes, go pause device
                    ldb       PD.RAW,y  ; raw output mode?
                    bne       L05A2     ; yes, go on
                    ldb       PD.PAU,y  ; end of page pause enabled?
                    beq       L05A2     ; no, go on
                    dec       V.LINE,u  ; subtract a line
                    bne       L05A2     ; not done, go on
                    ldb       #$ff      ; do a immediate pause request
                    stb       V.PAUS,u  ; store b into V.PAUS,u
                    bra       L059A     ; go read next character

L03DA               pshs      u,y,x     ; preserve registers
                    ldx       PD.DV2,y  ; get output device table pointer
                    beq       NoOut     ; none, exit
                    ldu       PD.DEV,y  ; get device table pointer
                    lbra      L03EA     ; process & return

NoOut               puls      pc,u,y,x  ; no output device so exit

* Wait for pause release
L0590               bsr       L03DA     ; read next character
                    bcs       L059A     ; error, try again
                    cmpa      PD.PSC,y  ; pause char?
                    bne       L0590     ; no, try again
L059A               bsr       L03DA     ; reset line count and read a character
                    cmpa      PD.PSC,y  ; pause character?
                    beq       L059A     ; yes, go read again
* Process Carriage return - do auto linefeed & Null's if necessary
* Entry: A=CHR$($0D)
L05A2               ldu       V$STAT,x  ; get static storage pointer
                    clra                ; clear a and carry state for success/zero value
                    sta       V.PAUS,u  ; clear pause request
                    lda       #C$CR     ; carriage return (in cases from pause)
                    bsr       L05C9     ; send it to driver
                    lda       PD.RAW,y  ; raw mode?
                    bne       L05C7     ; yes, return
                    ldb       PD.NUL,y  ; get end of line null count
                    pshs      b         ; save it
                    lda       PD.ALF,y  ; auto line feed enabled?
                    beq       L05BE     ; no, go on
                    lda       #C$LF     ; get line feed code
L05BA               bsr       L05C9     ; execute driver write routine
                    bcs       L05C5     ; error, purge stack and return
L05BE               clra                ; get null character
                    dec       ,s        ; done null count?
                    bpl       L05BA     ; no, go send it to driver
                    clra                ; clear carry
L05C5               leas      1,s       ; purge stack
L05C7               puls      pc,u,y,x,a ; restore & return

* Execute device driver write routine
* Entry: A=Character to write
* Execute device driver
* Entry: W=Entry offset (for type of function, ex. Write, Read)
*        A=Code to send to driver
L05C9               ldu       V$STAT,x  ; get device static storage pointer
                    pshs      y,x       ; preserve registers
                    clrb                ; clear b and carry state for success/zero value
                    stb       V.WAKE,u  ; wake it up
                  IFGT    Level-1 ; assemble following block when Level-1 is true
                    ldx       V$DRIVEX,x ; get driver execution pointer
                  ELSE    ;       select alternate assembly branch
                    pshs      d         ; save d on stack
                    ldx       V$DRIV,x  ; get driver execution pointer
                    ldd       M$EXEC,x  ; load d from M$EXEC,x
                    leax      d,x       ; compute address d,x into x
                    puls      d         ; restore d from stack
                  ENDC    ;       end conditional assembly block
                    jsr       D$WRIT,x  ; execute driver
                    puls      pc,y,x    ; restore & return

* Send character to driver
L0565               pshs      u,y,x,a   ; preserve registers
                    ldx       PD.DV2,y  ; get output device table pointer
                    beq       L0571     ; return if none
                    cmpa      #C$CR     ; carriage return?
                    beq       L05A2     ; yes, go process it
L056F               ldu       V$STAT,x  ; get device static storage pointer
                    clrb                ; clear b and carry state for success/zero value
                    stb       V.WAKE,u  ; wake it up
                  IFGT    Level-1 ; assemble following block when Level-1 is true
                    ldx       V$DRIVEX,x ; get driver execution pointer
                  ELSE    ;       select alternate assembly branch
                    pshs      d         ; save d on stack
                    ldx       V$DRIV,x  ; get driver module
                    ldd       M$EXEC,x  ; load d from M$EXEC,x
                    leax      d,x       ; compute address d,x into x
                    puls      d         ; restore d from stack
                  ENDC    ;       end conditional assembly block
                    jsr       D$WRIT,x  ; execute driver
L0571               puls      pc,u,y,x,a ; restore & return


* Check for printable character (Entry: A=char to echo)
L0413               ldb       PD.EKO,y  ; echo turned on?
                    bne       L0418     ; yes, go do
                    rts                 ; no, just return

L0418               cmpa      #C$SPAC   ; cHR$(32) or higher?
                    bhs       L0565     ; yes, go send to driver
                    cmpa      #C$CR     ; ctrl char
                    beq       L0565     ; yes, send it to the driver
* Any ctrl char <> CR, replace with period when echoed to device
L0423               pshs      a         ; save code
                    lda       #'.       ; get code for period
                    bsr       L0565     ; output it to device
                    puls      pc,a      ; restore original ctrl char & return

L0624               bsr       L0418     ; check if it's printable and send it to driver
* Process ReadLn
L05F8               lbsr      L03E2     ; get a character from device
                    lbcs      L0370     ; return if error
                    tsta                ; usable character?
                    lbeq      L02FE     ; no, check path descriptor special characters
                    ldb       PD.RPR,y  ; get reprint line code
                    cmpb      #C$RPRT   ; cntrl D?
                    lbeq      L02FE     ; yes, check path descriptor special characters
                    cmpa      PD.RPR,y  ; reprint line?
                    bne       L0629     ; no, Check line editor keys
                    cmpx      PD.MAX,y  ; character count at maximum?
                    beq       L05F8     ; yes, go read next character
                    ldb       #1        ; bump char count up by 1
                    abx                 ; add b to x for indexed byte advance
                    cmpx      ,s        ; done?
                    bhs       L0620     ; yes, exit
                    lda       ,u+       ; get character read
                    beq       L0624     ; null, go send it to driver
                    cmpa      PD.EOR,y  ; end of record character?
                    bne       L0624     ; no, go send it to driver
                    leau      -1,u      ; bump buffer pointer back 1
L0620               leax      -1,x      ; bump character count back 1
                    bra       L05F8     ; go read next character

L0629               cmpa      #C$PLINE  ; print rest of line code?
                    bne       L0647     ; no, check insert
* Process print rest of line
L062D               pshs      u         ; save buffer pointer
                    lbsr      L038B     ; go print rest of line
                    lda       PD.BSE,y  ; get backspace echo character
L0634               cmpu      ,s        ; beginning of buffer?
                    beq       L0642     ; yes, exit
                    leau      -1,u      ; bump buffer pointer back 1
                    leax      -1,x      ; bump character count back 1
                    bsr       L0565     ; print it
                    bra       L0634     ; keep going

L0642               leas      2,s       ; purge buffer pointer
                    bra       L05F8     ; return

L0647               cmpa      #C$INSERT ; insert character code?
                    bne       L0664     ; no, check delete
* Process Insert character (NOTE:Currently destroys W)
                  IFNE    H6309   ; assemble following block when H6309 is true
                    pshs      x,y       ; preserve x&y a moment
                    tfr       u,w       ; dupe buffer pointer into w
                    ldf       #$fe      ; end of buffer -1
                    tfr       w,x       ; source copy address
                    incw                ; include char we are on & dest address is+1
                    tfr       w,y       ; destination copy address
                    subr      u,w       ; w=w-u (Size of copy)
                    tfm       x-,y-     ; move buffer up one
                    puls      y,x       ; get back original y & x
                    lda       #C$SPAC   ; get code for space
                    sta       ,u        ; save it there
                  ELSE    ;       select alternate assembly branch
                    pshs      u         ; save u on stack
                    tfr       u,d       ; move buffer ptr to D
                    ldb       #$FF      ; point to end of buffer
                    tfr       d,u       ; move back to U
L06DE               lda       ,-u       ; shift buffer later by 1 char
                    sta       1,u       ; store a into 1,u
                    cmpu      ,s        ; compare u with ,s
                    bne       L06DE     ; branch if comparison was not equal to L06DE
                    lda       #C$SPAC   ; insert space at insert point in buffer
                    sta       ,u        ; store a into ,u
                    leas      2,s       ; adjust stack pointer by 2,s
                  ENDC    ;       end conditional assembly block
                    bra       L062D     ; go print rest of line

L0664               cmpa      #C$DELETE ; delete character code?
                    bne       L068B     ; no, check end of line
* Process delete line
                    pshs      u         ; save buffer pointer
                    lda       ,u        ; get character there
                    cmpa      PD.EOR,y  ; end of record?
                    beq       L0687     ; yes, don't bother to delete it
L0671               lda       1,u       ; get character beside it
                    cmpa      PD.EOR,y  ; this an end of record?
                    beq       L067C     ; yes, delete it
                    sta       ,u+       ; bump character back
                    bra       L0671     ; go do next character

L067C               lda       #C$SPAC   ; get code for space
                    cmpa      ,u        ; already there?
                    bne       L0685     ; no, put it in
                    lda       PD.EOR,y  ; get end of record code
L0685               sta       ,u        ; put it there
L0687               puls      u         ; restore buffer pointer
                    bra       L062D     ; go print rest of line

* Delete rest of buffer
L068B               cmpa      PD.EOR,y  ; end of record code? (normally CR)
                    bne       L02FE     ; no, check for special path dsc. chars
* CR hit, replace rest of buffer with spaces?
                    pshs      u         ; yes, Save buffer pointer
                    bra       L069F     ; go erase rest of buffer

L0696               pshs      a         ; save CR code
                    lda       #C$SPAC   ; get code for space
                    lbsr      L0565     ; print it
                    puls      a         ; restore CR code
L069F               cmpa      ,u+       ; end of record?
                    bne       L0696     ; no, go print a space
                    puls      u         ; restore buffer pointer
* Check character read against path descriptor
L02FE               tsta                ; usable character?
                    beq       L030C     ; no, go on
                    ldb       #PD.BSP   ; get start point in path descriptor
L0303               cmpa      b,y       ; match code in descriptor?
                    beq       L032C     ; yes, go process it
                    incb                ; move to next one
                    cmpb      #PD.QUT   ; done check?
                    bls       L0303     ; no, keep going
L030C               cmpx      PD.MAX,y  ; past maximum character count?
                    bls       L0312     ; no, go on
                    stx       PD.MAX,y  ; update maximum character count
L0312               ldb       #1        ; add 1 char
                    abx                 ; add b to x for indexed byte advance
                    cmpx      ,s        ; past requested amount?
                    blo       L0322     ; no, go on
                    lda       PD.OVF,y  ; get overflow character
                    lbsr      L0565     ; send it to driver
                    leax      -1,x      ; subtract a character
                    lbra      L05F8     ; go try again

L0322               ldb       PD.UPC,y  ; force uppercase?
                    beq       L0328     ; no, put char in buffer
                    lbsr      L0403     ; make character uppercase
L0328               sta       ,u+       ; put character in buffer
                    lbsr      L0413     ; check for printable
                    lbra      L05F8     ; go try again

* Process path option characters
L032C               pshs      x,pc      ; preserve character count & PC
                    leax      <L033F,pc ; point to branch table
                    subb      #PD.BSP   ; subtract off first code
                    lslb                Account ; for 2 bytes a entry
                    abx                 ; point to entry point
                    stx       2,s       ; save it in PC on stack
                    puls      x         ; restore X
C8E3                jsr       [,s++]    ; execute routine
                    lbra      L05F8     ; continue on

* Vector points for PD.BSP-PD.QUT
L033F               bra       L03BB     ; process PD.BSP
                    bra       L03A5     ; process PD.DEL
                    bra       L0351     ; process PD.EOR
                    bra       L0366     ; process PD.EOF
                    bra       L0381     ; process PD.RPR
                    bra       L038B     ; process PD.DUP
                    rts                 ; pD.PSC we don't worry about
                    nop
                    bra       L03A5     ; process PD.INT
                    bra       L03A5     ; process PD.QUT

* Process PD.EOR character
L0351               leas      2,s       ; purge return address
                    sta       ,u        ; save character in buffer
                    lbsr      L0413     ; call distant local routine L0413
                    ldu       PD.RGS,y  ; get callers register stack pointer
                    ldb       #1        ; bump up char count by 1
                    abx                 ; add b to x for indexed byte advance
                    stx       R$Y,u     ; store it in callers Y
                    lbsr      L042B     ; call distant local routine L042B
                    leas      2,s       ; adjust stack pointer by 2,s
                    lbra      L0453     ; long branch unconditionally to L0453

* Process PD.EOF
L0366               leas      2,s       ; purge return address
                    leax      ,x        ; read anything?
                    lbeq      L02A2     ; long branch if comparison was equal to L02A2
                    bra       L030C     ; branch unconditionally to L030C

L0370               pshs      b         ; save b on stack
                    lda       #C$CR     ; load a from #C$CR
                    sta       ,u        ; store a into ,u
                    lbsr      L0565     ; send it to the driver
                    puls      b         ; restore b from stack
                    lbra      L02A4     ; long branch unconditionally to L02A4

* Process PD.RPR
L0381               lda       PD.EOR,y  ; get end of record character
                    sta       ,u        ; put it in buffer
                    ldx       #0        ; load x from #0
                    ldu       PD.BUF,y  ; get buffer ptr
L0388               lbsr      L0418     ; send it to driver
L038B               cmpx      PD.MAX,y  ; character maximum?
                    beq       L03A2     ; yes, return
                    ldb       #1        ; bump char count up by 1
                    abx                 ; add b to x for indexed byte advance
                    cmpx      2,s       ; done count?
                    bhs       L03A0     ; yes, exit
                    lda       ,u+       ; get character from buffer
                    beq       L0388     ; null, go send it
                    cmpa      PD.EOR,y  ; done line?
                    bne       L0388     ; no go send it
                    leau      -1,u      ; move back a character
L03A0               leax      -1,x      ; move character count back
L03A2               rts                 ; return

L03A3               bsr       L03BF     ; erase one character while deleting the current line
* PD.DEL/PD.QUT/PD.INT processing
L03A5               leax      ,x        ; any characters?
                    beq       L03B8     ; no, reset buffer ptr
                    ldb       PD.DLO,y  ; backspace over line?
                    beq       L03A3     ; yes, go do it
                    ldb       PD.EKO,y  ; echo character?
                    beq       L03B5     ; no, zero out buffer pointers & return
                    lda       #C$CR     ; send CR to the driver
                    lbsr      L0565     ; send it to driver
L03B5               ldx       #0        ; zero out count
L03B8               ldu       PD.BUF,y  ; reset buffer pointer
L03BA               rts                 ; return

* Process PD.BSP
L03BB               leax      ,x        ; any characters?
                    beq       L03A2     ; no, return
L03BF               leau      -1,u      ; mover buffer pointer back 1 character
                    leax      -1,x      ; move character count back 1
                    ldb       PD.EKO,y  ; echoing characters?
                    beq       L03BA     ; no, return
                    ldb       PD.BSO,y  ; which backspace method?
                    beq       L03D4     ; use BSE
                    bsr       L03D4     ; do a BSE
                    lda       #C$SPAC   ; get code for space
                    lbsr      L0565     ; send it to driver
L03D4               lda       PD.BSE,y  ; get BSE
                    lbra      L0565     ; send it to driver

                  IFGT    Level-1 ; assemble following block when Level-1 is true
* check PD.DTP,y and update PD.WPTR,y if it's device type $10 (grfdrv)
get.wptr            pshs      x,u       ; save x,u on stack
                    ldu       PD.DEV,y  ; get device table entry
                    ldx       V$DRIV,u  ; get device driver module
                    ldd       M$Name,x  ; offset to name
                    ldd       d,x       ; load d from d,x
                    cmpd      #"VT      ; is it VTIO?
                    bne       no.fast   ; no, don't do the fast stuff
* If/when we introduce buffered writes to CoVDG, this will need changing. LCB
                    ldd       >WGlobal+G.GrfEnt ; does GrfDrv have an entry address?
                    beq       no.fast   ; nope, don't bother calling it.
                    ldu       V$STAT,u  ; and device static storage
                    tst       V.ParmCnt,u ; are we busy getting more parameters?
                    bne       no.fast   ; yes, don't do buffered writes
* Get window table pointer & verify it: copied from CoWin and modified
                    ldb       V.WinNum,u ; get window # from device mem
                    lda       #Wt.Siz   ; size of each entry
                    mul                 ; calculate window table offset
                    addd      #WinBase  ; point to specific window table entry
                    tfr       d,y       ; move to y, the register we want
                    lda       Wt.STbl,y ; get MSB of scrn tbl ptr
                    bgt       VerExit   ; if $01-$7f, should be ok
* Return illegal window definition error
no.fast             comb                ; set carry: no error code, it's an internal routine
                    puls      x,u,pc    ; restore x,u,pc and return

VerExit             clra                ; no error
                    puls      x,u,pc    ; restore x,u,pc and return

call.grf            pshs      d,x,y,u   ; save registers
                    ldx       #$0180    ; where to put the text
                  IFNE    H6309   ; assemble following block when H6309 is true
                    pshs      cc        ; save old CC
                  ELSE    ;       select alternate assembly branch
                    tfr       cc,a      ; transfer cc,a
                    sta       -2,x      ; store a into -2,x
                  ENDC    ;       end conditional assembly block
                    orcc      #IntMasks+Entire ; shut everything else off
                  IFNE    H6309   ; assemble following block when H6309 is true
                    clra                ; make sure high byte=0
                    tfr       d,w       ; transfer d,w
                    tfm       u+,x+     ; move the data into low memory
                  ELSE    ;       select alternate assembly branch
l@                  lda       ,u+       ; load a from ,u+
                    sta       ,x+       ; store a into ,x+
                    decb                ; decrement b counter
                    bne       l@        ; branch if comparison was not equal to l@
                  ENDC    ;       end conditional assembly block
                    ldb       #6        ; alpha put
                    stb       >WGlobal+G.GfBusy ; flag grfdrv busy
                  IFNE    H6309   ; assemble following block when H6309 is true
                    lde       ,s+       ; grab old CC off of the stack
                    lda       1,s       ; get the number of characters to write
                  ELSE    ;       select alternate assembly branch
                    lda       1,s       ; get the number of characters to write
                  ENDC    ;       end conditional assembly block
* A = number of bytes at $0180 to write out...
                    bsr       do.grf    ; do the call
* ignore errors : none possible from this particular call
call.out            puls      d,x,y,u,pc ; and return

* this routine should always be called by a BSR, and grfdrv will use the
* PC saved on-stack to return to the calling routine.
* ALL REGISTERS WILL BE TRASHED
do.grf              sts       >WGlobal+G.GrfStk ; stack pointer for GrfDrv
                    lds       <D.CCStk  ; get new stack pointer
                  IFNE    H6309   ; assemble following block when H6309 is true
                    pshs      dp,x,y,u,pc ; save dp,x,y,u,pc on stack
                    pshsw     ;         save 6309 w register on stack
                    pshs      cc,d      ; save all registers
                  ELSE    ;       select alternate assembly branch
                    pshs      dp,cc,d,x,y,u,pc ; save dp,cc,d,x,y,u,pc on stack
                  ENDC    ;       end conditional assembly block
                    ldx       >WGlobal+G.GrfEnt ; get GrfDrv entry address
                    stx       R$PC,s    ; save grfdrv entry address as PC on the stack
                  IFNE    H6309   ; assemble following block when H6309 is true
                    ste       R$CC,s    ; save CC onto CC on the stack
                  ELSE    ;       select alternate assembly branch
                    stb       R$B,s     ; store b into R$B,s
                    ldb       $017E     ; load b from $017E
                    stb       R$CC,s    ; store b into R$CC,s
                  ENDC    ;       end conditional assembly block
                    jmp       [>D.Flip1] ; flip to grfdrv and execute it
                  ENDC    ;       end conditional assembly block

                    emod      ;         end the OS-9 module body
eom                 equ       *         ; define constant eom
                    end       ;         end assembler source
