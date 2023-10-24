********************************************************************
* Boot - CoCo Emulator Virtual Hard Disk Booter
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2002/10/10  Boisy G. Pitre
* Acquired from Robert Gault.

                    nam       Boot
                    ttl       CoCo Emulator Virtual Hard Disk Booter

                    ifp1
                    use       defsfile
                    endc

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       2

* This boot module is intended for either MESS or Jeff's emulator
* Written by Robert Gault based on a personal boot for an RGBDOS hard drive
* Hard Disk Interface registers for the VHD emulator drives

dataport            equ       $FF80
status              equ       dataport+3
commnd              equ       dataport+3
buffer              equ       dataport+4
lsn                 equ       dataport


                    mod       eom,name,tylg,atrv,start,size

blockloc            rmb       2                   pointer to memory requested
blockimg            rmb       2                   duplicate of the above
bootloc             rmb       3                   sector pointer; not byte pointer
bootsize            rmb       2                   size in bytes
size                equ       .

name                fcs       /Boot/
                    fcb       1
start               clra
                    ldb       #size
clean               pshs      a
                    decb
                    bne       clean
                    tfr       s,u                 get pointer to data area
                    pshs      u                   save pointer to data area

                    lda       #$d0                forced interrupt; kill floppy activity
                    sta       $FF48               command register
                    clrb
pause               decb
                    bne       pause
                    lda       $FF48               clear controller
                    clr       $FF40               make sure motors are turned off
                    sta       $FFD9               fast clock

* Request memory for LSN0
                    ldd       #1
                    os9       F$SRqMem            request one page of RAM
                    bcs       error
                    bsr       getpntr

* Get LSN0 into memory

                    clrb                          MSB sector
                    ldx       #0                  LSW sector
                    bsr       mread
                    bcs       error
                    ldd       bootsize,u
                    beq       error
                    pshs      d

* Return memory

                    ldd       #$100
                    ldu       blockloc,u
                    os9       F$SRtMem
                    puls      d
                    os9       F$BtMem
                    bcs       error
                    bsr       getpntr
                    std       blockimg,u

* Get os9boot into memory

                    ldd       bootsize,u
                    leas      -2,s                same as a PSHS D
getboot             std       ,s
                    ldb       bootloc,u           MSB sector location
                    ldx       bootloc+1,u         LSW sector location
                    bsr       mread
                    ldd       bootloc+1,u         update sector location by one to 24bit word
                    addd      #1
                    std       bootloc+1,u
                    ldb       bootloc,u
                    adcb      #0
                    stb       bootloc,u
                    inc       blockloc,u          update memory pointer for upload
                    ldd       ,s                  update size of file left to read
                    subd      #$100               file read one sector at a time
                    bhi       getboot

                    leas      4+size,s            reset the stack    same as PULS U,D
                    ldd       bootsize,u
                    ldx       blockimg,u          pointer to start of os9boot in memory
                    andcc     #%11111110          clear carry
                    rts                           back to os9p1

error               leas      2+size,s
                    ldb       #E$NotRdy           drive not ready
                    rts

getpntr             tfr       u,d                 save pointer to requested memory
                    ldu       2,s                 recover pointer to data stack
                    std       blockloc,u
                    rts

mread               tstb                          LSN0 high byte
                    bne       read10
                    cmpx      #0                  LSN0 low word
                    bne       read10
                    bsr       read10
                    bcc       readlsn0
                    rts

readlsn0            pshs      a,x,y               find location of boot track
                    ldy       blockloc,u
                    lda       DD.Bt,y             os9boot pointer
                    ldx       DD.Bt+1,y           LSW of 24 bit address
                    sta       bootloc,u
                    stx       bootloc+1,u
                    ldx       DD.BSZ,y            os9boot size in bytes
                    stx       bootsize,u
                    clra
                    puls      a,x,y,pc

* Generic read

read10              clra
                    bsr       setup
                    bra       command

setup               pshs      x
                    stb       lsn
                    stx       lsn+1
                    ldx       blockloc,u
                    stx       buffer
                    puls      x,pc

command
                    sta       commnd
                    lda       commnd
                    rts

* Fillers to get to $1D0

                    fill      $39,$1D0-*-3

                    emod
eom                 equ       *
                    end
