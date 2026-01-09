# Makefile to create assembler library
include $(NITROS9DIR)/rules.mak


MODS = psg.o

all:	libwbsnd.a

libwbsnd.a: $(MODS)
	$(LWAR) $@ $?

clean:
	$(RM) *.o libwbsnd.a *.list *.map
