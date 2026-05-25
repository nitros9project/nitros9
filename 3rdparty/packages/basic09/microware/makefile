PYTHON = python3
SCRIPT = build-modular-basic09.py

SRCS = comand.asm compil.asm binder.asm stmts.asm exprsn.asm cnvio.asm \
       defs b09defs b09type jmpdefs linkage editor

.PHONY: all clean

all: basic09_6809 runb_6809 basic09_6309 runb_6309

basic09_6809: $(SCRIPT) $(SRCS)
	$(PYTHON) $(SCRIPT) basic09 $@ -DCOMMUNITY=1

runb_6809: $(SCRIPT) $(SRCS)
	$(PYTHON) $(SCRIPT) runb $@ -DCOMMUNITY=1

basic09_6309: $(SCRIPT) $(SRCS)
	$(PYTHON) $(SCRIPT) basic09 $@ -DCOMMUNITY=1 -DH6309=1

runb_6309: $(SCRIPT) $(SRCS)
	$(PYTHON) $(SCRIPT) runb $@ -DCOMMUNITY=1 -DH6309=1

clean:
	rm -f basic09_6809 runb_6809 basic09_6309 runb_6309
	rm -rf .modular-build
	rm *.list *.map
