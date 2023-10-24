********************************************************************
* PadROM - ROM padding utility
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2003/09/06  Boisy G. Pitre
* Started.

                    nam       PadROM
                    ttl       ROM padding utility

                    ifp1
                    use       defsfile
                    endc

* Here are some tweakable options
DOHELP              set       0                   1 = include help info
STACKSZ             set       128                 estimated stack size in bytes
PARMSZ              set       256                 estimated parameter size in bytes

* Module header definitions
tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

* Your utility's static storage vars go here
                    org       0
* These vars are used by the base template and shouldn't be removed
parmptr             rmb       2                   pointer to our command line params
filecnt             rmb       1
* These vars are used for this example, it will probably change for you
hexcnt              rmb       1                   used by hex routine
hexvalue            rmb       2                   maximum size is $FFFF
openmode            rmb       1
openpath            rmb       1
filesize            rmb       2
gota                rmb       1
gotb                rmb       1
padbyte             rmb       1
padpage             rmb       256
cleartop            equ       .
                    rmb       STACKSZ+PARMSZ
size                equ       .

* The utility name and edition goes here
name                fcs       /PadROM/
                    fcb       edition

* Place constant strings here
                    ifne      DOHELP
HlpMsg              fcb       C$LF
                    fcc       /Use: NGU [<opts>] <path> [<path>] [<opts>]/
                    fcb       C$LF
                    fcc       /   -a    option 1/
                    fcb       C$LF
                    fcc       /   -b    option 2/
                    fcb       C$LF
                    fcc       /   -c=f  option 3/
                    fcb       C$LF
CR                  fcb       C$CR
HlpMsgL             equ       *-HlpMsg
                    endc
BadSize             fcc       /padrom only pads up to $FFFF bytes/
                    fcb       C$CR
BadSizeL            equ       *-BadSize
BadPad              fcc       /file size exceeds pad size/
                    fcb       C$CR
BadPadL             equ       *-BadPad
UnkOpt              fcc       /unknown option: /
UnkOptL             equ       *-UnkOpt

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

* The start of the program is here.
* Before any command line processing is done, we clear out
* our static memory from U to cleartop, then determine the
* size of our data area (minus the stack).
start               subd      #$0001              subtract 1 from D (param length)
                    lbeq      ShowHelp            if zero, no params were on line

                    pshs      u,x                 save registers for later
                    leax      cleartop,u          point to end of area to zero out
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

InitVars            stx       <parmptr            save parameter pointer
                    lda       #UPDAT.             get default open mode
                    sta       <openmode           and save it
                    lda       #$FF
                    sta       <padbyte            assume a default pad byte

* At this point we have determined our buffer space and saved pointers
* for later use.  Now we will parse the command line for options that
* begin with a dash.
* Note that X will NOT point to a space, but to either a CR (if no
* parameters were passed) or the first non-space character of the
* parameter.
* Here we merely grab the byte at X into A and test for end of line,
* exiting if so.  Utilities that don't require arguments should
* comment out the following three lines.
GetChar             lda       ,x+                 get next character on cmd line
                    cmpa      #C$CR               CR?
                    beq       DoPadROM            if so, do whatever this utility does
                    cmpa      #'-                 is it an option?
                    beq       GetDash             if so, process it
                    inc       <filecnt            else must be a non-option argument (file)
                    lbsr      SkipNSpc            move past the argument
ChkDash             lbsr      SkipSpcs            and any following spaces
                    bra       GetChar             start processing again
GetDash             clr       -1,x                wipe out the dash from the cmd line
GetDash2            ldd       ,x+                 load option char and char following
                    ora       #$20                make lowercase
IsItX               cmpa      #'x                 is it this option?
                    bne       IsItC               branch if not
                    lda       #EXEC.+UPDAT.
                    sta       <openmode
                    bra       FixCmdLn
IsItC               cmpa      #'c                 is it this option?
                    bne       BadOpt              branch if not
                    cmpb      #'=                 2nd char =?
                    lbne      ShowHelp            show help if not
                    clr       -$01,x              write over c
                    clr       ,x+                 and = sign, inc X to dest dir
* check for valid char after -c=
                    lbsr      Hex2Int             get value of hex pad char
                    lda       <hexvalue+1
                    sta       <padbyte            save pad character byte
                    lda       ,x                  get char at X (should be space or CR)
                    cmpa      #C$SPAC
                    beq       ChkDash
                    cmpa      #C$CR
                    beq       ChkDash
                    lbra      ShowHelp            neither, so show help

FixCmdLn            clr       -$01,x              wipe out option character
                    cmpb      #'0
                    blt       ChkDash             start dash option processing again
                    bra       GetDash             possibly another option following?

* We branch here if we encounter an unknown option character
* A = bad option character
BadOpt              leax      UnkOpt,pcr
                    ldy       #UnkOptL
                    ldb       #C$CR
                    pshs      d                   save bad option and CR on stack
                    lda       #$02                stderr
                    os9       I$Write
                    leax      ,s                  point X at option char on stack
                    os9       I$WritLn            print option and CR
                    puls      d                   clean up stack
                    lbra      ShowHelp


* At this point options are processed.
* We load X with our parameter pointer and go down the command line
* looking at each file to process (options have been wiped out with
* spaces)
*
* Note, the following two instructions may not be needed, depending on
* if your utility requires a non-option on the command line.
DoPadROM
* Before processing any parameters, fill <padpage with <padchar
                    clrb
                    lda       <padbyte
                    leax      padpage,u
fillpage            sta       ,x+
                    decb
                    bne       fillpage

* Get parameter pointer and skip leading spaces
                    ldx       <parmptr            get our parameter pointer
                    lbsr      SkipSpcs            skip any leading spaces
* First parameter should be a hex pad size (maximum 4 hex bytes)
                    lbsr      Hex2Int             get hex value
                    dec       <filecnt            decrement file count
                    lbeq      ShowHelp            if no other file, exit with error
DoLoop              lbsr      SkipSpcs            skip any leading spaces
                    cmpa      #C$CR               end of parameters?
                    beq       ExitOk              if so, end the utility
                    pshs      x                   save pointer to arg
                    bsr       ProcFile            process file at X
                    puls      x                   get arg pointer
                    lbsr      SkipNSpc            skip the argument we just processed
                    bra       DoLoop

* This routine processes one file at a time.
* Entry: X = ptr to argument on the command line.
* On exit, X can point to the argument or past it.
* Note that there are NO leading spaces.
* They have been skipped by the caller.
* The following code just echos the command line argument, followed
* by a carriage return.
ProcFile
                    lda       <openmode           get open mode
                    ldy       #256
                    os9       I$Write
                    os9       I$Open              open file
                    bcs       Exit                exit if error
                    sta       <openpath           save path
                    ldb       #SS.Size            we want the file size
                    pshs      u,x                 save
                    os9       I$GetStt            get the size
                    stu       <filesize           save file size
                    bcs       Exit                branch if error
                    cmpx      #$0000              file bigger than 65535?
                    bne       toobig              yup
                    lda       <openpath           get path to file
                    os9       I$Seek              seek to the end of the file
                    bcs       Exit                branch if error
                    puls      x,u                 restore
* Expand the file out to the desired size
                    ldd       <hexvalue           get pad size
                    subd      <filesize           get remaining size left
                    bcs       padbad
* D now holds the number of bytes we need to write
                    pshs      d                   save count on stack
                    lda       <openpath           get path to file
                    leax      padpage,u           point to pad page
                    tst       ,s                  greater than 256 bytes left?
                    beq       cont2               no, write remaining
                    ldy       #256                for 256 bytes
cont                os9       I$Write             write it out
                    bcs       Exit                branch if error
                    dec       ,s                  decrement page count
                    bne       cont
cont2               puls      y                   get count off stack into Y
                    os9       I$Write             write out remaining bytes
                    bcs       Exit                branch if error

* Now close the file and return
                    os9       I$Close             close it
                    rts

toobig              lda       #$02                stdout
                    ldy       #BadSizeL           get length of bad size message
                    leax      BadSize,pcr         and point to it
                    os9       I$WritLn            send out the message
                    bra       error1

padbad              lda       #$02
                    ldy       #BadPadL
                    leax      BadPad,pcr
                    os9       I$WritLn
error1              ldb       #$01
                    bra       Exit

ShowHelp            equ       *
                    ifne      DOHELP
                    leax      >HlpMsg,pcr         point to help message
                    ldy       #HlpMsgL            get length
                    lda       #$02                std error
                    os9       I$WritLn            write it
                    endc
ExitOk              clrb                          clear carry
Exit                os9       F$Exit              and exit


* This routine skip over spaces and nul bytes
*
* Entry:
*   X = ptr to data to parse
* Exit:
*   X = ptr to first non-whitespace char
*   A = non-whitespace char
SkipSpcs            lda       ,x+
                    beq       SkipSpcs
                    cmpa      #C$SPAC
                    beq       SkipSpcs
                    leax      -1,x
                    rts

* This routine skips over everything but spaces, nul bytes and CRs
*
* Entry:
*   X = ptr to data to parse
* Exit:
*   X = ptr to first whitespace char
*   A = whitespace char
SkipNSpc            lda       ,x+
                    beq       EatOut
                    cmpa      #C$SPAC
                    beq       EatOut
                    cmpa      #C$CR
                    bne       SkipNSpc
EatOut              leax      -1,x
                    rts


* Hex2Int
*
* Entry:
*   X = address of hex string (1-4 bytes)
* Exit:
*   <hexvalue = value of hex string
*   X = address of character after hex string
Hex2Int             clr       <hexcnt             clear our counter
                    lda       ,x
                    cmpa      #'$                 hex sign?
                    bne       Hex2Int2
                    clr       ,x+                 clear it and move to next char
Hex2Int2            bsr       Hex2Nib             get hex nibble at ,X
                    bcs       HexW2               branch if done
                    pshs      b                   save good hex byte on stack
                    inc       <hexcnt             increment counter
                    lda       <hexcnt             get counter
                    cmpa      #$04                max size?
                    beq       HexW3
                    bra       Hex2Int2            and continue

* Here, <hexcnt contains a count of the bytes on the stack that contain
* hex values
HexW2               tst       <hexcnt             any valid hex data?
                    beq       HexWDone            no, exit

HexW3               clra                          clear out return hex value
                    clrb
                    std       <hexvalue

                    puls      b                   get nibble off the stack
                    stb       <hexvalue+1
                    dec       <hexcnt             decrement counter
                    beq       HexWDone            branch if done
                    lsl       ,s                  else move lo-nib on stack to hi-nib
                    lsl       ,s
                    lsl       ,s
                    lsl       ,s
                    addb      ,s+                 and add it to lonibble in B
                    stb       <hexvalue+1
                    dec       <hexcnt             decrement counter
                    beq       HexWDone
                    puls      b                   get nibble off the stack
                    stb       <hexvalue+0
                    dec       <hexcnt             decrement counter
                    beq       HexWDone
                    lsl       ,s                  else move lo-nib on stack to hi-nib
                    lsl       ,s
                    lsl       ,s
                    lsl       ,s
                    addb      ,s+                 and add it to lonibble in A
                    stb       <hexvalue+0

HexWDone            rts



* Hex2Nib - Convert byte at X from hex to byte integer
*
* Entry:
*   X = address of byte to convert
* Exit:
*   A = ASCII value of char at X
*   B = byte value of hex char at X (if carry clear)
*       OR error (if carry set)
Hex2Nib             lda       ,x                  get char at X
                    tfr       a,b                 transfer it to working reg (B)
                    subb      #$30                subtract '0
                    cmpb      #$09                compare against 9
                    bls       L02B1               branch if valid number
                    cmpb      #$31                uppercase?
                    bcs       L02A7               branch if so
                    subb      #$20                else make uppercase
L02A7               subb      #$07                subtract
                    cmpb      #$0F                compare against 0x0F
                    bhi       L02B6               branch if higher
                    cmpb      #$0A                compare against 0x0A
                    bcs       L02B6
L02B1               andcc     #^Carry             clear carry
                    clr       ,x                  clear byte on cmd line
                    leax      $01,x               move X to next char
                    rts                           return
L02B6               comb
                    rts

                    emod
eom                 equ       *
                    end
