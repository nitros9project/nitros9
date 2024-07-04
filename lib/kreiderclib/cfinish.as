                    export    exit
                    
                    section   code

exit                lbsr      _dumprof
                    lbsr      _tidyup
_exit               ldd       2,s
                    os9       F$Exit

                    endsect

