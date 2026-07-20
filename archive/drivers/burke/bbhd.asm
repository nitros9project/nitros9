*******************************************
***                                     ***
***     COPYRIGHT 1988 BURKE & BURKE    ***
***     ALL RIGHTS RESERVED             ***
***                                     ***
*******************************************

                    nam       BBHD

*
*   CoCo XT Hard Disk Driver  Version 2.0
*   (with formatting capability)
*
*
*   For Western Digital WD1002-WX2 (or WX1) Controller.
*
*   This version is optimized for ONE hard drive having 4
*   heads and 32 sectors per track.  There is no formatting
*   capability and no write verification.
*
*   The number of tracks is taken from the device descriptor,
*   so this driver can be used with ST-506, ST-412, ST-225 or
*   ST-238 drives.  This version DOES include the read cache.
*   It has the cruddy error messages.

*
*   Chris Burke  Schaumburg, IL  02/22/88
*

                    page
*
*  Conditional assembly control
*

Drives              equ       1                   ;Number of drives supported

irqflg              equ       0                   ;non-zero to mask interrupts during HD access
trsflg              equ       1                   ;non-zero if optimized for 4 heads, 32 SPT
cchflg              equ       1                   ;non-zero if read cache supported
vrfflg              equ       0                   ;non-zero if write verification supported
tboflg              equ       0                   ;non-zero if jump to 2 MHz for block moves
fstflg              equ       1                   ;non-zero if fast transfers supported
sysram              equ       1                   ;non-zero to use system RAM for verf buffer
sizflg              equ       0                   ;non-zero to allow drives of different sizes

fmtflg              equ       0                   ;non-zero if hard formatting supported
errflg              equ       0                   ;non-zero for good error messages
icdflg              equ       0                   ;non-zero to ignore C/D status bit
timflg              equ       0                   ;non-zero to support access timer

XLEVEL              equ       2                   ;Bogus level 2 flag

testing             equ       0                   ;non-zero to call driver "XD", not "HD"

*
*   Include the main line
*

                    use       xtos9.src

