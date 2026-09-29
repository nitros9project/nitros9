# CocoMEM Jr port-specific modules

Sources here override same-named files elsewhere on the recipe vpath
(`level2/cocomemjr/modules` is searched first when `PORT=cocomemjr`).

The CocoMEM Jr is an MMU board for the CoCo 1/2. It is register-compatible with
the CoCo 3 GIME MMU ($FF90/$FF91, $FFA0-$FFAF), but:

- blocks $38-$3F are the 64K motherboard RAM, the only RAM the SAM/VDG can
  display; every other block number is MemJr internal RAM
- $FF90 bit 7 is inverted compared with the GIME: 0 = alternate vectors
  ($FFE0-$FFFF from internal RAM), 1 = CoCo 1/2 vectors from ROM
- there is no GIME video, timer or interrupt controller: video is VDG + SAM,
  and the clock IRQ comes from the PIA0 VSYNC interrupt
