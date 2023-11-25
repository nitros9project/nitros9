************************************************************************
* Optimized 1 byte - v2
DWRead    clra                       ; clear Carry (no framing error)
          deca                       ; clear Z flag, A = timeout msb ($ff)
          pshs   u,x,dp,cc           ; preserve registers
          leau   ,x                  ; buffer pointer
          ldx    #$0000              ; Initialize Checksum
          IFEQ   NOINTMASK
          orcc   #IntMasks           ; Disable Interrupts
          ENDC

          tfr       a,dp             ; Set up Direct Page Register

          lda       <MPIREG          ; Get Current MPI Status
          pshs      a                ; Save it
          anda      #CTSMASK         ; Mask out SCS, save CTS
          ora       #MMMSLT          ; SCS Slot Selection
          sta       <MPIREG          ; write the info to MPI register

rxByte@   lda    #LSRDR              ; Data Ready mask
loop@     bita   <MMMUARTB+LSR       ; Check bit
          beq    loop@               ; loop if empty
          ldb    <MMMUARTB           ; Read data
          stb    ,u+                 ; save it
          abx                        ; update checksum
          leay   -1,y                ; counter = counter - 1
          bne    loop@

          puls      a                ; Get original MPI Register back
          sta       <MPIREG          ; Restore it

          lda    #4                  ; Z flag
          ora    ,s                  ; place status information into the..
          sta    ,s                  ; ..C and Z bits of the preserved CC
          leay   ,x                  ; return checksum in Y
          puls   cc,dp,x,u,pc        ; restore registers and return
************************************************************************
