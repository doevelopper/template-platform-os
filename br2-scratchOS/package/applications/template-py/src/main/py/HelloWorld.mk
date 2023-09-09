################################################################################
#
# 
#
################################################################################

PYTHON_APP_VERSION = 0.01
PYTHON_APP_SOURCE = python-APP-$(PYTHON_APP_VERSION).tar.xz
PYTHON_APP_SOURCE = $(BR2_EXTERNAL_MSF_EMS_DHS_PATH)/packages/applications/template-c/src/main/c/msf/ems/dhs/msf/ems/dhs4
PYTHON_APP_SITE = local
PYTHON_APP_LICENSE = BSD-3-Clause
PYTHON_APP_LICENSE_FILES = COPYRIGHT.txt LICENSES.txt LICENSE
PYTHON_APP_CPE_ID_VENDOR = pytemplate
PYTHON_APP_SETUP_TYPE = setuptools
# PYTHON_APP_ENV = SOME_VAR=1
# PYTHON_APP_DEPENDENCIES = libmad
# PYTHON_APP_SETUP_TYPE = distutils

define PYTHON_APP_INSTALL_CONF_FILES
	$(INSTALL) -d -m 755 $(TARGET_DIR)/etc/supervisor.d
	$(INSTALL) -D -m 644 $(BR2_EXTERNAL_MSF_EMS_DHS_PATH)/packages/applications/template-py/src/main/resources/template-py.conf \
		$(TARGET_DIR)/etc/template-py.conf
endef

PYTHON_APP_POST_INSTALL_TARGET_HOOKS += PYTHON_APP_INSTALL_CONF_FILES

define PYTHON_APP_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 755 $(BR2_EXTERNAL_MSF_EMS_DHS_PATH)/packages/applications/template-py/src/main/resources/S99template-py \
		$(TARGET_DIR)/etc/init.d/S99template-py
endef

define PYTHON_APP_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 $(BR2_EXTERNAL_MSF_EMS_DHS_PATH)/packages/applications/template-py/src/main/resources/S99template-py.service \
		$(TARGET_DIR)/usr/lib/systemd/system/template-py.service
endef

$(eval $(python-package))
