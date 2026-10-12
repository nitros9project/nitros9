* Companion wave data. U process base; never load an entire ROM into the
* process map. A/B/X/Y/CC scratch; U remains the process base.
* Companion files live in /dd/astro, independent of the current directory.
OpenAstroData    leax      AstroDataName,pcr
                    lda       #READ.
                    os9       I$Open
AssetOpened      bcs       AssetError
                    sta       AD_AssetPath,u
                    inc       AD_AssetOpen,u
                    leax      AD_AssetDirectory,u
                    ldy       #AS_HeaderBytes
                    os9       I$Read
                    bcs       AssetError
                    cmpy      #AS_HeaderBytes
                    bne       AssetBadData
                    leax      AD_AssetDirectory,u
                    leay      AstroDataSignature,pcr
                    ldb       #AS_PrefixBytes
AssetCheckSignature lda   ,x+
                    cmpa      ,y+
                    bne       AssetBadData
                    decb
                    bne       AssetCheckSignature
                    clrb
                    rts
AssetBadData     ldb       #E$BTyp
AssetError       stb       AD_AssetError,u
                    orcc      #1
                    rts

* B one-based original wave number; U process base. X returns a native
* wave descriptor in the owned buffer, B/error and C follow OS-9. Y scratch.
LoadWaveData    tstb
                    beq       AssetBadData
                    cmpb      #AS_WaveCount
                    bhi       AssetBadData
                    decb
                    lda       #AS_EntryBytes
                    mul
                    leax      AD_AssetDirectory+AS_PrefixBytes,u
                    leax      d,x
                    ldd       4,x
                    beq       AssetBadData
                    cmpd      #AS_BufferBytes
                    bhi       AssetBadData
                    std       AD_AssetLength,u
                    ldy       2,x
                    ldx       ,x
                    lda       AD_AssetPath,u
                    pshs      u         stack offset: process base; I$Seek uses X:U
                    tfr       y,u
                    os9       I$Seek
                    puls      u
                    bcs       AssetError
                    leax      AD_WaveBuffer,u
                    ldy       AD_AssetLength,u
                    lda       AD_AssetPath,u
                    os9       I$Read
                    bcs       AssetError
                    cmpy      AD_AssetLength,u
                    bne       AssetBadData
                    leax      AD_WaveBuffer,u
                    ldd       ,x
                    cmpd      AD_AssetLength,u
                    bhs       AssetBadData
                    leax      d,x
                    clrb
                    rts

CloseAstroData   tst       AD_AssetOpen,u
                    beq       AssetCloseOK
                    lda       AD_AssetPath,u
                    os9       I$Close
                    bcs       AssetCloseReturn
                    clr       AD_AssetOpen,u
AssetCloseOK     clrb
AssetCloseReturn rts
AstroDataName    fcc       "/dd/astro/astro.dat"
                    fcb       C$CR
AstroDataSignature fcc     /ASTRO1/
                    fdb       AS_WaveCount
