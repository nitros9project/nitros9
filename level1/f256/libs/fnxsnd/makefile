# Makefile to create assembler library
include $(NITROS9DIR)/rules.mak


MODS = psg.o

all:	libfnxsnd.a

libfnxsnd.a: $(MODS)
	$(LWAR) $@ $?

clean:
	$(RM) *.o libfnxsnd.a *.list *.map
