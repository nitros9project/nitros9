                    export    _exit
                    
                    section   code

_exit               lbsr      _dumprof
                    lbsr      _tidyup
__exit              ldd       2,s
                    os9       F$Exit

                    endsect

