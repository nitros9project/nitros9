*******************************************************************
* VTIO - NitrOS-9 video terminal I/O driver for the Foenix F256
*
* https://wiki.osdev.org/PS2_Keyboard
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  1       2013/08/20  Boisy G. Pitre
* Started.
*
*  2       2013/12/06  Boisy G. Pitre
* Added SS.Joy support.
*
*  3       2025/09/26  Boisy G. Pitre
* Segregated into high and low level for grfdrv-like functionality for F256.

                    nam       VTIO
                    ttl       NitrOS-9 video terminal I/O driver for the Foenix F256

                    use       defsfile
                    use       f256vtio.d

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       2

                    mod       eom,name,tylg,atrv,start,size

size                equ       V.Last

                    fcb       UPDAT.+EXEC.

name                fcs       /vtio/
                    fcb       edition

start               lbra      Init
                    lbra      Read
                    lbra      Write
                    lbra      GetStat
                    lbra      SetStat
                    lbra      Term

llpath              fcc       "/dd/CMDS/"
llnam               fcs       "grfdrvf256"

Init                
* Link to module
linkmod
                    ifgt      Level-2
                    leas      -2,s                Make buffer for current process dsc.
                    bsr       tosysproc               Swap to system process
                    endc
                    lda       #Systm+Objct        Link module
                    leax      llnam,pcr
                    pshs      u
                    os9       F$Link
                    puls      u
                    ifgt      Level-2
                    bsr       toproc               Swap back to current process
                    endc
                    bcc       save                 Return
                    cmpb      #E$MNF              Module not found?
                    bne       ex                 No, exit with error

* Load a module
loadmod
                    ifgt      Level-2
                    leas      -2,s                Make a buffer for current process ptr
                    bsr       tosysproc               Switch to system process descriptor
                    ldu       <D.Proc
                    endc
                    lda       #Systm+Objct        Load module
                    leax      llpath,pcr
                    pshs      u
                    os9       F$Load
                    puls      u
                    bcs       ex

                    ifgt      Level-2
                    bsr       toproc               Swap back to current process
                    endc
save
                    ifgt      Level-2
                    leas      2,s                 Purge stack & return
                    endc
                    sty       V.LLEntry,u
                    jmp       ,y
ex                  rts

                    ifgt      Level-2
* Switch to system process descriptor
tosysproc           pshs      d                   Preserve D
                    ldd       <D.Proc             Get current process dsc. ptr
                    std       4,s                 Preserve on stack
                    ldd       <D.SysPrc           Get system process dsc. ptr
                    std       <D.Proc             Make it the current process
                    puls      d,pc                Restore D & return

* Switch back to current process
toproc              pshs      d                   Preserve D
                    ldd       4,s                 Get current process ptr
                    std       <D.Proc             Make it the current process
                    puls      d,pc                Restore D & return
                    endc

Read                ldx       V.LLEntry,u
                    jmp       3,x
                    
Write               ldx       V.LLEntry,u
                    jmp       6,x
                    
GetStat             ldx       V.LLEntry,u
                    jmp       9,x
                    
SetStat             ldx       V.LLEntry,u
                    jmp       12,x
                    
Term                ldx       V.LLEntry,u
                    jmp       15,x
                    
                    emod
eom                 equ       *
                    end
