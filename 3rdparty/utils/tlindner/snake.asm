********************************************************************
* Snake - Animate slithering snake in window
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2014/10/08  tim lindner
* Started writing code.

                    nam       Snake
                    ttl       Animate slithering snake in window

                    ifp1
                    use       defsfile
                    endc

* Here are some tweakable options
DOHELP              set       1                   1 = include help info
STACKSZ             set       32                  estimated stack size in bytes
PARMSZ              set       256                 estimated parameter size in bytes

* Module header definitions
tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    org       0
bail_flag           rmb       1
windowx             rmb       1
windowy             rmb       1
time                rmb       3
RND                 rmb       3
snakesize           rmb       1
head                rmb       1
IOBUF               rmb       4
IOBUF2              rmb       4
cleartop            equ       .                   everything up to here gets cleared at start
* Finally the stack for any PSHS/PULS/BSR/LBSRs that we might do
snakebuffer         rmb       80*2
                    rmb       STACKSZ+PARMSZ
size                equ       .

* The utility name and edition goes here
name                fcs       /Snake/
                    fcb       edition

* Place constant strings here
                    ifne      DOHELP
HlpMsg              fcb       C$LF
                    fcc       /Use: Snake <size>/
                    fcb       C$LF
                    fcb       C$CR
                    fcc       /  Size is less than window width./
                    fcb       C$LF
                    fcb       C$CR
HlpMsgL             equ       *-HlpMsg
                    endc
*
* Here's how registers are set when this process is forked:
*
*   +-----------------+  <--  Y          (highest address)
*   !   Parameter     !
*   !     Area        !
*   +-----------------+  <-- X, SP
*   !   Data Area     !
*   +-----------------+
*   !   Direct Page   !
*   +-----------------+  <-- U, DP       (lowest address)
*
*   D = parameter area size
*  PC = module entry point abs. address
*  CC = F=0, I=0, others undefined

* This routine skip over spaces and commas
*
* Entry:
*   X = ptr to data to parse
* Exit:
*   X = ptr to first non-whitespace char
*   A = non-whitespace char
SkipSpcs            lda       ,x+
                    cmpa      #C$SPAC
                    beq       SkipSpcs
                    leax      -1,x
                    rts

* The start of the program is here.
* Before any command line processing is done, we clear out
* our static memory from U to cleartop, then determine the
* size of our data area (minus the stack).
start               pshs      u,x                 save registers for later
                    leax      <cleartop,u         point to end of area to zero out
                    ifne      H6309
                    subr      u,x                 subtract U from X
                    tfr       x,w                 and put X in W
                    clr       ,-s                 put a zero on the stack
                    tfm       s,u+                and use TFM to clear starting at U
                    leas      1,s                 clean up the stack
                    else
                    pshs      x                   save end pointer on stack
clrnxt              clr       ,u+                 clear out
                    cmpu      ,s                  done?
                    bne       clrnxt              branch if not
                    leas      2,s                 else clear stack
                    endc
                    puls      x,u                 and restore our earlier saved registers

                    lda       ,x+                 get first char
                    cmpa      #C$CR               CR?
                    lbeq      ShowHelp
* Process command line (a single number)
nextChar            suba      #'0'                Convert ASCII number to value
                    adda      snakesize,u         add stored value with new value
                    sta       snakesize,u         store new snake size
                    lda       ,x                  get next char
                    cmpa      #'0'
                    blo       clDone
                    cmpa      #'9'
                    bhi       clDone
                    lda       #10
                    ldb       snakesize,u         multiply current snake size by 10
                    mul
                    stb       snakesize,u
                    lda       ,x+                 get next char
                    bra       nextChar
clDone              cmpb      #80
                    ble       timeSeed
                    ldb       #80
                    stb       snakesize,u
* Get Time packet to seed PRNG
timeSeed            leax      time,u
                    os9       F$Time
* Turn off cursor
                    leax      IOBUF,u
                    lda       #$05                05 20 is turn off cursor code
                    sta       ,x
                    lda       #$20
                    sta       1,x
                    ldy       #2                  Length of buffer
                    lda       #1                  Output path (stdout)
                    os9       I$Write             Send the value to the device driver
* Add intercept
                    leax      IR,pcr
                    os9       F$Icpt
* Clear screen
                    leax      IOBUF,u
                    lda       #$0c                load 'clear screen' code for VDGINT/WINDINT
                    sta       ,x
                    ldy       #1                  Length of buffer
                    lda       #1                  Output path (stdout)
                    os9       I$Write             Send the value to the device driver
* get window size
                    ldx       #$0
                    ldy       #$0
                    lda       #1                  Output Path (stdout)
                    ldb       #SS.ScSiz           Request screen size
                    os9       I$Getstt            Make requst
                    bcs       sizeErr
                    tfr       x,d
                    cmpb      #$0
                    beq       sizeErr             RBF returns screen size of $0
                    decb
                    stb       windowx,u
                    tfr       y,d
                    decb
                    stb       windowy,u
                    bra       compare
* If SS.ScSiz returns an error set the window up for 80 x 24
sizeErr             ldd       #$4f17
                    std       windowx,u
* compare parameter with window width
compare             ldb       snakesize,u
                    cmpb      windowx,u
                    lbpl      ShowHelp            bail if parameter is larger than window
* fill snake buffer with initial X coordinate for snake positions
*  figure out starting horizontal position of tail
                    clra
                    ldb       snakesize,u
                    lsrb                          divide snake size by 2
                    stb       ,-s
                    ldb       windowx,u
                    lsrb                          divide window width by 2
                    subb      ,s+                 subtract half snake length from half window width
                    addb      #$20                Offset Horizontal position for VDGINT and WINDINT
                    leax      snakebuffer,u
                    lda       snakesize,u
filloopx            stb       ,x++
                    incb
                    deca
                    bne       filloopx            fill snake buffer with initial horizontal coordinates
*  Figure out starting vertical of snake body
                    ldb       windowy,u
                    lsrb                          divide window height by 2
                    addb      #$20                Offset vertical position for VDGINT or WINDINT
                    leax      snakebuffer+1,u
                    lda       snakesize,u
filloopy            stb       ,x++
                    deca
                    bne       filloopy            fill snake buffer with initial vertical coordinates
* Draw initial snake
                    leax      IOBUF,u
                    lda       #$02
                    sta       0,x
                    lda       #'*'
                    sta       3,x
                    ldy       #4                  Length of buffer
                    lda       snakesize,u
                    pshs      u
                    leau      snakebuffer,u
idrlp               ldb       ,u+
                    stb       1,x
                    ldb       ,u+
                    stb       2,x
                    exg       a,b
                    lda       #1                  Output path (stdout)
                    os9       I$Write             Send the value to the device driver
                    exg       b,a
                    deca
                    bne       idrlp               Initial draw loop
                    puls      u
                    lda       snakesize,u         set head pointer to snake size minus one
                    deca
                    sta       head,u
* Offset Window size for VDGINT and WINDINT
                    ldd       windowx,u
                    addd      #$2020
                    std       windowx,u
* Set up IOBUF2 for Easing
                    lda       #$02
                    sta       IOBUF2,u
                    lda       #'                  '
                    sta       IOBUF2+3,U
MainLoop            equ       *
* Erase tail
                    leay      snakebuffer,u
                    leax      IOBUF2,u
                    ldb       head,u
                    incb
                    cmpb      snakesize,u
                    bne       mlcont1
                    clrb
mlcont1             stb       head,u              Store new head offset
                    lslb
                    ldd       b,y                 offset into table pointer
                    sta       1,x
                    stb       2,x
                    ldy       #4
                    lda       #1                  Output path (stdout)
                    os9       I$Write             Send the value to the device driver
* Find position for new head
*  Set Reg X to point to current head position
copyhead            ldb       head,u              get head index
                    lslb
                    leax      snakebuffer,u
                    abx                           advance X to correct position
                    lsrb
                    bne       mlcont2             if not zero
                    ldb       snakesize,u         get snake buffer size
mlcont2             decb                          Back up one index
                    lslb                          multiply by two
                    leay      snakebuffer,u       point y to start of buffer
                    leay      b,y                 advance Y to correct position
                    ldd       ,y                  load coordinates
                    std       ,x                  save coordinates
* pick random number
pick                ldb       #$4
                    lbsr      RAND
                    deca
                    beq       goLeft
                    deca
                    beq       goDown
                    deca
                    beq       goRight

* Remember: coordinates are pre-offset by a value of $20

goUp                ldb       1,x
                    cmpb      #$20
                    beq       pick
                    decb
                    stb       1,x
                    bra       drawHead

goDown              ldb       1,x
                    incb
                    cmpb      windowy,u
                    beq       pick
                    stb       1,x
                    bra       drawHead

goLeft              ldb       ,x
                    cmpb      #$20
                    beq       pick
                    decb
                    stb       ,x
                    bra       drawHead

goRight             ldb       ,x
                    cmpb      windowx,u
                    beq       pick
                    incb
                    stb       ,x
                    bra       drawHead

drawHead            ldd       ,x
                    std       IOBUF+1,u
                    lda       #$1
                    ldy       #$4
                    leax      IOBUF,u
                    os9       I$Write             Send the value to the device driver
                    lda       bail_flag
                    bne       ExitOK
                    ldx       #$1
                    os9       F$Sleep
                    lbra      MainLoop

ExitOk              bsr       bail
                    clrb
Exit                os9       F$Exit

IR                  lda       #$ff
                    sta       bail_flag,u
                    rti
* Turn on cursor
bail                leax      IOBUF,u
                    lda       #$05                05 21 is turn on cursor code
                    sta       ,x
                    lda       #$21
                    sta       1,x
                    ldy       #2                  Length of buffer
                    lda       #1                  Output path (stdout)
                    os9       I$Write             Send the value to the device driver
                    rts

ShowHelp            equ       *
                    ifne      DOHELP
                    leax      >HlpMsg,pcr         point to help message
                    ldy       #HlpMsgL            get length
                    lda       #$02                std error
                    os9       I$Write             write it
                    endc
                    bra       ExitOk

* THIS IS A FAST MEDIUM GRADE RANDOM NUMBER GENERATOR
* From SYMMETRY by Robert Gault, 1993
* LENGTH OF NON-REPEATING SEQUENCE = 16,777,215
* INTERMEDIATE OUTPUT 0 - 255 OR 0 - .996078431 STEPS OF .003921568
* ENTER: REG.B = N+1
* EXIT:  REG.A = 0 TO N
*        REG.B = FRACTIONAL PART OF N
RAND                lda       RND+2,u             GET 19TH BIT
                    anda      #%00100000
                    lsla                          ALIGN IT WITH 24TH BIT
                    lsla                          FASTER THAN SHIFTING TO RIGHT
                    lsla
                    rola
                    eora      RND+2,u             XOR BITS 19&24
                    lsra                          RESULT TO CARRY
                    ror       RND,u               FEED RESULT INTO RANDOM NUMBER
                    ror       RND+1,u             AND SHIFT TO THE RIGHT
                    ror       RND+2,u
                    lda       RND,u
                    mul
                    rts

                    emod
eom                 equ       *
                    end
                    end
