*******************************************
***                                     ***
***     COPYRIGHT 1990 BURKE & BURKE    ***
***     ALL RIGHTS RESERVED             ***
***                                     ***
*******************************************

                    nam       BBFHDISK

*
*   CoCo XT Hard Disk Driver  Version 2.0
*
*
*   For Western Digital WD1002-WX2 (or WX1) Controller.
*
*   This is a general purpose driver.  It can handle
*   1-4 hard drives, the parameters of which are described
*   in the device descriptors.  The drives may be of different
*   sizes.  This version is optimized for the CoCo 3 under level
*   2 OS9.  It does not mess with the clock speed -- the native
*   speed is used.  It also verifies disk writes, and uses
*   read caching.  This version ccan format the hard drive.
*

*
*   Chris Burke  Schaumburg, IL  01/26/88
*

                    page
*
*  Conditional assembly control
*

*Drives  equ     2           ;Number of drives supported
Drives              equ       4                   ;Number of drives supported (2 per controller)

irqflg              equ       0                   ;non-zero to mask interrupts during HD access
trsflg              equ       0                   ;non-zero if optimized for 4 heads, 32 SPT
cchflg              equ       1                   ;non-zero if read cache supported
vrfflg              equ       1                   ;non-zero if write verification supported
tboflg              equ       0                   ;non-zero if jump to 2 MHz for block moves
fstflg              equ       1                   ;non-zero if fast transfers supported
sysram              equ       1                   ;non-zero to use system RAM for verf buffer
sizflg              equ       1                   ;non-zero to allow drives of different sizes

fmtflg              equ       1                   ;non-zero if hard formatting supported
errflg              equ       1                   ;non-zero for good error messages
icdflg              equ       0                   ;non-zero to ignore C/D status bit
timflg              equ       0                   ;non-zero to support access timer

XLEVEL              equ       2                   ;Bogus level 2 flag

testing             equ       0                   ;non-zero to call driver "XD", not "HD"

*
*   Include the main line
*

                    use       xtos9.src

