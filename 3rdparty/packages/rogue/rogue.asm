* Disassembly by L. Curtis Boyle
* Edition 1 changes by LCB
* 12/18/2017 - changed gfx font mode check to allow gfx font on ANY graphics window
*   to         - optimized some code to be smaller/faster.
* ??/??/2018   - changed some time delays to use F$Sleep calls (more multi-tasking friendly)
* To do:
* 1) Fix bug when running on 25 line screens (unecessary scrolling)
* 2) Fix 25 line height with smaller width windows (can use extra line for status,etc.)
* 3) Add command line option for font # -f=hh
* 4) Change hard coded PIA sound to either <CTRL>-<G> or SS.Tone (smaller,
*    more multi-tasking friendly
* Possible extensions:
* 1) Make extended 224 char font so that monsters can be 8x8 graphics
* 2) Add option for 106 width (if -f=hh font is 6 bit wide) map
* 3) If someone gets creative, add termcap support to run over serial port
* 4) Allow it run on VDG screen (32x16 is well within the minimum window size)
* Note: Rogue defaults to a 19 byte data aread ($00-$12)
* Note 2: It rarely uses DP - should change it, after we see if there is a page that
*  is used often.
                    nam       ROGUE
                    ttl       program module

* Disassembled 2017/11/23 18:58:35 by Disasm v1.5 (C) 1988 by RML

* OS9 system calls, etc (won't have enough RAM to do locally - can change later for defs
*   files for LWASM).
F$Chain             equ       $05
F$Exit              equ       $06
F$Mem               equ       $07
F$Icpt              equ       $09
F$Sleep             equ       $0A
F$ID                equ       $0C
F$PErr              equ       $0F
F$Time              equ       $15
I$Create            equ       $83
I$Open              equ       $84
I$Delete            equ       $87
I$Read              equ       $89
I$Write             equ       $8A
I$ReadLn            equ       $8B
I$GetStt            equ       $8D
I$SetStt            equ       $8E
I$Close             equ       $8F

SS.ScTyp            equ       $93
SS.Ready            equ       $01
SS.ScSiz            equ       $26

Prgrm               equ       $10
Objct               equ       $01
ReEnt               equ       $80

Edition             equ       $01                 Change to $01 once we are done

PrgOffst            equ       $6000               Address Rogue will be loaded into RAM (used for tables at end)

*         ifp1
*         use   /dd/defs/os9defs
*         endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
                    mod       eom,name,tylg,atrv,start,size


* NOTE: This is the original 20 byte data area (reserved for parameters; ie the
*  save filename if present). Rogue then requests 24K of RAM, reads the rogue.dat
*  file into that, and all data area access from there on is based on the 24K data
*  data area instead. We should expand this and allow the -f=<fontnum> (default to
*  whatever # we make the Epyx Rogue font), since it will use a full 8K MMU block
*  anyways)
u0000               rmb       1
u0001               rmb       1
u0002               rmb       1
u0003               rmb       1
u0004               rmb       1
u0005               rmb       1
u0006               rmb       1
u0007               rmb       1
u0008               rmb       1
u0009               rmb       1
u000A               rmb       1
u000B               rmb       1
u000C               rmb       1
u000D               rmb       1
u000E               rmb       1
u000F               rmb       1
u0010               rmb       1
u0011               rmb       1
u0012               rmb       1
size                equ       .

name                fcs       /rogue/
* Edition #1 for new revisions
                    fcb       Edition

start               orcc      #$50                Kill IRQs
* The following SP setting works because, even though we have only "offically" allocated 20 bytes for the
*   data / parameter area, we get a full 8K MMU block. We should be able to change the size of the area
*   to allow the -f=## font override option we want to add. Even "officially" allocated the full 8K?
                    lds       #$1FFE              Set stack ptr, then re-enable IRQs
                    andcc     #$AF
                    ifne      coco3
                    lda       #$02
                    sta       >$FF20              ??? RS-232 bit on PIA?
                    endc
                    clra
                    ldb       #SS.ScTyp           Get screen type
                    os9       I$GetStt
* Easiest patch for graphical font (either original or alternate) is to just
* leave the font # alone, and skip all this special checking. Check if type >4,
* then use C8 2A. If we have enough room for an inline patch, we can add an
* option flag to specify a different font # (and take out all the special process
* ID stuff)
                    cmpa      #$05                640x192x2?
                    blo       L002D               If hardware text window, skip loading gfx font
                    lbsr      L00EE               Yes, load special gfx font 'rogue.fnt' first NON STANDARD grp/buff!
L002D               ldd       #$6000              Allocate 24K of RAM
                    os9       F$Mem
                    lbcs      L00CA               Couldn't get RAM; exit with error
                    orcc      #$50                Set stack ptr to end of new RAM
                    lds       #$5FFF
                    andcc     #$AF
                    pshs      u                   Save ptr to start of our data area
                    leas      <-20,s              Bump stack ptr back 20 bytes
                    leay      ,s
                    pshs      y                   Save that ptr
                    clrb                          Copy the original parameters passed to the new location
L0049               lda       ,x+
                    sta       ,y+
                    incb
                    cmpb      #20                 Max 20 chars for parameters
                    beq       L0059
                    tsta                          If <20 chars (NUL terminated), stop copying
                    beq       L005B
                    cmpa      #$0D                If CR terminated, stop copying
                    bne       L0049               Keep copying until done
L0059               clr       ,-y                 Force NUL to end parameter string
L005B               leax      <L00D2,pc           Point to 'rogue.dat'
                    lda       #$01                owner Read mode
                    os9       I$Open              Open it
                    bcs       L00CA               Error, exit
                    pshs      a                   Save path to file
                    ldx       #$0000              Read whole file to <u0000 (note: overwrites special font buffer above)
                    ldy       #$5E4D              NOTE: This is 3 bytes bigger than the actual file???
                    os9       I$Read              Read whole .dat file
                    bcs       L00CA               Error, exit
                    puls      a                   Get path back
                    os9       I$Close             Close file
                    bcs       L00CA
                    puls      y                   Get back ptr to copy of original parameters we received
                    ldx       #$1528              Copy parameter string (until NUL) into new data area
L0088               lda       ,y+
                    sta       ,x+
                    bne       L0088
                    leas      <20,s               Bump stack ptr back past parameter copy
                    puls      d                   Get back start of original data area ?
                    stb       >$3571              ??? Save LSB of it (this sets flag that we are using rogue gfx font)
                    clra                          Get options on current window
                    clrb
                    ldx       #$0000
                    os9       I$GetStt
                    clr       >$0004              Turn echo off
                    os9       I$SetStt
* Not sure why all the PIA stuff here is necessary? It looks like the sound used for
*  text overflow, hitting a trap, etc. actually hits the PIA directly. We could replace
*  with the BEL ($07) later, or SS.Tone
                    lda       >$FF01              Get PIA settings
                    anda      #$F7                Disable Horizontal sync IRQ
                    sta       >$FF01
                    lda       >$FF03              Get PIA settings
                    anda      #$F7                Disable vertical sync IRQ
                    sta       >$FF03
                    lda       >$FF23              Get PIA settings
                    ora       #$08                Enable 6 bit sound
                    sta       >$FF23
                    leax      <L00DC,pc           Intercept routine (just return)
                    ldu       #$0000              Intercept routine data mem area
                    os9       F$Icpt
                    lbra      L405F

L00CA               lda       #$02                Exit with error
                    os9       F$PErr
                    lbra      L0195

L00D2               fcc       'rogue.dat'
                    fcb       0

* Signal trap routine - just return
L00DC               rti

* Part of header for special gfx font. This chunk comes after the GPLoad sequence
*   group/buff (1b 29 gg bb), so it has type 5, 8x8, $400 byte load
L00DD               fcb       $05,$00,$08,$00,$08,$04,$00

* Name of special font
L00E4               fcc       'rogue.fnt'
                    fcb       0

* Routine to read in special gfx font into Group #(our process ID), buffer #2
L00EE               pshs      y,x,d
                    leax      <L00E4,pc           Point to 'rogue.fnt'
                    lda       #1
                    os9       I$Open              Open it (raw font data)
                    bcs       L0179
                    ldx       #$0100              Load it @ <u0100
                    ldy       #$0400
                    os9       I$Read
                    bcs       L0179
                    os9       I$Close             Close the file
                    os9       F$ID                Get our process ID number
                    sta       <u0000              Save it (as group # for font) NON STANDARD
                    lda       #$02                Buffer #2
                    sta       <u0001              Save that too
L0116               lda       #$1B                Send ESC
                    bsr       L0184
                    lda       #$29                Send DfnGPBuf command byte
                    bsr       L0184
                    bsr       L017E               Send process # & $02 as group #/buffer #
                    lda       #$04                Send $0400 as size of buffer
                    bsr       L0184
                    lda       #$00
                    bsr       L0184
                    ldd       #$02*256+SS.Ready   Std error path, SS.Ready GetStat call
                    ldb       #SS.Ready           Check if data ready
                    os9       I$GetStt
                    bcs       L014B               If not ready, skip ahead (to GPLoad)
L0136               ldx       #$0002              Point to 1 byte write buffer
                    ldy       #$0001              Read 1 byte
                    os9       I$Read
                    ldb       #SS.Ready           Keep going until no error
                    os9       I$GetStt
                    bcs       L0136
                    inc       <u0001              If no error, inc group #? And try defining that buffer
                    bra       L0116

L014B               lda       #$1B                Send ESC out
                    bsr       L0184
                    lda       #$2B                Send out GPLoad command
                    bsr       L0184
                    bsr       L017E               Send out new group #/buffer # from loop above
                    leax      <L00DD,pc           Point to rest of GPLoad (type 5, 8x8, $400 byte load size)
                    ldy       #$0007              Write out rest of GPLoad command parameters
                    clra
                    os9       I$Write
                    ldx       #$0100              Send out actual font data as part of GPLoad
                    ldy       #$0400
                    os9       I$Write
                    lda       #$1B                Send ESC
                    bsr       L0184
                    lda       #$3A                Send Font Select command byte
                    bsr       L0184
                    bsr       L017E               Use current group/buffer # for font select
                    ldu       #$0001              Flag font load was succesful
                    puls      pc,y,x,d

L0179               ldu       #$0000              Flag font load unsuccesful
                    puls      pc,y,x,d

* NOTE: L017E & L0184 are only called from above (multiple times) as part of GPLoad
* etc. We can replace with single writes, leaving us some room for handling -f=<fontnum>
L017E               lda       <u0000              Get process ID #
                    bsr       L0184               Send that # to std out (for get/put group #)
                    lda       <u0001              Get $02 we stored earlier & send it out
* Write 1 byte from <u0002 to path in A
L0184               pshs      u,y,x,d
                    sta       <u0002
                    ldx       #$0002
                    ldy       #$0001
                    clra
                    os9       I$Write
                    puls      pc,u,y,x,d

L0195               tst       >$14AF              did we get called with -x option?
                    bne       L01A6               Yes, akip ahead
                    lda       >$37CC              Get cursor Y coord
                    suba      #2                  Adjust down by 2
                    clrb                          X coord to 0
                    lbsr      L6CDE               CurXY to b,a
                    bra       L01AF

L01A6               lda       >$37CC              Get cursor Y coord
                    suba      #4                  Adjust down by 4
                    clrb                          X coord to 0
                    lbsr      L6CDE               CurXY to b,a
L01AF               lbsr      L6D42
                    lbsr      L6421
                    lda       >$FF23              Shut 6 bit sound off?
                    anda      #$F7
                    sta       >$FF23
                    clra                          Get SS.Opt options block
                    clrb
                    ldx       #$0000              We are saving it to $0-$1f
                    os9       I$GetStt
                    lda       #$01                Turn echo back on
                    sta       <$0004
                    os9       I$SetStt
                    tst       >$14AF              Did user use -x option (chain to rogue, rather than fork)?
                    bne       L01D7               Yes, go chain to shell
                    clrb                          No, a simple exit will suffice
                    os9       F$Exit              Exit without error

L01D7               clra                          Reset DP and SP
                    tfr       a,dp
                    lds       #$00FF              Reset Stack
                    leax      <L01F2,pc           Chain to shell (if we had 128k)
                    ldu       #$0000              Set parm ptr and parm size both to 0
                    leay      ,u
                    ldd       #$1103              Prgrm+6809, 3 pages of data RAM (768 bytes)
                    os9       F$Chain

L01F2               fcc       'shell'
                    fcb       $0d

* Open rogue.opt file (pointed to by X from calling routine)
L01F8               pshs      u,y,x,d
                    lda       #1
                    os9       I$Open
                    bcs       L0210
                    ldx       #$14B0              Load 120 bytes from it to $14B0
                    ldy       #120
                    os9       I$Read
                    os9       I$Close
L0210               puls      pc,u,y,x,d

* 'S'ave game command
L0212               pshs      u,y,x,d
                    ldu       #$1470
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    clr       >$0D94
                    lda       >$37CB              Get window width
                    cmpa      #66                 If 66 or higher, skip ahead
                    bhs       L022B
                    lbsr      L6D6F               If <=65, CLS our window 1st
L022B               ldu       #$14D5              'rogue.sav'
                    pshs      u
                    ldu       #$15A2              'Save file (press enter to default to "%s") ? '
                    pshs      u
                    lbsr      L6D16
                    leas      4,s
                    lda       #19                 19 characters max for filename
                    ldx       #$1528              Where to read filename from player
                    lbsr      L6268               Go get filename from keyboard input
                    ldu       #$1470
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    pshs      a
                    lda       >$37CB              Get window width
                    cmpa      #66                 If 66 or greater, skip ahead
                    bhs       L0258
                    lbsr      L6D6F               If <=65, CLS our window 1st.
L0258               puls      a
                    cmpa      #$1A
                    lbeq      L032D
                    lda       >$1528
                    bne       L0272
                    ldx       #$14D5              Copy filename (until NUL)
                    ldy       #$1528
L026C               lda       ,x+
                    sta       ,y+
                    bne       L026C
L0272               ldx       #$1528              Point to filename copy
                    lda       #$03                Read+Write
                    os9       I$Open              Try to open save file
                    bcs       L02A6               Couldn't (doesn't exist), go create it
                    os9       I$Close             Close it, then prompt if player wants to overwrite it
                    ldu       #$1528
                    pshs      u
                    ldu       #$15D0              '"%s" already exists, overwrite (y,n) ?'
                    pshs      u
                    lbsr      L68D8
                    leas      4,s
                    lbsr      L61C2
                    ldu       #$1470
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    cmpa      #$79                'y'?
                    beq       L02B6               Yes, go overwrite it
                    cmpa      #$59                'Y'?
                    beq       L02B6               Yes, go overwrite it
                    lbra      L032D

* Save game
L02A6               ldx       #$1528              Point to filename
                    ldd       #$03*256+$1B        New path for file, PW PR W R attributes
                    os9       I$Create            Create file
                    bcs       L02FF               Error creating, go handle
                    bra       L02C2

L02B6               ldx       #$1528
                    lda       #$03                Read+Write
                    os9       I$Open
                    bcs       L0319
L02C2               ldx       #$153C              Point to authors names (from rogue.dat)
                    ldy       #50                 Size of message
                    os9       I$Write             Write to save file
                    bcs       L0310               Error, close file & delete it
                    ldx       #$0000              Dump entire data structure to save file
                    ldy       #$5E4A
                    os9       I$Write
                    bcs       L0310               Error, close file & delete it
                    os9       I$Close             Close save game file
                    lda       >$37CE
                    clrb
                    lbsr      L6CDE               CurXY to b,a
                    lbsr      L6D78               Clear to end of line
                    lda       >$37CE
                    deca
                    clrb
                    lbsr      L6CDE               CurXY to b,a
                    lbsr      L6D6F
                    ldu       #$1528
                    pshs      u
                    ldu       #$15F8              'Game saved as "%s"'
                    pshs      u
                    lbsr      L4186
L02FF               ldu       #$1528
                    pshs      u
                    ldu       #$160E              'Could not create "%s".'
                    pshs      u
                    lbsr      L68D8
                    leas      4,s
                    bra       L0323

L0310               os9       I$Close             Error; close file
                    ldx       #$1528              then delete it
                    os9       I$Delete
L0319               ldu       #$1625              'Could not write savefile to disk!'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
L0323               ldu       #$1647              'Sorry, you can't save the game just now'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
L032D               lda       >$37CB
                    cmpa      #66
                    bhs       L0337
                    lbsr      L6411
L0337               puls      pc,u,y,x,d

L0339               pshs      u,y,x,d
                    stx       >$15A0
                    lbsr      L6D6F
                    ldu       #$166F              'Insert disk with saved game'
                    pshs      u
                    lbsr      L6D16
                    leas      2,s
                    lda       >$37CE
                    ldx       #$168C              '(Press spacebar)'
                    lbsr      L6D56
                    lda       #$20
                    lbsr      L62E5
                    lbsr      L6D6F
                    ldd       >$0020
                    pshs      d
                    ldx       >$15A0
                    lda       #$01                Open file in read mode
                    os9       I$Open
                    bcc       L037B               Opened ok, skip ahead
                    ldu       >$15A0
                    pshs      u
                    ldu       #$169D
                    pshs      u
                    lbsr      L4186
L037B               sta       >$14AE
                    ldu       >$15A0
                    pshs      u
                    ldu       #$16AF              'Restoring "%s"
                    pshs      u
                    lbsr      L6D16
                    leas      4,s
                    ldx       #$156E              Buffer to read first 50 bytes of save file (must be authors names)
                    ldy       #50
                    lda       >$14AE              File path
                    os9       I$Read              Read start of save file
                    bcs       L03AE               Error, skip ahead
                    ldx       #$156E              Point to start of file buffer again
                    ldu       #$153C              'Mike Leber, Ron Miller, James Long, Ed Rosenzweig' (must be start of save file)
                    lbsr      L3FCD               Go compare the two strings
                    tsta
                    beq       L03BC               Legitimate save file, go read it
                    ldx       #$16C0              'Not a savefile.'
                    lbsr      L6D07               Write out string @ X (NUL terminated)
L03AE               lda       >$14AE
                    os9       I$Close
L03B4               ldu       #$16D4              'Serious restore error.'
                    pshs      u
                    lbsr      L4186
* Block read the entire save file (which is the author's names header, plus a raw dump of the
*   entire rogue.dat area saved from previous game)
L03BC               ldx       #$0000              Read whole save file in (after 50 char 'validated' header)
                    ldy       #$5E4A              Length of save file to read
                    lda       >$14AE              Get file path, and read save file
                    os9       I$Read
                    bcs       L03AE
                    os9       I$Close             Close file
                    bcs       L03B4
                    puls      d
                    cmpa      >$0020
                    bne       L03B4
                    cmpb      >$0021
                    bne       L03B4
                    lbsr      L63DD
                    clra
                    lbsr      L6405
                    lbsr      L6411
                    clr       >$0D94
                    ldu       #$14B0              'Rodney' (Default char name)
                    pshs      u
                    ldu       #$16EB              'Hello %s, Welcome back to the Dungeon of Doom!'
                    pshs      u
                    lbsr      L68D8
                    leas      4,s
                    lbsr      L3B32
                    ldx       #$1528              Delete original save file.
                    os9       I$Delete
                    puls      pc,u,y,x,d

L0403               pshs      u,y,x,d
                    lbsr      L6546
                    ldx       #$171B              'ROGUE'
                    lda       >$37CC              Get window height /'d by 2
                    lsra
                    lbsr      L6D56
                    lda       >$37CB              Get window width
                    cmpa      #25                 If 25 or less, skip printing Copyright screen
                    blo       L0424
                    lda       >$37CE              Get cursor Y position
                    suba      #2                  -2
                    ldx       #$1721              'Copyright (C) 1986 Epyx'
                    lbsr      L6D56
L0424               lda       >$37CE              Get cursor Y position
                    ldx       #$1739              '(Press spacebar)'
                    lbsr      L6D56
                    lda       #$20
                    lbsr      L62E5
                    puls      pc,u,y,x,d

L0434               pshs      u,y,x,d
                    std       >$174A
                    stu       >$174C
                    bne       L044B
                    tsta
                    bne       L044B
                    tstb
                    beq       L0472
L044B               lda       >$37CB              Get window width
                    cmpa      #30                 If <30, skip ahead
                    blo       L0459
                    lda       >$37CE              Get cursor Y position
                    cmpa      #14                 If >=14, skip ahead
                    bhs       L0464
L0459               lda       >$37CE              Get cursor Y position
                    ldx       #$1957
                    lbsr      L6D56
                    bra       L046A

L0464               ldx       #$1965
                    lbsr      L6D56
L046A               lbsr      L621D
                    lda       #$0D
                    lbsr      L62E5
L0472               lbsr      L6D6F
                    ldx       #$14C8              Get ptr to filename to open
                    lda       #$01                Read mode
                    os9       I$Open
                    bcc       L04C2
                    ldd       >$174C
                    bne       L0486
                    puls      pc,u,y,x,d

L0486               clra
                    clrb
                    lbsr      L6CDE               CurXY to 0,0
                    ldx       #$1928              'No scorefile: Create Retry Abort (C,R or A) ? '
                    lbsr      L6D07               Write out string @ X (NUL terminated)
L0491               lbsr      L61C2               Get response from player
                    cmpa      #$63                'c'?
                    beq       L049C               Yes, create score file
                    cmpa      #$43                'C'?
                    bne       L04AC               No, check for next option
L049C               ldx       #$14C8              'rogue.scr'
                    ldd       #$03*256+$1B        Update, W PW R PR
                    os9       I$Create            Create empty score file
                    os9       I$Close
                    bra       L0472

L04AC               cmpa      #$72                'r'?
                    beq       L0472               go retry
                    cmpa      #$52                'R'?
                    beq       L0472               go retry
                    cmpa      #$61                'a'?
                    beq       L04C0               go abort
                    cmpa      #$41                'A'
                    bne       L0491               No, not legit response, prompt player again.
L04C0               puls      pc,u,y,x,d          Exit to abort

L04C2               sta       >$14AE              Save path #
                    ldx       #$174F
                    bsr       L0527               Read some stuff from score file
                    os9       I$Close             Close score file
                    ldx       #$18FD
                    ldu       #$14B0
                    lbsr      L3FF3
                    ldd       >$174C
                    std       >$1924
                    lda       >$174A
                    bne       L04E6
                    lda       >$174B
L04E6               sta       >$1926
                    lda       >$0D90
                    sta       >$1927
                    lda       >$10EB              Get player's current rank
                    sta       >$1923              Save copy
                    ldx       #$18FD
                    ldu       #$174F
                    lbsr      L06B4
                    sta       >$174E
                    lda       >$174E
                    beq       L051B
                    ldx       #$14C8              'rogue.scr'
                    lda       #$02
                    os9       I$Open              Open score file
                    sta       >$14AE              Save path
                    ldx       #$174F
                    bsr       L0567
                    os9       I$Close             Close score file
L051B               ldy       #$174F
                    lda       -1,y
                    bsr       L0592
                    puls      pc,u,y,x,d

L0527               pshs      u,y,x,d
                    lda       #$01
                    sta       >$1984
                    clr       >$1983
L0531               lda       >$1983
                    cmpa      #10
                    bhs       L0590
                    tst       >$1984
                    beq       L054F
                    ldy       #43
                    lda       >$14AE
                    os9       I$Read              Read 43 bytes from score file (each entry is 43 bytes)
                    bcs       L054F
                    leay      ,y                  0 bytes read?
                    bne       L0552               No, skip ahead
L054F               clr       >$1984              Flag it's an empty file
L0552               tst       >$1984              Empty file?
                    bne       L055D               No, skip ahead
                    ldd       #$0000
                    std       <$27,x
L055D               inc       >$1983
                    leax      <$2B,x
                    bra       L0531

L0567               pshs      u,y,x,d
                    clr       >$1985              Clear # of high score entries to 0
L056C               lda       >$1985              Get current high score entry #
                    cmpa      #10                 If we have done all 10, exit
                    bhs       L0590
                    ldd       <$27,x              Get # of gold
                    beq       L0590               If 0, don't save
                    ldy       #43                 Write out entry
                    lda       >$14AE
                    os9       I$Write
                    bcs       L0590
                    inc       >$1985              Next high score entry #
                    leax      <43,x               Point to next high score entry
                    bra       L056C               Keep going until done

L0592               pshs      u,y,x,d
                    lbsr      L6D6F
                    lda       >$37CE              Get cursor Y position
                    cmpa      #14                 If >=14 go print "Hall of fame" header
                    bhs       L05A0
L0590               puls      pc,u,y,x,d          Otherwise just return

L05A0               clra
                    clrb
                    lbsr      L6CDE               CurXY to b,a
                    ldx       #$19E1              'Guildmaster's Hall of Fame:'
                    lbsr      L6D07               Write out string @ X (NUL terminated)
                    ldd       #$0200              0,2 cursor coords
                    lbsr      L6CDE               CurXY to b,a
                    lda       >$37CC              Get window height
                    cmpa      #18                 If <=18 then skip 'Gold' sub-header
                    blo       L05C1
                    ldx       #$19FD              '  Gold'
                    lbsr      L6D07               Write out string @ X (NUL terminated)
L05C1               clr       >$1986
L05C4               lda       >$1986
                    cmpa      #10
                    bhs       L06AF
                    clra
                    clrb
                    std       >$1987
                    ldd       <$27,y              Get # of gold
                    beq       L06AF               If 0 (end of list), skip ahead
                    leau      ,y
                    pshs      u
                    pshs      d                   Save # gold on stack
                    ldu       #$1A07
                    pshs      u
                    lbsr      L6D16
                    leas      6,s
                    lda       >$37CB
                    cmpa      #$2F                ? '/'
                    lbcs      L06A0
                    lda       <$2A,y              Get dungeon level attained
                    cmpa      #26                 If <26 (never made it Amulet), skip ahead
                    blo       L0606
                    ldd       #$19A7              'Honored by the Guild' (only for those who made it to dungeon level 26)
                    std       >$1987
L0606               lda       <$29,y              Get players final status
                    lbsr      L3EE2
                    tsta
                    beq       L0628
                    lda       <$29,y              Get players final status (if letter, it's which monster type A-Z killed player)
                    ldb       #$01
                    lbsr      L0ABE
                    pshs      u
                    ldu       #$1A0F              ' killed by %s'
                    pshs      u
                    ldx       #$1989
                    lbsr      L3D23
                    leas      4,s
                    bra       L0651

L06AF               puls      pc,u,y,x,d

L0628               lda       <$29,y              Get players status
                    cmpa      #2                  If <>2, skip ahead
                    bne       L0638
                    ldd       #$19BD              ' A total winner!'
                    std       >$1987
                    bra       L0651

L0638               cmpa      #1                  1=Quit the game
                    bne       L0648
                    ldx       #$1989
                    ldu       #$19CE              ' quit'
                    lbsr      L3FF3
                    bra       L0651

L0648               ldx       #$1989              Illegal players last status, print that player was "wierded out" (note: spelled wrong)
                    ldu       #$19D4              'wierded out'
                    lbsr      L3FF3
L0651               lda       <$26,y              Get player level
                    cmpa      #1                  If 0 or 1, skip ahead
                    bls       L0676
                    leax      ,y
                    lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    tsta
                    beq       L0676
                    lda       <$26,y              Get player's level
                    deca                          0 based
                    lsla                          * 2 for two byte entries
                    ldu       #$0504              Ptr to player level table
                    ldu       a,u                 Get ptr to player level text ('Guild Novice' through 'Bug Chaser')
                    pshs      u                   Save ptr
                    ldu       #$1A1D              ' "%s"
                    pshs      u
                    lbsr      L6D16
                    leas      4,s
L0676               lda       >$37CB              Get window width
                    cmpa      #80                 If <80, skip ahead
                    blo       L06A0
                    ldx       >$1987
                    bne       L069D
                    ldb       <$2A,y              Get dungeon level attained
                    clra
                    pshs      d
                    ldu       #$1989
                    pshs      u
                    ldu       #$1A23              '%s on level %d'
                    pshs      u
                    lbsr      L6D16
                    leas      6,s
                    bra       L06A0

L069D               lbsr      L6D07               Write out string @ X (NUL terminated)
L06A0               ldx       #$1A32              CRLF
                    lbsr      L6D07               Write out string @ X (NUL terminated)
                    inc       >$1986
                    leay      <$2B,y              Point to next score entry.
                    lbra      L05C4

L06B4               pshs      u,y,x,b
                    lda       #11
                    sta       >$1A35
                    stu       >$1A36
                    leau      >$0183,u
                    stu       >$1A38
L06C5               cmpu      >$1A36
                    blo       L06FC
                    ldd       <$27,x
                    cmpd      <$27,u
                    bls       L06FC
                    leay      ,u
                    dec       >$1A35
                    cmpy      >$1A38
                    bhs       L06F5
                    ldd       <$27,u
                    beq       L06F5
                    pshs      u
                    clrb
L06E7               lda       ,u+
                    sta       <43-1,u
                    incb
                    cmpb      #43
                    blo       L06E7
                    puls      u
L06F5               lda       #-43
                    leau      a,u
                    bra       L06C5

L06FC               lda       >$1A35
                    cmpa      #11
                    bne       L0707
                    clra
                    puls      pc,u,y,x,b

L0707               clrb
L0708               lda       b,x
                    sta       b,y
                    incb
                    cmpb      #$2B
                    blo       L0708
                    lda       >$1A35
                    puls      pc,u,y,x,b

L0716               sta       >$1A3A
                    ldu       >$0D92              Get worth of all players items at end of game
                    ldd       #10                 Divide by 10
                    lbsr      L3C5C               U=U/D (remainder in D)
                    pshs      u                   Save result
                    ldd       >$0D92              Get worth of all players items again
                    subd      ,s++                Subtract 1/10th of that amount
                    std       >$0D92              Save new worth
                    lbsr      L6D6F               Clear the window
                    ldy       #$0001
                    lda       >$37CE
                    ldb       >$37CD
                    decb
                    tfr       d,x
                    lbsr      L6493
                    lda       >$37CE
                    suba      #$0E
                    sta       >$1A3B
                    bge       L0773
                    lda       #$09
                    adda      >$1A3B
                    ldx       #$1A77              'You died.'
                    lbsr      L6D56
                    ldu       >$0D92
                    pshs      u
                    ldu       #$1A6A              'WORTH: %u Au'
                    pshs      u
                    ldx       #$35BF
                    lbsr      L3D23
                    leas      4,s
                    lda       #$0B
                    adda      >$1A3B
                    lbsr      L6D56
                    lbra      L0823

L0773               ldx       #$1A81              '_____' (5)
                    lda       #$01
                    adda      >$1A3B
                    lbsr      L6D56
                    ldx       #$1A87              '/     \'
                    lda       #$02
                    adda      >$1A3B
                    lbsr      L6D56
                    ldx       #$1A8F              'I  RIP  I'
                    lda       #$03
                    adda      >$1A3B
                    lbsr      L6D56
                    ldx       #$1A99              'I       I'  (these 3 could be compressed to point to the same entry)
                    lda       #$04
                    adda      >$1A3B
                    lbsr      L6D56
                    ldx       #$1AA3              'I       I'
                    lda       #$05
                    adda      >$1A3B
                    lbsr      L6D56
                    ldx       #$1AAD              'I       I'
                    lda       #$06
                    adda      >$1A3B
                    lbsr      L6D56
                    lda       >$1A3A
                    ldb       #$01
                    lbsr      L0ABE
                    pshs      u
                    ldu       #$14B0              'Rodney'
                    pshs      u
                    ldu       #$1A3C              'Here lies %s killed by %s.'
                    pshs      u
                    ldx       #$35BF
                    lbsr      L3D23
                    leas      6,s
                    lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    adda      #$04
                    cmpa      >$37CB
                    bhi       L07E5
                    lda       #$09
                    adda      >$1A3B
                    lbsr      L6D56
                    bra       L0809

L07E5               ldu       #$14B0              'Rodney'
                    pshs      u
                    ldu       #$1AB7              'Here lies %s'
                    pshs      u
                    ldx       #$35BF
                    lbsr      L3D23
                    leas      4,s
                    lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    adda      #$04
                    cmpa      >$37CB              wider than window width?
                    bhi       L0823
                    lda       #$09
                    adda      >$1A3B
                    lbsr      L6D56
L0809               ldu       >$0D92
                    pshs      u
                    ldu       #$1A57              'TOTAL WORTH: %u Au'
                    pshs      u
                    ldx       #$35BF
                    lbsr      L3D23
                    leas      4,s
                    lda       #$0B
                    adda      >$1A3B
                    lbsr      L6D56
L0823               ldu       >$0D92
                    clra
                    ldb       >$1A3A
                    lbsr      L0434
                    lbra      L0195

L0830               lbsr      L6D6F
                    ldu       #$1AC9              See text breakdown in comments below:
* U points to multi-line win screen:
*Congratulations!
*You have made it to the light of day!
*
*
*
*
*
*You journey home and sell all your
*loot at a great profit and are
*admitted to the fighters guild.
*
*
                    pshs      u
                    lbsr      L6D16
                    leas      2,s
                    lda       >$37CE
                    clrb
                    lbsr      L6CDE               CurXY to b,a
                    ldx       #$1B84              '--Press space to continue--'
                    lbsr      L6D07               Write out string @ X (NUL terminated)
                    lda       #$20
                    lbsr      L62E5
                    lbsr      L6D6F
                    ldx       #$1BA0              '    Worth  Item<CRLF>    -----  ----'
                    lbsr      L6D07               Write out string @ X (NUL terminated)
                    lda       #4
                    sta       >$3CCB
                    ldd       >$0D92              ?Get cumulative worth of items
                    std       >$1AC7              ?Save copy
                    lda       #'a                 $61 - letter for first object (done 'a' through 'z', like inventory list)
                    sta       >$1AC6
                    ldx       >$10F5              Get ptr to root object in backpack
* 6809 - could change to leax ,x (1 byte shorter, 1 cycle longer)
* Loop to calculate worth of each item player has when they have one the game
* First up - food: 2 gold per food
L086B               cmpx      #$0000              No more entries, skip ahead
                    lbeq      L0A67
                    lda       4,x                 Get object type
                    cmpa      #$CC                Is it food?
                    bne       L0883               No, skip ahead
                    ldb       $E,x                Get how many food player has
                    clra                          Food is worth 2 gold per food
                    lslb
                    rola
                    lbra      L0A1C

* Weapons - table of worths by weapon type, + (combined blessing/curse values*3)
L0883               cmpa      #$CF                Weapon?
                    bne       L08B1               No, skip ahead
                    lda       $F,x                Get weapon type
                    ldu       #$00BD              Point to weapon worth tbl
                    ldb       a,u                 Get worth of weapon
                    clra
                    std       >$1AC4              Save value
                    lda       #3
                    ldb       <$10,x              Get blessing level (chance to hit?) (+/-)
                    addb      <$11,x              Add extra damage value (+/-)
                    mul                           Multiply total by 3
                    addb      $E,x                Add qty of object
                    ldu       >$1AC4              Get original weapon value
                    lbsr      L3CCE               D=D*U
                    std       >$1AC4              Save full point value
                    lda       <$13,x              Get object flags
                    ora       #%00000010          $02 Flag as fully identified by player
                    sta       <$13,x              Save object flags
                    lbra      L0A1F

* Armor: Base type value + (armor class-2ndary value)*10
L08B1               cmpa      #$D0                Armor?
                    bne       L08EC               No, skip ahead
                    lda       $F,x                Get type of armor
                    ldu       #$013E              Point to armor worth table
                    ldb       a,u                 Get base value
                    clra                          Make 16 bit
                    std       >$1AC4              Save it
                    ldd       #$0964              A=9, B=100
                    suba      <$12,x              Subtract armor class (so better armor is lower number)
                    mul                           * 100
                    addd      >$1AC4              Add to base worth and save it
                    std       >$1AC4
                    lda       #10                 10*Armor type #
                    ldb       $F,x
                    ldu       #$014E              Another table for armor values (based on armor class-higher # is lower class)
                    ldb       b,u                 Get value
                    subb      <$12,x              Subtract actual armor class
                    mul                           * 10
                    addd      >$1AC4              Add to worth
                    std       >$1AC4
                    lda       <$13,x              Set 'identified' in object flags
                    ora       #%00000010          $02
                    sta       <$13,x
                    lbra      L0A1F

* Scroll: (base value *10)*qty of scroll. Divide that value by 2 if unidentified
L08EC               cmpa      #$CD                Scroll?
                    bne       L0928               No, skip ahead
                    lda       $F,x                Get scroll type
                    ldb       #4                  4 bytes/entry
                    mul
                    addd      #$0159              Base of special scroll table
                    tfr       d,u                 Move to indexable register
                    lda       ,u                  Get base value
                    ldb       #10                 *10
                    mul
                    std       >$1AC4              Save it
                    ldb       $E,x                Get qty of scroll
                    clra
                    ldu       >$1AC4              Get current value
                    lbsr      L3CCE               D=D*U
                    std       >$1AC4              Save new result
                    lda       $F,x                Get scroll type
                    ldu       #$05FE              Point to tbl of scrolls known to player
                    tst       a,u                 Is this scroll known?
                    bne       L091F               Yes, skip ahead
                    ldd       >$1AC4              If not, cut point value by half
                    lsra
                    rorb
                    std       >$1AC4
L091F               lda       $F,x                Get scroll type
                    ldb       #1                  Flag that scroll is known to player
                    stb       a,u
                    lbra      L0A1F

* Potion: (Base value*10)*10. Divide by 2 if unknown to player
L0928               cmpa      #$CE                Potion?
                    bne       L0964               No, try next
                    lda       $F,x                Get potion type
                    ldb       #4                  4 bytes per entry
                    mul
                    addd      #$0265              Add to base ptr to table+3 (where value is)-tbl itself starts at u0262
                    tfr       d,u
                    lda       ,u                  Get base value
                    ldb       #10                 *10
                    mul
                    std       >$1AC4              Save it
                    ldb       $E,x                Get qty of potion
                    clra
                    ldu       >$1AC4              Multiply value * qty
                    lbsr      L3CCE               D=D*U
                    std       >$1AC4              Save it
                    lda       $F,x                Get type of potion
                    ldu       #$060D              Point to tbl with known potion types
                    tst       a,u                 Does player know this one?
                    bne       L095B               Yes, skip ahead
                    ldd       >$1AC4              No, divide value by 2
                    lsra
                    rorb
                    std       >$1AC4
L095B               lda       $F,x                Flag that is it known now
                    ldb       #$01
                    stb       a,u
                    lbra      L0A1F

* Ring - (base value *10)+10 (if cursed -1 or worse) or + (blessing level*100). Divide by 2 if not identified
L0964               cmpa      #$D1                Ring?
                    bne       L09C7               No, check next
                    lda       $0F,x               Get ring type
                    ldb       #4                  4 bytes/entry
                    mul
                    addd      #$034F              Point to start of tbl, 4th entry (value)
                    tfr       d,u
                    lda       ,u                  Get base value
                    ldb       #10                 *10
                    mul
                    std       >$1AC4              Save it
                    lda       $F,x                Get type
                    beq       L098C               If protection, add some more
                    cmpa      #1                  If Add strength, add some more
                    beq       L098C
                    cmpa      #8                  If Increase damage, add some more
                    beq       L098C
                    cmpa      #7                  If not Dexterity, skip adding
                    bne       L09A4
* Protection, add strength, increase damage or dexterity, add more here
L098C               lda       <$12,x              Get blessing/curse value
                    ble       L099E               If negative (cursed), skip ahead
                    ldb       #100                Blessing value * 100
                    mul
                    addd      >$1AC4              Add to value
                    std       >$1AC4
                    bra       L09A4

L099E               ldd       #10                 If cursed (negative blessing), force value to 10
                    std       >$1AC4
L09A4               lda       <$13,x              Get object flags
                    anda      #%00000010          $02 Was object identified?
                    bne       L09B3               Yes, skip ahead
                    ldd       >$1AC4              No, divide value by 2
                    lsra
                    rorb
                    std       >$1AC4
* 6309 - replace next 3 lines with oim #2,<$13,x
L09B3               lda       <$13,x              Get object flags
                    ora       #%00000010          $02 Flag it as identified
                    sta       <$13,x
                    lda       $F,x                Get type
                    ldu       #$061B              Point to other identified (named by player?) table
                    ldb       #1                  Flag it as identified/named?
                    stb       a,u
                    bra       L0A1F

* Wand/staff - (base value*10)+(# charges*20). Divide by 2 if unidentified
L09C7               cmpa      #$D2                Wand/staff?
                    bne       L0A0C               No, skip ahead
                    lda       $F,x                Get type
                    ldb       #4                  4 bytes/entry
                    mul
                    addd      #$043F              Point to tbl+3 (4th byte is value)
                    tfr       d,u
                    lda       ,u                  Get base value
                    ldb       #10                 *10
                    mul
                    std       >$1AC4              Save it
                    lda       <$12,x              Get # of charges?
                    ldb       #20                 *20
                    mul
                    addd      >$1AC4              Add to base value
                    std       >$1AC4              Save updated value
                    lda       <$13,x              Get object flags
                    anda      #%00000010          $02 Identified?
                    bne       L09F8               Yes, skip ahead
                    ldd       >$1AC4              No, divide value by 2
                    lsra
                    rorb
                    std       >$1AC4              Save it back
L09F8               lda       <$13,x              Get object flags
                    ora       #%00000010          $02 Flag as identified
                    sta       <$13,x
                    lda       $F,x                Get type
                    ldu       #$0629              Point to other identified (named by player?) tbl
                    ldb       #1                  Flag as identified
                    stb       a,u
                    bra       L0A1F

L0A0C               cmpa      #$D5                Amulet of Yendor?
                    bne       L0A19               No, force value to 0
                    ldd       #1000               1000 points
                    bra       L0A1C

L0A19               ldd       #$0000              Force current item worth to 0
L0A1C               std       >$1AC4              Save updated item worth
L0A1F               ldd       >$1AC4              Get current item worth
                    bpl       L0A2A               If >0, use that value
                    ldd       #$0000              If negative, use 0
                    std       >$1AC4
L0A2A               pshs      x                   Save object ptr
                    clra
                    lbsr      L72B6               Generate string description of object
                    pshs      u
                    ldu       >$1AC4              Get item worth
                    pshs      u                   Save it
                    lda       >$1AC6              Get current inventory letter
                    pshs      a                   Save that
                    ldu       #$1B76              '%c) %5d  %s'
                    pshs      u                   Save ptr to formatting string
                    ldx       #$4AE4              Point to string buffer
                    lbsr      L3D23               Print string
                    leas      7,s                 Eat temp stack
                    ldd       #$1470              Point to string buffer #1
                    ldy       #$4AE4              Point to string buffer #2
                    lbsr      L7B5E               ? 'Select item' prompt?
                    puls      x
                    ldd       >$0D92              Get cumulative worth of items?
                    addd      >$1AC4              Add item worth
                    std       >$0D92              Save back
                    inc       >$1AC6              bump to next inventory letter
                    ldx       ,x                  Get ptr to next inventory object in linked list
                    lbra      L086B               Loop back through remaining items that player has

L0A67               ldd       #$1470
                    ldy       #$1B82              ' '
                    lbsr      L7B5E
                    ldu       >$1AC7              Get original amount of gold
                    pshs      u                   Save for print routine
                    ldu       #$1BC4              '   %5u  Gold Pieces'
                    pshs      u
                    ldx       #$4AE4              Buffer to copy string to
                    lbsr      L3D23               Generate string
                    leas      4,s
                    ldd       #$1470
                    ldy       #$4AE4
                    lbsr      L7B5E
                    ldd       #$1470
                    ldy       #$1B82              ' '
                    lbsr      L7B5E
                    ldu       >$0D92              Get full cumulative score (gold+items,etc.)
                    pshs      u
                    ldu       #$1BD8              '   %5u  TOTAL SCORE'
                    pshs      u
                    ldx       #$4AE4              Buffer to copy string to
                    lbsr      L3D23               Generate string
                    leas      4,s
                    ldd       #$1470
                    ldy       #$4AE4
                    lbsr      L7B5E
                    ldu       >$0D92              Get full cumulative score again
                    lda       #2
                    lbsr      L0434               Check/update score file
                    lbra      L0195               Exit rogue

* Entry: A=cause of players death (ASCII char)
*        B=1 (always seems to be case)
L0ABE               pshs      y,x,d
                    ldx       #$4B34
                    ldy       #$0001
                    cmpa      #'a                 $61
                    bne       L0AD1
                    ldu       #$1BED              'arrow'
                    bra       L0B1E

L0AD1               cmpa      #'b                 $62
                    bne       L0ADB
                    ldu       #$1BF3              'bolt'
                    bra       L0B1E

L0ADB               cmpa      #'d                 $64
                    bne       L0AE5
                    ldu       #$1BF8              'dart'
                    bra       L0B1E

L0AE5               cmpa      #'s                 $73
                    bne       L0AF3
                    ldu       #$1BFD              'starvation'
                    ldy       #$0000
                    bra       L0B1E

L0AF3               cmpa      #'f                 $66
                    bne       L0AFD
                    ldu       #$1C08              'fall'
                    bra       L0B1E

L0AFD               cmpa      #'A                 $41
                    blo       L0B17               Not a regular death or monster - use 'God' as cause of death
                    cmpa      #'Z                 $5A
                    bhi       L0B17               Not a regular death or monster - use 'God' as cause of death
                    pshs      b                   Save ?
                    suba      #$41                convert to 0-25
                    ldb       #18                 Multiply by 18 for offset
                    mul
                    addd      #$10FB              Offset into monster table
                    tfr       d,u
                    ldu       ,u                  Get ptr to full monster name
                    puls      b                   Restore ?
                    bra       L0B1E

* Should never get here - player died due to completely unknown reason
L0B17               ldu       #$1C0D              'God'
                    ldy       #$0000
* Entry: Y=0 or 1
*        A=ASCII char cause of death
*        B=1
*        U=Ptr to string of what killed player
L0B1E               tstb                          ??? from what I can tell, B=1 always
                    beq       L0B3C               ??? If B=0 skip ahead
                    leay      ,y                  Is Y=0?
                    beq       L0B3C               Yes, skip ahead
                    pshs      u                   If Y=1, save ptr to string of what killed player
                    lbsr      L56E3               Get NUL or 'n' to append to 'a' (proper english for prefixing a word starting with vowel)
                    pshs      u
                    ldu       #$1C11              'a%s '
                    pshs      u
                    lbsr      L3D23               Print 'a' or 'an'
                    leas      4,s
                    puls      u
                    bra       L0B3F

L0B3C               clr       >$4B34
L0B3F               lbsr      L3FFD               Append string in U to string in X
                    leau      ,x
                    puls      pc,y,x,d

* Called when going up or down dungeon level. Initializing next level map
* Clears 6,x - 9,x in each room block
L0B46               pshs      u,y,x,d
                    lda       >$0D91              Get players level in dungeon
                    sta       >$1C20              Save copy
* A=width of room block (26), B=height of room block (7)
                    ldd       #$1A07              (80/3, 23/3) - originally called divide subroutine
                    std       >$1C1C              Save both
                    ldx       #$0DBB              Point to start of "room blocks" (9 total)
                    clra
                    clrb
L0B67               std       6,x                 Zero out 4 bytes in room block
                    std       8,x
                    leax      <34,x               Point to next room block
                    cmpx      #$0EED              Done all 9 of them?
                    bne       L0B67               No, keep doing until we are
* Initialization done, start generating new room blocks
                    lda       #4                  RND(4) 0-4
                    lbsr      L63A9
                    sta       >$1C21              Save loop ctr TO value
                    clr       >$1C16              clear current loop count
L0B82               lda       >$1C16              Are we done?
                    cmpa      >$1C21
                    bhs       L0BC5               Yes, skip ahead
L0B8A               lbsr      L1997               No, get random room # that has room flag bit 2 clear, or both bits 2-3 set
                    sta       >$1C17              Save that room #
                    lbsr      L3D0A               Get ptr to that room block into X
                    lda       8,x                 Get room flags
                    anda      #%00000100          $04  Is bit 3 set?
                    bne       L0B8A               Yes, pick a different random room block #
* 6309 - OIM #2,8,x
                    lda       8,x                 No, set flag bit 2
                    ora       #%00000010          $02
                    sta       8,x
                    lda       >$1C17              Get room # we are working on
                    cmpa      #2                  Is it on the top row of room blocks?
                    bls       L0BC0               Yes, skip to next one
                    lda       >$0D91              No, get level of dungeon player is on
                    cmpa      #10                 If <=10, on to next one
                    bls       L0BC0
                    suba      #9                  If >=11, drop by 9 (3 to 17)
                    pshs      a                   Save it
                    lda       #20                 RND(20) (0-20)
                    lbsr      L63A9
                    cmpa      ,s+                 Is random #>= above #?
                    bhs       L0BC0               Yes, on to next one
* 6309 - OIM #2,8,x
                    lda       8,x                 No, set bit 3 flag
                    ora       #%00000100          $04
                    sta       8,x
L0BC0               inc       >$1C16              Inc loop ctr, keep doing until done
                    bra       L0B82

L0D55               puls      pc,u,y,x,d

* Generate 9 'rooms' for current level. NOTE: they can be just halls, too, but always 3x3 within 80x23 map
L0BC5               clr       >$1C16              Init room ctr to 0
                    ldx       #$0DBB              Point to tbl of 9 entries (each 34 bytes) - part of map definitions?
L0BCB               lda       >$1C16              Get current room ctr
                    cmpa      #9                  Done all 9 areas?
                    bhs       L0D55               Yes, exit
                    lda       #3
                    ldb       >$1C16              Current room # / 3
                    lbsr      L3CA4
                    pshs      a                   Save row # for height calc later
                    lda       >$1C1C              Get how many chars wide each 'room' area is (26)
                    mul                           Multiply by remainder (0,1,2) (so 0,26,52)
                    incb                          Add 1 (1,27,53) and save it (start pos for each 1/3 of width (room block))
                    stb       >$1C1A              Save it
                    puls      a                   Get result back for height calc
                    ldb       >$1C1D              Get how many chars high each 'room' area is (7)
                    mul                           Multiply by row # (0-2)
                    stb       >$1C1B              Save that
                    lda       8,x                 Get room flags
                    bita      #%00000010          $02 If bit 2 clear, skip ahead
                    beq       L0C3F
                    bita      #%00000100          $04 If bit 2 set & bit 3 clear, skip ahead
                    beq       L0C09
                    ldd       >$1C1A              Otherwise, get start X,Y position of block for room
                    std       ,x                  Save them as start X,Y position for room itself
                    lbsr      L1552
                    bra       L0C3C

* If room object has bit 2 set&bit 3 clear in flags, do this
L0C09               lda       >$1C1C              Get width of area a room can fit in (27)
                    suba      #2                  Drop by 2 (to leave room for connecting hallways?)
                    lbsr      L63A9               RND(A)
                    adda      >$1C1A              Add to start X of current room block
                    inca                          +1
                    sta       ,x                  Save room start X
                    lda       >$1C1D              Get height of area a room can fit in (7)
                    suba      #2                  Drop by 2 (to leave room for connecting hallways?)
                    lbsr      L63A9               RND(5)
                    adda      >$1C1B              Add to start Y of current room bloc
                    inca                          Add 1
                    sta       1,x                 Save room start Y
                    lda       #-80                Store -80 for room width???
                    sta       2,x
                    lda       #-23                Store -23 for room height???
                    sta       3,x
                    lda       1,x                 Get room start Y
                    ble       L0C09               If negative or 0, try shrinking it?
                    inca                          If not, increase by 1
                    cmpa      #23                 Hit 23?
                    bge       L0C09               Yes, try again?
L0C3C               lbra      L0D4C               No, go to next room block

* Take current room width/height and add random offsets to each so that they
*  are not always flush left in the 27x6 room blocks
L0C3F               lda       #10                 RND(10) (0-10)
                    lbsr      L63A9
                    inca                          1-11
                    cmpa      >$0D91              Compare with level player is on
                    bhs       L0C50               If random #>= dungeon level, skip ahead
* 6309 - OIM #01,8,x
                    lda       8,x
                    ora       #%00000001          $01 If not, set bit 1 flag
                    sta       8,x
L0C50               lda       >$1C1C              Get width of each possible room block (26)
                    suba      #4                  Subtract 4 (22)
                    lbsr      L63A9               RND(22)
                    adda      #4                  Add 4 and save as room width
                    sta       2,x
                    lda       >$1C1D              Get height of each possible room block (7)
                    suba      #4                  Subtract 4 (3)
                    lbsr      L63A9               RND(A)
                    adda      #4                  Add 4 and save
                    sta       3,x                 Save as room height
                    lda       >$1C1C              Get width of each horizontal room block (26)
                    suba      2,x                 Subtract width of room (width of non-room space)
                    lbsr      L63A9               RND(A) (of non-room space)
                    adda      >$1C1A              Add to start X position for current room block
                    sta       ,x                  Save that as new start X position of room
                    lda       >$1C1D              Get height of room block
                    suba      3,x                 Subtract start Y position of room (height of non-room space)
                    lbsr      L63A9               RND(A) (of non-room space)
                    adda      >$1C1B              Add to stary Y position for current room block
                    sta       1,x                 Save back as new room start Y position
                    beq       L0C50               If that Y position is 0, try generating again
                    lbsr      L0D57               Go fill in the main level map with the walls for current room
                    lda       #2
                    lbsr      L63A9               RND(2) 0-2
                    tsta
                    bne       L0CFA               If 1 or 2, skip ahead
                    tst       >$0638              ??? Some flag having to do with the Amulet?
                    beq       L0CA2               Not set, skip ahead
                    lda       >$0D91              Get players dungeon level
                    cmpa      >$0D90              ??? Compare with max dungeon level player has been to?
                    blo       L0CFA               If <,skip ahead
L0CA2               pshs      x                   Save room block ptr
                    lbsr      L6162               Get next free inventory entry (max 40)
                    leau      ,x                  Point U to it
                    puls      x                   Restore room block ptr
                    cmpu      #$0000              No room left for objects?
                    beq       L0CFA               Yes, skip ahead
                    lbsr      L3BD1               Do some calc into D based on dungeon level
                    std       6,x                 Save result in two tables
                    std       16,u
                    pshs      u
L0CBD               leau      4,x
                    lbsr      L0E1A
                    lda       5,x
                    ldb       4,x
                    lbsr      L3BBB
                    lbsr      L3C2C
                    tsta
                    beq       L0CBD
                    puls      u                   Get back object ptr
                    ldd       4,x
                    std       5,u
                    ldd       #$2001
                    sta       <$13,u              Save object flag
                    stb       <$15,u
                    lda       #$CB                Gold object
                    sta       4,u                 Save as object type
                    pshs      x
                    leax      ,u
                    ldu       #$10F7
                    lbsr      L6138
                    puls      x
                    lda       5,x
                    ldb       4,x
                    lbsr      L3CF4
                    lda       #$CB                Gold
                    sta       ,u                  Save it
L0CFA               ldd       6,x
                    beq       L0D02
                    lda       #80
                    bra       L0D04

L0D02               lda       #25
L0D04               pshs      a                   Save 25 or 80
                    lda       #100                RND(100)
                    lbsr      L63A9
                    cmpa      ,s+                 Is random #>=25 or 80 from above?
                    bge       L0D4C               Yes, skip way ahead
                    pshs      x
                    lbsr      L6162               Get next free inventory entry (max 40)
                    leau      ,x                  Move ptr to U
                    puls      x
                    cmpu      #$0000              No more empty entries?
                    beq       L0D4C               None, skip ahead
                    pshs      u
L0D22               ldu       #$1C1E
                    lbsr      L0E1A
                    lda       >$1C1F
                    ldb       >$1C1E
                    lbsr      L5AF2
                    lbsr      L3C2C
                    tsta
                    beq       L0D22
                    puls      u
                    pshs      x
                    clra                          Use 1st monster/level generation string
                    lbsr      L29A7               Generate new monster
                    ldx       #$1C1E
                    lbsr      L29E5
                    leax      ,u
                    lbsr      L2C88
                    puls      x
L0D4C               inc       >$1C16              Bump up "room area" ctr
                    leax      <34,x               Point to next "room area" entry
                    lbra      L0BCB               Keep doing until all 9 are done

* Entry: X=ptr to 1 of 9 "room blocks" (starting at >$0DBB)
* This populates the room in map 2 (Full map) @ $4b84 with corners
*  and floor
L0D57               pshs      u,d
                    lda       1,x                 Get top Y coord
                    adda      3,x                 Add height
                    deca                          -1
                    sta       >$1C23              Save bottom Y coord
                    lda       ,x                  Get left X coord
                    adda      2,x                 Add width
                    deca                          -1
                    sta       >$1C22              Save right X coord
                    lda       ,x                  Get left X coord
                    bsr       L0DD2               Add vertical wall for left side
                    lda       >$1C22              Get right X coord
                    bsr       L0DD2               Add vertical wall for right side
                    lda       1,x                 Get upper Y coord
                    bsr       L0DF7               Add horizontal wall for top
                    lda       >$1C23              Get bottom Y coord
                    bsr       L0DF7               Add horizontal wall for bottom
                    lda       1,x                 Get upper Y
                    ldb       ,x                  Get left X
                    lbsr      L3CF4               Get address in map 2 ($4b84)
                    lda       #$C6                Upper left corner wall
                    sta       ,u                  Save in map 2
                    lda       1,x                 Get upper Y
                    ldb       >$1C22              Get right X
                    lbsr      L3CF4               Get address in map 2 ($4b84)
                    lda       #$C7                upper right corner wall
                    sta       ,u                  Save in map 2
                    lda       >$1C23              Get bottom Y
                    ldb       ,x                  Get left X
                    lbsr      L3CF4               Get address in map 2 ($4b84)
                    lda       #$C8                Lower left corner wall
                    sta       ,u                  Save in map 2
                    lda       >$1C23              Get bottom Y
                    ldb       >$1C22              Get right X
                    lbsr      L3CF4               Get address in map 2 ($4b84)
                    lda       #$C9                Lower right corner wall
                    sta       ,u                  Save in map 2
* Set up outside loop
                    lda       1,x                 Get height
                    inca                          Bump up by 1
L0DB2               cmpa      >$1C23              compare with bottom Y
                    bhs       L0DF4               If we are past the bottom,exit
* Set up inside loop
                    ldb       ,x                  Get width
                    incb                          Bump up by 1
L0DBA               cmpb      >$1C22              Past right side?
                    bhs       L0DCD               Yes, go to next line
                    pshs      a                   Save working Y coord
                    lbsr      L3CF4               Get address in map 2 ($4b84)
                    lda       #$C2                Floor
                    sta       ,u                  Save in map 2
                    puls      a                   Get working Y coord back
                    incb                          Move to next X coord & loop back
                    bra       L0DBA

L0DCD               inca                          Bump up working Y coord & loop back
                    bra       L0DB2

* Add vertical wall for entire side of room
* Entry: A=X coord for either left or right side of room
L0DD2               pshs      u,d
                    tfr       a,b                 Dupe coord into B
                    lda       1,x                 Get start Y coord
                    sta       >$1C24              Save working Y coord
L0DDB               lda       1,x                 Get start Y coord
                    adda      3,x                 Add room width
                    deca                          -1
                    cmpa      >$1C24              Have we hit bottom row of room yet?
                    blo       L0DF4               No, return
                    lda       >$1C24              Yes, get bottom row of room
                    lbsr      L3CF4               Get address in map 2 ($4b84)
                    lda       #$C5                Vertical wall
                    sta       ,u                  Save in map 2
                    inc       >$1C24              Bump up working Y coord
                    bra       L0DDB               Keep adding vertical walls until done

L0DF4               puls      pc,u,d

* Add horizontal wall for entire side of room
* Entry: A=Y coord for either top or bottom of room
L0DF7               pshs      u,b
                    ldb       ,x                  Get start X coord
                    stb       >$1C25              Save working copy
L0DFE               ldb       ,x                  Get start X coord
                    addb      2,x                 Add width
                    decb                          -1
                    cmpb      >$1C25              Past left side?
                    blo       L0E17               Yes, return
                    ldb       >$1C25              Get X working copy
                    lbsr      L3CF4               Get address in map 2 ($4b84)
                    ldb       #$C4                Horizontal wall
                    stb       ,u                  Save in map 2
                    inc       >$1C25              Bump up working X coord
                    bra       L0DFE               Keep doing until done entire wall

L0E17               puls      pc,u,b

L0E1A               pshs      d
                    lda       2,x
                    suba      #2
                    lbsr      L63A9               RND(A)
                    inca
                    adda      ,x
                    sta       ,u
                    lda       3,x
                    suba      #2
                    lbsr      L63A9               RND(A)
                    inca
                    adda      1,x
                    sta       1,u
                    puls      pc,d

L0E36               pshs      u,x,d
                    leau      ,x
                    lbsr      L281F               Get ptr into tbl @ $EED into U based on some x,y coords
                    stu       >$10F3              Save it
                    tst       >$063F              Check flag/ctr
                    bne       L0E51               <>0, return
                    lda       8,u
                    bita      #%00000010          $02 Is bit 2 set?
                    beq       L0E53               No, skip ahead
                    anda      #%00000100          $04 Is bit 3 set?
                    bne       L0E53               Yes, skip ahead, else return
L0E51               puls      pc,u,x,d

L0E53               lbsr      L1F45
                    lda       8,u
                    anda      #%00000001          $01
                    bne       L0ED8
                    ldx       #$10D8
                    ldd       #$0001
                    lbsr      L3C3C
                    tsta
                    bne       L0ED8
                    lda       8,u
                    anda      #$04
                    bne       L0ED8
                    lda       1,u
                    sta       >$1C27
                    adda      3,u
                    sta       >$1C29
L0E7A               lda       >$1C27
                    cmpa      >$1C29
                    bhs       L0ED8
                    lda       >$1C27
                    ldb       ,u
                    std       >$355B
                    lda       ,u
                    sta       >$1C26
                    adda      2,u
                    sta       >$1C28
L0E94               lda       >$1C26
                    cmpa      >$1C28
                    bhs       L0ED3
                    lda       >$1C27              Get Y coord to search for
                    ldb       >$1C26              Get X coord to search for
                    lbsr      L2CDB               Search monster object list for matching monster in same position
                    cmpx      #$0000
                    beq       L0EB0               None, skip ahead
                    lbsr      L25F0
                    tsta
                    bne       L0EBE
L0EB0               lda       >$1C27
                    ldb       >$1C26
                    lbsr      L3BBB
                    lbsr      L6612
                    bra       L0ECE

L0EBE               lda       >$1C27
                    ldb       >$1C26
                    lbsr      L3BBB
                    sta       9,x
                    lda       8,x
                    lbsr      L6612
L0ECE               inc       >$1C26
                    bra       L0E94

L0ED3               inc       >$1C27
                    bra       L0E7A

L0ED8               puls      pc,u,x,d

L0EDA               pshs      u,x,d
                    ldu       >$10F3
                    lda       1,x
                    ldb       ,x
                    lbsr      L3BC6
                    anda      #$0F
                    ldb       #$22
                    mul
                    addd      #$0EED
                    std       >$10F3
                    lda       8,u
                    anda      #$01
                    beq       L0F07
                    ldx       #$10D8
                    ldd       #$0001
                    lbsr      L3C3C
                    tsta
                    bne       L0F07
                    lda       #$20                Blank (non-active map object)
                    bra       L0F09

L0F07               lda       #$C2                Floor
L0F09               sta       >$1C2B              Save it
                    lda       8,u
                    anda      #$04
                    beq       L0F17
                    lda       #$C3
                    sta       >$1C2B
L0F17               lda       1,u
                    inca
                    sta       >$1C2D
                    lda       3,u
                    adda      1,u
                    deca
                    sta       >$1C2F
L0F25               lda       >$1C2D
                    cmpa      >$1C2F
                    bhs       L0FB2
                    lda       ,u
                    inca
                    sta       >$1C2C
                    lda       2,u
                    adda      ,u
                    deca
                    sta       >$1C2E
L0F3D               lda       >$1C2C
                    cmpa      >$1C2E
                    bhs       L0FAC
                    lda       >$1C2D
                    ldb       >$1C2C
                    lbsr      L68D2
                    sta       >$1C2A              Save copy of map element
                    cmpa      #$20                Blank (background, not active map)?
                    beq       L0FA7               Yes, skip ahead
                    cmpa      #$C3                Hallway?
                    beq       L0FA7
                    cmpa      #$D4                Trap?
                    beq       L0FA7
                    cmpa      #$D3                Stairs?
                    beq       L0FA7
                    cmpa      #$C2                Floor?
                    bne       L0F71
                    lda       >$1C2B
                    cmpa      #$20
                    bne       L0FA7
                    lbsr      L6612
                    bra       L0FA7

* Not sure, but something to do with seeing objects/monsters in a room when
* entering/leaving (either turns them on or off after you enter/exit doorway)
L0F71               anda      #%01111111          $7F
                    lbsr      L3EF6
                    tsta
                    beq       L0FA1
                    ldx       #$10D8
                    ldd       #$0002
                    lbsr      L3C3C
                    tsta
                    beq       L0F94
                    lda       >$1C2A
                    lbsr      L6612
                    bra       L0FA7

L0F94               lda       >$1C2D              Get Y coord to search for
                    ldb       >$1C2C              Get X coord to search for
                    lbsr      L2CDB               Search monster object list for matching monster in same position
                    lda       #$40
                    sta       9,x
L0FA1               lda       >$1C2B
                    lbsr      L6612
L0FA7               inc       >$1C2C
                    bra       L0F3D

L0FAC               inc       >$1C2D
                    lbra      L0F25

L0FB2               lbsr      L1F45
                    puls      pc,u,x,d

L0FB7               pshs      u,y,x,d
                    std       >$1C32
                    pshs      b
                    cmpa      ,s+
                    bhs       L0FDD
                    sta       >$1C39
                    inca
                    pshs      b
                    cmpa      ,s+
                    bne       L0FD6
                    lda       #$72
                    sta       >$1C3D
                    bra       L0FF3

L0FD6               lda       #$64
                    sta       >$1C3D
                    bra       L0FF3

L0FDD               stb       >$1C39
                    incb
                    pshs      a
                    cmpb      ,s+
                    bne       L0FEE
                    lda       #$72
                    sta       >$1C3D
                    bra       L0FF3

L0FEE               lda       #$64
                    sta       >$1C3D
L0FF3               ldb       >$1C39
                    lda       #$22
                    mul
                    addd      #$0DBB
                    std       >$1C34
                    tfr       d,y                 Smaller, faster
                    lda       >$1C3D
                    cmpa      #$64
                    lbne      L10C2
                    lda       >$1C39
                    adda      #$03
                    sta       >$1C38              Save entry #
                    ldb       #34                 Size of each entry
                    mul
                    addd      #$0DBB              Point to entry in table
                    std       >$1C36
                    tfr       d,x                 Smaller, faster
                    ldx       >$1C36
                    clr       >$1C3E
                    lda       #$01
                    sta       >$1C3F
                    lda       8,y
                    tfr       a,b
                    anda      #$02
                    beq       L1034
                    andb      #$04
                    beq       L1057
L1034               lda       1,y
                    adda      3,y
                    deca
                    sta       >$1C45
L103C               lda       2,y                 Get ???
                    suba      #2                  RND(2,y)-2
                    lbsr      L63A9
                    inca
                    adda      ,y
                    sta       >$1C44              Save X coord
                    tfr       a,b                 Move to B
                    lda       >$1C45              Get Y coord
                    lbsr      L3BBB               Get element from map #1 @ coords
                    cmpa      #$20                Empty (not active part of map)?
                    beq       L103C               yes, go back
                    bra       L1061               No, skip ahead

L1057               ldd       ,y
                    std       >$1C44
L1061               lda       1,x
                    sta       >$1C47
                    lda       8,x
                    tfr       a,b
                    anda      #$02
                    beq       L1072
                    andb      #$04
                    beq       L108D
L1072               lda       2,x
                    suba      #2
                    lbsr      L63A9               RND(A)
                    inca
                    adda      ,x
                    sta       >$1C46
                    tfr       a,b
                    lda       >$1C47
                    lbsr      L3BBB
                    cmpa      #$20
                    beq       L1072
                    bra       L1092

L108D               lda       ,x
                    sta       >$1C46
L1092               lda       >$1C45
                    suba      >$1C47
                    lbsr      L3BB6               ABS of A
                    deca
                    sta       >$1C3A
                    clr       >$1C43
                    lda       >$1C44
                    cmpa      >$1C46
                    blo       L10AE
                    lda       #$FF
                    bra       L10B0

L10AE               lda       #$01
L10B0               sta       >$1C42
                    lda       >$1C44
                    suba      >$1C46
                    lbsr      L3BB6               ABS of A
                    sta       >$1C3C
                    lbra      L1170

L10C2               lda       >$1C39
                    inca
                    sta       >$1C38              Save room # we are checking for
                    ldb       #$22                34 bytes/entry
                    mul
                    addd      #$0DBB              Add to start of tbl
                    std       >$1C36
                    tfr       d,x                 smaller/faster
                    lda       #$01
                    sta       >$1C3E
                    clr       >$1C3F
                    lda       8,y
                    tfr       a,b
                    anda      #%00000010          $02
                    beq       L10E9
                    andb      #$04
                    beq       L110A
L10E9               lda       ,y
                    adda      2,y
                    deca
                    sta       >$1C44
L10F1               lda       3,y
                    suba      #$02
                    lbsr      L63A9               RND(A)
                    inca
                    adda      1,y
                    sta       >$1C45              Get Y coord
                    ldb       >$1C44              Get X coord
                    lbsr      L3BBB               Get map char for that coordinate
                    cmpa      #$20                Unused background?
                    beq       L10F1               Yes, try again
                    bra       L1114               No, skip ahead

L110A               ldd       ,y
                    std       >$1C44
L1114               lda       ,x
                    sta       >$1C46
                    lda       8,x
                    tfr       a,b
                    anda      #$02
                    beq       L1125
                    andb      #$04
                    beq       L113E
L1125               lda       3,x
                    suba      #2
                    lbsr      L63A9               RND(A)
                    inca
                    adda      1,x
                    sta       >$1C47              Y coord
                    ldb       >$1C46              Get X coord
                    lbsr      L3BBB               Get map char for that coordinate
                    cmpa      #$20                unused background?
                    beq       L1125               Yes, try again
                    bra       L1143               skip ahead

L113E               lda       1,x
                    sta       >$1C47
L1143               lda       >$1C44
                    suba      >$1C46
                    lbsr      L3BB6               ABS of A
                    deca
                    sta       >$1C3A
                    lda       >$1C45
                    cmpa      >$1C47
                    blo       L115C
                    lda       #-1
                    bra       L115E

L115C               lda       #1
L115E               sta       >$1C43
                    clr       >$1C42
                    lda       >$1C45
                    suba      >$1C47
                    lbsr      L3BB6               ABS of A
                    sta       >$1C3C
L1170               lda       >$1C3A
                    deca
                    beq       L1179
                    lbsr      L63A9               RND(A)
L1179               inca
                    sta       >$1C3B
                    lda       8,y
                    anda      #$02
                    bne       L1192
                    tfr       y,d
                    pshs      y
                    ldy       #$1C44
                    lbsr      L13DE
                    puls      y
                    bra       L119B

L1192               lda       >$1C45
                    ldb       >$1C44
                    lbsr      L153B
L119B               lda       8,x
                    anda      #$02
                    bne       L11B0
                    tfr       x,d
                    pshs      x
                    ldy       #$1C46
                    lbsr      L13DE
                    puls      x
                    bra       L11B9

L11B0               lda       >$1C47
                    ldb       >$1C46
                    lbsr      L153B
L11B9               lda       >$1C44
                    sta       >$1C40
                    lda       >$1C45
                    sta       >$1C41
L11C5               lda       >$1C3A
                    beq       L1215
                    ldb       >$1C40
                    addb      >$1C3E
                    stb       >$1C40
                    ldb       >$1C41
                    addb      >$1C3F
                    stb       >$1C41
                    cmpa      >$1C3B
                    bne       L1207
L11E1               lda       >$1C3C
                    dec       >$1C3C
                    tsta
                    beq       L1207
                    lda       >$1C41
                    ldb       >$1C40
                    lbsr      L153B
                    lda       >$1C40
                    adda      >$1C42
                    sta       >$1C40
                    lda       >$1C41
                    adda      >$1C43
                    sta       >$1C41
                    bra       L11E1

L1207               lda       >$1C41
                    ldb       >$1C40
                    lbsr      L153B
                    dec       >$1C3A
                    bra       L11C5

L1215               ldd       >$1C40
                    adda      >$1C3E
                    addb      >$1C3F
                    std       >$1C40
                    ldd       #$1C40
                    ldu       #$1C46
                    lbsr      L5A95
                    tsta
                    bne       L124E
                    ldb       >$1C46
                    subb      >$1C3E
                    stb       >$1C46
                    lda       >$1C47
                    suba      >$1C3F
                    sta       >$1C47
                    lbsr      L153B
L124E               puls      pc,u,y,x,d

L1250               pshs      u,y,x,d
                    ldu       #$1C48
                    stu       >$1CF3
                    ldd       #$1CF3
                    std       >$1CFA
                    clr       >$1CF8
L1261               cmpu      >$1CFA
                    bhs       L127D
                    lda       >$1CF8
L126A               cmpa      #9
                    bhs       L1275
                    leax      9,u
                    clr       a,x
                    inca
                    bra       L126A

L1275               clr       <$12,u
                    leau      <$13,u
                    bra       L1261

L127D               lda       #$01
                    sta       >$1CF9
                    lda       #9                  RND(9)
                    lbsr      L63A9
                    ldb       #19                 *19 (tbl entry size)
                    mul
                    addd      #$1C48              Add to tbl start address
                    std       >$1CF3
                    tfr       d,u
                    lda       #1
                    sta       <$12,u
                    leax      ,u
L1299               clr       >$1CF7
                    clr       >$1CF8
L129F               lda       >$1CF7
                    cmpa      #9
                    bhs       L12D5
                    tst       a,x
                    beq       L12D0
                    ldb       #19
                    mul
                    addd      #$1C5A
                    tfr       d,y
                    tst       ,y
                    bne       L12D0
                    inc       >$1CF8
                    lda       >$1CF8              RND(A)
                    lbsr      L63A9
                    tsta
                    bne       L12D0
                    lda       >$1CF7
                    ldb       #19
                    mul
                    addd      #$1C48
                    std       >$1CF5
L12D0               inc       >$1CF7
                    bra       L129F

L12D5               tst       >$1CF8
                    bne       L12F1
L12DA               lda       #9                  RND(9) *(Random room #?)
                    lbsr      L63A9
                    ldb       #$13                * size of each tbl entry
                    mul
                    addd      #$1C48              Add to base of tbl
                    std       >$1CF3
                    tfr       d,x
                    tst       <$12,x
                    beq       L12DA
                    bra       L1335

L12F1               ldx       >$1CF5
                    lda       #1
                    sta       <$12,x
                    ldd       >$1CF3
                    tfr       d,x
                    subd      #$1C48
                    lda       #19
                    lbsr      L3CA4               B/A
                    sta       >$1CF7              Save result (ignore remainder)
                    ldd       >$1CF5
                    tfr       d,y
                    subd      #$1C48
                    lda       #19
                    lbsr      L3CA4               B/A
                    sta       >$1CF8              Save result (ignore remainder)
                    ldd       >$1CF7
                    lbsr      L0FB7
                    lda       >$1CF8
                    leax      9,x
                    ldb       #1
                    stb       a,x
                    lda       >$1CF7
                    leax      9,y
                    stb       a,x
                    inc       >$1CF9              Bump up which "room" # we are working on
L1335               lda       >$1CF9              Get room # we are working on
                    cmpa      #9                  Still more rooms to work on?
                    lblo      L1299               Yes, loop back
                    lda       #5                  RND(5)
                    lbsr      L63A9
                    sta       >$1CF9              Save it
L1346               lda       >$1CF9
                    lbls      L13D9
                    lda       #9                  RND(9)
                    lbsr      L63A9
                    ldb       #19
                    mul
                    addd      #$1C48
                    std       >$1CF3
                    tfr       d,x
                    clr       >$1CF8
                    clr       >$1CF7
L1365               lda       >$1CF7
                    cmpa      #9
                    bhs       L1395
                    leay      ,x
                    tst       a,y
                    beq       L1390
                    leay      9,x
                    tst       a,y
                    bne       L1390
                    inc       >$1CF8
                    lda       >$1CF8
                    lbsr      L63A9               RND(A)
                    tsta
                    bne       L1390
                    lda       >$1CF7
                    ldb       #19
                    mul
                    addd      #$1C48
                    std       >$1CF5
L1390               inc       >$1CF7
                    bra       L1365

L1395               tst       >$1CF8
                    beq       L13D3
                    ldd       >$1CF3
                    tfr       d,x
                    subd      #$1C48
                    lda       #19
                    lbsr      L3CA4               B/A
                    sta       >$1CF7              Save result (ignore remainder)
                    ldd       >$1CF5
                    tfr       d,y
                    subd      #$1C48
                    lda       #19
                    lbsr      L3CA4               B/A
                    sta       >$1CF8              Save result (ignore remainder)
                    ldd       >$1CF7
                    lbsr      L0FB7
                    lda       >$1CF8
                    leax      9,x
                    ldb       #1
                    stb       a,x
                    lda       >$1CF7
                    leax      9,y
                    stb       a,x
L13D3               dec       >$1CF9
                    lbra      L1346

L13D9               bsr       L1449
                    puls      pc,u,y,x,d

L13DE               pshs      u,y,x,d
                    std       >$1CFC
                    tfr       d,u
                    lda       1,y
                    ldb       ,y
                    lbsr      L5AAA               X=offset into 80x22 map
                    stx       >$1CFE
                    lda       #10                 RND(10) 0-10
                    lbsr      L63A9
                    inca                          1-11
                    cmpa      >$0D91              If random # is >=dungeon level, skip ahead
                    bhs       L142D
                    lda       #5                  If <dungeon level, RND(5) 0-5
                    lbsr      L63A9
                    tsta
                    bne       L142D               If RND(5)<>0, skip ahead
                    lda       1,y
                    cmpa      1,u
                    beq       L1417
                    pshs      a
                    lda       1,u
                    adda      3,u
                    deca
                    cmpa      ,s+
                    beq       L1417
                    lda       #$C5                Vertical wall
                    bra       L1419               Save onto map

L1417               lda       #$C4                Horizontal wall
L1419               ldx       >$1CFE              Get ptr to current position in map
                    sta       >$4B84,x            Save wall type onto map
* 6309 - if above is true, then AIM #$EF,>$5264,x replaces all 4 lines
                    lda       #%11101111          $EF Clear bit 5 on flags map for this spot
                    anda      >$5264,x
                    sta       >$5264,x
                    bra       L1436

L142D               ldx       >$1CFE              Get ptr to current position in map
                    lda       #$CA                Door
                    sta       >$4B84,x            Save door into main map
L1436               lda       9,u
                    inc       9,u
                    ldb       1,y
                    lsla
                    leax      11,u
                    stb       a,x
                    ldb       ,y
                    leax      10,u
                    stb       a,x
                    puls      pc,u,y,x,d

L1449               pshs      u,y,x,d
                    clr       >$1C30
                    clr       >$1C31
                    ldx       #$0EED
                    ldd       #$10A7              Result of orginal code which did (13*34)+$EED
                    std       >$1D01
L145F               cmpx      >$1D01
                    bhs       L146B
                    clr       9,x
                    leax      <$22,x
                    bra       L145F

L146B               ldx       #$0DBB              Point to start of table
                    ldd       #$0EED              (9*$22+$0DBB) - point to 9th entry in table
                    std       >$1D01              Save as end of table marker
L1479               cmpx      >$1D01              Are we done to end of table?
                    bhs       L14A1               Yes, exit
                    clr       >$1D00
L1481               lda       >$1D00
                    cmpa      9,x
                    bhs       L149C
                    lsla
                    inc       >$1C31
                    leau      10,x
                    ldb       a,u
                    leau      11,x
                    lda       a,u
                    bsr       L14A3
                    inc       >$1D00
                    bra       L1481

L149C               leax      <34,x               Point to next entry
                    bra       L1479

L14A1               puls      pc,u,y,x,d

L14A3               pshs      d
                    pshs      u
                    std       >$1D03
                    lbsr      L5ADE
                    tsta
                    bne       L1537
                    lda       >$1D03
                    lbsr      L3CFF
                    lda       ,u
                    anda      #%00001111
                    bne       L1537
                    tst       >$1C31
                    beq       L14CE
                    inc       >$1C30
                    clr       >$1C31
L14CE               ldd       >$1D03              Get Y/X coord
                    lbsr      L3BBB               Get char from main map
                    cmpa      #$CA                Door?
                    beq       L14E5               Yes, skip ahead
                    ldb       ,u
                    andb      #%00010000          $10
                    bne       L150D
                    cmpa      #$C2                Floor?
                    beq       L150D               Yes, skip ahead
L14E5               pshs      u
                    lda       >$1C30              Get entry #
                    ldb       #34                 entry size
                    mul
                    addd      #$0EED              Point to our entry in tbl
                    tfr       d,u
                    lda       9,u
                    ldb       >$1D03
                    lsla
                    pshs      x
                    leax      11,u
                    stb       a,x
                    inc       9,u
                    ldb       >$1D04
                    leax      10,u
                    stb       a,x
                    puls      x
                    puls      u
                    bra       L1513

L150D               ldb       ,u
                    andb      #$40
                    beq       L1537
L1513               lda       ,u
                    ora       >$1C30
                    sta       ,u
                    puls      u
                    ldd       >$1D03
                    inca
                    bsr       L14A3
                    suba      #2
                    bsr       L14A3
                    inca
                    incb
                    bsr       L14A3
                    subb      #2
                    lbsr      L14A3
                    puls      pc,d

L1537               puls      u
                    puls      pc,d

L153B               pshs      x,d                 Save regs (A=y coord, B=X coord)
                    lbsr      L5AAA               X=offset into 80x22 map
                    ldb       #$C3                Hallway
                    stb       >$4B84,x            Save on main map
* 6309 - replace next 3 with OIM #$40,>$5264,x
                    lda       >$5264,x            Get equivalent from flags map
                    ora       #%01000000          $40 Set flag (?)
                    sta       >$5264,x
                    puls      pc,x,d

L1552               pshs      u,y,x,d
                    ldd       #$1D1A
                    std       >$1D0C
                    ldb       #$7E                2nd ptr is $1D7E
                    std       >$1D0E
                    clr       >$1D0A
                    clr       >$1D0B
                    lda       1,x
                    sta       >$1D08
                    bne       L1572
                    inc       >$1D08
                    inc       1,x
L1572               lda       ,x
                    sta       >$1D09
                    ldd       >$1D08
                    std       >$1D10
                    lbsr      L17B7
                    lbsr      L1628
L1589               tst       >$1D05
                    beq       L159C
                    lbsr      L167C
                    ldd       >$1D06
                    lbsr      L1628
                    bra       L1589

L159C               lda       >$1D0A
                    suba      ,x
                    inca
                    sta       2,x
                    lda       >$1D0B
                    suba      1,x
                    inca
                    sta       3,x
L15AC               ldu       #$1D14
                    lbsr      L0E1A
                    clr       >$1D12
                    ldy       #$1DE2
                    ldd       #$1DE2+8            Same size, 1 cyc faster for 6809 than ADDD #8
                    std       >$1D18
                    lda       #$01
                    sta       >$1D13
L15C5               cmpy      >$1D18
                    bhs       L1605
                    ldd       >$1D14
                    adda      ,y
                    addb      1,y
                    std       >$1D10
                    lbsr      L5ADE
                    tsta
                    bne       L15FA
                    lda       >$1D10
                    lbsr      L3BBB
                    cmpa      #$C3
                    bne       L15FA
                    lda       >$1D12
                    adda      >$1D13
                    sta       >$1D12
L15FA               lda       >$1D13
                    lsla
                    sta       >$1D13
                    leay      2,y
                    bra       L15C5

L1605               lda       >$1D15
                    ldb       >$1D14
                    lbsr      L3BBB
                    cmpa      #$C3                Hallway?
                    beq       L15AC               Yes, go back
                    lda       #5
                    ldb       >$1D12
                    lbsr      L3CA4               B/A
                    tstb                          Is there a remainder?
                    bne       L15AC               Yes, go back
                    lda       >$1D15
                    ldb       >$1D14
                    lbsr      L17B7
                    puls      pc,u,y,x,d

L1628               pshs      d
                    suba      #2
                    bsr       L1642
                    adda      #4
                    bsr       L1642
                    suba      #2
                    subb      #2
                    bsr       L1642
                    addb      #4
                    bsr       L1642
                    puls      pc,d

L1642               pshs      u,d
                    std       >$1DEA
                    lbsr      L17E5
                    tsta
                    beq       L167A
                    lda       >$1DEA
                    lbsr      L3BBB
                    cmpa      #$20
                    bne       L167A
                    lda       >$1DEA
                    lbsr      L3CF4
                    lda       #$46
                    sta       ,u
                    lda       >$1DEA
                    ldb       >$1D05
                    ldu       >$1D0C
                    sta       b,u
                    lda       >$1DEB
                    ldu       >$1D0E
                    sta       b,u
                    inc       >$1D05
L167A               puls      pc,u,d

L167C               pshs      u,y,x,d
                    clr       >$1DEC
                    clr       >$1DED
                    clr       >$1DF2
                    lda       >$1D05
                    lbsr      L63A9               RND(A)
                    sta       >$1DF3
                    tfr       a,b
                    ldu       >$1D0E
                    lda       b,u
                    sta       >$1D07
                    ldu       >$1D0C
                    lda       b,u
                    sta       >$1D06
                    ldb       >$1D05
                    decb
                    lda       b,u
                    ldb       >$1DF3
                    sta       b,u
                    dec       >$1D05
                    ldb       >$1D05
                    ldu       >$1D0E
                    lda       b,u
                    ldb       >$1DF3
                    sta       b,u
                    lda       >$1D06
                    suba      #2
                    ldb       >$1D07
                    lbsr      L179B
                    tsta
                    beq       L16D6
                    ldb       >$1DF2
                    ldu       #$1DEE
                    clr       b,u
                    inc       >$1DF2
L16D6               lda       >$1D06
                    adda      #2
                    ldb       >$1D07
                    lbsr      L179B
                    tsta
                    beq       L16F1
                    ldb       >$1DF2
                    ldu       #$1DEE
                    lda       #$01
                    sta       b,u
                    inc       >$1DF2
L16F1               ldd       >$1D06
                    subb      #$02
                    lbsr      L179B
                    tsta
                    beq       L170C
                    ldb       >$1DF2
                    ldu       #$1DEE
                    lda       #$02
                    sta       b,u
                    inc       >$1DF2
L170C               ldd       >$1D06
                    addb      #2
                    bsr       L179B
                    tsta
                    beq       L1727
                    ldb       >$1DF2
                    ldu       #$1DEE
                    lda       #3
                    sta       b,u
                    inc       >$1DF2
L1727               lda       >$1DF2
                    lbsr      L63A9               RND(A)
                    ldu       #$1DEE
                    ldb       a,u
                    stb       >$1DF6
                    ldd       >$1D06
                    bsr       L17B7
                    lda       >$1DF6
                    bne       L1750
                    lda       #1
                    sta       >$1DF6
                    nega
                    sta       >$1DEC
                    bra       L177B

L1750               cmpa      #1
                    bne       L175E
                    clr       >$1DF6
                    sta       >$1DEC
                    bra       L177B

L175E               cmpa      #2
                    bne       L176E
                    lda       #3
                    sta       >$1DF6
                    lda       #$FF
                    sta       >$1DED
                    bra       L177B

L176E               cmpa      #3
                    bne       L177B
                    lda       #2
                    sta       >$1DF6
                    deca
                    sta       >$1DED
L177B               ldd       >$1DEC
                    adda      >$1D06
                    addb      >$1D07
                    std       >$1DF4
                    bsr       L17E5
                    tsta
                    beq       L1799
                    lda       >$1DF4
                    bsr       L17B7
L1799               puls      pc,u,y,x,d

L179B               pshs      b
                    sta       >$1DF7
                    bsr       L17E5
                    tsta
                    beq       L17B4
                    lda       >$1DF7
                    lbsr      L3BBB
                    cmpa      #$C3
                    bne       L17B4
                    lda       #$01
                    puls      pc,b

L17B4               clra
                    puls      pc,b

L17B7               pshs      u,d
                    std       >$1DF8
                    lbsr      L3CF4
                    lda       #$C3
                    sta       ,u
                    lda       >$1DF8
                    lbsr      L3CFF
                    lda       #$30
                    sta       ,u
                    cmpb      >$1D0A
                    bls       L17D8
                    stb       >$1D0A
L17D8               lda       >$1DF8
                    cmpa      >$1D0B
                    bls       L17E3
                    sta       >$1D0B
L17E3               puls      pc,u,d

L17E5               pshs      b
                    std       >$1DFA
                    cmpa      >$1D08
                    blo       L1827
                    lda       #7                  (23/3)
                    adda      >$1D08
                    pshs      a
                    lda       >$1DFA
                    cmpa      ,s+
                    bhs       L1827
                    lda       >$1DFB
                    cmpa      >$1D09
                    blo       L1827
                    lda       #26                 (80/3)
                    adda      >$1D09
                    pshs      a
                    lda       >$1DFB
                    cmpa      ,s+
                    bhs       L1827
                    lda       #1
                    puls      pc,b

L1827               clra
                    puls      pc,b

L182A               pshs      u,y,x,d
                    ldb       >$10E4+1            Get LSB of player status flags
                    andb      #%01111111          $7F  Clear bit 8 (trapped by venus flytrap?)
                    stb       >$10E4+1            Save it back
                    lda       >$0D91              Get players current dungeon level
                    cmpa      >$0D90              If >???, set ??? to current dungeon level
                    bls       L1841
                    sta       >$0D90
L1841               ldu       #$4B84              Buffer to init
                    ldx       #$0370              Size of map screen (80x22) in 16 bit words
                    ldd       #$2020              Fill buffer with spaces
                    lbsr      L401D
* 6809/6309 - Since this is even byte size, could use L401D routine (faster)
                    ldu       #$5264              Buffer to init
                    ldx       #$0370              Size of map screen (80x22)
                    ldd       #$1010              Value to init with (This could use the L401D routine and be faster)
                    lbsr      L401D
                    ldu       >$10F9              Get ptr to root monster block for current level
L185B               beq       L186B               No more monsters, skip ahead
                    leax      <29,u               Point to some ptr in the object block that has to do with monsters
                    lbsr      L6150
                    ldu       ,u
                    bra       L185B

L186B               ldx       #$10F9
                    lbsr      L6150
                    lbsr      L2AB8
                    ldx       #$10F7
                    lbsr      L6150
                    lbsr      L0B46
                    lda       >$0D90
                    cmpa      #$01
                    bne       L1887
                    lbsr      L6D6F
L1887               lbsr      L6546
                    lbsr      L68A8
                    lbsr      L6C1D
                    lbsr      L6AA2
                    lbsr      L1250
                    inc       >$0D9C
                    lbsr      L19BA
                    clr       >$1DFC
L189F               lbsr      L1997
                    lbsr      L3D0A
                    ldu       #$1DFD
                    lbsr      L0E1A
                    lda       >$1DFE
                    ldb       >$1DFD
                    lbsr      L5AAA               X=offset into 80x22 map
                    inc       >$1DFC
                    lda       >$1DFC
                    cmpa      #$64
                    blt       L18C4
                    clr       >$1DFC
                    lbsr      L3B32
L18C4               lda       >$4B84,x            Get map piece type
                    lbsr      L3C2C
                    tsta
                    beq       L189F
                    lda       #$D3                Make it stairs
                    sta       >$4B84,x
                    lda       #10                 RND(10) 0-10
                    lbsr      L63A9
                    cmpa      >$0D91              < dungeon level player is on?
                    blo       L192D               Yes, skip ahead
                    lda       >$0D91              No, get dungeon level
                    asra                          Divide by 4 (signed)
                    asra
                    lbsr      L63A9               RND(A)
                    inca
                    cmpa      #10
                    ble       L18ED               If <=10 (including negative) skip ahead
                    lda       #10                 Otherwise, force to 10
L18ED               sta       >$0D8F
                    sta       >$1DFC
L18F3               tst       >$1DFC
                    beq       L192D
                    dec       >$1DFC
                    lbsr      L1997
                    lbsr      L3D0A
                    ldu       #$1DFD
                    lbsr      L0E1A
                    lda       >$1DFE
                    ldb       >$1DFD
                    lbsr      L5AAA               X=offset into 80x22 map
                    lda       >$4B84,x            Get map character
                    lbsr      L3C2C
                    tsta
                    beq       L18F3
                    leax      >$5264,x            Point to position in flags map
                    lda       ,x
                    anda      #%11101111          $EF set "hidden door" flag
                    sta       ,x
                    lda       #6                  RND(6)
                    lbsr      L63A9
                    ora       ,x                  Randomly set the lowest 3 bit flags
                    sta       ,x
L192D               bsr       L1997
                    lbsr      L3D0A
                    ldu       #$10DC
                    lbsr      L0E1A
                    lda       >$10DD              Get Y coord to check
                    ldb       >$10DC              Get X coord to check
                    lbsr      L5AAA               X=offset into 80x22 map for coord
                    lda       >$4B84,x            Get object from main level map
                    lbsr      L3C2C
                    tsta
                    beq       L192D
                    lda       >$5264,x            Get flags for object from flags map
                    anda      #%00010000          $10 Is it a hidden door?
                    beq       L192D               Yes, go back
                    lda       >$10DD              ?Get players Y coord?
                    ldb       >$10DC              ?Get players X coord?
                    lbsr      L2CDB               Search monster object list for matching monster in same position
                    cmpx      #$0000
                    bne       L192D               No, match go back
                    clr       >$0D94
                    ldx       #$10DC
                    lbsr      L0E36
                    lda       >$10DD
                    ldb       >$10DC
                    std       >$355B
                    lda       #$C1
                    lbsr      L6612
                    ldd       >$10DC
                    std       >$0DAD
                    ldd       >$10F3
                    std       >$0DB9
                    ldx       #$10D8
                    ldd       #$0002
                    lbsr      L3C3C
                    tsta
                    beq       L1995
                    clra
                    lbsr      L93BF
L1995               puls      pc,u,y,x,d

* I *think* this has to do with randomly generating monsters on a level during play.
*   It gets called several times per level; maybe every so many turns?
* Exit: A=RND(0-9) if room flags has bit 2 clear, OR bits 2 & 3 both set
L1997               pshs      x,b
L1999               lda       #9                  RND(0) 0-9 (room block #)
                    lbsr      L63A9
                    sta       >$1DFF              Save entry #
                    ldb       #34                 Point to entry in room block table
                    mul
                    addd      #$0DBB
                    tfr       d,x
                    lda       8,x                 Get current room block flags
                    bita      #%00000010          $02
                    beq       L19B5               If bit 2 is clear, return with our random 0-9
                    anda      #%00000100          $04 If bit 2 is set, see if bit 3 is as well
                    beq       L1999               Bit 3 not set; pick a different random room #
L19B5               lda       >$1DFF              Get random room # & return
                    puls      pc,x,b

L19BA               pshs      u,y,x,d
                    clr       >$1E00
                    tst       >$0638
                    beq       L19D3
                    lda       >$0D91              Get dungeon level player is on
                    cmpa      >$0D90              If (signed) >= ???, skip ahead
                    bge       L19D3
                    lda       #8
                    sta       >$1E00
                    bra       L1A41

L19D3               lda       >$0D91              Get dungeon level player is on
L19D6               cmpa      #26                 Is it above where the amulet would be found?
                    blt       L1A36               Yes, skip ahead
                    tst       >$0638
                    bne       L1A36
                    lbsr      L6162               Get next free inventory entry (max 40)
                    stx       >$1E03              Save ptr to it
                    beq       L1A36
                    ldu       #$10F7              Get ptr to root object block on current dungeon level
                    lbsr      L6138
                    clr       <$10,x              Clear blessing & extra damage
                    clr       <$11,x
                    ldd       #$1E05              '0d0'
                    std       $A,x                Save as 1st weapons damage ptr
                    std       $C,x                Save as 2nd weapons damage ptr
                    lda       #11                 Save Damage modifier of 11? (or something special to amulet)
                    sta       <$12,x
                    lda       #$D5                Amulet of Yendor
                    sta       4,x                 Save as object type
L1A06               bsr       L1997
                    lbsr      L3D0A
                    ldu       #$1E01
                    lbsr      L0E1A
                    lda       >$1E02
                    ldb       >$1E01
                    lbsr      L5AF2
                    lbsr      L3C2C
                    tsta
                    beq       L1A06
                    lda       >$1E02
                    ldb       >$1E01
                    lbsr      L3CF4
                    lda       #$D5
                    sta       ,u
                    ldx       >$1E03
                    ldu       >$1E01
                    stu       5,x
L1A36               lda       #20                 RND(20)
                    lbsr      L63A9
                    tsta
                    bne       L1A41
                    bsr       L1A9B
L1A41               lda       >$1E00
                    cmpa      #9                  Done loop, exit
                    bhs       L1A99
                    lda       >$0D9B
                    cmpa      #40
                    bhs       L1A94
                    lda       #100                RND(100)
                    lbsr      L63A9
                    cmpa      #60
                    bhs       L1A94
                    lbsr      L7830
                    stx       >$1E03
                    ldu       #$10F7
                    lbsr      L6138
L1A64               lbsr      L1997
                    lbsr      L3D0A
                    ldu       #$1E01
                    lbsr      L0E1A
                    lda       >$1E02
                    ldb       >$1E01
                    lbsr      L3BBB
                    lbsr      L3C2C
                    tsta
                    beq       L1A64
                    lda       >$1E02
                    ldb       >$1E01
                    lbsr      L3CF4
                    ldx       >$1E03
                    lda       4,x
                    sta       ,u
                    ldd       >$1E01
                    std       5,x
L1A94               inc       >$1E00
                    bra       L1A41

L1A99               puls      pc,u,y,x,d

L1A9B               pshs      u,y,x,d
                    lbsr      L1997
                    lbsr      L3D0A
                    stx       >$1E0E
                    ldd       2,x
                    suba      #2
                    subb      #2
                    mul
                    tfr       b,a
                    suba      #2
                    cmpa      #8                  If >8, force to 8
                    ble       L1AB9
                    lda       #8
L1AB9               sta       >$1E09
                    lbsr      L63A9               RND(A)
                    adda      #2
                    sta       >$1E0A
                    sta       >$1E0B
L1AC7               lda       >$1E0B
                    beq       L1B0E
                    dec       >$1E0B
                    lda       >$0D9B
                    cmpa      #40
                    bge       L1B0E
L1AD6               ldx       >$1E0E
                    ldu       #$1E0C
                    lbsr      L0E1A
                    lda       >$1E0D
                    ldb       >$1E0C
                    lbsr      L5AAA               X=offset into 80x22 map
                    stx       >$1E10
                    lda       >$4B84,x
                    lbsr      L3C2C
                    tsta
                    beq       L1AD6
                    lbsr      L7830
                    ldd       >$1E0C
                    std       5,x
                    ldu       #$10F7              Get ptr to root object for level
                    lbsr      L6138
                    lda       4,x                 Get object type
                    ldx       >$1E10              Get position offset in map
                    sta       >$4B84,x            Save object in master map
                    bra       L1AC7

L1B0E               lda       >$1E09
                    lbsr      L63A9               RND(A)
                    adda      #2
                    sta       >$1E0B
                    suba      #2
                    cmpa      >$1E0A
                    bge       L1B28
                    lda       >$1E0A
                    adda      #2
                    sta       >$1E0B
L1B28               ldx       >$1E0E
                    ldd       2,x
                    suba      #2
                    subb      #2
                    mul
                    cmpb      >$1E0B              Apparently multiplication will always be 8 bit answer
                    bge       L1B3C
                    stb       >$1E0B
L1B3C               inc       >$0D91              Player is now one level deeper in dungeon
L1B3F               tst       >$1E0B
                    beq       L1BAA
                    dec       >$1E0B
                    clr       >$1E09              Init loop ctr
L1B4A               lda       >$1E09              Get current loop ctr
                    cmpa      #10                 Are we done all 10?
                    bge       L1B80               Yes, skip ahead
                    ldx       >$1E0E
                    ldu       #$1E0C
                    lbsr      L0E1A
                    lda       >$1E0D
                    ldb       >$1E0C
                    lbsr      L5AAA               X=offset into 80x22 map
                    lda       >$4B84,x            Get char from main full map
                    lbsr      L3C2C
                    tsta
                    beq       L1B7B
                    lda       >$1E0D              Get Y/X coords
                    ldb       >$1E0C
                    lbsr      L2CDB               Search monster object list for matching monster in same position
                    cmpx      #$0000
                    beq       L1B80               None found, skip ahead
L1B7B               inc       >$1E09              Inc loop ctr & continue looping until done
                    bra       L1B4A

L1B80               lda       >$1E09
                    cmpa      #10
                    beq       L1B3F
                    lbsr      L6162               Get next free inventory entry (max 40)
                    cmpx      #$0000              Inventory full?
                    beq       L1B3F               Yes, go back
                    pshs      x                   Save inventory ptr
                    leau      ,x                  faster,same size
                    clra                          Use first monster/level generation string
                    lbsr      L29A7               Go generate monster
                    ldx       #$1E0C
                    lbsr      L29E5
                    puls      x                   Get inventory entry ptr back
* 6809/6309 - chg 3 lines to ldb $D,x / orb #$20 / stb $D,x (a not modified)
                    ldd       $C,x
                    orb       #$20
                    std       $C,x
                    lbsr      L2C88
                    bra       L1B3F

L1BAA               dec       >$0D91              Move player up one level in dungeon
                    puls      pc,u,y,x,d

L1BAF               pshs      a
                    sta       >$0641
                    lda       #1
                    sta       >$063C
                    clr       >$05FC
                    puls      pc,a

L1BBE               pshs      u,y,x,d
                    std       >$1E62
                    clr       >$063B
                    tst       >$063F
                    beq       L1BE4
                    clr       >$063F
                    ldu       #$1E14              'the crack widens ...'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    ldu       #$1470
                    lbsr      L2143
                    lbra      L1F43

L1BE4               tst       >$0D96              Ctr for being stuck in bear trap?
                    beq       L1BF9
                    dec       >$0D96              Dec ctr
                    ldu       #$1E2A              'you are still stuck in the bear trap'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbra      L1F43

L1BF9               ldx       #$10D8
                    ldd       #$0100
                    lbsr      L3C3C
                    tsta
                    beq       L1C15
                    lda       #5                  RND(5)
                    lbsr      L63A9
                    tsta
                    beq       L1C15
                    ldd       #$1E12
                    lbsr      L219B
                    bra       L1C27

* Something to do with moving the player
L1C15               ldd       >$10DC
                    adda      >$1E63
                    addb      >$1E62
                    std       >$1E12
L1C27               lda       >$1E13
                    ldb       >$1E12
                    lbsr      L5ADE
                    tsta
                    lbne      L1D0B
                    ldu       #$10DC
                    ldy       #$1E12
                    lbsr      L2871
                    tsta
                    bne       L1C51
                    clr       >$05FC
                    clr       >$063C
                    clr       >$0D9E
                    lbsr      L43D1
                    lbra      L1F43

L1C51               tst       >$063C
                    beq       L1C6E
                    ldd       #$10DC
                    ldu       #$1E12
                    lbsr      L5A95
                    tsta
                    beq       L1C6E
                    clr       >$05FC
                    clr       >$063C
                    clr       >$0D9E
                    lbsr      L43D1
L1C6E               lda       >$1E13
                    ldb       >$1E12
                    lbsr      L3BC6
                    sta       >$1E64
                    lda       >$1E13
                    lbsr      L5AF2
                    sta       >$1E65
                    lda       >$10DD
                    ldb       >$10DC
                    lbsr      L3BBB
                    cmpa      #$CA
                    bne       L1C9A
                    lda       >$1E65
                    cmpa      #$C2
                    bne       L1C9A
                    clr       >$063C
L1C9A               lda       >$1E64
                    anda      #%00010000          $10
                    bne       L1CCA
                    lda       >$1E65
                    cmpa      #$C2
                    bne       L1CCA
                    lda       #$D4
                    sta       >$1E65
                    pshs      a
                    lda       >$1E13
                    ldb       >$1E12
                    lbsr      L3CF4
                    puls      a
                    sta       ,u
                    lda       >$1E13
                    lbsr      L3CFF
* 6309 - replace 3 lines with OIM #$10,,u
                    lda       ,u
                    ora       #$10
                    sta       ,u
                    bra       L1CEA

L1CCA               ldx       #$10D8
                    ldd       #$0080
                    lbsr      L3C3C
                    tsta
                    beq       L1CEA
                    lda       >$1E65
                    cmpa      #$46
                    beq       L1CED
                    ldu       #$1E4F
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbra      L1F43

L1CEA               lda       >$1E65
L1CED               cmpa      #$20
                    beq       L1D0B
                    cmpa      #$C5
                    beq       L1D0B
                    cmpa      #$C4
                    beq       L1D0B
                    cmpa      #$C6
                    beq       L1D0B
                    cmpa      #$C7
                    beq       L1D0B
                    cmpa      #$C8
                    beq       L1D0B
                    cmpa      #$C9
                    lbne      L1E4F
L1D0B               tst       >$063C
                    lbeq      L1E40
                    ldx       >$10F3
                    lda       8,x
                    anda      #%00000010          $02 - Not sure if safe to do bita instead of anda
                    lbeq      L1E40
                    lda       8,x
                    anda      #%00000100          $04
                    lbne      L1E40
                    ldx       #$10D8
                    ldb       #1                  A is already 0, so D=1
                    lbsr      L3C3C
                    tsta
                    lbne      L1E40
                    lda       >$0641              Get keypress
                    cmpa      #$68                h?
                    beq       L1D40               Yes, skip ahead
                    cmpa      #$6C                l?
                    bne       L1DB9
L1D40               lda       >$10DD              If h or l key pressed, do this.
                    cmpa      #1
                    bls       L1D5D
                    deca
                    ldb       >$10DC
                    lbsr      L3BC6
                    anda      #%01000000          $40
                    bne       L1D62
                    lda       >$10DD
                    deca
                    lbsr      L3BBB
                    cmpa      #$CA                Door>
                    beq       L1D62
L1D5D               clr       >$1E66
                    bra       L1D67

L1D62               lda       #1
                    sta       >$1E66
L1D67               lda       >$10DD              Get Y coord (players pos?)
                    cmpa      #21                 If last line (or higher), skip ahead?
                    bhs       L1D84
                    inca
                    ldb       >$10DC              Get X coord (players pos?)
                    lbsr      L3BC6
                    anda      #%01000000          $40
                    bne       L1D89
                    lda       >$10DD
                    inca
                    lbsr      L3BBB
                    cmpa      #$CA                Door?
                    beq       L1D89               Yes, skip ahead
L1D84               clr       >$1E67
                    bra       L1D8E

L1D89               lda       #1
                    sta       >$1E67
L1D8E               lda       >$1E66
                    eora      >$1E67
                    lbeq      L1E40
                    tst       >$1E66
                    beq       L1DA9
                    lda       #$6B                'k'
                    sta       >$0641              Save in keypress buffer
                    lda       #$FF
                    sta       >$1E62
                    bra       L1DB3

L1DA9               lda       #$6A                'j'
                    sta       >$0641              Save in keypress buffer
                    lda       #1
                    sta       >$1E62
L1DB3               clr       >$1E63
                    lbra      L1C15

L1DB9               cmpa      #$6A                'j'?
                    beq       L1DC3               Yes, skip ahead
                    cmpa      #$6B                'k'
                    bne       L1E40               No, skip ahead
L1DC3               lda       >$10DC
                    cmpa      #1
                    bls       L1DE2
                    lda       >$10DD
                    ldb       >$10DC
                    decb
                    lbsr      L3BC6
                    anda      #%01000000          $40
                    bne       L1DE7
                    lda       >$10DD
                    lbsr      L3BBB
                    cmpa      #$CA                Door?
                    beq       L1DE7               Yes, skip ahead
L1DE2               clr       >$1E66
                    bra       L1DEC

L1DE7               lda       #1
                    sta       >$1E66
* 6809/6309 - If B isn't need following L1E0B path, could use ldb here and skip reloading it again.
L1DEC               lda       >$10DC              Get X coord (players pos?)
                    cmpa      #78                 If >=78, then skip ahead
                    bhs       L1E0B
                    lda       >$10DD
                    ldb       >$10DC
                    incb
                    lbsr      L3BC6
                    anda      #%01000000          $40
                    bne       L1E10
                    lda       >$10DD
                    lbsr      L3BBB
                    cmpa      #$CA                Door?
                    beq       L1E10               Yes, skip ahead
L1E0B               clr       >$1E67
                    bra       L1E15

L1E10               lda       #1
                    sta       >$1E67
L1E15               lda       >$1E66
                    eora      >$1E67
                    beq       L1E40
                    tst       >$1E66
                    beq       L1E30
                    lda       #$68                'h'?
                    sta       >$0641              Save as keypress
                    lda       #$FF
                    sta       >$1E63
                    bra       L1E3A

L1E30               lda       #$6C                'l'?
                    sta       >$0641              Save as keypress?
                    lda       #1
                    sta       >$1E63
L1E3A               clr       >$1E62
                    lbra      L1C15

L1E40               clr       >$05FC
                    clr       >$063C
                    clr       >$0D9E
                    lbsr      L43D1
                    lbra      L1F43

L1E4F               cmpa      #$CA                Door?
                    bne       L1E6D               No, skip ahead
                    clr       >$063C
                    lda       >$10DD
                    ldb       >$10DC
                    lbsr      L3BC6
                    anda      #%01000000          $40
                    beq       L1ED6
                    ldx       #$1E12
                    lbsr      L0E36
                    bra       L1ED6

L1E6D               cmpa      #$D4                Trap?
                    bne       L1E85               No, skip ahead
                    ldx       #$1E12
                    lbsr      L1FCB
                    sta       >$1E65
                    beq       L1E82
                    cmpa      #4
                    bne       L1ED6
L1E82               lbra      L1F43

L1E85               cmpa      #$C3                Hallway?
                    beq       L1ED6               Yes, skip ahead
L1E8B               cmpa      #$C2                Floor?
                    bne       L1E9E               No, skip ahead
                    lda       >$1E64
                    anda      #%00010000          $10
                    bne       L1ED6
                    ldx       #$10DC
                    lbsr      L1FCB
                    bra       L1ED6

L1E9E               clr       >$063C
                    lda       >$1E65
                    lbsr      L3EF6
                    tsta
                    bne       L1EB8
                    lda       >$1E13              Get Y/X coords
                    ldb       >$1E12
                    lbsr      L2CDB               Search monster object list for matching monster in same position
                    cmpx      #$0000
                    beq       L1EC9
L1EB8               ldy       #$1E12
                    ldb       >$1E65
                    ldu       >$0DB7
                    clra
                    lbsr      L2E75
                    bra       L1F43

L1EC9               clr       >$063C
                    lda       >$1E65
                    cmpa      #$D3                Stairs?
                    beq       L1ED6               Yes, skip ahead
                    sta       >$0640              No save copy of whatever object it is
L1ED6               ldx       #$10D8
                    ldd       #$0001
                    lbsr      L3C3C
                    beq       L1EF8
                    lda       >$10DD
                    ldb       >$10DC
                    lbsr      L3BBB
                    tfr       a,b                 X=A
                    clra
                    tfr       d,x
                    lda       >$10DD
                    ldb       >$10DC
                    lbsr      L68C4
L1EF8               lda       >$1E64
                    anda      #%01000000          $40
                    beq       L1F23
                    lda       >$1E64
                    anda      #%00100000          $20
                    bne       L1F23
                    lda       >$0DAE
                    ldb       >$0DAD
                    lbsr      L3BBB
                    cmpa      #$CA
                    beq       L1F1D
                    lda       >$0DAE
                    lbsr      L3BC6
                    anda      #%00100000          $20
                    beq       L1F23
L1F1D               ldx       #$1E12
                    lbsr      L0EDA
L1F23               lda       >$1E64
                    anda      #%00100000          $20
                    beq       L1F3D
                    lda       >$0DAE
                    ldb       >$0DAD
                    lbsr      L3BC6
                    anda      #%00100000          $20
                    bne       L1F3D
                    ldx       #$1E12
                    lbsr      L0E36
L1F3D               ldd       >$1E12
                    std       >$10DC
L1F43               puls      pc,u,y,x,d

* I think something to do with going through doors
L1F45               pshs      u,y,x,d
                    lda       8,u
                    anda      #%00000010          $02
                    bne       L1FC9
                    ldx       #$10D8
                    ldb       #1                  Since A is 0 from ANDA, D=1 now
                    lbsr      L3C3C
                    tsta
                    bne       L1FC9
                    lda       1,u
                    sta       >$1E68
                    adda      3,u
                    sta       >$1E6A
L1F63               lda       >$1E68
                    cmpa      >$1E6A
                    bhs       L1FC9
                    lda       ,u
                    sta       >$1E69
                    adda      2,u
                    sta       >$1E6B
L1F75               lda       >$1E69
                    cmpa      >$1E6B
                    bhs       L1FC4
                    ldd       >$1E68
                    lbsr      L5AF2
                    sta       >$1E6C
                    lbsr      L3EF6
                    tsta
                    beq       L1FBF
                    lda       >$1E68
                    lbsr      L2B55
                    stx       >$1E6D
                    lda       9,x
                    cmpa      #$20
                    bne       L1FBF
                    lda       8,u
                    anda      #%00000001          $01
                    bne       L1FBF
                    pshs      x
                    ldx       #$10D8
                    ldb       #1                  Since A is 0 from ANDA, D=1 now
                    lbsr      L3C3C
                    puls      x
                    tsta
                    bne       L1FBF
                    ldd       >$1E68
                    lbsr      L3BBB
                    sta       9,x
L1FBF               inc       >$1E69
                    bra       L1F75

L1FC4               inc       >$1E68
                    bra       L1F63

L1FC9               puls      pc,u,y,x,d

L1FCB               pshs      u,y,x,b
                    clr       >$063C
                    clr       >$0D9E
                    lbsr      L43D1
                    lda       1,x
                    ldb       ,x
                    stx       >$1F87
                    lbsr      L5AAA               X=offset into 80x22 map
                    lda       #$D4
                    sta       >$4B84,x
                    lda       >$5264,x
                    anda      #%00000111          $07
                    sta       >$1F86
                    ldb       #1
                    stb       >$063E
                    tsta
                    bne       L2001
                    ldu       #$1E6F
                    lbsr      L2143
                    lbra      L213B

L2001               cmpa      #3
                    bne       L201A
                    lda       #3
                    adda      >$0D96
                    sta       >$0D96
                    ldu       #$1E85
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbra      L213B

L201A               cmpa      #2
                    bne       L203D
                    lda       #5
                    adda      >$0D98
                    sta       >$0D98
                    ldd       >$10E4
                    andb      #$FB
                    stb       >$10E5
                    ldu       #$1EA3
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbra      L213B

L203D               cmpa      #1
                    bne       L20B6
                    ldu       #1
                    ldd       >$10EB              Get players rank & Armor class
                    deca                          Drop rank by 1
                    lbsr      L33A5
                    tsta
                    beq       L2087
                    ldd       #$0106
                    lbsr      L63BB
                    pshs      d
                    ldd       >$10ED
                    subd      ,s++
                    std       >$10ED
                    bgt       L207A
                    ldu       #$1ED9
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lda       #$61
                    lbsr      L0716
* I have no idea what this is for... I haven't seen anything to set up SWI yet in the
* code.
                    swi

L207A               ldu       #$1EED
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbra      L213B

* Possibly something to do with traps?
L2087               lbsr      L6162               Get next free inventory entry
                    cmpx      #$0000              None left?
                    beq       L20A9               Yes, skip ahead
                    lda       #$CF                Weapon type
                    sta       4,x
                    lda       #3                  Arrows weapon type
                    sta       $F,x
                    lbsr      L893F
                    lda       #1                  Qty=1?
                    sta       $E,x
                    ldd       >$10DC
                    std       5,x
                    clra
                    lbsr      L88B1
L20A9               ldu       #$1F06
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    bra       L213B

L20B6               cmpa      #4
                    bne       L20D3
                    lbsr      L49CC
                    ldb       #$D4
                    clra
                    pshs      d
                    ldx       >$1F87
                    lda       1,x
                    ldb       ,x
                    puls      x
                    lbsr      L68C4
                    inc       >$063E
                    bra       L213B

L20D3               cmpa      #5
                    bne       L213B
                    ldu       #1
                    ldd       >$10EB              Get players rank & armor class
                    inca                          Bump rank up by 1
                    lbsr      L33A5
                    tsta
                    beq       L2131
                    ldd       #$0104
                    lbsr      L63BB
                    pshs      d
                    ldd       >$10ED
                    subd      ,s++
                    std       >$10ED
                    bgt       L2110
                    ldu       #$1F1F
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lda       #$64
                    lbsr      L0716

* left for debugging - can remove
                    swi

L2110               lda       #2                  Is player wearing a Sustain Strength ring?
                    lbsr      L3C00
                    tsta
                    bne       L2125               Yes, skip ahead
                    lbsr      L37F4               Call routine with A=0
                    tsta
                    bne       L2125
                    lda       #$FF
                    lbsr      L55F0
L2125               ldu       #$1F3A              'a dart just hit you in the shoulder'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    bra       L213B

L2131               ldu       #$1F5E              'a dart whizzes by your ear and vanishes'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
L213B               lbsr      L621D
                    lda       >$1F86
                    puls      pc,u,y,x,b

L2143               pshs      u,y,x,d
                    pshs      u
                    inc       >$0D91              Player is one level deeper in dungeon
                    tst       ,u
                    bne       L2158
                    ldu       #$1F89              ' '
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
L2158               lbsr      L182A
                    ldu       #$1470
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbsr      L68D8
                    leas      2,s
                    lda       #1
                    lbsr      L37F4
                    tsta
                    bne       L2199
                    ldu       #$1F8B              'you are damaged by the fall'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    ldd       #$0108
                    lbsr      L63BB
                    pshs      d
                    ldd       >$10ED              Get players hit points
                    subd      ,s++                Subtract damage from fall
* question - why is it only saving the MSB?
                    sta       >$10ED              Save it back
                    cmpd      #$0000
                    bgt       L2199
                    lda       #'f                 Flag that player died by a fall
                    lbsr      L0716               Die screen - should never return from here
* Another unknown SWI call -left in from testing, I think
                    swi

L2199               puls      pc,u,y,x,d

L219B               pshs      u,y,x,d
                    std       >$1FA7
                    tfr       d,u
                    lda       #3                  RND(3)
                    lbsr      L63A9
                    deca
                    adda      5,x
                    sta       1,u
                    sta       >$1FAA
                    lda       #3                  RND(3)
                    lbsr      L63A9
                    deca
                    adda      4,x
                    sta       ,u
                    sta       >$1FA9
                    lda       5,x
                    cmpa      >$1FAA
                    bne       L21CB
                    lda       4,x
                    cmpa      >$1FA9
                    beq       L223D
L21CB               lda       >$1FAA
                    cmpa      #1
                    blo       L2235
                    cmpa      >$0D8E
                    bhs       L2235
                    lda       >$1FA9
                    blo       L2235
                    cmpa      #80
                    bhs       L2235
                    ldy       >$1FA7
                    leau      4,x
                    lbsr      L2871
                    tsta
                    beq       L2235
                    lda       >$1FAA
                    ldb       >$1FA9
                    lbsr      L5AF2
                    sta       >$1FAB              Save copy of map piece (or monster) type
                    lbsr      L58E8               Check map piece;on return A=0 if blank, wall piece or monster, A=1 otherwise
                    tsta
                    beq       L2235
                    lda       >$1FAB              Get copy of map piece or monster type again
                    cmpa      #$CD                Scroll?
                    bne       L223D               No, skip ahead
                    ldu       >$10F7
L220A               cmpu      #$0000
                    beq       L223D
                    lda       >$1FAA
                    cmpa      6,u
                    bne       L221E
                    lda       >$1FA9
                    cmpa      5,u
                    beq       L2227
L221E               exg       u,x
                    ldx       ,x
                    exg       u,x
                    bra       L220A

L2227               cmpu      #$0000
                    beq       L223D
                    lda       $F,u
                    cmpa      #6
                    bne       L223D
L2235               ldd       4,x
                    ldy       >$1FA7
                    std       ,y
L223D               puls      pc,u,y,x,d

* One of the routines called by the weird -$1b2 tbl entries
L223F               pshs      u,y,x,d
                    ldx       >$10F9              Get ptr to root monster object
L2244               cmpx      #$0000              Done monster object list, return
                    beq       L22CD
                    ldd       #%0000000010000000  $0080 Check if bit 8 set on monster flags (Confused) set
                    lbsr      L3C3C
                    tsta
                    bne       L22C7               No, go to next monster entry
                    ldd       #%0000000000000100  $0004   Yes, monster is confused, check if also paralyzed
                    lbsr      L3C3C
                    tsta
                    beq       L22C7               No, on to next monster entry
                    lda       5,x                 Get monster Y coord
                    ldb       4,x                 Get monster X coord
                    tfr       d,y                 Copy to Y
                    lda       >$10DD              Get players Y coord
                    ldb       >$10DC              Get players X coord
                    lbsr      L5A5F               Get square of distance between the coords
                    std       >$1FAE
                    ldd       #%0010000000000000  $2000 Check ??? flag
                    lbsr      L3C3C
                    tsta
                    bne       L2287
                    lda       7,x                 Get monster letter
                    cmpa      #'S                 $53 Slime?
                    bne       L228B               No, skip ahead
                    ldd       >$1FAE              Get square of distance between slime and player
                    cmpd      #3                  If slime <2 squares away?
                    bls       L228B               Yes, skip ahead
L2287               lda       6,x                 No, get ??? from monster entry
                    beq       L228E               If 0, skip ahead
L228B               bsr       L22CF
L228E               ldd       #$4000
                    lbsr      L3C3C
                    tsta
                    beq       L229A
                    bsr       L22CF
L229A               lda       5,x
                    ldb       4,x
                    tfr       d,y
                    lda       >$10DD
                    ldb       >$10DC
                    lbsr      L5A5F               Get square of distance between the coords
                    std       >$1FAE
                    ldd       #$8000
                    lbsr      L3C3C
                    tsta
                    beq       L22C1
                    ldd       >$1FAE
                    cmpd      #3
                    bls       L22C1
                    bsr       L22CF
* 6309 - eim #$01,6,X
L22C1               lda       6,x
                    eora      #$01
                    sta       6,x
L22C7               ldx       ,x
                    lbra      L2244

L22CD               puls      pc,u,y,x,d

* Entry: X=ptr to monster object block
L22CF               pshs      u,y,x,d
                    ldd       #$7FFF
                    std       >$1FB0
                    ldy       <$1B,x              Get some sort of ptr
                    sty       >$1FB2              Save copy
                    ldd       #%0000000001000000  $0040 Check if ??? (trapped by Venus Flytrap for player, no idea with monster)
                    lbsr      L3C3C
                    tsta
                    beq       L22F1
                    ldd       6,y                 Get ??? from ptr
                    bne       L22F1
                    ldd       #$10DC              ??? Save something in monster object
                    std       $A,x
L22F1               ldu       >$10F3              Get ptr
                    stu       >$1FB4              Make copy
                    ldd       $A,x                Get ??? from monster object
                    cmpd      #$10DC              Same as initial value?
                    beq       L2307               Yes, skip ahead
                    ldu       $A,x                Copy same ??? from monster object into U
                    lbsr      L281F               Get ptr into tbl @ $EED into U based on some x,y coords
                    stu       >$1FB4              Save it
L2307               ldu       >$1FB4              Get ptr
                    lbeq      L25EE               None, skip ahead
                    lda       #1
                    sta       >$1FB6
                    lda       5,x                 Get Y coord
                    ldb       4,x                 Get X coord
                    lbsr      L3BBB               Get value from map #2 (u4B84) for that location
                    cmpa      #$CA                Door?
                    beq       L2321
                    clr       >$1FB6
L2321               cmpy      >$1FB4
                    beq       L23A4
                    lda       8,y
                    anda      #%00000100          $04
                    bne       L23A4
                    clr       >$1FB7              Init ctr to 0
L2334               lda       >$1FB7              Get current ctr
                    ldy       >$1FB2
                    cmpa      9,y
                    bhs       L2381
                    lda       >$1FB7
                    lsla
                    leau      $B,y
                    lda       a,u
                    ldb       >$1FB7
                    lslb
                    leau      $A,y
                    ldb       b,u
                    sty       >$1FB2
                    tfr       d,y
                    ldu       $A,x
                    lda       1,u
                    ldb       ,u
                    lbsr      L5A5F               Get square of distance between the coords
                    std       >$1FC9
                    cmpd      >$1FB0
                    bge       L237C
                    lda       >$1FB7
                    lsla
                    ldy       >$1FB2
                    leay      $A,y
                    ldd       a,y
                    std       >$1FB8
                    ldd       >$1FC9
                    std       >$1FB0
L237C               inc       >$1FB7              Inc ctr, loop again
                    bra       L2334

* Part of player moving?
L2381               tst       >$1FB6
                    lbeq      L2446
                    lda       5,x
                    ldb       4,x
                    lbsr      L3BC6
                    anda      #%00001111          $0F Mask tbl entry # to 0-15
                    ldb       #34                 34 bytes/entry
                    mul
                    addd      #$0EED              Point to our entry
                    std       >$1FB2
                    tfr       d,y
                    clr       >$1FB6
                    bra       L2321

L23A4               ldu       $A,x
                    ldd       ,u
                    std       >$1FB8
                    lda       7,x
                    cmpa      #'D                 Dragon?
                    beq       L23B7               Yes, skip ahead
                    cmpa      #'I                 Ice Monster?
                    lbne      L2446               Nope, skip ahead
L23B7               lda       5,x
                    cmpa      >$10DD
                    beq       L23DB
                    lda       4,x
                    cmpa      >$10DC
                    beq       L23DB
                    lda       5,x
                    suba      >$10DD
                    lbsr      L3BB6               ABS of A
                    pshs      a
                    lda       4,x
                    suba      >$10DC
                    lbsr      L3BB6               ABS of A
                    cmpa      ,s+
                    bne       L2446
L23DB               lda       >$10DD
                    ldb       >$10DC
                    tfr       d,y
                    lda       5,x
                    ldb       4,x
                    lbsr      L5A5F               Get square of distance between the coords
                    std       >$1FC9
                    cmpd      #$0002
                    bls       L2446
                    ldd       #36                 (was 6*6)
                    pshs      d
                    ldd       >$1FC9
                    cmpd      ,s++
                    bhi       L2446
                    ldd       #$1000
                    lbsr      L3C3C
                    tsta
                    bne       L2446
                    lda       #5                  RND(5)
                    lbsr      L63A9
                    tsta
                    bne       L2446
                    sta       >$063C
                    lda       >$10DD
                    suba      5,x
                    lbsr      L5860
                    sta       >$0DB0
                    lda       >$10DC
                    suba      4,x
                    lbsr      L5860
                    sta       >$0DAF
                    leau      4,x
                    ldy       #$0DAF
                    lda       7,x
                    cmpa      #'D                 Dragon?
                    bne       L243D               No, must be Ice Monster
                    ldd       #$1FBD              'flame'
                    bra       L2440

L243D               ldd       #$1FC3              'frost'
L2440               lbsr      L8313
                    puls      pc,u,y,x,d

L2446               ldd       #$1FB8
                    lbsr      L26AE
                    ldd       #$1FAC
                    ldu       #$10DC
                    lbsr      L5A95
                    tsta
                    beq       L2460
                    leay      ,x
                    lbsr      L301A
                    puls      pc,u,y,x,d

L2460               ldu       $A,x
                    lbsr      L5A95
                    tsta
                    beq       L24DD
                    ldy       >$10F7              Get ptr to root object block for current dungeon level
L246C               leay      ,y                  Y=0?
                    beq       L24DD               Yes, skip ahead
                    leau      5,y
                    cmpu      $A,x
                    bne       L24D0
                    pshs      x
                    leax      ,y                  Move ptr to object block to remove to X
                    ldu       #$10F7              Get ptr to current level root object block
                    lbsr      L6112               Go remove it (update linked list)
                    ldx       ,s
                    ldu       <$1D,x
                    leax      ,y
                    lbsr      L6138
                    puls      x
                    ldu       <$1B,x
                    lda       8,u
                    anda      #%00000010          $02
                    beq       L249C
                    lda       #$C3                ??? Maybe Hallway?
                    bra       L249E

L249C               lda       #$C2                ??? Maybe Floor?
L249E               pshs      a
                    lda       6,y
                    ldb       5,y
                    lbsr      L3CF4
                    puls      a
                    sta       ,u
                    sta       >$1FBA
                    lda       6,y
                    ldb       5,y
                    lbsr      L28A4               Calc distance between 2 X/Y coords
                    tsta
                    beq       L24C9
                    pshs      x
                    clra
                    ldb       >$1FBA
                    tfr       d,x
                    lda       6,y
                    ldb       5,y
                    lbsr      L68C4               Update on screen map
                    puls      x
L24C9               lbsr      L28FB
                    std       $A,x
                    bra       L24DD

L24D0               pshs      x
                    leax      ,y
                    ldx       ,x
                    puls      y
                    exg       x,y
                    bra       L246C

L24DD               lda       7,x                 Get monster type from object block
                    cmpa      #'F                 $46 Venus Flytrap?
                    lbeq      L25EE               Yes, skip ahead
                    lda       9,x                 No, get ???
                    cmpa      #$40
                    beq       L2544
                    cmpa      #$20
                    bne       L250E
                    lda       5,x                 Get Y coord
                    ldb       4,x                 Get X coord
                    lbsr      L28A4
                    tsta
                    beq       L250E
                    lda       5,x
                    pshs      x
                    lbsr      L5AAA               X=offset into 80x22 map
                    lda       >$4B84,x            Get map char
                    puls      x
                    cmpa      #$C2                Floor?
                    bne       L250E               No, skip ahead
                    ldb       #$C2                Yes, B=Floor and skip ahead
                    bra       L2534

L250E               lda       9,x
                    cmpa      #$C2
                    bne       L2532
                    lda       5,x                 ? Y coord of monster?
                    ldb       4,x                 ? X coord of monster?
                    lbsr      L28A4
                    tsta
                    bne       L2532
                    pshs      x
                    ldx       #$10D8              Point to ??? data block
                    ldd       #%0000000000000010  $0002 Check if bit 2 set @ 12,x (Monster detection?)
                    lbsr      L3C3C
                    puls      x
                    tsta
                    bne       L2532               Bit was set, skip ahead
                    ldb       #$20                Use space char
                    bra       L2534

L2532               ldb       9,x                 Get char to print?
L2534               clra
                    pshs      x
                    tfr       d,u
                    lda       5,x
                    ldb       4,x
                    leax      ,u
                    lbsr      L68C4
                    puls      x
L2544               ldy       <$1B,x
                    sty       >$1FBB
                    ldd       #$1FAC
                    leau      4,x
                    lbsr      L5A95
                    tsta
                    bne       L257F
                    ldu       #$1FAC
                    lbsr      L281F               Get ptr into tbl @ $EED into U based on some x,y coords
                    ldd       >$1FBB
                    stu       <$1B,x
                    bne       L256F
                    std       <$1B,x
                    puls      pc,u,y,x,d

L256F               cmpd      <$1B,x
                    beq       L257A
                    lbsr      L28FB
                    std       $A,x
L257A               ldd       >$1FAC
                    std       4,x
L257F               bsr       L25F0
                    tsta
                    beq       L25A1
                    lda       >$1FAD
                    ldb       >$1FAC
                    lbsr      L3BC6
                    anda      #%01000000          $40
                    beq       L2595
L2595               lda       >$1FAD
                    lbsr      L68D2
                    sta       9,x
                    ldb       8,x
                    bra       L25C1

L25A1               pshs      x
                    ldx       #$10D8              Point to player data block
                    ldd       #%0000000000000010  $0002 (Monster detection?)
                    lbsr      L3C3C               Check if 12,x has bit 2 set
                    puls      x
                    tsta
                    beq       L25D3               Not set, skip ahead
                    lda       >$1FAD
                    ldb       >$1FAC
                    lbsr      L68D2
                    sta       9,x
                    ldb       7,x
L25C1               clra
                    pshs      x
                    tfr       d,x
                    lda       >$1FAD
                    ldb       >$1FAC
                    lbsr      L68C4
                    puls      x
                    bra       L25D7

L25D3               lda       #$40
                    sta       9,x
L25D7               lda       9,x
                    cmpa      #$C2                Floor?
                    bne       L25EE               no, exit
                    ldy       >$1FBB
                    lda       8,y
                    anda      #%00000001          $01
                    beq       L25EE
                    lda       #$20
                    sta       9,x
L25EE               puls      pc,u,y,x,d

* Check if player can see monster? (because either blind or invisible monster)
* Entry: Y=some ptr from $1B in monster object
*        X=Ptr to monster object
* Exit: A=0 - player can not see it, A<>0, player can see it
L25F0               pshs      u,y,x,b
                    ldd       #%0000000000000001  $0001 Check for bit 1 in player flags (blind?)
                    pshs      x                   Preserve monster object block ptr
                    ldx       #$10D8              Point to player data block
                    lbsr      L3C3C               Check if player is blind (player flags @ $10E4)
                    puls      x                   Restore monster object block ptr
                    tsta
                    beq       L2606               No, player not blind, skip ahead
                    clra                          Player is blind, return that player can not see monster
                    puls      pc,u,y,x,b

L2606               ldd       #%0000000000010000  $0010 Check if monster invisible?
                    lbsr      L3C3C               (Note: X is pointing to monster object block here)
                    tsta
                    beq       L2622               No, monster is not ???, skip ahead
                    pshs      x                   Save monster block ptr
                    ldx       #$10D8              Point to player block
                    ldd       #%0000100000000000  $0800  Check for player "See invisible" flag
                    lbsr      L3C3C
                    puls      x                   Get back monster block ptr
                    tsta
                    bne       L2622               Player can see invisible, skip ahead
                    clra                          No, exit that player can not see monster
                    puls      pc,u,y,x,b

L2622               lda       >$10DD              Get players current Y pos
                    ldb       >$10DC              Get players current X pos
                    tfr       d,y                 Move pair to Y
                    lda       5,x                 Get monster Y coord?
                    ldb       4,x                 Get monster X coord?
                    lbsr      L5A5F               Get square of distance between the coords
                    cmpd      #$0003              Is the distance 1.414 or less?
                    blo       L2650               Yes, skip ahead (close enough to attack hand to hand?)
                    ldy       <$1B,x              Get some sort of ptr
                    cmpy      >$10F3              Compare with other ptr
                    bne       L264D               Different, exit with A=0
                    lda       8,y
                    tfr       a,b
                    anda      #%00000001          $01
                    bne       L264D
                    andb      #%00000100          $04
                    beq       L2650
L264D               clra
                    puls      pc,u,y,x,b

L2650               ldy       >$0DB7              Get ptr to object being wielded
                    beq       L2689               None, skip ahead
                    lda       7,x
                    cmpa      <$14,y
                    bne       L2689
                    lda       <$13,y
                    tfr       a,b
                    anda      #%00000100          $04
                    bne       L2689
                    orb       #%00000100          $04
                    stb       <$13,y
                    lda       #1
                    sta       >$364A
                    ldu       #$1473              ' of intense white light'
                    pshs      u
                    lda       $F,y
                    lsla
                    ldu       #$004B
                    ldd       a,u
                    pshs      d
                    ldu       #$148B              'your %s gives off a flash%s'
                    pshs      u
                    lbsr      L68D8
                    leas      6,s
L2689               lda       #1
L268B               puls      pc,u,y,x,b

* part of attacking a monster? (Beginning part, if it is)
* Entry: X=monster object ptr+4 (X/Y coord of monster)
L268D               pshs      u,y,x,d
                    leay      ,x                  Point Y to object (monster) type
                    lda       1,y                 Get Y coord of monster
                    ldb       ,y                  Get X coord of monster
                    lbsr      L2CDB               Search monster object list for matching monster in same position
                    cmpx      #$0000              Are we at end of monster list?
                    beq       L26AC               Yes, return
                    ldb       $C+1,x              No, Get 2nd byte of monster flags for matching monster
                    orb       #%00000100          $04 Set bit 3
                    andb      #%01111111          $7F Clear bit 0
                    stb       $C+1,x              Save updated flags
                    lbsr      L28FB
                    std       $A,x
L26AC               puls      pc,u,y,x,d

L26AE               pshs      u,y,x,d
                    std       >$1FCB
                    lda       #1
                    sta       >$1FCD
                    leau      4,x
                    stu       >$1FD9
                    ldd       #%0000000100000000  $0100 (Check if confused?)
                    lbsr      L3C3C
                    tsta
                    beq       L26CE               Not confused, skip ahead
                    lda       #5                  Confused, RND(5)
                    lbsr      L63A9
                    tsta
                    bne       L26EA               If <>0, skip ahead
L26CE               lda       7,x
                    cmpa      #80
                    bne       L26DC
                    lda       #5                  RND(5)
                    lbsr      L63A9
                    tsta
                    beq       L26EA               IF rnd(5)=0, skip ahead
                    lda       7,x
L26DC               cmpa      #66
                    bne       L271B
                    lda       #2                  RND(2)
                    lbsr      L63A9
                    tsta
                    bne       L271B               If 1 or 2, skip ahead
L26EA               ldd       #$1FAC
                    lbsr      L219B
                    ldu       >$1FCB
                    lda       1,u
                    ldb       ,u
                    tfr       d,y
                    lda       >$1FAD
                    ldb       >$1FAC
                    lbsr      L5A5F               Get square of X distance and Y distance
                    std       >$1FCE
                    lda       #30                 RND(30)
                    lbsr      L63A9
                    cmpa      #17
                    bne       L281D               If not 17, exit
                    lda       $C,x                If 17, clear flag in monster flags
                    anda      #%11111110          $FE
                    sta       $C,x
L281D               puls      pc,u,y,x,d

L271B               ldy       >$1FCB
                    lda       1,y
                    ldb       ,y
                    tfr       d,y
                    ldu       >$1FD9
                    lda       1,u
                    ldb       ,u
                    lbsr      L5A5F               Get square of X distance and Y distance
                    std       >$1FCE              Save that result
                    ldd       ,u
                    std       >$1FAC
                    lda       ,u
                    inca
                    sta       >$1FD4
                    suba      #2
                    sta       >$1FD2
                    lda       1,u
                    inca
                    sta       >$1FD5
L2748               lda       >$1FD2
                    cmpa      >$1FD4
                    bhi       L281D
                    ldu       >$1FD9
                    lda       1,u
                    deca
                    sta       >$1FD3
L275B               ldb       >$1FD3
                    cmpb      >$1FD5
                    lbhi      L2817
                    ldb       >$1FD2
                    stb       >$1FD6
                    lda       >$1FD3
                    sta       >$1FD7
                    lbsr      L5ADE
                    tsta
                    lbne      L2811
                    ldy       #$1FD6
                    lbsr      L2871
                    tsta
                    lbeq      L2811
                    lda       >$1FD3
                    lbsr      L5AF2
                    sta       >$1FD8
                    lbsr      L58E8               Check map piece;on return A=0 if blank, wall piece or monster, A=1 otherwise
                    tsta
                    beq       L2811
                    lda       >$1FD8
                    cmpa      #$CD                Scroll?
                    bne       L27C8               No, skip ahead
                    ldy       >$10F7              Get ptr to root object for current level
L279F               beq       L27C8               No objects on level, skip ahead
                    lda       >$1FD3              Get ???
                    cmpa      6,y
                    bne       L27B3
                    lda       >$1FD2
                    cmpa      5,y
                    beq       L27BC
L27B3               ldy       ,y
                    bra       L279F

L27BC               leay      ,y                  Is object ptr empty?
                    beq       L27C8               Yes, skip ahead
                    lda       $F,y                Get object sub-type
                    cmpa      #6                  Scare monster scroll?
                    beq       L2811               Yes, skip ahead
L27C8               ldy       >$1FCB
                    lda       1,y
                    ldb       ,y
                    tfr       d,y
                    lda       >$1FD3
                    ldb       >$1FD2
                    lbsr      L5A5F               Get square of X distance and Y distance
                    std       >$1FD0
                    cmpd      >$1FCE
                    bhs       L27F7
                    lda       #1
                    sta       >$1FCD
                    ldd       >$1FD6
                    std       >$1FAC
                    ldd       >$1FD0
                    std       >$1FCE
                    bra       L2811

L27F7               bne       L2811
                    inc       >$1FCD
                    lda       >$1FCD
                    lbsr      L63A9               RND(A)
                    tsta
                    bne       L2811
                    ldd       >$1FD6
                    std       >$1FAC
                    ldd       >$1FD0
                    std       >$1FCE
L2811               inc       >$1FD3
                    lbra      L275B

L2817               inc       >$1FD2
                    lbra      L2748

* Part of monster spawning?
* Entry: U=ptr from $A,x in monster object (points to some x,y coords)
L281F               pshs      y,x,d
                    ldx       #$0DBB              Point to start of room areas tbl (1st of 9)
L2824               cmpx      #$0EED              Done all 9 room areas?
                    bhs       L284E               Yes, skip ahead
                    lda       ,x                  Get Start X of room
                    adda      2,x                 Add room width
                    cmpa      ,u                  Compare with value from ptr in monster object
                    ble       L2849               If <=, skip to next entry
                    lda       ,x                  Get Start X of room again
                    cmpa      ,u                  Same as X from ptr in monster object?
                    bgt       L2849               If >, skip to next entry
                    lda       1,x                 Get Start Y of room
                    adda      3,x                 Add room height
                    cmpa      1,u                 Same as Y from ptr in monster object?
                    ble       L2849               If <=, skip to next entry
                    lda       1,x                 Get room width
                    cmpa      1,u                 > width from ptr in monster object?
                    bgt       L2849               Yes, skip to next entry in table
                    leau      ,x                  No, copy ptr to X & return
                    puls      pc,y,x,d

L2849               leax      <$22,x              Bump ptr to next entry in table, continue search
                    bra       L2824

* Checked all room objects comes here, none matched compare criteria (from L281F above)
L284E               lda       1,u                 Get Y from ptr in monster object
                    ldb       ,u                  Get X from ptr in monster object
                    lbsr      L3CFF               Get offset into map #3 (flags map) for these coordinates (into U)
                    lda       ,u                  Get flag byte from map #3
                    bita      #%01000000          $40 Is bit 7 set?
                    beq       L2869               No, skip ahead
                    anda      #%00001111          $0F Mask entry # off to 0-15 (we only use 0-12, I believe)
                    ldb       #34                 Multiply by tbl entry size
                    mul
                    addd      #$0EED              Add to base of tbl
                    tfr       d,u                 Move ptr to U & return
                    puls      pc,y,x,d

L2869               inc       >$063F
                    ldu       #$0000              Set ptr to 0 & return
                    puls      pc,y,x,d

* part of player moving routine?
L2871               pshs      u,y,x,b
                    lda       ,y
                    cmpa      ,u
                    beq       L287F
                    lda       1,y
                    cmpa      1,u
                    bne       L2883
L287F               lda       #1
                    puls      pc,u,y,x,b

L2883               lda       1,y
                    ldb       ,u
                    lbsr      L3BBB
                    lbsr      L58E8               Check map piece;on return A=0 if blank, wall piece or monster, A=1 otherwise
                    tsta
                    beq       L28A2
                    lda       1,u
                    ldb       ,y
                    lbsr      L3BBB
                    lbsr      L58E8               Check map piece;on return A=0 if blank, wall piece or monster, A=1 otherwise
                    tsta
                    beq       L28A2
                    lda       #1
L28A2               puls      pc,u,y,x,b

L28A4               pshs      u,y,x,b
                    std       >$1FDD
                    ldx       #$10D8
                    ldd       #$0001
                    lbsr      L3C3C
                    tsta
                    bne       L28F8
L28BB               lda       >$10DD
                    ldb       >$10DC
                    tfr       d,y
                    ldd       >$1FDD
                    lbsr      L5A5F               Get square of X distance and Y distance
                    cmpd      #$0003
                    bhs       L28D6
                    lda       #1
                    puls      pc,u,y,x,b

* Not sure - but when you throw something, it does these each space the object moves
L28D6               ldd       >$1FDD              Get Y/X coords
                    ldu       #$1FDF              Ptr to store at
                    sta       1,u                 Save copies of coords
                    stb       ,u
                    lbsr      L281F               Get ptr into tbl @ $EED into U based on some x,y coords
                    cmpu      >$10F3              Same as another ptr based on $EED?
                    bne       L28F8               No, clear with A=0
                    lda       8,u
                    anda      #%00000001          $01
                    bne       L28F8
                    lda       #1
                    puls      pc,u,y,x,b

L28F8               clra
                    puls      pc,u,y,x,b

* Entry: X=ptr to monster object block. Part of monster spawn, and/or attacking a monster?
L28FB               pshs      u,y,x
                    lda       7,x                 Get monster type (first char of monster name)
                    suba      #$41                Convert to binary
                    ldb       #18                 18 bytes/entry
                    mul
                    addd      #$10FD              Point to proper entry in monster definition tbl
                    pshs      x                   Save original monster block ptr
                    tfr       d,x                 Move monster definition ptr to indexable reg
                    lda       ,x                  Get 1st byte from monster definition
                    puls      x                   Get monster block ptr back
                    sta       >$1FE1              Save byte from monster definition
                    bls       L2926
                    ldy       <$1B,x              Get ptr from monster object
                    cmpy      >$10F3              Same as ??? ptr
                    beq       L2926               Matched, skip ahead
                    lbsr      L25F0
                    tsta
                    beq       L292B

L2926               ldd       #$10DC              exit with D=$10DC
                    puls      pc,u,y,x

L292B               ldy       <$1B,x
                    ldu       >$10F7              Get ptr to root object block (start of linked list)
                    stu       >$1FE2              Save working copy
L2935               ldu       >$1FE2              Get working copy of object block
                    beq       L2926               Done list, exit with D=$10DC
                    lda       4,u                 Get object type
                    cmpa      #$CD                Scroll?
                    bne       L294A               Nope, skip ahead
                    lda       $F,u                Get scroll type
                    cmpa      #6                  Scare monster?
                    beq       L2997               Yes, skip ahead
L294A               leau      5,u                 Point U to 5 bytes into object block
                    lbsr      L281F               Get ptr into tbl @ $EED into U based on some x,y coords
                    pshs      u
                    cmpy      ,s++
                    bne       L2997
                    lda       #100                RND(100)
                    lbsr      L63A9
                    cmpa      >$1FE1
                    bhs       L2997
                    ldx       >$10F9              Get ptr to root monster object for current level
                    stx       >$1FE4              Save working copy
L2966               beq       L2986               Done list, skip ahead
                    ldd       $A,x
                    pshs      d
                    ldx       >$1FE2              Get ptr to current object on level
                    leax      5,x                 Point 5 bytes into object structure
                    cmpx      ,s++                Same as ???
                    beq       L2986               Yes, skip ahead
                    ldx       >$1FE4              No, point to next monster object and loop back
                    ldx       ,x
                    stx       >$1FE4
                    bra       L2966               Keep going until no more monster objects

L2986               ldx       >$1FE4              Get ptr to current monster object
                    bne       L2997               There is one, skip ahead
                    ldx       >$1FE2              No monster, get ptr to current object on level
                    leax      5,x                 Point 5 bytes in
                    tfr       x,d                 Move that ptr to D & return
                    puls      pc,u,y,x

L2997               ldx       >$1FE2              Get ptr to current object block we are checking
                    ldx       ,x                  Get ptr to next object in linked list
                    stx       >$1FE2              Save as new current object block
                    bra       L2935               Continue through object linked list

* Part of random monster generation. There are two strings of the first letters of monsters
*  that it can choose from, depending on A on entry
* Entry: A=0 - use first monster/level spawn string.
*        A=1 - use 2nd monster/level spawn string.
* Exit: A=ASCII monster type randomly picked
L29A7               pshs      u,y,x,b
                    ldu       #$2001              'KEBHISORZ CAQ YTW PUGM VJ '
                    tsta
                    bne       L29B2
                    ldu       #$1FE6              'K BHISOR LCA NYTWFP GMXVJD'
L29B2               lda       #5                  RND(5) (0-5)
                    lbsr      L63A9
                    pshs      a                   Save random #
                    lda       #6                  RND(6) (0-6)
                    lbsr      L63A9
                    adda      ,s+                 Add the 2 random numbers together (0-11)
                    suba      #5                  Subtract 5 (-5 to 6)
                    adda      >$0D91              Add current dungeon level (1-26)
                    cmpa      #1                  If 1 to 6, skip ahead
                    bge       L29CF
                    lda       #5                  RND(5) (0-5)
                    lbsr      L63A9
                    inca                          Now 1-6
L29CF               cmpa      #26
                    bls       L29DA
                    lda       #5                  RND(5)
                    lbsr      L63A9
                    adda      #22                 22-27
L29DA               deca                          Drop monster type by 1
                    ldb       a,u                 Get monster type from tbl
                    cmpb      #$20                Space?
                    beq       L29B2               Yes, go try random sequence again
                    tfr       b,a                 Exit with A=random monster type generated
                    puls      pc,u,y,x,b

L29E5               pshs      u,y,x,d
                    stx       >$2020
                    sta       >$201F
                    ldb       >$0D91              Get current dungeon level
                    subb      #26
                    stb       >$201C
                    bge       L29FC
                    clr       >$201C
* Something during initialization
L29FC               pshs      u,x
                    leax      ,u
                    ldu       #$10F9
                    lbsr      L6138
                    puls      u,x
                    sta       7,u
                    ldb       #$40
                    std       8,u
                    ldd       ,x
                    std       4,u
                    exg       x,u
                    lbsr      L281F
                    stu       <$1B,x
                    lda       7,x                 Get monster letter
                    suba      #$41                ASCII to binary (0-25)
                    ldb       #18                 Point to monster entry in monster table
                    mul
                    addd      #$10FB
                    tfr       d,y                 Move monster ptr to Y
                    lda       $A,y
                    adda      >$201C
                    sta       <$13,x
                    ldb       #8
                    lbsr      L63BB
                    std       <$15,x
                    std       <$19,x
                    lda       $B,y
                    suba      >$201C
                    sta       <$14,x
                    ldd       $E,y
                    std       <$17,x
                    lda       $5,y
                    sta       $E,x
                    bsr       L2AD1
                    pshs      d
                    lda       #10
                    ldb       >$201C
                    mul
                    addd      ,s++
                    addd      8,y
                    std       <$11,x
* std/ldd should not affect carry, so I removed pshs cc / puls cc before/after ldd 6,y
                    ldd       6,y
                    bcc       L2A69
                    addd      #1
L2A69               std       $F,x
                    ldd       3,y
                    std       $C,x
                    lda       #1
                    sta       6,x
                    clra
                    clrb
                    std       <$1D,x
                    lda       #6                  Is player wearing a Aggravate Monster ring?
                    lbsr      L3C00
                    tsta
                    beq       L2A8A               No, skip ahead
                    pshs      x
                    ldx       >$2020
                    lbsr      L268D
                    puls      x
L2A8A               lda       >$201F
                    cmpa      #$46
                    bne       L2A97
                    ldd       >$144A
                    std       <$17,x
L2A97               lda       >$201F
                    cmpa      #$58
                    bne       L2AB6
                    ldb       >$0D91              Get current dungeon level
                    lda       #9                  Default # of monsters we can pick from to 9
                    cmpb      #25                 If dungeon level is <26, drop to pick from first 8
                    bhi       L2AA9
                    deca
L2AA9               lbsr      L63A9               RND(A) (either 8 or 9)
                    tfr       a,b
                    ldy       #$2022              'KNMSOPQRU' (monster list for RND(9) or RND(8) from above)
                    lda       b,y
                    sta       8,x
L2AB6               puls      pc,u,y,x,d

* Seems to be called once at start of each level
L2AB8               pshs      u,y,x
                    clr       >$0DA0
                    ldx       #$1155
                    ldu       $E,x
                    ldx       >$144A
                    lbsr      L3FF3               Copy NUL terminated string from ,U to ,X
                    puls      pc,u,y,x

L2AD1               pshs      u,y,x
                    lda       <$13,x
                    ldb       <$19,x
                    cmpa      #1
                    pshs      cc
                    clra
                    tfr       d,u                 Move to U so we can divide into it
                    puls      cc
                    bne       L2AE9               If <$19,x <>1, divide by 6
                    ldd       #8                  Otherwise divide by 8
                    bra       L2AEC

L2AE9               ldd       #6
L2AEC               lbsr      L3C5C               U=U/D (remainder in D)
                    lda       <$13,x
                    cmpa      #9
                    bls       L2AFE
                    ldd       #20
                    lbsr      L3CCE               D=D*U
                    puls      pc,u,y,x

L2AFE               cmpa      #6
                    bls       L2B0A
                    ldd       #4
                    lbsr      L3CCE               D=D*U
                    puls      pc,u,y,x

L2B0A               tfr       u,d
L2B0C               puls      pc,u,y,x

L2B0E               pshs      u,y,x,d
                    lbsr      L6162               Get next free inventory entry (max 40)
                    stx       >$202D              Save ptr to entry
                    beq       L2B53               If inventory full, exit
L2B1B               lbsr      L1997
                    lbsr      L3D0A
                    cmpx      >$10F3
                    beq       L2B2C
                    ldu       #$202B
                    lbsr      L0E1A
L2B2C               cmpx      >$10F3
                    beq       L2B1B
                    lda       >$202C
                    ldb       >$202B
                    lbsr      L5AF2
                    lbsr      L58E8               Check map piece;on return A=0 if blank, wall piece or monster, A=1 otherwise
                    tsta
                    beq       L2B1B
                    lda       #1                  Use 2nd monster/level generation string
                    lbsr      L29A7               Go generate monster
                    ldx       #$202B
                    ldu       >$202D
                    lbsr      L29E5
                    leax      4,u
                    lbsr      L268D
L2B53               puls      pc,u,y,x,d

L2B55               pshs      u,y,d
                    std       >$2052              Save coords
                    lbsr      L2CDB               Search monster object list for matching monster in same position
                    cmpx      #$0000
                    lbeq      L2C86               None, skip ahead
                    ldb       7,x                 Get monster type
                    pshs      b                   Save it on stack
                    ldd       #4
                    lbsr      L3C3C
                    tsta
                    bne       L2B9E
                    lda       #3                  RND(3)
                    lbsr      L63A9
                    tsta
                    beq       L2B9E               If 0, skip ahead
                    ldd       #$0020              Check if 6th bit of player flags set
                    lbsr      L3C3C
                    tsta
                    beq       L2B9E               No, skip ahead
                    ldd       #$0080              Check if player confused?
                    lbsr      L3C3C
                    tsta
                    bne       L2B9E               Yes, skip ahead
                    lda       #$0C                Is player wearing a Stealth ring?
                    lbsr      L3C00
                    tsta
                    bne       L2B9E               Yes, skip ahead
                    ldd       #$10DC
                    std       $A,x
                    ldb       $D,x
                    orb       #%00000100          $04
                    stb       $D,x
L2B9E               puls      b                   Get monster type back
                    cmpb      #'M                 Medusa?
                    lbne      L2C5B               No, skip ahead
                    pshs      x
                    ldx       #$10D8
                    ldd       #1
                    lbsr      L3C3C
                    puls      x
                    tsta
                    lbne      L2C5B
                    ldd       #$0008
                    lbsr      L3C3C
                    tsta
                    lbne      L2C5B
                    ldd       #$1000
                    lbsr      L3C3C
                    tsta
                    lbne      L2C5B
                    ldd       #4
                    lbsr      L3C3C
                    tsta
                    beq       L2C5B
                    ldy       >$10F3
                    pshs      y
                    lda       >$10DD
                    ldb       >$10DC
                    tfr       d,y
                    ldd       >$2052
                    lbsr      L5A5F               Get square of X distance and Y distance
                    tfr       d,u
                    puls      y
                    leay      ,y
                    beq       L2BFD
                    lda       8,y
                    anda      #%00000001          $01
                    beq       L2C03
L2BFD               cmpu      #3
                    bhs       L2C5B
L2C03               ldb       $D,x
                    orb       #%00001000          $08
                    stb       $D,x
                    lda       #$03
                    lbsr      L37F4
                    tsta
                    bne       L2C5B
                    pshs      x
                    ldx       #$10D8
                    ldd       #$0100
                    lbsr      L3C3C
                    puls      x
                    ldu       #L5FAB+PrgOffst-$1B2 (#$BDF9)
                    tsta
                    beq       L2C34
                    ldd       #$0014
                    lbsr      L6396
                    addd      #$0014
                    lbsr      L5E90
                    bra       L2C44

L2C34               ldd       #$0014
                    lbsr      L6396
                    addd      #$0014
                    tfr       d,y
                    clra
                    clrb
                    lbsr      L5E82
L2C44               lda       #$01
                    sta       >$364A
* 6809/6309 - Change to lda / sta (since we aren't modifying B)
* NOTE: THE L68D8 DOES PSHS D, AND CALLS OTHER ROUTINES. DON'T KNOW IF IT NEEDS D ON STACK
*  OR IF IT IS JUST SAVING IT. LEAVING ALONE FOR NOW
                    ldd       >$10E4
                    ora       #%00000001          $01
                    std       >$10E4
                    ldu       #$202F              'the medusa's gaze has confused you'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
L2C5B               ldd       #$0040
                    lbsr      L3C3C
                    tsta
                    beq       L2C86
                    ldd       #4
                    lbsr      L3C3C
                    tsta
                    bne       L2C86
                    ldb       $D,x
                    orb       #%00000100          $04
                    stb       $D,x
                    ldy       >$10F3
                    ldd       6,y
                    beq       L2C7F
                    leay      4,y
                    bra       L2C83

L2C7F               ldy       #$10DC
L2C83               sty       $A,x
L2C86               puls      pc,u,y,d

L2C88               pshs      u,y,x,d
                    lda       >$0D9B              Get # of inventory items (or total active objects?)
                    cmpa      #40                 If already at limit of 40, return
                    bhs       L2CB3
                    lda       #100                RND(100)
                    lbsr      L63A9
                    pshs      a                   Save random #
                    lda       7,x                 Get monster type
                    suba      #$41                convert to binary
                    ldb       #$12                Size of monster definition tbl entries
                    mul
                    addd      #$10FB+2            $10FD point to 3rd byte of monster definition
                    tfr       d,y                 Move ptr to Y
                    lda       ,y                  Get ???
                    cmpa      ,s+                 Compare with our random #
                    bls       L2CB3
                    leau      <$1D,x
                    lbsr      L7830
                    lbsr      L6138
L2CB3               puls      pc,u,y,x,d

* Pick a monster from list 2 (u1FE6), going backwards through list
L2CB5               pshs      u,y,x,b
                    ldx       #$1FE6              'K BHISOR LCA NYTWFP GMXVJD' Point to monster list/spawn string 2
                    lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    tfr       a,b
                    abx                           Start at end of string
L2CC0               leax      -1,x                Go back one position
                    cmpx      #$1FE6              Are we back to beginning yet?
                    blo       L2CD7               Yes, skip ahead
                    lda       #10                 RND(10)
                    lbsr      L63A9
                    tsta                          If random <>0, keep going
                    bne       L2CC0
                    lda       ,x                  Get monster letter
                    cmpa      #$20                If empty slot, skip to next one
                    beq       L2CC0
                    puls      pc,u,y,x,b

L2CD7               lda       #'M                 $4D (Medusa)
                    puls      pc,u,y,x,b

* Search linked list of monsters for matching X,Y position
* Entry: A=Y pos to find matching monster location
*        B=X pos to find matching monster location
* Exit:  X=ptr to matching monster (same position) or X=0 if none.
*        CC: Zero flag set if X=0
L2CDB               pshs      u,y,d
                    std       >$2054              Save Y & X positions
                    ldx       >$10F9              Get ptr to root monster object
L2CE6               cmpx      #$0000              If no more monsters left in linked list, return
                    beq       L2CFE
                    lda       4,x                 Get object X pos
                    cmpa      >$2055              Same as monster X pos?
                    bne       L2CF9               No, skip onto next entry
                    lda       5,x                 Get object Y pos
                    cmpa      >$2054              Same as monster Y pos?
                    beq       L2CFE               Yes, return
L2CF9               ldx       ,x                  Get ptr to next monster object block, and check that
                    bra       L2CE6

L2CFE               puls      pc,u,y,d

L2D00               pshs      u,y,x,d
                    bsr       L2D53
                    tsta
                    beq       L2D51
                    lbsr      L6162               Get next free inventory entry (max 40)
                    stx       >$2058              Save ptr to it
                    beq       L2D51               If inventory full, exit
                    ldu       #$205A              'The slime divides.   Ick!'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    ldx       #$2056
                    lda       #$53
                    ldu       >$2058
                    lbsr      L29E5
                    lda       >$2057
                    ldb       >$2056
                    lbsr      L28A4
                    tsta
                    beq       L2D4B
                    lda       >$2057
                    ldb       >$2056
                    lbsr      L3BBB
                    sta       9,u
                    lda       >$2057
                    ldb       >$2056
                    ldx       #$0053
                    lbsr      L68C4
L2D4B               ldx       #$2056
                    lbsr      L268D
L2D51               puls      pc,u,y,x,d

* Part of slime dividing routine
L2D53               pshs      u,y,x,b             Save regs
                    leas      -13,s               Reserve 13 extra bytes on stack
                    leau      ,s                  Point User stack to this 13 byte buffer
                    stx       ,u
                    clr       6,u
                    lda       $C,x
                    ora       #%10000000          $80
                    sta       $C,x
                    lda       $5,x
                    sta       8,u
                    ldb       4,x
                    stb       7,u
                    leax      11,u                Point X to 11 bytes into our temp stack buffer
                    bsr       L2DE0
                    tsta
                    bne       L2DC7
                    lda       8,u
                    deca
                    sta       2,u
                    adda      #2
                    sta       4,u
L2D7C               lda       2,u
                    cmpa      4,u
                    bhi       L2DD0
                    lda       7,u
                    deca
                    sta       3,u
                    adda      #2
                    sta       5,u
L2D8B               lda       3,u
                    cmpa      <u0005
                    bhi       L2DC3
                    ldd       2,u                 Get Y,X coords from ?
                    lbsr      L5AF2
                    cmpa      #$53                ? 'S' for slime, maybe?
                    bne       L2DBF               No, skip ahead
                    lda       2,u                 Yes, get Y coord back
                    lbsr      L2CDB               Search monster object list for matching monster in same position
                    stx       9,u                 Save ptr
                    beq       L2DBF
                    ldd       $C,x
                    anda      #$80
* 6809/6309 - doesn't this ALWAYS set Zero flag, which means BNE below is NEVER called?
                    andb      #$00
                    bne       L2DBF
                    bsr       L2D53
                    tsta
                    beq       L2DBF
                    lda       8,u
                    adda      #2
                    sta       2,u
                    lda       7,u
                    adda      #2
                    sta       3,u
L2DBF               inc       3,u
                    bra       L2D8B

L2DC3               inc       2,u
                    bra       L2D7C

L2DC7               lda       #1
                    sta       6,u
                    ldd       11,u
                    std       >$2056
L2DD0               ldx       ,u
                    ldd       12,x
                    anda      #%01111111          $7F
                    std       12,x
                    lda       6,u
                    leas      13,s
                    puls      pc,u,y,x,b

* Called from slime routine, and Create Monster routine
L2DE0               pshs      u,y,x,b
                    clr       >$2074
                    stx       >$2075
                    inca
                    sta       >$2079
                    suba      #2
                    sta       >$2077
                    stb       >$207E
L2DF4               lda       >$2077
                    cmpa      >$2079
                    bhi       L2E6F
                    lda       >$207E
                    deca
                    sta       >$2078
                    adda      #$02
                    sta       >$207A
L2E08               lda       >$2078
                    cmpa      >$207A
                    bhi       L2E6A
                    ldd       >$2077
                    cmpa      >$10DD
                    bne       L2E20
                    cmpb      >$10DC
                    beq       L2E65
L2E20               lbsr      L5ADE
                    tsta
                    bne       L2E65
                    ldd       >$2077
                    lbsr      L5AF2
                    sta       >$207B
                    lbsr      L58E8               Check map piece;on return A=0 if blank, wall piece or monster, A=1 otherwise
                    tsta
                    beq       L2E65
                    lda       >$207B
                    cmpa      #$CD                ? (Maybe checking for scroll)
                    bne       L2E4B
                    lda       >$2077
                    lbsr      L54E5
                    lda       $F,x
                    cmpa      #6
                    beq       L2E65
L2E4B               inc       >$2074
                    lda       >$2074
                    lbsr      L63A9               RND(A)
                    tsta
                    bne       L2E65               If <>0 skip ahead
                    ldy       >$2075
                    lda       >$2077
                    sta       1,y
                    lda       >$2078
                    sta       ,y
L2E65               inc       >$2078
                    bra       L2E08

L2E6A               inc       >$2077
                    bra       L2DF4

L2E6F               lda       >$2074
                    puls      pc,u,y,x,b

* Player is attacking monster
L2E75               pshs      u,y,x,b
                    sta       >$20E3
                    stu       >$20E4
                    stb       >$20E0
                    lda       1,y
                    ldb       ,y
                    lbsr      L2CDB               Search monster object list for matching monster in same position
                    clra
                    stx       >$20E6
                    lbeq      L3018
                    clr       >$0D9E
                    lbsr      L43D1
                    clr       >$0DA2
                    leax      ,y
                    lbsr      L268D
                    ldx       >$20E6
                    lda       #$58                'X' (Xeroc?)
                    cmpa      7,x
                    bne       L2ED6
                    cmpa      8,x
                    beq       L2ED6
                    ldx       #$10D8
                    ldd       #$0001
                    lbsr      L3C3C
                    tsta
                    bne       L2ED6
                    ldx       >$20E6
                    lda       #$58                'X' (Xeroc?)
                    sta       8,x
                    sta       >$20E0
                    tst       >$20E3
                    beq       L2ECC
                    clra
                    lbra      L3018

L2ECC               ldu       #$207F              'wait! That's a Xeroc!'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
L2ED6               ldb       >$20E0
                    subb      #$41
                    lda       #18
                    mul
                    addd      #$10FB              Point to our entry in the monster table
                    tfr       d,u
                    ldd       ,u
                    std       >$20E1
                    ldx       #$10D8
                    ldd       #1
                    lbsr      L3C3C
                    tsta
                    beq       L2EFA
                    ldd       #$14A7              'it'
                    std       >$20E1
L2EFA               ldx       >$20E6
                    ldu       >$20E4
                    lda       >$20E3
                    ldy       #$10D8
                    lbsr      L3450
                    tsta
                    bne       L2F1D
                    cmpu      #$0000
                    lbeq      L2FE1
                    lda       4,u
                    cmpa      #$CE                ? Potion?
                    lbne      L2FE1
L2F1D               clr       >$20E8
                    tst       >$20E3
                    beq       L2F34
                    ldy       >$20E1
                    ldd       #$20C9              'hits'
                    ldx       #$20CE              'hit'
                    lbsr      L38DF
                    bra       L2F3D

L2F34               clra
                    clrb
                    ldy       >$20E1
                    lbsr      L36C5
L2F3D               ldu       >$20E4
                    lda       4,u
                    cmpa      #$CE                ? Potion?
                    bne       L2F71
                    tfr       u,d
                    ldx       >$20E6
                    lbsr      L943F
                    tst       >$20E3
                    bne       L2F71
                    lda       $E,u
                    cmpa      #1
                    bls       L2F5D
                    dec       $E,u
                    bra       L2F6B

L2F5D               leax      ,u                  Point to object we want to remove
                    ldu       #$10F5              Get ptr to root object block for backpack
                    lbsr      L6112               Remove object (update linked list)
                    ldu       >$20E4
                    lbsr      L61A0
L2F6B               clr       >$0DB7
                    clr       >$0DB8
L2F71               tst       >$20E3
                    beq       L2F7C
                    ldu       >$20E4
                    lbsr      L61A0
L2F7C               ldx       #$10D8
                    ldd       #$0400
                    lbsr      L3C3C
                    tsta
                    beq       L2FAA
                    lda       #$01
                    sta       >$20E8
                    ldx       >$20E6
                    lda       $C,x
                    ora       #%00000001          $01
                    sta       $C,x
* 6809/6309 - Subroutine may use D, so leaving as is for now.
                    ldd       >$10E4
                    anda      #%11111011          $FB
                    andb      #%11111111          $FF
                    std       >$10E4
                    ldu       #$2095
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
L2FAA               ldx       >$20E6
                    ldd       <$15,x
                    bgt       L2FBD
                    lda       #1
                    lbsr      L3A1C               Call "killed monster" routine
                    bra       L2FDD

L2FBD               tst       >$20E8
                    beq       L2FDD
                    ldx       #$10D8
                    ldd       #$0001
                    lbsr      L3C3C
                    tsta
                    bne       L2FDD
                    ldu       >$20E1
                    pshs      u
                    ldu       #$20B1              'the %s appears confused'
                    pshs      u
                    lbsr      L68D8
                    leas      4,s
L2FDD               lda       #1
                    bra       L3018

L2FE1               tst       >$20E3
                    beq       L2FF8
                    ldu       >$20E4
                    ldy       >$20E1
                    ldd       #$20D2              'misses'
                    ldx       #$20D9              'missed'
                    lbsr      L38DF
                    bra       L3002

L2FF8               ldd       #$0000
                    ldy       >$20E1
                    lbsr      L3741
L3002               ldx       >$20E6
                    lda       7,x
                    cmpa      #$53                ?'S' Slime?
                    bne       L3017
                    lda       #100
                    lbsr      L63A9               RND(100)
                    cmpa      #25
                    bls       L3017
                    lbsr      L2D00
L3017               clra
L3018               puls      pc,u,y,x,b

* Monster attacks, I think. Includes special monster attacks for certain kinds
L301A               pshs      u,y,x,d
                    sty       >$21D9
                    clr       >$063C
                    clr       >$0D9E
                    lbsr      L43D1
                    clr       >$0DA2
                    lda       7,y
                    cmpa      #$58
                    bne       L3042
                    ldx       #$10D8
                    ldd       #$0001
                    lbsr      L3C3C
                    tsta
                    bne       L3042
                    lda       #$58
                    sta       8,y
L3042               lda       7,y
                    suba      #$41
                    ldb       #$12
                    mul
                    addd      #$10FB
                    tfr       d,u
                    ldd       ,u
                    std       >$21D7
                    ldx       #$10D8
                    ldd       #$0001
                    lbsr      L3C3C
                    tsta
                    beq       L3065
                    ldd       #$14A7              'it'
                    std       >$21D7
L3065               ldu       #$0000
                    clra
                    lbsr      L3450
                    tsta
                    lbeq      L336F
                    ldd       >$21D7
                    sty       >$21D9
                    ldy       #$0000
                    lbsr      L36C5
                    ldy       >$21D9
                    ldd       >$10ED
                    bgt       L3092
                    lda       7,y
                    lbsr      L0716
L3092               ldx       >$21D9
                    ldd       #$1000
                    lbsr      L3C3C
                    tsta
                    lbne      L339D
                    lda       7,y
                    lbeq      L339D
                    cmpa      #$41                'A'qator?
                    bne       L30EF               No, skip ahead
                    ldu       >$0DB1
                    lbeq      L339D
                    ldb       <$12,u
                    cmpb      #9
                    lbhs      L339D
                    ldb       $F,u
                    lbeq      L339D
                    lda       #$0D                Is player wearing a Maintain Armor ring?
                    lbsr      L3C00
                    tsta
                    beq       L30DB               No, lower armor class
                    pshs      u
                    ldu       #$20E9              'the rust vanishes instantly'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    puls      u
                    lbra      L339D

L30DB               pshs      u
                    ldu       #$2105              'your armor weakens, oh my!'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    puls      u
                    inc       <$12,u
                    lbra      L339D

L30EF               cmpa      #$49                'I'ce Monster?
                    bne       L3102               No, skip ahead
                    lda       >$0D98
                    cmpa      #1
                    lbls      L339D
                    dec       >$0D98
                    lbra      L339D

L3102               cmpa      #$52                'R'attlesnake?
                    bne       L3137               No, skip ahead
                    clra
                    lbsr      L37F4
                    tsta
                    lbne      L339D
                    lda       #2                  Is player wearing Sustain strength ring?
                    lbsr      L3C00
                    tsta
                    bne       L312A               Yes, skip weakening player's strength from snake bite
                    lda       #$FF
                    lbsr      L55F0
                    ldu       #$2120              'you feel a bite in your leg and now feel weaker'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbra      L339D

L312A               ldu       #$2150              'a bite momentarily weakens you'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbra      L339D

* Special Wraith/Vampire handling. Wraith will drop player a level (and his experience points)
L3137               cmpa      #'W                 $57 Wraith?
                    beq       L3141               Yes, skip ahead
                    cmpa      #'V                 $56 Vampire?
                    lbne      L3202               No, skip ahead
L3141               lda       #100                If Wraith or Vampire, RND(100)
                    lbsr      L63A9
                    tfr       a,b                 Copy random # to B
                    lda       7,y
                    cmpa      #'W                 $57 Wraith?
                    beq       L3152               Yes, set up chance of Wraith draining player
                    lda       #30                 No, Vampire drain is 30 in 100 chance
                    bra       L3154

L3152               lda       #15                 Wraith has 15 in 100 chance of draining player
L3154               pshs      a                   Save value
                    cmpb      ,s+                 Was RND(100)>=saved value?
                    lbhs      L339D               Yes, no draining attack, return
                    lda       #'W                 No, player drained by 'W'raith?
                    cmpa      7,y
                    bne       L31C1               No, skip ahead to Vampire drain routine
                    ldd       >$10E9              Wraith, get LSW of player's experience points
                    bne       L3172               There is some, skip ahead
                    ldd       >$10E7              Get MSW of player's experience points
                    bne       L3172               There is some, skip ahead
                    lda       #'W                 $57 Flag player was killed by wraith
                    lbsr      L0716               Player dead, end game

* Should never get here; left from debugging
                    swi

* Wraith drained player - drop his rank by 1, and experience points to what lower level needs+1
L3172               dec       >$10EB              Drop players rank 1 level
                    bne       L3188               Still rank 1 or higher, skip ahead
                    ldd       #$0000              Player back to rank 0, drop his experience points to 0
                    std       >$10E7
                    std       >$10E9
                    inca                          Set his rank to 1
                    sta       >$10EB
                    bra       L31B8               Skip ahead

L3188               lda       >$10EB              Get players new, lower rank
                    deca                          Drop by 1
                    lsla                          * 4 (4 bytes per entry)
                    lsla
                    ldu       #$4A90              Point to table of experience points needed to go to each player level/rank
                    leau      a,u                 Point to specific level (32 bit numbers)
                    ldd       2,u                 Copy experience points needed for next level to players current experience points
                    std       >$10E9
                    ldd       ,u
                    ldu       #$10E7
                    std       ,u
* NOTE: NOT TESTED YET!
* 6309 - ldq ,u / addw #1 / adcd #0 / stq ,u
                    ldd       2,u                 Add 1 experience point to player
                    addd      #1
                    std       2,u
                    ldd       ,u
                    adcb      #00
                    adca      #00
                    std       ,u

*         lda   3,u            Do a 4 byte add #1 ,u
*         adda  #1
*         sta   3,u
*         lda   2,u
*         adca  #$00
*         sta   2,u
*         lda   1,u
*         adca  #$00
*         sta   1,u
*         lda   ,u
*         adca  #$00
*         sta   ,u
L31B8               ldd       #$010A
                    lbsr      L63BB
                    bra       L31C8

* Vampire drained player comes here. Drops players max and current hit points by same partially random
*   amount
L31C1               ldd       #$0105              Loop ctr=1, divide by 5
                    lbsr      L63BB               Do random seed changes, plus remainder of divide
L31C8               pshs      d                   Save totalled remainder of divides
                    ldd       >$10F1              Get players current Max Hit points
                    subd      ,s                  Subtract the amount we got from routine above
                    std       >$10F1              Save new maximum hit points
                    ldd       >$10ED              Get players current hit points
                    subd      ,s++                Subtract the amount from routine above
                    std       >$10ED              Save as new current hit points
                    cmpd      #$0001              Still >=1?
                    bge       L31E6               Yes, skip ahead
                    ldd       #$0001              Force to 1
                    std       >$10ED
L31E6               ldd       >$10F1              Get new max player hit points
                    cmpd      #$0001              >=1?
                    bge       L31F5               Yes, skip ahead
                    lda       7,y                 Get cause of death (monster letter, maybe?)
                    lbsr      L0716               Player died

* Should never get here - left in original code for testing
                    swi

L31F5               ldu       #$216F              'you suddenly feel weaker'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbra      L339D

L3202               cmpa      #$46                'F' (Venus Flytrap)?
                    bne       L3226               No, check next
                    ldb       >$10E5              Get 2nd byte of player flags
                    orb       #%10000000          $80 Flag player is stuck
                    stb       >$10E5
                    inc       >$0DA0              Inc ?
                    lda       >$0DA0              Get current value
                    pshs      a                   Push value
                    ldu       #$21D2              '%id1' format string for digit
                    pshs      u
                    ldx       <$17,y              Get ptr of where to put final formatted string
                    lbsr      L3D23
                    leas      3,s
                    lbra      L339D

L3226               cmpa      #$4C                'L'eprechaun?
                    bne       L3293               No, check next
                    ldd       >$0D92              Get players current gold
                    std       >$21E0              Save copy
                    lbsr      L3BD1               D=[$2DE0] / (Dungeon level*10)+50 (somewhat random, I think)
                    pshs      d                   Save remainder
                    ldd       >$0D92              Get players current gold
                    subd      ,s++                Subtract amount leprechaun stole
                    std       >$0D92              Save new amount
                    lda       #3                  ???
                    lbsr      L37F4               Something based on player wearing rings of protection (returns 0 or 1)
                    tsta                          If 1, skip ahead
                    bne       L3267
                    lbsr      L3BD1               D=[$2DE0] / (Dungeon level*10)+50 (somewhat random, I think)
                    pshs      d
                    lbsr      L3BD1               D=[$2DE0] / (Dungeon level*10)+50 (somewhat random, I think)
                    pshs      d
                    lbsr      L3BD1               D=[$2DE0] / (Dungeon level*10)+50 (somewhat random, I think)
                    pshs      d
                    lbsr      L3BD1               D=[$2DE0] / (Dungeon level*10)+50 (somewhat random, I think)
                    addd      ,s++                Add the 4 somewhat random numbers based on dungeon level
                    addd      ,s++
                    addd      ,s                  Add final, and save full result back to stack
                    std       ,s
                    ldd       >$0D92              Get players gold
                    subd      ,s++                Subtract that new amount
                    std       >$0D92              Save new amount
L3267               ldd       >$0D92              Get players gold
                    bge       L3275               If >=0 skip ahead
                    clra                          If went negative, set to 0
                    clrb
                    std       >$0D92              Save it back
L3275               leau      4,y                 Point to monster type (L in this case)
                    clra                          A=0 means removing monster from linked list (Leprechaun vanishes after stealing gold)
                    lbsr      L3937               Remove Leprechaun from monster list
                    ldd       >$0D92              Get players gold
                    cmpd      >$21E0              Get players original gold
                    lbeq      L339D               No change, clean up and return
                    ldu       #$2188              'your purse feels lighter'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbra      L339D

* Routine where Nymph steals an object from players backpack. She will NOT steal items
*  being worn or wielded, or "normal" objects (food, +0 armor, +/- weapons)
L3293               cmpa      #$4E                'N'ymph?
                    lbne      L3332               No, try next
                    ldd       #$0000
                    std       >$21DD              Init object ptr (item she is stealing?)
                    sta       >$21DF              Init ???
                    ldx       >$10F5              Get ptr to root object block for backpack contents
L32A5               stx       >$21DB              Save working copy
                    beq       L32D8               No more objects in backpack, skip ahead
                    cmpx      >$0DB1              Is this current armor being worn?
                    beq       L32D3               Yes, skip to next object
                    cmpx      >$0DB7              Is this current weapon being wielded?
                    beq       L32D3               Yes, skip to next object
                    cmpx      >$0DB3              Is this current ring on left hand?
                    beq       L32D3               Yes, skip to next object
                    cmpx      >$0DB5              Is this current ring on right hand?
                    beq       L32D3               Yes, skip to next object
                    lbsr      L39CF               No, check if "normal" (not blessed/cursed) weapon/armor or food
                    tsta
                    beq       L32D3               Yes, normal object, skip to next object in backpack
                    inc       >$21DF              Magical object, inc flag
                    lda       >$21DF              Get flag (1)
                    lbsr      L63A9               RND(1)
                    tsta
                    bne       L32D3               If 1, skip to next object
                    stx       >$21DD              If 0, save ptr to object
L32D3               ldx       ,x                  Get ptr to next object in linked list
                    bra       L32A5               Keep checking

L32D8               ldx       >$21DD              Get object to be stolen by Nymph
                    lbeq      L339D               None, skip stealing routines
                    leau      4,y                 Point to monster letter (N in this case)
                    clra                          A=0 means remove monster from monster list
                    lbsr      L3937               Remove Nymph from monster list
                    dec       >$0D9A
                    ldx       >$21DD              Get ptr to object Nymph is stealing
                    lda       $E,x                Get quantity of object
                    ldb       $E,x                and copy (1 cyc faster than tfr a,b)
                    cmpa      #1                  If 1 or lower, skip ahead
                    bls       L3313
                    lda       <$15,x              Get ???
                    bne       L3313               If <>0, skip ahead
* >1 of object, remove 1 of them only
                    decb                          Drop copy of quantity by 1
                    lda       #1                  Set quantity to 1
                    sta       $E,x
                    lbsr      L72B6               Generate string description of object
                    pshs      u
                    ldu       #$21A1              'she stole %s!'
                    pshs      u
                    lbsr      L68D8               Print that on screen
                    leas      4,s
                    stb       $E,x                Save new quantity (original qty-1)
                    bra       L339D

* Only 1 object, remove whole entry
* Entry: X=Ptr to object to remove
L3313               ldu       #$10F5              Get ptr to root object block in backpack
                    lbsr      L6112               Remove object block ,X from backpack (update linked list)
                    leau      ,x
                    lbsr      L61A0               Remove item from inventory?
                    lda       #1
                    lbsr      L72B6               Build string of name of object she stole
                    pshs      u
                    ldu       #$21A1              'she stole %s!'
                    pshs      u
                    lbsr      L68D8               Print it
                    leas      4,s
                    bra       L339D

L3332               cmpa      #$4A                'J'abberwock?
                    bne       L339D               No, skip ahead
                    ldx       >$10F5              Get ptr to root object block for player's backpack contents
                    beq       L339D               Backpack empty, skip ahead
                    lda       4,x                 Get object type
                    cmpa      #$CC                Food?
                    bne       L334B               No, skip ahead
                    ldx       ,x                  Get ptr to next backpack object
                    beq       L339D               If player has only 1 food in his/her entire backup, have pity on them
L334B               lda       #5                  RND(5)
                    lbsr      L63A9
                    tsta                          If RND is not 0, skip ahead
                    bne       L339D
                    ldu       #$10F5              Get ptr to root object block for player's backpack contents
                    lbsr      L6112               Remove item (pointed to by X) from inventory (update linked list)
                    leau      ,x
                    lbsr      L61A0
                    ldu       #$21AF              'something in your pack explodes!!!'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    bra       L339D

L336F               lda       7,y                 Get monster type
                    cmpa      #'I                 Ice Monster?
                    beq       L339D               Yes, skip ahead
                    cmpa      #'F                 Venus Flytrap?
                    bne       L3393               No, skip ahead
                    ldb       >$0DA0              Get damage value
                    clra
                    pshs      d
                    ldd       >$10ED              Get players hit points
                    subd      ,s++                Subtract damage and save it back
                    std       >$10ED
                    bge       L3393               Player at >=0, skip ahead
                    lda       7,y                 Get monster letter type again
                    lbsr      L0716               Player died, do death routine and exit

* 6809/6309 - Should never get here. Left in by Epyx for debugging
                    swi

L3393               ldd       >$21D7
                    ldy       #$0000
                    lbsr      L3741               Attack missed, notify player
L339D               lbsr      L621D               Set up >$1471 ptr to #$1470, copy >$2DDE to >$2DDD
                    lbsr      L6AA2               Update bottom status line of player & return
                    puls      pc,u,y,x,d

* Entry: A=players rank (sometimes adjusted by +/- 1)
*        B=Players armor class
*        U=??? (1 in two cases; not sure on 3rd)
* ??? Exit: A=0 or 1, depending on some math
L33A5               pshs      u,y,x,b
                    std       >$21E3              Save copies of players rank & Armor Class
                    tfr       u,d                 Copy flag byte over to B
                    stb       >$21E5              ??? Save flag?
                    lda       #20                 RND(20)
                    lbsr      L63A9
                    sta       >$21E2              Save that
                    ldb       #20                 B=20-(Players rank+Players Armor class)
                    subb      >$21E3
                    subb      >$21E4
                    pshs      b                   Save on stack
                    lda       >$21E2              Get original RND(20)
                    adda      >$21E5              Add to flag byte
                    cmpa      ,s+                 Is that >= calculation above?
                    bge       L33D1               Yes, exit with A=1
                    clra                          No, exit with A=0
                    puls      pc,u,y,x,b

L33D1               lda       #1
L33D3               puls      pc,u,y,x,b

* Figure out players rank by their experience points. Bump rank if needed
L33D5               pshs      u,y,x,d
                    clr       >$2203              Init players rank to 0
                    ldy       #$4A90              Point to Experience Points needed for each rank table (long 32 bit #'s)
L33DE               ldd       2,y                 If non-zero, jump ahead
                    bne       L33E6
                    ldd       ,y
                    beq       L344E               It is zero, exit
L33E6               ldd       ,y                  Get upper 16 bits
                    cmpd      >$10E7              Compare with upper 16 bits of players experience points?
                    blo       L33F8               If lower, skip ahead
                    bhi       L33FF               If higher, branch ahead
                    ldd       2,y                 If equal, check lower 16 bits
                    cmpd      >$10E9
                    bhi       L33FF               If higher, skip ahead
L33F8               leay      4,y                 Bump up to next 32 bit entry
                    inc       >$2203              Inc rank ctr
                    bra       L33DE

* Bump up rank of player
L33FF               inc       >$2203              Bump rank up by 1
                    ldb       >$2203              Get it
                    lda       >$10EB              Get players original rank
                    stb       >$10EB              Save player rank overtop
                    pshs      a                   Save original rank
                    cmpb      ,s+                 Is new rank same or lower as original?
                    bls       L344E               Yes, return
                    pshs      a                   Save original rank again.
                    subb      ,s+
                    tfr       b,a
                    ldb       #10
                    lbsr      L63BB
                    pshs      d
                    addd      >$10F1              Add to players max hit points, and save new total
                    std       >$10F1
                    puls      d
                    addd      >$10ED              Add to players current hit points, and save new total
                    std       >$10ED
                    cmpd      >$10F1
                    ble       L3438               If new current is <= maximum, we are done with hit points
                    ldd       >$10F1              Anything >maximum, get forced to maximum
                    std       >$10ED
L3438               lda       >$2203              Get players level/rank
                    deca                          Make zero based
                    lsla                          * 2 since 2 byte pointers
                    ldu       #$0504              Point to table of name offsets for players level (rank)
                    ldu       a,u                 Get ptr to players rank (text)
                    pshs      u                   Save for print routine
                    ldu       #$21E6              'and achieved the rank of "%s"'
                    pshs      u
                    lbsr      L68D8               Go print it
                    leas      4,s
L344E               puls      pc,u,y,x,d

* Routine to figure out chance of hitting monster, and damage to do.
* Checks for two special rings worn by player: Dexterity (increases chance
*  of hitting monster), and increase damage). Multiple rings of the same type
*  have a cumulative effect.
L3450               pshs      u,y,x,b             Save regs on stack
                    sty       >$2204              And save most of them again
                    stx       >$2206
                    sta       >$220A
                    leay      $E,y
                    sty       >$2212
                    leax      $E,x
                    stx       >$220B
                    ldx       >$2206
                    stu       >$2208
                    bne       L3481               If U=0, skip ahead
                    ldd       9,y
                    std       >$220D
                    clr       >$220F              Clear damage
                    clr       >$2210              Clear chance to hit monster
                    lbra      L355B

* Modify attack based on rings worn.
* Dexterity ring increases chance of hitting monster, Increase damage self-explanatory.
L3481               ldd       <$10,u              Get initial chance to hit & damage
                    std       >$2210              Save copies of both
                    lda       7,x
                    cmpa      <$14,u
                    bne       L34A4
                    lda       #4                  ??? Roll to hit monster?
                    adda      >$2210
                    sta       >$2210
                    lda       #4                  Add 4 to damage
                    adda      >$220F
                    sta       >$220F
L34A4               cmpu      >$0DB7
                    bne       L3500
                    ldd       #$0008              Left hand, check for ring type #8 (Increase damage)
                    lbsr      L3BE8
                    ldy       >$0DB3              Get ptr to ring object we are wearing on left hand
                    ldb       <$12,y              get damage modifier(?)
                    tsta                          Is player wearing Increase damage on left hand?
                    beq       L34C3               No, check next ring type
                    addb      >$220F              ?Yes, add damage modifier to damage
                    stb       >$220F
                    bra       L34D5

L34C3               pshs      b
                    ldb       #7
                    lbsr      L3BE8               Left hand, check for ring type #7 (Dexterity)
                    puls      b
                    tsta
                    beq       L34D5
                    addb      >$2210              If player has dexterity, increase his chance of hitting monster
                    stb       >$2210
L34D5               ldd       #$0108              Right hand, check for ring type #8 (increase damage)
                    lbsr      L3BE8
                    ldy       >$0DB5
                    ldb       <$12,y
                    tsta
                    beq       L34EE               No, check next type/hand
                    addb      >$220F
                    stb       >$220F
                    bra       L3500

L34EE               pshs      b
                    ldb       #$07                Right hand, check for ring type #7 (Dexterity)
                    lbsr      L3BE8
                    puls      b
                    tsta
                    beq       L3500               No, don't adjust chance to hit
                    addb      >$2210              If player has dexterity, increase his chance of hitting monster
                    stb       >$2210
L3500               ldd       $A,u                Get ptr to damage string
                    std       >$220D              Save copy
                    tst       >$220A
                    beq       L3534
                    lda       <$13,u              Get object flags
                    anda      #%00010000          $10 ? Check flag?
                    beq       L3534               Not set, skip ahead
                    ldy       >$0DB7              Get ptr to object being wielded
                    beq       L3534               None, skip ahead
                    lda       $F,y                Get weapon type
                    cmpa      9,u                 Compare with ???
                    bne       L3534               Different, skip ahead
                    ldd       $C,u                Get 2nd version of weapons damage string ptr
                    std       >$220D              Save it
                    lda       <$10,y
                    adda      >$2210              ??? Add to chance of player hitting monster?
                    sta       >$2210              Save it
                    lda       <$11,y              Get ???
                    adda      >$220F              Add to damage player is doing to monster
                    sta       >$220F              Save it
L3534               lda       4,u                 Get object type
                    cmpa      #$D2                Is it a wand/staff?
                    bne       L355B               No, skip ahead
                    lda       $F,u                Get wand type
                    cmpa      #1                  Wand of striking?
                    bne       L355B               No, skip ahead
                    dec       <$12,u              ? Dec # of charges remaining?
                    lda       <$12,u              ? Get # of charges remaining
                    bhs       L355B               If <>0, skip ahead
                    ldd       #$2219              '0D0'
                    std       >$220D
                    std       $A,u                Save ptr to damage string as 1st weapons damage string ptr
                    clr       <$11,u              0 extra damage
                    clr       <$10,u              0 blessing level
                    clr       <$12,u              0 charges left
L355B               ldx       >$2206
                    ldd       #%0000000000000100  4 Check if bit 3 set @ 12,x
                    lbsr      L3C3C
                    tsta
                    bne       L356F               Yes, skip ahead
                    lda       #4                  no, add 4 to chance to player hitting monster
                    adda      >$2210
                    sta       >$2210
L356F               ldy       >$220B
                    lda       6,y
                    sta       >$2211
                    ldd       #$10E6              Check if ptr is pointing one of the players damage ptr
                    cmpd      >$220B
                    bne       L35C3
                    ldy       >$0DB1              Get ptr to object block for armor being worn
                    beq       L358D               No armor being worn; skip ahead
                    lda       <$12,y              Get damage modifier for armor
                    sta       >$2211              Save work copy
L358D               clra                          Check if player is wearing ring of Protection on left hand
                    clrb
                    lbsr      L3BE8
                    tsta
                    beq       L35A8               Nope, check right hand
                    ldy       >$0DB3              Get ptr to object block for ring on left hand
                    lda       <$12,y              Get +/- of ring of Protection
                    pshs      a                   Save on stack
                    lda       >$2211              Get current damage received modifier
                    suba      ,s+                 Bump down (up) by amount of protection
                    sta       >$2211              Save new value
L35A8               ldd       #$0100              Check if player is wearing ring of Protection on right hand
                    lbsr      L3BE8
                    tsta
                    beq       L35C3               Nope, skip ahead
                    ldy       >$0DB5              Get ptr to object block for ring on right hand
                    lda       <$12,y              Get +/- of ring of protection
                    pshs      a                   Add that to the current damaged received modifier
                    lda       >$2211
                    suba      ,s+
                    sta       >$2211
L35C3               clr       >$2218              ???
L35C6               ldy       >$220D              Get ptr to '0D0' style damage string
L35CA               lbsr      L3AFF               Convert to 8 bit binary number
                    sta       >$2216              Save it
                    ldy       >$220D              Get ptr back
L35D4               ldb       ,y+                 Get "chance to hit" part of damage string?
                    lbeq      L366A               0, lda >$2218 and return
                    cmpb      #'d                 D? (separator char between chance to hit and damage)
                    bne       L35D4               No, keep reading damage string until we find it
                    sty       >$220D              Save ptr to "damage" part of damage string?
                    lbsr      L3AFF               Convert damage ASCII to binary
                    sta       >$2217              Save it
                    ldy       >$2212
                    lda       ,y
                    lbsr      L3837
                    adda      >$2210              Add to chance to hit monster?
                    tfr       a,b
                    clra
                    tfr       d,u
                    lda       5,y
                    ldb       >$2211              Get damage modifier for armor being worn
                    lbsr      L33A5
                    tsta
                    beq       L3655
                    ldd       >$2216
                    lbsr      L63BB
                    pshs      d
                    ldb       >$220F              Get damage player is doing
                    sex                           16 bit signed
                    addd      ,s++
                    pshs      d
                    ldu       >$2212              Get ptr
                    ldb       ,u
                    lbsr      L3867
                    addd      ,s++
                    std       >$2214
                    ldy       >$2206              Get ptr
                    cmpy      #$10D8              ??? Is it pointing to (some data block)
                    bne       L3640               No, skip ahead
                    lda       #1                  Yes,
                    cmpa      >$0D90
                    bne       L3640
                    ldd       >$2214              Get ???
                    addd      #1                  Add 1, then divide result by 2
                    lsra
                    rorb
                    std       >$2214              Save new result
L3640               ldd       >$2214              Get ???
                    bmi       L3650               If negative, skip ahead
                    ldy       >$220B              Get ptr to ???
                    ldd       7,y
                    subd      >$2214
                    std       7,y
L3650               lda       #1
                    sta       >$2218
L3655               ldy       >$220D              Get ptr to attack/damage string
L3659               lda       ,y                  Get "chance to hit" modifier?
                    beq       L366A               If 0, skip ahead
                    leay      1,y                 Not 0, point to next char
                    cmpa      #$2F                Is it a slash '/'?
                    bne       L3659               No, keep going until we find NUL or slash
                    sty       >$220D              Once we find NUL or slash, save ptr to that
                    lbra      L35CA               Loop back to process char

L366A               lda       >$2218
                    puls      pc,u,y,x,b

L366F               pshs      y,x,d
                    sta       >$2222
                    clra
                    sta       >$4AE4
                    stu       >$2223
                    bne       L368C
                    ldx       #$4AE4
                    ldu       #$14AA              'you'
                    lbsr      L3FF3               Copy string from U to X
                    bra       L36B2

L368C               ldx       #$10D8              Point to block of player data
                    ldd       #%0000000000000001  $0001 Check if player blind bit set @ 12,x (player status flags)
                    lbsr      L3C3C
                    tsta
                    beq       L36A3               No, skip ahead
                    ldx       #$4AE4              Yes, player can't see, so any monster becomes "it"
                    ldu       #$14A7              'it'
                    lbsr      L3FF3               Copy string from U to X
                    bra       L36B2

L36A3               ldx       #$4AE4
                    ldu       #$221D              'the '
                    lbsr      L3FF3               Copy string from U to X
                    ldu       >$2223              Get ptr to string to append
                    lbsr      L3FFD               Append string @ ,U to string pointed to by ,X
L36B2               tst       >$2222
                    beq       L36C0
                    lda       >$4AE4              Get first char from string @ ,X
                    lbsr      L3F5D
                    sta       >$4AE4
L36C0               ldu       #$4AE4
                    puls      pc,y,x,d

L36C5               pshs      u,y,x,d
                    std       >$228E
                    sty       >$228C
                    tfr       d,u
                    lda       #1
                    bsr       L366F
                    pshs      u
                    lbsr      L68FD
                    leas      2,s
                    lda       #4                  RND(4)
                    lbsr      L63A9
                    tsta
                    bne       L36F1               If RND(4)<>0, try next
                    lda       >$37CB              Get window width
                    cmpa      #54                 If <54, force to always say "hit"
                    blo       L36F5
                    ldu       #$2225
                    bra       L3728

L36F1               cmpa      #1                  If RND(4)<>1, try next
                    bne       L36FA
L36F5               ldu       #$2242              ' hit '
                    bra       L3728

L36FA               cmpa      #2                  IF RND(4) is 3 or 4, use 'swing and hit' derivatives
                    bne       L3714
                    lda       >$37CB              Get window width
                    cmpa      #40                 If window width<40, use "hit"
                    blo       L36F5
                    ldd       >$228E              If ??? <>0, use "has injured" instead of "have injured"
                    bne       L370F
                    ldu       #$2248              ' have injured '
                    bra       L3728

L370F               ldu       #$2257              ' has injured '
                    bra       L3728

L3714               lda       >$37CB              If RND(4)=2, get window width
                    cmpa      #43                 If width<43, just say "hit"
                    blo       L36F5
                    ldd       >$228E              If ??? <>0, then "swings and hits"
                    bne       L3725
                    ldu       #$2277              ' swing and hit '
                    bra       L3728

L3725               ldu       #$2265              ' swings and hits '
L3728               leay      ,u                  Point Y to string
                    ldu       >$228C
                    clra
                    lbsr      L366F               Do some string stuff
                    pshs      u
                    pshs      y
                    ldu       #$2287              '%s%s'
                    pshs      u
                    lbsr      L68D8
                    leas      6,s
                    puls      pc,u,y,x,d

* Attack missed, build appropriate message and display it
L3741               pshs      u,y,x,d
                    std       >$22FD
                    sty       >$22FB
                    tfr       d,u
                    lda       #1
                    lbsr      L366F
                    pshs      u
                    lbsr      L68FD
                    leas      2,s
                    lda       #4                  RND(4) to get which type of "missed" attack to display on screen
                    lbsr      L63A9
                    tsta                          Is it 0?
                    bne       L3777               No, try next
                    lda       >$37CB
                    cmpa      #$2C
                    blo       L377B
                    ldd       >$22FD
                    bne       L3772
                    ldu       #$2290              ' swing and miss'
                    bra       L37BA

L3772               ldu       #$22A0              ' swings and misses'
                    bra       L37BA

L3777               cmpa      #1                  RND(4)=1?
                    bne       L378A               No, try next
L377B               ldd       >$22FD
                    bne       L3785
                    ldu       #$22B3              ' miss'
                    bra       L37BA

L3785               ldu       #$22B9              ' misses'
                    bra       L37BA

L378A               cmpa      #2                  RND(4)=2?
                    bne       L37A4               No, do last option
                    lda       >$37CB              Get window width
                    cmpa      #40                 If <40, always use 'miss' or 'misses'
                    blo       L377B
                    ldd       >$22FD
                    bne       L379F
                    ldu       #$22C1              ' barely miss'
                    bra       L37BA

L379F               ldu       #$22CE              ' barely misses'
                    bra       L37BA

L37A4               lda       >$37CB              Get window width
                    cmpa      #38                 If <38, force to 'miss' or 'misses'
                    blo       L377B
                    ldd       >$22FD
                    bne       L37B5
                    ldu       #$22DD              ' don't hit'
                    bra       L37BA

L37B5               ldu       #$22E8              ' doesn't hit'
L37BA               leay      ,u
                    ldu       >$22FB
                    clra
                    lbsr      L366F
                    pshs      u
                    pshs      y
                    ldu       #$22F5              '%s %s'
                    pshs      u
                    lbsr      L68D8
                    leas      6,s
                    puls      pc,u,y,x,d

* ???
* Exit: A=0 or 1
L37D3               pshs      y,b
                    adda      #14
                    ldb       <$13,y              Get value
                    lsrb                          Divide by 2
                    pshs      b
                    suba      ,s                  14-(value)
                    sta       ,s                  Save it over original on stack
                    ldd       #$0114              Lp ctr=1, divide by 20
                    lbsr      L63BB               Divide [>$2DE0] by 20
                    cmpb      ,s+
                    bhs       L37F0
                    clra
                    puls      pc,y,b

L37F0               lda       #1
L37F2               puls      pc,y,b

L37F4               pshs      y,b
                    sta       >$22FF
                    cmpa      #3
                    bne       L382B
                    clra
                    clrb
                    lbsr      L3BE8               Check if player is wearing ring of Protection on left hand
                    tsta
                    beq       L3814               Nope, check if one on right hand
                    ldy       >$0DB3              Get ptr to object block for ring on left hand
                    lda       >$22FF              Get ???
                    suba      <$12,y              Subtract the +/- of the ring
                    sta       >$22FF              Save that back
L3814               ldd       #$0100
                    lbsr      L3BE8               Check if player is wearing ring of Protection on right hand
                    tsta
                    beq       L382B               Nope, skip ahead
                    ldy       >$0DB5              Get ptr to object block for ring on right hand
                    lda       >$22FF              Get ???
                    suba      <$12,y              Subtract the +/- of the ring
                    sta       >$22FF              Save it back
L382B               lda       >$22FF              Get final modifier
                    ldy       #$10D8              Point to player data block
                    bsr       L37D3
                    puls      pc,y,b

* Entry: A=value pointed to by address in $2212
* Exit: >$2300 is 0-4, based on value in A
*       A is the value in $2300, except if incoming A<8. Then it's incoming A-7
L3837               pshs      b
                    ldb       #4                  Init ??? to 4
                    stb       >$2300
                    cmpa      #8
                    bhs       L3846
                    suba      #7
                    puls      pc,b

L3846               cmpa      #31                 If ??? >=31, >$2300 = 4
                    bhs       L3862
                    dec       >$2300              Drop ? by 1
                    cmpa      #21                 If ??? is 21-30, >$2300 = 3
                    bhs       L3862
                    dec       >$2300
                    cmpa      #19                 If ??? is 19-20, >$2300 = 2
                    bhs       L3862
                    dec       >$2300
                    cmpa      #17                 If ??? is 17-18, >$2300 = 1
                    bhs       L3862
                    dec       >$2300              If ??? is 0-16, >$2300 = 0
L3862               lda       >$2300              Load new value into A & return
                    puls      pc,b

L3867               lda       #6                  Init >$2301 to 6
                    sta       >$2301
                    cmpb      #8                  Is entry parm>=8?
                    bhs       L3879               Yes, scale done >$2301 based on it
                    lda       #7                  No, subtract 7 from it
                    pshs      a
                    subb      ,s+
                    sex                           Convert to 16 bit (note: can be negative or positive)
                    rts

L3879               cmpb      #31                 If ??? >=31 then >$2301=6
                    bhs       L38A3
                    dec       >$2301
                    cmpb      #22                 If ??? is 22-30, then >$2301=5
                    bhs       L38A3
                    dec       >$2301
                    cmpb      #20                 If ??? is 20-21, then >$2301=4
                    bhs       L38A3
                    dec       >$2301
                    cmpb      #18                 If ??? is 18-19, then >$2301=3
                    bhs       L38A3
                    dec       >$2301
                    cmpb      #17                 If ??? is 17, then >$2301=2
                    bhs       L38A3
                    dec       >$2301
                    cmpb      #16                 If ??? is 16, then >$2301=1
                    bhs       L38A3
                    dec       >$2301              If ??? is 8 to 15, then >$2301=0
L38A3               ldb       >$2301              Get value, make 16 bit (signed) & return
                    sex
                    rts

* Raise player up one skill level (Raise Level potion)
* Gives the player the # of experience points needed for next level and 1 extra
L38A8               pshs      u,d
                    lda       >$10EB              Get player's current rank/level
                    deca                          Make 0 based
                    lsla                          * 4 (32 bit experience point level per level in table)
                    lsla
                    ldu       #$4A90              Point to experience points required for each level table
                    leau      a,u                 Point to the specific entry we want
                    ldd       ,u                  Copy experience points needed for level to player's current experience points
                    std       >$10E7
                    ldd       2,u
                    std       >$10E9
                    ldu       #$10E7              Point to 4 byte long experience points for player
                    ldd       2,u                 Add 1 more point to players experience points
                    addb      #1
                    adca      #0
                    std       2,u
                    ldd       ,u
                    adcb      #0
                    adca      #0
                    sta       ,u
                    lbsr      L33D5               Go do actual Rank/Level check (and upgrade, in this case)
                    puls      pc,u,d

* Entry: D=ptr to 'hits' or 'misses', X=ptr to 'hit' or 'missed'
L38DF               pshs      u,y,x,d
                    std       >$2302              Save ptr to present tense attack result string
                    lda       4,u                 Get object type
                    cmpa      #$CF                Weapon?
                    bne       L3905               No, skip ahead
                    ldd       >$2302              Get ptr to present tense attack result string
                    pshs      d                   Save it
                    lda       $F,u                Get weapon table entry #
                    lsla                          *2 since 2 byte entries
                    ldu       #$004B              Base of table (weapons name table)
                    ldd       a,u                 Get ptr to weapon name
                    pshs      d                   Save it
                    ldu       #$2304              'the %s %s '
                    pshs      u
                    lbsr      L68FD               Print attack result
                    leas      6,s
                    bra       L3911

L3905               pshs      x
                    ldu       #$230F              'you %s '
                    pshs      u
                    lbsr      L68FD               Print result
                    leas      4,s
L3911               ldx       #$10D8              Point to player data block
                    ldd       #%0000000000000001  $0001
                    lbsr      L3C3C               Is player blinded?
                    tsta
                    beq       L3929               No, identify monster by name
                    ldd       #$14A7              Yes, just call it 'it'
                    pshs      d
                    lbsr      L68D8
                    leas      2,s
                    puls      pc,u,y,x,d

L3929               pshs      y
                    ldu       #$2317              'the %s'
                    pshs      u
                    lbsr      L68D8
                    leas      4,s
                    puls      pc,u,y,x,d

* Part of player hitting monster (direct, not thrown). Or maybe removing monster if defeated, disappears?
* Entry: A=0 (monster disappears - Leprechaun or Nymph), A=1 (player has defeated monster)
*        U=ptr to monster type (single character)
*        Y=ptr to object block for monster
L3937               pshs      u,y,x,d
                    sta       >$2324              Save flag as to why monster is being removed
                    stu       >$2322              Save ptr to monster type
                    leay      ,y                  No monster?
                    beq       L39CD               None, return
                    ldx       <$1D,y              Get ptr to ??? (next monster in monster linked list?)
L394A               beq       L397A               Empty, skip ahead
                    stx       >$231E              Save current linked list ptr?
                    ldx       ,x                  Get ptr to next object (monster)?
                    stx       >$2320              Save copy
                    ldx       >$231E              Get other ptr (object/monster) to delete
                    ldd       4,y                 Get
                    std       5,x
                    leau      <$1D,y              Point U to ptr to next monster in linked list)
                    lbsr      L6112               Go remove monster (update linked list)
                    tst       >$2324              Is the monster disappearing, or killed?
                    beq       L3970               Disappearing, skip ahead
                    clra                          If killed, do ???
                    lbsr      L88B1
                    bra       L3975

L3970               leau      ,x                  Monster killed, do???
                    lbsr      L61A0
L3975               ldx       >$2320              Get ptr to next (object or monster)
                    bra       L394A               Keep looping

L397A               ldu       >$2322              Get ptr back
                    lda       1,u                 ? Get Y coord of monster?
                    ldb       ,u                  ? Get X coord of monster?
                    lbsr      L5AAA               X=offset into 80x22 map
L398F               lda       9,y
                    cmpa      #$C2                Floor?
                    bne       L39AD               No, skip ahead
                    lda       1,u                 ? Get Y coord
                    ldb       ,u                  ? Get X coord
                    lbsr      L28A4               Calc some sort of distance between two points
                    tsta
                    bne       L39AD
                    ldx       #$0020
                    lda       1,u                 ? Get Y coord
                    ldb       ,u                  ? Get X coord
                    lbsr      L68C4               Update on screen map
                    bra       L39BD

L39AD               ldb       9,y
                    cmpb      #$40                ??? '@' on map? (may be wrong on this one?)
                    beq       L39BD               Yes, skip ahead
                    clra                          No, Move B to X
                    tfr       d,x
                    lda       1,u                 ? Get Y coord
                    ldb       ,u                  ? Get X coord
                    lbsr      L68C4
L39BD               ldu       #$10F9              Get ptr to root monster block
                    leax      ,y                  Point to monster object to delete
                    lbsr      L6112               Go remove it (update linked list)
                    leau      ,y
                    lbsr      L61A0
L39CD               puls      pc,u,y,x,d

* Set flag based on object type, and sometimes object attibutes.
* Entry: X=ptr to object table entry
* Exit   A=0 if : Armor or Weapon with "normal" (+0) attributes OR
*                 non-magical item (like food)
*        A=1 if : Armor or Weapon with -/+ attributes OR
*                   if potion,scroll,wand,ring,Amulet of Yendor
L39CF               pshs      x,b
                    lda       4,x                 Get object type
                    cmpa      #$D0                Armor?
                    bne       L39EA               No, skip ahead
                    lda       $F,x                Get armor type
                    ldu       #$014E              Point to start of armor class table
                    lda       a,u                 Get default armor class for armor type
                    cmpa      <$12,x              Same as current armor type in object?
                    bne       L39E6               No, exit with A=1
L3A17               clra                          Yes, exit with A=0
                    puls      pc,x,b

L39E6               lda       #1                  Flag that armor class on armor is different than "normal" for this type of armor
                    puls      pc,x,b

L39EA               cmpa      #$CF                Weapon?
                    bne       L39FF               No, skip ahead
                    lda       <$10,x              Get blessing level of object
                    bne       L39E6               If not 0, exit with flag=1
                    lda       <$11,x              Get extra damage
                    bne       L39E6               Is not 0, exit with flag=1
                    clra                          Normal weapon, exit with flag=0
                    puls      pc,x,b

L39FF               cmpa      #$CE                Potion?
                    beq       L3A13               Yes, exit with flag =1
                    cmpa      #$CD                Scroll?
                    beq       L3A13               Yes, exit flag=1
                    cmpa      #$D2                Wand?
                    beq       L3A13               Yes, exit flag=1
                    cmpa      #$D1                Ring?
                    beq       L3A13               Yes, exit flag=1
                    cmpa      #$D5                Amulet of Yendor?
                    bne       L3A17               If not that object, exit flag=0
L3A13               lda       #1                  Exit flag=1
                    puls      pc,x,b

* Player killed monster. Add experience points (I think),gold (if leprechaun), and untrap
*  player (if Venus flytrap) and report monster killed.
L3A1C               pshs      u,y,x,d
                    sta       >$2327
                    stx       >$2325
* 32 bit add of [$F,X] + [>$10E7]. Experience points, maybe?
                    ldd       <$11,x              Get LSW
                    addd      >$10E9              Add LSW
                    std       >$10E9              Save updated LSW
                    ldd       <$F,x               Get MSW
                    adcb      >$10E8              Add low byte of MSW
                    adca      >$10E7              Add high byte of MSW
                    std       >$10E7              Save MSW

* 32 bit add of [$F,X] + [>$10E7]. Should be able to use D to speed/shrink
*         lda   <$12,x
*         adda  >$10EA
*         sta   >$10EA
*         lda   <$11,x
*         adca  >$10E9
*         sta   >$10E9
*         lda   <$10,x
*         adca  >$10E8
*         sta   >$10E8
*         lda   $F,x
*         adca  >$10E7
*         sta   >$10E7

                    lda       7,x                 Get monster type
                    cmpa      #$46                'F' Venus Flytrap?
                    bne       L3A5C               No, try next
                    ldb       >$10E5              Get player status flags
                    andb      #%01111111          $7F (Mask that we are not trapped, I think?)
                    stb       >$10E5              Save back
                    lbsr      L2AB8
                    bra       L3AAD               Go print that player defeated monster

L3A5C               cmpa      #$4C                'L'eprechaun?
                    bne       L3AAD               No, that was the last special case to check for here
                    stx       >$2325              Save ptr to monster info
                    lbsr      L6162               Get next free inventory entry (max 40)
                    cmpx      #$0000              Inventory full?
                    bne       YesGold             No, go add gold
                    puls      pc,u,y,x,d          Yes, return with no gold

YesGold             lda       #$CB                Gold object type
                    sta       4,x                 Save object type in object block
                    lbsr      L3BD1               Get ???
                    std       <$10,x              Save ??? in object block
                    lda       #3
                    lbsr      L37F4
                    tsta                          ??? Maybe flag that leprechaun stole money, so more will be added?
                    beq       L3A9D
                    lbsr      L3BD1               I think this is getting up to 4x gold for a leprechaun than other monster
                    pshs      d
                    lbsr      L3BD1
                    pshs      d
                    lbsr      L3BD1
                    pshs      d
                    lbsr      L3BD1
                    addd      ,s++
                    addd      ,s++
                    addd      ,s++
                    addd      <$10,x
                    std       <$10,x
L3A9D               pshs      x
                    ldx       >$2325
                    leau      <$1D,x
                    puls      x
                    lbsr      L6138
                    ldx       >$2325
* Report that player defeated monster
L3AAD               leau      4,x
                    leay      ,x
                    lda       #1
                    lbsr      L3937
                    tst       >$2327
                    beq       L3AFA
                    ldu       #$2328              'you have defeated '
                    pshs      u
                    lbsr      L68FD
                    leas      2,s
                    ldx       #$10D8
                    ldd       #$0001
                    lbsr      L3C3C
                    tsta                          ??Is player blinded?
                    beq       L3ADD               No, print type of monster called
                    ldu       #$14A7              'it' - if player blinded, player will have no idea what it was
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    bra       L3AFA

L3ADD               ldx       >$2325              Get ptr to monster object for the monster we just killed
                    lda       7,x                 Get letter of Monster
                    suba      #$41                Convert ASCII to binary
                    ldb       #18                 18 bytes/monster tbl entry
                    mul
                    addd      #$10FB              Point to monster tbl entry for the monster
                    tfr       d,y
                    ldd       ,y                  Get ptr to monster name
                    pshs      d
                    ldu       #$233B              'the %s'
                    pshs      u
                    lbsr      L68D8
                    leas      4,s
L3AFA               lbsr      L33D5
L3AFD               puls      pc,u,y,x,d

* Convert variable length ASCII number to 8 bit binary
* Entry: Y=ptr to ASCII numeric string
* Exit:  A=8 bit binary value
L3AFF               pshs      y,b                 Save regs
                    clr       >$2342              Init result to 0
L3B04               lda       ,y+                 Get value
                    beq       L3B21               NUL, we are done
                    cmpa      #$30                If not ASCII digit 0-9, get value and return
                    blo       L3B21
                    cmpa      #$39
                    bhi       L3B21
                    suba      #$30                Convert ASCII # to binary
                    pshs      a                   Save it
                    lda       >$2342              Get cumulative result until now
                    ldb       #10                 Multiply by 10
                    mul
                    addb      ,s+                 Add to binary #
                    stb       >$2342              Save it back, continue loop
                    bra       L3B04

L3B21               lda       >$2342              Get final result & return
                    puls      pc,y,b

* Get cursor Y position, save copy of it -1
L3B26               pshs      a
                    lda       >$37CE              Get cursor Y position
                    deca                          Drop by 1
                    sta       >$0D8E              Save it & return
                    puls      a,pc

* I think this inits the RND seed? It dumps the process ID #, User #, RTS
* address, some bytes from from just beyond the stack ptr into a 12 byte
* buffer, and then loops through adding the seconds from F$Time to each of
* them.
L3B32               pshs      u,y,x,d
                    ldu       #$0000              ??? No idea; F$ID doesn't use/need U
                    os9       F$ID
                    adda      >$2DE0              Add process ID # to ??? and save it back
                    sta       >$2DE0
                    tfr       y,d                 Move user # to D
                    addd      >$2DE1              Add to ??? and save it back
                    std       >$2DE1
                    ldd       8,s                 Get RTS address?
                    addd      >$2DE3              Add to ???
                    std       >$2DE3              Save it back
                    ldd       10,s                I have no idea???
                    addd      >$2DE5              Add to ??? and save it back
                    std       >$2DE5
                    ldb       #13                 We are going to init 12 byte buffer from $2DE0-$2DEC
                    ldx       #$2DE0
L3B5D               decb
                    beq       L3B6C               If done, restore regs & exit
                    bsr       L3B6E               Get system time seconds into A
                    adda      b,x                 Add that to whatever is in buffer (RND seed, maybe?)
                    sta       b,x                 Save it back
                    lbsr      L6362
                    bra       L3B5D               Keep looping until done

L3B6C               puls      pc,u,y,x,d

* Kick start system time to get multi-tasking going (if needed)
* Also gets current system time seconds field into A on exit
L3B6E               pshs      u,y,x,b
                    ldx       #$2343              Point to time packet
                    os9       F$Time              Set time
                    lda       >$2348              Get seconds from time packet
                    puls      pc,u,y,x,b

L3B7B               pshs      u,y,x,d
                    lbsr      L6D6F
                    clra
                    clrb
                    ldx       #$2362              'Rogue's Name? '
                    lbsr      L6D81
L3B88               lbsr      L632D               Check for keypress
                    tsta                          Was a key pressed?
                    bne       L3B88               No, keep checking
                    ldx       #$2349              Buffer to hold players name
                    lda       #23                 Maximum size allowed
                    lbsr      L6268               Go get player's name
                    lda       >$2349              Get 1st char of name
                    tsta                          Did we get any characters from player?
                    beq       L3BA9               No, exit
                    cmpa      #$1A                <CTRL-Z> (Player ESCaped)?
                    beq       L3BA9               yes, exit
                    ldx       #$14B0              'Rodney' (ptr to destination buffer)
                    ldu       #$2349              Point to the text player typed
                    lbsr      L3FF3               Copy string from U to X & return
L3BA9               puls      pc,u,y,x,d

* 6809/6309 Time delay - should replace with F$Sleep call if possible
* (approx .0225 seconds) - so sleep 2 or 3 ticks. 3 seems closest to original.
*  could speed up to 2 (this affects the asterisks going down levels, pause when
* shooting arrows, darts, etc., monster distant attacks (fire breath, frost, etc.)
L3BAB               pshs      x,b
                    ldx       #3
                    os9       F$Sleep
                    puls      pc,x,b

* Do ABS(A) (I assume for distance calculations?)
* Entry: A=8 bit signed value (could be negative or positive)
* Exit:  A=8 bit positive version of value
L3BB6               tsta
                    bpl       L3BBA
                    nega
L3BBA               rts

* Get map piece type from main full map from X,Y coord (map #2) (u4B84)
* Entry: B=X coord (or size?)
*        A=Y coord (or size?)
L3BBB               pshs      x
                    lbsr      L5AAA               X=offset into 80x22 map
                    lda       >$4B84,x            Get map piece type
                    puls      pc,x

* Get flags byte from flags map based on X,Y coord (map #3) (u5264)
* Entry: B=X coord (or size?)
*        A=Y coord (or size?)
L3BC6               pshs      x
                    lbsr      L5AAA               X=offset into 80x22 map
                    lda       >$5264,x            Get flags byte
                    puls      pc,x

* Get current dungeon level * 10, +
L3BD1               pshs      u
                    clra
                    ldb       >$0D91              D=dungeon level player is on
                    ldu       #10                 *10
                    lbsr      L3CCE               D=D*U
                    addd      #50                 Add 50 more
                    lbsr      L6396
                    addd      #2
                    puls      pc,u

* Check if ring type on left hand matches type in B, and that A value matches
* Entry: A=which hand we are checking (0=left, 1=right)
*        B=sub-object type # (type of ring)
* Exit:  A=0 - ring type we are looking for not on hand we checked
*        A=1 - ring type IS on hand we checked.
L3BE8               pshs      x
                    lsla                          2 bytes/entry
                    ldx       #$0DB3              Object ptr to what is on our hands
                    ldx       a,x                 Get object ptr for appropriate hand
                    beq       L3BFD               None worn on this hand, exit with A=0
                    cmpb      $F,x                Same sub-type as X object block?
                    bne       L3BFD               No, return with A=0
                    lda       #1                  yes, match, so return with A=1
                    puls      pc,x

L3BFD               clra
                    puls      pc,x

* Check to see if player is wearing a certain type of ring
* Entry: A=ring type to check for
* Exit:  A=0 (player not wearing that type of ring), A=1 (player is wearing that ring)
L3C00               pshs      b
                    tfr       a,b                 Move it B
                    clra                          Left hand
                    bsr       L3BE8               Is player wearing that ring on left hand?
                    tsta
                    bne       L3C17               Yes, flag that
                    lda       #1                  No, try right hand
                    bsr       L3BE8
                    tsta
                    bne       L3C17               Yes, flag player has that ring
                    clra                          No, flag player is not wearing that ring
                    puls      pc,b

L3C17               lda       #$01
                    puls      pc,b

* Check A (object) to see if potion, scroll or food. If so, exit with
* A=1, else A=0
* 6809/6309 - should be able to suba #$cc, then deca for other checks
L3C1B               cmpa      #$CE                Potion?
                    beq       L3C29
                    cmpa      #$CD                Scroll?
                    beq       L3C29
                    cmpa      #$CC                Food?
                    beq       L3C29
                    clra
                    rts

L3C29               lda       #$01
                    rts

* 6809/6309 - should be able to suba #$c2, then deca for other checks
* Entry: A=char in 2ndary screen map we are checking
* Exit: A=1 if floor or hallway
*       A=0 if anything else
L3C2C               cmpa      #$C2                Floor?
                    beq       L3C29               Yes, exit with A=1
                    cmpa      #$C3                Hallway?
                    beq       L3C29               Yes, exit with A=1
                    clra                          Anything else, exit with A=0
                    rts

* Entry: D=bits to check if on (16 bits)
* Exit: A=0 - none of the bits were set
*       A=1 - At least one of them was set
L3C3C               pshs      d
                    ldd       12,x
                    anda      ,s+
                    andb      ,s+
                    cmpd      #$0000
                    beq       L3C50
                    lda       #1
L3C50               rts

* Copy A bytes from U to X. 6309 - TFM
L3C51               pshs      u,x,d
L3C53               ldb       ,u+
                    stb       ,x+
                    deca
                    bne       L3C53
                    puls      pc,u,x,d

* MATH ROUTINES FOLLOW: 16X16 DIVIDE, 8X8 DIVIDE, 16X16 MULTIPLY
* 16x16 divide. I think unsigned
* Entry: D=16 bit # to divide by
*        U=16 bit # to divide
* Exit:  U=result
*        D=remainder
L3C5C               pshs      y
                    clr       >$2371              clear 32 bit LONG
                    clr       >$2372
                    clr       >$2373
                    clr       >$2374
                    ldy       #17                 Loop ctr
L3C6E               lsra
                    rorb
                    ror       >$2373
                    ror       >$2374
                    leay      -1,y                Do 17 times, until all non-0 bits shifted in?
                    tstb
                    bne       L3C6E
                    tsta
                    bne       L3C6E
                    tfr       u,d
L3C80               subd      >$2373
                    bcc       L3C8C
                    addd      >$2373
                    andcc     #%11111110          $FE
                    bra       L3C8E

L3C8C               orcc      #%00000001          $01
L3C8E               rol       >$2372
                    rol       >$2371
                    lsr       >$2373
                    ror       >$2374
                    leay      -1,y
                    bne       L3C80
                    ldu       >$2371
                    puls      y,pc

* Unsigned 8 bit divide (A=B/A)
* Entry: B=number to divide
*        A=number to divide by
* Exit:  A=result
*        B=remainder
L3CA4               pshs      y
                    clr       >$2375
                    ldy       #9                  Loop ctr
L3CAD               lsra
                    ror       >$2375
                    leay      -1,y
                    tsta
                    bne       L3CAD
L3CB6               subb      >$2375
                    bcc       L3CC2
                    addb      >$2375
                    andcc     #%11111110          $FE
                    bra       L3CC4

L3CC2               orcc      #%00000001          $01
L3CC4               rola
                    lsr       >$2375
                    leay      -1,y
                    bne       L3CB6
                    puls      pc,y

* 16 x 16 bit multiply
* Entry: D=blessing/curse value * 3
*        U=base value of item
* Exit: D=original D*U (I think)
L3CCE               std       >$2376              Save blessing/curse value
                    stu       >$2378              Save base value
                    clra
                    clrb
L3CD6               tst       >$2377
                    bne       L3CE0
                    tst       >$2376
                    beq       L3CF3
L3CE0               lsr       >$2376              Divide blessing value by 2
                    ror       >$2377
                    bcc       L3CEB               least bit was 0, skip ahead
                    addd      >$2378
L3CEB               lsl       >$2379
                    rol       >$2378
                    bra       L3CD6

* Might be able to move label - if we move jump table below to closer
L3CF3               rts

L3CF4               pshs      x
                    lbsr      L5AAA               X=offset into 80x22 map
                    leau      >$4B84,x            Offset into screen map #2
                    puls      pc,x

L3CFF               pshs      x
                    lbsr      L5AAA               X=offset into 80x22 map
                    leau      >$5264,x            Offset into screen map #3
                    puls      pc,x

* Get ptr to $0DBB table (9 roomb blocks for current dungeon level) for room A
* Entry: A=Room # we want ptr to
* Exit:  X=Ptr to Room block
L3D0A               pshs      d
                    ldb       #34                 34 bytes/room definition
                    mul
                    addd      #$0DBB              Add start of table
                    tfr       d,x
                    puls      d,pc

* Entry: X=ptr to buffer to hold final translated string
* Entry after pshs u,y,x,d:
* 2,s = Ptr to buffer to hold final text message
* 8,s = RTS address
* 10,s = Ptr to original string to print
* 12,s = Ptr to string 'an' or 'a'
*
L3D23               pshs      u,y,x,d
                    ldy       10,s
                    leau      12,s                Point to ptr on stack ('an' or 'a' string ptr)
                    stu       >$2384              Save ptr
L3D2D               lda       ,y+
                    lbeq      L3DDB               If NUL, clear flag and exit
                    cmpa      #$25                % sign?
                    beq       L3D3B               Yes, process
                    sta       ,x+                 Anything else, copy verbatim, keep looping until NUL found
                    bra       L3D2D

* % sign found
L3D3B               pshs      x
                    clr       >$2381
                    clr       >$2383
                    lda       ,y
                    cmpa      #$2D                - sign?
                    bne       L3D4E               Nope, skip ahead
                    inc       >$2381              Yes, set flag
                    leay      1,y                 Bump source string ptr
L3D4E               lbsr      L3DDF
                    sta       >$2382
                    lda       ,y                  Get source string byte
                    cmpa      #$2E                Period '.'?
                    bne       L3D62               No, skip ahead
                    leay      1,y                 yes, bump source string ptr
                    bsr       L3DDF
                    sta       >$2383
L3D62               ldu       #$2386
                    ldx       #$237A              'scudi%' (C parse chars for '%*'?)
                    clrb                          Clear entry #
L3D69               lda       b,x                 Get C parse char from table
                    beq       L3D8E               Done table, skip ahead
                    cmpa      ,y                  Same as one is source buffer?
                    beq       L3D74               Yes, exit with B being parse table entry #
                    incb                          No, bump up parse table entry # and keep checking
                    bra       L3D69

* part of text printing at top (not used for normal map drawing while playing)
* Entry: B=entry # into table (2 bytes/entry) @ L3D17
* This routine replaces two RTS addresses on the stack - one for the subroutine,
* and one for the 'cleanup' routine that all subroutines use (L3D88)
L3D74               leax      <L3D88,pc           Save RTS address to come to after subroutine done
                    pshs      x
                    leax      <L3D17,pc           Point to table
                    ldb       b,x                 Get offset value
                    abx                           Point to subroutine
                    pshs      x                   Save routine address on stack for RTS
                    ldx       >$2384
                    rts                           Return to subroutine calculated above

* This routine always gets called after one of the table functions above. Possibly
*   a cleanup up routine after the printf type handling the subroutines do.
* Entry: D=# of bytes used up from source ptr (0,1,2)
L3D88               addd      >$2384              Add D to string ptr
                    std       >$2384              Save new string ptr
L3D8E               clr       ,u                  Add NUL
                    tst       >$2383
                    beq       L3DA5
                    ldx       #$2386
                    lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    cmpa      >$2383              If <=??, skip ahead
                    bls       L3DA5
                    lda       >$2383              Get 'other' length
                    clr       a,x                 force end of string with NUL at that far into the string
L3DA5               ldx       #$2386
                    lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    pshs      a
                    lda       >$2382
                    suba      ,s+
                    puls      u
                    tst       >$2381
                    bne       L3DBC
                    bsr       L3DF7               Fill buffer @ ,u with spaces for A chars (or NUL found)
L3DBC               pshs      a
                    ldx       #$2386              Source buffer to copy from
                    lda       #127                Max size of buffer to copy
                    lbsr      L3F7B               Copy from X to U, stopping at max size or NUL, whichever comes first
                    puls      a
                    tst       >$2381
                    beq       L3DD0
                    bsr       L3DF7               Fill buffer @ ,u with spaces (till NUL or Size in A reached)
L3DD0               leax      ,u
                    tst       ,y
                    beq       L3DD8
                    leay      1,y
L3DD8               lbra      L3D2D

L3DDB               clr       ,x                  Terminate with NUL & return
                    puls      pc,u,y,x,d

* Entry: A=offset (0-127) into buffer @ >u2411
* Convert value at ($2411+A) from 2 char ASCII to binary
L3DDF               pshs      b
                    clrb
L3DE2               lda       ,y                  Get offset value
                    lbsr      L3F1E               Check if %00000100 bit set at $2411+A
                    tsta
                    beq       L3DF3               Nope, tfr B to A & return
                    lda       #10                 Yep, Make 10s digit, add to value, go do singles digit
                    mul
                    addb      ,y+
                    subb      #$30
                    bra       L3DE2

L3DF3               tfr       b,a
                    puls      pc,b

* Jump table for some special substring functions - called from L3D74.
* This might be C string handling routines?
L3D17               fcb       L3E09-L3D17         Entry 0  ($00f2)  Copy string from [,x] to ,u-stop at 127 chars or NUL
                    fcb       L3E17-L3D17         Entry 1  ($0100)  Copy 1 byte from ,x to ,u
                    fcb       L3E30-L3D17         Entry 2  ($0119)  Convert 16 bit positive number to ASCII equivalent
                    fcb       L3E1F-L3D17         Entry 3  ($0108)  Convert 16 bit signed number to ASCII equivalent
                    fcb       L3E8A-L3D17         Entry 4  ($0173)  Convert 8 bit unsigned number to ASCII equivalent
                    fcb       L3EDA-L3D17         Entry 5  ($01C3)  Add % sign to output buffer @ ,u

* Fill string buffer with spaces, and add NUL to end
* Entry: U=ptr to buffer
*        A=size of string buffer (NOTE: it does come in here with negative #'s at times!
* Exit:  U=ptr to end of buffer (where NUL terminator is)
L3DF7               pshs      d                   Save regs
                    tsta                          0 length string requested?
                    ble       L3E05               Yes, put a NUL in & return
                    ldb       #$20                Space char
L3DFB               stb       ,u+                 Save space in buffer
                    deca                          Keep going until done
                    bne       L3DFB
L3E05               clr       ,u
                    puls      pc,d


* Jump table Entry #0 - Copy string from [,x] to ,u-stop at 127 chars or NUL, whichever is 1st
* Exit: D=2 (bump up dest string ptr by 2 on exit)
L3E09               pshs      x
                    ldx       ,x                  Get ptr to source string
                    lda       #127                Length of 127
                    lbsr      L3F7B               Copy string from X to U, up to 127 bytes max or NUL encountered
                    ldd       #2                  ??? Bump string ptr up by 2 on return?
                    puls      pc,x

* Jump table Entry #1 - copy byte from X into U buffer
* Entry: X=src buffer (1 char)
*        U=Dest buffer ptr
* Exit:  D=Bump up dest string ptr by 1 on exit?
*        U updated
L3E17               lda       ,x
                    sta       ,u+
                    ldd       #1                  ??? Bump string ptr up by 1 on return?
                    rts

* Jump table Entry #3 - convert 16 bit ABS of value @ ,x to ASCII equivalent with NUL terminator
* X=ptr to 16 bit value we need to print in ASCII
* U=Ptr to Output buffer to append ASCII digits to (also adds '-' if negative)
L3E1F               ldd       ,x                  Get 16 bit #
                    bpl       L3E30               If positive, go straight to translating # to ASCII
                    lda       #$2D                If negative, add '-' to output buffer
                    sta       ,u+
                    ldd       #$0000              Negate 16 bit value @ ,x (Force to positive)
                    subd      ,x
                    std       ,x
* Jump table Entry #2 - convert 16 bit unsigned value @ ,x to ASCII equivalent with NUL terminator
L3E30               pshs      y,x
                    pshs      u                   Save output string buffer ptr
                    ldd       #10000              Divide by 10000 (start with 10,000ths digit)
                    std       >$240D              Save as divisor
                    ldy       #$2406              Ptr to buffer to hold ASCII #'s
                    ldd       ,x                  Get 16 bit value we are converting to ASCII
                    bne       L3E48               If not 0, go convert
                    lda       #'0                 $30 If 0, save a 0 in ASCII buffer
                    sta       ,y+
L3E79               clr       ,y                  Done converting, add a NUL
                    puls      u                   Get output string buffer ptr back
                    ldx       #$2406              Point to ASCII numeric conversion buffer
                    lda       #6                  Max # of chars to copy
                    lbsr      L3F7B               Copy (up to) 6 chars over from numeric ASCII conversion to output string buffer
                    ldd       #2                  ??? Bump string ptr up by 2 on return?
                    puls      pc,y,x

L3E48               clr       >$240C              Clear ctr
L3E4B               ldd       >$240D              Get # to divide by (either 10000 or 10)
                    beq       L3E79               If 0, skip (/0 error otherwise)
                    ldu       ,x                  Get # to divide into
                    lbsr      L3C5C               U=U/D (remainder in D)
                    cmpu      #$0000              Is the result 0?
                    bne       L3E60               No, skip ahead
                    tst       >$240C              Any chars in buffer already?
                    beq       L3E6B               No, skip ahead
L3E60               std       ,x                  Save remainder
                    tfr       u,d                 Move result of division to B (A not used)
                    addb      #'0                 $30 ASCII-fy it
                    stb       ,y+                 Save in dest buffer
                    inc       >$240C              Inc ctr (how many ASCII chars in output buffer?)
L3E6B               ldu       >$240D              Get ??? (number to divide into)
                    ldd       #10                 Divide by 10
                    lbsr      L3C5C               U=U/D (remainder in D)
                    stu       >$240D              Save new result overtop original #
                    bra       L3E4B

* Jump table Entry #4         Convert 8 bit unsigned # to ASCII, append to string buffer
L3E8A               pshs      y,x
                    ldy       #$2406              Point to ASCII conversion string buffer
                    lda       ,x                  Get binary digit @ X
                    bne       L3E9A               If <>0, skip ahead
                    lda       #'0                 $30 If 0, add ASCII zero
                    sta       ,y+
                    bra       L3ECB

L3E9A               clr       >$240F              Clear ctr of # of digits
                    lda       #100                Start with 100's digit
                    sta       >$2410              Save divisor
L3EA2               lda       >$2410              Get divisor
                    beq       L3ECB               If 0, we are done
                    ldb       ,x                  Get binary value
                    lbsr      L3CA4               B/A
                    tsta                          Result<>0?
                    bne       L3EB5               yes, skip ahead
                    tst       >$240F              Had any digits before?
                    beq       L3EBE               No, skip ahead
L3EB5               stb       ,x                  Save remainder
                    adda      #'0                 $30 ASCII-fy result
                    sta       ,y+                 Save in ASCII string buffer
                    inc       >$240F              Inc # of ASCII digits
L3EBE               ldb       >$2410              Get divisor
                    lda       #10                 divide by 10 (drop to next decimal digit)
                    lbsr      L3CA4               B/A
                    sta       >$2410              Save result and continue until we have done all 3 digits needed for 8 bit
                    bra       L3EA2

L3ECB               clr       ,y                  Add NUL to terminate string
                    ldx       #$2406              Point to ASCII conversion string buffer
                    lda       #6                  Max of 6 chars (including NUL)
                    lbsr      L3F7B               Copy to main output string buffer
                    ldd       #1                  # of bytes we we processed from src ptr?
                    puls      pc,y,x

* Jump table Entry #5 - append % sign to output buffer
L3EDA               lda       #'%                 $25 % sign
                    sta       ,u+
                    ldd       #$0000              # of bytes used from source string
                    rts

* Check entry A in table @ $2411 for bits 1-2 being set
* Entry: A=entry # to check
* Exit:  A=1 if bits set, A=0 if not
L3EE2               tsta
                    bpl       L3EE7
                    clra
                    rts

L3EE7               pshs      x
                    ldx       #$2411
                    lda       a,x
                    anda      #%00000011          $03
                    beq       L3EF4
                    lda       #1
L3EF4               puls      pc,x

* Check entry A in table @ $2411 for bit 1 being set
* Entry: A=entry # to check
* Exit:  A=1 if bit set, A=0 if not
L3EF6               tsta
                    bpl       L3EFB
                    clra
                    rts

L3EFB               pshs      x
                    ldx       #$2411
                    lda       a,x
                    anda      #%00000001          $01
                    beq       L3F08
                    lda       #1
L3F08               puls      pc,x

* Check entry A in table @ $2411 for bit 2 being set
* Entry: A=entry # to check
* Exit:  A=1 if bit set, A=0 if not
L3F0A               tsta
                    bpl       L3F0F
                    clra
                    rts

L3F0F               pshs      x
                    ldx       #$2411
                    lda       a,x
                    anda      #%00000010          $02
                    beq       L3F1C
                    lda       #1
L3F1C               puls      pc,x

* Check entry A in table @ $2411 for bit 3 being set
* Entry: A=entry # to check
* Exit:  A=1 if bit set, A=0 if not
L3F1E               tsta
                    bpl       L3F23
                    clra
                    rts

L3F23               pshs      x
                    ldx       #$2411
                    lda       a,x
                    anda      #%00000100          $04
                    beq       L3F30
                    lda       #1
L3F30               puls      pc,x

* Check entry A in table @ $2411 for bit 4 being set
* Entry: A=entry # to check
* Exit:  A=1 if bit set, A=0 if not
L3F32               tsta
                    bpl       L3F37
                    clra
                    rts

L3F37               pshs      x
                    ldx       #$2411
                    lda       a,x
                    anda      #%00010000          $10
                    beq       L3F44
                    lda       #1
L3F44               puls      pc,x

* Check entry A in table @ $2411 for bits 1-4 being set
* Entry: A=entry # to check
* Exit:  A=1 if bit set, A=0 if not
L3F46               tsta
                    bpl       L3F4B
                    clra
                    rts

L3F4B               pshs      x
                    ldx       #$2411
                    lda       a,x
                    anda      #%00001111          $0F
                    beq       L3F58
                    lda       #1
L3F58               puls      pc,x

L3F5D               pshs      a                   Save entry #
                    bsr       L3F0A               See if bit 2 at $2411+A is set
                    tsta
                    beq       L3F6A               Nope, exit with A=0
                    puls      a
                    suba      #$20                Subtract 32 from entry #?
                    rts

L3F6A               puls      pc,a

L3F6C               pshs      a
                    bsr       L3EF6               See if bit 1 at $2411+A is set
                    tsta
                    beq       L3F6A               Nope, exit with A=0
                    puls      a
                    adda      #$20                Add 20 to entry #
                    rts

* Copy string from ,x to ,u, up to A characters or NUL is encountered
* Entry: A=max # of chars to copy
*        X=ptr to source string
*        U=ptr to dest string
L3F7B               pshs      x,d
                    tsta                          0 bytes to copy?
                    beq       L3F89               Yes, save NUL as 1st char & exit
L3F7D               ldb       ,x+                 Get byte from source string
                    beq       L3F89               If NUL, store it (and do NOT inc U)
                    stb       ,u+                 Save it in destination
                    deca                          Are we one maximum length allowed?
                    bne       L3F7D               No, keep copying
L3F89               clr       ,u                  Terminate dest string with NUL
                    puls      pc,x,d

L3F8D               pshs      x,a
L3F8F               lda       ,x                  Get entry # into tbl @ $2411 to cehck
                    beq       L3F9A               No entry, return
                    bsr       L3F6C               Got check if bit 1 is set
                    sta       ,x+                 If it was, save that+$20 (x or y coord with OS9 offset, maybe?)
                    bra       L3F8F

L3F9A               puls      pc,x,a

* Entry: X=ptr to ASCII numeric string (only used in debug mode, to create gold, I think)
* Exit   D=value of ASCII string in binary
L3F9C               pshs      x
                    ldd       #$0000              Init value to 0
                    std       >$2491
L3FA4               lda       ,x+                 Get character
                    tsta                          End of string, skip ahead
                    beq       L3FC8
                    cmpa      #'0                 If non-numeric, skip ahead
                    blo       L3FC8
                    cmpa      #'9
                    bhi       L3FC8
                    suba      #'0                 $30 Numeric; convert ASCII to binary
                    clrb
                    exg       a,b                 D=binary value
                    pshs      d                   Save on stack
                    ldu       >$2491              Multiply stored value by 10
                    ldd       #10
                    lbsr      L3CCE               D=D*U
                    addd      ,s++                Add to value we have on stack
                    std       >$2491              Save it back
                    bra       L3FA4               Keep going until NUL or non-numeric

L3FC8               ldd       >$2491              Get final binary value & return
                    puls      pc,x

* Compare two strings
* Entry: U=Ptr to string 1
*        X=Ptr to string 2
* Exit: A=0 - both strings match
*       A=1 - String 2>String 1
*       A=$FF - String 2<String 1
L3FCD               pshs      u,x
L3FCF               lda       ,x+
                    cmpa      ,u+
                    bhi       L3FDC
                    blo       L3FE0
                    tsta
                    bne       L3FCF
L3FE4               puls      pc,u,x              Exit with A=0

L3FDC               lda       #$01
                    puls      pc,u,x

L3FE0               lda       #$FF
                    puls      pc,u,x


* Get length of string pointed to by X (NUL terminated). Up to 255 length max.
* 6809/6309 - Should be able to change to tst a,x (faster for 6809). Could speed up
* further by pshs/puls b as well, and do ldb a,x vs. tst (saves 1 or 2 cycles/compare, but
*  slows down pshs/puls by 2 cycles)
L3FE7               pshs      b,x
                    clra
L3FEA               ldb       a,x
                    beq       L3FF1
                    inca
                    bra       L3FEA

L3FF1               puls      pc,x,b

* Copy string from U to X (stop on NUL)
L3FF3               pshs      u,x,a
L3FF5               lda       ,u+
                    sta       ,x+
                    bne       L3FF5
                    puls      pc,u,x,a

* Append string in U to string in X (stop on NUL)
L3FFD               pshs      u,x
L3FFF               lda       ,x+
                    bne       L3FFF
                    leax      -1,x
L4005               lda       ,u+
                    sta       ,x+
                    bne       L4005
                    puls      pc,u,x

* Advance in string until space or NUL encountered. Only called for command line option parsing.
* Exit: X=end of string+1
L400D               pshs      a
L400F               lda       ,x
                    beq       L401B
                    cmpa      #$20
                    bne       L401B
                    leax      1,x
                    bra       L400F

L401B               puls      pc,a

* Duplicate value in D into [x] U times. Only called once to initialize something related
*  to map from L1841. Faster init but must be even byte size
* Entry: U=ptr of where to copy to
*        D=16 bit value to duplicate
*        X=# of duplicates
L401D               pshs      u,x
L401F               std       ,u++
                    leax      -1,x
                    bne       L401F
                    puls      pc,u,x

* Clear out U bytes @ X with value in A (6309 TFM). Slower init but will work on odd sizes.
L402B               pshs      u,x
L402D               sta       ,x+
                    leau      -1,u
                    cmpu      #$0000
                    bne       L402D
                    puls      pc,u,x

* Some sort of sound generation routine. Used for illegal typing, traps, etc.
* 6809/6309 - SHOULD REPLACE WITH SS.TONE CALL, INSTEAD OF HARD CODED
* DAC MANIPULATION.
L4039
                    ifne      coco3
                    pshs      u,y,x,d
                    ldy       #80                 80 loops of toggling 6 bit DAC between 63 & 15
L403F               lda       #%00111111          63 for 6 bit DAC
                    bsr       L4057               Update PIA
                    ldb       #90                 Time delay ctr
L4045               decb
                    bne       L4045               Delay 540 cycles
                    lda       #%00001111          15 for 6 bit DAC
                    bsr       L4057               Update PIA
                    ldb       #90                 Save time delay as before
L404E               decb
                    bne       L404E
                    leay      -1,y                Keep doing DAC toggles until done.
                    bne       L403F
                    puls      pc,u,y,x,d

* Entry: A=6 bit DAC value
* Exit: DAC updated, RS-232 bit forced on.
L4057               lsla                          Shift 0-63 value to high 6 bits for DAC
                    lsla
                    ora       #%00000010          $02 Also turn on RS-232 bit on PIA (debug?)
                    sta       >$FF20              Save to PIA & return
                    endc
                    rts

* Main program start (after allocating 24k RAM, loading Gfx font (if on gfx window)
* If we add -f=hh font option here, will need to change calling routines to hold off
* on gfx font selection (or redo it here with user specified - which may be better option)
L405F               lbsr      L63DD               Get screen size, etc.
                    lbsr      L0403               Print Rogue title screen
                    ldx       #$0023              'rogue.opt'
                    lbsr      L01F8               Go read 120 bytes of rogue.opt file to $14B0
                    ldx       #$1528              Point to command line arguments
                    lda       ,x                  Get 1st char
                    cmpa      #'-                 $2D  Is it a dash? (option)
                    bne       L409A               Nope, see if restore game filename present
L4074               leax      1,x                 If dash, get next char (option)
                    lda       ,x
                    beq       L40A0               NUL, skip ahead
                    cmpa      #$20                Space?
                    bne       L4083               No, check next char
                    bsr       L400D               Anything else, scan until SPACE or NUL found
                    bra       L409A               Check for saved game filename

L4083               cmpa      #$78                'x'? (chained, instead of forked)
                    bne       L408E               No, unknown command line argument
* 6809/6309 NOTE: INSERT FONT OVERRIDE CHECK HERE - CHECK FOR F=hh
                    lda       #$01                Yes, set flag
                    sta       >$14AF
                    bra       L4074

L408E               lbsr      L6D6F
                    ldu       #$2493              'rogue: unknown command line argument.'
                    pshs      u
                    lbsr      L4186               Exit Rogue
* SWI testing trap - should never get here
                    swi

L409A               tst       ,x                  check next parm character (non-dash option)
                    bne       L410A               Something there, check for restore game filename

* Set up new game
L40A0               lda       #1                  No command line options at all, set up new game. A=1 means init viewable player map
                    lbsr      L6405               Go init X,Y vars for various things, clear viewable player map
                    lbsr      L3B7B               Get player's name
                    lbsr      L3B32               ? I think init RND seed
                    lbsr      L9B6C               Generate gibberish names for scrolls
                    lbsr      L9B09               Assign initial potion names (picks 14 from 25)
                    lbsr      L9C3B               Assign initial ring names (picks 15 from 26)
                    lbsr      L9CB9               Assign initial wand/staff names (picks wand or staff, and picks 14 of 20)
                    lbsr      L9D77               Init experience points required per rank table
                    lbsr      L96A1               Set up player's initial inventory
                    lbsr      L3B26               Copy current cursor Y position to D8E from 37CE
                    lbsr      L182A               Init some player flags, and screen maps
                    ldu       #L5EE7+PrgOffst-$1B2 (#$BD35) Address for '.' rest command
                    clra
                    clrb
                    lbsr      L5E48               Add 6 byte packet (U, D, $FFFF) to tbl @ $2C24
                    ldu       #L5F6B+PrgOffst-$1B2 (#$BDB9) - Address for routine that adds L5F77/D=0 to tbl
                    clra
                    clrb
                    ldy       #$0046
                    lbsr      L5870
                    lbsr      L5E82
                    ldu       #L604D+PrgOffst-$1B2 (#$BE9B)
                    clra
                    clrb
                    lbsr      L5E48
                    ldu       #L223F+PrgOffst-$1B2 (#$808D)
                    clra
                    clrb
                    lbsr      L5E48
                    ldu       #$14B0              'Rodney'
                    pshs      u
                    ldu       #$24B9              'Hello %s.  Welcome to the Dungeons of Doom.'
                    pshs      u
                    lbsr      L68D8
                    leas      4,s
                    ldd       >$10DC              Get some X/Y coords
                    std       >$0DAD              Save copies
                    ldu       #$10DC
                    lbsr      L281F               Get ptr into tbl @ $EED into U based on some x,y coords
                    stu       >$0DB9              Save ptr to tbl entry (or 0)
                    bra       L4113

* Check for restore game filename
L410A               lbsr      L0339               Prompt 'insert disk with saved game'
                    lbsr      L3B26               Get >$37CE, dec by 1, save to >$0D8E
L4113               bsr       L418E
                    bra       L4113

* Player requested 'Q'uit command
L4118               pshs      x,d
                    clr       >$0D94              Clear # of command repeats
                    clra                          Cursor x,y=0,0
                    clrb
                    lbsr      L6CDE               CurXY to b,a
                    lbsr      L6D78               Clear to end of line
                    lbsr      L6CDE               CurXY to b,a
                    ldx       #$24E5              'Do you wish to end your quest now (Yes/No) ?'
                    lda       >$37CB              Get window width
                    cmpa      #45
                    bhs       L4135
                    ldx       #$2512              If window width <45, use 'Quit (Yes/No)?' instead
L4135               lbsr      L6D07               Write prompt to screen
                    clra
                    lbsr      L5088
                    lbsr      L61C2
                    cmpa      #$79                'y'?
                    beq       L4147               Yes, go quit
                    cmpa      #$59                'Y'
                    bne       L4170               No, skip ahead
L4147               lbsr      L6D6F
                    clra
                    clrb
                    lbsr      L6CDE               CurXY to b,a (0,0)
                    ldu       >$0D92
                    pshs      u
                    ldu       #$2522              'You quit with %u gold pieces<LF>'
                    pshs      u
                    lbsr      L6D16
                    leas      4,s
                    ldu       >$0D92
                    lda       #$01
                    clrb
                    lbsr      L0434
                    ldu       #$1470
                    pshs      u
                    bsr       L4186
* SWI testing trap - should never get here
                    swi

L4170               clra
                    clrb
                    lbsr      L6CDE               CurXY to b,a (0,0)
                    lbsr      L6D78               Clear to end of line
                    lbsr      L6AA2               Print status line @ bottom (Level, Hits, etc.) approp. for scrn width
                    clr       >$0D94
                    clr       >$0D9E              clear # of repeats for command
                    lbsr      L43D1
                    puls      pc,x,d

L4186               leas      2,s
                    lbsr      L6D16
                    lbra      L0195               Exit rogue, I think

L418E               pshs      u,y,x,d
                    ldx       #$10D8              Point to ???
                    ldd       #%0100000000000000  $4000 16 bit mask to AND with 12,x in subroutine
                    lbsr      L3C3C               See if bit 15 is set at 12,x
                    beq       L419F               Nope, save $01 to >$2545
                    lda       #$02                Yes, save $02 to >$2545
                    bra       L41A1

L419F               lda       #$01
L41A1               sta       >$2545
L41A4               tst       >$2545
                    beq       L41DB
                    dec       >$2545
                    lbsr      L6AA2               Display bottom status line(s) (minus command repeat counter)
                    lbsr      L622D               Check for key, amongst other things
                    lda       >$0D98              Get # of turns until player is unfrozen
                    beq       L41CA               Player not frozen, skip ahead
                    deca                          Drop count by 1 and save back
                    sta       >$0D98
                    tsta
                    bne       L41CD               Player still frozen, skip ahead
                    ldu       #$2548              'you can move again'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    bra       L41CD

L41CA               lbsr      L43FE               Check for movement keys
L41CD               ldu       >$0DB3              Get ptr to object block for ring on left hand
                    bsr       L41E3
                    ldu       >$0DB5              Get ptr to object block for ring on left hand
                    bsr       L41E3
                    bra       L41A4               Branch back up to routine

L41DB               lbsr      L5EB2
                    lbsr      L5E58
                    puls      pc,u,y,x,d

* Entry: U=ptr to ring object block on current hand (zero flag already set from LDU calling here)
*L41E3    cmpu  #$0000         Ring on current hand being checked?
L41E3               beq       L4204               If not ring on current hand, return
                    lda       $F,u                Get sub-type of ring
                    cmpa      #3                  Ring of searching?
                    bne       L41F4               No, check next
                    lbra      L5B05               Do special checking with ring of searching & return from there

L41F4               cmpa      #$0B                Ring of Teleportation?
                    bne       L4204               No, return
                    lda       #50                 RND(50)
                    lbsr      L63A9
                    cmpa      #17                 If <>17, return
                    bne       L4204
                    lbra      L49CC               Randomly teleport the player, return from there

L4204               rts

L4205               pshs      u,b
                    lbsr      L61C2
                    cmpa      #$08                Left arrow key?
                    bne       L4213               No, check next
                    lda       #$68                left arrow is same as 'h' key
                    bra       L4222               Skip ahead

L4213               cmpa      #$2B                '+' key?
                    bne       L421C               No, try next
                    lda       #$74                Same as 't' throw key
                    bra       L4222

L421C               cmpa      #$2D                '-' key?
                    bne       L4222               No, that's all the special ones we are checking
                    lda       #$7A                Yes, same as 'z' zap key
L4222               tst       >$0D94
                    beq       L4236
                    tst       >$063C
                    bne       L4236
                    ldu       #$1470
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
L4236               puls      pc,u,b

L4238               pshs      x,b
                    lda       #$01
                    sta       >$05FC
                    lda       >$1527
                    sta       >$063A
                    lda       #$01
                    lbsr      L5088
                    tst       >$063C
                    bne       L4252
                    clr       >$0639
L4252               lda       #$01
                    sta       >$2543
                    clr       >$05FD
                    lda       >$0D9E              Get # of repeats for command
                    beq       L4279               If 0, skip ahead
                    dec       >$0D9E              Drop # of repeats left by 1
                    beq       L4276
                    lda       >$2544
                    sta       >$2543              Save flag to go over object without picking it up
                    lda       >$2542
                    sta       >$255B
                    clr       >$063A
                    lbra      L4312

L4276               lbsr      L43D1
L4279               tst       >$063C
                    beq       L428D
                    lda       >$0641              Get keypress
                    sta       >$255B              Save
                    lda       >$2544
                    sta       >$2543
                    bra       L4312

L428D               clr       >$255B              Clear copy of keypress
L4290               tst       >$255B              Is there a copy of keypress (what command to repeat)
                    bne       L4312               Yes, skip ahead
                    lbsr      L4205               Check for keypress, amongst other things
                    cmpa      #$30                Check if numeric
                    blo       L42B9               No, skip ahead
                    cmpa      #$39
                    bhi       L42B9
                    suba      #$30                Convert ASCII digit to binary
                    pshs      a                   Save it
                    lda       >$0D9E              ? Get upper digit
                    ldb       #10                 * 10
                    mul
                    addb      ,s+                 Add to 1's digit
                    cmpb      #100                If >100 skip ahead
                    bhs       L42B3
                    stb       >$0D9E              Otherwise save new value
L42B3               lbsr      L43D1
                    bra       L4290

L42B9               cmpa      #$66                lowercase f (1 shot Fast mode)
                    bne       L42C3
                    com       >$063A              Toggle fast mode for next command
                    bra       L4290               Back to check for keypress (or repeat command)

L42C3               cmpa      #$46                Uppercase F? (Toggle full fast mode)
                    bne       L42D3
                    com       >$1527              Toggle Full fast mode
                    com       >$063A              Toggle fast mode for next command
                    lbsr      L6AA2
                    bra       L4290

L42D3               cmpa      #$67                'g'o over command (go over object without picking it up)
                    bne       L42DD               No, try next
                    clr       >$2543              Set flag that we will go over object without picking it up
                    bra       L4290

L42DD               cmpa      #$61                lowercase a (repeat last command)?
                    bne       L42F5
                    lda       >$2542              Get last command key
                    sta       >$255B              Copy to command key copy
                    lda       >$2544              Get copy of flag to go over objects (copy for repeat commands)
                    sta       >$2543              Save for current commmand
                    lda       #$01
                    sta       >$05FD
                    bra       L4290

L42F5               cmpa      #$1A                <CTRL-Z> (abort)
                    bne       L4305               No, try next
                    clr       >$0639
                    clr       >$0D9E              Abort clears out repeat commmand ctr to 0
                    lbsr      L43D1
                    bra       L4290

L4305               cmpa      #$20                ? Space? (Does nothing, and does not take a turn)
                    beq       L4290
L430C               sta       >$255B
L430F               bra       L4290

L4312               tst       >$0D9E
                    beq       L431A
                    clr       >$063A              Clear fast mode flag
* Check for player movement keys
L431A               lda       >$255B              Get keypress ASCII code
* Single movement keys (lowercase)
                    cmpa      #$68                h key? (left)
                    beq       L433F
                    cmpa      #$6A                j key? (down)
                    beq       L433F
                    cmpa      #$6B                k key? (up)
                    beq       L433F
                    cmpa      #$6C                l key? (right)
                    beq       L433F
                    cmpa      #$79                y key? (up/left)
                    beq       L433F
                    cmpa      #$75                u key? (up/right)
                    beq       L433F
                    cmpa      #$62                b key? (down/left)
                    beq       L433F
                    cmpa      #$6E                n key? (down/right)
                    bne       L4369               Not a single step directional key, skip ahead
* Player single step movement key found
L433F               tst       >$063A              Fast mode enabled?
                    beq       L43AD               No, skip ahead
                    tst       >$063C
                    bne       L43AD
                    ldx       #$10D8
                    ldd       #$0001
                    lbsr      L3C3C
                    tsta
                    bne       L435D
                    lda       #$01
                    sta       >$0639
                    sta       >$063B
L435D               lda       >$255B              Get copy of keypress (for repeat commands)
                    lbsr      L3F5D
                    sta       >$255B              Save copy of keypress (for repeat commands)
                    bra       L43AD

* check for fast mode directional keys (uppercase)
L4369               cmpa      #$48                H key? (left)
                    beq       L43AD
                    cmpa      #$4A                J key? (down)
                    beq       L43AD
                    cmpa      #$4B                K key? (up)
                    beq       L43AD
                    cmpa      #$4C                L key? (right)
                    beq       L43AD
                    cmpa      #$59                Y key? (up/left)
                    beq       L43AD
                    cmpa      #$55                U key? (up/right)
                    beq       L43AD
                    cmpa      #$42                B key? (down/left)
                    beq       L43AD
                    cmpa      #$4E                N key? (down/right)
                    beq       L43AD
* Check some other legal keys
                    cmpa      #$71                q key? (quaff)
                    beq       L43AD
                    cmpa      #$72                r key? (read)
                    beq       L43AD
                    cmpa      #$73                s key? (search)
                    beq       L43AD
                    cmpa      #$7A                z key? (zap)
                    beq       L43AD
                    cmpa      #$74                t key? (throw)
                    beq       L43AD
                    cmpa      #$2E                . key? (rest)
                    beq       L43AD
                    cmpa      #$43                C key? (Call)
                    beq       L43AD
L43AA               clr       >$0D9E              Clear # of repeats
L43AD               tst       >$0D9E              Do we have # of repeats?
                    bne       L43B7               Yes, skip ahead
                    tst       >$2540
                    beq       L43BA
L43B7               bsr       L43D1               Display # of commmand repeats left, in lower right corner of window
L43BA               lda       >$255B              Get copy of keypress (to repeat)
                    sta       >$2542              Save where single repeat ('a) command is.
                    lda       >$0D9E              Get # of repeats
                    sta       >$2540              Save copy
                    lda       >$2543              Get 'go over objects w/o picking them up' flag
                    sta       >$2544              Save copy
                    lda       >$255B              Get copy of keypress to repeat
                    puls      pc,x,b

* This displays the # of repeats to do for a command (displayed in lower right corner)
L43D1               pshs      u,y,x,d
                    lda       >$37CE              Get Y coord
                    ldb       >$37CD              Get X coord
                    subb      #$02                We want to the left of that (so prints at right side of window)
                    lbsr      L6CDE               CurXY to b,a
                    tst       >$0D9E              Is the # of repeats >0?
                    beq       L43F6               No, print 2 spaces
                    ldb       >$0D9E              Yes, get repeat count
                    clra                          Put into D for routine
                    pshs      d
                    ldu       #$255C              '%2d' (print formatting for 2 digits)
                    pshs      u
                    lbsr      L6D16               Print repeat count
                    leas      4,s
                    puls      pc,u,y,x,d

L43F6               ldx       #$2560              '  '
                    lbsr      L6D07               Write out string @ X (NUL terminated)
                    puls      pc,u,y,x,d

L43FE               pshs      u,y,x,d
L4400               lbsr      L4238
                    cmpa      #$68                h key (left)
                    beq       L4425
                    cmpa      #$6A                j key (down)
                    beq       L4425
                    cmpa      #$6B                l key (right)
                    beq       L4425
                    cmpa      #$6C                m key (up)
                    beq       L4425
                    cmpa      #$79                y key (up/left)
                    beq       L4425
                    cmpa      #$75                u key (up/right)
                    beq       L4425
                    cmpa      #$62                b key (down/left)
                    beq       L4425
                    cmpa      #$6E                n key (down/right)
                    bne       L4437               No, skip ahead
L4425               ldx       #$2563
                    lbsr      L57B5
                    lda       >$2564
                    ldb       >$2563
                    lbsr      L1BBE
                    lbra      L4689

L4437               cmpa      #$48                H key (left)
                    beq       L4459
                    cmpa      #$4A                J key (down)
                    beq       L4459
                    cmpa      #$4B                L key (right)
                    beq       L4459
                    cmpa      #$4C                M key (up)
                    beq       L4459
                    cmpa      #$59                Y key (up/left)
                    beq       L4459
                    cmpa      #$55                U key (up/right)
                    beq       L4459
                    cmpa      #$42                B key (down/left)
                    beq       L4459
                    cmpa      #$4E                N key (down/right)
                    bne       L4462               No, skip ahead
L4459               lbsr      L3F6C
                    lbsr      L1BAF
                    lbra      L4689

L4462               cmpa      #$74                t key (throw)
                    bne       L447D
                    lbsr      L5749               Go get direction to throw, etc.
                    tsta
                    beq       L4477
                    lda       >$0DB0
                    ldb       >$0DAF
                    lbsr      L8745
                    bra       L447A

L4477               clr       >$05FC
L447A               lbra      L4689

L447D               cmpa      #$51                Q key (Quit)
                    bne       L448A
                    clr       >$05FC
                    lbsr      L4118
                    lbra      L4689

L448A               cmpa      #$69                i key (inventory)
                    bne       L449E
                    clra
                    sta       >$05FC
                    ldx       >$10F5
                    ldu       #$1470
                    lbsr      L7037
                    lbra      L4689

L449E               cmpa      #$64                d key (drop)
                    bne       L44A8
                    lbsr      L76F6
                    lbra      L4689

L44A8               cmpa      #$71                q key (quaff)
                    bne       L44B2
                    lbsr      L8FB1
                    lbra      L4689

L44B2               cmpa      #$72                r key (read)
                    bne       L44BC
                    lbsr      L8B05
                    lbra      L4689

L44BC               cmpa      #$65                e key (eat)
                    bne       L44C6
                    lbsr      L54FF
                    lbra      L4689

L44C6               cmpa      #$77                w key (wield)
                    bne       L44D0
                    lbsr      L8A00
                    lbra      L4689

L44D0               cmpa      #$57                W key (Wear)
                    bne       L44DA
                    lbsr      L86B0
                    lbra      L4689

L44DA               cmpa      #$54                T key (Take off)
                    bne       L44E4
                    lbsr      L8706
                    lbra      L4689

L44E4               cmpa      #$50                P key (Put on)
                    bne       L44EE
                    lbsr      L94E3
                    lbra      L4689

L44EE               cmpa      #$52                R key (Remove)
                    bne       L44F8
                    lbsr      L9573
                    lbra      L4689

L44F8               cmpa      #$63                c key (call) (rename)
                    bne       L4505
                    clr       >$05FC
                    lbsr      L5C6D
                    lbra      L4689

L4505               cmpa      #$3E                > key (downstairs)
                    bne       L4512
                    clr       >$05FC
                    lbsr      L5C04
                    lbra      L4689

L4512               cmpa      #$3C                < key (upstairs)
                    bne       L451F
                    clr       >$05FC
                    lbsr      L5C27
                    lbra      L4689

L451F               cmpa      #$2F                / key (list symbols)
                    bne       L453D
                    clr       >$05FC
                    tst       >$3571              ? Are we in gfx mode with rogue font?
                    bne       L4534               Yes, use gfx version of symbols help screen
                    ldx       #$0037              'rogue.chr'
                    lbsr      L59C9               Go print it to screen
                    lbra      L4689

L4534               ldx       #$0041              'rogue.grf' (use gfx version of symbols help screen)
                    lbsr      L59C9               Go print it to screen
                    lbra      L4689

L453D               cmpa      #$3F                ? key (list help)
                    bne       L454D
                    clr       >$05FC
                    ldx       #$002D              'rogue.hlp'
                    lbsr      L59C9
                    lbra      L4689

L454D               cmpa      #$73                s key (search)
                    bne       L4557
                    lbsr      L5B05
                    lbra      L4689

L4557               cmpa      #$7A                z key (zap)
                    bne       L456C
                    lbsr      L5749
                    tsta
                    beq       L4566
                    lbsr      L7D91               Process Zap command
                    bra       L4569

L4566               clr       >$05FC
L4569               lbra      L4689

L456C               cmpa      #$44                D key (Discovered items list)
                    bne       L4579
                    clr       >$05FC
                    lbsr      L79F3
                    lbra      L4689

L4579               cmpa      #$4D                M key (Macro define)
                    bne       L4589
                    clr       >$05FC
                    ldx       #$14E2              'v' (default macro is 'v'ersion command)
                    lbsr      L5DB6
                    lbra      L4689

L4589               cmpa      #$6D                m key (macro execute)
                    bne       L4599
                    clr       >$05FC
                    ldd       #$14E2              'v' (default macro is 'v'ersion command)
                    std       >$1471
                    lbra      L4689

L4599               cmpa      #$12                <CTRL-R> key (repeat last message)
                    bne       L45AD
                    clr       >$05FC
                    ldu       #$0D0E
                    pshs      u
                    lbsr      L68D8               Print out the last message
                    leas      2,s
                    lbra      L4689

L45AD               cmpa      #$76                v key (version)
                    bne       L45E9
                    clr       >$05FC
                    ldx       #$14B0              'Rodney'
                    ldu       #$2565              'The Grand Beeking'
                    lbsr      L3FCD               Compare the two strings
                    tsta
                    bne       L45CF
                    ldu       #$002A
                    pshs      u
                    ldu       #$2577              '(%d) that's not your name!'
                    pshs      u
                    lbsr      L68D8
                    leas      4,s
L45CF               lda       >$0021
                    pshs      a
                    lda       >$0020
                    pshs      a
                    ldu       #$2592              'Rogue version %i.%i (mll and rbm)'
                    pshs      u
                    lbsr      L68D8
                    leas      4,s
                    lbsr      L4C94
                    lbra      L4689

L45E9               cmpa      #$53                S key (Save game)
                    bne       L45F6
                    clr       >$05FC
                    lbsr      L0212
                    lbra      L4689

L45F6               cmpa      #$2E                . key (rest)
                    bne       L4600
                    lbsr      L5EE7
                    lbra      L4689

L4600               cmpa      #$49                I key (Identify trap)
                    bne       L4655
                    clr       >$05FC              Clear doing macro flag
                    lbsr      L5749               Get direction to look from player
                    tsta
                    beq       L4689
                    lda       >$10DD
                    adda      >$0DB0
                    sta       >$25B5
                    lda       >$10DC
                    adda      >$0DAF
                    sta       >$25B4
                    lda       >$25B5
                    ldb       >$25B4
                    lbsr      L3BBB
                    cmpa      #$D4                Is it a trap?
                    beq       L4638               Yes, go identify type to player
                    ldu       #$25B6              'no trap there.'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    bra       L4689

L4638               lda       >$25B5              Get Y,X coords
                    ldb       >$25B4
                    lbsr      L3BC6               Get trap type at that location
                    anda      #%00000111          $07 (only 3 bits used for trap type)
                    lbsr      L5041               Get ptr to trap type text into U
                    pshs      u                   Save ptr to trap type text
                    ldu       #$25C5              'you found %s'
                    pshs      u
                    lbsr      L68D8               Print it out
                    leas      4,s
L4652               bra       L4689

L4655               cmpa      #$0F                <CTRL-O> key (Operator - first of 2 keys to enter debug mode)
                    bne       L4669
                    lbsr      L61C2               Go get another keypress
                    cmpa      #$13                <CTRL-up arrow) (Operator - 2nd key required to enable debug mode)
                    bne       L4669               Unknown command, skip ahead
                    clr       >$05FC              Flag we are NOT doing a macro
                    lbsr      L4AA6               Check if we allow CMD mode (checks byte @ >$26BC in rogue.dat file)
                    bra       L4689

L4669               clr       >$05FC              Flag we are NOT doing macro
                    clr       >$063D
                    lbsr      L643F
                    pshs      u
                    ldu       #$25D2              'illegal command '%s''
                    pshs      u
                    lbsr      L68D8               Print out illegal command string
                    leas      4,s
                    clr       >$0D9E              Clear # of times to repeat command
                    lbsr      L43D1               Clear out repeat command ctr on screen, if there was one
                    lda       #$01
                    sta       >$063D
L4689               tst       >$0640
                    beq       L4699
                    tst       >$2543              Were we flagged to go over an object without picking it up?
                    beq       L4699               Yes, skip ahead
                    lda       >$0640
                    lbsr      L70E4
L4699               clr       >$0640
                    tst       >$063C
                    bne       L46A4
                    clr       >$0639
L46A4               tst       >$05FC              ??? Were we doing a macro?
                    lbeq      L4400               No, go back to key check
                    puls      pc,u,y,x,d          Yes, return

* 'i'dentify scroll read
L46AD               pshs      u,y,x,d
                    ldd       >$10F5
                    bne       L46C0
                    ldu       >$25E7              Get ptr to text string?
                    pshs      u
                    lbsr      L68D8               Go print something on screen
                    leas      2,s
                    puls      pc,u,y,x,d

L46C0               ldx       #$2618              'identify'
                    clra
                    lbsr      L711A               Get ptr to object block player wants to identify
                    cmpx      #$0000              Did player specify one?
                    bne       L46E5               Yes, go identify it
                    ldu       #$2621              'You must identify something'
                    pshs      u
                    lbsr      L68D8               Go print that
                    leas      2,s
                    ldu       #$263D              ' '
                    pshs      u
                    lbsr      L68D8               Print space
                    leas      2,s
                    clr       >$0D94
                    bra       L46C0               Prompt player for something to identify again

* X=ptr to object block that player wants to identify
L46E5               lda       4,x                 Get object type
                    cmpa      #$CD                Scroll?
                    bne       L46FD               No, check next
                    lda       #1                  Flag that we now know real name of scroll
                    ldb       $F,x                Get sub-type (type of scroll)
                    ldu       #$05FE              Ptr to "scroll types known" table
                    sta       b,u                 Flag that we know this scroll
                    lslb                          * 2 bytes/entry
                    ldu       #$07ED              Point to tbl of scroll names made up by player
                    clr       [b,u]               Clear first byte of that entry
                    bra       L4764

L46FD               cmpa      #$CE                Potion?
                    bne       L4713               No, check next
                    lda       #1                  Flag that we know real name of potion
                    ldb       $F,x
                    ldu       #$060D              Ptr to "potion types known" table
                    sta       b,u                 Flag that we know this potion
                    lslb
                    ldu       #$080B              Point to tbl of potion names made up by player
                    clr       [b,u]               Clear first byte of that entry
                    bra       L4764

L4713               cmpa      #$D1                Ring?
                    bne       L4731               No, check next
                    lda       #1                  Flag that we know real name of ring
                    ldb       $F,x
                    ldu       #$061B              Ptr to "ring types known" table
                    sta       b,u                 Flag that we know this ring
                    lslb
                    ldu       #$0827              Point to tbl of ring names made up by player
                    clr       [b,u]               Clear first byte of that entry
* 6309 - OIM #$02,<$13,x
                    lda       <$13,x              Flag that ring is fully identified
                    ora       #%00000010          $02
                    sta       <$13,x
                    bra       L4764

L4731               cmpa      #$D2                Wand?
                    bne       L474F               No, try next
                    lda       #1                  Flag that we know real name of wand
                    ldb       $F,x
                    ldu       #$0629              Ptr to "wand types known" table
                    sta       b,u                 Flag that we know this wand
                    lslb
                    ldu       #$0843              Point to tbl of wand names made up by player
                    clr       [b,u]
* 6309 - OIM #$02,<$13,x
                    lda       <$13,x              Flag that wand is fully identified
                    ora       #%00000010          $02
                    sta       <$13,x
                    bra       L4764

L474F               cmpa      #$CF                Weapon?
                    beq       L4759               Yes, go do that
                    cmpa      #$D0                Armor?
                    beq       L4759               Yes, do that the same as weapon
                    bra       L4764               Anything else, skip ahead

* Weapon/Armor Identify goes here
* 6309 - OIM #$02,<$13,x
L4759               lda       <$13,x              Flag that weapon/armor is fully identified
                    ora       #$02
                    sta       <$13,x
L4764               tst       <$14,x              ? I think is weapon vorpalized? (If so, it will be monster letter here)
                    beq       L4771               No, skip ahead
* 6309 - OIM #$40,<$13,x
                    lda       <$13,x              Flag that weapon is vorpalized
                    ora       #$40
                    sta       <$13,x
L4771               clra                          ???
                    lbsr      L72B6               Go generate text string description of object
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    puls      pc,u,y,x,d

L477E               pshs      u,y,x,d
                    lbsr      L6162               Get next free inventory entry (max 40)
                    cmpx      #$0000              Inventory full?
                    bne       L4794               No, skip ahead
                    ldu       #$2658              Yes, 'can't create anything now'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    puls      pc,u,y,x,d

* Debug mode - Create object goes here
* Entry: X=ptr to inventory entry that we will put new object in
L4794               ldu       #$2672              'type of Thing: '
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    clr       >$0D94
L47A1               lbsr      L61C2               Get next output char
                    cmpa      #$41                If we are not creating a monster, skip ahead
                    blt       L4802
                    cmpa      #$5A
                    bhi       L4802
                    pshs      a                   If within A-Z, create monster of this type
                    pshs      x
                    ldx       >$10F3
                    lda       8,x
                    anda      #%00000110          $06
                    beq       L47C3
                    lbsr      L1997
                    lbsr      L3D0A               Get ptr into u0DBB table (entry #a) into X
L47C3               ldu       #$2656
                    lbsr      L0E1A
                    lda       >$2657
                    ldb       >$2656
                    lbsr      L5AF2
                    lbsr      L3C2C
                    tsta
                    beq       L47C3
                    puls      u
                    puls      a
                    ldx       #$2656
                    lbsr      L29E5
                    leax      ,u
                    lbsr      L2C88
                    ldu       #$2682              'you hear a plop!'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    ldx       >$10F3
                    lda       8,x
                    anda      #%00000110          $06
                    bne       L4800
                    ldx       #$10DC
                    lbsr      L0E36
L4800               puls      pc,u,y,x,d

* Create object that is not a monster goes here.
* Entry: A=original text char for object
* Exit:  B=high bit equivalent char to use (in map) and for GFX character
L4802               cmpa      #$3F                ? (Potion)
                    bne       L480B
                    ldb       #$CE                Potion gfx char
                    bra       L486E

L480B               cmpa      #$7E                ~ (Scroll)
                    bne       L4814
                    ldb       #$CD                Scroll gfx char
                    bra       L486E

L4814               cmpa      #$21                ! (Wand/staff)
                    bne       L481D
                    ldb       #$D2                Wand gfx char
                    bra       L486E

L481D               cmpa      #$6F                'o' (ring)
                    bne       L4826
                    ldb       #$D1                Ring gfx char
                    bra       L486E

L4826               cmpa      #$5E                ^ (weapon)
                    bne       L482F
                    ldb       #$CF                Weapon gfx char
                    bra       L486E

L482F               cmpa      #$2A                * (armor)
                    bne       L4838
                    ldb       #$D0                Armor gfx char
                    bra       L486E

L4838               cmpa      #$26                & (Amulet of Yendor)
                    bne       L4841
                    ldb       #$D5                Amulet gfx char
                    bra       L486E

L4841               cmpa      #$24                $ (gold)
                    bne       L484A
                    ldb       #$CB                gold gfx char
                    bra       L486E

L484A               cmpa      #$25                % (food)
                    bne       L4853
                    ldb       #$CC                Food rations gfx char
                    bra       L486E

L4853               cmpa      #$1A                Ctrl-Z? (debug mode user aborting create object)
                    bne       L4868               No, skip ahead
L4857               leau      ,x                  Yes, abort
                    lbsr      L61A0
                    ldu       #$1470
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    puls      pc,u,y,x,d

* Illegal char to create item, beep at user and then prompt again
L4868               lbsr      L4039               Make sound
                    lbra      L47A1               Prompt for object to create again

* Entry: A= original CHR$() version of object
*        B= map version of object (also CHR$ for Rogue graphics font)
L486E               stb       4,x                 Save gfx char/map object type
                    pshs      a                   Preserve original text version
                    ldu       #$2693              'which %c do you want? (0-f)'
                    pshs      u
                    lbsr      L68D8
                    leas      3,s
                    clr       >$0D94
L487F               lbsr      L61C2               Get keypress
                    cmpa      #$1A                <CTRL>-<Z> (abort)?
                    beq       L4857               Yes, do abort
                    pshs      a                   Save keypress
                    lbsr      L3F1E               Check if value @ $2411+A has bit 3 set
                    tsta
                    puls      a                   Restore original keypress
                    beq       L4894               Bit 3 NOT set, skip ahead
                    suba      #$30                Convert ASCII numeric to binary
                    bra       L4896

L4894               suba      #$57                Convert ASCII hex letter to binary (A-F)
L4896               cmpa      #$0F                Legitimate hex value? (0-F)
                    bls       L489F               Yes, save it
                    lbsr      L4039               Make sound to tell player he/she is an idiot
                    bra       L487F               Go get another keypress

* A=hex digit 0-F
* X=Object block ptr
L489F               sta       $F,x                Save sub-type of object
                    clr       <$15,x
                    lda       #1                  Quantity of 1
                    sta       $E,x
                    ldd       #$2640              '0d0' (extra chance to hit & extra damage set to 0), I think
                    std       $A,x                ? Save extra chance to hit?
                    std       $C,x                ? Save extra damage?
                    lda       $4,x                Get object type again
                    cmpa      #$CF                Weapon?
                    beq       L48BB               Yes, ask for attack modifier
                    cmpa      #$D0                Armor?
                    lbne      L494A               No, skip ahead
* Armor/weapon blessing done here
L48BB               ldu       #$2644              'blessing? (+,-,n)'
                    pshs      u
                    lbsr      L68D8               Print prompt
                    leas      2,s
                    lbsr      L61C2               Get keypress from player
                    sta       >$263F              Save copy
                    clr       >$0D94
                    cmpa      #$2D                '-' (Curse)?
                    bne       L48DA               No, skip ahead
* 6309 - OIM #$01,<$13,x      Set cursed flag?
                    lda       <$13,x
                    ora       #%00000001          $01 Set Cursed flag
                    sta       <$13,x
L48DA               lda       4,x                 Get object type again
                    cmpa      #$CF                Weapon?
                    bne       L4918               No, skip ahead
                    lda       $F,x                Get weapon sub-type
                    lbsr      L893F               Copy damage strings,etc. over to object table
                    lda       >$263F
                    cmpa      #$2D                - key? (cursed weapon)
                    bne       L48FD               No, check for blessed weapon request
                    lda       #3                  RND(3)
                    lbsr      L63A9
                    adda      #1                  Now 1-4
                    pshs      a
                    lda       <$10,x              Subtract random # from (gold value?) and save back
                    suba      ,s+
                    sta       <$10,x
L48FD               lda       >$263F              Get keypress back
                    cmpa      #$2B                + key?
                    bne       L4915               No, we are done checking - normal weapon
                    lda       #3                  RND(3)
                    lbsr      L63A9
                    adda      #1                  Now 1-4
                    pshs      a
                    lda       <$10,x              Add random # to (gold value?) and save back
                    adda      ,s+
                    sta       <$10,x
L4915               lbra      L49C6

L4918               lda       >$263F              Get copy of keypress
                    cmpa      #$2D                '-' (cursed?)
                    bne       L4930               No, try next
                    lda       #3                  RND(3)
                    lbsr      L63A9
                    adda      #1                  Now 1-4
                    pshs      a
                    lda       <$12,x              Get Damage modifier?
                    adda      ,s+                 Add RND and save back
                    sta       <$12,x
                    lda       >$263F              Get key back again
L4930               cmpa      #$2B                + key?
                    bne       L4948               No, done
                    lda       #3                  RND(3)
                    lbsr      L63A9
                    adda      #1                  Now 1-4
                    pshs      a
                    lda       <$12,x              Add to ? (I thought damage modifier, but maybe not)
                    suba      ,s+
                    sta       <$12,x
L4948               bra       L49C6

* Create objects other than weapon/armor
L494A               cmpa      #$D1                Ring?
                    bne       L49A9               No, try next
                    lda       $F,x                Get ring type
                    beq       L4962               Protection, get blessing/curse setting
                    cmpa      #1                  Add strength, get blessing/curse setting
                    beq       L4962
                    cmpa      #7                  Dexterity, get blessing/curse setting
                    beq       L4962
                    cmpa      #8                  Increase Damage, get blessing/curse setting
                    beq       L4962
                    bra       L4995               Other rings don't get blessings

L4962               ldu       #$2644              'blessing? (+,-,n)'
                    pshs      u
                    lbsr      L68D8               Display prompt
                    leas      2,s
                    lbsr      L61C2               Get keypress
                    clr       >$0D94
                    cmpa      #$2D                '-' (Curse ring?)
                    bne       L4985               No, skip ahead
* 6309 - OIM #$01,<$13,x
                    lda       <$13,x              Set Cursed flag
                    ora       #%00000001          $01
                    sta       <$13,x
                    lda       #$FF                ??? something unique to rings
                    sta       <$12,x
                    bra       L49C6

L4985               lda       #2                  Not cursed, RND(2)
                    lbsr      L63A9
                    adda      #1                  Now 1-3
                    adda      <$12,x              ??? Add to damage modifier
                    sta       <$12,x
L4992               bra       L49C6

L4995               cmpa      #6                  Aggravate monster?
                    beq       L499F               Yes, set as cursed ring
                    cmpa      #$0B                Teleportation?
                    beq       L499F               Yes, set as cursed ring
                    bra       L49C6

* 6309 - OIM #$01,<$13,x
L499F               lda       <$13,x              Set cursed flag
                    ora       #%00000001          $01
                    sta       <$13,x
L49A7               bra       L49C6

L49A9               cmpa      #$D2                Wand/Staff?
                    bne       L49B2               No, check next
                    lbsr      L7D34               Go do wand stuff
                    bra       L49C6

L49B2               cmpa      #$CB                Gold?
                    bne       L49C6               No, exit
                    ldu       #$26AF              'how much? '
                    pshs      u
                    lbsr      L68D8               Print prompt
                    leas      2,s
                    lbsr      L4F59               Get amount from player
                    std       <$10,x              Save it
L49C6               clra
                    lbsr      L6DBF
                    puls      pc,u,y,x,d

* I think randomly teleport the player on current level?
L49CC               pshs      u,y,x,d
                    lda       >$10DD              Y coord
                    ldb       >$10DC              X coord
                    std       >$355B              Do something with map #2 (4B84)
                    lbsr      L3BBB
                    lbsr      L6612
                    lda       >$0DAE
                    ldb       >$0DAD
                    std       >$355B
                    lbsr      L3BBB
                    lbsr      L6612
L49EC               lbsr      L1997
                    lbsr      L3D0A               Get (into X) ptr to entry A in $0DBB table
                    ldu       #$26BA
                    lbsr      L0E1A
                    lda       >$26BB
                    ldb       >$26BA
                    lbsr      L5AF2
                    lbsr      L58E8               Check map piece;on return A=0 if blank, wall piece or monster, A=1 otherwise
                    tsta
                    beq       L49EC
                    cmpx      >$10F3
                    beq       L4A2D
                    lda       >$10DD              Get Y coord of some sort
                    ldb       >$10DC              Get X coord of some sort
                    lbsr      L3BC6               Do something in map #3 (u5264)
                    anda      #%01000000          $40
                    bne       L4A1F
                    ldx       #$10DC
                    lbsr      L0EDA
L4A1F               ldd       >$26BA
                    std       >$10DC
                    ldx       #$10DC
                    lbsr      L0E36
                    bra       L4A38

L4A2D               ldd       >$26BA
                    std       >$10DC
                    lda       #$01
                    lbsr      L5088
L4A38               lda       >$10DD
                    ldb       >$10DC
                    std       >$355B
                    lda       #$C1
                    lbsr      L6612
                    ldx       #$10D8
                    ldd       #$0080
                    lbsr      L3C3C
                    tsta
                    beq       L4A5F
                    ldd       >$10E4
                    anda      #$FF
                    andb      #$7F
                    std       >$10E4
                    lbsr      L2AB8
L4A5F               clr       >$0D96
                    clr       >$0D9E
                    clr       >$063C
                    lbsr      L621D
                    ldx       #$10D8
                    ldd       #$0100
                    lbsr      L3C3C
                    tsta
                    beq       L4A88
                    ldu       #L5FAB+PrgOffst-$1B2 (#$BDF9)
                    ldd       #$0004
                    lbsr      L6396
                    addd      #$0002
                    lbsr      L5E90
                    bra       L4A9C

L4A88               ldu       #L5FAB+PrgOffst-$1B2 (#$BDF9)
                    ldd       #$0004
                    lbsr      L6396
                    addd      #$0002
                    tfr       d,y
                    ldd       #$0000
                    lbsr      L5E82
L4A9C               lda       >$10E4
                    ora       #%00000001          $01
                    sta       >$10E4
                    puls      pc,u,y,x,d

* Check to see if debug mode is enabled. Offset $26BC in the original rogue.dat file determined
* this; it is easier to modify the BNE to BRA (which can be MODPATCHED)
*  be actual offset in file, since it is loaded starting at <u0000.
L4AA6               tst       >$26BC
* Debug mode: Enable with BRA, disable with BNE).
                    bra       L4AAC
                    rts

* Debug CMD commands
L4AAC               pshs      u,y,x,d
L4AAE               ldu       #$26CB              'cmd: '
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    clr       >$0D94
L4ABB               lbsr      L61C2
L4ABE               cmpa      #$3C                < key? (go up a level)?
                    bne       L4ADC               No, skip ahead
                    lda       >$0D91              Get dungeon level
                    cmpa      #1                  Already on top level?
                    bhi       L4ACF               No, move player up one level
                    lbsr      L4039               Yes, Make sound
                    bra       L4AAE               Do cmd: prompt again

L4ACF               dec       >$0D91              Drop dungeon level by 1 (go up)
                    lbsr      L182A
                    clra
                    lbsr      L5088
                    bra       L4AAE

L4ADC               cmpa      #$3E                > key? (go down)?
                    bne       L4AED               No, check next
                    inc       >$0D91              Increase dungeon level (wraps at 255)
                    lbsr      L182A
                    clra
                    lbsr      L5088
                    bra       L4AAE

L4AED               cmpa      #$61                a(rc) key?
                    bne       L4AF7
                    lbsr      L4BE2
                    bra       L4AAE

L4AF7               cmpa      #$69                i(dent) key?
                    bne       L4B01
                    lbsr      L46AD
                    bra       L4AAE

L4B01               cmpa      #$74                t(eleport) key?
                    bne       L4B1F
                    lbsr      L49CC
                    clra
                    lbsr      L5088
                    ldd       >$10E4
                    anda      #$FE
                    andb      #$FF
                    std       >$10E4
                    ldu       #L5FAB+PrgOffst-$1B2 (#$BDF9)
                    lbsr      L5EA2
                    bra       L4AAE

L4B1F               cmpa      #$6D                m(ap) key?
                    bne       L4B29
                    lbsr      L4CCF
L4BDF               bra       L4AAE

L4B29               cmpa      #$66                f(lags) key?
                    bne       L4B33
                    lbsr      L4D13
                    bra       L4AAE

L4B33               cmpa      #$70                p(ack) key?
                    bne       L4B3D
                    lbsr      L4D65
                    bra       L4BDF

L4B3D               cmpa      #$6C                l(vl) key?
                    bne       L4B47
                    lbsr      L4D82
                    bra       L4BDF

L4B47               cmpa      #$62                b(east) key?
                    bne       L4B51
                    lbsr      L4DD1
                    bra       L4BDF

L4B51               cmpa      #$73                s(ys) key?
                    bne       L4B5B
                    lbsr      L4ECE
                    bra       L4BDF

L4B5B               cmpa      #$63                c(reate) key?
                    bne       L4B65
                    lbsr      L477E
                    bra       L4BDF

L4B65               cmpa      #$20                Spacebar key? (Exits debug menu)
                    beq       L4B6F
                    cmpa      #$1A                <CTRL>-<Z>? (also exits debug menu)
                    bne       L4B7B
L4B6F               ldu       #$1470
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    puls      pc,u,y,x,d

L4B7B               cmpa      #$53                S(uper rogue) key?
                    bne       L4B85
                    lbsr      L4C0F
                    bra       L4BDF

L4B85               cmpa      #$4E                N(ormal rogue) key?
                    bne       L4B8F
                    lbsr      L4C42
                    bra       L4BDF

L4B8F               cmpa      #$52                R(eset rogue) key?
                    bne       L4B99
                    lbsr      L4C66
                    bra       L4BDF

* There are 3 help levels in debug CMD mode: 1st lists base keypresses, the other 2
*   list specifc commands
L4B99               cmpa      #$3F                ? (additional help) key?
                    bne       L4BD9
                    ldu       #$26D1              'cmd (<,>,a,i,t,m,f,p,l,b,s,c,S,N,R,?,??): '
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    clr       >$0D94
                    lbsr      L61C2
                    cmpa      #$3F                ? (additional help) key?
                    lbne      L4ABE               No, skip ahead
                    ldu       #$26FC              'cmd ( a)rc i)dent t)el m)ap f)lags p)ack l)vl b)east s)ys c)reate ): '
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    clr       >$0D94
                    lbsr      L61C2
                    cmpa      #$3F                ? (additional additional help) key?
                    lbne      L4ABE
                    ldu       #$2742              'cmd (S)uper rogue  (N)ormal rogue  (R)eset rogue  : '
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    clr       >$0D94
                    lbra      L4ABB

L4BD9               lbsr      L4039               Illegal Debug command; make sound
                    lbra      L4ABB               Get new keypress from user

L4BE2               ldx       >$10F3              Get tbl ptr
                    lda       8,x                 Check bit 2 of ??? (maze discovered map, maybe?)
                    anda      #%00000010          $02
                    beq       L4BF7               Not set, skip ahead
                    ldu       #$2777              'the corridor flares white and then fades'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    rts

L4BF7               ldu       #$27A0              'the room is lit by a brilliant arc-light'
                    pshs      u
                    lbsr      L68D8               Print message
                    leas      2,s
                    lda       #%11111110          $FE
                    anda      8,x
                    sta       8,x
                    ldx       #$10DC
                    lbra      L0E36

* Super Rogue routine
L4C0F               tst       >$26BD
                    bne       L4C24
                    ldx       #$26BE              Copy 13 bytes from $10A7 to $26BE
                    ldu       #$10A7
                    lda       #13
                    lbsr      L3C51
                    lda       #1
                    sta       >$26BD
L4C24               ldx       #$10A7              Copy 13 bytes from $10C5 to $10A7
                    ldu       #$10C5
                    lda       #13
                    lbsr      L3C51
                    lda       #1
                    sta       >$26BD
                    ldx       #$10E6              Copy 13 bytes from $10A7 to $10E6
                    ldu       #$10A7
                    lda       #13
                    lbsr      L3C51
                    lbra      L6AA2

L4C42               tst       >$26BD
                    bne       L4C4A
                    lbra      L4039               Make sound & return from there

L4C4A               clr       >$26BD
                    ldx       #$10A7              Copy 13 bytes from $26BE to $10A7
                    ldu       #$26BE
                    lda       #13
                    lbsr      L3C51
                    ldx       #$10E6              Copy 13 bytes from $10A7 to $10E6
                    ldu       #$10A7
                    lda       #13
                    lbsr      L3C51
                    lbra      L6AA2

L4C66               tst       >$26BD
                    bne       L4C7B
                    ldx       #$26BE              Copy 13 bytes from $10A7 to $26BE
                    ldu       #$10A7
                    lda       #13
                    lbsr      L3C51
                    lda       #$01
                    sta       >$26BD
L4C7B               ldx       #$10A7              Copy 13 bytes from $10B4 to $10B4
                    ldu       #$10B4
                    lda       #13
                    lbsr      L3C51
                    ldx       #$10E6              Copy 13 bytes from $10A7 to $10E6
                    ldu       #$10A7
                    lda       #13
                    lbsr      L3C51
                    lbra      L6AA2

L4C94               pshs      u,y,x,d
                    ldx       #$27C9              'open sesame'
                    ldu       #$14E2
                    lbsr      L3FCD               Compare strings at ,u / ,x
                    bne       L4CCD
                    lda       >$10DD              Get Y coord
                    ldb       >$10DC              Get X coord
                    lbsr      L3BBB               Get something in map 2 ($4B84)
                    cmpa      #$CA
                    bne       L4CCD
                    lda       >$0DB0
                    bne       L4CCD
                    lda       >$0DAF
                    cmpa      #$01
                    bne       L4CCD
                    ldx       >$10F5              Get object block ptr
                    beq       L4CCD               empty, exit
                    lda       4,x                 Get object type
                    cmpa      #$CC                Is it food?
                    beq       L4CCD               Yes, exit
                    lda       #1                  Anything but food, set flag, beep, & return
                    sta       >$26BC
                    lbsr      L4039               Make sound
L4CCD               puls      pc,u,y,x,d

* 'm'ap key (debug mode)
L4CCF               pshs      u,y,x,d
                    lda       #1
                    sta       >$27D5              Init (line # on map?) to 1
L4CD6               lda       >$27D5              Get vertical line # on map
                    cmpa      #22
                    bhs       L4D07               If >=22 then skip ahead
                    clra                          Init horizongtal char # on map to 0
                    sta       >$27D6
L4CE1               lda       >$27D6              Get current horizontal position on map
                    cmpa      #80                 At end of current row?
                    bhs       L4D02               Yes, bump up line #
                    ldd       >$27D5              No, get current x,y coords we are working on
                    std       >$355B              Save copy
                    lbsr      L3BBB               Get map char at current X,Y position from map 2 (4B84)
                    lbsr      L6612               Write out to screen(?)
                    inc       >$27D6              Bump to next
                    bra       L4CE1

L4D02               inc       >$27D5              Bump up line # we are working on
                    bra       L4CD6               Loop back until done

L4D07               ldu       #$27D7              'map'
                    pshs      u
                    lbsr      L68D8               Print it
                    leas      2,s
                    puls      pc,u,y,x,d

* 'f'lags key (debug mode)
L4D13               pshs      u,y,x,d
                    lda       #1                  Init map Y coord to 1
                    sta       >$27DB
L4D1A               lda       >$27DB              Get current map Y coord
                    cmpa      #22                 Are we at last line or higher?
                    bhs       L4D59               Yes, done drawing flags map
                    clra                          No, init horizontal position to 0
                    sta       >$27DC
L4D25               lda       >$27DC              Get current horizontal position
                    cmpa      #80                 Done current line?
                    bhs       L4D54               Yes, skip ahead
                    ldd       >$27DB              Get current flag map X/Y coords
                    std       >$355B              Save copies for routine
                    ldd       >$27DB
                    lbsr      L3BC6               Get corresponding char (flags) from map #3 ($5264)
                    lsra                          Shift hi nibble to low nibble
                    lsra
                    lsra
                    lsra
                    cmpa      #9                  If high nibble>9, then skip ahead
                    bhi       L4D4A
                    adda      #$30                bump to ASCII 0-9
                    bra       L4D4C

L4D4A               lda       #$2A                If anything higher than 9, write out '*' instead (error condition, maybe?)
L4D4C               lbsr      L6612               Write it out
                    inc       >$27DC              Bump X coord up
                    bra       L4D25               Continue current line

L4D54               inc       >$27DB              Inc y coord
                    bra       L4D1A               Loop back until done

L4D59               ldu       #$27DD              'flags'
                    pshs      u
                    lbsr      L68D8               Print that
                    leas      2,s
                    puls      pc,u,y,x,d

* 'p'ack key (debug mode) - show contents of backpack, with mem addresses
L4D65               pshs      u,y,x,d
                    lbsr      L6D6F               Clear our window
                    ldx       >$10F5              Get ptr to backpack's root object block
                    bsr       L4D9F
                    pshs      x
                    ldx       #$27E3              'pack:'
                    lbsr      L6D07               Write out string @ X (NUL terminated)
                    puls      x
                    lbsr      L61C2
                    lbsr      L6411
                    puls      pc,u,y,x,d

* 'l'vl_obj key (debug mode) - show all objects on current level, with mem addresses
L4D82               pshs      u,y,x,d
                    lbsr      L6D6F               Clear our window
                    ldx       >$10F7              Get ptr to current level's first object block
                    bsr       L4D9F               Go through linked list, display addresses and what they are
                    pshs      x
                    ldx       #$27E9              'lvl_obj:'
                    lbsr      L6D07               Write out string @ X (NUL terminated)
                    puls      x
                    lbsr      L61C2
                    lbsr      L6411
L4DCF               puls      pc,u,y,x,d

* Go through object blocks (linked lists) - used for Backpack and objects on current level
* Entry: X=Ptr to first object block for list we are going through
L4D9F               pshs      u,y,x,d
L4DA1               cmpx      #$0000              Is the current object block empty?
                    beq       L4DCF               Yes, exit
                    tfr       x,d                 Move ptr to D
                    lbsr      L4FCE               Write address out in hex
                    lda       #$3A                Write ':' to screen
                    lbsr      L6CF5
                    ldd       ,x                  Get ptr to next object in linked list
                    lbsr      L4FCE               Write out that address in hex
                    lda       #$20                Write space to screen
                    lbsr      L6CF5
                    clra
                    lbsr      L72B6
                    pshs      x                   Save object block ptr
                    leax      ,u
                    lbsr      L6D07               Write out string @ X (NUL terminated)
                    lbsr      L5010               Write out LFCR
                    puls      x                   Get object block ptr back
                    ldx       ,x                  Get ptr to next object block
                    bra       L4DA1               Go do that one (or exit if $0000)

* 'b'east key (debug mode) - show list of monsters on level, and monster block ptrs
L4DD1               pshs      u,y,x,d
                    lbsr      L6D6F               Clear our window
                    ldx       >$10F9              Get ptr to to root monster block
L4DD9               cmpx      #$0000              Done list? (next monster is empty)
                    beq       L4E31               Yes, finish routine
                    tfr       x,d                 Move ptr to D
                    lbsr      L4FCE               Write address out in hex
                    lda       #$3E                Write '>' to screen
                    lbsr      L6CF5
                    ldd       ,x                  Get ptr to next monster object in linked list
                    lbsr      L4FCE               Write that address out in hex
                    pshs      x                   Save ptr to current monster object
                    ldx       #$27F2              ' ('
                    lbsr      L6D07               Write out string @ X (NUL terminated)
                    ldx       ,s                  Get ptr back
                    ldd       $C,x                Get monster flags
                    lbsr      L4FCE               Write those out in hex
                    ldx       #$27F5              ') '
                    lbsr      L6D07               Write out string @ X (NUL terminated)
                    ldx       ,s                  Get ptr back
                    lda       7,x                 Get monster type (first letter of monster name)
                    suba      #$41                convert to 0-25
                    ldb       #18                 18 bytes/entry in monster definition table
                    mul
                    addd      #$10FB              Point to monster entry we want
                    tfr       d,x                 Move monster definition ptr to X
                    ldx       ,x                  Get ptr to full monster name
                    lbsr      L6D07               Write it out (string @ X (NUL terminated)
                    lbsr      L5010               Write out LFCR
                    puls      x                   Get back monster object ptr
                    ldd       <$1D,x              Get ???
                    beq       L4E2C               Empty, skip ahead
                    pshs      x                   Save monster object ptr again
                    tfr       d,x                 Copy ptr to X
                    lbsr      L4D9F               Go through linked list based on that ptr.
                    puls      x
L4E2C               ldx       ,x                  Get ptr to next monster object
                    bra       L4DD9               Keep doing list until done

L4E31               pshs      x
                    ldx       #$27F8              'monsters:'
                    lbsr      L6D07               Write out string @ X (NUL terminated)
                    puls      x
                    lbsr      L61C2
                    lbsr      L6411
                    puls      pc,u,y,x,d

* UNUSED DEBUGGING CODE - NOT REFERENCED ANYWHERES. Dumps ptr address and 1 byte per tbl entry
* for table @ $EED, and secondary tbl @ u0DBB. I THINK THESE ARE ROOM TABLES
L4E43               pshs      u,y,x,d
                    lbsr      L6D6F               Clear the window
                    lbsr      L5010               Write out LFCR
                    ldx       #$0EED              Point to start of table
L4E4E               cmpx      #$10A7              Are we done all 13 entries of the table?
                    beq       L4E6A               Yes, skip ahead
                    tfr       x,d                 Move ptr to D
                    lbsr      L4FCE               Write out ptr to screen in hex
                    lda       #$3A                Write ':' to screen
                    lbsr      L6CF5
                    lda       8,x                 Get ?? from table
                    lbsr      L4FDA               Write single byte to screen in hex
                    lbsr      L5010               Write out LFCR
                    leax      <34,x               Point to next entry in table
                    bra       L4E4E               Keep going until all 13 entries are done

* PART OF UNUSED DEBUGGING ROUTINE
L4E6A               pshs      x                   Save ptr to current entry
                    ldx       #$2802              'passages:r_flags'
                    lbsr      L6D07               Write out string @ X (NUL terminated)
                    puls      x                   Get ptr back
                    lbsr      L61C2               Check for keypress amongst other things
                    lbsr      L6D6F               Clear the window
                    lbsr      L5010               Write out LFCR
                    ldy       #$0DBB              Point to another table of nine 34 byte entries
L4E81               cmpy      #$0EED              Are we done the secondary table?
                    beq       L4EBC               Yes, skip ahead
                    tfr       y,d                 Move ptr to D
                    lbsr      L4FCE               Write out that ptr to screen in hex
                    lda       #$3A                Write ':' to screen
                    lbsr      L6CF5
                    lda       8,y                 Get ?? from secondary tbl
                    lbsr      L4FDA               Write 8 bit value out to screen in hex
                    pshs      x                   Save main tbl ptr
                    ldx       #$2813              ' r_pos:'
                    lbsr      L6D07               Write out string @ X (NUL terminated)
                    puls      x                   Get main tbl ptr back
                    ldd       ,y                  Get ??? from secondary table
                    lbsr      L4FCE               Write out 16 bit num to screen in hex
                    pshs      x
                    ldx       #$281B              ' r_max:'
                    lbsr      L6D07               Write out string @ X (NUL terminated)
                    puls      x
                    ldd       2,y                 Get ?? from secondary ptr
                    lbsr      L4FCE               Write 16 bit num to screen in hex
                    lbsr      L5010               Write out LFCR
                    leay      <34,y               Point to next entry in secondary table
                    bra       L4E81               Keep going until secondary tbl done

* PART OF UNUSED DEBUGGING ROUTINE
L4EBC               pshs      x                   Save primary tbl ptr
                    ldx       #$2823              'rooms:'
                    lbsr      L6D07               Write out string @ X (NUL terminated)
                    puls      x                   Restore primary tbl ptr
                    lbsr      L61C2               'More 'and keypress check
                    lbsr      L6411
                    puls      pc,u,y,x,d

* 's'ys key (Debug mode) - Summary of linked lists (System status)
L4ECE               pshs      u,y,x,d
                    lbsr      L6D6F               Clear the window
                    lda       >$0638              Get saw_amulet and namulet flag, put on stack for display routine
                    pshs      a
                    lda       >$0637
                    pshs      a
                    ldu       #$282A              'namulet    :(%i)CRLFsaw_amulet :(%i)CRLF'
                    pshs      u
                    lbsr      L6D16               Print both amulet statuses on screen
                    leas      4,s                 Eat temp stack
                    ldx       >$10F5              Get ptr to root object block for backpack contents
                    clra                          init # of backpack objects to 0
                    bsr       L4F2E               Count how many backpack objects we have
                    pshs      a                   Save backpack object count
                    bsr       L4F3D               Get monsters and mcarried counts
                    pshs      a                   Save those for printing
                    pshs      b
                    ldx       >$10F7              Get ptr to root object for current dungeon level
                    clra                          Clear ctr
                    bsr       L4F2E               Count objects on current dungeon level
                    pshs      a                   Save that on stack
                    adda      1,s                 Add all 4 counts together
                    adda      2,s
                    adda      3,s
* 'alloc(lvl_obj ) :(%i)CRLF     (monsters) :(%i)CRLF     (mcarried) :(%i)CRLF     (packed  ) :(%i)CRLF'
                    ldu       #$284F
                    pshs      u
                    lbsr      L6D16               Print level objects, monsters, 'mcarried' and backpack totals
                    leas      6,s                 Eat temp stack
                    ldb       >$0D9A              Get # of objects defined?
                    pshs      b                   Save # objects defined
                    pshs      a                   Save # objects counted
                    lda       >$0D9B              Get # of objects in backpack
                    pshs      a
                    ldu       #$28AC              'total defined:(%i)CRLFaccounted for:(%i)CRLFinpack :(%i)CRLFCRLFsys_status:'
                    pshs      u
                    lbsr      L6D16               Print object totals
                    leas      5,s                 Eat temp stack
                    lbsr      L61C2               Check for keypress
                    lbsr      L6411
                    puls      pc,u,y,x,d

* Entry: X=ptr to root object block for object table
* Exit:  A=how many objects in table
L4F2E               pshs      x                   Save object block ptr
L4F30               cmpx      #$0000              End of linked list?
                    beq       L4F3B               Yes, exit
                    inca                          Bump up object ctr
                    ldx       ,x                  Get ptr to next object
                    bra       L4F30               Keep counting until we have done them all

L4F3B               puls      pc,x

L4F3D               pshs      y,x
                    clra                          clear mcarried and monsters counters
                    clrb
                    ldy       >$10F9              Get ptr to root object block for monsters
L4F45               leay      ,y                  Done table?
                    beq       L4F57               Yes, exit
                    incb                          Inc monster counter
                    ldx       <$1D,y              Get ptr to ???
                    bsr       L4F2E               Get count of objects in sub-table
                    ldy       ,y                  Get ptr to next object
                    bra       L4F45               Keep doing this this table is done counting

L4F57               puls      pc,y,x

* Debug: Get amount of gold player wants to create
* Exit: D=# of gold
L4F59               pshs      x
                    ldx       #$28F0              Point to keyboard buffer
                    lda       #10                 10 chars max
                    lbsr      L6268               Get response from player (ASCII # of gold)
                    lbsr      L3F9C               Convert it to binary (into D)
                    puls      pc,x                Return

* DEBUG: UNUSED CODE, NEVER CALLED
* Entry: X=ptr to string (NUL terminated)
L4F68               pshs      u,y,x,d
                    lbsr      L501F               Get length of string @ X, write it to screen
                    lbsr      L502F               Read 1 char from keyboard into A
                    lbsr      L5010               Write out LFCR
                    puls      pc,u,y,x,d

* DEBUG: UNUSED CODE, NEVER CALLED
* Register dump (for debugging) - currently never called
L4F75               pshs      d
                    pshs      x
                    pshs      y
* 6809/6309 - If there aren't direct jumps into each PSHS, these last two can be combined into PSHS u,cc
                    pshs      u
                    pshs      cc
* Register dump
                    ldx       #$28FC              ' D:'
                    lbsr      L501F
                    ldd       7,s
                    bsr       L4FCE
                    ldx       #$2900              ' X:'
                    lbsr      L501F
                    ldd       5,s
                    bsr       L4FCE
                    ldx       #$2904              ' Y:'
                    bsr       L501F
                    ldd       3,s
                    bsr       L4FCE
                    ldx       #$2908              ' U:'
                    bsr       L501F
                    ldd       1,s
                    bsr       L4FCE
                    ldx       #$290C              ' CC:'
                    bsr       L501F
                    lda       ,s
                    bsr       L4FDA
                    ldx       #$2911              ' S:'
                    bsr       L501F
                    tfr       s,d
                    bsr       L4FCE
                    bsr       L5010
* 6809/6309 - if not separate entry points, combine puls cc,u
                    puls      cc
                    puls      u
                    puls      y
                    puls      x
                    puls      pc,d

* Write out 16 bit number in D to screen, in hexidecimal format
L4FCE               pshs      d
                    bsr       L4FDA               Write out upper byte first
                    tfr       b,a
                    bsr       L4FDA               Write out lower byte
                    puls      pc,d

* Print byte out in hex (00-FF)
* Entry: A= byte to print out in hex format
L4FDA               pshs      u,y,x,d
                    pshs      a                   Save digit
                    lsra                          Shift hi nibble to low
                    lsra
                    lsra
                    lsra
                    adda      #$30                ASCIIfy #
                    cmpa      #$3A                Past 9?
                    blo       L4FEA               Nope, go print
                    adda      #$07                Yep, bump it up to A-F (for hex)
L4FEA               bsr       L4FFE               Write digit out
                    puls      a                   Get original digit back
                    anda      #%00001111          Keep low nibble only
                    adda      #$30                ASCIIfy #
                    cmpa      #$3A                Past 9?
                    blo       L4FF9               No, go print
                    adda      #$07                Make into A-F hex digit
L4FF9               bsr       L4FFE               Print digit out
                    puls      pc,u,y,x,d          Restore regs & return

* Write single char at <u2915 out to screen
L4FFE               pshs      y,x,d
                    sta       >$2915              Save char to write out
                    ldx       #$2915              Point to it
                    ldy       #$0001              1 char
                    clra
                    os9       I$Write             Write to Std In (same as Std out)
                    puls      pc,y,x,d

* Write out LFCR to screen
L5010               pshs      y,x,d
                    ldx       #$2916              Point to LFCR
                    ldy       #$0002
                    clra
                    os9       I$Write             Write to screen
                    puls      pc,y,x,d

L501F               pshs      u,y,x,d
                    lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    tfr       a,b
                    clra
                    tfr       d,y                 # chars to write (from A returned by L3FE7
                    clra
                    os9       I$Write             Write to screen & return
                    puls      pc,u,y,x,d

* Read 1 char from keyboard, return with key in A
L502F               pshs      y,x,b
                    ldx       #$2918
                    ldy       #$0001
                    clra
                    os9       I$Read
                    lda       >$2918
                    puls      pc,y,x,b

* Get ptr to text string for trap type
* Entry: A=Trap type (0-7 max)
* Exit:  U=ptr to text string of the trap type
* 6809/6309 - might be able to make more efficient with deca instead of cmpa, unless
* calling routines require A intact
L5041               clr       >$2983
                    sta       >$2984              Save copy of trap type
                    bne       L504F
                    ldu       #$2919              'a trapdoor'
                    rts

L504F               cmpa      #$03
                    bne       L5057
                    ldu       #$2924              'a beartrap'
                    rts

L5057               cmpa      #$02
                    bne       L505F
                    ldu       #$292F              'a sleeping gas trap'
                    rts

L505F               cmpa      #$01
                    bne       L5067
                    ldu       #$2943              'an arrow trap'
                    rts

L5067               cmpa      #$04
                    bne       L506F
                    ldu       #$2951              'a teleport trap'
                    rts

L506F               cmpa      #$05
                    bne       L5077
                    ldu       #$2961              'a poison dart trap'
                    rts

* Should not get here - something is corrupted if it did.
L5077               ldu       >$2983
                    pshs      u
                    ldu       #$2974              'wierd trap: %d'
                    pshs      u
                    lbsr      L68D8
                    ldu       #$0000
                    rts

L5088               pshs      u,y,x,d
                    sta       >$2984
                    clr       >$299D
                    ldd       >$10F3              Get ptr to ???
                    std       >$298C              Save copy
                    lda       >$10DD              Get Y coord of some sort
                    ldb       >$10DC              Get X coord of some sort
                    lbsr      L5AAA               X=offset into 80x22 map          X=offset into 80x22 map
                    stx       >$2990              Save this (I have no idea what this is for
                    lda       >$5264,x            Get byte from that far into the 3rd map buffer (Flags map)
                    sta       >$298A              Save copy
                    lda       >$4B84,x            Get byte from that far into the 2nd map buffer
                    sta       >$2992              Save copy of that as well.
                    ldd       #$0DAD              Point to X,Y coord of some sort
                    ldu       #$10DC              Point to another X,Y coord of some sort
                    lbsr      L5A95               Check if they match
                    tsta
                    lbne      L5180               Yes, skip ahead
                    ldx       #$10D8              Base address to check against (with +12 offset)
                    ldd       #$0001              Bit mask to check
                    lbsr      L3C3C               go see if bit 1 set in $10D8+12 (as 16 bit #)
                    tsta                          If bit 1 set?
                    lbne      L5174               Yes, skip ahead (I think this means fully lit room)
                    lda       >$0DAD              No, get X coord of some sort (I think this is the 3x3 mapping routine for unlit room)
                    deca                          -1
                    sta       >$299C              Save that copy (and start point for 3x3 mapping in darkened room)
                    adda      #2                  add 2
                    sta       >$2985              and save that (part of mapping in dark room, with coord +/-1 in each direction
L50D8               lda       >$299C              Get current X coord
                    cmpa      >$2985              Have we finished all 3 across?
                    lbhi      L5174               Yes, skip ahead
                    lda       >$0DAE              Get Y coord of some sort
                    inca                          Create +/-1 versions of it, and save those
                    sta       >$2986              Save +1 version
                    suba      #2
                    sta       >$299B              Save -1 version (and start point for checking)
L50EE               lda       >$299B              Get current Y coord
                    cmpa      >$2986              Have we finished to +1 version?
                    bhi       L516E               Yes, go bump up X coordinate now and loop back
                    ldb       >$299C              Get max X coord to do
                    cmpa      >$10DD              Compare current Y coord with another Y coord (map clipping?)
                    bne       L5105               Different, skip ahead
                    cmpb      >$10DC              Compare current X coord with another X coord (map clipping?)
                    beq       L5168
L5105               lbsr      L5ADE
                    tsta
                    bne       L5168
                    lda       >$299B              Get Y coord we want map char from
                    std       >$355B              Save copy for subroutine
                    lbsr      L65E6               Get char from map into A
                    sta       >$2987              Save copy
                    cmpa      #$C2                Is it a Floor?
                    bne       L512D               No, skip ahead
                    ldu       >$0DB9
                    lda       8,u
                    anda      #%00000011          $03 Keep lowest two bits only
                    cmpa      #1                  Is it just lowest bit set by itself?
                    bne       L5168               No, skip ahead
                    lda       #$20
                    lbsr      L6612
                    bra       L5168

* This has something to do with player moving on map.
L512D               ldd       >$299B
                    lbsr      L5AAA               X=offset into 80x22 map
                    leau      >$5264,x            Point into 3rd map (flags)
                    stu       >$2988              Save that ptr
                    lda       ,u                  Get flags byte
                    anda      #%00100000          $20
                    bne       L5149
                    lda       ,u
                    anda      #%01000000          $40
                    beq       L5168
L5149               lda       >$2987
                    cmpa      #$C3                Is it a hallway?
                    beq       L5168               Yes, skip ahead
                    cmpa      #$D3                Is it Stairs?
                    beq       L5168               Yes, skip ahead
                    lda       ,u                  Get byte from flags map
                    anda      #%00001111          $0F (keep only lower nibble's worth of flags)
                    ldb       >$298A
                    andb      #%00001111          $0F (keep only lower nibble's worth of flags)
                    pshs      b
                    cmpa      ,s+                 Are these the same?
                    bne       L5168               No, skip ahead
                    lda       #$C3                Char for Hallway
                    lbsr      L6612               Go print (if viewable/needable, etc.)
L5168               inc       >$299B              Inc working Y coord
                    bra       L50EE               Continue

L516E               inc       >$299C              Inc working X coord
                    lbra      L50D8               Continue

* Possibly routine to view room that is lit (ie draw whole room, not just 3x3 grid around player)
L5174               ldd       >$10DC              Get X/Y coords
                    std       >$0DAD              Save copies
                    ldd       >$298C              ??? Copy something else
                    std       >$0DB9
L5180               lda       >$10DD              Get Y coord
                    inca                          Bump up by 1, save new version out
                    sta       >$2993
                    lda       >$10DC              Get X coord
                    inca                          Bump up by 1, save new version out
                    sta       >$2994
                    lda       >$10DC
                    deca
                    sta       >$2996
                    lda       >$10DD
                    deca
                    sta       >$2995
                    tst       >$0639
                    beq       L51C2
                    tst       >$063B
                    bne       L51C2
                    tst       >$063C
                    beq       L51C2
                    ldb       >$10DC
                    clra
                    pshs      d
                    ldb       >$10DD
                    addd      ,s
                    std       >$2997
                    clra
                    ldb       >$10DD
                    subd      ,s++
                    std       >$2999
L51C2               lda       >$2995
                    sta       >$299B
L51C8               lda       >$299B
                    cmpa      >$2993
                    lbhi      L5498
                    cmpa      #$00                Can't use TSTA, since not just negative or zero branch
                    lblo      L5498
                    cmpa      #22
                    lbhs      L5498
                    lda       >$2996
                    sta       >$299C
L51E4               lda       >$299C
                    cmpa      >$2994
                    lbhi      L5492
                    cmpa      #$00                Can't use TSTA, since not just negative or zero branch
                    lbls      L548C
                    cmpa      #80
                    lbhs      L548C
                    ldx       #$10D8
                    ldd       #$0001
                    lbsr      L3C3C
                    tsta
                    bne       L521C
                    lda       >$299B
                    cmpa      >$10DD
                    bne       L5230
                    ldb       >$299C              Get current X coord+1
                    cmpb      >$10DC
                    bne       L5230
                    lbra      L548C

* Part of checking map when going through hallways, I think
L521C               lda       >$299B
                    cmpa      >$10DD
                    lbne      L548C
                    lda       >$299C
                    cmpa      >$10DC
                    lbne      L548C
L5230               ldd       >$299B
                    lbsr      L5AAA               X=offset into 80x22 map
                    stx       >$2990
                    leax      >$5264,x            Offset into map #3 (flags map)
                    stx       >$2988              Save ptr
                    ldx       >$2990
                    lda       >$4B84,x            Offset into map #2
                    sta       >$2987
                    lda       #$CA                Door object
                    cmpa      >$2992
                    beq       L5293
                    cmpa      >$2987
                    beq       L5293
                    lda       >$298A
                    anda      #%01000000          $40
                    pshs      a
                    ldu       >$2988
                    lda       ,u
                    anda      #%01000000          $40
                    cmpa      ,s+
                    beq       L527C
                    lda       >$298A
                    anda      #$20
                    bne       L5293
                    lda       ,u
                    anda      #%00100000          $20
                    bne       L5293
                    lbra      L548C

L527C               lda       ,u
                    anda      #%01000000          $40
                    beq       L5293
                    lda       ,u
                    anda      #%00001111          $0F
                    pshs      a
                    lda       >$298A
                    anda      #%00001111          $0F
                    cmpa      ,s+
                    lbne      L548C
L5293               ldd       >$299B              Get Y/X coord (maybe something to do with unlit room?)
                    lbsr      L2CDB               Search monster object list for matching monster in same position
                    stx       >$298E              Save ptr
                    beq       L5315               If not monster at that coord, skip ahead
                    ldx       #$10D8
                    ldd       #$0002              Check if bit 2 set @ 12,x
                    lbsr      L3C3C
                    tsta                          Was bit 2 on?
                    beq       L52CF               No, skip ahead
                    ldx       >$298E
                    ldd       #$0010              Check if bit 5 set @ 12,x
                    lbsr      L3C3C
                    tsta
                    beq       L52CF
                    tst       >$0639
                    lbeq      L548C
                    tst       >$063B
                    lbne      L548C
                    clr       >$063C
                    lbra      L548C

* Something to do with monster encounters (hit or miss)? But not killing them.
L52CF               lda       >$2984              Was tst, but since A is immediately reloaded either way, lda is faster
                    beq       L52DD
                    ldd       >$299B
                    lbsr      L2B55
L52DD               ldx       >$298E
                    lda       9,x
                    cmpa      #$20
                    bne       L52FB
                    ldx       >$298C
                    lda       8,x
                    anda      #%00000001          $01
                    bne       L5307
                    ldx       #$10D8
                    ldd       #$0001              Check if bit 1 set @ 12,x
                    lbsr      L3C3C
                    tsta
                    bne       L5307               Yes, skip ahead
L52FB               ldx       >$2990
                    lda       >$4B84,x
                    ldx       >$298E
                    sta       9,x
L5307               ldx       >$298E
                    lbsr      L25F0
                    tsta
                    beq       L5315
                    lda       8,x
                    sta       >$2987
L5315               ldd       >$299B
                    std       >$355B
                    lda       >$2987
                    lbsr      L6612
                    tst       >$0639
                    lbeq      L548C
                    tst       >$063B
                    lbne      L548C
                    tst       >$063C
                    lbeq      L548C
                    lda       >$0641              Get keypress (I think)
                    cmpa      #$68                h? (left)
                    bne       L536A               No, check next
                    lda       >$299C
                    cmpa      >$2994
                    lbeq      L548C
                    lbra      L541E

L536A               cmpa      #$6A                j? (down)
                    bne       L537B
                    lda       >$299B
                    cmpa      >$2995
                    lbeq      L548C
                    lbra      L541E

L537B               cmpa      #$6B                k? (up)
                    bne       L538C
                    lda       >$299B
                    cmpa      >$2993
                    lbeq      L548C
                    lbra      L541E

L538C               cmpa      #$6C                l? (right)
                    bne       L539D
                    lda       >$299C
                    cmpa      >$2996
                    lbeq      L548C
                    bra       L541E

L539D               cmpa      #$79                y (up/left)
                    bne       L53BE
                    ldd       >$2997
                    pshs      d
                    ldb       >$299C
                    clra
                    pshs      d
                    ldb       >$299B
                    addd      ,s++
                    subd      ,s++
                    cmpd      #$0001
                    lbge      L548C
                    bra       L541E

L53BE               cmpa      #$75                u (up/right)
                    bne       L53DF
                    ldd       >$2999
                    pshs      d
                    clra
                    ldb       >$299C
                    pshs      d
                    ldb       >$299B
                    subd      ,s++
                    subd      ,s++
                    cmpd      #$0001
                    lbge      L548C
                    bra       L541E

L53DF               cmpa      #$6E                n (down/right)
                    bne       L5400
                    ldd       >$2997
                    pshs      d
                    ldb       >$299C
                    clra
                    pshs      d
                    ldb       >$299B
                    addd      ,s++
                    subd      ,s++
                    cmpd      #$FFFF
                    ble       L548C
                    bra       L541E

L5400               cmpa      #$62                b (down/left)
                    bne       L541E
                    ldd       >$2999
                    pshs      d
                    clra
                    ldb       >$299C
                    pshs      d
                    ldb       >$299B
                    subd      ,s++
                    subd      ,s++
                    cmpd      #$FFFF
                    ble       L548C
L541E               lda       >$2987
                    cmpa      #$CA                Door?
                    bne       L543D               No, check next
                    lda       >$10DC
                    cmpa      >$299C
                    beq       L5437
                    lda       >$10DD
                    cmpa      >$299B
                    bne       L548C
L5437               clr       >$063C
                    bra       L548C

L543D               cmpa      #$C3                Hallway?
                    bne       L5459               No, check next
                    lda       >$10DC
                    cmpa      >$299C
                    beq       L5453
                    lda       >$10DD
                    cmpa      >$299B
                    bne       L548C
L5453               inc       >$299D
                    bra       L548C

L5459               cmpa      #$C2                Floor?
                    beq       L548C               Yes, skip ahead
                    cmpa      #$C5                Vertical Wall?
                    beq       L548C               Yes, skip ahead
                    cmpa      #$C4                Horizontal Wall?
                    beq       L548C               Yes, skip ahead
                    cmpa      #$C6                Upper left corner wall?
                    beq       L548C               Yes, skip ahead
                    cmpa      #$C7                Upper right corner wall?
                    beq       L548C               Yes, skip ahead
                    cmpa      #$C8                Lower left corner wall?
                    beq       L548C               Yes, skip ahead
                    cmpa      #$C9                Lower right corner wall?
                    beq       L548C               Yes, skip ahead
                    cmpa      #$20                ??? I think this is the empty space that is not part of the rooms/hallways?
                    beq       L548C               Yes, skip ahead
                    clr       >$063C
L548C               inc       >$299C
                    lbra      L51E4

L5492               inc       >$299B
                    lbra      L51C8

L5498               tst       >$0639
                    beq       L54AC
                    tst       >$063B
                    bne       L54AC
                    lda       >$299D
                    cmpa      #1
                    bls       L54AC
                    clr       >$063C
L54AC               lda       >$10DD
                    ldb       >$10DC
                    std       >$355B
                    lbsr      L3BC6
                    anda      #%01000000          $40
                    bne       L54CD
                    lda       >$063E
                    cmpa      #1
                    bhi       L54CD
                    lda       >$10DD
                    lbsr      L3BC6
L54CD               lda       #$C1                Player object
                    lbsr      L6612
                    tst       >$063E
                    beq       L54E3
                    lbsr      L4039               Make sound
                    clr       >$063E
L54E3               puls      pc,u,y,x,d

L54E5               ldx       >$10F7
L54E8               beq       L54FA               If X=0, exit with X=0
                    cmpa      6,x
                    bne       L54F5
                    cmpb      5,x
                    beq       L54FA
L54F5               ldx       ,x
                    bra       L54E8

L54FA               rts

* 'e'at command
L54FF               pshs      u,y,x,d
                    ldx       #$299E              'eat'
                    lda       #$CC                Food object
                    lbsr      L711A
                    cmpx      #$0000              No food object?
                    lbeq      L55EE               Nope, exit
                    lda       4,x                 Get object type
                    cmpa      #$CC                Food?
                    beq       L5523               Yes, skip ahead
                    ldu       #$29A2              'ugh, you would get ill if you ate that'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    puls      pc,u,y,x,d

L5523               dec       >$0D9A
                    dec       $E,x                Dec qty of food object
                    lda       $E,x                Get new qty
                    cmpa      #1                  At least 1 food?
                    bhs       L5539               Yes, go do
                    ldu       #$10F5              Get root object block ptr to backpack
                    lbsr      L6112               Remove object ptr ,X from linked list of backpack objects
                    leau      ,x
                    lbsr      L61A0
L5539               ldd       >$0DA4              Get current ctr for how long food will last
                    cmpd      #$0000              Positive #?
                    bge       L5547               Yes, skip ahead
                    clra                          If negative, force to 0
                    clrb
                    std       >$0DA4
L5547               cmpd      #$07BC              1980 (ctr for how long food lasts?)
                    bls       L555A               If 1-1980, skip ahead
                    lda       #5                  RND(5)
                    lbsr      L63A9
                    adda      #2                  Change to 2-7
                    adda      >$0D98
                    sta       >$0D98
L555A               ldd       #$0190
                    lbsr      L6396
                    addd      #$044C              add 1100
                    addd      >$0DA4              add to original food ctr
                    std       >$0DA4              Save it back
                    cmpd      #$07D0              If >2000, force to 2000
                    bls       L5575
                    ldd       #$07D0
                    std       >$0DA4
L5575               clr       >$0DA7
                    clr       >$0DA8
                    cmpx      >$0DB7
                    bne       L5586
                    clr       >$0DB7
                    clr       >$0DB8
L5586               lda       $F,x                Get sub-type of food
                    cmpa      #1                  If anything but 1, skip ahead
                    bne       L559D
                    ldu       #$150B              'Slime Mold'
                    pshs      u
                    ldu       #$29C9              'my, that was a yummy %s'
                    pshs      u
                    lbsr      L68D8
                    leas      4,s
                    bra       L55DF

L559D               lda       #100                RND(100)
                    lbsr      L63A9
                    cmpa      #70                 7 in 10 chance food tastes good
                    bls       L55D5
* If food tastes awful, player gains 1 experience point
                    ldd       >$10E9              Get LSW
                    addd      #1                  Add 1
                    std       >$10E9
                    ldd       >$10E7              Get MSW
                    adcb      #0
                    adca      #0
                    std       >$10E7
                    ldu       #$29E1              'yuk, this food tastes awful'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbsr      L33D5
                    bra       L55DF

L55D5               ldu       #$29FD              'yum, that tasted good'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
L55DF               tst       >$0D98              If player has eaten too much
                    beq       L55EE
                    ldu       #$2A13              'You feel bloated and fall asleep'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
L55EE               puls      pc,u,y,x,d

* Something to do with damage with player attack
L55F0               pshs      u,y,x,d
                    tsta
                    beq       L563D
                    ldx       #$10E6
                    lbsr      L563F
                    lda       >$10E6
                    sta       >$2A34
                    ldd       #$0001              Check if player wearing Add Strength on left hand
                    lbsr      L3BE8
                    tsta
                    beq       L5618               Nope, skip ahead
                    ldx       #$2A34              Ptr to one of 2 players potential max damage
                    ldu       >$0DB3              Get ptr to object block for right hand
                    lda       <$12,u              Get damage modifier for ring
                    nega                          Invert for subroutine
                    bsr       L563F               Modify players potential damage on attack
L5618               ldd       #$0101              Check if player wearing Add Strength on right hand
                    lbsr      L3BE8
                    tsta
                    beq       L562F
                    ldx       #$2A34              Ptr to one of 2 players potential max damage
                    ldu       >$0DB5              Get ptr to object block for left hand
                    lda       <$12,u              Get damage modifier for ring
                    nega                          Flip sign
                    bsr       L563F               Modify players potential damage on attack
L562F               lda       >$10A7              Get ???
                    cmpa      >$2A34              Compare with ring-modified max damage?
                    bhi       L563D               If original higher than ring modified, exit
                    lda       >$2A34              If original lower than ring-modified, use ring modified instead
                    sta       >$10A7
L563D               puls      pc,u,y,x,d

* Entry: X=ptr to damage value ($2A34)
*        A=ring damage modifier (inverted sign - a -1 ring comes here with $01; a +2 ring comes here with -2)
* Exit:  ,x  contains maximum damage player can do on attack
L563F               pshs      u,y,x,d
                    pshs      a                   Save inverted damage modifier
                    ldb       ,x                  Get current damage value
                    addb      ,s+                 Add ring modifier
                    stb       ,x                  Save damage value back
                    cmpb      #3                  Is damage value>=3?
                    bhs       L5653               Yes, skip ahead
                    ldb       #3                  If <3, force to 3 (minimum damage during an attack, I presume)
                    stb       ,x                  Save 3 as damage
                    puls      pc,u,y,x,d

L5653               cmpb      #31                 If damage value >31?
                    bls       L565B               No, leave as is
                    ldb       #31                 Yes, force to maximum damage of 31
                    stb       ,x
L565B               puls      pc,u,y,x,d

* Something to do with player quaffing a Haste Self potion
* Entry: A=1 always, I think
* Exit:  A=0 or 1 (0 if player is now paralyzed, 1=
L565D               pshs      u,y,x,b
                    pshs      a                   Save copy of Haste self flag?
                    ldx       #$10D8              Point to block of (player?) data
                    ldd       #$4000              Check if bit 15 is set in 12,x (fainted flag?)
                    lbsr      L3C3C
                    tsta
                    beq       L56A4               No, skip ahead
* 6809/6309 - was leas 1,s/pshs a. NOT TESTED YET
                    sta       ,s                  Save A overtop old value on stack
                    lda       #8                  RND(8)
                    lbsr      L63A9
                    adda      >$0D98              Add to some sort of food value (not actual turns left on food)
                    sta       >$0D98              Save it back
                    ldb       >$10E5              Get 2nd half of player status flags
                    andb      #%11111011          $FB Paralyze player
                    stb       >$10E5
                    ldu       #L6035+PrgOffst-$1B2 (#$BE83)
                    lbsr      L5EA2
                    lda       >$10E4              Get high byte of player status flags
                    anda      #%10111111          $BF Flag fainted
                    sta       >$10E4
                    ldu       #$2A35              'you faint from exaustion'
                    pshs      u
                    lbsr      L68D8               Print that on screen
                    leas      2,s
                    clra
                    puls      pc,u,y,x,b

* Haste self if bit 15 in player flags is NOT set (not paralized?)
L56A4               lda       >$10E4              Get player flags
                    ora       #%01000000          $40 Set fainted flag?
                    sta       >$10E4
                    puls      a                   Restore original A (1)
                    beq       L56C5
                    ldu       #L6035+PrgOffst-$1B2 (#$BE83) (this is the 'you feel yourself slowing down' routine)
                    lda       #4                  RND(4)
                    lbsr      L63A9
                    adda      #10                 now 10-14
                    tfr       a,b                 D=#
                    clra
                    tfr       d,y                 Y=#
                    ldd       #$0000
                    lbsr      L5E82
L56C5               lda       #$01
                    puls      pc,u,y,x,b

* Part of Aggravate Monster
L56C9               pshs      u,y,x,d
                    ldx       >$10F9              Get ptr to root monster object block
L56CE               cmpx      #$0000              No monsters?
                    beq       L56E1               None, return
                    pshs      x                   Save current monster object block ptr
                    leax      4,x                 Point to object type?
                    lbsr      L268D               ? Call something (part of attacking monster?)
                    puls      x                   Restore object ptr
                    ldx       ,x                  Get ptr to next entry monster linked list
                    bra       L56CE               Continue until all monsters in level have been changed

L56E1               puls      pc,u,y,x,d

* Point U to NUL or 'n' (for 'a' or 'an')
* Entry: U=ptr to string
* Exit:  U=ptr to either 'n', or NUL if not (adds to 'a', for 'a' (consonant) or 'an' (vowel)
L56E3               pshs      a
                    lda       ,u
                    cmpa      #$61                a?
                    beq       L5711
                    cmpa      #$41                A?
                    beq       L5711
                    cmpa      #$65                e?
                    beq       L5711
                    cmpa      #$45                E?
                    beq       L5711
                    cmpa      #$69                i?
                    beq       L5711
                    cmpa      #$49                I?
                    beq       L5711
                    cmpa      #$6F                o?
                    beq       L5711
                    cmpa      #$4F                O?
                    beq       L5711
                    cmpa      #$75                u
                    beq       L5711
                    cmpa      #$55                U?
                    bne       L5719
L5711               ldu       #$2A4E              'n'
                    puls      pc,a

L5719               ldu       #$1470
                    puls      pc,a

* Check if object already in use
* Entry: X = Object block ptr (X=0 if none)
* Exit: A=0 if not in use, A=1 if in use
L571E               pshs      u,y,x,b
                    clra
                    cmpx      #$0000              If no ptr, return
                    beq       L5747
                    cmpx      >$0DB1              Same object as armor being worn?
                    beq       L573B               Yes, report already in use
                    cmpx      >$0DB7              Same object as weapon being wielded?
                    beq       L573B               Yes, report already in use
                    cmpx      >$0DB3              Same object as on left hand?
                    beq       L573B               Yes, report already in use
                    cmpx      >$0DB5              Same object as on right hand?
                    bne       L5747               No, exit with A=0
L573B               ldu       #$2A50              'That's already in use'
                    pshs      u
                    lbsr      L68D8               Print message
                    leas      2,s
                    lda       #$01                Flag already in use/can't
L5747               puls      pc,u,y,x,b

* routine to prompt for direction from player - used by several routines (zap, throw, Identify trap)
L5749               pshs      u,y,x,b
                    lda       #$01
                    tst       >$05FD
                    bne       L57B3
                    ldu       #$2A66              'which direction? '
                    pshs      u
                    lbsr      L68D8               Print prompt
                    leas      2,s
L575C               lbsr      L61C2               Get response from player
                    cmpa      #$1A                <CTRL-Z>? (which is abort)
                    bne       L5770               No, skip ahead
                    ldu       #$1470
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    clra
                    bra       L57B3

L5770               ldx       #$0DAF              Buffer to hold 2 bytes of data (Y and X coord offsets to add)
                    bsr       L57B5               Figure out how Y and X coord offsets
                    tsta                          We aren't moving (illegal movement key), prompt user again
                    beq       L575C
                    ldu       #$1470
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    ldx       #$10D8              Point to player data
                    ldd       #%0000000100000000  $0100 Check if bit 9 set in player flags (confused)
                    lbsr      L3C3C
                    tsta
                    beq       L57B1               Nope, exit with A=1
                    lda       #5                  Player is confused, A=RND(5)
                    lbsr      L63A9
                    tsta
                    beq       L57B1               If 0, exit with A=1
L5797               lda       #3                  A=RND(3)
                    lbsr      L63A9
                    deca                          Now -1 to 2
                    sta       >$0DB0
                    tfr       a,b
                    lda       #3                  A=RND(3)
                    lbsr      L63A9
                    deca                          Now -1 to 2
                    sta       >$0DAF
                    tstb                          Check original RND(3)
                    bne       L57B1               It was either -1, 1 or 2, skip ahead
                    tsta                          If original was 0, check 2nd one
                    beq       L5797               0 as well, get new random numbers
L57B1               lda       #$01
L57B3               puls      pc,u,y,x,b

* Save offsets for a movement key
* Entry: A=movement keypress
* Exit: ,x  = X offset value to move
*       1,x = Y offset value to move
*       A=1 if we did move, and A=0 if we did not
L57B5               pshs      u,y,x,b
                    ldb       #1                  Default flag that we did move
                    stb       >$2A78
                    cmpa      #$68                h key? (left)
                    beq       L57C6
                    cmpa      #$48                H key?
                    bne       L57CF               No, try next
L57C6               clr       1,x                 Y offset=0
                    ldb       #-1                 X offset=-1
                    stb       ,x
                    bra       L585B

L57CF               cmpa      #$6A                j key? (down)
                    beq       L57D9
                    cmpa      #$4A                J key?
                    bne       L57E2               No, try next
L57D9               ldb       #1                  Y offset=1
                    stb       1,x
                    clr       ,x                  X offset=0
                    bra       L585B

L57E2               cmpa      #$6B                k key? (up)
                    beq       L57EC
                    cmpa      #$4B                K key?
                    bne       L57F5               No, try next
L57EC               ldb       #-1                 Y offset=-1
                    stb       1,x
                    clr       ,x                  X offset=1
                    bra       L585B

L57F5               cmpa      #$6C                l key? (right)
                    beq       L57FF
                    cmpa      #$4C                L key?
                    bne       L5808               no, try next
L57FF               clr       1,x                 Y offset=0
                    ldb       #1                  X offset=1
                    stb       ,x
                    bra       L585B

L5808               cmpa      #$79                y key? (up and left)
                    beq       L5812
                    cmpa      #$59                Y key?
                    bne       L581B               No, try next
L5812               ldb       #-1                 Y offset=-1
                    stb       1,x
                    stb       ,x                  X offset=-1
                    bra       L585B

L581B               cmpa      #$75                u key?  (up and right)
                    beq       L5825
                    cmpa      #$55                U key?
                    bne       L5830
L5825               ldb       #-1                 Y offset=-1
                    stb       1,x
                    negb                          X offset=1
                    stb       ,x
                    bra       L585B

L5830               cmpa      #$62                b key? (down and left)
                    beq       L583A
                    cmpa      #$42                B key?
                    bne       L5845
L583A               ldb       #1                  Y offset=1
                    stb       1,x
                    negb                          X offset=-1
                    stb       ,x
                    bra       L585B

L5845               cmpa      #$6E                n key?
                    beq       L584F
                    cmpa      #$4E                N key?
                    bne       L5858               No, flag we didn't do anything
L584F               ldb       #1                  Y offset=1
                    stb       1,x
                    stb       ,x                  X offset=1
                    bra       L585B

L5858               clr       >$2A78              Flag that we didn't move
L585B               lda       >$2A78              Get "did we move" flag & return
                    puls      pc,u,y,x,b

* Entry: A=value to check
* Exit: A=0 if A was 0, 1 if it was positive, $FF if it was negative
L5860               cmpa      #$00                Can't use TSTA, since not just negative or zero branch
                    bge       L586A
                    lda       #$FF
                    bra       L586E

L586A               beq       L586E
                    lda       #$01
L586E               rts

* 6809/6309 - pretty sure we can combine to pshs u,y,x,d
* Entry: D=16 bit # to divide into
L5870               pshs      u,y,x
                    pshs      d
                    tfr       d,u                 Move to U to divide into
                    ldd       #10                 Divide by 10
                    lbsr      L3C5C               U=U/D (remainder in D)
                    ldd       ,s                  Get original # back
                    pshs      u                   Save copy of result from /10
                    subd      ,s++                Subtract 1/10 from original value
                    pshs      d                   Save new result
                    ldu       2,s                 Get 1/10 result again
                    ldd       #5                  Divide that by 5
                    lbsr      L3C5C               U=U/D (remainder in D)
                    tfr       u,d                 Save answer
                    lbsr      L63A9               Get RND(A) (just upper byte)
                    addd      ,s++
                    leas      2,s                 Eat original # to divide into
                    puls      pc,u,y,x

L5897               pshs      u,y,x,d
                    stx       >$2AA1
                    ldb       [,x]
                    tsta
* 6809/6309 - change to BEQ L58A9. L58A6 tsta's again with bne - it can never be bne. No other entry
                    beq       L58A6
* 6809/6309 - isn't this tstb useless? CLR immediately zeros N, V, C bits, & forces Z bit to 1, overriding tstb
                    tstb
                    clr       [,x]
                    bra       L58E6

* 6809/6309 - After L58A9 label added and BEQ above changed, remove 2 lines
L58A6               tsta
                    bne       L58E6
* Add L58A9 label
                    tstb
                    bne       L58E6
                    lda       >$37CB
                    cmpa      #$32
                    blo       L58BA
                    ldu       #$2A79              'what do you want to call it? '
                    pshs      u
                    bra       L58BF

L58BA               ldu       #$2A97              'call it? '
                    pshs      u
L58BF               lbsr      L68D8
                    leas      2,s
                    ldx       #$4B34
                    lda       #$14
                    lbsr      L6268
                    ldu       #$4B34
                    lda       ,u
                    cmpa      #$1A                <CTRL-Z>
                    beq       L58DC
                    ldx       [>$2AA1]
                    lbsr      L3FF3
L58DC               ldu       #$1470
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
L58E6               puls      pc,u,y,x,d

* Check map type
* Entry: A=map char (or monster char)
* Exit : A=0 if blank, wall or monster
*        A=1 if anything else
L58E8               cmpa      #$20                Blank (not active part of map)?
                    beq       L5906               Yes, exit with A=0
                    cmpa      #$41                not blank,wall or monster?
                    blo       L5914               Yes, exit with A=1
                    cmpa      #$5A                Is it an uppercase letter (monster)?
                    bls       L5906               Yes, exit with A=0
                    cmpa      #$C4                not blank,wall or monster?
                    blo       L5914               Yes, exit with A=1
                    cmpa      #$C9                One of 6 wall types?
                    bls       L5906               Yes, exit with A=0
L5914               lda       #1                  Flag as not blank,wall or monster
                    rts

L5906               clra
                    rts

* 6809/6309 - modify to group compares to shrink/speed up. Also, No registers are changed
* except A, so remove pshs and change puls to rts
*L58E8    pshs  u,y,x,b
*         cmpa  #$20           Blank (not active part of map)?
*         beq   L5906          Yes, exit with A=0
*         cmpa  #$C4
*         beq   L5906
*         cmpa  #$C5
*         beq   L5906
*         cmpa  #$C6
*         beq   L5906
*         cmpa  #$C7
*         beq   L5906
*         cmpa  #$C8
*         beq   L5906
*         cmpa  #$C9
*         bne   L5909

*L5906    clra                 Flag if blank, wall,
*         puls  pc,u,y,x,b

*L5909    cmpa  #$41           Alphabetic uppercase?
*         blo   L5914          Nope, set flag to 1
*         cmpa  #$5A
*         bhi   L5914
*         clra                 Yes, set flag to 0
*         bra   L5916

*L5914    lda   #$01
*L5916    puls  pc,u,y,x,b

L5918               pshs      u,y,x,a
                    ldb       #$D6
                    lda       <$13,y
                    anda      #$01
                    beq       L5925
                    ldb       #$D7
L5925               lda       4,y
                    cmpa      #$D0
                    bne       L5942
                    lda       <$12,y
                    pshs      a
                    lda       $F,y
                    ldx       #$014E
                    lda       a,x
                    cmpa      ,s+
                    lbhs      L59C7
                    ldb       #$D7
                    lbra      L59C7

L5942               cmpa      #$CF
                    bne       L5958
                    lda       <$10,y
* 6809/6309 - redundant, remove CMPA
                    cmpa      #$00
                    blo       L5954
                    lda       <$11,y
* 6809/6309 - redundant, remove CMPA
                    cmpa      #$00
                    bcc       L59C7
L5954               ldb       #$D7
                    bra       L59C7

L5958               cmpa      #$CD
                    bne       L596E
                    lda       $F,y
                    cmpa      #$03
                    beq       L596A
                    cmpa      #$0A
                    beq       L596A
                    cmpa      #$0C
                    bne       L59C7
L596A               ldb       #$D7
                    bra       L59C7

L596E               cmpa      #$CE
                    bne       L5988
                    lda       $F,y
* 6809/6309 - redundant, remove CMPA
                    cmpa      #$00
                    beq       L5984
                    cmpa      #$01
                    beq       L5984
                    cmpa      #$02
                    beq       L5984
                    cmpa      #$0C
                    bne       L59C7
L5984               ldb       #$D7
                    bra       L59C7

L5988               cmpa      #$D2
                    bne       L599A
                    lda       $F,y
                    cmpa      #$07
                    beq       L5996
                    cmpa      #$0C
                    bne       L59C7
L5996               ldb       #$D7
                    bra       L59C7

L599A               cmpa      #$D1
                    bne       L59C7
                    lda       $F,y
* 6809/6309 - redundant, remove CMPA
                    cmpa      #$00
                    beq       L59C3
                    cmpa      #$01
                    beq       L59C3
                    cmpa      #$08
                    beq       L59C3
                    cmpa      #$07
                    bne       L59BB
                    lda       <$12,y
                    bhs       L59C7
                    ldb       #$D7
                    puls      pc,u,y,x,a

L59BB               cmpa      #$06
                    beq       L59C3
                    cmpa      #$0B
                    bne       L59C7
L59C3               ldb       #$D7
L59C7               puls      pc,u,y,x,a

* '/' (symbols help) and '?' (commands help).
* Entry: X=ptr to help filename we will be displaying. Symbols help can be rogue.chr (regular font)
*  or rogue.grf (rogue font)
L59C9               pshs      u,y,x,d
                    clr       >$2AA3
                    lda       #$01
                    os9       I$Open
                    bcs       L5A4F
                    sta       >$14AE
                    lbsr      L6D6F
L59DD               ldb       >$37CC
                    cmpb      #$0F
                    bls       L59EC
                    subb      #$0F
                    asrb
                    lda       #$0A
                    lbsr      L6532
L59EC               ldb       >$37CB
                    cmpb      #$20
                    bls       L59FB
                    subb      #$20
                    asrb
                    lda       #$20
                    lbsr      L6532
L59FB               lda       >$14AE
                    ldx       #$4B34              Read up to 32 bytes
                    ldy       #32
                    os9       I$ReadLn
                    lda       ,x                  Get 1st byte, save copy
                    sta       >$2AA3
                    cmpa      #$58                X-skip ahead
                    beq       L5A23
                    cmpa      #$4E                N-skip ahead
                    beq       L5A23
                    tfr       y,d
                    lda       #10
                    sta       b,x
                    incb
                    clr       b,x
                    lbsr      L6D07               Write out string @ X (NUL terminated)
                    bra       L59EC

L5A23               lda       >$37CE
                    ldx       #$2AA4              'SPACE to continue ESC to quit'
                    lbsr      L6D56
L5A2C               lbsr      L61C2
                    cmpa      #$1A                <CTRL-Z>
                    beq       L5A44
                    cmpa      #$20                Space?
                    bne       L5A2C
                    lda       >$2AA3
                    cmpa      #$58                X?
                    beq       L5A44
                    lbsr      L6D6F
* 6809/6309 - BRA
                    lbra      L59DD

L5A44               lda       >$14AE
                    os9       I$Close
                    lbsr      L6411
L5A4D               puls      pc,u,y,x,d

L5A4F               pshs      x
                    ldu       #$2AC2              'Can't open "%s".'
                    pshs      u
                    lbsr      L68D8
* 6809/6309 - change 2 lines to leas 4,s
                    leas      2,s
                    leas      2,s
                    bra       L5A4D

* Pythagorean Thereom calc (Calc diagonal distance)
* Entry: A,B  = Y,X coord of first point
*        YH,YL= Y,X coord of 2nd point
* Exit: D=SQR of distance between the two points
L5A5F               pshs      u,y,x
* 6809/6309 - std >$2AD3
                    sta       >$2AD3              Save coords
                    stb       >$2AD4
* 6809/6309 - replace next 3 lines with sty >$2AD5
                    tfr       y,d                 Save other coords
                    sta       >$2AD5
                    stb       >$2AD6
                    lda       >$2AD4              Calc distance between X coords
                    suba      >$2AD6
                    ldb       >$2AD3              Calc distance between Y coords
                    subb      >$2AD5
                    tsta                          ABS of X distance
                    bpl       L5A7F
                    nega
L5A7F               tstb                          ABS of Y distance
                    bpl       L5A83
                    negb
L5A83               pshs      b                   Save Y distance
                    tfr       a,b                 Move X distance to B
                    mul                           Multiply together (SQR of X distance)
                    tfr       d,u                 Move result to U
                    puls      a                   Get Y distance back
                    tfr       a,b                 Multiply by itself (SQR of Y distance)
                    mul
                    pshs      u                   Save SQR(X distance)
                    addd      ,s++                Add to SQR(Y distance)
                    puls      pc,u,y,x

* Check if X,Y coords match (pointed to by U and D on entry)
* Entry: U=ptr to X,Y #1
*        D=ptr to X,Y #2
* Exit:  A=0 if they don't match, A=1 if they do
* 6809/6309 - x and U don't get modified; shouldn't need to preserve.
L5A95               pshs      u,y,x,b
                    tfr       d,y
                    lda       #$01
                    ldb       ,y
                    cmpb      ,u
                    bne       L5AA7
                    ldb       1,y
                    cmpb      1,u
                    beq       L5AA8
L5AA7               clra
L5AA8               puls      pc,u,y,x,b

* Entry: A=Y coord of some sort
*        B=X coord of some sort
L5AAA               pshs      u,y,d
                    cmpa      #23                 Is Y coord 23 or higher?
                    bhs       L5AB4               Yes, skip ahead
                    cmpb      #80                 No, Is X coord <80?
                    blo       L5AC9
* 6809/6309 - double check, but I think pshs d would work here?
L5AB4               pshs      b                   Illegal coordinate(s) found - save coords for text routine
                    pshs      a
                    ldu       #$2AD7              'index: bad index. (%i,%i)'
                    pshs      u
                    lbsr      L68D8               Print error message, including coords
                    leas      4,s
                    ldx       #$0000
                    puls      pc,u,y,d

* x,y coords are legit
L5AC9               tfr       d,u                 Copy Y,X to U
                    tfr       a,b                 D=A (Y coord)
                    clra
                    pshs      d                   Save 16 bit version of Y coord on stack
                    tfr       u,d                 Copy X coord back to B
                    lda       #21                 21*X coord?
                    mul
                    addd      ,s++                Add to Y coord on stack
                    subd      #$0001              Subract 1
                    tfr       d,x                 Copy result to X and exit
                    puls      pc,u,y,d

L5ADE               cmpa      #$01
                    blo       L5AEF
                    cmpa      #$16
                    bhs       L5AEF
                    clra
                    cmpb      #$00                Can't use TSTB, since not just negative or zero branch
                    blo       L5AEF
                    cmpb      #80
                    blo       L5AF1
L5AEF               lda       #$01
L5AF1               rts

* Find if monster on specified map coordinate
* Entry: A=Y coord
*        B=X coord
* Exit:  X=Ptr to monster object (or 0 if none)
*        A=map type square (hallway, floor, etc.) at coord
L5AF2               pshs      u,y,x,b
                    lbsr      L2CDB               Search monster object list for matching monster in same position
                    cmpx      #$0000              Monster at that position?
                    bne       L5B01               Yes, get type of map square under monster from monster object
                    lbsr      L3BBB               No, get type of map square from actual map
                    puls      pc,u,y,x,b

L5B01               lda       8,x                 Get type of map square under the monster & return
                    puls      pc,u,y,x,b

* 's'earch command
L5B05               pshs      u,y,x,d
                    ldx       #$10D8
                    ldd       #$0001
                    lbsr      L3C3C
                    tsta
                    lbne      L5C02
                    lda       >$10DC
                    inca
                    sta       >$2B01
                    lda       >$10DD
                    inca
                    sta       >$2AFF
                    suba      #$02
                    sta       >$2AFE
L5B28               lda       >$2AFE
                    cmpa      >$2AFF
                    lbhi      L5C02
                    lda       >$10DC
                    deca
                    sta       >$2B00
L5B39               lda       >$2B00
                    cmpa      >$2B01
                    lbhi      L5BFC
                    lda       >$2AFE
                    ldb       >$2B00
                    cmpa      >$10DD
                    bne       L5B55
                    cmpb      >$10DC
                    lbeq      L5BF6
* 6809/6309 - BSR
L5B55               lbsr      L5ADE
                    tsta
                    lbne      L5BF6
                    lda       >$2AFE
                    ldb       >$2B00
                    lbsr      L3CFF
                    stu       >$2B02
                    lda       ,u
                    anda      #$10
                    lbne      L5BF6
                    lda       >$2AFE
                    ldb       >$2B00
                    lbsr      L3BBB
                    cmpa      #$C5
                    beq       L5B92
                    cmpa      #$C4
                    beq       L5B92
                    cmpa      #$C6
                    beq       L5B92
                    cmpa      #$C7
                    beq       L5B92
                    cmpa      #$C8
                    beq       L5B92
                    cmpa      #$C9
                    bne       L5BB8
L5B92               lda       #5                  RND(5)
                    lbsr      L63A9
                    tsta
                    bne       L5BF6
                    lda       >$2AFE
                    lbsr      L3CF4
                    lda       #$CA
                    sta       ,u
                    ldu       >$2B02
* 6309 - OIM #$10,,u if L43D1 doesn't need the OR'd A
                    lda       ,u
                    ora       #$10
                    sta       ,u
                    clr       >$0D9E
                    lbsr      L43D1
                    clr       >$063C
                    bra       L5BF6

L5BB8               cmpa      #$C2                Floor?
                    bne       L5BF6               No, skip ahead
                    lda       #2                  RND(2)
                    lbsr      L63A9
                    tsta
                    bne       L5BF6
                    lda       >$2AFE
                    ldb       >$2B00
                    lbsr      L3CF4
                    lda       #$D4
                    sta       ,u
                    ldu       >$2B02
* 6309 - OIM #$10,,u if L43D1 doesn't need the OR'd A
                    lda       ,u
                    ora       #$10
                    sta       ,u
                    clr       >$0D9E
                    lbsr      L43D1
                    clr       >$063C
                    anda      #$07
                    lbsr      L5041
                    pshs      u
                    ldu       #$2AF1              'you found %s'
                    pshs      u
                    lbsr      L68D8
                    leas      4,s
L5BF6               inc       >$2B00
                    lbra      L5B39

L5BFC               inc       >$2AFE
                    lbra      L5B28

L5C02               puls      pc,u,y,x,d

* '>' or F1 - go down command
L5C04               pshs      u,y,x,d
                    lda       >$10DD
                    ldb       >$10DC
                    lbsr      L3BBB
                    cmpa      #$D3                Stairs?
                    beq       L5C1F               Yes, move player down 1 level
                    ldu       #$2B04              'I see no way down'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    bra       L5C25

L5C1F               inc       >$0D91              increase dungeon level # (go down)
                    lbsr      L182A
L5C25               puls      pc,u,y,x,d

* '<' or F2 - go up command
L5C27               pshs      u,y,x,d
                    lda       >$10DD
                    ldb       >$10DC
                    lbsr      L3BBB
                    cmpa      #$D3                Stairs?
                    bne       L5C61               No, tell player (s)he is an idiot
                    tst       >$0637              Has player seen the amulet?
                    beq       L5C55               No, skip ahead
                    dec       >$0D91              Yes, Move player up a level
* 6809/6309 - isn't tst redundant? dec above will set the zero flag already. Remove tst
                    tst       >$0D91              Has player hit surface?
                    bne       L5C46               No, skip subroutine
                    lbsr      L0830
L5C46               lbsr      L182A
                    ldu       #$2B16              'you feel a wrenching sensation in your gut'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    bra       L5C6B

L5C55               ldu       #$2B41              'your way is magically blocked'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    bra       L5C6B

L5C61               ldu       #$2B5F              'I see no way up'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
L5C6B               puls      pc,u,y,x,d

* 'c'all command
L5C6D               pshs      u,y,x,d
                    ldx       #$2B6F              'call'
                    lda       #$FF
                    lbsr      L711A
                    stx       >$2BEA
                    cmpx      #$0000
                    lbeq      L5DB4
                    lda       4,x
                    cmpa      #$D1
                    bne       L5CB5
                    ldu       #$0827
                    stu       >$2BEC
                    ldd       #$061B
                    std       >$2BEE
                    lda       $F,x
                    lsla
                    ldy       a,u
                    lda       ,y
                    tsta
                    beq       L5CA5
                    sty       >$2BF0
                    lbra      L5D4F

L5CA5               lda       $F,x
                    lsla
                    ldu       #$0799
                    ldy       a,u
                    sty       >$2BF0
                    lbra      L5D4F

L5CB5               cmpa      #$CE
                    bne       L5CE5
                    ldu       #$080B
                    stu       >$2BEC
                    ldd       #$060D
                    std       >$2BEE
                    lda       $F,x
                    lsla
                    ldy       a,u
                    lda       ,y
                    tsta
                    beq       L5CD6
                    sty       >$2BF0
                    bra       L5D4F

L5CD6               lda       $F,x
                    lsla
                    ldu       #$077D
                    ldy       a,u
                    sty       >$2BF0
                    bra       L5D4F

L5CE5               cmpa      #$CD
                    bne       L5D13
                    ldu       #$07ED
                    stu       >$2BEC
                    ldd       #$05FE
                    std       >$2BEE
                    lda       $F,x
                    lsla
                    ldy       a,u
                    lda       ,y
                    tsta
                    beq       L5D06
                    sty       >$2BF0
                    bra       L5D4F

L5D06               lda       $0F,x
                    ldb       #$15
                    mul
                    addd      #$0642
                    std       >$2BF0
                    bra       L5D4F

L5D13               cmpa      #$D2
                    bne       L5D43
                    ldu       #$0843
                    stu       >$2BEC
                    ldd       #$0629
                    std       >$2BEE
                    lda       $F,x
                    lsla
                    ldy       a,u
                    lda       ,y
                    tsta
                    beq       L5D34
                    sty       >$2BF0
                    bra       L5D4F

L5D34               lda       $F,x
                    lsla
                    ldu       #$07B5
                    ldy       a,u
                    sty       >$2BF0
                    bra       L5D4F

L5D43               ldu       #$2B74              'you can't call that anything'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    bra       L5DB4

L5D4F               lda       $F,x
                    ldu       >$2BEE
                    lda       a,u
                    beq       L5D64
                    ldu       #$2B91              'that has already been identified'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    bra       L5DB4

L5D64               ldu       >$2BF0
                    pshs      u
                    ldu       #$2BB2              'Was called "%s"'
                    pshs      u
                    lbsr      L68D8
                    lda       >$37CB
                    cmpa      #$32
                    blo       L5D7F
                    ldu       #$2BC2              'what do you want to call it? '
                    pshs      u
                    bra       L5D84

L5D7F               ldu       #$2BE0              'call it? '
                    pshs      u
L5D84               lbsr      L68D8
                    leas      6,s
                    ldx       #$4B34
                    lda       #$14
                    lbsr      L6268
                    lda       ,x
                    beq       L5DAA
                    cmpa      #$1A
                    beq       L5DAA
                    ldx       >$2BEA
                    ldu       >$2BEC
                    lda       $0F,x
                    lsla
                    ldx       a,u
                    ldu       #$4B34
                    lbsr      L3FF3
L5DAA               ldu       #$1470
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
L5DB4               puls      pc,u,y,x,d

* 'M'acro key define command
L5DB6               pshs      u,y,x,d
                    stx       >$2C1E
                    lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    sta       >$2C22
                    clr       >$2C23
                    pshs      x
                    lda       >$37CB
                    cmpa      #$32
                    blo       L5DD4
                    ldu       #$2BF2              'The macro was %s, enter new macro: '
                    pshs      u
                    bra       L5DD9

L5DD4               ldu       #$2C16              'macro: '
                    pshs      u
L5DD9               stu       >$2C20
                    lbsr      L68D8
                    leas      4,s
                    ldx       #$4B34
                    lda       #$28
                    lbsr      L6268
                    cmpa      #$1A                <CTRL-Z>
                    beq       L5E03
                    lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    sta       >$2C23
                    ldx       >$2C1E
                    ldu       #$4B34
L5DF9               lda       ,u+
                    cmpa      #$4D                M?
                    beq       L5DF9               Yes, eat that character (can't define Macro inside of defining a Macro)
                    sta       ,x+
                    bne       L5DF9
L5E03               ldx       >$2C20
                    lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    adda      >$2C22
                    adda      >$2C23
                    cmpa      >$37CB
                    bls       L5E19
                    lbsr      L6411
                    bra       L5E23

L5E19               ldu       #$1470
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
L5E23               clr       >$0D94
                    lbsr      L621D
                    puls      pc,u,y,x,d

* look for empty entry (jump address of 0)
* Exit: X=ptr to empty entry
L5E2B               pshs      u,d
                    ldu       #$0000              Look for a jump address of 0 (empty entry; we will be adding new)
                    bsr       L5E35               Go find it
                    puls      pc,u,d

* Search tbl of 20 six byte entries for match address
* Entry: U=jump address we are looking for a match for (or $0000 if we are adding)
* Exit: X=ptr to 6 byte tbl entry with matching jump address
*         X=0 means table is full, and no match found
L5E35               ldx       #$2C24              Point to start of tbl
L5E38               cmpu      ,x                  Does the jump address match?
                    beq       L5E47               Yes, exit
                    leax      6,x                 No, point to next entry
                    cmpx      #$2C9C              Done all 20?
                    bne       L5E38               No, keep checking
                    ldx       #$0000              Yes, tbl is full, exit with X=0
L5E47               rts

* I *think* these tbl entries are countdown timers of some sort, with jump addresses associated
*   with each. It goes through all of them after it starts, updating as needed. They all have a common
*   last routine called (L5E79) which enables it to continue through the table until all active entries
*   in the tbl are done.
* Init tbl entry. Saves jump address, middle value, and inits counter to -1
* Entry: U=jump address
*        D=middle value (whatever that is)
* Exit: X points to existing tbl entry with matching U address, or new one added.
*       Tbl entry has U saved at ,X; D is saved at 2,x, and 4,x is inited to $FFFF
L5E48               pshs      x,d
                    bsr       L5E2B               Look for empty entry (jump address of $0000)
                    stu       ,x                  Save address (may already be there)
                    std       2,x                 Save ????
                    ldd       #$FFFF              Init counter to -1
                    std       4,x
                    puls      pc,x,d

L5E58               pshs      u,y,x,d
                    ldx       #$2C24              Point to tbl of 20 six byte entries
L5E5D               ldd       4,x                 Get last two bytes of current entry
                    cmpd      #$FFFF              $FFFF is special flag or ctr (means ctr hasn't started?)
                    bne       L5E79               Not special flag, skip to next entry
                    ldy       ,x                  Get first 2 bytes (subroutine ptr-$1B2)
                    beq       L5E79               Empty, skip to next entry
                    leau      >L5E79,pc           Not empty, point to routine (goes to next entry)
                    pshs      u                   Put on stack as 2ndary RTS (after main subroutine called)
                    leay      >$01B2,y            Point Y to ($1B2) bytes from original ptr above (WHY DID THEY SUBTRACT $1B2 IN 1ST PLACE?)
                    pshs      y                   Put that on stack as RTS address
                    ldd       2,x                 Get middle 2 bytes from table
                    rts                           Return to address from Y above

* all the weird -$1b2 subroutines come here after completing. This is to continue going through the
* tbl entries at $2C24 to $2C9C until they are all done
L5E79               leax      6,x                 Point to next entry
                    cmpx      #$2C9C              Done checking all 20 entries?
                    bne       L5E5D               No, keep checking
                    puls      pc,u,y,x,d          restore regs and return

L5E82               pshs      x
                    lbsr      L5E2B
                    stu       ,x
                    std       2,x
                    sty       4,x
                    puls      pc,x

L5E90               pshs      u,x
                    lbsr      L5E35
                    cmpx      #$0000
                    beq       L5EA0
                    ldu       4,x
                    leau      d,u
                    stu       4,x
L5EA0               puls      pc,u,x

L5EA2               pshs      x,d
                    lbsr      L5E35
                    cmpx      #$0000
                    beq       L5EB0
                    clra
                    clrb
                    std       ,x
L5EB0               puls      pc,x,d

L5EB2               pshs      u,y,x,d
                    ldx       #$2C24              Point to table of 20 six byte entries
L5EB7               ldy       ,x                  Get address ptr from tbl
                    beq       L5EDE               Empty, skip ahead
                    ldd       4,x                 Get counter
* 6809/6309 - redundant, remove cmpd
                    cmpd      #$0000              Is that value empty or negative?
                    ble       L5EDE               yes, skip ahead
                    subd      #$0001              If not, dec by 1 and save back
                    std       4,x
                    bne       L5EDE               If still not 0, skip ahead
* 6809/6309 - use <L5EDA,pc
                    leau      >L5EDA,pc           Point to routine
                    pshs      u                   Save address to it on stack
                    leay      >$01B2,y            Add $1B2 to address ptr
                    pshs      y                   Save on stack
                    ldd       2,x                 Get ??? value
                    rts                           Return to address on Y

L5EDA               clra                          Force address to 0
                    clrb
                    std       ,x
L5EDE               leax      6,x                 Point to next entry
                    cmpx      #$2C9C              Done checking all 20?
                    bne       L5EB7               No, keep checking
                    puls      pc,u,y,x,d

* '.' (rest command)
L5EE7               pshs      u,y,x,d
                    lda       >$10EB              Get players rank
                    sta       >$2C9C              Save copy
                    ldd       >$10ED              Get players current hit points
                    std       >$2C9D              Save copy
                    inc       >$0DA2
                    lda       >$2C9C              Get copy of players rank again
                    cmpa      #8                  Is rank at least 8 (I think Champion)?
                    bhs       L5F12               Yes, skip ahead
                    lsla
                    adda      >$0DA2
                    cmpa      #$14
                    bls       L5F2B
                    ldd       >$10ED
                    addd      #$0001
                    std       >$10ED
                    bra       L5F2B

L5F12               lda       >$0DA2
                    cmpa      #$03
                    blo       L5F2B
                    ldb       >$2C9C
                    subb      #$07
                    clra
                    lbsr      L6396
                    addd      #$0001
                    addd      >$10ED
                    std       >$10ED
* 6809/6309 - ldd #$0009
L5F2B               lda       #$00                Check if player wearing Regeneration ring on left hand
                    ldb       #$09
                    lbsr      L3BE8
                    tsta
                    beq       L5F3E
                    ldd       >$10ED
                    addd      #$0001
                    std       >$10ED
* 6809/6309 - ldd #$0009
L5F3E               lda       #$01                Check if player wearing Regeneration ring on right hand
                    ldb       #$09
                    lbsr      L3BE8
                    tsta
                    beq       L5F51
                    ldd       >$10ED
                    addd      #$0001
                    std       >$10ED
L5F51               ldd       >$10ED
                    cmpd      >$2C9D
                    beq       L5F69
                    cmpd      >$10F1
                    bls       L5F66
                    ldd       >$10F1
                    std       >$10ED
L5F66               clr       >$0DA2
L5F69               puls      pc,u,y,x,d

L5F6B               pshs      u,y,x,d
                    ldu       #L5F77+PrgOffst-$1B2 (#$BDC5)
                    clra
                    clrb
                    lbsr      L5E48
                    puls      pc,u,y,x,d

L5F77               pshs      u,y,x,d
                    inc       >$2C9F
                    lda       #3                  RND(3)
                    lbsr      L63A9
                    adda      #$03
                    cmpa      >$2C9F
                    blo       L5FA9
                    lda       #6                  RND(6)
                    lbsr      L63A9
                    tsta
                    bne       L5FA6
                    lbsr      L2B0E
                    ldu       #L5F77+PrgOffst-$1B2 (#$BDC5)
                    lbsr      L5EA2
                    ldu       #L5F6B+PrgOffst-$1B2 (#$BDB9)
* 6809/6309 - could use clra/clrb to save a byte
                    ldd       #$0000
                    ldy       #$0046
                    lbsr      L5E82
L5FA6               clr       >$2C9F
L5FA9               puls      pc,u,y,x,d

L5FAB               pshs      u,y,x,d
                    ldd       >$10E4
                    anda      #$FE
                    andb      #$FF
                    std       >$10E4
                    ldu       #$2CA0              'you feel less confused now'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    puls      pc,u,y,x,d

L5FC3               pshs      u,y,x,d
                    ldx       >$10F9
L5FC8               cmpx      #$0000
                    beq       L5FF3
                    ldd       #$0010
                    lbsr      L3C3C
                    tsta
                    beq       L5FEE
                    lbsr      L25F0
                    tsta
                    beq       L5FEE
                    lda       9,x
                    cmpa      <$0040
                    beq       L5FEE
                    lda       5,x
                    ldb       4,x
                    std       >$355B
                    lda       9,x
                    lbsr      L6612
L5FEE               ldx       ,x
                    bra       L5FC8

L5FF3               ldd       >$10E4
                    anda      #$F7
                    andb      #$FF
                    std       >$10E4
                    puls      pc,u,y,x,d

L5FFF               pshs      u,y,x,d
                    ldx       #$10D8
                    ldd       #$0001
                    lbsr      L3C3C
                    tsta
                    beq       L6033
                    ldu       #L5FFF+PrgOffst-$1B2 (#$BE4D)
                    lbsr      L5EA2
                    ldd       >$10E4
                    anda      #$FF
                    andb      #$FE
                    std       >$10E4
                    lda       8,x
                    anda      #$02
                    bne       L6029
                    ldx       #$10DC
                    lbsr      L0E36
L6029               ldu       #$2CBB              'the veil of darkness lifts'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
L6033               puls      pc,u,y,x,d

L6035               pshs      u,y,x,d
                    ldd       >$10E4
                    anda      #$BF
                    andb      #$FF
                    std       >$10E4
                    ldu       #$2CD6              'you feel yourself slowing down'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    puls      pc,u,y,x,d

* Food consumption status/update
L604D               pshs      u,y,x,d
                    ldd       >$0DA4              Get current food level
* 6809/6309 - redundant, remove CMPD
                    cmpd      #$0000
                    bgt       L60A9               If positive, skip ahead
* 6809/6309 - couldn't this be ldd #-352 for next two lines?
                    ldd       #$0000
                    subd      #$0352
                    cmpd      >$0DA4              Compare to current food level
                    ble       L6069               If current food level >=-352, skip ahead
                    lda       <$0073              ??? middle of a string? 'o' (cause of death?)
                    lbsr      L0716               Player has died sequence (should never return from there)
L6069               tst       >$0D98
                    bne       L6076
                    lda       #5                  RND(5) 0-5
                    lbsr      L63A9
                    tsta
                    beq       L6078               If RND was 0, skip ahead, otherwise return
L6076               puls      pc,u,y,x,d

* Player has eaten to much and is
L6078               lda       #8                  RND(8) 0-8
                    lbsr      L63A9
                    adda      #4                  Now 4-12
                    adda      >$0D98              Add to # of turns paralized for starving or overfull
                    sta       >$0D98              Save it back
* 6809/6309 - can likely change to ldb >$10E5 / andb #$FB / stb >$10E5
                    ldd       >$10E4              Get player status flags
                    anda      #%11111111          $FF
                    andb      #%11111011          $FB Clear bit 3 (player is now paralyzed)
                    std       >$10E4              Save flags
                    clr       >$063C
                    clr       >$0D9E              Clear # of repeats for player command (in case we were doing that)
                    lbsr      L43D1               Clear # of repeats in lower right corner of screen
                    lda       #3
                    sta       >$0DA7
                    ldu       #$2CF7              'you feel very weak'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    bra       L6110

* Part of food consumption algorithm - if food value>0
L60A9               ldd       >$0DA4
                    std       >$2CF5
* 6809/6309 - clra - carry not needed in L9607 entry
                    lda       #$00
                    lbsr      L9607
                    pshs      a
                    lda       #1
                    lbsr      L9607
                    adda      ,s+
                    adda      #1
                    tfr       a,b
                    clra
                    pshs      d
                    ldd       >$0DA4              Get how long is left for current food level
                    subd      ,s++                Subtract
                    std       >$0DA4              Save new value
                    ldd       #150                Down to 150?
                    cmpd      >$0DA4
                    ble       L60EC               If >150, skip ahead
                    cmpd      >$2CF5              ???
                    bgt       L60EC
                    lda       #2                  Notifiy player that they are starting to get weak
                    sta       >$0DA7
                    ldu       #$2D27              'you are starting to feel weak'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    bra       L6110

* Part of food consumption algorithm
* 6809/6309 - chg 3 lines to ldd #300
L60EC               ldd       #150
                    ldu       #2
                    lbsr      L3CCE               D=D*U
                    cmpd      >$0DA4
                    ble       L6110
                    cmpd      >$2CF5
                    bgt       L6110
                    lda       #$01
                    sta       >$0DA7
                    ldu       #$2D45              'you are starting to get hungry'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
L6110               puls      pc,u,y,x,d

* Remove item from backpack inventory
* Entry: U=ptr to object block (usually root of backpack list)
*        X=ptr to object block to remove
* Exit: Updates linked list ptrs (both for next and previous item) to remove item
L6112               pshs      u,d
                    cmpx      ,u                  Is the item to remove the first one in the backpack?
                    bne       L611C               No, skip ahead
                    ldd       ,x                  Yes, get ptr to next item
                    std       ,u                  Save as new root item in backpack
L611C               ldd       2,x                 Get ptr to previous item
                    beq       L6126               If none, skip ahead
                    ldd       ,x                  Get ptr to next item
                    ldu       2,x                 Get ptr to previous item
                    std       ,u                  Save next item ptr overtop old previous item ptr
L6126               ldd       ,x                  Get ptr to next item
                    beq       L6130               Done list, skip ahead
                    ldd       2,x                 Get ptr to previous item
                    ldu       ,x                  Get ptr to next item
                    std       2,u                 Save old previous ptr into new next item previous ptr
L6130               clra                          Zero out both next and previous item ptrs in deleted object
                    clrb
                    std       ,x
                    std       2,x
                    puls      pc,u,d

L6138               pshs      y,d
                    clra
                    clrb
                    ldy       ,u
                    beq       L6148
                    sty       ,x
                    stx       2,y
                    bra       L614A

L6148               std       ,x
L614A               std       2,x
                    stx       ,u
                    puls      pc,y,d

L6150               pshs      u,d
L6152               ldu       ,x
                    beq       L615F
                    ldd       ,u
                    std       ,x
                    bsr       L61A0
                    bra       L6152

* 6809/6309 - puls pc,u,d
L615F               puls      u,d
                    rts

* Get next free inventory entry, and clear first 4 bytes of it if one was found
* Exit: X=0 (no spaces left in inventory) or X=ptr to entry (31 bytes/entry)
L6162               pshs      d
* 6809/6309 - L6174 ONLY called from here - embed
                    bsr       L6174               Get ptr to next free inventory entry
                    cmpx      #$0000              None left?
                    beq       L6172               Yes, exit
                    clra
                    clrb
                    std       2,x                 Clear first 4 bytes of inventory entry & return
                    std       ,x
L6172               puls      pc,d

* Find next free inventory entry for player
* Entry: None
* Exit: X=ptr to next free entry (and 'used' flag for entry is set to 1)
*       OR X=0 if inventory is full already
L6174               pshs      u,d
                    ldx       #$5E1C              Point to start of inventory flags tbl
                    clra
L617A               tst       ,x                  Anything in this inventory entry?
                    bne       L6194               Yes, skip to next inventory entry
                    inc       >$0D9B              ? Bump up # of active inventory items by 1?
                    inc       ,x                  Flag inventory that we now have something for this entry
                    ldb       #31                 31 bytes/entry
                    mul                           Multiply by entry #
                    addd      #$5944              Offset into table
                    tfr       d,x
                    ldu       #31                 31 bytes to clear
                    clra                          Clear with NUL's
                    lbsr      L402B               Go clear current tbl entry
                    puls      pc,u,d              Return with X pointing to now empty entry (flagged to be used)

L6194               leax      1,x                 Point to next entry
                    inca                          Bump up inventory entry #
                    cmpa      #40                 Are we done all 40 (max 40 inventory items)?
                    blo       L617A               No, check next
                    ldx       #$0000              Return with X=0 (no room left)
                    puls      pc,u,d

L61A0               pshs      x,d
                    stu       >$2D64
                    ldx       #$5944
                    clra
L61A9               cmpx      >$2D64
                    bne       L61B8
                    dec       >$0D9B
                    ldx       #$5E1C
                    clr       a,x
                    puls      pc,x,d

L61B8               leax      <$1F,x
                    inca
                    cmpa      #40
                    blo       L61A9
                    puls      pc,x,d

L61C2               pshs      u,y,x,b
* 6809/6309 - BSR
                    lbsr      L622D
                    tst       [>$1471]
                    beq       L61D7
                    ldx       >$1471
                    lda       ,x+
                    stx       >$1471
                    puls      pc,u,y,x,b

L61D7               lbsr      L6310
                    tsta
                    bne       L61E6
L61DD               lbsr      L632D               Go check for keypress
                    tsta                          Key pressed?
                    beq       L61DD               No, try again
L61E6               ldx       #$2D66              Point to ??? buffer
L61E9               cmpa      ,x                  Key press the same as char stored there?
                    beq       L61F3               Yes, skip ahead
                    tst       ,x++
                    bne       L61E9
                    puls      pc,u,y,x,b

L61F3               lda       1,x                 Get 2nd byte entry and return
L61F5               puls      pc,u,y,x,b

L61F7               pshs      u,y,x,b
* 6809/6309 - BSR
                    lbsr      L622D
                    tst       [>$1471]
                    beq       L620C
                    ldx       >$1471
                    lda       ,x+
                    stx       >$1471
                    puls      pc,u,y,x,b

L620C               lbsr      L6310
                    tsta
                    bne       L621B
L6212               lbsr      L632D               Go check for keypress
                    tsta
                    beq       L6212
L621B               puls      pc,u,y,x,b

L621D               pshs      d
                    ldd       #$1470
                    std       >$1471
                    lda       >$2DDE
                    sta       >$2DDD
                    puls      pc,d

L622D               pshs      d
                    lbsr      L632D               Check for keypress
                    tsta                          Key pressed?
                    beq       L624D               No, skip ahead
                    cmpa      #$1A                Yes, <CTRL-Z>?
                    bne       L6248
                    clr       >$0639
                    clr       >$063C
                    clr       >$0D9E
                    lbsr      L43D1
* 6809/6309 - BSR
                    lbsr      L621D
L6248               lbsr      L62F4
                    bra       L6266

L624D               inc       >$2D73
                    lda       >$2D73
                    cmpa      #$80
                    blo       L6266
                    clr       >$2D73
                    lbsr      L3B6E
                    adda      >$2DE0
                    sta       >$2DE0
                    lbsr      L6362
L6266               puls      pc,d

* Routine to read a full string from the keyboard, one key at a time (like players name, naming an item)
* Entry: X=keyboard buffer ptr
*        A=Max # of chars to read
L6268               pshs      u,y,x,b
                    lbsr      L6421               Write 2 bytes @ u2DEF to the screen
                    sta       >$2D74              Save max # chars allowed
                    clr       >$2D77              Clear # chars read so far
                    stx       >$2D75              Save ptr within keyboard buffer
                    clr       ,x                  NUL for first char
                    lbsr      L6421               Write out two chars @ u$2DEF to screen
L627B               lbsr      L632D               Check for keypress
                    tsta                          Any pressed?
                    beq       L627B               No, try again

L6284               cmpa      #$1A                <CTRL-Z>?
                    bne       L629B
L6288               cmpx      >$2D75
                    beq       L6297
* 6809/6309 - BSR
                    bsr       L62DB
                    dec       >$2D77
                    leax      -1,x
                    bra       L6288

L6297               clr       ,x
                    bra       L62D6

L629B               cmpa      #$08                Left arrow?
                    bne       L62AE               No, check for next special key
                    cmpx      >$2D75
                    beq       L627B
                    bsr       L62DB               Go write out NUL terminated string @ u2DC8
                    dec       >$2D77              Dec size of string
                    leax      -1,x                Move ptr back one in keyboard buffer
                    bra       L627B               Go check for key again

L62AE               cmpa      #$0D                CR?
                    bne       L62B6
                    clr       ,x
                    bra       L62D6

L62B6               cmpa      #$20                Space or other printable character?
                    bhs       L62BF               Yes, go do
                    lbsr      L4039               Some other ctrl char; go beep at user (hard coded DAC sound)
                    bra       L627B

L62BF               ldb       >$2D77
                    cmpb      >$2D74
                    blo       L62CC
                    lbsr      L4039               Make sound
                    bra       L627B

L62CC               sta       ,x+                 Save char in buffer
                    lbsr      L6CF5               Also write it to the screen
                    inc       >$2D77
                    bra       L627B

L62D6               lbsr      L6430
                    puls      pc,u,y,x,b

L62DB               pshs      u,y,x,d
                    ldx       #$2DC8
                    lbsr      L6D07               Write out string @ X (NUL terminated)
                    puls      pc,u,y,x,d

L62E5               pshs      d
                    sta       >$2DCC
L62EA               lbsr      L61C2
                    cmpa      >$2DCC
                    bne       L62EA
                    puls      pc,d

L62F4               pshs      x,b
                    ldb       >$2DDD
                    incb
                    cmpb      #$10
                    blo       L62FF
                    clrb
L62FF               cmpb      >$2DDE
                    bne       L6306
                    puls      pc,x,b

L6306               stb       >$2DDD
                    ldx       #$2DCD
                    sta       b,x
                    puls      pc,x,b

L6310               pshs      x,b
                    ldb       >$2DDE
                    cmpb      >$2DDD
                    bne       L631D
                    clra
                    puls      pc,x,b

L631D               incb
                    cmpb      #$10
                    blo       L6323
                    clrb
L6323               stb       >$2DDE
                    ldx       #$2DCD
                    lda       b,x
                    puls      pc,x,b

* Get key in input buffer.
* Exit: A=0 means no key pressed, CTRL-Z if ABORT or EXIT (CTRL C/E), otherwise
*       key itself.
L632D               pshs      y,x,b
                    inc       >$2DE0
                    clra
                    ldb       #SS.Ready
                    os9       I$GetStt
                    bcc       L633D               Data ready on keyboard, skip ahead
                    ldx       #1                  Remainder of current time slice
                    os9       F$Sleep             Put Rogue to sleep for remaining time slice, to wait for another key
                    clra                          Otherwise exit
                    puls      pc,y,x,b

* Key in keyboard buffer
L633D               clra                          Read char from keyboard
                    ldx       #$2DDF
                    ldy       #$0001
                    os9       I$Read
                    lda       >$2DDF              Get char
                    adda      >$2DE0              Add to ??? and store back
                    sta       >$2DE0
                    lda       >$2DDF              Get original key back
                    cmpa      #$03                <CTRL-C>?
                    beq       L635E               Yes, skip ahead
                    cmpa      #$05                <CTRL-E>?
                    beq       L635E               Yes, skip ahead
                    puls      pc,y,x,b            Otherwise return with key in A

L635E               lda       #$1A                If abort or Exit, change to <CTRL-Z>
                    puls      pc,y,x,b

* This is called * A LOT * when initializing a level - like hundreds of times
* I think it is part of the random # seed generator
L6362               pshs      x,d
                    ldx       #$2DE0              Point to start of buffer
                    ldb       ,x                  Get first byte in buffer
L636A               lda       1,x                 Get next byte, add to previous
                    adda      ,x
                    sta       ,x+                 Save as new previous & bump ptr
                    cmpx      #$2DEC              Done buffer?
                    bne       L636A               No, keep going
                    addb      ,x                  Add original first byte to last
                    stb       ,x                  Save in last position
                    ldd       >$2DE0              Bump up 1st two seeds
                    inca
                    addb      #2
                    std       >$2DE0
                    ldd       >$2DE2
                    adda      #3
                    addb      #5
                    std       >$2DE2
                    puls      pc,x,d

* Take 16 bit contents of >$2DE0 and divide by D
* Entry: D=# to divide by
* Exit:  D=Remainder of divide, RND seed updated
L6396               pshs      u
                    cmpd      #$0000              Are we trying to divide by 0?
                    beq       L63A7               Yes, just exit
                    ldu       >$2DE0              Get # to divide into
                    lbsr      L3C5C               U=U/D (remainder in D)
                    bsr       L6362               Update RND seed generator (leaves D remainder alone)
L63A7               puls      pc,u                Return with D having the remainder

* I think this is the 8 bit random number generator.
* Entry: A=highest # to generate
* Exit:  A=Random number (0 to original A)
L63A9               pshs      b
                    tsta                          If RND range is 0 to 0, then just exit with A=0
                    beq       L63B9
                    ldb       >$2DE0
                    lbsr      L3CA4               B/A
                    tfr       b,a                 Move remainder to A
                    bsr       L6362
L63B9               puls      pc,b

* Entry: A=Ctr for loop
*        B=8 bit unsigned # to divide by
*        >$2DE0 16 bit number to divide into
* Exit: If A=0 on entry, exit with D=0
*       D=# based on repeated divides of >$2DE0 by B, adding remainders of them together.
* ($2DE0 appears to be the first part of the seeding data)
L63BB               tsta                          If A=0, exit with B=0 as well
                    bne       L63C1
                    clrb
                    rts

L63C1               std       >$2DED              Save ctr and divisor
                    clra                          Init stack to 0
                    clrb
* 6809/6309 - could pshs d outside of loop, and std ,s in loop (2 cyc faster). and addd ,s++ below
* becomes just addd ,s. Would need to add leas 2,s before rts, though.
L63C9               pshs      d                   Save value
                    clra                          D=16 bit of original B from caller - Divisor for divide routine
                    ldb       >$2DEE
                    bsr       L6396               Do >$2DE0 (16 bit) divided by D (returns with D=remainder of divide)
                    addd      #$0001              Add 1 to remainder
                    addd      ,s++                Add to D on stack
                    dec       >$2DED              dec ctr
                    bne       L63C9               Keep doing until done
                    rts

L63DD               pshs      u,y,x,d
                    clra
                    ldb       #SS.ScSiz
                    os9       I$GetStt            Get current screen size
* 6809 note: Could do sty >$37CB / tfr x,d / stb $37CB instead of next 4 lines.
                    tfr       x,d                 Move X size to D
                    stb       >$37CB              Save copy
                    tfr       y,d                 Move Y size to D
                    stb       >$37CC              Save copy
                    lbsr      L6D6F
                    bsr       L6430
                    lbsr      L6D30
                    lbsr      L6C3B
                    lbsr      L6A96
                    clra
                    clrb
                    lbsr      L6CDE               CurXY to b,a
                    puls      pc,u,y,x,d

L6405               pshs      u,y,x,d
                    lbsr      L6869               Init a lot of window X,Y coords (where map displays, status lines, etc.)
                    clra
                    clrb
                    std       >$355B
                    puls      pc,u,y,x,d

L6411               pshs      u,y,x,d
                    lbsr      L6D6F
                    lbsr      L6C1D
                    lbsr      L6AA2
                    lbsr      L66EE
                    puls      pc,u,y,x,d

* Write 2 bytes @ >$2DEF to screen
* 6809/6309 - Don't think we need to save U here.
L6421               pshs      u,y,x,d
                    ldx       #$2DEF
                    ldy       #$0002
                    clra
                    os9       I$Write
                    puls      pc,u,y,x,d

* Write 2 bytes @ >$2DF1 to screen
* 6809/6309 - Don't think we need to save U here.
L6430               pshs      u,y,x,d
                    ldx       #$2DF1
                    ldy       #$0002
                    clra
                    os9       I$Write
                    puls      pc,u,y,x,d

L643F               pshs      x,d
                    sta       >$2E11
                    lbsr      L3F32
                    tsta
                    beq       L6452
                    ldd       #$2000
                    std       >$2E05
                    bra       L648E

L6452               lda       >$2E11
                    lbsr      L3F46
                    tsta
                    bne       L6487
                    ldb       >$2E11
                    cmpb      #$20
                    bhs       L6475
                    addb      #$40
                    pshs      b
                    ldu       #$2E12              '^%c'
                    pshs      u
                    ldx       #$2E05
                    lbsr      L3D23
                    leas      3,s
                    bra       L648E

L6475               clra
                    pshs      d
                    ldu       #$2E16              '<asc> %d>'
                    pshs      u
                    ldx       #$2E05
                    lbsr      L3D23
                    leas      4,s
                    bra       L648E

L6487               lda       >$2E11
                    clrb
                    std       >$2E05
L648E               ldu       #$2E05
                    puls      pc,x,d

L6493               pshs      u
                    ldu       #$2DF9              '****|-      '
* 6809/6309 - BSR
                    lbsr      L649D
                    puls      pc,u

L649D               pshs      u,y,x,d
                    sty       >$2E20
                    stx       >$2E22
                    ldd       >$2E20
                    incb
                    lbsr      L6CDE               CurXY to b,a
                    lda       5,u
                    ldb       >$2E23
                    subb      >$2E21
                    decb
                    stb       >$2E1F
* 6809/6309 - BSR
                    lbsr      L6532
                    lda       >$2E22
                    ldb       >$2E21
                    incb
                    lbsr      L6CDE               CurXY to b,a
                    lda       5,u
                    ldb       >$2E1F
                    lbsr      L6532
                    lda       >$2E20
                    inca
                    sta       >$2E1F
L64D5               lda       >$2E1F
                    cmpa      >$2E22
                    bhs       L64FE
                    lda       >$2E1F
                    ldb       >$2E21
                    lbsr      L6CDE               CurXY to b,a
                    lda       4,u                 Get char
                    lbsr      L6CF5               Write to screen
                    lda       >$2E1F
                    ldb       >$2E23
                    lbsr      L6CDE               CurXY to b,a
                    lda       4,u                 Get char
                    lbsr      L6CF5               Write to screen
                    inc       >$2E1F
                    bra       L64D5

L64FE               ldd       >$2E20
                    lbsr      L6CDE               CurXY to b,a
                    lda       ,u                  Get char
                    lbsr      L6CF5               Write to screen
                    lda       >$2E20
                    ldb       >$2E23
                    lbsr      L6CDE               CurXY to b,a
                    lda       1,u                 Get char
                    lbsr      L6CF5               Write to screen
                    lda       >$2E22
                    ldb       >$2E21
                    lbsr      L6CDE               CurXY to b,a
                    lda       2,u                 Get char
                    lbsr      L6CF5               Write to screen
                    ldd       >$2E22
                    lbsr      L6CDE               CurXY to b,a
                    lda       3,u
                    lbsr      L6CF5
                    puls      pc,u,y,x,d

L6532               pshs      x,b
                    ldx       #$4B34
L6537               sta       ,x+
                    decb
                    bne       L6537
                    clr       ,x
                    ldx       #$4B34
                    lbsr      L6D07               Write out string @ X (NUL terminated)
                    puls      pc,x,b

L6546               pshs      u,y,x,d
                    lbsr      L6D6F
                    lda       >$37CC
                    ldb       >$37CB
                    lbsr      L3CA4               B/A
                    sta       >$2E29              Save result (discard remainder)
                    lda       #2
                    ldb       >$37CC
                    lbsr      L3CA4               B/A (B/2 in this case)
                    sta       >$2E2A              Save result
                    lda       >$37CE
                    sta       >$2E27
                    clr       >$2E25
                    lda       #1
                    sta       >$2E26
                    lda       >$37CD
                    deca
                    sta       >$2E28
L6577               lda       >$2E25
                    cmpa      >$2E2A
                    bcc       L65DA
                    ldd       >$2E25
                    lbsr      L6CDE               CurXY to b,a
                    lda       #$2A                Write '*' to screen
                    lbsr      L6CF5
                    lda       >$2E25
                    ldb       >$2E28
                    lbsr      L6CDE               CurXY to b,a
                    lda       #$2A                Write '*' to screen
                    lbsr      L6CF5
                    lda       >$2E27
                    ldb       >$2E26
                    lbsr      L6CDE               CurXY to b,a
                    lda       #$2A                Write '*' to screen
                    lbsr      L6CF5
                    ldd       >$2E27
                    lbsr      L6CDE               CurXY to b,a
                    lda       #$2A                Write '*' to screen
                    lbsr      L6CF5
                    lbsr      L3BAB               approx .045 sec time delay (counting both). F$Sleep 2 or 3 ticks instead
                    lbsr      L3BAB
                    inc       >$2E25
                    lda       >$2E26
                    adda      >$2E29
                    sta       >$2E26
                    dec       >$2E27
                    lda       >$2E28
                    suba      >$2E29
                    sta       >$2E28
* 6809/6309 - BRA
                    lbra      L6577

L65DA               lbsr      L6D6F
                    puls      pc,u,y,x,d

* Get object character from map #1 (map known to player)
* Exit: A=char found at that location (translated for non-rogue font if we are not using rogue gfx font)
L65E6               pshs      x,b
                    lda       >$355B              Get Y coord we are currently drawing map for
                    ldb       #80                 80 chars per row in map
                    mul                           Calc offset to specific map line # we want
                    addd      #$2E2B              Offset to map buffer of map known to player
                    tfr       d,x                 Move to indexable register
                    ldb       >$355C              Get X coord we are currently drawing map for
                    abx                           Offset to that specific location
                    lda       ,x                  Get object #(wall, object, etc.)
                    tst       >$3571              Are we using the rogue gfx font?
                    bne       L6610               Yes, return with that char ($C1-$D7)
                    ldx       #$35A6              No, point to ASCII translation table for regular fonts
                    ldb       #$C1                Current gfx char we are checking
L6603               cmpa      ,x+                 Is object char matching table entry?
                    beq       L660E               Yes, copy gfx CHR$ to A and exit
                    incb                          No, bump to next gfx char
                    cmpb      #$D8                Are we done checking the whole translation table?
                    blo       L6603               No, keep checking
                    puls      pc,x,b              Yes, exit without changing char at all

L660E               tfr       b,a                 Copy gfx char to A & return
L6610               puls      pc,x,b

* Entry: A=map char from map 2 ($4B84) - I think the full walls/doors map
L6612               pshs      u,y,x,d
                    cmpa      #$20                Is it a control char?
                    lblo      L66D8               Yes, that is illegal, report as such.
                    sta       >$356D              No, save copy
                    bpl       L662E               If 32-127, skip ahead
                    tst       >$3571              Are we using the rogue gfx font?
                    bne       L662E               Yes, skip translating the character
                    suba      #$C1                No, change char to offset in ASCII translation table
                    ldx       #$35A6              Point to ASCII text map conversion tbl
                    lda       a,x                 Get ASCII converted character (hardware text mode)
                    sta       >$356D              Save char
L662E               lda       >$10DC              Get X coord
                    cmpa      >$3561              Same as working X coord?
                    blo       L6648
                    cmpa      >$3562
                    bhi       L6648
                    lda       >$10DD
                    cmpa      >$3563
                    blo       L6648
                    cmpa      >$3564
                    bls       L664E
L6648               lbsr      L678B
                    lbsr      L66EE
L664E               lda       >$355C
                    cmpa      >$355D
                    blo       L66A7
                    cmpa      #80
                    bhi       L66C0
                    cmpa      >$355E
                    bhi       L66A7
                    lda       >$355B              Get Y coord for flag map
                    cmpa      >$355F              Compare with Y coord in viewable map
                    blo       L66A7               If lower, skip ahead
                    cmpa      #23                 If Y coord>23, report error
                    bhi       L66C0
                    cmpa      >$3560
                    bhi       L66A7
                    lda       >$355B              Get Y coord (flag map?)
                    ldb       #80                 Multipley by 80 chars/line
                    mul
                    addd      #$2E2B              Point into players viewable map
                    tfr       d,x
                    ldb       >$355C              Get X coord (flag map?)
                    abx                           Now pointing to specific char in viewable map
                    lda       >$356D              Get working map character (pre-translated to hardware text if needed)
                    cmpa      ,x                  Is this already drawn on the viewable map?
                    beq       L66BB               Yes, skip drawing it again
                    sta       ,x
                    lda       >$355C              Get X coord
                    suba      >$355D              Subtract X coord for known map
                    ldb       >$355B              Get Y coord
                    subb      >$355F              Subtract Y coord for known map
                    addd      #$2021              Add offsets for CurXY (and +1 for Y coord)
                    std       >$356B              Save for CurXY command
                    clra
                    ldx       #$356A              Point to CurXY buffer
                    ldy       #$0004              Send CurXY command
                    os9       I$Write
                    bra       L66BB

L66A7               lda       >$355B
                    ldb       #80
                    mul
                    addd      #$2E2B
                    tfr       d,x
                    ldb       >$355C
                    abx
                    lda       >$356D
                    sta       ,x
L66BB               inc       >$355C
                    puls      pc,u,y,x,d

* Bad X,Y coord (out of range) - report on screen
L66C0               lda       >$355C
                    pshs      a
                    lda       >$355B
                    pshs      a
                    ldu       #$3572              'addch: bad coords. (%i,%i)'
                    pshs      u
                    lbsr      L68D8
                    leas      4,s
                    puls      pc,u,y,x,d

L66D8               pshs      a
                    ldu       #$358D              'addch: bad chr. (ASC %i)'
                    pshs      u
                    lbsr      L68D8
                    leas      3,s
                    lda       #$20
                    sta       >$356D
                    lbra      L662E

L66EE               pshs      u,y,x,d
                    tst       >$3570
                    bne       L6754
                    lda       >$355F              Get line # on map screen
                    ldb       #80                 * 80 chars/line for map
                    mul
                    addd      #$2E2B              Add to start of current map screen buffer
                    tfr       d,x                 Move to X
                    ldb       >$355D              Get char # on current line on map screen
                    abx
                    ldd       #$2021              Cursor position=0,1
                    std       >$356B              Save for CuyXY
                    clra
                    ldb       >$37CB
                    std       >$35BD
L6711               pshs      x
                    clra
                    ldx       #$356A              Send CurXY command
                    ldy       #$0003
                    os9       I$Write
                    ldx       ,s                  Get back write buffer ptr
                    ldy       >$35BD              Get length to write
                    bsr       L6775
                    leay      ,y
                    beq       L6736               No, skip
                    os9       I$Write
                    cmpy      >$35BD
                    beq       L6740
L6736               ldx       #$3569              Clear to end of Line char
                    ldy       #$0001
                    os9       I$Write             Clear remainder of screen line
L6740               puls      x
                    leax      <80,x
                    inc       >$356C
                    lda       >$356C
                    suba      #$20
                    cmpa      >$356E
                    bls       L6711
                    puls      pc,u,y,x,d

L6754               ldd       #$2021              Cursor position 0,1
                    std       >$356B
                    clra
                    ldx       #$356A              Send CurXY command
                    ldy       #$0003
                    os9       I$Write
                    clra
                    ldx       #$2E2B              Point to buffer of currently known map for player
                    ldy       #$06E0              Size of map (80x22)
                    bsr       L6775               Working from end, find first map char that is "active"
                    os9       I$Write             Write to screen
                    puls      pc,u,y,x,d          Restore regs and return

* Scan from end of known map until first "real" map char (no spaces). This allows
*  us to write only the # of bytes from the top of the map until we don't see
*  anything lower
L6775               pshs      x,d                 Preserve regs
                    pshs      x                   Save known map buffer ptr
                    tfr       y,d                 Move size of known map to D
                    addd      ,s++                Calculate end of map ptr
                    tfr       d,x                 Point to end of map
L677F               lda       ,-x                 Get map char
                    cmpa      #$20                Space (unknown or nothing there)?
                    bne       L6789               No, real map piece, exit
                    leay      -1,y                Dec size
                    bne       L677F               Still more to check, keep going
L6789               puls      pc,x,d

* Init some windowing vars (various X/Y coords).
* 6809/6309 - B never used, so use PSHS A and PULS PC,A. But, we may need to use B to check
*  for 25 line window
L678B               pshs      d
                    lda       >$37CB              Get window width
                    cmpa      #80                 Full 80 width?
                    bne       L679D               No, skip ahead
                    lda       >$37CC              Get window height
                    cmpa      #24                 24 or higher?
                    lbhs      L6846               If full 80x24+ go here (APPEARS TO HAVE FIXED THE UNECESSARY SCROLLING ON 80X25)
L679D               lda       >$10DD              Get ? Y coord
                    suba      >$3566              Subtract (viewable map height-1)/2
                    bpl       L67B8               If positive result, skip ahead
                    clr       >$355F              Clear current Y coord?
                    clr       >$3563
                    lda       >$3565              Get height of viewable map-2
                    sta       >$3560              Save working copy
                    suba      #2                  Subtract 2 more
                    sta       >$3564              Save that copy
                    bra       L67EF

L67B8               adda      >$3565              Add map viewable height-2
* 6809/6309 MAY NEED TO CHECK IF 22, NOT 21, *IF* WINDOW HEIGHT=25
                    cmpa      #21                 If<=21, skip ahead
                    bls       L67D4
                    lda       #21                 Set working copy of view map height to 21
                    sta       >$3560
                    sta       >$3564              Save another working copy
                    suba      >$3565              Subtract another height
                    sta       >$355F
                    adda      #2                  Add 2 and save that
                    sta       >$3563
                    bra       L67EF

L67D4               lda       >$10DD
                    suba      >$3566
                    sta       >$355F
                    adda      #2
                    sta       >$3563
                    suba      #2
                    adda      >$3565
                    sta       >$3560
                    suba      #2
                    sta       >$3564
L67EF               lda       >$10DC
                    suba      >$3568
                    bpl       L680A
                    clr       >$355D
                    clr       >$3561
                    lda       >$3567
                    sta       >$355E
                    suba      #2
                    sta       >$3562
                    bra       L6844

L680A               adda      >$3567              Add window width-1
                    cmpa      #79                 79 or less?
                    bls       L6826               Yes, skip ahead
                    lda       #79                 No, force to 79
                    sta       >$355E
                    sta       >$3562
                    suba      >$3567
                    sta       >$355D
                    adda      #2
                    sta       >$3561
                    bra       L6844

L6826               lda       >$10DC
                    suba      >$3568
                    sta       >$355D
                    adda      #2
                    sta       >$3561
                    suba      #2
                    adda      >$3567
                    sta       >$355E
                    suba      #2
                    sta       >$3562
                    clr       >$3570
L6844               puls      pc,d

L6846               clr       >$355F              Clear Y coord for current known map buffer
                    clr       >$3563
                    lda       #$15
                    sta       >$3560
                    sta       >$3564
                    clr       >$355D              Clear X coord for current known map buffer
                    clr       >$3561
                    lda       #79
                    sta       >$355E
                    sta       >$3562
                    lda       #$01
                    sta       >$3570
                    puls      pc,d

* Entry: A=1 if from main game init (and that appears to be only spot)
L6869               pshs      u,y,x,d
                    pshs      a
                    lda       >$37CC              Get our window height
                    suba      #2                  Subtract 2
                    suba      >$3660              Subtract height adjustment (depending on window width) for status lines @ bottom
                    sta       >$356E              Save height of viewable map area
                    suba      #1                  Subtract 1 more
                    sta       >$356F              Save it
                    deca                          drop 1 more
                    sta       >$3565              save again
                    lda       >$37CB              Get window width
                    deca                          -1
                    sta       >$3567              Save it
                    lda       >$356F              Get viewable map height-1
                    lsra                          Divide by 2
                    sta       >$3566              Save it
                    lda       >$37CB              Get window width again
                    lsra                          Divide by 2
                    sta       >$3568              Save it
                    clr       >$355C              Clear ??? X coord
                    clr       >$355B              Clear ??? Y coord
                    lbsr      L678B               Init some other X,Y coord stuff
                    tst       ,s+                 Test original value of A on entry
                    beq       L68A6               If 0, exit
                    bsr       L68A8               If 1, init map currently known to player first
L68A6               puls      pc,u,y,x,d

* Clear out map viewable by player with spaces (and extra line, so 23x80)
L68A8               pshs      x,d
* 6309 - TFM
                    ldx       #$2E2B+(80*23)      $730+$2E2B Point to end of known to player map (80x23)
                    ldd       #$2020              Fill with spaces
L68B5               std       ,--x                Clear 8 bytes
                    std       ,--x
                    std       ,--x
                    std       ,--x
                    cmpx      #$2E2B              Done entire map?
                    bne       L68B5               No, keep going until done
                    puls      pc,x,d

L68C4               pshs      d
                    std       >$355B
                    tfr       x,d
                    tfr       b,a
                    lbsr      L6612
                    puls      pc,d

L68D2               std       >$355B
                    lbra      L65E6

* Print text message at 0,0
* Entry (stack): 0,s = RTS address
*                2,s = Ptr to text string to print. If $0000, print blank text line
L68D8               tst       [<$02,s]            Is there a legit text ptr?
                    bne       L68EC               Yes, go print
                    pshs      d                   No, preserve D
                    clra                          Cursor X,Y to 0,0
                    clrb
                    lbsr      L6CDE               CurXY to b,a
                    lbsr      L6D78               Clear to end of line
                    clr       >$0D94
                    puls      pc,d

L68EC               stu       >$3642              Save copy of u
* 6809/6309 - wouldn't a puls u be faster & same size?
                    ldu       ,s++                Get/eat RTS address from stack?
                    bsr       L68FD
* 6809/6309 - wouldn't a pshs u be faster & same size?
                    stu       ,--s
                    ldu       >$3642
                    bra       L6927

* Entry: U=RTS address to return to?
L68FD               stx       >$3644
                    stu       >$3646
                    std       >$3648
                    ldx       #$35BF
                    ldb       >$363F
                    abx
* 6809/6309 - wouldn't a puls u be faster & same size?
                    ldu       ,s++
                    lbsr      L3D23
* 6809/6309 - wouldn't a pshs u be faster & same size?
                    stu       ,--s
                    ldx       #$35BF
                    lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    sta       >$363F
                    ldx       >$3644
                    ldu       >$3646
                    ldd       >$3648
                    rts

L6927               pshs      u,x,d
                    tst       >$063D
                    beq       L6937
                    ldx       #$0D0E
                    ldu       #$35BF
                    lbsr      L3FF3
L6937               tst       >$0D94
                    beq       L6955
                    tst       >$364A
                    bne       L6945
                    clra
                    lbsr      L5088
L6945               clr       >$364A
                    clra
                    ldb       >$0D94
                    lbsr      L6CDE               CurXY to b,a
                    ldx       #$364B              ' More '
                    lbsr      L697B
L6955               ldx       #$35BF
                    lda       1,x
                    cmpa      #$29                ')'?
                    beq       L696D
                    lda       ,x
                    lbsr      L3F0A
                    tsta
                    beq       L696D
                    lda       ,x
                    lbsr      L3F5D
                    sta       ,x
L696D               lbsr      L6996
                    lda       >$363F
                    sta       >$0D94
                    clr       >$363F
                    puls      pc,u,x,d

L697B               pshs      u,y,x,d
                    clra
                    ldb       >$3640
                    lbsr      L6CDE               CurXY to b,a
                    lbsr      L6D4C
                    lbsr      L6D07               Write out string @ X (NUL terminated)
                    lbsr      L6D42
L698D               lbsr      L61C2
                    cmpa      #$20                ?Space?
                    bne       L698D
                    puls      pc,u,y,x,d

L6996               pshs      u,y,x,d
                    ldd       #$0000
                    std       >$3654
                    stx       >$3652
L69A1               ldx       >$3654
                    ldy       >$3652
                    lbsr      L6A36
                    ldx       >$3652
                    lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    sta       >$3658
                    sta       >$363F
                    lda       >$3658
                    cmpa      >$3641
                    bls       L6A34
                    ldx       #$3659              ' Cont '
* 6809/6309 - BSR
                    lbsr      L697B
                    ldd       >$3652
                    std       >$3654
L69CB               ldx       >$3652              Get ptr to buffer to check
L69CE               lda       ,x                  Get char?
                    cmpa      #$20                Is it a space?
                    beq       L69DC               Yes, skip ahead
                    leax      1,x                 No, bump ptr
                    tsta                          Was char a NUL?
                    bne       L69CE               no, keep looking
                    ldx       #$0000              Change ptr to 0
L69DC               stx       >$3656              Save ptr
                    ldd       >$3654
                    cmpd      >$3652
                    bne       L6A06
                    ldd       >$3656
                    beq       L69FA
                    clra
                    ldb       >$3641
                    addd      >$3654
                    cmpd      >$3656
                    bhi       L6A06
L69FA               clra
                    ldb       >$3641
                    addd      >$3654
                    std       >$3652
                    bra       L69A1

L6A06               ldd       >$3656
* 6809/6309 - BEQ
                    lbeq      L69A1
                    clra
                    ldb       >$3641
                    addd      >$3654
                    cmpd      >$3656
* 6809/6309 - BLS
                    lbls      L69A1
                    ldx       >$3652
                    lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    cmpa      >$3641
                    lbcs      L69A1
                    ldd       >$3656
                    addd      #$0001
                    std       >$3652
                    bra       L69CB

L6A34               puls      pc,u,y,x,d

L6A36               pshs      u,y,x,d
                    cmpx      #$0000
                    bne       L6A65
                    clra
                    clrb
                    lbsr      L6CDE               CurXY to b,a
                    leax      ,y
                    lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    cmpa      >$3641
                    bls       L6A4F
                    lda       >$3641
L6A4F               sta       >$3640
                    ldb       >$37CB
                    lbsr      L6D87
                    lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    cmpa      >$37CB
                    bhs       L6A94
                    lbsr      L6D78               Clear to end of line
                    bra       L6A94

L6A65               pshs      y
                    cmpx      ,s++
                    bhi       L6A94
                    clra
                    clrb
                    lbsr      L6CDE               CurXY to b,a
                    lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    cmpa      >$3641
                    bls       L6A7B
                    lda       >$3641
L6A7B               sta       >$3640
                    ldb       >$37CB
                    lbsr      L6D87
                    leax      1,x
                    lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    inca
                    cmpa      >$37CB
                    bhs       L6A65
                    lbsr      L6D78               Clear to end of line
                    bra       L6A65

* 6809/6309 - Might be able to share some labels to shrink code (like one below)
L6A94               puls      pc,u,y,x,d

L6A96               pshs      u,y,x,d
                    lda       >$37CB
                    suba      #6
                    sta       >$3641
                    puls      pc,u,y,x,d

* Update status line(s) on bottom of window. NOTE: Depending on window width, not all fields will be displayed
L6AA2               pshs      u,y,x,d
                    lbsr      L622D               Check for keypress, etc.
                    lda       >$0D91              Get dungeon level #
                    cmpa      >$36F7              Same as ???
                    beq       L6ACB               Yes, skip ahead
                    sta       >$36F7              No, set ??? to current dungeon level
                    clra                          0=Dungeon Level field
                    lbsr      L6C95               Go position cursor
                    cmpa      #$FF                Not printing on current window size; skip to next
                    beq       L6ACB
                    ldb       >$0D91              Get current dungeon level
                    clra
                    pshs      d                   Make 16 bit for subroutine
                    ldu       #$3701              'Level:%-2.2d'
                    pshs      u
                    lbsr      L6D16               Print level on screen
                    leas      4,s
L6ACB               ldd       >$10ED              Get players hit points
                    cmpd      >$36FA              If equal to what we have already printed, skip printing again
                    beq       L6B17
                    std       >$36FA              Hit points different than displayed; save new "last displayed" value
                    lda       #1                  1=Hit points field
                    lbsr      L6C95               Go position cursor
                    ldu       >$10F1              Get players max hit points
                    pshs      u                   Save for subroutine
                    ldu       >$10ED              Get players current hit points
                    pshs      u                   Save for subroutine
                    ldu       #$370E              'Hits:%.3d(%.3d)'
                    pshs      u
                    lbsr      L6D16               Go print players hit points
                    leas      6,s                 Eat temp stack
                    ldd       >$10ED              Get players current hit points
                    cmpd      #100                If 3 digits, on to next field
                    bhs       L6B17
                    cmpd      #10                 If 2 digits, add a space
                    bhs       L6B04
                    lda       #$20                If 1 digit, Write space to screen (1st of 2)
                    lbsr      L6CF5
L6B04               lda       #$20                Write space to screen
                    lbsr      L6CF5
                    ldd       >$10F1              Get players max hit points
                    cmpd      #100                If 3 digit, done hit points
                    bhs       L6B17
                    lda       #$20                If 1 or 2, write space to screen
                    lbsr      L6CF5
L6B17               lda       >$10E6              Get players strength
                    cmpa      >$36FD              Same as currently displayed?
                    beq       L6B47               Yes, skip updating
                    sta       >$36FD              No, save last updated strength
                    lda       #2                  2=Strength field
                    lbsr      L6C95               Cursor X,Y to strength field
                    clra
                    ldb       >$10A7              Get players current maximum strength
                    pshs      d                   Save for subroutine
                    ldb       >$10E6              Get players current strength
                    pshs      d                   Save for subroutine
                    ldu       #$371E              'Str:%.2d(%.2d)'
                    pshs      u
                    lbsr      L6D16               Display strength on screen
                    leas      6,s
                    cmpd      #10                 If 2 digits, skip ahead
                    bhs       L6B47
                    lda       #$20                Write space to screen (to wipe out any old)
                    lbsr      L6CF5
L6B47               ldd       >$0D92              Get players gold
                    cmpd      >$36F8              Same as previously displayed?
                    beq       L6B6B               Yes, skip updating
                    std       >$36F8              No, save as "last displayed"
                    lda       #3                  3=Gold
                    lbsr      L6C95               Cursor X,Y for gold
                    cmpa      #$FF                No room for gold on window?
                    beq       L6B6B               Nope, skip to next status field
                    ldu       >$0D92              Get players gold
                    pshs      u                   Save for subroutine
                    ldu       #$372D              'Gold:%-5.5u'
                    pshs      u
                    lbsr      L6D16
                    leas      4,s
L6B6B               ldx       >$0DB1              Get ptr to armor being worn
                    beq       L6B78               None, skip ahead
                    lda       <18,x               Get current armor class
                    bra       L6B7B

L6B78               lda       >$10EC              ??? Get armor class when not wearing armor?
L6B7B               cmpa      >$36FC              Same as last displayed?
                    beq       L6B9B               Yes, skip updating
                    sta       >$36FC              No, save as "last displayed"
                    lda       #4                  4=Armor Class
                    lbsr      L6C95               Cursor X,Y for Armor
                    ldb       >$36FC              Get last displayed armor class
                    subb      #11                 Armor class is inverted from what is display (based on 10, so AC 3 displayed=AC 7)
                    negb                          so flip it properly and save for subroutine
                    sex
                    pshs      d
                    ldu       #$3739              'Armor:%-2.2d'
                    pshs      u
                    lbsr      L6D16
                    leas      4,s
L6B9B               lda       >$10EB              Get player's rank
                    cmpa      >$36FE              Same as last displayed?
                    beq       L6BC5               Yes, skip updating
                    sta       >$36FE              No, save as new "last displayed"
                    lda       #5                  5=Players rank
                    lbsr      L6C95               Cursor X,Y for rank
                    cmpa      #$FF                Window too small to display rank?
                    beq       L6BC5               Yes, skip printing it
                    lda       >$36FE              Get last display rank
                    deca                          Base 0
                    lsla                          2 bytes per ptr
                    ldx       #$0504              Point to tbl of rank names
                    ldd       a,x                 Get ptr to specific rank player is at
                    pshs      d                   Save for subroutine
                    ldu       #$3746              '%-12s'
                    pshs      u
                    lbsr      L6D16               Print it
                    leas      4,s
L6BC5               lda       >$0DA7              Get current hunger status
                    cmpa      >$36FF              Same as last displayed?
                    beq       L6BF2               Yes, skip updating
                    sta       >$36FF              No, save as new "last displayed"
                    lda       #6                  6=hunger status
                    lbsr      L6C95               Cursor X,Y for hunger status
                    cmpa      #$FF                Room for hunger status?
                    beq       L6BF2               Nope, skip printing it
                    ldx       >$36D1              Point to hunger status tbl
                    lbsr      L6D07               Write out string @ X (NUL terminated)
                    lda       #6                  6=hunger status
                    lbsr      L6C95               Cursor X,Y for hunger status again
                    lda       >$0DA7              Get hunger status
                    beq       L6BF2               If 0 (normal), skip ahead
                    lsla                          <>0 means a level of hunger, so *2 since 2 byte ptrs
                    ldx       #$36D1              Base of hunger status text tbl
                    ldx       a,x                 Get ptr to hunger status string (which are spaces,Hungry,Weak,Faint,? in that order)
                    lbsr      L6D07               Write out string @ X (NUL terminated)
L6BF2               lda       >$1527              Get fast mode flag
                    cmpa      >$3700              Same as previous fast mode flag?
                    beq       L6C1B               Yes, don't update
                    sta       >$3700              Save as new "last displayed"
                    lda       #7                  7=Fast Mode
                    lbsr      L6C95               Cursor X,Y for Fast mode
                    tst       >$1527              Fast mode on?
                    beq       L6C15               No, skip ahead to print blank spaces
                    lbsr      L6D4C
                    ldx       #$374C              'Fast'
                    lbsr      L6D07               Write out string @ X (NUL terminated)
                    lbsr      L6D42
                    puls      pc,u,y,x,d

L6C15               ldx       #$3751              '    '
                    lbsr      L6D07               Write out string @ X (NUL terminated)
L6C1B               puls      pc,u,y,x,d

L6C1D               ldd       #$FEFE
                    sta       >$36F7
                    std       >$36F8
                    std       >$36FA
* 6809/6309 - replace next 4 lines with std >$36FD / std >$36FF
                    sta       >$36FD
                    sta       >$36FE
                    sta       >$36FF
                    sta       >$3700
                    lda       #$80
                    sta       >$36FC
                    rts

L6C3B               pshs      u,y,x,d
                    lda       >$37CB              Get # of columns wide window is
                    cmpa      >$3664              Is it smaller than minimum window width?
                    bhs       L6C54               No, continue
                    ldb       >$3664              Get minimum window width into D
                    clra
                    pshs      d                   Put on stack for subroutine call
                    ldu       #$3756              'Rogue will not run in a window less than %d columns wide.CRLF'
                    pshs      u
                    lbsr      L4186               Exit Rogue
* SWI testing trap - should never get here
                    swi

L6C54               lda       >$37CC              Get window height
                    cmpa      #12                 12 or more?
                    bhs       L6C69               yes, proceed
                    ldd       #12                 No, put minimum size on stack for subroutine call
                    pshs      d
                    ldu       #$3792              'Rogue will not run in a window less than %d rows tall.CRLF'
                    pshs      u
                    lbsr      L4186               Exit Rogue
* SWI testing trap - should never get here
                    swi

* At this point, we already know window width >20, so the CMPB loop below will always be B=1
* or higher
L6C69               lda       >$37CB              Get columns wide window is
                    ldx       #$3664              Point to table of 6 widths (used as ranges, as in "up to") - 20,32,40,50,65,80
                    clrb                          Init our position in the tbl (we will never use 0, since width>20 to get here)
L6C70               cmpa      b,x                 Is current width below current entry?
                    blo       L6C7B               yes, skip ahead
                    tst       b,x                 Are we done entire table?
                    beq       L6C7B               yes, skip ahead
                    incb                          No, check next entry
                    bra       L6C70

L6C7B               decb                          Drop tbl entry by 1 (zero based, skipping "under 20" since that is not used)
                    ldx       #$366B              Point to another table based on width entry # above (contains 2,2,2,2,2,1)
                    lda       b,x                 Get table value (height adjustment based on width)
                    sta       >$3660              Save it
                    lda       #8                  Multiple tbl entry by 1 (0 based)
                    mul
                    std       >$3662              Save value *8 (either 8 or 0) (tbl offset)
                    lda       >$37CC              Get window height
                    suba      >$3660              Subtract height adjustment
                    sta       >$3661              Save "usable" height?
                    puls      pc,u,y,x,d

* Used for two tables - To get X,Y coords for the status fields on the bottom. An $FF entry
* for the Y coord means that field will not be printed at the current window size.
* Entry: A=Which status field to print (0=Level, 1=Hit Points, 2=Strength, 3=Gold, 4=Armor,5=Rank,6=Hunger,7=Fast mode)
L6C95               pshs      x,d
                    ldx       >$3662              Get tbl offset value (either 8 or 16)
                    leax      >$3671,x            Point to X coord tbl based on that value
                    ldb       a,x                 Get entry from within 8 byte table block
                    cmpb      #$FF                If $FF, exit with A=$FF (not printing this status field)
                    beq       L6CB5
                    ldx       >$3662              Get value again
                    leax      >$36A1,x
                    lda       a,x
                    adda      >$3661
                    lbsr      L6CDE               CurXY to b,a for current status field
                    puls      pc,x,d

L6CB5               puls      x,d
                    lda       #$FF
                    rts

* Set Foreground color to A. 6808/6309 - U should not need preserved
L6CBA               pshs      u,y,x,d
                    sta       >$37D5
                    clra
                    ldx       #$37D3
                    ldy       #$0003
                    os9       I$Write
                    puls      pc,u,y,x,d

* Set Background color to A 6808/6309 - U should not need preserved
L6CCC               pshs      u,y,x,d
                    sta       >$37D8
                    clra
                    ldx       #$37D6
                    ldy       #$0003
                    os9       I$Write
                    puls      pc,u,y,x,d

* CurXY to B,A
L6CDE               pshs      y,x,d
                    exg       a,b                 Swap Y/X cursor coord we want
                    addd      #$2020              Add $20 to each for CurXY command
                    std       >$37D1              Save ($02 is preloaded from Rogue.dat)
                    clra
                    ldx       #$37D0              Send CurXY
                    ldy       #$0003
                    os9       I$Write
                    puls      pc,y,x,d

* Write 1 char in A to std in (out)
L6CF5               pshs      y,x,d
                    sta       >$37CF
                    clra
                    ldx       #$37CF
                    ldy       #$0001
                    os9       I$Write
                    puls      pc,y,x,d

* Write out string @ X (NUL terminated)
L6D07               pshs      y,x,d
                    lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    tfr       a,b                 Move length to Y
                    clra
                    tfr       d,y
                    os9       I$Write
                    puls      pc,y,x,d

L6D16               stu       >$37D9
                    stx       >$37DB
* 6809/6309 - shouldn't this be PULS u?
                    ldu       ,s++
                    ldx       #$35BF
                    lbsr      L3D23
* 6809/6309 - BSR
                    lbsr      L6D07               Write out string @ X (NUL terminated)
* 6809/6309 - shouldn't this be PSHS u?
                    stu       ,--s
                    ldu       >$37D9
                    ldx       >$37DB
                    rts

* 6809/6309 - change routine to: pshs d / ldd >$37CB / deca / decb / std >$37CD / puls d,pc
L6D30               pshs      a
                    lda       >$37CB
                    deca
                    sta       >$37CD
                    lda       >$37CC
                    deca
                    sta       >$37CE
                    puls      pc,a

* Turn reverse video OFF. Could just ldx #$37DD/ldy #2/clra/os9 I$Write
L6D42               pshs      x
                    ldx       #$37DD
* 6809/6309 - BSR
                    lbsr      L6D07               Write out string @ X (NUL terminated)
                    puls      pc,x

* Turn reverse video ON. Could just ldx #$37E0/ldy #2/clra/os9 I$Write (and share with OFF above
L6D4C               pshs      x
                    ldx       #$37E0
* 6809/6309 - BSR
                    lbsr      L6D07               Write out string @ X (NUL terminated)
                    puls      pc,x

L6D56               pshs      d
                    pshs      a
                    lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    pshs      a
                    ldb       >$37CD
                    subb      ,s+
                    lsrb
                    puls      a
                    lbsr      L6CDE               CurXY to b,a
* 6809/6309 - BSR
                    lbsr      L6D07               Write out string @ X (NUL terminated)
                    puls      pc,d

* Clear our window
L6D6F               pshs      a
                    lda       #$0C                Clear window
* 6809/6309 - BSR after some of the above LBSR's are changed to BSR's
                    lbsr      L6CF5
                    puls      pc,a

* Clear from current cursor position to end of line
L6D78               pshs      a
                    lda       #$04                Clear to EOL
                    lbsr      L6CF5
                    puls      pc,a

L6D81               lbsr      L6CDE               CurXY to b,a
* 6809/6309 - BRA (after above BSR's are replaced)
                    lbra      L6D07

* Write text out - if text <= window width, print whole thing, otherwise just to width of window
L6D87               pshs      y,x,d
                    lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    pshs      a
                    cmpb      ,s+                 ? Is it within width of window?
                    bls       L6D94               Yes, print full string
                    tfr       a,b                 No, set length to width of window instead
L6D94               clra
                    tfr       d,y
                    os9       I$Write
                    puls      pc,y,x,d

L6D9C               pshs      y,x,d
                    ldx       >$10F5              Get ptr to root backpack item
                    ldb       #$61                'a'
L6DA3               cmpx      #$0000              Done looking through backpack list?
                    beq       L6DB8               Yes, skip ahead
                    pshs      b
                    cmpa      ,s+
                    bne       L6DB2
                    leau      ,x
                    bra       L6DBD

L6DB2               incb
                    ldx       ,x
                    bra       L6DA3

L6DB8               stb       ,u
                    ldu       #$0000
L6DBD               puls      pc,y,x,d

* Entry: X=Object block ptr
L6DBF               pshs      u,y,x,d
                    sta       >$37E8              Save special object type (0=gold, 1=food
                    stx       >$37E6              Save object block ptr
                    cmpx      #$0000              No object?
                    bne       L6DE3               Yes, there is, go do
                    ldb       #$01
                    stb       >$37E4
                    lda       >$10DD              ??? Maybe get players y,x?
                    ldb       >$10DC
                    lbsr      L54E5               ??? Maybe check objects y,x?
                    stx       >$37E6              Save ptr to object to remove
* 6809/6309 - chg 2 lines to bne L6DE6/puls pc,u,y,x,d
                    lbeq      L7035               There is none, return
                    bra       L6DE6

L6DE3               clr       >$37E4
L6DE6               ldy       >$10F3
                    lda       8,y
                    anda      #$02
                    bne       L6DF4
                    lda       #$C2
                    bra       L6DF6

L6DF4               lda       #$C3
L6DF6               sta       >$37E3
                    tst       <$15,x
                    beq       L6E5E
                    ldy       >$10F5
                    sty       >$37E9
* 6809/6309 - leay ,y is 2 bytes smaller, same speed
L6E06               cmpy      #$0000
                    beq       L6E5E
                    lda       <$15,x
                    cmpa      <$15,y
                    bne       L6E4E
                    lda       $E,x
                    adda      $E,y
                    sta       $E,y
                    tst       >$37E4
                    beq       L6E3F
                    ldu       #$10F7              Get ptr to root object for current dungeon level
                    lbsr      L6112               Delete object ,X from current level (update linked list)
                    ldb       >$37E3
                    clra
                    tfr       d,x
                    ldb       >$10DC
                    lda       >$10DD
                    lbsr      L68C4
                    lda       >$10DD
                    lbsr      L3CF4
                    lda       >$37E3
                    sta       ,u
L6E3F               ldu       >$37E6              ??? Get ptr to object we are creating?
                    lbsr      L61A0
                    ldx       >$37E9
                    stx       >$37E6
                    lbra      L6FD7

* 6809/6309 - Could ldx [>$37E9] (5+5) -saves 1 cycle & 1 byte
L6E4E               ldx       >$37E9              6 cyc
                    ldx       ,x                  5 cyc
                    stx       >$37E9
                    leay      ,x
                    ldx       >$37E6
                    bra       L6E06

L6E5E               lda       >$0D9A
                    cmpa      #$16
                    blo       L6E72
                    ldu       #$37ED
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbra      L7035

L6E72               ldx       >$37E6              ??? Get ptr to object being created?
                    lda       4,x                 Get object type
                    cmpa      #$CD                Is it a scroll?
                    bne       L6EC5               No, skip ahead
                    lda       $F,x
                    cmpa      #$06
                    bne       L6EC5
                    lda       <$13,x
                    anda      #$08
                    beq       L6EBA
                    ldu       #$10F7              Get ptr to root object in current level
                    lbsr      L6112               Delete object ,x from current level (update linked list)
                    leau      ,x
                    lbsr      L61A0
                    ldb       >$37E3
                    clra
                    tfr       d,x
                    lda       >$10DD
                    ldb       >$10DC
                    lbsr      L68C4
                    lda       >$10DD
                    lbsr      L3CF4
                    lda       >$37E3
                    sta       ,u
                    ldu       #$380B              'the scroll turns to dust as you pick it up'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbra      L7035

L6EBA               ldx       >$37E6
                    lda       <$13,x
                    ora       #$08
                    sta       <$13,x
L6EC5               inc       >$0D9A
                    tst       >$37E4
                    beq       L6EED
                    ldu       #$10F7              Get ptr to root object for current level
                    lbsr      L6112               Delete object ,X from current level (update linked list)
                    ldb       >$37E3
                    clra
                    tfr       d,x
                    lda       >$10DD
                    ldb       >$10DC
                    lbsr      L68C4
                    lda       >$10DD
                    lbsr      L3CF4
                    lda       >$37E3
                    sta       ,u
L6EED               clr       >$37E5
                    ldx       >$37E6
                    ldy       >$10F5
                    sty       >$37E9
* 6809/6309 - leay ,y is 2 bytes smaller, same speed
L6EFB               cmpy      #$0000
* 6809/6309 - change to beq to ldy >$10F5 (L6F1D)
                    beq       L6F17
                    lda       4,x
                    cmpa      4,y
                    beq       L6F17
* 6809/6309 - pretty sure next 3 lines could be replaced by: ldy ,y
                    leax      ,y
                    ldx       ,x
                    leay      ,x
                    sty       >$37E9
                    ldx       >$37E6
                    bra       L6EFB

* 6809/6309 - leay ,y is 2 bytes smaller, same speed
L6F17               cmpy      #$0000
                    bne       L6F46
* 6809/6309 - new label for above branch (skips 2nd cmpy/bne)
L6F1D               ldy       >$10F5
                    sty       >$37E9
* 6809/6309 - leay ,y is 2 bytes smaller, same speed
L6F25               cmpy      #$0000
                    beq       L6F71
                    lda       4,y                 Get object type
                    cmpa      #$CC                Food?
                    bne       L6F71               No, skip ahead
                    sty       >$37EB
* 6809/6309 - pretty sure next 5 lines can be replaced with ldy  ,y
                    pshs      x
                    leax      ,y
                    ldx       ,x
                    leay      ,x
                    puls      x

                    sty       >$37E9
                    bra       L6F25

L6F46               lda       4,x
                    cmpa      4,y
                    bne       L6F71
                    lda       $F,x
                    cmpa      $F,y
                    bne       L6F59
                    lda       #$01
                    sta       >$37E5
                    bra       L6F71

L6F59               sty       >$37EB
* 6809/6309 - pretty sure next 6 lines can be replaced with ldy  ,y / sty >$37E9
                    pshs      x
                    leax      ,y
                    ldx       ,x
                    stx       >$37E9
                    leay      ,x
                    puls      x

* 6809/6309 - leay ,y is 2 bytes smaller, same speed
                    cmpy      #$0000
                    bne       L6F46
* 6809/6309 - leay ,y is 2 bytes smaller, same speed
L6F71               cmpy      #$0000
                    bne       L6F8E
                    ldu       >$10F5
                    bne       L6F81
                    stx       >$10F5
                    bra       L6FD7

L6F81               ldu       >$37EB
                    stx       ,u
                    stu       2,x
                    clr       ,x
                    clr       1,x
                    bra       L6FD7

L6F8E               tst       >$37E5
                    beq       L6FAF
                    lda       4,x                 Get object type
                    lbsr      L3C1B               Check if potion/food/scroll
                    tsta
                    beq       L6FAF               Nope, skip ahead
                    ldy       >$37E9
                    inc       $E,y
                    ldu       >$37E6
                    lbsr      L61A0
                    ldx       >$37E9
                    stx       >$37E6
                    bra       L6FD7

L6FAF               ldx       >$37E9
                    ldx       2,x
                    ldu       >$37E6
                    stx       2,u
                    beq       L6FC8
                    ldx       >$37E6
                    ldu       2,u
                    stx       ,u
                    bra       L6FCE

L6FC8               ldx       >$37E6
                    stx       >$10F5
L6FCE               ldy       >$37E9
                    sty       ,x
                    stx       2,y
L6FD7               ldy       >$10F9
                    sty       >$37E9
* 6809/6309 - leay ,y - same speed, saves 2 cycles
L6FDF               cmpy      #$0000
                    beq       L700C
                    ldu       10,y
                    lda       ,u
                    ldx       >$37E6
                    cmpa      5,x
                    bne       L6FFB
                    lda       1,u
                    cmpa      6,x
                    bne       L6FFB
                    ldd       #$10DC
                    std       10,y
* 6809/6309 - pretty sure next 6 lines can be replaced with ldy  ,y / sty >$37E9
L6FFB               pshs      x
                    leax      ,y
                    ldx       ,x
                    leay      ,x
                    sty       >$37E9
                    puls      x
* If above note works, change to bra L6FE3 (the BEQ L700C)
                    bra       L6FDF

L700C               lda       4,x                 Get object type
                    cmpa      #$D5                Amulet of Yendor?
                    bne       L701A               No, akip ahead
                    lda       #$01                Set both amulet flags (amulet seen and ???)
                    sta       >$0637
                    sta       >$0638
L701A               tst       >$37E8
                    bne       L7035
                    lbsr      L723E
                    pshs      a
                    lda       #1
                    lbsr      L72B6
                    pshs      u
                    ldu       #$3836              'you can now have %s (%c)'
                    pshs      u
                    lbsr      L68D8
                    leas      5,s
L7035               puls      pc,u,y,x,d

* 'I'nventory command?
L7037               pshs      u,y,x,b
                    stx       >$388C
                    sta       >$388E
                    stu       >$388F
                    clr       >$3891
                    lda       #$61                'a'
                    sta       >$38E2
L704A               ldx       >$388C
                    beq       L70BE
                    lda       >$388E
                    beq       L7086
                    cmpa      4,x
                    beq       L7086
                    cmpa      #$FF
                    bne       L706E
                    ldb       4,x
                    cmpb      #$CD
                    beq       L7086
                    cmpb      #$CE
                    beq       L7086
                    cmpb      #$D1
                    beq       L7086
                    cmpb      #$D2
                    beq       L7086
L706E               cmpa      #$CF
                    bne       L7078
                    ldb       4,x
                    cmpb      #$CE
                    beq       L7086
L7078               cmpa      #$D2
                    bne       L70B0
                    lda       <$14,x
                    beq       L70B0
                    lda       <$12,x
                    beq       L70B0
L7086               inc       >$3891
                    lda       >$38E2
                    pshs      a
                    ldd       #$3884              '%c) %%s'
                    pshs      d
                    ldx       #$3892
                    lbsr      L3D23
                    leas      3,s
                    ldx       >$388C
                    clra
                    lbsr      L72B6
                    ldy       #$3892
                    ldd       >$388F
                    lbsr      L7B5E
                    cmpa      #$20                space?
                    bne       L70E2               no, exit
L70B0               inc       >$38E2
                    ldx       >$388C
                    ldx       ,x
                    stx       >$388C
                    bra       L704A

L70BE               tst       >$3891
                    bne       L70DC
                    tst       >$388E
                    bne       L70CF
                    ldu       #$384B              'you are empty handed'
                    pshs      u
                    bra       L70D4

L70CF               ldu       #$3860              'you don't have anything appropriate'
                    pshs      u
L70D4               lbsr      L68D8
                    leas      2,s
                    clra
* 6809/6309 - replace with puls pc,u,y,x,b (same size, saves 3 cycles)
                    bra       L70E2

L70DC               ldd       >$388F
                    lbsr      L7D29
L70E2               puls      pc,u,y,x,b

L70E4               pshs      u,y,x,d
                    cmpa      #$CB                Gold?
                    bne       L7111               No, skip ahead
                    lda       >$10DD
                    ldb       >$10DC
                    lbsr      L54E5
                    cmpx      #$0000              Object being pointed to?
                    beq       L7118               No, exit
                    ldd       <$10,x              Get # of gold pieces
                    lbsr      L7267
                    ldu       #$10F7              Get ptr to root object on current level
                    lbsr      L6112               Remove object ,X from current level (update linked list)
                    leau      ,x
                    lbsr      L61A0
                    ldy       >$10F3
                    clr       6,y
                    puls      pc,u,y,x,d

L7111               ldx       #$0000
                    clra
                    lbsr      L6DBF
L7118               puls      pc,u,y,x,d

* Get ptr to object block that player is acting on.
* Exit: X=ptr to object block, or 0 if none.
L711A               pshs      u,y,d
                    stx       >$3975
                    sta       >$3977
                    clr       >$3980
                    ldu       #$1523              'on'
                    lda       ,u+
                    cmpa      #$73                's'?
                    bne       L714F
                    lda       ,u+
                    cmpa      #$65                'e'?
                    bne       L714F
                    lda       ,u
                    cmpa      #$6C                'l'?
                    bne       L714F
                    ldx       >$3975
                    ldu       #$3969              'eat'
                    lbsr      L3FCD               Compare strings at ,u / ,x
                    tsta
                    beq       L714F
                    ldu       #$396D              'drop'
                    lbsr      L3FCD               Compare strings at ,u / ,x
                    tsta
                    bne       L715B
L714F               ldx       #$1523
                    ldu       #$3972              'on'
                    lbsr      L3FCD               Compare strings at ,u / ,x
                    tsta
                    bne       L7160
L715B               lda       #$01
                    sta       >$3980
L7160               lda       >$05FD
                    sta       >$397F
                    ldu       >$10F5
                    bne       L717B
                    ldu       #$38E3              'you aren't carrying anything'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    ldx       #$0000
                    lbra      L723C

L717B               lda       >$397C
                    sta       >$397A
L7181               tst       >$397F
                    beq       L7195
                    lda       >$397A
                    ldu       #$397B
                    lbsr      L6D9C
                    cmpu      >$397D
                    beq       L71B6
L7195               tst       >$3980
                    beq       L71A1
                    lda       #$2A                '*'
                    sta       >$397A
                    bra       L71B6

L71A1               ldu       >$3975              Ptr to text for Action (drop, throw, etc.)
                    pshs      u
                    ldu       #$3900              'which object do you want to %s? (* for list): '
                    pshs      u
                    lbsr      L68D8               Go print that
                    leas      4,s
                    lbsr      L61F7
                    sta       >$397A
L71B6               clr       >$0D94
                    clr       >$397F
                    clr       >$3980
                    lda       >$397A
                    cmpa      #$2A                '*'?
                    beq       L71CA
                    cmpa      #$3A                ':'?
                    bne       L71EA
L71CA               ldx       >$10F5
                    ldu       >$3975
                    lda       >$3977
                    lbsr      L7037
                    sta       >$397A
                    bne       L71E3
                    clr       >$05FC
                    ldx       #$0000
                    bra       L723C

L71E3               cmpa      #$20                Space?
                    beq       L7181
                    sta       >$397C
L71EA               cmpa      #$1A                <CTRL-Z>?
                    bne       L7200
                    clr       >$05FC
                    ldu       #$1470
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    ldx       #$0000
                    bra       L723C

L7200               lda       >$397A
                    ldu       #$397B
                    lbsr      L6D9C
                    stu       >$3978
                    bne       L7221
                    lda       >$397B
                    deca
                    pshs      a
                    ldu       #$392F              'please specify a letter between 'a' and '%c'
                    pshs      u
                    lbsr      L68D8
                    leas      3,s
                    lbra      L7181

L7221               ldx       >$3975
                    ldu       #$395C              'identify'
                    lbsr      L3FCD               Compare strings at ,u / ,x
                    tsta
                    beq       L7239
                    lda       >$397A
                    sta       >$397C
                    ldx       >$3978
                    stx       >$397D
L7239               ldx       >$3978
L723C               puls      pc,u,y,d

L723E               pshs      u,y,x,b
                    lda       #$61                'a'
                    ldy       >$10F5
* 6809/6309 - leay ,y is 2 bytes smaller, same speed
L7246               cmpy      #$0000
                    beq       L7263
                    pshs      x
                    cmpy      ,s++
* 6809/6309 - change to beq L7265, eliminate bra (let it fall through to L7255)
                    bne       L7255
                    bra       L7265

L7255               inca
* 6809/6309 - pretty sure next 5 lines can be replaced with ldy  ,y
                    pshs      x
                    leax      ,y
                    ldx       ,x
                    leay      ,x
                    puls      x

                    bra       L7246

L7263               lda       #$3F                '?'
L7265               puls      pc,u,y,x,b

L7267               pshs      u,y,x,d
                    std       >$399B
                    ldy       >$10F3
                    lda       8,y
                    anda      #$02
                    beq       L727A
                    lda       #$C3
                    bra       L727C

L727A               lda       #$C2                ? Force object type to Gold?
L727C               sta       >$399A
                    ldd       >$399B
                    addd      >$0D92
                    std       >$0D92
                    ldb       >$399A
                    clra
                    tfr       d,x
                    lda       >$10DD
                    ldb       >$10DC
                    lbsr      L68C4
                    lbsr      L3CF4
                    lda       >$399A
                    sta       ,u
                    ldd       >$399B
* 6809/6309 - Redundant; remove cmpd
                    cmpd      #$0000
                    bls       L72B4
                    pshs      d
                    ldu       #$3981              'you found %u gold pieces'
                    pshs      u
                    lbsr      L68D8
                    leas      4,s
L72B4               puls      pc,u,y,x,d

* Generate string for object
* Entry: A=???
*        X=ptr to object data block
L72B6               pshs      y,x,d
* 6809/6309 - leay ,x is same size, faster
                    leay      ,x                  Point Y to object
                    sta       >$399D
                    lda       $F,y
                    sta       >$399E              Save object sub-type (o_which)
                    ldx       #$4B34              Point to buffer to place string
                    lda       4,y                 Get object type (o_type)
                    cmpa      #$CD                Scroll?
                    bne       L733F               No, check for next type
                    ldb       $E,y                Get quantity
                    cmpb      #1                  If >1, use plural text
                    bne       L72DB
                    ldu       #$399F              'A scroll '
                    lbsr      L3FF3
                    leax      9,x
                    bra       L72ED

L72DB               clra
                    pshs      d                   Save # of scrolls
                    ldu       #$39A9              '%d scrolls '
                    pshs      u
                    lbsr      L3D23               Generate string
                    leas      4,s
                    lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    leax      a,x                 Point to end of string
L72ED               lda       >$399E              Get scroll type
                    ldu       #$05FE              Point to flag table of which scrolls players knows
                    tst       a,u                 Does player know this scroll?
                    beq       L730F               No, use random gibberish or what player called them
                    ldb       #4                  4 bytes per entry
                    mul
                    addd      #$0156              Point to scroll names table
                    tfr       d,u
                    ldu       ,u                  Get ptr to scrolls real name
                    pshs      u                   Save it
                    ldu       #$39B5              'of %s'
                    pshs      u
                    lbsr      L3D23
                    leas      4,s
                    bra       L733C

L730F               lsla                          *2 for 2 bytes/entry
                    ldu       #$07ED              Point to tbl for scroll names if not known to player
                    tst       [a,u]               Check 1st byte at name ptr
                    beq       L7327               Nothing yet, skip ahead
                    ldu       a,u                 Get ptr to non-official name
                    pshs      u
                    ldu       #$39BB              'called %s'
                    pshs      u
                    lbsr      L3D23
                    leas      4,s
                    bra       L733C

L7327               lda       >$399E              Get scroll type again (0-14)
                    ldb       #21                 21 bytes per random gibberish scroll name
                    mul
                    addd      #$0642              Point to gibberish name for scroll
                    pshs      d
                    ldu       #$39C5              'titled '%s'
                    pshs      u
                    lbsr      L3D23
                    leas      4,s
L733C               lbra      L7691

L733F               cmpa      #$CE                Potion?
                    lbne      L73EC
                    ldb       $E,y                Get # of potions of this type?
                    cmpb      #1                  If >1, skip to plural text
                    bne       L7355
                    ldu       #$39D1              'A potion '
                    lbsr      L3FF3
                    leax      9,x
                    bra       L7367

L7355               clra
                    pshs      d
                    ldu       #$39DB              '%d potions '
                    pshs      u
                    lbsr      L3D23
                    leas      4,s
                    lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    leax      a,x
L7367               lda       >$399E              Get potion type
                    ldu       #$060D              Point to table of which potions player knows
                    tst       a,u                 Does player know this potion type?
                    beq       L7397               No, skip ahead
* 6809/6309 - redundant, remove lda
                    lda       >$399E
                    lsla                          *2 bytes per entry
                    ldu       #$077D              Point to table of ptrs to potion names assigned by player
                    ldu       a,u
                    pshs      u
                    lda       >$399E              Get potion type again
                    ldb       #4                  4 bytes per entry
                    mul
                    addd      #$0262              Point to table of ptrs to real potion names
                    tfr       d,u
                    ldu       ,u
                    pshs      u
                    ldu       #$39E7              'of %s(%s)'
                    pshs      u
                    lbsr      L3D23
                    leas      6,s
                    bra       L73E9

* Player doesn't know current potion type
L7397               lsla
                    ldu       #$080B              Point to player assigned name table for potions
                    tst       [a,u]               Has player assigned name to it?
                    beq       L73B9               No, use potion color instead
                    ldu       #$077D              Point to tbl of potion names assigned by player
                    ldu       a,u                 Get ptr to potion we are doing
                    pshs      u
                    ldu       #$080B              Point to assigned name table
                    ldu       a,u                 Get that ptr
                    pshs      u
                    ldu       #$39F1              'called %s(%s)'
                    pshs      u
                    lbsr      L3D23
                    leas      6,s
                    bra       L73E9

L73B9               ldx       #$4B34
                    ldu       #$077D
                    ldu       a,u
                    ldb       $E,y                Get # of potions of this type player has
                    cmpb      #1                  If >1, use plural text
                    bne       L73DA
                    pshs      u
                    lbsr      L56E3               Point to NUL or 'n' ('a' or 'an')
                    pshs      u
                    ldu       #$39FF              'A%s %s potion'
                    pshs      u
                    lbsr      L3D23
                    leas      6,s
                    bra       L73E9

L73DA               pshs      u
                    clra
                    pshs      d
                    ldu       #$3A0D              '%d %s potions'
                    pshs      u
                    lbsr      L3D23
                    leas      6,s
L73E9               lbra      L7691

L73EC               cmpa      #$CC                Slime Mold?
                    bne       L7445
                    lda       >$399E
                    cmpa      #$01
                    bne       L7427
                    ldb       $E,y                Get # of slime molds player has
                    cmpb      #1                  >1, use plural text
                    bne       L7413
                    ldu       #$150B              'Slime Mold'
                    pshs      u
                    lbsr      L56E3               Point to NUL or 'n' ('a' or 'an')
                    pshs      u
                    ldu       #$3A1B              'A%s %s'
                    pshs      u
                    lbsr      L3D23
                    leas      6,s
                    bra       L7442

L7413               ldu       #$150B              'Slime Mold'
                    pshs      u
                    clra
                    pshs      d
                    ldu       #$3A22              '%d %ss'
                    pshs      u
                    lbsr      L3D23
                    leas      6,s
                    bra       L7442

L7427               ldb       $E,y                Get # of food player has
                    cmpb      #1                  >1, use plural text
                    bne       L7435
                    ldu       #$3A29              'Some food'
                    lbsr      L3FF3
                    bra       L7442

L7435               clra
                    pshs      d
                    ldu       #$3A33              '%d rations of food'
                    pshs      u
                    lbsr      L3D23
                    leas      4,s
L7442               lbra      L7691

L7445               cmpa      #$CF                Weapon?
                    lbne      L74F7               No, skip ahead
                    ldb       $E,y                Get # of weapon player has
                    cmpb      #1                  >1, use plural text
                    bne       L746B
                    lda       >$399E              Get object # again
                    lsla                          2 bytes/entry
                    ldu       #$004B              Point to tbl of ptrs to weapon names
                    ldu       a,u                 Point to specific weapon name
                    lbsr      L56E3               Get A from U. If it's a vowel (aeiou), U=$2A4E else U=$1470
                    pshs      u
                    ldu       #$3A46              'A%s '
                    pshs      u
                    lbsr      L3D23
                    leas      4,s
                    bra       L7478

L746B               clra
                    pshs      d
                    ldu       #$3A4B              '%d '
                    pshs      u
                    lbsr      L3D23
                    leas      4,s
L7478               lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    leax      a,x
                    lda       <$13,y              ??? Maybe weapon is a +/-?
                    anda      #$02
                    beq       L74A9
                    lda       >$399E              Get weapon object # again
                    lsla                          2 bytes/ptr to weapon name
                    ldu       #$004B              Start of weapons name tbl
                    ldu       a,u                 Point to specific weapon name
                    pshs      u
* 6809/6309 - ldd <$10,y
                    lda       <$10,y
                    ldb       <$11,y
                    ldu       #$00CF
                    lbsr      L899A
                    pshs      u
                    ldu       #$3A4F              '%s %s'
                    pshs      u
                    lbsr      L3D23
                    leas      6,s
                    bra       L74BE

L74A9               lda       >$399E              Get object #
                    lsla                          2 bytes/ptr
                    ldu       #$004B              Start of weapons name tbl
                    ldu       a,u                 Point to specific weapon name
                    pshs      u
                    ldu       #$3A55              '%s'
                    pshs      u
                    lbsr      L3D23
                    leas      4,s
L74BE               ldb       $E,y                Get # of weapon player has
                    cmpb      #1                  If just one, skip ahead
                    beq       L74CA
                    ldu       #$3A58              's' (add s for plural)
                    lbsr      L3FFD
L74CA               tst       <$14,y              ?Special weapon flag set?
                    beq       L74F4               No, skip ahead
                    lda       <$13,y              ?Yes, check for specific special types?
                    anda      #$40
                    beq       L74F4               No, skip ahead
                    ldu       #$3A5A              ' of '
                    lbsr      L3FFD
                    lda       <$14,y              Get special type
                    suba      #$41
                    ldb       #18
                    mul
                    addd      #$10FB
                    tfr       d,u
                    ldu       ,u
                    lbsr      L3FFD
                    ldu       #$3A5F              ' slaying'
                    lbsr      L3FFD
L74F4               lbra      L7691

L74F7               cmpa      #$D0                Armor?
                    bne       L754E
                    lda       <$13,y
                    anda      #$02
                    beq       L7536
                    ldb       <$12,y
                    subb      #$0B
                    negb
                    clra
                    pshs      d
                    lda       >$399E              Get armor type #
                    lsla                          2 bytes per ptr
                    ldu       #$00C7              Point to tbl of ptrs to armor names
                    ldu       a,u                 Get ptr to our armor type
                    pshs      u
                    lda       >$399E              Get armor type again
                    ldu       #$014E              Point to ???? armor table
                    lda       a,u                 Get entry
                    suba      <$12,y
                    clrb
                    ldu       #$00D0              Some other table
                    lbsr      L899A
                    pshs      u
                    ldu       #$3A68              '%s %s [armor class %d]'
                    pshs      u
                    lbsr      L3D23
                    leas      8,s
                    bra       L754B

L7536               lda       >$399E              Get armor type #
                    lsla                          2 bytes per ptr
                    ldu       #$00C7              Point to tbl of armor names
                    ldu       a,u                 Get ptr to our armor type
                    pshs      u
                    ldu       #$3A7F              '%s'
                    pshs      u
                    lbsr      L3D23
                    leas      4,s
L754B               lbra      L7691

L754E               cmpa      #$D5                Amulet of Yendor?
                    bne       L755B
                    ldu       #$3A82              'The Amulet of Yendor'
                    lbsr      L3FF3
                    lbra      L7691

L755B               cmpa      #$D2                Wand/Staff?
                    lbne      L75F8               No, skip ahead
                    lda       >$399E              Get object #
                    lsla                          * 2 bytes for ptrs
                    ldu       #$07D1              Point to table of ptrs to ??? (wands)
                    ldu       a,u                 Get ptr to specific wand name
                    pshs      u
                    lbsr      L56E3               Point to NUL or 'n' ('a' or 'an')
                    pshs      u
                    ldu       #$3A97              'A%s %s '
                    pshs      u
                    lbsr      L3D23
                    leas      6,s
                    ldu       #$4B34
                    lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    leax      a,x
                    lda       >$399E              Get object # again
                    ldu       #$0629              Point to ??? Wand table
                    tst       a,u                 Has it been identified?
                    beq       L75B8               No, skip ahead
* 6809/6309 - redundant, A not reloaded. Remove lda
                    lda       >$399E
                    lsla                          * 2 per tbl entry
                    ldu       #$07B5
                    ldu       a,u                 Get ptr to wand name assigned by player
                    pshs      u
                    lbsr      L8688
                    pshs      u
                    lda       >$399E              Get object # again
                    ldb       #4                  4 bytes/entry
                    mul
                    addd      #$043C              Point to specific entry of our wand type
                    tfr       d,u
                    ldu       ,u                  Get ptr to wands real name
                    pshs      u
                    ldu       #$3A9F              'of %s%s(%s)'
                    pshs      u
                    lbsr      L3D23
                    leas      8,s
                    bra       L75F5

L75B8               lsla                          * 2 bytes/ptr
                    ldu       #$0843              Point to player assigned wand name ptrs
                    tst       [a,u]               Has player named it?
                    beq       L75DA               no, use unidentified name
                    ldu       #$07B5              Yes, get ptr to player assigned name
                    ldu       a,u
                    pshs      u
                    ldu       #$0843
                    ldu       a,u
                    pshs      u
                    ldu       #$3AAB              ' %s'
                    pshs      u
                    lbsr      L3D23
                    leas      6,s
                    bra       L75F5

L75DA               ldx       #$4B36
                    ldu       #$07D1
                    ldu       a,u
                    pshs      u
                    ldu       #$07B5
                    ldu       a,u
                    pshs      u
                    ldu       #$3AB9
                    pshs      u
                    lbsr      L3D23
                    leas      6,s
L75F5               lbra      L7691

L75F8               cmpa      #$D1                Ring object type?
                    bne       L7669               No, skip ahead
                    lda       >$399E              Get ring type #
                    ldu       #$061B              Has this ring type been seen before?
                    tst       a,u
                    beq       L762E               No, skip ahead
                    lsla
                    ldu       #$0799              Point to player assigned name ptr tbl
                    ldu       a,u                 Get ptr
                    pshs      u
                    lda       >$399E              Get ring type #
                    ldb       #4                  4 bytes/entry
                    mul
                    addd      #$034C              Point to start of ring name tbl
                    tfr       d,u
                    ldu       ,u                  Get ptr to real ring name
                    pshs      u
                    lbsr      L9667
                    pshs      u
                    ldu       #$3ABF              'A%s ring of %s(%s)'
                    pshs      u
                    lbsr      L3D23
                    leas      8,s
* 6809/6309 - BRA L7691
                    bra       L7666

L762E               lsla
                    ldu       #$0827              Point to player assigned ring name ptrs
                    tst       [a,u]               Has player named this one?
                    beq       L7650               No, use default unidentified ring name
                    ldu       #$0799
                    ldu       a,u
                    pshs      u
                    ldu       #$0827              Get ptr to player assigned ring name
                    ldu       a,u
                    pshs      u
                    ldu       #$3AD2              'A ring called %s(%s)'
                    pshs      u
                    lbsr      L3D23
                    leas      6,s
* 6809/6309 - BRA L7691
                    bra       L7666

L7650               ldu       #$0799              Point to ring name ptr tbl
                    ldu       a,u                 Get ptr for our ring
                    pshs      u
                    lbsr      L56E3               Point to NUL or 'n' ('a' or 'an')
                    pshs      u
                    ldu       #$3AE7              'A%s %s ring'
                    pshs      u
                    lbsr      L3D23
                    leas      6,s
* 6809/6309 - BRA
L7666               lbra      L7691

L7669               cmpa      #$CB                Gold object?
                    bne       L767F               No, skip ahead
                    ldu       <$10,y
                    pshs      u
                    ldu       #$3AF3              '%u gold pieces'
                    pshs      u
                    lbsr      L3D23
* 6809/6309 - Change next to lines to BRA L768F (new label)
                    leas      4,s
                    lbra      L7691

L767F               lda       $F,y
                    pshs      a
                    lda       4,y
                    pshs      a
                    ldu       #$3B02              'Something bizarre [o_type:%i],[o_which:%i]' (you should never see this)
                    pshs      u
                    lbsr      L3D23
L768F               leas      4,s
* After special object processing above, they all come here (post object descriptions)
L7691               cmpy      >$0DB1
                    bne       L769D
                    ldu       #$3B2D              ' (being worn)'
                    lbsr      L3FFD
L769D               cmpy      >$0DB7
                    bne       L76A9
                    ldu       #$3B3B              ' (weapon in hand)'
                    lbsr      L3FFD
L76A9               cmpy      >$0DB3
                    bne       L76B5
                    ldu       #$3B4D              ' (on left hand)'
                    lbsr      L3FFD
L76B5               cmpy      >$0DB5
                    bne       L76C1
                    ldu       #$3B5D              ' (on right hand)'
                    lbsr      L3FFD
L76C1               tst       >$399D
                    beq       L76DA
                    lda       >$4B34
                    lbsr      L3EF6
                    tsta
                    beq       L76DA
                    lda       >$4B34
                    lbsr      L3F6C
                    sta       >$4B34
                    bra       L76F1

L76DA               tst       >$399D
                    bne       L76F1
                    lda       >$4B34
                    lbsr      L3F0A
                    tsta
                    beq       L76F1
                    lda       >$4B34
                    lbsr      L3F5D
                    sta       >$4B34
L76F1               ldu       #$4B34
                    puls      pc,y,x,d

* 'D'rop command
L76F6               pshs      u,y,x,d
                    lda       >$10DD
                    ldb       >$10DC
                    lbsr      L3BBB
                    cmpa      #$C2
                    beq       L7715
                    cmpa      #$C3
                    beq       L7715
                    ldu       #$3B73              'there is something there already'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    puls      pc,u,y,x,d

L7715               ldx       #$3B6E              'drop'
                    clra
                    lbsr      L711A
                    cmpx      #$0000
                    bne       L7723
                    puls      pc,u,y,x,d

L7723               lbsr      L77AC
                    tsta
                    bne       L772B
                    puls      pc,u,y,x,d

L772B               lda       $E,x
                    cmpa      #2
                    blo       L776F
                    lda       4,x
                    cmpa      #$CF
                    beq       L776F
                    pshs      x
                    lbsr      L6162               Get next free inventory entry (max 40)
                    leau      ,x                  Copy inventory ptr to U
                    puls      x                   Get original X back
                    cmpu      #$0000              Was inventory full?
                    bne       L7752               No, go handle
                    ldu       #$3B94              'can't drop it, it appears to be stuck in your pack!'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    puls      pc,u,y,x,d

L7752               dec       $E,x
                    pshs      u,x
                    lda       #$1F
                    exg       u,x
                    lbsr      L3C51
                    puls      u,x
                    lda       #1
                    sta       $E,u
                    leax      ,u
                    tst       <$15,x
                    beq       L7775
                    inc       >$0D9A
                    bra       L7775

L776F               ldu       #$10F5              Get ptr to root object in backpack
                    lbsr      L6112               Remove object ,X from backpack (update linked list)
L7775               dec       >$0D9A
                    ldu       #$10F7
                    lbsr      L6138
                    lda       >$10DD
                    ldb       >$10DC
                    lbsr      L3CF4
                    lda       4,x
                    sta       ,u
                    ldd       >$10DC
                    std       5,x
                    lda       4,x
                    cmpa      #$D5
                    bne       L7799
                    clr       >$0637
L7799               lda       #1
                    lbsr      L72B6
                    pshs      u
                    ldu       #$3BC8              'dropped %s'
                    pshs      u
                    lbsr      L68D8
                    leas      4,s
                    puls      pc,u,y,x,d

L77AC               pshs      u,x
                    cmpx      #$0000
                    bne       L77B7
                    lda       #1
                    puls      pc,u,x

L77B7               cmpx      >$0DB1              Same as armor worn object ptr?
                    beq       L77CF
                    cmpx      >$0DB7              Same as weapon wielded object ptr?
                    beq       L77CF
                    cmpx      >$0DB3              Same as left hand ring object ptr?
                    beq       L77CF
                    cmpx      >$0DB5              Same as right hand ring object ptr?
                    beq       L77CF
                    lda       #1
                    puls      pc,u,x

L77CF               lda       <$13,x
                    anda      #$01
                    beq       L77E3
                    ldu       #$3BD3              'you can't. It appears to be cursed'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    clra
                    puls      pc,u,x

L77E3               clra
                    clrb
                    cmpx      >$0DB7              Same as weapon wielded object ptr?
                    bne       L77EF               No, check next
                    std       >$0DB7              Save as new weapon wielded object ptr
                    bra       L782C

L77EF               cmpx      >$0DB1              Same as armor worn object ptr?
                    bne       L77FC               No, check next
                    lbsr      L873F
                    std       >$0DB1              Save new armor worn object ptr
                    bra       L782C

L77FC               cmpx      >$0DB3              Same as ring on left hand object ptr?
                    bne       L7806               No, check next
                    std       >$0DB3              Save new ring on left hand object ptr
                    bra       L7810

L7806               cmpx      >$0DB5              Same as ring on right hand object ptr?
                    bne       L782C
                    std       >$0DB5              Save new ring on right hand object ptr
                    bra       L7810

L7810               lda       $F,x
                    cmpa      #1
                    bne       L781F
                    lda       <$12,x
                    nega
                    lbsr      L55F0
                    bra       L782C

L781F               cmpa      #4
                    bne       L782C
                    lbsr      L5FC3
                    ldu       #L5FC3+PrgOffst-$1B2 (#$BE11)
                    lbsr      L5EA2
L782C               lda       #1
                    puls      pc,u,x

L7830               pshs      u,d
                    lbsr      L6162               Get next free inventory entry (max 40)
                    cmpx      #$0000              Inventory full?
                    bne       L783C               No, proceed
                    puls      pc,u,d              Yes, exit

L783C               clr       <$10,x              Blessing=0
                    clr       <$11,x              extra damage=0
                    ldd       #$3BF7              '0d0'? (maybe)
                    std       $A,x
                    std       $C,x
                    lda       #$B
                    sta       <$12,x
                    lda       #$01
                    sta       $E,x
                    clr       <$15,x
                    clr       <$13,x
                    clr       <$14,x
                    lda       >$0D9C
                    cmpa      #3
                    bls       L7866
                    lda       #$02
                    bra       L786E

L7866               ldu       #$1454
                    lda       #$07
                    lbsr      L79C9
* 6809/6309 - TSTA
L786E               cmpa      #$00
                    bne       L7883
                    lda       #$CE
                    sta       4,x
                    ldu       #$0262              Point to potion name table
                    lda       #$0E
                    lbsr      L79C9
                    sta       $F,x
                    lbra      L79C7

L7883               cmpa      #$01
                    bne       L7898
                    lda       #$CD
                    sta       4,x
                    ldu       #$0156              Point to ???
                    lda       #$0F
                    lbsr      L79C9
                    sta       $F,x
                    lbra      L79C7

L7898               cmpa      #$02
                    bne       L78B7
                    clr       >$0D9C
                    lda       #$CC
                    sta       4,x
                    lda       #10                 RND(10)
                    lbsr      L63A9
                    tsta
                    beq       L78B0
                    clr       $F,x
                    lbra      L79C7

L78B0               lda       #$01
                    sta       $F,x
                    lbra      L79C7

L78B7               cmpa      #$03
                    bne       L78FE
                    lda       #$CF
                    sta       4,x
                    lda       #10                 RND(10)
                    lbsr      L63A9
                    sta       $F,x
                    lbsr      L893F
                    lda       #100                RND(100)
                    lbsr      L63A9
                    cmpa      #10
                    bge       L78EA
                    lda       <$13,x
                    ora       #$01
                    sta       <$13,x
                    lda       #3                  RND(3)
                    lbsr      L63A9
                    adda      #$01
                    nega
                    adda      <$10,x
                    sta       <$10,x
                    bra       L78FB

L78EA               cmpa      #$0F
                    bge       L78FB
                    lda       #3                  RND(3)
                    lbsr      L63A9
                    adda      #$01
                    adda      <$10,x
                    sta       <$10,x
L78FB               lbra      L79C7

L78FE               cmpa      #$04
                    bne       L7957
                    lda       #$D0
                    sta       4,x
                    lda       #100                RND(100)
                    lbsr      L63A9
                    ldu       #$0146
                    clrb
L790F               cmpa      b,u
                    blt       L7918
                    suba      b,u
                    incb
                    bra       L790F

L7918               stb       $F,x
                    ldu       #$014E
                    lda       b,u
                    sta       <$12,x
                    lda       #100                RND(100)
                    lbsr      L63A9
                    cmpa      #$14
                    bhs       L7942
                    lda       <$13,x
                    ora       #1
                    sta       <$13,x
                    lda       #3                  RND(3)
                    lbsr      L63A9
                    adda      #1
                    adda      <$12,x
                    sta       <$12,x
                    bra       L7954

L7942               cmpa      #$1C
                    bge       L7954
                    lda       #3                  RND(3)
                    lbsr      L63A9
                    adda      #1
                    nega
                    adda      <$12,x
                    sta       <$12,x
L7954               lbra      L79C7

L7957               cmpa      #5
                    bne       L79A5
                    lda       #$D1
                    sta       4,x
                    ldu       #$034C
                    lda       #$0E
                    lbsr      L79C9
                    sta       $F,x
                    beq       L7979
                    cmpa      #1
                    beq       L7979
                    cmpa      #$07
                    beq       L7979
                    cmpa      #$08
                    bne       L7992
L7979               lda       #3                  RND(3)
                    lbsr      L63A9
                    sta       <$12,x
                    bne       L7990
                    lda       #$FF
                    sta       <$12,x
                    lda       <$13,x
                    ora       #$01
                    sta       <$13,x
L7990               bra       L79A2

L7992               cmpa      #$06
                    beq       L799A
                    cmpa      #$0B
                    bne       L79A2
L799A               lda       <$13,x
                    ora       #1
                    sta       <$13,x
L79A2               bra       L79C7

L79A5               cmpa      #$06
                    bne       L79BD
                    lda       #$D2
                    sta       4,x
                    ldu       #$043C              Point to tbl of pointers for wands
                    lda       #$0E
                    bsr       L79C9
                    sta       $F,x
                    lbsr      L7D34
                    bra       L79C7

L79BD               ldu       #$3BFB              'Picked a bad kind of object.'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
L79C7               puls      pc,u,d

L79C9               pshs      u
                    sta       >$3C18
                    lda       #100                RND(100)
                    lbsr      L63A9
                    clrb
L79D4               cmpa      2,u
                    blt       L79DF
                    suba      2,u
                    incb
                    leau      4,u
                    bra       L79D4

L79DF               tfr       b,a
                    cmpa      >$3C18
                    blt       L79F1
                    ldu       #$3C19              'Picked a bad object out of this list '
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    clra
L79F1               puls      pc,u

* 'D'iscovered items command
L79F3               pshs      u,y,d
                    lda       #$CE
* 6809/6309 - BSR
                    lbsr      L7A11
                    lda       #$CD
* 6809/6309 - BSR
                    lbsr      L7A11
                    lda       #$D1
* 6809/6309 - BSR
                    lbsr      L7A11
                    lda       #$D2
* 6809/6309 - BSR
                    lbsr      L7A1E
                    ldd       #$1470
                    lbsr      L7D29
                    puls      pc,u,y,d

* 6809/6309 - BSR
L7A11               lbsr      L7A1E
                    ldd       #$1470
                    ldy       #$3C3F
                    lbra      L7B5E

L7A1E               pshs      u,y,x,d
                    sta       >$3C41
                    cmpa      #$CD                Scroll?
                    bne       L7A32
                    lda       #$0F
                    ldy       #$05FE              Point to tbl of flags of known scroll types
                    ldu       #$07ED              Point to tbl of scroll names assigned by player
                    bra       L7A5D

L7A32               cmpa      #$CE                Potion?
                    bne       L7A41
                    lda       #$0E
                    ldy       #$060D              Point to tbl of flags of known potion types
                    ldu       #$080B              Point to tbl of potion names assigned by player
                    bra       L7A5D

L7A41               cmpa      #$D1                Ring?
                    bne       L7A50
                    lda       #$0E
                    ldy       #$061B              Point to tbl of flags of known ring types
                    ldu       #$0827              Point to table of ring names assigned by player
                    bra       L7A5D

L7A50               cmpa      #$D2                Wand?
                    bne       L7A5D
                    lda       #$0E
                    ldy       #$0629              Point to tbl of flags of known wand types
                    ldu       #$0843              Point to table of wand names assigned by player
L7A5D               ldx       #$3C68
* 6809/6309 - BSR
                    lbsr      L7AD4
                    sta       >$3C47
                    sty       >$3C42
                    stu       >$3C44
                    ldx       #$3C49
                    lda       #$01
                    sta       $E,x
                    clr       <$13,x
                    clr       >$3C48
                    clr       >$3C46
L7A7D               lda       >$3C46
                    cmpa      >$3C47
                    bhs       L7AC1
                    lda       >$3C46
                    ldu       #$3C68
                    lda       a,u
                    ldu       >$3C42
                    tst       a,u
                    bne       L7A9C
                    lsla
                    ldu       >$3C44
                    tst       [a,u]
                    beq       L7ABC
L7A9C               lda       >$3C41
                    sta       $04,x
                    lda       >$3C46
                    ldu       #$3C68
                    lda       a,u
                    sta       $F,x
                    clra
                    lbsr      L72B6
                    ldd       #$1470
                    ldy       #$3C81              '%s'
                    lbsr      L7B5E
                    inc       >$3C48
L7ABC               inc       >$3C46
                    bra       L7A7D

L7AC1               tst       >$3C48
                    bne       L7AD2
                    lda       >$3C41
                    lbsr      L7B12
                    ldd       #$1470
                    lbsr      L7B5E
L7AD2               puls      pc,u,y,x,d

L7AD4               pshs      d
                    sta       >$3C84
                    clra
L7ADA               sta       a,x
                    inca
                    cmpa      >$3C84
                    blo       L7ADA
                    lda       >$3C84
                    sta       >$3C85
L7AE8               lbsr      L63A9               RND(A)
                    sta       >$3C86
                    lda       >$3C85
                    deca
                    ldb       a,x
                    pshs      b
                    lda       >$3C86
                    ldb       a,x
                    lda       >$3C85
                    deca
                    stb       a,x
                    puls      b
                    lda       >$3C86
                    stb       a,x
                    dec       >$3C85
                    lda       >$3C85
                    bne       L7AE8
                    puls      pc,d

L7B12               pshs      u,x,d
                    pshs      a
                    ldx       #$4B34
                    ldu       #$3C87              'Haven't discovered anything'
                    pshs      u
                    lbsr      L3D23
                    leas      2,s
                    lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    leax      a,x
                    puls      a
                    cmpa      #$CE                Potion?
                    bne       L7B33
                    ldu       #$3CA3              'potion'
                    bra       L7B4C

L7B33               cmpa      #$CD                Scroll?
                    bne       L7B3C
                    ldu       #$3CAA              'scroll'
                    bra       L7B4C

L7B3C               cmpa      #$D1                Ring?
                    bne       L7B45
                    ldu       #$3CB1              'ring'
                    bra       L7B4C

L7B45               cmpa      #$D2                Wand?
                    bne       L7B4C
                    ldu       #$3CB6              'stick'
L7B4C               pshs      u
                    ldu       #$3CBC              ' about any %ss'
                    pshs      u
                    lbsr      L3D23
                    leas      4,s
                    ldy       #$4B34
                    puls      pc,u,x,d

L7B5E               pshs      u,y,x
                    std       >$3CCC
                    sty       >$3CCE
                    stu       >$3CD0
                    lda       #$20
                    sta       >$3CD2
                    clr       >$3CD3
                    ldd       >$3CCE
                    lbne      L7BFE
                    lda       #$01
                    sta       >$3CD3
                    tst       [>$3CCC]
                    beq       L7BD7
                    lda       >$37CB
                    cmpa      #$2C
                    bhs       L7BBE
                    cmpa      #$1E
                    bhs       L7BA4
                    lda       >$37CE
                    deca
                    clrb
                    lbsr      L6CDE               CurXY to b,a
                    ldu       #$3CD4              -Select item-CRLF-Esc to cancel-'
                    pshs      u
                    lbsr      L6D16
                    leas      2,s
                    lbra      L7CBA

L7BA4               lda       >$37CE
                    deca
                    clrb
                    lbsr      L6CDE               CurXY to b,a
                    ldu       >$3CCC
                    pshs      u
                    ldu       #$3CF3              '-Select item to %s-CRLF-Esc to cancel-'
                    pshs      u
                    lbsr      L6D16
                    leas      4,s
                    lbra      L7CBA

L7BBE               lda       >$37CE
                    clrb
                    lbsr      L6CDE               CurXY to b,a
                    ldu       >$3CCC
                    pshs      u
                    ldu       #$3D18              '-Select item to %s'
                    pshs      u
                    lbsr      L6D16
                    leas      4,s
                    lbra      L7CBA

L7BD7               lda       >$37CB              Get window width
                    cmpa      #25                 If>=25, skip ahead
                    bhs       L7BEE
                    lda       >$37CE
                    clrb
                    lbsr      L6CDE               CurXY to b,a
                    ldx       #$3D3B              '-Space to continue-'
                    lbsr      L6D07               Write out string @ X (NUL terminated)
                    lbra      L7CBA

L7BEE               lda       >$37CE
                    clrb
                    lbsr      L6CDE               CurXY to b,a
                    ldx       #$3D4F              '-Press space bar to continue-'
                    lbsr      L6D07               Write out string @ X (NUL terminated)
                    lbra      L7CBA

L7BFE               lda       >$37CB              Get window width
                    cmpa      #40                 If >=40 columns, skip ahead
                    bhs       L7C09
                    lda       #$05
                    bra       L7C13

L7C09               cmpa      #65                 Is window width >=65 columns?
                    bhs       L7C11               Yes, skip ahead
                    lda       #$03
                    bra       L7C13

L7C11               lda       #$01
L7C13               adda      >$3CCB
                    cmpa      >$37CC
                    lblo      L7CDF
                    tst       [>$3CCC]
                    beq       L7C97
                    lda       >$37CB              Get window width
                    cmpa      #44
                    bhs       L7C62
                    cmpa      #30
                    bhs       L7C48
                    lda       >$37CE
                    deca
                    deca
                    clrb
                    lbsr      L6CDE               CurXY to b,a
                    ldu       >$3CCC
                    pshs      u
                    ldu       #$3D69              '-Select item-CRLF--Esc to cancel-CRLF-Space for more'
                    pshs      u
                    lbsr      L6D16
                    leas      4,s
                    bra       L7CBA

L7C48               lda       >$37CE
                    deca
                    deca
                    clrb
                    lbsr      L6CDE               CurXY to b,a
                    ldu       >$3CCC
                    pshs      u
                    ldu       #$3D9A              '-Select item to %s-CRLF-Esc to cancel-CRLF-Press space for more-'
                    pshs      u
                    lbsr      L6D16
                    leas      4,s
                    bra       L7CBA

L7C62               cmpa      #65                 window width 65 or higher?
                    bhs       L7C7F               Yes, skip ahead
                    lda       >$37CE
                    deca
                    clrb
                    lbsr      L6CDE               CurXY to b,a
                    ldu       >$3CCC
                    pshs      u
                    ldu       #$3DD7              '-Select item to %s-CRLF-Esc to cancel. Press space for more-'
                    pshs      u
                    lbsr      L6D16
                    leas      4,s
                    bra       L7CBA

L7C7F               lda       >$37CE              Comes here is window width is 65 or higher
                    clrb
                    lbsr      L6CDE               CurXY to b,a
                    ldu       >$3CCC
                    pshs      u
                    ldu       #$3E12              '-Select item to %s. Esc to cancel. Press space for more-'
                    pshs      u
                    lbsr      L6D16
                    leas      4,s
                    bra       L7CBA

L7C97               lda       >$37CB              Get window width
                    cmpa      #24                 If 24 or higher, skip ahead
                    bhs       L7CAD
                    lda       >$37CE
                    clrb
                    lbsr      L6CDE               CurXY to b,a
                    ldx       #$3E4B              '-Space for more-'
                    lbsr      L6D07               Write out string @ X (NUL terminated)
                    bra       L7CBA

L7CAD               lda       >$37CE
                    clrb
                    lbsr      L6CDE               CurXY to b,a
                    ldx       #$3E5C              '-Press space for more-'
                    lbsr      L6D07               Write out string @ X (NUL terminated)
L7CBA               lbsr      L61F7
                    sta       >$3CD2
                    cmpa      #$1A                <CTRL-Z>
                    beq       L7CCE
                    cmpa      #$20                Space?
                    beq       L7CD7
                    lbsr      L3F0A
                    tsta
                    beq       L7CBA
L7CCE               clr       >$3CCB
                    lbsr      L6411
                    bra       L7D24

L7CD7               tst       >$3CD3
                    bne       L7CCE
                    clr       >$3CCB
L7CDF               tst       >$3CCB
                    bne       L7CEA
                    tst       [>$3CCE]
                    beq       L7D24
L7CEA               tst       >$3CCB
                    bne       L7CF2
                    lbsr      L6D6F
L7CF2               lda       >$3CCB
                    clrb
                    lbsr      L6CDE               CurXY to b,a
                    ldu       >$3CD0
                    pshs      u
                    ldu       >$3CCE
                    pshs      u
                    ldx       #$35BF
                    lbsr      L3D23
                    leas      4,s
                    lbsr      L6D07               Write out string @ X (NUL terminated)
                    lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    tsta
                    beq       L7D1D               If 0, skip ahead
                    deca                          Drop by 1 (so base 0)
                    tfr       a,b                 Move for divie
                    lda       >$37CB              Get window width
                    lbsr      L3CA4               Divide by length of string (A=B/A, Remainder=B)
L7D1D               inca                          Bump answer up by 1
                    adda      >$3CCB
                    sta       >$3CCB
L7D24               lda       >$3CD2
                    puls      pc,u,y,x

L7D29               pshs      y
                    ldy       #$0000
                    lbsr      L7B5E
                    puls      pc,y

* Wand/staff
L7D34               pshs      u,y,x,d
                    lda       $F,x
                    lsla
                    ldu       #$07D1
                    pshs      x
                    ldx       a,u
                    ldu       #$3E73              'staff'
                    lbsr      L3FCD               Compare strings at ,u / ,x
                    puls      x
                    tsta
                    bne       L7D52
                    ldd       #$3E79              '2d3'
                    std       $A,x
                    bra       L7D57

L7D52               ldd       #$3E7D              '1d1'
                    std       $A,x
L7D57               ldd       #$3E7D              '1d1'
                    std       $C,x
                    lda       #5
                    lbsr      L63A9               RND(5)
                    adda      #3
                    sta       <$12,x
                    lda       $0F,x
                    cmpa      #1
                    bne       L7D7E
                    lda       #$64
                    sta       <$10,x
                    lda       #$03
                    sta       <$11,x
                    ldd       #$3E81              '1d8'
                    std       $A,x
L7D8F               puls      pc,u,y,x,d

L7D7E               tsta
                    bne       L7D8F
                    lda       #10                 RND(10)
                    lbsr      L63A9
                    adda      #$0A
                    sta       <$12,x
                    puls      pc,u,y,x,d


* Part of 'z'ap command
L7D91               pshs      u,y,x,d
                    ldx       #$3EA0              'zap with'
                    lda       #$D2                Wand Object type
                    lbsr      L711A               Get ptr to object block (into X)
                    stx       >$3FD3              Save copy
                    beq       L7D8F               No object found, return
                    lda       $F,x                Get type of object
                    sta       >$3FDB              Save it
                    lda       4,x                 Get basic object type
                    cmpa      #$D2                Wand/Staff?
                    beq       L7DCE               Yes, check if there are charges left on it
                    tst       <$14,x              Player zapping with a vorpalized weapon?
                    beq       L7DBE               No, tell player they can't use 'z'ap with this object
                    tst       <$12,x              ??? Check if + value vorpalized object?
                    beq       L7DBE               No, tell player they can't use 'z'ap with this object
                    lda       #$0E                ??? Value higher than the highest wand type value (special for vorpalized weapon?)
                    sta       >$3FDB
                    bra       L7DCE               Continue

L7DBE               ldu       #$3EA9              'you can't zap with that!'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    clr       >$05FC
                    puls      pc,u,y,x,d

L7DCE               tst       <$12,x              Any charges left?
                    bne       L7DE0               Yes, continue
                    ldu       #$3EC2              'nothing happens'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    puls      pc,u,y,x,d

L7DE0               lda       >$3FDB              Get wand/staff type
                    bne       L7E42               If not Wand/Staff of Light, check next
                    pshs      x
                    ldx       #$10D8              Point to Player data block
                    ldb       #%00000001          Check if player is blind (A already 0 from above)
                    lbsr      L3C3C
                    puls      x
                    tsta
                    beq       L7E03               No, continue
                    ldu       #$3ED2              'you feel a warm glow around you' is all you get if you are blind
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    bra       L7E28

L7E03               ldb       #$01                Flag that player now knows wand/staff of light
                    stb       >$0629
                    ldy       >$10F3              Get ptr to ???
                    lda       8,y
                    anda      #%00000010          $02 Hallway?
                    beq       L7E1E               No, light up the room
                    ldu       #$3EF2              Yes, 'the corridor glows and then fades'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    bra       L7E28

L7E1E               ldu       #$3F14              'the room is lit by a shimmering blue light'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
L7E28               ldy       >$10F3              Get ptr to 'other' room table???
                    lda       8,y                 Get flags
                    anda      #%00000010          $02 Hallway?
                    bne       L7E3F               Yes, skip ahead
                    lda       #%11111110          $FE Flag room as fully viewable
                    anda      8,y
                    sta       8,y                 Save it back
                    ldx       #$10DC              Ptr to Players x,y coords
                    lbsr      L0E36
L7E3F               lbra      L8215               Update charges on the wand/staff, return from there.

L7E42               cmpa      #$09                Wand/staff of Drain Life?
                    bne       L7E62               No, check next
                    ldd       >$10ED              Yes, get players hit points
                    cmpd      #$0002              If >=2, do the Drain Life routine
                    bge       L7E5C
                    ldu       #$3F3F              'you are too weak to use it'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    puls      pc,u,y,x,d

* Drain Life wand
L7E5C               lbsr      L8227               Drain life routine
                    lbra      L8215

L7E62               cmpa      #$05                Polymorph wand/staff?
                    beq       L7E79
                    cmpa      #$0B                Teleport Away wand/staff?
                    beq       L7E79
                    cmpa      #$0C                Teleport To wand/staff?
                    beq       L7E79
                    cmpa      #$0D                Wand/staff of Cancellation
                    beq       L7E79
                    cmpa      #$0E                Vorpalized weapon being used to ZAP?
                    lbne      L8085               No, try next wand type
* Polymorph, Teleport Away, Teleport To, Cancellation wand/staff or Vorpalized weapon used to 'z'ap
L7E79               lda       >$10DD              Get players Y coord
                    sta       >$3FD8              Save copy
                    ldb       >$10DC              Get players X coord
                    stb       >$3FD7              Save copy
* Loop to find first proper object/map piece to stop zap path at.
L7E85               lbsr      L5AF2               Get ptr to monster @ coords (X=ptr, A=map piece from location)
                    lbsr      L58E8               Check map piece;on return A=0 if blank, wall piece or monster, A=1 otherwise
                    tsta                          blank, wall or monster?
                    beq       L7EA2               Yes, Skip ahead
                    lda       >$3FD8              Get copy of players Y coord
                    adda      >$0DB0              Add (signed) direction zap is going on Y axis
                    sta       >$3FD8              Save updated copy
                    ldb       >$3FD7              Get copy of players X coord
                    addb      >$0DAF              Add (signed) direction zap is going on X axis
                    stb       >$3FD7              Save updated copy
                    bra       L7E85               Keep scanning ahead for something for zap to collide with (blank,wall,monster)

* Zap path has hit something it will be stopped by
L7EA2               lda       >$3FD8              Get Y coord
                    lbsr      L2CDB               Search monster object list for matching monster in same X,Y pos
                    stx       >$3FD5              Save ptr to monster object
                    lbeq      L8082               If none, skip ahead
                    lda       7,x                 Get monster type
                    sta       >$3FFB              Save 2 copies
                    sta       >$3FFC
                    cmpa      #'F                 Venus Flytrap?
                    bne       L7EC5               no, skip ahead
                    ldb       >$10E4+1            Get 2nd byte of player flags
                    andb      #%01111111          $7F Clear that haste potion was active
                    stb       >$10E4+1            Save flags
L7EC5               lda       >$3FDB              Get temp copy of wand type
                    cmpa      #$0E                Special case - Vorpalized weapon?
                    bne       L7F04               No, regular wand, skip ahead
* Zapping with a vorpalized weapon
                    ldy       >$3FD3              Get ptr to vorpalized weapon object
                    lda       >$3FFB              Get monster type we are attacking
                    cmpa      <$14,y              Same monster type as weapon is vorpalized for?
                    bne       L7EF7               No, skip ahead
* If attacking the specific monster its vorpalized for, kill it instantly
                    suba      #$41                Convert monster type to binary
                    ldb       #18                 Point to that monster entry in monster definitions table
                    mul
                    addd      #$10FB
                    tfr       d,u                 Move to U
                    ldd       ,u                  Get ptr to monster name
                    pshs      d
                    ldu       #$3F5A              'the %s vanishes in a puff of smoke'
                    pshs      u
                    lbsr      L68D8
                    leas      4,s
                    clra
                    lbsr      L3A1C               Call monster killed routine
                    lbra      L8077

* Zapping the wrong monster with a vorpalized weapon
L7EF7               ldu       #$3F7D              'you hear a maniacal chuckle in the distance'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbra      L8077

* Polymorph, Teleport Away, Teleport To, Cancellation wand/staff used to 'z'ap
L7F04               cmpa      #5                  Polymorph?
                    bne       L7F85               No, check next
                    ldy       <$1D,x              Get ptr to next monster in level, maybe?
                    ldu       #$10F9              Get ptr to root object in monster list
                    lbsr      L6112               Remove monster @ ,X (update linked list)
                    lbsr      L25F0               Check if player can see monster pointed to by X
                    tsta
                    beq       L7F35               Player can NOT see it, skip ahead
                    lda       >$3FD8              Get temp copies of player's Y,X coords
                    ldb       >$3FD7
                    lbsr      L3BBB               Get map square type of position from main level map
                    tfr       a,b                 Move type to D
                    clra
                    pshs      x                   Save X, move type to X
                    tfr       d,x
                    lda       >$3FD8              Get Y,X coords again
                    ldb       >$3FD7
                    lbsr      L68C4
                    puls      x
L7F35               lda       9,x
                    sta       >$3FFD
                    lda       #26                 RND(26) (Random monster)
                    lbsr      L63A9
                    adda      #$41                Bump up to A-Z (monster)
                    leau      ,x
                    sta       >$3FFB              Save random Monster type
                    ldx       #$3FD7
                    lbsr      L29E5
                    leax      ,u
                    lbsr      L25F0               Check if player can see monster
                    tsta
                    beq       L7F67               Player can not see it, skip ahead
                    ldb       >$3FFB              Get monster type again into D
                    clra
                    pshs      x
                    tfr       d,x
                    lda       >$3FD8              Get Y,X coords again
                    ldb       >$3FD7
                    lbsr      L68C4
                    puls      x
L7F67               lda       >$3FFD
                    sta       9,x
                    sty       <$1D,x
                    lda       >$3FFB              Get monster type again
                    cmpa      >$3FFC              Same as other monster type?
                    lbeq      L8077               Yes, skip ahead
                    ldb       #$01                Flag that player knows polymorph wand/staff
                    orb       >$0629+5
                    stb       >$062E+5
                    lbra      L8077

L7F85               cmpa      #$0D                Wand of Cancellation?
                    bne       L7F9D               No, check next
                    ldd       $C,x                Get flags
                    ora       #%00010000          $10 Set (Monster invisible flag?)
                    anda      #%11111011          $FB Clear Monster ??? flag
                    andb      #%11101111          $EF
                    std       $C,x
                    lda       7,x                 ???
                    sta       8,x
                    lbra      L8077

L7F9D               lbsr      L25F0               Check if player can see monster?
                    tsta
                    beq       L7FB5               Player can't see it, skip ahead
                    pshs      x
                    ldb       9,x
                    clra
                    tfr       d,x
                    lda       >$3FD8
                    ldb       >$3FD7
                    lbsr      L68C4
                    puls      x
L7FB5               lda       >$3FDB              Get wand type again
                    cmpa      #$0B                Teleport Away?
                    lbne      L8040               No, check next
                    lda       #$40
                    sta       9,x
L7FC2               lbsr      L1997
                    sta       >$3FFE
                    pshs      x
                    ldu       #$3FFF
                    lda       >$3FFE
                    ldb       #$22
                    mul
                    addd      #$0DBB
                    tfr       d,x
                    lbsr      L0E1A
                    puls      x
                    lda       >$4000
                    ldb       >$3FFF
                    lbsr      L5AF2
                    lbsr      L3C2C
                    tsta
                    beq       L7FC2
                    ldd       >$3FFF
                    std       4,x
                    pshs      u
                    ldu       #$3FFF
                    lbsr      L281F               Get ptr into tbl @ $EED into U based on some x,y coords
                    stu       <$1B,x
                    puls      u
                    lbsr      L25F0
                    tsta
                    beq       L8018
                    ldb       8,x
                    pshs      x
                    clra
                    tfr       d,u
                    lda       5,x
                    ldb       4,x
                    leax      ,u
                    lbsr      L68C4
                    puls      x
                    bra       L8050

L8018               ldx       #$10D8
                    ldd       #$0002
                    lbsr      L3C3C
                    tsta
                    beq       L8050
                    ldx       >$3FD5
                    ldb       8,x
                    clra
                    tfr       d,u
                    lda       5,x
                    ldb       4,x
                    leax      ,u
                    lbsr      L68C4
                    ldx       >$3FD5
                    bra       L8050

* Teleport To wand
L8040               lda       >$0DB0              Get Y position
                    adda      >$10DD              Add to players Y position
                    sta       5,x                 Save it in object tbl
                    lda       >$0DAF              Get X position
                    adda      >$10DC              Add to players X position
                    sta       4,x                 Save to object tbl
L8050               lda       7,x                 Get monster type
                    cmpa      #'F                 ($46) Venus Flytrap?
                    bne       L8060               No, skip ahead
                    ldb       >$10E4+1            Get LSB player status flags
                    andb      #%01111111          Flag trapped by Venus Flytrap
                    stb       >$10E4+1            Save them back
L8060               lda       5,x                 Get monster Y coord back
                    cmpa      >$3FD8              Same as temp players Y coord?
                    bne       L806E               No, skip ahead
                    lda       4,x                 Get monster X coord back
                    cmpa      >$3FD7              Same as temp players X coord
                    beq       L8077               Yes, skip ahead
L806E               lbsr      L68D2               Get object char from map known to player ($2E2B)
                    sta       9,x                 Save it
L8077               ldd       #$10DC
                    std       $A,x
                    ldb       $C+1,x
                    orb       #%00000100          $04 Set Monster aggravated flag (so it will attack)
                    stb       $C+1,x
L8082               lbra      L8215

L8085               cmpa      #$06                Magic Missile wand/staff?
                    bne       L80F5               No, skip ahead
                    ldd       #$2A01
                    stb       >$062F
                    sta       >$3FE0
                    ldd       #$3E85
                    std       >$3FE8
                    ldd       #$6401
                    std       >$3FEC
                    lda       #$10
                    sta       >$3FEF
                    ldx       >$0DB7              Get ptr to weapon being wielded
                    beq       L80B2               None, skip ahead
                    lda       $F,x                Get weapon type
                    sta       >$3FE5              Save copy
L80B2               ldx       #$3FDC              Ptr to ???
                    lda       >$0DB0              Get Y,X coords for Zap path
                    ldb       >$0DAF
                    lbsr      L87D4
                    lda       >$3FE2              Get Y coord
                    ldb       >$3FE1              Get X coord
                    lbsr      L2CDB               Search monster object list for matching monster in same position
                    stx       >$3FD5              Save ptr to monster object
                    beq       L80E8               None, skip ahead
                    leay      ,x                  Y=monster obj ptr
                    lda       #$03
                    lbsr      L37D3
                    tsta
                    bne       L80E8
                    pshs      x
                    ldx       #$3FDC
                    lda       >$3FE2              Get Y/X pos of ???
                    ldb       >$3FE1
                    lbsr      L8978               Search monster list for monster in same position
                    puls      x
                    bra       L80F2

L80E8               ldu       #$3FAA              'the missile vanishes with a puff of smoke'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
L80F2               lbra      L8215

L80F5               cmpa      #1                  Wand/staff of Striking?
                    bne       L8140               No, check next wand type
                    lda       >$3FD8
                    adda      >$0DB0
                    sta       >$3FD8
                    ldb       >$3FD7
                    addb      >$0DAF
                    stb       >$3FD7
                    ldy       >$3FD3
                    lbsr      L2CDB               Search monster object list for matching monster in same position
                    stx       >$3FD5
                    beq       L813D
                    lda       #20                 RND(20)
                    lbsr      L63A9
                    tsta
                    bne       L8126
                    ldu       #$3E89              '3d8'
                    lda       #$09
                    bra       L812B

L8126               ldu       #$3E8D              '2d8'
                    lda       #4
L812B               stu       $A,y
                    sta       <$11,y
                    ldy       #$3FD7
                    ldb       7,x
                    ldu       >$3FD3
                    clra
                    lbsr      L2E75
L813D               lbra      L8215

L8140               cmpa      #$07                Haste Monster wand/staff?
                    beq       L814B               Yes, skip ahead
                    cmpa      #$08                Slow Monster wand/staff?
                    lbne      L81CC               No, check next wand types
L814B               lda       >$10DD
                    sta       >$3FD8
                    ldb       >$10DC
                    stb       >$3FD7
L8157               lbsr      L5AF2
                    lbsr      L58E8               Check map piece;on return A=0 if blank, wall piece or monster, A=1 otherwise
                    tsta
                    beq       L8174
                    lda       >$3FD8
                    adda      >$0DB0
                    sta       >$3FD8
                    ldb       >$3FD7
                    addb      >$0DAF
                    stb       >$3FD7
                    bra       L8157

L8174               lda       >$3FD8              Get Y coord
                    ldb       >$3FD7              Get X coord
                    lbsr      L2CDB               Search monster object list for matching monster in same position
                    stx       >$3FD5              Save ptr to monster object
                    beq       L81C9               Non, skip ahead
                    lda       >$3FDB
                    cmpa      #$07
                    bne       L81A4
                    ldd       #$2000
                    lbsr      L3C3C
                    tsta
                    beq       L819C
                    ldd       $C,x
                    anda      #$DF
                    andb      #$FF
                    std       $C,x
                    bra       L81C3

L819C               ldd       $C,x
                    ora       #$40
                    std       $C,x
                    bra       L81C3

L81A4               ldd       #$4000
                    lbsr      L3C3C
                    tsta
                    beq       L81B7
                    ldd       $C,x
                    anda      #$BF
                    andb      #$FF
                    std       $C,x
                    bra       L81C3

L81B7               ldd       $C,x
                    ora       #$20
                    std       $C,x
                    bra       L81C3

L81BF               lda       #$01
                    sta       6,x
L81C3               ldx       #$3FD7
                    lbsr      L268D
L81C9               bra       L8215

L81CC               cmpa      #$02                Lightning staff/wand?
                    beq       L81DA
                    cmpa      #$03                Fire staff/wand?
                    beq       L81DA
                    cmpa      #$04                Cold staff/wand
                    bne       L8215               not Lightning, Fire or Cold wand/staff, skip ahead
L81DA               lda       >$3FDB
                    cmpa      #$02
                    bne       L81E9
                    ldd       #$3E91              'bolt'
                    std       >$3FD9
                    bra       L81FB

L81E9               cmpa      #$03
                    bne       L81F5
                    ldd       #$3E96              'flame'
                    std       >$3FD9
                    bra       L81FB

L81F5               ldd       #$3E9C              'ice'
                    std       >$3FD9
L81FB               ldu       #$10DC
                    ldy       #$0DAF
                    ldd       >$3FD9
                    lbsr      L8313
                    lda       >$3FDB
                    ldb       #$01
                    ldu       #$0629
                    stb       a,u
* Drop # of charges on wand/staff by 1
L8215               ldx       >$3FD3              Get copy of ptr to wand just used
                    lda       <$12,x              Get # charges on wand
                    beq       L8225               If already 0, return
                    deca                          Drop by 1
                    sta       <$12,x              Save new charges
L8225               puls      pc,u,y,x,d

* Drain Life wand routine
L8227               pshs      u,y,x,d
                    clr       >$40C2
                    lda       >$10DD
                    ldb       >$10DC
                    lbsr      L3BBB
                    cmpa      #$CA                Door?
                    bne       L824C               No, skip ahead
                    lda       >$10DD              Get a Y coord
                    lbsr      L3BC6
                    anda      #%00001111          $0F
                    ldb       #$22
                    mul
                    addd      #$0EED
                    std       >$40C5
                    bra       L8252

L824C               clr       >$40C5
                    clr       >$40C6
L8252               ldy       >$10F3              Get ptr to our room in second room table (13*34)
                    lda       8,y                 Get room flags
                    anda      #%00000010          $02 Only keep hallway bit
                    sta       >$40C4              Save temp copy
                    ldu       #$4072              Point to ???
                    ldx       >$10F9              Get ptr to root of monster object linked list
* 6809/6309 - X always load just before coming here, so CMPX #$0000 is unnecessary. Remove
L8263               cmpx      #$0000
                    beq       L82A3               If done all monster entries, skip ahead
                    ldd       <$1B,x              Get ??? ptr from monster entry
                    cmpd      >$10F3              Same as ptr into $EEB room table?
                    beq       L829A               Yes, skip ahead
                    cmpd      >$40C5
                    beq       L829A
                    tst       >$40C4
                    beq       L829E
                    lda       5,x
                    ldb       4,x
                    lbsr      L3BBB
                    cmpa      #$CA                Door?
                    bne       L829E               No, skip ahead
                    lda       5,x
                    lbsr      L3BC6
                    anda      #$0F                Force to 0-15
                    ldb       #$22
                    mul
                    addd      #$0EED
                    cmpd      >$10F3
                    bne       L829E
L829A               stx       ,u++
L829E               ldx       ,x
                    bra       L8263

L82A3               stu       >$40C7
                    tfr       u,d
                    subd      #$4072              Subtract 16,498
                    ldu       #2                  Divide by 2
                    exg       d,u                 Swap so right registers for divide
                    lbsr      L3C5C               U=U/D (remainder in D)
                    stu       >$40C2              Save result
                    bne       L82C8
                    ldu       #$400B              'you have a tingling feeling'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
L8311               puls      pc,u,y,x,d

* ??? Drops players hit points by half, so maybe part of Wraith or Vampire attack?
L82C8               ldu       >$40C7
                    clra
                    clrb
                    std       ,u
                    ldu       >$10ED              Get players hit points
                    ldd       #2                  Divide by 2
                    lbsr      L3C5C               U=U/D (remainder in D)
                    stu       >$10ED              Save as new hit points
                    ldd       >$40C2              Get ??? and divide the new 1/2 hit points by it
                    lbsr      L3C5C               U=U/D (remainder in D)
                    leau      1,u                 Add 1 to result
                    stu       >$40C2              Save it back
                    ldu       #$4072
L82E9               ldx       ,u
                    beq       L8311
                    ldd       <$15,x
                    subd      >$40C2
                    std       <$15,x
                    bgt       L8304
                    lbsr      L25F0
                    lbsr      L3A1C               Call monster killed routine
                    bra       L830D

L8304               pshs      x
                    leax      4,x
                    lbsr      L268D
                    puls      x
L830D               leau      2,u
                    bra       L82E9

L8313               pshs      u,y,x,d
                    stu       >$41B7
                    sty       >$41B9
                    std       >$41BB
                    ldd       ,y
                    std       >$41B5
                    ldx       >$41BB
                    ldu       #$40C9              'frost'
                    lbsr      L3FCD               Compare strings at ,u / ,x
                    tsta
                    bne       L8334
                    lda       #$01
                    bra       L8335

L8334               clra
L8335               sta       >$41B4
                    lda       #$CF
                    sta       >$4199
                    lda       #$0A
                    sta       >$41A4
                    ldd       #$40CF              '6d6'
                    std       >$41A1
                    std       >$419F
* 6809/6309 - Replace next 3 lines with ldd #$1e00 / std >$41A5
                    lda       #$1E
                    sta       >$41A5
                    clr       >$41A6
                    ldd       >$41BB
                    std       >$005F
                    lda       >$41B6
                    adda      >$41B5
* 6809/6309 - redundant, remove CMPA
                    cmpa      #$00
                    bne       L836B
                    lda       #$2F                '/'
                    sta       >$4189
                    bra       L8398

L836B               cmpa      #$01
                    beq       L8375
                    cmpa      #$FF
                    bne       L8386
L8375               lda       >$41B6              Determine if horizontal or vertical blast; change char appropriately
                    beq       L837E
                    lda       #$7C                '|'
                    bra       L8380

L837E               lda       #$2D                '-'
L8380               sta       >$4189
                    bra       L8398

L8386               cmpa      #$02
                    beq       L8390
                    cmpa      #$FE
                    bne       L8398
L8390               lda       #$5C                '\'
                    sta       >$4189
                    bra       L8398

L8398               ldu       >$41B7
                    ldd       ,u
                    std       >$4193
                    cmpu      #$10DC
                    bne       L83A9
                    clra
                    bra       L83AB

L83A9               lda       #$01
L83AB               sta       >$418C
                    clr       >$418D
                    clr       >$418E
                    clr       >$418F
L83B7               lda       >$418F
                    cmpa      #6
                    lbhs      L8639
                    tst       >$418D
                    lbne      L8639
                    lda       >$41B6
                    adda      >$4194
                    sta       >$4194
                    ldb       >$41B5
                    addb      >$4193
                    stb       >$4193
                    lbsr      L5AF2
                    sta       >$4188
                    ldd       #$4193
                    ldu       #$10DC
                    lbsr      L5A95
                    tsta
                    beq       L83F0
                    lda       #$C1
                    sta       >$4188
L83F0               lda       >$418F
                    ldb       #3
                    mul
                    addd      #$41BF
                    tfr       d,u
                    ldd       >$4193
                    std       ,u
                    lda       >$4194
                    ldb       >$4193
                    lbsr      L68D2
                    pshs      a
                    lda       >$418F
                    ldb       #3
                    mul
                    addd      #$41C1
                    tfr       d,u
                    puls      a
                    sta       ,u
                    cmpa      >$4189
                    bne       L8421
                    clr       ,u
L8421               lda       >$4188              Get map object
                    cmpa      #$20                blank (non-object map char)?
                    beq       L8446
                    cmpa      #$C4                If not door or any type of wall, skip ahead
                    blo       L8473
                    cmpa      #$CA
                    bhi       L8473
* Door, blank or any wall goes here
L8446               tst       >$418E
                    bne       L8458
                    tst       >$418C
                    bne       L8455
                    inc       >$418C
                    bra       L8458

L8455               clr       >$418C
L8458               clr       >$418E
                    neg       >$41B6
                    neg       >$41B5
                    ldd       >$41BB
                    pshs      d
                    ldu       #$40D9              'the %s bounces'
                    pshs      u
                    lbsr      L68D8
                    leas      4,s
                    lbra      L8633

L8473               tst       >$418C
                    lbne      L855C
                    lda       >$4194              Get Y coord
                    ldb       >$4193              Get X coord
                    lbsr      L2CDB               Search monster object list for matching monster in same position
                    stx       >$418A              Save monster object ptr
                    lbeq      L855C               None, skip ahead
                    lda       #1
                    sta       >$418C
                    tst       >$418E
                    bne       L8499
                    inc       >$418E
                    bra       L849C

L8499               clr       >$418E
L849C               lda       9,x
                    cmpa      #$40
                    beq       L84AD
                    lda       >$4194
                    ldb       >$4193
                    lbsr      L3BBB
                    sta       9,x
L84AD               lda       #$03
                    leay      ,x
                    lbsr      L37D3
                    tsta
                    beq       L84BC
                    tst       >$41B4
                    beq       L851A
L84BC               ldd       >$4193
                    std       >$419A
                    lda       #1
                    sta       >$418D
                    lda       7,x
                    cmpa      #$44                'D' (Dragon?)
                    bne       L84EA
                    ldu       #$40D3              'flame'
                    pshs      x
                    ldx       >$41BB
                    lbsr      L3FCD               Compare strings at ,u / ,x
                    puls      x
                    tsta
                    bne       L84EA
                    ldu       #$40E8              'the flame bounces off the dragon'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbra      L860D

L84EA               stx       >$418A
                    ldx       #$4195
                    lda       >$4194
                    ldb       >$4193
                    lbsr      L8978
                    lda       >$4194
                    lbsr      L68D2
                    cmpa      >$4189
                    lbeq      L860D
                    pshs      a
                    lda       >$418F
                    ldb       #3
                    mul
                    addd      #$41C1
                    tfr       d,u
                    puls      a
                    sta       ,u
                    lbra      L860D

L851A               lda       #$58                'X' (Xeroc?)
                    cmpa      >$4188
                    bne       L852A
                    ldx       >$418A
                    cmpa      8,x
                    lbne      L860D
L852A               ldd       >$41B7
                    cmpd      #$10DC
                    bne       L8539
                    ldx       #$4193
                    lbsr      L268D
L8539               lda       >$4188
                    suba      #$41
                    ldb       #18
                    mul
                    addd      #$10FB
                    tfr       d,u
                    ldd       ,u
                    pshs      d
                    ldd       >$41BB
                    pshs      d
                    ldu       #$4109              'the %s whizzes past the %s'
                    pshs      u
                    lbsr      L68D8
                    leas      6,s
                    lbra      L860D

L855C               tst       >$418C
                    lbeq      L860D
                    ldd       #$4193
                    ldu       #$10DC
                    lbsr      L5A95
                    tsta
                    lbeq      L860D
                    clr       >$418C
                    tst       >$418E
                    bne       L857E
                    inc       >$418E
                    bra       L8581

L857E               clr       >$418E
L8581               lda       #3
                    lbsr      L37F4
                    tsta
                    bne       L85FE
                    tst       >$41B4
                    beq       L85AD
                    ldu       #$4124              'You are frozen by a blast of frost from the Ice Monster'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lda       >$0D98
                    cmpa      #$14
                    bhs       L85E3
                    ldd       #$0007
                    lbsr      L5870
                    addb      >$0D98
                    stb       >$0D98
                    bra       L85E3

* 6809/6309 - ldd #$0606
L85AD               lda       #$06
                    ldb       #$06
                    lbsr      L63BB
                    pshs      d
                    ldd       >$10ED              Get players hit points
                    subd      ,s++                Subtract damage
                    std       >$10ED              Save it back
* 6809/6309 - redundant, remove cmpd
                    cmpd      #$0000
                    bgt       L85E3               If>0, continue
                    ldd       >$41B7
                    cmpd      #$10DC
                    bne       L85D3
                    lda       #'b                 Player killed by 'b'olt
                    lbsr      L0716               End game

* Another SWI leftover from internal testing
                    swi

L85D3               ldu       >$41B7              Get ptr
                    lda       1,u                 Get Y coord
                    ldb       ,u                  Get X coord
                    lbsr      L2CDB               Search monster object list for matching monster in same position
                    lda       7,x                 Get monster type (so end game can say what player was killed by)
                    lbsr      L0716               End game

* Another SWI - was used for internal testing
                    swi

L85E3               lda       #$01
                    sta       >$418D
                    tst       >$41B4
                    bne       L860D
                    ldd       >$41BB
                    pshs      d
                    ldu       #$415C              'you are hit by the %s'
                    pshs      u
                    lbsr      L68D8
                    leas      4,s
                    bra       L860D

L85FE               ldd       >$41BB
                    pshs      d
                    ldu       #$4172              'the %s whizzes by you'
                    pshs      u
                    lbsr      L68D8
                    leas      4,s
L860D               lbsr      L3BAB               Approx 2-3 tick time delay
                    ldb       >$4189              Get frost/fire, etc. char (\,|,/,-)
                    clra                          Put into D
                    pshs      x                   Save x, but 16 bit char into x
                    tfr       d,x
                    lda       >$4194
                    ldb       >$4193
                    lbsr      L68C4
                    puls      x
L8633               inc       >$418F
                    lbra      L83B7

L8639               clr       >$4191
L863C               lda       >$4191
                    cmpa      >$418F
                    bhs       L8686
                    lbsr      L3BAB
                    ldb       #3
                    mul
                    addd      #$41C1
                    tfr       d,u
                    tst       ,u
                    beq       L8681
                    lda       >$4191
                    ldb       #3
                    mul
                    std       >$41BD
                    addd      #$41C0
                    tfr       d,u
                    lda       ,u
                    pshs      a
                    ldd       >$41BD
                    addd      #$41BF
                    tfr       d,u
                    ldb       ,u
                    puls      a
                    std       >$355B
                    ldd       >$41BD
                    addd      #$41C1
                    tfr       d,u
                    lda       ,u
                    lbsr      L6612
L8681               inc       >$4191
                    bra       L863C

L8686               puls      pc,u,y,x,d

L8688               pshs      y,x,d
                    lda       <$13,y
                    anda      #$02
                    bne       L8698
                    ldu       #$41F1
                    clr       ,u
                    bra       L86AB

L8698               ldb       <$12,y
                    clra
                    pshs      d
                    ldd       #$41E3              ? ' [%d charges]'
                    pshs      d
                    ldx       #$41F1
                    lbsr      L3D23
                    leas      4,s
L86AB               ldu       #$41F1
                    puls      pc,y,x,d

* 'W'ear command
L86B0               pshs      u,x,d
                    ldd       >$0DB1
                    beq       L86C6
                    ldu       #$420A              'you are already wearing some. You'll have to take it off first.'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    clr       >$05FC
                    puls      pc,u,x,d

L86C6               ldx       #$4205              'wear'
                    lda       #$D0                Armor object type
                    lbsr      L711A
                    cmpx      #$0000
                    beq       L8704
                    lda       4,x
                    cmpa      #$D0                Is it an armor type?
                    beq       L86E5               Yes, skip ahead
                    ldu       #$424A              'you can't wear that'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    puls      pc,u,x,d

* 6809/6309 - BSR
L86E5               lbsr      L873F
                    lda       <$13,x
                    ora       #$02
                    sta       <$13,x
                    lda       #1
                    lbsr      L72B6
                    pshs      u
                    ldu       #$425E              'you are now wearing %s'
                    pshs      u
                    lbsr      L68D8
                    leas      4,s
                    stx       >$0DB1
L8704               puls      pc,u,x,d

* 'T'ake off command
L8706               pshs      u,x,d
                    ldx       >$0DB1
                    bne       L871C
                    clr       >$05FC
                    ldu       #$4275
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    puls      pc,u,x,d

L871C               lbsr      L77AC
                    tsta
                    beq       L873D
                    clra
                    clrb
                    std       >$0DB1
* 6809/6309 - inca
                    lda       #$01
                    lbsr      L72B6
                    pshs      u
                    lbsr      L723E
                    pshs      a
                    ldu       #$4292              'you used to be wearing %c) %s'
                    pshs      u
                    lbsr      L68D8
                    leas      5,s
L873D               puls      pc,u,x,d

L873F               lbsr      L5E58
                    lbra      L5EB2

* Part of Throw object
L8745               std       >$433D
                    pshs      u,y,x,d
                    lda       #$CF                Weapon object type
                    ldx       #$4337              'throw'
                    lbsr      L711A               Get ptr to object block that player is acting on
                    cmpx      #$0000              If none, exit
                    beq       L87D2
* 6809/6309 - we can change to enter at L77B7 if we add a pshs u,x in front)
                    lbsr      L77AC               Check if already in use
                    tsta                          Can we do action on the object?
                    beq       L87D2               No, exit
                    lbsr      L571E               Check if object block pointed to by X already in use
                    tsta
                    bne       L87D2               Yes, exit
L8766               lda       $E,x                No, get qty
                    cmpa      #2                  Is it 2 or higher?
                    bhs       L8777               Yes, skip ahead
                    ldu       #$10F5              No, Get root object from backpack
                    lbsr      L6112               Delete object ,X from backpack (update linked list)
                    dec       >$0D9A
                    bra       L87AB

*
L8777               pshs      x                   Save object block ptr
                    lbsr      L6162               Get next free inventory entry (max 40)
                    leau      ,x                  Move ptr to entry to U
                    puls      x                   Get original X back
                    cmpu      #$0000              Inventory full?
                    bne       L8796               No, skip ahead
                    lda       #1
                    sta       $E,x
                    ldu       #$4314              'something in your pack explodes!!!'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    bra       L8766

L8796               dec       $E,x
                    tst       <$15,x
                    bne       L87A0
                    dec       >$0D9A
L87A0               exg       x,u
                    lda       #$1F
                    lbsr      L3C51
                    lda       #1
                    sta       $E,x
* 6809/6309 - ldd >$433D
L87AB               lda       >$433D
                    ldb       >$433E
                    lbsr      L87D4
                    lda       6,x                 Get Y coord
                    ldb       5,x                 Get X coord
                    pshs      x                   Save X
                    lbsr      L2CDB               Search monster object list for matching monster in same position
                    leau      ,x                  Point U to monster object
                    puls      x                   Restore X
                    cmpu      #$0000
                    beq       L87CD               No monster object, skip ahead
                    lbsr      L8978
                    tsta
                    bne       L87D2
L87CD               lda       #$01
                    lbsr      L88B1
L87D2               puls      pc,u,y,x,d

L87D4               pshs      u,y,x,d
* 6809/6309 - std >$433F
                    sta       >$433F
                    stb       >$4340
                    lda       #$40
                    sta       >$4341
                    ldd       >$10DC
                    std       5,x
L87E6               lda       >$4341
                    cmpa      #$40
                    beq       L8815
                    leau      5,x
                    tfr       u,d
                    ldu       #$10DC
                    lbsr      L5A95
                    tsta
                    bne       L8815
                    lda       6,x
                    ldb       5,x
                    lbsr      L28A4
                    tsta
                    beq       L8815
                    leau      ,x
                    ldb       >$4341
                    clra
                    tfr       d,x
                    lda       6,u
                    ldb       5,u
                    lbsr      L68C4
                    leax      ,u
L8815               lda       6,x
                    adda      >$433F
                    sta       6,x
                    ldb       5,x
                    addb      >$4340
                    stb       5,x
                    lbsr      L5AF2
                    tfr       a,b
                    lbsr      L58E8               Check map piece;on return A=0 if blank, wall piece or monster, A=1 otherwise
                    tsta
                    beq       L8860
                    cmpb      #$CA                Door?
                    beq       L8860
                    lda       6,x
                    ldb       5,x
                    lbsr      L28A4
                    tsta
                    beq       L8859
                    lda       6,x
                    lbsr      L3BBB
                    sta       >$4341
                    lda       6,x
                    leay      ,x
                    tfr       d,x
                    clra
                    ldb       4,y
                    exg       d,x
                    lbsr      L68C4
                    leax      ,y
                    lbsr      L3BAB
                    bra       L87E6

L8859               lda       #$40
                    sta       >$4341
                    bra       L87E6

L8860               puls      pc,u,y,x,d

L8862               pshs      y,x,d
                    lda       4,x
                    cmpa      #$CF                Weapon object?
                    bne       L8874               No, try next object type
                    lda       $F,x                Get weapon type
                    lsla
                    ldu       #$004B              point to weapon name ptr table
                    ldu       a,u                 Point to specific weapon name
* 6809/6309 - replace with puls  pc,y,x,d
                    bra       L88AF

L8874               cmpa      #$D0                Armor object?
                    bne       L8882               no, try next object type
                    lda       $F,x                Get armor type
                    lsla
                    ldu       #$00C7              Point to armor name ptr table
                    ldu       a,u                 point to specific armor name
* 6809/6309 - replace with puls  pc,y,x,d
                    bra       L88AF

L8882               cmpa      #$CC                Food object?
                    bne       L888B               no, try next object type
                    ldu       #$4342              'food'
* 6809/6309 - replace with puls  pc,y,x,d
                    bra       L88AF

L888B               cmpa      #$CE                Potion?
                    beq       L889F               Yes, skip ahead
                    cmpa      #$CD                Scroll?
                    beq       L889F               yes, skip ahead
                    cmpa      #$D5                Amulet of Yendor?
                    beq       L889F               Yes, skip ahead
                    cmpa      #$D2                Wand/Staff?
                    beq       L889F               Yes, skip ahead
                    cmpa      #$D1                Ring?
                    bne       L88AC               Not other special types - special processing
L889F               lda       #$01
                    lbsr      L72B6
L88A4               lda       ,u+                 Search text for space
                    cmpa      #$20
                    bne       L88A4
* 6809/6309 - replace with puls  pc,y,x,d
                    bra       L88AF

L88AC               ldu       #$4347              'bizarre thing' (should never get hear - unknown object type)
* 6809/6309 - remove line, embed puls where each BRA L88AF appears above
L88AF               puls      pc,y,x,d

L88B1               pshs      u,y,x,d
                    sta       >$437E
                    ldu       #$437C
                    lbsr      L8A56
                    cmpa      #$01
                    bne       L891D
                    leay      ,x
                    lda       >$437D              Get Y/X coord
                    ldb       >$437C
                    lbsr      L5AAA               X=offset into 80x22 map
                    lda       4,y
                    sta       >$4B84,x            Save into main map
                    ldd       >$437C
                    std       5,y
                    lda       >$437D
                    ldb       >$437C
                    lbsr      L28A4
                    tsta
                    beq       L8913
                    lda       6,y
                    ldb       5,y
                    lbsr      L3BC6
L88F6               clra
                    ldb       4,y
                    tfr       d,x
                    lda       >$437D
                    ldb       >$437C
                    lbsr      L68C4
                    lbsr      L2CDB               Search monster object list for matching monster in same position
                    cmpx      #$0000
                    beq       L8913               No monster object at position, skip ahead
                    lda       4,y
                    sta       9,x
L8913               leax      ,y
                    ldu       #$10F7
                    lbsr      L6138
                    puls      pc,u,y,x,d

L891D               cmpa      #$02
                    bne       L8924
                    clr       >$437E
L8924               tst       >$437E
                    beq       L8938
                    lbsr      L8862
                    pshs      u
                    ldu       #$4355              'the %s vanishes as it hits the ground'
                    pshs      u
                    lbsr      L68D8
                    leas      4,s
L8938               leau      ,x
                    lbsr      L61A0
L893D               puls      pc,u,y,x,d

* Copy weapons damages into object block
* Entry: A=weapon sub-type
*        X=object block ptr
L893F               pshs      u,y,x,d
                    ldb       #6                  6 bytes per entry
                    mul
                    addd      #$42D8              Base of table (includes 2 ptrs to damage tables?, plus ??)
                    tfr       d,u
                    ldd       ,u                  Get ptr to first damage string
                    std       $A,x
                    ldd       2,u                 Get ptr to second damage string
                    std       $C,x
                    lda       4,u                 Get ???
                    sta       $9,x
                    lda       5,u                 Get object flags
                    sta       <$13,x
                    anda      #%00100000          $20 Is bit 6 set? (multi-qty allowed-arrows,darts,crossbow bolts)
                    beq       L8972               Yes, force to qty 1
                    lda       #8                  No, get RND(8)
                    lbsr      L63A9
                    adda      #8                  Add 8 more (so qty is 8-16)
                    sta       $E,x                Save as qty
                    lda       >$0DA6
                    sta       <$15,x
                    inc       >$0DA6
                    bra       L8976

L8972               lda       #1                  1 object
                    sta       $E,x
L8976               puls      pc,u,y,x,d

L8978               pshs      u,y,x,b
                    leau      ,x                  Preserve X in U
                    lbsr      L2CDB               Search monster object list for matching monster in same position
                    cmpx      #$0000
                    beq       L8997               No monster @ that position, skip ahead
                    sta       >$4380
                    ldy       #$437F
                    stb       ,y
                    ldb       7,x
                    lda       #1
                    lbsr      L2E75
                    puls      pc,u,y,x,b

L8997               clra
L8998               puls      pc,u,y,x,b

L899A               pshs      y,x,d
                    std       >$4398
                    tfr       a,b
                    sex
                    pshs      d
                    lda       >$4398
                    bge       L89B3
                    ldd       #$1470
                    bra       L89B6

L89B3               ldd       #$4396              '+'
L89B6               pshs      d
                    ldd       #$438B              '%s%d'
                    pshs      d
                    ldx       #$4381
                    lbsr      L3D23
                    leas      6,s
                    cmpu      #$00CF              >$00CF points to 'chain mail'
                    bne       L89FB
                    ldb       >$4399
                    sex
                    pshs      d
* 6809/6309 - tstb
                    cmpb      #0                  Can't use TSTB, since not just negative or zero branch
                    bge       L89DA
                    ldd       #$1470
                    bra       L89DD

L89DA               ldd       #$4396              '+'
L89DD               pshs      d
                    ldd       #$4390              ',%s%d'
                    pshs      d
                    ldx       #$4381
                    lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    tfr       a,b                 D=length
                    clra
                    pshs      d
                    ldd       #$4381              Add to start ptr
                    addd      ,s++
                    tfr       d,x                 Move end ptr to X
                    lbsr      L3D23
                    leas      6,s
L89FB               ldu       #$4381
                    puls      pc,y,x,d

* 'w'ield command
L8A00               pshs      u,y,x,d
                    ldx       >$0DB7
                    ldu       >$0DB7
                    lbsr      L77AC
                    stu       >$0DB7
                    tsta
                    beq       L8A54
                    ldx       #$439A              'wield'
                    lda       #$CF                Weapon object type
                    lbsr      L711A
                    cmpx      #$0000
                    bne       L8A23
L8A1E               clr       >$05FC
                    bra       L8A54

L8A23               lda       4,x
                    cmpa      #$D0                Armor type?
                    bne       L8A35
                    ldu       #$43A0              'you can't wield armor'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    bra       L8A1E

L8A35               lbsr      L571E
                    tsta
                    bne       L8A1E
                    lda       #1
                    lbsr      L72B6
                    stx       >$0DB7
                    lbsr      L723E
                    pshs      a
                    pshs      u
                    ldu       #$43B6              'you are now wielding %s (%c)'
                    pshs      u
                    lbsr      L68D8
                    leas      5,s
L8A54               puls      pc,u,y,x,d

L8A56               pshs      u,y,x,b
                    clr       >$43D7
                    lda       6,x
                    deca
                    sta       >$43D3
                    adda      #$02
                    sta       >$43D5
                    lda       5,x
                    inca
                    sta       >$43D6
L8A6C               lda       >$43D3
                    cmpa      >$43D5
                    lbhi      L8AFB
                    lda       5,x
                    deca
                    sta       >$43D4
L8A7C               lda       >$43D4
                    cmpa      >$43D6
                    bhi       L8AF5
* 6809/6309 - ldd >$43D3
                    lda       >$43D3
                    ldb       >$43D4
                    cmpa      >$10DD
                    bne       L8A94
                    cmpb      >$10DC
                    beq       L8AF0
L8A94               lbsr      L5ADE
                    tsta
                    bne       L8AF0
                    lda       >$43D3
                    lbsr      L3BBB
                    cmpa      #$C2                Floor?
                    beq       L8AA8               Yes, skip ahead
                    cmpa      #$C3                Hallway?
                    bne       L8ABD               No, skip ahead
L8AA8               inc       >$43D7
                    lda       >$43D7
                    lbsr      L63A9               RND(A)
                    tsta
                    bne       L8AF0
                    lda       >$43D3
                    sta       1,u
                    stb       ,u
                    bra       L8AF0

L8ABD               lbsr      L58E8               Check map piece;on return A=0 if blank, wall piece or monster, A=1 otherwise
                    tsta
                    beq       L8AF0
* 6809/6309 - ldd >$43D3
                    lda       >$43D3
                    ldb       >$43D4
                    leay      ,x
                    lbsr      L54E5
                    exg       x,y
* 6809/6309 - leay ,y - same speed, 2 bytes smaller
                    cmpy      #$0000
                    beq       L8AF0
                    lda       4,x
                    cmpa      4,y
                    bne       L8AF0
                    lda       <$15,y
                    beq       L8AF0
                    cmpa      <$15,x
                    bne       L8AF0
                    lda       $E,y
                    adda      $E,x
                    sta       $E,y
                    lda       #2
                    bra       L8B03

L8AF0               inc       >$43D4
                    bra       L8A7C

L8AF5               inc       >$43D3
                    lbra      L8A6C

L8AFB               clra
                    tst       >$43D7
                    beq       L8B03
                    lda       #$01
L8B03               puls      pc,u,y,x,b

* Read scroll routine
L8B05               pshs      u,y,x,d
                    clr       >$468E
                    ldx       #$43D8              'read'
                    lda       #$CD                Scroll o_type
                    lbsr      L711A
                    stx       >$468C
                    lbeq      L8FAF
                    cmpa      4,x
                    beq       L8B2A
                    ldu       #$43DD              'there is nothing on it to read'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbra      L8FAF

L8B2A               ldu       #$43FC              'as you read the scroll, it vanishes.'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    cmpx      >$0DB7
                    bne       L8B3F
                    clr       >$0DB7
                    clr       >$0DB8
L8B3F               lda       $F,x                Get scroll type
* 6809/6309 - redundant. Remove cmpa
                    cmpa      #$00
                    bne       L8B5A               Not 'confuse monster' scroll, skip ahead
                    ldd       >$10E4              ? Flag 'confuse monster' active for next attack by player?
                    ora       #$04
                    std       >$10E4
                    ldu       #$4420              'your hands begin to glow red'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbra      L8F6B

L8B5A               cmpa      #4                  Enchant armor?
                    bne       L8B7C               No, check next
                    ldu       >$0DB1              ? Get ptr to player stats?
                    beq       L8B79
                    dec       <$12,u              ? Dec armor class?
* 6809/6309 - replace 2 lines with lda #$FE
                    lda       #$01
                    coma
                    anda      <$13,u
                    sta       <$13,u
                    ldu       #$443D              'your armor glows faintly for a moment'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
L8B79               lbra      L8F6B

L8B7C               cmpa      #$02                Hold monster scroll?
                    bne       L8BE3               No, check next
                    lda       >$10DC
                    adda      #3
                    sta       >$4689
                    suba      #6
                    sta       >$4688
                    ldb       >$10DD
                    addb      #3
                    stb       >$468B
L8B95               lda       >$4688
                    cmpa      >$4689
                    bhi       L8BE0
                    cmpa      #$00                Can't use TSTA, since not just negative or zero branch
                    blo       L8BDB
                    cmpa      #80
                    bhs       L8BDB
                    ldb       >$10DD
                    subb      #3
                    stb       >$468A
L8BAD               ldb       >$468A
                    cmpb      >$468B
                    bhi       L8BDB
                    cmpb      #$00                Can't use TSTB, since not just negative or zero branch
                    bls       L8BD6
                    cmpb      >$0D8E
                    bhs       L8BD6
                    lda       >$468A              Get Y/X coords
                    ldb       >$4688
                    lbsr      L2CDB               Search monster object list for matching monster in same position
                    cmpx      #$0000
                    beq       L8BD6               No monster @ position, skip ahead
                    ldd       $C,x
                    anda      #$FF
                    andb      #$FB
                    orb       #$80
                    std       $C,x
L8BD6               inc       >$468A
                    bra       L8BAD

L8BDB               inc       >$4688
                    bra       L8B95

L8BE0               lbra      L8F6B

L8BE3               cmpa      #3                  Sleep scroll?
                    bne       L8C10               no, check next
* 6809/6309 - replace next 3 lines with ldd #$0501 / stb >$0601
                    ldb       #$01
                    stb       >$0601
                    lda       #5                  RND(5)
                    lbsr      L63A9
                    adda      #$04
                    adda      >$0D98
                    sta       >$0D98
                    ldd       >$10E4
                    anda      #$FF
                    andb      #$FB
                    std       >$10E4
                    ldu       #$4463              'you fall asleep'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbra      L8F6B

L8C10               cmpa      #10                 Create monster?
                    bne       L8C46               no, check next
                    lda       >$10DD
                    ldb       >$10DC
                    ldx       #$4686
                    lbsr      L2DE0
                    tsta
                    beq       L8C39
                    lbsr      L6162               Get next free inventory entry (max 40)
                    cmpx      #$0000              Inventory full?
                    beq       L8C39               Yes, skip ahead
                    leau      ,x                  Copy inventory entry ptr to U
                    clra                          Use first monster/level generation string
                    lbsr      L29A7               Go generate monster
                    ldx       #$4686
                    lbsr      L29E5
                    bra       L8C43

L8C39               ldu       #$4473              'you hear a faint cry of anguish in the distance'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
L8C43               lbra      L8F6B

L8C46               cmpa      #5                  Identify scroll?
                    bne       L8C7F               No, check next
                    ldb       #$01
                    stb       >$0603
                    ldu       #$44A3              'this scroll is an identify scroll'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    ldx       #$1523              'on'
                    ldu       #$4678              'on'
                    lbsr      L3FCD               Compare strings at ,u / ,x
                    tsta
                    beq       L8C6E
                    ldu       #$467B              'sel'
                    lbsr      L3FCD               Compare strings at ,u / ,x
                    tsta
                    bne       L8C74
L8C6E               ldx       #$467F              ' More '
                    lbsr      L697B
L8C74               lbsr      L46AD
                    lda       #$01
                    sta       >$05FC
                    lbra      L8F6B

L8C7F               cmpa      #1                  Magic Mapping?
                    lbne      L8D5D               No, check next
                    ldb       #$01
                    stb       >$05FF
                    ldu       #$44C5              'oh, now this scroll has a map on it'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lda       #1                  Init Y pos in map we are working on
                    sta       >$468A
L8C99               lda       >$468A              Get current Y pos we are working on
                    cmpa      #22                 Are we done last line?
                    lbhs      L8D5A               yes, skip ahead
                    clrb                          Init X pos in map we are working on
                    stb       >$4688
L8CA6               ldb       >$4688              Get current X pos we are working on
                    cmpb      #80                 Done entire line?
                    lbhs      L8D54               Yes, skip ahead
                    lda       >$468A              Get Y pos back
                    lbsr      L5AAA               X=offset into 80x22 map
                    lda       >$4B84,x            Get char from screen map #1 tbl
                    sta       >$468F              Save copy
                    cmpa      #$C4                Check if it is any kind of wall object
                    blo       L8CF2
                    cmpa      #$C9
                    bhi       L8CF2
L8CD4               lda       >$5264,x            If it's any of 6 wall types, get equivalent byte from flags map
                    anda      #%00010000          Is it a door that has not been searched/found yet?
                    bne       L8D1E               Nope, skip ahead
                    lda       #$CA                Door
                    sta       >$4B84,x            Not hidden anymore, save door in map
                    sta       >$468F              Save temp copy as door now
                    lda       #%11101111          Flip "hidden door" bit in flags map
                    anda      >$5264,x            Clear 5th bit in flags map
                    sta       >$5264,x
                    bra       L8D1E

L8CF2               cmpa      #$CA                Door?
                    beq       L8CFE               Yes, skip ahead
                    cmpa      #$C3                Hallway?
                    beq       L8CFE               Yes, skip ahead
                    cmpa      #$D3                Stairs?
                    bne       L8D19               No, skip ahead
* Comes here only if A was door, hallway or stairs
L8CFE               lda       >$468A              Get Y pos back
                    ldb       >$4688              Get X pos back
                    lbsr      L2CDB               Search monster object list for matching monster in same position
                    cmpx      #$0000
                    beq       L8D1E               No monster at position, skip ahead
                    lda       9,x
                    cmpa      #$20                Space?
                    bne       L8D1E
                    lda       >$468F
                    sta       9,x
                    bra       L8D1E

L8D19               lda       #$20                No active map object, print space
                    sta       >$468F
L8D1E               lda       >$468F
                    cmpa      #$CA                Door?
                    bne       L8D38               No, skip ahead
                    lda       >$468A              Get Y pos
                    ldb       >$4688              Get X pos
                    std       >$355B              Save them
                    lbsr      L65E6
                    cmpa      #$CA                Door?
                    beq       L8D38
L8D38               ldb       >$468F
                    cmpb      #$20
                    beq       L8D4B
                    clra
                    tfr       d,x
                    lda       >$468A
                    ldb       >$4688
                    lbsr      L68C4
L8D4B               inc       >$4688
                    lbra      L8CA6

L8D54               inc       >$468A
                    lbra      L8C99

L8D5A               lbra      L8F6B

L8D5D               cmpa      #7                  Food Detection?
                    bne       L8DCE               No, check next
                    clr       >$468F
                    ldx       >$10F7
L8D67               cmpx      #$0000
                    beq       L8DAB
                    lda       4,x                 Get o_type
                    cmpa      #$CC                Food type?
                    bne       L8D8B               No, skip ahead
                    lda       #1
                    sta       >$468F
                    lda       6,x
                    ldb       5,x
                    std       >$355B
                    lda       #$CC                Food type
                    lbsr      L6612
                    bra       L8DA6

L8D8B               cmpa      #$D5                Amulet type?
                    bne       L8DA6
                    lda       #1
                    sta       >$468F
                    lda       6,x
                    ldb       5,x
                    std       >$355B
                    lda       #$D5
                    lbsr      L6612
L8DA6               ldx       ,x
                    bra       L8D67

L8DAB               ldb       >$468F              ? Food found on current level flag?
                    beq       L8DC1               No food on level, different message
                    ldb       #1
                    stb       >$0605
                    ldu       #$44E9              'your nose tingles as you sense food'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    bra       L8DCB

L8DC1               ldu       #$450D              'you hear a growling noise very close to you'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
L8DCB               lbra      L8F6B

L8DCE               cmpa      #8                  Teleportation?
                    bne       L8DE5               No, check next
                    ldx       >$10F3
                    lbsr      L49CC
                    cmpx      >$10F3
                    beq       L8DE2
                    ldb       #1
                    stb       >$0606
L8DE2               lbra      L8F6B

L8DE5               cmpa      #9                  Enchant weapon?
                    bne       L8E30               No, check next
                    ldx       >$0DB7              Get ptr to object block for weapon being wielded
                    beq       L8DF4               None, skip ahead
                    lda       4,x                 Get object type
                    cmpa      #$CF                Weapon type?
                    beq       L8E00               Yes, skip ahead
L8DF4               ldu       #$4539              'you feel a strange sense of loss'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    bra       L8E2D

* 6809/6309 - replace 2 lines with lda #$FE
L8E00               lda       #1                  First, clear any curse on wielded weapon
                    coma
                    anda      <$13,x
                    sta       <$13,x
                    lda       #2                  RND(2)
                    lbsr      L63A9
                    tsta
                    bne       L8E16
                    inc       <$10,x              Increase blessing level by 1
                    bra       L8E19

L8E16               inc       <$11,x
L8E19               lda       $F,x                Get which object sub-type
                    lsla                          *2 for ptr
                    ldu       #$004B              Point to weapon name table
                    ldd       a,u                 Point to our weapon
                    pshs      d
                    ldu       #$455A              'your %s glows blue for a moment'
                    pshs      u
                    lbsr      L68D8
                    leas      4,s
L8E2D               lbra      L8F6B

L8E30               cmpa      #6                  Scare monster?
                    bne       L8E41               No, check next
                    ldu       #$464D              'you hear maniacal laughter in the distance'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbra      L8F6B

L8E41               cmpa      #11                 Remove curse?
                    bne       L8E8D               No, check next
* 6809/6309 - replace 2 lines with lda #$FE
                    lda       #1
                    coma
                    pshs      a
                    ldx       >$0DB1              Get ptr to object block for armor being worn
                    beq       L8E57               None, skip ahead
                    lda       ,s
                    anda      <$13,x              clear curse flag on armor
                    sta       <$13,x
L8E57               ldx       >$0DB7              Get ptr to object block for weapon being wielded.
                    beq       L8E64               No, skip ahead
                    lda       ,s
                    anda      <$13,x              clear curse flag on weapon
                    sta       <$13,x
L8E64               ldx       >$0DB3              Get ptr to object block for ring on left hand
                    beq       L8E71               None, skip ahead
                    lda       ,s
                    anda      <$13,x              clear curse flag on left ring
                    sta       <$13,x
L8E71               ldx       >$0DB5              Get ptr to object block for ring on right hand
                    beq       L8E7E               None, skip ahead
                    lda       ,s
                    anda      <$13,x              Clear curse flag on right ring
                    sta       <$13,x
L8E7E               leas      1,s
                    ldu       #$457A              'you feel as if somebody is watching over you'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbra      L8F6B

L8E8D               cmpa      #12                 Aggravate monsters?
                    bne       L8EA1               No, check next
                    lbsr      L56C9
                    ldu       #$45A7              'you hear a high pitched humming noise'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbra      L8F6B

L8EA1               cmpa      #13                 Blank paper?
                    bne       L8EB2               No, check next
                    ldu       #$45CD              'this scroll seems to be blank'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbra      L8F6B

L8EB2               cmpa      #14                 Vorpalize weapon?
                    lbne      L8F61               No, check next
                    ldx       >$0DB7              Get weapon wielded object block ptr
                    beq       L8EC3               none, skip ahead
                    lda       4,x                 Get object type
                    cmpa      #$CF                Weapon?
                    beq       L8ED0               Yes, go vorpalize it
L8EC3               ldu       #$464D              No, 'you hear maniacal laughter in the distance'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbra      L8F5E

L8ED0               tst       <$14,x
                    beq       L8EFC
                    lda       $F,x                Get which weapon type
                    lsla
                    ldu       #$004B              Point to weapon name tbl
                    ldd       a,u                 Get ptr to our weapon name
                    pshs      d
                    ldu       #$45EB              'your %s vanishes in a puff of smoke'
                    pshs      u
                    lbsr      L68D8
                    leas      4,s
                    ldu       #$10F5              Get ptr to root object in backpack
                    lbsr      L6112               Delete object ,X from backpack (update linked list)
                    leau      ,x
                    lbsr      L61A0
                    ldx       #$0000              Set so that player has no weapon wielded.
                    stx       >$0DB7
                    bra       L8F5E

L8EFC               lbsr      L2CB5
                    sta       <$14,x
                    inc       <$10,x              Increase blessing level of weapon
                    inc       <$11,x              Increase damage(?) level of weapon
                    lda       #1                  ??? flag something for weapon
                    sta       <$12,x
                    ldu       #$1473              ' of intense white light'
                    pshs      u
                    lda       $F,x                Get which type weapon
                    lsla                          * 2 for pointer
                    ldu       #$004B              Point to weapons name table
                    ldd       a,u                 Our specific weapon
                    pshs      d
                    ldu       #$148B              'your %s gives off a flash%s'
                    pshs      u
                    lbsr      L68D8
                    leas      6,s
                    lda       #20                 RND(20)
                    lbsr      L63A9
                    tsta
                    bne       L8F5E
* 6809/6309 - replace 6 lines with lda #$41 / ora <$13,x / sta <$13,x
                    lda       #1                  Set cursed/blessed flag?
                    ora       <$13,x
                    sta       <$13,x
                    lda       #$40                ??? some other flag
                    ora       <$13,x
                    sta       <$13,x
                    ldb       #$01
                    stb       >$060C
                    lda       <$14,x              Get monster letter
                    suba      #$41                Make binary (0-25)
                    ldb       #18
                    mul
                    addd      #$10FB              Point to base of monster table
                    tfr       d,u
                    ldd       ,u                  Get pointer to monster name
                    pshs      d
                    ldu       #$460F              'you feel a sudden desire to kill %ss.'
                    pshs      u
                    lbsr      L68D8
                    leas      4,s
L8F5E               bra       L8F6B

L8F61               ldu       #$4635              'what a puzzling scroll!' (you should never get this)
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
L8F6B               lda       #$01
                    lbsr      L5088
                    lbsr      L6AA2
                    dec       >$0D9A
                    ldx       >$468C
                    lda       $E,x                Get quantity of object
                    cmpa      #1                  If 1, remove object from backpack
                    bls       L8F83
                    dec       $E,x                Otherwise, drop count by 1
                    bra       L8F8E

L8F83               ldu       #$10F5              Get ptr to root object in backpack
                    lbsr      L6112               Delete object ,X from backpack (update linked list)
                    lda       #1
                    sta       >$468E
L8F8E               lda       $F,x                ??? Get which sub-type of object?
                    ldu       #$05FE
                    lda       a,u
                    pshs      a
                    lda       $F,x
                    lsla
                    ldx       #$07ED
                    leax      a,x
                    puls      a
                    lbsr      L5897
                    tst       >$468E
                    beq       L8FAF
                    ldu       >$468C
                    lbsr      L61A0
L8FAF               puls      pc,u,y,x,d

* 'q'uaff command
L8FB1               pshs      u,y,x,d
                    clr       >$4901
                    lda       #$CE                Potion object
                    ldx       #$4690              'quaff'
                    lbsr      L711A
                    stx       >$48FD
                    lbeq      L9383
                    cmpa      4,x                 Is this a potion object?
                    beq       L8FD6               Yes, go drink the potion
                    ldu       #$4696              No, 'yuk! Why would you want to drink that?'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbra      L9383

L8FD6               cmpx      >$0DB7              Is drink object being wielded as a weapon?
                    bne       L8FDE               No, skip ahead
                    ldx       #$0000              Yes, set object ptr to 0
L8FDE               lda       $F,x                Get which type of potion
                    bne       L9025               not confusion, try next type
                    ldb       #$01                Flag that player will now recognize potion of confusion
                    stb       >$060D
                    ldx       #$10D8
                    ldd       #$0100
                    lbsr      L3C3C
                    pshs      a
                    ldd       #$0008
                    lbsr      L6396
                    addd      #$0014
                    ldu       #L5FAB+PrgOffst-$1B2 (#$BDF9)
                    tst       ,s+
                    beq       L9009
                    lbsr      L5E90
                    bra       L9010

L9009               tfr       d,y
                    clra
                    clrb
                    lbsr      L5E82
* 6809/6309 - lda >$10E4 / ora #$01 / sta >$10E4
L9010               ldd       >$10E4              Get player status flags
                    ora       #$01                Set confusion flag
                    std       >$10E4              Save it back
                    ldu       #$46BD              'wait, what's going on? Huh? What? Who?'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbra      L9346

L9025               cmpa      #2                  Poison potion?
                    bne       L905F               No, check next
                    ldu       #$46E4              'you feel %s sick'
                    stu       >$4902
                    lda       #$01
                    sta       >$060D+2            Flag player recognizes poison potion
                    lda       #$02                Is player wearing Sustain strength ring?
                    lbsr      L3C00
                    tsta
                    bne       L904D               Yes, we are protected against poison, skip ahead
                    lda       #3                  RND(3)
                    lbsr      L63A9
                    inca
                    nega
                    lbsr      L55F0
                    ldu       #$46F6              'very'
                    pshs      u
                    bra       L9052

L904D               ldu       #$46FB              'momentarily'
                    pshs      u
L9052               ldu       >$4902
                    pshs      u
                    lbsr      L68D8
                    leas      4,s
                    lbra      L9346

L905F               cmpa      #5                  Healing poition?
                    bne       L9098               No, check next
                    lda       #$01
                    sta       >$060D+5            Flag player knows healing potion
                    ldb       #$04
                    lda       >$10EB              Get players rank
                    lbsr      L63BB
                    addd      >$10ED              Add hit points
                    std       >$10ED              Save new total
                    cmpd      >$10F1              Are we now past fully healed?
                    ble       L9088               No, skip ahead
                    ldd       >$10F1              We were fully healed, increase our max hit points by 1
                    addd      #$0001
                    std       >$10F1              Save new max hit points
                    std       >$10ED              Save as new current hit points
L9088               lbsr      L5FFF
                    ldu       #$4707              'you begin to feel better'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbra      L9346

L9098               cmpa      #3                  Gain Strength potion?
                    bne       L90B1               No, check next
                    lda       #$01
                    sta       >$060D+3            Flag player knows Gain Strength potion
                    lbsr      L55F0
                    ldu       #$4720              'you feel stronger. What bulging muscles!'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbra      L9346

L90B1               cmpa      #6                  Monster Detection potion?
                    bne       L90EA               No, check next
                    ldu       #L93BF+PrgOffst-$1B2 (#$F20D)
                    ldd       #$0100              Init flags(?) to $0100
                    ldy       #$0014              Counter to 20
                    lbsr      L5E82               Add to table @ u2C24
                    ldd       >$10F9
                    bne       L90D3
                    ldu       #$4749              'you have a strange feeling for a moment'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    bra       L90E7

L90D3               clra
                    lbsr      L93BF
                    ora       >$0613
                    sta       >$0613
                    ldu       #$1470
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
L90E7               lbra      L9346

L90EA               cmpa      #7                  Magic detection potion?
                    lbne      L9189               No, try next
                    ldx       >$10F7
                    lbeq      L917C
                    clr       >$4904
L90FA               cmpx      #$0000
                    beq       L9129
                    lbsr      L39CF               No, check if "normal" (not blessed/cursed) weapon/armor or food
                    tsta
                    beq       L9124
                    lda       #$01
                    sta       >$4904
                    leay      ,x
                    lbsr      L5918
                    clra
                    pshs      x
                    tfr       d,u
                    lda       6,x
                    ldb       5,x
                    leax      ,u
                    lbsr      L68C4
                    puls      x
                    lda       #$01
                    sta       >$060D+7            Flag player knows Magic Detection potion
L9124               ldx       ,x
                    bra       L90FA

L9129               ldy       >$10F9
* 6809/6309 - leay ,y
L912D               cmpy      #$0000
                    beq       L916B
                    ldx       <$1D,y
L9136               cmpx      #$0000
                    beq       L9162
                    lbsr      L39CF               No, check if "normal" (not blessed/cursed) weapon/armor or food
                    tsta
                    beq       L915D
                    lda       #$01
                    sta       >$4904
                    ldb       #$D6
                    clra
                    pshs      x
                    tfr       d,u
                    lda       5,y
                    ldb       4,y
                    leax      ,u
                    lbsr      L68C4
                    puls      x
                    lda       #$01
                    sta       >$060D+7            Flag player knows Magic Detection potion
L915D               ldx       ,x
                    bra       L9136

* 6809/6309 - I think the next 3 lines could be ldx ,y / leay ,x
L9162               leax      ,y
                    ldx       ,x
                    leay      ,x
                    bra       L912D

L916B               tst       >$4904              Did we find magic items on this level?
                    beq       L917C               No
                    ldu       #$47A8              Yes, 'You sense the presence of magic.'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    bra       L9186

L917C               ldu       #$4771              'you have a strange feeling for a moment then it passes'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
L9186               lbra      L9346

L9189               cmpa      #1                  Paralysis potion?
                    bne       L91AE               No, try next
                    lda       #$01                Flag player knows Paralysis potion
                    sta       >$060D+1
                    lda       #$02
                    sta       >$0D98
                    ldd       >$10E4
                    anda      #$FF
                    andb      #$FB
                    std       >$10E4
                    ldu       #$47C9              'you can't move'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbra      L9346

L91AE               cmpa      #4                  See Invisible potion?
                    bne       L91E6               No, try next
                    ldx       #$10D8
                    ldd       #$0800
                    lbsr      L3C3C
                    tsta
                    bne       L91D1
                    ldu       #L5FC3+PrgOffst-$1B2 (#$BE11)
                    clra
                    clrb
                    ldy       #$012C
                    lbsr      L5E82
                    clra
                    lbsr      L5088
                    lbsr      L9385
L91D1               lbsr      L5FFF
                    ldu       #$150B              'Slime Mold'
                    pshs      u
                    ldu       #$47D8              'this potion tastes like %s juice'
                    pshs      u
                    lbsr      L68D8
                    leas      4,s
                    lbra      L9346

L91E6               cmpa      #8                  Raise Level potion?
                    bne       L91FF               No, try next
                    lda       #$01
                    sta       >$060D+8            Flag that player knows Raise level potion
                    ldu       #$47F9              'you suddenly feel much more skillfull'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbsr      L38A8
                    lbra      L9346

L91FF               cmpa      #9                  Extra Healing potion?
                    bne       L9255               No, try next
                    lda       #$01
                    sta       >$060D+9            Flag that player knows Extra Healing potion
                    lda       >$10EB              Get players rank
                    ldb       #8
                    lbsr      L63BB
                    addd      >$10ED              Add hit points to player
                    std       >$10ED
                    cmpd      >$10F1              Are we past players current maximum HP?
                    ble       L9245               No, we are done adding
                    tfr       d,u
                    ldd       >$10F1              Get players max hit points
                    addd      >$10EB              Add players rank & armor class
                    addd      #$0001              and one more
                    pshs      d
                    tfr       u,d
                    cmpd      ,s++
                    ble       L9239               If player not already fully healed, heal them and bump up max by 1
                    ldd       >$10F1              Player fully healed already; add 2 to max
                    addd      #$0001
                    std       >$10F1
L9239               ldd       >$10F1
                    addd      #$0001
                    std       >$10F1              Save new max hit points
                    std       >$10ED              Save new current hit points
L9245               lbsr      L5FFF
                    ldu       #$481E              'you begin to feel much better'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbra      L9346

L9255               cmpa      #10                 Haste Self potion?
                    bne       L9271               No, check next
                    lda       #$01
                    sta       >$060D+10           Flag that player knows Haste Self potion
                    lbsr      L565D
                    tsta
                    beq       L926E
                    ldu       #$483C              'you feel yourself moving much faster'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
L926E               lbra      L9346

L9271               cmpa      #11                 Restore strength potion?
                    bne       L92F2               No, check next
* 6809/6309 - LDD #$0001
                    lda       #$00                Check if player wearing Add strength ring on left hand
                    ldb       #$01
                    lbsr      L3BE8
                    tsta
                    beq       L928D
                    ldy       >$0DB3              Get ptr to object block for ring on left hand
                    lda       <$12,y              Get ???
                    nega
                    ldx       #$10E6
                    lbsr      L563F
* 6809/6309 - LDD #$0101
L928D               lda       #$01                Check if player wearing Add strength ring on right hand
                    ldb       #$01
                    lbsr      L3BE8
                    tsta
                    beq       L92A5
                    ldy       >$0DB5              Get ptr to object block for ring on right hand
                    lda       <$12,y
                    nega
                    ldx       #$10E6
                    lbsr      L563F
L92A5               ldd       >$10A7
                    pshs      d
                    tfr       d,u
                    ldd       >$10E6
                    cmpd      ,s++
                    bhs       L92B7
                    stu       >$10E6
* 6809/6309 - LDD #$0001
L92B7               lda       #$00                Check if player wearing Add strength ring on left hand
                    ldb       #$01
                    lbsr      L3BE8
                    tsta
                    beq       L92CE
                    ldy       >$0DB3              Get ptr to object block for ring on left hand
                    lda       <$12,y
                    ldx       #$10E6
                    lbsr      L563F
* 6809/6309 - LDD #$0101
L92CE               lda       #$01                Check if player wearing Add strength ring on right hand
                    ldb       #$01
                    lbsr      L3BE8
                    tsta
                    beq       L92E5
                    ldy       >$0DB5              Get ptr to object block for ring on right hand
                    lda       <$12,y
                    ldx       #$10E6
                    lbsr      L563F
L92E5               ldu       #$4861              'hey, this tastes great.  It makes you feel warm all over'
                    pshs      u                   (restore strength if player @ full strength)
                    lbsr      L68D8
                    leas      2,s
                    bra       L9346

L92F2               cmpa      #12                 Blindness potion?
                    bne       L932B               No, check next
                    lda       #$01
                    sta       >$060D+12           Flag players knows blindness potion
                    ldx       #$10D8
                    ldd       #$0001
                    lbsr      L3C3C
                    tsta
                    bne       L931E
                    ldd       >$10E4              Set player bit flag for blindness
                    orb       #$01
                    std       >$10E4
                    ldu       #L5FFF+PrgOffst-$1B2 (#$BE4D)
                    clra
                    clrb
                    ldy       #$012C
                    lbsr      L5E82
                    lbsr      L5088
L931E               ldu       #$489A              'a cloak of darkness falls around you'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    bra       L9346

L932B               cmpa      #13                 Thirst Quenching potion?
                    bne       L933C               No, skip ahead
                    ldu       #$48BF              'this potion tastes extremely dull'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    bra       L9346

L933C               ldu       #$48E1              'what an odd tasting potion!' (should never see this)
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
L9346               lbsr      L6AA2
                    dec       >$0D9A
                    ldx       >$48FD
                    lda       $E,x                Get qty
                    cmpa      #1                  If just 1, delete item from backpack
                    bls       L9359
                    dec       $E,x                Otherwise, drop count by 1
                    bra       L9364

L9359               ldu       #$10F5              Get ptr to root object in backpack
                    lbsr      L6112               Delete object ,X from backpack (update linked list)
                    lda       #1
                    sta       >$4901
L9364               lda       $F,x
                    pshs      a
                    lsla
                    ldx       #$080B
                    leax      a,x
                    ldu       #$060D              Get ptr to flags for which potion types are known to player
                    puls      a
                    lda       a,u
                    lbsr      L5897
                    tst       >$4901
                    beq       L9383
                    ldu       >$48FD
                    lbsr      L61A0
L9383               puls      pc,u,y,x,d

L9385               pshs      u,y,x,d
* 6809/6309 - lda >$10E4 / ora #$08 / sta >$10E4
                    ldd       >$10E4              Get player status flags
                    ora       #$08                Set "see invisible" flag
                    std       >$10E4              Save it back
                    ldx       >$10F9
L9392               cmpx      #$0000
                    beq       L93BD
                    ldd       #$0010
                    lbsr      L3C3C
                    tsta
                    beq       L93B8
                    lbsr      L25F0
                    tsta
                    beq       L93B8
                    ldb       8,x
                    clra
                    pshs      x
                    tfr       d,u
                    lda       5,x
                    ldb       4,x
                    leax      ,u
                    lbsr      L68C4
                    puls      x
L93B8               ldx       ,x
                    bra       L9392

L93BD               puls      pc,u,y,x,d

L93BF               pshs      u,y,x,b
                    sta       >$490C
                    clr       >$4907
                    ldx       >$10F9
L93CA               cmpx      #$0000
                    beq       L9426
                    lda       5,x
                    ldb       4,x
                    std       >$355B
                    lbsr      L25F0
                    tsta
                    bne       L93E9
                    lbsr      L65E6
                    sta       >$490B
                    cmpa      7,x
                    beq       L93E9
                    clra
                    bra       L93EB

L93E9               lda       #$01
L93EB               sta       >$4908
                    tst       >$490C
                    beq       L9404
                    lbsr      L25F0
                    tsta
                    bne       L9421
                    lda       9,x
                    cmpa      #$40
                    beq       L9421
                    lbsr      L6612
                    bra       L9421

L9404               tst       >$4908
                    bne       L9411
                    lda       >$490B
                    sta       9,x
L9411               lda       7,x
                    lbsr      L6612
                    tst       >$4908
                    bne       L9421
                    inc       >$4907
L9421               ldx       ,x
                    bra       L93CA

L9426               ldd       >$10E4              Get player status flags
                    orb       #$02                Set monster detection flag
                    std       >$10E4
                    tst       >$490C              ??? Maybe # of monsters on current level?
                    beq       L943A
                    anda      #$FF                If >$490C is <>0, then clear monster detection flag
                    andb      #$FD
                    std       >$10E4
L943A               lda       >$4907
                    puls      pc,u,y,x,b

* Throwing potions as a weapon
L943F               pshs      u,y,x,d
                    tfr       d,y
                    lda       $0F,y               Get which type of potion was thrown
                    beq       L944F               Confusion potion thrown
                    cmpa      #$0C                Blindness potion thrown?
                    bne       L9472               No, check next
L944F               lda       $C,x                Flag monster confused
                    ora       #$01
                    sta       $C,x
                    lda       7,x                 Get monster letter
                    suba      #$41                Make binary (from ASCII)
                    ldb       #18                 18 bytes/monster table entry
                    mul
                    addd      #$10FB              Point into monster table
                    tfr       d,u
                    ldd       ,u                  Point to monster name
                    pshs      d
                    ldu       #$490D              'the %s appears confused'
                    pshs      u
                    lbsr      L68D8
                    leas      4,s
                    bra       L94D7

L9472               cmpa      #1                  Paralysis potion thrown?
                    bne       L9483               No, check next
                    ldd       $C,x                Get flags
                    anda      #%11111111          $FF
                    andb      #%11111011          $FB  Clear paralyzed bit (Which means paralyzed)
                    orb       #%10000000          $80  ?? Set trapped (like Venus Flytrap) bit
                    std       $C,x
                    bra       L94D7

L9483               cmpa      #5                  Healing potion thrown?
                    beq       L948D               Yes, go do
                    cmpa      #9                  Extra healing potion thrown?
                    bne       L94AE               No, check next
L948D               ldd       #$0008              Divisor
                    lbsr      L6396               I think add up to RND(HP of monster/8) HP to monster
                    addd      <$15,x
                    std       <$15,x
                    cmpd      <$19,x              Past maximum for monster?
                    ble       L94AB               No, done
                    ldd       <$19,x              Yes, increase monsters HP by 1 (both current & max)
                    addd      #$0001
                    std       <$19,x
                    std       <$15,x
L94AB               bra       L94D7

L94AE               cmpa      #8                  Raise Level potion thrown?
                    bne       L94CA               No, check next
                    ldd       <$15,x              Get monsters hit points
                    addd      #$0008              Add 8
                    std       <$15,x              Save new total
                    ldd       <$19,x              Get monsters max hitpoints
                    addd      #$0008              Add 8
                    std       <$19,x              Save that as well
                    inc       <$13,x              ???
                    bra       L94D7

L94CA               cmpa      #10                 Haste Self potion thrown?
                    bne       L94D7               No, do generic 'the flask shatters'
* 6809/6309 - lda #$C,x / ora #$40 / sta $C,x
                    ldd       $C,x                Get flags
                    ora       #$40
                    std       $C,x
L94D7               ldu       #$4925              'the flask shatters'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    puls      pc,u,y,x,d

* 'P'ut on command
L94E3               pshs      u,y,x,d
                    ldx       #$493F              'put on'
                    lda       #$D1                Ring object
                    lbsr      L711A
                    cmpx      #$0000
                    beq       L956E
                    lda       4,x                 Get object type
                    cmpa      #$D1                Ring?
                    beq       L9504               Yes, put it on (if we can)
                    ldu       #$4946              'you can't put that on your finger'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    bra       L956E

L9504               lbsr      L571E
                    tsta
                    bne       L956E
                    ldu       >$0DB3              Get ptr to object block for ring on left hand
                    bne       L951F               Already something there, skip ahead
* 6809/6309 - redundant since A has to be 0 to get here. Remove lda
                    lda       #$00                Offset for left hand
                    ldu       >$0DB5              Get ptr to object block for ring on right hand
                    bne       L9532               Already something there too, skip ahead
                    lbsr      L95CA
                    cmpa      #$FF
                    beq       L956E
                    bra       L9532

L951F               lda       #$01                Offset for right hand
                    ldu       >$0DB5              Get ptr to object block for ring on right hand
                    beq       L9532               It's empty, skip ahead
                    ldu       #$4968              'you already have a ring on each hand'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    bra       L956E

L9532               lsla                          2 bytes/entry
                    ldu       #$0DB3              Get ptr to object block for ring on left hand
                    stx       a,u                 Save ptr to either left hand or right hand
                    lda       $F,x                Get Which type of ring
                    cmpa      #1                  Add strength?
                    bne       L9546               No, try next
                    lda       <$12,x              ??? vorpalized?
                    lbsr      L55F0
                    bra       L9556

L9546               cmpa      #4                  See Invisible?
                    bne       L954F               No, try next
                    lbsr      L9385
                    bra       L9556

L954F               cmpa      #6                  Aggravate Monster?
                    bne       L9556               No, try next
                    lbsr      L56C9
L9556               lbsr      L723E
                    pshs      a
                    lda       #$01
                    lbsr      L72B6
                    pshs      u
                    ldu       #$498D              'you are now wearing %s (%c)'
                    pshs      u
                    lbsr      L68D8
                    leas      5,s
                    puls      pc,u,y,x,d

L956E               clr       >$05FC
                    puls      pc,u,y,x,d

* 'R'emove command
L9573               pshs      u,y,x,d
                    ldu       >$0DB3              Get ptr to object block of ring on left hand
                    beq       L958A               Empty, skip ahead
* 6809/6309 - CLRA
                    lda       #$00
                    ldu       >$0DB5              Get ptr to object block of ring on right hand
                    beq       L959D               Empty, skip ahead
                    lbsr      L95CA
                    cmpa      #$FF
                    beq       L95C5
                    bra       L959D

L958A               lda       #$01
                    ldu       >$0DB5              Get ptr to object block of ring on right hand
                    bne       L959D
                    ldu       #$49A9              'you aren't wearing any rings'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    puls      pc,u,y,x,d

* Entry: A=0 (left hand) or 1 (right hand)
L959D               lsla                          2 bytes per hand entry
                    ldu       #$0DB3              Get ptr to object block of rings on hands
                    ldx       a,u                 get ptr to object block appropriate hand
                    clra
                    sta       >$0D94
                    lbsr      L77AC
                    tsta
                    beq       L95C3
                    lbsr      L723E
                    pshs      a
                    lda       #$01
                    lbsr      L72B6
                    pshs      u
                    ldu       #$49C6              'was wearing %s (%c)'
                    pshs      u
                    lbsr      L68D8
                    leas      5,s
L95C3               puls      pc,u,y,x,d

L95C5               clr       >$05FC
                    puls      pc,u,y,x,d

L95CA               ldu       #$49DA              'left or right hand? '
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    lbsr      L61C2
                    cmpa      #$1A                <CTRL-Z>
                    bne       L95E1
                    clr       >$05FC
                    lda       #$FF
                    rts

L95E1               clrb
                    stb       >$0D94
                    cmpa      #$6C                'l'?
                    beq       L95ED
                    cmpa      #$4C                'L'
                    bne       L95F0
* 6809/6309 - CLRA
L95ED               lda       #$00                Left hand offset
                    rts

L95F0               cmpa      #$72                'r'?
                    beq       L95F8
                    cmpa      #$52                'R'
                    bne       L95FB               Neither, clarify for idiot user
L95F8               lda       #$01
                    rts

L95FB               ldu       #$49EF              'please type L or R'
                    pshs      u
                    lbsr      L68D8
                    leas      2,s
                    bra       L95CA

* Subroutine to determine "class" of object? Returns 0, 1 or 2 depending on which sub-object type
* Entry: A=0 (left hand) or 1 (right hand)
* Exit: A=0 (nothing on hand, see invisible, searching)
*       A=1 (sustain strength, maintain armor, protection, add strenght, stealth)
*       A=2 (regeneration)
L9607               pshs      x
                    ldx       #$0DB3              Base left hand object ptr
                    lsla                          *2 for 2 byte ptrs
                    ldx       a,x                 Get ptr to object block for appropriate hand
                    cmpx      #$0000              Nothing (no ring, skip ahead)
                    bne       L9617
                    clra
                    puls      pc,x


L9617               lda       $F,x                Get which type of the object
                    cmpa      #9                  Regeneration?
                    bne       L9621               no, try next
                    lda       #$02
                    puls      pc,x

L9621               cmpa      #2                  Sustain strength?
                    beq       L9635               Yes, A=1
                    cmpa      #13                 Maintain armor
                    beq       L9635               yes, A=1
* 6809/6309 - tsta
                    cmpa      #$00                Protection
                    beq       L9635               Yes
                    cmpa      #$01                Add strength
                    beq       L9635
                    cmpa      #$0C                Stealth?
                    bne       L9639               No, next broad ring type?
L9635               lda       #$01
                    puls      pc,x

L9639               cmpa      #$04                See invisible?
                    beq       L9641
                    cmpa      #$03                Searching?
                    bne       L964C               No, skip ahead
L9641               lda       #5                  RND(5)
L9643               lbsr      L63A9
                    tsta
                    beq       L9635
                    clra
                    puls      pc,x

L964C               cmpa      #$07                Dexterity?
                    beq       L9654
                    cmpa      #$08                Increase damage
                    bne       L9658
L9654               lda       #$03
                    bra       L9643

L9658               cmpa      #$0A                Slow digestion
                    bne       L9664               None of the above, exit with A=0
                    lda       #2                  RND(2)
                    lbsr      L63A9
                    deca
                    puls      pc,x

L9664               clra
                    puls      pc,x

L9667               pshs      x,d
                    lda       <$13,y              ? Get object flags?
                    anda      #$02                Is ??? set?
                    beq       L969C
                    lda       $0F,y               Get sub-type of object
* 6809/6309 - Redundant, remove cmpa
                    cmpa      #$00
                    beq       L9682
                    cmpa      #$01
                    beq       L9682
                    cmpa      #$08
                    beq       L9682
                    cmpa      #$07
                    bne       L969C
L9682               lda       #$20
                    sta       >$4939
                    lda       <$12,y
                    clrb
                    ldu       #$00D1
                    lbsr      L899A
                    ldx       #$493A
                    lbsr      L3FF3
                    ldu       #$4939
                    puls      pc,x,d

L969C               ldu       #$1470
                    puls      pc,x,d

* Set up players initial inventory on start
L96A1               pshs      u,y,x,d
                    lda       #1                  Set player on dungeon level #1
                    sta       >$0D91
                    sta       >$0DA6
                    clr       >$0D90
                    ldx       #$10E6
                    ldu       #$10A7
                    lda       #13
                    lbsr      L3C51
                    ldd       #$0514
                    std       >$0DA4
                    ldx       #$5944              Point to inventory (or objects on level?) tbl
                    ldu       #40*31              ($04D8) - clear all 40 entries (31 bytes/each)
                    clra                          Clear with 0's
                    lbsr      L402B
                    ldx       #$5E1C              Point to inventory/object used flag table
                    ldu       #40                 40 bytes (entries) to clear
                    lbsr      L402B               Clear that with 0's too.
                    lbsr      L6162               Get next free inventory entry (max 40)
                    lda       #$CF                Weapon type
                    sta       4,x
                    clra
                    sta       $F,x                Mace sub-type
                    lbsr      L893F
                    lda       #1
                    sta       <$10,x              +1 to hit
                    sta       <$11,x              +1 damage
                    sta       $E,x                1 mace
                    lda       <$13,x
                    ora       #%00000010          $02
                    sta       <$13,x
                    clr       <$15,x
                    lda       #1
                    lbsr      L6DBF
                    stx       >$0DB7              Save ptr as weapon being wielded
                    lbsr      L6162               Get next free inventory entry (max 40)
                    lda       #$CF                Weapon type
                    sta       4,x                 Save
                    lda       #$02                Short Bow sub-type
                    sta       $0F,x
                    lbsr      L893F
                    lda       #1
                    sta       <$10,x              +1 to hit
                    sta       $0E,x               1 bow
                    clr       <$11,x              +0 damage
                    clr       <$15,x
                    lda       <$13,x
                    ora       #$02
                    sta       <$13,x
                    lda       #1
                    lbsr      L6DBF
                    lbsr      L6162               Get next free inventory entry (max 40)
                    lda       #$CF                Weapon type
                    sta       4,x
                    lda       #3                  Arrows sub-type
                    sta       $F,x
                    lbsr      L893F
                    lda       #15                 RND(15)
                    lbsr      L63A9
                    adda      #$19                add 25 (so player gets random 25-40 arrows at start of game)
                    sta       $0E,x
                    clr       <$10,x              +0 to hit
                    clr       <$11,x              +0 damage
                    lda       <$13,x
                    ora       #$02
                    sta       <$13,x
                    lda       #$01
                    lbsr      L6DBF
                    lbsr      L6162               Get next free inventory entry (max 40)
                    lda       #$D0                Armor type
                    sta       4,x                 Save as object type
                    lda       #$01                Ring Mail
                    sta       $F,x                Save as sub-type
                    lda       >$014F
                    deca
                    sta       <$12,x
                    lda       <$13,x
                    ora       #$02
                    sta       <$13,x
                    lda       #$01                1 Ring mail
                    sta       $0E,x
                    clr       <$15,x
                    lda       #$01
                    lbsr      L6DBF
                    stx       >$0DB1              Save ptr to armor being worn
                    lbsr      L6162               Get next free inventory entry (max 40)
                    lda       #$CC                Food object
                    sta       4,x                 Save it
                    lda       #$01                Quantity 1
                    sta       $E,x
                    clr       $F,x                Regular food
                    clr       <$15,x
                    lda       #1
                    lbsr      L6DBF
                    puls      pc,u,y,x,d

* The ptr tables to follow (4 of them) point to the strings of the various potions,etc.
* types based on the address in RAM _while_ Rogue is running. So any code changes that
* where these appear need to be changed as well, or the tables need to be changed to
* allow them to be moved around.
* Ptr table to possible potion names (original color versions)
* Have to with Label+$5E4E offset so it points properly to where to loads in memory)
* but this will move as we modify. Need to base on 'eom', since it is based on the
* address we load into RAM at.
L9790               fdb       Amber+PrgOffst-$1B2 (Prgoffst is $6000 (where Rogue loads), but $1B2 is always added
                    fdb       Aquam+PrgOffst-$1B2
                    fdb       Black+PrgOffst-$1B2
                    fdb       Blue+PrgOffst-$1B2
                    fdb       Brown+PrgOffst-$1B2
                    fdb       Clear+PrgOffst-$1B2
                    fdb       Crimson+PrgOffst-$1B2
                    fdb       Cyan+PrgOffst-$1B2
                    fdb       Gold+PrgOffst-$1B2
                    fdb       Green+PrgOffst-$1B2
                    fdb       Grey+PrgOffst-$1B2
                    fdb       Magenta+PrgOffst-$1B2
                    fdb       Orange+PrgOffst-$1B2
                    fdb       Pink+PrgOffst-$1B2
                    fdb       Plaid+PrgOffst-$1B2
                    fdb       Purple+PrgOffst-$1B2
                    fdb       Red+PrgOffst-$1B2
                    fdb       Silver+PrgOffst-$1B2
                    fdb       Tan+PrgOffst-$1B2
                    fdb       Tanger+PrgOffst-$1B2
                    fdb       Turquo+PrgOffst-$1B2
                    fdb       Vermil+PrgOffst-$1B2
                    fdb       Violet+PrgOffst-$1B2
                    fdb       White+PrgOffst-$1B2
                    fdb       Yellow+PrgOffst-$1B2
Amber               fcc       'amber'
                    fcb       0
Aquam               fcc       'aquamarine'
                    fcb       0
Black               fcc       'black'
                    fcb       0
Blue                fcc       'blue'
                    fcb       0
Brown               fcc       'brown'
                    fcb       0
Clear               fcc       'clear'
                    fcb       0
Crimson             fcc       'crimson'
                    fcb       0
Cyan                fcc       'cyan'
                    fcb       0
Gold                fcc       'gold'
                    fcb       0
Green               fcc       'green'
                    fcb       0
Grey                fcc       'grey'
                    fcb       0
Magenta             fcc       'magenta'
                    fcb       0
Orange              fcc       'orange'
                    fcb       0
Pink                fcc       'pink'
                    fcb       0
Plaid               fcc       'plaid'
                    fcb       0
Purple              fcc       'purple'
                    fcb       0
Red                 fcc       'red'
                    fcb       0
Silver              fcc       'silver'
                    fcb       0
Tan                 fcc       'tan'
                    fcb       0
Tanger              fcc       'tangerine'
                    fcb       0
Turquo              fcc       'turquoise'
                    fcb       0
Vermil              fcc       'vermilion'
                    fcb       0
Violet              fcc       'violet'
                    fcb       0
White               fcc       'white'
                    fcb       0
Yellow              fcc       'yellow'
                    fcb       0

* Ptr table to possible ring names (original versions)
* May have to with Label+PrgOffst-$1B2 offset so it points properly to where to loads in memory)
L9869               fdb       Agate+PrgOffst-$1B2
                    fdb       Alexan+PrgOffst-$1B2
                    fdb       Amethy+PrgOffst-$1B2
                    fdb       Carnel+PrgOffst-$1B2
                    fdb       Diamon+PrgOffst-$1B2
                    fdb       Emeral+PrgOffst-$1B2
                    fdb       German+PrgOffst-$1B2
                    fdb       Granit+PrgOffst-$1B2
                    fdb       Garnet+PrgOffst-$1B2
                    fdb       Jade+PrgOffst-$1B2
                    fdb       Krypton+PrgOffst-$1B2
                    fdb       Lazuli+PrgOffst-$1B2
                    fdb       Moonst+PrgOffst-$1B2
                    fdb       Obsid+PrgOffst-$1B2
                    fdb       Onyx+PrgOffst-$1B2
                    fdb       Opal+PrgOffst-$1B2
                    fdb       Pearl+PrgOffst-$1B2
                    fdb       Perid+PrgOffst-$1B2
                    fdb       Ruby+PrgOffst-$1B2
                    fdb       Sapph+PrgOffst-$1B2
                    fdb       Stibot+PrgOffst-$1B2
                    fdb       Tiger+PrgOffst-$1B2
                    fdb       Topaz+PrgOffst-$1B2
                    fdb       Turq+PrgOffst-$1B2
                    fdb       Taaff+PrgOffst-$1B2
                    fdb       Zircon+PrgOffst-$1B2
Agate               fcc       'agate'
                    fcb       0
Alexan              fcc       'alexandrite'
                    fcb       0
Amethy              fcc       'amethyst'
                    fcb       0
Carnel              fcc       'carnelian'
                    fcb       0
Diamon              fcc       'diamond'
                    fcb       0
Emeral              fcc       'emerald'
                    fcb       0
German              fcc       'germanium'
                    fcb       0
Granit              fcc       'granite'
                    fcb       0
Garnet              fcc       'garnet'
                    fcb       0
Jade                fcc       'jade'
                    fcb       0
Krypton             fcc       'kryptonite'
                    fcb       0
Lazuli              fcc       'lapis lazuli'
                    fcb       0
Moonst              fcc       'moonstone'
                    fcb       0
Obsid               fcc       'obsidian'
                    fcb       0
Onyx                fcc       'onyx'
                    fcb       0
Opal                fcc       'opal'
                    fcb       0
Pearl               fcc       'pearl'
                    fcb       0
Perid               fcc       'peridot'
                    fcb       0
Ruby                fcc       'ruby'
                    fcb       0
Sapph               fcc       'sapphire'
                    fcb       0
Stibot              fcc       'stibotantalite'
                    fcb       0
Tiger               fcc       'tiger eye'
                    fcb       0
Topaz               fcc       'topaz'
                    fcb       0
Turq                fcc       'turquoise'
                    fcb       0
Taaff               fcc       'taaffeite'
                    fcb       0
Zircon              fcc       'zircon'
                    fcb       0

* This might be a specific object table of some sort? Maybe not. There is a routine that at
*  least goes to $19,x based on this, though
L997B               fdb       $1904               ?Ptr to tbl of 8 bit values (0,x)
                    fcb       $05,$04,$1E,$1E,$17,$01,$05,$0F,$1E,$05,$05,$02,$06,$14 (2,x - $F,x)
                    fcb       $16,$06,$23,$1D,$14,$05,$06,$07,$1e,$08 ($10,x - $19,x)

* Ptr table to possible staff names (original versions)
* May have to with Label+PrgOffst-$1B2 offset so it points properly to where to loads in memory)
L9995               fdb       Avocad+PrgOffst-$1B2
                    fdb       Bamboo+PrgOffst-$1B2
                    fdb       Birch+PrgOffst-$1B2
                    fdb       Cedar+PrgOffst-$1B2
                    fdb       Cypress+PrgOffst-$1B2
                    fdb       Dogwood+PrgOffst-$1B2
                    fdb       Drift+PrgOffst-$1B2
                    fdb       Ebony+PrgOffst-$1B2
                    fdb       Elm+PrgOffst-$1B2
                    fdb       Eucal+PrgOffst-$1B2
                    fdb       Hemlock+PrgOffst-$1B2
                    fdb       Ironw+PrgOffst-$1B2
                    fdb       Maple+PrgOffst-$1B2
                    fdb       Oaken+PrgOffst-$1B2
                    fdb       Pine+PrgOffst-$1B2
                    fdb       Redw+PrgOffst-$1B2
                    fdb       Spruce+PrgOffst-$1B2
                    fdb       Teak+PrgOffst-$1B2
                    fdb       Walnut+PrgOffst-$1B2
                    fdb       Zebra+PrgOffst-$1B2
Avocad              fcc       'avocado wood'
                    fcb       0
Bamboo              fcc       'bamboo'
                    fcb       0
Birch               fcc       'birch'
                    fcb       0
Cedar               fcc       'cedar'
                    fcb       0
Cypress             fcc       'cypress'
                    fcb       0
Dogwood             fcc       'dogwood'
                    fcb       0
Drift               fcc       'driftwood'
                    fcb       0
Ebony               fcc       'ebony'
                    fcb       0
Elm                 fcc       'elm'
                    fcb       0
Eucal               fcc       'eucalyptus'
                    fcb       0
Hemlock             fcc       'hemlock'
                    fcb       0
Ironw               fcc       'ironwood'
                    fcb       0
Maple               fcc       'maple'
                    fcb       0
Oaken               fcc       'oaken'
                    fcb       0
Pine                fcc       'pine'
                    fcb       0
Redw                fcc       'redwood'
                    fcb       0
Spruce              fcc       'spruce'
                    fcb       0
Teak                fcc       'teak'
                    fcb       0
Walnut              fcc       'walnut'
                    fcb       0
Zebra               fcc       'zebrawood'
                    fcb       0

* Ptr table to possible wand names (original versions)
* May have to with Label+PrgOffst-$1B2 offset so it points properly to where to loads in memory)
L9A53               fdb       Alumin+PrgOffst-$1B2
                    fdb       Beryl+PrgOffst-$1B2
                    fdb       Bone+PrgOffst-$1B2
                    fdb       Brass+PrgOffst-$1B2
                    fdb       Bronze+PrgOffst-$1B2
                    fdb       Copper+PrgOffst-$1B2
                    fdb       Electr+PrgOffst-$1B2
                    fdb       Gold2+PrgOffst-$1B2
                    fdb       Iron+PrgOffst-$1B2
                    fdb       Lead+PrgOffst-$1B2
                    fdb       Magnes+PrgOffst-$1B2
                    fdb       Nickel+PrgOffst-$1B2
                    fdb       Plat+PrgOffst-$1B2
                    fdb       Steel+PrgOffst-$1B2
                    fdb       Silver2+PrgOffst-$1B2
                    fdb       Silic+PrgOffst-$1B2
                    fdb       Tin+PrgOffst-$1B2
                    fdb       Titan+PrgOffst-$1B2
                    fdb       Tungst+PrgOffst-$1B2
                    fdb       Zinc+PrgOffst-$1B2

Alumin              fcc       'aluminum'
                    fcb       0
Beryl               fcc       'beryllium'
                    fcb       0
Bone                fcc       'bone'
                    fcb       0
Brass               fcc       'brass'
                    fcb       0
Bronze              fcc       'bronze'
                    fcb       0
Copper              fcc       'copper'
                    fcb       0
Electr              fcc       'electrum'
                    fcb       0
Gold2               fcc       'gold'
                    fcb       0
Iron                fcc       'iron'
                    fcb       0
Lead                fcc       'lead'
                    fcb       0
Magnes              fcc       'magnesium'
                    fcb       0
Nickel              fcc       'nickel'
                    fcb       0
Plat                fcc       'platinum'
                    fcb       0
Steel               fcc       'steel'
                    fcb       0
Silver2             fcc       'silver'
                    fcb       0
Silic               fcc       'silicon'
                    fcb       0
Tin                 fcc       'tin'
                    fcb       0
Titan               fcc       'titanium'
                    fcb       0
Tungst              fcc       'tungsten'
                    fcb       0
Zinc                fcc       'zinc'
                    fcb       0

* Assign initial potion colors (14 from master list of 25) for current game
* Clear 25 bytes @ u4A02 (Flags for whether potion names known or not)
L9B09               pshs      u,y,x,d
                    ldd       #25                 A=0 byte to clear with, 25 is count
                    ldx       #$4A02+25           Point to end of buffer
L9B0F               sta       ,-x                 Clear byte
                    decb
                    bne       L9B0F
* Assign 14 random potion names to start (from list of 25 possible ones)
                    clr       >$4A1B              Init entry #
L9B1B               lda       >$4A1B              Get current entry #
                    cmpa      #14                 Are we done assigning the random 14 potion names from the 25 master list?
                    bhs       L9B6A               Yes, exit
                    ldx       #$4A02              Point to tbl of potion colors we are using flags
L9B25               lda       #25                 25 possible potion names in master list
                    lbsr      L63A9               Get RND 1-25
                    tst       a,x                 Have we already assigned this one?
                    bne       L9B25               Yes, pick a different random potion name
                    inc       a,x                 Flag that we have used this potion name
                    lsla
                    leax      >L9790,pc           Point to table of ptrs for potion names ($30 $80 $fc $59 ($FC5D,pc)
                    ldu       a,x                 Get ptr to potion name we will be using (absolute address when ROGUE is loaded)
                    leau      >$01B2,u            Offset to ??? (appears to be middle of a ring name???)
                    lda       >$4A1B              Get entry # again
                    lsla                          * 2 since 2 byte ptrs
                    ldx       #$077D              Point to table to hold ptrs to active potion names for this game
                    stu       a,x                 Save entry
                    lda       >$4A1B              Get ctr
                    ldx       #$060D              Point to tbl of potions known to player
                    clr       a,x                 Clear it
                    lda       >$0D0C
                    ldb       #21
                    mul
                    addd      #$085F
                    tfr       d,u
                    lda       >$4A1B
                    lsla
                    ldx       #$080B
                    stu       a,x
                    inc       >$0D0C
                    inc       >$4A1B
                    bra       L9B1B

* Randomly generate the "gibberish" words for all 15 scrolls?
L9B6C               pshs      u,y,x,d
                    clr       >$4A1C              Clear counter
L9B71               lda       >$4A1C              Get current counter
                    cmpa      #15                 @ 15 yet?
                    blo       L9B78               No, keep going
L9B6A               puls      pc,u,y,x,d

L9B78               ldu       #$4B34              Point to temp buffer
                    lda       #4                  RND(4) (0-4)
                    lbsr      L63A9
                    adda      #2                  (2-6) # times through inner loop
                    sta       >$4A1D              Save it
L9B87               tst       >$4A1D              0?
                    beq       L9BC4               Yes, skip ahead
                    dec       >$4A1D              No, drop it by 1
                    lda       #2                  RND(2) (0-2)
                    lbsr      L63A9
                    inca                          (1-3)
                    sta       >$4A1E              Save another loop ctr
L9B99               tst       >$4A1E              Hit 0 yet?
                    beq       L9BBE               Yes, skip ahead
                    dec       >$4A1E              Drop ctr
                    bsr       L9C02               Get random consonant/vowel combo to $4A1F, point X to it
                    lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    leay      a,u
                    cmpy      #$4B47
                    bls       L9BB4
                    clr       >$4A1D
                    bra       L9BC4

L9BB4               tst       ,x                  Copy buffer from X to U until a NUL is encountered
                    beq       L9B99
                    lda       ,x+
                    sta       ,u+
                    bra       L9BB4

L9BBE               lda       #$20                Add space to output buffer
                    sta       ,u+
                    bra       L9B87

L9BC4               clr       ,-u
                    clr       >$4B48
                    lda       >$4A1C              Get scroll type
                    ldx       #$05FE              Point to tbl of flags for scroll types known to player
                    clr       a,x                 Clear it
                    lda       >$0D0C
                    ldb       #21
                    mul
                    addd      #$085F
                    tfr       d,y
                    lda       >$4A1C
                    lsla
                    ldx       #$07ED              Point to tbl of scroll names assigned by player
                    sty       a,x
                    inc       >$0D0C
                    lda       >$4A1C
                    ldb       #21
                    mul
                    addd      #$0642
                    tfr       d,x
                    ldu       #$4B34
                    lbsr      L3FF3
                    inc       >$4A1C
                    lbra      L9B71

* Get random consonant, and random vowel, save at >$4A1F
* Exit: X=$4A1F (points to random letter pair)
L9C02               pshs      d
                    clr       >$4A22
                    ldx       #$4A23              Point to consonant letter list
                    bsr       L9C32               Get length of that list
                    sta       >$4A21              Save it
                    lda       #2                  RND(2) (0-2)
                    lbsr      L63A9
                    tsta
                    bne       L9C1B               <>0, skip ahead
                    clr       >$4A21              If 0, clear consonant list size to 0
L9C1B               ldx       #$4A39              Point to vowel list (Y is a consonant)
                    bsr       L9C32               Get random letter from list
                    sta       >$4A20              Save it
                    ldx       #$4A23              Point to consonant letter list
                    bsr       L9C32               Get random letter from list
                    ldx       #$4A1F              Point to buffer with random consonant/vowel pairing
                    sta       ,x                  Save random consonant & return
                    puls      pc,d

* Entry: X=ptr to letter list (either consonant list or vowel list, NUL terminated)
* Exit:  A=random letter from list
L9C32               lbsr      L3FE7               Get length of string @ X (NUL terminated)
                    lbsr      L63A9               Get RND(len)
                    lda       a,x                 Get that character from list & return
                    rts

* Set up random names for rings for current game
L9C3B               pshs      u,y,x,d
                    ldd       #26                 A=0 byte to clear with, 26 is count
                    ldx       #$4A3F+26           Point to end of buffer
L9C41               sta       ,-x                 Clear byte
                    decb
                    bne       L9C41
L9C4A               clr       >$4A59              Init ctr (how many have been assigned)
L9C4D               lda       >$4A59              Get current assigned ctr
                    cmpa      #14                 Are we done all the rings?
                    bhs       L9CB7               Yes, return
                    ldx       #$4A3F              Point to start of assigned name flag tbl
L9C57               lda       #26                 RND(26)
                    lbsr      L63A9
                    tst       a,x                 Have we assigned this one already?
                    bne       L9C57               Yes, pick a different one
                    sta       >$4A5A              Save #
                    ldb       #1                  Flag as used
                    stb       a,x
                    lsla                          * 2 since 16 bit ptr
                    leax      >L9869,pc           Point to possible ring names table ptrs
                    ldu       a,x                 Get ptr to name
                    leau      >$01B2,u            ??? Not sure why they added this offset?
                    lda       >$4A59              Get which of 14 ring #'s we are currently assigning name to
                    lsla                          * 2 since 16 bit ptr
                    ldx       #$0799              Ptr to ring names assigned by player
                    stu       a,x                 Save ptr to name in table
                    lsra                          Get which ring # we are doing again
                    ldx       #$061B              ptr to ring flags (rings known to player)
                    clr       a,x                 Clear flag for current ring type
                    lda       >$0D0C              Get ???
                    ldb       #21                 21 bytes/entry
                    mul
                    addd      #$085F              Add to start of tbl ptr
                    tfr       d,u
                    lda       >$4A59              Get ring # we are currently working on
                    lsla                          * 2
                    ldx       #$0827              Tbl ptr
                    stu       a,x                 Copy ptr to table
                    inc       >$0D0C              Bump up ctr?
                    lda       >$4A59              Get which ring # we are working on
                    ldb       #4                  *4 bytes/entry
                    mul
                    addd      #$034F
                    tfr       d,u
                    lda       ,u                  Get value to add
                    ldb       >$4A5A              Get table entry #
                    ldx       >L997B,pc           Point to another table
                    adda      b,x                 Add value to entry in table
                    sta       ,u                  Save that result
                    inc       >$4A59              Bump up which of 14 rings we are working on making initial name for
                    bra       L9C4D               Do until done

L9CB7               puls      pc,u,y,x,d

* Randomly generate wand/staff initial names
L9CB9               pshs      u,y,x,d
                    ldd       #40                 Going to clear two 20 byte tables at once ($4A5D and $4A71)
                    ldx       #$4A5D+40           point to end of 2nd table
L9CBF               sta       ,-x                 Clear out entry
                    decb
                    bne       L9CBF
L9CD5               clr       >$4A5B              Init ctr
L9CD8               lda       >$4A5B              Get ctr
                    cmpa      #14                 Are we done all 14?
                    lbhs      L9D75               Yes, return
L9CE1               lda       #2                  RND(2) (0-2)
                    lbsr      L63A9
                    tsta                          Was random # 0?
                    bne       L9D18               No, do a staff name assignment
* Random wand name assignment
                    lda       #20                 RND(20)
                    lbsr      L63A9
                    ldx       #$4A5D              Point to wand assigned initial name flags tbl
                    tst       a,x                 Have we used this name before?
                    bne       L9CE1               Yes, pick a different one
                    sta       >$4A5C              Save which one we picked
                    ldb       #1                  Flag it as being used
                    stb       a,x
                    ldu       #$4A85              Pt to 'wand'
                    lda       >$4A5B              Get which out of 14 we are assigning
                    lsla                          * 2 (16 bit ptr)
                    ldx       #$07D1              Point to tbl of whether current entry is a wand or staff
                    stu       a,x                 Save default ptr into name ptr list
                    lda       >$4A5C              Get which name of wand/staff we picked
                    lsla                          *2 (16 bit ptr)
                    leax      >L9A53,pc           Point to tbl of ptrs to wand names
                    ldu       a,x                 Get ptr to name
                    leau      >$01B2,u            Don't know why this offset is here?
                    bra       L9D47               Jump ahead

* Random staff name assignment
L9D18               lda       #20                 RND(20)
                    lbsr      L63A9
                    ldx       #$4A71              Point to staff assigned initial name flags tbl
                    tst       a,x                 Have we used this name before?
                    bne       L9CE1               Yes, try a whole new assignment again
                    sta       >$4A5C              Save name entry # we will be assigning
                    ldb       #1                  Flag as assigned
                    stb       a,x
                    ldu       #$4A8A              Pt to 'staff'
                    lda       >$4A5B              Get which of 14 we are assigning
                    lsla                          * 2 since ptr
                    ldx       #$07D1              Pt to tbl that shows whether wand or staff
                    stu       a,x                 Save ptr to type name
                    lda       >$4A5C              Get initial name #
                    lsla
                    leax      >L9995,pc           Point to tbl of ptrs to staff names
                    ldu       a,x                 Get ptr to staff name
                    leau      >$01B2,u            ??? Don't know why
L9D47               lda       >$4A5B              Get which of 14 we are assigning
                    lsla
                    ldx       #$07B5              Pt to table of iniital wand/staff names
                    stu       a,x                 Save ptr to the name in tbl
                    lda       >$4A5B              Get which wand # we are assigning
                    ldx       #$0629              Flag that actual wand/staff type is NOT known to player
                    clr       a,x
                    lda       >$0D0C
                    ldb       #21
                    mul
                    addd      #$085F
                    tfr       d,u
                    lda       >$4A5B              Get wand/staff # we are working on again
                    lsla                          * 2 per tbl entry
                    ldx       #$0843              Pt start of tbl
                    stu       a,x                 Save ptr into tbl
                    inc       >$0D0C              ???
                    inc       >$4A5B              Inc which wand/staff # we are currently making initial names for
                    lbra      L9CD8               Keep doing until done all of them.

L9D75               puls      pc,u,y,x,d

* Init tbl of how many experience points required per rank. Starts at 10, then doubles each rank after,
*  until 5,242,880 ($500000) for Bug Chaser
L9D77               pshs      u,y,x,d
                    ldd       #10                 Init experience pts needed for first rank to 10 (32 bit #)
                    std       >$5E46
                    clrb
                    std       >$5E44
                    ldx       #$4A90              Point to start of experience points required tbl
                    leau      <80,x               Point U to experience tbl end+1
                    stu       >$5E48              Save end ptr
L9D8E               cmpx      >$5E48              Are we done all entries?
                    bhs       L9D75               Yes, return
                    ldd       >$5E44              Copy current experience points temp to current rank experience points required
                    std       ,x++
                    ldd       >$5E46              Copy current experience points temp to current rank experience points required
                    std       ,x++
                    lsl       >$5E47              Multiply current experience points temp by 2
                    rol       >$5E46
                    rol       >$5E45
                    rol       >$5E44
                    bra       L9D8E

                    emod

eom                 equ       *
                    end
