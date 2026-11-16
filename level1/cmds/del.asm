********************************************************************
* Del - File deletion utility
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   5      ????/??/??  Kim Kempf
* From Tandy OS-9 Level One VR 02.00.00.
*
*   6      2003/01/13  Boisy G. Pitre
* Now option can be anywhere on command line, and all files will be
* deleted.  Also made smaller.
*
*   6      2025/05/05  Boisy G. Pitre
* Added Microware comments from Soren Roug's Microware sources.
*
*   7      2026/11/16  Mark Murray
* Added -r to delete directories and everything in them.

 nam Del
 ttl File deletion utility

 ifp1
 use defsfile
 use readdir.d
 endc

DOHELP set 0

tylg set Prgrm+Objct
atrv set ReEnt+rev
rev set $00
edition set 7

* Longest pathlist -r builds. A directory level adds at least two
* characters, so the stack below covers the deepest tree this allows.
PATHMAX equ 256
FRAMESZ equ 7 bytes of stack DelDirOpen keeps for each level

 mod eom,name,tylg,atrv,start,size

 org 0
amode rmb 1
recurse rmb 1 nonzero when -r was given
lasterr rmb 1 last error reported by -r
cleared rmb 1 nonzero when the directory attribute was cleared
pathend rmb 2 address of the carriage return ending pathbuf
argptr rmb 2 next command line argument for -r
fdattr rmb 3 attributes and owner from the file descriptor
record rmb RD.Size directory entry, or the path options
pathbuf rmb PATHMAX pathlist of the file being deleted
 rmb (PATHMAX/2)*(FRAMESZ+2)+250 stack room
stack rmb 200 parameter room
size equ .

name fcs /Del/
 fcb edition

 ifne DOHELP
HelpMsg fcb C$LF
 fcc "Use: Del [-rx] <path> {<path>} [-rx]"
 fcb C$CR
 endc

start lda ,x get first char on command line
 cmpa #C$CR carriage return?
 beq ShowHelp if so, no params, show help
 lda #READ.
 sta <amode default to non-sys delete
 clr <recurse default to deleting files only
 clr <lasterr no errors reported yet
 pshs x save param pointer
 bsr GetOpts get opts
 puls x get param pointer
 tst <recurse was -r given?
 bne DelRArgs branch if so
Del07 lda <amode
 os9 I$DeletX
 bcs Exit branch if error
 lda ,x get next byte
 cmpa #C$CR end of line?
 bne Del07 branch if more
ExitOk clrb
Exit os9 F$Exit

GetOpts ldd ,x+ parse parameters
 cmpa #C$SPAC
 beq GetOpts skip spaces
 cmpa #C$COMA
 beq GetOpts skip commas
 cmpa #C$CR
 beq Return skip carriage return
 cmpa #'- option delimiter
 bne SkipName no, branch
 lda #C$SPAC get a space
 sta -1,x write over the option delimiter
 bsr GetOpt the delimiter must be followed by an option
OptLoop lda ,x get the next character
 cmpa #C$SPAC end of the options?
 beq GetOpts branch if so
 cmpa #C$COMA end of the options?
 beq GetOpts branch if so
 cmpa #C$CR end of the options?
 beq GetOpts branch if so
 bsr GetOpt process the option
 bra OptLoop and look for another

GetOpt lda ,x get the option letter
 anda #$DF make it upper case
 cmpa #'X is it execution directory option?
 bne GetOpt2 branch if not
 ldb #EXEC. get execution mode
 stb <amode save it
 bra GetOpt3 write over the option
GetOpt2 cmpa #'R is it the recursive option?
 bne ShowHelp branch if not
 inc <recurse delete directories too
GetOpt3 lda #C$SPAC get a space
 sta ,x+ write over the option
 rts

SkipName lda ,x+ get char
 cmpa #C$SPAC
 beq GetOpts skip spaces
 cmpa #C$COMA
 beq GetOpts skip commas
CheckCR cmpa #C$CR
 bne SkipName branch if not
Return rts

ShowHelp equ *
 ifne DOHELP
 leax >HelpMsg,pcr
 ldy #80
 lda #2 stderr
 os9 I$WritLn write help
 endc
 bra ExitOk

* Delete each argument with -r. Report every failure and carry on, then
* exit with the last error.
DelRArgs lda ,x get the next character
 cmpa #C$SPAC is it a space?
 beq DelRSkip skip it if so
 cmpa #C$COMA is it a comma?
 beq DelRSkip skip it if so
 cmpa #C$CR end of the command line?
 beq DelRDone branch if so
 leay pathbuf,u copy the argument into the path buffer
DelRCopy lda ,x get a character of the argument
 cmpa #C$SPAC end of the argument?
 beq DelRStrip branch if so
 cmpa #C$COMA end of the argument?
 beq DelRStrip branch if so
 cmpa #C$CR end of the argument?
 beq DelRStrip branch if so
 sta ,y+ copy the character
 leax 1,x move to the next character
 pshs y save the end of the copy
 leay pathbuf+PATHMAX-1,u get the last usable byte of the buffer
 cmpy ,s has the copy reached it?
 puls y restore the end of the copy
 bhi DelRCopy branch if not
 bsr DelREnd end the path where the copy stopped
 bsr SkipArg skip the rest of the argument
 ldb #E$BPNam the pathlist is too long
 bra DelRFail report it
DelRStrip pshs x save the command line
DelRStr2 leax pathbuf,u get the start of the path buffer
 pshs x save it
 cmpy ,s++ is the path empty?
 beq DelRStr3 branch if so
 lda -1,y get the last character of the path
 cmpa #PDELIM is it a trailing separator?
 bne DelRStr3 branch if not
 leay -1,y drop the separator
 bra DelRStr2 and look for another
DelRStr3 puls x restore the command line
 bsr DelREnd end the path
 bsr CheckPath refuse dot names and device roots
 bcs DelRFail report the error
 lbsr DelPath delete the file or the directory tree
 bcc DelRNext branch if it went well
 tstb has the error been reported?
 beq DelRNext branch if so
DelRFail lbsr Report report the error
DelRNext ldx <argptr get the rest of the command line
 bra DelRArgs and delete the next argument
DelRSkip leax 1,x move past the separator
 bra DelRArgs and look again
DelRDone ldb <lasterr exit with the last error
 os9 F$Exit

* Y=end of the path in pathbuf, X=command line. End the path there.
DelREnd lda #C$CR get a carriage return
 sta ,y end the path with it
 sty <pathend save the end of the path
 stx <argptr save the rest of the command line
 rts

* Skip the rest of an argument too long for the path buffer.
SkipArg ldx <argptr get the rest of the command line
SkipArg2 lda ,x get a character
 cmpa #C$SPAC end of the argument?
 beq SkipArg3 branch if so
 cmpa #C$COMA end of the argument?
 beq SkipArg3 branch if so
 cmpa #C$CR end of the argument?
 beq SkipArg3 branch if so
 leax 1,x move to the next character
 bra SkipArg2 and check it
SkipArg3 stx <argptr save the rest of the command line
 rts

* Refuse to delete a path whose last name is only dots, or which names
* a whole device, since either would delete a directory above it.
CheckPath leay pathbuf,u get the start of the path
 ldx <pathend get the end of the path
 pshs y save the start of the path
ChkPath2 cmpx ,s is this the start of the path?
 beq ChkPath4 branch if so
 lda ,-x get the previous character
 cmpa #PDELIM is it a separator?
 bne ChkPath2 branch if not
 cmpx ,s is it the separator before a device name?
 beq ChkPathBad refuse the path if so
 leax 1,x point to the last name
ChkPath4 cmpx <pathend has the whole last name been checked?
 beq ChkPathBad branch if it was empty or only dots
 lda ,x+ get a character of the last name
 cmpa #'. is it a dot?
 beq ChkPath4 branch if so
 clrb no error
 puls y,pc the path is acceptable
ChkPathBad puls y discard the start of the path
 ldb #E$BPNam refuse the path
 orcc #Carry return the error
 rts

* Delete the file or directory tree named in pathbuf. Return with carry
* set and B=0 when the errors have already been reported.
DelPath lda <amode get the access mode
 ora #DIR.+READ. open it as a directory
 leax pathbuf,u point to the path
 os9 I$Open is it a directory?
 bcc DelDirOpen branch if so
DelFile lda <amode get the access mode
 leax pathbuf,u point to the path
 os9 I$DeletX delete the file
DelFileRet rts

* Delete the directory named in pathbuf and everything in it.
DelDir lda <amode get the access mode
 ora #DIR.+READ. open it as a directory
 leax pathbuf,u point to the path
 os9 I$Open open the directory
 bcs DelFileRet return the error if that failed

* A=directory path. Each entry is deleted while the directory stays
* open, except that it is closed while a subdirectory is deleted, so
* the tree depth doesn't depend on the number of free paths. On
* reopening, the entries that couldn't be deleted are skipped.
* Frame: 0,s=path 1,s=entries that failed 3,s=entries to skip
* 5,s=end of this directory's path
DelDirOpen ldx <pathend get the end of this directory's path
 pshs x save it
 ldx #0 get a zero count
 pshs x no entries to skip
 pshs x no entries have failed
 pshs a save the path
DDNext lda ,s get the directory path
 leax record,u point to the entry buffer
 ldy #RD.Size ask for the name and the attributes
 lbsr ReadDirCompat read the next entry
 bcs DDEnd branch at the end or on an error
 ldd 3,s are there entries to skip?
 beq DDUse branch if not
 subd #1 count the skipped entry
 std 3,s save the count
 bra DDNext and read the next entry
DDUse lbsr AddName add the entry's name to the path
 bcs DDFailRep report it if the path is too long
 lda record+RD.Attr,u get the entry's attributes
 bita #DIR. is it a directory?
 bne DDSub branch if so
 bsr DelFile delete the file
 bcc DDRestore branch if it went well
DDFailRep lbsr Report report the error
 ldd 1,s get the count of entries that failed
 addd #1 count this one
 std 1,s save the count
DDRestore lbsr DDTrunc remove the entry's name from the path
 bra DDNext and read the next entry
DDSub lda ,s get the directory path
 os9 I$Close close it while the subdirectory is deleted
 bsr DelDir delete the subdirectory
 bcc DDReopen branch if it went well
 tstb has the error been reported?
 beq DDFail2 branch if so
 lbsr Report report the error
DDFail2 ldd 1,s get the count of entries that failed
 addd #1 count this one
 std 1,s save the count
DDReopen ldd 1,s get the count of entries that failed
 std 3,s skip them after reopening
 bsr DDTrunc remove the entry's name from the path
 lda <amode get the access mode
 ora #DIR.+READ. open it as a directory
 leax pathbuf,u point to this directory's path
 os9 I$Open reopen the directory
 bcs DDOpenErr branch if that failed
 sta ,s save the new path
 bra DDNext and read the next entry
DDOpenErr lbsr Report report the error
 bra DDRet0 and give up on this directory
DDEnd cmpb #E$EOF end of the directory?
 beq DDDone branch if so
 pshs b save the error
 lda 1,s get the directory path
 os9 I$Close close it
 puls b restore the error
 lbsr Report report the error
 bra DDRet0 and give up on this directory
DDDone ldd 1,s did any entry fail?
 beq DDRemove branch if not
 lda ,s get the directory path
 os9 I$Close close it
 bra DDRet0 the directory can't be deleted
DDRemove lda ,s get the directory path
 lbsr ClearDir allow RBF to delete the directory
 bcs DDCloseErr branch if that failed
 lda ,s get the directory path
 os9 I$Close close it
 lbsr DelFile delete the directory
 bcc DDOk branch if it went well
 pshs b save the error
 lbsr RestoreDir make it a directory again
 puls b restore the error
 bra DDErr and return it
DDCloseErr pshs b save the error
 lda 1,s get the directory path
 os9 I$Close close it
 puls b restore the error
DDErr leas FRAMESZ,s discard the frame
 orcc #Carry return the error
 rts
DDOk leas FRAMESZ,s discard the frame
 clrb no error
 rts
DDRet0 leas FRAMESZ,s discard the frame
 clrb the errors have been reported
 orcc #Carry return a failure
 rts

* Remove the entry's name from the path. The frame is 2 bytes deeper.
DDTrunc ldx 7,s get the end of this directory's path
 lda #C$CR get a carriage return
 sta ,x end the path there
 stx <pathend save the end of the path
 rts

* Add a separator and the entry's name to the path.
AddName ldd <pathend get the end of the path
 leax pathbuf+PATHMAX-RD.ID-2,u get the last place any name fits
 pshs x save it
 cmpd ,s++ does the name fit?
 bhi AddNameBad branch if not
 tfr d,x point to the end of the path
 leay record+RD.Name,u point to the entry's name
 lda #PDELIM get a separator
AddName2 sta ,x+ add the character to the path
 lda ,y+ get a character of the name
 bpl AddName2 branch if it isn't the last
 anda #$7F clear the end of name marker
 sta ,x+ add the last character
 lda #C$CR get a carriage return
 sta ,x end the path with it
 stx <pathend save the end of the path
 clrb no error
 rts
AddNameBad ldb #E$BPNam the pathlist is too long
 orcc #Carry return the error
 rts

* A=directory path. RBF deletes a directory only once its directory
* attribute is cleared; other file managers delete directories as they
* are. As with attr, only the owner or the superuser may clear it.
ClearDir clr <cleared the attribute hasn't been cleared
 pshs a save the path
 leax record,u point to the options buffer
 ldb #SS.Opt get the path options
 os9 I$GetStt
 bcs ClearRet return the error
 lda record,u get the device type
 cmpa #DT.RBF is it RBF?
 bne ClearOk branch if not
 lda ,s get the path
 leax fdattr,u point to the descriptor buffer
 ldy #FD.OWN+2 get the attributes and the owner
 ldb #SS.FD read the file descriptor
 os9 I$GetStt
 bcs ClearRet return the error
 os9 F$ID get the user number
 cmpy #0 is it the superuser?
 beq ClearOwn branch if so
 cmpy fdattr+FD.OWN,u is it the owner?
 beq ClearOwn branch if so
 ldb #E$FNA the directory isn't accessible
 orcc #Carry return the error
 bra ClearRet
ClearOwn lda fdattr+FD.ATT,u get the attributes
 anda #^DIR. clear the directory attribute
 sta record,u save them
 lda ,s get the path
 leax record,u point to the attributes
 ldy #1 write only the attributes
 ldb #SS.FD write the file descriptor
 os9 I$SetStt
 bcs ClearRet return the error
 inc <cleared remember to restore it if the delete fails
ClearOk clrb no error
ClearRet puls a,pc restore the path

* Set the directory attribute again on the file named in pathbuf.
RestoreDir tst <cleared was the attribute cleared?
 beq RestRet branch if not
 lda <amode get the access mode
 leax pathbuf,u point to the path
 os9 I$Open open the file
 bcs RestRet nothing more can be done if that failed
 pshs a save the path
 leax fdattr+FD.ATT,u point to the original attributes
 ldy #1 write only the attributes
 ldb #SS.FD write the file descriptor
 os9 I$SetStt
 puls a restore the path
 os9 I$Close close the file
RestRet rts

* B=error. Write the path and the error to the standard error path.
Report pshs b,x,y,u save the error and the registers
 stb <lasterr remember the error for the exit status
 leax pathbuf,u point to the path
 ldd <pathend get the end of the path
 pshs x save the start of the path
 subd ,s++ get the length of the path
 tfr d,y write that many characters
 lda #2 to the standard error path
 os9 I$Write write the path
 leax ErrSep,pcr point to the separator
 ldy #2 write two characters
 lda #2 to the standard error path
 os9 I$Write write the separator
 ldb ,s get the error
 os9 F$PErr write the error
 puls b,x,y,u,pc restore the registers

ErrSep fcc ": "

 use ../level1/cmds/readdir-compat.asm

 emod
eom equ *
 end
