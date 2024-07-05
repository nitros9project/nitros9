                    export    _kill
                    export    _wait
                    export    _setpr
                    export    _chain
                    export    _os9fork
                    
                    section   code

_kill               lda       3,s
                    ldb       5,s
                    os9       F$Send
                    lbra      _sysret
                    
_wait               clra
                    clrb
                    os9       F$Wait
                    lblo      _os9err
                    ldx       2,s
                    beq       L001b
                    stb       1,x
                    clr       ,x
L001b               tfr       a,b
                    clra
                    rts
                    
_setpr              lda       3,s
                    ldb       5,s
                    os9       F$SPrior
                    lbra      _sysret
                    
;;; void chain(char *modname, char *params, int paramsize, int type, int lang, int datasize)
;;;
;;; Load and execute a program module.
;;;
;;; This function creates a process without returning to the caller. If there is an error, the chained process aborts and returns to its parent process.
;;; Check the file's existence and access permissions before calling this function. Check permissions with modlink() or modload() followed by munlink().
;;; modname points to the name of the desired module. paramsize is the length of the parameter string (terminated with '\n'), and params points to the parameter string. ;;;;;; type is the module type in the module header (normally 1 for a program module), and lang matches the language nibble in the module header (C programs have a 1 for machine language).
;;; datasize may be zero or contain the number of 256 byte pages to give to the new process as its initial data memory allocation.
;;;
;;; Note: If there are no parameters, specify a carriage return for params and set paramsize to 1.

_chain              leau      ,s
                    leas      255,y
                    ldx       2,u
                    ldy       4,u
                    lda       9,u
                    asla
                    asla
                    asla
                    asla
                    ora       11,u
                    ldb       13,u
                    ldu       6,u
                    os9       F$Chain
                    os9       F$Exit
                    
_os9fork            pshs      y,u
                    ldx       6,s
                    ldy       8,s
                    ldu       10,s
                    lda       13,s
                    ora       15,s
                    ldb       17,s
                    os9       F$Fork
                    puls      y,u
                    lblo      _os9err
                    tfr       a,b
                    clra
                    rts

                    endsect

