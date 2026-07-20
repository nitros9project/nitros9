********************************************************************
* sdir - Print directory of SDC card
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2014/11/20  tim lindner
* Started writing code.
*   2      2015/02/07  tim lindner
* Refactored code to use llcocosdc.

                    nam       sdir
                    ttl       Print directory of SDC card

                    ifp1
                    use       defsfile
                    use       cocosdc.d
                    endc


* Here are some tweakable options
STACKSZ             set       32                  estimated stack size in bytes
PARMSZ              set       256                 estimated parameter size in bytes

* Module header definitions
tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    org       0
pathnumber          rmb       1
count               rmb       1
flag                rmb       1
columns             rmb       2
buffer              rmb       256

* Finally the stack for any PSHS/PULS/BSR/LBSRs that we might do
                    rmb       STACKSZ+PARMSZ
size                equ       .

* The utility name and edition goes here
name                fcs       /sdir/
                    fcb       edition

* Place constant strings here
header              fcc       /SDC Directory: /
headerL             equ       *-header

basepath            fcc       /L:*.*/
                    fcb       0
basepathL           equ       *-basepath-1

parameterTooLong    fcc       /Parameter too long./
                    fcb       C$LF
                    fcb       C$CR
parameterTooLongL   equ       *-parameterTooLong

timoutError         fcc       /Timeout./
carrigeReturn       fcb       C$LF
                    fcb       C$CR
timoutErrorL        equ       *-timoutError

dirNotFound         fcc       /Directory not found./
                    fcb       C$LF
                    fcb       C$CR
dirNotFoundL        equ       *-dirNotFound

pathNameInvalid     fcc       /Pathname is invalid./
                    fcb       C$LF
                    fcb       C$CR
pathNameInvalidL    equ       *-pathNameInvalid

miscHardwareError   fcc       /Miscellaneous hardware error./
                    fcb       C$LF
                    fcb       C$CR
miscHardwareErrorL  equ       *-miscHardwareError

notInitiated        fcc       /Listing not initiated./
                    fcb       C$LF
                    fcb       C$CR
notInitiatedL       equ       *-notInitiated

truncated           fcc       /Out of memory. Listing trucated./
                    fcb       C$LF
                    fcb       C$CR
                    fcb       C$LF
                    fcb       C$CR
truncatedL          equ       *-truncated

dirString           fcc       / <DIR>  /
dirStringL          equ       *-dirString

sdcPathName         fcc       ./sd0@.
                    fcb       C$CR

sdcNotFound         fcc       "SDC Driver or /sd0 not found."
                    fcb       C$LF
                    fcb       C$CR
sdcNotFoundL        equ       *-sdcNotFound

mounted_header      fcc       "CoCo SDC mounted images:"
                    fcb       C$LF
                    fcb       C$CR
mounted_headerL     equ       *-mounted_header

mount_zero          fcc       "0: "
mount_zeroL         equ       *-mount_zero

mount_one           fcc       "1: "
mount_oneL          equ       *-mount_one

not_mounted         fcc       "Not Mounted"
                    fcb       C$LF
                    fcb       C$CR
not_mountedL        equ       *-not_mounted

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

list_mounted_images
                    puls      d
                    lda       #1
                    sta       flag,u              set "first time" flag

                    leax      mounted_header,pcr
                    ldy       #mounted_headerL
                    lda       #1                  standard output
                    os9       I$Write

                    lbsr      open_path_to_driver

                    leax      mount_zero,pcr
                    ldy       #mount_zeroL
                    ldb       #$c0                set command code for first slot
get_next_image
                    lda       #1                  standard output
                    os9       I$Write

get_mounted_image
                    lda       pathnumber,u
                    leax      buffer,u            output buffer
                    pshs      u
                    ldu       #'I                 parameter
                    os9       I$Getstt
                    puls      u
                    bcc       parse_mounted_image
                    tsta
                    lbeq      timeOut
                    bita      #$80
                    bne       print_not_mounted
                    tfr       a,b
                    lbra      exit_now

parse_mounted_image
                    leax      buffer,u
                    lbsr      PrintFileName

* print mounted flags
                    leax      buffer,u
                    lda       #$20
                    sta       ,x
                    ldb       11,x
                    lda       #'-
                    bitb      #$10
                    beq       pmf1
                    lda       #'D
pmf1
                    sta       1,x
                    lda       #'-
                    bitb      #$4
                    beq       pmf2
                    lda       #'S
pmf2
                    sta       2,x
                    lda       #'-
                    bitb      #$2
                    beq       pmf3
                    lda       #'H
pmf3
                    sta       3,x
                    lda       #'-
                    bitb      #$1
                    beq       pmf4
                    lda       #'L
pmf4
                    sta       4,x
                    lda       #1
                    ldy       #5                  a space then four characters
                    os9       I$Write

print_mounted_size
                    leax      buffer+28,u
                    lbsr      PrintFileSize

                    leax      carrigeReturn,pc
                    ldy       #2
                    lda       #1                  standard output
                    os9       I$Write

                    bra       next_mounted_image

print_not_mounted
                    leax      not_mounted,pcr
                    ldy       #not_mountedL
                    lda       #1                  standard output
                    os9       I$Write

next_mounted_image
                    lda       flag,u
                    lbeq      exit_ok             if flag zero, we are done.
                    dec       flag,u
                    leax      mount_one,pcr
                    ldy       #mount_oneL
                    ldb       #$c1                set command code for second slot
                    lbra      get_next_image

* error printers
timeOut
                    leax      >timoutError,pcr    point to help message
                    ldy       #timoutErrorL       get length
genErr
                    lda       #$02                std error
                    os9       I$Write
                    ldb       #1
                    lbra      exit_now
noDriverError
                    leax      >sdcNotFound,pcr
                    ldy       #sdcNotFoundL
                    lda       #$02                std error
                    os9       I$Write
                    lbra      exit_now
parameterToLongError
                    leax      >parameterTooLong,pcr
                    ldy       #parameterTooLongL
                    bra       genErr
targetDirectoryNotFoundError
                    leax      >dirNotFound,pcr
                    ldy       #dirNotFoundL
                    bra       genErr
miscellaneousHardwareError
                    leax      >miscHardwareError,pcr
                    ldy       #miscHardwareErrorL
                    bra       genErr
pathNameInvalidError
                    leax      >pathNameInvalid,pcr
                    ldy       #pathNameInvalidL
                    bra       genErr
notInitiatedError
                    leax      >notInitiated,pcr
                    ldy       #notInitiatedL
                    bra       genErr

* open path to driver
* uses A, X
open_path_to_driver
                    leax      sdcPathName,pc
                    lda       READ.+PREAD.        open for reading
                    os9       I$Open
                    lbcs      noDriverError       Fail if not opened
                    sta       pathnumber,u
                    rts

* The start of the program is here.
start
                    pshs      d
* check for hyphen
                    lda       ,x
                    cmpa      #'-
                    lbeq      list_mounted_images

* print header
                    pshs      x,y
                    lda       #1                  standard output
                    leax      header,pc
                    ldy       #headerL
                    os9       I$Write
                    puls      x,y
                    puls      d
* check for zero parameters
                    cmpd      #1
                    beq       use_base_path
* check for prefix on user supplied parameter string
                    clr       -1,y                place null at end of parameter area
                    subb      #1
                    sbca      #0                  decrement reg d
                    tfr       d,y                 store parameter length in reg y
                    ldd       ,x
                    cmpd      #$4c3a              "L:"
                    beq       print_path
* stack ascii characters to prepend "L:" to user supplied base path
                    ldd       #$4c3a
                    pshs      d
                    leay      2,y                 increase parameter length by 2
* point reg x to base path string
                    tfr       s,x
                    bra       print_path

use_base_path
                    leax      basepath,pc
                    ldy       #basepathL
print_path
                    pshs      x
                    lda       #1                  standard output
                    os9       I$Write
                    leax      carrigeReturn,pc
                    ldy       #2
                    os9       I$Write
                    bsr       open_path_to_driver

* Get screen width
                    lda       #1                  Output Path (stdout)
                    ldb       #SS.ScSiz           Request screen size
                    os9       I$Getstt            Make screen size request
                    ldd       #$0403
                    cmpx      #75
                    bhi       save_screen
                    ldd       #$0302
                    cmpx      #42
                    bhi       save_screen
                    ldd       #$0201
save_screen
                    std       columns,u           Save Column information

* ask driver to initiate directory transfer
* path buffer must be on stack
                    puls      x
                    lda       pathnumber,u
                    ldb       #$e0
                    pshs      u
                    os9       I$Getstt
                    puls      u
                    bcc       get_diretory_block
                    tsta
                    lbeq      timeOut
                    bita      #$10
                    lbne      targetDirectoryNotFoundError
                    bita      #$08
                    lbne      miscellaneousHardwareError
                    bita      #$04
                    lbne      pathNameInvalidError
                    tfr       a,b
                    lbra      exit_now

get_diretory_block
                    lda       pathnumber,u
                    ldb       #$c0                Command code
                    leax      buffer,u            output buffer
                    pshs      u
                    ldu       #$3e                parameter
                    os9       I$Getstt
                    puls      u
                    bcc       parse_directory_block
                    tsta
                    lbeq      timeOut
                    bita      #$80
                    lbne      miscellaneousHardwareError
                    bita      #$08
                    lbne      notInitiatedError
                    tfr       a,b
                    bra       exit_now

parse_directory_block
                    ldb       #-1
                    stb       count,u
check_if_done
                    dec       columns,u
                    bne       print_continue
                    lda       columns+1,u
                    sta       columns,u
print_return
                    leax      carrigeReturn,pc
                    ldy       #2
                    lda       #1
                    os9       I$Write
print_continue
                    ldb       count,u
                    incb
                    stb       count,u
                    cmpb      #16
                    beq       get_diretory_block  go get another block
                    lda       #16
* calculate directory record address
                    mul
                    leax      buffer,u
                    abx
                    lda       ,x
                    cmpa      #0
                    beq       exit_ok

                    bsr       PrintFileName

* print flags
                    ldb       4,x
                    lda       #'-
                    bitb      #2
                    beq       pf1
                    lda       #'H
pf1
                    sta       1,x
                    lda       #'-
                    bitb      #1
                    beq       pf2
                    lda       #'L
pf2
                    sta       2,x
                    lda       #1
                    ldy       #3
                    os9       I$Write
                    bitb      #$10
                    beq       print_size

* print directory token
                    leax      >dirString,pcr
                    ldy       #dirStringL
                    os9       I$Write
                    bra       end_print

print_size
                    leax      5,x
                    bsr       PrintFileSize

end_print
                    bra       check_if_done

exit_ok
                    clrb
exit_now
                    os9       F$Exit

*********************************************************************
* PrintFileName
*********************************************************************
* ENTRY:
* X = Address of 10 byte filename and extension
*
* EXIT:
*
PrintFileName
                    lda       #1                  standard output
                    ldy       #8                  filename length
                    os9       I$Write
                    ldb       #$20
                    leax      7,x
                    stb       ,x
                    ldy       #4
                    os9       I$Write
                    rts

*********************************************************************
* PrintFileSize
*********************************************************************
* ENTRY:
* X = Address of 4 byte file size
* String buffer at -11,x
* String buffer index at -12,x
*
* EXIT:
*
PrintFileSize
                    pshs      u
                    leau      ,x
* start with a space
                    lda       #$20                space character
* store U offset in -11,u
                    ldb       #-11
                    stb       -12,u
                    sta       b,u
                    incb
                    stb       -12,u
                    lda       ,u
                    beq       ps1
* Very large number: load offset 0 and 1, shift right 4 bits, print decimal as mega bytes
                    ldb       1,u
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    bsr       L09BA               write ascii value of D to buffer
                    lda       #'M
                    bra       psUnit
ps1
                    lda       1,u
                    beq       ps2
* Kind of large number: load offsets 1 and 2, shift right 2 bits, print decimal as kilo bytes
                    ldb       2,u
                    lsra
                    rorb
                    lsra
                    rorb
                    bsr       L09BA               write ascii value of D to buffer
                    lda       #'K
                    bra       psUnit
ps2
                    ldd       2,u
* number: load offsetprint 14 and 15, print decimal as bytes
                    bsr       L09BA               write ascii value of D to buffer
                    lda       #'B
                    bra       psUnit
* print unit to buffer
psUnit
                    ldb       -12,u
                    sta       b,u
                    lda       #$20
                    incb
                    sta       b,u
                    incb
                    sta       b,u
                    incb
                    sta       b,u
                    incb
                    sta       b,u
                    incb
                    sta       b,u
                    lda       #1
                    ldy       #8
                    leax      -11,u
                    os9       I$Write
                    puls      u
                    rts

* Stolen from BASIC09
* Convert # in D to ASCII version (decimal)
L09BA               pshs      y,x,d               Preserve End of data mem ptr,?,Data mem size
                    pshs      d                   Preserve data mem size again
                    leay      <L09ED,pc           Point to decimal table (for integers)
L09C1               ldx       #$2F00
L09C4               puls      d                   Get data mem size
L09C6               leax      >$0100,x            Bump X up to $3000
                    subd      ,y                  Subtract value from table
                    bhs       L09C6               No underflow, keep subtracting current power of 10
                    addd      ,y++                Restore to before underflow state
                    pshs      d                   Preserve remainder of this power
                    ldd       ,y                  Get next lower power of 10
                    tfr       x,d                 Promptly overwrite it with X (doesn't chg flags)
                    beq       L09E6               If finished table, skip ahead
                    cmpd      #$3000              Just went through once?
                    beq       L09C1               Yes, reset X & do again
                    ldb       -12,u               Write A to output buffer
                    sta       b,u
                    incb
                    stb       -12,u
                    ldx       #$2F01              Reset X differently
                    bra       L09C4               Go do again

L09E6
                    ldb       -12,u               Write A to output buffer
                    sta       b,u
                    incb
                    stb       -12,u
                    leas      2,s                 Eat stack
                    puls      pc,y,x,d            Restore regs & return

* Table of decimal values
L09ED               fdb       $2710               10000
                    fdb       $03E8               1000
                    fdb       $0064               100
                    fdb       $000A               10
                    fdb       $0001               1
                    fdb       $0000               0

                    emod
eom                 equ       *
                    end
