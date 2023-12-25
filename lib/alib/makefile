# Makefile to create assembler library
include $(NITROS9DIR)/rules.mak


MODS = stimestr.o datestr.o getfmd.o mktemp.o linedit.o sho_regs.o \
	print_dec.o print_hex.o print_asc.o \
	mult16x8.o mult16x16.o div16x8.o div16x16.o div8x8.o \
	dec_bin.o bin_dec.o asc_bin.o bin_asc.o hex_bin.o \
	bin_hex.o bin2hex.o dectab.o bin_rom.o \
	strcat.o strcpy.o strncpy.o parsnstr.o strhcpy.o strhlen.o \
	strcmp.o strncmp.o strlen.o memmove.o ptsearch.o compare.o \
	b09strlen.o \
	to_upprs.o to_upper.o to_lowrs.o to_lower.o \
	is_punct.o is_print.o is_cntrl.o is_space.o is_xdigit.o \
	is_alnum.o is_alpha.o is_digit.o is_lower.o is_upper.o is_termin.o \
	prints.o puts.o fputs.o putcr.o fputcr.o putspace.o fputspace.o \
	putc.o fputc.o inkey.o getc.o fgetc.o gets.o fgets.o puty.o fputy.o \
	gety.o fgety.o ftrans.o \
	frewind.o ftoeof.o \
	jsr_cmd.o jsr_cmd2.o \
	windefs.o \
	to_sp.o to_non_sp.o memset.o rnd.o \
	opts.o


all:	../libalib.a

../libalib.a: $(MODS)
	$(LWAR) $@ $?

clean:
	$(RM) *.o ../libalib.a
