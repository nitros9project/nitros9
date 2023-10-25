***************************************

* Subroutine rewind file

* OTHER MODULES NEEDED: none

* ENTRY: A=path


* EXIT:  CC carry set if error (from I$Seek)
*        B  error code if any

                    nam       Rewind              open RBF file
                    ttl       Assembler Library Module


                    section   .text

FREWIND
                    pshs      x,u
                    ldx       #0
                    tfr       x,u
                    os9       I$Seek              seek to pos 0
                    puls      x,u,pc

                    endsect

