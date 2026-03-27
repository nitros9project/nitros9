vpath %.as $(NITROS9DIR)/lib:$(NITROS9DIR)/lib/alib

LIB_NAMES ?= libnos96809l1.a libnos96809l2.a libnos96309l2.a libnet.a libalib.a \
	libcoco.a libcoco3.a libcoco3_6309.a libdragon.a libatari.a \
	libmc09.a libwildbitsl1.a libwildbitsl2.a
LIB_TARGETS = $(addprefix $(LIBDIR)/,$(LIB_NAMES))

ALIB_OBJS = asc_bin.o b09strlen.o bin_asc.o bin_dec.o bin_hex.o \
	bin_rom.o bin2hex.o compare.o datestr.o dec_bin.o dectab.o \
	div16x16.o div16x8.o div8x8.o fgetc.o fgets.o fgety.o \
	fputc.o fputcr.o fputs.o fputspace.o fputy.o frewind.o \
	ftoeof.o ftrans.o getc.o getfmd.o gets.o gety.o hex_bin.o \
	inkey.o is_alnum.o is_alpha.o is_cntrl.o is_digit.o is_lower.o \
	is_print.o is_punct.o is_space.o is_termin.o is_upper.o \
	is_xdigit.o jsr_cmd.o jsr_cmd2.o linedit.o memmove.o memset.o \
	mktemp.o mult16x16.o mult16x8.o opts.o parsnstr.o print_asc.o \
	print_dec.o print_hex.o prints.o ptsearch.o putc.o putcr.o \
	puts.o putspace.o puty.o rnd.o sho_regs.o stimestr.o strcat.o \
	strcmp.o strlen.o strncmp.o to_lowrs.o to_non_sp.o to_sp.o to_upper.o \
	to_upprs.o windefs.o
ALIB_OBJ_TARGETS = $(addprefix $(OBJDIR)/,$(ALIB_OBJS))

libs: $(LIB_TARGETS)

$(LIBDIR)/libnos96809l1.a: $(OBJDIR)/sys6809l1.o | $(LIBDIR)
	$(LWAR) $@ $?

$(LIBDIR)/libnos96809l2.a: $(OBJDIR)/sys6809l2.o | $(LIBDIR)
	$(LWAR) $@ $?

$(LIBDIR)/libnos96309l2.a: $(OBJDIR)/sys6309l2.o | $(LIBDIR)
	$(LWAR) $@ $?

$(LIBDIR)/libnet.a: $(OBJDIR)/net.o | $(LIBDIR)
	$(LWAR) $@ $?

$(LIBDIR)/libcoco.a: $(OBJDIR)/coco.o | $(LIBDIR)
	$(LWAR) $@ $?

$(LIBDIR)/libcoco3.a: $(OBJDIR)/coco3.o | $(LIBDIR)
	$(LWAR) $@ $?

$(LIBDIR)/libcoco3_6309.a: $(OBJDIR)/coco3_6309.o | $(LIBDIR)
	$(LWAR) $@ $?

$(LIBDIR)/libatari.a: $(OBJDIR)/atari.o | $(LIBDIR)
	$(LWAR) $@ $?

$(LIBDIR)/libdragon.a: $(OBJDIR)/dragon.o | $(LIBDIR)
	$(LWAR) $@ $?

$(LIBDIR)/libmc09.a: $(OBJDIR)/mc09.o | $(LIBDIR)
	$(LWAR) $@ $?

$(LIBDIR)/libwildbitsl1.a: $(OBJDIR)/wildbitsl1.o | $(LIBDIR)
	$(LWAR) $@ $?

$(LIBDIR)/libwildbitsl2.a: $(OBJDIR)/wildbitsl2.o | $(LIBDIR)
	$(LWAR) $@ $?

$(LIBDIR)/libalib.a: $(ALIB_OBJ_TARGETS) | $(LIBDIR)
	$(LWAR) $@ $?
