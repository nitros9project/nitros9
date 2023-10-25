***************************************

* Subroutine seek to end of file

* OTHER MODULES NEEDED: none

* ENTRY: A=path


* EXIT:  CC carry set if error (from I$Seek)
*        B  error code if any

                    nam       Seek                EOF of open RBF file
                    ttl       Assembler Library Module


                    section   .text

FTOEOF
                    pshs      x,u
                    ldb       #SS.Size            first get filesize
                    os9       I$GetStt
                    bcs       exit
                    os9       I$Seek              seek to end of file
exit
                    puls      x,u,pc

                    endsect
