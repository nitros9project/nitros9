* bootlink.asm, boot selection utility
* Copyright (C) 2012-2014  Gene Heskett
* License: GPLv2
* See bootlink.doc for more licensing information
*
* A utility to facilitate using different boot vdisk images on
* a hard drive as the next default vdisk to boot from.
*
* REQUIRES:
* HDB-DOS 1.1a or I assume newer.
* The boot sequence is this:
* load the boottrack from the default vdisk 128 image coded into
* HDB-DOS.
*
* That tracks boot module, if a boot from the hard drive module
* will then interogate LSN0 of the selected disk, and will
* then use that data to locate the selected OS9Boot file
* from anyplace on the disk, well beyond the basic partitions
* end address if it is one of the 256 HDB-DOS vdisks.
*
* The only reason to change this boottrack is if one wanted to
* change the rel module to change the default boot screen from
* what is being used in the default vdisk 128. I like rel_80
* myself.
*
* Getting LSN0 from that drive, reading DD.BT, and DD.SIZ, it knows
* where on the disks surface to get, and how much to get, to fetch
* the OS9Boot file from ANYPLACE on the hard drive.  This means
* that by re-writing the DD.BT and DD.SIZ values in the selected by
* the boot module drive, we can effectively do exactly the same as
* I believe that LINK.BAS is doing but which is hard to get to without
* doing a full reset into rsdos. Something I rarely do.
*
* The intention is to be able to do something like:
* >bootlink 129;reboot
* choose 1 or let it time out and it will reboot using the boottrack
* from HDB-DOS vdisk 128, but then get the OS9Boot file from vdisk 129
* instead of the default 128.  Repeat the selection of which OS9Boot
* for any HDB-DOS vdisk.
*
* Caveat: be sure there is an OS9Boot file on that vdisk, else you will
* need to find that LINK.BAS and rerun it to restore your boot drives
* LSN0 DD.BT and DD.SIZ to valid values.
*
* The code for bootlink follows:
* various bits of the code can be traced by setting the debug level
* IF the machine has a 6309 in it, I use those registers to mark where
* the dump came from.
* DEBUG set 1 traces the LSN0 file creation process for the boot device
* DEBUG set 2 traces the LSN0 file creation process for the stp selected vdisk
* DEBUG set 3 will trace the offset calcs
* DEBUG set 4 traces new boot address additions
* DEBUG set 5 traces LSN0 edits
* DEBUG set 6 traces the decimal or ascii to hex conversions
* DEBUG set 7 traces the math for the $276*HEXB function
* DEBUG set 8 will check last coded display lines exit
* Any non-zero traces entry state
DEBUG               set       0
                    ttl       bootlink - method of effecting reboots to different bootfiles
                    ifp1
                    use       os9.d
                    use       rbf.d
                    endc
tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       1
ed                  set       1
srchcli             set       8                   amount of cli to search
shdeflt             set       $80
MkUpper             set       $DF

                    mod       eom,name,tylg,atrv,start,msiz

name                fcs       /bootlink/
                    fcb       ed
* All internally used strings here
DNAME               fcc       '/DD@'
                    fdb       $0d
SHNAME              fcc       '/SH@'
                    fdb       $0d
SHDIR               fcc       '/sh'
                    fdb       $0d
SHMOD               fcc       'SH'
                    fdb       $0d
SHBoot              fcc       '/sh/OS9Boot'       have that file?
                    fdb       $0d
LSN0Sav             fcc       '/DD/SRC/bootlink.LSN0'
                    fdb       $0d
LSN0tar             fcc       '/DD/SRC/targetlink.LSN0'
                    fdb       $0d
bootmin             fcb       $60                 only check high byte
hextbll             fcb       $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
hextblh             fcb       $00,$10,$20,$30,$40,$50,$60,$70,$80,$90,$A0,$B0,$C0,$D0,$E0,$F0

vdpream             fcc       'next, will do the equ of '
vdmode$             fcc       'dmode'             a printable string
dmodpar             fcc       ' /sh stp=$'
dmodevd             fcc       '00'
                    fcb       $0a
dmodend             fcb       $0d

* all allocated memory here
DBUF1               rmb       256                 at 0,u drives base LSN0 when read in
DBUF2               rmb       256                 at 256,u drives target LSN0
CMDL                rmb       2                   READONLY pointer to command line args
OSID                rmb       2                   holds 1st two bytes of OS9Boot
HEXB                rmb       1                   scratchpad
STPHEX              rmb       3                   storage for $276*HEXB
BFADR               rmb       3                   size DD.BT
BFSIZ               rmb       2                   size DD.SIZ
NBFADR              rmb       3                   size new HDB-DOS DD.BT
NEWBTAD             rmb       3                   final addr move so 5 byte move works, is absolute addr
NBFSIZ              rmb       2                   size new DD.SIZ
PATHN               rmb       1                   pathnx I$Open returns
PATH2               rmb       1                   pathno to sh@
DPRTSZ              rmb       3                   size of device root part
OLDBTAD             rmb       3                   addr old boot file from LSN0 DD.BT
HEXASC              rmb       1                   controls treatment of input, dec or hex
DLRPTR              rmb       2                   save pointer to $ sign
ynumptr             rmb       2                   place to save x while getting input
stackp              rmb       2                   place to hold stack at launch
ParamD              rmb       1                   size of parameters passed at F$Fork that starts us
msiz                equ       .
* any other strings are defined within the code as needed
**********************************************
* We run everything from here
start               sts       stackp,u            re-init the sp for exits!
                    stx       CMDL,u              save for whatever ;)
                    stb       ParamD,u            assume never over 256 bytes!
                    sta       HEXASC,u            assume always 0 here
                    clra
                    clrb
                    std       DLRPTR,u            zero these
                    lda       ,x                  what char is x pointed at right now?
* Ok, we have an argument, handle it
whatgot             cmpa      #'$                 what sort of an argument do we have?
* is it a hex value, or a decimal, no leading $ sign?
                    bne       not$
                    lbsr      itshex
                    bra       GotHEX
not$                lbsr      numconv
GotHEX              lbsr      shomd               got it show it
                    clrb
                    pshs      u,y,x
                    lbsr      domode              Link and UnLink screw with lots of stuff
                    puls      u,y,x
                    lbcs      nodevic
                    clrb
                    lbsr      GetLSNs             works
                    lbcs      baddat
                    clrb
                    lbsr      GetDin
                    lbcs      baddat
                    clrb
                    lbsr      cklgimg
                    lbcs      baddat
                    clrb
                    lbsr      CalOfst
                    lbcs      baddat
                    clrb
                    lbsr      ShoRslt
                    clrb
                    bsr       Cmitit              actually do it!
                    lbra      end                 All done folks!

****SUBROUTINE****
Cmitit              leax      DBUF1,u
                    leax      DD.BT,u
                    leay      NEWBTAD,u
                    ldb       #5                  bytes to move
Comit               lda       ,y+
                    sta       ,x+
                    decb
                    bne       Comit
                    leax      DNAME,pcr           point at /sh@
                    lda       #WRITE.
                    os9       I$Open
                    ifeq      DEBUG-5
                    pshs      cc
                    lde       #'O
                    ldf       #'P
                    os9       F$RegDmp
                    puls      cc
                    endc
                    bcs       Comitnd
                    sta       PATHN,u
                    clrb
                    ldy       #256                one sector
                    leax      DBUF1,u
                    lda       PATHN,u
                    os9       I$Write             put the sector back
                    ifeq      DEBUG-5
                    pshs      cc
                    lde       #'W
                    ldf       #'R
                    os9       F$RegDmp
                    puls      cc
                    endc
                    bcs       Comitnd
                    lda       PATHN,u
                    os9       I$Close
                    ifeq      DEBUG-5
                    pshs      cc
                    lde       #'C
                    ldf       #'L
                    os9       F$RegDmp
                    puls      cc
                    endc
Comitnd             rts
****SUBROUTINE****
* we should have the HDBDOS disk number in HEXB now
* so show the equ dmode line but thats not how we'll do it
shomd               lda       HEXB,u
                    lbsr      hxb2asc
                    leax      dmodevd,pcr
                    std       ,x
                    leax      vdpream,pcr
                    lda       #1
                    ldy       #1+dmodend-vdpream
                    os9       I$Write             should show it on screen
                    clrb
                    rts

*****SUBROUTINE*****
* now, set to fork dmode but crashes above
domode              clrb                          clr any carry
                    leax      SHMOD,pcr           point at /sh\r string
                    lda       #$f1
                    pshs      u                   save it
                    os9       F$Link
                    ifeq      DEBUG-9
                    lde       #'F
                    ldf       #'L
                    pshs      cc
                    os9       F$RegDmp
                    puls      cc
                    endc

* U now points at Header absolute address, but may not exist!
                    lbcs      nodevic             and this didn't work!
* now, lets play here a bit
                    tfr       u,y                 so we can use it
                    puls      u                   which should clean the stack
                    lda       HEXB,u
                    sta       IT.STP,y            which should do it but screws the crc. do we care?
                    rts                           done here, works!

GetLSNs             lbsr      BaseLSN             Get LSN0 from /DD@
                    lbcs      end                 nothing on stack here
                    lbsr      SHLSN0              Get LSN0 from /sh@
                    lbcs      end                 nothing on stack
                    ifne      DEBUG               if no debug, don't create check files
                    lbsr      Creat1              make test files that can be dumped
                    lbcs      end                 nothing on stack if we are here
                    lbsr      Creat2              ditto
                    lbcs      end                 stack s/b ok
                    endc
                    rts

**********CalOfst*********************
* we have all the data, so we need to calculate
* the additional LSN offset for the HEXB (stp) value we should have
* this will be $276*HEXB, and will store the result in STPHEX,u
* First, clear var holder & make some space on stack
CalOfst             clra
                    sta       STPHEX,u
                    sta       STPHEX+1,u
                    sta       STPHEX+2,u
                    leas      -4,s
                    lda       HEXB,u
                    ldb       #$76
                    mul
                    std       2,s
                    lda       HEXB,u
                    ldb       #$02
                    mul
                    std       ,s
                    clrb
                    lda       1,s
                    addd      2,s
                    std       2,s
                    bcc       missinc
                    inc       ,s
missinc             lda       ,s
                    sta       1,s
                    ldd       2,s
                    addd      STPHEX+1,u
                    std       STPHEX+1,u
                    lda       1,s
                    adca      STPHEX,u
                    sta       STPHEX,u
                    leas      4,s                 restore stack
                    ifeq      DEBUG-3
                    ldd       HEXB,u
                    ldw       STPHEX+1,u
                    pshs      cc
                    os9       F$RegDmp
                    puls      cc
                    endc
* here we do straight additions with carry for 3 bytes
                    clra
                    ldb       DPRTSZ+2,u          get low byte of partition end
                    addb      STPHEX+2,u          add low byte of calculated vdisk
                    adca      #0                  handle carry if
                    addb      NBFADR+2,u
                    adca      #0                  handle any carry's
                    stb       NEWBTAD+2,u
                    tfr       a,b                 do 2nd byte of 3, carry added above, now in b
                    clra
                    addb      NBFADR+1,u          very slim chance of carry, but not 0
                    adca      #0                  transfer the carry to a
                    addb      STPHEX+1,u
                    adca      #0                  chance of carry, handle
                    addb      DPRTSZ+1,u
                    adca      #0                  chance of carry, handle
                    stb       NEWBTAD+1,u
                    tfr       a,b                 potential carry's in b now
                    clra
                    addb      NBFADR,u            add to potential carry
                    addb      STPHEX,u            astronomical chance of carry here
                    addb      DPRTSZ,u            or here, no place to put it anyway
                    stb       NEWBTAD,u
                    ifeq      DEBUG-4
                    ldw       NEWBTAD+1,u
                    pshs      cc
                    os9       F$RegDmp
                    puls      cc
                    endc
                    rts                           All done!!

*********SUBROUTINES***********
* support strings for ShoRslt

Shopart             fcc       'Disk has an os9 partition size of = $'
partsiz             fcc       '000000'
                    fdb       $0a0d               works
Shoddbt             fcc       'Original OS9Boot file location = $'
Oldd.bt             fcc       '000000'
                    fdb       $0a0d               works
Shorsiz             fcc       'Original OS9Boot file size is = $'
Oldbsiz             fcc       '0000'
                    fdb       $0a0d               works
Shonbad             fcc       'The new bootfile location in /sh is = $'
nblocat             fcc       '000000'
                    fdb       $0a0d               works
Shabslo             fcc       'This will be at actual $'
absolut             fcc       '000000'
                    fcc       ' sector on the drive'
                    fdb       $0a0d               works
Shnbsiz             fcc       'The new OS9Boot file size is = $'
nbsize              fcc       '0000'
                    fdb       $0a0d
Shhdbvd             fcc       'Which is located in HDB-DOS disk $'
Shdbdos             fcc       '00'
                    fdb       $0a0d
Sendstr             equ       *                   need ending data marker
ShoRslt             leax      partsiz,pcr
                    lda       DPRTSZ,u
                    lbsr      hxb2asc
                    std       ,x++                first 2 ascii digits
                    lda       DPRTSZ+1,u
                    lbsr      hxb2asc
                    std       ,x++                next 2 ascii digits
                    lda       DPRTSZ+2,u
                    lbsr      hxb2asc
                    std       ,x                  last 2 ascii digits
                    leax      Shopart,pcr         now print it
                    ldy       #Shoddbt-Shopart
                    lda       #1
                    os9       I$Write
                    clrb
ShDD.BT             leax      Oldd.bt,pcr
                    lda       OLDBTAD,u
                    lbsr      hxb2asc
                    std       ,x++
                    lda       OLDBTAD+1,u
                    lbsr      hxb2asc
                    std       ,x++
                    lda       OLDBTAD+2,u
                    lbsr      hxb2asc
                    std       ,x
                    leax      Shoddbt,pcr
                    ldy       #Shorsiz-Shoddbt
                    lda       #1
                    os9       I$Write
                    clrb
oldbtsz             leax      Oldbsiz,pcr
                    lda       BFSIZ,u
                    lbsr      hxb2asc
                    std       ,x++
                    lda       BFSIZ+1,u
                    lbsr      hxb2asc
                    std       ,x
                    leax      Shorsiz,pcr
                    ldy       #Shonbad-Shorsiz
                    lda       #1                  stdout
                    os9       I$Write
                    clrb
                    leax      nblocat,pcr
                    lda       NBFADR,u
                    lbsr      hxb2asc
                    std       ,x++
                    lda       NBFADR+1,u
                    lbsr      hxb2asc
                    std       ,x++
                    lda       NBFADR+2,u
                    lbsr      hxb2asc
                    std       ,x                  last byte
                    leax      Shonbad,pcr
                    ldy       #Shabslo-Shonbad
                    lda       #1
                    os9       I$Write
                    clrb
* now show its size
                    leax      nbsize,pcr
                    lda       NBFSIZ,u
                    lbsr      hxb2asc
                    std       ,x++
                    lda       NBFSIZ+1,u
                    lbsr      hxb2asc
                    std       ,x
                    leax      Shnbsiz,pcr
                    ldy       #Shhdbvd-Shnbsiz
                    lda       #1
                    os9       I$Write
                    clrb
abslutA             leax      absolut,pcr
                    lda       NEWBTAD,u
                    lbsr      hxb2asc
                    std       ,x++
                    lda       NEWBTAD+1,u
                    lbsr      hxb2asc
                    std       ,x++
                    lda       NEWBTAD+2,u
                    lbsr      hxb2asc
                    std       ,x
                    leax      Shabslo,pcr
                    ldy       #Shnbsiz-Shabslo
                    lda       #1
                    os9       I$Write
                    clrb
                    leax      Shdbdos,pcr
                    lda       HEXB,u
                    lbsr      hxb2asc
                    std       ,x
                    leax      Shhdbvd,pcr
                    ldy       #Sendstr-Shhdbvd
                    lda       #1
                    os9       I$Write
                    clrb
ShoEnd              rts

* Get the LSN0 data from /DD
* arrive here with 1 bsr on stack
BaseLSN             lda       #READ.              Read mode
                    leax      DNAME,pcr           point at device name
                    os9       I$Open              open it raw
                    bcs       Basend              report the error
                    sta       PATHN,u             Save path#
                    leax      DBUF1,u             point x at DBUF,u
                    ldy       #256                size of buffer
                    lda       PATHN,u             get path# back in case regs.a wrong
                    os9       I$Read              and read 256 byte of /dd@ LSN0
                    bcs       Basend              report the error
* got the sector, save the interesting data
                    pshs      x
                    leax      DD.BT,x
                    ifeq      DEBUG-1
                    pshs      cc
                    lde       #'O
                    ldf       #'A
                    os9       F$RegDmp            look at x
                    puls      cc
                    endc
                    ldd       ,x++
                    std       OLDBTAD,u
                    ldb       ,x+
                    stb       OLDBTAD+2,u
                    ldd       ,x
                    std       BFSIZ,u
                    ldd       DBUF1,u             get partition size
                    std       DPRTSZ,u
                    lda       DBUF1+2,u           last byte
                    sta       DPRTSZ+2,u
                    ifeq      DEBUG-1
                    ldf       #'B
                    pshs      cc
                    os9       F$RegDmp
                    puls      cc
                    endc
                    puls      x                   clean up the stack & restore x
                    lda       PATHN,u             restore regs.a in case
                    os9       I$Close             and close path to /dd@
                    bcs       Basend
                    clrb
Basend              rts

******************************************
* Get the LSN0 data from /sh@
* should arrive here with 1 bsr on stack
SHLSN0              lda       #READ.              read mode
                    leax      SHNAME,pcr
                    os9       I$Open              open it raw
                    bcs       SHCKend             report the error
                    sta       PATH2,u             save the path number
                    leax      DBUF2,u
                    ldy       #256
                    lda       PATH2,u             get our pathno back
                    os9       I$Read              and read the 256 bytes of /sh@
                    bcs       SHCKend             report the error
                    pshs      x
                    leax      DBUF2,u             get the location & size of this bootfile
                    leax      DD.BT,x
                    ldd       ,x++
                    std       NBFADR,u
                    lda       ,x+
                    sta       NBFADR+2,u
                    ldd       ,x
                    std       NBFSIZ,u
                    ifeq      DEBUG-1
                    pshs      cc
                    lde       #'2
                    ldf       #'A
                    os9       F$RegDmp
                    puls      cc
                    endc
                    puls      x
                    lda       PATH2,u
                    os9       I$Close
* we have added nothing to the stack
SHCKend             rts                           if err, report

*****************************************
* now create trace dumps
* this could be removed in final
* should arrive here with 1 bsr on stack
Creat1              leax      LSN0Sav,pcr         point x at filename to save LSN0 in
                    ldb       #UPDAT.+PREAD.+PWRIT. global read+write attr's
                    lda       #UPDAT.+PREAD.+PWRIT. real attr's go in regs.b dummy
                    os9       I$Create            and create it, s/b empty file
                    bcs       Cr1fix
cont1               sta       PATHN,u             save the path# returned
                    lda       PATHN,u
                    leax      DBUF1,u             point x at buffer we read from /dd@
                    ldy       #256                amount to write
                    os9       I$Write             and write it to the file
                    bcs       Cr1end
                    lda       PATHN,u             it could be played with, get it back
                    clrb                          just in case
                    os9       I$Close
                    clrb
Cr1end              rts                           should clean up the bsr on stack

Cr1fix              leax      LSN0Sav,pcr
                    os9       I$Delete
                    bcs       Cr1end              can't fix, some other error
                    bra       Creat1              go back and try again

Creat2              equ       *                   lets go make the 2nd file
                    ifeq      DEBUG-2
* Tally we got here
                    lde       #'C
                    ldf       #'2
                    pshs      cc
                    os9       F$RegDmp
                    puls      cc
                    endc
                    leax      LSN0tar,pcr
                    lda       #UPDAT.+PREAD.+PWRIT.
                    ldb       #UPDAT.+PREAD.+PWRIT.
                    os9       I$Create            s/b empty file
                    bcs       Cr2fix
cont2               sta       PATH2,u
                    leax      DBUF2,u
                    ldy       #256
                    os9       I$Write
                    bcs       Cr2end
                    lda       PATH2,u
                    clrb
                    os9       I$Close
                    clrb                          successful, no?
Cr2end              rts                           should clean stack

Cr2fix              leax      LSN0tar,pcr
                    clrb                          clr error?
                    os9       I$Delete
                    bcs       Cr2end              some other error, report
                    bra       Creat2              else go back and try again
* eventually these fixes need to check the return err
* and if not 218, bail plumb out
******************************************
* check legal image, do we have an os9
* spec LSN0 in DBUF2,u?
* should arrive here with 1 bsr on stack
cklgimg             leax      DBUF2,u
                    clrb                          our error counter
                    lda       ,x+                 sets z flag if $00
                    ifeq      DEBUG-9
                    tfr       pc,w
                    pshs      cc
                    os9       F$RegDmp
                    puls      cc
                    endc
                    beq       badbuf1
                    incb
badbuf1             lda       ,x+                 get next byte, better be a $02
                    cmpa      #$02
                    ifeq      DEBUG-9
                    pshs      cc
                    tfr       pc,w
                    os9       F$RegDmp
                    puls      cc
                    endc
                    beq       badbuf2
                    incb
badbuf2             lda       ,x+                 better be a $76
                    cmpa      #$76
                    ifeq      DEBUG-9
                    pshs      cc
                    tfr       pc,w
                    os9       F$RegDmp
                    puls      cc
                    endc
                    beq       badbuf3
                    incb
badbuf3             leax      DBUF2,u             reset x
                    leax      DD.BT,x             point x at DD.BT
                    lda       ,x+                 first byte of DD.BT
                    beq       bt1
                    incb
bt1                 lda       ,x+                 2nd byte of DD.BT s/b a $00 too
                    beq       bt2
                    incb
bt2                 lda       ,x+                 last byte of DD.BT s/b non-zero
                    bne       bt3                 got something, skip the incb
                    incb
bt3                 tstb                          non zero? error!
                    ifeq      DEBUG-9
                    pshs      cc
                    tfr       pc,w
                    os9       F$RegDmp
                    puls      cc
                    endc
                    lbne      baddat
* got this far, what size is it?
                    lda       ,x+                 get 1st byte of DD.BSZ
* now here, this is subjective, I've not seen a boot file
* that wasn't at least #$5000 long
                    cmpa      bootmin,pcr         abs minn length IMO
                    ifeq      DEBUG-9
                    pshs      cc
                    tfr       pc,w
                    os9       F$RegDmp
                    puls      cc
                    endc
                    bcc       noBinc
                    incb
* no illegal value to 2nd byte, don't bother

*********************************
* now check the DD.DIR & regs.b is still $00 if got here
noBinc              leax      DBUF2,u             point x at sh's buffer
                    leax      DD.DIR,x            now point at 1st byte of DD.dir
                    lda       ,x+                 /sb $00, no floppy can be non-zero
                    beq       dir1
                    incb                          opps, really bad data
dir1                lda       ,x+                 2nd byte, for floppy s/b $00 if mb made the disk
                    beq       dir2                is legal
                    incb                          not zero, tally as bad
dir2                lda       ,x+                 get 3rd byte, s/b a $02
                    cmpa      #$02                as it should be for a valid floppy
                    beq       dir3
                    incb                          not a $02, tally it as bad
dir3                tstb
                    ifeq      DEBUG-9
                    pshs      cc
                    tfr       pc,w
                    os9       F$RegDmp
                    puls      cc
                    endc
                    beq       getdrsh
                    incb
getdrsh             lda       #READ.+DIR.         open for read only
                    leax      SHDIR,pcr
                    os9       I$Open              see if is has a dir
                    ifeq      DEBUG-9
                    pshs      cc
                    tfr       pc,w
                    os9       F$RegDmp
                    puls      cc
                    endc
                    bcc       scapinc
                    incb
scapinc             os9       I$Close             clean up the path table
************************************************
* got here ok, can we open the OS9Boot file?
chkboot             leax      SHBoot,pcr
                    lda       #READ.
                    os9       I$Open
                    ifeq      DEBUG-9
                    pshs      cc
                    tfr       pc,w
                    os9       F$RegDmp
                    puls      cc
                    endc
                    bcc       scipinc
                    incb
scipinc             sta       PATH2,u             file must exist
                    leax      OSID,u
                    ldy       #0002               bytes to read
                    os9       I$Read
                    ifeq      DEBUG-9
                    pshs      cc
                    tfr       pc,w
                    os9       F$RegDmp
                    puls      cc
                    endc
                    bcc       skpinc
                    incb
skpinc              pshs      d
                    ldd       OSID,u
                    cmpd      #$87CD              header bytes?
                    ifeq      DEBUG-9
                    pshs      cc
                    lde       #'B
                    ldf       #'F
                    os9       F$RegDmp
                    puls      cc
                    endc
                    puls      d
                    beq       closeup
                    incb
closeup             lda       PATH2,u
                    os9       I$Close             clean up path table
* image looks good, we even have an OS9Boot file
* that looks good, so
                    tstb
                    lbne      baddat
                    clrb
BadImg              rts                           We've weeded it out to about a -8.0000-21 chance of bad=good

************************************
* got data, copy goodies to work buffers
GetDin              lda       ,u                  get first byte of part size
                    sta       DPRTSZ,u
                    ldd       1,u                 get other 2 bytes
                    std       DPRTSZ+1,u          Should now have devices size
                    ldd       DD.SIZ,u            current os9boot files size
                    std       BFSIZ,u             and save it
                    ldd       DD.BT,u             get 2 byte of its location
                    std       BFADR,u             and save that for later
                    lda       DD.BT+2,u           get last byte of addr
                    sta       BFADR+2,u           and save it
                    rts

************subroutines**************
* hxb2asc
* this routine was written up in the
* Rainbow (11/92) by Tim Kientzle.
* it will convert the value passed
* in the A register to a pair of
* ascii characters in A:B which
* are the directly printable ASCII
* representations of the original
* contents of regs.a. Load regs.A
* with byte of source number, call,
* store A nd B in order in the
* printable string on return.

hxb2asc             tfr       a,b                 Make copy of a in b
                    anda      #$0f                mask off lower digit
                    adda      #$90                generates carry if a>9
                    daa                           in this operation
                    adca      #$40                bring in the carry
                    daa                           make final character
                    exg       a,b                 stash that in b, get a back
                    lsra                          getting high nibble
                    lsra                          into position to
                    lsra                          convert it
                    lsra
                    adda      #$90                and repeat for high nibble
                    daa                           and generate carry from a>9
                    adca      #$40
                    daa
                    rts                           returns with a:b=two hexidecimal characters

*********************************************
* a2h make 1 hex byte from two ascii chars
a2h                 ldx       CMDL,u              get arg pointer back
                    lda       ,x+                 get the left hex char
                    stx       CMDL,u              save for next byte
                    suba      #'0                 reduce for decimal entries
                    cmpa      #$0A
                    blo       znine               its 0-9
                    anda      #MkUpper
                    suba      #$07                else sub 7 more for A-F values
znine               pshs      x
                    leax      hextblh,pcr
                    ldb       a,x
                    stb       HEXB,u              write high nibble
                    puls      x                   restore it
                    ifeq      DEBUG-6
                    lde       #'a
                    ldf       #'h
                    pshs      cc
                    os9       F$RegDmp
                    puls      cc
                    endc
* now check, is there a high nibble?
                    lda       ,x                  x already inc'd
                    suba      #'0                 reduce to decimal
                    cmpa      #$0A
                    blo       ninez
                    anda      #MkUpper
                    suba      #$07                else sub 7 more for A-F inputs
ninez               pshs      x
                    leax      hextbll,pcr
                    ldb       a,x
                    puls      x
                    orb       HEXB,u
nineex              stb       HEXB,u
                    ifeq      DEBUG-6
                    lde       #'A
                    ldf       #'H
                    pshs      cc
                    os9       F$RegDmp
                    puls      cc
                    endc
                    rts

itshex              leax      1,x                 throw away the $ sign
                    ifeq      DEBUG-6
                    pshs      cc
                    lde       #'n
                    ldf       #'c
                    os9       F$RegDmp
                    puls      cc
                    endc
                    stx       CMDL,u              for a2h use
                    lbsr      a2h                 and convert to a hex byte
                    rts

***********************************
* we supposedly have found the cr without unzeroing HEXASC,u
* so we use this conversion.
numconv             ldx       CMDL,u              s/b first char of arg value
* find the end
                    clrb                          find out how many chars we have
findeod             lda       ,x+
                    ifeq      DEBUG-6
                    lde       #'f
                    ldf       #'s
                    pshs      cc
                    os9       F$RegDmp
                    puls      cc
                    endc
                    incb
                    cmpa      #$0D
                    bne       findeod
* we have the cr, so
foundcr             leax      -3,x                back to data?
                    ldd       ,x                  get 2 bytes of decimal cli
                    ifeq      DEBUG-6
                    lde       #'c
                    ldf       #'r                 found cr
                    pshs      cc
                    os9       F$RegDmp            lets see the data in A:B
                    puls      cc
                    endc
decmode             cmpa      #'9                 make a hex digit out of regs.a
                    ble       gigo1
                    lda       #$30                load a zero
gigo1               cmpa      #'0
                    bhi       gigo2
                    lda       #$30                load a zero
gigo2               subb      #'0                 leave a hex nibble
                    suba      #'0                 leave a hex nibble
                    blo       add00               garbage, go
                    cmpa      #'9
                    bhi       add00               garbage, go
                    ifeq      DEBUG-6
                    lde       #'d
                    ldf       #'r
                    pshs      cc
                    os9       F$RegDmp            check A[2]:B[8] again good
                    puls      cc
                    endc
                    stb       HEXB,u              save lsnibble
                    ldb       #$0A
                    mul                           multiply a:b
                    daa
                    addb      HEXB,u
                    stb       HEXB,u
* now lets see what we have in B
                    ifeq      DEBUG-6
                    ldf       #'1                 low nibble in B?
                    pshs      cc
                    os9       F$RegDmp            is $10 for a 28 input
                    puls      cc
                    endc
* but we're not done, need to handle 1st digit if
                    leax      -1,x
                    lda       ,x
                    ifeq      DEBUG-6
                    lde       #'d
                    ldf       #'2
                    pshs      cc
                    os9       F$RegDmp            wft am I getting?
                    puls      cc
                    endc
                    cmpa      #'2
                    beq       add200
                    cmpa      #'1                 can we get garbage here?  yes
                    beq       add100              else add 200
                    bra       add00               else garbage, add nothing
add200              addb      #$64
add100              addb      #$64
add00               stb       HEXB,u
                    ifeq      DEBUG-6
                    lde       #'d
                    ldf       #'e
                    pshs      cc
                    os9       F$RegDmp            show HEXB in b
                    puls      cc
                    endc
                    clrb                          kill false error
numdone             rts

****************************************************
* exit messages
FMTSTR              fcc       'Something is wrong, either with the hdb-dos disk chosen'
                    fdb       $0a0d
                    fcc       '    and set into the /sh descriptor'
                    fdb       $0a0d
                    fcc       '    or the format of the argument.'
                    fdb       $0a0d
                    fcc       /bootlink needs a fixed size vdisk number argument/
                    fdb       $0a0d
                    fcc       /in a 3 digit format. If first char is a $ sign,/
                    fdb       $0a0d
                    fcc       /the next 2 nums are hex, else all 3 are decimal./
                    fdb       $0a0d
                    fcc       /example: $80 or 128. Result will be used to control/
                    fdb       $0a0d
                    fcc       'as in "dmode /sh stp=hex of above number.'
                    fdb       $0a0d
ENDSTR              bra       forker1
ndevmsg             fcc       'Named device /sh is not in memory.'
enddvmg             fdb       $0a0d
nodevic             leax      ndevmsg,pcr
                    ldy       #enddvmg-ndevmsg
                    lda       #1                  stdout
                    os9       I$Write
                    bra       forker1
numdun              equ       *
baddat              leax      FMTSTR,pcr
                    ldy       #ENDSTR-FMTSTR
                    lda       #1                  stdout
                    os9       I$Write
forker1             clrb                          we just reported the error folks
* arriving here with possible bsr on stack - restore
* but make sure U is correct, a Link call screws it!
* and this sp reload with U fucked is my crash just like
* little green apples. GIGO of the hidden  sort. So...
                    ldu       #$0000              this seems to be where we started
                    lds       stackp,u            clear it for exit, leave b, cc as is
bigdec              equ       *
end                 os9       F$Exit
                    emod
eom                 equ       *

