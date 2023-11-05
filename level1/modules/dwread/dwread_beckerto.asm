                    ifndef    BECKBASE
BECKBASE            equ       $FF41               ; Set base address for future use
                    endc
* NOTE: There is now timeout ...
DWRead              clra                          ; clear Carry, Set Z
                    pshs      cc,x,u              ; save regs
                    leau      ,x                  ; U is data buffer
                    ldx       #$0000              ; X is reset check sum
                    ifeq      NOINTMASK
                    orcc      #IntMasks           ; turn off interrupts
                    endc
ini@                pshs      x                   ; save X
                    ldx       #0x8000             ; X = timeout
loop@               ldb       BECKBASE            ; test for data ready flag
                    bitb      #$02
                    bne       rdy@                ; byte is ready
                    leax      -1,x                ; bump timout
                    bne       loop@               ; not timed out, try again
                    ;;        timed               out!
                    puls      x                   ; remove timeout off stack
                    puls      cc                  ; pull CC
                    comb                          ; reset Z (timeout error)
                    puls      x,u,pc              ; restore registers and return
                    ;;        a                   byte is ready
rdy@                puls      x                   ; restore X
                    ldb       BECKBASE+1          ; get byte from port
                    stb       ,u+                 ; store in data buffer
                    abx                           ; add received byte to checksum
                    leay      ,-y                 ; decrement byte counter
                    bne       ini@                ; go get another byte if not done
                    ;;        done                reading bytes return
                    tfr       x,y                 ; put checksum in y
                    puls      cc,x,u,pc           ; restore registers and return
