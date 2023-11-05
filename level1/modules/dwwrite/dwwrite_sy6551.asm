                    ifndef    SY6551B
SY6551B             equ       $FF68               ; Set base address for future use
                    endc
                    ifndef    SYDATA
SYDATA              equ       SY6551B
                    endc
                    ifndef    SYCONT
SYCONT              equ       SY6551B+3
                    endc
                    ifndef    SYCOMM
SYCOMM              equ       SY6551B+2
                    endc
                    ifndef    SYSTAT
SYSTAT              equ       SY6551B+1
                    endc
                    ifndef    SYCONSET
SYCONSET            equ       $10                 ; Default baud rate 115200
                    endc
DWWrite             pshs      d,cc                ; preserve registers
                    ifeq      NOINTMASK
                    orcc      #IntMasks           ; mask interrupts
                    endc
                    lda       #SYCONSET           ; Set baud to value of SYCONSET
                    sta       SYCONT              ; write the info to register
                    lda       #$0B                ; Set no parity, no irq
                    sta       SYCOMM              ; write the info to register
txByte
                    lda       SYSTAT              ; read status register to check
                    anda      #$10                ; if transmit buffer is empty
                    beq       txByte              ; if not loop back and check again
                    lda       ,x+                 ; load byte from buffer
                    sta       SYDATA              ; and write it to data register
                    leay      -1,y                ; decrement byte counter
                    bne       txByte              ; loop if more to send
                    puls      cc,d,pc             ; restore registers and return
