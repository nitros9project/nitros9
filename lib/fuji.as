********************************************************************
* fuji - FujiNet routines
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2024/09/12  Boisy G. Pitre
* Started.

                    section   bss
nbufferl            equ       128
nbuffer             rmb       nbufferl
                    endsect

                    section   code

space               fcb       C$SPAC
devnam              fcs       "/N"

getopts             leax      nbuffer,u
                    ldb       #SS.Opt
                    os9       I$GetStt
                    rts

setopts             leax      nbuffer,u
                    ldb       #SS.Opt
                    os9       I$SetStt
                    rts

* Set Echo On
*
* Entry: A = path to network device
* Exit:
*        Success: CC carry clear
*        Failure: CC carry set, B = error code
SetEchoOn           pshs      a,x
                    bsr       getopts
                    bcs       rawex
                    ldb       #1
                    stb       PD.EKO-PD.OPT,x
                    bsr       setopts
                    puls      a,x,pc


* Set Echo Off
*
* Entry: A = path to network device
* Exit:
*        Success: CC carry clear
*        Failure: CC carry set, B = error code
SetEchoOff          pshs      a,x
                    bsr       getopts
                    bcs       rawex
                    clr       PD.EKO-PD.OPT,x
                    bsr       setopts
                    puls      a,x,pc


* Set Auto Linefeed On
*
* Entry: A = path to network device
* Exit:
*        Success: CC carry clear
*        Failure: CC carry set, B = error code
SetAutoLFOn         pshs      a,x
                    bsr       getopts
                    bcs       rawex
                    ldb       #1
                    stb       PD.ALF-PD.OPT,x
                    bsr       setopts
                    puls      a,x,pc


* Set Auto Linefeed Off
*
* Entry: A = path to network device
* Exit:
*        Success: CC carry clear
*        Failure: CC carry set, B = error code
SetAutoLFOff        pshs      a,x
                    bsr       getopts
                    bcs       rawex
                    clr       PD.ALF-PD.OPT,x
                    bsr       setopts
                    puls      a,x,pc


* Put the path passed in A in raw mode
*
* Entry: A = path to network device
*
* Exit:
*        Success: CC carry clear
*        Failure: CC carry set, B = error code
RawPath             pshs      a,x
                    bsr       getopts
                    bcs       rawex
                    leax      PD.UPC-PD.OPT,x
                    ldb       #PD.QUT-PD.UPC
rawloop             clr       ,x+
                    decb
                    bpl       rawloop
                    bsr       setopts
rawex               puls      a,x,pc


* Attempts to open and setup a path to the FujiNet server
*
* Exit:
*        Success: A = path to network device, CC carry clear
*        Failure: B = error code, CC carry set
NOpen               pshs      x,y
                    lda       #UPDAT.
                    leax      devnam,pcr
                    os9       I$Open
                    bcs       openerr
                    bsr       SetEchoOff
                    bsr       SetAutoLFOff
openerr
                    puls      x,y,pc

                    endsect
