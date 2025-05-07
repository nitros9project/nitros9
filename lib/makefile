include $(NITROS9DIR)/rules.mak

all: libnos96809l1.a libnos96809l2.a libnos96309l2.a libnet.a libalib.a \
	libcoco.a libcoco3.a libcoco3_6309.a libdragon.a libatari.a \
	libmc09.a libf256.a

libnos96809l1.a: sys6809l1.o
	$(LWAR) $@ $?

libnos96809l2.a: sys6809l2.o
	$(LWAR) $@ $?

libnos96309l2.a: sys6309l2.o
	$(LWAR) $@ $?

libnet.a: net.o
	$(LWAR) $@ $?

libcoco.a: coco.o
	$(LWAR) $@ $?

libcoco3.a: coco3.o
	$(LWAR) $@ $?

libcoco3_6309.a: coco3_6309.o
	$(LWAR) $@ $?

libatari.a: atari.o
	$(LWAR) $@ $?

libdragon.a: dragon.o
	$(LWAR) $@ $?

libmc09.a: mc09.o
	$(LWAR) $@ $?

libf256.a: f256.o
	$(LWAR) $@ $?

libalib.a:
	$(MAKE) -C alib

info:
dsk:
dskcopy:
dskclean:

clean:
	$(RM) *.a *.o *.list *.map
	$(MAKE) -C alib clean
