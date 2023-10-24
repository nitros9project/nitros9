********************************************************************
* Binex - Motorola S-Record utility
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  67      ????/??/??
* From Tandy OS-9 Level Two VR 02.00.01.
*
*  68      2003/01/14  Boisy G. Pitre
* Restarted edition; removed Motorola copyright.

;;; binex
;;;
;;; Syntax:	binex <filename1> <filename2>
;;; Function: Converts a binary file into an S-Record file.
;;; Parameters:
;;;     filename1   The name of the file to convert.
;;;     filename2   The name of the file in which to store the converted code.
;;;
;;; Notes
;;;
;;; binex converts the specified OS-9 binary file filename1 to an S-Record file and gives the new file the name
;;; filename2. If filename1 is a non-binary load module file, a warning message asks you if binex should
;;; proceed anyway. Press Y to continue with the conversion, or any other key to terminate.
;;;
;;; The program asks you for a program name and a starting load address. It stores this
;;; information in a header record. Although OS-9 is position-independent and does not require absolute addressing,
;;; S-Record files do.
;;;
;;; Examples
;;;
;;; To convert scanner into an S-Record file scanner.s1, type:
;;;
;;;     binex /d0/cmds/scanner scanner.s1 [ENTER]
;;;
;;; The command responds with:
;;;
;;;     Enter starting address for file:
;;;     $100 [ENTER]
;;;     Enter name for header record:
;;;     scanner [ENTER]
;;;
;;;
;;; To download scanner.s1 to a device using the serial port /T1, type:
;;;
;;;     list scanner.s1 >/t1 [ENTER]
;;;
;;; An S-Record is a type of text file that contains records representing binary data in hexadecimal character
;;; form. Most commercial PROM programmers, emulators, logic analyzers, and similar RS-232 devices can directly
;;; accept this Motorola standard format. You can also use S-Record files to transmit data over data links that can
;;; only handle character-type data or to convert OS-9 assembler or compiler-generated programs to load on non-OS-9
;;; systems. For example, to convert the binary file zap to an S-Record file zap.sr, type:
;;;
;;;     binex /d0/cmds/zap /d1/sr/zap.sr

                    nam       Binex
                    ttl       Motorola S-Record utility

* Disassembled 98/09/15 00:08:52 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

inpath              rmb       1
outpath             rmb       1
parmptr             rmb       2
u0004               rmb       1
u0005               rmb       1
gotname             rmb       1
u0007               rmb       2
u0009               rmb       1
u000A               rmb       2
headername          rmb       1
u000D               rmb       31
u002C               rmb       1
u002D               rmb       1
u002E               rmb       1
u002F               rmb       2
u0031               rmb       2
u0033               rmb       2
u0035               rmb       656
size                equ       .

name                fcs       /Binex/
                    fcb       edition

*         fcc   "Copyright 1982 Motorola, Inc."
*         fcb   $01

start               stx       <parmptr            save off parameter
                    lda       #READ.              open file for reading
                    os9       I$Open              open it
                    bcc       openok              branch if success
Exit                os9       F$Exit              else exit
openok              sta       <inpath             save off path to input file
                    stx       <parmptr            save off updated parameter pointer
                    lda       #WRITE.             open next file for writing
                    ldb       #SHARE.+PEXEC.+PWRIT.+PREAD.+EXEC.+UPDAT.
                    os9       I$Create            create the file
                    bcs       Exit                branch if error
                    sta       <outpath            save off path to output file
                    stx       <parmptr            save off updated parameter pointer
                    ldd       #$0000              clear off...
                    sta       <gotname
                    std       <u000A
                    std       <u002F
                    ldx       #$5330
                    stx       <u002D
                    ldx       #$3030
                    stx       <u0031
                    stx       <u0033
L0062               leax      >AskStart,pcr       point to starting address prompt
                    lda       #$01                standard output
                    ldy       #AskStrtL           get length of prompt
                    os9       I$Write             write it to standard output
                    leax      <u0031,u
                    lda       #$00                standard input
                    ldy       #$0005              # of bytes to read
                    os9       I$ReadLn            read up to carriage return
                    leay      -$01,y              decrement read count
                    cmpy      #$0000              carriage return only? (no input)
                    beq       L0062               if so, go ask again
                    cmpy      #$0004              is length of answer 4 bytes?
                    bhi       L0062               if greater, go ask again
                    beq       L00A7               else go ask for next item
                    tfr       y,d                 transfer length of answer to D
                    pshs      b                   save off B
                    decb                          decrement it
                    leax      <u0031,u            point X to answer buffer
                    leay      $04,x               point 4 bytes past that
L0095               lda       b,x                 get byte at offset B of answer
                    sta       ,-y                 store at destination
                    decb                          decrement
                    bpl       L0095               if >=0, continue
                    ldb       #$04
                    subb      ,s+
                    lda       #'0
leading0            sta       ,-y
                    decb
                    bgt       leading0
L00A7               lbsr      L0178
                    leax      >AskName,pcr        point to prompt to ask for name
                    lda       #$01                write to standard output
                    ldy       #AskNameL           get prompt length
                    os9       I$Write             write it out
                    leax      headername,u        point to answer buffer
                    lda       #$00                read from standard input
                    ldy       #$0015              for this many bytes
                    os9       I$ReadLn            read the response
                    leay      -$01,y              subtract 1 from answer length
                    cmpy      #$0000              empty answer?
                    bne       L0120               branch if not
L00CA               lda       <inpath             get file input path
                    leax      headername,u        point X to user input for header name
                    ldy       #$0020              read 32 bytes
                    os9       I$Read              read it
                    lbcs      L0160               branch if error
                    cmpy      #$0000              any data?
                    lbeq      L0160               branch if nothing
                    lda       <gotname            do we have the header name?
                    bne       L0120               branch if so
                    inc       <gotname            else flag that we do
                    lda       #$31
                    sta       <u002E
                    ldx       <u0004
                    stx       <u000A
                    ldx       headername,u        get two bytes at headername pointer
                    cmpx      #$87CD              are these module header sync bytes?
                    beq       L0120               branch if so
                    leax      >Alert,pcr          else point to alert message
                    pshs      y                   save off Y
                    ldy       #AlertL             get alert message length
                    lda       #$01                to standard output
                    os9       I$Write             write the alert message
                    leax      <u0035,u            point to answer buffer
                    ldy       #$0002              read up to 2 bytes
                    lda       #$00                from standard input
                    os9       I$ReadLn            read byte and carriage return
                    puls      y                   restore Y
                    lda       <u0035,u            get answer byte
                    anda      #$DF                make uppercase
                    cmpa      #'Y                 is it "YES"?
                    beq       L0120               if so, continue
CleanExit
                    clrb                          else clear carry and B
                    os9       F$Exit              and exit
L0120               sty       <u0007
                    tfr       y,d
                    addb      #$03
                    stb       <u0009
                    leax      u0009,u
                    clra
                    ldb       ,x
L012E               adda      ,x+
                    decb
                    bne       L012E
                    coma
                    sta       ,x
                    leax      u0009,u
                    leay      <u002F,u
                    ldb       ,x
                    incb
L013E               bsr       L01B6
                    decb
                    bne       L013E
                    ldb       #$0D
                    stb       ,y
                    leax      <u002D,u
                    ldy       #$0073
                    lda       <outpath
                    os9       I$WritLn
                    lbcs      Exit
                    ldd       <u000A
                    addd      <u0007
                    std       <u000A
                    lbra      L00CA
L0160               cmpb      #$D3
                    lbne      Exit
                    lda       #$39
                    cmpa      <u002E
                    beq       CleanExit
                    sta       <u002E
                    ldx       <u0004
                    stx       <u000A
                    ldy       #$0000
                    bra       L0120
L0178               bsr       L017C
                    sta       <u0004
L017C               lda       ,x+
                    bsr       L0197
                    lsla
                    lsla
                    lsla
                    lsla
                    anda      #$F0
                    pshs      a
                    lda       ,x+
                    bsr       L0197
                    adda      ,s+
                    sta       <u0005
                    adda      <u002C
                    sta       <u002C
                    lda       <u0005
                    rts
L0197               suba      #'0
                    bmi       NonHexFound
                    cmpa      #$09
                    ble       L01A5
                    suba      #$07
                    cmpa      #$0F
                    bhi       NonHexFound
L01A5               rts
NonHexFound
                    leax      >NonHex,pcr         point to "non-hex" message
                    lda       #$02                to standard error
                    ldy       #$00FF              maximum length to write
                    os9       I$WritLn            inform the user
                    lbra      CleanExit           and cleanly exit
L01B6               pshs      b,a
                    lda       ,x+
                    tfr       a,b
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       L01CC
                    sta       ,y+
                    tfr       b,a
                    bsr       L01CC
                    sta       ,y+
                    puls      pc,b,a
L01CC               anda      #$0F
                    adda      #$30
                    cmpa      #$39
                    bls       L01D6
                    adda      #$07
L01D6               rts
NonHex              fcc       "** NON-HEX CHARACTER ENCOUNTERED"
                    fcb       C$BELL,C$CR
AskName             fcc       "Enter name for header record: "
AskNameL            equ       *-AskName
AskStart            fcc       "Enter starting address for file: $"
AskStrtL            equ       *-AskStart
Alert               fcb       C$BELL,C$CR,C$LF
                    fcc       "** Not a binary load module file.  Proceed anyway (Y/N)? "
AlertL              equ       *-Alert

                    emod
eom                 equ       *
                    end
