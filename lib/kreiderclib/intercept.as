                    export    _intercept
                    
                    section   bss

* Uninitialized data (class B)
B0000               rmb       2
* Initialized Data (class G)

                    endsect

                    section   code

_intercept          pshs      u
                    tfr       y,u
                    ldx       4,s
                    stx       B0000,y
                    leax      >L0016,pcr
                    os9       F$Icpt
                    puls      u
                    lbra      _sysret
L0016               tfr       u,y
                    clra
                    pshs      d
                    jsr       [B0000,y]
                    leas      2,s
                    rti

                    endsect

