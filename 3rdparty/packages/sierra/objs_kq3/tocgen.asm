********************************************************************
* TOCGEN - Kings Quest III Table of Contents module
*
*        Module header for original tocgen
*
*
*        Header for : tocgen
*        Module size: $1678  #5752
*        Module CRC : $FD7921 (Good)
*        Hdr parity : $46
*        Exec. off  : $001D  #29
*        Data size  : $054F  #1359
*        Edition    : $01  #1
*        Ty/La At/Rv: $11 $81
*        Prog mod, 6809 Obj, re-ent, R/O
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2003/01/31  Paul W. Zibaila
* Disassembly of original distribution; added comments from the
* C-modules from dev system disk; currently assembles to the
* duplicate of the original module.
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

                    ifp1
                    use       defsfile
                    endc

* Params
MAXARGS             equ       30                  allow for 30 arguments
nfiles              equ       2                   stdin and stdout at least
Stk                 equ       nfiles*256+128+256  stdin,stdout,stderr and fudge

* These are probably defined in scfdefs
C$CR                equ       $0D
C$SPC               equ       $20
C$COMA              equ       $2C
C$DQUt              equ       $22
C$SQUT              equ       $27


* These should be defined somewhere
stdin               equ       0
stdout              equ       1
stderr              equ       2

* These should be defined somewhere
pmode               equ       $0b                 r/w for owner, r for others
EPEXEC.             equ       %00100100           mask for public and owner executes



* OS-9 Header info

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
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
u0000               rmb       1                   I think this is the __$$ fcb 0 vsect.
dpsiz               rmb       1
u0002               rmb       2
u0004               rmb       2
u0006               rmb       2
u0008               rmb       2
u000A               rmb       1
u000B               rmb       2

u000D               rmb       2
u000F               rmb       2
u0011               rmb       1
u0012               rmb       2
u0014               rmb       335

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

argv                rmb       2*MAXARGS           pointers to args
argc                rmb       2
_sttop              rmb       2

memend              rmb       2                   end of memory                      ($01a3)
_flacc              rmb       8                   floating point & longs accumulator ($01A5)
_mtop               rmb       2                   current non-stack memory top
_stbot              rmb       2                   current stack bottom limit
errno               rmb       2                   global error holder                ($01b1)

varnum1             rmb       2                   ($01b3)
varnum2             rmb       10                  ($01b5)
varnum3             rmb       10                  ($01bf)
varnum4             rmb       2                   ($01c9)
varnum5             rmb       2                   ($01cb)
spare               rmb       2                   from mem.a                       ($01CD)
end                 equ       .                   End of unitialized data          ($01CF)


stack               rmb       Stk
size                equ       .

name                equ       *
                    fcs       /tocgen/            module name
                    fcb       $01                 edition byte

********************************************************************
*  Start of code from cstart.a file.
*
*  The movebytes routine
*
* move bytes (Y=From addr, U=To addr, X=Count)
*


movebytes           lda       ,y+                 get a byte
                    sta       ,u+                 put a byte
                    leax      -1,x                dec the count
                    bne       movebytes           and round again
                    rts

_cstart
start               equ       *                   _cstart code
                    pshs      y                   save top of mem
                    pshs      u                   save the data beginning address

*
* This code segment initializes the first 256
* (possible) direct page bytes
*

                    clra                          set up to clear
                    clrb                          256 bytes
csta05              sta       ,u+                 clear dp bytes
                    decb
                    bne       csta05

*
* This code segment sets up to move the
* initialized data from the code section
* to the data area.
*


csta10              ldx       ,s                  get the beginning of data address
                    leau      ,x                  (tfr x,u)
                    leax      end,x               get the end of bss address
**       leax  >$01CF,x   absolute address of the operand ??
                    pshs      x                   save it
                    leay      >etext,pcr          point to dp-data count word

*
* now move the initialized direct-page
* data into position.
*

                    ldx       ,y++                get count of dp-data to be moved
                    beq       csta15              bra if none (L003E old label)
                    bsr       movebytes           move dp data into position (L0014)

*
* now move the initialized non direct-page
* data into position.
*


                    ldu       $02,s               get beginning address again
csta15              leau      >dpsiz,u            point to where non-dp should start
                    ldx       ,y++                get count of non-dp data to be moved
                    beq       clrbss              (L0049 old label)
                    bsr       movebytes           move non-dp data into position

*
*  clear the bss area - starts where the transferred data finishs
*  now clear out the rest of the uninitialized data area.
*

                    clra
clrbss              cmpu      ,s                  reached the end ??
                    beq       reldt               if so branch to relocate
                    sta       ,u+                 if not end clear it
                    bra       clrbss              and then go again (L0049 old tag)

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

reldt               ldu       $02,s               restore to data bottom
                    ldd       ,y++                get the data text ref count
                    beq       reldd               (old tag L005F)

******************************************************************
*  this is interesting
*  from the cstart.a code this line is as follows
*
*    this guy points back to line L0000 but where is it
*    at offset zero of course`
*
*
*        leax  >L0000,pcr  point to text ??? line from disassembly

                    leax      btext,pcr           point to text. ---- line from cstart.a
                    lbsr      patch               patch them in (L0162 old tag)

*
*  and now the data-data refs.
*
reldd               ldd       ,y++                get the count of the data refs
                    beq       restack             branch if none (L0068 old tag)
                    leax      ,u                  u was already pointing there
                    lbsr      patch               patch them in (L0162 old tag)

******************************************************************
*
*  this restack is slightly diff from the root.a version in the
*  c-compiler code.
*   restack leas 4,s return scratch
*    leay 0,u tfr u,y (base addr of data to y)
*    puls u high end of allocated data area
*    leax 0,s point to parameters


restack             leas      $04,s               reset stack
                    puls      x                   restore 'memend'
                    stx       >memend,u

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

                    sty       >argv,u
                    ldd       #$0001              at least one arg
                    std       >argc,u
                    leay      >argv+2,u           point y at second slot
                    leax      ,s                  point x at params
                    lda       ,x+                 initialize

aloop               ldb       >argc+1,u
                    cmpb      #MAXARGS-1          about to overflow ??
                    beq       final               branch out

aloop10             cmpa      #C$CR               is it the EOL?
                    beq       final               yep - reached end of the list
                    cmpa      #C$SPC              is it a space
                    beq       aloop20             yep go for the next one
                    cmpa      #C$COMA             is it a comma ?
                    bne       aloop30             no - then a word has started

aloop20             lda       ,x+                 yes it's a comma bump to next char
                    bra       aloop10             and loop again

aloop30             cmpa      #C$DQUT             a quoted string (")
                    beq       aloop40             yep - go process it
                    cmpa      #C$SQUT             a quoted string (')
                    bne       aloop60             not quotes double or single move on

aloop40             stx       ,y++                save the address in vector
                    inc       >argc+1,u           bump up the arg count
                    pshs      a                   save the delim char

qloop               lda       ,x+                 get the next char
                    cmpa      #C$CR               EOL?
                    beq       aloop50             go clean up
                    cmpa      ,s                  is it a delim char
                    bne       qloop               no then lop to the next

aloop50             puls      b                   clean up stack
                    clr       -$01,x
                    cmpa      #C$CR
                    beq       final
                    lda       ,x+
                    bra       aloop

aloop60             leax      -$01,x              point at first char
                    stx       ,y++                put address in vector
                    leax      $01,x               bump it back
                    inc       >argc+1,u           bump up the arg count

* at least one none space character has been seen
aloop70             cmpa      #C$CR               Have
                    beq       loopend             we
                    cmpa      #C$SPC              reached
                    beq       loopend             the end
                    cmpa      #C$COMA             comma?
                    beq       loopend             look some more
                    lda       ,x+
                    bra       aloop70

loopend             clr       -$01,x
                    bra       aloop

*`
* Now put the pointers on the stack
*
final               leax      >argv,u             get the address of the arg vector
                    pshs      x                   goes on the stack first
                    ldd       >argc,u             get the arg count

                    pshs      b,a
*        pshs  d          push it on the stack

                    leay      0,u                 C progs. assume data and bss offset from y
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
                    bsr       _fixtop             set various variables

*******************************************************
*
*    go to the main event
*
                    lbsr      main                call our program

*  clean up and bit and out we go

                    clr       ,-s                 pushzero clear a byte on the stack
                    clr       ,-s                 pushzero clear a byte on the stack
                    lbsr      exit                and a dummy return address
*  should never return here


********************************************************
*
*
*

_fixtop             leax      end,y               get the initial memeory end
*                         (unitilaized data "bss"address)
                    stx       _mtop,y             its the current memory top
                    sts       _sttop,y            this is really two bytes short
                    sts       _stbot,y
                    ldd       #-126               give ourselfs some breathing space

*        stx   >$01AD,y   ---- disassembly
*        sts   >$01A1,y   ---- disassembly
*        sts   >$01AF,y   ---- disassembly
*        ldd   #$FF82     ---- disassembly

_stkchec
_stkcheck
                    leax      d,s                 calculate the requested size
                    cmpx      _stbot,y            is it lower than already reserved?
*        bcc   stk10      ---- disassembly
                    bhs       stk10               no -return
                    cmpx      _mtop,y             is it lower than possible?
*        bcs   ftserr     ---- disassembly
                    blo       fsterr              yes - can't cope
                    stx       _stbot,y            no - reserve it
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

fsterr              leax      <fixserr,pcr        load x wit address of error strin
                    ldb       #E$MEMFUL           load b with the error code number

erexit              pshs      b                   stack the error number
                    lda       #stderr             set path to standard error output
                    ldy       #$0064              set size more than needed
                    os9       I$WritLn            write it
*                            pop the error code back
                    clr       ,-s                 pushzero clear MSB of status
                    lbsr      _exit               and out
* no return here

* stacksize()
* returns the extent of stack requested
* can be used by programmer for guidance
* in sizing memory at compile time

stacksiz
                    ldd       _sttop,y            top of stack on entry
                    subd      _stbot,y            subtract current reserved limit
                    rts


* freemem()
* returns the current size of the free memory area
*

freemem
                    ldd       _stbot,y
                    subd      _mtop,y
                    rts



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

patch               pshs      x                   save the base
                    leax      d,y                 half way up the list
                    leax      d,x                 top of list
                    pshs      x                   save it as place to stop

* we do not come to this routine with
* a zero count (check!) so a test at the loop top
* is unnecessary

patch10             ldd       ,y++                get the offset
                    leax      d,u                 point to location
                    ldd       0,x                 get the relative reference
                    addd      2,s                 add in the base
                    std       0,x                 store the absolute reference
                    cmpy      0,s                 reached the top?
                    bne       patch10             no - round again

                    leas      4,s                 reset the stack
                    rts                           and return




main                pshs      u
                    ldd       #$FD57
                    lbsr      _stkcheck:          check for sufficient stack available:

                    leas      >-$025D,s
                    ldd       >$0261,s
                    cmpd      #$0002              looks like we check for two args
                    beq       gotargs             if good number go
                    ldd       [>$0263,s]
                    pshs      b,a
                    leax      >usemsg,pcr         load address of usage message
                    pshs      x                   push it on the stack

                    lbsr      L07EF
                    leas      $04,s               clean up stack
                    clra                          clear the exit codes
                    clrb                          from d
                    pshs      b,a                 push it on the stack
                    lbsr      exit


                    leas      $02,s

gotargs             leax      >L04C8,pcr          Load address data after usage message
                    pshs      x
                    ldx       >$0265,s
                    ldd       $02,x
                    pshs      b,a
                    lbsr      L06CF
                    leas      $04,s
                    std       >$025B,s
                    bne       L01E1
                    ldx       >$0263,s
                    ldd       $02,x
                    pshs      b,a
                    leax      >cntread,pcr        Load address can't open for reading message
                    pshs      x
                    lbsr      L07EF
                    leas      $04,s
                    clra
                    clrb
                    pshs      b,a
                    lbsr      exit

                    leas      $02,s
L01E1               clra
                    clrb
                    std       >$0082,s
                    lslb
                    rola
                    leax      ,s
                    leax      d,x
                    clra
                    clrb
                    std       ,x
                    leax      >$0084,s
                    stx       >$0255,s
                    lbra      L0396

L01FC               ldd       >$0257,s
                    addd      #$0001
                    std       >$0257,s
L0207               ldb       [>$0257,s]
                    cmpb      #C$CR
                    beq       L021F
                    ldb       [>$0257,s]
                    cmpb      #$64                'd
                    beq       L021F
                    ldb       [>$0257,s]
                    cmpb      #$44                'D
                    bne       L01FC
L021F               ldb       [>$0257,s]
                    cmpb      #C$CR
                    beq       L0247
                    ldd       >$0257,s
                    addd      #$0001
                    std       >$0257,s
                    pshs      b,a
                    lbsr      L11C2
                    leas      $02,s
                    ldx       >$0255,s
                    leax      $01,x
                    stx       >$0255,s
                    stb       -$01,x
                    bra       L026E

L0247               leax      >$0204,s
                    pshs      x
                    leax      >dsknmsg,pcr        Load address of disk number ?? mising
                    pshs      x
                    lbsr      L07EF
                    leas      $04,s
                    clra
                    clrb
                    pshs      b,a
                    lbsr      exit
                    leas      $02,s
                    bra       L026E
L0263               ldd       >$0257,s
                    addd      #$0001
                    std       >$0257,s
L026E               ldb       [>$0257,s]
                    cmpb      #C$CR
                    beq       L0286
                    ldb       [>$0257,s]
                    cmpb      #$73                's
                    beq       L0286
                    ldb       [>$0257,s]
                    cmpb      #$53                'S
                    bne       L0263
L0286               ldb       [>$0257,s]
                    cmpb      #C$CR
                    beq       L02CE
                    ldd       >$0257,s
                    addd      #$0001
                    std       >$0257,s
                    pshs      b,a
                    lbsr      L11C2
                    leas      $02,s
                    stb       >$025A,s
                    cmpb      #$01
                    beq       L02B0
                    ldb       >$025A,s
                    cmpb      #$02
                    bne       L02C2
L02B0               ldb       >$025A,s
                    ldx       >$0255,s
                    leax      $01,x
                    stx       >$0255,s
                    stb       -$01,x
                    bra       L02E8
L02C2               leax      >$0204,s
                    pshs      x
                    leax      >invside,pcr        load address of the invalid side message
                    bra       L02D8
L02CE               leax      >$0204,s
                    pshs      x
                    leax      >snmiss,pcr         load address of side number missing mesg
L02D8               pshs      x
                    lbsr      L07EF
                    leas      $04,s
                    clra
                    clrb
                    pshs      b,a
                    lbsr      exit
                    leas      $02,s
L02E8               clra
                    clrb
                    stb       >$0259,s
                    bra       L0342
L02F0               ldd       >$0257,s
                    addd      #$0001
                    std       >$0257,s
L02FB               ldb       [>$0257,s]
                    cmpb      #C$CR
                    beq       L0313
                    ldb       [>$0257,s]
                    cmpb      #$76                's
                    beq       L0313
                    ldb       [>$0257,s]
                    cmpb      #$56                'S
                    bne       L02F0
L0313               ldb       [>$0257,s]
                    cmpb      #C$CR
                    beq       L034A
                    ldd       >$0257,s
                    addd      #$0001
                    std       >$0257,s
                    pshs      b,a
                    lbsr      L11C2
                    leas      $02,s
                    ldx       >$0255,s
                    leax      $01,x
                    stx       >$0255,s
                    stb       -$01,x
                    ldd       #$0001
                    stb       >$0259,s
                    bra       L0342
L0342               ldb       [>$0257,s]
                    cmpb      #C$CR
                    bne       L02FB
L034A               ldb       >$0259,s
                    bne       L036A
                    leax      >$0204,s
                    pshs      x
                    leax      >vnmiss,pcr         load address of volume missing mesg
                    pshs      x
                    lbsr      L07EF
                    leas      $04,s
                    clra
                    clrb
                    pshs      b,a
                    lbsr      exit                head out

                    leas      $02,s
L036A               ldx       >$0255,s
                    ldb       -$01,x
                    sex
                    orb       #$80
                    stb       -$01,x
                    ldd       >$0082,s
                    addd      #$0001
                    std       >$0082,s
                    lslb
                    rola
                    leax      ,s
                    leax      d,x
                    pshs      x
                    leax      >$0086,s
                    pshs      x
                    ldd       >$0259,s
                    subd      ,s++
                    std       [,s++]
L0396               ldd       >$025B,s
                    pshs      b,a
                    ldd       #$0051
                    pshs      b,a
                    leax      >$0208,s
                    pshs      x
                    lbsr      L075C
                    leas      $06,s
                    std       >$0257,s
                    lbne      L0207
                    clra
                    clrb
                    bra       L03D7
L03B8               ldd       >$0080,s
                    lslb
                    rola
                    leax      ,s
                    leax      d,x
                    ldd       ,x
                    pshs      x,b,a
                    ldd       >$0086,s
                    lslb
                    rola
                    addd      ,s++
                    std       [,s++]
                    ldd       >$0080,s
                    addd      #$0001
L03D7               std       >$0080,s
                    ldd       >$0080,s
                    cmpd      >$0082,s
                    bcs       L03B8
                    ldd       >$025B,s
                    pshs      b,a
                    lbsr      L0DE4
                    leas      $02,s
                    leax      >L0548,pcr
                    pshs      x
                    leax      >dpsiz,y
                    pshs      x
                    lbsr      L06CF
                    leas      $04,s
                    std       >$025B,s
                    bne       L0422

                    leax      >dpsiz,y
                    pshs      x
                    leax      >cntwrit,pcr        load address of can't write mesg
                    pshs      x
                    lbsr      L07EF
                    leas      $04,s
                    clra
                    clrb
                    pshs      b,a
                    lbsr      exit

                    leas      $02,s
L0422               ldd       >$025B,s
                    pshs      b,a
                    ldd       >$0084,s
                    pshs      b,a
                    lbsr      egg2
                    leas      $04,s
                    cmpd      #$FFFF
                    beq       L0481
                    ldd       >$025B,s
                    pshs      b,a
                    ldd       #$0001
                    pshs      b,a
                    ldd       >$0086,s
                    lslb
                    rola
                    pshs      b,a
                    leax      $06,s
                    pshs      x
                    lbsr      L07A5
                    leas      $08,s
                    std       -$02,s
                    beq       L0481
                    ldd       >$025B,s
                    pshs      b,a
                    ldd       #$0001
                    pshs      b,a
                    leax      >$0088,s
                    pshs      x
                    ldd       >$025B,s
                    subd      ,s++
                    pshs      b,a
                    leax      >$008A,s
                    pshs      x
                    lbsr      L07A5
                    leas      $08,s
                    std       -$02,s
                    bne       L049B
L0481               leax      >dpsiz,y
                    pshs      x
                    leax      errwrit,pcr         load address of error writing mesg
                    pshs      x
                    lbsr      L07EF
                    leas      $04,s
                    clra
                    clrb
                    pshs      b,a
                    lbsr      exit

                    leas      $02,s
L049B               ldd       >$025B,s
                    pshs      b,a
                    lbsr      L0DE4
                    leas      $02,s
                    clra
                    clrb
                    pshs      b,a
                    lbsr      exit
                    leas      $02,s
                    leas      >$025D,s
                    puls      pc,u

usemsg              fcc       /Usage: %s pathlist/ c-string
                    fcb       $00                 null terminator c-string


L04C8               fcb       $72,$00             what am I

cntread             fcc       /Can't open %s for reading./ c-string
                    fcb       C$CR,$00            cr and null term

dsknmsg             fcc       /Disk number missing:/ c-string
                    fcb       C$CR                with a cr embedded
                    fcc       /%s/                c-string
                    fcb       $00                 null terminator c-string

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

L0548               fcb       $77,$00             what am i

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

egg1                pshs      u                   ***  pshs u incorrectly decoded

L057B               leau      >u0012,y
L057F               ldd       u0006,u
                    clra
                    andb      #$03
                    lbeq      L05F0
                    leau      u000D,u
                    pshs      u
                    leax      >$00E2,y
                    cmpx      ,s++
                    bhi       L057F
                    ldd       #E$PthFul           $00C8
                    std       >errno,y            01b1
                    lbra      L05F4
                    puls      pc,u

L05A0               pshs      u
                    ldu       $08,s
                    bne       L05AA
                    bsr       egg1                ***  pshs u incorrectly decoded
                    tfr       d,u
L05AA               stu       -$02,s
                    beq       L05F4
                    ldd       $04,s
                    std       u0008,u
                    ldx       $06,s
                    ldb       $01,x
                    cmpb      #$2B                '+   ?????
                    beq       L05C2
                    ldx       $06,s
                    ldb       $02,x
                    cmpb      #$2B                '+   ??????
                    bne       L05C8
L05C2               ldd       u0006,u
                    orb       #$03
                    bra       L05E6
L05C8               ldd       u0006,u
                    pshs      b,a
                    ldb       [<$08,s]
                    cmpb      #$72                'r
                    beq       L05DA
                    ldb       [<$08,s]
                    cmpb      #$64                'd
                    bne       L05DF
L05DA               ldd       #$0001
                    bra       L05E2
L05DF               ldd       #$0002
L05E2               ora       ,s+
L05E4               orb       ,s+
L05E6               std       u0006,u
                    ldd       u0002,u
                    addd      u000B,u
                    std       u0004,u
                    std       ,u
L05F0               tfr       u,d
                    puls      pc,u

L05F4               clra
                    clrb
                    puls      pc,u

L05F8               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    std       ,s
                    ldx       $0A,s
                    ldb       $01,x
                    sex
                    tfr       d,x
                    bra       L0629
L060B               ldx       $0A,s
                    ldb       $02,x
                    cmpb      #$2B                '+
                    bne       L0618
                    ldd       #$0007
                    bra       L0620
L0618               ldd       #$0004
                    bra       L0620
L061D               ldd       #$0003
L0620               std       ,s
                    bra       L0639
L0624               leax      $04,s
                    lbra      L0691
L0629               stx       -$02,s
                    beq       L0639
                    cmpx      #$0078
                    beq       L060B
                    cmpx      #$002B
                    beq       L061D
                    bra       L0624
L0639               ldb       [<$0A,s]
                    sex
                    tfr       d,x
                    lbra      L069E
L0642               ldd       ,s
                    orb       #$01
                    bra       L0684
L0648               ldd       ,s
                    orb       #$02
                    pshs      b,a
                    pshs      u
                    lbsr      open:
                    leas      $04,s
                    std       $02,s
                    cmpd      #$FFFF
                    beq       L0673
                    ldd       #$0002
                    pshs      b,a
                    clra
                    clrb
                    pshs      b,a
                    pshs      b,a
                    ldd       $08,s
                    pshs      b,a
                    lbsr      lseek:
                    leas      $08,s
                    bra       L06B8
L0673               ldd       ,s
                    orb       #$02
                    pshs      b,a
                    pshs      u
                    lbsr      creat:
                    bra       L068B
L0680               ldd       ,s
                    orb       #$81
L0684               pshs      b,a
                    pshs      u
                    lbsr      open:
L068B               leas      $04,s
                    std       $02,s
                    bra       L06B8
L0691               leas      -$04,x
L0693               ldd       #$00CB
                    std       >errno,y            01b1
                    clra
                    clrb
                    bra       L06BA
L069E               cmpx      #$0072
                    lbeq      L0642
                    cmpx      #$0061
                    lbeq      L0648
                    cmpx      #$0077
                    beq       L0673
                    cmpx      #$0064
                    beq       L0680
                    bra       L0693
L06B8               ldd       $02,s
L06BA               leas      $04,s
                    puls      pc,u
                    pshs      u
                    clra
                    clrb
                    pshs      b,a
                    ldd       $08,s
                    pshs      b,a
                    ldd       $08,s
                    pshs      b,a
                    lbra      L071A
L06CF               pshs      u
                    ldd       $06,s
                    pshs      b,a
                    ldd       $06,s
                    pshs      b,a
                    lbsr      L05F8
                    leas      $04,s
                    tfr       d,u
                    cmpu      #$FFFF
                    bne       L06EA
                    clra
                    clrb
                    bra       L071F
L06EA               clra
                    clrb
                    bra       L0712
                    pshs      u
                    ldd       $08,s
                    pshs      b,a
                    lbsr      L0DE4
                    leas      $02,s
                    ldd       $06,s
                    pshs      b,a
                    ldd       $06,s
                    pshs      b,a
                    lbsr      L05F8
                    leas      $04,s
                    tfr       d,u
                    stu       -$02,s
                    bge       L0710
                    clra
                    clrb
                    bra       L071F
L0710               ldd       $08,s
L0712               pshs      b,a
                    ldd       $08,s
                    pshs      b,a
                    pshs      u
L071A               lbsr      L05A0
                    leas      $06,s
L071F               puls      pc,u
                    pshs      u,b,a
                    ldu       $06,s
                    bra       L072B
L0727               ldd       ,s
                    stb       ,u+
L072B               leax      >u0012,y
                    pshs      x
                    lbsr      L0F0E
                    leas      $02,s
                    std       ,s
                    cmpd      #$000D
                    beq       L0746
                    ldd       ,s
                    cmpd      #$FFFF
                    bne       L0727
L0746               ldd       ,s
                    cmpd      #$FFFF
                    bne       L0752
                    clra
                    clrb
                    bra       L0758
L0752               clra
                    clrb
                    stb       ,u
                    ldd       $06,s
L0758               leas      $02,s
                    puls      pc,u

L075C               pshs      u
                    ldu       $06,s
                    leas      -$04,s
                    ldd       $08,s
                    std       ,s
                    bra       L0776
L0768               ldd       $02,s
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    cmpb      #C$CR
                    beq       L078F
L0776               tfr       u,d
                    leau      -dpsiz,u
                    std       -$02,s
                    ble       L078F
                    ldd       $0C,s
                    pshs      b,a
                    lbsr      L0F0E
                    leas      $02,s
                    std       $02,s
                    cmpd      #$FFFF
                    bne       L0768
L078F               clra
                    clrb
                    stb       [,s]
                    ldd       $02,s
                    cmpd      #$FFFF
                    bne       L079F
                    clra
                    clrb
                    bra       L07A1
L079F               ldd       $08,s
L07A1               leas      $04,s
                    puls      pc,u

L07A5               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    bra       L07E0
L07AF               clra
                    clrb
                    std       ,s
                    bra       L07CC
L07B5               ldd       $0E,s
                    pshs      b,a
                    ldb       ,u+
                    sex
                    pshs      b,a
                    lbsr      egg2
                    leas      $04,s
                    ldx       $0E,s
                    ldd       $06,x
                    clra
                    andb      #C$SPC
                    bne       L07E9
L07CC               ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      $0A,s
                    blt       L07B5
                    ldd       $02,s
                    addd      #$0001
L07E0               std       $02,s
                    ldd       $02,s
                    cmpd      $0C,s
                    blt       L07AF
L07E9               ldd       $02,s
                    leas      $04,s
                    puls      pc,u

L07EF               pshs      u
                    leax      >$001F,y
                    stx       >varnum1,y          $01B3,y
                    leax      $06,s
                    pshs      x
                    ldd       $06,s
                    bra       L080F
                    pshs      u
                    ldd       $04,s
                    std       >varnum1,y
                    leax      $08,s
                    pshs      x
                    ldd       $08,s
L080F               pshs      b,a
                    leax      >L0CC7,pcr
                    pshs      x
                    bsr       L0841
                    leas      $06,s
                    puls      pc,u
                    pshs      u
                    ldd       $04,s
                    std       >varnum1,y
                    leax      $08,s
                    pshs      x
                    ldd       $08,s
                    pshs      b,a
                    leax      >L0CDA,pcr
                    pshs      x
                    bsr       L0841
                    leas      $06,s
                    clra
                    clrb
                    stb       [>varnum1,y]
                    ldd       $04,s
                    puls      pc,u
L0841               pshs      u
                    ldu       $06,s
                    leas      -$0B,s
                    bra       L0859
L0849               ldb       $08,s
                    lbeq      L0A8A
                    ldb       $08,s
                    sex
                    pshs      b,a
                    jsr       [<$11,s]
                    leas      $02,s
L0859               ldb       ,u+
                    stb       $08,s
                    cmpb      #$25                '%
                    bne       L0849
                    ldb       ,u+
                    stb       $08,s
                    clra
                    clrb
                    std       $02,s
                    std       $06,s
                    ldb       $08,s
                    cmpb      #$2D                '-
                    bne       L087E
                    ldd       #$0001
                    std       >varnum4,y
                    ldb       ,u+
                    stb       $08,s
                    bra       L0884
L087E               clra
                    clrb
                    std       >varnum4,y
L0884               ldb       $08,s
                    cmpb      #$30                '0
                    bne       L088F
                    ldd       #$0030
                    bra       L0892
L088F               ldd       #$0020
L0892               std       >varnum5,y
                    bra       L08B2
L0898               ldd       $06,s
                    pshs      b,a
                    ldd       #$000A
                    lbsr      L1235
                    pshs      b,a
                    ldb       $0A,s
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $06,s
                    ldb       ,u+
                    stb       $08,s
L08B2               ldb       $08,s
                    sex
                    leax      >$00E3,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    bne       L0898
                    ldb       $08,s
                    cmpb      #$2E                '. period
                    bne       L08FB
                    ldd       #$0001
                    std       $04,s
                    bra       L08E5
L08CF               ldd       $02,s
                    pshs      b,a
                    ldd       #$000A
                    lbsr      L1235
                    pshs      b,a
                    ldb       $0A,s
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $02,s
L08E5               ldb       ,u+
                    stb       $08,s
                    ldb       $08,s
                    sex
                    leax      >$00E3,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    bne       L08CF
                    bra       L08FF
L08FB               clra
                    clrb
                    std       $04,s
L08FF               ldb       $08,s
                    sex
                    tfr       d,x
                    lbra      L0A2D
L0907               ldd       $06,s
                    pshs      b,a
                    ldx       <$15,s
                    leax      $02,x
                    stx       <$15,s
                    ldd       -$02,x
                    pshs      b,a
                    lbsr      L0A8E
                    bra       L092F
L091C               ldd       $06,s
                    pshs      b,a
                    ldx       <$15,s
                    leax      $02,x
                    stx       <$15,s
                    ldd       -$02,x
                    pshs      b,a
                    lbsr      L0B4B
L092F               std       ,s
                    lbra      L0A13
L0934               ldd       $06,s
                    pshs      b,a
                    ldb       $0A,s
                    sex
                    leax      >$00E3,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$02
                    pshs      b,a
                    ldx       <$17,s
                    leax      $02,x
                    stx       <$17,s
                    ldd       -$02,x
                    pshs      b,a
                    lbsr      L0B93
                    lbra      L0A0F
L095A               ldd       $06,s
                    pshs      b,a
                    ldx       <$15,s
                    leax      $02,x
                    stx       <$15,s
                    ldd       -$02,x
                    pshs      b,a
                    leax      >varnum2,y
                    pshs      x
                    lbsr      L0AD2
                    lbra      L0A0F
L0976               ldd       $04,s
                    bne       L097F
                    ldd       #$0006
                    std       $02,s
L097F               ldd       $06,s
                    pshs      b,a
                    leax      <$15,s
                    pshs      x
                    ldd       $06,s
                    pshs      b,a
                    ldb       $0E,s
                    sex
                    pshs      b,a
                    lbsr      egg3
                    leas      $06,s
                    lbra      L0A11
L0999               ldx       <$13,s
                    leax      $02,x
                    stx       <$13,s
                    ldd       -$02,x
                    lbra      L0A23
L09A6               ldx       <$13,s
                    leax      $02,x
                    stx       <$13,s
                    ldd       -$02,x
                    std       $09,s
                    ldd       $04,s
                    beq       L09EE
                    ldd       $09,s
                    std       $04,s
                    bra       L09C8
L09BC               ldb       [<$09,s]
                    beq       L09D4
                    ldd       $09,s
                    addd      #$0001
                    std       $09,s
L09C8               ldd       $02,s
                    addd      #$FFFF
                    std       $02,s
                    subd      #$FFFF
                    bne       L09BC
L09D4               ldd       $06,s
                    pshs      b,a
                    ldd       $0B,s
                    subd      $06,s
                    pshs      b,a
                    ldd       $08,s
                    pshs      b,a
                    ldd       <$15,s
                    pshs      b,a
                    lbsr      L0BFE
                    leas      $08,s
                    bra       L0A1D
L09EE               ldd       $06,s
                    pshs      b,a
                    ldd       $0B,s
                    bra       L0A11
L09F6               ldb       ,u+
                    stb       $08,s
                    bra       L09FE
                    leas      -$0B,x
L09FE               ldd       $06,s
                    pshs      b,a
                    leax      <$15,s
                    pshs      x
                    ldb       $0C,s
                    sex
                    pshs      b,a
                    lbsr      L10F2
L0A0F               leas      $04,s
L0A11               pshs      b,a
L0A13               ldd       <$13,s
                    pshs      b,a
                    lbsr      L0C60
                    leas      $06,s
L0A1D               lbra      L0859

L0A20               ldb       $08,s
                    sex
L0A23               pshs      b,a
                    jsr       [<$11,s]
                    leas      $02,s
                    lbra      L0859

L0A2D               cmpx      #$0064              'd
                    lbeq      L0907
                    cmpx      #$006F              'o
                    lbeq      L091C
                    cmpx      #$0078              'x
                    lbeq      L0934
                    cmpx      #$0058              'X
                    lbeq      L0934
                    cmpx      #$0075              'u
                    lbeq      L095A
                    cmpx      #$0066              'f
                    lbeq      L0976
                    cmpx      #$0065              'e
                    lbeq      L0976
                    cmpx      #$0067              'g
                    lbeq      L0976
                    cmpx      #$0045              'E
                    lbeq      L0976
                    cmpx      #$0047              'G
                    lbeq      L0976
                    cmpx      #$0063              'c
                    lbeq      L0999
                    cmpx      #$0073              's
                    lbeq      L09A6
                    cmpx      #$006C              'l
                    lbeq      L09F6
                    bra       L0A20

L0A8A               leas      $0B,s
                    puls      pc,u
L0A8E               pshs      u,b,a
                    leax      >varnum2,y
                    stx       ,s
                    ldd       $06,s
                    bge       L0AC3
                    ldd       $06,s
                    nega
                    negb
                    sbca      #$00
                    std       $06,s
                    bge       L0AB8
                    leax      >L0CEC,pcr
                    pshs      x
                    leax      >varnum2,y
                    pshs      x
                    lbsr      L114C
                    leas      $04,s
                    lbra      L0B8F
L0AB8               ldd       #$002D
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
L0AC3               ldd       $06,s
                    pshs      b,a
                    ldd       $02,s
                    pshs      b,a
                    bsr       L0AD2
                    leas      $04,s
                    lbra      L0B89
L0AD2               pshs      u,y,x,b,a
                    ldu       $0A,s
                    clra
                    clrb
                    std       $02,s
                    clra
                    clrb
                    std       ,s
                    bra       L0AEF
L0AE0               ldd       ,s
                    addd      #$0001
                    std       ,s
                    ldd       $0C,s
                    subd      >$0005,y
                    std       $0C,s
L0AEF               ldd       $0C,s
                    blt       L0AE0
                    leax      >$0005,y
                    stx       $04,s
                    bra       L0B31
L0AFB               ldd       ,s
                    addd      #$0001
                    std       ,s
L0B02               ldd       $0C,s
                    subd      [<$04,s]
                    std       $0C,s
                    bge       L0AFB
                    ldd       $0C,s
                    addd      [<$04,s]
                    std       $0C,s
                    ldd       ,s
                    beq       L0B1B
                    ldd       #$0001
                    std       $02,s
L0B1B               ldd       $02,s
                    beq       L0B26
                    ldd       ,s
                    addd      #$0030
                    stb       ,u+
L0B26               clra
                    clrb
                    std       ,s
                    ldd       $04,s
                    addd      #$0002
                    std       $04,s
L0B31               ldd       $04,s
                    cmpd      >$000D,y
                    bne       L0B02
                    ldd       $0C,s
                    addd      #$0030
                    stb       ,u+
                    clra
                    clrb
                    stb       ,u
                    ldd       $0A,s
                    leas      $06,s
                    puls      pc,u
L0B4B               pshs      u,b,a
                    leax      >varnum2,y
                    stx       ,s
                    leau      >varnum3,y
L0B57               ldd       $06,s
                    clra
                    andb      #$07
                    addd      #$0030
                    stb       ,u+
                    ldd       $06,s
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    std       $06,s
                    bne       L0B57
                    bra       L0B79
L0B6F               ldb       ,u
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
L0B79               leau      -dpsiz,u
                    pshs      u
                    leax      >varnum3,y
                    cmpx      ,s++
                    bls       L0B6F
                    clra
                    clrb
                    stb       [,s]
L0B89               leax      >varnum2,y
                    tfr       x,d
L0B8F               leas      $02,s
                    puls      pc,u
L0B93               pshs      u,x,b,a
                    leax      >varnum2,y
                    stx       $02,s
                    leau      >varnum3,y
L0B9F               ldd       $08,s
                    clra
                    andb      #$0F
                    std       ,s
                    pshs      b,a
                    ldd       $02,s
                    cmpd      #$0009
                    ble       L0BC1
                    ldd       $0C,s
                    beq       L0BB9
                    ldd       #$0041
                    bra       L0BBC
L0BB9               ldd       #$0061
L0BBC               addd      #$FFF6
                    bra       L0BC4
L0BC1               ldd       #$0030
L0BC4               addd      ,s++
                    stb       ,u+
                    ldd       $08,s
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    anda      #$0F
                    std       $08,s
                    bne       L0B9F
                    bra       L0BE4
L0BDA               ldb       ,u
                    ldx       $02,s
                    leax      $01,x
                    stx       $02,s
                    stb       -$01,x
L0BE4               leau      -dpsiz,u
                    pshs      u
                    leax      >varnum3,y
                    cmpx      ,s++
                    bls       L0BDA
                    clra
                    clrb
                    stb       [<$02,s]
                    leax      >varnum2,y
                    tfr       x,d
                    lbra      L0CD6
L0BFE               pshs      u
                    ldu       $06,s
                    ldd       $0A,s
                    subd      $08,s
                    std       $0A,s
                    ldd       >varnum4,y
                    bne       L0C33
                    bra       L0C1B
L0C10               ldd       >varnum5,y
                    pshs      b,a
                    jsr       [<$06,s]
                    leas      $02,s
L0C1B               ldd       $0A,s
                    addd      #$FFFF
                    std       $0A,s
                    subd      #$FFFF
                    bgt       L0C10
                    bra       L0C33
L0C29               ldb       ,u+
                    sex
                    pshs      b,a
                    jsr       [<$06,s]
                    leas      $02,s
L0C33               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bne       L0C29
                    ldd       >varnum4,y
                    beq       L0C5E
                    bra       L0C52
L0C47               ldd       >varnum5,y
                    pshs      b,a
                    jsr       [<$06,s]
                    leas      $02,s
L0C52               ldd       $0A,s
                    addd      #$FFFF
                    std       $0A,s
                    subd      #$FFFF
                    bgt       L0C47
L0C5E               puls      pc,u
L0C60               pshs      u
                    ldu       $06,s
                    ldd       $08,s
                    pshs      b,a
                    pshs      u
                    lbsr      egg4
                    leas      $02,s
                    nega
                    negb
                    sbca      #$00
                    addd      ,s++
                    std       $08,s
                    ldd       >varnum4,y
                    bne       L0CA2
                    bra       L0C8A
L0C7F               ldd       >varnum5,y
                    pshs      b,a
                    jsr       [<$06,s]
                    leas      $02,s
L0C8A               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bgt       L0C7F
                    bra       L0CA2
L0C98               ldb       ,u+
                    sex
                    pshs      b,a
                    jsr       [<$06,s]
                    leas      $02,s
L0CA2               ldb       ,u
                    bne       L0C98
                    ldd       >varnum4,y
                    beq       L0CC5
                    bra       L0CB9
L0CAE               ldd       >varnum5,y
                    pshs      b,a
                    jsr       [<$06,s]
                    leas      $02,s
L0CB9               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bgt       L0CAE
L0CC5               puls      pc,u

L0CC7               pshs      u
                    ldd       >varnum1,y
                    pshs      b,a
                    ldd       $06,s
                    pshs      b,a
                    lbsr      egg2
L0CD6               leas      $04,s
                    puls      pc,u
L0CDA               pshs      u
                    ldd       $04,s
                    ldx       >varnum1,y
                    leax      $01,x
                    stx       >varnum1,y
                    stb       -$01,x
                    puls      pc,u
L0CEC               blt       L0D21
                    leas      -$09,y
                    pshu      y,x,dp

*         neg   <u0034  branch to middle of instruct?
*
*L0CF2    fcb    $00
*L0CF3    fcb    $34
*
*         nega

                    fcb       $00                 what function in life do I have
egg2                pshs      u                   disassembled as neg <u0034 then neg
                    ldu       $06,s
                    ldd       u0006,u
                    anda      #$80
                    andb      #$22
                    cmpd      #$8002
                    beq       L0D17
                    ldd       u0006,u
                    clra
                    andb      #$22
                    cmpd      #$0002
                    lbne      L0E2F
                    pshs      u
                    lbsr      L1062
                    leas      $02,s
L0D17               ldd       u0006,u
                    clra
                    andb      #$04
                    beq       L0D53
                    ldd       #$0001
L0D21               pshs      b,a
                    leax      $07,s
                    pshs      x
                    ldd       u0008,u
                    pshs      b,a
                    ldd       u0006,u
                    clra
                    andb      #$40
                    beq       L0D38
                    leax      >L13EC,pcr          writeln: ??
                    bra       L0D3C
L0D38               leax      >L13D3,pcr          write:  ??
L0D3C               tfr       x,d
                    tfr       d,x
                    jsr       ,x
                    leas      $06,s
                    cmpd      #$FFFF
                    bne       L0D94
                    ldd       u0006,u
                    orb       #C$SPC
                    std       u0006,u
                    lbra      L0E2F
L0D53               ldd       u0006,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L0D63
                    pshs      u
                    lbsr      L0E4C
                    leas      $02,s
L0D63               ldd       ,u
                    addd      #$0001
                    std       ,u
                    subd      #$0001
                    tfr       d,x
                    ldd       $04,s
                    stb       ,x
                    ldd       ,u
                    cmpd      u0004,u
                    bcc       L0D89
                    ldd       u0006,u
                    clra
                    andb      #$40
                    beq       L0D94
                    ldd       $04,s
                    cmpd      #$000D
                    bne       L0D94
L0D89               pshs      u
                    lbsr      L0E4C
                    std       ,s++
                    lbne      L0E2F
L0D94               ldd       $04,s
                    puls      pc,u
                    pshs      u
                    ldu       $04,s
                    ldd       $06,s
                    pshs      b,a
                    pshs      u
                    ldd       #$0008
                    lbsr      L1294
                    pshs      b,a
                    lbsr      egg2
                    leas      $04,s
                    ldd       $06,s
                    pshs      b,a
                    pshs      u
                    lbsr      egg2
                    lbra      L0F06
L0DBB               pshs      u,b,a
                    leau      >u0012,y
                    clra
                    clrb
                    std       ,s
                    bra       L0DD1
L0DC7               tfr       u,d
                    leau      u000D,u
                    pshs      b,a
                    bsr       L0DE4
                    leas      $02,s
L0DD1               ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      #$0010
                    blt       L0DC7
                    lbra      L0E48
L0DE4               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    cmpu      #$0000
                    beq       L0DF4
                    ldd       u0006,u
                    bne       L0DFA
L0DF4               ldd       #$FFFF
                    lbra      L0E48
L0DFA               ldd       u0006,u
                    clra
                    andb      #$02
                    beq       L0E09
                    pshs      u
                    bsr       L0E1E
                    leas      $02,s
                    bra       L0E0B
L0E09               clra
                    clrb
L0E0B               std       ,s
                    ldd       u0008,u
                    pshs      b,a
                    lbsr      close:
                    leas      $02,s
                    clra
                    clrb
                    std       u0006,u
                    ldd       ,s
                    bra       L0E48
L0E1E               pshs      u
                    ldu       $04,s
                    beq       L0E2F
                    ldd       u0006,u
                    clra
                    andb      #$22
                    cmpd      #$0002
                    beq       L0E34
L0E2F               ldd       #$FFFF
                    puls      pc,u

L0E34               ldd       u0006,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       L0E44
                    pshs      u
                    lbsr      L1062
                    leas      $02,s
L0E44               pshs      u
                    bsr       L0E4C
L0E48               leas      $02,s
                    puls      pc,u                return

L0E4C               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    ldd       u0006,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L0E7E
                    ldd       ,u
                    cmpd      u0004,u
                    beq       L0E7E
                    clra
                    clrb
                    pshs      b,a
                    pshs      u
                    lbsr      L0F0A
                    leas      $02,s
                    ldd       $02,x
                    pshs      b,a
                    ldd       ,x
                    pshs      b,a
                    ldd       u0008,u
                    pshs      b,a
                    lbsr      lseek:
                    leas      $08,s
L0E7E               ldd       ,u
                    subd      u0002,u
                    std       $02,s
                    lbeq      L0EF6
                    ldd       u0006,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    lbeq      L0EF6
                    ldd       u0006,u
                    clra
                    andb      #$40
                    beq       L0ECD
                    ldd       u0002,u
                    bra       L0EC5
L0E9E               ldd       $02,s
                    pshs      b,a
                    ldd       ,u
                    pshs      b,a
                    ldd       u0008,u
                    pshs      b,a
                    lbsr      writeln
                    leas      $06,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L0EBB
                    leax      $04,s
                    bra       L0EE5
L0EBB               ldd       $02,s
                    subd      ,s
                    std       $02,s
                    ldd       ,u
                    addd      ,s
L0EC5               std       ,u
                    ldd       $02,s
                    bne       L0E9E
                    bra       L0EF6
L0ECD               ldd       $02,s
                    pshs      b,a
                    ldd       u0002,u
                    pshs      b,a
                    ldd       u0008,u
                    pshs      b,a
                    lbsr      write:              was L13D3
                    leas      $06,s
                    cmpd      $02,s
                    beq       L0EF6
                    bra       L0EE7
L0EE5               leas      -$04,x
L0EE7               ldd       u0006,u
                    orb       #C$SPC
                    std       u0006,u
                    ldd       u0004,u
                    std       ,u
                    ldd       #$FFFF
                    bra       L0F06
L0EF6               ldd       u0006,u
                    ora       #$01
                    std       u0006,u
                    ldd       u0002,u
                    std       ,u
                    addd      u000B,u
                    std       u0004,u
                    clra
                    clrb
L0F06               leas      $04,s
                    puls      pc,u
L0F0A               pshs      u
                    puls      pc,u
L0F0E               pshs      u
                    ldu       $04,s
                    beq       L0F5A
                    ldd       u0006,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L0F5A
                    ldd       ,u
                    cmpd      u0004,u
                    bcc       L0F36
                    ldd       ,u
                    addd      #$0001
                    std       ,u
                    subd      #$0001
                    tfr       d,x
                    ldb       ,x
                    clra
                    lbra      L1060
L0F36               pshs      u
                    lbsr      L0FA9
                    lbra      L105E
                    pshs      u
                    ldu       $06,s
                    beq       L0F5A
                    ldd       u0006,u
                    clra
                    andb      #$01
                    beq       L0F5A
                    ldd       $04,s
                    cmpd      #$FFFF
                    beq       L0F5A
                    ldd       ,u
                    cmpd      u0002,u
                    bhi       L0F5F
L0F5A               ldd       #$FFFF
                    puls      pc,u
L0F5F               ldd       ,u
                    addd      #$FFFF
                    std       ,u
                    tfr       d,x
                    ldd       $04,s
                    stb       ,x
                    ldd       $04,s
                    puls      pc,u
                    pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    pshs      u
                    lbsr      L0F0E
                    leas      $02,s
                    std       $02,s
                    cmpd      #$FFFF
                    beq       L0F94
                    pshs      u
                    lbsr      L0F0E
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L0F99
L0F94               ldd       #$FFFF
                    bra       L0FA5
L0F99               ldd       $02,s
                    pshs      b,a
                    ldd       #$0008
                    lbsr      L12AB
                    addd      ,s
L0FA5               leas      $04,s
                    puls      pc,u
L0FA9               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    ldd       u0006,u
                    anda      #$80
                    andb      #$31
                    cmpd      #$8001
                    beq       L0FCF
                    ldd       u0006,u
                    clra
                    andb      #$31
                    cmpd      #$0001
                    lbne      L1048
                    pshs      u
                    lbsr      L1062
                    leas      $02,s
L0FCF               leax      >u0012,y
                    pshs      x
                    cmpu      ,s++
                    bne       L0FEC
                    ldd       u0006,u
                    clra
                    andb      #$40
                    beq       L0FEC
                    leax      >$001F,y
                    pshs      x
                    lbsr      L0E1E
                    leas      $02,s
L0FEC               ldd       u0006,u
                    clra
                    andb      #$08
                    beq       L1018
                    ldd       u000B,u
                    pshs      b,a
                    ldd       u0002,u
                    pshs      b,a
                    ldd       u0008,u
                    pshs      b,a
                    ldd       u0006,u
                    clra
                    andb      #$40
                    beq       L100C
                    leax      >L13C3,pcr          readln:
                    bra       L1010
L100C               leax      >L13A2,pcr          compiler dosent like "read:" label
L1010               tfr       x,d
                    tfr       d,x
                    jsr       ,x
                    bra       L102A
L1018               ldd       #$0001
                    pshs      b,a
                    leax      u000A,u
                    stx       u0002,u
                    pshs      x
                    ldd       u0008,u
                    pshs      b,a
                    lbsr      read:

L102A               leas      $06,s
                    std       ,s
                    ldd       ,s
                    bgt       L104D
                    ldd       u0006,u
                    pshs      b,a
                    ldd       $02,s
                    beq       L103F
                    ldd       #$0020
                    bra       L1042
L103F               ldd       #$0010
L1042               ora       ,s+
                    orb       ,s+
                    std       u0006,u
L1048               ldd       #$FFFF
                    bra       L105E
L104D               ldd       u0002,u
                    addd      #$0001
                    std       ,u
                    ldd       u0002,u
                    addd      ,s
                    std       u0004,u
                    ldb       [<u0002,u]
                    clra
L105E               leas      $02,s
L1060               puls      pc,u
L1062               pshs      u
                    ldu       $04,s
                    ldd       u0006,u
                    clra
                    andb      #$C0
                    bne       L109A
                    leas      <-$20,s
                    leax      ,s
                    pshs      x
                    ldd       u0008,u
                    pshs      b,a
                    clra
                    clrb
                    pshs      b,a
                    lbsr      getstat:
                    leas      $06,s
                    ldd       u0006,u
                    pshs      b,a
                    ldb       $02,s
                    bne       L108E
                    ldd       #$0040
                    bra       L1091
L108E               ldd       #$0080
L1091               ora       ,s+
                    orb       ,s+
                    std       u0006,u
                    leas      <$20,s
L109A               ldd       u0006,u
                    ora       #$80
                    std       u0006,u
                    clra
                    andb      #$0C
                    beq       L10A7
                    puls      pc,u

L10A7               ldd       u000B,u
                    bne       L10BC
                    ldd       u0006,u
                    clra
                    andb      #$40
                    beq       L10B7
                    ldd       #$0080
                    bra       L10BA
L10B7               ldd       #$0100
L10BA               std       u000B,u
L10BC               ldd       u0002,u
                    bne       L10D1
                    ldd       u000B,u
                    pshs      b,a
                    lbsr      ibrk                L14BA
                    leas      $02,s
                    std       u0002,u
                    cmpd      #$FFFF
                    beq       L10D9
L10D1               ldd       u0006,u
                    orb       #$08
                    std       u0006,u
                    bra       L10E8
L10D9               ldd       u0006,u
                    orb       #$04
                    std       u0006,u
                    leax      u000A,u
                    stx       u0002,u
                    ldd       #$0001
                    std       u000B,u
L10E8               ldd       u0002,u
                    addd      u000B,u
                    std       u0004,u
                    std       ,u
                    puls      pc,u

L10F2               pshs      u
                    ldb       $05,s
                    sex
                    tfr       d,x
                    bra       L1118
L10FB               ldd       [<$06,s]
                    addd      #$0004
                    std       [<$06,s]
                    leax      >L112F,pcr
                    bra       L1114
L110A               ldb       $05,s
                    stb       >$0010,y
                    leax      >$000F,y
L1114               tfr       x,d
                    puls      pc,u
L1118               cmpx      #$0064              'd
                    beq       L10FB
                    cmpx      #$006F              'o
                    lbeq      L10FB
                    cmpx      #$0078              'x
                    lbeq      L10FB
                    bra       L110A
                    puls      pc,u

*L112F    neg   <u0034 branch in here ?
*L112F    fcb $00
*L1130    fcb $34
*         nega

L112F               fcb       $00                 used above
egg3                pshs      u                   disassembled as neg <u0034 then neg

                    leax      >L113A,pcr
                    tfr       x,d
                    puls      pc,u
*
* L113A    neg   <u0034 same story here except somebody jumps
*                        to the front byte too
*

L113A               fcb       $00                 what do i do?
egg4                pshs      u                   disassembled as neg <u0034 then neg
                    ldu       $04,s
L113F               ldb       ,u+
                    bne       L113F
                    tfr       u,d
                    subd      $04,s
                    addd      #$FFFF
                    puls      pc,u

L114C               pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
L1156               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L1156
                    bra       L118B

                    pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
L116E               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    bne       L116E
                    ldd       ,s
                    addd      #$FFFF
                    std       ,s

L117F               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L117F

L118B               ldd       $06,s
                    leas      $02,s
                    puls      pc,u                return

                    pshs      u
                    ldu       $04,s
                    bra       L11A7
L1197               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    bne       L11A5
                    clra
                    clrb
                    puls      pc,u                return

L11A5               leau      dpsiz,u
L11A7               ldb       ,u
                    sex
                    pshs      b,a
                    ldb       [<$08,s]
                    sex
                    cmpd      ,s++
                    beq       L1197
                    ldb       [<$06,s]
                    sex
                    pshs      b,a
                    ldb       ,u
                    sex
                    subd      ,s++
                    puls      pc,u                return

L11C2               pshs      u
                    ldu       $04,s
                    leas      -$05,s
                    clra
                    clrb
                    std       $01,s
L11CC               ldb       ,u+
                    stb       ,s
                    cmpb      #C$SPC
                    beq       L11CC
                    ldb       ,s
                    cmpb      #$09
                    lbeq      L11CC
                    ldb       ,s
                    cmpb      #$2D                '-
                    bne       L11E7
                    ldd       #$0001
                    bra       L11E9
L11E7               clra
                    clrb
L11E9               std       $03,s
                    ldb       ,s
                    cmpb      #$2D                '-
                    beq       L120F
                    ldb       ,s
                    cmpb      #$2B                '+
                    bne       L1213
                    bra       L120F
L11F9               ldd       $01,s
                    pshs      b,a
                    ldd       #$000A
                    lbsr      L1235
                    pshs      b,a
                    ldb       $02,s
                    sex
                    addd      ,s++
                    addd      #$FFD0
                    std       $01,s
L120F               ldb       ,u+
                    stb       ,s
L1213               ldb       ,s
                    sex
                    leax      >$00E3,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    bne       L11F9
                    ldd       $03,s
                    beq       L122F
                    ldd       $01,s
                    nega
                    negb
                    sbca      #$00
                    bra       L1231
L122F               ldd       $01,s
L1231               leas      $05,s
                    puls      pc,u                return

L1235               tsta
                    bne       L124A
                    tst       $02,s
                    bne       L124A
                    lda       $03,s
                    mul
                    ldx       ,s
                    stx       $02,s
                    ldx       #$0000
                    std       ,s
                    puls      pc,b,a              return

L124A               pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    pshs      b,a
                    lda       $05,s
                    ldb       $09,s
                    mul
                    std       $02,s
                    lda       $05,s
                    ldb       $08,s
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L1267
                    inc       ,s
L1267               lda       $04,s
                    ldb       $09,s
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L1274
                    inc       ,s
L1274               lda       $04,s
                    ldb       $08,s
                    mul
                    addd      ,s
                    std       ,s
                    ldx       $06,s
                    stx       $08,s
                    ldx       ,s
                    ldd       $02,s
                    leas      $08,s
                    rts


                    tstb
                    beq       L129E

L128B               asr       $02,s
                    ror       $03,s
                    decb
                    bne       L128B
                    bra       L129E

L1294               tstb
                    beq       L129E

L1297               lsr       $02,s
                    ror       $03,s
                    decb
                    bne       L1297


L129E               ldd       $02,s
                    pshs      b,a
                    ldd       $02,s
                    std       $04,s
                    ldd       ,s
                    leas      $04,s
                    rts



L12AB               tstb
                    beq       L129E
L12AE               lsl       $03,s
                    rol       $02,s
                    decb
                    bne       L12AE
                    bra       L129E


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

getstat             lda       $05,s               get the path number
                    ldb       $03,s               get the code
                    beq       getst30             code is 0 ? Buffer (SS.Opt)
                    cmpb      #SS.Ready
                    beq       getst40             data available scf dev
                    cmpb      #SS.EOF
                    beq       getst40             EOF & error check
                    cmpb      #SS.Size
                    beq       getst10
                    cmpb      #SS.Pos             file position
                    beq       getst10


*  can't do other codes
                    ldb       #E$UnkSvc           load error unknow service code
                    lbra      _os9err:            head for error routine


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

getst10             pshs      u                   stack u since getstt modifies it
                    os9       I$GetStt
                    bcc       getst20             successful ?? go store info
                    puls      u                   otherwise pop our u
                    lbra      _os9err:            head for error procesing

getst20             stx       [<$08,s]            store MSW
                    ldx       $08,s               get address of destination
                    stu       $02,x               store LSW
                    puls      u                   restore register variable
                    clra                          clear d
                    clrb
                    rts                           return to caller

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

getst30             ldx       $06,s               load address to receive status packet


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

getst40             os9       I$GetStt            make the cal
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
                    lda       $05,s               get the path number
                    ldb       $03,s               get the code
                    beq       setst10             code is 0
                    cmpb      #SS.Size            code is 2
                    beq       setst20
*                         No other codes permitted
                    ldb       #E$UnkSvc           unknow service code
                    lbra      _os9err:

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

setst10             ldx       $06,s               x gets the address of the status packet
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

setst20             pshs      u                   stack the u since setstat modifies it
                    ldx       $08,s               get MSW
                    ldu       $0A,s               get LSW
                    os9       I$SetStt            make the call
                    puls      u                   bring back the orig u
                    lbra      _sysret             return
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
                    ldx       $02,s               get address of path list
                    lda       $05,s               get access mode (permissions)
                    os9       I$Open              attempt to open
                    bcs       access10            didn't open ? no need to
                    os9       I$Close             Close it
access10            lbra      _sysret             return


* open a path
open                ldx       $02,s               get address of the path list
                    lda       $05,s               get access mode permisions
                    os9       I$Open              attempt the opoen
                    lbcs      _os9err:            didn't open go to error handler
                    tfr       a,b                 path is open put a in b
                    clra                          clear a
                    rts                           return

* close a path
close               lda       $03,s               get path number
                    os9       I$Close             go close it
                    lbra      _sysret             return

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

mknod               ldx       $02,s               get address of the path list
                    ldb       $05,s               get access mode permission
                    os9       I$MakDir            make the call
                    lbra      _sysret             return



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

creat               ldx       $02,s               get address of the path list
                    lda       $05,s               get access modes
                    tfr       a,b                 proto attr
                    andb      #EPEXEC.            save exec bits public and owner
                    orb       #pmode              now add the default modes
                    os9       I$Create            go make the file
                    bcs       creat10             failed creation ?
ccret               tfr       a,b                 move path to b
                    clra                          clear a
                    rts                           return

creat10             cmpb      #E$CEF              already there ?
                    lbne      _os9err:            no a different error bail out

*  is it a directory although we want a file instead?
                    lda       $05,s               get the mode
                    bita      #$80                trying to create a directrory?
                    lbne      _os9err:            yes - bail out

*  if already there attempt to open with proper access rights
                    anda      #$07                access mode bits
                    ldx       $02,s               get the name again
                    os9       I$Open              try and open it
                    lbcs      _os9err:            still fails - bail out


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
                    pshs      u,a                 we got it open Yippee
                    ldx       #$0000              set file size
                    leau      ,x                  to zero
                    ldb       #SS.Size            set function code
*                       path number of open file is in a from I$Iopen
                    os9       I$SetStt            make the call
                    puls      u,a                 pop u and a back
                    bcc       ccret               contine as we have created the file

                    pshs      b                   set stat fail ? save error code
                    os9       I$Close             call close on file
                    puls      b                   pop the setstat error code
                    lbra      _os9err:            head for error handler


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

unlink              ldx       $02,s               get address of the path list
                    os9       I$Delete            make the call
                    lbra      _sysret             return

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

dup                 lda       $03,s               get path number
                    os9       I$Dup               make the call
                    lbcs      _os9err:            didn't dup go to error handler
                    tfr       a,b                 move the new path num into b
                    clra                          clear a
                    rts                           return

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
L13A2               pshs      y                   stack current y
                    ldx       $06,s               get address to store at
                    lda       $05,s               get path number
                    ldy       $08,s               get number of bytes to read
                    pshs      y                   stack the number of to read also
                    os9       I$Read              make the call


read1               bcc       rdexit              no problem if carry clear
                    cmpb      #E$EOF              is it end of file ??
                    bne       read10              nope then head for error handler
                    clra                          was the end of the file
                    clrb                          then clear a & b
                    puls      pc,y,x              pop the stacked values (cheap rts)

read10              puls      y,x
                    lbra      _os9err:
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
L13C3               pshs      y                   save data pointer
                    lda       $05,s               get the path number
                    ldx       $06,s               get the buffer address
                    ldy       $08,s               get the number to read
                    pshs      y                   save request for later
                    os9       I$ReadLn            read it
                    bra       read1               always go back test for eof

write
L13D3               pshs      y                   save data pointer
                    ldy       $08,s               get count
                    beq       write10
                    lda       $05,s               get file number
                    ldx       $06,s               get buffer address
                    os9       I$Write             write it

write1              bcc       write10             good write head out
                    puls      y                   error in writing ? get data pointer
                    lbra      _os9err:            head for error handler

write10             tfr       y,d                 good write
                    puls      pc,y                return

writeln
L13EC               pshs      y                   save data pointer
                    ldy       $08,s               get the count
                    beq       write10             count zero ??  go to return
                    lda       $05,s               something to write get path number
                    ldx       $06,s               get buffer address
                    os9       I$WritLn            write it
                    bra       write1              goto return

*  lseek(fd, offset, type)
lseek               pshs      u                   save the register variable
                    ldd       10,s                get type
*        ldd   $0A,s    get type
                    bne       lseek10
                    ldu       #$0000
                    ldx       #$0000
                    bra       doseek

lseek10             cmpd      #$0001              from here?
                    beq       here
                    cmpd      #$0002              from the end?
                    beq       frmend
*                      otherwise it was passed a bad type
*        ldb   #$F7
                    ldb       #E$SEEK

lserr               clra                          seek error routine
                    std       >errno,y            was $01b1
                    ldd       #-1                 $FFFF
                    leax      >_flacc,y           $01a5
                    std       ,x
                    std       $02,x
                    puls      pc,u                return

* from the end
frmend              lda       $05,s               get the path number
                    ldb       #SS.size            $02 file size code
                    os9       I$GetStt            get the file size
                    bcs       lserr               if error go to error code

                    bra       doseek              if not seek to position

here                lda       $05,s               get path number
                    ldb       #SS.pos             $05 file position
                    os9       I$GetStt            get the postion
                    bcs       lserr               if error go to error code

doseek              tfr       u,d                 work on the LSW first
                    addd      $08,s
                    std       _flacc+2,y
                    tfr       d,u
                    tfr       x,d
                    adcb      $07,s
                    adca      $06,s
                    bmi       lserr               seek is before the beginning of the file
                    tfr       d,x
                    std       _flacc,y

                    lda       $05,s               get the path number
                    os9       I$Seek
                    bcs       lserr               if error go to error code

                    leax      _flacc,y
                    puls      pc,u                return

sbrk                ldd       memend,y            get hi bound
*         ldd   >$01a3,y  disassembly
*         pshs  b,a       disassembly
                    pshs      d                   save it
                    ldd       $04,s               get required size
                    cmpd      spare,y             any spare left
*         bcs   L1497     disassembly
                    blo       sbrk20

*  have to get some from the system
                    addd      memend,y            add current size
                    pshs      y                   save data pointer
                    subd      ,s                  adjust for base
                    os9       F$Mem               re-size memory
                    tfr       y,d                 save the high bound
                    puls      y                   restore the data paointer
                    bcc       sbrk10              branch if NO error
                    ldd       #-1                 return error code
                    leas      $02,s               junk scratch
                    rts

sbrk10              std       memend,y            save new memory address
                    addd      spare,y             add in spare bytes ($01CD)
                    subd      ,s                  less old base
                    std       spare,y             is new spare value ($01CD)

*  now spare is big enough
sbrk20              leas      $02,s               junk scratch    L1497
                    ldd       spare,y             get spare count
                    pshs      d
*        pshs  b,a
                    subd      $04,s               less size
                    std       spare,y             update value
                    ldd       memend,y            get hi bound
                    subd      ,s++                base of free memeory
                    pshs      d                   save it
*        pshs  b,a

                    clra
                    ldx       ,s
sbrk30              sta       ,x+                 clear new memory
                    cmpx      memend,y
                    bcs       sbrk30
*        puls  pc,b,a
                    puls      pc,d                return

*   get memory within data allocation
ibrk                ldd       $02,s               get the size
                    addd      _mtop,y             add in the current top
                    bcs       ibrk20              if it wraps round - error
                    cmpd      _stbot,y            overlap stack
                    bcc       ibrk20              yes error
*        pshs  b,a
                    pshs      d                   no save top
                    ldx       _mtop,y             reset to the bottom

                    clra
sbloop              cmpx      ,s                  reached the end
                    bcc       ibrk10              yes - done
                    sta       ,x+                 nope clear and bump
                    bra       sbloop

ibrk10              ldd       _mtop,y             return value
                    puls      x                   restore new top
                    stx       _mtop,y             save for next time
                    rts


ibrk20              ldd       #-1                 return memory full
                    rts

*****************************
*   stat.a code
*

_os9err             clra
                    std       >errno,y            indicate in system error indicator
                    ldd       #-1                 error condition

*        std   >$01B1,y
*        ldd   #$FFFF
                    rts


_sysret             bcs       _os9err
                    clra                          clear "d"
                    clrb                          to return 0
                    rts


* normal exit - buffers flushed if there are any
exit                lbsr      L1500

                    lbsr      L0DBB               What do I do ???



* abnormal exit - no buffer flushing
* the argument to either exit entry is taken to be the
* F$EXIT status

_exit               ldd       $02,s               get the exit status
                    os9       F$Exit              toodle-loo

L1500               rts

********************************************************************
* end of executable text

etext               equ       *
L1501               fcb       $00,$01,$00,$01,$62,$74,$4F ....btO
L1508               fcb       $43,$00,$27,$10,$03,$E8,$00,$64 C.'..h.d
L1510               fcb       $00,$0A,$00,$0D,$6C,$78,$00,$00 ....lx..
L1518               fcb       $00,$00,$00,$00,$00,$00,$01,$00 ........
L1520               fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
L1528               fcb       $00,$00,$00,$02,$00,$01,$00,$00 ........
L1530               fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
L1538               fcb       $42,$00,$02,$00,$00,$00,$00,$00 B.......
L1540               fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
L1548               fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
L1550               fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
L1558               fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
L1560               fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
L1568               fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
L1570               fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
L1578               fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
L1580               fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
L1588               fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
L1590               fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
L1598               fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
L15A0               fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
L15A8               fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
L15B0               fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
L15B8               fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
L15C0               fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
L15C8               fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
L15D0               fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
L15D8               fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
L15E0               fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
L15E8               fcb       $01,$01,$01,$01,$01,$01,$01,$01 ........
L15F0               fcb       $01,$11,$11,$01,$11,$11,$01,$01 ........
L15F8               fcb       $01,$01,$01,$01,$01,$01,$01,$01 ........
L1600               fcb       $01,$01,$01,$01,$01,$01,$01,$01 ........
L1608               fcb       $30,$20,$20,$20,$20,$20,$20,$20 0
L1610               fcb       $20,$20,$20,$20,$20,$20,$20,$20
L1618               fcb       $48,$48,$48,$48,$48,$48,$48,$48 HHHHHHHH
L1620               fcb       $48,$48,$20,$20,$20,$20,$20,$20 HH
L1628               fcb       $20,$42,$42,$42,$42,$42,$42,$02 BBBBBB.
L1630               fcb       $02,$02,$02,$02,$02,$02,$02,$02 ........
L1638               fcb       $02,$02,$02,$02,$02,$02,$02,$02 ........
L1640               fcb       $02,$02,$02,$20,$20,$20,$20,$20 ...
L1648               fcb       $20,$44,$44,$44,$44,$44,$44,$04 DDDDDD.
L1650               fcb       $04,$04,$04,$04,$04,$04,$04,$04 ........
L1658               fcb       $04,$04,$04,$04,$04,$04,$04,$04 ........
L1660               fcb       $04,$04,$04,$20,$20,$20,$20,$01 ...    .
L1668               fcb       $00,$00,$00,$01,$00,$0D,$74,$6F ......to
L1670               fcb       $63,$67,$65,$6E,$00 cgen.

                    emod
eom                 equ       *
                    end
