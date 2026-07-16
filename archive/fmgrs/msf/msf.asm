*********************************************************************
* MSF (msf.v2.3.a)
*
* copyright 1988 by
*           Clearbrook Software Group Inc.
*           Box 8000-499
*           Abbotsford, B.C.
*           CANADA  V2S 6H1
*           (604)853-9118
*
* author: Paul Kehler
*
* MSF source and object code and any product derived from the
*  MSF source code is a copyrighted product of Clearbrook
*  Software Group Inc. It may be used by a licensed user on one
*  computer system and may not be sold or given away except as
*  authorized by Clearbrook Software Group Inc.
*
* Oct 15, 1988 - added check for busy before FAT checked
*
* MSDOS file manager for OS9 Level 2 with SDisk3 disk driver
*********************************************************************

                    ifp1
                    use       defsfile
                    endc

type                set       FlMgr+Objct
revs                set       Reent+1

edition             set       $23                 version 2.3

                    mod       modlen,modname,type,revs,modexec,modmem

modname             fcs       'MSF'
                    fcb       edition


* information determined from the FAT ID byte

*** Revision 2.1 to support 640 and 720k disk

*** Revision 2.2 to support 1.2meg floppies
* and follow the MSDOS v2+ standard for the
* information sector and FAT ID byte.

* double sided, 8 sectors/track
doubles8
                    fcb       $00,$02             512 bytes/sector
                    fcb       $02                 sectors/cluster
                    fcb       $01,$00             reserved sectors
                    fcb       $02                 number of FATs
                    fcb       $70,$00             112 root directory entries
                    fcb       $80,$02             640 sectors
                    fcb       $FF                 ID byte
                    fcb       $01,$00             1 sector/FAT
                    fcb       $08,$00             8 sectors/track
                    fcb       $02,$00             2 heads
                    fcb       $00,$00             no hidden sectors

* single sided, 8 sectors/track
singles8
                    fcb       $00,$02             512 bytes/sector
                    fcb       $01                 sectors/cluster
                    fcb       $01,$00             reserved sectors
                    fcb       $02                 number of FATs
                    fcb       $40,$00             64 root directory entries
                    fcb       $40,$01             320 sectors
                    fcb       $FE                 ID byte
                    fcb       $01,$00             1 sector/FAT
                    fcb       $08,$00             8 sectors/track
                    fcb       $01,$00             1 head
                    fcb       $00,$00             no hidden sectors

* double sided, 9 sectors/track
doubles9
                    fcb       $00,$02             512 bytes/sector
                    fcb       $02                 sectors/cluster
                    fcb       $01,$00             reserved sectors
                    fcb       $02                 number of FATs
                    fcb       $70,$00             112 root directory entries
                    fcb       $D0,$02             720 sectors
                    fcb       $FD                 ID byte
                    fcb       $02,$00             2 sector/FAT
                    fcb       $09,$00             9 sectors/track
                    fcb       $02,$00             2 heads
                    fcb       $00,$00             no hidden sectors

* single sided, 9 sectors/track
singles9
                    fcb       $00,$02             512 bytes/sector
                    fcb       $01                 sectors/cluster
                    fcb       $01,$00             reserved sectors
                    fcb       $02                 number of FATs
                    fcb       $40,$00             64 root directory entries
                    fcb       $68,$01             360 sectors
                    fcb       $FC                 ID byte
                    fcb       $02,$00             2 sector/FAT
                    fcb       $09,$00             9 sectors/track
                    fcb       $01,$00             1 head
                    fcb       $00,$00             no hidden sectors

*********************************
* Subroutine: expchn
*
* function - add a cluster to a file chain
*
* On entry:
*  Y points to path descriptor
*  D is number of last cluster in file
*
* On exit:
*  D is number of added cluster
*        or
*  Carry set and error code in B

expchn              ldx       msp.dtb,y
                    ldx       V.FAT,x             point to FAT

*********************************
* Subroutine: expchain
*
* function - add a cluster to a file chain
*
* On entry:
*  X points to FAT
*  D is number of last cluster in file ($FFF if none)
*
* On exit:
*  D is number of added cluster
*        or
*  Carry set and error code in B

expchain            pshs      d,u
                    lbsr      findhole            find first available sector
                    beq       expbad              ..media full
                    tfr       d,u                 save cluster number of hole
                    ldd       ,s++                get current last cluster
                    beq       expch5              ..this is first
                    cmpd      #$FF8
                    bhs       expch5
                    bsr       updFAT              make it the second last one
expch5              tfr       u,d                 get number of hole
                    ldu       #$FFF
                    bsr       updFAT              make it the last cluster in file
                    puls      u,pc                return last cluster number in D

expbad              leas      4,s
                    comb                          set carry
                    ldb       #E$Full
                    rts                           return carry set and media full


*******************************************
* Subroutine: delchain
*
* function - delete a file chain from the FAT
*
* On entry:
*  X points to FAT
*  D is first cluster in file
*
* On exit:
*  D==0 if error

delchain            pshs      d,x,u
                    ldu       #0
                    bra       delch2
delch1              bsr       findnext            find the next cluster in the chain
                    std       2,s                 save it
                    ldd       ,s                  get previous cluster number
                    bsr       updFAT              mark it as unused
                    ldd       2,s                 get current cluster
                    std       ,s                  make it the previous
                    beq       delerror            ..bad FAT
delch2              cmpd      #$FF8               end of file?
                    blo       delch1              ..no, remove another cluster
delerror            ldd       ,s
                    leas      4,s
                    puls      u,pc


**************************************************
* Subroutine: updFAT
*
* function - update the FAT
*
* On entry:
*  X points to FAT
*  D cluster to update
*  U next cluster to cluster D
*     U==$FFF if D is last cluster in file
*     U==0 if D is an unused cluster
*
* On exit:
*  all registers unchanged

updFAT              pshs      d,x,u
                    lslb
                    rola
                    addd      ,s
                    lsra
                    rorb                          offset in FAT=cluster# * 1.5
                    leax      d,x                 point to FAT entry
                    ldd       ,x                  get current value in FAT
                    bcs       updodd              ..nomalize for odd cluster number
* 12bit value is put in fat in the following order
* nibble1, nibble0, neighbour, nibble2
                    andb      #$F0                keep neighbour nibble
                    pshs      b
                    ldd       5,s                 get new value
                    anda      #$F                 isolate most significant nibble
                    ora       ,s+                 combine with neighbouring nibble
                    sta       1,x
                    stb       ,x                  put in second and third nibbles
                    bra       updend

updodd              anda      #$F                 keep neighbour nibble
                    pshs      a
                    ldd       5,s                 get new value
                    lsra
                    rorb
                    rora
                    rorb
                    rora
                    rorb
                    rora
                    rorb
                    rora                          rearrange the word nibble0, neighbour, nibble2, nibble1
                    ora       ,s+                 combine with neighbour
                    std       ,x                  and put it in FAT
updend              lda       #1
                    ldx       msp.dir,y
                    sta       dir.stat,x          set dir.stat to update FAT
                    puls      d,x,u,pc


********************************************
* Subroutine: findnext
*
* function - find the next cluster in a chain
*
* On entry:
*  X points to FAT
*  D current cluster number
*
* On exit:
*  D is next cluster number

findnext            pshs      d
                    lslb
                    rola
                    addd      ,s++
                    lsra
                    rorb                          offset=cluster*1.5 /carry set if cluster is odd
                    ldd       d,x                 get mixed up cluster #
                    exg       a,b
                    bcs       oddcl               ..unjumble odd cluster
                    anda      #$F                 normalize next cluster # for an even cluster
                    rts
oddcl               lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    rts


**********************************************
* Subroutine: findhole
*
* function - find an unused cluster
*
* On entry:
*  Y points to path descriptor
*
* On exit:
*  D - first unused cluster or 0 if media full
*  X - points to FAT

findhole            ldx       msp.dtb,y
                    ldx       V.BPB,x             point to disk info
                    ldd       ID.clus,x           get number of clusters
                    ldx       msp.dtb,y
                    ldx       V.FAT,x             point to file allocation table
findh02             pshs      d
                    ldd       #2                  first usable cluster
                    pshs      d
findh1              bsr       findnext            get next cluster
                    std       -2,s                is there one?
                    beq       holefnd             ..no, its unused
                    ldd       ,s
                    addd      #1
                    std       ,s
                    cmpd      2,s                 end of FAT?
                    bne       findh1              ..no, check it out
                    clra
                    clrb
                    std       ,s
holefnd             ldd       ,s++                return cluster # in D
                    leas      2,s
                    rts

*************************************************
* Subroutine: rootdat
*
* function - return info about size and location
*  of root directory.
*
* On entry:
*   Y points to path descriptor
*
* On exit:
*  A is cluster size
*  B is size of directory in sectors
*  U is location of directory (logical sector)

rootdat             pshs      x
                    ldx       msp.dtb,y
                    ldx       V.BPB,x             point to info
                    lda       ID.spf,x            get sectors/fat
                    ldb       ID.FATs,x           get number of FATs
                    mul
                    addb      ID.res,x            add reserved sectors
                    tfr       d,u
                    ldb       ID.BPS+1,x          get MSB of sector size
                    pshs      b
                    ldd       ID.RDE,x            get root directory entries
                    exg       a,b
                    lsra
                    rorb
                    lsra
                    rorb
rootd5              lsra
                    rorb
                    lsr       ,s
                    bne       rootd5              calculate number of directory sectors
                    puls      a
                    lda       ID.SPA,x            get sectors/cluster
                    puls      x,pc


*************************************************
* Subroutine: sepecl
*
* function - return sectors per cluster
*
* On entry:
*   Y points to path descriptor
*
* On exit:
*   A - number of sectors per cluster
*
sepecl              pshs      x
                    ldx       msp.dtb,y
                    ldx       V.BPB,x             point to disk info
                    lda       ID.SPA,x            get Sectors Per Allocation unit
                    puls      x,pc


*************************************************
* Subroutine: secsiz
*
* function - return sector size
*
* On entry:
*   Y points to path descriptor
*
* On exit:
*   D - sector size
*
secsiz              pshs      x
                    ldx       msp.dtb,y
                    ldx       V.BPB,x             point to disk info
                    ldd       ID.BPS,x            get Sector size
                    exg       a,b                 convert to Motorola format
                    puls      x,pc


*************************************************
* Subroutine: findfile
*
* function - find a file in the directory
*
* On entry:
*   Y points to path descriptor
*
* On exit:
*  Carry set if error (error code in B)
*  X points to directory entry if file found

findf91             rts

* link path into list
findfile            ldx       msp.dev,y
                    ldx       V$STAT,x            point to device static storage
                    ldb       PD.DRV,y            get drive number
                    lda       #DRVMEM
                    mul
                    leax      d,x
                    leax      DRVBEG2,x
                    stx       msp.dtb,y           save address of drive table
                    inc       V.CNT,x             path count
open001             ldu       <D.MSF
                    beq       open1
                    sty       msp.prev,u
                    stu       msp.next,y
open1               sty       <D.MSF
                    tfr       Y,U
                    ldx       <D.PthDBT
                    os9       F$All64             get 64 bytes of storage
                    bcs       findf91             ..return error
                    exg       Y,U
                    stu       msp.dir,y           place to store directory entry
                    clra
                    clrb
                    std       dir.msd+msd.strt,u  mark file as root directory
                    std       dir.msd+msd.size+2,u
                    ldx       <D.Proc             point to user process
                    ldb       P$Task,x            get DAT task number
                    ldx       PD.RGS,y            point to stacked parameters
                    ldx       R$X,x               point to file name
                    pshs      b,x,y               save registers
                    leas      -4,s                save temporary space
                    clr       1,s                 directory mode
                    inc       1,s
                    os9       F$LDABX             get first character of path list
                    sta       ,s
                    cmpa      #'/                 complete path list?
                    beq       findf1              ..yes
                    cmpa      #'@                 entire disk?
                    lbeq      findf201            ..yes
                    bsr       getrdy              get ready to access disk
                    lbcs      findf24
                    lbsr      setdir              select current default directory
                    lbcs      findf24             ..return error
                    ldb       4,s                 recover task number
                    lda       ,s
                    lbra      findf20

* Read the FAT if required
* return:
*   carry set and error in B
*   NE if buffer already set up
getFAT              pshs      x,u
*** rev 2.3
                    ldu       PD.DEV,y
                    ldu       V$STAT,u            point to static storage
getFAT0             tst       V.BUSY,u            is driver busy?
                    beq       getFAT1             ..no
                    ldx       #1
                    os9       F$SLEEP             sleep until ready
                    bra       getFAT0
getFAT1
***
                    ldu       msp.dtb,y
                    clrb                          clear carry
                    ldd       V.FAT,u             has FAT been read?
                    bne       open012             ..yes
open01              lbsr      readFAT             read the file allocation table
                    bcs       open013
open012             ldd       PD.BUF,y            is buffer already allocated?
                    bne       open013             ..yes
                    lbsr      secsiz              get sector size
                    os9       F$SRQMEM            request memory
                    bcs       open013             ..return error
                    stu       PD.BUF,y
                    clrb
open013             puls      x,u,pc

* read the file allocation table if needed
*  and setup the root directory
getrdy              bsr       getFAT
                    bcs       getrdy9
                    lbsr      rootdat             get root information
                    lbsr      setsec
                    ldu       msp.dir,y
                    pshs      x
                    ldx       msp.dtb,y
                    ldx       V.BPB,x             point to info
                    ldd       ID.RDE,x            get root directory entries
                    puls      x
                    exg       a,b
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola                          root directory entries * 16
                    exg       a,b
                    std       dir.msd+msd.size,u  set size of root directory (bytes)
                    ldb       #attr.DR
                    stb       dir.msd+msd.attr,u  set directory attribute
                    ldd       #1
                    std       msp.pos+1,y
getrdy9             rts

findf1              pshs      y
                    os9       F$PrsNam            skip device name
                    tfr       y,x
                    puls      y
                    anda      #$7f
                    cmpa      #'/
                    beq       findf19
                    cmpa      #'@                 is it entire disk?
                    beq       findf201            ..yes
                    bsr       getrdy              get ready for directory search
                    lbcs      findf24             ..report error
                    bra       findf23             5 ..end of path list
findf19             bsr       getrdy              get ready for directory search
                    lbcs      findf24             ..report error
                    ldb       4,s                 recover task number
findf2              leax      1,x                 point to next character
                    os9       F$LDABX             get next character
findf20             anda      #$7f                remove terminator bit
                    cmpa      #'.                 subdirectory?
                    beq       findf21             ..yes
                    cmpa      #'@                 entire disk
                    bne       findf26             ..no
findf201            lbsr      setdisk             open entire disk
                    leax      1,x
                    clr       1,s                 ..not directory
                    inc       msp.wrt,y           don't allow writing to this file
                    bra       findf23
findf21             leax      1,x
                    os9       F$LDABX             get next char
                    sta       ,s
                    anda      #$7f
                    cmpa      #'@                 entire disk?
                    beq       findf201            ..yes
                    cmpa      #'.                 parent directory?
                    bne       findf22             ..no
                    lbsr      setparnt
                    bcs       findf24             ..report error
                    ldb       4,s                 restore task number
                    bra       findf21             check for more
findf22             tst       1,s                 directory mode?
                    beq       findf225            ..no
                    cmpa      #'/                 end of name?
                    beq       findf2              ..yes check next name in list
findf225            tst       ,s                  is name terminated?
                    bmi       findf23             ..yes
                    cmpa      #SP                 space?
                    bls       findf23             ..yes, or control
                    cmpa      #',                 comma?
                    bne       findf25             ..no
findf23             pshs      y
                    os9       F$PrsNam            skip trailing spaces and comma
                    tfr       y,x
                    puls      y
findf235            ldu       PD.RGS,y            point to register stack
                    stx       R$X,u               update pointer past path list
                    clrb                          clear carry
                    ldb       1,s                 return NE if pathlist is directory
                    beq       findf237            ..not directory
                    ldb       PD.MOD,Y            get mode
                    bpl       NoPerm              ..no permission to open directory
findf236            inc       msp.wrt,y           don't allow writing to file
                    bra       Findf24

findf237            ldx       msp.dir,y
                    lda       dir.msd+msd.attr,x  get file attribute
                    anda      #attr.RO            read only?
                    beq       findf238            ..no
                    lda       PD.MOD,Y
                    anda      #WRITE.             are we opening for write?
                    beq       findf238            ..no, we have permission
NoPerm              comb
                    ldb       #E$FNA              ..no permission
                    bra       findf24
findf238            lda       PD.MOD,y            directory?
                    bmi       NoPerm              ..yes, wrong mode
findf24             leas      7,s                 fix stack
                    puls      y,pc

findf25             comb                          set carry
                    ldb       #E$BPNam            bad path name
                    bra       findf24

* search directory for file name at X
findf26             lbsr      findname            look for the name in current directory
                    std       ,s
                    bcs       findf24             ..report error
                    ldb       4,s                 get task number
                    bra       findf22             check next section of path list

* set current directory
setdir              pshs      x,u
                    ldx       <D.Proc             point to user process
                    ldu       P$DIO+3,x           get default directory location
                    lda       PD.MOD,y            get access mode
                    anda      #EXEC.              is it execution directory?
                    beq       setdir2             ..no
                    ldu       P$DIO+9,x           get default execution directory
setdir2             tfr       u,d
                    lbsr      setcls              set current directory
                    ldx       msp.dir,y
                    stu       dir.prnt,x          save parent start cluster
                    cmpu      #1                  ROOT or entire disk?
                    bls       setdir3             ..yes
                    lbsr      readsec             read the sector
                    bcs       setdir9
                    clra
                    clrb
                    std       msp.pos+1,y         point to "." directory entry
                    ldx       PD.BUF,y            point to parent directory entry
                    bra       copydir1            copy directory entry to buffer

setdir3             ldd       #1
                    std       msp.pos+1,y         make position unique
                    tfr       u,d
                    exg       a,b
                    ldu       msp.dir,y
                    std       dir.msd+msd.strt,u
                    beq       setdir4             ..ROOT
                    ldu       #0
                    bra       setdir7
*
setdir4             lbsr      rootdat
setdir7             bsr       setsec
setdir9             puls      x,u,pc

setsec              cmpu      msp.sec,y           same sector?
                    beq       setsec9
                    stu       msp.sec,y
                    clr       msp.sest,y          ..sector buffer is not sector U
setsec9             rts

setcls              tst       msp.clss,y
                    beq       setcls0
                    std       msp.cls,y
setcls00            clr       msp.clss,y
                    bra       setcls2
setcls0             cmpd      msp.cls,y           has cluster changed?
                    beq       setsec9             ..no
                    std       msp.cls,y
setcls2             pshs      d
                    ldb       msp.sest,y
                    andb      #^SECGOOD
                    orb       #SECBUF
                    stb       msp.sest,y          msp.sec is OK but msp.cls is not
setcls9             puls      d,pc

clss0               tst       msp.clss,y
                    bne       setcls00
                    rts

* make entry for entire disk
setdisk             pshs      x,u
                    ldx       msp.dir,y
*??????????????????
                    ldd       #2
                    std       dir.msd+msd.size,x
                    ldu       #1                  .. if start cluster is 1 then entire disk is open
                    bra       setdir2

* make parent the current directory
setparnt            pshs      x,u
                    clrb                          clear carry
                    ldu       msp.cls,y           is there a current directory?
                    beq       setdir9             ..no, its root
                    lbsr      readsec
                    bcs       setdir9             ..error
                    ldu       PD.BUF,y            point to current directory
                    ldd       MSDSIZE+msd.strt,u  get parent cluster
                    exg       a,b
                    tfr       d,u
                    lbra      setdir2

copydir             pshs      x,u
copydir1            ldu       msp.dir,y           point to directory buffer
                    leau      dir.msd,u
                    ldb       #MSDSIZE
copydir5            lda       ,x+
                    sta       ,u+
                    decb
                    bne       copydir5
                    puls      x,u,pc

*******************************************************
* find file with name at X in current directory
* on entry:
*        B=DAT task number of file name
*
* return A=last character of name
*        B=mode(NE=directory) or error if carry set
*        X points to last character
findname            pshs      d,x,y,u
                    ldu       msp.dir,y
                    clra
                    clrb
                    stb       msp.pos,y
                    std       msp.pos+1,y         start of directory
                    std       dir.esec,u
                    std       dir.eoff,u          ..entry not found
                    ldd       msp.cls,y           get current cluster number (of subdirectory)
                    std       dir.prnt,u          save it (for use by makdir)
                    leau      dir.msd,u           point to place for file name
                    pshs      u
                    tfr       u,x
                    lbsr      clrname             clear the directory entry
                    ldx       4,s
                    ldb       3,s                 task number
                    lbsr      movename
                    lbeq      findnerr
                    sta       2,s                 this will be the character returned
                    stx       4,s                 return value of X
                    pshs      d,x,y
                    lbsr      readit              read the first sector in directory
                    lbcs      findn70             ..error
findn52             lbsr      secsiz              get sector size
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb                          number of directory entries per sector
                    stb       ,s
                    ldx       PD.BUF,Y            point to directory buffer
findn55             ldu       6,s                 point to file name
                    stx       4,s
                    ldb       #11                 number of bytes to compare
* this section of code is used to save values
* for the CREATE process
                    lda       ,x                  get first char of directory entry
                    beq       findn57
                    cmpa      #$E5                unused entry?
                    bne       findn6              ..no
findn57             pshs      a
                    ldx       msp.dir,y
                    ldd       dir.esec,x          unused entry already found?
                    bne       findn58             ..yes, ignore it
                    ldd       msp.sec,y           get current sector number
                    std       dir.esec,x
                    lbsr      secsiz              get sector size
                    subd      #1
                    anda      msp.pos+1,y         get position
                    andb      msp.pos+2,y         get offset in sector
                    std       dir.eoff,x
findn58             lda       ,s+
                    bne       findn7
                    bra       findnNF             ..file not found

findn6              lda       ,u+
                    cmpa      ,x+
                    bne       findn7              ..no match
                    decb
                    bne       findn6              ..compare more
* match found
                    lbsr      secsiz              get sector size
                    subd      #1
                    anda      msp.pos+1,y         get position
                    andb      msp.pos+2,y
                    std       msp.pos+1,y
                    ldx       4,s                 point to directory entry
                    lbsr      copydir             copy directory entry
                    lda       msd.attr,x          get attribute
                    anda      #attr.DR            is it directory?
                    sta       9,s
                    beq       findn67             ..no
                    ldd       msd.strt,x
                    exg       a,b
                    lbsr      setcls              set cluster number
findn67             leas      8,s                 fix stack
                    clrb                          clear carry
                    puls      d,x,y,u,pc

findn7              ldd       msp.pos+1,y
                    addd      #MSDSIZE
                    std       msp.pos+1,y         update directory entry position
                    ldx       4,s
                    leax      MSDSIZE,x
                    dec       ,s                  end of sector?
                    bne       findn55             ..no
findn72             lbsr      readnxt             read the next sector
                    lbcc      findn52
                    cmpb      #E$EOF              end of file?
                    bne       findn70             ..no report error
findnNF             ldb       #E$PNNF             path name not found
findn70             coma                          set carry
                    lda       8,s                 return last character read so CREATE can tell if name terminated OK.
                    leas      10,s                fix stack
                    puls      x,y,u,pc

findnerr            comb
                    ldb       #E$BPNam            bad path name
                    leas      4,s
                    puls      x,y,u,pc


*******************************
* B is DAT task #
* X points to file name
* U point to destination
*
* On exit:
*  A is last character of name or first non-name character
*  B is number of bytes in name

movename            pshs      d,u
                    lda       #11
                    sta       1,s
findn2              os9       F$LDABX             get character
                    leax      1,x
                    sta       ,s
                    bsr       validc              check for valid file character
                    beq       findn5
                    cmpa      #'.                 start of extension?
                    bne       findn4              ..no
                    lda       1,s
                    cmpa      #11                 first character?
                    beq       findn5              ..yes, illegal
                    ldu       2,s
                    leau      8,u                 point to start of extension
                    lda       #3
                    sta       1,s
                    lda       #SP
                    sta       ,u
                    sta       1,u
                    sta       2,u
                    bra       findn2              get next character
findn4              tst       1,s
                    beq       findn45             ..past end of name
                    sta       ,u+
                    dec       1,s
findn45             lda       ,s
                    bpl       findn2
findn5              leax      -1,x
                    puls      d,u
                    pshs      d,x
                    leax      <resrvd,pcr         point to reserved names
findn.3             clrb
findn.5             lda       ,x+
                    beq       findn.9
                    anda      #$7F
                    cmpa      b,u
                    bne       findn.7
                    incb
                    lda       -1,x                end of name?
                    bpl       findn.5             ..no, check remainder of name
                    lda       b,u
                    cmpa      #SP                 end of file name?
                    bne       findn.3             ..no match
                    clrb
                    puls      d,x,pc              signal error in file name
findn.9             puls      d,x
                    cmpb      #11                 no good characters in name?
                    rts
findn.7             leax      -1,x
findn.8             lda       ,x+
                    bpl       findn.8
                    bra       findn.3

validc              anda      #$7f                mask hi bit
                    cmpa      #'a
                    blo       findn3
                    cmpa      #'z
                    bhi       findn3
                    anda      #$5f
findn3              cmpa      #'!
                    beq       findnyes
                    cmpa      #'#
                    blo       findnno
                    cmpa      #')
                    bls       findnyes
                    cmpa      #''
                    beq       findnyes
                    cmpa      #'-
                    beq       findnyes
                    cmpa      #'.                 start of extension?
                    beq       findnyes
                    cmpa      #'0
                    blo       findnno
                    cmpa      #'9
                    bls       findnyes
                    cmpa      #'@
                    blo       findnno
                    cmpa      #'Z
                    bls       findnyes
                    cmpa      #'^
                    blo       findnno
                    cmpa      #'`
                    bls       findnyes
                    cmpa      #'{
                    beq       findnyes
                    cmpa      #'}
                    beq       findnyes
                    cmpa      #'~
                    beq       findnyes
findnno             clra
findnyes            tsta
                    rts

resrvd
                    fcs       "AUX"
                    fcs       "COM1"
                    fcs       "COM2"
                    fcs       "CON"
                    fcs       "LPT1"
                    fcs       "LPT2"
                    fcs       "LPT3"
                    fcs       "NUL"
                    fcs       "PRN"
                    fcb       0

*************************************************
* Subroutine: DirFull
*
* funtion - try to expand the directory
*
* On entry:
*  Y points to path descriptor
*
* On exit:
*  Carry set and error code in B if error
*  D offset to directory entry in sector buffer
*  X address of sector buffer
*  U sector number of sector at X

DirFull             ldd       msp.cls,y           is this root directory?
                    bne       dirfull1            ..no
dirfull0            comb                          set carry
                    ldb       #E$SLF              segment (directory) list full
dirfret             rts                           ..return error
dirfull1            lbsr      expchn              add cluster to file
                    bcs       dirfret             ..error
* another entry point (MAKDIR)
DirFull9            lbsr      setcls              save number of new cluster
                    lbsr      cluslog             convert to logical sector number
                    tfr       d,u
                    pshs      u
                    ldx       PD.BUF,y            point to sector buffer
                    lbsr      secsiz              get sector size
                    subd      #MSDSIZE
dirfull2            clr       d,x                 clear the first byte of each directory entry
                    subd      #MSDSIZE
                    bpl       dirfull2
                    ldx       PD.BUF,y
                    lbsr      sepecl              get sectors per cluster
                    deca                          only one?
                    beq       dirfull3            ..yes
dirf25              pshs      a
                    leau      1,u
                    lbsr      dwritel             write second sector of cluster
                    puls      a
                    bcs       dirfull4            ..error
                    deca
                    bne       dirf25
dirfull3            clra                          return offset to unused directory entry (first)
                    clrb
dirfull4            puls      u,pc

*************************************************
* Subroutine: create1
*
* funtion - make sure file can be created
*
* On entry:
*  Y points to path descriptor
*  U points to caller's register stack
*
* On exit:
*  Carry set and error code in B if error
*  D offset to directory entry in sector buffer
*  X address of sector buffer
*  U sector number of sector at X

create1             lbsr      findfile            find the file
                    bcs       create2             ..can't OPEN file
create10            ldb       #E$CEF              ..file already exists
                    bra       create25            ..report error
create2             cmpb      #E$PNNF             file not found?
                    beq       create3             ..yes, create it
                    cmpb      #E$FNA
                    beq       create10
create25            coma                          set carry
                    rts
create3             tsta                          is file name hi bit terminated?
                    bmi       create5             ..yes
                    cmpa      #SP                 space or control?
                    bls       create4             ..yes
                    ldb       #E$BPNam
                    cmpa      #',                 comma?
                    bne       create25            ..report bad path name error
create4             pshs      y
                    os9       F$PrsNam            skip trailing junk
                    tfr       y,x
                    puls      y
create5             ldu       PD.RGS,y            point to stacked registers
                    stx       R$X,u               return X pointing past name
                    ldx       msp.dir,y
                    clra                          file can be read or written
                    ldb       R$B,u               get file permissions
                    bitb      #WRITE.+PWRIT.      create for write?
                    bne       create52            ..yes
                    lda       #attr.RO            file is read only
create52            bitb      #DIR.               is is subdirectory
                    beq       create53            ..no
                    ora       #attr.DR
create53            sta       dir.msd+msd.attr,x  file access mode
                    clra
                    clrb
                    std       dir.msd+msd.size,x
                    std       dir.msd+msd.size+2,x set file size to 0
*** I'm not sure if MSDOS does it this way
                    ldd       #$FF0F              end of file mark
                    std       dir.msd+msd.strt,x  ..no clusters in file yet
***
                    lbsr      setdate             copy date and time to dir entry
                    ldu       msp.dir,y
                    ldx       PD.BUF,y
                    ldd       dir.eoff,u          get offset to entry in sector
                    std       msp.pos+1,y
                    ldu       dir.esec,u          get sector number
                    bne       create58            ..there is room in directory
                    lbsr      DirFull             .. directory full, expand if possible
                    bcs       create25            ..return error
                    pshs      d,x,u               save pointer to directory entry, buffer and sector #
                    tfr       u,d
                    ldu       msp.dir,y
                    std       dir.esec,u          update directory sector number
                    bra       create59
create58            lbsr      dreadl              read directory sector
                    bcs       create25            .. report error
                    ldd       msp.pos+1,y         recover offset
                    pshs      d,x,u
                    leax      d,x                 point to start of entry
                    ldu       msp.dir,y
create59            leau      dir.msd,u           point to directory info
                    ldb       #msd.res
clrres              clr       b,u                 clear the reserved bytes in the directory
                    incb
                    cmpb      #msd.time
                    blo       clrres
                    ldb       #msd.size
clrsize             clr       b,u
                    incb
                    cmpb      #MSDSIZE
                    blo       clrsize
create6             lda       ,u+
                    sta       ,x+                 copy entry into sector
                    decb
                    bne       create6
                    puls      d,x,u,pc


*************************************************
* Subroutine: create
*
* funtion - create file (initialize path descriptor)
*
* On entry:
*  Y points to path descriptor
*  U points to caller's register stack
*
* On exit:
*  Carry set and error code in B if error

create              pshs      x,u
                    lda       R$B,u
                    anda      #^DIR.              can't create a directory
                    sta       R$B,u
*** rev 2.3
* lda PD.CPR,y
* sta msp.ncpr,y
***
                    lbsr      create1
                    bcs       open10              ..return error
*** rev 2.3
* clr msp.ncpr,y ..so driver will be freed after write
***
                    lbsr      dwritel             update the directory
                    lbsr      lockeof             get control of end of file lock
                    bra       open10


*************************************************
* Subroutine: open
*
* funtion - open file (initialize path descriptor)
*
* On entry:
*  Y points to path descriptor
*  U points to caller's register stack
*
* On exit:
*  Carry set and error code in B if error

open                pshs      x,u
                    lbsr      findfile            try to find the file
open10              bcs       openerr
* check if file is already open
                    tfr       y,x
open11              ldx       msp.next,x
                    beq       open2               ..end of files reached with no match
                    ldd       msp.dnxt,x          is it last path to file
                    bne       open11              ..no, check next one
                    ldu       msp.dir,x           point to directory info
                    ldb       PD.DRV,y
                    cmpb      dir.drv,x           is it on same drive?
                    bne       open11              ..no
                    ldd       msp.sec,y
                    cmpd      dir.loc,u           same sector?
                    bne       open11              ..no
                    ldd       msp.pos+1,y
                    cmpd      dir.pos,u           same entry?
                    bne       open11              ..no
* path to same file has been found
                    lda       PD.MOD,y            get access mode
                    bita      #SHARE.             non-sharable?
                    bne       FileBusy            ..yes, busy
                    lda       [msp.dir,y]         get block number
                    ldx       <D.PthDBT
                    os9       F$Ret64             return the directory entry to the system
                    stu       msp.dir,y           point to matching entry
                    bra       open6
open2               ldu       msp.dir,y           point to directory info
                    ldb       PD.DRV,y            get drive number
                    stb       dir.drv,u
                    ldd       msp.sec,y
                    std       dir.loc,u           save sector number containing directory
                    ldd       msp.pos+1,y         get current position
                    std       dir.pos,u
open6               ldx       dir.last,u          point to previous path to same file
                    beq       open7               ..only one path to this file
                    sty       msp.dprv,x
                    stx       msp.dnxt,y
open7               sty       dir.last,u          point to last path open to this file
                    ldd       dir.msd+msd.strt,u  get starting cluster #
                    exg       a,b
                    lbsr      setcls              set cluster number
                    clra
                    clrb
                    std       msp.pos,y           we are at beginning of file
                    stb       msp.pos+2,y
                    std       msp.lksz,y          no part of file is locked
                    stb       msp.lksz+1,y
                    clr       msp.sest,y          sector buffer is invalid (and clear carry)
                    puls      x,u,pc

FileBusy            comb
                    ldb       #E$Share            non-sharable file is busy
openerr             puls      x,u
                    lbra      closef              go return buffers etc.


*************************************************
* Subroutine: chkeof
*
* function - make sure read will not go past end of file
*
* On entry:
*  Y points to path descriptor
*  U points to stacked registers
*
* On exit:
*  D number of bytes to read
*  Carry set and error in B if error

chkeof              ldd       R$Y,u               get number of bytes wanted
                    pshs      d,x,u
* if read length is greater than what is left in file
*  then make length the remaining size of file
                    ldu       msp.dir,y           point to directory entry info
                    ldd       dir.msd+msd.size,u  get least significant part of file size
                    exg       a,b                 convert to Motorola format
                    subd      msp.pos+1,y
                    pshs      d
                    ldb       dir.msd+msd.attr,u  get file attribute
                    andb      #attr.DR            is it subdirectory?
                    bne       read08              ..yes
                    ldd       dir.msd+msd.size+2,u get most significant word of file size
                    sbca      #0
                    bcs       readerr             ..read past end of file
                    suba      msp.pos,y
                    bcs       readerr             ..read past end of file
                    bne       read08              ..more than 2^16 bytes left in file
                    ldd       ,s
                    beq       readerr             ..its end of file
                    cmpd      2,s                 will we read past end of file?
                    bhs       read08              ..no
                    std       2,s                 ..yes, don't read past end of file
*
read08
***
* lbsr readit make sure the buffer is good
* bcc reader2
* bra reader1
***
                    clrb
                    bra       reader2
*
readerr             ldb       #E$EOF
reader1             stb       3,s
                    comb
reader2             leas      2,s
                    puls      d,x,u,pc


*************************************************
* Subroutine: read
*
* function - read data from the open file
*
* On entry:
*  Y point to path descriptor
*  U point to stacked registers X=address to read to
*                               Y=number of bytes
*
* On exit:
*  stacked register Y is number of bytes read
*  Carry set and error in B if error

read                clra
                    bra       read0
*
read98              std       msp.lksz,y
                    stb       msp.lksz+2,y
read99              puls      a,pc                return with error


*************************************************
* Subroutine: readln
*
* function - read a line from the open file
*
* On entry:
*  Y point to path descriptor
*  U points to stacked registers X=address to read to
*                                Y=number of bytes
*
* On exit:
*  stacked register Y = number of bytes read
*  Carry set and error in B if error

readln              lda       #EOL
read0               pshs      a
read01              ldd       R$Y,u
                    beq       read98
                    bsr       chkeof
                    bcs       read99
***
* bsr chklck check for record lock
* bcs read99 report error
* beq read01 ..yes, try again
***
                    ldx       R$X,u               get destination address
                    pshs      d,x
                    clra
                    clrb
                    pshs      d,x
                    ldx       <D.Proc
                    ldb       P$Task,x            get task number
                    pshs      b
                    lbsr      getFAT              read the FAT and set up sector buffer if needed
                    lbcs      read9               ..error
readln0             ldu       PD.BUF,y            point to buffer
                    lbsr      secsiz              get sector size
                    leax      d,u                 point to end of buffer
                    subd      #1
                    anda      msp.pos+1,y         get position
                    andb      msp.pos+2,y
                    leau      d,u                 point to start of data
                    stx       3,s
                    ldx       7,s
readln1             ldd       1,s
                    cmpd      5,s
                    beq       read2
                    addd      #1                  incriment byte count
                    std       1,s
                    ldb       msp.sest,y
                    bitb      #SECGOOD            is current sector good?
                    bne       readln12            ..yes
                    lbsr      readit              ..no, read the correct one
                    bcs       read9
readln12            ldb       ,s
                    lda       ,u+                 get a byte
                    os9       F$STABX
                    leax      1,x
                    cmpu      3,s                 was last byte read the last in the sector?
                    bne       read25              ..no
                    ldu       PD.BUF,y
                    ldb       #SECREAD
                    orb       msp.sest,y
                    andb      #^SECGOOD
                    stb       msp.sest,y          ..yes, sector is now completely read
read25              tst       9,s                 EOL char?
                    beq       readln1             ..no
                    cmpa      9,s                 is it end of line?
                    beq       read2               ..yes
                    cmpa      #MSDEOF             end of text file?
                    bne       readln1             ..no
read15              ldd       1,s
                    subd      #1
                    std       1,s
read2               ldb       PD.MOD,y            get file access mode
                    bitb      #WRITE.+PWRIT.      is file open for write?
                    beq       read26              ..no, don't lock the record
                    ldd       msp.pos,y
                    std       msp.lolk,y
                    ldb       msp.pos+2,y
                    stb       msp.lolk+2,y        update start of file lock
                    ldu       PD.RGS,y
                    ldd       R$Y,u
                    clr       msp.lksz,y
                    std       msp.lksz+1,y        update the lock size
                    lbsr      unlock              unlock waiting procs
read26              ldd       1,s
                    addd      msp.pos+1,y
                    std       msp.pos+1,y
                    lda       #0
                    adca      msp.pos,y
                    sta       msp.pos,y           update file position
                    clrb                          clear carry
                    ldd       1,s                 get byte read count
                    ldu       PD.RGS,y
                    std       R$Y,u
                    bne       read9
                    comb
                    ldb       #E$EOF              return end of file error
read9               leas      10,s
                    rts                           return with carry set and error in B
*

                    ifeq      1

*************************************************
* Subroutine: chklck
*
* function - check if current position is locked
*  if it is, sleep until it is free
*  return error if deadlock or signal
*
* On entry:
*  D is current offset (plus 1) from msp.pos,y
*  Y points to path descriptor
*
* On exit:
*  Carry set and error in B if error

chklck              pshs      x,y,u
                    ldu       msp.dir,y
chklck0             ldx       dir.last,u          point to last path to this file
chklck1             cmpx      2,s                 is it current path?
                    beq       chklck8             ..yes, ignore it
                    ldd       msp.lksz,x
                    bne       chklck2
                    tst       msp.lksz+2,x
                    beq       chklck8             ..path has no lock
chklck2
* check if path is locked

* b?? chklck8 ..no
* check if deadlock
                    lda       msp.LID,x           get lock process waiting ID
                    cmpa      msp.ID,y            is it waiting for current process?
                    bne       chklck5             ..no
                    ldb       #E$DeadLk           ..yes, report deadlock
                    bra       chklck7
* make sure driver is not reserved
chklck5             lbsr      reldrvr
* sleep
                    lda       msp.ID,x            get ID of process we are waiting for
                    sta       msp.LID,y
                    lda       msp.ID,y
                    sta       msp.WID,y           mark path as waiting
                    ldx       #0
                    os9       F$SLEEP             sleep until signalled
                    pshs      b,cc
* remove path from locked list
                    clr       msp.WID,y           mark path as not waiting
                    clr       msp.LID,y
                    puls      b,cc
                    bcs       chklck9             ..return error
                    ldx       <D.Proc
                    ldb       P$Signal,x          was process signalled?
                    beq       chklck0             ..no, check for other locks
chklck7             coma                          return signal which was received
                    puls      x,y,u,pc

chklck8             ldx       msp.dprv,x          point to previous file
                    bne       chklck1
                    clrb
chklck9             puls      x,y,u,pc

                    endc


*************************************************
* Subroutine: write
*
* function - write data to the current position of the file
*
* On entry:
*  Y points to path descriptor
*  X point to data to write
*  D is the number of bytes to write
*
* On exit:
*  D is number of bytes written
*  Carry set and error in B if error

write               clra                          ..no end of line character
                    bra       write0


*************************************************
* Subroutine: writeln
*
* function - write data up to count or first EOL
*  to the current position of the file
*
* On entry:
*  Y points to path descriptor
*  U points to stacked register X=address of data
*                               Y=number of bytes
*
* On exit:
*  stacked register Y is number of bytes written
*  Carry set and error in B if error

writeln             lda       #EOL
write0              ldb       msp.wrt,y           can we write?
                    beq       writln00            ..yes
FNA                 comb
                    ldb       #E$FNA              file is not accessible
                    rts
writln00            pshs      a                   save EOL character
                    ldx       R$X,u               point to data
                    ldd       R$Y,u               get size of data
                    lbeq      read98
                    pshs      d,x,u
                    ldu       PD.BUF,y            point to buffer
                    lbsr      secsiz              get sector size
                    leax      d,u                 point to end of buffer
                    subd      #1
                    anda      msp.pos+1,y         get position
                    andb      msp.pos+2,y
                    leau      d,u                 point to start of data
                    clra
                    clrb
                    pshs      d,x
                    ldx       <D.Proc
                    ldb       P$Task,x            get task number
                    pshs      b
***
* bsr chklck check if record is locked
* bcs write9
***
                    ldx       7,s
writln1             ldd       1,s
                    cmpd      5,s
                    beq       write2
                    addd      #1                  incriment byte count
                    std       1,s
                    ldb       msp.sest,y
                    bitb      #SECGOOD
                    bne       write12             ..yes
                    lbsr      seekwr              get ready to write
                    lbcs      write9
write12             ldb       ,s                  get task number
                    os9       F$LDABX             get byte
                    leax      1,x
                    sta       ,u+
                    ldb       #SECUPD+SECGOOD     sector is valid and needs update
                    cmpu      3,s                 is it end of sector?
                    bne       writln15
                    ldu       PD.BUF,y
                    ldb       #SECUPD+SECREAD     sector needs update and next one
writln15            stb       msp.sest,y          set sector status
                    tst       11,s                EOL char?
                    beq       writln1             ..no
                    cmpa      11,s                end of line?
                    bne       writln1             ..no
write2              clra
                    clrb
                    stb       msp.lksz,y
                    std       msp.lksz+1,y        no part of file is locked after write
                    ldd       1,s
                    addd      msp.pos+1,y
                    std       msp.pos+1,y
                    lda       #0
                    adca      msp.pos,y
                    sta       msp.pos,y           update file position
* update file size if position is greater than current size
write3              ldx       msp.dir,y
                    lda       dir.chg,x
                    ora       #attr.AR            set archive bit
                    sta       dir.chg,x
                    ldb       dir.msd+msd.attr,x  get attribute
                    bitb      #attr.DR            sub-directory?
                    bne       write35             ..yes, don't update size
                    ldd       dir.msd+msd.size+2,x get most significant file size
                    cmpa      msp.pos,y
                    blo       write35             ..position is past end of file
                    bhi       write36             ..position is not past end of file
                    ldd       dir.msd+msd.size,x  get least sig file size
                    exg       a,b
                    cmpd      msp.pos+1,y
                    bhs       write36             ..position is not past end of file
write35             ldd       msp.pos+1,y
                    exg       a,b                 to INTEL format
                    std       dir.msd+msd.size,x  update least sig size
                    lda       msp.pos,y
                    sta       dir.msd+msd.size+2,x update most sig size
                    bsr       lockeof
write36             bsr       unlock              unlock path waiting for this one
                    clrb                          clear carry
                    ldd       1,s                 get byte read count
                    ldu       PD.RGS,y            point to registers
                    std       R$Y,u               return number of bytes written
write9              leas      12,s
                    rts                           return with carry set and error in B

lockeof             pshs      b,cc
                    ldd       msp.pos,y
                    std       msp.lolk,y
                    lda       msp.pos+2,y
                    sta       msp.lolk+2,y
                    clra
                    clrb
                    std       msp.lksz,y
                    inca
                    sta       msp.lksz+2,y
                    puls      b,cc,pc

* unlock any waiting path(s)
unlock

                    ifeq      1

                    ldx       msp.dir,y           point to path which is waiting for this one
                    ldx       dir.last,x
unlock2             lda       msp.WID,x           get waiting process ID
                    beq       unlock3             ..none
                    ldb       #S$Wake
                    os9       F$SEND              wake up the waiting process
unlock3             ldx       msp.dprv,x
                    bne       unlock2

                    endc

                    rts

*******************************************************
* Subroutine: seekwr
*
* function - get ready to write to the current position
*
* On entry:
*  Y points to path descriptor
*
* On exit:
*  Carry set and error in B if error

seekwr              pshs      d,x,u
                    ldb       msp.sest,y          get buffer status
                    bitb      #SECUPD             does sector need updating?
                    beq       seekwr2             ..no
                    lbsr      writsec             update the sector
                    bcs       seekwr99
                    ldb       msp.sest,y
seekwr2             bitb      #SECREAD            is next sector the one we want?
                    bne       seekwr3             ..yes
                    bsr       expand
                    bra       seekwr4
seekwr3             bsr       expnxt              get number of next sector in the file
seekwr4             bcs       seekwr99
seekwr8             lbsr      readsec
                    bcs       seekwr99
                    ldb       #SECGOOD
                    stb       msp.sest,y
seekwr9             clrb                          clear carry
                    puls      d,x,u,pc
seekwr99            stb       1,s
                    puls      d,x,u,pc


*******************************************************
* Subroutine: expand
*
* function - seek to the current file position
*  and expand file if needed
*
* On entry:
*  Y point to path descriptor
*
* On exit:
*  Carry set and error in B if error

expand              ldd       msp.pos,y
*
* On entry:
*  D is position/256 to expand to
*
expand0             pshs      d,u
                    ldu       msp.dir,y           point to directory entry
                    ldd       dir.msd+msd.strt,u  get number of first cluster
                    exg       a,b                 convert to Motorola format
                    lbsr      setcls              set cluster number
                    cmpd      #$0FF8
                    blo       expand3             ..not first cluster
                    bsr       expnxt0             add cluster if file is empty
                    bcs       expand9
                    exg       a,b
                    std       dir.msd+msd.strt,u  ..first cluster
expand3             lbsr      secsiz              get sector size
                    exg       a,b
                    pshs      d
                    ldd       2,s                 get 256 byte sector count
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                    subd      ,s++                subtract pages/sector
                    blo       expand4             ..position found
                    std       ,s
                    bsr       expnxt              find next sector (add one if needed)
                    bcs       expand9
                    bra       expand3

expand4             clrb
expand9             leas      2,s
                    puls      u,pc

expnxt0             pshs      x,u                 expand from beginning of file
                    bra       expnxt00

expnxt              pshs      x,u                 seek or expand to next sector
                    lbsr      seeknxt
expnxt00            cmpd      #$FF8
                    blo       expnxt1
                    ldd       msp.cls,y           last cluster in file
                    lbsr      expchn              add next used cluster to chain
                    bcs       expnxt2
                    pshs      d
                    ldb       msp.sest,y

                    orb       #SECEXP             sector is expanded, don't read it
                    stb       msp.sest,y
                    puls      d
                    lbsr      clss0               first sector in cluster
expnxt1             lbsr      setcls0             set cluster number
                    andcc     #$fe                clear carry
expnxt2             puls      x,u,pc


*******************************************************
* Subroutine: seek
*
* function - seek to a new position in the file
*
* On entry:
*  Y points to path descriptor
*  U points to stacked registers
*
* On exit:
*  Carry set and error in B if error

seek                lbsr      secsiz              get sector size
                    addd      #1
                    tfr       a,b
                    andb      R$U,u
                    pshs      b
                    anda      msp.pos+1,y
                    cmpa      ,s+                 is seek within current sector?
                    bne       seek2               ..no, position is in different sector
                    ldd       R$X,u               MSW
                    cmpb      msp.pos,y
                    bne       seek2               ..position is in different sector
seek1               stb       msp.pos,y
                    ldd       R$U,u
                    std       msp.pos+1,y         update position in current sector
                    clrb                          ..no error
seek9               rts

seek2               ldb       msp.sest,y
                    andb      #SECUPD             does sector need updating?
                    beq       seek3               ..no
                    lbsr      writsec             write the current sector
                    bcs       seek9
                    ldb       msp.sest,y
seek3               andb      #^(SECREAD!SECGOOD!SECUPD) sector is no longer valid
                    stb       msp.sest,y
                    ldd       R$X,u
                    bra       seek1

* Clear directory entry at X

clrentry            bsr       clrname
makd4               clr       ,x+                 clear the rest of the entry
                    incb
                    cmpb      #MSDSIZE
                    blo       makd4
                    rts

clrname             clrb
                    lda       #SP
makd3               sta       ,x+                 write spaces for file name
                    incb
                    cmpb      #11
                    blo       makd3
                    rts


*******************************************************
* Subroutine: makdir
*
* function - make a new directory
*
* On entry:
*  Y points to path descriptor
*  U points to caller's register stack
*
* On exit:
*  Carry set and error in B if error

makdir
*** rev 2.3
* lda PD.CPR,y
* sta msp.ncpr,y ..so disk driver won't be released
***
                    lda       R$B,u               get access mode
                    ora       #DIR.+WRITE.        set the directory bit
                    anda      #^(EXEC.+PEXEC.)
                    sta       R$B,u
                    sta       PD.MOD,y
                    lbsr      create1             create a new file
                    lbcs      closef              close file and report error
                    pshs      x,u                 save offset, buffer address and sector #
                    leax      d,x                 point to directory entry
                    pshs      x
                    clra
                    clrb                          no clusters in file yet
                    lbsr      expchn              add next unused cluster to chain
                    puls      x
                    bcs       closem              close file and report error
                    lbsr      setcls              save cluster number
                    exg       a,b                 convert to INTEL
                    std       msd.strt,x          put starting cluster of new directory
                    puls      x,u                 get address and number of sector
                    lbsr      dwritel             update the directory
                    bcs       closef              ..error
                    ldd       msp.cls,y           get cluster number of new directory
                    lbsr      DirFull9            ..clear directory entries
                    bcs       closef              ..error
                    pshs      x,u
                    bsr       clrentry
                    bsr       clrentry
                    ldx       PD.BUF,y
                    ldu       msp.dir,y
                    lda       #attr.DR            subdirectories
                    sta       msd.attr,x
                    sta       MSDSIZE+msd.attr,x
                    ldd       dir.msd+msd.time,u  get time
                    std       msd.time,x
                    std       MSDSIZE+msd.time,x
                    ldd       dir.msd+msd.date,u  get date
                    std       msd.date,x
                    std       MSDSIZE+msd.date,x
                    ldd       msp.cls,y           get starting cluster number
                    exg       a,b
                    std       msd.strt,x
                    ldd       dir.prnt,u          get parent directory start cluster
                    exg       a,b
                    std       MSDSIZE+msd.strt,x
                    ldd       #"..
                    stb       msd.name,x
                    std       MSDSIZE+msd.name,x
                    puls      x,u
                    lbsr      dwritel             write the new subdirectory
                    bcs       closef
                    lbsr      writFAT             update the file allocation table
                    bra       closef
closem              puls      x,u
                    bra       closef

*******************************************************
* Subroutine: close
*
* function - close the current path
*
* On entry:
*  Y points to path descriptor
*
* On exit:
*  Carry set and error in B if error

close               clra                          clear carry
                    tst       msp.cnt,y           any duped paths?
                    lbne      close5              ..yes, don't deallocate
                    ldb       PD.MOD,y            get access mode
                    bitb      #WRITE.             open for write?
                    beq       close10             ..no
                    ldb       msp.sest,y          get sector status
                    bitb      #SECUPD             does sector need update?
                    beq       close1              ..no
                    lbsr      writsec             write sector
                    bcs       closef
close1              ldx       msp.dir,y           point to directory info
                    ldb       dir.stat,x          update FAT?
                    beq       close10             ..no
                    clr       dir.stat,x
                    lbsr      writFAT             update the FAT
                    bcs       closef
close10             bsr       writdir             update the directory entry
closef              pshs      cc,b                save condition codes and B in case of error
                    ldu       PD.BUF,y            point to sector buffer
                    beq       close3              ..no buffer
                    lbsr      secsiz              get sector size
                    os9       F$SRTMem            return system memory
close3              ldx       msp.prev,y          point to previous MSF path descriptor
                    ldu       msp.next,y
                    beq       close35
                    stx       msp.prev,u
                    bne       close38
                    tfr       u,x
                    bra       close37
close35             stx       -2,s
                    bne       close38
close37             stx       <D.MSF
                    bra       close4
close38             stu       msp.next,x
close4              ldx       msp.dprv,y          point to previous desc for same file
                    ldu       msp.dnxt,y          point to next desc for same file
                    beq       close45
                    stx       msp.dprv,u
close45             stx       -2,s
                    bne       close48
                    ldx       msp.dir,y
                    stu       dir.last,x
                    beq       close47             .. no one is using directory entry
                    bra       close49
close48             stu       msp.dnxt,x
                    bra       close49
close47             lda       ,x                  get block number
                    ldx       <D.PthDBT
                    os9       F$Ret64             return the directory entry to the system
close49             ldx       msp.dtb,y           point to device table
                    dec       V.CNT,x
*** mod so it works with VAR
                    bne       close50
                    ldu       V.FAT,x
                    beq       close50             ..FAT hadn't been read
                    clra
                    clrb
                    std       V.FAT,x
                    lda       V.FS,x              get FAT size (in pages)
                    os9       F$SRTMem            return system memory
                    lda       [V.BPB,x]           get page number
                    ldx       <D.PthDBT
                    os9       F$Ret64
close50             bsr       close5              release the driver for other use
                    puls      cc,b,pc             return with error or not

close5
*** rev 2.3
* clr msp.ncpr,y
* lbra reldrvr release the driver for other use
***
                    rts

writdir             ldx       msp.dir,y
                    ldb       dir.chg,x           has directory entry changed?
                    beq       writdir9            ..no
writdir0            lda       PD.CPR,y
                    sta       msp.ncpr,y          so driver will remain locked
                    clr       dir.chg,x
                    andb      #attr.AR            has file been updated?
                    beq       writdir1            ..no
                    orb       dir.msd+msd.attr,x  set ARchive bit
                    stb       dir.msd+msd.attr,x
                    lbsr      setdate
writdir1            ldd       dir.msd+msd.strt,x
                    exg       a,b
                    cmpd      #1
                    bls       permiss
                    ldu       dir.loc,x           get directory sector #
                    ldx       PD.BUF,y            point to buffer
                    lbsr      dreadl              read the sector
                    bcs       writdir9            ..error
                    pshs      x,u
                    ldu       msp.dir,y
                    ldd       dir.pos,u           get offset to entry
                    leau      dir.msd,u           skip file name
                    leax      d,x
                    ldb       #MSDSIZE            number of bytes to copy
writdir2            lda       ,u+
                    sta       ,x+
                    decb
                    bne       writdir2
                    puls      x,u
                    lbsr      dwritel             write the updated sector
writdir9            pshs      cc,b
                    bra       close50

permiss             comb
                    ldb       #E$BMode
                    rts

*******************************************************
* Subroutine: chgdir
*
* function - change the current execution or data directory
*
* On entry:
*  Y points to path descriptor
*
* On exit:
*  Carry set and error in B if error

chgdir              ldb       PD.MOD,y            get access mode
                    orb       #DIR.               make sure we find a directory
                    stb       PD.MOD,y
                    dec       PD.CNT,y            so file will close properly
                    lbsr      findfile            open the directory
                    lbcs      closef              close the file
                    ldx       <D.Proc             point to the user process descriptor
                    ldu       msp.dir,y
                    ldd       dir.msd+msd.strt,u  get starting cluster number
                    exg       a,b                 convert to motorola
                    tfr       d,u
                    lda       PD.DRV,y            get drive number
                    ldb       PD.MOD,y            get access mode
                    bitb      #READ.+WRITE.       read or write?
                    beq       chgdir2             ..no
                    sta       P$DIO+2,x
                    stu       P$DIO+3,x
chgdir2             bitb      #EXEC.              execution dir?
                    beq       chgdir4             ..no
                    sta       P$DIO+8,x
                    stu       P$DIO+9,x
chgdir4             clrb
                    lbra      closef              go close the file


*******************************************************
* Subroutine: readit
*
* function read the current sector if it is valid
*
* On entry:
*  Y points to path descriptor
*
* On exit:
*  Carry set and error in B if error

readit              clrb                          clear carry
                    pshs      x,u
                    ldb       msp.sest,y          get sector status
                    bitb      #SECGOOD            is current sector OK?
                    bne       readit9             ..yes
                    bitb      #SECUPD             does sector need updating?
                    beq       readit1             ..no
                    lbsr      writsec             write the current sector
                    bcs       readit9
                    ldb       msp.sest,y
readit1             bitb      #SECREAD            read next sector?
                    bne       readnxt1            ..yes
                    bsr       seekit              find cluster number of sector
                    bcs       readit9
                    bra       readnxt2

* read the next sector in a file
readnxt             pshs      x,u                 read the next sector in the file
readnxt1            lbsr      seeknxt             seek to the next sector
                    cmpd      #$FF8               last cluster?
                    bhs       readit99
                    lbsr      setcls0             set current cluster number
readnxt2            lbsr      readsec             read the current sector
                    bcs       readit9
                    ldb       #SECGOOD
                    stb       msp.sest,y
readit9             puls      x,u,pc

readit99            coma                          set carry
                    ldb       #E$EOF
                    puls      x,u,pc


*******************************************************
* Subroutine: seekit
*
* function - seek to the current file position
*
* On entry:
*  Y points to path descriptor
*
* On exit:
*  Carry set and error in B if error

seekit              pshs      x,u
                    ldd       msp.cls,y
                    beq       seekit01            ..root directory
                    cmpd      #1
                    bne       seekit03            ..not entire disk
                    lbsr      disksize
seekit00            ldu       #0
                    bra       seekit02
seekit01            lbsr      rootdat
                    ldx       msp.dtb,y
                    ldx       V.BPB,x
                    lda       ID.BPS+1,x          get MSB of sector size
skit012             lsra
                    beq       skit015
                    lslb
                    bra       skit012
skit015             clra
                    ldx       msp.dir,y
                    std       dir.msd+msd.size,x
seekit02            lbsr      setsec              currect sector is start of root or disk
                    ldx       msp.dir,y
                    lbsr      secsiz              get sector size
                    pshs      a
                    ldd       dir.msd+msd.size+1,x get file size
                    exg       a,b
skit02              lsr       ,s
                    beq       skit025             ..done
                    lsra
                    rorb                          divide number of 256 byte sector to get actual sectors
                    bra       skit02
skit025             leas      1,s
                    leau      d,u                 first sector past last one
                    stu       msp.end,y
seekit03            lbsr      clss0               first sector in cluster
                    ldu       msp.dir,y           point to directory entry
                    ldd       dir.msd+msd.strt,u  get number of first cluster
                    exg       a,b                 convert to Motorola format
                    ldx       msp.pos,y           get position to seek to
seekit1             cmpd      #$FF8               end of chain?
                    bhs       readit99            ..yes
                    lbsr      setcls0             set current cluster number
                    lbsr      secsiz              get sector size
                    exg       a,b
                    pshs      d
                    tfr       x,d
                    subd      ,s++                subtract pages/sector
                    bcs       seekit4
                    pshs      d
                    bsr       seeknxt             seek to the next sector
                    puls      x
                    bra       seekit1
seekit4             clrb
seekit5             puls      x,u,pc              .. position has been found

seekroot            pshs      u
                    ldu       msp.sec,y           get current sector number
                    leau      1,u
                    cmpu      msp.end,y           end of directory or disk?
                    bhs       seekrt9             ..yes
                    lbsr      setsec
                    ldd       msp.cls,y
                    puls      u,pc
seekrt9             lda       #$FF                return EOF indicator
                    puls      u,pc

seeknxt             ldd       msp.cls,y           root directory?
                    cmpd      #1                  or entire disk?
                    bls       seekroot            ..yes
                    ldx       msp.dtb,y           point to drive info table
                    lbsr      sepecl              get sectors per cluster
                    deca
                    cmpa      msp.clss,y          last sector in cluster?
                    bne       seeknxt8            ..no
seeknxt7            ldd       msp.cls,y           get current cluster number
                    ldx       V.FAT,x             point to FAT
                    lbsr      findnext            find next cluster in chain
                    lbsr      clss0               ..it's the first sector in the cluster
seeknxt9            rts

seeknxt8            inc       msp.clss,y          point to next sector in cluster
                    ldb       msp.sest,y
                    andb      #^SECGOOD
                    orb       #SECBUF
                    stb       msp.sest,y
                    clrb
                    ldd       msp.cls,y
                    rts


*******************************************************
* Subroutine: readsec
*
* function - read the current sector
*
* On entry:
*  Y points to path descriptor
*
* On exit:
*  Carry set and error in B if error

readsec             pshs      x,u
                    ldu       msp.sec,y           root directory?
                    ldd       msp.cls,y           get cluster number
                    cmpd      #1                  ROOT or entire disk?
                    bls       readsec2            ..yes
                    bsr       cluslog             convert cluster number to logical sector #
                    addb      msp.clss,y          add cluster sector #
                    adca      #0
                    tfr       d,u
readsec2            lbsr      dreadl
                    puls      x,u,pc


*******************************************************
* Subroutine: writsec
*
* function - write the current sector
*
* On entry:
*  Y points to path descriptor
*
* On exit:
*  Carry set and error in B if error

writsec             pshs      x,u
                    ldu       msp.sec,y
                    ldd       msp.cls,y           get cluster number
                    cmpd      #1                  ROOT or entire disk
                    bls       writsec2            ..yes
                    bsr       cluslog             convert cluster number to logical sector #
                    addb      msp.clss,y          add cluster sector #
                    adca      #0
                    tfr       d,u
writsec2            ldx       PD.BUF,y            point to sector buffer
                    lbsr      dwritel
                    bcs       writsec9
                    ldb       msp.sest,y          get sector status
                    andb      #^SECUPD
                    stb       msp.sest,y
                    ldx       msp.dir,y           point to directory info
                    ldb       dir.chg,x           get directory change flag
                    orb       #attr.AR            set the archive bit
                    stb       dir.chg,x
writsec9            puls      x,u,pc


*************************************************
* Subroutine: cluslog
*
* function - convert cluster # to logical sector #
*
* On entry:
*  D is cluster #
*  Y points to path descriptor
*
* On exit:
*  D is logical sector #

cluslog             subd      #2
                    pshs      d,x,u
                    lbsr      rootdat             get root info
cluslog1            lsra                          cluster done?
                    beq       cluslog5            ..no
                    lsl       1,s
                    rol       ,s                  multiply by 2
                    bra       cluslog1
cluslog5            pshs      u                   starting sector of directory
                    addd      ,s++                directory size + starting sector
                    addd      ,s++                + data offset
                    puls      x,u,pc


*************************************************
* Subroutine: readFAT
*
* function - read the File Allocation Table
*
* On entry:
*  Y points to path descriptor
*
* On exit:
*  X points to FAT
*  Carry set if error (error code in B)

readFAT             ldb       PD.DNS,y            get density
                    lslb
                    andb      #%00001010          get hi and double density bits
                    orb       #%01000000          1024 byte sector size
                    ldx       msp.dtb,y
                    stb       V.dns,x             save density info
                    pshs      x,u
                    ldd       #1024               allow for up to 1k sector size
                    sta       V.FS,x              current FAT size (it may change yet)
                    os9       F$SRQMEM
                    lbcs      readFAT9
                    stu       V.FAT,x             save pointer to FAT
                    tfr       u,x
                    ldu       #1                  boot sector
                    clrb                          side 0
                    lbsr      dread               read the boot sector
                    lbcs      readFAT8
                    ldb       ,x                  get version byte
                    tfr       x,u
                    ldx       msp.dtb,y
                    lda       V.dns,x
                    leax      ID.skip,u           point to disk information
                    cmpb      #$E9                version 2?
                    beq       maketabl            ..yes
                    cmpb      #$EB                version 3?
                    beq       maketabl            ..yes
                    bita      #%00001000          is it hi density?
                    bne       maketabl            ..yes, sector 0 must be good (FM R60)
                    ldx       msp.dtb,y
                    ldb       #%00100010
                    stb       V.dns,x             set up for double density 512 byte sectors
                    tfr       u,x
                    ldu       #$0002              track 0 sector 2 first sector of FAT
                    clrb                          side 0
                    lbsr      dread               read the first sector of FAT
                    lbcs      readFAT8
                    ldb       ,x                  get format type
                    cmpb      #$FC                is it valid byte?
                    lblo      readFAT5            ..no
                    leax      doubles8,pcr
nxttbl              incb
                    beq       maketabl            ..yes, table found
                    leax      IDsize,x            point to next table
                    bra       nxttbl
maketabl            tfr       x,u
                    pshs      y
                    ldx       <D.PthDBT
                    os9       F$ALL64             allocate 64 bytes
                    tfr       y,x                 point x to buffer
                    puls      y
                    lbcs      readFAT5            ..no memory
                    pshs      u
                    ldu       msp.dtb,y
                    stx       V.BPB,u             save pointer to disk info
                    puls      u
                    pshs      x
                    leax      1,x
                    lda       #IDsize             get size of info table
maketlp             ldb       ,u+
                    stb       ,x+
                    deca
                    bne       maketlp             copy the disk info to safe place
                    puls      x                   point to info
*** calculate usable clusters
                    ldb       ID.SPA,x            cluster size
                    pshs      b
                    ldd       ID.res,x
                    exg       a,b
                    pshs      d
                    lda       ID.spf,x
                    ldb       ID.FATs,x
                    mul
                    pshs      d
                    ldd       ID.RDE,x
                    exg       a,b
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb                          divide directory entries by 16 to get sectors
                    pshs      d
                    ldd       ID.secs,x           get total sectors
                    exg       a,b
                    subd      ,s++
                    subd      ,s++
                    subd      ,s++                usable sectors
divsec              lsr       ,s                  end of cluster?
                    beq       divdone
                    lsra
                    rorb
                    bra       divsec
divdone             addd      #2
                    std       ID.clus,x           save usable cluster count
                    puls      b
*** calculate track density
                    ldb       #40
                    pshs      b
                    lda       ID.spt,x            get sectors/track
                    ldb       ID.hds,x            get heads
                    mul
                    pshs      d                   sectors/cylinder
                    ldd       ID.secs,x           total sectors
                    exg       a,b
calctrks            subd      ,s
                    ble       calctrk1
                    dec       2,s
                    bne       calctrks
                    ldb       #4
                    bra       calctrk2
calctrk1            clrb
calctrk2            leas      3,s
                    lda       ID.BPS+1,x
                    lbeq      readFAT5            ..sector size not supported
                    lsla
                    lsla
                    lsla
                    lsla
                    pshs      a
                    lda       ID.spf,x            get sectors per FAT
                    ldx       1,s
                    orb       V.dns,x
                    andb      #$f                 mask out density info
                    orb       ,s+
                    stb       V.dns,x             update density
                    ldu       V.FAT,x             get FAT address
                    pshs      a                   save FAT sector count
                    ldd       #1024               buffer size
                    os9       F$SRTMem            return the memory
                    clra
                    clrb
                    std       V.FAT,x
                    lbsr      secsiz              get sector size
                    tfr       a,b
                    lda       ,s                  get FAT sector count
calct2              lsrb
                    beq       calct3
                    lsla                          convert sectors to pages
                    bra       calct2
calct3              sta       V.FS,x              save FAT size (in pages)
                    os9       F$SRQMem
                    puls      a                   recover sector count
                    bcs       readFAT9            ..report error
                    stu       V.FAT,x
onesec              tfr       u,x
                    ldu       #$0002              first sector of FAT
RFloop              pshs      a
                    clrb                          side 0
                    lbsr      dread
                    puls      a
                    bcs       readFAT8            ..report error
                    pshs      a
                    lbsr      secsiz              get sector size
                    leax      d,x
                    puls      a
                    leau      1,u                 track 0 sector 3
                    deca
                    bne       RFloop              ..more
                    puls      x
                    ldx       V.FAT,x
                    clrb                          clear carry
                    puls      u,pc

readFAT5            comb
                    ldb       #E$BTyp             wrong media
readFAT8            ldx       ,s
                    pshs      b,cc
                    ldu       V.FAT,x             get FAT address
                    lda       V.FS,x              get FAT size
                    clrb
                    os9       F$SRTMem            return the memory
                    puls      b,cc
readFAT9            ldx       ,s
                    pshs      b,cc
                    lda       [V.BPB,x]           get info buffer page number
                    ldx       <D.PthDBT
                    os9       F$Ret64
                    puls      cc,b,x,u,pc


*******************************************
* set the disk size
disksize            pshs      x
                    ldx       msp.dtb,y
                    ldx       V.BPB,x             point to disk info
                    ldb       ID.BPS+1,x          get pages/sector
                    pshs      b
                    ldd       ID.secs,x           get total number of sectors on disk
disksiz3            lsr       ,s
                    beq       disksiz5            ..done
                    lsla
                    rolb
                    bra       disksiz3
disksiz5            ldx       msp.dir,y
                    std       dir.msd+msd.size+1,x save disk size
                    clr       dir.msd+msd.size,x
                    clr       dir.msd+msd.size+3,x
                    puls      a,x,pc


*******************************************
* Subroutine: dreadl
*
* function read logical sector
*
* On entry:
*  U is logical sector number
*  Y points to path descriptor
*
* On exit:
*  D is garbage
*  data read to PD.BUF
*  Carry set and error in B if error

dreadl              pshs      u,x
* lbsr getFAT read the FAT and set up sector buffer if needed
* bcs dreadl9 ..error
* bne dreadl2 buffer was already set
* bsr disksize this must be the first read of entire disk (@)
dreadl2             ldb       msp.sest,y          is sector valid?
                    beq       dreadl5             ..no
                    bitb      #SECEXP
                    bne       dreadl8             ..yes, don't read sector
                    cmpu      msp.sec,y           is it current sector?
                    beq       dreadl9             ..yes, return
                    ldx       <D.MSF              follow file chain to see if other path has this sector
                    ldb       PD.DRV,y
dreadl3             tst       msp.sest,x          is sector valid?
                    beq       dreadl4             ..no
                    cmpb      PD.DRV,x
                    bne       dreadl4             ..no
                    cmpu      msp.sec,x           same sector?
                    bne       dreadl4             ..no
                    stu       msp.sec,y
                    lbsr      secsiz              get sector size
                    ldu       PD.BUF,x
                    leau      d,u
                    ldx       PD.BUF,y
                    leax      d,x
dreadl35            ldd       ,--u
                    std       ,--x
                    cmpx      PD.BUF,y
                    bne       dreadl35
                    bra       dreadl9
dreadl4             ldx       msp.next,x          point to next path
                    bne       dreadl3
dreadl5             stu       msp.sec,y
                    clr       msp.sest,y
                    ldx       PD.BUF,y
                    bsr       logphys             convert logical sector number to track/sector/side
                    bsr       dread               read the sector
                    bcs       dreadl9
dread7              ldb       #SECBUF             mark sector as valid
                    stb       msp.sest,y          indicate the buffer contains sector msp.sec
dreadl9             puls      x,u,pc
dreadl8             stu       msp.sec,y
                    bra       dread7

*******************************************
* Subroutine: dread
*
* Function - Read an MSDOS sector
*
* On entry:
*  X points to buffer
*  U MSB track #, LSB sector #
*  B - bit 0 set = side 1
*  Y points to path descriptor
*
* On exit:
*  Carry Set and error in B if error

dread               pshs      x
                    pshs      y
                    ldy       msp.dtb,y
                    orb       V.dns,y             mask in track density (bit2 set=96tpi)
                    ldy       ,s                  recover y
                    ldy       PD.RGS,y
                    pshs      y
                    clra
                    tfr       d,y
                    ldb       #SS.SREAD
                    ifeq      H6309-1
                    pshs      pc,u,y,x,dp
                    pshsw
                    pshs      d,cc
                    else
                    pshs      pc,u,y,x,dp,d,cc    push all parameters
                    endc
                    ldy       R$Size+4,s          point to path descriptor
                    sts       PD.RGS,y            save pointer to register params
                    lbsr      getstat0
                    leas      R$Size,s
                    puls      x,y
                    stx       PD.RGS,y
                    puls      x,pc


*******************************************
* Subroutine: logphys
*
* function - convert logical sector number to
*  track/sector/side
*
* On entry:
*  U is logical sector number
*  Y points to path descriptor
*
* On exit:
*  B is side (0 or 1)
*  U is track and sector number

logphys             pshs      x,y
                    ldy       msp.dtb,y
                    ldy       V.BPB,y             point to disk info
                    ldd       ID.spt,y            get sectors/track
                    exg       a,b
logph0              pshs      d                   save sectors/track
                    ldx       #0                  start on track 0
                    tfr       u,d
logph1              subd      ,s
                    bcs       logph5              ..track found
                    leax      1,x
                    bra       logph1
logph5              addd      ,s++
                    incb                          sector number to read
                    pshs      b
                    tfr       x,d
                    tfr       b,a
                    ldb       ID.hds,y            get number of heads/sides
                    decb                          double sided?
                    beq       logph6              ..no
                    lsra                          divide tracks by 2
                    ldb       #0
                    rolb
logph6              pshs      a                   track number
                    puls      u                   MSB=track, LSB=sector
                    puls      x,y,pc


*************************************************
* Subroutine: writFAT
*
* function - write the File Allocation Table
*
* On entry:
*  Y points to path descriptor
*
* On exit:
*  X points to FAT
*  Carry set if error (error code in B)

writFAT             ldx       msp.dtb,y
                    lda       V.FS,x              get FAT size (in pages)
                    lsra                          convert to sectors
                    ldx       V.FAT,x             point to FAT
                    pshs      a,x,u
                    ldu       #$0002              track 0 sector 2
WFloop              clrb                          side 0
                    bsr       dwrite
                    bcs       writFAT9
                    lbsr      secsiz              get sector size
                    leax      d,x
                    leau      1,u                 next sector
                    dec       ,s
                    bne       WFloop
                    clrb
writFAT9            puls      a,x,u,pc


*******************************************
* Subroutine: dwritel
*
* function - write logical sector
*
* On entry:
*  X points to buffer (512 bytes)
*  U is logical sector number
*  Y points to path descriptor
*
* On exit:
*  D is garbage
*  data written from X
*  Carry set and error in B if error

dwritel             pshs      u
                    stu       msp.sec,y
                    bsr       logphys             convert logical sector number to track/sector/side
                    ldx       PD.BUF,y
                    lda       msp.sest,y
                    pshs      a
                    clr       msp.sest,y
                    bsr       dwrite              write the sector
                    puls      a
                    bcs       dwritel9
                    anda      #^(SECUPD+SECEXP)   ..sector doesn't need update anymore
dwritel9            sta       msp.sest,y
                    puls      u,pc


*******************************************
* Subroutine: dwrite
*
* Function - Write an MSDOS sector
*
* On entry:
*  X points to buffer
*  U MSB track #, LSB sector #
*  B - bit 0 set - side 1
*  Y points to path descriptor
*
* On exit:
*  Carry Set and error in B if error

dwrite              pshs      x
                    pshs      y
                    ldy       msp.dtb,y
                    orb       V.dns,y             set bit 2 if 96tpi
                    ldy       ,s                  recover y
                    ldy       PD.RGS,y
                    pshs      y
                    clra
                    tfr       d,y
                    ldb       #SS.SREAD
                    ifeq      H6309-1
                    pshs      pc,u,y,x,dp
                    pshsw
                    pshs      d,cc
                    else
                    pshs      pc,u,y,x,dp,d,cc    push all parameters
                    endc
                    ldy       R$Size+4,s          point to path descriptor
                    sts       PD.RGS,y            save pointer to register params
                    lbsr      putstat0            call the driver
                    leas      R$Size,s
                    puls      x,y
                    stx       PD.RGS,y
                    puls      x,pc

********************************************
* Subroutine: newdate
*
* function - place the date in the FD in
*  the files directory entry
*
* On entry:
*  X points to directory entry
*  U points to stacked registers (X point to FD)
*
* On exit:
*  date and time placed in entry

newdate             pshs      d,x
                    leas      -6,s
                    ldx       <D.Proc
                    ldb       P$Task,x
                    ldx       R$X,u
                    leax      FD.DAT,x            point to new date
                    lda       #5                  size of date info
                    pshs      a,u
                    leau      3,s
newdate1            os9       F$LDABX
                    leax      1,x
                    sta       ,u+
                    dec       ,s
                    bne       newdate1
                    clr       ,u                  ..no seconds info available
                    puls      a,u
                    bra       setdate0


********************************************
* Subroutine: setdate
*
* function - place the current date and time in
*  the files directory entry
*
* On entry:
*  X points to directory entry
*
* On exit:
*  date and time placed in entry

setdate             pshs      d,x
                    leas      -6,s                reserve space for time
                    tfr       s,x
                    ldd       <D.Proc             user process
                    pshs      d
                    ldd       <D.SysPrc           system process
                    std       <D.Proc
                    os9       F$TIME
                    puls      x
                    stx       <D.Proc             fix user process
                    bcs       setdate9            ..time not set
setdate0            ldx       8,s                 point to time in directory
                    clra
                    clrb
                    std       dir.msd+msd.time,x
                    ldd       4,s                 get minutes and seconds
                    lsrb
                    andb      #%00011111
                    pshs      b
                    asla
                    asla
                    asla
                    asla
                    asla
                    ora       ,s+                 combine with part of minutes
                    sta       dir.msd+msd.time,x
                    ldd       3,s                 get hours and minutes
                    lsrb
                    lsrb
                    lsrb
                    andb      #%00000111
                    pshs      b
                    lsla
                    lsla
                    lsla
                    ora       ,s+
                    sta       dir.msd+msd.time+1,x
                    clra
                    clrb
                    std       dir.msd+msd.date,x
                    ldd       1,s                 get month and day
                    andb      #$1f
                    pshs      b
                    lsla
                    lsla
                    lsla
                    lsla
                    lsla
                    ora       ,s+
                    sta       dir.msd+msd.date,x
                    ldd       ,s                  get year and month
                    lsrb
                    lsrb
                    lsrb
                    andb      #1
                    suba      #80                 MSDOS is base 1980 not 1900
                    bcs       setdate9            ..number too low
                    pshs      b
                    lsla
                    ora       ,s+
                    sta       dir.msd+msd.date+1,x
setdate9            leas      6,s                 fix stack
                    puls      d,x,pc


*******************************************************
* Subroutine: delete
*
* function - delete a file
*
* On entry:
*  Y points to path descriptor
*  U points to stacked registers
*
* On exit:
*  Carry set and error in B if error

delete
*** rev 2.3
* lda PD.CPR,y
* sta msp.ncpr,y to lock out other processes
***
                    lda       PD.MOD,y            get access mode
                    ora       #SHARE.+WRITE.
                    sta       PD.MOD,y            make sure no one else is using file
                    dec       PD.CNT,y            ..so file will close completely
                    lbsr      open                open file
                    bcs       derror
                    ldx       msp.dir,y
                    ldb       #$E5                deleted entry mark
                    stb       dir.msd+msd.name,x
                    lda       #^attr.AR           set all but the archive bit so entry (not date) will be updated
                    sta       dir.chg,x
                    ldd       dir.msd+msd.strt,x  get starting cluster #
                    exg       a,b                 to MOTOROLA
                    cmpd      #1                  is it ROOT or entire disk?
                    bls       CantDel             ..no permission
                    ldx       msp.dtb,y
                    ldx       V.FAT,x             point to file allocation table
                    lbsr      delchain            delete the cluster chain for this file
                    lbne      close               close the file
damaged             ldb       #E$NES              ..return non-existent segment (structure damaged)
                    bra       delerr
derror              rts

CantDel             ldb       #E$FNA              file not accessible
delerr              coma                          set carry
                    lbra      closef

* return carry set if position is at end of file
iseof               ldx       msp.dir,y
                    ldb       dir.msd+msd.attr,x  get file attribute
                    bitb      #attr.DR            is it subdirectory?
                    bne       isnteof             ..yes
                    ldd       dir.msd+msd.size+2,x get MSW of file size
                    cmpa      msp.pos,y
                    blo       itiseof             ..its past end of file
                    bhi       isnteof             ..its not end of file
                    ldd       dir.msd+msd.size,x  get LSW of file size
                    exg       a,b                 convert to MOTOROLA
                    cmpd      msp.pos+1,y
                    bls       itiseof             ..its at or past end of file
isnteof             clrb
                    rts
itiseof             comb
                    rts                           .. return carry set if end of file


*****************************************************
* getstat - get file options
*
* On entry:
*  Y points to path descriptor
*  U points to stacked registers
*
* On exit:
*  Carry set and error in B if error
*  Some stacked registers changed depending on status code

getstat             ldb       R$B,u               get status code
                    cmpb      #SS.Opt
                    beq       greturn             ..return nothing
                    cmpb      #SS.Ready
                    bne       getst2              ..no
noteof              clr       R$B,u               ..return ready
greturn             rts

getst2              cmpb      #SS.EOF
                    bne       getst3
                    bsr       iseof               is it end of file?
                    bcc       noteof              ..no
                    comb
                    ldb       #E$EOF              return end of file error
                    rts

getst3              cmpb      #SS.Size            get file size
                    bne       getst4              ..no
                    ldx       msp.dir,y
                    ldd       dir.msd+msd.size,x  get LSW
                    exg       a,b
                    std       R$U,u               LSW returned in U
                    ldd       dir.msd+msd.size+2,x
                    exg       a,b
                    std       R$X,u               MSW returned in X
                    rts

getst4              cmpb      #SS.Pos             get file position
                    bne       getst5              ..no
                    ldd       msp.pos+1,y         get LSW
                    std       R$U,u
                    ldb       msp.pos,y           get MSW
                    clra
                    std       R$X,u
                    rts

getst5              cmpb      #SS.FD              get FD sector?
                    lbne      getst6              ..no
                    leas      -16,s               leave room for first part of FD sector
                    ldx       msp.dir,y
                    ldb       dir.msd+msd.attr,x  get file attribute
                    lda       #READ.+WRITE.
                    bitb      #attr.RO            read only?
                    beq       getst51             ..no
                    lda       #READ.
getst51             bitb      #attr.DR            directory?
                    beq       getst52             ..no
                    ora       #DIR.
getst52             sta       ,s                  place attribute in FD buffer
                    clra
                    clrb
                    std       1,s                 owner is user 0
                    sta       8,s                 link count is 0
                    ldd       dir.msd+msd.size,x  get LS file size
                    exg       a,b
                    std       11,s
                    ldd       dir.msd+msd.size+2,x get MS file size
                    exg       a,b
                    std       9,s
                    ldd       dir.msd+msd.time,x  get time
                    lsla
                    rolb
                    lsla
                    rolb
                    lsla
                    rolb
                    andb      #%00111111
                    stb       7,s
                    ldb       dir.msd+msd.time+1,x get hour
                    lsrb
                    lsrb
                    lsrb
                    stb       6,s
                    ldd       dir.msd+msd.date,x  get date
                    anda      #%00011111
                    sta       5,s                 day
                    sta       15,s
                    ldd       dir.msd+msd.date,x
                    lsrb
                    rora
                    lsra
                    lsra
                    lsra
                    lsra
                    sta       4,s
                    sta       14,s                month
                    lda       dir.msd+msd.date+1,x get year
                    lsra
                    adda      #80
                    sta       3,s
                    sta       13,s                year
                    ldx       <D.Proc
                    ldb       P$Task,x            get DAT task number
                    ldy       R$Y,u               get byte count
                    beq       getst58
                    ldx       R$X,u               point to FD
                    leau      16,s
                    pshs      u
                    leau      2,s
getst55             lda       ,u+
getst56             os9       F$STABX
                    leax      1,x
                    leay      -1,y
                    beq       getst57
                    cmpu      ,s                  into segment list?
                    blo       getst55             ..no
                    clra
                    bra       getst56
getst57             leas      2,s                 fix stack
getst58             leas      16,s
                    rts

getst6              cmpb      #SS.ATTR            get file attribute?
                    bne       getst7              ..no
                    ldx       msp.dir,y
                    ldb       dir.msd+msd.attr,x  get file attribute
                    stb       R$X+1,u             return attribute in LS byte of X
                    rts

getst7
getstat0            lda       #D$GSTA


***********************************************************
* CallDrvr - call a device driver subroutine
*
* On entry:
*  Y points to path descriptor
*  A is offset in subroutine dispatch table
*
* On exit:
*  carry set and error in B if error

CallDrvr            pshs      d,x,y,u
                    ldu       PD.DEV,y            point to device table
                    ldu       V$STAT,u            point to static storage
                    bra       CallDr1
CallDr0             os9       F$IOQu
CallDr1             lda       V.Busy,u            is device busy?
*** rev 2.3
* beq CallDr2
* cmpa PD.CPR,y
***
                    bne       CallDr0             ..yes, wait
CallDr2             lda       PD.CPR,y
                    sta       V.Busy,u            current process is using device
                    ldd       ,s
                    ldx       2,s
                    bsr       CallDr3             call driver subroutine
                    ldy       4,s
                    bsr       reldrvr             release driver for other's use
                    bcc       CallDr9
                    stb       1,s
CallDr9             puls      d,x,y,u,pc

CallDr3             pshs      d,x,pc
                    ldx       PD.DEV,y
                    ldd       V$DRIV,x            point to driver module
                    ldx       V$DRIV,x
                    addd      M$Exec,x            get execution offset
                    addb      ,s                  add execution offset
                    adca      #0
                    std       4,s
                    puls      d,x,pc              go do driver subroutine

* release the driver software for use by another process
* Condition Codes not affected
reldrvr             pshs      a,cc,u
                    ldu       PD.DEV,y            point to device table
                    ldu       V$STAT,u            point to static storage
*** rev 2.3
* lda PD.CPR,y
* cmpa V.Busy,u
* bne reldrvr9 ..this process doesn't control driver
* lda msp.ncpr,y
* sta V.Busy,u device is no longer busy (maybe)
***
                    clr       V.Busy,u
***
reldrvr9            puls      a,cc,u,pc


*****************************************************
* putstat - set file options
*
* On entry:
*  Y points to path descriptor
*  U points to stacked registers
*
* On exit:
*  Carry set and error in B if error
*  Some stacked registers changed depending on status code

putstat             ldb       R$B,u               get status code
                    cmpb      #SS.Opt
                    bne       putst2
                    rts

putst2              cmpb      #SS.Size            set file size?
                    bne       putst3
                    ldd       R$X,u               get MSW of new size
                    bne       putst22
                    ldd       R$U,u               get LSW of new size
                    bne       putst22
                    ldx       msp.dir,y
                    ldd       dir.msd+msd.strt,x  get starting cluster
                    exg       a,b
                    cmpd      #$FF8               last cluster in file?
                    beq       putst21             ..yes, file is right size
                    ldx       msp.dtb,y
                    ldx       V.FAT,x             point to FAT
                    lbsr      delchain            delete the file cluster chain
                    ldx       msp.dir,y
                    ldd       #$FF0F
                    std       dir.msd+msd.strt,x  set starting cluster number
                    clrb
putst21             rts
putst22             ldd       R$U,u               get LSW of new size
                    subd      #1                  convert to base 0
                    tfr       a,b
                    lda       R$X+1,u             get third byte of new size
                    sbca      #0
                    lbsr      expand0             and expand file
                    bcs       putst21
                    ldd       msp.cls,y           get last cluster number
                    ldx       msp.dtb,y
                    ldx       V.FAT,x             point to FAT
                    lbsr      findnext
                    cmpd      #$0FF8              last cluster?
                    bhs       putst24             ..yes
                    lbsr      delchain            delete remainder of chain
                    ldd       msp.cls,y
                    ldu       #$FFF
                    lbsr      updFAT              mark last cluster in file
putst24             ldu       msp.rgs,y           point to stacked params
                    ldx       msp.dir,y
                    ldd       R$U,u               get LSW
                    exg       a,b
                    std       dir.msd+msd.size,x
                    ldd       R$X,u               get MSW
                    stb       dir.msd+msd.size+2,x set new file size
                    clrb
                    rts

putst3              cmpb      #SS.FD              update file descriptor?
                    bne       putst4
                    ldx       msp.dir,y           point to directory entry
                    lbsr      newdate             get the new date
                    bra       putst65             update the directory entry

putst4              cmpb      #SS.Lock            lock/release record?
                    bne       putst5              ..no
                    rts

putst5              cmpb      #SS.Ticks           set lockout duration?
                    bne       putst6              ..no
putst55             rts

putst6              cmpb      #SS.ATTR            set file attribute?
                    bne       putst7              ..no
                    ldx       msp.dir,y
                    ldb       R$X+1,u             return attribute in LS byte of X
                    tfr       b,a
                    eorb      dir.msd+msd.attr,x
                    andb      #attr.DR            has directory changed
                    beq       putst64             ..no
                    ldb       dir.msd+msd.attr,x
                    bitb      #attr.DR            are we removing directory attribute?
                    beq       putst63             ..no
* make sure this is only path to file
                    ldd       msp.dnxt,y
                    cmpd      msp.dprv,y
                    beq       putst600            ..this is the only path to the directory
                    comb
                    ldb       #E$Share            report error, can't change to regular file
                    rts                           because another process has directory open
* make sure directory is empty
* read the first sector
putst600            ldx       msp.pos,y
                    clra
                    clrb
                    std       msp.pos,y
                    lbsr      readit
                    stx       msp.pos,y
                    bra       putst620
putst60             lbsr      secsize             get sector size
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb                          sector size / 32 = directory entries/sector
                    ldx       PD.BUF,y            point to data buffer
putst61             lda       ,x
                    beq       putst630
                    cmpa      #'.                 . or .. entry?
                    beq       putst610            ..yes, skip it
                    cmpa      #$E5                deleted?
                    lbne      permiss             ..no permission, directory not empty
putst610            leax      MSDSIZE,x           point to next entry
                    decb
                    bne       putst61             ..next sector
putst62             lbsr      readnxt
putst620            lda       #0
                    sta       msp.sest,y
                    bcc       putst60
                    cmpb      #E$EOF
                    beq       putst630            ..yes, directory is empty
                    coma                          set carry
                    rts
putst630            lda       R$X+1,u
                    ldx       msp.dir,y
                    bra       putst64
putst63             anda      #^attr.DR           make sure directory bit is clear
putst64             anda      #attr.DR+attr.AR+attr.VL+attr.SY+attr.HD+attr.RO
                    sta       dir.msd+msd.attr,x  set file attribute
putst65             ldb       dir.chg,x
                    orb       #^attr.AR           directory entry is changed
                    lbsr      writdir0            update the directory
putst69             rts

putst7              cmpb      #SS.RENAM           rename file?
                    bne       putst8              ..no
                    ldb       #11
putst71             lda       #SP
                    pshs      a
                    decb
                    bne       putst71
                    ldx       <D.Proc
                    ldb       P$Task,x            DAT task number
                    ldx       R$X,u               point to new name
                    tfr       s,u                 point to place for converted name
                    lbsr      movename
                    beq       putst79             ..bad name
                    tsta
                    bmi       putst72
                    cmpa      #SP                 space terminated?
                    bls       putst72             ..yes
                    cmpa      #',                 comma terminated?
                    beq       putst72
putst79             leas      11,s
                    comb
                    ldb       #E$BPNam            ..bad name
                    rts

putst72             pshs      y
                    os9       F$PrsNam            skip trailing spaces
                    tfr       y,x
                    puls      y
                    ldu       PD.RGS,y
                    stx       R$X,u
                    ldx       msp.dir,y
                    leax      dir.msd,x
                    ldb       msd.attr,x          get file attribute
                    bitb      #attr.DR            subdirectory?
                    beq       putst73             ..no
                    ldb       8,s                 is there a file extension?
                    cmpb      #SP
                    bne       putst79             ..yes, error
putst73             ldb       #11
putst74             puls      a
                    sta       ,x+
                    decb
                    bne       putst74             copy new directory name
                    ldx       msp.dir,y
                    bra       putst65             and update directory entry

putst8              cmpb      #SS.ALLOW           allow writes to directories and entire disk?
                    bne       putst9              ..no
                    clr       msp.wrt,y           allow writes
                    rts

putst9

putstat0            lda       #D$PSTA
                    lbra      CallDrvr            call driver putstat routine


*******************************************************
* Subroutine dispatch table

modexec
                    lbra      create
                    lbra      open
                    lbra      makdir
                    lbra      chgdir
                    lbra      delete
                    lbra      seek
                    lbra      read
                    lbra      write
                    lbra      readln
                    lbra      writeln
                    lbra      getstat
                    lbra      putstat
                    lbra      close

                    emod
modlen              equ       *
                    end
