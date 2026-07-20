*     TCCCHD: Hard disk driver/scsi host adapter driver for OS9
*     Copyright (C) 1990,1991,1992,1993,1994,1995,1996 Robert E. Brose II
*
*     This program is free software; you can redistribute it and/or modify
*     it under the terms of the GNU General Public License as published by
*     the Free Software Foundation; either version 2 of the License, or
*     (at your option) any later version.
*
*      This program is distributed in the hope that it will be useful,
*      but WITHOUT ANY WARRANTY; without even the implied warranty of
*      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*      GNU General Public License for more details.
*
*      You should have received a copy of the GNU General Public License
*      along with this program; if not, write to the Free Software
*      Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

                    opt       w131
                    nam       Hard                Disk driver, flip-flop & latch version.
                    ttl       title page

* experimental no DP version 9-11-90
**************************************************************
*     T C C C (TC^3)                                         *
*     H A R D   D I S K       device driver for CoCo OS9     *
*                             written by Robert E. Brose II  *
*     uses Western digital WD 1002-shd or Xebec 5" controller*
*     host adapter modeled after example in Xebec manual     *
*     Allows use of 2 different drives with separate offsets *
*     for partitioning (ms 13 bits of 21 bit sector #)       *
**************************************************************
*
*
* physical drive number stored in IT.DNS.
*
* revision history
*------------------------------------
* 2.0 Totally revamped
*     Controller number gotten from the PD (PD.DNS lower 4 bits).
*     Avoids use of DP, it's faster without it.
*     Most subroutines moved to inline code to increase speed
*     Added time slice release if controller is busy 12/01/90
*     set blocks in init instead of doing it on every packet 12/01/90
* 2.1 Added adaptec conditional statements 02-23-92
*     Uniform descriptors, params adaptec doesn't need are ignored 02-23-92
* 2.2 init/don't init drive, bit 6 of PD.DNS. 1=don't init 1-15-94
*     resets drive in setup routine 1-16-94
*     locks scsi packet, elims conflict on multiple drives on the same
*     host adapter. 1-16-94
*     altered format to work with seagate drives. 1-16-94
* 5/6.x changed revisn and versn below to match up with this history 1-19-94
* 5.x 256 byte sectors version.
* 6.x 1K HD sectors version. 1-19-94
* 5/6.2 added HOG flag for maximum speed, to hog the cpu
* 5/6/7/8.3 Added MEDSEC for 512 byte sectors
* 5/6/7/8.4 much 6309 optimisation
* 9.x Redid version/revision stuff again. Version is now 9, revision
*     indicates sector size. 6809: 1=256 by/sec 2=512 by/sec 3=1024 by/sec
*     Nitros 6309  4=256 by/sec 5=512 by/sec 6=1024 by/sec
*10.x Changes to allow >1 drive with large sectors. 11-5-94
*     UGH removed for now, flush is too complicated with BIGSEC
*     changed 6309 block moves to I/O to allow for a gap to service serial
*      interrupts every 256 moves (affects sector sizes >256 bytes). 3-25-95
*11.x Optimizations from better understanding about when the driver can
*     be interupted, thanks Alan DeKok. 1-7-96
*     Handles inits of several scsi id'd devices. 1-7-96
*     Fixed Calcsec, logread and logwrit to handle 512 bytes/sector 1-8-96
*12.x Added DISTO HD II support 3-9-96
*      notes: sleep causes the only possible reentrant situation (~HOG)
*              in this case cmd block and cache buffer must be preserved.
*             To make multiple drives/driver work for 512 and 1024 (BUFSEC)
*              cases will require info like drive, lun, offset, etc to be
*              save for the previous sector so a cache flush can be done. YUK!
*     Added sector 0 cache because rbf accesses it all the darn time! 6-8-96

H6309               equ       1                   if 6309 cpu, 0=on!

                    ttl       equates
DBHS                equ       1                   data requires req handshake version 0=ON! (i.e. adaptec)
BIGSEC              equ       1                   use 1024 byte physical sectors (0=ON!)
MEDSEC              equ       0                   use 512 byte physical sectors (0=ON!)
HOG                 equ       1                   hog the cpu on waits (speeds up disk access 0=ON!)
DISTO               equ       1                   use HD II ports and status bits (0=ON!)
MDRIVES             equ       1                   can use more than 1 drive / driver in BUFSEC case (0=ON!)
MPAK                equ       1                   includes multipak switching code (needed for DISTO w/ MPAK 0=ON!)
CANFORM             equ       0                   drive formatting allowed (0=ON!)
CACHE               equ       1                   sector 0 cache (0=ON!).


* BUFSEC below means a buffer is used when reading/writing physical secs
* (0=on)

                    ifeq      BIGSEC
BUFSEC              equ       $0
m.smask             equ       %11111100
m.nsmask            equ       %00000011
                    else

                    ifeq      MEDSEC
BUFSEC              equ       $0
m.smask             equ       %11111110
m.nsmask            equ       %00000001
                    else

BUFSEC              equ       $1
                    endc
                    endc

                    ifeq      H6309

                    ifeq      BIGSEC
revisn              equ       6
                    else
                    ifeq      MEDSEC
revisn              equ       5
                    else
revisn              equ       4
                    endc
                    endc

                    else

                    ifeq      BIGSEC
revisn              equ       3
                    else
                    ifeq      MEDSEC
revisn              equ       2
                    else
revisn              equ       1
                    endc
                    endc

                    endc

verson              equ       12

numdrvs             equ       4                   number of drives supported by driver (logical)
* status byte mask

m.error             equ       %00000010           error flag

* status register bit masks

                    ifeq      DISTO
m.req               equ       %10000000           data request line
m.busy              equ       %00000001           busy status line
* broken on disto??? m.msg  equ %00000100 end of message status line
m.msg               equ       %00000000           end of message status line
m.cmd               equ       %01000000           command/data status line
m.in                equ       %00100000           input/output status line
* broken msg on disto ??? m.nnc  equ %11100101 unconnected lines = ignore mask
m.nnc               equ       %11100001           unconnected lines = ignore mask

                    else

* normal TCCC defs
m.req               equ       %00000001           data request line
m.busy              equ       %00000010           busy status line
m.msg               equ       %00000100           end of message status line
m.cmd               equ       %00001000           command/data status line
m.in                equ       %00010000           input/output status line

                    endc

m.phys              equ       %00100000           physical drive mask (LUN on Controller)
m.init              equ       %01000000           initialize drive on change flag
m.cont              equ       %00001111           controller address mask
m.recal             equ       %00010000           do a recal (home) on 1st drive access
m.format            equ       %10000000           enable format command

                    ifeq      MPAK
m.mpscs             equ       %11110000           Mpak slot select SCS clearing mask
mpsel               equ       $FF7F               multipak select latch addr, used for disto.
EXTPRM              equ       25                  extra params in descriptor
                    else
EXTPRM              equ       24                  extra params in descriptor
                    endc

* input and output ports offsets for HOST ADAPTER bus

                    ifeq      DISTO
datapo              equ       3                   read and write data
rstpo               equ       1                   software reset
selpo               equ       2                   controller select
statpo              equ       1                   read status
                    else

* Normal TCCC defines
datapo              equ       0                   read and write data
rstpo               equ       1                   software reset
selpo               equ       2                   controller select
selrst              equ       3                   reset of select (scuzzie adapters)
statpo              equ       1                   read status

                    endc

* controller opcodes

o.ready             equ       $00                 test for drive ready
o.param             equ       $0c                 set parameters for the drives
o.read              equ       $08                 read sector(s)
o.write             equ       $0a                 write sector(s)
o.formt             equ       $04                 format drive
o.recal             equ       $01                 recalibrate drive (head to track 0)

                    ifp1
                    use       defsfile
                    endc

                    ttl       data allocation

                    org       DRVBEG
tables              rmb       DRVMEM*numdrvs      reserve space for system tables

* command packet for controller

packet              equ       .

opcode              rmb       1                   command opcode
lun                 rmb       1                   logical unit number : ms part of lsn
lsn                 rmb       2                   logical sector number
blocks              rmb       1                   interleave or block count
control             rmb       1                   control byte set at packet send time
plocked             rmb       1                   above control block in use, locked
blocked             rmb       1                   buffer sector (caching) in use, locked

* extra parameters read in from the descriptor.

param               rmb       8                   physical drive 0 params
param1              rmb       8                   physical drive 1 params

* logical drive offsets

offsd1              rmb       2
offsd2              rmb       2
offsd3              rmb       2
offsd4              rmb       2

                    ifeq      MPAK
* Multipak latch temp storage and slot.
mpslot              rmb       1                   From descriptor, FF = no mpak
                    endc

* end of extra params read in from descriptor

                    ifeq      MPAK
mpstor              rmb       1                   Current multipak value outside of this driver.
                    endc
didflag             rmb       1                   read lsn 0 flag
lastphy             rmb       1                   last drive accessed (physical)
sec0fl              rmb       numdrvs             (recal (home) completed flag)
tempw1              rmb       2                   word temp var
tempw2              rmb       2                   word temp var

iniflg              rmb       numdrvs             whether or not the device has been initalized

                    ifeq      BUFSEC

                    ifeq      BIGSEC
secbuf              rmb       1024                buffer for physical sector
                    else
secbuf              rmb       512                 buffer for physical sector
                    endc

                    ifeq      CACHE
sec0                rmb       256*numdrvs         optional sector 0 cache
                    endc

lastdrv             rmb       1                   last LOGICAL drive accessed
lsech               rmb       1                   24 bit address, sector in buffer (logical w/o least sig 2 bits)
lsecm               rmb       1                   (part of above)
lsecl               rmb       1                   "
physech             rmb       1                   24 bit address, sector in buffer (physical sector in buffer)
physecm             rmb       1                   (part of above)
physecl             rmb       1                   "
cached              rmb       1                   cache is dirty flag
secidx              rmb       1                   index into physical sector
                    endc

endmem              equ       .

                    ttl       module entry

                    mod       endmod,name,drivr+objct,reent+verson,xferad,endmem
mode                fcb       $ff                 mode

                    ifeq      DISTO
                    ifeq      DBHS
name                fcs       "DIDBHS"
                    else
                    ifeq      BIGSEC
name                fcs       "DI1024"
                    else
                    ifeq      MEDSEC
name                fcs       "DIS512"
                    else
name                fcs       "DISTHD"
                    endc
                    endc
                    endc

                    else

                    ifeq      DBHS
name                fcs       "DBHSHD"
                    else
                    ifeq      BIGSEC
name                fcs       "TC1024"
                    else
                    ifeq      MEDSEC
name                fcs       "TCC512"
                    else
name                fcs       "TCCCHD"
                    endc
                    endc
                    endc

                    endc

                    fcb       revisn

* rbf dispatch vectors

xferad              lbra      INIT

                    ifeq      BUFSEC
                    lbra      LOGREAD
                    else
                    bra       READ
                    nop
                    endc


                    ifeq      BUFSEC
                    bra       LOGWRIT
                    else
                    bra       WRITE
                    endc

                    nop
                    lbra      GETSTA
                    lbra      SETSTA
                    lbra      TERM

                    ifeq      BUFSEC
                    ttl       logical sector write

* logwrit
*
* input:
* b = msb of os9 lsn
* x = lsbs of os9 lsn
* y = path descriptor
* u = static storage
*
* output:
* 256 bytes moved from the os9 buffer to the physical buffer. Any
* necessary physical sector writing and reading is done also.
*
LOGWRIT

                    ifne      HOG
                    pshs      u
logwr01             tst       blocked,u           critical lock on this section
                    beq       logwr02             because of the buffer
                    pshs      b,x
                    ldx       #1
                    os9       F$Sleep             wait a while
                    puls      b,x
                    bra       logwr01             and check again
logwr02             com       blocked,u           set it
                    endc

                    pshs      b                   save HSB
                    tfr       x,d                 msb and lsb into d for manipulation
                    stb       secidx,u            save lsb for indexing into phys sec buf later
                    andb      #m.smask            zero indexing bits
                    cmpd      lsecm,u             lower part of logical sector
                    puls      b                   get back HSB
                    bne       diffwr              if compare fails, new sector, need preread
                    cmpb      lsech,u             compare HSB's

                    ifne      MDRIVES
                    beq       cpysecw             ok, in buffer
diffwr

                    else

                    bne       diffwr              failed new sec need preread
                    lda       PD.DRV,y            current drive
                    cmpa      lastdrv,u           = last drive?
                    beq       cpysecw             if same, log sector is in physical buffer
diffwr
                    sta       lastdrv,u           save logical drive for future compare
                    endc

                    tst       cached,u            need to flush physical sector?
                    beq       cleanw              no, skip ahead
                    pshs      b,x,y,u             save new sector
                    ldb       physech,u           get current HSB
                    ldx       physecm,u           get current msb & lsb
                    lbsr      WRITE               do the physical write
                    puls      b,x,y,u             restore new sector
                    bcs       logwre              exit on write error

cleanw              lbsr      calcsec
                    pshs      y
                    lbsr      READ                read the physical sector
                    puls      y
                    bcs       logwre              exit on read error

cpysecw
                    ldy       PD.BUF,y            os9 buffer
                    lda       secidx,u            index into physical buffer
                    anda      #m.nsmask           mask upper off
                    leax      secbuf,u            location of physical buffer
                    ldb       #128
cpsw2               tsta                          done calculating index?
                    beq       cpsw2b              yup, exit loop
                    abx                           these 2 ins advance 256 bytes into physical buffer
                    abx
                    deca
                    bra       cpsw2

cpsw2b              clr       cached,u
                    com       cached,u            set cache dirty flag

                    ifeq      H6309

cpsw3               ldw       #256                bytes to copy
                    tfm       y+,x+

                    else

* 16 bit copy, 128 words from os9 buff to phys buff
cpsw3               ldu       ,y++                get byte from os9 buffer
                    stu       ,x++                to phys sector
                    decb
                    bne       cpsw3

                    endc

                    clrb

logwre

                    ifne      HOG
                    puls      u                   restore static pointer
                    clr       blocked,u           clear lock on this section
                    endc

                    rts


                    ttl       logical sector read

* logread
*
* input:
* b = msb of os9 lsn
* x = lsbs of os9 lsn
* y = path descriptor
* u = static storage
*
* output:
* 256 bytes moved from the physical buffer to the os9 buffer. Any
* necessary physical sector writing and reading is done first.
*
LOGREAD

                    ifne      HOG
                    pshs      u
logre01             tst       blocked,u           critical lock on this section
                    beq       logre02             because of the buffer
                    pshs      b,x
                    ldx       #1
                    os9       F$Sleep             wait a while
                    puls      b,x
                    bra       logre01             and check again
logre02             com       blocked,u           set lock
                    endc

                    pshs      b                   save HSB
                    tfr       x,d                 msb and lsb into d for manipulation
                    stb       secidx,u            save lsb for indexing into phys sec buf later
                    andb      #m.smask            zero indexing bits
                    cmpd      lsecm,u             lower part of phys sector
                    puls      b                   get back HSB
                    bne       diffrd              if compare fails, new sector to read
                    cmpb      lsech,u             compare HSB's

                    ifne      MDRIVES
                    beq       cpysecr             ok, in buffer
diffrd

                    else

                    bne       diffrd              failed new sec need preread
                    lda       PD.DRV,y            current drive
                    cmpa      lastdrv,u           = last drive?
                    beq       cpysecr             if same, log sector is in physical buffer
diffrd
                    sta       lastdrv,u           save logical drive for future compare
                    endc

                    tst       cached,u            need to flush physical sector?
                    beq       cleanr              no, skip ahead
                    pshs      b,x,y,u             save new sector
                    ldb       physech,u           get current HSB
                    ldx       physecm,u           get current msb & lsb
                    lbsr      WRITE               do the physical write
                    puls      b,x,y,u             restore new sector
                    bcs       logrde              exit on write error

cleanr              bsr       calcsec
                    pshs      y
                    lbsr      READ                read the physical sector
                    puls      y
                    bcs       logrde              exit on read error

cpysecr
                    ldy       PD.BUF,y            os9 buffer
                    lda       secidx,u            index into physical buffer
                    anda      #m.nsmask           mask upper off
                    leax      secbuf,u            location of physical buffer
                    ldb       #128
cpsr2               tsta                          done calculating index?
                    beq       cpsr3               yup, exit loop
                    abx                           these 2 ins advance 256 bytes into physical buffer
                    abx
                    deca
                    bra       cpsr2

                    ifeq      H6309

cpsr3               ldw       #256
                    tfm       x+,y+

                    else

* 16 bit copy, 128 words from phys buff to os9 buff
cpsr3               ldu       ,x++                get byte from phys sec
                    stu       ,y++                to os9 buffer
                    decb
                    bne       cpsr3

                    endc

                    clrb
logrde

                    ifne      HOG
                    puls      u                   restore static pointer
                    clr       blocked,u           clear lock on this section
                    endc

                    rts

* fast calcsec (see comments in 6809 code below)

                    ifeq      H6309
calcsec             stb       lsech,u
                    tfr       x,w

                    tfr       f,a
                    anda      #m.smask
                    sta       lsecl,u
                    ste       lsecm,u

*aim #m.smask,lsecl,u

* 4x (256 x 4 =1k sector) or 2x (256 x 2 = 512 sector)

                    ifeq      BIGSEC
                    lsrb
                    rorw
                    endc

                    lsrb
                    rorw
                    stb       physech,u
                    tfr       w,x
                    stx       physecm,u
                    rts

                    else

calcsec             stb       lsech,u             save logical sec hsb for next compare
                    stb       physech,u           and in physec for shifting
                    tfr       x,d                 get msb & lsb into d for shifting
                    andb      #m.smask            strip lower bits lsb sec #
                    std       lsecm,u             save it for compare
                    std       physecm,u           as above for shifting
                    lsr       physech,u           shift 24 bits right 2 bits, converts to physical sec # (1st 8)
                    ror       physecm,u           (2nd 8)
                    ror       physecl,u           (3rd 8)

* 4x (256 x 4 =1k sector) or 2x (256 x 2 = 512 sector)
                    ifeq      BIGSEC
                    lsr       physech,u           (1st 8, second time)
                    ror       physecm,u           (2nd 8, second time)
                    ror       physecl,u           (3rd 8, second time)
                    endc

                    ldx       physecm,u           for return value
                    ldb       physech,u           for return value
                    rts

                    endc                          (H6309)
                    endc                          (bufsec)

                    ttl       write sector

*  write
*
* input:
*  b = msb of lsn
*  x = lsb's of lsn
*  y = path descriptor
*  u = static storage
*
* output:
*   b,x,y,u destroyed
*   256 bytes written (512/1024 bufsec version)
*   otherwise, carry set and b = error code
*
*
WRITE
                    ifeq      MPAK
                    pshs      u                   need for restore at end of write routine
                    tst       mpslot,u            multipak in use? (1xxxxxxxb = no)
                    bmi       slotw2              hi bit set, skip
                    lda       >mpsel              get current value
                    sta       mpstor,u            save it
                    anda      #m.mpscs            clear scs bits
                    ora       mpslot,u            add in scs select
                    sta       >mpsel              put it to mpak
slotw2
                    endc

                    lda       #o.write            controller write opcode
                    lbsr      setup               setup  packet, initiate command

                    ifeq      BUFSEC
                    leax      secbuf,u            get address of physical sector buffer
                    clr       cached,u            clear cache dirty flag
                    else
                    ldx       PD.BUF,y            get buffer address into x
                    endc

                    ldu       V.PORT,u
                    leay      statpo,U
                    leau      datapo,u            u points to data port
                    lda       #m.req

                    ifeq      HOG
W0                  bita      ,y                  get req bit
                    beq       W0                  wait till req

                    else

W00                 clrb                          256 tries
W0                  bita      ,y                  get req bit
                    bne       W0B
                    decb
                    bne       W0                  keep trying
                    lbsr      doslp
                    bra       W00

                    endc

                    ifeq      DBHS
W0B                 bra       W1                  first req got already, skip ahead
W0C                 ldb       ,y                  status port
                    bitb      #m.req              have req?
                    beq       W0C                 wait till we do
                    bitb      #m.cmd              finished putting data?
                    bne       W2A                 if so, skip ahead
W1                  lda       ,x+                 get a byte from memory
                    sta       ,u                  put it to the drive
                    bra       W0C                 go again

                    else

* for 6309, use block transfer fixed size. Not really according to scsi
* spec, but FAST!

                    ifeq      H6309
W0B
                    ifeq      BIGSEC
                    ldw       #1024
                    tfm       x+,u
                    else
                    ifeq      MEDSEC
                    ldw       #512
                    tfm       x+,u
                    else
                    ldw       #256
                    tfm       x+,u
                    endc
                    endc

                    else

                    ifeq      DISTO
W0B                 bra       W2
W1                  lda       ,X+
                    sta       ,U
W2                  ldb       ,Y
                    andb      #m.nnc              and out the floating bits
                    cmpb      #m.req+m.busy       still have data?
                    beq       W1                  yup go for more

                    else
W0B                 ldb       #m.req+m.busy       status mask for command/data mode
                    bra       W2
W1                  lda       ,X+
                    sta       ,U
W2                  cmpb      ,Y
                    beq       W1
                    endc

* didn't work, don't know why. changed to make disto easier

*W0B ldb #m.cmd command mode?
* bra W2
*W1 LDA ,X+
* STA ,U
*W2 BITB ,Y
* BEQ W1 not command mode yet, go for more data

                    endc
                    endc

                    ifeq      DISTO

W2A                 ldb       ,y                  get status bits
                    andb      #m.nnc              strip floating bits
                    cmpb      #m.req+m.busy+m.cmd+m.in
                    bne       W2A
                    lda       ,u                  status data byte
W2C                 ldb       ,y                  get status bits
                    andb      #m.nnc              strip floating bits
                    cmpb      #m.req+m.busy+m.msg+m.cmd+m.in
                    bne       W2C

                    else

W2A                 ldb       #m.req+m.busy+m.cmd+m.in
W2B                 cmpb      ,y                  get status
                    bne       W2B
                    lda       ,u                  status data byte
                    ldb       #m.req+m.busy+m.msg+m.cmd+m.in
W2C                 cmpb      ,y
                    bne       W2C                 get term byte

                    endc

                    ldb       ,u                  discard
                    anda      #m.error            isolate error bit
                    beq       w3                  if no error
                    comb                          flag error
                    ldb       #E$Write            error code for OS9
                    bra       w4

w3                  clrb                          flag no errors

w4
                    ifeq      MPAK
                    puls      u                   saved at top of routine
                    pshs      a,cc
                    lda       mpstor,u
                    sta       >mpsel              restore old mpak slot value
                    puls      a,cc
                    endc

                    rts


                    ttl       read sector

*  read
*
* input:
*  b = hsb of lsn
*  x = lsb's of lsn
*  y = path descriptor
*  u = static storage
* output:
*  b,x,y destroyed, u preserved
*  if no error, 256 bytes into sector buffer
*   otherwise carry set and b = error
*
*
READ
                    ifeq      MPAK
                    tst       mpslot,u            multipak in use? (1xxxxxxxb = no)
                    bmi       slotr2              hi bit set, skip change
                    lda       >mpsel              get current value
                    sta       mpstor,u            save it
                    anda      #m.mpscs            clear scs bits
                    ora       mpslot,u            add in scs select
                    sta       >mpsel              put it to mpak
slotr2
                    endc

                    tstb                          hsb = 0
                    bne       rdnot0              no, skip
                    leax      ,x                  msb & lsb =0?
                    bne       rdnot0

                    ifeq      BUFSEC
                    lda       secidx,u            least 2 bits are in here
                    anda      #m.nsmask
                    bne       rdnot0
                    endc

* first access to drive (implied) so recal the drive to home heads.

                    pshs      d,x
                    leax      sec0fl,u            get flag for this drive
                    lda       PD.DRV,y            get drive #
                    tst       a,x                 drive LSN0 already read?
                    bne       sec0dn              yup, skip it
                    com       a,x                 flag recal done now
                    clr       didflag,u
                    com       didflag,u           set disk id sec flag on
                    lda       PD.DNS,y
                    anda      #m.recal            should this drive be homed?
                    beq       sec0dn

                    ldx       #0                  clear sector # back out (B is still clear)

                    lda       #o.recal
                    lbsr      setup

                    ifeq      DISTO

recal0              ldb       statpo,x            (see comments at W2A)
                    andb      #m.nnc
                    cmpb      #m.req+m.busy+m.cmd+m.in
                    bne       recal0
                    lda       datapo,x
recal1              ldb       statpo,x
                    andb      #m.nnc
                    cmpb      #m.req+m.busy+m.msg+m.cmd+m.in
                    bne       recal1

                    else

                    ldb       #m.req+m.busy+m.cmd+m.in
recal0              cmpb      statpo,x
                    bne       recal0
                    lda       datapo,x
                    ldb       #m.req+m.busy+m.msg+m.cmd+m.in
recal1              cmpb      statpo,x
                    bne       recal1

                    endc

                    lda       datapo,x
sec0dn
                    puls      d,x

rdnot0              lda       #o.read             opcode for read operation
                    lbsr      setup               setup packet, initiate command

                    ifeq      BUFSEC
                    leax      secbuf,u            physical buffer location
                    clr       cached,u
                    else
                    ldx       PD.BUF,y            setup buffer loc in x
                    endc

                    pshs      Y,U
                    ldu       V.PORT,u
                    leay      statpo,U
                    leau      datapo,u

                    lda       #m.req              wait for data request

                    ifeq      HOG

R0                  bita      ,y
                    beq       R0                  wait for req

                    else
R00                 clrb                          256 tries for req
R0                  bita      ,y
                    bne       R0B
                    decb
                    bne       R0                  keep trying
                    lbsr      doslp
                    bra       R00

                    endc

                    ifeq      DBHS

R0B                 bra       R1                  first time have req, skip forward
R0C                 ldb       ,y                  get status
                    bitb      #m.req              request bit
                    beq       R0C                 no, go again
                    bitb      #m.cmd              finished with data?
                    bne       R2A                 yes, skip ahead
R1                  lda       ,u                  get data from the controller
                    sta       ,x+                 to memory
                    bra       R0C                 go again

                    else

R0B
* for 6309, use block transfer fixed size. Not really according to scsi
* spec, but FAST!

                    ifeq      H6309
                    ifeq      BIGSEC
                    ldw       #256
                    orcc      #%01010000
                    tfm       u,x+
                    andcc     #%10101111
                    ldw       #256
                    orcc      #%01010000
                    tfm       u,x+
                    andcc     #%10101111
                    ldw       #256
                    orcc      #%01010000
                    tfm       u,x+
                    andcc     #%10101111
                    ldw       #256
                    orcc      #%01010000
                    tfm       u,x+
                    andcc     #%10101111
                    else
                    ifeq      MEDSEC
                    ldw       #256
                    orcc      #%01010000
                    tfm       u,x+
                    andcc     #%10101111
                    ldw       #256
                    orcc      #%01010000
                    tfm       u,x+
                    andcc     #%10101111
                    else
                    ldw       #256
                    orcc      #%01010000
                    tfm       u,x+
                    andcc     #%10101111
                    endc
                    endc

                    else

                    ifeq      DISTO
                    bra       R2
R1                  lda       ,U
                    sta       ,X+
R2                  ldb       ,Y
                    andb      #m.nnc              and out floating bits
                    cmpb      #m.in+m.busy+m.req  still more data?
                    beq       R1                  yes, go for more
                    else
                    ldb       #m.in+m.busy+m.req  test bit for command/data mode
                    bra       R2
R1                  lda       ,U
                    sta       ,X+
R2                  cmpb      ,Y
                    beq       R1
                    endc

                    endc
                    endc

                    ifeq      DISTO

R2A                 ldb       ,y                  get status bits
                    andb      #m.nnc              strip floating bits
                    cmpb      #m.req+m.busy+m.cmd+m.in
                    bne       R2A
                    lda       ,u                  status data byte
R2C                 ldb       ,y                  get status bits
                    andb      #m.nnc              strip floating bits
                    cmpb      #m.req+m.busy+m.msg+m.cmd+m.in
                    bne       R2C

                    else

R2A                 ldb       #m.req+m.busy+m.cmd+m.in
R2B                 cmpb      ,y                  get status
                    bne       R2B
                    lda       ,u                  status data byte
                    ldb       #m.req+m.busy+m.msg+m.cmd+m.in
R2C                 cmpb      ,y
                    bne       R2C                 get term byte

                    endc

                    ldb       ,u                  discard
                    anda      #m.error            isolate error bit
                    puls      Y,U
                    beq       r3                  if no error detected
                    comb                          flag error to OS9
                    ldb       #E$Read             error code to be returned
                    bra       r6
r3                  lda       didflag,u
                    beq       r5                  if lsn not 0
                    clr       didflag,u
                    lda       PD.DRV,y            get drive number
                    ldb       #DRVMEM             size of each entry
                    mul                           calculate the offset into the table
                    leax      tables,u            get base address
                    leax      d,x                 get record address

                    ifeq      BUFSEC
                    leay      secbuf,u            physical sector buffer
                    else
                    ldy       PD.BUF,y            sector buffer address
                    endc

                    ifeq      H6309

                    ldw       #DD.SIZ
                    tfm       y+,x+

                    else

                    ldb       #DD.SIZ             number of bytes to copy
r4                  lda       ,y+                 get a byte from the disk identification sector
                    sta       ,x+                 put it into the drive table
                    decb                          count bytes to copy
                    bne       r4

                    endc

r5                  clrb
r6
                    ifeq      MPAK
                    pshs      a,cc
                    lda       mpstor,u
                    sta       >mpsel              restore old mpak slot value
                    puls      a,cc
                    endc

                    rts

                    ttl       device init

*  init
*
* input:
*  y = device descriptor
*  u = static storage
*
* output:
*  carry set if error
*  b = error code
*
*  y,u preserved. others destroyed

INIT                pshs      y

                    ldx       V.PORT,u

                    ifne      DISTO
                    sta       selrst,x            reset select line
                    endc

* removed 1-16-94, multiple drives are now imbeded scsi, each has controller
*  shouldn't do a scsi bus reset

* ifne ADAPTEC
* sta rstpo,x reset controllers (if more than one device, should be removed)
* ldb #m.busy
*iniw bitb statpo,x wait till not busy
* bne iniw
* endc

                    leay      $21,y               get start of params & offsets in descriptor
                    ldb       #EXTPRM             bytes to transfer
                    leax      param,u             start of drive parameters in static storage
offload             lda       ,y+                 get drive parameters from descriptor
                    sta       ,x+                 put into static
                    decb
                    bne       offload             if not done
                    puls      y
                    clr       didflag,u           sector 0 read flag=cleared
                    lda       #$ff                will set lastphy to undef
                    sta       lastphy,u           store it

                    ifeq      BUFSEC
                    sta       lastdrv,u           set last logical read to unknown
                    endc

                    ldb       #numdrvs            number of drives controller supports
                    stb       V.NDRV,u            to the manager space
                    leax      tables,u
                    lda       #$ff
fixtab              sta       DD.TOT,x            setup starting info in the tables until the first sector
                    clr       V.TRAK,x            of the device is read which will fill in the drive tables
                    sta       V.TRAK+1,x
                    leax      DRVMEM,x
                    decb
                    bne       fixtab              if not done with both tables
                    lda       #1
                    sta       blocks,u            set up for normal read/write 1 sector
                    clr       blocked,u           extended buffer locked flag
                    clr       plocked,u           param block locked flag

                    ifeq      BUFSEC
                    clr       cached,u            cache dirty flag
                    clr       secidx,u            index into physical sector
                    ldb       #$ff
                    stb       lsech,u             set begin phy sec number to impossible value to force read
                    stb       lsecm,u
                    ldb       #m.smask
                    stb       lsecl,u
                    endc

                    ldb       #numdrvs
                    leax      sec0fl,u            clean recal flags
clnrecal
                    clr       ,x+
                    decb
                    bne       clnrecal

                    clrb                          no errors
                    rts

                    ttl       sleep for rest of tick. Switch mpak slot if necessary (during HW Access)


* entry conditions:
* U = static storage
* exit conditions
* registers preserved

doslp
                    pshs      b,x

                    ifeq      MPAK
                    tst       mpslot,u            multipak in use? (1xxxxxxxb = no)
                    bpl       doslp2              hi bit clear, do change
                    ldx       #1
                    os9       F$Sleep             wait a while
                    bra       doslp               exit
doslp2              ldb       mpstor,u            get back old mpak sel value
                    stb       >mpsel              put it to mpak
                    endc

                    ldx       #1
                    os9       F$Sleep             wait a while

                    ifeq      MPAK
                    ldb       >mpsel              get current value (could have changed)
                    stb       mpstor,u            save it again
                    andb      #m.mpscs            clear scs bits
                    orb       mpslot,u            add in scs select
                    stb       >mpsel              put it to mpak
                    endc

doslpo
                    puls      b,x,pc


                    ttl       setup and initiate command

* entry conditions:
* Y = path descriptor
* A = opcode to controller
* B = MSB of disk logical sector number
* X = LSB's of disk logical sector number
* U = static storage
*
* setup command packet
* select controller
* initiate command
*
* exit conditions:
* A = destroyed
* B = destroyed
* X = controller base
* U = unchanged (static)
* Y = unchanged (PD)
*
setup
set0
                    ifne      HOG
                    tst       plocked,u           critical lock on this section
                    beq       set02
* sleep was inline, now call
                    bsr       doslp               sleep for a while
                    bra       set0                and check again
set02               com       plocked,u           set the lock
                    endc

                    sta       opcode,u            put controller opcode into command packet
                    stb       lun,u
                    stx       lsn,u
                    lda       PD.DNS,y            get physical drive number (0 or 1 supported) and init flag
                    tfr       a,b
                    anda      #m.phys             (bit 5 is physical drive number)
                    andb      #m.init
                    beq       set25               skip init if not set in desc

* changed 4-16-96, always check for init, based on descriptor
*was ifne ADAPTEC adaptec handles drive parameter switches internally

                    cmpa      lastphy,u           current physical drive?
                    beq       set25               yes, continue

                    pshs      a,y
                    sta       lastphy,u
                    ldx       V.PORT,u

* wait for controller to finish any previous command
* needs x set to port base and y set to pd

                    ldb       #m.busy             busy status bit
sel1                bitb      statpo,x            read status port

                    ifeq      HOG

                    bne       sel1                wait till not busy

                    else

                    beq       sel1b               skip if not busy
                    bsr       doslp
                    bra       sel1

                    endc

sel1b               lda       PD.DNS,y            controller number (lower 4 bits of PD.DNS var)
                    anda      #m.cont             isolate controller number
                    sta       datapo,x            latch the controller select
                    sta       selpo,x             generate a select strobe
sel2                bitb      statpo,x            read status port
                    beq       sel2                wait for controller to recognize select

                    ifne      DISTO
                    sta       selrst,x            reset select (scuzzie version)
                    endc

                    lda       lastphy,u           get drive back
                    leay      param,U             Point to Drive 0 Params as Default
                    tsta                          Is it Drive 0?
                    beq       setp2               yes, get drive 0 parameters
                    leay      param1-param,Y      Point to Drive 1 Params
setp2               lda       #m.req
setp3               bita      statpo,x            get status
                    beq       setp3               wait till ready
                    lda       #o.param            set param command
                    sta       datapo,x            send it out
                    ldb       #5                  rest of packet
                    clra
pakout              sta       datapo,x            dump em out!
                    decb
                    bne       pakout              if not done
                    lda       #m.req
setp4               bita      statpo,x
                    beq       setp4
                    ldb       #8                  # of parameters to send out
paramout            lda       ,y+                 get a parameter
                    sta       datapo,x            send it out
                    decb
                    bne       paramout            if not done, go again

                    ifeq      DISTO
setp5               ldb       statpo,x            get status bits
                    andb      #m.nnc              strip floating bits
                    cmpb      #m.req+m.busy+m.cmd+m.in
                    bne       setp5
                    lda       datapo,x            status data byte
setp6               ldb       statpo,x            get status bits
                    andb      #m.nnc              strip floating bits
                    cmpb      #m.req+m.busy+m.msg+m.cmd+m.in
                    bne       setp6

                    else

                    ldb       #m.req+m.busy+m.cmd+m.in
setp5               cmpb      statpo,x            get status
                    bne       setp5
                    lda       datapo,x            status data byte
                    ldb       #m.req+m.busy+m.msg+m.cmd+m.in
setp6               cmpb      statpo,x
                    bne       setp6               get term byte

                    endc

                    ldb       datapo,x            discard
                    puls      a,Y

set25
                    ora       lun,u               or in physical drive with sector number top 8 of 24 bits
                    sta       lun,u               and put it back in place
                    lda       PD.STP,y            get step and options
                    sta       control,u           to the packet
                    lda       PD.DRV,y            drive # from path descriptor
                    lsla                          byte to word offset
                    leax      offsd1,u            base of offsets
                    ldd       a,x                 get offset
                    addd      lun,u               add in top 16 of 24 bit sector number
                    std       lun,u
                    ldx       V.PORT,u

* wait for controller to finish any previous command
* needs x set to port base and y set to pd

set26               ldb       #m.busy             busy status bit
sel3                bitb      statpo,x            read status port

                    ifeq      HOG

                    bne       sel3                wait till not busy

                    else

                    beq       sel3b               skip ahead if not busy
                    lbsr      doslp
                    bra       sel3

                    endc

sel3b               lda       PD.DNS,y            controller number (lower 4 bits of PD.DNS var)
                    anda      #m.cont             isolate controller number
                    sta       datapo,x            latch the controller select
                    sta       selpo,x             generate a select strobe
sel4                bitb      statpo,x            read status port
                    beq       sel4                wait for controller to recognize select

                    ifne      DISTO
                    sta       selrst,x            reset select (scuzzie version)
                    endc

                    ttl       send command packet
* sends the command packet to the disk controller
* needs x set to V.PORT

taskout             pshs      y
                    leay      packet,u            address of scsi packet
                    ldb       #6                  number of bytes to transfer
task00              lda       #m.req
task0               bita      statpo,x
                    beq       task0

* ifeq H6309
*
* orcc #%01010000
* ldw #6
* tfm y+,x
* andcc #%10101111
*
* else

task1               lda       ,y+                 get a byte from the packet
                    sta       datapo,x            send it to the controller
                    decb                          count the bytes

                    ifeq      DBHS
                    bne       task00              need to check req again
                    else
                    bne       task1
                    endc

* endc

                    ifne      HOG
                    clr       plocked,u           clear critical section lock
                    endc

                    puls      y,pc

                    ifeq      CANFORM

                    ttl       format the drive

* format
*
* Called by setstat. Entire drive will be formatted.
*
FORMAT              ldd       R$U,X               Get Track Number
                    lbne      nofrmerr            If Not Zero We are Done
                    ldd       R$Y,X               get sides
                    tsta
                    lbne      nofrmerr

                    ifeq      MPAK
                    pshs      b
                    tst       mpslot,u            multipak in use? (1xxxxxxxb = no)
                    bmi       slotf2              hi bit set, skip change
                    ldb       >mpsel              get current value
                    stb       mpstor,u            save it
                    andb      #m.mpscs            clear scs bits
                    orb       mpslot,u            add in scs select
                    stb       >mpsel              put it to mpak
slotf2
                    puls      b
                    endc

                    tfr       D,X                 Set LSB's of Track # to Zero

                    lda       PD.ILV,y            get drive interleave
*sta >$ff68 DEBUG
                    sta       blocks,u            put into packet (in place of blocks, restored below)

* deal with the drive offset, needs to be zeroed for unit format
                    pshs      y
* nitros adj

                    ifeq      H6309
                    lda       PD.DRV+2,y
                    else
                    lda       PD.DRV,y
                    endc

                    lsla                          drive to index
                    leax      offsd1,u            offset table
                    stx       tempw1,u            save the offset location
                    ldy       a,x
                    sty       tempw2,u            save the offset value
                    ldy       #0
                    sty       a,x                 set the offset temporarily to 0
                    puls      y

                    ifne      HOG
format0             tst       plocked,u
                    beq       format1
                    lbsr      doslp
                    bra       format0
                    com       plocked,u
format1
                    endc

                    lda       #o.formt            Get Format Command
                    clrb                          sector high byte
                    ldx       #0                  sector low word
                    lbsr      setup

* restore the original offset

                    pshs      x
                    ldx       tempw1,u            offset loc
                    ldd       tempw2,u            offset value
                    std       ,x                  put it back in the table
                    puls      x

                    lda       #1
                    sta       blocks,u            put 1 back to blocks

                    ifeq      DISTO
format2             ldb       statpo,x            get status bits
                    andb      #m.nnc              strip floating bits
                    cmpb      #m.req+m.busy+m.cmd+m.in
                    beq       format2b
                    lbsr      doslp
                    bra       format2
format2b            lda       datapo,x            status data byte
format3             ldb       statpo,x            get status bits
                    andb      #m.nnc              strip floating bits
                    cmpb      #m.req+m.busy+m.msg+m.cmd+m.in
                    bne       format3

                    else

                    ldb       #m.req+m.busy+m.cmd+m.in
format2             cmpb      statpo,x            get status
                    beq       format2b
                    lbsr      doslp
                    bra       format2
format2b            lda       datapo,x            status data byte
                    ldb       #m.req+m.busy+m.msg+m.cmd+m.in
format3             cmpb      statpo,x
                    bne       format3             get term byte

                    endc

                    ldb       datapo,x            discard
                    anda      #m.error
                    beq       nofrmerr            format sucessful
                    comb                          indicate error
                    ldb       #E$Write
                    bra       formato

                    endc

nofrmerr            clrb
formato
                    ifeq      MPAK
                    pshs      a,cc
                    lda       mpstor,u
                    sta       >mpsel              restore old mpak slot value
                    puls      a,cc
                    endc

                    ifne      HOG
                    clr       plocked,u
                    endc

                    rts

SETSTA              ldx       PD.RGS,y            find the stacked values
                    cmpb      #SS.Reset
                    beq       nofrmerr

                    ifeq      CANFORM

                    cmpb      #SS.WTrk            is it the format command?
                    bne       noformat

* is it ok to format this drive?
                    lda       PD.DNS,y
                    anda      #m.format
                    lbne      format
noformat
                    endc

GETSTA              comb
                    ldb       #E$UnkSvc           unknown service request
                    rts

TERM                equ       nofrmerr

                    emod
endmod              equ       *
                    end
