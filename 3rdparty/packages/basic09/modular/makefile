PYTHON = python3
SCRIPT = build-modular-basic09.py

SRCS = comand.asm compil.asm binder.asm stmts.asm exprsn.asm cnvio.asm \
       defs b09defs b09type jmpdefs linkage editor

.PHONY: all clean

all: basic09 runb basic09_community runb_community

basic09: $(SCRIPT) $(SRCS)
	$(PYTHON) $(SCRIPT) basic09 $@

runb: $(SCRIPT) $(SRCS)
	$(PYTHON) $(SCRIPT) runb $@

basic09_community: $(SCRIPT) $(SRCS)
	$(PYTHON) $(SCRIPT) basic09 $@ -DH6309=1

runb_community: $(SCRIPT) $(SRCS)
	$(PYTHON) $(SCRIPT) runb $@ -DH6309=1

clean:
	rm -f basic09 runb basic09_community runb_community
	rm -rf .modular-build
