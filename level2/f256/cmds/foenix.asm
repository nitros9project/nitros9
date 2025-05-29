********************************************************************
* foenix - Foenix Basic09 subroutine module
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2024/03/13  Boisy Gene Pitre
* Created.
*   2      2024/11/02  Matt Massie - Added Foenix F256 Graphics, Mouse, Joystick functions

                  IFP1
                    use       ../defs/os9.d
                    use       scf.d
                    use       ../defs/f256.d
                    use       f256vtio.d
                    *use      defsfile
                  ENDC

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       $05

                    mod       eom,name,tylg,atrv,start,size

* Data size since BASIC09 subroutine modules do everything on the stack
u0000               rmb       0
size                equ       .

name                fcs       /foenix/
                    fcb       edition

                    fcb       $00

* Offsets for parameters accessed directly (there can be more, but they are handled in loops)
                    org       0
Return              rmb       2         $00    Return address of caller
PCount              rmb       2         $02    # of parameters following
PrmPtr1             rmb       2         $04 00 pointer to 1st parameter data
PrmLen1             rmb       2         $06 02 length of 1st parameter
PrmPtr2             rmb       2         $08 04 pointer to 2nd parameter data
PrmLen2             rmb       2         $0A 06 length of 2nd parameter
PrmPtr3             rmb       2         $0C 08 pointer to 3rd parameter data
PrmLen3             rmb       2         $0E 0A length of 3rd parameter
PrmPtr4             rmb       2         $10 0C pointer to 4th parameter data
PrmLen4             rmb       2         $12 0E length of 4th parameter
PrmPtr5             rmb       2         $14 10 pointer to 5th parameter data
PrmLen5             rmb       2         $16 12 length of 5th parameter
PrmPtr6             rmb       2         $18 14 pointer to 6th parameter data
PrmLen6             rmb       2         $1A 16 length of 6th parameter
PrmPtr7             rmb       2         $1C 18 pointer to 7th parameter data
PrmLen7             rmb       2         $1E 1A length of 7th parameter
PrmPtr8             rmb       2         $20 1C pointer to 8th parameter data
PrmLen8             rmb       2         $22 1E length of 8th parameter
X1                  rmb       2         $24 20 Universal X1 Variable
Y1                  rmb       2         $26 22 Universal Y1 Variable
X2                  rmb       2         $28 24 Universal X2 Variable
Y2                  rmb       2         $2A 26 Universal Y2 Variable
dx                  rmb       2         $2C 28
dy                  rmb       2         $2E 2A
dx2                 rmb       2         $30 2C
dy2                 rmb       2         $32 2E
p                   rmb       2         $34 30
currBlk             rmb       2         $36 32 Variable currBlk BMLoad
mapaddr             rmb       2         $38 34 Variable mapaddr BMLoad
pxlblk0             rmb       1         $3A 36 Variable for Pixel
pxlblk              rmb       1         $3C 38 Variable for Pixel
pxlblkaddr          rmb       2         $3E 3A
bmblock             rmb       1         $40 3C first bitmap block
steep               rmb       1         $41 3D line variables
univ8a              rmb       1         $42 3E
univ8b              rmb       1         $43 3F
univ8c              rmb       1         $44 40
univ8d              rmb       1         $45 41
currPath            rmb       1         $46 42 Variable  currPath BMLoad
blkCnt              rmb       1         $47 43 Variable blkCnt BMLoad
slperr              rmb       2         $48 44 Slope error
d                   rmb       2         $4A 46 Decision
cnt                 rmb       2         $4C 48 count 
radius              rmb       1         $4E 4A radius
ssize               rmb       2
lut                 rmb       2
layer               rmb       2
offset              rmb       2      
enable              rmb       2
endian              rmb       1
stkdepth            equ       .

* Function table. Please note, that on entry to these subroutines, the main temp stack is already
* allocated (33 bytes), B=# of parameters received
* Sneaky trick for end of table markers - it does a 16 bit load to get the offset to the function
*  routine. It has been purposely made so that every one of these offsets >255, so we only need a
*  single $00 byte as the high byte to designate the end of a table

FuncTbl
                    fdb       Random-FuncTbl
                    fcc       "Random"
                    fcb       $FF

                    fdb       Seed-FuncTbl
                    fcc       "Seed"
                    fcb       $FF

                    fdb       DWSet-FuncTbl
                    fcc       "DWSet"
                    fcb       $FF

                    fdb       Palette-FuncTbl
                    fcc       "Palette"
                    fcb       $FF

                    fdb       Color-FuncTbl
                    fcc       "Color"
                    fcb       $FF

                    fdb       CurHome-FuncTbl
                    fcc       "CurHome"
                    fcb       $FF

                    fdb       CurXY-FuncTbl
                    fcc       "CurXY"
                    fcb       $FF

                    fdb       ErLine-FuncTbl
                    fcc       "ErLine"
                    fcb       $FF

                    fdb       ErEOLine-FuncTbl
                    fcc       "ErEOLine"
                    fcb       $FF

                    fdb       CurOff-FuncTbl
                    fcc       "CurOff"
                    fcb       $FF

                    fdb       CurOn-FuncTbl
                    fcc       "CurOn"
                    fcb       $FF

                    fdb       CurRgt-FuncTbl
                    fcc       "CurRgt"
                    fcb       $FF

                    fdb       Bell-FuncTbl
                    fcc       "Bell"
                    fcb       $FF

                    fdb       CurLft-FuncTbl
                    fcc       "CurLft"
                    fcb       $FF

                    fdb       CurUp-FuncTbl
                    fcc       "CurUp"
                    fcb       $FF

                    fdb       CurDwn-FuncTbl
                    fcc       "CurDwn"
                    fcb       $FF

                    fdb       ErEOWndw-FuncTbl
                    fcc       "ErEOWndw"
                    fcb       $FF

                    fdb       Clear-FuncTbl
                    fcc       "Clear"
                    fcb       $FF
                    
                    fdb       Display-FuncTbl
                    fcc       "Display"
                    fcb       $FF

                    fdb       CrRtn-FuncTbl
                    fcc       "CrRtn"
                    fcb       $FF

                    fdb       InsLin-FuncTbl
                    fcc       "InsLin"
                    fcb       $FF

                    fdb       DelLin-FuncTbl
                    fcc       "DelLin"
                    fcb       $FF

                    fdb       Tone-FuncTbl
                    fcc       "Tone"
                    fcb       $FF

                    fdb       WInfo-FuncTbl
                    fcc       "WInfo"
                    fcb       $FF

                    fdb       ID-FuncTbl
                    fcc       "ID"
                    fcb       $FF

                    fdb       GetDow-FuncTbl
                    fcc       "GetDow"
                    fcb       $FF

                    fdb       GetDate-FuncTbl
                    fcc       "GetDate"
                    fcb       $FF

                    fdb       GetTime-FuncTbl
                    fcc       "GetTime"
                    fcb       $FF

                    fdb       JoyL-FuncTbl
                    fcc       "Joyl"
                    fcb       $FF
                    
                    fdb       JoyR-FuncTbl
                    fcc       "Joyr"
                    fcb       $FF
                    
                    fdb       INKEY-FuncTbl
                    fcc       "INKEY"
                    fcb       $FF

                    fdb       Mult-FuncTbl
                    fcc       "Mult"
                    fcb       $FF

                    fdb       Real-FuncTbl
                    fcc       "Real"
                    fcb       $FF

                    fdb       FNLoad-FuncTbl
                    fcc       "FNLoad"
                    fcb       $FF
                    
                    fdb       FNChar-FuncTbl
                    fcc       "FNChar"
                    fcb       $FF

                    fdb       MouseHR-FuncTbl
                    fcc       "MouseHR"
                    fcb       $FF
                    
                    fdb       Mouse-FuncTbl
                    fcc       "Mouse"
                    fcb       $FF
                    
                    fdb       GFree-FuncTbl
                    fcc       "GFree"
                    fcb       $FF
                                       
                    fdb       Bitmap-FuncTbl
                    fcc       "Bitmap"
                    fcb       $FF
                    
                    fdb       ClutLoad-FuncTbl
                    fcc       "ClutLoad"
                    fcb       $FF
                    
                    fdb       ClutFree-FuncTbl
                    fcc       "ClutFree"
                    fcb       $FF
                    
                    fdb       BMStatus-FuncTbl
                    fcc       "BMStatus"
                    fcb       $FF
                    
                    fdb       BMoff-FuncTbl
                    fcc       "BMoff"
                    fcb       $FF                    
                    
                    fdb       Gon-FuncTbl
                    fcc       "Gon"
                    fcb       $FF
                    
                    fdb       Goff-FuncTbl
                    fcc       "Goff"
                    fcb       $FF
                    
                    fdb       BMSave-FuncTbl
                    fcc       "BMSave"
                    fcb       $FF
                    
                    fdb       BMClear-FuncTbl
                    fcc       "BMClear"
                    fcb       $FF
                    
                    fdb       BMLoad-FuncTbl
                    fcc       "BMLoad"
                    fcb       $FF

                    fdb       Pixel-FuncTbl
                    fcc       "Pixel"
                    fcb       $FF
                    
                    fdb       GetPixel-FuncTbl
                    fcc       "GetPixel"
                    fcb       $FF
                    
                    fdb       Box-FuncTbl
                    fcc       "Box"
                    fcb       $FF
                    
                    fdb       Bar-FuncTbl
                    fcc       "Bar"
                    fcb       $FF
                    
                    fdb       Line-FuncTbl
                    fcc       "Line"
                    fcb       $FF
                    
                    fdb       Circle-FuncTbl
                    fcc       "Circle"
                    fcb       $FF
                    
                    fdb       SPCreate-FuncTbl
                    fcc       "SPCreate"
                    fcb       $FF
                    
                    fdb       SPConfig-FuncTbl
                    fcc       "SPConfig"
                    fcb       $FF
                    
                    fdb       SPAssign-FuncTbl
                    fcc       "SPAssign"
                    fcb       $FF
                    
                    fdb       SPPos-FuncTbl
                    fcc       "SPPos"
                    fcb       $FF
                    
                    fdb       SPLoad-FuncTbl
                    fcc       "SPLoad"
                    fcb       $FF
                    
                    fdb       SPSave-FuncTbl
                    fcc       "SPSave"
                    fcb       $FF
                    
                    fdb       SPKill-FuncTbl
                    fcc       "SPKill"
                    fcb       $FF
                    
                    fdb       Peekw-FuncTbl
                    fcc       "Peekw"
                    fcb       $FF
                    
                    fdb       Pokew-FuncTbl
                    fcc       "Pokew"
                    fcb       $FF
                    
                    fdb       MapBlk-FuncTbl
                    fcc       "MapBlk"
                    fcb       $FF
                    
                    fdb       ClrBlk-FuncTbl
                    fcc       "ClrBlk"
                    fcb       $FF

* Test by sending non-existant function name
                    fcb       $00       end of table marker

;stkdepth            equ       $21
;stkdepth            equ       $27       BMLoad variables added
;stkdepth            equ       $2C       Added Pixel Variables + carry 2B was 2C 
;stkdepth            equ       $2B       BMLoad variables added
* All functions (from the call table) are entered with the following parameters:
*   Y = pointer to function subroutine
*   X = pointer to "stkdepth" byte scratch variable area (same as stack pointer, which has allocated that extra memory)
*   U = pointer to 2nd parameter (first parameter after name itself)
*   D = # of parameters (NOTE: function name itself is always parameter 1)

* Stack on entry to every function routine (with stkdepth set to 9):
*   $00-$08 / 00-08,s - temporary scratch variable area
*   $09-$0A / 09-10,s - RTS address to BASIC09/RUNB
*   $0B-$0C / 11-12,s - # of parameters (including function name itself)
*   $0D-$0E / 13-14,s - pointer to 1st parameter's data (function name)
*   $0F-$10 / 15-16,s - length of first parameter
* From here on is optional, depending on the function being called, there can be up to 9 parameter pairs
* (pointer/value and length).
* The temporary stack uses 0,s as the path #, and 1,s + as the output buffer.

start               leas      <-stkdepth,s reserve bytes on stack
                    clr       <pxlblk0,s
                    clr       <pxlblk,s
                    clr       <pxlblkaddr,s
                    clr       <pxlblkaddr+1,s
                    clr       <bmblock,s
                    clr       ,s        clear optional path # is BYTE or INTEGER flag
                    ldd       <stkdepth+PCount,s get # of parameters
                    beq       ParamErr  if 0, exit with parameter error
                    tsta                if >255, exit with parameter error
                    bne       ParamErr  branch if >255
                    ldd       [<stkdepth+PrmPtr1,s] get value from first parameter (optional path #)
                    ldx       <stkdepth+PrmLen1,s get length of 1st parameter
                    leax      -1,x      decrement length
                    beq       byte@     if zero, it's a BYTE value, so save path #
                    leax      -1,x      decrement length again
                    bne       nopath@   if not INTEGER value, no optional path, 1st parameter is keyword
                    tfr       b,a       it's an INTEGER value, so save LSB as path #
byte@               sta       ,s        save on stack
                    dec       <stkdepth+PCount+1,s decrement # of parameters (to skip path #)
                    ldx       <stkdepth+PrmPtr2,s X = pointer to function name we received
                    leau      <stkdepth+PrmPtr3,s U = pointer to (possible) 1st parameter for function
                    bra       L02B8
* No optional path, set path to Std Out, and point X/U to function name and 1st parameter for it.
nopath@             inc       ,s        no optional path # specified, set path to 1 (Std Out)
                    ldx       <stkdepth+PrmPtr1,s point to function name
                    leau      <stkdepth+PrmPtr2,s point to first parameter of function
* Entry here: X=pointer to function name passed from caller
*             U=pointer to 1st parameter for function
L02B8               pshs      u,x       save 1st parameter & function name pointers
                    leau      >FuncTbl,pcr point to table of supported functions
L02BE               ldy       ,u++      get pointer to subroutine
                    beq       L02F0     if $0000, exit with Unimplemented Routine Error (out of functions)
                    ldx       ,s        get pointer to function name we were sent
L02C5               lda       ,x+       get character from caller
                    eora      ,u+       force matching case and compare with table entry
                    anda      #$DF      set case
                    beq       L02D5     matched, skip ahead
                    leau      -1,u      bump table pointer back one
L02CF               tst       ,u+       hi bit set on last character? ($FF check cheat)
                    bpl       L02CF     no, keep scanning till we find end of table entry text
                    bra       L02BE     check next table entry

L02D5               tst       -1,u      was hi bit set on matching character? (we hit end of function name?)
                    bpl       L02C5     no, check next character
* 6809/6309 - skip leas, change puls u below to puls u,x (faster, and we reload X anyways)
                    leas      2,s       yes, function found. Eat copy of pointer to function name we were sent
                    tfr       y,d       copy jump table offset to D
                    leay      >FuncTbl,pcr point to table of supported functions again
                    leay      d,y       add offset
                    puls      u         get original 1st parameter pointer
                    leax      1,s       point to temp write buffer we are building

                    lda       #$1B      start it with an ESCAPE code (most functions use this)
                    sta       ,x+       store it in the output buffer
                    ldd       <stkdepth+PCount,s get # of params again including path (if present) & function name pointer
                    jmp       ,y        call function subroutine & return from there

L02F0               leas      4,s       clean the stack
                    ldb       #E$NoRout unimplemented routine error
                    bra       L02F8

ParamErr            ldb       #E$ParmEr parameter error
L02F8               coma                set the carry
                    leas      <stkdepth,s clean the stack
                    rts                 return to the caller

* For all calls from table, entry is:
*   Y = The address of routine.
*   X = Output buffer pointer ($1B is preloaded).
*   U = Pointer to 1st parameter for function.
*   D = # of parameters being passed (including optional path #, and function name pointer).

;;; INKEY
;;;
;;; calling syntax: RUN FOENIX([path,],"INKEY",keyval)
INKEY               cmpb      #2               2 parameters?
                    beq       InKey20          No Path just retkey
                    ;cmpb      #3               3 parameters?
                    lbne      ParamErr         no, exit with Parameter Error
InKey20             pshs      a,x,y,u          Preserve registers
                    lda       ,s               Path # from stack
                    ldb       #SS.Ready
                    os9       I$GetStt         see if key ready
                    bcc       getit
                    cmpb      #E$NotRdy        no keys ready=no error
                    bne       exit@            other error, report it
                    clra                       no error
                    bra       exit@
getit               lbsr      FGETC            go get the key
                    tsta                       Nil?
                    clrb
                    exg       a,b              Swap A and B
                    std       [,u]
exit@               puls      u,y,x,a
                    leas      <stkdepth,s      clean the stack
                    rts                        return to the caller   

FGETC               pshs      a,x,y
                    ldy       #1               number of char to print
                    tfr       s,x              point x at 1 char buffer
                    os9       I$Read
                    puls      a,x,y,pc

;;; JoyR Right Joystick Input
;;;
;;; calling syntax: RUN FOENIX([path,],"JoyR",x,y,btn)
JoyR                cmpb      #4               4 parameters?
                    lbne      ParamErr         no, exit with Parameter Error
                    lda       ,s               Path # from stack
                    ldx       #$00             Right Joystick
                    ldb       #SS.Joy          Joystick Code
                    os9       I$GetStt
                    stx       [,u]             Store X value 1st parameter
                    sty       [<$04,u]         Store Y value 2nd parameter
                    clrb                       Clear B - A = 255 Fire Btn
                    exg       a,b              Swap A and B
                    std       [<$08,u] 
                    leas      <stkdepth,s      eat temporary stack
                    rts                        return to the caller

;;; JoyL Left Joystick Input
;;;
;;; calling syntax: RUN FOENIX([path,],"Joyl",x,y,btn)
Joyl                cmpb      #4               4 parameters?
                    lbne      ParamErr         no, exit with Parameter Error
                    ;lda       ,s               Path # from stack
                    lda       #1               Output Path
                    ldx       #$01             Left Joystick
                    ldb       #SS.Joy          Joystick Code
                    os9       I$GetStt
                    stx       [,u]             Store X value 1st parameter
                    sty       [<$04,u]         Store Y value 2nd parameter
                    clrb                       Clear B - A = 255 Fire Btn
                    exg       a,b      
                    std       [<$08,u] 
                    leas      <stkdepth,s      eat temporary stack
                    rts                        return to the caller

;;; SPCreate - Create Spritesheet
;;;
;;;
;;; calling syntax: RUN FOENIX([path,],"SPCreate",bm)
SPCreate            cmpb      #2               2 parameter
                    lbne      ParamErr         no, exit with Parameter Error
                    leas      <stkdepth,s      eat temporary stack
                    rts                        return to the caller

;;; SPConfig - Configure Sprites
;;;
;;; SIZE 0=32x32,1=24x24, 2=16x16, 3=8x8
;;; LAYER 0-3
;;; LUT 0-3
;;; Enable 1=Enabled 0=Disabled
;;; calling syntax: RUN FOENIX([path,],"SPConfig",sprite#,size,layer,LUT, Enable)
SPConfig            cmpb      #6               6 parameters?
                    lbne      ParamErr         no, exit with Parameter Error
                    pshs      a,b,x,y,u        Put the variables on the stack
                    ldx       #$c0             map page with sprite control reg
                    pshs      u                preserve u
                    ldb       #$01             need 1 block
                    os9       F$MapBlk         map it into process address space
                    lbcs      err@
                    exg       u,x              mapped block to x
                    puls      u
                    stx       <mapaddr,s       mapped address
* config sprite
                    ldd       [,u]             get sprite #
                    lslb
                    rola                       
                    lslb
                    rola                       
                    lslb
                    rola                       multiply to get offset 8 bytes per sprite                    
                    std       <offset,s        save offset
                    std       $fee2
                    ldd       [<$10,u]         get enable
                    ;andd      #$0001           isolate enable
                    std       <enable,s
                    ldd       [<$0C,u]         get LUT
                    ;andd      #$0003           isolate lut 2 bit
                    lslb
                    rola                       need LUT at bits 2-1, bit 0=enable
                    std       <lut,s
                    ;std       $fee4
                    ldd       [<$08,u]         get layer
                    lslb
                    rola                       
                    lslb
                    rola                       
                    lslb
                    rola                       need layer at bits 4-3
                    std       <layer,s
                    ldd       [<$04,u]             size value
                    lslb
                    rola                       
                    lslb
                    rola                       
                    lslb
                    rola
                    lslb
                    rola                       need size at bits 6-5                  
                    std       <ssize,s
                    clrd                       d=0
                    addd      <enable,s        setup sprite config byte
                    addd      <lut,s
                    addd      <layer,s
                    addd      <ssize,s
                    std       $fee0
                    exg       x,d              mapaddr to d, sprite config bytes x
                    addd      #$1300           add offset to sprite register
                    addd      <offset,s        sprite # offset
                    exg       x,d              x calculated offset, sprite config d
                    stb       ,x               store sprite config in sprite register
* clrblk
                    ldu       <mapaddr,s       get mapped address
                    pshs      u                clear MapBlk from DAT Image
                    ldx       #$C0             page to unmap
                    ldb       #1               clearing 1 block
                    os9       F$ClrBlk         remove block from DAT Image
                    clrb
err@                puls      u
                    puls      u,y,x,b,a
                    leas      <stkdepth,s      eat temporary stack
                    rts                        return to the caller

;;; SPAssign - Assign sprite
;;;
;;; calling syntax: RUN FOENIX([path,],"SPAssign",sprite#,mem_loc)
SPAssign            cmpb      #3               3 parameters?
                    lbne      ParamErr         no, exit with Parameter Error
                    lda       7,u              get the length of the 2nd parameter
                    cmpa      #3               3 bytes?
                    lbne      ParamErr         no, return an error
                    pshs      a,b,x,y,u        Put the variables on the stack
                    ldx       #$c0             map page with sprite control reg
                    pshs      u                preserve u
                    ldb       #$01             need 1 block
                    os9       F$MapBlk         map it into process address space
                    lbcs      err@
                    exg       u,x              mapped block to x
                    puls      u
                    stx       <mapaddr,s       mapped address
                    ldd       [,u]             get sprite #
                    lslb
                    rola                       
                    lslb
                    rola                       
                    lslb
                    rola                       multiply to get offset 8 bytes per sprite                    
                    std       <offset,s        save offset
                    tfr       x,d              mapped addr to d
                    addd      #$1300           sprite registers offset
                    addd      <offset,s        sprite # offset
                    tfr       d,y              y=sprite # base register
                    leax      [<$04,u]         get address of 2nd parameter
                    lda       ,x+              get first byte of 3
                    sta       1,y              store first byte memory addr  H
                    lda       ,x+              get second byte of 3
                    sta       2,y              store second byte memory addr M
                    lda       ,x+              get third byte of memory addr 
                    sta       3,y              store third byte              L
* clrblk
                    ldu       <mapaddr,s       get mapped address
                    pshs      u                clear MapBlk from DAT Image
                    ldx       #$C0             page to unmap
                    ldb       #1               clearing 1 block
                    os9       F$ClrBlk         remove block from DAT Image
                    clrb
err@                puls      u
                    puls      u,y,x,b,a
                    leas      <stkdepth,s      eat temporary stack
                    rts                        return to the caller

;;; SPPos -  Sprite Position
;;;
;;; calling syntax: RUN FOENIX([path,],"SPPos",sprite#,X,Y)
SPPos               cmpb      #4               3 parameters?
                    lbne      ParamErr         no, exit with Parameter Error
                    pshs      a,b,x,y,u        Put the variables on the stack
                    lbsr      chk_endian
                    ldd       <endian,s
                    std       $fee0
                    ldx       #$c0             map page with sprite control reg
                    pshs      u                preserve u
                    ldb       #$01             need 1 block
                    os9       F$MapBlk         map it into process address space
                    lbcs      err@
                    exg       u,x              mapped block to x
                    puls      u
                    stx       <mapaddr,s       mapped address
* calc offset                    
                    ldd       [,u]             get sprite #
                    lslb
                    rola                       
                    lslb
                    rola                       
                    lslb
                    rola                       multiply to get offset 8 bytes per sprite                    
                    std       <offset,s        save offset
                    exg       x,d              mapaddr to d
                    addd      #$1300           add offset to sprite register
                    addd      <offset,s        sprite # offset
                    exg       x,d              x = sprite # base address
                    ldd       [<$04,u]         get x position
                    std       4,x              store x value in sprite register
                    ;stb       4,x
                    ;sta       5,x
                    ldd       [<$08,u]         get y position
                    std       6,x              store y value in sprite register
                    ;stb       6,x
                    ;sta       7,x
* clrblk
                    ldu       <mapaddr,s       get mapped address
                    pshs      u                clear MapBlk from DAT Image
                    ldx       #$C0             page to unmap
                    ldb       #1               clearing 1 block
                    os9       F$ClrBlk         remove block from DAT Image
                    clrb
err@                puls      u
                    puls      u,y,x,b,a
                    leas      <stkdepth,s      eat temporary stack
                    rts                        return to the caller

;;; SPLoad - Load Sprite
;;; 
;;; from file, from data module file or loaded data module (or memory?)
;;; calling syntax: RUN FOENIX([path,],"SPLoad",sprite#,spritefile,bm)
SPLoad              cmpb      #4               4 parameters?
                    lbne      ParamErr         no, exit with Parameter Error
                    leas      <stkdepth,s      eat temporary stack
                    rts                        return to the caller

;;; SPSave - Save Sprite
;;;
;;;
;;; calling syntax: RUN FOENIX([path,],"SPSave",sprite#,spritefile)
SPSave              cmpb      #3               3 parameters?
                    lbne      ParamErr         no, exit with Parameter Error
                    leas      <stkdepth,s      eat temporary stack
                    rts                        return to the caller

;;; SPKill - Sprite Kill - Free sprite memory
;;;
;;; calling syntax: RUN FOENIX([path,],"SPKill",sprite#,spritefile)
SPKill              cmpb      #3               3 parameters?
                    lbne      ParamErr         no, exit with Parameter Error
                    leas      <stkdepth,s      eat temporary stack
                    rts                        return to the caller

;;; Check for little/big endian Math Co-Pro
;;;
chk_endian          ldd       #$0100           check for big endian
                    std       $fee0
                    ldd       #$0200
                    std       $fee2
                    lda       $fef1            big endian should be 2
                    cmpa       #$02
                    beq       big@
                    clra
                    sta       <endian+2,s      0 = little endian
                    bra       cont@
big@                lda       #1               1 = big endian
                    sta       <endian+2,s         
cont@               rts

;;; Pixel - Draw Pixel
;;;
;;; takes X,Y and color and puts it in the bitmap bmblock
;;; x=X
;;; y=Y
;;; a=color
;;; calling syntax: RUN FOENIX([path,],"Pixel",X,Y,Color,bmblock)
Pixel               cmpb      #5               5 parameters?
                    lbne      ParamErr         no, exit with Parameter Error
                    clr       <pxlblk0,s
                    clr       <pxlblk,s
                    clr       <pxlblkaddr,s
                    clr       <pxlblkaddr+1,s
                    clr       <bmblock,s
                    ldx       [,u]             X value 1st parameter
                    ldy       [<$04,u]         Y value 2nd parameter
                    ldd       [<$0C,u]         Get BMBlock
                    exg       a,b              LSB to A
                    sta       <bmblock,s       store in stack variable
                    sta       <$1F,u           store bmblock in u
                    ldd       [<$08,u]         Color 3rd parameter
                    exg       a,b              LSB to A
                    pshs      a,b,x,y,u        Put the variables on the stack
                    leas      -1,s             add 1 byte to stack for carry -1
                    clr       ,s               0=carry,1=color,2=y,3=X
*                   **** D = 320 * gy.
*                   **** 320 = 256 + 64, so use MUL for the lower byte,
*                   **** and then add gy (gy * 256) to the upper byte.
                    lda       6,s              py     ; 8 bits.
                    ldb       #64
                    mul
                    adda      6,s              py
                    ror       ,s               <pcarry  ; Collect the carry bit.
*                   **** D += gx.
                    addd      3,s              px     ; 16 bits.
                    ror       ,s               <pcarry  ; Collect the carry bit.
*                   **** Stash the block ID bits.
                    pshs      a
*                   **** Move the lower 13 bits (8191) into a pointer.
                    anda      #31
                    tfr       d,x
*                   **** Restore the carry.
*                   **** This add will set/clear the carry
*                   **** based on the previously collected carry bits.
                    ldb       1,s                   carry bit 
                    addb      #192
*                   **** ror it into the top of the block bits.
                    puls      a
                    rora
*                   **** Shift the block bits to the bottom of A. 
                    lsra
                    lsra
                    lsra
                    lsra
*                   **** A now contains the relative block number,
*                   **** and X contains the block relative offset.xxxxxxxx               
                    pshs      x                   stx pixel offset
                    ;adda      #$36                  bmblock
                    adda       <$1F,u             bmblock
                    ;adda      [<$0C,u]           add bmblock
mapit@              sta       <pxlblk+2,s              store the new block we will map
                    ldx       <pxlblk0+2,s             load x with mapblock for F$MapBlk
                    ldb       #1                  map 1 block
                    pshs      u                   push u (F$MapBlk returns address in u)
                    os9       F$MapBlk            Map the block
                    lbcc      mapgood@            if successful, finish
                    puls      u,x                 error, clean up and return
                    bra       cleanup@            
mapgood@            stu       <pxlblkaddr+4,s         store the logical address
                    puls      u
storepixel@         ldd       <pxlblkaddr+2,s
                    puls      x                   pull blk relative offset
                    leax      d,x                 add in logical start of block
                    lda       1,s                 lda with the color
                    sta       ,x                  write the pixel
cleanup@            leas      1,s                 pull carry byte off stack
*                    lbsr      fclrblk
                    pshs      b,u
                    ldu       <pxlblkaddr+2,s    ; was 4
                    ldb       #1
                    os9       F$ClrBlk
                    puls      b,u 
stkclean            puls      u,y,x,b,a           clean up stack 
                    clrb                          No routine returns an error here so return 0
                    leas      <stkdepth,s         eat temporary stack
                    rts                           return to the caller

;;; GetPixel - Return the color of pixel at x,y
;;;
;;; takes X,Y and color and puts it in the bitmap bmblock
;;; x=X
;;; y=Y
;;; a=color
;;; calling syntax: RUN FOENIX([path,],"GetPixel",X,Y,Color,bmblock)
GetPixel            cmpb      #5               5 parameters?
                    lbne      ParamErr         no, exit with Parameter Error
                    clr       <pxlblk0,s
                    clr       <pxlblk,s
                    clr       <pxlblkaddr,s
                    clr       <pxlblkaddr+1,s
                    clr       <bmblock,s
                    clr       <$1F,u
                    ldx       [,u]             X value 1st parameter
                    ldy       [<$04,u]         Y value 2nd parameter
                    ldd       [<$0C,u]         Get BMBlock
                    exg       a,b              LSB to A
                    ;sta       <bmblock,s       store in stack variable
                    sta       <$1F,u           store bmblock in u
                    ldd       [<$08,u]         Color 3rd parameter
                    exg       a,b              LSB to A
                    pshs      a,b,x,y,u        Put the variables on the stack
                    leas      -1,s             add 1 byte to stack for carry -1
                    clr       ,s               0=carry,1=color,2=y,3=X
*                   **** D = 320 * gy.
*                   **** 320 = 256 + 64, so use MUL for the lower byte,
*                   **** and then add gy (gy * 256) to the upper byte.
                    lda       6,s              py     ; 8 bits.
                    ldb       #64
                    mul
                    adda      6,s              py
                    ror       ,s               <pcarry  ; Collect the carry bit.
*                   **** D += gx.
                    addd      3,s              px     ; 16 bits.
                    ror       ,s               <pcarry  ; Collect the carry bit.
*                   **** Stash the block ID bits.
                    pshs      a
*                   **** Move the lower 13 bits (8191) into a pointer.
                    anda      #31
                    tfr       d,x
*                   **** Restore the carry.
*                   **** This add will set/clear the carry
*                   **** based on the previously collected carry bits.
                    ldb       1,s                   carry bit 
                    addb      #192
*                   **** ror it into the top of the block bits.
                    puls      a
                    rora
*                   **** Shift the block bits to the bottom of A. 
                    lsra
                    lsra
                    lsra
                    lsra
*                   **** A now contains the relative block number,
*                   **** and X contains the block relative offset.xxxxxxxx               
                    pshs      x                   stx pixel offset
                    ;adda      #$36                  bmblock
                    ;adda      #$2C                   bmblock
                    adda       <$1F,u             add bmblock to relative block
mapit@              sta       <pxlblk+2,s              store the new block we will map
                    ldx       <pxlblk0+2,s             load x with mapblock for F$MapBlk
                    ldb       #1                  map 1 block
                    pshs      u                   push u (F$MapBlk returns address in u)
                    os9       F$MapBlk            Map the block
                    lbcc      mapgood@            if successful, finish
                    puls      u,x                 error, clean up and return
                    bra       clean            
mapgood@            stu       <pxlblkaddr+4,s         store the logical address
                    puls      u
storepixel@         ldd       <pxlblkaddr+2,s
                    puls      x                   pull blk relative offset
                    leax      d,x                 add in logical start of block
                    ;lda       1,s                 lda with the color
                    ;sta       ,x                  write the pixel
                    pshs      b
                    clrb
                    lda       ,x                  get the color at pixel x,y
                    exg       a,b
                    std       [<$08,u]            return the value
                    puls      b
clean               leas      1,s                 pull carry byte off stack
                    pshs      b,u
                    ldu       <pxlblkaddr+2,s    ; was 4
                    ldb       #1
                    os9       F$ClrBlk
                    puls      b,u 
                    puls      u,y,x,b,a           clean up stack 
                    clrb                          No routine returns an error here so return 0
                    leas      <stkdepth,s         eat temporary stack
                    rts                           return to the calle

;;; Box- Draw a rectangle.
;;;
;;; calling syntax: RUN FOENIX([path,],"Box",X1,Y1,X2,Y2,color,bmblock)
Box                 cmpb      #7                  7 parameters?
                    lbne      ParamErr            no, exit with Parameter Error
                    pshs      a,b,x,y,u           push registers on the stack
*                   get caller params and store variables on stack 
                    ldd       [<$10,u]            get lcolor 
                    stb       <univ8c,s           save color
                    ldy       [<$0C,u]            get Y2 from basic
                    sty       <Y2,s               store Y2 in variable  
                    ldx       [<$08,u]            get X2 from basic
                    stx       <X2,s               store in X2 variable
                    ldy       [<$04,u]            get Y1 from basic
                    sty       <Y1,s
                    ldx       [,u]                get X1 from basic
                    stx       <X1,s               store in X1 variable
                    ;lbsr      writepixel2
loop@               ldy       <Y1,s
                    lbsr      writepixel2
                    ldy       <Y2,s
                    lbsr      writepixel2
                    leax      1,x
                    cmpx      <X2,s
                    bne       loop@
                    lbsr      writepixel2
                    ldy       <Y1,s
loop2@              ldx       <X1,s
                    lbsr      writepixel2
                    ldx       <X2,s
                    lbsr      writepixel2
                    leay      1,y
                    cmpy      <Y2,s
                    bne       loop2@
exit@               puls      u,y,x,b,a           restore previous regs from stack
                    clrb                          math results in B causes strange error
                    leas      <stkdepth,s         eat temporary stack
                    rts  

;;; Bar - Draw a filled rectangle.
;;;
;;; calling syntax: RUN FOENIX([path,],"Bar",X1,Y1,X2,Y2,color,bmblock)
Bar                 cmpb      #7                  7 parameters?
                    lbne      ParamErr            no, exit with Parameter Error
                    pshs      a,b,x,y,u           push registers on the stack
*                   get caller params and store variables on stack 
                    ldd       [<$10,u]            get lcolor 
                    stb       <univ8c,s           save color
                    ldy       [<$0C,u]            get Y2 from basic
                    sty       <Y2,s               store Y2 in variable  
                    ldx       [<$08,u]            get X2 from basic
                    stx       <X2,s               store in X2 variable
                    ldy       [<$04,u]            get Y1 from basic
                    sty       <Y1,s
                    ldx       [,u]                get X1 from basic
                    stx       <X1,s               store in X1 variable
                    ;lbsr      writepixel2
                    ;ldy       <Y1,s
loop@               ldx       <X1,s
loop2@              lbsr      writepixel2
                    leax      1,x
                    cmpx      <X2,s
                    bne       loop2@
                    leay      1,y
                    cmpy      <Y2,s
                    bne       loop@
exit@               puls      u,y,x,b,a           restore previous regs from stack
                    clrb                          math results in B causes strange error
                    leas      <stkdepth,s         eat temporary stack
                    rts  

;;; Circle - Draw a circle.
;;; 
;;; CX1=Center X, CY=Center Y, r=Radius,P2=Reserved Future 0, Color, BM First mapped block
;;; calling syntax: RUN FOENIX([path,],"Circle",cX1,cY1,r,p2,color,bmblock)
Circle              cmpb      #7                  7 parameters?
                    lbne      ParamErr            no, exit with Parameter Error
                    pshs      a,b,x,y,u           push registers on the stack
*                   get caller params and store variables on stack 
                    ldd       [<$10,u]            color
                    stb       <univ8c,s
                    ldx       [,u]                X1
                    stx       <X1,s
                    ldy       [<$04,u]            Y1
                    sty       <Y1,s
                    ldd       [<$08,u]            Radius
                    ldx       #0                  initial x=0
                    stx       <X2,s               Store X
                    tfr       d,y                 set y = radius
                    sty       <Y2,s               Store Y
                    lslb
                    rola
                    std       <radius,s           2 * radius
                    ldd       #3                  d=3
                    subd      <radius,s           d=3-(2*Radius)
                    std       <d,s                store decision parameter
*                   drawcircle
                    ldd       <X1,s               get center X
                    addd      <X2,s               add offset
                    tfr       d,x                 store X value
                    ldd       <Y1,s               get center Y
                    addd      <Y2,s               add offset
                    tfr       d,y
                    lbsr      writepixel2
                    ldd       <X1,s               get center X
                    subd      <X2,s               subract offset
                    tfr       d,x                 store X value
                    lbsr      writepixel2         y should already be set Y1+Y2
                    ldd       <X1,s               get center X
                    addd      <X2,s               add offset
                    tfr       d,x                 store X value
                    ldd       <Y1,s               get center Y
                    subd      <Y2,s               subtract offset
                    tfr       d,y
                    lbsr      writepixel2
                    ldd       <X1,s               get center X
                    subd      <X2,s               subract offset
                    tfr       d,x                 store X value
                    lbsr      writepixel2         y should already be Y1-Y2
                    ldd       <X1,s               get center X
                    addd      <Y2,s               add offset
                    tfr       d,x                 store X value
                    ldd       <Y1,s               get center Y
                    addd      <X2,s               add offset
                    tfr       d,y
                    lbsr      writepixel2
                    ldd       <X1,s               get center X
                    subd      <Y2,s
                    tfr       d,x                 store X value
                    ldd       <Y1,s               get center Y
                    addd      <X2,s               add offset
                    tfr       d,y
                    lbsr      writepixel2
                    ldd       <X1,s               get center X
                    addd      <Y2,s               add offset
                    tfr       d,x                 store X value
                    ldd       <Y1,s               get center Y
                    subd      <X2,s               subtract offset
                    tfr       d,y
                    lbsr      writepixel2
                    ldd       <X1,s               get center X
                    subd      <Y2,s
                    tfr       d,x                 store X value
                    ldd       <Y1,s               get center Y
                    subd      <X2,s               subtract offset
                    tfr       d,y
                    lbsr      writepixel2
*                   end drawcircle
cont@               ldd       <d,s                get decision
                    cmpd      #0
                    bgt       cont2@              if d>0
                    ldd       <X2,s               get X value
                    lslb
                    rola                          multiply by 2
                    lslb
                    rola                          multiply by 2 = *4
                    addd      <d,s
                    addd      #6                  d=d + 4 * X2 + 6
                    std       <d,s
                    bra       cont3@
cont2@              ldy       <Y2,s
                    leay      -1,y                decrement
                    sty       <Y2,s
                    ldd       <X2,s               get X value
                    subd      <Y2,s
                    lslb
                    rola                          multiply by 2
                    lslb
                    rola                          multiply by 2 = *4
                    addd      <d,s                 add d
                    addd      #10                 add 10   d=d + 4 * (x-y) + 10
                    std       <d,s
cont3@              ldx       <X2,s
                    leax      1,x                 increment X
                    stx       <X2,s               store X
*                   drawcircle
                    ldd       <X1,s               get center X
                    addd      <X2,s               add offset
                    tfr       d,x                 store X value
                    ldd       <Y1,s               get center Y
                    addd      <Y2,s               add offset
                    tfr       d,y
                    lbsr      writepixel2
                    ldd       <X1,s               get center X
                    subd      <X2,s               subract offset
                    tfr       d,x                 store X value
                    lbsr      writepixel2         y should already be set Y1+Y2
                    ldd       <X1,s               get center X
                    addd      <X2,s               add offset
                    tfr       d,x                 store X value
                    ldd       <Y1,s               get center Y
                    subd      <Y2,s               subtract offset
                    tfr       d,y
                    lbsr      writepixel2
                    ldd       <X1,s               get center X
                    subd      <X2,s               subract offset
                    tfr       d,x                 store X value
                    lbsr      writepixel2         y should already be Y1-Y2
                    ldd       <X1,s               get center X
                    addd      <Y2,s               add offset
                    tfr       d,x                 store X value
                    ldd       <Y1,s               get center Y
                    addd      <X2,s               add offset
                    tfr       d,y
                    lbsr      writepixel2
                    ldd       <X1,s               get center X
                    subd      <Y2,s
                    tfr       d,x                 store X value
                    ldd       <Y1,s               get center Y
                    addd      <X2,s               add offset
                    tfr       d,y
                    lbsr      writepixel2
                    ldd       <X1,s               get center X
                    addd      <Y2,s               add offset
                    tfr       d,x                 store X value
                    ldd       <Y1,s               get center Y
                    subd      <X2,s               subtract offset
                    tfr       d,y
                    lbsr      writepixel2
                    ldd       <X1,s               get center X
                    subd      <Y2,s
                    tfr       d,x                 store X value
                    ldd       <Y1,s               get center Y
                    subd      <X2,s               subtract offset
                    tfr       d,y
                    lbsr      writepixel2
*                   end drawcircle
                    ldd       <Y2,s
                    cmpd      <x2,s               x2=y2
                    lbge      cont@
exit@               puls      u,y,x,b,a           restore previous regs from stack
                    clrb                          math results in B causes strange error
                    leas      <stkdepth,s         eat temporary stack
                    rts  
                    
;;; Line - draw line between 2 coordinates
;;; 
;;; pull from stack: x, y, x, y, color
;;; x=16 bit value, y=8 bit value
;;; pc=01 x=23 y=4 x=56 y=7 c=8
;;; calling syntax: RUN FOENIX([path,],"Line",X1,Y1,X2,Y2,color,bmblock)                   
Line                cmpb      #7                  7 parameters?
                    lbne      ParamErr            no, exit with Parameter Error
                    pshs      a,b,x,y,u           push registers on the stack                    
*                   get caller params and store variables on stack 
                    ldd       [<$10,u]          color
                    stb       <univ8c,s
                    ldx       [,u]              X1
                    stx       <X1,s
                    ldy       [<$04,u]          Y1
                    sty       <Y1,s
                    ldx       [<$08,u]          X2
                    stx       <X2,s
                    ldy       [<$0C,u]          Y2
                    sty       <Y2,s
*                      check for straight line
                    cmpy      <Y1,s
                    lbeq      linehori    Check for horizontal line
*                      check for vertical line
                    cmpx      <X1,s
                    lbeq      linevert    Check for vertical  line
*                      Check for uphill line
                    ldy       <Y1,s
                    cmpy      <Y2,s
                    bhi       uphill@  
*                      Initial X1/X2 comparison
                    ldx       <X1,s
                    cmpx      <X2,s             Compare X1 with X2
                    lblo      cont@             
                    ldd       <X1,s             x1 switchpoints
                    ldx       <x2,s             x2
                    std       <X2,S             x2
                    stx       <X1,s             x1
                    ldd       <Y1,s             y1
                    ldx       <Y2,s             y2
                    std       <Y2,s             y2
                    stx       <Y1,s             y1
                    bra       cont@
uphill@             ldd       <X2,s             get X2
                    subd      <X1,s             sub X1
                    std       $fee6             store Math Co-Pro numerator
                    ldd       <Y1,s             get Y1
                    subd      <Y2,s             sub Y2
                    std       $fee4             store Math Co-Pro denominator
                    ldd       $fef4             Get results from Div Co-Pro
                    std       <cnt,s            save
                    ldd       #0                d=0
                    std       <d,s              clear d
                    ldx       <X1,s             starting X
                    ldy       <Y1,s             starting Y
uloop@              lbsr      writepixel2
                    ldd       <d,s              load D
                    addd      #1                increment D
                    std       <d,s              store D
                    cmpd      <cnt,s
                    bne       incx@
                    leay      -1,y
                    ldd       #0
                    std       <d,s              d=0 reset counter
incx@               leax      1,x               increment X
                    cmpx      <X2,s             at end of line
                    bne       uloop@
                    lbra      exit@
cont@               lbsr       calcdxdy         Calculate dx, dy once
*                      Determine steepness
                    ldd       <dx,s             Calculate dx*2
                    lslb
                    rola
                    std       <dx2,s            dx2 = 2 * dx
                    ldd       <dy,s             Calculate dy*2  
                    lslb
                    rola
                    std       <dy2,s            dy2 = 2*dy  m_new
                    subd      <dx,s             slope_error_new
                    ;std       $fee4
                    std       <slperr,s         store slope error
                    ldx       <X1,s             starting X
                    ldy       <Y1,s             starting Y
loop@               lbsr      writepixel2
                    ldd       <slperr,s
                    addd      <dy2,s            m_new add slope to increment angle formed
                    std       <slperr,s
                    ;std       $fee2
                    bge       slopenew@
cont2@              leax      1,x               increment X
                    cmpx      <X2,s             check for end
                    beq       exit@
                    bra       loop@
slopenew@           leay      1,y               increment y
                    ;ldd       #0
                    ldd       <slperr,s
                    subd      <dx2,s
                    std       <slperr,s         update slope error
                    ;std       $fee0
                    bra       cont2@            
exit@               lbsr      writepixel2
                    puls      u,y,x,b,a         restore previous regs from stack
                    clrb                        math results in B causes strange error
                    leas      <stkdepth,s       eat temporary stack
                    rts                         return to the caller 
                    
absd                tsta
                    bge       end@
                    coma
                    comb
                    addd      #1
end@                rts

calcdxdy            ldd       <X2+2,s            x2
                    subd      <X1+2,s            x1
                    lbsr      absd
                    std       <dx+2,s            <dx,s   dx=x2-x1
                    ldd       <Y2+2,s            y2
                    subd      <Y1+2,s            y1
                    lbsr      absd
                    std       <dy+2,s            <dy,s   dy=y2-y1 
                    rts                    

linehori            ldx       <X1,s               Get start of X1
                    cmpx      <X2,s               compare with X2
                    blo       loop@
                    ldy       <X2,s               get X2 value
                    sty       <X1,s
                    stx       <X2,s               
                    exg       x,y            
loop@               ldy       <Y1,s               Get Y1
                    lbsr      writepixel2
                    leax      1,x                 increment X1
                    cmpx      <X2,s
                    bne       loop@
                    lbsr      writepixel2
                    puls      u,y,x,b,a           restore previous regs from stack
                    clrb                          math results in B causes strange error
                    leas      <stkdepth,s         eat temporary stack
                    rts                           return to the caller 

linevert            ldy       <Y1,s               Get Start of Y
                    cmpy      <Y2,s
                    blo       loop2@
                    ldx       <Y2,s
                    stx       <Y1,s
                    sty       <Y2,s
                    ldy       <Y1,s
loop2@              ldx       <X1,s               Get X
                    lbsr      writepixel2
                    leay      1,y
                    cmpy      <Y2,s
                    bne       loop2@
                    puls      u,y,x,b,a           restore previous regs from stack
                    clrb                          math results in B causes strange error
                    leas      <stkdepth,s         eat temporary stack
                    rts                           return to the caller 

;;; write pixel - Subroutine
;;; takes X,Y and color and puts it in the bitmap bmblock
;;; x=X
;;; y=Y
;;; BMBlock pulled from parameter 6
;;; Color pulled from parameter 5
;;; 
writepixel2         clr       <pxlblk0+4,s
                    clr       <pxlblk+4,s
                    clr       <pxlblkaddr+4,s
                    clr       <pxlblkaddr+5,s
                    clrb
                    ldd       [<$14,u]            get bmblock
                    stb       <$1F,u              store bmblock referenced to u
                    ldd       [<$10,u]            get lcolor
                    exg       a,b                 color to a
                    pshs      a,b,x,y,u
                    leas      -1,s                  add 1 byte to stack for carry
                    clr       ,s                    0=carry,1=color,2=y,3=X
*                   **** D = 320 * gy.
*                   **** 320 = 256 + 64, so use MUL for the lower byte,
*                   **** and then add gy (gy * 256) to the upper byte.
                    lda       6,s                   py     ; 8 bits.
                    ldb       #64
                    mul
                    adda      6,s                   py
                    ror       ,s                    <pcarry  ; Collect the carry bit.
*                   **** D += gx.
                    addd      3,s                   px     ; 16 bits.
                    ror       ,s                    <pcarry  ; Collect the carry bit.
*                   **** Stash the block ID bits.
                    pshs      a

*                   **** Move the lower 13 bits (8191) into a pointer.
                    anda      #31
                    tfr       d,x
*                   **** Restore the carry.
*                   **** This add will set/clear the carry
*                   **** based on the previously collected carry bits.
                    ldb       1,s                   carry bit 
                    addb      #192
*                   **** ror it into the top of the block bits.
                    puls      a
                    rora
*                   **** Shift the block bits to the bottom of A. 
                    lsra
                    lsra
                    lsra
                    lsra
*                   **** A now contains the relative block number,
*                   **** and X contains the block relative offset.xxxxxxxxw
                    pshs      x                   stx pixel offset
                    adda      <$1F,u              add bmblock start of bitmap to relative to get block#
;                   adda      #$36                bmblock
mapit@              sta       <pxlblk+6,s         store the new block we will map
                    ldx       <pxlblk0+6,s        load x with mapblock for F$MapBlk
                    ldb       #1                  map 1 block
                    pshs      u                   push u (F$MapBlk returns address in u)
                    os9       F$MapBlk            Map the block
                    lbcc      mapgood@            if successful, finish
                    puls      u,x                 error, clean up and return
                    bra       cleanup@            
mapgood@            stu       <pxlblkaddr+8,s     store the logical address
                    puls      u
storepixel@         ldd       <pxlblkaddr+6,s     
                    puls      x                   pull blk relative offset
                    leax      d,x                 add in logical start of block
                    lda       1,s                 lda with the color
                    sta       ,x                  write the pixel
cleanup@            leas      1,s                 pull carry byte off stack
                    pshs      b,u
                    ldu       <pxlblkaddr+6,s     
                    ldb       #1
                    os9       F$ClrBlk
                    puls      b,u 
                    puls      u,y,x,b,a           clean up stack 
                    rts



;;; BMLoad - Load Bitmap file into allocated Bitmap
;;;
;;; calling syntax: RUN FOENIX([path,],"BMLoad",bmblock,bitmappath)
BMLoad              cmpb      #3               3 parameters?
                    lbne      ParamErr         no, exit with Parameter Error
                    pshs      a,x,y,u          Preserve registers
                    lda       #READ.
                    leax      [<$04,u]         Pointer to bitmap path
                    os9       I$Open
                    lbcs      errcl
                    sta       <currPath,s      store current path
                    
                    ldd       [,u]             get first bitmap block
                    clra
                    std       <currBlk,s       store current block
                    sta       <blkCnt,s        store block cnt
loadimage           ldb       #1
                    ldx       <currBlk,s       restore current block
                    pshs      u                F$MapBlk with destroy U so push
                    os9       F$MapBlk
                    bcc       noerr@
                    puls      u                restore U from stack
                    lbra      errcl
noerr@              stu       <mapaddr+2,s     since U is pushed add 2 to variable ref.
                    puls      u                restore U from stack

                    lda       <currPath,s      load path
                    ldx       <mapaddr,s       map address in X
                    ldy       #$2000           location to load
                    os9       I$Read
                    bcc       noerr@
                    cmpb      #E$EOF
                    beq       loaddone         load done?
                    lbra      errcl
noerr@              inc       <blkCnt,s        increment blk cnt

                    pshs      u                F$ClrBlk will destroy U, so push it
                    ldu       <mapaddr+2,s     since U is pushed add 2 to variable ref.
                    ldb       #1
                    os9       F$ClrBlk
                    puls      u                restore U from stack
                    
                    lda       <blkCnt,s        load block cnt
                    cmpa      #$0A             is it the end?
                    beq       loaddone
                    inc       <currBlk+1,s     increment current block
                    bra       loadimage

loaddone            lda       <currPath,s      restore path
                    os9       I$Close
                    bcs       errcl

errcl               puls      u,y,x,a
                    leas      <stkdepth,s      eat temporary stack
                    rts                        return to the caller

;;; BMClear - Clear image of allocated Bitmap
;;;
;;; calling syntax: RUN FOENIX([path,],"BMClear",bmblock, color)
BMClear             cmpb      #3               3 parameters?
                    lbne      ParamErr         no, exit with Parameter Error
                    clr       <pxlblk0,s
                    clr       <pxlblk,s
                    clr       <pxlblkaddr,s
                    clr       <pxlblkaddr+1,s
                    clr       <bmblock,s
                    clr       <currBlk,s
                    clr       <blkCnt,s
                    pshs      a,x,y,u          Preserve registers
                    sta       <currPath,s      store current path
                    ldd       [,u]             get first bitmap block
                    clra                       clear block cnt
                    std       <currBlk,s       store current block
                    sta       <blkCnt,s        store block cnt
clearimage          ldb       #1
                    ldx       <currBlk,s       restore current block
                    pshs      u                F$MapBlk with destroy U so push
                    os9       F$MapBlk
                    bcc       noerr@
                    puls      u                restore U from stack
                    lbra      errcl2
noerr@              stu       <mapaddr+2,s     since U is pushed add 2 to variable ref.
                    puls      u                restore U from stack
                    lda       <currPath,s      load path
                    ldx       <mapaddr,s       map address in X
                    ldy       #$2000           number of bytes to clear
                    ldd       [<$04,u]         load color
                    exg       a,b
                    clrb
                    ;lda       #0               color to write black=0
pixelloop           sta       ,x+              write pixel             
                    leay      -1,y             decrement Y pointer
                    bne       pixelloop        done?
cont@               inc       <blkCnt,s        increment blk cnt
                    pshs      u                F$ClrBlk will destroy U, so push it
                    ldu       <mapaddr+2,s     since U is pushed add 2 to variable ref.
                    ldb       #1
                    os9       F$ClrBlk
                    puls      u                restore U from stack                   
                    lda       <blkCnt,s        load block cnt
                    cmpa      #$0A             is it the end?
                    beq       cleardone
                    inc       <currBlk+1,s     increment current block
                    bra       clearimage
cleardone           lda       <currPath,s      restore path
errcl2              puls      u,y,x,a
                    leas      <stkdepth,s      eat temporary stack
                    rts                        return to the caller

;;; BMSave - Save current Bitmap
;;;
;;; calling syntax: RUN FOENIX([path,],"BMClear",bmblock, filename)
BMSave              cmpb      #3               3 parameters?
                    lbne      ParamErr         no, exit with Parameter Error
                    clr       <pxlblk0,s
                    clr       <pxlblk,s
                    clr       <pxlblkaddr,s
                    clr       <pxlblkaddr+1,s
                    clr       <bmblock,s
                    clr       <currBlk,s
                    clr       <blkCnt,s
                    pshs      a,x,y,u          Preserve registers
                    sta       <currPath,s      store current path
                    leax      [<$04,u]         Get the filename to save
                    ldb       #$2F             03 0=R 2=W 2=E 3=PR 4=PW 5=PE
                    lda       #WRITE.          #$04             Access Mode Write
                    os9       I$Create         create and open file
                    bcs       merr             Error
                    sta       <Univ8a,s        save file path
                    ldd       [,u]             get first bmblock
                    clra
                    std       <currBlk,s       get current block
                    sta       <blkCnt,s        store block count
mapblock            ldb       #1               map 1 block
                    ldx       <currBlk,s       X with current address
                    pshs      u                F$MapBlk destroys U
                    os9       F$Mapblk         map in block
                    bcc       noerr@
                    puls      u                restore U
                    lbra      merr             error
noerr@              stu       <mapaddr+2,s    store map address
                    puls      u                get U off stack
                    lda       <Univ8a,s        get file path
                    ldx       <mapaddr,s       put map address in X
                    ldy       #$2000           8K Block - num bytes
                    os9       I$Write
                    bcc       nooerr@
                    lbra      merr             error
nooerr@             inc       <blkCnt,s        increment block count
                    pshs      u                F$Clrblk destroys U
                    ldu       <mapaddr+2,s     get mapaddr
                    ldb       #1               clear 1 block
                    os9       F$Clrblk         clear the block
                    puls      u                restore u
                    lda       <blkCnt,s        load block count
                    cmpa      #$0A             10th block?
                    beq       done@
                    inc       <currBlk+1,s
                    bra       mapblock
done@               lda       <Univ8a,s        get the file path
                    os9       I$Close
merr                lda       <currPath,s      get previous path
                    puls      u,x,y,a          restore stack
                    leas      <stkdepth,s      eat temporary stack
                    rts                        return to the caller
                    
                    

;;; Graphics On
;;;
;;; calling syntax: RUN FOENIX([path,],"Gon")
Gon                 ldx       #$2F   ;#%00001000+%00000100    Turn on Bitmaps and Graphics FX_BM = %00001000  FX_GRX = %00000100
                    *         FX_OVR = %00000010      Overlay Text on Graphics
                    *         FX_TXT = %00000001      Text Mode On
                    *         Sprite = %00100000      Sprite Enable
                    *         TileMap= %00010000      TileMap Enable
                    ldy       #%11111111       Don't change FFC1  FT_OMIT = %11111111
                    lda       ,s               Path # from stack
                    ldb       #SS.DScrn        Display Screen with new settings
                    os9       I$SetStt         Turn on Graphics
                    clrb                       no error
                    leas      <stkdepth,s      eat temporary stack
                    rts                        return to the caller             


;;; Graphics Off
;;;
;;; calling syntax: RUN FOENIX([path,],"Goff")
Goff                ldx       #%00000001       Turn Text on BM_TXT = %00000001
                    ldy       #%11111111       Don't change FFC1  FT_OMIT = %11111111
                    lda       ,s               Path # from stack 
                    ldb       #SS.DScrn        Display screen with new settings
                    os9       I$SetStt
                    bcs       error_ds         Error
                    clrb                       No Error
error_ds            leas      <stkdepth,s      eat temporary stack
                    rts                        return to the caller
                    
;;; BMoff - Bitmap Off/Free
;;; 
;;; calling syntax: RUN FOENIX([path,],"BMoff",bitmap#)
BMoff               cmpb      #1               1 parameters?
                    beq       par1@            1 param clear BM0
                    cmpb      #2
                    lbne      ParamErr         no, exit with Parameter Error
                    ldy       [,u]             Get BM# to free
                    bra       par2@
par1@               ldy       #0               BM 0-2
par2@               lda       #0
                    ldb       #SS.FScrn        Free Bitmap
                    os9       I$SetStt
error_BG            leas      <stkdepth,s      eat temporary stack
                    rts                        return to the caller

;;; BMStatus - Bitmap Status
;;;  Returns 0 bm(x) if disabled, returns 1 bm(x) enabled
;;; calling syntax: RUN FOENIX([path,],"BMstatus",bm0,bm1,bm2)
BMStatus            cmpb      #4               3 parameters?
                    lbne      ParamErr         no, exit with Parameter Error
                    pshs      u
                    ldu       <mapaddr,s       u is address of mapped block
                    ldb       #$01             clearing 1 block
                    os9       F$ClrBlk         remove block from DAT Image
                    ldx       #$C0             need to map in BM registers block
                    ldb       #$01
                    os9       F$MapBlk         Map in Bitmap registers
                    lbcs      exiterr
                    stu       <mapaddr,s
                    stu       <$20,u
                    puls      u
                    pshs      b
                    clrb                       
                    ldx       <mapaddr-1,s       Get new mapped block
                    leax      $1000,x          bitmap registers are $1000 offset
                    lda       ,x+              Get BM0 status
                    anda      #$1              only want bit 0
                    exg       a,b
                    std       [,u]             store bm0
                    clrb
                    leax      7,x              Get BM1 status
                    lda       ,x+
                    anda      #$1              only want bit 0
                    exg       a,b
                    std       [<$04,u]         store bm1
                    clrb
                    leax      7,x              Get BM2 status
                    lda       ,x+
                    anda      #$1              only want bit 0
                    exg       a,b
                    std       [<$08,u]         store bm2
                    puls      b
                    pshs      u                clear MapBlk from DAT Image
                    ldu       <mapaddr,s       u is address of mapped block
                    ldb       #$01             clearing 1 block
                    os9       F$ClrBlk         remove block from DAT Image
                    puls      u
exiterr             leas      <stkdepth,s      eat temporary stack
                    rts                        return to the caller
                    
;;; Clut Unlink
;;; 
;;; calling syntax: RUN FOENIX([path,],"ClutFree",clutheader)
ClutFree            cmpb      #1               1 parameters?
                    lbne      ParamErr         no, exit with Parameter Error
                    pshs      u
                    ;ldu       [,u]            Get CLUT filename to free
                    ldu       $feea            clut header address
                    os9       F$Unlink
                    puls      u
                    leas      <stkdepth,s      eat temporary stack
                    rts                        return to the caller



;;; Clutload - Load a CLUT in specified clut#
;;; 
;;; calling syntax: RUN FOENIX([path,],"ClutLoad",clut#,clutfile)
ClutLoad            cmpb      #3               3 parameters?
                    lbne      ParamErr         no, exit with Parameter Error
                    pshs      a,x,y,u          push registers
                    ldx       [,u]	         clut# store x because need it later
                    pshs      x                when u gets trashed
                    leax      [$04,u]          6th parameter Get CLUT path
                    lda       #0               F$Load a=language, 0=Any
                    os9       F$Link           Try linking module
                    beq       cont@            Load CLUT if no error
                    os9       F$Load           Load and set y=entry point
                    bcs       error_cl3@
cont@               puls      x                replaced following line with this one
*                   ldx       [,u]             CLUT # 1st parameter
                    lda       ,s               Path #
                    ldb       #SS.DfPal        Define Palette CLUT#0 with Y data
                    os9       I$SetStt
                    os9       F$Unlink         Clut defined now this saves 8K for Basic09         
                    bcs       error_ds3
                    ldu       5,s              F$Link,F$Load,F$Unlink all trash U
error_cl3@          puls      u,y,x,a
                    leas      <stkdepth,s      eat temporary stack
                    rts                        return to the caller

;;; Bitmap - Allocate Bitmap
;;; 
;;; calling syntax: RUN FOENIX([path,],"Bitmap",bitmap#,screenmode,bmblock,layer,clut#,clutname)
Bitmap              cmpb      #7               6 parameters?
                    lbne      ParamErr         no, exit with Parameter Error
                    ldy       [,u]             1st parameter bitmap #
                    ldx       [$04,u]          2nd parameter screentype 0=320x240 1=320x200
                    lda       ,s               Path # from stack
                    ldb       #SS.AScrn        Assign and create bitmap
                    os9       I$SetStt         
                    bcc       storeblk         No error store block #
                    cmpb      #E$WADef         Check if windows already defined
                    bne       error_ds2
storeblk            tfr       x,d              
                    std       [$08,u]          Save BMBlock to 3rd parameter                

Clut                pshs      a,x,y,u          push
                    ldx       [$10,u]	        store x because need it later
                    pshs      x                when u gets trashed
                    leax      [$14,u]          6th parameter Get CLUT path
                    lda       #0               F$Load a=language, 0=Any
                    os9       F$Link           Try linking module
                    beq       cont@            Load CLUT if no error
                    os9       F$Load           Load and set y=entry point
                    bcs       error_ds3
cont@               puls      x                replaced following line with this one
*                   ldx       [$10,u]          CLUT # 5th parameter
                    lda       ,s               Path #
                    ldb       #SS.DfPal        Define Palette CLUT#0 with Y data
                    os9       I$SetStt
                    os9       F$Unlink         Clut defined now this saves 8K for Basic09         
                    bcs       error_ds3
                    ldu       5,s              F$Link,F$Load,F$Unlink all trash U
                    **** Set CLUT0 to BM0
                    ldx       [$10,u]          CLUT # 5th param
                    ldy       [,u]             Bitmap # 1st param
                    lda       ,s               Path #
                    ldb       #SS.Palet        Assign CLUT # to Bitmap #
                    os9       I$SetStt
                    
                    **** Assign Bitmap to Layer
                    ldx       [$0C,u]        4th parameter Layer # 
                    ldy       [,u]           Bitmap #
                    lda       ,s              Path #
                    ldb       #SS.PScrn       Position Bitmap # to Layer #
                    os9       I$SetStt
error_ds3           puls      u,y,x,a
error_ds2           leas      <stkdepth,s     eat temporary stack
                    rts                       return to the caller
                    
                    
;;;  GFfee
;;;
;;;  Calling syntax: RUN FOENIX([path,],"GFree",bitmap#)             
GFree               cmpb      #2              2 parameters?
                    lbne      ParamErr        no, exit with Parameter Error
                    ldy       [,u]            1st parameter Bitmap #
                    lda       ,s              Path #
                    ldb       #SS.FScrn       Free Screen Ram
                    os9       I$SetStt
                    bcs       error_ds4
                    clrb
error_ds4           leas      <stkdepth,s     eat temporary stack
                    rts                       return to the caller
                                  
;; SS.Mouse
;;; Mouse - Return Mouse coordinates 320x240
;;; Returns the mouse information.
;;;
;;; Entry:  B  = SS.Mouse 
;;;
;;; Exit:   A = Button state.
;;;         X = Horizontal position (0 - 640).
;;;         Y = Vertical position (0 - 480).
;;;        CC = Carry flag clear to indicate success.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;; Mouse returns 320x240 XY
;;; calling syntax: RUN FOENIX([path,],"Mouse",X,Y,Button)
Mouse               cmpb      #4               3 parameters?
                    lbne      ParamErr         no, exit with Parameter Error
                    ldx       [,u]             X value 1st parameter
                    ldy       [<$04,u]         Y value 2nd parameter
                    ldd       [<$08,u]         Button 3rd parameter
                    ldb       #SS.Mouse
                    clra
                    os9       I$GetStt
                    exg       x,d              Move X data to D
                    lsra                       divide Y/2
                    rorb
                    exg       x,d              swap X data back into X
                    exg       y,d              move Y data to D
                    lsra                       divide Y/2
                    rorb
                    exg       y,d
                    stx       [,u]             return X value 1st parameter
                    sty       [<$04,u]         return Y value 2nd parameter
                    clrb
                    exg       a,b              LSB to A, byte button data to A
                    anda      #$03             Bit 0 = Left, Bit 1 = Right, Bit 2 = Middle button
                    std       [<$08,u]         Return Button 3rd parameter    
                    leas      <stkdepth,s      eat temporary stack
                    rts                        return to the caller

;;; MouseHR - returns 640x480 XY
;;; calling syntax: RUN FOENIX([path,],"MouseHR",X,Y,Button)
MouseHR             cmpb      #4               3 parameters?
                    lbne      ParamErr         no, exit with Parameter Error
                    ldx       [,u]             X value 1st parameter
                    ldy       [<$04,u]         Y value 2nd parameter
                    ldd       [<$08,u]         Button 3rd parameter
                    ldb       #SS.Mouse
                    clra
                    os9       I$GetStt
                    stx       [,u]             return X value 1st parameter
                    sty       [<$04,u]         return Y value 2nd parameter
                    clrb
                    exg       a,b              LSB to A, byte button data to A
                    anda      #$03             Bit 0 = Left, Bit 1 = Right, Bit 2 = Middle button
                    std       [<$08,u]         Return Button 3rd parameter    
                    leas      <stkdepth,s      eat temporary stack
                    rts                        return to the caller

;;; FNLoad - Load a font into specified font position
;;;
;;; fontnum = 0 or 1 - fontname specifies font in /dd/sys/fonts
;;; Calling syntax: RUN FOENIX([path,],"FNLoad",fontnum,fontname) 
FNLoad              cmpb      #3               3 parameters?
                    lbne      ParamErr         no, exit with Parameter Error
                    pshs      a,x,y,u
                    ldy       [,u]             get param 1 fontnum
                    ;exg       a,b
                    lda       #0
                    leax      [<$04,u]         get param 2 fontname to load
                    ldb       #SS.FntLoadF     load font from file
                    os9       I$SetStt
                    bcs       error@
                    clrb                   
error@              puls      a,x,y,u
                    leas      <stkdepth,s      eat temporary stack
                    rts 
                    
;;; FNChar - Load a font into specified font position
;;;
;;; fontnum = 0 or 1 - fontname specifies font in /dd/sys/fonts
;;; Calling syntax: RUN FOENIX([path,],"FNChar",fontset,fontnum,FONTCHAR) 
FNChar              cmpb      #4               3 parameters?
                    lbne      ParamErr         no, exit with Parameter Error
                    pshs      a,x,y,u
                    ldd       $A,u
                    ldd       [,u]             get param 1 fontnum
                    exg       a,b
                    clrb
                    ldy       [<$04,u]         get param 2 fontname to load
                    leax      [<$08,u]         get param 3 8 Bytes
                    ldb       #SS.FntChar      Set Font 
                    os9       I$SetStt
                    bcs       error@
                    clrb                   
error@              puls      a,x,y,u
                    leas      <stkdepth,s      eat temporary stack
                    rts


;;; MapBlk - Map in Page
;;;
;;; Calling syntax: RUN FOENIX([path,],"MapBlk",Page,addr)
MapBlk              cmpb      #3               3 parameters?
                    lbne      ParamErr         no, exit with Parameter Error
                    ldx       [,u]             get page to map ex. $C1 $C2
                    pshs      u                preserve u
                    ldb       #$01             need 1 block
                    os9       F$MapBlk         map it into process address space
                    lbcs      exiterr4
                    exg       u,x              mapped block to x  
                    puls      u
                    stx       [<$04,u]         store mapaddr param 2
                    bra       cont@
exiterr4            puls      u                restore u
cont@               leas      <stkdepth,s      eat temporary stack
                    rts

;;; ClrBlk - Clear Mapped in Page
;;;
;;; Calling syntax: RUN FOENIX([path,],"ClrBlk",Page,addr)
ClrBlk              cmpb      #3               2 parameters?
                    lbne      ParamErr         no, exit with Parameter Error
                    ldx       [<$04,u]         load map addr in x
                    ;ldy       #$C1
                    ldy       [,u]             get page to map
                    pshs      u                clear MapBlk from DAT Image
                    exg       x,u              put mapaddr in u
                    exg       y,x              page to clear in x
                    ;ldu       <MAPADDR         u is address of mapped block
                    ldb       #$01             clearing 1 block
                    os9       F$ClrBlk         remove block from DAT Image
                    puls      u
                    clrb
                    leas      <stkdepth,s      eat temporary stack
                    rts

;;;
;;;
;;; Calling syntax: RUN FOENIX([path,],"Real",realval) 
Real                cmpb      #2               2 parameters?
                    lbne      ParamErr         no, exit with Parameter Error
                    leax      [,u]            get first parameter
                    lda       ,x+
                    sta       $FEE0
                    lda       ,x+
                    sta       $FEE1
                    lda       ,x+
                    sta       $FEE2
                    lda       ,x+
                    sta       $FEE3
                    lda       ,x
                    sta       $FEE4
                    leas      <stkdepth,s      eat temporary stack
                    rts                        return to the caller
                    
;;; Multiply - Multiply 2 16 bit integers
;;;
;;; Calling syntax: RUN FOENIX([path,],"MULTIPLY", integer_A, integer_B,result_REAL)
Mult                cmpb      #4              3 parameters?
                    lbne      ParamErr        no, exit with Parameter Error
                    lda       3,u             get the length of the 1st parameter
                    cmpa      #2              is it an integer?
                    lbne      ParamErr        no, return an error
                    lda       7,u             get the length of the 2nd parameter
                    cmpa      #2              is it an integer?
                    lbne      ParamErr        no, return an error
                    ldb       #11
                    lda       b,u             get the length of the 3rd parameter
                    cmpa      #5              is it a real?
                    lbne      ParamErr        no, return an error
                    ldd       [,u]            get first parameter
                    std       $FEE0           store 16 word in math coprocessor word A
                    ldd       [<$04,u]        get second parameter
                    std       $FEE2
                    ldd       $FEF0           get least significant result word
                    std       [,u]            save to caller 1st parameter
                    ldd       $FEF2           get most significant result word
                    std       [<$04,u]        save to caller 2nd parameter
                    ldd       [<$08,u]        get first 2 bytes of REAL
                    stb       $FEE0
                    sta       $FEE1       
                    clrb                      no error
                    leas      <stkdepth,s     eat temporary stack
                    rts                       return to the caller

;;; GetDow - Get Day of week
;;; Returns integer day of week
;;; Calling syntax: RUN FOENIX([path,] "GetDow", dow)
GetDow              cmpb      #2              2 parameters?
                    lbne      ParamErr        no, exit with Parameter Error
                    lda       $FE4E           get RTC control
                    ora       $08             RTC_UTI
                    sta       $FE4E           disable RTC updates
                    clra
                    ldb       $FE48           RTC_DOW - Get day of week
                    lbsr      bcdtoint        bcd to integer
                    std       [,u]            return dow value
                    lda       $FE4E           get RTC control
                    anda      $F7             RTC_UTI
                    sta       $FE4E           enable RTC updates
                    clrb                      no error
                    leas      <stkdepth,s     eat temporary stack
                    rts                       return to the caller
                    
                    
;;; GetTime - Get the current time.
;;;
;;; Calling syntax: RUN FOENIX([path,] "GetTime", hour,minute,seconds)
GetTime             cmpb      #4              4 parameters?
                    lbne      ParamErr        no, exit with Parameter Error
                    lda       $FE4E           get RTC control
                    ora       $08             RTC_UTI
                    sta       $FE4E           disable RTC updates
                    clrb
                    ldb       $FE44           read hours
                    ;andb      $7F             mask off am/pm in 12 hour mode
                    lbsr      bcdtoint
                    std       [,u]            save first parameter hours
                    ldb       $FE42           read minutes
                    lbsr      bcdtoint
                    std       [<$04,u]        save 2nd parameter minutes
                    ldb       $fE40
                    lbsr      bcdtoint
                    std       [<$08,u]        save 3rd parameter seconds
                    lda       $FE4E           get RTC control
                    anda      $F7             RTC_UTI
                    sta       $FE4E           enable RTC updates
                    clrb
                    leas      <stkdepth,s     eat temporary stack
                    rts                       return to the caller

;;; GetTime - Get the current time.
;;;
;;; RTC.Base $FE40
;;; Calling syntax: RUN FOENIX([path,] "GetDate", month,day,year)
GetDate             cmpb      #4              4 parameters?
                    lbne      ParamErr        no, exit with Parameter Error
                    clrb
                    lda       $FE4E           get RTC control
                    ora       $08             RTC_UTI
                    sta       $FE4E           disable RTC updates
                    ldb       $FE49           RTC_MONTH read month
                    lbsr      bcdtoint
                    std       [,u]            save first parameter month
                    ldb       $FE46           RTC_DAY read day
                    lbsr      bcdtoint
                    std       [<$04,u]        save 2nd parameter days
                    ldb       $fE4A           RTC_YEAR read year
                    lbsr      bcdtoint
                    stb       Univ8d,s        store value year
                    ;ldb       $FE4F           RTC_CENTURY get century
                    ldb       #$20            RTC_CENTURY invaled value returned
                    lbsr      bcdtocentury
                    ldd       <univ8a-2,s     restore calculated century -2 subroutine call
                    addb      Univ8d,s        add lsb years
                    std       [<$08,u]        save 3rd parameter year
                    lda       $FE4E           get RTC control
                    anda      $F7             RTC_UTI
                    sta       $FE4E           enable RTC updates
                    clrb
                    leas      <stkdepth,s     eat temporary stack
                    rts                       return to the caller

; Entry B register contains BCD byte
; Return D Integer value                    
bcdtoint            tfr       b,a             put a copy of b in a
                    andb      #$0F            mask off top 4 bits
                    stb       <pxlBlk,s       save a on stack 8 bit
                    anda      #$F0            mask off lower 4 bits
                    lsra
                    lsra
                    lsra
                    lsra                      move upper 4 bits to lower 4 bits
                    tfr       a,b
                    ldb       #10
                    mul
                    addb     <pxlBlk,s
                    rts

; Entry B register contains BCD byte
; Return D Integer value
bcdtocentury        tfr       b,a             put a copy of b in a
                    clr       <univ8a,s
                    clr       <univ8b,s
                    clr       <univ8c,s
                    sta       <bmblock,s
                    andb      #$0F            mask off top 4 bits
                    tfr       b,a
                    ldb       #100            multiple by 100
                    mul
                    sta       <pxlBlk,s       save B on stack 8 bit
                    
                    lda       <bmblock,s      reload original value
                    anda      #$F0            mask off lower 4 bits
                    lsra
                    lsra
                    lsra
                    lsra                      move upper 4 bits to lower 4 bits
                    sta       <pxlblk0,s      save muliplier
                    ;tfr       a,b
                    ldb       #$03            multiply 16 by 8 bit ($03E8=1000)
                    mul
                    std       <univ8a,s       store 2 bytes
                    ldb       <pxlblk0,s      restore msn bcd
                    lda       #$E8            16 bit multiply by 1000
                    mul
                    addd      <univ8b,s       ls byte
                    pshs      cc              preserve carry
                    std       <univ8b,s
                    lda       <univ8a,s
                    puls      cc
                    adca      #0              add in carry
                    ;sta       <univ8a,s
                    ldd       <univ8a,s
                    addb      <pxlBlk,s
                    std       <univ8a,s
                    rts


;;; Peekw - peek word.
;;;
;;; Return 16 bit value at specified address. Valid values -32768 - +32767
;;; Calling syntax: RUN FOENIX([path,] "Peekw", address,return_value)
Peekw               cmpb      #3              3 parameters?
                    lbne      ParamErr        no, exit with Parameter Error
                    ldx       [,u]            get address to peek
                    ldd       ,x++            read 2 bytes
                    std       [$04,u]
                    clrb                      no error
                    leas      <stkdepth,s     eat temporary stack
                    rts                       return to the caller
 
                    
;;; Pokew - poke word.
;;;
;;; Store 16 bit value at specified address. Valid values -32768 - +32767
;;; Calling syntax: RUN FOENIX([path,] "Pokew", address,value)
Pokew               cmpb      #3              3 parameters?
                    lbne      ParamErr        no, exit with Parameter Error
                    ldx       [,u]            get address to peek
                    ldd       [$04,u]         get value to store
                    std       ,x++            store 2 bytes at addr x
                    ;sta       ,x+             MSB $1FF4
                    ;stb       ,x+             LSB $1FF5           
                    clrb                      no error
                    leas      <stkdepth,s     eat temporary stack
                    rts                       return to the caller


;;; ID - Get the calling process' user ID
;;;
;;; Calling syntax: RUN FOENIX([path,] "ID", id)
ID                  os9       F$ID      get process ID # into D
                    tfr       a,b       put process ID in B
                    clra                and clear A (D = process ID)
                    std       [,u]      save it in caller's parameter 1 variable
L0305               clrb                no error
                    leas      <stkdepth,s eat temporary stack
                    rts                 return to the caller

;;; TONE - Generate a sound.
;;;
;;; Calling syntax: RUN FOENIX([path,] "TONE", frequency, duration, volume)
Tone                cmpb      #4        4 parameters?
                    lbne      ParamErr  no, exit with Parameter Error
                    ldy       [,u]      get frequency (0-1023)
                    ldd       [<$04,u]  get duration (1/60th second count) 0-255
                    pshs      b         save it (only 8 bit)
                    ldd       [<$08,u]  get volume (amplitude) (0-15)
                    tfr       b,a       move to high byte
                    puls      b         get duration back
                    tfr       d,x       X is now set up for SS.Tone
                    lda       ,s        get path
                    ldb       #SS.Tone  load tone code
                    os9       I$SetStt  perform the command
L043B               leas      <stkdepth,s eat temporary stack
                    rts                 return to the caller

;;; WINFO - Get window information.
;;;
;;; Calling syntax: RUN FOENIX([path,] "WINFO", format, width, height, foreground, background, border)
WInfo               cmpb      #7        7 parameters?
                    lbne      ParamErr  no, exit with parameter error
                    lda       ,s        get path
                    ldb       #SS.ScTyp get screen type system call
                    os9       I$GetStt
                    bcs       L0479     error, eat temp stack & exit
                    tfr       a,b       D=screen type
                    clra
                    std       [,u]      save to caller
                    lda       ,s        get path again
                    ldb       #SS.ScSiz load screen size code
                    os9       I$GetStt  perform the command
                    bcs       L0479     error, eat temporary stack & exit
                    stx       [<$04,u]  save # of columns in current working area
                    sty       [<$08,u]  save # of rows in current working area
                    ldb       #SS.FBRgs load foreground/background/border color call
                    os9       I$GetStt  perform the command
                    bcs       L0479     error, eat temporary stack & exit
                    pshs      a         save foreground color on stack
                    clra                D=background color
                    std       [<$10,u]  save to caller
                    puls      b         D=foreground color
                    std       [<$0C,u]  save to caller
                    stx       [<$14,u]  save border color to caller
L0478               clrb                no error
L0479               leas      <stkdepth,s eat temporary stack
                    rts                 return to the caller

;;; DWSET - Define a device window.
;;;
;;; Calling syntax: RUN FOENIX([path,] "DWSET", format, xcor, ycor, width, height, foreground, background, border)
DWSet               lda       #$20      load device window set code
                    pshs      x,d       save output string memory pointer, # of parameters & display code
                    ldx       2,u       get size of 1st parameter (to see if optional path #)
                    cmpx      #2        INTEGER?
                    bne       L04C0     no, skip ahead
                    ldd       [,u]      yes, get INTEGER value
                    bra       L04C2

L04C0               lda       [,u]      get BYTE value from parameter 1
L04C2               puls      x,d       restore output memory string pointer, # of parameters & display code (leaves CC alone)
                    ble       L04EF
                    cmpb      #9        9 parameters?
                    bne       L0528     no, skip ahead
                    sta       ,x+       save code to output stream
                    lbra      L0920     append next 8 parameters to output stream (either byte or integer) & write it out

L04E4               cmpb      #1        1 parameter?
                    bne       L0528     no, exit with parameter error
L04E8               sta       ,x+       append command code, and write output buffer out
                    lbra      L0901

L04EF               cmpb      #8        8 parameters?
                    bne       L0528     no, exit with parameter error
                    sta       ,x+       append OWSet code to output buffer
                    lbra      L0922     append the next 7 parameters (BYTE or INTEGER) to the output buffer & write it out

L0526               cmpb      #3        3 parameters?
L0528               lbne      ParamErr  no, exit with parameter error
                    sta       ,x+       yes, append code
                    lbra      L092C     append 2 BYTE/INTEGER parameters

L0579               ldx       ,u        get parameter pointer for string caller sent
                    lbsr      L0892     go find match, and get code to send for that string
                    puls      y,x       restore registers
                    bcs       L0528     no match found in table, exit with parameter error
                    lbra      L04E8     append code & write out

* Palette
Palette             lda       #$31      palette code
                    bra       L0526     append 3 parameters or exit with parameter error

;;; COLOR - Set the window colors.
;;;
;;; Calling syntax: RUN FOENIX([path,] "COLOR", foreground [,background] [,border])
Color               cmpb      #2        2 parameters? (foreground only, no path)
                    beq       color2@   yes, do that
                    cmpb      #3        3 parameters? (foreground/background only)?
                    beq       color3@   yes, do that
                    cmpb      #4        4 parameters? (foreground/background/border)?
                    bne       L0528     no, exit with parameter error
                    bra       color4@   yes, send all 3 color setting sequences out
* Build FColor sequence & write it out
color2@             bsr       L05B6     build foreground color sequence
                    bra       L05B3     write it out
*  Build FColor and BColor command sequences & write them out
color3@             bsr       L05B6     build foreground color sequence first
                    ldb       #$1B      add ESC code
                    stb       ,x+
                    bsr       L05BA     build background color sequence
                    bra       L05B3     write it out
* Build FColor, BColor, Border
color4@             bsr       L05B6     append foreground color sequence
                    ldb       #$1B      add ESC to output buffer
                    stb       ,x+
                    bsr       L05BA     append background color sequence
                    ldb       #$1B      add ESC to output buffer
                    stb       ,x+
                    bsr       L05CA     append border color sequence
L05B3               lbra      L0901     write output buffer

L05B6               lda       #$32      append foreground color code
                    bra       L05BC     and BYTE/INTEGER parameter from caller

* Build BColor
L05BA               lda       #$33      append background color code
L05BC               sta       ,x+
                    lbra      L0932     append background color (BYTE/INTEGER) from caller

L05CA               lda       #$34      append border color
                    bra       L05BC

* Entry: U=pointer to current parameter pointer
*        X=pointer to current position in output buffer
* Do SetDPtr (Set Draw Pointer) to x,y coord specified by next two parameters
L05F7               pshs      a         save A (original display code)
                    lda       #$40      append display code for SetDPPtr
                    sta       ,x+
                    lbsr      L08CE     append X coord
                    lbsr      L08CE     append Y coord
                    puls      pc,a      restore original display code & return

;;; SEED - Seeds the hardware-based random number.
;;;
;;; Calling syntax: RUN FOENIX([path,] "SEED" ,value)
Seed
                    lda       3,u       get the length of the 1st parameter
                    cmpa      #2        is it an integer?
                    lbne      ParamErr  no, return an error
                    ldx       #$FE00    load the base address
                    lda       #1        load the start flag
                    sta       6,x       enable the random number generator
                    ldd       [,u]      get seed from the caller
                    exg       a,b       swap bytes
                    std       4,x       store in hardware
                    clrb                no error, eat temp stack & return
                    leas      <stkdepth,s
                    rts                 return to the caller

;;; RANDOM - Returns a hardware-based random number.
;;;
;;; Calling syntax: RUN FOENIX([path,] "RANDOM" ,value)
Random
                    lda       3,u       get the length of the 1st parameter
                    cmpa      #2        is it an integer?
                    lbne      ParamErr  no, return an error
                    ldx       #$FE00    load the base address
                    lda       #1        load the start flag
                    sta       6,x       enable the random number generator
                    ldd       4,x       get bits 7-0 in A, 15-8 in B
                    exg       a,b       swap 'em
                    std       [,u]      save in caller's parameter 1 variable
                    clrb                no error, eat temp stack & return
                    leas      <stkdepth,s
                    rts                 return to the caller
L060F               cmpb      #3        3 parameters?
                    beq       L061D     yes, process (just end point)
                    cmpb      #5        5 parameters?
                    bne       L062E     no, exit with parameter error
                    bsr       L05F7     yes, do SetDPtr (Set Draw Pointer) first and then draw line
                    ldb       #$1B      ESC code
                    stb       ,x+       append to output buffer
L061D               sta       ,x+       save code in output buffer
                    lbra      L08FD     append two 16 bit parameters from caller (X endpoint, Y endpoint)

L062E               lbne      ParamErr  no, exit with parameter error
                    bra       L061D     yes, add X,Y coords from caller & write out

;;; CURHOME - Home the cursor.
;;;
;;; Calling syntax: RUN FOENIX([path,] "CURHOME")
CurHome             lda       #$01      home cursor code
                    bra       L0859     overwrite default ESC code in output buffer with new code, write it out

;;; CURXY - Move the cursor to a column and row.
;;;
;;; Calling syntax: RUN FOENIX([path,] "CURXY", column, row)
CurXY               lda       #$02      CurXY code
                    cmpb      #3        3 parameters?
L0804               lbne      ParamErr  no, exit with parameter error
                    sta       -1,x      yes, overwrite original ESC code in output buffer
                    bsr       L0811     append X coord from caller (with $20 offset)
                    bsr       L0811     append Y coord from caller (with $20 offset)
                    lbra      L0901     write output buffer

* Process text coord from caller. Handles BYTE or INTEGER, and adds +$20 offset needed for CurXY
L0811               pshs      y,d       save registers
                    ldd       [,u++]    get coord from caller (INTEGER)
                    adda      #$20      offset for CurXY
                    sta       ,x+       save in output buffer
                    pulu      y         get size of coord variable from caller
                    leay      -1,y      BYTE type?
                    beq       L0829     yes, we are done, restore registers & exit
                    leay      -1,y      INTEGER type?
                    lbne      L091B     no, eat temp stack, return with parameter error
                    addb      #$20      replace coord in output buffer with LSB of INTEGER parameter
                    stb       -1,x
L0829               puls      pc,y,d    return to the caller

;;; ERLINE - Delete the line of text the cursor is on.
;;;
;;; Calling syntax: RUN FOENIX([path,] "ERLINE")
ErLine              lda       #$03      erase line code
                    bra       L0859     overwrite default ESC code in output buffer with new code, write it out

;;; EREOLINE - Delete text from the cursor to the end of the current line.
;;;
;;; Calling syntax: RUN FOENIX([path,] "EREOLINE")
ErEOLine            lda       #$04      erase to end of Line code
                    bra       L0859     overwrite default ESC code in output buffer with new code, write it out

;;; CUROFF - Make the cursor invisible
;;;
;;; Calling syntax: RUN FOENIX([path,] "CUROFF")
CurOff              lda       #5        cursor on/off code
                    sta       -1,x      save over original ESC
                    lda       #$20      off value
                    bra       L087B     append to output buffer, write it out

;;; CURON - Make the cursor visible
;;;
;;; Calling syntax: RUN FOENIX([path,] "CURON")
CurOn               lda       #5        cursor on/off code
                    sta       -1,x      save over original ESC
                    lda       #$21      on value
                    bra       L087B     append to output buffer, write it out

;;; CURRGT - Move the cursor one character to the right.
;;;
;;; Calling syntax: RUN FOENIX([path,] "CURRGT")
CurRgt              lda       #6        cursor Right code
                    bra       L0859     overwrite default ESC code in output buffer with new code, write it out

;;; BELL - Produce a beep through the terminal's speaker.
;;;
;;; Calling syntax: RUN FOENIX([path,] "BELL")
Bell                lda       #7        bell code
                    bra       L0859     overwrite default ESC code in output buffer with new code, write it out

;;; CURLFT - Move the cursor one character to the left.
;;;
;;; Calling syntax: RUN FOENIX([path,] "CURLFT")
CurLft              lda       #8        cursor Left code
                    bra       L0859     overwrite default ESC code in output buffer with new code, write it out

;;; CURUP - Move the cursor one line up.
;;;
;;; Calling syntax: RUN FOENIX([path,] "CURUP")
CurUp               lda       #9        cursor Right code
                    bra       L0859     overwrite default ESC code in output buffer with new code, write it out

;;; CURDWN - Move the cursor one line down.
;;;
;;; Calling syntax: RUN FOENIX([path,] "CURDWN")
CurDwn              lda       #$A       cursor Down code
                    bra       L0859     overwrite default ESC code in output buffer with new code, write it out

;;; EREOWNDW - Delete text from the current cursor position to the end of the window.
;;;
;;; Calling syntax: RUN FOENIX([path,] "EREOWNDW")
ErEOWndw            lda       #$B       erase to end of Window code
L0859               leax      -1,x      bump back output buffer pointer
                    bra       L087B     overwrite default ESC code in output buffer with new code, write it out

;;; Clear - Clear the screen.
;;;
;;; Calling syntax: RUN FOENIX([path,] "CLEAR")
Clear               lda       #$C       clear window code
                    bra       L0859     overwrite default ESC code in output buffer with new code, write it out

;;; Display - Similar to Display without need call shell.
;;;
;;; Calling syntax: RUN FOENIX([path,] "Display",bytes)
Display             cmpb      #2        2 parameters?
                    lbne      ParamErr  no, exit with parameter error
                    ldb       3,u       Get length of bytes
                    leay      [,u]      get bytes
                    ;lda       #$32
                    ;sta       -1,x
loop@               lda       ,y+
                    sta       ,x+
                    decb
                    bne       loop@
                    lbra      L0901     write output buffer

;;; CRRTN - Send a carriage return.
;;;
;;; Calling syntax: RUN FOENIX([path,] "CRRTN")
CrRtn               lda       #C$CR     carriage return code
                    bra       L0859     overwrite default ESC code in output buffer with new code, write it out

L0873               pshs      a         save sub-code
                    lda       #$1F      put $1F code overtop original ESC first
                    sta       -1,x
                    puls      a         get sub-code back
L087B               lbra      L04E4     append to output buffer & write out

;;; INSLIN - Insert a blank line at the current cursor.
;;;
;;; Calling syntax: RUN FOENIX([path,] "INSLIN")
InsLin              lda       #$30      insert Line sub-code for $1F code
                    bra       L0873     append both to output buffer & write out

;;; DELLIN - Delete the line at the current cursor.
;;;
;;; Calling syntax: RUN FOENIX([path,] "DELLIN")
DelLin              lda       #$31      delete Line sub-code for $1FG code
                    bra       L0873     append both to output buffer & write out

;;; DEFCOL - Set palette registers to the default values.
;;;
;;; Calling syntax: RUN FOENIX([path,] "DEFCOL")
L088E               lda       #$30      default color code
                    bra       L087B     append to output buffer & write out

* Compare string from caller to string in table (used for ON, OFF, etc) case insensitive
* Entry: X=pointer to string from caller
*        Y=pointer in table for strings we are checking against
* Exit: Carry clear, A=code to send that corresponds to table string entry
*       or carry set if no match in table
L0892               pshs      x         save pointer to start of string from caller
L0894               lda       ,y+       get character from table
                    beq       L08BF     NUL (end of table), exit with error
L0898               eora      ,x+       force case
                    anda      #$DF
                    bne       L08AE     different, skip to next entry
                    tst       ,y        hi bit ($FF cheat) set on matching character from table (ie end of name?)
                    bmi       L08AA     yes, check if end of caller's string
                    tst       ,x        no, was hi bit ($FF cheat) set on character from caller?
                    bmi       L08AE     yes, skip to next entry
                    lda       ,y+       no, matches so far, check next character
                    bra       L0898

L08AA               tst       ,x        end of table string, is it end of caller string too?
                    bmi       L08BA     yes, found match, skip ahead
L08AE               leay      -1,y      no, bump table pointer back 1
L08B0               tst       ,y+       skip to end of table string
                    bpl       L08B0
                    ldx       ,s        get pointer to start of string from caller again
                    leay      1,y       bump table pointer to next entry
                    bra       L0894

L08BA               clra                clear carry
                    lda       1,y       get table byte entry
                    bra       L08C0

L08BF               coma                no match found, exit with carry set
L08C0               puls      pc,x      return to the caller

* Append BYTE or INTEGER value from caller as 16 bit value to output buffer
AppendParam         pshs      y,d       save registers
                    bsr       L08E8     append value from caller (unsigned, 16 bit value from callers 8 or 16 bit)
                    beq       L08E6     if 8 bit value was expanded to 16 bit, we are done, return
                    leay      -1,y      2 byte value (INTEGER) from caller?
                    bne       L091B     not BYTE or INTEGER, exit with parameter error
                    bra       L08E4     if INTEGER, append to output buffer and return

* Append BYTE or INTEGER value from caller as 16 bit value to output buffer (and eat 9 byte temp stack)
L08CE               pshs      y,d       save registers
                    bsr       L08E8     append value from caller (unsigned, 16 bit value from callers 8 or 16 bit)
                    beq       L08E6     if 8 bit value was expanded to 16 bit, we are done, return
                    leay      -1,y      2 byte value (INTEGER) from caller?
                    bne       L0919     not BYTE or INTEGER, exit with parameter error (& eat 9 byte temp stack)
                    bra       L08E4     if INTEGER, append to output buffer & return

* Append BYTE or INTEGER value from caller as 16 bit value to output buffer (and eat 15 byte temp stack)
L08DA               pshs      y,d       save registers
                    bsr       L08E8     append value from caller (unsigned, 16 bit value from callers 8 or 16 bit)
                    beq       L08E6     if 8 bit value was expanded to 16 bit, we are done, return
                    leay      -1,y      2 byte value (INTEGER) from caller?
                    bne       L0917     not BYTE or INTEGER, exit with parameter error (& eat 15 byte temp stack)
L08E4               std       ,x++      append value to output buffer
L08E6               puls      pc,y,d    return to the caller

* Append 16 bit value from caller to output buffer. Original from caller is unsigned, can be BYTE or INTEGER
L08E8               ldd       [,u++]    get 16 bit value from caller (INTEGER)
                    pulu      y         get size of variable form caller
                    leay      -1,y      INTEGER?
                    bne       L08F4     yes, return
                    sta       1,x       no, BYTE, save BYTE as 16 bit value (note: NOT SIGNED)
                    clr       ,x++
L08F4               rts                 return to the caller

L08F5               bsr       AppendParam append 16 bit value to output buffer (6 16 bit parameters)
                    bsr       AppendParam append 16 bit value to output buffer
L08F9               bsr       AppendParam append 16 bit value to output buffer (4 16 bit parameters)
L08FB               bsr       AppendParam append 16 bit value to output buffer (3 16 bit parameters)
L08FD               bsr       AppendParam append 16 bit value to output buffer (2 16 bit parameters)
L08FF               bsr       AppendParam append 16 bit value to output buffer (1 16 bit parameter)
L0901               bsr       L0907     write output buffer out
                    leas      <stkdepth,s eat main temp stack & return
                    rts                 return to the caller

* Write output buffer out
                  IFNE    H6309
L0907               leay      ,x        4 Y=end buffer ptr
                    leax      3,s       5 Point to start of buffer to write out
                    subr      x,y       4 Calc size of write
                  ELSE
L0907               tfr       x,d       4 Move buffer end ptr to write out to D
                    leax      3,s       5 Point to buffer to write out
                    pshs      x         6 Save start of buffer
                    subd      ,s++      7 End buffer ptr-Start buffer ptr=length
                    tfr       d,y       4 Move length to Y for Write
                  ENDC
                    lda       2,s       Get path, write out buffer
                    os9       I$Write
                    rts                 return to the caller

L0917               leas      6,s       eat extra temp stack (15 bytes)
L0919               leas      3,s       eat extra temp stack (9 bytes)
L091B               leas      6,s       eat extra temp stack  (6 bytes)
                    lbra      ParamErr  exit with parameter error

L0920               bsr       L0932     append BYTE or INTEGER parameter to output stream (append 8 parameters)
L0922               bsr       L0932     append BYTE or INTEGER parameter to output stream (append 7 parameters)
                    bsr       L0932     append BYTE or INTEGER parameter to output stream (append 6 parameters)
                    bsr       L0932     append BYTE or INTEGER parameter to output stream (append 5 parameters)
L0928               bsr       L0932     append BYTE or INTEGER parameter to output stream (append 4 parameters)
                    bsr       L0932     append BYTE or INTEGER parameter to output stream (append 3 parameters)
L092C               bsr       L0932     append BYTE or INTEGER parameter to output stream (append 2 parameters)
                    bsr       L0932     append BYTE or INTEGER parameter to output stream (append 1 parameter)
                    bra       L0901     write the output buffer out

* Append next parameter value to output stream (either INTEGER or BYTE)
* Entry: U=pointer to current parameter pointer and size
*        X=pointer to current position in output buffer
L0932               pshs      y,d       save registers
                    ldd       [,u++]    get next parameter value (BYTE)
                    sta       ,x+       append to output stream
                    pulu      y         Y=parameter size & bump U to next parameter
                    leay      -1,y
                    beq       L0944     if it was a BYTE, we are done
                    leay      -1,y
                    bne       L091B     not an INTEGER either, return with parameter error
                    stb       -1,x      save LSB overtop original one (which would have been 0 to get here)
L0944               puls      pc,y,d    return to the caller



                    emod
eom                 equ       *
                    end

