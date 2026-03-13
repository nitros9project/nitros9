include ../port.mak

vpath %.as  $(LEVEL2)/cmds:$(LEVEL1)/cmds
vpath %.asm $(LEVEL2)/cmds:$(LEVEL1)/cmds

DEPENDS     = ./makefile

AFLAGS      += -I$(LEVEL2)/$(PORT) -I$(LEVEL1)/modules -I../modules
LFLAGS      += -L$(NITROS9DIR)/lib
LFLAGS      += -lnos96809l2 -lnet -lalib

CMDS        = asm attr backup bawk binex build cmp copy \
              date dcheck debug ded deiniz del deldir devs dir dirsort disasm \
              display dmem dmode dsave dump dw echo edit error exbin \
              format free grep help httpd ident inetd iniz irqs link list load login \
              makdir mdir megaread merge mfree minted mmap modpatch more padrom park \
              pmap proc procs printerr prompt pwd pxd rename save setime \
              sleep smap tee telnet tmode touch tsmon unlink verify xmode

SHELLMODS   = shellplus echo iniz link load save unlink

UTILPAK1    = attr copy date del deldir dir display list makdir mdir \
              merge mfree procs rename tmode unlink

all:    $(DEPENDS) $(CMDS) shell utilpak1

tmode:  xmode.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DTMODE=1

xmode:  xmode.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DXMODE=1

pwd:    pd.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPWD=1

pxd:    pd.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPXD=1

shell:  $(SHELLMODS) $(DEPENDS)
	$(MERGE) $(SHELLMODS) >$@
	@$(ECHO) "*** Be sure the size of this file is less than 7681 bytes! ***"
	@ls -l $@
	@$(ECHO) ""

utilpak1:   $(UTILPAK1) $(DEPENDS)
	$(MERGE) $(UTILPAK1) >$@
	@$(ECHO) "*** Be sure the size of this file is less than 7681 bytes! ***"
	@ls -l $@
	@$(ECHO) ""

clean:
	$(RM) shell utilpak1 $(SHELLMODS) $(CMDS) *.list *.map

showobjs:
	@$(ECHO) shell utilpak1 $(CMDS)

identify:
	$(IDENT_SHORT) shell utilpak1 $(CMDS)

