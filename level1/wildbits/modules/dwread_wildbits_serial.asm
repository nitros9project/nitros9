*******************************************************
* DWRead: drain the UART into X first, checksum the captured bytes afterward.
* Entry: X = destination, Y = count. Exit: X/U preserved, Y = checksum;
* Z = complete, C = UART overrun/parity/framing/break observed. D is clobbered.
* A complete RBF sector is validated by the server checksum even if C is set.
*
* Mask only the prompt wait and active FIFO drain. After DW_MASKED empty
* polls restore caller masks; checksum and timeout purge also use caller masks.
* DW.LinkBusy keeps the background poll off the serial link during RBF I/O.
* Poll-count timeouts remain CPU-speed dependent; no timer is reprogrammed.
DW_TIMEOUT_MULT     equ       12
DW_MASKED           equ       512
DW_PURGE_IDLE       equ       3072
DWRead              clra
                    clrb
                    pshs      u,x,d,cc            CC=0,s; scratch=1,s; original X=3,s
                    leau      ,x
                    cmpy      #0
                    lbeq      bye@                zero-length receive: checksum already zero
                    orcc      #IntMasks
                    leas      -1,s                outer timeout; saved CC now 1,s
waitstart@          ldx       #0
                    lda       #DW_TIMEOUT_MULT
                    sta       ,s
waitpoll@           lda       UART.Base+UART_LSR
                    bita      #$1E
                    beq       waitdata@
                    pshs      a
                    lda       2,s
                    ora       #$01                retain hardware errors across clearing LSR reads
                    sta       2,s
                    puls      a
waitdata@           bita      #LSR_DATA_AVAIL
                    bne       gotwait@
                    leax      1,x
                    cmpx      #DW_MASKED
                    bne       waitcount@
                    lda       1,s
                    tfr       a,cc                late server: restore caller interrupt masks
waitcount@          cmpx      #0
                    bne       waitpoll@
                    dec       ,s
                    bne       waitpoll@
                    leas      1,s
                    lda       ,s
                    anda      #^$04               incomplete receive
                    sta       ,s
                    tfr       a,cc
                    ldy       #1200
prg0@               ldx       #DW_PURGE_IDLE
prg1@               lda       UART.Base+UART_LSR
                    bita      #LSR_DATA_AVAIL
                    bne       prg2@
                    leax      -1,x
                    bne       prg1@
                    bra       bye@
prg2@               lda       UART.Base+UART_TRHB
                    leay      -1,y
                    bne       prg0@
                    bra       bye@
gotwait@            orcc      #IntMasks           mask once on entering a receive burst
byte@               ldb       UART.Base+UART_TRHB
                    stb       ,u+                 capture immediately; no checksum in this loop
                    leay      -1,y
                    beq       captured@
burst@              lda       UART.Base+UART_LSR
                    bita      #$1E
                    bne       bursterr@
burstdata@          bita      #LSR_DATA_AVAIL
                    bne       byte@               drain everything ready before setting up a wait
                    bra       waitstart@
bursterr@           pshs      a
                    lda       2,s
                    ora       #$01
                    sta       2,s
                    puls      a
                    bra       burstdata@
captured@           leas      1,s                 drop outer counter; restore original frame layout
                    stu       1,s                 scratch now holds end of captured buffer
                    lda       ,s
                    tfr       a,cc                checksum computation need not mask interrupts
                    ldx       3,s                 original destination
                    ldy       #0
sum@                ldb       ,x+
                    clra
                    leay      d,y
                    cmpx      1,s
                    bne       sum@
bye@                puls      cc,d,x,u,pc
