                  IFNE    MIDI.D-1
MIDI.D              set       1

MIDICMD_NOTE_OFF    equ       $80                 Turn note off
MIDICMD_NOTE_ON     equ       $90                 Turn note On

MIDICMD_CC          equ       $B0                 Control Change
MIDICC_ALLNOTESOFF  equ       $7B

MIDICMD_SYSEX       equ       $F07F
MIDICMD_SYSEXTERM   equ       $F7
MIDIMMC_DEVICE_ALL  equ       $7F

******************************************
* Synthesizer targets                    *
******************************************
MIDITARG_MIDI       equ       0
MIDITARG_CZ230      equ       1
MIDITARG_CT460      equ       2
MIDITARG_MT540      equ       3
MIDITARG_MS710      equ       4
MIDITARG_FB01       equ       5
MIDITARG_MT32       equ       6
MIDITARG_PSR500     equ       7

******************************************
* General MIDI Instrument codes          *
******************************************
MIDII_GRANDPIANO     equ      0                   (000) Acoustic Grand Piano
MIDII_BRITACOUPIANO  equ      1                   Bright Acoustic Piano
MIDII_ELECTRICGRAND  equ      2                   Electric Grand Piano
MIDII_HONKYTONKPIANO equ      3                   Honky-Tonk Piano
MIDII_RHODESPIANO    equ      4                   Rhodes Piano
MIDII_CHORUSEDPIANO  equ      5                   Chorused Piano
MIDII_HARPSICHORD    equ      6                   Harpsichord
MIDII_CLAVINET       equ      7                   Clavinet
MIDII_CELESTA        equ      8                   (008) Celesta                  
MIDII_GLOCKENSPIEL   equ      9                   Glockenspiel
MIDII_MUSICBOX       equ      10                  Music Box 
MIDII_VIBRAPHONE     equ      11                  Vibraphone
MIDII_MARIMBA        equ      12                  Marimba
MIDII_XYLOPHONE      equ      13                  Xylophone
MIDII_TUBULARBELLS   equ      14                  Tubular Bells
MIDII_DULCIMER       equ      15                  Dulcimer
MIDII_HAMMONDORGAN   equ      16                  Hammond Organ
MIDII_PERCUSSIVEORG  equ      17                  Percussive Organ
MIDII_ROCKORGAN      equ      18                  Rock Organ
MIDII_CHURCHORGAN    equ      19                  Church Organ
MIDII_REEDORGAN      equ      20                  Reed Organ
MIDII_ACCORDION      equ      21                  Accordion
MIDII_HARMONICA      equ      22                  Harmonica
MIDII_TANGOACCORDION equ      23                  Tango Accordion
MIDII_ACOUSTICGUITAR equ      24                  (024) Acoustic Nylon Guitar
MIDII_STEELGUITAR    equ      25                  Acoustic Steel Guitar
MIDII_ELECJAZZGUITAR equ      26                  Electric Jazz Guitar
MIDII_ELECCLEANGUITA equ      27                  Electric Clean Guitar
MIDII_ELECMUTEDGUITA equ      28                  Electric Muted Guitar
MIDII_OVERDRIVENGUIT equ      29                  Overdriven Guitar
MIDII_DISTORTGUITAR  equ      30                  Distortion Guitar
MIDII_GUITARHARMONIC equ      31                  Guitar Harmonics
MIDII_ACOUSTICBASS   equ      32                  (032) Acoustic Bass
MIDII_FINGELECBASS   equ      33                  Fingered Electric Bass
MIDII_PLUKELECBASS   equ      34                  Plucked Electric Bass
MIDII_FRETLESSBASS   equ      35                  Fretless Bass
MIDII_SLAPBASS1      equ      36                  Slap Bass 1
MIDII_SLAPBASS2      equ      37                  Slap Bass 2
MIDII_SYNTHBASS1     equ      38                  Synth Bass 1
MIDII_SYNTHBASS2     equ      39                  Synth Bass 2
MIDII_VIOLIN         equ      40                  (040) Violin
MIDII_VIOLA          equ      41                  Viola
MIDII_CELLO          equ      42                  Cello
MIDII_CONTRABASS     equ      43                  Contrabass
MIDII_TREMELO        equ      44                  Tremolo Strings
MIDII_PIZZICATO      equ      45                  Pizzicato Strings
MIDII_HARP           equ      46                  Orchestral Harp
MIDII_TIMPANI        equ      47                  Timpani
MIDII_STRINGS1       equ      48                  String Ensemble 1
MIDII_STRINGS2       equ      49                  String Ensemble 2
MIDII_SYNTHSTR1      equ      50                  Synth Strings 1
MIDII_SYNTHSTR2      equ      51                  Synth Strings 2
MIDII_CHOIRAAH       equ      52                  Choir "Aah"
MIDII_CHOIROOH       equ      53                  Choir "Ooh"
MIDII_SYNTHVOICE     equ      54                  Synth Voice
MIDII_ORCHESTRALHIT  equ      55                  Orchestral Hit
MIDII_TRUMPET        equ      56                  Trumpet
MIDII_TROMBONE       equ      57                  Trombone
MIDII_TUBA           equ      58                  Tuba
MIDII_MUTEDTRUMPET   equ      59                  Muted Trumpet
MIDII_FRENCHHORN     equ      60                  French Horn
MIDII_BRASSSECTION   equ      61                  Brass Section
MIDII_SYNTHBRASS1    equ      62                  Synth Brass 1
MIDII_SYNTHBRASS2    equ      63                  Synth Brass 2
MIDII_SOPRANOSAX     equ      64                  Soprano Sax
MIDII_ALTOSAX        equ      65                  Alto Sax
MIDII_TENORSAX       equ      66                  Tenor Sax
MIDII_BARITONESAX    equ      67                  Baritone Sax
MIDII_OBOE           equ      68                  Oboe
MIDII_ENGLISHHORN    equ      69                  English Horn
MIDII_BASSOON        equ      70                  Bassoon
MIDII_CLARINET       equ      71                  Clarinet
MIDII_PICCOLO        equ      72                  Piccolo
MIDII_FLUTE          equ      73                  Flute
MIDII_RECORDER       equ      74                  Recorder
MIDII_PANFLUTE       equ      75                  Pan Flute
MIDII_BOTTLEBLOW     equ      76                  Bottle Blow
MIDII_SHAKUHACHI     equ      77                  Shakuhachi
MIDII_WHISTLE        equ      78                  Whistle
MIDII_OCARINA        equ      79                  Ocarina
MIDII_SQUAREWVLEAD   equ      80                  Square Wave Lead
MIDII_SAWTOOTHLEAD   equ      81                  Sawtooth Wave Lead
MIDII_CALLIONELEAD   equ      82                  Calliope Lead
MIDII_CHIFFLEAD      equ      83                  Chiff Lead
MIDII_CHARANGLEAD    equ      84                  Charang Lead
MIDII_VOICELEAD      equ      85                  Voice Lead
MIDII_FIFTHSLEAD     equ      86                  Fifths Lead
MIDII_BASSLEAD       equ      87                  Bass Lead
MIDII_NEWAGEPAD      equ      88                  New Age Pad
MIDII_WARMPAD        equ      89                  Warm Pad
MIDII_POLYSYNTHPAD   equ      90                  Polysynth Pad
MIDII_CHOIRPAD       equ      91                  Choir Pad
MIDII_BOWEDPAD       equ      92                  Bowed Pad
MIDII_METALLICPAD    equ      93                  Metallic Pad
MIDII_HALOPAD        equ      94                  Halo Pad
MIDII_SWEEPPAD       equ      95                  Sweep Pad
MIDII_RAIN           equ      96                  Rain Effect
MIDII_SOUNDTRKFX     equ      97                  Soundtrack Effect
MIDII_CRYSTALFX      equ      98                  Crystal Effect
MIDII_ATMOSPHEREFX   equ      99                  Atmosphere Effect
MIDII_BRIGHTNESSFX   equ      100                 Brightness Effect
MIDII_GOBLINSFX      equ      101                 Goblins Effect
MIDII_ECHOESFX       equ      102                 Echoes Effect
MIDII_SCIFIFX        equ      103                 Sci-Fi Effect
MIDII_SITAR          equ      104                 Sitar
MIDII_BANJO          equ      105                 Banjo
MIDII_SHAMISEN       equ      106                 Shamisen
MIDII_KOTO           equ      107                 Koto
MIDII_KALIMBA        equ      108                 Kalimba
MIDII_BAGPIPE        equ      109                 Bagpipe
MIDII_FIDDLE         equ      110                 Fiddle
MIDII_SHANAI         equ      111                 Shanai
MIDII_TINKLEBELL     equ      112                 Tinkle Bell
MIDII_AGOGO          equ      113                 Agogo
MIDII_STEELDRUMS     equ      114                 Steel Drums
MIDII_WOODBLOCK      equ      115                 Woodblock
MIDII_TAIKODRUM      equ      116                 Taiko Drum
MIDII_MELODICTOM     equ      117                 Melodic Tom
MIDII_SYNTHDRUMS     equ      118                 Synth Drum
MIDII_REVERSECYMBAL  equ      119                 Reverse Cymbal
MIDII_FRETNOISE      equ      120                 Guitar Fret Noise
MIDII_BREATH         equ      121                 Breath Noise
MIDII_SEASHORE       equ      122                 Seashore
MIDII_BIRDTWEET      equ      123                 Bird Tweet
MIDII_TELEPHONE      equ      124                 Telephone Ring
MIDII_HELICOPTER     equ      125                 Helicopter
MIDII_APPLAUSE       equ      126                 Applause
MIDII_GUNSHOT        equ      127                 Gun Shot


                    ENDC
