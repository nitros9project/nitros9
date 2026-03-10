********************************************************************
* VTIO - Minimal Video Terminal I/O Driver for Pico-Thing
*
* Stripped-down VTIO that loads and dispatches to the CoPico
* co-module. No PIA keyboard scanning, no joystick, no sound
* driver. Keyboard input arrives from the Graphics Pico via
* UART and is placed into the input buffer by the ISR.
*
* This driver acts as the SCF-level device driver for the
* graphical console. It triages Write calls (printable chars,
* ESC sequences, control codes) and dispatches them to the
* CoPico co-module for rendering on the Graphics Pico.
*
* Static memory layout (V.* per-device) and global memory
* layout (G.* at WGlobal) are defined in cocovtio.d.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2025       Initial skeleton for Pico-Thing

                    nam       VTIO
                    ttl       Minimal Video Terminal I/O Driver for Pico-Thing

                  IFP1
                    use       defsfile
                    use       cocovtio.d
                  ENDC

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       0
edition             set       1

                    mod       eom,name,tylg,atrv,start,CC3DSiz

                    fcb       EXEC.+UPDAT.

name                fcs       /VTIO/
                    fcb       edition

* SCF driver entry table
start               lbra      Init
                    lbra      Read
                    bra       Write
                    nop
                    lbra      GetStat
                    lbra      SetStat
                    lbra      Term

*------------------------------------------------------------
* Write
*
* Entry: A = character to write
*        Y = path descriptor pointer
*        U = device static memory pointer
* Exit:  CC = carry set on error, B = error code
*
Write               ldb       <V.ParmCnt,u collecting escape parameters?
                    bne       PrmCol    yes, go collect next byte
                    sta       <V.DevPar,u save character
                    cmpa      #C$SPAC   printable? (space or above)
                    bhs       CoWrit    yes, send to co-module
                    cmpa      #$1B      escape?
                    beq       DoEsc     yes, start collecting params
                    cmpa      #$05      cursor on/off?
                    beq       DoEsc     yes, needs a parameter
                    cmpa      #C$BELL   bell?
                    beq       DoBell    handle locally
* all other control codes go to co-module
CoWrit              ldb       #CoWrite  $03
CallCo              lda       <V.DevPar,u get saved character
                    ldx       <D.CCMem  get global memory pointer
                    stu       G.CurDvM,x save current device pointer
                    pshs      a         save parameter
                    leax      <G.CoTble,x point to co-module table
                    lda       <V.WinType,u get window type
                    ldx       a,x       get co-module entry vector
                    puls      a         restore parameter
                    beq       ErrMNF    no co-module linked
                    leax      b,x       index to entry point
                    jsr       ,x        call co-module
                    rts

ErrMNF              comb
                    ldb       #E$MNF
                    rts

* bell - just pass to co-module for now
DoBell              bra       CoWrit

* start escape sequence collection
DoEsc               leax      <CoWrit,pcr return vector after params collected
                    ldb       #$01      need 1 parameter byte
                    stx       <V.ParmVct,u save return vector
                    stb       <V.ParmCnt,u save count
                    clrb
                    rts

* collect escape parameter bytes
PrmCol              ldx       <V.NxtPrm,u get next param storage pointer
                    sta       ,x+       store byte
                    stx       <V.NxtPrm,u update pointer
                    decb                decrement count
                    stb       <V.ParmCnt,u save it
                    bne       PrmDone   more bytes needed
* all parameters collected, dispatch to co-module
                    ldx       <V.PrmStrt,u reset next pointer
                    stx       <V.NxtPrm,u
                    jsr       [<V.ParmVct,u] call the handler
                    rts
PrmDone             clrb
                    rts

*------------------------------------------------------------
* Read
*
* Read a character from the keyboard input buffer.
* The buffer is filled by the ISR (keyboard events from
* the Graphics Pico arrive via UART).
*
* Entry: Y = path descriptor pointer
*        U = device static memory pointer
* Exit:  A = character, carry clear
*        or carry set, B = E$NotRdy
*
Read                lda       <V.SSigID,u signal-on-data-ready set?
                    bne       NotReady  yes, return not ready
                    leax      >ReadBuf,u point to input buffer
                    ldb       <V.InpPtr,u get input pointer
                    cmpb      <V.EndPtr,u same as end pointer?
                    beq       NotReady  yes, buffer empty
                    abx                 index into buffer
                    lda       ,x        get character
                    incb                advance pointer
                    stb       <V.InpPtr,u save it
                    clrb                no error
                    rts

NotReady            comb
                    ldb       #E$NotRdy
                    rts

*------------------------------------------------------------
* GetStat
*
* Entry: A = function code
*        Y = path descriptor pointer
*        U = device static memory pointer
* Exit:  carry set on error, B = error code
*
GetStat             cmpa      #SS.EOF   end of file check?
                    beq       NoErr     always succeeds
                    cmpa      #SS.Ready device ready?
                    beq       GSReady
* pass everything else to co-module
                    ldb       #CoGetStt $06
                    lbra      CallCo

GSReady             leax      >ReadBuf,u point to input buffer
                    ldb       <V.InpPtr,u input pointer
                    cmpb      <V.EndPtr,u same?
                    beq       NotReady  empty, not ready
NoErr               clrb
                    rts

*------------------------------------------------------------
* SetStat
*
* Entry: A = function code
*        Y = path descriptor pointer
*        U = device static memory pointer
* Exit:  carry set on error, B = error code
*
SetStat             cmpa      #SS.SSig  signal on data ready?
                    beq       SSSig
                    cmpa      #SS.Relea release device?
                    beq       SSRelea
* pass everything else to co-module
                    ldb       #CoSetStt $09
                    lbra      CallCo

* SS.SSig - set up signal on data ready
SSSig               pshs      cc        save interrupt status
                    orcc      #IRQMask  disable interrupts
                    lda       PD.CPR,y  get current process ID
                    ldx       PD.RGS,y  get caller's register stack
                    ldb       R$X+1,x   get signal code from caller
                    ldx       <V.InpPtr,u check if data waiting
                    cmpx      <V.EndPtr,u
                    beq       SSSig1    no data, save for later
* data already waiting, send signal immediately
                    puls      cc        restore interrupts
                    os9       F$Send    send the signal
                    clrb
                    rts
SSSig1              std       <V.SSigID,u save process ID and signal code
                    puls      pc,cc     restore interrupts and return

* SS.Relea - release device
SSRelea             clr       <V.SSigID,u clear signal process ID
                    clrb
                    rts

*------------------------------------------------------------
* Init
*
* Entry: Y = device descriptor pointer
*        U = device static memory pointer
* Exit:  carry set on error, B = error code
*
Init                ldx       <D.CCMem  get global memory pointer
                    ldd       <G.CurDev,x already initialized?
                    bne       PerDev    yes, just do per-device init
* first-time global initialization
                    stu       <G.CurDev,x save as current device
                    lda       #2        2 ticks per cursor update
                    sta       G.CurTik,x
* save original D.AltIRQ and install ours
                    ldx       <D.AltIRQ
                    stx       >WGlobal+G.OrgAlt
                    leax      >ISR,pcr  point to our ISR
                    stx       <D.AltIRQ install it
* link CoPico co-module
                    pshs      u,y
                    ldd       <D.Proc   save current process
                    pshs      d
                    ldd       <D.SysPrc become system process for link
                    std       <D.Proc
                    leax      CoName,pcr point to CoPico name
                    lda       #Systm+Objct
                    os9       F$Link    link to it
                    puls      d
                    std       <D.Proc   restore current process
                    bcs       InitErr   link failed
                    ldx       <D.CCMem  get global memory pointer
                    sty       <G.CoTble,x store CoPico entry vector
                    puls      u,y
* per-device initialization
PerDev              clr       <V.WinType,u set window type 0 (CoPico)
                    clr       <V.ParmCnt,u no pending escape params
                    clr       <V.InpPtr,u clear input buffer pointers
                    clr       <V.EndPtr,u
                    leax      >CC3Parm,u parameter area start
                    stx       <V.PrmStrt,u save as param buffer start
                    stx       <V.NxtPrm,u and as next param pointer
* call co-module CoInit
                    clrb                CoInit = $00
                    lbra      CallCo

InitErr             puls      pc,u,y    restore and return with error

CoName              fcs       /CoPico/

*------------------------------------------------------------
* Term
*
* Entry: U = device static memory pointer
* Exit:  carry set on error, B = error code
*
Term                ldx       <D.CCMem  get global memory pointer
                    cmpu      <G.CurDev,x are we the current device?
                    bne       DoCoTerm  no, just terminate co-module
* last device, restore D.AltIRQ
                    pshs      cc
                    orcc      #IRQMask  disable interrupts
                    clra
                    clrb
                    std       <G.CurDev,x clear current device pointer
                    ldx       >WGlobal+G.OrgAlt get original AltIRQ
                    stx       <D.AltIRQ restore it
                    puls      cc        restore interrupts
DoCoTerm            ldb       #CoTerm   $0C
                    lbra      CallCo

*------------------------------------------------------------
* ISR - alternate IRQ service routine
*
* Called from the clock module via D.AltIRQ.
* This is where keyboard input from the Graphics Pico
* (arriving via UART) would be polled and placed into
* the device's input buffer.
*
* For now this is a stub that just returns.
*
ISR                 clrb
                    rts

                    emod
eom                 equ       *
                    end
