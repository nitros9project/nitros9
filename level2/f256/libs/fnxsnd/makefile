# Makefile to create assembler library
include $(NITROS9DIR)/rules.mak

vpath %.as $(LEVEL1)/f256/libs/fnxsnd

MODS = psg.o

all:	../libfnxsnd.a

../libfnxsnd.a: $(MODS)
	$(LWAR) $@ $?

clean:
	$(RM) *.o ../libfnxsnd.a *.list *.map
