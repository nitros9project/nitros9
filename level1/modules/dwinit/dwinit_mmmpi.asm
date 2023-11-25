*******************************************************
*
* DWInit
*    Initialize DriveWire for MegaMiniMPI

DWInit

               pshs      a,x
               pshs b,cc,dp
               orcc #$50                 ; clear interrupts
               lda #$ff                  ; set up DP
               tfr a,dp
               setdp $ff

               lda <MPIREG               ; save mpi settings
               pshs a
               anda #CTSMASK             ; Save previous CTS, clear off STS
               ora #MMMSLT               ; Set STS for MMMPI Uart Slot
               sta <MPIREG

               ; FF48
               sta <MMMUARTB+RST         ; Reset UART

               ; FF41
               clr <MMMUARTB+IER         ; IER: disable interrupts

               ; FF42
               lda #FCRFEN|FCRRXFCLR|FCRTXFCLR|FCRTRG8B ; FCR: enable,clear fifos, 8-byte trigger
               sta <MMMUARTB+FCR
               ;ldd #$0087
               ;std <MMMUARTB+IER

               ; FF43
               lda #LCR8BIT|LCRPARN       ; LCR: 8N1,DLAB=0
               sta <MMMUARTB+LCR

               ; FF44
               lda #MCRDTREN|MCRRTSEN|MCRAFEEN ; MCR: DTR & Auto Flow Control
               sta <MMMUARTB+MCR
               ; ldd #$8323
               ; std <MMMUARTB+LCR

               ; FF43
               lda <MMMUARTB+LCR          ; enable DLAB
               ora #DLABEN
               sta <MMMUARTB+LCR

               ; FF40
               ldd #MMMB921600            ; Set Divisor Latch
               ; std MMMUARTB+DL16        ; 16-bit DL helper
               sta <MMMUARTB+DLM
               stb <MMMUARTB+DLL

               ; FF43
               lda <MMMUARTB+LCR          ; disable DLAB
               anda #DLABDIS
               ; lda #$03
               sta <MMMUARTB+LCR

clrloop@       lda <MMMUARTB+LSR          ; check RX FiFo Status
               bita #LSRDR
               beq restore@               ; its empty
               lda <MMMUARTB              ; dump any data that's there
               bra clrloop@
restore@

               puls a                     ; restore mpi settings
               ; lda #$33
               sta <MPIREG
               puls b,cc,dp
               setdp $00

               puls a,x,pc

