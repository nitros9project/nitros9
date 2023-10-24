******************************************************************
* dirsort - Directory sorting utility
*
* This is an asm version of a Basic09 directory sort
* that was published in a Coco newsletter.
* Original and ml routine by Robert Gault, Nov. 2005
*
* The program uses a version of Shellsort published
* in a May 1983, BYTE article by Terry Barron and
* George Diehr (both at University of Washington)
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* -------------------------------------------------------------
*   1      2005/12/19  Robert Gault
* Very fast and fairly simple
*
*   2      2005/12/20  Robert Gault
* Minor change of use /dd/defs/defsfile to use defsfile. The first
* was for my OS-9 system. The current one is for the NitrOS-9
* project.

                    nam       dirsort
                    ttl       Directory sorting utility

                    ifp1
                    use       defsfile
                    endc

* If you want built-in help change the next line.
HELP                set       FALSE

TyLg                set       Prgrm+Objct         program object code
* Re-entrant means multiple users possible
AtRev               set       ReEnt+Rev           re-entrant, revision 1
Rev                 set       1

* Create module header, needed by all OS-9 modules
                    mod       Eom,Name,TyLg,AtRev,Start,Size
* Data area
DPptr               rmb       2                   pointer to our direct page
dirsize             rmb       2                   size of the directory less 64 bytes
count               rmb       2                   number of directory entries
entryI              rmb       2                   pointer to nameI
entryJ              rmb       2                   pointer to nameJ
entryID             rmb       2                   pointer to name(I+D)
Tx                  rmb       32                  buffer for transfer
i                   rmb       2                   index
j                   rmb       2                   index
NminusD             rmb       2                   holds last value of FOR I/NEXT loop
path                rmb       1                   value for path to the directory
D                   rmb       2                   shellsort constant
                    rmb       40
stack               equ       .
Size                equ       .                   This initial data space will be increased as OS-9
* assigns space in pages of 256 bytes. Initially the stack will
* not be here.
buffer              equ       .                   This will be the start of the data array in memory
* to be requested from OS-9 as needed.

Name                equ       *
                    fcs       /dirsort/
                    fcb       1                   edition number
* Ego stroking :) identifier
                    fcc       /Written by Robert Gault, 2005/

* Default directory name, dot, or current directory
default             fcb       C$PERD,C$CR

* Solutions for N,2^INT(LN(N)) -1
* We don't need general logs just specifc values so
* they were pre-calculated
Dtable              fdb       2,0
                    fdb       7,1
                    fdb       20,3
                    fdb       54,7
                    fdb       148,15
* If your directory has more entries than several hundred, you
* need to learn how to organize your disk/drive.
                    fdb       403,31
                    fdb       1096,63
* This next will exceed normal memory limits but is needed
* for values up to about 2000. We could just put $FFFF/32=
* 2047 but there are size checks in the code.
                    fdb       2980,127
DTEnd               equ       *

Start               equ       *
                    stu       <DPptr              save the direct page pointer
                    leas      stack,u             put the stack where we want it or it will be
* inside the directory buffer and crash the program.
                    cmpd      #0                  are there any parameters?
                    beq       noprm
l1                  lda       ,x+                 skip over spaces, if any
                    cmpa      #C$SPAC
                    beq       l1
                    cmpa      #C$CR               if only spaces, same as noprm
                    bne       a1
noprm               leax      default,pcr         point to default directory, dot
                    bra       a9
                    ifne      HELP
a1                  cmpa      #'?                 if "?" then show syntax
                    lbeq      syntax
                    cmpa      #'-                 if attempt at options, syntax
                    lbeq      syntax
                    leax      -1,x
                    else
a1                  leax      -1,x                backstep to first character of directory
                    endc
a9                  lda       #%11000011          directory, single user access, update
                    os9       I$Open              attempt to open a path to the directory
                    lbcs      error
                    sta       <path               save the path #
                    ldb       #SS.Size            get the size of the directory
                    os9       I$GetStt            size reported in regs X&U
                    cmpx      #0                  MSB of size
                    lbne      Tlarge              too big to sort
                    tfr       u,d                 evaluate the size
                    cmpd      #128                two entries other than .. and .
                    lblo      getreal             can't sort 1 item or less
                    subd      #64                 reduce size by 64 bytes for .. and .
                    std       <dirsize            save size in bytes
                    addd      #Size               we need current data + directory buffer
                    os9       F$Mem               request space for the buffer
                    lbcs      Tlarge              can't get enough memory
                    lda       <path               recover path to the directory
                    ldx       #0                  MSB position
                    ldu       #64                 LSB, past the entries .. and .
                    os9       I$Seek              skip over the entries
                    ldu       <DPptr              recover DP pointer
                    ldy       <dirsize            data size in bytes
                    leax      buffer,u            point to our buffer
                    os9       I$Read              transfer the directory information to buffer
* Calculate the number of directory entries
* Divide size by 32 bytes per entry. INT(size/32)must=size/32 or
* the directory is corrupted. So, ignore remainder.
                    ldx       #0                  initialize counter
                    ldd       <dirsize            this does not include . and ..
                    ifne      H6309
                    lsrd
                    lsrd
                    lsrd
                    lsrd
                    lsrd
                    else
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    endc
                    std       <count
                    leax      Dtable,pcr          precalculated constants
                    leay      DTEnd,pcr
                    pshs      y
l3                  cmpd      ,x
                    bls       a4                  if fewer or equal # of entries get D
                    leax      4,x                 move to next table entry
                    cmpx      ,s                  have we exhausted the table?
                    bne       l3
                    leas      2,s                 restore the stack
                    lbra      Tlarge              should not be possible to get here in code
a4                  leas      2,s                 restore the stack
                    ldd       2,x                 get shellsort D from table
                    std       <D                  save working value
* Sort starts here
* Directory entries can't have duplicate names or the directory
* is corrupted. That means a<b is as good as a<=b when testing.
s2                  ldd       #1                  initialize FOR/NEXT loop
                    std       <i
                    ldd       <count              same as n in Basic09 program
                    subd      <D
                    std       <NminusD            save value
* calculated pointer for entryID
s6                  ldd       <i                  FOR i=1 TO n-D STEP 1
                    addd      <D                  get pointer for entry(i+D)
                    lbsr      point               get the pointer value
                    stx       <entryID
                    tfr       x,y
* calculate pointer for entryI
                    ldd       <i
                    lbsr      point
                    stx       <entryI
* Compare the entry pointed to by regX against that for regY
                    lbsr      compare             is name(i) < name(i+D)
                    bcs       s20
                    ldx       <entryID
                    leay      Tx,u                shellsort swap name holder
                    lbsr      movexy              name(Tx)=name(i+D)
                    ldx       <entryI
                    ldy       <entryID
                    bsr       movexy              name(i+D)=name(i)
                    ldd       <i
                    cmpd      <D
                    bhi       s4                  this was a Basic09 IF/THEN
                    ldy       <entryI             inside the IF/THEN
                    leax      Tx,u
                    bsr       movexy              name(i)=name(Tx)
                    bra       s20                 ends the IF/THEN
s4                  ldd       <i                  initialize FOR/NEXT loop
                    subd      <D
                    std       <j
s5                  bsr       point               FOR j=i-D TO 1 STEP -D
                    stx       <entryJ
                    tfr       x,y
                    leax      Tx,u
                    lbsr      compare             is entry(Tx) > entry(j)
                    bcc       s10
                    ldd       <j
                    addd      <D                  name(j+D)
                    bsr       point
                    tfr       x,y
                    ldx       <entryJ
                    bsr       movexy              name(j+D)=name(j)
                    ldd       <j                  NEXT j
                    subd      <D                  STEP -D
                    std       <j
                    cmpd      #1                  stop if less than 1
                    bge       s5
s10                 leay      Tx,u
                    ldd       <j
                    addd      <D
                    bsr       point
                    exg       x,y
                    bsr       movexy              name(j+D)=name(Tx)
s20                 ldd       <i                  NEXT i
                    addd      #1                  STEP +1
                    std       <i
                    cmpd      <NminusD
                    bls       s6                  stop if i>(n-D)
                    ldd       <D                  D=D/2
                    ifne      H6309
                    lsrd
                    else
                    lsra
                    rorb
                    endc
                    std       <D
                    cmpd      #1
                    lbhs      s2                  WHILE D>0
                    lda       <path               rewind to just after .. & .
                    ldx       #0
                    ldu       #64
                    os9       I$Seek
                    lda       <path
                    ldu       <DPptr
                    leax      buffer,u            write out sorted directory
                    ldy       <dirsize
                    os9       I$Write
                    clrb
                    os9       F$Exit              release memory, close paths, and return to OS-9

                    ifne      H6309
movexy              ldw       #32
                    tfm       x+,y+
                    rts
                    else
movexy              ldb       #16                 move the entry pointed to in regX to
                    pshs      b
sw1                 ldd       ,x++                that pointed to by regY
                    std       ,y++
                    dec       ,s                  if not finished, continue
                    bne       sw1
                    puls      b,pc
                    endc

* Converts an index in regD to a memory offset in regX
* This could easily overflow but there are size checks
* in the above code so there is no overflow test.
point               leax      buffer,u
                    subd      #1
                    ifne      H6309
                    lsld
                    lsld
                    lsld
                    lsld
                    lsld
                    else
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    endc
                    leax      d,x
                    rts

compare             ldb       #29                 size of name field
                    pshs      b                   save counter
cloop               ldb       ,y+                 get character
                    lda       ,x+                 get character
                    beq       c1                  if deleted go
                    tstb
                    beq       c2                  if deleted go
                    tsta
                    bmi       c5                  if last character go
                    tstb
                    bmi       c6                  if last character go
                    pshs      b
                    cmpa      ,s+
                    beq       c4                  if equal, test next character
                    bra       cx
c1                  clra
                    bra       cx                  return +
c2                  coma
                    bra       cx                  return -
c3                  anda      #$7f
                    andb      #$7f
                    pshs      b
                    cmpa      ,s+
                    rts
c5                  bsr       c3
                    beq       c2
                    bra       cx
c6                  bsr       c3
                    beq       c1
                    bra       cx                  return result
c4                  dec       ,s
                    bne       cloop
                    clra                          should not be able to get here in code
cx                  puls      b,pc                return result

error               leax      nodir,pcr
                    ldy       #endnd-nodir
write               lda       #1                  screen
                    os9       I$Write
                    clrb
                    os9       F$Exit
nodir               equ       *
                    fcc       /Directory does not exist!/
                    fcb       C$CR,C$LF
endnd               equ       *

Tlarge              leax      big,pcr
                    ldy       #endbig-big
                    bra       write
big                 equ       *
                    fcc       /Either the directory is too large or there is insufficient /
                    fcc       /memory./
                    fcb       C$CR,C$LF
endbig              equ       *

getreal             leax      huh,pcr
                    ldy       #endhuh-huh
                    clr       ,-s
                    bra       write
huh                 equ       *
                    fcc       /Get real! You can't sort less than 2 items./
                    fcb       C$CR,C$LF
endhuh              equ       *

                    ifne      HELP
syntax              leax      usage,pcr
                    ldy       #enduse-usage
                    clr       ,-s
                    lbra      write
usage               fcc       /USAGE: dirsort will sort any directory. If no directory/
                    fcb       C$CR,C$LF
                    fcc       /       name is given, the current directory will be sorted./
                    fcb       C$CR,C$LF
                    fcc       /EX:    dirsort    dirsort .    dirsort ../
                    fcb       C$CR,C$LF
                    fcc       "       dirsort /dd/cmds"
                    fcb       C$CR,C$LF
enduse              equ       *
                    endc

                    emod
Eom                 equ       *
                    end
