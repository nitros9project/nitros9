                    use       ../defsfile

                    org       $FC00

                    orcc      #IntMasks           mask interrupts from the start
                    lds       #$500               load stack with something meaningful
                    clr       >MMU_MEM_CTRL       this just resets the MMU

* The Foenix keeps shadow RAM at $FFF0-$FFFF that isn't affected by changing out
* MMU blocks from $E000-$FFFF (slot 7). Copy the 6809 vectors to this shadow RAM
* location and leave it turned on.
                    ldx       #$FFF0              load the base address
                    ldd       #$00*256+$02        clear/set bit for shadow RAM
l@                  sta       >MMU_IO_CTRL        turn off the shadow RAM
                    ldy       ,x                  get the byte at the non-shadow RAM location
                    stb       >MMU_IO_CTRL        turn on the shadow RAM
                    sty       ,x++                and store the byte at the shadow RAM location
                    cmpx      #$0000              are we at the end?
                    bne       l@                  continue if not done

* Set up the MMU.
                    leax      MMUValues,pcr       point to the values to copy
                    ldy       #MMU_SLOT_0         and the base MMU slot
                    ldb       #8                  load the counter
loop@               lda       ,x+                 get the source value
                    sta       ,y+                 and save it to the destination
                    decb                          decrement the counter
                    bne       loop@               continue if more

* Place 'rti' instruction in the interrupt vectors.
                    lda       #$3B                load A with 'rti' instruction
                    sta       $103                store in vector
                    sta       $106                store in vector
                    sta       $109                store in vector
                    sta       $10C                store in vector
                    sta       $10F                store in vector

* Turn on interrupts so that we can "eat" the keyboard interrupt that we can't
* seem to clear or turn off.
                    andcc     #^IntMasks

* Initialize the keyboard.
* Note this is specific to the F256 Jr. and its PS/2 keyboard.
* Clear the keyboard buffer of any residual data.
                    lda       PS2_CTRL            get the control byte
                    ora       #KCLR               OR in the keyboard's "clear input FIFO queue" bit
                    sta       PS2_CTRL            save it to the control byte register
                    anda      #^KCLR              AND in the complement of the same bit
                    sta       PS2_CTRL            save it to control byte register

                    lda       #$03
l1@                 ldx       #$0000
l2@                 leax      -1,x
                    cmpx      #$0000
                    bne       l2@
                    deca
                    bne       l1@

* Jump to the kernel.
                    ldx       #$8000
                    ldy       #$7D00
                    jmp       $11,x               jump to the kernel

MMUValues
                    ifeq      FLASH-1
                    fcb       $00,$01,$02,$03,$7C,$7D,$7E,$7F
                    else
                    fcb       $00,$01,$02,$03,$04,$05,$06,$07
                    endc

                    fill      $FF,$FFF0-*
                    fdb       $0000,$0100,$0103,$010f,$010c,$0106,$0109,$fc00
