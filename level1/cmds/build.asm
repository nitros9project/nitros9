********************************************************************
* Build - Simple text file creation utility
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   6      ????/??/??
* From Tandy OS-9 Level Two VR 02.00.01.

;;; build
;;;
;;; Syntax: build <filename>
;;; Function: Builds a text file by copying input from the standard input device (the keyboard) into the file specified by filename.
;;; Parameters:
;;;      filename    The name of the file you're creating.
;;;
;;; Notes
;;;
;;; build creates the file, then displays a question mark (?) and waits for you to type a line. When you type a line and press [ENTER], build writes the line to the disk.
;;; When you finish entering the lines for the new file, press [ENTER] without any preceding text to close the file and terminate the operation.
;;; The following example demonstrates how to build a text file named newfile:
;;;
;;;      build newfile [ENTER]
;;;      ? THE POWERS OF THE OS-9 [ENTER]
;;;      ? OPERATING SYSTEM ARE TRULY [ENTER]
;;;      ? FANTASTIC. [ENTER]
;;;      ? [ENTER]
;;;
;;; To view the newly created file, type:
;;;
;;;      list newfile [ENTER]
;;;
;;; The screen displays:
;;;
;;;      THE POWERS OF THE OS-9
;;;      OPERATING SYSTEM ARE TRULY
;;;      FANTASTIC.
;;;
;;; Examples
;;;
;;; To create a new file called small_file and put into it whatever you type at the keyboard, type:
;;;
;;;      build small_file [ENTER]
;;;
;;; To direct whatever you type to the printer, type:
;;;
;;;      build /p [ENTER]
;;;
;;; You can use build to transfer, or redirect, data from one file to another. Instead of the keyboard, this example uses a file named mytext file for the input device. The output device is Terminal 1.
;;;
;;;      build ‹mytext /t1 [ENTER]

                    nam       Build
                    ttl       Simple text file creation utility

* Disassembled 98/09/10 23:19:12 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       6

                    mod       eom,name,tylg,atrv,start,size

fpath               rmb       1
linebuff            rmb       128
stack               rmb       450
size                equ       .

name                fcs       /Build/
                    fcb       edition

*start    ldd   #(WRITE.*256)+PREAD.+UPDAT.  Level One edition 5 line
start               ldd       #(WRITE.*256)+UPDAT.
                    os9       I$Create            create file
                    bcs       Exit                branch if error
                    sta       <fpath              else save path to file
InpLoop             lda       #1                  stdout
                    leax      <Prompt,pcr         point to prompt
                    ldy       #PromptL            and size of prompt
                    os9       I$WritLn            write line
                    clra                          stdin
                    leax      linebuff,u          point to line buffer
                    ldy       #128                and max read size
                    os9       I$ReadLn            read line
                    bcs       Close               branch if error
                    cmpy      #$0001              1 byte read?
                    beq       Close               if so, must be CR, exit
                    lda       <fpath              else get file path
                    os9       I$WritLn            write line to file
                    bcc       InpLoop             branch if ok
                    bra       Exit                else exit
Close               lda       <fpath              get file path
                    os9       I$Close             close it
                    bcs       Exit                branch if erro
                    clrb                          else clear carry
Exit                os9       F$Exit              and exit normally

Prompt              fcc       "? "
PromptL             equ       *-Prompt

                    emod
eom                 equ       *
                    end

