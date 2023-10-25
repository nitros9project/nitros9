****************************************
* Sample kick application for Liber809
* James Wilkinson
* v.2 - March 28, 2012
****************************************

* Note periods
B4                  equ       255
C5                  equ       243
C5S                 equ       230
D5                  equ       217
D5S                 equ       204
E5                  equ       193
F5                  equ       182
F5S                 equ       173
G5                  equ       162
G5S                 equ       153
A5                  equ       144
A5S                 equ       136
B5                  equ       128
C6                  equ       121
C6S                 equ       114
D6                  equ       108
D6S                 equ       102
E6                  equ       96
F6                  equ       91
F6S                 equ       85
G6                  equ       81
G6S                 equ       76
A6                  equ       72
A6S                 equ       68
B6                  equ       64
C7                  equ       60
C7S                 equ       57
D7                  equ       53
D7S                 equ       50
E7                  equ       47
F7                  equ       45
F7S                 equ       42
G7                  equ       40
G7S                 equ       37
A7                  equ       35
A7S                 equ       33
B7                  equ       31
C8                  equ       29
C8S                 equ       27
D8                  equ       26
D8S                 equ       24
E8                  equ       23
F8                  equ       22
F8S                 equ       21
G8                  equ       19
G8S                 equ       18
A8                  equ       17
A8S                 equ       16
B8                  equ       15
C9                  equ       14

* Note volume levels
VOL03               equ       1
VOL05               equ       1
VOL10               equ       3
VOL20               equ       7
VOL40               equ       10
VOL52               equ       13
VOL64               equ       15

* Note durations
DUR01               equ       4
DUR03               equ       DUR01*3
DUR07               equ       DUR01*7
DUR11               equ       DUR01*11

****************************************
* Track for each voice, in triplets of
* period, volume, and duration

Track0              fcb       F6,VOL40,DUR01,C6,VOL05,DUR01,E6,VOL40,DUR01,G5,VOL03,DUR01,C6,VOL40,DUR01,F6,VOL05,DUR01,D6,VOL40,DUR01,E6,VOL05,DUR01
                    fcb       F6,VOL40,DUR01,C6,VOL03,DUR01,E6,VOL40,DUR01,D6,VOL05,DUR01,C6,VOL40,DUR01,F6,VOL05,DUR01,G5,VOL40,DUR01,E6,VOL05,DUR01
                    fcb       F6,VOL40,DUR01,C6,VOL05,DUR01,E6,VOL40,DUR01,G5,VOL03,DUR01,C6,VOL40,DUR01,F6,VOL05,DUR01,D6,VOL40,DUR01,E6,VOL05,DUR01
                    fcb       F6,VOL40,DUR01,C6,VOL03,DUR01,E6,VOL40,DUR01,D6,VOL05,DUR01,C6,VOL40,DUR01,F6,VOL05,DUR01,G5,VOL40,DUR01,E6,VOL05,DUR01
                    fcb       F6,VOL40,DUR01,C6,VOL05,DUR01,E6,VOL40,DUR01,G5,VOL03,DUR01,C6,VOL40,DUR01,F6,VOL05,DUR01,D6,VOL40,DUR01,E6,VOL05,DUR01
                    fcb       F6,VOL40,DUR01,C6,VOL03,DUR01,E6,VOL40,DUR01,D6,VOL05,DUR01,C6,VOL40,DUR01,F6,VOL05,DUR01,G5,VOL40,DUR01,E6,VOL05,DUR01
                    fcb       F6,VOL40,DUR01,C6,VOL05,DUR01,E6,VOL40,DUR01,G5,VOL03,DUR01,C6,VOL40,DUR01,F6,VOL05,DUR01,D6,VOL40,DUR01,E6,VOL05,DUR01
                    fcb       F6,VOL40,DUR01,C6,VOL03,DUR01,E6,VOL40,DUR01,D6,VOL05,DUR01,C6,VOL40,DUR01,F6,VOL05,DUR01,G5,VOL40,DUR01,E6,VOL05,DUR01
                    fcb       0,0,0
Track1              fcb       D5,VOL40,DUR01,0,0,DUR03,C5,VOL20,DUR01,0,0,DUR01,D5,VOL40,DUR01,0,0,DUR01,D5,VOL20,DUR01,0,0,DUR01,C5,VOL40,DUR01,0,0,DUR01,C5,VOL40,DUR01,0,0,DUR01,D5,VOL40,DUR01,0,0,DUR01
                    fcb       C5,VOL40,DUR01,0,0,DUR01,C5,VOL20,DUR01,0,0,DUR01,D5,VOL10,DUR01,0,0,DUR11
                    fcb       C5,VOL40,DUR01,0,0,DUR03,D5,VOL20,DUR01,0,0,DUR01,C5,VOL40,DUR01,0,0,DUR01,C5,VOL20,DUR01,0,0,DUR01,C5,VOL40,DUR01,0,0,DUR01,C5,VOL10,DUR01,0,0,DUR01,C5,VOL40,DUR01,0,0,DUR01
                    fcb       C5,VOL40,DUR01,0,0,DUR03,C5,VOL20,DUR01,0,0,DUR03,C5,VOL40,DUR01,0,0,DUR07
                    fcb       0,0,0
