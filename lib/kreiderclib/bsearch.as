                    export    _bsearch
                    
                    section   code

;;; char bsearch(char *key, char *base, int nel, int width, int (*compar)())
;;;
;;; Search using a binary search algorithm.
;;;
;;; This function performs a binary search on a sorted array of strings to find the string matching key.
;;; Searches start at the memory location pointed to by base. The array MUST be sorted in ascending order according to the comparison function compar().
;;; nel contains the total number of elements in the array, and width the length of the each string.
;;; compar() is a user-supplied function that returns if the first argument is greater than, equal to, or less than, the second argument.
;;; strcmp() is a good choice for string variables.
;;;
;;; Returns: a pointer to the matching string upon success, or null.

_bsearch            pshs      d,x,y,u
                    ldu       10,s
                    clra
                    clrb
L0006               addd      #1
                    std       2,s
                    ldd       14,s
L000d               subd      2,s
                    bmi       L003d
                    ldd       14,s
                    addd      2,s
                    lsra
                    rorb
                    std       4,s
                    addd      #-1
                    pshs      d
                    ldd       18,s
                    lbsr      _ccmult
                    addd      12,s
                    std       ,s
                    pshs      u
                    jsr       [20,s]
                    std       ,s++
                    beq       L0041
                    asla
                    ldd       4,s
                    bcc       L0006
                    addd      #-1
                    std       14,s
                    bra       L000d
L003d               clra
                    clrb
                    bra       L0043
L0041               ldd       ,s
L0043               leas      6,s
                    puls      u,pc

                    endsect

