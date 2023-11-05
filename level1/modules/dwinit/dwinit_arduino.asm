DWInit

* setup PIA PORTA (read)
                    clr       $FF51
                    clr       $FF50
                    lda       #$2C
                    sta       $FF51

* setup PIA PORTB (write)
                    clr       $FF53
                    lda       #$FF
                    sta       $FF52
                    lda       #$2C
                    sta       $FF53
                    rts
