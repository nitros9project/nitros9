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
* - Speeded up OldWriteDriverHelper (write char to device) routine by a few cycles
* - Slightly optimized Insert char.
* - Move branch table so Read & ReadLn are 1 cycle faster each; fixed
*   SS.Fill so size is truncated @ 256 bytes.
* - Added NO CR option to SS.Fill (for use with modified Shellplus V2.2
*   command history).
*
*          1993/04/21  ???
* Slight speedup to some of ReadLn parsing, TFM's in Open/Close.
* - More optimization to read/write driver calls
* - Got rid of branch table @ OldReadDispatchTable for speed
*
*          1993/05/21  ???
* V1.10:
* Added Boisy Pitre's patch for non-sharable devices.
* - Saved 4 cycles in routine @ CopyBufferToCaller
* - Modified Boisy's routine to not pshs/puls B (saves 2 cycles).
* - Changed buffer prefill of CR's to save 1 byte.
*
*          1993/07/27  ???
* V1.11:
* Changed a BRA to a LBRA to a straight LBRA in ApplyReadLineUppercase.
* - Optimized path option character routine @ DispatchEditCharacter
*
*          1993/08/03  ???
* Modified vector table @ HandleBackspaceVector to save 1 cycle on PD.PSC
* - Sped up uppercase conversion checks for ReadLn & WritLn
* - Changed 2 BRA's to OldReadLineLoop to do an LBRA straight to ReadLineLoop (ReadLn loop)
* - Moved SendCharacter routine so Reprint line, Insert & Delete char (on ReadLn)
*   are 1 cycle faster / char printed
* - Changed 2 references to OldSendCharacter to go straight to SendCharacter
* - Sped up ReadLn loop by 2 or 3 cycles per char read
*
*          1993/09/21  ???
* V1.12:
* Sped up AlignCallerBuffer by 1 or 2 cycles (depending on branch)
* - Changed LDD ,S to TFR X,D (saves 1 cycle) @ RefillWriteBuffer (Write & WritLn)
* - Modified RefillWriteBuffer to use W without TFR (+1 byte, -3 cycles) (Write)
*
*          1993/11/09  ???
* Took LDX #0/LDU PD.BUF,y from ResetReadLineCount & merged in @ BeginRawRead, SetReadLineLimit & HandleReprintLine.
* Also changed BEQ @ ClearCurrentLine to skip re-loading X with 0.
*
*          1993/11/10  ???
* Moved OldReadDriverHelper routine to allow a couple of BSR's instead of LBSR's In READ.
* - Moved driver call right into READ loop (should save 25 cycles/char read)
* - Moved driver call right into SendCharacter (should save 12 cycles/char written on echo,
*   line editing, etc.)
*
*          1993/11/26  ???
* Moved ProcessReadLineCharacter (ReadLn parsing) to end where ReadLn routine is moved ReadDeviceCharacter
* so Read loop would be optimized for it (read char from driver) instead of
* CopyBufferToCaller (write filled buffer to caller).
* Changed LDA #C$NULL to CLRA.
*
*          1993/12/01  ???
* Modified device write call (CallDeviceWrite) to preserve Y as well, to cut down on
* PSHS/PULS.
* - Changed ReadDeviceCharacter & ReadPauseCharacter to exit immediately if PD.DEV or PD.DV2 (depending
* on which routine) is empty (eliminated redundant LEAX ,X).
*
*          1994/05/31  ???
* Attempted mode to SelectReadDeviceState to eliminate LDW #D$READ, changed:
*      LDX V$DRIV,x
*      ADDW M$Exec,x
*      JSR w,x
* to:
*      LDW V$DRIV,x
*      ADDW M$Exec,w
*      JSR D$READ,w
* Did same to CallWriteDriver & CallDeviceWrite (should speed up each by 1 cycle)
*
*          1994/06/07  ???
* Attempted to modify all M$Exec calls to use new V$DRIVEX (REQUIRES NEW IOMAN)
* - ExecuteStatusRequest (Get/SetStat), SelectReadDeviceState (Read), CallWriteDriver (Write), CallDeviceWrite (Write)
* - Changed CheckDeviceBusy to use LDB V.BUSY,x...CMPB ,s...TFR B,A
*
*          1994/06/08  ???
* Changed TST <PD.EKO,y in read loop (EchoRawCharacter) to LDB PD.EKO,y
* - Changed LEAX 1,X to LDB #1/ABX @ CountRawCharacter
* - Changed LEAX >HandleBackspaceVector,pc @ DispatchEditCharacter to use < (8 bit) version
* - Modified BeginReadLine to use D instead of X, allowing TSTA, and faster exit on 0 byte
*   just BRAnching to ReleaseDevices
*
*          1994/06/09  ???
* Changed LEAX 1,X to LDB #1/ABX @ WriteCharacter, ReadLineLoop, AdvanceReadLineBuffer, HandleEndOfRecord, ResetReadLineBuffer
* - Changed to WriteCharacterPaged: All TST's changed to LDB's
* - Changed Open/Create init to use LEAX,PC instead of BSR/PULS X
* - Changed TST PD.CNT,y to LDA PD.CNT,y @ close
* - Eliminated OldCloseSuccessPath, changed references to it to go to ReturnSuccess
* - Eliminated useless LEAX ,X @ CheckDeviceUse, and changed BEQ @ CheckDeviceUse to go to ReturnToCaller
*   instead of ReturnSuccess (speeds CLOSE by 5 or 10 cycles)
* - Moved OldCloseCleanupHelper into CloseLastPath, eliminate BSR/RTS, plus
* - Changed TST V.TYPE,x to LDB V.TYPE,x
* - Moved EchoReadLineCharacter to just before ReadLineLoop to eliminate BRA ReadLineLoop (ReadLn)
* - Changed TST PD.EKO,y @ EchoCharacter to LDB PD.EKO,y
* - Moved EchoCharacter-EchoControlAsPeriod routines to later in code to allow short branches
* - As result of above, changed 6 LBxx to Bxx
* - Changed TST PD.MIN,y @ CheckDevicesAcquired to LDA PD.MIN,y
* - Changed TST PD.RAW,y/TST PD.UPC,y @ ProcessWriteBuffer to LDB's
* - Changed TST PD.ALF,y @ HandleLineFeed to LDB
* - WriteCharacter: Moved TST PD.RAW,y to before LDA -1,u to speed up WRITE, changed it to LDB
*
*          1994/06/10  ???
* Changed TST PD.ALF,y to LDB @ HandleLineFeed
* - Changed CLR V.WAKE,u to CLRA/STA V.WAKE,u @ SelectReadDeviceState (Read)
* - Changed CLR V.BUSY,u to CLRA/STA V.BUSY,u @ ReleaseDeviceIfOwned
* - Changed CLR PD.MIN,y to CLRA/STA PD.MIN,y, moved before LDA P$ID,x @ TryAcquireDevices
* - Changed CLR PD.RAW,y @ CheckDevicesAcquired to STA PD.RAW, since A already 0 to get there
* - Changed CLR V.PAUS,u to CLRA/STA V.PAUS,u @ HandleCarriageReturn
* - Changed TST PD.RAW,y to LDA PD.RAW,y @ HandleCarriageReturn
* - Changed TST PD.ALF,y to LDA PD.ALF,y @ HandleCarriageReturn
* - Changed CLR V.WAKE,u to CLRB/STB V.WAKE,u @ CallWriteDriver
* - Changed CLR V.WAKE,u to CLRB/STB V.WAKE,u @ CallDeviceWrite
* - Changed TST PD.UPC,y to LDB PD.UPC,y @ ApplyReadLineUppercase
* - Changed TST PD.DLO,y/TST PD.EKO,y to LDB's @ ClearCurrentLine
*
*          1994/06/16  ???
* Changed TST PD.UPC,y to LDB PD.UPC,y @ ApplyReadLineUppercase
* - Changed TST PD.BSO,y to LDB PD.BSO,y @ ErasePreviousCharacter
* - Changed TST PD.EKO,y to LDB PD.EKO,y @ ErasePreviousCharacter
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
* chars no change. (EchoPrintableCharacter)
* 2 lbsr's changed to bsr's (both CPU's) - bsr ForceUppercase in g.loop & bsr SendCharacter in EraseReprintedCharacterLoop
*
*          2026/07/11  Codex
* Annotated source and normalized comments.

                    nam       SCF
                    ttl       NitrOS-9 Sequential Character File Manager

                    use       defsfile
                    use       scf.d
                  IFGT    Level-1
                    use       cocovtio.d
                  ENDC

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
                  IFNE    H6309
                    ldw       #msgsize  ; get size of default message
                    tfm       x+,u+     ; copy it into buffer (leaves X pointing to 2nd CR)
                    ldw       #blksize  ; size of rest of buffer
                    tfm       x,u+      ; fill rest of buffer with CR's
                  ELSE
CopyMsg             lda       ,x+       ; load a from ,x+
                    sta       ,u+       ; store a into ,u+
                    decb                ; decrement b counter
                    cmpa      #C$CR     ; compare a with #C$CR
                    bne       CopyMsg   ; branch if comparison was not equal to CopyMsg
CopyCR              sta       ,u+       ; store a into ,u+
                    decb                ; decrement b counter
                    bne       CopyCR    ; branch if comparison was not equal to CopyCR
                  ENDC
                    ldu       PD.DEV,y  ; get device table entry address
                    beq       bpnam     ; doesn't exist, exit with bad pathname error
                    ldx       V$STAT,u  ; get devices' static storage address
                    lda       PD.PAG,y  ; get devices page length
                    sta       V.LINE,x  ; save it to devices static storage
                    ldx       V$DESC,u  ; get descriptor address
                    ldd       PD.D2P,y  ; get offset to device name (duplicate from dev dsc)
                    beq       InitDeviceState ; none, skip ahead
                  IFNE    H6309
                    addr      d,x       ; point to device name in descriptor
                    lda       PD.MOD,y  ; get device mode (Read/Write/Update)
                    lsrd                ; ??? (swap Read/Write bits around in A?)
                  ELSE
                    leax      d,x       ; compute address d,x into x
                    lda       PD.MOD,y  ; get device mode (Read/Write/Update)
                    lsra                ; shift a right one bit
                    rorb                ; continue SCF file-manager flow
                  ENDC
                    lsra                ; shift a right one bit
                    rolb                ; continue SCF file-manager flow
                    rola                ; continue SCF file-manager flow
                    rorb                ; continue SCF file-manager flow
                    rola                ; continue SCF file-manager flow
                  IFGT    Level-1
                    pshs      y         ; save path descriptor pointer temporarily
                    ldy       <D.Proc   ; get current process pointer
                    ldu       <D.SysPrc ; get system process descriptor pointer
                    stu       <D.Proc   ; make system current process
                  ENDC
                    os9       I$Attach  ; attempt to attach to device name in device desc.
                  IFGT    Level-1
                    sty       <D.Proc   ; restore old current process pointer
                    puls      y         ; restore path descriptor pointer
                  ENDC
                    bcs       OpenErr   ; couldn't attach to device, detach & exit with error
                    stu       PD.DV2,y  ; save new output (echo) device table pointer
*         ldu   PD.DEV,y     Get device table pointer
InitDeviceState     ldu       V$STAT,u  ; point to it's static storage
                  IFNE    H6309
                    clrd                ; clear d to zero
                  ELSE
                    clra                ; clear a and carry state for success/zero value
                    clrb                ; clear b and carry state for success/zero value
                  ENDC
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
                  IFNE    H6309
                    tim       #SHARE.,PD.MOD,y ; test memory bits at #SHARE.,PD.MOD,y
                  ELSE
                    lda       PD.MOD,y  ; load a from PD.MOD,y
                    bita      #SHARE.   ; test a bits against #SHARE.
                  ENDC
                    bne       NoShare   ; branch if comparison was not equal to NoShare
* we now know that the path's mode doesn't have the SHARE. bit set, so
* we need to look at the mode of the path in the list header pointer to
* see if ITS SHARE. bit is set (meaning it wants exclusive access to the
* port).  If so we bail out
                  IFNE    H6309
                    tim       #SHARE.,PD.MOD,x ; test memory bits at #SHARE.,PD.MOD,x
                  ELSE
                    lda       PD.MOD,x  ; load a from PD.MOD,x
                    bita      #SHARE.   ; test a bits against #SHARE.
                  ENDC
                    beq       CkCar     ; check carrier status
NoShare             leas      2,s       ; eat extra stack (including good path count)
                    comb                ; complement b to set carry for error return
                    ldb       #E$DevBsy ; non-sharable device busy error
                    bra       OpenErr   ; go detach device & exit with error

Yespath             sty       V.PDLHd,u ; save path descriptor ptr
                    bra       InvokeDriverOpen ; go open the path

CheckOpenPath       tfr       d,x       ; change to PD.PLP path descriptor
CkCar               ldb       PD.PST,x  ; get Carrier status
                    bne       AdvanceOpenPath ; carrier was lost, don't update count
                    inc       1,s       ; carrier not lost, bump up count of good paths
AdvanceOpenPath     ldd       PD.PLP,x  ; get path descriptor list pointer
                    bne       CheckOpenPath ; there is one, go make it the current one
                    sty       PD.PLP,x  ; save path descriptor ptr as path dsc. list ptr
InvokeDriverOpen    lda       #SS.Open  ; internal open call
                    pshs      a         ; save it on the stack
                    inc       2,s       ; bump counter of good paths up by 1
                    lbsr      CallComStatus ; do the SS.Open call to the driver
                    lda       2,s       ; get counter of good paths
                    leas      3,s       ; eat stack
* NEW: return with error if SS.Open return error
                    bcs       OpenErrorCleanup ; +++BGP+++
                    deca                ; bump down good path count
                    bne       ReturnSuccess ; if more still open, exit without error
                    blo       OpenErrorCleanup ; if negative, something went wrong
                    lbra      UpdateComStatus ; set parity/baud & return

* we come here if there was an error in Open (after I$Attach and F$SRqMem!)
OpenErrorCleanup    bsr       RemoveFromPDList ; error, go clear stuff out
OpenErr             pshs      b,cc      ; preserve error status
                    bsr       DetachEchoDevice ; detach device
                    puls      pc,b,cc   ; restore error status & return

* I$Close entry point
close               pshs      cc        ; preserve interrupt status
                    orcc      #IntMasks ; disable interrupts
                    ldx       PD.DEV,y  ; get device table pointer
                    bsr       CheckDeviceUse ; check it
                    ldx       PD.DV2,y  ; get output device table pointer
                    bsr       CheckDeviceUse ; check it
                    puls      cc        ; restore interrupts
                    lda       PD.CNT,y  ; any open images?
                    beq       CloseLastPath ; no, go on
ReturnSuccess       clra                ; clear carry
ReturnToCaller      rts                 ; return

* Detach device & return buffer memory
CloseLastPath       bsr       RemoveFromPDList ; unlink this path descriptor from the device list
                    lda       #SS.Close ; get setstat code for close
                    ldx       PD.DEV,y  ; get pointer to device table
                    ldx       V$STAT,x  ; get static mem ptr
                    ldb       V.TYPE,x  ; get device type    \ WON'T THIS SCREW UP WITH
                    bmi       DetachEchoDevice ; window, skip ahead / MARK OR SPACE PARITY???
                    pshs      x,a       ; save close code & X for SS.Close calling routine
                    lbsr      CallComStatus ; not window, go call driver's SS.Close routine
                    leas      3,s       ; purge stack
DetachEchoDevice    ldu       PD.DV2,y  ; get output device pointer
                    beq       ReleaseInputBuffer ; nothing there, go on
                    os9       I$Detach  ; detach it
ReleaseInputBuffer  ldu       PD.BUF,y  ; get buffer pointer
                    beq       CloseSuccessReturn ; none defined go on
                    ldd       #256      ; get buffer size
                    os9       F$SRtMem  ; return buffer memory to system
CloseSuccessReturn  clra                ; clear carry
                    rts                 ; return

* Remove path descriptor from device path descriptor linked list
* Entry: Y = path descriptor
RemoveFromPDList
                    ldx       #1        ; load x from #1
                    pshs      cc,d,x,y,u ; save cc,d,x,y,u on stack
                    ldu       PD.DEV,y  ; get device table pointer
                    beq       ClearPathLink ; none, skip ahead
                    ldu       V$STAT,u  ; get static storage pointer
                    beq       ClearPathLink ; none, skip ahead
                    ldx       V.PDLHd,u ; get path descriptor list header
                    beq       ClearPathLink ; none, skip ahead
                    ldd       PD.PLP,y  ; get path descriptor list pointer
                    cmpy      V.PDLHd,u ; is the passed path descriptor the same?
                    bne       CheckNextPathLink ; branch if not
                    std       V.PDLHd,u ; store d into V.PDLHd,u
                    bne       ClearPathLink ; branch if comparison was not equal to ClearPathLink
                    clr       4,s       ; clear LSB of X on stack
                    bra       ClearPathLink ; return

* D = path descriptor to store
FindPreviousPath    ldx       PD.PLP,x  ; advance to next path descriptor in list
                    beq       RemovePathReturn ; branch if at end of linked list
CheckNextPathLink   cmpy      PD.PLP,x  ; is the passed path descriptor the same?
                    bne       FindPreviousPath ; branch if not
                    std       PD.PLP,x  ; store
                  IFNE    H6309
ClearPathLink       clrd                ; clear d to zero
                  ELSE
ClearPathLink       clra                ; clear a and carry state for success/zero value
                    clrb                ; clear b and carry state for success/zero value
                  ENDC
                    std       PD.PLP,y  ; store d into PD.PLP,y
RemovePathReturn    puls      cc,d,x,y,u,pc ; restore cc,d,x,y,u,pc and return


* Check path number?
* Entry: X=Ptr to device table (just LDX'd)
*        Y=Path dsc. ptr
CheckDeviceUse      beq       ReturnToCaller ; no device table, return to caller
                    ldx       V$STAT,x  ; get static storage pointer
                    ldb       PD.PD,y   ; get system path number from path dsc.
                    lda       PD.CPR,y  ; get ID # of process currently using path
                    pshs      d,x,y     ; save everything
                    cmpa      V.LPRC,x  ; current process same as last process using path?
                    bne       DeviceUseReturn ; no, return
                  IFGT    Level-1
                    ldx       <D.Proc   ; get current process pointer
                  ELSE
                    ldx       >D.Proc   ; get current process pointer
                  ENDC
                    leax      P$Path,x  ; point to local path table
                    clra                ; start path # = 0 (Std In)
FindLocalPath       cmpb      a,x       ; same path as one is process' local path list?
                    beq       DeviceUseReturn ; yes, return
                    inca                ; move to next path
                    cmpa      #NumPaths ; done all paths?
                    blo       FindLocalPath ; no, keep going
                    pshs      y         ; preserve path descriptor pointer
                  IFNE    H6309
                    lda       #SS.Relea ; release signals SetStat
                    ldf       #D$PSTA   ; get Setstat offset
                  ELSE
                    ldd       #SS.Relea*256+D$PSTA ; load d from #SS.Relea*256+D$PSTA
                  ENDC
                    bsr       ExecuteStatusRequest ; execute driver setstat routine
                    puls      y         ; restore path pointer
                  IFGT    Level-1
                    ldx       <D.Proc   ; get current process pointer
                  ELSE
                    ldx       >D.Proc   ; get current process pointer
                  ENDC
                    lda       P$PID,x   ; get parent process ID
                    sta       ,s        ; save it
                  IFGT    Level-1
                    os9       F$GProcP  ; get pointer to parent process descriptor
                  ELSE
                    ldx       <D.PrcDBT ; load x from <D.PrcDBT
                    os9       F$Find64  ; call OS-9 service F$Find64
                  ENDC
                    leax      P$Path,y  ; point to local path table
                    ldb       1,s       ; get path number
                    clra                ; get starting path number
FindEchoLocalPath   cmpb      a,x       ; same path?
                    beq       SaveLastProcess ; yes, go on
                    inca                ; move to next path
                    cmpa      #NumPaths ; done all paths?
                    blo       FindEchoLocalPath ; no, keep checking
                    clr       ,s        ; clear process ID
SaveLastProcess     lda       ,s        ; get process ID
                    ldx       2,s       ; get static storage pointer
                    sta       V.LPRC,x  ; store it as last process
DeviceUseReturn     puls      d,x,y,pc  ; restore & return

* I$GetStt entry point
getstt              lda       PD.PST,y  ; path status ok?
                    lbne      ReportHangup ; no, terminate process
                    ldx       PD.RGS,y  ; get register stack pointer
                    lda       R$B,x     ; get function code
                    bne       LoadGetStatOffset ; if not SS.Opt, call driver with function code
* ($00) SS.Opt Getstat - All of PD.OPT is already set up, *except* parity/baud, so we need to grab that
                    pshs      a,x,y     ; preserve registers (LCB: why X? SS.ComSt doesn't use X)
                    lda       #SS.ComSt ; get code for Comstat
                    sta       R$B,x     ; save it in callers B
                    ldu       R$Y,x     ; preserve callers Y
                    pshs      u         ; save u on stack
                    bsr       LoadGetStatOffset ; call SS.ComSt GetStat in driver (puts parity/baud into callers Y)
                    puls      u         ; restore callers Y
                    puls      a,x,y     ; restore registers
                    sta       R$B,x     ; save SS.Opt code back into caller's B
                    ldd       R$Y,x     ; get com stat (baud/parity)
                    stu       R$Y,x     ; put original callers Y back
                    bcs       SetOptSuccess ; return if error
                    std       PD.PAR,y  ; update path descriptor with baud/parity
SetOptSuccess       clrb                ; clear carry
SetOptReturn        rts                 ; return

* Execute device driver Get/Set Status routine
* Entry: A=GetStat/SetStat code
*        Y=path descriptor ptr
                  IFNE    H6309
LoadGetStatOffset   ldf       #D$GSTA   ; get Getstat driver entry offset
ExecuteStatusRequest ldx       PD.DEV,y  ; get device table pointer
                    ldu       V$STAT,x  ; get static storage pointer
                  IFGT    Level-1
                    ldx       V$DRIVEX,x ; get execution pointer of driver
                  ELSE
                    pshs      d         ; save d on stack
                    ldx       V$DRIV,x  ; get driver module
                    ldd       M$EXEC,x  ; point to entry point in driver
                    leax      d,x       ; compute address d,x into x
                    puls      d         ; restore d from stack
                  ENDC
                    pshs      y,u       ; preserve registers
                    jsr       f,x       ; execute driver
                    puls      y,u,pc    ; restore & return
                  ELSE
LoadGetStatOffset   ldb       #D$GSTA   ; load b from #D$GSTA
ExecuteStatusRequest ldx       PD.DEV,y  ; load x from PD.DEV,y
                    ldu       V$STAT,x  ; load u from V$STAT,x
                  IFGT    Level-1
                    ldx       V$DRIVEX,x ; load x from V$DRIVEX,x
                  ELSE
                    pshs      d         ; save d on stack
                    ldx       V$DRIV,x  ; get driver module
                    ldd       M$EXEC,x  ; load d from M$EXEC,x
                    leax      d,x       ; compute address d,x into x
                    puls      d         ; restore d from stack
                  ENDC
                    pshs      u,y       ; save u,y on stack
ExecuteStatusEntry  jsr       b,x       ; call subroutine at b,x
                    puls      y,u,pc    ; restore y,u,pc and return
                  ENDC

* I$SetStt entry point
setstt              lbsr      WaitForDevices ; call distant local routine WaitForDevices
SendSetStat         bsr       DispatchSetStat ; check codes
                    pshs      cc,b      ; preserve registers
                    lbsr      ReleaseDevices ; wait for device
                    puls      cc,b,pc   ; restore & return

putkey              cmpa      #SS.Fill  ; buffer preload?
                    bne       ExecuteStatusRequest ; no, go execute driver setstat
                    pshs      u,y,x     ; save u,y,x on stack
                  IFGT    Level-1
                    ldx       <D.Proc   ; get current process pointer
                  ELSE
                    ldx       >D.Proc   ; get current process pointer
                  ENDC
                    lda       R$Y,u     ; get flag byte for CR/NO CR
                    pshs      a         ; save it
                  IFGT    Level-1
                    lda       P$Task,x  ; get task number
                    ldb       <D.SysTsk ; get system task
                  IFNE    H6309
                    ldx       R$X,u     ; get pointer to data to move
                    ldf       R$Y+1,u   ; get number of bytes (max size of 256 bytes)
                    ldu       PD.BUF,y  ; get input buffer pointer
                    clre                ; high byte of Y
                    tfr       w,y       ; move size into proper register for F$Move
                  ELSE
                    pshs      d         ; save d on stack
                    clra                ; clear a and carry state for success/zero value
                    ldb       R$Y+1,u   ; load b from R$Y+1,u
                    ldx       R$X,u     ; load x from R$X,u
                    ldu       PD.BUF,y  ; load u from PD.BUF,y
                    tfr       d,y       ; transfer d,y
                    puls      d         ; restore d from stack
                  ENDC
* X=Source ptr from caller, Y=# bytes to move, U=Input buffer ptr
                    os9       F$Move    ; move it
                    bcs       putkey1   ; exit if error
                    tfr       y,d       ; move number of bytes to D
                  ELSE
loop                lda       ,x+       ; load a from ,x+
                    sta       ,u+       ; store a into ,u+
                    leay      -1,y      ; compute address -1,y into y
                    bne       loop      ; branch if comparison was not equal to loop
                  ENDC
                    lda       ,s        ; get CR flag
                    bmi       putkey1   ; don't want CR appended, exit
                    lda       #C$CR     ; get code for carriage return
                    sta       b,u       ; put it in buffer to terminate string
putkey1             puls      a,x,y,u,pc ; eat stack & return

                  IFNE    H6309
DispatchSetStat     ldf       #D$PSTA   ; get driver entry offset for setstat
                  ELSE
DispatchSetStat     ldb       #D$PSTA   ; get driver entry offset for setstat
                  ENDC
                    lda       R$B,u     ; get function code from caller
                    bne       putkey    ; not SS.OPT, go check buffer load
* SS.OPT SETSTAT
                    ldx       PD.PAU,y  ; get current pause & page
                  IFGT    Level-1
                    pshs      y,x       ; preserve Path pointer & pause/page
                    ldx       <D.Proc   ; get current process pointer
                    lda       P$Task,x  ; get task number
                    ldb       <D.SysTsk ; get system task number
                    ldx       R$X,u     ; get callers destination pointer
                    leau      PD.OPT,y  ; point to path options
                    ldy       #OPTCNT   ; get option length
                    os9       F$Move    ; move it to caller
                    puls      y,x       ; restore Path pointer & page/pause status
                    bcs       SetOptReturn ; return if error from move
                  ELSE
                    pshs      x,y       ; save x,y on stack
                    ldx       R$X,u     ; load x from R$X,u
                    leay      PD.OPT,y  ; compute address PD.OPT,y into y
                    ldb       #OPTCNT   ; load b from #OPTCNT
optloop             lda       ,x+       ; load a from ,x+
                    sta       ,y+       ; store a into ,y+
                    decb                ; decrement b counter
                    bne       optloop   ; branch if comparison was not equal to optloop
                    puls      x,y       ; restore x,y from stack
                  ENDC
                  IFEQ    H6309
                    pshs      x         ; save x on stack
                  ENDC
                    ldd       PD.PAU,y  ; get new page/pause status
                  IFNE    H6309
                    cmpr      d,x       ; same as old?
                  ELSE
                    cmpd      ,s++      ; compare d with ,s++
                  ENDC
                    beq       UpdateComStatus ; yes, go on
                    ldu       PD.DEV,y  ; get device table pointer
                    ldu       V$STAT,u  ; get static storage pointer
                    beq       UpdateComStatus ; go on if none
                    stb       V.LINE,u  ; update new line count
UpdateComStatus     ldx       PD.PAR,y  ; get parity/baud
                    lda       #SS.ComSt ; get code for ComSt
                    pshs      a,x       ; preserve them
                    bsr       CallComStatus ; update parity & baud
                    puls      a,x,pc    ; restore & return

* Update path Parity & baud
CallComStatus       pshs      x,y,u     ; preserve everything
                    ldx       PD.RGS,y  ; get callers register pointer
                    ldu       R$Y,x     ; get his Y
                    lda       R$B,x     ; get his B
                    pshs      a,x,y,u   ; preserve it all
                    ldd       $10,s     ; get current parity/baud
                    std       R$Y,x     ; put it in callers Y
                    lda       $0F,s     ; get function code
                    sta       R$B,x     ; put it in callers B
                    lbsr      TryAcquireDevices ; wait for device to be ready
                    lbsr      SendSetStat ; send it to driver
                    puls      a,x,y,u   ; restore callers registers
                    stu       R$Y,x     ; put back his Y
                    sta       R$B,x     ; put back his B
                    bcc       CallComStatusReturn ; return if no error
                    cmpb      #E$UnkSvc ; unknown service request?
                    beq       CallComStatusReturn ; yes, return
                    coma                ; set carry
CallComStatusReturn puls      x,y,u,pc  ; restore & return

* I$Read entry point
read                lbsr      WaitForDevices ; go wait for device to be ready for us
                    bcc       BeginRawRead ; no error, go on
ReadErrorReturn     rts                 ; return with error

BeginRawRead        inc       PD.RAW,y  ; make sure we do Raw read
                    ldx       R$Y,u     ; get number of characters to read
                    beq       FinishReadPath ; return if zero
                    pshs      x         ; save character count
                    ldx       #0        ; load x from #0
                    ldu       PD.BUF,y  ; get buffer address
                    bsr       ReadDeviceCharacter ; read 1 character from device
                    bcs       FinishReadError ; return if error
                    tsta                ; character read zero?
                    beq       CountRawCharacter ; yes, go try again
                    cmpa      PD.EOF,y  ; end of file character?
                    bne       EchoRawCharacter ; no, keep checking
ReturnEof           ldb       #E$EOF    ; get EOF error code
FinishReadError     leas      2,s       ; purge stack
                    pshs      b         ; save error code
                    bsr       CopyReadBuffer ; return
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
                    lbra      ReturnSuccess ; delete (return no error)
                    lbra      ReturnSuccess ; seek (return no error)
                    bra       read      ; read character
                    nop
                    lbra      write     ; write character
                    lbra      readln    ; readLn
                    lbra      writln    ; writeLn
                    lbra      getstt    ; get Status
                    lbra      setstt    ; set Status
                    lbra      close     ; close path

* MAIN READ LOOP (no editing)
RawReadLoop         tfr       x,d       ; move character count to D
                    tstb                ; past buffer end?
                    bne       ReadRawCharacter ; no, go get character from device
* Not often used: only when buffer is full
                    bsr       CopyBufferToCaller ; move buffer to caller's buffer
                    ldu       PD.BUF,y  ; reset buffer pointer back to start
* Main char by char read loop
ReadRawCharacter    bsr       ReadDeviceCharacter ; get a character from device
                    bcs       FinishReadError ; exit if error
EchoRawCharacter    ldb       PD.EKO,y  ; echo turned on?
                    beq       CountRawCharacter ; no, don't write it to device
                    lbsr      SendCharacter ; send it to device write
CountRawCharacter   ldb       #1        ; bump up char count
                    abx                 ; add b to x for indexed byte advance
                    sta       ,u+       ; save character in local buffer
                    beq       CheckRawReadCount ; go try again if it was a null
                    cmpa      PD.EOR,y  ; end of record charcter?
                    beq       FinishRawRead ; yes, return
CheckRawReadCount   cmpx      ,s        ; done read?
                    blo       RawReadLoop ; no, keep going till we are

FinishRawRead       leas      2,s       ; purge stack
CopyReadBuffer      bsr       CopyBufferToCaller ; move local buffer to caller
                    ldu       PD.RGS,y  ; get register stack pointer
                    stx       R$Y,u     ; save number of characters read
FinishReadPath      bra       ReleaseDevices ; update path descriptor and return

* Read character from device
ReadDeviceCharacter pshs      u,y,x     ; preserve regs
                    ldx       PD.DEV,y  ; get device table pointer for input
                    beq       ReadDeviceReturn ; none, exit
                    ldu       PD.DV2,y  ; get device table pointer for echoed output
                    beq       SelectReadDeviceState ; no echoed output device, skip ahead
LoadEchoDeviceState ldu       V$STAT,u  ; get device static storage ptr for echo device
                    ldb       PD.PAG,y  ; get lines per page
                    stb       V.LINE,u  ; store it in device static
SelectReadDeviceState tfr       u,d       ; yes, move echo device' static storage to D
                    ldu       V$STAT,x  ; get static storage ptr for input
                    std       V.DEV2,u  ; save echo device's static storage into input device
                    clra                ; clear a and carry state for success/zero value
                    sta       V.WAKE,u  ; flag input device to be awake
                  IFGT    Level-1
                    ldx       V$DRIVEX,x ; get driver execution pointer
                  ELSE
                    pshs      d         ; save d on stack
                    ldx       V$DRIV,x  ; get driver module
                    ldd       M$EXEC,x  ; get driver execution pointer
                    leax      d,x       ; compute address d,x into x
                    puls      d         ; restore d from stack
                  ENDC
                    jsr       D$READ,x  ; execute READ routine in driver
ReadDeviceReturn    puls      pc,u,y,x  ; restore regs & return

* Move buffer to caller
* Entry: Y=Path dsc. ptr
*        X=# chars to move
CopyBufferToCaller  pshs      y,x       ; preserve path dsc. ptr & char. count
                    ldd       ,s        ; get # bytes to move
                    beq       CopyBufferReturn ; exit if none
                    tstb                ; uneven # bytes (not even page of 256)?
                    bne       AlignCallerBuffer ; yes, go on
                    deca                ; >256, so bump MSB down
AlignCallerBuffer   clrb                ; force to even page
                    ldu       PD.RGS,y  ; get callers register stack pointer
                    ldu       R$X,u     ; get ptr to caller's buffer
                  IFNE    H6309
                    addr      d,u       ; offset to even page into buffer
                    clre                ; clear MSB of count
                    ldf       1,s       ; lSB of count on even page?
                    bne       SetCallerCopyCount ; no, go on
                    ince                ; make it even 256
SetCallerCopyCount
                  IFGT    Level-1
                    lda       <D.SysTsk ; get source task number
                  ENDC
                  ELSE
                    leau      d,u       ; compute address d,u into u
                    clra                ; clear a and carry state for success/zero value
                    ldb       1,s       ; load b from 1,s
                    bne       SetCallerCopyCount ; no, go on
                    inca                ; advance a counter
SetCallerCopyCount  pshs      d         ; save d on stack
                  IFGT    Level-1
                    lda       <D.SysTsk ; get source task number
                  ENDC
                  ENDC
                  IFGT    Level-1
                    ldx       <D.Proc   ; get destination task number
                    ldb       P$Task,x  ; load b from P$Task,x
                    ldx       PD.BUF,y  ; get buffer pointer
                  IFNE    H6309
                    tfr       w,y       ; put count into proper register
                  ELSE
                    puls      y         ; restore y from stack
                  ENDC
                    os9       F$Move    ; move it to caller
                  ELSE
                    ldx       PD.BUF,y  ; get buffer pointer
                  IFEQ    H6309
                    puls      y         ; restore y from stack
                  ELSE
                    tfr       w,y       ; transfer w,y
                  ENDC
                    pshs      u         ; save u on stack
CopyCallerBufferLoop lda       ,x+       ; load a from ,x+
                    sta       ,u+       ; store a into ,u+
                    leay      -1,y      ; compute address -1,y into y
                    bne       CopyCallerBufferLoop ; branch if comparison was not equal to CopyCallerBufferLoop
                    puls      u         ; restore u from stack
                  ENDC
CopyBufferReturn    puls      pc,y,x    ; restore & return

* I$ReadLn entry point
readln              bsr       WaitForDevices ; go wait for device to be ready for us
                    bcc       BeginReadLine ; no error, continue
                    rts                 ; error, exit with it

BeginReadLine       ldd       R$Y,u     ; get character count
                    beq       ReleaseDevices ; if none, mark device as un-busy
                    tsta                ; past 256 bytes?
                    beq       SetReadLineLimit ; no, go on
                    ldd       #$0100    ; get new character count
SetReadLineLimit    pshs      d         ; save character count
                    ldd       #$FFFF    ; get maximum character count
                    std       PD.MAX,y  ; store it in path descriptor
                    ldx       #0        ; set character count so far to 0
                    ldu       PD.BUF,y  ; get buffer ptr
                    lbra      ReadLineLoop ; go process readln

* Wait for device - Clears out V.BUSY if either Default or output devices are
* no longer busy
* Modifies X and A
ReleaseDevices
                  IFGT    Level-1
                    ldx       <D.Proc   ; get current process
                  ELSE
                    ldx       >D.Proc   ; get current process
                  ENDC
                    lda       P$ID,x    ; get it's process ID
                    ldx       PD.DEV,y  ; get device table pointer from our path dsc.
                    bsr       ReleaseDeviceIfOwned ; check if it's busy
                    ldx       PD.DV2,y  ; get output device table pointer
ReleaseDeviceIfOwned beq       ReleaseDeviceReturn ; doesn't exist, exit
                    ldx       V$STAT,x  ; get static storage pointer for our device
                    cmpa      V.BUSY,x  ; same process as current process?
                    bne       ReleaseDeviceReturn ; no, device busy return
                    clra                ; clear a and carry state for success/zero value
                    sta       V.BUSY,x  ; yes, mark device as free for use
ReleaseDeviceReturn rts                 ; return

AcquireDevice       pshs      x,a       ; preserve device table entry pointer & process ID
CheckDeviceBusy     ldx       V$STAT,x  ; get device static storage address
                    ldb       V.BUSY,x  ; get active process ID
                    beq       ReserveDevice ; no active process, device not busy go reserve it
                    cmpb      ,s        ; is it our own process?
                    beq       AcquireDeviceSuccess ; yes, return without error
                    bsr       ReleaseDevices ; go wait for device to no longer be busy
                    tfr       b,a       ; get process # busy using device
                    os9       F$IOQu    ; put our process into the IO Queue
                    inc       PD.MIN,y  ; mark device as not mine
                  IFGT    Level-1
                    ldx       <D.Proc   ; get current process
                  ELSE
                    ldx       >D.Proc   ; get current process
                  ENDC
                    ldb       P$Signal,x ; get signal code
                    lda       ,s        ; get our process id # again for CheckDeviceBusy
                    beq       CheckDeviceBusy ; no signal go try again
                    coma                ; set carry
                    puls      x,a,pc    ; restore device table ptr (eat a) & return

* Mark device as busy;copy pause/interrupt/quit/xon/xoff chars into static mem
ReserveDevice       sta       V.BUSY,x  ; make it as process # busy on this device
                    sta       V.LPRC,x  ; save it as the last process to use device
                    lda       PD.PSC,y  ; get pause character from path dsc.
                    sta       V.PCHR,x  ; save copy in static storage (faster later)
                    ldd       PD.INT,y  ; get keyboard interrupt & quit chars
                    std       V.INTR,x  ; save copies in static mem
                    ldd       PD.XON,y  ; get XON/XOFF chars
                    std       V.XON,x   ; save them in static mem too
AcquireDeviceSuccess clra                ; no error & return
                    puls      pc,x,a    ; restore A=Process #,X=Dev table entry ptr

* Wait for device?
WaitForDevices      lda       PD.PST,y  ; get path status (carrier)
                    bne       HandleHangup ; if carrier was lost, hang up process
TryAcquireDevices
                  IFGT    Level-1
                    ldx       <D.Proc   ; get current process ID
                  ELSE
                    ldx       >D.Proc   ; get current process ID
                  ENDC
                    clra                ; clear a and carry state for success/zero value
                    sta       PD.MIN,y  ; flag device is mine
                    lda       P$ID,x    ; get process ID #
                    ldx       PD.DEV,y  ; get device table pointer
                    bsr       AcquireDevice ; busy?
                    bcs       WaitForDeviceReturn ; no, return
                    ldx       PD.DV2,y  ; get output device table pointer
                    beq       CheckDevicesAcquired ; go on if it doesn't exist
                    bsr       AcquireDevice ; busy?
                    bcs       WaitForDeviceReturn ; no, return
CheckDevicesAcquired lda       PD.MIN,y  ; device mine?
                    bne       WaitForDevices ; no, go wait for it
                    sta       PD.RAW,y  ; mark device with editing
WaitForDeviceReturn ldu       PD.RGS,y  ; get register stack pointer
                    rts                 ; return

* Hangup process
HandleHangup        leas      2,s       ; purge return address
ReportHangup        ldb       #E$HangUp ; get hangup error code
                    cmpa      #S$Abort  ; termination signal (or carrier lost)?
                    blo       MarkPathHungUp ; yes, increment status flag & return
                    lda       PD.CPR,y  ; get current process ID # using path
                    ldb       #S$Kill   ; get kill signal
                    os9       F$Send    ; send it to process
MarkPathHungUp      inc       PD.PST,y  ; set path status
                    orcc      #Carry    ; set carry
                    rts                 ; return

* I$WritLn entry point
writln              bsr       WaitForDevices ; go wait for device to be ready for us
                    bra       StartWrite ; go write

* I$Write entry point
write               bsr       WaitForDevices ; go wait for device to be ready for us
                    inc       PD.RAW,y  ; mark device for raw write
StartWrite          ldx       R$Y,u     ; get number of characters to write
                    lbeq      FinishWritePath ; zero so return
                    pshs      x         ; save character count
                    ldx       #$0000    ; get write data offset
                    bra       RefillWriteBuffer ; go write data

ContinueWriteBuffer tfr       u,d       ; move current position in PD.BUF to D
                    tstb                ; at 256 (end of PD.BUF)?
                    bne       ProcessWriteBuffer ; no, keep writing from current PD.BUF

* Get new block of data to write into [PD.BUF]
* Only allows up to 32 bytes at a time, and puts them in the last 32 bytes of
* the 256 byte [PD.BUF] buffer. This way, can use TFR U,D/TSTB to see if fin-
* ished.
* NOTE: 32 bytes max for 6809, to keep "lockout" of grfdrv down to less CPU time
RefillWriteBuffer   pshs      y,x       ; save write offset & path descriptor pointer
                    tfr       x,d       ; move data offset to D
                    ldu       PD.RGS,y  ; get register stack pointer
                    ldx       R$X,u     ; get pointer to user's WRITE string
                  IFNE    H6309
                    addr      d,x       ; point to where we are in it now
                    ldw       R$Y,u     ; get # chars of original write
                    subr      d,w       ; calculate # chars we have left to write
                    cmpw      #64       ; more than 64?
                    bls       PrepareWriteChunk ; no, go on
                    ldw       #64       ; max size per chunk 6309=64
PrepareWriteChunk   ldd       PD.BUF,y  ; get buffer ptr
                    inca                ; point to PD.BUF+256 (1 byte past end
                    subr      w,d       ; subtract data size
                  ELSE
                    leax      d,x       ; point to where we are in it now
                    ldd       R$Y,u     ; get # chars of original write
                    subd      ,s        ; calculate # chars we have left to write
                    cmpd      #32       ; more than 32?
                    bls       PrepareWriteChunk ; no, go on
                    ldd       #32       ; max size per chunk 6809=32
PrepareWriteChunk   pshs      d         ; save buffered chunk size on stack
                    ldd       PD.BUF,y  ; get buffer ptr
                    inca                ; point to PD.BUF+256 (1 byte past end)
                    subd      ,s        ; subtract data size
                  ENDC
                    tfr       d,u       ; move it to U
                    lda       #C$CR     ; put a carriage return 1 byte before start
                    sta       -1,u      ; of write portion of buffer
                  IFGT    Level-1
                    ldy       <D.Proc   ; get current process pointer
                    lda       P$Task,y  ; get the task number
                    ldb       <D.SysTsk ; get system task number
                  IFNE    H6309
                    tfr       w,y       ; get number of bytes to move
                  ELSE
                    puls      y         ; restore y from stack
                  ENDC
                    os9       F$Move    ; move data to buffer
                  ELSE
                  IFNE    H6309
                    pshs      u         ; move data to buffer (level 1)
                    tfm       x+,u+     ; transfer memory block x+,u+
                    puls      u         ; restore u from stack
                  ELSE
                    puls      y         ; move data to buffer (level 1)
                    pshs      u         ; save u on stack
CopyWriteChunk      lda       ,x+       ; load a from ,x+
                    sta       ,u+       ; store a into ,u+
                    leay      -1,y      ; compute address -1,y into y
                    bne       CopyWriteChunk ; branch if comparison was not equal to CopyWriteChunk
                    puls      u         ; restore u from stack
                  ENDC
                  ENDC
                    puls      y,x       ; restore path descriptor pointer and data offset

* at this point, we have
* 0,s = end address of characters to write
* X = number of characters written
* Y = PD pointer
* U = pointer to data buffer to write
* Level 2: Use callcode $06 to call grfdrv (old DWProtSW from previous versions,
*   now unused by GrfDrv
ProcessWriteBuffer
                  IFGT    Level-1
                    ldb       PD.PAR,y  ; get device parity: bit 7 set = window
                    cmpb      #$80      ; is it even potentially a CoWin window?
                    bne       WriteNextCharacter ; no, skip the rest of the crap
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
                    bsr       ForceUppercase ; do a lower-uppercase conversion, if necessary
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
                    bra       CheckWriteComplete ; do end-buffer checks and continue

no.wptr             puls      b,x,y,u   ; restore all registers
                  ENDC
WriteNextCharacter  lda       ,u+       ; get character to write
                    ldb       PD.RAW,y  ; raw mode?
                    bne       WriteCharacter ; yes, go write it
                    ldb       PD.UPC,y  ; force uppercase?
                    beq       HandleLineFeed ; no, continue
                    bsr       ForceUppercase ; make it uppercase
HandleLineFeed      cmpa      #C$LF     ; is it a Line feed?
                    bne       WriteCharacter ; no, go print it
                    lda       #C$CR     ; get code for carriage return
                    ldb       PD.ALF,y  ; auto Line feed?
                    bne       WriteCharacter ; yes, go print carriage return first
                    bsr       WriteCharacterPaged ; print carriage return
                    bcs       HandleWriteError ; if error, go wait for device
                    lda       #C$LF     ; now, print the line feed

* Write character to device (call driver)
WriteCharacter      bsr       WriteCharacterPaged ; go write it to device
                    bcs       HandleWriteError ; if error, go wait for device
                    ldb       #1        ; bump up # chars we have written
                    abx                 ; add b to x for indexed byte advance
CheckWriteComplete  cmpx      ,s        ; done whole WRITE call?
                    bhs       FinishWrite ; yes, go save # chars written & exit
                    ldb       PD.RAW,y  ; raw mode?
                    lbne      ContinueWriteBuffer ; yes, keep writing
                    lda       -1,u      ; get the char we wrote
                    lbeq      ContinueWriteBuffer ; nUL, keep writing
                    cmpa      PD.EOR,y  ; end of record?
                    lbne      ContinueWriteBuffer ; no, keep writing
FinishWrite         leas      2,s       ; eof record, stop & Eat end of buffer ptr???
SaveWriteCount      ldu       PD.RGS,y  ; get callers register pointer
                    stx       R$Y,u     ; save character count to callers Y
FinishWritePath     lbra      ReleaseDevices ; mark device write clear and return

* Check for forced uppercase
ForceUppercase      cmpa      #'a       ; less then 'a'?
                    blo       ForceUppercaseReturn ; yes, leave it
                    cmpa      #'z       ; higher than 'z'?
                    bhi       ForceUppercaseReturn ; yes, leave it
                    suba      #$20      ; make it uppercase
ForceUppercaseReturn rts                 ; return

HandleWriteError    leas      2,s       ; purge stack
                    pshs      b,cc      ; preserve registers
                    bsr       SaveWriteCount ; wait for device
                    puls      pc,b,cc   ; restore & return

* Check for end of page (part of send char to driver)
WriteCharacterPaged pshs      u,y,x,a   ; preserve registers
                    ldx       PD.DEV,y  ; get device table pointer
                    cmpa      #C$CR     ; carriage return?
                    bne       CallDeviceWrite ; no, go print it
                    ldu       V$STAT,x  ; get pointer to device stactic storage
                    ldb       V.PAUS,u  ; pause request?
                    bne       WaitForPauseCharacter ; yes, go pause device
                    ldb       PD.RAW,y  ; raw output mode?
                    bne       HandleCarriageReturn ; yes, go on
                    ldb       PD.PAU,y  ; end of page pause enabled?
                    beq       HandleCarriageReturn ; no, go on
                    dec       V.LINE,u  ; subtract a line
                    bne       HandleCarriageReturn ; not done, go on
                    ldb       #$ff      ; do a immediate pause request
                    stb       V.PAUS,u  ; store b into V.PAUS,u
                    bra       ResumeAfterPause ; go read next character

ReadPauseCharacter  pshs      u,y,x     ; preserve registers
                    ldx       PD.DV2,y  ; get output device table pointer
                    beq       NoOut     ; none, exit
                    ldu       PD.DEV,y  ; get device table pointer
                    lbra      LoadEchoDeviceState ; process & return

NoOut               puls      pc,u,y,x  ; no output device so exit

* Wait for pause release
WaitForPauseCharacter bsr       ReadPauseCharacter ; read next character
                    bcs       ResumeAfterPause ; error, try again
                    cmpa      PD.PSC,y  ; pause char?
                    bne       WaitForPauseCharacter ; no, try again
ResumeAfterPause    bsr       ReadPauseCharacter ; reset line count and read a character
                    cmpa      PD.PSC,y  ; pause character?
                    beq       ResumeAfterPause ; yes, go read again
* Process Carriage return - do auto linefeed & Null's if necessary
* Entry: A=CHR$($0D)
HandleCarriageReturn ldu       V$STAT,x  ; get static storage pointer
                    clra                ; clear a and carry state for success/zero value
                    sta       V.PAUS,u  ; clear pause request
                    lda       #C$CR     ; carriage return (in cases from pause)
                    bsr       CallWriteDriver ; send it to driver
                    lda       PD.RAW,y  ; raw mode?
                    bne       ReturnFromCrHandling ; yes, return
                    ldb       PD.NUL,y  ; get end of line null count
                    pshs      b         ; save it
                    lda       PD.ALF,y  ; auto line feed enabled?
                    beq       WriteNullPadding ; no, go on
                    lda       #C$LF     ; get line feed code
WriteCrFollowup     bsr       CallWriteDriver ; execute driver write routine
                    bcs       FinishCrHandling ; error, purge stack and return
WriteNullPadding    clra                ; get null character
                    dec       ,s        ; done null count?
                    bpl       WriteCrFollowup ; no, go send it to driver
                    clra                ; clear carry
FinishCrHandling    leas      1,s       ; purge stack
ReturnFromCrHandling puls      pc,u,y,x,a ; restore & return

* Execute device driver write routine
* Entry: A=Character to write
* Execute device driver
* Entry: W=Entry offset (for type of function, ex. Write, Read)
*        A=Code to send to driver
CallWriteDriver     ldu       V$STAT,x  ; get device static storage pointer
                    pshs      y,x       ; preserve registers
                    clrb                ; clear b and carry state for success/zero value
                    stb       V.WAKE,u  ; wake it up
                  IFGT    Level-1
                    ldx       V$DRIVEX,x ; get driver execution pointer
                  ELSE
                    pshs      d         ; save d on stack
                    ldx       V$DRIV,x  ; get driver execution pointer
                    ldd       M$EXEC,x  ; load d from M$EXEC,x
                    leax      d,x       ; compute address d,x into x
                    puls      d         ; restore d from stack
                  ENDC
                    jsr       D$WRIT,x  ; execute driver
                    puls      pc,y,x    ; restore & return

* Send character to driver
SendCharacter       pshs      u,y,x,a   ; preserve registers
                    ldx       PD.DV2,y  ; get output device table pointer
                    beq       SendCharacterReturn ; return if none
                    cmpa      #C$CR     ; carriage return?
                    beq       HandleCarriageReturn ; yes, go process it
CallDeviceWrite     ldu       V$STAT,x  ; get device static storage pointer
                    clrb                ; clear b and carry state for success/zero value
                    stb       V.WAKE,u  ; wake it up
                  IFGT    Level-1
                    ldx       V$DRIVEX,x ; get driver execution pointer
                  ELSE
                    pshs      d         ; save d on stack
                    ldx       V$DRIV,x  ; get driver module
                    ldd       M$EXEC,x  ; load d from M$EXEC,x
                    leax      d,x       ; compute address d,x into x
                    puls      d         ; restore d from stack
                  ENDC
                    jsr       D$WRIT,x  ; execute driver
SendCharacterReturn puls      pc,u,y,x,a ; restore & return


* Check for printable character (Entry: A=char to echo)
EchoCharacter       ldb       PD.EKO,y  ; echo turned on?
                    bne       EchoPrintableCharacter ; yes, go do
                    rts                 ; no, just return

EchoPrintableCharacter cmpa      #C$SPAC   ; cHR$(32) or higher?
                    bhs       SendCharacter ; yes, go send to driver
                    cmpa      #C$CR     ; ctrl char
                    beq       SendCharacter ; yes, send it to the driver
* Any ctrl char <> CR, replace with period when echoed to device
EchoControlAsPeriod pshs      a         ; save code
                    lda       #'.       ; get code for period
                    bsr       SendCharacter ; output it to device
                    puls      pc,a      ; restore original ctrl char & return

EchoReadLineCharacter bsr       EchoPrintableCharacter ; check if it's printable and send it to driver
* Process ReadLn
ReadLineLoop        lbsr      ReadDeviceCharacter ; get a character from device
                    lbcs      HandlePauseCharacter ; return if error
                    tsta                ; usable character?
                    lbeq      ProcessReadLineCharacter ; no, check path descriptor special characters
                    ldb       PD.RPR,y  ; get reprint line code
                    cmpb      #C$RPRT   ; cntrl D?
                    lbeq      ProcessReadLineCharacter ; yes, check path descriptor special characters
                    cmpa      PD.RPR,y  ; reprint line?
                    bne       CheckPrintRest ; no, Check line editor keys
                    cmpx      PD.MAX,y  ; character count at maximum?
                    beq       ReadLineLoop ; yes, go read next character
                    ldb       #1        ; bump char count up by 1
                    abx                 ; add b to x for indexed byte advance
                    cmpx      ,s        ; done?
                    bhs       RemoveLastReadLineChar ; yes, exit
                    lda       ,u+       ; get character read
                    beq       EchoReadLineCharacter ; null, go send it to driver
                    cmpa      PD.EOR,y  ; end of record character?
                    bne       EchoReadLineCharacter ; no, go send it to driver
                    leau      -1,u      ; bump buffer pointer back 1
RemoveLastReadLineChar leax      -1,x      ; bump character count back 1
                    bra       ReadLineLoop ; go read next character

CheckPrintRest      cmpa      #C$PLINE  ; print rest of line code?
                    bne       CheckInsertCharacter ; no, check insert
* Process print rest of line
ReprintLine         pshs      u         ; save buffer pointer
                    lbsr      ReprintLineLoop ; go print rest of line
                    lda       PD.BSE,y  ; get backspace echo character
EraseReprintedCharacterLoop cmpu      ,s        ; beginning of buffer?
                    beq       FinishReprint ; yes, exit
                    leau      -1,u      ; bump buffer pointer back 1
                    leax      -1,x      ; bump character count back 1
                    bsr       SendCharacter ; print it
                    bra       EraseReprintedCharacterLoop ; keep going

FinishReprint       leas      2,s       ; purge buffer pointer
                    bra       ReadLineLoop ; return

CheckInsertCharacter cmpa      #C$INSERT ; insert character code?
                    bne       CheckDeleteCharacter ; no, check delete
* Process Insert character (NOTE:Currently destroys W)
                  IFNE    H6309
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
                  ELSE
                    pshs      u         ; save u on stack
                    tfr       u,d       ; move buffer ptr to D
                    ldb       #$FF      ; point to end of buffer
                    tfr       d,u       ; move back to U
ShiftBufferForInsert lda       ,-u       ; shift buffer later by 1 char
                    sta       1,u       ; store a into 1,u
                    cmpu      ,s        ; compare u with ,s
                    bne       ShiftBufferForInsert ; branch if comparison was not equal to ShiftBufferForInsert
                    lda       #C$SPAC   ; insert space at insert point in buffer
                    sta       ,u        ; store a into ,u
                    leas      2,s       ; adjust stack pointer by 2,s
                  ENDC
                    bra       ReprintLine ; go print rest of line

CheckDeleteCharacter cmpa      #C$DELETE ; delete character code?
                    bne       CheckDeleteLine ; no, check end of line
* Process delete line
                    pshs      u         ; save buffer pointer
                    lda       ,u        ; get character there
                    cmpa      PD.EOR,y  ; end of record?
                    beq       RestoreEditBuffer ; yes, don't bother to delete it
ShiftBufferForDelete lda       1,u       ; get character beside it
                    cmpa      PD.EOR,y  ; this an end of record?
                    beq       FillDeletedTail ; yes, delete it
                    sta       ,u+       ; bump character back
                    bra       ShiftBufferForDelete ; go do next character

FillDeletedTail     lda       #C$SPAC   ; get code for space
                    cmpa      ,u        ; already there?
                    bne       StoreDeletedTail ; no, put it in
                    lda       PD.EOR,y  ; get end of record code
StoreDeletedTail    sta       ,u        ; put it there
RestoreEditBuffer   puls      u         ; restore buffer pointer
                    bra       ReprintLine ; go print rest of line

* Delete rest of buffer
CheckDeleteLine     cmpa      PD.EOR,y  ; end of record code? (normally CR)
                    bne       ProcessReadLineCharacter ; no, check for special path dsc. chars
* CR hit, replace rest of buffer with spaces?
                    pshs      u         ; yes, Save buffer pointer
                    bra       DeleteLineLoop ; go erase rest of buffer

EchoDeleteLineTerminator pshs      a         ; save CR code
                    lda       #C$SPAC   ; get code for space
                    lbsr      SendCharacter ; print it
                    puls      a         ; restore CR code
DeleteLineLoop      cmpa      ,u+       ; end of record?
                    bne       EchoDeleteLineTerminator ; no, go print a space
                    puls      u         ; restore buffer pointer
* Check character read against path descriptor
ProcessReadLineCharacter tsta                ; usable character?
                    beq       UpdateMaxReadLineLength ; no, go on
                    ldb       #PD.BSP   ; get start point in path descriptor
MatchEditCharacter  cmpa      b,y       ; match code in descriptor?
                    beq       DispatchEditCharacter ; yes, go process it
                    incb                ; move to next one
                    cmpb      #PD.QUT   ; done check?
                    bls       MatchEditCharacter ; no, keep going
UpdateMaxReadLineLength cmpx      PD.MAX,y  ; past maximum character count?
                    bls       AdvanceReadLineBuffer ; no, go on
                    stx       PD.MAX,y  ; update maximum character count
AdvanceReadLineBuffer ldb       #1        ; add 1 char
                    abx                 ; add b to x for indexed byte advance
                    cmpx      ,s        ; past requested amount?
                    blo       ApplyReadLineUppercase ; no, go on
                    lda       PD.OVF,y  ; get overflow character
                    lbsr      SendCharacter ; send it to driver
                    leax      -1,x      ; subtract a character
                    lbra      ReadLineLoop ; go try again

ApplyReadLineUppercase ldb       PD.UPC,y  ; force uppercase?
                    beq       StoreReadLineCharacter ; no, put char in buffer
                    lbsr      ForceUppercase ; make character uppercase
StoreReadLineCharacter sta       ,u+       ; put character in buffer
                    lbsr      EchoCharacter ; check for printable
                    lbra      ReadLineLoop ; go try again

* Process path option characters
DispatchEditCharacter pshs      x,pc      ; preserve character count & PC
                    leax      <HandleBackspaceVector,pc ; point to branch table
                    subb      #PD.BSP   ; subtract off first code
                    lslb                Account ; for 2 bytes a entry
                    abx                 ; point to entry point
                    stx       2,s       ; save it in PC on stack
                    puls      x         ; restore X
C8E3                jsr       [,s++]    ; execute routine
                    lbra      ReadLineLoop ; continue on

* Vector points for PD.BSP-PD.QUT
HandleBackspaceVector bra       HandleBackspace ; process PD.BSP
                    bra       ClearCurrentLine ; process PD.DEL
                    bra       HandleEndOfRecord ; process PD.EOR
                    bra       HandleEndOfFile ; process PD.EOF
                    bra       HandleReprintLine ; process PD.RPR
                    bra       ReprintLineLoop ; process PD.DUP
                    rts                 ; pD.PSC we don't worry about
                    nop
                    bra       ClearCurrentLine ; process PD.INT
                    bra       ClearCurrentLine ; process PD.QUT

* Process PD.EOR character
HandleEndOfRecord   leas      2,s       ; purge return address
                    sta       ,u        ; save character in buffer
                    lbsr      EchoCharacter ; call distant local routine EchoCharacter
                    ldu       PD.RGS,y  ; get callers register stack pointer
                    ldb       #1        ; bump up char count by 1
                    abx                 ; add b to x for indexed byte advance
                    stx       R$Y,u     ; store it in callers Y
                    lbsr      CopyBufferToCaller ; call distant local routine CopyBufferToCaller
                    leas      2,s       ; adjust stack pointer by 2,s
                    lbra      ReleaseDevices ; long branch unconditionally to ReleaseDevices

* Process PD.EOF
HandleEndOfFile     leas      2,s       ; purge return address
                    leax      ,x        ; read anything?
                    lbeq      ReturnEof ; long branch if comparison was equal to ReturnEof
                    bra       UpdateMaxReadLineLength ; branch unconditionally to UpdateMaxReadLineLength

HandlePauseCharacter pshs      b         ; save b on stack
                    lda       #C$CR     ; load a from #C$CR
                    sta       ,u        ; store a into ,u
                    lbsr      SendCharacter ; send it to the driver
                    puls      b         ; restore b from stack
                    lbra      FinishReadError ; long branch unconditionally to FinishReadError

* Process PD.RPR
HandleReprintLine   lda       PD.EOR,y  ; get end of record character
                    sta       ,u        ; put it in buffer
                    ldx       #0        ; load x from #0
                    ldu       PD.BUF,y  ; get buffer ptr
EchoReprintCharacter lbsr      EchoPrintableCharacter ; send it to driver
ReprintLineLoop     cmpx      PD.MAX,y  ; character maximum?
                    beq       ReturnFromLineEdit ; yes, return
                    ldb       #1        ; bump char count up by 1
                    abx                 ; add b to x for indexed byte advance
                    cmpx      2,s       ; done count?
                    bhs       BackUpReprintPosition ; yes, exit
                    lda       ,u+       ; get character from buffer
                    beq       EchoReprintCharacter ; null, go send it
                    cmpa      PD.EOR,y  ; done line?
                    bne       EchoReprintCharacter ; no go send it
                    leau      -1,u      ; move back a character
BackUpReprintPosition leax      -1,x      ; move character count back
ReturnFromLineEdit  rts                 ; return

DeleteCurrentLine   bsr       ErasePreviousCharacter ; erase one character while deleting the current line
* PD.DEL/PD.QUT/PD.INT processing
ClearCurrentLine    leax      ,x        ; any characters?
                    beq       ResetReadLineBuffer ; no, reset buffer ptr
                    ldb       PD.DLO,y  ; backspace over line?
                    beq       DeleteCurrentLine ; yes, go do it
                    ldb       PD.EKO,y  ; echo character?
                    beq       ResetReadLineCount ; no, zero out buffer pointers & return
                    lda       #C$CR     ; send CR to the driver
                    lbsr      SendCharacter ; send it to driver
ResetReadLineCount  ldx       #0        ; zero out count
ResetReadLineBuffer ldu       PD.BUF,y  ; reset buffer pointer
LineEditReturn      rts                 ; return

* Process PD.BSP
HandleBackspace     leax      ,x        ; any characters?
                    beq       ReturnFromLineEdit ; no, return
ErasePreviousCharacter leau      -1,u      ; mover buffer pointer back 1 character
                    leax      -1,x      ; move character count back 1
                    ldb       PD.EKO,y  ; echoing characters?
                    beq       LineEditReturn ; no, return
                    ldb       PD.BSO,y  ; which backspace method?
                    beq       EchoBackspace ; use BSE
                    bsr       EchoBackspace ; do a BSE
                    lda       #C$SPAC   ; get code for space
                    lbsr      SendCharacter ; send it to driver
EchoBackspace       lda       PD.BSE,y  ; get BSE
                    lbra      SendCharacter ; send it to driver

                  IFGT    Level-1
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
                  IFNE    H6309
                    pshs      cc        ; save old CC
                  ELSE
                    tfr       cc,a      ; transfer cc,a
                    sta       -2,x      ; store a into -2,x
                  ENDC
                    orcc      #IntMasks+Entire ; shut everything else off
                  IFNE    H6309
                    clra                ; make sure high byte=0
                    tfr       d,w       ; transfer d,w
                    tfm       u+,x+     ; move the data into low memory
                  ELSE
l@                  lda       ,u+       ; load a from ,u+
                    sta       ,x+       ; store a into ,x+
                    decb                ; decrement b counter
                    bne       l@        ; branch if comparison was not equal to l@
                  ENDC
                    ldb       #6        ; alpha put
                    stb       >WGlobal+G.GfBusy ; flag grfdrv busy
                  IFNE    H6309
                    lde       ,s+       ; grab old CC off of the stack
                    lda       1,s       ; get the number of characters to write
                  ELSE
                    lda       1,s       ; get the number of characters to write
                  ENDC
* A = number of bytes at $0180 to write out...
                    bsr       do.grf    ; do the call
* ignore errors : none possible from this particular call
call.out            puls      d,x,y,u,pc ; and return

* this routine should always be called by a BSR, and grfdrv will use the
* PC saved on-stack to return to the calling routine.
* ALL REGISTERS WILL BE TRASHED
do.grf              sts       >WGlobal+G.GrfStk ; stack pointer for GrfDrv
                    lds       <D.CCStk  ; get new stack pointer
                  IFNE    H6309
                    pshs      dp,x,y,u,pc ; save dp,x,y,u,pc on stack
                    pshsw     ;         save 6309 w register on stack
                    pshs      cc,d      ; save all registers
                  ELSE
                    pshs      dp,cc,d,x,y,u,pc ; save dp,cc,d,x,y,u,pc on stack
                  ENDC
                    ldx       >WGlobal+G.GrfEnt ; get GrfDrv entry address
                    stx       R$PC,s    ; save grfdrv entry address as PC on the stack
                  IFNE    H6309
                    ste       R$CC,s    ; save CC onto CC on the stack
                  ELSE
                    stb       R$B,s     ; store b into R$B,s
                    ldb       $017E     ; load b from $017E
                    stb       R$CC,s    ; store b into R$CC,s
                  ENDC
                    jmp       [>D.Flip1] ; flip to grfdrv and execute it
                  ENDC

                    emod      ;         end the OS-9 module body
eom                 equ       *         ; define constant eom
                    end       ;         end assembler source
