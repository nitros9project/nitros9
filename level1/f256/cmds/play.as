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
*
*  14      2025/12/15  R Taylor
* Adjusted Ultimuse clef offsets in master MIDI table.
* Aded -d# debug mode: any value currently shows tracker for Ultimuse.
* Added MIDI filter switch -m# where # is the additive bit mask of the MIDI channels allowed to output.
* -m1 = only channel 1   (0000000000000001)
* -m5 = channels 1 and 3 (0000000000000101)
* -m65535 = all channels (1111111111111111)


                    nam       music
                    ttl       Music Player

 section __os9
edition = 14
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
MIDITABENTSIZ       equ       4                   MIDI Note Table entry size in bytes
MIDITABOCTSIZ       equ       7*MIDITABENTSIZ     MIDI Note Table octave size in bytes

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
UMECLEF_GUITAR      equ       2
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
*HalfCycles	    rmb       2
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
Interactive         rmb       1
TotalSections       rmb       1
PlaylistMode        rmb       1
PlaylistPath        rmb       1
ThisTrack           rmb       2                   Points to current track packet
LyraChannel         rmb       1
LyraChannel2        rmb       1
LyraMatchTable      rmb       2
LyraTempo           rmb       1
UMETicks            rmb       2
UMEEventTot         rmb       2                   Total number of events in file
UMEEventCntr        rmb       2
UMEPartsTot         rmb       1
UMEPartsAdr         rmb       2
UMEStavesAdr        rmb       2
UMEScoreStart       rmb       2
UMEEndOfScore       rmb       2
UMETranspose        rmb       2                   Signed offset
flgUseMapFile       rmb       1                   If set, .map file was processed, do not use .lyr instrument table
DoSequencer         rmb       1
DoAbort             rmb       1
DebugMode           rmb       1
MIDIMask1           rmb       1
MIDIMask2           rmb       1
MIDIChanMap         rmb       16
UMEPartClefs        rmb       16                  Table of clef #'s for each numbered part 0-15
UMEClefTable        rmb       2*8                 Table of 8 Ultimuse clef type pointers
SectionList         rmb       9*2
ScoreTracks         rmb       16*TRACK_ENTRYSIZE
PlaylistItemStr     rmb       PLAYLISTITEM_MAXSTR
HexStrDat           rmb       6
SampleBuf           rmb       25

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
                    fcc       /  {file}.map apply MIDI patch for subsequent scores on command line/
                    fcb       C$CR
                    fcc       /  {file}.ume = Ultimuse/
                    fcb       C$CR
                    fcc       /  {file}.lyr = Lyra/
                    fcb       C$CR
                    fcc       /  {file}.mus = Musica/
                    fcb       C$CR
                    fcc       /  {file}.rsd = raw SID dump/
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
                    clr       <DebugMode
                    clr       <DoSequencer
                    clr       <FilePath
                    clr       <Interactive
                    clr       <DoAbort
                    clr       <PlaylistMode
                    clr       <PlaylistPath
                    clr       <flgUseMapFile
                    ldd       #-1                 -1 means no MMU block is currently mapped in
                    std       <file_block_start
                    ldd       #-1
                    std       <MIDIMask1

GetOptions2         stx       <cliptr
GetOptions          ldx       <cliptr
                    lda       ,x
                    cmpa      #'-
                    lbne      DoBusiness
                    leax      1,x
                    lda       ,x+

                    ifne      DOHELP
                    cmpa      #'?
                    lbeq      ShowHelp
                    endc

                    cmpa      #'i
                    beq       Option_i
                    cmpa      #'d
                    beq       Option_d
                    cmpa      #'m
                    beq       Option_m
                    cmpa      #'z
                    beq       Option_z
                    bra       DoBusiness

Option_i            sta       <Interactive
                    bra       GetOptions2
Option_d            lbsr      ASC2Int
                    stb       <DebugMode
                    bra       GetOptions2
Option_m            lbsr      GetAscInt16
                    std       <MIDIMask1
                    stx       <cliptr
                    bra       GetOptions2
Option_z            lda       ,x+                 get character after 'z' and increment X
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

* Compute the run-time address of the MIDI Clef bases
* This affects the entire sound of Ultimuse scores
                    leay      MidiTrebE,pcr          Center is 2 notes above Middle C
                    sty       UMEClefTable+0,u
                    leay      +(1*MIDITABOCTSIZ),y   go 1 octave lower
                    sty       UMEClefTable+4,u       2 Guitar Clef base
                    leay      MidiBassG,pcr          Center is 10 notes below Middle C
                    sty       UMEClefTable+2,u       1 Bass Clef base
                    leay      +(1*MIDITABOCTSIZ),y   go 1 octave lower
                    sty       UMEClefTable+6,u       3 Double Bass Clef base
                    leay      MidiAlto,pcr           Center is 4 notes below Middle C
                    sty       UMEClefTable+10,u      5 Alto Clef base
                    leay      MidiTenor,pcr          Center is 6 notes below Middle C
                    sty       UMEClefTable+12,u      6 Tenor Clef base
                    leay      MidiPerc,pcr
                    sty       UMEClefTable+8,u       4 Percussion Clef base
                    leay      MidiPerc,pcr
                    sty       UMEClefTable+14,u      7 undocumented Clef type?

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
                    lbsr      ClearTracks

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
 stb <UMEPartsTot
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
                    sty       <MIDIChanMap
                    ldb       $0007,x             Only use LSB of 16-bit tempo 
                    stb       <LyraTempo
                    tst       <flgUseMapFile      Check if instrument map file was loaded
                    bne       gm@                 User has applied a patch file
                    lbsr      MidiMuteAll
                    lbsr      SetupInstruments    Auto-sensing instrument translation
gm@                 ldb       #1                  Enable the sequencer
                    stb       <DoSequencer

********************************************************************
* Main sequencer
*
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
                    ldy       <MIDIChanMap
                    lda       <LyraChannel
                    lda       a,y                 Get the MIDI channel that this LYRA channel targets
                    ldy       <ThisTrack
                    sta       TRACK_MIDICHAN,y    The MIDI channel (0-15) this Lyra channel (0-7)targets
                    ldd       TRACK_CYCLES,y      Enter subsequencer with D = Note Cycles Remaining
                    ldx       TRACK_LOCATION,y
                    bsr       LyraSubSeq          We process all tracks even if ended
s@                  ldy       <ThisTrack
                    stx       TRACK_LOCATION,y    Update track's note pointer
                    std       TRACK_CYCLES,y      Update track's current note length
                    inc       <LyraChannel
                    leay      TRACK_ENTRYSIZE,y
                    dec       ,s
                    bne       a@                  Do all Lyra channels
                    puls      b
 lbsr DebugNotes
ve@                 ldx       #$0002
                    os9       F$Sleep
                    bra       LyraLooper

********************************************************************
* Lyra subsequencer
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
dn@                 bsr       MidiNoteOn
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
nof@
*                lda       TRACK_MIDIPITCH,y   Next note is tied to this note
                    bsr       MidiNoteOff
nxn@                leax      2,x                 Point to the next note
                    clra
                    clrb
LyraSeqExit         rts                           Return to sequencer

MidiNoteOn          ldb       #MIDICMD_NOTE_ON    Send MIDI Note On
                    orb       TRACK_MIDICHAN,y    Get the target channel
                    stb       >MIDI_DataReg
                    lda       TRACK_MIDIPITCH,y
                    sta       >MIDI_DataReg       The note value to turn on
                    ldb       TRACK_VELOC,y       Get velocity for this channel
                    stb       >MIDI_DataReg
                    rts

MidiNoteOff         ldb       #MIDICMD_NOTE_OFF
                    bra       a@
MidiRestNote        ldb       #MIDICMD_NOTE_ON    Send MIDI Note On
a@                  orb       TRACK_MIDICHAN,y    Get the target channel
                    stb       >MIDI_DataReg
                    lda       TRACK_MIDIPITCH,y
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

ClearTracks         pshs      x,y
                    leay      ScoreTracks,u
                    ldx       #TRACK_ENTRYSIZE*16
c@                  clr       ,y+
                    leax      -1,x
                    bne       c@
                    puls      x,y,pc

MultYxD             pshs      d,y
                    ldd       ,s
a@                  addd      ,s
                    leay      -1,y
                    bne       a@
                    std       ,s
x@                  puls      d,y,pc

*******************************************************************
* Ultimuse III format (originally Tandy Color Computer)
*
PlayUltimuse        lbsr      Load2Local
                    lbcs      err                 Something went wrong, exit
                    clr       <UMETranspose
                    clr       <UMETranspose+1
                    lda       ,x                  Get UME version
*                    sta       <UMEVersion
                    ldd       4,x                 Top time, numer
                    ldd       6,x                 Bottom time, denom, 4/4, 8/8, etc.
                    ldd       8,x                 Get number of score events
                    std       <UMEEventTot        Save total event count
                    leay      $0A,x               Skip over first 10 control bytes in file
                    leay      4,y                 Skip over unused part #0
                    sty       <UMEPartsAdr        Set start of part/voice table
                    ldb       1,x                 Get number of music parts
                    stb       <UMEPartsTot        Save
                    lslb
                    lslb
                    leay      b,y
                    sty       <UMEStavesAdr       Save start of stave table
                    ldb       3,x                 Get number of staves
                    lda       #10                 There are 10 bytes per staff entry
                    mul
                    leay      d,y
                    sty       <UMEScoreStart
                    ldy       <UMEEventTot
                    ldd       #8
                    lbsr      MultYxD            Multiply total events by 8
                    addd      <UMEScoreStart
                    std       <UMEEndOfScore
                    tfr       d,y
                    ldb       ,x                 Get UME level
                    cmpb      #7
                    blo       UmeKick
                    leay      2,y                 secmin            2     /* Speed scale factor in "seconds per minute" */
                    leay      16,y                array instvals[]  16    /* 16 bytes for patch change numbers */
                    leay      160,y               array instnames[] 16*10 /* array of 16*10 for 10 byte incl \0
                    leay      16,y                array chans[]     16    /* array of 16 midi channels, 1 per part */
                    sty       <MIDIChanMap
                    leay      16,y                array levels[]    16    /* array of 16 midi vel levels lo-hi */
                    leay      1,y                 short ntlines     1     /* Num of Title line (4 here) */
                    leay      1,y                 short ntlenp1     1     /* length of line 51 + \0 */
                    leay      208,y               char  Titles[]    208   /* Actual 4 lines, 4*51 chars+\0 */
                    leay      8,y                 array genvols[]   8     /* GenVols[], Same as levels[]
                    leay      17,y                array percs[]     17    /* 17 1-byte midi notes nums for the slots of the percussion staff */
                    leay      24,y                char  percsynth   24    /* Synth name incl \0 */
                    leay      1,y                 short scrclock    1     /* not real sure on this one, it has something to do with perc clock */
                    ldd       ,y
                    ldd       1,y
                    std       <UMETranspose
                    leay      2,y                 transp            2     /* Transposer semi-tones */
UmeKick             lbsr      BuildClefMap
                    lbsr      PrintClefs

*******************************************************************
* Test: If a .map file wasn't specified, put together some kind
* of orchestra based on the clef types
                    tst       <flgUseMapFile      Check if instrument map file was loaded
                    bne       UmeStart            User has already applied a patch file
                    leay      UMEPartClefs,u
                    ldb       #0
                    pshs      b
a@                  lda       ,y+                 Get clef type
                    ldb       ,s
                    cmpb      #9                  Don't change sam2695 channel 10
                    beq       n@
                    cmpa      #UMECLEF_BASS       this is drum in Oh Come All Ye Faithful
                    beq       sb1@
                    cmpa      #UMECLEF_DBLBASS
                    beq       sb2@
                    cmpa      #UMECLEF_PERCUSSION     Percussion clef gets drum
                    beq       sprc@
                    cmpa      #UMECLEF_TENOR
                    beq       sten@
                    cmpa      #UMECLEF_ALTO
                    beq       salt@
                    cmpa      #UMECLEF_GUITAR
                    beq       sguit@
streb@              ldb       ,s
                    andb      #1
                    addb      #56    54     85
                    bra       i@
sguit@              ldb       ,s 
                    andb      #3
                    addb      #27
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
                    andb      #3
                    addb      #32
                    bra       i@
sb2@                ldb       ,s 
                    andb      #3
                    addb      #32
                    bra       i@
sprc@               ldb       ,s
                    andb      #3
                    addb       #115
i@                  lda       ,s
                    ora       #$C0                Program the associated MIDI channel
                    sta       >MIDI_DataReg
                    stb       >MIDI_DataReg
n@                  inc       ,s
                    ldb       ,s 
                    cmpb      <UMEPartsTot
                    blo       a@

UmeStart            ldx       <UMEScoreStart
                    ldd       #0
                    std       <UMETicks
                    std       <UMEEventCntr
                    ldb       #1                  Enable the sequencer
                    stb       <DoSequencer

UmeLooper           ldb       <DoAbort            Abort everything?
                    bne       Abort@
                    ldb       <DoSequencer
                    beq       End@
                    bra       trns1@
End@                clr       <DoSequencer        If we made it here it means all tracks have ended
                    lbsr      MidiMuteAll         kill the music and get out of here
                    lbra      CloseAndNext        It's not an abort, so we keep processing all supplied files
Abort@              clr       <DoSequencer
                    lbsr      MidiMuteAll         Yes, kill the music and get out of here
                    lbra      bye
trns1@
 lbsr DebugNotes
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
ev@
                    ldb       ,x                  Get event channel #1-16
                    lbeq      next@               Skip to next event
                    decb                          Adjust event # to base 0
                    cmpb      <UMEPartsTot        Is channel between 0..15?
                    lbhs      next@               Out of range, skip
                    lda       #TRACK_ENTRYSIZE    We use MUL in case track entry size changes
                    mul
                    leay      ScoreTracks,u 
                    leay      d,y 
                    sty       <ThisTrack
                    ldb       ,x
                    decb
                    stb       TRACK_MIDICHAN,y
                    leay      Powers,pcr 
                    lslb
                    ldd       b,y
                    ldy       <ThisTrack
                    bita      <MIDIMask1
                    bne       mf@
                    bitb      <MIDIMask2
                    lbeq      next@
* Incomplete feature.  We don't set a note length at this time.
* Notes stop when a new one starts on the same channel.
mf@                 ldd       #30                 test: make note 1/2 second long
                    addd      1,x                 Add note length to current clock
                    std       TRACK_CYCLES,y      Enter subsequencer with D = clock cycle to turn note off
                    lda       TRACK_MIDICHAN,y
                    leay      UMEPartClefs,u
                    ldb       a,y
*                    andb      #3                  Force 0-7
                    lslb
                    leay      UMEClefTable,u
                    ldy       b,y
                    ldb       5,x                 Slot pos on staff (clef type?) (Range: -15<>+15, 32=rest)
                    cmpb      #32
                    beq       UmeNote             It's a rest
                    pshs      y
                    negb                          MIDI table is in reverse than signed staff position
                    sex                           Make 16-bit signed offset
                    lslb                          Each note occupies 4 bytes
                    rola                          Quickly multiply by MIDITABENTSIZ (4)
                    lslb
                    rola
                    addd      ,s++                Compute note from the unsigned clef base
                    tfr       d,y                 Make into index reg
                    lda       1,y                 Get Midi note value from byte 1 of note (0,[1],2,3)
                    ldb       6,x                 Pitch mod (0,1=none  2=sharp,3=dbl sharp  4,5=natural?, 6=dbl flat,7=flat)
                    cmpb      #2
                    beq       UmeSharp
                    cmpb      #3
                    beq       UmeDSharp
                    cmpb      #7
                    beq       UmeFlat
                    cmpb      #6
                    beq       UmeDFlat
                    bra       UmeNote
UmeDSharp           inca                          Adjust note into Double Sharp (whole note higher)
UmeSharp            inca                          Adjust note into Sharp (half note higher)
                    bra       UmeNote
UmeDFlat            deca                          Adjust note into Double Flat (whole note lower)
UmeFlat             deca                          Adjust note into Sharp (half note lower)
UmeNote             ldy       <ThisTrack
                    ldb       TRACK_MIDICHAN,y    Get 0-based channel # from file
                    cmpb      #9                  Percussion?
                    beq       UmeMusicN
* This is where the transposing test takes place
*                    adda      <UMETranspose+1     MIDI transpose
UmeMusicN           pshs      a
*                    lda       TRACK_MIDIPITCH,y   The previous pitch for this channel
                    lbsr      MidiNoteOff
                    puls      a
                    ldb       5,x
                    cmpb      #32
                    beq       next@                 Is it a rest?
                    sta       TRACK_MIDIPITCH,y   Set the new pitch
                    lda       #MIDIVEL_DEFAULT
                    sta       TRACK_VELOC,y
                    lbsr      MidiNoteOn
next@               leax      8,x
                    ldd       <UMEEventCntr
                    addd      #1
                    std       <UMEEventCntr
                    cmpd      <UMEEventTot
                    lblo      trns@
                    lbra      CloseAndNext

* Translate MIDI note value into named note (including sharps/flats)
DebugNotes          tst       <DebugMode
                    bne       a@
                    rts
a@                  pshs      d,x,y
                    leay      ScoreTracks,u 
                    ldb       <UMEPartsTot
                    pshs      b
l@                  lda       TRACK_MIDIPITCH,y
                    ldb       TRACK_VELOC,y
                    bne       MOD12
                    leax      SpecNotes,pcr
                    bra       p@
* Calculate: A = A mod 12
MOD12               CMPA      #12    * Check if value is >= 12
                    BLO       d@     * If A < 12, we are finished
                    SUBA      #12    * Subtract 12
                    BRA       MOD12  * Repeat
* A now contains the remainder
d@                  leax      NoteNames,pcr
                    lsla
                    lsla
                    leax      a,x 
p@                  pshs      y
                    ldy       #4
                    lda       #1
                    os9       I$Write
                    puls      y
* Octave = (MIDI Number / 12) - 1
                    leay      TRACK_ENTRYSIZE,y
                    dec       ,s
                    bne       l@
                    leas      1,s
                    lbsr      PrintCR
                    puls      d,x,y,pc
SpecNotes           fcc       "--  "
NoteNames           fcc       "C   C#  D   D#  E   F   F#  G   G#  A   A#  B   "

*******************************************************************
* Print a row containing all the Parts' clefs used in the score
*
PrintClefs          pshs      d,y
                    tst       <DebugMode          Dump clef types of Ume file if an -m#,# filter is specified
                    beq       x@
                    leay      UMEPartClefs,u
                    clr       ,s
a@                  ldb       ,y+
                    bsr       PrintClefStr
                    inc       ,s
                    ldb       ,s
                    cmpb      <UMEPartsTot
                    blo       a@
                    lbsr      PrintCR
x@                  puls      d,y,pc

*******************************************************************
* Build a 16-byte table that contains each part's clef #
*
BuildClefMap        pshs      b,x,y
                    leax      UMEPartClefs,u
                    clr       ,s
a@                  ldy       <UMEPartsAdr
                    ldb       ,s                  Get part #
                    lslb
                    lslb
                    leay      b,y
                    ldb       1,y                 Get the staff that this part is on
                    ldy       <UMEStavesAdr
                    lda       #10
                    mul
                    leay      d,y
                    ldb       3,y                 Get clef type
                    stb       ,x+                 Set clef # for this part
                    inc       ,s
                    ldb       ,s
                    cmpb      <UMEPartsTot
                    blo       a@
                    puls      b,x,y,pc

*******************************************************************
* Print the name of the specified Ultimuse clef type 0-6
* reg.b = clef type
*
PrintClefStr        pshs      d,x,y 
                    leax      clefstr,pcr
                    andb      #7
                    lslb
                    lslb
                    leax      b,x
                    lda       #1
                    ldy       #4
                    os9       I$Write
                    puls      d,x,y,pc
clefstr             fcc       "Trb "
                    fcc       "Bas "
                    fcc       "Gtr "
                    fcc       "DBs "
                    fcc       "Per "
                    fcc       "Alt "
                    fcc       "Ten "
                    fcc       "??? "

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
* In:  (X)=Ascii String ptr
* Out: (A)=next char After Number
*      (B)=Number
*      (X)=updated Past Number
*      CC=set if Error
*
ASC2Int             clrb
shgn10              lda       ,x+
                    suba      #'0                 convert ascii to binary
                    cmpa      #9                  valid decimal digit?
                    bhi       shgn20              ..no; end of number
                    pshs      a                   save digit
                    lda       #10
                    mul                           MULTIPLY Partial result times 10
                    addb      ,s+                 add in next digit
                    bcc       shgn10              get next digit if no overflow
shgn20              rts
GetAscInt16         clra
                    clrb
                    pshs      d
a@                  ldb       ,x+
                    subb      #'0                 convert ascii to binary
                    cmpb      #9                  valid decimal digit?
                    bhi       x@                  ..no; end of number
                    ldd       ,s
                    addd      ,s
                    addd      ,s
                    addd      ,s
                    addd      ,s
                    addd      ,s
                    addd      ,s
                    addd      ,s
                    addd      ,s
                    addd      ,s
                    std       ,s
                    ldb       -1,x
                    subb      #'0
                    clra
                    addd      ,s                  add in next digit
                    std       ,s
                    bra       a@                  get next digit if no overflow
x@                  puls      d,pc

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
                    ora       #$C0
                    sta       >MIDI_DataReg
                    stb       >MIDI_DataReg
                    leay      1,y
                    cmpy      #16
                    blo       a@
                    ldb       #-1
                    stb       <flgUseMapFile      Set flag if instrument map file was loaded
                    lbra      CloseAndNext
* Eventually put programs here for quick switching between clef types
ExamplePatch        fcc       "0,1,2,3,16,17,18,19,0,0,38,0,0,0,0,0;"

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
*                    lsra
*                    rorb
*                    std       <HalfCycles         Planned: play 2 notes in sequence on same channel

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
                    fcb       $01               [0,4,0]       1,2,1 won't work because the 1s will reduce away by the tempo divider

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

* Conversion table for Lyra volume (0-7) into MIDI velocity (0-127)
LyraVelocConv       fcb       1,70,75,80,85,90,95,105

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
                    fcc       "YAMAHA PSR-5* "
                    fcb       -1

* The following synth translation maps are being reformatted to take up less
* source code lines and will generally be 4 instruments per line

CASIO_MT540
*                        0-3  Piano,           Hardpischord,     Vibraphone,      Jazz Organ
                    fcb       MIDII_GRANDPIANO,MIDII_HARPSICHORD,MIDII_VIBRAPHONE,MIDII_ROCKORGAN
*                        4-7  Pipe Organ,       Brass Ensemble,    Strings,       Jazz Flute
                    fcb       MIDII_CHURCHORGAN,MIDII_BRASSSECTION,MIDII_STRINGS1,MIDII_FLUTE
*                       8-11  Chorus,        Jazz Guitar,         Bells,             Funky Clavi
                    fcb       MIDII_CHOIRAAH,MIDII_ELECJAZZGUITAR,MIDII_TUBULARBELLS,MIDII_CLAVINET
*                      12-15  Metallic Sound,   Synth Ensemble, Percussion,      ?
                    fcb       MIDII_METALLICPAD,MIDII_SYNTHSTR1,MIDII_VIBRAPHONE,MIDII_REEDORGAN
*                      16-19  Accordion,      Bass/Wood/Slap, Sound Effect 1-2,  ?
                    fcb       MIDII_ACCORDION,MIDII_SLAPBASS1,MIDII_ATMOSPHEREFX,MIDII_BRIGHTNESSFX
*                      20-23  Honky-Tonk Piano,    Marimba,      Oboe,      Synth Reed
                    fcb       MIDII_HONKYTONKPIANO,MIDII_MARIMBA,MIDII_OBOE,MIDII_POLYSYNTHPAD
*                      24-27  Harp,      Synth Celesta,Synth Clavi,  Metallic Sound
                    fcb       MIDII_HARP,MIDII_WARMPAD,MIDII_HALOPAD,MIDII_METALLICPAD
*                      28-29  Fantasy,        Miracle
                    fcb       MIDII_CRYSTALFX,MIDII_BRIGHTNESSFX

CASIO_CT460
*                        0-3  Piano,           Harpishord,       Vibraphone,      Jazz Organ
                    fcb       MIDII_GRANDPIANO,MIDII_HARPSICHORD,MIDII_VIBRAPHONE,MIDII_ROCKORGAN
*                        4-7  Pipe Organ,       Brass Ensemble,    Flute,      Chorus
                    fcb       MIDII_CHURCHORGAN,MIDII_BRASSSECTION,MIDII_FLUTE,MIDII_SYNTHVOICE
*                       8-11  Jazz Guitar,         Bells,             Clavi,         Metallic Pad
                    fcb       MIDII_ELECJAZZGUITAR,MIDII_TUBULARBELLS,MIDII_CLAVINET,MIDII_METALLICPAD
*                      12-15  Synth Strings1, Melodic Tom,     Honky-Tonk Piano,    Rhodes Piano
                    fcb       MIDII_SYNTHSTR1,MIDII_MELODICTOM,MIDII_HONKYTONKPIANO,MIDII_RHODESPIANO
*                      16-19  Marimba,      Hammond Organ,     Accordion,      String Ensemble 1
                    fcb       MIDII_MARIMBA,MIDII_HAMMONDORGAN,MIDII_ACCORDION,MIDII_STRINGS1
*                      20-23  Oboe,      Charang Lead,     Harp,      Organ
                    fcb       MIDII_OBOE,MIDII_CHARANGLEAD,MIDII_HARP,MIDII_WARMPAD
*                      24-27  ,          ,      ,     
                    fcb       MIDII_BOWEDPAD,MIDII_NEWAGEPAD,MIDII_SWEEPPAD,MIDII_SLAPBASS1
                    fcb       119                 028 
                    fcb       123                 029

KAWAI_MS710
* incomplete, software may map into next table
*                        0-3  Piano,           Strings,        Flute,      Harmonica
                    fcb       MIDII_GRANDPIANO,MIDII_SYNTHSTR1,MIDII_FLUTE,MIDII_HARMONICA
*                        4-7  Carinet,       Piano,              Electric Piano,     Clavis
                    fcb       MIDII_CLARINET,MIDII_BRITACOUPIANO,MIDII_ELECTRICGRAND,MIDII_CLAVINET
*                       8-15  Vibes,           Jazz Organ,     Rock Organ,        Pipe Organ
                    fcb       MIDII_VIBRAPHONE,MIDII_ROCKORGAN,MIDII_HAMMONDORGAN,MIDII_REEDORGAN
*                       12-15 Accordian,      Alto Sax,     Trumpet,      Cosmic
                    fcb       MIDII_ACCORDION,MIDII_ALTOSAX,MIDII_TRUMPET,MIDII_NEWAGEPAD
*                      16-19  Banjo,    Acoustic Guit, Electric Guitar,     Acoustic Bass
                    fcb       105,MIDII_ACOUSTICGUITAR,MIDII_ELECCLEANGUITA,MIDII_ACOUSTICBASS
*                      20-23  Electric Bass,     User1,       User2,      User3
                    fcb       MIDII_FINGELECBASS,MIDII_VIOLIN,MIDII_VIOLA,MIDII_CELLO
*                      24-27  User4, others...
                    fcb       MIDII_CONTRABASS,0,MIDII_STEELGUITAR,MIDII_GRANDPIANO
*                      28-31  User4, others...
                    fcb       MIDII_ELECMUTEDGUITA,0,MIDII_STRINGS1,MIDII_DISTORTGUITAR
*                      32-35
                    fcb       MIDII_GRANDPIANO,MIDII_GRANDPIANO,MIDII_FINGELECBASS,MIDII_GRANDPIANO
*                      36-39
                    fcb       MIDII_GRANDPIANO,MIDII_GRANDPIANO,MIDII_GRANDPIANO,MIDII_GRANDPIANO
*                      40-43
                    fcb       MIDII_GRANDPIANO,MIDII_GRANDPIANO,MIDII_GRANDPIANO,MIDII_GRANDPIANO
*                      44-47
                    fcb       MIDII_GRANDPIANO,MIDII_GRANDPIANO,MIDII_GRANDPIANO,MIDII_GRANDPIANO
*                      48-51
                    fcb       MIDII_GRANDPIANO,MIDII_ACCORDION,MIDII_GRANDPIANO,MIDII_GRANDPIANO
*                      42-55
                    fcb       MIDII_GRANDPIANO,MIDII_GRANDPIANO,MIDII_GRANDPIANO,MIDII_GRANDPIANO
*                      56-59
                    fcb       MIDII_GRANDPIANO,MIDII_GRANDPIANO,MIDII_GRANDPIANO,MIDII_GRANDPIANO
*                      60-63
                    fcb       MIDII_GRANDPIANO,MIDII_GRANDPIANO,MIDII_GRANDPIANO,MIDII_GRANDPIANO
*                      64-67
                    fcb       MIDII_GRANDPIANO,MIDII_GRANDPIANO,MIDII_GRANDPIANO,MIDII_GRANDPIANO
*                      68-71
                    fcb       MIDII_GRANDPIANO,MIDII_GRANDPIANO,MIDII_GRANDPIANO,MIDII_GRANDPIANO
*                      72-75
                    fcb       MIDII_FLUTE,MIDII_GRANDPIANO,MIDII_GRANDPIANO,MIDII_GRANDPIANO
*                      76-79
                    fcb       MIDII_GRANDPIANO,MIDII_GRANDPIANO,MIDII_GRANDPIANO,MIDII_GRANDPIANO


MT_32
* incomplete, software may map into next table
*                        0-3  Acoust Piano 1,  Acoust Piano 2,     Acoust Piano 3,   Electric Piano 1
                    fcb       MIDII_GRANDPIANO,MIDII_BRITACOUPIANO,MIDII_RHODESPIANO,MIDII_ELECTRICGRAND
*                        4-7  Electric Piano 2,   Electric Piano 3,   Electric Piano 4,   HonkyTonk Piano
                    fcb       MIDII_ELECTRICGRAND,MIDII_ELECTRICGRAND,MIDII_ELECTRICGRAND,MIDII_HONKYTONKPIANO
*                       8-11  Electric Organ 1,  Elec Organ 2,       Elec Organ 3,   Elec Organ 4
                    fcb       MIDII_HAMMONDORGAN,MIDII_PERCUSSIVEORG,MIDII_ROCKORGAN,MIDII_ROCKORGAN
*                      12-15  Pipe Organ 1,     Pipe Organ 2,   Pipe Organ 3,   Accordion
                    fcb       MIDII_CHURCHORGAN,MIDII_REEDORGAN,MIDII_REEDORGAN,MIDII_ACCORDION
*                      16-19  Harpsichord 1,    Harpsichord 2,    Harpsichord 3,    Clavi 1
                    fcb       MIDII_HARPSICHORD,MIDII_HARPSICHORD,MIDII_HARPSICHORD,MIDII_CLAVINET
*                      20-23  Clavi 2,       Clavi 3,       Celesta 1,    Celesta 2
                    fcb       MIDII_CLAVINET,MIDII_CLAVINET,MIDII_CELESTA,MIDII_CELESTA
*                      24-27  Synth Brass 1,    Synth Brass 2,    Synth Brass 3,    Synth Brass 4
                    fcb       MIDII_SYNTHBRASS1,MIDII_SYNTHBRASS2,MIDII_SYNTHBRASS1,MIDII_SYNTHBRASS2


YAMAHA_PSR500
* incomplete, software may map into next table
*                        0-3  Piano,           Flange Piano,       Konky-Tonk Piano ,   Electric Piano 1
                    fcb       MIDII_GRANDPIANO,MIDII_BRITACOUPIANO,MIDII_HONKYTONKPIANO,MIDII_ELECTRICGRAND
*                        4-7  Electric piano 2,   Electric piano 3,   Harpischord 1,    Harpischord 2
                    fcb       MIDII_ELECTRICGRAND,MIDII_ELECTRICGRAND,MIDII_HARPSICHORD,MIDII_HARPSICHORD
*                       8-11  Clavi,         Celesta,      Pipe organ 1,   Pipe organ 2
                    fcb       MIDII_CLAVINET,MIDII_CELESTA,MIDII_ROCKORGAN,MIDII_REEDORGAN
*                      12-15  Elec Organ 1,      Elec Organ 2,       Elec Organ 3,   Elec Organ 4
                    fcb       MIDII_HAMMONDORGAN,MIDII_PERCUSSIVEORG,MIDII_ROCKORGAN,MIDII_CHURCHORGAN


CASIO_CZ230S fcb 0 Lyra files are using 1+codes found in CZ-230 manual!?
*                        0-3  Brass Ens 1,       Brass Ens 2,       Brass Ens 3,       Symphonic Ens 1
                    fcb       MIDII_BRASSSECTION,MIDII_BRASSSECTION,MIDII_BRASSSECTION,MIDII_SYNTHBRASS1
*                        4-7  Symphonic Ens 2,  Symphonic Ens 3,  String Ens 1,  String Ens 2
                    fcb       MIDII_SYNTHBRASS2,MIDII_SYNTHBRASS1,MIDII_STRINGS1,MIDII_STRINGS2
*                       8-11  Synth Ens 1,    Synth Ens 1,    Lt Harp,   Mars
                    fcb       MIDII_SYNTHSTR1,MIDII_SYNTHSTR2,MIDII_HARP,MIDII_CRYSTALFX
*                      12-15  Southern Wing,Magical Wind,Funky Horn,      Slap Horn
                    fcb       MIDII_VIOLA,MIDII_SEASHORE,MIDII_FRENCHHORN,MIDII_SLAPBASS2
*                      16-19  Sweet Strings,    Light Attack, Synth Harp,Metallic Sound
                    fcb       MIDII_HARPSICHORD,MIDII_SCIFIFX,MIDII_HARP,MIDII_METALLICPAD
*                      20-23  Jazz Organ 1,       Jazz Organ 2,   Pipe Organ 1,      Pipe Organ 2
                    fcb       MIDII_PERCUSSIVEORG,MIDII_ROCKORGAN,MIDII_HAMMONDORGAN,MIDII_REEDORGAN
*                      24-27  Accordion,      Fem Choir,     Male Choir,    Space Voice 1
                    fcb       MIDII_ACCORDION,MIDII_CHOIRAAH,MIDII_CHOIROOH,MIDII_ATMOSPHEREFX


                    fcb       00                  028
                    fcb       00                  029
                    fcb       MIDII_TRUMPET        030 TRUMPET -> Trumpet
                    fcb       MIDII_FLUTE          031 FLUTE -> Flute

                    fcb       MIDII_WHISTLE        032 WHISTLE
                    fcb       MIDII_VIOLIN         033 VIOLIN
                    fcb       MIDII_CELLO          034 CELLO -> Cello
                    fcb       MIDII_HARMONICA      035 BLUES HARMONICA -> Harmonica
                    fcb       MIDII_SHAKUHACHI     036 Sakuhac -> Shakuhach
                    fcb       MIDII_KOTO           037 KOTO -> Koto
                    fcb       MIDII_SHAMISEN       038 SHAMISEN
                    fcb       MIDII_DULCIMER       039 QANUN -> Dulcimer
                    fcb       MIDII_BASSOON        040 SYNTH REED -> Bassoon
                    fcb       MIDII_TINKLEBELL     041 Pearl Drop
                    fcb       MIDII_ALTOSAX        042 DOUBLE REED -> Alto Sax
                    fcb       00                  043
                    fcb       00                  044
                    fcb       MIDII_BRIGHTNESSFX   045 FANTASY 1
                    fcb       MIDII_ATMOSPHEREFX   046 FANTASY 2
                    fcb       MIDII_BOWEDPAD       047 PLUNK EXTEND
                    fcb       00                  048
                    fcb       00                  049
*                    050-054  Acoustic Grand, Bright Acoustic,   Rhodes,          Honky-Tonk,         Electric Grand
                    fcb       MIDII_GRANDPIANO,MIDII_BRITACOUPIANO,MIDII_RHODESPIANO,MIDII_HONKYTONKPIANO,MIDII_ELECTRICGRAND
*                    055-056  Harpischord 1,   Harpischord 2
                    fcb       MIDII_HARPSICHORD,MIDII_HARPSICHORD
                    fcb       MIDII_CLAVINET       057 SYNTH CLAVINET                  
                    fcb       00                  058
                    fcb       00                  059
                    fcb       MIDII_TUBULARBELLS   060 BELLS -> Tubular Bells
                    fcb       00                  061
                    fcb       MIDII_CELESTA        062 SYNTH CELESTA -> Celesta
*                    063-065  Synth Vibe 1      Synth Vibe 2,  Synth Vibe 3
                    fcb       MIDII_POLYSYNTHPAD,MIDII_NEWAGEPAD,MIDII_HALOPAD
                    fcb       MIDII_VIBRAPHONE     066 BELL-LYRA -> Wood block
                    fcb       MIDII_XYLOPHONE      067 XYLOPHONE -> Xylophone
                    fcb       MIDII_XYLOPHONE      068 SOFY XYLOPHONE
                    fcb       MIDII_MARIMBA        069 MARIMBA -> Marimba
                    fcb       MIDII_ACOUSTICGUITAR,MIDII_ACOUSTICBASS               070-071 ACOUSTIC GUITAR 1,2 -> Acoustic Nylon Guitar, Acoustic Bass Timbre
                    fcb       MIDII_ELECJAZZGUITAR 072 SEMI ACOUSTIC GUITAR -> Electric Jazz Guitar 
                    fcb       120                 073 FEEDBACK -> Guitar Fret Noise?
                    fcb       MIDII_ELECCLEANGUITA,MIDII_ELECMUTEDGUITA               074-075 ELECTRIC GUITAR 1,2 -> Electric Clean Guitar, Electric Muted Guitar
                    fcb       MIDII_FINGELECBASS,MIDII_PLUKELECBASS               076-077 ELEC BASS -> Fingered Electric Bass Guitar, Plucked Electric Bass Guitar
                    fcb       MIDII_SLAPBASS1      078 SLAP BASS -> Slap Bass 1
                    fcb       MIDII_METALLICPAD    079 METALLIC BASS -> Metallic Pad                  
                    fcb       MIDII_TAIKODRUM,MIDII_MELODICTOM,MIDII_SYNTHDRUMS     118         080-082 SYNTH DRUMS 1,2,3 -> Synth drums
                    fcb       MIDII_DULCIMER       083 SYNTH CLAPPER -> Dulcimer
                    fcb       128+54              084 TAMBOURINE -> Percussion, Tambourine
                    fcb       128+56              085 COWBELL -> Percussion, Cow Bell
                    fcb       128+64              086 CONGA -> Percussion, Low Conga
                    fcb       128+45              087 TABLA -> Percussion, Low Tom?    
                    fcb       128+63              088 AFRO PERCUSSION ->
                    fcb       MIDII_STEELDRUMS     089 STEEL DRUM -> Steel Drums
                    fcb       00                  
                    fcb       00                  
                    fcb       MIDII_GUNSHOT        092 EXPLOSION
                    fcb       MIDII_RAIN           093 TYPHOON -> Rain?
                    fcb       00
                    fcb       00                  
                    fcb       00                  
                    fcb       00
                    fcb       00
                    fcb       0
                    fcb       MIDII_SWEEPPAD       100 SWEEP
                    fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

Powers              fdb       1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768


**********************************************************
* MIDI/Ultimuse/Lyra notes
* Sharps and Flats are calculated in code by inca/deca of MIDI note
*      Octave       Note Number    Note Name        Frequency Hz
*                       127            G          12,543.8539514160
              fdb       127,12544      G9
*                       126          F#/Gb        11,839.8215267723
*                       125            F          11,175.3034058561
              fdb       125,11175      F9
*                       124            E          10,548.0818212118
              fdb       124,10548      E9
*                       123          D#/Eb	  9,956.0634791066
*                       122            D          9,397.2725733570
              fdb       122,9397       D9
*                       121          C#/Db        8,869.8441912599
*        9              120            C          8,372.0180896192
              fdb       120,8372       C9
**********              119            B          7,902.1328200980
              fdb       119,7902       B8
*                       118          A#/Bb        7,458.6201842894
*                       117            A          7,040.0000000000
              fdb       117,7040       A8
*                       116          G#/Ab        6,644.8751612791
*                       115            G          6,271.92697571
              fdb       115,6272       G8
*                       114          F#/Gb        5,919.9107633862
*                       113            F          5,587.6517029281
              fdb       113,5588       F8
*                       112            E          5,274.0409106059
              fdb       112,5274       E8
*                       111          D#/Eb        4,978.0317395533
*                       110            D          4,698.6362866785
              fdb       110,4699       D8
*                       109          C#/Db        4,434.9220956300
*        8              108            C          4,186.0090448096
              fdb       108,4186       C8
**********              107            B	  3,951.0664100490
              fdb       107,3951       B7
*                       106          A#/Bb        3,729.3100921447
*                       105            A          3,520.0000000000
              fdb       105,3520       A7
*                       104          G#/Ab        3,322.4375806396
*                       103            G          3,135.9634878540
              fdb       103,3136       G7
*                       102          F#/Gb        2,959.9553816931
*                       101            F          2,793.8258514640
              fdb       101,2794       F7
*                       100            E          2,637.0204553030
              fdb       100,2637       E7
*                        99          D#/Eb        2,489.0158697766
*                        98            D          2,349.3181433393
LyraRange     fdb        98,2349       D7
*                        97          C#/Db        2,217.4610478150
*        7               96            C          2,093.0045224048
              fdb        96,2093       C7
**********               95            B          1,975.5332050245
              fdb        95,1976       B6
*                        94          A#/Bb        1,864.6550460724
*                        93            A          1,760.0000000000
              fdb        93,1760       A6
*                        92          G#/Ab        1,661.2187903198
*                        91            G          1,567.9817439270
              fdb        91,1568       G6
*                        90          F#/Gb        1,479.9776908465
* High                   89            F          1,396.9129257320
              fdb        89,1397       F6
* High                   88            E          1,318.5102276515
              fdb        88,1319       E6
* High                   87          D#/Eb        1,244.5079348883
* High                   86            D          1,174.6590716696
              fdb        86,1175       D6
* High                   85          C#/Db        1,108.7305239075
* High   6               84            C          1,046.5022612024
              fdb        84,1047       C6
**********               83            B            987.7666025122
              fdb        83,988        B5
* High                   82          A#/Bb          932.3275230362
* High                   81            A            880.0000000000
              fdb        81,880        A5
* High                   80          G#/Ab          830.6093951599
* High                   79            G            783.9908719635
              fdb        79,784        G5
* High                   78           F#/Gb         739.9888454233
* Treble                 77            F            698.4564628660
              fdb        77,698        F5
* Treble                 76            E            659.2551138257
              fdb        76,659        E5
* Treble                 75          D#/Eb          622.2539674442
* Treble                 74            D            587.3295358348
MidiTrebD              fdb        74,587        D5
* Treble                 73          C#/Db          554.3652619537
* Treble 5               72            C            523.2511306012
MidiTrebC              fdb        72,523        C5
**********               71            B            493.8833012561
MidiTrebB              fdb        71,0          B4
* Treble                 70          A#/Bb          466.1637615181
* Treble                 69            A            440.0000000000
MidiTrebA              fdb        69,440        A4
* Treble                 68          G#/Ab          415.3046975799
* Treble                 67            G            391.9954359817
MidiTrebG              fdb        67,392        G4
* Treble                 66          F#/Gb          369.9944227116
* Middle                 65            F            349.2282314330
MidiTrebF              fdb        65,349        F4
* Middle                 64            E            329.6275569129
MidiTrebE      fdb        64,330        E4
* Middle                 63          D#/Eb          311.1269837221
* Middle                 62            D            293.6647679174
              fdb        62,294        D4
* Middle                 61          C#/Db          277.1826309769
* Middle 4               60            C            261.6255653006
MidiMidC      fdb        60,262        C4
**********               59            B            246.9416506281
              fdb        59,247        B3
* Middle                 58          A#/Bb          233.0818807590
* Middle                 57            A            220.0000000000
              fdb        57,220        A3
* Middle                 56          G#/Ab          207.6523487900
* Middle                 55            G            195.9977179909
MidiBass      fdb        55,196        G3
* Bass                   54          F#/Gb          184.9972113558
* Bass                   53            F            174.6141157165
MidiAlto
MidiBassF     fdb        53,175        F3
* Bass                   52            E            164.8137784564
MidiBassE     fdb        52,165        E3
* Bass                   51          D#/Eb          155.5634918610
* Bass                   50            D            146.8323839587
MidiTenor
MidiBassD
MidiPerc      fdb        50,147        D3
* Bass                   49          C#/Db          138.5913154884
* Bass   3               48            C            130.8127826503
MidiBassC     fdb        48,131        C3
**********               47            B            123.4708253140
MidiBassB     fdb        47,123        B2
* Bass                   46          A#/Bb          116.5409403795
* Bass                   45            A            110.0000000000
MidiBassA     fdb        45,110        A2
* Bass                   44          G#/Ab          103.8261743950
* Bass                   43            G             97.9988589954
MidiBassG     fdb        43,98         G2
* Low                    42          F#/Gb           92.4986056779
* Low                    41            F             87.3070578583
              fdb        41,87         F2
* Low                    40            E             82.4068892282
              fdb        40,82         E2
* Low                    39          D#/Eb           77.7817459305
* Low                    38            D             73.4161919794
              fdb        38,73         D2
* Low                    37          C#/Db           69.2956577442
* Low    2               36            C             65.4063913251
              fdb        36,65         C2
**********               35            B             61.7354126570
              fdb        35,62         B1
* Low                    34          A#/Bb           58.2704701898
* Low                    33            A             55.0000000000
              fdb        33,55         A2
* Low                    32          G#/Ab           51.9130871975
* Low                    31            G             48.9994294977
              fdb        31,49         G1
*                        30          F#/Gb           46.2493028390
*                        29            F             43.6535289291
              fdb        29,44         F1
*                        28            E             41.2034446141
              fdb        28,41         E1
*                        27          D#/Eb           38.8908729653
*                        26            D             36.7080959897
              fdb        26,37         D1
*                        25          C#/Db           34.6478288721
*        1               24            C             32.7031956626
              fdb        24,33         C1
**********               23            B             30.8677063285
              fdb        23,31         B0
*                        22          A#/Bb           29.1352350949
*                        21            A             27.5000000000
              fdb        21,28         A0
*                        20          G#/Ab           25.9565435987
*                        19            G             24.4997147489
              fdb        19,24         G0
*                        18          F#/Gb           23.1246514195
*                        17            F             21.8267644646
              fdb        17,22         F0
*                        16            E             20.6017223071
              fdb        16,21         E0
*                        15          D#/Eb           19.4454364826
*                        14            D             18.3540479948
              fdb        14,18         D0
*                        13          C#/Db           17.3239144361
*        0               12            C             16.3515978313
              fdb        12,16         C0
**********               11            B             15.4338531643
              fdb        11,15         B-1
*                        10          A#/Bb           14.5676175474
*                         9            A             13.7500000000
              fdb         9,14         A-1
*                         8          G#/Ab           12.9782717994
*                         7            G             12.2498573744
              fdb         7,12         G-1
*                         6          F#/Gb           11.5623257097
*                         5            F             10.9133822323
              fdb         5,11         F-1
*                         4            E             10.3008611535
              fdb         4,10         E-1
*                         3          D#/Eb            9.7227182413
*                         2            D              9.1770239974
              fdb         2,9          D-1
*                         1          C#/Db            8.6619572180
*       -1                0            C              8.1757989156
              fdb         0,8          C-1


FILETYPES           fcc       ".rsd"
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
CRStr               fcb       13,0

PrintSPC            pshs      cc,d,x,y
                    lda       #0
                    ldy       #1
                    leax      SPCStr,pcr
                    os9       I$WritLn
                    puls      cc,d,x,y,pc
SPCStr              fcb       C$SPAC,0

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
