********************************************************************
* sky_cols.asm - the sky and ground colors for FS's season and light (Roger's chart, 2026-10-27), in fsx at
* FsxSkyCol: fsw's Horizon when the light or the season moved (its HzKey), and fsx's ViewKey after the GPU view's
* mode. The ground is FS's green at every light (fs_panel.asm's DrawSkyGround: FsGndCol), its RGB in CLUT 0 entry
* FsGndCol; the scenery's green fields follow it. The sky: VICKY's background where the sky is color 0, the
* see-through nibble (the Jr2, a K2 without the GPU); CLUT 0 entry ScSkyIx in the K2 GPU's 320 x 256-color view
* (the prop's ramp: ac2gpu.py draws the prop in FS's color 10 at every shade, so its entries are free); FS's own
* sky color in the GPU's 640 x 16 view (four bits). FswHzSkyIx: the color fsw's HzSky gives the sky's bands.
* D, X clobbered.

ScBgBytes           equ       3                   GpuF.FixN's U: the background's blue, green, red
ScClutY             equ       0                   SS.ClutWrite's Y high byte: CLUT 0
ScGndY              equ       ScClutY*256+FsGndCol SS.ClutWrite's Y: CLUT 0, the ground's entry
ScLightMax          equ       2                   vLight >> 1: day 0, dawn and dusk 1, night 2
ScNibble            equ       $0F                 a color in a pattern byte's low nibble
ScOne               equ       1                   SS.ClutWrite's U: one entry
ScRgb               equ       3                   a color in ScTab: blue, green, red
ScPair              equ       ScRgb*2             a light's sky, then its ground
ScSeason            equ       ScPair*3            a season's day, dawn and dusk, night
ScSeasonMask        equ       3                   vSeason - 1 (1-4): ScTab's season 0-3
ScSeeThrough        equ       0                   the sky's bands in color 0: VICKY's background shows
ScSkyIx             equ       159                 the K2's sky in the 256-color view: the prop's ramp's last entry
ScSkyY              equ       ScClutY*256+ScSkyIx SS.ClutWrite's Y: CLUT 0, the K2's sky entry

SkyCol              pshs      y,u
                    ldb       >vSeason
                    decb
                    andb      #ScSeasonMask
                    lda       #ScSeason
                    mul
                    ldx       #ScTab
                    abx
                    lda       >vLight
                    lsra
                    cmpa      #ScLightMax
                    bls       sc1@
                    lda       #ScLightMax
sc1@                ldb       #ScPair
                    mul
                    abx                           X = the light's sky (blue, green, red), then its ground
                    ldy       #ScGndY             the ground
                    leau      ScRgb,x
                    bsr       ScPut
                    tst       >FswHwGpu
                    beq       sc5@                no GPU: the sky see-through, VICKY's background
                    lda       >FswGpCtl
                    bita      #GpuCtl256
                    bne       sc3@
                    lda       >vSkyCol            the 640 x 16 view: FS's own sky color
                    anda      #ScNibble
                    bra       sc4@
sc3@                ldy       #ScSkyY             the 256-color view: the sky's own entry
                    leau      ,x
                    bsr       ScPut
                    lda       #ScSkyIx
sc4@                sta       >FswHzSkyIx
                    puls      y,u,pc
sc5@                ldd       ,x                  VICKY's background: blue, green, red
                    std       ScBgRq+4
                    lda       2,x
                    sta       ScBgRq+6
                    ldx       #GpFnFixVicky
                    ldy       #ScBgRq
                    ldu       #ScBgBytes
                    clra                          GpCall: its SetStat functions
                    lbsr      GpCall
                    lda       #ScSeeThrough
                    bra       sc4@
* ScPut: U = a color (blue, green, red) to CLUT entry Y, SS.ClutWrite on FS's display path. X kept; D, U clobbered.
ScPut               pshs      x
                    ldd       ,u
                    std       ScBuf
                    lda       2,u
                    sta       ScBuf+2
                    ldx       #ScBuf
                    ldu       #ScOne
                    lda       >FsPath
                    ldb       #SS.ClutWrite
                    swi2
                    fcb       I$SetStt
                    puls      x,pc
ScBuf               fcb       0,0,0,0             one CLUT entry: blue, green, red, 0
ScBgRq              fdb       BACKGROUND_COLOR_B  GpuF.FixN's request: the offset, the mask, 0, then blue, green, red
                    fcb       3,0
                    rmb       3
* ScTab: each season's day, dawn and dusk, night: the sky's blue, green, red, then the ground's
ScTab               fcb       $E0,$B8,$D9,$F6,$F0,$EE   winter day: sky #D9B8E0, ground #EEF0F6
                    fcb       $92,$4F,$8A,$C4,$A3,$A9   winter dusk: #8A4F92, #A9A3C4
                    fcb       $22,$0C,$16,$44,$3A,$3A   winter night: #160C22, #3A3A44
                    fcb       $F2,$C2,$9C,$3F,$B2,$5D   spring day: #9CC2F2, #5DB23F
                    fcb       $B4,$64,$5E,$2B,$6E,$2F   spring dusk: #5E64B4, #2F6E2B
                    fcb       $28,$10,$0A,$2A,$2A,$2A   spring night: #0A1028, #2A2A2A
                    fcb       $F5,$AE,$74,$2F,$9B,$3F   summer day: #74AEF5, #3F9B2F
                    fcb       $A8,$5C,$4F,$24,$5F,$28   summer dusk: #4F5CA8, #285F24
                    fcb       $30,$12,$0B,$26,$26,$26   summer night: #0B1230, #262626
                    fcb       $97,$B8,$D8,$32,$7C,$A5   fall day: #D8B897, #A57C32
                    fcb       $30,$5B,$B6,$20,$43,$5E   fall dusk: #B65B30, #5E4320
                    fcb       $18,$10,$1A,$24,$27,$2B   fall night: #1A1018, #2B2724
