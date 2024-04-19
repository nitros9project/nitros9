# Makefile to create assembler library
include $(NITROS9DIR)/rules.mak


MODS = psg.o

all:	../libf256snd.a

../libf256snd.a: $(MODS)
	$(LWAR) $@ $?

clean:
	$(RM) *.o ../libf256snd.a
