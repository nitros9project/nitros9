
                    nam       SETUP
                    ttl       Routine to put objects in buffers

                    ifp1
*         use    /h0/defs/os9defs.a
                    endc

STACK               equ       100


                    section   bss

*    Local variables

TABCNT              rmb       1
XVALUE              rmb       2
YVALUE              rmb       2
DOTCNT              rmb       1
BYTE                rmb       1
READCT              rmb       2
                    rmb       STACK


                    endsect

                    section   code

*   The following fcb's,(up to SETLEN), will be put
*   in Group Buffer #= (Process ID)

*     Change palette colors
PALSET              fcb       $1b,$31,0,54        Bright Yellow
                    fcb       $1b,$31,1,9         Blue
                    fcb       $1b,$31,2,0         Black
                    fcb       $1b,$31,3,18        Green
                    fcb       $1b,$31,4,36        Bright Red
                    fcb       $1b,$31,5,63        White
                    fcb       $1b,$31,6,25        Medium Blue
                    fcb       $1b,$31,7,52        Medium Yellow-Orange
                    fcb       $1b,$31,8,32        Medium Red
                    fcb       $1b,$31,9,16        Medium Green
                    fcb       $1b,$31,10,36       Bright Red
                    fcb       $1b,$31,11,48       Medium Yellow
                    fcb       $1b,$31,12,63       White
                    fcb       $1b,$31,13,43       Medium Blue-Magenta

*     Draw and save dot
BLDOT               fcb       $1b,$2c,254,46,0,50,0,1,0,6,0,4

DOT                 fcb       $1b,$32,7
                    fcb       $1b,$40,0,50,0,2
                    fcb       $1b,$4a,0,55,0,3
                    fcb       $1b,$40,0,52,0,1
                    fcb       $1b,$4a,0,53,0,4
                    fcb       $1b,$2c,254,40,0,50,0,1,0,6,0,4

DOT2                fcb       $1b,$2c,254,42,0,50,0,1,0,6,0,3
                    fcb       $1b,$2d,254,42,0,25,0,5

DOT3                fcb       $1b,$2c,254,43,0,50,0,2,0,6,0,3
                    fcb       $1b,$2d,254,43,0,25,0,10

*     Draw and save power pill
BLPILL              fcb       $1b,$2c,254,56,0,60,0,10,0,10,0,4

POWPIL              fcb       $1b,$32,8
                    fcb       $1b,$40,0,60,0,11
                    fcb       $1b,$4a,0,69,0,12
                    fcb       $1b,$40,0,62,0,10
                    fcb       $1b,$4a,0,67,0,13
                    fcb       $1b,$2c,254,50,0,60,0,10,0,10,0,4

POW2                fcb       $1b,$2c,254,52,0,60,0,10,0,10,0,3
                    fcb       $1b,$2d,254,52,0,25,0,55

POW3                fcb       $1b,$2c,254,53,0,60,0,11,0,10,0,3
                    fcb       $1b,$2d,254,53,0,25,0,60
*   Blank bonus
BLBON               fcb       $1b,$2c,254,69,0,50,0,170,0,20,0,8

BONUS1              fcb       $1b,$32,10
                    fcb       $1b,$40,0,50,0,174
                    fcb       $1b,$4a,0,57,0,175
                    fcb       $1b,$40,0,52,0,173
                    fcb       $1b,$4a,0,55,0,176
                    fcb       $1b,$40,0,60,0,175
                    fcb       $1b,$4a,0,67,0,176
                    fcb       $1b,$40,0,62,0,174
                    fcb       $1b,$4a,0,65,0,177
                    fcb       $1b,$32,9
                    fcb       $1b,$40,0,56,0,173
                    fcb       $1b,$42,0,56,0,173
                    fcb       $1b,$40,0,58,0,172
                    fcb       $1b,$4a,0,61,0,174
                    fcb       $1b,$40,0,60,0,171
                    fcb       $1b,$44,0,62,0,171
                    fcb       $1b,$40,0,62,0,170
                    fcb       $1b,$44,0,64,0,170
                    fcb       $1b,$2c,254,70,0,50,0,170,0,18,0,8

BONUS2              fcb       $1b,$32,10
                    fcb       $1b,$40,0,88,0,170
                    fcb       $1b,$48,0,90,0,171
                    fcb       $1b,$32,12
                    fcb       $1b,$40,0,80,0,172
                    fcb       $1b,$4a,0,98,0,176
                    fcb       $1b,$32,2
                    fcb       $1b,$44,0,82,0,72
                    fcb       $1b,$40,0,96,0,172
                    fcb       $1b,$44,0,98,0,172
                    fcb       $1b,$42,0,80,0,173
                    fcb       $1b,$42,0,98,0,173
                    fcb       $1b,$32,13
                    fcb       $1b,$40,0,82,0,176
                    fcb       $1b,$4a,0,96,0,177
                    fcb       $1b,$40,0,86,0,176
                    fcb       $1b,$44,0,88,0,176
                    fcb       $1b,$2c,254,71,0,80,0,170,0,20,0,8

BONUS3              fcb       $1b,$32,0
                    fcb       $1b,$40,0,114,0,175
                    fcb       $1b,$4a,0,122,0,177
                    fcb       $1b,$32,10
                    fcb       $1b,$40,0,110,0,171
                    fcb       $1b,$4a,0,126,0,174
                    fcb       $1b,$32,12
                    fcb       $1b,$40,0,116,0,171
                    fcb       $1b,$44,0,118,0,171
                    fcb       $1b,$42,0,124,0,171
                    fcb       $1b,$42,0,126,0,173
                    fcb       $1b,$40,0,110,0,173
                    fcb       $1b,$44,0,112,0,173
                    fcb       $1b,$40,0,118,0,173
                    fcb       $1b,$44,0,120,0,173
                    fcb       $1b,$32,2
                    fcb       $1b,$42,0,110,0,171
                    fcb       $1b,$42,0,126,0,171
                    fcb       $1b,$2c,254,72,0,110,0,170,0,20,0,8

*     Get blank pacman
BLPAC               fcb       $1b,$2c,254,37,0,50,0,25,0,22,0,10
*     Draw and save round full pacman
RFPAC               fcb       $1b,$32,0
                    fcb       $1b,$40,0,50,0,29
                    fcb       $1b,$4a,0,71,0,32
                    fcb       $1b,$40,0,52,0,28
                    fcb       $1b,$4a,0,69,0,33
                    fcb       $1b,$40,0,54,0,27
                    fcb       $1b,$4a,0,67,0,34
                    fcb       $1b,$40,0,58,0,26
                    fcb       $1b,$4a,0,62,0,35
                    fcb       $1b,$2c,254,38,0,50,0,26,0,22,0,10
*     Right facing pacman cycle #1
RFPAC1              fcb       $1b,$2d,254,38,0,90,0,1
                    fcb       $1b,$40,0,98,0,5
                    fcb       $1b,$32,2
                    fcb       $1b,$4a,0,111,0,6
                    fcb       $1b,$2c,254,25,0,82,0,1,0,30,0,10
*     Right facing pacman cycle #2
RFPAC2              fcb       $1b,$2d,254,25,0,82,0,25
                    fcb       $1b,$40,0,106,0,28
                    fcb       $1b,$4a,0,111,0,31
                    fcb       $1b,$2c,254,26,0,82,0,25,0,30,0,10
*     Right facing pacman cycle #3
RFPAC3              fcb       $1b,$2d,254,26,0,82,0,50
                    fcb       $1b,$40,0,102,0,53
                    fcb       $1b,$4a,0,105,0,56
                    fcb       $1b,$40,0,106,0,52
                    fcb       $1b,$4a,0,109,0,57
                    fcb       $1b,$2c,254,27,0,82,0,50,0,30,0,10
*     Left facing pacman cycle #1
LFPAC1              fcb       $1b,$2d,254,38,0,130,0,1
                    fcb       $1b,$40,0,130,0,5
                    fcb       $1b,$4a,0,143,0,6
                    fcb       $1b,$2c,254,28,0,130,0,1,0,30,0,10
*     Left facing pacman cycle #2
LFPAC2              fcb       $1b,$2d,254,28,0,130,0,25
                    fcb       $1b,$40,0,130,0,28
                    fcb       $1b,$4a,0,135,0,31
                    fcb       $1b,$2c,254,29,0,130,0,25,0,30,0,10
*     Left facing pacman cycle #3
LFPAC3              fcb       $1b,$2d,254,29,0,130,0,50
                    fcb       $1b,$40,0,130,0,53
                    fcb       $1b,$4a,0,139,0,56
                    fcb       $1b,$40,0,132,0,52
                    fcb       $1b,$4a,0,135,0,57
                    fcb       $1b,$2c,254,30,0,130,0,50,0,30,0,10
*     Up facing pacman cycle #1
UFPAC1              fcb       $1b,$2d,254,38,0,170,0,1
                    fcb       $1b,$40,0,180,0,1
                    fcb       $1b,$4a,0,181,0,6
                    fcb       $1b,$2c,254,31,0,170,0,1,0,22,0,13
*     Up facing pacman cycle #2
UFPAC2              fcb       $1b,$2d,254,31,0,170,0,25
                    fcb       $1b,$40,0,178,0,25
                    fcb       $1b,$4a,0,183,0,29
                    fcb       $1b,$2c,254,32,0,170,0,25,0,22,0,13
*     Up facing pacman cycle #3
UFPAC3              fcb       $1b,$2d,254,32,0,170,0,50
                    fcb       $1b,$40,0,176,0,51
                    fcb       $1b,$4a,0,185,0,52
                    fcb       $1b,$2c,254,33,0,170,0,50,0,22,0,13
*     Down facing pacman cycle #1
DFPAC1              fcb       $1b,$2d,254,38,0,170,0,75
                    fcb       $1b,$40,0,180,0,79
                    fcb       $1b,$4a,0,181,0,84
                    fcb       $1b,$2c,254,34,0,170,0,72,0,22,0,13
*     Down facing pacman cycle #2
DFPAC2              fcb       $1b,$2d,254,34,0,170,0,96
                    fcb       $1b,$40,0,178,0,105
                    fcb       $1b,$4a,0,183,0,109
                    fcb       $1b,$2c,254,35,0,170,0,96,0,22,0,13
*     Down facing pacman cycle #3
DFPAC3              fcb       $1b,$2d,254,35,0,170,0,121
                    fcb       $1b,$40,0,176,0,132
                    fcb       $1b,$4a,0,185,0,133
                    fcb       $1b,$2c,254,36,0,170,0,121,0,22,0,13

*     The following are used when pacman is killed
*   #1
                    fcb       $1b,$2d,254,33,0,200,0,1
                    fcb       $1b,$2c,254,60,0,200,0,1,0,22,0,10
*   #2
                    fcb       $1b,$2d,254,60,0,200,0,25
                    fcb       $1b,$40,0,204,0,26
                    fcb       $1b,$4a,0,216,0,28
                    fcb       $1b,$40,0,206,0,29
                    fcb       $1b,$44,0,214,0,29
                    fcb       $1b,$2c,254,61,0,200,0,25,0,22,0,10
*   #3
                    fcb       $1b,$2d,254,61,0,200,0,50
                    fcb       $1b,$40,0,204,0,54
                    fcb       $1b,$4a,0,216,0,55
                    fcb       $1b,$40,0,208,0,56
                    fcb       $1b,$44,0,212,0,56
                    fcb       $1b,$42,0,204,0,58
                    fcb       $1b,$42,0,216,0,58
                    fcb       $1b,$2c,254,62,0,200,0,50,0,22,0,10
*   #4
                    fcb       $1b,$2d,254,62,0,200,0,70
                    fcb       $1b,$40,0,200,0,72
                    fcb       $1b,$4a,0,220,0,73
                    fcb       $1b,$42,0,200,0,76
                    fcb       $1b,$42,0,220,0,76
                    fcb       $1b,$42,0,202,0,77
                    fcb       $1b,$42,0,218,0,77
                    fcb       $1b,$42,0,206,0,78
                    fcb       $1b,$42,0,214,0,78
                    fcb       $1b,$42,0,208,0,79
                    fcb       $1b,$42,0,212,0,79
                    fcb       $1b,$2c,254,63,0,200,0,70,0,22,0,10
*   #5
                    fcb       $1b,$2d,254,63,0,200,0,90
                    fcb       $1b,$40,0,200,0,94
                    fcb       $1b,$44,0,220,0,94
                    fcb       $1b,$42,0,202,0,96
                    fcb       $1b,$42,0,218,0,96
                    fcb       $1b,$40,0,204,0,97
                    fcb       $1b,$44,0,206,0,97
                    fcb       $1b,$40,0,214,0,97
                    fcb       $1b,$44,0,216,0,97
                    fcb       $1b,$42,0,210,0,99
                    fcb       $1b,$2c,254,64,0,200,0,90,0,22,0,10
*   #6
                    fcb       $1b,$2d,254,64,0,200,0,110
                    fcb       $1b,$40,0,200,0,115
                    fcb       $1b,$44,0,220,0,115
                    fcb       $1b,$40,0,208,0,118
                    fcb       $1b,$44,0,212,0,118
                    fcb       $1b,$32,0
                    fcb       $1b,$42,0,202,0,116
                    fcb       $1b,$42,0,218,0,116
                    fcb       $1b,$2c,254,65,0,200,0,110,0,22,0,10
*   #7
                    fcb       $1b,$40,0,210,0,135
                    fcb       $1b,$44,0,210,0,139
                    fcb       $1b,$40,0,206,0,137
                    fcb       $1b,$44,0,214,0,137
                    fcb       $1b,$42,0,206,0,135
                    fcb       $1b,$42,0,214,0,135
                    fcb       $1b,$42,0,206,0,139
                    fcb       $1b,$42,0,214,0,139
                    fcb       $1b,$2c,254,66,0,200,0,130,0,22,0,10
*   #8
                    fcb       $1b,$2d,254,66,0,200,0,150
                    fcb       $1b,$32,2
                    fcb       $1b,$40,0,206,0,157
                    fcb       $1b,$44,0,214,0,157
                    fcb       $1b,$40,0,210,0,155
                    fcb       $1b,$44,0,210,0,159
                    fcb       $1b,$32,0
                    fcb       $1b,$42,0,210,0,157
                    fcb       $1b,$2c,254,67,0,200,0,150,0,22,0,10

*     Blank cage door
BLCGDR              fcb       $1b,$2c,254,22,0,170,0,180,0,24,0,1
*     Cage door
CAGDOR              fcb       $1b,$32,8
                    fcb       $1b,$40,0,170,0,180
                    fcb       $1b,$44,0,199,0,180
                    fcb       $1b,$2c,254,23,0,170,0,180,0,24,0,1


*     The following fcb's will draw the ghost objects
*     which will be put in Group buffer #= (Process ID +1)

*     Get blank ghost
BLGHST              fcb       $1b,$2c,254,1,0,50,0,50,0,20,0,10
*     Draw and save basic ghost (no eyes)
BCGHST              fcb       $1b,$32,4           Set color to red
                    fcb       $1b,$40,0,50,0,50   Set draw pointer
                    fcb       $1b,$4a,0,69,0,59   Draw bar rectangle
                    fcb       $1b,$40,0,50,0,50   Set draw pointer
                    fcb       $1b,$32,2           Set color to black
                    fcb       $1b,$4a,0,51,0,51   Draw bar rectangle
                    fcb       $1b,$44,0,53,0,50   Draw line
                    fcb       $1b,$40,0,69,0,50   Set draw pointer
                    fcb       $1b,$4a,0,68,0,51   Draw bar rectangle
                    fcb       $1b,$44,0,66,0,50   Draw line
                    fcb       $1b,$40,0,54,0,59   Set draw pointer
                    fcb       $1b,$44,0,57,0,59   Draw line
                    fcb       $1b,$40,0,62,0,59   Set draw pointer
                    fcb       $1b,$44,0,65,0,59   Draw line
                    fcb       $1b,$2c,254,18,0,50,0,50,0,20,0,10
*     Get blank eyes
*BLKEYE   fcb    $1b,$2c,254,21,0,60,0,1,0,14,0,3
*     Draw and save one eye
EYE                 fcb       $1b,$40,0,62,0,2
                    fcb       $1b,$32,5
                    fcb       $1b,$44,0,63,0,2
                    fcb       $1b,$2c,254,19,0,60,0,1,0,6,0,3
*     Put second eye an save
EYES                fcb       $1b,$2d,254,19,0,68,0,1
                    fcb       $1b,$2c,254,20,0,60,0,1,0,14,0,3
*     Draw and save RED ghost up
RGHUP               fcb       $1b,$2d,254,18,0,50,0,75
                    fcb       $1b,$2d,254,19,0,52,0,78
                    fcb       $1b,$2d,254,19,0,62,0,78
                    fcb       $1b,$2c,254,2,0,50,0,75,0,20,0,13
                    fcb       $1b,$2d,254,2,0,50,0,150
*     WHITE ghost up
WGHUP               fcb       $1b,$32,5
                    fcb       $1b,$40,0,52,0,77
                    fcb       $1b,$4f
                    fcb       $1b,$2c,254,6,0,50,0,75,0,20,0,13
                    fcb       $1b,$2d,254,6,0,50,0,125
*     GREEN ghost up
GGHUP               fcb       $1b,$32,3
                    fcb       $1b,$4f
                    fcb       $1b,$2c,254,10,0,50,0,75,0,20,0,13
                    fcb       $1b,$2d,254,10,0,50,0,100
*     BLUE ghost up
BGHUP               fcb       $1b,$32,6
                    fcb       $1b,$4f
                    fcb       $1b,$2c,254,14,0,50,0,75,0,20,0,13
*     RED ghost facing left
RDGHL               fcb       $1b,$2d,254,18,0,80,0,75
                    fcb       $1b,$2d,254,19,0,82,0,78
                    fcb       $1b,$2d,254,19,0,90,0,78
                    fcb       $1b,$2c,254,3,0,80,0,75,0,28,0,10
                    fcb       $1b,$2d,254,3,0,80,0,150
*     WHITE ghost facing left
WTGHL               fcb       $1b,$32,5
                    fcb       $1b,$40,0,82,0,77
                    fcb       $1b,$4f
                    fcb       $1b,$2c,254,7,0,80,0,75,0,28,0,10
                    fcb       $1b,$2d,254,7,0,80,0,125
*     GREEN ghost facing left
GRGHL               fcb       $1b,$32,3
                    fcb       $1b,$4f
                    fcb       $1b,$2c,254,11,0,80,0,75,0,28,0,10
                    fcb       $1b,$2d,254,11,0,80,0,100
*     BLUE ghost facing left
BLGHL               fcb       $1b,$32,6
                    fcb       $1b,$4f
                    fcb       $1b,$2c,254,15,0,80,0,75,0,28,0,10
*     RED ghost facing right
RDGHR               fcb       $1b,$2d,254,18,0,110,0,75
                    fcb       $1b,$2d,254,19,0,114,0,78
                    fcb       $1b,$2d,254,19,0,122,0,78
                    fcb       $1b,$2c,254,4,0,102,0,75,0,28,0,10
                    fcb       $1b,$2d,254,4,0,102,0,150
*     WHITE ghost facing right
WTGHR               fcb       $1b,$32,5
                    fcb       $1b,$40,0,112,0,77
                    fcb       $1b,$4f
                    fcb       $1b,$2c,254,8,0,102,0,75,0,28,0,10
                    fcb       $1b,$2d,254,8,0,102,0,125
*     GREEN ghost facing right
GRGHR               fcb       $1b,$32,3
                    fcb       $1b,$4f
                    fcb       $1b,$2c,254,12,0,102,0,75,0,28,0,10
                    fcb       $1b,$2d,254,12,0,102,0,100
*     BLUE ghost facing right
BLGHR               fcb       $1b,$32,6
                    fcb       $1b,$4f
                    fcb       $1b,$2c,254,16,0,102,0,100,0,28,0,10

                    fcb       $1b,$2d,254,16,1,94,0,25
                    fcb       $1b,$40,1,102,0,27
                    fcb       $1b,$32,6
                    fcb       $1b,$4f
                    fcb       $1b,$2c,254,16,1,94,0,25,0,28,0,10

*     Red ghost facing down
RGHDN               fcb       $1b,$2d,254,18,0,140,0,75
                    fcb       $1b,$2d,254,19,0,142,0,78
                    fcb       $1b,$2d,254,19,0,152,0,78
                    fcb       $1b,$2c,254,5,0,140,0,72,0,20,0,13
                    fcb       $1b,$2d,254,5,0,140,0,148
*     White ghost facing down
WGHDN               fcb       $1b,$32,5
                    fcb       $1b,$40,0,142,0,77
                    fcb       $1b,$4f
                    fcb       $1b,$2c,254,9,0,140,0,72,0,20,0,13
                    fcb       $1b,$2d,254,9,0,140,0,123
*     Green ghost facing down
GGHDN               fcb       $1b,$32,3
                    fcb       $1b,$4f
                    fcb       $1b,$2c,254,13,0,140,0,72,0,20,0,13
                    fcb       $1b,$2d,254,13,0,140,0,98
*     Blue ghost facing down
BGHDN               fcb       $1b,$32,6
                    fcb       $1b,$4f
                    fcb       $1b,$2d,254,5,1,100,0,48
                    fcb       $1b,$40,1,110,0,56
                    fcb       $1b,$32,6
                    fcb       $1b,$4f
                    fcb       $1b,$2c,254,17,1,100,0,48,0,20,0,13

                    fcb       255
SETLEN              equ       *-PALSET


DOTAB1              fdb       284
                    fcb       21,1,1,14,41,1,14,13,7,22,1,10,7
                    fcb       55,10,7,21,13,4,41,13,4,1,16,7
                    fcb       55,16,7,21,19,14,1,25,11,47,25,11
                    fcb       21,28,14,1,34,14,41,34,14,7,40,28
                    fcb       1,46,4,21,46,4,41,46,4,61,46,4
                    fcb       1,52,34

                    fcb       1,1,6,1,34,7,7,40,3,9,16,7,13,1,6
                    fcb       13,34,3,21,7,3,21,19,6,21,40,3
                    fcb       27,1,3,27,13,3,27,34,3,27,46,3
                    fcb       41,1,3,41,13,3,41,34,3,41,46,3
                    fcb       47,7,3,47,19,6,47,40,3,55,1,6
                    fcb       55,34,3,59,16,7,61,40,3,67,1,6
                    fcb       67,34,7,0,0

                    fcb       1,7,4,67,7,4,1,40,5,67,40,5
                    fcb       1,25,0,67,25,0,33,28,0,35,28,0
                    fcb       0,25,0,68,25,0,0,0

DOTAB2              fdb       302
                    fcb       24,1,1,7,55,1,7,13,4,22,1,7,7
                    fcb       55,7,7,1,13,7,21,13,6,37,13,6
                    fcb       55,13,7,1,19,7,21,19,14,55,19,7
                    fcb       13,25,5,47,25,5,21,28,14,1,34,16
                    fcb       37,34,16,1,40,3,13,40,22,63,40,3
                    fcb       1,46,7,21,46,14,55,46,7,1,52,34

                    fcb       1,1,14,1,46,3,5,40,3,7,19,6,13,1,5
                    fcb       13,19,10,21,4,4,21,19,6,21,40,3
                    fcb       31,13,3,31,34,3,33,1,2,35,46,3
                    fcb       37,13,3,37,34,3,47,4,4,47,19,6
                    fcb       47,40,3,55,1,5,55,19,10,61,19,6
                    fcb       63,40,3,67,1,14,67,46,3,0,0

                    fcb       1,7,5,67,7,5,1,40,5,67,40,5
                    fcb       33,0,0,33,1,0,35,52,0,35,53,0
                    fcb       33,28,0,35,28,0,0,0

DOTAB3              fdb       294
                    fcb       23,1,1,16,37,1,16,13,7,22,1,10,7
                    fcb       55,10,7,21,13,6,37,13,6,1,16,7
                    fcb       55,16,7,21,19,14,1,25,11,47,25,11
                    fcb       21,28,14,1,34,16,37,34,16,1,40,3
                    fcb       13,40,22,63,40,3,1,46,7,21,46,6
                    fcb       37,46,6,55,46,7,1,52,34

                    fcb       1,1,6,1,34,3,1,46,3,5,40,3
                    fcb       13,1,16,21,7,3,21,19,6,21,40,3
                    fcb       31,1,3,31,13,3,31,34,3,31,46,3
                    fcb       37,1,3,37,13,3,37,34,3,37,46,3
                    fcb       47,7,3,47,19,6,47,40,3,55,1,16
                    fcb       63,40,3,67,1,6,67,34,3,67,46,3
                    fcb       0,0

                    fcb       1,7,4,67,7,4,1,40,5,67,40,5
                    fcb       0,25,0,1,25,0,3,25,0,5,25,0
                    fcb       7,25,0,9,25,0,11,25,0
                    fcb       57,25,0,59,25,0,61,25,0
                    fcb       63,25,0,65,25,0,67,25,0
                    fcb       68,25,0,33,28,0,35,28,0
                    fcb       0,0

DOTAB4              fdb       327
                    fcb       24,1,1,34,21,7,14,1,10,7,55,10,7
                    fcb       13,13,22,1,16,7,55,16,7,21,19,14
                    fcb       3,22,6,55,22,6,13,25,5,47,25,5
                    fcb       3,28,6,21,28,14,55,28,6,1,34,16
                    fcb       37,34,16,1,40,7,21,40,14,55,40,7
                    fcb       1,46,7,21,46,14,55,46,7,1,52,34

                    fcb       1,1,6,1,34,3,1,46,3,3,22,3,7,1,4
                    fcb       7,40,3,13,1,14,13,46,3,21,1,3
                    fcb       21,19,12,25,7,3,31,34,3,33,1,3
                    fcb       33,13,3,35,46,3,37,34,3,43,7,3
                    fcb       47,1,3,47,19,12,55,1,14,55,46,3
                    fcb       61,1,4,61,40,3,65,22,3,67,1,6
                    fcb       67,34,3,67,46,3,0,0

                    fcb       1,7,4,67,7,4,1,40,5,67,40,5
                    fcb       33,28,0,35,28,0,33,1,0,35,52,0
                    fcb       33,0,0,35,53,0,0,0

DOTAB5              fdb       310
                    fcb       29,1,1,16,37,1,16,7,7,28,7,13,4
                    fcb       21,13,6,37,13,6,55,13,4,1,19,7
                    fcb       21,19,14,55,19,7,13,22,5,47,22,5
                    fcb       1,25,7,55,25,7,21,28,14,1,31,4
                    fcb       61,31,4,7,34,4,21,34,4,31,34,4
                    fcb       41,34,4,55,34,4,7,40,4,21,40,6
                    fcb       37,40,6,55,40,4,1,46,34
                    fcb       1,52,16,37,52,16

                    fcb       1,1,7,1,31,8,7,1,3,7,13,3,7,25,6
                    fcb       13,7,3,13,19,6,13,40,3,21,7,3
                    fcb       21,19,4,21,34,5,27,28,3,31,1,3
                    fcb       31,13,3,31,34,3,31,46,3,37,1,3
                    fcb       37,13,3,37,34,3,37,46,3,41,28,3
                    fcb       47,7,3,47,19,4,47,34,5,55,7,3
                    fcb       55,19,6,55,40,3,61,1,3,61,13,3
                    fcb       61,25,6,67,1,7,67,31,8,0,0

                    fcb       1,7,4,67,7,4,1,40,5,67,40,5
                    fcb       1,25,0,67,25,0,33,28,0,35,28,0
                    fcb       0,25,0,68,25,0,0,0

DOTAB6              fdb       336
                    fcb       25,1,1,34,1,7,4,19,7,16,61,7,4
                    fcb       7,13,7,25,13,4,37,13,4,49,13,7
                    fcb       1,19,34,1,25,4,15,25,4,47,25,4
                    fcb       61,25,4,7,28,5,21,28,14,53,28,5
                    fcb       1,34,16,37,34,16,7,40,7,25,40,10
                    fcb       49,40,7,1,46,4,19,46,16,61,46,4
                    fcb       1,52,34

                    fcb       1,1,18,7,7,3,7,19,6,7,40,3,13,1,7
                    fcb       13,34,7,15,25,2,19,7,3,19,40,3
                    fcb       21,19,6,25,1,7,25,34,7,31,13,3
                    fcb       31,34,3,33,1,3,35,46,3,37,13,3
                    fcb       37,34,3,43,1,7,43,34,7,47,19,6
                    fcb       49,7,3,49,40,3,53,25,2,55,1,7
                    fcb       55,34,7,61,7,3,61,19,6,61,40,3
                    fcb       67,1,18,0,0

                    fcb       1,7,5,67,7,5,1,40,4,67,40,4
                    fcb       33,1,0,35,52,0,33,28,0,35,28,0
                    fcb       33,0,0,35,53,0,0,0

DOTAB7              fdb       318
                    fcb       31,1,1,15,39,1,15,21,7,14,5,10,3
                    fcb       13,10,5,47,10,5,59,10,3,21,13,5
                    fcb       39,13,5,1,16,7,55,16,7,13,19,22
                    fcb       5,22,3,59,22,3,1,25,3,13,25,5
                    fcb       47,25,5,63,25,3,5,28,5,21,28,14
                    fcb       55,28,5,1,34,11,27,34,8,47,34,11
                    fcb       7,40,13,37,40,13,1,46,4,21,46,6
                    fcb       37,46,6,61,46,4,1,52,34

                    fcb       1,1,6,1,34,7,5,10,3,5,22,3,7,40,3
                    fcb       9,1,4,9,16,3,9,28,3,13,1,10,13,34,3
                    fcb       15,40,5,21,7,3,21,19,6,21,40,3
                    fcb       27,28,3,29,1,3,29,13,3,31,34,3
                    fcb       31,46,3,37,34,3,37,46,3,39,1,3
                    fcb       39,13,3,41,28,3,47,7,3,47,19,6
                    fcb       47,40,3,53,40,5,55,1,10,55,34,3
                    fcb       59,1,4,59,16,3,59,28,3,61,40,3
                    fcb       63,10,3,63,22,3,67,1,6,67,34,7,0,0

                    fcb       1,7,4,67,7,4,1,40,5,67,40,5
                    fcb       1,25,0,67,25,0,33,28,0,35,28,0
                    fcb       0,25,0,68,25,0,0,0

DOTAB8              fdb       332
                    fcb       32,1,1,15,37,1,16,7,7,4,19,7,3
                    fcb       29,7,5,43,7,3,55,7,4,1,10,4,61,10,4
                    fcb       19,13,15,1,16,7,55,16,7,13,19,22
                    fcb       1,22,5,59,22,5,13,25,5,47,25,5
                    fcb       1,28,5,21,28,14,59,28,5,1,34,16
                    fcb       37,34,16,1,40,7,21,40,15,55,40,7
                    fcb       1,46,7,21,46,3,31,46,5,45,46,3
                    fcb       55,46,7,1,52,16,39,52,15

                    fcb       1,1,14,1,46,3,7,1,6,7,40,3,9,22,3
                    fcb       13,1,14,13,46,3,19,7,3,21,19,6
                    fcb       21,40,3,23,1,3,25,13,3,25,46,3,29,1,3
                    fcb       31,34,3,31,46,3,33,1,5,35,40,5
                    fcb       37,1,3,37,34,3,39,46,3,41,13,3
                    fcb       43,1,3,45,46,3,47,7,3,47,19,6
                    fcb       49,40,3,55,1,14,55,46,3,59,22,3
                    fcb       61,1,6,61,40,3,67,1,14,67,46,3,0,0

                    fcb       1,7,4,67,7,4,1,40,5,67,40,5
                    fcb       33,0,0,33,1,0,35,52,0,35,53,0
                    fcb       33,28,0,35,28,0,0,0


GHSET
                    fcb       6,77,0,245,0,79,0,245,0,79
                    fcb       -1,2,150,150,0,0,4,4,4,36

                    fcb       6,93,1,117,0,79,1,117,0,79
                    fcb       -1,14,100,100,0,0,4,4,6,25

                    fcb       6,82,1,29,0,79,1,29,0,79
                    fcb       -1,6,50,50,0,0,4,4,5,63

                    fcb       6,88,1,77,0,79,1,77,0,79
                    fcb       -1,10,10,10,0,0,4,4,3,18


*
*   The SETUPB routine is used to insert the PROCESS I.D. number into
* the GROUP BUFFER numbers of the GETBLK and PUTBLK strings.
*   This had me stumped for a while because the draw codes are in FCB's
* in the program area, which legally in OS9 can't be changed. The way I
* found to get around this is that since the memory area for the board array
* has already been allocated (3726 bytes), but it has not yet been filled,
* all the object draw fcb's can be transfered to this memory area and as
* the data is transfered I change the dummy GROUP BUFFER (254) number in
* the GETBLK and PUTBLK commands, to the PROCESS I.D. number.
*

SETUPB              leay      ARRAY,U             Point to where data is to go
                    leax      PALSET,pcr          Point to FCB's to read
TRLOOP              lda       ,X+                 Get a byte from program area
                    cmpa      #255                255 = end of data
                    beq       WRTOUT              If so, then go write it out
                    cmpa      #254                Do we put I.D. here ?
                    bne       TRSTOR              If not, then store this byte
                    lda       PROCID              If so, then get process I.D. byte
TRSTOR              sta       ,Y+                 Store byte in data area
                    bra       TRLOOP              Loop till end of FCB's (255)

*     The fcb's have been transfered so now output them to path

WRTOUT              leax      ARRAY,U             Point to where FCB data was put
                    ldy       #SETLEN-1           Get byte count to output
                    lda       PATH                Set output path
                    os9       I$Write             Go output data
                    lbcs      ERR1                Branch if any errors
                    rts

*     Initially we clear the array then put the array data
*     in the screen save table, in case there are more than
*     one players. The array will be filled with $ff s.

SETUPC              bsr       CLRARR              Go setup the array & variables

FILTAB              leay      TABLE2,U            Point to player 2 table
                    sty       YVALUE              Save temporary pointer
                    leay      TABLE1,U            Point to player 1 table
                    sty       XVALUE,U            Save temporary value
                    leax      ARRAY,U             Point X reg. at array
                    leax      68,X                Move to first dot location -2
                    clr       DOTCNT
FLOOP               leax      2,X                 Bump X reg. 2 times
                    inc       DOTCNT
                    lda       ,X                  Get a byte from the array
                    ldy       XVALUE,U
                    sta       ,Y+                 Put it in table 1,bump pointer
                    sty       XVALUE,U
                    ldy       YVALUE,U
                    sta       ,Y+                 Put it in table 2,bump pointer
                    sty       YVALUE,U
                    lda       DOTCNT
                    cmpa      #34
                    bne       FLOOP
                    cmpx      #ARREND-73          Are we done ?
                    bge       FILEND              If so then get out
                    leax      139,X               Move down 3 lines
                    clr       DOTCNT
                    bra       FLOOP

FILEND              lbra      RETURN              Leave setup routine

*     This routine fills the entire array with -1's
*     The -1's will represent walls when the rest of the array is filled

CLRARR              leax      ARRAY,U             Point to array
                    ldd       #$ffff
CLRLOP              std       ,X++                Fill 2 bytes in array
                    cmpx      #ARREND             End of array yet?
                    ble       CLRLOP
                    leax      ARRAY,U
                    ldd       #$0000
                    std       -36,X
                    std       -105,X
                    std       3761,X
                    std       3830,X

*     This routine will put DOTS (=2) and SPACES (=0) in array

FILARR              lda       BRDNUM              Get board number
                    deca
                    bne       SEL2
                    leay      DOTAB1,pcr
                    bra       SELEND
SEL2                deca
                    bne       SEL3
                    leay      DOTAB2,pcr
                    bra       SELEND
SEL3                deca
                    bne       SEL4
                    leay      DOTAB3,pcr
                    bra       SELEND
SEL4                deca
                    bne       SEL5
                    leay      DOTAB4,pcr
                    bra       SELEND
SEL5                deca
                    bne       SEL6
                    leay      DOTAB5,pcr
                    bra       SELEND
SEL6                deca
                    bne       SEL7
                    leay      DOTAB6,pcr
                    bra       SELEND
SEL7                deca
                    bne       SEL8
                    leay      DOTAB7,pcr
                    bra       SELEND
SEL8                leay      DOTAB8,pcr

SELEND              ldd       ,Y++                Get Dot total
                    std       SCNTOT
                    lda       ,Y+                 Get number of entries
                    sta       TABCNT
LOOP                ldd       ,Y++                Get 2 bytes & bump Y reg. twice
                    beq       PUTLOP              End of DOT table=0000,Go do PILLS
                    sta       XVALUE              Save xvalue, B holds yvalue
                    lda       ,Y+                 Get # of dots to put on line
                    sta       DOTCNT              Save this number
CALC                lda       #69
                    mul                           Multiply yvalue by 69
                    addb      XVALUE              Add xvalue to result
                    adca      #$00                Add any carry to result
                    leax      ARRAY,U             Point to start of array
                    leax      D,X                 Add offset to spot in array
                    lda       #$02                a 2 in array signifies a dot
                    clrb                          a 0 in array signifies a space
                    cmpb      TABCNT              Done all dots on line yet ?
                    beq       DNLOOP              If so then do the down lines

*     This loop writes dots and spaces across
ACLOOP              sta       ,X+                 Put a dot in array
                    lda       #1
                    cmpa      DOTCNT              If dotcnt=1 then
                    beq       SKIP                don't put spaces
                    stb       ,X+                 Put 1 space in array
SKIP                lda       #$02
                    dec       DOTCNT              Decrement dot counter
                    bne       ACLOOP              Loop till zero
                    dec       TABCNT              Decrement table item counter
                    bra       LOOP                Loop till tabcnt=0

*     This loop writes dots and spaces down
*     When it puts a dot it also checks to see
*     if where it puts the dot, it is an
*     intersection. If so it adds 1 to number
*     to flag that spot as an intersection.

DNLOOP              tst       -1,X                Look at spot to left
                    bmi       TEST2               Branch if wall
                    adda      #1                  Intersection, add 1 to it
                    bra       PUTIT               Go put byte in array
TEST2               tst       1,X                 Look at spot to right
                    bmi       PUTIT
                    adda      #1                  Intersection

PUTIT               sta       ,X                  Put a dot in array
                    lda       #1
                    cmpa      DOTCNT              If dotcnt=1 then
                    beq       SKIP2               don't put spaces
                    leax      69,X                Add 69 to index reg.
                    stb       ,X                  Store a space
                    leax      69,X                Add 69 to index reg.
                    stb       ,X                  Store a space
                    leax      69,X                Add 69 to index reg.
SKIP2               lda       #$02
                    dec       DOTCNT              Decrement dot counter
                    bne       DNLOOP              Loop till zero
                    bra       LOOP                Go get another table item

*     This routine will put POWER PILLS (=4) in array
*     Y reg. already points to power pill table
*PUTPOW   leay   POWDOT,pcr  Point to power pill table

PUTLOP              ldd       ,Y++                Get xvalue and yvalue
                    cmpd      #$0000              End of table yet?
                    beq       DONE
                    sta       XVALUE              Save for later
                    lda       ,Y+                 Get byte to put in array
                    sta       BYTE                Save it
                    lda       #69
                    mul                           Multiply (yvalue-1) by 69
                    addb      XVALUE              Add xvalue to result
                    adca      #$00                Add in any carry
                    leax      ARRAY,U             Point to start of array
                    leax      D,X                 Add offset to spot in array
                    lda       BYTE                Get byte to put in array
                    sta       ,X                  Put byte in array
                    bra       PUTLOP              Loop till done

DONE                nop
*         ldd    DTOTAL,pcr  Get total # of dots
*         std    SCNTOT      Give it to screen total

*    Fill tables with ghost data

GHFILL              leax      GHSET,pcr           Point to bytes to transfer
                    leay      GHTABL,U            Point to where bytes go
                    ldb       #80                 Transfer 80 bytes
FLLOOP              lda       ,X+                 Get a byte
                    sta       ,Y+                 Store it
                    decb                          Decrement loop counter
                    bne       FLLOOP              Loop till done

GHDATA              leax      GHSET,pcr           Point to bytes to transfer
                    leay      G1OFST,U            Point to where bytes go
                    ldb       #80                 Transfer 80 bytes
GHLOOP              lda       ,X+                 Get a byte
                    sta       ,Y+                 Store it
                    decb                          Decrement counter
                    bne       GHLOOP              Loop till done

RETURN              rts



                    endsect

