* Address arithmetic for the calling VT's allocated bitmap.
* B = y, X = BYTE column (0..319), U = platform state.
* Success: X = physical block, D = offset within that block, C clear.
* Error: B = E$IllArg, C set. Y,U preserved; other results undefined.
* Does not map memory or write hardware. In particular, offsets above
* $FFFF in the 76,800-byte bitmap do not wrap into its first block.
BitmapByteAddress  pshs      x,y
                    leas      -BA_FrameBytes,s
                    cmpb      #SCREEN_HEIGHT
                    bhs       BitmapAddressBad
                    cmpx      #SCREEN_STRIDE
                    bhs       BitmapAddressBad
                    clr       BA_Bank,s
                    lda       #BITMAP_HALF_STRIDE
                    mul                 D = y*160, at most 38240
                    lslb
                    rola                C:D = y*320 (17 bits)
                    bcc       BitmapRowLow
                    inc       BA_Bank,s
BitmapRowLow
                    addd      BA_Column,s
                    bcc       BitmapAddressInBlock
                    inc       BA_Bank,s
BitmapAddressInBlock
                    pshs      d
                    lsra                high byte >> 5 gives low 3 block bits
                    lsra
                    lsra
                    lsra
                    lsra
                    ldb       BA_OffsetBytes+BA_Bank,s ; stack offset past result D
                    lslb                carry above 64K represents eight blocks
                    lslb
                    lslb
                    pshs      b
                    ora       ,s+       stack offset 0: temporary high block bits
                    tfr       a,b
                    ldx       AP_FirstBlock,u
                    abx
                    puls      d
                    anda      #BITMAP_OFFSET_HI_MASK
                    leas      BA_FrameBytes+BA_SavedXBytes,s
                    andcc     #$FE
                    puls      y,pc
BitmapAddressBad   leas      BA_FrameBytes+BA_SavedXBytes,s
                    ldb       #E$IllArg
                    orcc      #1
                    puls      y,pc

