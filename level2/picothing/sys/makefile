include ../port.mak

vpath %.hp $(LEVEL2)/sys:$(LEVEL1)/sys

DEPENDS     = ./makefile

L1TXTFILES  = errmsg inetd.conf password
L2TXTFILES  = $(LEVEL2)/sys/motd
BINFILES    =

HELPFILES   = asm.hp attr.hp backup.hp binex.hp build.hp chd.hp \
              chx.hp cmp.hp copy.hp date.hp \
              dcheck.hp debug.hp ded.hp deiniz.hp del.hp deldir.hp devs.hp \
              dir.hp dirsort.hp disasm.hp display.hp dmem.hp dmode.hp dsave.hp \
              dump.hp echo.hp edit.hp error.hp ex.hp exbin.hp format.hp free.hp \
              help.hp ident.hp iniz.hp irqs.hp link.hp \
              list.hp load.hp login.hp makdir.hp \
              mdir.hp megaread.hp merge.hp mfree.hp minted.hp mmap.hp \
              modpatch.hp padrom.hp park.hp pmap.hp proc.hp procs.hp \
              prompt.hp pwd.hp pxd.hp \
              rename.hp save.hp setime.hp \
              setpr.hp shell.hp sleep.hp smap.hp tee.hp tmode.hp touch.hp \
              tsmon.hp unlink.hp verify.hp xmode.hp

HELPMSG     = helpmsg

TEXTFILES   = $(L2TXTFILES) $(HELPMSG) $(L1TXTFILES)
ALLOBJS     = $(TEXTFILES) $(BINFILES)

all:    $(ALLOBJS) $(DEPENDS)

$(HELPMSG): $(HELPFILES)
	$(MERGE) $^ > $@

$(L1TXTFILES):
	$(SOFTLINK) -f $(LEVEL1)/sys/$@

clean:
	$(RM) $(HELPMSG) $(L1TXTFILES)

showbinobjs:
	@$(ECHO) $(BINFILES)

showtextobjs:
	@$(ECHO) $(TEXTFILES)

showobjs:
	@$(ECHO) $(ALLOBJS)
