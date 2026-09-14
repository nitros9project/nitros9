* RC16 file-backed tilemaps; based on John Federico's tmtest demos.
* tmtest: platform only. tmtest2: three layers with parallax scrolling.

                    ifp1
                    use       defsfile
                    endc

                    mod       eom,name,Prgrm+Objct,ReEnt+1,start,size
arena               rmb       2
c0addr              rmb       2
c1addr              rmb       2
mapped              rmb       2
nextblock           rmb       2
remaining           rmb       2
chunk               rmb       2
path                rmb       1
opened              rmb       1
saved               rmb       1
status              rmb       1
signal              rmb       1
master              rmb       1
layers              rmb       2
scroll              rmb       2
frames              rmb       2
module              rmb       2
palette_src         rmb       2
palette_num         rmb       2
key                 rmb       1
registers           rmb       48
oldpal              rmb       3072
palette             rmb       1024
                    rmb       512
size                equ       .
name                fcs       /tmtest/
                    fcb       2
start               clra
                    clrb
                    std       <arena
                    std       <c0addr
                    std       <c1addr
                    std       <mapped
                    std       <module
                    std       <scroll
                    stb       <opened
                    stb       <saved
                    stb       <status
                    stb       <signal
                    leax      Intercept,pcr
                    os9       F$Icpt
                    lbcs      Failure
                    clra
                    ldy       #0
                    os9       I$Read
                    lda       #1
                    os9       I$Write
* One arena holds five 8K blocks per tileset plus one block for all maps.
                    ldb       #1*5+1
                    os9       F$AllRAM
                    lbcs      Failure
                    std       <arena
                    ldx       #$C0
                    lbsr      MapOne
                    lbcs      Failure
                    stx       <c0addr
                    clr       <mapped
                    clr       <mapped+1
                    ldx       #$C1
                    lbsr      MapOne
                    lbcs      Failure
                    stx       <c1addr
                    clr       <mapped
                    clr       <mapped+1
* Snapshot the registers and graphics palettes before changing them.
                    ldx       <c0addr
                    leax      $1100,x
                    leay      registers,u
                    ldb       #36
SaveMaps            lda       ,x+
                    sta       ,y+
                    decb
                    bne       SaveMaps
                    ldx       <c0addr
                    leax      $1180,x
                    ldb       #12
SaveSets            lda       ,x+
                    sta       ,y+
                    decb
                    bne       SaveSets
                    ldx       <c1addr
                    leax      $1000,x
                    leay      oldpal,u
                    ldd       #3072
                    lbsr      Copy
                    lda       >TXT.Base
                    sta       <master
                    ldd       >VKY_LAYER_CTRL_0
                    std       <layers
                    inc       <saved
                    leax      tiles0,pcr
                    ldd       <arena
                    addd      #0
                    lbsr      LoadTiles
                    leax      clut0,pcr
                    ldy       #0
                    lbsr      LoadPalette
* Map the final arena block and load the supplied raw map bytes into it.
                    ldd       <arena
                    addd      #1*5
                    tfr       d,x
                    lbsr      MapOne
                    lbcs      Failure
                    leax      map0,pcr
                    lbsr      Open
                    lbcs      Failure
                    ldx       <mapped
                    leax      0,x
                    ldy       #2400
                    lbsr      ReadExact
                    lbcs      Failure
                    lbsr      Close
                    lbcs      Failure
                    lbsr      Unmap
                    lbcs      Failure
                    ldx       <c0addr
                    ldd       <arena
                    addd      #0
                    lbsr      BlockAddress
                    std       $1181,x
                    clr       $1183,x
                    lda       #8                  256-pixel bitmap stride (RC16 cfg bit 3)
                    sta       $1180,x
                    ldd       <arena
                    addd      #5
                    lbsr      BlockAddress
                    addd      #0
                    std       $1101,x
                    clr       $1103,x
                    ldd       #80
                    std       $1104,x
                    ldd       #15
                    std       $1106,x
                    clra
                    clrb
                    std       $1108,x
                    std       $110A,x
                    lda       #1
                    sta       $1100,x
                    lda       >VKY_LAYER_CTRL_0
                    anda      #$F0
                    ora       #4
                    sta       >VKY_LAYER_CTRL_0
                    ifeq      1-3
                    lda       #$54
                    sta       >VKY_LAYER_CTRL_0
                    lda       >VKY_LAYER_CTRL_1
                    anda      #$F0
                    ora       #6
                    sta       >VKY_LAYER_CTRL_1
                    endc
                    lda       <master
                    ora       #Mstr_Ctrl_Graph_Mode_En+Mstr_Ctrl_Text_Overlay+Mstr_Ctrl_TileMap_En
                    sta       >TXT.Base
                    ldd       #900
                    std       <frames
Loop                tst       <signal
                    lbne      Cleanup
                    clra
                    ldb       #SS.Ready
                    os9       I$GetStt
                    bcs       NoKey
                    leax      key,u
                    ldy       #1
                    os9       I$Read
                    lbra      Cleanup
NoKey               equ       *
                    ifeq      1-3
                    ldd       <scroll
                    addd      #1
                    cmpd      #1280
                    blo       ScrollOK
                    clra
                    clrb
ScrollOK            std       <scroll
                    ldx       <c0addr
                    std       $1108,x
                    lsra
                    rorb
                    std       $1114,x
                    lsra
                    rorb
                    std       $1120,x
                    endc
                    ldx       #2
                    os9       F$Sleep
                    ldd       <frames
                    subd      #1
                    std       <frames
                    bne       Loop
                    lbra      Cleanup
Failure             stb       <status
Cleanup             ldx       #0
                    os9       F$Icpt
                    tst       <opened
                    beq       NoOpen
                    lda       <path
                    os9       I$Close
NoOpen              lbsr      Unmap
                    tst       <saved
                    beq       NoRestore
* Disable our tile fetches before restoring pointers and releasing RAM.
                    lda       <master
                    anda      #$EF
                    sta       >TXT.Base
                    leax      oldpal,u
                    ldy       <c1addr
                    leay      $1000,y
                    ldd       #3072
                    lbsr      Copy
                    leax      registers,u
                    ldy       <c0addr
                    leay      $1100,y
                    ldd       #36
                    lbsr      Copy
                    ldy       <c0addr
                    leay      $1180,y
                    ldd       #12
                    lbsr      Copy
                    ldd       <layers
                    std       >VKY_LAYER_CTRL_0
                    lda       <master
                    sta       >TXT.Base
NoRestore           ldx       <c0addr
                    stx       <mapped
                    lbsr      Unmap
                    ldx       <c1addr
                    stx       <mapped
                    lbsr      Unmap
                    ldx       <arena
                    beq       NoArena
                    ldb       #1*5+1
                    os9       F$DelRAM
NoArena             ldb       <status
                    os9       F$Exit
Intercept           stb       <signal
                    rti

* Map exactly one physical block, preserving the process data base.
MapOne              pshs      u
                    ldb       #1
                    os9       F$MapBlk
                    tfr       u,x
                    puls      u
                    bcs       MapReturn
                    stx       <mapped
MapReturn           rts
Unmap               pshs      u
                    ldu       <mapped
                    beq       UnmapNone
                    ldb       #1
                    os9       F$ClrBlk
                    puls      u
                    clr       <mapped
                    clr       <mapped+1
                    rts
UnmapNone           puls      u
                    clrb
                    rts
* Copy D bytes X->Y, preserving U. X/Y advance.
Copy                pshs      d
CopyByte            lda       ,x+
                    sta       ,y+
                    ldd       ,s
                    subd      #1
                    std       ,s
                    bne       CopyByte
                    leas      2,s
                    rts
* Read an exact byte count. Short files and I/O errors abort the demo.
ReadExact           lda       <path
                    pshs      y
                    os9       I$Read
                    bcs       ReadReturn
                    cmpy      ,s
                    beq       ReadReturn
                    ldb       #E$EOF
                    orcc      #1
ReadReturn          leas      2,s
                    rts
Open                lda       #READ.
                    os9       I$Open
                    bcs       OpenReturn
                    sta       <path
                    inc       <opened
OpenReturn          rts
Close               lda       <path
                    os9       I$Close
                    clr       <opened
                    rts
* X = path, D = first block. The supplied tilesets contain exactly 36864 bytes.
LoadTiles           std       <nextblock
                    lbsr      Open
                    lbcs      Failure
                    ldd       #36864
                    std       <remaining
LoadChunk           ldx       <nextblock
                    lbsr      MapOne
                    lbcs      Failure
                    ldy       #8192
                    cmpy      <remaining
                    bls       ChunkOK
                    ldy       <remaining
ChunkOK             sty       <chunk
                    lbsr      ReadExact
                    lbcs      Failure
                    lbsr      Unmap
                    lbcs      Failure
                    ldd       <nextblock
                    addd      #1
                    std       <nextblock
                    ldd       <remaining
                    subd      <chunk
                    std       <remaining
                    bne       LoadChunk
                    lbsr      Close
                    lbcs      Failure
                    rts
* X = CLUT module pathname, Y = CLUT index. Pad short palettes with zeros.
LoadPalette         sty       <palette_num
                    pshs      u
                    clra
                    os9       F$Load
                    tfr       u,d
                    puls      u
                    lbcs      Failure
                    std       <module
                    sty       <palette_src
                    leax      palette,u
                    ldy       #1024
ClearPalette        clr       ,x+
                    leay      -1,y
                    bne       ClearPalette
                    ldx       <module
                    ldd       2,x
                    leax      d,x
                    tfr       x,d
                    subd      <palette_src
                    subd      #3
                    cmpd      #1024
                    bls       PaletteLen
                    ldd       #1024
PaletteLen          tstd
                    beq       PaletteReady
                    ldx       <palette_src
                    leay      palette,u
                    lbsr      Copy
PaletteReady        pshs      u
                    ldu       <module
                    os9       F$Unlink
                    puls      u
                    ldx       <palette_num
                    leay      palette,u
                    clra
                    ldb       #SS.DfPal
                    os9       I$SetStt
                    lbcs      Failure
                    rts
* D = physical block; return the high two bytes of its identity SRAM address.
BlockAddress        lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    rts
tiles0              fcc       "/dd/TESTS/platform_bm"
                    fcb       13
clut0               fcc       "/dd/TESTS/platform_clut"
                    fcb       13
map0                fcc       "/dd/TESTS/l1_platform_80x15.bin"
                    fcb       13
                    emod
eom                 equ       *
                    end
