# Share reproducible-build settings with ToolShed and recursive makes.
ifneq ($(strip $(SOURCE_DATE_EPOCH)),)
export SOURCE_DATE_EPOCH
export TZ = UTC
export LC_ALL = C
ZIPFLAGS += -X
SET_BUILD_TIME = timestamp="$$( $(BUILD_DATE) +%Y%m%d%H%M.%S)" && touch -t "$$timestamp"
else
SET_BUILD_TIME = :
endif

BUILD_DATE = $(SHELL) "$(NITROS9DIR)/recipes/support/build-date.sh"
