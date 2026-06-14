                    ifndef    BECKBASE
BECKBASE            equ       $FF41               ; Set base address for future use
                    endc
* Entry: X = destination buffer, Y = byte count
* Exit:  Y = checksum, carry clear, Z set (all bytes received)
DWRead              pshs      u,x                 ; preserve registers
                    leau      ,x
                    ldx       #$0000
                    ifeq      NOINTMASK
                    orcc      #IntMasks
                    endc
loop@               ldb       BECKBASE
                    bitb      #$02
                    beq       loop@
                    ldb       BECKBASE+1
                    stb       ,u+
                    abx
                    leay      ,-y
                    bne       loop@
                    leay      ,x                  ; Y = checksum
                    clrb                          ; carry clear = no framing error
                    orcc      #$04                ; Z set = all bytes received
                    puls      x,u,pc
