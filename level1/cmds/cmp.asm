********************************************************************
* Cmp - Binary file comparison utility
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2003/01/20  Boisy G. Pitre
* Rewritten in assembly for size.

;;; cmp
;;;
;;; Syntax: cmp <filename1> <filename2>
;;; Function: Compares two files.
;;; Parameters:
;;;      filename1    The first file to compare.
;;;      filename2    The second file to compare.
;;;
;;; Notes
;;;
;;; Opens two files and performs a comparison of the binary values of the corresponding
;;; data bytes of the files. If there are any differences, the file offset (address) and
;;; the values of the bytes from each file are displayed in hexadecimal.
;;; The comparison ends when end-of-file is encountered on either file, followed by
;;; a summary of the number of bytes compared and the number of differences found.

                    nam       Cmp
                    ttl       Binary file comparison utility

                    ifp1
                    use       defsfile
                    endc

* Here are some tweakable options
DOHELP              set       0                   1 = include help info
CMPBUFSZ            set       1024
STACKSZ             set       128                 estimated stack size in bytes
PARMSZ              set       256                 estimated parameter size in bytes

* Module header definitions
tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    org       0
headdone            rmb       1                   if 1, means byte  #1 #2 header shown
noneflag            rmb       1                   if 1, means there were differences
f1path              rmb       1                   file 1 path
f2path              rmb       1                   file 2 path
f1read              rmb       2
f2read              rmb       2
f1namptr            rmb       2
f2namptr            rmb       2
f1namsiz            rmb       2
f2namsiz            rmb       2
cmpbytes            rmb       4                   bytes compared
difbytes            rmb       4                   bytes different
cleartop            equ       .                   everything up to here gets cleared at start
diffbuff            rmb       32
f1buff              rmb       CMPBUFSZ
f2buff              rmb       CMPBUFSZ
* Finally the stack for any PSHS/PULS/BSR/LBSRs that we might do
                    rmb       STACKSZ+PARMSZ
size                equ       .

* The utility name and edition goes here
name                fcs       /Cmp/
                    fcb       edition

* Place constant strings here
                    ifne      DOHELP
HlpMsg              fcb       C$LF
                    fcc       /Use: Cmp <file1> <file2>/
                    fcb       C$CR
HlpMsgL             equ       *-HlpMsg
                    endc
CmpHead             fcb       C$LF
                    fcc       " Differences"
                    fcb       C$LF
CrRtn               fcb       C$CR
None                fcc       "   None ..."
                    fcb       C$CR
CmpHead2            fcc       "byte      #1 #2"
                    fcb       C$CR
CmpHead3            fcc       "========  == =="
                    fcb       C$CR
ByteCmp             fcb       C$LF
                    fcc       "Bytes compared:   "
ByteCmpL            equ       *-ByteCmp
ByteDif             fcc       "Bytes different:  "
ByteDifL            equ       *-ByteDif
IsLonger            fcc       " is longer"
                    fcb       C$CR

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

* This routine counts the number of non-whitespace characters
* starting at X
*
* Entry:
*   X = ptr to string (space, comma or CR terminated)
* Exit:
*   Y = length of string
*   X = ptr to byte after string
StrLen              pshs      a
                    ldy       #$0000
StrLenLp            lda       ,x+
                    cmpa      #C$SPAC
                    beq       StrLenEx
                    cmpa      #C$CR
                    beq       StrLenEx
                    leay      1,y
                    bra       StrLenLp
StrLenEx            puls      a,pc

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

                    lda       ,x                  get first char
                    cmpa      #C$CR               CR?
                    lbeq      ShowHelp            if so, no parameters... show help and exit
* Open first file on command line
                    bsr       SkipSpcs
                    stx       f1namptr,u
                    bsr       StrLen
                    sty       f1namsiz
                    ldx       f1namptr,u
                    lda       #READ.
                    os9       I$Open
                    lbcs      ShutDown
                    sta       <f1path
* Open second file on command line
                    bsr       SkipSpcs
                    stx       f2namptr,u
                    bsr       StrLen
                    sty       f2namsiz
                    ldx       f2namptr,u
                    lda       #READ.
                    os9       I$Open
                    lbcs      ShutDown
                    sta       <f2path

* Write "Differences" to standard output
                    lda       #$01
                    leax      CmpHead,pcr
                    ldy       #128
                    os9       I$WritLn

DoCmp               lda       f1path
                    leax      f1buff,u
                    ldy       #CMPBUFSZ
                    os9       I$Read
                    lbcs      ShutDown
                    sty       <f1read

                    lda       f2path
                    leax      f2buff,u
                    ldy       #CMPBUFSZ
                    os9       I$Read
                    lbcs      ShutDown
                    sty       <f2read

* Actual compare is done here
                    ldd       f1read,u            get read amount for file 1
                    cmpd      f2read,u            compare against read amount for file2
                    ble       Compare             branch if f1read less than or equal
                    ldd       f2read,u            else get f2read size
Compare             leax      f1buff,u            point X to f1 buff
                    leay      f2buff,u            point Y to f2 buff
CmpLoop             pshs      d
                    lda       ,x                  get f1 byte in A
                    cmpa      ,y                  compare against f2 byte at Y
                    beq       CmpOk               if same, go on
                    bsr       ShowDiff            else show diff
CmpOk               leax      1,x
                    leay      1,y
                    ldd       <cmpbytes+2         get lo 16 bits
                    addd      #$0001
                    std       <cmpbytes+2
                    bcc       CmpFwd
                    ldd       <cmpbytes
                    addd      #$0001
                    std       <cmpbytes
CmpFwd              ldd       ,s++
                    subd      #$0001
                    bne       CmpLoop
                    bra       DoCmp               else read more

ShowDiff            pshs      x,y
                    tst       <headdone           did we already show header?
                    bne       ShowDif1            branch if so
                    lda       #$01                stdout
                    sta       <noneflag           we won't be showing none when done!
                    sta       <headdone           set head done flag
                    leax      CmpHead2,pcr        print header 2
                    ldy       #128
                    os9       I$WritLn
                    leax      CmpHead3,pcr        and header 3
                    os9       I$WritLn
ShowDif1            leax      diffbuff,u
                    ldd       <cmpbytes
                    bsr       MkHexWrd
                    ldd       <cmpbytes+2
                    bsr       MkHexWrd
                    ldd       #C$SPAC*256+C$SPAC
                    std       ,x++
                    ldb       [,s]
                    bsr       MkHexByt
                    lda       #C$SPAC
                    sta       ,x+
                    ldb       [2,s]
                    bsr       MkHexByt
                    lda       #C$CR
                    sta       ,x
                    leax      diffbuff,u
                    lda       #$01
                    ldy       #128
                    os9       I$WritLn

* Increment diff count
                    ldd       <difbytes+2         get lo 16 bits
                    addd      #$0001
                    std       <difbytes+2
                    bcc       ShowDif2
                    ldd       <difbytes
                    addd      #$0001
                    std       <difbytes
ShowDif2
                    puls      x,y,pc

* Entry: X = buffer to place 4 byte Hex char in
*        D = word to convert to Hex
* Exit : X = ptr to location after 4 byte Hex
MkHexWrd            exg       a,b
                    bsr       MkHexByt
                    exg       a,b
                    bsr       MkHexByt
                    rts

* Entry: X = buffer to place 2 byte Hex char in
*        B = byte to convert to Hex
* Exit : X = ptr to location after 2 byte Hex
MkHexByt            pshs      d
                    tfr       b,a
                    lsrb                          shift upper nibble to lower
                    lsrb
                    lsrb
                    lsrb
                    bsr       MakeChar
                    tfr       a,b
                    andb      #$0F
                    bsr       MakeChar
                    puls      d,pc
MakeChar            cmpb      #$09
                    bhi       IsLetter
                    addb      #'0
                    fcb       $8C                 skip next two bytes
IsLetter            addb      #55
                    stb       ,x+
                    rts

ShutDown            lda       <f1path             get file 1 path number
                    beq       CloseF2             if empty, close file 2
                    os9       I$Close
CloseF2             lda       <f2path             get file 2 path number
                    lbeq      ExitOk
                    os9       I$Close
                    lda       #$01                stdout for later
                    tst       <noneflag           any differences?
                    bne       Summary1
                    leax      None,pcr
                    ldy       #128
                    os9       I$WritLn
Summary1            leax      ByteCmp,pcr
                    ldy       #ByteCmpL
                    os9       I$Write
                    leax      diffbuff,u
                    ldd       <cmpbytes
                    bsr       MkHexWrd
                    ldd       <cmpbytes+2
                    bsr       MkHexWrd
                    ldb       #C$CR
                    stb       ,x
                    leax      diffbuff,u
                    lda       #$01
                    ldy       #128
                    os9       I$WritLn
Summary2            leax      ByteDif,pcr
                    ldy       #ByteDifL
                    os9       I$Write
                    leax      diffbuff,u
                    ldd       <difbytes
                    bsr       MkHexWrd
                    ldd       <difbytes+2
                    lbsr      MkHexWrd
                    ldb       #C$CR
                    stb       ,x
                    leax      diffbuff,u
                    lda       #$01
                    ldy       #128
                    os9       I$WritLn

* See if one file is longer than other
                    ldd       <f1read
                    cmpd      <f2read
                    beq       ExitOk              if same, go on
* Write CR
                    lda       #1
                    leax      CrRtn,pcr
                    ldy       #1
                    os9       I$WritLn
                    ldx       <f1namptr
                    ldy       <f1namsiz
* Assume file 1 is longer
                    ldd       <f1read
                    cmpd      <f2read
                    bgt       ShowLong
* Otherwise file 2 is longer
                    ldx       <f2namptr
                    ldy       <f2namsiz
ShowLong            lda       #1
                    os9       I$Write
                    leax      IsLonger,pcr
                    ldy       #128
                    os9       I$WritLn

ExitOk              clrb
Exit                os9       F$Exit

ShowHelp            equ       *
                    ifne      DOHELP
                    leax      >HlpMsg,pcr         point to help message
                    ldy       #HlpMsgL            get length
                    lda       #$02                std error
                    os9       I$WritLn            write it
                    endc
                    bra       ExitOk

                    emod
eom                 equ       *
                    end
