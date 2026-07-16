PROCEDURE IDE_detect
(* IDE identify program
(* Do not have IDE driver enabled
(* while running this program!
(* Copyright 1996 By Jim Hathaway
(* Revised version 2 by L. Curtis Boyle, May, 1999
(* Version 2.1 by L. Curtis Boyle, Oct. 13/1999 - to handle ATAPI
(* Slight changes Oct. 20/1999 to show # of sectors in both hex & decimal
(* Changed to make it easier for changing controller address, and for handling
(* both the Master & Slave drives
(* - also bug fix (LBA mode was not detected correctly)
DIM bignum:REAL
DIM prompt:STRING[2]
DIM driveaccessmsg(4),driveerrors(5):STRING[32]
DIM ide(512):BYTE
(* 0=haven't checked yet, 1=found & ok, 2=not found, 3=found & error
DIM drivefound(2):INTEGER
DIM ready:INTEGER
DIM temp:BYTE
DIM counter:INTEGER
DIM driveselect(2):BYTE
DIM drivenumber:INTEGER
DIM baseaddress:REAL
DIM idestatus:BYTE
DIM ideerror:BYTE
DIM undon(2):BYTE
DIM undoff(2):BYTE
DIM invon(2):BYTE
DIM invoff(2):BYTE
undon(1)=$1f
undon(2)=$22
undoff(1)=$1f
undoff(2)=$23
invon(1)=$1f
invoff(1)=$1f
invon(2)=$20
invoff(2)=$21
driveaccessmsg(1)="Has not been checked"
driveaccessmsg(2)="Found & Ok"
driveaccessmsg(3)="Not found"
driveaccessmsg(4)="Found with error"
drivefound(1)=0
drivefound(2)=0
driveerrors(1)="No error detected"
driveerrors(2)="Formatter device error"
driveerrors(3)="Sector buffer error"
driveerrors(4)="EC circuitry error"
driveerrors(5)="Controlling microprocessor error"

driveselect(1)=$A0
driveselect(2)=$B0
PRINT CHR$(12);"IDE Detection program Version 2.1"
PRINT "Version 1.0 Copyright 1996 by Jim Hathaway"
PRINT "Version 2.1 Copyright Oct, 1999 by L. Curtis Boyle"
PRINT "Will detect both ATA and ATAPI devices."
(* Programmer's note: If this program checked and changed the busy flag in the
(* IDE driver's mem, we _COULD_ theoretically flag the driver busy while this
(* program is running.. although we would have to cheat like mad with the MMU
(* to accomplish this...
PRINT "Make sure you are NOT running an IDE driver while running this program!"
PRINT "If you are, hit <BREAK> now!"
PRINT "If you get bizarre results with a 2 drive system, make sure your Master/Slave"
PRINT "jumper settings don't conflict.  The Ask Jeeves search engine (www.aj.com)"
PRINT "on the Internet has a lot of drive tech info available, including jumper"
PRINT "settings."
PRINT "Please select base address of controller:"
PRINT "<1> $FF50"
PRINT "<2> $FF70"
5 INPUT "Select <1-2>:";counter
IF counter<>1 AND counter<>2 THEN 5
IF counter=1 THEN
  baseaddress=65360.
ELSE
  baseaddress=65392.
ENDIF

(* Start with drive 0
drivenumber=1

(* Select drive 0 in NON-LBA mode, and do a Execute Drive Diagnostic command
10 POKE baseaddress+6.,driveselect(drivenumber)
POKE baseaddress+7.,$90

(* Need both DRDY (Drive Ready) & DSC (Drive Seek Complete) flags set
ready=$50
counter=5000
WHILE counter>0 DO
  idestatus=PEEK(baseaddress+7.)
EXITIF idestatus=ready THEN
ENDEXIT
EXITIF LAND(idestatus,1)<>0 THEN
  PRINT "Error detected during Drive Diagnostic"
  ideerror=PEEK(baseaddress+1.)
  temp=LAND(ideerror,$7f)
  IF temp>1 THEN
    PRINT "Error on drive 0"
    drivefound(1)=3
    IF temp<6 THEN
      PRINT driveerrors(temp)
    ELSE
      PRINT " - unknown error # $";
      PRINT USING "H2",ideerror
    ENDIF
  ENDIF
  IF ideerror>=$80 THEN
    PRINT "Error on drive 1"
    drivefound(2)=3
    POKE baseaddress+6.,driveselect(2)
    counter=5000
    REPEAT
      idestatus=PEEK(baseaddress+7.)
    UNTIL LAND(idestatus,$80)=0 OR counter=0
    ideerror=PEEK(baseaddress+1.)
    IF ideerror>0 AND ideerror<6 THEN
      PRINT " - ";driveerrors(ideerror)
    ELSE
      PRINT " - unknown error # $";
      PRINT USING "H2",ideerror
    ENDIF
  ENDIF
ENDEXIT
EXITIF idestatus=0 THEN
  PRINT "IDE cable may be plugged in, but no power to drive 0"
  counter=0
ENDEXIT
  counter=counter-1
ENDWHILE
IF counter=0 THEN
  PRINT "Error: Drive 0 did not respond to Drive Diagnostic command!!!!"
  drivefound(1)=2
ELSE 
  IF drivefound(1)=0 THEN
    PRINT "Drive 0 responded to Drive Diagnostic command"
    drivefound(1)=1
  ENDIF
ENDIF

(* Now, select drive 1 - check if it is there
POKE baseaddress+6.,driveselect(2)
REPEAT
  idestatus=PEEK(baseaddress+7.)
UNTIL LAND(idestatus,$80)=0
IF LAND(idestatus,1)<>0 OR LAND(idestatus,$20)<>0 THEN
  PRINT "Error flag or Write Fault flag set on status register for drive 1"
  IF LAND(idestatus,1)=1 THEN
    ideerror=PEEK(baseaddress+1.)
    PRINT "Drive 1 error code=$";
    PRINT USING "h2",iderror
  ELSE
    PRINT "Write Fault flag set - drive probably not plugged in"
    drivefound(2)=2
  ENDIF
ENDIF
IF drivefound(2)<>3 AND drivefound(2)<>2 THEN
  IF idestatus=0 THEN
    PRINT "There does not appear to be a drive 1"
    drivefound(2)=2
  ENDIF
  IF drivefound(2)=0 THEN
    drivefound(2)=1
  ENDIF
ENDIF
PRINT

(* Select drive and identify
FOR drivenumber=1 TO 2
  PUT #1,undon
  PRINT "Checking drive ";drivenumber-1
  PUT #1,undoff
  IF drivefound(drivenumber)=1 THEN
    PRINT "Sending IDE identify device command to drive ";drivenumber-1
    POKE baseaddress+6.,driveselect(drivenumber)
    POKE baseaddress+7.,$ec
    counter=2000
    REPEAT
      counter=counter-1
    UNTIL PEEK(baseaddress+7.)=ready+8 OR counter=0
    IF counter=0 THEN
      POKE baseaddress+7.,$a1
      counter=2000
      REPEAT
        counter=counter-1
      UNTIL PEEK(baseaddress+7.)=ready+8 OR counter=0
    ELSE
      PRINT "ATA Identified:"
      GOTO 20
    ENDIF
    IF counter=0 THEN
      PRINT "ERROR: Could not identify either ATA or ATAPI!"
      END
    ELSE
      PRINT "ATAPI Identified:"
    ENDIF
20  FOR counter=1 TO 512 STEP 2
      ide(counter+1)=PEEK(baseaddress)
      ide(counter)=PEEK(baseaddress+8.)
    NEXT counter
    PRINT "Model#=           ";
    PUT #1,invon
    FOR counter=55 TO 90
      PRINT CHR$(ide(counter)); 
    NEXT counter
    PUT #1,invoff
    PRINT 
    PRINT "Firmware Revision=";
    PUT #1,invon
    FOR counter=47 TO 54
      PRINT CHR$(ide(counter));
    NEXT counter
    PUT #1,invoff
    PRINT
    PRINT "Serial#=          "; 
    PUT #1,invon
    FOR counter=21 TO 41
      PRINT CHR$(ide(counter)); 
    NEXT counter
    PUT #1,invoff
    PRINT 
    PRINT USING "'Configuration=0x',H2,H2", ide(1), ide(2)
    PRINT "Logical Cyls="; ide(3)*256+ide(4)
    PRINT "Logical Heads="; ide(7)*256+ide(8)
    PRINT "Logical Sectors="; ide(13)*256+ide(14)
(* Note: not using ide(115-118) for CHS sector count, since some older ATA-1
(* drives do NOT report it correctly.
    bignum=(ide(3)*256.+ide(4))*(ide(7)*256.+ide(8))*(ide(13)*256.+ide(14))
    PRINT USING "'# of user addressable sectors in CHS mode=',x13,R10.0";bignum
    IF ide(96)=0 THEN 
      PRINT "READ/WRITE multiple not supported"
    ELSE
      PRINT ide(96); " Sectors per READ/WRITE multiple"
    ENDIF 
(* Bug fix - originally checked if equal to 1 (which it NEVER would be, since
(*   we are LANDing the 2ND bit!)
    IF LAND(ide(99),2)=2 THEN
      PRINT "LBA is supported"
      bignum=16777216.*ide(123)+65536.*ide(124)+256.*ide(121)+ide(122)
      PRINT USING "'# of user addressable sectors in LBA mode=$',h2,h2,h2,h2,x4,R10.0";ide(123),ide(124),ide(121),ide(122),bignum
    ELSE 
      PRINT "LBA is not supported"
    ENDIF 
    PRINT "PIO data tranfer cycle timing="; ide(103)
    PRINT "Current logical cylinders="; ide(109)*256+ide(110)
    PRINT "Current logical heads="; ide(111)*256+ide(112)
    PRINT "Current logical Sectors="; ide(113)*256+ide(114)
    PRINT
    INPUT "Press <ENTER> to continue:";prompt
  ELSE
    PRINT "Drive ";drivenumber-1;" not accessable:";
    PRINT driveaccessmsg(drivefound(drivenumber)+1)
  ENDIF
NEXT drivenumber
PRINT "Program finished."
END
