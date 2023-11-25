********************************************************************
* Init - NitrOS-9 Configuration module
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2023/10/08  Boisy G. Pitre
* Created for FEU.

               use       ../defsfile

tylg           set       Systm+$00
atrv           set       ReEnt+rev
rev            set       $00
edition        set       1

*
* Usually, the last two words here would be the module entry
* address and the dynamic data size requirement. Neither value is
* needed for this module so they are pressed into service to show
* MaxMem and PollCnt. For example:
* $0FE0,$0015 means
* MaxMem = $0FE000
* PollCnt = $0015
*
               mod       eom,name,tylg,atrv,$0FE0,$0015

***** USER MODIFIABLE DEFINITIONS HERE *****

*
* refer to
* "Configuration Module Entry Offsets"
* in os9.d
*
start          equ       *
               fcb       $27                 entries in device table
               fdb       DefProg             offset to program to fork
               fdb       DefDev              offset to default disk device
               fdb       DefCons             offset to default console device
               fdb       DefBoot             offset to boot module name
               fcb       $01                 write protect flag (?)
               fcb       Level               OS level
               fcb       NOS9VER             OS version
               fcb       NOS9MAJ             OS major revision
               fcb       NOS9MIN             OS minor revision
               fcb       CRCOff              feature byte #1
               fcb       $00                 feature byte #2
               fdb       OSStr
               fdb       InstStr
               fcb       0,0,0,0             reserved

name           fcs       "init"
               fcb       edition

DefProg        fcs       "sysgo"
DefDev         fcs       "/dd"
DefCons        fcs       "/term"
DefBoot        fcb       0

OSStr          fcb       0

InstStr        fcb       0

               emod
eom            equ       *
               end
