* Disassembly by Os9disasm of errmsg.r

                    section   code

_errmsg             pshs      u
                    lbsr      _prgname
                    pshs      d
                    leau      >L002f,pcr
                    leax      _iob+26,y
                    pshs      x,u
                    lbsr      fprintf
                    leas      6,s
                    ldu       12,s
                    ldx       10,s
                    ldd       8,s
                    pshs      d,x,u
                    ldu       12,s
                    leax      _iob+26,y
                    pshs      x,u
                    lbsr      fprintf
                    leas      10,s
                    ldd       4,s
                    puls      u,pc
*L002f bcs   L00a4
* abx
* bra   L0034

                    endsect

