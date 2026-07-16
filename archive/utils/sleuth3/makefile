include ../../../rules.mak

DEPENDS		= ./makefile

AS		= lwasm --6309 --format=os9 --pragma=forwardrefmax,pcaspcr,nosymbolcase,condundefzero,undefextern,dollarnotlocal --includedir=. --includedir=$(DEFSDIR)

ALLOBJS		= $(OBJS)

DSKSLEUTH3	= Sleuth3.dsk

DSKS		= $(DSKSLEUTH3)

OBJS		= Sleuth3 XRefs3 ChgNam3

TXTS1		= genes.notes csshelps.txt

TXTS2		= csschgdf.txt csschge1.txt csschge2.txt \
		  csschge9.txt csschgf1.txt csschgf2.txt csschgf9.txt

SRCS		= cssauxil3.asm cssconst3.asm cssdisas3.asm cssdkdsk3.asm cssdmptb3.asm \
		cssgetcd3.asm cssiafcb3.asm cssinitz3.asm cssinput3.asm cssleuth3.asm \
		cssmapdk3.asm cssmiscl3.asm cssnames3.asm cssoutcd3.asm cssparam3.asm \
		cssshowc3.asm csstable3.asm cssvarbl3.asm cssxiort3.asm cssxrefs3.asm \
		csszapcd3.asm sleuth3.asm

CMDS		= $(OBJS)

all:	banner $(ALLOBJS) $(DEPENDS)	

banner:
	@$(ECHO) "**************************************************"
	@$(ECHO) "*                                                *"
	@$(ECHO) "*           Sleuth3 Disassembler                 *"
	@$(ECHO) "*                                                *"
	@$(ECHO) "**************************************************"

Sleuth3: sleuth3.asm
	$(AS) $(ASOUT)$@ $< $(M6809)
XRefs3: cssxrefs3.asm
	$(AS) $(ASOUT)$@ $< $(M6809)
ChgNam3: cssnames3.asm
	$(AS) $(ASOUT)$@ $< $(M6809)

$(DSKSLEUTH3): $(CMDS)
	$(RM) $@
	$(OS9FORMAT_DS80) -q $@ -n"Sleuth3 Disassembler"
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,HELP
	$(MAKDIR) $@,EXAMPL
	$(MAKDIR) $@,SRC
	$(OS9COPY) $(CMDS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(OS9COPY) $(TXTS1) $@,HELP
	$(OS9ATTR_TEXT) $(foreach file,$(TXTS1),$@,HELP/$(file))
	$(OS9COPY) $(TXTS2) $@,EXAMPL
	$(OS9ATTR_TEXT) $(foreach file,$(TXTS2),$@,EXAMPL/$(file))
	$(OS9COPY) $(SRCS) $@,SRC
	$(OS9ATTR_TEXT) $(foreach file,$(SRCS),$@,SRC/$(file))

dsk: all $(DSKS)

dskcopy: dsk
	$(CP) $(DSKS) $(DSKDIR)

dskclean:
	$(RM) $(DSKS)

clean: dskclean
	$(RM) $(ALLOBJS) *.list *.map

info:
	@$(ECHO) "*** Sleuth3 OS9 Disassembler ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)

