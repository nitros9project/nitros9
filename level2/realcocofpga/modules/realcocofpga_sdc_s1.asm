         nam   S1
         ttl	Virtual Disk Device Descriptor for MatchboxSDC

        use       os9.d
        use       rbf.d
        use       coco.d

Type     set   Devic+Objct
Revs     set   Reent+3   

Step30   equ   0         
Step20   equ   1         
Step12   equ   2         
Step06   equ   3         

* USER CHANGEABLE SETTINGS
Drive	set	1	OS-9 drive number (0-3)
DrvTyp	set   $84	hard drive + entire partition
StpRat	set   Step30	drive stepping rate code
Cyls	set   $1AAA	number of cylinders (tracks per side)
SecTrk	set   18	number of sectors per track
SecTr0	set   18	number of sectors per track (track 0, side 0)
Density	set   0		48 tpi, MFM
Sides	set   1		number of sides (1 or 2)
Verify	set   1		verify off

* MODULE HEADER AND FIXED INFORMATION
         mod   DescEnd,DescName,Type,Revs,DscMgr,DscDrv
         fcb   DIR.+SHARE.+PREAD.+PWRIT.+UPDAT.+EXEC.+PEXEC.

         fcb   $00        port bank			1=entire partition drive
         fdb   $ff70      port address
         fcb   OptEnd-*-1 number of bytes in option section below

* OPTION TABLE
	fcb	DT.RBF     device type = RBF					0 offsets
	fcb	Drive      drive number						1
	fcb	StpRat     step rate code					2
	fcb	DrvTyp    							3
	fcb	Density   							4
	fdb	Cyls       number of cylinders					5
	fcb	Sides     							7
	fcb	Verify     verify						8
	fdb	SecTrk    							9
	fdb	SecTr0    							11
	fcb	0		sector interleave offset factor			13
	fcb	8		minimum sector allocation size			14
	fcb	0		(WAS reserved, now indicates uDrive 0-255)	15
	fdb	0		(reserved)					16
	fcb	$10		sector/track offset (CoCo OS-9 disk format)	18
OptEnd   equ   *

* NAME STRINGS
DescName fcs   "S1"
DscMgr   fcs   "RBF"
DscDrv   fcs   "MatchboxSDC"

         emod            
DescEnd  equ   *         
         end             
