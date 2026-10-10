# Studio-9 (s9), the WildBits port of UltiMusE III; every module is built from its source in cmds/.
#
# The image sources in cmds/ assemble to raw intermediates in .mods/SYS: Chars16 is wrapped in the s9_d0 data
# module, UmeSymbols16 is included in s9's tail. Everything installed goes to .mods/CMDS.
# make: assemble code and data with lwasm alone (no Python); make verify: the Python checks.

NITROS9DIR ?= $(realpath ../../..)
include $(NITROS9DIR)/rules.mak

MODDIR   = .mods
# the piano-key pngs, read only by make piano-keys (kept in the build kit; the sprites are committed in
# cmds/UmeSymbols16.asm)
ARTDIR  ?= /home/taylo/wildbits-buildkit/tools/s9/art
CMDDIR   = cmds
# the image sources (Chars16/UmeSymbols16.asm) live beside the code; intermediates in .mods/SYS
SYSDIR   = cmds
AFLAGS  += -I$(NITROS9DIR)/level2/wildbits
# scdwv and the DriveWire MIDI descriptor are not built here: recipes/wildbits/wildbits.mak puts them in OS9Boot.
MODULES  = s9 s9gui s9b s9c s9d s9e s9k s9l s9m s9p s9r s9i s9y s9o s9f s9g s9s s9t s9u s9w s9_d0
FORKED   = $(filter-out equates,$(basename $(notdir $(wildcard $(CMDDIR)/*.asm))))   # cmds/equates.asm is shared, not a module
OBJS     = $(addprefix $(MODDIR)/CMDS/,$(MODULES))
SYSIMGS  = $(MODDIR)/SYS/UmeSymbols16.img $(MODDIR)/SYS/Chars16.img

# `make` builds every module with lwasm alone - no Python. The checks are `make verify`; the piano-key
# generator is `make piano-keys`.
all: $(OBJS)

verify: verify-symbols verify-data verify-sizes verify-menus

verify-symbols:
	$(PYTHON) tools/check/check_symbols.py

# every module includes the shared equates
$(addprefix $(MODDIR)/CMDS/,$(MODULES)): $(CMDDIR)/equates.asm

$(MODDIR)/CMDS/s9i: $(CMDDIR)/import_staff.inc $(CMDDIR)/midi_score.inc $(CMDDIR)/midi_bars.inc $(CMDDIR)/midi_read.inc $(CMDDIR)/equates.asm
$(MODDIR)/CMDS/s9y: $(CMDDIR)/import_staff.inc $(CMDDIR)/midi_score.inc $(CMDDIR)/midi_bars.inc $(CMDDIR)/equates.asm $(CMDDIR)/lyra_patches.inc $(NITROS9DIR)/defs/midi.d
$(MODDIR)/CMDS/s9r: $(CMDDIR)/score_browser.inc $(CMDDIR)/vs_rtmidi.inc
$(MODDIR)/CMDS/s9o: $(CMDDIR)/import_staff.inc $(CMDDIR)/midi_score.inc $(CMDDIR)/midi_bars.inc $(CMDDIR)/equates.asm
$(MODDIR)/CMDS/s9f: $(CMDDIR)/import_staff.inc $(CMDDIR)/midi_score.inc $(CMDDIR)/equates.asm
$(MODDIR)/CMDS/s9d: $(CMDDIR)/equates.asm
$(MODDIR)/CMDS/s9: $(CMDDIR)/Palette.asm $(CMDDIR)/module_dir.inc
$(MODDIR)/CMDS/s9gui: $(CMDDIR)/module_dir.inc
# The piano key images are committed as assembly in cmds/UmeSymbols16.asm. `make piano-keys` (Python) re-scales
# the pngs and rewrites that section - commit a changed png AND the regenerated UmeSymbols16.asm. The normal build
# never runs it.
PIANO_PNGS = $(ARTDIR)/piano_white.png $(ARTDIR)/piano_white_pressed.png $(ARTDIR)/piano_black.png $(ARTDIR)/piano_black_pressed.png
piano-keys:
	S9ART=$(ARTDIR) $(PYTHON) tools/gen/make_piano_keys.py
# s9gui builds its 128th-note glyphs from the symbol image itself (includebin slices, cmds/s9gui.asm Note128Glyph).
$(MODDIR)/CMDS/s9gui: $(MODDIR)/SYS/UmeSymbols16.img $(MODDIR)/SYS/Chars16.img

# UmeSymbols16 rides in s9's last two blocks ($A000 and $C000, includebin slices of the image). Chars16 is the
# separate s9_d0 module, which keeps s9gui below its 31,999-byte ceiling.
$(MODDIR)/CMDS/s9: $(MODDIR)/SYS/UmeSymbols16.img
# s9_d0 (cmds/s9_d0.asm) wraps the Chars16 image in a data module.
$(MODDIR)/CMDS/s9_d0: $(MODDIR)/SYS/Chars16.img

$(MODDIR)/CMDS $(MODDIR)/SYS $(MODDIR)/MAP:
	mkdir -p $@

# every module is built from its source in cmds/
# Each assembly also writes the module's routine index, .mods/MAP/<module>.map (offset, name, file:line), from
# its listing - regenerated every build, so it always matches the module.
$(MODDIR)/CMDS/%: $(CMDDIR)/%.asm | $(MODDIR)/CMDS $(MODDIR)/MAP
	$(AS) $(AFLAGS) --list=$(MODDIR)/MAP/$*.lst $< $(ASOUT)$@
	awk -f tools/routine_map.awk $(MODDIR)/MAP/$*.lst > $(MODDIR)/MAP/$*.map

# image sources for the data modules (cmds/Chars16.asm and UmeSymbols16.asm): annotated source, raw binary out to .mods/SYS
$(MODDIR)/SYS/%.img: $(SYSDIR)/%.asm | $(MODDIR)/SYS
	$(ASROM) $< $(ASOUT)$@

PYTHON    ?= python3

verify-data: $(filter $(MODDIR)/CMDS/s9_d0,$(OBJS))
	$(PYTHON) tools/check/verify_data.py $(MODDIR)

# Check existing outputs too, so an incremental build cannot bypass the limit.
# Every condensed menu is checked against its assembled bytes - rows vs header, widths, the window on screen, the
# states formats, the key dispatch, pickers on their windows (tools/check/check_menus.py).
verify-menus: $(OBJS)
	$(PYTHON) tools/check/check_menus.py "$(AS) $(AFLAGS)" $(MODDIR)/CMDS

verify-sizes: $(OBJS)
	$(PYTHON) tools/check/check_module_size.py $(OBJS)

# Optional development check; MC6809 is a test dependency, not a Foenix dependency.
verify-midi: $(MODDIR)/CMDS
	$(AS) $(AFLAGS) --symbol-dump=$(MODDIR)/Um3R_browser.sym $(CMDDIR)/s9r.asm $(ASOUT)$(MODDIR)/CMDS/s9r
	$(AS) $(AFLAGS) --symbol-dump=$(MODDIR)/Um3D_browser.sym $(CMDDIR)/s9d.asm $(ASOUT)$(MODDIR)/CMDS/s9d
	$(AS) $(AFLAGS) --symbol-dump=$(MODDIR)/Um3I_import.sym $(CMDDIR)/s9i.asm $(ASOUT)$(MODDIR)/CMDS/s9i
	$(AS) $(AFLAGS) --symbol-dump=$(MODDIR)/Um3P_import.sym $(CMDDIR)/s9p.asm $(ASOUT)$(MODDIR)/CMDS/s9p
	$(AS) $(AFLAGS) --symbol-dump=$(MODDIR)/Um3O_import.sym $(CMDDIR)/s9o.asm $(ASOUT)$(MODDIR)/CMDS/s9o
	$(AS) $(AFLAGS) --symbol-dump=$(MODDIR)/Um3F_import.sym $(CMDDIR)/s9f.asm $(ASOUT)$(MODDIR)/CMDS/s9f
	$(PYTHON) tools/check/check_module_size.py $(MODDIR)/CMDS/s9d $(MODDIR)/CMDS/s9i $(MODDIR)/CMDS/s9f $(MODDIR)/CMDS/s9p
	$(PYTHON) tools/test/test_midi_import.py
	$(PYTHON) tools/test/test_musica_import.py
	$(PYTHON) tools/test/test_musica_pitch.py
	$(PYTHON) tools/test/test_orc_import.py
	$(PYTHON) tools/test/test_score_browser.py
	$(PYTHON) tools/test/test_browser_pages.py
	$(PYTHON) tools/test/test_midi_playback.py

verify-config: all
	$(AS) $(AFLAGS) --symbol-dump=$(MODDIR)/Um3G_config.sym $(CMDDIR)/s9g.asm $(ASOUT)$(MODDIR)/CMDS/s9g
	$(AS) $(AFLAGS) --symbol-dump=$(MODDIR)/Um3D_config.sym $(CMDDIR)/s9d.asm $(ASOUT)$(MODDIR)/CMDS/s9d
	$(AS) $(AFLAGS) --symbol-dump=$(MODDIR)/Um3R_config.sym $(CMDDIR)/s9r.asm $(ASOUT)$(MODDIR)/CMDS/s9r
	$(PYTHON) tools/check/check_module_size.py $(MODDIR)/CMDS/s9g $(MODDIR)/CMDS/s9d $(MODDIR)/CMDS/s9r
	$(AS) $(AFLAGS) --symbol-dump=$(MODDIR)/s9_config.sym $(CMDDIR)/s9.asm $(ASOUT)$(MODDIR)/CMDS/s9
	$(AS) $(AFLAGS) --symbol-dump=$(MODDIR)/s9gui_config.sym $(CMDDIR)/s9gui.asm $(ASOUT)$(MODDIR)/CMDS/s9gui
	$(PYTHON) tools/test/test_studio9_config.py

report: all
	@for m in $(MODULES); do printf '%-10s %6s bytes\n' $$m $$(stat -c %s $(MODDIR)/CMDS/$$m); done

clean:
	$(RM) -r $(MODDIR)

.PHONY: all report clean verify verify-data verify-midi verify-sizes verify-menus verify-config verify-symbols piano-keys
.DELETE_ON_ERROR:
