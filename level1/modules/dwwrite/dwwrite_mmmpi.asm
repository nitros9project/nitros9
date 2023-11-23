************************************************************************
* DP Optmizied - v2
DWWrite   pshs      d,dp,cc           ; preserve registers

          IFEQ      NOINTMASK
          orcc      #IntMasks         ; mask interrupts
          ENDC

          lda       #$ff              ; Set up DP
          tfr       a,dp

          lda       <MPIREG           ; Get Current MPI Status
          pshs      a                 ; Save it
          anda      #CTSMASK          ; Mask out SCS, save CTS
          ora       #MMMSLT           ; SCS Slot Selection
          sta       <MPIREG           ; write the info to MPI register

txByte@   lda       #LSRTHRE          ; Transmit Holding Register Empty mask
loop@     bita      <MMMUARTB+LSR     ; Check Bit
          beq       loop@             ; loop if not empty
          ldb       ,x+               ; load byte from buffer
          stb       <MMMUARTB         ; and write it to data register
          leay      -1,y              ; decrement byte counter
          bne       loop@             ; loop if more to send

          puls      a                 ; Get original MPI Register back
          sta       <MPIREG           ; Restore it

          puls      cc,dp,d,pc        ; restore registers and return
************************************************************************
