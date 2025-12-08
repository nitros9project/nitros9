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
*
*   12     2025/12/08  R Taylor
* Added support for tied notes.
* Added .map file support for programming MIDI instruments.
* Added automatic instrument matching for various target keyboards and synths.
*
*   13     2025/12/11  R Taylor
* Added Ultimuse III format.  Lyra and Ultimuse use new master MIDI table.

                    nam       music
                    ttl       Music Player

 section __os9
edition = 13
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
MIDIVEL_DEFAULT     equ       80                  0..127 for MIDI velocity
PLAYLISTITEM_MAXSTR equ       255

FILETYPE_MUSICA     equ       1
FILETYPE_SIDRAW     equ       2
FILETYPE_COCOLYRA   equ       3
FILETYPE_ULTIMUSE   equ       4
FILETYPE_MIDIPATCH  equ       5

MIDI_StatusReg      equ       SAM2695.Base+MIDI_STATUS
MIDI_DataReg        equ       SAM2695.Base+MIDI_FIFO_DATA

* Byte 1 bits
LYRA_EVENTBIT       equ       %10000000
LYRA_DOTTEDNOTE     equ       %01000000
LYRA_TIEDTOLAST     equ       %00100000           Note is tied to previous note (length only)
LYRA_TRIPLETNOTE    equ       %00010000
LYRA_RESTNOTE       equ       %00001000
LYRA_LENGTHBITS     equ       %00000111
* Byte 2 bits
LYRA_FLATNOTE       equ       %10000000
LYRA_SHARPNOTE      equ       %01000000
LYRA_PITCHMASK      equ       %00111111

* 0=Treble, 1=Bass, 2=Guitenor, 3=Double Bass
* 4=Percus, 5=Alto, 6=Tenor
UMECLEF_TREBLE      equ       0
UMECLEF_BASS        equ       1
UMECLEF_GUITENOR    equ       2
UMECLEF_DBLBASS     equ       3
UMECLEF_PERCUSSION  equ       4
UMECLEF_ALTO        equ       5
UMECLEF_TENOR       equ       6

* Offsets into 8-byte track packets
TRACK_LOCATION      equ       0                   Keep this as variable 0!
TRACK_CYCLES        equ       2
TRACK_MIDICHAN      equ       4                   Lyra supports 8 tracks that can each map to any 16 MIDI channel
TRACK_MIDIPITCH     equ       5
TRACK_VELOC         equ       6
TRACK_TRIPLET       equ       7
TRACK_ENTRYSIZE     equ       8                   Bytes per track

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
FileTop             rmb       2
DoSequencer         rmb       1
DoAbort             rmb       1
Interactive         rmb       1
TotalSections       rmb       1
PlaylistMode        rmb       1
PlaylistPath        rmb       1
ThisTrack           rmb       2                   Points to current track packet
LyraChanMap         rmb       8
LyraChannel         rmb       1
LyraChannel2        rmb       1
LyraMatchTable      rmb       2
LyraTempo           rmb       1
LyraUseMap          rmb       1                   If set, .map file was processed, do not use .lyr instrument table
UMETicks            rmb       2
UMEEvents           rmb       2                   Total number of events in file
UMEEventCntr        rmb       2
UMEParts            rmb       2
UMEStaves           rmb       2
ScoreTracks         rmb       16*TRACK_ENTRYSIZE
SectionList         rmb       9*2
SampleBuf           rmb       25
HexStrDat           rmb       6
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
                    fcc       /  <file.map> apply MIDI instrument map/
                    fcb       C$CR
                    fcc       /  <file.lyr> Lyra/
                    fcb       C$CR
                    fcc       /  <file.mus> Musica II/
                    fcb       C$CR
                    fcc       /  <file.rsd> Raw SID file/
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

* These values are cleared once per program run
                    clr       <DoSequencer
                    clr       <FilePath
                    clr       <Interactive
                    clr       <DoAbort
                    clr       <PlaylistMode
                    clr       <PlaylistPath
                    clr       <LyraUseMap

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

* These values are cleared before each file play
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
                    cmpa      #FILETYPE_MIDIPATCH
                    lbeq      MidiPatch
                    cmpa      #FILETYPE_MUSICA 
                    lbeq      PlayMusica
                    cmpa      #FILETYPE_SIDRAW 
                    beq       PlaySidRaw
                    cmpa      #FILETYPE_COCOLYRA
                    lbeq      PlayLyra
                    cmpa      #FILETYPE_ULTIMUSE
                    lbeq      PlayUltimuse
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
                    stx       <FileTop
                    rts

********************************************************************
* Lyra Player
* Outputs to SAM2695 MIDI Synth chip

PlayLyra            bsr       Load2Local
                    lbcs      err                 Something went wrong, exit
                    pshs      x
                    leax      $10,x               Point to address holder of track 1
                    leay      ScoreTracks,u       Table holds Track block location, Cycles left for note/rest
                    ldb       #8
                    pshs      b
a@                  ldd       1,s                 Recall address of top of file
                    addd      ,x++                Compute (top of file + track offset)
                    std       TRACK_LOCATION,y    Save exact start of current track
                    clra
                    clrb
                    std       TRACK_CYCLES,y
                    lda       #MIDIVEL_DEFAULT    Reset velocity
                    sta       TRACK_VELOC,y
                    leay      TRACK_ENTRYSIZE,y
                    dec       ,s 
                    bne       a@
                    puls      b
                    puls      x                   Restore pointer to top of file

                    ldx       <FileTop
                    leay      $121,x              Point to Lyra channel map (8 entries)
                    sty       <LyraChanMap
                    ldb       $0007,x             Only use LSB of 16-bit tempo 
                    stb       <LyraTempo
                
                    tst       <LyraUseMap         Check if a instrument map file was loaded
                    bne       gm@                 User has applied a patch file
*                    ldx       <FileTop
*                    ldy       #28
*                    clra
*                    leax      $104,x 
*                    os9       I$Write
*                    lbsr      PrintCR
                    lbsr      MidiMuteAll
                    lbsr      SetupInstruments    Auto-sensing instrument translation
gm@                 ldb       #1                  Enable the sequencer
                    stb       <DoSequencer

LyraLooper          ldb       <DoAbort            Abort everything?
                    bne       LyraAbort
                    ldb       <DoSequencer
                    beq       LyraEnd
                    leay      ScoreTracks,u
                    lda       [TRACK_ENTRYSIZE*0,y]   When each tracks' note pointer is at a dead command (0)
                    ora       [TRACK_ENTRYSIZE*1,y]   the piece is over
                    ora       [TRACK_ENTRYSIZE*2,y]
                    ora       [TRACK_ENTRYSIZE*3,y]
                    ora       [TRACK_ENTRYSIZE*4,y]
                    ora       [TRACK_ENTRYSIZE*5,y]
                    ora       [TRACK_ENTRYSIZE*6,y]
                    ora       [TRACK_ENTRYSIZE*7,y]
                    bne       lt@
LyraEnd             clr       <DoSequencer        If we made it here it means all tracks have ended
                    lbsr      MidiMuteAll         kill the music and get out of here
                    lbra      CloseAndNext        It's not an abort, so we keep processing all supplied files
LyraAbort           clr       <DoSequencer
                    lbsr      MidiMuteAll         Yes, kill the music and get out of here
                    lbra      bye
lt@                 clr       <LyraChannel
                    ldb       #8                  Process all 8 LYRA channels
                    pshs      b
a@                  sty       <ThisTrack
                    ldy       <LyraChanMap
                    lda       <LyraChannel
                    lda       a,y                 Get the MIDI channel that this LYRA channel targets
                    ldy       <ThisTrack
                    sta       TRACK_MIDICHAN,y    The MIDI channel (0-15) this Lyra channel (0-7)targets
                    ldd       TRACK_CYCLES,y      Enter subsequencer with D = Note Cycles Remaining
                    ldx       TRACK_LOCATION,y
                    bsr       LyraSubSeq          We process all tracks even if ended, for consistent time
s@                  ldy       <ThisTrack
                    stx       TRACK_LOCATION,y    Update track's note pointer
                    std       TRACK_CYCLES,y      Update track's current note length
                    inc       <LyraChannel
                    leay      TRACK_ENTRYSIZE,y
                    dec       ,s
                    bne       a@                  Do all Lyra channels
                    puls      b
ve@                 ldx       #$0002
                    os9       F$Sleep
                    bra       LyraLooper

********************************************************************
* Lyra Sequencer
* Entry:  reg.x = pointer to current note of a LyraChannel
*         reg.d = cycles left for current note

LyraSubSeq          cmpd      #0                  Is there a note playing?
                    lbne      LyraDecCycle        Yes, decrement note timer and exit, long branch is helpful in balance
r@                  ldd       ,x                  Get current note
                    lbeq      LyraSeqExit         Note marks the end of the track,  long branch is helpful in balance
                    bita      #LYRA_EVENTBIT      Is this an event?
                    beq       c@                  No, it must be a note or rest
* Process Event Codes
                    anda      #$F0                Mask out non event bits
                    cmpa      #$E0                Is this velocity control?
                    bne       te@                 Assume this is a musical note/rest
                    andb      #7                  Make safe velocity value
                    leay      LyraVelocConv,pcr   Point to Lyra-to-MIDI velocity conversion table
                    lda       b,y                 Convert 0..7 to 0..127
                    ldy       <ThisTrack          Restore track pointer
                    sta       TRACK_VELOC,y       Set new velocity for this channel
                    bra       se@
te@                 cmpa      #$A0                Tempo event?
                    bne       se@
                    stb       <LyraTempo
                    bra       se@
ie@                 cmpa      #$90                Instrument event?
                    bne       se@
                    lda       ,x 
                    anda      #$0F                Get channel # for instrument change 
                    ora       #$C0                MIDI instrument change code
                    sta       >MIDI_DataReg
                    stb       >MIDI_DataReg
se@                 leax      2,x                 Immediately skip over Lyra Event and get next data
                    bra       r@
* Process New Note Value before issuing any Note On or Note Off commands
c@                  andb      #LYRA_PITCHMASK     Clear off the Sharp/Flat indicators and leave 0-63
                    clra
                    lslb
                    rola
                    lslb
                    rola
                    leay      LyraRange,pcr       Point to starting notes in MIDI table conversion table
                    leay      d,y                 Point to index of Lyra note
                    lda       1,y                 Get Midi note value
                    ldy       <ThisTrack      Restore track pointer
                    ldb       1,x                 Get Lyra note value
                    bitb      #LYRA_SHARPNOTE     Support situation where a note is marked Sharp AND Flat to neutralize it
                    beq       sh@
fl@                 inca                          Decrease Midi note by 1 to make Flat
sh@                 bitb      #LYRA_FLATNOTE
                    beq       p@
                    deca                          Increase Midi note by 1 to make Sharp
p@                  sta       TRACK_MIDIPITCH,y
* Process Note
gn@                 ldd       ,x                  Get current note again
                    bita      #LYRA_RESTNOTE      Is this a Note or a Rest
                    beq       ntied@              It's sound, go check whether it's tied to last note
                    lbsr      MidiRestNote        It's a rest - silence this pitch
                    bra       non@                Then jump to length calc of note
* Tied Notes Logic: Tied notes have to be the same pitch.  Lyra marks a note as being tied to the previous note.
ntied@              cmpb      3,x                 Next note Pitch is different, so it can't be tied
                    bne       dn@                 That would be called Slur which we can't do at this time
                    bita      #LYRA_TIEDTOLAST    Is the current note tied to the previous note?
                    bne       non@                This note Should already be on, don't do it twice
dn@                 lda       TRACK_MIDIPITCH,y
                    bsr       MidiNoteOn
* Process Note Length
non@                ldy       <ThisTrack
                    ldb       ,x
                    bitb      #LYRA_TRIPLETNOTE
                    beq       lb@
                    ldb       TRACK_TRIPLET,y     Get triplet note # 1-3
ftc@                incb
                    cmpb      #4
                    blo       tos@
                    ldb       #1
tos@                stb       TRACK_TRIPLET,y
                    bra       nt@
lb@                 clr       TRACK_TRIPLET,y
nt@                 ldb       TRACK_TRIPLET,y     Get triplet note # for this channel
                    leay      LyraLengths,pcr
                    lslb
                    lslb
                    lslb
                    leay      b,y
                    ldb       ,x                  Get note code
                    andb      #LYRA_LENGTHBITS    Pick off only the Length bits
                    clra                          Make 16-bit offset and note length
                    ldb       d,y                 Point to index of Lyra note
* Slow the tempo a bit but not in half.  Reduction in any way prevents 64ths
* notes from playing in a trio, so in the trio tables we use a total of 0,4,0
* instead of 1,2,1 for the 64th note lengths.
                    lda       #3                  Speed up all notes, L*.75, L*3/4
                    mul
                    lsra
                    rorb
                    lsra
                    rorb
                    ldy       <ThisTrack      Restore track pointer
                    pshs      d                   Save note length
                    lda       ,x                  Get note code 
                    anda      #LYRA_DOTTEDNOTE    Is this a dotted note length?
                    beq       l@                  No
                    ldd       ,s                  It's a dotted note, multiply it by 1.5
                    lsra                          So we add half its length To the length
                    rorb                          to yield a 50% increase
                    addd      ,s                  Adjust length for dotted note
                    std       ,s                  Save to stack just to pop it back in the next instruction?
l@                  ldd       ,s++                Pop adjusted length from stack
                    beq       sn@                 Length is zero! But how, why, when, where, who.  Skip over decrement.
LyraDecCycle        subd      #1                  Count down the note cycles
                    bne       LyraSeqExit
sn@                 ldd       2,x
                    cmpb      1,x
                    bne       nof@                That would be called Slur which we can't do at this time
                    bita      #LYRA_TIEDTOLAST    Is the next note tied to the current note?
                    bne       nxn@
nof@                lda       TRACK_MIDIPITCH,y   Next note is tied to this note
                    bsr       MidiNoteOff
nxn@                leax      2,x                 Point to the next note
                    clra
                    clrb
LyraSeqExit         rts                           Return to sequencer

MidiNoteOn          ldb       #MIDICMD_NOTE_ON    Send MIDI Note On
                    orb       TRACK_MIDICHAN,y    Get the target channel
                    stb       >MIDI_DataReg
                    sta       >MIDI_DataReg       The note value to turn on
                    ldb       TRACK_VELOC,y       Get velocity for this channel
                    stb       >MIDI_DataReg
                    rts

MidiNoteOff         ldb       #MIDICMD_NOTE_OFF
                    bra       a@
MidiRestNote        ldb       #MIDICMD_NOTE_ON    Send MIDI Note On
a@                  orb       TRACK_MIDICHAN,y    Get the target channel
                    stb       >MIDI_DataReg
                    sta       >MIDI_DataReg       The note value to turn on
                    ldb       #$00 
                    stb       >MIDI_DataReg
                    rts

MidiMuteAll         clr       ,-s                 First MIDI channel #
a@                  lda       #MIDICMD_CC         Control Change $Bx
                    ora       ,s                  Mix in the channel (x)
                    sta       >MIDI_DataReg
                    ldb       #MIDICC_ALLNOTESOFF
                    stb       >MIDI_DataReg       The note value to turn off
                    lda       #$00
                    sta       >MIDI_DataReg
                    inc       ,s
                    lda       ,s
                    cmpa      #16
                    blo       a@
                    ldd       #MIDICMD_SYSEX      Reset all channels/instruments
                    sta       >MIDI_DataReg
                    stb       >MIDI_DataReg
                    lda       #MIDIMMC_DEVICE_ALL*256+$09
                    sta       >MIDI_DataReg
                    stb       >MIDI_DataReg
                    ldd       #$01F7
                    sta       >MIDI_DataReg
                    stb       >MIDI_DataReg
                    puls      a,pc

*******************************************************************
* Ultimuse III format (originally Tandy Color Computer)
*
PlayUltimuse        lbsr      Load2Local
                    lbcs      err                 Something went wrong, exit
                    ldd       4,x                 Top time, numer
                    ldd       6,x                 Bottom time, denom, 4/4, 8/8, etc.
                    ldd       8,x                 Get number of score events
                    std       <UMEEvents          Save
                    leay      $0A,x
                    leay      4,y                 Skip over part #0
                    sty       <UMEParts           Start of voice/part/channel table
                    ldd       ,x                  Get music version and number of parts/voices
                    lda       #4
                    mul
                    leay      d,y
                    sty       <UMEStaves          Start of stave table
                    ldb       3,x                 Get number of staves
                    lda       #10
                    mul
                    leay      d,y
                    tfr       y,x                 Put start of score in reg.x

*******************************************************************
* Test: If a .map file wasn't specified, put together some kind
* of orchestra based on the clef types
                    tst       <LyraUseMap         Check if a instrument map file was loaded
                    bne       gm@                 User has applied a patch file
                    ldy       <UMEParts
                    ldb       #0
                    pshs      b
a@                  ldb       ,s
                    cmpb      #9                  Don't change sam2695 channel 10
                    beq       n@
                    lda       3,y                 Get clef type
                    cmpa      #UMECLEF_BASS       this is drum in Oh Come All Ye Faithful
                    beq       sb1@
                    cmpa      #UMECLEF_DBLBASS
                    beq       sb1@
                    cmpa      #UMECLEF_PERCUSSION     Percussion clef gets drum
                    beq       sprc@
                    cmpa      #UMECLEF_TENOR
                    beq       sten@
                    cmpa      #UMECLEF_ALTO
                    beq       salt@
*                    cmpa      #UMECLEF_GUITENOR
*                    beq       sguit@
streb@              ldb       ,s 
                    andb      #7
                    addb      #0
                    bra       i@
sguit@              ldb       ,s 
                    andb      #7
                    addb      #24
                    bra       i@
salt@               ldb       ,s 
                    andb      #7
                    addb      #65
                    bra       i@
sten@               ldb       ,s
                    andb      #7
                    addb      #66
                    bra       i@
sb1@                ldb       ,s 
                    andb      #7
                    addb      #32
                    bra       i@
sprc@               ldb       ,s
                    andb      #3
                    addb       #115
i@                  lda       ,s
                    ora       #$C0                Program the associated MIDI channel. Can this happen more than once?
                    sta       >MIDI_DataReg
                    stb       >MIDI_DataReg
n@                  leay      4,y
                    inc       ,s
                    ldb       ,s 
                    cmpb      #15 
                    bls       a@
gm@
*******************************************************************

                    ldd       #0
                    std       <UMETicks
                    std       <UMEEventCntr
                    ldb       #1                  Enable the sequencer
                    stb       <DoSequencer

UmeLooper           ldb       <DoAbort            Abort everything?
                    bne       Abort@
                    ldb       <DoSequencer
                    beq       End@
                    bra       trns@
End@                clr       <DoSequencer        If we made it here it means all tracks have ended
                    lbsr      MidiMuteAll         kill the music and get out of here
                    lbra      CloseAndNext        It's not an abort, so we keep processing all supplied files
Abort@              clr       <DoSequencer
                    lbsr      MidiMuteAll         Yes, kill the music and get out of here
                    lbra      bye
trns@               ldd       <UMETicks
                    cmpd      1,x                 Compare to this event's clock
                    beq       ev@
                    pshs      x
                    ldx       #$0002
                    os9       F$Sleep
                    puls      x
                    ldd       <UMETicks
                    addd      #2                  Increment the music clock
                    std       <UMETicks
                    bra       UmeLooper           Keep looping
* Translate Ume event into our event
ev@                 ldb       ,x                  Get event channel #
                    lbeq      next@               Skip to next event
                    decb                          Adjust event # to base 0
                    cmpb      #$0F 
                    lbhi      next@
                    lda       #TRACK_ENTRYSIZE
                    mul
                    leay      ScoreTracks,u 
                    leay      d,y 
                    sty       <ThisTrack
                    ldb       ,x
                    decb
                    stb       TRACK_MIDICHAN,y    The MIDI channel (0-15) this Lyra channel (0-7)targets
* Incomplete feature.  We don't set a note length at this time.
* Notes stop when a new one starts on the same channel.
                    ldd       #30                 Make note 1/2 second long
                    addd      1,x                 
                    std       TRACK_CYCLES,y      Enter subsequencer with D = Clock cycle to turn note off
                    lda       TRACK_MIDICHAN,y
                    ldy       <UMEParts
                    lsla
                    lsla
                    leay      a,y 
                    ldb       1,y                 Get stave # of this part
                    lda       #10
                    mul
                    ldy       <UMEStaves
                    leay      d,y                 Point to stave block for this part
                    ldb       3,y                 Get clef type for this part
                    cmpb      #UMECLEF_GUITENOR
                    beq       UmeGuitenor
                    cmpb      #UMECLEF_BASS
                    beq       UmeBass
                    cmpb      #UMECLEF_DBLBASS
                    beq       UmeDblBass
                    cmpb      #UMECLEF_ALTO
                    beq       UmeAlto
                    cmpb      #UMECLEF_TENOR
                    beq       UmeTenor
                    cmpb      #UMECLEF_PERCUSSION
                    beq       UmePercussion
                    bra       UmeTreble
UmeGuitenor         leay      Treble,pcr
                    leay      -(7*4*1),y
                    bra       UmeClef
UmeAlto             leay      Treble,pcr
                    bra       UmeClef
UmeTenor            leay      Treble,pcr
                    bra       UmeClef
UmeBass             leay      Bass,pcr
                    leay      +(7*4*1),y
                    bra       UmeClef
UmeDblBass          leay      Bass,pcr
                    leay      +(7*4*2),y
                    bra       UmeClef
UmePercussion       leay      Percussion,pcr
                    bra       UmeClef
UmeTreble           leay      Treble,pcr
UmeClef             pshs      y
                    ldb       5,x                 Slot pos on staff (Range: -15<>+15, 32=rest)
                    cmpb      #32
                    beq       UmeNote             It's a rest
* Compute note from MIDI table (each note occupies 4 bytes)
                    negb
                    sex                           Make +/- offset
                    lslb
                    rola
                    lslb
                    rola
                    addd      ,s++                Add +/- offset to base address
                    tfr       d,y
                    lda       1,y                 Get Midi note value from byte 1 (0,[1],2,3)
* Adjust MIDI note value for Sharp or Flat
                    ldb       6,x                 Pitch mod (0,1=none  2=sharp,3=dbl sharp  4,5=natural, 6=dbl flat,7=flat)
                    cmpb      #2
                    beq       UmeSharp
                    cmpb      #3
                    beq       UmeDSharp
                    cmpb      #7
                    beq       UmeFlat
                    cmpb      #6
                    beq       UmeDFlat
                    bra       UmeNote
UmeDSharp           inca
UmeSharp            inca
                    bra       UmeNote
UmeDFlat            deca
UmeFlat             deca
UmeNote             ldb       ,x                  Get 1-based channel #
                    cmpb      #10
                    bne       UmeMusicN
                    anda      #31
                    adda      #35
UmeMusicN           pshs      a
                    ldy       <ThisTrack
                    lda       TRACK_MIDIPITCH,y
                    lbsr      MidiNoteOff
                    puls      a
                    sta       TRACK_MIDIPITCH,y
                    ldb       #MIDIVEL_DEFAULT
                    stb       TRACK_VELOC,y
                    ldb       5,x
                    cmpb      #32
                    bne       nt@
                    clr       TRACK_VELOC,y
nt@                 ldb       TRACK_MIDICHAN,y
                    lbsr      MidiNoteOn
*next@               bsr       ctrl@               Debugger
next@               leax      8,x
                    ldd       <UMEEventCntr
                    addd      #1
                    std       <UMEEventCntr
                    cmpd      <UMEEvents
                    lblo      trns@
                    lbra      CloseAndNext
ctrl@
 ldb      0,x 
 lbsr PrintHex8
 ldb      1,x 
 lbsr PrintHex8
 ldb      2,x 
 lbsr PrintHex8
 ldb      3,x 
 lbsr PrintHex8
 ldb      4,x 
 lbsr PrintHex8
 ldb      5,x 
 lbsr PrintHex8
 ldb      6,x 
 lbsr PrintHex8
 ldb      7,x 
 lbsr PrintHex8
 lbsr PrintCR
 rts             

* Try to match the Lyra device string to a device code
SetupInstruments    leay      MIDITARGets+1,pcr   Point to list of 28-character device strings
                    ldx       <FileTop
                    leax      $104,x
                    pshs      y,x,d               Save table pointer and 16-bit device name pointer
ne@                 lda       -1,y                Is this the last entry in the table?
                    bmi       f@                  Yes, stop scanning
                    clra 
                    clrb
                    std       ,s                  Reset common index into matching strings
mc@                 ldx       2,s
                    ldd       ,s
                    leax      d,x
                    ldy       4,s
                    ldd       ,s
                    leay      d,y
                    lda       ,y                  Get char from table
                    cmpa      #'*                 Wildcard char
                    beq       f@                  Finish with match
                    cmpa      ,x                  Compare to char in file
                    bne       n@                  Char doesn't match, move to next table entry
                    ldd       ,s 
                    addd      #1
                    std       ,s
                    cmpd      #14
                    blo       mc@
                    bra       f@                  We've got a match
n@                  ldy       4,s
                    leay      15,y
                    sty       4,s
                    bra       ne@                 Start new entry, clear index
f@                  ldy       4,s
                    lda       -1,y
                    sta       ,s 
                    puls      d,x,y
                    leay      CASIO_CZ230S,pcr
                    ldb       #127                Last instrument # supported
                    cmpa      #MIDITARG_CZ230
                    beq       s@
                    leay      KAWAI_MS710,pcr
                    ldb       #127                Last instrument # supported
                    cmpa      #MIDITARG_MS710
                    beq       s@                  Some songs use both GM and MS710 ?
                    leay      CASIO_MT540,pcr
                    ldb       #30                 Last instrument # supported
                    cmpa      #MIDITARG_MT540
                    beq       s@
                    leay      CASIO_CT460,pcr
                    ldb       #30                 Last instrument # supported
                    cmpa      #MIDITARG_CT460
                    beq       s@
                    ldy       #$0000
                    ldb       #127
s@                  sty       <LyraMatchTable
                    pshs      y,x,b
                    ldx       <FileTop
                    leax      $24,x               Point to first Lyra instrument def
                    ldb       #16                 16 MIDI channels defined in Lyra header
                    pshs      b
a@                  lda       ,x++                Get MIDI channel # (1-digit ASCII HEX) and skip over ":"
                    suba      #'0
                    leay      ASCIIHEX,pcr
                    lda       a,y                 Get decimal value of HEX character
                    anda      #$0F                Lyra files show 16 voices in its header
                    sta       <LyraChannel2       Save as temp var
                    pshs      x
                    lbsr      ASC2Int             Read decimal ASCII value via ,x+ into reg.b
                    puls      x
                    ldy       <LyraMatchTable
                    cmpy      #$0000
                    beq       dm@
                    cmpb      1,s                 Don't set channel to use instrument out of range of target device
                    bhi       dm@
tm@                 ldb       b,y                 Translate device instrument into MIDI instrument
dm@                 lda       <LyraChannel2
                    ora       #$C0                Program the associated MIDI channel. Can this happen more than once?
                    sta       >MIDI_DataReg
                    stb       >MIDI_DataReg
nm@                 leax      14-2,x              Point to next Lyra instrument def (already skipped #: chars)
                    dec       ,s                  up to 16 MIDI channels defined
                    bne       a@
                    puls      b                   Reclaim space used for MIDI channel counter
                    puls      b,x,y,pc

********************************************************************
* ASC2Int
*   Convert Ascii Number (0-255) to Binary
*
* Passed: (X)=Ascii String ptr
* Returns: (A)=next char After Number
*          (B)=Number
*          (X)=updated Past Number
*          CC=set if Error
*
ASC2Int clrb
shgn10 lda ,x+
 suba #'0 convert ascii to binary
 cmpa #9 valid decimal digit?
 bhi shgn20 ..no; end of number
 pshs a save digit
 lda #10
 mul MULTIPLY Partial result times 10
 addb ,s+ add in next digit
 bcc shgn10 get next digit if no overflow
shgn20 
 rts

********************************************************************
* Program the sam2695 instruments from an ASCII file
* with comma/space-separated values
MidiPatch           lbsr      Load2Local
                    lbcs      err                 Something went wrong, exit
MidiPatchX          ldy       #0
a@                  bsr       ASC2Int
                    pshs      b
                    tfr       y,d
                    tfr       b,a
                    puls      b
                    ora       #$C0                Program the associated MIDI channel. Can this happen more than once?
                    sta       >MIDI_DataReg
                    stb       >MIDI_DataReg
                    leay      1,y
                    cmpy      #16
                    blo       a@
                    ldb       #-1
                    stb       <LyraUseMap
                    lbra      CloseAndNext
* Eventually put programs here for quick switching between clef types
UmePatch            fcc       "0,1,2,3,16,17,18,19,0,0,38,0,0,0,0,0;"

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

CloseAndNext        lbsr      MidiMuteAll
                    lda       <FilePath
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


* Subtract 48 from ASCII HEX digit
ASCIIHEX            fcb       0,1,2,3,4,5,6,7,8,9,0,0,0,0,0,0,0,10,11,12,13,14,15

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
                    fcb       $01               [0,4,0]       1,2,1 won't work because the 1s will reduce away by the tempo adjuster

                    fcb       $00
                    fcb       $80               [64,128,64]
                    fcb       $40               [32,64,32]
                    fcb       $20               [16,32,16]
                    fcb       $10               [8,16,8]
                    fcb       $08               [4,8,4]
                    fcb       $04               [2,4,2]
                    fcb       $02               [0,4,0]

                    fcb       $00
                    fcb       $40               [64,128,64]
                    fcb       $20               [32,64,32]
                    fcb       $10               [16,32,16]
                    fcb       $08               [8,16,8]
                    fcb       $04               [4,8,4]
                    fcb       $02               [2,4,2]
                    fcb       $01               [0,4,0]

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
* MIDI/Ultimuse/Lyra notes
* Sharps and Flats are calculated in code by inca/deca of MIDI note
*      Octave       Note Number    Note Name        Frequency Hz
*        9              127            G          12,543.8539514160
              fdb       127,12544      G8
*        9              126          F#/Gb        11,839.8215267723
*        9              125            F          11,175.3034058561
              fdb       125,11175      F8
*        9              124            E          10,548.0818212118
              fdb       124,10548      E8
*        9              123          D#/Eb	  9,956.0634791066
*        9              122            D          9,397.2725733570
              fdb       122,9397       D8
*        9              121          C#/Db        8,869.8441912599
*        9              120            C          8,372.0180896192
              fdb       120,8372       C8
*        8              119            B          7,902.1328200980
              fdb       119,7902       B8
*        8              118          A#/Bb        7,458.6201842894
*        8              117            A          7,040.0000000000
              fdb       117,7040       A8
*        8              116          G#/Ab        6,644.8751612791
*        8              115            G          6,271.92697571
              fdb       115,6272       G8
*        8              114          F#/Gb        5,919.9107633862
*        8              113            F          5,587.6517029281
              fdb       113,5588       F8
*        8              112            E          5,274.0409106059
              fdb       112,5274       E8
*        8              111          D#/Eb        4,978.0317395533
*        8              110            D          4,698.6362866785
              fdb       110,4699       D8
*        8              109          C#/Db        4,434.9220956300
*        8              108            C          4,186.0090448096
              fdb       108,4186       C8
*        7              107            B	  3,951.0664100490
              fdb       107,3951       B7
*        7              106          A#/Bb        3,729.3100921447
*        7              105            A          3,520.0000000000
              fdb       105,3520       A7
*        7              104          G#/Ab        3,322.4375806396
*        7              103            G          3,135.9634878540
              fdb       103,3136       G7
*        7              102          F#/Gb        2,959.9553816931
*        7              101            F          2,793.8258514640
              fdb       101,2794       F7
*        7              100            E          2,637.0204553030
              fdb       100,2637       E7
*        7               99          D#/Eb        2,489.0158697766
*        7               98            D          2,349.3181433393
LyraRange     fdb        98,2349       D7
*        7               97          C#/Db        2,217.4610478150
*        7               96            C          2,093.0045224048
              fdb        96,2093       C7
*        6               95            B          1,975.5332050245
              fdb        95,1976       B6
*        6               94          A#/Bb        1,864.6550460724
*        6               93            A          1,760.0000000000
              fdb        93,1760       A6
*        6               92          G#/Ab        1,661.2187903198
*        6               91            G          1,567.9817439270
              fdb        91,1568       G6
*        6               90          F#/Gb        1,479.9776908465
* High   6               89            F          1,396.9129257320
              fdb        89,1397       F6
* High   6               88            E          1,318.5102276515
              fdb        88,1319       E6
* High   6               87          D#/Eb        1,244.5079348883
* High   6               86            D          1,174.6590716696
              fdb        86,1175       D6
* High   6               85          C#/Db        1,108.7305239075
* High   6               84            C          1,046.5022612024
              fdb        84,1047       C6
* High   5               83            B            987.7666025122
              fdb        83,988        B5
* High   5               82          A#/Bb          932.3275230362
* High   5               81            A            880.0000000000
              fdb        81,880        A5
* High   5               80          G#/Ab          830.6093951599
* High   5               79            G            783.9908719635
              fdb        79,784        G5
* High   5               78           F#/Gb         739.9888454233
* Treble 5               77            F            698.4564628660
              fdb        77,698        F5
* Treble 5               76            E            659.2551138257
              fdb        76,659        E5
* Treble 5               75          D#/Eb          622.2539674442
* Treble 5               74            D            587.3295358348
              fdb        74,587        D5
* Treble 5               73          C#/Db          554.3652619537
* Treble 5               72            C            523.2511306012
              fdb        72,523        C5
* Treble 4               71            B            493.8833012561
              fdb        71,0          B4
* Treble 4               70          A#/Bb          466.1637615181
* Treble 4               69            A            440.0000000000
              fdb        69,440        A4
* Treble 4               68          G#/Ab          415.3046975799
* Treble 4               67            G            391.9954359817
              fdb        67,392        G4
* Treble 4               66          F#/Gb          369.9944227116
* Middle 4               65            F            349.2282314330
              fdb        65,349        F4
* Middle 4               64            E            329.6275569129
Treble        fdb        64,330        E4
* Middle 4               63          D#/Eb          311.1269837221
* Middle 4               62            D            293.6647679174
              fdb        62,294        D4
* Middle 4               61          C#/Db          277.1826309769
* Middle 4               60            C            261.6255653006
MiddleC       fdb        60,262        C4
* Middle 3               59            B            246.9416506281
              fdb        59,247        B3
* Middle 3               58          A#/Bb          233.0818807590
* Middle 3               57            A            220.0000000000
              fdb        57,220        A3
* Middle 3               56          G#/Ab          207.6523487900
* Middle 3               55            G            195.9977179909
Bass          fdb        55,196        G3
* Bass   3               54          F#/Gb          184.9972113558
* Bass   3               53            F            174.6141157165
Alto          fdb        53,175        F3
* Bass   3               52            E            164.8137784564
              fdb        52,165        E3
* Bass   3               51          D#/Eb          155.5634918610
* Bass   3               50            D            146.8323839587
              fdb        50,147        D3
* Bass   3               49          C#/Db          138.5913154884
* Bass   3               48            C            130.8127826503
              fdb        48,131        C3
* Bass   2               47            B            123.4708253140
              fdb        47,123        B2
* Bass   2               46          A#/Bb          116.5409403795
* Bass   2               45            A            110.0000000000
              fdb        45,110        A2
* Bass   2               44          G#/Ab          103.8261743950
* Bass   2               43            G             97.9988589954
              fdb        43,98         G2
* Low    2               42          F#/Gb           92.4986056779
* Low    2               41            F             87.3070578583
              fdb        41,87         F2
* Low    2               40            E             82.4068892282
              fdb        40,82         E2
* Low    2               39          D#/Eb           77.7817459305
* Low    2               38            D             73.4161919794
              fdb        38,73         D2
* Low    2               37          C#/Db           69.2956577442
* Low    2               36            C             65.4063913251
              fdb        36,65         C2
* Low    1               35            B             61.7354126570
              fdb        35,62         B1
* Low    1               34          A#/Bb           58.2704701898
* Low    1               33            A             55.0000000000
              fdb        33,55         A2
* Low    1               32          G#/Ab           51.9130871975
* Low    1               31            G             48.9994294977
              fdb        31,49         G1
*        1               30          F#/Gb           46.2493028390
*        1               29            F             43.6535289291
              fdb        29,44         F1
*        1               28            E             41.2034446141
              fdb        28,41         E1
*        1               27          D#/Eb           38.8908729653
*        1               26            D             36.7080959897
              fdb        26,37         D1
*        1               25          C#/Db           34.6478288721
*        1               24            C             32.7031956626
              fdb        24,33         C1
*        0               23            B             30.8677063285
              fdb        23,31         B0
*        0               22          A#/Bb           29.1352350949
*        0               21            A             27.5000000000
              fdb        21,28         A0
*        0               20          G#/Ab           25.9565435987
*        0               19            G             24.4997147489
              fdb        19,24         G0
*        0               18          F#/Gb           23.1246514195
*        0               17            F             21.8267644646
              fdb        17,22         F0
*        0               16            E             20.6017223071
              fdb        16,21         E0
*        0               15          D#/Eb           19.4454364826
*        0               14            D             18.3540479948
              fdb        14,18         D0
*        0               13          C#/Db           17.3239144361
*        0               12            C             16.3515978313
Percussion    fdb        12,16         C0
*       -1               11            B             15.4338531643
              fdb        11,15         B-1
*       -1               10          A#/Bb           14.5676175474
*       -1                9            A             13.7500000000
              fdb         9,14         A-1
*       -1                8          G#/Ab           12.9782717994
*       -1                7            G             12.2498573744
              fdb         7,12         G-1
*       -1                6          F#/Gb           11.5623257097
*       -1                5            F             10.9133822323
              fdb         5,11         F-1
*       -1                4            E             10.3008611535
              fdb         4,10         E-1
*       -1                3          D#/Eb            9.7227182413
*       -1                2            D              9.1770239974
              fdb         2,9          D-1
*       -1                1          C#/Db            8.6619572180
*       -1                0            C              8.1757989156
              fdb         0,8          C-1


* Program the MIDI instruments per the Lyra header
* Lyra has 8 virtual channels, and each one can link to any physical MIDI channel.
MIDITARGets         fcb       MIDITARG_CZ230
                    fcc       "CASIO CZ-230* "
                    fcb       MIDITARG_CZ230
                    fcc       "CZ-230*       "
                    fcb       MIDITARG_CT460
                    fcc       "CASIO CT-460* "
                    fcb       MIDITARG_MT540
                    fcc       "CASIO MT-540* "
                    fcb       MIDITARG_MS710
                    fcc       "KAWAI MS-710* "
                    fcb       MIDITARG_FB01
                    fcc       "FB-01*        "
                    fcb       MIDITARG_MT32
                    fcc       "MT-32*        "
                    fcb       MIDITARG_PSR500
                    fcc       "YAMAHA PSR*   "
                    fcb       -1

* incomplete, needs 16..99
YAMAHA_PSR500       fcb       MIDI_GRANDPIANO      00 Piano
                    fcb       MIDI_ACOUSTICPIANO   01 Flange piano
                    fcb       MIDI_HONKYTONKPIANO  02 Honky-Tonk piano
                    fcb       MIDI_ELECTRICGRAND   03 Electric piano 1
                    fcb       MIDI_ELECTRICGRAND   04 Electric piano 2
                    fcb       MIDI_ELECTRICGRAND   05 Electric piano 3
                    fcb       MIDI_HARPSICHORD     06 Harpischord 1
                    fcb       MIDI_HARPSICHORD     07 Harpischord 2
                    fcb       MIDI_CLAVINET        08 Clavi
                    fcb       MIDI_CELESTA         09 Celesta
                    fcb       MIDI_ROCKORGAN,MIDI_REEDORGAN                10-11 Pipe organ 1,2
                    fcb       MIDI_HAMMONDORGAN,MIDI_PERCUSSIVEORG,MIDI_ROCKORGAN,MIDI_CHURCHORGAN          12-15 Electronic organ 1,2,3,4

* incomplete
MT_32               fcb       MIDI_GRANDPIANO
                    fcb       36                  001 Slap bass 1
                    fcb       48                  002 String section 1
                    fcb       62                  003 Synth brass
                    fcb       65                  004 Alto sax
                    fcb       96                  005 Ice rain
                    fcb       MIDI_ELECTRICGRAND  006 Electric piano
                    fcb       76                  007 Bottle blow
                    fcb       55                  008 Ochestral hit

CASIO_MT540         fcb       MIDI_GRANDPIANO     000 Piano
                    fcb       MIDI_HARPSICHORD    001 Harpishord
                    fcb       MIDI_VIBRAPHONE     002 Vibraphone
                    fcb       MIDI_ROCKORGAN      003 Jazz Organ
                    fcb       MIDI_CHURCHORGAN    004 Pipe Organ
                    fcb       62                  005 Brass Ensemble
                    fcb       48                  006 Strings
                    fcb       73                  007 Flute
                    fcb       54                  008 Chorus
                    fcb       26                  009 Jazz Guitar
                    fcb       MIDI_TUBULARBELLS   010 Bells
                    fcb       MIDI_CLAVINET       011 Funky Clavi
                    fcb       50                  012 Metallic Sound
                    fcb       117                 013 Synthetic Ensemble
                    fcb       MIDI_RHODESPIANO    014 Percussion
                    fcb       MIDI_REEDORGAN      015 
                    fcb       21                  016 Accordion
                    fcb       36                  017 Bass/Wood/Slap
                    fcb       119                 018 Sound Effect 1-2
                    fcb       123                 019
                    fcb       MIDI_HONKYTONKPIANO 020 Honky-Tonk Piano
                    fcb       MIDI_MARIMBA        021 Marimba
                    fcb       68                  022 Oboe
                    fcb       92                  023 Synth Reed
                    fcb       46                  024 Harp
                    fcb       89                  025 Synth Celesta
                    fcb       94                  026 Synth Clavi 
                    fcb       93                  027 Metallic Sound 
                    fcb       88                  028 Fantasy 
                    fcb       95                  029 Miracle


CASIO_CT460         fcb       MIDI_GRANDPIANO     000 Piano
                    fcb       MIDI_HARPSICHORD    001 Harpishord
                    fcb       MIDI_VIBRAPHONE     002 Vibraphone
                    fcb       MIDI_ROCKORGAN      003 Jazz Organ
                    fcb       MIDI_CHURCHORGAN    004 Pipe Organ
                    fcb       62                  005 Brass Ensemble
                    fcb       73                  006 Flute
                    fcb       54                  007 Chorus
                    fcb       26                  008 Jazz Guitar?
                    fcb       MIDI_TUBULARBELLS   009 Bells
                    fcb       MIDI_CLAVINET       010 Clavi
                    fcb       93                  011 Metallic Pad
                    fcb       50                  012 Synth Strings 1
                    fcb       117                 013 Melodic Tom Drum
                    fcb       MIDI_HONKYTONKPIANO 014 Honky-Tonk Piano
                    fcb       MIDI_RHODESPIANO    015 Rhodes Piano
                    fcb       MIDI_MARIMBA        016 Marimba
                    fcb       MIDI_HAMMONDORGAN   017 Hammond Organ
                    fcb       MIDI_ACCORDION      018 Accordion
                    fcb       48                  019 String Ensemble 1
                    fcb       68                  020 Oboe
                    fcb       84                  021 Charang Lead
                    fcb       46                  022
                    fcb       89                  023
                    fcb       92                  024
                    fcb       88                  025
                    fcb       95                  026 
                    fcb       36                  027 
                    fcb       119                 028 
                    fcb       123                 029


KAWAI_MS710
*                        0-7  Piano, Strings, Flute, Harmonica, Carinet, Piano, Electric Piano, Clavis
                    fcb       MIDI_GRANDPIANO,50,73,48,71,MIDI_ACOUSTICPIANO,MIDI_ELECTRICGRAND,MIDI_CLAVINET

*                       8-15  Vibes, Jazz Organ, Rock Organ, Pipe Organ, Accordian, Alto Sax, Trumpet, Cosmic
                    fcb       MIDI_VIBRAPHONE,MIDI_ROCKORGAN,MIDI_HAMMONDORGAN,MIDI_REEDORGAN,MIDI_ACCORDION,65,56,88

*                      16-23  Banjo, Acoustic Guitar, Electric Guitar, Acoustic Bass, Electric Bass, User1-3
                    fcb       105,25,27,32,33,40,41,42

*                      24-31  User4, others...
                    fcb       43,0,25,0,28,0,48,30
* 32-39
                    fcb       0,0,33,0,0,0,0,0
* 40-47
                    fcb       0,0,0,0,0,0,0,0
* 48-55
                    fcb       0,21,0,0,0,0,0,0
* 56-63
                    fcb       0,0,0,0,0,0,0,0
* 64-71
                    fcb       0,0,0,0,0,0,0,0
* 72-79
                    fcb       73,0,0,0,0,0,0,0


CASIO_CZ230S
                    fcb       0
                    fcb       61,62,63            000-002 BRASS ENSEMBLE 1,2,3 -> Brass Section
                    fcb       55                  003 SYMPHONIC ENSEMBLE -> Orchestral Hit?
                    fcb       55                  004
                    fcb       55                  005
                    fcb       48,49               006-007 String Ensemble 1,2
                    fcb       50,51               008-009 Synth Ensemble 1,2 -> Synth Strings 1,2
                    fcb       46                  010 LT HARP -> Orchestral Harp
                    fcb       88                  011 MARS -> New Age Sound
                    fcb       MIDI_VIBRAPHONE     012 VIBRABL -> Bottle blow?
                    fcb       00                  013
                    fcb       69                  014 FUNKY HORN -> English Horn reed
                    fcb       36                  015 SLAP HORN -> Slap Bass 1
                    fcb       00                  016
                    fcb       00                  017
                    fcb       00                  018
                    fcb       00                  019
                    fcb       MIDI_ROCKORGAN,20   020-021 JAZZ ORGAN 1,2 -> Rock Organ, Reed Organ
                    fcb       MIDI_HAMMONDORGAN,MIDI_PERCUSSIVEORG               022-023 PIPE ORGAN 1,2 -> Hammond Organ, Percussive Organ
                    fcb       MIDI_ACCORDION      024 ACORDIN -> Accordian
                    fcb       52                  025 FEMCHOR -> "Aah"
                    fcb       53                  026 MALECHOR -> "Ooh"
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
                    fcb       107                 037 KOTO -> Koto
                    fcb       105                 038 SHAMISEN -> Banjo
                    fcb       15                  039 QANUN -> Dulcimer
                    fcb       70                  040 SYNTH REED -> Bassoon
                    fcb       112                 041 Pearl Drop -> Tinkle Bell?
                    fcb       65                  042 DOUBLE REED -> Alto Sax
                    fcb       00                  043
                    fcb       00                  044
                    fcb       112                 045 FANTASY 1 -> Tinkle Bell
                    fcb       113                 046 FANTASY 2 -> Agogo
                    fcb       92                  047 PLUNK EXTEND -> Bowed Pad
                    fcb       00                  048
                    fcb       00                  049
                    fcb       0,1,4,3,2           050-054 PIANOS -> Acoustic Grand, Bright Acoustic, Rhodes, Honky-Tonk, Electric Grand
                    fcb       6,6                 055-056 HARPISCHORD 1,2
                    fcb       MIDI_CLAVINET       057 SYNTH CLAVINET                  
                    fcb       00                  058
                    fcb       00                  059
                    fcb       MIDI_TUBULARBELLS   060 BELLS -> Tubular Bells
                    fcb       00                  061
                    fcb       MIDI_CELESTA        062 SYNTH CELESTA -> Celesta
                    fcb       90,88,89            063-065 SYNTH VIB 1,2,3 -> Polysynth Pad, New Age Pad, Halo Pad?
                    fcb       MIDI_VIBRAPHONE     066 BELL-LYRA -> Wood block
                    fcb       MIDI_XYLOPHONE      067 XYLOPHONE -> Xylophone
                    fcb       MIDI_XYLOPHONE      068 SOFY XYLOPHONE
                    fcb       MIDI_MARIMBA        069 MARIMBA -> Marimba
                    fcb       24,32               070-071 ACOUSTIC GUITAR 1,2 -> Acoustic Nylon Guitar, Acoustic Bass Timbre
                    fcb       26                  072 SEMI ACOUSTIC GUITAR -> Electric Jazz Guitar 
                    fcb       31                  073 FEEDBACK -> Guitar Harmonics?
                    fcb       27,28               074-075 ELECTRIC GUITAR 1,2 -> Electric Clean Guitar, Electric Muted Guitar
                    fcb       33,34               076-077 ELEC BASS -> Fingered Electric Bass Guitar, Plucked Electric Bass Guitar
                    fcb       36                  078 SLAP BASS -> Slap Bass 1
                    fcb       93                  079 METALLIC BASS -> Metallic Pad                  
                    fcb       118,118,118         080-082 SYNTH DRUMS 1,2,3 -> Synth drums
                    fcb       15                  083 SYNTH CLAPPER -> Dulcimer
                    fcb       128+54              084 TAMBOURINE -> Percussion, Tambourine
                    fcb       128+56              085 COWBELL -> Percussion, Cow Bell
                    fcb       128+64              086 CONGA -> Percussion, Low Conga
                    fcb       128+45              087 TABLA -> Percussion, Low Tom?    
                    fcb       128+63              088 AFRO PERCUSSION ->
                    fcb       114                 089 STEEL DRUM -> Steel Drums
                    fcb       00                  
                    fcb       00                  
                    fcb       127                 092 EXPLOSION -> Gun shot
                    fcb       96                  093 TYPHOON -> Rain?
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       00                  
                    fcb       0                  
                    fcb       95                  100 SWEEP -> Sweep Pad
                    fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

FILETYPES
                    fcc       ".rsd"
                    fcb       FILETYPE_SIDRAW
                    fcc       ".mus"
                    fcb       FILETYPE_MUSICA
                    fcc       ".lyr"
                    fcb       FILETYPE_COCOLYRA
                    fcc       ".ume"
                    fcb       FILETYPE_ULTIMUSE
                    fcc       ".map"
                    fcb       FILETYPE_MIDIPATCH
                    fcb       0                   Mark end of table

PrintCR             pshs      cc,d,x,y
                    lda       #0
                    ldy       #1
                    leax      CRStr,pcr
                    os9       I$WritLn
                    puls      cc,d,x,y,pc
CRStr               fcb       $0d

PrintSPC            pshs      cc,d,x,y
                    lda       #0
                    ldy       #1
                    leax      SPCStr,pcr
                    os9       I$WritLn
                    puls      cc,d,x,y,pc
SPCStr              fcb       C$SPAC

PrintHex16          pshs      y,x,b,a,cc
                    leax      HexStrDat,u

                    lda       1,s
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       Bin2AscHex
                    sta       ,x+
                    lda       1,s
                    anda      #$F
                    bsr       Bin2AscHex
                    sta       ,x+

                    lda       2,s
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       Bin2AscHex
                    sta       ,x+
                    lda       2,s
                    anda      #$F
                    bsr       Bin2AscHex
                    sta       ,x+

                    lda       #0
                    ldy       #4
                    leax      HexStrDat,u
                    os9       I$WritLn
 lbsr PrintSPC
                    puls      cc,d,x,y,pc

PrintHex8           pshs      y,x,b,a,cc
                    leax      HexStrDat,u

                    lda       2,s
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       Bin2AscHex
                    sta       ,x+
                    lda       2,s
                    anda      #$F
                    bsr       Bin2AscHex
                    sta       ,x+

                    lda       #0
                    ldy       #2
                    leax      HexStrDat,u
                    os9       I$WritLn
 lbsr PrintSPC
                    puls      cc,d,x,y,pc

Bin2AscHex          anda      #$0f
                    cmpa      #9
                    bls       d@
                    suba      #10
                    adda      #'A'
                    bra       x@
d@                  adda      #'0'
x@                  rts


                    endsect
