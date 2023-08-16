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

##################################################################################################################################
# Courtesy to 
#	https://github.com/fhunleth/bbb-buildroot-fwup/blob/master/Makefile
#   	https://github.com/RosePointNav/nerves-sdk/blob/master/Makefile
#   	https://github.com/jens-maus/RaspberryMatic/blob/master/Makefile
##################################################################################################################################

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

# .PHONY: $(BLRT_OOSB)/$(TARGET_BOARD)-build-artifacts/.config
$(BLRT_OOSB)/$(TARGET_BOARD)-build-artifacts/.config: | $(BLRT_OOSB)/$(TARGET_BOARD)-build-artifacts
	$(Q)$(call MESSAGE,"BLRT [Generating default config for $(TARGET_BOARD)")
#	$(Q)$(BLRT_CMD) $(TARGET_BOARD)_defconfig
#	$(Q)$(BLRT_CMD) defconfig BR2_DEFCONFIG=$(DEFCONFIG_DIR_FULL)/$(TARGET_BOARD)_defconfig
	if [ ! -f $@ ]; then $(BLRT_CMD) defconfig BR2_DEFCONFIG=$(DEFCONFIG_DIR_FULL)/$(TARGET_BOARD)_defconfig; fi

.PHONY: $(TARGET_BOARD)-configure
$(TARGET_BOARD)-configure: | $(BLRT_OOSB)/$(TARGET_BOARD)-build-artifacts/.config
	$(Q)$(call MESSAGE,"BLRT [$(TARGET_BOARD)'s default configuration generated...")

.PHONY: $(addsuffix -menuconfig,$(TARGET_BOARD))
$(addsuffix -menuconfig,$(TARGET_BOARD)): %-menuconfig: $(TARGET_BOARD)-configure
	$(Q)$(call MESSAGE,"BLRT [Change buildroot configuration for $(TARGET_BOARD) board]")
	$(Q)$(BLRT_CMD) menuconfig
	$(Q)echo
	$(Q)echo "!!! Important !!!"
	$(Q)echo "1. $(TARGET_BOARD)-configure has NOT been updated."
	$(Q)echo "   Changes will be lost if you run 'make distclean'."
	$(Q)echo "   Run $(TERM_BOLD) 'make $(addsuffix -savedefconfig,$(TARGET_BOARD))' $(TERM_RESET) to update."
	$(Q)echo "2. Buildroot normally requires you to run 'make clean' and 'make' after"
	$(Q)echo "   changing the configuration. You don't technically have to do this,"
	$(Q)echo "   but if you're new to Buildroot, it's best to be safe."

.PHONY: $(addsuffix -savedefconfig,$(TARGET_BOARD))
$(addsuffix -savedefconfig,$(TARGET_BOARD)): %-savedefconfig: $(TARGET_BOARD)-configure
	$(Q)$(call MESSAGE,"BLRT [Saving $(TARGET_BOARD)] defautl config")
	$(Q)$(BLRT_CMD) savedefconfig
#	$(Q)$(BLRT_CMD) savedefconfig BR2_DEFCONFIG=$(DEFCONFIG_DIR_FULL)/$(TARGET_BOARD)_defconfig

.PHONY: $(addsuffix -linux-menuconfig,$(TARGET_BOARD))
$(addsuffix -linux-menuconfig,$(TARGET_BOARD)): %-linux-menuconfig: $(TARGET_BOARD)-configure
#	@if grep -q 'BR2_LINUX_KERNEL=y'
	$(Q)$(call MESSAGE,"$(TARGET_BOARD) [Change the Linux kernel configuration.] $*")
	$(Q)$(BLRT_CMD) linux-menuconfig
	$(Q)$(BLRT_CMD) linux-savedefconfig
	$(Q)echo
	$(Q)echo Going to update your board/$(TARGET_BOARD)/configs/linux.config. If you do not have one,
	$(Q)echo you will get an error shortly. You will then have to make one and update,
	$(Q)echo your buildroot configuration to use it.
	$(Q)echo
	$(Q)$(BLRT_CMD) linux-update-defconfig

.PHONY: $(addsuffix -uboot-menuconfig,$(TARGET_BOARD))
$(addsuffix -uboot-menuconfig,$(TARGET_BOARD)): %-uboot-menuconfig: $(TARGET_BOARD)-configure
#	@if grep -q 'BR2_TARGET_UBOOT=y' $(BLRT_OOSB)/$(TARGET_BOARD)-build-artifacts/.config; then
	$(Q)$(call MESSAGE,"$(TARGET_BOARD) [Change the Bootloader configuration.] $*")
	$(Q)$(BLRT_CMD) uboot-menuconfig
	$(Q)$(BLRT_CMD) uboot-savedefconfig
	$(Q)echo
	$(Q)echo Going to update your board/$(TARGET_BOARD)/configs/uboot.config. If you do not have one,
	$(Q)echo you will get an error shortly. You will then have to make one and update,
	$(Q)echo your buildroot configuration to use it.
	$(Q)$(BLRT_CMD) uboot-update-defconfig

#	else 
#		echo "--- (UBOOT not activated SKIPPING $@ ---" ;
#	fi

.PHONY: $(addsuffix -busybox-menuconfig,$(TARGET_BOARD))
$(addsuffix -busybox-menuconfig,$(TARGET_BOARD)): %-busybox-menuconfig: $(TARGET_BOARD)-configure
	$(Q)$(call MESSAGE,"$(TARGET_BOARD) [Change the Busybox configuration.] $*")
	$(Q)$(BLRT_CMD) busybox-menuconfig
	$(Q)$(BLRT_CMD) busybox-savedefconfig
	$(Q)echo
	$(Q)echo Going to update your board/$(TARGET_BOARD)/configs/busybox.config. If you do not have one,
	$(Q)echo you will get an error shortly. You will then have to make one and update,
	$(Q)echo your buildroot configuration to use it.
	$(Q)echo
	$(Q)$(BLRT_CMD) busybox-update-config

# ##################################################################################################################################
# #
# #    					Build -> unit-test -> integration-test -> coverage-test -> qacheck -> package
# #
# ##################################################################################################################################

.PHONY: $(addsuffix -compile,$(TARGET_BOARD))
$(addsuffix -compile,$(TARGET_BOARD)): | $(BLRT_OOSB)/buildroot-$(BLRT_VERSION) $(TARGET_BOARD)-configure
	$(Q)$(call MESSAGE,"$(TARGET_BOARD) [ Compiling artifacts]")
	$(Q)$(BLRT_CMD) BR2_JLEVEL=40
	$(Q)$(call MESSAGE,"$(TARGET_BOARD) [ Copying artifacts to $(BLRT_ARTIFACTS_DIR)]")
	$(Q)if [ -d $(BLRT_ARTIFACTS_DIR) ]; then rm -Rvf $(BLRT_ARTIFACTS_DIR) && mkdir -pv $(BLRT_ARTIFACTS_DIR); fi
	$(Q)cp -Rv $(BLRT_OOSB)/$(TARGET_BOARD)-build-artifacts/images $(BLRT_ARTIFACTS_DIR)
#	$(Q)$(MAKE) $(BLRT_MAKEARGS)  BR2_JLEVEL=40

.PHONY: $(addsuffix -unit-testing,$(TARGET_BOARD))
$(addsuffix -unit-testing,$(TARGET_BOARD)): | $(addsuffix -compile,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"$(TARGET_BOARD) [ Unit Testing]")

.PHONY: $(addsuffix -integration-testing,$(TARGET_BOARD))
$(addsuffix -integration-testing,$(TARGET_BOARD)): | $(addsuffix -unit-testing,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"$(TARGET_BOARD) [ Integration Testing]")

.PHONY: $(addsuffix -coverage-testing,$(TARGET_BOARD))
$(addsuffix -coverage-testing,$(TARGET_BOARD)): | $(addsuffix -unit-testing,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"$(TARGET_BOARD) [ Integration Testing]")

.PHONY: $(addsuffix -package,$(TARGET_BOARD))
$(addsuffix -package,$(TARGET_BOARD)): | $(addsuffix -integration-testing,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"$(TARGET_BOARD) [ Packaging]")

# ##################################################################################################################################
# #
# #    					Artifact upload to targets
# #
# ##################################################################################################################################
.PHONY: $(addsuffix -burn,$(TARGET_BOARD))
$(addsuffix -burn,$(TARGET_BOARD)): | $(addsuffix -compile,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"$(TARGET_BOARD) [ Replace everything on the SDCard with new artifacts]")
# 	$(Q)$(BLRT_OOSB)/$(TARGET_BOARD)-build-artifacts/host/usr/bin/rauc --version
# 	$(Q)$(BLRT_OOSB)/$(TARGET_BOARD)-build-artifacts/host/usr/bin/fwup --version
# ## $(Q)$(BLRT_OOSB)/$(TARGET_BOARD)-build-artifacts/host/usr/bin/fwup -a -i $(firstword $(wildcard $(Q)$(BLRT_OOSB)/$(TARGET_BOARD)-build-artifacts/output/images/*.fw)) -t complete

# # Upgrade the image on the SDCard (app data won't be removed)
# # This is usually the fastest way to update an SDCard that's already
# # been programmed. It won't update bootloaders, so if something is
# # really messed up, burn-complete may be better.
.PHONY: $(addsuffix -upgrade,$(TARGET_BOARD))
$(addsuffix -upgrade,$(TARGET_BOARD)): | $(addsuffix -compile,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"$(TARGET_BOARD) [ Upgrading taget $(TARGET_BOARD)]")
# 	@fakeroot $(OOSB)/$(TARGET_BOARD)-build-artifacts/host/usr/bin/fwup -a -i $(firstword $(wildcard $(OOSB)/$(TARGET_BOARD)-build-artifacts/output/images/*.fw)) -t upgrade
# 	@fakeroot $(OOSB)/$(TARGET_BOARD)-build-artifacts/host/usr/bin/fwup -y -a -i /tmp/finalize.fw -t on-reboot
# 	@fakeroot rm /tmp/finalize.fw

.PHONY: $(addsuffix -updater,$(TARGET_BOARD))
$(addsuffix -updater,$(TARGET_BOARD)): | $(addsuffix -compile,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"$(TARGET_BOARD) [ Updating $(TARGET_BOARD) packages]")
# 	$(Q)echo "=== $@ ==="
# 	@if grep -q 'BR2_PACKAGE_SWUPDATE=y' $(OOSB)/$(TARGET_BOARD)-build-artifacts/.config; then \
# 		echo "--- (swupdate) $@ ---" ; \
# 	else \
# 		echo "--- (skip swupdate) $@ ---" ; \
# 	fi

# ##################################################################################################################################
# #
# #    					BR2 Clean goals
# ##
# ##################################################################################################################################


.PHONY: package-clean
package-clean:
	$(Q)$(call MESSAGE,"[ Package clean  $(BLRT_OOSB)]")
	$(Q)mkdir -p $(build_dir)
	$(if $(V), @echo " RM        $(build_dir)/*.o")
	$(Q)find $(build_dir) -type f -name "*.o" -exec rm -rf {} +
	$(if $(V), @echo " RM        $(build_dir)/*.a")
	$(Q)find $(build_dir) -type f -name "*.a" -exec rm -rf {} +
	$(if $(V), @echo " RM        $(build_dir)/*.elf")
	$(Q)find $(build_dir) -type f -name "*.elf" -exec rm -rf {} +
	$(if $(V), @echo " RM        $(build_dir)/*.bin")
	$(Q)find $(build_dir) -type f -name "*.bin" -exec rm -rf {} +
	$(if $(V), @echo " RM        $(build_dir)/*.dtb")
	$(Q)find $(build_dir) -type f -name "*.dtb" -exec rm -rf {} +

# Rule for "make distclean"
.PHONY: package-distclean
package-distclean: package-clean
	$(Q)$(call MESSAGE,"[ Package distclean  $(BLRT_OOSB)]")
	$(Q)mkdir -p $(build_dir)
	$(if $(V), @echo " RM        $(build_dir)/*.dep")
	$(Q)find $(build_dir) -type f -name "*.dep" -exec rm -rf {} +
ifeq ($(build_dir),$(CURDIR)/build)
	$(if $(V), @echo " RM        $(build_dir)")
	$(Q)rm -rf $(build_dir)
endif
ifeq ($(install_root_dir),$(install_root_dir_default)/usr)
	$(if $(V), @echo " RM        $(install_root_dir_default)")
	$(Q)rm -rf $(install_root_dir_default)
endif
	$(if $(V), @echo " RM        $(src_dir)/cscope*")
	$(Q)rm -f $(src_dir)/cscope*


.PHONY: $(addsuffix -clean,$(TARGET_BOARD))
$(addsuffix -clean,$(TARGET_BOARD)):
	$(Q)$(call MESSAGE,"$(TARGET_BOARD) [ Delete all files created by $(TARGET_BOARD)'s build]")
	$(Q)$(BLRT_CMD) clean

.PHONY: $(addsuffix -distclean,$(TARGET_BOARD))
$(addsuffix -distclean,$(TARGET_BOARD)):
	$(Q)$(call MESSAGE,"$(TARGET_BOARD) [ Delete all non-source files (including .config) of $(TARGET_BOARD)'s build]")
	$(Q)$(BLRT_CMD) distclean

realclean:
	$(Q)$(call MESSAGE,"[ BLRT Removing  $(BLRT_OOSB)]")
	$(Q)rm -fr buildroot .buildroot-patched .buildroot-downloaded

dangerous-reset:
	$(Q)$(call MESSAGE,"[ BLRT wiping everything in $(BLRT_OOSB)]")
#	@rm -Rvf $(BLRT_OOSB)

# ##################################################################################################################################
# #
# #    					MISCS goals
# ##
# ##################################################################################################################################

# bootstrap-br2-external:
# 	$(Q)echo "Bootstrapping br2 external directory layout"
# 	@mkdir -pv br2-layout/{board/{common/configs,raspberrypi3-64/{rootfs-overlay,configs/{kernel-dts,uboot-dts},patches/{buildroot,linux,uboot,busybox}}},configs,toolchain/{toolchain-external-blrt-arm,toolchain-external-blrt-component},provides,packages/{applications/src/{it,site,{main,test}/{c,cpp,resources,py}},drivers/{user,kernel}},patches/{buildroot,linux,uboot,busybox}}
# 	@find . -type d -exec touch {}/.gitkeep \;
# 	@touch br2-layout/{external.desc,Config.in,Config.ext.in,external.mk}
# 	$(Q)echo "Now edit external.desc Config.in external.mk to fit your needs"

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
