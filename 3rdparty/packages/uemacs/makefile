#  makefile for Micro emacs for os9/68000
# temp files on ram disk
include $(NITROS9DIR)/rules.mak

DCC     = dcc

DCCFLAGS = -q -o -s -dOS9 -dANSI

MAINO  = uemain1.o uemain2.o uemain3.o uemain4.o uemaintable.o
DISPO  = uedisplay1.o uedisplay2.o uedisplay3.o
RESTO  = uebasic.o uebuffer1.o uebuffer2.o uefile1.o uefile2.o uefileio.o \
  ueline1.o ueline2.o uerandom1.o uerandom2.o ueregion.o uesearch.o uespawn.o \
  uetermio.o ueansi.o uewindow.o ueword.o
OFILES = $(MAINO) $(DISPO) $(RESTO)

all: umacs

# use cio libarary
umacs: $(OFILES)
	$(DCC) $(DCCFLAGS) -f=$@ $^
  
$(MAINO): ueed.h uemain.h
$(DISPO): ueed.h uedisplay.h
$(RESTO): ueed.h

%.o: %.c
	$(DCC) $(DCCFLAGS) -r -f=$@ $<

clean:
	$(RM) $(OFILES) umacs *.list *.map c.errors cstr.* ctmp.*
