* Private Astro sound service ABI. Shared by launcher and resident driver.
AS_Play       equ $80       X.low = PCM cue (1..8), Y.low = voice (0..2)
AS_Background equ $81       X.low = original active-low alien enables
AS_Pause      equ $82       X.low = 0 resume / nonzero pause
AS_Stop       equ $83       stop timer and all owned sound generators
AS_Start      equ $84       enable service after preload; PCM cues arm timer
AS_Loop       equ $85       X.low = 0 stop, 7 refill, 8 asteroids; fourth PCM voice
AS_UploadBlock equ $86      GetStat: X = next owned RAM block; EOF when complete
AS_UploadDone equ $87       SetStat: commit one completely filled 8 KB block
AS_PCMLeft    equ $FF9A     signed big-endian pair; low byte commits
AS_PCMRight   equ $FF9C
AS_PCMStatus  equ $FF9E
AS_PCMReady   equ 1
AS_SampleRate equ 8000
AS_TimerCount equ 3146      25.175 MHz / 3147 = 7999.682 samples/sec
AS_BlockBytes equ $2000
AS_SoundRAMBlocks equ 1     RAM blocks the driver takes: astro.snd's SID-table block
AS_SoundFileBlock equ 26    that block's number in astro.snd (sound_assets.asm ASoundSIDBlock; astrosnd checks)
AS_OneShots   equ 3
AS_Voices     equ 4
AV_Block      equ 0
AV_Offset     equ 1
AV_Left       equ 3         remaining sample bytes, always even
AV_LoopBank   equ 5
AV_LoopOffset equ 6
AV_LoopLength equ 8
AV_Bytes      equ 10
AS_SIDControl equ 4
AS_SIDAttack  equ 5
AS_SIDSustain equ 6
AS_SIDVolume  equ 24
AS_SIDPulse   equ $41
AS_SIDSilent  equ $40
SY_Slots      equ 7         synth script slots
AS_SIDLoud    equ 15        SID master volume
AS_RumbleHold equ 144       ticks: the long (player) explosion, 2.4 s
AS_HumSustain equ $50       hum voices: sustain 5, about 33% amplitude
