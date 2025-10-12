include $(NITROS9DIR)/rules.mak

vpath %.asm ../cmds

AFLAGS += -I.

DSK	= OS9L2BBS.dsk
BBS	= ../bbs

PROBCMDS = AnsiEd AnsiFilt BBS.chat New_user Quikterm pause suser

BBSFILES = $(BBS)/BBS.userstats $(BBS)/bbs.alias $(BBS)/bbs.cmds $(BBS)/bbs.cmds_2 $(BBS)/bbs.cmds_3 $(BBS)/bbs.cmds_h \
	$(BBS)/bbs.cmds_sl $(BBS)/bbs.cmds_sys $(BBS)/bbs.cmds_uld $(BBS)/bbs.cmds_uld_2 $(BBS)/bbs.cmds_uld_3 \
	$(BBS)/bbs.cmds_uld_h $(BBS)/bbs.menu_32 $(BBS)/bbs.menu_80 $(BBS)/bbs.menu_am $(BBS)/bbs.menu_sl \
	$(BBS)/bbs.menu_sys $(BBS)/bbs.menu_uld $(BBS)/bbs.users $(BBS)/eotd $(BBS)/modem.set $(BBS)/motd $(BBS)/new_user_form \
	$(BBS)/new_user_message $(BBS)/packall $(BBS)/packall_3 $(BBS)/runbbs $(BBS)/runbbs_new $(BBS)/sysop

CMDS	= Ansicode Answer At \
	BBS.archive BBS.build BBS.conf BBS.conf.who BBS.convert \
	BBS.create BBS.delete BBS.download BBS.form BBS.forward BBS.list \
	BBS.mail.check BBS.mail.delete BBS.mail.post BBS.mail.read \
	BBS.mail.readD BBS.new BBS.pack BBS.page BBS.post BBS.read BBS.reply \
	BBS.scan BBS.search BBS.stat BBS.upload BBS.validate BBS.who \
	Conf.dat \
	DLD.add DLD.list DLD.read DLD.search DLD.unvalidate DLD.validate \
	Dloada Dloadx Dloadxc Dloady \
	Login Makdir Menu Monitor New_user Prompt T1mon Tsmon \
	Uloada Uloadx Uloadxc Uloady ViewBBS

all: $(CMDS)

dsk: $(DSK)

$(DSK): $(CMDS)
	$(OS9FORMAT) -q $@ -n"OS-9 L2 BBS for 6809"
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(CMDS) $@,CMDS
	$(MAKDIR) $@,BBS
	$(OS9COPY) $(BBSFILES) $@,BBS

dskcopy: $(DSK)
	$(CP) $(DSK) $(DSKDIR)

clean: dskclean
	$(RM) $(CMDS) *.list *.map

dskclean:
	$(RM) $(DSK)

info:
	@$(ECHO) "*** OS-9 L2 BBS for 6809 ***"
	@$(ECHO) $(DSK)
