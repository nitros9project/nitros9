                    export    _isatty
                    export    _devtyp
                    
                    section   code

;;; int isatty(int pn)
;;;
;;; Check if the device is a TTY.
;;;
;;; This function verifies that the device represented by pn is an SCF device.
;;;
;;; Returns: 1 for an SCF device; otherwise, 0.

_isatty             ldd       2,s
                    pshs      d
                    bsr       _devtyp
                    std       ,s++
                    beq       L000c
                    clrb
                    rts
L000c               incb
                    rts
                    
;;; int devtyp(int pn)
;;;
;;; Check the device type.
;;;
;;; This function returns an integer corresponding to the OS-9 device type. pn is the OS-9 path number
;;; of the device to check.
;;;
;;; Returns: 0 for an SCF device; 1 for an RBF device; 2 for a Pipe device; 3 for an SBF device.

_devtyp             lda       3,s
                    clrb
                    leas      -32,s
                    leax      ,s
                    os9       I$GetStt
                    lda       ,s
                    leas      32,s
                    lblo      _os9err
                    tfr       a,b
                    clra
                    rts

                    endsect

