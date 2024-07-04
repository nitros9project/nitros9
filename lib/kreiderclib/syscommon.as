                    export    errno
                    export    _os9err
                    export    _sysret
                    
                    section   bss
errno               rmb                 1                    
                    endc
                    
                    section   code

_os9err             clra
                    std       errno,y
                    ldd       #-1
                    rts
_sysret             bcs       _os9err
                    clra
                    clrb
                    rts

                    endsect

