***************************************

* Subroutine to transfer data for one file to another

* OTHER MODULES NEEDED: none

* ENTRY: A=source path
*        B=destination path
*        Y=number of bytes to transfer
*        X=buffer for this routine
*        U=buffer size


* EXIT:  CC carry set if error (from I$Read or I$Write)
*        B  error code if any

                    nam       File                data transfer
                    ttl       Assembler Library Module

                    section   .data

* this sets up a stack frame used for variable references

count               rmb       2                   number of bytes to transfer (2nd Y)
inpath              rmb       1                   source file (A)
Breg                rmb       1                   copy of B register
outpath             equ       Breg                dest file
buffer              rmb       2                   buffer memory (X)
                    rmb       2                   copy of Y
bufsize             rmb       2                   buffer size (U)

                    endsect

                    section   .text

FTRANS
                    pshs      a,b,x,y,u
                    pshs      y

loop
                    ldy       count,s             bytes left to send
                    beq       exit                all done?

                    lda       inpath,s            source file
                    ldx       buffer,s            buffer area
                    cmpy      bufsize,s           is remainder > buffer size
                    blo       get                 no, get all of remainder
                    ldy       bufsize,s           use buffer size

get
                    os9       I$Read              get data
                    bcs       error
                    lda       outpath,s
                    os9       I$Write
                    bcs       error

                    pshs      y                   number of bytes got/sent
                    ldd       count+2,s           adjust count remaining
                    subd      ,s++
                    std       count,s
                    bra       loop

exit
                    clra                          no error
                    bra       exit2

error
                    coma                          signal error
                    stb       Breg,s              set B

exit2
                    puls      y
                    puls      a,b,x,y,u,pc

                    endsect
