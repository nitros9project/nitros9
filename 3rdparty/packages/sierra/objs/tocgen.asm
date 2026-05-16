********************************************************************
* tocgen - Sierra AGI interpreter table of contents module
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2003/01/31  Paul W. Zibaila
* Disassembly of original distribution; added comments from the
* C-modules from dev system disk; currently assembles to the
* duplicate of the original module.
*
* Annotated by /annotate-asm (Claude Code) 2026-05-12:
*   - Renamed disassembled labels to meaningful names
*   - Added inline comments to every instruction
*
********************************************************************
***
***
*** See
***  Section 1 - The C Compiler system
***  Section 2 - Characteristics of Compiled Programs
***  of the Microware C compiler user's guide
***  for interesting info
***  Review the cstart.a
***
********************************************************************
*
*   Definitions from compiler user guide
*   labels defined in the linkage editor
*   used to establish the end addresses of the respective sections
*   etext  - executable text
*   edata  - initialized data
*   end    - uninitialized data
*
*   where is btext defined ???

                    nam       tocgen
                    ttl       program module

* Disassembled 03/01/07 13:59:26 by Disasm v1.6 (C) 1988 by RML

                  IFP1
                    use       defsfile
                  ENDC

* Params
MAXARGS             equ       30        allow for 30 arguments
nfiles              equ       2         stdin and stdout at least
Stk                 equ       nfiles*256+128+256 stdin,stdout,stderr and fudge

* These are probably defined in scfdefs
* C$CR  equ $0D   (defined in scf.d -- local copy removed to avoid duplicate)
C$SPC               equ       $20
* C$COMA equ $2C  (defined in scf.d -- local copy removed to avoid duplicate)
C$DQUt              equ       $22
C$SQUT              equ       $27


* These should be defined somewhere
stdin               equ       0
stdout              equ       1
stderr              equ       2

* These should be defined somewhere
pmode               equ       $0b       r/w for owner, r for others
EPEXEC.             equ       %00100100 mask for public and owner executes



* OS-9 Header info

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
                    mod       eom,name,tylg,atrv,start,size


********************************************************************
*   From cstart.a
*   MAXARGS equ 30 allow for 30 arguments
*
*
*   rob the first dp byte so nothing gets assigned
*   here.  No valid pointer can point to byte zero.
*
* vsect dp
* __$$ fcb 0
* endsect
*
* pushzero is a rma macro not supported by asm used in cstart.a
* pushzero macro
*  clr ,-s clear a byte on the stack
* endm

********************************************************************
btext               equ       .
NullGuard           rmb       1         I think this is the __$$ fcb 0 vsect.
dpsiz               rmb       1
StrmBufBase         rmb       2
StrmBufEnd          rmb       2
StrmFlags           rmb       2
StrmPath            rmb       2
StrmMode            rmb       1
StrmBufSize         rmb       2

StrmStride          rmb       2
ReservedF           rmb       2
Reserved11          rmb       1
StrmTable           rmb       2
StrmDataBuf         rmb       335

*u0020    rmb   5
*u0025    rmb   2
*u0027    rmb   30
*u0043    rmb   2
*u0045    rmb   31
*u0064    rmb   132
*u00E8    rmb   123



*  if I understand how the vsects work in rma
*  the following should be true
*  the following are globally known
*  vsect (from cstart.a)
*  pwz the did fall into place :-)

argv                rmb       2*MAXARGS pointers to args
argc                rmb       2
_sttop              rmb       2

memend              rmb       2         end of memory                      ($01a3)
_flacc              rmb       8         floating point & longs accumulator ($01A5)
_mtop               rmb       2         current non-stack memory top
_stbot              rmb       2         current stack bottom limit
errno               rmb       2         global error holder                ($01b1)

varnum1             rmb       2         ($01b3)
varnum2             rmb       10        ($01b5)
varnum3             rmb       10        ($01bf)
varnum4             rmb       2         ($01c9)
varnum5             rmb       2         ($01cb)
spare               rmb       2         from mem.a                       ($01CD)
end                 equ       .         End of unitialized data          ($01CF)


stack               rmb       Stk
size                equ       .

name                equ       *
                    fcs       /tocgen/            module name
                    fcb       $01       edition byte

********************************************************************
*  Start of code from cstart.a file.
*
*  The movebytes routine
*
* move bytes (Y=From addr, U=To addr, X=Count)
*


movebytes           lda       ,y+       get a byte
                    sta       ,u+       put a byte
                    leax      -1,x      dec the count
                    bne       movebytes and round again
                    rts

_cstart
start               equ       *         _cstart code
                    pshs      y         save top of mem
                    pshs      u         save the data beginning address

*
* This code segment initializes the first 256
* (possible) direct page bytes
*

                    clra                set up to clear
                    clrb                256 bytes
csta05              sta       ,u+       clear dp bytes
                    decb                decrement byte counter
                    bne       csta05    loop until 256 bytes cleared

*
* This code segment sets up to move the
* initialized data from the code section
* to the data area.
*


csta10              ldx       ,s        get the beginning of data address
                    leau      ,x        (tfr x,u)
                    leax      end,x     get the end of bss address
**       leax  >$01CF,x   absolute address of the operand ??
                    pshs      x         save it
                    leay      >etext,pcr point to dp-data count word

*
* now move the initialized direct-page
* data into position.
*

                    ldx       ,y++      get count of dp-data to be moved
                    beq       csta15    bra if none (L003E old label)
                    bsr       movebytes move dp data into position (L0014)

*
* now move the initialized non direct-page
* data into position.
*


                    ldu       $02,s     get beginning address again
csta15              leau      >dpsiz,u  point to where non-dp should start
                    ldx       ,y++      get count of non-dp data to be moved
                    beq       clrbss    (L0049 old label)
                    bsr       movebytes move non-dp data into position

*
*  clear the bss area - starts where the transferred data finishs
*  now clear out the rest of the uninitialized data area.
*

                    clra                clear A for bss zero-fill
clrbss              cmpu      ,s        reached the end ??
                    beq       reldt     if so branch to relocate
                    sta       ,u+       if not end clear it
                    bra       clrbss    and then go again (L0049 old tag)

*
* The linker cannot know the final absolute
* addresses of any data in the data area that
* refers to other data or code.  The next section
* of code will add the base of the text area to
* data pointers pointing to text (data-text references)
* and add the base of the data area to data pointers
* pointing to other data (data-data references).
* The linker leaves a list of the offsets at the end
* object code module.

*
*  now relocate the data-text references
*

reldt               ldu       $02,s     restore to data bottom
                    ldd       ,y++      get the data text ref count
                    beq       reldd     (old tag L005F)

******************************************************************
*  this is interesting
*  from the cstart.a code this line is as follows
*
*    this guy points back to line L0000 but where is it
*    at offset zero of course`
*
*
*        leax  >L0000,pcr  point to text ??? line from disassembly

                    leax      btext,pcr point to text. ---- line from cstart.a
                    lbsr      patch     patch them in (L0162 old tag)

*
*  and now the data-data refs.
*
reldd               ldd       ,y++      get the count of the data refs
                    beq       restack   branch if none (L0068 old tag)
                    leax      ,u        u was already pointing there
                    lbsr      patch     patch them in (L0162 old tag)

******************************************************************
*
*  this restack is slightly diff from the root.a version in the
*  c-compiler code.
*   restack leas 4,s return scratch
*    leay 0,u tfr u,y (base addr of data to y)
*    puls u high end of allocated data area
*    leax 0,s point to parameters


restack             leas      $04,s     reset stack
                    puls      x         restore 'memend'
                    stx       >memend,u save memory end pointer into data area

******************************************************************
*
* process the params
* the stack pointer is back where it started so is
* pointing at the params
*
* the objective is to insert null chars at the end of each argument
* and fill in the argv vector with pointers to them

* first store the program name address
* (an extra name inserted here for just this purpose
* - undocumented as yet)

                    sty       >argv,u   store program name ptr in argv[0]
                    ldd       #$0001    at least one arg
                    std       >argc,u   initialize argc to 1
                    leay      >argv+2,u point y at second slot
                    leax      ,s        point X at OS9 parameter area
                    lda       ,x+       fetch first character of params

aloop               ldb       >argc+1,u load current arg count low byte
                    cmpb      #MAXARGS-1 about to overflow ??
                    beq       final     branch out

aloop10             cmpa      #C$CR     is it the EOL?
                    beq       final     yep - reached end of the list
                    cmpa      #C$SPC    is it a space
                    beq       aloop20   yep go for the next one
                    cmpa      #C$COMA   is it a comma ?
                    bne       aloop30   no - then a word has started

aloop20             lda       ,x+       yes it's a comma bump to next char
                    bra       aloop10   and loop again

aloop30             cmpa      #C$DQUT   a quoted string (")
                    beq       aloop40   yep - go process it
                    cmpa      #C$SQUT   a quoted string (')
                    bne       aloop60   not quotes double or single move on

aloop40             stx       ,y++      save the address in vector
                    inc       >argc+1,u bump up the arg count
                    pshs      a         save the delim char

qloop               lda       ,x+       get the next char
                    cmpa      #C$CR     EOL?
                    beq       aloop50   go clean up
                    cmpa      ,s        is it a delim char
                    bne       qloop     no then lop to the next

aloop50             puls      b         pop saved delimiter off stack
                    clr       -$01,x    null-terminate this arg
                    cmpa      #C$CR     was it end-of-line?
                    beq       final     yes — done parsing args
                    lda       ,x+       skip delimiter, get next char
                    bra       aloop     loop for more args

aloop60             leax      -$01,x    back up to first char of token
                    stx       ,y++      store pointer in argv vector
                    leax      $01,x     advance past first char
                    inc       >argc+1,u increment arg count

* at least one none space character has been seen
aloop70             cmpa      #C$CR     Have
                    beq       loopend   we
                    cmpa      #C$SPC    reached
                    beq       loopend   the end
                    cmpa      #C$COMA   comma?
                    beq       loopend   look some more
                    lda       ,x+       get next character
                    bra       aloop70   keep scanning token

loopend             clr       -$01,x    null-terminate the token
                    bra       aloop     scan for next arg

*`
* Now put the pointers on the stack
*
final               leax      >argv,u   get the address of the arg vector
                    pshs      x         goes on the stack first
                    ldd       >argc,u   get the arg count

                    pshs      b,a       push argc onto stack for main()
*        pshs  d          push it on the stack

                    leay      ,u        set Y = data base pointer (C convention)
*                         see note above in restack
*
*    end of argv and argc processing
*
*****************************************************
*
* Registers at this point:
*
*    X = Pointer to parameter area
*    U = Pointer to top of data allocated
*        by the linker.
*    Y = Pointer to bottom of data area
*   DP = Same as high byte of Y-reg
*
* The linker has adjusted
* all non-direct-page data references to reflect
* the data memory as we have set up here.  The
* data-index register choice here is arbitrary,
* but must be used consistently.  To maintain
* compatability with code produced by the C compiler,
* the Y register is used here as the data pointer.


*******************************************************
*
*    go set up variables for stack size and such
*
                    bsr       _fixtop   set various variables

*******************************************************
*
*    go to the main event
*
                    lbsr      main      call our program

*  clean up and bit and out we go

                    clr       ,-s       pushzero clear a byte on the stack
                    clr       ,-s       pushzero clear a byte on the stack
                    lbsr      exit      and a dummy return address
*  should never return here


********************************************************
*
*
*

_fixtop             leax      end,y     get the initial memeory end
*                         (unitilaized data "bss"address)
                    stx       _mtop,y   its the current memory top
                    sts       _sttop,y  this is really two bytes short
                    sts       _stbot,y  save initial stack bottom limit
                    ldd       #-126     breathing room below stack

*        stx   >$01AD,y   ---- disassembly
*        sts   >$01A1,y   ---- disassembly
*        sts   >$01AF,y   ---- disassembly
*        ldd   #$FF82     ---- disassembly

_stkchec
_stkcheck
                    leax      d,s       calculate the requested size
                    cmpx      _stbot,y  is it lower than already reserved?
*        bcc   stk10      ---- disassembly
                    bhs       stk10     no -return
                    cmpx      _mtop,y   is it lower than possible?
*        bcs   ftserr     ---- disassembly
                    blo       fsterr    yes - can't cope
                    stx       _stbot,y  no - reserve it
stk10               rts

*  Stackover flow string
fixserr             fcc       %**** STACK OVERFLOW ****%
                    fcb       $0D

*  Stackover flow error processing
* entry:
*       a -> path to write
*       b -> mem full error
*       x -> address of data to be written
*       y -> maximum #of bytes message length
*       s -> b pushed to preserve the mem full error
*            since the I$WritLn returns it error code in b
* exit:
*       u - unchanged
*       y - number of bytes written
*       s-> popped back to prior to entry
*
* error: (I$writLn)
*       CC -> Carry set
*       b  -> error code
*

fsterr              leax      <fixserr,pcr load x wit address of error strin
                    ldb       #E$MEMFUL load b with the error code number

erexit              pshs      b         stack the error number
                    lda       #stderr   set path to standard error output
                    ldy       #$0064    set size more than needed
                    os9       I$WritLn  write it
*                            pop the error code back
                    clr       ,-s       pushzero clear MSB of status
                    lbsr      _exit     and out
* no return here

* stacksize()
* returns the extent of stack requested
* can be used by programmer for guidance
* in sizing memory at compile time

stacksiz
                    ldd       _sttop,y  top of stack on entry
                    subd      _stbot,y  subtract current reserved limit
                    rts


* freemem()
* returns the current size of the free memory area
*

freemem
                    ldd       _stbot,y  load current stack bottom limit
                    subd      _mtop,y   subtract heap top → free memory size
                    rts                 return free bytes in D



* patch - adjust initialised data which refer to memory locations.
* entry:
*       y -> list of offsets in the data area to be patched
*       u -> base of data
*       x -> base of either text or data area as appropriate
*       d =  count of offsets in the list
*
* exit:
*       u - unchanged
*       y - past the last entry in the list
*       x and d mangled

patch               pshs      x         save the base
                    leax      d,y       half way up the list
                    leax      d,x       top of list
                    pshs      x         save it as place to stop

* we do not come to this routine with
* a zero count (check!) so a test at the loop top
* is unnecessary

patch10             ldd       ,y++      get the offset
                    leax      d,u       point to location
                    ldd       ,x        get the relative reference
                    addd      2,s       add in the base
                    std       ,x        store the absolute reference
                    cmpy      ,s        reached the top?
                    bne       patch10   no - round again

                    leas      4,s       reset the stack
                    rts                 and return




main                pshs      u         save frame pointer
                    ldd       #$FD57    required stack depth for main()
                    lbsr      _stkcheck check for sufficient stack available:

                    leas      >-$025D,s allocate 605-byte local frame
                    ldd       >$0261,s  load argc from stack
                    cmpd      #$0002    looks like we check for two args
                    beq       gotargs   if good number go
                    ldd       [>$0263,s] load argv[0] (program name)
                    pshs      b,a       push for printf
                    leax      >usemsg,pcr load address of usage message
                    pshs      x         push it on the stack

                    lbsr      PrintfEntry
                    leas      $04,s     clean up stack
                    clra                clear the exit codes
                    clrb                from d
                    pshs      b,a       push it on the stack
                    lbsr      exit


                    leas      $02,s     (dead — exit doesn't return)

gotargs             leax      >OpenReadFlag,pcr push "r" mode string
                    pshs      x
                    ldx       >$0265,s  load argv pointer
                    ldd       $02,x     get argv[1] (input filename)
                    pshs      b,a       push filename for fopen
                    lbsr      FopenWrapper
                    leas      $04,s     pop fopen args
                    std       >$025B,s  save input FILE*
                    bne       ArgCountOk branch if fopen succeeded
                    ldx       >$0263,s  load argv for error message
                    ldd       $02,x     get argv[1]
                    pshs      b,a       push filename
                    leax      >cntread,pcr Load address can't open for reading message
                    pshs      x
                    lbsr      PrintfEntry
                    leas      $04,s
                    clra
                    clrb
                    pshs      b,a       push exit code 0
                    lbsr      exit

                    leas      $02,s     (dead — exit doesn't return)
ArgCountOk          clra
                    clrb
                    std       >$0082,s  init entry count to 0
                    lslb
                    rola                D = entry_count * 2 (word index)
                    leax      ,s        base of local frame
                    leax      d,x       point into disk-side table
                    clra
                    clrb
                    std       ,x        zero first table slot
                    leax      >$0084,s  address of output buffer in frame
                    stx       >$0255,s  save output write pointer
                    lbra      ReadTOCLine begin reading TOC input

AdvanceDiskScan     ldd       >$0257,s  load current scan pointer
                    addd      #$0001    advance one character
                    std       >$0257,s  store updated scan pointer
CheckDiskLetter     ldb       [>$0257,s] read character at scan pointer
                    cmpb      #C$CR     end of line?
                    beq       ParseDiskDigit yes — treat as implicit disk token
                    ldb       [>$0257,s] re-read character
                    cmpb      #$64      'd (lowercase d = disk)?
                    beq       ParseDiskDigit yes — found disk letter
                    ldb       [>$0257,s] re-read character
                    cmpb      #$44      'D (uppercase D = disk)?
                    bne       AdvanceDiskScan not D/d — keep scanning
ParseDiskDigit      ldb       [>$0257,s] read char following disk letter
                    cmpb      #C$CR     end of line?
                    beq       MissingDiskNumErr yes — disk number absent
                    ldd       >$0257,s  load scan pointer
                    addd      #$0001    advance past disk letter
                    std       >$0257,s  store updated pointer
                    pshs      b,a       push pointer for AtoI
                    lbsr      AtoI      convert ASCII digits to integer
                    leas      $02,s     pop argument
                    ldx       >$0255,s  load output write pointer
                    leax      $01,x     advance one byte
                    stx       >$0255,s  store updated output pointer
                    stb       -$01,x    store disk number byte to output
                    bra       CheckSideLetter now scan for side letter

MissingDiskNumErr   leax      >$0204,s  load address buffer for printf
                    pshs      x
                    leax      >dsknmsg,pcr Load address of disk number ?? mising
                    pshs      x
                    lbsr      PrintfEntry
                    leas      $04,s
                    clra
                    clrb
                    pshs      b,a       exit code 0
                    lbsr      exit
                    leas      $02,s     (dead)
                    bra       CheckSideLetter
AdvanceSideScan     ldd       >$0257,s  load scan pointer
                    addd      #$0001    advance one character
                    std       >$0257,s  store updated pointer
CheckSideLetter     ldb       [>$0257,s] read char at scan pointer
                    cmpb      #C$CR     end of line?
                    beq       ParseSideDigit yes — implicit side token
                    ldb       [>$0257,s] re-read character
                    cmpb      #$73      's (lowercase side)?
                    beq       ParseSideDigit yes — found side letter
                    ldb       [>$0257,s] re-read character
                    cmpb      #$53      'S (uppercase side)?
                    bne       AdvanceSideScan not S/s — keep scanning
ParseSideDigit      ldb       [>$0257,s] read char following side letter
                    cmpb      #C$CR     end of line?
                    beq       MissingSideErr yes — side number absent
                    ldd       >$0257,s  load scan pointer
                    addd      #$0001    advance past side letter
                    std       >$0257,s  store updated pointer
                    pshs      b,a       push pointer for AtoI
                    lbsr      AtoI      convert side number string to integer
                    leas      $02,s     pop argument
                    stb       >$025A,s  save parsed side number
                    cmpb      #$01      is it side 1?
                    beq       ValidSideNum yes — valid
                    ldb       >$025A,s  reload side number
                    cmpb      #$02      is it side 2?
                    bne       InvalidSideErr no — error
ValidSideNum        ldb       >$025A,s  load validated side number
                    ldx       >$0255,s  load output write pointer
                    leax      $01,x     advance one byte
                    stx       >$0255,s  store updated output pointer
                    stb       -$01,x    store side byte to output
                    bra       AfterSideNum continue to volume scan
InvalidSideErr      leax      >$0204,s  load address buffer for printf
                    pshs      x
                    leax      >invside,pcr load address of the invalid side message
                    bra       PrintErrExit
MissingSideErr      leax      >$0204,s  load address buffer for printf
                    pshs      x
                    leax      >snmiss,pcr load address of side number missing mesg
PrintErrExit        pshs      x         push error message address
                    lbsr      PrintfEntry
                    leas      $04,s     pop printf args
                    clra
                    clrb
                    pshs      b,a       exit code 0
                    lbsr      exit
                    leas      $02,s     (dead)
AfterSideNum        clra
                    clrb
                    stb       >$0259,s  clear volume-found flag
                    bra       VolScanLoop skip to loop entry
AdvanceVolScan      ldd       >$0257,s  load scan pointer
                    addd      #$0001    advance one character
                    std       >$0257,s  store updated pointer
CheckVolLetter      ldb       [>$0257,s] read char at scan pointer
                    cmpb      #C$CR     end of line?
                    beq       ParseVolDigit yes — treat as implicit volume token
                    ldb       [>$0257,s] re-read char for lowercase 'v' check
                    cmpb      #$76      'v' ?
                    beq       ParseVolDigit yes — parse volume number
                    ldb       [>$0257,s] re-read char for uppercase 'V' check
                    cmpb      #$56      'V' ?
                    bne       AdvanceVolScan no — keep scanning
ParseVolDigit       ldb       [>$0257,s] read char after volume letter
                    cmpb      #C$CR     end of line (no digit follows)?
                    beq       CheckVolFound yes — check if volume was found
                    ldd       >$0257,s  load pointer to volume digit
                    addd      #$0001    advance past volume letter
                    std       >$0257,s  store updated pointer
                    pshs      b,a       push pointer for AtoI
                    lbsr      AtoI      parse ASCII integer from string
                    leas      $02,s     discard pointer arg
                    ldx       >$0255,s  load output buffer write pointer
                    leax      $01,x     advance write pointer by one
                    stx       >$0255,s  store updated write pointer
                    stb       -$01,x    store parsed volume number in buffer
                    ldd       #$0001    set found flag = 1
                    stb       >$0259,s  mark volume as found
                    bra       VolScanLoop continue scanning
VolScanLoop         ldb       [>$0257,s] read char at scan pointer
                    cmpb      #C$CR     end of line?
                    bne       CheckVolLetter no — check for volume letter
CheckVolFound       ldb       >$0259,s  load volume-found flag
                    bne       ArgsParseDone non-zero — args successfully parsed
                    leax      >$0204,s  pointer to line buffer for error message
                    pshs      x         push line buffer pointer
                    leax      >vnmiss,pcr load address of volume missing mesg
                    pshs      x         push format string
                    lbsr      PrintfEntry print "volume number missing" error
                    leas      $04,s     discard printf args
                    clra                clear exit code high byte
                    clrb                clear exit code low byte
                    pshs      b,a       push exit(0)
                    lbsr      exit      head out

                    leas      $02,s     (dead — never reached)
ArgsParseDone       ldx       >$0255,s  load end of volume buffer
                    ldb       -$01,x    read last byte stored (final volume)
                    sex                 sign-extend B to D
                    orb       #$80      set high bit to mark end of list
                    stb       -$01,x    store back end-of-list sentinel
                    ldd       >$0082,s  load total arg count
                    addd      #$0001    increment arg count
                    std       >$0082,s  store updated arg count
                    lslb                multiply arg count × 2 (low byte)
                    rola                multiply arg count × 2 (high byte)
                    leax      ,s        base of stack frame
                    leax      d,x       point to arg slot at stack + 2*count
                    pshs      x         push pointer to arg slot
                    leax      >$0086,s  load second parameter address
                    pshs      x         push it
                    ldd       >$0259,s  load volume scan position
                    subd      ,s++      subtract arg slot pointer (pop)
                    std       [,s++]    store result indirect (pop)
ReadTOCLine         ldd       >$025B,s  load input FILE* stream
                    pshs      b,a       push FILE* arg
                    ldd       #$0051    buffer size = 81 chars
                    pshs      b,a       push size arg
                    leax      >$0208,s  address of line input buffer
                    pshs      x         push buffer pointer
                    lbsr      FGetsEntry read one line from TOC file
                    leas      $06,s     discard three args
                    std       >$0257,s  save fgets result (NULL = EOF)
                    lbne      CheckDiskLetter if got a line, parse it
                    clra                EOF — set return value high = 0
                    clrb                EOF — set return value low = 0
                    bra       BuildEntryNext advance past entry loop
BuildEntryLoop      ldd       >$0080,s  load current entry index
                    lslb                multiply index × 2 (low)
                    rola                multiply index × 2 (high)
                    leax      ,s        base of stack
                    leax      d,x       point to entry slot = stack + 2*index
                    ldd       ,x        load pointer from entry slot
                    pshs      x,b,a     save slot address and loaded pointer
                    ldd       >$0086,s  load arg buffer base pointer
                    lslb                multiply × 2 (low)
                    rola                multiply × 2 (high)
                    addd      ,s++      add saved slot address, pop X
                    std       [,s++]    write result indirect through saved D, pop
                    ldd       >$0080,s  reload current entry index
                    addd      #$0001    increment index
BuildEntryNext      std       >$0080,s  store updated index
                    ldd       >$0080,s  reload index for comparison
                    cmpd      >$0082,s  compare to total arg count
                    bcs       BuildEntryLoop if more entries remain, keep looping
                    ldd       >$025B,s  load input FILE*
                    pshs      b,a       push FILE* arg
                    lbsr      FClose    close input TOC file
                    leas      $02,s     discard arg
                    leax      >OpenWriteFlag,pcr point to "w" open mode string
                    pshs      x         push mode arg
                    leax      >dpsiz,y  point to output filename (from data segment)
                    pshs      x         push filename arg
                    lbsr      FopenWrapper open output file for writing
                    leas      $04,s     discard fopen args
                    std       >$025B,s  save output FILE*
                    bne       OpenOutputFile non-null — file opened OK

                    leax      >dpsiz,y  load output filename for error message
                    pshs      x         push filename arg
                    leax      >cntwrit,pcr load address of can't write mesg
                    pshs      x         push format string
                    lbsr      PrintfEntry print "can't open for writing" error
                    leas      $04,s     discard args
                    clra                clear exit code high byte
                    clrb                clear exit code low byte
                    pshs      b,a       push exit(0)
                    lbsr      exit      terminate with error

                    leas      $02,s     (dead — never reached)
OpenOutputFile      ldd       >$025B,s  load output FILE*
                    pshs      b,a       push FILE* arg
                    ldd       >$0084,s  load TOC entry count
                    pshs      b,a       push count arg
                    lbsr      egg2      write TOC header record
                    leas      $04,s     discard args
                    cmpd      #$FFFF    check for write error
                    beq       WriteErrExit error — report and exit
                    ldd       >$025B,s  reload output FILE*
                    pshs      b,a       push FILE* arg
                    ldd       #$0001    item count = 1
                    pshs      b,a       push count arg
                    ldd       >$0086,s  load number of entries
                    lslb                multiply by 2 (low byte) for byte length
                    rola                multiply by 2 (high byte)
                    pshs      b,a       push byte length
                    leax      $06,s     address of TOC data buffer on stack
                    pshs      x         push buffer pointer
                    lbsr      FWriteEntry write first TOC chunk to output file
                    leas      $08,s     discard four args
                    std       -$02,s    save write result
                    beq       WriteErrExit zero bytes written — write error
                    ldd       >$025B,s  reload output FILE*
                    pshs      b,a       push FILE* arg
                    ldd       #$0001    item count = 1
                    pshs      b,a       push count arg
                    leax      >$0088,s  address of second TOC data block
                    pshs      x         push buffer pointer
                    ldd       >$025B,s  load FILE* for size calculation
                    subd      ,s++      subtract buffer pointer (pop), get byte count
                    pshs      b,a       push computed byte count
                    leax      >$008A,s  address of output area for second block
                    pshs      x         push destination pointer
                    lbsr      FWriteEntry write second TOC chunk to output file
                    leas      $08,s     discard four args
                    std       -$02,s    save write result
                    bne       CleanExit success — proceed to clean exit
WriteErrExit        leax      >dpsiz,y  load output filename for error message
                    pshs      x         push filename arg
                    leax      errwrit,pcr load address of error writing mesg
                    pshs      x         push format string
                    lbsr      PrintfEntry print "error writing" message
                    leas      $04,s     discard args
                    clra                clear exit code high byte
                    clrb                clear exit code low byte
                    pshs      b,a       push exit(0)
                    lbsr      exit      terminate with write error

                    leas      $02,s     (dead — never reached)
CleanExit           ldd       >$025B,s  load output FILE*
                    pshs      b,a       push FILE* arg
                    lbsr      FClose    close output file
                    leas      $02,s     discard arg
                    clra                exit code high = 0
                    clrb                exit code low = 0
                    pshs      b,a       push exit(0)
                    lbsr      exit      terminate successfully
                    leas      $02,s     (dead — never reached)
                    leas      >$025D,s  deallocate main stack frame
                    puls      pc,u      restore frame pointer and return

usemsg              fcc       /Usage: %s pathlist/ c-string
                    fcb       $00       null terminator c-string


OpenReadFlag        fcb       $72,$00   what am I

cntread             fcc       /Can't open %s for reading./ c-string
                    fcb       C$CR,$00  cr and null term

dsknmsg             fcc       /Disk number missing:/ c-string
                    fcb       C$CR      with a cr embedded
                    fcc       /%s/                c-string
                    fcb       $00       null terminator c-string

invside             fcc       /Invalid side number:/
                    fcb       C$CR
                    fcc       /%s/
                    fcb       $00

snmiss              fcc       /Side number missing:/
                    fcb       C$CR
                    fcc       /%s/
                    fcb       $00

vnmiss              fcc       /Volume number missing:/
                    fcb       C$CR
                    fcc       /%s/
                    fcb       $00

OpenWriteFlag       fcb       $77,$00   what am i

cntwrit             fcc       /Can't open %s for writing./
                    fcb       C$CR,$00


errwrit             fcc       /Error writing %s./
                    fcb       C$CR
                    fcb       $00


*                      the null actually terminates the above string
*L0578    fcb   $00    same code frag as egg2 calls into
*L0579    fcb   $34
*         neg   <u0034 dis assembled as "3440" disassembled as
*         nega

egg1                pshs      u         ***  pshs u incorrectly decoded

ScanStreamStart     leau      >StrmTable,y point U to first stream table entry
ScanStreamLoop      ldd       StrmFlags,u load mode flags for this stream slot
                    clra                ignore high byte
                    andb      #$03      keep only read/write mode bits
                    lbeq      ReturnStreamPtr mode == 0 — this slot is free, return it
                    leau      StrmStride,u advance U to next stream entry
                    pshs      u         push current U for boundary check
                    leax      >$00E2,y  X = one past end of stream table
                    cmpx      ,s++      compare table-end to current U (pop)
                    bhi       ScanStreamLoop still within table — keep scanning
                    ldd       #E$PthFul no free slots — path table full error
                    std       >errno,y  store error code in errno
                    lbra      ReturnNullStream return NULL to caller
                    puls      pc,u      (dead — never reached)

GetOrAllocStream    pshs      u         save U (frame pointer)
                    ldu       $08,s     load caller's stream pointer arg
                    bne       StreamFound non-NULL — use supplied stream
                    bsr       egg1      ***  pshs u incorrectly decoded
                    tfr       d,u       move allocated stream pointer to U
StreamFound         stu       -$02,s    save stream pointer as local
                    beq       ReturnNullStream NULL result — allocation failed
                    ldd       $04,s     load path number from caller arg
                    std       StrmPath,u store path in stream struct
                    ldx       $06,s     load mode string pointer
                    ldb       $01,x     read second char of mode string
                    cmpb      #$2B      '+' (update/append mode flag)?
                    beq       SetRWFlags yes — set read+write
                    ldx       $06,s     reload mode string pointer
                    ldb       $02,x     read third char of mode string
                    cmpb      #$2B      '+' in position 2?
                    bne       ParseModeStr no — parse mode char normally
SetRWFlags          ldd       StrmFlags,u load current stream flags
                    orb       #$03      set both read and write bits
                    bra       StoreModeFlags apply combined flags
ParseModeStr        ldd       StrmFlags,u load current flags for OR
                    pshs      b,a       save current flags on stack
                    ldb       [<$08,s]  read first char of mode string
                    cmpb      #$72      'r' (read mode)?
                    beq       SetReadMode yes — read-only
                    ldb       [<$08,s]  re-read first mode char
                    cmpb      #$64      'd' (delete/read mode)?
                    bne       SetWriteMode no — default to write
SetReadMode         ldd       #$0001    read flag = bit 0
                    bra       OrFlagsHigh merge into saved flags
SetWriteMode        ldd       #$0002    write flag = bit 1
OrFlagsHigh         ora       ,s+       OR high byte with saved, pop A
OrFlagsLow          orb       ,s+       OR low byte with saved, pop B
StoreModeFlags      std       StrmFlags,u write combined mode flags to stream
                    ldd       StrmBufBase,u load buffer base address
                    addd      StrmBufSize,u add buffer size to get end address
                    std       StrmBufEnd,u store buffer end pointer
                    std       ,u        also update current buffer pointer
ReturnStreamPtr     tfr       u,d       return stream pointer in D
                    puls      pc,u      restore U and return

ReturnNullStream    clra                return NULL high byte
                    clrb                return NULL low byte
                    puls      pc,u      restore U and return

FOpenMode           pshs      u         save U (frame pointer)
                    ldu       $04,s     load data pointer from arg
                    leas      -$04,s    allocate 4 bytes local storage
                    clra                clear open-mode high byte
                    clrb                clear open-mode low byte
                    std       ,s        initialize mode storage to zero
                    ldx       $0A,s     load mode string pointer from arg
                    ldb       $01,x     read first mode character
                    sex                 sign-extend B to D
                    tfr       d,x       move mode char value to X
                    bra       CheckModeCode go check mode character
CheckOpenMode2      ldx       $0A,s     reload mode string pointer
                    ldb       $02,x     read second mode character
                    cmpb      #$2B      '+' (update/r+w mode)?
                    bne       OpenModeOfs4 no — use offset 4
                    ldd       #$0007    mode offset = 7 (read+write+update)
                    bra       StoreOpenMode store mode and proceed
OpenModeOfs4        ldd       #$0004    mode offset = 4 (exclusive)
                    bra       StoreOpenMode store and proceed
OpenModeOfs3        ldd       #$0003    mode offset = 3 (exclusive write)
StoreOpenMode       std       ,s        store computed open mode
                    bra       GetAccessChar go parse access character
JumpFOpenPath       leax      $04,s     compute cleanup pointer
                    lbra      FOpenFail jump to failure path
CheckModeCode       stx       -$02,s    save mode char in local
                    beq       GetAccessChar NUL → default access
                    cmpx      #$0078    'x' (exclusive mode)?
                    beq       CheckOpenMode2 yes — check for '+' update
                    cmpx      #$002B    '+' (update directly)?
                    beq       OpenModeOfs3 yes — use offset 3
                    bra       JumpFOpenPath unknown mode char — fail
GetAccessChar       ldb       [<$0A,s]  read first character of mode string
                    sex                 sign-extend B to D
                    tfr       d,x       move access char value to X
                    lbra      DispatchOpenMode dispatch on access character
OpenReadMode        ldd       ,s        load open mode word
                    orb       #$01      set read-access bit
                    bra       OpenWithFlags open file with read flags
OpenAppendMode      ldd       ,s        load open mode word
                    orb       #$02      set write/append-access bit
                    pshs      b,a       push flags
                    pshs      u         push filename pointer
                    lbsr      open      try to open existing file
                    leas      $04,s     discard two args
                    std       $02,s     save file descriptor
                    cmpd      #$FFFF    open failed?
                    beq       CreateAppendFile yes — create the file instead
                    ldd       #$0002    seek relative = SEEK_END
                    pshs      b,a       push seek mode
                    clra                seek offset high word = 0
                    clrb                seek offset high word low byte = 0
                    pshs      b,a       push high word of offset
                    pshs      b,a       push low word of offset (0)
                    ldd       $08,s     load file descriptor
                    pshs      b,a       push fd
                    lbsr      lseek     seek to end of file
                    leas      $08,s     discard four args
                    bra       ReturnFD  return file descriptor
CreateAppendFile    ldd       ,s        load open mode word
                    orb       #$02      set write bit for create
                    pshs      b,a       push flags
                    pshs      u         push filename pointer
                    lbsr      creat     create new file
                    bra       AfterOpenCreat merge with open path
OpenDeleteMode      ldd       ,s        load open mode word
                    orb       #$81      set delete-on-close flag
OpenWithFlags       pshs      b,a       push open flags
                    pshs      u         push filename pointer
                    lbsr      open      open file with given flags
AfterOpenCreat      leas      $04,s     discard two args
                    std       $02,s     save file descriptor
                    bra       ReturnFD  return fd
FOpenFail           leas      -$04,x    restore stack from X
SetErrnoInval       ldd       #$00CB    errno = E$BPath (invalid path)
                    std       >errno,y  store in errno
                    clra                return NULL high byte
                    clrb                return NULL low byte
                    bra       CleanStackReturn clean up and return
DispatchOpenMode    cmpx      #$0072    'r' (read)?
                    lbeq      OpenReadMode yes — read mode
                    cmpx      #$0061    'a' (append)?
                    lbeq      OpenAppendMode yes — append mode
                    cmpx      #$0077    'w' (write/create)?
                    beq       CreateAppendFile yes — create/truncate
                    cmpx      #$0064    'd' (delete)?
                    beq       OpenDeleteMode yes — delete mode
                    bra       SetErrnoInval unknown access char — fail
ReturnFD            ldd       $02,s     load file descriptor to return
CleanStackReturn    leas      $04,s     deallocate locals
                    puls      pc,u      restore U and return
                    pshs      u         (dead code — never reached)
                    clra                (dead)
                    clrb                (dead)
                    pshs      b,a       (dead)
                    ldd       $08,s     (dead)
                    pshs      b,a       (dead)
                    ldd       $08,s     (dead)
                    pshs      b,a       (dead)
                    lbra      AllocStreamCall (dead)
FopenWrapper        pshs      u         save U (frame pointer)
                    ldd       $06,s     load mode string pointer from caller
                    pshs      b,a       push mode pointer arg
                    ldd       $06,s     reload mode string pointer
                    pshs      b,a       push mode pointer arg (second copy)
                    lbsr      FOpenMode call fopen mode dispatcher
                    leas      $04,s     discard two args
                    tfr       d,u       move file descriptor to U
                    cmpu      #$FFFF    open failed?
                    bne       FopenAfterOpen no — proceed with stream setup
                    clra                return NULL high byte
                    clrb                return NULL low byte
                    bra       FopenReturn return NULL on failure
FopenAfterOpen      clra                clear stream-search high byte
                    clrb                clear stream-search low byte
                    bra       FopenSetup jump to stream allocation
                    pshs      u         (dead — alternate re-open path)
                    ldd       $08,s     (dead)
                    pshs      b,a       (dead)
                    lbsr      FClose    (dead)
                    leas      $02,s     (dead)
                    ldd       $06,s     (dead)
                    pshs      b,a       (dead)
                    ldd       $06,s     (dead)
                    pshs      b,a       (dead)
                    lbsr      FOpenMode (dead)
                    leas      $04,s     (dead)
                    tfr       d,u       (dead)
                    stu       -$02,s    (dead)
                    bge       FopenContinue (dead)
                    clra                (dead)
                    clrb                (dead)
                    bra       FopenReturn (dead)
FopenContinue       ldd       $08,s     load stream arg for allocation
FopenSetup          pshs      b,a       push stream base for GetOrAllocStream
                    ldd       $08,s     load stream arg
                    pshs      b,a       push stream arg
                    pshs      u         push file descriptor
AllocStreamCall     lbsr      GetOrAllocStream allocate or associate stream
                    leas      $06,s     discard three args
FopenReturn         puls      pc,u      restore U and return
                    pshs      u,b,a     (dead — unreachable after puls pc,u)
                    ldu       $06,s     (dead)
                    bra       GetCharLoop (dead)
StoreByte           ldd       ,s        reload last character value
                    stb       ,u+       store char to output buffer, advance U
GetCharLoop         leax      >StrmTable,y point X to stream table
                    pshs      x         push stream pointer
                    lbsr      FGetCharFill read next character from stream
                    leas      $02,s     discard stream arg
                    std       ,s        save character result on stack
                    cmpd      #$000D    is it carriage return?
                    beq       CheckGetChar yes — check for CR handling
                    ldd       ,s        reload result
                    cmpd      #$FFFF    is it EOF?
                    bne       StoreByte not EOF — store char and continue
CheckGetChar        ldd       ,s        reload result
                    cmpd      #$FFFF    is it EOF?
                    bne       GotChar   no — got the CR char
                    clra                EOF — return 0 high byte
                    clrb                EOF — return 0 low byte
                    bra       GetCharReturn return EOF indicator
GotChar             clra                clear high byte of result
                    clrb                clear low byte
                    stb       ,u        NUL-terminate buffer at current position
                    ldd       $06,s     load return value (buffer pointer)
GetCharReturn       leas      $02,s     discard saved char local
                    puls      pc,u      restore U and return

FGetsEntry          pshs      u         save U (frame pointer)
                    ldu       $06,s     load FILE* stream pointer from arg
                    leas      -$04,s    allocate 4 bytes local storage
                    ldd       $08,s     load dest buffer pointer
                    std       ,s        save buffer write pointer as local
                    bra       CheckRemaining enter loop at boundary check
FGetsBufStore       ldd       $02,s     load last char read
                    ldx       ,s        load current write pointer
                    leax      $01,x     advance write pointer by one
                    stx       ,s        store updated write pointer
                    stb       -$01,x    store char before advanced pointer
                    cmpb      #C$CR     was it a CR?
                    beq       NullTermBuf yes — line complete, terminate
CheckRemaining      tfr       u,d       copy current position to D
                    leau      -dpsiz,u  back up U by dpsiz (update stream pos)
                    std       -$02,s    save remaining byte count
                    ble       NullTermBuf zero or less — buffer full
                    ldd       $0C,s     load stream pointer for next read
                    pshs      b,a       push stream arg
                    lbsr      FGetCharFill read next character
                    leas      $02,s     discard arg
                    std       $02,s     save char result
                    cmpd      #$FFFF    EOF?
                    bne       FGetsBufStore no — store char and loop
NullTermBuf         clra                clear high byte
                    clrb                clear low byte
                    stb       [,s]      NUL-terminate buffer at write pointer
                    ldd       $02,s     load last char read
                    cmpd      #$FFFF    was it EOF?
                    bne       FGetsSuccess no — return buffer pointer
                    clra                EOF — return NULL high byte
                    clrb                EOF — return NULL low byte
                    bra       ReturnCount return zero/null
FGetsSuccess        ldd       $08,s     return dest buffer pointer
ReturnCount         leas      $04,s     deallocate locals
                    puls      pc,u      restore U and return

FWriteEntry         pshs      u         save U (frame pointer)
                    ldu       $04,s     load FILE* stream pointer from arg
                    leas      -$04,s    allocate 4 bytes locals (written count)
                    clra                clear outer loop index high byte
                    clrb                clear outer loop index low byte
                    bra       FWriteOuterUpdate enter outer loop at update step
FWriteInit          clra                clear inner count high byte
                    clrb                clear inner count low byte
                    std       ,s        init inner written count to zero
                    bra       FWriteIncCount enter inner loop at count check
FWriteCharLoop      ldd       $0E,s     load FILE* for output
                    pshs      b,a       push FILE* arg
                    ldb       ,u+       read byte from source buffer, advance U
                    sex                 sign-extend B to D
                    pshs      b,a       push character arg
                    lbsr      egg2      write one character to output stream
                    leas      $04,s     discard two args
                    ldx       $0E,s     load stream pointer
                    ldd       $06,x     load stream flags word
                    clra                clear high byte
                    andb      #C$SPC    check error/status bits
                    bne       FWriteReturn stream error — stop writing
FWriteIncCount      ldd       ,s        load inner written count
                    addd      #$0001    increment count
                    std       ,s        store updated count
                    subd      #$0001    restore to previous value (for compare)
                    cmpd      $0A,s     compare to inner limit
                    blt       FWriteCharLoop less than limit — write next char
                    ldd       $02,s     load outer loop counter
                    addd      #$0001    increment outer counter
FWriteOuterUpdate   std       $02,s     store outer counter
                    ldd       $02,s     reload outer counter
                    cmpd      $0C,s     compare to outer limit (nmemb arg)
                    blt       FWriteInit less — start next inner loop
FWriteReturn        ldd       $02,s     load final written count to return
                    leas      $04,s     deallocate locals
                    puls      pc,u      restore U and return

PrintfEntry         pshs      u         save U (frame pointer)
                    leax      >$001F,y  point X to output putchar context
                    stx       >varnum1,y store putchar context pointer
                    leax      $06,s     point to format string arg on stack
                    pshs      x         push format string pointer
                    ldd       $06,s     load first vararg value
                    bra       PrintfPushArgs push args and call format proc
                    pshs      u         (dead — alternate fprintf entry)
                    ldd       $04,s     (dead)
                    std       >varnum1,y (dead)
                    leax      $08,s     (dead)
                    pshs      x         (dead)
                    ldd       $08,s     (dead)
PrintfPushArgs      pshs      b,a       push first vararg
                    leax      >FWriteCallback,pcr load address of write callback
                    pshs      x         push callback function pointer
                    bsr       FormatStrProc call format string processor
                    leas      $06,s     discard three pushed args
                    puls      pc,u      restore U and return
                    pshs      u         (dead — alternate sprintf entry)
                    ldd       $04,s     (dead)
                    std       >varnum1,y (dead)
                    leax      $08,s     (dead)
                    pshs      x         (dead)
                    ldd       $08,s     (dead)
                    pshs      b,a       (dead)
                    leax      >PutCharCallback,pcr (dead)
                    pshs      x         (dead)
                    bsr       FormatStrProc (dead)
                    leas      $06,s     (dead)
                    clra                (dead)
                    clrb                (dead)
                    stb       [>varnum1,y] (dead)
                    ldd       $04,s     (dead)
                    puls      pc,u      (dead)
FormatStrProc       pshs      u         save U (frame pointer)
                    ldu       $06,s     load format string pointer from arg
                    leas      -$0B,s    allocate 11 bytes of local workspace
                    bra       GetFormatChar start at top of format char fetch
FormatCharLoop      ldb       $08,s     load current format character
                    lbeq      FormatDone NUL — end of format string
                    ldb       $08,s     reload char
                    sex                 sign-extend B to D
                    pshs      b,a       push char for output callback
                    jsr       [<$11,s]  call output character callback
                    leas      $02,s     discard char arg
GetFormatChar       ldb       ,u+       fetch next byte from format string
                    stb       $08,s     save as current format char
                    cmpb      #$25      '%' (format specifier start)?
                    bne       FormatCharLoop no — output literal char
                    ldb       ,u+       fetch char after '%'
                    stb       $08,s     save as specifier char
                    clra                clear precision high byte
                    clrb                clear precision low byte
                    std       $02,s     init precision accumulator to 0
                    std       $06,s     init width accumulator to 0
                    ldb       $08,s     reload specifier char
                    cmpb      #$2D      '-' (left-justify flag)?
                    bne       NoLeftJust no — right-justify (default)
                    ldd       #$0001    left-justify flag = 1
                    std       >varnum4,y store left-justify flag
                    ldb       ,u+       consume '-', fetch next format char
                    stb       $08,s     save it
                    bra       CheckPadChar check for pad character
NoLeftJust          clra                clear left-justify flag high byte
                    clrb                clear left-justify flag low byte
                    std       >varnum4,y store right-justify (0 = default)
CheckPadChar        ldb       $08,s     load current format char
                    cmpb      #$30      '0' (zero-pad)?
                    bne       PadWithSpace no — pad with spaces
                    ldd       #$0030    pad character = '0'
                    bra       StorePadChar store and proceed
PadWithSpace        ldd       #$0020    pad character = ' ' (space)
StorePadChar        std       >varnum5,y store pad character
                    bra       CheckWidthDigit start width accumulation
AccumWidth          ldd       $06,s     load current width accumulator
                    pshs      b,a       push accumulator
                    ldd       #$000A    multiplier = 10
                    lbsr      UMul16    width = width × 10
                    pshs      b,a       push product
                    ldb       $0A,s     load current digit char
                    sex                 sign-extend digit to D
                    addd      #$FFD0    subtract $30 (convert ASCII digit to value)
                    addd      ,s++      add to product (pop)
                    std       $06,s     store updated width
                    ldb       ,u+       fetch next format char
                    stb       $08,s     save it
CheckWidthDigit     ldb       $08,s     load current char
                    sex                 sign-extend to D
                    leax      >$00E3,y  point to character class table
                    leax      d,x       index by char value
                    ldb       ,x        load character class byte
                    clra                clear high byte
                    andb      #$08      test digit class bit
                    bne       AccumWidth digit — accumulate into width
                    ldb       $08,s     load char after width digits
                    cmpb      #$2E      '.' (precision specifier)?
                    bne       ZeroPrecision no — precision = 0
                    ldd       #$0001    precision seen flag = 1
                    std       $04,s     set precision-seen flag
                    bra       PrecisionLoop start precision accumulation
AccumPrecision      ldd       $02,s     load current precision accumulator
                    pshs      b,a       push accumulator
                    ldd       #$000A    multiplier = 10
                    lbsr      UMul16    precision = precision × 10
                    pshs      b,a       push product
                    ldb       $0A,s     load current digit char
                    sex                 sign-extend digit to D
                    addd      #$FFD0    subtract $30 (ASCII digit to value)
                    addd      ,s++      add to product (pop)
                    std       $02,s     store updated precision
PrecisionLoop       ldb       ,u+       fetch next format char
                    stb       $08,s     save it
                    ldb       $08,s     reload
                    sex                 sign-extend to D
                    leax      >$00E3,y  point to character class table
                    leax      d,x       index by char value
                    ldb       ,x        load class byte
                    clra                clear high byte
                    andb      #$08      test digit class bit
                    bne       AccumPrecision digit — accumulate precision
                    bra       FormatDispatch done — dispatch on specifier char
ZeroPrecision       clra                precision not specified — clear high
                    clrb                precision not specified — clear low
                    std       $04,s     store zero precision flag
FormatDispatch      ldb       $08,s     load format specifier character
                    sex                 sign-extend to D
                    tfr       d,x       move to X for comparison
                    lbra      FmtSpecDispatch jump to format type dispatcher
FmtDecimalSigned    ldd       $06,s     load width argument
                    pshs      b,a       push width
                    ldx       <$15,s    load vararg pointer
                    leax      $02,x     advance vararg pointer by 2
                    stx       <$15,s    store updated vararg pointer
                    ldd       -$02,x    load integer value from varargs
                    pshs      b,a       push value
                    lbsr      ItoA      convert signed integer to ASCII string
                    bra       StoreFormatted store result and output
FmtOctal            ldd       $06,s     load width argument
                    pshs      b,a       push width
                    ldx       <$15,s    load vararg pointer
                    leax      $02,x     advance vararg pointer by 2
                    stx       <$15,s    store updated vararg pointer
                    ldd       -$02,x    load value from varargs
                    pshs      b,a       push value
                    lbsr      UtoOct    convert unsigned to octal string
StoreFormatted      std       ,s        save string pointer result
                    lbra      CallOutputFunc output the formatted string
FmtHex              ldd       $06,s     load width argument
                    pshs      b,a       push width
                    ldb       $0A,s     load format char ('x' or 'X')
                    sex                 sign-extend to D
                    leax      >$00E3,y  point to character class table
                    leax      d,x       index by char value
                    ldb       ,x        load class byte
                    clra                clear high byte
                    andb      #$02      test uppercase bit (class 2 = upper)
                    pshs      b,a       push uppercase flag
                    ldx       <$17,s    load vararg pointer
                    leax      $02,x     advance vararg pointer by 2
                    stx       <$17,s    store updated pointer
                    ldd       -$02,x    load value from varargs
                    pshs      b,a       push value
                    lbsr      UtoHex    convert unsigned to hex string
                    lbra      FormatCleanup clean up and output
FmtUnsigned         ldd       $06,s     load width argument
                    pshs      b,a       push width
                    ldx       <$15,s    load vararg pointer
                    leax      $02,x     advance vararg pointer by 2
                    stx       <$15,s    store updated pointer
                    ldd       -$02,x    load value from varargs
                    pshs      b,a       push value
                    leax      >varnum2,y point to conversion buffer
                    pshs      x         push buffer pointer
                    lbsr      UtoA      convert unsigned integer to ASCII
                    lbra      FormatCleanup clean up and output
FmtFloat            ldd       $04,s     load precision-seen flag
                    bne       FmtFloatPrecSet precision was specified — use it
                    ldd       #$0006    default float precision = 6 digits
                    std       $02,s     store default precision
FmtFloatPrecSet     ldd       $06,s     load width argument
                    pshs      b,a       push width
                    leax      <$15,s    address of vararg pointer
                    pshs      x         push pointer-to-pointer
                    ldd       $06,s     load width (second copy)
                    pshs      b,a       push width again
                    ldb       $0E,s     load format specifier char
                    sex                 sign-extend to D
                    pshs      b,a       push specifier char
                    lbsr      egg3      convert float to formatted string
                    leas      $06,s     discard four args
                    lbra      PushFormatResult push result and output
FmtChar             ldx       <$13,s    load vararg pointer
                    leax      $02,x     advance vararg pointer by 2
                    stx       <$13,s    store updated pointer
                    ldd       -$02,x    load character value from varargs
                    lbra      CallOutputIndirect output the character directly
FmtString           ldx       <$13,s    load vararg pointer
                    leax      $02,x     advance vararg pointer by 2
                    stx       <$13,s    store updated pointer
                    ldd       -$02,x    load string pointer from varargs
                    std       $09,s     save string pointer locally
                    ldd       $04,s     load precision-seen flag
                    beq       NullStringPad precision = 0 (none) — just pad
                    ldd       $09,s     load string pointer
                    std       $04,s     use string pointer as precision limit
                    bra       StrCopyChar enter string copy loop
StrCopyLoop         ldb       [<$09,s]  read char at string pointer
                    beq       PadString NUL — end of string, pad to width
                    ldd       $09,s     load current string pointer
                    addd      #$0001    advance by one character
                    std       $09,s     store updated string pointer
StrCopyChar         ldd       $02,s     load remaining width count
                    addd      #$FFFF    decrement remaining count
                    std       $02,s     store updated count
                    subd      #$FFFF    restore to previous value
                    bne       StrCopyLoop more chars to copy
PadString           ldd       $06,s     load width for padding calc
                    pshs      b,a       push width
                    ldd       $0B,s     load original string end
                    subd      $06,s     subtract width → pad count
                    pshs      b,a       push pad count
                    ldd       $08,s     load output context
                    pshs      b,a       push context
                    ldd       <$15,s    load vararg base pointer
                    pshs      b,a       push base pointer
                    lbsr      FmtFloatImpl output padded string
                    leas      $08,s     discard four args
                    bra       BackToFormatLoop return to format char fetch
NullStringPad       ldd       $06,s     load width
                    pshs      b,a       push width
                    ldd       $0B,s     load string end (for length)
                    bra       PushFormatResult push and output
FmtLong             ldb       ,u+       fetch 'l' modifier char (already consumed)
                    stb       $08,s     save modifier
                    bra       FmtLongCont continue with long handler
                    leas      -$0B,x    (dead — unreachable)
FmtLongCont         ldd       $06,s     load width
                    pshs      b,a       push width
                    leax      <$15,s    address of vararg pointer
                    pshs      x         push pointer-to-pointer
                    ldb       $0C,s     load format specifier after 'l'
                    sex                 sign-extend to D
                    pshs      b,a       push specifier
                    lbsr      GetFmtSpecArg fetch long-size argument from varargs
FormatCleanup       leas      $04,s     discard three args
PushFormatResult    pshs      b,a       push string result
CallOutputFunc      ldd       <$13,s    load output context
                    pshs      b,a       push context
                    lbsr      PaddedOutput output with padding applied
                    leas      $06,s     discard three args
BackToFormatLoop    lbra      GetFormatChar loop back to next format char

DefaultFmtChar      ldb       $08,s     load char that wasn't a specifier
                    sex                 sign-extend to D
CallOutputIndirect  pshs      b,a       push char/value arg
                    jsr       [<$11,s]  call output callback indirectly
                    leas      $02,s     discard arg
                    lbra      GetFormatChar loop to next format char

FmtSpecDispatch     cmpx      #$0064    'd' (signed decimal)?
                    lbeq      FmtDecimalSigned yes
                    cmpx      #$006F    'o' (octal)?
                    lbeq      FmtOctal  yes
                    cmpx      #$0078    'x' (hex lowercase)?
                    lbeq      FmtHex    yes
                    cmpx      #$0058    'X' (hex uppercase)?
                    lbeq      FmtHex    yes
                    cmpx      #$0075    'u' (unsigned decimal)?
                    lbeq      FmtUnsigned yes
                    cmpx      #$0066    'f' (float fixed)?
                    lbeq      FmtFloat  yes
                    cmpx      #$0065    'e' (float scientific)?
                    lbeq      FmtFloat  yes
                    cmpx      #$0067    'g' (float shortest)?
                    lbeq      FmtFloat  yes
                    cmpx      #$0045    'E' (float scientific upper)?
                    lbeq      FmtFloat  yes
                    cmpx      #$0047    'G' (float shortest upper)?
                    lbeq      FmtFloat  yes
                    cmpx      #$0063    'c' (character)?
                    lbeq      FmtChar   yes
                    cmpx      #$0073    's' (string)?
                    lbeq      FmtString yes
                    cmpx      #$006C    'l' (long modifier)?
                    lbeq      FmtLong   yes
                    bra       DefaultFmtChar unknown specifier — output literally

FormatDone          leas      $0B,s     deallocate format locals
                    puls      pc,u      restore U and return
ItoA                pshs      u,b,a     save registers (U,B,A on stack)
                    leax      >varnum2,y point X to conversion output buffer
                    stx       ,s        save buffer pointer as local
                    ldd       $06,s     load integer value to convert
                    bge       CallUtoA  non-negative — convert directly
                    ldd       $06,s     reload negative value
                    nega                negate high byte
                    negb                negate low byte
                    sbca      #$00      propagate borrow for 2's complement
                    std       $06,s     store negated (positive) value
                    bge       PrependMinus overflow safe — prepend '-'
                    leax      >MinIntStr,pcr special case: $8000 (most negative int)
                    pshs      x         push source string pointer
                    leax      >varnum2,y point to output buffer
                    pshs      x         push dest buffer pointer
                    lbsr      StrCopyFunc copy MinInt string constant
                    leas      $04,s     discard two args
                    lbra      ConvCleanReturn clean up and return
PrependMinus        ldd       #$002D    '-' character as D
                    ldx       ,s        load current write pointer
                    leax      $01,x     advance write pointer
                    stx       ,s        store updated pointer
                    stb       -$01,x    store '-' before advanced pointer
CallUtoA            ldd       $06,s     load value to convert
                    pshs      b,a       push value
                    ldd       $02,s     load write pointer
                    pshs      b,a       push pointer
                    bsr       UtoA      convert unsigned integer to ASCII
                    leas      $04,s     discard two args
                    lbra      OctReturn return via Oct cleanup path
UtoA                pshs      u,y,x,b,a save all needed registers
                    ldu       $0A,s     load pointer to output buffer from arg
                    clra                clear quotient accumulator high
                    clrb                clear quotient accumulator low
                    std       $02,s     init quotient to 0
                    clra                clear digit quotient high
                    clrb                clear digit quotient low
                    std       ,s        init digit quotient to 0
                    bra       DivSetup  enter division loop at setup
DivLoop             ldd       ,s        load digit quotient
                    addd      #$0001    increment quotient
                    std       ,s        store updated quotient
                    ldd       $0C,s     load dividend
                    subd      >$0005,y  subtract smallest power-of-10 constant
                    std       $0C,s     store updated dividend
DivSetup            ldd       $0C,s     load current dividend
                    blt       DivLoop   still subtracting — continue
                    leax      >$0005,y  point to power-of-10 table
                    stx       $04,s     save table pointer
                    bra       DivLoopCheck enter multi-digit loop
DivSubLoop          ldd       ,s        load digit quotient
                    addd      #$0001    increment quotient
                    std       ,s        store updated quotient
DivContLoop         ldd       $0C,s     load current remainder
                    subd      [<$04,s]  subtract current divisor from table
                    std       $0C,s     store updated remainder
                    bge       DivSubLoop still positive — keep subtracting
                    ldd       $0C,s     load negative remainder
                    addd      [<$04,s]  add back divisor to restore
                    std       $0C,s     store corrected remainder
                    ldd       ,s        load digit quotient (result digit)
                    beq       StoreDivDigit digit is zero — check suppression
                    ldd       #$0001    set non-zero digit seen flag
                    std       $02,s     update leading-zero suppression flag
StoreDivDigit       ldd       $02,s     load non-zero-seen flag
                    beq       ClearQuot still leading zero — suppress
                    ldd       ,s        load digit value
                    addd      #$0030    convert to ASCII ('0'+digit)
                    stb       ,u+       store ASCII digit, advance output
ClearQuot           clra                clear digit quotient high
                    clrb                clear digit quotient low
                    std       ,s        reset digit quotient for next iteration
                    ldd       $04,s     load table pointer
                    addd      #$0002    advance to next entry (2 bytes each)
                    std       $04,s     store updated pointer
DivLoopCheck        ldd       $04,s     load current table pointer
                    cmpd      >$000D,y  compare to table end sentinel
                    bne       DivContLoop not done — continue division
                    ldd       $0C,s     load final remainder (last digit)
                    addd      #$0030    convert to ASCII
                    stb       ,u+       store last digit
                    clra                NUL terminator high byte
                    clrb                NUL terminator low byte
                    stb       ,u        NUL-terminate the string
                    ldd       $0A,s     load buffer pointer to return
                    leas      $06,s     restore stack past locals
                    puls      pc,u      restore registers and return
UtoOct              pshs      u,b,a     save registers (U,B,A)
                    leax      >varnum2,y point to output string buffer
                    stx       ,s        save write pointer as local
                    leau      >varnum3,y point U to temp digit buffer
OctDigitLoop        ldd       $06,s     load value to convert
                    clra                clear high byte (only low 3 bits matter)
                    andb      #$07      extract lowest octal digit (bits 0–2)
                    addd      #$0030    convert to ASCII ('0'+digit)
                    stb       ,u+       store octal digit, advance U
                    ldd       $06,s     reload value
                    lsra                shift value right 1 bit (high)
                    rorb                shift value right 1 bit (low)
                    lsra                shift right again (total 3 bits needed)
                    rorb                shift right 2
                    lsra                shift right 3
                    rorb                logical shift right to get next octal group
                    std       $06,s     store shifted value
                    bne       OctDigitLoop more digits remain — continue
                    bra       OctReverseLoop digits are reversed — fix order
OctCopyReverse      ldb       ,u        read byte at current temp pointer
                    ldx       ,s        load current output write pointer
                    leax      $01,x     advance write pointer
                    stx       ,s        store updated write pointer
                    stb       -$01,x    store byte at previous write position
OctReverseLoop      leau      -dpsiz,u  back up temp pointer by one
                    pshs      u         push for boundary comparison
                    leax      >varnum3,y X = start of temp buffer
                    cmpx      ,s++      compare start to current temp ptr (pop)
                    bls       OctCopyReverse not past start — copy another digit
                    clra                NUL terminator high byte
                    clrb                NUL terminator low byte
                    stb       [,s]      NUL-terminate at write pointer
OctReturn           leax      >varnum2,y load address of output string
                    tfr       x,d       return string pointer in D
ConvCleanReturn     leas      $02,s     restore stack past saved registers
                    puls      pc,u      restore U and return
UtoHex              pshs      u,x,b,a   save registers (U,X,B,A)
                    leax      >varnum2,y point to output string buffer
                    stx       $02,s     save write pointer
                    leau      >varnum3,y point U to temp digit buffer
HexDigitLoop        ldd       $08,s     load value to convert
                    clra                clear high byte
                    andb      #$0F      extract lowest hex digit (4 bits)
                    std       ,s        save digit value on stack
                    pshs      b,a       push digit for comparison
                    ldd       $02,s     load digit again (was pushed earlier)
                    cmpd      #$0009    digit > 9?
                    ble       HexDigitOffset no — use '0'+digit
                    ldd       $0C,s     load uppercase flag
                    beq       HexLowerA zero → lowercase 'a'–'f'
                    ldd       #$0041    'A' (uppercase)
                    bra       HexAlphaOffset compute letter offset
HexLowerA           ldd       #$0061    'a' (lowercase)
HexAlphaOffset      addd      #$FFF6    subtract 10 (make 'a'+digit-10 or 'A'+digit-10)
                    bra       StoreHexDigit store the letter
HexDigitOffset      ldd       #$0030    '0' base for numeric digits
StoreHexDigit       addd      ,s++      add digit value, pop digit (pop)
                    stb       ,u+       store ASCII hex char, advance U
                    ldd       $08,s     reload value
                    lsra                shift right 4 bits (high)
                    rorb                shift right 4 bits (2)
                    lsra                shift right 4 bits (3)
                    rorb                shift right 4 bits (4)
                    lsra                shift right 4 bits (5) — low nibble gone
                    rorb                shift right 4 bits (6)
                    lsra                shift right 4 bits (7)
                    rorb                shift right 4 bits — next nibble in low
                    anda      #$0F      mask to 4 bits for next digit
                    std       $08,s     store shifted value
                    bne       HexDigitLoop more digits — continue
                    bra       HexReverseLoop digits reversed — fix order
HexCopyReverse      ldb       ,u        read byte at current temp pointer
                    ldx       $02,s     load output write pointer
                    leax      $01,x     advance write pointer
                    stx       $02,s     store updated pointer
                    stb       -$01,x    store digit at previous position
HexReverseLoop      leau      -dpsiz,u  back up temp pointer by one
                    pshs      u         push for boundary comparison
                    leax      >varnum3,y X = start of temp buffer
                    cmpx      ,s++      compare start to current temp ptr (pop)
                    bls       HexCopyReverse not past start — copy another digit
                    clra                NUL terminator high byte
                    clrb                NUL terminator low byte
                    stb       [<$02,s]  NUL-terminate output string
                    leax      >varnum2,y load start of output string
                    tfr       x,d       return string pointer in D
                    lbra      FWriteCleanup jump to shared cleanup path
FmtFloatImpl        pshs      u         save U (frame pointer)
                    ldu       $06,s     load output callback from arg
                    ldd       $0A,s     load width
                    subd      $08,s     width - string length = pad count
                    std       $0A,s     save padding count
                    ldd       >varnum4,y load left-justify flag
                    bne       FloatCountLoop non-zero — left-justify, skip left pad
                    bra       FloatPadLoop zero — right-justify, apply left pad
FloatLeftPad        ldd       >varnum5,y load pad character
                    pshs      b,a       push pad char
                    jsr       [<$06,s]  call output callback
                    leas      $02,s     discard arg
FloatPadLoop        ldd       $0A,s     load remaining pad count
                    addd      #$FFFF    decrement pad count
                    std       $0A,s     store updated count
                    subd      #$FFFF    restore to previous for comparison
                    bgt       FloatLeftPad more padding needed — continue
                    bra       FloatCountLoop done padding — copy string
FloatCopyLoop       ldb       ,u+       read byte from string, advance U
                    sex                 sign-extend to D
                    pshs      b,a       push character
                    jsr       [<$06,s]  call output callback
                    leas      $02,s     discard arg
FloatCountLoop      ldd       $08,s     load remaining char count
                    addd      #$FFFF    decrement count
                    std       $08,s     store updated count
                    subd      #$FFFF    restore for comparison
                    bne       FloatCopyLoop more chars — continue
                    ldd       >varnum4,y load left-justify flag
                    beq       FloatReturn right-justify — no right padding
                    bra       FloatRightCount left-justify — apply right padding
FloatRightPad       ldd       >varnum5,y load pad character
                    pshs      b,a       push pad char
                    jsr       [<$06,s]  call output callback
                    leas      $02,s     discard arg
FloatRightCount     ldd       $0A,s     load remaining pad count
                    addd      #$FFFF    decrement count
                    std       $0A,s     store updated count
                    subd      #$FFFF    restore for comparison
                    bgt       FloatRightPad more right-padding needed
FloatReturn         puls      pc,u      restore U and return
PaddedOutput        pshs      u         save U (frame pointer)
                    ldu       $06,s     load string pointer from arg
                    ldd       $08,s     load string/count arg
                    pshs      b,a       push for egg4 call
                    pshs      u         push string pointer
                    lbsr      egg4      measure string length
                    leas      $02,s     discard one arg
                    nega                negate length high byte (2's complement)
                    negb                negate length low byte
                    sbca      #$00      propagate borrow
                    addd      ,s++      add width arg (pop) → pad count
                    std       $08,s     save padding count
                    ldd       >varnum4,y load left-justify flag
                    bne       CheckEndOfStr left-justify — skip left padding
                    bra       LeftCountLoop right-justify — apply left padding
LeftPadLoop         ldd       >varnum5,y load pad character
                    pshs      b,a       push pad char
                    jsr       [<$06,s]  call output callback
                    leas      $02,s     discard arg
LeftCountLoop       ldd       $08,s     load remaining pad count
                    addd      #$FFFF    decrement count
                    std       $08,s     store updated count
                    subd      #$FFFF    restore for comparison
                    bgt       LeftPadLoop more left padding needed
                    bra       CheckEndOfStr done padding — copy string
CopyCharsLoop       ldb       ,u+       read byte from string, advance U
                    sex                 sign-extend to D
                    pshs      b,a       push character
                    jsr       [<$06,s]  call output callback
                    leas      $02,s     discard arg
CheckEndOfStr       ldb       ,u        peek at current string byte
                    bne       CopyCharsLoop non-NUL — copy next char
                    ldd       >varnum4,y load left-justify flag
                    beq       PaddedOutputRet right-justify — no trailing pad
                    bra       RightCountLoop left-justify — apply right padding
RightPadLoop        ldd       >varnum5,y load pad character
                    pshs      b,a       push pad char
                    jsr       [<$06,s]  call output callback
                    leas      $02,s     discard arg
RightCountLoop      ldd       $08,s     load remaining pad count
                    addd      #$FFFF    decrement count
                    std       $08,s     store updated count
                    subd      #$FFFF    restore for comparison
                    bgt       RightPadLoop more right padding needed
PaddedOutputRet     puls      pc,u      restore U and return

FWriteCallback      pshs      u         save U (frame pointer)
                    ldd       >varnum1,y load output FILE* from global
                    pshs      b,a       push FILE* arg
                    ldd       $06,s     load character to write
                    pshs      b,a       push character arg
                    lbsr      egg2      write character to stream
FWriteCleanup       leas      $04,s     discard two args
                    puls      pc,u      restore U and return
PutCharCallback     pshs      u         save U (frame pointer)
                    ldd       $04,s     load character to store
                    ldx       >varnum1,y load string write pointer from global
                    leax      $01,x     advance write pointer
                    stx       >varnum1,y store updated write pointer
                    stb       -$01,x    store character at previous position
                    puls      pc,u      restore U and return
MinIntStr           blt       PushWriteArgs
                    leas      -$09,y
                    pshu      y,x,dp

*         neg   <u0034  branch to middle of instruct?
*
*L0CF2    fcb    $00
*L0CF3    fcb    $34
*
*         nega

                    fcb       $00       what function in life do I have
egg2                pshs      u         disassembled as neg <u0034 then neg
                    ldu       $06,s     load FILE* stream pointer from arg
                    ldd       StrmFlags,u load stream flags word
                    anda      #$80      isolate read-mode bit (high)
                    andb      #$22      isolate write/buffered bits (low)
                    cmpd      #$8002    read mode + write bit set?
                    beq       ReadBitSet yes — stream is readable, write anyway
                    ldd       StrmFlags,u reload flags for write-mode check
                    clra                clear high byte
                    andb      #$22      isolate write/buffered bits
                    cmpd      #$0002    write-mode only?
                    lbne      ReturnError neither read nor write — error
                    pshs      u         push stream pointer
                    lbsr      SetStreamMode set write mode on stream
                    leas      $02,s     discard arg
ReadBitSet          ldd       StrmFlags,u load stream flags
                    clra                clear high byte
                    andb      #$04      isolate block-mode bit
                    beq       WriteOnlyMode not block mode — write directly
                    ldd       #$0001    write count = 1
PushWriteArgs       pshs      b,a       push count arg
                    leax      $07,s     point to character arg on stack
                    pshs      x         push pointer to char arg
                    ldd       StrmPath,u load path number from stream
                    pshs      b,a       push path number
                    ldd       StrmFlags,u load stream flags
                    clra                clear high byte
                    andb      #$40      test line-buffered bit
                    beq       WriteLnFuncPtr not line-buffered → use WriteFuncEntry
                    leax      >WriteLnFuncEntry,pcr writeln: ??
                    bra       CallWriteFunc call write with line function
WriteLnFuncPtr      leax      >WriteFuncEntry,pcr write  ??
CallWriteFunc       tfr       x,d       copy function pointer to D
                    tfr       d,x       then back to X for indirect call
                    jsr       ,x        call write function via pointer
                    leas      $06,s     discard three args
                    cmpd      #$FFFF    write failed?
                    bne       ReturnChar success — return char
                    ldd       StrmFlags,u load flags for error update
                    orb       #C$SPC    set error bit in flags
                    std       StrmFlags,u store updated flags
                    lbra      ReturnError return error
WriteOnlyMode       ldd       StrmFlags,u load stream flags
                    anda      #$01      test unbuffered bit
                    clrb                clear low byte
                    std       -$02,s    save unbuffered flag as local
                    bne       StoreCharInBuf buffered — store in buffer
                    pshs      u         push stream pointer
                    lbsr      FlushBuf  flush buffer before writing
                    leas      $02,s     discard arg
StoreCharInBuf      ldd       ,u        load current buffer pointer (StrmBufBase)
                    addd      #$0001    advance buffer pointer
                    std       ,u        store updated pointer
                    subd      #$0001    restore previous pointer
                    tfr       d,x       move to X for indexed store
                    ldd       $04,s     load character to store
                    stb       ,x        store char at previous buffer position
                    ldd       ,u        load updated buffer pointer
                    cmpd      StrmBufEnd,u compare to buffer end
                    bcc       BufFull   at or past end — flush buffer
                    ldd       StrmFlags,u load flags
                    clra                clear high byte
                    andb      #$40      test line-buffered bit
                    beq       ReturnChar not line-buffered — just return
                    ldd       $04,s     load character again
                    cmpd      #$000D    is it CR?
                    bne       ReturnChar not CR — return char
BufFull             pshs      u         push stream pointer for flush
                    lbsr      FlushBuf  flush full (or CR-triggered) buffer
                    std       ,s++      save result, pop stream pointer
                    lbne      ReturnError flush failed — return error
ReturnChar          ldd       $04,s     load character to return
                    puls      pc,u      restore U and return
                    pshs      u         (dead — write word to stream helper)
                    ldu       $04,s     (dead)
                    ldd       $06,s     (dead)
                    pshs      b,a       (dead)
                    pshs      u         (dead)
                    ldd       #$0008    (dead)
                    lbsr      LShiftRight (dead)
                    pshs      b,a       (dead)
                    lbsr      egg2      (dead)
                    leas      $04,s     (dead)
                    ldd       $06,s     (dead)
                    pshs      b,a       (dead)
                    pshs      u         (dead)
                    lbsr      egg2      (dead)
                    lbra      FinalCleanup (dead)
CloseAllStreams     pshs      u,b,a     save registers for stream iteration
                    leau      >StrmTable,y point U to first stream table entry
                    clra                clear stream index high byte
                    clrb                clear stream index low byte
                    std       ,s        init index = 0
                    bra       StreamCountLoop start at count check
AdvanceStream       tfr       u,d       save old U for FClose arg
                    leau      StrmStride,u advance U to next stream entry
                    pshs      b,a       push old stream pointer as arg
                    bsr       FClose    close this stream
                    leas      $02,s     discard arg
StreamCountLoop     ldd       ,s        load stream index
                    addd      #$0001    increment index
                    std       ,s        store updated index
                    subd      #$0001    restore for comparison
                    cmpd      #$0010    processed all 16 entries?
                    blt       AdvanceStream no — close next stream
                    lbra      CleanupReturn yes — done
FClose              pshs      u         save U (frame pointer)
                    ldu       $04,s     load FILE* stream pointer from arg
                    leas      -$02,s    allocate 2 bytes local storage
                    cmpu      #$0000    is stream pointer NULL?
                    beq       NullStream yes — return $FFFF (invalid)
                    ldd       StrmFlags,u load stream mode flags
                    bne       CheckCloseFlags flags non-zero — stream is open
NullStream          ldd       #$FFFF    return $FFFF for null/closed stream
                    lbra      CleanupReturn clean up and return
CheckCloseFlags     ldd       StrmFlags,u load mode flags
                    clra                clear high byte
                    andb      #$02      isolate write-mode bit
                    beq       NotFlushed not write mode — no flush needed
                    pshs      u         push stream pointer
                    bsr       CheckBufWrite flush dirty write buffer
                    leas      $02,s     discard arg
                    bra       ClosePath proceed to close path
NotFlushed          clra                no flush — clear result high
                    clrb                no flush — clear result low
ClosePath           std       ,s        save flush result as local
                    ldd       StrmPath,u load OS path number
                    pshs      b,a       push path arg
                    lbsr      close     call OS close
                    leas      $02,s     discard arg
                    clra                clear flags high byte
                    clrb                clear flags low byte
                    std       StrmFlags,u zero stream flags (mark closed)
                    ldd       ,s        load saved result
                    bra       CleanupReturn clean up and return
CheckBufWrite       pshs      u         save U
                    ldu       $04,s     load stream pointer
                    beq       ReturnError NULL stream — return error
                    ldd       StrmFlags,u load stream flags
                    clra                clear high byte
                    andb      #$22      isolate write flags
                    cmpd      #$0002    write-mode set?
                    beq       FlushDirtyBuf yes — flush the buffer
ReturnError         ldd       #$FFFF    return $FFFF (error/not writable)
                    puls      pc,u      restore U and return

FlushDirtyBuf       ldd       StrmFlags,u load stream flags
                    anda      #$80      test read-mode bit
                    clrb                clear low byte
                    std       -$02,s    save read-mode flag as local
                    bne       FlushAndReturn read-mode set — flush directly
                    pshs      u         push stream pointer
                    lbsr      SetStreamMode ensure stream is in write mode
                    leas      $02,s     discard arg
FlushAndReturn      pshs      u         push stream pointer for flush
                    bsr       FlushBuf  flush buffer to OS
CleanupReturn       leas      $02,s     deallocate locals
                    puls      pc,u      restore U and return

FlushBuf            pshs      u         save U (frame pointer)
                    ldu       $04,s     load FILE* stream pointer from arg
                    leas      -$04,s    allocate 4 bytes local storage
                    ldd       StrmFlags,u load stream flags
                    anda      #$01      test buffered bit
                    clrb                clear low byte
                    std       -$02,s    save buffered flag as local
                    bne       FlushWritePath buffered — skip seek on flush
                    ldd       ,u        load current buffer pointer
                    cmpd      StrmBufEnd,u compare to buffer end
                    beq       FlushWritePath at end — nothing to flush
                    clra                seek offset high word high byte
                    clrb                seek offset high word low byte
                    pshs      b,a       push high word of seek offset
                    pshs      u         push stream pointer
                    lbsr      GetFilePosStub get/calculate current file position
                    leas      $02,s     discard stream pointer
                    ldd       $02,x     load low word of position from result
                    pshs      b,a       push low word
                    ldd       ,x        load high word of position
                    pshs      b,a       push high word
                    ldd       StrmPath,u load path number
                    pshs      b,a       push path
                    lbsr      lseek     seek to correct position
                    leas      $08,s     discard four args
FlushWritePath      ldd       ,u        load current write pointer
                    subd      StrmBufBase,u subtract buffer base → bytes to write
                    std       $02,s     save byte count
                    lbeq      FlushSuccess nothing buffered — done
                    ldd       StrmFlags,u reload flags
                    anda      #$01      test buffered bit
                    clrb                clear low byte
                    std       -$02,s    save flag
                    lbeq      FlushSuccess unbuffered — nothing to write
                    ldd       StrmFlags,u reload flags for line-mode check
                    clra                clear high byte
                    andb      #$40      test line-buffer bit
                    beq       RawWritePath not line-buffered — raw write
                    ldd       StrmBufBase,u load buffer base as write position
                    bra       AdvanceBufPtr go store updated buf pointer
WriteLineLoop       ldd       $02,s     load remaining byte count
                    pshs      b,a       push count arg
                    ldd       ,u        load current write pointer
                    pshs      b,a       push data pointer
                    ldd       StrmPath,u load OS path number
                    pshs      b,a       push path
                    lbsr      writeln   write one line to OS path
                    leas      $06,s     discard three args
                    std       ,s        save bytes written
                    cmpd      #$FFFF    write failed?
                    bne       UpdateAfterWrite success — update pointers
                    leax      $04,s     compute cleanup pointer
                    bra       FlushWriteErr handle write error
UpdateAfterWrite    ldd       $02,s     load remaining byte count
                    subd      ,s        subtract bytes written this call
                    std       $02,s     store updated remaining count
                    ldd       ,u        load current write pointer
                    addd      ,s        add bytes written
AdvanceBufPtr       std       ,u        store updated buffer pointer
                    ldd       $02,s     load remaining count
                    bne       WriteLineLoop more bytes remain — write next line
                    bra       FlushSuccess all written — success
RawWritePath        ldd       $02,s     load total byte count
                    pshs      b,a       push count arg
                    ldd       StrmBufBase,u load buffer base address
                    pshs      b,a       push data pointer
                    ldd       StrmPath,u load OS path number
                    pshs      b,a       push path
                    lbsr      write     write buffer to OS path (was L13D3)
                    leas      $06,s     discard three args
                    cmpd      $02,s     compare written to requested
                    beq       FlushSuccess match — success
                    bra       SetErrorFlags mismatch — set error
FlushWriteErr       leas      -$04,x    restore stack via X pointer
SetErrorFlags       ldd       StrmFlags,u load stream flags
                    orb       #C$SPC    set error/EOF bit
                    std       StrmFlags,u store updated flags
                    ldd       StrmBufEnd,u load buffer end
                    std       ,u        store as current ptr (mark buf full)
                    ldd       #$FFFF    return $FFFF (error)
                    bra       FinalCleanup clean up and return
FlushSuccess        ldd       StrmFlags,u load stream flags
                    ora       #$01      set buffered/valid bit
                    std       StrmFlags,u store updated flags
                    ldd       StrmBufBase,u reset buffer write pointer to base
                    std       ,u        store reset pointer
                    addd      StrmBufSize,u compute new buffer end
                    std       StrmBufEnd,u store buffer end
                    clra                return 0 high byte (success)
                    clrb                return 0 low byte
FinalCleanup        leas      $04,s     deallocate locals
                    puls      pc,u      restore U and return
GetFilePosStub      pshs      u         save U (stub — no real implementation)
                    puls      pc,u      restore U and return immediately
FGetCharFill        pshs      u         save U (frame pointer)
                    ldu       $04,s     load FILE* stream pointer from arg
                    beq       ReturnEOF NULL stream — return EOF
                    ldd       StrmFlags,u load stream flags
                    anda      #$01      test EOF/error bit
                    clrb                clear low byte
                    std       -$02,s    save flag as local
                    bne       ReturnEOF error set — return EOF
                    ldd       ,u        load current buffer read pointer
                    cmpd      StrmBufEnd,u compare to buffer end
                    bcc       FillReadBuf at or past end — refill buffer
                    ldd       ,u        reload read pointer
                    addd      #$0001    advance read pointer
                    std       ,u        store updated pointer
                    subd      #$0001    restore previous pointer
                    tfr       d,x       move to X for indexed load
                    ldb       ,x        read character from buffer
                    clra                clear high byte (char is 8-bit)
                    lbra      PopAndReturn clean up and return char
FillReadBuf         pshs      u         push stream pointer for ReadBufFill
                    lbsr      ReadBufFill refill the read buffer
                    lbra      ReadCleanup clean up result and return
                    pshs      u         (dead — unget helper entry)
                    ldu       $06,s     (dead)
                    beq       ReturnEOF (dead)
                    ldd       StrmFlags,u (dead)
                    clra                (dead)
                    andb      #$01      (dead)
                    beq       ReturnEOF (dead)
                    ldd       $04,s     (dead)
                    cmpd      #$FFFF    (dead)
                    beq       ReturnEOF (dead)
                    ldd       ,u        (dead)
                    cmpd      StrmBufBase,u (dead)
                    bhi       ReturnGetChar (dead)
ReturnEOF           ldd       #$FFFF    return $FFFF (EOF/error)
                    puls      pc,u      restore U and return
ReturnGetChar       ldd       ,u        load current read pointer
                    addd      #$FFFF    back up read pointer by one (unget)
                    std       ,u        store decremented pointer
                    tfr       d,x       move pointer to X
                    ldd       $04,s     load character to unget
                    stb       ,x        store character back into buffer
                    ldd       $04,s     reload character
                    puls      pc,u      restore U and return char
                    pshs      u         (dead — fgetword entry)
                    ldu       $04,s     (dead)
                    leas      -$04,s    (dead)
                    pshs      u         (dead)
                    lbsr      FGetCharFill (dead)
                    leas      $02,s     (dead)
                    std       $02,s     (dead)
                    cmpd      #$FFFF    (dead)
                    beq       EofOnFirstRead (dead)
                    pshs      u         (dead)
                    lbsr      FGetCharFill (dead)
                    leas      $02,s     (dead)
                    std       ,s        (dead)
                    cmpd      #$FFFF    (dead)
                    bne       CombineChars (dead)
EofOnFirstRead      ldd       #$FFFF    EOF on first byte — return EOF
                    bra       ReturnCombined return EOF value
CombineChars        ldd       $02,s     load first byte (high byte of word)
                    pshs      b,a       push first byte
                    ldd       #$0008    shift count = 8
                    lbsr      LShiftLeft shift first byte left 8 bits
                    addd      ,s        add second byte to form 16-bit word
ReturnCombined      leas      $04,s     deallocate locals
                    puls      pc,u      restore U and return
ReadBufFill         pshs      u         save U (frame pointer)
                    ldu       $04,s     load FILE* stream pointer from arg
                    leas      -$02,s    allocate 2 bytes local storage
                    ldd       StrmFlags,u load stream flags
                    anda      #$80      isolate read-mode bit (high byte)
                    andb      #$31      isolate read/buffered bits (low byte)
                    cmpd      #$8001    read-mode + buffered ready?
                    beq       CheckStdinStream yes — stream set up, check stdin
                    ldd       StrmFlags,u reload flags for write-mode check
                    clra                clear high byte
                    andb      #$31      isolate read/buffered bits
                    cmpd      #$0001    read-only buffered?
                    lbne      ReturnEOFVal not read mode — return EOF
                    pshs      u         push stream pointer
                    lbsr      SetStreamMode initialize stream for reading
                    leas      $02,s     discard arg
CheckStdinStream    leax      >StrmTable,y point X to stdin stream entry
                    pshs      x         push pointer for comparison
                    cmpu      ,s++      is this stream the stdin stream? (pop)
                    bne       CheckReadMode no — skip stdin flush
                    ldd       StrmFlags,u load stdin flags
                    clra                clear high byte
                    andb      #$40      test line-buffered bit
                    beq       CheckReadMode not line-buffered — skip
                    leax      >$001F,y  point to stdout stream
                    pshs      x         push stdout pointer
                    lbsr      CheckBufWrite flush stdout before reading stdin
                    leas      $02,s     discard arg
CheckReadMode       ldd       StrmFlags,u load stream flags
                    clra                clear high byte
                    andb      #$08      test block-read bit
                    beq       SingleByteRead not block — single-byte read
                    ldd       StrmBufSize,u load buffer size for block read
                    pshs      b,a       push size arg
                    ldd       StrmBufBase,u load buffer base address
                    pshs      b,a       push buffer pointer
                    ldd       StrmPath,u load OS path number
                    pshs      b,a       push path
                    ldd       StrmFlags,u load flags for line-mode check
                    clra                clear high byte
                    andb      #$40      test line-buffered bit
                    beq       LoadReadFuncPtr not line-buffered → use read
                    leax      >ReadLnFuncEntry,pcr readln:
                    bra       CallReadFunc call readln
LoadReadFuncPtr     leax      >ReadFuncEntry,pcr compiler doesn't like "read" label
CallReadFunc        tfr       x,d       copy function pointer to D
                    tfr       d,x       then back to X for indirect call
                    jsr       ,x        call read/readln function
                    bra       ProcessReadResult handle result
SingleByteRead      ldd       #$0001    single-byte count
                    pshs      b,a       push count arg
                    leax      StrmMode,u use StrmMode field as 1-byte buffer
                    stx       StrmBufBase,u set buffer base to StrmMode
                    pshs      x         push buffer address
                    ldd       StrmPath,u load OS path number
                    pshs      b,a       push path
                    lbsr      read      read one byte from OS path

ProcessReadResult   leas      $06,s     discard three args
                    std       ,s        save bytes-read result
                    ldd       ,s        reload result for comparison
                    bgt       AdvanceBufRead positive count — data was read
                    ldd       StrmFlags,u load stream flags for error update
                    pshs      b,a       save current flags
                    ldd       $02,s     load the bytes-read result
                    beq       SetEofBit zero bytes → EOF condition
                    ldd       #$0020    error flag bit
                    bra       ApplyEofFlags apply error flag
SetEofBit           ldd       #$0010    EOF flag bit
ApplyEofFlags       ora       ,s+       OR into saved flags high byte (pop A)
                    orb       ,s+       OR into saved flags low byte (pop B)
                    std       StrmFlags,u store updated flags with EOF/error set
ReturnEOFVal        ldd       #$FFFF    return $FFFF (EOF)
                    bra       ReadCleanup clean up and return
AdvanceBufRead      ldd       StrmBufBase,u load buffer base
                    addd      #$0001    advance by one (past first byte)
                    std       ,u        store as current read pointer
                    ldd       StrmBufBase,u reload buffer base
                    addd      ,s        add bytes-read count
                    std       StrmBufEnd,u set buffer end = base + count
                    ldb       [<StrmBufBase,u] read first byte from buffer
                    clra                clear high byte (char is 8-bit)
ReadCleanup         leas      $02,s     deallocate locals
PopAndReturn        puls      pc,u      restore U and return
SetStreamMode       pshs      u         save U (frame pointer)
                    ldu       $04,s     load FILE* stream pointer
                    ldd       StrmFlags,u load stream flags
                    clra                clear high byte
                    andb      #$C0      check if mode already initialized
                    bne       SetOpenedFlag already set — skip getstat
                    leas      <-$20,s   allocate $20-byte buffer for getstat
                    leax      ,s        X points to getstat result buffer
                    pshs      x         push buffer pointer
                    ldd       StrmPath,u load OS path number
                    pshs      b,a       push path
                    clra                getstat option = SS_OPT (0)
                    clrb
                    pshs      b,a       push option code
                    lbsr      getstat   call OS getstat to probe stream type
                    leas      $06,s     discard three args
                    ldd       StrmFlags,u reload flags to combine with mode
                    pshs      b,a       save current flags on stack
                    ldb       $02,s     load stream-type byte from getstat result
                    bne       SetBlockModeFlag non-zero → block device
                    ldd       #$0040    line-buffered flag (character device)
                    bra       ApplyModeFlags apply mode flag
SetBlockModeFlag    ldd       #$0080    block-mode flag (block device)
ApplyModeFlags      ora       ,s+       OR high byte into saved flags (pop)
                    orb       ,s+       OR low byte into saved flags (pop)
                    std       StrmFlags,u store combined mode flags
                    leas      <$20,s    deallocate getstat buffer
SetOpenedFlag       ldd       StrmFlags,u reload flags
                    ora       #$80      set stream-opened bit
                    std       StrmFlags,u store updated flags
                    clra                clear high byte for buffer-state check
                    andb      #$0C      test buffer-error/single-byte bits
                    beq       CheckBufSizeSet not set — determine buffer size
                    puls      pc,u      buffer state valid — return

CheckBufSizeSet     ldd       StrmBufSize,u load buffer size
                    bne       CheckBufAllocated non-zero — size already set
                    ldd       StrmFlags,u load flags for line/block check
                    clra                clear high byte
                    andb      #$40      test line-buffered flag
                    beq       DefaultLineBufSize not line-buffered → use default
                    ldd       #$0080    line-buffer size = $80 (128)
                    bra       StoreBufSizeVal store size
DefaultLineBufSize  ldd       #$0100    block-buffer size = $100 (256)
StoreBufSizeVal     std       StrmBufSize,u store buffer size in stream struct
CheckBufAllocated   ldd       StrmBufBase,u load buffer base pointer
                    bne       MarkBufReady non-NULL — already allocated
                    ldd       StrmBufSize,u load size needed
                    pshs      b,a       push size arg
                    lbsr      ibrk      allocate memory from heap (L14BA)
                    leas      $02,s     discard arg
                    std       StrmBufBase,u store allocated buffer pointer
                    cmpd      #$FFFF    allocation failed?
                    beq       MarkBufError yes — use single-byte fallback
MarkBufReady        ldd       StrmFlags,u load stream flags
                    orb       #$08      set block-buffer-ready bit
                    std       StrmFlags,u store updated flags
                    bra       CalcBufEnd compute buffer end pointer
MarkBufError        ldd       StrmFlags,u load stream flags
                    orb       #$04      set single-byte-buffer bit
                    std       StrmFlags,u store updated flags
                    leax      StrmMode,u use StrmMode field as 1-byte buffer
                    stx       StrmBufBase,u set buffer base to StrmMode
                    ldd       #$0001    single-byte buffer size
                    std       StrmBufSize,u store buffer size = 1
CalcBufEnd          ldd       StrmBufBase,u load buffer base
                    addd      StrmBufSize,u add size to get end address
                    std       StrmBufEnd,u store buffer end
                    std       ,u        initialize current read pointer to end
                    puls      pc,u      restore U and return

GetFmtSpecArg       pshs      u         save U (frame pointer)
                    ldb       $05,s     load format specifier char from arg
                    sex                 sign-extend B to D
                    tfr       d,x       move specifier to X for comparison
                    bra       CheckFmtSpecChar dispatch on specifier type
DispatchFmtArg      ldd       [<$06,s]  load vararg pointer (indirect)
                    addd      #$0004    advance vararg pointer by 4 bytes (long)
                    std       [<$06,s]  store updated vararg pointer
                    leax      >Egg3FuncByte,pcr load address of egg3 function byte
                    bra       ReturnFmtSpecVal return function pointer in D
StoreFmtCharResult  ldb       $05,s     load specifier char for char result
                    stb       >$0010,y  store char in format scratch area
                    leax      >$000F,y  point X to scratch area
ReturnFmtSpecVal    tfr       x,d       return pointer/value in D
                    puls      pc,u      restore U and return
CheckFmtSpecChar    cmpx      #$0064    'd' (decimal)?
                    beq       DispatchFmtArg yes — fetch as integer
                    cmpx      #$006F    'o' (octal)?
                    lbeq      DispatchFmtArg yes — fetch as integer
                    cmpx      #$0078    'x' (hex)?
                    lbeq      DispatchFmtArg yes — fetch as integer
                    bra       StoreFmtCharResult other — store specifier char
                    puls      pc,u      (dead — never reached)

*L112F    neg   <u0034 branch in here ?
*L112F    fcb $00
*L1130    fcb $34
*         nega

Egg3FuncByte        fcb       $00       used above
egg3                pshs      u         disassembled as neg <u0034 then neg

                    leax      >Egg4FuncByte,pcr load address of egg4 function byte
                    tfr       x,d       return address in D
                    puls      pc,u      restore U and return
*
* L113A    neg   <u0034 same story here except somebody jumps
*                        to the front byte too
*

Egg4FuncByte        fcb       $00       what do i do?
egg4                pshs      u         disassembled as neg <u0034 then neg
                    ldu       $04,s     load string pointer from arg
StrLenLoop          ldb       ,u+       read byte at U, advance U
                    bne       StrLenLoop non-NUL — keep counting
                    tfr       u,d       D = one past NUL terminator
                    subd      $04,s     subtract original pointer
                    addd      #$FFFF    subtract 1 (don't count NUL)
                    puls      pc,u      restore U and return length

StrCopyFunc         pshs      u         save U (frame pointer)
                    ldu       $06,s     load source string pointer from arg
                    leas      -$02,s    allocate 2 bytes (dest write pointer)
                    ldd       $06,s     load dest pointer from arg
                    std       ,s        save dest write pointer as local
StrCopyBufLoop      ldb       ,u+       read byte from source, advance U
                    ldx       ,s        load current dest write pointer
                    leax      $01,x     advance dest pointer
                    stx       ,s        store updated dest pointer
                    stb       -$01,x    store byte at previous dest position
                    bne       StrCopyBufLoop non-NUL — copy next byte
                    bra       StrOpReturn done — return
                    pshs      u         (dead — strlen fallback)
                    ldu       $06,s     (dead)
                    leas      -$02,s    (dead)
                    ldd       $06,s     (dead)
                    std       ,s        (dead)
StrLenBufLoop       ldx       ,s        load current scan pointer
                    leax      $01,x     advance pointer
                    stx       ,s        store updated pointer
                    ldb       -$01,x    read byte at previous position
                    bne       StrLenBufLoop non-NUL — keep scanning
                    ldd       ,s        load pointer past NUL
                    addd      #$FFFF    back up one (exclude NUL)
                    std       ,s        store length pointer

StrAppendLoop       ldb       ,u+       read byte from U (source string)
                    ldx       ,s        load dest write pointer
                    leax      $01,x     advance dest pointer
                    stx       ,s        store updated pointer
                    stb       -$01,x    store byte at previous position
                    bne       StrAppendLoop non-NUL — append next byte

StrOpReturn         ldd       $06,s     load return value (original dest)
                    leas      $02,s     deallocate local
                    puls      pc,u      restore U and return

                    pshs      u         (dead — strcmp entry)
                    ldu       $04,s     (dead)
                    bra       CompareStrLoop (dead)
CheckStrMatch       ldx       $06,s     load current string scan pointer
                    leax      $01,x     advance by one
                    stx       $06,s     store updated pointer
                    ldb       -$01,x    read byte at previous position
                    bne       NextStrEntry non-NUL — chars matched, continue
                    clra                match found — return 0 high
                    clrb                match found — return 0 low
                    puls      pc,u      restore U and return

NextStrEntry        leau      dpsiz,u   advance U to next string entry
CompareStrLoop      ldb       ,u        read byte from table entry
                    sex                 sign-extend to D
                    pshs      b,a       push table char
                    ldb       [<$08,s]  read char from search key (indirect)
                    sex                 sign-extend to D
                    cmpd      ,s++      compare key char to table char (pop)
                    beq       CheckStrMatch match — continue comparing
                    ldb       [<$06,s]  load current scan position char
                    sex                 sign-extend to D
                    pshs      b,a       push it
                    ldb       ,u        reload table char for subtraction
                    sex                 sign-extend to D
                    subd      ,s++      compute difference (key - table), pop
                    puls      pc,u      restore U and return difference

AtoI                pshs      u         save U (frame pointer)
                    ldu       $04,s     load string pointer from arg
                    leas      -$05,s    allocate 5 bytes local storage
                    clra                clear accumulator high byte
                    clrb                clear accumulator low byte
                    std       $01,s     init accumulator to 0
SkipWhitespace      ldb       ,u+       read char from string, advance U
                    stb       ,s        save char as current
                    cmpb      #C$SPC    space character?
                    beq       SkipWhitespace yes — skip it
                    ldb       ,s        reload current char
                    cmpb      #$09      tab character?
                    lbeq      SkipWhitespace yes — skip it
                    ldb       ,s        reload for sign check
                    cmpb      #$2D      '-' (negative sign)?
                    bne       NotNegativeSign no — not negative
                    ldd       #$0001    sign flag = 1 (negative)
                    bra       StoreSignFlag store sign
NotNegativeSign     clra                sign flag high = 0 (positive)
                    clrb                sign flag low = 0
StoreSignFlag       std       $03,s     store sign flag local
                    ldb       ,s        reload current char
                    cmpb      #$2D      '-' (was the sign char)?
                    beq       AdvanceInputPtr yes — skip past the '-'
                    ldb       ,s        reload for '+' check
                    cmpb      #$2B      '+' (explicit positive)?
                    bne       CheckDigitChar no — check if digit
                    bra       AdvanceInputPtr yes — skip past the '+'
AccumDecDigit       ldd       $01,s     load current accumulated value
                    pshs      b,a       push accumulated value
                    ldd       #$000A    multiplier = 10
                    lbsr      UMul16    value = value × 10
                    pshs      b,a       push product
                    ldb       $02,s     load current char (digit)
                    sex                 sign-extend to D
                    addd      ,s++      add to product (pop)
                    addd      #$FFD0    subtract $30 (convert ASCII to digit value)
                    std       $01,s     store updated accumulator
AdvanceInputPtr     ldb       ,u+       fetch next char from string
                    stb       ,s        save as current char
CheckDigitChar      ldb       ,s        load current char for class check
                    sex                 sign-extend to D
                    leax      >$00E3,y  point to character class table
                    leax      d,x       index by char value
                    ldb       ,x        load character class byte
                    clra                clear high byte
                    andb      #$08      test decimal digit class bit
                    bne       AccumDecDigit it's a digit — accumulate
                    ldd       $03,s     load sign flag
                    beq       PositiveResult zero — result is positive
                    ldd       $01,s     load accumulated absolute value
                    nega                negate high byte (2's complement)
                    negb                negate low byte
                    sbca      #$00      propagate borrow
                    bra       AtoIReturn return negated value
PositiveResult      ldd       $01,s     load positive accumulated value
AtoIReturn          leas      $05,s     deallocate locals
                    puls      pc,u      restore U and return

UMul16              tsta                test high byte of multiplier A
                    bne       UMul32    non-zero — need 32-bit multiply
                    tst       $02,s     test high byte of multiplicand
                    bne       UMul32    non-zero — need 32-bit multiply
                    lda       $03,s     load low byte of multiplicand
                    mul                 A × B → D (8×8 unsigned)
                    ldx       ,s        load return address / old X
                    stx       $02,s     save for later restore
                    ldx       #$0000    clear high word result
                    std       ,s        store low product
                    puls      pc,b,a    restore B,A and return result

UMul32              pshs      b,a       save multiplicand (A,B) on stack
                    ldd       #$0000    zero for accumulation
                    pshs      b,a       push high word of result = 0
                    pshs      b,a       push low word of result = 0
                    lda       $05,s     multiplicand low byte
                    ldb       $09,s     multiplier low byte
                    mul                 partial product: lo×lo
                    std       $02,s     store in result low word
                    lda       $05,s     multiplicand low byte
                    ldb       $08,s     multiplier high byte
                    mul                 partial product: lo×hi
                    addd      $01,s     add into result mid bytes
                    std       $01,s     store updated mid bytes
                    bcc       MulCarry1 no carry — skip increment
                    inc       ,s        propagate carry to high word
MulCarry1           lda       $04,s     multiplicand high byte
                    ldb       $09,s     multiplier low byte
                    mul                 partial product: hi×lo
                    addd      $01,s     add into result mid bytes
                    std       $01,s     store updated mid bytes
                    bcc       MulCarry2 no carry — skip increment
                    inc       ,s        propagate carry to high word
MulCarry2           lda       $04,s     multiplicand high byte
                    ldb       $08,s     multiplier high byte
                    mul                 partial product: hi×hi
                    addd      ,s        add into result high word
                    std       ,s        store final high word
                    ldx       $06,s     load return address / old X
                    stx       $08,s     restore return address
                    ldx       ,s        load high word of result
                    ldd       $02,s     load low word of result
                    leas      $08,s     restore stack
                    rts                 return with 32-bit result in X:D


                    tstb                (dead — arithmetic right shift entry)
                    beq       ShiftReturn (dead)

AShiftRightLoop     asr       $02,s     arithmetic shift right high byte
                    ror       $03,s     rotate right into low byte
                    decb                decrement shift count
                    bne       AShiftRightLoop more shifts remaining
                    bra       ShiftReturn done shifting

LShiftRight         tstb                test shift count
                    beq       ShiftReturn zero — nothing to shift

LShiftRightLoop     lsr       $02,s     logical shift right high byte
                    ror       $03,s     rotate right into low byte
                    decb                decrement shift count
                    bne       LShiftRightLoop more shifts remaining


ShiftReturn         ldd       $02,s     load shifted result high word
                    pshs      b,a       push high word
                    ldd       $02,s     load shifted result again
                    std       $04,s     store for return path
                    ldd       ,s        load pushed high word
                    leas      $04,s     restore stack
                    rts                 return with shifted result



LShiftLeft          tstb                test shift count
                    beq       ShiftReturn zero — nothing to shift
LShiftLeftLoop      lsl       $03,s     logical shift left low byte
                    rol       $02,s     rotate left into high byte
                    decb                decrement shift count
                    bne       LShiftLeftLoop more shifts remaining
                    bra       ShiftReturn done shifting


*************************************************
*
*  Found in stat.a c-compiler sources
*  getstat code (code,path,buffer)
*
*** See
***  Section 3 - C System Calls page 3-16
***  of the Microware C compiler user's guide
***  for interesting info on "Code" meanings
*

*  Get status - Returns the status of a file or device
*               Wildcard call exit status differs based on cal code
* entry:
*       a -> path number
*       b -> function code
*
* exit:
*       exit status differs based on cal code
*
* error:
*       CC -> Carry set on error (usually)
*       b  -> error code
*

getstat             lda       $05,s     get the path number
                    ldb       $03,s     get the code
                    beq       getst30   code is 0 ? Buffer (SS.Opt)
                    cmpb      #SS.Ready
                    beq       getst40   data available scf dev
                    cmpb      #SS.EOF
                    beq       getst40   EOF & error check
                    cmpb      #SS.Size
                    beq       getst10
                    cmpb      #SS.Pos   file position
                    beq       getst10


*  can't do other codes
                    ldb       #E$UnkSvc load error unknow service code
                    lbra      _os9err   head for error routine


* Code 2
* entry:
*       a -> path number
*       b -> function code 2 (SS.Size)
*
* exit:
*       x -> most significant 16 bits of the current file size
*       u -> least significant 16 bits of the current file size
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)
*
* Code 5
* entry:
*       a -> path number
*       b -> function code 5 (SS.Pos)
*
* exit:
*       x -> most significant 16 bits of the current file position
*       u -> least significant 16 bits of the current file position
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)
*

getst10             pshs      u         stack u since getstt modifies it
                    os9       I$GetStt
                    bcc       getst20   successful ?? go store info
                    puls      u         otherwise pop our u
                    lbra      _os9err   head for error procesing

getst20             stx       [<$08,s]  store MSW
                    ldx       $08,s     get address of destination
                    stu       $02,x     store LSW
                    puls      u         restore register variable
                    clra                clear d
                    clrb
                    rts                 return to caller

* Code 0  - 32 bytes into buffer
* entry:
*       a -> path number
*       b -> function code 2 (SS.opt)
*       x -> address to receive the status packet
*
* exit:
*      none
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)
*

getst30             ldx       $06,s     load address to receive status packet


* Code 6  - End of file
* entry:
*       a -> path number
*       b -> function code 6 (SS.eof)
*
* exit:
*      If there is NO end of file
*       CC -> carry clear
*       b  -> $00 (zeroed)
*
*      If there IS an end of file
*       CC -> carry set
*       b  -> $D3 (E$EOF)
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)
*

getst40             os9       I$GetStt  make the cal
                    lbra      _sysret

*****************************************************
*
*  Found in stat.a c-compiler sources
*  setstat(code,failname,buffer)
*  setstat(code,failname,size)
*
*** See
***  Section 3 - C System Calls page 3-37
***  of the Microware C compiler user's guide
***  for interesting info on "Code" meanings
*
* Set status - Returns the status of a file or device
*               Wildcard call exit status differs based on cal code
* entry:
*       a -> path number
*       b -> function code
*
* exit:
*       exit status differs based on cal code
*
* error:
*       CC -> Carry set on error (usually)
*       b  -> error code
*
*
* setstat(code,path,buffer) or
* setstat(code,path,offset)

setsat
                    lda       $05,s     get the path number
                    ldb       $03,s     get the code
                    beq       setst10   code is 0
                    cmpb      #SS.Size  code is 2
                    beq       setst20
*                         No other codes permitted
                    ldb       #E$UnkSvc unknow service code
                    lbra      _os9err

* Code 0
* entry:
*       a -> path number
*       b -> function code 0 (SS.opt)
*       x -> address to receive the status packet
*
* exit:
*      none
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)
*

setst10             ldx       $06,s     x gets the address of the status packet
                    os9       I$SetStt
                    lbra      _sysret

* Code 2
* entry:
*       a -> path number
*       b -> function code 2 (SS.Size)
*
* exit:
*       x -> most significant 16 bits of the desired file size
*       u -> least significant 16 bits of the desired file size
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)
*

setst20             pshs      u         stack the u since setstat modifies it
                    ldx       $08,s     get MSW
                    ldu       $0A,s     get LSW
                    os9       I$SetStt  make the call
                    puls      u         bring back the orig u
                    lbra      _sysret   return
*
*  end of getstat & setstat
*
*
*****************************************************
*
*  Found in access.a c-compiler sources
*  access(fname,perm)
*
*** See
***  Section 3 - C System Calls page 3-4
***  of the Microware C compiler user's guide
***  for interesting info
*

* Open Path - Opens a path to the an existing file or device
*             as specified by the path list
* entry:
*       a -> access mode (D S PE PW PR E W R)
*       x -> address of the path list
*
* exit:
*       a -> path number
*       x -> address of the last btye of the path list + 1
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)
*
* Close Path - Terminates I/O path
*              (performs an impledd I$Detach call)
* entry:
*       a -> path number
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)


* access test
access
                    ldx       $02,s     get address of path list
                    lda       $05,s     get access mode (permissions)
                    os9       I$Open    attempt to open
                    bcs       access10  didn't open ? no need to
                    os9       I$Close   Close it
access10            lbra      _sysret   return


* open a path
open                ldx       $02,s     get address of the path list
                    lda       $05,s     get access mode permisions
                    os9       I$Open    attempt the opoen
                    lbcs      _os9err   didn't open go to error handler
                    tfr       a,b       path is open put a in b
                    clra                clear a
                    rts                 return

* close a path
close               lda       $03,s     get path number
                    os9       I$Close   go close it
                    lbra      _sysret   return

* mknod (name,mode)
* Make Directory - Creates an initializes a dircectory
*
* entry:
*       b -> directory attributes
*       x -> address of the path list
*
* exit:
*       x -> address of the last btye of the path list + 1
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)

mknod               ldx       $02,s     get address of the path list
                    ldb       $05,s     get access mode permission
                    os9       I$MakDir  make the call
                    lbra      _sysret   return



* create (fname,mode)
* Create File - Creates and opens a disk file
*
* entry:
*       a -> access mode (write or update)
*       b -> file attributes
*       x -> address of the path list
*
* exit:
*       a -> path number
*       x -> address of the last btye of the path list + 1;
*            trailing blanks are skipped.
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)

creat               ldx       $02,s     get address of the path list
                    lda       $05,s     get access modes
                    tfr       a,b       proto attr
                    andb      #EPEXEC.  save exec bits public and owner
                    orb       #pmode    now add the default modes
                    os9       I$Create  go make the file
                    bcs       creat10   failed creation ?
ccret               tfr       a,b       move path to b
                    clra                clear a
                    rts                 return

creat10             cmpb      #E$CEF    already there ?
                    lbne      _os9err   no a different error bail out

*  is it a directory although we want a file instead?
                    lda       $05,s     get the mode
                    bita      #$80      trying to create a directrory?
                    lbne      _os9err   yes - bail out

*  if already there attempt to open with proper access rights
                    anda      #$07      access mode bits
                    ldx       $02,s     get the name again
                    os9       I$Open    try and open it
                    lbcs      _os9err   still fails - bail out


* Set Stat Code 2 (SS.SIZE)
* entry:
*       a -> path number
*       b -> function code 2 (SS.Size)
*
* exit:
*       x -> most significant 16 bits of the desired file size
*       u -> least significant 16 bits of the desired file size
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)
*
                    pshs      u,a       we got it open Yippee
                    ldx       #$0000    set file size
                    leau      ,x        to zero
                    ldb       #SS.Size  set function code
*                       path number of open file is in a from I$Iopen
                    os9       I$SetStt  make the call
                    puls      u,a       pop u and a back
                    bcc       ccret     contine as we have created the file

                    pshs      b         set stat fail ? save error code
                    os9       I$Close   call close on file
                    puls      b         pop the setstat error code
                    lbra      _os9err   head for error handler


* unlink(fname)
* Delete File - Deletes a specified disk file
* entry:
*       x -> address of the path list
*
* exit:
*       x -> address of the last btye of the path list + 1;
*            trailing blanks are skipped.
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)
*

unlink              ldx       $02,s     get address of the path list
                    os9       I$Delete  make the call
                    lbra      _sysret   return

* dup(fildes)
* Duplicate Path - Returns a synonymous path number
* entry:
*       a -> old path number (number of path to duplicate)
*
* exit:
*       a -> new path number if NO error
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)
*

dup                 lda       $03,s     get path number
                    os9       I$Dup     make the call
                    lbcs      _os9err   didn't dup go to error handler
                    tfr       a,b       move the new path num into b
                    clra                clear a
                    rts                 return

*
*  end of access code
*****************************************************
*
*  Found in io.a c-compiler sources
*
*** See
***  Section 3 - C System Calls
***  of the Microware C compiler user's guide
***  for interesting info
*
* Read  - Reads n bytes from the specified path
* entry:
*       a -> path number
*       x -> address in which to stor the data
*       y -> is the number of bytes to read
*
* exit:
*       y -> number of bytes read
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)


read
ReadFuncEntry       pshs      y         stack current y
                    ldx       $06,s     get address to store at
                    lda       $05,s     get path number
                    ldy       $08,s     get number of bytes to read
                    pshs      y         stack the number of to read also
                    os9       I$Read    make the call


read1               bcc       rdexit    no problem if carry clear
                    cmpb      #E$EOF    is it end of file ??
                    bne       read10    nope then head for error handler
                    clra                was the end of the file
                    clrb                then clear a & b
                    puls      pc,y,x    pop the stacked values (cheap rts)

read10              puls      y,x
                    lbra      _os9err
rdexit              tfr       y,d
                    puls      pc,y,x




* Read Line with Editing  - Reads text line with editting
* entry:
*       a -> path number
*       x -> address in which to stor the data
*       y -> is the max number of bytes to read
*
* exit:
*       y -> number of bytes read
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)

readln
ReadLnFuncEntry     pshs      y         save data pointer
                    lda       $05,s     get the path number
                    ldx       $06,s     get the buffer address
                    ldy       $08,s     get the number to read
                    pshs      y         save request for later
                    os9       I$ReadLn  read it
                    bra       read1     always go back test for eof

write
WriteFuncEntry      pshs      y         save data pointer
                    ldy       $08,s     get count
                    beq       write10
                    lda       $05,s     get file number
                    ldx       $06,s     get buffer address
                    os9       I$Write   write it

write1              bcc       write10   good write head out
                    puls      y         error in writing ? get data pointer
                    lbra      _os9err   head for error handler

write10             tfr       y,d       good write
                    puls      pc,y      return

writeln
WriteLnFuncEntry    pshs      y         save data pointer
                    ldy       $08,s     get the count
                    beq       write10   count zero ??  go to return
                    lda       $05,s     something to write get path number
                    ldx       $06,s     get buffer address
                    os9       I$WritLn  write it
                    bra       write1    goto return

*  lseek(fd, offset, type)
lseek               pshs      u         save the register variable
                    ldd       10,s      get type
                    bne       lseek10   non-zero — not SEEK_SET
                    ldu       #$0000    SEEK_SET: offset high word = 0
                    ldx       #$0000    SEEK_SET: offset low word = 0
                    bra       doseek    seek to absolute position

lseek10             cmpd      #$0001    from here?
                    beq       here
                    cmpd      #$0002    from the end?
                    beq       frmend
*                      otherwise it was passed a bad type
*        ldb   #$F7
                    ldb       #E$SEEK

lserr               clra                seek error routine
                    std       >errno,y  was $01b1
                    ldd       #-1       $FFFF
                    leax      >_flacc,y $01a5
                    std       ,x
                    std       $02,x
                    puls      pc,u      return

* from the end
frmend              lda       $05,s     get the path number
                    ldb       #SS.size  $02 file size code
                    os9       I$GetStt  get the file size
                    bcs       lserr     if error go to error code

                    bra       doseek    if not seek to position

here                lda       $05,s     get path number
                    ldb       #SS.pos   $05 file position
                    os9       I$GetStt  get the postion
                    bcs       lserr     if error go to error code

doseek              tfr       u,d       work on the LSW first
                    addd      $08,s     add low offset word
                    std       _flacc+2,y store low word of seek target
                    tfr       d,u       save low word in U
                    tfr       x,d       work on high word
                    adcb      $07,s     add carry + high offset low byte
                    adca      $06,s     add high offset high byte
                    bmi       lserr     seek is before the beginning of the file
                    tfr       d,x       save high word in X
                    std       _flacc,y  store high word of seek target

                    lda       $05,s     get the path number
                    os9       I$Seek
                    bcs       lserr     if error go to error code

                    leax      _flacc,y
                    puls      pc,u      return

sbrk                ldd       memend,y  get hi bound
*         ldd   >$01a3,y  disassembly
*         pshs  b,a       disassembly
                    pshs      d         save it
                    ldd       $04,s     get required size
                    cmpd      spare,y   any spare left
*         bcs   L1497     disassembly
                    blo       sbrk20

*  have to get some from the system
                    addd      memend,y  add current size
                    pshs      y         save data pointer
                    subd      ,s        adjust for base
                    os9       F$Mem     re-size memory
                    tfr       y,d       save the high bound
                    puls      y         restore the data paointer
                    bcc       sbrk10    branch if NO error
                    ldd       #-1       return error code
                    leas      $02,s     junk scratch
                    rts

sbrk10              std       memend,y  save new memory address
                    addd      spare,y   add in spare bytes ($01CD)
                    subd      ,s        less old base
                    std       spare,y   is new spare value ($01CD)

*  now spare is big enough
sbrk20              leas      $02,s     junk scratch    L1497
                    ldd       spare,y   get spare count
                    pshs      d
*        pshs  b,a
                    subd      $04,s     less size
                    std       spare,y   update value
                    ldd       memend,y  get hi bound
                    subd      ,s++      base of free memeory
                    pshs      d         save it
*        pshs  b,a

                    clra                clear fill byte (zero)
                    ldx       ,s        load start of new memory region
sbrk30              sta       ,x+       clear new memory
                    cmpx      memend,y  reached new memend?
                    bcs       sbrk30    no — clear next byte
*        puls  pc,b,a
                    puls      pc,d      return

*   get memory within data allocation
ibrk                ldd       $02,s     get the size
                    addd      _mtop,y   add in the current top
                    bcs       ibrk20    if it wraps round - error
                    cmpd      _stbot,y  overlap stack
                    bcc       ibrk20    yes error
*        pshs  b,a
                    pshs      d         no save top
                    ldx       _mtop,y   reset to the bottom

                    clra                fill byte = 0 (zero-initialize)
sbloop              cmpx      ,s        reached the end of new block?
                    bcc       ibrk10    yes - done clearing
                    sta       ,x+       nope clear and bump
                    bra       sbloop

ibrk10              ldd       _mtop,y   return value (old top = allocated start)
                    puls      x         restore new top pointer
                    stx       _mtop,y   save for next time
                    rts                 return with allocated block pointer


ibrk20              ldd       #-1       return memory full
                    rts

*****************************
*   stat.a code
*

_os9err             clra                clear high byte
                    std       >errno,y  indicate in system error indicator
                    ldd       #-1       error condition ($FFFF)
                    rts                 return -1 to caller

_sysret             bcs       _os9err   carry set → system call error
                    clra                clear "d" high byte
                    clrb                clear "d" low byte
                    rts                 return 0 (success)


* normal exit - buffers flushed if there are any
exit                lbsr      ExitPreflushStub pre-exit flush hook (stub)

                    lbsr      CloseAllStreams close all open streams before exit



* abnormal exit - no buffer flushing
* the argument to either exit entry is taken to be the
* F$EXIT status

_exit               ldd       $02,s     get the exit status
                    os9       F$Exit    toodle-loo

ExitPreflushStub    rts

********************************************************************
* end of executable text

etext               equ       *
InitDataTbl         fcb       $00,$01,$00,$01,$62,$74,$4F ....btO
InitDataRow08       fcb       $43,$00,$27,$10,$03,$E8,$00,$64 C.'..h.d
InitDataRow10       fcb       $00,$0A,$00,$0D,$6C,$78,$00,$00 ....lx..
InitDataRow18       fcb       $00,$00,$00,$00,$00,$00,$01,$00 ........
InitDataRow20       fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
InitDataRow28       fcb       $00,$00,$00,$02,$00,$01,$00,$00 ........
InitDataRow30       fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
InitDataRow38       fcb       $42,$00,$02,$00,$00,$00,$00,$00 B.......
InitDataRow40       fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
InitDataRow48       fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
InitDataRow50       fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
InitDataRow58       fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
InitDataRow60       fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
InitDataRow68       fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
InitDataRow70       fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
InitDataRow78       fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
InitDataRow80       fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
InitDataRow88       fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
InitDataRow90       fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
InitDataRow98       fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
InitDataRowA0       fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
InitDataRowA8       fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
InitDataRowB0       fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
InitDataRowB8       fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
InitDataRowC0       fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
InitDataRowC8       fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
InitDataRowD0       fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
InitDataRowD8       fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
InitDataRowE0       fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
CharClassTbl        fcb       $01,$01,$01,$01,$01,$01,$01,$01 ........
CharClassRow0F      fcb       $01,$11,$11,$01,$11,$11,$01,$01 ........
CharClassRow0F_B    fcb       $01,$01,$01,$01,$01,$01,$01,$01 ........
CharClassRow10      fcb       $01,$01,$01,$01,$01,$01,$01,$01 ........
CharClassRow18      fcb       $30,$20,$20,$20,$20,$20,$20,$20 0
CharClassRow20      fcb       $20,$20,$20,$20,$20,$20,$20,$20
CharClassRow28      fcb       $48,$48,$48,$48,$48,$48,$48,$48 HHHHHHHH
CharClassRow30      fcb       $48,$48,$20,$20,$20,$20,$20,$20 HH
CharClassRow38      fcb       $20,$42,$42,$42,$42,$42,$42,$02 BBBBBB.
CharClassRow40      fcb       $02,$02,$02,$02,$02,$02,$02,$02 ........
CharClassRow48      fcb       $02,$02,$02,$02,$02,$02,$02,$02 ........
CharClassRow50      fcb       $02,$02,$02,$20,$20,$20,$20,$20 ...
CharClassRow58      fcb       $20,$44,$44,$44,$44,$44,$44,$04 DDDDDD.
CharClassRow60      fcb       $04,$04,$04,$04,$04,$04,$04,$04 ........
CharClassRow68      fcb       $04,$04,$04,$04,$04,$04,$04,$04 ........
CharClassRow70      fcb       $04,$04,$04,$20,$20,$20,$20,$01 ...    .
ModInfoData         fcb       $00,$00,$00,$01,$00,$0D,$74,$6F ......to
ModuleNameStr       fcb       $63,$67,$65,$6E,$00 cgen.

                    emod
eom                 equ       *
                    end
