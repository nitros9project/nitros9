***************************************************************
*
* BigBro - Forks to Procs for continuous viewing of processes
*
*          Great for SysOps and System Administrators
*
* (C) 1991 Boisy G. Pitre
*
* Log:   12/07/91 - Created Program
*
* Note:  You are allowed to modify ONLY the Cls, Top, and EreoScr
*        bytes to match that of your terminal type.  You may also
*        need to change the Y registers at the points that they
*        are written to the screen (i.e. TVI925 uses 3 bytes to
*        clear the screen).
*

                    nam       BigBro
                    ttl       Forks to the Procs utility for monitoring processes

                    ifp1
                    use       defsfile
                    endc

                    mod       Size,Name,Prgrm+Objct,ReEnt+1,Start,Fin
Name                fcs       /BigBro/
ed                  fcb       1

Stack               rmb       250
Fin                 equ       .

Module              fcc       /Procs/
                    fcb       $0d
Cls                 fcb       $0c                 Clear screen byte
Top                 fcb       $01                 Home cursor byte
EreoScr             fcb       $0b                 Erase-end-of-screen byte


* Start of Program - no parameters recognized

Start               leax      Cls,pcr             Clear screen initially
                    lda       #1                  to StdOut...
                    ldy       #1                  ...one byte
                    os9       I$Write             Write it
                    bcs       Error

Loop                leax      Top,pcr             Point to Home cursor byte
                    lda       #1                  to StdOut...
                    ldy       #1                  ...one byte
                    os9       I$Write             Write it!
                    bcs       Error

                    lda       #Prgrm+Objct        Set Type/Lang Byte
                    clrb                          No memory used
                    leax      Module,pcr          Point to module to fork's name
                    ldy       #0                  No parameters
                    os9       F$Fork              Fuck it!
                    bcs       Error
                    os9       F$Wait              Wait till process finishes
                    tstb                          see if a signal occurred
                    bne       Done                ...if so, probably BREAK, so quit
                    leax      EreoScr,pcr         else point to ereoscr byte
                    lda       #1                  to Stdout...
                    ldy       #1                  ...one byte
                    os9       I$Write             Write it!
                    bcs       Error
                    bra       Loop                Loop back and do it all again

Done                clrb                          clear B for no errors

Error               os9       F$Exit              Leave the program
                    emod
Size                equ       *
                    end

