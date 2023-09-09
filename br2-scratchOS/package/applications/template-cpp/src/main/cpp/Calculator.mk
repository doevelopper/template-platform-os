HELLO_WORLD_VERSION = 0.0.1
HELLO_WORLD_SITE = $(BR2_EXTERNAL_MSF_EMS_DHS_PATH)/packages/applications/template-cpp/src/main/c/msf/ems/dhs/msf/ems/dhs
HELLO_WORLD_SITE_METHOD = local
HELLO_WORLD_INSTALL_STAGING = NO
HELLO_LICENSE = GPL-2.0+
HELLO_LICENSE_FILES = COPYING

HELLO_CONF_ENV = CXXFLAGS="$(TARGET_CXXFLAGS) -fPIC -std=c++17 -std=c17"

LIBCEC_INSTALL_STAGING = YES
LIBCEC_DEPENDENCIES = host-pkgconf libplatform

ifeq ($(BR2_PACKAGE_HAS_UDEV),y)
	HELLO_DEPENDENCIES += udev
endif


ifeq ($(BR2_PACKAGE_RPI_USERLAND),y)
LIBCEC_DEPENDENCIES += rpi-userland
LIBCEC_CONF_OPTS += \
	-DCMAKE_C_FLAGS="$(TARGET_CFLAGS) -lvcos -lvchiq_arm" \
	-DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) \
		-I$(STAGING_DIR)/usr/include/interface/vmcs_host/linux \
		-I$(STAGING_DIR)/usr/include/interface/vcos/pthreads"
endif

LIBCEC_CONF_OPTS += -DHAVE_GIT_BIN="" \
	-DHAVE_WHOAMI_BIN="" \
	-DHAVE_HOSTNAME_BIN="" \
	-DHAVE_UNAME_BIN=""

ifeq ($(BR2_PACKAGE_ZLIB),y)
	HELLO_CONF_OPTS += --with-compression
	HELLO_DEPENDENCIES += zlib
else
	HELLO_CONF_OPTS += --without-compression
endif

# define HELLO_WORLD_BUILD_CMDS
# 	$(MAKE) CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D) all
# endef

# define HELLO_WORLD_INSTALL_TARGET_CMDS
# 	$(INSTALL) -D -m 0755 $(@D)/Calculator $(TARGET_DIR)/usr/lib
# endef

# $(eval $(generic-package))