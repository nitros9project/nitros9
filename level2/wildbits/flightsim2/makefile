# Flight Simulator II (subLOGIC, 1987), ported to the WildBits: the WildBits FS2.
#
# port/ is the WildBits source: fs.asm (with its subsystems port/fs_*.asm and the platform layer fs_wb.asm),
# f2.asm, f3.asm, f4.asm and fsd.asm (FSD, the data module stored after F4 in the f4 file), and fsw.asm, the drawing
# layer FS loads from /dd/fs2/fsw. The disks get these through recipes/wildbits/wildbits.mak; this makefile builds
# the same modules into .mods/ on their own. fd and sf.standard are the program's data files (the CoCo's panel
# pictures fa and fp are gone: the panel is the dashboard, dash.bm); sf.europe and
# sf.japan the subLOGIC scenery disks; sf.sd7 and sf.sd11 subLOGIC's Scenery Disks 7 and 11 converted from the Atari ST
# version (wildbits-buildkit/tools/flightsim2/st_sd.py); sf.wildbits is sf.standard with its Chicago areas converted
# from the Atari ST version (wildbits-buildkit/tools/flightsim2/st/st2coco.py) and a full-scale 1987 O'Hare (tools/flightsim2/sf_wildbits.py), and fd starts the aircraft parked on its south cargo apron. fs.asm, f2.asm, f3.asm and f4.asm
# in this directory are the CoCo 3 package's byte listings, kept for reference only; nothing builds them.

NITROS9DIR ?= $(realpath ../../..)
include $(NITROS9DIR)/rules.mak

MODDIR       = .mods
MODS         = fs f2 f3 f4 f5 fsd
$(MODDIR)/f5: port/f5_data.asm
SUPPORTFILES = fd sf.standard sf.europe sf.japan sf.sd7 sf.sd11 sf.wildbits dash.bm

# /FTDD, the frame timer FS reads (I$GetStt $80, I$SetStt $81): NitrOS-9's generic VRN driver (VIRQ through the
# clock's F$VIRQ, with FS2's table) and the CoCo 3 FTDD descriptor, assembled with the WildBits defs. Its hardware
# port ($FF01) is not used by VRN.
DRIVERS  = vrn ftdd

all: $(addprefix $(MODDIR)/,$(MODS) fsw fsx fsp $(DRIVERS))

$(MODDIR)/vrn: $(NITROS9DIR)/level1/modules/vrn.asm | $(MODDIR)
	$(AS) $(AFLAGS) -I.. $< $(ASOUT)$@

$(MODDIR)/ftdd: $(NITROS9DIR)/level2/coco3/modules/ftdd.asm | $(MODDIR)
	$(AS) $(AFLAGS) -I.. $< $(ASOUT)$@

$(MODDIR):
	mkdir -p $@

# fs.asm is the module header; it pulls in its subsystems (port/fs_*.asm) with use.
$(MODDIR)/fs: $(wildcard port/fs_*.asm)
$(addprefix $(MODDIR)/,$(MODS)): port/fs_wb.d

$(addprefix $(MODDIR)/,$(MODS)): $(MODDIR)/%: port/%.asm | $(MODDIR)
	$(AS) $(AFLAGS) -I.. -Iport $< $(ASOUT)$@

# fsw: the WildBits drawing layer, a raw binary FS loads from /dd/fs2/fsw at startup
$(MODDIR)/fsw: port/fsw.asm port/fs_wb.d | $(MODDIR)
	$(AS) $(AFLAGS) --format=raw -I.. -Iport $< $(ASOUT)$@

# fsx: the spot view, a raw binary fsw reads into a RAM block of its own
$(MODDIR)/fsx: port/fsx.asm port/fsx_cessna.asm port/fs_wb.d | $(MODDIR)
	$(AS) $(AFLAGS) --format=raw -I.. -Iport $< $(ASOUT)$@

# fsp: the dashboard (K2), a raw binary fsw reads into a RAM block of its own; its art is dash.bm
$(MODDIR)/fsp: port/fsp.asm port/fs_wb.d | $(MODDIR)
	$(AS) $(AFLAGS) --format=raw -I.. -Iport $< $(ASOUT)$@

clean:
	$(RM) -r $(MODDIR)

.PHONY: all clean
