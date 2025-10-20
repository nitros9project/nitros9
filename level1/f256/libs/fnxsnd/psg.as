                    section   .bss
nega                rmb       1
                    endsect

                    section   .text

MAPSLOT             equ       MMU_SLOT_1
MAPADDR             equ       (MAPSLOT-MMU_SLOT_0)*$2000

PSG.Base            equ        PSGL.Base

                    section   .text

;;; PSG_INIT
;;;
;;; Initialize the PSG.
;;;
;;; Entry:  None.
;;;
;;; Exit:  None.
;;;
;;; All registers (except CC) are preserved.
PSG_INIT:
                    pshs     d,x,y
                    
* Initialize the F256 sound hardware.
InitSound           clr       D.SndPrcID          clear the process ID of the current sound emitter (none)
                    lda       SYS1                get the byte at SYS1
                    anda      #^SYS_PSG_ST clear the stereo flag
                    sta       SYS1                and save it back

InitPSG             pshs      cc                save the condition code register
                    lda       #$C4                get the sound MMU block
                    orcc      #IntMasks           mask interrupts
                    ldb       MAPSLOT             get the MMU slot we'll map to
                    sta       MAPSLOT             store it in the MMU slot to map it in

* Silence the PSG's four channels.
                    lda       #%10011111                            set volume of channel to 0
                    sta       MAPADDR+PSG.Base
                    lda       #%10111111                            set volume of channel to 1
                    sta       MAPADDR+PSG.Base
                    lda       #%11011111                            set volume of channel to 2
                    sta       MAPADDR+PSG.Base
                    lda       #%11111111                            set volume of channel to 3
                    sta       MAPADDR+PSG.Base
                    
                    stb       MAPSLOT restore it in the MMU slot
                    puls      cc restore interrupts

                    ldx       #CODEC.Base
*                    ldd       #%0001010000000010                    R10 - DAC Interface Control 
                    ldd        #%0001010000010010                    R10 - DAC Interface Control 20-bit
                    bsr       SendToCODEC
                    ldd       #%0001011000000010                    R11 - ADC Interface Control 
                    bsr       SendToCODEC
                    ldd       #%0001100111010101                    R12 - Master Mode Control 
                    bsr       SendToCODEC
                    ldd       #%0001101001001010                    R13 - PWR Down Control   bit 2 = '1' for DAC Enabled
                    bsr       SendToCODEC
                    ldd       #%0010001100000001                    R17 - ALC Control 2 
                    bsr       SendToCODEC
                    ldd       #%0010101011000000                    R21 - ADC Mux Control   Right/Left channels muted
                    bsr       SendToCODEC
                    ldd       #%0010110000000001                    R22 - Output Mux MX[2:0] = "001" for DAC Enable
                    bsr       SendToCODEC
                    puls      d,x,y,pc

* Send data to F256 CODEC and await its digestion.
*
* Entry: D = Value to send to CODEC.
*        X = Base address of CODEC.
SendToCODEC         exg       a,b
                    std       CODECCmdLo,x
                    lda       #$01
                    sta       CODECCtrl,x
l@                  cmpa      CODECCtrl,x
                    beq       l@
                    rts
                    
;;; PSG_WRITE
;;;
;;; Write a byte to the PSG.
;;;
;;; Entry: A = Value to send.
;;;
;;; Exit:  None.
;;;
;;; All registers (except CC) are preserved.
PSG_WRITE:          pshs      cc,d
                    lda       #$C4
                    orcc      #IntMasks
                    ldb       MAPSLOT
                    sta       MAPSLOT
                    lda       2,s
                    sta       MAPADDR+PSG.Base
                    stb       MAPSLOT
                    puls      cc,d,pc

                    endsect

