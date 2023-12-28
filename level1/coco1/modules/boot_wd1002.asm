********************************************************************
* Boot - Eliminator WD1002-05 Boot Module
*
* $Id$
*
* WD 1002-05 OS-9 Boot Subroutine (called by OS9p1)
* Copyright 1988, 1989 Bruce Isted
* All Rights Reserved
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   2      ????/??/??  Bruce Isted
* Created.

                    nam       Boot
                    ttl       Eliminator WD1002-05 Boot Module

* These equates should be set before assembly:
FDStep              equ       $09                 see Step Rate Table
HDStep              equ       $0F                 see step rate table

*Step Rate Table:
*+------------------+------------------+------------------+------------------+
*! Value=FD/HD Rate ! Value=FD/HD Rate ! Value=FD/HD Rate ! Value=FD/HD Rate !
*+------------------+------------------+------------------+------------------+
*!  $00=40mS/7.5mS  !  $04=16mS/5.5mS  !  $08=08mS/3.5mS  !  $0C=03mS/1.5mS  !
*!  $01=25mS/7.0mS  !  $05=14mS/5.0mS  !  $09=06mS/3.0mS  !  $0D=02mS/1.0mS  !
*!  $02=20mS/6.5mS  !  $06=12mS/4.5mS  !  $0A=05mS/2.5mS  !  $0E=01mS/0.5mS  !
*!  $03=18mS/6.0mS  !  $07=10mS/4.0mS  !  $0B=04mS/2.0mS  !  $0F=15uS/ 35uS  !
*+------------------+------------------+------------------+------------------+

                    ifp1
                    use       defsfile
                    endc

* These equates should not have to be changed:
BEdtn               equ       2
BVrsn               equ       1
MaxCyls             equ       1024                maximum cylinders supported
MaxHeads            equ       16                  maximum heads supported
MaxSctrs            equ       64                  maximum sectors per track supported
PhysDrv0            equ       %10000000           SDH register mask for HD0
PhysDrv1            equ       %10001000           SDH register mask for HD1
PhysDrv2            equ       %10010000           SDH register mask for HD2
PhysDrv3            equ       %00011000           SDH register mask for FD0
PhysDrv4            equ       %00011010           SDH register mask for FD1
PhysDrv5            equ       %00011100           SDH register mask for FD2
PhysDrv6            equ       %00011110           SDH register mask for FD3
ReadSctr            equ       %00100000           read sector command
Restore             equ       %00010000           base restore command
SelfTest            equ       %10010000           WD 1002-05 diagnostic test command

* HCA memory map:
                    org       0
WDData              rmb       2                   WD 1002-05 sector buffer/task files
                    rmb       2                   reserved - do not use
PA                  equ       .                   PIA PA offset
DDRA                rmb       1                   PIA DDRA offset
CRA                 rmb       1                   PIA CRA offset
PB                  equ       .                   PIA PB offset
DDRB                rmb       1                   PIA DDRB offset
CRB                 rmb       1                   PIA CRB offset

* WD 1002-05 register definitions:
                    org       0
WDBuff              rmb       1                   WD 1002-05 sector buffer address
ErrReg              equ       .                   error register address (read)
WPCReg              rmb       1                   write precomp register address (write)
SctrCnt             rmb       1                   sector count register address
SctrReg             rmb       1                   sector number register address
CylLow              rmb       1                   cylinder LSB register address
CylHigh             rmb       1                   cylinder MSB register address
SDHReg              rmb       1                   Size/Drive/Head register address
StatReg             equ       .                   status register address (read)
CmdReg              rmb       1                   command register address (write)

                    org       0
U.BSZ               rmb       2                   boot file size
U.BSct              rmb       1                   number of sectors in boot file
U.BT                rmb       3                   boot file start LSN
U.BtStrt            rmb       2                   boot file start address
U.CrtCyl            rmb       2                   current cylinder number
U.CrtSct            rmb       1                   current sector number
U.CrtSid            rmb       1                   current side (head) number
U.Restor            rmb       1                   restore command incl. step rate code
U.SDH               rmb       1                   base WD Size/Drive/Head register copy
U.Sides             rmb       1                   number of disk sides (heads)
U.SPC               rmb       2                   sectors per cylinder
U.SPT               rmb       2                   sectors per track
U.StSctr            rmb       1                   start sector number (HD=0, FD=1)
BootMem             equ       .

                    mod       BEnd,BNam,Systm+Objct,ReEnt+BVrsn,BExec,$00
BNam                fcs       "Boot"
                    fcb       BEdtn               edition number

* base SDH register table
SDHTable            equ       *
                    fcb       PhysDrv0,PhysDrv1,PhysDrv2 base SDH for hard drives
                    fcb       PhysDrv3,PhysDrv4,PhysDrv5,PhysDrv6 base SDH for floppys
***
* Boot subroutine module
*
* INPUT: none
*
* OUTPUT: [D]=size of bootstrap file
*         [X]=start address of bootstrap file in memory
*         y,u registers altered
*
* ERROR OUTPUT: [CC]=carry set
*               [B]=error code
BExec               ldy       <D.WDAddr           get HCA base address (set by auto-boot EPROM)
                    cmpy      #$FF40              base address too low?
                    blo       UnitErr             yes, go report error...
                    cmpy      #$FF7F              base address too high?
                    bhi       UnitErr             yes, go report error...
                    lda       <D.WDBtDr           get boot drive number (set by auto-boot EPROM
                    cmpa      #$07                legal drive number?
                    blo       InitPIA             yes, go initialize PIA...
UnitErr             ldb       #E$Unit
                    coma
                    rts

DumpRead            clr       PB,y                set WD address to sector buffer
DumpR0              lda       WDData,y            get a byte from WD sector buffer
                    decb                          done yet?
                    bne       DumpR0              no, go dump another byte
                    rts
LSN0Info            ldb       #DD.FMT             load number of bytes to dump
                    bsr       DumpRead            go dump LSN0 up to DD.FMT
                    lda       WDData,y            get DD.FMT (disk density, sides)
                    anda      #$01                mask out all but disk sides bit
                    inca                          correction to bit coding
                    sta       U.Sides,u           save disk sides (not valid if HD > 2 heads)
                    ldd       WDData,y            get DD.SPT (sectors per track)
                    std       U.SPT,u
                    ldb       #DD.BT-DD.RES       load number of bytes to dump
                    bsr       DumpRead            go dump LSN0 from DD.RES to DD.BT
                    lda       WDData,y            get DD.BT (boot file start LSN) MSB
                    sta       U.BT,u
                    ldd       WDData,y            get DD.BT (boot file start LSN) LSBs
                    std       U.BT+1,u
                    ldd       WDData,y            get DD.BSZ (boot file size)
                    std       U.BSZ,u
                    ldb       U.StSctr,u          floppy drive? (start sector = 1)
                    bne       GotInfo             yes, sides info OK, go return
                    ldb       #DD.OPT+(PD.SID-PD.OPT)-DD.DAT load number of bytes to dump
                    bsr       DumpRead            go dump LSN0 from DD.DAT to number of sides in option table
                    lda       WDData,y            get number of sides from DD.OPT section
                    sta       U.Sides,u
GotInfo             rts

InitPIA             clr       CRA,y               enable PIA DDRA
                    ldd       #$033E              [A]=DDRA:  PA bits 7-2 = inputs, bits 1-0 = outputs
                    std       DDRA,y              [B]=CRA:  PIA CA2 out high, PA slct, CA1 low to high, no IRQs
                    clr       CRB,y               enable PIA DDRB
                    lda       #$FF                [A]=DDRB:  PB bits 7-0 all outputs
                    std       DDRB,y              [B]=CRB:  PIA CB2 out high, PB slct, CB1 low to high, no IRQs
                    leas      -BootMem,s          open up some space for variables
                    leau      ,s                  point [U] to start of variables
                    ldb       #BootMem            number of bytes to clear
                    leax      ,u                  point [X] to start of variables
ClrLoop             clr       ,x+                 initialize a byte to 0
                    decb                          done yet?
                    bne       ClrLoop             no, go clear another byte
                    lda       #SelfTest           WD 1002-05 internal diagnostic command
                    lbsr      CmdUpdat            go issue WD command, ensure everything is ready...
                    bcs       ReadErr             error, go report it...
                    lda       #Restore!($0F&^HDStep) default to Restore with HD step rate
                    ldb       <D.WDBtDr           get boot drive number
                    cmpb      #$03                hard drive?
                    blo       SaveRstr            yes, go save HD Restore command...
                    inc       U.StSctr,u          set start sector to 1 for floppy disks
                    lda       #Restore!($0F&^FDStep) get Restore with FD step rate
SaveRstr            sta       U.Restor,u
                    leax      SDHTable,pc
                    lda       b,x                 get base SDH register
                    sta       U.SDH,u             save it...
* restore head to track 0
                    lbsr      SetupTF             go update WD task files (except command)
                    lda       U.Restor,u          load WD restore command code
                    lbsr      CmdUpdat            go issue WD command
                    bcs       ReadErr             error, go report it...
* read cylinder 0, head 0, first sector
                    lbsr      GetSctr             go set up, issue read command
                    bcs       ReadErr             error, go report it...
                    bsr       LSN0Info            go get disk info from LSN0
                    ldd       U.BSZ,u             get boot file size/cylinder offset number
                    bne       ChkInfo             must be boot file size, go check other LSN0 info...
                    ldd       U.BT+1,u            get offset cylinder number
                    beq       ReadErr             must not be boot disk, go report error...
                    cmpd      #MaxCyls            offset cylinder number OK?
                    bhs       ReadErr             no, go return error...
                    std       U.CrtCyl,u          save offset cylinder
* read offset cylinder, head 0, first sector
                    lbsr      GetSctr             go set up, issue read command
                    bcs       ReadErr             error, go exit...
                    lbsr      LSN0Info            go get disk info from offset LSN0
                    ldd       U.BSZ,u             get boot file size
                    beq       ReadErr             must not be boot disk, go report error...
* check LSN0 info
ChkInfo             ldd       U.SPT,u             get sectors per track
                    beq       ReadErr             0 sectors per track, go return error
                    cmpd      #MaxSctrs           sectors per track OK?
                    bhi       ReadErr             no, go return error
                    lda       U.Sides,u           get disk sides (heads)
                    beq       ReadErr             0 sides, go return error
                    cmpa      #MaxHeads           number of heads OK?
                    bhi       ReadErr             no, go return error
                    mul                           calculate sectors per cylinder
                    std       U.SPC,u             save sectors per cylinder
                    ldd       U.BSZ,u             get boot file size
                    addd      #$00FF              round up to even sector...
                    sta       U.BSct,u            save number of sectors in boot file
* calculate boot file start cylinder, head, & sector
                    ldd       U.BT+1,u            get boot file LSN LSBs
                    ldx       U.CrtCyl,u          get current (offset) cylinder number
CylLoop             subd      U.SPC,u             subtract sectors/cylinder
                    blo       ChkBtMSB            [D] underflow, go check boot file LSN MSB
CylLoop0            leax      1,x                 increment current cylinder number
                    bne       CylLoop             no overflow, go do another subtraction
ReadErr             ldb       #E$Read
                    coma                          set Carry for error
                    leas      BootMem,s           restore stack pointer
                    rts
ChkBtMSB            tst       U.BT,u              boot file LSN MSB = 0?
                    beq       GotCyl              yes, go determine head number
                    dec       U.BT,u              decrement boot file LSN MSB
                    bra       CylLoop0            go on...
GotCyl              addd      U.SPC,u             restore sector number
                    stx       U.CrtCyl,u          save current cylinder number
TrkLoop             subd      U.SPT,u             subtract sectors/track
                    blo       GotSide             [D] underflow, go save current sector number
                    inc       U.CrtSid,u          increment current side number
                    bra       TrkLoop             go do another subtraction
GotSide             addd      U.SPT,u             restore sector number
                    stb       U.CrtSct,u          save it
* request boot file memory
                    pshs      u                   save data pointer
                    ldd       U.BSZ,u             get boot file size
                    os9       F$SRqMem
                    tfr       u,x                 move start address into [X]
                    puls      u                   recover data pointer
                    bcs       BtExit0             go return F$SRqMem error
                    stx       U.BtStrt,u          save boot file start address
                    ldd       U.CrtCyl,u          get cylinder number
                    bra       ChkCyl              go check cylinder & get first sector

* load boot file into memory
BootLoad            inc       U.CrtSct,u          move on to next sector
                    lda       U.SPT+1,u           get sectors per track LSB (MSB is always 0)
                    cmpa      U.CrtSct,u          done track?
                    bhi       LoadSctr            no, go get sector
                    clr       U.CrtSct,u          reset current sector number to 0
                    inc       U.CrtSid,u          move on to next side
                    lda       U.CrtSid,u          get side number
                    cmpa      U.Sides,u           done cylinder?
                    blo       LoadSctr            no, go get sector
                    clr       U.CrtSid,u          reset side number to 0
                    ldd       U.CrtCyl,u          get cylinder number
                    addd      #1                  move on to next cylinder
                    std       U.CrtCyl,u          save cylinder number
ChkCyl              cmpd      #MaxCyls            cylinder number OK?
                    bhs       ReadErr             no, go return error
LoadSctr            bsr       GetSctr             go get current sector from WD 1002-05
                    bcs       ReadErr             error, go exit
                    clrb                          transfer 256 bytes
                    stb       PB,y                set WD sector buffer address
ReadLoop            lda       WDData,y            get byte from WD 1002-05
                    sta       ,x+                 save byte to buffer
                    decb                          done yet?
                    bne       ReadLoop            no, go get another byte
                    dec       U.BSct,u            count down boot file sectors remaining
                    bne       BootLoad
                    clrb                          clear carry
                    ldd       U.BSZ,u             get boot file size
                    ldx       U.BtStrt,u          get boot file start address
BtExit0             leas      BootMem,s           restore stack pointer
                    rts

GetSctr             bsr       SetupTF             go set up WD task files (except command)
                    lda       #ReadSctr           load WD read sector command code
CmdUpdat            ldb       #CmdReg             load WD command register address
                    bsr       TFUpdat             go issue command...
BusyWait            ldb       #StatReg
                    stb       PB,y                set WD status register address
BusyW0              ldb       WDData,y            get WD 1002-05 status
                    bitb      #%00000010          valid data?  (WD 1002-05 powered & connected?)
                    bne       BWErr               no, go report error...
                    tstb                          ensure [CC] sign flag is current
                    bmi       BusyW0              yes, go check again
                    ldb       WDData,y            get valid controller status
                    rorb                          rotate error bit into carry
                    bcc       NoError
                    ldb       #ErrReg
                    stb       PB,y                set WD error register address
                    ldb       WDData,y            get error register contents
                    bne       BWErr
NoError             clrb
                    rts
BWErr               comb                          error, set [CC] Carry...
                    rts

SetupTF             ldd       #$01*256+SctrCnt    single sector commands only
                    bsr       TFUpdat
                    lda       U.CrtCyl,u          get current cylinder number MSB
                    ldb       #CylHigh
                    bsr       TFUpdat
                    lda       U.CrtCyl+1,u        get current cylinder number LSB
                    ldb       #CylLow
                    bsr       TFUpdat
                    lda       U.CrtSct,u          get current sector number
                    adda      U.StSctr,u          add offset...
                    ldb       #SctrReg
                    bsr       TFUpdat
                    clrb                          default extended head disabled
                    lda       U.CrtSid,u          get current side (head) number
                    cmpa      #$08                extended head?
                    blo       StdHead             no, go on...
                    incb                          set enable code
                    anda      #$07                mask out all but standard head number
StdHead             stb       PA,y                set extended head enable/disable
                    ora       U.SDH,u             mask in base SDH copy
                    ldb       #SDHReg
TfUpdat             stb       PB,y                set WD register address
                    sta       WDData,y            write data to WD 1002-05
                    rts

                    ifgt      Level-1
* L2 kernel file is composed of rel, boot, krn. The size of each of these
* is controlled with filler, so that (after relocation):
* rel  starts at $ED00 and is $130 bytes in size
* boot starts at $EE30 and is $1D0 bytes in size
* krn  starts at $F000 and ends at $FEFF (there is no 'emod' at the end
*      of krn and so there are no module-end boilerplate bytes)
*
* Filler to get to a total size of $1D0. 3 represents bytes after
* the filler: the end boilerplate for the module.
Filler              fill      $39,$1D0-3-*
                    endc

                    emod
BEnd                equ       *
                    end
