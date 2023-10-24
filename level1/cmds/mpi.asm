********************************************************************
* mpi - Determines if a Multi-Pak Interface is present
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2004/03/16  Rodney Hamilton
* Created.
*
*   1r1    2004/05/08  Boisy G. Pitre
* Fixed a problem where wrong message was being reported due to buggy
* code, placed there by me :(

                    nam       mpi
                    ttl       Determines if a Multi-Pak is present

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    org       0
                    rmb       200
size                equ       .

name                fcs       /mpi/
                    fcb       edition

no                  fcc       "No "
mpi                 fcc       "MPI found"
                    fcb       C$CR

start               equ       *
                    tfr       cc,b                save CC into B
                    ldx       #$FF7F              get MPI slot sel reg contents
                    lda       #$CC                load A with %11001100
                    orcc      #IntMasks           mask interrupts from this point on
                    eora      ,x                  XOR with MPI slot sel reg contents
                    sta       ,x                  and save...
                    cmpa      ,x                  same?
                    beq       is_mpi              branch if so
                    leax      <no,pc              else point to "no"...
                    bra       doit                and DO IT!
is_mpi              leax      <mpi,pc             or point to "yes"...
doit                tfr       b,cc                restore original CC
                    ldy       #100
                    lda       #$01
                    os9       I$WritLn            write the message at ,X
                    bcs       L001C
                    clrb
L001C               os9       F$Exit              exit...

                    emod
eom                 equ       *
                    end
