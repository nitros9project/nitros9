********************************************************************
* Park - Park a hard drive
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.
*
*   2      2002/07/13  Boisy G. Pitre
* Changed name to a mixture of upper/lowercase.

                    nam       Park
                    ttl       Park a hard drive

* Disassembled 02/07/06 21:41:10 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

DOHELP              set       0

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       2

                    mod       eom,name,tylg,atrv,start,size

                    org       0
parmptr             rmb       2
devname             rmb       20
devbuff             rmb       502
size                equ       .

name                fcs       /Park/
                    fcb       edition

                    ifne      DOHELP
HelpMsg             fcb       C$LF
                    fcc       "Use:  Park <devname> [...]"
                    fcb       C$LF
                    fcc       "      To park hard disk heads"
                    fcb       C$LF
                    fcc       "      on inner track of drive"
                    fcb       C$LF,C$CR
HelpMsgL            equ       *-HelpMsg
                    endc

Parked              fcc       " has been parked. "
                    fcb       C$CR
ParkedLen           equ       *-Parked

NoOpen              fcc       " cannot be opened."
                    fcb       C$CR
NoOpenL             equ       *-NoOpen

NoPark              fcc       " has not been parked."
                    fcb       C$CR
NoParkL             equ       *-NoPark

start               bsr       SkipSpcs            skip over spaces
                    cmpa      #C$CR               CR?
                    beq       ShowHelp            if so, show help
NextDev             cmpa      #PDELIM             else is char delim?
                    bne       ShowHelp            branch if not
                    bsr       CopyDev             copy device name
                    lda       #READ.              read permission
                    os9       I$Open              open path to device
                    bcs       OpenErr             branch if error
                    ldb       #SS.SQD             do park setstat
                    os9       I$SetStt            do it!
                    bcs       NotPark             branch if error
                    os9       I$Close             close path
                    bsr       ShowDev             show device name
                    leax      >Parked,pcr
                    ldy       #ParkedLen
WriteMsg            os9       I$WritLn
                    ldx       <parmptr            get pointer to command line
                    lda       ,x                  get char
                    cmpa      #C$CR               CR?
                    bne       NextDev             if not, park next device
ExitOk              clrb
                    os9       F$Exit
ShowHelp            equ       *
                    ifne      DOHELP
                    lda       #2                  to stderr...
                    leax      >HelpMsg,pcr        point to help message
                    ldy       #HelpMsgL           get length
                    os9       I$WritLn            then write
                    endc
                    bra       ExitOk              and exit

ShowDev             leax      devname,u           point to device name
                    lda       #2                  to stderr
                    ldy       <devbuff            get length of device
                    os9       I$Write             write it
                    rts

OpenErr             bsr       ShowDev             show device name
                    leax      >NoOpen,pcr
                    ldy       #NoOpenL
                    bra       WriteMsg            write open error

NotPark             os9       I$Close             close path
                    bsr       ShowDev             show device name
                    leax      >NoPark,pcr
                    ldy       #NoParkL
                    bra       WriteMsg            write not parked message

* Skip spaces
SkipSpcs            lda       ,x                  get char at X
                    cmpa      #C$SPAC             space?
                    bne       L0121               branch if not
                    leax      1,x                 else advance
                    bra       SkipSpcs            and get next char
L0121               rts

CopyDev             clrb
                    leay      devname,u           point to device name
                    pshs      y                   and save ptr on stack
CopyX2Y             lda       ,x+                 get byte at X
                    cmpa      #C$SPAC             space?
                    bls       L0132               if same or lower, exit loop
                    sta       ,y+                 else save at Y
                    incb                          inc b
                    bra       CopyX2Y             and continue copy
L0132               lda       #PENTIR             get ENTIRE char
                    sta       ,y+                 save after copied device
                    leax      -1,x                back up one at X
                    bsr       SkipSpcs            skip any spaces
                    stx       <parmptr            save updated pointer
                    clra
                    std       <devbuff,u          save pathlist length
                    puls      pc,x

                    emod
eom                 equ       *
                    end

