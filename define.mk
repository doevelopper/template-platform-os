
qstrip                  = 	$(strip $(subst ",,$(1)))
MESSAGE                 =   echo "$(shell date +%Y-%m-%dT%H:%M:%S) $(TERM_BOLD)\#\#\#\#\#\#  $(call qstrip,$(1)) \#\#\#\#\#\# $(TERM_RESET)"
TERM_BOLD               :=  $(shell tput smso 2>/dev/null)
TERM_RESET              :=  $(shell tput rmso 2>/dev/null)
TERM_UNDERLINE 			:=  $(shell tput smul 2>/dev/null)
TERM_NOUNDERLINE		:=  $(shell tput rmul 2>/dev/null)
FULL_OUTPUT             ?= 	/dev/null

SHELL            		=  bash
AWK              		:= awk
CP               		:= cp
EGREP            		:= egrep
HTML_VIEWER      		:= cygstart
KILL             		:= /bin/kill
M4               		:= m4
MV               		:= mv
PDF_VIEWER       		:= cygstart
RM               		:= rm -f
MKDIR            		:= mkdir -p
LNDIR            		:= lndir
SED              		:= sed
SORT             		:= sort
TOUCH            		:= touch
XMLTO            		:= xmlto
XMLTO_FLAGS      		=  -o $(OUTPUT_DIR) $(XML_VERBOSE)
BISON 					:= $(shell which bison || type -p bison)
UNZIP 					:= $(shell which unzip || type -p unzip) -q

# Check if verbosity is ON for build process
CMD_PREFIX_DEFAULT 		:= @

ifeq ($(V), 1)
	Q :=
else
	Q := $(CMD_PREFIX_DEFAULT)
endif

print-help-run 			= 	printf "  	%-30s - %s\\n" "$1" "$2"
print-help 				= 	$(Q)$(call print-help-run,$1,$2)

BLRT_VERSION       		= 	2023.08
BLRT_EXT           		=   br2-scratchOS
DEFCONFIG_DIR			=   $(BLRT_EXT)/configs
DEFCONFIG_DIR_FULL		=   $(PWD)/$(BLRT_EXT)/configs
DATE					:=  $(shell date +%Y.%m.%d-%H%M%S --utc)

## out of source build
BLRT_OOSB               =   $(PWD)/workspace
BLRT_ARTIFACTS_DIR      =   $(BLRT_OOSB)/artifacts/$(TARGET_BOARD)
BLRT_DL_DIR				=	$(BLRT_OOSB)/download
BLRT_CCACHE_DIR			=   $(BLRT_OOSB)/.buildroot-ccache
BLRT_DIR                =   $(BLRT_OOSB)/buildroot-$(BLRT_VERSION)

SUPPORTED_TARGETS       :=  $(sort $(notdir $(patsubst %_defconfig,%,$(wildcard $(DEFCONFIG_DIR)/*_defconfig))))
TARGETS_CONFIG 			:= 	$(notdir $(patsubst %_defconfig,%-configure,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
TARGETS_CONFIG_COMPILE	:= 	$(notdir $(patsubst %_defconfig,%-compile,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
TARGETS_CONFIG_TEST 	:= 	$(notdir $(patsubst %_defconfig,%-unit-test,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
TARGETS_CONFIG_ITEST 	:= 	$(notdir $(patsubst %_defconfig,%-integration-test,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
TARGETS_CONFIG_REL		:= 	$(notdir $(patsubst %_defconfig,%-release,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
BLRT_CONFIG				:= 	$(notdir $(patsubst %_defconfig,%-menuconfig,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
LINUX_CONFIG			:= 	$(notdir $(patsubst %_defconfig,%-linux-menuconfig,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
UBOOT_CONFIG			:= 	$(notdir $(patsubst %_defconfig,%-uboot-menuconfig,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
BUSYBOX_CONFIG			:= 	$(notdir $(patsubst %_defconfig,%-busybox-menuconfig,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
BR_SAVE_CONFIG			:= 	$(notdir $(patsubst %_defconfig,%-savedefconfig,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
REBUILD_LINUX_CFG 		:= 	$(notdir $(patsubst %_defconfig,%-linux-rebuild,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
REBUILD_UBOOT_CFG 		:= 	$(notdir $(patsubst %_defconfig,%-uboot-rebuild,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
REBUILD_BUSYBOX_CFG		:= 	$(notdir $(patsubst %_defconfig,%-busybox-rebuild,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))

BLRT_MAKEARGS			:= 	-C $(BLRT_DIR)
BLRT_MAKEARGS 			+= 	BR2_EXTERNAL=$(PWD)/$(BLRT_EXT)
BLRT_MAKEARGS 			+= 	BR2_DL_DIR=$(BLRT_DL_DIR)
BLRT_MAKEARGS 			+= 	BR2_CCACHE_DIR=$(BLRT_CCACHE_DIR)
#BLRT_MAKEARGS 			+= 	O=$(BLRT_OOSB)/$(TARGET_BOARD)-build-artifacts

VERSION_GIT_EPOCH 		:= 	$(shell $(GIT) log -1 --format=%at 2> /dev/null)

# Time steps
define step_time
	printf "%s:%-5.5s:%-20.20s: %s\n"           	\
	       "$$(date +%s.%N)" "$(1)" "$(2)" "$(3)"  	\
	       >>"$(BUILD_DIR)/build-time.log"
endef

word-dot 				= $(word $2,$(subst ., ,$1))
UC 						= $(shell echo '$1' | tr '[:lower:]' '[:upper:]')