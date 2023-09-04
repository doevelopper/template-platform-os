.DEFAULT_GOAL:=help

# This file is part of CFSOS.
#
#    CFSOS is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    CFSOS is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with CFSOS.  If not, see <http://www.gnu.org/licenses/>.

#             __|__
#      --@--@--(_)--@--@--

include br-external.conf

.NOTPARALLEL: $(SUPPORTED_TARGETS) $(TARGETS_CONFIG) all

##################################################################################################################################
# Courtesy to 
#	https://github.com/fhunleth/bbb-buildroot-fwup/blob/master/Makefile
#   https://github.com/RosePointNav/nerves-sdk/blob/master/Makefile
#   https://github.com/jens-maus/RaspberryMatic/blob/master/Makefile
##################################################################################################################################

$(BLRT_OOSB)/buildroot:
	@mkdir -p $(OUTPUT_DIR)
	@rm -rf $(OUTPUT_DIR)/buildroot || :
	@git clone -q -b $(BR2_VERSION) --depth 1 $(BR2_GIT_URL) $(OUTPUT_DIR)/buildroot 2>/dev/null

$(BLRT_OOSB)/buildroot-$(BLRT_VERSION).tar.gz.sign:
	$(Q)$(call MESSAGE,"BLRT [Downloading signature $@ ]")
	$(Q)mkdir -pv $(BLRT_OOSB)
	$(Q)mkdir -pv $(BLRT_CCACHE_DIR)
	$(Q)mkdir -pv $(BLRT_ARTIFACTS_DIR)
	curl --output $@ https://buildroot.org/downloads/buildroot-$(BLRT_VERSION).tar.gz.sign

$(BLRT_OOSB)/buildroot-$(BLRT_VERSION).tar.gz: | $(BLRT_OOSB)/buildroot-$(BLRT_VERSION).tar.gz.sign
	$(Q)$(call MESSAGE,"BLRT [Downloading build tool $@ ]")
	$(Q)curl --output $@ https://buildroot.org/downloads/buildroot-$(BLRT_VERSION).tar.gz

$(BLRT_OOSB)/buildroot-$(BLRT_VERSION): | $(BLRT_OOSB)/buildroot-$(BLRT_VERSION).tar.gz
	$(Q)$(CMD_PREFIX)$(call MESSAGE,"BLRT [Extracting buildroot-$(BLRT_VERSION)] $@ ")
	$(Q)cd $(BLRT_OOSB) && if [ ! -d $@ ]; then tar xf $(BLRT_OOSB)/buildroot-$(BLRT_VERSION).tar.gz; fi

$(BLRT_OOSB)/.buildroot-downloaded: $(BLRT_OOSB)/buildroot-$(BLRT_VERSION)
	$(Q)$(call MESSAGE,"BLRT [Caching downloaded files in $(BLRT_DL_DIR).]")
	$(Q)mkdir -p $(BLRT_DL_DIR)
	$(Q)touch $@

## useful to patch version of package to be downloaded...  this patch preceed <package>-patch ....
$(BLRT_OOSB)/.buildroot-patched: $(BLRT_OOSB)/.buildroot-downloaded
	$(Q)$(call MESSAGE,"BLRT [Patching buildroot-$(BLRT_VERSION)]")
	
	$(Q)for p in $(sort $(wildcard buildroot-patches/*.patch)); do \
		echo "\nApplying $${p}"; \
		patch -d $(BLRT_OOSB)/buildroot-$(BLRT_VERSION) --remove-empty-files -p1 < $${p} || exit 237; \
		[ ! -x $${p%.*}.sh ] || $${p%.*}.sh $(BLRT_OOSB)/buildroot-$(BLRT_VERSION); \
	done;
	$(Q)touch $@

$(BLRT_OOSB)/.others-patched: $(BLRT_OOSB)/.buildroot-patched
	$(Q)$(call MESSAGE,"BLRT [Apply our patches that either haven't been submitted or merged upstream in buildroot-$(BLRT_VERSION)] packages")
#	$(BLRT_DIR)/support/scripts/apply-patches.sh $(BLRT_OOSB)/buildroot-$(BLRT_VERSION) $(BLRT_EXT)/patches/buildroot || exit 1
	$(Q)touch $@

$(BLRT_OOSB)/$(TARGET_BOARD)-build-artifacts: | $(BLRT_OOSB)/buildroot-$(BLRT_VERSION) $(BLRT_OOSB)/.others-patched
	$(Q)$(call MESSAGE,"BLRT [Creating $(TARGET_BOARD) build directory.]")
	$(Q)mkdir $(BLRT_OOSB)/$(TARGET_BOARD)-build-artifacts
	$(Q)touch $@


# ####################################################################################################
# #
# #								Goals declaration
# #
# ####################################################################################################

$(TARGETS_CONFIG): %-configure:
	$(Q)$(call MESSAGE,"BR2 [Generating configuration for $*")
#	$(MAKE) $(BLRT_MAKEARGS) O=$(BLRT_OOSB)/$*-build-artifacts  $*_defconfig



.PHONY: help
help:
	$(Q)echo
	$(Q)echo "  Version $$(git describe --always), Copyright (C) 2023 AHL"
	$(Q)echo
	$(Q)echo "  Comes with ABSOLUTELY NO WARRANTY; for details see file LICENSE."
	$(Q)echo "  SPDX-License-Identifier: GPL-2.0-only"
	$(Q)echo
	$(Q)echo "$(TERM_BOLD)Build Environment$(TERM_RESET)"
	$(Q)echo
	$(Q)echo
	$(Q)echo "$(TERM_BOLD)Availables commands$(TERM_RESET)"
	$(Q)echo
	$(Q)echo "$(TERM_UNDERLINE)Cleaning goals:$(TERM_NOUNDERLINE)"
	$(call print-help,$(MAKE) $(addsuffix -clean,$(TARGET_BOARD)),Cleans $(TARGET_BOARD))
	$(call print-help,$(MAKE) $(addsuffix -distclean,$(TARGET_BOARD)),Cleans $(TARGET_BOARD))
	$(Q)echo
	$(Q)echo "$(TERM_UNDERLINE)Building goals:$(TERM_NOUNDERLINE)"
	$(call print-help,$(MAKE) $(addsuffix -compile,$(TARGET_BOARD)),Compile $(TARGET_BOARD))
	$(call print-help,$(MAKE) $(addsuffix -unit-testing,$(TARGET_BOARD)),run unit test $(TARGET_BOARD))
	$(call print-help,$(MAKE) $(addsuffix -integration-testing,$(TARGET_BOARD)),Run non regression test $(TARGET_BOARD))
ifeq ($(CONFIG_PLUGIN),y)
	@echo  'Plugin targets:'
	$(call print-help,plugins,Build the example TCG plugins)
	@echo  ''
endif
ifeq ($(CONFIG_LINUX),y)
	@echo  'Linux targets:'
	$(call print-help,plugins,Build the example TCG plugins)
	@echo  ''
endif
ifeq ($(CONFIG_UBOOT),y)
	@echo  'Uboot targets:'
	$(call print-help,plugins,Build the example TCG plugins)
	@echo  ''
endif
ifeq ($(CONFIG_BUSYBOX),y)
	@echo  'Busibox targets:'
	$(call print-help,plugins,Build the example TCG plugins)
	@echo  ''
endif
	$(Q)echo
	$(Q)echo "$(TERM_UNDERLINE)Supported targets:$(TERM_NOUNDERLINE)"
	$(Q)echo
	$(Q)$(foreach b, $(sort $(notdir $(patsubst %_defconfig,%,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))), \
		printf "  	%-30s - Build configuration for %s\\n" $(b) $(b:_defconfig=); \
	)
	$(Q)echo

# will delete the target of a rule if commands exit with a nonzero exit status
.DELETE_ON_ERROR:

print-%:
	@echo '$*=$($*)'

#	-- 
#	.-----------------.--------------------.------------------.--------------------.
#	|  Adrien L. H    | Real-Time Embedded | /"\ ASCII RIBBON | Erics' conspiracy: |
#	| +xx 000 000 000 | Software  Designer | \ / CAMPAIGN     |  ___               |
#	| +xx 000 000 000 `------------.-------:  X  AGAINST      |  \e/  There is no  |
#	| https://memyselandi_ad_exem/ | _/*\_ | / \ HTML MAIL    |   v   conspiracy.  |
#	'------------------------------^-------^------------------^--------------------'
