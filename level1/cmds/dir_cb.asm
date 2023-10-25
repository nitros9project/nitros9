* DIR Edition #8 - Released Mar. 12/2000
* Added the '-c' option, which stands for case insensitive. This means that
*  wildcard filename matches do not care as to whether the filenames are
* upper or lowercase, when compared to the wildcard filename search you
* specified. There still are some quirks to using the '*' wildcard in some
* cases... I am still tracking down why that is happening.
*
* DIR Edition #7 - Released Jan. 16/2000
*
* This is a new version of the DIR command, based on the version Alan Dekok
*  did with wildcarding. It fixes the year to work with modern clock drivers,
*  allowing from 1900-2155. It also fixes the help message, and changes the
* edition # to 7. It should work with all version of OS9/NitrOS9/PowerBoost.
*
* -Curtis-
*
* Edition #7: (L. Curtis Boyle)
* 2000/01/15: Fixed help message bug.
* 2000/01/16: Fixed year output to handle 1900-2155
*
* Edition #8 (Curtis)
* 2000/03/11  Fixed Bad Filename error
* 2000/03/12  Added -c option (case insensitive filematching)

* Need to do 1 things:
*   Fix '*' wildcards (ex. DIR *.lzh returns completely different than
*      DIR *lzh - 1st only does files with ONE '.' char, 2nd does mix of ONE
*      and >1, but not all the same as first example???)

                    nam       dir
                    ttl       program module

* Disassembled 94/11/18 12:51:39 by Alan DeKok

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       1                   Path to current Directory
u0001               rmb       1                   Path to RAW drive (current data or exec dir's drive)
u0002               rmb       2                   Pointer to directory we are DIRing
u0004               rmb       2                   Ptr to end of current sub-parm (if more than 1)
u0006               rmb       2                   Pointer to filename match string we are DIRing
u0008               rmb       1                   Case insensitive flag (0=NO)
u0009               rmb       1                   Wildcard matched flag (0=NO)
u000A               rmb       1                   0=Filename not written yet, <>0 means is written out
u000B               rmb       1                   Merge of directories/non-directories/ext. info flags
u000C               rmb       1                   Wildcards in effect flag
u000D               rmb       1                   Extended info flag (0=No)
u000E               rmb       1                   Directories ONLY (0=No)
u000F               rmb       1                   Non-directories ONLY (0=NO)
u0010               rmb       1                   One entry/line flag (0=Yes, else no)
u0011               rmb       1                   Screen width
u0012               rmb       1                   # chars left on current output line
u0013               rmb       2                   Length of current filename
u0015               rmb       1                   char from current directory entry
u0016               rmb       1                   char from wild card string
u0017               rmb       1                   Attributes for DIR open (Ex. EXEC)
* File descriptor info - 1st 13 bytes - only used if certain options and/or
*   extended directory listings are requested.
u0018               rmb       1                   File attributes
u0019               rmb       2                   File owner ID
u001B               rmb       5                   Date last modified
u0020               rmb       1                   DIR path # (link count on FD read, but not used)
u0021               rmb       4                   File size (in bytes)
* Start of WritLn buffer for each directory entry starts here
u0025               rmb       1
* Information to be printed out goes here
* user-number, 4 bytes of hex, space space
u0026               rmb       6
* YY/MM/DD HHMM
u002C               rmb       17
* file attributes
u003B               rmb       10
* starting sector number
u0045               rmb       8
* file size
u004D               rmb       8
* a space
u0055               rmb       1
* file name
u0056               rmb       25
u006F               rmb       1
u0070               rmb       4
* starting sector of the file (3 bytes)
u0074               rmb       2
u0076               rmb       1
u0077               rmb       1                   always 0
AllFlag             rmb       1                   $2E=don't print out .foo, $00=print out .foo
                    rmb       256                 leave room for the stack
size                equ       .

name                fcs       /dir/
                    fcb       $08

start               ldd       #$0150              Default to multiple entries/line, 80 column width
                    std       <u0010
                    lda       #'.                 default to NOT printing files with this first char
                    sta       <AllFlag
                    clra
                    clrb
                    std       <u000E              directories only/non-directories only flags
                    std       <u000C              Clear wildcard & extended info flags
                    sta       <u0008              Set case sensitivity to ON
                    leay      >L0449,pc           point to '.'
                    sty       <u0002              Default to current data directory as DIR path
                    ldb       #READ.              directory attribute=READ.
                    clr       <u0077              Always 0
* Process parameter line
L003F               lda       ,x                  get character
                    cmpa      #$0D                End of parms?
                    beq       L0071               yup, time to dir!
                    cmpa      #$20                space?
                    beq       L006D               yup, skip it
                    pshs      x                   save ptr to start of current sub-parm
L004B               lda       ,x+                 get char, bump up ptr
                    cmpa      #$20                if a space, skip it
                    beq       L0057
                    cmpa      #$0D                if not a CR, skip
                    bne       L004B
                    leax      -1,x                save address of the CR
L0057               stx       <u0004              Save ptr to end of current sub-parm
                    puls      x                   Restore start of current sub-parm
                    lda       ,x                  Get 1st char of sub-parm
                    cmpa      #'-                 option flag?
                    bne       L0066               no, must be dir/filename, go process
                    lbsr      L023A               Update flags based on hyphen options
                    bra       L0069               Continue from end of current sub-parm block

L0066               lbsr      L0286               Process dir and/or filenames
L0069               ldx       <u0004              Continue from end of current sub-parm block
                    bra       L003F               Start working on next sub-parm

L006D               leax      1,x                 skip this character
                    bra       L003F               and get another one

* Done processing parameter line - start doing actual DIR
* Entry: A=13 (which looks to be width if SS.ScSiz fails).
L0071               stb       <u0017              Save directory attributes byte
                    ldb       <u000D              Get extended info flag
                    orb       <u000E              Merge setting with Directories flag
                    orb       <u000F              Merge with non-directories flag
                    stb       <u000B              Save merged flag
                    tst       <u0010              one line/entry?
                    beq       L00B3               if so, continue
                    pshs      x,a
* Calculate dir table width
                    lda       #1
                    ldb       #SS.ScSiz           return screen size
                    os9       I$GetStt
                    bcs       L00A6               Check for unknown service error
                    tfr       x,d                 Move screen width to D
                    cmpb      #80                 >=80 characters/line?
                    bhs       L00AF               Yes, continue
                    lda       #60                 go to 64
                    cmpb      #60                 64 to 79 chars?
                    bhs       L00AD               Yes, set width to 64
                    lda       #48                 48 to 63 chars?
                    cmpb      #48                 Yes, set width to 48
                    bhs       L00AD
                    lda       #32                 32 to 47 chars?
                    cmpb      #32                 Yes, set to 32 chars
                    bhs       L00AD
                    clr       <u0010              if <32, do 1 file/line
                    bra       L00AD

L00A6               cmpb      #E$UnkSvc           Unknown service code?
                    beq       L00AF               Yes, skip ahead
                    lbra      L0430               Check for EOF, or exit with error

L00AD               sta       <u0011              Save screen width we will use
L00AF               andcc     #$FE                Clear error flag
                    puls      x,a                 Restore regs
L00B3               lda       <u0017              Get current attributes flag
                    ora       #$80                Add DIR attribute
                    ldx       <u0002              Get ptr to DIR directory path
                    os9       I$Open              Open directory
                    lbcs      L0430               Error, exit with it
                    sta       <u0000              Save DIR path
                    ldx       <u0002              Get ptr to DIR pathname
                    lda       <u0017              Get DIR attributes we used to OPEN
                    os9       I$ChgDir            Change directory to DIR path
                    tst       <u000B              Get dir vs. nondir, extended info flags
                    beq       L00ED               None set, skip ahead
                    lda       <u0017              Get DIR attributes
                    leax      >L044B,pc           point to '@'
                    os9       I$Open              Open current drive RAW (to get file descriptors)
                    lbcs      L0430               Error, check for EOF, or exit with it
                    sta       <u0001              Save path to raw drive
L00ED               lda       <u0011              Get screen width
                    sta       <u0012              Save it as # chars left on current output line
                    lda       <u000D              Get extended info requested flag
                    ora       <u0010              Merge with 1 line/entry flag
                    beq       L0145               All clear, skip 'Directory of'
                    leax      >L044D,pc           Print ' Directory of ' to screen
                    ldy       #$000F
                    lda       #$01
                    os9       I$Write
                    lbcs      L0430
                    leay      <u0025,u            Point to directory entries buffer area
                    ldx       <u0002              Get pathname to directory
L010D               lda       ,x+                 Copy pathname up until CR
                    sta       ,y+
                    cmpa      #$0D
                    bne       L010D
                    tst       <u000C              Separate filename?
                    beq       L0127               No, skip ahead
                    lda       #'/                 Yes, Add slash to end of buffer
                    sta       -1,y
                    ldx       <u0006              Get pointer to user filename request
* Copy User filename to end of 'dir of' line
L011F               lda       ,x+                 Copy it over until CR
* Force to uppercase if case insensitive flag set AND char is lowercase
* Will make for faster compares later.
                    lbsr      ForcUppr            Do uppercase change if needed
                    sta       -1,x                Save over original char (in case changed)
                    sta       ,y+
                    cmpa      #$0D
                    bne       L011F
L0127               leax      <u0025,u            Point to full directory path/file requested
                    ldy       #$00FF              Max of 255 chars to print
                    lda       #$01                Print directory name out (with 'directory of')
                    os9       I$WritLn
                    tst       <u000D              Extended info requested?
                    beq       L0145               No, skip extended info header
                    ldd       #$0102              std out for output, 2 lines to print
                    leax      >L045C,pc           Write out extended info header lines
                    lbsr      L0627
                    lbcs      L0430

* Main dir entry reading loop
L0145               lda       <u0000              get path number to current directory
                    ldy       #$001D              get the filename
                    leax      <u0056,u            where to put it
                    os9       I$Read              read it
                    lbcs      L0430
                    ldy       #$0003              and the starting sector
                    leax      <u0074,u
                    os9       I$Read
                    lbcs      L0430
                    lda       <u0056              get the first character of filename
                    beq       L0145               if zero (deleted), skip it
                    cmpa      #$80                hi bit (deleted), ignore it
                    beq       AllCont             continue
* Now A<>0, and AllFlag may be zero (=print out all files)
                    anda      #$7F
                    cmpa      <AllFlag            do all files?
                    beq       L0145               if the first character is '.', don't print it
* Non '.' leading char filenames go here
AllCont             clrb                          Filename size set to 0
                    leax      <u0056,u            Point to filename
L016D               lda       ,x+                 Check char
                    incb                          Bump up filename size
                    cmpa      #$80                End of filename marker?
                    blo       L016D               No, keep getting size
                    anda      #$7F                make it a real character
                    sta       -1,x                save it back
                    lda       #$0D                Add carriage return to filename
                    sta       ,x
                    stb       <u0013              Save filename size
                    tst       <u000C              filename to match specified?
                    beq       L0191               No, skip ahead
                    leax      <u0056,u            Point to filename part of write buffer
                    ldy       <u0006              Get ptr to filename match string
                    lbsr      L0324               Do wildcard compare
                    tst       <u0009              Did we have a match?
                    beq       L0145               No, skip to next filename
L0191               tst       <u000B              Any files we have to weed out?
                    beq       L01CA               No, just print
* we only want certain types of files - check
                    ldx       <u0074              Get FD sector # - hi word
                    pshs      u                   Preserve U
                    ldu       <u0076              Get FD sector # - low word
                    lda       <u0001              Get path to raw drive
                    os9       I$Seek              seek to the file descriptor
                    lbcs      L0430
                    puls      u                   Restore U
                    leax      <u0018,u            Point to place to store FD info
                    ldy       #13                 We only need 1st 13 bytes
                    os9       I$Read              Read it in
                    lbcs      L0430
                    lda       <u0018              Get file attributes
                    anda      #$80                Ignore all but DIR attribute
                    tst       <u000E              Directories ONLY?
                    beq       L01C1               No, skip ahead
                    tsta                          This file a directory?
                    lbeq      L0145               No, skip to next filename
                    bra       L01CA               Yes, print dir name out

L01C1               tst       <u000F              Non-directories ONLY?
                    beq       L01CA               No, print filename out
                    tsta                          This file a non-directory?
                    lbne      L0145               It is a DIR, skip to next filename
* Print current dir entry out
L01CA               tst       <u0010              do one entry/line?
                    beq       L0221               yes, print it out
                    clr       <u000A              Flag we have NOT printed filename yet.
                    ldb       <u0013              Get filename size
                    cmpb      <u0012              enough chars left in current output line to fit?
                    bge       L0205               No, Print CR
                    inc       <u000A              Flag that we will have printed filename
L01D8               clra                          D=Current filename size
                    tfr       d,y                 Y=size of filename
                    inca                          Std Out
                    leax      <u0056,u            Point to filename in output buffer
                    os9       I$Write             Write out filename
                    lbcs      L0430
                    lda       <u0012              Get # chars left on current output line
* Add spaces between filenames - they are 'tabbed' at 16 or 32 chars,
*   depending on filename size
L01E8               suba      #16                 Subtract 16 from # chars left on output line
                    ble       L0205               Done line, print CR
                    subb      #16                 Not done, subtract 16 chars from filename size
                    bge       L01E8               filename was >16 chars, bump to next 'tab' stop
                    negb                          # spaces we have to print to pad to next 'tab'
                    sta       <u0012              Save # chars left on output line
                    clra                          Y=# spaces to print to finish current tab field
                    tfr       d,y
                    inca                          Std out
                    leax      >L04F2,pc           Write spaces out
                    os9       I$Write
                    lbcs      L0430
                    lbra      L0145               On to next filename entry

* Flush out current output line to screen, reset # chars left on output line
*   to screen width.
L0205               lda       #$01                Print CR by itself
                    ldy       #$0001
                    leax      >L044A,pc
                    os9       I$WritLn
                    lbcs      L0430
                    lda       <u0011              Get screen width
                    sta       <u0012              Save as size available on current line
                    tst       <u000A              Did we print filename out yet?
                    beq       L01D8               No, do it now
                    lbra      L0145               Already printed, skip to next filename

L0221               tst       <u000D
                    lbne      L036A               if not zero, print out all the information
                    lda       #$01
                    leax      <u0056,u
                    ldy       #$001E              length of the filename
                    os9       I$WritLn            dump out the filename
                    lbcs      L0430
                    lbra      L0145

* parse the path options
* Entry: X=ptr to current char being checked in parameter line
L023A               leax      1,x                 Point to next char
                    lda       ,x                  Get it
                    cmpa      #$20                Space?
                    beq       L025E               Yes, done current parm, return
                    cmpa      #$0D                CR?
                    beq       L025E               Yes, done parm line, return
                    anda      #$DF                make it uppercase
                    cmpa      #'E                 extended directory?
                    beq       L0274
                    cmpa      #'S                 Single entry/line
                    beq       L0270
                    cmpa      #'D                 Directories only
                    beq       L027A
                    cmpa      #'F                 Non-Dirs only
                    beq       L0280
                    cmpa      #'X                 Execution directory
                    beq       L026C
* Curt's additions here
                    cmpa      #'C                 Case insensitve?
                    beq       CaseIns
*--- my additions here
                    cmpa      #'L                 Extended dir
                    beq       L0274
                    cmpa      #'A                 do _all_ files (includes '.' and '..')
                    beq       DoAll
                    bra       L025F

L025E               rts

CaseIns             inc       <u0008              Set case insensitivity ON
                    bra       L023A

L025F               ldd       #$010c              12 lines of text in help
                    leax      >L0505,pc           Point to help message
                    lbsr      L0627               Print it out
                    lbra      L0430

L026C               addb      #EXEC.              add in exec attribute
                    bra       L023A               and get another character

L0270               clr       <u0010              one line/entry
                    bra       L023A

L0274               inc       <u000D              print out all info
                    clr       <u0010              one line/entry
                    bra       L023A

L027A               inc       <u000E              Set directories only flag
                    clr       <u000F              Clear non-directories only flag
                    bra       L023A

L0280               inc       <u000F              Set non-directories only flag
                    clr       <u000E              Clear directories only flag
                    bra       L023A

DoAll               clr       <AllFlag            do all files
                    bra       L023A               and get another character

* Process requested dir/file name from user
* Entry: X=ptr to start of wildcard matching filename
* Exit: u0002=ptr to start of dir name
*       u0006=ptr to start of filename to match (if any)
*
L0286               stx       <u0002              save ptr to start of file/dir name
L0288               lda       ,x+                 Get char from file/dir name
                    cmpa      #'_                 underscore?
                    beq       L0288               skip it
                    cmpa      #'.                 period or under?
                    blo       L02A6               special checks, skip ahead
                    cmpa      #'9                 9?
                    bls       L0288               Below, skip to next char
                    cmpa      #'A                 Between ':' and '@', skip ahead
                    blo       L02A6
                    cmpa      #'Z                 Uppercase letter, skip to next char
                    bls       L0288
                    cmpa      #'a                 Between '[' and "'", skip ahead
                    blo       L02A6
                    cmpa      #'z                 lowercase, skip to next char
                    bls       L0288
L02A6               cmpa      #$0D                cr?
                    beq       L02B2               exit if so
                    cmpa      #$20                space?
                    bne       L02B3               no, go do more checks
                    lda       #$0D                replace space with CR (only 1 file/dirname allowed)
                    sta       ,-x                 save in the parameter area
L02B2               rts

* Special char check
L02B3               cmpa      #'*                 any sequence match wildcard?
                    beq       L02C1               yes, process it
                    cmpa      #'?                 one-character wildcard?
                    beq       L02C1               yes, process it
                    ldb       #E$BNam             Exit with Bad filename error
                    orcc      #1
                    lbra      L0430

L02C1               stx       <u0006              Save pointer to filename match string
L02C3               lda       ,x+                 grab another byte
                    cmpa      #$0D                CR?
                    beq       L02D1               yup, exit
                    cmpa      #$20                space?
                    bne       L02C3               no, skip it
                    lda       #$0D                dump a CR at the end of the filename
                    sta       ,-x
L02D1               ldx       <u0006              Get ptr to start of filename again
L02D3               lda       ,-x                 get the previous character to filename
                    cmpx      <u0002              was dirname ptr?
                    bne       L02E3               no, check for user specified dir separator
                    stx       <u0006              save start of filename
                    leax      >L0449,pc           point to a '.' (current dir)
                    stx       <u0002              save dir pathname
                    bra       L02ED

L02E3               cmpa      #'/                 slash (wildcard is start of filename after dir)?
                    bne       L02D3               no, keep searching back until '/' or start of entry
                    lda       #$0D                Found '/', Put CR over slash
                    sta       ,x+                 (separate dir name from filename)
                    stx       <u0006              Save new wildcard start
L02ED               inc       <u000C              Set wildcards used flag
                    ldx       <u0006              Get wildcard start
L02F1               lda       #$0D                Is current char of wildcard CR?
                    cmpa      ,x
                    beq       L0323               Yes, skip ahead
                    lda       #'*                 wildcard?
                    cmpa      ,x
                    beq       L0301               yes, do it
                    leax      1,x                 otherwise skip the character
                    bra       L02F1

L0301               leay      1,x
                    cmpa      ,y
                    beq       L0311
                    lda       #'?                 one-character wildcard?
                    cmpa      ,y
                    beq       L031B
                    leax      $01,x
                    bra       L02F1

L0311               lda       ,y+
                    sta       -$02,y
                    cmpa      #$0D
                    bne       L0311
                    bra       L02F1

L031B               sta       ,x+
                    lda       #'*                 save a wildcard
                    sta       ,x
                    bra       L02F1

L0323               rts

* Compare current dir entry filename to user specified match filename
* Entry: X=ptr to current filename from dir
*        Y=ptr to wildcard match filename
* Exit: <u0009=0, no match
*            <>1, match
L0324               lda       ,x                  Get char from current dir entry filename

                    bsr       ForcUppr            Change case if needed

                    ldb       ,y                  Get char from user match filename
                    std       <u0015              Save both 1st chars
                    cmpb      #$0D                CR of wildcard?
                    bne       L0334               No, skip ahead
                    cmpa      #$0D                CR of current DIR entry filename?
                    beq       L0362               Yes, matched
                    bra       L0367               No match

L0334               cmpb      #'*                 any char match wildcard?
                    beq       L034A               yes, do it
                    cmpa      #$0D                End of filename from current dir entry?
                    beq       L0367               Yes, flag that filename did NOT match
                    cmpb      #'?                 one-character wildcard?
                    beq       L0344               yes, simply skip over 1 char in both strings
                    cmpb      <u0015              non-wildcard char from user match dir entry?
                    bne       L0367               No, flag no match & return
L0344               leax      1,x                 next up in current dir entry
                    leay      1,y                 next up in wildcard
                    bra       L0324               Continue comparing

L034A               leay      1,y                 Bump up user filename char ptr
                    ldb       ,y                  Get that char from user filename string
                    cmpb      #$0D                End of wildcard match string?
                    beq       L0362               Yes, set flag & return
L0352               cmpb      <u0015              Same as current char from current filename?
                    beq       L0344               Yes, bump both string pointers up and do next chars
                    leax      1,x                 Bump up dir entry char ptr
                    lda       ,x                  Get char
                    cmpa      #$0D                End of filename?
                    beq       L0367               Yes, clear flag and return
                    sta       <u0015              Save char from current dir entry
                    bra       L0352               Try next

* Flag that wildcard compare has a match (so far)
L0362               lda       #$01
                    sta       <u0009
                    rts

* Flag that wildcard compare did NOT match
L0367               clr       <u0009
                    rts

* Change current char in A to uppercase, if <u0008 <>0
ForcUppr            tst       <u0008              Case insensitive?
                    beq       NoChange            No, check char as is
                    cmpa      #'a
                    blo       NoChange            Non-lowercase, check as is
                    cmpa      #'z                 Lowercase?
                    bhi       NoChange            No, check as is
                    anda      #$DF                Force uppercase
NoChange            rts

* Copy default output line information to output line buffer
L036A               leax      >L04D4,pc           Point to default date/attributes string
                    leay      <u0025,u            Point to output line buffer
L0371               lda       ,x+                 Copy until we hit LF
                    cmpa      #$0A
                    beq       L037B
                    sta       ,y+
                    bra       L0371

L037B               leay      <u0026,u            Point to start of output line buffer
                    leax      <u0019,u            Point to file creator's user #
                    ldb       #$02                print out user number, in hex (2 bytes)
L0383               lda       ,x+
                    lbsr      L0409               dump hex ASCII number into 2 bytes @ y
                    decb                          Do 2nd byte
                    bne       L0383
                    leax      <u0026,u            Point to start of user # in output buffer
                    lbsr      L0420               replace leading zeros with spaces
                    leay      <u002C,u            Where ASCII date/time info goes in write buffer
                    leax      <u001B,u            Point to date/time last modified binary data
* Y2k - Treat century as separate #
                    ldb       ,x                  Get year
                    clra                          Century offset starts @ 0
LoopCent            cmpb      #100                Calculate century offset (0-2) into A
                    blo       DoCent
                    inca
                    subb      #100
                    bra       LoopCent

DoCent              tfr       a,b                 Save century offset
                    adda      #19                 actual century offset
                    bsr       L03F8               Convert A to 2 digit century
                    lda       #100
                    mul                           Calculate # of years already accounted for
                    pshs      b                   Save it
                    lda       ,x+                 Get original year back
                    suba      ,s+                 Calculate years left
                    bsr       L03F8               Dump rest of year out
                    leay      1,y                 Skip slash
                    ldb       #2                  We are converting 3 #'s into 2 digit ASCII
L0399               lda       ,x+                 Get binary value
                    bsr       L03F8               dump it out in ASCII
                    leay      1,y                 Skip over when '/'
                    decb
                    bne       L0399
                    lda       ,x+
                    bsr       L03F8               HH
                    lda       ,x
                    bsr       L03F8               MM
* Attributes
                    leay      <u003B,u
                    leax      <u0018,u
                    ldd       #$2D08              hyphen, 8-times
L03B3               lsl       ,x
                    bcs       L03B9
                    sta       ,y                  save hyphen if bit is not set
L03B9               leay      $01,y               go to the next byte
                    decb
                    bne       L03B3               Do all 8 attribute bits
                    leay      <u0045,u            Point to part of output buffer for start sector #
                    leax      <u0074,u            Point to start sector # data
                    ldb       #$03                3 bytes of data to do
L03C6               lda       ,x+                 Convert to hex
                    bsr       L0409
                    decb
                    bne       L03C6
                    leax      <u0045,u
                    bsr       L0420               replace leading 0's with spaces
                    leay      <u004D,u            Point to file size in output buffer
                    leax      <u0021,u            Point to file size data
                    ldb       #$04                4 bytes of data to do
L03DB               lda       ,x+                 Convert to hex
                    bsr       L0409
                    decb
                    bne       L03DB
                    leax      <u004D,u
                    bsr       L0420               replace leading 0's with spaces
                    leax      <u0025,u            Point to output buffer
                    ldy       #$0050              Print line (filename done earlier)
                    lda       #$01
                    os9       I$WritLn
                    bcs       L0430
                    lbra      L0145               Onto next dir entry

* Dump decimal ASCII out for contents of A (2 digit max)
* ,y must contain a '0' for this to work.
L03F8               cmpa      #10                 <10?
                    blo       L0402               Yes, just do one digit
                    inc       ,y                  Bump up 10's counter
                    suba      #10                 Subtract 10 from byte
                    bra       L03F8               Do until 10's digit is done.

L0402               leay      1,y                 Skip to 2nd byte
                    adda      #'0                 add in a zero (for bin to ASCII)
                    sta       ,y+                 Save it & return
                    rts

* Convert binary to hex
* Entry: A=byte to convert to 2 digit hex
*        Y=ptr to 2 byte buffer to hold ASCII HEX chars
L0409               pshs      a                   Save byte
                    lsra                          A=high nibble (shifted down)
                    lsra
                    lsra
                    lsra
                    bsr       L0415               Make digit
                    puls      a                   Restore original
                    anda      #$0F                Mask out high nibble
L0415               adda      #'0                 Convert to ASCII char
                    cmpa      #'9
                    bls       L041D
                    adda      #$07
L041D               sta       ,y+
                    rts

* replace leading zeros with spaces from ASCII sequence, stopping at non-zero
* Entry: X=ptr to string
L0420               ldd       #$3020              Zero & space chars
L0423               cmpa      ,x                  is the first character a zero?
                    bne       L042F               if not, return
                    cmpb      1,x                 is the 2nd character a space?
                    beq       L042F               if '0 ', return without any changes
                    stb       ,x+                 otherwise save space over '0', go onto next char
                    bra       L0423

L042F               rts

L0430               cmpb      #E$EOF
                    bne       L0435
                    clrb                          ignore EOF errors
L0435               tst       <u0010              one file/line?
                    beq       L0446               if so, exit
                    leax      >L044A,pcr          output a CR
                    lda       #$01
                    ldy       #$0001
                    os9       I$WritLn            and then exit
L0446               os9       F$Exit

L0449               fcc       /./
L044A               fcb       $0d
L044B               fcc       /@/
                    fcb       $0d
L044D               fcb       $0a
                    fcc       / Directory of /
L045C               fcb       $0a
                    fcc       /User # Last Modified   Attributes Sector File Size File Name/
                    fcb       $0d
                    fcc       /------ --------------- ---------- ------ --------- ----------/
                    fcb       $0d
L04D4               fcc       '       0000/00/00 0000  dsewrewr'
L04F2               fcc       /                   /
L0505               fcb       $0a
                    fcc       'dir [-opts] [path/patt] [-opts]'
                    fcb       $0d
                    fcc       /opts: x - use current exec dir/
                    fcb       $0d
                    fcc       '      s - one entry/line'
                    fcb       $0d
                    fcc       '    e/l - extended directory'
                    fcb       $0d
                    fcc       /      a - show '.files', too/
                    fcb       $0d
                    fcc       /      d - only directory files/
                    fcb       $0d
                    fcc       /      f - only non-dir files/
                    fcb       $0d
                    fcc       /      c - case insensitive filename match (BUT NOT DIR NAME)/
                    fcb       $0d
                    fcc       /      ? - help message/
                    fcb       $0d
                    fcc       /pattern: may include wild cards/
                    fcb       $0d
                    fcc       /      * - multiple character/
                    fcb       $0d
                    fcc       /      ? - single character/
                    fcb       $0d

* Print several lines of text up to 80 chars each
* Entry: X=Ptr to multi-line text string (CR terminates lines)
*        B=# of lines to write.
L0627               decb                          Dec line counter
                    ldy       #80
                    os9       I$WritLn
                    bcs       L0642               Error writing, return with it
                    pshs      d                   preserve path/line count
                    tfr       y,d                 Move size actually written to D
                    leax      d,x                 Bump source buffer ptr to next line
                    puls      d                   Restore path/line count
                    tstb                          Any lines left to print?
                    beq       L0642               No, exit
                    bra       L0627               Yes, print next line

L0642               rts

                    emod
eom                 equ       *
