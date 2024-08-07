                    export    _rpterr
                    
                    section   code

_rpterr             std       errno,y
                    pshs      b,y
                    os9       F$ID
                    puls      b,y
                    os9       F$Send
                    rts

                    endsect

