# MSF file manager
#

include ../../../rules.mak

DEPENDS		= ./makefile

FMGRS		= msf_6309.mn msf_6809.mn
DESCS		= m0_40d.dd
ALLOBJS		= $(FMGRS) $(DESCS)

all:	$(ALLOBJS) $(DEPENDS)

clean:
	$(RM) $(ALLOBJS) *.list *.map

msf_6309.mn: msf.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DH6309=1

msf_6809.mn: msf.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@

dsk:
dskcopy:
