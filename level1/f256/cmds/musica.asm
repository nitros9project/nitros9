********************************************************************
* MUSICA II Player by Roger Taylor
* For the F256 Computer by Foenix Retro Systems
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2025/10/27  R Taylor
* Created
*
*   1      2025/10/28  R Taylor
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
MUSTOP	            RMB       2
MUSPNT	            RMB       2
MUSCLK	            RMB       2
DUR	            RMB       2
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

greeting            fcc       /MUSICA Player 0.2 by Roger Taylor/
                    fcb       $0d,0
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
                    cmpa      #'-
                    lbne      DoBusiness
                    leax      1,x
                    lda       ,x+
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

ShowHelp            lda       #0
                    leax      greeting,pcr
                    ldy       #255
                    os9       I$WritLn
                    bra       DoBusiness          This will be optimized out later

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
                    std       <DUR

                    tst       <PlaylistMode
                    beq       OpenMediaFile

                    lda       <PlaylistPath
                    leax      <PlaylistItemStr,u
                    ldy       #PLAYLISTITEM_MAXSTR
                    os9       I$ReadLn
                    lbcs      bye
                    leax      <PlaylistItemStr,u
                    stx       <cliptr

OpenMediaFile       ldx       <cliptr
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
                    stx       filesize
                    tfr       x,d
                    addd      fmemsize
                    os9       F$Mem
                    bcs       err
                    sty       fmemupper
*                    std       fmemsize            Caused each music file to be appended to process mem
                    ldd       fmemupper
                    subd      filesize
                    tfr       d,x
                    ldy       filesize
                    lda       filepath
                    os9       I$Read
                    bcs       err

                    bsr       SETMUS
                    ldy       <psg_left
                    lbsr      PSG_LOUD_ALL
                    ldy       <psg_right
                    lbsr      PSG_LOUD_ALL
                    ldb       #1
                    stb       <sequencer

keyloop@            lda       <sequencer          Listen for IRQ to signal that the song is over
                    beq       CloseAndNext
                    lbsr      INKEY  		  Inkey routine with handlers for intergace
                    cmpa      #$0D                $0D=ok shift+$0d=cancel
                    bne       keyloop@

                *     lda       <filepath           There better be a path#
                *     os9       I$Close
                *     lda       <PlaylistPath       There better be a path#
                *     os9       I$Close

bye                 clrb
err                 pshs      d,u,cc
                    orcc      #IntMasks
                    clr       <sequencer
*                    lbsr      MuteSignals
                    lbsr      RemoveSignals       Clean up and remove signals and SOL
                    ldy       <psg_left
      	            bsr	      PSG_QUIET_ALL
                    ldy       <psg_right
      	            bsr	      PSG_QUIET_ALL
*                    ldu       <SoundMem
*                    ldb       #$01                need 1 block
*                    os9       F$ClrBlk            return to OS-9 but is this needed if we're exiting a program?
                    puls      d,u,cc
                    os9       F$Exit

CloseAndNext        lda       <filepath
                    os9       I$Close
                    lbra      NextSong

SETMUS	            lda       ,x
                    bne       nd@
                    leax      5,x                  skip over DOS header
nd@                 tfr       x,d		a=page# where music waveforms start
*                    sta       <muspag
                    leax      1024,x            skip over waveforms
                    leax      5,x               skip over Default 1st block
                    STX       <MUSTOP
                    STX       <MUSPNT
                    RTS

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

MAP_IN_SOUND
                    pshs      u,cc
                    orcc      #IntMasks
                    tfr       u,y
                    ldx       #$C4
                    ldb       #$01                need 1 block
                    os9       F$MapBlk            map it into process address space
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
memerr              fcc       "MapBlk should have returned $C000"
                    fcb       $0d,$00

********************************************************************
* cfIcptRtn
* this handles the signals received by SOL
* 
cfIcptRtn
                    pshs      cc,d,x,y,u
                    LDX       <MUSPNT
                    LDB       <sequencer          MUSIC DISABLED?
                    LBEQ      IRQ800		  Don't do anything right now
                    LDD       <DUR
                    LBNE      IRQ750		  NOTE IS PLAYING
                    LDA       ,X		  GET NOTE LENGTH
                    lbeq      IRQ785		  END OF MUSIC
                    BPL       IRQ730		  GO SET UP NOTE
                    CMPA    #253		  REPEAT MUSIC
                    LBEQ      IRQ785
                    CMPA    #254		  GET CONTROL BLOCK PARAMS
                    LBNE      IRQ780
                    LBRA      IRQ780
IRQ730
n@                  TFR       A,B                 ADJUST MUSICA NOTE LENGTH TO 60HZ TIMER
                    LSRB
                    CLRA
*                    ADDD      <MUSCLK
                    STD       <DUR

                    LDD       1,X
                    beq       v1@
                    bsr       Mf2Pf
v1@                 lbsr      psgv1
                    ldy       <psg_right
                    bsr       WritePSG
                    ldy       <psg_left
                    bsr       WritePSG

                    LDD       3,X
                    beq       v2@
                    bsr       Mf2Pf
v2@                 lbsr      psgv2
                    ldy       <psg_right
                    bsr       WritePSG
                    ldy       <psg_left
                    bsr       WritePSG

                    LDD       5,X
                    beq       v3@
                    bsr       Mf2Pf
v3@                 lbsr      psgv3
                    ldy       <psg_left
                    bsr       WritePSG

                    LDD       7,X
                    beq       v4@
                    bsr       Mf2Pf
v4@                 lbsr      psgv3
                    ldy       <psg_right
                    bsr       WritePSG

                    LDD       <DUR
IRQ750              SUBD      #1
                    STD       <DUR
                    BNE       IRQ900
IRQ780              LEAX      9,X
                    STX       <MUSPNT
                    BRA       IRQ900
IRQ785              LDX       <MUSTOP             at end of song, play it again
                    STX       <MUSPNT
                    clr       <sequencer          Tell main code that the song is over
                    BRA       IRQ900
IRQ800
                    BRA       IRQ900
IRQ900              puls      cc,d,x,y,u
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
range               fcc       "out of range "
                    fcb       $0d,0

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