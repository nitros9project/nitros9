********************************************************************
* inetd - internet daemon
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2010/01/08  Boisy G. Pitre
* Started.
*
*   2      2010/01/22  Boisy G. Pitre
* Now reads inetd.conf file.
*
*   3      2011/08/07  Boisy G. Pitre
* Fixed bug where conf file wasn't being processed correctly.

                    nam       inetd
                    ttl       internet daemon

                    section   __os9
type                equ       Prgrm
lang                equ       Objct
attr                equ       ReEnt
rev                 equ       $00
edition             equ       3
stack               equ       200
                    endsect

                    section   bss
targetport          rmb       2
netdatardy          rmb       1
nbufferl            equ       128
nbuffer             rmb       nbufferl
lbufferl            equ       128
lbuffer             rmb       lbufferl
nnext               rmb       2
token               rmb       2
orgstdin            rmb       1
orgstdout           rmb       1
orgstderr           rmb       1
childnetpath        rmb       1
netpath             rmb       1
targetprog          rmb       128
targetparams        rmb       128
tmodeparamlen       rmb       1
tmodeparams         rmb       128
                    endsect

                    section   code

DEBUG               equ       1


NetSig              equ       2

tmode               fcs       /tmode/

* signal intercept routine
sigint              cmpb      #NetSig
                    bne       sigex
                    inc       netdatardy,u
sigex               rti

**** Entry Point ****
__start
* setup signal intercept
                    leax      sigint,pcr
                    os9       F$Icpt

                    clr       netdatardy,u

                    leax      nbuffer,u
                    stx       nnext,u

* Turn off pause in standard out
                    ldd       #$01*256+SS.Opt
                    leas      -32,s
                    tfr       s,x
                    os9       I$GetStt
                    bcs       opterr
                    clr       PD.PAU-PD.OPT,x
                    os9       I$SetStt
opterr
                    leas      32,s

* open the path to the control channel
                    lbsr      TCPOpen
                    lbcs      errex
                    sta       netpath,u
                    leax      SetupPorts,pcr
                    lbsr      ProcInetd
                    lbcs      errex

                    ifne      DEBUG
                    lbsr      PRINTS
                    fcc       /Got netpath and setup ports/
                    fcb       C$CR
                    fcb       $00
                    endc

ssignetpath
                    ifne      DEBUG
                    lbsr      PRINTS
                    fcc       /SS.SSig on NetPath/
                    fcb       C$CR
                    fcb       $00
                    endc

                    lda       netpath,u
                    ldb       #SS.SSig            send signal on data ready
                    ldx       #NetSig
                    os9       I$SetStt
                    lbcs      errex

**** MAIN LOOP ****
mainloop
                    pshs      cc
                    orcc      #IntMasks
                    tst       netdatardy,u
                    bne       gotdata

* wait for a child to die (or wake up via signal)
                    os9       F$Wait
                    bcc       chkrdy
                    cmpb      #E$NoChld
                    bne       chkrdy              got error other than "no children"
* if no children, go to sleep
                    ldx       #$0000
                    os9       F$Sleep

chkrdy              puls      cc
                    bra       ssignetpath

gotdata             puls      cc
                    dec       netdatardy,u
* read the data from netpath
                    ifne      DEBUG
                    lbsr      PRINTS
                    fcc       /Reading data from netpath/
                    fcb       C$CR
                    fcb       $00
                    endc

                    lda       netpath,u
                    ldb       #SS.Ready
                    os9       I$GetStt
                    bcs       ssignetpath

                    clra
                    tfr       d,y
                    lda       netpath,u
                    ldx       nnext,u
                    os9       I$Read
                    lbcs      errex
                    tfr       y,d
                    leax      d,x
                    stx       nnext,u
                    lda       -1,x
                    cmpa      #C$CR
                    lbne      ssignetpath

                    leax      nbuffer,u
                    stx       nnext,u

                    lda       #1
                    ldy       #256
                    os9       I$WritLn

* determine response
                    lda       ,x
                    cmpa      #'9
                    ble       incoming

                    cmpa      #'F
                    lbra      ssignetpath

* get token number
incoming
                    lbsr      DEC_BIN
                    std       token,u
                    ifne      DEBUG
                    pshs      d
                    lbsr      PRINTS
                    fcc       /Got token /
                    fcb       $00
                    puls      d
                    lbsr      PRINT_DEC
                    lbsr      PRINTS
                    fcb       C$CR
                    fcb       $00
                    endc

* skip over token number
                    ifne      DEBUG
                    lbsr      PRINTS
                    fcc       /To Space.../
                    fcb       C$CR
                    fcb       $00
                    endc
                    lbsr      TO_SP
                    ifne      DEBUG
                    lbsr      PRINTS
                    fcc       /To Non-Space.../
                    fcb       C$CR
                    fcb       $00
                    endc
                    lbsr      TO_NON_SP

* get port number
                    lbsr      DEC_BIN
                    std       targetport,u

                    ifne      DEBUG
                    pshs      d
                    lbsr      PRINTS
                    fcc       /Got request for port /
                    fcb       $00
                    ldd       ,s
                    lbsr      PRINT_DEC
                    lbsr      PRINTS
                    fcb       C$CR
                    fcb       $00
                    puls      d
                    endc

                    leax      ForkProcForPort,pcr
                    lbsr      ProcInetd
                    lbra      ssignetpath         we may want to tell server we have no app

errex               os9       F$Exit


* Process inetd.conf file
*
* Entry: X = processor routine
*
* - open conf file
* - read each line and get first parameter (port number)
* - send it to the processor routine at x
* - if error or end of file, close and return
ProcInetd           pshs      x
                    leax      inetdconf,pcr
                    lda       #READ.
                    os9       I$Open
                    bcs       adex
                    ifne      DEBUG
                    pshs      d
                    lbsr      PRINTS
                    fcc       /Opened inetd.conf ok/
                    fcb       C$CR
                    fcb       $00
                    puls      d
                    endc
nextline            leax      lbuffer,u
                    ldy       #lbufferl-1
                    lbsr      FGETS
                    bcs       closeup
                    lbsr      TO_NON_SP           skip any leading spaces
                    ldb       ,x                  check for EOL or comment
                    cmpb      #C$CR
                    beq       nextline
                    cmpb      #'#
                    beq       nextline
                    ifne      DEBUG
                    pshs      d,x
                    lbsr      PRINTS
                    fcc       /Reading line: /
                    fcb       $00
                    ldx       2,s
                    lbsr      PUTS
                    puls      d,x
                    endc
                    pshs      a
                    jsr       [1,s]
                    puls      a
                    bcc       nextline
closeup             cmpb      #E$EOF
                    bne       closeandex
                    clrb
closeandex          pshs      b,cc
                    os9       I$Close
                    puls      b,cc
adex                puls      x,pc


* Setup ports
* Extract first parameter at X and send to server
SetupPorts          lbsr      DEC_BIN
                    cmpd      #0
                    beq       ret0
* find comma and change it to nul
                    tfr       x,y
setuploop           lda       ,y+
                    cmpa      #C$CR
                    beq       ret0
                    cmpa      #',
                    bne       setuploop
setuplisten
                    clr       -1,y
                    ifne      DEBUG
                    pshs      d,x
                    lbsr      PRINTS
                    fcc       /Send listen/
                    fcb       C$CR
                    fcb       $00
                    puls      d,x
                    endc
                    lda       netpath,u
                    lbsr      TCPListen
ret0                rts

retcc               clrb
                    rts

* Fork Proccess that matches target port
* Extract first parameter at X and see if it matches target port
* if so, read rest of line and fork the process
* Line looks like this:  portnumberplusoptions,prog,params,path opts
ForkProcForPort
* get port number
                    lbsr      DEC_BIN
                    ifne      DEBUG
                    pshs      d
                    lbsr      PRINTS
                    fcc       /Reading port /
                    fcb       $00
                    ldd       ,s
                    lbsr      PRINT_DEC
                    lbsr      PRINTS
                    fcb       C$CR
                    fcb       $00
                    lbsr      PRINTS
                    fcc       /Comparing to port /
                    fcb       $00
                    ldd       targetport,u
                    lbsr      PRINT_DEC
                    lbsr      PRINTS
                    fcb       C$CR
                    fcb       $00
                    puls      d
                    endc
                    cmpd      targetport,u
                    lbne      retcc
* point Y to byte after comma
portloop            lda       ,y+
                    cmpa      #C$CR
                    beq       ret0
                    cmpa      #',
                    bne       portloop
                    tfr       y,x
* copy bytes up to comma at X
                    leay      targetprog,u
prgloop             lda       ,x+
                    cmpa      #',
                    beq       sethi
                    cmpa      #C$CR
                    lbeq      ret
                    sta       ,y+
                    bra       prgloop
sethi               lda       -1,y
                    ora       #$80
                    sta       -1,y
copypar             clr       tmodeparamlen,u
                    leay      targetparams,u
parloop             lda       ,x+
                    sta       ,y+
                    cmpa      #',
                    beq       procopts
                    cmpa      #C$CR
                    beq       gotprocparms

procopts
                    leay      tmodeparams,u
procoptsloop        lda       ,x+
                    sta       ,y+
                    inc       targetparams,u
                    cmpa      #C$CR
                    beq       procoptsloop

gotprocparms
                    ifne      DEBUG
                    pshs      d
                    lbsr      PRINTS
                    fcc       /Got proc and params to fork/
                    fcb       C$CR
                    fcb       $00
                    puls      d
                    endc

* ignore client port number and hostname for now
                    lbsr      TCPOpen
                    bcc       savechild

                    ldd       token,u
                    leas      -8,s
                    leax      ,s
                    lbsr      BIN_DEC
                    lda       netpath,u
                    tfr       x,y
                    lbsr      TCPKill
                    leas      8,s
                    lbra      forkex

savechild
                    sta       childnetpath,u
                    ldd       token,u
                    leas      -8,s
                    leax      ,s
                    lbsr      BIN_DEC
                    lda       childnetpath,u
                    tfr       x,y
                    lbsr      TCPJoin
                    leas      8,s
                    bcc       turnonechoalf
                    os9       I$Close
                    lbra      forkex

turnonechoalf
                    ifne      DEBUG
                    pshs      d
                    lbsr      PRINTS
                    fcc       /Turning on PD.EKO and PD.ALF/
                    fcb       C$CR
                    fcb       $00
                    puls      d
                    endc
                    lbsr      SetEchoOn
                    lbcs      ret
                    lbsr      SetAutoLFOn
                    lbcs      ret

* dup paths
duper
                    ifne      DEBUG
                    pshs      d
                    lbsr      PRINTS
                    fcc       /Duping paths/
                    fcb       C$CR
                    fcb       $00
                    puls      d
                    endc

                    clra
                    os9       I$Dup
                    lbcs      errex
                    sta       orgstdin,u
                    lda       #1
                    os9       I$Dup
                    lbcs      errex
                    sta       orgstdout,u
                    lda       #2
                    os9       I$Dup
                    lbcs      errex
                    sta       orgstderr,u

* close original stdin/out/err paths
                    clra
                    os9       I$Close
                    inca
                    os9       I$Close
                    inca
                    os9       I$Close

* Dup child net path to stdin/stdout/stderr
                    lda       childnetpath,u
                    os9       I$Dup
                    lbcs      errex
                    os9       I$Dup
                    lbcs      errex
                    os9       I$Dup
                    lbcs      errex

* fork tmode process if tmode param length > 0
                    tst       tmodeparamlen,u
                    beq       forkchild
                    pshs      u
                    leax      tmode,pcr
                    leau      tmodeparams,u
                    lda       #Objct
                    clrb
                    ldy       #256
                    os9       F$Fork
                    puls      u
                    os9       F$Wait

* fork child process
forkchild
                    pshs      u
                    leax      targetprog,u
                    leau      targetparams,u
                    lda       #Objct
                    clrb
                    ldy       #256
                    os9       F$Fork
                    puls      u
* If our F$Fork fails, do not error out...
*              bcs       ret2

* restore orginal paths
                    clra
                    os9       I$Close
                    inca
                    os9       I$Close
                    inca
                    os9       I$Close

                    lda       orgstdin,u
                    os9       I$Dup
                    lbcs      errex
                    lda       orgstdout,u
                    os9       I$Dup
                    lbcs      errex
                    lda       orgstderr,u
                    os9       I$Dup
                    lbcs      errex
                    lda       orgstdin,u
                    os9       I$Close
                    lda       orgstdout,u
                    os9       I$Close
                    lda       orgstderr,u
                    os9       I$Close
                    lda       childnetpath,u
                    os9       I$Close

                    ifne      DEBUG
                    pshs      d
                    lbsr      PRINTS
                    fcc       /Proc forked/
                    fcb       C$CR
                    fcb       $00
                    puls      d
                    endc

forkex              comb
                    ldb       #E$EOF
ret                 rts

inetdconf           fcc       "....../SYS/inetd.conf"
                    fcb       C$CR
                    endsect
