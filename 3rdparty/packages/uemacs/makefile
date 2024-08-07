#  makefile for Micro emacs for os9/68000
# temp files on ram disk
include $(NITROS9DIR)/rules.mak

CC	= cmoc

CFLAGS = -I. -I../../../lib/kreiderclib/defs --os9

MAINR  = uemain1.o uemain2.o uemain3.o uemain4.o uemaintable.o
DISPR  = uedisplay1.o uedisplay2.o uedisplay3.o
RESTR  = uebasic.o uebuffer1.o uebuffer2.o uefile1.o uefile2.o uefileio.o \
ueline1.o ueline2.o uerandom1.o uerandom2.o ueregion.o uesearch.o uespawn.o \
uetermio.o uevt52.o uewindow.o ueword.o uetcap.o uecoco.o
RFILES = $(MAINR) $(DISPR) $(RESTR)

all: umacs

# use cio libarary
umacs: $(RFILES) 
	$(CC) --os9 -o $@ $^ -L../../../lib -lct -ltermcap -lnos96809l2
	  
$(MAINR): ueed.h uemain.h
$(DISPR): ueed.h uedisplay.h
$(RESTR): ueed.h

clean:
	$(RM) $(RFILES) umacs
	