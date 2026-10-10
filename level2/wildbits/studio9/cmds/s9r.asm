* s9r: MIDI device overlay - route setup and editor, the MIDI Devices menu, the /MIDI
* toggle, SAM2695/VS1053 audio selection and VS1053 RT-MIDI start; also the score browser.
                    nam       s9r
                  IFP1
                    use       defsfile
                  ENDC
UME_SCOPE_S9R                  equ       1
                    use       equates.asm
                    mod       eom,name,Prgrm+Objct,ReEnt+1,start,$104C
name                fcs       /s9r/
                    fcb       1


start               ldb       3,s
                    cmpb      #'i
                    lbeq      InitMidiRoutes
                    cmpb      #'c
                    lbeq      SamAudioMix
                    cmpb      #'b
                    lbeq      BrowserEntry
                    cmpb      #'v
                    lbeq      VsSynthStart        bring the VS1053 up as the real-time MIDI synth
                    cmpb      #'d
                    lbeq      DriveWireToggle     MIDI Devices /midi checkbox
                    cmpb      #'M
                    lbeq      DevicesMenu         the MIDI Devices menu
                    pshs      x,y,u
                    leas      -FrameSize,s
                    tfr       s,u
                    clr       Slot,u
routePrompt         ldb       Slot,u
                    clra
                    aslb
                    aslb
                    aslb
                    aslb
                    addd      #MidiRouteNames
                    std       NamePtr,u
                    pshs      d
                    ldb       Slot,u
                    incb
                    clra
                    pshs      d
                    leax      promptText,pcr
                    pshs      x
                    leax      Prompt,u
                    pshs      x
                    jsr       [>UmeData_psprintf]
                    leas      8,s
                    clr       Input,u
                    ldd       #1
                    pshs      d
                    leax      Prompt,u
                    pshs      x
                    leax      Input,u
                    pshs      x
                    jsr       [>UmeData_pgetempty]
                    leas      6,s
                    lbeq      routeNext
                    lda       #MidiUnusedPath
                    sta       NewPath,u
                    ldd       Input,u
                    cmpd      #$2D00
                    lbeq      routeInstall
                    leax      Input,u
                    clrb
routeLength         lda       ,x+
                    beq       routeName
                    cmpa      #'%
                    lbeq      routeBadName
                    cmpa      #33
                    lblo      routeBadName
                    incb
                    cmpb      #MidiNameSize
                    lbhs      routeBadName
                    bra       routeLength
routeName           leax      Input,u
                    pshs      y
                    leay      wildbitsName,pcr
routeCompare        lda       ,x+
                    cmpa      ,y+
                    bne       routeExternal
                    tsta
                    bne       routeCompare
                    puls      y
                    tst       Slot,u
                    lbne      routeBadName
                    lda       #MidiWildbitsPath
                    sta       NewPath,u
                    bra       routeInstall
routeExternal       puls      y
                    lda       Input,u
                    cmpa      #PDELIM
                    lbne      routeBadName
                    leax      Input,u
                    lda       #WRITE.
                    os9       I$Open
                    lbcs      routeOpenError
                    sta       NewPath,u
                    leax      Options,u
                    ldb       #SS.Opt
                    pshs      y
                    os9       I$GetStt
                    puls      y
                    bcs       routeNotSCF
                    lda       Options+PD.DTP-PD.OPT,u
                    cmpa      #DT.SCF
                    bne       routeNotSCF
routeInstall        lbsr      routeOldPath
                    lda       NewPath,u
                    sta       ,x
                    ldx       NamePtr,u
                    cmpa      #MidiUnusedPath
                    bne       routeCopy
                    clr       ,x
                    bra       routeNext
routeCopy           leay      Input,u
routeCopyByte       lda       ,y+
                    sta       ,x+
                    bne       routeCopyByte
* Restore the caller's C static base before another main-program call.
                    ldy       FrameSize+2,u
routeNext           inc       Slot,u
                    lda       Slot,u
                    cmpa      #MidiRouteCount
                    lblo      routePrompt
                    leas      FrameSize,s
                    puls      x,y,u
                    ldd       #1
                    rts

routeOldPath        ldb       Slot,u
                    ldx       #MidiRoutePaths
                    abx
                    lda       ,x
                    cmpa      #MidiWildbitsPath
                    bhs       routeOldDone
                    pshs      x,y
                    os9       I$Close
                    puls      x,y
routeOldDone        rts
routeNotSCF         lda       NewPath,u
                    pshs      y
                    os9       I$Close
                    puls      y
                    leax      charDeviceError,pcr
                    bra       routeAlert
routeBadName        leax      nameError,pcr
                    bra       routeAlert
routeOpenError      leax      openError,pcr
routeAlert          ldd       #0
                    pshs      d
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
                    lbra      routePrompt
* Cold route initialization belongs with the MIDI device settings, not the live receiver.
InitMidiRoutes      pshs      d,x,y
                    lbsr      OpenMidiInput
                    clr       >Vs1053Out          SAM2695 is the default synth
                    clra
                    clrb
                    std       >MidiRxStatus
                    std       >MidiRxCount
                    clr       >MidiPlaying
                    ldx       #MidiRouteNames
                    ldb       #MidiRouteCount*MidiNameSize
mirClear@           clr       ,x+
                    decb
                    bne       mirClear@
                    ldd       #$5769               Wi
                    std       >MidiRouteNames
                    ldd       #$6C64               ld
                    std       >MidiRouteNames+2
                    ldd       #$6269               bi
                    std       >MidiRouteNames+4
                    ldd       #$7473               ts
                    std       >MidiRouteNames+6
                    ldx       #MidiRoutePaths
                    lda       #MidiUnusedPath
                    ldb       #MidiRouteCount
mirPaths@           sta       ,x+
                    decb
                    bne       mirPaths@
                    lda       #MidiWildbitsPath
                    sta       >MidiRoutePaths
                    lda       #1
                    sta       <UmeData_midiser            SAM2695 audible at start-up
                    sta       <UmeData_midipak             hardware MIDI OUT on at start-up
                    clr       >MidiSelected       no external (/MIDI) route at start-up
                    clr       <UmeData_mididev
                    puls      d,x,y,pc

* MIDrv and /mi are in OS9Boot. Open /mi for update: s9 reads MIDI in and writes MIDI out on this one path.
OpenMidiInput       pshs      d,x,y,u
                    lda       >MidiInPath
                    beq       miopen@
                    deca
                    os9       I$Close
                    clr       >MidiInPath
miopen@             leax      MidiInputPath,pcr
                    lda       #UPDAT.             read and write: MIDI out goes through /mi too
                    os9       I$Open
                    bcs       mireturn@
                    inca
                    sta       >MidiInPath
mireturn@           puls      d,x,y,u,pc
MidiInputPath       fcc       "/mi"
                    fcb       0

* DriveWireToggle: open or close the /MIDI route (slot 2). The four-slot editor
* above stays in the overlay ABI; no menu links to it.
DriveWireToggle     pshs      d,x,y,u
                    ldx       #MidiRoutePaths+1
                    lda       ,x
                    cmpa      #MidiUnusedPath
                    beq       dwOpen@
                    cmpa      #MidiWildbitsPath
                    bhs       dwOff@
                    os9       I$Close
dwOff@              lda       #MidiUnusedPath
                    sta       ,x
                    clr       >MidiSelected
                    bra       dwDone@
dwOpen@             pshs      x
                    leax      dwName,pcr
                    lda       #WRITE.
                    os9       I$Open
                    puls      x
                    bcs       dwError@
                    sta       ,x
                    lda       #MidiPath
                    sta       >MidiSelected
                    bra       dwDone@
dwError@            leax      openError,pcr
                    ldd       #0
                    pshs      d
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
dwDone@             puls      d,x,y,u,pc
dwName              fcc       "/MIDI"             DriveWire channel-14 descriptor
                    fcb       C$CR

promptText          fcc       /Device %d [%s]/
                    fcb       13
                    fcc       /Name (blank keeps, - clears): /
                    fcb       0
wildbitsName        fcc       /Wildbits/
                    fcb       0
nameError           fcc       /Use Wildbits in slot 1, or a device path (15 chars max)./
                    fcb       0
openError           fcc       /Cannot open MIDI output device; previous route kept./
                    fcb       0
charDeviceError     fcc       /MIDI output requires a character device; previous route kept./
                    fcb       0
                    use       score_browser.inc
* The shared MIDI UART must keep feeding the DIN jack. Mute SAM locally at
* WM8776 R21: AIN1/2 are SAM, AIN4 is VS1053. Keep the other inputs enabled.
* This owns only the input selection; headphone/DAC/PGA gains stay unchanged.
SamAudioMix         pshs      d,x,y,u
                    ldb       #$1C
                    tst       <UmeData_midiser
                    beq       sam_mix@
                    orb       #3
sam_mix@            ldx       #0
sam_wait@           lda       >CODEC.Base+CODECCtrl
                    bita      #1
                    beq       sam_write@
                    leax      -1,x
                    bne       sam_wait@
                    leax      SamMixError,pcr
                    clra
                    clrb
                    pshs      d
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
                    puls      d,x,y,u,pc
sam_write@          lda       #$2A                R21, no change to LRBOTH/gain
                    sta       >CODEC.Base+CODECCmdHi
                    stb       >CODEC.Base+CODECCmdLo
                    lda       #1
                    sta       >CODEC.Base+CODECCtrl
                    puls      d,x,y,u,pc
SamMixError         fcc       /Codec busy; SAM audio selection not applied./
                    fcb       0
* VsSynthStart: install VLSI's VS1053b RT-MIDI 1.2 application through SCI.
* CLOCKF $C000 selects the documented 4.5x MIDI clock for a 12.288 MHz crystal.
* The application handles SysEx without losing MIDI message framing. SDI still
* receives zero/byte pairs, with FIFO-full checks in s9's MidiVSSend.
* Records: SCI register, count (bit15 repeats one value), values.
VsSynthStart        pshs      d,x,y,u
                    leas      -4,s                ,s words left  2,s the SCI register  3,s run flag
                    lda       #VS_RESET
                    sta       >VS1053.Base+VS_CTRL
                    ldx       #1
                    os9       F$Sleep
                    clr       >VS1053.Base+VS_CTRL
                    ldx       #3
                    os9       F$Sleep
                    lda       #VS_STATUS
                    ldy       #$0040
                    lbsr      VsSci
                    lbcs      vsp_fail@
                    lda       #VS_VOL
                    ldy       #$0000
                    lbsr      VsSci
                    lbcs      vsp_fail@
                    lda       #VS_CLOCKF
                    ldy       #$C000
                    lbsr      VsSci
                    lbcs      vsp_fail@
                    ldx       #6
                    os9       F$Sleep
                    leau      VsPlugin,pcr
                    ldd       #(VsPlugin_end-VsPlugin)/2
                    std       ,s
vsp_rec@            ldd       ,s
                    beq       vsp_done@
                    subd      #2
                    std       ,s
                    lda       1,u                 the SCI register (low byte of the address word)
                    sta       2,s
                    ldd       2,u                 the count word
                    leau      4,u
                    clr       3,s
                    bita      #$80
                    beq       vsp_cnt@
                    anda      #$7F                a run: one value, repeated
                    inc       3,s
vsp_cnt@            tfr       d,x                 X = values to write
vsp_val@            cmpx      #0
                    beq       vsp_end@
                    ldy       ,u                  the value
                    tst       3,s
                    bne       vsp_run@
                    leau      2,u                 copy: the next word next time
                    ldd       ,s
                    subd      #1
                    std       ,s
vsp_run@            lda       2,s
                    lbsr      VsSci
                    lbcs      vsp_fail@
                    leax      -1,x
                    bra       vsp_val@
vsp_end@            tst       3,s
                    beq       vsp_rec@
                    leau      2,u                 a run: step past its single value
                    ldd       ,s
                    subd      #1
                    std       ,s
                    bra       vsp_rec@
vsp_done@           ldx       #3                  let the MIDI code start
                    os9       F$Sleep
                    lda       #VS_VOL            application startup defaults to -1.5 dB
                    ldy       #0
                    lbsr      VsSci
                    bcs       vsp_fail@
                    bra       vsp_exit@
vsp_fail@           clr       >Vs1053Out          never leave a failed route enabled
                    ldy       8,s                 restore the caller's C static base for alert
                    leax      VsStartError,pcr
                    ldd       #0
                    pshs      d
                    pshs      x
                    jsr       [>UmeData_palert]            alert(message, 0)
                    leas      4,s
vsp_exit@           leas      4,s
                    puls      d,x,y,u,pc
VsStartError        fcc       /VS1053 did not respond; output disabled./
                    fcb       0
* VsSci: A = SCI register, Y = the 16-bit value (the bridge's data pair is big-endian). Waits for BUSY
* to clear, bounded. X preserved, Y used as the counter.
VsSci               pshs      x
                    ldx       #VS1053.Base
                    sta       VS_SCIREG,x
                    sty       VS_DATA,x
                    clr       VS_CTRL,x           START is edge-triggered: low first
                    lda       #VS_START
                    sta       VS_CTRL,x
                    ldy       #0                  65536 looks
vsci_w@             lda       VS_CTRL,x
                    bita      #VS_BUSY
                    beq       vsci_ok@
                    leay      -1,y
                    bne       vsci_w@
                    orcc      #1
                    puls      x,pc
vsci_ok@            andcc     #$FE
                    puls      x,pc
* DevicesMenu ('M'): the MIDI Devices menu - the four MIDI outputs and the two DriveWire 4 dialogs (menu3).
* Returns D = 1 when a DriveWire 4 dialog ran (s9m then reloads the MIDI menu), else 0.
* Frame: ,s the key  1,s the window to restore  3,s the DW4 flag.
DevicesMenu         pshs      u
                    leas      -4,s
                    clr       3,s
                    ldd       <UmeData_curcurse
                    std       1,s
                    ldd       #2
                    lbsr      DmSelWin
dmRedraw@           ldb       <UmeData_smf        the checkboxes in row order: /mi, /midi, VS1053, MIDI File
                    sex
                    pshs      d
                    ldb       >Vs1053Out
                    sex
                    pshs      d
                    clrb
                    lda       >MidiRoutePaths+1   the /midi route: open unless the slot is unused
                    cmpa      #MidiUnusedPath
                    beq       dmdw@
                    incb
dmdw@               clra
                    pshs      d
                    ldb       <UmeData_midiser
                    sex
                    pshs      d
                    leax      >fmtDmFlags,pcr
                    pshs      x
                    ldx       #MenuStates
                    pshs      x
                    jsr       [>UmeData_psprintf]
                    leas      12,s
                    ldx       #MenuStates
                    pshs      x
                    leax      >descMidiDevices,pcr
                    pshs      x
                    jsr       [>pMenu3]           s9 streams it, s9gui draws it and answers: B
                    leas      4,s
                    stb       ,s
                    ldd       #$00C7              FlushDisplay: $C7 through the <$16 format
                    pshs      d
                    ldd       <UmeData_reserved_0016
                    pshs      d
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    ldb       ,s
                    cmpb      #'S
                    beq       dmSam@
                    cmpb      #'V
                    beq       dmVs@
                    cmpb      #'d
                    beq       dmMidi@
                    cmpb      #'f
                    beq       dmFile@
                    cmpb      #'D
                    beq       dmDev@
                    cmpb      #'P
                    beq       dmProf@
                    cmpb      #C$CR
                    beq       dmEnd@              ENTER or a click off the menu
                    jsr       [>UmeData_pbeep]
                    lbra      dmRedraw@
dmSam@              ldb       <UmeData_midiser    SAM2695 and VS1053 stay mutually exclusive
                    eorb      #1
                    stb       <UmeData_midiser
                    beq       dmMix@
                    clr       >Vs1053Out
                    bra       dmMix@
dmVs@               lda       >Vs1053Out
                    eora      #1
                    sta       >Vs1053Out
                    beq       dmMix@
                    clr       <UmeData_midiser
                    lbsr      VsSynthStart        the chip up as the real-time MIDI synth
dmMix@              lbsr      SamAudioMix
                    lbra      dmRedraw@
dmMidi@             lbsr      DriveWireToggle
                    lbra      dmRedraw@
dmFile@             lda       <UmeData_smf        file export suppresses live output, the saved routes kept
                    eora      #1
                    sta       <UmeData_smf
                    sta       <UmeData_pldebug
                    lbra      dmRedraw@
dmDev@              ldd       #'d
                    bra       dmDw4@
dmProf@             ldd       #'p
dmDw4@              tst       <UmeData_reserved_0051  /N opened at start: else a message, and the menu stays
                    bne       dmDw4go@
                    clra
                    clrb
                    pshs      d
                    leax      >msgDmNoN,pcr
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      4,s
                    lbra      dmRedraw@
* s9w's dialogs are full-screen (an unsaved window, then $90 clears the picture and asks for a rebuild), so the
* menu ends here instead of looping back over the cleared screen.
dmDw4go@            pshs      d
                    ldd       #'W
                    pshs      d
                    jsr       [>UmeData_psoowee]
                    leas      4,s
                    inc       3,s
dmEnd@              ldd       1,s
                    lbsr      DmSelWin
                    clra
                    ldb       3,s
                    leas      4,s
                    puls      u,pc
* DmSelWin: D = the window: curcurse, then $9A through the <$18 format (s9m's SelectWindow)
DmSelWin            std       <UmeData_curcurse
                    pshs      d
                    ldd       #$009A
                    pshs      d
                    ldd       <UmeData_reserved_0018
                    pshs      d
                    jsr       [>UmeData_pprintf]
                    leas      6,s
                    rts
fmtDmFlags          fcc       /%d%d%d%d/
                    fcb       0
msgDmNoN            fcc       | No DriveWire /N |
                    fcb       0
* descMidiDevices: menu3 - col, top, width, rows; one key a row; then kind + label per row ('-' key = a title row)
descMidiDevices     fcb       MidiSubCol+1,MidiSubTop,19,7
                    fcc       /-SdVfDP/
                    fcc       /  MIDI DEVICES/
                    fcb       0
                    fcc       |b/mi (Wildbits)|
                    fcb       0
                    fcc       |b/midi (DriveWire)|
                    fcb       0
                    fcc       /bVS1053/
                    fcb       0
                    fcc       /bMIDI File/
                    fcb       0
                    fcc       /   DW4 Device.../
                    fcb       0
                    fcc       /   DW4 Profile.../
                    fcb       0,0
* Updated VLSI application, with its documented SCI start record.
VsPlugin            use       vs_rtmidi.inc
VsPlugin_end        equ       *
                    fill      0,$1D00-*           pad to $1D00 bytes so F$Link never puts this overlay in slot 7 and the score page always gets it
                    emod
eom                 equ       *
                    end
