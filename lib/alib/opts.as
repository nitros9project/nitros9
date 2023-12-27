************************************************
*
* SCF path option routines

* ENTRY: A=path number

* EXIT: all registers (except cc) preserved

                    use       scf.d

                    section   .bss
orgopts             rmb       OPTCNT
modopts             rmb       OPTCNT
                    endsect

                    section   .text

getopts             leax      modopts,u
getnonmodopts       ldb       #SS.Opt
                    os9       I$GetStt
                    rts

setopts             leax      modopts,u
setnonmodopts       ldb       #SS.Opt
                    os9       I$SetStt
                    rts

*
*
* Save options
*
* Entry: A = path to device
*
* Exit:
*        Success: CC carry clear
*        Failure: CC carry set, B = error code
SaveOpts            pshs      d,x
                    leax      orgopts,u           point to original options buffer
                    bsr       getnonmodopts
                    bcs       ex@                 branch if error
                    bsr       getopts
ex@                 puls      d,x,pc

*
*
* Restore options
*
* Entry: A = path to network device
*
* Exit:
*        Success: CC carry clear
*        Failure: CC carry set, B = error code
RestoreOpts         pshs      d,x
                    leax      orgopts,u           point to original options buffer
                    bsr       setnonmodopts
ex@                 puls      d,x,pc


*
* Put the path passed in A in raw mode
*
* Entry: A = path to network device
*
* Exit:
*        Success: CC carry clear
*        Failure: CC carry set, B = error code
RawPath             pshs      d,x
                    leax      modopts,u
                    leax      PD.UPC-PD.OPT,x
                    ldb       #PD.QUT-PD.UPC
l@                  clr       ,x+
                    decb
                    bpl       l@
                    bsr       setopts
ex@                 puls      d,x,pc

* Set Quit Character
*
* Entry: A = path to network device
*        B = new quit character
* Exit:
*        Success: CC carry clear
*        Failure: CC carry set, B = error code
SetQuitChar         pshs      d,x
                    leax      modopts,u
                    stb       PD.QUT-PD.OPT,x
                    bsr       setopts
ex@                 puls      d,x,pc

* Set Echo On
*
* Entry: A = path to network device
*        B = echo flag (1 = echo, 0 = don't echo)
* Exit:
*        Success: CC carry clear
*        Failure: CC carry set, B = error code
SetEcho             pshs      d,x
                    leax      modopts,u
                    stb       PD.EKO-PD.OPT,x
                    bsr       setopts
ex@                 puls      d,x,pc

                    endsect
