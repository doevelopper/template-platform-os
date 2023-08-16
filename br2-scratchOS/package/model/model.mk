################################################################################
#
# model package
#
################################################################################

MODEL_VERSION = 1.0
MODEL_SITE = ./packages/model/src/main/cpp
MODEL_SITE_METHOD = local# Other methods like git,wget,scp,file etc. are also available.

define MODEL_BUILD_CMDS
	$(MAKE) CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)
endef

define MODEL_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/model  $(TARGET_DIR)/usr/bin
endef

$(eval $(generic-package))