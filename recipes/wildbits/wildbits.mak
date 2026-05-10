PORT ?= wildbits
RECIPE ?= wildbits
MODDIR = .mods
include ../../rules.mak
-include recipe.mak

vpath %.asm $(3RDPARTY)/packages/basic09

ifeq ($(strip $(PLATFORM)),)
  $(info PLATFORM not set; defaulting to jr2)
  PLATFORM = jr2
endif

ifneq ($(filter $(PLATFORM),jr jr2),)
  KEYSUB = keydrv_ps2
else
  KEYSUB = keydrv_k2
  PLATFORM = k2
endif

DSKIMAGE ?= l$(LEVEL)_$(RECIPE)$(PLATFORM).dsk
OS9FORMAT_CMD ?= $(OS9FORMAT_SD)

AFLAGS += -D$(PLATFORM) -I.
ifeq ($(LEVEL),2)
AFLAGS += -I$(L2PD)
AFLAGS += -I$(L2MD)/kernel -I$(L2PMD)
endif
AFLAGS += -I$(L1MD)/kernel -I$(L1PMD)
AFLAGS += -I$(3RDPARTY)/packages/basic09
AFLAGS += $(AFLAGS_EXTRA)
LFLAGS += -L $(LIBDIR) -lwildbitsl$(LEVEL) -lnet -lalib
LFLAGS += $(LFLAGS_EXTRA)

BOOT_RBF ?= dds0
RBF = rbf rbsuper llwbsd rbmem $(BOOT_RBF) s1 f0 f1 $(RBF_EXTRA)
SCF = scf vtio $(KEYSUB) term bannerfont palette $(SCF_EXTRA)
ifeq ($(LEVEL),2)
SCF += mousedrv_ps2
endif
DRIVEWIRE_RBF = rbdw x0 x1 x2 x3
DRIVEWIRE_SCF = scdwv n1 n2 n3 n4 n5
DRIVEWIRE = dwio_serial $(DRIVEWIRE_RBF) $(DRIVEWIRE_SCF)
DRIVEWIRE_BOOTMODS = dwio_serial $(PIPE) $(SC16550)
PIPE = pipeman piper pipe
SC16550 = sc16550 t0_sc16550
CLOCK = clock clock2_wildbits

# NOTE!!!
# VTIO must be near the top of the bootlist so that it can safely map
# the text and CLUT blocks into $E000-$FFFF.
ifeq ($(LEVEL),2)
BOOTMODS = krnp2 ioman init \
	$(SCF) \
	$(RBF) \
	$(CLOCK) \
	$(BOOTMODS_EXTRA) \
	krn
else
BOOTMODS = krn krnp2 ioman init \
	$(SCF) \
	$(RBF) \
	$(CLOCK) \
	sysgo shell_21 \
	$(BOOTMODS_EXTRA)
endif

CMDS += $(STDCMDS) \
	bootos9 scfg wbinfo wbreset modem \
	inetd telnet dw httpd $(BASIC09) $(BF) \
	$(CMDS_EXTRA)

ifeq ($(LEVEL),2)
UTILPAK1_MODS = attr copy date del deiniz dir display list makdir mdir \
	merge mfree procs rename tmode unlink
CMDS += dmem minted mmap modpatch \
	proc pmap smap \
	gfxstatus xtclut drawtest play \
	shellbg shellbgoff ntptime view utilpak1
endif

BASIC09 = basic09 runb inkey syscall wild
BASIC09_FILES = $(wildcard $(3RDPARTY)/packages/basic09/samples/*.b09)
STARTUP = $(LEVEL2)/wildbits/startup
FEU_STARTUP = feu.startup
SCRIPTS_DIR = $(LEVEL1)/wildbits/scripts
TESTS_DIR = $(LEVEL1)/wildbits/tests
SCRIPTS = $(notdir $(wildcard $(SCRIPTS_DIR)/*))
TESTS = $(notdir $(wildcard $(TESTS_DIR)/*))
FONT_DIR = $(LEVEL1)/wildbits/sys/fonts
BACKGROUND_DIR = $(LEVEL1)/wildbits/sys/backgrounds
FONTS = 800yfont applefont bigbluefont boxedfont bannerfont.sb \
	c256seriffont cbmfont commodedorfont enemigafont f256standardfont \
	IIishfont jessefont msxbannerfont msxfont petticoatsfont \
	phoenixegafont.sb quadrotextfont techfont thickefont
BACKGROUNDS = clutbeach clutgrid clutmeadow clutmetal clutspace clutstone clutstone2 clutwood \
	pixmapbeach pixmapgrid pixmapmeadow pixmapmetal pixmapspace pixmapstone \
	pixmapstone2 pixmapwood pixmappaintspl pixmappaint2 clutpaintspl clutpaint2 \
	pixmapwizfi pixmapwizfi2 clutwizfi clutwizfi2 testclutbm0 testclutbm1 testclutbm2 \
	testpixmapbm0 testpixmapbm1 testpixmapbm2

ifeq ($(LEVEL),2)
SYS_DIR = $(LEVEL2)/wildbits/sys
SYS_TEXT_FILES = $(LEVEL2)/sys/motd $(LEVEL1)/sys/errmsg $(LEVEL1)/sys/password \
	$(SYS_DIR)/helpmsg $(SYS_DIR)/inetd.conf
SYS_BIN_FILES = $(addprefix $(SYS_DIR)/,stdfonts stdpats_2 stdpats_4 stdpats_16 stdptrs \
	ibmedcfont isolatin1font)
else
SYS_DIR = $(LEVEL1)/wildbits/sys
SYS_TEXT_FILES = $(LEVEL1)/sys/motd $(LEVEL1)/sys/errmsg $(LEVEL1)/sys/password \
	$(SYS_DIR)/helpmsg $(SYS_DIR)/inetd.conf
SYS_BIN_FILES =
endif

all: libs $(DSKIMAGE)

LIB_NAMES = libwildbitsl$(LEVEL).a libnet.a libalib.a
include ../../libs.mak

$(MODDIR)/sysgo: $(OBJDIR)/sysgo.o | $(MODDIR)
	$(LINKER) $(LFLAGS) $^ -osysgo
	$(MOVE) sysgo $@

$(OBJDIR)/sysgo.o: sysgo.as | $(OBJDIR)
.PHONY: wildbits-sys-assets
wildbits-sys-assets:
	$(MAKE) -C $(SYS_DIR)
	$(MAKE) -C $(FONT_DIR)
	$(MAKE) -C $(BACKGROUND_DIR)

$(FEU_STARTUP): FORCE
	echo "bootos9 /s0/OS9Boot" >> $@

FORCE: ;

ifeq ($(LEVEL),2)
  PADUP ?= ./padup256 bootfile
endif
bootfile: $(addprefix $(MODDIR)/,$(BOOTMODS))
	$(MERGE) $(addprefix $(MODDIR)/,$(BOOTMODS))>$@
	$(PADUP)

ifeq ($(LEVEL),2)
$(DSKIMAGE): bootfile $(MODDIR)/sysgo $(addprefix $(MODDIR)/,$(CMDS)) $(STARTUP) $(FEU_STARTUP) wildbits-sys-assets
else
$(DSKIMAGE): bootfile $(addprefix $(MODDIR)/,$(CMDS)) $(STARTUP) $(FEU_STARTUP) wildbits-sys-assets
endif
	$(RM) $@
	$(OS9FORMAT_CMD) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9COPY) bootfile $@,OS9Boot
ifeq ($(LEVEL),2)
	$(OS9COPY) $(MODDIR)/sysgo $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
endif
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) $(addprefix $(MODDIR)/,$(CMDS)) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(OS9RENAME) $@,CMDS/shellplus shell
	$(CPL) $(SYS_TEXT_FILES) $@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYS_TEXT_FILES)),$@,SYS/$(file))
ifneq ($(strip $(SYS_BIN_FILES)),)
	$(OS9COPY) $(SYS_BIN_FILES) $@,SYS
endif
	$(MAKDIR) $@,SYS/fonts
	$(OS9COPY) $(addprefix $(FONT_DIR)/,$(FONTS)) $@,SYS/fonts
	$(MAKDIR) $@,SYS/backgrounds
	$(OS9COPY) $(addprefix $(BACKGROUND_DIR)/,$(BACKGROUNDS)) $@,SYS/backgrounds
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,BASIC09
	$(CPL) $(BASIC09_FILES) $@,BASIC09
	$(MAKDIR) $@,SCRIPTS
	$(foreach file,$(SCRIPTS),$(CPL) $(SCRIPTS_DIR)/$(file) $@,SCRIPTS;)
	$(MAKDIR) $@,TESTS
	$(foreach file,$(TESTS),$(CPL) $(TESTS_DIR)/$(file) $@,TESTS;)
	$(MAKDIR) $@,FEU
	$(CPL) $(FEU_STARTUP) $@,FEU/startup

# Command rules
$(MODDIR)/pwd: pd.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPWD=1

$(MODDIR)/pxd: pd.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPXD=1

$(MODDIR)/xmode: xmode.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DXMODE=1

$(MODDIR)/tmode: xmode.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DTMODE=1

ifeq ($(LEVEL),2)
$(MODDIR)/utilpak1: $(addprefix $(MODDIR)/,$(UTILPAK1_MODS)) | $(MODDIR)
	$(MERGE) $^ > utilpak1
	$(MOVE) utilpak1 $@
endif

# Descriptor rules
# SD card descriptors
$(MODDIR)/dds0: rbwbsddesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(WBSDFLAGS) -DSD=0 -DDD=1

$(MODDIR)/s0: rbwbsddesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(WBSDFLAGS) -DSD=0

$(MODDIR)/s1: rbwbsddesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(WBSDFLAGS) -DSD=1

# rbmem descriptors
$(MODDIR)/f0: rbmemdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDNum=0

$(MODDIR)/f1: rbmemdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDNum=1 -DF1=1

$(MODDIR)/c0: rbmemdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDNum=2 -DC0=1

$(MODDIR)/c1: rbmemdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDNum=3 -DC1=1

$(MODDIR)/ddc0: rbmemdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDNum=2 -DDD=1 -DC0=1

# DriveWire dwio modules
$(MODDIR)/dwio_wizfi: dwio.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDWIO_WIZFI

$(MODDIR)/dwio_serial: dwio.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDWIO_SERIAL

# DriveWire 3 RBF descriptors
$(MODDIR)/ddx0: dwdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDD=1 -DDNum=0

$(MODDIR)/x0: dwdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDNum=0

$(MODDIR)/x1: dwdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDNum=1

$(MODDIR)/x2: dwdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDNum=2

$(MODDIR)/x3: dwdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDNum=3

# 16550 descriptors
$(MODDIR)/t0_sc16550: sc16550desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

# DriveWire 3 SCF descriptors
$(MODDIR)/term_n.dt: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=0

$(MODDIR)/n: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=255

$(MODDIR)/n0: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=0

$(MODDIR)/n1: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=1

$(MODDIR)/n2: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=2

$(MODDIR)/n3: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=3

$(MODDIR)/n4: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=4

$(MODDIR)/n5: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=5

$(MODDIR)/n6: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=6

$(MODDIR)/n7: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=7

$(MODDIR)/n8: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=8

$(MODDIR)/n9: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=9

$(MODDIR)/n10: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=10

$(MODDIR)/n11: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=11

$(MODDIR)/n12: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=12

$(MODDIR)/n13: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=13

$(MODDIR)/midi: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=14

$(MODDIR)/term_z.dt: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=16

$(MODDIR)/z1: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=17

$(MODDIR)/z2: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=18

$(MODDIR)/z3: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=19

$(MODDIR)/z4: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=20

$(MODDIR)/z5: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=21

$(MODDIR)/z6: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=22

$(MODDIR)/z7: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=23

$(MODDIR)/z8: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=24

$(MODDIR)/z9: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=25

$(MODDIR)/z10: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=26

$(MODDIR)/z11: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=27

$(MODDIR)/z12: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=28

$(MODDIR)/z13: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=29

$(MODDIR)/z14: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=30

clean:
	$(RM) *.list *.map bootfile *.dsk buildinfo feu.startup
	-rm -rf $(OBJDIR) $(LIBDIR) $(MODDIR)

.PHONY: all clean libs
