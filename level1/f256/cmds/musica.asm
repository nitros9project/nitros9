********************************************************************
* MUSICA II Player
* For the F256 Computer by Foenix Retro Systems
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2025/10/27  Roger Taylor
* Created
*
*   1      2025/10/28  Roger Taylor
* Added -z playlist feature

                    nam       musica
                    ttl       Musica II Player

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

PLAYLISTITEM_MAXSTR equ       255

                    mod       eom,name,tylg,atrv,start,size

clistart            rmb       2
cliptr              rmb       2
fmemupper           rmb       2
fmemsize            rmb       2
filesize            rmb       2
SoundMem            rmb       2                   Points to 8K block of RAM where sound registers are
ScoreStart	    rmb       2
ScoreCurrent	    rmb       2
ScoreTempo	    rmb       1
NoteCycles	    rmb       2
psg_out             rmb       2
psg_left            rmb       2
psg_both            rmb       2
psg_right           rmb       2
solpath	            rmb       1
sequencer	    RMB       1
filepath            rmb       1
filebuf             rmb       2
PlaylistMode        rmb       1
PlaylistPath        rmb       1
PlaylistItemStr     rmb       PLAYLISTITEM_MAXSTR

	            rmb       250
size                equ       .
name                fcs       /musica/
                    fcb       edition
helpstr             fcc       /musica {file}/
                    fcb       C$LF
                    fcc       /musica -z {playlist file}/
                    fcb       C$LF
greeting            fcc       /MUSICA Player 0.3 by Roger Taylor/
                    fcb       C$LF
helplen             set       *-helpstr
greetlen             set       *-greeting
range               fcc       "out of range"
                    fcb       C$LF,0
memerr              fcc       "MapBlk should have returned $C000"
                    fcb       C$LF,0

start
                    clra
                    clrb
                    os9       F$Mem
                    lbcs      err
                    sty       fmemupper
                    std       fmemsize

                    stx       <clistart
                    stx       <cliptr
                    clr       <PlaylistMode

GetOptions          ldx       <cliptr
                    lda       ,x
                    cmpa      #$0d
                    beq       ShowGreeting
                    cmpa      #'-
                    lbne      DoBusiness
                    leax      1,x
                    lda       ,x
                    cmpa      #'?
                    beq       ShowHelp
                    cmpa      #'h
                    beq       ShowHelp
                    cmpa      #'z
                    beq       Option_Z
                    cmpa      #'Z
                    beq       Option_Z
                    bra       DoBusiness

Option_Z
                    leax      1,x
                    lda       ,x
                    cmpa      #$0D
                    lbeq      bye
                    lda       #READ.
                    os9       I$Open              Open the playlist path
                    lbcs      err
                    stx       <cliptr
                    sta       <PlaylistPath
                    ldb       #1
                    stb       <PlaylistMode
                    bra       DoBusiness

ShowGreeting        leax      greeting,pcr
                    ldy       #greetlen
                    bra       p@
ShowHelp            leax      helpstr,pcr
                    ldy       #helplen
p@                  lda       #2
                    os9       I$WritLn
                    os9       F$Exit

DoBusiness          lbsr      MAP_IN_SOUND
                    lbsr      InstallSignals      Install SOL to show different font on screen
                    lbsr      MuteSignals
                    ldd       <psg_both
                    std       <psg_out
                    clr       <sequencer
                    lbsr      UnMuteSignals

NextSong            clr       <sequencer
                    ldy       <psg_left
                    lbsr      PSG_QUIET_ALL
                    ldy       <psg_right
                    lbsr      PSG_QUIET_ALL
                    ldy       <psg_left
                    lbsr      PSG_QUIET_ALL
                    ldy       <psg_right
                    lbsr      PSG_QUIET_ALL
                    ldd       #$0000
                    std       <NoteCycles

                    tst       <PlaylistMode
                    beq       LoadMediaFile

                    lda       <PlaylistPath
                    leax      <PlaylistItemStr,u
                    ldy       #PLAYLISTITEM_MAXSTR
                    os9       I$ReadLn
                    lbcs      bye
                    leax      <PlaylistItemStr,u
                    stx       <cliptr

LoadMediaFile       ldx       <cliptr
                    lda       ,x
                    cmpa      #$0D
                    lbeq      bye
                    lda       #READ.
                    os9       I$Open
                    lbcs      err
                    stx       <cliptr
                    sta       filepath
                    ldb       #SS.Size
                    pshs      u
                    os9       I$GetStt
                    tfr       u,x
                    puls      u
                    lbcs      err
                    stx       <filesize
                    tfr       x,d
                    addd      <fmemsize
                    os9       F$Mem
                    bcs       err
                    sty       <fmemupper
*                   std       <fmemsize           Caused each music file to be appended to process mem
                    ldd       <fmemupper
                    subd      <filesize
                    tfr       d,x
                    ldy       <filesize
                    lda       <filepath
                    os9       I$Read
                    bcs       err

                    lda       ,x                  Examine first byte of file
                    bne       nd@                 Is non-zero, not a LOADM header
                    leax      5,x                 Skip over the DOS LOADM header
nd@                 tfr       x,d
*                   sta       <muspag             MSB is CPU memory page# where music waveforms start
                    leax      1024,x              Skip over the 4 waveforms (4*256)
                    leax      5,x                 Skip over Default 1st music block
                    stx       <ScoreStart         This is where our music starts
                    stx       <ScoreCurrent       Set the running pointer

                    ldy       <psg_left
                    lbsr      PSG_LOUD_ALL
                    ldy       <psg_right
                    lbsr      PSG_LOUD_ALL
                    ldb       #1                  Enable the player
                    stb       <sequencer          Tell the ISR to PLAY THE MUSIC

keyloop@            lda       <sequencer          Listen for IRQ to signal that the song is over
                    beq       CloseAndNext
                    lbsr      INKEY  		  Inkey routine with handlers for intergace
                    cmpa      #$0D                $0D=ok shift+$0d=cancel
                    bne       keyloop@

*                   lda       <filepath           There better be a path#
*                   os9       I$Close
*                   lda       <PlaylistPath       There better be a path#
*                   os9       I$Close

bye                 clrb
err                 pshs      d,u,cc
                    orcc      #IntMasks
                    clr       <sequencer
*                   lbsr      MuteSignals         Not an audio mute, is an IRQ signal "mute"
                    lbsr      RemoveSignals       Clean up and remove signals and SOL
                    ldy       <psg_left
      	            bsr	      PSG_QUIET_ALL
                    ldy       <psg_right
      	            bsr	      PSG_QUIET_ALL
*                   ldu       <SoundMem
*                   ldb       #$01                Return 1 block
*                   os9       F$ClrBlk            Return to OS-9 but is this needed if we're exiting a program?
                    puls      d,u,cc
                    os9       F$Exit

CloseAndNext        lda       <filepath
                    os9       I$Close
                    lbra      NextSong

PSG_LOUD_ALL        ldd       #$B090
                    lbsr      WritePSG
                    ldd       #$D0FF
                    lbsr      WritePSG
                    rts

PSG_QUIET_ALL       ldd       #$9FBF
                    lbsr      WritePSG
                    ldd       #$DFFF
                    lbsr      WritePSG
                    rts

MAP_IN_SOUND        pshs      u,cc
                    orcc      #IntMasks
                    tfr       u,y
                    ldx       #$C4
                    ldb       #$01                Ask for 1 block
                    os9       F$MapBlk            Map it into process address space
                    stu       <SoundMem
                    leau      $200,u              compute address of PSG Left channel
                    stu       <psg_left,y
                    leau      $08,u               compute address of PSG dual channel
                    stu       <psg_both,y
                    leau      $08,u               compute address of PSG right channel
                    stu       <psg_right,y        save
                    ldu       <SoundMem
                    cmpu      #$C000
                    beq       x@
                    lda       #0
                    leax      memerr,pcr
                    ldy       #255
                    os9       I$WritLn
x@                  puls      cc,u,pc

********************************************************************
* cfIcptRtn
* this handles the signals received by SOL
* 
cfIcptRtn
                    pshs      cc,d,x,y,u          <--------- do we need to do this?
                    LDB       <sequencer          Are we allowed to play music?
                    LBEQ      SeqExit		  No, then exit
                    LDX       <ScoreCurrent
                    LDD       <NoteCycles
                    lbne      NextCycle		  A note is currently playing
                    LDA       ,X		  Get the new note length
                    lbeq      IRQ785		  0 means End Of Score
                    BPL       IRQ730		  Go set up the note
                    CMPA      #$FD		  Repeat the score
                    LBEQ      IRQ785
                    CMPA      #$FE		  Tempo and Instruments Block
                    lbne      NextNote
                    lda       5,x                 Get new tempo
                    sta       <ScoreTempo
                    lbra      NextNote
IRQ730
                *     tfr       a,b                 Convert 8-bit note length into 16 bits
                *     clra
                *     lsrb
                *     addd      #$0001

                    tfr       a,b                 Convert 8-bit note length into 16 bits
                    clra
                    pshs      d
                    lsr       1,s
                    subd      ,s++
                    addd      #$0001

                    std       <NoteCycles

* What are we doing here... since the 76489 chip only has 3 tone channels
* and we need to hear all 4 Musica voices, we split Musica Voices 1,2 between
* both PSG channels, we send the 3rd Musica voice to the Left PSG channel,
* and the 4th Musica Voice to the Right PSG channel, all at the same time.

                    LDD       1,X                 Get Musica Voice 1 16-bit frequency
                    beq       v1@                 0 means Silence
                    bsr       Mf2Pf               Convert to 10-bit PSG tone
v1@                 lbsr      psgv1               Convert to PSG Voice 1 Command bytes
                    ldy       <psg_right
                    bsr       WritePSG            Output to right
                    ldy       <psg_left
                    bsr       WritePSG            Output to left

                    LDD       3,X                 Get Musica Voice 2 16-bit frequency
                    beq       v2@                 0 means Silence
                    bsr       Mf2Pf               Convert to 10-bit PSG tone
v2@                 lbsr      psgv2               Convert to PSG Voice 2 Command bytes
                    ldy       <psg_right
                    bsr       WritePSG            Output to right
                    ldy       <psg_left
                    bsr       WritePSG            Output to left

                    LDD       5,X                 Get Musica Voice 3 16-bit frequency
                    beq       v3@                 0 means Silence
                    bsr       Mf2Pf               Convert to 10-bit PSG tone
v3@                 lbsr      psgv3               Convert to PSG Voice 2 Command bytes
                    ldy       <psg_left
                    bsr       WritePSG            Output to left

                    LDD       7,X                 Get Musica Voice 4 16-bit frequency
                    beq       v4@                 0 means Silence
                    bsr       Mf2Pf               Convert to 10-bit PSG tone
v4@                 lbsr      psgv3               Convert to PSG Voice 2 Command bytes
                    ldy       <psg_right
                    bsr       WritePSG            Output to right

                    ldd       <NoteCycles
NextCycle           subd      #1
                    std       <NoteCycles
                    BNE       SeqExit
NextNote            LEAX      9,X
                    STX       <ScoreCurrent
                    BRA       SeqExit
IRQ785              LDX       <ScoreStart             at end of song, play it again
                    STX       <ScoreCurrent
                    clr       <sequencer          Tell main code that the song is over
                    BRA       SeqExit
SeqExit             puls      cc,d,x,y,u
                    rti

WritePSG            pshs      cc,d
                    sta       ,y
                    stb       ,y
                    puls      cc,d,pc

Mf2Pf               lsra                          lower the Musica freq (octave?) before Fconv
                    rorb
                    lsra                          lower the Musica freq (octave?) before Fconv
                    rorb
                    lsra                          lower the Musica freq (octave?) before Fconv
                    rorb
                    lsra                          lower the Musica freq (octave?) before Fconv
                    rorb
                    std       $FEE4               denominator (MUSICA II freq)
                    ldd      #111563/2
                    std       $FEE6               numerator
                    ldd       $FEF4               quotient
*                    lslb                          adjust the PSG freq after the Fconv
*                    rola
*                    lslb                          adjust the PSG freq after the Fconv
*                    rola
                    cmpd      #1023               Is the result <1024, in PSG tone range?
                    bls       g@
                    ldd       #1023               Set upper freq limit for PSG
*                    lda       #0                  Let the user know
*                    leax      range,pcr
*                    ldy     #255
*                    os9       I$WritLn
g@                  rts

* Assign a voice to a speaker, or both speakers
*  Enter with PSG-format 10-bit tone value a/XXXXXXHH b/HHHHLLLL
*  reg.y = psg_left, psg_both, psg_right
psgv1               pshs      d
                    andb      #%00001111          get low 4 bits of tone
                    orb       #%10000000          set voice #1 of 3
                    bra       psgout
psgv2               pshs      d
                    andb      #%00001111          get low 4 bits for freq
                    orb       #%10100000          set voice #2 of 3
                    bra       psgout
psgv3               pshs      d
                    andb      #%00001111          get low 4 bits for freq
                    orb       #%11000000          set voice #3 of 3
                    bra       psgout
psgout              stb       ,-s                 save command byte with lower 4 bits so we can write them at the same time
                    ldd       1,s                 retrieve PSG tone from stack
                    lsra                          shift lower 4 bits away
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    andb      #%00111111          then use 6 of the remaining bits
                    lda       ,s+                 retrieve tone command with lower 4 tone bits
                    std       ,s                  save the 2 PSG command bytes for the caller
                    puls      d,pc

********************************************************************
* INKEY routine from alib
*
INKEY               clra                          std in
                    ldb       #SS.Ready
                    os9       I$GetStt            see if key ready
                    bcc       getit
                    cmpb      #E$NotRdy           no keys ready=no error
                    bne       exit@               other error, report it
                    clra                          no error
                    bra       exit@
getit               lbsr      FGETC               go get the key
                    tsta
exit@               rts

FGETC               pshs      a,x,y
                    ldy       #1                  number of char to print
                    tfr       s,x                 point x at 1 char buffer
                    os9       I$Read
                    puls      a,x,y,pc



********************************************************************
* InstallSignals
* Installs signal receiver and
* opens path to SOL driver and installs SOL lines

InstallSignals pshs      cc
               orcc      #IntMasks
               leax      cfIcptRtn,pcr
	       os9	 F$Icpt
	       lda	 #UPDAT.+SHARE.
	       leax      fsol,pcr
	       os9	 I$Open
	       bcc	 storesol@
	       os9	 F$PErr
	       tfr	 a,b
	       os9	 F$PErr
storesol@      sta	 <solpath,u
	       ldx	 #260
	       ldy	 #$A0
	       ldb	 #SS.SOLIRQ
	       os9	 I$SetStt
	       lda	 <solpath
	       puls      cc,pc

fsol	       fcc	 \/fSOL\
	       fcb	 $0D

********************************************************************
* Mute Signals
* turns off signals to this process from SOL
* use these to reduce flicker when performing longer procedures
*
MuteSignals    pshs      a,b,x,y
	       lda	 <solpath
	       ldx	 #1
	       ldb	 #SS.SOLMUTE
	       os9	 I$SetStt
	       puls      a,b,x,y
	       rts

********************************************************************
* Unmute signals
* turns signals back on
*
UnMuteSignals  pshs	 a,b,x
	       lda	 <solpath,u
	       ldx	 #0
	       ldb	 #SS.SOLMUTE
	       os9	 I$SetStt
	       puls	 a,b,x
	       rts

********************************************************************
* RemoveSignals
* clean up irqs and signal handling on exit
*
RemoveSignals  lda	 <solpath,u
	       ldx	 #260
	       ldy	 #0
	       ldb	 #SS.SOLIRQ
	       os9	 I$SetStt
	       lda	 <solpath,u
	       ldx	 #385
	       ldy	 #0
	       ldb	 #SS.SOLIRQ
	       os9	 I$SetStt
	       lda	 <solpath,u
	       os9	 I$Close
	       rts


               emod
eom            equ *
               end