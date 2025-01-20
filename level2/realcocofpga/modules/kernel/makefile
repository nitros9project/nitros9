PORT = coco3
include $(NITROS9DIR)/rules.mak

vpath %.asm $(LEVEL2)/modules/kernel:$(LEVEL1)/modules/kernel

DEPENDS		= ./makefile
AFLAGS		+= -DH6309=0
AFLAGS		+= -I$(LEVEL2)/$(PORT)
AFLAGS		+= -I$(LEVEL2)/modules/kernel
AFLAGS      += -I$(LEVEL1)/modules/kernel

KERNEL		= krn
KERNEL_CCB	= ccbkrn
KERNELP2	= krnp2
SYSCALLS	= fallimg.asm fallram.asm falltsk.asm faproc.asm fcmpnam.asm \
		fcpymem.asm fdatlog.asm fdelram.asm ffmodul.asm ffreehb.asm \
		fld.asm fldabx.asm flink.asm fmove.asm fnproc.asm fprsnam.asm \
		fdebug.asm fssvc.asm fvmodul.asm \
		fallbit.asm fallprc.asm fchain.asm fclrblk.asm fcrcmod.asm \
		fdelimg.asm fexit.asm ffind64.asm ffork.asm fgblkmp.asm \
		fgcmdir.asm fgmoddr.asm fgprdsc.asm fgprocp.asm ficpt.asm \
		fid.asm fmapblk.asm fmem.asm fsend.asm fsleep.asm fsprior.asm \
		fsswi.asm fstime.asm fsuser.asm funlink.asm funload.asm

ALLOBJS		= $(KERNEL) $(KERNELP2) $(KERNEL_CCB)

all:	$(ALLOBJS)

$(KERNEL):	krn.asm $(SYSCALLS) fsrqmem.asm

$(KERNEL_CCB):	ccbkrn.asm $(SYSCALLS) ccbfsrqmem.asm

$(KERNELP2):	krnp2.asm $(SYSCALLS)

clean:
	$(RM) $(ALLOBJS)

showobjs:
	@$(ECHO) $(ALLOBJS)

showcopyobjs:
	@$(ECHO) $(COPYOBJS)

identify:
	$(IDENT_SHORT) $(ALLOBJS)
