include ../../../rules.mak

DCC	= dcc
DCCFLAGS = -q -o -s -dm6809 -dOS9 -dSHELLPLUS -dNEWCLIB -dDCC_LW
SRCDIR	= src

DISK68	= uucpbb21_6809.dsk
DISK63	= uucpbb21_6309.dsk
CONFIG	= Devices FileServ.help Systems bin.list Dialers Parameters active distributions
DOCS	= adduser.man aliases.doc chown.man cnvrtmail.man fileserv.man fixtext.man login.man mailrc.doc mailx.man parameters.doc postnews.man profile.doc readnews.man rmail.man rnews.man signature.doc subscribe.man uucico.man uuclean.man uucp.man uucpbb.doc uulog.man uuxqt.man whoami.man

DSKS	= $(DISK68) $(DISK63)

SRC_CMDS = uucico mailx dotilde rmail rnews uuxqt readnews postnews expire \
	subscribe unsubscribe uulog uuclean uuencode uudecode uucp chown \
	whoami fixtext adduser fileserv uuname login cnvrtmail
SRC_TARGETS = $(addprefix $(SRCDIR)/,$(SRC_CMDS))
SRC_OBJECTS = $(sort $(foreach cmd,$(SRC_CMDS),$(addprefix $(SRCDIR)/,$($(cmd)_OBJS))))

uucico_OBJS = uucico.o getopt.o getparam.o findmach.o chksched.o findline.o \
	findent.o finddev.o connect.o openport.o openuucp.o findwork.o \
	filexfer.o gproto.o dumpcode.o filemove.o fixperms.o closeuucp.o \
	parse.o docmd.o gtime.o mfgets.o strdetab.o getenv.o strdup.o \
	getdirs.o strstr.o pwent.o
mailx_OBJS = mail.o recvmail.o sendmail.o getuser.o docmd.o parse.o fixline.o \
	filemove.o maketemp.o getseq.o getval.o fixperms.o getparam.o \
	userparam.o t2test.o date822.o gtime.o doalias.o forkshell.o \
	strdup.o mfgets.o strdetab.o getenv.o termio.o nmload.o getdirs.o \
	pwent.o
dotilde_OBJS = dotilde.o docmd.o fixline.o parse.o forkshell.o getenv.o \
	mfgets.o strdetab.o strdup.o gtime.o filemove.o termio.o pwent.o
rmail_OBJS = rmail.o getline.o getuser.o validuser.o setuser.o parse.o \
	genseq.o findent.o getparam.o getval.o maketemp.o gtime.o fixperms.o \
	date822.o filemove.o doalias.o mfgets.o getenv.o strdup.o getdirs.o \
	termio.o docmd.o pwent.o
rnews_OBJS = rnews.o getline.o groups.o procbatch.o mbuf.o xatol.o getdirs.o \
	getparam.o parse.o strdup.o mfgets.o openarts.o makepath.o strupr.o \
	procart.o getopt.o fixref.o gtime.o log.o getenv.o
uuxqt_OBJS = uuxqt.o findxwork.o getline.o parse.o docmd.o gtime.o filemove.o \
	mfgets.o getopt.o strdetab.o strdup.o getdirs.o strupr.o nmload.o \
	getenv.o
readnews_OBJS = readnews.o getuser.o makepath.o parse.o filemove.o fixline.o \
	docmd.o newsutils.o getval.o getparam.o userparam.o gtime.o t2test.o \
	forkshell.o mfgets.o strupr.o strdetab.o getenv.o strdup.o getdirs.o \
	termio.o pwent.o
postnews_OBJS = postnews.o getuser.o maketemp.o getseq.o findent.o getsys.o \
	docmd.o fixline.o filemove.o genseq.o getparam.o userparam.o parse.o \
	t2test.o fixperms.o gtime.o date822.o mfgets.o strdetab.o getenv.o \
	strdup.o getdirs.o getopt.o termio.o nmload.o pwent.o
expire_OBJS = expire.o expgroup.o makepath.o parse.o newsutils.o gtime.o \
	filemove.o strupr.o mfgets.o strdetab.o strdup.o getdirs.o getopt.o \
	getenv.o
subscribe_OBJS = subscribe.o filemove.o mfgets.o getenv.o pwent.o strdup.o
unsubscribe_OBJS = unsubscribe.o filemove.o mfgets.o getenv.o pwent.o strdup.o
uulog_OBJS = uulog.o getopt.o getenv.o strdup.o mfgets.o
uuclean_OBJS = uuclean.o getparam.o parse.o docmd.o maketemp.o mfgets.o \
	gtime.o filemove.o date822.o setuser.o getval.o getenv.o strdup.o \
	getdirs.o getopt.o pwent.o
uucp_OBJS = uucp.o getuser.o getparam.o parse.o genseq.o fixperms.o maketemp.o \
	docmd.o mfgets.o gtime.o getenv.o strdup.o getdirs.o pwent.o
uudecode_OBJS = uudecode.o
uuencode_OBJS = uuencode.o
chown_OBJS = chown.o pwent.o
whoami_OBJS = whoami.o pwent.o
fixtext_OBJS = fixtext.o fixline.o strdetab.o mfgets.o
adduser_OBJS = adduser.o strdetab.o getenv.o strdup.o termio.o mfgets.o pwent.o
fileserv_OBJS = fileserv.o getparam.o getdirs.o strdup.o mfgets.o getval.o \
	maketemp.o filemove.o docmd.o gtime.o date822.o getseq.o fixperms.o \
	parse.o getenv.o
uuname_OBJS = uuname.o parse.o mfgets.o
login_OBJS = login.o parse.o fixperms.o pwent.o getenv.o strdup.o
cnvrtmail_OBJS = cnvrtmail.o docmd.o fixperms.o gtime.o strupr.o getval.o \
	mfgets.o filemove.o getenv.o parse.o pwent.o strdup.o

# Make all components
all: $(SRC_TARGETS)

banner:
	@$(ECHO) "**************************************************"
	@$(ECHO) "*                                                *"
	@$(ECHO) "*                   UUCPbb v2.1                  *"
	@$(ECHO) "*                                                *"
	@$(ECHO) "**************************************************"

# Clean all components
clean:	dskclean
	$(RM) $(SRC_TARGETS) $(SRCDIR)/*.o $(SRCDIR)/*.list $(SRCDIR)/*.map $(SRCDIR)/c.errors $(SRCDIR)/cstr.* $(SRCDIR)/ctmp.*
	$(RM) c.errors *.list *.map cstr.* ctmp.*

dsk: $(DSKS)

$(DISK68): banner all
	$(RM) $@
	$(OS9FORMAT) -l10000 $@ -q -n"UUCPbb v2.1 6809"
	$(MAKDIR) $@,LOG
	$(MAKDIR) $@,UUCP
	$(MAKDIR) $@,UUCP/CMDS_WIN
	$(MAKDIR) $@,UUCP/CMDS_TCAP
	$(MAKDIR) $@,UUCP/DOC
	$(MAKDIR) $@,UUCP/SPOOL
	$(MAKDIR) $@,UUCP/SPOOL/MAIL
	$(MAKDIR) $@,UUCP/SPOOL/NEWS
	$(MAKDIR) $@,UUCP/SPOOL/UUCP
	$(MAKDIR) $@,UUCP/SPOOL/UUCP/REDHAT
	$(MAKDIR) $@,UUCP/SPOOL/UUCPPUBLIC
	$(MAKDIR) $@,UUCP/SPOOL/REDHAT
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,SYS/UUCP
	$(CD) sample_config; $(CPL) $(CONFIG) ../$@,SYS/UUCP
	$(CPL) profile $@,SYS
	$(CD) $(SRCDIR); $(OS9COPY) $(SRC_CMDS) ../$@,UUCP/CMDS_TCAP
	$(OS9ATTR_EXEC) $(foreach file,$(SRC_CMDS),$@,UUCP/CMDS_TCAP/$(file))
	$(CD) $(SRCDIR); $(OS9COPY) $(SRC_CMDS) ../$@,UUCP/CMDS_WIN
	$(OS9ATTR_EXEC) $(foreach file,$(SRC_CMDS),$@,UUCP/CMDS_WIN/$(file))
	$(CD) doc; $(CPL) $(DOCS) ../$@,UUCP/DOC
	$(CPL) copying readme.first $@,UUCP

$(DISK63): banner all
	$(RM) $@
	$(OS9FORMAT) -l10000 $@ -q -n"UUCPbb v2.1 6309"
	$(MAKDIR) $@,LOG
	$(MAKDIR) $@,UUCP
	$(MAKDIR) $@,UUCP/DOC
	$(MAKDIR) $@,UUCP/CMDS_WIN
	$(MAKDIR) $@,UUCP/CMDS_TCAP
	$(MAKDIR) $@,UUCP/SPOOL
	$(MAKDIR) $@,UUCP/SPOOL/MAIL
	$(MAKDIR) $@,UUCP/SPOOL/NEWS
	$(MAKDIR) $@,UUCP/SPOOL/UUCP
	$(MAKDIR) $@,UUCP/SPOOL/UUCP/REDHAT
	$(MAKDIR) $@,UUCP/SPOOL/UUCPPUBLIC
	$(MAKDIR) $@,UUCP/SPOOL/REDHAT
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,SYS/UUCP
	$(CD) sample_config; $(CPL) $(CONFIG) ../$@,SYS/UUCP
	$(CPL) profile $@,SYS
	$(CD) $(SRCDIR); $(OS9COPY) $(SRC_CMDS) ../$@,UUCP/CMDS_TCAP
	$(OS9ATTR_EXEC) $(foreach file,$(SRC_CMDS),$@,UUCP/CMDS_TCAP/$(file))
	$(CD) $(SRCDIR); $(OS9COPY) $(SRC_CMDS) ../$@,UUCP/CMDS_WIN
	$(OS9ATTR_EXEC) $(foreach file,$(SRC_CMDS),$@,UUCP/CMDS_WIN/$(file))
	$(CD) doc; $(CPL) $(DOCS) ../$@,UUCP/DOC
	$(CPL) copying readme.first $@,UUCP

dskcopy: dsk
	$(CP) $(DSKS) $(DSKDIR)

dskclean:
	$(RM) $(DSKS)

info:
	@$(ECHO) "*** UUCPbb 2.1 ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)

.SECONDEXPANSION:
$(SRC_TARGETS): $$(addprefix $$(SRCDIR)/,$$($$(@F)_OBJS))
	cd $(SRCDIR) && $(DCC) $(DCCFLAGS) -f=$(@F) $(notdir $^)
	@$(RM) $(SRCDIR)/c.errors

$(SRC_OBJECTS): $(SRCDIR)/%.o: $(SRCDIR)/%.c
	cd $(SRCDIR) && $(DCC) $(DCCFLAGS) -r -f=$(@F) $(<F)
