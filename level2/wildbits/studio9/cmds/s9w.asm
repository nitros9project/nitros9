* s9w: the DriveWire4 MIDI configuration overlay, ported from the Um3W overlay of
* UltiMusE III v10.11.4E (disassembled; routine names are reverse-engineered).
* OverlayMain is called by s9 with one character argument: 'd' = device-selection menu,
* 'p' = synth-profile menu, 'v' = re-send "dw mid out N" from the saved device digit ($03B7),
* 'f' = re-send "dw mid syn pro <name>" from the saved profile name ($03B8), 's' = both
* with a 2-tick sleep between (restores the saved settings at startup).
* Both menus open an s9 window (window codes $C6/$C7/$CC/$90 through s9's printf), run
* "dw mid sta" or "dw mid syn sho pro" over the DriveWire virtual serial port /N, capture
* the reply lines into a 24x80 array at $0E5B (first line = header, discarded), print them,
* then call s9's menu picker (UmeData_ptextmen). A click row is mapped through
* tblProfPickDigit to a hex digit (one row per device or profile); a typed key is returned
* negated. The digit becomes the device number ("dw mid out N") or indexes the profile list
* ("dw mid syn pro <first 10 chars>"), and the DW4 reply line is echoed.
* DwCmdGetLines and DwCmdSend are the two DW4 transaction engines: open /N (mode 3),
* install SigHandler (signal 4 -> status 1, anything else -> status 2), put the path in
* raw mode (SS.Opt bytes 1..17 zeroed), write the command, read the first reply byte
* ('F' = "Command Failed!", 'O' = OK, skip the rest of that line), then poll SS.Ready
* (E$NotRdy -> sleep 1 tick) and read chunks until data runs out (DwCmdSend: until a CR or
* LF arrives); status 2 returns 0, otherwise 1.
* Globals: $0CCE command buffer (128), $0D4E reply buffer (255), $0E4D status, $0E4F index,
* $0E51 line count, $0E53 column, $0E55 bytes ready, $0E57 bytes read, $0E59 /N path,
* $15DB register struct for _os9(), $15E8 intercept vector, $034F errno.
* The tail is the Microware C runtime: itoa/strrev, strcpy/strcat/strlen/strncpy/strncat,
* memory clear, 16-bit mul/div/mod (divide-by-zero raises signal 45), and the
* open/close/read/write/tsleep/intercept/_os9 wrappers. SendMidiOutCmd and DevDigitPicked
* call IntToStr without its destination buffer argument (the pointer is whatever sits
* above on the stack), a latent bug in the original program.
* Data size $1C6A. Data addresses are mostly left numeric (<$xx = direct page); fcb/fcc
* lines inside code are code bytes kept as data.

                    nam       s9w
                    ttl       s9w (disassembly)

                  IFP1
                    use       defsfile
                  ENDC
UME_SCOPE_S9W                  equ       1
                    use       equates.asm

tylg                set       $11
atrv                set       $81
size                equ       $1C6A

                    mod       eom,name,tylg,atrv,start,size
name                fcs       /s9w/
                    fcb       $07
start               equ       *
                    lbra      OverlayMain
                    fcb       $39,$0D,$00
* SigHandler: code kept as fcb: status $0E4D = 1 for signal 4, else 2. Installed with
* Intercept by both DW transaction routines to end the read loop.
SigHandler          fcb       $34,$40,$EC,$64,$10,$83,$00,$04
                    fcb       $26,$05,$CC,$00,$01,$20,$03,$CC
                    fcb       $00,$02,$FD,$0E,$4D,$35,$C0
* OverlayMain: one char argument (5,s), sign-extended into X, dispatched on 'd','p','v','f','s';
* returns byte >$01A6 in the argument slot.
OverlayMain         pshs      u
                    ldb       5,s
                    sex
                    tfr       d,x
                    bra       DispatchCmd
CaseDevMenu         lbsr      DevSelectMenu
                    bra       MainExit
CaseProfMenu        lbsr      ProfSelectMenu
                    bra       MainExit
CaseSendDev         bsr       SendMidiOutCmd
                    bra       MainExit
CaseSendProf        lbsr      SendSynProfCmd
                    bra       MainExit
CaseSendBoth        bsr       SendDevThenProf
                    bra       MainExit
* DispatchCmd: cmpx chain on the command character: $64 d, $70 p, $76 v, $66 f, $73 s; unknown falls into MainExit
DispatchCmd         cmpx      #$0064
                    beq       CaseDevMenu
                    cmpx      #$0070
                    beq       CaseProfMenu
                    cmpx      #$0076
                    beq       CaseSendDev
                    cmpx      #$0066
                    beq       CaseSendProf
                    cmpx      #$0073
                    beq       CaseSendBoth
* MainExit: common exit of OverlayMain: ldb >$01A6; stb 5,s; puls u,pc
MainExit            ldb       >UmeData_reserved_01A6
                    stb       5,s
                    puls      u,pc
* SendDevThenProf: 's' command: SendMidiOutCmd, TSleep(2), SendSynProfCmd - restores both saved DW4 MIDI settings
SendDevThenProf     pshs      u
                    bsr       SendMidiOutCmd
                    ldd       #$0002
                    pshs      a,b
                    lbsr      TSleep
                    leas      2,s
                    lbsr      SendSynProfCmd
                    puls      u,pc
* SendMidiOutCmd: if saved device digit >$03B7 is set: strcpy(cmd,"dw mid out "), convert the hex digit to 0..15, strcat(cmd, IntToStr(n)) (buffer arg missing - compiled bug), strcat "\r", DwCmdSend
SendMidiOutCmd      pshs      u
                    leas      -1,s
                    ldb       >UmeData_reserved_03B7
                    lbeq      DevMenuExit
                    ldb       >UmeData_reserved_03B7
                    stb       ,s
                    leax      >strDwMidOut,pcr
                    pshs      x
                    ldx       #$0CCE
                    pshs      x
                    lbsr      StrCpy
                    leas      4,s
                    ldb       ,s
                    cmpb      #$39
                    ble       a1@
                    ldb       ,s
                    sex
                    addd      #$FFF9
                    stb       ,s
a1@                 ldb       ,s
                    sex
                    addd      #$FFD0
                    stb       ,s
                    sex
                    pshs      a,b
                    lbsr      IntToStr
                    std       ,s
                    ldx       #$0CCE
                    pshs      x
                    lbsr      StrCat
                    leas      4,s
                    leax      >strCR1,pcr
                    pshs      x
                    ldx       #$0CCE
                    pshs      x
                    lbsr      StrCat
                    leas      4,s
                    lbsr      DwCmdSend
                    lbra      DevMenuExit
* SendSynProfCmd: if saved profile name at >$03B8 is non-empty: strcpy(cmd,"dw mid syn pro "), strncat(cmd, name, 10), strcat "\r", DwCmdSend
SendSynProfCmd      pshs      u
                    ldb       >UmeData_reserved_03B8
                    beq       a2@
                    leax      >strDwMidSynPro,pcr
                    pshs      x
                    ldx       #$0CCE
                    pshs      x
                    lbsr      StrCpy
                    leas      4,s
                    ldd       #$000A
                    pshs      a,b
                    ldx       #$03B8
                    pshs      x
                    ldx       #$0CCE
                    pshs      x
                    lbsr      StrNCat
                    leas      6,s
                    leax      >strCR2,pcr
                    pshs      x
                    ldx       #$0CCE
                    pshs      x
                    lbsr      StrCat
                    leas      4,s
                    lbsr      DwCmdSend
a2@                 puls      u,pc
* DevSelectMenu: 'd': sets the refresh flags; bails if DP $51 is 0; WinDefine(1,184,78,24,0,
* WinStylePaper3D), putchar(12), clears the 24 line buffers, runs "dw mid sta" via
* DwCmdGetLines, prints the lines, then DevPromptPick.
DevSelectMenu       pshs      u
                    leas      -1,s
                    ldd       #$0001
                    stb       <UmeData_rfr_scr
                    stb       <UmeData_rfr_bar
                    ldb       <UmeData_reserved_0051
                    lbeq      DevMenuExit
                    ldd       #WinStylePaper3D    the paper 3D box
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0018
                    pshs      a,b
                    ldd       #$004E
                    pshs      a,b
                    ldd       #$00B8
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    lbsr      WinDefine
                    leas      12,s
                    ldd       #$000C
                    pshs      a,b
                    jsr       [>UmeData_pputchar]
                    leas      2,s
                    jsr       [>UmeData_pflush]
                    ldd       #$0001
                    pshs      a,b
                    lbsr      WinCtlCC
                    leas      2,s
                    clra
                    clrb
                    bra       DevClrLoop
* DevClrLineBody: Body of DevSelectMenu's clear loop: MemClear(lines[i],80), i++; DevClrLoop blt's back here
DevClrLineBody      ldd       #$0050
                    pshs      a,b
                    ldd       >UmeData_reserved_0E4F
                    pshs      a,b
                    ldd       #$0050
                    lbsr      MulInt16
                    ldx       #$0E5B
                    leax      d,x
                    pshs      x
                    lbsr      MemClear
                    leas      4,s
                    ldd       >UmeData_reserved_0E4F
                    addd      #$0001
* DevClrLoop: loop test i<24 for MemClear(lines[i],80) before the dw mid sta capture
DevClrLoop          std       >UmeData_reserved_0E4F
                    ldd       >UmeData_reserved_0E4F
                    cmpd      #$0018
                    blt       DevClrLineBody
                    ldd       #$0080
                    pshs      a,b
                    ldx       #$0CCE
                    pshs      x
                    lbsr      MemClear
                    leas      4,s
                    leax      >strDwMidSta,pcr
                    pshs      x
                    ldx       #$0CCE
                    pshs      x
                    lbsr      StrCpy
                    leas      4,s
                    lbsr      DwCmdGetLines
                    lbeq      DevMenuFail
                    clra
                    clrb
                    bra       DevListLoop
* DevPrintLine: list loop body: stops when lines[0][0]==0 or status==2, else printf("%s", lines[i]).
DevPrintLine        ldb       >UmeData_reserved_0E5B
                    beq       a3@
                    ldd       >UmeData_reserved_0E4D
                    cmpd      #$0002
                    bne       b3@
a3@                 ldd       >UmeData_reserved_0E4F
                    std       >UmeData_reserved_0E51
                    bra       DevPromptPick
b3@                 ldd       >UmeData_reserved_0E4F
                    pshs      a,b
                    ldd       #$0050
                    lbsr      MulInt16
                    ldx       #$0E5B
                    leax      d,x
* A device's second, indented detail line is not shown: one row per device keeps the list
* inside the 24-row window.
                    lda       ,x
                    cmpa      #$20
                    beq       c3@
                    pshs      x
                    leax      >fmtStr,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    jsr       [>UmeData_pflush]
c3@                 ldd       >UmeData_reserved_0E4F
                    addd      #$0001
* DevListLoop: loop test i<linecount for DevPrintLine
DevListLoop         std       >UmeData_reserved_0E4F
                    ldd       >UmeData_reserved_0E4F
                    cmpd      >UmeData_reserved_0E51
                    blt       DevPrintLine
* DevPromptPick: putchar(13), msgClickOrType, menu picker (1,184,78,1,1,(n-1)/2+1,1); a
* negative result is a typed key (negated), else a row index into tblProfPickDigit.
DevPromptPick       ldd       #$000D
                    pshs      a,b
                    jsr       [>UmeData_pputchar]
                    leas      2,s
                    leax      >msgClickOrType,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       >UmeData_reserved_0E51
                    addd      #$FFFF
                    pshs      a,b
                    ldd       #$0002
                    lbsr      DivInt16
                    addd      #$0001              the header row and one row per device
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$004E
                    pshs      a,b
                    ldd       #$00B8
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    jsr       [>UmeData_ptextmen]
                    leas      14,s
                    stb       ,s
                    bge       DevClickToDigit
                    ldb       ,s
                    sex
                    nega
                    negb
                    sbca      #$00
                    bra       DevPickedChar
* DevClickToDigit: click row -> character: one screen row per device, so the profile list's
* table (row 0 the header's CR, then 0..F) serves here too.
DevClickToDigit     leax      >tblProfPickDigit,pcr
                    tfr       x,d
                    pshs      a,b
                    ldb       2,s
                    sex
                    addd      ,s++
                    tfr       d,x
                    ldb       ,x
* DevPickedChar: Join of typed-key and click-row arms in DevPromptPick: stores picked char, then DevCheckDigit
DevPickedChar       stb       ,s
                    ldb       ,s
                    sex
                    tfr       d,x
                    lbra      DevCheckDigit
* DevDigitPicked: valid hex digit chosen: save it in >$03B7, convert to 0..15, reject if >= (linecount-1)/2, build "dw mid out N\r" (IntToStr called without buffer arg) and DwCmdSend
DevDigitPicked      ldd       #$0080
                    pshs      a,b
                    ldx       #$0CCE
                    pshs      x
                    lbsr      MemClear
                    leas      4,s
                    ldb       ,s
                    stb       >UmeData_reserved_03B7
                    ldb       ,s
                    cmpb      #$39
                    ble       a4@
                    ldb       ,s
                    sex
                    addd      #$FFF9
                    stb       ,s
a4@                 ldb       ,s
                    sex
                    addd      #$FFD0
                    stb       ,s
                    sex
                    pshs      a,b
                    ldd       >UmeData_reserved_0E51
                    addd      #$FFFF
                    pshs      a,b
                    ldd       #$0002
                    lbsr      DivInt16
                    cmpd      ,s++
                    ble       DevMenuDone
                    leax      >strDwMidOut2,pcr
                    pshs      x
                    ldx       #$0CCE
                    pshs      x
                    lbsr      StrCpy
                    leas      4,s
                    ldb       ,s
                    sex
                    pshs      a,b
                    lbsr      IntToStr
                    std       ,s
                    ldx       #$0CCE
                    pshs      x
                    lbsr      StrCat
                    leas      4,s
                    leax      >strCR3,pcr
                    pshs      x
                    ldx       #$0CCE
                    pshs      x
                    lbsr      StrCat
                    leas      4,s
                    lbsr      DwCmdSend
                    bne       DevShowReply
* DevMenuFail: capture or send failed: WinEnd and return
DevMenuFail         lbsr      WinEnd
                    lbra      DevMenuExit
* DevShowReply: flush, printf("\r%s\r", replybuf), wait for ENTER/click.
DevShowReply        jsr       [>UmeData_pflush]
                    ldx       #$0D4E
                    pshs      x
                    leax      >fmtReplyLine,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    jsr       [>UmeData_phit]
* DevMenuDone: normal exit: WinEnd, WinCtl90, return
DevMenuDone         lbsr      WinEnd
                    lbsr      WinCtl90
                    bra       DevMenuExit
* DevCheckDigit: cmpx chain accepting '0'..'9','A'..'F' -> DevDigitPicked, anything else -> DevMenuDone
DevCheckDigit       cmpx      #$0030
                    lbeq      DevDigitPicked
                    cmpx      #$0031
                    lbeq      DevDigitPicked
                    cmpx      #$0032
                    lbeq      DevDigitPicked
                    cmpx      #$0033
                    lbeq      DevDigitPicked
                    cmpx      #$0034
                    lbeq      DevDigitPicked
                    cmpx      #$0035
                    lbeq      DevDigitPicked
                    cmpx      #$0036
                    lbeq      DevDigitPicked
                    cmpx      #$0037
                    lbeq      DevDigitPicked
                    cmpx      #$0038
                    lbeq      DevDigitPicked
                    cmpx      #$0039
                    lbeq      DevDigitPicked
                    cmpx      #$0041
                    lbeq      DevDigitPicked
                    cmpx      #$0042
                    lbeq      DevDigitPicked
                    cmpx      #$0043
                    lbeq      DevDigitPicked
                    cmpx      #$0044
                    lbeq      DevDigitPicked
                    cmpx      #$0045
                    lbeq      DevDigitPicked
                    cmpx      #$0046
                    lbeq      DevDigitPicked
                    bra       DevMenuDone
* DevMenuExit: frame exit of DevSelectMenu (leas 1,s; puls u,pc), also used by SendMidiOutCmd
DevMenuExit         leas      1,s
                    puls      u,pc
* ProfSelectMenu: 'p': same window setup as DevSelectMenu, runs "dw mid syn sho pro" via
* DwCmdGetLines, prints msgSelectProfile and each line as "[%02d] %s", then ProfPromptPick.
* Frame: ,s the picked character, 1,s a 50-byte line buffer.
ProfSelectMenu      pshs      u
                    leas      <-$33,s
                    ldd       #$0001
                    stb       <UmeData_rfr_scr
                    stb       <UmeData_rfr_bar
                    ldb       <UmeData_reserved_0051
                    lbeq      ProfMenuExit
                    ldd       #WinStylePaper3D    the paper 3D box
                    pshs      a,b
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0018
                    pshs      a,b
                    ldd       #$004E
                    pshs      a,b
                    ldd       #$00B8
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    lbsr      WinDefine
                    leas      12,s
                    ldd       #$000C
                    pshs      a,b
                    jsr       [>UmeData_pputchar]
                    leas      2,s
                    jsr       [>UmeData_pflush]
                    ldd       #$0001
                    pshs      a,b
                    lbsr      WinCtlCC
                    leas      2,s
                    clra
                    clrb
                    bra       ProfClrLoop
* ProfClrLineBody: Body of ProfSelectMenu's clear loop: MemClear(lines[i],80), i++; ProfClrLoop blt's back here
ProfClrLineBody     ldd       #$0050
                    pshs      a,b
                    ldd       >UmeData_reserved_0E4F
                    pshs      a,b
                    ldd       #$0050
                    lbsr      MulInt16
                    ldx       #$0E5B
                    leax      d,x
                    pshs      x
                    lbsr      MemClear
                    leas      4,s
                    ldd       >UmeData_reserved_0E4F
                    addd      #$0001
* ProfClrLoop: loop test i<24 for MemClear(lines[i],80) before the profile capture
ProfClrLoop         std       >UmeData_reserved_0E4F
                    ldd       >UmeData_reserved_0E4F
                    cmpd      #$0018
                    blt       ProfClrLineBody
                    ldd       #$0080
                    pshs      a,b
                    ldx       #$0CCE
                    pshs      x
                    lbsr      MemClear
                    leas      4,s
                    leax      >strDwSynShoPro,pcr
                    pshs      x
                    ldx       #$0CCE
                    pshs      x
                    lbsr      StrCpy
                    leas      4,s
                    lbsr      DwCmdGetLines
                    lbeq      ProfMenuFail
                    leax      >msgSelectProfile,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    clra
                    clrb
                    lbra      ProfListLoop
* ProfPrintLine: list loop body: stops at 24 lines, empty lines[0] or status==2, else formats and prints the profile line
ProfPrintLine       ldd       >UmeData_reserved_0E4F
                    cmpd      #$0018
                    lbge      ProfPromptPick
                    ldb       >UmeData_reserved_0E5B
                    beq       a5@
                    ldd       >UmeData_reserved_0E4D
                    cmpd      #$0002
                    bne       ProfFormatLine
a5@                 ldd       >UmeData_reserved_0E4F
                    std       >UmeData_reserved_0E51
                    lbra      ProfPromptPick
* ProfFormatLine: MemClear(local 50-byte name), strncpy(name, lines[i], 48), strncat "\r", printf("[%02d] %s", i, name)
ProfFormatLine      ldd       #$0032
                    pshs      a,b
                    leax      3,s
                    pshs      x
                    lbsr      MemClear
                    leas      4,s
                    ldd       #$0030
                    pshs      a,b
                    ldd       >UmeData_reserved_0E4F
                    pshs      a,b
                    ldd       #$0050
                    lbsr      MulInt16
                    ldx       #$0E5B
                    leax      d,x
                    pshs      x
                    leax      5,s
                    pshs      x
                    lbsr      StrNCpy
                    leas      6,s
                    ldd       #$0001
                    pshs      a,b
                    leax      >strCR4,pcr
                    pshs      x
                    leax      5,s
                    pshs      x
                    lbsr      StrNCat
                    leas      6,s
                    ldd       >UmeData_reserved_0E4F
                    cmpd      >UmeData_reserved_0E51
                    bge       a6@
                    leax      1,s
                    pshs      x
                    ldd       >UmeData_reserved_0E4F
                    pshs      a,b
                    leax      >fmtProfItem,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      6,s
                    bra       b6@
a6@                 leax      1,s
                    pshs      x
                    leax      >fmtProfPlain,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      4,s
b6@                 jsr       [>UmeData_pflush]
                    ldd       >UmeData_reserved_0E4F
                    addd      #$0001
* ProfListLoop: loop test i<linecount for ProfPrintLine
ProfListLoop        std       >UmeData_reserved_0E4F
                    ldd       >UmeData_reserved_0E4F
                    cmpd      >UmeData_reserved_0E51
                    lblt      ProfPrintLine
* ProfPromptPick: putchar(13), msgClickOrType2, menu picker (1,184,78,1,2,linecount,1);
* negative = typed key, else a row into tblProfPickDigit.
ProfPromptPick      ldd       #$000D
                    pshs      a,b
                    jsr       [>UmeData_pputchar]
                    leas      2,s
                    leax      >msgClickOrType2,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    ldd       #$0001
                    pshs      a,b
                    ldd       >UmeData_reserved_0E51
                    pshs      a,b
                    ldd       #$0002
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    ldd       #$004E
                    pshs      a,b
                    ldd       #$00B8
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    jsr       [>UmeData_ptextmen]
                    leas      14,s
                    stb       ,s
                    bge       ProfClickToDigit
                    ldb       ,s
                    sex
                    nega
                    negb
                    sbca      #$00
                    bra       ProfPickedChar
* ProfClickToDigit: click row -> character via tblProfPickDigit (one row per profile)
ProfClickToDigit    leax      >tblProfPickDigit,pcr
                    tfr       x,d
                    pshs      a,b
                    ldb       2,s
                    sex
                    addd      ,s++
                    tfr       d,x
                    ldb       ,x
* ProfPickedChar: Join of typed-key and click-row arms in ProfPromptPick: stores picked char, then ProfCheckDigit
ProfPickedChar      stb       ,s
                    ldb       ,s
                    sex
                    tfr       d,x
                    lbra      ProfCheckDigit
* ProfDigitPicked: valid hex digit: n = 0..15, reject if n >= linecount, strcpy "dw mid syn pro ", strncat(lines[n],10), strcat "\r", strncpy(>$03B8, lines[n], 10), DwCmdSend
ProfDigitPicked     ldd       #$0080
                    pshs      a,b
                    ldx       #$0CCE
                    pshs      x
                    lbsr      MemClear
                    leas      4,s
                    ldb       ,s
                    cmpb      #$39
                    ble       a7@
                    ldb       ,s
                    sex
                    addd      #$FFF9
                    stb       ,s
a7@                 ldb       ,s
                    sex
                    addd      #$FFD0
                    stb       ,s
                    sex
                    cmpd      >UmeData_reserved_0E51
                    lbge      ProfMenuDone
                    leax      >strDwMidSynPro2,pcr
                    pshs      x
                    ldx       #$0CCE
                    pshs      x
                    lbsr      StrCpy
                    leas      4,s
                    ldd       #$000A
                    pshs      a,b
                    ldb       2,s
                    sex
                    pshs      a,b
                    ldd       #$0050
                    lbsr      MulInt16
                    ldx       #$0E5B
                    leax      d,x
                    pshs      x
                    ldx       #$0CCE
                    pshs      x
                    lbsr      StrNCat
                    leas      6,s
                    leax      >strCR5,pcr
                    pshs      x
                    ldx       #$0CCE
                    pshs      x
                    lbsr      StrCat
                    leas      4,s
                    ldd       #$000A
                    pshs      a,b
                    ldb       2,s
                    sex
                    pshs      a,b
                    ldd       #$0050
                    lbsr      MulInt16
                    ldx       #$0E5B
                    leax      d,x
                    pshs      x
                    ldx       #$03B8
                    pshs      x
                    lbsr      StrNCpy
                    leas      6,s
                    lbsr      DwCmdSend
                    bne       ProfShowReply
* ProfMenuFail: capture or send failed: WinEnd and return
ProfMenuFail        lbsr      WinEnd
                    lbra      ProfMenuExit
* ProfShowReply: flush, printf("\r%s\r", replybuf), wait for ENTER/click.
ProfShowReply       jsr       [>UmeData_pflush]
                    ldx       #$0D4E
                    pshs      x
                    leax      >fmtReplyLine2,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    jsr       [>UmeData_phit]
* ProfMenuDone: normal exit: WinEnd, WinCtl90, return
ProfMenuDone        lbsr      WinEnd
                    lbsr      WinCtl90
                    bra       ProfMenuExit
* ProfCheckDigit: cmpx chain accepting '0'..'9','A'..'F' -> ProfDigitPicked, else ProfMenuDone
ProfCheckDigit      cmpx      #$0030
                    lbeq      ProfDigitPicked
                    cmpx      #$0031
                    lbeq      ProfDigitPicked
                    cmpx      #$0032
                    lbeq      ProfDigitPicked
                    cmpx      #$0033
                    lbeq      ProfDigitPicked
                    cmpx      #$0034
                    lbeq      ProfDigitPicked
                    cmpx      #$0035
                    lbeq      ProfDigitPicked
                    cmpx      #$0036
                    lbeq      ProfDigitPicked
                    cmpx      #$0037
                    lbeq      ProfDigitPicked
                    cmpx      #$0038
                    lbeq      ProfDigitPicked
                    cmpx      #$0039
                    lbeq      ProfDigitPicked
                    cmpx      #$0041
                    lbeq      ProfDigitPicked
                    cmpx      #$0042
                    lbeq      ProfDigitPicked
                    cmpx      #$0043
                    lbeq      ProfDigitPicked
                    cmpx      #$0044
                    lbeq      ProfDigitPicked
                    cmpx      #$0045
                    lbeq      ProfDigitPicked
                    cmpx      #$0046
                    lbeq      ProfDigitPicked
                    bra       ProfMenuDone
* ProfMenuExit: frame exit of ProfSelectMenu (leas $33,s; puls u,pc)
ProfMenuExit        leas      <$33,s
                    puls      u,pc
* SetPathRaw: Os9Call(I$GetStt, SS.Opt) on the /N path into a 128-byte local, zeroes option
* bytes 1..17 (echo, auto-LF, pause, EOR, EOF, interrupt/quit chars), Os9Call(I$SetStt, SS.Opt).
SetPathRaw          pshs      u
                    leas      >-$0082,s
                    ldd       >UmeData_reserved_0E59
                    stb       >$15DC
                    clra
                    clrb
                    stb       >$15DD
                    leax      ,s
                    stx       >$15DF
                    ldx       #$15DB
                    pshs      x
                    ldd       #$008D
                    pshs      a,b
                    lbsr      Os9Call
                    leas      4,s
                    ldd       #$0001
                    bra       RawOptLoop
* RawOptClrByte: Body of SetPathRaw's loop: zeroes SS.Opt byte i and bumps i; RawOptLoop ble's back here
RawOptClrByte       ldd       >$0080,s
                    leax      ,s
                    leax      d,x
                    clra
                    clrb
                    stb       ,x
                    ldd       >$0080,s
                    addd      #$0001
* RawOptLoop: loop test i<=17 zeroing the SS.Opt bytes
RawOptLoop          std       >$0080,s
                    ldd       >$0080,s
                    cmpd      #$0011
                    ble       RawOptClrByte
                    ldd       >UmeData_reserved_0E59
                    stb       >$15DC
                    clra
                    clrb
                    stb       >$15DD
                    leax      ,s
                    stx       >$15DF
                    ldx       #$15DB
                    pshs      x
                    ldd       #$008E
                    pshs      a,b
                    lbsr      Os9Call
                    leas      4,s
                    leas      >$0082,s
                    puls      u,pc
* DwCmdGetLines: OpenPath("/N",3) -> >$0E59 (error: alert msgDwOpenErr with errno, return 0);
* sends the command in >$0CCE and captures the reply into the 24x80 line array at >$0E5B;
* returns 1 unless status==2.
DwCmdGetLines       pshs      u
                    leas      -3,s
                    ldd       #$0003
                    pshs      a,b
                    leax      >pathDwSerial,pcr
                    pshs      x
                    lbsr      OpenPath
                    leas      4,s
                    std       >UmeData_reserved_0E59
                    bge       DwCapSendCmd
                    ldd       >UmeData_c_errno
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    leax      >msgDwOpenErr,pcr
                    pshs      x
                    jsr       [>UmeData_palert]
                    leas      6,s
                    lbra      DwCapExit
* DwCapSendCmd: Intercept(SigHandler), zero status/counters, SetPathRaw, WritePath(cmd),
* read the first reply byte: 'F' -> msgCmdFailed + wait + close + return 0.
DwCapSendCmd        leax      >SigHandler,pcr
                    pshs      x
                    lbsr      Intercept
                    leas      2,s
                    clra
                    clrb
                    std       >UmeData_reserved_0E4D
                    clra
                    clrb
                    std       >UmeData_reserved_0E57
                    clra
                    clrb
                    std       >UmeData_reserved_0E4F
                    clra
                    clrb
                    std       >UmeData_reserved_0E51
                    clra
                    clrb
                    std       >UmeData_reserved_0E53
                    clra
                    clrb
                    std       ,s
                    lbsr      SetPathRaw
                    ldx       #$0CCE
                    pshs      x
                    lbsr      StrLen
                    std       ,s
                    ldx       #$0CCE
                    pshs      x
                    ldd       >UmeData_reserved_0E59
                    pshs      a,b
                    lbsr      WritePath
                    leas      6,s
                    ldd       #$00FF
                    pshs      a,b
                    ldx       #$0D4E
                    pshs      x
                    lbsr      MemClear
                    leas      4,s
                    ldd       #$0001
                    pshs      a,b
                    ldx       #$0D4E
                    pshs      x
                    ldd       >UmeData_reserved_0E59
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    ldb       >UmeData_reserved_0D4E
                    cmpb      #$46
                    bne       a8@
                    leax      >msgCmdFailed,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    jsr       [>UmeData_phit]
                    ldd       >UmeData_reserved_0E59
                    pshs      a,b
                    lbsr      ClosePath
                    leas      2,s
                    lbra      DwCapRetZero
a8@                 ldb       >UmeData_reserved_0D4E
                    cmpb      #$4F
                    lbne      DwCapLoopTest
* DwCapSkipOkLine: after an 'O' (OK) byte, read one byte at a time until CR or LF.
DwCapSkipOkLine     ldd       #$0001
                    pshs      a,b
                    ldx       #$0D4E
                    pshs      x
                    ldd       >UmeData_reserved_0E59
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    ldb       >UmeData_reserved_0D4E
                    cmpb      #$0D
                    lbeq      DwCapLoopTest
                    cmpb      #$0A                an LF ends the OK line too
                    bne       DwCapSkipOkLine
                    lbra      DwCapLoopTest
* DwCapPoll: Os9Call(I$GetStt, SS.Ready) on the DW path: E$NotRdy ($F6) -> TSleep(1) and retry, other error -> status 2, else bytes-ready -> >$0E55
DwCapPoll           ldd       >UmeData_reserved_0E59
                    stb       >$15DC
                    ldd       #$0001
                    stb       >$15DD
                    ldx       #$15DB
                    pshs      x
                    ldd       #$008D
                    pshs      a,b
                    lbsr      Os9Call
                    leas      4,s
                    std       -2,s
                    beq       DwCapReadChunk
                    ldb       >$15DD
                    sex
                    cmpd      #$FFF6
                    bne       a9@
                    ldd       #$0001
                    pshs      a,b
                    lbsr      TSleep
                    leas      2,s
                    lbra      DwCapLoopTest
a9@                 ldd       #$0002
                    std       >UmeData_reserved_0E4D
                    lbra      DwCapLoopTest
* DwCapReadChunk: bytes ready <=0 -> status 1; else MemClear(replybuf,255), ReadPath(path,replybuf,n) -> >$0E57, 0 read -> status 1
DwCapReadChunk      ldb       >$15DD
                    clra
                    std       >UmeData_reserved_0E55
                    lble      DwCapNoData
                    ldd       #$00FF
                    pshs      a,b
                    ldx       #$0D4E
                    pshs      x
                    lbsr      MemClear
                    leas      4,s
                    ldd       >UmeData_reserved_0E55
                    pshs      a,b
                    ldx       #$0D4E
                    pshs      x
                    ldd       >UmeData_reserved_0E59
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    std       >UmeData_reserved_0E57
                    bne       DwCapScanStart
* DwCapFinish: status = 1 (capture complete) and back to DwCapLoopTest
DwCapFinish         ldd       #$0001
                    std       >UmeData_reserved_0E4D
                    lbra      DwCapLoopTest
* DwCapScanStart: DwCapReadChunk bne's here when bytes were read: i=0 then into the DwCapCharLoop per-byte scan
DwCapScanStart      clra
                    clrb
                    lbra      DwCapCharLoop
* DwCapStoreChar: per-byte loop: stop at 24 lines, store the char at lines[line][col]; CR
* ends a line (empty lines ignored, first line dropped as header, later lines bump the count).
DwCapStoreChar      ldd       >UmeData_reserved_0E51
                    cmpd      #$0018
                    bge       DwCapFinish
                    ldd       >UmeData_reserved_0E4F
                    ldx       #$0D4E
                    leax      d,x
                    ldb       ,x
* An LF is made a CR in the buffer, so CR, LF and CRLF all end a line; the LF of a CRLF
* then meets an empty line, which is ignored.
                    cmpb      #$0A
                    bne       dwcs1@
                    ldb       #$0D
                    stb       ,x
dwcs1@              ldd       >UmeData_reserved_0E51
                    pshs      a,b
                    ldd       #$0050
                    lbsr      MulInt16
                    ldx       #$0E5B
                    leax      d,x
                    ldd       >UmeData_reserved_0E53
                    leax      d,x
                    pshs      x
                    ldd       >UmeData_reserved_0E4F
                    ldx       #$0D4E
                    leax      d,x
                    ldb       ,x
                    stb       [,s++]
                    ldd       >UmeData_reserved_0E4F
                    ldx       #$0D4E
                    leax      d,x
                    ldb       ,x
                    cmpb      #$0D
                    bne       DwCapBumpCol
                    ldd       >UmeData_reserved_0E53
                    beq       DwCapNextChar
                    clra
                    clrb
                    std       >UmeData_reserved_0E53
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    cmpd      #$0002
                    blt       DwCapDropHeader
                    ldd       >UmeData_reserved_0E51
                    addd      #$0001
                    std       >UmeData_reserved_0E51
                    bra       DwCapNextChar
* DwCapDropHeader: first CR-terminated line is the command header: MemClear(lines[line],80) instead of keeping it
DwCapDropHeader     ldd       #$0050
                    pshs      a,b
                    ldd       >UmeData_reserved_0E51
                    pshs      a,b
                    ldd       #$0050
                    lbsr      MulInt16
                    ldx       #$0E5B
                    leax      d,x
                    pshs      x
                    lbsr      MemClear
                    leas      4,s
                    bra       DwCapNextChar
* DwCapBumpCol: Non-CR char in DwCapStoreChar (bne): col++ then falls into DwCapNextChar
DwCapBumpCol        ldd       >UmeData_reserved_0E53
* The column stops at 79: a line that never sees its CR or LF keeps overwriting its last
* byte instead of running out of its 80-byte slot into the data after the 24 lines.
                    cmpd      #$004F
                    bhs       DwCapNextChar
                    addd      #$0001
                    std       >UmeData_reserved_0E53
* DwCapNextChar: shared continue of DwCapStoreChar: i++ then the DwCapCharLoop test.
DwCapNextChar       ldd       >UmeData_reserved_0E4F
                    addd      #$0001
* DwCapCharLoop: loop test i < bytes read for DwCapStoreChar
DwCapCharLoop       std       >UmeData_reserved_0E4F
                    ldd       >UmeData_reserved_0E4F
                    cmpd      >UmeData_reserved_0E57
                    lblt      DwCapStoreChar
                    bra       DwCapLoopTest
* DwCapNoData: DwCapReadChunk lble's here when SS.Ready is <=0: status=1 and straight to DwCapClose
DwCapNoData         ldd       #$0001
                    std       >UmeData_reserved_0E4D
                    bra       DwCapClose
* DwCapLoopTest: while status==0 go back to DwCapPoll
DwCapLoopTest       ldd       >UmeData_reserved_0E4D
                    lbeq      DwCapPoll
* DwCapClose: ClosePath(DW path); return status==2 ? 0 : 1
DwCapClose          ldd       >UmeData_reserved_0E59
                    pshs      a,b
                    lbsr      ClosePath
                    leas      2,s
                    ldd       >UmeData_reserved_0E4D
                    cmpd      #$0002
                    bne       a10@
* DwCapRetZero: Return 0 from DwCmdGetLines: 'Command Failed' path lbra's here, status==2 falls in; then DwCapExit
DwCapRetZero        clra
                    clrb
                    bra       DwCapExit
a10@                ldd       #$0001
* DwCapExit: frame exit of DwCmdGetLines (leas 3,s; puls u,pc)
DwCapExit           leas      3,s
                    puls      u,pc
* DwCmdSend: OpenPath("/N",3), Intercept, SetPathRaw, WritePath(cmd); first byte 'F' ->
* msgCmdFailed2 + wait + close + return 0; 'O' -> skip the OK line; then poll and read
* until a CR or LF arrives in replybuf. Returns 1 unless status==2.
DwCmdSend           pshs      u
                    ldd       #$0003
                    pshs      a,b
                    leax      >pathDwSerial2,pcr
                    pshs      x
                    lbsr      OpenPath
                    leas      4,s
                    std       >UmeData_reserved_0E59
                    bge       DwSendBody
                    ldd       >UmeData_c_errno
                    pshs      a,b
                    ldd       #$0001
                    pshs      a,b
                    leax      >msgDwOpenErr2,pcr
                    pshs      x
                    jsr       [>UmeData_palert]
                    lbra      Pop6ArgsRet
* DwSendBody: path opened: install SigHandler, zero status/counters, raw mode, write the command, read the first reply byte
DwSendBody          leax      >SigHandler,pcr
                    pshs      x
                    lbsr      Intercept
                    leas      2,s
                    clra
                    clrb
                    std       >UmeData_reserved_0E4D
                    clra
                    clrb
                    std       >UmeData_reserved_0E57
                    clra
                    clrb
                    std       >UmeData_reserved_0E4F
                    clra
                    clrb
                    std       >UmeData_reserved_0E51
                    clra
                    clrb
                    std       >UmeData_reserved_0E53
                    lbsr      SetPathRaw
                    ldx       #$0CCE
                    pshs      x
                    lbsr      StrLen
                    std       ,s
                    ldx       #$0CCE
                    pshs      x
                    ldd       >UmeData_reserved_0E59
                    pshs      a,b
                    lbsr      WritePath
                    leas      6,s
                    ldd       #$00FF
                    pshs      a,b
                    ldx       #$0D4E
                    pshs      x
                    lbsr      MemClear
                    leas      4,s
                    ldd       #$0001
                    pshs      a,b
                    ldx       #$0D4E
                    pshs      x
                    ldd       >UmeData_reserved_0E59
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    ldb       >UmeData_reserved_0D4E
                    cmpb      #$46
                    bne       a11@
                    leax      >msgCmdFailed2,pcr
                    pshs      x
                    jsr       [>UmeData_pprintf]
                    leas      2,s
                    jsr       [>UmeData_phit]
                    ldd       >UmeData_reserved_0E59
                    pshs      a,b
                    lbsr      ClosePath
                    leas      2,s
                    lbra      DwSendFail
a11@                ldb       >UmeData_reserved_0D4E
                    cmpb      #$4F
                    lbne      DwSendLoopTest
* DwSendSkipOkLine: after 'O', read single bytes until CR or LF.
DwSendSkipOkLine    ldd       #$0001
                    pshs      a,b
                    ldx       #$0D4E
                    pshs      x
                    ldd       >UmeData_reserved_0E59
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    ldb       >UmeData_reserved_0D4E
                    cmpb      #$0D
                    lbeq      DwSendLoopTest
                    cmpb      #$0A                an LF ends the OK line too
                    bne       DwSendSkipOkLine
                    lbra      DwSendLoopTest
* DwSendPoll: I$GetStt SS.Ready via Os9Call; E$NotRdy -> TSleep(1) and retry, other error -> status 2
DwSendPoll          ldd       >UmeData_reserved_0E59
                    stb       >$15DC
                    ldd       #$0001
                    stb       >$15DD
                    ldx       #$15DB
                    pshs      x
                    ldd       #$008D
                    pshs      a,b
                    lbsr      Os9Call
                    leas      4,s
                    std       -2,s
                    beq       DwSendReadChunk
                    ldb       >$15DD
                    sex
                    cmpd      #$FFF6
                    bne       a12@
                    ldd       #$0001
                    pshs      a,b
                    lbsr      TSleep
                    leas      2,s
                    lbra      DwSendLoopTest
a12@                ldd       #$0002
                    std       >UmeData_reserved_0E4D
                    lbra      DwSendLoopTest
* DwSendReadChunk: bytes ready <=0 -> status 1; else clear replybuf and ReadPath n bytes -> >$0E57
DwSendReadChunk     ldb       >$15DD
                    clra
                    std       >UmeData_reserved_0E55
                    lble      DwSendNoData
                    ldd       #$00FF
                    pshs      a,b
                    ldx       #$0D4E
                    pshs      x
                    lbsr      MemClear
                    leas      4,s
                    ldd       >UmeData_reserved_0E55
                    pshs      a,b
                    ldx       #$0D4E
                    pshs      x
                    ldd       >UmeData_reserved_0E59
                    pshs      a,b
                    lbsr      ReadPath
                    leas      6,s
                    std       >UmeData_reserved_0E57
                    bne       DwSendScanStart
* DwSendGotLine: CR or LF seen (or nothing read): status = 1, reply line complete
DwSendGotLine       ldd       #$0001
                    std       >UmeData_reserved_0E4D
                    bra       DwSendLoopTest
* DwSendScanStart: DwSendReadChunk bne's here when bytes were read: i=0 then into the DwSendScanLoop test
DwSendScanStart     clra
                    clrb
                    bra       DwSendScanLoop
* DwSendScanChar: scan the chunk: CR or LF -> DwSendGotLine
DwSendScanChar      ldd       >UmeData_reserved_0E4F
                    ldx       #$0D4E
                    leax      d,x
                    ldb       ,x
                    cmpb      #$0A                CR, LF or CRLF ends the line
                    beq       DwSendGotLine
                    ldd       >UmeData_reserved_0E4F
                    ldx       #$0D4E
                    leax      d,x
                    ldb       ,x
                    cmpb      #$0D
                    beq       DwSendGotLine
a13@                ldd       >UmeData_reserved_0E4F
                    addd      #$0001
* DwSendScanLoop: loop test i < bytes read for DwSendScanChar
DwSendScanLoop      std       >UmeData_reserved_0E4F
                    ldd       >UmeData_reserved_0E4F
                    cmpd      >UmeData_reserved_0E57
                    blt       DwSendScanChar
                    bra       DwSendLoopTest
* DwSendNoData: DwSendReadChunk lble's here when SS.Ready is <=0: status=1 and on to DwSendClose
DwSendNoData        ldd       #$0001
                    std       >UmeData_reserved_0E4D
                    bra       DwSendClose
* DwSendLoopTest: while status==0 go back to DwSendPoll
DwSendLoopTest      ldd       >UmeData_reserved_0E4D
                    lbeq      DwSendPoll
* DwSendClose: ClosePath(DW path); status==2 -> DwSendFail else DwSendOk
DwSendClose         ldd       >UmeData_reserved_0E59
                    pshs      a,b
                    lbsr      ClosePath
                    leas      2,s
                    ldd       >UmeData_reserved_0E4D
                    cmpd      #$0002
                    bne       DwSendOk
* DwSendFail: return 0 from DwCmdSend
DwSendFail          clra
                    clrb
                    puls      u,pc
* DwSendOk: return 1 from DwCmdSend
DwSendOk            ldd       #$0001
                    puls      u,pc
                    fcb       $35,$C0
* WinDefine: printf(fmt at DP $14, $C6, a1..a4, (char)a5, a6) then flush - s9's window-define
* code; called with (1,184,78,24,0,WinStylePaper3D).
WinDefine           pshs      u
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
* WinEnd: printf(fmt at DP $16, $C7) - s9's window-close code, called on every menu exit.
WinEnd              pshs      u
                    ldd       #$00C7
                    pshs      a,b
                    ldd       <UmeData_reserved_0016
                    pshs      a,b
                    jsr       [>UmeData_pprintf]
                    leas      4,s
                    puls      u,pc
* WinCtlCC: printf(fmt at DP $18, $CC, (char)arg) - control code $CC, issued with 1 when each menu opens.
WinCtlCC            pshs      u
                    ldb       5,s
                    sex
                    pshs      a,b
                    ldd       #$00CC
                    pshs      a,b
                    ldd       <UmeData_reserved_0018
                    bra       WinCtlPrintf
* WinCtl90: printf(fmt at DP $0A, $90, 0) - control code $90, issued after a menu selection completes.
WinCtl90            pshs      u
                    clra
                    clrb
                    pshs      a,b
                    ldd       #$0090
                    pshs      a,b
                    ldd       <UmeData_reserved_000A
* WinCtlPrintf: shared printf tail of WinCtlCC (bra) and WinCtl90 (fall-in).
WinCtlPrintf        pshs      a,b
                    jsr       [>UmeData_pprintf]
* Pop6ArgsRet: shared epilogue leas 6,s; puls u,pc: WinCtl90 falls in, DwCmdSend's open-error path lbra's here.
Pop6ArgsRet         leas      6,s
                    puls      u,pc
                    fcb       $34,$40,$CC,$00,$02,$34,$06,$CC
                    fcb       $00,$01,$34,$06,$CC,$00,$0A,$34
                    fcb       $06,$CC,$00,$28,$34,$06,$CC,$00
                    fcb       $0A,$34,$06,$CC,$00,$14,$34,$06
                    fcb       $17,$FF
                    fcc       /r2l0/
                    fcb       $8D,$01,$86,$34,$10,$AD,$9F,$03
                    fcs       /]2b5@/
strDwMidOut         fcc       /dw mid out /
                    fcb       $00
strCR1              fcb       $0D,$00
strDwMidSynPro      fcc       /dw mid syn pro /
                    fcb       $00
strCR2              fcb       $0D,$00
strDwMidSta         fcc       /dw mid sta/
                    fcb       $0D,$00
fmtStr              fcb       $25,$73,$00
msgClickOrType      fcc       /Click Selection or Type Number/
                    fcb       $0D,$00
* strDwMidOut2: command prefix used after a device pick.
strDwMidOut2        fcc       /dw mid out /
                    fcb       $00
strCR3              fcb       $0D,$00
fmtReplyLine        fcb       $0D,$25,$73,$0D,$00
strDwSynShoPro      fcc       /dw mid syn sho pro/
                    fcb       $0D,$00
msgSelectProfile    fcc       / Select your DW4 MIDI Profile/
                    fcb       $0D,$00
* strCR4: appended to each profile line with StrNCat.
strCR4              fcb       $0D,$00
fmtProfItem         fcc       /[%02d] %s/
                    fcb       $00
* fmtProfPlain: unnumbered profile line (index beyond the count).
fmtProfPlain        fcc       / %s/
                    fcb       $00
msgClickOrType2     fcc       /Click Selection or Type Number/
                    fcb       $0D,$00
* tblProfPickDigit: click row -> hex digit, one row per device or profile (row 0 = header).
tblProfPickDigit    fcb       $0D
                    fcc       /0123456789ABCDEF/
                    fcb       $00
* strDwMidSynPro2: command prefix used after a profile pick.
strDwMidSynPro2     fcc       /dw mid syn pro /
                    fcb       $00
strCR5              fcb       $0D,$00
fmtReplyLine2       fcb       $0D,$25,$73,$0D,$00
pathDwSerial        fcb       $2F,$4E,$00
msgDwOpenErr        fcc       /Error opening DW device!! Error #/
                    fcb       $00
msgCmdFailed        fcc       /Command Failed!/
                    fcb       $0D,$00
pathDwSerial2       fcb       $2F,$4E,$00
msgDwOpenErr2       fcc       /Error opening DW device!! Error #/
                    fcb       $00
* msgCmdFailed2: followed by an unreferenced "\r       Accessing DriveWire4 Server\r" string.
msgCmdFailed2       fcc       /Command Failed!/
                    fcb       $0D,$00,$0D
                    fcc       /       Accessing DriveWire4 Server/
                    fcb       $0D,$00
                    fcs       /O_4Fn/
                    fcb       $68,$20,$10
* IntToStr: itoa(n, buf): handles sign, emits digits with UModInt16/UDivInt16 by 10 reversed, appends '-', NUL, then StrReverse; returns buf
IntToStr            clra
                    clrb
                    pshs      a,b,u
                    ldu       8,s
                    tst       6,s
                    bpl       ItoaDigitLoop
                    inc       ,s
                    subd      6,s
                    std       6,s
* ItoaDigitLoop: digit loop of IntToStr: n%10+'0' stored, n/=10 while >0
ItoaDigitLoop       ldd       6,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      UModInt16
                    addb      #$30
                    stb       ,u+
                    ldd       6,s
                    pshs      a,b
                    ldd       #$000A
                    lbsr      UDivInt16
                    std       6,s
                    bgt       ItoaDigitLoop
                    tst       ,s
                    beq       a14@
                    ldb       #$2D
                    stb       ,u+
a14@                clr       ,u
                    ldd       8,s
                    pshs      a,b
                    lbsr      StrReverse
                    leas      4,s
                    puls      u,pc
* StrReverse: reverse a string in place (swaps from both ends using StrLen); returns the string
StrReverse          pshs      u
                    ldu       4,s
                    pshs      u
                    pshs      u
                    lbsr      StrLen
                    leas      2,s
                    addd      ,s++
                    tfr       d,x
                    bra       b15@
a15@                ldb       ,u
                    lda       ,-x
                    sta       ,u+
                    stb       ,x
b15@                pshs      x
                    cmpu      ,s++
                    blo       a15@
                    ldd       4,s
                    puls      u,pc
* StrCat: strcat(dest, src): SkipToNul on dest then copy loop; returns dest
StrCat              pshs      u
                    ldu       6,s
                    ldx       4,s
                    bsr       SkipToNul
                    tfr       d,x
                    bra       StrCopyLoop
* StrCpy: strcpy(dest, src); returns dest
StrCpy              pshs      u
                    ldu       6,s
                    ldx       4,s
* StrCopyLoop: byte copy loop shared by StrCpy and StrCat
StrCopyLoop         ldb       ,u+
                    stb       ,x+
                    bne       StrCopyLoop
                    ldd       4,s
                    puls      u,pc
                    fcb       $AE,$62
* SkipToNul: advance X to the terminating NUL, return it in D (StrCat helper)
SkipToNul           ldb       ,x+
                    bne       SkipToNul
                    leax      -1,x
                    tfr       x,d
                    rts
* StrLen: strlen(s): scan to NUL, D = end - start
StrLen              pshs      u
                    ldu       4,s
a16@                ldb       ,u+
                    bne       a16@
                    leau      -1,u
                    tfr       u,d
                    subd      4,s
                    puls      u,pc
* StrNCpy: strncpy(dest, src, n): copies up to n bytes, pads the rest with NUL; returns dest
StrNCpy             pshs      y,u
                    ldu       8,s
                    ldx       6,s
                    ldy       10,s
                    beq       c17@
a17@                ldb       ,u+
                    stb       ,x+
                    leay      -1,y
                    beq       c17@
                    tstb
                    bne       a17@
b17@                clr       ,x+
                    leay      -1,y
                    bne       b17@
c17@                ldd       6,s
                    puls      y,u,pc
* StrNCat: strncat(dest, src, n): finds dest end, copies up to n bytes, terminates; returns dest
StrNCat             pshs      y,u
                    ldu       8,s
                    ldx       6,s
                    ldy       10,s
                    beq       d18@
a18@                ldb       ,x+
                    bne       a18@
                    leax      -1,x
b18@                ldb       ,u+
                    stb       ,x+
                    leay      -1,y
                    beq       c18@
                    tstb
                    bne       b18@
c18@                clr       ,x
d18@                ldd       4,s
                    puls      y,u,pc
* MemClear: clear(dest, n): stores n zero bytes; returns dest
MemClear            pshs      u
                    ldu       4,s
                    clrb
                    ldx       6,s
                    beq       b19@
a19@                stb       ,u+
                    leax      -1,x
                    bne       a19@
b19@                ldd       4,s
                    puls      u,pc
* MulInt16: Microware C _mul: D = D * operand on stack (operand popped); fast 8x8 path when both high bytes are zero
MulInt16            tsta
                    bne       MulFull16
                    tst       2,s
                    bne       MulFull16
                    lda       3,s
                    mul
                    ldx       ,s
                    stx       2,s
                    ldx       #$0000
                    std       ,s
                    puls      a,b,pc
* MulFull16: general 16x16 partial-product path of MulInt16
MulFull16           pshs      a,b
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
                    bhs       a20@
                    inc       ,s
a20@                lda       4,s
                    ldb       9,s
                    mul
                    addd      1,s
                    std       1,s
                    bhs       b20@
                    inc       ,s
b20@                lda       4,s
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
* UModInt16: unsigned modulo: clears sign flag >$15E5,y, sets divide vector >$15E6,y = UDivInt16, joins ModCommon; D = dividend(on stack) % D
UModInt16           clr       >$15E5,y
                    leax      >UDivInt16,pcr
                    stx       >$15E6,y
                    bra       ModCommon
                    fcb       $30,$8D,$00,$4F,$AF,$A9,$15,$E6
                    fcb       $6F,$A9,$15,$E5
                    fcc       /mb*/
                    fcb       $04,$6C,$A9,$15,$E5
* ModCommon: modulo tail: divisor 0 -> return the dividend; else call the divide through [>$15E6,y], take the remainder from X, negate if the sign flag is set
ModCommon           subd      #$0000
                    bne       a21@
                    puls      x
                    ldd       ,s++
                    jmp       ,x
a21@                ldx       2,s
                    pshs      x
                    jsr       [>$15E6,y]
                    ldd       ,s
                    std       2,s
                    tfr       x,d
                    tst       >$15E5,y
                    beq       b21@
                    nega
                    negb
                    sbca      #$00
b21@                std       ,s++
                    rts
* UDivInt16: unsigned 16-bit divide: dividend on stack, divisor in D; returns quotient in D, remainder in X, pops the dividend; zero divisor -> DivByZero
UDivInt16           subd      #$0000
                    beq       DivByZero
                    pshs      a,b
                    leas      -2,s
                    clr       ,s
                    clr       1,s
                    bra       DivNormalize
* DivByZero: divide by zero: errno = 45 and RaiseSignal(45) to the own process
DivByZero           puls      a,b
                    std       ,s
                    ldd       #$002D
                    lbra      RaiseSignal
* DivInt16: signed 16-bit divide (Microware C _div): negates operands and tracks the sign, then shift-subtract loop; D = quotient, X = remainder
DivInt16            subd      #$0000
                    beq       DivByZero
                    pshs      a,b
                    leas      -2,s
                    clr       ,s
                    clr       1,s
                    tsta
                    bpl       a22@
                    nega
                    negb
                    sbca      #$00
                    com       1,s
                    std       2,s
a22@                ldd       6,s
                    bpl       DivNormalize
                    nega
                    negb
                    sbca      #$00
                    com       1,s
                    std       6,s
* DivNormalize: shared by UDivInt16 and DivInt16: shift the divisor left until bit 15 is set, counting the steps
DivNormalize        lda       #$01
a23@                inca
                    asl       3,s
                    rol       2,s
                    bpl       a23@
                    sta       ,s
                    ldd       6,s
                    clr       6,s
                    clr       7,s
* DivLoop: restoring shift-subtract division loop
DivLoop             subd      2,s
                    bhs       a24@
                    addd      2,s
                    andcc     #$FE
                    bra       b24@
a24@                orcc      #$01
b24@                rol       7,s
                    rol       6,s
                    lsr       2,s
                    ror       3,s
                    dec       ,s
                    bne       DivLoop
                    std       2,s
                    tst       1,s
                    beq       DivReturn
                    ldd       6,s
                    nega
                    negb
                    sbca      #$00
                    std       6,s
* DivReturn: move the return address over the dividend arg, load X = remainder, D = quotient, leas 6 and rts
DivReturn           ldx       4,s
                    ldd       6,s
                    std       4,s
                    stx       6,s
                    ldx       2,s
                    ldd       4,s
                    leas      6,s
                    rts
* RaiseSignal: store D into errno (>$034F,y), F$ID to get the own process id, F$Send that signal code to self
RaiseSignal         std       >$034F,y
                    pshs      b,y
                    os9       F$ID
                    puls      b,y
                    os9       F$Send
                    rts
* OpenPath: open(name, mode): I$Open, carry -> ErrReturn, else returns the path number
OpenPath            ldx       2,s
                    lda       5,s
                    os9       I$Open
                    lblo      ErrReturn
                    tfr       a,b
                    clra
                    rts
* ClosePath: close(path): I$Close then CarryToRet
ClosePath           lda       3,s
                    os9       I$Close
                    lbra      CarryToRet
* ReadPath: read(path, buf, n): I$Read, E$EOF ($D3) -> 0, other error -> ErrReturn, else bytes read
ReadPath            pshs      y
                    ldx       6,s
                    lda       5,s
                    ldy       8,s
                    pshs      y
                    os9       I$Read
                    bhs       b25@
                    cmpb      #$D3
                    bne       a25@
                    clra
                    clrb
                    puls      x,y,pc
a25@                puls      x,y
                    lbra      ErrReturn
b25@                tfr       y,d
                    puls      x,y,pc
                    fcb       $34,$20,$A6,$65,$AE,$66,$10,$AE
                    fcc       /h4 /
                    fcb       $10,$3F,$8B,$20,$DD
* WritePath: write(path, buf, n): n==0 returns 0, I$Write, error -> ErrReturn, else n
WritePath           pshs      y
                    ldy       8,s
                    beq       a26@
                    lda       5,s
                    ldx       6,s
                    os9       I$Write
                    bhs       a26@
                    puls      y
                    lbra      ErrReturn
a26@                tfr       y,d
                    puls      y,pc
                    fcb       $34,$20,$10,$AE,$68,$27,$F5,$A6
                    fcb       $65,$AE,$66,$10,$3F,$8C,$20,$E5
                    fcb       $39,$8E,$00,$00,$5F,$10,$3F,$0A
                    fcb       $16,$00,$80
                    fcs       /94`./
                    fcb       $66,$10,$AE,$68,$EE,$6A,$10,$3F
                    fcb       $17,$35,$E0,$A6,$63,$E6,$65,$10
                    fcb       $3F,$0F,$10,$25,$00,$66,$39
* TSleep: tsleep(ticks): F$Sleep, error -> ErrReturn, returns remaining ticks
TSleep              ldx       2,s
                    os9       F$Sleep
                    lblo      ErrReturn
                    tfr       x,d
                    rts
* Intercept: intercept(func): stores func in >$15E8,y, F$Icpt with IcptTrampoline and U = data pointer, CarryToRet
Intercept           pshs      u
                    tfr       y,u
                    ldx       4,s
                    stx       >$15E8,y
                    leax      >IcptTrampoline,pcr
                    os9       F$Icpt
                    puls      u
                    lbra      CarryToRet
* IcptTrampoline: code stored as text: tfr u,y; clra; pshs a,b (signal code as int); jsr [>$15E8,y]; leas 2,s; rti - the C library intercept stub
IcptTrampoline      fcb       $1F
                    fcc       /2O4/
                    fcb       $06,$AD,$B9,$15,$E8
                    fcc       /2b;/
* Os9Call: _os9(code, &regs): builds SWI2/code/RTS on the stack, loads A,B,X,Y,U from the 10-byte regs struct (cc,a,b,dp,x,y,u), executes, stores the registers back, returns -1 on carry else 0
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
                    beq       Os9CallOk
                    ldd       #$FFFF
                    rts
* Os9CallOk: Os9Call success: return 0
Os9CallOk           clra
                    clrb
                    rts
* ErrReturn: errno (>$034F,y) = B, return -1; common error exit of the system-call wrappers
ErrReturn           clra
                    std       >$034F,y
                    ldd       #$FFFF
                    rts
* CarryToRet: carry set -> ErrReturn else return 0 (tail of ClosePath and Intercept)
CarryToRet          blo       ErrReturn
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
                    fcc       /s9w/
                    fcb       $00

                    fill      0,$1D00-*           pad to $1D00 bytes so F$Link never puts this overlay in slot 7 and the score page always gets it
                    emod
eom                 equ       *
                    end
