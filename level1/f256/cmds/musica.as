********************************************************************
* MUSICA II Player by Roger Taylor
* For the F256 Computer by Foenix Retro Systems
*
* Usage: 
*   Play one or more files from the command line:
*      musica peanuts.mus coming.mus
*
*   Play files from a text file:
*      musica -z=music_list
*
*   Play files from standard input:
*      musica -z (reads from standard input)
*   
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2025/10/27  R Taylor
* Created.
*
*          2025/10/28  R Taylor
* Added -z playlist feature.
*
*   2      2025/11/08  Boisy Gene Pitre
* Added -z playlist feature
*
*   3      2025/11/08  R Taylor / Boisy Gene Pitre
* Implemented abort.  Mini-overhaul of the sequencer.

                    nam       musica
                    ttl       Musica II Player

 section __os9
edition = 2
 endsect
  
* Here are some tweakable options
DOHELP              set       1                   1 = include help info

PLAYLISTITEM_MAXSTR equ       255

                    section   bss
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
filepath            rmb       1
filebuf             rmb       2
sequencer	    RMB       1
abort               rmb       1
interactive         rmb       1
PlaylistMode        rmb       1
PlaylistPath        rmb       1
PlaylistItemStr     rmb       PLAYLISTITEM_MAXSTR
                    endsect

                    section   code
* Place constant strings here
                    ifne      DOHELP
helpstr             fcb       C$CR
                    fcc       /Use: musica [<opts>] {file} {...}/
                    fcb       C$CR
                    fcc       /  -z = get files from standard input/
                    fcb       C$CR
                    fcc       /  -z=<file> get files from <file>/
                    fcb       C$CR
                    fcb       $0
                    endc

range               fcc       "out of range"
                    fcb       C$LF,0
memerr              fcc       "MapBlk should have returned $C000"
                    fcb       C$LF,0

ShowHelp
                    leax      helpstr,pcr
                    lbsr      PUTS
                    lbra      exit

__start
                    clra
                    clrb
                    os9       F$Mem
                    lbcs      err
                    sty       fmemupper
                    std       fmemsize

                    clr       <interactive
                    clr       <abort
                    clr       <PlaylistMode
                    stx       <clistart
GetOptions2         stx       <cliptr
GetOptions          ldx       <cliptr
                    lda       ,x
                    cmpa      #'-
                    lbne      DoBusiness
                    leax      1,x
                    lda       ,x+
                    ifne      DOHELP
                    cmpa      #'?
                    beq       ShowHelp
                    endc
                    cmpa      #'i
                    bne       oz@
                    sta       <interactive
                    bra       GetOptions2
oz@                 cmpa      #'z
                    bne       DoBusiness

Option_Z
                    lda       ,x+                 get character after 'z' and increment X
                    cmpa      #'=                 is it the file indicator?
                    bne       stdin@              branch if not
                    lda       #READ.
                    os9       I$Open              Open the playlist path
                    lbcs      err
                    stx       <cliptr
                    bra       s@
stdin@              clra
s@                  sta       <PlaylistPath
                    ldb       #1
                    stb       <PlaylistMode

DoBusiness          lbsr      MAP_IN_SOUND
                    ldd       <psg_both
                    std       <psg_out
                    clr       <sequencer
                    leax      cfIcptRtn,pcr
	            os9	      F$Icpt

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
                    beq       OpenMediaFile

                    lda       <PlaylistPath
                    leax      <PlaylistItemStr,u
                    ldy       #PLAYLISTITEM_MAXSTR
                    os9       I$ReadLn
                    bcc       ok@
                    cmpb      #E$EOF
                    lbne      err
                    lbra      bye
ok@                 stx       <cliptr

OpenMediaFile       ldx       <cliptr
                    lda       ,x
                    cmpa      #C$CR
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
                    leax      1024,x              Skip over the 4 waveforms (4*256)
                    leax      5,x                 Skip over Default tone block, can be before the waves or after, but how do we tell??
                    stx       <ScoreStart         This is where our music starts
                    stx       <ScoreCurrent       Set the running pointer

                    ldy       <psg_left
                    lbsr      PSG_LOUD_ALL
                    ldy       <psg_right
                    lbsr      PSG_LOUD_ALL
                    ldb       #1                  Enable the player
                    stb       <sequencer          Tell the ISR to PLAY THE MUSIC

keyloop@            tst       <abort              Abort everything?
                    bne       bye                 Yes, kill the sequencer, and get out of here
                    tst       <sequencer
                    beq       CloseAndNext
                    lbsr      Sequencer           keep calling the sequencer
                    ldx       #$0002
                    os9       F$Sleep
                    bra       keyloop@

*                   lbsr      INKEY  		  Inkey routine with handlers for interface
*                   ldb       <interactive
*                   beq       keyloop@            No keyboard interaction allowed
*                   cmpa      #C$CR                C$CR=ok shift+C$CR=cancel
*                   bne       keyloop@

bye                 clrb
err                 pshs      d,u,cc
                    lda       <PlaylistPath
                    os9       I$Close
                    orcc      #IntMasks
                    clr       <sequencer
                    ldy       <psg_left
      	            bsr	      PSG_QUIET_ALL
                    ldy       <psg_right
      	            bsr	      PSG_QUIET_ALL
*                   ldu       <SoundMem
*                   ldb       #$01                Return 1 block
*                   os9       F$ClrBlk            Return to OS-9 but is this needed if we're exiting a program?
                    puls      d,u,cc
exit                os9       F$Exit

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
                    ldd       #%1000000000000000  Set no freq
                    lbsr      WritePSG
                    ldd       #%1010000000000000  Set no freq
                    lbsr      WritePSG
                    ldd       #%1100000000000000  Set no freq
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
Sequencer           ldb       <sequencer          Are we allowed to play music?
                    lbeq      SeqExit		  No, then exit
                    ldx       <ScoreCurrent
                    ldd       <NoteCycles
                    bne       NextCycle		  A note is currently playing
                    ldb       ,x		  Get the new note length
                    lbeq      SeqEnd		  0 means End Of Score
                    bpl       SeqGetNote		  Go set up the note
                    cmpb      #$FD		  Barline Repeat
                    beq       SeqRepeat
                    cmpb      #$FE		  Tempo and Instruments Block
                    bne       NextNote
                    lda       5,x                 Get new tempo
                    sta       <ScoreTempo
                    bra       NextNote
SeqGetNote          clra
                    pshs      d
                    lsr       1,s
                    subd      ,s++
                    addd      #$0001
                    std       <NoteCycles

* What are we doing here... since the 76489 chip only has 3 tone channels
* and we need to hear all 4 Musica voices, we split Musica Voices 1,2 between
* both PSG channels, we send the 3rd Musica voice to the Left PSG channel,
* and the 4th Musica Voice to the Right PSG channel, all at the same time.

                    ldd       1,X                 Get Musica Voice 1 16-bit frequency
                    beq       v1@                 0 means Silence
                    bsr       Mf2Pf               Convert to 10-bit PSG tone
v1@                 bsr       psgv1               Convert to PSG Voice 1 Command bytes
                    ldy       <psg_right
                    bsr       WritePSG            Output to right
                    ldy       <psg_left
                    bsr       WritePSG            Output to left

                    ldd       3,X                 Get Musica Voice 2 16-bit frequency
                    beq       v2@                 0 means Silence
                    bsr       Mf2Pf               Convert to 10-bit PSG tone
v2@                 bsr       psgv2               Convert to PSG Voice 2 Command bytes
                    ldy       <psg_right
                    bsr       WritePSG            Output to right
                    ldy       <psg_left
                    bsr       WritePSG            Output to left

                    ldd       5,X                 Get Musica Voice 3 16-bit frequency
                    beq       v3@                 0 means Silence
                    bsr       Mf2Pf               Convert to 10-bit PSG tone
v3@                 bsr       psgv3               Convert to PSG Voice 2 Command bytes
                    ldy       <psg_left
                    bsr       WritePSG            Output to left

                    ldd       7,X                 Get Musica Voice 4 16-bit frequency
                    beq       v4@                 0 means Silence
                    bsr       Mf2Pf               Convert to 10-bit PSG tone
v4@                 bsr       psgv3               Convert to PSG Voice 2 Command bytes
                    ldy       <psg_right
                    bsr       WritePSG            Output to right

                    ldd       <NoteCycles
NextCycle           subd      #1
                    std       <NoteCycles
                    bne       SeqExit
NextNote            leax      9,x
                    stx       <ScoreCurrent
                    bra       SeqExit
SeqRepeat           ldx       <ScoreStart
                    stx       <ScoreCurrent
                    bra       SeqExit
SeqEnd              clr       <sequencer          Tell main code that the song is over
                    bra       SeqExit
SeqExit             rts

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
*                   lslb                          adjust the PSG freq after the Fconv
*                   rola
*                   lslb                          adjust the PSG freq after the Fconv
*                   rola
                    cmpd      #1023               Is the result <1024, in PSG tone range?
                    bls       g@
                    ldd       #1023               Set upper freq limit for PSG
*                   lda       #0                  Let the user know
*                   leax      range,pcr
*                   ldy     #255
*                   os9       I$WritLn
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

cfIcptRtn           ldb       #-1
                    stb       <abort
                    clr       <sequencer
                    rti

 endsect