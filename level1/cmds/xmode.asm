********************************************************************
* XMode/TMode - SCF device/path descriptor utility
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      1989/06/21  Bruce Isted
* Released to public domain.
*
*   2      2004/07/29  Boisy G. Pitre
* Revamped to also assemble as tmode

                    nam       XMode/TMode
                    ttl       SCF device/path descriptor utility

DOHELP              set       0

                    ifp1
                    use       defsfile
                    endc

BuffSize            equ       34                  max. CHAR string length
Edtn                equ       2
MaxSize             equ       $80                 maximum module size
NameSize            equ       4                   maximum module name length
rev                 equ       0

                    org       0
Count               rmb       1                   number of option bytes
DataPtr             rmb       2                   current option ptr
HexIn               rmb       2                   2 byte hex number
                    ifne      XMODE
ModAddr             rmb       2                   module address
ModSize             rmb       2                   module size
OptEnd              rmb       2                   option table end offset
                    endc
PathNmbr            rmb       1                   file path
ParmPtr             rmb       2                   next name DataPtr
TxtPtr              rmb       2                   option name ptr
Buffer              rmb       BuffSize            miscellaneous output buffer
ModBuff             rmb       MaxSize             module work copy buffer
stack               rmb       $0200               stack and parameter space
MemSize             equ       .

                    mod       Size,Name,Prgrm+Objct,ReEnt+rev,Entry,MemSize

Name                equ       *
                    ifne      XMODE
                    fcc       "X"
                    else
                    fcc       "T"
                    endc
                    fcs       "Mode"
                    fcb       Edtn                edition number

OptTable
                    ifne      XMODE
                    fcc       " nam"              option name
                    fcb       Sign+M$Name,NameSize offset to string offset & max. byte count to change
                    fcc       " mgr"
                    fcb       Sign+M$FMgr,0       offset to string offset & no changes allowed
                    fcc       " ddr"
                    fcb       Sign+M$PDev,0
                    fcc       " hpn"
                    fcb       M$Port,1            option offset & byte count
                    fcc       " hpa"
                    fcb       M$Port+1,2
                    endc
                    fcc       " upc"
                    ifne      XMODE
                    fcb       IT.UPC,1
                    else
                    fcb       PD.UPC-PD.OPT,1
                    endc
                    fcc       " bso"
                    ifne      XMODE
                    fcb       IT.BSO,1
                    else
                    fcb       PD.BSO-PD.OPT,1
                    endc
                    fcc       " dlo"
                    ifne      XMODE
                    fcb       IT.DLO,1
                    else
                    fcb       PD.DLO-PD.OPT,1
                    endc
                    fcc       " eko"
                    ifne      XMODE
                    fcb       IT.EKO,1
                    else
                    fcb       PD.EKO-PD.OPT,1
                    endc
                    fcc       " alf"
                    ifne      XMODE
                    fcb       IT.ALF,1
                    else
                    fcb       PD.ALF-PD.OPT,1
                    endc
                    fcc       " nul"
                    ifne      XMODE
                    fcb       IT.NUL,1
                    else
                    fcb       PD.NUL-PD.OPT,1
                    endc
                    fcc       " pau"
                    ifne      XMODE
                    fcb       IT.PAU,1
                    else
                    fcb       PD.PAU-PD.OPT,1
                    endc
                    fcc       " pag"
                    ifne      XMODE
                    fcb       IT.PAG,1
                    else
                    fcb       PD.PAG-PD.OPT,1
                    endc
                    fcc       " bsp"
                    ifne      XMODE
                    fcb       IT.BSP,1
                    else
                    fcb       PD.BSP-PD.OPT,1
                    endc
                    fcc       " del"
                    ifne      XMODE
                    fcb       IT.DEL,1
                    else
                    fcb       PD.DEL-PD.OPT,1
                    endc
                    fcc       " eor"
                    ifne      XMODE
                    fcb       IT.EOR,1
                    else
                    fcb       PD.EOR-PD.OPT,1
                    endc
                    fcc       " eof"
                    ifne      XMODE
                    fcb       IT.EOF,1
                    else
                    fcb       PD.EOF-PD.OPT,1
                    endc
                    fcc       " rpr"
                    ifne      XMODE
                    fcb       IT.RPR,1
                    else
                    fcb       PD.RPR-PD.OPT,1
                    endc
                    fcc       " dup"
                    ifne      XMODE
                    fcb       IT.DUP,1
                    else
                    fcb       PD.DUP-PD.OPT,1
                    endc
                    fcc       " psc"
                    ifne      XMODE
                    fcb       IT.PSC,1
                    else
                    fcb       PD.PSC-PD.OPT,1
                    endc
                    fcc       " int"
                    ifne      XMODE
                    fcb       IT.INT,1
                    else
                    fcb       PD.INT-PD.OPT,1
                    endc
                    fcc       " qut"
                    ifne      XMODE
                    fcb       IT.QUT,1
                    else
                    fcb       PD.QUT-PD.OPT,1
                    endc
                    fcc       " bse"
                    ifne      XMODE
                    fcb       IT.BSE,1
                    else
                    fcb       PD.BSE-PD.OPT,1
                    endc
                    fcc       " ovf"
                    ifne      XMODE
                    fcb       IT.OVF,1
                    else
                    fcb       PD.OVF-PD.OPT,1
                    endc
                    fcc       " par"
                    ifne      XMODE
                    fcb       IT.PAR,1
                    else
                    fcb       PD.PAR-PD.OPT,1
                    endc
                    fcc       " bau"
                    ifne      XMODE
                    fcb       IT.BAU,1
                    else
                    fcb       PD.BAU-PD.OPT,1
                    endc
                    fcc       " xon"
                    ifne      XMODE
                    fcb       IT.XON,1
                    else
                    fcb       PD.XON-PD.OPT,1
                    endc
                    fcc       " xof"
                    ifne      XMODE
                    fcb       IT.XOFF,1
                    else
                    fcb       PD.XOFF-PD.OPT,1
                    endc
                    ifne      XMODE
                    fcc       " col"
                    fcb       IT.COL,1
                    fcc       " row"
                    fcb       IT.ROW,1
                    ifgt      Level-1
                    fcc       " xtp"
                    fcb       IT.XTYP,1
                    fcc       " wnd"
                    fcb       IT.WND,1
                    fcc       " val"
                    fcb       IT.VAL,1
                    fcc       " sty"
                    fcb       IT.STY,1
                    fcc       " cpx"
                    fcb       IT.CPX,1
                    fcc       " cpy"
                    fcb       IT.CPY,1
                    fcc       " fgc"
                    fcb       IT.FGC,1
                    fcc       " bgc"
                    fcb       IT.BGC,1
                    fcc       " bdc"
                    fcb       IT.BDC,1
                    endc
                    endc
TablOpts            equ       (*-OptTable)/6      number of table entries
                    fcb       $80                 end of option table

                    ifne      DOHELP
UseMsg
                    fcb       C$LF
                    fcc       "Usage:  XMode [/<device> || -<pathlist> || -?] [option] [option] [...]"
                    fcb       C$LF,C$LF
                    fcc       "Purpose:  To report or alter current option settings of SCF device"
                    fcb       C$LF
                    fcc       "          descriptors in memory or on disk in single module files."
                    fcb       C$LF,C$LF
                    fcc       "Options:  nam, mgr, ddr, hpn, hpa, upc, bso, dlo, eko, alf, nul, pau,"
                    fcb       C$LF
                    fcc       "          pag, bsp, del, eor, eof, rpr, dup, psc, int, qut, bse, ovf,"
                    fcb       C$LF
                    fcc       "          par, bau, xon, xof, col, row, xtp, wnd, val, sty, cpx, cpy,"
                    fcb       C$LF
                    fcc       "          fgc, bgc, bdc"
                    fcb       C$LF,C$LF
                    fcc       "Examples:  xmode /t2"
                    fcb       C$LF
                    fcc       "               Prints the current option settings of the /T2 descriptor"
                    fcb       C$LF
                    fcc       "               in memory."
                    fcb       C$LF
                    fcc       "           xmode -modules/t4.dd nam=T2 bau=6 hpa=ff6c eof=1B"
                    fcb       C$LF
                    fcc       "               Changes the module name in the MODULES/T4.dd file to T2,"
                    fcb       C$LF
                    fcc       "               sets the baud rate code to 6,  the hardware port address"
                    fcb       C$LF
                    fcc       "               to $FF6C, and the end of file character to $1B."
                    fcb       C$LF
                    fcc       "           xmode -?"
                    fcb       C$LF
                    fcc       "               Prints more complete information on all of the options."
                    fcb       C$CR
UseLen              equ       *-UseMsg

HelpMsg
                    fcb       C$LF
                    fcc       "The NAM option accepts only a legal OS-9 module name with a maximum of"
                    fcb       C$LF
                    fcc       "4 characters.  It is up to the user to ensure that there is adequate"
                    fcb       C$LF
                    fcc       "room for the module name, and if required to rename the disk file to"
                    fcb       C$LF
                    fcc       "suit the new module name.  The MGR and DDR options can't be changed."
                    fcb       C$LF
                    fcc       "All other options require hexadecimal numbers (0 through FFFF).  XTP is"
                    fcb       C$LF
                    fcc       "for certain ACIA descriptors only.  WND, VAL, STY, CPX, CPY, FGC, BGC,"
                    fcb       C$LF
                    fcc       "and BDC are for window descriptors only."
                    fcb       C$LF,C$LF
                    fcc       "nam Device Name         mgr File Manager Name   ddr Device Driver Name"
                    fcb       C$LF
                    fcc       "hpn H'ware Page Number  hpa H'ware Port Address upc Case Lock Flag"
                    fcb       C$LF
                    fcc       "bso Backspace Method    dlo Delete Line Method  eko Screen Echo Flag"
                    fcb       C$LF
                    fcc       "alf Auto Linefeed Flag  nul End Of Line Nulls   pau Page Pause Flag"
                    fcb       C$LF
                    fcc       "pag Page Length         bsp Backspace Character del Delete Line Char"
                    fcb       C$LF
                    fcc       "eor End Of Record Char  eof End Of File Char    rpr Reprint Line Char"
                    fcb       C$LF
                    fcc       "dup Duplicate Line Char psc Pause Character     int Interrupt Character"
                    fcb       C$LF
                    fcc       "qut Quit Character      bse Backspace Echo Char ovf Overflow Character"
                    fcb       C$LF
                    fcc       "par Type (Parity) Code  bau Baud Rate Code      xon XON Character"
                    fcb       C$LF
                    fcc       "xof XOFF Character      col Display Columns     row Display Rows"
                    fcb       C$LF
                    fcc       "xtp Extended Type Code  wnd Window Number       val Valid Window Flag"
                    fcb       C$LF
                    fcc       "sty Window Screen Type  cpx X Corner Position   cpy Y Corner Position"
                    fcb       C$LF
                    fcc       "fgc Foreground Colour   bgc Background Colour   bdc Border Colour"
                    fcb       C$CR
HelpLen             equ       *-HelpMsg
                    endc

Equal               fcc       "="

TypeMsg
                    fcc       "Not an SCF "
                    ifne      XMODE
                    fcc       "descriptor!"
                    else
                    fcc       "path!"
                    endc
CR                  fcb       C$CR
TypeLen             equ       *-TypeMsg

                    ifne      XMODE
Sizemsg
                    fcc       "Module size out of range!"
                    fcb       C$CR
Sizelen             equ       *-Sizemsg
                    endc

SynMsg
                    fcc       "Syntax error:  "
SynLen              equ       *-SynMsg

****************
* miscellaneous error and help routines

                    ifne      DOHELP
MuchHelp
                    leax      HelpMsg,pc
                    ldy       #HelpLen
                    bra       Helpprnt
                    endc

                    ifne      XMODE
BadSize
                    leax      Sizemsg,pc
                    ldy       #Sizelen
                    bra       AddHelp
                    endc

BadType
                    leax      TypeMsg,pc
                    ldy       #TypeLen

AddHelp
                    lda       #2
                    os9       I$WritLn
Help
                    ifne      DOHelp
                    leax      UseMsg,pc
                    ldy       #UseLen
Helpprnt
                    lda       #2
                    os9       I$WritLn
                    endc
                    lbra      OkayEnd2

****************
Entry
                    ifne      XMODE
                    ldd       #0
                    std       <ModAddr            zero mod flag
                    sta       <PathNmbr           zero file flag
                    endc
                    ldd       ,x+                 check for device name
                    ifne      XMODE
                    cmpa      #'-                 file option?
                    bne       Link
                    else
                    stx       <ParmPtr
                    clr       <PathNmbr
                    cmpa      #'.                 dot? (for path specification)
                    bne       Process             if not, process as option
                    subb      #$30
                    lbmi      Syntax
                    cmpb      #$02
                    lbgt      Syntax
                    stb       <PathNmbr
                    leax      2,x                 point passed char after '.'
                    endc
                    ifne      DOHELP
                    cmpb      #'?                 help option?
                    beq       MuchHelp
                    endc
                    ifne      XMODE
* Use Filename to Get Desc:
                    lda       #UPDAT.             open path to module file
                    os9       I$Open
                    bcs       Help
                    stx       <ParmPtr
                    sta       <PathNmbr           save path number
                    ldy       #MaxSize            max size
                    leax      ModBuff,u           module buff
                    os9       I$Read              get it
                    lbcs      Error
                    ldb       M$Opt,x
                    clra                          [D] = option table size
                    addd      #M$DTyp             add options start offset
                    std       <OptEnd             save options end offset
                    ldd       M$Size,x            get module size
                    cmpd      #MaxSize            module size OK?
                    bhi       BadSize             no, go return error...
                    std       <ModSize
                    bra       GotIt
Link
                    cmpa      #'/                 else must be /<devicename>
                    bne       Help
                    pshs      u
                    lda       #Devic
                    os9       F$Link              link to module
                    bcs       Help
                    stx       <ParmPtr            update after name
                    tfr       u,x
                    puls      u
                    stx       <ModAddr
                    ldb       M$Opt,x
                    clra                          [D] = option table size
                    addd      #M$DTyp             add options start offset
                    std       <OptEnd             save options end offset
                    ldd       M$Size,x            get module size
                    cmpd      #MaxSize            module size OK?
                    lbhi      BadSize             no, go report error...
                    std       <ModSize
                    tfr       d,y                 copy module size...
                    pshs      u                   save data area pointer
                    leau      ModBuff,u

GetModLp
                    lda       ,x+
                    sta       ,u+
                    leay      -1,y
                    bne       GetModLp
                    puls      u                   recover data area pointer

GotIt
                    ldd       <OptEnd             get option table end offset
                    cmpd      <ModSize            is option table size OK?
                    lbhs      BadSize             no, go report error...
                    leax      ModBuff,u
                    lda       M$DTyp,x            get device type
                    lbne      BadType             SCF = $00
                    ldx       <ParmPtr            point to input parms
                    lbsr      SkipSpac            go skip leading spaces...
                    cmpa      #C$CR               no options?
                    lbeq      Info                ..yes, give info
                    leax      -1,x
                    else
Process
                    leax      -1,x
                    stx       <ParmPtr            save for syntax error use
                    leax      ModBuff,u
                    lda       <PathNmbr
                    clrb
                    os9       I$GetStt
                    tst       ,x
                    lbne      BadType
                    ldx       <ParmPtr
                    lbsr      SkipSpac            go skip leading spaces...
                    cmpa      #C$CR               no options?
                    lbeq      Info                ..yes, give info
                    leax      -1,x
                    endc

****************
* X=ParmPtr
* Find and Set Options:

FindLp10
                    lbsr      SkipSpac            get next input param
                    stx       <ParmPtr            save for syntax error use
                    cmpa      #C$CR               end?
                    lbeq      Verify              ..yes, update module CRC
                    leay      OptTable-6,pc       ready option table ptr
                    pshs      u
                    ldu       ,x++                get next two chars
                    ora       #$20                convert 1st param char to lower case
                    exg       d,u                 move [U] where we can convert param chars
                    ora       #$20                convert 2nd param char...
                    orb       #$20                convert 3rd...
                    exg       d,u                 move back again

FindLp20
                    leay      6,y                 next option entry
                    tst       ,y                  last entry?
                    bmi       Syntax              ..yes, bad option
                    cmpa      1,y
                    bne       FindLp20            same name?
                    cmpu      2,y
                    bne       FindLp20            ..no, loop
* Found Option
                    puls      u
                    sty       <TxtPtr
                    ldd       ,x+                 must be followed by "=", leave [X] pointing at char after "="
                    cmpa      #'=
                    bne       Syntax
                    cmpb      #C$CR               rest of option missing?
                    beq       Syntax              yes, go report error
                    cmpb      #C$SPAC             rest of option missing?
                    beq       Syntax              yes, go report error
                    ldb       5,y                 get # of bytes
                    beq       Syntax              0 bytes, not allowed to change this option
                    stb       <Count
                    ldb       4,y                 get option offset or offset to option offset
                    ifne      XMODE
                    bpl       NumOpt              option offset, go set hexadecimal option
* Get CHAR input and set option:
                    andb      #^Sign              clear sign bit of offset to string offset
                    clra                          [D] = offset to string offset within module
                    cmpd      <ModSize            is it OK?
                    bhs       Syntax              no, go report error...
                    leay      ModBuff,u           point to module
                    ldd       b,y                 get offset to string
                    cmpd      <ModSize            is it OK?
                    bhs       Syntax              no, go report error...
                    leay      d,y                 point to option
                    pshs      y                   save option pointer
                    os9       F$PrsNam            valid OS-9 name?
                    puls      y                   recover option pointer (end of name pointer lost)
                    bcs       Syntax              no, go report error
                    cmpa      #C$SPAC             space delimiter char?
                    beq       ChkLen              yes, go check name length...
                    cmpa      #C$CR               <CR> delimiter char?
                    bne       Syntax              no, go report error

ChkLen
                    cmpb      <Count              name length OK?
                    bhi       Syntax              no, go report error...

SetChrLp
                    lda       ,x+                 get character
                    sta       ,y+                 save it to module copy
                    decb                          done yet?
                    bne       SetChrLp            no, go copy another char...
                    lda       -1,y                get last char
                    ora       #Sign               set sign bit
                    sta       -1,y                save last char
                    lbra      FindLp10            go do next...
                    else
                    lbra      NumOpt              option offset, go set hexadecimal option
                    endc

* Syntax Error:
Syntax
                    leax      SynMsg,pc
                    ldy       #SynLen
                    lda       #2
                    os9       I$Write
                    ldx       <ParmPtr
                    leax      -1,x
                    pshs      x
                    ldy       #0

CntLoop
                    leay      1,y
                    lda       ,x+
                    cmpa      #C$CR
                    beq       SynSay
                    cmpa      #C$SPAC
                    bne       CntLoop

SynSay
                    puls      x
                    lda       #2
                    os9       I$Write             output err
                    lbra      OkayEnd

* Get Hex Input and Set Option:
NumOpt
                    ifne      XMODE
                    clra                          [D] = option offset within module
                    cmpd      <OptEnd             is it OK?
                    bhs       Syntax              no, go report error...
                    endc
                    clr       <HexIn              zero hex input bytes
                    clr       <HexIn+1

SetNumLp
                    lda       ,x+                 get next #
                    cmpa      #C$SPAC             end of number?
                    beq       SetNum2             ..yes, set option
                    cmpa      #C$CR               end of line?
                    beq       SetNum1             ..yes, set option
* Convert ASCII Hex-->Byte:
                    suba      #$30                make number from ASCII
                    bmi       Syntax
                    cmpa      #10                 is it number?
                    bcs       Num
                    anda      #$5F                make uppercase
                    suba      #$11-$0A            make hex $A-$F
                    cmpa      #$0A
                    bcs       Syntax
                    cmpa      #$10                not hex char?
                    bcc       Syntax

Num
                    ldb       #16                 fancy asl *4
                    mul
                    pshs      b                   save top 4 bits
                    ldd       <HexIn
                    rol       ,s
                    rolb
                    rola
                    rol       ,s
                    rolb
                    rola
                    rol       ,s
                    rolb
                    rola
                    rol       ,s
                    rolb
                    rola
                    std       <HexIn
                    puls      b                   drop temp
                    bra       SetNumLp            ..loop

SetNum1
                    leax      -1,x                reset so can find <CR>

SetNum2
                    ldb       4,y                 get option offset
                    leay      ModBuff,u           point to module
                    leay      b,y                 point to option
                    ldd       <HexIn              pick up hex input
                    dec       <Count
                    beq       SetOne
                    std       ,y                  set two byte option
                    lbra      FindLp10

SetOne
                    tsta
                    lbne      Syntax
                    stb       ,y                  set one byte option

SetNDone
                    lbra      FindLp10

* --------------
* Skip Spaces:
SkipSpac
                    lda       ,x+
                    cmpa      #C$SPAC
                    beq       SkipSpac
                    rts

* --------------
* Update Module CRC:
Verify
                    ifne      XMODE
                    pshs      u                   save data ptr
                    leau      ModBuff,u
                    tfr       u,x                 X is mod address
                    ldy       M$Size,x            Y is mod size
                    leay      -3,y                beginning of chksum
                    tfr       y,d                 Y is byte count
                    leau      d,u                 set U to chksum
                    lda       #$FF                init chksum
                    sta       ,u
                    sta       1,u
                    sta       2,u
                    pshs      u
                    os9       F$CRC               calc new crc
                    puls      u
                    com       ,u+                 fix it up right
                    com       ,u+
                    com       ,u
                    lda       <PathNmbr           was it file?
                    beq       MemMod              ..no, in memory
                    ldx       #0
                    tfr       x,u
                    os9       I$Seek              go back to file begin
                    bcs       Error
                    puls      u
                    leax      ModBuff,u
                    ldy       <ModSize
                    os9       I$Write             update module file
                    else
                    leax      ModBuff,u
                    lda       <PathNmbr
                    clrb
                    os9       I$SetStt
                    endc
                    bra       OkayEnd

                    ifne      XMODE
MemMod
                    ldu       ,s                  get data area pointer
                    leax      ModBuff,u
                    ldy       <ModSize
                    ldu       <ModAddr

PutModLp
                    lda       ,x+
                    sta       ,u+
                    leay      -1,y
                    bne       PutModLp
                    puls      u                   recover data area pointer
                    bra       OkayEnd2
                    endc

OkayEnd
*         bsr   OutCR

OkayEnd2
                    clrb                          okay
Error
                    ifne      XMODE
                    pshs      b,cc
                    ldu       <ModAddr
                    beq       Bye
                    os9       F$UnLink

Bye
                    puls      b,cc
                    endc
                    os9       F$Exit              we're done...

* --------------
* Print a <CR>:
OutCR
                    leax      CR,pc
                    ldy       #1
                    lda       #1
                    os9       I$WritLn
                    rts

****************
* Output Current Desc Info:
Info
                    ifne      TMODE
                    lda       <PathNmbr
                    leax      Buffer,u
                    ldb       #PDELIM
                    stb       ,x+
                    ldb       #SS.DevNm
                    os9       I$GetStt
go@                 ldb       ,x+
                    bpl       go@
                    andb      #$7F
                    stb       -1,x
                    ldb       #C$CR
                    stb       ,x
                    leax      Buffer,u
                    ldy       #80
                    lda       #$01
                    os9       I$WritLn
                    endc

                    leax      OptTable,pc         point to text table
                    stx       <TxtPtr

                    clr       ,-s
InfoLoop
                    ldx       <TxtPtr
                    ldy       #4
                    lbsr      OutPut              print option name
                    leax      Equal,pc
                    ldy       #1
                    lbsr      OutPut              print =
                    ldx       <TxtPtr
                    ldb       4,x                 get offset to HEX option;  if minus, offset to option offset
                    ifne      XMODE
                    bpl       PrintHex            go do simple offset to HEX option
                    andb      #^Sign              clear sign bit
                    clra                          [D] = offset to string offset within module
                    cmpd      <ModSize            is it OK?
                    bhs       MovePtr             no, skip this option...
                    leay      ModBuff,u           point [Y] to module work copy
                    ldd       b,y                 get string offset within module
                    cmpd      <ModSize            is string offset OK?
                    bhs       MovePtr             no, skip this option...
                    leay      d,y                 point [Y] to CHAR string
                    lda       #BuffSize           get max. chars to print
                    leax      Buffer,u            point [X] to CHAR string buffer
                    clr       <Count              init counter

CharCopy            ldb       ,y+                 get char
                    bpl       NotLast             sign bit clear so not last, go on...
                    andb      #^Sign              clear sign bit
                    lda       #1                  set up as last char

NotLast             stb       ,x+
                    inc       <Count              count chars in string
                    deca                          done yet?
                    bne       CharCopy            no, go do another char...
                    ldb       <Count              get chars in string ([A]=0, so [D]=char count)
                    tfr       d,y                 module name length into [Y]
                    leax      Buffer,u            point [X] to CHAR string copy
                    bsr       OutPut              print CHAR string
                    bra       MovePtr             skip HEX output routine
                    endc

* Print Hex Option Values:
PrintHex
                    ldx       <TxtPtr
                    ldb       5,x                 get # of digits
                    stb       <Count
                    ldb       4,x                 get option offset in module
                    ifne      XMODE
                    clra                          [D] = option offset within module
                    cmpd      <OptEnd             is option offset OK?
                    bhs       MovePtr             no, skip this option...
                    endc
                    leax      ModBuff,u           point [X] to module work copy
                    abx                           point [X] to option
                    stx       <DataPtr

* Print One Byte:
NumLoop
                    ldx       <DataPtr
                    lda       ,x+
                    stx       <DataPtr
                    pshs      a
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       OutOne
                    puls      a
                    anda      #$0F
                    bsr       OutOne
                    dec       <Count
                    bne       NumLoop

MovePtr
                    ldx       <TxtPtr
                    leax      6,x
                    stx       <TxtPtr
                    ldb       ,s+
                    incb
                    cmpb      #TablOpts
                    lbeq      OkayEnd             done...
                    pshs      b
                    bitb      #$07                # of options remaining evenly divisible by eight?
                    lbne      InfoLoop            no, go print next option on same line
                    lbsr      OutCR               <CR> after every 8th option
                    lbra      InfoLoop            ..loop

* --------------
* Print 1/2 Byte Hex Char:
OutOne
                    cmpa      #10
                    bcs       Number
                    adda      #$11-10             make alpha

Number
                    adda      #$30                make ASCII
                    sta       <Buffer
                    leax      Buffer,u
                    ldy       #1

OutPut
                    lda       #$01
                    os9       I$Write
                    lbcs      Error
                    rts

                    emod
Size                equ       *
                    end

