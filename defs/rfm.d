********************************************************************
* rfm.d - Remote File Manager Definitions
*
*          2010/02/20  AAW
* initial version

                    NAM       rfm.d
                    TTL       Remote              File Manager Definitions

DW.Create           EQU       $01
DW.Open             EQU       $02
DW.MakDir           EQU       $03
DW.ChgDir           EQU       $04
DW.Delete           EQU       $05
DW.Seek             EQU       $06
DW.Read             EQU       $07
DW.Write            EQU       $08
DW.ReadLn           EQU       $09
DW.WritLn           EQU       $0A
DW.GetStt           EQU       $0B
DW.SetStt           EQU       $0C
DW.Close            EQU       $0D

DWSS.GetDir         EQU       $10

********************
* RFM Static Storage

                    ORG       V.USER
V.DWCMD             RMB       1                   last DW command sent
V.BUF               RMB       2                   pointer to buffer
V.PATHNAME          RMB       2                   pointer to pathname
V.PATHNAMELEN       RMB       2                   pathname length
V.FILESIZE          RMB       4                   file size
V.MODTIME           RMB       6                   modified time
V.FATTR             RMB       2                   modified time
V.RFM               EQU       .                   Total RFM manager static overhead

