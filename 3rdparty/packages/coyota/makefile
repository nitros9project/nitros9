include $(NITROS9DIR)/rules.mak

TARGET	= coyota
OBJS	= coyota.o instrument.o dashboard.o bin_dec32.o
LFLAGS	+= -lalib -lnos96809l2 -L$(NOSLIB)
DSK	= $(TARGET).dsk

$(TARGET): $(OBJS)

dsk: $(DSK)

$(DSK): $(TARGET)
	$(RM) $@
	$(OS9FORMAT) -q $@ -n"Coyota"
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(TARGET) $@,CMDS
	$(OS9ATTR_EXEC) $@,CMDS/$(TARGET)

dskclean:
	$(RM) $(DSK)

clean: dskclean
	$(RM) $(OBJS) $(TARGET) *.list *.map
