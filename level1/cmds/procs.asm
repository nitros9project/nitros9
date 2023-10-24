********************************************************************
* Procs - Show processes
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   9      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.
*
*  10      2003/01/14  Boisy G. Pitre
* Now uses -e instead of e.

                    nam       Procs
                    ttl       program module

* Disassembled 02/04/05 13:22:14 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       10

                    mod       eom,name,tylg,atrv,start,size

                    org       0
narrow              rmb       1
eflag               rmb       1
aproc               rmb       2
wproc               rmb       2
sproc               rmb       2
myuid               rmb       2
u000A               rmb       1
bufptr              rmb       2
buffer              rmb       87
u0064               rmb       132
u00E8               rmb       2156
PsBuf               rmb       450
size                equ       .

name                fcs       /Procs/
                    fcb       edition

L0013               fcb       C$LF
                    fcc       "Usr #  id pty sta mem pri mod"
                    fcb       C$CR
DshSh               fcs       "----- --- --- --- --- -------"
ActSh               fcs       " act "
WaiSh               fcs       " wai "
SleSh               fcs       " sle "
L005E               fcb       C$LF
                    fcc       "Usr #  id pty  state   mem primary module"
                    fcb       C$CR
DshLo               fcs       "----- --- --- -------- --- --------------"
ActLo               fcs       "  active  "
WaiLo               fcs       "  waiting "
SleLo               fcs       " sleeping "

start               clr       <eflag
                    clr       <narrow
                    pshs      y,x,b,a
                    lda       #$01
                    ldb       #SS.ScSiz
                    os9       I$GetStt
                    bcc       L00E8
                    cmpb      #E$UnkSvc
                    beq       L00EF
                    puls      y,x,b,a
                    lbra      L01F1
L00E8               cmpx      #50
                    bge       L00EF
                    inc       <narrow
L00EF               puls      y,x,b,a
*
* Check for a '-E' as argument
*
                    ldd       ,x+
                    andb      #$DF
                    cmpd      #$2D45
                    bne       L00FB
                    inc       <eflag
L00FB               leax      buffer,u
                    stx       <bufptr
                    orcc      #IntMasks
                    ldx       >D.AProcQ
                    stx       <aproc
                    ldx       >D.WProcQ
                    stx       <wproc
                    ldx       >D.SProcQ
                    stx       <sproc
                    ldx       >D.Proc
                    ldd       P$User,x
                    std       <myuid
                    pshs      u
                    leau      >PsBuf,u            Assign buffer to reg u
                    lda       #$01
                    ldx       <aproc
                    lbsr      LoopP
                    lda       #$02
                    ldx       <wproc
                    lbsr      LoopP
                    lda       #$03
                    ldx       <sproc
                    lbsr      LoopP
                    andcc     #^IntMasks
                    clra
                    clrb
                    pshu      b,a
                    pshu      b,a
                    puls      u
                    tst       <narrow
                    beq       L0156
                    leay      >L0013,pcr
                    lbsr      WritY
                    lbsr      WrBuf
                    leay      >DshSh,pcr          Write short dashes
                    lbsr      WritY
                    lbsr      WrBuf
                    bra       L016A

* Write 80 char header
L0156               leay      >L005E,pcr
                    lbsr      WritY
                    lbsr      WrBuf
                    leay      >DshLo,pcr          Write long dashes
                    lbsr      WritY
                    lbsr      WrBuf

L016A               leax      >PsBuf,u
NextW               leax      -$09,x
                    ldd       $05,x
                    beq       Finish
                    ldd       $07,x
                    lbsr      L0250
                    lbsr      WrSpc               Write Space
                    ldb       ,x
                    lbsr      L0214
                    lbsr      WrSpc               Write Space
                    ldb       $03,x
                    lbsr      L0214
                    lda       $04,x
                    tst       <narrow
                    beq       L0195
                    leay      >ActSh,pcr
                    bra       L0199
L0195               leay      >ActLo,pcr
L0199               cmpa      #$01
                    beq       L01BD               branch if status is active
                    tst       <narrow
                    beq       L01A7
                    leay      >WaiSh,pcr
                    bra       L01AB
L01A7               leay      >WaiLo,pcr
L01AB               cmpa      #$02
                    beq       L01BD               branch if status is waiting
                    tst       <narrow
                    beq       L01B9
                    leay      >SleSh,pcr
                    bra       L01BD
L01B9               leay      >SleLo,pcr
L01BD               bsr       WritY
                    ldb       $02,x
                    bsr       L0214
                    bsr       WrSpc               Write Space
                    ldy       $05,x
                    ldd       $04,y
                    leay      d,y
                    bsr       WritY
                    bsr       WrSpc               Write Space
                    tst       <narrow
                    bne       L01EB
                    lda       #'<
                    bsr       WriCh
                    lda       $01,x
                    lbsr      L02B5
                    bcs       L01EB
                    ldy       $03,y
                    ldy       $04,y
                    ldd       $04,y
                    leay      d,y
                    bsr       WritY
L01EB               bsr       WrBuf
                    lbra      NextW               Next line

Finish              clrb
L01F1               os9       F$Exit
*
* Write text pointed to by Reg Y to buffer
*
WritY               lda       ,y
                    anda      #$7F
                    bsr       WriCh
                    lda       ,y+
                    bpl       WritY
                    rts
*
* Write out buffer to stdout (max 80 chars)
*
WrBuf               pshs      y,x,a
                    lda       #C$CR
                    bsr       WriCh
                    leax      buffer,u
                    stx       <bufptr
                    ldy       #80
                    lda       #$01
                    os9       I$WritLn
                    puls      pc,y,x,a

L0214               clr       <u000A
                    lda       #$FF
L0218               inca
                    subb      #100
                    bcc       L0218
                    bsr       L022E
                    lda       #10
L0221               deca
                    addb      #10
                    bcc       L0221
                    bsr       L022E
                    tfr       b,a
                    adda      #'0
                    bra       WriCh
L022E               tsta
                    beq       L0233
                    sta       <u000A
L0233               tst       <u000A
                    bne       L0239
WrSpc               lda       #$F0
L0239               adda      #'0
*
* Add char to buffer pointed to by bufptr
*
WriCh               pshs      x
                    ldx       <bufptr
                    sta       ,x+
                    stx       <bufptr
                    puls      pc,x

L0245               fcb       $27,$10,$03,$e8,$00,$64,$00,$0a,$00,$01,$ff

L0250               pshs      x,y,a,b
                    leax      <L0245,pcr
                    ldy       #$2F20
L0259               leay      >$0100,y
                    subd      ,x
                    bcc       L0259
                    addd      ,x++
                    pshs      b,a
                    tfr       y,d
                    tst       ,x
                    bmi       L0281
                    ldy       #$2F30
                    cmpd      #$3020
                    bne       L027B
                    ldy       #$2F20
                    lda       #C$SPAC
L027B               bsr       WriCh
                    puls      b,a
                    bra       L0259
L0281               bsr       WriCh
                    leas      $02,s
                    puls      pc,y,x,b,a
*
* Loop through list of processes
* Reg X contains the pointer
*
LoopP               pshs      y,b,a
                    leax      ,x                  point to first entry in queue
                    beq       EndP
NextP               ldd       P$User,x
                    tst       <eflag
                    bne       L0298
                    cmpd      <myuid
                    bne       ContP
L0298               pshu      b,a                 put userid on stack
                    lda       P$Prior,x
                    ldb       ,s
                    ldy       <P$PModul,x
                    pshu      y,b,a               put module,priority,status on stack
                    lda       P$PagCnt,x
                    pshu      a                   put pagecount on stack
                    lda       P$ID,x
                    ldb       <P$PATH,x
                    pshu      b,a
ContP               ldx       P$Queue,x
                    bne       NextP
EndP                puls      pc,y,b,a

L02B5               pshs      x,b,a
                    ldx       >D.PthDBT
                    tsta
                    beq       L02CC
                    clrb
                    lsra
                    rorb
                    lsra
                    rorb
                    lda       a,x
                    tfr       d,y
                    beq       L02CC
                    tst       ,y
                    bne       L02CD
L02CC               coma
L02CD               puls      pc,x,b,a

                    emod
eom                 equ       *
                    end
