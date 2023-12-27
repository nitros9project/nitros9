********************************************************************
* Disasm - 6809/6309 disassembler
*
* $Id$
*
* Disasm v1.5 (c) 1988 by Ron Lammardo
* 6309 additions by L. Curtis Boyle Jan. 1993
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   2      1987/03/12  Ron Lammardo
* Added code for line,address,obj display added options 'o' and 'x'.
*
*   3      1987/04/02  Ron Lammardo
* Added code to provide commented disassembly of device descriptors.
*
*   4      1987/11/16  Ron Lammardo
* Fixed restart link failure, added code to display direct page addresses.
*
*   5      1988/02/22  Ron Lammardo
* Added code to display dp/u offsets; added code to display fcb bytes
* preceding eom; added code for z option (hex input disassembly);
* added code to display date/time run
*
*          1993/01/23  L. Curtis Boyle
* Added code to handle 6309 instruction set additions
*
*          2003/04/22  Rodney V. Hamilton
* Added 4-digit year output.
*
*          2003/07/09  Rodney V. Hamilton
* Changed output format of 6309 Bit commands.
*
*          2003/08/14  Rodney V. Hamilton
* Added code to output "end" line
*
*          2004/03/11  Rodney V. Hamilton
* Updated TFM register selection
*
*          2004/07/15  Robert Gault
* Added code to indicate manual start and end for disassembly.
*
*          2004/08/08  Robert Gault
* Changed getbyte routine to make "in memory" and disk i/o synchronize.
* This also required a slight change to gotmod. Added testing so that manual
* end/stop can't exceed module length. Almost have L lables working in Label
* field. If there should be lables and you don't see them, use the s option
* with s$0004$length_of_module. Then you should be able to use any values
* for start/stop and the L labels will still be present.
* Change in z option required by change in getbyte.
* S option uses fake data size. Added minor changes suggested by R.V.H.
*
*         2005/10/13  Robert Gault
* Forced to shrink labeltab size so that os9boot could be disassembled.
*   6     2019/07/25  L. Curtis Boyle
* Fixed bug where PSHU/PULU would try and push/pull U onto itself. (chk.f7)
* Also, changed edition # since _so_ many changes (including 6309 support)
*  have been added since edition 5
*   6r1   2020/12/08  L. Curtis Boyle
* Added I$ModDsc to I/O SWI2 call names

                    nam       Disasm
                    ttl       6809/6309 disassembler

                    ifp1
                    use       defsfile
                    endc

typ                 set       Prgrm+Objct
attrev              set       ReEnt+revision
revision            set       $01
edtn                set       6                   edition
edition             equ       $30+edtn            ascii edition

                    mod       eom,mname,typ,attrev,start,datend

pcrzero             equ       *-$0D               module start

mname               fcs       /Disasm/
                    fcb       edtn

dfltdrv             fcc       /dd/
cr                  set       C$CR
**** start of data area ****
stackhld            rmb       2
ureghold            rmb       2
xreghold            rmb       2
xsave               rmb       2
dsave               rmb       2
startadr            rmb       2
modadr              rmb       2
s_start             rmb       2                   for manual start & stop
s_end               rmb       2
address             rmb       2
addrsave            rmb       2
lineadr             rmb       2
objadr              rmb       2
crntadr             rmb       2
modend              rmb       2
nameadr             rmb       2
size                rmb       2
temp                rmb       2
readpos             rmb       2
readcnt             rmb       1
readclr             rmb       1
byte                rmb       1
TFMFlag             rmb       1                   Flag to indicate processing TFM
bitcom              rmb       1                   Flag to indicate processing bit instruction
indirct             rmb       1
hexstrng            rmb       4
decstrng            rmb       5
testbyte            rmb       1
register            rmb       1
labladr             rmb       2
highadr             rmb       2
utabend             rmb       2
path                rmb       1
pass                rmb       1
diskio              rmb       1
objcnt              rmb       1
tylghold            rmb       1
atrvhold            rmb       1
revshold            rmb       1
m.opt               rmb       1
o.opt               rmb       1
s.opt               rmb       1                   manual start & stop RG
x.opt               rmb       1
z.opt               rmb       1
u.opt               rmb       1
op.cnt              rmb       1
descript            rmb       1
mgradr              rmb       2
drvadr              rmb       2
desctype            rmb       1
printadr            rmb       2
initsize            rmb       2
counter             rmb       1
countdec            rmb       2
numline             rmb       2
runtime             rmb       6
* start of output line
linenum             rmb       8
holdadr             rmb       5
holdobj             rmb       11
holdline            rmb       56
* end of output line
holdname            rmb       32
namehold            rmb       32
hldtylg             rmb       40
hldatrv             rmb       40
hldrev              rmb       40
hldttl              rmb       40
pathlist            rmb       80
readbuff            rmb       20
labeltab            rmb       $1D0C
lbtblend            rmb       1
                    rmb       255
datend              equ       .

*****************************************
**   os9 call tables                   **
**   (sequence = $10,$3f,..)           **
*****************************************
os9f$tab            equ       *
                    fcc       /F$Link  /
                    fcc       /F$Load  /
                    fcc       /F$UnLink/
                    fcc       /F$Fork  /
                    fcc       /F$Wait  /
                    fcc       /F$Chain /
                    fcc       /F$Exit  /
                    fcc       /F$Mem   /
                    fcc       /F$Send  /
                    fcc       /F$Icpt  /
                    fcc       /F$Sleep /
                    fcc       /F$SSpd  /
                    fcc       /F$ID    /
                    fcc       /F$SPrior/
                    fcc       /F$SSWI  /
                    fcc       /F$PErr  /
                    fcc       /F$PrsNam/
                    fcc       /F$CmpNam/
                    fcc       /F$SchBit/
                    fcc       /F$AllBit/
                    fcc       /F$DelBit/
                    fcc       /F$Time  /
                    fcc       /F$STime /
                    fcc       /F$CRC   /
                    fcc       /F$GPrDsc/
                    fcc       /F$GBlkMp/
                    fcc       /F$GModDr/
                    fcc       /F$CpyMem/
                    fcc       /F$SUser /
                    fcc       /F$UnLoad/
                    fcc       /F$Alarm /
                    fcc       /????????/
                    fcc       /????????/
                    fcc       /F$NMLink/
                    fcc       /F$NMLoad/
                    fcc       /????????/
                    fcc       /????????/
* Rodney pointed this out as a bug
*         fcc    /????????/
                    fcc       /F$TPS   /
                    fcc       /F$TimAlm/
                    fcc       /F$VIRQ  /
                    fcc       /F$SRqMem/
                    fcc       /F$SRtMem/
                    fcc       /F$IRQ   /
                    fcc       /F$IOQu  /
                    fcc       /F$AProc /
                    fcc       /F$NProc /
                    fcc       /F$VModul/
                    fcc       /F$Find64/
                    fcc       /F$All64 /
                    fcc       /F$Ret64 /
                    fcc       /F$SSvc  /
                    fcc       /F$IODel /
                    fcc       /F$SLink /
                    fcc       /F$Boot  /
                    fcc       /F$BtMem /
                    fcc       /F$GProcP/
                    fcc       /F$Move  /
                    fcc       /F$AllRAM/
                    fcc       /F$AllImg/
                    fcc       /F$DelImg/
                    fcc       /F$SetImg/
                    fcc       /F$FreeLB/
                    fcc       /F$FreeHB/
                    fcc       /F$AllTsk/
                    fcc       /F$DelTsk/
                    fcc       /F$SetTsk/
                    fcc       /F$ResTsk/
                    fcc       /F$RelTsk/
                    fcc       /F$DATLog/
                    fcc       /F$DATTmp/
                    fcc       /F$LDAXY /
                    fcc       /F$LDAXYP/
                    fcc       /F$LDDDXY/
                    fcc       /F$LDABX /
                    fcc       /F$STABX /
                    fcc       /F$AllPrc/
                    fcc       /F$DelPrc/
                    fcc       /F$ELink /
                    fcc       /F$FModul/
                    fcc       /F$MapBlk/
                    fcc       /F$ClrBlk/
                    fcc       /F$DelRAM/
                    fcc       /F$GCMDir/
                    fcc       /F$AlHRAM/

os9i$tab            equ       *
                    fcc       /I$Attach/
                    fcc       /I$Detach/
                    fcc       /I$Dup   /
                    fcc       /I$Create/
                    fcc       /I$Open  /
                    fcc       /I$MakDir/
                    fcc       /I$ChgDir/
                    fcc       /I$Delete/
                    fcc       /I$Seek  /
                    fcc       /I$Read  /
                    fcc       /I$Write /
                    fcc       /I$ReadLn/
                    fcc       /I$WritLn/
                    fcc       /I$GetStt/
                    fcc       /I$SetStt/
                    fcc       /I$Close /
                    fcc       /I$DeletX/
                    fcc       /I$ModDsc/
bados9op            fcc       /????????/

* Mnemonic table: 1st byte =Opcode
*                 2nd byte =Flags to indicate mode type of opcode
*                Bytes 3-7 =Mnemonic name of opcode
*****************************************
**  2 byte table -                     **
**  $10 is first byte of op code       **
*****************************************
get10tab            equ       *
                    fcb       $21
                    fcb       $fc
                    fcc       /lbrn /
                    fcb       $22
                    fcb       $fc
                    fcc       /lbhi /
                    fcb       $23
                    fcb       $fc
                    fcc       /lbls /
                    fcb       $24
                    fcb       $fc
                    fcc       /lbcc /
                    fcb       $25
                    fcb       $fc
                    fcc       /lbcs /
                    fcb       $26
                    fcb       $fc
                    fcc       /lbne /
                    fcb       $27
                    fcb       $fc
                    fcc       /lbeq /
                    fcb       $28
                    fcb       $fc
                    fcc       /lbvc /
                    fcb       $29
                    fcb       $fc
                    fcc       /lbvs /
                    fcb       $2a
                    fcb       $fc
                    fcc       /lbpl /
                    fcb       $2b
                    fcb       $fc
                    fcc       /lbmi /
                    fcb       $2c
                    fcb       $fc
                    fcc       /lbge /
                    fcb       $2d
                    fcb       $fc
                    fcc       /lblt /
                    fcb       $2e
                    fcb       $fc
                    fcc       /lbgt /
                    fcb       $2f
                    fcb       $fc
                    fcc       /lble /
* Test of 6309 codes
                    fcb       $30
                    fcb       $fa
                    fcc       /addr /
                    fcb       $31
                    fcb       $fa
                    fcc       /adcr /
                    fcb       $32
                    fcb       $fa
                    fcc       /subr /
                    fcb       $33
                    fcb       $fa
                    fcc       /sbcr /
                    fcb       $34
                    fcb       $fa
                    fcc       /andr /
                    fcb       $35
                    fcb       $fa
                    fcc       /orr  /
                    fcb       $36
                    fcb       $fa
                    fcc       /eorr /
                    fcb       $37
                    fcb       $fa
                    fcc       /cmpr /
                    fcb       $38
                    fcb       $fd
                    fcc       /pshsw/
                    fcb       $39
                    fcb       $fd
                    fcc       /pulsw/
                    fcb       $3a
                    fcb       $fd
                    fcc       /pshuw/
                    fcb       $3b
                    fcb       $fd
                    fcc       /puluw/
                    fcb       $40
                    fcb       $fd
                    fcc       /negd /
                    fcb       $43
                    fcb       $fd
                    fcc       /comd /
                    fcb       $44
                    fcb       $fd
                    fcc       /lsrd /
                    fcb       $46
                    fcb       $fd
                    fcc       /rord /
                    fcb       $47
                    fcb       $fd
                    fcc       /asrd /
                    fcb       $48
                    fcb       $fd
                    fcc       /asld /
                    fcb       $49
                    fcb       $fd
                    fcc       /rold /
                    fcb       $4a
                    fcb       $fd
                    fcc       /decd /
                    fcb       $4c
                    fcb       $fd
                    fcc       /incd /
                    fcb       $4d
                    fcb       $fd
                    fcc       /tstd /
                    fcb       $4f
                    fcb       $fd
                    fcc       /clrd /
                    fcb       $53
                    fcb       $fd
                    fcc       /comw /
                    fcb       $54
                    fcb       $fd
                    fcc       /lsrw /
                    fcb       $56
                    fcb       $fd
                    fcc       /rorw /
                    fcb       $59
                    fcb       $fd
                    fcc       /rolw /
                    fcb       $5a
                    fcb       $fd
                    fcc       /decw /
                    fcb       $5c
                    fcb       $fd
                    fcc       /incw /
                    fcb       $5d
                    fcb       $fd
                    fcc       /tstw /
                    fcb       $5f
                    fcb       $fd
                    fcc       /clrw /
                    fcb       $80
                    fcb       $f3
                    fcc       /subw /
                    fcb       $81
                    fcb       $f3
                    fcc       /cmpw /
                    fcb       $82
                    fcb       $f3
                    fcc       /sbcd /
                    fcb       $83
                    fcb       $f3
                    fcc       /cmpd /
                    fcb       $84
                    fcb       $f3
                    fcc       /andd /
                    fcb       $85
                    fcb       $f3
                    fcc       /bitd /
                    fcb       $86
                    fcb       $f3
                    fcc       /ldw  /
                    fcb       $88
                    fcb       $f3
                    fcc       /eord /
                    fcb       $89
                    fcb       $f3
                    fcc       /adcd /
                    fcb       $8a
                    fcb       $f3
                    fcc       /ord  /
                    fcb       $8b
                    fcb       $f3
                    fcc       /addw /
                    fcb       $8c
                    fcb       $f3
                    fcc       /cmpy /
                    fcb       $8e
                    fcb       $f3
                    fcc       /ldy  /
                    fcb       $90
                    fcb       $ff
                    fcc       /subw /
                    fcb       $91
                    fcb       $ff
                    fcc       /cmpw /
                    fcb       $92
                    fcb       $ff
                    fcc       /sbcd /
                    fcb       $93
                    fcb       $ff
                    fcc       /cmpd /
                    fcb       $94
                    fcb       $ff
                    fcc       /andd /
                    fcb       $95
                    fcb       $ff
                    fcc       /bitd /
                    fcb       $96
                    fcb       $ff
                    fcc       /ldw  /
                    fcb       $97
                    fcb       $ff
                    fcc       /stw  /
                    fcb       $98
                    fcb       $ff
                    fcc       /eord /
                    fcb       $99
                    fcb       $ff
                    fcc       /adcd /
                    fcb       $9a
                    fcb       $ff
                    fcc       /ord  /
                    fcb       $9b
                    fcb       $ff
                    fcc       /addw /
                    fcb       $9c
                    fcb       $ff
                    fcc       /cmpy /
                    fcb       $9e
                    fcb       $ff
                    fcc       /ldy  /
                    fcb       $9f
                    fcb       $ff
                    fcc       /sty  /
                    fcb       $a0
                    fcb       $f8
                    fcc       /subw /
                    fcb       $a1
                    fcb       $f8
                    fcc       /cmpw /
                    fcb       $a2
                    fcb       $f8
                    fcc       /sbcd /
                    fcb       $a3
                    fcb       $f8
                    fcc       /cmpd /
                    fcb       $a4
                    fcb       $f8
                    fcc       /andd /
                    fcb       $a5
                    fcb       $f8
                    fcc       /bitd /
                    fcb       $a6
                    fcb       $f8
                    fcc       /ldw  /
                    fcb       $a7
                    fcb       $f8
                    fcc       /stw  /
                    fcb       $a8
                    fcb       $f8
                    fcc       /eord /
                    fcb       $a9
                    fcb       $f8
                    fcc       /adcd /
                    fcb       $aa
                    fcb       $f8
                    fcc       /ord  /
                    fcb       $ab
                    fcb       $f8
                    fcc       /addw /
                    fcb       $ac
                    fcb       $f8
                    fcc       /cmpy /
                    fcb       $ae
                    fcb       $f8
                    fcc       /ldy  /
                    fcb       $af
                    fcb       $f8
                    fcc       /sty  /
                    fcb       $b0
                    fcb       $f4
                    fcc       /subw /
                    fcb       $b1
                    fcb       $f4
                    fcc       /cmpw /
                    fcb       $b2
                    fcb       $f4
                    fcc       /sbcd /
                    fcb       $b3
                    fcb       $f4
                    fcc       /cmpd /
                    fcb       $b4
                    fcb       $f4
                    fcc       /andd /
                    fcb       $b5
                    fcb       $f4
                    fcc       /bitd /
                    fcb       $b6
                    fcb       $f4
                    fcc       /ldw  /
                    fcb       $b7
                    fcb       $f4
                    fcc       /stw  /
                    fcb       $b8
                    fcb       $f4
                    fcc       /eord /
                    fcb       $b9
                    fcb       $f4
                    fcc       /adcd /
                    fcb       $ba
                    fcb       $f4
                    fcc       /ord  /
                    fcb       $bb
                    fcb       $f4
                    fcc       /addw /
                    fcb       $bc
                    fcb       $f4
                    fcc       /cmpy /
                    fcb       $be
                    fcb       $f4
                    fcc       /ldy  /
                    fcb       $bf
                    fcb       $f4
                    fcc       /sty  /
                    fcb       $ce
                    fcb       $f3
                    fcc       /lds  /
                    fcb       $dc
                    fcb       $ff
                    fcc       /ldq  /
                    fcb       $dd
                    fcb       $ff
                    fcc       /stq  /
                    fcb       $de
                    fcb       $ff
                    fcc       /lds  /
                    fcb       $df
                    fcb       $ff
                    fcc       /sts  /
                    fcb       $ec
                    fcb       $f8
                    fcc       /ldq  /
                    fcb       $ed
                    fcb       $f8
                    fcc       /stq  /
                    fcb       $ee
                    fcb       $f8
                    fcc       /lds  /
                    fcb       $ef
                    fcb       $f8
                    fcc       /sts  /
                    fcb       $fc
                    fcb       $f4
                    fcc       /ldq  /
                    fcb       $fd
                    fcb       $f4
                    fcc       /stq  /
                    fcb       $fe
                    fcb       $f4
                    fcc       /lds  /
                    fcb       $ff
                    fcb       $f4
                    fcc       /sts  /
                    fcb       $00
                    fcb       $fe
                    fcc       /fcb  /
                    pag
*****************************************
**  2 byte table -                     **
**  $11 is first byte of op code       **
*****************************************
get11tab            equ       *
                    fcb       $30
                    fcb       $f0
                    fcc       /band /
                    fcb       $31
                    fcb       $f0
                    fcc       /biand/
                    fcb       $32
                    fcb       $f0
                    fcc       /bor  /
                    fcb       $33
                    fcb       $f0
                    fcc       /bior /
                    fcb       $34
                    fcb       $f0
                    fcc       /beor /
                    fcb       $35
                    fcb       $f0
                    fcc       /bieor/
                    fcb       $36
                    fcb       $f0
                    fcc       /ldbt /
                    fcb       $37
                    fcb       $f0
                    fcc       /stbt /
                    fcb       $38
                    fcb       $fa
                    fcc       /tfm  /
                    fcb       $39
                    fcb       $fa
                    fcc       /tfm  /
                    fcb       $3a
                    fcb       $fa
                    fcc       /tfm  /
                    fcb       $3b
                    fcb       $fa
                    fcc       /tfm  /
                    fcb       $3c
                    fcb       $fb
                    fcc       /bitmd/
                    fcb       $3d
                    fcb       $fb
                    fcc       /ldmd /
                    fcb       $3f
                    fcb       $fd
                    fcc       /swi3 /
                    fcb       $43
                    fcb       $fd
                    fcc       /come /
                    fcb       $4a
                    fcb       $fd
                    fcc       /dece /
                    fcb       $4c
                    fcb       $fd
                    fcc       /ince /
                    fcb       $4d
                    fcb       $fd
                    fcc       /tste /
                    fcb       $4f
                    fcb       $fd
                    fcc       /clre /
                    fcb       $53
                    fcb       $fd
                    fcc       /comf /
                    fcb       $5a
                    fcb       $fd
                    fcc       /decf /
                    fcb       $5c
                    fcb       $fd
                    fcc       /incf /
                    fcb       $5d
                    fcb       $fd
                    fcc       /tstf /
                    fcb       $5f
                    fcb       $fd
                    fcc       /clrf /
                    fcb       $80
                    fcb       $fb
                    fcc       /sube /
                    fcb       $81
                    fcb       $fb
                    fcc       /cmpe /
                    fcb       $83
                    fcb       $f3
                    fcc       /cmpu /
                    fcb       $86
                    fcb       $fb
                    fcc       /lde  /
                    fcb       $8b
                    fcb       $fb
                    fcc       /adde /
                    fcb       $8c
                    fcb       $f3
                    fcc       /cmps /
                    fcb       $8d
                    fcb       $fb
                    fcc       /divd /
                    fcb       $8e
                    fcb       $f3
                    fcc       /divq /
                    fcb       $8f
                    fcb       $f3
                    fcc       /muld /
                    fcb       $90
                    fcb       $ff
                    fcc       /sube /
                    fcb       $91
                    fcb       $ff
                    fcc       /cmpe /
                    fcb       $93
                    fcb       $ff
                    fcc       /cmpu /
                    fcb       $96
                    fcb       $ff
                    fcc       /lde  /
                    fcb       $97
                    fcb       $ff
                    fcc       /ste  /
                    fcb       $9b
                    fcb       $ff
                    fcc       /adde /
                    fcb       $9c
                    fcb       $ff
                    fcc       /cmps /
                    fcb       $9d
                    fcb       $ff
                    fcc       /divd /
                    fcb       $9e
                    fcb       $ff
                    fcc       /divq /
                    fcb       $9f
                    fcb       $ff
                    fcc       /muld /
                    fcb       $a0
                    fcb       $f8
                    fcc       /sube /
                    fcb       $a1
                    fcb       $f8
                    fcc       /cmpe /
                    fcb       $a3
                    fcb       $f8
                    fcc       /cmpu /
                    fcb       $a6
                    fcb       $f8
                    fcc       /lde  /
                    fcb       $a7
                    fcb       $f8
                    fcc       /ste  /
                    fcb       $ab
                    fcb       $f8
                    fcc       /adde /
                    fcb       $ac
                    fcb       $f8
                    fcc       /cmps /
                    fcb       $ad
                    fcb       $f8
                    fcc       /divd /
                    fcb       $ae
                    fcb       $f8
                    fcc       /divq /
                    fcb       $af
                    fcb       $f8
                    fcc       /muld /
                    fcb       $b0
                    fcb       $f4
                    fcc       /sube /
                    fcb       $b1
                    fcb       $f4
                    fcc       /cmpe /
                    fcb       $b3
                    fcb       $f4
                    fcc       /cmpu /
                    fcb       $b6
                    fcb       $f4
                    fcc       /lde  /
                    fcb       $b7
                    fcb       $f4
                    fcc       /ste  /
                    fcb       $bb
                    fcb       $f4
                    fcc       /adde /
                    fcb       $bc
                    fcb       $f4
                    fcc       /cmps /
                    fcb       $bd
                    fcb       $f4
                    fcc       /divd /
                    fcb       $be
                    fcb       $f4
                    fcc       /divq /
                    fcb       $bf
                    fcb       $f4
                    fcc       /muld /
                    fcb       $c0
                    fcb       $fb
                    fcc       /subf /
                    fcb       $c1
                    fcb       $fb
                    fcc       /cmpf /
                    fcb       $c6
                    fcb       $fb
                    fcc       /ldf  /
                    fcb       $cb
                    fcb       $fb
                    fcc       /addf /
                    fcb       $d0
                    fcb       $ff
                    fcc       /subf /
                    fcb       $d1
                    fcb       $ff
                    fcc       /cmpf /
                    fcb       $d6
                    fcb       $ff
                    fcc       /ldf  /
                    fcb       $d7
                    fcb       $ff
                    fcc       /stf  /
                    fcb       $db
                    fcb       $ff
                    fcc       /addf /
                    fcb       $e0
                    fcb       $f8
                    fcc       /subf /
                    fcb       $e1
                    fcb       $f8
                    fcc       /cmpf /
                    fcb       $e6
                    fcb       $f8
                    fcc       /ldf  /
                    fcb       $e7
                    fcb       $f8
                    fcc       /stf  /
                    fcb       $eb
                    fcb       $f8
                    fcc       /addf /
                    fcb       $f0
                    fcb       $f4
                    fcc       /subf /
                    fcb       $f1
                    fcb       $f4
                    fcc       /cmpf /
                    fcb       $f6
                    fcb       $f4
                    fcc       /ldf  /
                    fcb       $f7
                    fcb       $f4
                    fcc       /stf  /
                    fcb       $fb
                    fcb       $f4
                    fcc       /addf /
                    fcb       $00                 Unknown gets FCB's
                    fcb       $fe
                    fcc       /fcb  /
                    pag
*****************************************
**  1 byte op code table               **
*****************************************
* Position in table is opcode, byte stored there is how to interpret it
* Interpreter bytes are:
* $FF: Direct page mode (1 byte address)
* $FE: FCB (unknown single byte)
* $FD: Implied (single byte by itself)
* $FC: 2 byte relative
* $FB: 1 byte immediate
* $FA: Dual register (EXG/TFR)
* $F9: 1 byte relative
* $F8: Indexed (1 or more post bytes)
* $F7: Stack (PSH/PUL) register post-byte
* $F6: ??? (internal use?)
* $F5: SWI???
* $F4: Extended (2 byte address)
* $F3: 2 byte immediate
* $F2: 4 byte immediate
* $F1: In memory (AIM, etc.)
* $F0: Bit commands (LDBT, etc.)
optable             fcb       $00
tab0x               equ       *
                    fcb       $ff                 =00
                    fcc       /neg  /
                    fcb       $f1                 =01
                    fcc       /oim  /
                    fcb       $f1                 =02
                    fcc       /aim  /
                    fcb       $ff                 =03
                    fcc       /com  /
                    fcb       $ff                 =04
                    fcc       /lsr  /
                    fcb       $f1                 =05
                    fcc       /eim  /
                    fcb       $ff                 =06
                    fcc       /ror  /
                    fcb       $ff                 =07
                    fcc       /asr  /
                    fcb       $ff                 =08
                    fcc       /lsl  /
                    fcb       $ff                 =09
                    fcc       /rol  /
                    fcb       $ff                 =0a
                    fcc       /dec  /
                    fcb       $f1                 =0b
                    fcc       /tim  /
                    fcb       $ff                 =0c
                    fcc       /inc  /
                    fcb       $ff                 =0d
                    fcc       /tst  /
                    fcb       $ff                 =0e
                    fcc       /jmp  /
                    fcb       $ff                 =0f
                    fcc       /clr  /
tab1x               equ       *
                    fcb       $fe                 =10        Unused entry; pre-byte
                    fcc       /fcb  /
                    fcb       $fe                 =11        Unused entry; pre-byte
                    fcc       /fcb  /
                    fcb       $fd                 =12
                    fcc       /nop  /
                    fcb       $fd                 =13
                    fcc       /sync /
                    fcb       $fd                 =14
                    fcc       /sexw /
                    fcb       $fe                 =15
                    fcc       /fcb  /
                    fcb       $fc                 =16
                    fcc       /lbra /
                    fcb       $fc                 =17
                    fcc       /lbsr /
                    fcb       $fe                 =18
                    fcc       /fcb  /
                    fcb       $fd                 =19
                    fcc       /daa  /
                    fcb       $fb                 =1a
                    fcc       /orcc /
                    fcb       $fe                 =1b
                    fcc       /fcb  /
                    fcb       $fb                 =1c
                    fcc       /andcc/
                    fcb       $fd                 =1d
                    fcc       /sex  /
                    fcb       $fa                 =1e
                    fcc       /exg  /
                    fcb       $fa                 =1f
                    fcc       /tfr  /
tab2x               equ       *
                    fcb       $f9                 =20
                    fcc       /bra  /
                    fcb       $f9                 =21
                    fcc       /brn  /
                    fcb       $f9                 =22
                    fcc       /bhi  /
                    fcb       $f9                 =23
                    fcc       /bls  /
                    fcb       $f9                 =24
                    fcc       /bcc  /
                    fcb       $f9                 =25
                    fcc       /bcs  /
                    fcb       $f9                 =26
                    fcc       /bne  /
                    fcb       $f9                 =27
                    fcc       /beq  /
                    fcb       $f9                 =28
                    fcc       /bvc  /
                    fcb       $f9                 =29
                    fcc       /bvs  /
                    fcb       $f9                 =2a
                    fcc       /bpl  /
                    fcb       $f9                 =2b
                    fcc       /bmi  /
                    fcb       $f9                 =2c
                    fcc       /bge  /
                    fcb       $f9                 =2d
                    fcc       /blt  /
                    fcb       $f9                 =2e
                    fcc       /bgt  /
                    fcb       $f9                 =2f
                    fcc       /ble  /
tab3x               equ       *
                    fcb       $f8                 =30
                    fcc       /leax /
                    fcb       $f8                 =31
                    fcc       /leay /
                    fcb       $f8                 =32
                    fcc       /leas /
                    fcb       $f8                 =33
                    fcc       /leau /
                    fcb       $f7                 =34
                    fcc       /pshs /
                    fcb       $f7                 =35
                    fcc       /puls /
                    fcb       $f7                 =36
                    fcc       /pshu /
                    fcb       $f7                 =37
                    fcc       /pulu /
                    fcb       $fe                 =38
                    fcc       /fcb  /
                    fcb       $fd                 =39
                    fcc       /rts  /
                    fcb       $fd                 =3a
                    fcc       /abx  /
                    fcb       $fd                 =3b
                    fcc       /rti  /
                    fcb       $fb                 =3c
                    fcc       /cwai /
                    fcb       $fd                 =3d
                    fcc       /mul  /
                    fcb       $fe                 =3e
                    fcc       /fcb  /
                    fcb       $f5                 =3f
                    fcc       /swi  /
tab4x               equ       *
                    fcb       $fd                 =40
                    fcc       /nega /
                    fcb       $fe                 =41
                    fcc       /fcb  /
                    fcb       $fe                 =42
                    fcc       /fcb  /
                    fcb       $fd                 =43
                    fcc       /coma /
                    fcb       $fd                 =44
                    fcc       /lsra /
                    fcb       $fe                 =45
                    fcc       /fcb  /
                    fcb       $fd                 =46
                    fcc       /rora /
                    fcb       $fd                 =47
                    fcc       /asra /
                    fcb       $fd                 =48
                    fcc       /lsla /
                    fcb       $fd                 =49
                    fcc       /rola /
                    fcb       $fd                 =4a
                    fcc       /deca /
                    fcb       $fe                 =4b
                    fcc       /fcb  /
                    fcb       $fd                 =4c
                    fcc       /inca /
                    fcb       $fd                 =4d
                    fcc       /tsta /
                    fcb       $fe                 =4e
                    fcc       /fcb  /
                    fcb       $fd                 =4f
                    fcc       /clra /
tab5x               equ       *
                    fcb       $fd                 =50
                    fcc       /negb /
                    fcb       $fe                 =51
                    fcc       /fcb  /
                    fcb       $fe                 =52
                    fcc       /fcb  /
                    fcb       $fd                 =53
                    fcc       /comb /
                    fcb       $fd                 =54
                    fcc       /lsrb /
                    fcb       $fe                 =55
                    fcc       /fcb  /
                    fcb       $fd                 =56
                    fcc       /rorb /
                    fcb       $fd                 =57
                    fcc       /asrb /
                    fcb       $fd                 =58
                    fcc       /lslb /
                    fcb       $fd                 =59
                    fcc       /rolb /
                    fcb       $fd                 =5a
                    fcc       /decb /
                    fcb       $fe                 =5b
                    fcc       /fcb  /
                    fcb       $fd                 =5c
                    fcc       /incb /
                    fcb       $fd                 =5d
                    fcc       /tstb /
                    fcb       $fe                 =5e
                    fcc       /fcb  /
                    fcb       $fd                 =5f
                    fcc       /clrb /
tab6x               equ       *
                    fcb       $f8                 =60
                    fcc       /neg  /
                    fcb       $f1                 =61
                    fcc       /oim  /
                    fcb       $f1                 =62
                    fcc       /aim  /
                    fcb       $f8                 =63
                    fcc       /com  /
                    fcb       $f8                 =64
                    fcc       /lsr  /
                    fcb       $f1                 =65
                    fcc       /eim  /
                    fcb       $f8                 =66
                    fcc       /ror  /
                    fcb       $f8                 =67
                    fcc       /asr  /
                    fcb       $f8                 =68
                    fcc       /lsl  /
                    fcb       $f8                 =69
                    fcc       /rol  /
                    fcb       $f8                 =6a
                    fcc       /dec  /
                    fcb       $f1                 =6b
                    fcc       /tim  /
                    fcb       $f8                 =6c
                    fcc       /inc  /
                    fcb       $f8                 =6d
                    fcc       /tst  /
                    fcb       $f8                 =6e
                    fcc       /jmp  /
                    fcb       $f8                 =6f
                    fcc       /clr  /
tab7x               equ       *
                    fcb       $f4                 =70
                    fcc       /neg  /
                    fcb       $f1                 =71
                    fcc       /oim  /
                    fcb       $f1                 =72
                    fcc       /aim  /
                    fcb       $f4                 =73
                    fcc       /com  /
                    fcb       $f4                 =74
                    fcc       /lsr  /
                    fcb       $f1                 =75
                    fcc       /eim  /
                    fcb       $f4                 =76
                    fcc       /ror  /
                    fcb       $f4                 =77
                    fcc       /asr  /
                    fcb       $f4                 =78
                    fcc       /lsl  /
                    fcb       $f4                 =79
                    fcc       /rol  /
                    fcb       $f4                 =7a
                    fcc       /dec  /
                    fcb       $f1                 =7b
                    fcc       /tim  /
                    fcb       $f4                 =7c
                    fcc       /inc  /
                    fcb       $f4                 =7d
                    fcc       /tst  /
                    fcb       $f4                 =7e
                    fcc       /jmp  /
                    fcb       $f4                 =7f
                    fcc       /clr  /
tab8x               equ       *
                    fcb       $fb                 =80
                    fcc       /suba /
                    fcb       $fb                 =81
                    fcc       /cmpa /
                    fcb       $fb                 =82
                    fcc       /sbca /
                    fcb       $f3                 =83
                    fcc       /subd /
                    fcb       $fb                 =84
                    fcc       /anda /
                    fcb       $fb                 =85
                    fcc       /bita /
                    fcb       $fb                 =86
                    fcc       /lda  /
                    fcb       $fe                 =87
                    fcc       /fcb  /
                    fcb       $fb                 =88
                    fcc       /eora /
                    fcb       $fb                 =89
                    fcc       /adca /
                    fcb       $fb                 =8a
                    fcc       /ora  /
                    fcb       $fb                 =8b
                    fcc       /adda /
                    fcb       $f3                 =8c
                    fcc       /cmpx /
                    fcb       $f9                 =8d
                    fcc       /bsr  /
                    fcb       $f3                 =8e
                    fcc       /ldx  /
                    fcb       $fe                 =8f
                    fcc       /fcb  /
tab9x               equ       *
                    fcb       $ff                 =90
                    fcc       /suba /
                    fcb       $ff                 =91
                    fcc       /cmpa /
                    fcb       $ff                 =92
                    fcc       /sbca /
                    fcb       $ff                 =93
                    fcc       /subd /
                    fcb       $ff                 =94
                    fcc       /anda /
                    fcb       $ff                 =95
                    fcc       /bita /
                    fcb       $ff                 =96
                    fcc       /lda  /
                    fcb       $ff                 =97
                    fcc       /sta  /
                    fcb       $ff                 =98
                    fcc       /eora /
                    fcb       $ff                 =99
                    fcc       /adca /
                    fcb       $ff                 =9a
                    fcc       /ora  /
                    fcb       $ff                 =9b
                    fcc       /adda /
                    fcb       $ff                 =9c
                    fcc       /cmpx /
                    fcb       $ff                 =9d
                    fcc       /jsr  /
                    fcb       $ff                 =9e
                    fcc       /ldx  /
                    fcb       $ff                 =9f
                    fcc       /stx  /
tabax               equ       *
                    fcb       $f8                 =a0
                    fcc       /suba /
                    fcb       $f8                 =a1
                    fcc       /cmpa /
                    fcb       $f8                 =a2
                    fcc       /sbca /
                    fcb       $f8                 =a3
                    fcc       /subd /
                    fcb       $f8                 =a4
                    fcc       /anda /
                    fcb       $f8                 =a5
                    fcc       /bita /
                    fcb       $f8                 =a6
                    fcc       /lda  /
                    fcb       $f8                 =a7
                    fcc       /sta  /
                    fcb       $f8                 =a8
                    fcc       /eora /
                    fcb       $f8                 =a9
                    fcc       /adca /
                    fcb       $f8                 =aa
                    fcc       /ora  /
                    fcb       $f8                 =ab
                    fcc       /adda /
                    fcb       $f8                 =ac
                    fcc       /cmpx /
                    fcb       $f8                 =ad
                    fcc       /jsr  /
                    fcb       $f8                 =ae
                    fcc       /ldx  /
                    fcb       $f8                 =af
                    fcc       /stx  /
tabbx               equ       *
                    fcb       $f4                 =b0
                    fcc       /suba /
                    fcb       $f4                 =b1
                    fcc       /cmpa /
                    fcb       $f4                 =b2
                    fcc       /sbca /
                    fcb       $f4                 =b3
                    fcc       /subd /
                    fcb       $f4                 =b4
                    fcc       /anda /
                    fcb       $f4                 =b5
                    fcc       /bita /
                    fcb       $f4                 =b6
                    fcc       /lda  /
                    fcb       $f4                 =b7
                    fcc       /sta  /
                    fcb       $f4                 =b8
                    fcc       /eora /
                    fcb       $f4                 =b9
                    fcc       /adca /
                    fcb       $f4                 =ba
                    fcc       /ora  /
                    fcb       $f4                 =bb
                    fcc       /adda /
                    fcb       $f4                 =bc
                    fcc       /cmpx /
                    fcb       $f4                 =bd
                    fcc       /jsr  /
                    fcb       $f4                 =be
                    fcc       /ldx  /
                    fcb       $f4                 =bf
                    fcc       /stx  /
tabcx               equ       *
                    fcb       $fb                 =c0
                    fcc       /subb /
                    fcb       $fb                 =c1
                    fcc       /cmpb /
                    fcb       $fb                 =c2
                    fcc       /sbcb /
                    fcb       $f3                 =c3
                    fcc       /addd /
                    fcb       $fb                 =c4
                    fcc       /andb /
                    fcb       $fb                 =c5
                    fcc       /bitb /
                    fcb       $fb                 =c6
                    fcc       /ldb  /
                    fcb       $fe                 =c7
                    fcc       /fcb  /
                    fcb       $fb                 =c8
                    fcc       /eorb /
                    fcb       $fb                 =c9
                    fcc       /adcb /
                    fcb       $fb                 =ca
                    fcc       /orb  /
                    fcb       $fb                 =cb
                    fcc       /addb /
                    fcb       $f3                 =cc
                    fcc       /ldd  /
                    fcb       $f2                 =cd
                    fcc       /ldq  /
                    fcb       $f3                 =ce
                    fcc       /ldu  /
                    fcb       $fe                 =cf
                    fcc       /fcb  /
tabdx               equ       *
                    fcb       $ff                 =d0
                    fcc       /subb /
                    fcb       $ff                 =d1
                    fcc       /cmpb /
                    fcb       $ff                 =d2
                    fcc       /sbcb /
                    fcb       $ff                 =d3
                    fcc       /addd /
                    fcb       $ff                 =d4
                    fcc       /andb /
                    fcb       $ff                 =d5
                    fcc       /bitb /
                    fcb       $ff                 =d6
                    fcc       /ldb  /
                    fcb       $ff                 =d7
                    fcc       /stb  /
                    fcb       $ff                 =d8
                    fcc       /eorb /
                    fcb       $ff                 =d9
                    fcc       /adcb /
                    fcb       $ff                 =da
                    fcc       /orb  /
                    fcb       $ff                 =db
                    fcc       /addb /
                    fcb       $ff                 =dc
                    fcc       /ldd  /
                    fcb       $ff                 =dd
                    fcc       /std  /
                    fcb       $ff                 =de
                    fcc       /ldu  /
                    fcb       $ff                 =df
                    fcc       /stu  /
tabex               equ       *
                    fcb       $f8                 =e0
                    fcc       /subb /
                    fcb       $f8                 =e1
                    fcc       /cmpb /
                    fcb       $f8                 =e2
                    fcc       /sbcb /
                    fcb       $f8                 =e3
                    fcc       /addd /
                    fcb       $f8                 =e4
                    fcc       /andb /
                    fcb       $f8                 =e5
                    fcc       /bitb /
                    fcb       $f8                 =e6
                    fcc       /ldb  /
                    fcb       $f8                 =e7
                    fcc       /stb  /
                    fcb       $f8                 =e8
                    fcc       /eorb /
                    fcb       $f8                 =e9
                    fcc       /adcb /
                    fcb       $f8                 =ea
                    fcc       /orb  /
                    fcb       $f8                 =eb
                    fcc       /addb /
                    fcb       $f8                 =ec
                    fcc       /ldd  /
                    fcb       $f8                 =ed
                    fcc       /std  /
                    fcb       $f8                 =ee
                    fcc       /ldu  /
                    fcb       $f8                 =ef
                    fcc       /stu  /
tabfx               equ       *
                    fcb       $f4                 =f0
                    fcc       /subb /
                    fcb       $f4                 =f1
                    fcc       /cmpb /
                    fcb       $f4                 =f2
                    fcc       /sbcb /
                    fcb       $f4                 =f3
                    fcc       /addd /
                    fcb       $f4                 =f4
                    fcc       /andb /
                    fcb       $f4                 =f5
                    fcc       /bitb /
                    fcb       $f4                 =f6
                    fcc       /ldb  /
                    fcb       $f4                 =f7
                    fcc       /stb  /
                    fcb       $f4                 =f8
                    fcc       /eorb /
                    fcb       $f4                 =f9
                    fcc       /adcb /
                    fcb       $f4                 =fa
                    fcc       /orb  /
                    fcb       $f4                 =fb
                    fcc       /addb /
                    fcb       $f4                 =fc
                    fcc       /ldd  /
                    fcb       $f4                 =fd
                    fcc       /std  /
                    fcb       $f4                 =fe
                    fcc       /ldu  /
                    fcb       $f4                 =ff
                    fcc       /stu  /
                    pag


testing             equ       0                   (0=no,1=yes)
regtab              fcc       /d x y u s pcw v a b ccdp0 0 e f /
stackreg            fcc       /pcu y x dpb a cc/
ustckreg            fcc       /pcs y x dpb a cc/
timesplt            fcc       '// :: '
title               equ       *
                    fcc       /program module       /
                    fcc       /subroutine module    /
                    fcc       /multi-module         /
                    fcc       /data module          /
                    fcc       /os9 system module    /
                    fcc       /os9 file manager     /
                    fcc       /os9 device driver    /
                    fcc       /os9 device descriptor/
badindx             fcc       /?????????????????????/
devtype             equ       *
                    fcc       /Prgrm/
                    fcc       /Sbrtn/
                    fcc       /Multi/
                    fcc       / Data/
                    fcc       /Systm/
                    fcc       /FlMgr/
                    fcc       /Drivr/
                    fcc       /Devic/
                    fcc       /?????/
language            equ       *
                    fcc       /Objct   /
                    fcc       /ICode   /
                    fcc       /PCode   /
                    fcc       /CCode   /
                    fcc       /CblCode /
                    fcc       /FrtnCode/
                    fcc       /???????? /
reent.              fcc       /ReEnt /
modprot.            fcc       /Modprot /
line010             fcc       /         ifp1/
line011             fcb       $0d
ln010sz             equ       *-line010
line020             fcc       %         use   /%
ln020sz             equ       *-line020
line025             fcc       %/defs/defsfile%
                    fcb       $0d
ln025sz             equ       *-line025
line030             fcc       /         endc/
                    fcb       $0d
ln030sz             equ       *-line030
line040             fcc       /                    /
                    fcc       /                    /
                    fcc       /                    /
                    fcc       /                    /

line050             fcc       /         mod   /
                    fcc       /eom,name,tylg,/
                    fcc       /atrv,start,size/
                    fcb       $0d
ln050sz             equ       *-line050
line060             fcc       %fcs   /%
ln060sz             equ       *-line060
line070             fcc       /u0000    rmb   /
ln070sz             equ       *-line070
line080             fcc       /<u/
line085             fcc       /<$/
line090             fcc       /fcb   $/
ln090sz             equ       *-line090
line100             fcc       /name     equ   */
ln100sz             equ       *-line100
line110             fcc       /         rmb   /
ln110sz             equ       *-line110
line120             fcc       /size     equ   ./
                    fcb       $0d
ln120sz             equ       *-line120
line130             fcc       /start    equ   */
                    fcb       $0d
ln130sz             equ       *-line130
line140             fcc       /swi2/
ln140sz             equ       *-line140
line150             fcc       /os9   /
ln150sz             equ       *-line150
line160             fcc       /         ttl   /
ln160sz             equ       *-line160
line170             fcc       /         emod/
                    fcb       $0d
ln170sz             equ       *-line170
line180             fcc       /eom      equ   */
                    fcb       $0d
ln180sz             equ       *-line180
line181             fcc       /         end/
                    fcb       $0d
ln181sz             equ       *-line181
line190             fcc       /equ   */
ln190sz             equ       *-line190
line200             fcb       $0a
                    fcc       /error: can't link to module/
                    fcb       $0d
ln200sz             equ       *-line200
line210             fcc       /* Disassembled /
ln210sz             equ       *-line210
line215             fcc       /by Disasm v1./
                    fcb       edition
                    fcc       / (C) 1988 by RML/
ln215sz             equ       *-line215
line220             fcc       /,pcr/
ln220sz             equ       *-line220
line230             fcb       $0a
                    fcc       /* entries in symbol table :$/
ln230sz             equ       *-line230
line240             fcb       $0a
                    fcb       $0a
                    fcc       /error: symbol table full/
                    fdb       $070d
ln240sz             equ       *-line240
line250             fcb       $0a
                    fcb       $0a
                    fcc       /error: illegal option/
                    fdb       $070d
ln250sz             equ       *-line250
line260             fcb       $0a
                    fcc       %error: no module/path name found%
                    fcb       $0a
                    fcc       /use Disasm -? for help/
                    fdb       $070d
ln260sz             equ       *-line260
line270             fcb       $0a
                    fcc       /  Disasm v1./
                    fcb       edition
                    fcc       / (for 6809 & 6309 code) options:/
                    fcb       $0a
                    fcc       /  Disasm -m modname/
                    fcb       $0a
                    fcc       /    will link to module 'modname' -/
                    fcc       / if not found,will load module/
                    fcb       $0a
                    fcb       $0a
                    fcc       /  Disasm modname/
                    fcb       $0a
                    fcc       /    will 'read' the module from the/
                    fcc       / specified path without loading/
                    fcb       $0a,$0a
                    fcc       /  Disasm -z {hex data}/
                    fcb       $0a
                    fcc       /    will disassemble the data input on the comand line/
                    fcb       $0a
                    fcc       /    as if it were part of a module in memory/
                    fcb       $0a,$0a
                    fcc       /  other options:/
                    fcb       $0a
                    fcc       /    o = display line number,address,object code & source code/
                    fcb       $0a
                    fcc       /    s = indicate disassembly start & end/
                    fcb       $0a
                    fcc       /        syntax   -s$ssss$eeee/
                    fcb       $0a
                    fcc       /    x = take modules from execution directory/
                    fcb       $0a
                    fcc       '    u = do not convert u/dp offsets to symbolic labels'
                    fcb       $0a,$0a
                    fcc       /  any combination of options is allowed (lower or upper case)/
                    fcb       $0a
                    fcc       /    but they must immediately follow the '-' and there must be/
                    fcb       $0a
                    fcc       /    no spaces separating options./
                    fcb       $0a
ln270sz             equ       *-line270
line280             fcc       /         nam   /
ln280sz             equ       *-line280
line290             fcc       /tylg     set   /
ln290sz             equ       *-line290
line300             fcc       /atrv     set   /
ln300sz             equ       *-line300
line310             fcc       /rev      set   $/
ln310sz             equ       *-line310
line320             fcc       /+rev/
ln320sz             equ       *-line320
line330             fcc       /         mod   /
                    fcc       /eom,name,tylg,/
                    fcc       /atrv,mgrnam,drvnam/
                    fcb       $0d
ln330sz             equ       *-line330

line340             fcc       /mode byte/
ln340sz             equ       *-line340
line350             fcc       /extended controller address/
ln350sz             equ       *-line350
line360             fcc       / physical controller address/
ln360sz             equ       *-line360
line370             fcc       /fdb   $/
ln370sz             equ       *-line370
line380             fcc       /fcb   initsize-*-1  initilization table size/
ln380sz             equ       *-line380
line390             fcc       /device type:0=scf,1=rbf,2=pipe,3=scf/
ln390sz             equ       *-line390
line400             fcc       /initsize equ   */
ln400sz             equ       *-line400
line410             fcc       /mgrnam   equ   */
ln410sz             equ       *-line410
line420             fcc       /drvnam   equ   */
ln420sz             equ       *-line420
line430             fcc       /fdb   name copy of descriptor name address/
ln430sz             equ       *-line430
rbfprint            fcc       /1drive number/
                    fcb       cr
                    fcc       /1step rate/
                    fcb       cr
                    fcc       /1drive device type/
                    fcb       cr
                    fcc       /1media density:0=single,1=double/
                    fcb       cr
                    fcc       /2number of cylinders (tracks)/
                    fcb       cr
                    fcc       /1number of sides/
                    fcb       cr
                    fcc       /1verify disk writes:0=on/
                    fcb       cr
                    fcc       /2# of sectors per track/
                    fcb       cr
                    fcc       /2# of sectors per track (track 0)/
                    fcb       cr
                    fcc       /1sector interleave factor/
                    fcb       cr
                    fcc       /1minimum size of sector allocation/
                    fcb       cr
                    fcc       /1?/
                    fcb       cr

scfprint            equ       *
                    fcc       /1case:0=up&lower,1=upper only/
                    fcb       cr
                    fcc       /1backspace:0=bsp,1=bsp then sp & bsp/
                    fcb       cr
                    fcc       /1delete:0=bsp over line,1=return/
                    fcb       cr
                    fcc       /1echo:0=no echo/
                    fcb       cr
                    fcc       /1auto line feed:0=off/
                    fcb       cr
*
                    fcc       /1end of line null count/
                    fcb       cr
                    fcc       /1pause:0=no end of page pause/
                    fcb       cr
                    fcc       /1lines per page/
                    fcb       cr
                    fcc       /1backspace character/
                    fcb       cr
                    fcc       /1delete line character/
                    fcb       cr
                    fcc       /1end of record character/
                    fcb       cr
                    fcc       /1end of file character/
                    fcb       cr
                    fcc       /1reprint line character/
                    fcb       cr
                    fcc       /1duplicate last line character/
                    fcb       cr
                    fcc       /1pause character/
                    fcb       cr
                    fcc       /1interrupt character/
                    fcb       cr
                    fcc       /1quit character/
                    fcb       cr
                    fcc       /1backspace echo character/
                    fcb       cr
                    fcc       /1line overflow character (bell)/
                    fcb       cr
                    fcc       /1init value for dev ctl reg/
                    fcb       cr
                    fcc       /1baud rate/
                    fcb       cr
                    fcc       /3/
                    fcc       /1acia xon char/
                    fcb       cr
                    fcc       /1acia xoff char/
                    fcb       cr
                    fcc       /1(szx) number of columns for display/
                    fcb       cr
                    fcc       /1(szy) number of rows for display/
                    fcb       cr
                    fcc       /1window number/
                    fcb       cr
                    fcc       /1data in rest of descriptor valid/
                    fcb       cr
                    fcc       /1(sty) window type/
                    fcb       cr
                    fcc       /1(cpx) x cursor position/
                    fcb       cr
                    fcc       /1(cpy) y cursor position/
                    fcb       cr
                    fcc       /1(prn1) foreground color/
                    fcb       cr
                    fcc       /1(prn2) background color/
                    fcb       cr
                    fcc       /1(prn3) border color/
                    fcb       cr
scfpend             fcc       /1?/
                    fcb       cr
*        use    /dd/defs/usr/usrall

start               equ       *
                    sts       <stackhld           save the stack address for later
                    stx       <xreghold
                    stu       <ureghold
                    cmpd      #2
                    bhs       pathok
                    leax      line260,pcr
                    ldy       #ln260sz
                    lbra      prterror
pathok              equ       *
                    leax      labeltab,u
                    stx       <labladr
                    clra
                    clrb
                    std       ,x++                clear two bytes of a buffer
*         sta   ,x+
*         sta   ,x+
                    leax      -500,s              this takes 500 bytes away from the label buffer
*        leax  labeltab+40,u
                    stx       <utabend            and makes that the end of the buffer
                    ldd       #$ffff
                    std       ,x
* new
                    ldd       #0
                    std       ,--x
                    stx       <highadr
*         leax  -2,x
*         stx   <highadr
*         ldd   #0
*         std   ,x
                    std       <pass               reordered data to accommodate this RG
                    std       <m.opt
                    std       <s.opt
                    std       <z.opt
                    std       <op.cnt
*         clr   <pass
*         clr   <diskio
*         clr   <m.opt
*         clr   <o.opt
*         clr   <s.opt           manual start & stop RG
*         clr   <x.opt
*         clr   <z.opt
*         clr   <u.opt
*         clr   <op.cnt
*         clr   <descript
                    lbsr      clrline

restart             equ       *
                    clr       <readcnt
                    clr       <readclr
                    leax      readbuff,u
                    stx       <readpos
                    ldd       #0
                    std       <numline
                    tst       <pass
                    beq       rest2
                    tst       <s.opt              for manual start & stop RG
                    beq       rest2
                    ldx       <s_start
                    stx       <startadr
                    ldx       <s_end              prevent overflow past end of module
                    cmpx      <modend
                    bhi       sopt1
                    bra       rest3
rest2               ldx       #$ffff
rest3               stx       <modend
sopt1               ldx       <xreghold
                    tst       <pass
                    lbeq      getprm
                    lbsr      clrline
                    tst       <s.opt              for manual start & stop to prevent print of
                    bne       sopt2               meaningless text RG
                    leay      line280,pcr
                    ldb       #ln280sz
                    lbsr      mergline
                    leay      holdname,u
                    ldb       #$44
                    lbsr      mergline
                    lbsr      writline
                    leay      hldttl,u
                    ldb       #40
                    lbsr      mergline
                    lbsr      writline
                    lbsr      writline
sopt2               leax      holdobj,u
                    tst       <o.opt
                    bne       time010
                    leax      holdline,u
time010
                    stx       <lineadr
                    leay      line210,pcr
                    ldb       #ln210sz
                    lbsr      mergline
                    leax      runtime,u
                    os9       F$Time              get time
                    lbcs      exit
                    lda       #6
                    sta       <temp
                    leay      timesplt,pcr
* patch to output 4-digit year
                    ldb       ,x+
                    clra
                    addd      #1900
                    pshs      x
                    pshs      y
                    lbsr      mergdec
                    bra       time025
time020
                    ldb       ,x+
                    clra
                    pshs      x
                    pshs      y
                    leay      decstrng,u
                    lbsr      getdec
                    leay      decstrng+3,u
                    ldb       #2
                    lbsr      mergline
time025
                    puls      y
                    lda       ,y+
                    lbsr      movechar
                    puls      x
                    dec       <temp
                    bne       time020
                    leay      line215,pcr
                    ldb       #ln215sz
                    lbsr      mergline
                    lbsr      writline
                    lbsr      writline

                    leay      line010,pcr
                    ldb       #ln010sz
                    lbsr      mergline
                    lbsr      writline
                    leay      line020,pcr
                    ldb       #ln020sz
                    lbsr      mergline
                    leay      dfltdrv,pcr
                    ldb       #2
                    lbsr      mergline
                    leay      line025,pcr
                    ldb       #ln025sz
                    lbsr      mergline
                    lbsr      writline
                    leay      line030,pcr
                    ldb       #ln030sz
                    lbsr      mergline
                    lbsr      writline
                    tst       <s.opt              for manual start & stop, don't print junk RG
                    bne       sopt3
                    ldb       <tylghold
                    bsr       movehdr
                    leay      hldtylg,u
                    ldb       #$50
                    lbsr      mergline
                    lbsr      writline
                    ldb       <atrvhold
                    bsr       movehdr
                    leay      hldatrv,u
                    ldb       #$50
                    lbsr      mergline
                    lbsr      writline
                    ldb       <revshold
                    bsr       movehdr
                    leay      hldrev,u
                    ldb       #$50
                    lbsr      mergline
                    lbsr      writline
sopt3               ldx       <xreghold
                    tst       <diskio
                    lbne      diskmod
                    lbra      mem020

movehdr             equ       *
                    clra
                    lbsr      gethex
                    leax      holdadr,u
                    leay      hexstrng,u
                    ldb       #4
                    lbsr      merge
                    rts

getprm              lda       ,x+
                    cmpa      #$20
                    beq       getprm
                    leax      -1,x
                    stx       <xreghold
                    cmpa      #'-
                    lbne      diskmod
                    leax      1,x
getopt              equ       *
                    lda       ,x+
                    sta       <byte
                    anda      #$df
                    cmpa      #'M
                    bne       gtopt010
                    inc       <m.opt
                    inc       <op.cnt
                    bra       getopt
gtopt010            cmpa      #'O
                    bne       gtopt020
                    inc       <o.opt
                    inc       <op.cnt
                    bra       getopt
gtopt020            equ       *
                    cmpa      #'X
                    bne       gtopt030
                    inc       <x.opt
                    inc       <op.cnt
                    bra       getopt

gtopt030            equ       *
                    cmpa      #'Z
                    bne       gtopt040
                    inc       <z.opt
                    inc       <op.cnt
                    bra       getopt

gtopt040            equ       *
                    cmpa      #'U
                    bne       gtopt050
                    inc       <u.opt
                    inc       <op.cnt
                    bra       getopt

gtopt050            equ       *
                    cmpa      #'S                 add start & stop option RG
                    bne       gtopt060
                    bsr       gtoptS
                    bcs       badopt
                    std       <s_start
                    bsr       gtoptS
                    bcs       badopt
                    addd      #3
                    std       <s_end
                    inc       <s.opt
                    inc       <op.cnt
                    lbra      getopt
gtoptS              lda       ,x+                 for manual start & stop RG
                    cmpa      #$20
                    beq       gtoptS
                    cmpa      #'$
                    bne       gtoptS2
                    lbsr      u$hexin
                    clrb
                    ldd       ,x
                    leax      4,x
                    rts
gtoptS2             equ       *
                    comb
                    rts

gtopt060            equ       *
                    lda       <byte
                    cmpa      #'?
                    bne       chkopt
                    leax      line270,pcr
                    ldy       #ln270sz
                    lbra      prterror
chkopt              equ       *
                    tst       <z.opt
                    beq       optest
                    lbsr      u$hexin             convert hex chars to binary
                    leay      3,y
                    sty       <modend
*         leax  -1,x             because of changes to getbyte
                    stx       <crntadr
                    ldd       #$FFFF
                    std       <address
                    lda       #1
                    sta       <pass
                    leax      line011,pcr
                    ldy       #1
                    lda       #1
                    os9       I$WritLn
                    lbcs      exit
                    lbra      readbyte            go start doing it!!!

optest              tst       <op.cnt
                    bne       memmod
badopt              equ       *
                    leax      line250,pcr
                    ldy       #ln250sz
                    lbra      prterror
diskmod             equ       *
                    inc       <diskio
                    lda       #READ.
                    tst       <x.opt
                    beq       open
                    ora       #EXEC.
open                os9       I$Open
                    lbcs      exit
                    sta       <path
*         lbsr  getbyte       no longer needed, RG
                    bra       gotmod

memmod              equ       *
mem010              lda       ,x+
                    cmpa      #$20
                    beq       mem010
                    leax      -1,x
                    stx       <xreghold
                    tst       <m.opt
                    beq       diskmod

mem020              equ       *
                    clra
                    os9       F$Link
                    bcc       gotmod
                    clra
                    ldx       <xreghold
                    os9       F$Load
                    lbcs      nolink
gotmod              equ       *
                    stu       <modadr
                    stu       <crntadr
                    ldu       <ureghold
                    ldx       #-1                 was $0, RG
                    stx       <address
                    tst       <pass               new     RG
                    beq       gotmod2
                    tst       <s.opt              for manual start & stop RG
                    bne       gotmod3
gotmod2             lbsr      getbyte2            make memory and disk in sync, RG
*        lbsr  getbyte           no longer needed
                    lbsr      getbyte2
                    std       <modend
gotmod3             lbsr      clrline
                    tst       <s.opt              prevent printing junk with s option
                    lbne      gotmod4
                    lda       #$87
                    lbsr      moveobj
                    lda       #$cd
                    lbsr      moveobj
                    ldd       <modend
                    lbsr      moveobj
                    ldd       <modend
                    tfr       b,a
                    lbsr      moveobj
                    leay      holdadr,u
                    lda       #'0                 Store 4 ASCII 0's
                    sta       ,y+
                    sta       ,y+
                    sta       ,y+
                    sta       ,y+
                    leay      line050,pcr
                    ldb       #ln050sz
                    tst       <descript
                    beq       prtmod
                    leay      line330,pcr
                    ldb       #ln330sz
prtmod              equ       *
                    lbsr      mergline
                    lbsr      writline
                    lbsr      getbyte2
                    std       <nameadr
                    leay      hldtylg,u
                    lbsr      clrhld
                    leay      line290,pcr
                    ldb       #ln290sz
                    lbsr      mergline
                    lbsr      getbyte
                    stb       <tylghold
                    andb      #TypeMask
                    tstb
                    beq       badtype
                    cmpb      #$40
                    bls       goodtype
                    cmpb      #$c0
                    bhs       goodtype
badtype             equ       *
                    lbsr      mvchr005
                    lbsr      merghex
                    bra       chklang
goodtype            equ       *
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    cmpb      #$0c
                    blo       type010
                    subb      #$7
                    cmpb      #8
                    bne       type010
                    inc       <descript
type010             subb      #1
                    stb       <testbyte
                    lda       #$5
                    mul
                    leay      devtype,pcr
                    leay      d,y
                    ldb       #5
                    lbsr      mergline
chklang             equ       *
                    lbsr      mvchr008
                    ldb       <byte
                    andb      #LangMask
                    tstb
                    beq       badlang
                    cmpb      #6
                    bls       goodlang
badlang             equ       *
                    lbsr      mvchr005
                    lbsr      merghex
                    bra       lang010
goodlang            equ       *
                    subb      #1
                    leay      language,pcr
                    lda       #8
                    mul
                    leay      d,y
                    ldb       #8
                    lbsr      mergline
lang010             equ       *
                    lda       #$0d
                    lbsr      movechar
chkattr             equ       *
                    leay      hldttl,u
                    lbsr      clrhld
                    leay      line160,pcr
                    ldb       #ln160sz
                    lbsr      mergline
                    ldb       <testbyte
                    lda       #$15
                    mul
                    leay      title,pcr
                    leay      d,y
                    ldb       #$15
                    lbsr      mergline
                    lda       #$0d
                    lbsr      movechar
                    leay      hldatrv,u
                    lbsr      clrhld
                    leay      line300,pcr
                    ldb       #ln300sz
                    lbsr      mergline
                    lbsr      getbyte
                    stb       <atrvhold
                    andb      #AttrMask
                    cmpb      #ReEnt
                    beq       attr.r
                    cmpb      #ModProt
                    beq       attr.m
                    lbsr      mvchr005
                    lbsr      merghex
                    bra       chkrevs
attr.r              equ       *
                    leay      reent.,pcr
                    ldb       #5
                    bra       moveattr
attr.m              equ       *
                    leay      modprot.,pcr
                    ldb       #7
moveattr            lbsr      mergline
chkrevs             leay      line320,pcr
                    ldb       #ln320sz
                    lbsr      mergline
                    lda       #$0d
                    lbsr      movechar
                    leay      hldrev,u
                    lbsr      clrhld
                    leay      line310,pcr
                    ldb       #ln310sz
                    lbsr      mergline
                    ldb       <byte
                    andb      #RevsMask
                    stb       revshold
                    lbsr      merghex
                    lda       #$0d
                    lbsr      movechar
                    lbsr      getbyte
                    tst       <descript
                    lbne      descrhdr
                    lbsr      getbyte2
                    std       <startadr
                    lbsr      getbyte2
gotmod4             tst       <s.opt
                    beq       gotmod5
                    ldd       #$3D0C-510          fake data size
gotmod5             std       <size
                    ldx       <utabend
                    std       ,x
                    lbsr      clrline
* Next line was in code but does nothing RG
*         tst   <pass
*        lbra  findname

                    ldx       <address
                    stx       <addrsave
                    ldx       <highadr
                    tst       <u.opt
                    beq       movedp
                    ldx       <utabend
*         leax  -2,x
                    clra
                    clrb
                    std       ,--x

movedp              equ       *
                    ldd       ,x++
                    pshs      x
                    std       <address
                    lbsr      adrmove
                    leay      line070,pcr
                    ldb       #ln070sz
                    lbsr      mergline
                    leay      linenum,u
                    lda       #'D
                    sta       6,y
                    leax      holdadr,u
                    leay      25,y
                    ldb       #4
                    exg       x,y
                    lbsr      merge
                    puls      x
                    ldd       ,x
                    subd      -2,x
                    pshs      x
                    lbsr      mergdec
                    lbsr      writline
                    puls      x
                    ldd       ,x
                    cmpd      <size
                    bne       movedp

                    ldd       <size
                    lbsr      gethex
                    leay      hexstrng,u
                    leax      holdadr,u
                    ldb       #4
                    lbsr      merge
                    leay      linenum,u
                    leay      6,y
                    lda       #'D
                    sta       ,y
                    leay      line120,pcr
                    ldb       #ln120sz
                    lbsr      mergline
                    lbsr      writline
                    ldx       <addrsave
                    stx       <address
                    tst       <s.opt
                    lbne      getstart

findname            equ       *
                    lbsr      getbyte
                    ldx       <nameadr
                    cmpx      <address
                    beq       getname
                    lbsr      fcbline
                    bra       findname

getname             equ       *
                    lbsr      clrline
                    lbsr      adrmove
                    leay      line100,pcr
                    ldb       #ln100sz
                    lbsr      mergline
                    lbsr      writline
                    leay      holdname,u
                    lbsr      movename
getstart            equ       *
                    ldx       <address            new test to permit start at $0000 RG
                    cmpx      <startadr
                    beq       readbyte            can only be true if s.opt<>0
*         bne   gets3
*         tst   <s.opt
*         bne   readbyte
gets3               equ       *
                    lbsr      getbyte
                    ldx       <address
                    cmpx      <startadr
                    beq       gotstart
gets2               tst       <s.opt              for manual start & stop RG
                    bne       gets3               don't print fcb as this is disassembled
                    lbsr      fcbline
                    bra       gets3
gotstart            equ       *
                    lbsr      clrline
                    tst       <s.opt              for manual start & stop RG
                    bne       sopt4               skip printing Start
                    lbsr      adrmove
                    leay      line130,pcr
                    ldb       #ln130sz
                    lbsr      mergline
                    lbsr      writline
sopt4               lda       <byte
                    lbsr      moveobj
                    bra       testop
readbyte            lbsr      getbyte
* Check opcodes
testop              equ       *
                    clr       <bitcom             Clear bit instruction processing flag
                    lbsr      moveadr             Go bump address up?
                    lda       <byte               Get next byte
                    cmpa      #$10                Is it a $10?
                    bne       test11              No, check for next special one
                    lbsr      getbyte             Is $10, get next byte
                    cmpb      #$3f                OS9 System call?
                    bne       test10              No, do rest of check for $10 pre-byte
                    lbsr      getbyte             Get function code
                    tfr       b,a                 Move to A
                    ldb       #$3f                Go get proper mnemonic for System call
                    lbsr      getop
                    cmpa      #'?                 Unknown one?
                    bne       os9ok               No, print out regular system call
                    leax      holdobj,u           Unknown, deal with it
                    stx       <objadr
                    clr       <objcnt
                    lda       #$10
                    lbsr      moveobj
                    lda       #$3f
                    lbsr      moveobj
                    ldx       <objadr
                    ldd       #$2020
                    std       ,x
                    ldx       <lineadr
                    leax      -15,x
                    stx       <lineadr
                    leay      line140,pcr         Print SWI2 message
                    ldb       #ln140sz
                    lbsr      mergline
                    lbsr      writline
                    lda       <testbyte
                    sta       <byte
                    lbsr      fcbline             And FCB byte following it
                    bra       readbyte

* Got recognizable OS9 System call... print it
os9ok               lbsr      writline
                    bra       readbyte
* $10 Pre-byte OTHER than SWI2 (system calls)

test10              tfr       b,a                 Put opcode part into A
                    ldb       #$10                Go get proper mnemonic type for $10xx code
                    lbsr      getop
                    cmpb      #$fe                Unknown opcode?
                    bne       chkreslt            No, deal with result
                    lda       #$10                Unknown, convert to FCB line
                    bra       tst11.1
test11              cmpa      #$11                $11 pre-byte?
                    bne       onebyte             No, must be normal
                    lbsr      getbyte             Get opcode part of $11xx command
                    tfr       b,a                 Put into A
                    ldb       #$11                $11 pre-byte
                    lbsr      getop               Go get proper mnemonic type for $11xxx code
                    cmpb      #$fe                Unknown opcode?
                    bne       chkreslt            No, deal with result
                    lda       #$11                Make FCB line
tst11.1             ldb       <byte
                    pshs      b
                    sta       <byte
                    ldx       <address
                    leax      -1,x
                    stx       <address
                    lbsr      fcbline
                    puls      b
                    stb       <byte
                    tfr       b,a
                    lbsr      moveobj
                    ldx       <address
                    leax      1,x
                    stx       <address
                    lbra      testop

* Opcode type branch table
rslttab             fdb       chk.ff              Direct page (1 byte address)
                    fdb       dofcb               FCB (Unknown type... should never get here!)
                    fdb       chk.fd              Implied (single byte by itself)
                    fdb       chk.fc              2 byte relative (long branches)
                    fdb       chk.fb              1 byte immediate value
                    fdb       chk.fa              Dual register spec (EXG/TFR)
                    fdb       chk.f9              1 byte relative (short branches)
                    fdb       chk.f8              Indexed (1 or more post bytes)
                    fdb       chk.f7              Stack (PSH/PUL) register post-byte
                    fdb       chk.f6              ???
                    fdb       chk.f5              SWI
                    fdb       chk.f4              Extended (2 byte address)
                    fdb       chk.f3              2 byte immediate value
                    fdb       chk.f2              4 byte immediate
                    fdb       chk.f1              in memory (AIM, etc.)
                    fdb       chk.f0              Bit commands (LDBT, etc.)

onebyte             clrb                          Clear $10/$11/Syscall flag
                    lbsr      getop               Get type into B/Code in <testbyte

chkreslt            cmpb      #$f0                Check legal limit of opcode type
                    blo       dofcb               If <$F0, assume FCB
                    comb                          Flip bits
                    lslb                          2 bytes per entry
                    leax      rslttab,pcr         Point to opcode type table
                    ldd       b,x                 Get offset to proper routine
                    leax      pcrzero,pcr         Point to start of module
                    jmp       d,x                 Go process proper type

* Illegal opcode-FCB it
dofcb               lbsr      fcbline
                    lbra      readbyte

* Direct Page Addr - 1 byte
chk.ff              leay      line080,pc
                    tst       <u.opt              User wants Symbolic labels?
                    beq       ff.010              Yes, do so
                    leay      line085,pcr         No, use <$00xx instead
ff.010              ldb       #2                  In both cases, 2 chars to merge
                    lbsr      mergline            Merge onto current output line
                    lbsr      getbyte             Get direct page address byte
                    clra                          Make for 4 digit hex number
                    lbsr      merghex2            Merge 4 digit hex result onto output line
                    tst       <u.opt              Direct page currently @ 0?
                    lbeq      indx046             put address in u table & write out line

* Inherent Addr - 0 bytes (also exit point when line is completed)
chk.fd              lbsr      writline            Flush line out & continue processing
                    lbra      readbyte

* Relative Addr - 2 bytes
chk.fc              lbsr      getbyte2            Get 2 byte relative offset
                    lbsr      reladr.2            Calculate relative address & append it
                    bra       chk.fd              Write out line

* Immediate Addr - 1 byte
chk.fb              lbsr      mvchr004            Add '#' to line
                    lbsr      mvchr005            Add '$' to line
                    lbsr      getbyte             Get immediate value
                    lbsr      merghex             Add hex version to line
                    bra       chk.fd              Write it out

* Dual register field
* (used only for TFR/EXG/TFM & register to register operations)
chk.fa              lda       <testbyte           Get original opcode
                    clr       <TFMFlag            Clear TFM flag
                    cmpa      #$38                TFM?
                    blo       normtf              No, skip ahead
                    cmpa      #$3b
                    bhi       normtf
                    inc       <TFMFlag            Set TFM flag
normtf              lbsr      getbyte             Get register field byte
                    pshs      b                   Preserve
                    lsrb                          Move source reg. into proper pos.
                    lsrb
                    lsrb
                    lsrb
                    bsr       fa.020              Add it to line
                    lda       <testbyte           Get original opcode
                    cmpa      #$38                Is it a TFM?
                    blo       notTFM              Too low
                    cmpa      #$3B
                    bhs       notTFM              Too high (or is r1,r2+ and doesn't need sign)
                    cmpa      #$39                TFM r1-,r2-?
                    bne       Tplus1
                    lbsr      mvchr009            Add '-'
                    bra       notTFM
Tplus1              lbsr      mvchr008            Add '+'
notTFM              lbsr      mvchr003            Add comma to line
                    puls      b                   Get back field byte
                    andb      #$0f                Just destination reg.
                    bsr       fa.020              Add it to line
                    lda       <testbyte           Get original opcode
                    cmpa      #$38                Is it a TFM?
                    blo       notTFM2             Too low
                    cmpa      #$3B
                    bhi       notTFM2             Too high
                    cmpa      #$3A                TFM r1+,r2?
                    beq       notTFM2             Yes, don't need to add anything
                    cmpa      #$39                TFM r1-,r2-?
                    bne       Tplus2
                    lbsr      mvchr009            Add '-'
                    bra       notTFM2
Tplus2              lbsr      mvchr008            Add '+'
notTFM2             lbsr      writline            Write line & leave
                    lbra      readbyte

fa.020              tst       <TFMFlag            Is this a TFM command?
                    beq       normreg             No, allow all register names
                    cmpb      #4                  D,X,Y,U or S?
                    bhi       badreg              No, illegal in TFM
normreg             lslb                          2 bytes/entry
                    leax      regtab,pc           Point to register field table
                    ldd       b,x                 Get register name
                    bra       movereg             Add to end of line and return
badreg              ldd       #'?*256+'?          Illegal register, use question marks
*         bra   movereg        Add to end of line (eating spaces)
* fall thru into movereg, which immediately follows

movereg             lbsr      movechar            Add first char of reg. name to line
                    cmpb      #$20                2nd char a space?
                    beq       mvreg010            Yes, exit
                    tfr       b,a                 Move to proper reg.
                    lbsr      movechar            And add 2nd char of reg. name to line
mvreg010            rts

* Relative Addr - 1 byte
chk.f9              lbsr      getbyte             Get relative offset byte
                    lbsr      reladr.1            Calculate & add it to line
                    lbra      chk.fd              Print line

indxregs            fcb       %00000000,'x
                    fcb       %00100000,'y
                    fcb       %01000000,'u
                    fcb       %01100000,'s
* Index table routine list for both normal & indirect modes
indxjmp             fcb       %10000100           Zero offset ($84)
                    fdb       indx010
                    fcb       %10001000           8 bit offset ($88)
                    fdb       indx.3
                    fcb       %10001001           16 bit offset ($89)
                    fdb       indx.4
                    fcb       %10000110           A,R ($86)
                    fdb       indx.5
                    fcb       %10000101           B,R ($85)
                    fdb       indx.6
                    fcb       %10001011           D,R ($8B)
                    fdb       indx.7
                    fcb       %10000111           E,R ($87)
                    fdb       indx.E
                    fcb       %10001010           F,R ($8a)
                    fdb       indx.F
                    fcb       %10001110           W,R ($8e)
                    fdb       indx.W
                    fcb       %10000000           ,R+ ($80)
                    fdb       indx.8
                    fcb       %10000001           ,R++ ($81)
                    fdb       indx.9
                    fcb       %10000010           ,-R ($82)
                    fdb       indx.10
                    fcb       %10000011           ,--R ($83)
                    fdb       indx.11
                    fcb       %10001100           8 bit,PC ($8C)
                    fdb       indx.12
                    fcb       %10001101           16 bit,PC ($8D)
                    fdb       indx.13
                    fcb       %10001111           Non-indirect W modes ($8f)
                    fdb       indx.Wm
                    fcb       0                   table end    (any patterns not covered are illegal)

* indexed addr - 1 or 2 bytes
chk.f8              clr       <indirct            Clear indirect flag
                    lbsr      getbyte             Get byte into B (and duplicate in <byte>)
                    andb      #%10011111          Mask out register bits (mode bits for W)
                    cmpb      #%10001111          W base (non-indirect)?
                    beq       isw                 Yes, set register name
                    cmpb      #%10010000          W base (indirect)?
                    beq       isw                 Yes, set register name
                    ldb       <byte               Get original byte back
                    bra       notw                Do normal search
isw                 ldb       #'w                 W register is base register
                    bra       streg               Store it as base register
notw                andb      #%01100000          Register mask
                    leax      indxregs-2,pc       Point to register offsets -2 for loop
f8.10               leax      2,x                 Point to next entry
                    cmpb      ,x                  This the one we want?
                    bne       f8.10               No, keep looking
                    ldb       1,x                 Get base register name
streg               stb       <register           Preserve it
                    ldb       <byte               Get back original byte
                    andb      #%10011111          Mask out the base register bits
* Main indexing type check here
                    cmpb      #%00100000          5 bit offset indexing (special case)?
                    blo       indx.2              Yes, go do
                    cmpb      #%10010000          Non-indirect?
                    blo       f8.15               Yes, skip ahead
* Indirect modes start here
                    lbsr      mvchr001            Add '['
                    inc       <indirct            Set indirect flag
                    cmpb      #%10010000          W indirect indexing mode (since it shares pattern)
                    lbeq      indx.Wm             Yes, go process
                    cmpb      #%10010010          Illegal?
                    lbeq      indx.15             Yes, bad mode
                    cmpb      #%10011111          Extended indirect?
                    lbeq      indx.14             Yes, go do that
                    andb      #%10001111          Mask out indirect bit for next routine
f8.15               leax      indxjmp-3,pc        Point to index jump table -3 for loop
f8.20               leax      3,x                 Point to next entry
                    cmpb      ,x                  Bit mask we want?
                    beq       f8.30               Yes, skip ahead
                    tst       ,x                  No, is the end of table marker?
                    lbeq      indx.15             Yes, bad mode
                    bra       f8.20               Otherwise, keep searching
f8.30               ldd       1,x                 Get vector
                    leax      pcrzero,pc          Set base address of vector
                    jmp       d,x                 Go to proper routine

* 5 bit offset
indx.2              andb      #$1f                Mask out upper 3 bits
                    pshs      b                   Preserve it
                    cmpb      #$0f                Negative offset?
                    bls       indx2.1             No, skip ahead
                    ldb       #$20                Calculate negative offset & preserve
                    subb      ,s
                    stb       ,s
                    lbsr      mvchr009            Add '-'
indx2.1             lbsr      mvchr005            Add '$'
                    puls      a                   Get offset value
                    bra       indx3.1             Add it to the line in hex format

* 8 bit offset
indx.3              lbsr      getbyte             Get next byte
                    lbsr      mvchr006            Add '<'
                    cmpb      #$7f                Negative value?
                    bls       indx3.0             No, skip ahead
                    clra                          Make it a 16 bit number
                    std       <temp               Store it
                    ldd       #$0100              Calculate negative offset for 8 bit #
                    subd      <temp
                    lbsr      mvchr009            Add '-'
indx3.0             lbsr      mvchr005            Add '$'
indx3.1             lbsr      merghex             Add LSB of D as a 2 digit hex byte
                    lbra      indx010

* 16 bit offset
indx.4              lbsr      mvchr007            Add '>'
                    lbsr      getbyte2            Get 2 byte offset
                    pshs      d                   Preserve it
                    cmpd      #$7fff              Is it negative?
                    bls       indx4.1             No, skip ahead
                    puls      d                   Get back value
                    std       <temp               Preserve it
                    ldd       #$ffff              Calculate negative offset
                    subd      <temp
                    addd      #1
                    pshs      d                   Preserve it
                    lbsr      mvchr009            Add '-'
indx4.1             lbsr      mvchr005            Add '$'
                    puls      d                   Get back offset value
                    lbsr      merghex2            Add 16 bit number in hex format
                    bra       indx010

indx.5              lda       #'a                 A,R
indx5.1             lbsr      movechar
                    bra       indx010

indx.6              lda       #'b                 B,R
                    bra       indx5.1

indx.7              lda       #'d                 D,R
                    bra       indx5.1

indx.E              lda       #'e                 E,R
                    bra       indx5.1

indx.F              lda       #'f                 F,R
                    bra       indx5.1

indx.W              lda       #'w                 W,R
                    bra       indx5.1

* ,R+
indx.8              lbsr      isub010             Add ',' & register name
indx8.1             lbsr      mvchr008            Add '+'
                    bra       indx040             Continue

* ,R++
indx.9              lbsr      isub010             Add ',' & register name
                    lbsr      mvchr008            Add '+'
                    bra       indx8.1             Add 2nd '+' and continue

* ,-R
indx.10             lbsr      mvchr003            Add ','
indx10.1            lbsr      isub020             '-' & register name
                    bra       indx040             Continue

* ,--R
indx.11             lbsr      mvchr003            Add ','
                    lbsr      mvchr009            Add '-'
                    bra       indx10.1            Add 2nd '-' & register name & continue

* 8 bit,pc
indx.12             lbsr      mvchr006            Add '<'
                    lbsr      getbyte             Get next byte
                    lbsr      reladr.1            Calculate relative address label
                    bra       indx030             Add ',pcr'

* 16 bit,pc
indx.13             lbsr      mvchr007            Add '>'
                    lbsr      getbyte2            Get next 2 bytes
                    lbsr      reladr.2            Calculate relative address label
                    bra       indx030             Add ',pcr'

* Extended indirect
indx.14             lbsr      mvchr007            Add '>'
                    lbsr      mvchr005            Add '$'
                    lbsr      getbyte2            Get next 2 bytes
                    lbsr      merghex2            Append hex version of 16 bit #
                    bra       indx040             Continue
* W modes (<register=w and <indirct flag is set)
indx.Wm             ldb       <byte               Get original byte again
                    andb      #%01100000          Mask out all but W mode settings
                    cmpb      #%00000000          Straight register?
                    beq       indx010             Yes, do it
                    cmpb      #%00100000          mmmm,W?
                    lbeq      indx.4              Go do that
                    cmpb      #%01000000          ,W++?
                    beq       indx.9              Do that
                    bra       indx.11             Must be ,--W
* Illegal indexing mode
indx.15             leay      badindx,pcr         Point to '?'
                    ldb       #5                  Add 5 of them
                    lbsr      mergline
                    bra       indx040             Continue

indx010             lbsr      isub010             Add ',R'
                    bra       indx040             Continue

indx030             leay      line220,pc          Add ',pcr'
                    ldb       #ln220sz
                    lbsr      mergline

indx040             tst       <indirct            Is it an indirect mode?
                    beq       indx041             No, skip ahead
                    lbsr      mvchr002            Add ']'
indx041             lda       <register           Get register name
                    cmpa      #'u                 U register offset?
                    bne       indx090             No, skip ahead
                    tst       <u.opt              User wants uxxxx?
                    bne       indx090             No, skip
                    ldd       <dsave              get the offset
                    cmpd      <size               is it > total data size ???
                    bhi       indx090             yes..skip this stuff
                    leax      holdline+15,u       start of mnemonic
* Calculating  'uxxxx' info
indx042             lda       ,x+
                    cmpa      #'u                 done??
                    beq       indx090             yes..go send line as is
                    cmpa      #'$
                    bne       indx042
                    lda       #'u
                    sta       -1,x
                    lda       2,x
                    cmpa      #',
                    bne       indx046
                    stx       <xsave
                    ldx       <lineadr
                    leax      1,x
indx044             lda       ,-x
                    sta       2,x
                    cmpx      <xsave
                    bne       indx044
                    ldd       #$3030
                    std       ,x
                    ldx       <lineadr
                    leax      2,x
                    stx       <lineadr

* put the offset in u table
indx046             tst       <pass
                    bne       indx090
                    ldd       <dsave              get the u offset
                    ldx       <highadr            start of u table
                    leax      -2,x                back off for loop increment
indx050             leax      2,x
                    cmpd      ,x
                    beq       indx090
                    bhi       indx050             if >,go loop
                    leax      -2,x                this is where to insert it
                    stx       <xsave
                    ldx       <highadr
                    leax      -2,x
                    stx       <highadr
                    cmpx      <labladr
                    lbls      rladr2.3
indx052             ldd       2,x
                    std       ,x
                    leax      2,x
                    cmpx      <xsave
                    bne       indx052
                    ldd       <dsave
                    std       ,x

indx090             tst       <bitcom             We a bit operation and need to RTS?
                    beq       notbit              No, write line & exit
                    rts
notbit              lbsr      writline            Send the line out
                    lbra      readbyte            and continue

isub010             lbsr      mvchr003            Add ','
                    bra       isub025             skip ahead

isub020             lbsr      mvchr009            Add '-'
isub025             lda       <register           Get register name
* LCB - lbra movechar, remove RTS
                    lbsr      movechar            Add it too
                    rts

* Entry: <testbyte has actual opcode ($34-$37). We need to know if $36-$37, and change
* 'u' to 's' if it is
chk.f7              equ       *
* inherent addr - 1 byte
* (used for psh and pul only)
                    lbsr      getbyte             Get the bit flags byte part of PSH/PUL (into B & <byte)
                    leay      stackreg,pcr        Point to list of 2 byte register names for psh/pul
                    lda       <testbyte           Get opcode
                    cmpa      #$36                PSHU/PULU?
                    blo       SStack              No, use regs for PSHS/PULS
                    leay      ustckreg-stackreg,y Yes, point to PSHU/PULU version instead
SStack              lda       #%10000000          Init check for which regs are being pushed/pulled to 1st bit
                    sta       <testbyte
                    lda       #8                  # of bits to check ctr
f7.010              pshs      a                   Save # of bits to check ctr
                    ldx       ,y++                Get 1 or 2 char name of register
                    ldb       <byte               Is this register turned on in post byte?
                    andb      <testbyte
                    beq       f7.020              No, skip to next
                    tfr       x,d                 Yes, move name to D
* INSERT CHECK HERE - IF WE DOING PSHU/PULU, CHANGE A TO 's ($	73)
                    lbsr      movereg             Copy reg name to output buffer
                    lbsr      mvchr003            Add a comma to output buffer
f7.020              lda       <testbyte           Shift check bit to next one
                    lsra
                    sta       <testbyte
                    puls      a                   Get # of bits left to check ctr
                    deca                          We finished one
                    bne       f7.010              Still more left, try next
                    ldx       <lineadr            Done, move output buffer end ptr back one (eat last comma)
                    leax      -1,x
                    stx       <lineadr
                    lbra      chk.fd

chk.f6              lbsr      getbyte             Get 1 byte
                    clra                          Make into D
                    lbsr      merghex             Add hex value to output
                    lbra      chk.fd              continue

chk.f5              lbsr      writline            Write line out
                    lbsr      getbyte             Get byte
                    lbsr      fcbline             Make fcb line
                    lbra      readbyte            continue?

* extended addr - 2 bytes
chk.f4              lbsr      mvchr007            Add '>'
                    lbsr      mvchr005            Add '$'
f4.010              lbsr      getbyte2            Get 2 bytes
                    lbsr      merghex2            Print 4 digit hex value
                    lbra      chk.fd              continue

* immediate addr - 2 bytes
chk.f3              lbsr      mvchr004            Add '#'
                    lbsr      mvchr005            Add '$'
                    bra       f4.010              Add 4 digit hex value & leave

* immediate mode - 4 bytes
chk.f2              lbsr      mvchr004            Add '#'
                    lbsr      mvchr005            Add '$'
                    lbsr      getbyte2            Get 2 bytes
                    lbsr      merghex2            Print 4 hex digits
                    bra       f4.010              Print next 4 digits & continue

* in memory mode (AIM, etc.) (opcode s/b in <testbyte)
chk.f1              lbsr      mvchr004            Add '#'
                    lbsr      mvchr005            Add '$'
                    lbsr      getbyte             Get the 1 byte immediate value
                    lbsr      merghex             Add it to output
                    lbsr      mvchr003            Add ','
                    ldb       <testbyte           Get back original opcode
                    andb      #%11110000          Mask out all but mode nibble
                    lbeq      chk.ff              If Direct page mode, do that
                    cmpb      #%01100000          Indexed?
                    lbeq      chk.f8              Yes, do it
                    cmpb      #%01110000          Extended?
                    beq       chk.f4              yes, do it
                    lbsr      mvchr010            Unknown, add '?'
                    lbra      chk.fd              & exit
* Bit commands (LDBT, etc.)
chk.f0              lbsr      getbyte             Get register/bit flags
                    andb      #%11000000          Mask out all but register bits
                    beq       iscc                If CC, do that
                    cmpb      #%01000000          A?
                    bne       tryb                No, try B
                    ldd       #'a*256+32          Add 'a '
                    bra       gotregn
tryb                cmpb      #%10000000          B?
                    bne       is.e                No, must be E
                    ldd       #'b*256+32          Add 'b '
                    bra       gotregn
is.e                ldd       #'e*256+32          Add 'e '
                    bra       gotregn
iscc                ldd       #'c*256+'c          cc register
gotregn             lbsr      movereg             Add register name
                    lbsr      mvchr003            Add ','
                    lda       <byte               Get original byte again
                    bsr       getbit              Output register Bit #
                    lda       <byte               Get original byte again
                    lsra                          Shift to memory bit #
                    lsra
                    lsra
                    bsr       getbit              Output memory bit #
                    inc       <bitcom             Set bit command flag
* Dupe of direct page stuff
                    leay      line080,pc          Point to '<u'
                    tst       <u.opt              User wants Symbolic labels?
                    beq       f0.010              Yes, do so
                    leay      line085,pcr         No, use <$00xx instead
f0.010              ldb       #2                  In both cases, 2 chars to merge
                    lbsr      mergline            Merge onto current output line
                    lbsr      getbyte             Get direct page address byte
                    clra                          Make for 4 digit hex number
                    lbsr      merghex2            Merge 4 digit hex result onto output line
                    tst       <u.opt              Direct page currently @ 0?
                    bne       nou                 No, skip u stuff
                    lbsr      indx046             put address in u table & write out line
nou                 lbra      chk.fd              Write it out & continue

* Output ASCII bit # plus comma
getbit              anda      #%00000111          Mask to bit # 0-7
                    adda      #'0                 Convert to ASCII digit
                    lbsr      movechar            Add it to output
                    lbra      mvchr003            Add ',' and return

* 8 bit relative offset (bra)
reladr.1            lda       #'L                 Add 'L'
                    lbsr      movechar
                    clra                          D=8 bit relative address offset
                    ldb       <byte
                    addd      <address            Add to current address pointer
                    addd      #1                  Adjust for current instruction
                    pshs      a
                    lda       <byte
                    cmpa      #$7f                Negative offset?
                    puls      a
                    bls       rladr2.1            No, skip ahead
                    subd      #$0100              Calculate negative offset
                    bra       rladr2.1
* 16 bit relative offset (bra)
reladr.2            pshs      a
                    lda       #'L
                    lbsr      movechar
                    puls      a
                    addd      <address
                    addd      #1
rladr2.1            tst       <pass
                    bne       rladr2.4
                    leay      labeltab,u
rladr2.2            cmpd      ,y
                    beq       rladr2.4
                    leay      2,y
                    cmpy      <labladr
                    blo       rladr2.2
                    ldx       <labladr
                    std       ,x++
                    stx       <labladr
                    leax      2,x
                    cmpx      <highadr
                    blo       rladr2.4
rladr2.3            leax      line240,pcr         Error:symbol table full
                    ldy       #ln240sz
                    lda       #2
                    os9       I$WritLn
                    lbra      unlink
rladr2.4            lbsr      merghex2            Add 4 hex digits & return
                    rts

endit               lds       <stackhld           restore stack
endit010            tst       <pass
                    bne       endit020
*        ldx   <highadr
*        ldd   <utabend
*        subd  <highadr
*        tfr   d,y
*        lda   #2
*        os9   I$Write
*        lbcs  exit
*        lbra  clrexit
endit015            inc       <pass
                    lbsr      close
                    lbra      restart
endit020            ldb       <readcnt
                    beq       endit024
                    inc       <readclr
                    clra
                    std       <temp
                    ldd       <address
                    subd      <temp
                    std       <address
                    leax      readbuff,u
endit022            ldb       ,x+
                    stx       <readpos
                    stb       <byte
                    lbsr      fcbline
                    ldd       <address
                    addd      #1
                    std       <address
                    ldx       <readpos
                    dec       <readcnt
                    bne       endit022
endit024            tst       <z.opt
                    lbne      clrexit
                    tst       <s.opt
                    lbne      endit032            don't print eom etc.
                    clr       <readclr
                    lbsr      clrline
                    lbsr      adrmove
                    ldx       #$ffff
                    stx       <modend
                    lbsr      getbyte
                    lbsr      getbyte
                    lbsr      getbyte
                    leay      line170,pcr
                    ldb       #ln170sz
                    lbsr      mergline
                    lbsr      writline
                    lbsr      adrmove
                    leay      line180,pcr
                    ldb       #ln180sz
                    lbsr      mergline
                    lbsr      writline
                    lbsr      moveadr
                    leax      holdline,u
                    lda       ,x
                    cmpa      #$20
                    beq       endit030
                    leay      line190,pcr
                    ldb       #ln190sz
                    lbsr      mergline
                    lbsr      writline
endit030            lbsr      clrline
                    leay      line181,pcr
                    ldb       #ln181sz
                    lbsr      mergline
                    lbsr      writline
endit032            bsr       close

                    ifeq      testing-1
                    lbsr      clrline
                    lda       #$20
                    lbsr      movechar
                    lbsr      writline
                    leay      labeltab,u
endit040            ldd       ,y++
                    pshs      y
                    lda       #'*
                    lbsr      movechar
                    lda       #$20
                    lbsr      movechar
                    lbsr      merghex2
                    lbsr      writline
                    puls      y
                    cmpy      <labladr
                    bls       endit040
                    leay      line230,pcr
                    ldb       #ln230sz
                    lbsr      mergline
                    ldd       <labladr
                    leax      labeltab,u
                    stx       <labladr
                    subd      <labladr
                    lsra
                    rorb
                    lbsr      merghex2
                    lbsr      writline
                    endc

                    tst       <diskio
                    lbne      clrexit
                    lda       #2
                    sta       <byte

unlink              ldu       <modadr
                    os9       F$UnLink
                    lbcs      exit
                    dec       <byte
                    bne       unlink
                    lbra      clrexit

close               tst       <diskio
                    beq       close010
                    lda       <path
                    os9       I$Close
                    lbcs      exit
close010            rts


                    pag
*
******************** descriptor processing ***************************
descrhdr            lbsr      getbyte2
                    std       <mgradr
                    lbsr      getbyte2
                    std       <drvadr
                    lbsr      clrline
                    lbsr      getbyte
                    lbsr      fcbline
                    leay      line340,pcr
                    ldb       #ln340sz
                    lbsr      mergline
                    lbsr      writline
                    lbsr      getbyte
                    lbsr      fcbline
                    leay      line350,pcr
                    ldb       #ln350sz
                    lbsr      mergline
                    lbsr      writline
                    lbsr      getbyte2
                    lbsr      fdbline
                    leay      line360,pcr
                    ldb       #ln360sz
                    lbsr      mergline
                    lbsr      writline
                    lbsr      getbyte
                    lbsr      moveadr
                    clra
                    ldb       <byte
                    addd      <address
                    addd      #1
                    std       <initsize
                    leay      line380,pcr
                    ldb       #ln380sz
                    lbsr      mergline
                    lbsr      writline
                    lbsr      getbyte
                    stb       <desctype
                    lbsr      fcbline
                    leay      line390,pcr
                    ldb       #ln390sz
                    lbsr      mergline
                    lbsr      writline
                    leax      scfprint,pcr
                    stx       <printadr
                    lda       <desctype
                    cmpa      #1
                    bne       getdescr
                    leax      rbfprint,pcr
                    stx       <printadr
getdescr            ldx       <printadr
                    lda       ,x+
                    pshs      x
                    cmpa      #'2
                    lbeq      descr2
                    cmpa      #'3
                    lbeq      descr3
                    lbsr      getbyte
                    ldd       <address
                    cmpd      <initsize
                    bne       desc010
                    lbsr      clrline
                    lbsr      adrmove
                    leay      line400,pcr
                    ldb       #ln400sz
                    lbsr      mergline
                    lbsr      writline
desc010             ldd       <address
                    cmpd      <nameadr
                    bne       desc015
                    leay      line100,pcr
                    ldb       #ln100sz
                    leax      holdname,u
                    bra       desc030
desc015             cmpd      <mgradr
                    bne       desc020
                    leay      line410,pcr
                    ldb       #ln410sz
                    leax      namehold,u
                    bra       desc030
desc020             cmpd      <drvadr
                    bne       desc040
                    leay      line420,pcr
                    ldb       #ln420sz
                    leax      namehold,u
desc030             pshs      x
                    pshs      b
                    leax      holdobj,u
                    ldd       #$2020
                    std       ,x++
                    std       ,x++
                    std       ,x++
                    std       ,x++
                    puls      b
                    lbsr      mergline
                    lbsr      adrmove
                    lbsr      writline
                    puls      y
                    lbsr      movename
                    lbsr      getbyte
                    puls      x
                    leax      scfpend,pcr
                    leax      1,x
                    pshs      x
                    stx       <printadr
                    bra       desc010
desc040             lbsr      fcbline
                    bra       mergdesc
descr2              lbsr      getbyte2
                    lbsr      fdbline
                    bra       mergdesc
* descriptor name copy
descr3              stx       <printadr
                    lbsr      getbyte2
                    lbsr      moveadr
                    leay      line430,pcr
                    ldb       #ln430sz
                    lbsr      mergline
                    lbsr      writline
                    lbra      getdescr

mergdesc            clrb
                    puls      x
                    pshs      x
desc050             lda       ,x+
                    cmpa      #$0d
                    beq       desc060
                    incb
                    bra       desc050
desc060             stx       <printadr
*         leax  -2,x
                    lda       ,--x
                    cmpa      #'?
                    bne       desc070
                    leax      -1,x
                    stx       <printadr
desc070             puls      y
                    lbsr      mergline
                    lbsr      writline
                    lbra      getdescr

**********************************************************************
*######################################################################
* subroutines
*######################################################################


***********************************************************************
*                                                                     *
* U$hexin - converts hex characters to binary digits                  *
*                                                                     *
* Entry: x=start address of digits to convert                         *
*                                                                     *
* Exit:  x=same as entry                                              *
*        y=# of converted bytes                                       *
*                                                                     *
***********************************************************************

u$hexin             pshs      a,b
                    pshs      x
                    leay      ,x                  move start addr for scan
hexin010            bsr       hexin030            convert bytes
                    bcs       hexin020            exit if done
                    stb       ,x+                 move the converted byte in
                    bra       hexin010            go back & get more
hexin020            tfr       x,d                 get current byte position
                    subd      ,s                  subtract start position
                    tfr       d,y                 move the length of the string
                    puls      x
                    puls      a,b,pc              done

hexin030            ldb       ,y+                 get char
                    cmpb      #',                 was it a comma??
*         bne   hexin050 no..don't skip it
                    beq       hexin030            skip it
*hexin040 ldb   ,y+ get next char
hexin050            cmpb      #$20                was it a space
*        beq   hexin040 yes...skip it & get next char
                    beq       hexin030            yes...skip it & get next char
                    leay      -$01,y              else back up to point to the char
                    bsr       hexin080            convert it
                    bcs       hexin070            done....exit
                    pshs      b                   save the byte
                    bsr       hexin080            convert next byte
                    bcs       hexin060            exit if done
                    asl       ,s                  shift saved char to put in high 4 bits
                    asl       ,s
                    asl       ,s
                    asl       ,s
                    addb      ,s                  and move in low 4 bits
                    stb       ,s                  save the byte
hexin060            clrb                          clear the carry flag
                    puls      b                   restore the saved flag
hexin070            rts                           return

hexin080            ldb       ,y                  get the char in
                    subb      #$30                subtract bias for numbers
                    cmpb      #$09                was it > 9
                    bls       hexin100            no...its good
                    cmpb      #$31                was it 'a'
                    blo       hexin090            if less than that..skip next
                    subb      #$20                else make it upper case
hexin090            subb      #$07                back off so 'A' = $0a
                    cmpb      #$0F                check if it was a 'F'
                    bhi       hexin110            if >...error
                    cmpb      #$0A                was it a 'A'
                    bcs       hexin110            if <...error
hexin100            andcc     #$FE                clear carry bit of cc
                    leay      $01,y               bump up pointer for next char
                    rts                           return
hexin110            comb                          set carry flag
                    rts                           return


*
* convert bytes in d to hex, output to hexstrng
*
gethex              std       <dsave
                    pshs      y
                    leay      hexstrng,u
                    pshs      b
                    bsr       gethx010
                    puls      a
                    bsr       gethx010
                    puls      y,pc
gethx010            pshs      a
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       gethx020
                    puls      a
                    anda      #$0f
                    bsr       gethx020
                    rts
gethx020            adda      #$30
                    cmpa      #$3a
                    blt       gethx030
                    adda      #$07
gethx030            sta       ,y+
                    rts

*
* get decimal value of bytes in d, output in string pointed at by 'y'
*
getdec              pshs      x
                    ldx       #10000
                    bsr       getdc010
                    ldx       #01000
                    bsr       getdc010
                    ldx       #00100
                    bsr       getdc010
                    ldx       #00010
                    bsr       getdc010
                    stb       <counter
                    bsr       getdc030
                    puls      x,pc
getdc010            stx       <countdec
                    clr       <counter
getdc020            cmpd      <countdec
                    blo       getdc030
                    subd      <countdec
                    inc       <counter
                    bra       getdc020
getdc030            pshs      b
                    ldb       <counter
                    addb      #$30
                    stb       ,y+
                    puls      b,pc

*
* read next 2 bytes into 'd'
*
getbyte2            bsr       getbyte
                    tfr       b,a
                    bsr       getbyte
                    rts

*
* merge last 2 bytes of hexstrng with output line
*
merghex             equ       *
                    clra
                    bsr       gethex
                    leay      hexstrng,u
                    leay      2,y
                    ldb       #2
                    lbsr      mergline
                    rts

*
* merge all 4 hex chars to output line
*
merghex2            bsr       gethex
                    leay      hexstrng,u
                    ldb       #4
                    lbsr      mergline
                    rts


*
* merge significant decimal characters
*
mergdec             pshs      a,b
                    leay      decstrng,u
                    lda       #$30
                    sta       ,y
                    puls      a,b
                    cmpd      #0
                    bne       mergd010
                    ldb       #1
                    lbra      mergline
mergd010            bsr       getdec
                    leay      decstrng,u
                    ldb       #6
chkdecln            decb
                    lda       ,y+
                    cmpa      #$30
                    beq       chkdecln
                    leay      -1,y
                    lbra      mergline

*
* read 1 byte
* Exit: B=next byte from program being disassembled (also stored in <byte)
getbyte             pshs      x,y,a               Save regs
                    ldx       <address            Bump address up by 1
                    leax      1,x
                    stx       <address
                    leax      3,x                 Bump up size of CRC
                    cmpx      <modend             Are we at the CRC bytes now?
                    lbhs      endit               Yes, we are finished disassembling
                    tst       <diskio             Are we disassembling from disk?
                    bne       getdisk             Yes, get byte from disk path instead of memory
                    ldx       <crntadr            Get ptr to current position in module in memory
                    ldb       ,x+                 Get next byte (puts "in memory" in sync with disk i/o, RG)
*         leax  1,x
                    stx       <crntadr            Save updated ptr
*        ldb   ,x           here it throws disk and memory out of sync
                    stb       <byte               Save byte
                    bra       gotbyte
*
* read byte from disk
*
getdisk             leax      byte,u              Point to where byte will go
                    ldy       #1                  1 byte to read
                    lda       <path               Get path to disk file we are disassemlbing
                    os9       I$Read              Read next byte
                    lbcs      endit               Error, we are done
                    ldb       <byte               Get byte into B
gotbyte             lda       <byte               And into A
                    bsr       moveobj             Convert to hex, append to object code listing
* Isn't this redundant? we have b with <byte from both entry points, and it's preserved in
* moveobj. (LCB)
                    ldb       <byte               Get byte back
                    ldx       <readpos            Update read position
                    stb       ,x+
                    stx       <readpos
                    inc       <readcnt            Bump up read byte count
                    puls      x,y,a,pc            restore regs & return

*
* convert 'a' to hex,merge with object code listing
* Entry: A=byte we are converting
moveobj             pshs      x,y,b               Save regs
                    ldb       <objcnt
                    cmpb      #4
                    bhs       moverts
                    inc       <objcnt
                    lbsr      gethex
                    ldx       <objadr
                    leay      hexstrng,u
                    lda       ,y+
                    lbsr      getupc
                    sta       ,x+
                    lda       ,y
                    lbsr      getupc
                    sta       ,x+
                    stx       <objadr
moverts             puls      x,y,b,pc

*
* clear one of the hold strings pointed to by 'y'
*
clrhld              sty       <lineadr
                    pshs      x,b
                    tfr       y,x
                    leay      line040,pcr
                    ldb       #40
                    bsr       merge
                    ldy       <lineadr
                    puls      x,b,pc

*
* clear all parts of the output line
*
clrline             pshs      x,y,a,b
                    leax      holdline,u
                    stx       <lineadr
                    leax      holdobj,u
                    stx       <objadr
                    leax      linenum,u
                    clr       <objcnt
                    leay      line040,pcr
                    ldb       #80
                    bsr       merge
                    puls      x,y,a,b,pc

*
* merge the string pointed to by 'y' with the current line
*
mergline            ldx       <lineadr
                    bsr       merge
                    stx       <lineadr
                    rts

*
* merge the string pointed to by 'y' with the string pointed to by 'x'
*
merge               pshs      a
merge010            lda       ,y+
                    sta       ,x+
                    decb
                    bne       merge010
                    puls      a,pc

*
* write the output line to standard output path,then clear line
*
writline            pshs      x,y
                    tst       <pass
                    beq       wrtln010
                    ldd       <numline
                    addd      #1
                    std       <numline
                    leay      linenum,u
                    lbsr      getdec
                    ldx       <lineadr
                    lda       #$0d
                    sta       ,x+
                    tfr       x,d
                    leax      linenum,u
                    tst       <o.opt
                    bne       wrtln005
                    leax      holdline,u
wrtln005            stx       <temp
                    subd      <temp
                    tfr       d,y
                    lbsr      send
wrtln010            bsr       clrline
                    tst       <readclr
                    bne       wrtln020
                    leax      readbuff,u
                    stx       <readpos
                    clr       <readcnt
wrtln020            puls      x,y,pc
*
* move the current address to holdadr of output line
*
adrmove             pshs      x
                    ldd       <address
                    lbsr      gethex
                    leax      hexstrng,u
                    leay      holdadr,u
                    ldb       #4
adrmv010            lda       ,x+
                    lbsr      getupc
                    sta       ,y+
                    decb
                    bne       adrmv010
                    puls      x,pc

*
* move the current address if its second pass and its a referenced address
*
moveadr             tst       <pass
                    beq       mvadr020
                    bsr       adrmove
                    leay      labeltab,u
                    ldd       <address
mvadr010            cmpy      <labladr
                    beq       mvadr020
                    cmpd      ,y
                    beq       mvadr030
                    leay      2,y
                    bra       mvadr010
mvadr020            leay      line040,pcr
                    ldb       #9
                    lbsr      mergline
                    rts
mvadr030            lda       #'L
                    bsr       movechar
                    ldd       <address
                    lbsr      merghex2
                    leay      line040,pcr
                    ldb       #4
                    lbsr      mergline
                    rts

*
* merge predefined characters with the output line
*
mvchr001            lda       #'[
                    bra       movechar
mvchr002            lda       #']
                    bra       movechar
mvchr003            lda       #',
                    bra       movechar
mvchr004            lda       #'#
                    bra       movechar
mvchr005            lda       #'$
                    bra       movechar
mvchr006            lda       #'<
                    bra       movechar
mvchr007            lda       #'>
                    bra       movechar
mvchr008            lda       #'+
                    bra       movechar
mvchr009            lda       #'-
                    bra       movechar
mvchr010            lda       #'?
*        bra   movechar  fall thru

*
* merge the char in 'a' with the output line
*
movechar            ldx       <lineadr
                    sta       ,x+
                    stx       <lineadr
                    rts

movename            pshs      y
                    lbsr      clrline
                    bsr       moveadr
                    leay      line060,pcr
                    ldb       #ln060sz
                    lbsr      mergline
                    ldb       <byte
                    tfr       b,a
                    lbsr      moveobj
                    puls      y
getnm010            cmpb      #$80
                    bhs       getnm020
                    stb       ,y+
                    tfr       b,a
                    bsr       movechar
                    lbsr      getbyte
                    bra       getnm010
getnm020            subb      #$80
                    stb       ,y+
                    tfr       b,a
                    bsr       movechar
                    ldb       #$0d
                    stb       ,y
                    lda       #'/
                    bsr       movechar
                    lbsr      writline
                    rts
*
* line type is fcb ...create all parts of fcb line
*
fcbline             lbsr      clrline
                    lbsr      moveadr
                    leay      line090,pcr
                    ldb       #ln090sz
                    lbsr      mergline
                    ldb       <byte
                    lbsr      merghex
                    leay      hexstrng,u
                    leay      2,y
                    pshs      x

                    ldx       <objadr
                    lda       ,y+
                    sta       ,x+
                    lda       ,y
                    sta       ,x+
                    stx       <objadr
                    puls      x
                    lda       #$20
                    lbsr      movechar
                    tst       <descript
                    bne       fcbl030
                    lda       <byte
                    cmpa      #$20
                    bls       fcbl020
                    cmpa      #'z
                    bls       fcbl010
                    suba      #$80
                    cmpa      #$20
                    bls       fcbl020
                    cmpa      #'z
                    bgt       fcbl020
fcbl010             lbsr      movechar
fcbl020             lbsr      writline
fcbl030             rts
fdbline             pshs      d
                    lbsr      clrline
                    ldd       <address
                    pshs      d
                    subd      #1
                    std       <address
                    lbsr      moveadr
                    puls      d
                    std       <address
                    leay      line370,pcr
                    ldb       #ln370sz
                    lbsr      mergline
                    puls      d
                    lbsr      merghex2
                    leay      hexstrng,u
                    ldb       #4
                    pshs      x
                    ldx       <objadr
                    ldd       ,y++
                    std       ,x++
                    ldd       ,y++
                    std       ,x++
                    stx       <objadr
                    puls      x
                    lda       #$20
                    lbsr      movechar
                    rts


*
* convert 'a' to upper case if its a letter
*
getupc              cmpa      #'z
                    bls       getup010
                    anda      #$df
getup010            rts


*
* if its 2nd pass,write the line to standard output path
*
send                tst       <pass
                    beq       send010
                    lda       #1
                    os9       I$WritLn
                    lbcs      exit
send010             lbsr      clrline
                    rts

********* get op ******************
*  entry: opcode in a / a&b for 2 ops
getop               sta       <testbyte           Save opcode
                    tstb                          Check if special
                    bne       chkos9              Yes, check for os9 system call
                    ldb       #6                  No, 6 bytes/entry (type byte, 5 char string per entry)
                    mul
                    leay      optable,pcr         Point to opcode table
                    leay      d,y                 Point to entry for our opcode
getrest             leay      1,y
                    lda       ,y+
                    tfr       a,b
                    pshs      b
                    ldb       #5                  Size of opcode string
moveop              lda       ,y+                 Get char from opcode name
                    lbsr      movechar            Copy to output
                    decb                          Done whole string?
                    bne       moveop              No, keep copying until done
                    pshs      a
                    lda       #$20                Done, add a space to output
                    lbsr      movechar
                    puls      a
                    puls      b,pc

chkos9              cmpb      #$3f
                    bne       chk10
                    leay      line150,pcr
                    ldb       #ln150sz
                    lbsr      mergline
                    cmpa      #$80
                    bhs       i$os9
                    cmpa      #$54
                    bhs       bados9
                    leay      os9f$tab,pcr
                    bra       getos9

i$os9               cmpa      #$91
                    bhi       bados9
                    leay      os9i$tab,pcr
                    suba      #$80
                    bra       getos9
bados9              leay      bados9op,pcr
                    clra
getos9              ldb       #8
                    mul
                    leay      d,y
                    pshs      b
                    ldb       #8
                    bra       moveop

chk10               sta       <testbyte
                    cmpb      #$10
                    beq       load10
                    cmpb      #$11
                    beq       load11
                    clr       <testbyte
load11              leay      get11tab,pcr
                    bra       loop10
load10              leay      get10tab,pcr
loop10              lda       ,y
                    tsta
                    beq       getrest
                    cmpa      <testbyte
                    beq       getrest
                    leay      7,y
                    bra       loop10

nolink              lbsr      clrline
                    leay      line200,pcr
                    ldb       #ln200sz
                    lbsr      mergline
                    ldy       <xreghold
                    ldb       #$20
                    lbsr      mergline
                    lda       #$0d
                    lbsr      movechar
                    leax      holdline,u
                    ldy       #$50

*
* error encountered - print error to standard error path
*
prterror            lda       #2
                    os9       I$WritLn
clrexit             clrb
exit                os9       F$Exit

                    emod
eom                 equ       *
                    end

