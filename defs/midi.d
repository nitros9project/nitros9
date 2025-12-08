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
* Synthesizer targets
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
MIDI_GRANDPIANO     equ       0
MIDI_ACOUSTICPIANO  equ       1
MIDI_ELECTRICGRAND  equ       2
MIDI_HONKYTONKPIANO equ       3
MIDI_RHODESPIANO    equ       4
MIDI_CHORUSEDPIANO  equ       5
MIDI_HARPSICHORD    equ       6
MIDI_CLAVINET       equ       7
MIDI_CELESTA        equ       8
MIDI_GLOCKENSPIEL   equ       9
MIDI_MUSICBOX       equ       10
MIDI_VIBRAPHONE     equ       11
MIDI_MARIMBA        equ       12
MIDI_XYLOPHONE      equ       13
MIDI_TUBULARBELLS   equ       14
MIDI_DULCIMER       equ       15
MIDI_HAMMONDORGAN   equ       16
MIDI_PERCUSSIVEORG  equ       17
MIDI_ROCKORGAN      equ       18
MIDI_CHURCHORGAN    equ       19
MIDI_REEDORGAN      equ       20
MIDI_ACCORDION      equ       21
MIDI_HARMONICA      equ       22
MIDI_TANGOACCORDION equ       23
MIDI_ACOUSTICGUITAR equ       24
MIDI_STEELGUITAR    equ       25
MIDI_ELECJAZZGUITAR equ       26
MIDI_ELECCLEANGUITA equ       27
MIDI_ELECMUTEDGUITA equ       28
MIDI_OVERDRIVENGUIT equ       29
MIDI_DISTORTIONGUIT equ       30
MIDI_GUITARHARMONIC equ       31

MIDI_TRUMPET        equ       56
MIDI_PICCOLO        equ       72
MIDI_FLUTE          equ       73
MIDI_RECORDER       equ       74
MIDI_PANFLUTE       equ       75
MIDI_BOTTLEBLOW     equ       76
MIDI_SHAKUHACHI     equ       77
MIDI_WHISTLE        equ       78
MIDI_OCARINA        equ       79



                    ENDC
