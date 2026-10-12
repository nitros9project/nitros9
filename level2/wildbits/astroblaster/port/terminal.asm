* Multi-Term / VT display ownership. U always addresses AP_StateBytes.
* All display changes go through the inherited output path and its mirror.
* No direct VICKY, keyboard, DMA, MMU, or interrupt-register access.
* D,X,Y,CC are scratch. U is preserved across every call, including calls
* whose OS-9 ABI uses U as an argument or return value.
*
* PrepareDisplay allocates and clears the tile memory (tilevideo.asm).
* ShowDisplay is separate: install palette and first frame before calling it.
* CloseDisplay releases resources; call it on startup failure as well as exit.
* Do not call PrepareDisplay again before CloseDisplay has succeeded.
PrepareDisplay     leax      ,u
                    ldb       #AP_StateBytes
PrepareStateClear  clr       ,x+
                    decb
                    bne       PrepareStateClear
                    lda       #ASTRO_OUTPUT_PATH
                    ldb       #SS.MCR
                    os9       I$GetStt
                    bcs       PrepareReturn
                    stx       AP_SavedMCRLow,u
                    sty       AP_SavedMCRHigh,u
* Never displace an existing graphics application on this VT.
                    tfr       x,d
                    andb      #ASTRO_GRAPHICS_MASK
                    beq       PrepareWatchTerminal
                    comb
                    ldb       #E$WADef
                    rts
PrepareWatchTerminal
                    lbsr      WatchTerminal
                    bcs       PrepareReturn
PrepareTryBitmap   lbra      InitializeTileMemory
PrepareReturn      rts
ShowDisplay        lbsr      ShowTileDisplay
                    bcs       ShowReturn
* Record restore responsibility BEFORE a call that could partly change state.
                    inc       AP_SavedDisplay,u
                    ldd       AP_SavedMCRHigh,u
                    andb      #ASTRO_60HZ_MASK
                    tfr       d,y
                    ldx       #ASTRO_GRAPHICS
                    lda       #ASTRO_OUTPUT_PATH
                    ldb       #SS.MCR
                    os9       I$SetStt
ShowReturn         rts

ReleaseDisplayMapping
                    tst       AP_HasMapping,u
                    beq       DisplayReturnOK
                    ldx       AP_MapAddress,u
                    pshs      u
                    tfr       x,u
                    ldb       #1
                    os9       F$ClrBlk
                    puls      u
                    bcs       DisplayReturn
                    clr       AP_HasMapping,u
DisplayReturnOK    clrb
DisplayReturn      rts

CloseDisplay       clr       AP_Error,u
                    tst       AP_SavedDisplay,u
                    beq       CloseMapping
                    ldx       AP_SavedMCRLow,u
                    ldy       AP_SavedMCRHigh,u
                    lda       #ASTRO_OUTPUT_PATH
                    ldb       #SS.MCR
                    os9       I$SetStt
                    bcc       CloseRestored
                    stb       AP_Error,u
                    bra       CloseMapping
CloseRestored      clr       AP_SavedDisplay,u
CloseMapping       lbsr      ReleaseDisplayMapping
                    bcc       CloseBitmap
                    tst       AP_Error,u
                    bne       CloseResult
                    stb       AP_Error,u
                    bra       CloseResult
CloseBitmap
                    tst       AP_OwnsBitmap,u
                    beq       CloseResult
                    lbsr      CloseTileDisplay
                    bcc       CloseBitmapReleased
                    tst       AP_Error,u
                    bne       CloseResult
                    stb       AP_Error,u
                    bra       CloseResult
CloseBitmapReleased
                    clr       AP_OwnsBitmap,u
CloseResult        lbsr      UnwatchTerminal
                    bcc       CloseReturnError
                    tst       AP_Error,u
                    bne       CloseReturnError
                    stb       AP_Error,u
CloseReturnError
                    ldb       AP_Error,u
                    beq       DisplayReturnOK
                    orcc      #1
                    rts
