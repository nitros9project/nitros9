include ../port.mak

vpath %.hp $(LEVEL2)/sys:$(LEVEL1)/sys
vpath %.asm $(LEVEL2)/sys

DEPENDS		= ./makefile

L1TXTFILES	= errmsg password
L2SYSGOTEXTFILES = sysgo.cfg
BINFILES	= stdfonts stdpats_2 stdpats_4 stdpats_16 stdptrs \
		ibmedcfont isolatin1font
HELPFILES	= asm.hp attr.hp backup.hp binex.hp build.hp chd.hp \
		chx.hp cmp.hp cobbler.hp config.hp copy.hp cputype.hp date.hp \
		dcheck.hp debug.hp ded.hp deiniz.hp del.hp deldir.hp devs.hp \
		dir.hp dirsort.hp disasm.hp display.hp dmode.hp dsave.hp dump.hp echo.hp \
		edit.hp error.hp ex.hp exbin.hp format.hp free.hp gfx.hp \
		help.hp ident.hp iniz.hp inkey.hp irqs.hp kill.hp link.hp \
		list.hp load.hp login.hp makdir.hp \
		mdir.hp megaread.hp merge.hp minted.hp mpi.hp mfree.hp os9gen.hp \
		padrom.hp park.hp procs.hp prompt.hp pwd.hp pxd.hp \
		rename.hp save.hp setime.hp \
		setpr.hp shell.hp sleep.hp tee.hp tmode.hp touch.hp tsmon.hp \
		tuneport.hp unlink.hp verify.hp xmode.hp

# These are Level 2/3 only
HELPFILES	+= dmem.hp gfx2.hp grfdrv.hp basic09.hp runb.hp \
		wcreate.hp make.hp mmap.hp modpatch.hp montype.hp \
		pmap.hp proc.hp reboot.hp smap.hp scred.hp

# Help files for code that is not in the NitrOS9 tree
HELPFILES	+= make.hp maketerm.hp rdump.hp rlink.hp rma.hp scred.hp

# These are mc09 only
HELPFILES	+= mc09rtc.hp

HELPMSG		= helpmsg

TEXTFILES	= $(L2TXTFILES) $(HELPMSG) $(L1TXTFILES)
SYSGOTEXTFILES = $(L2SYSGOTEXTFILES)
ALLOBJS = $(TEXTFILES) $(SYSGOTEXTFILES) $(BINFILES) motd inetd.conf

all:	$(ALLOBJS) $(DEPENDS)

$(HELPMSG): $(HELPFILES)
	$(MERGE) $^ > $@

$(L1TXTFILES):
	$(SOFTLINK) -f $(LEVEL1)/sys/$@

$(L2SYSGOTEXTFILES):
	$(SOFTLINK) -f $(LEVEL2)/sys/$@

motd:
	@$(ECHO) > $@
	@$(ECHO) "Welcome to NitrOS-9 Level $(LEVEL) $(NITROS9VER) !" >> $@
	@$(ECHO) >> $@

inetd.conf:     $(LEVEL1)/sys/inetd.conf
	@sed -e 's/%TELNET_PORT%/$(TELNET_PORT)/' -e 's/%HTTPD_PORT%/$(HTTPD_PORT)/' $^ > $@

clean:
	$(RM) $(ALLOBJS)

showbinobjs:
	@$(ECHO) $(BINFILES)

showtextobjs:
	@$(ECHO) $(TEXTFILES) motd inetd.conf

showsysgotextobjs:
	@$(ECHO) $(SYSGOTEXTFILES)

showobjs:
	@$(ECHO) $(ALLOBJS)
