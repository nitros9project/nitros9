                    IFNE      PIPE.D-1

PIPE.D              SET       1

********************************************************************
* PipeDefs - Pipe File Manager Definitions
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          1988/12/03  Chris J. Burke
* Coded from new PIPEMAN comments.

                    NAM       PipeDefs
                    TTL       Pipe                File Manager Definitions

*
*   IOMan equates duplicated for PipeMan use
*

NPATHS              SET       16                  ;Maximum local paths per task -- must match IOMan
NameMax             SET       29                  ;Maximum length of a file name

*
*   Device Driver Static Storage Layout
*
                    ORG       V.User
V.List              RMB       2                   ;Pointer to 1st pipe's pipe buffer
PManMem             EQU       .                   ;Device driver memory (drive table equivalent)

*
*   Pipe Buffer Data Structure
*
                    ORG       0
PP.PD               RMB       2                   ;Pointer to shared path descriptor
PP.Next             RMB       2                   ;Pointer to next pipe buffer in system map
PP.Prev             RMB       2                   ;Pointer to previous pipe buffer in system map
PP.Rsrv             RMB       2                   ;Reserved
PP.Data             EQU       .                   ;Data buffer begins at this offset

*
*   Unique Path Descriptor Variables
*
                    ORG       PD.FST
*** PP.Read must have bit 4 clear; PP.Writ must be PP.Read XOR 4
PD.Read             EQU       .
PD.RPID             RMB       1                   ;Process ID of reader waiting on signal
PD.RCT              RMB       1                   ;Number of blocked readers
PD.RSIG             RMB       1                   ;Signal to send reader
PD.REOR             RMB       1                   ;Read EOR character
PD.Writ             EQU       .
PD.WPID             RMB       1                   ;Process ID of writer waiting on signal
PD.WCT              RMB       1                   ;Number of blocked writers
PD.WSIG             RMB       1                   ;Signal to send writer
PD.WEOR             RMB       1                   ;Write EOR character (dummy)
*** End of special section
PD.End              RMB       2                   ;Pointer to end of pipe buffer
PD.NxtI             RMB       2                   ;Next in pointer
PD.NxtO             RMB       2                   ;Next out pointer
PD.RFlg             RMB       1                   ;"Ready" flag
PD.Wrtn             RMB       1                   ;"Written" flag
PD.BCnt             RMB       2                   ;# queue elements currently bufered
PD.Own              RMB       1                   ;Process ID of pipe original creator
PD.Keep             RMB       1                   ;Non-zero if pipe has been kept open artificailly
PD.QSiz             RMB       2                   ;Max. elements in queue (copied from OPT section)

*
*   Path descriptor option section
*
*   Note that PD.Name overlaps with the last byte of PD.ECnt.
*   PD.ECnt is copied to PD.QSiz as part of OPEN or CREATE,
*   to make room for the pipe name.
*
                    ORG       (PD.OPT+1)
PD.ESiz             RMB       1                   ;Size of each queue element
PD.ECnt             RMB       2                   ;Max. elements in queue (initial position)
                    IFGT      Level-1
                    ORG       (PD.OPT+3)
PD.Name             RMB       NameMax
                    ENDC

*
*   Device Descriptor definitions
*
IT.PDC              EQU       $12                 ;Pipe device class (like IT.DTP, IT.DVC)
                    ORG       IT.PDC
                    RMB       1                   ;Leave room for device class
IT.ESiz             RMB       1                   ;Size of each queue element
IT.ECnt             RMB       2                   ;Max. elements in queue (initial position)

*   End of pipe.d

                    ENDC

