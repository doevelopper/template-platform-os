.DEFAULT_GOAL:=help
#
# MSF DHS project Makefile
#
include define.mk

.NOTPARALLEL: $(SUPPORTED_TARGETS) $(TARGETS_CONFIG) all

# ####################################################################################################
# #
# #				BLRT Infrastructure setup
# #
# ####################################################################################################

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
		echo "---------------------------------------------------"; \
		echo "Applying $${p}"; \
		echo "---------------------------------------------------"; \
		patch -d $(BLRT_OOSB)/buildroot-$(BLRT_VERSION) --remove-empty-files -p1 < $${p} || exit 237; \
		[ ! -x $${p%.*}.sh ] || $${p%.*}.sh $(BLRT_OOSB)/buildroot-$(BLRT_VERSION); \
	done;
	$(Q)touch $@

$(BLRT_OOSB)/.others-patched: $(BLRT_OOSB)/.buildroot-patched
	$(Q)$(call MESSAGE,"BLRT [Apply our patches that either haven't been submitted or merged upstream in buildroot-$(BLRT_VERSION)] packages")
#	$(BLRT_DIR)/support/scripts/apply-patches.sh $(BLRT_OOSB)/buildroot-$(BLRT_VERSION) $(BLRT_EXT)/patches/buildroot || exit 1
	$(Q)touch $@

# ####################################################################################################
# #
# #								DHS goals declaration
# #
# ####################################################################################################

# $(BLRT_OOSB)/%/.config:
$(BLRT_OOSB)/$*-build-artifacts/.config: $(BLRT_OOSB)/.others-patched
	$(Q)$(call MESSAGE,"BLRT [Generating configuration for $*]")

$(TARGETS_CONFIG): %-configure: $(BLRT_OOSB)/$*-build-artifacts/.config
	$(Q)$(call MESSAGE,"BLRT [Callee Generating configuration for $*]")
	$(Q)$(MAKE) $(BLRT_MAKEARGS) O=$(BLRT_OOSB)/$*-build-artifacts  $*_defconfig
#	$(Q)if [ ! -f $(BLRT_OOSB)/$*-build-artifacts/.config ] then; \
# 			$(MAKE) $(BLRT_MAKEARGS) O=$(BLRT_OOSB)/$*-build-artifacts  $*_defconfig \
# 		else \
# 			$(call MESSAGE,"BLRT [configuration for $* alredy done]") \
#		fi

$(TARGETS_CONFIG_COMPILE): %-compile: %-configure
	$(Q)$(call MESSAGE,"[  Compiling artifacts for targets $*]")
	$(Q)$(MAKE) $(BLRT_MAKEARGS) O=$(BLRT_OOSB)/$*-build-artifacts
	$(Q)$(call MESSAGE,"[ Copying artifacts to $(BLRT_ARTIFACTS_DIR)]")
	$(Q)if [ -d $(BLRT_ARTIFACTS_DIR) ]; then rm -Rvf $(BLRT_ARTIFACTS_DIR) && mkdir -pv $(BLRT_ARTIFACTS_DIR); fi
	$(Q)cp -Rv $(BLRT_OOSB)/$*-build-artifacts/images $(BLRT_ARTIFACTS_DIR)
	$(Q)echo Copying binaries to tftp server
	$(Q)rm -vf /srv/tftp/*
	$(Q)cp -nv $(BLRT_OOSB)/$*-build-artifacts/images/u-boot.bin /srv/tftp/
	$(Q)cp -nv $(BLRT_OOSB)/$*-build-artifacts/images/*.dtb /srv/tftp/
	$(Q)cp -nv $(BLRT_OOSB)/$*-build-artifacts/images/*mage /srv/tftp/

$(TARGETS_CONFIG_TEST): %-unit-test: %-compile
	$(Q)$(call MESSAGE,"[  Running Unit test for targets $*]")
#	$(Q)$(MAKE) $(BLRT_MAKEARGS) O=$(BLRT_OOSB)/$*-build-artifacts  $*_defconfig

$(TARGETS_CONFIG_ITEST): %-integration-test: %-unit-test
	$(Q)$(call MESSAGE,"[  Running Integration test for targets $* board]")

$(TARGETS_CONFIG_REL): %-release: %-integration-test
	$(Q)$(call MESSAGE,"[  Packaging $* board's artefacts]")

$(BLRT_CONFIG): %-menuconfig:
	$(Q)$(call MESSAGE,"BLRT [Change buildroot configuration for $*]")
	$(Q)$(MAKE) $(BLRT_MAKEARGS) O=$(BLRT_OOSB)/$*-build-artifacts $(subst $*-,,$@)
	$(Q)echo
	$(Q)echo "!!! Important !!!"
	$(Q)echo "1. $*-configure has NOT been updated."
	$(Q)echo "   Changes will be lost if you run 'make distclean'."
	$(Q)echo "   Run $(TERM_BOLD) 'make $*-savedefconfig' $(TERM_RESET) to update."
	$(Q)echo "2. Buildroot normally requires you to run 'make clean' and 'make' after"
	$(Q)echo "   changing the configuration. You don't technically have to do this,"
	$(Q)echo "   but if you're new to Buildroot, it's best to be safe."

$(LINUX_CONFIG): %-linux-menuconfig:
#	@if grep -q 'BR2_LINUX_KERNEL=y'
	$(Q)$(call MESSAGE,"[ Change the Linux kernel configuration.] $*")
	$(Q)$(MAKE) $(BLRT_MAKEARGS) O=$(BLRT_OOSB)/$*-build-artifacts $(subst $*-,,$@)
	$(Q)$(MAKE) $(BLRT_MAKEARGS) O=$(BLRT_OOSB)/$*-build-artifacts linux-savedefconfig
	$(Q)echo
	$(Q)echo Going to update your $(BR2_EXTERNAL_SCRATCHOS_PATH)/board/$*/configs/linux.config. If you do not have one,
	$(Q)echo you will get an error shortly. You will then have to make one and update,
	$(Q)echo your buildroot configuration to use it.
	$(Q)echo
	$(Q)$(MAKE) $(BLRT_MAKEARGS) O=$(BLRT_OOSB)/$*-build-artifacts linux-update-defconfig	

$(UBOOT_CONFIG): %-uboot-menuconfig:
	$(Q)$(call MESSAGE,"[ Change the Bootloader configuration.] $*")
#	@if grep -q 'BR2_TARGET_UBOOT=y' $(BLRT_OOSB)/$*-build-artifacts/.config; then
	$(Q)$(MAKE) $(BLRT_MAKEARGS) O=$(BLRT_OOSB)/$*-build-artifacts $(subst $*-,,$@)
	$(Q)$(MAKE) $(BLRT_MAKEARGS) O=$(BLRT_OOSB)/$*-build-artifacts uboot-savedefconfig
	$(Q)echo
	$(Q)echo Going to update your $(BR2_EXTERNAL_SCRATCHOS_PATH)/board/$*/configs/uboot.config. If you do not have one,
	$(Q)echo you will get an error shortly. You will then have to make one and update,
	$(Q)echo your buildroot configuration to use it.
	$(Q)$(MAKE) $(BLRT_MAKEARGS) O=$(BLRT_OOSB)/$*-build-artifacts uboot-update-defconfig

#	else 
#		echo "--- (UBOOT not activated SKIPPING $@ ---" ;
#	fi

$(BUSYBOX_CONFIG): %-busybox-menuconfig:
	$(Q)$(call MESSAGE,"[ Change the Busybox configuration.] $*")
	$(Q)$(MAKE) $(BLRT_MAKEARGS) O=$(BLRT_OOSB)/$*-build-artifacts $(subst $*-,,$@)
	$(Q)echo
	$(Q)echo Going to update your $(BR2_EXTERNAL_SCRATCHOS_PATH)/board/$*/configs/busybox.config. If you do not have one,
	$(Q)echo you will get an error shortly. You will then have to make one and update,
	$(Q)echo your buildroot configuration to use it.
	$(Q)echo
	$(Q)$(MAKE) $(BLRT_MAKEARGS) O=$(BLRT_OOSB)/$*-build-artifacts busybox-update-config

$(BR_SAVE_CONFIG): %-savedefconfig: 
	$(Q)$(call MESSAGE,"BLRT [Saving $*] default config")
	$(Q)$(MAKE) $(BLRT_MAKEARGS)  O=$(BLRT_OOSB)/$*-build-artifacts savedefconfig BR2_DEFCONFIG=$(DEFCONFIG_DIR_FULL)/$*_defconfig

$(REBUILD_UBOOT_CFG): %-uboot-rebuild:
	$(Q)$(call MESSAGE,"BLRT [Rebuilding after $(call UC, $(word 1,$(subst -, ,$(subst $*-,,$@)))) $* configuration change!]")
	$(Q)$(MAKE) $(BLRT_MAKEARGS) O=$(BLRT_OOSB)/$*-build-artifacts $(subst $*-,,$@)

$(REBUILD_LINUX_CFG): %-linux-rebuild:
	$(Q)$(call MESSAGE,"BLRT [Rebuilding after $(call UC, $(word 1,$(subst -, ,$(subst $*-,,$@)))) $* configuration change!]")
	$(Q)$(MAKE) $(BLRT_MAKEARGS) O=$(BLRT_OOSB)/$*-build-artifacts $(subst $*-,,$@)

$(REBUILD_BUSYBOX_CFG): %-busybox-rebuild:
	$(Q)$(call MESSAGE,"BLRT [Rebuilding after $(call UC, $(word 1,$(subst -, ,$(subst $*-,,$@)))) $* configuration change!]")
	$(Q)$(MAKE) $(BLRT_MAKEARGS) O=$(BLRT_OOSB)/$*-build-artifacts $(subst $*-,,$@)


##################################################################################################################################
#
#                                     BR2 Clean goals
#
##################################################################################################################################

$(BLRT_CLEAN): %-clean:
	$(Q)$(call MESSAGE,"[  Delete all files created by $*'s build]")
	$(Q)$(MAKE) $(BLRT_MAKEARGS) O=$(BLRT_OOSB)/$*-build-artifacts $(subst $*-,,$@)

$(BLRT_DISTCLEAN): %-distclean:
	$(Q)$(call MESSAGE,"[  Delete all non-source files including $*'s .config ]")
	$(Q)$(MAKE) $(BLRT_MAKEARGS) O=$(BLRT_OOSB)/$*-build-artifacts $(subst $*-,,$@)

##################################################################################################################################
#
#                                     Artifact upload to targets
#
##################################################################################################################################

$(BURN_ARTIFACTS): %-upload:
	$(Q)$(call MESSAGE,"[ Uploading $*'s artifacts")
	@if grep -q 'BR2_PACKAGE_SWUPDATE=y' $(BLRT_OOSB)/$*-build-artifacts/.config; then \
        echo "--- (swupdate) $* ---" ; \
    else \
        echo "--- (skip swupdate) $* ---" ; \
    fi

$(UPGRADE_ARTIFACTS): %--upgrade:
	$(Q)$(call MESSAGE,"[ Upgrading $*'s artifacts")
	@if grep -q 'BR2_PACKAGE_SWUPDATE=y' $(BLRT_OOSB)/$*-build-artifacts/.config; then \
        echo "--- (swupdate) $* ---" ; \
    else \
        echo "--- (skip swupdate) $* ---" ; \
    fi


.PHONY: help
help: ## Display this help and exits.
	$(Q)echo
	$(Q)echo "  Version $$(git describe --always), Copyright (C) 2023 MSF "
	$(Q)echo
	$(Q)echo
	$(Q)echo "$(TERM_BOLD)Build Environment$(TERM_RESET)"
	$(Q)echo
	$(Q)echo
	$(Q)awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf " \033[36m%-20s\033[0m  %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	$(Q)echo ""	
	$(Q)echo
	$(Q)echo "$(TERM_UNDERLINE)Supported targets:$(TERM_NOUNDERLINE)"
	$(Q)echo
	$(Q)$(foreach b, $(sort $(notdir $(patsubst %_defconfig,%,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))), \
		printf "  	%-30s - Build configuration for %s\\n" $(b) $(b:_defconfig=); \
	)
	$(Q)echo
