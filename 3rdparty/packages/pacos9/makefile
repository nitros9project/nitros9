include $(NITROS9DIR)/rules.mak

TARGET = pacos9
OBJS = main90.o board90.o caged90.o check90.o ghosts90.o movpac90.o \
       score90.o scrns90.o setup90.o
LFLAGS += -L$(NITROS9DIR)/lib -lnos96809l2

DSK = PacOS9.dsk

$(TARGET): $(OBJS)
	$(LINKER) $(LFLAGS) $^ -o$@

dsk: $(DSK)

$(DSK): $(TARGET)
	$(RM) $@
	$(OS9FORMAT) -q $@ -n"Larry Olson's Pacos9"
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(TARGET) $@,CMDS
	$(OS9ATTR_EXEC) $@,CMDS/$(TARGET)

dskcopy: $(DSK)
	$(CP) $(DSK) $(DSKDIR)

dskclean:
	$(RM) $(DSK)

clean: dskclean
	$(RM) $(OBJS) $(TARGET) *.list *.map

info:
	@$(ECHO) "*** Larry Olson's Pacos9 game ***"
	@$(ECHO) $(DSK)
