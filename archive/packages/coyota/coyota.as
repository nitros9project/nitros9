****************************************************************************
*
* coyota.as - main coyota application
*
*

                    use       os9.d

                    section   __os9
TYPE                equ       $11
ATTR                equ       $80
REVS                equ       $01
EDITION             equ       $01
STACK               equ       200
                    endsect

                    section   bss
orgopt              rmb       32
curopt              rmb       32
                    endsect

* Sleep Duration
NAPTIME             equ       6

                    section   code

* byte stream to send to window to make a 320x192 16 color gfx screen
type6               fdb       WDWEnd
                    fdb       WDWSet
                    fcb       $08,$00,$00,$28,$18,$00,$02,$02
                    fdb       WSelect
                    fdb       WCurOff
selfnt              fdb       WFont
                    fcb       $c8,$02             select 6x8 stdfont
type6L              equ       *-type6
selfntL             equ       *-selfnt

curon               fdb       WCurOn
                    fcb       $00

stdfonts
                    fcc       "SYS/stdfonts"
                    fcb       C$CR
                    endsect

                    section   bss
ch                  rmb       1
readbuf             rmb       $2000
                    endsect

                    section   code

* Intercept routine
exit
                    clra
                    clrb
                    leax      orgopt,u
                    os9       I$SetStt

                    leax      <curon,pcr
                    lbsr      PUTS
                    clrb
                    os9       F$Exit

intercept
                    cmpb      #S$Abort
                    beq       exit
                    rti


* main entry point
__start
coyota
* install intercept routine
                    leax      <intercept,pcr
                    os9       F$Icpt

* get path options
                    lda       #$01
                    clrb
                    leax      orgopt,u
                    os9       I$GetStt
                    leax      curopt,u
                    os9       I$GetStt

                    clr       PD.EKO-PD.OPT,x
                    os9       I$SetStt

* initialize instrumentation hardware
                    lbsr      insinit

* make type 6 (320x192 16 color) graphics screen and select font
Scrn                leax      <type6,pcr
                    ldy       #type6L
                    lda       #1
                    os9       I$Write
                    bcc       next

* error occurred... merge stdfonts
                    leax      <stdfonts,pcr
                    lda       #READ.
                    os9       I$Open
                    bcs       Scrn
                    leax      readbuf,u
                    pshs      a                   save path num to stack
rl                  ldy       #2048
                    os9       I$Read
                    bcs       close
                    lda       #$01
                    os9       I$Write
                    lda       ,s
                    bra       rl
close               lda       ,s+
                    os9       I$Close
                    leax      selfnt,pcr
                    ldy       #selfntL
                    lda       #$01
                    os9       I$Write

next                lbsr      dashboard           draw the dashboard

* Main processing loop:
*  - get values from various instruments
*  - display them on the appropriate section of the screen
*  - sleep a while
*  - go back and do it again!
main                lbsr      speed               update speedometer
                    lbsr      odometer            update odometer
                    lbsr      engtemp             update engine temperature
                    lbsr      fuelgauge           update fuel gauge
                    lbsr      systime             update system time
                    ldx       #NAPTIME            sleep for a bit

*		os9		F$Sleep
                    ldd       #SS.Ready
                    os9       I$GetStt
                    bcs       main
                    leax      ch,u
                    ldy       #$0001
                    os9       I$Read
                    lda       ,x
                    cmpa      #'x
                    bne       main
                    lbsr      speedplus

                    bra       main



* ENTRY: X=buffer for ascii string
*        D=binary value to convert

* EXIT: all registers (except cc) preserved

                    endsect
