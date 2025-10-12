include ../../../../rules.mak

DEPENDS		= ./makefile

CMDS_TCAP	= tcap/adduser tcap/chown tcap/cnvrtmail tcap/dotilde tcap/expire tcap/fileserv tcap/fixtext tcap/login tcap/mailx tcap/postnews tcap/readnews tcap/rmail tcap/rnews tcap/subscribe tcap/unsubscribe tcap/uucico tcap/uuclean tcap/uucp tcap/uudecode tcap/uuencode tcap/uulog tcap/uuname tcap/uuxqt tcap/whoami
CMDS_WIN	= win/adduser win/chown win/cnvrtmail win/dotilde win/expire win/fileserv win/fixtext win/login win/mailx win/postnews win/readnews win/rmail win/rnews win/subscribe win/unsubscribe win/uucico win/uuclean win/uucp win/uudecode win/uuencode win/uulog win/uuname win/uuxqt win/whoami
CMDS		= uumon

ALLOBJS		= $(CMDS_TCAP) $(CMDS_WIN) $(CMDS)

all:	$(ALLOBJS)

clean:
	$(RM) $(ALLOBJS) *.list *.map

showtcapobjs:
	@$(ECHO) $(CMDS_TCAP)

showwinobjs:
	@$(ECHO) $(CMDS_WIN)

showobjs:
	@$(ECHO) $(CMDS)

identify:
	$(IDENT_SHORT) $(ALLOBJS)
