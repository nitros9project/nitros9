********************************************************************
* sierra - King's Quest III setup module
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   0      2003/01/31  Paul W. Zibaila
* Disassembly of original distribution and merged in comments from
* disasm dated 1992.
*
*   1      2003/03/10  Boisy G. Pitre
* Monitor type bug now fixed.
*   2      2012/01/05  Robert Gault
* Converted raw reads of $FFA0-$FFAF to a routine that gets images
* from the system. Now works with 2 or 8Meg systems. Unfortunately
* it was necessary to make buffers within the code rather than data
* area because it was safer given data was shared with other modules.
*
* Simplified some other routines.

* I/O path definitions
StdIn               equ       0
StdOut              equ       1
StdErr              equ       2

                    nam       sierra
                    ttl       King's Quest III setup module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    org       0
u0000               rmb       2                   holds size of data area
u0002               rmb       1                   MMU block # mapped into block #2 -org
u0003               rmb       1                   MMU block # mapped into block #3 -org
u0004               rmb       2                   Hi res screen start address
u0006               rmb       2                   Hi res screen end address  ?????
u0008               rmb       1                   disasm as u0008 rmb 2
u0009               rmb       1                   MMU Block # SIERRA is in  -org
u000A               rmb       1                   double byte MMU Task 1 block 1
u000B               rmb       1                   value actually resides here
u000C               rmb       1
u000D               rmb       1
u000E               rmb       1
u000F               rmb       1
u0010               rmb       1
u0011               rmb       3
u0014               rmb       2                   Hi res screen start address
u0016               rmb       2                   Hi res screen end address ???
u0017               rmb       4
u001C               rmb       2
u001E               rmb       4
u0022               rmb       1
u0023               rmb       1
u0024               rmb       2                   mnln remap value holder
u0026               rmb       2                   scrn remap value holder
u0028               rmb       2                   shdw remap value holder
u002A               rmb       2                   saves stack pointer of caller to sub659
u002C               rmb       2
u002E               rmb       16
u003E               rmb       1
u003F               rmb       2
u0041               rmb       1
u0042               rmb       1                   MMU Block # of SIERRA's dsc.
u0043               rmb       2
u0045               rmb       1                   flag after color table sets
u0046               rmb       2
u0048               rmb       2
u004A               rmb       5
u004F               rmb       4
u0053               rmb       2
u0055               rmb       10
u005F               rmb       163
u0102               rmb       113
mtf173              rmb       1                   multitasking flag
scr174              rmb       1                   screen number?
x01076              rmb       212
u0249               rmb       1
u024A               rmb       1
u024B               rmb       1
u024C               rmb       497
u043D               rmb       245
u0532               rmb       16                  vol_handle_table (pointer to file structures)
u0542               rmb       15
u0551               rmb       2                   given_pic_data (pointer)
u0553               rmb       1                   display_type
u0554               rmb       154
int5EE              rmb       107                 Signal Intercept routine from 452 - 4BD
sub659              rmb       116                 Slot to hold subroutine for others uses at 4DA - 54F
u0xxx               rmb       6450
size                equ       .

name                fcs       /sierra/
                    fcb       edition

start               equ       *
L0014               lbra      L007D               branch to entry process params
L0017               lbra      L00DB               agi_exit() branch to clean up routines


*                   Multi-tasking flag (0=No multitask, 1=multitask)
L001A               fcb       $00                 we store a value here
*                   the "old self modifying code" trick


* Text strings think this was probably an Info thing
L001B               fcc       'AGI (c) copyright 1988 SIERRA On-Line'
                    fcc       'CoCo3 version by Chris Iden'
                    fcb       $00
Infosz              equ       *-L001B


* Useage text string
L005C               fcc       'Usage: Sierra -Rgb -Multitasking'
                    fcb       C$CR
Usgsz               equ       *-L005C


L007D               tfr       s,d                 save stack ptr / start of param ptr into d
*
                    subd      #$04FF              start of stack/end of data mem ptr
                    std       <u0000              store this value in user var
                    bsr       L009C               branch to input processer routine

L0086               lbsr      L011A               relay call to L0140

L0089               ldd       <u0000              load the data pointer
                    beq       L00DF               if it is zero we have a problem
*         ldd   >$FFA9     ??? MMU task 1 block 1 ???
                    lbsr      mmuini2             get MMU values $FFA8-$FFAF
                    ldd       mmubuf+9,pcr
                    std       <u000A              save the task 1 block one value
                    lda       #$00                clear a to zero
                    sta       <u0011              save that value
                    ldx       <u0024              set up to jump to mnln and go for it
                    jsr       sub659              code at L04DA plays with mmu blocks
                    rts

* Process any command line args
* See F$Fork description 8-15 for entry conditions

L009C               lda       ,x+                 get next char after name string
                    cmpa      #C$CR               is it a CR?
                    beq       L00DA               yes exit from routine
                    cmpa      #$2D                is it a dash '-
                    bne       L009C               not a dash go look again

                    lda       ,x+                 was as dash get the next char
                    ora       #$20                apply mask to lower case
                    cmpa      #$72                is it a 'r ?
                    beq       L00C2               yep go set up for RGB monitor
                    cmpa      #$6D                is it an 'm ?
                    beq       L00D2               if so go store a flag and continue

*  We've found something other than Mm or Rr after a dash
*  write usage message and Exit program

                    lda       #StdOut             load path std out
                    leax      >L005C,pcr          load address of message
                    ldy       #Usgsz              $0021  load the size of the message
                    os9       I$WritLn            write it
                    clrb                          clear the error code (unneeded branch to L00DE)
                    bra       L00DF               and branch to exit!

* found a "-r"
L00C2               pshs      x                   save x-reg since set stat call uses it
                    lda       #StdOut             $01  set the path number
                    ldb       #SS.Montr           code #$92 sets the monitor type
                    ldx       #RGB                monitor type code $0001
                    os9       I$SetStt            set it up
                    puls      x                   fetch our x back assumes call doesn't fail
                    bra       L009C               go process the rest of the parms

* found an "-m"
L00D2               lda       #$01                we have found a -m and load a flag
                    sta       >L001A,pcr          and stow it in our code area  (SELF MODIFYING)
                    bra       L009C               check for next param

L00DA               rts                           return


*  This is just a relay call to L0336
agi_exit
L00DB               lbsr      L0133

L00DE               clrb
L00DF               os9       F$Exit              time to check out


* same sequence of bytes at L454C in mnln

L00E2               fcb       $00                 composite
                    fcb       $0C
                    fcb       $02
                    fcb       $2E
                    fcb       $06
                    fcb       $09
                    fcb       $04
                    fcb       $20
                    fcb       $10
                    fcb       $1B
                    fcb       $11
                    fcb       $3D
                    fcb       $17
                    fcb       $29
                    fcb       $33
                    fcb       $3F

                    fcb       $00                 rgb
                    fcb       $08
                    fcb       $14
                    fcb       $18
                    fcb       $20
                    fcb       $28
                    fcb       $22
                    fcb       $38
                    fcb       $07
                    fcb       $0B
                    fcb       $16
                    fcb       $1F
                    fcb       $27
                    fcb       $2D
                    fcb       $37
                    fcb       $3F

* The disassembly gets confused here with text and the nulls
*  according to the partial disassembly I recieved these hold
*  Original MMU block image of second and third blocks of SIERRA
*  MORE SELF MODIFYING CODE

L0102               fdb       $0000               Orig MMU block image of 2nd blk of sierra
L0104               fdb       $0000               Orig MMU block image of 3nd blk of sierra

* Name strings of other modules to load.

L0106               fcc       'Shdw'
                    fcb       C$CR

L010B               fcc       'Scrn'
                    fcb       C$CR

L0110               fcc       'MnLn'
                    fcb       C$CR


* Internal variables for self modifying code
L0115               fcb       $00                 Echo
L0116               fcb       $00                 EOF
L0117               fcb       $00                 INTerupt
L0118               fcb       $00                 Quit
L0119               fcb       $00                 Monitor type Coco set to when Sierra ran


* L011A called by L0086
L011A               lbsr      L0140               Clears data area, sets up vars and saves montype
                    lbsr      mmuini1             get MMU values $FFA0-$FFA7
                    lbsr      L01AF               Change our process image to dupe block 0 to 1-2
L0120               lbsr      L01FA               copies two subs to data area so others can use them

                    lbsr      L0419               load intercept routine and open /VI and allocate Ram
                    bcs       L0139               if errors occured  close VIRQ device

                    lbsr      L0229               NMLoads the three other modules and sets up vals
                    bcs       L0136               problems then unload them

                    lbsr      L026B               go set up screens
                    bcs       L0133               problems deallocate them
                    rts

* clean up and shut down
agi_shutdown
L0133               lbsr      L0336               go deallocate hi res screens
L0136               lbsr      L0370               unloads the three other modules
L0139               lbsr      L04BD               Close VIRQ device
                    lbsr      L0388               restore the MMU blocks
                    rts

* at this point u0000 contains the value of s on entry minus $04FF
* which should be the size of our initialized data
* so we don't over write it but clear the rest of the data area

L0140               ldx       #$0002              Init data area from 2-end with 0's
                    ldd       #$0000
L0146               std       ,x++
                    cmpx      <u0000              should have the value $04FF
                    bcs       L0146               appears this zeros out memory somewhere

* initialize some variables
                    lda       >L001A,pcr          multitasking flag from startup parms
                    sta       mtf173              >$0173       store it

                    ldd       #$06CE              why twice
                    std       <u0053
                    std       <u0055

                    lda       #$5C
                    sta       >$0101

                    lda       #$17
                    sta       >$01D8

                    lda       #$0F
                    sta       >$023F

                    ldd       #$0000
                    std       <u004F

*  get current montype
*  GetStat Function Code $92
*          Allocates and maps high res screen
*          into application address space
* entry:
*       a -> path number
*       b -> function code $92 (SS.Montr)
*
* exit:
*       x -> monitor type
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)
*
                    lda       #StdOut             $01 path number
                    ldb       #SS.Montr           monitor type code (not listed for getstat $92
                    os9       I$GetStt            make the call
                    tfr       x,d                 save in d appears he expects montype returned
                    stb       >L0119,pcr          trim it to a byte and save it
                    andb      #$01                mask out mono type only RGB or COMP
                    stb       >$0553              save that value off as display_type

*  set current montype
*  SetStat Function Code $92
*          Allocates and maps high res screen
*          into application address space
* entry:
*       a -> path number
*       b -> function code $92 (SS.Montr)
*       x -> momitor type
*            0 = color composite
*            1 = analog RGB
*            2 = monochrome composite
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)
*
                    ldx       #RGB                $0001 set type to RGB again as in L00C2
                    lda       #StdOut             $01 set the path
                    ldb       #SS.Montr           Monitor type code $92
                    os9       I$SetStt            make the call

* initialize more variables

                    lda       #$32
                    sta       >$0246

                    ldd       #$6000              This is the start of high res screen memory
                    std       <u0046

                    lda       #$15
                    sta       >$0248

                    lda       #$FF                Init 15 bytes at u0532 to $FF
                    ldb       #$0F
                    ldx       #$0532
                    bsr       L01A3
                    rts

* Fill routine-one byte pattern
* Entry: A=Byte to fill with
*        B=# bytes to fill
*        X=Start address of fill

L01A3               sta       ,x+
                    decb
                    bne       L01A3
                    rts

* Fill routine-two byte pattern
* Entry: U=2-Byte pattern to fill with
*        B=# bytes to fill
*        X=Start address of fill
*                                     NO BODY CALLS HERE ??
L01A9               stu       ,x++
                    decb
                    bne       L01A9
                    rts

*  Raw disassembly of followin code
*L01AF    orcc  #$50
*         ldx   #$0002
*         stx   <u0022
*         lda   >$FFAF
*         sta   <u0008
*         clr   >$FFA9
*         ldd   >$2050
*         anda  #$1F
*         addd  #$2043
*         std   <u0043
*         ldb   >$2050
*         andb  #$E0
*         lsrb
*         lsrb
*         lsrb
*         lsrb
*         lsrb
*         ldx   #$FFA0
*         lda   b,x
*         sta   <u0042
*         sta   >$FFA9
*         ldx   <u0043
*         ldd   -$01,x
*         std   >L0102,pcr
*         ldd   $01,x
*         std   >L0104,pcr
*         ldd   -$03,x
*         std   -$01,x
*         std   $01,x
*         tfr   b,a
*         std   >$FFA9
*         std   <u0002
*         andcc #$AF
*         rts

**********************************************************
* COMMENTS FROM CODE RECIEVED
* Change our process map:
*         Blocks 1-2 become duplicates of block 0 (data area...
*         changes actual MMU regs themselves &
*         changes them in our process descriptor
*
* NOTE: SHOULD CHANGE SO IT MAPS IN BLOCK 0 IN AN UNUSED BLOCK 1ST
*       TO GET PROCESS DESCRIPTOR DAT IMAGE FOR SIERRA.
*       THEN, CAN BUMP BLOCKS AROUND WITH THE ACTUAL BLOCK #
*       IN FULL 2 MB RANGE, INSTEAD OF JUST GIME 512K RANGE.

L01AF               orcc      #IntMasks           Shut interrupts off
                    ldx       #$0002              ???
                    stx       <u0022

*        As per above NOTE, should postpone this until we have DAT image
*        available for Sierra process

*         lda   >$FFAF         Get MMU block # SIERRA is in
                    lda       mmubuf+$0F,pcr
                    sta       <u0008              Save it
                    clr       >$FFA9              Map system block 0 into $2000-$3FFF
                    ldd       >D.Proc+$2000       Get SIERRA's process dsc. ptr
                    anda      #$1F                Keep non-MMU dependent address

* NOTE: OFFSET IS STUPID, SHOULD USE EVEN BYTE SO LDD'S BELOW
*       CAN USE FASTER LDD ,X INSTEAD OF OFFSET,X

                    addd      #$2000+P$DATImg+3   Set up ptr for what we want out of it
                    std       <u0043              Save it
                    ldb       >D.Proc+$2000       Get MSB of SIERRA's process dsc. ptr
                    andb      #$E0                Calculate which 8K block within
*                                 system task it's in
*         lsrb
*         lsrb
*         lsrb
*         lsrb
*         lsrb
                    lda       #8
                    mul

* NOTE: HAVE TO CHANGE THIS TO GET BLOCK #'S FROM SYSTEM DAT IMAGE,
*       NOT RAW GIME REGS (TO WORK WITH >512K MACHINES)
*         ldx   #$FFA0       Point to base of System task DAT register set block 0 task 0
                    leax      mmubuf,pcr
*         lda   b,x          Get block # that has process desc. for SIERRA
                    lda       a,x
                    sta       <u0042              Save it
                    sta       >$FFA9              Map in block with process dsc. to $2000-$3FFF
                    ldx       <u0043              Get offset to 2nd 8K block in DAT map for SIERRA
                    ldd       -1,x                Get MMU block # of current 2nd 8k block in SIERRA
                    std       >L0102,pc           Save it
                    ldd       1,x                 Get MMU block # of current 3rd 8k block in SIERRA
                    std       >L0104,pc           Save it
                    ldd       -3,x                Get data area block 3 from sierra (1st block)
                    std       -1,x                Move 8k data area to 2nd block
                    std       1,x                 And to 3rd block
                    tfr       b,a                 D=Raw MMU block # for both

* HAVE TO CHANGE TO ALLOW FOR DISTO DAT EXTENSION
                    std       >$FFA9              Map data area block into both blocks 2&3
                    std       <u0002              Save both block #'s
                    andcc     #^IntMasks          Turn interrupts back on
                    rts


* NOTE: 6809/6309 MOD: STUPID. DO LEAX, AND THEN PSHS X

* load first routine
*L01FA    leas  -2,s         Make 2 word buffer on stack
*         leax  >L054F,pc    Point to end of routine
*         stx   ,s           Save ptr
L01FA               leax      L054F,pcr
                    pshs      x
                    leax      >L04DA,pc           Point to routine
*         ldu   #$0659      Point to place in data area to copy it
                    ldu       #sub659
L0209               lda       ,x+                 Copy routine
                    sta       ,u+
                    cmpx      ,s                  Done whole routine yet?
                    blo       L0209               No, keep going

* get next routine interrupt intecept routine
                    leax      >L04BD,pcr          point to end of routine
                    stx       ,s                  save pointer
                    leax      >L0452,pcr          point to routine
                    ldu       #int5EE             point to place in data area to copy it
L021E               lda       ,x+                 copy routine
                    sta       ,u+
                    cmpx      ,s                  Done whole routine yet?
                    blo       L021E               No, keep going
*         leas  $02,s        clean up stack
*         rts                return
                    puls      x,pc

* Called from dispatch table at L0120
* The last op in the subroutine before this one
* was a puls a,b after a puhs x and a setsatt call for process+path to VIRQ

L0229               tfr       b,a                 don't see what's going on here
                    incb
                    std       <u001C              but we save off a bunch of values

                    addd      #$0202
                    std       <u001E

                    addd      #$0202
                    sta       <u005F
                    std       <u000C
                    std       <u000E

                    ldu       #$001A
                    stu       <u0028
                    leax      >L0106,pcr          shdw
                    lbsr      L03D0               NMLoads named module
                    bcs       L026A               return on error

                    ldu       #$0012
                    stu       <u0026
                    leax      >L010B,pcr          scrn
                    lbsr      L03D0               NMLoads named module
                    bcs       L026A               return on error

                    ldu       #$000A
                    stu       <u0024
                    leax      >L0110,pcr          mnln
                    lbsr      L03D0               NMLoads named module

                    leau      >$2000,u
                    stu       <u002E
L026A               rts

*****************************************************
*
*  Set up screens
*  SetStat Function Code $8B
*          Allocates and maps high res screen
*          into application address space
* entry:
*       a -> path number
*       b -> function code $8B (SS.AScrn)
*       x -> screen type
*            0 = 640 x 192 x 2 colors (16K)
*            1 = 320 x 192 x 4 colors (16K)
*            2 = 160 x 192 x 16 colors (16K)
*            3 = 640 x 192 x 4 colors (32K)
*            4 = 320 x 192 x 16 colors (32K)
*
* exit:
*       x -> application address space of screen
*       y -> screen number (1-3)
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)
*
*  Call use VDGINT allocates high res graphics for use with screens
*  updated by the process, does not clear the screens only allocates
*  See OS-9 Technical Reference 8-142 for more details
*

L026B               leas      -$04,s              mamke room om stack 2 words
                    lda       #$01                Std out
                    ldb       #SS.AScrn           Allocate & map in hi-res screen (VDGINT)
                    ldx       #$0004              320x192x16 screen
                    os9       I$SetStt            Map it in
                    bcs       L02E6               Error, Restore stack & exit
                    tfr       y,d                 Move screen # returned to D
*         stb   >$0174      Save screen #
                    stb       scr174              Save screen #

* call with application address of screen in x
* returns with values in u
                    lbsr      mmuini2             get current MMU values
                    lbsr      L03B6               twiddle addresses
                    stu       <u0004              stow it two places
                    stu       <u0014

                    leax      >$4000,x            end address ???
                    lbsr      L03B6               twiddle addresses
                    stu       <u0006              stow it in two places
                    stu       <u0016

* TFM for 6309
                    ldu       #$D800              Clear hi-res screen to color 0
                    ldx       #$7800              Screen is from $6000 to $D800
                    ldd       #$0000              (U will end up pointing to beginning of screen)
L0299               std       ,--u                writes 0000 to screen address and decrements
                    leax      -2,x                decrement x loop counter
                    bne       L0299               keep going till all of screen is cleared

*  Display a screen allocated by SS.AScrn
*  SetStat Function Code $8C
*
* entry:
*       a -> path number
*       b -> function code $8C (SS.DScrn)
*       y -> screen numbe
*            0 = text screen (32 x 16)
*            1-3 = high resolution screen
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)

                    clra                          Get screen # to display
                    ldb       scr174
                    tfr       d,y                 Y=screen # to display
                    lda       #StdOut             $01  Std out path
                    ldb       #SS.DScrn           Display 320x192x16 screen
                    os9       I$SetStt            make the call
                    bcs       L02E6

                    leax      >L00E2,pc           get color table values
                    ldb       >$0553              display_type 0 = comp / 1 = rgb
                    lda       #$10
                    mul                           first sixteen comp, second rgb
                    abx                           add b to x reset the pointer as required


* This loads up the control sequence to set the pallete 1B 31 PRN CTN
*  PRN palette register 0 - 15, CTN color table 0 - 63
                    lda       #$1B                Escape code
                    sta       ,s                  push on stack
                    lda       #$31                Palette code
                    sta       $01,s               push on stack
                    clra                          make a zero palette reg value
                    sta       $02,s               push it `
                    ldy       #$0004              sets up # of bytes to write
L02C8               ldb       ,x+                 get value computed above for color table and bump it
                    stb       $03,s               push it
                    pshs      x                   save it
                    lda       #StdOut             $01      Std Out path
                    leax      $02,s               start of data to write
                    os9       I$Write             write it
                    bcs       L02E6               error during write clean up stack and leave
                    puls      x                   retrieve our x
                    inc       $02,s               this is our palette register value
                    lda       $02,s               we bumped it by one
                    cmpa      #$10                we loop 15 times to set them all
                    blo       L02C8               loop

                    clr       <u0045              clear a flag in memory
                    lbsr      L02E9               go disable keyboard interrupts
L02E6               leas      $04,s               clean up stack
                    rts                           return


*  Raw disassembly of following section
*L02E9    leas  <-$20,s
*         lda   #$00
*         ldb   #$00
*         leax  ,s
*         os9   I$GetStt
*         bcs   L0332
*         lda   >L0115,pcr
*         ldb   $04,x
*         sta   $04,x
*         stb   >L0115,pcr
*         lda   >L0116,pcr
*         ldb   $0C,x
*         sta   $0C,x
*         stb   >L0116,pcr
*         lda   >L0117,pcr
*         ldb   <$10,x
*         sta   <$10,x
*         stb   >L0117,pcr
*         lda   >L0118,pcr
*         ldb   <$11,x
*         sta   <$11,x
*         stb   >L0118,pcr
*         lda   #$00
*         ldb   #$00
*         os9   I$SetStt
*L0332    leas  <$20,s
*         rts

* Kills the echo, eof, int and quit signals
*  get current options packet
*  GetStat Function Code $00
*          Reads the options section of the path descriptor and
*          copies it into the 32 byte area pointed to by reg X`
* entry:
*       a -> path number
*       b -> function code $00 (SS.OPT)
*       x -> address to recieve status packet
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)
*

L02E9               leas      <-$20,s             Make temp buffer to hold PD.OPT data
                    lda       #StdIn              $00 Get 32 byte PD.OPT from Std In
                    ldb       #SS.OPT             $00
                    leax      ,s                  point to our temp buffer
                    os9       I$GetStt            make the call
                    bcs       L0332               error goto exit sub

* NOTE: make sure following lines assemble into 5 bit, not 8 bit
*       These appear to be loading the  echo EOF, INT and QUIT with
*       null values and saving the original ones back to vars
*       since L0115 - L0118 were initialized with $00

                    lda       >L0115,pc
                    ldb       PD.EKO-PD.OPT,x     Get echo option
                    sta       PD.EKO-PD.OPT,x     change echo option no echo
                    stb       >L0115,pc           Save original echo option

                    lda       >L0116,pc
                    ldb       PD.EOF-PD.OPT,x     Change EOF char
                    sta       PD.EOF-PD.OPT,x
                    stb       >L0116,pc

                    lda       >L0117,pc
                    ldb       <PD.INT-PD.OPT,x    Change INTerrupt char (normally CTRL-C)
                    sta       <PD.INT-PD.OPT,x
                    stb       >L0117,pc

                    lda       >L0118,pc
                    ldb       <PD.QUT-PD.OPT,x    Change QUIT char (normally CTRL-E)
                    sta       <PD.QUT-PD.OPT,x
                    stb       >L0118,pc

*  set current options packet
*  SetStat Function Code $00
*          Writes the options section of the path descriptor
*          from the 32 byte area pointed to by reg X`
* entry:
*       a -> path number
*       b -> function code $00 (SS.OPT)
*       x -> address holding the status packet
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)
*

*                                x is still pointing to our temp buff
                    lda       #StdIn              $00 Set VDG screen to new options
                    ldb       #SS.OPT             $00
                    os9       I$SetStt            set them to be our new values

L0332               leas      <$20,s              Eat temp stack & return
                    rts

* raw disassembly
*L0336    leas  -$02,s
*         tst   >$0174
*         beq   L036D
*         lbsr  L02E9
*         bcs   L036D
**         lda   #$1B
*         sta   ,s
*         lda   #$30
*         sta   $01,s
*         ldy   #$0002
*         lda   #$01
*         leax  ,s
*         os9   I$Write
*         bcs   L036D
*         ldb   #$8C
*         ldy   #$0000
*         os9   I$SetStt
*         clra
*         ldb   >$0174
*         tfr   d,y
*         lda   #$01
*         ldb   #$8D
*         os9   I$SetStt
*L036D    leas  $02,s
*         rts


*  Return the screen to default text sreen and its values
*  deallocate and free memory of high res screen created

L0336               leas      -2,s                Make temp buffer to hold write data
*         tst   >$0174       Any hi-res screen # allocated?
                    tst       scr174              Any hi-res screen # allocated?
                    beq       L036D               No, restore stack & return
                    lbsr      L02E9               go change the echo,eof,int and quit settings
                    bcs       L036D               had an error restore stack and return
                    lda       #$1B                Setup DefColr sequence in temp buffer
                    sta       ,s
                    lda       #$30                Sets palettes back to default color
                    sta       1,s
                    ldy       #$0002              number of bytes to write
                    lda       #StdOut             path to write to $01
                    leax      ,s                  point x a buffer
                    os9       I$Write             write
                    bcs       L036D               we have an error clean stack and leave

*  Display a screen allocated by SS.AScrn
*  SetStat Function Code $8C
*
* entry:
*       a -> path number
*       b -> function code $8C (SS.DScrn)
*       y -> screen numbe
*            0 = text screen (32 x 16)
*            1-3 = high resolution screen
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)

*                           a is still set to stdout from above
                    ldb       #SS.DScrn           Display screen function code
                    ldy       #$0000              Display screen #0 (lo-res or 32x16 text)
                    os9       I$SetStt            make the call

*  Frees the memory of a screen allocated by SS.AScrn
*  SetStat Function Code $8C
*
* entry:
*       a -> path number
*       b -> function code $8D (SS.FScrn)
*       y -> screen number 1-3 = high resolution screen
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)

                    clra                          clear high byte
                    ldb       scr174              Get hi-res screen # again
                    tfr       d,y                 move it to Y=screen #
                    lda       #StdOut             set the path $01
                    ldb       #SS.FSCrn           Return screen memory to system
                    os9       I$SetStt            amke the call

L036D               leas      2,s                 Eat stack & return
                    rts



*  Unload the other modules
L0370               leax      >L0106,pcr          shdw name string
                    lda       #Prgrm+Objct        #$11        module type
                    lbsr      L040B               unload it
                    leax      >L010B,pcr          scrn name string
                    lbsr      L040B               unload it
                    leax      >L0110,pcr          mnln name string
                    lbsr      L040B               unload it
                    rts

*L0388    orcc  #$50
*         lda   <u0042
*         sta   >$FFA9
*         ldx   <u0043
*         ldd   >L0104,pcr
*         std   $01,x
*         stb   >$FFAA
*         ldd   >L0102,pcr
*         std   -$01,x
*         stb   >$FFA9
*         andcc #$AF
*         clra
*         ldb   >L0119,pcr
*         andb  #$03
*         tfr   d,x
*         lda   #$01
*         ldb   #$92
*         os9   I$SetStt
*         rts
**
*L03B6    tfr   x,d
*         exg   a,b
*         lsrb
*         lsrb
*         lsrb
*         lsrb
*         lsrb
*         pshs  b
*         ldu   #$FFA8
*         lda   b,u
*         incb
*         andb  #$07
*         ldb   b,u
*         tfr   d,u
*         puls  a
*         rts


* Restore original MMU block numbers
L0388               orcc      #IntMasks           Shut off interrupts
                    lda       <u0042              get MMU Block #
                    sta       >$FFA9              Restore original block 0 onto MMU
                    ldx       <u0043
                    ldd       >L0104,pc           Origanl 3rd block of MMU
                    std       1,x
                    stb       >$FFAA              Restore original block 1 onto MMU
                    ldd       >L0102,pc           Original 2nd block of MMU
                    std       -1,x
                    stb       >$FFA9              Restore block 0 again
                    andcc     #^IntMasks          Turn interrupts back on

*  return monitor type to original value
                    clra
                    ldb       >L0119,pc           Get original monitor type
                    andb      #$03                Force to only legit values
                    tfr       d,x                 Move to proper register
                    lda       #StdOut             set path $01
                    ldb       #SS.Montr           Restore original monitor type
                    os9       I$SetStt            make the call
                    rts

* twiddles address
* called with value to be twiddled in X
* returns block # in a
*         ?????   in u
L03B6               tfr       x,d                 Move address to D
*         exg   a,b          Swap MSB/LSB
*         lsrb               Divide MSB by 32 (calculate 8k block # in proc map)
*         lsrb
*         lsrb
*         lsrb
*         lsrb
*         pshs  b            Save block # in process map
*         ldu   #$FFA8       Point to start of user DAT image
*         lda   b,u
                    ldb       #8
                    mul
                    pshs      a
                    leau      mmubuf+8,pcr
                    lda       a,u                 get MMU value
                    ldb       ,s
                    incb
                    andb      #$07
                    ldb       b,u
                    tfr       d,u
                    puls      a
                    rts



*************************************************************
*  Called from  within sub at L0229
*  entry:
*	x -> is loaded with the address of the name string to load
*       u -> contains some arbitrary value
*

L03D0               leas      -$08,s              Make a little scratch on the stack
                    stu       ,s                  pointer to our buffer

* Loads one or more modules from a file but does not map the module
* into user's address space F$NMLoad
* entry:
*      a -> type/language byte
*      x -> address of the path list
*           with out path list default path is current execution dir
*
* exit:
*      a -> type/language
*      b -> module revision
*      x -> address of the last byte in the pathlist + 1
*      y -> storageb requirements of the module
*
* error:
*      b  -> error code if any
*      cc -> carry set on error

                    stx       $02,s               pointer module name
                    lda       #Prgrm+Objct        $11      module type
                    os9       F$NMLoad            Load it but don't map it in
                    bcs       L0408               exit on error

* Links to a memory module that has the specified name, language and type
* entry:
*      a -> type/language byte
*      x -> address of the module name
*
* exit:
*      a -> type/language
*      b -> attributes/module revision
*      x -> address of the last byte in the modulename + 1
*      y -> module entry point absolute address
*      u -> module header abosolute address
*
* error:
*     cc -> set on error

                    ldx       $02,s               get our name string again
                    os9       F$Link              link it
                    bcs       L0408               exit on error
                    stu       $06,s               store module header address
                    tfr       u,x
                    lbsr      mmuini2             get current MMU values
L03E8               stx       $04,s
                    lbsr      L03B6               Go twiddle with address`
                    ldx       ,s
                    leax      a,x
                    exg       d,u
                    sta       ,x
                    exg       d,u
                    cmpa      #$06
                    beq       L0403
                    ldx       $04,s
                    leax      >$2000,x
                    bra       L03E8

L0403               ldu       $06,s
                    os9       F$UnLink
L0408               leas      $08,s
                    rts

L040B               os9       F$UnLoad            Unlink a module by name
                    bcc       L040B
                    clrb
                    rts

L0412               fcc       '/VI'
L0415               fcb       C$CR
L0416               fdb       $0000               address of the device table entry
L0418               fcb       $00                 path number to device

**************************************************************
*
*   subroutine entry is L0419
*   sets up Sig Intercept
*   verifies /VI device is loaded links to it
*   and allocates ram for it
*   called from dispatch table around L0120


* Set signal intercept trap
*  entry:
*        x -> address of intercept routine
*        u -> starting adress of routines memory area
*  exit:
*       Signals sent to the process cause the intercept to be
*       called instead of the process being killed

L0419               ldu       #$0000              start of Sierra memory area
                    ldx       #int5EE             Intercept rourtine copied to mem area
                    os9       F$Icpt              install the trap

* Attach to the vrt memory descriptor
* Attaches and verifies loaded the VI descriptor
* entry:
*      a -> access mode
*          0 = use any special device capabilities
*          1 = read only
*          2 = write only
*          3 = update (read and write)
*      x -> address of device name string
*
* exit:
*      x -> updated past device name
*      u -> address of device table entry
*
* error:
*      b  -> error code (if any)
*      cc -> carry set on error

                    lda       #$01                attach for read
                    leax      >L0412+1,pcr        skip the slash Load VI only
                    os9       I$Attach            make the call
                    bcs       L0451               didn't work exit
                    stu       >L0416,pcr          did work save address

* Open a path to the device /VI
* entry:
*       a -> access mode (D S PE PW PR E W R)
*       x -> address of the path list
*
* exit:
*       a -> path number
*       x -> address of the last byte if the pathlist + 1
*
* error:
*       b  -> error code(if any)
*       cc -> carry set on error
*
*                            a still contains $01 read
                    leax      >L0412,pcr          load with device name including /
                    os9       I$Open              make the call
                    bcs       L0451               didn't work exit
                    sta       >L0418,pcr          did work save path #

* Allocate process+path RAM blocks

                    ldb       #SS.ARAM            $CA function code for VIRQ
                    ldx       #$000C
                    os9       I$SetStt            make the call
                    bcs       L0451
                    pshs      x

* Set process+path VIRQ KQ3
                    ldb       #SS.KSet            $C8 function code for VIRQ
                    os9       I$SetStt
                    puls      b,a
L0451               rts

* Signal Intercept processing gets copied to int5EE mem slot
L0452               cmpb      #$80                b gets the signal code if not $80 ignore
                    bne       L0464               $80 is user defined
                    tfr       u,d
                    tfr       a,dp
                    dec       <u004A
                    bne       L0464
                    bsr       L0465
                    lda       #$03
                    sta       <u004A
L0464               rti

L0465               inc       >u024C,u
                    bne       L047B
                    inc       >u024B,u
                    bne       L047B
                    inc       >u024A,u
                    bne       L047B
                    inc       >u0249,u
L047B               tst       >u0102,u
                    bne       L04BC
                    inc       <u003F
                    bne       L0487
                    inc       <u003E
L0487               ldd       <u0048
                    addd      #$0001
                    std       <u0048
                    cmpd      #$0014
                    bcs       L04BC
                    subd      #$0014
                    std       <u0048
                    ldd       #$003C
                    leax      >u043D,u
                    inc       ,x
                    cmpb      ,x
                    bhi       L04BC
                    sta       ,x+
                    inc       ,x
                    cmpb      ,x
                    bhi       L04BC
                    sta       ,x+
                    inc       ,x
                    ldb       #$18
                    cmpb      ,x
                    bhi       L04BC
                    sta       ,x+
                    inc       ,x
L04BC               rts

* deallocates the VIRQ device
L04BD               lda       >L0418,pcr          load path number to /VI device
                    beq       L04D0               no path open check for device table addr
                    ldb       #SS.KClr            $C9 Clear KQ3 VIRQ
                    os9       I$SetStt            make the call
                    ldb       #SS.DRAM            $CB deallocate the ram
                    os9       I$SetStt            make the call
                    os9       I$Close             close the path to /VI
L04D0               ldu       >L0416,pcr          load device table address for VI
                    beq       L04D9               don't have one leave now
                    os9       I$Detach            else detach it
L04D9               rts

*  Twiddles with MMU blocks for us
*  This sub gets copied into $0659 and executed there from this and
*  the other modules this one loads (sub659)
*
*  s and x loaded by calling routine

L04DA               ldd       ,s++                load d with current stack pointer and bump it
*                         from mnln we come in with $4040
                    std       <u002A              save the calling stack pointer in u002A
                    orcc      #IntMasks           mask the interrupts
                    lda       <u0042
                    sta       ,x                  x is loaded with value from u0028 in mnln
                    sta       >$FFA9              task 1 block 2 x2000 - x3FFF
                    ldu       <u0043
                    lda       $06,x
                    sta       u000C,u
                    sta       >$FFAF              task 1 block 8 xE000 - xFFFF
                    lda       $05,x
                    sta       u000A,u
                    sta       >$FFAE              task 1 block 7 xC000 - xDFFF
                    lda       $04,x
                    sta       u0008,u
                    sta       >$FFAD              task 1 block 6 xA000 - xBFFF
                    lda       $03,x
                    sta       u0006,u
                    sta       >$FFAC              task 1 block 5 x8000 - x9FFF
                    lda       $02,x
                    sta       u0004,u
                    sta       >$FFAB              task 1 block 4 x6000 - x7FFF
                    andcc     #^IntMasks          unmask interrupts

                    lda       $07,x
                    ldu       <u002E
                    adda      u000A,u
                    jsr       a,u

                    orcc      #IntMasks
                    lda       <u0042
                    sta       >$FFA9
                    ldu       <u0043
                    lda       <u0010
                    sta       u000C,u
                    sta       >$FFAF
                    lda       <u000F
                    sta       u000A,u
                    sta       >$FFAE
                    lda       <u000E
                    sta       u0008,u
                    sta       >$FFAD
                    lda       <u000D
                    sta       u0006,u
                    sta       >$FFAC
                    lda       <u000B
                    sta       u0002,u
                    sta       >$FFAA
                    lda       <u000A
                    sta       ,u
                    sta       >$FFA9
                    andcc     #^IntMasks

                    jmp       [>$002A]

L054F               fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
L0557               fcb       $73,$69,$65,$72,$72,$61,$00 sierra.

* New routines so we don't have raw reads of the MMU bytes. RG
mmubuf              fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
gprbuf              fzb       512
* Get $FFA0-$FFA7
mmuini1             pshs      cc,x,y
                    orcc      #$50
                    lda       #1                  system ID#
                    leax      gprbuf,pcr
                    os9       F$GPrDsc            get system process descriptor
                    leay      $41,x               point to its mmu block values
                    leax      mmubuf,pcr
                    ldb       #8
m2lup               lda       ,y++                get MMU value and skip over usage
                    sta       ,x+
                    decb
                    bne       m2lup
                    puls      cc,x,y,pc
* Get $FFA8-$FFAF
mmuini2             pshs      cc,x,y
                    orcc      #$50
                    os9       F$ID                get our ID#
                    leax      gprbuf,pcr
                    os9       F$GPrDsc            get our process descriptor
                    leay      $41,x               point to our mmu block values
                    leax      mmubuf+8,pcr
                    ldb       #8
mloop               lda       ,y++
                    sta       ,x+
                    decb
                    bne       mloop
                    puls      cc,x,y,pc

                    emod
eom                 equ       *
                    end
