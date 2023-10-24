                    ifne      1

* Checksum routine - D returns as the sum of all bytes of the sector
* Entry: X = address of sector
* Exit : D = checksum value
DoCSum              equ       *
                    clr       ,-s
                    clra
                    clrb
c2@                 addb      ,x+
                    adca      #0
                    dec       ,s
                    bne       c2@
                    leas      1,s
*         exg   a,b		do endian conversion to match Server's checksum
                    rts


* Weak but fast CRC Computation Routine
* Entry: X = address of sector
* Exit : D = crc value
*DoCRC    equ   *
*         IFNE  H6309
*         clrd
*         clre
*CRC2     eord  ,x++
*         ince
*         bpl   CRC2
*         ELSE
*         clr   ,-s
*         clra
*         clrb
*CRC2     eora  ,x+
*         eorb  ,x+
*         inc   ,s
*         bpl   CRC2
*         leas  1,s
*         ENDC
*         exg   a,b		do endian conversion to match PC's CRC
*         rts


                    else

* CCITT CRC-16 Computation Routine
*
* Provided by Tim Lindner - 02/12/2003
*
* Entry: X = address of sector
* Exit : D = crc value
*CRC16    equ   *
*         IFNE  H6309
*         clrd
*         clre
*         ELSE
*         clra
*         clrb
*         pshs  b		save as counter of 256 bytes
*         ENDC
*CRCLP    eora  ,x+
*         IFNE  H6309
*         lsld
*         ELSE
*         lslb
*         rola
*         ENDC
*         bcc   CRCLp0
*         IFNE  H6309
*         eord  #$1021
*         ELSE
*         eora  #$10
*         eorb  #$21
*         ENDC
*CRCLp0   equ   *
*         IFNE  H6309
*         lsld
*         ELSE
*         lslb
*         rola
*         ENDC
*         bcc   CRCLp1
*         IFNE  H6309
*         eord  #$1021
*         ELSE
*         eora  #$10
*         eorb  #$21
*         ENDC
*CRCLp1   equ   *
*         IFNE  H6309
*         lsld
*         ELSE
*         lslb
*         rola
*         ENDC
*         bcc   CRCLp2
*         IFNE  H6309
*         eord  #$1021
*         ELSE
*         eora  #$10
*         eorb  #$21
*         ENDC
*CRCLp2   equ   *
*         IFNE  H6309
*         lsld
*         ELSE
*         lslb
*         rola
*         ENDC
*         bcc   CRCLp3
*         IFNE  H6309
*         eord  #$1021
*         ELSE
*         eora  #$10
*         eorb  #$21
*         ENDC
*CRCLp3   equ   *
*         IFNE  H6309
*         lsld
*         ELSE
*         lslb
*         rola
*         ENDC
*         bcc   CRCLp4
**         IFNE  H6309
**         eord  #$1021
*         ELSE
*         eora  #$10
*         eorb  #$21
*         ENDC
*CRCLp4   equ   *
*         IFNE  H6309
*         lsld
*         ELSE
*         lslb
*         rola
*         ENDC
*         bcc   CRCLp5
*         IFNE  H6309
*         eord  #$1021
*         ELSE
*         eora  #$10
*         eorb  #$21
*         ENDC
*CRCLp5   equ   *
*         IFNE  H6309
*         lsld
*         ELSE
*         lslb
*         rola
*         ENDC
*         bcc   CRCLp6
*         IFNE  H6309
*         eord  #$1021
*         ELSE
*         eora  #$10
*         eorb  #$21
*         ENDC
*CRCLp6   equ   *
*         IFNE  H6309
*         lsld
*         ELSE
*         lslb
*         rola
*         ENDC
*         bcc   CRCLp7
*         IFNE  H6309
*         eord  #$1021
*         ELSE
*         eora  #$10
*         eorb  #$21
*         ENDC
*CRCLp7   equ   *
*         IFNE  H6309
*         dece
*         ELSE
*         dec   ,s
*         ENDC
*         bne   CRCLp
*         IFEQ  H6309
*         leas  1,s		eat counter on stack
*         ENDC
*         rts
*
*         ENDC
*

* calculate CCITT CRC 16
* input:  X - Address of block
*       Block is assumed to be 256 bytes
* output: D - 16 bit CRC
* uses: X, D, CC, and two bytes of stack

DoCRC               equ       *
                    ifne      H6309

                    clre
                    clrd
nextbyte            ldf       #8
                    eora      ,x+
nextbit             lsld
                    bcc       loop
                    eord      #$1021
loop                decf
                    bne       nextbit
                    dece
                    bne       nextbyte
                    rts

                    else

                    clra
                    clrb
                    pshs      y,b
nextbyte            ldy       #8
                    eora      ,x+
nextbit             lslb
                    rola
                    bcc       loop
                    eora      #$10
                    eorb      #$21
loop                leay      -1,y
                    bne       nextbit
                    dec       ,s
                    bne       nextbyte
                    leas      1,s
                    puls      y,pc

                    endc
                    endc

