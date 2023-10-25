                    nam       GShell              Graphics Shell
                    ttl       Source derived by Kent D. Meyers.

* Signal handlers will have to handle new RBF call for directory updates
* DIR has to be open (uses path #), but can be in READ+DIR mode
*  Renames, etc. will have to close DIR 1st, do function, re-open.

* Compressed Version. Started February 7, 1988. Completed February 29.
* Upgraded Version. Started March 2, 1988. Finished by KDM Feb 13, 1994
* NITROS9 ONLY VERSION. Started August 8,1998 by LCB
* NOTE: When GSHPAL added, got rid of DEVICSET, and 2 other SETS from env.file
*       check in DP (3 DP bytes back)
* NOTE: HAVE TRIED 5 ROWS OF ICONS (ICONYMAX=143, ICONROWH=32, ICONSCR=20), &
*       IT FITS, BUT LOOKS REALLY CROWDED. IF WE MAKE THE NEW "SYSTEM" 6 PIXEL
*       WIDE FONT ALSO SHORTER (LIKE FONT #$27, WHICH IS THE 8 PIXEL WIDE VERSION)
*       IT MIGHT WORK THEN.
* Killed all calls to F.SLEEP, embedded (shorter & faster)
* Should do F$CpyMem of <$40-43 in direct page to get real RAM size - both
*   6809 and NitrOS9. Then we can eliminate RAM= from the Env.fil entirely!

* NOTE (6309 ONLY): ALL STD -2,S TO CHECK THE D FLAG CAN BE CHANGED TO TSTD
*(SAME SIZE, FASTER)

* EOS (Ease of Use) modifications:
* LCB- 12/15/2017 - New printer and trash can icons from Nick Marentes (and trash can position)
*
                    ifp1
                    use       defsfile
                    endc

BTEXT               mod       MODSIZE,MODNAME,$11,$81,CSTART,DATASIZE

* COMPLETE DEFS FOR THIS ASSEMBLY.

ICNONSCR            equ       16                  # icons on screen in 40 column mode

* Standard character defs
NUL                 equ       C$NULL
BEL                 equ       C$BELL
HT                  equ       $09
LF                  equ       C$LF
FF                  equ       $0C
CR                  equ       C$CR
SPACE               equ       C$SPAC

* GShell specific Data Structures.

                    org       0
* File info - linked list for each icon
FL.XSTRT            rmb       2                   X start position of icon \   These are for determining if
FL.YSTRT            rmb       2                   Y start position of icon  \  mouse clicks are on a particular
FL.XEND             rmb       2                   X end position of icon    /  icon or not.
FL.YEND             rmb       2                   Y end position of icon   /
FL.ICONO            rmb       1                   Icon type (IC.*)
FL.AIFNO            rmb       1                   AIF # (entry # to look in ID.* table)
FL.LINK             rmb       2                   Link to next FL.* entry
FL.FNAME            rmb       2                   Ptr to filename
FL.SIZE             equ       .

                    org       0
* Structure for table entries for executable programs to fork into new
*   windows - called process tables here (see PTBL* vars)
GD.MNAME            rmb       2                   Module name ptr?
GD.INDVC            rmb       2                   ??? Ptr to ?
GD.PRCID            rmb       2                   Process ID # for new process
GD.STATS            rmb       2                   Last status of forked program (errors, etc.)
GD.MTYPE            rmb       1                   Module type
GD.MLANG            rmb       1                   Module language
GD.MEMSZ            rmb       2                   Mem size required
GD.WPATH            rmb       2                   Path to window
GD.DW.OW            rmb       2                   Process running in overlay window flag: 1=Yes, else NO
GD.XSTRT            rmb       2                   Start X,Y coords of window
GD.YSTRT            rmb       2
GD.XEND             rmb       2                   End X,Y coords of window
GD.YEND             rmb       2
GD.SCRNO            rmb       2                   Screen #
GD.LINK             rmb       2                   Link to next GD.* entry
GD.SIZE             equ       .

* Defs for table entries of AIF data
* NOTE: all ID.NUMBR's below IC.XTRNL ($14) are for internal AIF structures,
*   not from actual read in AIF files ($f-$13 are currently unused?)
                    org       0
ID.NUMBR            rmb       2                   Entry # in ID.* structure (only 2nd byte is used)
ID.WTYPE            rmb       2                   Window type for AIF program
ID.XSIZE            rmb       2                   Minimum window X size for AIF program
ID.YSIZE            rmb       2                   Minimum window Y size for AIF program
ID.FRGND            rmb       2                   Window foreground color for AIF program
ID.BKGND            rmb       2                   Window background color for AIF program
ID.MEMSZ            rmb       2                   Data area size for AIF program
ID.MNAME            rmb       2                   Ptr to module name for AIF program
ID.XXXPT            rmb       2                   ??? Ptr to AIF 3 letter extension?
ID.PARAM            rmb       2                   Ptr to parameters for AIF program
ID.LINK             rmb       2                   Ptr to next ID.* structure in linked list
ID.SIZE             equ       .

* Structure for screens used table (maximum of 8)
                    org       0
SC.PTHNO            rmb       1                   Path number to screen
SC.WTYPE            rmb       1                   Full screen background window type
SC.USERS            rmb       1                   # of users (programs) active on screen
                    rmb       1                   ??? reserved space?
SC.SIZE             equ       .

* Icon descriptor identifiers (reserved ones). For programs, they will have
*   there own entry for running in a new window (?)
* These are stored in Fl.ICONO
* NOTE: A NEW VERSION OF COCOPR SHOULD BE WRITTEN TO HANDLE GRAPHIC SCREEN
* DUMPS OF VEF'S. IT SHOULD ALSO ALLOW -F (FORMFEED AFTER TRAILER) AS AN
* OPTION FROM THE ENV.FILE
IC.TEXT             equ       $0001               Text file identifier
IC.FOLDR            equ       $0002               Folder (directory) identifier
IC.PRGRM            equ       $0003               Program (executable) identifier
IC.CLOSE            equ       $0004               Close box
IC.DRIVE            equ       $0005               Drive icon
IC.AIF.F            equ       $0006               ??? AIF for a single program
IC.F.XXX            equ       $0007               ??? AIF for an extension already allocated
IC.DRBAR            equ       $0008               Drive bar (top of current dir window)
IC.TRASH            equ       $0009               Trash can (delete from file menu)
IC.GCALC            equ       $000A               Calculator off of Tandy menu
IC.GCLOK            equ       $000B               Clock off of Tandy menu
IC.GCAL             equ       $000C               Calendar off of Tandy menu
IC.SHELL            equ       $000D               Shell off of Tandy menu
IC.QUERY            equ       $000E               '?' Help off of Tandy menu
IC.PRNTR            equ       $000F               Printer (print from file menu)
* Looks like we have room to insert 4 more entries here...
IC.XTRNL            equ       $0014               Start of external entries (from AIF files)

* Menu ID #'s
MID.CLS             equ       $0002
MID.SUP             equ       $0004
MID.SDN             equ       $0005
MID.SRT             equ       $0006
MID.SLT             equ       $0007
MID.TDY             equ       $0014
MID.FIL             equ       $0017
MID.VEW             equ       $0018
MID.DSK             equ       $0019
MID.KDM             equ       $001A

* Mouse packet variables (see manual)
PT.VALID            equ       $0000
PT.CBSA             equ       $0008
PT.CBSB             equ       $0009
PT.STAT             equ       $0016
PT.ACX              equ       $0018
PT.ACY              equ       $001A
PT.WRX              equ       $001C
PT.WRY              equ       $001E

STDOUT              equ       $0001
STDERR              equ       $0002

WT.FSWIN            equ       $0002
WT.DBOX             equ       $0004
WN.NMNS             equ       $0014
WN.SYNC             equ       $0017
WN.BAR              equ       $0020
WINSYNC             equ       $C0C0

PTR.ARR             equ       $0001
FNT.S8X8            equ       $0001
FNT.S6X8            equ       $0002
FNT.G8X8            equ       $0003
PTR.SLP             equ       $0004
PTR.ILL             equ       $0005
MOUSIGNL            equ       $000A
KYBDSGNL            equ       $000B
DIRSIG              equ       $000C               New signal for SS.FSig
MI.SIZ              equ       $0015
MI.ENBL             equ       $000F
MN.ENBL             equ       $0012
MN.SIZ              equ       $0017
WN.SIZ              equ       $0022
GRP.FNT             equ       $00C8
GRP.PTR             equ       $00CA

* OS-9 DATA AREA DEFINITIONS

                    org       0
WIPED               rmb       1                   Icons wiped flag (0=no need to redraw)
DEFWTYPE            rmb       2                   GShell's current window type (default for GCalc, GClock, etc.)
ICONCOLW            rmb       2                   Width of icon column. (in pixels)
STRTYPOS            rmb       2                   Starting Y position for the first icon on screen.
ICONYMAX            rmb       2                   Maximum Y value for displayed icons.
ICONROWH            rmb       2                   Height of icon row. (in pixels)
WINDWSZY            rmb       2                   Y size of GShell window path.
PTBLNEXT            rmb       2                   Pointer to next available process descriptor link.
FNAMEPTR            rmb       2                   Pointer to file name buffer. (null terminated)
IDSCSPTR            rmb       2                   Pointer to start of icon descriptor table.
IDSCNEXT            rmb       2                   Pointer to next available icon descriptor link
DEVICNTR            rmb       1                   Current device count. (maximum 5)
DRIVYPOS            rmb       1                   Starting Y position for first drive icon.

* The preceding are loaded at startup with default values.

STRTXPOS            rmb       2                   Starting X position for the first icon on screen.
PIXELSWD            rmb       2                   Width of GShell window in pixels.
FLAG640W            rmb       1                   640 pixels wide flag
RECDSGNL            rmb       2                   Current received signal from intercept routine.
MAXICONS            rmb       2                   Maximum number of icons per screen. (12/24)
RAMSIZE             rmb       2                   Computer's memory size. (128/512)
WNDWPATH            rmb       2                   GShell window I/O path number.
WINDWSZX            rmb       2                   X size of GShell window path.
PRCIDNUM            rmb       2                   GShell process ID number. (for GPLOAD)
SCREENOW            rmb       2                   Number of current display icon screen. (0 to n-1)
NSCREENS            rmb       2                   Number of available icon screens.
STRTICON            rmb       2                   Pointer to file icon descriptor for first icon on current screen.
FILESCTR            rmb       2                   Number of files in current data directory.
FTBLSPTR            rmb       2                   Pointer to start of file icon descriptor table.
FTBLNEXT            rmb       2                   Pointer to next available link in file icon descriptor table.
SELECTED            rmb       2                   Pointer to file icon descriptor for currently selected icon.
DEVICNOW            rmb       2                   Pointer to file icon descriptor for currently selected drive.
PTBLSPTR            rmb       2                   Pointer to start of process descriptor table.
DIRPTR              rmb       2                   Pointer to next directory entry in directory read buffer.
XFD.ATT             rmb       1                   Buffer for FD.ATT (attributes) of current directory entry.
NEXTXPOS            rmb       2                   Next X position for file icon on this screen.
NEXTYPOS            rmb       4                   Next Y position for file icon on this screen.
ACTVSCRN            rmb       2                   Number of the active process screen. (for window setup)
PROCXSIZ            rmb       2                   Minimum X size for this process.
PROCYSIZ            rmb       2                   Minimum Y size for this process.
PROCWTYP            rmb       2                   Default window type for this process.
WPOSGOOD            rmb       2                   Window OK flag. (for window setup)
DWSETSTY            rmb       2                   Actual STY byte for process window. (for window setup)

* Additions to handle GSHPALx=r,g,b commands (removed *SET ones)
CURPAL              rmb       1                   Current GSHPAL palette # being worked on
CURCOLOR            rmb       1                   Current palette value
CURGFXSZ            rmb       1                   Size of GFXBUF to write for GSHPAL values
GIPMSRES            rmb       1                   0=low res, 1=high res, $ff=not set (default=0)
GIPMSPRT            rmb       1                   1=right, 2=left, $ff=not set (default=1)
GIPKYST             rmb       1                   keyboard repeat start ($ff=not set)
GIPKYSPD            rmb       1                   keyboard repeat speed ($ff=not set)
DRTBLPTR            rmb       2                   Pointer to start of drive table.
SUREYPOS            rmb       2                   Y position for "Sure" box.
SUREXPOS            rmb       1                   X position for "Sure" box.
BXOFFSET            rmb       2                   X size for selection box.
WD48FLAG            rmb       1                   $80 if on type 7 windown.
TNDYITMS            rmb       MI.SIZ*8            Tandy Menu items array.

DISKITMS            rmb       0                   Disk Menu items array.
ITM.FREE            rmb       MI.SIZ              Free
ITM.FLDR            rmb       MI.SIZ              Folder
ITM.FMAT            rmb       MI.SIZ*4            Format

FILSITMS            rmb       0                   Files menu items array.
ITM.OPEN            rmb       MI.SIZ              Open
ITM.LIST            rmb       MI.SIZ              List
ITM.COPY            rmb       MI.SIZ              Copy
ITM.STAT            rmb       MI.SIZ              Stat
ITM.PRNT            rmb       MI.SIZ              Print
ITM.RNAM            rmb       MI.SIZ              Rename
ITM.DELT            rmb       MI.SIZ              Delete
ITM.SORT            rmb       MI.SIZ*2            Sort

VIEWITMS            rmb       0                   View Menu items array.
ITM.LRES            rmb       MI.SIZ*3            Low Res 4 Color

KDMITMS             rmb       MI.SIZ*2            KDM Menu items array.

TNDYDESC            rmb       MN.SIZ              Tandy Menu descriptor.
FILSDESC            rmb       MN.SIZ              Files Menu descriptor.
DISKDESC            rmb       MN.SIZ              Disk Menu descriptor.
VIEWDESC            rmb       MN.SIZ              View Menu descriptor.
KDMDESC             rmb       MN.SIZ              KDM Menu descriptor.

SHELLNAM            rmb       6                   "shell"
LISTNAM             rmb       5                   "list"
GCALCNAM            rmb       6                   "gcalc"
GCLOCKNM            rmb       7                   "gclock"
GCALNAM             rmb       5                   "gcal"
CONTRLNM            rmb       8                   "control"
GPRINTNM            rmb       7                   "gprint"
GPORTNAM            rmb       6                   "gport"
HELPNAM             rmb       5                   "help"
COCPRNM             rmb       7                   "cocopr"

DBOXDESC            rmb       FL.SIZE             Directory Close Box descriptor. (file icon descriptor format)
DBARDESC            rmb       FL.SIZE             Directory Bar descriptor. (file icon descriptor format)
QURYDESC            rmb       FL.SIZE             ? descriptor. (file icon descriptor format)
TRSHDESC            rmb       FL.SIZE             Trash Can descriptor. (file icon descriptor format)
PRTRDESC            rmb       FL.SIZE             Printer descriptor (file icon descriptor format)

CALCDESC            rmb       ID.SIZE             Icon descriptor for gcalc.
CLOKDESC            rmb       ID.SIZE             icon descriptor for gclock
CALDESC             rmb       ID.SIZE             icon descriptor for gcal.
SHELDESC            rmb       ID.LINK             icon descriptor for shell.
ENDLINK             rmb       2                   Terminating link for internal icon descriptors.
NXTICONO            rmb       2                   Next available external icon number.
PRESSMSG            rmb       14                  "press any key"
NEWNMSG             rmb       18                  "new name:"
SLASHW              rmb       3                   "/w"
ALLOCP              rmb       3                   "C" Variable.
STTOP               rmb       2                   "C" Variable.
MEMEND              rmb       10                  "C" Variable.  1st 2 is current upper boundary of data memory
MTOP                rmb       2                   "C" Variable.
STBOT               rmb       2                   "C" Variable.
ERRNO               rmb       2                   "C" Variable.
WINDDESC            rmb       WN.SIZ              GShell window descriptor.
DDIRNAME            rmb       256                 Full path name to current data directory.
XDIRNAME            rmb       256                 Full path name to current execution directory.
MOUSPCKT            rmb       32                  Mouse packet buffer.
FNAMBUFR            rmb       30                  File name (null terminated) for file icon descriptor setup.
DIRBUFER            rmb       2048                Read buffer for current directory information.
ICONBUFR            rmb       144                 Icon read/build buffer. (for GPLOAD)
MULTIBFR            rmb       256                 Shared buffer.
LINEBUFR            rmb       80                  80 character line input buffer.
ASCIINUM            rmb       8                   ASCII number from binary/ASCII conversion routine.
ASCIITMP            rmb       8                   Binary/ASCII temp buffer. (reversed)
PARMSBFR            rmb       256                 Command/parameters build build buffer.
AIFNMBFR            rmb       8                   AIF.xxx file name build buffer.
DNAMBUFR            rmb       32                  Directory name input buffer.
SCRNTABL            rmb       SC.SIZE*8           Process screen table.
ENVFLBFR            rmb       80                  80 character line buffer for ENV.FILE input.
GFXBUF2             rmb       4                   Graphics command build buffer. (small)
SSOPTBFR            rmb       34                  Buffer for SS.OPT information.
DRIVETBL            rmb       FL.SIZE*5           Device/Drive table.
DRVNMTBL            rmb       32*5                Device/Drive name table.
BASE                rmb       4                   "C" Variable.
SPARE               rmb       2                   "C" Variable.
GFXBUF              rmb       16                  Graphics command build buffer. (large)
* Added for mode changing palette support
GSHBUF              rmb       16                  GSHPAL0 to 3 display code buffer.
DIRPATH             rmb       1                   Path # to current dir. (added for dir monitoring)
Dirup               rmb       1                   Copy of signal code (if it was new DIR signal)
RenFlag             rmb       1                   Flag used by rename - whether to reset DIRSIG or not
NSIGN               rmb       1                   "C" Variable.
HANDLER             rmb       2                   "C" Variable.
                    ifeq      H6309
REGE                rmb       1
REGF                rmb       1
                    endc
END                 rmb       896                 "C" Variable.
DATASIZE            equ       .

MODNAME             fcs       "gshell"
                    fcb       2

* Will change to not bother preserving U, assume data area always @ 0
CSTART              pshs      Y                   Save ptr to end of parm area
                    pshs      U                   Save ptr to start of data area
                    ifne      H6309
                    clr       ,-s                 Init all of direct page to 0's
                    ldw       #256
                    tfm       s,u+
                    leas      1,s                 Eat 0 byte
                    else
                    clrb
CSTART1             clr       ,u+
                    decb
                    bne       CSTART1
                    endc
                    ldx       ,S                  Get ptr to start of data area again
                    leau      ,X                  Point U to it again
                    leax      END,X               Point to End of GSHELL data area
                    pshs      X                   Save it
                    leay      ETEXT,PC            Point to a table of initialized data (includes screen height)
                    ifne      H6309
                    ldw       ,y++                Get size of data block
                    tfm       y+,u+               Block copy initialized data
                    else
                    ldx       ,y++
CSTART2             lda       ,y+
                    sta       ,u+
                    leax      -1,x
                    bne       CSTART2
                    endc
                    ldu       2,S                 Get ptr to start of data area again
                    leau      <TNDYITMS,U         Point to Tandy Menu Items array in data area
                    ifne      H6309
                    ldw       ,y++                Get size of data block
                    tfm       y+,u+               Block copy initialized data
                    ldw       ,s                  Get end address
                    clr       ,-s                 Zero byte
                    subr      u,w                 W=Size of area to clear
                    tfm       s,u+                Clear until end of data area
                    ldu       3,s                 Get ptr to start of data area again
                    leas      5,s                 Eat zero byte & End/Start of data markers
                    else
                    ldx       ,y++
CSTART3             lda       ,y+
                    sta       ,u+
                    leax      -1,x
                    bne       CSTART3
                    ldd       ,s
                    pshs      u
                    subd      ,s++
CSTART4             clr       ,u+
                    subd      #$0001
                    bne       CSTART4
                    ldu       2,s                 Get ptr to start of data area again
                    leas      4,s                 Eat zero byte & End/Start of data markers
                    endc
                    puls      X                   Get ptr to end of parm area
                    stx       >MEMEND             Save as end of data memory ptr
                    leay      ,U                  Point Y to start of data area
                    bsr       MAIN                Call main GSHELL routine
                    ifne      H6309
                    clrd                          No error & exit
                    else
                    clra
                    clrb
                    endc
                    std       ,--s
                    lbra      EXIT

* Signal intercept trap
SAVESGNL            clra                          Save signal as D & return
                    std       RECDSGNL,U
                    cmpb      #DIRSIG             Dir update signal?
                    bne       DoneSig
                    stb       Dirup,u             Save copy (in case in middle of dir update, or stuck elsewhere)
DoneSig             rti

MAIN                pshs      U,y                 Save U
                    lbsr      SETUPENV            Setup drive tables, and read in ENV.FIL stuff
                    puls      y
                    leax      <SAVESGNL,PC        Set up intercept trap
                    tfr       Y,U                 Copy start of data area to U
                    os9       F$ICPT
* FIXWINDW only called once, embed !
                    bsr       FIXWINDW            Get window path
                    std       -2,S                Save it
                    beq       GSHABORT            Could not get path, abort
                    bsr       BILDDESC            Go build menu descriptor for GSHELL
                    bsr       SETWINDW            Set some coords, graphics cursor, window type, etc.
                    lbsr      KILLPBUF            Kill all GP buffers in the our ID # group
                    lbsr      FINLINIT            Redo std I/O for window path, menus for 128/512k,mouse on
                    lbsr      GSHSTART

GSHABORT            puls      U,PC                Restore U & return

* Entry: Y=start of data area ptr
FIXWINDW            ldd       #SS.SCTYP           Path=0, get screentype call
                    os9       I$GETSTT
                    bcc       ONWINDOW            No error on call, skip ahead
                    clra
                    std       >ERRNO              Save 16 bit error #
                    lda       #UPDAT.             Attempt to open path to 'w/'
                    ldx       #SLASHW
                    lbsr      I.OPEN              D=path for window
DoneFix             std       <WNDWPATH           Save path to window
                    rts

ONWINDOW            lda       #STDERR             Get Std Error path
                    lbsr      I.DUP               Duplicate path
                    pshs      d                   Save new path # (16 bit)
                    lbsr      DWEND               DWEnd the window
                    puls      d                   Get path #
                    bra       DoneFix             Save & return

BILDDESC            ldx       #TNDYDESC           Point to our copy of Tandy Menu descriptor
                    stx       WINDDESC+WN.BAR,Y   Save as ptr to menu descriptors
                    ldb       #5                  5 menus on the menu bar
                    stb       WINDDESC+WN.NMNS,Y
                    ldd       #WINSYNC            Sync bytes to $c0c0 <grin>
                    std       WINDDESC+WN.SYNC,Y
                    leax      <GSHELLTL,PC        Point to GSHELL title bar
                    pshs      X                   Save it
                    ldx       #WINDDESC           Point to Gshell menu descriptor
                    pshs      X                   Save that
                    lbsr      STRCPY              Copy title bar info into RAM copy of Menu descriptor
                    leas      4,S                 Eat stack
                    clr       <PRCIDNUM
                    pshs      y                   Save Y
                    os9       F$ID                Get process #
                    sta       <PRCIDNUM+1         Save it
                    puls      y,pc                Restore Y & return

GSHELLTL            fcc       "GShell+ 1.26"
                    fcb       NUL

SETWINDW            bsr       WINDPARM            Set up some of the 40/80 column measurement stuff
                    ldb       #2
                    pshs      d                   border color=2
                    pshs      d                   background color=0
                    clrb
                    pshs      d                   foreground color=1
                    ldx       WINDWSZY            Get Window height
                    ldb       WINDWSZX+1          Get X window size (in chars)
                    pshs      d,X                 Save them
                    clrb                          Start x,y=0,0
                    pshs      d
                    pshs      d
                    ldx       DEFWTYPE            Get window type
                    ldb       WNDWPATH+1          Get window path #
                    pshs      d,X                 Save them
                    lbsr      DWSET               Do the device window set
                    lbsr      ResetPal            Added to restore GSHPAL colors when re-setting window
                    leas      18,S                Eat all of our stack crap
                    std       -2,S
                    blt       SETWIND1            ??? Error, skip ahead

                    lbsr      MenuClr             Set color for menu bars
                    ldx       #WINDDESC           Point to Gshell menu structure
                    ldd       #WT.FSWIN           Framed window with scrollbars
                    pshs      d,X                 Save on stack
                    ldb       WNDWPATH+1          Get path to window
                    pshs      d                   Save
                    lbsr      ST.WNSET            Set the window to framed with scrollbars
                    leas      6,S                 Eat stack stuff

                    lbsr      RegClr              Set color for regular stuff
                    std       -2,S
                    bge       SETFONTS            No error, skip ahead
SETWIND1            ldd       ERRNO,Y             Get error #
                    pshs      d                   Save it
                    lbsr      TRYQUIT             ??? Try resetting everything?
                    leas      2,S                 Eat stack
SETFONTS            clrb                          Save regs
                    pshs      d,X,Y
                    lbsr      SELECT              Select std in as current window
                    ldb       WNDWPATH+1          Get window path
                    stb       1,S                 Save on stack
                    lbsr      SELECT              Select Gshell window path as current window
                    ldb       #FNT.S6X8           Save 6x8 font #
                    stb       1+4,S
                    ldb       #GRP.FNT            Save font group #
                    stb       3,S
                    lbsr      FONT                Select the 6x8 font
                    clrb                          Echo off, pause off
                    std       2,S
                    lbsr      PAUSECHO            Shut echo & pause off
                    lbsr      CURSCLOF            Cursor off & Scaling off
                    lbsr      CRSRAROW            Set graphics cursor to the arrow
                    leas      6,S                 Eat stack & return
                    rts

WINDPARM            clra                          Default flag to 320 res.
                    ldb       DEFWTYPE+1          Get default window type
                    cmpb      #7                  640x200x4 color?
                    bne       WINDPAR3            No, leave at 320 res.
WINDPAR1            inca                          Flag as 640 res.
WINDPAR3            sta       FLAG640W            Save 640/320 flag
                    bne       WINDPAR4            640, skip ahead
                    ldd       #303                Set Gshell window width to 303
                    std       PIXELSWD
                    ldd       #265                Set Directory Bar End X to 265
                    std       DBARDESC+FL.XEND,Y
                    ldd       #280                '?' Start X pos to 280
                    std       QURYDESC+FL.XSTRT,Y
                    ldd       #295                '?' End X pos to 295
                    std       QURYDESC+FL.XEND,Y
                    ldd       #64                 Start X position of icons on screen to 64
                    std       STRTXPOS
                    std       ICONCOLW            Also # pixels between icons (width)
                    ldb       #ICNONSCR           Get max # icons on screen at once
                    std       MAXICONS            Save it
                    ldb       #40                 X Size of GShell window path to 40
                    clr       WD48FLAG            Set 40 column flag
                    bra       WINDPARX

* 640 wide screen
WINDPAR4            ldd       #623                GShell window width=632
                    std       PIXELSWD
                    ldd       #576                Set directory bar end X to 576
                    std       DBARDESC+FL.XEND,Y
                    ldd       #597                '?' Start X pos to 597
                    std       QURYDESC+FL.XSTRT,Y
                    ldd       #615                '?' End X pos to 615
                    std       QURYDESC+FL.XEND,Y
                    ldd       #56                 Start X pos of icons on screen to 56
                    std       STRTXPOS
                    ldb       #ICNONSCR*2         # icons on screen max
                    std       MAXICONS            Save it
                    ldb       #72                 72 pixels between icons on screen
                    stb       ICONCOLW+1
                    ldb       #$80                Flag 80 colum screen
                    stb       WD48FLAG
                    ldb       #80                 80 column width
WINDPARX            std       WINDWSZX            Save # text chars wide screen is & return
                    rts

FINLINIT            lbsr      RESTDIO             Close std I/O, Reopen with current window path
                    lbsr      SETVIEW             Set up the VIEW menu
                    tst       RAMSIZE             >128k RAM?
                    bne       FINLINIX            Yes, skip ahead
                    clr       VIEWDESC+MN.ENBL    No, disable the view menu (only allow 16k 320x200x4)
                    clr       ITM.FMAT+MI.ENBL    Disable the FORMAT command
                    lda       WNDWPATH+1          Get window path
                    ldb       #SS.UMBAR           Update the menu bar (to enforce above changes)
                    os9       I$SETSTT

FINLINIX            lbsr      STDICONS            Preload built in icons (regular & expanded for some)
                    lbsr      MOUSENOW            Turn on auto-follow mouse
                    rts

* Shut cursor & scaling off
CURSCLOF
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    pshs      d
                    ldb       5,S
                    pshs      d
                    lbsr      SCALESW             Shut scaling off
                    lbsr      CURSROFF            Shut cursor off
                    bra       CURSCLOX

* Clear out signal code, reset up Mouse/keyboard signals
* CHANGED: will copy Dirup signal flag to RECDSGNL
SETSGNLS            clra                          Clear out last received signal
                    ldb       Dirup               Get Saved Dir updated signal (0 means none)
                    std       RECDSGNL            Clear or set saved DIR signal
                    ldb       WNDWPATH+1          D=window path to receive mouse signal from
                    ldx       #MOUSIGNL           Mouse signal #
                    pshs      d,X                 Save for routine call (both only s/b 8 bit)
                    lbsr      ST.RELEA            Release the mouse signal
                    lbsr      ST.MSSIG            Set the mouse signal
                    inc       3,S                 Bump up signal number (to keyboard signal)
                    lbsr      ST.SSIG             Set keyboard signal
CURSCLOX            leas      4,S                 Eat temp stack & return
                    rts

GSHSTART            pshs      U                   Preserve U
                    leas      -3,S                Make room on stack
                    ldu       #MOUSPCKT           Point to mouse packet buffer
                    lbsr      INITSCRN
WAITLOOP            bsr       SETSGNLS            Set signals for keyboard & mouse
                    ldd       RECDSGNL            Get signal
                    bne       SGNLRECD            Got one, process it
                    pshs      d                   Preserve 0
                    lbsr      HNDLWAIT            Go sleep, check for signals
                    std       ,S++                Save child's signal code
                    bne       SGNLRECD            Got one, process as if local signal
                    bsr       SETSGNLS            Set signals again
                    ldx       RECDSGNL            Get any new signal
                    bne       SGNLRECD            Got one, process it
                    os9       F$SLEEP             Sleep until signal received
SGNLRECD            ldd       RECDSGNL            Get signal code (only need B portion)
                    subb      #DIRSIG             Dir update signal?
                    lbeq      EQULSIGN            Yes, go do
                    incb                          Keyboard signal?
                    lbeq      CHKKEYBD            yes, handle
                    incb                          Mouse signal?
                    bne       WAITLOOP            No, wait some more
* Mouse signal handling here
CHKMOUSE            ldd       WNDWPATH            Get window path
                    pshs      d,U
                    lbsr      GT.MOUSE            Get mouse packet
                    leas      4,S
                    ldb       PT.VALID,U          Mouse on current window?
                    beq       WAITLOOP            No, continue waiting
                    ldb       PT.CBSA,U           Is button A pressed?
                    beq       WAITLOOP            No, continue waiting
                    ldb       PT.STAT,U           Is mouse in control region or off window?
                    bne       CHEKMENU            Yes, go check if menu select made
                    pshs      U
                    lbsr      CHEKSCRN            No, check if user selected something not on menu bar
SLCTRTRN            leas      2,S                 Eat stack, poll keyboard/mouse
                    bra       WAITLOOP

CHEKMENU            lda       WNDWPATH+1          Get window path
                    ldb       #SS.MNSEL           Menu select call
                    os9       I$GETSTT            Do call (ignore errors... original does)
* Error code added to see if we get errors when GSHELL "freezes"
                    bcc       NoError
                    os9       F$EXIT
NoError             cmpa      #MID.CLS            Close box?
                    beq       CLOSEBOX
                    cmpa      #MID.SUP            Scroll up arrow?
                    beq       SCRLLUPL
                    cmpa      #MID.SLT            Scroll left arrow?
                    beq       SCRLLUPL
                    cmpa      #MID.SDN            Scroll down arrow?
                    beq       SCRLLDNR
                    cmpa      #MID.SRT            Scroll right arrow?
                    beq       SCRLLDNR
                    cmpa      #MID.TDY            Tandy menu?
                    beq       TNDYMENU
                    cmpa      #MID.FIL            File menu?
                    beq       FILEMENU
                    cmpa      #MID.DSK            Disk menu?
                    beq       DISKMENU
                    cmpa      #MID.VEW            View menu?
                    beq       VIEWMENU
WAITRTRN            bra       WAITLOOP            Continue waiting (About.. menu will never return item)

* Called by hitting 'q' or clicking on close box
CLOSEBOX            lbsr      SUREQUIT            Do 'are you sure' box
                    bra       WAITRTRN            Obviously hit 'no', continue

SCRLLUPL            ldd       DEVICNOW            Drive selected?
                    beq       WAITRTRN            No, continue polling keyboard/mouse
                    lbsr      SCRLLUP1            Scroll up on current drive
                    bra       WAITRTRN            Continue polling keyboard/mouse

SCRLLDNR            ldd       DEVICNOW            If drive selected, scroll down
                    beq       WAITRTRN            continue polling keyboard/mouse
                    lbsr      SCRLLDN1
                    bra       WAITRTRN

* Entry for all 4 ????MENU calls is B=item # selected
TNDYMENU            clra
                    pshs      d
                    lbsr      TNDYSLCT            Go handle Tandy menu
                    bra       SLCTRTRN            Eat stack, continue polling

FILEMENU            clra
                    pshs      d
                    lbsr      FILESLCT            Do File menu
                    bra       SLCTRTRN            Eat stack, continue polling

DISKMENU            clra
                    pshs      d
                    lbsr      DISKSLCT            Do Disk menu
                    bra       SLCTRTRN            Eat stack, continue polling

VIEWMENU            clra
                    pshs      d
                    lbsr      VIEWSLCT            Do View menu
                    bra       SLCTRTRN            Eat stack, continue polling

* Poll keyboard
CHKKEYBD            ldd       #1                  1 byte length/std in?
                    pshs      d
                    leax      2,S                 Point to 1 byte buffer
                    ldd       WNDWPATH            Get window path
                    pshs      d,X
                    lbsr      I.READ              Read key
                    leas      6,S
                    std       -2,S                save byte
                    ble       WAITRTN2            No key(?), continue polling
                    ldb       ,S                  Get key press
                    cmpb      #'=
                    beq       EQULSIGN            '=' - go refresh current drive/dir selection
                    cmpb      #'$
                    beq       DOLRSIGN            '$' - go set up new resizable shell window
                    cmpb      #28                 (Pageup)
                    beq       SCRLLUPL            Scroll up current dir
                    cmpb      #26                 (PageDown)
                    beq       SCRLLDNR            Scroll down current dir
                    cmpb      #63                 '?' - call Help routine
                    beq       ICONQUR1
                    andb      #$5F
                    cmpb      #'Q                 'Q'uit Gshell
                    beq       CLOSEBOX
                    cmpb      #'S                 'S'ame screen overlay shell
                    beq       LETTERS
                    ldd       WNDWPATH            Illegal key, beep at user
                    pshs      d
                    lbsr      RINGBELL
                    leas      2,S
                    bra       WAITRTN2            Continue polling

* Resizable shell
DOLRSIGN            ldb       #IC.SHELL           We want the structure for the SHELL entry
                    pshs      d
                    lbsr      FNDIDESC            (Returns D=ptr to proper ID structure) - may change screen type
                    std       ,S                  Save ptr
                    ldd       #1                  ? Save flag that we want a double box window for the program
                    pshs      d
                    ldx       #SHELLNAM           Point to shell name for F$Fork
                    pshs      X
                    lbsr      EXCICOND            Execute shell in resizable window
                    leas      6,S
                    bra       WAITRTN2

* Refresh current drive/dir (NEW RBF CALL, IF FULLY WORKING, MAY OBSOLETE THIS
* ROUTINE FROM BEING CALLED BY A KEYPRESS)
EQULSIGN            ldd       DEVICNOW            If no drive selected, don't bother
                    beq       WAITRTN2
                    lbsr      DONEWDIR            Go refresh current drive stuff
WAITRTN2            lbra      WAITLOOP

* Same screen overlay shell
LETTERS
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    pshs      d
                    pshs      d                   No parameter for calling program
                    incb
                    pshs      d                   Flag that we want overlay window to run in
                    ldx       #SHELLNAM           Point to 'shell'
                    pshs      X
                    lbsr      EXECPRGM            Execute program in overlay window (MAYBE ALLOW RESIZE?)
                    leas      8,S
                    bra       WAITRTN2            Continue polling after shell exited

* Printer click
ICONPRTR            ldd       SELECTED            Is there a file/dir selected?
                    beq       ICONTRS1            No, don't do printer
                    ldb       #5                  Print menu item # from FILES menu
                    std       ,S
                    lbsr      FILESLCT
                    bra       ICONTRS1

* Trash can click
ICONTRSH            ldd       SELECTED            Is there a file/dir selected?
                    beq       ICONTRS1            No, don't do trash stuff
                    ldb       #10                 Trash delete option from FILES menu structure (no sure prompt)
                    std       ,S
                    lbsr      FILESLCT
ICONTRS1            lbra      ICONEXIT

* ? in upper right corner - hot key
ICONQUR1            pshs      d                   Just so it exits properly
                    ldb       #7
                    pshs      d
                    lbsr      TNDYSLCT
                    bra       WAITRTN2

ICONQURY            ldb       #7                  '?' selected, call 'Help' (menu item 7) from Tandy menu
                    pshs      d
                    lbsr      TNDYSLCT
                    lbra      ICONEXT1

* Not menu bar selection, try other stuff on screen
CHEKSCRN            pshs      U
                    ldd       8-4,S
                    pshs      d,X
                    lbsr      ISITICON            Check if drive or icon
                    tfr       D,U
                    stu       -2,S                Set CC based on ptr to icon info
                    lbeq      DSLCTALL            Empty spot clicked, clear any currently highlighted stuff
                    ldb       FL.ICONO,U          Get selected icon buffer #
                    cmpb      #IC.TRASH           Is it the trash can?
                    beq       ICONTRSH            Yes, go handle
                    cmpb      #IC.PRNTR           Is it the printer?
                    beq       ICONPRTR            Yes, go do it
                    cmpb      #IC.QUERY           Is it the question mark?
                    beq       ICONQURY            Yes, go do help
                    lbsr      ENBLSOFF            Disable any menu items that deal with specific file
                    ldb       #1
                    std       ,S
                    ldd       SELECTED            Get current selected icon
                    beq       CHEKSCR2            None, skip ahead
                    cmpu      SELECTED            Same as previously selected icon?
                    bne       CHEKSCR1            No, unselect previous icon
                    inc       1,S
                    bra       CHEKSCR2

CHEKSCR1            pshs      d                   Unselect previously selected icon
                    lbsr      UNSLICON
                    leas      2,S
CHEKSCR2            stu       SELECTED            Save newly selected icon
                    ldb       FL.ICONO,U          Get icon # (also type?)
                    decb
                    lbeq      ICONTEXT            1=Text file icon
                    decb
                    beq       ICONFLDR            2=Folder (dir) icon
                    decb
                    lbeq      ICONPRGM            3=Program (executable) icon
                    decb
                    beq       ICONCLOS            4=Close box for current device title bar
                    decb
                    beq       ICONDRIV            5=Disk drive icon
                    decb
                    lbeq      ICONAIF             6=AIF file icon
                    decb
                    lbeq      ICON.XXX            7=file with extension already defined by AIF
                    decb
                    bne       ICONEXT2            >8, exit icon check routine
                    ldd       DEVICNOW            8=current device title bar (to refresh current dir)
                    beq       ICONEXT2
                    lbsr      DONEWDIR            Refresh current dir
                    bra       ICONEXT2

* Select new drive icon
ICONDRIV            ldd       DEVICNOW            Get current device
                    std       2,S
                    pshs      d
                    lbsr      UNSLICON            Unselect current device
                    stu       ,S
                    lbsr      SELCICON            Select new icon
                    ldd       FL.FNAME,U          Get ptr to drive name
                    std       ,S
                    lbsr      NEWDDIR             Get new drive dir
                    std       ,S++
                    bne       ICONDROK            Legit, continue
                    pshs      U
                    lbsr      UNSLICON            Bad dir, unselect drive
                    leas      2,S
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       SELECTED            Current device=none
                    ldd       2,S                 Did user have a different drive selected before?
                    beq       ICONEXT2            No, exit
                    pshs      d
                    lbsr      SELCICON            Re-select the old drive instead
ICONEXT1            leas      2,S
ICONEXT2            lbra      ICONEXIT

* User selected new, legitimate drive
ICONDROK            ldb       #1                  Enable menu items flag
                    pshs      d
                    lbsr      ENFREFLD            Enable drive specific menu items (NOT FILE ONES!)
                    leas      2,S
                    stu       DEVICNOW            Save new current device
                    bra       ICONEXT2

* Selected current path close box (go up a directory)
ICONCLOS            lbsr      PARENTDR            Change to parent directory or drive
                    bra       ICONEXT2

* Selected a folder (directory)
ICONFLDR            ldd       ,S                  ??? Get # times mouse clicked
                    decb
                    beq       ONECLIKF            Once, skip ahead
                    ldd       FL.FNAME,U          Twice, get ptr to folder name
                    pshs      d
                    lbsr      OPENFLDR            Open the folder & return
                    bra       ICONEXT1

ONECLIKF            pshs      U
                    lbsr      SELCICON            Highlight (select) the folder
                    ldb       #1
                    std       ,S
                    lbsr      ENBLOPEN            Enable OPEN item on files menu
                    lbsr      ENSTRNDL            Enable STAT, RENAME & DELETE on files menu
                    bra       ICONEXT1            Exit

* Text file icon selected
ICONTEXT            ldb       #1                  Enable LIST & PRINT on Files menu
                    pshs      d
                    lbsr      ENLSTPRT
                    ldd       2,S                 Get # of mouse clicks
                    decb
                    bne       TWOCLIKT            double click, skip ahead
                    stu       ,S                  Select the icon
                    lbsr      SELCICON
                    bra       ICONTEX1

TWOCLIKT            ldx       #1                  Double clicked text file: try executing as shell script
                    stx       ,S
                    ldd       FL.FNAME,U          Save ptr to filename
                    pshs      d
                    ldd       #SHELLNAM           Save ptr to 'shell' and 'use overlay window' flag
                    pshs      d,X
                    lbsr      EXECPRGM            Execute shell in overlay window
                    leas      6,S
                    bra       ICONTEX1

* File with previously found AIF extension clicked on
ICON.XXX            ldd       ,S                  Get # of clicks
                    decb
                    beq       ICONAIF1            1 click, skip ahead
                    pshs      U
                    lbsr      EXEC.XXX            Double click, execute the program related to icon
                    bra       ICONAIF2

* AIF file clicked on
ICONAIF             ldb       #1                  Enable LIST & PRINT on FILE menu
                    pshs      d
                    lbsr      ENLSTPRT
                    leas      2,S
                    ldd       ,S                  Get # of clicks
                    decb
                    beq       ICONAIF1            1 click, skip ahead
                    pshs      U
                    lbsr      EXECAIF             2 clicks, execute program AIF file refers to
                    bra       ICONAIF2

* Executable program clicked on
ICONPRGM            ldd       ,S                  Get # of clicks
                    decb
                    beq       ICONAIF1            1 click, skip ahead
                    pshs      d
                    lbsr      FILESLCT            2 clicks, Go to file select menu, option 1 (OPEN)
                    leas      2,S
                    bra       ICONPRG1

ICONAIF1            pshs      U
                    lbsr      SELCICON            Do select icon on screen
ICONAIF2            leas      2,S
ICONPRG1            ldb       #1                  Enable OPEN item on FILES menu
                    pshs      d
                    lbsr      ENBLOPEN
ICONTEX1            ldb       #1
                    std       ,S
                    lbsr      ENBLCOPY            Enable COPY item on FILES menu
                    lbra      ICONEXT1

DSLCTALL            ldd       SELECTED            Get ptr to current selected icon
                    pshs      d
                    lbsr      UNSLICON            Unselect icon
                    lbsr      ENBLSOFF            Shut all FILES menu items off
                    leas      2,S
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       SELECTED            Set selected file/device to none
ICONEXIT            leas      4,S
                    puls      U,PC

* Pop up overlay window to ask user for parameters for file we are about to
*  execute.
GETPARMS            pshs      U
                    ldd       4,S
                    leas      -48-10,S            Make room on stack for string copy
                    leax      TENSPACE,PC
                    pshs      d,X                 Save ptr to 10 spaces & ptr to module name we are executing
                    leax      <PARMSFOR,PC        Save ptr to "parameters for" text
                    pshs      X
                    leax      4+2,S
                    pshs      X
                    lbsr      STRCPY              Copy "paramters for" onto stack
                    leas      4,S
                    pshs      d
                    lbsr      STRCAT              Add 10 spaces
                    leas      4,S
                    pshs      d
                    lbsr      STRCAT              Add module name
                    leas      4,S
                    leax      ,S
                    pshs      X
                    lbsr      INPTSCRN            Get parameter info from user
                    leas      48+2+10,S           Eat stack & return
                    puls      U,PC

PARMSFOR            fcc       "Parameters for "
                    fcb       NUL

EXEC.XXX            pshs      U
                    bsr       IDESCTST
                    beq       EXECAIF3
                    pshs      d
                    ldd       FL.FNAME,U          Get ptr to file name
                    pshs      d
                    lbsr      STPREFIX
                    puls      d,U
                    bra       EXEC.XX1

* See if there is a ID.* entry for a FL.* entry
* Entry: 0-1,s : RTS address
*        2-3,s : ignored
*        4-5,s : ignored
*        6-7,s : FL.* ptr
* Exit: D=ptr to ID.* structure (0 if none)
IDESCTST            ldu       4+2,S               Get ptr to file info structure (FL.*)
                    clra
                    ldb       FL.AIFNO,U          Get entry # in ID.* table
                    pshs      d
                    lbsr      FNDIDESC            Get ptr to appropriate ID.* table entry
                    std       ,S++                Set zero flag based on ptr
                    rts

EXECAIF             pshs      U                   Save U
                    bsr       IDESCTST            Get ID.* ptr
                    beq       EXECAIF3            None, exit
                    tfr       D,U                 Move ptr to U
EXEC.XX1            lda       [ID.PARAM,U]        Get 1st char of parms
                    beq       EXECAIF2            None, skip ahead
                    cmpa      #'?                 Question mark (prompt for parms)?
                    bne       EXECAIFN            No, use parms raw
                    ldd       ID.MNAME,U          Get ptr to module name
                    pshs      d
                    bsr       GETPARMS            Prompt user for parms (uses overlay with module name)
                    std       ,S++                Size of user response
                    beq       EXECAIF2            Just hit enter, skip ahead
                    bra       EXECAIFP

EXECAIFN            ldd       ID.PARAM,U          Get ptr to parms string
EXECAIFP            pshs      d                   Save ptr to parms string
                    lbsr      STPREFIX            Prefix that onto Fork line string
                    leas      2,S
EXECAIF2
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    pshs      d,U
                    ldd       ID.MNAME,U          Get ptr to module name to fork
                    pshs      d
                    lbsr      EXCICOND            Go execute module in resizable window
                    leas      6,S
EXECAIF3            puls      U,PC

* Open folder
OPENFLDR            pshs      U
                    ldu       4,S
                    pshs      U
                    lbsr      CHGDDIR             Change dir to newly selected folder
                    std       ,S++
                    bne       OPENFLD1
                    ldx       #DDIRNAME           Append new dir to dir name on drive bar
                    pshs      X
                    lbsr      STREND              Find end of current path
                    leas      2,S
                    tfr       D,X
                    ldb       #'/                 Add slash to end of path
                    stb       ,X+
                    bra       NEWDDIR1

OPENFLD1            leax      <CANTFLDR,PC
                    bra       OPENFLD2

NEWDDIR             pshs      U
                    ldu       4,S
                    pshs      U
                    lbsr      CHGDDIR
                    std       ,S++
                    bne       NEWDDIR2
                    lbsr      KILIBUFS            Kill previous dir's icon buffers & get/put buffers?
                    ldx       #DDIRNAME           Point to full path to current data directory

NEWDDIR1            pshs      X,U
                    lbsr      STRCPY              Add new path (,U) to end of current path (,X)
                    leas      4,S
                    lbsr      DONEWDIR            Refresh current drive on screen
                    ldb       #1                  Exit with D=1
                    bra       NEWDDIR3

NEWDDIR2            leax      <CANTDEVC,PC
OPENFLD2            pshs      X
                    lbsr      OLAYPRNT
                    leas      2,S
                    clrb
NEWDDIR3            clra
                    puls      U,PC

CANTFLDR            fcc       "Can't open this folder"
                    fcb       NUL

CANTDEVC            fcc       "Can't open this device"
                    fcb       NUL

* Change to parent directory (clicked on dir bar close box)
PARENTDR            pshs      U
                    lbsr      FNDSLASH            Find slash NOTE: ONLY CALLED ONCE, EMBED!
                    std       -2,S                On root?
                    bne       PARENTD1            Yes, skip ahead
                    leax      <DOTDOT,PC          Change directory to '..'
                    pshs      X
                    lbsr      CHGDDIR
                    ldx       #DDIRNAME           Get ptr to current full path to data dir.
                    stx       ,S
                    lbsr      TERMSLSH            Cut data dir off one directory level earlier
                    leas      2,S                 Eat stack
                    lbsr      DONEWDIR            Refresh current drive on screen
                    bra       PARENTD2

* On root directory of current drive, unselect drive itself
PARENTD1            clrb                          D=0
                    pshs      d                   Save it
                    lbsr      ENFREFLD            Disable Drive specific menu items
                    lbsr      CLRDSCRN            Wipe out current dir icon window, reset scroll bars to 0,0
                    ldd       DEVICNOW            Get ptr to table for current selected drive
                    std       ,S                  Save it
                    lbsr      UNSLICON            Unselect the current drive
                    leas      2,S
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       STRTICON            Set ptr to start icon for screen to NONE
                    std       SELECTED            Current selected icon to NONE
                    std       DEVICNOW            Current selected device to NONE
                    lbsr      KILIBUFS            Kill icon table & get/put buffers
PARENTD2            puls      U,PC

DOTDOT              fcc       ".."
                    fcb       NUL

KILPDS00            lbra      KILPDS16            Eat stack & exit

* Kill process info for a process that has stopped (update linked list)
* NOTE: BOTH 6809/6309 - SOME STU -2,S LOOK PRETTY USELESS
* Entry: 0-1,s RTS address
*        2-3,s ptr to GD.* (process table entry ptr) to kill
KILPDESC            pshs      U
                    ifne      H6309
                    clrd                          No entry found yet
                    else
                    clra
                    clrb
                    endc
                    pshs      d                   Save it
                    ldu       PTBLSPTR            Get ptr to start of process descriptor table
                    beq       KILPDS00            None, exit
                    ldd       6,S                 Get process table entry ptr we are to kill
                    beq       KILPDS00            None, exit
                    cmpu      6,S                 Is the requested entry to kill the 1st entry in table?
                    beq       KILPDES2            Yes, skip ahead
* Entry other than 1st to kill
KILPDES1            stu       ,S                  Save ptr to entry previous to one we want to kill
                    ldu       GD.LINK,U           Get ptr to next process table entry in chain
* Following line should be removed (inherent from LDU)
                    stu       -2,S
                    beq       KILPDES2            No other entries, exit (if you follow below) (REALLY STUPID)
                    cmpu      6,S                 Is this the entry we are trying to kill?
                    bne       KILPDES1            No, check next link
* ??? Remove entry from linked list (next entry in list pointed to by U)
KILPDES2            stu       -2,S                Next entry a legit one?
                    beq       KILPDS00            No, exit
                    cmpu      PTBLSPTR            Is it the 1st entry?
                    bne       KILPDES3            No, skip ahead
                    ldd       GD.LINK,U           Get ptr to next process table entry
                    std       PTBLSPTR            Reset this ptr as the 1st process table entry
                    bra       KILPDES4            Skip ahead

* one to remove is not 1st entry
KILPDES3            ldd       GD.LINK,U           Get next entry in linked list
                    ldx       ,S                  Get ptr to one previous to the one we want to kill
                    std       GD.LINK,X           Repoint previous entry to link to next entry (bypass us)
KILPDES4            ldd       #GD.LINK            Offset to link ptr in structure
                    ifne      H6309
                    addr      u,d                 Point to next link ptr entry in current table entry
                    else
                    pshs      u
                    addd      ,s++
                    endc
                    cmpd      PTBLNEXT            Same as next available process descriptor link?
                    bne       KILPDES6            No, skip ahead
                    ldd       ,S                  Get previous entry ptr
                    beq       KILPDES5            None, skip ahead
                    addd      #GD.LINK            Offset to next link ptr
                    std       PTBLNEXT            Save as ptr to next available process descriptor link
                    bra       KILPDES6

KILPDES5            leax      <PTBLSPTR,Y         Point to 1st entry
                    stx       PTBLNEXT            Save as next available process desc. link
KILPDES6            ldd       GD.WPATH,U          Get window path for process
                    blt       KILPDS10            If negative, skip ahead
                    cmpd      WNDWPATH            Same as current GSHELL path?
                    bne       KILPDES7            No, skip ahead
                    lbsr      KILLOLAY            Remove overlay window it was running in.
                    tst       RAMSIZE             128k RAM machine?
                    bne       KILPDS12            >=256K, skip ahead
                    lbsr      CLRSCRN             on 128k, clear GSHELL screen 1st
                    bra       KILPDS12

*Process killed was on different path than GSHELL itself is on
KILPDES7            ldd       GD.DW.OW,U          Process running in overlay window?
                    beq       KILPDES8            No, skip ahead
* NOTE: WHY DO SELECT TWO DIFFERENT WINDOWS IN A ROW???
*   Something to do with overlay window vs. parent device window?
                    ldd       GD.WPATH,U          Get path to window process was on
                    pshs      d                   Make it the active window
                    lbsr      SELECT
                    ldd       WNDWPATH            Get GSHELL window path
                    std       ,S                  Select it
                    lbsr      SELECT              Select window
                    ldd       GD.WPATH,U          Get process' window path again
                    std       ,S                  End process' window
                    lbsr      DWEND
                    bra       KILPDES9

KILPDES8            ldd       WNDWPATH            Get path to GSHELL window
                    pshs      d                   Make it the active window
                    lbsr      SELECT
KILPDES9            leas      2,S                 Eat temp stack
                    ldd       GD.WPATH,U          Get path to process' window
                    pshs      d                   Close path to window
                    lbsr      I.CLOSE
                    bra       KILPDS11

KILPDS10            ldd       WNDWPATH            Get path to GSHELL window
                    pshs      d
                    lbsr      SELECT              Make it the active window
KILPDS11            leas      2,S                 Eat stack
KILPDS12            ldd       GD.SCRNO,U          Get screen #
                    ble       KILPDS13            If negative or 0, skip ahead
                    pshs      d                   Save screen #
                    lbsr      UNLKWNDW            Unlink window from active window/screen list
                    leas      2,S
KILPDS13            ldd       GD.INDVC,U          Get ptr to ???
                    beq       KILPDS14            None, skip ahead
                    pshs      d
                    lbsr      FREE                ??? Free memory of some sort?
                    leas      2,S
KILPDS14            ldd       GD.MNAME,U          Get ptr to process module name
                    beq       KILPDS15            None, skip ahead
                    pshs      d                   ??? Free mem for that?
                    lbsr      FREE
                    leas      2,S
KILPDS15            pshs      U
                    lbsr      FREE
                    leas      2,S
KILPDS16            leas      2,S
                    puls      U,PC

* Allocate & setup process entry for our table of forked proceses
SETPDESC            pshs      U
                    ldd       #GD.SIZE            Size we want to allocate
                    pshs      d
                    lbsr      MEMSPACE            Allocate the memory
                    tfr       D,U                 Save ptr to allocated memory into U
                    std       [PTBLNEXT,Y]        Save ptr to next available spot for process descriptor
                    leax      GD.LINK,U           Point to next link
                    stx       PTBLNEXT            Save ptr to next available
                    ldd       4+2,S
                    std       ,S
                    lbsr      PUTSTRNG
                    leas      2,S
                    std       GD.MNAME,U          Save ptr to module name
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       GD.MTYPE,U          Default stuff to zeros
                    std       GD.INDVC,U          ??? to 0
                    std       GD.PRCID,U          Process ID # to 0
                    std       GD.MEMSZ,U          memory size to 0
                    std       GD.DW.OW,U          Default to running on separate device window
                    leax      GD.LINK,U           Point to next link ptr
                    std       ,X                  Set next link to empty
                    ldd       #-1
                    std       GD.STATS,U
                    std       GD.WPATH,U          No window path done yet
                    std       ,--X
                    std       ,--X
                    std       ,--X
                    std       ,--X
                    std       ,--X
                    tfr       U,D
                    puls      U,PC

DONEWDIR            lbsr      KILLFTBL            Kill current file table in memory
                    lbsr      RSTXYPTR            Reset x/y pointers for icon starts
                    lbsr      NEWDIREC            Redraw current dir screen
                    bra       DONEWDR1            Redraw screen & return

SCRLLDN1            ldb       SCREENOW+1
                    cmpb      NSCREENS+1
                    bge       SCRLLUDX
                    incb
                    bra       SCRLLDN2

SCRLLUP1            ldb       SCREENOW+1
                    beq       SCRLLUDX
                    decb
SCRLLDN2            stb       SCREENOW+1
DONEWDR1            bsr       DRAWSCRN
SCRLLUDX            rts

* Update screen: does 1) update directory bar, 2) update icons, 3) update
*   scroll bar marker.
DRAWSCRN            pshs      U
                    lbsr      ENBLSOFF            Disable any menu items that deal with a specific file
                    ldd       WNDWPATH            Get GSHELL path
                    pshs      d,X
                    lbsr      GCSETOFF            Shut graphics cursor off
                    lbsr      MOUSOFF             Shut mouse off
                    lbsr      WIPICONS            Wipe icons off screen (should not touch dir bar)
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       SELECTED            0 out currently selected icon ptr
                    ldd       MAXICONS            Get # icons/screen
                    ifne      H6309
                    muld      SCREENOW            Multiply by screen set #
                    stw       2,s                 Save result
                    else
                    pshs      x,y
                    ldx       SCREENOW
                    lbsr      MUL16
                    puls      x,y
                    stu       2,s
                    endc
                    ldu       FTBLSPTR            Get ptr to file icon descriptor table
                    bra       DRAWSCR2

DRAWSCR1            ldu       FL.LINK,U
DRAWSCR2            ldd       2,S                 Get screen set # we want to print
                    ifne      H6309
                    decd      Base                0
                    else
                    subd      #$0001
                    endc
                    std       2,S                 Save it back
                    bge       DRAWSCR1            If not 1st, skip ahead
                    stu       STRTICON            Save ptr to 1st icon on current screen
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    bra       DRAWSCR4

DRAWSCR3            pshs      U
                    lbsr      WRITICON
                    leas      2,S
                    ldu       FL.LINK,U
                    ldd       2,S
                    ifne      H6309
                    incd
                    else
                    addd      #$0001
                    endc
DRAWSCR4            std       2,S
                    stu       -2,S
                    beq       DRAWSCR5
                    cmpd      MAXICONS
                    blt       DRAWSCR3

DRAWSCR5            ldd       NSCREENS            Get # of icon screens
                    cmpd      SCREENOW            On last one?
                    bne       SCROLBAR            No, skip ahead
                    ldd       #20                 Yes, use Y pos 20 (for 200 line screen)
                    bra       DRAWSCR6

* Calculate position of vertical scroll bar (based on current screen #, and
*  how many screens of icons there is in current dir)
SCROLBAR            ldd       NSCREENS            Get # of screens of icons
                    beq       DRAWSCR6            If 0, just put in position 0
                    lda       SCREENOW+1          Get current screen#
                    beq       Force0              If 0, that is Y position
                    leas      -3,s                make room on stack for temp vars
                    incb                          Base 1 for divide
                    stb       3,s                 Save # of screens
                    ldd       #21                 Maximum # of screens
                    ifne      H6309
                    divd      3,s                 B= # of Y positions per screen
* remainder = A, quotient = B
                    else
                    clr       ,-s
SCROLBRa            inc       ,s
                    subb      4,s
                    sbca      #0
                    bcc       SCROLBRa
                    addb      4,s
                    tfr       b,a
                    puls      b
                    decb
                    endc
                    std       1,s                 Save remainder & answer
                    lda       SCREENOW+1          Get current screen #
                    inca                          Base 1
                    mul                           Multiply by answer (rough Y pos)
                    stb       ,s                  Save that result
                    lda       SCREENOW+1          Get current screen #
                    inca                          Base 1
                    ldb       1,s                 Get original remainder
                    mul                           Calculate 2ndary offset
                    ifne      H6309
                    divd      3,s                 B= # of Y positions per screen
                    else
                    clr       ,-s
SCROLBRb            inc       ,s
                    subb      4,s
                    sbca      #0
                    bcc       SCROLBRb
                    addb      4,s
                    tfr       b,a
                    puls      b
                    decb
                    endc
                    addb      ,s                  Add 2ndary to primary Y pos calc
                    leas      3,s                 Eat stack
                    decb                          Base 0 for scroll bar SETSTAT call
                    bge       NotNeg              not negative, skip ahead
Force0
                    ifne      H6309
                    clrd                          Force to 0
                    else
                    clra
                    clrb
                    endc
NotNeg              cmpb      #20                 Past end?
                    bls       DRAWSCR6            No, good, so update scroll bars
                    ldb       #20                 Force to 20
* Actually update the scrollbar (Y only one used)
* Entry: D=Y position wanted (0-20)
DRAWSCR6            std       ,S                  Save Y pos
                    pshs      d                   And again
                    ldx       #77                 Default to X position 77
                    tst       FLAG640W            80 or 40 column?
                    bne       DRAWSCR8            80, continue
                    ldx       #37                 X position to 37 for 40 column
DRAWSCR8            ldd       WNDWPATH            Get GSHELL window path
                    pshs      d,X                 Save path & x position
                    lbsr      ST.SBAR             Set scroll bar positions
                    lbsr      MOUSENOW            Turn auto-follow mouse back on
                    leas      6,S                 eat stack
                    lbra      GENLEXIT            Fix stack & return

* Wipe interior window, & redraw directory bar (latter done by call to
*   WRITDBAR). Change so it doesn't redraw directory bar unless directory has
*   changed
WIPICONS            pshs      U
                    ldb       #21                 Window Y size to clear - NOTE: WE HAVE TO ELIMINATE THE
                    pshs      d                   EXTRA BOX LINE IT CURRENTLY DRAWS
                    ldx       WINDWSZX            Get window X size
                    leax      -7,X                Subtract 7 (leaves scroll bars & drive icons alone)
                    ldb       #2                  Start Y at 2 (skip menu bar and current path line)
                    pshs      d,X
                    ldx       #6                  Start X (skip left border & drive icons)
                    ldd       WNDWPATH            Get GSHELL path
                    pshs      d,X
                    lbsr      CWAREA              Change working area
                    lbsr      CLRSCRN             Clear screen (Send CHR$(12))
                    leas      10,S                Eat stack
                    lbsr      FULLSCRN            Change working area to whole window except border stuff
                    lbsr      WRITDBAR            Do initial drawing of "inside" screen REDOES DIR STUFF
                    clr       WIPED               Flag that icons need not be redrawn
                    puls      U,PC                Exit

* Wipe interior window, except drive icons (but including box around dir
*  contents)
CLRDSCRN            pshs      U
                    ldb       #22                 Y size
                    pshs      d
                    ldx       WINDWSZX            X size -6 (includes box around dir contents)
                    leax      -6,X
                    ldb       #1                  Y start=1 (includes dir bar)
                    pshs      d,X
                    ldx       #5                  X start=5 (includes box around dir)
                    ldd       WNDWPATH
                    pshs      d,X
                    lbsr      CWAREA              Clear out interior window
                    lbsr      CLRSCRN
                    lbsr      FULLSCRN            Full interior window size (except border)
                    ifne      H6309
                    clrd                          Redo scroll bars at 0,0
                    else
                    clra
                    clrb
                    endc
                    std       4,S
                    std       2,S
                    lbsr      ST.SBAR
                    leas      10,S
                    puls      U,PC

* new dir - read in and print 1st screen
NEWDIREC            pshs      U
                    ldb       #$ff                Flag that we have to redo icons
                    stb       WIPED
                    bsr       WIPICONS            Wipe icons off screen (leave current dir border)
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       FILESCTR            # files in current dir=0
                    ldb       #PTR.SLP            Hourglass ptr
                    pshs      d,X,Y
                    ldx       #GRP.PTR
                    ldd       WNDWPATH
                    pshs      d,X
                    lbsr      GCSET
                    lbsr      MOUSOFF             Shut mouse off - Change later to slow sampling?

* New DIR check code here
                    lda       DIRPATH             Get current DIR path #
                    beq       SkipClos            None, don't try closing
                    os9       I$Close             Close dir path 1st
* New label here
SkipClos            ldb       #DIR.+READ.
                    std       2,S
                    leax      ONEDOT,PC           Point to '.'
                    stx       ,S
                    lbsr      I.OPEN2             Open current dir
                    leas      6,S
                    std       2,S                 Save path # to stack
                    lblt      BAD.DIR             Couldn't read current dir
                    stb       DIRPATH             Successfull open; Save current dir path
* NOTE: Done this early so if opening a large directory, and updates are done
*   during read, they will get caught too
                    clr       Dirup               Clear out Directory update flag (saved signal)
* New DIR code here - We want a signal if DIR changes
* Moved here so will detect changes even on dir we are doing
                    lda       DIRPATH             path in A
                    ldx       #DIRSIG             Signal code to send on dir update
                    ldb       #SS.FSIG            Send signal on file update setstat
                    os9       I$SetStt            Enable call

                    ldd       #DIR.SZ*2           Flag to read 2 entries (. & ..) - NOTE IF ONE OR BOTH OF THESE
                    pshs      d                   IS NOT PRESENT, THEN GSHELL WILL SKIP ENTRIES!
                    ldx       #DIRBUFER
                    ldd       6-2,S
                    pshs      d,X
                    lbsr      I.READ              Read . & ..
                    leas      6,S
                    bra       READ.DIR            Go read rest of dir

DIRVALID            ldd       ,S                  Get # of bytes of dir entries
                    pshs      d                   Save # to divide by
                    ldb       #5
                    lbsr      CCASR               divide by 32 (2^5) (size of dir entry)
                    std       ,S
                    ldx       #DIRBUFER           Point to start of DIR buffer
                    stx       DIRPTR              Save it
                    bra       CLASTEST            Check which kind of file

CLASSIFY            ldb       [DIRPTR,Y]          Get 1st byte of dir entry
                    beq       CLASSIF4            NUL (Deleted file, skip to next)
                    ldx       DIRPTR              Get ptr to filename
                    ldd       FNAMEPTR            Get ptr to current filename buffer
                    pshs      d,X
                    lbsr      STRHCPY             Copy filename, including fixing hi-bit marker
                    lbsr      UPDTIPTR            Update icon/file table ptrs
                    leas      4,S
                    tfr       D,U
                    stu       -2,S
                    beq       CLASSIF4
                    ifne      H6309
                    bsr       GTFD.ATT            Get file attributes
                    else
                    lbsr      GTFD.ATT            Get file attributes
                    endc
                    ldb       #IC.FOLDR           Default to folder (dir)
                    bita      #DIR.               If it is dir, done
                    bne       CLASSIF3
                    ldb       #IC.PRGRM
                    bita      #EXEC.              If executable, program type
                    bne       CLASSIF3
                    pshs      U
                    lbsr      ISIT.XXX            Check if an AIF type we know about
                    leas      2,S
CLASSIF3            stb       FL.ICONO,U          Save icon type
CLASSIF4            ldd       DIRPTR              Go onto next dir entry
                    addd      #DIR.SZ
                    std       DIRPTR

CLASTEST            ldd       ,S                  Get # of dir entries in this 2k block
                    ifne      H6309
                    decd      Subtract            1
                    else
                    subd      #$0001
                    endc
                    std       ,S
                    bge       CLASSIFY            Still going, classify file type, otherwise, get next 2k block

READ.DIR            ldd       #2048               Size of read buffer (64 dir entries @ once)
                    pshs      d
                    ldx       #DIRBUFER
                    ldd       6-2,S
                    pshs      d,X
                    lbsr      I.READ              Read in 2K of directory
                    leas      6,S
                    std       ,S
                    bgt       DIRVALID            Good read, continue

* New DIR code here
* We want a signal if DIR changes
                    lda       DIRPATH             path in A
                    ldx       #DIRSIG             Signal code to send on dir update
                    ldb       #SS.FSIG            Send signal on file update setstat
                    os9       I$SetStt            Enable call
                    bra       READDIR2

BAD.DIR             leax      <CANTFLD2,PC
                    pshs      X
                    lbsr      OLAYPRNT
READDIRX            leas      2,S
READDIR2            bsr       CNTSCRNS
                    lbra      GENLEXIT

CANTFLD2            fcc       "Can't open folder"
                    fcb       NUL

* Count # of screens to hold icons
CNTSCRNS
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       SCREENOW            Set current "screen" of icons to 0 (1st)
                    ldd       FILESCTR            Get # files current dir
                    beq       CNTSCRN2            zero, save & exit
                    ifne      H6309
                    decd
                    divd      MAXICONS+1          Divide by # icons/"screen"
                    else
                    subd      #$0001
                    clr       ,-s
CNTSCRNa            inc       ,s
                    subb      MAXICONS+1
                    sbca      #0
                    bcc       CNTSCRNa
                    addb      MAXICONS+1
                    tfr       b,a
                    puls      b
                    decb
                    endc
                    clra                          16 bit result
CNTSCRN2            std       NSCREENS            Save # of icon "screens" & return
                    rts

GTFD.ATT            leax      <XFD.ATT,Y
                    ldd       DIRPTR
                    pshs      d,X
                    ldd       6+2,S
                    pshs      d
                    lbsr      GT.FDINF
                    leas      6,S
                    lda       XFD.ATT
                    rts

* Write icon to screen
WRITICON            pshs      U
                    ldu       4,S                 ?? Get ptr to current FL.* entry
                    ldb       FL.ICONO,U          Get icon type
                    pshs      d                   Save it
                    bra       WRITICO2

WRITICO1            ldb       FL.AIFNO,U
                    std       ,S
                    bra       WRITICO3

WRITICO2            subb      #IC.F.XXX
                    beq       WRITICO1
                    incb
                    beq       WRITICO1
WRITICO3            ldd       FL.YSTRT,U          Get icon Y start position
                    pshs      d                   Save it
                    ldx       FL.XSTRT,U          Get icon X start position
                    ldd       2,S                 Get icon buffer #
                    orb       WD48FLAG            +$80 if double wide (for 80 column)
                    pshs      d,X                 Save 'em
                    ldx       PRCIDNUM            Get group #
                    ldd       WNDWPATH            Get window path
                    pshs      d,X                 Save 'em
                    lbsr      PUTBLK              Put icon on screen
                    leas      10,S                Eat temp stack
                    ldd       ,S                  Get icon type
                    andb      #$7F                Strip hi bit
                    cmpb      #IC.TRASH           Trash icon?
                    beq       NoName              Yes, don't print name
                    cmpb      #IC.PRNTR           Printer icon?
                    bne       WRITICO6            No, print name
NoName              pshs      U                   Yes, fake stack for exit, NO name printing
                    bra       GENLEXIT            Eat stack & return

WRITICO6            cmpb      #IC.DRIVE           Drive icon?
                    bne       WRITICO4            No, skip ahead
                    pshs      U
                    lbsr      POSIDRNM            Print drive name below drive icon
                    bra       GENLEXIT            Eat stack & exit

WRITICO4            pshs      U                   If not trash or drive, print icon name
                    bsr       WRITFNAM
WRITICO5            bra       GENLEXIT            Eat stack & exit

WRITFNAM            pshs      U
                    ldu       4,S                 Get ptr to current icon table
                    ldd       FL.FNAME,U          Get ptr to icon name
                    pshs      d                   Save em
                    pshs      U
                    bra       ERWRFNAM            Write out icon (file) name

* Erase the filename from the screen (under the icon)
ERASFNAM            pshs      U
                    leax      <TENSPACE,PC
                    ldd       4,S
                    pshs      d,X
ERWRFNAM            bsr       POSIFNAM            Print filename under icon
GENLEXIT            leas      4,S                 Eat stack, restore U and return
                    puls      U,PC

TENSPACE            fcc       "      "
FOURSPAC            fcc       "    "
                    fcb       NUL

POSIFNAM            pshs      U
                    ldu       4,S
                    ldd       8-2,S
                    pshs      d
                    lbsr      STRLEN
                    cmpd      #10
                    ble       POSIFNA1
                    ldd       #10
                    tst       WD48FLAG
                    beq       POSIFNA1
                    incb
POSIFNA1            std       ,S
                    ldd       FL.YSTRT,U          Get Y start of icon
                    addd      #1                  Force to next text line
                    lbsr      DIVDX8              Divide by 8 (text Y position)
                    addd      #3                  Add 3 (to skip 3*8 pixel height of icon)
                    pshs      d
                    ldd       2,S
                    asra
                    rorb
                    pshs      d
                    ldd       FL.XSTRT,U
                    pshs      d
                    ldd       #6
                    lbsr      CCDIV
                    subd      ,S++
                    addd      #2
                    tst       WD48FLAG
                    beq       POSIFNA3
                    addd      #2

POSIFNA3            pshs      d
                    ldd       WNDWPATH
                    pshs      d
                    tst       WD48FLAG
                    bne       POSIFNA4
                    ldd       FL.XSTRT,U
                    cmpd      #200
                    blo       POSIFNA4
                    inc       3,S

POSIFNA4            lbsr      GOTOXY
                    ldd       0+6,S
                    std       4,S
                    ldd       10+4,S
                    bra       POSIFNA2

* Print drive name (max 4 chars) at proper position below drive icon
POSIDRNM            pshs      U
                    ldu       4,S                 Get ptr to icon entry for current drive
                    ldd       FL.FNAME,U          Get drive name ptr
                    pshs      d                   Save it
                    lbsr      STRLEN              Calculate length of drive name
                    cmpd      #4                  4 or less?
                    ble       POSIDRN1            Yep, continue
                    ldd       #4                  No, 4 is max.
POSIDRN1            std       ,S                  Save drive name size
                    ldd       FL.YSTRT,U          Get Y icon start
                    lbsr      DIVDX8              Calc char. position
                    addd      #2                  +2 to skip icon itself
                    pshs      d                   Save it
                    ldb       #1                  X position=1
                    pshs      d
                    ldd       WNDWPATH            Window path
                    pshs      d
                    lbsr      GOTOXY              Position text cursor
                    ldd       6,S                 Get drive name size
                    std       4,S                 Save it
                    ldd       FL.FNAME,U          Get drive name ptr
POSIFNA2            std       2,S                 Save it
                    lbsr      I.WRITE             Write out drive name
                    leas      8,S                 Eat temp stack
                    puls      U,PC                Restore U & return

* Scroll bar Y position table (for # of icon-filled screens)
* SCROLLxx: xx is the number of screens of icons present
*  the last screen is ALWAYS the last position (20), irregardless of the #
*  of screens used.
* since using x200 now, can expand to 21 screen, using 0-20
* Data is then which Y position to be in for each screen set
* This should be a DIV type instruction, and screw the table to save memory
*  in the 6309 version
* EVENTUALLY, SEE IF WINDINT CAN HANDLE VARIABLE SIZED SCROLL
*   BARS (SEE NOTES I PUT IN MULTI-VUE MANUAL).
SCROLL02            fcb       0
SCROLL03            fcb       0,10
SCROLL04            fcb       0,7,14
SCROLL05            fcb       0,7,11,15
SCROLL06            fcb       0,6,9,13,16
SCROLL07            fcb       0,4,7,10,13,16
SCROLL08            fcb       0,4,7,9,12,14,17
SCROLL09            fcb       0,4,6,8,10,12,14,16
SCROLL10            fcb       0,3,5,7,9,11,13,15,17
SCROLL11            fcb       0,2,4,6,8,10,12,14,16,18
SCROLL12            fcb       0,1,3,5,7,9,11,13,15,17,18
SCROLL13            fcb       0,1,2,3,5,7,9,11,13,15,17,18
SCROLL14            fcb       0,1,2,3,5,7,9,11,13,15,16,17,18
SCROLL15            fcb       0,1,2,3,4,5,7,9,11,13,15,16,17,18
SCROLL16            fcb       0,1,2,3,4,5,7,9,11,13,14,15,16,17,18
SCROLL17            fcb       0,1,2,3,4,5,6,7,9,11,13,14,15,16,17,18
SCROLL18            fcb       0,1,2,3,4,5,6,7,9,11,12,13,14,15,16,17,18
SCROLL19            fcb       0,1,2,3,4,5,6,7,8,9,11,12,13,14,15,16,17,18
SCROLL20            fcb       0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18

* Select icon on screen - draw box around AIF ones, just FFill for drives,
*  folders, data files or executables. Done in color 3, reverts to color 1
*  on exit.
* NOTE: TRY CHANGING TO XOR BAR AROUND ICON & NAME OF ICON. SHOULD BE FASTER
* & SMALLER (don't need "stop box" around AIF's to prevent FFILL leaking)
* Entry: U=Ptr to FL.* data structure
SELCICON            pshs      U
                    ldu       4,S
                    beq       SELCICO3
                    ldb       #3                  color 3
                    pshs      d,X
                    ldb       WNDWPATH+1
                    pshs      d
                    lbsr      FCOLOR              Change foreground color to 3
                    ldb       FL.ICONO,U          Get icon type
                    beq       SELCICO2
                    cmpb      #IC.PRGRM           Program, folder or text?
                    bls       SELCICO1            Yes, draw box
                    cmpb      #IC.DRIVE           Drive icon?
                    beq       SELCICO1            Yes, draw box
                    subb      #IC.AIF.F           If AIF file, draw box around icon 1st
                    beq       SELCICO1
                    decb                          If anything but AIF itself or found AIF extension, don't
                    bne       SELCICO2            draw box around icon
SELCICO1
                    ifne      H6309
                    lde       #1                  Flag we want inverted shadow as well
                    else
                    lda       #1
                    sta       REGE
                    endc
                    bsr       DRAIFBOX            Draw "selected" box around icon
SELCICO2            std       2,S
                    clrb                          Reset foreground color to black
                    std       2,S
                    lbsr      FCOLOR
                    leas      6,S
SELCICO3            puls      U,PC

* Unselect icon
* Entry: U=ptr to FL.* structure
UNSLICON            pshs      U
                    ldu       4,S
                    beq       SELCICO3
                    ldb       FL.ICONO,U          Get icon type
                    beq       UNSLICO2
                    cmpb      #IC.PRGRM           text, folder or program?
                    bls       UNSLICO1            Yes, draw box
                    cmpb      #IC.DRIVE           Drive?
                    beq       UNSLICO1            Yes, draw grey box
                    subb      #IC.AIF.F           If AIF or previously done AIF, we do outside box stuff 1st
                    beq       UNSLICO1
                    decb
                    bne       UNSLICO2
UNSLICO1            ldx       #2                  If AIF related, set color to 2 and draw box around it (clear
                    ldb       WNDWPATH+1          box around around icon)
                    pshs      d,X
                    lbsr      FCOLOR
                    ifne      H6309
                    clre                          Flag that we are just doing light grey box
                    else
                    clr       REGE
                    endc
                    bsr       DRAIFBOX            Light grey box (same as background color)
                    clrb
                    stb       3,S
                    lbsr      FCOLOR              Reset foreground color to black
                    leas      4,S
UNSLICO2            puls      u,pc                ALSO REDRAWS FILENAME - UNNECESSARY FROM HERE, ANYWAYS

* Draw select box around selected drive/icon
* Color should be set up before calling
* Entry: E=0 if just straight box, <>0 if box AND dark grey invert shadow
*        U=ptr to FL.* structure
* Uses F
DRAIFBOX            ldd       FL.YSTRT,U          Get Y start coord for icon, subtract 2 for box
                    subb      #2                  A little above top of icon
                    pshs      d
                    ldx       FL.XSTRT,U          Get X pos of icon
                    ifne      H6309
                    ldf       FL.ICONO,u          Get icon type
                    subf      #IC.DRIVE           Drive? (special case)
                    else
                    lda       FL.ICONO,u          Get icon type
                    suba      #IC.DRIVE           Drive? (special case)
                    sta       REGF
                    endc
                    bne       NormIcon            No, do normal box
                    leax      -3,x                Yes, smaller box
                    bra       Minus9              Go save X pos

NormIcon            leax      -9,X                -9 to include text
                    tst       WD48FLAG            If 40 column, bump down by another 14
                    bne       Minus9
                    leax      -16,x
                    ldd       FL.XSTRT,u          Get original icon start again
                    ifne      H6309
                    lsld                          Put column # in A
                    lsld
                    else
                    lslb
                    rola
                    lslb
                    rola
                    endc
AdjLoop             leax      2,x                 2 pixels per column
                    deca
                    bne       AdjLoop
Minus9              ldd       WNDWPATH            Save X start & window path
                    pshs      d,X
                    lbsr      SETDPTR             Set draw ptr to upper left corner of box
* include text below icon as well
                    ldd       #36                 Box height 36 pixels (2 above & below)
                    ifne      H6309
                    tstf
                    else
                    tst       REGF
                    endc
                    bne       NormIco2
                    ldd       #24                 Unless drive, then 24
NormIco2            std       4,S
                    ifne      H6309
                    tstf                          Drive?
                    else
                    tst       REGF
                    endc
                    bne       NormIco3            No, determine width
                    ldb       #29                 Special width for drive
                    bra       DRAIFBO1

NormIco3            ldb       #68                 80 columns defaults to 68 pixel width
                    tst       WD48FLAG            If 80 column skip ahead
                    bne       DRAIFBO1
                    ldb       #62                 Box width 62 pixels for 40 column
DRAIFBO1            std       2,S                 Save box width
                    lbsr      RBOX                Draw box & return
* use entry flag to flag whether
                    ifne      H6309
                    tste                          Do we want shadow too?
                    else
                    tst       REGE
                    endc
                    beq       DoneAIFB            No, exit
                    ldb       #1                  Dark Grey color
                    std       2,s
                    lbsr      FCOLOR
                    clrb                          Set X offset to 0
                    std       2,s
                    lbsr      RLINE               Draw vertical line
                    clrb                          Set Y offset to 0
                    std       4,s
                    ifne      H6309
                    tstf                          Drive?
                    else
                    tst       REGF
                    endc
                    bne       NormIco4            No
                    ldb       #28
                    bra       Do40Shdw

NormIco4            ldb       #61                 61 pixel width for 40 column
                    tst       WD48FLAG
                    beq       Do40Shdw
                    ldb       #67                 67 pixel width for 80 column
Do40Shdw            std       2,s                 X offset
                    lbsr      RLINE               Draw horizontal dark grey line
DoneAIFB            leas      6,S                 Eat stack & return
                    rts

UPDTDEVC            pshs      U
                    ldu       #DRIVETBL
                    ldx       #21
                    ldb       #4
                    pshs      d,X
                    ldx       #1
                    pshs      X
                    ldb       WNDWPATH+1
                    pshs      d,X
                    lbsr      CWAREA
                    lbsr      MOUSOFF
                    lbsr      CLRSCRN
                    lbsr      FULLSCRN
                    bra       UPDTDEV2

UPDTDEV1            lbsr      WRITICON            Print icon on screen
                    ldu       FL.LINK,U           Get next device in linked list
UPDTDEV2            stu       ,S                  Save it
                    bne       UPDTDEV1            Still more drives, do next one
                    ldx       #TRSHDESC           Now, do trash can
                    stx       ,S
                    lbsr      WRITICON
                    ldx       #PRTRDESC           And printer
                    stx       ,s
                    lbsr      WRITICON
                    ldd       DEVICNOW            Get current drive (if any)
                    std       ,S
                    lbsr      SELCICON            Select it on screen
                    ldd       WNDWPATH
                    std       ,S
                    lbsr      INITMOUS            Set mouse parms
                    leas      10,S
                    puls      U,PC

* Get ptr to root path (not including drive name)
* Exit: X=ptr to either end of pathname (if on root), or ptr to root path
*       D=1 if on root
*       D=0 if found path
FNDSLASH            ldx       #DDIRNAME+1         Point to full path of current dir (skip 1st '/')
FNDSLAS1            ldb       ,X+                 Get char
                    beq       FNDSLAS2            End of path, exit with D=1
                    cmpb      #'/                 Find slash?
                    bne       FNDSLAS1            No, keep looking
                    clrb                          Exit with D=0
                    bra       FNDSLAS3

FNDSLAS2            incb
FNDSLAS3            clra
                    rts

* Check if icon (or clickable option)
* Exit: D=0 if no icon selected
*       else D=ptr to FL.* structure for icon selected
ISITICON            pshs      U
                    ldx       4,S                 Get ptr to mouse packet
                    ldd       PT.ACY,X            Get Y coord
                    subd      #8
                    pshs      d,X                 Save modified Y coord & room for X coord
                    ldd       PT.ACX,X            Get X coord
                    tst       FLAG640W            640 wide screen?
                    bne       ISITICO1            No, skip ahead
                    ifne      H6309
                    asrd                          Divide by 2 (scale to 320)
                    else
                    asra
                    rorb
                    endc
ISITICO1            subd      #8
                    std       2,S                 Save modified X coord
                    cmpd      #32                 Is X coord within 32 pixels of left side (no border)?
                    ble       ISITDEVC            Yes, check for device (NOTE: WHERE PRINTER SHOULD GO)
                    ldd       ,S                  Get Y adjusted coord
                    cmpd      #8                  Is it in the current directory bar area?
                    bgt       ISITDISP            No, skip ahead
                    ldu       #DBOXDESC           Point to icon info table entry for CLOSE box in current dir bar
                    bra       ISITICO4            Go check that

ISITDISP            ldu       STRTICON            Get ptr to icon descriptor for 1st icon on current scrn
                    bra       ISITICO4            Check it

ISITDEVC            ldu       #DRIVETBL           Point to start of device/drive table
                    ldd       ,S                  Get adjusted Y coord (NOTE: LDB 1,S BOTH 6809/6309)
                    cmpb      #128                From 0-128 (drives themselves)?
                    blo       ISITICO4            Yes, check with drive table entries
                    cmpb      #160                Trash?
                    blo       TryPrntr            No, try printer
                    ldu       #TRSHDESC           Try the trash can descriptor
                    bra       ISITICO4

TryPrntr            ldu       #PRTRDESC           Try printer descriptor
                    bra       ISITICO4

ISITICO2            ldd       2,S                 Get X coord
                    cmpd      FL.XSTRT,U          Within X start coord of current file table entry?
                    blt       ISITICO3            No, check next file entry
                    cmpd      FL.XEND,U           Within X end coord of current entry?
                    bgt       ISITICO3            No, check next file entry
                    ldd       ,S                  Get Y coord
                    cmpd      FL.YSTRT,U          Within Y start coord of current entry?
                    blt       ISITICO3            No, check next
                    cmpd      FL.YEND,U           Within Y end coord of current entry
                    bgt       ISITICO3            No, check next
                    tfr       U,D                 Found, move table entry ptr to D & exit
                    bra       ISITICO5

* Go to next file table entry
ISITICO3            ldu       FL.LINK,U           Get next file table ptr
ISITICO4            stu       -2,S                Is this a legit ptr?
                    bne       ISITICO2            Yes, go check it
                    clra                          No match, return with 0 (done, & no icon clicked)
                    clrb
ISITICO5            leas      4,S                 Eat stack & return
                    puls      U,PC

SET48X24            ldd       #288
                    std       14,S
                    ldx       #MULTIBFR           Point to general purpose buffer
                    stx       16,S
                    ldb       #7
                    stb       9,S
                    ldd       #48
                    std       10,S
                    ldb       7,S
                    orb       #$80
                    stb       7,S
                    rts

SET24X24            ldd       #144
                    std       14,S
                    ldx       #ICONBUFR           Point to icon build buffer
                    stx       16,S
                    ldb       #6
                    stb       9,S
                    ldd       #24
                    std       10,S
                    rts

* Load standard icons
STDICONS            leas      -12,S               Make temp buffer on stack
                    ldx       PRCIDNUM            Get GSHELL's process id # (for group)
                    ldd       WNDWPATH            Get GSHELL's window path
                    pshs      d,X                 Save them
                    ldb       #24                 Save ??? (height in pixels?)
                    std       10,S
                    leax      txticon,pc          Point to new 4 color image of text
                    ldb       #144
                    lbsr      CopyIcon
                    lbsr      ICN48X24
                    ldd       #IC.TEXT
                    std       4,S
                    bsr       SET24X24
                    lbsr      GPLOAD
                    bsr       SET48X24
                    lbsr      GPLOAD

                    leax      foldricn,pc         Point to new 4 color image of folder
                    ldb       #144
                    lbsr      CopyIcon
                    lbsr      ICN48X24
                    ldb       #IC.FOLDR
                    std       4,S
                    bsr       SET24X24
                    lbsr      GPLOAD
                    bsr       SET48X24
                    lbsr      GPLOAD

                    leax      execicon,pc         Point to new 4 color image of executable
                    ldb       #144
                    lbsr      CopyIcon
                    lbsr      ICN48X24            Make double width version for 80 column screen
                    ldb       #IC.PRGRM
                    std       4,S
                    bsr       SET24X24
                    lbsr      GPLOAD
                    lbsr      SET48X24
                    lbsr      GPLOAD

                    leax      trashicn,pc         Point to new 4 color image of trashcan
                    ldb       #144
                    lbsr      CopyIcon
                    ldb       #IC.TRASH
                    std       4,S
                    bsr       SET24X24
                    lbsr      GPLOAD
                    ldb       #7
                    stb       7,S
                    ldb       #IC.TRASH+$80
                    stb       5,S
                    lbsr      GPLOAD
                    lbsr      SET24X24

                    leax      driveicn,pc         Point to new 4 color image of drive
                    ldb       #72
                    lbsr      CopyIcon
                    ldd       #72                 72 bytes to load
                    std       12,S
                    ldb       #12                 12 lines high
                    std       10,S
                    ldb       #IC.DRIVE           Buffer #
                    std       4,S
                    lbsr      GPLOAD              Load it in
                    ldb       #7                  Screen type 7
                    stb       7,S
                    ldb       #IC.DRIVE+$80       Buffer #+$80 for type 7 version (useless, same as type 6)
                    stb       5,S
                    lbsr      GPLOAD              Load the type 7 version (eliminate later!)

                    leax      prntricn,pc         Point to new 4 color image of printer
                    ldb       #90                 90 bytes to load/copy
                    lbsr      CopyIcon
                    ldd       #90                 72 bytes to load
                    std       12,S
                    ldb       #15                 12 lines high
                    std       10,S
                    ldb       #IC.PRNTR           Buffer #
                    std       4,S
                    lbsr      GPLOAD              Load it in
                    ldb       #7                  Screen type 7
                    stb       7,S
                    ldb       #IC.PRNTR+$80       Buffer #+$80 for type 7 version (useless, same as type 6)
                    stb       5,S
                    lbsr      GPLOAD              Load the type 7 version (eliminate later!)

                    leas      16,S
                    rts

* NOTE: XPNDICONS ROUTINE ORIGINALLY HERE...NO LONGER NEEDED

* duplicate a 24x12 4 color buffer to a 48x12
ICN48X24            ldb       #144                Counter for # of bytes in 4 color icon
                    pshs      B,U                 Save it
                    ldx       #ICONBUFR           Point to 4 color icon buffer
                    ldu       #MULTIBFR           Point to bigger buffer to expand into (could expand into LINEBUFR)
IC48X24L            ldb       ,X+                 Get 4 color byte
                    bsr       SR48X24             Expand 2 pixels (a nibble) into 4 pixels (a byte)
                    bsr       SR48X24             Do next last half of byte
                    dec       ,S                  Are we done all 144 source bytes?
                    bne       IC48X24L            No, continue
                    puls      B,U,PC              Restore & return

SR48X24             clra                          Zero out hi byte
                    lslb                          Shift 1st color into B (2 bits)
                    rola
                    lslb
                    rola
                    lsla                          Now, shift that over 1 pixel
                    lsla
                    lslb                          Shift in the next pixel from the source byte
                    rola
                    lslb
                    rola
                    pshs      A                   Save that byte (2 source pixels, now separated by a pixel)
                    lsla                          Shift it left by a pixel
                    lsla
                    ora       ,S+                 Merge with original (effectively doubling each pixel)
                    sta       ,U+                 Save doubled up byte
                    rts

AIF.NAME            fcc       "aif"

ONEDOT              fcb       '.
                    fcb       NUL

* Entry: 0-1,s=RTS address
*        2-3,s=Ptr to file table entry
FILE.XXX            pshs      U
                    ldu       4,S                 Get ptr to file table entry
                    leas      -64,S               Make large buffer on stack
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       28,S
                    ldd       FL.FNAME,U          Get ptr to filename
                    pshs      d
                    lbsr      ISIT.AIF
                    std       28+2,S
                    ldd       70+2,S
                    std       ,S
                    lbsr      MTCH.XXX
                    leas      2,S
                    std       22,S
                    lbne      FILEXXX3
                    ldd       70,S
                    pshs      d
                    leax      <AIF.NAME,PC
                    pshs      X
                    leax      38-2,S
                    pshs      X
                    lbsr      STRCPY
                    leas      4,S
                    pshs      d
                    lbsr      STRCAT
                    std       26+4,S
                    ldx       #READ.
                    stx       2,S
                    std       ,S
                    lbsr      I.OPEN2             Open AIF file
                    leas      4,S
                    std       30,S                Save path to AIF file
                    lblt      FILEXXX2            Couldn't open, skip ahead
                    ldd       70,S
                    pshs      d
                    lbsr      PUTSTRNG
                    std       ID.XXXPT+2,S
                    ldd       30+2,S              Get path to AIF file
                    std       ,S
                    lbsr      RDLN80CH            Read line of up to 80 chars (program name)
                    std       ,S                  Save size of read
                    lbsr      PUTSTRNG            Allocate mem & copy string into that mem
                    std       ID.MNAME+2,S        Save pointer to program name in AIF structure
                    std       26+2,S              Save again
                    ldd       30+2,S              Get path to AIF file again
                    std       ,S
                    lbsr      RDLN80CH            Read parameters line
                    std       ,S                  Save size of read
                    lbsr      PUTSTRNG            Allocate mem & copy string
                    std       ID.PARAM+2,S        Save parm line
                    ldd       30+2,S
                    std       ,S
                    lbsr      RDLN80CH            Get icon file path
                    std       ,S                  Save # bytes read
                    lbsr      PUTSTRNG            Allocate mem & copy string
                    std       24+2,S
                    ldd       30+2,S
                    std       ,S
                    lbsr      GETNUMBR            Get memory modifier (in 256 byte pages) HANDLES +/-
                    std       ID.MEMSZ+2,S        Save mem size
                    lbsr      GETNUMBR
                    std       ID.WTYPE+2,S        Save window type (includes - & 0's!)
                    lbsr      GETNUMBR
                    std       ID.XSIZE+2,S        Save minimum X size
                    lbsr      GETNUMBR
                    std       ID.YSIZE+2,S        Save minimum Y size
                    lbsr      GETNUMBR
                    std       ID.BKGND+2,S        Save background color
                    lbsr      GETNUMBR
                    std       ID.FRGND+2,S        Save foreground color
                    lbsr      I.CLOSE             Close the AIF file
                    ldb       #EXEC.+READ.
                    std       ,S
                    ldd       26,S                Get icon file path ptr
                    pshs      d
                    lbsr      I.OPEN2             Open icon file
                    leas      4,S
                    std       30,S                Save path # to icon file
                    blt       FILEXXX1            Error opening, skip ahead
                    ldd       #144                Size of icon file
                    pshs      d
                    ldx       #ICONBUFR           Point to buffer to hold icon data
                    ldd       34-2,S              Get path #
                    pshs      d,X                 Save them both
                    lbsr      I.READ              Read in icon data
                    ldd       30+6,S              Get path # again
                    std       ,S
                    lbsr      I.CLOSE             Close icon file
                    ldd       24+6,S
                    std       ,S
                    lbsr      FREE
                    ldd       70+6,S
                    std       ,S
                    lbsr      EXTICTBL            Allocate a new AIF descriptor entry (ID.*)
                    std       22+6,S              Save ptr to new entry
                    std       ,S                  and again
                    ldd       #ID.SIZE            Get size of ID.* structure
                    std       4,S                 Save it
                    leax      2+4,S
                    stx       2,S
                    lbsr      STRNCPY             ?? Copy stack copy of ID.* structure into allocated entry
                    ldd       NXTICONO,Y
                    ldx       22+6,S
                    std       ,X
                    ifne      H6309
                    incd
                    else
                    addd      #$0001
                    endc
                    std       NXTICONO,Y
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       ID.LINK,X
                    ldd       #24
                    std       ,S
                    pshs      d
                    ldd       [32-2,S]
                    pshs      d,X
                    ldx       PRCIDNUM
                    ldd       WNDWPATH
                    pshs      d,X
                    lbsr      SET24X24
                    lbsr      GPLOAD
                    lbsr      ICN48X24
                    lbsr      SET48X24
                    lbsr      GPLOAD
                    leas      16,S
                    bra       FILEXXX2

FILEXXX1            ldd       14,S
                    pshs      d
                    lbsr      FREE
                    ldd       18+2,S
                    std       ,S
                    lbsr      FREE
                    ldd       24+2,S
                    std       ,S
                    lbsr      FREE
                    leas      2,S
FILEXXX2            ldd       30,S
                    bge       FILEXXX3
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    bra       FILEXXX6

FILEXXX3            ldd       28,S
                    beq       FILEXXX4
                    ldx       22,S
                    ldd       ID.MNAME,X
                    pshs      d
                    pshs      U
                    lbsr      RPLFICON
                    leas      4,S
                    tfr       D,U
                    ldd       #IC.AIF.F
                    stb       FL.ICONO,U
                    bra       FILEXXX5

FILEXXX4            ldd       #IC.F.XXX
FILEXXX5            std       28,S
                    ldd       [22,S]
                    stb       FL.AIFNO,U
                    ldd       28,S
FILEXXX6            leas      64,S
                    puls      U,PC

* Allocate new ID.* descriptor
* Exit:D=0 if could not allocate new descriptor
*      or D=ptr to where new descriptor is
EXTICTBL            pshs      U
                    ldd       #ID.SIZE            Size of ID.* structure (for AIF's)
                    pshs      d,X
                    lbsr      MEMSPACE            Try to allocate memory for another ID.* entry
                    leas      2,S
                    std       ,S                  Save ptr to where new ID.* entry will go
                    std       [IDSCNEXT,Y]        ??? Save where process ID # is supposed to be???
                    addd      #ID.LINK            offset to next link ptr within ID.* entry
                    std       IDSCNEXT            Save as ptr to next available icon desc. link
                    ldd       ,S++                Get ptr to new entry
                    puls      U,PC                Return with it

FIND.XXX            ldx       2,S
                    lbsr      STREND1
                    ldb       #'.
                    cmpb      -4,X
                    bne       ISITAIF4
                    leax      -3,X
                    tfr       X,D
                    rts

* Get a numeric input
* Entry: Path # to read from on stack
GETNUMBR            ldd       2,S                 Get path to do read from
                    pshs      d
                    lbsr      RDLN80CH            Go do 80 char readln
                    std       ,S                  Save # chars read
                    beq       GETNUMB1            If no characters read, exit
                    lbsr      ATOI                Convert ASCII # to raw binary form
GETNUMB1            leas      2,S
                    rts

ISIT.AIF            ldx       2,S
                    ldd       ,X++
                    ifne      H6309
                    andd      #$5f5f
                    else
                    anda      #$5f
                    andb      #$5f
                    endc
                    cmpd      #"AI
                    bne       ISITAIF4
                    ldd       ,X
                    anda      #$5F
                    cmpd      #"F.
                    beq       ISITAIF5
ISITAIF4            clra
                    clrb
ISITAIF5            rts

MTCH.XXX            pshs      X,U
                    ldu       6,S
                    ldx       IDSCSPTR
                    leax      ID.SIZE*2,X
                    ldx       ID.LINK,X
                    beq       MTCH.XX2
MTCH.XX1            ldd       ID.XXXPT,X
                    pshs      d,U
                    lbsr      STRCMP
                    leas      4,S
                    std       -2,S
                    beq       MTCH.XX2
                    ldx       ID.LINK,X
                    bne       MTCH.XX1
MTCH.XX2            tfr       X,D
                    puls      X,U,PC

* Entry: 0-1,s : RTS address
*        2-3,s : AIF entry # (anything lower than IC.XTRNL is internal AIF's
*                only, such as GCALC, etc.)
* Exit: D=ptr to ID.* structure that matches
*       D=0 if no match found
FNDIDESC            pshs      U
                    ldd       4,S                 Get AIF entry # for ID.* structure (only need B)
                    ldu       IDSCSPTR            Get ptr to start of icon descriptor table
FNDIDES1            cmpb      ID.NUMBR+1,U        Is this the correct ID.* entry?
                    beq       FNDIDES2            Yes, skip ahead
                    ldu       ID.LINK,U           Get ptr to next ID.* entry
                    bne       FNDIDES1            Go check it out
                    bra       FNDIDES5            Hit end of list, no match so exit with ptr=0

FNDIDES2            cmpb      #IC.XTRNL           Is this an external AIF?
                    bge       FNDIDES5            Yes, exit
                    cmpb      #IC.GCAL            Is it the calender program?
                    bne       FNDIDES3            No, use GSHELL's current window type
* ADDED FOR GCAL - to allow it on an 80 column screen
                    ldd       DEFWTYPE            Get current GSHELL window type
                    cmpd      #8                  Is it a 16 color?
                    bne       FNDIDES4            No, allow GSHELL window type
                    ldd       #6                  Force GCAL to use type 6 (320x200x4)
                    bra       FNDIDES4

FNDIDES3            ldd       DEFWTYPE            Use default window type (GShell's actual type)
FNDIDES4            std       ID.WTYPE,U          Save as AIF's window type
FNDIDES5            tfr       U,D                 D=ptr to AIF entry found
                    puls      U,PC

* Kill icon Get/put buffer, free up table entry???
KILIBUFS            pshs      U
                    ldu       IDSCSPTR
                    leau      ID.SIZE*3,U
                    ldd       ID.LINK,U
                    pshs      d
                    clra
                    clrb
                    std       ID.LINK,U
                    bra       KILIBUF2

KILIBUF1            ldd       ID.LINK,U
                    std       ,S
                    ldd       ID.NUMBR,U
                    pshs      d
                    ldd       PRCIDNUM
                    pshs      d
                    ldd       WNDWPATH
                    pshs      d
                    lbsr      KILBUF
                    ldb       5,S
                    orb       #$80
                    stb       5,S
                    lbsr      KILBUF
                    ldd       ID.MNAME,U
                    std       ,S
                    lbsr      FREE
                    ldd       ID.XXXPT,U
                    std       ,S
                    lbsr      FREE
                    ldd       ID.PARAM,U
                    std       ,S
                    lbsr      FREE
                    stu       ,S
                    lbsr      FREE
                    leas      6,S
KILIBUF2            ldu       ,S
                    bne       KILIBUF1
                    ldd       #IC.XTRNL
                    std       NXTICONO,Y
                    ldx       #ENDLINK
                    stx       IDSCNEXT
                    puls      d,U,PC

PUTSTRNG            ldd       2,S
                    pshs      d
                    lbsr      STRLEN
                    addd      #1
                    std       ,S
                    bsr       MEMSPACE
                    std       ,S++
                    beq       PUTSTRNX
                    ldx       2,S
                    pshs      d,X
                    lbsr      STRCPY
                    leas      4,S
PUTSTRNX            rts

* Allocate memory from internal data area?
* Entry: # bytes requested at 0,s
* Exit: appears to be ptr to start of memory received, or 0 if couldn't get
*       memory requested
MEMSPACE            ldd       2,S                 Get size of memory requested
                    pshs      d
                    lbsr      MALLOC              Allocate it
                    std       ,S                  Save ptr to memory received
                    bne       MEMSPAC1            Successful MALLOC, exit with new mem ptr
                    leax      <OUTOFMEM,PC        Unsuccesfull, print 'Out of memory" in overlay window
                    pshs      X
                    lbsr      OLAYPRNT
                    leas      2,S
MEMSPAC1            puls      d,pc                Return with ptr

OUTOFMEM            fcc       "Out of memory"
CRETURN             fcb       CR,NUL

* See if all forked processes shut down before we exit
* Exit: D=-1 if still active processes
*
TESTQUIT            pshs      U
                    ldu       PTBLSPTR            Get ptr to start of linked list of process descriptors
                    beq       TSTQUIT3            No entries
TSTQUIT1            ldx       GD.LINK,U
                    ldd       GD.STATS,U
                    bge       TSTQUIT2
                    leax      <STILACTV,PC        Print "processes still active" in overlay window
                    pshs      X
                    lbsr      OLAYPRNT
                    leas      2,S
                    ldd       #-1                 Flag we can't exit GSHELL yet
TSTQUIT3            puls      U,PC

TSTQUIT2            tfr       X,U
                    stu       -2,S
                    bne       TSTQUIT1
                    puls      U,PC

TRYQUIT             pshs      U
                    ldx       #1
                    ldb       WNDWPATH+1
                    pshs      d,X
                    lbsr      PAUSECHO            Set pause & echo ON
                    lbsr      CURSORON            Turn text cursor ON
                    lbsr      ST.RELEA            Release any pending signals
                    lbsr      KILLPBUF
                    clr       3,S
                    lbsr      NOMOUSE             Shut mouse autofollow off
                    lbsr      ST.WNSET
                    clrb
                    pshs      d
                    lbsr      SELECT
                    leas      2,S
                    lbsr      I.CLOSE
                    leas      4,S
                    ldd       4,S
                    blt       TRYQUIT4
                    pshs      d
                    lbsr      F.EXIT
TRYQUIT4            clra
                    clrb
                    puls      U,PC

STILACTV            fcc       "Processes still active"
                    fcb       NUL

ERRPRINT            pshs      U
                    ldu       6,S
                    ldd       GD.WPATH,U          Get process window path
                    cmpd      WNDWPATH            Same as GSHELL window path?
                    ble       ERRPRIN1
                    pshs      d
                    lbsr      SELECT
                    ldd       WNDWPATH
                    std       ,S
                    lbsr      SELECT
                    leas      2,S
ERRPRIN1            ldd       GD.STATS,U          Get last status (error) from program
                    pshs      d
                    ldx       GD.MNAME,U          Get ptr to module name that had error
                    ldd       6,S
                    pshs      d,X
                    bsr       BUILDMSG
                    leas      6,S
                    puls      U,PC

BUILDMSG            ldd       6,S
                    pshs      d
                    lbsr      BIN2ASCI
                    std       ,S
                    leax      <QUOTDASH,PC
                    pshs      X
                    ldx       8,S
                    ldd       6,S
                    pshs      d,X
                    ldx       #MULTIBFR
                    pshs      X
                    lbsr      STRCPY
                    leas      4,S
                    pshs      d
                    lbsr      STRCAT
                    leas      4,S
                    pshs      d
                    lbsr      STRCAT
                    leas      4,S
                    pshs      d
                    lbsr      STRCAT
                    leas      4,S
                    pshs      d
                    bsr       OLAYPRNT
                    leas      2,S
                    rts

QUOTDASH            fcb       '"
                    fcc       " - "
                    fcb       NUL

OLAYPRNT            ldx       #1
                    ldd       2,S
                    pshs      d,X
                    ldd       WNDWPATH
                    pshs      d
                    lbsr      OLAYGNBK
                    bsr       WAITPRES
                    lbsr      KILOLAY2
                    bra       OLAYPRN1

* Write out a string to the current window path (string length determined by
* NUL char)
* Entry: 0-1,s = RTS address
*        2-3,s = ptr to string to write
WTSTRLEN            ldd       2,S                 Get ptr to string to write
                    pshs      d
                    lbsr      STRLEN              Determine length
                    std       ,S                  Save it
                    ldx       4,S
                    ldd       WNDWPATH            Get path to window
                    pshs      d,X
                    lbsr      I.WRITE             Write it out
OLAYPRN1            leas      6,S                 Eat temp stack & return
                    rts

* Write out a string to the current window path (string length determined by
* NUL char) and add a Carriage return if there isn't one already
* Entry: 0-1,s = RTS address
*        2-3,s = ptr to string to write
WRLNWCR             pshs      Y,U
                    ldd       6,S                 Get ptr to string
                    pshs      d
                    lbsr      STREND              Get end position of string
                    tfr       D,U
                    subd      ,S++                Calculate size of string
                    tfr       D,Y
                    ldx       6,S                 Get ptr to string again
                    lda       WNDWPATH+1          Get window path
                    os9       I$WRITLN            Write it
                    ldb       -1,U                Was last char a CR?
                    cmpb      #CR
                    beq       WRLNWCRX            Yep, done
                    ldy       #1                  No, write a CR too
                    leax      CRETURN,PC
                    os9       I$WRITLN
WRLNWCRX            puls      Y,U,PC

WAITPRES            pshs      U
                    ldu       4,S
                    pshs      U
                    lbsr      ST.RELEA
                    ldd       #NEWNMSG-PRESSMSG
                    std       ,S
                    ldx       #PRESSMSG
                    pshs      X
                    pshs      U
                    lbsr      I.WRITE
                    leas      6,S
                    lbsr      WAITPSIG
                    puls      U,PC

* ReadLn up to 80 chars into [LINEBUFR]
RDLN80CH            ldd       #80                 Max read size
                    pshs      d
                    ldx       #LINEBUFR           Get ptr to read buffer
                    ldd       4,S                 Get path to read from
                    pshs      d,X
                    lbsr      I.READLN            Read line up to 80 chars (note:includes CR!)
                    leas      6,S
                    addd      #1                  Add 1 to total of chars read
                    beq       RDLN80C0            If was -1 (had error),try reading again
                    subd      #2                  Just CR?
                    bne       RDLN80C1            No, skip ahead
RDLN80C0            clr       LINEBUFR,Y          If just one char, NUL instead of CR
                    rts

RDLN80C1            ldx       #LINEBUFR           Point to input buffer
                    pshs      X
                    leax      D,X                 Point to last char read in buffer
                    clr       ,X                  Terminate read string @ CR
                    puls      D,PC                Return with D=ptr to start of read buffer

BIN2ASCI            pshs      U
                    ldu       #ASCIITMP           Point to buffer to hold ASCII version of # (reverse order)
                    ldd       4,S
                    bra       BIN2ASC2

BIN2ASC1            pshs      d
                    ldd       #10
                    lbsr      CCMOD
                    addd      #'0                 'ASCII'ize the digit
                    stb       ,U+
                    ldd       4,S
                    pshs      d
                    ldd       #10
                    lbsr      CCDIV
                    std       4,S
BIN2ASC2            cmpd      #9
                    bgt       BIN2ASC1
                    addd      #'0
                    ldx       #ASCIITMP
                    pshs      X
                    ldx       #ASCIINUM
                    bra       BIN2ASC4

BIN2ASC3            ldb       ,-U
BIN2ASC4            stb       ,X+
                    cmpu      ,S
                    bhi       BIN2ASC3
                    leas      2,S
                    clr       ,X
                    ldx       #ASCIINUM
                    tfr       X,D
                    puls      U,PC

LINKLOAD            pshs      U
                    ldu       4,S
                    ldb       #PTR.SLP            Change ptr to sleep icon
                    pshs      d,X
                    ldx       #GRP.PTR
                    ldd       WNDWPATH
                    pshs      d,X
                    lbsr      GCSET
                    lbsr      MOUSOFF             Shut mouse off
                    leas      6,S
                    pshs      U
                    lbsr      NMLNKLOD            Attempt to link/load module
                    std       ,S++
                    beq       LINKLOA1            Error, deal with it
                    ldd       #1                  No error, status=successful
                    bra       LINKLOA2

LINKLOA1            ldd       ERRNO,Y             Get error code
                    std       GD.STATS,U          Save in forked program status
                    leax      <CANTFORK,PC        Tell user we could not fork program
                    pshs      X,U
                    lbsr      ERRPRINT
                    leas      4,S
                    clra                          Non successful fork
                    clrb
LINKLOA2            std       ,S                  Save status of fork
                    lbsr      MOUSENOW            Turn mouse back on and return
                    puls      d,U,PC

CANTFORK            fcc       "Can't fork "
                    fcb       '",NUL

RUNCNAME            fcc       "runc"
                    fcb       NUL

RUNBNAME            fcc       "runb"
                    fcb       NUL

BAS09NAM            fcc       "basic09"
                    fcb       NUL

* Fork program pointed to by GD.* ptr, onto it's proper window (obviously
* already set up in GD.INDVC or GD.WPATH earlier). Does language stuff
* automatically like SHELL, and mem size stuff
* Stack on entry:
* 0-1,s = RTS address
* 2-3,s = Ptr to GD.* vars
FORKPROC            pshs      U                   Save U
                    ldu       4,S                 Get GD.* ptr
                    leas      -12,S               Make temp stack
                    clra
                    clrb
                    std       10,S                Set some things to 0
                    std       8,S
                    std       ,S
                    ldb       GD.MLANG,U          Get language type of module to fork
                    cmpb      #OBJCT              ML code?
                    ble       SETPRGRM            Yes, go set
                    cmpb      #ICODE              RUNB required?
                    beq       SETRUNB             Yes, set that
                    cmpb      #PCODE              Pascal required?
                    beq       SETPASCL            Yes, set that
                    cmpb      #CBLCODE            COBOL required?
                    bne       BADLANG             No, don't have a clue what it is
                    leax      <RUNCNAME,PC        Must be RUNC (whatever that is?)
                    stx       10,S                Save ptr to runtime module name
                    bra       SETLANG

SETRUNB             leax      <RUNBNAME,PC        Set ptr to RUNB module name
                    stx       10,S
                    leax      <BAS09NAM,PC        2nd ptr to BASIC09
                    bra       SETRUNB1

SETPASCL            leax      <PASCSNAM,PC        Set ptr to PASCALS module name
                    stx       10,S
                    leax      <PASCNNAM,PC        2nd ptr to PASCALN
SETRUNB1            stx       8,S
                    bra       SETLANG

PASCSNAM            fcc       "pascals"
                    fcb       NUL

PASCNNAM            fcc       "pascaln"
                    fcb       NUL

BADLANG             leax      <CANTLANG,PC        Code type is unknown, notify user that we can
                    pshs      X                   not run.
                    lbsr      OLAYPRNT
                    leas      2,S
                    clra
                    clrb
                    lbra      BADLANGX

CANTLANG            fcc       "Can't determine language"
                    fcc       " for module"
                    fcb       CR,NUL

* Entry: 10,s=ptr to runtime module
*  X=ptr to 2ndary module (if needed) ex. BASIC09 for RUNB
SETLANG             ldd       #$0101              Module type=Program module, language=ML
                    std       GD.MTYPE,U          Save module type&language of primary program to execute
SETPRGRM            ldd       10,S                Get ptr to name of primary program
                    beq       FORKPRC2            If raw ML module (no runtime package), skip ahead
                    ldd       GD.MNAME,U          Get ptr to sub-module name (ex. program name for RUNB)
                    pshs      d                   Save it
                    lbsr      STPREFIX            Build (into PARMSBFR) program name <space> module name
                    leas      2,S                 Eat stack
                    ldd       10,S                Get ptr to name of primary program
                    bra       FORKPRC3

FORKPRC2            ldd       GD.MNAME,U          Get ptr to module to run
FORKPRC3            std       6,S                 Save it
                    ldx       #PARMSBFR           Point to temp buffer
                    pshs      X                   Save it
                    lbsr      STRLEN              Get length of command line to run
                    leas      2,S                 Eat stack
                    std       2,S                 Save length
                    beq       FORKPRC4            If 0, just put a CR in it
                    addd      #-1                 Dec length by 1 (space on end?)
                    ldx       #PARMSBFR           Point to start of command line
                    leax      D,X                 Point to end of it
                    ldd       #CR*256             Append a CR/NUL to it
                    std       ,X
                    bra       FORKPRC5

FORKPRC4            ldd       #CR*256             Nothing in command buffer, just put CR/NUL in
                    std       PARMSBFR,Y
FORKPRC5            ldd       2,S                 Get length of command line to run
                    addd      #1                  bump up by 1 & save it again
                    std       2,S
                    pshs      U
                    lbsr      NEWSTDIO            Change I/O paths (all 3) to window path in current GD.* ptr
                    std       ,S++                Were we successful?
                    beq       FORKPRC7            No, skip ahead
                    clra                          Select std IN path as current window (in other words,
                    clrb                          select GD.* path as new window
                    pshs      d
                    lbsr      SELECT
                    ldd       GD.MEMSZ,U          Get memory size required
                    std       ,S                  Save it
                    clra
                    clrb
                    pshs      d
                    pshs      d
                    ldx       #PARMSBFR           Point to parms buffer
                    ldd       8,S
                    pshs      d,X
                    ldd       16,S
                    pshs      d
                    lbsr      F.FORK              Fork the program
                    std       16,S
                    ble       FORKPR51
                    leas      12,S
                    bra       FORKPRC6

FORKPR51            ldd       20,S
                    bne       FORKPR52
                    leas      12,S
                    bra       FORKPRC7

FORKPR52            std       ,S
                    lbsr      F.FORK
                    leas      12,S
                    std       4,S
                    ble       FORKPRC7

FORKPRC6            ldd       4,S
                    std       GD.PRCID,U
                    ldd       #1
                    std       ,S

* Couldn't change std paths to new window
FORKPRC7            ldd       GD.MNAME,U          Get ptr to module name
                    pshs      d                   Save it
                    lbsr      F.UNLOAD            Unload the module
                    leas      2,S                 Eat stack
                    ldd       ,S                  ???
                    bne       FORKPRC8            But don't print FORK ERROR if it is<>0
                    ldd       ERRNO,Y             Get error code
                    std       GD.STATS,U          Save as last status for forked program
                    leax      <FORKERR,PC         Report FORK error in overlay window
                    pshs      X,U
                    lbsr      ERRPRINT
                    leas      4,S
FORKPRC8            clr       PARMSBFR,Y          NUL the command buffer
                    pshs      U
                    lbsr      RESTDIO             Restore std I/O paths to normal GSHELL window path
                    leas      2,S
                    ldd       ,S                  Get ???
BADLANGX            leas      12,S                Eat stack & return
                    puls      U,PC

FORKERR             fcc       "Fork error - "
                    fcb       '",NUL

* Call F$Wait. If no child process, returns immediately.
* Otherwise, returns with child ID # & child exit status code)
* Stack usage (from -6,s):
* 0,s = ???
* 2,s = Child process ID #
* 4,s = Child process signal code
* NOTE: IF child is ABORTED (CTRL-E), GSHELL's keyboard buffer is cleared.
*  IF child is INTERRUPTED, GSHELL's keyboard buffer is left intact.
HNDLWAIT            pshs      U
                    leas      -6,S                Temp stack
                    clra                          Default child status code to 0
                    clrb
                    std       4,S
HNDLWAI1            leax      4,S                 Point to temp ID/exit status
                    pshs      X                   Save ptr for subroutine call
                    lbsr      F.WAIT              NOTE: ONLY CALLED FROM HERE! EMBED (6809 &6309)
                    leas      2,S                 Eat temp X ptr
                    std       2,S                 Save child process' ID #
                    beq       HNDLWAI2            None, eat temp stack & return
                    cmpd      #-1                 Error from F$Wait?
                    beq       HNDLWA10            Yes, return with exit signal=0 (no signal)
                    ldd       RECDSGNL            Did get child signal; try local signal
                    beq       HNDLWAI3            None, process child signal
HNDLWAI2            ldd       #S$WAKE             Exit with WAKE signal (flag to redo signal loop)
                    bra       HNDLWA12

* Child process has sent us a signal
HNDLWAI3            ldd       2,S                 Get child process ID #
                    pshs      d                   Save on stack (silly, unless destructive)
                    bsr       GTPRDESC            Get our process descriptor table entry ptr
                    tfr       D,U                 Move to U
                    stu       ,S++                Legit?
                    beq       HNDLWA11            No, if signal=0, try WAIT again, else exit
                    ldd       4,S                 Get child's signal code
                    std       ERRNO,Y             Save as error
                    std       GD.STATS,U          Save as last status for forked program
                    beq       HNDLWAI8            If child's signal was 0, skip ahead
                    cmpb      #S$ABORT            Abort signal?
                    beq       HNDLWAI4            yes, go handle
                    cmpb      #S$INTRPT           Interrupt signal?
                    bne       HNDLWAI7            Yes, go handle
* Child ABORTed (CTRL-E)
HNDLWAI4            clrb                          D=0
                    pshs      d
                    ldd       GD.WPATH,U          Get programs window path
                    pshs      d
                    lbsr      PAUSECHO            Shut pause & echo off for that window
                    leas      4,S                 Eat temp stack
                    bra       HNDLWAI6

* Flush out keyboard buffer for main GSHELL window
HNDLWAI5            pshs      d                   Save # of chars in main window buffer
                    ldx       #MULTIBFR           Point to temp buffer area
                    ldd       WNDWPATH            Get window path for GSHELL
                    pshs      d,X
                    lbsr      I.READ              Read (eat/flush) all chars in keyboard buffer for GSHELL
                    leas      6,S                 Eat temp stack
HNDLWAI6            ldd       WNDWPATH            Get path to GSHELL window
                    pshs      d
                    lbsr      GT.READY            Check if any data ready in keyboard buffer
                    leas      2,S
                    std       ,S                  Save # chars waiting
                    bgt       HNDLWAI5            There are some, process
* Child INTERRUPTed (CTRL-C)
HNDLWAI7            leax      <PROCERR,PC         Point to 'process error' msg
                    pshs      X,U
                    lbsr      ERRPRINT            Print error to screen
                    leas      4,S
HNDLWAI8            ldd       GD.DW.OW,U          Child running on overlay window in main GSHELL scrn?
                    cmpd      #1
                    beq       HNDLWAI9            Yes, Skip ahead
                    pshs      U                   No, save ptr to Process dsc. entry
                    lbsr      KILPDESC            Remove process descriptor out of table, kill device window
                    leas      2,S
HNDLWAI9            cmpu      10,S                Current process desc. entry ptr same as ???
                    bne       HNDLWA11
HNDLWA10            clra                          Return with D=0 (no signal)
                    clrb
                    bra       HNDLWA12

* If signal received not for any child of ours (done directly from GSHELL)
*   ,exit with D=0, else redo WAIT and try again (could this be 'infinite'
* loop bug where sometimes just auto-follow mouse works, but nothing else?
HNDLWA11            ldd       4,S                 Get child's signal code
                    lbeq      HNDLWAI1            If none, redo WAIT call & try again
HNDLWA12            leas      6,S                 Eat temp stack & return
                    puls      U,PC

PROCERR             fcc       "Process error - "
                    fcb       '",NUL

* Exit: D=0 if no child processes in table
*       D=ptr to process descriptor table entry
GTPRDESC            ldx       PTBLSPTR            Get ptr to start of process descriptor table
                    beq       GTPRDES3            None, exit
GTPRDES1            ldd       GD.PRCID,X          Get process id # for current table entry
                    cmpd      2,S                 This the one we are looking for?
                    bne       GTPRDES2            No, skip to next one
                    tfr       X,D                 Exit with D=process table entry ptr
                    rts

GTPRDES2            ldx       GD.LINK,X           Get ptr to next process in table
                    bne       GTPRDES1            got one, check it
GTPRDES3            clra                          End of table, exit with D=0
                    clrb
                    rts

* Add a string prefix to the current string
* Entry: 0-1,s = RTS address
*        2-3,s = String that we are inserting in front of
STPREFIX            pshs      U                   Preserve U
                    ldd       4,S                 Get ptr to string we are inserting in front of
                    pshs      d,X,Y               Save it & regs
                    lbsr      STRLEN              Get length of string we are inserting in front of
* NOTE: WHEN TFM'ING BELOW, DELETE ADDD #1
                    addd      #1
                    std       4,S                 Save length of string+1
                    ldu       #PARMSBFR           Point to temp buffer
                    stu       ,S                  Save ptr
                    lbsr      STRLEN              Get length of string in temp buffer
                    leas      2,S                 Eat stack
* WHEN TFMING BELOW, DELETE INCB
                    incb                          Bump length up by 1
* 6309
* tfr d,w  Save length
* addr w,u Point to end of string+1
* DELETE LDA 1,S BELOW

                    std       ,S                  Save it
                    leau      D,U                 Point to end of string+1
                    tfr       U,X                 Save ptr in X
                    ldd       2,S                 Get length of string we are inserting in front of
                    leau      D,U                 Calculate end ptr of two strings together
                    lda       1,S                 Get # of bytes to move (size of inserted string)
                    bra       STPREFX2

* 6309 - DELETE ABOVE BRA STPREFX2
* NOTE THAT DELETING INCB & ADDD #1 ABOVE IS BECAUSE TFM IS _POST_ DECREMENT,
*   WHILE ORIGINAL ,-X IS _PRE_DECREMENT
* NOTE: 6309 ONLY: CHANGE TO TFM
*  tfm x-,u-
* Copy string we are inserting in front of further ahead in buffer to make
*   room for inserted string
STPREFX1            ldb       ,-X                 Get char from 1st string
                    stb       ,-U                 Append in 2nd
STPREFX2            deca                          Dec # bytes left
                    bge       STPREFX1            Still some left continue copying
                    ldx       8,S                 Get ptr to another string
                    ldu       #PARMSBFR           Point to start of temp buffer
                    bra       STPREFX4

STPREFX3            ldb       ,X+                 Copy char from string to temp buffer
                    stb       ,U+
STPREFX4            ldb       ,X                  Get char from string
                    bne       STPREFX3            Not end of string, copy character
                    ldd       #SPACE              A=0, B=Space char
                    stb       ,U                  Add space char
                    leas      4,S                 Eat stack & return
                    puls      U,PC

* Change all 3 standard I/O paths to path pointed to by current program
*   table entry (GD.*) (or WNDWPATH if GD.WPATH is negative & there is no
*   ptr to a pathname in GD.INDVC)
* Entry: 0-1,s = RTS address
*        2-3,s = Ptr to current entry in GD.* table
NEWSTDIO            pshs      U
                    ldu       4,S                 Get GD.* ptr
                    lda       GD.WPATH+1,U        Get path # to window program is/will be running on.
                    bgt       NEWSTDI1            If positive value, skip ahead
                    lda       WNDWPATH+1          If negative, use GSHELL window path
NEWSTDI1            pshs      A                   Save new window path #
                    clra                          Close current input/output/error paths
                    os9       I$CLOSE
                    inca
                    os9       I$CLOSE
                    inca
                    os9       I$CLOSE
                    ldx       GD.INDVC,U          Get ptr to new window's path NAME
                    beq       NEWSTDI2            None, use path # on stack
                    lda       #READ.              There is a path name, OPEN a READ path to it
                    os9       I$OPEN              & use it's path # for new std i/o paths
                    bra       NEWSTDI3

NEWSTDI2            lda       ,S                  Get new window's path # from stack
                    os9       I$DUP               Duplicate new path as std in
NEWSTDI3            bcs       NEWSTDI4
                    lda       ,S                  and std out
                    os9       I$DUP
                    bcs       NEWSTDI4
                    lda       ,S                  and std err
                    os9       I$DUP
                    bcs       NEWSTDI4
                    puls      A                   eat copy of new path #
                    ldd       #1                  D=1 if new std i/o paths created successfully
                    puls      U,PC

NEWSTDI4            leas      1,S                 Eat stack
                    clra                          Exit with D=0 if could not create new paths
                    clrb
                    puls      U,PC

* Restore std I/O paths to normal GSHELL path
RESTDIO             clra                          Close std in/out/error paths
                    os9       I$CLOSE
                    inca
                    os9       I$CLOSE
                    inca
                    os9       I$CLOSE
                    lda       WNDWPATH+1          Duplicate normal GSHELL window paths to std i/o
                    os9       I$DUP
                    lda       WNDWPATH+1
                    os9       I$DUP
                    lda       WNDWPATH+1
                    os9       I$DUP
                    rts

EXTFITBL            pshs      U
                    ldd       4,S
                    pshs      d
                    lbsr      STRLEN
                    addd      #FL.SIZE+1
                    std       ,S
                    lbsr      MEMSPACE
                    leas      2,S
                    tfr       D,U
                    stu       -2,S
                    beq       EXTFITB1
                    leax      FL.SIZE,U
                    stx       FL.FNAME,U
                    ldd       4,S
                    pshs      d
                    pshs      X
                    lbsr      STRCPY
                    leas      4,S
                    inc       FILESCTR+1
                    bne       EXTFITB1
                    inc       FILESCTR
EXTFITB1            tfr       U,D
                    puls      U,PC

UPDTIPTR            ldd       2,S
                    pshs      d
                    bsr       EXTFITBL
                    std       ,S
                    beq       UPDTIPT1
                    std       [FTBLNEXT,Y]
                    tfr       D,X
                    clra
                    clrb
                    std       FL.LINK,X
                    std       FL.ICONO,X
                    lbsr      ICNXYSET
                    leax      FL.LINK,X
                    stx       FTBLNEXT
UPDTIPT1            puls      d,PC

ADDFICON            ldd       2,S
                    pshs      d
                    bsr       UPDTIPTR
                    std       ,S
                    beq       ADDFICO3
                    ldb       7,S
                    cmpb      #IC.AIF.F
                    beq       ADDFICO1
                    cmpb      #IC.F.XXX
                    bne       ADDFICO2
ADDFICO1            bsr       ISIT.XXX
ADDFICO2            ldx       ,S
                    stb       FL.ICONO,X
                    bsr       UPDTNSCR
ADDFICO3            puls      d,PC

UPDTNSCR            ldd       FILESCTR
                    subd      #1
                    pshs      d
                    ldd       MAXICONS
                    lbsr      CCDIV
                    std       NSCREENS
                    rts

ISIT.XXX            pshs      U
                    ldu       4,S
                    ldd       FL.FNAME,U
                    pshs      d
                    lbsr      FIND.XXX
                    std       ,S++
                    beq       ISITXXX1
                    pshs      d
                    pshs      U
                    lbsr      FILE.XXX
                    leas      4,S
                    std       -2,S
                    beq       ISITXXX1
                    puls      U,PC

ISITXXX1            incb
                    puls      U,PC

RPLFICON            pshs      U
                    ldd       6-2,S
                    pshs      d,X
                    bsr       SRCHFTBL
                    std       2,S
                    ldd       8+2,S
                    std       ,S
                    lbsr      EXTFITBL
                    tfr       D,U
                    ldd       #FL.FNAME
                    std       ,S
                    ldd       8,S
                    pshs      d
                    pshs      U
                    lbsr      STRNCPY
                    leas      6,S
                    ldx       6,S
                    cmpx      STRTICON
                    bne       RPLFICOX
                    stu       STRTICON
RPLFICOX            ldx       FL.LINK,X
                    bne       RPLFICO1
                    leax      FL.LINK,U
                    stx       FTBLNEXT
RPLFICO1            ldx       ,S
                    bne       RPLFICO2
                    stu       FTBLSPTR
                    bra       RPLFICO3

RPLFICO2            stu       FL.LINK,X
RPLFICO3            ldd       6,S
                    pshs      d
                    lbsr      FREE
                    ldd       FILESCTR
                    subd      #1                  NOTE: 6309 DECD
                    std       FILESCTR
                    bsr       UPDTNSCR
                    tfr       U,D
                    leas      4,S
                    puls      U,PC

RMVFICON            pshs      U
                    ldx       4,S
                    ldu       FL.LINK,X
                    pshs      X
                    bsr       SRCHFTBL
                    std       ,S
                    stu       -2,S
                    bne       RPLFICO1
                    ldd       ,S
                    bne       RMVFICO1
                    leax      <FTBLSPTR,Y
                    stx       FTBLNEXT
                    bra       RPLFICO1

RMVFICO1            addd      #FL.LINK
                    std       FTBLNEXT
                    bra       RPLFICO1

SRCHFTBL            clra
                    clrb
                    pshs      d
                    ldx       FTBLSPTR
SRCHFTB1            cmpx      4,S
                    bne       SRCHFTB2
                    puls      d,PC

SRCHFTB2            stx       ,S
                    ldx       FL.LINK,X
                    bne       SRCHFTB1
                    clra
                    clrb
                    rts

KILLFTBL            pshs      d,U
                    ldu       FTBLSPTR
                    bra       KILLFTB2

KILLFTB1            ldu       FL.LINK,U
                    lbsr      FREE
KILLFTB2            stu       ,S
                    bne       KILLFTB1
                    leax      <FTBLSPTR,Y
                    stu       ,X
                    stx       FTBLNEXT
                    puls      d,U,PC

* Update file icon table position entry, as well as next icon position on
* screen.
* Entry: 0-1,s = RTS address
*        2-3,s = Ptr to current file table (FL.*) entry
ICNXYSET            pshs      U
                    ldu       4,S                 Get ptr to current file table entry
                    ldd       NEXTXPOS            Get next X position for file icon on screen
                    std       FL.XSTRT,U          Save as X start for file table entry
                    addd      #24                 Add 24 pixels (Width of icon)
                    tst       WD48FLAG            Using wide 80 column screen?
                    beq       ICNXYSE2            No, skip ahead
                    addd      #24                 Yes, add another 24 pixels (48 pixels for wide)
ICNXYSE2            std       FL.XEND,U           Save as X end for file table entry
                    ldd       NEXTYPOS            Get next Y position
                    std       FL.YSTRT,U          Save as Y start for file table entry
                    addd      #24                 Add 24
                    std       FL.YEND,U           Save Y end for file table entry
                    ldd       NEXTXPOS            Get next X start pos again
                    addd      ICONCOLW            Add icon column width (including spacing)
                    std       NEXTXPOS            Save as new next X pos
                    pshs      d                   * NOTE: 6309 SUBR
                    ldd       PIXELSWD            Get GSHELL window width
                    subd      ,S++
                    cmpd      #24                 Is next icon going to be past right window edge?
                    bge       ICNXYSE1            No, skip ahead
                    ldd       STRTXPOS            Yes, reset next X pos to start X pos (left side)
                    std       NEXTXPOS
                    ldd       NEXTYPOS            Bump Y pos up too by icon row height
                    addd      ICONROWH
                    std       NEXTYPOS
                    cmpd      ICONYMAX            Are we passed the bottom of the GSHELL window too?
                    ble       ICNXYSE1            No, skip ahead
                    ldd       STRTYPOS            Yes, reset next Y pos as start Y pos (top side)
                    std       NEXTYPOS
ICNXYSE1            puls      U,PC

UPDFITBL            bsr       RSTXYPTR            Reset X/Y positions of next icon to upper left corner
                    ldx       FTBLSPTR            Get ptr to start of file table
                    bra       UPDFITB2            Update table icon positions again

UPDFITB1            pshs      X                   Save file table entry ptr
                    bsr       ICNXYSET            Set X/Y positions of file icon
                    leas      2,S
                    ldx       FL.LINK,X           Get ptr to next file table entry
UPDFITB2            bne       UPDFITB1            There is one, go fix it's coords
                    rts                           Done them all, return

* Reset next positions for icons to upper left corner
RSTXYPTR            ldd       STRTXPOS
                    std       NEXTXPOS
                    ldd       STRTYPOS
                    std       NEXTYPOS
                    rts

* FILE menu - Sort option
FLSORT              lbsr      SUREBOX6
                    std       -2,S
                    beq       FLSORT1
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    pshs      d
                    pshs      d                   No parameter for program
                    pshs      d                   No overlay window
                    leax      <GSORTNAM,PC        Save primary module name ptr
                    pshs      X
                    lbsr      EXECPRGM            Execute GSORT without overlay window (does it's own)
                    leas      8,S
                    lbsr      DONEWDIR
FLSORT1             lbra      FILSEXIT

GSORTNAM            fcc       "gsort"
                    fcb       NUL

DELDIRNM            fcc       "deldir"
                    fcb       NUL

CANTDELT            fcc       "Can't delete "
                    fcb       '",NUL

* FILE menu, Delete option (Trash entry a little further in. NOTE: Use this
*  as the basis for the PRINT option)
FLDELETE            lbsr      SUREBOX6            Ask user if he/she is sure they want to delete
                    std       -2,S
                    lbeq      FILSEXIT            Said no, don't delete
FLTRASH             ldb       FL.ICONO,U          Get icon buffer number for file to delete
                    cmpb      #IC.FOLDR           Is it a folder (directory)?
                    bne       NOTADIR             No, skip ahead
                    clra                          Call DELDIR to delete a directory
                    clrb
                    pshs      d
                    ldx       FL.FNAME,U
                    incb
                    pshs      d,X
                    leax      <DELDIRNM,PC
                    pshs      X
                    lbsr      EXECPRGM
                    leas      8,S
FLDELET1            std       4,S
                    bra       FLDELET3

* Not a dir, delete a normal file
NOTADIR             pshs      U
                    lbsr      GETFLPTR            Get ptr to filename
                    std       ,S
                    lbsr      I.DELETE
                    leas      2,S
                    std       4,S
                    beq       FLDELET3
                    ldd       ERRNO,Y
                    cmpb      #E$PNNF
                    bne       FLDELET2
                    clra
                    clrb
                    bra       FLDELET1

FLDELET2            ldx       ERRNO,Y
                    ldd       FL.FNAME,U
                    pshs      d,X
                    leax      <CANTDELT,PC
                    pshs      X
                    lbsr      BUILDMSG
                    leas      6,S
FLDELET3            ldd       4,S
                    bne       FILSEXIT
                    pshs      U
                    lbsr      RMVFICON
                    leas      2,S
                    clra
                    clrb
                    std       SELECTED
                    lbsr      UPDFITBL
                    ldd       FL.ICONO,U
                    cmpa      #IC.AIF.F
                    bne       FLDELET9
                    ldx       FTBLSPTR
                    beq       FLDELET6
                    lda       #IC.TEXT
FLDELET4            cmpb      FL.AIFNO,X
                    bne       FLDELET5
                    clr       FL.AIFNO,X
                    sta       FL.ICONO,X
FLDELET5            ldx       FL.LINK,X
                    bne       FLDELET4
FLDELET6            ldx       IDSCSPTR
FLDELET7            cmpb      ID.NUMBR+1,X
                    bne       FLDELET8
                    ldx       ID.XXXPT,X
                    clr       ,X
                    bra       FLDELET9

FLDELET8            ldx       ID.LINK,X
                    bne       FLDELET7
FLDELET9
FLCOPYEX            lbsr      DRAWSCRN
                    bra       FILSEXIT

* FILE menu, Quit option
FLQUIT              lbsr      SUREQUI3            Ask user if they are sure
                    bra       FILSEXIT

* FILES menu
FILESLCT            pshs      U
                    leas      -8,S
                    ldu       SELECTED            Get ptr to icon table entry currently selected
                    ldd       12,S                Get FILES menu item #
                    decb
                    beq       FLOPEN
                    decb
                    lbeq      FLLIST
                    decb
                    lbeq      FLCOPY
                    decb
                    lbeq      FLSTAT
                    decb
                    lbeq      FLPRINT
                    decb
                    lbeq      FLRENAME
                    decb
                    lbeq      FLDELETE
                    decb
                    lbeq      FLSORT
                    decb
                    beq       FLQUIT
                    decb
                    lbeq      FLTRASH
FILSEXIT            leas      8,S
                    puls      U,PC

* File menu - OPEN option
FLOPEN              ldb       FL.ICONO,U          Get icon type
                    cmpb      #IC.AIF.F           Is it a one shot AIF file?
                    beq       FLOPNAIF            Yes, open as an AIF file
                    cmpb      #IC.FOLDR           Is it a folder/directory?
                    beq       FLOPFLDR            Yes, switch to that sub-directory
                    cmpb      #IC.F.XXX           Is it a file that matches a previous AIF extension
                    bne       FLOPRGRM            No, treat as an executable
                    pshs      U                   Save file info ptr
                    lbsr      EXEC.XXX            Do the AIF match thing
                    bra       FLEXHOOK

* File menu - OPEN for a one-shot AIF file
FLOPNAIF            pshs      U                   Save file info ptr
                    lbsr      EXECAIF             Execute using AIF stuff
                    bra       FLEXHOOK

* File menu - OPEN for a folder (directory)
FLOPFLDR            ldd       FL.FNAME,U          Get ptr to directory name
                    pshs      d
                    lbsr      OPENFLDR            Change to sub-directory
FLEXHOOK            leas      2,S                 Eat temp stack & exit
                    bra       FILSEXIT

FLOPRGRM            ldd       FL.FNAME,U          Get ptr to filename to execute
                    pshs      d
                    leax      <SLASH,PC           Point to a slash
                    pshs      X
                    ldx       #DDIRNAME           Point to current full path name
                    pshs      X
                    ldx       #MULTIBFR           Place to store path & filename
                    pshs      X
                    lbsr      STRCPY              Copy pathname to temp buffer
                    leas      4,S
                    pshs      d
                    lbsr      STRCAT              Add slash (NOTE: DO MANUALLY!)
                    leas      4,S
                    pshs      d
                    lbsr      STRCAT              Add filename of program to execute
                    leas      4,S
                    ldd       FL.FNAME,U          Point to filename (for get params prompt)
                    pshs      d
                    lbsr      GETPARMS            Prompt & get any params needed from user
                    leas      2,S
                    std       2,S
                    ldd       #1                  We want overlay window to run program in flag
                    pshs      d
                    ldx       4,S
                    pshs      d,X
                    ldx       #MULTIBFR           Point to new filename path
FLEXEC              pshs      X
                    lbsr      EXECPRGM            Fork that program in an overlay window
                    leas      8,S
FILSEXT2            bra       FILSEXIT

SLASH               fcc       "/"
                    fcb       NUL

* File menu - LIST option
FLLIST              ldd       #1
                    pshs      d
                    pshs      U
                    lbsr      GETFLPTR            Get ptr to filename we want to list
                    std       ,S                  Save it
                    ldd       #1                  Flag that we want to run LIST in an overlay window
                    pshs      d
                    ldx       #LISTNAM            Point to 'LIST '
                    bra       FLEXEC

* File menu - COPY option
FLCOPY              ldx       #NEWNMSG            Point to 'new name:'
                    pshs      X
                    lbsr      INPTSCRN            Prompt for destination path for copy
                    std       4,S
                    beq       FLEXHOOK            User just hit <ENTER>, abort copy
                    std       ,S                  Save ptr to string we are inserting in front of
                    lbsr      STPREFIX            Insert original filename to copy (?)
                    clra
                    clrb
                    std       ,S
                    pshs      U
                    lbsr      GETFLPTR            Get ptr to filename we want to copy
                    std       ,S
                    clra                          No overlay window for COPY command
                    clrb
                    pshs      d
                    leax      <COPYNAME,PC
                    pshs      X
                    lbsr      EXECPRGM            Execute COPY program
                    leas      8,S
                    std       -2,S
                    bne       FILSEXT2
                    ldd       2,S
                    pshs      d
                    lbsr      INOURDIR
                    leas      2,S
                    std       2,S
                    beq       FILSEXT2
                    ldb       FL.ICONO,U
                    sex
                    pshs      d
                    ldd       4,S
                    pshs      d
                    lbsr      ADDFICON
                    leas      4,S
                    lbra      FLCOPYEX

* File menu - FSTAT option
FLSTAT              ldd       #1
                    pshs      d
                    pshs      U
                    lbsr      GETFLPTR            Get ptr to filename we are FSTATing
                    std       ,S
                    ldd       #1                  Flag we want this in an overlay window
                    pshs      d
                    leax      <FSTATNAM,PC        Point to 'fstat'
                    lbra      FLEXEC

COPYNAME            fcc       "copy"
                    fcb       NUL

FSTATNAM            fcc       "fstat"
                    fcb       NUL

* File menu - PRINT option - NOTE: ADD PRINT ICON CALL TO HERE
FLPRINT             ldd       #1
                    pshs      d
                    pshs      U
                    bsr       GETFLPTR            Get ptr to file to print
                    std       ,S
                    ldd       #1                  We want this to run in an overlay window
                    pshs      d
                    ldx       #COCPRNM            Execute 'COCOPR' program
                    lbra      FLEXEC

* File menu - RENAME option - patch to not allow DIRSIG to trigger needlessly
FLRENAME            ldx       #NEWNMSG            Prompt user for new filename
                    pshs      X
                    lbsr      INPTSCRN
                    std       4,S                 Save ptr to new filename
                    beq       FLRENAM1            User hit <ENTER>, abort rename
                    std       ,S
                    lbsr      STPREFIX
                    clra
                    clrb
                    std       ,S
                    pshs      U
                    bsr       GETFLPTR            Get ptr to filename of original filename to rename
                    std       ,S
* If Dirup <>0, leave RECDSGNL/Dirup alone (another process has updated DIR)
* If Dirup=0, we want to wipe out RECDSGNL & Dirup right after Fork comes back
* before we exit this routine.
                    lda       Dirup               Any directory update signal?
                    sta       RenFlag             Save it (irregardless)
                    clra                          No overlay window for RENAME
                    clrb
                    pshs      d
                    leax      <RENAMENM,PC        Rename the file
                    pshs      X
                    lbsr      EXECPRGM
                    leas      8,S
                    std       -2,S
                    lbne      FILSEXIT
                    lda       RenFlag             Was their a dir update originally?
                    bne       SkipSigC            Yes, leave signal stuff alone
                    sta       Dirup               Clear queued dir update signal flag (rename triggered it)
                    sta       RECDSGNL+1          Clear signal copy as well
SkipSigC            pshs      U
                    lbsr      ERASFNAM            Erase the original filename from the screen
                    ldd       4,S
                    std       ,S
                    pshs      U
                    lbsr      RPLFICON            Update the file table entry for the new name
                    leas      4,S
                    std       SELECTED
                    pshs      d
                    lbsr      WRITFNAM            Write the new filename on the screen
FLRENAM1            lbra      FLEXHOOK

RENAMENM            fcc       "rename"
                    fcb       NUL

* Get ptr to filename
* Entry: 0-1,s = RTS address
*        2-3,s = Ptr to file table entry for current file
GETFLPTR            ldx       2,S                 Get ptr to file table entry
                    ldb       FL.ICONO,X          Get icon type
                    cmpb      #IC.AIF.F           Is it a one shot AIF type?
                    bne       GETFLPT1            No, skip ahead
                    pshs      X                   Save ptr to file table entry
                    bsr       FPTR.XXX            Generate AIF.xxx filename, return with ptr to it
                    leas      2,S
                    rts

* Non AIF one-shot
GETFLPT1            ldd       FL.FNAME,X          Get filename ptr & return
                    rts

* AIF one shot (need name of AIF itself, not program referenced in it)
FPTR.XXX            pshs      U
                    leau      AIF.NAME,PC         Point to 'aif'
                    ldx       #AIFNMBFR           Point to buffer to build AIF.xxx filename
                    pshs      X,U
                    lbsr      STRCPY              Copy 'aif' into buffer
                    leas      4,S
                    ldu       4,S
                    clra
                    ldb       FL.AIFNO,U          Get entry # into ID.* table
                    pshs      d
                    lbsr      FNDIDESC            Go find the right entry
                    tfr       D,U
                    std       ,S++
                    beq       FPTRXXX1            None, skip ahead
                    ldu       ID.XXXPT,U          Get ptr to ???
                    ldx       #AIFNMBFR           Point to AIF buffer again
                    pshs      X,U
                    lbsr      STRCAT              append the 3 letter AIF code
                    leas      4,S
FPTRXXX1            puls      U,PC                Return with ptr to AIF.xxx filename

INOURDIR            pshs      U
                    ldu       4,S
                    ldb       ,U
                    cmpb      #'/
                    bne       INOURDI1
                    pshs      U
                    bsr       TERMSLSH            Cut directory name off one dir. level earlier
                    std       ,S                  Save ptr to end of new path
                    ldx       #DDIRNAME
                    pshs      X,U
                    lbsr      STRCMP
                    leas      4,S
                    puls      X
                    std       -2,S
                    bne       INOURDI2
                    leax      1,X
                    tfr       X,D
                    bra       INOURDI4

INOURDI1            ldb       ,U+
                    beq       INOURDI3
                    cmpb      #'/
                    bne       INOURDI1
INOURDI2            clra
                    clrb
                    puls      U,PC

INOURDI3            ldd       4,S
INOURDI4            puls      U,PC

* Shorten string at [2,S] to end at the previous '/'
* Used to shorten directory paths by one directory level
* Exit: D=ptr to end of new pathname
TERMSLSH            ldx       2,S                 Get ptr to pathname
                    lbsr      STREND1             Get end of string ptr into D
TERMSLS1            ldb       ,-X                 Get previous char
                    cmpb      #'/                 Slash?
                    bne       TERMSLS1            No, keep looking
                    cmpx      2,S                 Yes, are we at the beginning of the path again?
                    beq       TERMSLS2            Yes, done
                    clrb                          Found previous dir, flag string end here
                    stb       ,X
TERMSLS2            tfr       X,D
                    rts

* FILE menu, Free option
DOFREE              ldd       #1                  Do in an overlay window
                    pshs      d
                    ldx       DEVICNOW            Get ptr to file entry for current device
                    ldx       FL.FNAME,X          Get ptr to device name
                    pshs      d,X
                    leax      <FREENAME,PC        Fork FREE command on that drive
                    bra       FORKHOOK

FREENAME            fcc       "free"
                    fcb       NUL

SORCDEVC            fcc       " Source device"
                    fcb       LF,NUL

DESTDEVC            fcc       " Dest. device"
                    fcb       LF,NUL

BACKUPNM            fcc       "backup"
                    fcb       NUL

SNAME               fcc       "s"
                    fcb       NUL

* - Backup command - NOTE: SHOULD WE CHANGE THIS TO USE BRUCE ISTED'S STREAM?
DOBACKUP            leax      <SORCDEVC,PC        Point to ' Source device'
                    pshs      X
                    lbsr      SLCTDEVC            Prompt user for source device to BACKUP
                    tfr       D,U
                    stu       ,S++
                    beq       DISKEXIT            User just hit <ENTER>, exit
                    leax      <DESTDEVC,PC        Prompt user for destination device to BACKUP
                    pshs      X
                    lbsr      SLCTDEVC
                    leas      2,S
                    std       2,S
                    beq       DISKEXIT            User just hit <ENTER>, exit
                    cmpu      2,S                 Same as source drive?
                    beq       SNGLDRIV            Yes, doing single drive backup
                    pshs      d
                    lbsr      STPREFIX            Append
                    leas      2,S
                    clra                          No overlay window (since will be automatic)
                    clrb
                    bra       TWODRIVE

* Single drive backup
SNGLDRIV            ldd       #1                  Need overlay window for disk swap prompts
TWODRIVE            std       ,S
                    pshs      U
                    lbsr      STPREFIX
                    ldd       #1
                    std       ,S
                    ldd       2,S
                    beq       TWODRIV1
                    leax      <SNAME,PC
                    tfr       X,D
TWODRIV1            pshs      d
                    ldd       #1
                    pshs      d
                    leax      <BACKUPNM,PC
FORKHOOK            pshs      X
                    lbsr      EXECPRGM
                    leas      8,S
                    bra       DISKEXIT

DOSTEXEC            lbsr      NOMOUSE             ++X25
                    lbsr      STEXCDVC
                    bra       DISKEXIT

DOSETDVC            lbsr      NOMOUSE             ++X25
                    lbsr      FIXDRTBL
                    lbsr      CHGDEVCS
                    lbsr      UPDTDEVC
                    bra       DISKEXIT

* DISK MENU
DISKSLCT            pshs      U
                    leas      -4,S
                    ldd       8,S
                    decb
                    lbeq      DOFREE              Free
                    decb
                    beq       DONWFLDR            Create new folder (directory)
                    decb
                    beq       DOFORMAT            Format disk
                    decb
                    lbeq      DOBACKUP            Backup disk
                    decb
                    beq       DOSTEXEC            Set execution directory
                    decb
                    beq       DOSETDVC            Set data directory (drive)
DISKEXIT            leas      4,S
                    lbsr      MOUSENOW            Turn mouse back on
                    puls      U,PC

DONWFLDR            lbsr      NOMOUSE             Turn mouse off
                    leax      <FOLDRNAM,PC        Ask for new folder name
                    pshs      X
                    lbsr      INPTSCRN
                    tfr       D,U
                    std       ,S++
                    beq       DISKEXIT
                    ldb       #PEXEC.+PREAD.+EXEC.+UPDAT.
                    pshs      d
                    pshs      U
                    lbsr      I.MAKDIR
                    leas      4,S
                    tstb
                    bne       DONWFLD1
                    pshs      U
                    lbsr      INOURDIR
                    tfr       D,U
                    stu       ,S++
                    beq       DISKEXIT
                    ldb       #IC.FOLDR
                    pshs      d
                    pshs      U
                    lbsr      ADDFICON
                    leas      4,S
                    lbsr      DRAWSCRN
                    bra       DISKEXIT

DONWFLD1            ldd       ERRNO,Y
                    pshs      d
                    leax      <CANTMAKE,PC
                    pshs      X,U
                    lbsr      BUILDMSG
                    leas      6,S
                    bra       DISKEXIT

DOFORMAT            leax      <FMTDEVIC,PC
                    pshs      X
                    bsr       SLCTDEVC
                    tfr       D,U
                    stu       ,S++
                    beq       DISKEXIT
                    lbsr      SUREBOX5
                    tstb
                    beq       DISKEXIT
                    ldd       #1
                    pshs      d
                    pshs      d,U
                    leax      <FORMATNM,PC
                    lbra      FORKHOOK

FOLDRNAM            fcc       "Folder name:      "
                    fcb       NUL

CANTMAKE            fcc       "Can't make "
                    fcb       '",NUL

FMTDEVIC            fcc       " Format device"
                    fcb       LF,NUL

FORMATNM            fcc       "format"
                    fcb       NUL

* Select a new drive
SLCTDEVC            pshs      U
                    lbsr      NOMOUSE             Shut the mouse off
                    ldx       #MOUSPCKT
                    ldd       #8
                    std       BXOFFSET
                    clrb
                    pshs      d,X
                    ldb       #3
                    pshs      d,X
                    decb
                    pshs      d
                    ldx       #10
                    ldd       16-2,S
                    pshs      d,X
                    lbsr      STRLEN
                    addd      #2
                    std       ,S
                    clrb
                    pshs      d
                    ldb       #10
                    pshs      d
                    ldx       #1
                    ldd       WNDWPATH
                    pshs      d,X
                    lbsr      OWSET
                    ldd       #WT.DBOX            Double box overlay window
                    std       2,S
                    lbsr      ST.WNSET
                    ldd       10+16,S
                    std       ,S
                    lbsr      WRLNWCR
                    leas      2+14,S
                    ldd       #16
                    std       ,S
                    ldu       #DRIVETBL
                    bra       SLCTDEV2

SLCTDEV1            ldd       FL.FNAME,U
                    pshs      d
                    ldx       #DNAMBUFR
                    pshs      X
                    lbsr      STRCPY
                    clr       DNAMBUFR+11,Y
                    leax      FOURSPAC,PC
                    stx       ,S
                    lbsr      WTSTRLEN
                    ldx       #DNAMBUFR
                    stx       ,S
                    lbsr      WRLNWCR
                    ldd       4,S
                    std       2,S
                    ldd       #8
                    std       ,S
                    lbsr      DRAWABOX
                    leas      4,S
                    ldd       ,S
                    addd      #8
                    std       ,S
                    ldu       FL.LINK,U
SLCTDEV2            stu       -2,S
                    bne       SLCTDEV1
                    stu       RECDSGNL
                    ldd       WNDWPATH
                    pshs      d,X
                    lbsr      ST.RELEA
                    lbsr      MOUSENOW
                    ldd       #MOUSIGNL
                    std       2,S
                    lbsr      ST.MSSIG
                    leas      4,S
                    ldx       RECDSGNL            Get signal
                    bne       SLCTDEV3            Got one, process
                    os9       F$SLEEP             Sleep for remainder of tick
SLCTDEV3            ldd       RECDSGNL
                    cmpb      #MOUSIGNL
                    bne       SLCTDEV6
                    ldx       4,S
                    ldd       WNDWPATH
                    pshs      d,X
                    lbsr      GT.MOUSE
                    leas      4,S
                    ldd       #16
                    std       ,S
                    ldu       #DRIVETBL
                    bra       SLCTDEV5

SLCTDEV4            pshs      d
                    ldx       #8
                    ldd       8-2,S
                    pshs      d,X
                    lbsr      TESTDBOX
                    leas      6,S
                    std       2,S
                    bne       SLCTDEV6
                    ldd       ,S
                    addd      #8
                    std       ,S
                    ldu       FL.LINK,U
SLCTDEV5            stu       -2,S
                    bne       SLCTDEV4
SLCTDEV6            ldd       WNDWPATH
                    pshs      d
                    lbsr      OWEND
                    leas      2,S
                    lbsr      MOUSENOW
                    ldd       2,S
                    beq       SLCTDEV7
                    ldd       FL.FNAME,U
                    bra       SLCTDEVX

SLCTDEV7            clra
                    clrb
                    bra       SLCTDEVX

STEXCDVC            pshs      U
                    ldd       #3
                    pshs      d
                    leax      <SETEXEC,PC
                    ldd       WNDWPATH
                    pshs      d,X
                    lbsr      OLAYGNBK
                    lbsr      CURSORON
                    leax      <PREVIOUS,PC
                    stx       ,S
                    lbsr      WTSTRLEN
                    ldx       #XDIRNAME
                    stx       ,S
                    lbsr      WRLNWCR
                    leax      <NEW.MSG,PC
                    stx       ,S
                    lbsr      WTSTRLEN
                    lbsr      INPUTCHK
                    leas      2+4,S
                    tfr       D,U
                    stu       -2,S
                    beq       STEXCDV3
                    ldb       ,U
                    beq       STEXCDV3
                    pshs      U
                    lbsr      CHGXDIR
                    std       ,S++
                    bne       STEXCDV1
                    ldx       #XDIRNAME
                    pshs      X,U
                    lbsr      STRCPY
                    leas      4,S
                    bra       STEXCDV3

STEXCDV1            lbsr      KILLOLAY
                    ldd       ERRNO,Y
                    pshs      D
                    leax      <CANTOPEN,PC
                    pshs      X,U
                    lbsr      BUILDMSG
SLCTDEVX            leas      6,S
                    puls      U,PC

STEXCDV3            lbsr      KILLOLAY
                    puls      U,PC

SETEXEC             fcc       " Set execution folder "
                    fcb       NUL

PREVIOUS            fcb       LF
                    fcc       "Prev: "
                    fcb       NUL

NEW.MSG             fcc       "New:  "
                    fcb       NUL

CANTOPEN            fcc       "Can't open "
                    fcb       '",NUL

SUREQUI3            lbsr      TESTQUIT
                    bne       SUREQUI2
                    lbsr      SUREBOX8
                    bra       SUREQUI4

SUREQUIT            lbsr      TESTQUIT
                    bne       SUREQUI2
                    lbsr      SUREBOX7
SUREQUI4            std       -2,S
                    beq       SUREQUI2
                    ldd       #-1
                    pshs      D
                    lbsr      TRYQUIT
                    std       ,S++
                    bne       SUREQUI2
                    os9       F$ID
                    ldx       #DIRBUFER
                    os9       F$GPRDSC
                    tst       1,X
                    bne       SUREQUI1
                    lds       #$FF
                    leax      <EXITSHEL,PC        Point to SHELL
                    leau      <IEQUALS,PC         Point to 'i=/1'
                    ldy       #PARMSIZE
* NOTE: WE SHOULD CHANGE SO THAT GSHELL RECORDS THE ORIGINAL WINDOW TYPE, AND
*  RESTORES IT AS WELL. IT SHOULD ALSO RESET PAUSE PROPERLY
                    ldd       #$0100              Chain to regular SHELL
                    os9       F$CHAIN

SUREQUI1            pshs      D
                    lbsr      EXIT
SUREQUI2            rts

EXITSHEL            fcc       "shell"
                    fcb       CR

IEQUALS             fcc       "i=/1"
                    fcb       CR

PARMSIZE            equ       *-IEQUALS

* Entry: 0-1,s = RTS address
*        2-3,s = Ptr to mouse packet
TESTDBOX            pshs      U
                    ldu       4,S                 Get ptr to mouse packet
                    ldx       PT.WRX,U            Get
                    ldd       PT.WRY,U
                    pshs      d,X
                    ldd       10,S
                    cmpd      2,S
                    bge       TESTDBO1
                    addd      BXOFFSET
                    cmpd      2,S
                    blt       TESTDBO1
                    ldd       12,S
                    cmpd      ,S
                    bge       TESTDBO1
                    addd      #8
                    cmpd      ,S
                    blt       TESTDBO1
                    ldd       12,S
                    addd      #2
                    pshs      d
                    ldd       12,S
                    addd      #2
                    pshs      d
                    ldd       WNDWPATH
                    pshs      d
                    lbsr      SETDPTR
                    lbsr      FFILL
                    ldx       #10                 Sleep for 10 ticks
                    os9       F$SLEEP
                    leas      6,S
                    ldb       #1
                    bra       TESTDBO2

TESTDBO1            clrb
TESTDBO2            clra
                    leas      4,S
                    puls      U,PC

VIEWSLCT            ldb       3,S                 Get menu item #
                    beq       VIEWEXIT            None selected, exit
                    cmpb      #3                  Higher than the 3 we ignore (HOW WOULD THIS HAPPEN?)
                    bhi       VIEWEXIT
                    addb      #5                  Adjust to match OS9 window types
                    cmpb      DEFWTYPE+1          Same as current type?
                    beq       VIEWEXIT            Yes, don't do anything
                    stb       DEFWTYPE+1          Save new type
                    stb       WIPED               Flag that we have to redo dir bar
                    bsr       SETVIEW             Do changes to the VIEW menu for the new type
                    lbsr      SETHLRES            Change current GSHELL window to new type
VIEWEXIT            rts

* Update VIEW menu options
SETVIEW             ldb       #1
                    ldx       #ITM.LRES+MI.ENBL
                    stb       ,X
                    stb       MI.SIZ,X
                    stb       MI.SIZ*2,X
                    ldb       DEFWTYPE+1
                    subb      #5
SETVIEW1            decb
                    beq       SETVIEW2
                    leax      MI.SIZ,X
                    bra       SETVIEW1

SETVIEW2            clr       ,X
                    rts

* Select off of the TANDY menu
* Entry: 0-1,s = RTS parameter
*        2-3,s = Menu item # selected
TNDYSLCT
                    ifne      H6309
                    clrd                          Put 4 zero bytes on stack
                    else
                    clra
                    clrb
                    endc
                    pshs      D
                    pshs      D
                    ldb       7,S                 Get 1 byte version of menu item selected
                    decb
                    beq       SELCALC             1=Calculator
                    decb
                    beq       SELCLOCK            2=Clock
                    decb
                    beq       SELCAL              3=Calender
                    decb
                    beq       SELCNTRL            4=Control Panel
                    decb
                    beq       SELPRNTR            5=Printer control panel
                    decb
                    beq       SELPORT             6=Serial port control panel
                    decb
                    beq       SELHELP             7=Help command
                    decb
                    bne       TNDYEXIT            9 or greater, exit Tandy menu
                    incb                          Save ???
                    stb       1,S
                    ldb       #IC.SHELL           Execute resizable window SHELL command
                    ldx       #SHELLNAM           Point to word "shell" with NUL
                    bra       TNDYEXEC            Go execute it

* Clock from Tandy menu selected
SELCLOCK            ldb       #IC.GCLOK           Clock forked process ID #
                    ldx       #GCLOCKNM           Point to name of clock program
                    bra       TNDYEXEC            Go execute it

* Calendar from Tandy menu selected
SELCAL              ldb       #IC.GCAL            Execute GCalendar
                    ldx       #GCALNAM
                    bra       TNDYEXEC

* Control panel selected
SELCNTRL            ldx       #CONTRLNM
                    bra       TNDYEXC1

* Printer panel selected
SELPRNTR            ldx       #GPRINTNM
                    bra       TNDYEXC1

* Serial ports panel selected
SELPORT             ldx       #GPORTNAM
TNDYEXC1            pshs      X                   Save ptr to program name to fork
                    lbsr      EXCOPOPR
                    leas      2,S
                    bra       TNDYEXIT

SELHELP             incb
                    pshs      D
                    ldx       SELECTED
                    beq       SELHELP1
                    ldd       FL.FNAME,X
                    std       2,S
                    inc       5,S

SELHELP1            ldx       #HELPNAM
                    pshs      X
                    lbsr      EXECPRGM
                    leas      4,S
                    bra       TNDYEXIT

SELCALC             ldb       #IC.GCALC
                    ldx       #GCALCNAM

* Execute resizable window, call program
* Entry: B=IC.*  id number
*        X=Pointer to program to call (no parameters at this point)
TNDYEXEC            pshs      D                   Preserve id #
                    lbsr      FNDIDESC            Find Ptr to ID descriptor we are looking for
                    std       2+2,S               Save on stack
                    stx       ,S                  Save ptr to program name
                    bsr       EXCICOND            Go execute
                    leas      2,S                 Eat temp stack
TNDYEXIT            leas      4,S                 Eat rest of temp stack & return
                    rts

*Execute an IC.* program
* Entry: 0-1,s  RTS address
*        2-3,s  Ptr to name of program to be called
EXCICOND            pshs      U                   Preserve U
                    ldd       4,S                 Get ptr to program to be forked
                    pshs      D                   Add entry to our internal table of programs we have forked
                    lbsr      SETPDESC
                    std       ,S                  Save ptr to current descriptor entry
                    lbeq      EXCICON9            None (couldn't make), clear 1st byte of parms buffer/exit
                    tfr       D,U                 Move ptr to U
                    lbsr      LINKLOAD            Shut mouse off/Hourglass, link or load program in question
                    std       ,S++                Did we have an error?
                    lbeq      EXCICON8            Yes, kill our GD.* process link, window (if any), exit
                    tst       RAMSIZE             Check our RAM size
                    bne       EXCICON4            >128k, skip ahead
                    ldd       8,S                 128k
                    pshs      D
                    pshs      U
                    lbsr      ISCR128K            Do special 128k processing for new window
                    leas      4,S                 Eat stack
                    std       -2,S                Check if new window create successful
                    beq       EXCICON1            Yes, continue
                    bgt       EXCICON6            Screen type of 7 or 8, can't create in 128k
                    lbsr      SETHLRES            Reinit main window, then print 'can't create' error
                    bra       EXCICON6

EXCICON1            ldd       6,S                 ???
                    beq       EXCICON2
                    ldx       #WT.DBOX            Double box border
                    ldb       WNDWPATH+1          Window path
                    pshs      D,X                 Save for routine
                    lbsr      ST.WNSET            Set window to double box
                    leas      4,S                 Eat temp stack
                    std       -2,S                Error on Window Set?
                    bne       EXCICON3            Yes, reset window (?) and exit
EXCICON2            pshs      D                   Save regs
                    pshs      D
                    pshs      U                   ?? Save ptr to process to fork
                    lbsr      FORKWAIT            Go fork process
                    leas      6,S
EXCICON3            lbsr      SETHLRES            Change current window type & exit
                    bra       EXCICN10

* >128k RAM for forking IC.* program
EXCICON4            ldd       8,S
                    pshs      D
                    pshs      U
                    lbsr      ISCR512K            Go set up new window to fork program into
                    leas      4,S                 Eat temp stack
                    std       -2,S                Successful window create?
                    blt       EXCICN11            No, report error
                    ldd       6,S                 Get double box window flag
                    beq       EXCICON5            Not set, go straight to program fork
                    ldx       #WT.DBOX            Draw Double box window
                    ldd       GD.WPATH,U          Get path # to window program is/will be running on
                    pshs      D,X
                    lbsr      ST.WNSET
                    leas      4,S
                    std       -2,S
                    bne       EXCICON6            Couldn't create double box window, report error
EXCICON5            pshs      U                   Save ptr to GD.* variables
                    lbsr      FORKPROC            Fork program
                    std       ,S++
                    bne       EXCICN10            Successful fork, exit
EXCICON6            ldd       WNDWPATH            Print error on main window that we could not
                    pshs      D                   make a new window
                    lbsr      SELECT
                    leas      2,S
                    leax      <CANTWIND,PC
EXCICON7            pshs      X
                    lbsr      OLAYPRNT            Print message on overlay window (main screen)
                    ldd       GD.MNAME,U
                    std       ,S
                    lbsr      F.UNLOAD            Unload program we tried to fork
                    leas      2,S
EXCICON8            pshs      U
                    lbsr      KILPDESC            Yank entry out of current forked processes list
EXCICON9            leas      2,S
                    clr       PARMSBFR,Y          Flag parameters buffer as empty & return
EXCICN10            puls      U,PC

EXCICN11            cmpd      #-1
                    beq       EXCICON6            If error flag=-1,"can't create new window" error
                    leax      <EXECTERM,PC        "Execution terminated" error
                    bra       EXCICON7

EXECTERM            fcc       "Execution terminated"
                    fcb       NUL

* Execute program in pop up window on main GSHELL screen?
EXCOPOPR            pshs      U
                    ldd       4,S
                    pshs      D
                    lbsr      SETPDESC            Allocate internal process descriptor table entry
                    tfr       D,U
                    std       ,S
                    beq       EXCICON9
                    lbsr      LINKLOAD
                    std       ,S++
                    beq       EXCICON8
                    pshs      U
                    lbsr      OLAYWTBK
                    std       ,S++
                    beq       EXCICON8
                    ldx       #1
                    ldb       WNDWPATH+1
                    pshs      D,X
                    lbsr      SCALESW
                    leas      4,S
                    clra
                    clrb
                    pshs      D
                    incb
                    bra       EXECPRG3

CANTWIND            fcc       "Can't open new window"
                    fcb       NUL

* Execute program
* Entry: 0-1,s = RTS address
*        2-3,s = Ptr to primary module name
*        4-5,s = Flag 0=Make overlay window, <>0 = no overlay window
*        6-7,s = Ptr to parameter to send?
EXECPRGM            pshs      U
                    ldd       4,S                 Get ptr to primary module to execute
                    pshs      D
                    lbsr      SETPDESC            Allocate a process table entry
                    std       ,S
                    beq       EXECPRG5            If primary module ptr empty, exit
                    ldu       ,S                  Get ptr to primary module name
                    lbsr      LINKLOAD            Attempt to link or load it
                    std       ,S++                Eat stack
                    beq       EXECPRG4            Could not load/link, return process tbl mem & exit
                    ldd       6,S                 Get overlay window flag
                    beq       EXECPRG1            If flag=0, don't do overlay window
                    pshs      U
                    lbsr      OLAYBLWT
                    bsr       NOMOUSE
                    leas      2,S
EXECPRG1            ldd       8,S
                    beq       EXECPRG2
                    pshs      D
                    lbsr      STPREFIX
                    leas      2,S

EXECPRG2            ldd       10,S
                    pshs      D
                    ldd       8,S

EXECPRG3            pshs      d
                    pshs      U
                    bsr       FORKWAIT
                    pshs      d
                    bsr       MOUSENOW
                    puls      d
                    leas      6,S
                    lbsr      ResetPal            Reset palettes to GSHPAL in case CONTROL was called.
                    puls      U,PC

EXECPRG4            pshs      U
                    lbsr      KILPDESC            Kill the process table entry we had allocated
EXECPRG5            leas      2,S                 Exit with error flag set
                    ldd       #-1
                    puls      U,PC

NOMOUSE             ldd       WNDWPATH
                    pshs      d
                    lbsr      GCSETOFF
                    lbsr      MOUSOFF
                    puls      d,PC

MOUSENOW            ldd       WNDWPATH            Get path to gshell window
                    pshs      d                   Save it
                    lbsr      CRSRAROW            Set gfx cursor to arrow
                    lbsr      INITMOUS            Set mouse parms
                    puls      d,PC

FORKWAIT            pshs      U
                    ldu       4,S
                    pshs      U,PC
                    lbsr      FORKPROC            Fork process
                    std       ,S++                Successful?
                    beq       FORKWAI3            No, flag error & kill process descriptor entry
FORKWAI1            clra                          Succesful - clear received signal
                    clrb
                    std       RECDSGNL
                    pshs      U
                    lbsr      HNDLWAIT            Handle waiting while forked process runs
                    leas      2,S
                    ldd       GD.STATS,U          Get child's exit signal
                    cmpd      #-1                 If -1, try waiting again
                    beq       FORKWAI1
                    std       ,S                  Save signal
                    ldd       8,S
                    beq       FORKWAI5
                    ldd       10,S
                    beq       FORKWAI4
                    ldd       ,S
                    bne       FORKWAI4
                    ldx       #PRESSMSG           "Press any key" message
                    pshs      X
                    lbsr      WRLNWCR
                    leas      2,S
                    bsr       WAITPSIG            Wait for signal
                    bra       FORKWAI4

FORKWAI3            ldd       #-1                 Flag error
                    std       ,S
FORKWAI4            pshs      U
                    lbsr      KILPDESC            Kill process descriptor entry
                    leas      2,S
                    tst       RAMSIZE             Only 128k?
                    bne       FORKWAI5            No, exit
                    lbsr      INITSCRN            Yes, reinit screen before exiting
FORKWAI5            puls      d,U,PC

WAITPSIG            lbsr      SETSGNLS            Reset mouse & keyboard signals
                    ldd       RECDSGNL            Get current signal (could be dirupdate from SETSGNLS)
                    beq       WAITPSLP            None, sleep for one.
                    cmpb      #DIRSIG             Queued Dir update signal?
                    beq       WAITPSL2            Yes, sleep till next signal
                    bsr       FORKWTST            Check for key press, abort or interrupt signal
                    bne       WAITPSIG            Different signal, wait for a different one
                    bsr       FORKWSUB            Go read a key from current window
                    bra       WAITPSIG            Now wait for signal again

WAITPSL2            clrb
WAITPSLP            tfr       d,x                 Sleep till we receive a signal
                    os9       F$SLEEP
                    bsr       FORKWTST            Have signal, check it out
                    bne       WAITPRSX            Not key, abort or interrupt, skip ahead
                    bsr       FORKWSUB            If one of those, eat key from kybd buffer 1st
WAITPRSX            ldd       <WNDWPATH           Release signals for window
                    pshs      d
                    lbsr      ST.RELEA
                    leas      2,S
                    ifne      H6309
                    clrd                          Clear out signal received & return
                    else
                    clra
                    clrb
                    endc
                    std       <RECDSGNL
                    rts

FORKWSUB            clr       ,-S
                    ldd       WNDWPATH
                    pshs      d,DP
                    lbsr      PAUSECHO            Shut echo & pause off on current window
                    ldd       #1
                    std       ,S
                    ldd       WNDWPATH
                    leax      2,S
                    pshs      d,X
                    lbsr      I.READ              Read 1 char for current window
                    leas      8,S
                    rts

* Received signal - Set for BEQ if keyboard, interrupt or abort signal, else
*   BNE
FORKWTST            ldd       <RECDSGNL           Get last received signal
                    clr       <RECDSGNL           Clear out old signal code
                    clr       <RECDSGNL+1
                    cmpb      #KYBDSGNL           Key pressed?
                    beq       FORKWTEX            Yes, return
                    cmpb      #S$ABORT            Abort signal?
                    beq       FORKWTEX            Yes, return
                    cmpb      #S$INTRPT           Interrupt signal, return
FORKWTEX            rts

DRAWABOX            ldd       2,S
                    ldx       4,S
                    pshs      d,X
                    ldd       WNDWPATH
                    pshs      D
                    lbsr      SETDPTR
                    ldd       BXOFFSET
                    std       2,S
                    ldb       #8
                    std       4,S
                    lbsr      RBOX
                    leas      6,S
                    rts

*Change current window type (from VIEW menu)
SETHLRES            ldd       #PTR.SLP            Set mouse cursor to hourglass
                    pshs      d
                    ldx       #GRP.PTR
                    ldd       WNDWPATH
                    pshs      d,X
                    lbsr      GCSET
                    lbsr      ST.RELEA            Release any signals
                    lbsr      MOUSOFF
                    ldx       #30                 Sleep for 1/2 second
SETHLRE1            os9       F$SLEEP
                    leax      ,X                  Did we finish sleeping?
                    bne       SETHLRE1            No, continue sleeping
SETHLRE2            ldd       WNDWPATH            Get window path
                    std       ,S
                    lbsr      DWEND               End current window
                    leas      6,S
                    lbsr      SETWINDW            Set new window
                    lbsr      CNTSCRNS            Figure out how many screens needed to hold all icons
                    lbsr      UPDFITBL            Rebuild icon positions in file table (FL.* stuff)
                    lbsr      INITSCRN            Init new screen
                    rts

AREYSURE            fcc       " Are you sure?"
                    fcb       NUL

YES.NO              fcb       LF
                    fcc       "        Yes!"
                    fcb       NUL

SUREBOX5            ldd       #10
                    bra       SUREBOX9

SUREBOX6            ldd       #4*256+5
                    bra       SUREBOX9

SUREBOX7            ldd       #0
                    bra       SUREBOX9

SUREBOX8            ldd       #6*256+5
SUREBOX9            std       SUREYPOS+1
                    pshs      U
                    lbsr      NOMOUSE
                    ldu       #MOUSPCKT
                    ldb       #3
                    pshs      D,DP,X
                    decb
                    pshs      D
                    ldx       #6
                    ldb       #14
                    pshs      D,X
                    ldx       SUREYPOS
                    ldb       SUREXPOS
                    pshs      D,X
                    ldx       #1
                    ldb       WNDWPATH+1
                    pshs      D,X
                    lbsr      OWSET
                    ldd       #WT.DBOX
                    std       2,S
                    lbsr      ST.WNSET
                    leax      <AREYSURE,PC
                    stx       ,S
                    lbsr      WRLNWCR
                    leax      <YES.NO,PC
                    stx       ,S
                    lbsr      WTSTRLEN
                    ldd       #16
                    std       BXOFFSET
                    std       0+2,S
                    ldb       #20
                    std       ,S
                    lbsr      DRAWABOX
                    lbsr      MOUSENOW
                    lbsr      SETSGNLS
                    tst       RECDSGNL+1
                    bne       SUREBOX0
                    ifne      H6309
                    tfr       0,x                 Sleep for remainder of tick (ldx #0 for 6809)
                    else
                    ldx       #$0000
                    endc
                    os9       F$SLEEP
SUREBOX0            leas      16,S
                    ldd       RECDSGNL
                    cmpb      #MOUSIGNL
                    bne       SUREBOX1
                    ldb       WNDWPATH+1
                    pshs      d,U
                    lbsr      GT.MOUSE
                    ldd       #16
                    std       2,S
                    ldb       #20
                    std       ,S
                    pshs      U
                    lbsr      TESTDBOX
                    leas      6,S
                    bra       SUREBOX4

SUREBOX1            cmpb      #KYBDSGNL
                    bne       SUREBOX3
                    ldb       #1
                    pshs      D
                    leax      4,S
                    ldb       WNDWPATH+1
                    pshs      D,X
                    lbsr      I.READ
                    leas      6,S
                    ldb       2,S
                    andb      #$5F
                    cmpb      #'Y
                    bne       SUREBOX3
                    ldd       #1
                    bra       SUREBOX4

SUREBOX3            clra
                    clrb
SUREBOX4            std       ,S
                    ldd       WNDWPATH
                    pshs      D
                    lbsr      OWEND
                    lbsr      MOUSENOW
                    ldd       2,S
                    leas      5,S
                    puls      U,PC

* Create overlay window for calling other programs
* Does White on Black
OLAYBLWT            pshs      U
                    ldb       #13                 Overlay window height of 13 lines
                    pshs      D,X,Y,U
                    ldx       #75                 75 char wide window as default
                    tst       FLAG640W            On 640 screen?
                    bne       OLAYBLW2            Yes, continue on
                    ldx       #37                 320 screen, only do 37 char wide window
OLAYBLW2            ldb       #9                  Start Y of overlay at 9 chars down from top
                    pshs      D,X
                    ldx       #2                  Start X of overlay at 2 chars from left
                    ldd       WNDWPATH
                    pshs      D,X
                    lbsr      CWAREA              Change working area to outside of overlay
                    clrb                          Background color black
                    std       14,S
                    ldb       #3                  Foreground color (WHITE)
                    std       12,S
                    ldb       #13                 Y size of overlay
                    std       10,S
                    ldb       #75                 Width of overlay
                    tst       FLAG640W
                    bne       OLAYBLW4
                    ldb       #37                 40 column width
OLAYBLW4            std       8,S
                    clrb
                    std       6,S                 Start Y=0
                    std       4,S                 Start X=0
                    tst       RAMSIZE             Enough RAM to save overlay area?
                    beq       OLAYBLW6            No, don't bother
                    incb                          Flag to preserve contents
OLAYBLW6            std       2,S
                    lbsr      OWSET               Do overlay window
                    leas      16,S                Eat stack
                    std       -2,S                Save error code
                    bne       OLAYBERR
                    ldx       #WT.DBOX            Double box around window
                    ldd       WNDWPATH
                    pshs      D,X
                    lbsr      ST.WNSET            Draw double box
                    leas      4,S
                    bra       OLAYBLW7

* Theoretically,
OLAYWTBK            pshs      U
                    clrb                          Black background
                    pshs      D
                    ldb       #3                  White foreground
                    pshs      D
                    ldx       WINDWSZY            Get window Y size
                    leax      -3,X                Drop by 3
                    ldd       WINDWSZX            Get window X size
                    asra                          Divide by 2
                    rorb
                    pshs      D,X                 Save X/Y sizes
                    clrb
                    pshs      D
                    pshs      D
                    tst       RAMSIZE
                    beq       OLAYWTB2
                    incb
OLAYWTB2            pshs      D                   Save 'save screen' flag
                    ldd       WNDWPATH
                    pshs      D
                    lbsr      OWSET
                    leas      16,S                Eat stack
                    std       -2,S
                    bne       OLAYBERR
OLAYBLW7            ldd       4,S
                    pshs      D
                    bsr       OLAYIOPS
                    lbra      ISC128K5

OLAYBERR
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    puls      U,PC

OLAYIOPS            pshs      U
                    ldu       4,S
                    bsr       IOOPTSON
                    ldd       WNDWPATH            Get GSHELL window path
                    std       GD.WPATH,U          Save as window path for forked program
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       GD.SCRNO,U          Screen # 0
                    incb
                    std       GD.DW.OW,U          ??? to 1
                    puls      U,PC

* Turn ON: page pause, echo, text cursor, and release any pending signals
IOOPTSON            ldb       #1                  Flag for turning stuff ON
                    pshs      D
                    ldb       WNDWPATH+1
                    pshs      D
                    lbsr      PAUSECHO            Turn pause & echo on
                    lbsr      CURSORON            Turn text cursor on
                    lbsr      ST.RELEA            Release any pending signals
                    leas      4,S
                    rts

KILLOLAY            pshs      U
                    ldd       WNDWPATH            Get path to current window
                    pshs      D,X
                    clr       3,S
                    lbsr      ST.RELEA            Release any pending signals
                    lbsr      MOUSOFF             Shut mouse off
                    lbsr      OWEND               Remove overlay window
                    lbsr      FULLSCRN            Change working area to full screen
                    lbsr      PAUSECHO
                    lbsr      CURSROFF            Shut text cursor off
                    lbsr      INITMOUS            Set mouse parms
                    leas      4,S
                    puls      U,PC

* Make double bordered overlay window with text in it
OLAYGNBK            pshs      U
                    ldu       6,S
                    leas      -12,S               Make stack buffer
                    ldd       16,S
                    pshs      D
                    lbsr      ST.RELEA            Release any pending signals
                    stu       ,S
                    lbsr      STRLEN              Get string length of prompt text
                    std       4+2,S
                    leas      2,s
*NOTE: SINCE THIS MULD DOES THE WIDTH OF A WINDOW, WHICH CAN NEVER GET PAST
* 106 CHARACTERS, WE SHOULD BE ABLE TO USE A STRAIGHT 8 BIT MUL, FOLLOWED BY
* AND ADDD#7 ON _BOTH_ THE 6809 & 6309 VERSIONS.
                    ifne      H6309
                    muld      #6                  Multiply by 6 (for 6 pixel font chars)
                    ldd       #7                  Add 7 extra pixels (border?)
                    addr      w,d
                    else
                    pshs      x,y,u
                    ldx       #6
                    lbsr      MUL16
                    pshs      u
                    ldd       #7
                    addd      ,s++
                    puls      x,y,u
                    endc
                    lbsr      DIVDX8              Divide by 8 (shift method) for # 8 pixel chars for window width
                    addd      #3                  Add 3 more for borders?
                    cmpd      WINDWSZX            Too big for current screen width?
                    blo       OLAYGNB1            No, continue
                    ldd       WINDWSZX            Yes, change to screen width-1
                    decb
OLAYGNB1            std       6,S                 Save overlay window width
                    ldd       20,S                ???
                    ifne      H6309
                    incd
                    else
                    addd      #$0001
                    endc
                    std       20,S
                    leax      ,S                  Where we are going to store Y size
                    pshs      X
                    leax      4,S                 Where we are going to store X size
                    ldd       20-2,S
                    pshs      D,X                 Save path # & ptr to where to store X size
                    lbsr      GT.SCSIZ            Get the current screen size
                    leas      6,S                 Eat ptrs & path duplicates
                    ldd       2,S                 Get X size of screen
                    cmpd      6,S
                    bhi       OLAYGN05            If it is wider than the proposed overlay window, jump
                    dec       6,S                 If not, bump X size of overlay down by one
                    clr       11,S                ??? Clear flag
                    bra       OLAYGN07

OLAYGN05            subd      6,S                 Get # of characters extra we have for window vs scrn width
                    pshs      D
* NOTE: HARD CODE SINGLE SHIFT HERE! (6809 & 6309)
                    ldd       #2                  Divide by 2 (to figure out start X coord of overlay)
                    lbsr      CCDIV
                    std       10,S                Save start X coord
OLAYGN07            ldb       #3                  Save background palette #3 (white in new windint)
                    pshs      D
* NOTE: 6309 ONLY - USE DARK GREY? (PALETTE #1)
                    ldb       #1                  Save foreground palette #1 (dark grey in new windint)
                    pshs      D
                    ldd       24,S                Get Y size for border (usually 2)
                    addb      #3                  ??? Add 3 for data entry lines (not including borders)
                    pshs      D                   Save overlay Y size
                    ldd       12,S                Save X size of overlay
                    pshs      D
* Start Y coord for overlay
* NOTE: 6309 - Change to use W on first load, then SUBR
                    ldd       28,S                Get Y size of border (usually 2)
                    addd      #3                  Add 3 for height added to overlay window for data entry
                    pshs      D
                    ldd       10,S                Get height of screen
                    subd      ,S++                Subtract overlay Y size
                    asra                          Divide result by 2
                    rorb
                    pshs      D                   Save Y start coord
                    ldd       20,S                Start X coord of overlay
                    pshs      D
                    ldb       #1                  Save switch to ON
                    pshs      D
                    ldd       30,S                Get path to window
                    pshs      D
                    lbsr      OWSET               Make overlay window
                    leas      16,S                Eat temp stack
                    std       -2,S                If error, eat stack & return
                    bne       OLAYGNB4
                    ldx       #WT.DBOX            Now make the overlay a double bordered box
                    ldd       18-2,S
                    pshs      D,X
                    lbsr      ST.WNSET
                    leas      4,S
                    ldd       20,S                ??? Flag to indicate whether we add CR to text on overlay
                    beq       OLAYGNB2            or not. If 0, do NOT add CR.
                    ldd       4,S
                    pshs      D                   Save length of string to write
                    ldd       20-2,S
                    pshs      D,U                 Save path # and ptr to text to write
                    lbsr      I.WRITLN            Write text to double box window
                    ldd       #1                  Length to write=1
                    std       4,S
                    leax      CRETURN,PC          Write out a single CR
                    stx       2,S
                    lbsr      I.WRITLN
                    bra       OLAYGNB3

OLAYGNB2            ldd       4,S                 Get length of string to write
                    pshs      D                   Save it
                    ldd       20-2,S              Get ptr to text to write
                    pshs      D,U
                    lbsr      I.WRITE             Write text out (NO CR)
OLAYGNB3            leas      6,S                 Eat stack & exit
OLAYGNB4            leas      12,S
                    puls      U,PC

* Pop up overlay window and ask for input from user
INPTSCRN            pshs      U
                    ldd       #1
                    pshs      D
                    ldx       6,S
                    ldd       WNDWPATH
                    pshs      D,X
                    lbsr      OLAYGNBK            Pop up overlay window & print prompt
                    lbsr      CURSORON            Turn text cursor on
                    bsr       INPUTCHK            Get input from user
                    leas      2+4,S
                    tfr       D,U
                    lbsr      KILLOLAY            Shut off overlay prompt window
                    tfr       U,D
                    puls      U,PC

INPUTCHK            ldd       WNDWPATH            Get window path
                    pshs      D
INPTLOOP            lbsr      SETSGNLS            Reset both mouse & keyboard signals
                    ldd       RECDSGNL            Any signal received?
                    bne       INPTSGNL            Yes, go process
                    tfr       d,x
                    os9       F$SLEEP             Sleep for remainder of tick
                    ldd       RECDSGNL            Get signal code
INPTSGNL            cmpb      #S$INTRPT           Interrupt signal?
                    beq       INPTQUIT            Yes, abort input
                    cmpb      #S$ABORT            Abort signal?
                    beq       INPTQUIT            Yes, abort input
                    cmpb      #MOUSIGNL           Mouse signal?
                    bne       INPTKYBD            No, skip ahead (must be keyboard)
                    ifne      H6309
                    clrd                          Mouse signal, abort input & return
                    else
                    clra
                    clrb
                    endc
                    bra       INPTEXIT

INPTKYBD            cmpb      #KYBDSGNL           Keyboard signal?
* NOTE (6309 ONLY): IF LIVE DIRECTORY UPDATE IS ENABLED, WE WILL HAVE TO FLAG
*  IT HERE TO ACT ON _AFTER_ PROCESSING KEYBOARD INPUT
                    bne       INPTLOOP            No, ignore any other signals
                    lbsr      IOOPTSON            Turn pause,echo,text cursor on, release signals
                    lbsr      RDLN80CH            Go read in up to 80 chars
INPTEXIT            leas      2,S                 Eat stack & return
                    rts

* Waiting for user input, but received abort or interrupt signal
INPTQUIT            lbsr      ST.RELEA            Release any other pending signals
                    ldd       #1                  Read 1 char from window path
                    pshs      D
                    leax      2,S                 Point to temp spot
                    ldd       WNDWPATH
                    pshs      D,X
                    lbsr      I.READ              Read 1 key from keyboard (hot key)
                    ifne      H6309
                    clrd                          exit
                    else
                    clra
                    clrb
                    endc
                    leas      8,S
                    rts

KILOLAY2            pshs      U
                    ldd       4,S
                    pshs      D
                    lbsr      ST.RELEA
                    lbsr      OWEND
                    bra       ISC128K5

ISCR128K            pshs      U
                    ldu       6,S
                    ldd       ID.WTYPE,U          Get window type
                    pshs      d                   Save it
                    cmpd      #6
                    bgt       ISC128K4
                    ldd       WNDWPATH            Get GSHELL window path
                    ldx       6,S
                    std       GD.WPATH,X          Save as program window path
                    pshs      d
                    lbsr      GCSETOFF
                    lbsr      ST.RELEA
                    lbsr      DWEND
                    ldd       ID.BKGND,U
                    std       ,S
                    pshs      d
                    ldx       ID.FRGND,U
* Changed for x200 screens
                    ldb       #25
                    pshs      d,X
                    ldd       8,S                 Get screen type
                    lbsr      COLS4080            40 or 80 column?
                    beq       ISC128K1            80 column, skip ahead
                    ldb       #40                 40 columns
                    bra       ISC128K2

ISC128K1            ldb       #80                 80 columns
ISC128K2            pshs      d
                    clrb
                    pshs      d
                    pshs      d
                    ldx       14,S                Get window type
                    ldd       WNDWPATH            Get path # to window
                    pshs      D,X
                    lbsr      DWSET               Set the new window
                    leas      18,S
                    std       -2,S
                    bne       ISC128K3
                    ldx       #1
                    ldd       WNDWPATH
                    pshs      D,X
                    lbsr      SELECT
                    lbsr      MOUSENOW
                    lbsr      PAUSECHO
                    leas      4,S
                    clra
                    clrb
                    bra       ISC128K5

ISC128K3            ldd       #-1
                    bra       ISC128K5

ISC128K4            ldd       #1
ISC128K5            leas      2,S
                    puls      U,PC

* Get mouse packet - wait till button A is released
GETMPAKT            pshs      U
                    ldu       #MOUSPCKT
                    ldd       4,S
                    pshs      D,U
GETMPAK1            lbsr      GT.MOUSE            Get mouse packet
                    ldd       PT.CBSA,U           Button A pressed?
                    bne       GETMPAK1            Yes, wait till it is released
                    leas      4,S
                    puls      U,PC

* Use mouse to position & size new window
SETSTOP             pshs      U
                    leas      -10,S               Make 10 byte temp area
                    ldu       #MOUSPCKT           Point to mouse packet
                    ldd       14,S
                    pshs      D
                    bsr       GETMPAKT            Let auto-follow mouse for start position of window run until
                    leas      2,S                 button A is released
* Upper left corner is now selected
SETSTOP1            ldd       14,S
                    pshs      D,X,Y
                    lbsr      ST.RELEA            Release signals
                    clra
                    clrb
                    std       RECDSGNL
                    std       WPOSGOOD
                    ldd       #KYBDSGNL           Set keyboard signal (So we can trap SPACEBAR to switch screens
                    std       2,S                 for new window)
                    lbsr      ST.SSIG
                    clra
                    clrb
                    std       6,S
                    std       4,S
                    std       8,S
                    std       2,S
                    lbsr      SETDPTR             Draw ptr=0,0
                    ldd       PROCYSIZ            Min. X size of process
                    std       4,S
                    ldd       PROCXSIZ            Min. Y size of process
                    std       2,S
                    lbsr      BOX                 Draw box (for window sizing)
                    leas      6,S
SETSTOP2            pshs      U
                    ldd       16,S
                    pshs      D
                    lbsr      GT.MOUSE            Get mouse update
                    leas      4,S
                    ldb       PT.CBSB,U           Button B pressed?
                    beq       SETSTOP3            No, skip ahead
                    ldd       #S$WAKE             Flag WAKE signal
                    std       RECDSGNL
                    lbra      SETTOP13

SETSTOP3            ldb       PT.CBSA,U           Button A pressed?
                    beq       SETSTOP4            No, skip ahead
                    ldd       14,S                Button B pressed - do this?
                    pshs      D
                    bsr       GETMPAKT            Do auto-follow mouse update until button A pressed
                    leas      2,S
                    ldd       WPOSGOOD
                    lbeq      SETTOP13
                    bra       SETSTOP2

* Button A pressed when positioning window
SETSTOP4            ldd       PT.ACX,U            Get current X coord of mouse
                    std       6,S                 Save it
                    ldd       PROCWTYP            Get window type
                    lbsr      COLS4080            40 or 80 column?
                    beq       SETSTOP5            80 column, skip ahead
                    ldd       6,S                 Get current X coord of mouse
                    lsra                          divide by 2
                    rorb
                    std       6,S                 Save it
SETSTOP5            ldd       6,S                 Get X coord of mouse
                    andb      #%11111000          Make it evenly divisible by 8
                    std       6,S                 Save new X coord
                    ldd       PT.ACY,U            Get current mouse Y coord
                    andb      #%11111000          Make it evenly divisible by 8
                    std       4,S                 Save it
                    ldd       6,S                 Get X coord
                    cmpd      2,S
                    bne       SETSTOP6
                    ldd       4,S
                    cmpd      ,S
                    beq       SETTOP11
SETSTOP6            ldd       4,S
                    addd      PROCYSIZ
                    pshs      D
                    ldd       8,S
                    addd      PROCXSIZ
                    pshs      D
                    ldx       8,S
                    ldd       12-2,S
                    pshs      D,X
                    lbsr      CHKPOSIT            See if we can position window on existing screen
                    leas      8,S
                    std       -2,S
                    beq       SETSTOP9
                    ldd       WPOSGOOD
                    beq       SETSTOP7
                    ldd       14,S
                    pshs      D
                    lbsr      GOODWPOS
                    leas      2,S
                    bra       SETSTOP8

SETSTOP7            bsr       MAKERBOX
SETSTOP8            ldd       4,S
                    std       ,S
                    pshs      D
                    ldx       8,S
                    stx       4,S
                    ldd       18-2,S
                    pshs      D,X
                    lbsr      SETDPTR
                    leas      6,S
                    bsr       MAKERBOX
                    std       -2,S
                    bge       SETTOP11
                    bra       SETTOP10

* Draw relative box
MAKERBOX            ldd       PROCYSIZ            Y size
                    pshs      D
                    ldd       PROCXSIZ            X size
                    pshs      D
                    ldd       18+2,S              Get path # to full-screen window underneath program windows
                    pshs      D
                    lbsr      RBOX                Draw box from current coord for currently selected size
                    leas      6,S
                    rts

SETSTOP9            ldd       WPOSGOOD
                    bne       SETTOP11
                    bsr       MAKERBOX
SETTOP10            ldd       14,S
                    pshs      D
                    lbsr      STOPSIGN
                    leas      2,S
SETTOP11            ldd       RECDSGNL
                    lbeq      SETSTOP2
                    cmpb      #KYBDSGNL
                    bne       SETTOP12
                    ldd       #1
                    pshs      D
                    leax      10,S
                    ldd       18-2,S
                    pshs      D,X
                    lbsr      I.READ
                    leas      6,S
                    bra       SETTOP13

SETTOP12            clra
                    clrb
                    std       RECDSGNL
                    lbra      SETSTOP2

SETTOP13            ldd       RECDSGNL            Get last signal received
                    beq       SETTOP15            None, skip ahead
                    ldd       WPOSGOOD            ??? Window positioning good?
                    bne       SETTOP14            Yes, create selected window pos/size to run program in
                    bsr       MAKERBOX            No, Draw current
SETTOP14            ldd       14,S
                    pshs      D
                    lbsr      GOODWPOS
                    leas      2,S
                    lbsr      GETPSCRN            Create new window (screen) if possible
                    std       14,S                Save flag
                    blt       SETTOP16
                    lbra      SETSTOP1

SETTOP15            ldd       14,S
                    pshs      D
                    lbsr      ST.RELEA            Release signals
                    leas      2,S
                    ldd       2,S
                    ldx       16,S
                    std       GD.XSTRT,X
                    ldd       ,S
                    std       GD.YSTRT,X

SETTOP16            ldd       14,S
                    leas      10,S
                    puls      U,PC

SETSBOTM            pshs      U
                    ldu       4,S
                    leas      -14,S
                    ldx       #MOUSPCKT
                    stx       12,S
                    clra
                    clrb
                    std       WPOSGOOD
                    ldx       20,S
                    ldd       GD.XSTRT,X
                    addd      PROCXSIZ
                    std       2,S
                    std       6,S
                    ldd       GD.YSTRT,X
                    addd      PROCYSIZ
                    std       ,S
                    std       4,S

SETSBOT1            ldd       12,S
                    pshs      D
                    pshs      U
                    lbsr      GT.MOUSE
                    leas      4,S
                    ldd       WPOSGOOD
                    beq       SETSBOT2
                    ldx       12,S
                    ldb       PT.CBSA,X
                    bne       SETSBOT1

SETSBOT2            ldx       12,S                Get ptr to mouse packet
                    ldd       PT.ACX,X            Get current mouse X coord
                    std       10,S                Save it
                    ldd       PROCWTYP            Get new process' window type
                    lbsr      COLS4080            Check if 40 or 80 column
                    beq       SETSBOT3            80 column, skip ahead
                    ldd       10,S                Get mouse X coord again
                    asra                          Divide by 2
                    rorb
                    std       10,S                Save it
SETSBOT3            ldd       10,S                Get mouse X coord
                    pshs      D                   Save it
                    lbsr      RNDUPTO8            Round up to nearest 8 pixel boundary
                    std       10+2,S              Save it again
                    ldx       12+2,S              Get mouse packet ptr again
                    ldd       PT.ACY,X            Get mouse Y coord
                    std       ,S                  Save it
                    lbsr      RNDUPTO8            Round it up to nearest 8 pixel boundary
                    leas      2,S                 Eat temp stack
                    std       8,S                 Save it
                    ldd       10,S                Get X coord
                    cmpd      6,S
                    bge       SETSBOT4
                    ldd       6,S
                    std       10,S

SETSBOT4            ldd       8,S
                    cmpd      4,S
                    bge       SETSBOT5
                    ldd       4,S
                    std       8,S

SETSBOT5            ldd       10,S
                    cmpd      2,S
                    bne       SETSBOT6
                    ldd       8,S
                    cmpd      ,S
                    beq       SETBOT11

SETSBOT6            ldx       8,S
                    ldd       12-2,S
                    pshs      D,X
                    ldx       24,S
                    ldd       GD.YSTRT,X
                    pshs      D
                    ldd       GD.XSTRT,X
                    pshs      D
                    lbsr      CHKPOSIT
                    leas      8,S
                    std       -2,S
                    beq       SETSBOT9
                    ldd       WPOSGOOD
                    beq       SETSBOT7
                    pshs      U
                    lbsr      GOODWPOS
                    leas      2,S
                    bra       SETSBOT8

MAKEBOX2            ldd       2,S
                    pshs      D
                    ldd       4+2,S
                    pshs      D
                    pshs      U
                    lbsr      BOX
                    leas      6,S
                    rts

SETSBOT7            bsr       MAKEBOX2

SETSBOT8            ldd       8,S
                    std       ,S
                    pshs      D
                    ldd       12,S
                    std       4,S
                    pshs      D
                    pshs      U
                    lbsr      BOX
                    leas      6,S
                    std       -2,S
                    bge       SETBOT11
                    bra       SETBOT10

SETSBOT9            ldd       WPOSGOOD
                    bne       SETBOT10
                    bsr       MAKEBOX2

SETBOT10            pshs      U
                    bsr       STOPSIGN
                    leas      2,S

SETBOT11            ldx       12,S
                    ldb       PT.CBSA,X
                    lbeq      SETSBOT1
                    ldd       WPOSGOOD
                    lbne      SETSBOT1
                    ldd       8,S
                    ldx       20,S
                    std       GD.YEND,X
                    pshs      D
                    ldd       12,S
                    std       GD.XEND,X
                    pshs      D
                    pshs      U
                    lbsr      BOX
                    leas      14+6,S
                    puls      U,PC

RNDUPTO8            pshs      U
                    ldd       4,S
                    addd      #7
                    andb      #$F8
                    addd      #-1
                    puls      U,PC

STOPSIGN            pshs      U
                    ldd       #1
                    std       WPOSGOOD
                    ldb       #PTR.ILL
                    pshs      D
                    ldx       #GRP.PTR
                    ldd       8-2,S
                    pshs      D,X
                    lbsr      GCSET
                    leas      6,S
                    puls      U,PC

GOODWPOS            clra
                    clrb
                    std       WPOSGOOD
                    ldd       2,S
                    pshs      D
                    lbsr      GCSETOFF
                    puls      D,PC

* Theoretically, code to check if we can fit new window on an existing
* screen
CHKPOSIT            pshs      U
                    ldu       PTBLSPTR            Get ptr to process descriptors table
                    bra       CHKPOSI8            NOTE: BOTH CPUS: S/B ABLE TO BRA PAST STU -2,S

CHKPOSI1            ldd       GD.SCRNO,U          Get screen # for process entry
                    cmpd      ACTVSCRN            Same as active process screen?
                    bne       CHKPOSI7            Nope, skip ahead
                    ldd       GD.XSTRT,U
                    cmpd      4,S
                    blt       CHKPOSI3
                    cmpd      8,S
                    blt       CHKPOSI4
                    bra       CHKPOSI7

CHKPOSI3            ldd       GD.XEND,U
                    cmpd      4,S
                    bgt       CHKPOSI4
                    cmpd      8,S
                    ble       CHKPOSI7

CHKPOSI4            ldd       GD.YSTRT,U
                    cmpd      6,S
                    blt       CHKPOSI5
                    cmpd      10,S
                    blt       CHKPOSI6
                    bra       CHKPOSI7

CHKPOSI5            ldd       GD.YEND,U
                    cmpd      6,S
                    bgt       CHKPOSI6
                    cmpd      10,S
                    ble       CHKPOSI7
CHKPOSI6            clra
                    clrb
                    puls      U,PC

CHKPOSI7            ldu       GD.LINK,U           Get ptr to next forked program entry
CHKPOSI8            stu       -2,S                Is there one?
                    bne       CHKPOSI1            Yes, check positions
                    ldd       #1                  No, set flag to 1 & exit
                    puls      U,PC

* Entry: B=screen type
* Exit: B=0 (80 column)
*       B=1 (40 column)
COLS4080            decb                          Type 1?
                    beq       COLS408X            Yes, flag 40 column
                    cmpb      #5                  320x200x4?
                    beq       COLS408X            Yes, flag 40 column
                    cmpb      #7                  320x200x16?
                    beq       COLS408X            Yes, flag 40 column
                    clrb                          Flag for 80 column
                    rts

COLS408X            ldb       #1
                    rts

* >128k RAM, try to make new window???
ISCR512K            pshs      U
                    ldu       4,S                 Get ptr to current GD (forked process table) structure
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       ACTVSCRN            Current active screen to none
                    std       DWSETSTY            New window type to none
                    ldx       6,S
                    lbsr      GFXSIZXY            Set window type & minimum X/Y sizes
                    ldd       ID.MEMSZ,X          Get mem size need for new program
                    std       GD.MEMSZ,U          Save it in forked process table
                    ldd       PROCWTYP            Get default window type new program
                    pshs      d,X,Y               Save window type, ID.* tbl ptr & room for 2 bytes(?)
                    bsr       COLS4080            Figure it if 40 or 80 column screen
                    stb       5,S                 Save 40/80 flag (0=80 column)
                    puls      d                   Get window type back
                    decb
                    beq       ISC512K3            H/W text handler (type 1) - Just create new window
                    decb
                    beq       ISC512K3            H/W text handler (type 2) - Just create new window
                    ldb       #40                 Default to 40 column screen
                    tst       3,S                 Was process window type 40 or 80 column
                    bne       ISC512K2            40, skip ahead
                    ldb       #80                 It was 80
ISC512K2            cmpb      ID.XSIZE+1,X        If min width<>full width window, go to window
                    bne       ISC512K6            sizing routine
                    lda       ID.YSIZE+1,X        If min height<>full height window, go to window sizing
                    cmpa      #25                 routine
                    bne       ISC512K6
* New window is full size goes here
ISC512K3
                    ifne      H6309
                    clrd                          Default window x,y start to 0,0
                    else
                    clra
                    clrb
                    endc
                    std       GD.XSTRT,U
                    std       GD.YSTRT,U
                    ldd       #319                Default to 320 X pixel size
                    tst       3,S                 Was it 40 column window?
                    bne       ISC512K5            Yes, 320 is fine
                    ldd       #639                80 column, so 640 X pixel size
ISC512K5            std       GD.XEND,U           Save X size for new process
                    ldd       #199                Y end is 199 (NitrOS9 only)
                    std       GD.YEND,U
                    ldd       #-1                 Flag active screen with -1 (?)
                    std       ACTVSCRN
                    ldd       PROCWTYP            Get process' requested type
                    std       DWSETSTY            Save as screen type to use to create new window
                    bra       ISC512K7

* New window is sized by user - do positioning/sizing
ISC512K6            lbsr      GETPSCRN            ???Activate screen we will be putting new window on
                    std       ,S                  Save flag
                    lblt      IS512K13            If -2 or -1, eat stack & exit (Either scrn tbl full, or deleted old screen)
                    pshs      d,U
                    lbsr      SETSTOP             Position & size window with mouse
                    leas      4,S
                    std       ,S                  Save flag
                    lblt      IS512K13
                    pshs      d,U
                    lbsr      SETSBOTM
                    ldd       4,S
                    std       ,S
                    lbsr      GCSETOFF
                    leas      4,S
                    ldx       #0
                    ldd       ,S
                    pshs      d,X
                    lbsr      LSET
                    leas      4,S
* Create new window (?)
ISC512K7            ldd       ACTVSCRN
                    std       GD.SCRNO,U
                    blt       ISC512K8
                    lbsr      LINKWNDW
ISC512K8            lda       #UPDAT.             Open path to next available window
                    ldx       #SLASHW
                    lbsr      I.OPEN
                    std       2,S                 Save path #
                    blt       IS512K13            negative (error), skip ahead
                    std       GD.WPATH,U          Save as path # to window for program to fork
                    ldx       10,S
                    bne       ISC512K9
                    clra
                    clrb
                    ldx       #1
                    bra       IS512K10

ISC512K9            ldd       ID.FRGND,X          Get foreground color
                    ldx       ID.BKGND,X          Get background color
IS512K10            pshs      X                   Save border color (Background copy)
                    pshs      d,X                 Save background & foreground colors
                    leas      -12,S               Make room on stack for rest of DWSET
                    ldd       GD.YSTRT,U
                    bsr       DIVDX8
                    std       6,S                 Save Y start of window
                    ldd       GD.YEND,U
                    incb
                    bsr       DIVDX8
                    subd      6,S                 Save Y window size
                    std       10,S
                    ldd       GD.XSTRT,U          Save X start of window
                    bsr       DIVDX8
                    std       4,S
                    ldd       GD.XEND,U           Save X window size
                    ifne      H6309
                    incd
                    else
                    addd      #$0001
                    endc
                    bsr       DIVDX8
                    subd      4,S
                    std       8,S
                    ldd       DWSETSTY            Save screen type
                    std       2,S
                    ldd       20,S                Save path to new window
                    std       ,S
                    lbsr      DWSET
                    leas      18,S
                    std       -2,S
                    bne       IS512K12
                    ldd       DWSETSTY
                    beq       IS512K11
                    ldd       2,S
                    pshs      D
                    lbsr      SELECT
                    puls      D

IS512K11            ldd       #2
                    std       GD.DW.OW,U
                    decb
                    bra       IS512K13

IS512K12            ldd       #-1

IS512K13            leas      4,S
                    puls      U,PC

*D=D/8
DIVDX8              asra
                    rorb
                    asra
                    rorb
                    asra
                    rorb
                    rts

*D=D*8
MULDX8              aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    rts

* ???
* NOTE: BOTH CPUS: SINCE MAX=8, LDB ACTVSCRN+1 WOULD BE FINE
* Exit: D=-1 : screen table full, could not create new screen
*       D=-2 : Closed existing screen table, did not create new screen
GETPSCRN            pshs      U                   Preserve U
                    leas      -2,S                Make room on stack
                    ldu       #SCRNTABL           Point to start of screens used table
                    ldd       ACTVSCRN            Get active screen #
                    aslb                          x4 (size of each entry)
                    aslb
                    leau      D,U                 Point to active screen entry
                    ldb       ACTVSCRN+1          Get active screen # again
                    beq       GETPSCR3            1st entry, skip ahead (?)
                    leax      SC.SIZE,U           Point to next entry
                    lda       SC.USERS,X          Any paths already open to this next screen?
                    bne       GETPSCR3            Yes, skip ahead
* Cleanup? seems to close screen path if no programs on screen
                    ldd       WNDWPATH            No programs on this screen, get GSHELL window path
                    pshs      D,X
                    lbsr      SELECT              Go select GSHELL window
                    puls      D,X
                    lbsr      CLOSE.X             Close screen entry path
                    ldd       #-2                 Exit flag
                    bra       GETPSCR6

* NOTE: IN ADDITION TO ADDING SUPPORT FOR VDG SCREENS, AND WINDOW TYPES
*  WITH GSHELL PALETTES (INSTEAD OF STANDARD), WE SHOULD PUT IN A WILDCARD
*  ONE FOR PROGRAMS THAT DON'T CARE (EX. ZONE RUNNER, ROGUE, ETC.) THAT CAN
*  RUN ON ANY TYPE AS LONG AS THERE IS ROOM, BASED ON MINIMUM X/Y SIZES.
*  (AND IT HAS TO BE ON A GRAPHICS WINDOW)
* SC.USERS count will be at least 1 (for the underlying size select window)

* This chunk checks against window types for screens in active use...
GETPSCR1            lda       SC.WTYPE,U          Get screen type
                    cmpa      PROCWTYP+1          Same as window type needed for process?
                    bne       GETPSCR2            No, try next screen
                    lda       SC.USERS,U          Screen initialized already?
                    bne       GETPSCR8            Yes, skip ahead
GETPSCR2            incb                          Set active screen to next one
                    stb       ACTVSCRN+1
                    leau      SC.SIZE,U           Bump to next screen table
GETPSCR3            cmpb      #8                  On last possible active screen?
                    blt       GETPSCR1            No, check this screen
* No current screen entry of correct type
                    ldu       #SCRNTABL           IF on last screen, point to start of screen table
                    clrb                          Next routine starts @ screen 0 again
                    bra       GETPSCR5            See if we can add new screen to list

* This chunk checks to see if we can add a new screen to the screen table
GETPSCR4            lda       SC.USERS,U          Is this screen initialized already?
                    beq       GETPSCR7            No, use it
                    incb                          Yes, try next one
                    leau      SC.SIZE,U
GETPSCR5            stb       ACTVSCRN+1          Save screen #
                    cmpb      #8                  On last one?
                    blt       GETPSCR4            No, check next
                    ldd       #-1                 ERROR - no room for new screen
GETPSCR6            std       ,S                  Save flag as to what happened
                    bra       GETPSCR9            Restore regs & exit

* Empty screen table entry - add new entry (Screen) for process
GETPSCR7            ldd       PROCWTYP            Get process window type
                    stb       SC.WTYPE,U          Save as screen table screen type
                    pshs      D                   Save it
                    bsr       OPNSLSHW            Open new window (/w)
                    leas      2,S                 Eat stack
                    stb       SC.PTHNO,U          Save new window path #
GETPSCR8            ldb       SC.PTHNO,U          Get path # to screen
                    sex                           Save it as D for subroutines
                    std       ,S
                    blt       GETPSCR9            If new window failed, exit
                    inc       ACTVSCRN+1          Bump up active screen #
                    bsr       INITPSCR            Select new window, LSET to XOR, set up mouse
GETPSCR9            puls      D,U,PC

* Select new window, prepare for sizing/etc.
INITPSCR            pshs      D                   Save new window path #
                    pshs      D                   & again
                    lbsr      INITMOUS            Set mouse parms & turn auto follow on
                    lbsr      CURSCLOF            Cursor & scaling off
                    lbsr      SELECT              Select new window as interactive one
                    ldd       #3                  gfx logic set to XOR
                    std       2,S
                    lbsr      LSET
                    clr       3,S
                    lbsr      PAUSECHO            Shut echo & pause off
                    leas      4,S                 Eat stack & return
                    rts

* Create new window - GSHPAL window stuff & VDGINT stuff should go here!
* Called from GETPSCR7 only. Should be able to sneak GSHPAL flag as 1st byte
*   of window type (0=not gshpal, <>0=gshpal), so window type needs no
*   massaging here (or, do masks here)
* Entry: 0-1,s = RTS address
*        2-3,s = window type
* Exit: D=New window path #
*         <0 means failure on OPEN
OPNSLSHW            pshs      U
                    ldx       #SLASHW
                    lda       #UPDAT.
                    lbsr      I.OPEN              Open /w
                    tfr       D,U                 Copy path # to U
                    std       -2,S
                    blt       OPNSLSHX            Error opening path, exit
                    ldb       #80
                    lda       5,S                 Get window type (could put GSHPAL flag at 4,s)
* beq SetupVDG    Add this in for when we do VDG window support
                    anda      #1                  See if 40 or 80 column window
                    bne       OPNSLSH2
                    ldb       #40
OPNSLSH2            pshs      d                   Save window width for DWSET
                    ldb       #2                  Border color=2
                    pshs      d
                    clrb                          Background color=0
                    pshs      d
                    incb                          Foreground color=1
                    pshs      d
                    ldb       #25                 Window height=25
                    pshs      d
                    ldx       8,S                 Get window width
                    clrb
                    pshs      d,X                 Save Y start & window width
                    pshs      d                   Save X start
                    ldd       20,S                Get window type
                    pshs      d                   Save for DWSET
                    pshs      U                   Save path # to new window (new screen)
                    lbsr      DWSET               Set the window
                    clrb
                    std       2,S
                    lbsr      DWPROTSW
                    leas      20,S                Eat temp stack
OPNSLSHX            tfr       U,D                 Transfer new window path # to D & exit
                    puls      U,PC

SRWINDOW            decb                          - Note, if B does not need to be signed, change
                    ldx       #SCRNTABL           LEAX d,x to abx
                    aslb
                    aslb
                    leax      D,X
                    rts

LINKWNDW            bsr       SRWINDOW
                    inc       SC.USERS,X
                    rts

* Unlink window from active screen list
UNLKWNDW            ldd       2,S
                    bsr       SRWINDOW
                    dec       SC.USERS,X          Dec # users on current screen
                    bne       UNLKWND1            Still some left, exit
* Close current SC.* entry path
* Entry: X=ptr to current entry in used screen table
CLOSE.X             lda       SC.PTHNO,X          Get path to window
                    os9       I$CLOSE             Close it
                    clra                          Flag as no path anymore & return
                    sta       SC.PTHNO,X
UNLKWND1            rts

* Calc highest pixel values allowed for AIF entry (X&Y), and window type
* Saves PROCYSIZ, PROCXSIZ, PROCWTYP
* Entry: X=ptr to ID.* structure
GFXSIZXY            ldd       ID.XSIZE,X          Get min. X size for AIF entry
                    lbsr      MULDX8              *8 for pixels
                    subd      #1                  -1 for far right pixel base 0
                    std       PROCXSIZ            Save as min. X size for process
                    ldd       ID.YSIZE,X          Do pixel Y calc
                    lbsr      MULDX8
                    subd      #1
                    std       PROCYSIZ            Save as min. Y size for process
                    ldd       ID.WTYPE,X          Save AIF window type too.
                    std       PROCWTYP
                    rts

ENV.FILE            fcc       "/dd/sys/env.file"
                    fcb       NUL

GET.ENV             pshs      U
                    ldu       #ENVFLBFR           Point U to 80 char buffer for enviornment file lines
                    ldd       #$ffff              Defaults for keyboard & mouse stuff
                    std       <GIPMSRES           Both mouse defaults
                    std       <GIPKYST            Both keyboard defaults
                    ldd       #128                Default RAM size to 128k
                    sta       <CURGFXSZ           Size of GSHPAL buffer to 0
                    std       <RAMSIZE
                    leax      <ENV.FILE,PC        Point to filename
                    pshs      X,Y
                    pshs      U
                    lbsr      STRCPY
                    leas      4,S
                    lda       #READ.
                    tfr       U,X
                    lbsr      I.OPEN              Open env.file
                    std       ,S                  Save path #
                    blt       GET.ENV3            Bad path #, exit

GET.ENV1            ldd       #80                 Size of line buffer to read
                    pshs      d
                    pshs      U
                    ldd       4,S
                    pshs      d
                    lbsr      I.READLN            Read line from env.file
                    leas      6,S
                    std       -2,S
                    ble       GET.ENV2            End of file, close & exit
                    pshs      U
                    bsr       PROCENVF            Go process lines we actually pay attention to
                    leas      2,S
                    bra       GET.ENV1            Keep going till env.file done

ResetPal            pshs      d,u                 For GET.ENV3 below
                    bra       DoPal

GET.ENV2            lbsr      I.CLOSE
                    pshs      y                   Do mouse/keyboard updates
                    lda       <GIPMSRES           Any change to Mouse resolution?
                    cmpa      #$ff
                    bne       Mse2                Yes, use it
                    clra                          No, default to low res
Mse2                ldb       <GIPMSPRT           Any change to mouse port?
                    cmpb      #$ff
                    bne       Kybd1               Yes, use it
                    ldb       #1                  No, default to right port
Kybd1               tfr       d,x                 Move mouse stuff to X
                    ldy       <GIPKYST            Get keyboard repeat start/repeat speed
                    lda       <WNDWPATH+1         Get window path
                    ldb       #$94                SS.GIP call
                    os9       I$SETSTT            Set keyboard/mouse stuff
                    puls      y
DoPal               ldb       <CURGFXSZ           Get current graphics buffer write size
                    beq       GET.ENV3            Empty, exit
                    clra                          Put in Y
                    pshs      y                   Save Y (else screws up)
                    tfr       d,y
                    ldx       #GSHBUF             Point to start of buffer
                    lda       <WNDWPATH+1         Get path # to window
                    os9       I$Write             Write out palette changes
                    puls      y                   Restore y
GET.ENV3            puls      D,U,PC

RBFDEVEQ            fcc       "RBFDEV="
RBFSEND             fcb       NUL

RAMEQU              fcc       "RAM="
RAMSEND             fcb       NUL

* Process and env.file line
PROCENVF            pshs      U
                    ldu       4,S
                    leas      -2,S
                    ldb       #RBFSEND-RBFDEVEQ
                    leax      <RBFDEVEQ,PC
                    bsr       PROCLINE            Check if 'RBFDEV='
                    bne       PROCENV2            No, check next
                    leau      RBFSEND-RBFDEVEQ,U  Point to start of string
PROCENV1            pshs      U                   Save start of string ptr
                    bsr       TERMNATE            Append NUL terminator on end of device name
                    std       2,S                 Save flag as to whether whole string is done
                    lbsr      ADDEVICE            Add the device to the list
                    lbsr      STRLEN              Get length of device name
                    leas      2,S                 Eat extra on stack
                    addd      #1                  Bump length up to accomodate NUL (INCD for 6309)
                    leau      D,U                 Point to start of next device name (if any)
                    ldd       ,S                  Get flag - do we have more to do?
                    beq       PROCENV1            Yes, keep doing until all devices done
                    bra       PROCENV4            No, exit process current line of env.file routine

* Check if current env.file line=current flag we are looking for
* Entry:B=Size of compare to do
*       X=Text of current flag we are looking for
* Exit: Flags set so BEQ will mean a match
PROCLINE            pshs      d
                    pshs      X
                    pshs      U
                    lbsr      STRNCMP
                    leas      6,S
                    std       -2,S
                    rts

PROCENV2            ldb       #RAMSEND-RAMEQU     Check for RAM setting ALREADY HANDLES >128K
                    leax      <RAMEQU,PC
                    bsr       PROCLINE
                    bne       PROCENV3            Not RAM, check next
                    leau      RAMSEND-RAMEQU,U    Point to after RAM=
                    pshs      U                   Save ptr
                    lbsr      ATOI                Convert ASCII text from [,u] into D register
                    leas      2,S                 Save RAM size from file
                    std       <RAMSIZE            Save RAM size found
                    bra       PROCENV4            Done processing current line

EXECEQU             fcc       "EXEC="
EXECSEND            fcb       NUL

PROCENV3            ldb       #EXECSEND-EXECEQU   Check for EXEC setting
                    leax      <EXECEQU,PC
                    bsr       PROCLINE
                    bne       GSHPal
                    leau      EXECSEND-EXECEQU,U  Point to 1st byte after EXEC=
                    pshs      U
                    bsr       TERMNATE            Terminate the string with a NUL
                    lbsr      CHGXDIR             Change Execution directory to one read from env.file
                    std       ,S++                Eat stack & set CC
                    bne       PROCENV4
                    ldx       #XDIRNAME           Copy execution path name here
                    pshs      X,U
                    lbsr      STRCPY
                    leas      4,S

PROCENV4            puls      d,U,PC              Restore regs & return

GSHPALEQ            fcc       "GSHPAL"            --Added for GShell palettes
GSHSEND             fcb       NUL

* Add a NUL to the end of a string segment (, or CR delimeter)
* Entry: 2,S=Ptr to string
* Exit: D=0 if end of string
*       D=1 if string has more to process yet
TERMNATE            ldx       2,S                 Get ptr to start of string
                    clrb                          NUL to terminate string with
TERMNAT1            lda       ,X                  Get char
                    beq       TERMNAT4            Already NUL, flag & exit
                    cmpa      #',                 Comma?
                    beq       TERMNAT2            Yes, set NUL & exit
                    cmpa      #CR                 End of line?
                    beq       TERMNAT3            Yes, set NUL & flag & exit
                    leax      1,X                 Bump up string ptr
                    bra       TERMNAT1            Keep looking

TERMNAT2            stb       ,X                  Save NUL as separator
                    clra                          We're done the entire string flag
                    rts

TERMNAT3            stb       ,X                  Save NUL as separator
TERMNAT4            ldd       #1                  We still have more in string to do flag
                    rts

* NOTE: FROM HERE ON, SHOULD CHANGE NON-LBRA TO PROCENV4 TO BE SHORT BRANCHES
*  TO THE TERMINATING LBRA PROCENV4 (TO SAVE A LITTLE SPACE)

* Added by LCB 8/12/1998 - Check for GShell default palettes (only 0-3 legit)
GSHPal              ldb       #GSHSEND-GSHPALEQ   Check for GSHPAL setting
                    leax      <GSHPALEQ,pc
                    bsr       PROCLINE
                    lbne      DefCheck            Not, try next
PalLoop             leau      GSHSEND-GSHPALEQ,u  Point to 1st byte after GSHPAL
                    ldd       ,u++                Get palette # to assign to
                    cmpb      #'=                 2nd char '='?
                    bne       PROCENV4            No, ignore this line
                    suba      #$30                Convert to binary palette #
                    blt       PROCENV4            Went negative, ignore line
                    cmpa      #3                  Within palette range?
                    bhi       PROCENV4            No, ignore this line
                    sta       <CURPAL             Save palette #
                    ldd       ,u++                Get next 2 chars
                    cmpb      #',                 2nd a comma?
                    bne       PROCENV4            No, ignore line
                    suba      #$30                Convert to binary
                    blt       PROCENV4            negative, ignore line
                    cmpa      #3                  Within range?
                    bhi       PROCENV4            (No, ignore line)
                    lsla                          Move to 1st red bit
                    lsla
                    tfr       a,b                 Save copy
                    anda      #4                  Save lsb
                    pshs      a
                    lslb                          Calculate msb of RED
                    lslb
                    andb      #$20
                    addb      ,s+                 Merge the reds together
                    stb       <CURCOLOR           Save it
                    ldd       ,u++                Get next color
                    cmpb      #',                 2nd char a comma?
                    bne       PROCENV4            No, ignore line
                    suba      #$30                Convert to binary
                    blt       PROCENV4            negative, ignore line
                    cmpa      #3                  Within range?
                    bhi       PROCENV4            (No, ignore line)
                    lsla                          Shift to 1st Green bit
                    tfr       a,b                 Save copy
                    anda      #2                  Save lsb
                    pshs      a
                    lslb                          Calculate msb of Green
                    lslb
                    andb      #$10
                    addb      ,s+                 Merge the greens together
                    orb       <CURCOLOR           mix with red
                    stb       <CURCOLOR           Save it
                    ldd       ,u++                Get last color
                    cmpb      #CR                 2nd char a CR?
                    bne       GSHPalEx            No, ignore line
                    suba      #$30                Convert to binary
                    blt       GSHPalEx            negative, ignore line
                    cmpa      #3                  Within range?
                    bhi       GSHPALEx            (No, ignore line)
                    tfr       a,b
                    andb      #1
                    pshs      b                   Save lsb of Blue
                    lsla                          Move msb of Blue
                    lsla
                    anda      #$08                Just msb
                    adda      ,s+                 Merge blues together
                    ora       <CURCOLOR           merge with red/green
                    ldx       #GSHBUF             Point to start of palette buffer
                    ldb       <CURGFXSZ           Get size of previous buffer
                    abx                           Point X to start
                    addb      #4                  Add for next position
                    stb       <CURGFXSZ           Save it
                    sta       3,x                 Save color
                    lda       <CURPAL             Get current palette
                    sta       2,x                 Save palette
                    ldd       #$1b31              Change palette command
                    std       ,x                  Save it
GSHPalEx            lbra      PROCENV4            Done processing line

DEFTYPE             fcc       "DEFTYPE="
DEFTPEND            fcb       NUL

MONITOR             fcc       "MONTYPE="
MONTEND             fcb       NUL

* Added by LCB 12/24/1998 - Check for Default screen type=6,7,8
DefCheck            ldb       #DEFTPEND-DEFTYPE   Check for Default screen type
                    leax      <DEFTYPE,PC
                    lbsr      PROCLINE
                    bne       MonCheck            No, try next
                    leau      DEFTPEND-DEFTYPE,u  Point to after DEFTYPE=
                    lda       ,u                  Get screen type
                    suba      #$30                Adjust to binary
                    cmpa      #6                  Below type 6?
                    blo       DefEx               Yes, ignore
                    cmpa      #8                  Above type 8?
                    bhi       DefEx               Yes, ignore
                    sta       DEFWTYPE+1          One of 3 good ones, save it
DefEx               lbra      PROCENV4            Done processing current line

* Added by LCB 04/15/1999 - set monitor type
MonCheck            ldb       #MONTEND-MONITOR    Check for monitor type
                    leax      <MONITOR,pc
                    lbsr      PROCLINE
                    bne       MousChk1            No, try next
                    leau      MONTEND-MONITOR,u   Point to after MONTYPE=
                    ldb       ,u                  Get monitor type
                    subb      #$30                Adjust to binary
                    cmpb      #2                  Above 2, ignore
                    bhi       MonEx
                    clra
                    tfr       d,x                 Move to proper register
                    lda       <WNDWPATH+1         Get path # to window
                    ldb       #$92                SS.Montr call
                    os9       I$SETSTT            Change monitor type
MonEx               lbra      PROCENV4            Done processing current line

PTRSIDE             fcc       "PTRSID="
PTRSDEND            fcb       NUL

* Following 4 (PTRSID, PTRRES, REPSPD, REPSTR) added by LCB 04/15/1999 - set
*   keyboard and mouse parameters
MousChk1            ldb       #PTRSDEND-PTRSIDE   Check for Mouse port
                    leax      <PTRSIDE,pc
                    lbsr      PROCLINE
                    bne       MousChk2            No, try next
                    leau      PTRSDEND-PTRSIDE,u  Point to after PTRSID=
                    lda       ,u                  Get parm
                    suba      #$30                ASC to binary
                    cmpa      #1
                    bhi       Mse1Ex              <>0 or 1 is illegal
                    ldb       #1
                    ifne      H6309
                    subr      a,b                 Invert value
                    else
                    pshs      a
                    subb      ,s+
                    endc
                    incb                          Bump up to 1-2 for SS.GIP
                    sta       <GIPMSPRT           Save it
Mse1Ex              lbra      PROCENV4

PTRRES              fcc       'PTRRES='
PTRRESEN            fcb       NUL

MousChk2            ldb       #PTRRESEN-PTRRES    Check for mouse resolution
                    leax      <PTRRES,pc
                    lbsr      PROCLINE
                    bne       KybdChk1            No, try next
                    leau      PTRRESEN-PTRRES,u   Point to after PTRRES=
                    lda       ,u                  Get parm
                    suba      #$30                ASC to bin
                    cmpa      #1
                    bhi       Mse2Ex              <>1 or 2 is illegal
                    sta       <GIPMSRES           Save mouse res
Mse2Ex              lbra      PROCENV4

REPSTR              fcc       'REPSTR='
REPSTREN            fcb       NUL

* Start delay table from CONTROL
StrtTble            fcb       0,45,30,20,10

KybdChk1            ldb       #REPSTREN-REPSTR    Check for keyboard repeat start
                    leax      <REPSTR,pc
                    lbsr      PROCLINE
                    bne       KybdChk2            No, try next
                    leau      REPSTREN-REPSTR,u   Point to after REPSTR=
                    lda       ,u                  Get parm
                    suba      #$30                ASC to bin
                    beq       Key1Ex              0 not legal
                    cmpa      #5
                    bhi       Key1Ex              Above 5 ain't either (unlike manual's 3)
                    leax      <StrtTble,pc        Point to table
                    deca                          0-4
                    ldb       a,x                 Get speed setting
                    stb       <GIPKYST            Save keyboard repeat start
Key1Ex              lbra      PROCENV4

REPSPD              fcc       'REPSPD='
REPSPDEN            fcb       NUL

SpdTble             fcb       24,12,6,3,2

KybdChk2            ldb       #REPSPDEN-REPSPD    Check for keyboard repeat speed
                    leax      <REPSPD,pc
                    lbsr      PROCLINE
                    bne       Key2Ex              No, done processing current line
                    leau      REPSPDEN-REPSPD,u   Point to after REPSPD=
                    lda       ,u                  Get parm
                    suba      #$30                ASC to bin
                    beq       Key2Ex              0 not legal
                    cmpa      #5
                    bhi       Key2Ex              Above 5 ain't either (unlike manual's 3)
                    leax      <SpdTble,pc         Point to table
                    deca                          0-4
                    ldb       a,x                 Get speed setting
                    stb       <GIPKYSPD           Save keyboard repeat speed
Key2Ex              lbra      PROCENV4

* Get file descriptor info
GT.FDINF            pshs      d,X,Y,U
                    ldx       12,S
                    leax      DIR.FD,X
                    lda       ,X+
                    ldb       #1
                    tfr       D,Y
                    ldu       ,X
                    ldx       14,S
                    lda       1,S
                    ldb       #SS.FDINF
                    os9       I$GETSTT
                    puls      d,X,Y,U
                    bra       ISYSRET1

* Entry: 0-1,s  = RTS address
*        2-3,s  = Path for window (only use 3,s)
*        4-5,s  = On/off flag (0=off, 1=on) (only use 5,s)
PAUSECHO            ldx       #SSOPTBFR           Point to window's SS.option buffer
                    lda       3,S                 Get path
                    clrb                          SS.OPT Getstat
                    os9       I$GETSTT            Get current window options
                    bcs       ISYSRET1
                    ldb       5,S                 Get on/off flag
                    stb       4,X                 Set echo
                    stb       7,X                 Set page pause
                    clrb                          SS.OPT SetStat
                    os9       I$SETSTT            Set echo & pause options
ISYSRET1            lbra      SYSRET

*Close box char, and CurXY to 8,0
CBOXICON            fcb       $C7,$02,$28,$20

*Text string to draw 80 column wide stripes for directory bar
* We should make this box/line calls, as faster (possibly smaller?)
STRIPBAR            fcb       $C5,$C5,$C5,$C5,$C5,$C5,$C5,$C5
                    fcb       $C5,$C5,$C5,$C5,$C5,$C5,$C5,$C5
                    fcb       $C5,$C5,$C5,$C5,$C5,$C5,$C5,$C5
                    fcb       $C5,$C5,$C5,$C5,$C5,$C5,$C5,$C5
                    fcb       $C5,$C5,$C5,$C5,$C5,$C5,$00

WBOX.BAR            leax      <CBOXICON,PC        Point to CLOSE box & CurXY 8,0
                    ldb       #29                 Default to close box & 25 "stripe" bar chars to write
                    tst       FLAG640W
                    beq       WRITEBX             If 320 pixel screen, go write it
                    ldd       <WNDWPATH           Save window path
                    pshs      d
                    ldb       #33                 Do close box & 29 "stripe" bar chars
                    bsr       WRITEBX
                    leas      2,S                 Eat temp window path
                    ldb       #36                 Do 36 more "stripe" bar chars (65 total)
                    leax      <STRIPBAR,PC
                    bra       WRITEBX

GOTOXY              ldx       #GFXBUF2
                    lda       #2
                    ldb       5,S
                    addb      #SPACE
                    std       ,X
                    ldb       7,S
                    addb      #SPACE
                    stb       2,X
                    ldb       #3

GFXWR2              ldx       #GFXBUF2

* Write text string
* Entry: B    =# chars to write
*        X    =Ptr to text to write
*        4-5,s=Path to write to (only 5 used)
WRITEBX             pshs      Y
                    clra
                    tfr       D,Y
                    lda       5,S
                    os9       I$WRITE
                    puls      Y
                    bra       ISYSRET1

CLRSCRN             ldb       #FF
                    bra       OUT1

RINGBELL            ldb       #BEL
OUT1                stb       GFXBUF2,Y
                    ldb       #1
                    bra       GFXWR2

CURSORON            ldb       #$21
                    bra       CURSRSET

CURSROFF            ldb       #$20
CURSRSET            lda       #5
                    std       GFXBUF2,Y
                    ldb       #2
                    bra       GFXWR2

* Change gfx cursor to arrow
CRSRAROW            lda       #GRP.PTR
                    ldb       #PTR.ARR
                    bra       GCSET.2

GCSETOFF            clra
                    clrb
GCSET.2             std       GFXBUF2+2,Y
                    ldd       #$1B39
                    std       GFXBUF2,Y
                    ldb       #4
                    bra       GFXWR2

* Entry for change EXEC dir
CHGXDIR             lda       #EXEC.
                    bra       I.CHGDIR

* Entry for change DATA dir
CHGDDIR             lda       #READ.
I.CHGDIR            pshs      A
* SHOULD WE CHANGE TO JUST DROP SAMPLING RATE SO MOUSE CAN STILL MOVE?
* Shut mouse off (note that keyboard mouse ignores this)
                    lbsr      NOMOUSE
                    puls      A
                    ldx       2,S
                    os9       I$CHGDIR
                    pshs      CC,B
* Mouse back on
                    lbsr      MOUSENOW
                    puls      CC,B
                    lbra      SYSRET

MOUSOFF             clra
                    clrb
                    bra       INITMOU1

*             0-1,s = Path to window to read mouse from
*             2-3,s = Mouse sampling rate
*             4-5,s = Mouse button timeout
*             6-7 ,s= Auto follow mouse flag
* Init mouse to
INITMOUS            ldd       #3
INITMOU1            ldx       #1
                    pshs      X
                    pshs      d,X                 Save mouse sampling rate & mouse button timeout
                    ldd       8,S
                    pshs      d                   Save path to window mouse is on
* NOTE: ONLY CALLED ONCE...EMBED WITH RAW CALL!
                    lbsr      ST.MOUSE            Set mouse parms
                    leas      8,S                 Eat temp stack & return
                    rts

SETUPENV            pshs      U
                    ldu       #DRIVETBL
                    stu       <DRTBLPTR
                    ldx       #DRVNMTBL
                    clra
SETUPEN1            stx       FL.FNAME,U
                    ldb       #IC.DRIVE
                    stb       FL.ICONO,U
                    ldb       #8
                    std       FL.XSTRT,U
                    ldb       #32
                    std       FL.XEND,U
                    ldb       <DRIVYPOS
                    std       FL.YSTRT,U
                    addb      #12
                    std       FL.YEND,U
                    addb      #12
                    stb       <DRIVYPOS
                    leax      32,X
                    leau      FL.SIZE,U
                    dec       <DEVICNTR
                    bne       SETUPEN1
                    lbsr      GET.ENV             Read env.sys file
                    puls      U,PC

ADDEVICE            pshs      U
                    ldx       <DRTBLPTR
                    ldb       <DEVICNTR
                    cmpb      #5
                    bge       ADDEVIC1
                    pshs      B
                    inc       DEVICNTR
                    ldu       5,S
                    pshs      X,U
                    bsr       MOVDNAME
                    puls      X,U
                    leau      FL.SIZE,X
                    stu       <DRTBLPTR
                    ldb       ,S+
                    beq       ADDEVIC1
                    leau      0-FL.SIZE,X
                    stx       FL.LINK,U
ADDEVIC1            puls      U,PC

MOVDNAME            ldx       2,S
                    ldd       FL.FNAME,X
                    ldx       4,S
                    pshs      d,X
                    lbsr      STRCPY
                    leas      4,S
                    rts

FIXDRTBL            ldb       <DEVICNTR
                    beq       FIXDRTB1
                    ldd       <SELECTED
                    beq       FIXDRTBX
                    pshs      d
                    lbsr      UNSLICON
                    leas      2,S

FIXDRTBX            ldx       <DRTBLPTR
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       <SELECTED
                    std       FL.LINK-FL.SIZE,X
                    ldd       <DEVICNOW
                    beq       FIXDRTB1
                    cmpx      <DEVICNOW
                    bhi       FIXDRTB1
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       <DEVICNOW
                    std       <STRTICON
                    lbsr      ENFREFL1
                    lbsr      ENBLSOFF
                    lbsr      CLRDSCRN
FIXDRTB1            rts

CHGDEVCS            pshs      U
                    leas      -38,S
                    leax      6,S
                    stx       4,S
                    ldd       #3
                    pshs      d
                    decb
                    pshs      d
                    ldb       #10
                    pshs      d
                    ldx       #20
                    ldb       #11
                    pshs      d,X
                    decb
                    pshs      d
                    ldx       #1
                    ldb       <WNDWPATH+1
                    pshs      d,X
                    lbsr      OWSET               Overlay window
                    ldd       #WT.DBOX
                    std       2,S
                    lbsr      ST.WNSET            Double boxed window
                    lbsr      IOOPTSON
                    leax      <CHGDEVNM,PC
                    stx       ,S
                    lbsr      WRLNWCR
                    leas      2+14,S
                    ldu       #DRIVETBL
                    bra       CHGDEVC2

CHGDEVC1            ldd       FL.FNAME,U
                    pshs      d
                    lbsr      WRLNWCR
                    leas      2,S
                    ldu       FL.LINK,U
CHGDEVC2            stu       -2,S
                    bne       CHGDEVC1
                    ldu       <DRTBLPTR
                    ldb       <DEVICNTR
                    bra       CHGDEVC5

CHGDEVC3            ldd       #32
                    pshs      d
                    ldx       6,S
                    ldd       WNDWPATH
                    pshs      d,X
                    lbsr      I.READLN
                    leas      6,S
                    std       ,S
                    ble       CHGDEVC6
                    ldb       [4,S]
                    cmpb      #'/
                    bne       CHGDEVC6
                    ldd       ,S
                    decb
                    addd      4,S
                    tfr       D,X
                    clr       ,X
                    ldd       4,S
                    pshs      d
                    pshs      U
                    lbsr      MOVDNAME
                    leas      4,S
                    ldb       3,S
                    beq       CHGDEVC4
                    stu       FL.LINK-FL.SIZE,U
CHGDEVC4
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       FL.LINK,U
                    leau      FL.SIZE,U
                    ldb       3,S
                    incb
CHGDEVC5            stb       3,S
                    cmpb      #5
                    blt       CHGDEVC3
CHGDEVC6            lbsr      KILLOLAY
                    leas      38,S
                    puls      U,PC

CHGDEVNM            fcc       "Change device names"
                    fcb       LF,NUL

ENBLSOFF            clrb                          Flag to disable menu items on FILES menu
                    pshs      d
                    bsr       ENBLOPEN            Set OPEN item on FILES menu
                    bsr       ENLSTPRT            Set LIST & PRINT items on FILES menu
                    bsr       ENBLCOPY            Set COPY item on FILES menu
                    bra       ENBLSOFX

ENFREFLD            ldb       3,S
* Enable/Disable FREE, FOLDER & SORT on DISK menu
ENFREFL1            stb       ITM.FREE+MI.ENBL
                    stb       ITM.FLDR+MI.ENBL
                    stb       ITM.SORT+MI.ENBL
                    rts

* Enable/Disable OPEN item on FILES menu
ENBLOPEN            ldb       3,S
                    stb       ITM.OPEN+MI.ENBL
                    rts

* Enable/Disable LIST & PRINT items on FILES menu
ENLSTPRT            ldb       3,S
                    stb       ITM.LIST+MI.ENBL
                    stb       ITM.PRNT+MI.ENBL
                    rts

* Enable/Disable COPY item on FILES menu
ENBLCOPY            ldd       2,S
                    stb       ITM.COPY+MI.ENBL
                    pshs      d
                    bsr       ENSTRNDL            Deal with 3 other menu items
ENBLSOFX            leas      2,S
                    rts

* Enable/Disable STAT, RENAME & DELETE items on FILES menu
ENSTRNDL            ldb       3,S
                    stb       ITM.STAT+MI.ENBL
                    stb       ITM.RNAM+MI.ENBL
                    stb       ITM.DELT+MI.ENBL
                    rts

INITSCRN            bsr       FULLSCRN            Change working area to everything but menu/scroll bars
                    ldd       WNDWPATH            Get window path
                    pshs      d
                    lbsr      CLRSCRN             Send $0c to clear screen
                    leas      2,S                 Eat stack
                    lbsr      UPDTDEVC            Update device list at left in window ONLY
                    ldd       DEVICNOW            Get ptr to icon descriptor for current selected drive
                    beq       INITSCR1            No drive selected, return
                    lbsr      DRAWSCRN            Disable OPEN,COPY,LIST,PRINT,STAT,RENAME,DELETE options
INITSCR1            rts                           Wipe out icons, draw icons, etc., etc.

* Changed from 22 to 23 for NitrOS9
FULLSCRN            ldb       #23                 Save CWAREA height
                    pshs      d
                    ldd       WINDWSZX            CWAREA width=full width-2
                    subb      #2
                    pshs      d                   Save it
                    ldx       #1                  Save '1'
                    pshs      X
                    ldb       WNDWPATH+1          Get window path
                    pshs      d,X                 Save '1' again & path
                    lbsr      CWAREA              Change working area
                    leas      10,S
                    rts

* Draw border stuff for current dir, re-title dir bar
WRITDBAR
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    pshs      d
                    ldx       #39                 39,0 for 1st coord (relative to window inside border)
                    ldd       WNDWPATH
                    pshs      d,X
                    lbsr      MOUSOFF             Shut mouse off
                    lbsr      SETDPTR             Set draw ptr
                    ldb       #183                Draw to 39,183 (for 200 line screen)
                    std       4,S
                    lbsr      LINE
                    ldb       #8                  Y coord=8
                    std       4,s
                    lbsr      SETDPTR             Set draw ptr to 39,8
                    ldd       PIXELSWD            Get far right coord of current dir window
                    std       2,s
                    lbsr      LINE                Draw top line
                    ldb       WIPED               icons ok already?
                    lbeq      WIPICEXT            Yes, exit
* From here on draws the dir bar, question mark, and current directory.
*  Should flag to NOT do this if still in same dir.
                    ldd       #FNT.G8X8           8x8 graphic font
                    std       4,S
                    ldb       #GRP.FNT
                    std       2,S
                    lbsr      FONT                Set font to special GSHELL font set
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       4,S
                    ldb       #6
                    std       2,S
                    lbsr      GOTOXY              Text cursor to 6,0
                    lbsr      WBOX.BAR            Draw dir entry close box, and bars all the way across
                    ldb       #FNT.S8X8           Select 8x8 text font
                    std       4,S
                    ldb       #GRP.FNT
                    std       2,S
                    lbsr      FONT
                    ldb       #5                  Write out ' <?> ' for help box
                    stb       5,S
                    leax      <QUERY,PC
                    stx       2,S
                    lbsr      I.WRITE
                    ldb       #FNT.S6X8           6x8 text font
                    std       4,S
                    ldb       #GRP.FNT
                    std       2,S
                    lbsr      FONT                Text cursor to 10,0
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       4,S
                    ldb       #10
                    std       2,S
                    lbsr      GOTOXY
                    ldx       #DDIRNAME           Print dir name (as far as can fit)
                    stx       2,S
                    pshs      X
                    lbsr      STRLEN
                    puls      X
                    cmpd      #34                 If 320 screen, we can fit up to 34 chars
                    bls       WRITDBA1
                    tst       FLAG640W            Check if 640 screen, in which case we can fit up to 87 chars
                    beq       WRITDB05
                    cmpd      #87
                    bls       WRITDBA1
                    subd      #87
                    leax      D,X
                    ldd       #87
                    bra       WRITDB07

WRITDB05            subd      #34
                    leax      D,X
                    ldd       #34
WRITDB07            stx       2,S
WRITDBA1            std       4,S
                    lbsr      I.WRITE             Write out current directory name
                    ldd       #1
                    std       4,S
                    leax      <ONESPACE,PC        Add one space
                    stx       2,S
                    lbsr      I.WRITE
WIPICEXT            lbsr      INITMOUS            Re-init mouse
                    leas      6,S                 Eat stack & return
                    rts

QUERY               fcc       " <?> "

ONESPACE            fcc       " "

* memory allocation ala K&R
*  functionally identical to the C stuff from MicroWare
*   but 75% as much code and faster
*   calloc split out to save size
* Allocates memory in multiples of 256 bytes (pages)
* Exit:D=-1 If could not get the memory requested

MORECORE            ldd       2,S                 get nu   (Get # 4 byte units requested)
                    addd      #255                nu + NALLOC - 1  Round up to even 256 byte page
                    clrb                          divided by NALLOC
                    pshs      D                   rnu = result      Save # of 256 byte pages needed
                    aslb                          * sizeof(HEADER)    (Multiply by 4)
                    rola
                    aslb
                    rola
                    pshs      D                   Save #
                    lbsr      SBRK                Go allocate more data mem & clear it
                    leas      2,S                 Eat temp
                    puls      U                   get rnu into U (U=# 256 byte pages requested)
                    cmpd      #-1                 Did we get our requested data memory?
                    beq       ANRTS               No, return with D=-1
                    exg       D,U                 Swap # 256 byte pages & ptr to start of free data mem
                    std       2,U                 Save # 256 byte pages at 2,<start of free data mem>
                    leau      4,U                 up += 1 (Point to next entry after free data header)??
                    pshs      U                   Save ptr
                    bsr       FREE
                    leas      2,S                 waste up
                    ldu       ALLOCP,Y            return allocp (never 0)
ANRTS               rts

* Allocate memory within our data area
MALLOC              pshs      D,U                 Preserve regs
                    ldd       6,S                 Get # bytes to be allocated
                    addd      #3                  nbytes + sizeof(HEADER) - 1
                    ifne      H6309
                    lsrd                          div by sizeof(HEADER) (4 bytes)
                    lsrd
                    incd                          result+1
                    else
                    lsra
                    rorb
                    lsra
                    rorb
                    addd      #$0001
                    endc
                    std       ,S                  nunits = result (units allocated seems to be 4 byte chunks)
                    ldx       ALLOCP,Y            q = allocp  (Get current value)
                    bne       MALLOC1             if not 0    (If not zero, it has been initialized)
                    ldx       #BASE               q = &base   (Initialize it to BASE)
                    stx       ALLOCP,Y            allocp = q = &base
                    stx       BASE,Y              base.ptr = .... = &base  (BASE points to itself)
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       BASE+2,Y            base.size = 0   (it's size=0)
MALLOC1             ldu       ,X                  p = q->ptr   (Get ptr to current allocp (last mem entry?)
                    bra       MALLOC3

MALLOC2             tfr       U,X                 q = p
                    ldu       ,U                  p = p->ptr
MALLOC3             ldd       2,U                 Get size of last block allocated
                    cmpd      ,S                  Compare with # 4 byte blocks requested
                    blo       MALLOC6             if (p->size >= nunits)
                    bne       MALLOC4             if (p->size == nunits)
                    ldd       ,U
                    std       ,X                  q->ptr = p->ptr
                    bra       MALLOC5

MALLOC4             ldd       2,U                 p->size -= nunits
                    subd      ,S
                    std       2,U
                    aslb                          (char) p->size
                    rola
                    aslb
                    rola
                    leau      D,U                 p += (char) p->size
                    ldd       ,S                  p->size = nunits
                    std       2,U

MALLOC5             stx       ALLOCP,Y            allocp = q
                    leau      4,U                 p += 1 (header)
                    tfr       U,D                 set up for return
                    bra       MALLOC7

MALLOC6             cmpu      ALLOCP,Y            if (p == allocp)
                    bne       MALLOC2
                    lbsr      MORECORE            nunits above return addr (Get more data mem)
                    bne       MALLOC2             if (p = .... == 0) (Get mem failed?)
                    ifne      H6309
                    clrd                          set up zero for return
                    else
                    clra
                    clrb
                    endc
MALLOC7             leas      2,S
                    puls      U,PC

* Entry: 0-1,s    RTS address
*        2-3,s    Ptr of some sort (to data area after 4 byte header?)
*        D=# 256 byte pages requested
*        U=Ptr to header+4
FREE                pshs      D,U                 Save ??? ptr & #256 byte pages
                    ldu       6,S                 Get ptr to data start of allocated chunk?
                    leau      -4,U                p = ap - 1 (Point to star of chunk header?)
                    ldx       ALLOCP,Y            q = allocp  ???
                    bra       FREE3

FREE1               cmpx      ,X                  if (q >= q->ptr)
                    blo       FREE2
                    cmpu      ,S                  && (p > q
                    bhi       FREE4
                    cmpu      ,X                  || p < q->ptr)
                    blo       FREE4               break
FREE2               ldx       ,X                  q >= q->ptr
FREE3               stx       ,S                  q' = q         Save ??? (chunk header?)
                    cmpu      ,S                  if (p > q)     Is
                    bls       FREE1
                    cmpu      ,X                  && (p < q->ptr)
                    bhs       FREE1
FREE4               pshs      U                   stack p
                    ldd       2,U                 t$1 = p->size
                    aslb                          scale it
                    rola
                    aslb
                    rola
                    addd      ,S++                t$1 = p + p->size
                    cmpd      ,X                  if (p + p->size == q->ptr)
                    bne       FREE5
                    pshs      X                   save q
                    ldx       ,X                  q = q->ptr
                    ldd       2,X                 t$1 = q->ptr->size
                    puls      X                   recover q
                    addd      2,U                 t$1 = p->size + p->ptr->size
                    std       2,U                 p->size = t$1
                    ldd       [,X]                t$1 = q->ptr->ptr
                    bra       FREE6

FREE5               ldd       ,X                  t$1 = q->ptr
FREE6               std       ,U                  p->ptr = t$1
                    ldd       2,X                 t$1 = q->size
                    aslb                          scale it
                    rola
                    aslb
                    rola
                    addd      ,S                  t$1 = q + q->size
*NOTE 6309:CMPR D,U
                    pshs      D
                    cmpu      ,S++                if (q + q->size == p)
                    bne       FREE7
                    ldd       2,X                 t$1 = q->size
                    addd      2,U                 t$1 += p->size
                    std       2,X                 q->size = t$1
                    ldd       ,U                  t$1 = p->ptr
                    std       ,X                  q->ptr = t$1
                    bra       FREE8

FREE7               stu       ,X                  q->ptr = p
FREE8               stx       ALLOCP,Y            allocp = q
                    bra       MALLOC7

NMLNKLOD            pshs      U
                    leas      -4,S
                    leax      ,S
                    leau      2,S
                    pshs      X,U
                    ldu       12,S
                    ldd       GD.MNAME,U
                    pshs      D
                    bsr       F.NMLINK
                    std       -2,S
                    bne       LINLOA1
                    bsr       F.NMLOAD
                    std       -2,S
                    bne       LINLOA1
                    leas      6,S
                    bra       LINLOA3

LINLOA1             leas      6,S
                    ldb       1,S
                    andb      #$F0
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    stb       GD.MTYPE,U
                    ldb       1,S
                    andb      #$0F
                    stb       GD.MLANG,U
                    ldd       GD.MEMSZ,U
                    bne       LINLOA3
                    ldd       2,S
                    tstb
                    beq       LINLOA2
                    inca
LINLOA2             tfr       A,B
                    clra
                    std       GD.MEMSZ,U
                    ldb       #1
LINLOA3             leas      4,S
                    puls      U,PC

F.NMLOAD            pshs      X,Y
                    ldx       6,S
                    clra
                    os9       F$NMLOAD
                    bra       F.NML1

F.NMLINK            pshs      X,Y
                    ldx       6,S
                    bsr       SKPSLASH
                    clra
                    os9       F$NMLINK
F.NML1              bcc       F.NML2
                    puls      X,Y
                    stb       ERRNO+1,Y
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    rts

F.NML2              sty       [10,S]
                    tfr       A,B
                    clra
                    std       [8,S]
                    ldb       #1
                    puls      X,Y,PC

F.UNLOAD            ldx       2,S
                    bsr       SKPSLASH
                    clra
                    os9       F$UNLOAD
                    rts

SKPSLASH            pshs      X
                    lbsr      STREND1
SKPSLAS1            cmpx      ,S
                    ble       SKPSLAS2
                    ldb       ,-X
                    cmpb      #'/
                    bne       SKPSLAS1
                    leax      1,X
                    stx       ,S
SKPSLAS2            puls      X
                    rts

KILLPBUF            clrb
                    pshs      D
                    ldx       PRCIDNUM
                    ldd       WNDWPATH
                    pshs      D,X
                    lbsr      KILBUF
                    leas      6,S
                    rts

* NOTE: ONLY CALLED FROM
* Wait for forked program to die (or wait for signal)
* Entry: [,x] is a ptr to a 16 bit area to save the child's exit code
* Exit:  [,x] child's exit code
*        D=0 - if [,x] ptr was 0
*   else D=   Child's proces #
F.WAIT
                    ifne      H6309
                    clrd                          Wait for signal
                    else
                    clra
                    clrb
                    endc
                    os9       F$WAIT
                    bcs       OS9ERR2             Error, save error code & return (no child process)
                    ldx       2,S                 Get ptr to ???
                    beq       F.WAITX             If 0, exit with child ID process #=0
                    stb       1,X                 Save child's exit code in pointed to area
                    clr       ,X
F.WAITX             tfr       A,B                 D=Deceased child process's ID #
                    clra
                    rts

F.FORK              pshs      Y,U
                    ldx       6,S
                    ldy       8,S
                    ldu       10,S
                    lda       13,S
                    ora       15,S
                    ldb       17,S
                    os9       F$FORK
                    puls      Y,U
                    bcs       OS9ERR2
                    tfr       A,B
                    clra
                    rts

* Raw read
I.READ              pshs      Y                   Save Y
                    ldx       6,S                 Get ptr to buffer to read into
                    lda       5,S                 Get file path
                    ldy       8,S                 Get size of read
                    os9       I$READ              Read data
READ1               bcc       WRITE10
                    cmpb      #E$EOF              EOF error?
                    bne       WRITERR             No, report error
                    ifne      H6309
                    clrd                          If EOF error, report 0 bytes read
                    else
                    clra
                    clrb
                    endc
                    puls      Y,PC

* Read line: Exits with D=# bytes read
I.READLN            pshs      Y
                    lda       5,S
                    ldx       6,S
                    ldy       8,S
                    os9       I$READLN
                    bra       READ1

I.WRITE             pshs      Y
                    ldy       8,S
                    beq       WRITE10
                    lda       5,S
                    ldx       6,S
                    os9       I$WRITE
WRITE1              bcc       WRITE10
WRITERR             puls      Y
OS9ERR2             lbra      OS9ERR

WRITE10             tfr       Y,D
                    puls      Y,PC

* Perform WritLn call
* Entry: 0-1,s  =RTS address
*        2-3,s  =Path to write to (use only B)
*        4-5,s  =Ptr to text to write
*        6-7,s  =Length to write
I.WRITLN            pshs      Y
                    ldy       8,S
                    beq       WRITE10
                    lda       5,S
                    ldx       6,S
                    os9       I$WRITLN
                    bra       WRITE1

I.DUP               os9       I$DUP
                    bra       ERRTEST

I.OPEN2             ldx       2,S
                    lda       5,S
I.OPEN              os9       I$OPEN
ERRTEST             bcs       OS9ERR2
                    tfr       A,B
                    clra
                    rts

I.CLOSE             lda       3,S
                    os9       I$CLOSE
                    bra       I.SYSRET

I.MAKDIR            ldx       2,S
                    ldb       5,S
                    os9       I$MAKDIR
                    bra       I.SYSRET

I.DELETE            ldx       2,S
                    os9       I$DELETE
I.SYSRET            lbra      SYSRET

* Get String length - terminated by NUL (CHR$(0)) char
* Entry: 0-1,s is RTS address
*        2-3,s is the ptr to the string to check
* Exit:  X=Ptr to end of string (not including NUL)
*        D=Length of string
STRLEN              ldx       2,S                 Get ptr to string we are checking length of
STRLEN1             ldb       ,X+                 Get char
                    bne       STRLEN1             Not end of string, keep checking
                    leax      -1,X                Found it, point to last char
                    tfr       X,D
                    subd      2,S                 D=length of string
                    rts

* Get string end - terminated by NUL char
* Entry: [,s] is the ptr to the string to check
* Exit: D=Ptr to end of string (not including NUL)
STREND              ldx       2,S
STREND1             ldb       ,X+
                    bne       STREND1
                    leax      -1,X
                    tfr       X,D
                    rts

STRCPY              pshs      X,U
                    ldu       6,S
STRCAT2             ldx       8,S
STRCPY1             ldb       ,X+
                    stb       ,U+
                    bne       STRCPY1
                    ldd       6,S
                    puls      X,U,PC

STRCAT              pshs      X,U
                    ldu       6,S
STRCAT1             ldb       ,U+
                    bne       STRCAT1
                    leau      -1,U
                    bra       STRCAT2

* Compare two strings
* Exit: D=0 if they are the same
*       D=-1 if they are not the same
STRCMP              pshs      X,U                 Save regs
                    ldu       6,S                 Get ptr to 1st string
                    beq       STRCMP2             No string, exit with <>
                    ldx       8,S                 Get ptr to 2nd string
                    beq       STRCMP2             No string, exit with <>
STRCMP1             ldb       ,U+                 Get char from 1st string
                    cmpb      ,X+                 Same as char from 2nd string?
                    bne       STRCMP2             No, exit with <>
                    tstb                          Same, is it an end of string marker?
                    bne       STRCMP1             No, continue comparing
                    clra                          Exit with '='
                    puls      X,U,PC

* Flag not equal strings
STRCMP2             ldd       #-1
                    puls      X,U,PC

* String compare with maximum length of strings
* Exit: D=-1 if they are <>
*       D=0  if they are =
STRNCMP             pshs      X,U
                    ldu       6,S                 Get ptr to string 1
                    beq       STRNCMP4
                    ldx       8,S                 Get ptr to string 2
                    beq       STRNCMP4
                    lda       11,S                Get maximum size to compare
                    beq       STRNCMP2            If 0, exit with =
STRNCMP1            deca                          Done max length?
                    blt       STRNCMP3            Yes, process
                    ldb       ,U+                 Get char
                    cmpb      ,X+                 Same as in 2nd string?
                    bne       STRNCMP4            No,  exit with <>
                    tstb                          End of string early?
                    bne       STRNCMP1            No, continue comparing
STRNCMP2
                    ifne      H6309
                    clrd                          Exit with =
                    else
                    clra
                    clrb
                    endc
                    puls      X,U,PC

* If done up to max length, compare last chars of each string
* NOTE: THIS LOOKS LIKE THE LDB/CMPB/BEQ IS USELESS??? SHOULD JUST EXIT
*   WITH D=0???
STRNCMP3            ldb       ,-U                 If last 2 chars matched, exit with =
                    cmpb      ,-X
                    beq       STRNCMP2
STRNCMP4            ldd       #-1                 Exit with <>
STRNCMPX            puls      X,U,PC

STRHCPY             pshs      U
                    ldu       4,S
                    ldx       6,S
STRHCPY1            ldb       ,X+
                    stb       ,U+
                    bgt       STRHCPY1
                    andb      #$7F
                    stb       -1,U
                    clrb
                    stb       ,U
                    ldd       4,S
                    puls      U,PC

* Copy B bytes from X to Y
* NOTE: CHANGE TO TFM!
STRNCPY             pshs      X,U
                    ldu       6,S
                    ldx       8,S
                    ldb       11,S
STRNCPY1            lda       ,X+
                    sta       ,U+
                    decb
                    bne       STRNCPY1
                    puls      X,U,PC

* Allocate more memory from our remainding data memory, or get more data mem-
* ory and allocate from that
* Exit:D=-1 if could not get memory
*      or D=Ptr to start of free data memory
SBRK                ldd       MEMEND,Y            Get end of data memory ptr
                    pshs      D                   Save it
                    ldd       4,S                 Get # bytes requested
                    cmpd      SPARE,Y             Will that fit in what we have left right now?
* following should be BLO
                    bcs       SBRK20              Yes, skip ahead
                    addd      MEMEND,Y            Calculate what total data area size should now be
                    bcs       SBRK05              >64k, too big to fit in process space, exit with error
                    pshs      Y                   Preserve Y
                    os9       F$MEM               Attempt to change data area size to D bytes
                    tfr       Y,D                 Move new end of data mem address to D
                    puls      Y                   Restore Y
                    bcc       SBRK10              No error on F$MEM call, continue
SBRK05              ldd       #-1                 Eat stack & exit with error flag set
                    leas      2,S
                    rts

* Extra memory requested was succesful
SBRK10              std       MEMEND,Y            Save new end of data mem ptr
                    addd      SPARE,Y             Add to amount of free data mem before request came in
                    subd      ,S                  Subtract original end of data mem ptr
                    std       SPARE,Y             Save new amount of spare data mem
SBRK20              leas      2,S
                    ldd       SPARE,Y             Get amount of spare data mem
                    pshs      D
                    subd      4,S                 Subtract the amount of mem requested
                    std       SPARE,Y             Save new amount of spare data mem
                    ldd       MEMEND,Y            Get end of data mem ptr
* NOTE 6309:SUBR, AND KEEP SIZE OF SPARE MEM. CHANGE LOOP BELOW TO TFM
                    subd      ,S++                Calculate start address of free data mem
                    pshs      D                   Save it
                    clra                          Zero byte
                    ldx       ,S                  X=start of free data mem
SBRK30              sta       ,X+                 Clear out all free data mem
                    cmpx      MEMEND,Y
                    bcs       SBRK30
                    puls      D,PC                Get ptr to start of data mem & return with it

GT.READY            lda       3,S
                    ldb       #SS.READY
                    os9       I$GETSTT
                    bcs       OS9ERR3
                    clra
                    rts

* setup mouse parms - NOTE: should embed elsewhere  - only called once.
* In routine: 0-1,s = Preserved Y
*             2-3,s = RTS address
*             4-5,s = Path to window to read mouse from
*             6-7,s = Mouse sampling rate
*             8-9,s = Mouse button timeout
*            10-11,s= Auto follow mouse flag
ST.MOUSE            pshs      Y                   Preserve Y
                    lda       7,S                 Get # clock ticks between mouse reads
                    ldb       9,S                 Get mouse button timeout value
                    tfr       D,X
                    clra                          Get auto-follow flag
                    ldb       11,S
                    tfr       D,Y
                    lda       5,S                 Get path for window mouse is on
                    ldb       #SS.MOUSE           Setup mouse parms
                    os9       I$SETSTT
                    puls      Y                   Restore Y & return
                    bra       SYSRET2

GT.MOUSE            lda       3,S
                    ldb       #SS.MOUSE
                    ldx       4,S
                    pshs      Y
                    ldy       #0
                    os9       I$GETSTT
                    puls      Y
                    bra       SYSRET2

ST.SSIG             lda       3,S
                    ldb       #SS.SSIG
                    ldx       4,S
                    os9       I$SETSTT
                    bra       SYSRET2

ST.RELEA            lda       3,S
                    ldb       #SS.RELEA
                    os9       I$SETSTT
SYSRET2             lbra      SYSRET

OS9ERR3             lbcs      OS9ERR
                    pshs      A
                    sex
                    std       [5,S]
                    puls      B
                    clra
                    rts

* Get current screen size in 8x8 text chars
* Entry: 0-1,s   = RTS address
*        2-3,s   = 16 bit path # (only use 3,s)
*        4-5,s   = Ptr to where to store X size
*        6-7,s   = Ptr to where to store Y size
GT.SCSIZ            lda       3,S                 Get path to screen
                    ldb       #SS.SCSIZ
                    pshs      X,Y                 Preserve regs
                    os9       I$GETSTT
                    bcs       SCSIZERR
                    stx       [8,S]               Save X size (by pointer)
                    sty       [10,S]              Save Y size (by pointer)
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    bra       SCSIZEXT

SCSIZERR            ldy       2,S                 Get data area pointer back
                    clra
                    std       ERRNO,Y             Save error code
                    ldd       #-1                 Flag error & return
SCSIZEXT            puls      X,Y
                    rts

ST.SBAR             lda       3,S
                    ldb       #SS.SBAR
                    ldx       4,S
                    pshs      Y
                    ldy       8,S
                    os9       I$SETSTT
                    puls      Y
                    bra       SYSRET2

ST.MSSIG            lda       3,S
                    ldb       #SS.MSSIG
                    ldx       4,S
                    os9       I$SETSTT
                    bra       SYSRET2

* Do WINDINT window style
* Entry: 0-1,s   =RTS address
*        2-3,s   =Window path (only use B)
*        4-5,s   =window type (WT.*)
*        6-7,s   =Ptr to window/menu data (for framed windows only)
ST.WNSET            lda       3,S                 Get path
                    ldb       #SS.WNSET
                    pshs      Y
                    ldy       6,S                 Get window type
                    ldx       8,S                 Get ptr for framed window data
                    os9       I$SETSTT            Convert current window
                    puls      Y
                    bra       SYSRET2

* Entry: all parms for DWSET are on stack, in order-but with 2 bytes/parm
*    whether it needs it or not!
* 0-1,s: RTS address
* 2-3,s: path # to window
* 4-5,s: screen type
* etc. for other DWSET parms
DWSET               ldd       #$1B20              Device window Set
                    bsr       DW.OWSET            Set up GFXBUF to contain full display code sequence for DWSET
                    ldb       #9                  # of bytes to write in DWSET sequence
                    tst       5,S                 Check low byte of window type (actual type)
                    ble       DOWSETX             If current displayed or current processes screen, don't bother with border
                    incb                          If positive, bump # bytes up to 10 (to cover border color)
DOWSETX             bra       GFXWR3              Go write it out and return from there

OWSET               ldd       #$1B22
                    bsr       DW.OWSET
                    ldb       #9
                    bra       DOWSETX

DW.OWSET            ldx       #GFXBUF             Place to put actual command bytes for DWSET
                    std       ,X++                Save command sequence
                    lda       7,S                 Get screen type (low byte only)
                    ldb       9,S
                    std       ,X++                Get start, end ,etc. parms & append them
                    lda       11,S
                    ldb       13,S
                    std       ,X++
                    lda       15,S
                    ldb       17,S
                    std       ,X++
                    lda       19,S
                    ldb       21,S                Get border color (may not be used)
                    std       ,X
                    rts

DWEND               ldd       #$1B24
                    bra       OUT2

OWEND               ldd       #$1B23
                    bra       OUT2

SELECT              ldd       #$1B21

OUT2                std       GFXBUF,Y
                    ldb       #2
                    bra       GFXWR3

CWAREA              ldd       #$1B25
                    ldx       #GFXBUF
                    std       ,X++
                    lda       5,S
                    ldb       7,S
                    std       ,X++
                    lda       9,S
                    ldb       11,S
                    std       ,X
                    ldb       #6
                    bra       GFXWR3

GCSET               ldd       #$1B39
                    bra       OUT4

FONT                ldd       #$1B3A
                    bra       OUT4

KILBUF              ldd       #$1B2A
OUT4                ldx       #GFXBUF
                    std       ,X++
                    lda       5,S
                    ldb       7,S
                    std       ,X
                    ldb       #4
GFXWR3              lbra      GFXWR

SCALESW             ldb       #$35
                    bra       OUT3

DWPROTSW            ldb       #$36
                    bra       OUT3

FCOLOR              ldb       #$32
                    bra       OUT3

LSET                ldb       #$2F
OUT3                lda       #$1B
                    std       GFXBUF,Y
                    ldb       5,S
                    stb       GFXBUF+2,Y
                    ldb       #3
                    bra       GFXWR3

LINE                ldb       #$44
                    bra       OUT6

LINEM               ldb       #$46
                    bra       OUT6

RLINE               ldb       #$45
                    bra       OUT6

BOX                 ldb       #$48
                    bra       OUT6

RBOX                ldb       #$49
                    bra       OUT6

SETDPTR             ldb       #$40
OUT6                lda       #$1B
                    ldx       #GFXBUF
                    std       ,X++
                    ldd       4,S
                    std       ,X++
                    ldd       6,S
                    std       ,X
                    ldb       #6
                    bra       GFXWR

PUTBLK              ldx       #GFXBUF
                    ldd       #$1B2D
                    std       ,X++
                    lda       5,S
                    ldb       7,S
                    std       ,X++
                    ldd       8,S
                    std       ,X++
                    ldd       10,S
                    std       ,X
                    ldb       #8
                    bra       GFXWR

FFILL               ldd       #$1B4F
                    std       GFXBUF,Y
                    ldb       #2
                    bra       GFXWR

GPLOAD              ldx       #GFXBUF
                    ldd       #$1B2B
                    std       ,X++
                    lda       5,S
                    ldb       7,S
                    std       ,X++
                    lda       9,S
                    sta       ,X+
                    ldd       10,S
                    std       ,X++
                    ldd       12,S
                    std       ,X++
                    ldd       14,S
                    std       ,X
                    ldd       2,S
                    pshs      D
                    ldb       #11
                    bsr       GFXWR
                    leas      2,S
                    ldx       16,S
                    pshs      Y
                    ldy       16,S
                    lda       5,S
                    os9       I$WRITE
                    bcs       GFXERR
                    puls      Y,PC


* Entry:B= # bytes to write
GFXWR               clra                          D=B
                    ldx       #GFXBUF             Point to buffer that holds graphics commands to execute
                    pshs      Y
                    tfr       D,Y                 Length of command sequence to write
                    lda       5,S                 Get path # to write to
                    os9       I$WRITE             Send gfx command
                    puls      Y
                    bcs       GFXERR
                    clra
                    clrb
                    rts

GFXERR              clra
                    std       ERRNO,Y
                    ldd       #-1
                    rts

* Convert ASCII # to 16 bit signed integer
* NOTE:WILL DO WEIRD THINGS IF RESULT IS >65535 (WRAPS AT 16 BIT)
* Works by saving neg/pos flag, and then going from left to right, multiplying
*  cumulative result by 10 each time a new digit is found, until non-digit
*  found. Also eats leading spaces & tabs.
* Entry: ptr to ASCII buffer on stack
* Exit: D=signed 16 bit value
ATOI                pshs      U                   Preserve U
                    ldu       4,S                 Get ptr to text to convert
                    ifne      H6309
                    clrd                          Clear carry, and default # to 0
                    else
                    clra
                    clrb
                    endc
                    pshs      cc,d,dp             CC=storage for current ASC char, dp=sign, D=current result
ATOI1               ldb       ,U+                 Get 1st ascii character
                    stb       ,S                  Save it
                    cmpb      #SPACE              Is it a space?
                    beq       ATOI1               Yes, skip that char
                    cmpb      #HT                 Is it a TAB char?
                    beq       ATOI1               Yes, skip that char
                    cmpb      #'-                 Is it a negative sign?
                    bne       ATOI2               No, process character
                    ldb       #1                  Flag that we are working with a negative #
                    bra       ATOI3

ATOI2               clrb                          Flag that it is a positive #
ATOI3               stb       3,S                 Save positive/negative flag
                    ldb       ,S                  Get char again
                    cmpb      #'-                 Was it a negative sign?
                    beq       ATOI5               Yes, go onto next character
                    cmpb      #'+                 Was it a plus sign?
                    bne       ATOI6               No, go check if it was a numeric char
                    bra       ATOI5               +, skip to next char
* CHANGE MAIN LOOP TO PRE SUBTRACT #$30 INSTEAD OF CMP 1ST WHEN CHECKING
*   RANGE (?)

ATOI4               ldd       1,S                 Get current result (so far)
                    ifne      H6309
                    muld      #10                 Bump up by one order of magnitude (Since on next digit)
                    ldb       ,S                  Get original numeric char
                    sex                           make 16 bit (note: still ascii version!)
                    addr      w,d                 Add to current base digit value (1,10,100,1000,10000)
                    else
                    pshs      x,y,u
                    ldx       #10
                    lbsr      MUL16
                    ldb       6,s
                    sex
                    pshs      u
                    addd      ,s++
                    puls      x,y,u
                    endc
                    std       1,S                 Save current result
ATOI5               ldb       ,U+                 Get next char from ASCII buffer
ATOI6               subb      #$30                Convert to binary
                    stb       ,S                  Save it
                    blt       ATOI65              Below '0', stop conversion
                    cmpb      #9                  Above '9'?
                    bls       ATOI4               No, numeric, go process
                    cmpb      #'0                 Below a numeric char?
                    blo       ATOI65              Yes, skip ahead
                    cmpb      #'9                 Above a numeric char?
                    bls       ATOI4               No, a numeric, go process
* Non numeric char stops conversion
ATOI65              ldd       1,S                 Get current result
                    tst       3,S                 Was there a negative sign?
                    beq       ATOI8               No, done
                    ifne      H6309
                    negd
                    else
                    nega
                    negb
                    sbca      #$00
                    endc
ATOI8               leas      4,S                 Eat temp vars
                    puls      U,PC                Restore U & exit

CCMOD               leax      <CCDIV,PC
                    stx       HANDLER,Y
                    clr       NSIGN,Y
                    tst       2,S
                    bpl       CCMOD1
                    inc       NSIGN,Y
CCMOD1              subd      #0
                    bne       CCMOD2
                    puls      X
                    ldd       ,S++
                    jmp       ,X

CCMOD2              ldx       2,S
                    pshs      X
                    jsr       [HANDLER,Y]
                    ldd       ,S
                    std       2,S
                    tfr       X,D
                    tst       NSIGN,Y
                    beq       CCMODX
                    ifne      H6309
                    negd
                    else
                    nega
                    negb
                    sbca      #$00
                    endc
CCMODX              std       ,S++
                    rts

DIVIDE.0            puls      D
                    std       ,S
                    ldd       #45
                    ifne      H6309
                    bra       RPTERR
                    else
                    lbra      RPTERR
                    endc

CCDIV               subd      #0
                    beq       DIVIDE.0
                    pshs      D
                    leas      -2,S
                    clr       ,S
                    clr       1,S
                    tsta
                    bpl       CCDIV1
                    ifne      H6309
                    negd
                    else
                    nega
                    negb
                    sbca      #$00
                    endc
                    inc       1,S
                    std       2,S
CCDIV1              ldd       6,S
                    bpl       CCDIV2
                    ifne      H6309
                    negd
                    else
                    nega
                    negb
                    sbca      #$00
                    endc
                    com       1,S
                    std       6,S
CCDIV2              lda       #1
CCDIV3              inca
                    asl       3,S
                    rol       2,S
                    bpl       CCDIV3
                    sta       ,S
                    ldd       6,S
                    clr       6,S
                    clr       7,S
CCDIV4              subd      2,S
                    bcc       CCDIV5
                    addd      2,S
                    andcc     #^Carry
                    bra       CCDIV6

CCDIV5              orcc      #Carry
CCDIV6              rol       7,S
                    rol       6,S
                    lsr       2,S
                    ror       3,S
                    dec       ,S
                    bne       CCDIV4
                    std       2,S
                    tst       1,S
                    beq       CCDIV7
                    ldd       6,S
                    ifne      H6309
                    negd
                    else
                    nega
                    negb
                    sbca      #$00
                    endc
                    std       6,S
CCDIV7              ldx       4,S
                    ldd       6,S
                    std       4,S
                    stx       6,S
                    ldx       2,S
                    ldd       4,S
                    leas      6,S
                    rts

CCASR               tstb
                    beq       CCSEXIT
CCASR1              asr       2,S
                    ror       3,S
                    decb
                    bne       CCASR1
CCSEXIT             ldd       2,S
                    pshs      D
                    ldd       2,S
                    std       4,S
                    ldd       ,S
                    leas      4,S
                    rts

RPTERR              std       ERRNO,Y
                    pshs      B,Y
                    os9       F$ID
                    puls      B,Y
                    os9       F$SEND
                    rts

* Save error # & set flag
OS9ERR              clra
                    std       ERRNO,Y
                    ldd       #-1
                    rts

SYSRET              bcs       OS9ERR
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    rts

EXIT
F.EXIT              ldd       2,S
                    os9       F$EXIT

* Quick hack to copy new 4 color icon stuff into buffer used by GPLOAD routine
* Entry: X=Source buffer of icon
*        B=# bytes to copy
CopyIcon            pshs      u
                    ldu       #ICONBUFR           Point to icon build buffer
CpyIc               lda       ,x+
                    sta       ,u+
                    decb
                    bne       CpyIc
                    puls      u,pc

* Reset fore/back colors for Menu bar updates
MenuClr             pshs      d,x,y
                    leax      <MenuColr,pc
                    bra       WritColr

* Reset fore/back colors for non-Menu bar updates
RegClr              pshs      d,x,y
                    leax      <RegColr,pc
WritColr            ldy       #6
                    lda       <WNDWPATH+1         Get window path
                    os9       I$Write
                    puls      d,x,y,pc

* 16 bit multiply
                    ifeq      H6309
MUL16               pshs      d,x,y,u             XmulD returns Y&U
                    clr       4,s
                    lda       3,s
                    mul
                    std       6,s
                    ldd       1,s
                    mul
                    addb      6,s
                    adca      #0
                    std       5,s
                    ldb       ,s
                    lda       3,s
                    mul
                    addd      5,s
                    std       5,s
                    bcc       MUL16b
                    inc       4,s
MUL16b              lda       ,s
                    ldb       2,s
                    mul
                    addd      4,s
                    clra
                    std       4,s
                    puls      d,x,y,u,pc
                    endc

MenuColr            fcb       $1b,$32,2,$1b,$33,0
RegColr             fcb       $1b,$32,0,$1b,$33,2

* New 4 color disk drive icon 24x12
driveicn            fcb       255,255,255,255,255,253
                    fcb       234,170,170,170,170,169
                    fcb       234,170,170,170,170,169
                    fcb       234,170,170,170,170,169
                    fcb       234,170,85,85,170,169
                    fcb       233,85,64,1,85,233
                    fcb       235,255,234,171,255,233
                    fcb       234,170,255,255,170,169
                    fcb       234,170,170,170,175,233
                    fcb       229,106,170,170,173,105
                    fcb       234,170,170,170,170,169
                    fcb       213,85,85,85,85,85

* New trash can icon 24x24 (original GSHELL 1.26F)
*trashicn fcb   $AA,$AA,$AA,$AA,$AA,$AA
*         fcb   $AA,$80,$00,$00,$AA,$AA
*         fcb   $A0,$05,$55,$9B,$02,$AA
*         fcb   $81,$11,$56,$66,$BC,$AA
*         fcb   $04,$55,$59,$9A,$EF,$2A
*         fcb   $01,$11,$66,$A7,$BC,$2A
*         fcb   $20,$05,$59,$9F,$02,$2A
*         fcb   $2A,$80,$00,$00,$AA,$2A
*         fcb   $2A,$AA,$AA,$AA,$AA,$2A
*         fcb   $28,$0A,$AA,$A8,$0A,$2A
*         fcb   $23,$D2,$80,$A3,$D2,$2A
*         fcb   $23,$92,$3D,$23,$92,$2A
*         fcb   $23,$92,$39,$23,$92,$2A
*         fcb   $23,$92,$39,$23,$92,$2A
*         fcb   $23,$92,$39,$23,$92,$2A
*         fcb   $23,$92,$39,$23,$92,$2A
*         fcb   $23,$92,$39,$23,$92,$2A
*         fcb   $23,$92,$39,$23,$92,$2A
*         fcb   $23,$92,$39,$23,$92,$2A
*         fcb   $23,$92,$39,$23,$92,$2A
*         fcb   $28,$0A,$39,$28,$0A,$16
*         fcb   $82,$AA,$80,$AA,$A0,$55
*         fcb   $A8,$0A,$AA,$A8,$05,$55
*         fcb   $AA,$A0,$00,$01,$55,$86

* Proposed new one from Nick Marentes version 2
trashicn            fcb       $AA,$AA,$80,$0A,$AA,$AA
                    fcb       $AA,$AA,$1B,$52,$AA,$AA
                    fcb       $AA,$00,$00,$00,$00,$AA
                    fcb       $A8,$56,$BF,$A5,$55,$2A
                    fcb       $A8,$00,$00,$00,$00,$2A
                    fcb       $AA,$16,$BF,$A9,$54,$AA
                    fcb       $AA,$16,$BF,$A9,$54,$AA
                    fcb       $AA,$11,$87,$91,$44,$AA
                    fcb       $AA,$11,$87,$91,$44,$AA
                    fcb       $AA,$11,$87,$91,$44,$AA
                    fcb       $AA,$11,$87,$91,$44,$AA
                    fcb       $AA,$11,$87,$91,$44,$AA
                    fcb       $AA,$11,$87,$91,$44,$AA
                    fcb       $AA,$11,$87,$91,$44,$AA
                    fcb       $AA,$11,$87,$91,$44,$AA
                    fcb       $AA,$11,$87,$91,$44,$AA
                    fcb       $AA,$11,$87,$91,$44,$AA
                    fcb       $AA,$11,$87,$91,$44,$AA
                    fcb       $AA,$11,$87,$91,$44,$AA
                    fcb       $AA,$16,$BF,$A9,$54,$AA
                    fcb       $AA,$16,$BF,$A9,$54,$AA
                    fcb       $AA,$80,$00,$00,$02,$AA
                    fcb       $AA,$AA,$AA,$AA,$AA,$AA
                    fcb       $AA,$AA,$AA,$AA,$AA,$AA

* New 4 color EXECUTABLE icon 24x24
execicon            fcb       255,255,255,255,255,253
                    fcb       228,169,21,100,74,165
                    fcb       228,169,20,161,10,165
                    fcb       213,85,85,85,85,85
                    fcb       253,170,170,170,170,253
                    fcb       233,145,170,18,170,201
                    fcb       233,132,170,70,170,193
                    fcb       233,145,170,18,170,213
                    fcb       233,170,170,170,170,233
                    fcb       233,148,106,20,170,253
                    fcb       233,145,106,80,170,233
                    fcb       233,170,170,170,170,213
                    fcb       233,170,170,170,170,233
                    fcb       233,157,234,170,170,233
                    fcb       233,180,106,170,170,233
                    fcb       233,131,106,170,170,233
                    fcb       233,170,170,170,170,213
                    fcb       233,129,42,170,170,193
                    fcb       233,132,42,170,170,209
                    fcb       213,170,170,170,170,213
                    fcb       255,255,255,255,255,253
                    fcb       193,174,106,170,170,65
                    fcb       225,174,106,170,170,73
                    fcb       85,85,85,85,85,85

* New 4 color Folder icon 24x24
foldricn            fcb       170,130,170,170,170,170
                    fcb       170,60,10,170,170,170
                    fcb       170,55,240,170,170,170
                    fcb       1,225,124,170,170,170
                    fcb       60,42,168,10,170,170
                    fcb       63,192,171,240,42,170
                    fcb       62,191,2,175,192,170
                    fcb       58,170,252,10,191,2
                    fcb       58,170,171,240,42,252
                    fcb       58,170,170,175,194,160
                    fcb       58,170,170,170,146,164
                    fcb       58,170,170,170,145,148
                    fcb       58,170,170,170,146,100
                    fcb       58,170,170,170,145,148
                    fcb       58,170,170,170,146,82
                    fcb       58,170,170,170,164,146
                    fcb       58,170,170,170,164,82
                    fcb       21,170,170,170,164,146
                    fcb       128,86,170,170,164,82
                    fcb       170,1,90,170,164,10
                    fcb       170,168,5,106,165,10
                    fcb       170,170,160,21,153,10
                    fcb       170,170,170,128,85,10
                    fcb       170,170,170,170,0,10

* Text Icon 24x24
txticon             fcb       0,0,0,0,0,10
                    fcb       63,255,255,253,85,70
                    fcb       61,183,229,253,154,134
                    fcb       61,119,109,125,230,134
                    fcb       63,255,255,253,249,134
                    fcb       63,255,255,253,190,70
                    fcb       61,191,246,253,85,70
                    fcb       62,223,155,191,255,198
                    fcb       63,255,255,255,255,198
                    fcb       63,255,255,255,255,198
                    fcb       62,109,253,215,251,198
                    fcb       63,126,122,219,185,198
                    fcb       63,255,255,255,255,198
                    fcb       63,255,255,255,255,198
                    fcb       62,254,254,255,251,198
                    fcb       62,125,110,125,249,198
                    fcb       63,255,255,255,255,198
                    fcb       63,255,255,255,255,198
                    fcb       62,189,127,231,151,198
                    fcb       62,255,175,223,251,198
                    fcb       63,255,255,255,255,198
                    fcb       0,0,0,0,0,6
                    fcb       149,85,85,85,85,86
                    fcb       170,170,170,170,170,170

* NEW - printer icon (24x15) (Gshell 1.26F)
*prntricn fcb   170,168,0,2,170,170
*         fcb   170,168,255,200,170,170
*         fcb   170,168,195,205,42,170
*         fcb   170,168,255,192,42,170
*         fcb   170,168,192,255,42,170
*         fcb   170,168,255,195,42,170
*         fcb   170,128,192,255,2,170
*         fcb   170,136,255,255,34,170
*         fcb   170,0,0,0,0,170
*         fcb   168,166,102,102,106,42
*         fcb   168,170,170,170,130,42
*         fcb   168,170,170,170,170,42
*         fcb   168,0,0,0,0,42
*         fcb   170,38,102,102,104,170
*         fcb   170,128,0,0,2,170
* New printer icon (24x15) - Nick for EOU
prntricn            fcb       170,168,0,2,170,170
                    fcb       170,168,255,200,170,170
                    fcb       170,168,195,205,42,170
                    fcb       170,168,255,192,42,170
                    fcb       170,168,192,255,42,170
                    fcb       170,168,255,195,42,170
                    fcb       170,128,192,255,2,170
                    fcb       170,136,255,255,34,170
                    fcb       170,0,0,0,0,170
                    fcb       $A8,$AA,$AA,$AA,$AA,$2A
                    fcb       168,170,170,170,130,42
                    fcb       168,170,170,170,170,42
                    fcb       168,0,0,0,0,42
                    fcb       $AA,$2A,$AA,$AA,$A8,$AA
                    fcb       170,128,0,0,2,170

ETEXT               fdb       INTCOUNT-DPAGDATA

DPAGDATA            fcb       $FF                 WIPED  On initialization, we have to refresh DIR screen
                    fdb       6                   DEFWTYPE
                    fdb       64                  ICONCOLW
                    fdb       15                  STRTYPOS
                    fdb       135                 ICONYMAX
                    fdb       40                  ICONROWH
                    fdb       25                  WNDWSZY
                    fdb       PTBLSPTR            PTBLNEXT
                    fdb       FNAMBUFR            FNAMEPTR
                    fdb       CALCDESC            IDSCSPTR
                    fdb       ENDLINK             IDSCNEXT
                    fcb       5                   DEVICNTR
                    fcb       2                   DRIVYPOS  Was 18 (making room for printer)

* End of Direct Page Variables.

INTCOUNT            fdb       DTXCOUNT-INITDATA

* TNDYITMS

INITDATA            fcc       "Calc"
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       NUL,NUL,NUL
                    fcb       1,0,0,0
                    fcb       0,0

                    fcc       "Clock"
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       NUL,NUL
                    fcb       1,0,0,0
                    fcb       0,0

                    fcc       "Calendar"
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       1,0,0,0
                    fcb       0,0

                    fcc       "Control"
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       1,0,0,0
                    fcb       0,0

                    fcc       "Printer"
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       1,0,0,0
                    fcb       0,0

                    fcc       "Port"
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       NUL,NUL,NUL
                    fcb       1,0,0,0
                    fcb       0,0

                    fcc       "Help"
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       NUL,NUL,NUL
                    fcb       1,0,0,0
                    fcb       0,0

                    fcc       "Shell"
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       NUL,NUL
                    fcb       1,0,0,0
                    fcb       0,0

* MAY WANT TO ADD BACK IN IF WE START USING CLIPBOARD FUNCTIONS
* FCC "Clipboard"
* FCB NUL,NUL,NUL,NUL,NUL,NUL
* FCB 0,0,0,0
* FCB 0,0

* DISKITMS
* ITM.FREE

                    fcc       "Free"
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       NUL,NUL,NUL
                    fcb       0,0,0,0
                    fcb       0,0

* ITM.FLDR

                    fcc       "New Folder"
                    fcb       NUL,NUL,NUL,NUL,NUL
                    fcb       0,0,0,0
                    fcb       0,0

* ITM.FMAT

                    fcc       "Format"
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       NUL
                    fcb       1,0,0,0
                    fcb       0,0

                    fcc       "Backup"
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       NUL
                    fcb       1,0,0,0
                    fcb       0,0

                    fcc       "Set Execute"
                    fcb       NUL,NUL,NUL,NUL
                    fcb       1,0,0,0
                    fcb       0,0

                    fcc       "Set Devices"
                    fcb       NUL,NUL,NUL,NUL
                    fcb       1,0,0,0
                    fcb       0,0

* ITM.OPEN

                    fcc       "Open"
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       NUL,NUL,NUL
                    fcb       0,0,0,0
                    fcb       0,0

* ITM.LIST

                    fcc       "List"
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       NUL,NUL,NUL
                    fcb       0,0,0,0
                    fcb       0,0

* ITM.COPY

                    fcc       "Copy"
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       NUL,NUL,NUL
                    fcb       0,0,0,0
                    fcb       0,0

* ITM.STAT

                    fcc       "Stat"
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       NUL,NUL,NUL
                    fcb       0,0,0,0
                    fcb       0,0

* ITM.PRNT

                    fcc       "Print"
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       NUL,NUL
                    fcb       0,0,0,0
                    fcb       0,0

* ITM.RENAM

                    fcc       "Rename"
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       NUL
                    fcb       0,0,0,0
                    fcb       0,0

* ITM.DELT

                    fcc       "Delete"
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       NUL
                    fcb       0,0,0,0
                    fcb       0,0

* ITM.SORT

                    fcc       "Sort"
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       NUL,NUL,NUL
                    fcb       0,0,0,0
                    fcb       0,0

                    fcc       "Quit"
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       NUL,NUL,NUL
                    fcb       1,0,0,0
                    fcb       0,0

* VIEWITEMS
* ITM.LRES

                    fcc       "40x25-4"
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       1,0,0,0
                    fcb       0,0

                    fcc       "80x25-4 (FAT)"
                    fcb       NUL,NUL
                    fcb       1,0,0,0
                    fcb       0,0

                    fcc       "40x25-16"
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       1,0,0,0
                    fcb       0,0

* KDMITMS

                    fcc       "<KDM&LCB>"
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       0,0,0,0
                    fcb       0,0

                    fcc       "V#1.26"
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       0,0,0,0
                    fcb       0,0

* TNDYDESC

                    fcc       "Tandy"
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       NUL,NUL
                    fcb       MID.TDY
                    fcb       8,8,1
                    fdb       $0000
                    fdb       TNDYITMS

* FILSDESC

                    fcc       "Files"
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       NUL,NUL
                    fcb       MID.FIL
                    fcb       6,9,1
                    fdb       $0000
                    fdb       FILSITMS

* DISKDESC

                    fcc       "Disk"
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       NUL,NUL,NUL
                    fcb       MID.DSK
                    fcb       12,6,1
                    fdb       $0000
                    fdb       DISKITMS

* VIEWDESC

                    fcc       "View"
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       NUL,NUL,NUL
                    fcb       MID.VEW
                    fcb       13,3,1
                    fdb       $0000
                    fdb       VIEWITMS

* KDMDESC

                    fcc       "About.."
                    fcb       NUL,NUL,NUL,NUL,NUL,NUL,NUL,NUL
                    fcb       MID.KDM
                    fcb       9,2,1
                    fdb       $0000
                    fdb       KDMITMS

* SHELLNAM

                    fcc       "shell"
                    fcb       NUL

* LISTNAM

                    fcc       "list"
                    fcb       NUL

* GCALCNAM

                    fcc       "gcalc"
                    fcb       NUL

* GCLOCKNM

                    fcc       "gclock"
                    fcb       NUL

* GCALNAM

                    fcc       "gcal"
                    fcb       NUL

* CONTROLNM

                    fcc       "control"
                    fcb       NUL

* GPRINTNM

                    fcc       "gprint"
                    fcb       NUL

* GPORTNAM

                    fcc       "gport"
                    fcb       NUL

* HELPNAM

                    fcc       "help"
                    fcb       NUL

* COCPRNM

                    fcc       "cocopr"
                    fcb       NUL

* SCRLPTRS table of pointers was here

* DBOXDESC

                    fdb       48,0,56,8
                    fcb       IC.CLOSE
                    fcb       0
                    fdb       DBARDESC
                    fdb       $0000

* DBARDESC

                    fdb       58,0,600,8
                    fcb       IC.DRBAR
                    fcb       0
                    fdb       QURYDESC
                    fdb       $0000

* QURYDESC

                    fdb       600,0,623,8
                    fcb       IC.QUERY
                    fcb       0
                    fdb       $0000,$0000

* TRSHDESC - moved down to make room for printer. Adjust again for Nick's new icons
                    fdb       8,156,32,180
* before Nick's icon changes
*         fdb   8,160,32,184 Was 8,144,32,168
                    fcb       IC.TRASH
                    fcb       0
                    fdb       $0000,$0000

* PRTRDESC - NEW
                    fdb       8,133,32,148
                    fcb       IC.PRNTR
                    fcb       0
                    fdb       $0000,$0000

* CALCDESC

                    fdb       IC.GCALC
                    fdb       6,20,12,1
                    fdb       0,0
                    fdb       GCALCNAM
                    fdb       $0000,$0000
                    fdb       CLOKDESC

* CLOKDESC

                    fdb       IC.GCLOK
                    fdb       6,20,10,1
                    fdb       0,0
                    fdb       GCLOCKNM
                    fdb       $0000,$0000
                    fdb       CALDESC

* CALDESC

                    fdb       IC.GCAL
                    fdb       6,40,25,1
                    fdb       0,0
                    fdb       GCALNAM
                    fdb       $0000,$0000
                    fdb       SHELDESC

* SHELDESC

                    fdb       IC.SHELL
                    fdb       6,10,5,1
                    fdb       0,0
                    fdb       SHELLNAM
                    fdb       $0000,$0000

* ENDLINK

                    fdb       $0000

* NXTICONO

                    fdb       IC.XTRNL

* PRESSMSG

                    fcc       "Press any key"
                    fcb       NUL

* NEWNMSG

                    fcc       "New name:        "
                    fcb       NUL

* SLASHW

                    fcc       "/w"
                    fcb       NUL

* ALLOCP

                    fcb       0,0,0

DTXCOUNT

                    emod
MODSIZE             equ       *
                    end
