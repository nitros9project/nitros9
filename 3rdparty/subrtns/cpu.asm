********************************************************************
* CPU - CPU Determiner Subroutine Module
*
* $Id$
*
* Basic09 subroutine module to determine the CPU type of the computer
* Test via:
*
* PROGRAM CPU
* DIM CPUType,Mode:integer
* RUN CPU(Type,Mode)
* PRINT "CPU type:";CPUType
* IF Mode=0 THEN
*  PRINT "6809 Emulation mode"
* ELSE
*  PRINT "6309 Native mode"
* ENDIF
* END
*
* returns: CPUType: 6809 or 6309  (decimal integer)
*             Mode: 0=emulation mode, 1=native mode
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------
*   1    Created                                        ADK ??/??/??

                    nam       CPU
                    ttl       CPU Determiner Subroutine Module

                    ifp1
                    use       defsfile
                    endc

rev                 set       1                   first revision
tylg                set       Sbrtn+Objct
atrv                set       ReEnt+Rev
edition             set       1

                    org       0
                    rmb       2                   return address
PCount              rmb       2                   number of parameters
Param1              rmb       2                   1st param address
Length1             rmb       2                   size
Param2              rmb       2
Length2             rmb       2
Size                equ       .

                    mod       eom,name,tylg,atrv,start,size

name                fcs       /CPU/
                    fcb       edition

Start               ldd       PCount,s            get parameter count
                    cmpd      #2                  2 parameters?
                    bne       p.error             no, error out.

                    ldd       Length1,s           get size of the first parameter
                    cmpd      #2                  integer variable?
                    bne       p.error             no, error out.

                    ldd       Length2,s
                    cmpd      #2                  integer variable?
                    bne       p.error             no, error out.

* do a 6309/6809 test
                    ldd       #$FFFF              make sure it's non-zero
*         clrd             executes as a pseudo-NOP ($10), and a CLRA
                    fdb       $104F
                    tstb
                    bne       is.6809
                    ldd       #6309               it's a 6309
                    bra       save.1

is.6809             ldd       #6809               it's a 6809
save.1              ldx       Param1,s            where to put the CPU type
                    std       ,x                  save the integer CPU type

* if it's a 6809, we don't need to do the next part, as we KNOW it's
* running in 6809 emulation mode!

* this is harder.... are we in native mode?
                    pshs      cc,dp,x,y,u         save all registers but D
*         pshsw            a NOP on a 6809
                    fdb       $1038

                    leay      native,pc           native mode PC
                    leax      emulate,pc          emulation mode PC
                    pshs      x,y                 save them
                    pshs      cc,d,dp,x,y,u       and the rest of the registers, too.
                    orcc      #Entire             set the entire bit in CC
                    rti

emulate             leas      2,s                 emulation mode: kill native mode PC
                    clrb                          we're in emulation mode
                    fcb       $8C                 skip 2 bytes
native              ldb       #1                  in native mode
                    puls      u                   restore W from off-stack
*         tfr   u,w        a PULSW does an 'RTS' on a 6809
                    fdb       $1F36
                    puls      cc,dp,x,y,u         restore all of our other registers
                    clra                          now d=0: emulation, 1: native
                    ldx       Param2,s            where to put the data
                    std       ,x                  save native/emulation mode flag
                    clrb                          no errors
                    rts

p.error             comb                          set the carry
                    ldb       #$38                Basic09 parameter error
                    rts

                    emod
eom                 equ       *
                    end
