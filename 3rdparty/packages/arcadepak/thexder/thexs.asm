* Patched 05/14/2019 for 2 MB RAM systems by LCB

                    nam       ThexS
                    ttl       subroutine module

* Disassembled 2019/05/12 00:50:46 by Disasm v1.5 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       $01
L0000               mod       eom,name,tylg,atrv,start,size

* Since subroutine module, it is sharing it's memory map with the main
* THEXDER program
* Data mem locations from THEXDER referenced in THEXS:
NewWPath            equ       $1FC3               path # to newly allocated window
Speed               equ       $1FC4               16 bit speed setting (Defaults to 3)
Immortal            equ       $1FCC               Immortal player flag (0=no)
StLevel             equ       $1FCD               Start Level #

u0004               equ       $04                 DP <u0004 (I think data mem ptr?)
u0006               equ       $06                 DP <u0006
u0008               equ       $08                 DP <u0008
*
u0000               rmb       0
size                equ       .

name                equ       *
                    fcs       /ThexS/
* Edition
                    fcb       $02

* Special font
L0013               fcc       '/dd/sys/ia.fnt'
                    fcb       C$CR,C$CR,C$CR

* Select Font esc sequence for IA.FNT (buffer $AD - Alan's initials)
L0024               fcb       $1B,$3A,$C8,$AD


* Wildcard window descriptor (find next available)
L0028               fcc       '/w'
                    fcb       C$CR

* DWSet sequence: Type 8, 40x24, fc=15, bc/bord=0
L002B               fcb       $1B,$20,$08,$00,$00,$28,$18,$0F,$00,$00
                    fcb       $05,$20,C$FORM      Cursor OFF, CLS
                    fcb       $1b,$31,$00,$00     Color 0=$00 (black)
                    fcb       $1b,$31,$01,$04     Color 1=$04 (Dark red)
                    fcb       $1b,$31,$02,$36     Color 2=$36 (yellow)
                    fcb       $1b,$31,$03,$12     Color 3=$12 (green)
                    fcb       $1b,$31,$04,$20     Color 4=$20 (medium red)
                    fcb       $1b,$31,$05,$24     Color 5=$24 (bright red)
                    fcb       $1b,$31,$06,$2D     Color 6=$2D (magenta)
                    fcb       $1b,$31,$07,$27     Color 7=$27 (pinkish?)
                    fcb       $1b,$31,$08,$01     Color 8=$01 (Dark blue)
                    fcb       $1b,$31,$09,$2D     Color 9=$2D (pinkish?)
                    fcb       $1b,$31,$0A,$09     Color 10=$09 (bright blue)
                    fcb       $1b,$31,$0B,$39     Color 11=$39 (purple)
                    fcb       $1b,$31,$0C,$38     Color 12=$38 (medium grey)
                    fcb       $1b,$31,$0D,$3C     Color 13=$3C (flesh tone)
                    fcb       $1b,$31,$0E,$39     Color 14=$39 (purple)
                    fcb       $1b,$31,$0F,$3f     Color 15=$3F (white)

L0078               fcb       $1B,$24             DWEnd

L007A               fcb       $1B,$21             Select Window


* Entry: X=ptr to params
start               lbra      L00E6

L007F               lbra      L0497

* 'i'mmortal option
L0082               tst       >Immortal           Immortal player flag already set?
                    lbne      L024E               Yes, exit with Illegal Parameter error
                    com       >Immortal           Invert flag
                    lbra      L00FE               Continue processing parameters

* 'l'evel setting option
L008F               ldd       >StLevel            Get start level #
                    cmpd      #1                  Still 1 (default)?
                    lbne      L024E               No, they are trying to specify it twice, illegal parameter error
                    bsr       L00CD               Convert ASCII level # to binary in B
                    tstb                          Level 0?
                    lbeq      L0349               Yes, print help message
                    cmpb      #16                 Above 16?
                    lbhi      L0349               Yes, print help message
                    clra
                    std       >StLevel            Save 16 bit start level # 1-15
                    lbra      L00FE               Continue processing parameters

* 's'peed setting option
L00AE               ldd       >Speed              Get speed value
                    cmpd      #3                  Still default 3?
                    lbne      L024E               No, they tried specifying it twice, exit with illegal parameter error
                    bsr       L00CD               Get binary version of ASCII speed selection into B
                    tstb                          If 0, print help message
                    lbeq      L0349               Print most of the help message
                    cmpb      #5                  >5?
                    lbhi      L0349               Yes, print help message
                    clra
                    std       >Speed              Save 16 bit speed setting
                    lbra      L00FE               Continue processing parameters

* Process numeric parameter
L00CD               ldb       ,x+                 Get parm byte
                    cmpb      #'=                 '=' sign?
                    lbne      L024E               No, skip ahead
                    ldb       ,x+                 Yes, get char after =
                    cmpb      #'0                 Numeric?
                    lblo      L024E               No, skip ahead
                    cmpb      #'9
                    lbhi      L024E
                    andb      #$0F                Yes, convert ASCII 0-9 to byte value & return
                    rts

L00E6               ldd       <u0006              Get ? from THEXDER memory map
                    cmpd      #$8000              No memory specifier from command line specified?
                    lbne      L03F6               There was one, tell user NOT to use #xxK
                    ldd       #3                  Init default speed to 3
                    std       >Speed
                    ldb       #$01                Init start level to 1
                    std       >StLevel
                    clr       >Immortal           Init Immortal flag to 0 (Not immortal)
L00FE               lda       ,x+                 Get parm byte
                    cmpa      #C$CR               Carriage return?
                    beq       L012D               Yes, skip ahead
                    cmpa      #C$SPAC             Space?
                    beq       L00FE               Yes, eat it and get next byte
                    cmpa      #'-                 Dash for param?
                    lbne      L024E               No, skip ahead
                    ldb       ,x+                 Get parm character
                    cmpb      #'?                 '?' Help?
                    lbeq      L0349               Yes, print help screen
                    orb       #$20                No, force char to lowercase
                    cmpb      #'i                 'i' (immortal)?
                    lbeq      L0082               Yes, go do that
                    cmpb      #'s                 's' (speed setting)?
                    lbeq      L00AE               Yes, go do
                    cmpb      #'l                 'l' (level setting)?
                    lbeq      L008F               Yes, go do
                    lbra      L0349               Unknown option, go print help screen

L012D               lbsr      L0368               Go allocate /w, and find MMU block #'s it is using
                    ldd       >$1FB0              Get start block #
                    ldx       #$1FB8              Point to second table
                    std       ,x++                Add all 4 (contiguous) MMU block #'s to 2nd table
                    incb
                    std       ,x++
                    incb
                    std       ,x++
                    incb
                    std       ,x++
                    lbsr      L0368               Go allocate second /w, and find MMU block #'s it is using
                    os9       F$ID                Get our process ID #
                    ldu       <u0004              Get data mem ptr?
                    leax      9,u                 Point to 512 byte buffer to hold process descriptor
                    os9       F$GPrDsc            Get copy of our process descriptor
                    leax      <P$DATImg,x         Point to copy of our DAT image
                    leay      >$1FB2,u            Point to block 1 & up MMU block # copies we are making
                    leax      2,x                 Skip past first MMU block #
                    ldd       ,x++                Get our process' MMU block #1
                    clra                          Clear high byte
                    std       ,y++                Save in our copy
                    ldd       ,x++                Get our process' MMU Block #2
                    clra
                    std       ,y++                Save in our copy
                    ldd       ,x++                Get our process' MMU block #3
                    clra
                    std       ,y++                Save in our copy
                    puls      u,y,x,d             Get regs from current stack
                    lds       #$0C00              Force stack to 3K into block 0 in our process
                    pshs      u,y,x,d             Put same regs onto new stack
                    ldu       #$2000              Clear out 3 MMU blocks in our task starting at 2nd block
                    ldb       #$03
                    os9       F$ClrBlk
                    ldu       <u0004              Get data mem ptr
                    ldx       >$1FB0              Get start block # of /w screen 1
                    ldb       #$04                Map those 4 MMU blocks into our process space
                    os9       F$MapBlk            U now is pointing to address of 1st MMU block we just mapped in
                    lda       >NewWPath           Get path # to new window we allocated
                    clrb                          SS.Opt Get path desc options for new window
                    leax      9,u                 Point to buffer to hold the 32 bytes
                    os9       I$GetStt
                    clr       PD.EKO-PD.OPT,x     $04 - No echo
                    clr       <PD.INT-PD.OPT,x    $10 - No Interrupt key
                    clr       <PD.QUT-PD.OPT,x    $11 - No Quit key
                    clrb                          SS.Opt Change the window settings to our new ones
                    os9       I$SetStt
                    lda       >NewWPath           Get new window path again
                    leax      >L0024,pcr          Point to Font Select for IA font
                    ldy       #$0004
                    os9       I$Write             Select font in new window
                    bcc       L01E1               Worked, continue on
                    cmpb      #E$BadBuf           Bad buffer # (font not loaded) error?
                    lbne      L0251               No, exit back to THEXDER with whatever error we got
                    leax      >L0013,pcr          Yes, point to path to IA.FNT
                    lda       #READ.
                    os9       I$Open              Open font file
                    bcs       L01E1               Error opening, skip ahead
                    ldx       #$0100              Place to hold font data
                    ldy       #$040B              Size of font to load
                    os9       I$Read              Read in the font
                    lbcs      L0251               Error, exit back to THEXDER with error
                    pshs      a                   Save path # to font file
                    lda       >NewWPath           Get path to new window
                    os9       I$Write             Send new font to new window
                    puls      a                   Get path # to font file back
                    os9       I$Close             Close font file
                    lda       >NewWPath           Get new window path #
                    leax      >L0024,pcr          Select new font on new window
                    ldy       #$0004
                    os9       I$Write
L01E1               lda       >NewWPath           Get path to new window
                    leax      >L007A,pcr          Select new window as active screen
                    ldy       #$0002
                    os9       I$Write             Select that window
                    lda       >NewWPath           Get path to window again
                    ldb       #SS.KySns           $27
                    ldx       #1                  Turn Keysense mode ON
                    os9       I$SetStt
                    ldd       #500                ?
                    std       >$1FC6              Save it (is 999 if immortal)
                    ldd       #1                  ?
                    std       >$1FC8              Save it
                    ldd       #10                 ?
                    std       >$1FCA              Save it
                    tst       >Immortal           Is immortal flag set?
                    beq       L021E               No, skip ahead
                    clrb                          Yes, change default values
                    std       >$1FC8              Change from 1 to 0
                    std       >$1FCA              Change from 10 to 0
                    ldd       #999                Change to 500 from 999
                    std       >$1FC6
L021E               leax      >L04E7,pcr          Point to routine
                    ldu       #$9800              Point to address to copy it to
                    stu       >$1FCF              Save that address
                    ldy       #$0062              Copy L04E7 routine over (98 bytes)
                    lbsr      L0245
                    stu       >$1FD1              Save ptr to 2nd routine
                    ldy       #$004B              Copy L0549 routine over (75 bytes)
                    lbsr      L0245
                    stu       >$1FD3              Save ptr to 3rd routine
                    ldy       #$0047              Copy L0594 routine over (71 bytes)
                    lbsr      L0245
L0243               clrb                          No error & return
                    rts

* Copy Y bytes from X to U
L0245               lda       ,x+
                    sta       ,u+
                    leay      -$01,y
                    bne       L0245
                    rts

* Return to main THEXDER module with Illegal Argument error
L024E               coma                          Set carry for error
                    ldb       #E$IllArg           Illegal Argument error$BB
* Entry point for other Error #'s
L0251               pshs      b                   Save error on stack
                    leau      >L0000,pcr          Point to start of THEXS module
                    ldd       >$C002              Get module size of THEXDER module
                    cmpd      #$3DF2              Match the size of the version we expect?
                    bne       L0263               no, exit (Were not called from THEXDER?)
                    jmp       >$C123              Yes, jump into THEXDER code $23 bytes into module
* This does a jsr ,y immediately, and then F$UnLink (I assume unlinks THEXS)

L0263               os9       F$Exit

L0266               fcc       '-==='
                    fcc       ': Thexder:OS-9 :===-'
                    fcb       C$CR,C$LF
                    fcc       'Modifications (C) 1992 Alan DeKok'
                    fcb       C$CR,C$LF
                    fcc       'All Rights Reserved'
                    fcb       C$CR,C$LF
                    fcc       ' -?   print this help message'
                    fcb       C$CR,C$LF
                    fcc       ' -i   make Thexder immortal!'
                    fcb       C$CR,C$LF
                    fcc       ' -l=# set starting level: 1 to 9'
                    fcb       C$CR,C$LF
                    fcc       ' -s=# set speed: 1 (fast) to 5 (slow), default 3'
                    fcb       C$CR,C$LF

L0349               leax      >L0266,pcr          Write help message to std out
                    ldy       #$00E3
                    lda       #$01
L0353               os9       I$Write
                    clrb                          Return to Thexder with error 0
                    lbra      L0251

L035A               lda       >NewWPath           Get path to new window
                    ldy       #$0002              Send DWend to it (close & return memory)
                    leax      >L0078,pcr
                    os9       I$Write
* Normal entry point
L0368               lda       #UPDAT.             Read+Write
                    leax      >L0028,pcr          Point to '/w'
                    os9       I$Open              Open path to next available window
                    lbcs      L042F               If error, report no free window/out of mem error
                    sta       >NewWPath           Save path # to new window
                    ldu       <u0004              Get data mem ptr
                    leax      9,u                 Point to temp buffer for initial block map
                    os9       F$GBlkMp            Get copy of system block map (1024 bytes)
                    leax      >L002B,pcr          Point to Device Window Set esc sequence (includes clear scrn, shut crs off, palettes)
                    lda       >NewWPath           Get path to new window
L0386               ldy       #$004D              Size of entire command sequence
                    os9       I$Write             320x192x16, cursor off, cls, set all 16 palettes
                    lbcs      L042F               Error, report no free window/out of mem error
L0391               leax      >$0109,u            Point to 2nd buffer for new MMU block map (with new window allocated)
                    os9       F$GBlkMp            Get copy of new block map
                    clr       ,-s                 Clear ctr on stack
                    leax      $09,u               Point X to start of initial block map
                    leay      >$0109,u            Point Y to start of new block map
                    leau      >$0209,u            Point U to end of 2nd block map+1 (to see if finished)
                    clr       ,u+                 Clear 1st byte of "blocks newly allocated" table (flag to stop later)
L03A6               lda       ,x                  Get byte from initial block map
                    anda      #%00000011          Keep only module present & ram in use flags
                    cmpa      ,x+                 Is one of those set, but NO other bits set?
                    bne       L03C5               No, assume NOT RAM found, we are done checking, skip ahead
                    inc       ,s                  Yes, inc ctr
                    beq       Fix2MB              Wrapped, done checking all blocks, skip ahead
                    cmpa      ,y+                 Same as new map?
                    beq       L03A6               Yes, check next
                    ldb       -1,y                No, get previous block marker in new map
                    cmpd      #$0001              Is the two map combination map 1 unused RAM/map 2 used (but not module)?
                    bne       L03A6               No, continue onto next (makes sure wasn't a LOAD vs. video RAM allocation)
                    ldb       ,s                  Get MMU block # of newly allocated RAM
                    decb                          Base 0
                    stb       ,u+                 Save it
                    bra       L03A6               Keep checking rest of them (video is always contiguous)

* Finished comparing both MMU block maps - it is here somewheres that I think 2MB is screwing things up
* At this point, >$0209 will be '0', 4 contiguous blocks, '0' (if we found 32K contiguous new allocated RAM)
Fix2MB              dec       ,s                  Drop last block # to $FF
L03C5               clr       ,u                  Clear next byte in 3rd map (so newly allocated blocks have $00 at beginning & end)
                    ldb       ,s+                 Get highest block # found counter
                    cmpb      #$FF                Full 2 MB?
                    beq       SkipMask
                    andb      #%11000000          Only keep uppermost 2 bits
SkipMask            stb       <u0008              Save it (maybe for 512k video bank #?)
L03CD               lda       ,-u                 Get last MMU block # from newly allocated blocks table
                    beq       L03D9               If we have hit beginning of the contiguous blocks found, skip ahead
                    cmpa      <u0008              Compare with last block # counter (on 2 MB always 0)
                    blo       L03D9               If lower, skip ahead
                    clr       ,u                  Same or higher, clear byte out of 3rd table (not usable)
                    bra       L03CD               Continue on

L03D9               ldu       <u0004              Get data mem ptr
                    leax      >$020A,u            Point to 1st MMU block of newly allocated screen/window
                    clr       >$1FB0              16 bit entry for first MMU block #
                    lda       ,x+
                    sta       >$1FB1              Save to >$1FB0
                    suba      ,x+                 Quick & dirty way to make sure all 5 blocks are contiguous
                    adda      ,x+
                    suba      ,x+
                    adda      ,x+
                    cmpa      #-2                 Are all 5 blocks contiguous?
                    lbne      L035A               No, DWEnd window and try opening /w again
                    rts

L03F6               leax      >L0407,pcr          Point to memory size error
                    ldy       #$0028
L03FE               lda       #$02                Std Err
                    os9       I$Write             Write message out
                    clrb
                    lbra      L0251

L0407               fcc       'Thexder: Do NOT specify a memory size!'
                    fcb       C$CR,C$LF

L042F               leax      >L0439,pcr          Point to memory error msg
                    ldy       #$5E
                    bra       L03FE               Print it out

L0439               fcc       'Thexder: Window error.  Cannot allocate window,'
                    fcb       C$CR,C$LF
                    fcc       ' or there is insufficient memory available.'
                    fcb       C$CR,C$LF

L0497               puls      u,y,x,d             Get regs from original stack
                    lds       #$2000              Reset stack to $2000
L049D               pshs      u,y,x,d             Put regs onto new stack
                    ldb       #$01                Map 8K block @ $2000 out of our process space
                    ldu       #$2000
                    os9       F$ClrBlk
                    ldb       #$01                We are mapping 1 8K block
                    ldx       >$1FB2              Get block # we are mapping in
                    os9       F$MapBlk            Map it into our process
                    ldb       #$01                Map 8K block @ $4000 out of our process space
                    ldu       #$4000
                    os9       F$ClrBlk
                    ldb       #$01                We are mapping 1 8K block
                    ldx       >$1FB4              Get block # we are mapping in
                    os9       F$MapBlk            Map it into our process
                    ldb       #$01                Map 8K block @ $6000 out of our process space
                    ldu       #$6000
                    os9       F$ClrBlk
                    ldb       #$01                Get block # we are mapping in
                    ldx       >$1FB6
                    os9       F$MapBlk            map it into our process
                    ldb       #$01                Map 8K block @ $8000 out of our process space
                    ldu       #$8000
                    os9       F$ClrBlk
                    leax      >L007A,pcr          Point to Select Window esc code
                    lda       #$01                Std out
                    ldy       #2                  2 byte sequence to write
                    os9       I$Write             Display std out window
                    lbra      L0243               Return w/o error

* Routine pointed to by <$1FCF
* Graphics drawing of some sort? Or maybe text?
L04E7               ldd       #$EEFF              purple,purple,white,white
                    std       ,x                  Save on screen?
                    clrb
                    std       >$0280,x            purple,purple,black,black 4 lines down
                    ldb       #$E0                purple,purple,purple,black 5 lines down
                    std       >$0320,x
                    ldb       #$AA                purple,purple,bright blue,bright blue, 7 lines down
                    std       >$0460,x
                    ldb       #$EE                purple,purple,purple,purple 5 pixels to right, 1st line
                    std       2,x
                    ldd       #$EFFF              purple,white,white,white 1 line down
                    std       >$00A0,x
                    ldd       #$FFF0              white,white,white,black 2 lines down
                    std       >$0140,x
                    clrb
                    std       >$01E0,x            white,white,black,black 3 lines down
                    ldd       #$EAAA              purple,bright blue,bright blue,bright blue, 6 lines down
                    std       >$03C0,x
                    lda       #$0E                black,purple,bright blue,bright blue 2 lines down, 5 pixels to right
                    std       >$0142,x
                    clra                          black,black,bright blue,bright blue 3 lines down, 5 pixels to right
                    std       >$01E2,x
                    ldd       #$EAEE              purple,bright blue, purple,purple, 1 line down, 5 pixels to right
                    std       >$00A2,x
                    lda       #$A8                bright blue,dark blue,purple,purple, 7 lines down, 5 pixels to right
                    std       >$0462,x
                    ldd       #$00A8              black,black,bright blue,dark blue, 4 lines down, 5 pixels to right
                    std       >$0282,x
                    ldd       #$0AAE              black,bright blue,bright blue,purple 5 lines down, 5 pixels to right
                    std       >$0322,x
                    ldd       #$AA8E              bright blue,bright blue,dark blue,purple, 6 lines down, 5 pixels to right
                    std       >$03C2,x
                    rts

* Routine pointed to by <$1FD1
* Graphics drawing of some sort?
L0549               ldd       #$EEEE
                    std       ,x
                    std       $02,x
                    std       >$0460,x
                    std       >$0462,x
                    ldd       #$E000
                    std       >$00A0,x
                    ldb       #$AA
                    std       >$0140,x
                    std       >$01E0,x
                    std       >$0280,x
                    std       >$0320,x
                    std       >$03C0,x
                    ldd       #$000E
                    std       >$00A2,x
                    ldd       #$AAAE
                    std       >$0142,x
                    std       >$01E2,x
                    std       >$0282,x
                    std       >$0322,x
                    std       >$03C2,x
                    rts

* Routine pointed to by <$1FD3
* Graphics drawing of some sort?
L0594               ldd       #$1111
                    std       ,x
                    std       >$00A0,x
                    std       >$0140,x
                    std       >$01E0,x
                    std       >$0320,x
                    std       >$03C0,x
                    std       >$01E2,x
                    std       >$0282,x
                    std       >$0322,x
                    std       >$0462,x
                    ldb       #$15
                    std       $02,x
                    std       >$0460,x
                    std       >$0142,x
                    std       >$03C2,x
                    ldd       #$1511
                    std       >$0280,x
                    lda       #$51
                    std       >$00A2,x
                    rts

                    emod
eom                 equ       *
                    end
