.DEFAULT_GOAL:=help
#
# MSF DHS project Makefile
#
include define.mk

# ####################################################################################################
# #
# #
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
#	$(Q)$(MAKE) $(BLRT_MAKEARGS) $(TARGET_BOARD)_defconfig
	$(Q)$(MAKE) $(BLRT_MAKEARGS) defconfig BR2_DEFCONFIG=$(DEFCONFIG_DIR_FULL)/$(TARGET_BOARD)_defconfig
#	if [ ! -f $@ ]; then $(MAKE) $(BLRT_MAKEARGS) defconfig BR2_DEFCONFIG=$(DEFCONFIG_DIR_FULL)/$(TARGET_BOARD)_defconfig; fi

.PHONY: $(TARGET_BOARD)-configure
$(TARGET_BOARD)-configure: | $(BLRT_OOSB)/$(TARGET_BOARD)-build-artifacts/.config
	$(Q)$(call MESSAGE,"BLRT [$(TARGET_BOARD)'s configuration ...")
#	$(Q)$(MAKE) $(BLRT_MAKEARGS) socrates_cyclone5_defconfig

.PHONY: $(addsuffix -menuconfig,$(TARGET_BOARD))
$(addsuffix -menuconfig,$(TARGET_BOARD)): %-menuconfig: $(TARGET_BOARD)-configure
	$(Q)$(call MESSAGE,"BLRT [Change buildroot configuration for $(TARGET_BOARD) board]")
	$(Q)$(MAKE) $(BLRT_MAKEARGS) menuconfig
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
#	$(Q)$(MAKE) $(BLRT_MAKEARGS) savedefconfig
	$(Q)$(MAKE) $(BLRT_MAKEARGS) savedefconfig BR2_DEFCONFIG=$(DEFCONFIG_DIR_FULL)/$(TARGET_BOARD)_defconfig

.PHONY: $(addsuffix -linux-menuconfig,$(TARGET_BOARD))
$(addsuffix -linux-menuconfig,$(TARGET_BOARD)): %-linux-menuconfig: $(TARGET_BOARD)-configure
#	@if grep -q 'BR2_LINUX_KERNEL=y'
	$(Q)$(call MESSAGE,"$(TARGET_BOARD) [Change the Linux kernel configuration.] $*")
	$(Q)$(MAKE) $(BLRT_MAKEARGS) linux-menuconfig
	$(Q)$(MAKE) $(BLRT_MAKEARGS) linux-savedefconfig
	$(Q)echo
	$(Q)echo Going to update your board/$(TARGET_BOARD)/configs/linux.config. If you do not have one,
	$(Q)echo you will get an error shortly. You will then have to make one and update,
	$(Q)echo your buildroot configuration to use it.
	$(Q)echo
	$(Q)$(MAKE) $(BLRT_MAKEARGS) linux-update-defconfig

.PHONY: $(addsuffix -uboot-menuconfig,$(TARGET_BOARD))
$(addsuffix -uboot-menuconfig,$(TARGET_BOARD)): %-uboot-menuconfig: $(TARGET_BOARD)-configure
#	@if grep -q 'BR2_TARGET_UBOOT=y' $(BLRT_OOSB)/$(TARGET_BOARD)-build-artifacts/.config; then
	$(Q)$(call MESSAGE,"$(TARGET_BOARD) [Change the Bootloader configuration.] $*")
	$(Q)$(MAKE) $(BLRT_MAKEARGS) uboot-menuconfig
	$(Q)$(MAKE) $(BLRT_MAKEARGS) uboot-savedefconfig
	$(Q)echo
	$(Q)echo Going to update your board/$(TARGET_BOARD)/configs/uboot.config. If you do not have one,
	$(Q)echo you will get an error shortly. You will then have to make one and update,
	$(Q)echo your buildroot configuration to use it.
	$(Q)$(MAKE) $(BLRT_MAKEARGS) uboot-update-defconfig

#	else 
#		echo "--- (UBOOT not activated SKIPPING $@ ---" ;
#	fi

.PHONY: $(addsuffix -busybox-menuconfig,$(TARGET_BOARD))
$(addsuffix -busybox-menuconfig,$(TARGET_BOARD)): %-busybox-menuconfig: $(TARGET_BOARD)-configure
	$(Q)$(call MESSAGE,"$(TARGET_BOARD) [Change the Busybox configuration.] $*")
	$(Q)$(MAKE) $(BLRT_MAKEARGS) busybox-menuconfig
#	$(Q)$(MAKE) $(BLRT_MAKEARGS) busybox-savedefconfig
	$(Q)echo
	$(Q)echo Going to update your board/$(TARGET_BOARD)/configs/busybox.config. If you do not have one,
	$(Q)echo you will get an error shortly. You will then have to make one and update,
	$(Q)echo your buildroot configuration to use it.
	$(Q)echo
	$(Q)$(MAKE) $(BLRT_MAKEARGS) busybox-update-config
# ####################################################################################################
# #
# #    										package -> install -> deploy
# #
# ####################################################################################################

.PHONY: $(addsuffix -validate,$(TARGET_BOARD))
$(addsuffix -validate,$(TARGET_BOARD)): | $(TARGET_BOARD)-configure
	$(Q)$(call MESSAGE,"[ validate the project is correct and all necessary information is available.]")

.PHONY: $(addsuffix -initialize,$(TARGET_BOARD))
$(addsuffix -initialize,$(TARGET_BOARD)): | $(addsuffix -validate,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"[ initialize build state, e.g. set properties or create directories.]")

.PHONY: $(addsuffix -generate-sources,$(TARGET_BOARD))
$(addsuffix -generate-sources,$(TARGET_BOARD)): | $(addsuffix -initialize,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"[ generate any source code for inclusion in compilation.]")

.PHONY: $(addsuffix -process-sources,$(TARGET_BOARD))
$(addsuffix -process-sources,$(TARGET_BOARD)): | $(addsuffix -generate-sources,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"[ process the source code, for example to filter any values.]")

.PHONY: $(addsuffix -generate-resources,$(TARGET_BOARD))
$(addsuffix -generate-resources,$(TARGET_BOARD)): | $(addsuffix -process-sources,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"[ generate resources for inclusion in the package.]")

.PHONY: $(addsuffix -process-resources,$(TARGET_BOARD))
$(addsuffix -process-resources,$(TARGET_BOARD)): | $(addsuffix -generate-resources,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"[ copy and process the resources into the destination directory, ready for packaging.]")

.PHONY: $(addsuffix -compile,$(TARGET_BOARD))
$(addsuffix -compile,$(TARGET_BOARD)): | $(addsuffix -process-resources,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"[ compile the source code of the project.]")
	$(Q)$(MAKE) $(BLRT_MAKEARGS)

.PHONY: $(addsuffix -process-classes,$(TARGET_BOARD))
$(addsuffix -process-classes,$(TARGET_BOARD)): | $(addsuffix -compile,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"[ post-process the generated files from compilation, for example to do bytecode enhancement on Java classes.]")

.PHONY: $(addsuffix -generate-test-sources,$(TARGET_BOARD))
$(addsuffix -generate-test-sources,$(TARGET_BOARD)): | $(addsuffix -process-classes,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"[ generate any test source code for inclusion in compilation.]")

.PHONY: $(addsuffix -process-test-sources,$(TARGET_BOARD))
$(addsuffix -process-test-sources,$(TARGET_BOARD)): | $(addsuffix -generate-test-sources,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"[ process the test source code, for example to filter any values.]")

.PHONY: $(addsuffix -generate-test-resources,$(TARGET_BOARD))
$(addsuffix -generate-test-resources,$(TARGET_BOARD)): | $(addsuffix -process-test-sources,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"[ create resources for testing.]")

.PHONY: $(addsuffix -process-test-resources,$(TARGET_BOARD))
$(addsuffix -process-test-resources,$(TARGET_BOARD)): | $(addsuffix -generate-test-resources,$(TARGET_BOARD))	
	$(Q)$(call MESSAGE,"[ copy and process the resources into the test destination directory.]")

.PHONY: $(addsuffix -test-compile,$(TARGET_BOARD))
$(addsuffix -test-compile,$(TARGET_BOARD)):	| $(addsuffix -process-test-resources,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"[ compile the test source code into the test destination directory.]")

.PHONY: $(addsuffix -process-test-classes,$(TARGET_BOARD))
$(addsuffix -process-test-classes,$(TARGET_BOARD)):	| $(addsuffix -test-compile,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"[ post-process the generated files from test compilation, for example to do bytecode enhancement on Java classes.]")

.PHONY: $(addsuffix -test,$(TARGET_BOARD))
$(addsuffix -test,$(TARGET_BOARD)):	| $(addsuffix -process-test-classes,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"[ run tests using a suitable unit testing framework. These tests should not require the code be packaged or deployed.]")

.PHONY: $(addsuffix -prepare-package,$(TARGET_BOARD))
$(addsuffix -prepare-package,$(TARGET_BOARD)): | $(addsuffix -test,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"[ Perform any operations necessary to prepare a package before the actual packaging. This often results in an unpacked, processed version of the package.]")

.PHONY: $(addsuffix -package,$(TARGET_BOARD))
$(addsuffix -package,$(TARGET_BOARD)): | $(addsuffix -prepare-package,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"[ take the compiled code and package it in its distributable format, such as a JAR.]")

.PHONY: $(addsuffix -pre-integration-test,$(TARGET_BOARD))
$(addsuffix -pre-integration-test,$(TARGET_BOARD)): | $(addsuffix -package,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"[ perform actions required before integration tests are executed. This may involve things such as setting up the required environment.]")

.PHONY: $(addsuffix -integration-test,$(TARGET_BOARD))
$(addsuffix -integration-test,$(TARGET_BOARD)): | $(addsuffix -pre-integration-test,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"[ process and deploy the package if necessary into an environment where integration tests can be run.]")

.PHONY: $(addsuffix -post-integration-test,$(TARGET_BOARD))
$(addsuffix -post-integration-test,$(TARGET_BOARD)): | $(addsuffix -integration-test,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"[ perform actions required after integration tests have been executed. This may including cleaning up the environment.]")

.PHONY: $(addsuffix -verify,$(TARGET_BOARD))
$(addsuffix -verify,$(TARGET_BOARD)): | $(addsuffix -post-integration-test,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"[ Run any checks to verify the package is v`alid and meets quality criteria.]")

.PHONY: $(addsuffix -install,$(TARGET_BOARD))
$(addsuffix -install,$(TARGET_BOARD)): | $(addsuffix -verify,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"[ Install the package into the local repository, for use as a dependency in other projects locally.]")

.PHONY: $(addsuffix -deploy,$(TARGET_BOARD))
$(addsuffix -deploy,$(TARGET_BOARD)): | $(addsuffix -install,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"[ Done in an integration or release environment, copies the final package to the remote repository for sharing with other developers and projects.]")

# ####################################################################################################
# #
# #    										coverage
# #
# ####################################################################################################

.PHONY: $(addsuffix -coverage,$(TARGET_BOARD))
$(addsuffix -coverage,$(TARGET_BOARD)): $(addsuffix -process-resources,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"[ compile the source code of the project.]")

.PHONY: $(addsuffix -test-coverage,$(TARGET_BOARD))
$(addsuffix -test-coverage,$(TARGET_BOARD)): $(addsuffix -coverage,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"[ Done in an integration or release environment, copies the final package to the remote repository for sharing with other developers and projects.]")

# ####################################################################################################
# #
# #    								package -> install -> deploy
# #
# ####################################################################################################

# ####################################################################################################
# #
# #    								pre-site -> site -> post-site -> site-deploy
# #
# ####################################################################################################
.PHONY: $(addsuffix -pre-site,$(TARGET_BOARD))
$(addsuffix -pre-site,$(TARGET_BOARD)):
	$(Q)$(call MESSAGE,"[ Execute processes needed prior to the actual project site generation.]")

.PHONY: $(addsuffix -site,$(TARGET_BOARD))
$(addsuffix -site,$(TARGET_BOARD)):
	$(Q)$(call MESSAGE,"[ generate the project's site documentation.]")

.PHONY: $(addsuffix -post-site,$(TARGET_BOARD))
$(addsuffix -post-site,$(TARGET_BOARD)):
	$(Q)$(call MESSAGE,"[ Execute processes needed to finalize the site generation, and to prepare for site deployment.]")

.PHONY: $(addsuffix -site-deploy,$(TARGET_BOARD))
$(addsuffix -site-deploy,$(TARGET_BOARD)):
	$(Q)$(call MESSAGE,"[ deploy the generated site documentation to the specified web server documentation.]")

# ####################################################################################################
# #
# #    										pre-clean -> clean -> post-clean 
# #
# ####################################################################################################
.PHONY: $(addsuffix -pre-clean,$(TARGET_BOARD))
$(addsuffix -pre-clean,$(TARGET_BOARD)):
	$(Q)$(call MESSAGE,"[ Execute processes needed prior to the actual project cleaning.]")

.PHONY: $(addsuffix -clean,$(TARGET_BOARD))
$(addsuffix -clean,$(TARGET_BOARD)): | $(addsuffix -pre-clean,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"[ Remove all files generated by the $(TARGET_BOARD)'s previous build.]")
	$(Q)$(MAKE) $(BLRT_MAKEARGS) clean

.PHONY: $(addsuffix -post-clean,$(TARGET_BOARD))
$(addsuffix -post-clean,$(TARGET_BOARD)): | $(addsuffix -clean,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"[ Execute processes needed to finalize the project cleaning.]")

.PHONY: $(addsuffix -distclean,$(TARGET_BOARD))
$(addsuffix -distclean,$(TARGET_BOARD)): |  $(addsuffix -post-clean,$(TARGET_BOARD))
	$(Q)$(call MESSAGE,"[ Delete all non-source files (including .config) of $(TARGET_BOARD)'s build]")
	$(Q)$(MAKE) $(BLRT_MAKEARGS) distclean

.PHONY: help
help:
	$(Q)echo
	$(Q)echo "  Version $$(git describe --always), Copyright (C) 2023 MSF "
	$(Q)echo
	$(Q)echo
	$(Q)echo "$(TERM_BOLD)Build Environment$(TERM_RESET)"
	$(Q)echo
	$(Q)echo
	$(Q)echo "$(TERM_UNDERLINE)Supported targets:$(TERM_NOUNDERLINE)"
	$(Q)echo
	$(Q)$(foreach b, $(sort $(notdir $(patsubst %_defconfig,%,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))), \
		printf "  	%-30s - Build configuration for %s\\n" $(b) $(b:_defconfig=); \
	)
	$(Q)echo