                    export    _time
                    export    _o2utime
                    export    _asctime
                    export    _ctime
                    export    _localtime
                    export    _daylight
                    export    _timezone
                                        
* class D external label equates

D0000               equ       $0000
D0025               equ       $0025
D0041               equ       $0041
D0044               equ       $0044
D0046               equ       $0046
D004a               equ       $004a
D004d               equ       $004d
D004e               equ       $004e
D0053               equ       $0053
D0054               equ       $0054
D0057               equ       $0057

* class X external label equates

X004f               equ       $004f
X2025               equ       $2025
X7200               equ       $7200

                    section   bss

* Uninitialized data (class B)
B0000               rmb       16
B0010               rmb       26
* Initialized Data (class G)
G0000               fcb       $00
                    fcb       $1f
                    fcb       $00
                    fcb       $1c
                    fcb       $00
                    fcb       $1f
                    fcb       $00
                    fcb       $1e
                    fcb       $00
                    fcb       $1f
                    fcb       $00
                    fcb       $1e
                    fcb       $00
                    fcb       $1f
                    fcb       $00
                    fcb       $1f
                    fcb       $00
                    fcb       $1e
                    fcb       $00
                    fcb       $1f
                    fcb       $00
                    fcb       $1e
                    fcb       $00
                    fcb       $1f

                    endsect

                    section   code

_time               pshs      u
                    leas      -6,s
                    leau      ,s
                    pshs      u
                    lbsr      getime
                    stu       ,s
                    bsr       _o2utime
                    ldu       12,s
                    beq       L001b
                    ldd       ,x
                    std       ,u
                    ldd       2,x
                    std       2,u
L001b               leas      8,s
                    puls      u,pc
                    
L001f               fcb       $01,$6D,$01,$6E

_o2utime            pshs      d,u
                    ldu       6,s
                    clra
                    clrb
                    pshs      d
                    pshs      d
                    ldb       #$45
                    ldx       #0
                    bra       L003e
L0034               leax      365,x
                    bitb      #3
                    bne       L003e
                    leax      1,x
L003e               incb
                    cmpb      ,u
                    blt       L0034
                    stx       2,s
                    leax      G0000,y
                    lda       #$1d
                    ldb       ,u+
                    andb      #3
                    beq       L0053
                    lda       #$1c
L0053               sta       3,x
                    ldb       #1
                    bra       L0062
L0059               ldd       ,x++
                    addd      2,s
                    std       2,s
                    ldb       4,s
                    incb
L0062               stb       4,s
                    cmpb      ,u
                    blt       L0059
                    leau      1,u
                    ldb       ,u+
                    decb
                    clra
                    addd      2,s
                    std       2,s
                    lslb
                    rola
                    addd      2,s
                    lslb
                    rola
                    rol       1,s
                    lslb
                    rola
                    rol       1,s
                    lslb
                    rola
                    rol       1,s
                    std       2,s
                    ldb       ,u+
                    clra
                    addd      2,s
                    std       2,s
                    ldb       1,s
                    adcb      #0
                    stb       1,s
                    bsr       L00c5
                    ldb       ,u+
                    clra
                    addd      2,s
                    std       2,s
                    ldd       ,s
                    adcb      #0
                    adca      #0
                    std       ,s
                    bsr       L00c5
                    ldb       ,u+
                    clra
                    addd      2,s
                    std       2,s
                    ldd       ,s
                    adcb      #0
                    adca      #0
                    std       ,s
                    leau      ,s
                    leax      _flacc,y
                    ldd       ,u
                    std       ,x
                    ldd       2,u
                    std       2,x
                    leas      6,s
                    puls      u,pc
L00c5               ldx       2,s
                    ldd       4,s
                    bsr       L00f0
                    bsr       L00f0
                    addd      4,s
                    exg       d,x
                    adcb      3,s
                    adca      2,s
                    exg       d,x
                    stx       2,s
                    std       4,s
                    bsr       L00f0
                    addd      4,s
                    exg       d,x
                    adcb      3,s
                    adca      2,s
                    exg       d,x
                    bsr       L00f0
                    bsr       L00f0
                    stx       2,s
                    std       4,s
                    rts
L00f0               lslb
                    rola
                    exg       d,x
                    rolb
                    rola
                    exg       d,x
                    rts
u2otime             pshs      u
                    ldu       6,s
                    ldx       4,s
                    leax      6,x
                    lda       #6
L0103               ldb       ,u+
                    ldb       ,u+
                    stb       ,-x
                    deca
                    bne       L0103
                    puls      u,pc
                    
_daylight           fcb       $70,$00,$00
_timezone           fcb       $70,$00,$00
                    fcb       $70,$00,$00
                    
;;; #include <utime.h>
;;;
;;; struct tm *localtime(long *clock)
;;;
;;; Returns a time structure.

_localtime          pshs      d,u
                    leau      B0000,y
                    ldx       6,s
                    ldd       2,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    leax      ,s
                    ldd       #$003c
                    bsr       L019b
                    std       ,u
                    ldd       #$003c
                    bsr       L019b
                    std       2,u
                    ldd       #$0018
                    bsr       L019b
                    std       4,u
                    ldd       2,x
                    std       4,s
                    ldd       #$0046
                    std       10,u
L0144               leax      L001f,pcr
                    ldb       11,u
                    andb      #3
                    bne       L0150
                    leax      2,x
L0150               ldd       4,s
                    subd      ,x
                    inc       11,u
                    std       4,s
                    bcc       L0144
                    addd      ,x
                    std       4,s
                    dec       11,u
                    std       14,u
                    ldb       11,u
                    leax      G0000,y
                    lda       #$1d
                    andb      #3
                    beq       L0170
                    lda       #$1c
L0170               sta       3,x
                    clra
                    clrb
                    std       8,u
                    ldd       4,s
L0178               inc       9,u
                    subd      ,x++
                    bcc       L0178
                    addd      -2,x
                    addd      #1
                    std       6,u
                    leax      ,s
                    ldd       2,x
                    addd      #4
                    std       2,x
                    ldd       #7
                    bsr       L019b
                    std       12,u
                    tfr       u,d
                    leas      6,s
                    puls      u,pc
L019b               clr       ,-s
                    clr       ,-s
                    pshs      d
                    ldb       #$21
                    pshs      b
                    bra       L01af
L01a7               ldd       3,s
                    subd      1,s
                    bcs       L01af
                    std       3,s
L01af               rol       3,x
                    rol       2,x
                    rol       1,x
                    rol       ,x
                    rol       4,s
                    rol       3,s
                    dec       ,s
                    bne       L01a7
                    com       3,x
                    com       2,x
                    com       1,x
                    com       ,x
                    lsr       3,s
                    ror       4,s
                    leas      3,s
                    puls      d,pc
                    
;;; #include <utime.h>
;;;
;;; char *asctime(struct tm *tm)
;;;
;;; Convert a time structure to an ASCII string.
;;;
;;; This function takes a time structure representing the time in seconds since 00:00:00, January 1, 1970,
;;; and returns a pointer to a 26-character string in the following form:
;;;
;;;   Sun Sep 16 01:03:52 1973

_asctime            pshs      u
                    ldu       4,s
                    ldd       10,u
                    pshs      d
                    ldd       ,u
                    pshs      d
                    ldd       2,u
                    pshs      d
                    ldd       4,u
                    pshs      d
                    ldd       6,u
                    pshs      d
                    ldd       8,u
                    subd      #1
                    lslb
                    rola
                    lslb
                    rola
                    leax      >L024a,pcr
                    leax      d,x
                    pshs      x
                    ldd       12,u
                    lslb
                    rola
                    lslb
                    rola
                    leax      >L022e,pcr
                    leax      d,x
                    pshs      x
                    leax      >L027a,pcr
                    pshs      x
                    leax      B0010,y
                    pshs      x
                    lbsr      _sprintf
                    leas      18,s
                    leax      B0010,y
                    tfr       x,d
                    puls      u,pc
                    
;;; #include <utime.h>
;;;
;;; char *ctime(long *clock)
;;;
;;; Convert date and time to an ASCII string.
;;;
;;; This function converts a long integer, usually returned from time(), representing the time in seconds since 00:00:00, January 1, 1970,
;;; and returns a pointer to a 26-character string in the following form:
;;;
;;;   Sun Sep 16 01:03:52 1973

_ctime              ldd       2,s
                    pshs      d
                    lbsr      _localtime
                    std       ,s
                    lbsr      _asctime
                    puls      x,pc

L022e               fcc       "Sun"
                    fdb       $7000
                    fcc       "Mon"
                    fdb       $7000
                    fcc       "Tue"
                    fdb       $7000
                    fcc       "Wed"
                    fdb       $7000
                    fcc       "Thu"
                    fdb       $7000
                    fcc       "Fri"
                    fdb       $7000
                    fcc       "Sat"
                    fdb       $0000
                    
L024a               fcc       "Jan"
                    fdb       $7000
                    fcc       "Feb"
                    fdb       $7000
                    fcc       "Mar"
                    fdb       $7000
                    fcc       "Apr"
                    fdb       $7000
                    fcc       "May"
                    fdb       $7000
                    fcc       "Jun"
                    fdb       $7000
                    fcc       "Jul"
                    fdb       $7000
                    fcc       "Aug"
                    fdb       $7000
                    fcc       "Sep"
                    fdb       $7000
                    fcc       "Oct"
                    fdb       $7000
                    fcc       "Nov"
                    fdb       $7000
                    fcc       "Dec"
                    fdb       $7000
                    
L027a               fcc       "%s %s %2d%02d:%2d:%2d92d}"
                    fcb       $0

                    endsect

