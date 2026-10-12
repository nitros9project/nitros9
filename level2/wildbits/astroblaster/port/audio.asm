* Private timer-driven sound device; no sample playback inside drawing loops.
InitializeAstroSound
                    leax AstroStageSoundLoad,pcr
                    lbsr ReportStartupStage
* F$Load always searches the execution directory. Form an absolute path
* from the device of the already-open astro.dat instead of guessing /dd.
                    leax AD_SoundName+1,u
                    lda AD_AssetPath,u
                    ldb #SS.DevNm
                    os9 I$GetStt
                    lbcs SoundAppReturn
                    lda #'/
                    sta AD_SoundName,u
                    leax AD_SoundName+1,u
                    ldb #29
SoundDeviceName    lda ,x
                    bmi SoundDeviceEnd
                    tsta
                    beq SoundDeviceSuffix
                    leax 1,x
                    decb
                    bne SoundDeviceName
                    ldb #E$BPNam
                    orcc #Carry
                    rts
SoundDeviceEnd     anda #$7F
                    sta ,x+
SoundDeviceSuffix  leay AstroSoundModule,pcr
SoundModuleName    lda ,y+
                    sta ,x+
                    bne SoundModuleName
                    leax AD_SoundName,u
                    clra
                    pshs u
                    os9 F$Load
                    tfr u,x
                    puls u
                    lbcs SoundAppReturn
                    stx AD_SoundLink,u
                    leax AstroStageSoundOpen,pcr
                    lbsr ReportStartupStage
                    leax AstroSoundDevice,pcr
                    lda #WRITE.
                    os9 I$Open
                    lbcs SoundAppReturn
                    sta AD_SoundPath,u
                    inc AD_SoundOpen,u
                    lbsr UnlinkAstroSound
                    lbcs SoundAppReturn
                    leax AstroStageSoundData,pcr
                    lbsr ReportStartupStage
                    leax AstroSoundData,pcr
                    lda #READ.
                    os9 I$Open
                    lbcs SoundAppReturn
                    sta AD_SoundDataPath,u
                    inc AD_SoundDataOpen,u
* Only astro.snd's SID-table block is used (the effects are SID/PSG scripts): seek to it, so the
* driver's one block gets it and nothing else is read.
                    pshs u
                    ldx #(AS_SoundFileBlock*AS_BlockBytes)/65536
                    ldu #(AS_SoundFileBlock*AS_BlockBytes)&$FFFF
                    os9 I$Seek
                    puls u
                    lbcs SoundAppReturn
                    leax AstroStageSoundUpload,pcr
                    lbsr ReportStartupStage
* Map one driver-owned bank into the spare process slot and read straight
* into it. No SCF byte writes or hand-edited system DAT entries during upload.
SoundReadAssets     ldb AP_ExitSignal,u
                    beq SoundNextAssetBank
                    orcc #Carry
                    bra SoundAppReturn
SoundNextAssetBank  lda AD_SoundPath,u
                    ldb #AS_UploadBlock
                    os9 I$GetStt
                    bcc SoundMapAssetBank
                    cmpb #E$EOF
                    bne SoundAppReturn
                    bra SoundAssetsLoaded
SoundMapAssetBank   pshs u
                    ldb #1
                    os9 F$MapBlk
                    tfr u,x
                    puls u
                    bcs SoundAppReturn
                    stx AP_MapAddress,u
                    inc AP_HasMapping,u
                    cmpx #LAST_SAFE_BLOCK_MAP
                    bls SoundReadAssetBank
                    ldb #E$MemFul
                    orcc #Carry
                    bra SoundReleaseAssetBank
SoundReadAssetBank  lda AD_SoundDataPath,u
                    ldy #AS_BlockBytes
                    os9 I$Read
SoundReleaseAssetBank
                    pshs cc,b,y   stack offsets: CC=0, error B=1, byte count Y=2
                    lbsr ReleaseDisplayMapping
                    bcs SoundReleaseAssetError
                    puls cc,b,y
                    bcs SoundAppReturn
                    cmpy #AS_BlockBytes
                    beq SoundCommitAssetBank
                    ldb #E$EOF
                    orcc #Carry
                    bra SoundAppReturn
SoundReleaseAssetError
                    leas 4,s     stack offset: discard saved read status/count
                    bra SoundAppReturn
SoundCommitAssetBank lda AD_SoundPath,u
                    ldb #AS_UploadDone
                    os9 I$SetStt
                    bcc SoundReadAssets
                    bra SoundAppReturn
SoundAssetsLoaded   lda AD_SoundDataPath,u
                    os9 I$Close
                    bcs SoundAppReturn
                    clr AD_SoundDataOpen,u
                    clrb
SoundAppReturn      rts

* Enable sound only after the first bitmap and frame clock are ready.
* The driver starts sample IRQs on demand for actual PCM voices.
StartAstroSound     leax AstroStageSoundStart,pcr
                    lbsr ReportStartupStage
                    lda AD_SoundPath,u
                    ldb #AS_Start
                    os9 I$SetStt
                    rts
UnlinkAstroSound    ldx AD_SoundLink,u
                    beq SoundAppOK
                    pshs u
                    tfr x,u
                    os9 F$UnLink
                    puls u
                    bcs SoundAppReturn
                    clr AD_SoundLink,u
                    clr AD_SoundLink+1,u
SoundAppOK          clrb
                    rts

* A=cue, X=game. Preserve every event class in the current logic tick.
QueueAstroSound     pshs a,b,y
                    cmpa #SFX_WARP
                    beq SoundQueueReturn
                    deca
                    leay SoundEventBits,pcr
                    ldb a,y
                    orb GS_SoundPending,x
                    stb GS_SoundPending,x
SoundQueueReturn   puls a,b,y,pc
SoundEventBits     fcb 1,2,4,8,16,32,64,128

FlushAstroSound     pshs d,x,y
                    leax AD_Game,u
                    lda GS_SoundPending,x
                    clr GS_SoundPending,x
                    sta AD_SoundPending,u
                    lbsr SyncSoundPause
                    tst AD_SoundOpen,u
                    lbeq SoundFlushReturn
                    tst AP_Paused,u
                    lbne SoundFlushReturn
* Original $1654/$1672 tables suppress effects in the demonstration.
                    tst GS_DemoActive,x
                    bne SoundQuietBackground
                    lda GS_Phase,x
                    cmpa #PHASE_PLAY
                    bne SoundQuietBackground
                    tst GS_Stage,x
                    bne SoundStageBackground
                    tst GS_BonusPrepared,x ; original $2C92: hum off at wave clear
                    bne SoundQuietBackground
                    ldy GS_WaveDescriptor,x
                    beq SoundQuietBackground
                    ldb W_Sound,y
                    cmpb #21
                    bhs SoundQuietBackground
                    leay SoundOriginalEnables,pcr
                    ldb b,y
                    lda GS_GameSpeed,x
                    cmpa #1
                    beq SoundSetBackground
                    andb #$7F       original loop ID 18: warp control
                    bra SoundSetBackground
SoundStageBackground lda GS_Stage,x
                    cmpa #STAGE_DOCK
                    bne SoundQuietBackground
                    tst GS_Docked,x
                    beq SoundQuietBackground
                    lda GS_DockAction,x
                    cmpa #1
                    beq SoundDockDoors
                    cmpa #2
                    bne SoundQuietBackground
                    ldb #$F7       original $4461: invader 4 during bonus
                    bra SoundSetBackground
SoundDockDoors     tst GS_DockDoorsStarted,x
                    beq SoundQuietBackground
                    ldb #$FB       original $4557: invader 3 during door motion
                    bra SoundSetBackground
SoundQuietBackground ldb #$FF
SoundSetBackground clra
                    tfr d,x
                    lda AD_SoundPath,u
                    ldb #AS_Background
                    os9 I$SetStt
                    lbcs SoundFlushError
                    leax AD_Game,u
                    clrb
                    tst GS_DemoActive,x
                    bne SoundSetLoop
                    lda GS_Phase,x
                    cmpa #PHASE_PLAY
                    bne SoundSetLoop
                    lda GS_Stage,x
                    cmpa #STAGE_ASTEROIDS
                    beq SoundAsteroidLoop
                    cmpa #STAGE_DOCK
                    bne SoundSetLoop
                    tst GS_Docked,x
                    beq SoundSetLoop
                    tst GS_DockComplete,x
                    bne SoundSetLoop
                    lda GS_DockAction,x
                    cmpa #2
                    bls SoundSetLoop
                    ldb #7         original loop ID 17: while fuel is refilling
                    bra SoundSetLoop
SoundAsteroidLoop  ldb #8         original loop ID 15
SoundSetLoop       clra
                    tfr d,x
                    lda AD_SoundPath,u
                    ldb #AS_Loop
                    os9 I$SetStt
                    bcs SoundFlushError
                    leax AD_Game,u
                    tst GS_DemoActive,x
                    bne SoundFlushReturn
                    leax SoundEventCommands,pcr
                    ldy #8
SoundFlushEvent     pshs y
                    lsr AD_SoundPending,u
                    bcc SoundNextEvent
                    pshs x
                    ldy 2,x
                    ldx ,x
                    lda AD_SoundPath,u
                    ldb #AS_Play
                    os9 I$SetStt
                    puls x
                    bcs SoundEventError
SoundNextEvent      leax 4,x
                    puls y
                    leay -1,y
                    bne SoundFlushEvent
                    bra SoundFlushReturn
SoundEventError     leas 2,s       stack offset: event-loop count
SoundFlushError     stb AD_SoundError,u
SoundFlushReturn    puls d,x,y,pc
* Separate shot/impact/major-event voices. Dock opens with the original
* long-explosion/sonar pair; queue the sonar class alongside SFX_DOCK.
SoundEventCommands  fdb 1,0,2,0,3,2,5,0,4,2,4,2,2,1,6,0
SoundOriginalEnables
                    fcb $FE,$FD,$FB,$F7,$FC,$FA,$F6,$F9,$F5,$F3,$F8,$F4,$F2,$F1,$F0,$EF,$DF,$BF,$7F,$60,$FF

* Main-context terminal ownership handling; never called by F$Icpt.
SyncSoundPause      pshs d,x,y
                    tst AD_SoundOpen,u
                    beq SoundPauseReturn
                    lda AP_Paused,u
                    cmpa AD_SoundPause,u
                    beq SoundPauseReturn
                    sta AD_SoundPause,u
                    tfr a,b
                    clra
                    tfr d,x
                    lda AD_SoundPath,u
                    ldb #AS_Pause
                    os9 I$SetStt
                    bcc SoundPauseReturn
                    stb AD_SoundError,u
SoundPauseReturn    puls d,x,y,pc

CloseAstroSound     tst AD_SoundOpen,u
                    beq SoundCloseData
                    lda AD_SoundPath,u
                    ldb #AS_Stop
                    os9 I$SetStt
                    lda AD_SoundPath,u
                    os9 I$Close
                    clr AD_SoundOpen,u
SoundCloseData      tst AD_SoundDataOpen,u
                    lbeq UnlinkAstroSound
                    lda AD_SoundDataPath,u
                    os9 I$Close
                    clr AD_SoundDataOpen,u
                    lbra UnlinkAstroSound
AstroSoundModule    fcc "/astro/astrosnd"
                    fcb 0
AstroSoundData      fcc "/dd/astro/astro.snd"
                    fcb 0
AstroSoundDevice    fcc "/asnd"
                    fcb 0
AstroStageSoundLoad  fcc "Astro: load sound driver"
                    fcb C$CR
AstroStageSoundOpen  fcc "Astro: open sound device"
                    fcb C$CR
AstroStageSoundData  fcc "Astro: open PCM assets"
                    fcb C$CR
AstroStageSoundUpload fcc "Astro: read PCM RAM blocks"
                    fcb C$CR
AstroStageSoundStart fcc "Astro: enable sound service"
                    fcb C$CR
