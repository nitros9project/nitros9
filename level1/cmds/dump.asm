********************************************************************
* Dump - Show file contents in hex
*
* $Id$
*
* Dump follows the function of the original Microware version but now
* supports large files over 64K, and is free from the problems of garbage
* in wide listings.
*
* In addition it now allows dumping of memory modules and command modules
* in the execution directory.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   5      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.
*
*   6      2002/12/23  Boisy G. Pitre
* Incorporated R. Telkman's additions from 1987, added -d option,
* added defs to conditionally assemble without help or screen size check.
*
*          2003/01/17  Boisy G. Pitre
* Removed -d option.
*
*          2003/01/21  Boisy G. Pitre
* Narrow screen now shows properly, only dumps 16 bits worth of address
* data to make room.
*
*          2003/03/03  Boisy G. Pitre
* Fixed bug where header would be shown even if there was no data in a file.
*
*   7      2003/06/06  Rodney V. Hamilton
* Restored Rubout processing for terminals.

;;; dump
;;;
;;; Syntax:	`dump [filename]`
;;; Usage: Displays the physical contents of the specified file or device in both ASCII and hexadecimal form.
;;; Parameters:
;;;     filename    An optional file pathlist or a device name.
;;;
;;; Use `dump` to examine the contents of non-text files. If you don't specify a file or device, `dump` displays the
;;; standard input path (the keyboard). It writes output to the standard output path (the video display).
;;; The command adjusts to the type of screen you are using. On 32 and 40 column screens, `dump` displays 8
;;; bytes per line. On 80 column screens, it displays 16 bytes per line.
;;; Data appears in both hexadecimal and ASCII character format. If data bytes have non-displayable values,
;;; `dump` displays them as periods (.).
;;;
;;; The addresses are relative to the beginning of the file. Because memory modules are
;;; position-independent and are stored in files exactly as they exist in memory, the addresses shown
;;; correspond to the relative load addresses of memory module files.
;;;
;;; # Examples
;;;
;;; To display keyboard input in hexadecimal, type the following command. Press [CTRL][BREAK] to return to the
;;;  shell.
;;;
;;;     `dump` [ENTER]
;;;
;;; To display the raw contents of the diskette in Drive /D1, type:
;;;
;;;     `dump /d1@` [ENTER]
;;;
;;; The @ symbol causes OS-9 to treat the entire disk as a file.
;;;
;;; Here's sample output on a 32 column screen:
;;;
;;; ```dump SYS/password >/p [ENTER]
;;;
;;;      0 1 2 3 4 5 6 7  0 2 4 6
;;; ADDR 8 9 A B C D E F  8 A C E
;;; ==== +-+-+-+-+-+-+-+- + + + +
;;; 0000 2C2C302C3132382C ,,0,128,
;;; 0008 2F44302F434D4453 /D0/CMDS
;;; 0010 2C2D2C5348454C4C ,.,SHELL
;;; 0018 0D55534552312C2C .USER1,,
;;; 0020 312C3132382C3E2C 1,128,.,
;;; 0028 2E2C5348454C4C0D .,SHELL.
;;; 0030 55534552322C2C32 USER2,,2
;;; 0038 2C3132382C232C23 ,128,.,.
;;;
;;;      0 1 2 3 4 5 6 7  0 2 4 6
;;; ADDR 8 9 A B C D E F  8 A C E
;;; ==== +-+-+-+-+-+-+-+- + + + +
;;; 0040 2C5348454C4C0D55 ,SHELL.U
;;; 0048 534552332C2C332C SER3,,3,
;;; 0050 3132382C232C2E2C 128,.,.,
;;; 0058 5348454C4C0D5553 SHELL.US
;;; 0060 4552342C2C342C31 ER4,,4,1
;;; 0068 32382C2E2C2E2C53 28,.,.,S
;;; 0070 48454C4C0D       HELL.
;;; ```
;;;
;;; The first column indicates the starting address. The next eight columns (00-EF) display data bytes in hexadecimal
;;; format. The columns (0-E) display data bytes in ASCII format. Non-ASCII appear as periods in the ASCII character
;;; display section.
;;;
;;; Here's sample output on an 80 column screen:
;;;
;;; ```
;;; dump SYS/password >/p [ENTER]
;;;
;;; ADDR  0 1  2 3  4 5  6 7  8 9  A B  C D  E F 0 2 4 6 9 A C E
;;; ---- ---- ---- ---- ---- ---- ---- ---- ---- ----------------
;;; 0000 2C2C 302C 3132 382C 2F44 302F 434D 4453 ,,0,128,/D0/CMDS
;;; 0010 2C2D 2C53 4845 4C4C 0D55 5345 5231 2C2C ,.,SHELL.USER1,,
;;; 0020 312C 3132 382C 3E2C 2E2C 5348 454C 4C0D 1,128,.,.,SHELL.
;;; 0030 5553 4552 322C 2C32 2C31 3238 2C23 2C23 USER2,,2,128,.,.
;;; 0040 2C53 4845 4C4C 0D55 5345 5233 2C2C 332C ,SHELL.USER3,,3,
;;; 0050 3132 382C 232C 2E2C 5348 454C 4C0D 5553 128,.,.,SHELL.US
;;; 0060 4552 342C 2C34 2C31 3238 2C2E 2C2E 2C53 ER4,,4,128,.,.,S
;;; 0070 4845 4C4C 0D                            HELL.
;;; ```

                    nam       Dump
                    ttl       Show file contents in hex

                    ifp1
                    use       defsfile
                    endc

* Tweakable options
DOSCSIZ             set       1                   1 = include SS.ScSiz code, 0 = leave out
DOHELP              set       0                   1 = include help message, 0 = leave out
BUFSZ               set       80

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       1
edition             set       7

                    org       0
nonopts             rmb       1
D.Prm               rmb       2
D.Hdr               rmb       1
D.Mem               rmb       1
                    ifne      DOSCSIZ
narrow              rmb       1
                    endc
Mode                rmb       1
D.Opn               rmb       1
D.Beg               rmb       2
D.End               rmb       2
D.Adr               rmb       4
D.Len               rmb       2
D.Ptr               rmb       2
D.Txt               rmb       2
Datbuf              rmb       16
Txtbuf              rmb       BUFSZ
                    rmb       128
datsz               equ       .

                    mod       length,name,tylg,atrv,start,datsz

name                fcs       /Dump/
                    fcb       edition

title               fcc       /Address   0 1  2 3  4 5  6 7  8 9  A B  C D  E F  0 2 4 6 8 A C E/
titlelen            equ       *-title
caret               fcb       C$CR
flund               fcc       /-------- ---- ---- ---- ---- ---- ---- ---- ----  ----------------/
                    fcb       C$CR
                    ifne      DOSCSIZ
short               fcc       /     0 1 2 3 4 5 6 7  0 2 4 6/
                    fcb       C$LF
                    fcc       /Addr 8 9 A B C D E F  8 A C E/
                    fcb       C$CR
shund               fcc       /==== +-+-+-+-+-+-+-+- +-+-+-+-/
                    fcb       C$CR
                    endc

start               stx       <D.Prm
                    clra
                    sta       <D.Hdr
                    sta       <D.Mem
                    sta       <nonopts            assume no non-opts
                    inca
                    sta       <Mode               READ.

                    ifne      DOSCSIZ
                    clr       <narrow             assume wide

* Check screen size
                    ldb       #SS.ScSiz
                    os9       I$GetStt
                    bcs       Pass1

                    cmpx      #titlelen+1
                    bge       PrePass

                    sta       <narrow

PrePass             ldx       <D.Prm
                    endc

* Pass1 - process any options
* Entry: X = ptr to cmd line
Pass1
* Skip over spaces
                    lda       ,x+
                    cmpa      #C$SPAC
                    beq       Pass1

* Check for EOL
                    cmpa      #C$CR
                    beq       Pass2

* Check for option
                    cmpa      #'-
                    bne       Pass1

* Here, X points to an option char
OptPass             lda       ,x+
                    cmpa      #C$SPAC
                    beq       Pass1
                    cmpa      #C$CR
                    beq       Pass2

                    anda      #$DF

IsItH               cmpa      #'H
                    bne       IsItM

* Process H here
                    sta       <D.Hdr
                    bra       OptPass

IsItM               cmpa      #'M
                    bne       IsItX

* Process M here
                    sta       <D.Mem
                    bra       OptPass

IsItX               cmpa      #'X
                    bne       ShowHelp

* Process X here
                    lda       <Mode
                    ora       #EXEC.
                    sta       <Mode
                    bra       OptPass

                    ifne      DOHELP
ShowHelp            leax      HelpMsg,pcr
                    lda       #2
                    ldy       #HelpLen
                    os9       I$Write
                    bra       ExitOk
                    endc

* Pass2 - process any non-options
* Entry: X = ptr to cmd line
Pass2
                    ldx       <D.Prm
Pass21
* Skip over spaces
                    lda       ,x+
                    cmpa      #C$SPAC
                    beq       Pass21
                    cmpa      #'-
                    bne       Pass22

EatOpts             lda       ,x+
                    cmpa      #C$SPAC
                    beq       Pass21
                    cmpa      #C$CR
                    bne       EatOpts

* Check for EOL
Pass22              cmpa      #C$CR
                    beq       EndOfL

Call                leax      -1,x
                    sta       nonopts,u
                    bsr       DumpFile
                    bra       Pass21

EndOfL              tst       <nonopts            any non-options on cmd line?
                    bne       ExitOk
                    tst       <D.Mem              memory option specified?
                    bne       ShowHelp            yes, no module specified, show help
                    clra                          stdin
                    bsr       DumpIn
                    ifeq      DOHELP
ShowHelp
                    endc
ExitOk              clrb
DoExit              os9       F$Exit

mlink               clra
                    pshs      u
                    os9       F$Link
                    stu       <D.Beg
                    puls      u
                    bcc       DumpIn
                    bra       DoExit

DumpFile            tst       <D.Mem
                    bne       mlink
                    lda       <Mode
opath               tfr       x,y
                    os9       I$Open
                    bcc       DumpIn
                    tfr       y,x
                    ora       #DIR.               try directory mode
                    os9       I$Open              open it
                    bcs       DoExit              branch if error
DumpIn              stx       <D.Prm
                    sta       <D.Opn
                    ldx       <D.Beg
                    ldd       M$Size,x
                    leax      d,x
                    stx       <D.End
                    clra
                    clrb
                    tfr       d,x
onpas               std       <D.Adr+2
                    bcc       notbg
                    leax      1,x
notbg               stx       <D.Adr
                    tst       <D.Hdr
                    bne       nohed
                    ifne      DOSCSIZ
                    tst       <narrow
                    beq       flpag
                    aslb
                    endc
flpag               tstb
                    bne       nohed
                    lbsr      iseof
                    bcc       flpag2
                    ldx       <D.Prm
                    rts
flpag2              leax      caret,pcr
                    lbsr      print
                    ldb       #16
                    leax      title,pcr
                    leay      flund,pcr
                    ifne      DOSCSIZ
                    tst       <narrow
                    beq       doprt
                    ldb       #8
                    leax      short,pcr
                    leay      shund,pcr
                    endc
doprt               pshs      y
                    clra
                    std       <D.Len
                    bsr       print
                    puls      x
                    bsr       print
nohed               leax      Txtbuf,u
                    stx       <D.Ptr
                    ldb       <D.Len+1
                    lda       #3
                    mul
                    addd      #2
                    ifne      DOSCSIZ
                    tst       <narrow
                    beq       leayit
                    subd      #4
                    endc
leayit              leay      d,x
                    sty       <D.Txt
                    lda       #C$SPAC
                    ldb       #BUFSZ-1
clbuf               sta       b,x
                    decb
                    bpl       clbuf
                    ldb       #D.Adr
                    ifne      DOSCSIZ
                    tst       <narrow
                    beq       adlop
                    incb                          we  skip first two bytes ...
                    incb                          ...  if on a narrow screen
                    endc
adlop               lda       b,u
                    lbsr      onbyt
                    incb
                    cmpb      #D.Adr+4
                    bne       adlop
                    ldx       <D.Ptr
                    leax      1,x
                    stx       <D.Ptr
                    bsr       readi
                    bcs       eofck
onlin               lbsr      onchr
                    decb
                    ble       enlin
                    lbsr      onchr
                    decb
                    ble       enlin
                    ifne      DOSCSIZ
                    tst       <narrow
                    bne       onlin
                    endc
                    lda       #C$SPAC
                    lbsr      savec
                    bra       onlin
enlin               lda       #C$CR
                    ldx       <D.Txt
                    sta       ,x
                    leax      Txtbuf,u
                    bsr       print
                    ldd       <D.Adr+2
                    ldx       <D.Adr
                    addd      <D.Len
                    lbra      onpas
print               ldy       #BUFSZ
                    lda       #1
                    os9       I$WritLn
                    lbcs      DoExit
                    rts
readi               ldy       <D.Len
                    clrb
                    tst       <D.Mem
                    bne       redad
                    leax      Datbuf,u
                    lda       <D.Opn
                    os9       I$Read
                    bcs       reded
                    tfr       y,d
reded               rts

redad               bsr       iseofm
                    bcc       setct
                    rts
setct               subd      <D.Len
                    bcs       redof
                    clra
                    clrb
redof               addd      <D.Len
                    clr       -1,s
                    leay      d,x
                    sty       <D.Beg
                    rts

eofck               cmpb      #E$EOF
                    orcc      #Carry
                    lbne      DoExit
                    clrb
                    ldx       <D.Prm
                    rts

iseof               tst       <D.Mem
                    bne       iseofm
                    lda       <D.Opn
                    ldb       #SS.EOF
                    os9       I$GetStt
                    cmpb      #E$EOF
                    beq       iseofex
                    clrb
iseofok             rts
iseofex             orcc      #Carry
                    ldb       #E$EOF
                    rts
iseofm              ldd       <D.End
                    ldx       <D.Beg
                    subd      <D.Beg
                    beq       iseofex
                    andcc     #^Carry
                    rts

onibl               anda      #$0F
                    cmpa      #9
                    bls       nocom
                    adda      #7
nocom               adda      #'0
savec               pshs      x
                    ldx       <D.Ptr
                    sta       ,x+
                    stx       <D.Ptr
                    puls      x,pc
onchr               lda       ,x+
                    bsr       onbyt
                    pshs      x,a
                    anda      #$7F
                    cmpa      #C$SPAC             control char?
                    blo       cntrl
                    cmpa      #$7F                rubout?
                    blo       savet
cntrl               lda       #'.                 make printable
savet               ldx       <D.Txt
                    sta       ,x+
                    stx       <D.Txt
                    puls      a,x,pc
onbyt               pshs      a
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       onibl
                    lda       ,s
                    bsr       onibl
                    puls      a,pc

                    ifne      DOHELP
HelpMsg             fcc       "Use: Dump [opts] [<path>] [opts]"
                    fcb       C$CR,C$LF
                    fcc       "  -h = no header"
                    fcb       C$CR,C$LF
                    fcc       "  -m = module in memory"
                    fcb       C$CR,C$LF
                    fcc       "  -x = file in exec dir"
                    fcb       C$CR,C$LF
HelpLen             equ       *-HelpMsg
                    endc

                    emod
length              equ       *
                    end
