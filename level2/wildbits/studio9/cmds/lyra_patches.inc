* Patch tables copied from level2/wildbits/cmds/play.as SetupInstruments.
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

CASIO_MT540_END equ *
* Lyra's CT-460 bank uses one-based program numbers, not panel offsets.
* Verified against the named instrument slots in the James Bond collection:
* 003 VIBRAPH, 009 JGUITAR, 020 ACCORDI, 022 OBOE, 024 HARP, 029 BASS.
CASIO_CT460          fcb       MIDII_GRANDPIANO     000 unspecified
                    fcb       MIDII_GRANDPIANO,MIDII_HARPSICHORD,MIDII_VIBRAPHONE
                    fcb       MIDII_ROCKORGAN,MIDII_CHURCHORGAN,MIDII_BRASSSECTION
                    fcb       MIDII_FLUTE,MIDII_SYNTHVOICE,MIDII_ELECJAZZGUITAR
                    fcb       MIDII_TUBULARBELLS,MIDII_CLAVINET,MIDII_METALLICPAD
                    fcb       MIDII_SYNTHSTR1,MIDII_MELODICTOM,119
                    fcb       MIDII_HONKYTONKPIANO,MIDII_RHODESPIANO,MIDII_MARIMBA
                    fcb       MIDII_HAMMONDORGAN,MIDII_ACCORDION,MIDII_STRINGS1
                    fcb       MIDII_OBOE,MIDII_CHARANGLEAD,MIDII_HARP
                    fcb       MIDII_WARMPAD,MIDII_HALOPAD,MIDII_NEWAGEPAD
                    fcb       MIDII_SWEEPPAD,MIDII_ACOUSTICBASS,123

CASIO_CT460_END equ *
KAWAI_MS710
* incomplete, software may map into next table
*                        0-3  Piano,           Strings,        Flute,      Harmonica
                    fcb       MIDII_GRANDPIANO,MIDII_SYNTHSTR1,MIDII_FLUTE,MIDII_HARMONICA
*                        4-7  Carinet,       Piano,              Electric Piano,     Clavis
                    fcb       MIDII_CLARINET,MIDII_BRITACOUPIANO,MIDII_ELECTRICGRAND,MIDII_CLAVINET
*                       8-11  Vibes,           Jazz Organ,     Rock Organ,        Pipe Organ
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
*                      52-55
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


KAWAI_MS710_END equ *
CASIO_CZ230S fcb 0 Lyra files are using 1+codes found in CZ-230 manual!?
*                        0-3  Brass Ens 1,       Brass Ens 2,       Brass Ens 3,       Symphonic Ens 1
* Symphonic Ens 1-3 are orchestral strings, not synth brass; String Ens 2 also maps to String Ensemble 1 (GM String
* Ensemble 2's slow attack swells every chord in)
                    fcb       MIDII_BRASSSECTION,MIDII_BRASSSECTION,MIDII_BRASSSECTION,MIDII_STRINGS1
*                        4-7  Symphonic Ens 2,  Symphonic Ens 3,  String Ens 1,  String Ens 2
                    fcb       MIDII_STRINGS1,MIDII_STRINGS1,MIDII_STRINGS1,MIDII_STRINGS1
*                       8-11  Synth Ens 1,    Synth Ens 1,    Lt Harp,   Mars
                    fcb       MIDII_SYNTHSTR1,MIDII_SYNTHSTR2,MIDII_HARP,MIDII_CRYSTALFX
*                      12-15  Southern Wing,Magical Wind,Funky Horn,      Slap Horn
                    fcb       MIDII_VIOLA,MIDII_SEASHORE,MIDII_FRENCHHORN,MIDII_SLAPBASS2
*                      16-19  Sweet Strings,    Light Attack, Synth Harp,Metallic Sound
                    fcb       MIDII_HARPSICHORD,MIDII_SCIFIFX,MIDII_HARP,MIDII_METALLICPAD
*                      20-23  Jazz Organ 1,       Jazz Organ 2,   Pipe Organ 1,      Pipe Organ 2
                    fcb       MIDII_PERCUSSIVEORG,MIDII_ROCKORGAN,MIDII_CHURCHORGAN,MIDII_CHURCHORGAN   2026-09-27: pipe organ is the church organ
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
                    fcb       MIDII_VIBRAPHONE     066 BELL-LYRA -> Vibraphone
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
CASIO_CZ230S_END equ *
* Names decide what a number cannot. Each entry: the keyword (a prefix of the header name, upper case),
* a 0, the GM program (128+n = percussion note n). An empty keyword ends a table.
* The CZ-230S rhythm-machine patterns: a header entry named after one is a drum part.
ly_rhythms          fcc       /ROCK/
                    fcb       0,128+42
                    fcc       /DISCO/
                    fcb       0,128+42
                    fcc       /16 BEAT/
                    fcb       0,128+42
                    fcc       /16BEAT/
                    fcb       0,128+42
                    fcc       /8 BEAT/
                    fcb       0,128+42
                    fcc       /POPS/
                    fcb       0,128+42
                    fcc       /SWING/
                    fcb       0,128+42
                    fcc       /WALTZ/
                    fcb       0,128+42
                    fcc       /BOSSA/
                    fcb       0,128+42
                    fcc       /SAMBA/
                    fcb       0,128+42
                    fcc       /RHUMBA/
                    fcb       0,128+42
                    fcc       /RUMBA/
                    fcb       0,128+42
                    fcc       /BEGUIN/
                    fcb       0,128+42
                    fcc       /TANGO/
                    fcb       0,128+42
                    fcc       /MARCH/
                    fcb       0,128+42
                    fcc       /REGGAE/
                    fcb       0,128+42
                    fcc       /SHUFFL/
                    fcb       0,128+42
                    fcc       /BOOGIE/
                    fcb       0,128+42
                    fcc       /BALLAD/
                    fcb       0,128+42
                    fcc       /SLOW ROCK/
                    fcb       0,128+42
                    fcb       0
* Tone names, for a number past the table or a row without a mapping.
ly_tonenames        fcc       /TRUMPET/
                    fcb       0,MIDII_TRUMPET
                    fcc       /ORCHHIT/
                    fcb       0,MIDII_ORCHESTRALHIT
                    fcc       /TROMBON/
                    fcb       0,MIDII_TROMBONE
                    fcc       /TUBA/
                    fcb       0,MIDII_TUBA
                    fcc       /FLUTE/
                    fcb       0,MIDII_FLUTE
                    fcc       /PICCOLO/
                    fcb       0,MIDII_PICCOLO
                    fcc       /OBOE/
                    fcb       0,MIDII_OBOE
                    fcc       /CLARINET/
                    fcb       0,MIDII_CLARINET
                    fcc       /SAX/
                    fcb       0,MIDII_ALTOSAX
                    fcc       /WHISTLE/
                    fcb       0,MIDII_WHISTLE
                    fcc       /SAKUHA/
                    fcb       0,MIDII_SHAKUHACHI
                    fcc       /SHAKUHA/
                    fcb       0,MIDII_SHAKUHACHI
                    fcc       /VIOLIN/
                    fcb       0,MIDII_VIOLIN
                    fcc       /CELLO/
                    fcb       0,MIDII_CELLO
                    fcc       /LOSTRI/
                    fcb       0,MIDII_CONTRABASS
                    fcc       /STRING/
                    fcb       0,MIDII_STRINGS1
                    fcc       /HARP/
                    fcb       0,MIDII_HARP
                    fcc       /LT HARP/
                    fcb       0,MIDII_HARP
                    fcc       /PIANO/
                    fcb       0,MIDII_GRANDPIANO
                    fcc       /RHODES/
                    fcb       0,MIDII_RHODESPIANO
                    fcc       /HARPSI/
                    fcb       0,MIDII_HARPSICHORD
                    fcc       /CLAVI/
                    fcb       0,MIDII_CLAVINET
                    fcc       /PIPE/
                    fcb       0,MIDII_CHURCHORGAN
                    fcc       /ORGAN/
                    fcb       0,MIDII_HAMMONDORGAN
                    fcc       /ACORD/
                    fcb       0,MIDII_ACCORDION
                    fcc       /ACCORD/
                    fcb       0,MIDII_ACCORDION
                    fcc       /HARMONI/
                    fcb       0,MIDII_HARMONICA
                    fcc       /GUITAR/
                    fcb       0,MIDII_ACOUSTICGUITAR
                    fcc       /BASS/
                    fcb       0,MIDII_FINGELECBASS
                    fcc       /ELECBAS/
                    fcb       0,MIDII_FINGELECBASS
                    fcc       /VIBRA/
                    fcb       0,MIDII_VIBRAPHONE
                    fcc       /MARIMBA/
                    fcb       0,MIDII_MARIMBA
                    fcc       /XYLO/
                    fcb       0,MIDII_XYLOPHONE
                    fcc       /GLOKEN/
                    fcb       0,MIDII_GLOCKENSPIEL
                    fcc       /GLOCK/
                    fcb       0,MIDII_GLOCKENSPIEL
                    fcc       /BELL/
                    fcb       0,MIDII_TUBULARBELLS
                    fcc       /CHOIR/
                    fcb       0,MIDII_CHOIRAAH
                    fcc       /FEMCH/
                    fcb       0,MIDII_CHOIRAAH
                    fcc       /MALECH/
                    fcb       0,MIDII_CHOIROOH
                    fcc       /VOICE/
                    fcb       0,53                Voice Oohs
                    fcc       /BRASS/
                    fcb       0,MIDII_BRASSSECTION
                    fcc       /HORN/
                    fcb       0,MIDII_FRENCHHORN
                    fcb       0
