************************************************************
* Send - Sends a signal to a process
*
* By: Boisy G. Pitre
*     Southern Station, Box 8455
*     Hattiesburg, MS  39406-8455
*     Internet:  bgpitre@seabass.st.usm.edu
*
* Usage:  Send [-signal] procID [...] [-signal] [procID] [...]
*
*         Where signal# is a decimal number from 0-255 and procID is the
*         process' ID number (obtainable by the PROCS command).  The
*         default signal is 0 if none is specified.  Different signals
*         can be sent to different processes on the same command line:
*
*                Send -3 45 55 -1 12 4 -0 5 6
*
*         ...sends signal 3 to processes 45 and 55, signal 1 to processes
*         12 and 4, and signal 0 to processes 5 and 6.
*
*         If a process cannot be killed for whatever reason, an error will
*         be printed, and parsing of the line will continue.
*
*         Standard Signals:
*                                0 - Kill (non-interceptable)
*                                1 - Wake up a sleeping process
*                                2 - Keyboard terminate
*                                3 - Keyboard interrupt
*                                4 - Window change
*                          128-255 - User defined
*
* For a detailed explanation on signals, see the OS-9 Level II Operating
* System Manual's "Technical Reference" section, page 2-15.
*

                    nam       Send
                    ttl       Signaler utility


                    ifp1
                    use       defsfile
                    endc

                    mod       Size,Name,Prgrm+Objct,ReEnt+1,Start,Finish

Name                fcs       /Send/
                    fcb       $02

XPlace              rmb       1
Signal              rmb       1                   Holds current signal
stack               rmb       200
params              rmb       200
Finish              equ       .

Start               decb                          Check for no params
                    beq       Help                If not, show help
                    clr       Signal              else clear signal (assume signal 0)

Parse               lda       ,x+                 get char
                    cmpa      #'-                 dash?
                    beq       GetSig              yeah, get signal no
                    cmpa      #C$SPAC             space?
                    beq       Parse               yeah, get next char
                    cmpa      #C$CR               eol?
                    beq       Done                yeah, exit

KillIt              leax      -1,x                backup on char.. must be a pid
                    bsr       Str2Byte            convert to byte
                    tfr       b,a                 put B (pid) in A
                    ldb       Signal              load B with current signal
                    os9       F$Send              and send it to the process
                    bcc       Parse
                    os9       F$PErr              else print the error
                    bra       Parse               and continue parsing

Done                clrb                          clear, no error
Error               os9       F$Exit              exit

GetSig              bsr       Str2Byte            convert to byte
                    stb       Signal              save the new signal
                    bra       Parse               and resume parsing

*******************************************
* Str2Byte - Converts an ASCII string to a single byte
*
* Entry: X - Address of first char in string
*
* Done:  B - Converted byte
*        X - Last number in string + 1
*

Str2Byte            clrb
cnvloop             lda       ,x+
                    cmpa      #'9
                    bhi       cnvdone
                    suba      #'0
                    blo       cnvdone
                    pshs      a
                    lda       #10
                    mul
                    addb      ,s+
                    bra       cnvloop
cnvdone             leax      -1,x
                    rts

Help                leax      HelpMsg,pcr
                    lda       #2
                    ldy       #200
                    os9       I$WritLn
                    bcs       Error
                    bra       Done

HelpMsg             fcc       /Usage:  Send [-signal] procID [...]/
                    fcb       C$CR

                    emod
Size                equ       *
                    end

