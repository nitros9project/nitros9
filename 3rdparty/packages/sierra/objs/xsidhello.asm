********************************************************************
* xsidhello - tiny SID hello-tone for CoCo X-SID via MPI
*
* Plays one tone on SID voice 1 (triangle waveform, ADSR envelope)
* through the CoCo X-SID cartridge.  Acts as the smallest end-to-end
* validation that a real 6809-issued cart-slot write reaches the SID
* through the Multi-Pak Interface in MAME (and on real hardware).
*
* MPI/X-SID wiring assumed:
*   - X-SID in MPI slot 1
*   - FDC  in MPI slot 4 (default)
*
* MPI $FF7F slot-select encoding:
*   bits 0-1  = SCS slot (-1)  -- $00 picks slot 1
*   bits 4-5  = CTS slot (-1)  -- $30 picks slot 4
*   $30 -> SCS=slot1(X-SID), CTS=slot4(FDC ROM)
*   $FF -> SCS=slot4,        CTS=slot4    (default; FDC normal)
*
* Critical section: while SCS is pointed at slot 1, any FDC IRQ that
* tries to read FDC status at $FF48 will instead hit the X-SID, so
* we MUST mask interrupts around every register burst.  Between bursts
* we restore $FF7F=$FF so the OS-9 floppy driver can talk to FDC again.
* The SID continues oscillating autonomously while we're elsewhere.
*
* Edt/Rev  YYYY/MM/DD  Modified by
*   0      2025/11/26  Copilot CLI + sspiller
*     Initial; based on level1/cmds/mpi.asm structure.

                    nam       xsidhello
                    ttl       SID hello tone for X-SID/MPI

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

* MPI register & encodings
MPI_CTRL            equ       $FF7F
MPI_SCS_XSID_CTS_FDC equ      $30                 SCS=slot1, CTS=slot4
MPI_DEFAULT         equ       $FF                 SCS=slot4, CTS=slot4

* SID register file (when MPI SCS routes here)
SID_BASE            equ       $FF40
SID_V1_FRQLO        equ       SID_BASE+$00
SID_V1_FRQHI        equ       SID_BASE+$01
SID_V1_PWLO         equ       SID_BASE+$02
SID_V1_PWHI         equ       SID_BASE+$03
SID_V1_CTRL         equ       SID_BASE+$04
SID_V1_AD           equ       SID_BASE+$05        attack/decay nibbles
SID_V1_SR           equ       SID_BASE+$06        sustain/release nibbles
SID_FCLO            equ       SID_BASE+$15        filter cutoff lo
SID_FCHI            equ       SID_BASE+$16        filter cutoff hi
SID_RESFLT          equ       SID_BASE+$17        resonance/filter select
SID_MODEVOL         equ       SID_BASE+$18        mode + master volume

* SID v1 control bits
SID_CTRL_GATE       equ       $01
SID_CTRL_TRIANGLE   equ       $10
SID_CTRL_SAWTOOTH   equ       $20
SID_CTRL_PULSE      equ       $40
SID_CTRL_NOISE      equ       $80

* Tone parameters: A4 = 440 Hz at 1 MHz SID clock
*   freq_reg = 440 * 16777216 / 1_000_000 = 7382 = $1CD6
A4_FREQ_LO          equ       $D6
A4_FREQ_HI          equ       $1C

* ADSR: attack=0 (2ms), decay=9 (240ms), sustain=10/15, release=4 (114ms)
ADSR_AD             equ       $09
ADSR_SR             equ       $A4
MASTER_VOL          equ       $0F

NOTE_TICKS          equ       120                 ~2.0 s at 60 Hz
RELEASE_TICKS       equ       60                  ~1.0 s

                    org       0
                    rmb       200                 stack/data scratch
size                equ       .

name                fcs       /xsidhello/
                    fcb       edition

************************************************************************
* start - main entry from OS-9.
*
* 1. Burst-write SID registers with voice 1 triangle + gate, A4 freq.
* 2. Sleep NOTE_TICKS while SID sustains.
* 3. Burst-write gate-off (drops voice into release phase).
* 4. Sleep RELEASE_TICKS while the envelope rings out.
* 5. Exit with success.
************************************************************************
start               equ       *
                    bsr       sid_note_on         start the tone
                    ldx       #NOTE_TICKS
                    os9       F$Sleep             let it ring for ~2s
                    bsr       sid_note_off        gate off -> release
                    ldx       #RELEASE_TICKS
                    os9       F$Sleep             let release fade
                    clrb                          status = success
                    os9       F$Exit

************************************************************************
* sid_note_on - configure voice 1 and gate it.
*   Selects MPI SCS=slot1, writes ADSR+freq+vol, gates voice 1 with
*   the triangle waveform, then restores MPI to default so the FDC
*   driver can continue servicing disk I/O during F$Sleep.
*
* Interrupts are masked across the entire SID register burst.
* All scratch in A; preserves B,X,Y,U.
************************************************************************
sid_note_on         pshs      cc,a
                    orcc      #IntMasks           lock out FDC/timer IRQs
                    lda       #MPI_SCS_XSID_CTS_FDC
                    sta       MPI_CTRL            route $FF40-5F to X-SID
                    lda       #MASTER_VOL
                    sta       SID_MODEVOL
                    lda       #ADSR_AD
                    sta       SID_V1_AD
                    lda       #ADSR_SR
                    sta       SID_V1_SR
                    lda       #A4_FREQ_LO
                    sta       SID_V1_FRQLO
                    lda       #A4_FREQ_HI
                    sta       SID_V1_FRQHI
                    lda       #SID_CTRL_TRIANGLE+SID_CTRL_GATE
                    sta       SID_V1_CTRL         triangle + gate on
                    lda       #MPI_DEFAULT
                    sta       MPI_CTRL            restore default routing
                    puls      cc,a,pc

************************************************************************
* sid_note_off - clear gate on voice 1 (enter release phase).
*   Same masking/routing dance as sid_note_on; only writes V1_CTRL.
************************************************************************
sid_note_off        pshs      cc,a
                    orcc      #IntMasks
                    lda       #MPI_SCS_XSID_CTS_FDC
                    sta       MPI_CTRL
                    lda       #SID_CTRL_TRIANGLE  triangle, gate=0
                    sta       SID_V1_CTRL
                    lda       #MPI_DEFAULT
                    sta       MPI_CTRL
                    puls      cc,a,pc

                    emod
eom                 equ       *
                    end
