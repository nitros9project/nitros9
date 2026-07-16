;;;
;;;  This sits in a DECB ROM and loads the bootloader
;;;  from the end of this binary down to it's proper place
;;;

                    org       $c000               ; is a ROM
                    .ascii    'DK'                ; is a DECB-look-a-like ROM
                    jmp       start               ; jump over the garbage
                    fill      $ff,9*256           ; this is area that Super Basic trashes
start               ldx       #payload            ; get address of payload
pre                 lda       ,x+                 ; check flag
                    bne       post                ; is end so post processes
                    ldy       ,x++                ; get size
                    ldu       ,x++                ; get address
loop                ldb       ,x+                 ; get a byte
                    stb       ,u+                 ; move the byte
                    leay      -1,y                ; bump counter
                    bne       loop                ; move another if not done
                    bra       pre                 ; get next block header
post                ldx       2,x                 ; X = execution address of binary
                    jmp       ,x                  ; and jump to it
payload
                    includebin "FPGABOOT.BIN"

                    fill      $ff,$e000-*         ; pad to 8k
