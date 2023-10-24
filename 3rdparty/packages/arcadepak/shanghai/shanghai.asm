                    nam       Shanghai
                    ttl       program module

                    use       defsfile

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

U0000               rmb       1
U0001               rmb       1
U0002               rmb       1
U0003               rmb       1
U0004               rmb       1
U0005               rmb       1
U0006               rmb       1
U0007               rmb       1
U0008               rmb       1
U0009               rmb       1
U000A               rmb       1
U000B               rmb       1
U000C               rmb       2
U000E               rmb       2
U0010               rmb       1
U0011               rmb       1
U0012               rmb       1
U0013               rmb       1
U0014               rmb       2
U0016               rmb       1
U0017               rmb       1
U0018               rmb       2
U001A               rmb       1
U001B               rmb       5
U0020               rmb       1
U0021               rmb       1
U0022               rmb       1
U0023               rmb       1
U0024               rmb       1
U0025               rmb       1
U0026               rmb       1
U0027               rmb       1
U0028               rmb       1
U0029               rmb       1
U002A               rmb       1
U002B               rmb       1
U002C               rmb       1
U002D               rmb       1
U002E               rmb       2
U0030               rmb       3
U0033               rmb       1
U0034               rmb       3
U0037               rmb       2
U0039               rmb       1
U003A               rmb       2
U003C               rmb       5
U0041               rmb       1
U0042               rmb       2
U0044               rmb       2
U0046               rmb       2
U0048               rmb       2
U004A               rmb       1
ScTyp               rmb       1
ScnWidth            rmb       2
ScnHeight           rmb       2
Foreground          rmb       1
Background          rmb       1
Border              rmb       1
U0053               rmb       2
U0055               rmb       2
U0057               rmb       4
U005B               rmb       1
U005C               rmb       1
U005D               rmb       4
U0061               rmb       9
U006A               rmb       48
X009A               rmb       5
X009F               rmb       1
X00A0               rmb       6
U00A6               rmb       28
U00C2               rmb       2
U00C4               rmb       2
U00C6               rmb       1
U00C7               rmb       2
U00C9               rmb       1
U00CA               rmb       1
U00CB               rmb       2
U00CD               rmb       1
U00CE               rmb       4
U00D2               rmb       1
U00D3               rmb       109
X0140               rmb       320
X0280               rmb       1
X0281               rmb       152
X0319               rmb       7
X0320               rmb       201
U03E9               rmb       275
X04FC               rmb       4
X0500               rmb       2
X0502               rmb       158
X05A0               rmb       2
X05A2               rmb       1104
U09F2               rmb       98
U0A54               rmb       46
FileName            rmb       1626
X10DC               rmb       538
X12F6               rmb       2826
U1E00               rmb       2088
Palette             rmb       16
U2638               rmb       3618
size                equ       .

name                fcs       /Shanghai/
                    fcb       $01
L0016               fdb       $0037
                    fdb       $2822
                    fdb       $1524
                    fdb       $0D0C
                    fdb       $260C
                    fdb       $0707
                    fdb       $3F3F
                    fdb       $383F
                    fdb       $0037
                    fdb       $2822
                    fdb       $1524
                    fdb       $0D0C
                    fdb       $260C
                    fdb       $3738
                    fdb       $3E3F
                    fdb       $383F

* Initialize the screen
L0036               fcb       $1B
                    fcb       $24
                    fcb       $1B
                    fcb       $20
                    fcb       $08
                    fcb       $00
                    fcb       $00
                    fcb       $28
                    fcb       $18
                    fcb       $00
                    fcb       $09
                    fcb       $09
                    fcb       $1B
                    fcb       $21
                    fcb       $05
                    fcb       $20
Title               fcc       "Shanghai - (C) Copyright 1986-1987 Activision, Inc."
                    fcb       $0D
                    fcb       $0A
                    fcb       $0A
                    fcc       "Programmed by : Rick Adams"
                    fcb       $0D
                    fcb       $0A
                    fcc       "Designed by   : Brodie Lockard"
                    fcb       $0D
                    fcb       $0A
                    fcc       "OS-9 Port by  : Bill Nobel"
                    fcb       $0D
                    fcb       $0A
                    fcc       "              : and Alan DeKok"
                    fcb       $0D
                    fcb       $0A
                    fcc       " Modifications (C) 1994 Bill Nobel and Alan DeKok"
                    fcb       $0D
                    fcb       $0A

start               clra
                    clrb
                    std       >FileName           Set filename to null
L012C               lda       ,X+                 Get the next character from the command-line arguments
                    cmpa      #'                  '         Is it a space?
                    beq       L012C               Yes, skip it
                    cmpa      #13                 Is it a CR?
                    beq       L015A               Yes, skip it
                    cmpa      #45                 Is it a dash?
                    bne       Exit                No, exit
                    ldd       ,X++                Get the next two bytes from the command line
                    anda      #$DF
                    cmpd      #$463D              Is it F=?
                    bne       Exit                No, exit
                    stx       >FileName           Store the filename
                    bra       L015A

Exit                leax      >Title,PC           Point to the title
                    ldy       #225                Write 225 bytes
                    lda       #1                  to stdout
                    os9       I$Write             Write the title
                    clrb                          Clear the error code
                    os9       F$Exit              Exit back to OS-9

L015A               tfr       U,X                 Swap U and X
                    clrb
L015D               clr       ,X+
                    decb
                    bne       L015D
                    clra
                    std       <U0057
                    leax      >Intercept,PC
                    os9       F$Icpt              Set an intercept handler
                    ldd       #SS.Opt
                    ldx       #$0082
                    os9       I$GetStt            Get stdin options
                    ldx       #$00A2
                    os9       I$GetStt            Get stdin options again
                    clr       <U00A6              Turn off echo
                    ldx       #$00A2
                    os9       I$SetStt            Set the stdin options
                    lda       #1
                    ldx       >FileName           Get the name of the custom tiles
                    bne       OpenTile            Open the custom tiles if not null
                    leax      >TileFile,PC        Get the name of the default tiles
                    os9       I$Open              Open the default tiles
                    bcc       L019E               Branch if no error
                    leax      >SysDir,PC
OpenTile            os9       I$Open
                    lbcs      TilDatErr
L019E               ldb       #SS.Size
                    os9       I$GetStt            Get the file size
                    leax      ,X                  Check the MSB of the file size
                    lbne      NoTileErr           Error if not zero
                    cmpu      #9710               Check the LSB of the file size
                    lbne      NoTileErr           Error if not 9710 bytes
                    ldx       #2692               Store the tile data at U2692
                    ldy       #9710
                    os9       I$Read              Read 9710 bytes
                    lbcs      TilDatErr           Branch if error
                    os9       I$Close             Close the tiles
                    leax      >L0016,PC
                    ldu       #2646
                    ldb       #32
                    bsr       cpymem              Copy 32 bytes from L0016 to 0A56
                    ldu       #2647
                    ldx       #12394
                    ldb       #8
                    bsr       cpymem              Copy 8 bytes from 306A to 0A57
                    ldu       #2663
                    ldx       #12394
                    ldb       #8
                    bsr       cpymem              Copy 8 bytes from 306A to 0A67
                    bra       L01EB

* Copy the number of bytes in B from X to U
* B = the number of bytes to copy
* X = the source memory block
* Y = the destination memory block
cpymem              lda       ,X+
                    sta       ,U+
                    decb
                    bne       cpymem
                    rts

L01EB               ldb       #4                  Need 4 blocks
                    os9       F$AllRAM            Allocate 4 blocks
                    lbcs      ScnMemErr           Branch if error
                    std       <U0057              Store the pointer to screen memory
                    lbsr      SetScrn
                    lbsr      L2BA9
                    lbsr      L0A7A
                    ldd       #1543
                    lbsr      L28D5
                    leax      >X0140,X
                    leau      >Copyright,PC
                    lbsr      L0FA2
                    ldd       #276
                    lbsr      L28D5
                    leax      >$FF60,X
                    leau      >Title3,PC
                    lbsr      L0FA2
                    ldd       #277
                    lbsr      L28D5
                    leau      >Title4,PC
                    lbsr      L0FA2
                    ldd       #6676
                    lbsr      L28D5
                    leax      >$FF60,X
                    leau      >Title1,PC
                    lbsr      L0FA2
                    ldd       #7445
                    lbsr      L28D5
                    leau      >Title2,PC
                    lbsr      L0FA2
                    ldd       #279
                    lbsr      L28D5
                    leau      >Title5,PC
                    lbsr      L0FA2
                    lbsr      L2DA1
                    lda       #9
                    sta       <U0021
                    lbsr      L0F8F
                    lbsr      L0DFE
                    clr       <U0021
                    lbsr      L1513
                    lbsr      Sleep120
                    lbsr      Sleep120
                    ldd       #1
                    lbsr      L28D5
                    leau      >ChsColor,PC
                    lbsr      L0FA2
                    lbsr      L1513
                    leau      >L263A,PC
                    stu       <U0018
                    lbra      L2AB9
ScnMemErr           leax      >L02C0,PC
                    ldy       #41
                    bra       ErrExit
NoTileErr           leax      >L0312,PC
                    ldy       #51
                    ldb       #228
                    bra       ErrExit
TilDatErr           leax      >L02E9,PC
                    ldy       #41
ErrExit             pshs      B,CC
                    lda       #2
                    os9       I$Write
                    ldd       #0
                    ldx       #130
                    os9       I$SetStt
                    lbsr      L044A
                    puls      B,CC
                    os9       F$Exit
L02C0               fcc       "Shanghai: Can't allocate screen memory."
                    fcb       $0D
                    fcb       $0A
L02E9               fcc       "Shanghai: Error opening tile data file."
                    fcb       $0D
                    fcb       $0A
L0312               fcc       "Shanghai: Specified file is NOT a tile data file."
                    fcb       $0D
                    fcb       $0A
SysDir              fcc       "/DD/SYS/"
TileFile            fcc       "Shanghai.til"
                    fcb       $0D
ChsColor            fcc       "Choose color set:"
                    fcb       $00
Copyright           fcc       "* 1986-87 Activision, Inc."
                    fcb       $00
Title1              fcc       "Programmed by"
                    fcb       $00
Title2              fcc       "Rick Adams"
                    fcb       $00
Title3              fcc       "Designed by"
                    fcb       $00
Title4              fcc       "Brodie Lockard"
                    fcb       $00
Title5              fcc       "OS-9 Port by Bill Nobel and Alan DeKok"
                    fcb       $00
                    fcb       $1B
                    leax      -1,U
                    pshs      B
                    ldd       #6948
                    std       >U00C2
                    ldd       #6944
                    std       >U00C4
                    lda       <ScTyp
                    sta       >U00C6
                    ldd       #0
                    std       >U00C7
                    ldd       <ScnWidth
                    stb       >U00C9
                    ldd       <ScnHeight
                    stb       >U00CA
                    lda       <Foreground
                    ldb       <Background
                    std       >U00CB
                    lda       <Border
                    sta       >U00CD
                    ldd       #6945
                    std       >U00CE
                    ldx       #194
                    ldy       #14
                    lda       #1
                    os9       I$Write
                    ldu       #2628
                    lbsr      L09E8
                    bsr       L044A
                    ldd       #0
                    ldx       #130
                    os9       I$SetStt
                    lda       #1
                    ldb       #137
                    ldx       #255
                    ldy       #0
                    os9       I$SetStt
                    puls      B
                    os9       F$Exit
L044A               ldx       <U0057
                    beq       L0453
                    ldb       #4
                    os9       F$DelRAM
L0453               rts
                    ldu       #2662
                    bra       L045C
                    ldu       #2646
L045C               stu       >U0A54
                    lbsr      L09E8
L0462               lbsr      L0F8F
L0465               lbsr      L0A7A
                    ldd       #2308
                    lbsr      L28D5
                    leau      >L0793,PC
                    lbsr      L0FA2
                    leau      >L265E,PC
                    lbra      L2AB4
                    tst       <U004A
                    beq       L0495
                    lbsr      L1AEE
                    bra       L0465
                    tst       <U004A
                    beq       L0498
                    lbsr      L1AEE
                    bra       L0465
                    clr       <U004A
L0490               lbsr      L0F8F
                    clr       <U0021
L0495               lbsr      J0F7A
L0498               tst       <U002D
                    beq       L0490
                    lbsr      L0A7A
                    lbsr      L0DFE
                    lbsr      J136D
                    ldx       #2678
                    os9       F$Time
                    tst       <U004A
                    lbgt      L07B8
                    lblt      L06F1
                    leau      >L26F2,PC
                    lbsr      L28B6
                    lbsr      L19BC
L04BF               ldb       #1
                    lbsr      L0E2B
                    leau      >L26F2,PC
                    lbsr      L2909
                    ldb       #1
                    lbsr      L107E
                    beq       L04BF
                    lbsr      L29E2
                    lbsr      J10C9
                    tstb
                    beq       L04BF
                    bsr       L04F2
                    tst       <U0002
                    bne       L0465
                    bra       L04BF
                    lbsr      L058A
                    bra       L04BF
                    lbsr      L05C1
                    bra       L04BF
                    lbsr      L067A
                    bra       L04BF
L04F2               clr       <U001A
                    clr       <U0002
                    lbsr      J14C5
                    bne       L0522
                    cmpu      <U002A
                    beq       L0558
                    cmpu      <U0027
                    bne       L050D
                    ldd       <U0008
                    lbeq      L067A
                    bra       L0558
L050D               ldy       <U0027
                    beq       L0518
                    ldy       <U002A
                    beq       L0546
                    rts
L0518               lbsr      L08A5
                    stu       <U0027
                    stb       <U0029
                    lbra      L09C7
L0522               lbsr      L1AEE
                    lbsr      L067A
                    leax      >L0535,PC
                    leay      >L053D,PC
                    clr       <U006A
                    lbra      J142E
L0535               fcc       "Tile is"
                    fcb       $00
L053D               fcc       "not free"
                    fcb       $00
L0546               ldy       <U0027
                    lbsr      J1A0D
                    bne       L0579
                    lbsr      L08A5
                    stu       <U002A
                    stb       <U002C
                    lbra      L09C7
L0558               ldu       <U0027
                    ldb       <U0029
                    lbsr      L09CE
                    ldu       <U002A
                    ldb       <U002C
                    lbsr      L09CE
                    lbsr      J136D
                    ldu       <U0018
                    lbsr      L28B6
                    lbsr      L08A5
                    lbsr      L19BC
                    inc       <U001A
                    lbra      J1587
L0579               lbsr      L1AEE
                    lbsr      L067A
                    leax      >L0666,PC
                    leay      >L0670,PC
                    lbra      J142E
L058A               ldd       <U0027
                    lbne      L067A
                    lda       <U002D
                    cmpa      #144
                    beq       L059A
                    bsr       L059B
                    bsr       L059B
L059A               rts
L059B               ldx       #2162
                    ldb       <U002D
                    clra
                    leax      D,X
                    ldb       ,X
                    ldu       #1154
                    lda       #7
                    pshs      B
                    decb
                    mul
                    leau      D,U
                    puls      B
                    com       ,U
                    lbsr      J173E
                    inc       <U002D
                    ldu       <U0018
                    lbsr      L28B6
                    lbra      J136D
L05C1               lbsr      L12BF
                    lbsr      L067E
                    clr       <U0006
                    ldd       <U0008
                    bne       L0632
L05CD               lda       <U0008
                    cmpa      #142
                    bhi       L063A
                    lda       <U0008
                    inca
                    sta       <U0009
L05D8               lda       <U0009
                    cmpa      #143
                    bhi       L0636
                    lda       <U0008
                    inca
                    sta       <U0029
                    deca
                    ldb       #7
                    mul
                    ldu       #1154
                    leau      D,U
                    stu       <U0027
                    lda       <U0009
                    inca
                    sta       <U002C
                    deca
                    ldb       #7
                    mul
                    ldu       #1154
                    leau      D,U
                    stu       <U002A
                    lbsr      J14C5
                    bne       L0632
                    ldu       <U0027
                    lbsr      J14C5
                    bne       L0632
                    ldu       <U0027
                    cmpu      <U002A
                    beq       L0632
                    ldy       <U002A
                    lbsr      J1A0D
                    bne       L0632
                    ldu       <U0027
                    ldb       <U0029
                    lbsr      J173E
                    ldu       <U002A
                    ldb       <U002C
                    lbsr      J173E
                    lbsr      J136D
                    ldu       <U0018
                    lbsr      L28B6
                    lbra      L115C
L0632               inc       <U0009
                    bra       L05D8
L0636               inc       <U0008
                    bra       L05CD
L063A               inc       <U0006
                    clra
                    clrb
                    std       <U0008
                    lbsr      L1AEE
                    lbsr      L19BC
                    leax      >L0654,PC
                    leay      >L065E,PC
                    lbsr      J142E
                    lbra      L115C
L0654               fcc       " No more "
                    fcb       $00
L065E               fcc       "  moves"
                    fcb       $00
L0666               fcc       "Tile does"
                    fcb       $00
L0670               fcc       "not match"
                    fcb       $00
L067A               clra
                    clrb
                    std       <U0008
L067E               ldd       <U0027
                    beq       L06A0
                    ldd       <U002A
                    beq       L0693
                    ldu       <U002A
                    ldb       <U002C
                    clr       <U002A
                    clr       <U002B
                    clr       <U002C
                    lbsr      J173E
L0693               ldu       <U0027
                    ldb       <U0029
                    clr       <U0027
                    clr       <U0028
                    clr       <U0029
                    lbsr      J173E
L06A0               rts
L06A1               fcc       "Tournament - Select time limit"
                    fcb       $00
                    lbsr      L0A7A
                    ldd       #1029
                    lbsr      L28D5
                    leau      >L06A1,PC
                    lbsr      L0FA2
                    leau      >L2841,PC
                    lbra      L2AB4
                    lda       #251
                    bra       L06DD
                    lda       #246
L06DD               sta       <U004A
                    lbsr      L12BF
                    leau      >L2841,PC
                    lbsr      L28B6
                    lbsr      L2ADB
                    clr       <U0017
                    lbra      L0490
L06F1               leau      >L2889,PC
                    lbsr      L28B6
                    lbsr      L19BC
                    lda       <U004A
                    nega
                    sta       <U0025
                    clr       <U0026
                    clr       <U0023
                    lbsr      J13C6
                    clr       <U0017
                    lda       #1
                    sta       <U001B
                    lbsr      L2BEA
L0710               ldd       <U0025
                    beq       L0767
                    ldb       <U001B
                    lbsr      L0E2B
                    leau      >L2889,PC
                    lbsr      L2909
                    lbsr      L13F7
                    tst       <U0005
                    bne       L0734
                    ldd       <U0025
                    cmpd      #256
                    bne       L0734
                    inc       <U0005
                    lbsr      L1513
L0734               tst       <U0004
                    bne       L0745
                    ldd       <U0025
                    cmpd      #10
                    bne       L0745
                    inc       <U0004
                    lbsr      L1513
L0745               ldb       <U001B
                    lbsr      L107E
                    beq       L0710
                    lbsr      L29E2
                    lbsr      J10C9
                    tstb
                    beq       L0710
                    lbsr      L04F2
                    tst       <U001A
                    beq       L0710
                    inc       <U0017
                    tst       <U0002
                    bne       L0767
                    lbsr      L2BEA
                    bra       L0710
L0767               lbsr      L067A
                    lbsr      L1513
                    lbsr      L1513
                    lbsr      L2CEB
                    lbsr      L2C19
                    lbne      L0495
                    clr       <U0021
                    lbra      L0462
                    lbsr      L058A
                    tst       <U0017
                    beq       L0710
                    dec       <U0017
                    lbsr      L2BEA
                    bra       L0710
                    lbsr      L067A
                    lbra      L0710
L0793               fcc       "Shanghai Main Menu:"
                    fcb       $00
L07A7               fcc       "Select a Dragon:"
                    fcb       $00
L07B8               leau      >L282F,PC
                    lbsr      L28B6
                    lbsr      L19BC
                    clr       <U0017
                    clr       <U0012
                    clr       <U0013
                    clr       <U0011
                    lda       <U004A
                    sta       <U0026
                    clr       <U0025
                    clr       <U0023
                    lbsr      J13C6
                    lbsr      L2BEA
                    lda       #1
                    sta       <U001B
                    leax      >L087F,PC
                    ldy       #0
                    lbsr      J142E
                    clr       <U0020
L07E9               ldd       <U0025
                    beq       L0815
                    ldb       <U001B
                    lbsr      L0E2B
                    leau      >L282F,PC
                    lbsr      L2909
                    lbsr      L13F7
                    ldb       <U001B
                    lbsr      L107E
                    beq       L07E9
                    lbsr      L29E2
                    lbsr      J10C9
                    tstb
                    beq       L07E9
                    lbsr      L04F2
                    tst       <U001A
                    beq       L07E9
                    bra       L0825
L0815               lbsr      L067A
                    lbsr      L1513
                    inc       <U0011
                    lda       <U0011
                    cmpa      #4
                    beq       L089F
                    bra       L082C
L0825               lbsr      L1513
                    clr       <U0011
                    inc       <U0017
L082C               ldx       #17
                    lda       <U001B
                    leax      A,X
                    ldb       <U0017
                    stb       ,X
                    lbsr      L2BEA
                    tst       <U002D
                    beq       L089F
                    lbsr      L12BF
                    lbsr      Sleep120
                    lbsr      L115C
                    lda       <U001B
                    ldb       #1
                    leax      >L087F,PC
                    ldy       #0
                    cmpa      #1
                    bne       L085C
                    leax      >L088A,PC
                    incb
L085C               stb       <U001B
                    lbsr      J142E
                    clr       <U0020
                    ldx       #17
                    ldb       <U001B
                    leax      B,X
                    lda       ,X
                    sta       <U0017
                    lbsr      L2BEA
                    lda       <U004A
                    sta       <U0026
                    clr       <U0025
                    clr       <U0023
                    lbsr      J13C6
                    lbra      L07E9
L087F               fcc       "Player one"
                    fcb       $00
L088A               fcc       "Player two"
                    fcb       $00
                    lbsr      L067A
                    lbra      L07E9
                    clr       <U0021
                    clr       <U002D
L089F               lbsr      J1659
                    lbra      L0462
L08A5               pshs      D
                    lbsr      L1B16
                    puls      PC,D
                    lbsr      L0A7A
                    ldd       #2306
                    lbsr      L28D5
                    leau      >L07A7,PC
                    lbsr      L0FA2
                    leau      >L272C,PC
                    lbra      L2AB4
                    ldb       #1
                    bra       L08E1
                    ldb       #2
                    bra       L08E1
                    ldb       #3
                    bra       L08E1
                    ldb       #4
                    bra       L08E1
                    ldb       #5
                    bra       L08E1
                    ldb       #6
                    bra       L08E1
                    ldb       #7
                    bra       L08E1
                    ldb       #8
L08E1               stb       <U0021
                    lbsr      L0F8F
                    lbra      L0465
L08E9               fcc       "Peek under tiles and forfeit game?"
                    fcb       $00
                    lbsr      L0A7A
                    tst       <U0006
                    bne       L0927
                    ldd       #518
                    lbsr      L28D5
                    leau      >L08E9,PC
                    lbsr      L0FA2
                    leau      >L27D0,PC
                    lbra      L2AB4
L0927               lbsr      L0A7A
                    lbsr      L0DFE
                    lbsr      J136D
                    leau      >L28A9,PC
                    lbsr      L28B6
                    lbsr      L19BC
L093A               ldb       #1
                    lbsr      L0E2B
                    leau      >L28A9,PC
                    lbsr      L2909
                    ldb       #1
                    lbsr      L107E
                    beq       L093A
                    lbsr      L29E2
                    lbsr      J10C9
                    tstb
                    beq       L093A
                    bsr       L09CE
                    lbsr      J136D
                    lbsr      L08A5
                    bra       L093A
                    clr       <U002D
                    lbra      L0465
                    lda       <U002D
                    cmpa      #144
                    beq       L093A
                    lbsr      L059B
                    bra       L093A
L0970               fcc       "CHALLENGE MATCH - Select time limit"
                    fcb       $00
                    lbsr      L0A7A
                    ldd       #518
                    lbsr      L28D5
                    leau      >L0970,PC
                    lbsr      L0FA2
                    leau      >L27E4,PC
                    lbra      L2AB4
                    lda       #10
                    sta       <U004A
                    lbra      L0490
                    lda       #20
                    sta       <U004A
                    lbra      L0490
                    lda       #30
                    sta       <U004A
                    lbra      L0490
                    lda       #60
                    sta       <U004A
                    lbra      L0490
L09C7               pshs      U,Y,X,D
                    lbsr      J173E
                    puls      PC,U,Y,X,D
L09CE               dec       <U002D
                    pshs      B
                    ldx       #2162
                    ldb       <U002D
                    clra
                    leax      D,X
                    puls      B
                    stb       ,X
                    com       ,U
                    lbsr      J173E
                    clra
                    clrb
                    std       <U0008
                    rts
L09E8               leas      -4,S
                    leax      ,S
                    ldd       #6961
                    std       ,X
                    clr       ,-S
L09F3               ldb       ,U+
                    lda       ,S
                    std       U0002,X
                    cmpa      #14
                    bne       L0A01
                    stb       <U005D
                    bra       L0A07
L0A01               cmpa      #15
                    bne       L0A07
                    stb       <U005C
L0A07               clra
                    ldy       #4
                    os9       I$Write
                    inc       ,S
                    ldb       ,S
                    cmpb      #16
                    bne       L09F3
                    leas      5,S
                    rts
L0A1A               fcb       $47
                    fcb       $16
                    fcb       $21
                    fcb       $20
                    fcb       $1F
                    fcb       $1E
                    fcb       $1D
                    fcb       $1C
                    fcb       $1B
                    fcb       $1A
                    fcb       $19
                    fcb       $18
                    fcb       $17
                    fcb       $16
                    fcb       $15
                    fcb       $14
                    fcb       $13
                    fcb       $12
                    fcb       $11
                    fcb       $10
                    fcb       $0F
                    fcb       $0E
                    fcb       $01
                    fcb       $00
                    fcb       $CC
                    fcb       $CC
                    fcb       $CC
                    fcb       $CC
                    fcb       $CC
                    fcb       $CC
                    fcb       $CC
                    fcb       $CC
                    fcb       $CC
                    fcb       $CC
                    fcb       $B0
                    fcb       $00
                    fcb       $CC
                    fcb       $FF
                    fcb       $FF
                    fcb       $FF
                    fcb       $FF
                    fcb       $FF
                    fcb       $FF
                    fcb       $FF
                    fcb       $FF
                    fcb       $CC
                    fcb       $B0
                    fcb       $00
L0A4A               fcb       $17
                    fcc       /"! /
                    fcb       $1F
                    fcb       $1E
                    fcb       $1D
                    fcb       $1C
                    fcb       $1B
                    fcb       $1A
                    fcb       $19
                    fcb       $18
                    fcb       $17
                    fcb       $16
                    fcb       $15
                    fcb       $14
                    fcb       $13
                    fcb       $12
                    fcb       $11
                    fcb       $10
                    fcb       $0F
                    fcb       $0E
                    fcb       $0D
                    fcb       $0C
                    fcb       $BB
                    fcb       $BB
                    fcb       $BB
                    fcb       $BB
                    fcb       $BB
                    fcb       $BB
                    fcb       $BB
                    fcb       $BB
                    fcb       $BB
                    fcb       $BB
                    fcb       $B0
                    fcb       $00
                    fcb       $DD
                    fcb       $DD
                    fcb       $DD
                    fcb       $DD
                    fcb       $DD
                    fcb       $DD
                    fcb       $DD
                    fcb       $DD
                    fcb       $DD
                    fcb       $DD
                    fcb       $B0
                    fcb       $00
L0A7A               clr       <U0007
                    clr       <U0020
L0A7E               tst       <U0000
                    beq       L0A86
                    clra
                    clrb
                    bra       L0A89
L0A86               ldd       #-26215
L0A89               ldy       #32000
                    ldx       <U0053
L0A8F               std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    leay      <-$20,Y
                    bne       L0A8F
                    rts
SetScrn             ldd       #SS.ScTyp
                    os9       I$GetStt            Get the screen type
                    sta       <ScTyp              Store the screen type
                    clra
                    ldb       #SS.ScSiz
                    os9       I$GetStt            Get the screen size
                    stx       <ScnWidth           Store the screen width
                    sty       <ScnHeight          Store the screen height
                    ldb       #SS.FBRgs
                    os9       I$GetStt            Get the foreground, background, and border palette registers
                    sta       <Foreground         Store the foreground palette register
                    stb       <Background         Store the background palette register
                    tfr       X,D                 Put the border in D
                    stb       <Border             Store the border palette register
                    ldd       #SS.Palet
                    ldx       #2628
                    os9       I$GetStt            Get the palette information
                    lda       <ScTyp              Get the screen type
                    cmpa      #8                  Is it 320x192 16 color?
                    beq       L0B4E               Yes, keep going
L0AE4               leax      >L0036,PC
                    ldy       #16
                    lda       #1
                    os9       I$Write
                    bcc       L0B60               Keep going if successful
                    leax      >AllocErr,PC
                    ldy       #62
                    lda       #2
                    os9       I$Write             Write the error message
                    ldd       #SS.Opt
                    ldx       #130
                    os9       I$SetStt            Restore the original options
                    lbsr      L044A
                    clrb
                    os9       F$Exit              Exit
AllocErr            fcc       "Shanghai: There was an error allocating the graphics screen."
                    fcb       $0D
                    fcb       $0A
L0B4E               ldx       <ScnWidth
                    ldy       <ScnHeight
                    cmpx      #40                 Is it 40 chars wide
                    bne       L0AE4
                    cmpy      #24
                    bcc       L0B60
                    bra       L0AE4
L0B60               ldb       #143
                    clra
                    os9       I$GetStt
                    bcs       L0B7D
L0B68               clra
                    std       <U0055
                    tfr       D,X
                    ldb       #4
                    os9       F$MapBlk
                    stu       <U0053
                    os9       F$ID
                    ldu       #2646
                    lbra      L09E8
L0B7D               lda       #1
                    ldb       #14
                    ldx       #194
                    os9       I$GetStt
                    ldx       #98
                    ldy       #194
                    lbsr      L0C66
                    ldx       #194
                    lda       #1
                    os9       F$GPrDsc
                    ldy       #194
                    leax      <$40,X
                    ldb       #16
L0BA2               lda       ,X+
                    sta       ,Y+
                    decb
                    bne       L0BA2
                    leas      -2,S
                    ldd       #194
                    leau      ,S
                    ldy       #2
                    ldx       #128
                    os9       F$CpyMem
                    ldd       #194
                    ldu       #210
                    ldy       #288
                    ldx       ,S++
                    os9       F$CpyMem
                    clrb
                    pshs      B
                    ldx       #210
                    pshs      X
L0BD1               ldx       ,S
                    lda       U0008,X
                    beq       L0C0E
                    leas      -7,S
                    ldd       #194
                    leau      ,S
                    ldx       7,S
                    ldx       U0004,X
                    leax      U0004,X
                    ldy       #2
                    os9       F$CpyMem
                    ldd       ,S
                    ldx       7,S
                    ldx       U0004,X
                    leax      D,X
                    ldd       #194
                    leau      ,S
                    ldy       #5
                    os9       F$CpyMem
                    leax      ,S
                    leay      ,S
                    bsr       L0C66
                    ldx       #98
                    bsr       L0C78
                    bcc       L0C24
                    leas      7,S
L0C0E               ldx       ,S
                    leax      U0009,X
                    stx       ,S
                    ldb       2,S
                    incb
                    stb       2,S
                    cmpb      #32
                    bne       L0BD1
                    leas      3,S
                    ldb       #221
                    os9       F$Exit
L0C24               leas      7,S
                    ldd       #194
                    ldx       ,S++
                    ldx       U0002,X
                    leax      <$35,X
                    ldy       #1
                    leau      ,S
                    os9       F$CpyMem
                    lda       ,S+
                    ldb       #64
                    mul
                    ldx       #4736
                    leax      D,X
                    ldd       #194
                    ldy       #64
                    ldu       #210
                    os9       F$CpyMem
                    ldd       #194
                    ldy       #32
                    ldx       >U00D2
                    ldu       #210
                    os9       F$CpyMem
                    ldb       >U00D3
                    lbra      L0B68
L0C66               pshs      Y,X
L0C68               lda       ,Y+
                    bmi       L0C70
                    sta       ,X+
                    bra       L0C68
L0C70               anda      #127
                    sta       ,X+
                    clr       ,X
                    puls      PC,Y,X
L0C78               pshs      Y,X
L0C7A               lda       ,X+
                    beq       L0C85
                    cmpa      ,Y+
                    beq       L0C7A
                    coma
                    puls      PC,Y,X
L0C85               clra
                    puls      PC,Y,X
L0C88               pshs      U,X,B
                    pshs      B
                    leax      -1,X
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    andb      #15
                    decb
                    leau      >L0D4C,PC
                    aslb
                    leau      B,U
                    ldd       ,U
                    ldu       #2692
                    leau      D,U
                    puls      B
                    andb      #15
                    decb
                    lda       #231
                    mul
                    leau      D,U
                    tfr       X,D
                    pshs      B
                    lsra
                    rorb
                    tfr       D,X
                    lbsr      L0E19
                    leax      >X0140,X
                    puls      B
                    andb      #1
                    lda       #255
                    mul
                    comb
                    incb
                    lda       #21
                    pshs      A
L0CC9               dec       ,S
                    blt       L0CEF
                    lda       #10
                    pshs      X,A
                    tstb
                    bne       L0CDD
                    lda       ,U
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       L0D2F
                    fcb       $8C
L0CDD               leax      U0001,X
L0CDF               bsr       L0CFF
                    dec       ,S
                    bne       L0CDF
                    puls      X,A
                    leax      >X00A0,X
                    leau      U0001,U
                    bra       L0CC9
L0CEF               puls      A
                    puls      PC,U,X,B
L0CF3               ldd       ,U+
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    bra       L0D06
L0CFF               pshs      D
                    tstb
                    beq       L0CF3
                    lda       ,U+
L0D06               cmpa      #221
                    bne       L0D0E
                    leax      U0001,X
                    puls      PC,D
L0D0E               bsr       L0D12
                    puls      PC,D
L0D12               pshs      A
                    lda       ,X
                    anda      #240
                    pshs      A
                    lda       1,S
                    anda      #240
                    cmpa      #208
                    bne       L0D23
                    fcb       $8C
L0D23               sta       ,S
                    lda       ,X
                    anda      #15
                    ora       ,S+
                    sta       ,X
                    puls      A
L0D2F               pshs      A
                    lda       ,X
                    anda      #15
                    pshs      A
                    lda       1,S
                    anda      #15
                    cmpa      #13
                    bne       L0D40
                    fcb       $8C
L0D40               sta       ,S
                    lda       ,X
                    anda      #240
                    ora       ,S+
                    sta       ,X+
                    puls      PC,A
L0D4C               fcb       $00
                    fcb       $00
                    fcb       $02
                    fcb       $B5
                    fcb       $06
                    fcb       $51
                    fcb       $09
                    fcb       $ED
                    fcb       $0D
                    fcb       $89
                    fcb       $15
                    fcb       $A8
                    fcb       $1D
                    fcb       $C7
L0D5A               pshs      U,X
                    tfr       X,D
                    andb      #1
                    bne       L0DA3
                    tfr       X,D
                    lsra
                    rorb
                    tfr       D,X
                    lbsr      L0E19
                    lda       #24
                    pshs      U,A
L0D6F               dec       ,S
                    blt       L0D9F
                    tfr       X,Y
                    ldu       1,S
                    ldb       ,U+
                    stu       1,S
                    leau      B,U
                    ldd       ,U++
                    std       ,Y++
                    ldd       ,U++
                    std       ,Y++
                    ldd       ,U++
                    std       ,Y++
                    ldd       ,U++
                    std       ,Y++
                    ldd       ,U++
                    std       ,Y++
                    lda       ,Y
                    anda      #15
                    ora       ,U+
                    sta       ,Y+
                    leax      >X00A0,X
                    bra       L0D6F
L0D9F               puls      U,A
                    puls      PC,U,X
L0DA3               tfr       X,D
                    lsra
                    rorb
                    tfr       D,X
                    bsr       L0E19
                    lda       #24
                    pshs      U,A
L0DAF               dec       ,S
                    blt       L0DE9
                    ldu       1,S
                    ldb       ,U+
                    stu       1,S
                    leau      B,U
                    tfr       X,Y
                    lda       ,Y
                    anda      #240
                    sta       ,Y
                    lda       ,U
                    anda      #240
                    lsra
                    lsra
                    lsra
                    lsra
                    ora       ,Y
                    sta       ,Y+
                    bsr       L0DED
                    bsr       L0DED
                    bsr       L0DED
                    bsr       L0DED
                    bsr       L0DED
                    bsr       L0DED
                    bsr       L0DED
                    bsr       L0DED
                    bsr       L0DED
                    bsr       L0DED
                    leax      >X00A0,X
                    bra       L0DAF
L0DE9               puls      U,A
                    puls      PC,U,X
L0DED               lda       ,U+
                    ldb       ,U
                    andb      #240
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    sta       ,Y+
                    rts
L0DFE               lbsr      L19BC
                    leax      >L1F62,PC
L0E05               lda       ,X+
                    lbeq      L19C9
                    deca
                    ldb       #7
                    mul
                    ldu       #1154
                    leau      D,U
                    lbsr      L1830
                    bra       L0E05
L0E19               pshs      A
                    leax      >$4002,X
                    lda       <U0021
                    cmpa      #9
                    bne       L0E29
                    leax      >X0280,X
L0E29               puls      PC,A
L0E2B               pshs      U,Y,X,B
                    lbsr      L115C
L0E30               pshs      B
                    ldx       #2678
                    os9       F$Time
                    puls      B
                    clra
                    cmpb      #1
                    beq       L0E41
                    ldb       #2
L0E41               tfr       D,Y
                    ldb       #137
                    ldx       #98
                    os9       I$GetStt
                    tst       ,X
                    bne       L0E63
                    ldx       #2684
                    os9       F$Time
                    ldx       #2678
                    os9       F$Time
                    ldx       #20
                    os9       F$Sleep
                    bra       L0E30
L0E63               inc       <U0024
                    lda       <U0024
                    anda      #16
                    beq       L0E75
                    lda       <U005C
                    cmpa      <U0061
                    beq       L0E80
                    sta       <U0061
                    bra       L0E7D
L0E75               lda       <U005D
                    cmpa      <U0061
                    beq       L0E80
                    sta       <U0061
L0E7D               sta       >-67
L0E80               pshs      X
                    ldx       #2682
                    ldd       ,X++
                    cmpd      U0004,X
                    beq       L0EB4
                    os9       F$Time
                    ldx       #2678
                    os9       F$Time
                    dec       <U0026
                    bge       L0EA7
                    lda       #59
                    sta       <U0026
                    tst       <U0025
                    beq       L0EA5
                    dec       <U0025
                    bra       L0EA7
L0EA5               clr       <U0026
L0EA7               tst       <U0020
                    beq       L0EB4
                    dec       <U0020
                    lda       <U0020
                    bne       L0EB4
                    lbsr      L1461
L0EB4               puls      X
                    ldd       <$18,X
                    lsra
                    rorb
                    std       <$18,X
                    cmpd      <U0037
                    bne       L0ECA
                    ldd       <$1A,X
                    cmpb      <U0039
                    beq       L0EE9
L0ECA               lbsr      L12BF
                    ldd       <$18,X
                    cmpd      #310
                    bls       L0ED9
                    ldd       #310
L0ED9               std       <U0037
                    ldd       <$1A,X
                    cmpb      #190
                    bls       L0EE4
                    ldb       #190
L0EE4               stb       <U0039
                    lbsr      L115C
L0EE9               puls      PC,U,Y,X,B
L0EEB               pshs      B
L0EED               lda       <U0033
                    ldb       #5
                    mul
                    pshs      D
                    lda       <U0034
                    ldb       #8
                    mul
                    addd      ,S++
                    exg       A,B
                    clrb
                    pshs      D
                    lda       <U0034
                    ldb       #5
                    mul
                    addd      ,S++
                    addd      #14449
                    std       <U0033
                    cmpa      ,S
                    bhi       L0EED
                    tsta
                    beq       L0EED
                    puls      B
                    exg       A,B
                    clra
                    rts
L0F19               leax      >L1FBA,PC
                    lda       #144
                    decb
                    mul
                    leax      D,X
                    leay      >L1C02,PC
                    ldu       #1154
                    lda       #144
                    sta       <U002D
                    pshs      A
L0F30               dec       ,S
                    lda       ,S
                    cmpa      #255
                    beq       L0F4A
                    lda       ,X+
                    sta       ,U+
                    ldd       ,Y++
                    std       ,U++
                    ldd       ,Y++
                    std       ,U++
                    ldd       ,Y++
                    std       ,U++
                    bra       L0F30
L0F4A               puls      PC,A
L0F4C               lda       #144
                    pshs      A
L0F50               dec       ,S
                    lda       ,S
                    cmpa      #255
                    beq       L0F78
                    ldb       #144
                    bsr       L0EEB
                    decb
                    lda       #7
                    mul
                    ldx       #1154
                    tfr       X,Y
                    leax      D,X
                    ldb       ,S
                    lda       #7
                    mul
                    leay      D,Y
                    lda       ,X
                    ldb       ,Y
                    sta       ,Y
                    stb       ,X
                    bra       L0F50
L0F78               puls      PC,A

J0F7A               clr       <U0006
                    ldx       #1154
                    lda       #144
                    sta       <U002D
L0F83               tst       ,X
                    bgt       L0F89
                    com       ,X
L0F89               leax      U0007,X
                    deca
                    bne       L0F83
                    rts

L0F8F               ldb       #144
                    stb       <U002D
                    clr       <U0006
                    ldb       <U0021
                    lbne      L0F19
                    ldb       #1
                    lbsr      L0F19
                    bra       L0F4C
L0FA2               ldb       ,U+
                    beq       L0FAA
                    bsr       L0FDC
                    bra       L0FA2
L0FAA               clr       <U0041
                    rts
ASCII               fcc       " ,*?#'-.0123456789:@ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                    fcb       $00
L0FDC               pshs      U,Y,X,D
                    cmpb      #97
                    bcs       L0FE4
                    subb      #32
L0FE4               leau      >L24CA,PC
                    leay      >ASCII,PC
L0FEC               tst       ,Y
                    beq       L0FF8
                    cmpb      ,Y+
                    beq       L0FFC
                    leau      U0008,U
                    bra       L0FEC
L0FF8               leau      >L24CA,PC
L0FFC               lda       #8
                    pshs      A
L1000               dec       ,S
                    blt       L100E
                    lda       ,U+
                    bsr       L1015
                    leax      >X00A0,X
                    bra       L1000
L100E               puls      A
                    puls      U,Y,X,D
                    leax      U0004,X
                    rts
L1015               pshs      A
                    lda       #255
                    sta       <U0030
                    tst       <U000A
                    beq       L1022
                    clra
                    sta       <U0030
L1022               tst       <U0041
                    beq       L102A
                    lda       #221
                    sta       <U0030
L102A               puls      A
                    ldb       #153
                    tst       <U000A
                    beq       L1034
                    ldb       #17
L1034               tst       <U0000
                    beq       L1039
                    clrb
L1039               stb       ,X
                    stb       U0001,X
                    stb       U0002,X
                    stb       U0003,X
                    ldb       #255
                    pshs      A
L1045               lda       ,S
                    beq       L107C
                    incb
                    asla
                    sta       ,S
                    bcc       L1045
                    tfr       X,Y
                    tfr       B,A
                    lsra
                    leay      A,Y
                    tfr       B,A
                    anda      #1
                    beq       L106C
                    lda       ,Y
                    anda      #240
                    pshs      A
                    lda       <U0030
                    anda      #15
                    ora       ,S+
                    sta       ,Y
                    bra       L1045
L106C               lda       ,Y
                    anda      #15
                    pshs      A
                    lda       <U0030
                    anda      #240
                    ora       ,S+
                    sta       ,Y
                    bra       L1045
L107C               puls      PC,A
L107E               pshs      Y,X
                    ldu       #53
                    clra
                    cmpb      #1
                    beq       L108C
                    ldb       #2
                    leau      U0001,U
L108C               tfr       D,Y
                    ldx       #98
                    ldb       #137
                    os9       I$GetStt
                    ldb       ,X
                    lda       U0008,X
                    puls      Y,X
                    tstb
                    beq       L10AB
                    tsta
                    beq       L10AB
                    tst       ,U
                    bne       L10AB
                    inc       ,U
                    ldb       #1
                    rts
L10AB               clr       ,U
                    clrb
                    rts

J10AF               pshs      Y,D
                    tfr       D,Y
                    clr       U0002,U
                    lsra
                    rorb
L10B7               subd      #160
                    blt       L10C4
                    inc       U0002,U
                    leay      >-320,Y
                    bra       L10B7
L10C4               sty       ,U
                    puls      PC,Y,D

J10C9               lda       #144
                    pshs      A
L10CD               dec       ,S
                    lda       ,S
                    ldb       #7
                    mul
                    ldx       #1154
                    leax      D,X
                    tst       ,X
                    ble       L1152
                    tst       U0005,X
                    beq       L10F0
                    lda       U0005,X
                    deca
                    ldb       #7
                    ldu       #1154
                    mul
                    leau      D,U
                    tst       ,U
                    bgt       L1152
L10F0               clra
                    ldb       ,S
                    incb
                    tfr       D,Y
                    ldd       U0001,X
                    exg       D,X
                    lbsr      L0E19
                    std       <U0003
                    lda       ,S
                    cmpa      #143
                    bcs       L1109
                    leax      >$FEC1,X
L1109               cmpa      #139
                    bcs       L1111
                    leax      >$FEC1,X
L1111               cmpa      #123
                    bcs       L1119
                    leax      >$FEC1,X
L1119               cmpa      #87
                    bcs       L1121
                    leax      >$FEC1,X
L1121               ldd       <U0003
                    exg       D,X
                    subd      <U0053
                    ldu       #58
                    lbsr      J10AF
                    lda       <U0039
                    cmpa      <U003C
                    bcs       L1152
                    lda       <U003C
                    adda      #23
                    cmpa      <U0039
                    bcs       L1152
                    ldd       <U0037
                    cmpd      <U003A
                    bcs       L1152
                    ldd       <U003A
                    addd      #20
                    cmpd      <U0037
                    bcs       L1152
                    tfr       X,U
                    puls      B
                    incb
                    rts
L1152               tst       ,S
                    lbne      L10CD
                    puls      B
                    clrb
                    rts
L115C               pshs      U,Y,X,D
                    tst       <U0007
                    lbne      L12BD
                    lda       #1
                    sta       <U0007
                    lbsr      L12EB
                    pshs      X,B
                    ldy       #2566
                    stx       ,Y++
                    lda       #10
                    pshs      A
L1177               dec       ,S
                    blt       L118D
                    ldd       ,X++
                    std       ,Y++
                    ldd       ,X++
                    std       ,Y++
                    ldd       ,X++
                    std       ,Y++
                    leax      >X009A,X
                    bra       L1177
L118D               puls      A
                    puls      X,B
                    andb      #1
                    lbeq      L1231
                    lda       ,X
                    ora       #15
                    sta       ,X
                    ldd       #-1
                    std       U0001,X
                    sta       U0003,X
                    ldb       #160
                    abx
                    lda       ,X
                    ora       #15
                    sta       ,X
                    clr       U0001,X
                    clr       U0002,X
                    lda       U0003,X
                    ora       #240
                    sta       U0003,X
                    abx
                    lda       ,X
                    ora       #15
                    sta       ,X
                    clr       U0001,X
                    lda       #15
                    sta       U0002,X
                    abx
                    lda       ,X
                    ora       #15
                    sta       ,X
                    clr       U0001,X
                    clr       U0002,X
                    lda       U0003,X
                    ora       #240
                    sta       U0003,X
                    abx
                    lda       ,X
                    ora       #15
                    sta       ,X
                    lda       #15
                    sta       U0001,X
                    clr       U0002,X
                    sta       U0003,X
                    abx
                    lda       ,X
                    ora       #15
                    sta       ,X
                    lda       U0001,X
                    ora       #240
                    sta       U0001,X
                    lda       #240
                    sta       U0002,X
                    clr       U0003,X
                    lda       U0004,X
                    ora       #240
                    sta       U0004,X
                    abx
                    lda       ,X
                    ora       #15
                    sta       ,X
                    lda       U0002,X
                    ora       #15
                    sta       U0002,X
                    clr       U0003,X
                    lda       #15
                    sta       U0004,X
                    abx
                    lda       #240
                    sta       U0003,X
                    clr       U0004,X
                    lda       U0005,X
                    ora       #240
                    sta       U0005,X
                    abx
                    lda       U0003,X
                    ora       #15
                    sta       U0003,X
                    lda       #15
                    sta       U0004,X
                    abx
                    lda       U0004,X
                    ora       #240
                    sta       U0004,X
                    puls      PC,U,Y,X,D
L1231               ldd       #-1
                    std       ,X
                    sta       U0002,X
                    lda       U0003,X
                    ora       #240
                    sta       U0003,X
                    leax      >X00A0,X
                    ldd       #-4081
                    sta       ,X
                    clr       U0001,X
                    stb       U0002,X
                    leax      >X00A0,X
                    sta       ,X
                    clr       U0001,X
                    lda       U0002,X
                    ora       #240
                    sta       U0002,X
                    leax      >X00A0,X
                    ldd       #-4081
                    sta       ,X
                    clr       U0001,X
                    stb       U0002,X
                    leax      >X00A0,X
                    sta       ,X
                    sta       U0001,X
                    clr       U0002,X
                    lda       U0003,X
                    ora       #240
                    sta       U0003,X
                    leax      >X00A0,X
                    ldd       #-241
                    sta       ,X
                    clr       U0002,X
                    stb       U0003,X
                    lda       U0001,X
                    ora       #15
                    sta       U0001,X
                    ldb       #160
                    abx
                    lda       #240
                    sta       U0002,X
                    lda       ,X
                    ora       #240
                    sta       ,X
                    clr       U0003,X
                    lda       U0004,X
                    ora       #240
                    sta       U0004,X
                    abx
                    lda       U0002,X
                    ora       #15
                    sta       U0002,X
                    clr       U0003,X
                    lda       #15
                    sta       U0004,X
                    abx
                    lda       #240
                    sta       U0003,X
                    lda       U0004,X
                    ora       #240
                    sta       U0004,X
                    abx
                    lda       U0003,X
                    ora       #15
                    sta       U0003,X
L12BD               puls      PC,U,Y,X,D
L12BF               pshs      U,Y,X,D
                    tst       <U0007
                    beq       L12E9
                    clr       <U0007
                    ldy       #2566
                    ldx       ,Y++
                    lda       #10
                    pshs      A
L12D1               dec       ,S
                    blt       L12E7
                    ldd       ,Y++
                    std       ,X++
                    ldd       ,Y++
                    std       ,X++
                    ldd       ,Y++
                    std       ,X++
                    leax      >X009A,X
                    bra       L12D1
L12E7               puls      A
L12E9               puls      PC,U,Y,X,D
L12EB               ldb       <U0039
                    ldx       <U0053
                    lda       #160
                    mul
                    leax      D,X
                    ldd       <U0037
                    pshs      B
                    lsra
                    rorb
                    leax      D,X
                    puls      PC,B

J12FE               pshs      U,Y,X,D
                    bsr       L1304
                    puls      PC,U,Y,X,D
L1304               pshs      B
                    ldy       #0
                    lda       #48
                    ldb       ,S
L130E               subb      #100
                    bcs       L1317
                    stb       ,S
                    inca
                    bra       L130E
L1317               cmpa      #48
                    beq       L1324
                    exg       B,A
                    lbsr      L0FDC
                    exg       B,A
                    leay      1,Y
L1324               lda       #48
                    ldb       ,S
L1328               subb      #10
                    blt       L1331
                    stb       ,S
                    inca
                    bra       L1328
L1331               leay      ,Y
                    bne       L1339
                    cmpa      #48
                    beq       L1342
L1339               exg       B,A
                    lbsr      L0FDC
                    exg       B,A
                    leay      1,Y
L1342               lda       #48
                    adda      ,S
                    exg       B,A
                    lbsr      L0FDC
                    exg       B,A
                    leay      1,Y
                    tfr       Y,D
                    cmpb      #3
                    beq       L136B
                    pshs      B
                    ldb       #32
                    lbsr      L0FDC
                    puls      B
                    cmpb      #1
                    bne       L136B
                    pshs      B
                    ldb       #32
                    lbsr      L0FDC
                    puls      B
L136B               puls      PC,B

J136D               pshs      U,Y,X,D
                    ldd       #530
                    lbsr      L28D5
                    leax      >X0280,X
                    leau      >Tiles,PC
                    lbsr      L0FA2
                    ldd       #787
                    lbsr      L28D5
                    leax      >X0320,X
                    ldb       <U002D
                    clra
                    lbsr      J12FE
                    puls      PC,U,Y,X,D
Tiles               fcc       "Tiles"
                    fcb       $00

Intercept           stb       <U005B
                    rti

J139B               pshs      B
                    lda       #48
                    ldb       ,S
L13A1               subb      #10
                    blt       L13AA
                    stb       ,S
                    inca
                    bra       L13A1
L13AA               leay      ,Y
                    beq       L13B2
                    cmpa      #48
                    beq       L13B9
L13B2               exg       B,A
                    lbsr      L0FDC
                    exg       B,A
L13B9               lda       #48
                    adda      ,S
                    exg       B,A
                    lbsr      L0FDC
                    exg       B,A
                    puls      PC,B

J13C6               pshs      U,Y,X,D
                    ldd       #16
                    lbsr      L28D5
                    leax      >$FD82,X
                    tst       <U004A
                    beq       L13EB
                    leau      >Secs,PC
                    tst       <U004A
                    bgt       L13E2
                    leau      >Mins,PC
L13E2               lbsr      L0FA2
                    lda       #255
                    sta       <U0022
                    bsr       L13F7
L13EB               puls      PC,U,Y,X,D
Mins                fcc       "Mins"
                    fcb       $00
Secs                fcc       "Secs"
                    fcb       $00
L13F7               pshs      U,Y,X,D
                    ldb       <U0026
                    cmpb      <U0022
                    beq       L142C
                    stb       <U0022
                    lbsr      L12BF
                    ldd       #273
                    lbsr      L28D5
                    leax      >$FE22,X
                    ldy       #0
                    ldb       <U0026
                    tst       <U004A
                    bge       L1426
                    ldb       <U0025
                    leax      -6,X
                    lbsr      J139B
                    ldb       #58
                    lbsr      L0FDC
                    ldb       <U0026
L1426               lbsr      J139B
                    lbsr      L115C
L142C               puls      PC,U,Y,X,D

J142E               lda       #4
                    sta       <U0020
                    pshs      Y
                    pshs      X
                    bsr       L1461
                    ldd       #7699
                    lbsr      L28D5
                    leax      >$FD80,X
                    ldu       ,S++
                    lbsr      L0FA2
                    ldd       #7700
                    lbsr      L28D5
                    leax      >$FD80,X
                    ldu       ,S++
                    pshs      U
                    puls      D
                    beq       L145C
                    lbsr      L0FA2
L145C               lda       #4
                    sta       <U0020
                    rts
L1461               lda       <U0007
                    pshs      A
                    beq       L146A
                    lbsr      L12BF
L146A               ldd       #7699
                    lbsr      L28D5
                    leax      >$FD80,X
                    bsr       L148B
                    ldd       #7700
                    lbsr      L28D5
                    leax      >$FD80,X
                    bsr       L148B
                    puls      A
                    tsta
                    beq       L148A
                    lbsr      L115C
L148A               rts
L148B               lda       #8
                    pshs      A
                    ldd       #-26215
L1492               dec       ,S
                    blt       L14C3
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    std       ,X++
                    leax      <$78,X
                    bra       L1492
L14C3               puls      PC,A

J14C5               pshs      B
                    pshs      U
                    tst       ,U
                    ble       L1504
                    ldb       U0005,U
                    beq       L14DE
                    lda       #7
                    decb
                    mul
                    ldu       #1154
                    leau      D,U
                    tst       ,U
                    bgt       L1504
L14DE               ldu       ,S
                    ldb       U0003,U
                    beq       L150C
                    lda       #7
                    decb
                    mul
                    ldu       #1154
                    leau      D,U
                    tst       ,U
                    ble       L150C
                    ldu       ,S
                    ldb       U0004,U
                    beq       L150C
                    lda       #7
                    decb
                    mul
                    ldu       #1154
                    leau      D,U
                    tst       ,U
                    ble       L150C
L1504               puls      U
                    puls      B
                    lda       #1
                    tsta
                    rts
L150C               puls      U
                    puls      B
                    clra
                    tsta
                    rts
L1513               pshs      D,CC
                    orcc      #80
                    lda       >-221
                    pshs      A
                    ora       #8
                    sta       >-221
                    lda       >-255
                    pshs      A
                    anda      #247
                    sta       >-255
                    lda       >-253
                    pshs      A
                    anda      #247
                    sta       >-253
                    clrb
L1536               leax      >L1568,PC
                    lda       #32
                    pshs      A
L153E               dec       ,S
                    blt       L1552
                    lda       ,X+
                    pshs      B
                    mul
                    asla
                    asla
                    anda      #252
                    sta       >-224
                    puls      B
                    bra       L153E
L1552               puls      A
                    decb
                    bne       L1536
                    puls      A
                    sta       >-253
                    puls      A
                    sta       >-255
                    puls      A
                    sta       >-221
                    puls      PC,D,CC
L1568               fcb       $20
                    fcb       $26
                    fcb       $2C
                    fcb       $31
                    fcb       $36
                    fcb       $3A
                    fcb       $3F
                    fcb       $3F
                    fcb       $3F
                    fcb       $3D
                    fcb       $3A
                    fcb       $36
                    fcb       $31
                    fcb       $2C
                    fcb       $26
                    fcb       $20
                    fcb       $19
                    fcb       $13
                    fcb       $0E
                    fcb       $09
                    fcb       $05
                    fcb       $02
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $02
                    fcb       $05
                    fcb       $09
                    fcb       $0E
                    fcb       $13
                    fcb       $19

* Guessing this is where a code block starts
J1587               clr       <U0002
                    tst       <U002D
                    bne       L15FF
                    inc       <U0002
                    lbsr      J136D
                    lda       <U0017
                    pshs      A
                    inc       <U0017
                    lbsr      L2BEA
                    lbsr      L12BF
                    lbsr      L1513
                    bsr       Sleep120
                    inc       <U0000
                    leau      >L30B2,PC
                    lbsr      L09E8
                    lbsr      L0A7A
                    leau      >L30D2,PC
                    lbsr      L1B86
                    ldd       #1294
                    lbsr      L28D5
                    leau      >ConqDrag,PC
                    lbsr      L0FA2
                    bsr       L1600
                    clr       <U0000
                    lbsr      L0A7A
                    lbsr      L115C
                    puls      A
                    sta       <U0017
                    ldu       >U0A54
                    lbra      L09E8
ConqDrag            fcc       "You have conquered the dragon"
                    fcb       $00
Sleep120            ldx       #120
Sleep               os9       F$Sleep
                    leax      ,X
                    bne       Sleep
L15FF               rts
L1600               lbsr      L1B3F
                    clra
                    pshs      A
L1606               bsr       L1640
                    dec       ,S
                    beq       L1635
                    clrb
                    pshs      B
L160F               dec       ,S
                    beq       L1631
                    leau      >L0465,PC
                    lda       ,S
                    bne       L161C
                    inca
L161C               lda       A,U
                    ldb       1,S
                    bne       L1623
                    incb
L1623               ldb       B,U
                    mul
                    anda      #15
                    ldb       D,U
                    andb      #252
                    stb       >-224
                    bra       L160F
L1631               puls      A
                    bra       L1606
L1635               puls      A
L1637               lda       >-221
                    anda      #247
                    sta       >-221
                    rts
L1640               lbsr      L1A36
                    ldx       #-79
                    ldb       ,X+
                    pshs      B
                    ldd       ,X++
                    std       -3,X
                    ldd       ,X++
                    std       -3,X
                    lda       ,X
                    puls      B
                    std       -1,X
                    rts

J1659               lbsr      L0A7A
                    lbsr      L29F1
                    ldd       #1797
                    lbsr      L28D5
                    leau      >MtchRslt,PC
                    lbsr      L0FA2
                    ldd       #3080
                    lbsr      L28D5
                    leau      >L087F,PC
                    lbsr      L0FA2
                    ldd       #6664
                    lbsr      L28D5
                    ldb       <U0012
                    lbsr      J12FE
                    ldd       #3082
                    lbsr      L28D5
                    leau      >L088A,PC
                    lbsr      L0FA2
                    ldd       #6666
                    lbsr      L28D5
                    ldb       <U0013
                    lbsr      J12FE
                    lda       <U0011
                    cmpa      #4
                    bne       L16AF
                    ldd       #1548
                    lbsr      L28D5
                    leau      >TooMany,PC
                    lbsr      L0FA2
L16AF               ldd       #2322
                    lbsr      L28D5
                    leau      >MatchEnd,PC
                    lbsr      L0FA2
                    ldd       #2068
                    lbsr      L28D5
                    leau      >PresBtn,PC
                    lbsr      L0FA2
                    bra       L1728
MtchRslt            fcc       "Challenge match results:"
                    fcb       $00
PresBtn             fcc       "Press button to exit"
                    fcb       $00
TooMany             fcc       "Too many turns have passed"
                    fcb       $00
MatchEnd            fcc       "This match is ended"
                    fcb       $00
L1728               ldd       #138
                    ldx       #128
                    clr       <U005B
                    os9       I$SetStt
                    tst       <U005B
                    bmi       L1728
                    ldx       #0
                    os9       F$Sleep
                    rts

J173E               pshs      Y,X,D
                    cmpb      #144
                    bne       L1749
                    ldb       #141
                    ldu       #2134
L1749               pshs      U
                    stb       <U0010
                    lbsr      L12BF
                    clr       <U0020
                    lbsr      L1461
                    lbsr      L1B6F
                    lbsr      L0A7E
                    ldu       ,S
                    lda       U0004,U
                    beq       L1772
                    ldb       #7
                    deca
                    mul
                    ldu       #1154
                    leau      D,U
                    ldu       U0001,U
                    leau      >$E200,U
                    bra       L1778
L1772               ldu       U0001,U
                    leau      >$E215,U
L1778               lbsr      L181E
                    ldu       ,S
                    ldu       U0001,U
                    leau      >$E200,U
                    lbsr      L181E
                    ldu       ,S
                    lda       U0003,U
                    beq       L179D
                    deca
                    ldu       #1154
                    ldb       #7
                    mul
                    leau      D,U
                    ldu       U0001,U
                    leau      >$E200,U
                    bra       L17A3
L179D               ldu       U0001,U
                    leau      >$E1EB,U
L17A3               bsr       L181E
                    lbsr      L19C9
                    ldx       ,S
                    ldx       U0001,X
                    ldb       <U0010
                    cmpb      #12
                    bls       L17B6
                    leax      >$F100,X
L17B6               leax      -10,X
                    tfr       X,D
                    lsra
                    rorb
                    tfr       D,X
                    lbsr      L0E19
                    lda       #36
                    ldb       <U0010
                    cmpb      #12
                    bls       L17CF
                    cmpb      #75
                    bls       L17CD
L17CD               lda       #48
L17CF               pshs      X
                    tfr       A,B
                    pshs      D
                    ldu       #194
L17D8               dec       ,S
                    blt       L17E7
                    tfr       X,Y
                    lbsr      L18A5
                    leax      >X00A0,X
                    bra       L17D8
L17E7               puls      A
                    lbsr      L1B58
                    ldx       1,S
                    ldy       #194
L17F2               dec       ,S
                    blt       L1801
                    tfr       X,U
                    lbsr      L18B6
                    leax      >X00A0,X
                    bra       L17F2
L1801               leas      3,S
                    clra
                    clrb
                    lbsr      L115C
                    puls      U
                    lbsr      J136D
                    ldu       <U0018
                    lbsr      L28B6
                    tst       <U004A
                    beq       L181C
                    lbsr      L2BEA
                    lbsr      J13C6
L181C               puls      PC,Y,X,D
L181E               pshs      U
                    bsr       L1834
                    leau      >U1E00,U
                    bsr       L1834
                    leau      >U1E00,U
                    bsr       L1834
                    puls      PC,U
L1830               pshs      U,Y,X,D
                    bra       L1848
L1834               pshs      U,Y,X,D
                    tfr       U,X
                    ldu       #1154
                    lda       #87
L183D               cmpx      U0001,U
                    beq       L1848
                    leau      U0007,U
                    deca
                    bne       L183D
                    puls      PC,U,Y,X,D
L1848               ldx       U0001,U
                    clr       <U000B
L184C               tst       ,U
                    ble       L1876
                    ldb       ,U
                    stb       <U000B
                    stx       <U000C
                    stu       <U000E
                    pshs      U
                    lbsr      L18EF
                    puls      U
                    lda       U0005,U
                    beq       L1876
                    cmpa      #144
                    beq       L1876
                    deca
                    ldb       #7
                    mul
                    ldu       #1154
                    leau      D,U
                    leax      >$FD82,X
                    bra       L184C
L1876               ldb       <U000B
                    beq       L18A3
                    ldx       <U000C
                    ldu       <U000E
                    cmpu      <U0027
                    beq       L1888
                    cmpu      <U002A
                    bne       L188E
L1888               leau      >L0A4A,PC
                    bra       L1892
L188E               leau      >L0A1A,PC
L1892               lbsr      L0D5A
                    ldx       <U000C
                    ldu       <U000E
                    lbsr      L1A40
                    ldx       <U000C
                    ldb       <U000B
                    lbsr      L0C88
L18A3               puls      PC,U,Y,X,D
L18A5               lda       <U0010
                    cmpa      #31
                    bne       L18AF
                    leay      4,Y
                    bra       L18B3
L18AF               bsr       L18C0
                    bra       L18B5
L18B3               bsr       L18C8
L18B5               rts
L18B6               lda       <U0010
                    cmpa      #31
                    bne       L18AF
                    leau      U0004,U
                    bra       L18B3
L18C0               ldd       ,Y++
                    std       ,U++
                    ldd       ,Y++
                    std       ,U++
L18C8               ldd       ,Y++
                    std       ,U++
                    ldd       ,Y++
                    std       ,U++
                    ldd       ,Y++
                    std       ,U++
                    ldd       ,Y++
                    std       ,U++
                    ldd       ,Y++
                    std       ,U++
                    ldd       ,Y++
                    std       ,U++
                    lda       <U0010
                    cmpa      #45
                    beq       L18EE
                    ldd       ,Y++
                    std       ,U++
                    ldd       ,Y++
                    std       ,U++
L18EE               rts
L18EF               pshs      X,B
                    tfr       X,D
                    andb      #1
                    beq       L1965
                    tfr       X,D
                    lsra
                    rorb
                    tfr       D,X
                    lbsr      L0E19
                    leax      -1,X
                    leax      >X00A0,X
                    lda       #186
                    sta       U0001,X
                    leax      >X00A0,X
                    lda       ,X
                    anda      #240
                    ora       #11
                    sta       ,X
                    lda       #170
                    sta       U0001,X
                    leax      >X00A0,X
                    lda       #23
                    pshs      A
L1922               dec       ,S
                    blt       L193C
                    lda       U0001,X
                    anda      #15
                    ora       #160
                    sta       U0001,X
                    lda       ,X
                    anda      #240
                    ora       #10
                    sta       ,X
                    leax      >X00A0,X
                    bra       L1922
L193C               puls      A
                    leax      >$FEC0,X
                    leax      U0001,X
                    lda       #10
                    ldb       #170
L1948               deca
                    blt       L1953
                    stb       >X00A0,X
                    stb       ,X+
                    bra       L1948
L1953               lda       #171
                    sta       ,X
                    leax      >X00A0,X
                    lda       ,X
                    anda      #15
                    ora       #176
                    sta       ,X
                    bra       L19BA
L1965               tfr       X,D
                    lsra
                    rorb
                    tfr       D,X
                    lbsr      L0E19
                    lda       #170
                    leax      >X009F,X
                    lda       ,X
                    anda      #240
                    ora       #11
                    sta       ,X
                    leax      >X00A0,X
                    lda       #186
                    sta       ,X
                    leax      >X00A0,X
                    lda       #170
                    ldb       #23
L198C               decb
                    blt       L1997
                    sta       ,X
                    leax      >X00A0,X
                    bra       L198C
L1997               leax      >$FEC0,X
                    lda       #170
                    ldb       #10
L199F               decb
                    blt       L19AA
                    sta       >X00A0,X
                    sta       ,X+
                    bra       L199F
L19AA               lda       #171
                    sta       ,X
                    leax      >X00A0,X
                    lda       ,X
                    anda      #15
                    ora       #176
                    sta       ,X
L19BA               puls      PC,X,B
L19BC               clr       <U0027
                    clr       <U0028
                    clr       <U0029
                    clr       <U002A
                    clr       <U002B
                    clr       <U002C
                    rts
L19C9               pshs      U,Y,X,D
                    ldu       #1154
                    leau      >U03E9,U
                    ldb       ,U
                    ble       L1A0B
                    pshs      U
                    ldx       U0001,U
                    leax      >$F608,X
                    pshs      X
                    lbsr      L18EF
                    ldu       2,S
                    bsr       L1A40
                    ldu       2,S
                    cmpu      <U0027
                    beq       L19F9
                    cmpu      <U002A
                    beq       L19F9
                    leau      >L0A1A,PC
                    bra       L19FD
L19F9               leau      >L0A4A,PC
L19FD               lbsr      L0D5A
                    puls      X
                    ldu       ,S
                    ldb       ,U
                    lbsr      L0C88
                    puls      U
L1A0B               puls      PC,U,Y,X,D

J1A0D               lda       ,U
                    cmpa      ,Y
                    beq       L1A2F
                    anda      #240
                    cmpa      #48
                    beq       L1A27
                    cmpa      #64
                    bne       L1A32
                    lda       ,Y
                    anda      #240
                    cmpa      #64
                    beq       L1A2F
                    bra       L1A32
L1A27               lda       ,Y
                    anda      #240
                    cmpa      #48
                    bne       L1A32
L1A2F               clra
                    tsta
                    rts
L1A32               lda       #1
                    tsta
                    rts
L1A36               pshs      X
                    ldx       #2
                    os9       F$Sleep
                    puls      PC,X
L1A40               pshs      X
                    pshs      U
                    lda       U0004,U
                    beq       L1A55
                    deca
                    ldu       #1154
                    ldb       #7
                    mul
                    leau      D,U
                    lda       ,U
                    bgt       L1AA8
L1A55               ldu       ,S
                    ldd       2,S
                    lsra
                    rorb
                    tfr       D,X
                    lbsr      L0E19
                    ldd       2,S
                    andb      #1
                    beq       L1A86
                    leax      U000B,X
                    bsr       L1AAC
                    lda       #22
                    pshs      A
L1A6E               dec       ,S
                    blt       L1A7C
                    leax      >X00A0,X
                    bsr       L1AAC
                    bsr       L1AC6
                    bra       L1A6E
L1A7C               puls      B
                    leax      >X00A0,X
                    bsr       L1AAC
                    bra       L1AA8
L1A86               leax      U000A,X
                    bsr       L1AC6
                    lda       #22
                    pshs      A
L1A8E               dec       ,S
                    blt       L1AA0
                    leax      >X00A0,X
                    bsr       L1AC6
                    leax      U0001,X
                    bsr       L1AAC
                    leax      -1,X
                    bra       L1A8E
L1AA0               puls      B
                    leax      >X00A0,X
                    bsr       L1AC6
L1AA8               puls      U
                    puls      PC,X
L1AAC               pshs      U
                    ldb       ,X
                    tfr       B,A
                    anda      #15
                    andb      #240
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    leau      >L1ADE,PC
                    ldb       B,U
                    aslb
                    aslb
                    aslb
                    aslb
                    bra       L1AD6
L1AC6               pshs      U
                    ldb       ,X
                    tfr       B,A
                    anda      #240
                    andb      #15
                    leau      >L1ADE,PC
                    ldb       B,U
L1AD6               pshs      A
                    orb       ,S+
                    stb       ,X
                    puls      PC,U
L1ADE               fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $09
                    fcb       $0A
                    fcb       $00
                    fcb       $0E
                    fcb       $0E
                    fcb       $00
                    fcb       $0E
L1AEE               bsr       L1B3F
                    pshs      CC
                    orcc      #80
                    lda       #230
L1AF6               bsr       L1B10
                    tfr       A,B
                    andb      #247
                    orb       #2
                    stb       >-224
                    bsr       L1B10
                    ldb       #2
                    stb       >-224
                    deca
                    deca
                    cmpa      #18
                    bcc       L1AF6
                    puls      CC
L1B10               ldb       #180
L1B12               decb
                    bne       L1B12
                    rts
L1B16               pshs      X,D,CC
                    orcc      #80
                    leax      >L0465,PC
                    lda       >-224
                    anda      #3
                    sta       >-224
                    bsr       L1B3F
                    lda       #10
L1B2A               tfr       A,B
L1B2C               decb
                    bne       L1B2C
                    ldb       ,X+
                    stb       >-224
                    inca
                    cmpa      #76
                    bcs       L1B2A
                    lbsr      L1637
                    clrb
                    puls      PC,X,D,CC
L1B3F               lda       >-221
                    ora       #8
                    sta       >-221
                    lda       >-255
                    anda      #247
                    sta       >-255
                    lda       >-253
                    anda      #247
                    sta       >-253
                    rts
L1B58               pshs      U,Y,X,D
                    ldu       <U0053
                    ldb       #4
                    os9       F$ClrBlk
                    ldx       <U0055
                    ldb       #4
                    os9       F$MapBlk
                    stu       <U0053
                    os9       F$ID
                    puls      PC,U,Y,X,D
L1B6F               pshs      U,Y,X,D
                    ldu       <U0053
                    ldb       #4
                    os9       F$ClrBlk
                    ldx       <U0057
                    ldb       #4
                    os9       F$MapBlk
                    stu       <U0053
                    os9       F$ID
                    puls      PC,U,Y,X,D
L1B86               ldx       <U0053
                    leax      >X12F6,X
L1B8C               lda       ,U+
                    cmpa      #255
                    beq       L1BB2
                    pshs      A
                    tsta
                    bge       L1BA1
                    ldb       ,S
                    andb      #127
                    bsr       L1BB3
                    stb       ,X+
                    bra       L1BAE
L1BA1               ldb       ,S
                    andb      #127
                    bsr       L1BB3
                    lda       ,U+
L1BA9               stb       ,X+
                    deca
                    bne       L1BA9
L1BAE               puls      A
                    bra       L1B8C
L1BB2               rts
L1BB3               pshs      A
                    leay      >L1BBE,PC
                    clra
                    ldb       D,Y
                    puls      PC,A
L1BBE               fcb       $00
                    fcb       $01
                    fcb       $02
                    fcb       $03
                    fcb       $04
                    fcb       $05
                    fcb       $06
                    fcb       $08
                    fcb       $09
                    fcb       $0A
                    fcb       $10
                    fcb       $11
                    fcb       $12
                    fcb       $16
                    fcb       $18
                    fcb       $19
                    fcc       /!"$&012369@DEFIJRUVY`cdefhijt/
                    fcb       $80
                    fcb       $84
                    fcb       $85
                    fcb       $86
                    fcb       $88
                    fcb       $89
                    fcb       $8A
                    fcb       $90
                    fcb       $91
                    fcb       $92
                    fcb       $93
                    fcb       $94
                    fcb       $95
                    fcb       $96
                    fcb       $98
                    fcb       $99
                    fcb       $9A
                    fcb       $A0
                    fcb       $A1
                    fcb       $A4
                    fcb       $A8
                    fcb       $A9
                    fcb       $AA
L1C02               fcb       $00
                    fcb       $15
                    fcb       $00
                    fcb       $02
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $2A
                    fcb       $01
                    fcb       $03
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $3F
                    fcb       $02
                    fcb       $04
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $54
                    fcb       $03
                    fcb       $05
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $69
                    fcb       $04
                    fcb       $06
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $7E
                    fcb       $05
                    fcb       $07
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $93
                    fcb       $06
                    fcb       $08
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $A8
                    fcb       $07
                    fcb       $09
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $BD
                    fcb       $08
                    fcb       $0A
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $D2
                    fcb       $09
                    fcb       $0B
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $E7
                    fcb       $0A
                    fcb       $0C
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $FC
                    fcb       $0B
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $1E
                    fcb       $3F
                    fcb       $00
                    fcb       $0E
                    fcb       $00
                    fcb       $00
                    fcb       $1E
                    fcb       $54
                    fcb       $0D
                    fcb       $0F
                    fcb       $58
                    fcb       $00
                    fcb       $1E
                    fcb       $69
                    fcb       $0E
                    fcb       $10
                    fcb       $59
                    fcb       $00
                    fcb       $1E
                    fcb       $7E
                    fcb       $0F
                    fcb       $11
                    fcb       $5A
                    fcb       $00
                    fcb       $1E
                    fcb       $93
                    fcb       $10
                    fcb       $12
                    fcb       $5B
                    fcb       $00
                    fcb       $1E
                    fcb       $A8
                    fcb       $11
                    fcb       $13
                    fcb       $5C
                    fcb       $00
                    fcb       $1E
                    fcb       $BD
                    fcb       $12
                    fcb       $14
                    fcb       $5D
                    fcb       $00
                    fcb       $1E
                    fcb       $D2
                    fcb       $13
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $2A
                    fcb       $00
                    fcb       $16
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $3F
                    fcb       $15
                    fcb       $17
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $54
                    fcb       $16
                    fcb       $18
                    fcb       $5E
                    fcb       $00
                    fcb       $3C
                    fcb       $69
                    fcb       $17
                    fcb       $19
                    fcb       $5F
                    fcb       $00
                    fcb       $3C
                    fcb       $7E
                    fcb       $18
                    fcb       $1A
                    fcb       $60
                    fcb       $00
                    fcb       $3C
                    fcb       $93
                    fcb       $19
                    fcb       $1B
                    fcb       $61
                    fcb       $00
                    fcb       $3C
                    fcb       $A8
                    fcb       $1A
                    fcb       $1C
                    fcb       $62
                    fcb       $00
                    fcb       $3C
                    fcb       $BD
                    fcb       $1B
                    fcb       $1D
                    fcb       $63
                    fcb       $00
                    fcb       $3C
                    fcb       $D2
                    fcb       $1C
                    fcb       $1E
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $E7
                    fcb       $1D
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $69
                    fcb       $00
                    fcb       $00
                    fcb       $20
                    fcb       $00
                    fcb       $00
                    fcb       $5A
                    fcb       $15
                    fcb       $1F
                    fcb       $21
                    fcb       $00
                    fcb       $00
                    fcc       /Z* "/
                    fcb       $00
                    fcb       $00
                    fcc       "Z?!#"
                    fcb       $00
                    fcb       $00
                    fcc       /ZT"$d/
                    fcb       $00
                    fcc       "Zi#%e"
                    fcb       $00
                    fcb       $5A
                    fcb       $7E
                    fcc       "$&f"
                    fcb       $00
                    fcb       $5A
                    fcb       $93
                    fcc       "%'g"
                    fcb       $00
                    fcb       $5A
                    fcb       $A8
                    fcc       "&(h"
                    fcb       $00
                    fcb       $5A
                    fcb       $BD
                    fcc       "')i"
                    fcb       $00
                    fcb       $5A
                    fcb       $D2
                    fcb       $28
                    fcb       $2A
                    fcb       $00
                    fcb       $00
                    fcb       $5A
                    fcb       $E7
                    fcb       $29
                    fcb       $2B
                    fcb       $00
                    fcb       $00
                    fcb       $5A
                    fcb       $FC
                    fcb       $2A
                    fcb       $2C
                    fcb       $00
                    fcb       $00
                    fcb       $6A
                    fcb       $11
                    fcb       $2B
                    fcb       $2D
                    fcb       $00
                    fcb       $00
                    fcc       "j&,"
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $15
                    fcb       $1F
                    fcb       $2F
                    fcb       $00
                    fcb       $00
                    fcc       "x*.0"
                    fcb       $00
                    fcb       $00
                    fcc       "x?/1"
                    fcb       $00
                    fcb       $00
                    fcc       "xT02j"
                    fcb       $00
                    fcc       "xi13k"
                    fcb       $00
                    fcb       $78
                    fcb       $7E
                    fcc       "24l"
                    fcb       $00
                    fcb       $78
                    fcb       $93
                    fcc       "35m"
                    fcb       $00
                    fcb       $78
                    fcb       $A8
                    fcc       "46n"
                    fcb       $00
                    fcb       $78
                    fcb       $BD
                    fcc       "57o"
                    fcb       $00
                    fcb       $78
                    fcb       $D2
                    fcb       $36
                    fcb       $38
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $E7
                    fcb       $37
                    fcb       $39
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $FC
                    fcb       $38
                    fcb       $2C
                    fcb       $00
                    fcb       $00
                    fcb       $96
                    fcb       $2A
                    fcb       $00
                    fcb       $3B
                    fcb       $00
                    fcb       $00
                    fcb       $96
                    fcc       "?:<"
                    fcb       $00
                    fcb       $00
                    fcb       $96
                    fcc       "T;=p"
                    fcb       $00
                    fcb       $96
                    fcc       "i<>q"
                    fcb       $00
                    fcb       $96
                    fcb       $7E
                    fcc       "=?r"
                    fcb       $00
                    fcb       $96
                    fcb       $93
                    fcc       ">@s"
                    fcb       $00
                    fcb       $96
                    fcb       $A8
                    fcc       "?At"
                    fcb       $00
                    fcb       $96
                    fcb       $BD
                    fcc       "@Bu"
                    fcb       $00
                    fcb       $96
                    fcb       $D2
                    fcb       $41
                    fcb       $43
                    fcb       $00
                    fcb       $00
                    fcb       $96
                    fcb       $E7
                    fcb       $42
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $B4
                    fcb       $3F
                    fcb       $00
                    fcb       $45
                    fcb       $00
                    fcb       $00
                    fcb       $B4
                    fcc       "TDFv"
                    fcb       $00
                    fcb       $B4
                    fcc       "iEGw"
                    fcb       $00
                    fcb       $B4
                    fcb       $7E
                    fcc       "FHx"
                    fcb       $00
                    fcb       $B4
                    fcb       $93
                    fcc       "GIy"
                    fcb       $00
                    fcb       $B4
                    fcb       $A8
                    fcc       "HJz"
                    fcb       $00
                    fcb       $B4
                    fcb       $BD
                    fcc       "IK{"
                    fcb       $00
                    fcb       $B4
                    fcb       $D2
                    fcb       $4A
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $D2
                    fcb       $15
                    fcb       $00
                    fcb       $4D
                    fcb       $00
                    fcb       $00
                    fcb       $D2
                    fcc       "*LN"
                    fcb       $00
                    fcb       $00
                    fcb       $D2
                    fcc       "?MO"
                    fcb       $00
                    fcb       $00
                    fcb       $D2
                    fcc       "TNP"
                    fcb       $00
                    fcb       $00
                    fcb       $D2
                    fcc       "iOQ"
                    fcb       $00
                    fcb       $00
                    fcb       $D2
                    fcb       $7E
                    fcb       $50
                    fcb       $52
                    fcb       $00
                    fcb       $00
                    fcb       $D2
                    fcb       $93
                    fcb       $51
                    fcb       $53
                    fcb       $00
                    fcb       $00
                    fcb       $D2
                    fcb       $A8
                    fcb       $52
                    fcb       $54
                    fcb       $00
                    fcb       $00
                    fcb       $D2
                    fcb       $BD
                    fcb       $53
                    fcb       $55
                    fcb       $00
                    fcb       $00
                    fcb       $D2
                    fcb       $D2
                    fcb       $54
                    fcb       $56
                    fcb       $00
                    fcb       $00
                    fcb       $D2
                    fcb       $E7
                    fcb       $55
                    fcb       $57
                    fcb       $00
                    fcb       $00
                    fcb       $D2
                    fcb       $FC
                    fcb       $56
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $1E
                    fcb       $54
                    fcb       $00
                    fcb       $59
                    fcb       $00
                    fcb       $0E
                    fcb       $1E
                    fcc       "iXZ"
                    fcb       $00
                    fcb       $0F
                    fcb       $1E
                    fcb       $7E
                    fcb       $59
                    fcb       $5B
                    fcb       $00
                    fcb       $10
                    fcb       $1E
                    fcb       $93
                    fcb       $5A
                    fcb       $5C
                    fcb       $00
                    fcb       $11
                    fcb       $1E
                    fcb       $A8
                    fcb       $5B
                    fcb       $5D
                    fcb       $00
                    fcb       $12
                    fcb       $1E
                    fcb       $BD
                    fcb       $5C
                    fcb       $00
                    fcb       $00
                    fcb       $13
                    fcb       $3C
                    fcb       $54
                    fcb       $00
                    fcb       $5F
                    fcb       $00
                    fcb       $17
                    fcc       "<i^`|"
                    fcb       $18
                    fcb       $3C
                    fcb       $7E
                    fcc       "_a}"
                    fcb       $19
                    fcb       $3C
                    fcb       $93
                    fcb       $60
                    fcb       $62
                    fcb       $7E
                    fcb       $1A
                    fcb       $3C
                    fcb       $A8
                    fcb       $61
                    fcb       $63
                    fcb       $7F
                    fcb       $1B
                    fcb       $3C
                    fcb       $BD
                    fcb       $62
                    fcb       $00
                    fcb       $00
                    fcb       $1C
                    fcb       $5A
                    fcb       $54
                    fcb       $00
                    fcb       $65
                    fcb       $00
                    fcc       "#Zidf"
                    fcb       $80
                    fcb       $24
                    fcb       $5A
                    fcb       $7E
                    fcb       $65
                    fcb       $67
                    fcb       $81
                    fcb       $25
                    fcb       $5A
                    fcb       $93
                    fcb       $66
                    fcb       $68
                    fcb       $82
                    fcb       $26
                    fcb       $5A
                    fcb       $A8
                    fcb       $67
                    fcb       $69
                    fcb       $83
                    fcb       $27
                    fcb       $5A
                    fcb       $BD
                    fcb       $68
                    fcb       $00
                    fcb       $00
                    fcc       "(xT"
                    fcb       $00
                    fcb       $6B
                    fcb       $00
                    fcc       "1xijl"
                    fcb       $84
                    fcb       $32
                    fcb       $78
                    fcb       $7E
                    fcb       $6B
                    fcb       $6D
                    fcb       $85
                    fcb       $33
                    fcb       $78
                    fcb       $93
                    fcb       $6C
                    fcb       $6E
                    fcb       $86
                    fcb       $34
                    fcb       $78
                    fcb       $A8
                    fcb       $6D
                    fcb       $6F
                    fcb       $87
                    fcb       $35
                    fcb       $78
                    fcb       $BD
                    fcb       $6E
                    fcb       $00
                    fcb       $00
                    fcb       $36
                    fcb       $96
                    fcb       $54
                    fcb       $00
                    fcb       $71
                    fcb       $00
                    fcb       $3C
                    fcb       $96
                    fcc       "ipr"
                    fcb       $88
                    fcb       $3D
                    fcb       $96
                    fcb       $7E
                    fcb       $71
                    fcb       $73
                    fcb       $89
                    fcb       $3E
                    fcb       $96
                    fcb       $93
                    fcb       $72
                    fcb       $74
                    fcb       $8A
                    fcb       $3F
                    fcb       $96
                    fcb       $A8
                    fcb       $73
                    fcb       $75
                    fcb       $8B
                    fcb       $40
                    fcb       $96
                    fcb       $BD
                    fcb       $74
                    fcb       $00
                    fcb       $00
                    fcb       $41
                    fcb       $B4
                    fcb       $54
                    fcb       $00
                    fcb       $77
                    fcb       $00
                    fcb       $45
                    fcb       $B4
                    fcc       "ivx"
                    fcb       $00
                    fcb       $46
                    fcb       $B4
                    fcb       $7E
                    fcb       $77
                    fcb       $79
                    fcb       $00
                    fcb       $47
                    fcb       $B4
                    fcb       $93
                    fcb       $78
                    fcb       $7A
                    fcb       $00
                    fcb       $48
                    fcb       $B4
                    fcb       $A8
                    fcb       $79
                    fcb       $7B
                    fcb       $00
                    fcb       $49
                    fcb       $B4
                    fcb       $BD
                    fcb       $7A
                    fcb       $00
                    fcb       $00
                    fcc       "J<i"
                    fcb       $00
                    fcb       $7D
                    fcb       $00
                    fcb       $5F
                    fcb       $3C
                    fcb       $7E
                    fcb       $7C
                    fcb       $7E
                    fcb       $00
                    fcb       $60
                    fcb       $3C
                    fcb       $93
                    fcb       $7D
                    fcb       $7F
                    fcb       $00
                    fcb       $61
                    fcb       $3C
                    fcb       $A8
                    fcb       $7E
                    fcb       $00
                    fcb       $00
                    fcc       "bZi"
                    fcb       $00
                    fcb       $81
                    fcb       $00
                    fcb       $65
                    fcb       $5A
                    fcb       $7E
                    fcb       $80
                    fcb       $82
                    fcb       $8C
                    fcb       $66
                    fcb       $5A
                    fcb       $93
                    fcb       $81
                    fcb       $83
                    fcb       $8D
                    fcb       $67
                    fcb       $5A
                    fcb       $A8
                    fcb       $82
                    fcb       $00
                    fcb       $00
                    fcc       "hxi"
                    fcb       $00
                    fcb       $85
                    fcb       $00
                    fcb       $6B
                    fcb       $78
                    fcb       $7E
                    fcb       $84
                    fcb       $86
                    fcb       $8E
                    fcb       $6C
                    fcb       $78
                    fcb       $93
                    fcb       $85
                    fcb       $87
                    fcb       $8F
                    fcb       $6D
                    fcb       $78
                    fcb       $A8
                    fcb       $86
                    fcb       $00
                    fcb       $00
                    fcb       $6E
                    fcb       $96
                    fcb       $69
                    fcb       $00
                    fcb       $89
                    fcb       $00
                    fcb       $71
                    fcb       $96
                    fcb       $7E
                    fcb       $88
                    fcb       $8A
                    fcb       $00
                    fcb       $72
                    fcb       $96
                    fcb       $93
                    fcb       $89
                    fcb       $8B
                    fcb       $00
                    fcb       $73
                    fcb       $96
                    fcb       $A8
                    fcb       $8A
                    fcb       $00
                    fcb       $00
                    fcb       $74
                    fcb       $5A
                    fcb       $7E
                    fcb       $00
                    fcb       $8D
                    fcb       $90
                    fcb       $81
                    fcb       $5A
                    fcb       $93
                    fcb       $8C
                    fcb       $00
                    fcb       $90
                    fcb       $82
                    fcb       $78
                    fcb       $7E
                    fcb       $00
                    fcb       $8F
                    fcb       $90
                    fcb       $85
                    fcb       $78
                    fcb       $93
                    fcb       $8E
                    fcb       $00
                    fcb       $90
                    fcb       $86
                    fcb       $69
                    fcb       $88
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
L1F62               fcb       $2D
                    fcb       $2C
                    fcb       $0C
                    fcc       "+9W"
                    fcb       $0B
                    fcb       $1E
                    fcc       "*8CV"
                    fcb       $0A
                    fcb       $14
                    fcb       $1D
                    fcc       ")7BKU"
                    fcb       $09
                    fcb       $13
                    fcb       $1C
                    fcc       "(6AJT"
                    fcb       $08
                    fcb       $12
                    fcb       $1B
                    fcc       "'5@IS"
                    fcb       $07
                    fcb       $11
                    fcb       $1A
                    fcc       "&4?HR"
                    fcb       $06
                    fcb       $10
                    fcb       $19
                    fcc       "%3>GQ"
                    fcb       $05
                    fcb       $0F
                    fcb       $18
                    fcc       "$2=FP"
                    fcb       $04
                    fcb       $0E
                    fcb       $17
                    fcc       "#1<EO"
                    fcb       $03
                    fcb       $0D
                    fcb       $16
                    fcc       /"0;DN/
                    fcb       $02
                    fcb       $15
                    fcc       "!/:M"
                    fcb       $01
                    fcc       " .L"
                    fcb       $1F
                    fcb       $00
L1FBA               fcc       /"R!$xy/
                    fcb       $13
                    fcc       "iUW#cRder#Y#ggqsy"
                    fcb       $11
                    fcb       $61
                    fcb       $11
                    fcc       /s"qwqfUxbduu/
                    fcb       $12
                    fcc       "iTrVV!ud"
                    fcb       $11
                    fcc       "Wxhre"
                    fcb       $11
                    fcc       "vXQQxXhsSd"
                    fcb       $12
                    fcc       "3twYRWy"
                    fcb       $12
                    fcb       $13
                    fcc       "$S1$yX2a!T"
                    fcb       $13
                    fcb       $61
                    fcb       $75
                    fcb       $13
                    fcc       /"bSaBRscf/
                    fcb       $12
                    fcc       /wfeW"TqTCbYcthAUtv!whQDScY$girQV#ev4UVgXitvbfw3Uytxr$YSYtxXv4sVSeAUqRhh!xWfidcaUiX/
                    fcb       $11
                    fcc       /g"SQ/
                    fcb       $12
                    fcc       "RqRttarqWWwbu"
                    fcb       $11
                    fcc       "dCDVW"
                    fcb       $13
                    fcc       "hdQQbqr"
                    fcb       $11
                    fcc       "yTe"
                    fcb       $12
                    fcb       $13
                    fcc       "sby2xBfcw!d#Yurvibs!"
                    fcb       $13
                    fcc       "XuTh#v"
                    fcb       $12
                    fcc       /Qvc$#Rf"""!1fwViauTVeUXa/
                    fcb       $12
                    fcc       "gTyS"
                    fcb       $13
                    fcc       "$$c"
                    fcb       $11
                    fcc       "sYgge#q"
                    fcb       $11
                    fcb       $73
                    fcb       $12
                    fcc       /WrYvvhRifSecbixdStUqa"fxeU"rXd$bd!Xuf/
                    fcb       $13
                    fcc       "u$#Ab$wvuiiTs"
                    fcb       $12
                    fcb       $71
                    fcb       $32
                    fcb       $13
                    fcc       "Vxga!aWV"
                    fcb       $11
                    fcc       "t!yVTWwg"
                    fcb       $11
                    fcb       $31
                    fcb       $56
                    fcb       $12
                    fcc       /Q#"wUhYhtbucRsrSfWBRhQS/
                    fcb       $11
                    fcc       "yQ$t#Dd"
                    fcb       $12
                    fcc       /Xcxgg4yr"3RYsT#TeYvQ/
                    fcb       $13
                    fcc       "!cey"
                    fcb       $13
                    fcc       "XqUaCwYw"
                    fcb       $12
                    fcc       "tebdbS"
                    fcb       $13
                    fcb       $11
                    fcc       "RcD"
                    fcb       $12
                    fcb       $13
                    fcc       "rirafVeVxsud"
                    fcb       $13
                    fcc       /dYX"ssie##fXqSia4/
                    fcb       $11
                    fcc       "Q#vrRu!!qgT$e"
                    fcb       $11
                    fcc       "ViTx#VWuhUcv"
                    fcb       $12
                    fcb       $51
                    fcb       $24
                    fcb       $13
                    fcc       /"TXwQhfxduvvgW/
                    fcb       $11
                    fcc       /ytUhW$qWC"QqcgUsytgUbwh1at23ycfXSyTS$!aYRbRYB!wr/
                    fcb       $12
                    fcc       /A"xRVtBStYwqq"ShRs!sUS!r/
                    fcb       $12
                    fcb       $76
                    fcb       $11
                    fcc       "bQ3"
                    fcb       $12
                    fcb       $34
                    fcb       $13
                    fcc       "w1c2"
                    fcb       $11
                    fcc       /"eTvrVbf"/
                    fcb       $13
                    fcc       "dXQRdx$dyqfc$cs"
                    fcb       $11
                    fcc       "fXdgyaTawYUQ!RbgtWigeU$WU#QTYTx"
                    fcb       $11
                    fcc       "isW"
                    fcb       $13
                    fcc       /S!"VxvCXug#qX/
                    fcb       $13
                    fcc       "Aea$u"
                    fcb       $12
                    fcc       "uehwuWYyxri#fvVtrhyaD#bhc"
                    fcb       $12
                    fcc       "ihU"
                    fcb       $12
                    fcc       /Q"!ReWeaQigqRdbVqtvyfhqSiWfYcg/
                    fcb       $12
                    fcc       "yU#X!awDgVext#wB"
                    fcb       $13
                    fcc       "sqcvS$TArSu!"
                    fcb       $11
                    fcc       /df$"/
                    fcb       $11
                    fcb       $75
                    fcb       $63
                    fcb       $13
                    fcb       $43
                    fcb       $13
                    fcc       "iRXrYyV#f"
                    fcb       $11
                    fcc       /#Qv$"xXssWVaXd31bYtbchs2Tgt/
                    fcb       $11
                    fcb       $53
                    fcb       $13
                    fcc       /yQb"Urvuxwu/
                    fcb       $12
                    fcc       "eTTwYraUW$xi4hd!"
                    fcb       $12
                    fcc       "RgQxi"
                    fcb       $11
                    fcc       "TXXRsbXuu#We#"
                    fcb       $12
                    fcc       "bXq!ticQSYcaURufRistsTqvD#A1STVW"
                    fcb       $12
                    fcc       "hyVvr"
                    fcb       $12
                    fcc       /Y!qWvU2fgehYY"$Svdtch/
                    fcb       $11
                    fcb       $13
                    fcc       /!wd"RfU/
                    fcb       $13
                    fcc       /$B3QaeuCV#yydbrf!bS"e/
                    fcb       $11
                    fcc       "h$rVy$awrgi4xtgwU"
                    fcb       $12
                    fcb       $61
                    fcb       $54
                    fcb       $13
                    fcc       /sx"cdWxw/
                    fcb       $13
                    fcb       $71
                    fcb       $51
                    fcb       $11
                    fcc       /iDsVAx!hixSfa""4er$2ydqv!QrvVwX/
                    fcb       $13
                    fcc       /C"QXhRcreu#tUdq#/
                    fcb       $11
                    fcc       "tqg1"
                    fcb       $13
                    fcc       "fg$$"
                    fcb       $13
                    fcb       $11
                    fcc       "SsWec!wRyUWB!RSvVu3gaxUhusa"
                    fcb       $12
                    fcc       "fvtrwda#yRTiW"
                    fcb       $13
                    fcb       $12
                    fcb       $59
                    fcb       $11
                    fcc       "WTibYxhTf#QTc"
                    fcb       $12
                    fcc       /"cUXuXt$bSY/
                    fcb       $12
                    fcc       "eQwq"
                    fcb       $11
                    fcc       "bsbdYyVg"
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $11
                    fcc       "QXhRcre"
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $23
                    fcb       $33
                    fcb       $11
                    fcc       "tqg1"
                    fcb       $13
                    fcb       $22
                    fcb       $71
                    fcb       $00
                    fcb       $00
                    fcc       "ABSsWeCA"
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $32
                    fcb       $22
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $12
                    fcc       "fvtrwda#yRTiW"
                    fcb       $13
                    fcb       $12
                    fcb       $59
                    fcb       $11
                    fcc       "WTibYxhTf#QTc"
                    fcb       $12
                    fcc       /"cUXuXt$/
                    fcb       $00
                    fcb       $53
                    fcb       $59
                    fcb       $00
                    fcc       "eQwq"
                    fcb       $00
                    fcb       $62
                    fcb       $73
                    fcb       $00
                    fcb       $64
                    fcb       $00
                    fcb       $79
                    fcb       $56
                    fcb       $00
L24CA               fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $0C
                    fcb       $0C
                    fcb       $18
                    fcc       " <B"
                    fcb       $99
                    fcb       $A1
                    fcb       $A1
                    fcb       $99
                    fcc       "B<4fF"
                    fcb       $0C
                    fcb       $18
                    fcb       $00
                    fcb       $18
                    fcb       $00
                    fcb       $88
                    fcb       $1D
                    fcb       $3E
                    fcb       $5C
                    fcb       $88
                    fcb       $C5
                    fcb       $E3
                    fcb       $D1
                    fcb       $1C
                    fcb       $0C
                    fcb       $18
                    fcb       $10
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $0E
                    fcb       $70
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $18
                    fcb       $18
                    fcb       $00
                    fcc       "<nFFbr~<"
                    fcb       $0C
                    fcb       $1C
                    fcb       $3C
                    fcb       $0C
                    fcb       $0C
                    fcb       $0C
                    fcb       $0C
                    fcb       $08
                    fcb       $3C
                    fcb       $7E
                    fcb       $66
                    fcb       $0C
                    fcb       $18
                    fcb       $33
                    fcb       $7E
                    fcb       $40
                    fcb       $3E
                    fcb       $06
                    fcb       $0C
                    fcb       $1E
                    fcb       $06
                    fcb       $0C
                    fcb       $18
                    fcb       $60
                    fcb       $0E
                    fcb       $1E
                    fcb       $36
                    fcb       $66
                    fcb       $7F
                    fcb       $06
                    fcb       $06
                    fcb       $04
                    fcb       $7E
                    fcb       $60
                    fcb       $7C
                    fcb       $06
                    fcb       $06
                    fcb       $0C
                    fcb       $18
                    fcb       $60
                    fcb       $06
                    fcb       $18
                    fcb       $30
                    fcb       $7C
                    fcb       $E6
                    fcc       "ff<~~F"
                    fcb       $0C
                    fcb       $18
                    fcb       $18
                    fcb       $18
                    fcb       $10
                    fcc       "<ff<ff~<<ffg>"
                    fcb       $0C
                    fcb       $18
                    fcb       $60
                    fcb       $00
                    fcb       $18
                    fcb       $18
                    fcb       $00
                    fcb       $18
                    fcb       $18
                    fcb       $00
                    fcb       $00
                    fcb       $7E
                    fcc       "BBBBB~"
                    fcb       $00
                    fcb       $38
                    fcb       $0C
                    fcs       "6fvffBlf"
                    fcc       "flffl@<Fb``r<"
                    fcb       $00
                    fcb       $6C
                    fcb       $E6
                    fcs       "ffffl@vb"
                    fcs       "`l`bv@vb"
                    fcs       "`l```@<F@"
                    fcb       $CC
                    fcb       $C6
                    fcb       $E6
                    fcb       $6C
                    fcb       $00
                    fcb       $66
                    fcb       $EE
                    fcc       "ffvffD"
                    fcb       $18
                    fcb       $00
                    fcb       $18
                    fcb       $38
                    fcb       $18
                    fcb       $18
                    fcb       $18
                    fcb       $10
                    fcb       $0C
                    fcb       $1C
                    fcb       $0C
                    fcb       $0C
                    fcb       $0C
                    fcb       $0C
                    fcb       $18
                    fcb       $20
                    fcb       $62
                    fcb       $EC
                    fcs       "h`hlfB``"
                    fcs       "```bn@cg"
                    fcb       $6B
                    fcb       $7F
                    fcs       "kccBfv"
                    fcb       $7E
                    fcc       "nfffD<Nfffv<"
                    fcb       $00
                    fcb       $6C
                    fcb       $E6
                    fcc       "fl```@<Nfffl6"
                    fcb       $02
                    fcb       $6C
                    fcb       $E6
                    fcc       "flhlf@,fp<"
                    fcb       $0E
                    fcb       $66
                    fcb       $34
                    fcb       $00
                    fcb       $FF
                    fcb       $89
                    fcb       $18
                    fcb       $18
                    fcb       $18
                    fcb       $18
                    fcb       $18
                    fcb       $10
                    fcc       "Dfffff4"
                    fcb       $00
                    fcb       $22
                    fcb       $66
                    fcb       $EE
                    fcc       "ff4"
                    fcb       $18
                    fcb       $00
                    fcb       $63
                    fcb       $E7
                    fcb       $63
                    fcb       $6B
                    fcb       $7F
                    fcc       "wcBBf4"
                    fcb       $18
                    fcb       $1C
                    fcs       ".fBfn"
                    fcb       $66
                    fcb       $34
                    fcb       $18
                    fcb       $18
                    fcb       $18
                    fcb       $10
                    fcb       $76
                    fcb       $46
                    fcb       $0C
                    fcb       $18
                    fcc       "0bn"
                    fcb       $00
L263A               fcb       $1D
                    fcb       $01
                    fcb       $00
                    fcb       $0B
                    fcb       $DE
                    fcb       $16
L2640               fcb       $12
                    fcb       $01
                    fcb       $00
                    fcb       $11
                    fcb       $DE
                    fcb       $15
                    fcb       $FF
                    fcc       "@ ALTERNATE"
                    fcb       $00
                    fcc       "@ ORIGINAL"
                    fcb       $00
L265E               fcb       $0C
                    fcb       $07
                    fcb       $00
                    fcb       $29
                    fcb       $DE
                    fcb       $2C
                    fcb       $0C
                    fcb       $09
                    fcb       $00
                    fcb       $32
                    fcb       $DE
                    fcb       $14
                    fcb       $0C
                    fcb       $0B
                    fcb       $00
                    fcb       $38
                    fcb       $E2
                    fcb       $3E
                    fcb       $0C
                    fcb       $0D
                    fcb       $00
                    fcb       $42
                    fcb       $E0
                    fcb       $4C
                    fcb       $0C
                    fcb       $0F
                    fcb       $00
                    fcb       $4C
                    fcb       $E3
                    fcb       $1A
                    fcb       $0C
                    fcb       $11
                    fcb       $00
                    fcb       $56
                    fcb       $DE
                    fcb       $05
                    fcb       $0C
                    fcb       $13
                    fcb       $00
                    fcb       $5F
                    fcb       $DD
                    fcb       $5E
                    fcb       $FF
                    fcc       "Play Solitaire"
                    fcb       $00
                    fcc       "Begin Again"
                    fcb       $00
                    fcc       "Select a Dragon"
                    fcb       $00
                    fcc       "Tournament Play"
                    fcb       $00
                    fcc       "Challenge Match"
                    fcb       $00
                    fcc       "Return to Game"
                    fcb       $00
                    fcc       "Return to OS-9"
                    fcb       $00
L26F2               fcb       $00
                    fcb       $04
                    fcb       $00
                    fcb       $1D
                    fcb       $DD
                    fcb       $6F
                    fcb       $00
                    fcb       $06
                    fcb       $00
                    fcb       $1C
                    fcb       $DD
                    fcb       $E7
                    fcb       $23
                    fcb       $06
                    fcb       $00
                    fcb       $1B
                    fcb       $DD
                    fcb       $E6
                    fcb       $22
                    fcb       $04
                    fcb       $00
                    fcb       $1A
                    fcb       $DD
                    fcb       $E5
                    fcb       $23
                    fcb       $08
                    fcb       $00
                    fcb       $1B
                    fcb       $E1
                    fcb       $FE
                    fcb       $FF
                    fcc       "Menu"
                    fcb       $00
                    fcc       "Undo"
                    fcb       $00
                    fcc       "Find"
                    fcb       $00
                    fcc       "Cancel"
                    fcb       $00
                    fcc       "Peek"
                    fcb       $00
L272C               fcb       $0C
                    fcb       $05
                    fcb       $00
                    fcb       $35
                    fcb       $E1
                    fcb       $93
                    fcb       $0C
                    fcb       $07
                    fcb       $00
                    fcb       $3D
                    fcb       $E1
                    fcb       $91
                    fcb       $0C
                    fcb       $09
                    fcb       $00
                    fcb       $44
                    fcb       $E1
                    fcb       $8F
                    fcb       $0C
                    fcb       $0B
                    fcb       $00
                    fcb       $49
                    fcb       $E1
                    fcb       $8D
                    fcb       $0C
                    fcb       $0D
                    fcb       $00
                    fcb       $4B
                    fcb       $E1
                    fcb       $8B
                    fcb       $0C
                    fcb       $0F
                    fcb       $00
                    fcb       $4F
                    fcb       $E1
                    fcb       $89
                    fcb       $0C
                    fcb       $11
                    fcb       $00
                    fcb       $55
                    fcb       $E1
                    fcb       $87
                    fcb       $0C
                    fcb       $13
                    fcb       $00
                    fcb       $5C
                    fcb       $E1
                    fcb       $85
                    fcb       $0C
                    fcb       $15
                    fcb       $00
                    fcb       $63
                    fcb       $DD
                    fcb       $05
                    fcb       $FF
                    fcc       "Pairs to Kong"
                    fcb       $00
                    fcc       "Fours Galore"
                    fcb       $00
                    fcc       "Four Winds"
                    fcb       $00
                    fcc       "Bam Bam"
                    fcb       $00
                    fcc       "Crak King"
                    fcb       $00
                    fcc       "Dots Across"
                    fcb       $00
                    fcc       "Dragon Rider"
                    fcb       $00
                    fcc       "Dragons Song"
                    fcb       $00
                    fcc       "Return to Menu"
                    fcb       $00
L27D0               fcb       $11
                    fcb       $0C
                    fcb       $00
                    fcb       $0B
                    fcb       $E1
                    fcb       $53
                    fcb       $11
                    fcb       $0E
                    fcb       $00
                    fcb       $09
                    fcb       $DC
                    fcb       $BE
                    fcb       $FF
                    fcc       "Yes"
                    fcb       $00
                    fcb       $4E
                    fcb       $6F
                    fcb       $00
L27E4               fcb       $0B
                    fcb       $09
                    fcb       $00
                    fcb       $1D
                    fcb       $E1
                    fcb       $C3
                    fcb       $0B
                    fcb       $0B
                    fcb       $00
                    fcb       $22
                    fcb       $E1
                    fcb       $C4
                    fcb       $0B
                    fcb       $0D
                    fcb       $00
                    fcb       $27
                    fcb       $E1
                    fcb       $C5
                    fcb       $0B
                    fcb       $0F
                    fcb       $00
                    fcb       $2C
                    fcb       $E1
                    fcb       $C6
                    fcb       $0B
                    fcb       $11
                    fcb       $FF
                    fcb       $C3
                    fcb       $DC
                    fcb       $65
                    fcb       $FF
                    fcc       "10 Seconds"
                    fcb       $00
                    fcc       "20 Seconds"
                    fcb       $00
                    fcc       "30 Seconds"
                    fcb       $00
                    fcc       "60 Seconds"
                    fcb       $00
L282F               fcb       $00
                    fcb       $04
                    fcb       $00
                    fcb       $0B
                    fcb       $E0
                    fcb       $68
                    fcb       $22
                    fcb       $04
                    fcb       $FE
                    fcb       $E9
                    fcb       $E0
                    fcb       $5C
                    fcb       $FF
                    fcc       "Quit"
                    fcb       $00
L2841               fcb       $06
                    fcb       $08
                    fcb       $00
                    fcb       $11
                    fcb       $DE
                    fcb       $92
                    fcb       $06
                    fcb       $0A
                    fcb       $00
                    fcb       $25
                    fcb       $DE
                    fcb       $90
                    fcb       $06
                    fcb       $0C
                    fcb       $FF
                    fcb       $72
                    fcb       $DC
                    fcb       $14
                    fcb       $FF
                    fcc       "Begin 5 minute tournament"
                    fcb       $00
                    fcc       "Begin 10 minute tournament"
                    fcb       $00
L2889               fcb       $00
                    fcb       $04
                    fcb       $FF
                    fcb       $B1
                    fcb       $DE
                    fcb       $DA
                    fcb       $00
                    fcb       $06
                    fcb       $FE
                    fcb       $85
                    fcb       $DE
                    fcb       $EC
                    fcb       $22
                    fcb       $04
                    fcb       $FE
                    fcb       $89
                    fcb       $DE
                    fcb       $F4
                    fcb       $FF
L289C               fcb       $1C
                    fcb       $15
                    fcb       $FF
                    fcb       $3F
                    fcb       $04
                    fcb       $09
                    fcb       $21
                    fcb       $15
                    fcb       $FF
                    fcb       $3D
                    fcb       $04
                    fcb       $15
                    fcb       $FF
L28A9               fcb       $00
                    fcb       $04
                    fcb       $FF
                    fcb       $91
                    fcb       $E0
                    fcb       $B3
                    fcb       $00
                    fcb       $06
                    fcb       $FE
                    fcb       $65
                    fcb       $E0
                    fcb       $B2
                    fcb       $FF
L28B6               pshs      U
                    stu       <U0018
                    clra
                    clrb
                    std       <U002E
L28BE               ldd       ,U++
                    blt       L28D3
                    bsr       L28D5
                    ldd       ,U
                    pshs      U
                    leau      D,U
                    lbsr      L0FA2
                    puls      U
                    leau      U0004,U
                    bra       L28BE
L28D3               puls      PC,U
L28D5               pshs      A
                    ldx       <U0053
                    pshs      B
L28DB               dec       ,S
                    blt       L28E5
                    leax      >X0500,X
                    bra       L28DB
L28E5               leas      1,S
                    puls      A
                    ldb       #4
                    mul
                    leax      D,X
                    rts
L28EF               pshs      A
                    ldx       <U0053
                    pshs      B
L28F5               dec       ,S
                    blt       L28FF
                    leax      >X05A0,X
                    bra       L28F5
L28FF               leas      1,S
                    puls      A
                    ldb       #4
                    mul
                    leax      D,X
                    rts
L2909               ldd       ,U
                    lblt      L29C5
                    pshs      A
                    lda       #8
                    mul
                    std       <U0046
                    addb      #8
                    std       <U0048
                    puls      A
                    ldb       #8
                    mul
                    std       <U0042
                    leax      U0002,U
                    ldd       U0002,U
                    leax      D,X
                    lda       #255
L2929               inca
                    tst       ,X+
                    bne       L2929
                    ldb       #8
                    mul
                    addd      <U0042
                    std       <U0044
                    ldd       <U0037
                    cmpd      <U0042
                    lbcs      L29C0
                    cmpd      <U0044
                    bhi       L29C0
                    ldb       <U0039
                    clra
                    cmpd      <U0046
                    bcs       L29C0
                    cmpd      <U0048
                    bhi       L29C0
                    ldd       <U002E
                    beq       L298A
                    pshs      U
                    cmpd      ,S++
                    bne       L295C
                    rts
L295C               pshs      U
                    ldu       <U002E
                    ldd       ,U++
                    lbsr      L28D5
                    ldd       ,U
                    leau      D,U
                    lbsr      L12BF
                    lbsr      L0FA2
                    lbsr      L115C
                    puls      U
                    stu       <U002E
                    ldd       ,U++
                    lbsr      L28D5
                    ldd       ,U
                    leau      D,U
                    inc       <U0041
                    lbsr      L12BF
                    lbsr      L0FA2
                    lbra      L115C
L298A               stu       <U002E
                    leau      >L2640,PC
                    cmpu      <U002E
                    bne       L299B
                    ldu       #2646
                    lbsr      L09E8
L299B               leau      >L263A,PC
                    cmpu      <U002E
                    bne       L29AA
                    ldu       #2662
                    lbsr      L09E8
L29AA               ldu       <U002E
                    ldd       ,U++
                    lbsr      L28D5
                    ldd       ,U
                    leau      D,U
                    inc       <U0041
                    lbsr      L12BF
                    lbsr      L0FA2
                    lbra      L115C
L29C0               leau      U0006,U
                    lbra      L2909
L29C5               ldd       <U002E
                    beq       L29E1
                    tfr       D,U
                    ldd       ,U++
                    lbsr      L28D5
                    ldd       ,U
                    leau      D,U
                    lbsr      L12BF
                    lbsr      L0FA2
                    lbsr      L115C
                    clra
                    clrb
                    std       <U002E
L29E1               rts
L29E2               ldd       <U002E
                    beq       L29F0
                    tfr       D,U
                    leau      U0004,U
                    ldd       ,U
                    leas      2,S
                    jmp       D,U
L29F0               rts
L29F1               inc       <U000A
                    ldx       <U0053
                    leax      >X0281,X
                    clrb
                    stb       >$FF5F,X
                    stb       >$FEBF,X
                    lda       #39
                    pshs      A
L2A06               dec       ,S
                    blt       L2A14
                    lbsr      L2A91
                    ldb       #35
                    lbsr      L0FDC
                    bra       L2A06
L2A14               puls      A
                    clrb
                    stb       >$FF60,X
                    stb       >$FEC0,X
                    ldx       <U0053
                    leax      >$6FE1,X
                    lda       #39
                    pshs      A
L2A29               dec       ,S
                    blt       L2A36
                    bsr       L2A91
                    ldb       #35
                    lbsr      L0FDC
                    bra       L2A29
L2A36               puls      A
                    clr       >X0500,X
                    clr       >X05A0,X
                    ldx       <U0053
                    leax      >X0281,X
                    lda       #23
                    pshs      A
L2A4A               dec       ,S
                    blt       L2A5B
                    bsr       L2A7F
                    ldb       #35
                    lbsr      L0FDC
                    leax      >X04FC,X
                    bra       L2A4A
L2A5B               puls      A
                    clrb
                    stb       -1,X
                    ldx       <U0053
                    leax      >X0319,X
                    lda       #23
                    pshs      A
L2A6A               dec       ,S
                    blt       L2A7B
                    bsr       L2A7F
                    ldb       #35
                    lbsr      L0FDC
                    leax      >X04FC,X
                    bra       L2A6A
L2A7B               clr       <U000A
                    puls      PC,A
L2A7F               pshs      X
                    ldd       #8
L2A84               sta       -1,X
                    sta       U0004,X
                    leax      >X00A0,X
                    decb
                    bne       L2A84
                    puls      PC,X
L2A91               clra
                    clrb
                    std       >$FEC0,X
                    std       >$FEC2,X
                    std       >$FF60,X
                    std       >$FF62,X
                    std       >X0500,X
                    std       >X0502,X
                    std       >X05A0,X
                    std       >X05A2,X
                    rts
L2AB4               stu       <U0018
                    lbsr      L29F1
L2AB9               ldu       <U0018
                    lbsr      L28B6
L2ABE               ldd       <U0033
                    addd      #1
                    std       <U0033
                    ldb       #1
                    lbsr      L0E2B
                    ldu       <U0018
                    lbsr      L2909
                    ldb       #1
                    lbsr      L107E
                    beq       L2ABE
                    lbsr      L29E2
                    bra       L2ABE
L2ADB               ldd       #5120
                    ldy       #2546
                    sty       <U0014
L2AE5               stb       ,Y+
                    deca
                    bne       L2AE5
                    ldd       #2546
                    clr       <U0016
                    ldd       #786
                    lbsr      L28D5
                    leau      >L2B75,PC
                    lbsr      L0FA2
                    ldd       #2067
                    lbsr      L28D5
                    leax      >X0140,X
                    ldb       #64
                    inc       <U0041
                    lbsr      L0FDC
                    clr       <U0041
                    leax      -4,X
L2B11               lbsr      L2B97
                    cmpb      #35
                    beq       L2B11
                    cmpb      #64
                    beq       L2B11
                    cmpb      #42
                    beq       L2B11
                    cmpb      #13
                    beq       L2B69
                    cmpb      #8
                    bne       L2B49
                    tst       <U0016
                    beq       L2B11
                    dec       <U0016
                    ldd       <U0014
                    subd      #1
                    std       <U0014
                    ldb       #32
                    lbsr      L0FDC
                    leax      -8,X
                    ldb       #64
                    inc       <U0041
                    lbsr      L0FDC
                    clr       <U0041
                    leax      -4,X
                    bra       L2B11
L2B49               lda       <U0016
                    cmpa      #19
                    bcc       L2B11
                    inc       <U0016
                    ldy       <U0014
                    stb       ,Y+
                    sty       <U0014
                    lbsr      L0FDC
                    inc       <U0041
                    ldb       #64
                    lbsr      L0FDC
                    clr       <U0041
                    leax      -4,X
                    bra       L2B11
L2B69               tst       <U0016
                    bne       L2B74
                    ldb       #45
                    stb       >U09F2
                    inc       <U0016
L2B74               rts
L2B75               fcc       "Type your name, then press enter:"
                    fcb       $00
L2B97               pshs      Y,X,A
                    leas      -1,S
                    leax      ,S
                    ldy       #1
                    clra
                    os9       I$Read
                    ldb       ,S+
                    puls      PC,Y,X,A
L2BA9               pshs      X,D
                    leax      >L2D3B,PC
                    lda       #1
                    os9       I$Open
                    bcs       L2BC5
                    ldx       #2306
                    ldy       #240
                    os9       I$Read
L2BC0               os9       I$Close
L2BC3               puls      PC,X,D
L2BC5               lda       #241
                    ldx       #2306
                    clrb
L2BCB               deca
                    beq       L2BD2
                    stb       ,X+
                    bra       L2BCB
L2BD2               leax      >L2D3B,PC
                    ldd       #795
                    os9       I$Create
                    bcs       L2BC3
                    ldx       #2306
                    ldy       #240
                    os9       I$Write
                    bra       L2BC0
L2BEA               pshs      U,Y,X,D
                    tst       <U004A
                    beq       L2C11
                    ldd       #8719
                    lbsr      L28D5
                    leax      >X0280,X
                    leau      >L2C13,PC
                    lbsr      L0FA2
                    ldd       #8976
                    lbsr      L28D5
                    leax      >X0320,X
                    ldb       <U0017
                    clra
                    lbsr      J12FE
L2C11               puls      PC,U,Y,X,D
L2C13               fcc       "Score"
                    fcb       $00
L2C19               lbsr      L0A7A
                    ldd       #2307
                    lbsr      L28D5
                    leau      >L2CC0,PC
                    lbsr      L0FA2
                    ldu       #2306
                    lda       #10
                    pshs      A
L2C30               dec       ,S
                    blt       L2C93
                    tst       ,U
                    beq       L2C64
                    ldd       #1032
                    subb      ,S
                    addb      #6
                    adda      #2
                    lbsr      L28EF
                    pshs      U
                    lbsr      L0FA2
                    ldd       #7688
                    subb      2,S
                    addb      #6
                    adda      #2
                    lbsr      L28EF
                    ldu       ,S
                    ldb       <$14,U
                    lbsr      J12FE
                    puls      U
                    leau      <$18,U
                    bra       L2C30
L2C64               ldd       #1032
                    subb      ,S
                    addb      #6
                    adda      #2
                    lbsr      L28EF
                    pshs      U
                    leau      >L2CBE,PC
                    lbsr      L0FA2
                    ldd       #7688
                    subb      2,S
                    addb      #6
                    adda      #2
                    lbsr      L28EF
                    leau      >L2CBE,PC
                    lbsr      L0FA2
                    puls      U
                    leau      <$18,U
                    bra       L2C30
L2C93               puls      A
                    ldd       #1045
                    lbsr      L28D5
                    leau      >L2CD6,PC
                    lbsr      L0FA2
                    leau      >L289C,PC
                    lbra      L2AB4
                    fcb       $17
                    fcb       $E6
                    fcb       $13
                    fcb       $DE
                    fcb       $18
                    fcb       $17
                    fcb       $FC
                    fcb       $05
                    fcb       $17
                    fcb       $FE
                    fcb       $27
                    fcb       $17
                    fcb       $E4
                    fcb       $A5
                    fcb       $86
                    fcb       $01
                    fcc       "M9OM9"
L2CBE               fcb       $2D
                    fcb       $00
L2CC0               fcc       "Tournament Scoreboard"
                    fcb       $00
L2CD6               fcc       "Continue tournament?"
                    fcb       $00
L2CEB               ldu       #2282
                    lda       #10
                    pshs      A
L2CF2               dec       ,S
                    blt       L2D21
                    leau      <$18,U
                    lda       <U0017
                    cmpa      <$14,U
                    bcs       L2CF2
                    bne       L2D1B
                    cmpa      #144
                    bne       L2D1B
                    lda       <U0025
                    cmpa      <$15,U
                    bcs       L2D1B
                    lda       <U0026
                    cmpa      <$16,U
                    bcs       L2D1B
                    lda       <U0023
                    cmpa      <$17,U
                    bhi       L2CF2
L2D1B               lda       ,S
                    bsr       L2D53
                    bsr       L2D7B
L2D21               leax      >L2D3B,PC
                    lda       #3
                    os9       I$Open
                    bcs       L2D39
                    ldx       #2306
                    ldy       #240
                    os9       I$Write
                    os9       I$Close
L2D39               puls      PC,A
L2D3B               fcc       "/DD/SYS/shanghai.scores"
                    fcb       $0D
L2D53               pshs      U,A
                    ldx       #2498
                    ldy       #2522
                    pshs      A
L2D5E               dec       ,S
                    blt       L2D77
                    lda       #24
                    pshs      Y,X
L2D66               ldb       ,X+
                    stb       ,Y+
                    deca
                    bne       L2D66
                    puls      Y,X
                    leax      <-$18,X
                    leay      <-$18,Y
                    bra       L2D5E
L2D77               puls      A
                    puls      PC,U,A
L2D7B               pshs      U
                    ldx       #2546
                    lda       <U0016
                    clr       A,X
L2D84               lda       ,X+
                    sta       ,U+
                    bne       L2D84
                    puls      U
                    lda       <U0017
                    sta       <$14,U
                    lda       <U0025
                    sta       <$15,U
                    lda       <U0026
                    sta       <$16,U
                    lda       <U0023
                    sta       <$17,U
                    rts
L2DA1               leau      >L2DB9,PC
                    ldx       <U0053
                    leax      >X10DC,X
L2DAB               lda       ,U+
                    cmpa      #187
                    beq       L2DB8
                    lbsr      L1015
                    leax      U0004,X
                    bra       L2DAB
L2DB8               rts
L2DB9               fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $FF
                    fcb       $FE
                    fcb       $0C
                    fcb       $03
                    fcb       $FF
                    fcb       $C0
                    fcb       $03
                    fcb       $FF
                    fcb       $C0
                    fcb       $00
                    fcb       $03
                    fcb       $C0
                    fcb       $00
                    fcb       $3F
                    fcb       $C0
                    fcb       $00
                    fcb       $03
                    fcb       $FF
                    fcb       $00
                    fcb       $00
                    fcb       $FF
                    fcb       $FF
                    fcb       $01
                    fcb       $87
                    fcb       $FF
                    fcb       $80
                    fcb       $07
                    fcb       $FF
                    fcb       $80
                    fcb       $00
                    fcb       $07
                    fcb       $80
                    fcb       $00
                    fcb       $07
                    fcb       $FF
                    fcb       $87
                    fcb       $50
                    fcb       $00
                    fcb       $00
                    fcb       $07
                    fcb       $F0
                    fcb       $1F
                    fcb       $FC
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $07
                    fcb       $E0
                    fcb       $00
                    fcb       $03
                    fcb       $F0
                    fcb       $00
                    fcb       $00
                    fcb       $30
                    fcb       $00
                    fcb       $0F
                    fcb       $C0
                    fcb       $03
                    fcb       $FF
                    fcb       $80
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $0F
                    fcb       $C0
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $02
                    fcb       $70
                    fcb       $00
                    fcb       $00
                    fcb       $1F
                    fcb       $00
                    fcb       $00
                    fcb       $FC
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $0F
                    fcb       $F0
                    fcb       $00
                    fcb       $00
                    fcb       $FC
                    fcb       $00
                    fcb       $00
                    fcb       $30
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $1F
                    fcb       $80
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $1F
                    fcb       $E0
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $02
                    fcb       $50
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $0C
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $1D
                    fcb       $F0
                    fcb       $00
                    fcb       $00
                    fcb       $3F
                    fcb       $00
                    fcb       $00
                    fcb       $30
                    fcb       $00
                    fcb       $F0
                    fcb       $00
                    fcb       $00
                    fcb       $01
                    fcb       $80
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $3D
                    fcb       $E0
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $0C
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $1C
                    fcb       $F8
                    fcb       $00
                    fcb       $00
                    fcb       $3F
                    fcb       $C0
                    fcb       $00
                    fcb       $30
                    fcb       $01
                    fcb       $C0
                    fcb       $00
                    fcb       $00
                    fcb       $01
                    fcb       $80
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $38
                    fcb       $F0
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $3E
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $38
                    fcb       $7C
                    fcb       $00
                    fcb       $00
                    fcb       $3F
                    fcb       $F0
                    fcb       $00
                    fcb       $30
                    fcb       $07
                    fcb       $80
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $70
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $3F
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $70
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $33
                    fcb       $FC
                    fcb       $00
                    fcb       $30
                    fcb       $0F
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $E0
                    fcb       $38
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $0F
                    fcb       $F8
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $70
                    fcb       $1E
                    fcb       $00
                    fcb       $00
                    fcb       $30
                    fcb       $FF
                    fcb       $00
                    fcb       $30
                    fcb       $1E
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $E0
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $03
                    fcb       $FF
                    fcb       $F0
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $E0
                    fcb       $0F
                    fcb       $00
                    fcb       $00
                    fcb       $30
                    fcb       $3F
                    fcb       $C0
                    fcb       $30
                    fcb       $1E
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $01
                    fcb       $C0
                    fcb       $1E
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $7F
                    fcb       $FF
                    fcb       $80
                    fcb       $00
                    fcb       $3F
                    fcb       $FF
                    fcb       $FF
                    fcb       $FC
                    fcb       $00
                    fcb       $01
                    fcb       $FF
                    fcb       $FF
                    fcb       $80
                    fcb       $00
                    fcb       $30
                    fcb       $0F
                    fcb       $F0
                    fcb       $30
                    fcb       $1E
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $7F
                    fcb       $FF
                    fcb       $FF
                    fcb       $F8
                    fcb       $00
                    fcb       $03
                    fcb       $FF
                    fcb       $FF
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $03
                    fcb       $FF
                    fcb       $F0
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $03
                    fcb       $80
                    fcb       $07
                    fcb       $C0
                    fcb       $00
                    fcb       $30
                    fcb       $03
                    fcb       $FC
                    fcb       $30
                    fcb       $1E
                    fcb       $00
                    fcb       $00
                    fcb       $01
                    fcb       $FF
                    fcb       $E0
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $07
                    fcb       $00
                    fcb       $0F
                    fcb       $80
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $1F
                    fcb       $F8
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $03
                    fcb       $00
                    fcb       $03
                    fcb       $C0
                    fcb       $00
                    fcb       $30
                    fcb       $00
                    fcb       $FF
                    fcb       $30
                    fcb       $1E
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $07
                    fcb       $80
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $06
                    fcb       $00
                    fcb       $07
                    fcb       $80
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $01
                    fcb       $FC
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $07
                    fcb       $00
                    fcb       $03
                    fcb       $E0
                    fcb       $00
                    fcb       $30
                    fcb       $00
                    fcb       $3F
                    fcb       $F0
                    fcb       $1F
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $07
                    fcb       $80
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $0E
                    fcb       $00
                    fcb       $07
                    fcb       $C0
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $7C
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $0E
                    fcb       $00
                    fcb       $01
                    fcb       $F0
                    fcb       $00
                    fcb       $30
                    fcb       $00
                    fcb       $0F
                    fcb       $F0
                    fcb       $0F
                    fcb       $80
                    fcb       $00
                    fcb       $00
                    fcb       $07
                    fcb       $80
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $1C
                    fcb       $00
                    fcb       $03
                    fcb       $E0
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $30
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $0C
                    fcb       $00
                    fcb       $00
                    fcb       $F0
                    fcb       $00
                    fcb       $30
                    fcb       $00
                    fcb       $03
                    fcb       $F0
                    fcb       $07
                    fcb       $E0
                    fcb       $00
                    fcb       $00
                    fcb       $07
                    fcb       $80
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $18
                    fcb       $00
                    fcb       $01
                    fcb       $E0
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $30
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $1C
                    fcb       $00
                    fcb       $00
                    fcb       $F8
                    fcb       $00
                    fcb       $30
                    fcb       $00
                    fcb       $00
                    fcb       $F0
                    fcb       $01
                    fcb       $F8
                    fcb       $00
                    fcb       $00
                    fcb       $0E
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $38
                    fcb       $00
                    fcb       $01
                    fcb       $F0
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $3F
                    fcb       $00
                    fcb       $00
                    fcb       $70
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $38
                    fcb       $00
                    fcb       $00
                    fcb       $7C
                    fcb       $00
                    fcb       $30
                    fcb       $00
                    fcb       $00
                    fcb       $70
                    fcb       $00
                    fcb       $7E
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $70
                    fcb       $00
                    fcb       $00
                    fcb       $F8
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $3F
                    fcb       $F0
                    fcb       $07
                    fcb       $E0
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $00
                    fcb       $3C
                    fcb       $00
                    fcb       $7C
                    fcb       $00
                    fcb       $00
                    fcb       $3E
                    fcb       $00
                    fcb       $30
                    fcb       $00
                    fcb       $00
                    fcb       $70
                    fcb       $00
                    fcb       $1F
                    fcb       $E0
                    fcb       $03
                    fcb       $F0
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $F8
                    fcb       $00
                    fcb       $00
                    fcb       $7C
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $30
                    fcb       $7F
                    fcb       $FF
                    fcb       $00
                    fcb       $03
                    fcb       $FF
                    fcb       $C0
                    fcb       $03
                    fcb       $FF
                    fcb       $C3
                    fcb       $FF
                    fcb       $E0
                    fcb       $0F
                    fcb       $FF
                    fcb       $C3
                    fcb       $FF
                    fcb       $00
                    fcb       $00
                    fcb       $30
                    fcb       $00
                    fcb       $03
                    fcb       $FF
                    fcb       $FF
                    fcb       $00
                    fcb       $07
                    fcb       $FF
                    fcb       $80
                    fcb       $07
                    fcb       $FF
                    fcb       $87
                    fcb       $FF
                    fcb       $80
                    fcb       $1F
                    fcb       $FF
                    fcb       $87
                    fcb       $FF
                    fcb       $80
                    fcb       $00
                    fcb       $BB
L30B2               fcb       $00
                    fcc       "$64$ "
                    fcb       $00
                    fcb       $34
                    fcb       $04
                    fcb       $20
                    fcb       $24
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $3F
                    fcb       $00
                    fcc       "$3#$"
                    fcb       $15
                    fcb       $00
                    fcb       $23
                    fcb       $05
                    fcb       $15
                    fcb       $24
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $3F
L30D2               fcb       $00
                    fcb       $0D
                    fcb       $88
                    fcb       $C2
                    fcb       $00
                    fcb       $9F
                    fcb       $BD
                    fcb       $C2
                    fcb       $00
                    fcb       $9E
                    fcb       $88
                    fcb       $BC
                    fcb       $C1
                    fcb       $00
                    fcb       $9E
                    fcb       $BE
                    fcb       $89
                    fcb       $BE
                    fcb       $00
                    fcb       $9D
                    fcb       $89
                    fcb       $80
                    fcb       $C3
                    fcb       $00
                    fcb       $9D
                    fcb       $87
                    fcb       $BE
                    fcb       $89
                    fcb       $C2
                    fcb       $00
                    fcb       $96
                    fcb       $B2
                    fcb       $BD
                    fcb       $C3
                    fcb       $BC
                    fcb       $AD
                    fcb       $00
                    fcb       $02
                    fcb       $BE
                    fcb       $80
                    fcb       $BD
                    fcb       $C1
                    fcb       $00
                    fcb       $97
                    fcb       $BC
                    fcb       $80
                    fcb       $BD
                    fcb       $C2
                    fcb       $AD
                    fcb       $C2
                    fcb       $80
                    fcb       $87
                    fcb       $B3
                    fcb       $C2
                    fcb       $B1
                    fcb       $87
                    fcb       $00
                    fcb       $95
                    fcb       $B4
                    fcb       $00
                    fcb       $02
                    fcb       $AD
                    fcb       $00
                    fcb       $03
                    fcb       $07
                    fcb       $02
                    fcb       $3C
                    fcb       $03
                    fcb       $00
                    fcb       $93
                    fcb       $87
                    fcb       $BE
                    fcb       $00
                    fcb       $03
                    fcb       $87
                    fcb       $31
                    fcb       $03
                    fcb       $B2
                    fcb       $43
                    fcb       $02
                    fcb       $B4
                    fcb       $BC
                    fcb       $00
                    fcb       $96
                    fcb       $B2
                    fcb       $AD
                    fcb       $80
                    fcb       $87
                    fcb       $BC
                    fcb       $43
                    fcb       $03
                    fcb       $C1
                    fcb       $B2
                    fcb       $B4
                    fcb       $BC
                    fcb       $00
                    fcb       $88
                    fcb       $AD
                    fcb       $80
                    fcb       $AD
                    fcb       $87
                    fcb       $80
                    fcb       $87
                    fcb       $AD
                    fcb       $BC
                    fcb       $C3
                    fcb       $BB
                    fcb       $80
                    fcb       $AD
                    fcb       $80
                    fcb       $B2
                    fcb       $80
                    fcb       $B2
                    fcb       $B4
                    fcb       $88
                    fcb       $B2
                    fcb       $43
                    fcb       $02
                    fcb       $C1
                    fcb       $80
                    fcb       $BD
                    fcb       $00
                    fcb       $8A
                    fcb       $B2
                    fcb       $BD
                    fcb       $43
                    fcb       $02
                    fcb       $BB
                    fcb       $87
                    fcb       $BC
                    fcb       $C3
                    fcb       $BB
                    fcb       $00
                    fcb       $02
                    fcb       $87
                    fcb       $B4
                    fcb       $AD
                    fcb       $00
                    fcb       $03
                    fcb       $BC
                    fcb       $BD
                    fcb       $C3
                    fcb       $C1
                    fcb       $BD
                    fcb       $BE
                    fcb       $00
                    fcb       $88
                    fcb       $B2
                    fcb       $BD
                    fcb       $C2
                    fcb       $BB
                    fcb       $AD
                    fcb       $00
                    fcb       $02
                    fcb       $B2
                    fcb       $BB
                    fcb       $BD
                    fcb       $BC
                    fcb       $AD
                    fcb       $80
                    fcb       $87
                    fcb       $80
                    fcb       $AD
                    fcb       $00
                    fcb       $03
                    fcb       $89
                    fcb       $43
                    fcb       $02
                    fcb       $B3
                    fcb       $C2
                    fcb       $B4
                    fcb       $00
                    fcb       $86
                    fcb       $87
                    fcb       $BD
                    fcb       $C2
                    fcb       $00
                    fcb       $05
                    fcb       $B2
                    fcb       $BE
                    fcb       $87
                    fcb       $B2
                    fcb       $C3
                    fcb       $B4
                    fcb       $88
                    fcb       $B4
                    fcb       $88
                    fcb       $B4
                    fcb       $00
                    fcb       $04
                    fcb       $43
                    fcb       $03
                    fcb       $B4
                    fcb       $00
                    fcb       $86
                    fcb       $B2
                    fcb       $C2
                    fcb       $AD
                    fcb       $00
                    fcb       $05
                    fcb       $B2
                    fcb       $C2
                    fcb       $80
                    fcb       $87
                    fcb       $BD
                    fcb       $C2
                    fcb       $88
                    fcb       $09
                    fcb       $02
                    fcb       $AD
                    fcb       $00
                    fcb       $03
                    fcb       $87
                    fcb       $80
                    fcb       $43
                    fcb       $03
                    fcb       $AD
                    fcb       $00
                    fcb       $85
                    fcb       $BD
                    fcb       $BB
                    fcb       $88
                    fcb       $00
                    fcb       $05
                    fcb       $87
                    fcb       $BD
                    fcb       $B4
                    fcb       $80
                    fcb       $B2
                    fcb       $C3
                    fcb       $B4
                    fcb       $C3
                    fcb       $BD
                    fcb       $BE
                    fcb       $80
                    fcb       $AC
                    fcb       $00
                    fcb       $02
                    fcb       $B4
                    fcb       $AD
                    fcb       $BD
                    fcb       $C3
                    fcb       $34
                    fcb       $02
                    fcb       $00
                    fcb       $84
                    fcb       $C2
                    fcb       $B4
                    fcb       $BC
                    fcb       $88
                    fcb       $B4
                    fcb       $00
                    fcb       $04
                    fcb       $B3
                    fcb       $BE
                    fcb       $80
                    fcb       $B1
                    fcb       $C3
                    fcb       $C2
                    fcb       $43
                    fcb       $02
                    fcb       $BD
                    fcb       $80
                    fcb       $84
                    fcb       $9A
                    fcb       $00
                    fcb       $02
                    fcb       $C1
                    fcb       $80
                    fcb       $BD
                    fcb       $B1
                    fcb       $BE
                    fcb       $00
                    fcb       $83
                    fcb       $89
                    fcb       $BC
                    fcb       $B1
                    fcb       $B4
                    fcb       $3C
                    fcb       $03
                    fcb       $00
                    fcb       $03
                    fcb       $87
                    fcb       $C2
                    fcb       $80
                    fcb       $AD
                    fcb       $BD
                    fcb       $43
                    fcb       $03
                    fcb       $C2
                    fcb       $87
                    fcb       $80
                    fcb       $AC
                    fcb       $9E
                    fcb       $00
                    fcb       $03
                    fcb       $B3
                    fcb       $C3
                    fcb       $C2
                    fcb       $00
                    fcb       $83
                    fcb       $BC
                    fcb       $B1
                    fcb       $B2
                    fcb       $AD
                    fcb       $00
                    fcb       $06
                    fcb       $87
                    fcb       $C3
                    fcb       $80
                    fcb       $B1
                    fcb       $B3
                    fcb       $C3
                    fcb       $C2
                    fcb       $C3
                    fcb       $C2
                    fcb       $C1
                    fcb       $BE
                    fcb       $80
                    fcb       $87
                    fcb       $AD
                    fcb       $00
                    fcb       $02
                    fcb       $89
                    fcb       $C3
                    fcb       $BC
                    fcb       $C2
                    fcb       $00
                    fcb       $82
                    fcb       $B4
                    fcb       $80
                    fcb       $87
                    fcb       $00
                    fcb       $03
                    fcb       $07
                    fcb       $02
                    fcb       $00
                    fcb       $02
                    fcb       $87
                    fcb       $C2
                    fcb       $80
                    fcb       $88
                    fcb       $BC
                    fcb       $43
                    fcb       $02
                    fcb       $B2
                    fcb       $43
                    fcb       $02
                    fcb       $C2
                    fcb       $00
                    fcb       $05
                    fcb       $88
                    fcb       $C3
                    fcb       $BE
                    fcb       $BD
                    fcb       $C3
                    fcb       $BB
                    fcb       $00
                    fcb       $83
                    fcb       $AD
                    fcb       $89
                    fcb       $B4
                    fcb       $00
                    fcb       $04
                    fcb       $87
                    fcb       $C1
                    fcb       $80
                    fcb       $89
                    fcb       $C2
                    fcb       $43
                    fcb       $02
                    fcb       $C2
                    fcb       $B2
                    fcb       $C2
                    fcb       $C3
                    fcb       $C2
                    fcb       $B2
                    fcb       $80
                    fcb       $88
                    fcb       $B4
                    fcb       $B2
                    fcb       $43
                    fcb       $05
                    fcb       $B4
                    fcb       $00
                    fcb       $82
                    fcb       $89
                    fcb       $80
                    fcb       $C3
                    fcb       $00
                    fcb       $04
                    fcb       $87
                    fcb       $BD
                    fcb       $80
                    fcb       $BC
                    fcb       $BD
                    fcb       $C3
                    fcb       $89
                    fcb       $C3
                    fcb       $C1
                    fcb       $B2
                    fcb       $C2
                    fcb       $BD
                    fcb       $BC
                    fcb       $B2
                    fcb       $3C
                    fcb       $02
                    fcb       $80
                    fcb       $89
                    fcb       $43
                    fcb       $03
                    fcb       $C2
                    fcb       $C1
                    fcb       $00
                    fcb       $04
                    fcb       $BC
                    fcb       $00
                    fcb       $7A
                    fcb       $87
                    fcb       $00
                    fcb       $02
                    fcb       $88
                    fcb       $BE
                    fcb       $C3
                    fcb       $80
                    fcb       $87
                    fcb       $AD
                    fcb       $00
                    fcb       $02
                    fcb       $B2
                    fcb       $C3
                    fcb       $B4
                    fcb       $B2
                    fcb       $C3
                    fcb       $88
                    fcb       $89
                    fcb       $C3
                    fcb       $BB
                    fcb       $BC
                    fcb       $43
                    fcb       $05
                    fcb       $B4
                    fcb       $B3
                    fcb       $43
                    fcb       $03
                    fcb       $C1
                    fcb       $C3
                    fcb       $BB
                    fcb       $00
                    fcb       $03
                    fcb       $BD
                    fcb       $00
                    fcb       $7D
                    fcb       $88
                    fcb       $BE
                    fcb       $C3
                    fcb       $00
                    fcb       $03
                    fcb       $AD
                    fcb       $80
                    fcb       $87
                    fcb       $B1
                    fcb       $87
                    fcb       $BD
                    fcb       $C2
                    fcb       $C3
                    fcb       $88
                    fcb       $43
                    fcb       $02
                    fcb       $C2
                    fcb       $3C
                    fcb       $02
                    fcb       $C3
                    fcb       $BC
                    fcb       $BD
                    fcb       $C2
                    fcb       $B2
                    fcb       $C3
                    fcb       $BB
                    fcb       $AD
                    fcb       $BD
                    fcb       $43
                    fcb       $02
                    fcb       $BC
                    fcb       $B4
                    fcb       $80
                    fcb       $BD
                    fcb       $BE
                    fcb       $00
                    fcb       $7C
                    fcb       $87
                    fcb       $BE
                    fcb       $C3
                    fcb       $00
                    fcb       $07
                    fcb       $B2
                    fcb       $C2
                    fcb       $C3
                    fcb       $89
                    fcb       $B4
                    fcb       $89
                    fcb       $43
                    fcb       $02
                    fcb       $AD
                    fcb       $32
                    fcb       $02
                    fcb       $80
                    fcb       $87
                    fcb       $AD
                    fcb       $80
                    fcb       $BD
                    fcb       $C1
                    fcb       $80
                    fcb       $BD
                    fcb       $43
                    fcb       $03
                    fcb       $C2
                    fcb       $BB
                    fcb       $B3
                    fcb       $C2
                    fcb       $B4
                    fcb       $00
                    fcb       $7C
                    fcb       $B4
                    fcb       $C3
                    fcb       $BB
                    fcb       $80
                    fcb       $2D
                    fcb       $02
                    fcb       $80
                    fcb       $B1
                    fcb       $80
                    fcb       $B3
                    fcb       $43
                    fcb       $02
                    fcb       $B4
                    fcb       $C2
                    fcb       $80
                    fcb       $C3
                    fcb       $BC
                    fcb       $B1
                    fcb       $00
                    fcb       $02
                    fcb       $B2
                    fcb       $AD
                    fcb       $BC
                    fcb       $B4
                    fcb       $88
                    fcb       $C3
                    fcb       $C2
                    fcb       $43
                    fcb       $05
                    fcb       $42
                    fcb       $02
                    fcb       $C3
                    fcb       $B4
                    fcb       $87
                    fcb       $BC
                    fcb       $C2
                    fcb       $BB
                    fcb       $00
                    fcb       $78
                    fcb       $88
                    fcb       $C3
                    fcb       $88
                    fcb       $BC
                    fcb       $87
                    fcb       $BC
                    fcb       $00
                    fcb       $02
                    fcb       $AD
                    fcb       $B3
                    fcb       $BD
                    fcb       $C2
                    fcb       $80
                    fcb       $BD
                    fcb       $C1
                    fcb       $BD
                    fcb       $BE
                    fcb       $80
                    fcb       $87
                    fcb       $BC
                    fcb       $43
                    fcb       $04
                    fcb       $B4
                    fcb       $88
                    fcb       $C3
                    fcb       $C2
                    fcb       $BD
                    fcb       $43
                    fcb       $02
                    fcb       $C2
                    fcb       $89
                    fcb       $C3
                    fcb       $C1
                    fcb       $00
                    fcb       $03
                    fcb       $BD
                    fcb       $C2
                    fcb       $00
                    fcb       $78
                    fcb       $89
                    fcb       $C2
                    fcb       $3C
                    fcb       $03
                    fcb       $BB
                    fcb       $00
                    fcb       $03
                    fcb       $B2
                    fcb       $C1
                    fcb       $AD
                    fcb       $43
                    fcb       $04
                    fcb       $BC
                    fcb       $87
                    fcb       $BD
                    fcb       $43
                    fcb       $06
                    fcb       $B4
                    fcb       $00
                    fcb       $02
                    fcb       $87
                    fcb       $B2
                    fcb       $B4
                    fcb       $BD
                    fcb       $43
                    fcb       $02
                    fcb       $80
                    fcb       $BD
                    fcb       $C3
                    fcb       $C2
                    fcb       $80
                    fcb       $C2
                    fcb       $AD
                    fcb       $00
                    fcb       $77
                    fcb       $C3
                    fcb       $BE
                    fcb       $88
                    fcb       $3C
                    fcb       $02
                    fcb       $B1
                    fcb       $00
                    fcb       $03
                    fcb       $87
                    fcb       $BD
                    fcb       $BC
                    fcb       $43
                    fcb       $03
                    fcb       $BD
                    fcb       $C1
                    fcb       $88
                    fcb       $43
                    fcb       $02
                    fcb       $3C
                    fcb       $04
                    fcb       $BD
                    fcb       $C3
                    fcb       $C2
                    fcb       $BB
                    fcb       $80
                    fcb       $88
                    fcb       $C2
                    fcb       $43
                    fcb       $02
                    fcb       $B4
                    fcb       $BD
                    fcb       $C3
                    fcb       $BC
                    fcb       $C3
                    fcb       $87
                    fcb       $C2
                    fcb       $BB
                    fcb       $00
                    fcb       $76
                    fcb       $88
                    fcb       $C3
                    fcb       $B4
                    fcb       $3C
                    fcb       $02
                    fcb       $BB
                    fcb       $B4
                    fcb       $00
                    fcb       $04
                    fcb       $87
                    fcb       $BD
                    fcb       $43
                    fcb       $03
                    fcb       $C2
                    fcb       $80
                    fcb       $88
                    fcb       $C2
                    fcb       $BB
                    fcb       $AD
                    fcb       $00
                    fcb       $02
                    fcb       $87
                    fcb       $B2
                    fcb       $BD
                    fcb       $43
                    fcb       $02
                    fcb       $C2
                    fcb       $00
                    fcb       $02
                    fcb       $BC
                    fcb       $BD
                    fcb       $88
                    fcb       $C2
                    fcb       $AD
                    fcb       $80
                    fcb       $89
                    fcb       $80
                    fcb       $C3
                    fcb       $C2
                    fcb       $AD
                    fcb       $00
                    fcb       $75
                    fcb       $BD
                    fcb       $C1
                    fcb       $87
                    fcb       $3C
                    fcb       $03
                    fcb       $B4
                    fcb       $00
                    fcb       $05
                    fcb       $87
                    fcb       $B2
                    fcb       $BD
                    fcb       $C3
                    fcb       $BE
                    fcb       $87
                    fcb       $BD
                    fcb       $B4
                    fcb       $88
                    fcb       $31
                    fcb       $03
                    fcb       $00
                    fcb       $02
                    fcb       $87
                    fcb       $BD
                    fcb       $43
                    fcb       $02
                    fcb       $C2
                    fcb       $00
                    fcb       $02
                    fcb       $88
                    fcb       $C3
                    fcb       $AD
                    fcb       $B3
                    fcb       $BC
                    fcb       $BD
                    fcb       $BE
                    fcb       $BD
                    fcb       $C3
                    fcb       $B4
                    fcb       $00
                    fcb       $75
                    fcb       $C3
                    fcb       $AD
                    fcb       $B2
                    fcb       $BC
                    fcb       $BB
                    fcb       $88
                    fcb       $AD
                    fcb       $00
                    fcb       $06
                    fcb       $87
                    fcb       $BD
                    fcb       $89
                    fcb       $BB
                    fcb       $87
                    fcb       $BD
                    fcb       $B4
                    fcb       $BC
                    fcb       $BD
                    fcb       $BC
                    fcb       $AD
                    fcb       $81
                    fcb       $00
                    fcb       $03
                    fcb       $B3
                    fcb       $43
                    fcb       $02
                    fcb       $BC
                    fcb       $B4
                    fcb       $80
                    fcb       $BD
                    fcb       $80
                    fcb       $BD
                    fcb       $43
                    fcb       $05
                    fcb       $B4
                    fcb       $00
                    fcb       $74
                    fcb       $89
                    fcb       $C2
                    fcb       $80
                    fcb       $B2
                    fcb       $BC
                    fcb       $B4
                    fcb       $00
                    fcb       $09
                    fcb       $B2
                    fcb       $BB
                    fcb       $88
                    fcb       $AD
                    fcb       $BD
                    fcb       $C2
                    fcb       $C1
                    fcb       $33
                    fcb       $02
                    fcb       $AD
                    fcb       $80
                    fcb       $A4
                    fcb       $00
                    fcb       $03
                    fcb       $B3
                    fcb       $43
                    fcb       $03
                    fcb       $B4
                    fcb       $BD
                    fcb       $B4
                    fcb       $87
                    fcb       $43
                    fcb       $03
                    fcb       $42
                    fcb       $02
                    fcb       $AD
                    fcb       $00
                    fcb       $74
                    fcb       $BD
                    fcb       $34
                    fcb       $02
                    fcb       $B2
                    fcb       $BC
                    fcb       $BB
                    fcb       $88
                    fcb       $00
                    fcb       $0A
                    fcb       $88
                    fcb       $C2
                    fcb       $88
                    fcb       $C2
                    fcb       $AD
                    fcb       $87
                    fcb       $C3
                    fcb       $BB
                    fcb       $81
                    fcb       $B0
                    fcb       $A4
                    fcb       $00
                    fcb       $03
                    fcb       $B2
                    fcb       $43
                    fcb       $02
                    fcb       $C2
                    fcb       $43
                    fcb       $06
                    fcb       $BC
                    fcb       $B4
                    fcb       $AD
                    fcb       $00
                    fcb       $73
                    fcb       $87
                    fcb       $C3
                    fcb       $88
                    fcb       $B4
                    fcb       $88
                    fcb       $BC
                    fcb       $BB
                    fcb       $88
                    fcb       $80
                    fcb       $87
                    fcb       $00
                    fcb       $0A
                    fcb       $BD
                    fcb       $C3
                    fcb       $BB
                    fcb       $80
                    fcb       $BD
                    fcb       $BB
                    fcb       $B0
                    fcb       $80
                    fcb       $AF
                    fcb       $A1
                    fcb       $00
                    fcb       $03
                    fcb       $87
                    fcb       $3C
                    fcb       $04
                    fcb       $C3
                    fcb       $C2
                    fcb       $C3
                    fcb       $BB
                    fcb       $87
                    fcb       $B4
                    fcb       $00
                    fcb       $74
                    fcb       $88
                    fcb       $C2
                    fcb       $88
                    fcb       $AD
                    fcb       $B2
                    fcb       $3C
                    fcb       $02
                    fcb       $88
                    fcb       $B4
                    fcb       $B2
                    fcb       $AD
                    fcb       $00
                    fcb       $09
                    fcb       $88
                    fcb       $43
                    fcb       $02
                    fcb       $C2
                    fcb       $87
                    fcb       $C2
                    fcb       $80
                    fcb       $29
                    fcb       $02
                    fcb       $A8
                    fcb       $9B
                    fcb       $9A
                    fcb       $00
                    fcb       $02
                    fcb       $87
                    fcb       $31
                    fcb       $03
                    fcb       $3C
                    fcb       $02
                    fcb       $BB
                    fcb       $80
                    fcb       $AD
                    fcb       $87
                    fcb       $00
                    fcb       $74
                    fcb       $B3
                    fcb       $BE
                    fcb       $B1
                    fcb       $80
                    fcb       $3C
                    fcb       $03
                    fcb       $88
                    fcb       $B4
                    fcb       $BD
                    fcb       $BB
                    fcb       $00
                    fcb       $0B
                    fcb       $BD
                    fcb       $C3
                    fcb       $B1
                    fcb       $B3
                    fcb       $AD
                    fcb       $A1
                    fcb       $A5
                    fcb       $97
                    fcb       $A1
                    fcb       $A5
                    fcb       $97
                    fcb       $00
                    fcb       $04
                    fcb       $87
                    fcb       $AD
                    fcb       $80
                    fcb       $AD
                    fcb       $00
                    fcb       $02
                    fcb       $AD
                    fcb       $00
                    fcb       $74
                    fcb       $BD
                    fcb       $BE
                    fcb       $BB
                    fcb       $80
                    fcb       $3C
                    fcb       $03
                    fcb       $B2
                    fcb       $BB
                    fcb       $C3
                    fcb       $C2
                    fcb       $AD
                    fcb       $80
                    fcb       $AD
                    fcb       $00
                    fcb       $09
                    fcb       $BD
                    fcb       $C1
                    fcb       $3B
                    fcb       $02
                    fcb       $80
                    fcb       $A2
                    fcb       $A4
                    fcb       $91
                    fcb       $8D
                    fcb       $A4
                    fcb       $91
                    fcb       $8A
                    fcb       $00
                    fcb       $03
                    fcb       $88
                    fcb       $00
                    fcb       $03
                    fcb       $87
                    fcb       $80
                    fcb       $87
                    fcb       $00
                    fcb       $72
                    fcb       $87
                    fcb       $BD
                    fcb       $AD
                    fcb       $00
                    fcb       $02
                    fcb       $3C
                    fcb       $04
                    fcb       $B4
                    fcb       $BD
                    fcb       $C3
                    fcb       $C2
                    fcb       $AD
                    fcb       $B2
                    fcb       $AD
                    fcb       $00
                    fcb       $09
                    fcb       $BD
                    fcb       $BC
                    fcb       $B1
                    fcb       $80
                    fcb       $AE
                    fcb       $9C
                    fcb       $A1
                    fcb       $B5
                    fcb       $BC
                    fcb       $A1
                    fcb       $B5
                    fcb       $BC
                    fcb       $00
                    fcb       $02
                    fcb       $88
                    fcb       $00
                    fcb       $78
                    fcb       $87
                    fcb       $C3
                    fcb       $87
                    fcb       $00
                    fcb       $02
                    fcb       $3C
                    fcb       $04
                    fcb       $B4
                    fcb       $BD
                    fcb       $43
                    fcb       $02
                    fcb       $C2
                    fcb       $B1
                    fcb       $BC
                    fcb       $00
                    fcb       $0A
                    fcb       $BD
                    fcb       $C3
                    fcb       $B4
                    fcb       $80
                    fcb       $C0
                    fcb       $9E
                    fcb       $9B
                    fcb       $9E
                    fcb       $BA
                    fcb       $B8
                    fcb       $9E
                    fcb       $BA
                    fcb       $B4
                    fcb       $A4
                    fcb       $00
                    fcb       $78
                    fcb       $87
                    fcb       $C2
                    fcb       $00
                    fcb       $03
                    fcb       $3C
                    fcb       $05
                    fcb       $89
                    fcb       $43
                    fcb       $03
                    fcb       $C2
                    fcb       $B2
                    fcb       $AD
                    fcb       $00
                    fcb       $09
                    fcb       $88
                    fcb       $BD
                    fcb       $C2
                    fcb       $80
                    fcb       $B2
                    fcb       $A5
                    fcb       $95
                    fcb       $B7
                    fcb       $97
                    fcb       $B5
                    fcb       $B7
                    fcb       $97
                    fcb       $B4
                    fcb       $A8
                    fcb       $A4
                    fcb       $00
                    fcb       $77
                    fcb       $87
                    fcb       $C2
                    fcb       $00
                    fcb       $03
                    fcb       $B2
                    fcb       $3C
                    fcb       $04
                    fcb       $88
                    fcb       $C3
                    fcb       $B3
                    fcb       $43
                    fcb       $02
                    fcb       $87
                    fcb       $BB
                    fcb       $00
                    fcb       $0A
                    fcb       $BC
                    fcb       $C3
                    fcb       $B4
                    fcb       $80
                    fcb       $86
                    fcb       $A0
                    fcb       $93
                    fcb       $AA
                    fcb       $91
                    fcb       $93
                    fcb       $AA
                    fcb       $91
                    fcb       $8D
                    fcb       $A7
                    fcb       $A1
                    fcb       $A8
                    fcb       $00
                    fcb       $75
                    fcb       $87
                    fcb       $BE
                    fcb       $00
                    fcb       $03
                    fcb       $88
                    fcb       $3C
                    fcb       $04
                    fcb       $B4
                    fcb       $89
                    fcb       $87
                    fcb       $43
                    fcb       $02
                    fcb       $C1
                    fcb       $BD
                    fcb       $AD
                    fcb       $00
                    fcb       $09
                    fcb       $87
                    fcb       $BD
                    fcb       $C3
                    fcb       $BB
                    fcb       $00
                    fcb       $02
                    fcb       $9A
                    fcb       $82
                    fcb       $84
                    fcb       $9B
                    fcb       $8B
                    fcb       $BA
                    fcb       $BF
                    fcb       $9F
                    fcb       $9E
                    fcb       $9B
                    fcb       $00
                    fcb       $75
                    fcb       $87
                    fcb       $BE
                    fcb       $00
                    fcb       $02
                    fcb       $AD
                    fcb       $88
                    fcb       $3C
                    fcb       $04
                    fcb       $B4
                    fcb       $BD
                    fcb       $B4
                    fcb       $89
                    fcb       $43
                    fcb       $03
                    fcb       $BB
                    fcb       $AD
                    fcb       $00
                    fcb       $09
                    fcb       $88
                    fcb       $43
                    fcb       $02
                    fcb       $AD
                    fcb       $00
                    fcb       $03
                    fcb       $85
                    fcb       $A2
                    fcb       $97
                    fcb       $98
                    fcb       $A1
                    fcb       $A6
                    fcb       $9B
                    fcb       $AB
                    fcb       $A5
                    fcb       $94
                    fcb       $00
                    fcb       $73
                    fcb       $87
                    fcb       $BE
                    fcb       $80
                    fcb       $87
                    fcb       $AD
                    fcb       $87
                    fcb       $3C
                    fcb       $06
                    fcb       $C2
                    fcb       $80
                    fcb       $BD
                    fcb       $C3
                    fcb       $BD
                    fcb       $C3
                    fcb       $B1
                    fcb       $00
                    fcb       $09
                    fcb       $87
                    fcb       $BB
                    fcb       $C3
                    fcb       $C1
                    fcb       $88
                    fcb       $80
                    fcb       $B4
                    fcb       $8C
                    fcb       $85
                    fcb       $A8
                    fcb       $82
                    fcb       $90
                    fcb       $8B
                    fcb       $A8
                    fcb       $8D
                    fcb       $A8
                    fcb       $A4
                    fcb       $00
                    fcb       $73
                    fcb       $87
                    fcb       $BE
                    fcb       $80
                    fcb       $88
                    fcb       $00
                    fcb       $02
                    fcb       $BB
                    fcb       $3C
                    fcb       $04
                    fcb       $87
                    fcb       $BC
                    fcb       $B4
                    fcb       $BC
                    fcb       $C1
                    fcb       $88
                    fcb       $C3
                    fcb       $C2
                    fcb       $AD
                    fcb       $00
                    fcb       $09
                    fcb       $87
                    fcb       $88
                    fcb       $C3
                    fcb       $34
                    fcb       $02
                    fcb       $80
                    fcb       $86
                    fcb       $A9
                    fcb       $9B
                    fcb       $A1
                    fcb       $A3
                    fcb       $8F
                    fcb       $B9
                    fcb       $8B
                    fcb       $A4
                    fcb       $80
                    fcb       $9D
                    fcb       $00
                    fcb       $72
                    fcb       $87
                    fcb       $BB
                    fcb       $80
                    fcb       $B4
                    fcb       $00
                    fcb       $02
                    fcb       $B1
                    fcb       $3C
                    fcb       $04
                    fcb       $B4
                    fcb       $80
                    fcb       $BD
                    fcb       $C2
                    fcb       $89
                    fcb       $80
                    fcb       $BD
                    fcb       $C3
                    fcb       $C1
                    fcb       $00
                    fcb       $09
                    fcb       $87
                    fcb       $B4
                    fcb       $BD
                    fcb       $C2
                    fcb       $AD
                    fcb       $00
                    fcb       $03
                    fcb       $C3
                    fcb       $9B
                    fcb       $B8
                    fcb       $9B
                    fcb       $BC
                    fcb       $AA
                    fcb       $8D
                    fcb       $80
                    fcb       $83
                    fcb       $96
                    fcb       $00
                    fcb       $72
                    fcb       $BB
                    fcb       $87
                    fcb       $AD
                    fcb       $00
                    fcb       $02
                    fcb       $87
                    fcb       $3C
                    fcb       $05
                    fcb       $88
                    fcb       $43
                    fcb       $02
                    fcb       $B4
                    fcb       $BE
                    fcb       $88
                    fcb       $43
                    fcb       $02
                    fcb       $AD
                    fcb       $00
                    fcb       $09
                    fcb       $BC
                    fcb       $88
                    fcb       $43
                    fcb       $02
                    fcb       $BC
                    fcb       $AD
                    fcb       $B4
                    fcb       $88
                    fcb       $87
                    fcb       $97
                    fcb       $8F
                    fcb       $97
                    fcb       $99
                    fcb       $0B
                    fcb       $02
                    fcb       $00
                    fcb       $74
                    fcb       $08
                    fcb       $02
                    fcb       $00
                    fcb       $04
                    fcb       $B2
                    fcb       $3C
                    fcb       $04
                    fcb       $88
                    fcb       $43
                    fcb       $03
                    fcb       $B3
                    fcb       $AD
                    fcb       $C3
                    fcb       $B2
                    fcb       $C2
                    fcb       $00
                    fcb       $09
                    fcb       $B2
                    fcb       $88
                    fcb       $C2
                    fcb       $88
                    fcb       $C3
                    fcb       $C1
                    fcb       $AD
                    fcb       $B4
                    fcb       $86
                    fcb       $A1
                    fcb       $91
                    fcb       $86
                    fcb       $B6
                    fcb       $92
                    fcb       $8B
                    fcb       $A6
                    fcb       $00
                    fcb       $73
                    fcb       $88
                    fcb       $00
                    fcb       $04
                    fcb       $B4
                    fcb       $AD
                    fcb       $3C
                    fcb       $04
                    fcb       $B4
                    fcb       $BD
                    fcb       $43
                    fcb       $02
                    fcb       $BD
                    fcb       $BE
                    fcb       $BD
                    fcb       $C2
                    fcb       $89
                    fcb       $BE
                    fcb       $00
                    fcb       $08
                    fcb       $88
                    fcb       $C3
                    fcb       $C2
                    fcb       $B4
                    fcb       $B2
                    fcb       $C3
                    fcb       $AD
                    fcb       $00
                    fcb       $05
                    fcb       $BA
                    fcb       $A4
                    fcb       $81
                    fcb       $8E
                    fcb       $BE
                    fcb       $00
                    fcb       $72
                    fcb       $88
                    fcb       $00
                    fcb       $04
                    fcb       $C2
                    fcb       $B4
                    fcb       $3C
                    fcb       $05
                    fcb       $B3
                    fcb       $43
                    fcb       $02
                    fcb       $BE
                    fcb       $C3
                    fcb       $88
                    fcb       $C3
                    fcb       $B4
                    fcb       $BD
                    fcb       $AD
                    fcb       $00
                    fcb       $07
                    fcb       $88
                    fcb       $3B
                    fcb       $02
                    fcb       $80
                    fcb       $87
                    fcb       $BC
                    fcb       $C2
                    fcb       $00
                    fcb       $06
                    fcb       $24
                    fcb       $02
                    fcb       $A1
                    fcb       $9B
                    fcb       $00
                    fcb       $73
                    fcb       $B4
                    fcb       $00
                    fcb       $03
                    fcb       $C2
                    fcb       $BC
                    fcb       $88
                    fcb       $3C
                    fcb       $03
                    fcb       $BB
                    fcb       $BC
                    fcb       $43
                    fcb       $02
                    fcb       $C2
                    fcb       $BD
                    fcb       $B4
                    fcb       $BD
                    fcb       $C2
                    fcb       $87
                    fcb       $C3
                    fcb       $AD
                    fcb       $00
                    fcb       $06
                    fcb       $87
                    fcb       $C2
                    fcb       $B3
                    fcb       $BC
                    fcb       $AD
                    fcb       $B1
                    fcb       $BD
                    fcb       $B4
                    fcb       $00
                    fcb       $80
                    fcb       $BE
                    fcb       $88
                    fcb       $B4
                    fcb       $3C
                    fcb       $04
                    fcb       $B4
                    fcb       $B3
                    fcb       $43
                    fcb       $02
                    fcb       $89
                    fcb       $BE
                    fcb       $BD
                    fcb       $C3
                    fcb       $B4
                    fcb       $89
                    fcb       $C1
                    fcb       $00
                    fcb       $06
                    fcb       $87
                    fcb       $BB
                    fcb       $FF

                    emod
eom                 equ       *
                    end
