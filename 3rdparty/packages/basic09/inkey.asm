********************************************************************
* Inkey - Key detect subroutine
*
* $Id$
*
* Called by: RUN INKEY(StrVar)
*            RUN INKEY(Path, StrVar)
* Inkey determines if a key has been typed on the given path
* (Standard Input if not specified), and if so, returns the next
* character in the String Variable.  If no key has been type, the
* null string is returned. If a path is specified, it must be
* either type BYTE or INTEGER.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          ????/??/??  Robert Doggett
* From Tandy OS-9 Level One VR 02.00.00.
*
*   1      1998/10/26  Boisy G. Pitre
* Put a proper edition number after the name.

                    nam       Inkey
                    ttl       Key detect subroutine

                    ifp1
                    use       defsfile
                    endc

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       0
size                equ       .

name                fcs       /Inkey/
                    fcb       edition

                    org       0                   parameters
Return              rmb       2                   return address of caller
PCount              rmb       2                   num of parameterss following
Param1              rmb       2                   1st param address
Length1             rmb       2                   size
Param2              rmb       2                   2nd param address
Length2             rmb       2                   size

start               leax      Param1,s            point to the parameter list
                    ldd       PCount,s            get the parameter count
                    cmpd      #1                  just one parameter?
                    beq       InKey20             ..yes; default path A=0
                    cmpd      #2                  are there two params?
                    bne       ParamErr            no, abort
                    ldd       [Param1,s]          get path number
                    ldx       Length1,s           and the length
                    leax      -1,x                byte available?
                    beq       InKey10             ..yes; (A)=path number
                    leax      -1,x                integer?
                    bne       ParamErr            ..no; abort
                    tfr       b,a                 else transfer B (path) into A
InKey10             leax      Param2,s            get the address of the second parameter
InKey20             ldu       2,x                 get the length of string
                    ldx       ,x                  and the address of string
                    ldb       #$FF                get initialization value
                    stb       ,x                  initialize to null string
                    cmpu      #2                  at least two-byte string?
                    blo       InKey30             ..no
                    stb       1,x                 put string terminator
InKey30             ldb       #SS.Ready           get call code
                    OS9       I$GetStt            is there any data ready?
                    bcs       InKey90             ..no; exit
                    ldy       #1                  read one byte
                    OS9       I$Read              read it
                    rts                           return to the caller
InKey90             cmpb      #E$NotRdy           not ready error?
                    bne       InKeyErr            error out if not
                    rts                           else return to caller
ParamErr            ldb       #E$ParmEr           parameter error
InKeyErr            coma                          set carry
                    rts                           return to the caller

                    emod
eom                 equ       *
                    end

