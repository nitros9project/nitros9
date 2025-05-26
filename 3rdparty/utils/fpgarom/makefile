# A makefile for booting os9

include ../../../rules.mak

DEPENDS		:= ./makefile

ALLJOBS	= FPGABOOT.BIN fpgaboot.rom

DSKFPGABOOT	= FPGABoot.DSK

DSKS		= $(DSKFPGABOOT)

all: banner $(ALLJOBS) $(DEPENDS)

banner:
	@$(ECHO) "**************************************************"
	@$(ECHO) "*                                                *"
	@$(ECHO) "*       Brett Gordon's CocoFPGA Boot ROM         *"
	@$(ECHO) "*                                                *"
	@$(ECHO) "**************************************************"

fpgaboot.rom: rom.asm FPGABOOT.BIN
	lwasm -fraw -ofpgaboot.rom -mrom.map rom.asm

$(DSKFPGABOOT): FPGABOOT.BIN AUTOEXEC.BAS
	$(RM) $@
	decb dskini $@
	decb copy -b -2 FPGABOOT.BIN $@,FPGABOOT.BIN
	decb copy -a -0 -l AUTOEXEC.BAS $@,AUTOEXEC.BAS
	decb copy -b -2 fpgaboot.rom $@,FPGABOOT.ROM

boot.bin: boot.asm sd.asm
	lwasm -mboot.map -oboot.bin boot.asm

FPGABOOT.BIN: boot.asm sd.asm test.lnk
	lwasm -fobj -oboot.o boot.asm
	lwasm -fobj -osd.o   sd.asm
	lwlink -mtest.map -oFPGABOOT.BIN -stest.lnk -b boot.o sd.o

dsk: all $(DSKS)

dskcopy: dsk
	$(CP) $(DSKS) $(DSKDIR)

dskclean:
	$(RM) $(DSKS)

clean: dskclean
	$(RM) $(ALLJOBS) *.o *.list *.map

info:
	@$(ECHO) "*** Brett Gordon's CocoFPGA Boot ROM ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)
