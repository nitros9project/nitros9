********************************************************************
* CPUType - Identify 6809 or 6309
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      ????/??/??  Alan DeKok
* Started.
*
*   2      2003/04/02  Boisy G. Pitre
* Fixed a crash bug on 6809, now just reports 6809 message on a 6809.
*
*   3      2003/04/23  Rodney V. Hamilton
* Rearranged code, used short offsets.

                    nam       CPUType
                    ttl       Identify 6809 or 6309

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+Rev
rev                 set       $00
edition             set       3

                    org       0
                    rmb       $0100               for the stack
size                equ       .

                    mod       eom,name,tylg,atrv,start,size

name                fcs       /CPUType/
                    fcb       edition

c.6809              fcc       /CPU: 6809/
                    fcb       C$CR

c.6309              fcc       /CPU: 6309, running in /
L6309               equ       *-c.6309

m.6809              fcc       /6809 mode./
                    fcb       C$CR

m.6309              fcc       /6309 native mode./
                    fcb       C$CR

* Entry of program
* First, let's determine if we have a 6309 or 6809
Start               ldd       #$FFFF              make sure D is non-zero
                    leax      <c.6809,pc          default to 6809 cpu
                    fdb       $104F               (CLRD) execs as pseudo-NOP ($10), and CLRA on 6809
                    tstb                          is this a 6309?
                    bne       print               no, print 6809 cpu and exit
is.6309             leax      <c.6309,pc          yes, print 6309 message
                    ldy       #L6309
                    lda       #1                  to STDOUT
                    os9       I$Write             dump it out

* This code is executed only if we have a 6309
* Determine if we are in native mode or not
                    pshs      cc,dp,x,y,u         save all registers but D
                    fdb       $1038               (PSHSW)
                    leay      <native,pc          native mode PC
                    leax      <emulate,pc         emulation mode PC
                    pshs      x,y                 save them
                    pshs      cc,d,dp,x,y,u       and the rest of the registers, too.
                    orcc      #Entire             set the entire bit in CC
                    rti

emulate             leas      2,s                 emulation mode: kill native mode PC
                    clrb                          we're in emulation mode
                    fcb       $8C                 skip 2 bytes
native              ldb       #1                  in native mode
                    puls      u                   restore W
                    fdb       $1F36               (TFR U,W)
                    puls      cc,dp,x,y,u         restore all of our other registers

emumsg              leax      <m.6809,pc          default to 6809
                    tstb                          are we in native mode?
                    beq       print               no
                    leax      <m.6309,pc          get the 6309 message

print               ldy       #$0100              a lot
                    lda       #1                  to STDOUT
                    os9       I$WritLn
                    clrb                          no errors
                    os9       F$Exit

                    emod
eom                 equ       *
                    end

