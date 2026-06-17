*******************************************************
*
* DWInit
*    Initialize DriveWire for CoCo Bit Banger

                  IFNE    MEGAMINIMPI
                    use       dwinit/dwinit_mmmpi.asm
                  ENDC

                  IFNE    wildbits
                  IFNE    DWIO_WIZFI
                    use       dwinit_wildbits_wizfi.asm
                  ELSE
                    use       dwinit_wildbits_serial.asm
                  ENDC
                  ENDC

                  IFNE    ARDUINO
                    use       dwinit/dwinit_arduino.asm
                  ENDC

                  IFNE    BECKER
                    use       dwinit/dwinit_none.asm
                  ENDC

                  IFNE    JMCPBCK+atari
                    use       dwinit/dwinit_none.asm
                  ENDC

                  IFNE    BECKERTO
                    use       dwinit/dwinit_none.asm
                  ENDC

                  IFNE    SY6551N
                    use       dwinit/dwinit_none.asm
                  ENDC

                  IFNE    picothing
                    use       dwinit/dwinit_picothing.asm
                  ENDC

                  IFEQ    BECKER+JMCPBCK+ARDUINO+BECKERTO+SY6551N+wildbits+MEGAMINIMPI+atari+picothing
                    use       dwinit/dwinit_bb.asm
                  ENDC
