************************************************************
* TEE - Tees input to multiple outputs
*
* By: Boisy G. Pitre
*     Southern Station, Box 8455
*     Hattiesburg, MS  39406-8455
*     Internet:  bgpitre@seabass.st.usm.edu
*
* Usage:  Tee <dev> [...] [...]
*
* Tee accepts input from StdIn.  You may use a pipe to send it information,
* or use the '<' operator of the shell to redirect StdIn.
*

                    nam       Tee
                    ttl       Tees input to multiple outputs

                    ifp1
                    use       defsfile
                    endc

                    mod       Size,Name,Prgrm+Objct,ReEnt+1,Start,Fin

Name                fcs       "Tee"
                    fcb       $03                 Replaces Tandy's Edition #2

PathCnt             rmb       1
BuffSize            rmb       2
StdOut              rmb       1                   StdOut path...
PathStk             rmb       40                  +40 = Handles 41 paths in all!
Buffer              rmb       250                 Max. chars per line
Stack               rmb       200
Parms               rmb       200
Fin                 equ       .

Start               lda       #1
                    sta       PathCnt,u           store a 1 in the path counter buffer
                    sta       StdOut,u            and the StdOut buffer
                    leay      PathStk,u           Position Y on the path queue

GetNext             lda       #WRITE.             Set mode to write only
                    ldb       #UPDAT.+PREAD.      owner read/write, other read
                    os9       I$Create            create the path
                    bcs       Error               exit if error

                    sta       ,y+                 store the path on path stack, inc Y
                    inc       PathCnt,u           inc path counter

CheckCR             lda       ,x                  See if last param on line
                    cmpa      #C$CR               if cr, must be last parm
                    beq       GoTee               so start teeing out
                    leax      1,x                 inc X
                    bra       CheckCR             and check again

EOF                 cmpb      #E$EOF              Check for end-of-file
                    bne       Error               nope, other error, abort

Done                clrb                          else clear out nicely...
Error               os9       F$Exit              and exit!

GoTee               clra                          use StdIn
                    ldy       #250                Buffer holds 250 chars. per line
                    leax      Buffer,u            point X to buffer
                    os9       I$ReadLn            read a line from stdin
                    bcs       EOF                 check EOF if error
                    sty       BuffSize,u          else save bytes read
                    ldb       PathCnt,u           load B with the Path counter value
                    leay      StdOut,u            position Y at the StdOut path (1st)

Service             lda       ,y+                 load A with path number
                    pshs      y                   save Y
                    ldy       BuffSize,u          get buffer size
                    os9       I$WritLn            write out
                    bcs       Error               Error if exit
                    puls      y                   get Y
                    decb                          decrement B
                    bne       Service             if not 0, service next path
                    bra       GoTee               else get more input from StdIn

                    emod
Size                equ       *
                    end

