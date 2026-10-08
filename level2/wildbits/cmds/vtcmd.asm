********************************************************************
* vt - open, switch to and list Wildbits virtual terminals
*
*   vt        new terminal with a shell (shell i=/vt&), then show it
*   vt n      show terminal n (0 = /term); start it with a shell first
*             if it is not open
*   vt -l     list the open terminals, * marks the one on screen
*
* The module is named vt but the source is vtcmd.asm: modules/vt.asm is
* the /vt factory descriptor, which owns .mods/vt and comes first in the
* vpath.  The recipe copies .mods/vtcmd to CMDS/vt.  The two modules
* coexist because every kernel lookup matches type, but Shell+ links a
* typed command name with any type first, so with only the descriptor in
* memory "vt" fails with E$NEMod.  level2/wildbits/startup does "load vt"
* so it is in memory, after the descriptor, from boot on.
*
* A terminal lives only while a path holds it open, so a new one is put
* on this process's paths 0-2 before the shell is forked: F$Fork gives
* the child its own copies inside the call, and the terminal survives
* this process closing its path and exiting.  Switching is SetStat
* SS.TermSel on vt's own path, never I/O on the target: SCF queues a
* write, SetStat, open or close to a terminal behind a program that holds
* it busy while reading (BASIC09 at its prompt), and vt would hang there.
* The terminal table is read with F$CpyMem out of system block 0
* (gr.LiveTerm, gr.TermTbl in defs/wildbits_vtio.d).
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2026/09/14  jfed6000
* Started.

                    nam       vt
                    ttl       Virtual terminal command

                    ifp1
                    use       defsfile
                    use       wildbits_vtio.d
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

* gr.LiveTerm and the whole of gr.TermTbl, which follows it
TblLen              equ       gr.TermTbl-gr.LiveTerm+G.TermMax*gr.TermSz

                    mod       eom,name,tylg,atrv,start,size

                    org       0
vPath               rmb       1                   path to the terminal
vTermId             rmb       1                   terminal id 0-8
vPLen               rmb       1                   length of vParm through its CR
vDAT                rmb       16                  DAT image for F$CpyMem: all block 0
vTbl                rmb       TblLen              gr.LiveTerm, then gr.TermTbl
vName               rmb       32                  SS.DevNm result
vParm               rmb       12                  "i=/vtN" CR - the pathlist starts at +2
                    rmb       250                 stack
size                equ       .

name                fcs       /vt/
                    fcb       edition

start               leay      vDAT,u              every DAT slot is block 0
                    ldb       #16
clrdat@             clr       ,y+
                    decb
                    bne       clrdat@
skipsp@             lda       ,x+
                    cmpa      #C$SPAC
                    beq       skipsp@
                    cmpa      #C$CR
                    beq       NewTerm             bare vt
                    cmpa      #'-
                    beq       Option
                    suba      #'0
                    cmpa      #G.TermMax          below '0' wraps high, so one test
                    bhs       Usage
                    sta       <vTermId
                    lbsr      EndArg
                    bne       Usage               more than one digit
                    bra       DoNum
Option              lda       ,x+
                    anda      #$DF                fold to upper case
                    cmpa      #'L
                    bne       Usage
                    lbsr      EndArg
                    bne       Usage
                    lbra      List

Usage               leax      UsageTx,pcr
ul@                 ldy       #80
                    lda       #2                  stderr
                    os9       I$WritLn            one line, up to its CR
                    lbcs      Exit
                    tfr       y,d
                    leax      d,x
                    tst       ,x
                    bne       ul@
                    ldb       #E$IllArg
                    lbra      Exit

* vt - the /vt factory binds the lowest free id 1-8 in SS.Open and swaps
* in /vtN's descriptor, so SS.DevNm names the terminal it gave us.
NewTerm             leax      VtName,pcr
                    lda       #UPDAT.
                    os9       I$Open
                    bcc       opened@
                    cmpb      #E$MNF              all eight are open?
                    lbne      Exit
                    leax      NoTermTx,pcr        say so, keep the error status
                    ldy       #80
                    lda       #2                  stderr
                    os9       I$WritLn
                    ldb       #E$MNF
                    lbra      Exit
opened@             sta       <vPath
                    ldb       #SS.DevNm
                    leax      vName,u
                    os9       I$GetStt
                    bcs       Exit
                    lda       vName+2,u           "vtN", N with the fcs high bit
                    anda      #$7F
                    suba      #'0
                    sta       <vTermId
                    lbsr      MakeParm
                    bra       Shell

* vt n - an open terminal is only selected, never opened: opening or
* writing to it can wait behind its reader.  Otherwise open /vtN, which
* creates it, and start a shell.
DoNum               lbsr      ReadTbl
                    lbcs      Exit
                    ldb       <vTermId
                    lbsr      EntryX
                    lda       T.Flags,x
                    bita      #T.Init
                    lbne      SelOnly             already open (/term always is)
                    lbsr      MakeParm
                    leax      vParm+2,u           "/vtN"
                    lda       #UPDAT.
                    os9       I$Open              creates the terminal
                    lbcs      Exit
                    sta       <vPath

* Put the terminal on paths 0-2 and fork an immortal shell on it.
Shell               clra
dup@                pshs      a
                    os9       I$Close
                    lda       <vPath
                    os9       I$Dup               lowest free path: the one just closed
                    puls      a                   (CC is I$Dup's)
                    bcs       Exit
                    inca
                    cmpa      #3
                    blo       dup@
                    pshs      u
                    ldb       <vPLen
                    clra
                    tfr       d,y                 parameter size
                    leax      ShellNm,pcr
                    leau      vParm,u             "i=/vtN" CR
                    lda       #Prgrm+Objct
                    clrb                          shell's own data size
                    os9       F$Fork              no F$Wait: like &
                    puls      u
                    bcs       Exit

Select              lbsr      SelTerm
                    bcs       Exit
                    lda       <vPath
                    os9       I$Close
                    bcs       Exit
                    clrb
Exit                os9       F$Exit

SelOnly             lbsr      SelTerm             B = 0 or the error
                    bra       Exit

* vt -l
List                bsr       ReadTbl
                    bcs       Exit
                    clrb
lp@                 pshs      b
                    bsr       EntryX
                    lda       T.Flags,x
                    bita      #T.Init
                    beq       nx@
                    ldb       ,s
                    stb       <vTermId
                    bsr       MakeParm
                    ldb       ,s
                    cmpb      <vTbl               gr.LiveTerm
                    bne       wr@
                    leax      vParm,u
                    ldb       <vPLen
                    abx                           just past the CR
                    ldd       #$202A              " *" over the CR
                    std       -1,x
                    lda       #C$CR
                    sta       1,x
                    inc       <vPLen
                    inc       <vPLen
wr@                 leax      vParm+2,u           the pathlist, without "i="
                    ldb       <vPLen
                    subb      #2
                    clra
                    tfr       d,y
                    lda       #1                  stdout
                    os9       I$WritLn
                    bcs       er@
nx@                 puls      b
                    incb
                    cmpb      #G.TermMax
                    blo       lp@
                    clrb
                    bra       Exit
er@                 leas      1,s
                    bra       Exit

* SelTerm - show terminal vTermId: SetStat SS.TermSel on the first of
* paths 0-2 that takes it (one may be redirected to a file or pipe).
* Exit: carry clear, B = 0; or carry set, B = the last error.
SelTerm             clra
sl@                 pshs      a                   path to try
                    ldb       <vTermId
                    clra
                    tfr       d,x                 X = terminal id
                    lda       ,s
                    ldb       #SS.TermSel
                    os9       I$SetStt
                    puls      a                   (CC is I$SetStt's)
                    bcc       ok@
                    inca
                    cmpa      #3
                    blo       sl@
                    coma                          set carry, B = last error
                    rts
ok@                 clrb
                    rts

* EndArg - Z set if X is at the end of an argument (space or CR).
EndArg              lda       ,x
                    cmpa      #C$CR
                    beq       ex@
                    cmpa      #C$SPAC
ex@                 rts

* ReadTbl - copy gr.LiveTerm and gr.TermTbl out of system block 0.
ReadTbl             pshs      u
                    leay      vDAT,u
                    leau      vTbl,u
                    tfr       y,d                 D = DAT image
                    ldx       #gr.LiveTerm
                    ldy       #TblLen
                    os9       F$CpyMem
                    puls      u,pc

* EntryX - B = id; X = that id's entry in the vTbl copy.  Clobbers D.
EntryX              lda       #gr.TermSz
                    mul
                    leax      vTbl+gr.TermTbl-gr.LiveTerm,u
                    leax      d,x
                    rts

* MakeParm - vParm = "i=/term" or "i=/vtN" and a CR for vTermId, and
* vPLen = its length.
MakeParm            leay      vParm,u
                    ldd       #$693D              "i="
                    std       ,y++
                    lda       #'/
                    sta       ,y+
                    ldb       <vTermId
                    bne       vtn@
                    ldd       #$7465              "te"
                    std       ,y++
                    ldd       #$726D              "rm"
                    std       ,y++
                    bra       cr@
vtn@                ldd       #$7674              "vt"
                    std       ,y++
                    ldb       <vTermId
                    addb      #'0
                    stb       ,y+
cr@                 lda       #C$CR
                    sta       ,y+
                    tfr       y,d
                    leay      vParm,u
                    pshs      y
                    subd      ,s++
                    stb       <vPLen
                    rts

VtName              fcc       "/vt"
                    fcb       C$CR
ShellNm             fcc       /shell/
                    fcb       C$CR
NoTermTx            fcc       /vt: no more terminals available/
                    fcb       C$CR
UsageTx             fcc       /Use: vt       new terminal + shell/
                    fcb       C$CR
                    fcc       /     vt n     go to terminal n (0-8)/
                    fcb       C$CR
                    fcc       /     vt -l    list terminals (*=shown)/
                    fcb       C$CR
                    fcb       0

                    emod
eom                 equ       *
                    end
