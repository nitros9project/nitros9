include $(NITROS9DIR)/rules.mak

CFLAGS += --os9 -I../../../lib/kreiderclib/defs
LFLAGS = --os9 -L../../../lib 
OBJS = amatch.o append.o bitmap.o catsub.o ckglob.o deflt.o del.o docmd.o \
	dodash.o doglob.o doprnt.o doread.o dowrite.o ed.o egets.o esc.o \
	find.o getfn.o getlst.o getnum.o getone.o getpat.o getptr.o getrhs.o \
	gettxt.o ins.o join.o makepat.o maksub.o matchs.o move.o omatch.o \
	optpat.o set.o setbuf.o subst.o unmkpat.o

all: ed

ed: $(OBJS)
	$(CC) $(LFLAGS) -o$@ $^ -lct -lnos96809l2
	
clean:
	$(RM) $(OBJS)
