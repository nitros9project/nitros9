# The NitrOS-9 Project
# Project-Wide Rules

# Environment variables are used to specify any directories other
# than the defaults below:
#
#   NITROS9DIR   - base directory of the NitrOS-9 project on your system
#
# If the defaults below are fine, then there is no need to set any
# environment variables.

# NitrOS-9 version

#################### DO NOT CHANGE ANYTHING BELOW THIS LINE ####################

CC		= c3
OS9		= os9

DEFSDIR		= $(NITROS9DIR)/defs
DSKDIR		= $(NITROS9DIR)/dsks

L1D = $(NITROS9DIR)/level1
L2D = $(NITROS9DIR)/level2
L1MD = $(L1D)/modules
L2MD = $(L2D)/modules
L1CD = $(L1D)/cmds
L2CD = $(L2D)/cmds
L1PD = $(L1D)/$(PORT)
L2PD = $(L2D)/$(PORT)
L1PMD = $(L1PD)/modules
L2PMD = $(L2PD)/modules
L1PCD = $(L1PD)/cmds
L2PCD = $(L2PD)/cmds

ifeq ($(LEVEL),2)
  vpath %.asm $(L2PMD):$(L2PCD):$(L1PMD):$(L1PCD):$(L2MD):$(L1MD):$(L2CD):$(L1CD):$(L2MD)/kernel:$(L1MD)/kernel:$(L2PD)/sys/fonts:$(L1PD)/sys/fonts
 vpath %.as $(L2PMD):$(L2PCD):$(L1PMD):$(L1PCD):$(L2MD):$(L1MD):$(L2CD):$(L1CD):$(L2MD)/kernel:$(L1MD)/kernel:$(L2PD)/sys/fonts:$(L1PD)/sys/fonts
else
  vpath %.asm $(L1PMD):$(L1PCD):$(L1MD):$(L1CD):$(L1MD)/kernel:$(L1PD)/sys/fonts
  vpath %.as $(L1PMD):$(L1PCD):$(L1MD):$(L1CD):$(L1MD)/kernel:$(L1PD)/sys/fonts
endif

# If we're using the OS-9 emulator and the *real* OS-9 assembler,
# uncomment the following two lines.
#AS		= os9 /mnt2/src/ocem/os9/asm
#ASOUT		= o=

# Use the cross assembler
#AS		= os9asm -i=$(DEFSDIR)
AS		= lwasm --no-warn=ifp1 --6309 --format=os9 --pragma=pcaspcr,nosymbolcase,condundefzero,undefextern,dollarnotlocal,noforwardrefmax --includedir=$(DEFSDIR)
ASROM		= lwasm --no-warn=ifp1 --6309 --format=raw --pragma=pcaspcr,nosymbolcase,condundefzero,undefextern,dollarnotlocal,noforwardrefmax --includedir=$(DEFSDIR)
ASBIN		= lwasm --no-warn=ifp1 --6309 --format=decb --pragma=pcaspcr,nosymbolcase,condundefzero,undefextern,dollarnotlocal,noforwardrefmax --includedir=$(DEFSDIR)
ASOUT		= -o
ifdef LISTDIR
ASOUT		= --list=$(LISTDIR)/$@.lst --symbols -o
endif
OBJDIR		?= .obj
LIBDIR		?= .lib
MODDIR		?= .mods
AFLAGS		=
ifdef PORT
AFLAGS		+= -D$(PORT)=1
endif

# RMA/RLINK
ASM		= lwasm --no-warn=ifp1 --6309 --format=obj --pragma=pcaspcr,condundefzero,undefextern,dollarnotlocal,noforwardrefmax,export --includedir=. --includedir=$(DEFSDIR)
LINKER		= lwlink --format=os9
LWAR		= lwar -c

# Commands
MAKDIR		= $(OS9) makdir
RM		= rm -f
MERGE		= cat
MOVE		= mv
ECHO		= echo
CD		= cd
CP		= cp
OS9COPY		= $(OS9) copy -o=0
CPL		= $(OS9COPY) -l
TAR		= tar
CHMOD		= chmod
IDENT		= $(OS9) ident
IDENT_SHORT	= $(IDENT) -s
#UNIX2OS9	= u2o
#OS92UNIX	= o2u
OS9FORMAT	= os9 format -e
OS9FORMAT_SS35	= os9 format -e -t35 -ss -dd
OS9FORMAT_SS40	= os9 format -e -t40 -ss -dd
OS9FORMAT_SS80	= os9 format -e -t80 -ss -dd
OS9FORMAT_DS40	= os9 format -e -t40 -ds -dd
OS9FORMAT_DS80	= os9 format -e -t80 -ds -dd
OS9FORMAT_DW	= os9 format -t29126 -ss -dd
OS9FORMAT_SDC  = os9 format -e -t29126 -ss -dd
OS9FORMAT_SD  = os9 format -t29126 -ss -dd
OS9FORMAT_CART  = os9 format -e -t64 -ss -st16 -sa1
OS9GEN		= os9 gen
OS9RENAME	= os9 rename
OS9ATTR		= os9 attr -q
OS9ATTR_TEXT	= $(OS9ATTR) -npe -npw -pr -ne -w -r
OS9ATTR_EXEC	= $(OS9ATTR) -pe -npw -pr -e -w -r
PADROM		= $(OS9) padrom
MOUNT		= sudo mount
UMOUNT		= sudo umount
LOREMOVE	= sudo losetup -d
LOSETUP		= sudo losetup
LINK		= ln
ifeq ($(OS),W)
SOFTLINK	= $(LINK)	# Special case for Windows
else
SOFTLINK	= $(LINK) -s
endif
ARCHIVE		= zip -D -9 -j
MKDSKINDEX	= perl $(NITROS9DIR)/scripts/mkdskindex
DROP_EXTRA_SPACES = fn() { mv "$$1" "$$1.tmp" && sed 's/  */ /g' "$$1.tmp" > "$$1" && rm "$$1.tmp"; }; fn

# Directories
3RDPARTY	= $(NITROS9DIR)/3rdparty
LEVEL1		= $(NITROS9DIR)/level1
LEVEL2		= $(NITROS9DIR)/level2
LEVEL3		= $(NITROS9DIR)/level3
NOSLIB		= $(NITROS9DIR)/lib
CC68L1          = $(LEVEL1)/coco1
CC368L2         = $(LEVEL2)/coco3
CC363L2         = $(LEVEL2)/coco3_6309
CC363L3         = $(LEVEL3)/coco3_6309

# HDD Drive ID's
ID0 = -DITDRV=0
ID1 = -DITDRV=1
ID2 = -DITDRV=2
ID3 = -DITDRV=3
ID4 = -DITDRV=4
ID5 = -DITDRV=5
ID6 = -DITDRV=6
ID7 = -DITDRV=7
SLAVE  = -DITDNS=1
MASTER = -DITDNS=0


# C-Cubed Rules
$(OBJDIR):
	@mkdir -p $@

$(LIBDIR):
	@mkdir -p $@

$(MODDIR):
	@mkdir -p $@

$(OBJDIR)/%.o: %.c | $(OBJDIR)
	$(CC) $(CFLAGS) $< -r

%.a: $(OBJDIR)/%.o
	lwar -c $@ $?

%: $(OBJDIR)/%.o
	$(LINKER) $(LFLAGS) $^ -o$@

%: %.a
	$(LINKER) $(LFLAGS) $^ -o$@

$(OBJDIR)/%.o: %.as | $(OBJDIR)
	$(ASM) $(AFLAGS) $< $(ASOUT)$@

# File managers
$(MODDIR)/%.mn: %.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

# Device drivers
$(MODDIR)/%.dr: %.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

# Device descriptors
$(MODDIR)/%.dd: %.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

# Subroutine modules
$(MODDIR)/%.sb: %.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

# Window device descriptors
$(MODDIR)/%.dw: %.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

# Terminal device descriptors
$(MODDIR)/%.dt: %.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

# I/O subroutines
$(MODDIR)/%.io: %.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

# All other modules
$(MODDIR)/%: %.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

# Modules built from RMA/RLINK-format .as files (assemble then link)
$(MODDIR)/%: $(OBJDIR)/%.o | $(MODDIR)
	$(LINKER) $(LFLAGS) $^ -o$@

# Include an optional release file based on the port name that contains
# release variables set... e.g.:
# NOS9MVER=26
# NOS9MAJ=1
# NOS9MIN=1
-include $(NITROS9DIR)/release_$(PORT)

ifeq ($(NOS9MAJ),)
  NITROS9VER = DEV
  AFLAGS += -DNOS9VER=0 -DNOS9MAJ=0 -DNOS9MIN=0
else
  NITROS9VER = v$(NOS9VER).$(NOS9MAJ).$(NOS9MIN)
  AFLAGS += -DNOS9VER=$(NOS9VER) -DNOS9MAJ=$(NOS9MAJ) -DNOS9MIN=$(NOS9MIN)
endif

default: all

.PHONY: buildinfo

buildinfo:
	@BUILDDATE="$$(git log -1 --format=%as)"; \
	COMMITHASH="$$(git rev-parse --short HEAD)"; \
	BRANCHNAME="$$(git branch --show-current)"; \
	echo " fcc !$${BUILDDATE} ($${COMMITHASH} - $${BRANCHNAME})!" > buildinfo;

STDCMDS = asm attr backup bawk binex build cmp copy date dcheck debug \
	ded deiniz del deldir devs dir dirsort disasm display dmode dsave \
	dump echo edit error exbin format free grep help ident iniz irqs \
	link list load login makdir megaread mdir merge mfree more \
	padrom park pick printerr procs prompt pwd pxd rename save \
	setime shellplus shell_21 sleep tee tmode touch tsmon unlink verify \
	xmode
