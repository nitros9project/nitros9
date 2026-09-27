********************************************************************
* KeyTest - show the bytes each keystroke delivers
*
* Reads standard input and prints every byte in hex, with its ASCII form
* where it has one: a printable character in quotes, a control code as
* ^X, and nothing for bytes of $80 and above.  Bytes that arrive together
* - several from one key, or a paste - print on one line, so a key that
* sends a sequence shows as a sequence.  Five ESCs in a row quit.
*
* It reads whatever standard input is, so it works on the serial console
* and on a video window alike (e.g. "keytest </w2", then F3 to give window
* 2 the keyboard).  On an SCF device it switches the path to raw input for
* the run - no echo, and the interrupt, quit, pause and XON/XOFF characters
* arrive as data instead of acting - and restores the original options on
* the way out, including when a signal ends it, since the path is usually
* shared with the shell that started it.  Raw also clears the end-of-file
* character, which SCF defaults to ESC.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2026       Created to test the video pico's USB keyboard

                    nam       KeyTest
                    ttl       keystroke byte viewer

                  IFP1
                    use       defsfile
                  ENDC

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

EscQuit             equ       5         consecutive ESCs that end the run
GroupMax            equ       8         bytes per output line

                    mod       eom,name,tylg,atrv,start,size

                    org       0
escs                rmb       1         consecutive ESCs seen so far
havopt              rmb       1         nonzero once raw options are set
ngrp                rmb       1         bytes on the current output line
byte                rmb       1         the byte just read
lptr                rmb       2         next free position in the line
oldopt              rmb       32        the path options as found
newopt              rmb       32        the raw options set for the run
line                rmb       100       one output line
                    rmb       250       working stack
size                equ       .

name                fcs       /KeyTest/
                    fcb       edition

Banner              fcc       "keytest: press keys to see their bytes; five ESCs in a row quit"
                    fcb       C$CR
BannerLn            equ       *-Banner
ByeMsg              fcc       "keytest: five ESCs - done"
                    fcb       C$CR
ByeMsgLn            equ       *-ByeMsg

start               leax      Icpt,pcr  ; catch signals so the options get restored
                    os9       F$Icpt
                    leax      Banner,pcr ; say what to do
                    ldy       #BannerLn
                    lda       #$01
                    os9       I$WritLn
                    clr       <havopt   ; nothing to restore yet
                    clr       <escs     ; no ESCs seen yet
* switch standard input to raw, if it is a terminal
                    clra                ; standard input
                    ldb       #SS.Opt   ; read its options
                    leax      oldopt,u
                    os9       I$GetStt
                    bcs       Group     ; no options: read it as it is
                    lda       <oldopt+(PD.DTP-PD.OPT) ; is it an SCF device?
                    cmpa      #DT.SCF
                    bne       Group     ; no: leave a file's options alone
                    leax      oldopt,u  ; copy the options to edit them
                    leay      newopt,u
                    ldb       #32
Copy                lda       ,x+
                    sta       ,y+
                    decb
                    bne       Copy
                    clr       <newopt+(PD.EKO-PD.OPT) ; no echo
                    clr       <newopt+(PD.PAU-PD.OPT) ; no end-of-page pause
                    clr       <newopt+(PD.PSC-PD.OPT) ; pause character is data
                    clr       <newopt+(PD.INT-PD.OPT) ; interrupt character is data
                    clr       <newopt+(PD.QUT-PD.OPT) ; quit character is data
                    clr       <newopt+(PD.EOF-PD.OPT) ; esc is not end-of-file
                    clr       <newopt+(PD.XON-PD.OPT) ; xon is data
                    clr       <newopt+(PD.XOFF-PD.OPT) ; xoff is data
                    clra                ; set them on standard input
                    ldb       #SS.Opt
                    leax      newopt,u
                    os9       I$SetStt
                    bcs       Group     ; refused: carry on without raw mode
                    inc       <havopt   ; remember to restore them

* one output line: wait for a byte, then take any others already waiting
Group               leax      line,u    ; start a fresh line
                    stx       <lptr
                    clr       <ngrp
                    lbsr      GetB      ; wait for the next byte
                    bcs       Quit      ; error or signal: stop
                    lbsr      AddB      ; format it onto the line
More                lda       <escs     ; enough ESCs in a row?
                    cmpa      #EscQuit
                    bhs       Done      ; yes: print this line and stop
                    lda       <ngrp     ; line full?
                    cmpa      #GroupMax
                    bhs       Flush     ; yes: print it, carry on with a new one
                    clra                ; any more bytes already waiting?
                    ldb       #SS.Ready
                    os9       I$GetStt
                    bcs       Flush     ; no: this keystroke's bytes are all in
                    lbsr      GetB      ; yes: take the next one
                    bcs       Quit
                    lbsr      AddB
                    bra       More
Flush               lbsr      PutLine   ; print the line
                    bra       Group     ; and wait for the next keystroke

Done                lbsr      PutLine   ; print the ESCs that ended it
                    lbsr      Restore
                    leax      ByeMsg,pcr ; sign off
                    ldy       #ByeMsgLn
                    lda       #$01
                    os9       I$WritLn
                    clrb                ; normal exit
                    os9       F$Exit

Quit                pshs      b         ; keep the error for the exit status
                    lbsr      Restore
                    puls      b
                    os9       F$Exit

* Icpt - signal intercept.  Returning lets the interrupted read fail, which
* takes the program out through Quit with the options restored.
Icpt                rti

* Restore - put the original input options back if they were changed
Restore             tst       <havopt   ; were they changed?
                    beq       RestX     ; no
                    clra                ; standard input
                    ldb       #SS.Opt
                    leax      oldopt,u
                    os9       I$SetStt
                    clr       <havopt
RestX               rts

* GetB - read one byte from standard input into byte and A
GetB                clra                ; standard input
                    leax      byte,u
                    ldy       #$0001
                    os9       I$Read
                    bcs       GetBX
                    lda       <byte
GetBX               rts

* AddB - append byte A to the line as "$XX" plus its ASCII form, and track
* the run of consecutive ESCs
AddB                pshs      a         ; keep the byte
                    cmpa      #$1B      ; an ESC?
                    bne       AddB1
                    inc       <escs     ; yes: one more in the run
                    bra       AddB2
AddB1               clr       <escs     ; no: the run is broken
AddB2               ldx       <lptr     ; where to put it
                    lda       #'$
                    sta       ,x+
                    lda       ,s        ; the byte in hex
                    lbsr      Hex2
                    lda       #C$SPAC
                    sta       ,x+
                    lda       ,s        ; now its ASCII form
                    cmpa      #C$SPAC
                    blo       AddCtl    ; control code: ^X
                    cmpa      #$7F
                    beq       AddDel    ; del: ^?
                    bhi       AddHi     ; $80 and up: no ASCII form
                    ldb       #$27      ; printable: in quotes
                    stb       ,x+
                    sta       ,x+
                    stb       ,x+
                    bra       AddSep
AddCtl              ldb       #'^       ; control code as ^ and its letter
                    stb       ,x+
                    adda      #$40
                    sta       ,x+
                    lda       #C$SPAC
                    sta       ,x+
                    bra       AddSep
AddDel              ldd       #$5E3F    ; "^?"
                    std       ,x++
                    lda       #C$SPAC
                    sta       ,x+
                    bra       AddSep
AddHi               ldd       #$2020    ; three blanks keep the columns
                    std       ,x++
                    sta       ,x+
AddSep              ldd       #$2020    ; two blanks between bytes
                    std       ,x++
                    stx       <lptr
                    inc       <ngrp
                    puls      a,pc

* Hex2 - store A as two hex digits at X, advancing X
Hex2                pshs      a
                    lsra                ; high nibble first
                    lsra
                    lsra
                    lsra
                    bsr       Nib
                    sta       ,x+
                    puls      a         ; then the low nibble
                    anda      #$0F
                    bsr       Nib
                    sta       ,x+
                    rts
* Nib - low nibble of A to an ASCII hex digit in A
Nib                 cmpa      #$0A
                    blo       Nib0
                    adda      #$07      ; a-F
Nib0                adda      #'0
                    rts

* PutLine - end the line with CR and write it to standard output
PutLine             ldx       <lptr
                    leax      -$02,x    ; drop the last byte's separator
                    lda       #C$CR
                    sta       ,x+
                    tfr       x,d       ; length = end - start
                    leax      line,u
                    pshs      x
                    subd      ,s++
                    tfr       d,y
                    lda       #$01      ; standard output
                    os9       I$WritLn
                    rts

                    emod
eom                 equ       *
                    end
