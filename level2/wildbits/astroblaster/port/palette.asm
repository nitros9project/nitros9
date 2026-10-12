* A = raw G80 palette byte; X = four-byte B,G,R,reserved destination.
* Preserves A,X,Y,U; B and CC scratch. No hardware access.
* Bits 2:0 red, 5:3 green, 7:6 blue (segag80r_v.cpp).
* Tables model the documented resistor network, not evenly spaced RGB332:
* red/green 4700/2400/1200 ohm; blue 2000/1000 ohm; pulldown 220 ohm.
* Scale all channels together so the greatest network output is 255;
* round combined weights once. The resulting white is RGB(250,250,255).
DecodeG80Color     pshs      a,y
                    tfr       a,b
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    leay      G80BlueLevels,pcr
                    ldb       b,y
                    stb       CLUT_Blue,x
                    ldb       PC_SavedColor,s ; stack offset: original color byte
                    lsrb
                    lsrb
                    lsrb
                    andb      #G80_RGB3Mask
                    leay      G80RedGreenLevels,pcr
                    ldb       b,y
                    stb       CLUT_Green,x
                    ldb       PC_SavedColor,s ; stack offset: original color byte
                    andb      #G80_RGB3Mask
                    ldb       b,y
                    stb       CLUT_Red,x
                    clr       CLUT_Reserved,x
                    puls      a,y,pc
G80RedGreenLevels  fcb       0,36,71,108,143,179,214,250
G80BlueLevels      fcb       0,85,170,255
