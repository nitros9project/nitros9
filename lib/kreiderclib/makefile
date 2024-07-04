# Makefile to create assembler library
include $(NITROS9DIR)/rules.mak

ASM		= lwasm --no-warn=ifp1 --6309 --format=obj --pragma=pcaspcr,condundefzero,undefextern,dollarnotlocal,noforwardrefmax --includedir=. --includedir=$(DEFSDIR)

MODS = _prgname.o abort.o abs.o access.o adump.o atof.o atoi.o atol.o \
	bsearch.o  \
	calloc.o case.o ccdiv.o ccmod.o ccmult.o cfinish.o cfloats.o \
	chcodes.o chmod.o chown.o claddsub.o clbits.o clcommon.o \
	clcompare.o clconvert.o cldiv.o clincdec.o clmove.o clmul.o \
	clnegcompl.o clshifts.o create.o cshifts.o \
	datmods.o defdrive.o devtyp.o dir.o dirutil.o \
	errmsg.o \
	fflush.o findstr.o fopen.o fread.o fseek.o ftelldummy.o \
	fwrite.o \
	getc.o getopt.o gets.o gs1.o gs2.o \
	htoi.o htol.o \
	id.o index.o intercept.o iob_data.o \
	l3tol.o lseek.o ltoa.o ltol3.o \
	mem.o memccpy.o memchr.o memcmp.o memcpy.o memory.o \
	memset.o minmax.o misc.o mktemp.o mod.o \
	open.o \
	patmatch.o pffdummy.o pfldummy.o \
	popen.o printf.o process.o prof.o profdummy.o putc.o \
	puts.o pwcryp.o pwent.o \
	rand.o read.o realloc.o reverse.o rpterr.o \
	scale.o setbase.o setbuf.o setjmp.o sets.o signal.o skip.o \
	sleep.o ss1.o ss2.o ss3.o stat.o strass.o strclr.o strcmp.o \
	strhcpy.o strings.o stringsu.o strlen.o strncat.o strncmp.o \
	strncpy.o strnucmp.o strpbrk.o strspn.o strtok.o strucmp.o \
	swab.o syscall.o syscommon.o system.o \
	tidyup.o time.o \
	uminmax.o utime.o \
	write.o \
	xtoa.o

NOTYET = pffinit.o plfinit.o

all:	../libkreiderc.a

../libkreiderc.a: $(MODS)
	lwar -c $@ $^

dskclean: clean

clean:
	$(RM) *.o ../libkreiderc.a *.list *.map
