AS = lwasm
AFLAGS = -f os9

all:	cpm

cpm:	cpm.asm os9core.asm file.asm instbl.asm z80.asm parity.asm bdos.asm
	$(AS) $(AFLAGS) -o $@ $<

clean:
	rm -f cpm 
	
dsk: