include $(NITROS9DIR)/rules.mak

# makefile for OS-9 UUCP package, UUCPbb v2.1 (OS-9/6809)
#
# This script requires Shell+ v2.1 (or later) and CC v2.5.0
#
# NOTE: This package must be compiled by the SUPERUSER (user 0) in order
#       for it to work properly.

# Temporary directory.  This device must have at least 120K of free space
TMP     =

# Default device
DD     = /DD

# Uncomment the termlib.l below to add termcap support.
# NOTE: termlib.l is necessary if using termcap, while sys.l is not currently
#       necessary for compiling

LIB     = #-l=/dd/lib/termlib.l \
          #-l=/dd/lib/cmath63.l -l=/dd/lib/string63.l \
          #-l=$(DD)/lib/sys.l 

LIB     = -L../../../../lib -lkreiderc -lnos96809l2

# REPLACE m6809 below with m6309 if you are using the 6309 microprocessor

CPU     = m6809

# COMMENT OUT SHELLPLUS if you do NOT use Shell+ v2.1 or later

USHELL  = SHELLPLUS

# UNCOMMENT -dTERMCAP to add termcap support.
# UNCOMMENT -dBSDISH also to add termcap support based on Brad Spencer's
#              port of BSD termcap (available on chestnut.cs.wisc.edu)
# UNCOMMENT -dDASHOK if kernel is patched to allow the '-' as part of file
#              and directory names.
# REMOVE    -dNEWCLIB if you are NOT using Carl Kreider clib.l replacement
#              1990 or later.
#
# ==IMPORTANT== do NOT remove the '\' at the end of the CFLAGS line.

CFLAGS  = -I../../../../lib/kreiderclib/defs --os9 -D$(CPU) -DOS9 -D$(USHELL) -DNEWCLIB  \
          #-DTERMCAP  #-DBSDISH  #-DDASHOK
OBJS	= uucico mailx dotilde rmail rnews uuxqt readnews postnews expire \
     subscribe unsubscribe uulog uuclean uuencode uudecode uucp chown \
     whoami fixtext adduser fileserv uuname login cnvrtmail #uusetup

# These modules will not be compiled now by this makefile: 
#         uusetup

all: $(OBJS)
#	attr uucico e w r pe -pw pr
#	attr mailx  e w r pe -pw pr
#	attr dotilde e w r pe -pw pr
#	attr rmail e w r -pe -pw -pr
#	attr rnews e w r -pe -pw -pr
#	attr uuxqt e w r -pe -pw -pr
#	attr readnews e w r pe -pw pr
#	attr postnews e w r pe -pw pr
#	attr expire e w r -pe -pw -pr
#	attr subscribe e w r pe -pw pr
#	attr unsubscribe e w r pe -pw pr
#	attr uulog e w r pe -pw pr
#	attr uuclean e w r -pe -pw -pr
#	attr uuencode e w r pe -pw pr
#	attr uudecode e w r pe -pw pr
#	attr uucp e w r pe -pw pr
#	attr chown e w r pe -pw pr
#	attr whoami e w r pe -pw pr
#	attr fixtext e w r pe -pw pr
#	attr adduser e w r -pe -pw -pr
#	attr fileserv e w r pe -pw pr
#	attr uuname e w r pe -pw pr
#	attr login e w r pe -pw pr
#	attr cnvrtmail e w r -pe -pw -pr
#	attr uusetup e w r -pe -pw -pr

_UUCICO = uucico.o getopt.o getparam.o findmach.o chksched.o findline.o \
        findent.o finddev.o connect.o openport.o openuucp.o findwork.o \
        filexfer.o gproto.o dumpcode.o filemove.o fixperms.o closeuucp.o \
        parse.o docmd.o gtime.o mfgets.o strdetab.o getenv.o strdup.o \
        getdirs.o strstr.o pwent.o

uucico: $(_UUCICO)
	$(CC) $(CFLAGS) $(_UUCICO) $(LIB)

_MAILX = mail.o recvmail.o sendmail.o getuser.o docmd.o parse.o fixline.o \
        filemove.o maketemp.o getseq.o getval.o fixperms.o getparam.o \
        userparam.o t2test.o date822.o gtime.o doalias.o forkshell.o \
        strdup.o mfgets.o strdetab.o getenv.o termio.o nmload.o getdirs.o \
        pwent.o

mailx: $(_MAILX)
	$(CC) -f=mailx $(CFLAGS) $(_MAILX) $(LIB) -m=3k

_DOTILDE = dotilde.o docmd.o fixline.o parse.o forkshell.o getenv.o \
        mfgets.o strdetab.o strdup.o gtime.o filemove.o termio.o pwent.o

dotilde: $(_DOTILDE)
	$(CC) -f=dotilde $(CFLAGS) $(_DOTILDE) $(LIB) -m=2k

_RMAIL = rmail.o getline.o getuser.o validuser.o setuser.o parse.o genseq.o \
        findent.o getparam.o getval.o maketemp.o gtime.o fixperms.o \
        date822.o filemove.o doalias.o mfgets.o getenv.o strdup.o getdirs.o \
        termio.o docmd.o pwent.o

rmail: $(_RMAIL)
	$(CC) -f=rmail $(CFLAGS) $(_RMAIL) $(LIB) -m=4k

_RNEWS = rnews.o getline.o groups.o procbatch.o mbuf.o xatol.o getdirs.o \
         getparam.o parse.o strdup.o mfgets.o openarts.o makepath.o strupr.o \
         procart.o getopt.o fixref.o gtime.o log.o getenv.o

rnews: $(_RNEWS)
	$(CC) -f=rnews $(CFLAGS) $(_RNEWS) $(LIB) -m=5k -e=21

_UUXQT = uuxqt.o findxwork.o getline.o parse.o docmd.o gtime.o filemove.o \
        mfgets.o getopt.o strdetab.o strdup.o getdirs.o strupr.o nmload.o \
        getenv.o

uuxqt: $(_UUXQT)
	$(CC) -f=uuxqt $(CFLAGS) $(_UUXQT) $(LIB) -m=3k

_READNEWS = readnews.o getuser.o makepath.o parse.o filemove.o fixline.o \
        docmd.o newsutils.o getval.o getparam.o userparam.o gtime.o \
        t2test.o forkshell.o mfgets.o strupr.o strdetab.o getenv.o strdup.o \
        getdirs.o termio.o pwent.o

readnews: $(_READNEWS)
	$(CC) -f=readnews $(CFLAGS) $(_READNEWS) $(LIB) -m=4k

_POSTNEWS = postnews.o getuser.o maketemp.o getseq.o findent.o \
        getsys.o docmd.o fixline.o filemove.o genseq.o getparam.o \
        userparam.o parse.o t2test.o fixperms.o gtime.o date822.o mfgets.o \
        strdetab.o getenv.o strdup.o getdirs.o getopt.o termio.o nmload.o \
        pwent.o

postnews: $(_POSTNEWS)
	$(CC) -f=postnews $(CFLAGS) $(_POSTNEWS) $(LIB) -m=4k

_EXPIRE = expire.o expgroup.o makepath.o parse.o newsutils.o gtime.o \
        filemove.o strupr.o mfgets.o strdetab.o strdup.o getdirs.o getopt.o \
        getenv.o

expire: $(_EXPIRE)
	$(CC) -f=expire $(CFLAGS) $(_EXPIRE) $(LIB) -m=2k

_SUBSCRIBE = subscribe.o filemove.o mfgets.o getenv.o pwent.o strdup.o

subscribe: $(_SUBSCRIBE)
	$(CC) -f=subscribe $(CFLAGS) $(_SUBSCRIBE) $(LIB) -m=1k

_UNSUBSCRIBE = unsubscribe.o filemove.o mfgets.o getenv.o pwent.o strdup.o

unsubscribe: $(_UNSUBSCRIBE)
	$(CC) -f=unsubscribe $(CFLAGS) $(_UNSUBSCRIBE) $(LIB) -m=1k

_UULOG = uulog.o getopt.o getenv.o strdup.o mfgets.o

uulog: $(_UULOG)
	$(CC) -f=uulog $(CFLAGS) $(_UULOG) $(LIB) -m=1k

_UUCLEAN = uuclean.o getparam.o parse.o docmd.o maketemp.o mfgets.o \
           gtime.o filemove.o date822.o setuser.o getval.o getenv.o \
           strdup.o getdirs.o getopt.o pwent.o

uuclean: $(_UUCLEAN)
	$(CC) -f=uuclean $(CFLAGS) $(_UUCLEAN) $(LIB) -m=4k

_UUSTAT = uustat.o

uustat: $(_UUSTAT)
	$(CC) -f=uustat $(CFLAGS) $(_UUSTAT) $(LIB) -m=1k

_UUCP = uucp.o getuser.o getparam.o parse.o genseq.o fixperms.o maketemp.o \
        docmd.o mfgets.o gtime.o getenv.o strdup.o getdirs.o pwent.o

uucp: $(_UUCP)
	$(CC) -f=uucp $(CFLAGS) $(_UUCP) $(LIB) -m=2k

_UUDECODE = uudecode.o

uudecode: $(_UUDECODE)
	$(CC) -f=uudecode $(CFLAGS) $(_UUDECODE) $(LIB) -m=1k

_UUENCODE = uuencode.o

uuencode: $(_UUENCODE)
	$(CC) -f=uuencode $(CFLAGS) $(_UUENCODE) $(LIB) -m=1k

_CHOWN = chown.o pwent.o

chown: $(_CHOWN)
	$(CC) -f=chown $(CFLAGS) $(_CHOWN) $(LIB)

_WHOAMI = whoami.o pwent.o

whoami: $(_WHOAMI)
	$(CC) -f=whoami $(CFLAGS) $(_WHOAMI) $(LIB) -m=1k

_FIXTEXT = fixtext.o fixline.o strdetab.o mfgets.o

fixtext: $(_FIXTEXT)
	$(CC) -f=fixtext $(CFLAGS) $(_FIXTEXT) $(LIB)

_CNVRTMAIL = cnvrtmail.o docmd.o fixperms.o gtime.o strupr.o getval.o \
             mfgets.o filemove.o getenv.o parse.o pwent.o strdup.o

cnvrtmail: $(_CNVRTMAIL)
	$(CC) -f=cnvrtmail $(CFLAGS) $(_CNVRTMAIL) $(LIB) -m=4k

_LOGIN = login.o parse.o fixperms.o pwent.o getenv.o strdup.o

login: $(_LOGIN)
	$(CC) -f=login $(CFLAGS) $(_LOGIN) $(LIB) -m=1k

_ADDUSER = adduser.o strdetab.o getenv.o strdup.o termio.o mfgets.o pwent.o

adduser: $(_ADDUSER)
	$(CC) -f=adduser $(CFLAGS) $(_ADDUSER) $(LIB) -m=1k

_UUSETUP = uusetup.o getdevices.o parse.o strupr.o mfgets.o termio.o

uusetup: $(_UUSETUP)
	$(CC) -f=uusetup $(CFLAGS) $(_UUSETUP) $(LIB) -m=1k

_FILESERV = fileserv.o getparam.o getdirs.o strdup.o mfgets.o getval.o \
    maketemp.o filemove.o docmd.o gtime.o date822.o getseq.o fixperms.o \
    parse.o getenv.o

fileserv: $(_FILESERV)
	$(CC) -f=fileserv $(CFLAGS) $(_FILESERV) $(LIB) -m=3k

_UUNAME = uuname.o parse.o mfgets.o

uuname: $(_UUNAME)
	$(CC) -f=uuname $(CFLAGS) $(_UUNAME) $(LIB)

clean:
	$(RM) *.o $(OBJS)
	
#
# Dependencies between .c and .h files
#
uucico.o: uucico.c uucp.h proto.h os_misc.h uucico.h
findmach.o: findmach.c uucp.h proto.h os_misc.h uucico.h
findline.o: findline.c uucp.h proto.h os_misc.h
findent.o: findent.c uucp.h proto.h os_misc.h
chksched.o: chksched.c uucp.h proto.h os_misc.h uucico.h
finddev.o: finddev.c uucp.h proto.h os_misc.h
openport.o: openport.c uucp.h proto.h os_misc.h uucico.h
openuucp.o: openuucp.c uucp.h proto.h os_misc.h uucico.h
gproto.o: gproto.c uucp.h proto.h os_misc.h uucico.h
dumpcode.o: dumpcode.c uucp.h proto.h os_misc.h
closeuucp.o: closeuucp.c uucp.h proto.h os_misc.h uucico.h
connect.o: connect.c uucp.h proto.h os_misc.h uucico.h
findwork.o: findwork.c uucp.h proto.h os_misc.h uucico.h
filexfer.o: filexfer.c uucp.h proto.h os_misc.h uucico.h
docmd.o: docmd.c uucp.h proto.h os_misc.h
getsys.o: getsys.c uucp.h proto.h os_misc.h
getparam.o: getparam.c uucp.h proto.h os_misc.h uucico.h
getopt.o: getopt.c getopt.h
dotilde.o: dotilde.c uucp.h proto.h os_misc.h
userparam.o: userparam.c uucp.h proto.h os_misc.h
doalias.o: doalias.c uucp.h proto.h os_misc.h
mail.o: mail.c uucp.h proto.h os_misc.h mail.h
recvmail.o: recvmail.c uucp.h proto.h os_misc.h mail.h
sendmail.o: sendmail.c uucp.h proto.h os_misc.h mail.h
mailx.o: mail.c uucp.h proto.h os_misc.h mail.h
recvmail.o: recvmail.c uucp.h proto.h os_misc.h mail.h
rmail.o: rmail.c uucp.h proto.h os_misc.h
genseq.o: genseq.c uucp.h proto.h os_misc.h
rnews.o: rnews.c uucp.h proto.h os_misc.h rnews.h mbuf.h getopt.h
groups.o: groups.c uucp.h proto.h os_misc.h rnews.h mbuf.h
procbatch.o: procbatch.c uucp.h proto.h os_misc.h rnews.h mbuf.h
xatol.o: xatol.c
mbuf.o: mbuf.c mbuf.h
openarts.o: openarts.c uucp.h proto.h os_misc.h rnews.h mbuf.h
procart.o: procart.c uucp.h proto.h os_misc.h rnews.h mbuf.h
fixref.o: fixref.c
log.o: log.c uucp.h proto.h os_misc.h
validuser.o: validuser.c uucp.h proto.h os_misc.h
uuxqt.o: uuxqt.c uucp.h proto.h os_misc.h
findxwork.o: findxwork.c uucp.h proto.h os_misc.h
readnews.o: readnews.c uucp.h proto.h os_misc.h
newsutils.o: newsutils.c uucp.h proto.h os_misc.h
postnews.o: postnews.c uucp.h proto.h os_misc.h
expire.o: expire.c uucp.h proto.h os_misc.h
expgroup.o: expgroup.c uucp.h proto.h os_misc.h
subscribe.o: subscribe.c uucp.h proto.h os_misc.h
unsubscribe.o: unsubscribe.c uucp.h proto.h os_misc.h
uulog.o: uulog.c uucp.h proto.h os_misc.h
uuclean.o: uuclean.c uucp.h proto.h os_misc.h
uustat.o: uustat.c uucp.h proto.h os_misc.h
uucp.o: uucp.c uucp.h proto.h os_misc.h
cnvrtmail.o: cnvrtmail.c uucp.h proto.h os_misc.h
login.o: login.c uucp.h proto.h os_misc.h
chown.o: chown.c uucp.h proto.h os_misc.h
adduser.o: adduser.c uucp.h proto.h os_misc.h
uusetup.o: uusetup.c uucp.h proto.h os_misc.h uusetup.h
getdevices.o: getdevices.c uucp.h proto.h os_misc.h uusetup.h
getenv.o: getenv.c uucp.h proto.h os_misc.h
getseq.o: getseq.c uucp.h proto.h os_misc.h
maketemp.o: maketemp.c uucp.h proto.h os_misc.h
forkhsell.o: forkshell.c uucp.h proto.h os_misc.h
setuser.o: setuser.c uucp.h proto.h os_misc.h
filemove.o: filemove.c uucp.h proto.h os_misc.h
fixpath.o: fixpath.c uucp.h proto.h os_misc.h
makepath.o: makepath.c uucp.h proto.h os_misc.h
getdirs.o: getdirs.c uucp.h proto.h os_misc.h
fixline.o: fixline.c uucp.h proto.h os_misc.h
getenv.o: getenv.c uucp.h proto.h os_misc.h
fileserv.o: fileserv.c uucp.h proto.h os_misc.h
osk.o: osk.c uucp.h proto.h os_misc.h
pwent.o: pwent.c uucp.h proto.h os_misc.h
uuname.o: uuname.c uucp.h proto.h os_misc.h
parse.o: parse.c uucp.h proto.h os_misc.h
