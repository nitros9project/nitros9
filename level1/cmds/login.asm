********************************************************************
* Login - Timeshare login utility
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  16      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.
*
*  17      1999/05/11  Boisy G. Pitre
* Fixed for years 1900-2155.
*
*  18      2002/07/20  Boisy G. Pitre
* Changed icpt routine rts to rti, put in conditionals for Level One
* not to execute the os9 F$SUser command.
*
*  19      2010/01/29  Boisy G. Pitre
* Changed icpt routine to honor the S$HUP signal and exit

                    nam       Login
                    ttl       Timeshare login utility

* Disassembled 02/07/13 23:49:05 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       19

                    mod       eom,name,tylg,atrv,start,size

NUMTRIES            set       3

                    org       0
u0000               rmb       1
passpath            rmb       1
motdpath            rmb       1
retries             rmb       1
defuid              rmb       1
priority            rmb       1
passline            rmb       2
rdbufptr            rmb       2
buffnext            rmb       2
convbyte            rmb       1
timebuff            rmb       5
linebuff            rmb       128
readbuff            rmb       80
outbuf              rmb       80
popts               rmb       32
stack               rmb       251
size                equ       .

name                fcs       /Login/
                    fcb       edition


initmod             fcs       "init"

passfile            fcc       "SYS/PASSWORD"
                    fcb       C$CR
UName               fcb       C$LF
                    fcc       "User name?: "
UNameLen            equ       *-UName

Who                 fcc       "Who?"
                    fcb       C$CR

Pass                fcc       "Password: "
PassLen             equ       *-Pass
nvPass              fcc       "Invalid password."
                    fcb       C$CR

ProcNum             fcb       C$LF
                    fcc       "Process #"
ProcNumL            equ       *-ProcNum

lo1                 fcc       " logged on "
lo1len              equ       *-lo1

lo2                 fcc       " logged on "
                    fcb       C$LF
lo2len              equ       *-lo2

Welcome             fcc       "Welcome!"
                    fcb       C$CR

DirNotFnd           fcc       "Directory not found."
                    fcb       C$CR

Syntax              fcb       C$LF
                    fcc       "Syntax Error in password file"

onthe               fcc       "on the "
onthel              equ       *-onthe

Sorry               fcb       C$LF
                    fcc       "It's been nice communicating with you."
                    fcb       C$LF
                    fcc       "Better luck next time."
                    fcb       C$CR

MOTD                fcc       "SYS/MOTD"
                    fcb       C$CR

root                fcc       "...... "

IcptRtn
                    cmpb      #S$HUP
                    lbeq      Exit
                    rti                           note, was rts in original code

* Entry: X = pointer to start of nul terminated string
* Exit:  D = length of string
strlen              pshs      x
                    ldd       #-1
go@                 addd      #$0001
                    tst       ,x+
                    bne       go@
                    puls      x,pc

start               pshs      y,x
                    leax      <IcptRtn,pcr
                    os9       F$Icpt
                    ifgt      Level-1
                    bcs       L0172
                    ldy       #$0000              super user ID
                    os9       F$SUser             set user ID to super user
                    endc
L0172               puls      y,x
                    lbcs      Exit
*         clr   <u0000
                    leay      >outbuf,u
                    sty       <buffnext
                    leay      >readbuff,u
                    sty       <rdbufptr
                    std       ,--s
                    beq       L0194
L018C               lda       ,x+
                    sta       ,y+
                    cmpa      #C$CR
                    bne       L018C
L0194
*         lda   #$01
*         ldb   #SS.ScSiz
*         os9   I$GetStt
*         bcc   L01A4
*         cmpb  #E$UnkSvc
*         beq   L01AB
*         lbra  L0280
*L01A4    cmpx  #51
*         bcc   L01AB
*         inc   <u0000
L01AB               lda       #READ.
                    leax      >root,pcr           point to root dir string
                    os9       I$ChgDir            and change to that directory
                    lda       #READ.
                    leax      >passfile,pcr
                    os9       I$Open              open password file
                    lbcs      Exit
                    sta       <passpath           and save path
                    lda       #NUMTRIES
                    sta       <retries            initialize the retry counter
                    ldd       ,s++
                    beq       L01D3
                    ldx       <rdbufptr
                    lda       ,x
                    cmpa      #C$CR
                    bne       L0209
L01D3
*         tst   <u0000
*         beq   L01E1
*         leax  >NrrwMsg,pcr
*         ldy   #NrrwMsgL
*         bra   L01E9
L01E1
                    leax      initmod,pcr
                    clra
                    pshs      u
                    os9       F$Link
                    tfr       u,x
                    puls      u
                    bcs       L01EC
                    pshs      x
                    ldd       OSName,x            point to OS name in INIT module
                    leax      d,x                 point to install name in INIT module
                    lbsr      strlen
                    tfr       d,y
                    lbsr      copystr
                    lbsr      putspace
                    leax      onthe,pcr
                    ldy       #onthel
                    lbsr      copystr

                    puls      x
                    ldd       InstallName,x
                    leax      d,x                 point to install name in INIT module
                    lbsr      strlen
                    tfr       d,y
                    lbsr      strandtime
                    lbsr      L04A4

L01EC               dec       <retries
                    leax      >Sorry,pcr
                    lbmi      L031F
                    leax      >readbuff,u
                    stx       <rdbufptr
                    leax      >UName,pcr
                    ldy       #UNameLen
                    lbsr      L0347
                    bcs       L020E
L0209               lbsr      readpassword
                    bcc       L0217
L020E               leax      >Who,pcr
L0212               lbsr      writeX
                    bra       L01EC
L0217               lbsr      L03B9
                    bcc       L0253
                    ldx       <rdbufptr
                    lda       ,x
                    cmpa      #C$CR
                    bne       L0242
                    lda       #C$COMA
                    sta       ,x+
                    stx       <rdbufptr
                    lbsr      killecho
                    leax      >Pass,pcr
                    ldy       #PassLen
                    lbsr      L0347
                    lbsr      setopts
                    bcs       L020E
                    lbsr      L03B9
                    bcc       L0253
L0242               leax      >readbuff,u
                    stx       <rdbufptr
                    lbsr      L03A1
                    bcc       L0217
                    leax      >nvPass,pcr
                    bra       L0212
L0253               lda       <passpath
                    os9       I$Close
                    lbsr      L0408
                    tfr       d,y
                    ifgt      Level-1
                    os9       F$SUser
                    endc
                    lbsr      L0408
                    tsta
                    lbne      L031B
                    tstb
                    lbeq      L031B
                    stb       <priority
                    os9       F$ID                get user id
                    sta       <defuid             save off
                    lda       #READ.
                    leax      >MOTD,pcr
                    os9       I$Open
                    bcc       L0280
                    clra
L0280               sta       <motdpath
                    lda       #$04
                    bsr       L02F7
                    lda       #$03
                    bsr       L02F7
                    leax      >ProcNum,pcr
                    ldy       #ProcNumL
                    lbsr      copystr
                    leax      defuid,u
                    lbsr      L0471
*         tst   <u0000
*         beq   L02A8
*         leax  >lo2,pcr
*         ldy   #lo2len
*         bra   L02B0
L02A8               leax      >lo1,pcr
                    ldy       #lo1len
L02B0               bsr       strandtime
                    leax      >Welcome,pcr
                    bsr       writeX
                    lbsr      L03F0
                    clrb
                    ldx       <passline           get password line in X
                    leau      ,x
L02C0               lda       ,u+
                    cmpa      #'0
                    bcc       L02C0
                    cmpa      #C$COMA
                    beq       L02CC
                    leau      -passpath,u
L02CC               lda       ,u+
                    cmpa      #C$SPAC
                    beq       L02CC
                    leau      -passpath,u
                    pshs      u
                    ldy       #$0000
L02DA               lda       ,u+
                    leay      $01,y
                    cmpa      #C$CR
                    bne       L02DA
                    puls      u
                    lda       <defuid
                    ldb       <priority
                    os9       F$SPrior            set priority
                    ldd       #256
                    os9       F$Chain
                    os9       F$PErr
Exit                os9       F$Exit
L02F7               ldx       <passline
                    os9       I$ChgDir
                    bcs       L0315
                    ldx       <passline
L0300               lda       ,x+
                    cmpa      #C$CR
                    beq       L031B
                    cmpa      #C$COMA
                    bne       L0300
                    lda       #C$SPAC
L030C               cmpa      ,x+
                    beq       L030C
                    leax      ,-x
                    stx       <passline
                    rts
L0315               leax      >DirNotFnd,pcr
                    bra       L031F
L031B               leax      >Syntax,pcr
L031F               bsr       writeX
                    clrb
                    os9       F$Exit

* Entry: X = ptr to string to write
writeX              ldy       #256
                    lda       #$01
                    os9       I$WritLn
                    rts

strandtime
                    bsr       copystr
                    lbsr      putspace
                    lbsr      putspace
                    lbra      puttime

* Entry: X = ptr to string to copy
*        Y = length of string
copystr
                    cmpy      #$0000
                    beq       copyex
                    lda       ,x+
                    lbsr      puta
                    leay      -$01,y
                    bne       copystr
copyex              rts

L0347               bsr       copystr
                    lbsr      writestr
                    ldx       <rdbufptr
                    ldy       #80
                    clra
                    os9       I$ReadLn
                    rts

killecho            pshs      x,b,a
                    leax      >popts,u
                    ldb       #SS.Opt             get path options
                    clra                          for stdin
                    os9       I$GetStt            get status
                    bcs       notscf              branch if error
                    lda       (PD.OPT-PD.FST),x   get path type
                    cmpa      #DT.SCF             SCF device?
                    bne       notscf              branch if not
                    lda       (PD.EKO-PD.FST),x
                    pshs      a                   save path echo flag
                    clr       (PD.EKO-PD.FST),x
                    bsr       setopts
                    puls      a
                    sta       (PD.EKO-PD.FST),x
                    puls      pc,x,b,a
notscf              lda       #$FF
                    sta       (PD.OPT-PD.FST),x
                    puls      pc,x,b,a
setopts             pshs      x,b,a,cc
                    leax      >popts,u
                    lda       (PD.OPT-PD.FST),x
                    cmpa      #DT.SCF
                    bne       L0391
                    ldb       #SS.Opt
                    clra
                    os9       I$SetStt
L0391               puls      pc,x,b,a,cc

readpassword
                    pshs      u
                    lda       <passpath           get path to password file
                    ldx       #$0000              seek to file position zero
                    leau      ,x
                    os9       I$Seek              now...
                    puls      u
L03A1               lda       <passpath
                    leax      >linebuff,u         read a line from the password file
                    ldy       #128
                    os9       I$ReadLn
                    bcs       L03B8               branch if error
                    stx       <passline           else save pointer to line
                    bsr       L03B9
                    bcs       L03A1
                    stx       <passline
L03B8               rts
L03B9               ldx       <passline
                    ldy       <rdbufptr
L03BE               lda       ,x+
                    cmpa      #C$COMA
                    beq       L03D2
                    cmpa      #C$CR
                    beq       L03D0
                    eora      ,y+
                    anda      #$DF
                    beq       L03BE
L03CE               comb
                    rts
L03D0               leax      -$01,x
L03D2               lda       ,y+
                    cmpa      #C$COMA
                    beq       L03DE
                    cmpa      #'0
                    bcc       L03CE
                    leay      -$01,y
L03DE               lda       ,y+
                    cmpa      #C$SPAC
                    beq       L03DE
                    leay      -$01,y
                    sty       <rdbufptr
                    stx       <passline
                    clrb
                    rts
L03ED               lbsr      writeX
L03F0               lda       <motdpath
                    beq       L0406
                    leax      >readbuff,u
                    ldy       #80
                    os9       I$ReadLn
                    bcc       L03ED
                    lda       <motdpath
                    os9       I$Close
L0406               clrb
                    rts

L0408               ldx       <passline
                    clra
                    clrb
                    pshs      y,x,b,a
                    pshs      b
L0410               ldb       ,x+
                    cmpb      #C$PERD
                    bne       L0423
                    tsta
                    lbne      L031B
                    ldb       $02,s
                    stb       ,s
                    clr       $02,s
                    bra       L0410
L0423               subb      #$30
                    cmpb      #$09
                    bhi       L043C
                    clra
                    ldy       #$000A
L042E               addd      $01,s
                    lbcs      L031B
                    leay      -$01,y
                    bne       L042E
                    std       $01,s
                    bra       L0410
L043C               lda       -$01,x
                    cmpa      #C$COMA
                    lbne      L031B
                    stx       <passline
                    lda       ,s+
                    beq       L0452
                    tst       ,s
                    lbne      L031B
                    sta       ,s
L0452               puls      pc,y,x,b,a

puttime             leax      timebuff,u
                    os9       F$Time              get current time
                    bsr       Y2K                 put Y2K compliant time string
                    bsr       putspace            put space
                    bsr       L0461
                    bra       L04A4
L0461               bsr       L0471
                    bsr       putcolon
putcolon            lda       #':
                    bra       L046F

Y2K                 lda       #19                 start out in 19th century
                    ldb       ,x                  get year
CntyLp              subb      #100                subtract
                    bcs       GotCntry            if carry set, we have century
                    inca
                    bra       CntyLp              continue
GotCntry            addb      #100
                    stb       ,x
                    tfr       a,b
PrCnty              bsr       Byt2ASC
L0469               bsr       L0471
                    bsr       Slash
Slash               lda       #'/
L046F               bsr       puta                add slash to buffer
L0471               ldb       ,x+
Byt2ASC             lda       #$2F
                    clr       <convbyte
L0477               inca
                    subb      #100
                    bcc       L0477
                    bsr       L048D
                    lda       #$3A
L0480               deca
                    addb      #10
                    bcc       L0480
                    bsr       puta
                    tfr       b,a
                    adda      #'0
                    bra       puta
L048D               inc       <convbyte
                    cmpa      #'0
                    bne       puta
                    dec       <convbyte
                    bne       puta
                    rts

putspace            lda       #C$SPAC
puta                pshs      x
                    ldx       <buffnext
                    sta       ,x+
                    stx       <buffnext
                    puls      pc,x

L04A4               pshs      a
                    lda       #C$CR
                    bsr       puta
                    puls      a
writestr            pshs      y,x,b,a
                    leax      >outbuf,u
                    ldd       <buffnext
                    stx       <buffnext
                    subd      <buffnext
                    tfr       d,y
                    lda       #$01
                    os9       I$WritLn
                    puls      pc,y,x,b,a

                    emod
eom                 equ       *
                    end
