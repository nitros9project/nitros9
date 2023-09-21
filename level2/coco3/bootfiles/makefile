include ../port.mak

# Module directory
MD		= ../modules

DEPENDS		= ./makefile

KERNEL_1773	= $(MD)/rel_80 $(MD)/boot_1773_6ms $(MD)/krn
KERNEL_1773_50HZ	= $(MD)/rel_80_50hz $(MD)/boot_1773_6ms $(MD)/krn
KERNEL_DW	= $(MD)/rel_80 $(MD)/boot_dw $(MD)/krn
KERNEL_ARDUINO	= $(MD)/rel_80 $(MD)/boot_dw_arduino $(MD)/krn
KERNEL_BECKER	= $(MD)/rel_80 $(MD)/boot_dw_becker $(MD)/krn
KERNEL_RS232PAK	= $(MD)/rel_80 $(MD)/boot_dw_rs232pak $(MD)/krn
KERNEL_COCOLINK	= $(MD)/rel_80 $(MD)/boot_dw_cocolink $(MD)/krn
KERNEL_DIRECTMODEMPAK	= $(MD)/rel_80 $(MD)/boot_dw_directmodempak $(MD)/krn
KERNEL_COCOSDC	= $(MD)/rel_80 $(MD)/boot_sdc $(MD)/krn
KERNEL_IDE	= $(MD)/rel_80 $(MD)/boot_ide $(MD)/krn
KERNEL_DIDE	= $(MD)/rel_80 $(MD)/boot_dide $(MD)/krn
# these not used yet:
KERNEL_RAMPAK	= $(MD)/rel_80 $(MD)/boot_rampak $(MD)/krn
KERNEL_KENTON	= $(MD)/rel_80 $(MD)/boot_kenton $(MD)/krn
KERNEL_TC3	= $(MD)/rel_80 $(MD)/boot_tc3 $(MD)/krn

FLOPPY_40D = $(MD)/rb1773.dr $(MD)/d0_40d.dd $(MD)/d1_40d.dd $(MD)/d2_40d.dd
FLOPPY_80D = $(MD)/rb1773.dr $(MD)/d0_80d.dd $(MD)/d1_80d.dd $(MD)/d2_80d.dd

VTIO_COGRF_40 = $(MD)/vtio.dr \
		$(MD)/keydrv_cc3.sb $(MD)/joydrv_joy.sb $(MD)/snddrv_cc3.sb \
		$(MD)/cogrf.io \
		$(MD)/term_win40.dt \
		$(MD)/w.dw $(MD)/w1.dw $(MD)/w2.dw $(MD)/w3.dw $(MD)/w4.dw \
		$(MD)/w5.dw $(MD)/w6.dw $(MD)/w7.dw
VTIO_COGRF_80 = $(MD)/vtio.dr \
		$(MD)/keydrv_cc3.sb $(MD)/joydrv_joy.sb $(MD)/snddrv_cc3.sb \
		$(MD)/cogrf.io \
		$(MD)/term_win80.dt \
		$(MD)/w.dw $(MD)/w1.dw $(MD)/w2.dw $(MD)/w3.dw $(MD)/w4.dw \
		$(MD)/w5.dw $(MD)/w6.dw $(MD)/w7.dw
VTIO_COWIN_40 = $(MD)/vtio.dr \
		$(MD)/keydrv_cc3.sb $(MD)/joydrv_joy.sb $(MD)/snddrv_cc3.sb \
		$(MD)/cowin.io \
		$(MD)/term_win40.dt \
		$(MD)/w.dw $(MD)/w1.dw $(MD)/w2.dw $(MD)/w3.dw $(MD)/w4.dw \
		$(MD)/w5.dw $(MD)/w6.dw $(MD)/w7.dw
VTIO_COWIN_80 = $(MD)/vtio.dr \
		$(MD)/keydrv_cc3.sb $(MD)/joydrv_joy.sb $(MD)/snddrv_cc3.sb \
		$(MD)/cowin.io \
		$(MD)/term_win80.dt \
		$(MD)/w.dw $(MD)/w1.dw $(MD)/w2.dw $(MD)/w3.dw $(MD)/w4.dw \
		$(MD)/w5.dw $(MD)/w6.dw $(MD)/w7.dw
RBDW       = $(MD)/rbdw.dr $(MD)/dwio.sb \
		$(MD)/x1.dd $(MD)/x2.dd $(MD)/x3.dd
RBCOCOSDC  = $(MD)/rbsuper.dr $(MD)/llcocosdc.dr \
		$(MD)/sd0_cocosdc.dd $(MD)/sd1_cocosdc.dd
RBDWARDUINO = $(MD)/rbdw.dr $(MD)/dwio_arduino.sb \
		$(MD)/x1.dd $(MD)/x2.dd $(MD)/x3.dd
RBDWBECKER = $(MD)/rbdw.dr $(MD)/dwio_becker.sb \
		$(MD)/x1.dd $(MD)/x2.dd $(MD)/x3.dd
RBDWRS232PAK = $(MD)/rbdw.dr $(MD)/dwio_rs232pak.sb \
		$(MD)/x1.dd $(MD)/x2.dd $(MD)/x3.dd
RBDWCOCOLINK = $(MD)/rbdw.dr $(MD)/dwio_cocolink.sb \
		$(MD)/x1.dd $(MD)/x2.dd $(MD)/x3.dd
RBDWDIRECTMODEMPAK = $(MD)/rbdw.dr $(MD)/dwio_directmodempak.sb \
		$(MD)/x1.dd $(MD)/x2.dd $(MD)/x3.dd
RBCOCO3FPGA = $(MD)/rbsuper.dr $(MD)/llcoco3fpga.dr \
		$(MD)/sd1_coco3fpga.dd $(MD)/ramd_coco3fpga.dr \
		$(MD)/r0_ramd_coco3fpga.dd

SCDWV_NET  = $(MD)/n_scdwv.dd $(MD)/n1_scdwv.dd $(MD)/n2_scdwv.dd \
		$(MD)/n3_scdwv.dd $(MD)/n4_scdwv.dd $(MD)/midi_scdwv.dd
SCDWV_WIN  = $(MD)/z1_scdwv.dd $(MD)/z2_scdwv.dd
SCDWP     = $(MD)/scdwp.dr $(MD)/p_scdwp.dd
PIPE       = $(MD)/pipeman.mn $(MD)/piper.dr $(MD)/pipe.dd
CLOCK50HZ  = $(MD)/clock_50hz $(MD)/clock2_soft
CLOCK60HZ  = $(MD)/clock_60hz $(MD)/clock2_soft
CLOCK60HZDW = $(MD)/clock_60hz $(MD)/clock2_dw
CLOCK60HZCC3FPGA = $(MD)/clock_60hz $(MD)/clock2_coco3fpga
EMUDSK = $(MD)/emudsk.dr $(MD)/h0_emudsk.dd \
		$(MD)/h1_emudsk.dd

# NitrOS-9 disk bootfile to allow booting from DriveWire server
# on a DE1 or Xilinx using Gary Becker's CoCo 3 FGPA
BOOTFILE_COCO3FPGA = $(MD)/krnp2 $(MD)/ioman $(MD)/init \
	$(MD)/rbf.mn \
	$(RBDWBECKER) \
	$(MD)/ddx0.dd \
	$(RBCOCO3FPGA) \
	$(MD)/sd0_coco3fpga.dd\
	$(MD)/scf.mn \
	$(VTIO_COWIN_80) \
	$(MD)/scdwv.dr \
	$(SCDWV_NET) \
	$(SCDWV_WIN) \
	$(SCDWP) \
	$(PIPE) \
	$(CLOCK60HZDW)

BOOTFILE_COCO3FPGA_SD = $(MD)/krnp2 $(MD)/ioman $(MD)/init \
	$(MD)/rbf.mn \
	$(RBDWBECKER) \
	$(MD)/x0.dd \
	$(RBCOCO3FPGA) \
	$(MD)/ddsd0_coco3fpga.dd\
	$(MD)/scf.mn \
	$(VTIO_COWIN_80) \
	$(MD)/scdwv.dr \
	$(SCDWV_NET) \
	$(SCDWV_WIN) \
	$(SCDWP) \
	$(PIPE) \
	$(CLOCK60HZDW)

BOOTFILE_COCO3FPGA_SD_RTC = $(MD)/krnp2 $(MD)/ioman $(MD)/init \
	$(MD)/rbf.mn \
	$(RBDWBECKER) \
	$(MD)/x0.dd \
	$(RBCOCO3FPGA) \
	$(MD)/ddsd0_coco3fpga.dd\
	$(MD)/scf.mn \
	$(VTIO_COWIN_80) \
	$(MD)/scdwv.dr \
	$(SCDWV_NET) \
	$(SCDWV_WIN) \
	$(SCDWP) \
	$(PIPE) \
	$(CLOCK60HZCC3FPGA)

BOOTFILE_COCO3FPGA_ROM = $(MD)/krnp2 $(MD)/ioman $(MD)/init \
	$(MD)/rbf.mn \
	$(RBDWBECKER) \
	$(MD)/x0.dd \
	$(RBCOCO3FPGA) \
	$(MD)/ddsd0_coco3fpga.dd\
	$(MD)/scf.mn \
	$(VTIO_COWIN_80) \
	$(MD)/scdwv.dr \
	$(SCDWV_NET) \
	$(SCDWV_WIN) \
	$(SCDWP) \
	$(PIPE) \
	$(CLOCK60HZ)

BOOTFILE_COCO3FPGA_ROM_DW = $(MD)/krnp2 $(MD)/ioman $(MD)/init \
	$(MD)/rbf.mn \
	$(RBDWBECKER) \
	$(MD)/x0.dd \
	$(RBCOCO3FPGA) \
	$(MD)/ddsd0_coco3fpga.dd\
	$(MD)/scf.mn \
	$(VTIO_COWIN_80) \
	$(MD)/scdwv.dr \
	$(SCDWV_NET) \
	$(SCDWV_WIN) \
	$(SCDWP) \
	$(PIPE) \
	$(CLOCK60HZDW)

BOOTFILE_COCO3FPGA_ROM_RTC = $(MD)/krnp2 $(MD)/ioman $(MD)/init \
	$(MD)/rbf.mn \
	$(RBDWBECKER) \
	$(MD)/x0.dd \
	$(RBCOCO3FPGA) \
	$(MD)/ddsd0_coco3fpga.dd\
	$(MD)/scf.mn \
	$(VTIO_COWIN_80) \
	$(MD)/scdwv.dr \
	$(SCDWV_NET) \
	$(SCDWV_WIN) \
	$(SCDWP) \
	$(PIPE) \
	$(CLOCK60HZCC3FPGA)

BOOTFILE_BECKER	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(RBDWBECKER) \
		$(MD)/ddx0.dd \
		$(FLOPPY_40D) \
		$(MD)/scf.mn \
		$(VTIO_COGRF_80) \
		$(MD)/scdwv.dr \
		$(SCDWV_NET) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZDW)

BOOTFILE_RS232PAK	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(RBDWRS232PAK) \
		$(MD)/ddx0.dd \
		$(FLOPPY_40D) \
		$(MD)/scf.mn \
		$(VTIO_COGRF_80) \
		$(MD)/scdwv.dr \
		$(SCDWV_NET) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZDW)

BOOTFILE_COCOLINK	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(RBDWCOCOLINK) \
		$(MD)/ddx0.dd \
		$(FLOPPY_40D) \
		$(MD)/scf.mn \
		$(VTIO_COGRF_80) \
		$(MD)/scdwv.dr \
		$(SCDWV_NET) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZDW)

BOOTFILE_DIRECTMODEMPAK	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(RBDWDIRECTMODEMPAK) \
		$(MD)/ddx0.dd \
		$(FLOPPY_40D) \
		$(MD)/scf.mn \
		$(VTIO_COGRF_80) \
		$(MD)/scdwv.dr \
		$(SCDWV_NET) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZDW)

# NitrOS-9 disk bootfile to allow booting from DriveWire server
# on an Arduino and CoCoPort
BOOTFILE_ARDUINO	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(RBDWARDUINO) \
                $(MD)/ddx0.dd \
		$(FLOPPY_40D) \
		$(MD)/scf.mn \
		$(VTIO_COGRF_80) \
		$(MD)/scdwv.dr \
		$(SCDWV_NET) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZ)

# NitrOS-9 disk bootfile to allow booting from DriveWire 3 server
BOOTFILE_DW	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(RBDW) \
		$(MD)/ddx0.dd \
		$(FLOPPY_40D) \
		$(MD)/scf.mn \
		$(VTIO_COGRF_80) \
		$(MD)/scdwv.dr \
		$(SCDWV_NET) \
		$(SCDWV_WIN) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZDW)
#		$(MD)/scdwv.dr \
#		$(MD)/n_scdwv.dd $(MD)/n1_scdwv.dd $(MD)/n2_scdwv.dd \
#		$(MD)/n3_scdwv.dd $(MD)/n4_scdwv.dd $(MD)/n5_scdwv.dd \
#		$(MD)/n6_scdwv.dd $(MD)/n7_scdwv.dd $(MD)/n8_scdwv.dd \
#		$(MD)/n9_scdwv.dd $(MD)/n10_scdwv.dd $(MD)/n11_scdwv.dd \
#		$(MD)/n12_scdwv.dd $(MD)/n13_scdwv.dd $(MD)/midi_scdwv.dd \

# NitrOS-9 disk bootfile to allow booting from DriveWire 3 server
# Headless mode
BOOTFILE_DW_HEADLESS	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(RBDW) \
		$(MD)/ddx0.dd \
		$(FLOPPY_40D) \
		$(MD)/scf.mn \
		$(MD)/scdwv.dr \
		$(MD)/term_scdwv.dt \
		$(SCDWV_NET) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZDW)

# NitrOS-9 disk bootfile to allow booting from DriveWire 3 server
# Headless mode Becker Port
BOOTFILE_BECKER_HEADLESS	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(RBDWBECKER) \
		$(MD)/ddx0.dd \
		$(FLOPPY_40D) \
		$(MD)/scf.mn \
		$(MD)/scdwv.dr \
		$(MD)/term_scdwv.dt \
		$(SCDWV_NET) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZDW)

# NitrOS-9 disk bootfile to allow booting from DriveWire 3 server
# Headless mode CoCoLINK RS232 Pak Port
BOOTFILE_COCOLINK_HEADLESS	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(RBDWCOCOLINK) \
		$(MD)/ddx0.dd \
		$(FLOPPY_40D) \
		$(MD)/scf.mn \
		$(MD)/scdwv.dr \
		$(MD)/term_scdwv.dt \
		$(SCDWV_NET) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZDW)

# NitrOS-9 disk bootfile to allow booting from DriveWire 3 server
# Headless mode Deluxe RS232 Pak Port
BOOTFILE_RS232PAK_HEADLESS	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(RBDWRS232PAK) \
		$(MD)/ddx0.dd \
		$(FLOPPY_40D) \
		$(MD)/scf.mn \
		$(MD)/scdwv.dr \
		$(MD)/term_scdwv.dt \
		$(SCDWV_NET) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZDW)

# NitrOS-9 disk bootfile to allow booting from DriveWire 3 server
# Headless mode DirectModem Pak Port
BOOTFILE_DIRECTMODEMPAK_HEADLESS	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(RBDWDIRECTMODEMPAK) \
		$(MD)/ddx0.dd \
		$(FLOPPY_40D) \
		$(MD)/scf.mn \
		$(MD)/scdwv.dr \
		$(MD)/term_scdwv.dt \
		$(SCDWV_NET) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZDW)

# NitrOS-9 disk bootfile to allow booting from DriveWire 3 server
# Headless mode Arduino
BOOTFILE_ARDUINO_HEADLESS	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(RBDWARDUINO) \
		$(MD)/ddx0.dd \
		$(FLOPPY_40D) \
		$(MD)/scf.mn \
		$(MD)/scdwv.dr \
		$(MD)/term_scdwv.dt \
		$(SCDWV_NET) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZDW)

# NitrOS-9 disk bootfile to allow booting from CoCo SD
BOOTFILE_COCOSDC	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(RBCOCOSDC) \
        $(MD)/ddsd0_cocosdc.dd \
        $(FLOPPY_40D) \
		$(MD)/scf.mn \
		$(VTIO_COGRF_80) \
		$(PIPE) \
		$(CLOCK60HZ)

BOOTFILE_IDE	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(MD)/rbsuper.dr $(MD)/llide.dr \
		$(MD)/ddi0_ide.dd \
		$(FLOPPY_40D) \
		$(MD)/scf.mn \
		$(VTIO_COGRF_80) \
		$(PIPE) \
		$(CLOCK60HZ)

# NitrOS-9 disk bootfile to allow booting from WD1773 disk controller
BOOTFILE_40D	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
                $(FLOPPY_40D) \
                $(MD)/ddd0_40d.dd \
		$(MD)/scf.mn \
		$(VTIO_COGRF_80) \
		$(PIPE) \
		$(CLOCK60HZ)

BOOTFILE_80D	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
                $(FLOPPY_80D) \
                $(MD)/ddd0_80d.dd \
		$(MD)/scf.mn \
		$(VTIO_COGRF_80) \
		$(PIPE) \
		$(CLOCK60HZ)

BOOTFILE_40D_50HZ	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
                $(FLOPPY_40D) \
                $(MD)/ddd0_40d.dd \
		$(MD)/scf.mn \
		$(VTIO_COGRF_80) \
		$(PIPE) \
		$(CLOCK50HZ)

BOOTFILE_80D_50HZ	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
                $(FLOPPY_80D) \
                $(MD)/ddd0_80d.dd \
		$(MD)/scf.mn \
		$(VTIO_COGRF_80) \
		$(PIPE) \
		$(CLOCK50HZ)

BOOTFILE_EMUDSK	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(FLOPPY_80D) \
		$(MD)/ddd0_80d.dd \
		$(MD)/scf.mn \
		$(VTIO_COGRF_80) \
		$(PIPE) \
		$(CLOCK60HZ) \
		$(EMUDSK)

BOOTFILES	= bootfile_40d bootfile_40d_50hz bootfile_80d \
		bootfile_80d_50hz bootfile_dw bootfile_dw_headless \
		bootfile_becker bootfile_arduino bootfile_becker_headless \
		bootfile_arduino_headless bootfile_cocosdc bootfile_ide \
		bootfile_coco3fpga bootfile_coco3fpga_sd bootfile_coco3fpga_sd_rtc \
		bootfile_coco3fpga_rom bootfile_coco3fpga_rom_dw bootfile_coco3fpga_rom_rtc \
		bootfile_rs232pak bootfile_directmodempak bootfile_rs232pak_headless \
		bootfile_directmodempak_headless bootfile_cocolink_headless bootfile_cocolink \
		bootfile_emudsk

KERNELS		= kernel_1773 kernel_1773_50hz kernel_dw kernel_becker \
		kernel_arduino kernel_cocosdc kernel_ide kernel_dide \
		kernel_rs232pak kernel_directmodempak kernel_cocolink

ALLOBJS		= $(BOOTFILES) $(KERNELS)

all:	$(ALLOBJS)

# Bootfiles
bootfile_coco3fpga: $(BOOTFILE_COCO3FPGA) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COCO3FPGA)>$@

bootfile_coco3fpga_sd: $(BOOTFILE_COCO3FPGA_SD) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COCO3FPGA_SD)>$@

bootfile_coco3fpga_sd_rtc: $(BOOTFILE_COCO3FPGA_SD_RTC) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COCO3FPGA_SD_RTC)>$@

bootfile_coco3fpga_rom: $(BOOTFILE_COCO3FPGA_ROM) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COCO3FPGA_ROM)>$@

bootfile_coco3fpga_rom_dw: $(BOOTFILE_COCO3FPGA_ROM_DW) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COCO3FPGA_ROM_DW)>$@

bootfile_coco3fpga_rom_rtc: $(BOOTFILE_COCO3FPGA_ROM_RTC) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COCO3FPGA_ROM_RTC)>$@

bootfile_becker: $(BOOTFILE_BECKER) $(DEPENDS)
	$(MERGE) $(BOOTFILE_BECKER)>$@

bootfile_rs232pak: $(BOOTFILE_RS232PAK) $(DEPENDS)
	$(MERGE) $(BOOTFILE_RS232PAK)>$@

bootfile_cocolink: $(BOOTFILE_COCOLINK) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COCOLINK)>$@

bootfile_directmodempak: $(BOOTFILE_DIRECTMODEMPAK) $(DEPENDS)
	$(MERGE) $(BOOTFILE_DIRECTMODEMPAK)>$@

bootfile_arduino: $(BOOTFILE_ARDUINO) $(DEPENDS)
	$(MERGE) $(BOOTFILE_ARDUINO)>$@

bootfile_40d: $(BOOTFILE_40D) $(DEPENDS)
	$(MERGE) $(BOOTFILE_40D)>$@

bootfile_40d_50hz: $(BOOTFILE_40D_50HZ) $(DEPENDS)
	$(MERGE) $(BOOTFILE_40D_50HZ)>$@

bootfile_80d: $(BOOTFILE_80D) $(DEPENDS)
	$(MERGE) $(BOOTFILE_80D)>$@

bootfile_80d_50hz: $(BOOTFILE_80D_50HZ) $(DEPENDS)
	$(MERGE) $(BOOTFILE_80D_50HZ)>$@

bootfile_dw: $(BOOTFILE_DW) $(DEPENDS)
	$(MERGE) $(BOOTFILE_DW)>$@

bootfile_dw_headless: $(BOOTFILE_DW_HEADLESS) $(DEPENDS)
	$(MERGE) $(BOOTFILE_DW_HEADLESS)>$@

bootfile_becker_headless: $(BOOTFILE_BECKER_HEADLESS) $(DEPENDS)
	$(MERGE) $(BOOTFILE_BECKER_HEADLESS)>$@

bootfile_rs232pak_headless: $(BOOTFILE_RS232PAK_HEADLESS) $(DEPENDS)
	$(MERGE) $(BOOTFILE_RS232PAK_HEADLESS)>$@

bootfile_cocolink_headless: $(BOOTFILE_COCOLINK_HEADLESS) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COCOLINK_HEADLESS)>$@

bootfile_directmodempak_headless: $(BOOTFILE_DIRECTMODEMPAK_HEADLESS) $(DEPENDS)
	$(MERGE) $(BOOTFILE_DIRECTMODEMPAK_HEADLESS)>$@

bootfile_arduino_headless: $(BOOTFILE_ARDUINO_HEADLESS) $(DEPENDS)
	$(MERGE) $(BOOTFILE_ARDUINO_HEADLESS)>$@

bootfile_cocosdc: $(BOOTFILE_COCOSDC) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COCOSDC)>$@

bootfile_ide: $(BOOTFILE_IDE) $(DEPENDS)
	$(MERGE) $(BOOTFILE_IDE)>$@

bootfile_emudsk: $(BOOTFILE_EMUDSK) $(DEPENDS)
	$(MERGE) $(BOOTFILE_EMUDSK)>$@

# Kernels
kernel_becker: $(KERNEL_BECKER) $(DEPENDS)
	$(MERGE) $(KERNEL_BECKER)>$@

kernel_rs232pak: $(KERNEL_RS232PAK) $(DEPENDS)
	$(MERGE) $(KERNEL_RS232PAK)>$@

kernel_cocolink: $(KERNEL_COCOLINK) $(DEPENDS)
	$(MERGE) $(KERNEL_COCOLINK)>$@

kernel_directmodempak: $(KERNEL_DIRECTMODEMPAK) $(DEPENDS)
	$(MERGE) $(KERNEL_DIRECTMODEMPAK)>$@

kernel_arduino: $(KERNEL_ARDUINO) $(DEPENDS)
	$(MERGE) $(KERNEL_ARDUINO)>$@

kernel_1773: $(KERNEL_1773) $(DEPENDS)
	$(MERGE) $(KERNEL_1773)>$@

kernel_1773_50hz: $(KERNEL_1773_50HZ) $(DEPENDS)
	$(MERGE) $(KERNEL_1773_50HZ)>$@

kernel_dw: $(KERNEL_DW) $(DEPENDS)
	$(MERGE) $(KERNEL_DW)>$@

kernel_cocosdc: $(KERNEL_COCOSDC) $(DEPENDS)
	$(MERGE) $(KERNEL_COCOSDC)>$@

kernel_ide: $(KERNEL_IDE) $(DEPENDS)
	$(MERGE) $(KERNEL_IDE)>$@

kernel_dide: $(KERNEL_DIDE) $(DEPENDS)
	$(MERGE) $(KERNEL_DIDE)>$@

clean:
	$(RM) $(ALLOBJS)

