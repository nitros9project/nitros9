                    export    _creat
                    export    _create
                    export    _ocreat
                    
                    section   code

;;; #include <modes.h>
;;;
;;; void creat(char *fname, int perms)
;;;
;;; Create a new file.
;;;
;;; This function returns a path number to a new file available for writing and gives it the permissions specified in perm. The
;;; caller is the owner of the file.
;;; If the file already exists, the function truncates it to length zero and the ownership and permissions remain unchanged.
;;;
;;; This function doesn't return an error if the file exists. If needed, ue access() to determine if the file exists. It
;;; doesn't create directories; use mknod() for that.
;;;
;;; If perms specify either owner or public executable, this function creates the file in the current execution directory; otherwise, the data directory hosts the file.
;;;
;;; Returns: 0 on success, or -1 on error.

_creat              ldx       2,s
                    lda       5,s
                    tfr       a,b
                    andb      #$24
                    orb       #$0b
                    os9       I$Create
                    bcc       L005d
                    cmpb      #$da
                    bne       L0039
                    lda       5,s
                    bita      #$80
                    bne       L0039
                    anda      #7
                    ldx       2,s
                    os9       I$Open
                    bcs       L0039
                    pshs      a,u
                    ldx       #0
                    leau      ,x
                    ldb       #2
                    os9       I$SetStt
                    puls      a,u
                    bcc       L005d
                    pshs      b
                    os9       I$Close
                    puls      b
L0039               lbra      _os9err

;;; #include <modes.h>
;;;
;;; void create(char *fname, int mode, int perms)
;;;
;;; Create and open a file.
;;;
;;; This function creates and opens a file, and accepts the file mode and access permissions.
;;;
;;; Returns: 0 on success, or -1 on error.

_create             ldx       2,s
                    lda       5,s
                    ldb       7,s
                    os9       I$Create
                    bcs       L0039
                    bra       L005d
L0049               cmpb      #$da
                    bne       L0039
                    os9       I$Delete
                    bcs       L0039
                    
;;; #include <modes.h>
;;;
;;; void ocreat(char *fname, int mode, int perms)
;;;
;;; Delete the file, then create and open it.
;;;
;;; This function deletes the file if it exists, then creates and opens it, and accepts the file mode and access permissions.
;;;
;;; Returns: 0 on success, or -1 on error.

_ocreat             ldx       2,s
                    lda       5,s
                    ldb       7,s
                    os9       I$Create
                    bcs       L0049
L005d               tfr       a,b
                    clra
                    rts

                    endsect

