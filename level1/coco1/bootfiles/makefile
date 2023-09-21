include ../port.mak

# Module directory
MD		= ../modules
# Commands directory
CMDSDIR		= ../cmds

DEPENDS		= ./makefile

KERNEL_1773	= $(MD)/rel $(MD)/krn $(MD)/krnp2 $(MD)/init \
		$(MD)/boot_1773_6ms

ifdef DW_BAUD38400
KERNEL_DW	= $(MD)/rel $(MD)/krn $(MD)/krnp2 $(MD)/init \
		$(MD)/boot_dw_38400
else
KERNEL_DW	= $(MD)/rel $(MD)/krn $(MD)/krnp2 $(MD)/init \
		$(MD)/boot_dw
endif

KERNEL_BECKER	= $(MD)/rel $(MD)/krn $(MD)/krnp2 $(MD)/init \
		$(MD)/boot_dw_becker

KERNEL_RS232PAK	= $(MD)/rel $(MD)/krn $(MD)/krnp2 $(MD)/init \
		$(MD)/boot_dw_rs232pak

KERNEL_COCOLINK	= $(MD)/rel $(MD)/krn $(MD)/krnp2 $(MD)/init \
		$(MD)/boot_dw_cocolink

KERNEL_DIRECTMODEMPAK	= $(MD)/rel $(MD)/krn $(MD)/krnp2 $(MD)/init \
		$(MD)/boot_dw_directmodempak

KERNEL_ARDUINO	= $(MD)/rel $(MD)/krn $(MD)/krnp2 $(MD)/init \
		$(MD)/boot_dw_arduino

KERNEL_COCOSDC	= $(MD)/rel $(MD)/krn $(MD)/krnp2 $(MD)/init \
		$(MD)/boot_sdc

IDE		= $(3PD)/ide
SCSI		= $(3PD)/scsisys

FLOPPY_40D	= $(MD)/rb1773.dr $(MD)/d0_40d.dd $(MD)/d1_40d.dd $(MD)/d2_40d.dd

FLOPPY_80D	= $(MD)/rb1773.dr $(MD)/d0_40d.dd $(MD)/d1_40d.dd $(MD)/d2_40d.dd

VTIO_COVDG	= $(MD)/vtio.dr $(MD)/covdg.io $(MD)/term_vdg.dt
VTIO_COVGA	= $(MD)/vtio_vga.dr $(MD)/covga.io $(MD)/term_vga.dt
VTIO_COHR	= $(MD)/vtio.dr $(MD)/cohr.io $(MD)/term_hr.dt
VTIO_CO80	= $(MD)/vtio.dr $(MD)/co80.io $(MD)/term_80.dt
VTIO_CO42	= $(MD)/vtio.dr $(MD)/co42.io $(MD)/term_42.dt
VTIO_COWPRS = $(MD)/vtio.dr $(MD)/cowprs.io $(MD)/term_wprs.dt

PIPE		= $(MD)/pipeman.mn $(MD)/piper.dr $(MD)/pipe.dd
CLOCK60HZ	= $(MD)/clock_60hz $(MD)/clock2_soft
CLOCK60HZDW	= $(MD)/clock_60hz $(MD)/clock2_dw
ifdef DW_BAUD38400
RBDW		= $(MD)/rbdw.dr $(MD)/dwio_38400.sb \
		$(MD)/x1.dd $(MD)/x2.dd $(MD)/x3.dd
else
RBDW		= $(MD)/rbdw.dr $(MD)/dwio.sb \
		$(MD)/x1.dd $(MD)/x2.dd $(MD)/x3.dd
endif
RBBECKER	= $(MD)/rbdw.dr $(MD)/dwio_becker.sb \
		$(MD)/x1.dd $(MD)/x2.dd $(MD)/x3.dd

RBRS232PAK	= $(MD)/rbdw.dr $(MD)/dwio_rs232pak.sb \
		$(MD)/x1.dd $(MD)/x2.dd $(MD)/x3.dd

RBCOCOLINK	= $(MD)/rbdw.dr $(MD)/dwio_cocolink.sb \
		$(MD)/x1.dd $(MD)/x2.dd $(MD)/x3.dd

RBDIRECTMODEMPAK	= $(MD)/rbdw.dr $(MD)/dwio_directmodempak.sb \
		$(MD)/x1.dd $(MD)/x2.dd $(MD)/x3.dd

RBARDUINO	= $(MD)/rbdw.dr $(MD)/dwio_arduino.sb \
		$(MD)/x1.dd $(MD)/x2.dd $(MD)/x3.dd

RBCOCOSDC	= $(MD)/rbsuper.dr $(MD)/llcocosdc.dr \
		$(MD)/sd0_cocosdc.dd $(MD)/sd1_cocosdc.dd

SCDWV_NET  = $(MD)/n_scdwv.dd $(MD)/n1_scdwv.dd $(MD)/n2_scdwv.dd \
		$(MD)/n3_scdwv.dd $(MD)/n4_scdwv.dd $(MD)/n5_scdwv.dd \
		$(MD)/n6_scdwv.dd $(MD)/n7_scdwv.dd $(MD)/n8_scdwv.dd \
		$(MD)/n9_scdwv.dd $(MD)/n10_scdwv.dd $(MD)/n11_scdwv.dd \
		$(MD)/n12_scdwv.dd $(MD)/n13_scdwv.dd $(MD)/midi_scdwv.dd
SCDWV_WIN  = $(MD)/z1_scdwv.dd $(MD)/z2_scdwv.dd $(MD)/z3_scdwv.dd \
		$(MD)/z4_scdwv.dd $(MD)/z5_scdwv.dd $(MD)/z6_scdwv.dd \
		$(MD)/z7_scdwv.dd
SCDWP     = $(MD)/scdwp.dr $(MD)/p_scdwp.dd

EMUDSK = $(MD)/emudsk.dr $(MD)/h0_emudsk.dd $(MD)/h1_emudsk.dd

BOOTFILE_COVDG	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(FLOPPY_40D) \
		$(MD)/ddd0_40d.dd \
		$(MD)/scf.mn \
		$(VTIO_COVDG) \
		$(MD)/scbbp.dr $(MD)/p_scbbp.dd \
		$(MD)/scbbt.dr $(MD)/t1_scbbt.dd \
		$(PIPE) \
		$(CLOCK60HZ) \
		$(MD)/sysgo_dd

BOOTFILE_COVGA	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(FLOPPY_40D) \
		$(MD)/ddd0_40d.dd \
		$(MD)/scf.mn \
		$(VTIO_COVGA) \
		$(MD)/scbbp.dr $(MD)/p_scbbp.dd \
		$(MD)/scbbt.dr $(MD)/t1_scbbt.dd \
		$(PIPE) \
		$(CLOCK60HZ) \
		$(MD)/sysgo_dd

BOOTFILE_COHR	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(FLOPPY_40D) \
		$(MD)/ddd0_40d.dd \
		$(MD)/scf.mn \
		$(VTIO_COHR) \
		$(MD)/scbbp.dr $(MD)/p_scbbp.dd \
		$(MD)/scbbt.dr $(MD)/t1_scbbt.dd \
		$(PIPE) \
		$(CLOCK60HZ) \
		$(MD)/sysgo_dd

BOOTFILE_CO42	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(FLOPPY_40D) \
		$(MD)/ddd0_40d.dd \
		$(MD)/scf.mn \
		$(VTIO_CO42) \
		$(MD)/scbbp.dr $(MD)/p_scbbp.dd \
		$(MD)/scbbt.dr $(MD)/t1_scbbt.dd \
		$(PIPE) \
		$(CLOCK60HZ) \
		$(MD)/sysgo_dd

BOOTFILE_CO80	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(FLOPPY_40D) \
		$(MD)/ddd0_40d.dd \
		$(MD)/scf.mn \
		$(VTIO_CO80) \
		$(MD)/scbbp.dr $(MD)/p_scbbp.dd \
		$(MD)/scbbt.dr $(MD)/t1_scbbt.dd \
		$(PIPE) \
		$(CLOCK60HZ) \
		$(MD)/sysgo_dd

BOOTFILE_COWPRS	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(FLOPPY_40D) \
		$(MD)/ddd0_40d.dd \
		$(MD)/scf.mn \
		$(VTIO_COWPRS) \
		$(MD)/scbbp.dr $(MD)/p_scbbp.dd \
		$(MD)/scbbt.dr $(MD)/t1_scbbt.dd \
		$(PIPE) \
		$(CLOCK60HZ) \
		$(MD)/sysgo_dd

BOOTFILE_DW_HEADLESS	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBDW) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(MD)/scdwv.dr \
		$(MD)/term_scdwv.dt \
		$(SCDWV_NET) \
		$(SCDWV_WIN) \
		$(SCDWP) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd

BOOTFILE_BECKER_HEADLESS	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBBECKER) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(MD)/scdwv.dr \
		$(MD)/term_scdwv.dt \
		$(SCDWV_NET) \
		$(SCDWV_WIN) \
		$(SCDWP) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd

BOOTFILE_RS232PAK_HEADLESS	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBRS232PAK) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(MD)/scdwv.dr \
		$(MD)/term_scdwv.dt \
		$(SCDWV_NET) \
		$(SCDWV_WIN) \
		$(SCDWP) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd

BOOTFILE_COCOLINK_HEADLESS	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBCOCOLINK) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(MD)/scdwv.dr \
		$(MD)/term_scdwv.dt \
		$(SCDWV_NET) \
		$(SCDWV_WIN) \
		$(SCDWP) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd

BOOTFILE_DIRECTMODEMPAK_HEADLESS	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBDIRECTMODEMPAK) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(MD)/scdwv.dr \
		$(MD)/term_scdwv.dt \
		$(SCDWV_NET) \
		$(SCDWV_WIN) \
		$(SCDWP) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd

BOOTFILE_ARDUINO_HEADLESS	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBARDUINO) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(MD)/scdwv.dr \
		$(MD)/term_scdwv.dt \
		$(SCDWV_NET) \
		$(SCDWV_WIN) \
		$(SCDWP) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd

BOOTFILE_COVDG_DW	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(FLOPPY_40D) \
		$(RBDW) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COVDG) \
		$(MD)/scdwv.dr \
		$(SCDWV_NET) \
		$(SCDWV_WIN) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd

BOOTFILE_COVGA_DW	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(FLOPPY_40D) \
		$(RBDW) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COVGA) \
		$(MD)/scdwv.dr \
		$(SCDWV_NET) \
		$(SCDWV_WIN) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd

BOOTFILE_COVDG_DW_GAME	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBDW) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COVDG) \
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd \
		$(CMDSDIR)/shell_21

BOOTFILE_COVGA_DW_GAME	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBDW) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COVGA) \
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd \
		$(CMDSDIR)/shell_21

BOOTFILE_COVDG_BECKER	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBBECKER) \
		$(FLOPPY_40D) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COVDG) \
		$(MD)/scdwv.dr \
		$(SCDWV_NET) \
		$(SCDWV_WIN) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd

BOOTFILE_COVGA_BECKER	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBBECKER) \
		$(FLOPPY_40D) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COVGA) \
		$(MD)/scdwv.dr \
		$(SCDWV_NET) \
		$(SCDWV_WIN) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd

BOOTFILE_COVDG_RS232PAK	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBRS232PAK) \
		$(FLOPPY_40D) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COVDG) \
		$(MD)/scdwv.dr \
		$(SCDWV_NET) \
		$(SCDWV_WIN) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd

BOOTFILE_COVGA_RS232PAK	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBRS232PAK) \
		$(FLOPPY_40D) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COVGA) \
		$(MD)/scdwv.dr \
		$(SCDWV_NET) \
		$(SCDWV_WIN) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd

BOOTFILE_COVDG_COCOLINK	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBCOCOLINK) \
		$(FLOPPY_40D) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COVDG) \
		$(MD)/scdwv.dr \
		$(SCDWV_NET) \
		$(SCDWV_WIN) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd

BOOTFILE_COVGA_COCOLINK	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBCOCOLINK) \
		$(FLOPPY_40D) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COVGA) \
		$(MD)/scdwv.dr \
		$(SCDWV_NET) \
		$(SCDWV_WIN) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd

BOOTFILE_COVDG_DIRECTMODEMPAK	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBDIRECTMODEMPAK) \
		$(FLOPPY_40D) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COVDG) \
		$(MD)/scdwv.dr \
		$(SCDWV_NET) \
		$(SCDWV_WIN) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd

BOOTFILE_COVGA_DIRECTMODEMPAK	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBDIRECTMODEMPAK) \
		$(FLOPPY_40D) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COVGA) \
		$(MD)/scdwv.dr \
		$(SCDWV_NET) \
		$(SCDWV_WIN) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd

BOOTFILE_COVDG_BECKER_GAME	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBBECKER) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COVDG) \
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd \
		$(CMDSDIR)/shell_21

BOOTFILE_COVDG_RS232PAK_GAME	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBRS232PAK) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COVDG) \
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd \
		$(CMDSDIR)/shell_21

BOOTFILE_COVGA_RS232PAK_GAME	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBRS232PAK) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COVGA) \
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd \
		$(CMDSDIR)/shell_21

BOOTFILE_COVDG_COCOLINK_GAME	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBCOCOLINK) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COVDG) \
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd \
		$(CMDSDIR)/shell_21

BOOTFILE_COVGA_COCOLINK_GAME	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBCOCOLINK) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COVGA) \
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd \
		$(CMDSDIR)/shell_21

BOOTFILE_COVDG_DIRECTMODEMPAK_GAME	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBDIRECTMODEMPAK) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COVDG) \
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd \
		$(CMDSDIR)/shell_21

BOOTFILE_COVGA_DIRECTMODEMPAK_GAME	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBDIRECTMODEMPAK) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COVGA) \
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd \
		$(CMDSDIR)/shell_21

BOOTFILE_COVDG_ARDUINO	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(FLOPPY_40D) \
		$(RBARDUINO) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COVDG) \
		$(MD)/scdwv.dr \
		$(SCDWV_NET) \
		$(SCDWV_WIN) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd

BOOTFILE_COVGA_ARDUINO	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(FLOPPY_40D) \
		$(RBARDUINO) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COVGA) \
		$(MD)/scdwv.dr \
		$(SCDWV_NET) \
		$(SCDWV_WIN) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd

BOOTFILE_COVDG_ARDUINO_GAME	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBARDUINO) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COVDG) \
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd \
		$(CMDSDIR)/shell_21

BOOTFILE_COVGA_ARDUINO_GAME	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBARDUINO) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COVGA) \
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd \
		$(CMDSDIR)/shell_21

BOOTFILE_COVDG_DS80	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(FLOPPY_80D) \
		$(MD)/ddd0_80d.dd \
		$(MD)/scf.mn \
		$(VTIO_COVDG) \
		$(MD)/scbbp.dr $(MD)/p_scbbp.dd \
		$(MD)/scbbt.dr $(MD)/t1_scbbt.dd \
		$(PIPE) \
		$(CLOCK60HZ) \
		$(MD)/sysgo_dd

BOOTFILE_COVGA_DS80	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(FLOPPY_80D) \
		$(MD)/ddd0_80d.dd \
		$(MD)/scf.mn \
		$(VTIO_COVGA) \
		$(MD)/scbbp.dr $(MD)/p_scbbp.dd \
		$(MD)/scbbt.dr $(MD)/t1_scbbt.dd \
		$(PIPE) \
		$(CLOCK60HZ) \
		$(MD)/sysgo_dd

BOOTFILE_COVDG_COCOSDC	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBCOCOSDC) \
		$(MD)/ddsd0_cocosdc.dd \
		$(FLOPPY_40D) \
		$(MD)/scf.mn \
		$(VTIO_COVDG) \
		$(MD)/scbbp.dr $(MD)/p_scbbp.dd \
		$(MD)/scbbt.dr $(MD)/t1_scbbt.dd \
		$(PIPE) \
		$(CLOCK60HZ) \
		$(MD)/sysgo_dd

BOOTFILE_COVGA_COCOSDC	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBCOCOSDC) \
		$(MD)/ddsd0_cocosdc.dd \
		$(FLOPPY_40D) \
		$(MD)/scf.mn \
		$(VTIO_COVGA) \
		$(MD)/scbbp.dr $(MD)/p_scbbp.dd \
		$(MD)/scbbt.dr $(MD)/t1_scbbt.dd \
		$(PIPE) \
		$(CLOCK60HZ) \
		$(MD)/sysgo_dd

BOOTFILE_CO42_COCOSDC	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBCOCOSDC) \
		$(MD)/ddsd0_cocosdc.dd \
		$(FLOPPY_40D) \
		$(MD)/scf.mn \
		$(VTIO_CO42) \
		$(MD)/scbbp.dr $(MD)/p_scbbp.dd \
		$(MD)/scbbt.dr $(MD)/t1_scbbt.dd \
		$(PIPE) \
		$(CLOCK60HZ) \
		$(MD)/sysgo_dd

BOOTFILE_COVDG_COCOSDC_GAME	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBCOCOSDC) \
		$(MD)/ddsd0_cocosdc.dd \
		$(MD)/scf.mn \
		$(VTIO_COVDG) \
		$(PIPE) \
		$(CLOCK60HZ) \
		$(MD)/sysgo_dd \
		$(CMDSDIR)/shell_21

BOOTFILE_COVGA_COCOSDC_GAME	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(RBCOCOSDC) \
		$(MD)/ddsd0_cocosdc.dd \
		$(MD)/scf.mn \
		$(VTIO_COVGA) \
		$(PIPE) \
		$(CLOCK60HZ) \
		$(MD)/sysgo_dd \
		$(CMDSDIR)/shell_21

BOOTFILE_COHR_DW	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(FLOPPY_40D) \
		$(RBDW) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COHR) \
		$(MD)/scdwv.dr \
		$(SCDWV_NET) \
		$(SCDWP)\
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd

BOOTFILE_CO42_DW	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(FLOPPY_40D) \
		$(RBDW) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_CO42) \
		$(MD)/scdwv.dr \
		$(SCDWV_NET) \
		$(SCDWP)\
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd

BOOTFILE_COHR_BECKER	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(FLOPPY_40D) \
		$(RBBECKER) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COHR) \
		$(MD)/scdwv.dr \
		$(SCDWV_NET) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd

BOOTFILE_COHR_RS232PAK	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(FLOPPY_40D) \
		$(RBRS232PAK) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COHR) \
		$(MD)/scdwv.dr \
		$(SCDWV_NET) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd

BOOTFILE_COHR_COCOLINK	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(FLOPPY_40D) \
		$(RBCOCOLINK) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COHR) \
		$(MD)/scdwv.dr \
		$(SCDWV_NET) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd

BOOTFILE_COHR_DIRECTMODEMPAK	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(FLOPPY_40D) \
		$(RBDIRECTMODEMPAK) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COHR) \
		$(MD)/scdwv.dr \
		$(SCDWV_NET) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd

BOOTFILE_COHR_ARDUINO	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(FLOPPY_40D) \
		$(RBARDUINO) \
		$(MD)/ddx0.dd \
		$(MD)/scf.mn \
		$(VTIO_COHR) \
		$(MD)/scdwv.dr \
		$(SCDWV_NET) \
		$(SCDWP) \
		$(PIPE) \
		$(CLOCK60HZDW) \
		$(MD)/sysgo_dd

BOOTFILE_COHR_DS80	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(FLOPPY_80D) \
		$(MD)/ddd0_80d.dd \
		$(MD)/scf.mn \
		$(VTIO_COHR) \
		$(MD)/scbbp.dr $(MD)/p_scbbp.dd \
		$(MD)/scbbt.dr $(MD)/t1_scbbt.dd \
		$(PIPE) \
		$(CLOCK60HZ) \
		$(MD)/sysgo_dd

BOOTFILE_CO42_DS80	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(FLOPPY_80D) \
		$(MD)/ddd0_80d.dd \
		$(MD)/scf.mn \
		$(VTIO_CO42) \
		$(MD)/scbbp.dr $(MD)/p_scbbp.dd \
		$(MD)/scbbt.dr $(MD)/t1_scbbt.dd \
		$(PIPE) \
		$(CLOCK60HZ) \
		$(MD)/sysgo_dd

BOOTFILE_EMUDSK	= $(MD)/ioman \
		$(MD)/rbf.mn \
		$(FLOPPY_40D) \
		$(MD)/ddd0_40d.dd \
		$(MD)/scf.mn \
		$(VTIO_COVDG) \
		$(MD)/scbbp.dr $(MD)/p_scbbp.dd \
		$(MD)/scbbt.dr $(MD)/t1_scbbt.dd \
		$(PIPE) \
		$(CLOCK60HZ) \
		$(MD)/sysgo_dd \
		$(EMUDSK)

BOOTFILES	= bootfile_covdg bootfile_cohr bootfile_co42 bootfile_cowprs \
		bootfile_dw_headless bootfile_covdg_becker bootfile_covdg_rs232pak \
		bootfile_covdg_cocolink bootfile_covdg_directmodempak \
		bootfile_covdg_becker_game bootfile_covdg_rs232pak_game bootfile_covdg_cocolink_game \
		bootfile_covdg_directmodempak_game bootfile_covdg_dw_game \
		bootfile_covdg_cocosdc bootfile_co42_cocosdc bootfile_covdg_cocosdc_game \
		bootfile_covdg_dw bootfile_cohr_dw bootfile_co42_dw \
		bootfile_covdg_ds80 bootfile_cohr_ds80 bootfile_co42_ds80 \
		bootfile_cohr_becker bootfile_becker_headless \
		bootfile_cohr_rs232pak bootfile_rs232pak_headless \
		bootfile_cohr_cocolink bootfile_cocolink_headless \
		bootfile_cohr_directmodempak bootfile_directmodempak_headless \
		bootfile_covdg_arduino bootfile_arduino_headless \
		bootfile_cohr_arduino bootfile_covdg_arduino_game \
		bootfile_covga_ds80 bootfile_covga_cocosdc bootfile_covga_dw bootfile_covga_rs232pak \
		bootfile_covga_directmodempak bootfile_covga_cocolink bootfile_covga_dw_game \
		bootfile_covga_cocosdc_game bootfile_covga_rs232pak_game bootfile_covga_directmodempak_game \
		bootfile_covga_cocolink_game bootfile_covga bootfile_covga_arduino bootfile_emudsk

KERNELS		= kernel_1773 kernel_dw kernel_becker kernel_arduino kernel_cocosdc \
			kernel_rs232pak kernel_directmodempak kernel_cocolink

ALLOBJS		= $(BOOTFILES) $(KERNELS)

all:	$(ALLOBJS)

bootfile_covdg: $(BOOTFILE_COVDG) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVDG)>$@

bootfile_covga: $(BOOTFILE_COVGA) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVGA)>$@

bootfile_cohr: $(BOOTFILE_COHR) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COHR)>$@

bootfile_co42: $(BOOTFILE_CO42) $(DEPENDS)
	$(MERGE) $(BOOTFILE_CO42)>$@

bootfile_co80: $(BOOTFILE_CO80) $(DEPENDS)
	$(MERGE) $(BOOTFILE_CO80)>$@

bootfile_cowprs: $(BOOTFILE_COWPRS) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COWPRS)>$@

bootfile_covdg_ds80: $(BOOTFILE_COVDG_DS80) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVDG_DS80)>$@

bootfile_covga_ds80: $(BOOTFILE_COVGA_DS80) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVGA_DS80)>$@

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

bootfile_covdg_dw: $(BOOTFILE_COVDG_DW) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVDG_DW)>$@

bootfile_covga_dw: $(BOOTFILE_COVGA_DW) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVGA_DW)>$@

bootfile_covdg_dw_game: $(BOOTFILE_COVDG_DW_GAME) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVDG_DW_GAME)>$@

bootfile_covga_dw_game: $(BOOTFILE_COVGA_DW_GAME) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVGA_DW_GAME)>$@

bootfile_covdg_becker: $(BOOTFILE_COVDG_BECKER) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVDG_BECKER)>$@

bootfile_covga_becker: $(BOOTFILE_COVGA_BECKER) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVGA_BECKER)>$@

bootfile_covdg_rs232pak: $(BOOTFILE_COVDG_RS232PAK) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVDG_RS232PAK)>$@

bootfile_covga_rs232pak: $(BOOTFILE_COVGA_RS232PAK) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVGA_RS232PAK)>$@

bootfile_covdg_cocolink: $(BOOTFILE_COVDG_COCOLINK) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVDG_COCOLINK)>$@

bootfile_covga_cocolink: $(BOOTFILE_COVGA_COCOLINK) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVGA_COCOLINK)>$@

bootfile_covdg_directmodempak: $(BOOTFILE_COVDG_DIRECTMODEMPAK) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVDG_DIRECTMODEMPAK)>$@

bootfile_covga_directmodempak: $(BOOTFILE_COVGA_DIRECTMODEMPAK) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVGA_DIRECTMODEMPAK)>$@

bootfile_covdg_becker_game: $(BOOTFILE_COVDG_BECKER_GAME) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVDG_BECKER_GAME)>$@

bootfile_covga_becker_game: $(BOOTFILE_COVGA_BECKER_GAME) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVGA_BECKER_GAME)>$@

bootfile_covdg_rs232pak_game: $(BOOTFILE_COVDG_RS232PAK_GAME) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVDG_RS232PAK_GAME)>$@

bootfile_covga_rs232pak_game: $(BOOTFILE_COVGA_RS232PAK_GAME) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVGA_RS232PAK_GAME)>$@

bootfile_covdg_cocolink_game: $(BOOTFILE_COVDG_COCOLINK_GAME) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVDG_COCOLINK_GAME)>$@

bootfile_covga_cocolink_game: $(BOOTFILE_COVGA_COCOLINK_GAME) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVGA_COCOLINK_GAME)>$@

bootfile_covdg_directmodempak_game: $(BOOTFILE_COVDG_DIRECTMODEMPAK_GAME) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVDG_DIRECTMODEMPAK_GAME)>$@

bootfile_covga_directmodempak_game: $(BOOTFILE_COVGA_DIRECTMODEMPAK_GAME) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVGA_DIRECTMODEMPAK_GAME)>$@

bootfile_covdg_arduino: $(BOOTFILE_COVDG_ARDUINO) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVDG_ARDUINO)>$@

bootfile_covga_arduino: $(BOOTFILE_COVGA_ARDUINO) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVGA_ARDUINO)>$@

bootfile_covdg_arduino_game: $(BOOTFILE_COVDG_ARDUINO_GAME) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVDG_ARDUINO_GAME)>$@

bootfile_covga_arduino_game: $(BOOTFILE_COVGA_ARDUINO_GAME) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVGA_ARDUINO_GAME)>$@

bootfile_covdg_cocosdc: $(BOOTFILE_COVDG_COCOSDC) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVDG_COCOSDC)>$@

bootfile_covga_cocosdc: $(BOOTFILE_COVGA_COCOSDC) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVGA_COCOSDC)>$@

bootfile_co42_cocosdc: $(BOOTFILE_CO42_COCOSDC) $(DEPENDS)
	$(MERGE) $(BOOTFILE_CO42_COCOSDC)>$@

bootfile_covdg_cocosdc_game: $(BOOTFILE_COVDG_COCOSDC_GAME) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVDG_COCOSDC_GAME)>$@

bootfile_covga_cocosdc_game: $(BOOTFILE_COVGA_COCOSDC_GAME) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COVGA_COCOSDC_GAME)>$@

bootfile_cohr_ds80: $(BOOTFILE_COHR_DS80) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COHR_DS80)>$@

bootfile_co42_ds80: $(BOOTFILE_CO42_DS80) $(DEPENDS)
	$(MERGE) $(BOOTFILE_CO42_DS80)>$@

bootfile_cohr_dw: $(BOOTFILE_COHR_DW) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COHR_DW)>$@

bootfile_co42_dw: $(BOOTFILE_CO42_DW) $(DEPENDS)
	$(MERGE) $(BOOTFILE_CO42_DW)>$@

bootfile_cohr_becker: $(BOOTFILE_COHR_BECKER) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COHR_BECKER)>$@

bootfile_cohr_rs232pak: $(BOOTFILE_COHR_RS232PAK) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COHR_RS232PAK)>$@

bootfile_cohr_cocolink: $(BOOTFILE_COHR_COCOLINK) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COHR_COCOLINK)>$@

bootfile_cohr_directmodempak: $(BOOTFILE_COHR_DIRECTMODEMPAK) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COHR_DIRECTMODEMPAK)>$@

bootfile_cohr_arduino: $(BOOTFILE_COHR_ARDUINO) $(DEPENDS)
	$(MERGE) $(BOOTFILE_COHR_ARDUINO)>$@

bootfile_emudsk: $(BOOTFILE_EMUDSK) $(DEPENDS)
	$(MERGE) $(BOOTFILE_EMUDSK)>$@

# WD1773 Kernel
kernel_1773: $(KERNEL_1773) $(DEPENDS)
	$(MERGE) $(KERNEL_1773)>$@
	$(PADROM) 4608 $@

# DriveWire 3 Kernel
kernel_dw: $(KERNEL_DW) $(DEPENDS)
	$(MERGE) $(KERNEL_DW)>$@
	$(PADROM) 4608 $@

kernel_becker: $(KERNEL_BECKER) $(DEPENDS)
	$(MERGE) $(KERNEL_BECKER)>$@
	$(PADROM) 4608 $@

kernel_cocolink: $(KERNEL_COCOLINK) $(DEPENDS)
	$(MERGE) $(KERNEL_COCOLINK)>$@
	$(PADROM) 4608 $@

kernel_rs232pak: $(KERNEL_RS232PAK) $(DEPENDS)
	$(MERGE) $(KERNEL_RS232PAK)>$@
	$(PADROM) 4608 $@

kernel_directmodempak: $(KERNEL_DIRECTMODEMPAK) $(DEPENDS)
	$(MERGE) $(KERNEL_DIRECTMODEMPAK)>$@
	$(PADROM) 4608 $@

kernel_arduino: $(KERNEL_ARDUINO) $(DEPENDS)
	$(MERGE) $(KERNEL_ARDUINO)>$@
	$(PADROM) 4608 $@

kernel_cocosdc: $(KERNEL_COCOSDC) $(DEPENDS)
	$(MERGE) $(KERNEL_COCOSDC)>$@
	$(PADROM) 4608 $@

clean:
	$(RM) $(ALLOBJS)
