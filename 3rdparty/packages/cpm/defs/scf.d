
SCF.D               SET       1

********************************************************************
* scf.d - Sequential Character File Manager Definitions
*
* $Id$
*
* SCF stands for 'Sequential Character Filemanager' and is a package of subroutines
* that define the logical structure of a serial device.
*
* The data structures in this file give SCF its 'personality' and are used
* by SCF itself, as well as applications that will require disk I/O.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          1984/01/11  YO
* Added V.KANJI, V.KBUF, V.MODADR for new kanji input process.
*
*          1985/04/20  Mark G. Hawkins
* Added V.PDLHd Path Descriptor List Head.
*
*          1985/04/21  Mark G. Hawkins
* Added PD.PLP and PD.PST for modem handling.
*
*          1987/06/23  Kevin K. Darling
* Updated with Dev Desc info.
*
*          1998/10/03  Boisy G. Pitre
* Consolidated L1/L2 scfdefs.
*
*          2003/01/21  Boisy G. Pitre
* Added symbolics for enhanced SCF line editing.
*
*          2003/06/02  Boisy G. Pitre
* Updated comments for clarity.
*
*          2004/05/17  Boisy G. Pitre
* Added higher baud rates.

                    NAM       scf.d
                    TTL       Sequential          File Manager Definitions

                    PAG
*******************************
* SCF Device Descriptor Offsets
*
* These definitions are for SCF device descriptors.

                    ORG       M$DTyp
IT.DVC              RMB       1                   Device type (DT.SCF)
IT.UPC              RMB       1                   Uppercase flag
IT.BSO              RMB       1                   Backspace behavior
IT.DLO              RMB       1                   Delete behavior
IT.EKO              RMB       1                   Echo flag
IT.ALF              RMB       1                   Auto linefeed flag
IT.NUL              RMB       1                   End-of-line null count
IT.PAU              RMB       1                   Page pause flag
IT.PAG              RMB       1                   Number of lines per page
IT.BSP              RMB       1                   Backspace character
IT.DEL              RMB       1                   Delete-line character
IT.EOR              RMB       1                   End-of-record character
IT.EOF              RMB       1                   End-of-file character
IT.RPR              RMB       1                   Reprint-line character
IT.DUP              RMB       1                   Duplicate-last-line character
IT.PSC              RMB       1                   Pause character
IT.INT              RMB       1                   Interrupt character
IT.QUT              RMB       1                   Quit character
IT.BSE              RMB       1                   Backspace echo character
IT.OVF              RMB       1                   Bell character
IT.PAR              RMB       1                   Parity
IT.BAU              RMB       1                   Baud rate
IT.D2P              RMB       2                   Attached device name string offset
IT.XON              RMB       1                   X-ON character
IT.XOFF             RMB       1                   X-OFF character
IT.COL              RMB       1                   Number of columns for display
IT.ROW              RMB       1                   Number of rows for display
IT.XTYP             RMB       1                   Extended type (added by BRI)

* Window Descriptor Additions
* For CoCo window, where IT.PAR = $80


                    PAG
********************
* SCF Static Storage
*
* SCF devices must reserve this space for SCF
*
                    ORG       V.USER
V.TYPE              RMB       1                   Device type or parity
V.LINE              RMB       1                   Lines left until end of page
V.PAUS              RMB       1                   Immediate Pause request
V.DEV2              RMB       2                   Attached device's static
V.INTR              RMB       1                   Interrupt char
V.QUIT              RMB       1                   Quit char
V.PCHR              RMB       1                   Pause char
V.ERR               RMB       1                   Accumulated errors
V.XON               RMB       1                   X-On char
V.XOFF              RMB       1                   X-Off char
V.KANJI             RMB       1                   Kanji mode flag
V.KBUF              RMB       2                   Kana - Kanji convert routine work address
V.MODADR            RMB       2                   Kana - Kanji convert module address
V.PDLHd             RMB       2                   Open path descriptor list head pointer
V.RSV               RMB       5                   Reserve bytes for future expansion
V.SCF               EQU       .                   Total SCF manager static overhead


                    PAG
***********************
* Character Definitions
*
C$NULL              SET       0                   Null char
C$RPET              SET       $01                 (CTRL-A - SOH) Repeat last input line
C$INTR              SET       $03                 (CTRL-C - ETX) Keyboard interrupt
C$RPRT              SET       $04                 (CTRL-D - EOT) Reprint current input line
C$QUIT              SET       $05                 (CTRL-E - ENQ) Keyboard Abort
C$BELL              SET       $07                 (CTRL-G - BEL) Line overflow warning
C$BSP               SET       $08                 (CTRL-H - BS ) Back space
C$RARR              SET       $09                 Right Arrow
C$EL                SET       $05                 Erase Line
C$LF                SET       $0A                 Line feed
C$HOME              SET       $0B                 Home position Code
C$Clsgr             SET       $15                 Graphic screen clear (use FM-11)
C$Clsall            SET       $16                 Graphic & character clear (use FM-11)
C$CR                SET       $0D                 Carriage return
C$FORM              SET       $0C                 (CTRL-L - FF ) Form Feed ... screen clear
C$SI                SET       $0F                 Shift IN Code
C$SO                SET       $0E                 Shift OUT Code
C$DELETE            SET       $10                 Delete char (for SCF enhanced line editing)
C$XON               SET       $11                 (CTRL-Q - DC1) Transmit Enable
C$INSERT            SET       C$XON               Insert char (for SCF enhanced line editing)
C$XOFF              SET       $13                 (CTRL-S - DC3) Transmit Disable
C$PLINE             SET       C$XOFF              Print remaining line (for SCF enhanced line editing)
C$PAUS              SET       $17                 (CTRL-W - ETB) Pause character
C$DEL               SET       $18                 (CTRL-X - CAN) Delete line
C$SHRARR            SET       $19                 Shift Right-Arrow
C$EOF               SET       $1B                 (CTRL-[ - ESC) END of file
C$RGT               SET       $1C                 Cursor right
C$LFT               SET       $1D                 Cursor left
C$UP                SET       $1E                 Cursor up
C$DWN               SET       $1F                 Cursor down
C$SPAC              SET       $20                 Space
C$PERD              SET       '.
C$COMA              SET       ',


                    PAG
*********************************************
* Sequential Character Path Descriptor Format
*
* A path descriptor is created for every new path that is open
* via the I$Open system call (processed by IOMan).  Process
* descriptors track state information of a path.
*
                    ORG       PD.FST
PD.DV2              RMB       2                   Output device table pointer
PD.RAW              RMB       1                   Read/Write or ReadLn/WritLn mode
PD.MAX              RMB       2                   ReadLn high byte count
PD.MIN              RMB       1                   Devices are "mine" if clear
PD.STS              RMB       2                   Status routine module addr
PD.STM              RMB       2                   Reserved for status routine
                    ORG       PD.OPT
                    RMB       1                   Device type
PD.UPC              RMB       1                   Case (0=both, 1=upper only)
PD.BSO              RMB       1                   Backspace (0=BSE, 1=BSE,SP,BSE)
PD.DLO              RMB       1                   Delete (0=BSE over line, 1=CRLF)
PD.EKO              RMB       1                   Echo (0=No Echo)
PD.ALF              RMB       1                   Auto linefeed (0=No auto LF)
PD.NUL              RMB       1                   End of Line null count
PD.PAU              RMB       1                   Page pause (0=No end of page pause)
PD.PAG              RMB       1                   Lines per page
PD.BSP              RMB       1                   Backspace character
PD.DEL              RMB       1                   Delete Line character
PD.EOR              RMB       1                   End of Record character (read only)
PD.EOF              RMB       1                   End of File character
PD.RPR              RMB       1                   Repront Line character
PD.DUP              RMB       1                   Dup Last Line character
PD.PSC              RMB       1                   Pause character
PD.INT              RMB       1                   Keyboard interrupt character (CTRL-C)
PD.QUT              RMB       1                   Keyboard quit character (CTRL-E)
PD.BSE              RMB       1                   Backspace echo character
PD.OVF              RMB       1                   Line overflow character (BELL)
PD.PAR              RMB       1                   Parity code
PD.BAU              RMB       1                   ACIA baud rate (Color Computer)
PD.D2P              RMB       2                   Offset of DEV2 name
PD.XON              RMB       1                   ACIA X-ON character
PD.XOFF             RMB       1                   ACIA X-OFF character
OPTCNT              EQU       .-PD.OPT            Total user settable options
PD.ERR              RMB       1                   Most recent I/O error status
PD.TBL              RMB       2                   Device table addr (copy)
PD.PLP              RMB       2                   Path Descriptor List Pointer
PD.PST              RMB       1                   Current path status


* PD.PST values Path Descriptor Status byte
*
PST.DCD             EQU       %00000001           Set if DCD is lost on Serial port


* PD.PAR definitions
*
* Parity
PARNONE             EQU       %00000000
PARODD              EQU       %00100000
PAREVEN             EQU       %01100000
PARMARK             EQU       %10100000
PARSPACE            EQU       %11100000

* PD.BAU definitions
*
* Baud rate
B110                EQU       %00000000
B300                EQU       %00000001
B600                EQU       %00000010
B1200               EQU       %00000011
B2400               EQU       %00000100
B4800               EQU       %00000101
B9600               EQU       %00000110
B19200              EQU       %00000111
B38400              EQU       %00001000
B57600              EQU       %00001001
B115200             EQU       %00001010
* Word size
WORD8               EQU       %00000000
WORD7               EQU       %00100000
* Stop bits
STOP1               EQU       %00000000
STOP2               EQU       %00010000

