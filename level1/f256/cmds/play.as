********************************************************************
* MUSIC Player
* For the F256 Computer by Foenix Retro Systems,
* and the Tandy Color Computer 3.
*
* Usage: 
*   Play one or more files from the command line:
*      play peanuts.mus wmtell.lyr archon.sdr
*
*   Play files from a text file:
*      play -z=music_list
*
*   Play files from standard input:
*      play -z (reads from standard input)
*
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2025/10/27  R Taylor
* Created.
*
*          2025/10/28  R Taylor
* Added -z={playlist} feature
*
*   2      2025/11/08  Boisy Gene Pitre
* Added -z playlist feature
*
*   3      2025/11/08  R Taylor / Boisy Gene Pitre
* Implemented abort.  Mini-overhaul of the sequencer.
*
*   4      2025/11/09  R Taylor
* Implemented bar repeat, section repeat.
*
*   5      2025/11/11  R Taylor
* Fixed the note lengths and tempo.
*
*   6      2025/11/13  R Taylor
* Fixed the pitch-to-tone algorithm for the SN76489.
* Added SID output.
*
*   7      2025/11/15  R Taylor
* Added "F256" build condition.  If not set, build for the CoCo+GMC Cartridge.
*
*   8      2025/11/18  R Taylor
* Added ability to play raw SID dumps (.sdr) on the F256.
*
*   9      2025/11/29  R Taylor
* Added ability to play Lyra (.lyr) files on the F256.
*
*   10     2025/11/29  R Taylor
* Morph into new "play" command, named some Lyra constants for easier tweaking.
* Added triplet handling.
*
*   11     2025/12/01  R Taylor
* Improved triplet notes. Consolidated Lyra tracker params.  Optimized code.
* Added some Lyra-to-Midi instrument matching.

                    nam       music
                    ttl       Music Player

 section __os9
edition = 11
 endsect

* Here are some tweakable options
DOHELP              set       1                   1 = include help info
SID_MAX_VOL         equ       15                  (0 = silence, 15 = loud) for all SID Voices
SID_V1_CR1          equ       %00010001           SID Voice 1 Gate
SID_V2_CR1          equ       %00010001           SID Voice 2 Gate
SID_V3_CR1          equ       %00010001           SID Voice 3 Gate
SID_V1_PULSE_DUTY   equ       $800
SID_V2_PULSE_DUTY   equ       $800
SID_V3_PULSE_DUTY   equ       $800
SID_V1_ADSR         equ       $00F0
SID_V2_ADSR         equ       $00F0
SID_V3_ADSR         equ       $00F0

LYRA_DATAOUT        equ       $ff31
LYRA_EVENTBIT       equ       %10000000
LYRA_LENGTHBITS     equ       %00000111
LYRA_MIDIVELOC      equ       80    100                 0..127 for MIDI velocity
LYRA_SHARPNOTE      equ       $80
LYRA_FLATNOTE       equ       $40
LYRA_RESTNOTE       equ       $08
LYRA_DOTTEDNOTE     equ       $40
LYRA_TIEDNOTE       equ       $20
LYRA_TRIPLETNOTE    equ       $10
* Offsets into 8-byte track packets
LYRATRK_LOCATION    equ       0
LYRATRK_CYCLES      equ       2
LYRATRK_MIDINOTE    equ       4
LYRATRK_VELOC       equ       5
LYRATRK_TRIPLET     equ       6
LYRATRK_MIDICHAN    equ       7                   Lyra supports 8 tracks that can each map to any 16 MIDI channel
LYRATRK_ENTRYSIZE   equ       8                   We need 8 bytes per track

MIDI_GRANDPIANO     equ       0
MIDI_ACOUSTICPIANO  equ       1
MIDI_ELECTRICGRAND  equ       2
MIDI_HONKYTONK      equ       3
MIDI_RHODESPIANO    equ       4
MIDI_CHORUSEDPIANO  equ       5
MIDI_HARPSICHORD    equ       6
MIDI_CLAVINET       equ       7
MIDI_CELESTA        equ       8
MIDI_GLOCKENSPIEL   equ       9
MIDI_MUSICBOX       equ       10
MIDI_VIBRAPHONE     equ       11
MIDI_TRUMPET        equ       56
MIDI_PICCOLO        equ       72
MIDI_FLUTE          equ       73
MIDI_RECORDER       equ       74
MIDI_PANFLUTE       equ       75
MIDI_BOTTLEBLOW     equ       76
MIDI_SHAKUHACHI     equ       77
MIDI_WHISTLE        equ       78
MIDI_OCARINA        equ       79

PLAYLISTITEM_MAXSTR equ       255
FILETYPE_MUSICA     equ       1
FILETYPE_SIDRAW     equ       2
FILETYPE_COCOLYRA   equ       3

                    section   bss
clistart            rmb       2
cliptr              rmb       2
fmemupper           rmb       2
fmemsize            rmb       2
filesize            rmb       2
psg_out             rmb       2
psg_left            rmb       2
psg_both            rmb       2
psg_right           rmb       2
sid_left            rmb       2
sid_both            rmb       2
sid_right           rmb       2
freq_sid1           rmb       2
freq_sid2           rmb       2
freq_sid3           rmb       2
freq_sid4           rmb       2
freq_psg1           rmb       2
freq_psg2           rmb       2
freq_psg3           rmb       2
freq_psg4           rmb       2
F256SoundBlk        rmb       2                   The F256 has some HW in high RAM
ScoreStart	    rmb       2
ScoreCurrent	    rmb       2
NoteCycles	    rmb       2                   Musica carries a chord for 1 duration
HalfCycles	    rmb       2
Dividend_High       rmb       2
Dividend_Low        rmb       2
Divisor             rmb       2
Quotient            rmb       2
Remainder           rmb       2
file_block_start    rmb       2
file_block_end      rmb       2
ScoreTempo	    rmb       1
FilePath            rmb       1
FileType            rmb       1
DoSequencer         rmb       1
DoAbort             rmb       1
Interactive         rmb       1
TotalSections       rmb       1
PlaylistMode        rmb       1
PlaylistPath        rmb       1
ThisLyraTrack       rmb       2                   Points to current track packet
LyraChanMap         rmb       8
LyraChannel         rmb       1
LyraChannel2        rmb       1
MidiInstrument      rmb       1
LyraTracks          rmb       16*LYRATRK_ENTRYSIZE
SectionList         rmb       9*2
SampleBuf           rmb       25
PlaylistItemStr     rmb       PLAYLISTITEM_MAXSTR
                    endsect

                    section   code
* Place constant strings here
                    ifne      DOHELP
helpstr             fcb       C$CR
                    fcc       /Music Player by Roger Taylor/
                    fcb       C$CR
                    fcc       /Use: play [<opts>] {file} {...}/
                    fcb       C$CR
                    fcc       /  -z = get files from standard input/
                    fcb       C$CR
                    fcc       /  -z=<file> get files from <file>/
                    fcb       C$CR
                    fcb       $0
                    endc

*range              fcc       "out of range"
*                   fcb       C$LF,0

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
                    stx       <clistart

                    clr       <DoSequencer
                    clr       <FilePath
                    clr       <Interactive
                    clr       <DoAbort
                    clr       <PlaylistMode
                    clr       <PlaylistPath

                    ldd       #-1                 -1 means no MMU block is currently mapped in
                    std       <file_block_start

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
                    sta       <Interactive
                    bra       GetOptions2
oz@                 cmpa      #'z
                    bne       DoBusiness

Option_Z            lda       ,x+                 get character after 'z' and increment X
                    cmpa      #'=                 is it the file indicator?
                    bne       stdin@              branch if not
                    lda       #READ.
                    os9       I$Open              Open the playlist path
                    lbcs      err
*                    stx       <cliptr
                    bra       s@
stdin@              clra
s@                  sta       <PlaylistPath
                    stx       <cliptr
                    ldb       #1
                    stb       <PlaylistMode

DoBusiness          lbsr      SET_SOUND_REGS
                    leax      cfIcptRtn,pcr
	            os9	      F$Icpt

NextSong            clr       <DoSequencer
                    clr       <TotalSections
                    clra
                    clrb
                    std       <SectionList
                    std       <SectionList+2
                    std       <SectionList+4
                    std       <SectionList+6
                    stb       <SectionList+8
                    std       <freq_psg1
                    std       <freq_psg2
                    std       <freq_psg3
                    std       <freq_psg4
                    std       <freq_sid1
                    std       <freq_sid2
                    std       <freq_sid3
                    std       <freq_sid4

                    lbsr      QUIET_ALL
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
                    clr       <FileType
                    lda       ,x
                    cmpa      #C$CR
                    lbeq      bye
b@                  leay      FILETYPES,pcr
d@                  lda       ,x                  Get 1st char of sliding window of ".ext"
                    beq       o@
                    cmpa      #32
                    beq       o@
                    cmpa      #C$CR
                    beq       o@
                    cmpa      ,y                  Compare 1st char against current table entry
                    bne       n@
                    lda       1,x
                    lbsr      toLower
                    cmpa      1,y                 Compare 2nd char
                    bne       n@
                    lda       2,x
                    lbsr      toLower
                    cmpa      2,y                 Compare 3rd char
                    bne       n@
                    lda       3,x
                    lbsr      toLower
                    cmpa      3,y                 Compare 4th char
                    bne       n@
                    lda       4,y
                    sta       <FileType
                    bra       o@
n@                  leay      5,y
                    ldb       ,y
                    bne       d@
                    leax      1,x
                    bra       b@
o@                  ldx       <cliptr
                    lda       #READ.
                    os9       I$Open
                    lbcs      err
                    stx       <cliptr
                    sta       <FilePath

                    lda       <FileType
                    cmpa      #FILETYPE_MUSICA 
                    lbeq      PlayMusica
                    cmpa      #FILETYPE_SIDRAW 
                    beq       PlaySidRaw
                    cmpa      #FILETYPE_COCOLYRA 
                    lbeq      PlayLyra
                    lbra      CloseAndNext        Filename extension not recognized, skip song

PlaySidRaw          lbsr      LOUD_ALL
PlaySidR2           leax      SampleBuf,u
                    ldy       #25
                    lda       <FilePath
                    os9       I$Read
                    lbcs      CloseAndNext

                    ldy       <sid_both
                    ldd       ,x 
                    exg       a,b
                    lbsr      WriteSIDV1F
                    ldd       2,x 
                    exg       a,b
                    lbsr      WriteSIDV1W
                    ldd       5,x 
                    lbsr      WriteSIDV1A
                    lda       4,x 
                    sta       4,y 

                    ldd       7,x 
                    exg       a,b
                    lbsr      WriteSIDV2F
                    ldd       7+2,x 
                    exg       a,b
                    lbsr      WriteSIDV2W
                    ldd       7+5,x 
                    lbsr      WriteSIDV2A
                    lda       7+4,x 
                    sta       7+4,y 

                    ldd       14,x 
                    exg       a,b
                    lbsr      WriteSIDV3F
                    ldd       14+2,x 
                    exg       a,b
                    lbsr      WriteSIDV3W
                    ldd       14+5,x 
                    lbsr      WriteSIDV3A
                    lda       14+4,x 
                    sta       14+4,y 

                    lda       22,x 
                    sta       22,y
                    lda       23,x 
                    sta       23,y 
                    lda       24,x 
                    sta       24,y 

                    ldx       #$0002
                    os9       F$Sleep
                    bra       PlaySidR2

Load2Local          ldb       #SS.Size
                    lda       <FilePath
                    pshs      u
                    os9       I$GetStt
                    tfr       u,x
                    puls      u
                    lbcs      err
                    stx       <filesize
                    tfr       x,d
                    addd      <fmemsize
                    os9       F$Mem
                    lbcs      err
                    sty       <fmemupper
                    ldd       <fmemupper
                    subd      <filesize
                    tfr       d,x
                    ldy       <filesize
                    lda       <FilePath
                    os9       I$Read
                    rts

********************************************************************
* Lyra Player
* Outputs to SAM2695 MIDI Synth chip

PlayLyra            bsr       Load2Local
                    lbcs      err                 Something went wrong, exit
                    pshs      x
                    leax      $10,x               Point to address holder of track 1
                    leay      LyraTracks,u        Table holds Track block location, Cycles left for note/rest
                    ldb       #8
                    pshs      b
a@                  ldd       1,s                 Recall address of top of file
                    addd      ,x++                Compute (top of file + track offset)
                    std       LYRATRK_LOCATION,y                Save exact start of current track
                    clra
                    clrb
                    std       LYRATRK_CYCLES,y
                    lda       #LYRA_MIDIVELOC     Reset velocity
                    sta       LYRATRK_VELOC,y
                    leay      8,y
                    dec       ,s 
                    bne       a@
                    puls      b
                    puls      x                   Restore pointer to top of file

                    leay      $121,x              Point to Lyra channel map (8 entries)
                    sty       <LyraChanMap
                    lbsr      MidiMuteAll

                    ldd       $104,x
                    cmpd      #$435A              "CZ"
                    bne       gm@                 Unknown MIDI device, don't remap instruments
                    ldd       $106,x
                    cmpd      #$2D32              "-2"
                    bne       gm@                 Unknown MIDI device, don't remap instruments
                    ldd       $108,x
                    cmpd      #$3330              "30"
                    bne       gm@                 Unknown MIDI device, don't remap instruments
                    lbsr      Lyra2MidiInst       Match Lyra instruments to closest MIDI match
gm@
                    ldb       #1                  Enable the sequencer
                    stb       <DoSequencer

LyraTracker         tst       <DoAbort            Abort everything?
                    bne       LyraAbort
                    tst       <DoSequencer
                    beq       LyraEnd
                    leay      LyraTracks,u
                    ldd       [0,y]
                    bne       v1@
                    ldd       [8,y]
                    bne       v1@
                    ldd       [16,y]
                    bne       v1@
                    ldd       [24,y]
                    bne       v1@
                    ldd       [32,y]
                    bne       v1@
                    ldd       [40,y]
                    bne       v1@
                    ldd       [48,y]
                    bne       v1@
                    ldd       [56,y]
                    bne       v1@
LyraEnd             clr       <DoSequencer        If we made it here it means all tracks have ended
                    lbsr      MidiMuteAll
                    lbra      CloseAndNext        It's not an abort, so we keep processing all supplied files
LyraAbort           clr       <DoSequencer
                    lbsr      MidiMuteAll         Yes, kill the sequencer, and get out of here
                    lbra      bye
v1@                 clr       <LyraChannel
                    ldb       #8                  Process all 8 channels
                    pshs      b
a@                  sty       <ThisLyraTrack
                    ldy       <LyraChanMap
                    lda       <LyraChannel
                    lda       a,y 
                    ldy       <ThisLyraTrack
                    sta       LYRATRK_MIDICHAN,y  The MIDI channel this Lyra channel targets
                    ldd       LYRATRK_CYCLES,y    Enter subsequencer with D = Note Cycles Remaining
                    ldx       LYRATRK_LOCATION,y
                    bsr       LyraSubSeq          We process all tracks even if ended, for consistent time
s@                  ldy       <ThisLyraTrack
                    stx       LYRATRK_LOCATION,y  Update track's note pointer
                    std       LYRATRK_CYCLES,y    Update track's current timer
                    inc       <LyraChannel
                    leay      LYRATRK_ENTRYSIZE,y
                    dec       ,s
                    bne       a@                  Do all Lyra channels
                    puls      b
ve@                 ldx       #$0002
                    os9       F$Sleep
                    bra       LyraTracker

********************************************************************
* Lyra Sequencer
* Entry:  reg.x = pointer to current note of a LyraChannel
*         reg.d = cycles left for current note

LyraSubSeq          cmpd      #0                  Is there a note playing?
                    lbne      LyraNextCycle       Yes, decrement note timer and exit
r@                  ldd       ,x                  Time for a new note
                    bne       ce@                 Check for event
                    lbra      LyraSeqExit         Note marks the end of the track, just exit
ce@                 bita      #LYRA_EVENTBIT      Is this an event?
                    beq       c@                  No, assume its a note or rest
* Process Event Codes
                    anda      #%11100000          Is this a Velocity Change event?
                    cmpa      #%11100000
                    bne       se@                 Assume this is a musical note/rest
                    lda       1,x                 Get new velocity
                    anda      #7
                    leay      LyraVelocConv,pcr   Point to Lyra-to-MIDI velocity conversion table
                    lda       a,y                 Convert 0..7 to 0..127
                    ldy       <ThisLyraTrack      Point to table of channel velocities
                    sta       LYRATRK_VELOC,y     Set new velocity for this channel
se@                 leax      2,x                 Immediately skip over Lyra Event and get next data
                    bra       r@
* Process Note Value
c@                  ldb       1,x
                    andb      #63                 This will expand into full MIDI notes 0-127
                    clra
                    lslb
                    rola
                    lslb
                    rola
                    leay      LyraConvTab,pcr     Point to note conversion table
                    leay      d,y                 Point to index of Lyra note
                    lda       1,y                 Get Midi note value
                    ldb       1,x                 Get Lyra note value
                    bitb      #LYRA_SHARPNOTE     Support situation where a note is marked Sharp AND Flat to neutralize it
                    beq       sh@
fl@                 deca                          Decrease Midi note by 1 to make Flat
sh@                 bitb      #LYRA_FLATNOTE
                    beq       p@
                    inca                          Increase Midi note by 1 to make Sharp
p@                  ldy       <ThisLyraTrack
                    sta       LYRATRK_MIDINOTE,y  Track new note
* Process Note Length
                    ldb       ,x
                    bitb      #LYRA_RESTNOTE      Is this a Note or a Rest
                    beq       non@                BEQ means bit 8 is clear (it's a note)
                    bsr       MidiNoteOff         It's a rest - turn off the note (reg.a should still hold the note)
                    bra       nl@
non@                lda       #$90                It's a Note
                    ora       LYRATRK_MIDICHAN,y
                    sta       >LYRA_DATAOUT
                    lda       LYRATRK_MIDINOTE,y
                    sta       >LYRA_DATAOUT
                    lda       LYRATRK_VELOC,y     Get velocity for this channel
                    sta       >LYRA_DATAOUT
nl@                 lda       ,x
                    bita      #LYRA_TRIPLETNOTE
                    beq       lb@
* Process Triplet Note Length (Method 1)
                    ldb       LYRATRK_TRIPLET,y   Get triplet note # 1-3
ftc@                incb
                    cmpb      #4
                    blo       tos@
                    ldb       #1
tos@                stb       LYRATRK_TRIPLET,y
                    bra       nt@
lb@                 clr       LYRATRK_TRIPLET,y
nt@                 ldb       LYRATRK_TRIPLET,y   Get triplet note # for this channel
                    leay      LyraLengths,pcr
                    lslb
                    lslb
                    lslb
                    leay      b,y
*                   lda       ,x                  Get note code (got it at nl@)
                    anda      #LYRA_LENGTHBITS    Pick off only the Length bits
                    ldb       a,y                 Point to index of Lyra note
                    lda       #3                  {5} (Length*6)/4
                    mul                           {11}
                    lsra                          {2}
                    rorb                          {2}
                    lsra                          {2}
                    rorb                          {2} {{24}}
                    pshs      d
                    lda       ,x                  Get note code 
                    anda      #LYRA_DOTTEDNOTE    Is this a dotted note length?
                    beq       l@                  No
                    ldd       ,s                  It's a dotted note, multiply it by 1.5
                    lsra                          So we add half its length To the length
                    rorb
                    addd      ,s                  Adjust length for dotted note
                    std       ,s
l@                  ldd       ,s++                Convert into 60hz ticks
                    beq       sn@
LyraNextCycle       subd      #1                  Count down the note cycles
                    bne       LyraSeqExit
*                   lda       ,x
*                   bita      #LYRA_TIEDNOTE      Is next note tied to current note?
*                   beq       st@                 It's tied, so don't release current note
sn@                 ldy       <ThisLyraTrack
                    lda       LYRATRK_MIDINOTE,y
                    bsr       MidiNoteOff         It was a normal note and needs to be turned off now
st@                 clra
                    clrb
                    leax      2,x
LyraSeqExit         rts

MidiNoteOff         pshs      a
                    lda       #$80
                    ora       LYRATRK_MIDICHAN,y
                    sta       >LYRA_DATAOUT
                    lda       ,s 
                    sta       >LYRA_DATAOUT       The note value to turn off
                    lda       #$00
                    sta       >LYRA_DATAOUT
                    puls      a,pc

* Also resets instruments to defaults
MidiMuteAll         clr       ,-s                 MIDI channel #
a@                  lda       #$B0
                    ora       ,s
                    sta       >LYRA_DATAOUT
                    ldb       #$7B
                    stb       >LYRA_DATAOUT       The note value to turn off
                    lda       #$00
                    sta       >LYRA_DATAOUT
                    inc       ,s
                    lda       ,s
                    cmpa      #16
                    blo       a@
* F0 7E 7F 09 01 F7
                    ldd       #$F07E
                    sta       >LYRA_DATAOUT
                    stb       >LYRA_DATAOUT
                    ldd       #$7F09
                    sta       >LYRA_DATAOUT
                    stb       >LYRA_DATAOUT
                    ldd       #$01F7
                    sta       >LYRA_DATAOUT
                    stb       >LYRA_DATAOUT
                    puls      a,pc

* Lyra has 8 virtual channels, and each one can link to any physical MIDI channel.
Lyra2MidiInst       pshs      x
                    leax      $24,x               Point to first Lyra instrument def
                    ldb       #8
                    pshs      b
a@                  lda       ,x                  Get Lyra channel # in ASCII
                    suba      #'0
                    leay      ASCIIHEX,pcr
                    lda       a,y
                    anda      #$0F                Lyra files show 16 voices in its header
                    sta       <LyraChannel2
                    ldb       2,x                 Get 1st digit in ASCII numeric instr #
                    subb      #'0
                    lda       #100
                    mul
                    pshs      d                   Save 100's place 
                    ldb       3,x                 Get 2nd digit in ASCII numeric instr #
                    subb      #'0
                    lda       #10
                    mul
                    addd      ,s                  Add 10's place
                    std       ,s 
                    clra
                    ldb       4,x                 Get 3rd digit in ASCII numeric instr #
                    subb      #'0
                    addd      ,s++                Add 1's place
                    tstb
                    beq       nn@
                    decb
nn@                 leay      CASIO_CZ230S,pcr
                    andb      #127
                    ldb       b,y
                    stb       <MidiInstrument
                    ldy       <LyraChanMap
                    clrb
b@                  lda       ,y+
                    cmpa      <LyraChannel2
                    bne       c@
                    tfr       b,a
                    ora       #$C0
                    sta       >LYRA_DATAOUT
                    lda       <MidiInstrument
                    sta       >LYRA_DATAOUT
c@                  incb
                    cmpb      #8
                    blo       b@
                    leax      14,x                Point to next Lyra instrument def
                    dec       ,s                  up to 8 Lyra channels
                    bne       a@
                    puls      b,x,pc

* Subtract 48 from ASCII HEX digit
ASCIIHEX            fcb       0,1,2,3,4,5,6,7,8,9,0,0,0,0,0,0,0,10,11,12,13,14,15

********************************************************************
* Musica Player
* Outputs to both SIDs on F256, or Game Master Cartridge on CoCo

PlayMusica          lbsr      Load2Local
                    lbcs      err                 Something went wrong, exit
                    lda       ,x                  Examine first byte of file
                    bne       nd@                 Is non-zero, not a LOADM header
                    leax      5,x                 Skip over the DOS LOADM header
nd@                 tfr       x,d
                    leax      1024,x              Skip over the 4 waveforms (4*256)
                    leax      5,x                 Skip over Default tone block, can be before the waves or after, but how do we tell??
                    stx       <ScoreStart         This is where our music starts
                    stx       <ScoreCurrent       Set the running pointer
                    lda       #32
                    sta       <ScoreTempo

                    lbsr      LOUD_ALL
                    ldb       #1                  Enable the sequencer
                    stb       <DoSequencer

keyloop@            tst       <DoAbort            Abort everything?
                    bne       bye                 Yes, kill the sequencer, and get out of here
                    tst       <DoSequencer
                    beq       CloseAndNext
                    bsr       MusicaSeq           Keep calling the sequencer
                    ldx       #$0002
                    os9       F$Sleep
                    bra       keyloop@

*                   ldb       <Interactive
*                   beq       keyloop@            No keyboard interaction allowed
*                   lbsr      INKEY  		  Inkey routine with handlers for interface
*                   cmpa      #C$CR               C$CR=ok shift+C$CR=cancel
*                   bne       keyloop@

bye                 clrb
err                 pshs      d,u
                    lda       <PlaylistPath
                    os9       I$Close
                    clr       <DoSequencer
      	            lbsr      QUIET_ALL
*                   ldu       <F256SoundBlk
*                   ldb       #$01                Return 1 block
*                   os9       F$ClrBlk            Return to OS-9 but is this needed if we're exiting a program?
                    puls      d,u
exit                os9       F$Exit

CloseAndNext        lda       <FilePath
                    os9       I$Close
                    lbra      NextSong

********************************************************************
* Musica Sequencer
*

MusicaSeq           ldb       <DoSequencer        Are we allowed to play music?
                    lbeq      SeqExit             No, then exit
                    ldx       <ScoreCurrent
                    ldd       <NoteCycles
                    lbne      MusicaNxtCyc        A note is currently playing
                    ldb       ,x                  Get the new note length
                    lbeq      MusicaSeqEnd        0 means End Of Score
                    bpl       SeqGetNote          Go set up the note
                    cmpb      #$FB                Repeat a Section
                    beq       MusicaSeqRepSct
                    cmpb      #$FC                Section Marker (up to 9 tracked)
                    beq       SeqAddSection
                    cmpb      #$FE		  Tempo and Instruments Block
                    beq       SeqSetTempo
                    cmpb      #$FD		  Barline Repeat
                    beq       MusicaSeqRepBar
                    bra       SeqNextNote         Skip the unknown block

MusicaSeqRepSct     ldb       #$F0                Make into unused block code, ignored on next passby
                    stb       ,x
                    ldb       1,x                 Get the Section # to repeat (1-9)
                    beq       SeqNextNote         Is out of range
                    cmpb      #9
                    bhs       SeqNextNote         Is out of range
                    leay      <SectionList,u
                    lslb
                    ldx       b,y                 Get the section # to repeat (1-9)
                    bra       SeqNextNote

MusicaSeqRepBar     ldb       #$F0                Make into unused block code, ignored on next passby
                    stb       ,x
                    ldx       <ScoreStart
                    stx       <ScoreCurrent
                    bra       SeqExit

SeqAddSection       ldb       <TotalSections
                    cmpb      #9
                    lbhs      SeqNextNote         Can't add more than 9 sections, ignore
                    leay      <SectionList,u
                    lslb
                    leay      b,y 
                    tfr       x,d
                    addd      #9                  Section starts at next note
                    std       ,y                  Store current score address in section slot
                    inc       <TotalSections
                    bra       SeqNextNote

SeqSetTempo         lda       5,x                 Set new tempo
                    sta       <ScoreTempo
                    bra       SeqNextNote

SeqGetNote          lda       <ScoreTempo
                    mul                           Multipy note length by the current tempo
                    lsra                          Divide by 128 to get # of 60hz cycles for the note duration
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    std       <NoteCycles         Update the cycles counter
                    cmpd      #0                  Note has no length...
                    beq       SeqExit             So just exit
                    lsra
                    rorb
                    std       <HalfCycles         Planned: play 2 notes in sequence on same channel

                ifne f256
                    bsr       SetSIDChord
                    lbsr      PlaySIDChord
                else
                    bsr       SetPSGChord
                    lbsr      PlayPSGChord
                endc

GetCycles           ldd       <NoteCycles
MusicaNxtCyc        subd      #1
                    std       <NoteCycles
                    bne       SeqExit
SeqNextNote         leax      9,x
                    stx       <ScoreCurrent
                    bra       SeqExit
MusicaSeqEnd        clr       <DoSequencer        Current song is over
*                   bra       SeqExit
SeqExit             rts


********************************************************************
* This section translates the Musica pitches into their respective SID frequencies

SetSIDChord         ldd       1,X                 Get Musica Voice 1 16-bit frequency
                    beq       v1@                 0 means Silence
                    bsr       Mf2SID              Convert to 16-bit SID tone
v1@                 std       <freq_sid1
                    ldd       3,X                 Get Musica Voice 2 16-bit frequency
                    beq       v2@                 0 means Silence
                    bsr       Mf2SID              Convert to 16-bit SID tone
v2@                 std       <freq_sid2
                    ldd       5,X                 Get Musica Voice 3 16-bit frequency
                    beq       v3@                 0 means Silence
                    bsr       Mf2SID              Convert to 16-bit SID tone
v3@                 std       <freq_sid3
                    ldd       7,X                 Get Musica Voice 4 16-bit frequency
                    beq       v4@                 0 means Silence
                    bsr       Mf2SID              Convert to 16-bit SID tone
v4@                 std       <freq_sid4
                    rts

SetPSGChord         ldd       1,X                 Get Musica Voice 1 16-bit frequency
                    beq       v1@                 0 means Silence
                    bsr       Mf2PSG              Convert to 10-bit PSG tone
v1@                 std       <freq_psg1
                    ldd       3,X                 Get Musica Voice 2 16-bit frequency
                    beq       v2@                 0 means Silence
                    bsr       Mf2PSG              Convert to 10-bit PSG tone
v2@                 std       <freq_psg2
                    ldd       5,X                 Get Musica Voice 3 16-bit frequency
                    beq       v3@                 0 means Silence
                    bsr       Mf2PSG              Convert to 10-bit PSG tone
v3@                 std       <freq_psg3
                    ldd       7,X                 Get Musica Voice 4 16-bit frequency
                    beq       v4@                 0 means Silence
                    bsr       Mf2PSG              Convert to 10-bit PSG tone
v4@                 std       <freq_psg4
                    rts

********************************************************************
* Translate a Musica Pitch into a SID freq
* pitch / 674
* or ((pitch * 10129) / 65536) * 10
* or (pitch * 10129) then take upper 16 bits of 32-bit result and * 10

Mf2SID              std       $FEE0               Put pitch in MULT-A
                    ldd       #10129              pitch * 10129
                    std       $FEE2               Put multiplier in MULT-B
                    ldd       $FEF0               Get upper 16 bits of 32-bit result
                    std       $FEE0               Put back in MULT-A
                    ldd       #10
                    std       $FEE2               Put 10 in MULT-B 
                    ldd       $FEF2               Get lower 16-bit of result
                    rts

********************************************************************
* Translate a Musica Pitch into a SN76489 tone
* 60250 / (Pitch / 22)  Generates precise SN76489 tones, but the lowest octaves aren't supported.
* 60250 / (Pitch / 11)  Generates more SN76489 tones but we have to go 1 octave higher.

* Perform (662750 / x)   (60250 / (x/11))   A 1CDE
* Perform (723000 / x)   (60250 / (x/12))   B 0838
* Perform (1325500 / x)  (60250 / (x/22))  14 39BC
Mf2PSG
                ifeq      f256
                    std       <Divisor
                    ldd       #$000A
                    std       <Dividend_High
                    ldd       #$1CDE
                    std       <Dividend_Low
                    lbsr      DIV32_16
                    ldd       <Quotient
                    rts
                else
                    std       $FEE6               Store pitch as numerator
*                   ldd       #22                 Low octave, grindy
*                   ldd       #11                 Higher octave, more accurate
                    ldd       #12                 Best sounding, but notes are a bit off scale
                    std       $FEE4               Denominator
                    ldd       $FEF4               Get answer
                    std       $FEE4               Store answer as new denominator
                    ldd       #60250
                    std       $FEE6               Numerator
                    ldd       $FEF4               Quotient
                    cmpd      #1023               Is the result <1024, in PSG tone range?
                    bls       g@
                    ldd       #1023               Set upper freq limit for PSG
g@                  rts
                endc

********************************************************************
* This section outputs the 4 translated pitches into a stereo chord for the SIDs.
* The order in which we write may enhance the stereo effect.

PlaySIDChord        ldy       <sid_right
                    ldd       <freq_sid1
                    bsr       WriteSIDV1F
                    lda       #SID_V1_CR1
                    bsr       WriteSIDV1G         Gate this tone

                    ldy       <sid_right
                    ldd       <freq_sid2
                    bsr       WriteSIDV2F
                    lda       #SID_V2_CR1
                    bsr       WriteSIDV2G         Gate this tone

                    ldy       <sid_right
                    ldd       <freq_sid3
                    bsr       WriteSIDV3F
                    lda       #SID_V3_CR1
                    ldy       <sid_right
                    bsr       WriteSIDV3G         Gate this tone

                    ldy       <sid_left
                    ldd       <freq_sid4
                    bsr       WriteSIDV3F
                    lda       #SID_V3_CR1
                    bsr       WriteSIDV3G         Gate this tone

                    ldy       <sid_left
                    ldd       <freq_sid2
                    bsr       WriteSIDV2F
                    lda       #SID_V2_CR1
                    bsr       WriteSIDV2G         Gate this tone

                    ldy       <sid_left
                    ldd       <freq_sid1
                    lbsr      WriteSIDV1F
                    lda       #SID_V1_CR1
                    lbsr      WriteSIDV1G         Gate this tone
                    rts

WriteSIDV1F         sta       1,y 
                    stb       ,y 
                    rts
WriteSIDV2F         sta       7+1,y 
                    stb       7,y 
                    rts
WriteSIDV3F         sta       14+1,y 
                    stb       14,y 
                    rts

WriteSIDV1W         sta       3,y 
                    stb       2,y 
                    rts
WriteSIDV2W         sta       7+3,y 
                    stb       7+2,y 
                    rts
WriteSIDV3W         sta       14+3,y 
                    stb       14+2,y 
                    rts

WriteSIDV1A         std       5,y
                    rts
WriteSIDV2A         std       7+5,y
                    rts
WriteSIDV3A         std       14+5,y
                    rts

WriteSIDV1G         sta       4,y
                    rts
WriteSIDV2G         sta       7+4,y
                    rts
WriteSIDV3G         sta       14+4,y
                    rts

********************************************************************
* This section outputs the 4 translated pitches into a stereo chord for the SN76489 chip(s).
* For the COCO version we output Musica Voices 1-3 to their respective GMC voice.
* For the F256 version we split Musica Voices 1-4 between two chips for a stereo effect.

PlayPSGChord
v1@                 ldd       <freq_psg1
                    bsr       psgv1               Convert to PSG Voice 1 Command bytes
                ifne f256
                    ldy       <psg_right
                    bsr       WritePSG            Output to right
                    ldy       <psg_left
                    bsr       WritePSG            Output to left
                else
                    ldy       <psg_both
                    bsr       WritePSG            Output
                endc
v2@                 ldd       <freq_psg2
                    bsr       psgv2               Convert to PSG Voice 2 Command bytes
                ifne f256
                    ldy       <psg_right
                    bsr       WritePSG            Output to right
                    ldy       <psg_left
                    bsr       WritePSG            Output to left
                else
                    ldy       <psg_both
                    bsr       WritePSG            Output
                endc
v3@                 ldd       <freq_psg3
                    bsr       psgv3               Convert to PSG Voice 3 Command bytes
                ifne f256
                    ldy       <psg_left
                    bsr       WritePSG            Output to left
                else
                    ldy       <psg_both
                    bsr       WritePSG            Output
                endc
                ifne f256
v4@                 ldd       <freq_psg4
                    bsr       psgv3               Convert to PSG Voice 3 Command bytes
                    ldy       <psg_right
                    bsr       WritePSG            Output to right
                endc
                    rts

********************************************************************
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
* This routine is correct.  The SN76489 takes commands in sequences.
* We first write reg.a, then we write reg.b  TO THE SAME ADDRESS.
*
WritePSG            sta       ,y
                    stb       ,y
                    rts

********************************************************************
* cfIcptRtn
* this handles the signals received to our app
*
cfIcptRtn           ldb       #-1
                    stb       <DoAbort
                    clr       <DoSequencer
                    rti

SIDINIT             pshs      a                   Save volume on stack
                    ldy       <sid_right
                    bsr       SidInz
                    ldy       <sid_left
                    lda       ,s+                 Use same volume for both channels
SidInz              sta       24,y                Set max vol
                    lda       #$00
                    lbsr      WriteSIDV1G
                    lda       #$00
                    lbsr      WriteSIDV2G
                    lda       #$00
                    lbsr      WriteSIDV3G
                    ldd       #SID_V1_ADSR
                    lbsr      WriteSIDV1A
                    ldd       #SID_V2_ADSR
                    lbsr      WriteSIDV2A
                    ldd       #SID_V3_ADSR
                    lbsr      WriteSIDV3A
                    ldd       #SID_V1_PULSE_DUTY
                    lbsr      WriteSIDV1W
                    ldd       #SID_V2_PULSE_DUTY
                    lbsr      WriteSIDV2W
                    ldd       #SID_V3_PULSE_DUTY
                    lbsr      WriteSIDV3W
                    rts

LOUD_ALL
                ifne f256
                    lda       #SID_MAX_VOL
                    lbsr      SIDINIT
                    ldy       <psg_left
                    bsr       PSG_LOUD
                    ldy       <psg_right
                    bra       PSG_LOUD
                else
                    ldy       <psg_both
                    bra       PSG_LOUD
                endc

PSG_LOUD            ldd       #$B090
                    lbsr      WritePSG
                    ldd       #$D0FF
                    lbra      WritePSG

QUIET_ALL
                ifne f256
                    lda       #$00                Volume
                    lbsr      SIDINIT
                    ldy       <psg_left
                    bsr       PSG_QUIET
                    ldy       <psg_right
                    bra       PSG_QUIET
                else
                    ldy       <psg_both
                    bra       PSG_QUIET
                endc

PSG_QUIET           ldd       #$9FBF
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

********************************************************************
* Set up the sound registers depending on whether this program was
* built for a CoCo or the F256
*
SET_SOUND_REGS      pshs      u,cc
                    tfr       u,y
                ifne      f256
                    orcc      #IntMasks
                    ldx       #$C4
                    ldb       #$01                Ask for 1 block
                    os9       F$MapBlk            Map it into process address space
                    stu       <F256SoundBlk
                    leau      $200,u              Compute address of PSG Left channel
                    stu       <psg_left,y
                    leau      $08,u               Compute address of PSG Dual channel
                    stu       <psg_both,y
                    leau      $08,u               Compute address of PSG Right channel
                    stu       <psg_right,y
                    ldu       <F256SoundBlk
                    stu       <sid_left,y         Compute address of SID Left channel
                    leau      $80,u
                    stu       <sid_both,y         Compute address of SID Dual channel
                    leau      $80,u
                    stu       <sid_right,y        Compute address of SID Right channel
                    ldu       <F256SoundBlk
                    cmpu      #$C000              Give a noncritical mem warning
                    beq       x@
                    lda       #0
                    leax      memerr,pcr
                    ldy       #255
                    os9       I$WritLn
                    bra       x@
memerr              fcc       "MapBlk should have returned $C000"
                    fcb       C$LF,0
                else
                    ldu       #$ff00            CoCo HW base
                    lda       $7f,u		Read current MPI slot Selection
                    anda      #$f0		Preserve CTS value, select slot 1 for SCS
                    sta       $7f,u		Set new slot selection
                    lda       $01,u             Enable Cartridge Sound
                    anda      #247
                    sta       $01,u
                    lda       $03,u
                    ora       #$08
                    sta       $03,u
                    lda       $23,u
                    ora       #$08
                    sta       $23,u
                    leax      $41,u               GMC w/single SN76489 chip @ $FF41
                    stx       <psg_both,y
                endc
x@                  puls      cc,u,pc

********************************************************************
* Convert Alpha Char to Lowercase
*
toLower             cmpa      #'A
                    blo       x@
                    cmpa      #'Z
                    bhi       x@
                    ora       #32
x@                  rts

********************************************************************
* 32/16 Division Routine
*
DIV32_16            pshs      x
                    clr      <Quotient+1
                    clr      <Quotient
                    clr      <Remainder+1
                    clr      <Remainder
                    lda      <Divisor+1
                    ora      <Divisor
                    beq      DIV_BY_ZERO_ERROR    Handle error if divisor is zero
                    ldd      <Dividend_High
                    std      <Remainder
                    ldx      #16                  Loop counter
DIV_LOOP            lsl      <Remainder+1
                    rol      <Remainder
                    lsl      <Dividend_Low+1
                    rol      <Dividend_Low
                    bcc      a@
                    inc      <Remainder+1 
a@                  ldd      <Remainder           Load remainder into D
                    cmpd     <Divisor             Compare with divisor
                    blt      NO_SUBTRACT          If remainder < divisor, skip subtraction
                    subd     <Divisor
                    std      <Remainder
                    lsl      <Quotient+1
                    rol      <Quotient
                    inc      <Quotient+1          Set the least significant bit of quotient
                    bra      END_LOOP
NO_SUBTRACT         lsl      Quotient+1
                    rol      <Quotient
END_LOOP            leax     -1,x
                    bne      DIV_LOOP
DIV_BY_ZERO_ERROR   puls     x,pc


MapInBlockAnywhere  pshs      cc,d,x,u            Preserve u
                    ldu       <file_block_start
                    cmpu      #-1
                    beq       a@
                    pshs      d,x
                    ldb       #1
                    os9       F$ClrBlk
                    puls      d,x
a@                  clra
                    tfr       d,x                 Block # to map in
                    ldu       5,s
                    ldb       #$01                need 1 block
                    os9       F$MapBlk            map it into process address space
                    stu       <file_block_start
                    tfr       u,y
                    leau      $2000,u
                    stu       <file_block_end
                    puls      cc,d,x,u,pc

WritePSG1           pshs      a,b,x,y,u           preserve u
                    ldx       #$C4
                    ldb       #$01                need 1 block
                    os9       F$MapBlk            map it into process address space
                    lda       ,s                  Get byte to write
                    sta       $200,u
                    sta       $210,u
                    ldb       #1
                    os9       F$ClrBlk
                    puls      a,b,x,y,u,pc

LyraLengths         fcb       $00               No length
                    fcb       $80               Whole
                    fcb       $40               Half
                    fcb       $20               Quarter
                    fcb       $10               8th
                    fcb       $08               16th
                    fcb       $04               32nd
                    fcb       $02               64th

TrioLengths         fcb       $00
                    fcb       $40               [64,128,64]
                    fcb       $20               [32,64,32]
                    fcb       $10               [16,32,16]
                    fcb       $08               [8,16,8]
                    fcb       $04               [4,8,4]
                    fcb       $02               [2,4,2]
                    fcb       $00               [0,4,0]

                    fcb       $00
                    fcb       $80               [64,128,64]
                    fcb       $40               [32,64,32]
                    fcb       $20               [16,32,16]
                    fcb       $10               [8,16,8]
                    fcb       $08               [4,8,4]
                    fcb       $04               [2,4,2]
                    fcb       $04               [0,4,0]

                    fcb       $00
                    fcb       $40               [64,128,64]
                    fcb       $20               [32,64,32]
                    fcb       $10               [16,32,16]
                    fcb       $08               [8,16,8]
                    fcb       $04               [4,8,4]
                    fcb       $02               [2,4,2]
                    fcb       $00               [0,4,0]

* Conversion table for Lyra volume (0-15) into MIDI velocity (0-127)
LyraVelocConv       fcb       0
                    fcb       40
                    fcb       50
                    fcb       60
                    fcb       70
                    fcb       80
                    fcb       90
                    fcb       100

**********************************************************
* CoCo Lyra note, Midi Note #, Hz
*
LyraConvTab         fdb       $62,1175                    $00/Lyra  =  D6/Note  =  $62/Midi
                    fdb       $60,1047                    $01       =  C6       =  $60
                    fdb       $5F,988                     $02       =  B5       =  $5F
                    fdb       $5D,880                     $03       =  A5       =  $5D
                    fdb       $5B,784                     $04       =  G5       =  $5B
                    fdb       $59,698                     $05       =  F5       =  $59
                    fdb       $58,659                     $06       =  E5       =  $58
                    fdb       $56,587                     $07       =  D5       =  $56
                    fdb       $54,523                     $08       =  C5       =  $54
                    fdb       $53,494                     $09       =  B4       =  $53
                    fdb       $51,440                     $0A       =  A4       =  $51
                    fdb       $4F,392                     $0B       =  G4       =  $4F
                    fdb       $4D,349                     $0C       =  F4       =  $4D
                    fdb       $4C,330                     $0D       =  E4       =  $4C
                    fdb       $4A,294                     $0E       =  D4       =  $4A
                    fdb       $48,262                     $0F       =  C4       =  $48
                    fdb       $47,247                     $10       =  B3       =  $47
                    fdb       $45,220                     $11       =  A3       =  $45
                    fdb       $43,196                     $12       =  G3       =  $43 
                    fdb       $41,175                     $13       =  F3       =  $41
                    fdb       $40,165                     $14       =  E3       =  $40
                    fdb       $3E,147                     $15       =  D3       =  $3E
                    fdb       $3C,131                     $16       =  C3       =  $3C
                    fdb       $3B,123                     $17       =  B2       =  $3B
                    fdb       $39,110                     $18       =  A2       =  $39
                    fdb       $37,98                      $19       =  G2       =  $37
                    fdb       $35,87                      $1A       =  F2       =  $35
                    fdb       $34,82                      $1B       =  E2       =  $34
                    fdb       $32,73                      $1C       =  D2       =  $32
                    fdb       $30,65                      $1D       =  C2       =  $30
                    fdb       $2F,62                      $1E       =  B1       =  $2F
                    fdb       $2D,55                      $1F       =  A1       =  $2D
                    fdb       $2B,49                      $20       =  G1       =  $2B
                    fdb       $29,44                      $21       =  F1       =  $29
                    fdb       $28,41                      $22       =  E1       =  $28
                    fdb       $26,37                      $23       =  D1       =  $26
                    fdb       $24,33                      $24       =  C1       =  $24 
                    fdb       $23,31                      $25       =  B0       =  $23
                    fdb       $21,28                      $26       =  A0       =  ?
                    fdb       $1F,27                      $27       =  G0       =  ?
                    fdb       $1D,26                      $28       =  F0       =  ?
                    fdb       $1C,25                      $29       =  E0       =  ?
                    fdb       $1A,24                      $2A       =  D0       =  ?
                    fdb       $18,23                      $2B       =  C0       =  ? 
                    fdb       $17,22                       $2C       =  B-1
                    fdb       $15,21                       $2D       =  A-1
                    fdb       $13,20                       $2E       =  G-1
                    fdb       $11,19                       $2F       =  F-1
                    fdb       $10,18                       $30       =  E-1
                    fdb       $0E,17                       $31       =  D-1
                    fdb       $0C,16                       $32       =  C-1
                    fdb       $0B,15                       $33       =  B-1

* Lyra to Midi Instrument # lookup table
* MidiInstrument = LYRAMIDIINSTR[LyraInstrument]
CASIO_CZ230S
                    fcb       61                  000 BRASS ENSEMBLE -> Brass Section
                    fcb       61                  001 
                    fcb       61                  002 
                    fcb       62                  003
                    fcb       62                  004
                    fcb       63                  005
                    fcb       48                  006 String Ensemble 1
                    fcb       49                  007 String Ensemble 2
                    fcb       50                  008 Synth Ensemble 1
                    fcb       51                  009 Synth Ensemble 1
                    fcb       46                  010 LT HARP -> Orchestral Harp
                    fcb       88                  011 MARS -> New Age Sound
                    fcb       11                  012 VIBRABL -> Bottle blow?
                    fcb       00                  013
                    fcb       69                  014 FUNKY HORN -> English Horn reed
                    fcb       36                  015 SLAP HORN -> Slap Bass 1
                    fcb       00                  016
                    fcb       00                  017
                    fcb       00                  018
                    fcb       00                  019
                    fcb       11                  020 GLOKEN -> 9 Glockenspiel is too loud, 13 Xylophone is like a stick hitting 
                    fcb       00                  021
                    fcb       16                  022 PIPE ORGAN 1
                    fcb       17                  023 PIPE ORGAN 2
                    fcb       21                  024 ACORDIN -> Accordian
                    fcb       21                  025 FEMCHOR -> Choir?
                    fcb       52                  026 
                    fcb       00                  027
                    fcb       00                  028
                    fcb       00                  029
                    fcb       56                  030 TRUMPET -> Trumpet
                    fcb       73                  031 FLUTE -> Flute
                    fcb       78                  032 WHISTLE
                    fcb       40                  033 VIOLIN
                    fcb       42                  034 CELLO -> Cello
                    fcb       22                  035 BLUES HARMONICA -> Harmonica
                    fcb       77                  036 Sakuhac -> Shakuhach
                    fcb       00                  037
                    fcb       00                  038
                    fcb       00                  039
                    fcb       70                  040 SYNTH REED -> Bassoon
                    fcb       00                  041
                    fcb       00                  042
                    fcb       00                  043
                    fcb       00                  044
                    fcb       00                  045
                    fcb       00                  046
                    fcb       00                  047
                    fcb       00                  048
                    fcb       00                  049
                    fcb       00                  050 PIANO
                    fcb       01                  051 PIANO
                    fcb       00                  052 PIANO                  
                    fcb       03                  053 HONKEY TONK PIANO
                    fcb       02                  054 ELECTRIC PIANO
                    fcb       06                  055 HARPISCHORD 1
                    fcb       06                  056 HARPISCHORD 2
                    fcb       07                  057 SYNTH CLAVINET                  
                    fcb       00                  058
                    fcb       00                  059
                    fcb       14                  060 BELLS -> Tubular Bells
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       13                  067 XYLOPHONE -> Xylophone
                    fcb       15                  068 SOFY XYLOPHONE
                    fcb       12                  069 MARIMBA -> Marimba
                    fcb       00                  070
                    fcb       00                  071
                    fcb       00                  072 
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       33                  077 ELECBAS -> Fingered Electric Bass Guitar
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       21                  081 ACORDIN ->  Accordian
                    fcb       11                  082 SYNTH DRUMS
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       73                  088 PIPE -> Piccolo
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       56                  092 TRUMPET -> Trumpet
                    fcb       69                  093 FUNKHRN -> French Horn
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       95                  100 SWEEP -> Sweep Pad
                    fcb       00                  
                    fcb       9                   102 Glock -> Glockenspiel
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       77                  108 Sakuhac -> Shakuhachi
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       119                 120 Cymbal -> Reverse Cymbal
                    fcb       00                  121
                    fcb       00                  122
                    fcb       00                  123
                    fcb       00                  124
                    fcb       00                  125
                    fcb       00                  126
                    fcb       00                  127

FILETYPES
                    fcc       ".sdr"
                    fcb       FILETYPE_SIDRAW
                    fcc       ".mus"
                    fcb       FILETYPE_MUSICA
                    fcc       ".lyr"
                    fcb       FILETYPE_COCOLYRA
                    fcb       0                   Mark end of table

                    endsect
