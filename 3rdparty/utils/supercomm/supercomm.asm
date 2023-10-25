********************************************************************
* SuperComm - OS-9 Level Two Communications Program
*
* $Id$
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------
*        Acquired source                                    02/11/20

                    nam       SuperComm
                    ttl       OS-9 Level Two Communications Program

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       $01

                    mod       eom,name,tylg,atrv,start,dsize

name                fcs       /SuperComm/
                    fcb       edition

*************************************************
*
* Supercomm Data Area Layout
*
* Separated from Main source for easier editing
*

                    org       0
Temp                rmb       2                   Temp var for whatever
u0000               rmb       2                   pointer to parameters from shell
u0002               rmb       2                   Ptr to max. address of receive buffer (constant)
u0004               rmb       2                   Ptr to start address of receive buffer (constant)
u0006               rmb       2                   Ptr to current end of receive buffer
u0C82               rmb       1                   Search/Reply string # being processed
u0C88               rmb       1                   MSB of size of converted output text buffer
u0C89               rmb       1                   LSB of size of converted output text buffer
u0008               rmb       1
u0009               rmb       2
u000B               rmb       1
u000C               rmb       1
u000D               rmb       2
u000F               rmb       2
u0011               rmb       1                   Copy of IT.DLO (Delete line 0=BSE, 1=CRLF)
u0012               rmb       1                   Copy of IT.EKO (0=echo off, 1=echo on)
u0013               rmb       2                   Ptr to device descriptor
u0015               rmb       2                   Ptr to start of SuperComm
u0017               rmb       2                   Size of SuperComm
u0019               rmb       1                   special version flag (adds 'a' to version #)
u001A               rmb       1
u001B               rmb       1
u001C               rmb       1
u001D               rmb       1
u001E               rmb       2
u0020               rmb       1
u0021               rmb       1
u0022               rmb       1
u0023               rmb       1                   sending ASCII file xfer flag (1=Send ASCII)
u0024               rmb       1
u0025               rmb       1                   Flag that ASCII receive file exists
u0026               rmb       1                   ASCII receive buffer open
u0027               rmb       2
u0029               rmb       1
u002A               rmb       1                   path # to recieve buffer file
u002B               rmb       1                   path # to serial port
u002C               rmb       1                   path # to file for ASCII send
u002D               rmb       10                  Terminal port to open (up to 10 chars)
u0037               rmb       2
u0039               rmb       3
u003C               rmb       1
u003D               rmb       1                   Path # for disk file
u003E               rmb       1                   path to status line window
u003F               rmb       1                   path to conference window (if enabled)
u0040               rmb       1                   conference mode activated flag (1=Conference mode)
u0041               rmb       1                   key sense data
u0042               rmb       1                   path to download file
u0043               rmb       1
u0044               rmb       1                   1 byte bffr for block responses (ACK/NAK,XON/XOFF)
u0045               rmb       1
u0046               rmb       1                   flag for YModem batch
u0047               rmb       1                   possible remove (not referenced anywhere)
u0048               rmb       1                   \  (u0048 is also running checksum byte)
u0049               rmb       1                   / running CRC for file Xfers
u004A               rmb       1                   last selected xfer protocol (Upload/Send)
u004B               rmb       1                   last selected xfer protocol (Download/Receive)
u004C               rmb       1
u004D               rmb       2                   used as a byte counter in download
u004F               rmb       1                   Internal Error # on xfer
u0050               rmb       2                   Ptr to end of X/Ymodem buffer in modem recv bffr
u0052               rmb       1                   Current attempt # on CheckSum receive (max=10)
u0053               rmb       2                   Current block # (only LSB is used in blck hdrs)
u0055               rmb       2                   True block size (includes blk/comp # & crc/chksm)
u0057               rmb       2                   # data bytes needed for block (128 or 1024)
u0059               rmb       1                   Current attempt # on CRC receive (max=4)
u005A               rmb       1                   CRC or Checksum (0=Checksum)
u005B               rmb       4                   4 byte longint (for file sizes)
u005F               rmb       1
u0060               rmb       2                   Part of timer routine for download timeouts???
u0062               rmb       2
u0064               rmb       1
u0065               rmb       1
u0066               rmb       2                   Ptr to next key in Conf mode keyboard buffer
u0068               rmb       1                   Counter of # keys in Conf mode keyboard buffer
u0069               rmb       1
u006A               rmb       1
u006B               rmb       1                   ZModem flag (hi bit clear=none in progress)
u006C               rmb       2                   pointer to ZModem start header
u006E               rmb       1                   duplicate of input path for ZModem (for restore)
u006F               rmb       1                   possible remove
u0070               rmb       1
u0071               rmb       1
u0072               rmb       1                   path to VRN (0=No VRN present)
u0073               rmb       1                   Current seconds counter (either VRN or Clock)
u0074               rmb       1                   # seconds on last update done (either VRN or Clock
u0075               rmb       1                   Timer on/off flag (0=Off)
u0076               rmb       1                   child process # (shell, sz & rz etc...)
u0077               rmb       11                  time On-Line ASCII text (with CurXY) '00:00:00'
u0082               rmb       1                   Width of original screen
u0083               rmb       1                   Height of original screen
u0084               rmb       1                   Type of original screen (ex. 1=40x24 Hware txt)
u0085               rmb       1                   background color for overlay windows
u0086               rmb       1
u0087               rmb       1                   FColor of main window
u0088               rmb       1                   BColor of main window
u0089               rmb       1                   FColor of conference mode window
u008A               rmb       1
u008B               rmb       1
u008C               rmb       1
u008D               rmb       1                   Foreground color of original screen
u008E               rmb       1                   Background color of original screen
u008F               rmb       1                   Border color of original screen
u0090               rmb       1                   X size of main window
u0091               rmb       1                   Y size of main window
u0092               rmb       1
u0093               rmb       2                   Ptr to next filename (from dir read)
u0095               rmb       2
u0097               rmb       2
u0099               rmb       1
u009A               rmb       1
u009B               rmb       1                   filename present for Upload/Download flag
u009C               rmb       3                   FColor codes
u009F               rmb       32                  old filename for downloads
u00BF               rmb       2
u00C1               rmb       26
u00DB               rmb       2
u00DD               rmb       2
u00DF               rmb       1                   input buffer from modem (192 bytes)
u00E0               rmb       1
u00E1               rmb       1
u00E2               rmb       4
u00E6               rmb       13
u00F3               rmb       10
u00FD               rmb       1010
u04EF               rmb       1
u04F0               rmb       31
u050F               rmb       255                 Conference mode keyboard buffer
u060E               rmb       255                 Generic Entry from keyboard buffer
u070D               rmb       1024                output buffer to screen (with conversion)
u0B0D               rmb       255
u0C0C               rmb       32                  Current SS.Opt settings for local keyboard
u0C2C               rmb       2
u0C2E               rmb       34
u0C50               rmb       16                  Palette settings of original screen
u0C60               rmb       1                   Start of buffer for converted ANSI sequences
u0C61               rmb       1
u0C62               rmb       30
u0C80               rmb       2                   Ptr to converted ANSI buffer (C60)
u0C83               rmb       1
u0C84               rmb       1                   Currently selected menu item # in ==> menu
u0C85               rmb       3
u0C8A               rmb       1                   Flag: 0=Not processing ANSI <ESC> sequence
u0C8B               rmb       1                   ??? (Inited to 0 if starting ANSI <ESC> sequence)
u0C8C               rmb       1
u0C8D               rmb       2                   Ptr to ANSI sequence (raw ANSI:u0B0D)
u0C8F               rmb       2                   current overlay window start co-ordinates
u0C91               rmb       2                   current overlay window size
u0C93               rmb       1                   possible remove
u0C94               rmb       1                   current cursor X position
u0C95               rmb       1                   current cursor Y position
u0C96               rmb       2                   current X/Y co-ordinates?
u0C98               rmb       1
u0C99               rmb       6                   Place to hold F$Time packet
u0C9F               rmb       1
u0CA0               rmb       1                   seems to be flag for upload/download (0=Upload)
u0CA1               rmb       2
u0CA3               rmb       1
u0CA4               rmb       1
u0CA5               rmb       1                   bit 8=Stop bits, bit 6=Word Len, bits 1-3=Baud
u0CA6               rmb       1                   current terminal type (0=TTY, 1=OS9, 2=ANSI)
u0CA7               rmb       1                   Current Echo type (0=Off, 1=On)
u0CA8               rmb       1
u0CA9               rmb       1
u0CAA               rmb       1
u0CAB               rmb       1                   Current hangup method (0=DTR drop, else +++ATH)
u0CAC               rmb       1                   Current Parity setting
u0CAD               rmb       1
u0CAE               rmb       1                   Auto Zmodem flag (0=Yes)
u0CAF               rmb       1                   Pause off char. code (for ASCII receive)
u0CB0               rmb       1                   Pause on char. code (for ASCII receive)
u0CB1               rmb       33
u0CD2               rmb       32                  Current data directory path list
u0CF2               rmb       39
u0D19               rmb       1
u0D1A               rmb       2
u0D1C               rmb       128                 <ALT>-<1> programmable key buffer
u0D9C               rmb       128                 <ALT>-<2> programmable key buffer
u0E1C               rmb       128                 <ALT>-<3> programmable key buffer
u0E9C               rmb       128                 <ALT>-<4> programmable key buffer
u0F1C               rmb       128                 <ALT>-<5> programmable key buffer
u0F9C               rmb       128                 <ALT>-<6> programmable key buffer
u101C               rmb       128                 <ALT>-<7> programmable key buffer
u109C               rmb       128                 <ALT>-<8> programmable key buffer
u111C               rmb       256                 SSn strings (4 of 64 bytes each)
u121C               rmb       256                 RSn strings (4 of 64 bytes each)
u131C               rmb       128
u139C               rmb       2                   Pointer to RSn string we are working on
u139E               rmb       1                   # download protocols supported
u139F               rmb       4
u13A3               rmb       1
u13A4               rmb       1
u13A5               rmb       1
u13A6               rmb       3
* ??? rest big buffer, most used for text, input & output ???
u13A9               rmb       1                   Temp buffer for small text, etc.
u13AA               rmb       6
u13B0               rmb       137
u1439               rmb       16
u1449               rmb       112
u14B9               rmb       512
u16B9               rmb       $2000-200-.         ASCII recieve buffer (expanded by #xxK modifier)
u1F38               rmb       200                 stack
dsize               equ       .

                    fcc       'Program by Dave Philipsen Copyright (c) 1988, 1989,1992'
                    fcc       / ('92 updates by Randy K. Wilson)/

L006F               fdb       85                  # bytes this message (?) ($55)
                    fcb       C$FORM              Clear screen
                    fcb       $02,$23,$21         CurXY @ 3,1
                    fcc       'SuperComm   v2.2'
                    fcb       $02,$24,$23         CurXY @ 4,3
                    fcc       'Copyright (c)'
                    fcb       $02,$23,$24         CurXY @ 3,4
                    fcc       '1988, 1989, 1992'
                    fcb       $02,$26,$26         CurXY @ 6,6
                    fcc       'written by'
                    fcb       $02,$24,$27         CurXY @ 4,7
                    fcc       'Dave Philipsen'

L00C6               fdb       35                  # bytes this message ($23)
                    fcb       C$FORM              Clear screen
                    fcb       $02,$22,$21         CurXY @ 2,1
                    fcc       'with updates by'
                    fcb       $02,$22,$22         CurXY @ 2,2
                    fcc       ' Randy Wilson'

L00EB               fdb       28                  # bytes this message ($1C)
                    fcb       $02,$40,$20         CurXY @ 32,0
                    fcb       $1B,$32,4           Foreground color= Yellow
                    fcc       'SuperComm v2.2 '
                    fcb       $1B,$32,3           Foreground color= White
                    fcb       $02,$58,$20         CurXY @ 55,0
                    fcc       '='                 (for port '=' baudrate)

L0109               fdb       454                 # bytes this message ($C6)
                    fcc       '   Use <ALT> key with the following keys:'
                    fcb       C$CR,C$LF,C$LF
                    fcc       ' A - Auto Dialer           Q - Quit'
                    fcb       C$CR,C$LF
                    fcc       ' B - Baud Rates            R - Reset Palettes'
                    fcb       C$CR,C$LF
                    fcc       ' C - Clear Screen          S - OS9 Shell Access'
                    fcb       C$CR,C$LF
                    fcc       ' D - Change Directory      T - Terminal Type'
                    fcb       C$CR,C$LF
                    fcc       ' H - Hang Up               U - Update SuperComm'
                    fcb       C$CR,C$LF
                    fcc       ' I - Timer on/off          Z - Conference Mode'
                    fcb       C$CR,C$LF
                    fcc       ' M - Open/Close Buffer   <Up>- Upload file'
                    fcb       C$CR,C$LF
                    fcc       ' O - Change Options      <Dn>- Download File'
                    fcb       C$LF,C$CR,C$LF
                    fcc       '     Select function or <Space> to continue'

L02DC               fcc       'ATH'               Hangup string (does not need '0' on end)
                    fcb       C$CR

L02E0               fcc       'Shell'

L02E5               fcb       C$CR

L02E6               fcc       'rz'
                    fcb       C$CR

L02E9               fcc       '-vv   '
                    fcb       C$CR

L02F0               fdb       40                  # bytes this message ($28)
                    fcb       $02,$34,$20         CurXY @ 20,0
                    fcc       'External ZModem File Receive'
                    fcb       C$CR,C$LF,C$LF
                    fcb       $1B,$25,0,3,$40,7   CWArea to 0,3 - 64,10

L031A               fcc       '*'                 ZModem Xfer signature
                    fcb       $18
                    fcc       'B0'
                    fcb       $00                 Byte to signify end of Zmodem Xfer signature

* Window for ZModem Send
L0322               fdb       37                  # bytes this message
                    fcb       $02,$36,$20         CurXY @ 23,1
                    fcc       'External ZModem File Send'
                    fcb       C$CR,C$LF,C$LF
                    fcb       $1B,$25,0,3,$40,7   CWArea to 0,3 - 64,10

* Hangup message
L0349               fdb       15                  # bytes this message
                    fcb       C$CR,C$LF
                    fcc       ' Hanging Up!!'

* Device to use VRN
L0360               fcc       '/nil'
                    fcb       C$CR
                    fcb       $00

* Default time on-line string
L0366               fcb       $02,$2b,$20         CurXY @ 11,0
                    fcc       '00:00:00'

* Palette set #1
L0371               fcb       $00,$20,$00,$3F,$10,$20,$3F,$3F
                    fcb       $00,$20,$00,$3F,$10,$20,$3F,$3F

* Palette set for ANSI mode
L0381               fcb       $00,$24,$12,$37,$09,$28,$1F,$3F
                    fcb       $00,$24,$12,$37,$09,$28,$1F,$3F

* Palette set for OS-9 mode
L0391               fcb       $3F,$09,$00,$12,$24,$37,$28,$1F
                    fcb       $3F,$09,$00,$12,$24,$37,$28,$1F

* Default FColor,BColor,Border settings for ANSI
L03A1               fcb       $07,$00,$00

* Default FColor,BColor,Border settings for OS-9
L03A4               fcb       $00,$02,$02

* Inverse/Underline/Blink OFF & clear screen
L03A7               fdb       7                   # bytes this message
                    fcb       $1F,$21,$1f,$23,$1f,$25,C$FORM

* Shadowed overlay window (save switch on)
L03B0               fdb       18                  # bytes this message
L03B2               fcb       $1B,$22,1,0,0,80,23,1,1
                    fcb       $1B,$22,1,2,1,76,21,6,0

* Shadowed overlay windows remove (restore original screen)
L03C4               fdb       4                   # bytes this message
L03C6               fcb       $1B,$23,$1b,$23     OWEnd, OWEnd

* Default settings?
L03D6               fdb       14                  # bytes this message
                    fcb       $1F,$21             Inverse off
                    fcb       $1F,$23             Underline off
                    fcb       $1F,$25             Blink off
                    fcb       $1B,$32,7           Foreground color 7
                    fcb       $1B,$33,0           Background color 0
                    fcb       $05,$21             Cursor ON

L03E6               fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    fdb       2                   # bytes this entry
                    fcb       $1F,$22             Underline on
                    fcb       0,0
                    fcb       2                   # bytes this entry
                    fcb       $1F,$24             Blink on
                    fcb       0,0,0,0,0,0,0
                    fcb       2                   # bytes this entry
                    fcb       $1F,$20             Inverse on
                    fcb       $00

* Foreground color settings
L040E               fdb       3                   # bytes this entry
                    fcb       $1B,$32,0           Foreground color 0
                    fdb       3                   # bytes this entry
                    fcb       $1B,$32,1           Foreground color 1
                    fdb       3                   # bytes this entry
                    fcb       $1B,$32,2           Foreground color 2
                    fdb       3                   # bytes this entry
                    fcb       $1B,$32,3           Foreground color 3
                    fdb       3                   # bytes this entry
                    fcb       $1B,$32,4           Foreground color 4
                    fdb       3                   # bytes this entry
                    fcb       $1B,$32,5           Foreground color 5
                    fdb       3                   # bytes this entry
                    fcb       $1B,$32,6           Foreground color 6
                    fdb       3                   # bytes this entry
                    fcb       $1B,$32,7           Foreground color 7

* Background color settings
L0436               fdb       3                   # bytes this entry
                    fcb       $1B,$33,0           Background color 0
                    fdb       3                   # bytes this entry
                    fcb       $1B,$33,1           Background color 1
                    fdb       3                   # bytes this entry
                    fcb       $1B,$33,2           Background color 2
                    fdb       3                   # bytes this entry
                    fcb       $1B,$33,3           Background color 3
                    fdb       3                   # bytes this entry
                    fcb       $1B,$33,4           Background color 4
                    fdb       3                   # bytes this entry
                    fcb       $1B,$33,5           Background color 5
                    fdb       3                   # bytes this entry
                    fcb       $1B,$33,6           Background color 6
                    fdb       3                   # bytes this entry
                    fcb       $1B,$33,7           Background color 7

* Clear screen code
L045E               fdb       1                   # bytes this entry
                    fcb       C$FORM

* Erase to end of line
L0461               fdb       1                   # bytes this entry
                    fcb       $04

* Erase to end of screen
L0464               fdb       1                   # bytes this entry
                    fcb       $0B

* Generic window descriptor
L0467               fcs       '/W'

* DWSet for main window: 80x23 text from 0,1
L0469               fcb       $1B,$24             DWEnd
                    fcb       $1B,$20,2,0,1,80,23,7,2,2,$1b,$21 DWSet:80x23 text, 1 from top

* DWSet for status line @ top window: 80x1 with blue background
* Done on Process' current screen (which is set by L0469 above)
L0475               fcb       $1B,$24             DWEnd
L0477               fcb       $1B,$20,0,0,0,80,1,3,4 DWSet: 80x1, same scrn, blue bckgrnd
                    fcb       C$FORM              Clear the line

L0481               fcb       $1B,$32,0           Foreground color=0
                    fcb       $1B,$33,0           Background color=0
                    fcb       C$FORM              Clear screen

                    fdb       1
                    fcc       / /

L048B               fdb       2
                    fcb       $05,$21

L048F               fdb       2
                    fcb       $05,$20

L0493               fcb       $1F,$20             Inverse on
                    fcb       $20                 Space
                    fcb       $1F,$21             Inverse off
                    fcb       C$BSP               Backspace

L0499               fdb       22                  # bytes this message
                    fcb       C$CR,C$LF
                    fcc       ' Are you sure? (y/N)'

L04B1               fdb       40                  # bytes this message
                    fcb       $02,$2e,$23         CurXY @ 14,3
                    fcc       'Count  '
                    fcb       $02,$2e,$25         CurXY @ 14,5
                    fcc       'Seconds '
                    fcb       $02,$2d,$27         CurXY @ 13,7
                    fcc       '<Space> aborts'
                    fcb       $05,$20             Turn off cursor

L04DB               fdb       8                   # bytes this message
                    fcc       'Dialing '

L04E5               fdb       3                   # bytes this message
                    fcb       $02,$37,$23         CurXY @ 23,3

L04EA               fdb       3                   # bytes this message
                    fcb       $02,$37,$25         CurXY @ 23,5

L04EF               fdb       32                  # bytes this message
                    fcc       '     Xmodem file transfer system'

L0511               fdb       9                   # bytes this message
                    fcb       $02,$20,$20         CurXY @ 0,0
                    fcc       '     Y'

L051C               fdb       17                  # bytes this message
                    fcb       $02,$2b,$26         CurXY @ 11,6
                    fcc       '<Break> aborts'

L052F               fdb       17                  # bytes this message
                    fcb       $02,$2A,$28         CurXY @ 10,8
                    fcc       '<Break> aborts'

                    fdb       27                  # bytes this message
                    fcb       $02,$25,$22         CurXY @ 5,2
                    fcc       'ASCII Processing? (Y/N) '

L055F               fdb       10                  # bytes this message
                    fcb       $02,$21,$24         CurXY @ 1,4
                    fcc       'File: '
                    fcb       $04                 Clear to end of line

L056B               fdb       10                  # bytes this message
                    fcb       $02,$21,$22         CurXY @ 1,2
                    fcc       'Recv: '
                    fcb       $04                 Clear to end of line

L0577               fdb       10                  # bytes this message
                    fcb       $02,$21,$23         CurXY @ 1,2
                    fcc       'Size: '
                    fcb       $04                 Clear to end of line

L0583               fdb       14                  # bytes this message
                    fcb       $02,$21,$24         CurXY @ 1,4
                    fcb       $04                 Clear to end of line
                    fcb       $02,$21,$22         CurXY @ 1,2
                    fcc       'Send: '
                    fcb       $04                 Clear to end of line

L0593               fdb       34                  # bytes this message
                    fcb       $02,$21,$25         CurXY @ 1,5
                    fcc       'Block #                 Error #'

L05B7               fdb       14                  # bytes this message
                    fcb       $02,$21,$27         CurXY @ 1,7
                    fcc       'Last Error:'

L05C7               fcc       '                    '
                    fcc       'Transfer Aborted    '
                    fcc       'Wrong Block Number  '
                    fcc       'Block Check Failed  '
                    fcc       'Time Out            '

L062B               fdb       7                   # bytes this message
                    fcb       $02,$28,$25         CurXY @ 8,5
                    fcc       '0000'

L0634               fdb       7                   # bytes this message
                    fcb       $02,$40,$25         CurXY @ 32,5
                    fcc       '0000'

* ???? No label was pointing to it, was after baud rate table (L0652)
* NOTE: MAY BE POSSIBLE TO DELETE FOLLOWING 8 BYTES
                    fdb       6                   # bytes this message
                    fcb       $1B,$25,1,2,4,9     CWArea from 1,2 to 5,11

L0682               fcb       C$BSP,C$BSP,C$BSP
                    fcc       '   '

L0688               fcb       C$FORM              Clear screen
                    fcb       C$LF,C$LF,C$LF,C$LF,C$LF,C$LF,C$LF,C$LF,C$LF,C$LF

L0693               fcc       '==>'

L0696               fdb       24                  # bytes this message
                    fcb       C$LF,C$CR
                    fcc       ' Terminal Type :      '

L06B0               fcc       'OS9  '
                    fcc       'ASCII'
                    fcc       'ANSI '

L06BF               fcb       $02,$30,$21         CurXY @ 16,1
                    fcc       'ASCII'

L06C7               fdb       8                   # bytes this message
                    fcb       $02,$30,$21         CurXY @ 16,1
                    fcc       '     '

* Keywords in ADF (Autodial) files
L06D1               fcs       'ADS'
                    fcs       'BPS'
                    fcs       'ECH'
                    fcs       'HEK'
                    fcs       'TRM'
                    fcs       'LNF'
                    fcs       'XON'
                    fcs       'XOF'
                    fcs       'RTR'
                    fcs       'RPS'
                    fcs       'PAR'
                    fcs       'CLK'
                    fcs       'WRD'
                    fcs       'STP'
                    fcs       'KM1'
                    fcs       'KM2'
                    fcs       'KM3'
                    fcs       'KM4'
                    fcs       'KM5'
                    fcs       'KM6'
                    fcs       'KM7'
                    fcs       'KM8'
                    fcs       'CNS'
                    fcs       'SS1'
                    fcs       'SS2'
                    fcs       'SS3'
                    fcs       'SS4'
                    fcs       'RS1'
                    fcs       'RS2'
                    fcs       'RS3'
                    fcs       'RS4'
                    fcs       'RLF'
                    fcs       'TLF'

* Receive protocol menu
L0734               fdb       111                 # bytes this message
                    fcc       ' SuperComm File Receive'
                    fcb       C$CR,C$LF,C$LF
                    fcc       '     ASCII Receive'
                    fcb       C$CR,C$LF
                    fcc       '     XModem (and X-1k)'
                    fcb       C$CR,C$LF
                    fcc       '     YModem Batch'
                    fcb       C$CR,C$LF
                    fcc       '     ZModem (external)'

* File send menu
L07A5               fdb       123                 # bytes this message
                    fcc       '   SuperComm File Send'
                    fcb       C$CR,C$LF,C$LF
                    fcc       '     ASCII Send'
                    fcb       C$CR,C$LF
                    fcc       '     XModem (and CRC)'
                    fcb       C$CR,C$LF
                    fcc       '     Xmodem 1K'
                    fcb       C$CR,C$LF
                    fcc       '     YModem Batch'
                    fcb       C$CR,C$LF
                    fcc       '     ZModem (external)'

* Options menu
L0821               fdb       147                 # bytes this message
                    fcc       '  SuperComm Options'
                    fcb       $1B,$25,5,2,14,12   CWArea from 5,2 to 19,14
                    fcc       'Echo'
                    fcb       C$CR,C$LF
                    fcc       'L-Feeds Rx'
                    fcb       C$CR,C$LF
                    fcc       'L-Feeds Tx'
                    fcb       C$CR,C$LF
                    fcc       'Click'
                    fcb       C$CR,C$LF
                    fcc       'Word Length'
                    fcb       C$CR,C$LF
                    fcc       'Parity'
                    fcb       C$CR,C$LF
                    fcc       'Stop Bits'
                    fcb       C$CR,C$LF
                    fcc       'Echo (host)'
                    fcb       C$CR,C$LF
                    fcc       'Hang Up'
                    fcb       C$CR,C$LF
                    fcc       'Auto Zmodem'
                    fcb       C$CR,C$LF
                    fcc       'Auto Ascii'
                    fcb       C$CR,C$LF
                    fcb       $1B,$25,0,0,22,14   CWArea from 0,0 to 22,14

* Re-saving Supercomm message
L08B6               fdb       23                  # bytes this message
                    fcb       C$CR,C$LF
                    fcc       ' Saving  SuperComm...'

L08CF               fdb       23                  # bytes this message
                    fcb       C$FORM              Clear screen
                    fcb       $02,$29,$20         CurXY @ 9,0
                    fcc       'File Capture System'

L08E8               fdb       38                  # bytes this message
                    fcc       '"'
                    fcb       $02,$21,$24         CurXY @ 1,4
                    fcc       'is already open.  Close it? (Y/n) '

L0910               fdb       19                  # bytes this message
                    fcb       $02,$2b,$22         CurXY @ 11,2
                    fcb       $03                 Erase current line
                    fcc       'Send ASCII file'

L0925               fdb       4                   # bytes this message
                    fcb       $02,$21,$22         CurXY @ 1,2
                    fcc       '"'

L092B               fdb       51                  # bytes this message
                    fcb       $02,$29,$20         CurXY @ 9,0
                    fcc       'File already exists!'
                    fcb       $02,$26,$22         CurXY @ 6,2
                    fcc       '<A>ppend or <O>verwrite? '

* Buffer open indicator
L0960               fdb       11                  # bytes this message
                    fcb       $02,$6e,$20         CurXY @ 78,0
                    fcb       $1F,$24             Blinking on
                    fcb       $1B,$32,3           Foreground color=3
                    fcc       'B'
                    fcb       $1F,$25             Blinking off

* Buffer closed indicator
L096D               fdb       10                  # bytes this message
                    fcb       $02,$6e,$20         CurXY @ 78,0
                    fcb       $1B,$32,0           Foreground color=0
                    fcc       'B'
                    fcb       $1B,$32,3           Foreground color=3

L0979               fdb       4                   # bytes this message
                    fcc       'DTR'
                    fcb       $04                 Clear to end of line

L0985               fdb       4                   # bytes this message
                    fcc       'Off'
                    fcb       $04                 Clear to end of line

L098B               fdb       3                   # bytes this message
                    fcc       'On'
                    fcb       $04                 Clear to end of line

L0990               fcc       ' '
L0991               fcc       'Mark'
L0995               fcc       'Space'
L099A               fcc       ' '
L099B               fcc       'Even'
L099F               fcc       ' '
L09A0               fcc       'Odd '
L09A4               fcc       ' '
L09A5               fcc       'None'

L09A9               fdb       54                  # bytes this message
                    fcb       $02,$28,$20         CurXY @ 8,0
                    fcc       'Change Data Directory'
                    fcb       $02,$29,$25         CurXY @ 9,5
                    fcc       '(use full pathname)'
                    fcb       $02,$21,$24         CurXY @ 1,4
                    fcc       'Path:'

L09E1               fcb       $02,$20,$20
                    fcc       /    /

L09E8               fcb       $02,$20,$20         CurXY @ 0,0
                    fcc       'Conf'

L09EF               fcb       $1B,$25,0,1,80,2    CWArea to 0,1 to 80,3

* Table for converting long Integers (used for file size printing)
* Will handle sizes up to 9,999,999 bytes
L09F5               fdb       $000F,$4240         1,000,000
                    fdb       $0001,$86A0         100,000
                    fdb       $0000,$2710         10,000
                    fdb       $0000,$03E8         1,000
                    fdb       $0000,$0064         100
                    fdb       $0000,$000A         10
                    fdb       $0000,$0001         1
                    fdb       $0000,$0001         0

L0A15               fcb       $0E

* Acceptable entries on help screen
L0A16               fcc       'ABCDHIMOQRSTUZ'

* Default option switches
L0A24               fcb       $04                 default word length, stop bits & baud rate
                    fcb       $02
                    fcb       $00                 echo
                    fcb       $00                 linefeeds Rx
                    fcb       $00                 linefeeds Tx
                    fcb       $00                 key click
                    fcb       $00                 hangup method
                    fcb       $00                 parity
                    fcb       $00                 auto ASCII (0=Off)
                    fcb       $00                 auto ZModem (0=On)
                    fcb       $11                 default XON value
                    fcb       $13                 default XOFF value
                    fcb       $00                 echo (host)

L0A31               fcs       '/dd/sys/dial'
                    fcc       '                    '

L0A51               fcc       '/dd'
                    fcb       C$CR
                    fcc       '                            '

****************************
* Main Entry point
* Note: Eventually change to use Ext. addressing
start               stx       <u0000              Save Param area ptr
                    leax      -$40,x              End of rec. bffr is 64 bytes from end of data mem
                    stx       <u0002              Save end of receive buffer ptr
                    leas      -1,s                Reserve 1 byte on stack
                    ldx       #u16B9              Point to start of receive buffer
                    stx       <u0004              Save start of receive buffer ptr (constant)
                    stx       <u0006              Save current end of receive buffer ptr
                    leax      -1,x                Move ptr 1 back
                    stx       <u000B              Save it
                    ldx       #u14B9              Point to ???
                    stx       <u000D              Save that ptr twice
                    stx       <u000F
                    ldd       #$0000              Clear out something to 0
                    std       <u0009
                    ldx       #u0019              Point X to $19 in data area
* Clear out all memory from $19 to end of Data mem-64
L0A96               sta       ,x+                 Clear byte out
                    cmpx      <u0002              Done all data mem yet?
                    blo       L0A96               No, keep going until done
                    ldx       <u0000              Get param area ptr back
                    lda       #C$SPAC             Get char for space
                    sta       -1,x                Save as char before param area

* Parse parameters for device name
L0AA2               lda       ,x+                 Get param char
                    cmpa      #C$CR               End of params?
                    beq       L0AB6               Yes, skip ahead
                    cmpa      #'/                 Start of device name?
                    bne       L0AA2               No, eat char & continue
                    lda       -2,x                Get char before the '/'
                    cmpa      #C$SPAC             Was it a space?
                    bne       L0AA2               No, eat '/' and continue parsing
                    leax      -1,x                It was, bump ptr back to '/'
                    bra       L0ABA               Skip ahead

* Default modem port
L035A               fcc       '/t2'
                    fcb       C$CR
                    fcb       $00,$00
*
L0AB6               leax      <L035A,pc           Point to '/t2'
L0ABA               ldy       #u002D              Point to spot in data mem
                    ldb       #10                 Max # bytes to copy
L0ABF               lda       ,x+                 Get char from device to use as modem port
                    cmpa      #C$CR               Hit end yet?
                    beq       L0ACA               Yes, skip ahead
                    sta       ,y+                 Save char
                    decb                          Past max count yet?
                    bne       L0ABF               No, keep copying
L0ACA               sta       ,y+                 Save CR too
                    lbsr      L12F5               Go save original screen attributes
                    lbcs      L0F15               If not window-capable, exit with error
                    lbsr      L1A8A               set main window to full size possible
                    lbcs      L0F15               If error, exit with it
                    lda       #$01
                    sta       <u0065
                    ldx       #$0003              sleep to allow window to init.
                    os9       F$Sleep
                    ldd       #1*256+SS.Montr     Get monitor type
                    os9       I$GetStt
                    bcs       L0B1D               Error, exit
                    tfr       x,d                 Move to splittable register
                    stb       >u0C84              save monitor type
                    ora       >u0C84              ??? OR with 0?
                    sta       <u0065              save monitor type
                    leax      L0A24,pc            point to default option table & directorys
                    ldy       #u0CA5
                    ldb       #$4D                get size of data
                    lbsr      L2D1E               move it
                    lda       #READ.
                    leax      L0A51,pc            point to default directory name
                    os9       I$ChgDir
                    leax      L0366,pc            point to default time on-line
                    ldy       #u0077
                    ldb       #$0B                get size of data
                    lbsr      L2D1E               move it
L0B1D               lbsr      L1BDF               set palettes based on monitor type
                    lbsr      L1C57
                    lbsr      L1BC7               initialize batch file xfer names?
                    leax      L0F18,pc            point to intercept trap
                    os9       F$Icpt
* Get special version flag from system direct page (offset $7C)
* all this byte does in this source is add a 'a' to the version # on the
* status line
                    ldx       #u00DF              point to a DAT buffer
                    ldd       #$0000              get DAT image
                    std       ,x                  store it
                    std       2,x
                    std       4,x
                    stb       6,x
                    tfr       x,d
                    ldx       #$7C                get offset into System DP (no idea what it is)
                    ldy       #1                  get # bytes
                    ldu       #u0019              point to location to copy
                    os9       F$CpyMem            get the byte
* Setup VRN
                    leax      L0360,pc            point to VRN pathname
                    lda       #UPDAT.
                    os9       I$Open
                    bcs       L0B92               If VRN not around, skip ahead
                    sta       <u0072              save path # to VRN
                    ldb       #$81                get code to setup VIRQ timer
                    ldy       #1                  get enable flag
                    ldx       #60                 get timer count
                    os9       I$SetStt            start timer
                    bcs       L0B89
                    lda       <u0072              get VRN path again
                    ldb       #$80                get code to clear & report VIRQ calls
                    os9       I$GetStt            get VIRQ counts & reset
                    bcs       L0B89
                    cmpx      #$0800
                    bhs       L0B89
                    cmpy      #$0800
                    blo       L0B92
L0B89               lda       <u0072              get path to VRN again
                    os9       I$Close             close it
                    clr       <u0072              clear path # to VRN
* No VRN available comes here
L0B92               ldx       #u050F              Point to ???
                    stx       <u0066              Save ptr
                    ldd       #$0100              ??? Init some values
                    std       >u0D19
                    ldd       #$1B32              Foreground color prefix
                    std       <u009C              Save it
* Print title screens
                    leax      L045E,pc            point to CLS
                    lbsr      L1B03               do it
                    leax      L048F,pc            point to CuOff
                    lbsr      L1B03               do it
                    ldd       #$1A04              get overlay start coords
                    std       >u0C8F
                    ldd       #$1609              get overlay size
                    std       >u0C91
                    lbsr      L1C81               place overlay window on screen
                    leax      L006F,pc            point to title #1
                    lbsr      L1B03               print it
                    lbsr      L1AE8               init small window on top line
                    ldx       #$001C              get sleep time
                    lbsr      L0F56               sleep for title pause
                    ldd       #$3210              get overlay start co-ordinates
                    std       >u0C8F
                    ldd       #$1304              get overlay size
                    std       >u0C91
                    lbsr      L1C81               place overlay on screen
                    leax      L00C6,pc            point to title #2
                    lbsr      L1B03               print it
                    lbsr      L3BBC               copy current seconds
L0BF7               ldd       #SS.Ready           Get code to check data ready on Std In
                    os9       I$GetStt            any data from keyboard?
                    bcc       L0C08               yes, skip ahead
                    lbsr      L3BDA               check timeout
                    cmpa      #$0A                did it timeout?
                    blo       L0BF7               no, try again
                    bra       L0C0B

L0C08               lbsr      L2AC5               purge the data from keyboard
L0C0B               lbsr      L1CDE               remove overlay windows
                    lbsr      L1CDE
                    leax      L048B,pc            point to CurOn
                    lbsr      L1B03               do it
                    lda       #UPDAT.             get mode for modem path
                    ldx       #u002D              point to modem path
                    os9       I$Open              open it
                    lbcs      L0F15               If error, exit with it
                    sta       <u002B              save path to modem
                    leax      L045E,pc            point to CLS
                    lbsr      L1B03               do it
                    lbsr      L117F               get path options from modem
                    lbsr      L2B86               print status line
                    lbsr      L4403               scan parameters for '-f=' (capture buffer)
                    ldd       #$0103              init cursor position
                    std       >u0C94
* NOTE: may want to have Supercomm make this an option (self-modify code
* to change LBSR opcode to LBRN or vice versa)
                    lbsr      L2AF5               toggle DTR to hangup modem
                    lbsr      L134D               get local keyboard path options
                    lbsr      L12B5               set them to what I need
                    clra                          Std In path
                    leax      L031A,pc            point to ZModem xfer header
                    stx       <u006C              save pointer to it
                    ldx       #u060E              Point to buffer for key presses
                    ldy       #$0001
                    os9       I$Read
                    lbra      L157B               enter main loop (without read from keyboard)

* Check if data waiting for keyboard
L13C2               ldd       #SS.Ready           Check if data ready on keyboard (Std In)
                    os9       I$GetStt
                    rts

* Main processing loop
L0C5E               lda       <u002B              Get path to modem
                    ldb       #SS.Ready           Check for data ready
                    os9       I$GetStt            Any data ready?
                    bcc       L0FB8               yes, go process
                    tst       <u0023              sending ASCII file?
                    lbne      L44B6               yes, read & write next line
                    ldx       #3                  get # ticks to wait
                    lbsr      L0F56               go wait
L0C72               bsr       L13C2               any data from keyboard?
                    bcs       L0C5E               no, try modem again
* Keyboard data ready
                    tst       <u0040              conference mode?
                    lbne      L273D               yes, go read data from keyboard
                    lbra      L156E               go read & process keyboard data

* Process modem data - only comes here if at least 1 char available
* Entry: B=Number of characters available on serial port
* Modified 94/03/27 for 256 byte buffer
L0FB8               clra                          clear MSB of length
                    tfr       d,y                 move length to Y
                    lda       <u002B              get path to modem
                    ldx       #u00DF              point to buffer
                    os9       I$Read              get the data
                    bcs       L1023               error, skip ahead
                    sty       <u0C88              save # bytes read
L0FD2               beq       L1017               If no data, skip ahead
                    lda       >u0CAE              Is Auto-Zmodem enabled?
                    bne       L0FE1               no, check continue
                    lbsr      L1062               Check for an Auto-ZModem header
L0FE1               lda       <u0C82              Get which search/reply string we are doing
                    beq       L0FF4               None, skip checking search/reply strings
                    cmpa      #$05                Have we finished the 4 max. allowed?
                    bne       L0FF1               No, go check for this one
                    clra                          Done all of them, clear it out to skip thru faster
                    sta       <u0C82
                    bra       L0FF4               Skip checking auto-logon sequences

L0FF1               lbsr      L254A               Go check for auto-logon sequences
L0FF4               bsr       L1040               convert & move data to output buffer
                    lda       #1                  get path to window
                    ldx       #u070D              point to parsed data
                    ldy       <u0C88              get amount of data
                    beq       L1017               none, skip ahead
                    os9       I$Write             print data on screen
                    tst       <u0025              Is there an ASCII receive buffer file going?
                    beq       L1017               No, skip ahead
                    tst       <u0026              Is the buffer OPEN?
                    beq       L1017               No, skip ahead
                    lbsr      L4394               Go handle receive buffer
L1017               lbsr      L453B               Go handle screen buffer
                    tst       >u0C83
                    beq       L1023
                    lbsr      L25B1
L1023               tst       <u006B              Zmodem flag?
                    bpl       L1036               No zmodem, skip ahead
                    clr       <u006B              Clear it out
                    tst       >u0CA0              Sending or receiving?
                    lbeq      L1859               Sending; do ZModem file send
                    lbra      L1793               Do Zmodem file receive

L1036               tst       <u0023              Are we sending an ASCII file?
                    beq       L0C72               No, go check the keyboard
                    lbra      L0C5E               go back to main loop

* Convert modem text to TTY/ANSI/OS9 codes
L1040               ldx       #u00DF              Point to modem buffer
                    ldy       #u070D              Point to screen output buffer
                    ldb       <u0C89              Get # bytes waiting in modem buffer
                    lda       >u0CA6              get terminal type
                    lbeq      L2D1E               TTY, copy buffer with no editing & exit
                    deca                          OS9?
                    beq       L0C8D               Yes, go do
                    deca                          ANSI?
                    beq       L0CF6               Yes, go (illegal values fall thru to OS9:was TTY)

* Loop to Convert OS9 codes to output buffer
* NOTE: ORIGINALLY STRIPPED HI-BIT OFF OF CHARS (anda #$7f) & also had code
*   after the strip to cmpa #$7f/BHI L0CA2, which would eat the char. Taken
* out to allow foreign & extra chars through. May want to add parser later
* to eat '.' illegal chars, but leave foreign symbols alone.
L0C8D               lda       ,x+                 get a byte
                    cmpa      #C$SPAC             control chars?
                    blo       L0CA2               yes, skip ahead
                    lbsr      L13CF               update internal cursor position
L0C9C               sta       ,y+                 save to output buffer
L0C9E               decb                          done all data?
                    bne       L0C8D               no, keep going
                    rts                           return

* Parse control codes
L0CA2               cmpa      #C$BSP              backspace?
                    bne       L0CAB               no, check CR
                    lbsr      L13EC
                    bra       L0C9C               go save char in output buffer & continue

L0CAB               cmpa      #C$CR               carriage return?
                    bne       L0CC5               no, check CLS
                    lbsr      L1405               u0C94=1
                    tst       >u0CA8              Auto line feed on?
                    beq       L0C9C               No, go save char in output buffer
* NOTE: CHANGE 140E TO ONLY PSHS A, ONLY LDA u0C95,u ETC.
                    lbsr      L140E               Go bump Y coord down by 1 for auto-lf on CR
                    inc       <u0C89              Increase size of converted buffer by 1
                    sta       ,y+                 Save CR in output buffer
                    lda       #C$LF               Get Line feed
                    bra       L0C9C               Go add that to buffer too

L0CC5               cmpa      #C$FORM             CLS?
                    bne       L0CCE               no, check bell
                    lbsr      L1422               u0C94 = $0101
                    bra       L0C9C               Go save CLS code in output buffer

L0CCE               cmpa      #C$BELL             bell?
                    beq       L0C9C               Yes, go save in output buffer
                    cmpa      #C$LF               linefeed?
                    bne       L0CDB               No, check Up one line
                    lbsr      L140E               Go bump Y coord down by 1
                    bra       L0C9C               Save LF in output buffer

L0CDB               cmpa      #$09                Up one line code?
                    bne       L0CE4               No, check next
* NOTE: USELESS LBSR...PERHAPS LEFT IN FOR AN OPTION TO HAVE CHR$(9) BE EITHER
* UP 1 LINE (FOR OS9) OR TAB CHAR??? IF REMOVING, SHOULD ALSO REMOVE RTS @
* 1BDE
*         lbsr  L1BDE        Spot reserved for TAB handler
                    bra       L0C9E               Eat the char & continue
* All other <CTRL> chars& chars >128, don't save in buffer?
L0CE4               dec       <u0C89              Shrink size of converted buffer by 1
                    bra       L0C9E               Eat char & continue

L0CF6               lda       >u0C8A              Are we processing an <ESC> sequence?
                    lbne      L0D9F               yes, go to ANSI processor
                    lda       ,x+                 get data
                    cmpa      #C$SPAC             printable?
                    blo       L0D13               no, check control codes
                    cmpa      #$80                Hi bit char?
                    blo       L0D0A               No, save it in out buffer
                    lda       #'*                 Yes, replace with '*'
L0D0A               lbsr      L13CF               update internal cursor position
L0D0D               sta       ,y+                 Save char in buffer
L0D0F               decb
                    bne       L0CF6
                    rts

L0D13               cmpa      #C$BSP              is it backspace?
                    beq       L0D31               yes, go process
                    cmpa      #C$CR               is it carriage return?
                    beq       L0D42               yes, go process
                    cmpa      #C$LF               is it line feed?
                    beq       L0D58               yes, go process
                    cmpa      #C$FORM             Clear screen?
                    beq       L0D5D               Yes, go process
                    cmpa      #C$BELL             <CTRL>-<G> Bell?
                    beq       L0D0A               Yes, go process
                    cmpa      #C$EOF              <ESC>?
                    beq       L0D62               Yes, ANSI code coming...go set up
L0D2B               dec       <u0C89              decrement # chars in converted output buffer
                    bra       L0D0F               Eat the char & continue processing

* Process backspace - ANSI (OS9, if it backspaces off left side, will go up
*   1 line & set the cursor to the right side. ANSI will stop at the left side
L0D31               pshs      a                   Save char
                    lda       >u0C94              get cursor X position
                    cmpa      #$01                Already at far left side?
                    puls      a                   Restore char
                    beq       L0D2B               Already @ left side, eat char & continue
                    dec       >u0C94              Bump X cursor coord left by 1
                    bra       L0D0D               continue processing

* Process carriage return
L0D42               lbsr      L1405               Reset X coord to 1
                    tst       >u0CA8              Auto LF on?
                    beq       L0D0D               No, go save CR
                    lbsr      L140E               Yes, bump up Y coord by 1
                    inc       <u0C89              Bump up size of converted output buffer by 1
                    sta       ,y+                 Save CR char in output buffer
                    lda       #C$LF               Also add an LF
                    bra       L0D0D

* Process line feed
L0D58               lbsr      L140E               Bump Y coord up by 1
                    bra       L0D0D               Go save LF in converted output buffer

* Process CLS
L0D5D               lbsr      L1422               Set X&Y coords to 1,1
                    bra       L0D0D               Save char in converted output buffer

* Process <ESC>
L0D62               inc       >u0C8A              flag <ESC> received
                    clr       >u0C8B
                    lda       #$FF                ??? Init ANSI convert buffer to empty
                    pshs      x                   Save converted output buffer ptr
                    ldx       #u0C60              ??? Point to ANSI convert buffer?
                    stx       >u0C80              Save ptr
                    clr       ,x                  Clear our 2 of ANSI convert bytes
                    clr       1,x
                    sta       2,x                 Flag end of ANSI convert buffer
                    ldx       #u0B0D              Point to start of ANSI seq. bffr (no ESC)
                    stx       >u0C8D              Save ptr to it
                    dec       <u0C89              Dec # chars in converted output buffer
                    puls      x                   Restore converted output ptr
                    bra       L0D0F               Eat the ESC for now & continue

* Parse ANSI escape sequence
* Entry: X=Modem buffer ptr, Y=Converted output buffer ptr, B=# bytes to do
L0D9F               ldu       >u0C8D              get ANSI sequence buffer ptr
                    lda       ,x+                 get character
                    sta       ,u+                 save it into ANSI sequence buffer
                    stu       >u0C8D              save updated ANSI sequence buffer ptr
                    cmpa      #'[                 the start char?
                    beq       L0DB9               yes, continue
                    cmpa      #'@                 printable char?
                    bhi       L0DC0               yes, check for finish
L0DB9               dec       <u0C89              decrement converted output buffer count
                    lbra      L0D0F               continue

* Start ANSI sequence found (<ESC>-[)
L0DC0               clr       >u0C8A              Clear out ANSI sequence found flag???
                    sta       >u0C8C              Save char
                    dec       <u0C89              Dec converted output buffer count
                    pshs      y,b                 Preserve converted output bffr ptr&# chars left
                    ldy       >u0C80              Get ptr to converted ANSI buffer
                    lda       #$FF                Flag as unused for now
                    sta       ,y
                    ldy       #u0C60              Point to converted ANSI buffer
                    sty       >u0C80
                    ldy       #u0B0D+1            Point to Start of ANSI sequence buffer (no ESC)+1
                    sty       >u0C8D              Save ptr
L0DEE               lda       ,y+                 Get char
                    cmpa      #$40                '@'
                    bhi       L0E3B               Letter or higher, go do
                    cmpa      #$3A                ':'
                    blo       L0DFC               Possible ASCII numeric, skip ahead
                    ldb       #$FE
                    bra       L0E19

L0DFC               suba      #$30                Drop possible numeric down to binary equivalent
                    sta       >u0C84              Save it
                    lda       ,y+                 Get next char
                    cmpa      #'9                 above numeric?
                    bhi       L0E33               Yes, skip ahead
                    suba      #$30                Bump down to binary version
                    sta       >u0C85              Save it
                    lda       >u0C84              Get 1st one again (10's digit)
                    ldb       #10                 Multiply by 10
                    mul
                    addb      -1,y                Add in one's digit
                    subb      #$30
L0E19               pshs      x
                    ldx       >u0C80
                    stb       ,x+
                    ldb       #$FF
                    stb       ,x
                    stb       1,x
                    stb       2,x
                    stx       >u0C80
                    puls      x
                    bra       L0DEE

L0E33               leay      -1,y
                    ldb       >u0C84
                    bra       L0E19

L0E3B               puls      y,b
                    lda       >u0C8C
                    cmpa      #$6D                m
                    beq       L0E84
                    cmpa      #$4A                J
                    lbeq      L10E2
                    cmpa      #$66                f
                    lbeq      L1467
                    cmpa      #$48                H
                    lbeq      L1467
                    cmpa      #$43                C
                    lbeq      L14B0
                    cmpa      #$44                D
                    lbeq      L14F4
                    cmpa      #$41                A
                    lbeq      L151D
                    cmpa      #$42                B
                    lbeq      L1546
                    cmpa      #$73                s
                    lbeq      L1433
                    cmpa      #$75                u
                    lbeq      L1442
                    cmpa      #$4B                K
                    lbeq      L1102
                    lbra      L0D0F

L0E84               pshs      x,d
                    ldx       #u0C60
L0E8A               lda       ,x+
                    cmpa      #$FF
                    beq       L0EA6
                    tsta
                    beq       L0EDD
                    cmpa      #$01
                    beq       L0E8A
                    cmpa      #$08
                    blo       L0EAB
                    cmpa      #$26
                    blo       L0EB3
                    cmpa      #$30
                    blo       L0EC8
                    bra       L0E8A

L0EA6               puls      x,d
                    lbra      L0D0F

L0EAB               pshs      x
                    leax      >L03E6,pc
                    bra       L0EE3

L0EB3               ldb       <u0065
                    cmpb      #$02
                    beq       L0E8A
                    cmpa      #$1E
                    blo       L0E8A
                    suba      #$1E
                    pshs      x
                    leax      >L040E,pc
                    bra       L0EE3

L0EC8               ldb       <u0065
                    cmpb      #$02
                    beq       L0E8A
                    cmpa      #$28
                    blo       L0E8A
                    suba      #$28
                    pshs      x
                    leax      >L0436,pc
                    bra       L0EE3

L0EDD               pshs      x
                    leax      >L03D6,pc
L0EE3               ldb       #5
                    mul
                    leax      b,x
                    lbsr      L10D2
                    puls      x
                    bra       L0E8A

L0EEF               lda       <u003E              Get path # to status window
                    os9       I$Close             Close it
                    lbsr      L134D
                    lbsr      L135C
                    lbsr      L13BA
                    lda       <u0072              Get path # to VRN
                    beq       L0F06               None, skip ahead
                    os9       I$Close             Close it
L0F06               tst       <u0025
                    beq       L0F14
                    lbsr      L43CA
                    lda       <u002A
                    os9       I$Close
L0F14               clrb
L0F15               os9       F$Exit
L0F18               cmpb      #$80
                    bne       L0F1F
                    inc       <u0073
L0F1F               rti

* Update on-screen timer
L0F20               pshs      y,x,a
                    ldx       #u009C              Point to FColor buffer
                    lda       <u0088              Get bckgrnd color of main window
                    sta       $02,x               Save as color to use
                    lda       <u003E              Get path # to status line window
                    ldy       #$0003
                    os9       I$Write             Set foreground color
                    ldx       #u0077              Send out current Timer string
                    ldy       #$000B
                    os9       I$Write
                    ldx       #u009C              Point to Fcolor buffer
                    lda       <u0087              Get foreground color
                    sta       $02,x               Save it
                    lda       <u003E              Get path to status window
                    ldy       #$0003              Change color on status window back to normal
                    os9       I$Write
                    puls      pc,y,x,a

* Entry: X=# ticks to sleep
L0F56               tst       <u0075              Is the timer function on?
                    beq       L0F6F               No, go to sleep
                    pshs      a                   Preserve # seconds
                    lda       <u0074              Yes, get current # seconds
L0F60               cmpa      <u0073              Different than last recorded # seconds?
                    beq       L0F6D               No, go to sleep
                    bsr       L0F78               Yes, go update timer on status bar
                    inca                          Bump # seconds up
                    sta       <u0074              Save # seconds
                    bra       L0F60               Check if it is different than last recorded?

L0F6D               puls      a                   Restore # seconds
L0F6F               os9       F$Sleep             Sleep for requested # ticks
                    cmpx      #$0000              Sleep for full requested period?
                    bne       L0F56               No, go update timer functions & sleep some more
                    rts                           Yes, return

L0F78               pshs      y,x,d               Preserve regs
                    ldx       #u0077              Point to ASCII on-screen timer packet
                    ldb       #10                 Point to end of packet (1's of seconds field)
L0F7F               bsr       L0F8C               Do 1 char at a time
                    tsta                          Do we need the next field updated too?
                    bpl       L0FAC               No, go update it on screen & return
                    decb                          Bump timer packet ptr down to previous field
                    decb
                    cmpb      #$04                Hit beginning (finished hours)?
                    bhs       L0F7F               No, go update next field
L0FAC               lda       <u003E              Get path to status window
                    ldy       #$000B              Get size of time string
                    os9       I$Write             Write it out
                    puls      pc,y,x,d            Restore & return

* Update 1's field
L0F8C               lda       b,x                 Get byte from timer
                    cmpa      #'9                 9?
                    beq       L0F96               Yes, skip ahead
L0F90               inca                          No, increment it to next one
                    sta       b,x                 Save result & return
                    rts

* Update 10's field
L0F96               lda       #'0                 Wrap it back to a 0
                    sta       b,x                 Save 0
                    decb                          Bump ptr to 10's field in ASCII time packet
                    lda       b,x                 Get char
                    cmpa      #'5                 5?
                    bne       L0F90               No, safe to increment & exit
L0FA5               lda       #'0                 Wrap it back to 0
                    sta       b,x                 Save it
                    lda       #$FF                Flag to say we need next field (minutes/hours)
                    rts                           updated & return

L1062               pshs      y,x,d               Preserve regs
                    ldb       <u0C89              Get LSB of size of converted text buffer
                    ldy       <u006C              Get ptr to Zmodem start header
                    ldx       #u00DF              Get ptr to modem buffer
L1070               tstb
                    beq       L10A8
                    tst       <u006B
                    beq       L1084
                    lda       ,x
                    cmpa      #$30
                    beq       L10C1
                    cmpa      #$31
                    beq       L10C7
                    bra       L1090

L1084               lda       ,x+
                    anda      #$7F
                    decb
                    clr       <u0071
L108C               cmpa      ,y
                    beq       L10AA
L1090               leay      >L031A,pc
                    sty       <u006C
                    tst       <u0071
                    bne       L10A2
                    inc       <u0071
                    bra       L108C

L10A2               clr       <u0071
                    tstb
                    bne       L1084
L10A8               puls      pc,y,x,d

L10AA               leay      1,y
                    sty       <u006C
                    tst       ,y
                    bne       L10A2
                    inc       <u006B
                    leay      >L031A,pc
                    sty       <u006C
                    bra       L1070

L10C1               inc       >u0CA0
                    bra       L10CB

L10C7               clr       >u0CA0
L10CB               lda       #$FF
                    sta       <u006B
                    bra       L10A8

L10D2               ldb       1,x
                    leax      2,x
L10D6               lda       ,x+
                    sta       ,y+
                    inc       <u0C89
                    decb
                    bne       L10D6
                    rts

L10E2               pshs      x,d
                    ldx       #u0C60
                    lda       ,x
                    cmpa      #$02
                    beq       L10F7
                    leax      >L0464,pc
                    bsr       L10D2
L10F4               lbra      L0EA6

L10F7               leax      >L045E,pc
                    bsr       L10D2
                    lbsr      L1422
                    bra       L10F4

L1102               pshs      x,d
                    leax      >L0461,pc
                    bsr       L10D2
                    lbra      L0EA6

* Print help screen
* Entry: None
L110D               ldd       #$1A01              get overlay start co-ordinates
                    std       >u0C8F
                    ldd       #$340D              get overlay size
                    std       >u0C91
                    lbsr      L1C81               place overlay
                    leax      L0109,pc            point to help screen text
                    lbsr      L1B03               print it
                    leax      L048F,pc            turn off cursor
                    lbsr      L1B03
L112C               lbsr      L2AC5               wait for a keypress
                    cmpa      #$20                was it space?
                    beq       L116B               yes, clean up & return
                    cmpa      #$05
                    beq       L116B               yes, clean up & return
                    cmpa      #$0C
                    bne       L113F
L113B               adda      #$80
                    bra       L1156

L113F               cmpa      #$0A
                    beq       L113B
                    ldb       L0A15,pc            get # commands possible
                    leax      L0A16,pc            point to command table
L114B               cmpa      ,x+                 find it?
                    beq       L1154               yes, go parse it
                    decb                          done?
                    bne       L114B               no, keep looking
                    bra       L112C               not legal, go wait for new keypress

L1154               adda      #$A0
L1156               pshs      a
                    leax      L03C4,pc            get rid of overlay
                    lbsr      L1B03
                    leax      L048B,pc            turn cursor on
                    lbsr      L1B03
                    puls      a                   restore command
                    lbra      L1597               go parse command

L116B               leax      L03C4,pc            get rid of overlays
                    lbsr      L1B03
                    lbsr      L1BAD               purge all remaining keyboard data
                    leax      L048B,pc            turn cursor on
                    lbsr      L1B03
                    lbra      L0C5E               return to main loop

* Get modem path options
L117F               pshs      x,d                 Preserve regs used
                    lda       <u002B              Get path # to modem
                    clrb                          SS.Opt call
                    ldx       #u0C2E              Point to buffer to hold Option section
                    os9       I$GetStt            Get modem path options
                    puls      pc,x,d              Restore regs & return

* Update status line (baud, word length, etc...)
* Entry: None
L118F               pshs      d,x,y
                    ldx       #u0C2E              point to
                    ldb       >u0CA5              get baud
                    stb       PD.BAU-PD.OPT,x
                    ldb       PD.PAR-PD.OPT,x
                    andb      #$0F
                    orb       >u0CAC
                    stb       PD.PAR-PD.OPT,x
                    ldb       >u0CAF
                    stb       PD.XON-PD.OPT,x
                    ldb       >u0CB0
                    stb       PD.XOFF-PD.OPT,x
                    ldb       >u0CB1
                    stb       PD.EKO-PD.OPT,x
                    ldb       >u0CA9
                    stb       PD.ALF-PD.OPT,x
                    clr       PD.PAU-PD.OPT,x
                    leax      PD.BSP-PD.OPT,x
                    ldd       #$000a              Clear 10 bytes from BSP to BSE
L11C8               sta       ,x+
                    decb
                    bne       L11C8
                    lda       <u002B              get path to modem
                    cmpa      #$03                is it legal?
                    lbls      L12B3               no, return
                    ldx       #u0C2E              point to option buffer
                    ldb       #SS.Opt             set 'em
                    os9       I$SetStt
                    ldx       #u0095              point to
                    ldd       #$025A              get CurXY codes
                    std       ,x                  save 'em
                    ldb       #$20                get Y co-ordinate
                    stb       2,x                 save it
                    ldy       #3                  get length
                    lda       <u003E              get path to status window
                    os9       I$Write             position cursor for baud rate text
                    lda       >u0CA5              get baud rate
                    anda      #$07                keep only baud bits
                    ldb       #5                  get length of baud text entrys
                    mul                           calculate offset
                    leax      L0652,pc            point to baud rate text table
                    leax      b,x                 point to baud rate
                    ldy       #5                  get length
                    lda       <u003E              get path to status line
                    os9       I$Write             print current baud
                    ldb       #$61                move X cursor position for word length
                    ldx       #u0095
                    stb       1,x
                    lda       <u003E
                    ldy       #$0003
                    os9       I$Write
                    ldb       >u0CA5
                    bitb      #$20
                    bne       L122D
                    ldb       #'8
                    bra       L122F

L122D               ldb       #'7
L122F               ldx       #u0044
                    stb       ,x
                    ldy       #1
                    os9       I$Write
                    ldb       #$63
                    ldx       #u0095
                    stb       1,x
                    ldy       #3
                    lda       <u003E
                    os9       I$Write
                    lda       >u0CAC
                    anda      #$E0
                    cmpa      #$A0
                    bne       L125D
                    leax      L0991,pc            point to 'Mark'
                    bra       L127F               go print it

L125D               cmpa      #$E0
                    bne       L1267
                    leax      L0995,pc            point to 'Space'
                    bra       L127F               go print it

L1267               cmpa      #$60
                    bne       L1271
                    leax      L099B,pc            point to 'Even'
                    bra       L127F               go print it
L1271               cmpa      #$20
                    bne       L127B
                    leax      L09A0,pc            point to 'Odd'
                    bra       L127F               go print it

L127B               leax      L09A5,pc            point to 'None'
L127F               lda       <u003E              get path to status line
                    ldy       #1
                    os9       I$Write
                    ldb       #$65
                    ldx       #u0095
                    stb       1,x
                    lda       <u003E
                    ldy       #3
                    os9       I$Write
                    ldb       >u0CA5
                    bpl       L12A5
                    ldb       #'2
                    bra       L12A7

L12A5               ldb       #'1
L12A7               ldx       #u0044
                    stb       ,x
                    ldy       #1
                    os9       I$Write
L12B3               puls      d,x,y,pc

* Setup path options for local keyboard to communicate with modems
* Entry: None
L12B5               pshs      d,x,y
                    ldx       #u13A9              point to a buffer
                    ldy       #u0C0C              point to original path options
                    ldb       #$20                get size
                    lbsr      L2D26               move it
                    ldx       #u13A9              point to the buffer
                    clr       PD.EKO-PD.OPT,x     turn off echo
                    lda       >u0CA8
                    sta       PD.ALF-PD.OPT,x     save linefeed stat
                    clr       PD.PAU-PD.OPT,x     turn off pause
                    lda       >u13A3
                    sta       PD.EOF-PD.OPT,x     save EOF char
                    lda       >u13A6
                    sta       PD.PSC-PD.OPT,x     save pause char
                    lda       >u13A4
                    sta       PD.INT-PD.OPT,x     save interupt char
                    lda       >u13A5
                    sta       PD.QUT-PD.OPT,x     save quit char
                    ldd       #1*256+SS.Opt       Set the options
                    os9       I$SetStt
                    puls      d,x,y,pc

* Get current window settings
*
* Entry: None
L12F5               pshs      d,x                 Preserve regs
                    ldd       #SS.Opt             Get option section path dsc. for Std In
                    ldx       #u0C0C              Buffer to hold option packet
                    os9       I$GetStt            Get current option settings
                    lda       PD.PAR-PD.OPT,x     Get current parity (window type)
                    bpl       L1348               If not a window, exit with error
                    ldd       #1*256+SS.FBRgs     Get fore/background/border regs from Std Out
                    os9       I$GetStt
                    std       <u008D              Save fore/background colors
                    tfr       x,d                 Move border to splittable register
                    stb       <u008F              Save border color
                    ldx       #u0C50
                    ldd       #1*256+SS.Palet     Get current palette settings from Std Out
                    os9       I$GetStt            Get current palette settings
                    ldd       #1*256+SS.ScSiz     Get screen size from Std Out
                    os9       I$GetStt            Get current screen size
                    tfr       x,d                 Move width to splittable register
                    stb       <u0082              Save screen width
                    tfr       y,d                 Move height to splittable register
                    stb       <u0083              Save screen height
                    ldd       #1*256+SS.ScTyp     Get screen type from Std Out
                    os9       I$GetStt
                    sta       <u0084              Save it
                    clrb                          No error & exit
L1346               puls      pc,x,d

L1348               comb                          Exit with Illegal Window Type error
                    ldb       #$B7
                    bra       L1346

* Set local path options
*
* Entry: None
L134D               pshs      d,x                 Preserve regs
                    ldd       #SS.Opt             Set option section from Std In path
                    ldx       #u0C0C              Point to buffer holding new settings
                    os9       I$SetStt            Set them
                    puls      d,x,pc              Restore regs & return

L135C               pshs      y,x,d
                    leay      >L0469,pc           Point to main window DWEnd/DWSet
                    ldb       #16                 Copy 16 bytes (?)
                    ldx       #u13A9
                    lbsr      L2D26
                    ldx       #u13A9
                    lda       <u0084
                    sta       4,x
                    clra
                    sta       6,x
                    ldd       <u0082
                    std       7,x
                    ldd       <u008D
                    std       9,x
                    lda       <u008F
                    sta       11,x
                    ldy       #12                 # bytes to write
                    lda       #$01                Write it out
                    os9       I$Write
                    ldx       #u0C50
                    ldd       #1*256+SS.Palet     Set palettes back to normal
                    os9       I$SetStt
                    ldd       #$1B21
                    std       ,x
                    lda       #$01
                    ldy       #$0002
                    os9       I$Write
                    puls      pc,y,x,d

L13BA               leax      >L03A7,pc           Inverse,Underline,Blink OFF/CLS
                    lbra      L1B03               Will RTS from there

* Add 1 to current cursor position (next line if needed)
L13CF               pshs      d
                    ldd       >u0C94              get current position
                    inca                          add 1 to X
                    cmpa      <u0090              past max?
                    bls       L13E6               no, save & return
                    lda       #1                  reset it
                    incb                          add 1 to Y
                    cmpb      <u0091              past max?
                    bls       L13E6               no, save & return
                    decb                          bump it back
L13E6               std       >u0C94              save new position
                    puls      d,pc                restore & return

* Subtract 1 from current cursor position
L13EC               pshs      d
                    ldd       >u0C94              get current cursor position
                    deca                          subtract 1 from X
                    bne       L13FF               minimum?
                    lda       <u0090              yes, reset to end (will be on previous line)
                    decb                          take 1 off Y
                    bne       L13FF               minimum?
                    ldd       #$0101              yes, reset
L13FF               std       >u0C94              save new position
                    puls      d,pc                restore & return

L1405               clr       >u0C94              reset X position
                    inc       >u0C94              add 1
                    rts

* Bump Y coord to next line down
L140E               pshs      a                   Preserve reg we use
                    lda       >u0C95              Get current Y coord
                    inca                          Bump up
                    cmpa      <u0091              We past biggest Y coord allowable?
                    bls       L141C               No, save new one
                    deca                          Yes, bump it back a line
L141C               sta       >u0C95              Save new Y coord
                    puls      pc,a                Restore & return

L1422               pshs      d                   Preserve regs
                    ldd       #$0101              Upper left corner of screen
                    std       >u0C94              Save coords
                    puls      pc,d                Restore D & return

L1433               pshs      d
                    ldd       >u0C94
                    std       >u0C96
                    puls      d
                    lbra      L0D0F

L1442               pshs      d
                    lda       #$02
                    sta       ,y+
                    ldd       >u0C96
                    std       >u0C94
                    adda      #$1F                Bump X&Y coords to base $20
                    addb      #$1F
                    std       ,y++
                    ldb       <u0C89
                    addb      #$03
                    stb       <u0C89
                    puls      d
                    lbra      L0D0F

L1467               pshs      x,d
                    ldx       #u0C60
                    lda       #$02
                    sta       ,y+
                    lda       1,x
                    beq       L1483
                    cmpa      #$FE
                    bne       L147D
                    lda       2,x
                    beq       L1483
L147D               cmpa      <u0090
                    bls       L1485
L1483               lda       #$01
L1485               sta       >u0C94
                    adda      #$1F
                    sta       ,y+
                    lda       ,x
                    beq       L1497
                    cmpa      <u0091
                    bls       L1499
L1497               lda       #$01
L1499               sta       >u0C95
                    adda      #$1F
                    sta       ,y+
                    ldb       <u0C89
                    addb      #$03
                    stb       <u0C89
                    puls      x,d
                    lbra      L0D0F

L14B0               pshs      x,d
                    ldx       #u0C60
                    lda       ,x
                    cmpa      <u0090
                    bhs       L14C1
                    tsta
                    bne       L14C3
L14C1               lda       #$01
L14C3               adda      >u0C94
                    cmpa      <u0090
                    bls       L14D1
                    lda       <u0090
L14D1               sta       >u0C94
L14D5               ldb       #$02
                    stb       ,y+
                    ldd       >u0C94
                    adda      #$1F                Bump up since base=$20 (both coords)
                    addb      #$1F
                    std       ,y++                Save new coords
                    ldb       <u0C89
                    addb      #$03
                    stb       <u0C89
                    puls      x,d
                    lbra      L0D0F

L14F4               pshs      x,d
                    ldx       #u0C60
                    lda       ,x
                    cmpa      <u0090
                    bhs       L1505
                    tsta
                    bne       L1507
L1505               lda       #$01
L1507               sta       >u0C84
                    lda       >u0C94
                    suba      >u0C84
                    bgt       L1517
                    lda       #$01
L1517               sta       >u0C94
                    bra       L14D5

L151D               pshs      x,d
                    ldx       #u0C60
                    lda       ,x
                    cmpa      <u0091              Fit within Y size of main window?
                    bhs       L152E
                    tsta
                    bne       L1530
L152E               lda       #$01
L1530               sta       >u0C84
                    lda       >u0C95
                    suba      >u0C84
                    bgt       L1540
                    lda       #$01
L1540               sta       >u0C95
                    bra       L14D5

L1546               pshs      x,d
                    ldx       #u0C60
                    lda       ,x
                    cmpa      <u0091              Y coord past size of window?
                    bhs       L1557               Yes, force it to 1
                    tsta                          Is it 0?
                    bne       L1559               No, legit, skip ahead
L1557               lda       #$01                Force size to 1
L1559               adda      >u0C95
                    cmpa      <u0091
                    bls       L1567
                    lda       <u0091
L1567               sta       >u0C95
                    bra       L14D5

L156E               clra                          Std In
                    ldy       #$0001
                    ldx       #u060E
                    os9       I$Read
* NOTE: SHOULD BE ABLE TO CHANGE SOME OF THE LDB <U0041/ANDB TO KEEP B
* AND USE BITB INSTEAD
L157B               ldd       #SS.KySns           Get key sense data from Std In
                    os9       I$GetStt
                    sta       <u0041              save key sense data
                    lda       >u060E
                    clr       >u060E
                    ldb       >u0CA6
                    cmpb      #2
                    lbeq      L21F0
* Check special command keys
L1597               cmpa      #$1A                download a file? (PgDn)
                    bne       L15A5               no, check upload
                    ldb       <u0041              get key sense info
                    andb      #DOWNBIT            is it down arrow?
                    beq       L15A5               no, skip ahead
                    lbra      L3580               process download

L15A5               cmpa      #$1C                upload a file? (PgUp)
                    bne       L15B3               no, check quit
                    ldb       <u0041              get key sense info
                    andb      #UPBIT              is it up arrow?
                    beq       L15B3               no, skip ahead
                    lbra      L35DF               process upload

L15B3               cmpa      #$F1                quit supercomm? (ALT-Q)
                    lbeq      L1B0C               yes,
                    cmpa      #$E8                hangup modem? (ALT-H)
                    lbeq      L1983               yes,
                    cmpa      #$AF                help? (ALT-?)
                    lbeq      L110D
                    cmpa      #$E1                autodial? (ALT-A)
                    lbeq      L2EBF
                    cmpa      #$E2                baud rate change? (ALT-B)
                    bne       L15D2
                    lbsr      L1D2F
L15D2               cmpa      #$E9                online timer toggle? (ALT-I)
                    bne       L15D9
                    lbra      L175C

L15D9               cmpa      #$F4                change terminal type? (ALT-T)
                    bne       L15E0
                    lbsr      L1E50
L15E0               cmpa      #$F5                update supercomm? (ALT-U)
                    bne       L15E7
                    lbsr      L2E83
L15E7               cmpa      #$E3                clear screen? (ALT-C)
                    bne       L15EE
                    lbsr      L1EDC
L15EE               cmpa      #$85                transmit break?
                    bne       L15F5
                    lbsr      L1D14
L15F5               cmpa      #$18                cntrl-X
                    bne       L15FD               no,
                    lda       #$7F                convert it to underscore (DELETE line on IBM's)
                    bra       L1659

L15FD               cmpa      #$F2                reset palettes?
                    lbeq      L16CB
                    cmpa      #$F3                shell access?
                    lbeq      L16DC
                    cmpa      #$8A                download #2? (ALT-DWN)
                    lbeq      L3580
                    cmpa      #$8C                upload #2? (ALT-UP)
                    lbeq      L35DF
                    cmpa      #$EF                change options? (ALT-O)
                    bne       L161C
                    lbsr      L1F1D
L161C               cmpa      #$ED                open/close buffer? (ALT-M)
                    bne       L1623
                    lbsr      L2364
L1623               cmpa      #$E4                change directory? (ALT-D)
                    bne       L162A
                    lbsr      L22B1
L162A               cmpa      #$FA                conference mode? (ALT-Z)
                    bne       L1631
                    lbsr      L2610
L1631               ldb       <u0041              get key sense data
                    andb      #ALTERBIT           is the ALT key down?
                    beq       L1646               no, skip ahead
                    cmpa      #$B1
                    blo       L1659
                    cmpa      #$B8
                    bhi       L1659
                    lbsr      L1A21
                    lbra      L0C5E

L1646               cmpa      #$B1                is it F1?
                    lbeq      L110D               yes, print help screen
                    cmpa      #$18
                    bne       L1659
                    ldb       <u0041
                    andb      #LEFTBIT
                    beq       L1659
                    lda       #$7F                convert it to underscore (DELETE line on IBM's)
L1659               cmpa      #$AF
                    bhi       L16C8
                    sta       >u04EF
                    tst       >u0CAA              key click on?
                    beq       L1675               no, skip ahead
                    ldd       #1*256+SS.Tone      Tone to Std Out
                    ldx       #$2801
                    ldy       #$0900
                    os9       I$SetStt
L1675               ldy       #$0001
                    ldx       #u04EF
                    lda       ,x
                    cmpa      #C$CR
                    bne       L168F
                    tst       >u0CA9
                    beq       L168F
                    lda       #$0A
                    sta       1,x
                    leay      1,y
L168F               lda       <u002B              Get path to modem
                    os9       I$Write
                    tst       >u04EF
                    bmi       L16C8
                    lda       >u0CA7
                    beq       L16C8
                    tst       >u0CA8
                    beq       L16BB
                    lda       >u04EF
                    cmpa      #C$CR
                    bne       L16BB
                    lda       #$0A
                    sta       >u04F0
                    ldy       #$0002
                    bra       L16BF

L16BB               ldy       #$0001
L16BF               ldx       #u04EF
                    lda       #$01
                    os9       I$Write
L16C8               lbra      L0C5E

* Reset palettes (ALT-R)
* Entry: None
L16CB               pshs      a,x,y               preserve regs
                    leax      L03D6,pc            reset window codes
                    lbsr      L1B03
                    lbsr      L1C57               set palettes per terminal type
                    puls      a,x,y               restore regs
                    lbra      L0C5E               go back to main loop

* Shell Access (ALT-S)
L16DC               pshs      u                   preserve data area pointer
                    lbsr      L134D               reset path options
                    ldb       #$13
                    leay      L03B2,pc            point to overlay for shell
                    ldx       #u13A9              point to buffer
                    lbsr      L2D26               move 'em
                    ldx       #u13A9              point to buffer
                    lda       <u0090              get window X size
                    sta       5,x                 save it
                    lda       <u0091              get Y size
                    tst       <u0040              conference mode on?
                    beq       L1703               no, skip ahead
                    suba      #$03                take off size of conference window
L1703               sta       6,x                 save Y size
                    lda       <u0089              get FColor
                    ldb       <u0088              get BColor
                    std       7,x                 save 'em
                    lda       #1                  place overlay
                    ldy       #9
                    os9       I$Write
                    leau      L02E5,pc            point to parameters
                    leax      L02E0,pc            point to 'shell'
                    ldd       #$1100              Type/Language & default data size
                    os9       F$Fork              execute a shell
                    puls      u                   restore data mem pointer
                    bcs       L173D               error, skip ahead
                    sta       <u0076              save process #
L172D               ldx       #1                  get # ticks
                    lbsr      L0F56               sleep
                    os9       F$Wait              wait for shell to die
                    bcs       L173D               error, skip ahead
                    cmpa      <u0076              was it my shell?
                    bne       L172D               no, go back & wait
L173D               lda       #1                  get path
                    leax      L03C6,pc            point to overlay end codes
                    ldy       #2                  get length
                    os9       I$Write             get rid of overlay
                    lbsr      L12B5               set path options back to me
                    lbra      L0C5E               go back to main loop

L1750               lda       ,x+                 Keep copying until <SPACE> or size B is reached
                    sta       ,y+
                    cmpa      #C$SPAC
                    beq       L175B
                    decb
                    bne       L1750
L175B               rts

* Toggle On-Line timer (ALT-I)
L175C               tst       <u0072              VRN present?
                    beq       L176C               no, return to main loop
                    lda       <u0075              currently active?
                    beq       L176F               no, turn it on
                    clr       <u0075              turn it off
                    lbsr      L0F20               print time
L176C               lbra      L0C5E               return to main loop

L176F               inc       <u0075              flag timer on
                    leax      L0366,pc            point to ASCII string '00:00:00'
                    ldy       #u0077              point to buffer
                    ldb       #$0B                get length
                    lbsr      L2D1E               move it
                    ldx       #u0077              point to buffer
                    ldy       #$000B              get length
                    lda       <u003E              get path to stat window
                    os9       I$Write             print the time
                    lda       <u0073              get current second from VRN
                    sta       <u0074              save it into timer flag
                    lbra      L0C5E               return to main loop

* External Zmodem file receive
L1793               ldd       #$0802              get overlay start co-ordinates
                    std       >u0C8F
                    ldd       #$400A              get overlay size
                    std       >u0C91
                    lbsr      L1C81               place overlay
                    leax      >L02F0,pc           point to 'Zmodem file receive...'
                    lbsr      L1B03               print it
                    leax      >L048F,pc           turn off cursor
                    lbsr      L1B03
                    ldx       #u13A9              point to a buffer
                    ldd       #1*256+SS.Opt       Get path options for Std Out
                    os9       I$GetStt
                    ldx       #u13A9
                    ldd       #$0100              SS.Opt for Std Out & settings below
                    sta       $05,x
                    stb       $07,x
                    os9       I$SetStt            Set them
                    clra                          Duplicate window path
                    os9       I$Dup
                    sta       <u006E
                    clra                          Close Std In path
                    os9       I$Close
                    lda       <u002B              get path to modem
                    os9       I$Dup
                    leau      >L02E9,pc           point to parameters for RZ
                    leax      >L02E6,pc           point to RZ
                    ldy       #$000A              get size of parameters
                    ldd       #$1100              Type/Lang & default mem size
                    os9       F$Fork              Call RZ
                    ldu       #$0000
                    pshs      cc
                    sta       <u0076              save process #
                    clra                          Restore Std In window path
                    os9       I$Close
                    lda       <u006E
                    os9       I$Dup
                    lda       <u006E              get duplicate path
                    os9       I$Close             close it
                    puls      cc
                    bcs       L1846
L180E               ldx       #$0001
                    lbsr      L0F56
                    ldd       #$0001              SS.Ready from Std In
                    os9       I$GetStt
                    bcs       L1836               No data ready, skip ahead
                    clra
                    tstb                          0 bytes ready?
                    beq       L1836               Yes, skip ahead
                    tfr       d,y                 Transfer # bytes waiting to Y
                    ldx       #u13A9              Point to buffer
                    os9       I$Read              Get that many bytes
                    lda       >u13A9
                    cmpa      #$05
                    bne       L1836
                    lbsr      L197B
L1836               os9       F$Wait
                    bcs       L1846
                    cmpa      <u0076
                    bne       L180E
                    tstb
                    beq       L1846
                    lbsr      L2AC5
L1846               lbsr      L1CDE
                    leax      >L048B,pc
                    lbsr      L1B03
                    lbsr      L12B5
                    lbsr      L1BAD
                    lbra      L0C5E

* Send file via ZModem
L1859               ldd       #$0802              get overlay start co-ordinates
                    std       >u0C8F              save 'em
                    ldd       #$400A              get overlay size
                    std       >u0C91              save 'em
                    lbsr      L1C81               place overlay
                    leax      L0322,pc            point to 'External ZModem file send'
                    lbsr      L1B03               print it
                    ldy       #u070D              point to parameter buffer
                    sty       <u0048              save pointer to it
                    ldd       #'-*256+'v          Place -v in param buffer
                    std       ,y++
                    ldd       #'v*256+C$SPAC      Place 'v ' in param buffer
                    std       ,y++
L1887               leax      L055F,pc            point to 'File:'
                    pshs      y
                    lbsr      L1B03               print it
                    puls      y
                    ldb       #C$SPAC
                    lbsr      L1B61
                    tst       <u0021
                    lbne      L1968
                    ldx       #u060E
                    ldb       <u001D
                    cmpb      #$01
                    beq       L18B6
L18A9               lda       ,x+
                    sta       ,y+
                    decb
                    bne       L18A9
                    lda       #C$SPAC
                    sta       -1,y
                    bra       L1887

* Filename to call ZModem send
L031F               fcc       'sz'
                    fcb       C$CR

L18B6               lda       #C$CR               Append CR
                    sta       ,y+
                    tfr       y,d
                    subd      <u0048
                    std       <u0048
                    cmpd      #$0007
                    lbcs      L1968
                    lbsr      L1EDC
                    leax      L048F,pc            point to CurOff codes
                    lbsr      L1B03
                    ldx       #u13A9              Point to buffer to hold Options
                    ldd       #$0100              Get Options from Std Out path
                    os9       I$GetStt
                    ldd       #$0100              SS.Opt from Std Out
                    ldx       #u13A9              Point to buffer again
                    sta       $05,x               Auto line feed ON
                    stb       $07,x               Pause OFF
                    os9       I$SetStt            Set new options
                    clra                          Dupe Std In path
                    os9       I$Dup
                    sta       <u006E
                    clra                          Close Std In path
                    os9       I$Close
                    lda       <u002B
                    os9       I$Dup
                    ldy       <u0048
                    ldu       #u070D
                    leax      <L031F,pc           point to 'sz'
                    ldd       #$1100              Type/Lang & default mem size
                    os9       F$Fork              Fork SZ
                    pshs      cc
                    sta       <u0076
                    clra                          Close Std In
                    os9       I$Close
                    lda       <u006E
                    os9       I$Dup
                    lda       <u006E
                    os9       I$Close
                    puls      cc
                    bcs       L1968
L1930               ldx       #$0001
                    lbsr      L0F56
                    ldd       #SS.Ready           Data ready on Std In?
                    os9       I$GetStt
                    bcs       L1958
                    clra
                    tstb                          0 bytes?
                    beq       L1958
                    tfr       d,y                 Move # bytes ready to Y
                    ldx       #u13A9              Point to buffer to hold them
                    os9       I$Read              Read them in
                    lda       >u13A9
                    cmpa      #$05
                    bne       L1958
                    bsr       L197B
L1958               os9       F$Wait
                    bcs       L1968
                    cmpa      <u0076
                    bne       L1930
                    tstb
                    beq       L1968
                    lbsr      L2AC5
L1968               lbsr      L1CDE
                    lbsr      L12B5
                    leax      L048B,pc
                    lbsr      L1B03
                    lbsr      L1BAD
                    lbra      L0C5E
* Kill SZ process
L197B               lda       <u0076              get it's process #
                    clrb                          get kill signal
                    os9       F$Send              send it
                    rts                           return

* Hangup modem (ALT-H)
L1983               tst       <u0072              VRN present?
                    beq       L198E               no, skip ahead
                    clr       <u0075              Flag that timer will be off
                    lbsr      L0F20
L198E               ldd       #$2105
                    std       >u0C8F
                    ldd       #$0E03
                    std       >u0C91
                    lbsr      L1C81
                    leax      >L048F,pc
                    lbsr      L1B03
                    leax      >L0349,pc
                    lbsr      L1B03
                    tst       >u0CAB
                    bne       L19E2
                    tst       <u001A
                    beq       L19C8
                    lda       <u002B
                    ldb       #SS.HngUp
                    os9       I$SetStt            Hang up the phone
                    ldx       #$003C
                    lbsr      L0F56
                    bra       L1A0C

* Hangup modem by '+++' 'ATH'
L19C8               ldx       <u0011
                    ldb       2,x
                    andb      #$FE
                    stb       2,x
                    ldx       #$003C
                    lbsr      L0F56
                    ldx       <u0011
                    ldb       2,x
                    orb       #$01
                    stb       2,x
                    bra       L1A0C

L19E2               lda       <u002B
                    ldb       #$03
L19E7               leax      >L0981,pc           point to '+++'
                    ldy       #$0001
                    os9       I$Write
                    ldx       #$000C
                    lbsr      L0F56
                    decb
                    bne       L19E7
                    ldx       #$0080
                    lbsr      L0F56
                    leax      >L02DC,pc           point to 'ATH'
                    ldy       #$0004
                    os9       I$Write
L1A0C               lbsr      L1CDE
                    leax      >L048B,pc
                    lbsr      L1B03
                    lbra      L0C5E

L1A19               pshs      y,x,d
                    ldx       #u131C
                    bra       L1A2E

L1A21               pshs      y,x,d
                    suba      #$B1
                    ldb       #$80
                    mul
                    ldx       #u0D1C
                    leax      d,x
L1A2E               pshs      x
                    clrb
L1A31               lda       ,x+
                    incb
                    cmpb      #$80                Hi bit set char?
                    bhi       L1A3C               Yes, skip ahead
                    cmpa      #C$CR               Carriage return?
                    bne       L1A31
L1A3C               decb
                    clra
                    puls      x
                    tstb
                    beq       L1A4F
L1A43               lda       ,x+
                    decb
                    cmpa      #'\
                    beq       L1A5D
                    bsr       L1A76
L1A4C               tstb
                    bne       L1A43
L1A4F               puls      pc,y,x,d

L1A51               pshs      x
                    ldx       #$001E
                    lbsr      L0F56
                    puls      x
                    bra       L1A4C

L1A5D               lda       ,x+
                    decb
                    cmpa      #'^
                    beq       L1A72
                    cmpa      #'*
                    beq       L1A51
                    cmpa      #'\
                    beq       L1A6E
                    suba      #$40
L1A6E               bsr       L1A76
                    bra       L1A4C

L1A72               lda       #$1B                <ESC>?
                    bra       L1A6E

* Write char in A to modem
L1A76               pshs      y,x,a               Preserve regs
                    leax      ,s                  Point X to char to write
                    ldy       #$0001              Write char out to modem
                    lda       <u002B
                    os9       I$Write
                    puls      pc,y,x,a            Restore & return

* Setup device windows
* Entry: None
L1A8A               pshs      a,x,y               preserve
                    leay      L0469,pc            point to DWEnd,DWSet/Select for main window
                    ldx       #u13A9              point to a buffer
                    ldb       #14                 get length of data
                    lbsr      L2D26               move it
                    ldx       #u13A9              Point to buffer again
                    lda       #28                 Maximum height we will try (for 28 line GRFDRV)
                    sta       >u0C84              Save copy
                    sta       8,x                 Save in DWSet command
                    sta       <u0091              Save as Y size of window (in case it works)
                    ldy       #14                 Size of all 3 commands
                    lda       #1                  Std Out
                    os9       I$Write             Try it
                    bcs       Nope                No, try 27 down to 10
                    lda       7,x                 Get width that worked
                    bra       Worked              Save it & return
Nope                ldx       #u13A9+2            point to data again (skipping DWEnd)
                    lda       #27                 Get screen height we will start trying on
L1AB5               sta       >u0C84              Save copy
                    sta       6,x                 save it into DWSet
                    sta       <u0091              Save as Y size of window
                    ldy       #10                 Size of DWSet command
                    lda       #1
                    os9       I$Write             try to setup window
                    bcs       L1AD8               didn't work, skip ahead
                    lda       5,x                 get width
Worked              sta       <u0090              Save it as main window width
L1AD6               puls      a,x,y,pc            restore & return

L1AD8               lda       >u0C84              get current height
                    deca                          subtract 1
                    cmpa      #10                 do we have any room?
                    bhi       L1AB5               yes, try again
                    comb                          set carry
                    ldb       #E$IWDef            Illegal Window Definition error
                    bra       L1AD6               return with error

L1AE8               leax      L0467,pc            Point to '/w'
                    lda       #WRITE.
                    os9       I$Open              Open path to new window
                    sta       <u003E              Save it
                    leax      >L0477,pc           Point to DWSet for status line window
                    ldy       #$000A
                    os9       I$Write
                    rts

* Generic WRITE routine
L1B03               lda       #$01                Std out path
L1B05               ldy       ,x++                Get length to write
                    os9       I$Write             Write it out
                    rts

* NOTE: SHOULD MOVE THESE ROUTINES?
L1B0C               bsr       L1B1D
                    cmpa      #'y
                    lbeq      L0EEF
                    cmpa      #'Y
                    lbeq      L0EEF
                    lbra      L0C5E

L1B1D               pshs      y
                    ldd       #$1D04
                    std       >u0C8F
                    ldd       #$1603
                    std       >u0C91
                    lbsr      L1C81
                    leax      >L0499,pc
                    bsr       L1B03
                    leax      >L048F,pc
                    bsr       L1B03
                    lbsr      L2ABC
                    pshs      a
                    leax      >L048B,pc
                    bsr       L1B03
                    lbsr      L1CDE
                    puls      pc,y,a

L1B4E               pshs      x,b
                    ldx       #u0C99
                    os9       F$Time
                    lda       $05,x               Get seconds
                    ldx       #$0002              Sleep for 2 tics
                    os9       F$Sleep
                    puls      pc,x,b

* Get input string locally
* Entry: B=Count?
L1B61               pshs      d,x,y
                    clr       <u001C
                    clr       <u001D              clear input data count
                    clr       <u0021              break flag?
                    ldx       #u060E
L1B70               lbsr      L2ABC
                    cmpa      #'-                 is it printable?
                    bls       L1B85               no, check control chars.
                    tstb
                    beq       L1B70
                    sta       ,x+                 save data to buffer
                    decb                          decrement count
                    inc       <u001D              add 1 to data length
                    lbsr      L1F0B               go print it
                    bra       L1B70               go try again

L1B85               cmpa      #C$BSP              was it backspace?
                    bne       L1B99               no,
                    tst       <u001D              any data?
                    beq       L1B70               no, try again
                    incb
                    dec       <u001D              decrement count
                    leax      -1,x                backup
                    lbsr      L1F0B               print it
                    bra       L1B70               go try again

L1B99               cmpa      #C$QUIT             break?
                    bne       L1BA2               no, check CR
                    inc       <u0021              flag break
                    puls      d,x,y,pc            Restore & return

L1BA2               cmpa      #C$CR               carriage return?
                    bne       L1B70               no, try again
                    sta       ,x                  save it
                    inc       <u001D              add 1 to count
                    puls      d,x,y,pc            restore & return

L1BAD               ldd       #SS.Ready           Std In - Check for data ready
                    os9       I$GetStt
                    bcc       L1BB7               May have some, skip ahead
                    rts                           Otherwise, return

L1BB7               tstb                          0 bytes?
                    beq       L1BC6               Yes, skip ahead
                    clra                          Clear high byte of size & Std In
                    tfr       d,y                 Move to Y for Read call
                    ldx       #u13A9              Place to hold waiting data
                    os9       I$Read
L1BC6               rts

* <ALT>-<1-8> function key init routine
L1BC7               pshs      x,d
                    ldb       #$08                # function keys to init
                    ldx       #u0D1C              Point to start of <ALT>-<1> key buffer
                    lda       #C$CR
L1BD1               sta       ,x                  Save 2 CR's as default for each key
                    sta       1,x
                    leax      >$0080,x            Move to next key
                    decb                          Do until all function keys initialized
                    bne       L1BD1
                    puls      pc,x,d

* TAB HANDLER GOES HERE (CHR$(9))
* L1BDE    rts

L1BDF               lda       <u0065              Get monitor type (0=Comp, 1=RGB, 2=Mono)
                    cmpa      #2
                    bne       L1BEC               If comp or RGB, skip ahead
                    leay      >L0371,pc           Point to a set of palettes for monochrome
                    bra       L1C16

* Monitor type is color (comp or RGB)
L1BEC               tst       >u0CA6              Check current terminal type
                    bne       L1C12               If Not TTY, skip ahead
* TTY: Color
                    leay      >L0391,pc           Point to OS9 terminal type palette defaults
                    ldd       #$0601              Reset some stored colors
                    std       <u0085
                    ldd       #$0002
                    std       <u0087
                    ldd       #$0704
                    std       <u0089
                    ldd       #$0305
                    std       <u008B
                    bra       L1C30

* OS9 or ANSI
L1C12               leay      >L0381,pc           Point to ANSI terminal type palette defaults
L1C16               ldd       #$0504
                    std       <u0085
                    ldd       #$0700
                    std       <u0087
                    ldd       #$0601
                    std       <u0089
                    ldd       #$0203
                    std       <u008B
L1C30               ldx       #u13A9              Point to temp buffer
                    ldd       #$1B31              Set palette command
                    std       ,x
                    clra                          Start with palette 0
L1C3A               ldb       a,y
                    pshs      y,a
                    std       $02,x
                    ldy       #$0004
                    lda       #$01
                    os9       I$Write
                    puls      y,a
                    inca
                    cmpa      #$10
                    blo       L1C3A
                    lbsr      L2C18
                    lbra      L2B86

L1C57               pshs      x,a
                    lda       <u0065
                    cmpa      #$02
                    beq       L1C6C
                    tst       >u0CA6
                    bne       L1C6C
                    leax      >L03A4,pc
                    bra       L1C70

L1C6C               leax      >L03A1,pc
L1C70               lda       ,x
                    lbsr      L2347
                    lda       $01,x
                    lbsr      L233B
                    lda       $02,x
                    lbsr      L2341
                    puls      pc,x,a

* Generic shadowed overlay window set routine
* Uses 9 byte buffer from u13A9 to hold OWSet command
* u0C8F : Start X,Y coords
* u0C91 : X,Y width
L1C81               pshs      y,x,d               Preserve regs
                    ldx       #u13A9              Point to buffer
                    ldd       #$1B22              OWSet prefix (Draw shadow part of overlay)
                    std       ,x
                    lda       #$01                Save switch on
                    sta       2,x
                    ldd       >u0C8F              Get start coords
                    adda      #$01                Bump up by 1
                    addb      #$01
                    std       3,x                 Save in string
                    ldd       >u0C91              Get width & height
                    std       5,x                 Save in string
                    ldb       >u0085              Get bckground color
                    clra                          Foreground color=0
                    std       7,x                 Save in string
                    lda       #$01                Pop overlay window onto screen
                    ldy       #$0009
                    os9       I$Write
                    ldd       #$1B22              Now, draw main overlay window
                    std       ,x
                    lda       #$01
                    sta       $02,x
                    ldd       >u0C8F
                    std       3,x
                    ldd       >u0C91
                    std       5,x
                    lda       <u0087
                    ldb       <u0086
                    std       7,x
                    lda       #$0C
                    sta       $09,x
                    lda       #$01
                    ldy       #$000A
                    os9       I$Write
                    puls      pc,y,x,d

* Generic shadowed overlay window remove routine
L1CDE               pshs      y,x,d               Preserve regs
                    ldx       #u13A9              Point to buffer
                    ldd       #$1B23              OWEnd command
                    std       ,x
                    lda       #1                  Take off both main & shadow overlays
                    ldy       #$0002
                    os9       I$Write
                    os9       I$Write
                    puls      pc,y,x,d            Restore & return

L1CF7               pshs      y,x,d
                    ldx       #$1003
                    ldy       #$0EA0
L1D00               ldd       #1*256+SS.Tone      Tone to Std Out
                    os9       I$SetStt
                    puls      pc,y,x,d

L1D09               pshs      y,x,d
                    ldx       #$3F03
                    ldy       #$0FD1
                    bra       L1D00

L1D14               pshs      x,d
                    ldb       #SS.Break           Send a BREAK signal
                    lda       <u002B              Get modem path
                    os9       I$SetStt            Send BREAK to modem
                    bcc       L1D2D               Did it, return without error
                    ldx       <u0011              If modem Driver doesn't support SS.Break call,
                    lda       2,x                 force it on hardware (assumes 6551 card)
                    ora       #%00001100
                    sta       2,x
                    anda      <u00F3
                    sta       2,x
L1D2D               puls      pc,x,d

L063D               fdb       19                  # bytes this message
                    fcb       C$LF,C$CR
                    fcc       ' Baud Rate:      '

* 12 backspaces
L03CA               fcb       C$BSP,C$BSP,C$BSP,C$BSP,C$BSP,C$BSP
                    fcb       C$BSP,C$BSP,C$BSP,C$BSP,C$BSP,C$BSP

L0652               fcc       '110  '
                    fcc       '300  '
                    fcc       '600  '
                    fcc       '1200 '
                    fcc       '2400 '
                    fcc       '4800 '
                    fcc       '9600 '
                    fcc       '19200'

* <ALT>-<B> Baud rate
L1D2F               pshs      y,x,d
                    leax      >L048F,pc           Cursor OFF
                    lbsr      L1B03
                    ldd       #$1E03              Set start coords & size of overlay window
                    std       >u0C8F
                    ldd       #$1203
                    std       >u0C91
                    lbsr      L1C81               Put shadowed overlay on screen
                    leax      <L063D,pc           Print 'Baud Rate:'
                    lbsr      L1B03
                    ldb       >u0CA5              Get word len/stop bits/baud rate
                    andb      #%00000111          Just want baud rate
L1D56               stb       >u0C84              Save baud rate
                    leax      <L03CA,pc           Point to 10 C$BSP's
                    ldy       #$0005              Send out 5 backspaces???
                    lda       #1
                    os9       I$Write
                    leax      <L0652,pc           Point to baud rate table
                    lda       #$05                Point to current baud rate string
                    ldb       >u0C84
                    mul
                    leax      d,x
                    lda       #$01                Write it out
                    ldy       #$0005
                    os9       I$Write
L1D7D               lbsr      L2ABC               ???
                    cmpa      #C$CR               Carriage return?
                    beq       L1D9B               Yes, skip ahead
                    cmpa      #$05                <CTRL>-<E> (BREAK)?
                    beq       L1D9B               Yes, skip ahead
                    cmpa      #C$SPAC             <SPACE> (next baud)?
                    bne       L1D7D               No, go get another key since current is illegal
                    ldb       >u0C84              Get baud rate
                    incb                          Bump up to next one
                    cmpb      #8                  Wrap past 19200?
                    bne       L1D56               No, go update baud rate on screen
                    clrb                          Reset baud to 110
                    bra       L1D56               Go update baud rate on screen

L1D9B               ldb       >u0CA5              Get stop bits/word len/baud rate
                    andb      #%11111000          Mask out the baud rate
                    orb       >u0C84              Merge new baud rate
                    stb       >u0CA5              Save as new setting
                    lbsr      L1CDE               Remove overlay windows
                    lbsr      L118F               Update port settings & status line
                    leax      >L048B,pc           Turn cursor ON
                    lbsr      L1B03
                    puls      pc,y,x,d            Restore & return

* ==> Menu handler
* Entry: B=current menu # (0 base) selected
* u0C84 : current menu # selected
* u139E : Max. # items on menu
L1DB8               pshs      y,x,a               Preserve regs
                    clr       >u0099
                    stb       >u0C84              Save current menu item # selected
                    ldx       #u13A9              Point to temp buffer
                    ldd       #$1B25              CWArea prefix
                    std       ,x                  Save it
                    ldd       #$0102              Start X,Y = 1,2
                    std       2,x
                    lda       #$04                Width=4
                    ldb       >u139E              Height=# entries in menu (0 base)
                    incb                          +1
                    std       4,x                 Save it
                    lda       #$01                Change working area of window
                    ldy       #$0006
                    os9       I$Write
                    ldb       >u0C84              Get B back
L1DE6               clra                          D=B+1
                    incb
                    tfr       d,y                 Move to Y
                    leax      >L0688,pc           Clear working area & print Y # line feeds
                    inca                          A=1 (Std Out)
                    os9       I$Write
                    leax      >L0693,pc           Point to '==>' cursor
                    ldy       #$0003              Write that out
                    os9       I$Write
L1DFE               lbsr      L2AC5               Go get key
                    anda      #$7F                Mask out high bit
                    cmpa      #C$LF               Down arrow?
                    beq       L1E19               Yes, skip ahead
                    cmpa      #C$FORM             Up arrow?
                    beq       L1E2B               Yes, skip ahead
                    cmpa      #C$SPAC             Space bar?
                    beq       L1E39               Yes, get menu item selected & exit
                    cmpa      #$05                <CTRL>-<E> or <BREAK>?
                    beq       L1E3F
                    cmpa      #C$CR               Carriage return?
                    bne       L1DFE               No, other keys illegal: go get another key
L1E4A               inc       <u0099              Flag that a change was made?
L1E39               ldb       >u0C84              Get menu item # selected
                    puls      pc,y,x,a            Restore regs & return

* Down arrow in ==> menu
L1E19               ldb       >u0C84              Get current menu #
                    incb                          Bump up
                    cmpb      >u139E              Past maximum
                    blo       L1E25               No, skip ahead
                    clrb                          Reset to menu item #0
L1E25               stb       >u0C84              Save new menu item selected
                    bra       L1DE6               Update menu arrow & get next key

* Up arrow in ==> menu
L1E2B               ldb       >u0C84              Get current menu #
                    decb                          Bump down
                    bpl       L1E25               If still legit, save it & update menu arrow
                    ldb       >u139E              Get # items in menu
                    decb                          Make base 0
                    bra       L1E25               Save & update menu arrow

* <CTRL>-<E> / <BREAK>
L1E3F               ldb       >u139E              Get # items in menu
                    incb                          +1 (to flag cancel?)
                    stb       >u0C84              Save as current menu item selected
                    puls      pc,y,x,a            Restore & return

* Select terminal type (<ALT>-<T>)
L1E50               pshs      y,x,d               Preserve regs
                    leax      >L048F,pc           Cursor OFF
                    lbsr      L1B03
                    ldd       #$1C03              Set up shadowed overlay window 23x3
                    std       >u0C8F
                    ldd       #$1703
                    std       >u0C91
                    lbsr      L1C81
                    leax      >L0696,pc           'Terminal type'
                    lbsr      L1B03
                    ldb       >u0CA6              Get current terminal type
L1E75               stb       >u0C84              Save as # entries in menu
                    leax      >L03CA,pc           Point to Backspaces
                    lda       #$01                Blank out 5 chars
                    ldy       #$0005
                    os9       I$Write
                    leax      >L06B0,pc           Point to terminal type table
                    lda       #$05                Calculate offset to currently selected type
                    ldb       >u0C84
                    mul
                    leax      d,x
                    ldy       #$0005              Print it out
                    lda       #$01
                    os9       I$Write
L1E9C               lbsr      L2ABC               Go get keypress
                    cmpa      #C$CR               Carriage return (keep new setting)?
                    beq       L1EBA               Yes, go process
                    cmpa      #$05                <CTRL>-<E> or <BREAK>?
                    beq       L1EBA               Yes, go process
                    cmpa      #C$SPAC             <SPACE> (change setting)?
                    bne       L1E9C               No, illegal key, try again
                    ldb       >u0C84              Get terminal type
                    incb                          Bump up to next one
                    cmpb      #3                  Past maximum?
                    bne       L1E75               No, go print new selection & back to menu handler
                    clrb                          Reset to 1st & back to menu handler
                    bra       L1E75

L1EBA               ldb       >u0C84              Get selected terminal type
                    stb       >u0CA6              Save as new terminal type
                    lbsr      L1BDF               Go reset palettes for new terminal type
                    lbsr      L1CDE               Remove overlay windows
                    lbsr      L1C57               Go set fore/back/border colors
                    bsr       L1EDC               Go clear the screen
                    tst       <u0040              Is conference mode active?
                    beq       L1ED3               No, skip ahead
                    bsr       L1EE5               Yes, reset up conference mode window
L1ED3               leax      >L048B,pc           Cursor ON
                    lbsr      L1B03
                    puls      pc,y,x,d            Restore & return

* Clear screen
L1EDC               pshs      a                   Preserve A
                    lda       #C$FORM             Clear screen code
                    bsr       L1F0B               Write it out
                    puls      pc,a                Restore & return

* Setup conference mode again
L1EE5               pshs      y,x,d               Preserve regs
                    ldx       #u13A9              Point to buffer
                    ldd       #$1B25              CWArea prefix
                    std       ,x
                    ldd       #$0000              Start @ 0,0
                    std       2,x
                    ldd       #$5003              80x3 size
                    std       4,x
                    lda       #1                  Home Cursor
                    sta       6,x
                    ldy       #$0007              Send CWArea/Home cursor to conference window
                    lda       <u003F
                    os9       I$Write
                    lbra      L268D               Go print '---'... line etc. for conference mode

* Print char in A to Std Out
L1F0B               pshs      y,x,d               Preserve regs & char to print
                    leax      ,s                  Point to char
                    ldy       #$0001              Write it out
                    lda       #$01
                    os9       I$Write
                    puls      pc,y,x,d            Restore & return

* <ALT>-<O> Options menu
L1F1D               pshs      y,x,d               Preserve regs
                    leax      L048F,pc            Cursor OFF
                    lbsr      L1B03
                    ldd       #$1F03              Do shadowed overlay of 31x3
                    std       >u0C8F
                    ldd       #$160E
                    std       >u0C91
                    lbsr      L1C81
                    leax      L0821,pc            Print out Options menu
                    lbsr      L1B03
                    lbsr      L20DB               Print Echo status
                    lbsr      L2108               Print Rx LF status
                    lbsr      L2118               Print Tx LF status
                    lbsr      L20F8               Print Key click status
                    lbsr      L21D5               Print Word Length setting
                    lbsr      L2174               Print Parity setting
                    lbsr      L21B9               Print Stop bits setting
                    lbsr      L2128               Print Host Echo setting
                    lbsr      L2138               Print Hangup type setting
                    lbsr      L2148               Print Auto-Zmodem setting
                    lbsr      L2158               Print Auto-ASCII setting
                    lda       #$0B                Get # items on menu
                    sta       >u139E              Save for ==> menu handler
                    clrb                          Default to menu item #0
L1F66               lbsr      L1DB8               Go get menu selection
                    ldx       #u13A9
                    ldd       #$1B25              CWArea
                    std       ,x
                    ldd       #$0000              from 0,0
                    std       2,x
                    ldd       #$160E              to 22,14 (on overlay window)
                    std       4,x
                    ldy       #$0006
                    lda       #$01
                    os9       I$Write
                    tst       <u0099              Any entry change?
                    lbne      L20CF               No, remove Options menu & return
                    ldb       >u0C84              Get menu item # that was changed
                    cmpb      #$0A                Was it <CTRL>-<E>/BREAK (1 higher than max)?
                    lbhi      L20CF               Yes, remove Options menu & return
                    tstb                          Was it Echo status?
                    bne       L1FAB               No, try next
                    lda       >u0CA7              Get echo type
                    bne       L1FA7               If 1, change to 0
                    inc       >u0CA7              If 0, change to 1
                    bra       L1FAB

L1FA7               clr       >u0CA7
L1FAB               lbsr      L20DB               Print setting (0=Off, 1=On)
                    cmpb      #$03
                    bne       L1FC2
                    lda       >u0CAA
                    bne       L1FBE
                    inc       >u0CAA
                    bra       L1FC2

L1FBE               clr       >u0CAA
L1FC2               lbsr      L20F8
                    cmpb      #$07
                    bne       L1FD9
                    lda       >u0CB1
                    bne       L1FD5
                    inc       >u0CB1
                    bra       L1FD9

L1FD5               clr       >u0CB1
L1FD9               lbsr      L2128
                    lbsr      L118F
                    cmpb      #$05
                    bne       L200C
                    lda       >u0CAC
                    anda      #$E0
                    tsta
                    beq       L2011
                    cmpa      #$E0
                    beq       L2015
                    adda      #$40
L1FF3               pshs      b
                    ldb       >u0CAC
                    andb      #$1F
                    stb       >u0CAC
                    puls      b
                    ora       >u0CAC
                    sta       >u0CAC
                    lbsr      L118F
L200C               lbsr      L2174
                    bra       L2018

L2011               adda      #$20
                    bra       L1FF3

L2015               clra
                    bra       L1FF3

L2018               cmpb      #$06
                    bne       L2032
                    lda       >u0CA5
                    bpl       L2026
                    anda      #$7F
                    bra       L2028

L2026               ora       #$80
L2028               sta       >u0CA5
                    lbsr      L118F
                    lbsr      L21B9
L2032               cmpb      #$04
                    bne       L204E
                    lda       >u0CA5
                    bita      #$20
                    beq       L2042
                    anda      #$DF
                    bra       L2044

L2042               ora       #$20
L2044               sta       >u0CA5
                    lbsr      L118F
                    lbsr      L21D5
L204E               cmpb      #$01
                    bne       L2062
                    lda       >u0CA8
                    bne       L205E
                    inc       >u0CA8
                    bra       L2062

L205E               clr       >u0CA8
L2062               lbsr      L2108
                    cmpb      #$02
                    bne       L207C
                    lda       >u0CA9
                    bne       L2075
                    inc       >u0CA9
                    bra       L207C

L2075               clr       >u0CA9
                    lbsr      L118F
L207C               lbsr      L2118
                    cmpb      #$08
                    bne       L2093
                    tst       >u0CAB
                    bne       L208F
                    inc       >u0CAB
                    bra       L2093

L208F               clr       >u0CAB
L2093               lbsr      L2158
                    cmpb      #$09
                    bne       L20AA
                    tst       >u0CAE
                    bne       L20A6
                    inc       >u0CAE
                    bra       L20AA

L20A6               clr       >u0CAE
L20AA               lbsr      L2148
                    cmpb      #$0A
                    bne       L20C1
                    tst       >u0CAD
                    bne       L20BD
                    inc       >u0CAD
                    bra       L20C1

L20BD               clr       >u0CAD
L20C1               bsr       L2138
                    cmpb      #$0A
                    bhi       L20CF
                    ldb       >u0C84
                    lbra      L1F66

L20CF               lbsr      L1CDE               Turn off overlay windows
                    leax      >L048B,pc           Point to Cursor On
                    lbsr      L1B03               Print it
                    puls      pc,y,x,d            Restore regs & return

L20DB               pshs      x,d
                    ldd       #$1102
                    lbsr      L2294
                    lda       >u0CA7
L20E7               bne       L20F2
L20E9               leax      >L0985,pc           Point to word 'Off'
L20ED               lbsr      L1B03               Print it
                    puls      pc,x,d

L20F2               leax      >L098B,pc           Point to word 'On'
                    bra       L20ED

L20F8               pshs      x,d
                    ldd       #$1105
                    lbsr      L2294
                    lda       >u0CAA
                    bra       L20E7               Go print 'on' or 'off'

L2108               pshs      x,d
                    ldd       #$1103
                    lbsr      L2294
                    lda       >u0CA8
                    bra       L20E7               Go print 'on' or 'off'

L2118               pshs      x,d
                    ldd       #$1104
                    lbsr      L2294
                    lda       >u0CA9
                    bra       L20E7               Go print 'on' or 'off'

L2128               pshs      x,d
                    ldd       #$1109
                    lbsr      L2294
                    lda       >u0CB1
                    bra       L20E7               Go print 'on' or 'off'

L2138               pshs      x,d
                    ldd       #$110C
                    lbsr      L2294
                    lda       >u0CAD
                    bra       L20E7               Go print 'on' or 'off'

L2148               pshs      x,d                 Preserve regs
                    ldd       #$110B              CurXY to 17,11 in options window
                    lbsr      L2294
                    lda       >u0CAE              Get Auto-ZModem flag (0=yes)
                    deca                          Adjust flag so routine works
                    bra       L20E7               Go print 'on' or 'off'

L2158               pshs      x,d
                    ldd       #$110A
                    lbsr      L2294
                    lda       >u0CAB              Get current hangup method
                    bne       L216D               <>0 is +++
                    leax      >L0979,pc           Point to 'dtr'
                    bra       L20ED

L097F               fdb       4                   # bytes this message
L0981               fcc       '+++'
                    fcb       4                   (Clear to EOL)

L216D               leax      <L097F,pc           Point to '+++'
                    bra       L20ED

L2174               pshs      y,x,d
                    ldd       #$1007
                    lbsr      L2294
                    lda       >u0CAC
                    anda      #$E0
                    cmpa      #$A0
                    bne       L218C
                    leax      >L0990,pc           Point to 'Mark'
                    bra       L21AE

L218C               cmpa      #$E0
                    bne       L2196
                    leax      >L0995,pc           Point to 'Space'
                    bra       L21AE

L2196               cmpa      #$60
                    bne       L21A0
                    leax      >L099A,pc           Point to 'Even'
                    bra       L21AE

L21A0               cmpa      #$20
                    bne       L21AA
                    leax      >L099F,pc           Point to 'Odd'
                    bra       L21AE

L21AA               leax      >L09A4,pc           Point to 'None'
L21AE               lda       #$01                Std Out
                    ldy       #$0005              Size of parity string
                    os9       I$Write             Print it out
                    puls      pc,y,x,d

* Print current Stop bits setting
L21B9               pshs      x,d
                    ldd       #$1208              Go position cursor @ 18,8
                    lbsr      L2294
                    lda       >u0CA5              Get # stop bits (hi bit)
                    bpl       L21CE
                    lda       #'2
                    bra       L21D0

L21CE               lda       #'1
L21D0               lbsr      L1F0B
                    puls      pc,x,d

* Print current Word Length setting
L21D5               pshs      x,d
                    ldd       #$1206              Position cursor @ 18,6
                    lbsr      L2294
                    lda       >u0CA5              Get word length
                    bita      #$20
                    bne       L21E9
                    lda       #'8
                    bra       L21EB

L21E9               lda       #'7
L21EB               lbsr      L1F0B
                    puls      pc,x,d

L21F0               cmpa      #$8C                <ALT>-<up arrow>?
                    bne       L21F8
                    ldd       #'A*256+9           ANSI/OS9 cursor up codes
                    bra       L2239

L21F8               cmpa      #$8A                <ALT>-<down arrow>?
                    bne       L2200
                    ldd       #'B*256+$A          ANSI/OS9 cursor down codes
                    bra       L2239

L2200               cmpa      #$88                <ALT>-<left arrow>?
                    bne       L2208
                    ldd       #'D*256+8           ANSI/OS9 cursor left code
                    bra       L2239

L2208               cmpa      #$89                <ALT>-<right arrow>?
                    bne       L2210
                    ldd       #'C*256+6           ANSI/OS9 cursor right code
                    bra       L2239

L2210               ldb       <u0041              Get last key sense byte
                    bitb      #%01111000          Any of the arrows?
                    lbeq      L1597               No, go check special SuperComm keys
                    cmpa      #$13                <CTRL>-<up>?
                    bne       L2221               No, skip ahead
                    ldd       #'H*256+1           ANSI/OS9 Home cursor codes
                    bra       L2239

L2221               cmpa      #$12                <CTRL>-<down>?
                    bne       L2229
                    ldd       #'K*256             ANSI end (screen or line?) / No OS9
                    bra       L2239

L2229               cmpa      #$10                <CTRL>-<left>?
                    bne       L2231
                    ldd       #'P*256             ANSI delete char / No OS9
                    bra       L2239

L2231               cmpa      #$11                <CTRL>-<right>?
                    lbne      L1597               No, go check for SuperComm special keys
                    ldd       #'@*256             ANSI insert char / No OS9
L2239               ldx       #u04EF              Point to buffer for 3 byte ANSI sequence
                    sta       2,x                 Save as ANSI post byte
                    pshs      b                   Save OS9 code until ANSI sequence sent
                    ldd       #$1B5B              ANSI prefix: <ESC>[
                    std       ,x
                    lda       <u002B              Get path to modem
                    ldy       #$0003
                    os9       I$Write             Send out the ANSI sequence
                    tst       >u0CA7              ??? Check if we have to do local cursor change
                    lbeq      L0C5E               No, go back to main processing loop
                    ldb       ,s+                 Get OS9 code back
                    lbeq      L0C5E               None, return to main processing loop
                    stb       ,x                  Save it in buffer
                    lda       #1                  Std Out (screen)
                    ldy       #$0001
                    os9       I$Write             Write out OS9 code
                    lbra      L0C5E               Return to main processing loop

* Position cursor at A,B
L2294               pshs      y,x,d               Preserve regs
                    ldx       #u0095              Point to buffer area
                    adda      #$20                Bump cursor pos. to OS9 equivalent (+$20)
                    addb      #$20
                    std       $01,x               Save OS9 coords
                    lda       #$02                CurXY prefix
                    sta       ,x                  Save that too
                    deca                          A=1 (Std Out)
                    ldy       #$0003              Size of CurXY command
                    os9       I$Write             Position cursor
                    puls      pc,y,x,d            Restore regs & return

* Change Data Directory command
L22B1               pshs      y,x,d
                    ldd       #$1504              Place overlay window from 21,4 to 58,11
                    std       >u0C8F
                    ldd       #$2507
                    std       >u0C91
                    lbsr      L1C81
                    leax      >L051C,pc           Point to 'break aborts'
                    lbsr      L1B03
                    ldd       #$0102              Position cursor @ 1,2
                    bsr       L2294
                    lda       #$01
                    ldx       #u0CD2              Point to current data dir
                    ldy       #$0020
                    os9       I$WritLn
                    ldb       #$1F
                    leax      >L09A9,pc           Point to 'change data dir' message
                    lbsr      L1B03
                    lbsr      L1B61
                    tst       <u0021
                    bne       L230E
                    lda       >u060E              Get first char that user typed in
                    cmpa      #C$CR               If just CR, skip ahead
                    beq       L230E
                    lda       #READ.              ChgDir in read mode
                    ldx       #u060E              Point to user-typed directory path
                    os9       I$ChgDir            Change to it
                    bcs       L2313               Error, skip ahead
                    ldx       #u060E              Did it, copy user path list to default path list
                    ldy       #u0CD2
                    ldb       #$20
                    lbsr      L2D1E               Copy data
L230E               lbsr      L1CDE               Overlay Window end
                    puls      pc,y,x,d            Restore & return

* Print error message to user
L2313               lda       #C$BELL             Beep at user
                    lbsr      L1F0B
                    pshs      b
                    ldd       #$0D02              CurXY @ 13,2
                    lbsr      L2294
                    leax      >L048F,pc           Cursor OFF
                    lbsr      L1B03
                    puls      b
                    os9       F$PErr              Print error message
                    ldx       #60
                    lbsr      L0F56               ??? (something with Timer)
                    leax      >L048B,pc           Cursor ON
                    lbsr      L1B03
                    bra       L230E               Overlay window end & return

* Change background color to A
L233B               pshs      y,x,d               Preserve regs
                    ldb       #$33                Background color code
                    bra       L234B

* Change border color to A
L2341               pshs      y,x,d               Preserve regs
                    ldb       #$34                Border color code
                    bra       L234B

* Change foreground color to A
L2347               pshs      y,x,d               Preserve regs
                    ldb       #$32                Foreground color code
L234B               ldx       #u13A9              Point to temp buffer
                    sta       2,x                 Save palette #
                    lda       #$1B                OS9 window code prefix
                    std       ,x                  Save it
                    lda       #1                  Std Out
                    ldy       #$0003              Change appropriate color, restore regs & return
                    os9       I$Write
                    puls      pc,y,x,d

L2364               tst       <u0026              ASCII receive buffer open?
                    beq       L2372               No, go check if a receive file exists
                    clr       <u0026              Yes, set receive buffer to CLOSED state
                    bra       L237E               Will return from there

L2372               tst       <u0025              ASCII receive file exist?
                    bne       L2376               Yes, go flag buffer as open
                    rts

L2376               inc       <u0026              Set ASCII receive buffer to OPEN state
* Change buffer indicator on status line to OFF
L237E               pshs      y,x,d               Preserve regs
                    tst       <u0026              Get ASCII buffer open/closed flag
                    bne       L23AA               Open, skip ahead
                    leay      >L096D,pc           Point to buffer close string (for status line)
                    ldx       #u13A9
                    ldb       #12                 Copy it
                    lbsr      L2D26
                    ldx       #u13A9              Get ptr back
                    lda       <u0088              Get bckground color of main window
                    sta       $07,x               Save new color in string
                    lda       <u0087              Get foreground color of main window
                    sta       $0B,x               Save new color in string
                    lda       <u003E              Get path to status line window
                    lbsr      L1B05
L23A8               puls      pc,y,x,d

* Change buffer indicator on status line to ON
L23AA               leay      >L0960,pc           Point to buffer on string (for status line)
                    ldx       #u13A9
                    ldb       #13
                    lbsr      L2D26
                    ldx       #u13A9
                    lda       <u0087
                    sta       $09,x
                    lda       <u003E
                    lbsr      L1B05
                    lda       <u0002
                    suba      <u0006
                    lbsr      L44FF
                    puls      pc,y,x,d            Restore & return

* Position cursor @ X coord on line 1 to center text @ [u0093] within 40 chars
L23D0               pshs      y,x,d               Preserve regs
                    ldx       <u0093              Get ptr to ???
                    clrb                          Clear counter
* Count # chars (max 30) until high bit set or '.' found
L23D7               lda       ,x+                 Get char
                    incb                          Inc counter
                    cmpb      #30                 Up to 30 char max?
                    bhi       L23E5               Yes, skip ahead
                    tsta                          Does the char have the high bit set?
                    bmi       L23E5               Yes, skip ahead
                    cmpa      #'.                 Is it a period?
                    bne       L23D7               No, get next char
L23E5               addb      #8                  Add 8 to total # chars (8 spaces assumed)
                    ldx       #u13A9              Point to temp buffer
                    pshs      b                   Preserve count
                    lda       #40                 Centering within 40 chars
                    suba      ,s+                 A=40-B (size)
                    lsra                          Divide by 2 (calculate # chars in to center?)
                    adda      #$21                Add to base for Cursor coords+1
                    sta       1,x                 Save coord
                    ldd       #$0221              CurXY prefix & Y coord=1
                    stb       2,x                 Save Y coord
                    sta       ,x                  Save CurXY prefix
                    ldy       #$0003              Move cursor to X
                    lda       #1                  Std Out
                    os9       I$Write             Position cursor & return
                    puls      pc,y,x,d

L2408               pshs      y,x,d               Preserve regs
                    ldd       <u0053              Get ptr
                    beq       L246F               None, skip ahead

L2411               ldx       #u00E2              Point to buffer
                    ldy       <u0057              Get # bytes to read
                    lda       <u0042              Get path to download file
                    os9       I$Read              Go read from file
                    bcc       L242A               No error on read, continue
                    ldd       #$0000
                    inc       <u005F
                    bra       L2432

L242A               cmpy      <u0057
                    beq       L2449
L2430               tfr       y,d                 Copy # bytes read to D
L2432               ldx       #u00E2              Point to 3 bytes into modem buffer
                    leax      d,x                 Offset into it
                    pshs      d                   Preserve offset
                    ldd       <u0057              Get # bytes read
                    subd      ,s++                Subtract ???
                    tfr       d,y                 Move result to Y
                    lda       #$1A                <CTRL>-<Z> for X/Ymodem padding to even block
L2443               sta       ,x+
                    leay      -1,y
                    bne       L2443

L2449               ldx       #u00DF              Point to modem buffer
                    ldd       <u0053
                    stb       1,x
                    comb
                    stb       2,x
                    ldd       <u0053
                    beq       L2463
                    ldd       <u0057
                    cmpd      #$0080
                    bne       L2469
L2463               lda       #$01
                    sta       ,x
                    bra       L246D

L2469               lda       #$02
                    sta       ,x
L246D               puls      pc,y,x,d

L246F               tst       <u0069
                    beq       L2481
                    ldx       #u00E2
                    ldd       #$0080
L247A               sta       ,x+
                    decb
                    bne       L247A
                    bra       L2449

L2481               ldx       #u00E2
                    ldy       #u009F
                    ldb       #32                 32 chars max
L248B               lda       ,y+
                    beq       L2498               If NUL, skip ahead
                    cmpa      #C$CR               If CR, skip ahead
                    beq       L2498
                    sta       ,x+
                    decb
                    bne       L248B
L2498               clr       ,x+
                    lbsr      L2C72
                    bra       L2449

L249F               pshs      y,x,d
                    clr       <u0048
                    clr       <u0049
                    ldx       #u00E2
                    ldd       <u0057
                    leay      d,x
                    sty       <u0050
                    tst       <u005A
                    bne       L24C5
                    lbsr      L3E3D
                    leax      d,x
                    lda       <u0048
                    sta       ,x
L24C3               puls      pc,y,x,d

L24C5               lbsr      L3E0F
                    leax      d,x
                    ldd       <u0048
                    std       ,x
                    bra       L24C3

* Clear out 512 bytes @ u111C - Clears out Search (SSn) and Reply (RSn)
* strings
L24D1               pshs      y,x,a               Preserve regs
                    ldy       #u111C              Point to 512 byte buffer to clear
                    ldx       #$0000              double clear word
                    clra                          Double count=256
L24DB               stx       ,y++                Clear 2 bytes
                    deca                          Done all 256 double bytes?
                    bne       L24DB               No, continue clearing
                    puls      pc,y,x,a            Restore & return

* Search (SSn) string parse
L24E3               lda       -2,x
                    suba      #$31                Convert ASCII numeral (1 based) to bin (0 base)
                    cmpa      #3                  Within range of 0-3?
                    bhi       L2541               No, exit
                    ldb       #$40                Size of each entry=64 bytes
                    mul                           Point to appropriate entry
                    ldy       #u121C              Point to main buffer
                    leay      d,y                 Point to entry within buffer
                    ldb       #$40                Max size to copy
L24F6               lda       ,x+                 Get char
                    decb                          drop count
                    beq       ForceCR             If done max count, force CR on end
                    cmpa      #C$CR               Is it a CR?
                    beq       L2504               Yes, save it and stop
                    sta       ,y+                 Save char
                    bra       L24F6               Keep copying

ForceCR             lda       #C$CR               Done, force last char to CR
L2504               sta       ,y                  Save last char
                    puls      pc,y,x,d            Restore & return

* Send string parse (SSn) - does CTRL (\) conversions
L2508               lda       -$02,x
                    suba      #$31
                    cmpa      #$03
                    bhi       L2541
                    ldb       #$40
                    mul
                    ldy       #u111C              Point to send string buffer
                    leay      d,y
                    lda       #$01
                    sta       <u0C82
                    pshs      x
                    ldx       #u111C
                    stx       >u139C
                    puls      x
                    ldb       #$40                Get max size of Send string
L252D               lda       ,x+                 Copy until CR or 64 chars is hit
                    cmpa      #C$CR
                    beq       L253E
                    cmpa      #'\                 Control code?
                    beq       L2544               Yes, process for that
L2537               sta       ,y+
                    decb
                    bne       L252D
                    puls      pc,y,x,d
L253E               clrb
                    stb       ,y
L2541               puls      pc,y,x,d

L2544               lda       ,x+                 Get code
                    suba      #$40                Knock down to <CTRL> equivalent
                    bra       L2537               Save & continue

* Entry: X=Ptr to converted text buffer?
L254A               pshs      y,x,d               Preserve regs
                    ldb       <u0C89              Get size of converted text buffer
                    ldy       >u139C              Get ptr to ???
L2555               lda       ,x+                 Get char
                    anda      #$7F                Strip high bit
                    decb                          Drop count in buffer
                    clr       <u0071              Clear flag
L255D               cmpa      ,y                  Same as first char in search string buffer?
                    beq       L258A               Yes, skip ahead
                    lda       <u0C82              Get reply string #
                    deca                          bump to 0 base (0-3)
                    pshs      b
                    ldb       #$40                Size of search strings
                    mul
                    ldy       #u111C              Point to search strings
                    leay      d,y                 Point to one we want
                    sty       >u139C              Save ptr
                    puls      b                   Restore count
                    tst       <u0071
                    bne       L2582
                    inc       <u0071
                    bra       L255D

L2582               clr       <u0071
                    tstb
                    bne       L2555
                    puls      pc,y,x,d

L258A               leay      1,y
                    sty       >u139C
                    tst       ,y
                    bne       L2582
                    lda       <u0C82              Get SSn # (0-3)
                    inc       <u0C82              Inc copy of it
                    inc       >u0C83
                    ldb       #$40
                    mul
                    ldy       #u111C              Point to search strings buffer
                    leay      d,y                 Point to entry within buffer
                    sty       >u139C              Save new SSn string ptr to check
                    puls      pc,y,x,d

* Deal with RSn buffer strings
L25B1               pshs      y,x,d
                    clr       >u0C83
                    lda       <u0C82
                    suba      #$02
                    ldb       #$40
                    mul
                    ldx       #u121C              Point to RSn reply string buffer
                    leax      d,x                 Point to entry within buffer
                    pshs      x                   Preserve ptr
                    clrb
* Calc size of reply string
L25C9               lda       ,x+                 Get char from buffer
                    incb
                    cmpb      #$40                Done whole buffer?
                    bhi       L25D4               Yes, skip ahead
                    cmpa      #C$CR               Done to end of string?
                    bne       L25C9               No, keep looking
L25D4               decb                          Adjust size back down
                    puls      x                   Get ptr to beginning of string again
                    tstb                          Was there anything in the string?
                    beq       L25E8               No, exit
* This write/convert loop could be optomized
L25DB               lda       ,x+                 Yes, get char
                    decb                          Dec counter
                    cmpa      #'\                 Special char?
                    beq       L25F6               Yes, go process
                    lbsr      L1A76               No, write char to modem
L25E5               tstb                          Done whole string?
                    bne       L25DB               No, continue until done
L25E8               puls      pc,y,x,d

L25EA               pshs      x                   Preserve X
                    ldx       #30                 Sleep for 30 ticks (1/2 sec)
                    lbsr      L0F56               Go sleep (and update timer if needed)
                    puls      x                   Restore X
                    bra       L25E5

* \ (control letter) processor for RSn strings?
L25F6               lda       ,x+                 Get byte from reply string
                    decb                          Drop count
                    cmpa      #'^                 Caret (ESC)?
                    beq       L260C               Yes, send <ESC>
                    cmpa      #'*                 1/2 second pause?
                    beq       L25EA               Yes, go do
                    cmpa      #'\                 Double '\\'?
                    beq       L2607               Yes, go send '\'
                    suba      #$40                Any others drop by $40 (ctrl chars)
L2607               lbsr      L1A76               Send to modem
                    bra       L25E5               Continue until RSn string is done

L260C               lda       #C$EOF              Send escape code
                    bra       L2607

* Copy main DWSet sequence into buffer
L2620               leax      >L0469,pc           Point to main DWSet
                    ldy       #u13A9              Point to buffer
                    ldb       #$0C                12 bytes to copy
                    lbra      L2D1E               Go copy them & return from there

* <ALT>-<Z> conference mode toggle
L2610               pshs      y,x,d               Preserve regs
L2612               tst       <u0040              Conference mode on?
                    lbne      L26EE               Yes, go shut it off
                    inc       <u0040              Set it to on
                    bsr       L2620               Go set up buffer for DWSet
* First, redo main window to leave 3 lines at bottom
L262E               ldx       #u13A9              Point X to DWSet buffer
                    ldd       <u0090              Get X&Y sizes of main window
                    subb      #$03                Bump Y down by 3 (allow room for conference)
                    std       7,x                 Save as new sizes in DWSet string
                    lda       #$FF                Set to current displayed screen
                    sta       4,x
                    ldd       <u0087              Get fore/background colors of window
                    std       9,x                 Save them
                    lda       #$01                Redo main window to smaller size
                    ldy       #$000B
                    os9       I$Write
                    lda       #WRITE.             Now, open path to /W (next avail. window)
                    leax      >L0467,pc
                    os9       I$Open
                    bcs       L2612               Error, shut conference mode off & exit
                    sta       <u003F              Save path to conference mode window
                    ldx       #u13A9+2            Point to buffer+2 (past DWEnd)
                    clr       2,x                 Set to process' current screen
                    lda       <u0091              Get Y size of main window
                    suba      #2                  Bump down by 2 (3 since base 0)
                    sta       4,x                 Start Y coord @ end of screen -2
                    lda       #3                  Y size=3
                    sta       6,x
                    lda       <u0089              Get ??? color
                    sta       7,x                 Save as foreground color for conference mode
                    lda       <u0088              Get main window background color
                    sta       8,x                 Save as background color for confence window
                    lda       <u003F              Get path to conference window
                    ldy       #$0009              Create the conference mode window
                    os9       I$Write
L268D               lda       <u0087              Get FColor of main window
                    ldx       #u009C              Point to Fcolor string
                    sta       2,x                 Save color
                    ldy       #$0003              Set foreground color for conference window
                    lda       <u003F
                    os9       I$Write
                    ldx       #u13A9
                    ldd       #'-*256+80          Put 80 '-' in buffer
L26A9               sta       ,x+
                    decb
                    bne       L26A9
                    ldx       #u13A9
                    lda       <u003F
                    ldy       #80
                    os9       I$Write             Write out conference mode line
                    ldx       #u009C              Point to FColor string
                    lda       <u0089              Get ?? color
                    sta       2,x                 Set Fcolor of conference window
                    ldy       #$0003
                    lda       <u003F
                    os9       I$Write
                    leax      >L09EF,pc           Change working area to use only 2 lines
                    ldy       #$0006              (to keep '---'... line on screen)
                    os9       I$Write
                    lbsr      L284E               Do Inv On/Space/Inv Off/Bsp (WHY???)
                    leax      >L09E8,pc           Point to 'Conf'
                    lda       <u003E              Send to Status window
                    ldy       #$0007
                    os9       I$Write
L26EC               puls      pc,y,x,d            Restore & return

* Shut Conference mode off
L26EE               clr       <u0040              Flag conference mode off
                    leax      >L0475,pc           DWEnd the conference window
                    lda       <u003F
                    ldy       #$0002
                    os9       I$Write
                    lda       <u003F              Close path to conference window
                    os9       I$Close
                    lbsr      L2620               Copy DWEnd/DWSet for main window string
                    ldx       #u13A9              Point to it
                    ldd       <u0090              Get X/Y size of main window
                    std       7,x                 Save in string
                    lda       #$FF                Current displayed screen
                    sta       4,x
                    ldd       <u0087              Fore/Background colors of main window
                    std       9,x
                    lda       #$01                Std Out
                    ldy       #$000B
                    os9       I$Write             Change main window back to it's normal size
                    leax      >L09E1,pc           CurXY @ 0,0 & print 4 spaces
                    lda       <u003E              Send that to the Status window (erase 'Conf')
                    ldy       #$0007
                    os9       I$Write
                    puls      pc,y,x,d            Restore & return

* Keyboard read called from conference mode
L273D               clra                          Std In
                    ldy       #$0001
                    ldx       #u060E
                    os9       I$Read              Read 1 byte
                    ldx       <u0066              Get ptr to current char in Conf. kybrd buffer
                    lda       >u060E              Get key read
                    cmpa      #$8C                Higher than <ALT>-<Up Arrow> ?
                    lbhi      L157B               Yes, go check for special (keysense) keys
                    cmpa      #$7F                Alt Arrows, etc. ($80-$8c)?
                    lbhi      L0C5E               Yes, return to main loop
                    cmpa      #$18                <CTRL>-<X> (SHIFT-BSP)?
                    bne       L2765               No, check next
                    lda       #$7F                Yes, replace with real DEL/RUBOUT key
                    bra       L27A1               Go save in buffer @ X

L2765               cmpa      #$1A                <CTRL>-<Z>/<SHIFT>-<DOWN>?
                    lbeq      L157B               Yes, go check key-sense bytes
                    cmpa      #$1C                <SHIFT>-<UP>?
                    lbeq      L157B               Yes, go check keysense bytes
                    cmpa      #$0A                <DOWN> / LF?
                    lbeq      L0C5E               Yes, return to main loop
                    cmpa      #$0C                <UP> / Clear screen?
                    lbeq      L0C5E               Yes, return to main loop
                    cmpa      #$09                <RIGHT> / Up 1 line?
                    lbeq      L0C5E               Yes, return to main loop
                    cmpa      #$08                <LEFT> / BSP?
                    bne       L2796               No, skip ahead
* Backspace
                    ldb       <u0068              Get # keys in Conf. keyboard buffer
                    beq       L27B2               If none, skip ahead
                    leax      -1,x                Bump ptr to current char in kybrd buffer back
                    stx       <u0066              Save new ptr
                    dec       <u0068              Dec # keys in Conf. keyboard buffer
                    bra       L27AD               CHECK:REDUNDANT TO CHECK FOR CR THEN BSP AGAIN

L2796               ldb       <u0068              Get # keys in conference buffer
                    cmpb      #253                Within max. range?
                    blo       L27A1               Yes, go save it in buffer
                    cmpa      #C$CR               About to overflow, was key CR?
                    bne       L27B2               No, beep so user knows we're full
L27A1               sta       ,x+                 Save keypress in conference mode kybrd buffer
                    stx       <u0066              Save new current char ptr for buffer
                    inc       <u0068              Bump up count of # keys in conf. mode kybrd buff.
                    cmpa      #C$CR               Was char a CR?
                    beq       L27C6               Yes, skip ahead
L27AD               bsr       L27FD               NO, CHECK FOR CR & BSP AGAIN ?!?
                    lbra      L0C5E               Go back to main loop

* Conference mode keyboard buffer overflow
L27B2               lda       #$07                <CTRL>-<G> beep
                    ldx       #u13A9              Write it out
                    sta       ,x
                    lda       #$01
                    ldy       #$0001
                    os9       I$Write
                    lbra      L0C5E               Go back to main loop

L27C6               lda       #C$LF               Append LF
                    sta       ,x+
                    ldb       <u0068              Get # keys in buffer
                    tst       >u0CA9
                    beq       L27D4
                    incb                          Bump up count by 1
L27D4               clra
                    tfr       d,y                 Move count to Y
                    lda       <u002B              Get path to modem
                    ldx       #u050F              Point to buffer
                    os9       I$Write             Send to modem
                    clr       <u0068              Set # keys in conf. kybrd buffer to 0
                    ldx       #u050F              Point to conf buffer again
                    stx       <u0066              Save as current char ptr for conf buffer
                    lda       #C$CR               Stick CR in start of normal keyboard buffer
                    sta       >u060E
                    bsr       L27FD               Process CR
                    lda       #C$LF               Stick LF in start of normal keyboard buffer
                    sta       >u060E
                    bsr       L27FD               Process LF
                    lbra      L0C5E               Return to main loop

L27FD               lda       >u060E              Get last key read
                    cmpa      #C$CR               CR (send line)?
                    bne       L281C               No, skip ahead
                    ldd       #$200D              Space & CR
                    ldx       #u13A9              Save in temp buffer
                    std       ,x
                    lda       <u003F              Get path to conference window
                    ldy       #$0002              Write out space & CR
                    os9       I$Write
                    rts                           return

L281C               cmpa      #C$BSP              Was key backspace?
                    bne       L2835               No, go print key to conf. window
                    ldd       #$2008              Space & Backspace
                    ldx       #u13A9
                    std       ,x
                    lda       <u003F              Send to conf. window
                    ldy       #$0002
                    os9       I$Write
L2835               ldx       #u060E              Send key pressed to conf. window
                    ldy       #$0001
                    lda       <u003F
                    os9       I$Write
                    lda       >u060E              Get key pressed
                    cmpa      #C$CR               Is it CR?
                    bne       L284E               Yes, skip ahead
                    rts                           Otherwise return

L284E               lda       <u003F              Send Inv On/Space/Inv Off/Bsp to conf. window
                    leax      >L0493,pc
                    ldy       #$0006
                    os9       I$Write
                    rts

* Filename parse for Batch Receive???
* YModem Batch (WXModem) header as follows:
*   Block # (1 byte)
*   Compliment of block # (1 byte)
* Some sort of filename parse: allows upper/lower case, numbers
* Unknown chars are forced to be Underscores (_)
L2860               pshs      y,x,d               Preserve regs
                    ldx       #u00DF+3            Point 3 bytes into input buffer from modem
                    pshs      x                   Save ptr to start of list
L2868               lda       ,x+                 Hunt for 1st 0 byte @ u00E2
                    bne       L2868
                    leax      -1,x
                    pshs      x                   Save ptr to 1st 0 byte
                    clr       <u009A              Clear flag?
* Found 1st NUL in modem buffer past u00DF+3, now parse it
L2874               lda       ,-x                 Now, go backwards getting chars as we go
                    cmpx      2,s                 At beginning again?
                    blo       L28AA               Yes, skip ahead
                    cmpa      #'A                 Check if alphabetic char (case ignored)
                    blo       L2890               Below alphabetic, go try #'s, etc.
                    cmpa      #'Z
                    bls       L2874               If A-Z, its fine
                    cmpa      #'a                 If [\]^_'  then check if \ to /, else _
                    blo       L28A6               S/B L28A6 & BELOW SHOULD BE L28A0
                    cmpa      #'z
                    bhi       L28A0               If {|}~ or $7F, force to underscore
                    sta       <u009A              Save char if lowercase
                    bra       L2874               Keep going

* Char below 'A'
L2890               cmpa      #'9
                    bhi       L28A0               If :;<=>?@ then change to underscore _
                    cmpa      #'0
                    bhs       L2874               If 0-9, its fine
                    cmpa      #'.                 If period, it's fine
                    beq       L2874
                    cmpa      #'/                 Path separator?
                    beq       L28AA               Special check
L28A0               lda       #'_                 Force to be underscore
                    sta       ,x                  Replace original char in buffer
                    bra       L2874               Continue checking

* USELESS, CAN ONLY GET CALLED IF CHAR IS CHR$($7B-$7F), AND BACKSLASH IS $5C
* COULD BE USED TO CHANGE PATH SEPARATORS (EX. MS-DOS) TO NORMAL ONES
L28A6               cmpa      #'\                 Backslash?
                    bne       L28A0               No, force to underscore
* Backslash handler
L28AA               leax      1,x                 Point to char again
                    lda       ,x                  Get it
                    beq       L28C2               If NUL skip ahead
                    cmpa      #C$CR               End of line?
                    beq       L28C2               Yes skip ahead
                    cmpa      #'A                 Char below alpha?
                    blo       L28BC               Yes, skip ahead
                    cmpa      #'_                 Underscore?
                    bne       L28C2               No, skip ahead
* Underscore or below A go here - these get replace by 'x'
L28BC               leax      -1,x                Bump ptr back
                    lda       #'x                 Force char to be 'x'
                    sta       ,x
L28C2               stx       2,s                 Save ptr as beginning ptr
                    tst       <u009A              Did we have lowercase char?
                    bne       L28DE               Yes, skip ahead
L28CA               lda       ,x+                 No, get char
                    cmpx      ,s                  Are we within buffer @ u00E1?
                    bhi       L28DE               Yes, skip ahead
                    cmpa      #'A                 Uppercase char?
                    blo       L28CA               No, keep going forward
                    cmpa      #'Z
                    bhi       L28CA
                    ora       #$20                Uppercase, force to lowercase
                    sta       -1,x
                    bra       L28CA

L28DE               ldy       #u009F
                    ldx       2,s
                    ldd       ,s++
                    subd      ,s++
                    cmpb      #29                 Small enough to be filename?
                    bls       L28EE
                    ldb       #29
L28EE               lbsr      L2D1E
                    lda       #C$CR
                    sta       ,y
                    leax      1,x
                    bsr       L2968
                    leax      >L056B,pc           Print 'Recv:'
                    lbsr      L1B03
                    ldx       #u009F
                    lda       ,x
                    beq       L2938
                    cmpa      #C$CR
                    beq       L2938
                    lda       #$01                Std Out
                    ldy       #$0020
                    os9       I$WritLn
                    leax      >L048F,pc           Cursor OFF
                    lbsr      L1B03
                    ldd       <u005B+2            Get LSW of file size
                    bne       L2944               There is one, skip ahead
                    ldd       <u005B              Get MSW of file size
                    bne       L2944
L2926               ldx       #u009F
                    ldd       #WRITE.*256+UPDAT.  Write mode, Read & Write attributes
                    os9       I$Create
                    bcs       L2938
                    sta       <u0042              Save path # to download file
                    puls      pc,y,x,d            Restore & return

L2938               lda       #$FF
                    sta       <u0042              Set download path # to invalid
                    lda       #$0A
                    sta       <u0052
                    puls      pc,y,x,d            Restore & return

* Have file size, print it
L2944               leax      >L0577,pc           Print 'Size:'
                    lbsr      L1B03
                    ldx       #u13AA
                    ldy       #$0007
L2953               lda       ,x
                    cmpa      #'0
                    bne       L2961
                    leax      1,x
                    leay      -1,y
                    beq       L2926               Go create the download file
                    bra       L2953

L2961               lda       #$01                Write to Std Out
                    os9       I$Write
                    bra       L2926

L2968               pshs      y,x,d
                    ldd       #$0000              Init file size to 0 bytes
                    std       <u005B
                    std       <u005B+2
                    ldb       #$08                Max count=8 chars
L2975               lda       ,x+                 Get char
                    beq       L2983               If NUL, skip ahead
                    cmpa      #C$SPAC             Space?
                    beq       L2983               Yes, skip ahead
                    decb                          Dec count
                    bne       L2975               Keep going until all 8 done
                    puls      pc,y,x,d            Restore & return

L2983               ldy       #u13B0
                    leax      -1,x                Point back to space or NUL
                    ldb       #$08                Max distance backwards
L298B               lda       ,-x
                    beq       L2996
                    sta       ,-y
                    decb
                    cmpb      #1
                    bne       L298B
L2996               lda       #'0
L2998               sta       ,-y
                    decb
                    cmpb      #1
                    bne       L2998
                    ldy       #u13A9
                    leax      >L09F5,pc           Point to table for decimal conversion
                    clrb                          Start at highest level (1,000,000)
* B=Current position to convert (0=1,000,000  1=100,000 etc.)
* X=Ptr to 4 byte integer conversion table
* Y=
L29A8               pshs      b,x                 Preserve digit field # & table ptr
                    lda       #$04                4 bytes / entry (for Long Ints)
                    mul
                    leax      d,x                 Point to proper entry
                    ldb       ,s                  Get which digit we are on
                    lda       b,y
                    suba      #'0
                    tfr       a,b
                    beq       L29E9
L29C2               lda       3,x                 Add 4 byte table to 4 byte longint variable
                    adda      <u005B+3
                    sta       <u005B+3
                    lda       2,x
                    adca      <u005B+2
                    sta       <u005B+2
                    lda       1,x
                    adca      <u005B+1
                    sta       <u005B+1
                    lda       ,x
                    adca      <u005B
                    sta       <u005B
                    decb
                    bne       L29C2
L29E9               puls      b,x
                    incb                          Next level lower
                    cmpb      #8                  Done all of them?
                    bne       L29A8               No, keep converting
                    puls      pc,y,x,d

* Check if <CTRL>-<E> / <BREAK> was pressed by user
* Entry: None
* Exit:  Carry clear if no <BREAK> in keyboard buffer
*        Carry set if one was pressed
*        All regs preserved
L29EB               pshs      y,x,d               Preserve regs
                    lbsr      L13C2               Go check if any data waiting in keyboard buffer
                    bcs       L2A0F               No, skip ahead
                    clra                          Yes, put # bytes waiting into Y
                    tfr       d,y
                    ldx       #u060E              Point to keyboard buffer
                    clra                          Std In
                    os9       I$Read              Go read it in
                    bcs       L2A0F               Error, skip ahead
                    tfr       y,d
                    ldx       #u060E              Point to beginning of buffer again
L2A06               lda       ,x+                 Get keypress
                    cmpa      #$05                <CTRL>-<E> / <BREAK>?
                    beq       L2A12               Yes, exit with carry set
                    decb                          Check whole keyboard buffer for it
                    bne       L2A06
L2A0F               clrb                          No break key, exit with carry clear
                    puls      pc,y,x,d

L2A12               comb                          <BREAK> key found, exit with carry set
                    puls      pc,y,x,d

L2A15               pshs      y,x,b               Preserve regs
                    lbsr      L3BBC               Go update seconds (via VRN if present else CLOCK)
L2A1A               bsr       L29EB               Check if <BREAK> was pressed by user
                    bcs       L2A4C               Yes, restore regs & return
                    lda       <u002B              Get path to modem
                    ldb       #SS.Ready           Check if any data ready
                    os9       I$GetStt
* NOTE: MAY WANT TO CHANGE L2A31 BELOW TO DO LDA <u002B,u FIRST SO BCC HERE
*   CAN SKIP IT & GO STRAIGHT TO LDY
                    bcc       L2A31               Maybe, go check it out
                    lbsr      L3BDA               No data on modem, go update on-screen timer
                    cmpa      #';                 Key pressed a Semi-colon or lower?
                    blo       L2A1A               Yes, eat it & try again
                    comb                          Set carry to indicate key-press?
L2A4C               puls      pc,y,x,b            Restore & return

L2A31               ldy       #$0001              Get 1 byte from modem
                    lda       <u002B              Go get path to modem
                    ldx       #u04EF
                    os9       I$Read              Read 1 byte from modem
                    bcs       L2A4F               If error, make char=NUL
                    lda       >u04EF              Get key pressed
                    clr       >u04EF              Clear out the buffer
L2A49               clrb                          No error & return with char in A
                    puls      pc,y,x,b            Restore & return

L2A4F               clra                          Clear char to NUL?
                    bra       L2A49               Exit with carry clear?

L2A52               pshs      y,x,d               Preserve regs
                    leax      >L048B,pc           Turn cursor ON
                    lbsr      L1B03
                    clrb                          1st 32 bytes of screen
                    ldx       #u070D              Point to screen output buffer
L2A60               pshs      x,b                 Preserve
                    bsr       L2A81               Print 'File:' & filename
                    puls      x,b                 Restore ptrs
                    lda       >u060E              Get 1st char of filename
                    cmpa      #C$CR               Was it CR?
                    beq       L2A78               Yes, go turn cursor back on
                    tst       <u0021
                    bne       L2A78
                    incb                          Inc which filename counter???
                    cmpb      #$20                32 allowed???
                    bne       L2A60
L2A78               leax      >L048F,pc           Turn cursor ON & return
                    lbsr      L1B03
                    puls      pc,y,x,d

* Entry: X=Ptr to screen output buffer
* B=???
L2A81               lda       #$20                Each B represents 32 bytes
                    mul
                    leax      d,x                 Point that far into screen buffer
                    pshs      x                   Preserve it
                    leax      L055F,pc            point to 'File:'
                    lbsr      L1B03               print it
                    ldb       #30
                    lbsr      L1B61               Get input string locally (?)
                    puls      x                   Restore pointer
                    ldy       #u060E              Point to where filename is
                    ldb       #32                 get length
                    lbra      L2D26               Copy 32 bytes from Y to X (filename into scrn bffr)

L2AA0               pshs      y,x,d
                    ldb       <u006A
                    lda       #$20
                    mul
                    ldx       #u070D              Point to output screen buffer
                    leax      d,x
                    ldy       #u009F              Point to old filename for downloads
                    ldb       #$20
                    lbsr      L2D1E
                    inc       <u006A
                    puls      pc,y,x,d

L2ABC               pshs      y,x,b
                    lda       #$01
                    sta       <u0029
                    bra       L2ACA

* Check if key waiting
L2AC5               pshs      y,x,b
                    clr       <u0029
L2ACA               lbsr      L13C2               Any data ready in keyboard buffer?
                    bcc       L2AD7               Yes, skip ahead
                    ldx       #$0003
                    lbsr      L0F56               Check for timer update
                    bra       L2ACA               Loop

* If key waiting, get & convert to uppercase
L2AD7               tstb                          Any chars waiting in keyboard buffer?
                    beq       L2ACA               No, go back to loop
                    ldx       #u001B              Point to buffer to hold keypress
                    ldy       #$0001
                    clra                          Std In
                    os9       I$Read              Read the key
                    lda       ,x
                    tst       <u0029
                    bne       L2AF3
                    cmpa      #$60                Under apostrophe?
                    blo       L2AF3               Yes, leave alone (upper case)
                    suba      #$20                Convert lower to upper case
L2AF3               puls      pc,y,x,b            Restore & return

* Hangup the modem from Driver call
L2AF5               clr       <u001A              Clear 1 byte buffer
                    lda       <u002B              Get path to modem
                    ldb       #SS.HngUp           Hangup the modem
                    os9       I$SetStt
                    bcs       L2B07               If error, skip ahead
                    inc       <u001A              ??? Set flag
                    rts
* No SS.HngUp call (probably ACIAPAK) - manually diddle with 6551 hardware
L2B07               ldx       #u0C2E              point to path option packet from modem
                    ldd       $1B,x               get device table address
                    addd      #V$DESC             point to descriptor address
                    std       <u0013              save pointer
                    lda       #$01                get system process descriptor
                    ldx       #u070D              Point to buffer to hold process dsc.
                    os9       F$GPrDsc
                    leax      P$DATImg,x          point to DAT image
                    stx       >u0C84              Save ptr
                    tfr       x,d                 Move to D
                    ldx       <u0013              get descriptor address
                    ldy       #$0002              get # bytes needed
                    ldu       #u13A9              Point to buffer
                    os9       F$CpyMem            get actual address of descriptor
                    ldx       >u13A9              get the descriptor address
                    leax      IT.DLO,x            Point to Delete line offset
                    ldd       >u0C84              Get ptr to DAT image
                    ldy       #$0002              Get DELETE line & echo settings
                    ldu       #u0011              Where to put copies of them
                    os9       F$CpyMem
* NOTE: Should be able to remove this LDU entirely
                    ldu       #$0000              Reset U to normal
                    rts

L2B50               pshs      y,x,d               Preserve regs
                    ldx       #u13A9              Point to temp buffer
                    ldd       #$0253              CurXY to 51,1
                    std       ,x
                    lda       #$20
                    sta       $02,x
                    ldy       #$0003
                    lda       <u003E              Position cursor in status window
                    os9       I$Write
                    ldx       #u002D              Point to name of terminal port
                    clrb
L2B6D               lda       ,x+                 Print name (up to 1st 5 chars) of port in status
                    incb                          window
                    cmpa      #$21
                    blo       L2B78
                    cmpb      #$05
                    blo       L2B6D
L2B78               ldx       #u002D
                    clra
                    tfr       d,y
                    lda       <u003E
                    os9       I$Write
                    puls      pc,y,x,d

L2B86               leay      >L0481,pc           Foreground/background color sets & clear scrn
                    ldx       #u13A9              Buffer to hold
                    pshs      x
                    ldb       #$07                Copy all 3 commands into buffer
                    lbsr      L2D26
                    puls      x
                    lda       <u0086              Get ??? color
                    sta       $05,x               Save as background color
                    lda       <u0087              Get Fcolor of main window
                    sta       $02,x               Save as foreground color
                    lda       <u003E              Clear out status window with these colors
                    ldy       #$0007
                    os9       I$Write
                    tst       <u0040              Is conference mode on?
                    beq       L2BC0               No, skip ahead
                    lda       <u003E              Print 'Conf' in status window
                    leax      >L09E8,pc
                    ldy       #$0007
                    os9       I$Write
L2BC0               leay      >L00EB,pc           Copy 'Supercomm' header into buffer
                    ldx       #u13A9
                    ldb       #$1E
                    lbsr      L2D26
                    ldx       #u13A9              Modify colors
                    lda       <u008C
                    sta       $07,x
                    lda       <u0087              Get Fcolor
                    sta       <$19,x
                    tst       <u0019              Special version flag set?
                    beq       L2BE8               No, skip ahead
                    lda       #$61                Yes, add 'a' to name
                    sta       <$16,x
L2BE8               lda       <u003E              Print status window so far
                    lbsr      L1B05
                    lbsr      L2B50               Print port name in status window
                    lbsr      L237E               Set/Print Capture buffer open status to OFF
                    tst       <u002B              Do we have path to serial port?
                    beq       L2BFC               No, skip ahead
                    lbsr      L118F               Yes, update baud rate/word len, parity, stp bits
L2BFC               lda       <u0072              VRN on?
                    beq       L2C13               No, skip exit
                    tst       <u0075              Timer on?
                    lbeq      L0F20               No, send out black timer string
                    ldx       #u0077              Point to timer string buffer
                    ldy       #$000B              Send to status window with active colors
                    lda       <u003E
                    os9       I$Write
L2C13               rts

L2C18               tst       <u0040              Conference mode on?
                    beq       L2C71               No, exit
                    leax      >L09EF,pc           Point to CWArea 0,1 to 80,3 string
                    ldy       #u13A9              Point to buffer
                    ldb       #$06
                    lbsr      L2D1E               Copy it
                    ldx       #u13A9              Point to buffer again
                    clra
                    sta       3,x                 Change so CWArea 0,0 to 80,2
                    lda       #3
                    sta       5,x
                    ldy       #$0006
                    lda       <u003F              Send to conference window
                    os9       I$Write
                    leay      >L0481,pc           Clear out the conference window
                    ldx       #u13A9
                    pshs      x
                    ldb       #$07
                    lbsr      L2D26
                    puls      x
                    ldd       <u0088              Get Bcolor of main window/Fcolor of conf. window
                    sta       $05,x               Save them
                    stb       $02,x
                    lda       <u003F              Send to conference window
                    ldy       #$0007
                    os9       I$Write
                    leax      >L09EF,pc           Point to CWArea again (from 0,1 to 80,3)
                    ldy       #$0006              Change to new working area
                    os9       I$Write
L2C71               rts

* Error with size of file, so set internal vars to indicate size=0 bytes
L2C8D               ldd       #$0000              Save size as 0 bytes
                    std       <u005B
                    std       <u005B+2
                    puls      pc,y,x,d            Restore regs & return

* NOTE: WHEN ALL U REFERENCES GONE, CAN ELIMINATE PSHS/PULS U
L2C72               pshs      y,x,d               Preserve regs
                    lda       <u0042              Get path to download file
                    ldb       #SS.Size            Get size of file
                    os9       I$GetStt
                    tfr       u,y                 Move LSW of size to Y
                    bcs       L2C8D               Error getting size, set to 0
                    stx       <u005B              Save 4 byte size
                    sty       <u005B+2
L2C98               ldx       2,s                 Get original X back
                    leay      >L09F5,pc           Point to decimal conversion table
                    pshs      x                   Preserve ptr to buffer for ASCII #
                    ldd       #$3007              Fill buffer with 7 '0's
L2CA4               sta       ,x+
                    decb
                    bne       L2CA4
                    puls      x                   Point to beginnning again
                    clrb                          Digit 0 (1,000,000) is where we start
L2CAC               pshs      y,x,d               Preserve regs again
                    bsr       L2CDB               Convert the digit
                    puls      y,x,d               Restore regs
                    incb                          Point to next ASCII converted digit
                    cmpb      #8                  Done all of them?
                    bne       L2CAC               No, continue
                    pshs      x                   Save ptr to ASCII string
                    leax      >L0577,pc           Print 'Size:'
                    lbsr      L1B03
                    puls      x                   Get ptr to ASCII string
                    ldy       #$0007              Size of #
L2CC6               lda       ,x                  Get char
                    cmpa      #'0                 Is it a 0?
                    bne       L2CD4               No, can print rest of string
                    leax      1,x                 Point to next char in ASCII string
                    leay      -1,y                Bump # bytes to print down
                    bne       L2CC6               Still some left, see if they are 0's
                    puls      pc,y,x,d            If 0, just exit

L2CD4               lda       #$01                Write the size to Std Out
                    os9       I$Write
                    puls      pc,y,x,d

* Entry: Y=Ptr to decimal conversion table
*        X=Ptr to 7 byte buffer for ASCII # (up to 9,999,999)
*        B=which ASCII # (0-6) (from million to 1) we are currently doing
* Does one digit, adjusting file size in mem down with repeated subtracts
L2CDB               leax      b,x                 Point to appropriate table entry in ASC # bffr
                    clra                          Calculate which 4 byte longint to try in table
                    lslb
                    rola
                    lslb
                    rola
                    leay      d,y                 Point to it
L2CE2               ldd       ,y                  Get MSW of table entry
                    cmpd      <u005B              Is it higher than MSW of file size?
                    bhi       L2D1D               Yes, skip ahead
                    blo       L2CF4               If lower, skip ahead
                    ldd       2,y                 Get LSW of table entry
                    cmpd      <u005B+2            Is it higher than LSW of file size?
                    bhi       L2D1D               No, skip ahead
L2CF4               ldd       <u005B              Get MSW of file size
                    bne       L2CFE               If file >64K, skip ahead
                    ldd       <u005B+2            <64K, get size
                    beq       L2D1D               If 0, return
L2CFE               inc       ,x                  Inc. ASCII #
                    ldd       <u005B+2            Get LSW of file size
                    subd      2,y                 Subtract LSW of table entry
                    std       <u005B+2            Save result
                    bhs       L2D13               Didn't wrap, continue
                    ldd       <u005B              Get MSW of file size
                    subd      #$0001              Bump down by 1
                    std       <u005B              Save result
L2D13               ldd       <u005B              Get MSW of file size
                    subd      ,y                  Subtract MSW of table entry
                    std       <u005B              Save it
                    bra       L2CE2               Continue through until this digit is done


* Move data from X to Y
* Entry: B=Count
*        X=Pointer to source
*        Y=Pointer to destination
L2D1E               lda       ,x+
                    sta       ,y+
                    decb
                    bne       L2D1E
L2D1D               rts

* Move data from Y to X
* Entry: B=Count
*        X=Pointer to destination
*        Y=Pointer to source
L2D26               lda       ,y+
                    sta       ,x+
                    decb
                    bne       L2D26
                    rts

L2D2E               pshs      x,a
                    tst       <u001A
                    beq       L2D41
                    lda       <u002B              Get path to modem
                    ldb       #SS.ComSt           Get current parity & baud rate
                    os9       I$GetStt
                    tfr       b,a                 Move possible error code to A
                    bra       L2D46

L2D41               ldx       <u0011              Get ???
                    lda       1,x
L2D46               anda      #$20
                    beq       L2D4D
                    clrb
L2D4B               puls      pc,x,a

L2D4D               comb
                    puls      pc,x,a

L2D50               pshs      x,d                 Preserve regs
                    ldx       #$0003              Sleep 3 ticks (or until signal)
                    os9       F$Sleep
                    ldb       #SS.Ready           Any data ready on modem?
                    lda       <u002B              Get path # to modem
                    os9       I$GetStt
                    bcs       L2D7E               No, exit
                    ldx       #$0015              Go sleep for up to 21 ticks
                    lbsr      L0F56
* NOTE: IT DOESN'T CHECK IF THERE ACTUALLY IS DATA THERE THIS TIME
                    lda       <u002B              Any data ready on modem this time?
                    ldb       #SS.Ready
                    os9       I$GetStt
                    clra
                    tfr       d,y                 # bytes ready into Y
                    ldx       #u13A9              Buffer to put modem data in
* NOTE: SHOULD BE ABLE TO REMOVE MOST OF THESE DOUBLE LDA'S OF PATH #
                    lda       <u002B              Get path # to modem again
                    os9       I$Read              Read from modem
                    clrb
L2D7E               puls      pc,x,d              Restore & return

* Entry: B=Count
*        X=Ptr
L2D82               lda       ,x+                 Get byte
                    decb                          Done all bytes?
                    bne       L2D8B               No, skip ahead
                    ldb       #$01
                    bra       L2DC7

L2D8B               cmpa      #'0                 If not a number, eat char & try next
                    blo       L2D82
                    cmpa      #'9
                    bhi       L2D82
                    tfr       x,y                 Found numeric digit, move ptr to it to Y
                    leay      -1,y                Bump back by 1
L2D97               lda       ,x+                 Now, search for next non-digit from here
                    cmpa      #'0
                    blo       L2DA3
                    cmpa      #'9
                    bls       L2D97

L2DA3               leax      -1,x                Bump ptr back to 1st non-digit past digit
                    ldd       #$2020              Store 2 spaces here
                    std       ,x
                    lda       #$A0                ???
                    sta       4,y
                    leax      >L0652,pc           Point to baud rate table
                    clrb
* NOTE: ELIMINATE F$CMPNAM WITH LOCAL VERSION!!!
L2DB3               pshs      y,x,b               Preserve regs
                    ldb       #$05                Size to compare
                    os9       F$CmpNam            Check if they match
                    puls      y,x,b               Restore regs
                    bcc       L2DC7               They match, skip ahead
                    leax      5,x                 Point to next baud rate to check
                    incb                          Inc baud rate counter
                    cmpb      #8                  Done all 8 possible baud rates
                    bne       L2DB3               No, try next
                    rts                           Yes, return

* Found baud rate match
L2DC7               lda       >u0CA5              Get baud/stop bits/word len
                    anda      #%11111000          Keep all but baud
                    sta       >u0CA5              Save result
                    orb       >u0CA5              Merge in baud rate
                    stb       >u0CA5              Save with new baud rate
                    lbra      L118F               Go update the status line & return

* NOTE FIX CMPNAM BELOW TO NOT USE SYSTEM CALL!!!
L2DDD               pshs      y,x,d               Preserve regs
                    lbsr      L2D50               Check for data ready on modem
                    bcs       L2E1B               Nope, Exit with carry set
                    sty       <u0C88              Save # bytes waiting (into size of conv. txt bfr)
                    ldx       #u13A9              Point to temp buffer
                    ldb       <u0C89              Get LSB of modem buffer size
                    subb      #7                  Bump down by 7 (to fit word 'CONNECT')
L2DF3               pshs      x,b                 Preserve regs
                    leay      <L02D1,pc           Point to 'CONNECT'
                    ldb       #$07                Check if connect string found
                    os9       F$CmpNam
                    puls      x,b                 Restore regs
                    bcc       L2E09               Found, skip ahead
                    leax      1,x                 Bump source ptr up by 1
                    decb                          Dec # bytes left in read buffer to check
                    bne       L2DF3               Keep checking whole buffer
L2E1B               comb                          Not found, exit with carry set
                    puls      pc,y,x,d

L2E09               ldb       <u0C89              Get LSB of buffer size
                    ldx       #u13A9              Point to temp buffer
                    ldy       #u00DF              Point to modem buffer
                    lbsr      L2D1E               Copy temp buffer to modem buffer
                    clrb                          No error & exit
L2E19               puls      pc,y,x,d

L02D1               fcs       'CONNECT'

L02D8               fcs       'BUSY'

* NOTE FIX CMPNAM BELOW TO NOT USE SYSTEM CALL!!!
L2E1E               pshs      y,x,d               Preserve regs
                    ldx       #u13A9              Point to temp buffer
                    ldb       #$0E                (Only checks 1st 14 bytes)
L2E26               pshs      x,b
                    leay      <L02D8,pc           Point to 'BUSY'
                    ldb       #$04
                    os9       F$CmpNam            See if we found it
                    puls      x,b
                    bcc       L2E3C               Yes, skip ahead
                    leax      1,x                 Go forward through buffer looking for 'BUSY'
                    decb                          Keep checking until done
                    bne       L2E26
L2E3C               puls      pc,y,x,d            Restore & return

* Re-Calculate module CRC and re-save module
L2E3E               pshs      d,x,y,u             preserve regs
                    leax      name-$d,pc          point to start of module
                    ldy       M$Size,x            get module size
                    stx       <u0015              save pointer to start of module
                    leay      -3,y                take off size of CRC
                    sty       <u0017              save module size
                    tfr       x,u                 calculate CRC
                    tfr       y,d
                    leau      d,u
                    ldd       #$FFFF
                    std       ,u
                    sta       2,u
                    os9       F$CRC
                    com       ,u
                    com       1,u
                    com       2,u
                    puls      d,x,y,u             restore regs
                    lda       #EXEC.+UPDAT.       open supercomm in current execution DIR
                    leax      name,pc             point to module name
                    os9       I$Open              open it
                    bcs       L2E82               error, return
                    ldx       <u0015              get pointer to module header
                    ldy       <u0017              get module size
                    leay      3,y                 add CRC
                    os9       I$Write             write it
                    os9       I$Close             close file
L2E82               rts                           return

L2E83               pshs      y,x,d               Preserve regs
                    leax      >L0A24,pc           Point to default option settings
                    ldy       #u0CA5              Point to current option settings
                    ldb       #$4D                Copy current options, dial directory &
                    lbsr      L2D26               Default dir into code (for init)
                    ldd       #$1603              Set overlay window size to 22x3
                    std       >u0C91              Save
                    ldd       #$1D04              Start coords @ 29,4
                    std       >u0C8F
                    lbsr      L1C81               Pop up the overlay window
                    leax      >L048F,pc           Cursor OFF
                    lbsr      L1B03
                    leax      >L08B6,pc           Print 'Saving SuperComm'
                    lbsr      L1B03
                    bsr       L2E3E               Re-Calc CRC for supercomm & save it
                    leax      >L048B,pc           Turn Cursor ON
                    lbsr      L1B03
                    lbsr      L1CDE               Remove overlay windows
                    puls      pc,y,x,d            Restore regs & return

L2EBF               pshs      y,x,d
                    tst       <u0072              Is there a path to VRN?
                    beq       L2ED8               No, skip ahead
                    clr       <u0075              Force timer to OFF
                    leax      >L0366,pc           Point to default timer string
                    ldy       #u0077              Point to buffer for ASCII timer string
                    ldb       #$0B                Copy default into current
                    lbsr      L2D1E
                    lbsr      L0F20               Update the timer on-screen
L2ED8               lbsr      L43CA               ??? Do something with receive buffer?
                    tst       <u0040              Conference mode on?
                    beq       L2EE3               No, skip ahead
                    lbsr      L2610               Yes, draw it on screen
L2EE3               ldd       #$0000
                    std       <u0009
                    ldx       #u16B9              Point to start of ASCII receive buffer
                    stx       <u0093              Save ptr
                    clr       <u0064              ???
                    lbsr      L1EDC               Clear the screen
                    ldd       #$0503              Overlay window from 5,3 to 73,19
                    std       >u0C8F
                    ldd       #$4411
                    std       >u0C91
                    lbsr      L1C81               Go put it on screen
                    lda       #$81
                    leax      >L0A31,pc           point to path to dial directory
                    os9       I$Open
                    bcs       L2F9A
                    sta       <u003D              Save path # to dialing directory name
* NOTE: CAN REMOVE PSHS/PULS U LATER
                    pshs      u
                    ldx       #$0000              skip past '.' & '..'
                    ldu       #$0040
                    os9       I$Seek
                    puls      u
                    bcs       L2F9A
L2F26               lda       <u003D              Get path # to directory
                    ldy       #$0020              Size of 1 dir entry
                    ldx       #u13A9              Point to temp buffer
                    os9       I$Read              Read filename
                    bcc       L2F3C               Got filename, skip ahead
                    cmpb      #E$EOF              End of directory?
                    bne       L2F9A               No, exit with error
                    bra       L2F4C               Skip ahead

L2F3C               lbsr      L3118               Go check filename
                    bcs       L2F43
                    bsr       L2FA5
L2F43               lda       <u0064
                    cmpa      #$1D
                    bls       L2F26
L2F4C               lda       <u0064
                    sta       >u0C98
                    lda       <u003D              Close path to dir
                    os9       I$Close
                    lbsr      L3038
                    tst       <u0092
                    beq       L2F79
                    lbsr      L1BC7
                    ldd       #$0000
                    std       >u131C
                    lbsr      L1EDC
                    leax      >L048F,pc
                    lbsr      L1B03
                    lbsr      L314B
L2F79               lbsr      L1CDE
                    lbsr      L1BDF
                    lbsr      L1C57
                    lbsr      L1EDC
                    leax      >L048B,pc
                    lbsr      L1B03
                    puls      y,x,d               Restore regs
                    ldx       #u00DF              Get ptr to modem buffer
                    ldy       <u0C88              Get # bytes read on modem
                    lbra      L0FD2               Go process

L2F9A               os9       F$PErr              Print error
                    ldx       #$0078              Sleep for up to $78 ticks???
                    lbsr      L0F56
                    bra       L2F79

L2FA5               pshs      y,x,d               Preserve regs
                    ldx       #u13A9              Point to filename buffer
                    ldy       <u0093
                    ldb       #$1E
L2FB2               lda       ,x+                 Get char from filename buffer
                    decb                          Dec count
                    tsta                          Hi bit set (end of filename)?
                    bpl       L2FC3               No, copy char & keep going
                    suba      #$80                Bump down to normal char
                    sta       ,y+                 Save normal version
                    ldd       #$0A0D              Add LF & CR
                    std       ,y
                    bra       L2FC8

L2FC3               sta       ,y+                 Save char
                    tstb                          Done maximum chars yet?
                    bne       L2FB2               No, continue copying/checking

L2FC8               inc       <u0064
                    bsr       L300E
                    bsr       L2FDE
                    ldy       <u0093
                    leay      <$20,y
                    sty       <u0093
                    puls      pc,y,x,d            Restore & return

L2FDE               pshs      y,x,d               Preserve regs
                    ldx       <u0093              ???
                    ldy       #u13A9              Point to temp buffer
                    ldb       #$1E
L2FEA               lda       ,x+
                    decb
                    cmpa      #'_
                    bne       L2FF3
                    lda       #C$SPAC
L2FF3               cmpa      #'.
                    bne       L2FFA
                    lda       #C$CR
                    clrb
L2FFA               sta       ,y+
                    tstb
                    bne       L2FEA
                    lda       #$01
                    ldy       #$001E
                    ldx       #u13A9
                    os9       I$WritLn
                    puls      pc,y,x,d

L300E               pshs      y,x,d
                    ldx       #u13A9
                    ldb       <u0064
                    cmpb      #$0F
                    bhi       L301F
                    lda       #$24
                    bra       L3023
L301F               lda       #$45
                    subb      #$0F
L3023               sta       $01,x
                    lda       #$02
                    sta       ,x
                    addb      #$20
                    stb       $02,x
                    ldy       #$0003
                    lda       #$01
                    os9       I$Write
                    puls      pc,y,x,d

L3038               pshs      y,x,d               Preserve regs
                    leax      >L048F,pc           Cursor OFF
                    lbsr      L1B03
                    lda       #$01
                    sta       <u0092
L3047               ldx       #u13A9
                    cmpa      >u0C98
                    bls       L3059
                    lda       >u0C98
                    sta       <u0092
L3059               cmpa      #$0F
                    bhi       L3061
                    adda      #$20
                    bra       L3063

L3061               adda      #$11
L3063               sta       $02,x
                    lda       <u0092
                    cmpa      #$0F
                    bhi       L3071
                    lda       #$21
                    bra       L3073

L3071               lda       #$42
L3073               sta       1,x
                    lda       #$02
                    sta       ,x
                    bsr       L3107               Go blank out previous '==>'
                    lda       #$01
                    ldy       #$0003
                    os9       I$Write
                    leax      >L0693,pc           Print  '==>'
                    ldy       #$0003
                    os9       I$Write
L3090               lbsr      L2AC5
                    cmpa      #$08
                    bne       L30A7
L3097               lda       <u0092
                    cmpa      #$0F
                    bhi       L30A3
                    adda      #$0F
L3100               sta       <u0092
                    bra       L3047

L30A3               suba      #$0F
                    bra       L3100

L30A7               cmpa      #$09
                    beq       L3097
L30AD               cmpa      #$0C
                    bne       L30CB
                    lda       <u0092
                    cmpa      #$01
                    beq       L30C1
                    suba      #$01
                    sta       <u0092
                    bra       L3100

L30C1               lda       >u0C98
                    sta       <u0092
                    bra       L3100

L30CB               cmpa      #$0A
                    bne       L30E9
                    lda       <u0092
                    cmpa      >u0C98
                    beq       L30E1
                    adda      #$01
                    sta       <u0092
                    bra       L3100

L30E1               lda       #$01
                    sta       <u0092
                    bra       L3100

L30E9               cmpa      #$0D
                    bne       L30F6
L30ED               leax      >L048B,pc
                    lbsr      L1B03
                    puls      pc,y,x,d

L30F6               cmpa      #$05
                    bne       L3090
                    clr       <u0092
                    bra       L30ED

L3107               pshs      y,x,a               Clear out '==>' from previous menu selection
                    lda       #$01
                    leax      >L0682,pc           Write out 3 BSP/SPC's to Std Out
                    ldy       #$0006
                    os9       I$Write
                    puls      pc,y,x,a

L3118               pshs      y,x,d
                    ldx       #u13A9
                    lda       ,x
                    beq       L3148
                    ldb       #$1B
L3124               lda       ,x+
                    decb
                    cmpa      #'.
                    beq       L3130
L312B               tstb
                    bne       L3124
L3148               comb
                    puls      pc,y,x,d

L3130               lda       ,x+
                    decb
                    cmpa      #'a
                    bne       L312B
                    lda       ,x+
                    decb
                    cmpa      #'d
                    bne       L312B
                    lda       ,x+
                    decb
                    cmpa      #$E6
                    bne       L312B
                    clrb
L3146               puls      pc,y,x,d

L314B               pshs      y,x,d
                    lda       <u0092
                    deca
                    ldb       #$20                32 bytes/entry
                    mul
                    ldx       #u16B9              Point to ASCII receive buffer
                    leax      d,x                 Point to proper entry
                    stx       <u0093              Save ptr
                    ldx       #u13A9
                    leay      >L0A31,pc           Point to '/dd/sys/dial'
L3169               lda       ,y+                 Copy path to buffer
                    bmi       L3171               Do until high bit set (terminates string)
                    sta       ,x+
                    bra       L3169

L3171               suba      #$80                Bump down to normal char
                    ldb       #'/                 Append slash to allow for filename
                    std       ,x++                Save in buffer
                    tfr       x,y
                    ldx       <u0093              Get ptr back
                    ldb       #$20                Up to 32 bytes max
L317D               lda       ,x+
                    sta       ,y+
                    bmi       L318A               If hi bit, that was last one
                    decb                          Hit max size yet?
                    bne       L317D               No, continue moving

L318A               ldx       #u13A9              Point to name of file to open
                    lda       #READ.
                    os9       I$Open              Open it
                    bcs       L31CF               Couldn't, print error message & exit
                    sta       <u003D              Save path to .ADF file
                    lbsr      L24D1               Go clear out Search & Reply strings
                    lda       #$01
                    sta       >u0D19
                    lda       #$1E
                    sta       >u0D1A
L31A7               lda       <u003D              Get path to ADF file again
                    ldx       #u13A9              Point to buffer
                    ldy       #$0050              Get up to an 80 char line
                    os9       I$ReadLn
                    bcc       L31BD               Got it, go parse (?)
                    cmpb      #E$EOF              End of file error?
                    bne       L31CF               No, print error & exit
L31C1               lda       <u003D              EOF, get path
                    os9       I$Close             Close the file
                    lbsr      L118F               Go update the status line
                    lbra      L33E0

L31BD               bsr       L31D4
                    bra       L31A7

L31CF               os9       F$PErr              Print error, & exit
L31CD               puls      pc,y,x,d

* Parse a line from ADF file
L31D4               pshs      y,x,d               Preserve regs
                    clra                          Current keyword being checked=0
                    leay      >L06D1,pc           Point to keyword list
L31DB               ldx       #u13A9              Point to buffer
                    ldb       #$03                Size of keyword=3
                    inca                          On keyword 1
                    os9       F$CmpNam
                    leay      3,y                 Point to next keyword
                    bcc       L31ED               Found match, skip ahead
                    cmpa      #32                 Done all 32 keywords?
                    blo       L31DB               No, keep checking
L31ED               cmpa      #31                 Is it 32?
                    bhi       L326F               Yes, exit
                    leax      3,x                 Point past keyword
                    ldb       ,x+                 Get next char
                    cmpb      #'=                 Is it an '='?
                    bne       L326F               No, exit
* Change to use DECA instead of repeated CMPA's
                    cmpa      #$01                ADS (Auto Dial String)?
                    beq       L3271
                    cmpa      #$02                BPS (Bits per second (Baud))?
                    lbeq      L328A
                    cmpa      #$03                ECH (Keyboard echo)?
                    lbeq      L32A3
                    cmpa      #$04                HEK (Host Echo)?
                    lbeq      L32B1
                    cmpa      #$05                TRM (Terminal Type)
                    lbeq      L32BF
                    cmpa      #$06                LNF (Line Feeds on in & outgoing text)
                    lbeq      L32CE
                    cmpa      #$07                XON (XON char)
                    lbeq      L32E0
                    cmpa      #$08                XOF (XOFF char)
                    lbeq      L32E9
                    cmpa      #$09                RTR (# of retries)
                    lbeq      L32F3
                    cmpa      #$0A                RPS (Time each entry lasts)
                    lbeq      L32FD
                    cmpa      #$0B                PAR (Parity)
                    lbeq      L3307
                    cmpa      #$0C                CLK (Keyclick)
                    lbeq      L3311
                    cmpa      #$0D                WRD (Word Length)
                    lbeq      L3320
                    cmpa      #$0E                STP (Stop bits)
                    lbeq      L3338
                    cmpa      #$16                KM1-8 (Keyboard macros)
                    lbls      L3358               Go handle all of them
                    cmpa      #$17                CNS (String to send on Connect)
                    lbeq      L337E
                    cmpa      #$1B                SS1-4 (Search string for auto-login)
                    lbls      L2508               Go handle them
                    cmpa      #$1F                RS1-4 (Reply strings for SSn's)
                    lbls      L24E3
                    cmpa      #$20                RLF (Line feeds added to received text)
                    lbeq      L3392
                    cmpa      #$21                TLF (Line feeds added to xmitted text)
                    lbeq      L33A1
L326F               puls      pc,y,x,d            Restore & return

L3271               ldy       #u0CF2
                    ldb       #$20                Max size=32 bytes
L3277               lda       ,x+                 Get char
                    sta       ,y+                 Copy it
                    cmpa      #C$CR               End of line?
                    beq       L3284               Yes, skip ahead
                    decb                          Hit max size?
                    bne       L3277               No, keep copying
                    puls      pc,y,x,d            Restore & return

L3284               clr       ,y+                 Append NUL
                    puls      pc,y,x,d            Restore & return

L328A               lbsr      L33B0
                    andb      #%00000111          Just keep baud rate
                    lda       >u0CA5              Get baud/word len/stop bits
                    anda      #%11111000          Keep all but baud
                    sta       >u0CA5              Save it
                    orb       >u0CA5              Merge with B
                    stb       >u0CA5              Save new baud rate
                    puls      pc,y,x,d

L32A3               lbsr      L33B0
                    tstb
                    beq       L32AB
                    ldb       #$01
L32AB               stb       >u0CA7              Save echo type
                    puls      pc,y,x,d

L32B1               lbsr      L33B0
                    tstb
                    beq       L32B9
                    ldb       #$01
L32B9               stb       >u0CB1
                    puls      pc,y,x,d

L32BF               lbsr      L33B0
                    cmpb      #$03
                    blo       L32C8
                    ldb       #$02
L32C8               stb       >u0CA6
                    puls      pc,y,x,d

L32CE               lbsr      L33B0
                    tstb
                    beq       L32D6
                    ldb       #$01
L32D6               stb       >u0CA8
                    stb       >u0CA9
                    puls      pc,y,x,d

L32E0               lbsr      L33B0
                    stb       >u0CAF              Pause off character code
                    puls      pc,y,x,d

L32E9               lbsr      L33B0
                    stb       >u0CB0              Pause on character code
                    puls      pc,y,x,d

L32F3               lbsr      L33B0
                    stb       >u0D19
                    puls      pc,y,x,d

L32FD               lbsr      L33B0
                    stb       >u0D1A
                    puls      pc,y,x,d

L3307               lbsr      L33B0
                    stb       >u0CAC              Save parity
                    puls      pc,y,x,d

L3311               lbsr      L33B0
                    tstb
                    beq       L3319
                    ldb       #$01
L3319               stb       >u0CAA
                    puls      pc,y,x,d

L3320               bsr       L33B0
                    lda       >u0CA5
                    anda      #%01001111          Keep baud rate
                    sta       >u0CA5              Save it
                    orb       >u0CA5              Mask in Word Len/Stop bits
                    stb       >u0CA5              Save new result
                    puls      pc,y,x,d

L3338               bsr       L33B0
                    tstb
                    beq       L3344
                    cmpb      #$80
                    beq       L3344
                    puls      pc,y,x,d

L3344               lda       >u0CA5
                    anda      #%01111111          Keep all but Stop bits
                    sta       >u0CA5
                    orb       >u0CA5              Merge in stop bit setting
                    stb       >u0CA5
                    puls      pc,y,x,d

L3358               lda       -2,x                Get macro #
                    suba      #$31                Convert ASCII 1-8 to binary 0-7
                    cmpa      #7                  Make sure only 0-7
                    bhi       L337B               Not, exit
                    ldb       #$80                128 bytes reserved per key
                    mul
                    ldy       #u0D1C              Point to start of programmable keys buffer
                    leay      d,y                 Point to appropriate key in table
                    ldb       #$80                Max size allowed=128 bytes
L336B               lda       ,x+                 Get char
                    cmpa      #C$CR               Hit end of line?
                    beq       L3378               Yes, flag end with NUL & exit
                    sta       ,y+                 Save char
                    decb                          Past max size?
                    bne       L336B               No, keep copying
                    puls      pc,y,x,d

L3378               clrb                          Append NUL byte
                    std       ,y                  Save CR & NUL
L337B               puls      pc,y,x,d            Return

L337E               ldy       #u131C
                    ldb       #$80
L3384               lda       ,x+
                    cmpa      #C$CR               Hit end?
                    beq       L3378               Yes, append NUL & exit
                    sta       ,y+
                    decb
                    bne       L3384
                    puls      pc,y,x,d

L3392               bsr       L33B0
                    tstb
                    beq       L339A
                    ldb       #$01
L339A               stb       >u0CA9
                    puls      pc,y,x,d

L33A1               bsr       L33B0
                    tstb
                    beq       L33A9
                    ldb       #$01
L33A9               stb       >u0CA8
                    puls      pc,y,x,d

L33B0               lda       1,x
                    cmpa      #$21
                    blo       L33D2               Space or control char, skip ahead
                    lda       ,x
                    suba      #$30                Convert to Binary #
                    cmpa      #10                 Possibly legit digit?
                    blo       L33C0
                    suba      #$07
L33C0               ldb       #$10
                    mul
                    lda       1,x
                    suba      #$30                Convert to Binary #
                    cmpa      #10                 Possibly legit digit
                    blo       L33CD               Decimal digit, skip ahead
                    suba      #$07
L33CD               sta       1,x
                    addb      1,x
                    rts

L33D2               lda       ,x
                    suba      #$30
                    cmpa      #10
                    blo       L33DC
                    suba      #$07
L33DC               tfr       a,b
                    rts

L33E0               tst       >u0D19
                    bne       L33ED
                    clr       >u131C
                    lbra      L3533

L33ED               lbsr      L1CDE
                    ldd       #$1403
                    std       >u0C8F
                    ldd       #$2808
                    std       >u0C91
                    lbsr      L1C81
                    leax      >L04B1,pc           Print to 'Count', 'Seconds', etc.
                    lbsr      L1B03
                    lbsr      L23D0               Center text
                    leax      >L04DB,pc           Print 'Dialing'
                    lbsr      L1B03
                    lbsr      L2FDE
                    leax      >L04E5,pc           CurXY @ 23,3
                    lbsr      L1B03
                    ldb       #$01
                    stb       >u139F
                    lbsr      L354B
                    ldx       #u0CF2
                    clrb
L342A               lda       ,x+
                    incb
                    cmpb      #$20
                    bhi       L3434
                    tsta
                    bne       L342A
L3434               decb
                    bne       L343E
                    clr       >u131C
                    lbra      L3533

L343E               clra
                    tfr       d,y
                    sty       >u0CA1
L3446               leax      >L02DC,pc           Write out 'ATH <CR>' to modem
                    ldy       #$0004
                    lda       <u002B
                    os9       I$Write
                    ldx       #$005A
                    lbsr      L0F56
                    lda       <u002B              Check if data waiting at modem
                    ldb       #SS.Ready
                    os9       I$GetStt
                    bcc       L346E
                    lbsr      L2D2E
                    bcs       L346E
                    clr       <u0022
                    bra       L3473

L346E               lda       #$01
                    sta       <u0022
L3473               lbsr      L2D50
                    ldy       >u0CA1
                    ldx       #u0CF2
                    lda       <u002B
                    os9       I$Write
                    lbsr      L2D50
                    ldb       #$FF
                    stb       >u0CA4
L348E               lbsr      L1B4E
                    sta       >u0CA3
L3495               tst       <u0022
                    beq       L34A6
                    lbsr      L2DDD
                    bcc       L3509
                    lbsr      L2E1E
                    bcs       L34AB
                    bra       L34DC

L34A6               lbsr      L2D2E
                    bcs       L3509
L34AB               ldd       #SS.KySns           Get keysense byte from StdIn
                    os9       I$GetStt
                    cmpa      #$80
                    bne       L34BC
                    clr       >u131C
                    bra       L3533

L34BC               lbsr      L1B4E
                    cmpa      >u0CA3
                    beq       L3495
                    inc       >u0CA4
                    leax      >L04EA,pc
                    lbsr      L1B03
                    ldb       >u0CA4
                    bsr       L354B
                    cmpb      >u0D1A
                    blo       L348E
L34DC               inc       >u139F
                    leax      >L04E5,pc
                    lbsr      L1B03
                    ldb       >u139F
                    bsr       L354B
                    ldb       >u0D19
                    cmpb      #$FF
                    lbeq      L3446
                    ldb       >u139F
                    cmpb      >u0D19
                    lblo      L3446
                    clr       >u131C
                    bra       L3533

L3509               ldd       #1*256+SS.Tone      Send Tone to Std Out
                    ldx       #$3F06
                    ldy       #$0D00
                    os9       I$SetStt
                    ldy       #$0E00
                    os9       I$SetStt            Send another one (higher frequency)
                    ldy       #$0F00
                    os9       I$SetStt            Send another one (still higher frequency)
                    tst       <u0072
                    beq       L3533
                    inc       <u0075
                    lda       <u0073
                    sta       <u0074
L3533               lbsr      L1BAD
                    lda       <u003D              Close disk file
                    os9       I$Close
                    tst       >u131C
                    beq       L3545
                    lbsr      L1A19
L3545               lbsr      L12B5
                    puls      pc,y,x,d

L354B               pshs      x,d
                    ldx       #u13A9
                    clra
L3552               cmpb      #$64
                    blo       L355B
                    subb      #$64
                    inca
                    bra       L3552

L355B               adda      #$30
                    sta       ,x+
                    clra
L3560               cmpb      #10
                    blo       L3569
                    subb      #$0A
                    inca
                    bra       L3560

L3569               adda      #$30
                    sta       ,x+
                    addb      #$30
                    stb       ,x+
                    ldx       #u13A9
                    ldy       #$0003
                    lda       #$01                Write 3 bytes to Std Out
                    os9       I$Write
                    puls      pc,x,d

* Download a file processing (PgDn from command state)
L3580               leax      >L048F,pc           turn off cursor
                    inc       >u0CA0
                    lbsr      L1B03
                    ldd       #$1C05              get start co-ordinates of overlay
                    std       >u0C8F
                    ldd       #$1907              get size of overlay
                    std       >u0C91
                    lbsr      L1C81               place overlay
                    leax      >L0734,pc           print available protocols
                    lbsr      L1B03
                    lda       #$04                get max # protocols
                    sta       >u139E              save it
                    ldb       <u004B              get last selected protocol
                    lbsr      L1DB8               let user choose new protocol
                    lbsr      L1CDE               get rid of overlay window
                    leax      >L048B,pc           turn cursor back on
                    lbsr      L1B03
                    clr       <u0046              clear ymodem batch flag
                    ldb       >u0C84              get selected type
                    beq       L35D6               ASCII, skip ahead
                    cmpb      #$03                within max?
                    lbhi      L0C5E               no, go back to main loop
                    stb       <u004B              update last selected protocol
                    cmpb      #$02                ZModem?
                    lbhi      L1793               yes, do it
                    blo       L3648               X/Ymodem, go do it
                    inc       <u0046              flag Ymodem batch
* X/Ymodem (batch) file receive
L3648               pshs      d,x,y               Store regs
                    lbra      L36F4               Go do X/Ymodem (w or w/o batch)

L35D6               stb       <u004B              update last selected protocol
                    lbra      L4233               go do ASCII Xfer

* Upload a file (PdUp in main command state)
L35DF               leax      >L048F,pc           point to CurOff
                    clr       >u0CA0
                    lbsr      L1B03               turn cursor off
                    ldd       #$1C05
                    std       >u0C8F
                    ldd       #$1908
                    std       >u0C91
                    lbsr      L1C81
                    leax      >L07A5,pc           Point to file send menu
                    lbsr      L1B03               Print it
                    lda       #$05
                    sta       >u139E
                    ldb       <u004A
                    lbsr      L1DB8
                    lbsr      L1CDE
                    leax      >L048B,pc           Cursor On
                    lbsr      L1B03
                    clr       <u0046
                    clr       <u0045
                    ldb       >u0C84
                    beq       L363F
                    cmpb      #$04
                    lbhi      L0C5E
                    stb       <u004A
                    cmpb      #$02
                    blo       L3648
                    inc       <u0045
                    cmpb      #$03
                    blo       L3648
                    lbhi      L1859
                    inc       <u0046
                    bra       L3648

L363F               stb       <u004A
                    lbra      L4233

* Setup Serial path options & data for file Xfer's
L364D               ldd       #$FF00
                    sta       <u0042
                    stb       <u0069
                    stb       <u005F
                    stb       <u004C
                    stb       <u006A
                    stb       <u0062
                    stb       <u0052
                    stb       <u009B
                    ldx       #u13A9
                    lda       <u002B              get path to modem
                    ldb       #SS.Opt             Get path options
                    pshs      d
                    os9       I$GetStt            get current settings
                    ldx       #u13A9              point to buffer
                    lda       PD.BAU-PD.OPT,x
                    anda      #$0F
                    sta       PD.BAU-PD.OPT,x
                    lda       PD.PAR-PD.OPT,x
                    anda      #$03
                    sta       PD.PAR-PD.OPT,x
                    clra
                    clrb
                    std       PD.XON-PD.OPT,x
                    std       PD.EKO-PD.OPT,x
                    puls      d                   restore path & option
                    os9       I$SetStt            set new path options
                    lda       >u0CB0
                    ldb       >u0CAF
                    pshs      d
                    clra
                    sta       >u0CAF
                    sta       >u0CB0
                    lbsr      L43CA
                    puls      d
                    sta       >u0CB0
                    stb       >u0CAF
                    ldd       #0
                    std       <u0009
                    ldd       #$1504              get start co-ordinates of xfer overlay
                    std       >u0C8F
                    ldd       #$2509              get size
                    std       >u0C91
                    lbra      L1C81               place xfer overlay window

L36CD               pshs      y,x,d
L36CF               lbsr      L3BBC
L36D2               lda       <u002B              Check if data ready on modem
                    ldb       #SS.Ready
                    os9       I$GetStt
                    bcc       L36E5               Maybe, go check it out
                    lbsr      L3BDA
                    cmpa      #$02
                    blo       L36D2
                    puls      pc,y,x,d

L36E5               clra
                    tfr       d,y                 # bytes received to Y
                    lda       <u002B              Get path to modem
                    ldx       #u13A9              Point to modem receive buffer
                    os9       I$Read              Read in the data
                    bra       L36CF

* X/Ymodem (batch) file receive
L36F4               lbsr      L364D               setup path options to modem for download
                    leax      >L04EF,pc           point to 'Xmodem file Xfer...'
                    lbsr      L1B03               print it
                    tst       <u0046              ymodem batch?
                    beq       L370A               no, skip ahead
                    leax      >L0511,pc           point to 'Y'
                    lbsr      L1B03               print it
L370A               leax      >L052F,pc           point to '<Break> aborts'
                    lbsr      L1B03               print it
                    tst       <u0046              ymodem batch?
                    beq       L371F               no, skip ahead
                    leax      >L048F,pc           turn cursor off
                    lbsr      L1B03
                    bra       L376A               skip to

* Get filename for X/Ymodem receive
L371F               leax      L055F,pc            point to 'File:'
                    lbsr      L1B03               print it
                    lbsr      L455D               scan for old filename
                    tst       <u009B              filename already present?
                    beq       L3742               no, skip ahead
                    ldx       #u009F              point to name
                    ldy       #$0020              get length
                    lda       #$01                print it
                    os9       I$WritLn
                    ldd       #$0704              position cursor back to start of input prompt
                    lbsr      L2294
L3742               ldb       #$1E                get max length of name
                    lbsr      L1B61               get it from user
                    tst       <u0021
                    lbne      L3954
                    leax      L045E,pc            clear the screen
                    lbsr      L1B03
                    leax      L04EF,pc            point to 'Xmodem file transer system'
                    lbsr      L1B03               print it
                    tst       <u0046              ymodem batch?
                    beq       L3772               no, skip ahead
                    leax      L0511,pc            point to 'Y'
                    lbsr      L1B03               print it
                    bra       L3772               skip ahead

L376A               tst       >u0CA0              Up/Download?
                    lbeq      L3F08
* NOTE: SHOULD CHANGE TO USE BILL'S SS.FILL CALL TO ALLOW EDITING OF 'GUESSED'
*  FILENAME
L3772               ldy       #u060E              point to user entered filename
                    ldx       #u009F              point to old filename buffer
                    lda       ,y                  get the first character
                    cmpa      #C$CR               user just hit enter?
                    bne       L378A               no, skip ahead
                    tst       <u009B              was there a old filename?
                    lbeq      L3954               no, skip ahead
                    bra       L378F

L378A               ldb       #$20                get length of name
                    lbsr      L2D26               move it to old filename buffer
L378F               tst       >u0CA0              Upload?
                    lbeq      L3F08               Yes, go do
                    tst       <u0046              Download; Batch?
                    bne       L37C9               yes, have to get filename from sender
                    leax      L056B,pc            point to 'Recv:'
                    lbsr      L1B03               print it
                    lda       #$01                print the filename
                    ldx       #u009F
                    ldy       #$0020
                    os9       I$WritLn
                    leax      L048F,pc            turn off cursor
                    lbsr      L1B03
                    lda       #WRITE.             get file mode
                    ldb       #$03                get attributes
                    ldx       #u009F              Point to filename
                    os9       I$Create            create file
                    lbcs      L3965
                    sta       <u0042              save path #
L37C9               ldd       <u0004              Get Start address of receive buffer
                    std       <u0006              Make it ptr to end of receive buffer too
                    leax      L0593,pc            point to 'Block # ... Error #'
                    lbsr      L1B03               print it
                    leax      L05B7,pc            point to 'Last Error:'
                    lbsr      L1B03               print it
                    leax      L052F,pc            point to '<Break> aborts'
                    lbsr      L1B03               print it
                    lbsr      L3E83               print '0000' for
                    lbsr      L3E9B               print '0000' for
                    tst       <u0046              Batch?
                    beq       L37F8               no, skip ahead
L37ED               lbsr      L3E83               print '0000' for
                    lbsr      L3E9B               print '0000' for
                    ldd       #$0000              Set current block # to 0 (for batch name block)
                    bra       L37FE               skip ahead

* Main X/Ymodem transfer loop
L37F8               lbsr      L3EDD               print ???
                    ldd       #1                  Set current block # to 1
L37FE               std       <u0053              Save current block #
                    leax      L06C7,pc            CurXY @ 16,1 & print 5 spaces
                    lbsr      L1B03               print it
                    ldd       #$0D07              get cursor coords for error messages
                    lbsr      L2294               move there
                    leax      L05C7,pc            Point to table of error messages for download
                    lda       #$01                To Std Out
                    ldy       #$0014              All error messages are 20 bytes (default=20 spaces
                    os9       I$Write
                    inc       <u005A
                    ldb       #$04                get # attempts for CRC mode
                    stb       <u0059              save it as a counter
* Try 4 attempts to recieve using CRC
L3823               lbsr      L3E73               send 'C' to host
                    dec       <u0059              decrement attempt count
                    lbsr      L3BBC               update timeout time
L382C               lda       <u002B              get path to modem
                    ldb       #SS.Ready
                    os9       I$GetStt            any data?
                    bcc       L38A3               yes, skip ahead
                    lbsr      L29EB               No, go check if user hit <BREAK> to abort
                    lbcs      L3992               Yes, abort transfer
                    lbsr      L3BDA               get # seconds
                    cmpa      #$03                timeout?
                    blo       L382C               no, try again
                    tst       <u0059              any attempts left?
                    bne       L3823               yes, try again
                    clr       <u005A              ???
L384C               lbsr      L3E7F               Send NAK code to modem
                    lbsr      L3BBC               Update timer stuff
* Try 10 attempts to initiate CheckSum
L3852               lda       <u002B              get path to modem
                    ldb       #SS.Ready
                    os9       I$GetStt            Any data waiting?
                    bcc       L38A3               Yes, skip ahead
                    lbsr      L29EB               No, go check if user hit <BREAK> to abort
                    lbcs      L3992               Yes, go abort transfer
                    lbsr      L3BDA               get # seconds waiting
                    cmpa      #10                 timeout?
                    blo       L3852               no, try again
                    inc       <u0052              Inc # attempts at checksum
                    lbsr      L3EC5               ??? Update some counter
                    lbsr      L1CF7               ??? (resets default colors to terminal type)
                    lda       <u0052              Get current # attempts @ checksum
                    cmpa      #10                 Done 10 of them?
                    blo       L384C               No, keep trying
                    lbra      L3992               Yes, abort transfer

L387D               ldd       <u0053              Get current block # of xfer
                    bne       L388E               There is one, skip ahead
                    lbsr      L3E7B               Send ACK to modem
                    lbsr      L3E73               Send 'C' (for CRC mode) to modem
                    bra       L3891

L388E               lbsr      L3E7B               Send ACK to modem
L3891               ldd       <u0053              Bump block # up 1
                    addd      #$0001
                    std       <u0053
                    lbsr      L3EDD               Update block # on screen
                    clr       <u0052              Clear Checksum attempt count
                    lbsr      L3EB3               Print '0000' (for block #'s?)

* Data waiting on modem comes here
L38A3               lbsr      L29EB               check for keyboard data
                    lbcs      L3992               got something, abort xfer
                    clr       <u00E2              Clear 4th byte of modem buffer
                    lbsr      L39F1               Go do the download (?)
                    pshs      cc                  Save error status
                    ldd       <u0053              Get current block #
                    bne       L38C7               Not header block, skip ahead
                    tst       <u00E2              Check 4th byte in buffer
                    bne       L38CD
                    puls      cc                  Restore error from download
                    lbra      L3992               Abort xfer

L38CD               puls      cc                  Restore error from download
                    bcc       L387D               None, go send ACK/'C' to modem
                    lda       #C$CR               Error, reset previous dload filename to CR
                    sta       <u009F
                    lbra      L3992               Abort xfer

L38C7               puls      cc
                    bcs       L38EC
L38DA               tst       <u005F
                    bne       L38FD
                    tst       <u0062
                    beq       L387D
                    clr       <u0062
                    lbsr      L3E7B
                    bra       L38A3               Go check keyboard/modem again

L38EC               lda       <u0052              Get current # attempts @ checksum
                    cmpa      #$09                Already have more than 9?
                    lbhi      L3992               Too many errors, abort xfer
                    lbsr      L36CD
                    lbsr      L3E7F               Send NAK to modem
                    bra       L38A3

* Current file xfer is done
L38FD               tst       <u0046              Batch mode on?
                    beq       L3941               No, skip ahead
* Batch mode xfer done
                    lbsr      L3E7F               Send NAK to modem
                    lbsr      L39F1               Go read block (for filename)
                    clr       <u005F
                    tst       <u004C
                    bne       L392D
                    ldd       <u005B              Get MSW of file size
                    bne       L391C               Definately not 0 length, go resize
                    ldd       <u005B+2            Get LSW of file size
                    beq       L392D               0 byte file, don't pre-extend
L391C               lda       <u0042              Get path to download file
                    ldb       #SS.Size            Re-size file to exact size from Batch header
                    ldx       <u005B
                    ldy       <u005B+2
                    tfr       y,u
                    os9       I$SetStt
L392D               lda       <u0042              Close the download file (???)
                    os9       I$Close
                    lda       #C$CR               Reset old filename to CR
                    sta       <u009F
                    lbsr      L3E7B               Send ACK to modem
                    lbra      L37ED               Reprint Block & Error #'s to '0000'

* Non-batch mode goes here
L3941               clr       <u005F
                    lbsr      L3E7B               Send ACK to modem
L3947               clr       >u0CA0              ??? Set xmit/recv flag to xmit???
                    lbsr      L1D09               Go sound a tone
                    lda       <u0042              Get path to dload file
                    os9       I$Close             Close it
L3954               lbsr      L118F               Go update the status line
                    lbsr      L1CDE               Remove overlay windows
                    clr       <u0046              Clear Batch mode flag
                    puls      y,x,d               Restore regs
                    lbra      L0C5E               Go back to main (no file xfer) loop

L3965               lda       #$07
                    lbsr      L1F0B
                    pshs      b
                    ldd       #$0D02
                    lbsr      L2294
                    lda       #$03
                    lbsr      L1F0B
                    leax      >L048F,pc           Cursor OFF
                    lbsr      L1B03
                    puls      b
                    os9       F$PErr              Print Error
                    ldx       #$003C
                    lbsr      L0F56
                    leax      >L048B,pc           Cursor ON
                    lbsr      L1B03
                    bra       L3954               Go remove windows & exit xfer

* Cancel file receive (comes here if key pressed)
L3992               lda       <u009F              get first char of filename
                    cmpa      #C$CR               anything?
                    beq       L39AA               no, skip delete
                    lda       <u0042              get path to file
                    os9       I$Close             close it
* NOTE: MAY WANT TO ADD USER OPTION TO KEEP WHATEVER WAS RECEIVED IN ABORTED
* XFER
                    ldx       #u009F              point to filename
                    os9       I$Delete            delete it
                    lbsr      L36CD               purge any remaining data from modem
* Cancel file transfer
L39AA               ldx       #u13A9              point to temp buffer
                    ldd       #$1804              CANcel code- 4 times
L39B2               sta       ,x+                 place in buffer
                    decb                          done?
                    bne       L39B2               no keep going
                    ldd       #$0304              Also add 4 <CTRL>-<C>'s
L39BB               sta       ,x+                 place in buffer
                    decb                          done?
                    bne       L39BB               no, keep going
                    lda       <u002B              get path to modem
                    ldy       #8                  get # chars
                    ldx       #u13A9              point to CAN string
                    os9       I$Write             send it to host
                    bra       L3947               Go close down xfer cleanly

L39D1               lda       #$04                Error # 4 (Time Out)
                    sta       <u004F
                    lbra      L3B83

L39D9               lda       #$03                Error # 3 (Block check failed)
                    sta       <u004F
                    lbra      L3B83

L39E1               lda       #$02                Error # 2 (Wrong Block #)
                    sta       <u004F
                    lbra      L3B83

L39E9               lda       #$01                Error # 1 (Transfer aborted)
                    sta       <u004F
                    lbra      L3B83

* Read a block??
L39F1               pshs      y,x                 Preserve regs
                    ldd       #$0000
                    std       <u004D              Clear byte counter for dload
                    std       <u0048              reset running CRC
                    sta       <u0062
                    sta       <u004F              Reset error # for xfer
                    sta       <u005F
                    lbsr      L3BBC               ??? Something with timer (timeout check?)
L3A08               ldx       #u00DF              point to modem receive buffer
L3A0C               lbsr      L3BDA               update timeout time
                    cmpa      #10                 timeout?
                    bhi       L39D1               yes, skip ahead
                    lda       <u002B              get path to modem
                    ldb       #SS.Ready           any data?
                    os9       I$GetStt
                    bcs       L3A0C               no, wait for it
                    ldy       #1                  get # bytes needed
* NOTE: Attempted to eliminate lda <u002B (redundant from GetStt above)
                    os9       I$Read              read the block header byte
                    bcs       L3A0C               error, try again
                    tfr       y,d                 move # bytes to D
                    std       <u004D              save it
                    abx                           add LSB of it to buffer pointer
                    lda       <u00DF              get the header byte
* NOTE: Change to use DECA to speed up X&Ymodem header checks?
                    cmpa      #$02                ymodem header?
                    beq       L3A57               yes, get block size
                    cmpa      #$01                xmodem header?
                    beq       L3A52               yes, get block size
                    cmpa      #$04                batch file header?
                    lbeq      L3BAC               yes, increment file count & process
                    cmpa      #$18                CAN?
                    lbeq      L3BB4               yes, cancel xfer
                    cmpa      #$03                OS-9 CAN?
                    lbeq      L3BB4               yes, cancel xfer
                    bra       L3A08               garbage data, try again

* Get XModem data block size
L3A52               ldd       #$0080              128 bytes per block (Xmodem)
                    bra       L3A5A

* Get YModem data block size
L3A57               ldd       #$0400              1024 bytes per block (Ymodem)
L3A5A               std       <u0057              save block size
                    ldy       #u00E2              Get ptr to where data block will be (past header)
                    leay      d,y                 Calculate end of block ptr
                    sty       <u0050              Save it
                    orb       #$04                add 4 to block size for header & checksum
                    tst       <u005A              CRC mode active?
                    beq       L3A70               No, we have block size
                    orb       #$01                add 1 to block size (for 2nd CRC byte)
L3A70               std       <u0055              save true block size
                    lbsr      L3BBC               update timeout time
                    bra       L3A81               Start getting blocks?

L3A78               lbsr      L3BDA               Go update X/YModem timer
                    cmpa      #2                  Too long?
                    lbhi      L39D1               Yes, TimeOut Error
L3A81               lda       <u002B              Any data ready on modem?
                    ldb       #SS.Ready
                    os9       I$GetStt
                    bcs       L3A78               No, do again
                    cmpb      #$02                At least 2 chars?
                    blo       L3A78               No, too small to bother, do again
                    ldy       #$0002              Read 2 chars from modem
                    os9       I$Read              Read in 2 chars
                    tfr       y,d                 Move size read to D
                    abx                           Bump buffer ptr up past new data
                    addd      <u004D              Add to total # bytes gotten for this block
                    std       <u004D              Save updated counter
                    ldd       <u0053              Get current block #
                    cmpb      <u00DF+1            Compare with block # for X/Ymodem block
                    bne       L3AB6               Error, skip ahead
L3AAC               comb                          Compliment block #
                    cmpb      <u00DF+2            Match compliment in block header?
                    beq       L3AC2               Yes, header info is fine, skip ahead
                    lbra      L39E1               Wrong Block # error

* Block # error
L3AB6               decb                          Bump current block # down to previous one
                    cmpb      <u00DF+1            Is that the one in the block header?
                    lbne      L39E1               No, wrong block # error
                    inc       <u0062              ???
                    bra       L3AAC               Check compliment of block # too

* Block # & it's compliment match in X/YModem block
L3AC2               lbsr      L3BBC               Do timing update
L3AC5               lbsr      L3BDA               Do timing sleep
* MAY WANT TO INCREASE THIS
                    cmpa      #2                  2 second difference?
                    lbhi      L39D1               If more than 2 second wait, timeout error
L3ACE               lda       <u002B              Any data ready on modem?
                    ldb       #SS.Ready
                    os9       I$GetStt
                    bcs       L3AC5               No, do again
                    clra
                    tfr       d,y                 # bytes received into Y
                    lda       <u002B              Read in data from modem
                    os9       I$Read
                    bcs       L3AC5               Error reading, try again
                    tfr       y,d                 # bytes read to D
                    lbsr      L3BBC               Do timing update
                    tst       <u005A              CRC mode?
                    bne       L3AF2               Yes, go update CRC
                    lbsr      L3E3D               Go update checksum
                    bra       L3AF5

L3AF2               lbsr      L3E0F               update CRC
L3AF5               abx                           Add # bytes read to read ptr
                    addd      <u004D              Add # bytes in this I$Read to total #bytes so far
                    std       <u004D              for this block
                    cmpd      <u0055              Got all the data we need for this block?
                    blo       L3ACE               No, keep reading data
                    ldx       <u0050
                    ldd       <u0048
                    tst       <u005A
                    beq       L3B16
                    cmpd      ,x
L3B10               beq       L3B1A
                    lbra      L39D9

L3B16               cmpa      ,x
                    bra       L3B10

L3B1A               tst       <u0062
                    bne       L3B7F
                    ldd       <u0053
                    bne       L3B2F
                    lbsr      L2860
                    bcs       L3B83
                    puls      pc,y,x

L3B2F               ldx       #u00E2
                    cmpd      #$0001
                    bne       L3B79
                    ldd       <u0057
                    lbsr      L4206
                    tst       <u004C
                    beq       L3B79
                    pshs      y,x,a
                    ldx       #u009C
                    lda       <u0089
                    sta       2,x
                    ldy       #$0003
                    lda       #$01
                    os9       I$Write
                    leax      >L06BF,pc           Print 'ASCII'
                    ldy       #$0008
                    os9       I$Write
                    lda       <u0087
                    ldx       #u009C
                    sta       $02,x
                    ldy       #$0003
                    lda       #$01
                    os9       I$Write
                    puls      y,x,a
L3B79               ldd       <u0057
                    lbsr      L4191
L3B7F               clrb
L3B80               puls      pc,y,x

L3B83               inc       <u0052
                    lbsr      L3EC5
                    lbsr      L1CF7
                    ldd       #$0D07
                    lbsr      L2294
                    ldb       #$14                Size of each error message
                    lda       <u004F              Get error #
                    beq       L3BA9               0=none?
                    mul                           Calculate offset to proper error
                    leax      >L05C7,pc           Point to Download error list
                    leax      d,x                 Point to specific error we want
                    lda       #$01                Print it to the user
                    ldy       #$0014
                    os9       I$Write
L3BA9               comb
                    puls      pc,y,x

L3BAC               inc       <u005F
                    lbsr      L41EC
                    puls      pc,y,x

L3BB4               lda       #$0A
                    sta       <u0052
                    lbra      L39E9

L3BBC               tst       <u0072              Is VRN running?
                    beq       L3BCC               No, use F$Time call
                    pshs      d                   Preserve reg used
                    clra
                    ldb       <u0073              Get # seconds from VRN timer
                    std       <u0060              Save it
                    puls      pc,d                Restore D & return

L3BCC               pshs      x,d                 Preserve regs
                    ldx       #u0C99              Point to place to hold time packet
                    os9       F$Time              Get current time
                    lda       5,x                 Get seconds
                    sta       <u0060              Save it
                    puls      pc,x,d              Restore regs & return

L3BDA               pshs      x,b                 Preserve regs
                    tst       <u0072              Is VRN present?
                    beq       L3BF3               No, use Clock
                    lda       #$01
                    ldb       <u0073              Get VRN seconds counter
                    subd      <u0060              Subtract last # seconds from VRN
                    tfr       b,a                 A=# seconds between the 2
                    ldx       #$0001              1 tick to sleep
                    lbsr      L0F56               Go check for/update onscreen timer & sleep 1 tick
                    puls      pc,x,b              Restore regs & return

L3BF3               ldx       #u0C99              Point to buffer for time packet
                    os9       F$Time              Get current system time
                    lda       5,x                 Get # seconds
                    ldx       #$0001              Sleep for 1 tick
                    os9       F$Sleep
                    adda      #60                 Add 60 to seconds
                    suba      <u0060              Subtract # seconds from last check
                    cmpa      #60                 Hit 60 yet?
                    blo       L3C0D               No, restore regs & exit
                    suba      #60                 Yes, bump back down to real seconds
L3C0D               puls      pc,x,b              Restore regs & return

* Update running 16 bit CRC
* Entry: D=# bytes in block?
*        X=Ptr to current position in read buffer?
L3E0F               pshs      d,x                 Preserve regs
                    leau      d,x                 Point U to where end of block would be
                    stu       <Temp               Save in temp var
                    cmpx      <u0050              We hit end of read buffer?
                    bhs       L3E39               Yes, exit
                    leau      <L3C0F,pc           Point to CRC table
L3E24               ldb       <u0048              Get 1st byte of current 16 bit CRC
                    clra                          Preload A for 16 bit #
                    eorb      ,x+                 EOR with byte from buffer
                    lslb                          Calculate offset to get CRC word from
                    rola
                    ldd       d,u                 Get CRC word
                    eora      <u0049              Update CRC
                    std       <u0048
                    cmpx      <u0050              Hit end of read buffer yet?
                    beq       L3E39               Yes, exit
                    cmpx      <Temp               Hit end of block yet?
                    blo       L3E24               No, continue calculating CRC with next byte
L3E39               puls      d,x,pc              Restore regs & return

* 16 bit CRC table
L3C0F               fdb       $0000,$1021,$2042,$3063,$4084,$50A5,$60C6,$70E7
                    fdb       $8108,$9129,$A14A,$B16B,$C18C,$D1AD,$E1CE,$F1EF
                    fdb       $1231,$0210,$3273,$2252,$52B5,$4294,$72F7,$62D6
                    fdb       $9339,$8318,$B37B,$A35A,$D3BD,$C39C,$F3FF,$E3DE
                    fdb       $2462,$3443,$0420,$1401,$64E6,$74C7,$44A4,$5485
                    fdb       $A56A,$B54B,$8528,$9509,$E5EE,$F5CF,$C5AC,$D58D
                    fdb       $3653,$2672,$1611,$0630,$76D7,$66F6,$5695,$46B4
                    fdb       $B75B,$A77A,$9719,$8738,$F7DF,$E7FE,$D79D,$C7BC
                    fdb       $48C4,$58E5,$6886,$78A7,$0840,$1861,$2802,$3823
                    fdb       $C9CC,$D9ED,$E98E,$F9AF,$8948,$9969,$A90A,$B92B
                    fdb       $5AF5,$4AD4,$7AB7,$6A96,$1A71,$0A50,$3A33,$2A12
                    fdb       $DBFD,$CBDC,$FBBF,$EB9E,$9B79,$8B58,$BB3B,$AB1A
                    fdb       $6CA6,$7C87,$4CE4,$5CC5,$2C22,$3C03,$0C60,$1C41
                    fdb       $EDAE,$FD8F,$CDEC,$DDCD,$AD2A,$BD0B,$8D68,$9D49
                    fdb       $7E97,$6EB6,$5ED5,$4EF4,$3E13,$2E32,$1E51,$0E70
                    fdb       $FF9F,$EFBE,$DFDD,$CFFC,$BF1B,$AF3A,$9F59,$8F78
                    fdb       $9188,$81A9,$B1CA,$A1EB,$D10C,$C12D,$F14E,$E16F
                    fdb       $1080,$00A1,$30C2,$20E3,$5004,$4025,$7046,$6067
                    fdb       $83B9,$9398,$A3FB,$B3DA,$C33D,$D31C,$E37F,$F35E
                    fdb       $02B1,$1290,$22F3,$32D2,$4235,$5214,$6277,$7256
                    fdb       $B5EA,$A5CB,$95A8,$8589,$F56E,$E54F,$D52C,$C50D
                    fdb       $34E2,$24C3,$14A0,$0481,$7466,$6447,$5424,$4405
                    fdb       $A7DB,$B7FA,$8799,$97B8,$E75F,$F77E,$C71D,$D73C
                    fdb       $26D3,$36F2,$0691,$16B0,$6657,$7676,$4615,$5634
                    fdb       $D94C,$C96D,$F90E,$E92F,$99C8,$89E9,$B98A,$A9AB
                    fdb       $5844,$4865,$7806,$6827,$18C0,$08E1,$3882,$28A3
                    fdb       $CB7D,$DB5C,$EB3F,$FB1E,$8BF9,$9BD8,$ABBB,$BB9A
                    fdb       $4A75,$5A54,$6A37,$7A16,$0AF1,$1AD0,$2AB3,$3A92
                    fdb       $FD2E,$ED0F,$DD6C,$CD4D,$BDAA,$AD8B,$9DE8,$8DC9
                    fdb       $7C26,$6C07,$5C64,$4C45,$3CA2,$2C83,$1CE0,$0CC1
                    fdb       $EF1F,$FF3E,$CF5D,$DF7C,$AF9B,$BFBA,$8FD9,$9FF8
                    fdb       $6E17,$7E36,$4E55,$5E74,$2E93,$3EB2,$0ED1,$1EF0

* Calculate Checksum?
* Entry: D=# bytes in block?
*        X=Ptr to current position in read buffer?
*        Y=
L3E3D               pshs      x,d                 Preserve regs
                    leau      d,x                 Point U to where end of block would be
                    stu       <Temp               Save in temp var
                    cmpx      <u0050              Hit end of read buffer?
                    beq       L3E56               Yes, exit
                    lda       <u0048              Get current Checksum
L3E4B               adda      ,x+                 Add next byte
                    cmpx      <u0050              Hit end of buffer?
                    beq       L3E56               Yes, exit
                    cmpx      <Temp               Hit end of block?
                    blo       L3E4B               No, keep calculating Checksum
L3E56               sta       <u0048              Save new checksum
                    puls      pc,x,d              Restore & return

* Send ACK code for properly received packet
L3E7B               lda       #$06                get ACK code

* Send single byte to modem
* Entry: A=Character to send
L3E6E               sta       <u0044              Save code to write

* Send block response code (ex. ACK)
L3E5D               pshs      a,x,y               preserve regs
                    ldx       #u0044              point to 1 byte buffer for block responses
                    lda       <u002B              get path to modem
                    ldy       #1                  get length
                    os9       I$Write             send it
                    puls      a,x,y,pc            restore & return

L3E73               lda       #'C                 get code for CRC mode
                    bra       L3E6E               send it to host

L3E77               lda       #$04                get end of transmission code
                    bra       L3E6E               send it to modem

L3E7F               lda       #$15                get NAK code
                    bra       L3E6E               send it to modem

L3E83               pshs      d,x,y
                    leax      >L062B,pc           Point to '0000' packet # text with CurXY @ 8,5
                    ldy       #u1449
                    ldb       #$09
                    lbsr      L2D1E
                    ldx       #u1449
                    lbsr      L1B03
                    puls      d,x,y,pc

L3E9B               pshs      y,x,d
                    leax      >L0634,pc           Point to '0000' packet # text with CurXY @ 32,5
                    ldy       #u1439
                    ldb       #$09
                    lbsr      L2D1E
                    ldx       #u1439
                    lbsr      L1B03
                    puls      pc,y,x,d

L3EB3               pshs      y,x,d
                    ldx       #u1439
                    ldd       #$3030              '00'
                    std       $05,x
                    std       $07,x
                    lbsr      L1B03
                    puls      pc,y,x,d

L3EC5               pshs      y,x,a
                    ldx       #u1439
                    bsr       L3EEA
                    lbsr      L1B03
                    puls      pc,y,x,a

* ??? NEVER CALLED?
*         pshs  y,x,a
*         leax  >u1449,u
*         lbsr  L1B03
*         puls  pc,y,x,a

L3EDD               pshs      y,x,a
                    ldx       #u1449
                    bsr       L3EEA
                    lbsr      L1B03
                    puls      pc,y,x,a

L3EEA               pshs      b
                    ldb       #$08
L3EEE               bsr       L3EF9
                    cmpa      #$30
                    bne       L3EF7
                    decb
                    bcc       L3EEE
L3EF7               puls      pc,b

L3EF9               lda       b,x
                    inca
                    cmpa      #$39                Higher than ASCII '9'?
                    bhi       L3F03
                    sta       b,x
                    rts

L3F03               lda       #$30                Force to ASCII '0'
                    sta       b,x
                    rts

L3F08               tst       <u0046              Check for YModem batch?
                    beq       L3F1A
                    lbsr      L2A52
                    tst       <u0021
                    lbne      L3954
L3F17               lbsr      L2AA0
L3F1A               leax      >L0583,pc
                    lbsr      L1B03
                    ldx       #u009F
                    lda       #$01
                    ldy       #$0020
                    os9       I$WritLn
                    leax      >L048F,pc           Cursor OFF
                    lbsr      L1B03
                    leax      >L06C7,pc
                    lbsr      L1B03
                    lda       #$01
                    ldx       #u009F
                    os9       I$Open
                    bcc       L3F53
L3F47               tst       <u0046
                    lbeq      L3954
                    inc       <u0069
                    bra       L3F71

L3F53               sta       <u0042              Save path # to download file
                    ldx       #u00DF              Read 127 bytes into buffer
                    ldy       #$007F
                    os9       I$Read
                    bcs       L3F47               Error, deal with it
                    tfr       y,d
                    lbsr      L4206
                    lda       <u0042              Get path # to download file
                    ldx       #$0000
                    os9       I$Seek
L3F71               leax      >L0593,pc
                    lbsr      L1B03
                    leax      >L052F,pc
                    lbsr      L1B03
                    lbsr      L3E83
                    lbsr      L3E9B
                    tst       <u004C
                    beq       L3FB9
                    ldx       #u009C
                    lda       <u0089
                    sta       $02,x
                    ldy       #$0003
                    lda       #$01
                    os9       I$Write
                    leax      >L06BF,pc
                    ldy       #$0008
                    os9       I$Write
                    ldx       #u009C
                    ldb       <u0087
                    stb       $02,x
                    ldy       #$0003
                    os9       I$Write
L3FB9               clr       <u005A              Clear block check type to Checksum
                    ldd       #$0080              128 bytes per block
                    std       <u0057              Save X/YModem block size
                    addd      #$0004              Add 4 bytes for header/trailer bytes
                    std       <u0055              Save 'real' block size
                    tst       <u0046              Batch mode?
                    lbne      L40EA               Yes, skip ahead
                    ldx       #u13A9
                    lbsr      L2C72
                    tst       <u0045
                    beq       L3FE7
                    ldd       #$0400              Set block size to 1024
                    std       <u0057
                    addd      #$0004              Add 4 for header/trailer bytes
                    std       <u0055
L3FE7               ldd       #$0001              Set current block # to 1
                    std       <u0053
                    lbsr      L3EDD
                    lbsr      L3EB3
                    lbsr      L36CD
                    lbsr      L2408
                    tst       <u0046              Batch mode?
                    beq       L4007               No, skip ahead
                    ldd       <u0053              Get block #
                    cmpd      #$0001              Block #1 (info block)?
                    beq       L4017               Yes, skip ahead
L4007               lbsr      L2A15
                    lbcs      L39AA
                    cmpa      #$43
                    beq       L4017
                    lbsr      L249F
                    bra       L4031

L4017               lda       #$01                Set to CRC checking
                    sta       <u005A
                    lbsr      L249F
                    ldd       <u0057              Get block size
                    addd      #$0005              Add 5 for header/trailer (CRC)
                    std       <u0055              Save as 'real' block size
                    bra       L4041

L402A               lbsr      L2A15
                    lbcs      L39AA
L4031               cmpa      #$15                NAK (bad block)?
                    beq       L4041               Yes, bump up retry ctr & see if time to quit
                    cmpa      #$06                ACK (good block)?
                    beq       L4070               Yes, skip ahead
                    cmpa      #$18                <CTRL>-<X> to abort Xfer?
                    lbeq      L39AA               Yes, go abort
                    bra       L4007

* Send X/Ymodem block & retry counter routine
L4041               inc       <u0052              Bump up # attempts @ checksum
                    lda       <u0052              Get it
                    cmpa      #$09                Past 10?
                    lbhi      L39AA               Yes, forget it
                    cmpa      #$01                1st try?
                    bne       L405A               No, skip ahead
                    ldd       <u0053              Get current block #
                    cmpd      #$0001              First block?
                    beq       L4060               Yes, skip ahead
L405A               lbsr      L3EC5               ??? Update retry count
                    lbsr      L1CF7               Send out a tone
L4060               ldy       <u0055              Get true block size
                    lda       <u002B              Get path to modem
                    ldx       #u00DF              Get ptr to modem buffer
                    os9       I$Write             Send out the block
                    bra       L402A

* Good block sent goes here
L4070               clr       <u0052              Clear out retry attempts to 0
                    lbsr      L3EB3               Go update block # on screen
                    tst       <u005F
                    bne       L40BE
                    ldd       <u0053              Get current block #
                    addd      #$0001              Add 1 to it
                    std       <u0053              Save mew block #
                    tst       <u0045
                    beq       L409F
                    ldd       #$0400              Set block size to 1024
                    std       <u0057
* SHOULD BE ABLE TO CHANGE TO ADD #4, THEN DO CHECK AND ADD 1 MORE IF CRC
                    tst       <u005A              CRC?
                    beq       L4099               No, skip ahead
                    addd      #$0005              'Real' block size is 1029
                    bra       L409C

L4099               addd      #$0004              'Real' block size is 1028 for checksum
L409C               std       <u0055              Save real block size
L409F               lbsr      L3EDD
                    lbsr      L2408
                    tst       <u005F
                    bne       L40BE
                    lbsr      L249F
                    lda       <u002B              Get path # to modem
                    ldx       #u00DF              Point to xmit buffer
                    ldy       <u0055              Get size of buffer
                    os9       I$Write             Send next block to modem
                    lbra      L402A

L40BE               lda       <u0042              Get path # to upload file
                    os9       I$Close             Close it
                    clr       <u005F
                    tst       <u0046              Batch xfer?
                    beq       L40D8               No, we're done
                    lbsr      L3E77
                    lbsr      L2A15
                    lbcs      L39AA
                    lbra      L3F17

L40D8               lbsr      L3E77
                    lbsr      L2A15
                    lbcs      L39AA
                    cmpa      #$06
                    bne       L40D8
                    lbra      L3947

L40EA               lbsr      L2A15
                    lbcs      L39AA
                    cmpa      #'C                 CRC mode requested?
                    bne       L40EA               No, go back
                    inc       <u005A              Set mode to CRC
                    ldd       <u0057              Get block size
                    addd      #$0005              'Real' block size
                    std       <u0055              Save 'Raw' block size
                    ldd       #$0000              Set current block # to 0
                    std       <u0053
                    lbsr      L2408
                    lbsr      L249F
                    ldx       #u00DF
                    ldy       #u13A9
                    ldb       #$86
                    lbsr      L2D1E
                    tst       <u0069
                    bne       L412F
                    ldd       #$0001              Set block # to 1
                    std       <u0053
                    ldd       #$0400              Set block size to 1024
                    std       <u0057
                    lbsr      L2408
                    lbsr      L249F
L412F               lda       <u002B              Get path # to modem
                    ldx       #u13A9
                    ldy       <u0055              Get 'raw' block size
                    os9       I$Write
L413D               lbsr      L2A15
                    lbcs      L39AA
                    cmpa      #$06
                    beq       L415C
                    cmpa      #$15
                    bne       L413D
                    inc       <u0052              Update retry counter
                    lda       <u0052
                    cmpa      #$09
                    lbhi      L39AA
                    lbsr      L3EC5
                    lbsr      L1CF7
                    bra       L412F

L415C               tst       <u0069
                    lbne      L3954
                    ldd       #$0001              Set block # to 1
                    std       <u0053
                    lbsr      L3EDD
                    ldd       <u0057              Get block size
                    addd      #$0005              New size for CRC header/trailer
                    std       <u0055              Save 'raw' block size
                    lbsr      L2A15
                    lbcs      L39AA
                    cmpa      #'C                 CRC mode requested?
                    bne       L415C
                    lda       <u002B              Get path to modem
                    ldx       #u00DF
                    ldy       <u0055              Get raw block size
                    os9       I$Write             Send to modem
                    lbra      L402A

L4191               pshs      y,d
                    ldd       <u0002              Get ptr to max address of receive buffer allowed
                    subd      ,s
                    cmpd      <u0006              Compare with end of current receive buffer
                    bhs       L419E
                    bsr       L41EC
L419E               ldy       <u0006
                    tst       <u004C
                    bne       L41BC
L41A6               ldd       ,x++
                    std       ,y++
                    ldd       ,s
                    subd      #$0002
                    std       ,s
                    bhi       L41A6
                    beq       L41B7
                    leay      -1,y
L41B7               sty       <u0006
                    puls      pc,y,d

L41BC               ldd       ,x++
                    cmpa      #$1F
                    bhi       L41CA
                    cmpa      #$0A
                    beq       L41CC
                    cmpa      #$1A
                    beq       L41CC
L41CA               sta       ,y+
L41CC               cmpb      #$1F
                    bhi       L41D8
                    cmpb      #$0A
                    beq       L41DA
                    cmpb      #$1A
                    beq       L41DA
L41D8               stb       ,y+
L41DA               ldd       ,s
                    subd      #$0002
                    std       ,s
                    bhi       L41BC
                    beq       L41E7
                    leay      -1,y
L41E7               sty       <u0006
                    puls      pc,y,d

L41EC               pshs      x
                    ldx       <u0004              Get ptr to start address of receive buffer
                    ldd       <u0006              Get ptr to current end of receive buffer
                    subd      <u0004              Calculate current size of receive buffer
                    tfr       d,y                 Keep copy in Y
                    lda       <u0042              Get path to download file
                    cmpa      #$FF                If none, skip ahead
                    beq       L4200
                    os9       I$Write             Otherwise, write buffer to disk
L4200               ldd       <u0004              Reset end of current buffer ptr to beginning
                    std       <u0006
                    puls      pc,x

L4206               pshs      x,d
                    tst       >u0CAD
                    beq       L422E
                    inc       <u004C
                    andb      #$7F
L4213               lda       ,x+
                    bmi       L422E
                    beq       L4229
                    cmpa      #$1F
                    bhi       L4229
                    cmpa      #$0D
                    beq       L4229
                    cmpa      #$0A
                    beq       L4229
                    cmpa      #$09
                    bne       L422E
L4229               decb
                    bne       L4213
                    puls      pc,x,d

L422E               clr       <u004C
                    puls      pc,x,d

* ASCII file download
L4233               ldd       #$1504
                    std       >u0C8F
                    ldd       #$2507
                    std       >u0C91
                    lbsr      L1C81
                    leax      >L048F,pc           Cursor OFF
                    lbsr      L1B03
                    tst       >u0CA0
                    lbeq      L444C
                    leax      >L08CF,pc           'File Capture System'
                    lbsr      L1B03
                    leax      >L051C,pc           'Break aborts'
                    lbsr      L1B03
                    leax      >L048B,pc           Cursor ON
                    lbsr      L1B03
                    tst       <u0025              Does an ASCII receive file exist?
                    beq       L42BE               No, continue
                    leax      >L0925,pc           Print a double quote
                    lbsr      L1B03
                    ldx       #u00BF
                    lda       #$01
                    ldy       <u001E
                    leay      -1,y
                    os9       I$Write             Write filename
                    leax      >L08E8,pc           'is already open'
                    lbsr      L1B03
* Loop for response to file already open
L428A               lbsr      L2AC5
                    cmpa      #'Y
                    beq       L42A3
                    cmpa      #'N
                    lbeq      L4332
                    cmpa      #$05                <CTRL>-<E>?
                    lbeq      L4332
                    cmpa      #C$CR
                    bne       L428A               Illegal responses; ignore & try again

L42A3               lbsr      L43CA
                    lbsr      L44E1
                    lda       <u002A              Get path to file
                    os9       I$Close             Close it
                    bcs       L433B
                    clr       <u0025              Clear flag that a receive file is open
                    clr       <u0026              Clear flag that receive buffer is open
                    lbsr      L237E
                    bra       L4332

L42BE               tst       <u0020
                    bne       L42E7
                    leax      >L055F,pc           'File:'
                    lbsr      L1B03
                    ldb       #$1E                Max file size allowed?
                    lbsr      L1B61               Go get filename from user
                    tst       <u0021
                    bne       L4332
                    ldd       <u001C
                    std       <u001E
                    ldx       #u060E
                    ldy       #u00BF
                    ldb       #$20
                    lbsr      L2D1E
L42E7               ldx       #u00BF
                    lda       ,x
                    cmpa      #$0D                Carriage return?
                    beq       L4332
                    ldd       #WRITE.*256+UPDAT.  Access mode=Write, attributes=Read & Write
                    os9       I$Create            Create the file
                    bcc       L4318
                    cmpb      #E$CEF              File aready exists error?
                    bne       L433B
                    leax      >L092B,pc           Append or overwrite message
                    lbsr      L1B03
L4305               lbsr      L2AC5
                    cmpa      #'A                 Append?
                    beq       L4363
                    cmpa      #'O                 Overwrite?
                    beq       L438A
                    cmpa      #C$CR               CR?
                    beq       L4332
                    bra       L4305

L4318               sta       <u002A              Save path # to receive file
L431B               inc       <u0025              Flag that receive file exists
                    tst       <u0024
                    bne       L4332
                    inc       <u0026              Flag that receive buffer is open
                    lbsr      L237E
                    lda       <u0002              Get MSB of max address for receive buffer
                    suba      <u0006              Calc size to end of buffer (in 256 byte blocks)
                    sta       <u0008              Save it
                    lbsr      L44FF
L4332               clr       <u0024
                    lbsr      L1CDE
                    lbra      L0C5E

L433B               lda       #$07
                    lbsr      L1F0B
                    pshs      b
                    ldd       #$0D02
                    lbsr      L2294
                    leax      >L048F,pc           Cursor OFF
                    lbsr      L1B03
                    puls      b
                    os9       F$PErr              Print error message
                    ldx       #$003C
                    lbsr      L0F56
                    leax      >L048B,pc           Cursor ON
                    lbsr      L1B03
                    bra       L4332

L4363               ldx       #u00BF
                    lda       #UPDAT.
                    os9       I$Open
                    bcc       L4379
                    os9       F$PErr
                    ldx       #$003C
                    lbsr      L0F56
                    bra       L433B

L4379               sta       <u002A              Save path # to receive file
* NOTE: TOOK OUT PSHS U
                    ldb       #SS.Size            Get size of file to append to
                    os9       I$GetStt
                    os9       I$Seek              Seek to end of file
* NOTE: TOOK OUT PULS U
                    bra       L431B

L438A               ldx       #u00BF              Delete file (to overwrite)
                    os9       I$Delete
                    lbra      L42E7

L4394               pshs      y,x,d
                    ldx       #u070D
                    ldb       <u0C89              Get LSB of size converted output text buffer
                    ldy       <u0006              Get ptr to end of current receive buffer
L43A4               lda       ,x+
                    cmpa      #$0A
                    beq       L43AF
                    sta       ,y+
                    sty       <u0006
L43AF               decb
                    cmpy      <u0002
                    bcs       L43BA
                    bsr       L43CA
                    ldy       <u0006
L43BA               tstb
                    bne       L43A4
                    lda       <u0002
                    suba      <u0006
                    cmpa      <u0008
                    beq       L43C8
                    lbsr      L44FF
L43C8               puls      pc,y,x,d

L43CA               pshs      y,x,d
                    ldd       <u0006
                    std       <u0009
                    tst       <u0025
                    beq       L43FD
                    lda       >u0CB0              Get pause on char
                    beq       L43E1               None, wing it & hope we don't overflow
                    sta       <u0044              Save it & send to modem
                    lbsr      L3E5D
L43E1               ldd       <u0006
                    subd      <u0004
                    tfr       d,y
                    ldx       #u16B9
                    lda       <u002A              Get path # to receive buffer file
                    os9       I$Write             Save
                    lda       >u0CAF              Get pause off char
                    beq       L43FD               None, skip ahead
                    sta       <u0044              Save & send to host
                    lbsr      L3E5D
L43FD               ldd       <u0004              Reset end of receive buffer ptr to start
                    std       <u0006
                    puls      pc,y,x,d

* Parameter parsing?
L4403               pshs      y,x,d
                    clr       <u0024
                    ldx       ,u
L440A               lda       ,x+
                    cmpa      #C$CR
                    beq       L4447
                    cmpa      #'f
                    beq       L4418
                    cmpa      #'F
                    bne       L440A
L4418               lda       -$02,x
                    cmpa      #C$SPAC
                    beq       L4425
                    cmpa      #'-
                    bne       L440A
                    inc       <u0024
L4425               lda       ,x+
                    cmpa      #'=
                    bne       L440A
                    ldy       #u00BF
                    clrb
L4430               lda       ,x+
                    sta       ,y+
                    incb
                    cmpa      #C$CR
                    beq       L443D
                    cmpb      #C$SPAC
                    blo       L4430
L443D               clra
                    std       <u001E
                    inc       <u0020
                    lbsr      L4233
L4447               clr       <u0020
                    puls      pc,y,x,d

L444C               leax      >L0910,pc           'Send ASCII file'
                    lbsr      L1B03
                    leax      >L048B,pc           Cursor ON
                    lbsr      L1B03
                    leax      >L055F,pc           'File:'
                    lbsr      L1B03
                    ldb       #$1E
                    lbsr      L1B61
                    tst       <u0021
                    bne       L44CF
                    ldx       #u060E
                    ldy       #u13A9
                    ldb       #$20
                    lbsr      L2D1E
                    ldx       #u13A9
                    lda       ,x
                    cmpa      #C$CR
                    beq       L44CF
                    lda       #READ.
                    os9       I$Open
                    bcs       L44CF
                    sta       <u002C              Save path # to file xmit in ASCII
                    lda       #$01
                    sta       <u0023
                    lbsr      L1CDE
L4494               lda       <u002C              Get path # to send file
                    ldx       #u13A9              Point to send buffer
                    ldy       #255                Max 255 bytes/read
                    os9       I$ReadLn            Get block from file
                    bcs       L44C3
                    lda       <u002B              Get path # to modem
                    ldx       #u13A9              Send data to modem
                    os9       I$WritLn
                    lbsr      L13C2
                    bcc       L44D4
                    lbra      L0C5E

L44B6               ldx       #$0004
                    lbsr      L0F56
                    lda       <u002B              Get path to modem
                    ldb       #SS.Ready
                    os9       I$GetStt            Any data ready on the modem?
                    lbcc      L0C5E               Possibly, return to main read loop
                    bra       L4494               No, go get more data from disk file

L44C3               lda       <u002C              Close send file
                    os9       I$Close
                    clr       <u0023              Clear 'Sending ASCII file' flag
                    lbra      L0C5E

L44CF               lbsr      L1CDE
                    lbra      L0C5E

L44D4               lbsr      L2AC5
                    cmpa      #$03
                    beq       L44C3
                    cmpa      #$05
                    beq       L44C3
                    lbra      L0C5E

L44E1               pshs      y,x,d
                    ldx       #u13A9
                    ldd       #$026A              CurXY @ 74,0
                    std       ,x
                    ldd       #$2020              +3 spaces
                    std       $02,x
                    std       $04,x
                    lda       <u003E              Get path # to status window
                    ldy       #$0006
                    os9       I$Write
                    puls      pc,y,x,d

L44FF               pshs      y,x,d
                    sta       <u0008
                    lsra
                    lsra
                    inca
                    ldx       #u13A9
                    clrb
L450B               cmpa      #10
                    blo       L4514
                    suba      #$0A
                    incb
                    bra       L450B

L4514               addb      #$30                Convert to ASCII numeric
                    adda      #$30
                    cmpb      #$30
                    bne       L451E
                    ldb       #C$SPAC
L451E               stb       $03,x
                    sta       $04,x
                    ldd       #$026A              CurXY @ 74,0
                    std       ,x
                    lda       #$20
                    sta       $02,x
                    lda       #$4B
                    sta       $05,x
                    lda       <u003E
                    ldy       #$0006
                    os9       I$Write
                    puls      pc,y,x,d

L453B               pshs      y,x,d
                    ldx       #u070D
                    ldb       <u0C89              Get # bytes in modem buffer
                    ldy       <u000F
L4548               lda       ,x+
                    sta       ,y+
                    decb
                    cmpy      <u000B
                    blo       L4555
                    ldy       <u000D
L4555               tstb
                    bne       L4548
                    sty       <u000F
                    puls      pc,y,x,d

* Scan filename memory for filename (used by file xfer's)
L455D               pshs      d,x,y
                    ldx       <u000F              get pointer to ???
L4561               lda       ,-x                 get a byte
                    cmpa      #$2E                period?
                    beq       L4577               yes, skip ahead
L4567               cmpx      <u000D              end of buffer?
                    bne       L456D               no, check
                    ldx       <u000B
L456D               cmpx      <u000F
                    bne       L4561
                    clr       <u009B              Clear filename present flag
                    puls      d,x,y,pc
*
L4577               lda       1,x                 get character again
                    cmpa      #'.
                    blo       L4567
                    lda       -1,x
                    cmpa      #'.
                    blo       L4567
L4583               lda       ,-x
                    cmpa      #'0
                    blo       L458F
                    cmpx      <u000F
                    beq       L456D
                    bra       L4583

L458F               lda       1,x
                    cmpa      #'A
                    blo       L456D
                    ldb       #$1F
                    leax      1,x
                    ldy       #u009F
L459D               lda       ,x+
L459F               cmpa      #'.
                    blo       L45B8
                    sta       ,y+
                    decb
                    beq       L45B8
                    cmpx      <u000B
                    beq       L45B2
                    cmpx      <u000F              ??? Hit end of name buffer?
                    bne       L459D               No, keep going

L45B8               lda       #C$CR               Change to CR
                    sta       ,y
                    inc       <u009B              Inc size of filename counter
                    puls      d,x,y,pc            Restore & return

L45B2               lda       ,x
                    ldx       <u000D
                    bra       L459F

                    emod
eom                 equ       *
                    end

