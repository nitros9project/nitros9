;;; FTRANS
;;;
;;; Transfer data between fpaths.
;;;
;;; Entry:  A = The source path.
;;;         B = The destination path.
;;;         X = The address of the buffer to transfer.
;;;         Y = The number of bytes to transfer.
;;;         U = The buffer size.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.

* This sets up a stack frame used for variable references.

                    section   .data

count               rmb       2                   number of bytes to transfer (2nd Y)
inpath              rmb       1                   source file (A)
Breg                rmb       1                   copy of B register
outpath             equ       Breg                dest file
buffer              rmb       2                   buffer memory (X)
                    rmb       2                   copy of Y
bufsize             rmb       2                   buffer size (U)

                    endsect

                    section   .text

FTRANS:             pshs      a,b,x,y,u
                    pshs      y

loop                ldy       count,s             bytes left to send
                    beq       exit                all done?

                    lda       inpath,s            source file
                    ldx       buffer,s            buffer area
                    cmpy      bufsize,s           is remainder > buffer size
                    blo       get                 no, get all of remainder
                    ldy       bufsize,s           use buffer size

get                 os9       I$Read              get data
                    bcs       error
                    lda       outpath,s
                    os9       I$Write
                    bcs       error

                    pshs      y                   number of bytes got/sent
                    ldd       count+2,s           adjust count remaining
                    subd      ,s++
                    std       count,s
                    bra       loop

exit                clra                          no error
                    bra       exit2

error               coma                          signal error
                    stb       Breg,s              set B

exit2               puls      y
                    puls      a,b,x,y,u,pc

                    endsect
