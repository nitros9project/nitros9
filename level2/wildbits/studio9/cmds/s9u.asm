* s9u: the "Update via DriveWire4 Internet" overlay, ported from the Um3U overlay of
* UltiMusE III v10.11.4E (disassembled; routine names are reverse-engineered).
* No C startup: start lbra's to OverlayEntry, a C function called by s9 (shared data in
* Y/DP) with the menu key as its int argument; 'u' runs UpdateViaDW4. It calls back into
* s9 through the UmeData_p* vectors; OpenMsgWindow/CloseMsgWindow print the window codes
* $C6/$C7 through the <$14/<$16 formats.
* Flow: UpdateViaDW4 asks permission; CheckForUpdates opens /N (the DW4 virtual serial
* port) and sends "dw ser lis <url>/s9.upd". The reply (4 version bytes, cmd-file count,
* CR-separated names, sys-file count, names) is parsed into $0CD4 (latest version),
* $0ED8/$0EDA (counts) and the 18-byte-per-entry name table at $0EDC (name at +3). The
* version is scored against the built-in 10.11.4E; the user may force. DownloadFiles then,
* per file, sprintf's the URL into cmdBuf $0CD8, CreatFile's /dd/cmds/<name> (perms $3F)
* or /dd/sys/<name> ($1B), DwFetchToFile streams the reply into it and SetFileAttr
* rewrites the FD attribute byte. Finally it warns that a restart is needed and sets
* UmeData_broke ($0076) = 2 (quit request).
* DW transfer (DwFetchToBuf/DwFetchToFile): SetIntercept(HupSigHandler) - S$HUP from the
* DW driver marks the transfer done ($0CCE=1), any other signal aborts (2); SetRawMode
* clears PD option bytes 1..17; the command is written; a first reply byte 'F' = command
* failed, 'O' = OK line skipped to CR; then SS.Ready polling (E$NotRdy -> sleep 1 tick)
* reads chunks into readBuf $0DD8 ($0CCC = count) until 0 bytes or the HUP signal.
* C runtime: StrLen, StrNCpy, MemZero, MulInt16, CreatFile, OpenPath, ClosePath, ReadPath,
* WritePath, SleepTicks, SetIntercept + IcptTrampoline, Os9Call, SetErrno/CarryToErrno
* (errno at $034F,y). Unreferenced library code (readln, writeln, send, tsleep) remains
* as fcb bytes after a21@/b22@/a23@; the trailer after CarryToErrno is the original
* data-initialization image (with the "Hi, Lester!" strings).
* Data addresses are mostly left numeric (<$xx = direct page). fcb/fcc lines inside
* code are code bytes kept as data.

                    nam       s9u
                    ttl       s9u (disassembly)

                  IFP1
                    use       defsfile
                  ENDC
UME_SCOPE_S9U                  equ       1
                    use       equates.asm

tylg                set       $11
atrv                set       $81
size                equ       $13C6

                    mod       eom,name,tylg,atrv,start,size
name                fcs       /s9u/
                    fcb       $07
start               equ       *
                    lbra      OverlayEntry
                    fcb       $39,$0D,$00
* HupSigHandler: the C signal handler installed by SetIntercept, kept as fcb/fcs bytes.
* Signal 4 (S$HUP = S$Window, sent by the DriveWire /N driver when the server closes the
* channel) sets $0CCE = 1 and returns 1; any other signal sets $0CCE = 2 and returns 0.
HupSigHandler       fcb       $34,$40,$EC,$64,$10,$83,$00,$04
                    fcb       $26,$0B,$CC,$00,$01,$FD,$0C,$CE
                    fcb       $CC,$00,$01,$35,$C0,$CC,$00,$02
                    fcb       $FD,$0C,$CE
                    fcs       /O_5@/
                    fcb       $35,$C0
* OverlayEntry: reached by start's lbra; C function, the menu key as int at 6,s. If dp $51
* (DriveWire /N available, set by s9 after opening /N) is 0: msgNeedDW4 in a message
* window, clear dp $50 and return 0.
OverlayEntry        pshs      u
                    leas      -1,s
                    ldb       <UmeData_reserved_0051
                    bne       a1@
                    ldd       #WinStylePaper3D    the paper 3D box
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$000A
                    pshs      a,b
                    ldd       #$0032
                    pshs      a,b
                    ldd       #$00B7
                    pshs      a,b
                    ldd       #$000F
                    pshs      a,b
                    lbsr      OpenMsgWindow
                    leas      12,s
                    leax      >msgNeedDW4,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    jsr       [>UmeData_phit]
                    lbsr      CloseMsgWindow
                    clra
                    clrb
                    stb       <UmeData_reserved_0050
                    bra       e1@
* a1@: the one-case switch of OverlayEntry: key sign-extended into X, compared with 'u'.
a1@                 ldb       6,s
                    sex
                    tfr       d,x
                    bra       c1@
b1@                 bsr       UpdateViaDW4
                    bra       d1@
c1@                 cmpx      #$0075
                    beq       b1@
d1@                 ldb       >UmeData_reserved_01A6
                    stb       ,s
e1@                 leas      1,s
                    puls      u,pc
* UpdateViaDW4: asks msgAskUpdate (yes/no); on yes runs CheckForUpdates and, when it
* returns nonzero, DownloadFiles. $208-byte frame: 2,s file index, $106,s path buffer,
* $207,s CheckForUpdates' result.
UpdateViaDW4        pshs      u
                    leas      >-$0208,s
                    leax      >msgAskUpdate,pcr
                    pshs      x
                    jsr       [>UmeData_pyesno]
                    leas      2,s
                    beq       a2@
                    lbsr      CheckForUpdates
                    stb       >$0207,s
                    bne       DownloadFiles
a2@                 leas      >$0208,s
                    puls      u,pc
* DownloadFiles: OpenMsgWindow(18,183,42,22,1,WinStylePaper3D), msgDeletingOld and
* fmtInstallingCmds with the cmd-file count $0ED8, then CmdFileLoop and SysFileLoop.
DownloadFiles       ldd       #WinStylePaper3D    the paper 3D box
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0016
                    pshs      a,b
                    ldd       #$002A
                    pshs      a,b
                    ldd       #$00B7
                    pshs      a,b
                    ldd       #$0012
                    pshs      a,b
                    lbsr      OpenMsgWindow
                    leas      12,s
                    leax      >msgDeletingOld,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    jsr       [>UmeData_pflush]
                    ldd       >UmeData_reserved_0ED8
                    pshs      a,b
                    leax      >fmtInstallingCmds,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    jsr       [>UmeData_pflush]
                    clra
                    clrb
                    lbra      CmdFileLoop
* FetchCmdFile: body of CmdFileLoop for file i (2,s): name = $0EDC + i*18 + 3; sprintf
* fmtDwListCmdUrl into cmdBuf $0CD8 and pathCmdsFile into the path buffer; CreatFile(path,
* $3F) -> $0CD2, DwFetchToFile; on failure fmtErrUpdatingCmd.
FetchCmdFile        ldd       2,s
                    pshs      a,b
                    ldd       #$0012
                    lbsr      MulInt16
                    ldx       #$0EDC
                    leax      d,x
                    tfr       x,d
                    addd      #$0003
                    pshs      a,b
                    leax      >fmtDownloadingCmd,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    jsr       [>UmeData_pflush]
                    ldd       #$0100
                    pshs      a,b
                    ldx       #$0CD8
                    pshs      x
                    lbsr      MemZero
                    leas      4,s
                    ldd       #$0100
                    pshs      a,b
                    leax      >$0108,s
                    pshs      x
                    lbsr      MemZero
                    leas      4,s
                    ldd       2,s
                    pshs      a,b
                    ldd       #$0012
                    lbsr      MulInt16
                    ldx       #$0EDC
                    leax      d,x
                    tfr       x,d
                    addd      #$0003
                    pshs      a,b
                    leax      >fmtDwListCmdUrl,pcr
                    pshs      x
                    ldx       #$0CD8
                    pshs      x
                    jsr       [>UmeData_psprintf]
                    leas      6,s
                    ldd       2,s
                    pshs      a,b
                    ldd       #$0012
                    lbsr      MulInt16
                    ldx       #$0EDC
                    leax      d,x
                    tfr       x,d
                    addd      #$0003
                    pshs      a,b
                    leax      >pathCmdsFile,pcr
                    pshs      x
                    leax      >$010A,s
                    pshs      x
                    jsr       [>UmeData_psprintf]
                    leas      6,s
                    ldd       #$003F
                    pshs      a,b
                    leax      >$0108,s
                    pshs      x
                    lbsr      CreatFile
                    leas      4,s
                    std       >UmeData_reserved_0CD2
                    lbsr      DwFetchToFile
                    bne       CmdFileFetched
                    leax      >$0106,s
                    pshs      x
                    leax      >fmtErrUpdatingCmd,pcr
                    lbra      CmdFileNext
* CmdFileFetched: Success half of FetchCmdFile: prints fmtCmdDownloaded and msgSetAttrsCmd, rebuilds the /dd/cmds path (pathCmdsFile2), SetFileAttr(path,$3F), then fmtAttrsSetCmd.
CmdFileFetched      ldd       2,s
                    pshs      a,b
                    ldd       #$0012
                    lbsr      MulInt16
                    ldx       #$0EDC
                    leax      d,x
                    tfr       x,d
                    addd      #$0003
                    pshs      a,b
                    leax      >fmtCmdDownloaded,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    leax      >msgSetAttrsCmd,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    jsr       [>UmeData_pflush]
                    ldd       #$0100
                    pshs      a,b
                    leax      >$0108,s
                    pshs      x
                    lbsr      MemZero
                    leas      4,s
                    ldd       2,s
                    pshs      a,b
                    ldd       #$0012
                    lbsr      MulInt16
                    ldx       #$0EDC
                    leax      d,x
                    tfr       x,d
                    addd      #$0003
                    pshs      a,b
                    leax      >pathCmdsFile2,pcr
                    pshs      x
                    leax      >$010A,s
                    pshs      x
                    jsr       [>UmeData_psprintf]
                    leas      6,s
                    ldd       #$003F
                    pshs      a,b
                    leax      >$0108,s
                    pshs      x
                    lbsr      SetFileAttr
                    leas      4,s
                    leax      >$0106,s
                    pshs      x
                    leax      >fmtAttrsSetCmd,pcr
* CmdFileNext: shared tail of FetchCmdFile: printf(fmt, path), flush, i++ into CmdFileLoop.
CmdFileNext         pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    jsr       [>UmeData_pflush]
                    ldd       2,s
                    addd      #$0001
* CmdFileLoop: Loop head: while i < cmd-file count ($0ED8) run FetchCmdFile; then prints fmtCmdsDoneSysCount with the sys-file count $0EDA and enters SysFileLoop with i = nCmd.
CmdFileLoop         std       2,s
                    ldd       2,s
                    cmpd      >UmeData_reserved_0ED8
                    lblt      FetchCmdFile
                    ldd       >UmeData_reserved_0EDA
                    pshs      a,b
                    leax      >fmtCmdsDoneSysCount,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    ldd       >UmeData_reserved_0ED8
                    lbra      SysFileLoop
* FetchSysFile: Body of SysFileLoop: same as FetchCmdFile but URL fmtDwListSysUrl (note the double slash), target pathSysFile '/dd/sys/%s' and CreatFile perms $1B.
FetchSysFile        ldd       2,s
                    pshs      a,b
                    ldd       #$0012
                    lbsr      MulInt16
                    ldx       #$0EDC
                    leax      d,x
                    tfr       x,d
                    addd      #$0003
                    pshs      a,b
                    leax      >fmtDownloadingSys,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    jsr       [>UmeData_pflush]
                    ldd       #$0100
                    pshs      a,b
                    ldx       #$0CD8
                    pshs      x
                    lbsr      MemZero
                    leas      4,s
                    ldd       #$0100
                    pshs      a,b
                    leax      >$0108,s
                    pshs      x
                    lbsr      MemZero
                    leas      4,s
                    ldd       2,s
                    pshs      a,b
                    ldd       #$0012
                    lbsr      MulInt16
                    ldx       #$0EDC
                    leax      d,x
                    tfr       x,d
                    addd      #$0003
                    pshs      a,b
                    leax      >fmtDwListSysUrl,pcr
                    pshs      x
                    ldx       #$0CD8
                    pshs      x
                    jsr       [>UmeData_psprintf]
                    leas      6,s
                    ldd       2,s
                    pshs      a,b
                    ldd       #$0012
                    lbsr      MulInt16
                    ldx       #$0EDC
                    leax      d,x
                    tfr       x,d
                    addd      #$0003
                    pshs      a,b
                    leax      >pathSysFile,pcr
                    pshs      x
                    leax      >$010A,s
                    pshs      x
                    jsr       [>UmeData_psprintf]
                    leas      6,s
                    ldd       #$001B
                    pshs      a,b
                    leax      >$0108,s
                    pshs      x
                    lbsr      CreatFile
                    leas      4,s
                    std       >UmeData_reserved_0CD2
                    lbsr      DwFetchToFile
                    bne       SysFileFetched
                    leax      >$0106,s
                    pshs      x
                    leax      >fmtErrUpdatingSys,pcr
                    lbra      SysFileNext
* SysFileFetched: Success half of FetchSysFile: fmtSysDownloaded, msgSetAttrsSys, SetFileAttr(path,$1B), fmtAttrsSetSys.
SysFileFetched      ldd       2,s
                    pshs      a,b
                    ldd       #$0012
                    lbsr      MulInt16
                    ldx       #$0EDC
                    leax      d,x
                    tfr       x,d
                    addd      #$0003
                    pshs      a,b
                    leax      >fmtSysDownloaded,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    leax      >msgSetAttrsSys,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    jsr       [>UmeData_pflush]
                    ldd       #$0100
                    pshs      a,b
                    leax      >$0108,s
                    pshs      x
                    lbsr      MemZero
                    leas      4,s
                    ldd       2,s
                    pshs      a,b
                    ldd       #$0012
                    lbsr      MulInt16
                    ldx       #$0EDC
                    leax      d,x
                    tfr       x,d
                    addd      #$0003
                    pshs      a,b
                    leax      >pathSysFile2,pcr
                    pshs      x
                    leax      >$010A,s
                    pshs      x
                    jsr       [>UmeData_psprintf]
                    leas      6,s
                    ldd       #$001B
                    pshs      a,b
                    leax      >$0108,s
                    pshs      x
                    lbsr      SetFileAttr
                    leas      4,s
                    leax      >$0106,s
                    pshs      x
                    leax      >fmtAttrsSetSys,pcr
* SysFileNext: Shared tail of FetchSysFile: printf(fmt, path), flush, i++ into SysFileLoop.
SysFileNext         pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    jsr       [>UmeData_pflush]
                    ldd       2,s
                    addd      #$0001
* SysFileLoop: while i < nCmd+nSys run FetchSysFile; then msgAllDownloaded and the three
* restart warnings, wait for ENTER/click, putchar(13), CloseMsgWindow, UmeData_broke = 2.
SysFileLoop         std       2,s
                    ldd       >UmeData_reserved_0EDA
                    addd      >UmeData_reserved_0ED8
                    cmpd      2,s
                    lbgt      FetchSysFile
                    leax      >msgAllDownloaded,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    leax      >msgRestartWarn1,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    leax      >msgRestartWarn2,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    leax      >msgRestartWarn3,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    jsr       [>UmeData_pflush]
                    jsr       [>UmeData_phit]
                    ldd       #$000D
                    pshs      a,b
                    jsr       [>UmeData_pputchar]
                    leas      2,s
                    lbsr      CloseMsgWindow
                    ldd       #$0002
                    std       >UmeData_broke
                    leas      >$0208,s
                    puls      u,pc
* CheckForUpdates: OpenMsgWindow(18,183,42,17,1,WinStylePaper3D), msgCheckingServer,
* StrNCpy strDwListUpdUrl into cmdBuf $0CD8 (74 bytes), DwFetchToBuf; on failure
* msgServerConnErr + wait and return 0. Parses the manifest from readBuf $0DD8, scores the
* version and returns 1 when the user accepts the download.
* Frame: ,s readBuf index, 2,s entry j, 4,s name offset k, 6,s version score, $18,s flag.
CheckForUpdates     pshs      u
                    leas      <-$19,s
                    clra
                    clrb
                    stb       <$18,s
                    ldd       #WinStylePaper3D    the paper 3D box
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0011
                    pshs      a,b
                    ldd       #$002A
                    pshs      a,b
                    ldd       #$00B7
                    pshs      a,b
                    ldd       #$0012
                    pshs      a,b
                    lbsr      OpenMsgWindow
                    leas      12,s
                    leax      >msgCheckingServer,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    jsr       [>UmeData_pflush]
                    ldd       #$0100
                    pshs      a,b
                    ldx       #$0CD8
                    pshs      x
                    lbsr      MemZero
                    leas      4,s
                    ldd       #$004A
                    pshs      a,b
                    leax      >strDwListUpdUrl,pcr
                    pshs      x
                    ldx       #$0CD8
                    pshs      x
                    lbsr      StrNCpy
                    leas      6,s
                    lbsr      DwFetchToBuf
                    stb       <$18,s
                    bne       a3@
                    leax      >msgServerConnErr,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    jsr       [>UmeData_phit]
                    lbra      CloseRetFlag
a3@                 clra
                    clrb
                    bra       VersionCopyLoop
* VersionCopyBody: body of VersionCopyLoop: copies readBuf[i] ($0DD8) to version byte $0CD4+i.
VersionCopyBody     ldd       2,s
                    ldx       #$0CD4
                    leax      d,x
                    pshs      x
                    ldd       4,s
                    ldx       #$0DD8
                    leax      d,x
                    ldb       ,x
                    clra
                    stb       [,s++]
                    ldd       2,s
                    addd      #$0001
* VersionCopyLoop: Loop head copying readBuf[0..3] into the latest-version bytes $0CD4..$0CD7; then nCmd = readBuf[4] -> $0ED8 and name parsing starts at index 5.
VersionCopyLoop     std       2,s
                    ldd       2,s
                    cmpd      #$0004
                    blt       VersionCopyBody
                    ldb       >UmeData_reserved_0DDC
                    clra
                    std       >UmeData_reserved_0ED8
                    ldd       #$0005
                    std       ,s
                    clra
                    clrb
                    std       4,s
                    clra
                    clrb
                    std       6,s
                    clra
                    clrb
                    lbra      CmdNameLoop
* ParseCmdName: Name-parse step: readBuf[idx] == CR terminates the current cmd-file name (table entry j, offset 3+k) with 0 and advances j; otherwise a4@.
ParseCmdName        ldd       ,s
                    ldx       #$0DD8
                    leax      d,x
                    ldb       ,x
                    cmpb      #$0D
                    bne       a4@
                    ldd       2,s
                    pshs      a,b
                    ldd       #$0012
                    lbsr      MulInt16
                    ldx       #$0EDC
                    leax      d,x
                    ldd       4,s
                    leax      d,x
                    clra
                    clrb
                    stb       3,x
                    clra
                    clrb
                    std       4,s
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    bra       b4@
* a4@: stores readBuf[idx] at table entry j offset 3+k, idx++, k++.
a4@                 ldd       2,s
                    pshs      a,b
                    ldd       #$0012
                    lbsr      MulInt16
                    ldx       #$0EDC
                    leax      d,x
                    ldd       4,s
                    leax      d,x
                    leax      3,x
                    pshs      x
                    ldd       2,s
                    ldx       #$0DD8
                    leax      d,x
                    ldb       ,x
                    stb       [,s++]
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    ldd       4,s
                    addd      #$0001
                    std       4,s
                    lbra      ParseCmdName
b4@                 ldd       2,s
                    addd      #$0001
* CmdNameLoop: Loop head: while j < nCmd parse names; then nSys = readBuf[idx] -> $0EDA and SysNameLoop continues in the same table from entry nCmd.
CmdNameLoop         std       2,s
                    ldd       2,s
                    cmpd      >UmeData_reserved_0ED8
                    lblt      ParseCmdName
                    ldd       ,s
                    ldx       #$0DD8
                    leax      d,x
                    ldb       ,x
                    clra
                    std       >UmeData_reserved_0EDA
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    clra
                    clrb
                    std       4,s
                    ldd       >UmeData_reserved_0ED8
                    lbra      SysNameLoop
* ParseSysName: Same CR-terminated name parse as ParseCmdName for the sys-file entries.
ParseSysName        ldd       ,s
                    ldx       #$0DD8
                    leax      d,x
                    ldb       ,x
                    cmpb      #$0D
                    bne       a5@
                    ldd       2,s
                    pshs      a,b
                    ldd       #$0012
                    lbsr      MulInt16
                    ldx       #$0EDC
                    leax      d,x
                    ldd       4,s
                    leax      d,x
                    clra
                    clrb
                    stb       3,x
                    clra
                    clrb
                    std       4,s
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    bra       b5@
* a5@: stores one character of a sys-file name into the $0EDC table.
a5@                 ldd       2,s
                    pshs      a,b
                    ldd       #$0012
                    lbsr      MulInt16
                    ldx       #$0EDC
                    leax      d,x
                    ldd       4,s
                    leax      d,x
                    leax      3,x
                    pshs      x
                    ldd       2,s
                    ldx       #$0DD8
                    leax      d,x
                    ldb       ,x
                    stb       [,s++]
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    ldd       4,s
                    addd      #$0001
                    std       4,s
                    lbra      ParseSysName
b5@                 ldd       2,s
                    addd      #$0001
* SysNameLoop: loop head for the sys-file names (j < nCmd+nSys); then the version score:
* each latest-version byte scores 2 when greater than 10, 11, 4, 'E' ($45) respectively,
* else 1; a total above 4 means an update is available.
SysNameLoop         std       2,s
                    ldd       >UmeData_reserved_0EDA
                    addd      >UmeData_reserved_0ED8
                    cmpd      2,s
                    lbgt      ParseSysName
                    ldb       >UmeData_reserved_0CD4
                    cmpb      #$0A
                    ble       a6@
                    ldd       6,s
                    addd      #$0002
                    bra       b6@
a6@                 ldd       6,s
                    addd      #$0001
b6@                 std       6,s
                    ldb       >UmeData_reserved_0CD5
                    cmpb      #$0B
                    ble       c6@
                    ldd       6,s
                    addd      #$0002
                    bra       d6@
c6@                 ldd       6,s
                    addd      #$0001
d6@                 std       6,s
                    ldb       >UmeData_reserved_0CD6
                    cmpb      #$04
                    ble       e6@
                    ldd       6,s
                    addd      #$0002
                    bra       f6@
e6@                 ldd       6,s
                    addd      #$0001
f6@                 std       6,s
                    ldb       >UmeData_reserved_0CD7
                    cmpb      #$45
                    ble       g6@
                    ldd       6,s
                    addd      #$0002
                    bra       h6@
g6@                 ldd       6,s
                    addd      #$0001
h6@                 std       6,s
                    ldd       6,s
                    cmpd      #$0004
                    ble       i6@
                    ldd       #$0001
                    bra       UpdateDecision
i6@                 clra
                    clrb
* UpdateDecision: Stores the update flag at $18,s; 0 -> prints msgNoUpdates and asks msgAskForce (no: clear dp $50 and CloseRetZero; yes: a7@); nonzero -> ShowUpdatesAvail.
UpdateDecision      stb       <$18,s
                    ldb       <$18,s
                    bne       ShowUpdatesAvail
                    leax      >msgNoUpdates,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    jsr       [>UmeData_pflush]
                    leax      >msgAskForce,pcr
                    pshs      x
                    jsr       [>UmeData_pyesno]
                    leas      2,s
                    bne       a7@
                    clra
                    clrb
                    stb       <UmeData_reserved_0050
                    lbra      CloseRetZero
* a7@: the user forced the update: flag = 1, then CloseRetFlag.
a7@                 ldd       #$0001
                    stb       <$18,s
* CloseRetFlag: Exit of CheckForUpdates: CloseMsgWindow and return the flag byte at $18,s (also reached from the server-connection error path with flag 0).
CloseRetFlag        lbsr      CloseMsgWindow
                    lbra      CheckUpdRetFlag
* ShowUpdatesAvail: Prints msgUpdatesAvail, fmtCurrentVersion with 10,11,4,'E' and fmtLatestVersion with $0CD4..$0CD7, then asks msgAskDownload.
ShowUpdatesAvail    leax      >msgUpdatesAvail,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    ldd       #$0045
                    pshs      a,b
                    ldd       #$0004
                    pshs      a,b
                    ldd       #$000B
                    pshs      a,b
                    ldd       #$000A
                    pshs      a,b
                    leax      >fmtCurrentVersion,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      10,s
                    ldb       >UmeData_reserved_0CD7
                    sex
                    pshs      a,b
                    ldb       >UmeData_reserved_0CD6
                    sex
                    pshs      a,b
                    ldb       >UmeData_reserved_0CD5
                    sex
                    pshs      a,b
                    ldb       >UmeData_reserved_0CD4
                    sex
                    pshs      a,b
                    leax      >fmtLatestVersion,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      10,s
                    jsr       [>UmeData_pflush]
                    leax      >msgAskDownload,pcr
                    pshs      x
                    jsr       [>UmeData_pyesno]
                    leas      2,s
                    bne       CloseRetYes
* CloseRetZero: Exit: CloseMsgWindow and return 0 (user declined the download).
CloseRetZero        lbsr      CloseMsgWindow
                    clra
                    clrb
                    bra       a8@
* CloseRetYes: ShowUpdatesAvail's yes: CloseMsgWindow, flush, return the flag (1).
CloseRetYes         lbsr      CloseMsgWindow
                    jsr       [>UmeData_pflush]
* CheckUpdRetFlag: shared tail of CheckForUpdates: return the flag at $18,s.
CheckUpdRetFlag     ldb       <$18,s
a8@                 leas      <$19,s
                    puls      u,pc
* SetRawMode: Os9Call(I$GetStt, {A = dwPath $0CD0, B = SS.Opt, X = 10,s}) reads the path
* options, b9@ zeroes option bytes 1..17 (PD.UPC..PD.QUT), Os9Call(I$SetStt) writes them back.
SetRawMode          pshs      u
                    leas      >-$008C,s
                    ldd       >UmeData_reserved_0CD0
                    stb       1,s
                    clra
                    clrb
                    stb       2,s
                    leax      10,s
                    stx       4,s
                    leax      ,s
                    pshs      x
                    ldd       #$008D
                    pshs      a,b
                    lbsr      Os9Call
                    leas      4,s
                    ldd       #$0001
                    bra       b9@
a9@                 ldd       >$008A,s
                    leax      10,s
                    leax      d,x
                    clra
                    clrb
                    stb       ,x
                    ldd       >$008A,s
                    addd      #$0001
* b9@: loop head, index 1..17 at $8A,s.
b9@                 std       >$008A,s
                    ldd       >$008A,s
                    cmpd      #$0011
                    ble       a9@
                    ldd       >UmeData_reserved_0CD0
                    stb       1,s
                    clra
                    clrb
                    stb       2,s
                    leax      10,s
                    stx       4,s
                    leax      ,s
                    pshs      x
                    ldd       #$008E
                    pshs      a,b
                    lbsr      Os9Call
                    leas      4,s
                    leas      >$008C,s
                    puls      u,pc
* DwFetchToBuf: OpenPath(pathDwDevN '/N', 3) -> dwPath $0CD0 (error: DwOpenErrExit with
* msgDwOpenErr and errno); DwFetchBufBody sends cmdBuf and reads the reply into readBuf
* $0DD8; returns 1 when the transfer completes, 0 on failure.
DwFetchToBuf        pshs      u
                    leas      <-$12,s
                    ldd       #$0003
                    pshs      a,b
                    leax      >pathDwDevN,pcr
                    pshs      x
                    lbsr      OpenPath
                    leas      4,s
                    std       >UmeData_reserved_0CD0
                    bge       DwFetchBufBody
                    ldd       >UmeData_c_errno
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    leax      >msgDwOpenErr,pcr
                    lbra      DwOpenErrExit
* DwFetchBufBody: SetIntercept(HupSigHandler), state $0CCE = 0, count $0CCC = 0,
* SetRawMode, WritePath(dwPath, cmdBuf, StrLen), MemZero readBuf, ReadPath 1 byte:
* 'F' -> msgCmdFailed + wait, FetchRetZero; 'O' -> SkipOkLine; then BufXferLoop.
DwFetchBufBody      leax      >HupSigHandler,pcr
                    pshs      x
                    lbsr      SetIntercept
                    leas      2,s
                    clra
                    clrb
                    std       >UmeData_reserved_0CCE
                    clra
                    clrb
                    std       >UmeData_reserved_0CCC
                    clra
                    clrb
                    std       14,s
                    clra
                    clrb
                    std       12,s
                    clra
                    clrb
                    std       10,s
                    lbsr      SetRawMode
                    ldx       #$0CD8
                    pshs      x
                    lbsr      StrLen
                    std       ,s
                    ldx       #$0CD8
                    pshs      x
                    ldd       >UmeData_reserved_0CD0
                    pshs      a,b
                    lbsr      WritePath
                    leas      6,s
                    ldd       #$0100
                    pshs      a,b
                    ldx       #$0DD8
                    pshs      x
                    lbsr      MemZero
                    leas      4,s
                    ldd       #$0001
                    pshs      a,b
                    ldx       #$0DD8
                    pshs      x
                    ldd       >UmeData_reserved_0CD0
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    ldb       >UmeData_reserved_0DD8
                    cmpb      #$46
                    bne       a10@
                    leax      >msgCmdFailed,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    jsr       [>UmeData_phit]
                    lbra      FetchRetZero
a10@                ldb       >UmeData_reserved_0DD8
                    cmpb      #$4F
                    lbne      BufXferLoop
* SkipOkLine: Loop reading single bytes from the DW path until the CR ending the 'O...' status line.
SkipOkLine          ldd       #$0001
                    pshs      a,b
                    ldx       #$0DD8
                    pshs      x
                    ldd       >UmeData_reserved_0CD0
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    ldb       >UmeData_reserved_0DD8
                    cmpb      #$0D
                    bne       SkipOkLine
                    lbra      BufXferLoop
* PollReadyBuf: Os9Call(I$GetStt, {A = dwPath, B = SS.Ready}): E$NotRdy ($F6) -> SleepTicks(1)
* and retry; another error -> state 2; ready -> b11@ with the byte count from B.
PollReadyBuf        ldd       >UmeData_reserved_0CD0
                    stb       1,s
                    ldd       #$0001
                    stb       2,s
                    leax      ,s
                    pshs      x
                    ldd       #$008D
                    pshs      a,b
                    lbsr      Os9Call
                    leas      4,s
                    std       -2,s
                    beq       b11@
                    ldb       2,s
                    sex
                    cmpd      #$FFF6
                    bne       a11@
                    ldd       #$0001
                    pshs      a,b
                    lbsr      SleepTicks
                    leas      2,s
                    bra       BufXferLoop
a11@                ldd       #$0002
                    bra       d11@
* b11@: MemZero readBuf, ReadPath(dwPath, readBuf, n) -> $0CCC; 0 bytes -> state 1 (done).
b11@                ldb       2,s
                    clra
                    std       <$10,s
                    ble       c11@
                    ldd       #$0100
                    pshs      a,b
                    ldx       #$0DD8
                    pshs      x
                    lbsr      MemZero
                    leas      4,s
                    ldd       <$10,s
                    pshs      a,b
                    ldx       #$0DD8
                    pshs      x
                    ldd       >UmeData_reserved_0CD0
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    std       >UmeData_reserved_0CCC
                    bne       BufXferLoop
c11@                ldd       #$0001
d11@                std       >UmeData_reserved_0CCE
* BufXferLoop: Loop head: while state $0CCE == 0 -> PollReadyBuf; then ClosePath(dwPath) and return state==2 ? 0 : 1.
BufXferLoop         ldd       >UmeData_reserved_0CCE
                    lbeq      PollReadyBuf
                    ldd       >UmeData_reserved_0CD0
                    pshs      a,b
                    lbsr      ClosePath
                    leas      2,s
                    ldd       >UmeData_reserved_0CCE
                    cmpd      #$0002
                    lbeq      FetchRetZero
                    lbra      FetchRetOne
* DwFetchToFile: as DwFetchToBuf (pathDwDevN2, msgDwOpenErr2, msgCmdFailed2), but every
* received chunk is written to the output path in $0CD2 (opened by the caller's CreatFile).
DwFetchToFile       pshs      u
                    leas      <-$12,s
                    ldd       #$0003
                    pshs      a,b
                    leax      >pathDwDevN2,pcr
                    pshs      x
                    lbsr      OpenPath
                    leas      4,s
                    std       >UmeData_reserved_0CD0
                    bge       DwFetchFileBody
                    ldd       >UmeData_c_errno
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    leax      >msgDwOpenErr2,pcr
* DwOpenErrExit: shared error exit of both fetch routines: alert(msg, 1, errno), FetchRetZero.
DwOpenErrExit       pshs      x
                    jsr       [>UmeData_palert]
                    leas      6,s
                    lbra      FetchRetZero
* DwFetchFileBody: After the open: intercept, state reset, SetRawMode, send cmdBuf, first byte 'F' -> msgCmdFailed2 + wait + close, 'O' -> b12@, then FileXferLoop.
DwFetchFileBody     leax      >HupSigHandler,pcr
                    pshs      x
                    lbsr      SetIntercept
                    leas      2,s
                    clra
                    clrb
                    std       >UmeData_reserved_0CCE
                    clra
                    clrb
                    std       >UmeData_reserved_0CCC
                    clra
                    clrb
                    std       14,s
                    clra
                    clrb
                    std       12,s
                    clra
                    clrb
                    std       10,s
                    lbsr      SetRawMode
                    ldx       #$0CD8
                    pshs      x
                    lbsr      StrLen
                    std       ,s
                    ldx       #$0CD8
                    pshs      x
                    ldd       >UmeData_reserved_0CD0
                    pshs      a,b
                    lbsr      WritePath
                    leas      6,s
                    ldd       #$0100
                    pshs      a,b
                    ldx       #$0DD8
                    pshs      x
                    lbsr      MemZero
                    leas      4,s
                    ldd       #$0001
                    pshs      a,b
                    ldx       #$0DD8
                    pshs      x
                    ldd       >UmeData_reserved_0CD0
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    ldb       >UmeData_reserved_0DD8
                    cmpb      #$46
                    bne       a12@
                    leax      >msgCmdFailed2,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    jsr       [>UmeData_phit]
                    ldd       >UmeData_reserved_0CD0
                    pshs      a,b
                    lbsr      ClosePath
                    leas      2,s
                    lbra      FetchRetZero
a12@                ldb       >UmeData_reserved_0DD8
                    cmpb      #$4F
                    lbne      FileXferLoop
* b12@: reads bytes until CR (end of the 'O' status line).
b12@                ldd       #$0001
                    pshs      a,b
                    ldx       #$0DD8
                    pshs      x
                    ldd       >UmeData_reserved_0CD0
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    ldb       >UmeData_reserved_0DD8
                    cmpb      #$0D
                    bne       b12@
                    lbra      FileXferLoop
* PollReadyFile: SS.Ready poll of the file-download variant: E$NotRdy -> sleep 1 tick and retry, other error -> state 2, ready -> ReadChunkToFile.
PollReadyFile       ldd       >UmeData_reserved_0CD0
                    stb       1,s
                    ldd       #$0001
                    stb       2,s
                    leax      ,s
                    pshs      x
                    ldd       #$008D
                    pshs      a,b
                    lbsr      Os9Call
                    leas      4,s
                    std       -2,s
                    beq       ReadChunkToFile
                    ldb       2,s
                    sex
                    cmpd      #$FFF6
                    bne       a13@
                    ldd       #$0001
                    pshs      a,b
                    lbsr      SleepTicks
                    leas      2,s
                    bra       FileXferLoop
a13@                ldd       #$0002
                    bra       FileXferSetState
* ReadChunkToFile: MemZero readBuf, ReadPath n bytes -> $0CCC, WritePath($0CD2, readBuf, count); 0 bytes -> state 1 (done).
ReadChunkToFile     ldb       2,s
                    clra
                    std       <$10,s
                    ble       a14@
                    ldd       #$0100
                    pshs      a,b
                    ldx       #$0DD8
                    pshs      x
                    lbsr      MemZero
                    leas      4,s
                    ldd       <$10,s
                    pshs      a,b
                    ldx       #$0DD8
                    pshs      x
                    ldd       >UmeData_reserved_0CD0
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    std       >UmeData_reserved_0CCC
                    beq       a14@
                    ldd       >UmeData_reserved_0CCC
                    pshs      a,b
                    ldx       #$0DD8
                    pshs      x
                    ldd       >UmeData_reserved_0CD2
                    pshs      a,b
                    lbsr      WritePath
                    leas      6,s
                    bra       FileXferLoop
a14@                ldd       #$0001
* FileXferSetState: Stores state $0CCE then falls into FileXferLoop; PollReadyFile bra's 2 (abort), ReadChunkToFile 1 (done)
FileXferSetState    std       >UmeData_reserved_0CCE
* FileXferLoop: Loop head: while state==0 -> PollReadyFile; then ClosePath(dwPath), ClosePath($0CD2); state 2 -> FetchRetZero else FetchRetOne.
FileXferLoop        ldd       >UmeData_reserved_0CCE
                    lbeq      PollReadyFile
                    ldd       >UmeData_reserved_0CD0
                    pshs      a,b
                    lbsr      ClosePath
                    leas      2,s
                    ldd       >UmeData_reserved_0CD2
                    pshs      a,b
                    lbsr      ClosePath
                    leas      2,s
                    ldd       >UmeData_reserved_0CCE
                    cmpd      #$0002
                    bne       FetchRetOne
* FetchRetZero: Common exit of both fetch routines returning 0 (failure).
FetchRetZero        clra
                    clrb
                    bra       DwFetchRet
* FetchRetOne: Exit returning 1 (transfer complete).
FetchRetOne         ldd       #$0001
* DwFetchRet: shared epilogue of both fetch routines.
DwFetchRet          leas      <$12,s
                    puls      u,pc
* OpenMsgWindow: printf(<$14 fmt, $C6, a1..a6) then flush: the window-open code $C6. Called
* with (15,183,50,10,1,WinStylePaper3D), (18,183,42,22,...) and (18,183,42,17,...).
OpenMsgWindow       pshs      u
                    ldd       14,s
                    pshs      a,b
                    ldb       15,s
                    sex
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    ldd       14,s
                    pshs      a,b
                    ldd       #$00C6
                    pshs      a,b
                    ldd       <UmeData_reserved_0014
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      <$10,s
                    jsr       [>UmeData_pflush]
                    puls      u,pc
* CloseMsgWindow: printf(<$16 fmt, $C7): the window-close code; called on every exit path.
CloseMsgWindow      pshs      u
                    ldd       #$00C7
                    pshs      a,b
                    ldd       <UmeData_reserved_0016
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    puls      u,pc
                    fcc       /4@O_4/
                    fcb       $06,$CC,$00,$90,$34,$06,$DC,$0A
                    fcb       $34,$06,$AD,$9F,$03
                    fcs       /]2f5@/
* msgNeedDW4: shown by OverlayEntry when dp $51 says there is no /N port.
msgNeedDW4          fcc       /  You must have DriveWire4 and Internet access/
                    fcb       $0D,$00
msgAskUpdate        fcc       / Update Studio-9 via DW4 Internet? /
                    fcb       $00
msgDeletingOld      fcc       / Deleting the older files.../
                    fcb       $0D,$00
fmtInstallingCmds   fcb       $0D
                    fcc       / Downloading and installing %02d Cmd files/
                    fcb       $0D,$00
fmtDownloadingCmd   fcb       $0D
                    fcc       / Downloading %s..../
                    fcb       $0D,$00
* fmtDwListCmdUrl: DW4 'dw server list' command, streams .../u/23059963/ud/UME/<name>
* over the /N channel; sprintf'd into cmdBuf for each cmd file.
fmtDwListCmdUrl     fcc       /dw ser lis https:/
                    fcb       $2F,$2F
                    fcc       /dl.dropboxusercontent.com/
                    fcb       $2F,$75,$2F
                    fcc       /23059963/
                    fcb       $2F,$75,$64,$2F
                    fcc       /UME/
                    fcb       $2F,$25,$73,$0D,$00
pathCmdsFile        fcb       $2F,$64,$64,$2F
                    fcc       /cmds/
                    fcb       $2F,$25,$73,$00
fmtErrUpdatingCmd   fcc       /Error updating %s/
                    fcb       $0D,$00
fmtCmdDownloaded    fcc       / %s Downloaded./
                    fcb       $0D,$00
msgSetAttrsCmd      fcc       / Setting attributes/
                    fcb       $0D,$00
* pathCmdsFile2: second copy of '/dd/cmds/%s', rebuilds the path for SetFileAttr.
pathCmdsFile2       fcb       $2F,$64,$64,$2F
                    fcc       /cmds/
                    fcb       $2F,$25,$73,$00
fmtAttrsSetCmd      fcc       / Attributes set for %s/
                    fcb       $0D,$00
fmtCmdsDoneSysCount fcc       / Cmd Files complete./
                    fcb       $0D
                    fcc       / Downloading %02d system files/
                    fcb       $0D,$00
fmtDownloadingSys   fcb       $0D
                    fcc       / Downloading %s..../
                    fcb       $0D,$00
* fmtDwListSysUrl: the sys-file variant (a double slash before %s, as in the original).
fmtDwListSysUrl     fcc       /dw ser lis https:/
                    fcb       $2F,$2F
                    fcc       /dl.dropboxusercontent.com/
                    fcb       $2F,$75,$2F
                    fcc       /23059963/
                    fcb       $2F,$75,$64,$2F
                    fcc       /UME/
                    fcb       $2F,$2F,$25,$73,$0D,$00
pathSysFile         fcb       $2F,$64,$64,$2F
                    fcc       /sys/
                    fcb       $2F,$25,$73,$00
fmtErrUpdatingSys   fcc       /Error updating %s/
                    fcb       $0D,$00
fmtSysDownloaded    fcc       / %s Downloaded./
                    fcb       $0D,$00
msgSetAttrsSys      fcc       / Setting attributes/
                    fcb       $0D,$00
* pathSysFile2: second copy of '/dd/sys/%s', for SetFileAttr.
pathSysFile2        fcb       $2F,$64,$64,$2F
                    fcc       /sys/
                    fcb       $2F,$25,$73,$00
fmtAttrsSetSys      fcc       / Attributes set for %s/
                    fcb       $0D,$00
msgAllDownloaded    fcb       $0D
                    fcc       /    All Files Downloaded/
                    fcb       $0D,$00
msgRestartWarn1     fcc       /You must restart Studio-9 to activate/
                    fcb       $0D,$00
msgRestartWarn2     fcc       /the new version. If you continue to run/
                    fcb       $0D,$00
msgRestartWarn3     fcc       /this version, Studio-9 will most likely CRASH/
                    fcb       $0D,$00
msgCheckingServer   fcc       /  Checking the Server for Studio-9 Updates/
                    fcb       $0D,$00
* strDwListUpdUrl: fetches the update manifest .../UME/s9.upd (version bytes, counts, names).
strDwListUpdUrl     fcc       /dw ser lis https:/
                    fcb       $2F,$2F
                    fcc       /dl.dropboxusercontent.com/
                    fcb       $2F,$75,$2F
                    fcc       /23059963/
                    fcb       $2F,$75,$64,$2F
                    fcc       /UME/
                    fcb       $2F
                    fcc       /s9.upd/
                    fcb       $0D,$00
msgServerConnErr    fcc       /Error in Server connection!/
                    fcb       $0D,$00
msgNoUpdates        fcb       $0D
                    fcc       / No Updates Available at this time./
                    fcb       $0D,$0D,$00
msgAskForce         fcc       / Force Updates Anyway? /
                    fcb       $00
msgUpdatesAvail     fcb       $0D
                    fcc       / Updates are available !/
                    fcb       $0D,$00
* fmtCurrentVersion: printed with the built-in 10,11,4,'E'.
fmtCurrentVersion   fcb       $0D
                    fcc       / Current Version:%02d.%02d.%02d%c/
                    fcb       $0D,$00
* fmtLatestVersion: printed with the manifest bytes $0CD4..$0CD7.
fmtLatestVersion    fcb       $0D
                    fcc       / Latest Version :%02d.%02d.%02d%c/
                    fcb       $0D,$00
msgAskDownload      fcc       / Download Updates to Studio-9? /
                    fcb       $00
* pathDwDevN: '/N', the DriveWire4 virtual serial port, opened (mode 3) by DwFetchToBuf.
pathDwDevN          fcb       $2F,$4E,$00
msgDwOpenErr        fcc       /Error opening DW device!! Error #/
                    fcb       $00
* msgCmdFailed: the DW server answered 'F' to the list command.
msgCmdFailed        fcb       $0D
                    fcc       /      Command Failed!/
                    fcb       $0D,$00
pathDwDevN2         fcb       $2F,$4E,$00
msgDwOpenErr2       fcc       /Error opening DW device!! Error #/
                    fcb       $00
msgCmdFailed2       fcb       $0D
                    fcc       /      Command Failed!/
                    fcb       $0D,$00
* StrLen: strlen: scans for the NUL, returns end - start in D; used to size the command written to the DW path.
StrLen              pshs      u
                    ldu       4,s
a15@                ldb       ,u+
                    bne       a15@
                    leau      -1,u
                    tfr       u,d
                    subd      4,s
                    puls      u,pc
* StrNCpy: strncpy(dst, src, n): copies up to n bytes stopping after the NUL and zero-fills the rest; returns dst. Copies strDwListUpdUrl into cmdBuf.
StrNCpy             pshs      y,u
                    ldu       8,s
                    ldx       6,s
                    ldy       10,s
                    beq       c16@
a16@                ldb       ,u+
                    stb       ,x+
                    leay      -1,y
                    beq       c16@
                    tstb
                    bne       a16@
b16@                clr       ,x+
                    leay      -1,y
                    bne       b16@
c16@                ldd       6,s
                    puls      y,u,pc
* MemZero: Fills n bytes at buf with 0 (Microware clear()); returns buf; used to wipe the 256-byte command and read buffers.
MemZero             pshs      u
                    ldu       4,s
                    clrb
                    ldx       6,s
                    beq       b17@
a17@                stb       ,u+
                    leax      -1,x
                    bne       a17@
b17@                ldd       4,s
                    puls      u,pc
* MulInt16: C runtime 16x16 unsigned multiply of D by the word pushed on the stack; fast 8x8 mul when both high bytes are 0, else Mul16Long; result in D (X = high word). Used for index*18 into the name table.
MulInt16            tsta
                    bne       Mul16Long
                    tst       2,s
                    bne       Mul16Long
                    lda       3,s
                    mul
                    ldx       ,s
                    stx       2,s
                    ldx       #$0000
                    std       ,s
                    puls      a,b,pc
* Mul16Long: Four-partial-product path of MulInt16 for operands with nonzero high bytes.
Mul16Long           pshs      a,b
                    ldd       #$0000
                    pshs      a,b
                    pshs      a,b
                    lda       5,s
                    ldb       9,s
                    mul
                    std       2,s
                    lda       5,s
                    ldb       8,s
                    mul
                    addd      1,s
                    std       1,s
                    bhs       a18@
                    inc       ,s
a18@                lda       4,s
                    ldb       9,s
                    mul
                    addd      1,s
                    std       1,s
                    bhs       b18@
                    inc       ,s
b18@                lda       4,s
                    ldb       8,s
                    mul
                    addd      ,s
                    std       ,s
                    ldx       6,s
                    stx       8,s
                    ldx       ,s
                    ldd       2,s
                    leas      8,s
                    rts
* SetFileAttr: attr(name, attrs): OpenReadFD opens the file for write and reads its FD;
* F$ID - a non-superuser must own the file (FD.OWN at 1,x) else E$FNA ($D6); a19@ stores
* the new attribute byte and writes the FD back with I$SetStt SS.FD, then closes.
SetFileAttr         pshs      y,u
                    leas      -16,s
                    bsr       OpenReadFD
                    blo       b19@
                    pshs      a,y
                    os9       F$ID
                    cmpy      #$0000
                    beq       a19@
                    ldb       #$D6
                    cmpy      1,x
                    orcc      #$01
                    bne       b19@
a19@                ldb       <$1C,s
                    stb       ,x
                    puls      a,y
                    ldb       #$0F
                    os9       I$SetStt
                    blo       b19@
                    os9       I$Close
b19@                leas      <$10,s
                    puls      y,u
                    lbra      CarryToErrno
* OpenReadFD: I$Open(name, WRITE.) then I$GetStt SS.FD ($0F): 16 FD bytes into SetFileAttr's frame.
OpenReadFD          lda       #$02
                    ldx       <$18,s
                    os9       I$Open
                    bhs       a20@
                    rts
a20@                leax      2,s
                    ldy       #$0010
                    ldb       #$0F
                    os9       I$GetStt
                    rts
* CreatFile: Microware creat(name, perms): I$Create with mode = perms, attr = (perms&$24)|$0B;
* on E$CEF ($DA) with perms bit 7 clear it reopens with I$Open(perms&7) and truncates with
* I$SetStt SS.Size 0. Errors -> SetErrno.
CreatFile           ldx       2,s
                    lda       5,s
                    tfr       a,b
                    andb      #$24
                    orb       #$0B
                    os9       I$Create
                    bhs       CreatRetPath
                    cmpb      #$DA
                    bne       a21@
                    lda       5,s
                    bita      #$80
                    bne       a21@
                    anda      #$07
                    ldx       2,s
                    os9       I$Open
                    blo       a21@
                    pshs      a,u
                    ldx       #$0000
                    leau      ,x
                    ldb       #$02
                    os9       I$SetStt
                    puls      a,u
                    bhs       CreatRetPath
                    pshs      b
                    os9       I$Close
                    puls      b
a21@                lbra      SetErrno
                    fcb       $AE,$62,$A6,$65,$E6,$67,$10,$3F
                    fcb       $83,$25,$F2,$20,$14,$C1,$DA,$26
                    fcb       $EC,$10,$3F,$87,$25,$E7,$AE,$62
                    fcb       $A6,$65,$E6,$67,$10,$3F,$83,$25
                    fcb       $EC
* CreatRetPath: Success exit of CreatFile: path number from A returned in D.
CreatRetPath        tfr       a,b
                    clra
                    rts
* OpenPath: open(name, mode): I$Open; error -> SetErrno/-1, else the path number in D. Opens the '/N' DriveWire port.
OpenPath            ldx       2,s
                    lda       5,s
                    os9       I$Open
                    lblo      SetErrno
                    tfr       a,b
                    clra
                    rts
* ClosePath: close(path): I$Close then CarryToErrno.
ClosePath           lda       3,s
                    os9       I$Close
                    lbra      CarryToErrno
* ReadPath: read(path, buf, n): I$Read; E$EOF ($D3) returns 0; other errors -1 via SetErrno; else the byte count from Y.
ReadPath            pshs      y
                    ldx       6,s
                    lda       5,s
                    ldy       8,s
                    pshs      y
                    os9       I$Read
                    bhs       b22@
                    cmpb      #$D3
                    bne       a22@
                    clra
                    clrb
                    puls      x,y,pc
a22@                puls      x,y
                    lbra      SetErrno
b22@                tfr       y,d
                    puls      x,y,pc
                    fcb       $34,$20,$A6,$65,$AE,$66,$10,$AE
                    fcc       /h4 /
                    fcb       $10,$3F,$8B,$20,$DD
* WritePath: write(path, buf, n): n==0 returns 0; I$Write; error -1 via SetErrno; else n.
WritePath           pshs      y
                    ldy       8,s
                    beq       a23@
                    lda       5,s
                    ldx       6,s
                    os9       I$Write
                    bhs       a23@
                    puls      y
                    lbra      SetErrno
a23@                tfr       y,d
                    puls      y,pc
                    fcb       $34,$20,$10,$AE,$68,$27,$F5,$A6
                    fcb       $65,$AE,$66,$10,$3F,$8C,$20,$E5
                    fcb       $39,$8E,$00,$00,$5F,$10,$3F,$0A
                    fcb       $16,$00,$80
                    fcs       /94`./
                    fcb       $66,$10,$AE,$68,$EE,$6A,$10,$3F
                    fcb       $17,$35,$E0,$A6,$63,$E6,$65,$10
                    fcb       $3F,$0F,$10,$25,$00,$66,$39
* SleepTicks: sleep(ticks): F$Sleep with X = ticks; error -1, else the remaining ticks. Used with 1 tick while polling SS.Ready.
SleepTicks          ldx       2,s
                    os9       F$Sleep
                    lblo      SetErrno
                    tfr       x,d
                    rts
* SetIntercept: intercept(handler): stores the handler pointer at $1044,y and issues F$Icpt with X = IcptTrampoline and U = the data pointer; returns 0/-1 via CarryToErrno.
SetIntercept        pshs      u
                    tfr       y,u
                    ldx       4,s
                    stx       >$1044,y
                    leax      >IcptTrampoline,pcr
                    os9       F$Icpt
                    puls      u
                    lbra      CarryToErrno
* IcptTrampoline: the C intercept stub, kept as fcb/fcc bytes: tfr u,y; clra; pshs a,b
* (signal code as int); jsr [>$1044,y]; leas 2,s; rti.
IcptTrampoline      fcb       $1F
                    fcc       /2O4/
                    fcb       $06,$AD,$B9,$10
                    fcc       /D2b;/
* Os9Call: _os9(code, regs): builds 'os9 code / rts' on the stack, loads A,B,X,Y,U from
* the register block, runs it, stores CC,A,B,DP,X,Y,U back; returns -1 on carry, else 0.
Os9Call             pshs      y,u
                    lda       7,s
                    ldb       #$39
                    pshs      a,b
                    ldd       #$103F
                    pshs      a,b
                    ldu       12,s
                    ldd       1,u
                    ldx       4,u
                    ldy       6,u
                    ldu       8,u
                    jsr       ,s
                    pshs      cc,u
                    ldu       15,s
                    leau      8,u
                    pshu      a,b,dp,x,y
                    puls      a,x
                    sta       ,-u
                    stx       8,u
                    leas      4,s
                    puls      y,u
                    bita      #$01
                    beq       a24@
                    ldd       #$FFFF
                    rts
a24@                clra
                    clrb
                    rts
* SetErrno: Common C-runtime error exit: errno at $034F,y = B, returns -1.
SetErrno            clra
                    std       >$034F,y
                    ldd       #$FFFF
                    rts
* CarryToErrno: Carry set -> SetErrno, else return 0; shared tail of ClosePath, SetIntercept and SetFileAttr.
CarryToErrno        blo       SetErrno
                    clra
                    clrb
                    rts
                    fcb       $00,$22,$00,$00,$00,$00,$04,$00
                    fcb       $04,$00,$00,$00,$01,$47,$01,$45
                    fcb       $01,$43,$01,$41,$01,$3F,$01,$3D
                    fcb       $01,$56,$01,$54,$01,$52,$01,$50
                    fcb       $01,$4E,$01,$4C,$02,$0A,$01
                    fcc       /h4c/
                    fcb       $00,$03,$00,$02,$00,$04,$00,$00
                    fcb       $01,$11
                    fcc       /!1AYi/
                    fcb       $7F,$03,$00,$00,$00,$02,$03,$00
                    fcb       $00,$00,$02,$03,$00,$20,$00,$02
                    fcb       $02,$03,$02,$03,$04,$03,$03,$03
                    fcb       $03,$03,$03,$03,$00,$03,$03,$03
                    fcb       $03,$03,$03,$03,$03,$03,$03,$03
                    fcb       $03,$02,$02,$02,$04,$04,$02,$02
                    fcb       $03,$03,$01
                    fcc       /%c%c%c%c%c%c%c/
                    fcb       $00
                    fcc       /%c%c%c%c%c%c/
                    fcb       $0D,$00,$01,$80,$02,$40,$02,$A0
                    fcb       $01,$00,$00,$17,$00,$18,$00,$17
                    fcb       $00,$0C,$00,$17,$00,$11,$00,$17
                    fcb       $00,$05,$00,$17,$00,$00,$00,$17
                    fcb       $00,$12,$00,$17,$00,$10,$00,$17
                    fcb       $00,$00,$00,$17,$00,$17,$00,$17
                    fcb       $00,$17,$00,$17,$00,$17,$00,$17
                    fcb       $00,$17,$00,$17,$00,$17,$00,$17
                    fcb       $00,$17,$00,$17,$00,$17,$00,$17
                    fcb       $00,$17,$00,$17,$00,$17
                    fcc       /1234567890123456789012345678901234567890123456789/
                    fcb       $00
                    fcc       / Hi, Lester!  Keep your Hands off my code! -Mike /
                    fcb       $00
                    fcc       /1234567890123456789012345678901234567890123456789/
                    fcb       $00
                    fcc       / This array is here for a reason. You are one hel/
                    fcb       $00
                    fcc       /l of a C hacker if you figure out what that is!  /
                    fcb       $00
                    fcc       /1234567890123456789012345678901234567890123456789/
                    fcb       $00
                    fcc       /1234567890123456789012345678901234567890123456/
                    fcb       $00,$00,$1A,$01,$72,$01,$6E,$01
                    fcb       $6A,$01,$66,$01,$62,$01,$88,$01
                    fcb       $86,$01,$84,$01,$82,$01,$7E,$01
                    fcb       $7A,$01,$76,$01,$96,$01,$94,$01
                    fcb       $92,$01,$90,$01,$8E,$01,$8C,$01
                    fcb       $8A,$01,$A4,$01,$A2,$01,$A0,$01
                    fcb       $9E,$01,$9C,$01,$9A,$01,$98,$00
                    fcb       $0C,$00,$12,$00,$10,$00,$0E,$00
                    fcb       $0C,$00,$0A,$00,$20,$00,$1E,$00
                    fcb       $1C,$00,$1A,$00,$18,$00,$16,$00
                    fcb       $14
                    fcc       /s9u/
                    fcb       $00

                    fill      0,$1D00-*           pad to $1D00 bytes so F$Link never puts this overlay in slot 7 and the score page always gets it
                    emod
eom                 equ       *
                    end
