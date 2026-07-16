include $(NITROS9DIR)/rules.mak

TARGET	= view
#LFLAGS	+= -y -l=$(HOME)/Projects/c3/lib/rmalib/alib.l
LFLAGS	+= $(NITROS9DIR)/lib/root.r
RMAFLAGS += -I$(NITROS9DIR)/lib

ROFS	= debug.r view.r view_arith.r view_clp.r view_cm3.r view_convert.r \
		view_gfx.r view_gfx2.r view_gif.r view_gifcol.r view_gifpix.r \
		view_gifset.r view_global.r view_help.r view_img.r view_io.r \
		view_mac.r view_max.r view_maxcmp.r view_mge.r view_pals.r \
		view_parse.r view_pix.r view_pix2.r view_rat.r view_rle.r view_save.r \
		view_savecomp.r view_setsave.r view_st.r view_table.r view_vef.r \
		view_wait.r

$(TARGET): $(ROFS)
	rlink $(LFLAGS) $(ROFS) -o=$(TARGET)
	
clean:
	$(RM) $(TARGET) $(ROFS)