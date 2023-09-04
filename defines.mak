qstrip                  = 	$(strip $(subst ",,$(1)))
MESSAGE                 =   echo "$(shell date +%Y-%m-%dT%H:%M:%S) $(TERM_BOLD)\#\#\#\#\#\#  $(call qstrip,$(1)) \#\#\#\#\#\# $(TERM_RESET)"
TERM_BOLD               :=  $(shell tput smso 2>/dev/null)
TERM_RESET              :=  $(shell tput rmso 2>/dev/null)
TERM_UNDERLINE 			:=  $(shell tput smul 2>/dev/null)
TERM_NOUNDERLINE		:=  $(shell tput rmul 2>/dev/null)
FULL_OUTPUT             ?= 	/dev/null

KERNEL_VERSION			=	6.4
RT_PATCH_VERSION		=	$KERNEL_VERSION.6-rt8
BLRT_GIT_URL       		= 	https://github.com/buildroot/buildroot.git
BLRT_VERSION       		= 	2023.08-rc2
BLRT_LATEST				=
#BLRT_EXT           		=   br2-tos
BLRT_EXT           		=   br2-scratchOS
DEFCONFIG_DIR			=   $(BLRT_EXT)/configs
DEFCONFIG_DIR_FULL		=   $(PWD)/$(BLRT_EXT)/configs
DATE					:=  $(shell date +%Y.%m.%d-%H%M%S --utc)
## out of source build
BLRT_OOSB               =   $(PWD)/workspace
BLRT_DL_DIR 			= 	$(BLRT_OOSB)/dl
BLRT_DL_DIR				=	$(BLRT_OOSB)/download
BLRT_CCACHE_DIR			=   $(BLRT_OOSB)/.buildroot-ccache
BLRT_DIR                =   $(BLRT_OOSB)/buildroot-$(BLRT_VERSION)

ifneq ($(TARGET_BOARD),)
       SUPPORTED_TARGETS       :=      $(TARGET_BOARD)
else
       TARGET_BOARD            :=      $(firstword $(SUPPORTED_TARGETS))
endif

SUPPORTED_TARGETS       :=  $(sort $(notdir $(patsubst %_defconfig,%,$(wildcard $(DEFCONFIG_DIR)/*_defconfig))))
TARGETS_CONFIG 			:= 	$(notdir $(patsubst %_defconfig,%-configure,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))
#  \
# 								$(notdir $(patsubst %_defconfig,%-compile,$(wildcard $(DEFCONFIG_DIR)/*_defconfig))) \
# 								$(notdir $(patsubst %_defconfig,%-unit-test,$(wildcard $(DEFCONFIG_DIR)/*_defconfig))) \
# 								$(notdir $(patsubst %_defconfig,%-integration-test,$(wildcard $(DEFCONFIG_DIR)/*_defconfig))) \
# 								$(notdir $(patsubst %_defconfig,%-menuconfig,$(wildcard $(DEFCONFIG_DIR)/*_defconfig))) \
# 								$(notdir $(patsubst %_defconfig,%-saveconfig,$(wildcard $(DEFCONFIG_DIR)/*_defconfig))) \
# 								$(notdir $(patsubst %_defconfig,%-linux-menuconfig,$(wildcard $(DEFCONFIG_DIR)/*_defconfig))) \
# 								$(notdir $(patsubst %_defconfig,%-uboot-menuconfig,$(wildcard $(DEFCONFIG_DIR)/*_defconfig))) \
# 								$(notdir $(patsubst %_defconfig,%-busybox-menuconfig,$(wildcard $(DEFCONFIG_DIR)/*_defconfig))) \
# 								$(notdir $(patsubst %_defconfig,%-relsease,$(wildcard $(DEFCONFIG_DIR)/*_defconfig)))

PARALLEL_JOBS 			:= 	$(shell getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)
ifneq ($(PARALLEL_JOBS),1)
#	PARALLEL_OPTS 		= 	-j$(PARALLEL_JOBS) -Orecurse
	PARALLEL_OPTS 		= 	-j$(PARALLEL_JOBS)
else
	PARALLEL_OPTS 		=
endif

BLRT_MAKEARGS			:= 	-C $(BLRT_DIR)
BLRT_MAKEARGS 			+= 	BR2_EXTERNAL=$(PWD)/$(BLRT_EXT)
BLRT_MAKEARGS 			+= 	BR2_DL_DIR=$(BLRT_DL_DIR)
BLRT_MAKEARGS 			+= 	BR2_CCACHE_DIR=$(BLRT_CCACHE_DIR)
BLRT_MAKEARGS 			+= 	O=$(BLRT_OOSB)/$(TARGET_BOARD)-build-artifacts

BLRT_ARTIFACTS_DIR      =   $(BLRT_OOSB)/artifacts/$(TARGET_BOARD)
BLRT_CMD				=  	$(MAKE) -C $(BLRT_DIR)
BLRT_CMD				+=	BR2_EXTERNAL=$(PWD)/$(BLRT_EXT) BR2_DL_DIR=$(BLRT_DL_DIR) BR2_CCACHE_DIR=$(BLRT_CCACHE_DIR)
BLRT_CMD				+=	O=$(BLRT_OOSB)/$(TARGET_BOARD)-build-artifacts

# Check if verbosity is ON for build process
CMD_PREFIX_DEFAULT 		:= @
ifeq ($(V), 1)
	Q 					:=
else
	Q 					:= $(CMD_PREFIX_DEFAULT)
endif

print-help-run 			= 	printf "  	%-30s - %s\\n" "$1" "$2"
print-help 				= 	$(Q)$(call print-help-run,$1,$2)

# MAKEFLAGS 				+= --no-print-directory

VERSION_GIT				=	$(shell if [ -d $(PWD)/.git ]; then git describe 2> /dev/null; fi)
BUILD_COMPILER_VERSION	=	$(shell $(CC) -v 2>&1 | grep ' version ' | sed 's/[[:space:]]*$$//')



# Kconfig helper macros

# Convenient variables
comma       			:= ,
quote       			:= "
squote      			:= '
empty       			:=
space       			:= $(empty) $(empty)
dollar      			:= $
right_paren 			:= )
left_paren  			:= (
space_escape 			:= _-_SPACE_-_
pound 					:= \#

# $(if-success,<command>,<then>,<else>)
# Return <then> if <command> exits with 0, <else> otherwise.
if-success 				= $(shell,{ $(1); } >/dev/null 2>&1 && echo "$(2)" || echo "$(3)")

# $(success,<command>)
# Return y if <command> exits with 0, n otherwise
success 				= $(if-success,$(1),y,n)

# $(cc-option,<flag>)
# Return y if the compiler supports <flag>, n otherwise
cc-option 				= $(success,$(CC) -Werror $(CLANG_FLAGS) $(1) -E -x c /dev/null -o /dev/null)

# $(ld-option,<flag>)
# Return y if the linker supports <flag>, n otherwise
ld-option 				= $(success,$(LD) -v $(1))

# try-run
# Usage: option = $(call try-run, $(CC)...-o "$$TMP",option-ok,otherwise)
# Exit code chooses option. "$$TMP" serves as a temporary file and is
# automatically cleaned up.
try-run 				= $(							\
							shell set -e;				\
							TMP="$(TMPOUT).$$$$.tmp";	\
							TMPO="$(TMPOUT).$$$$.o";	\
							if ($(1)) >/dev/null 2>&1;	\
								then echo "$(2)";		\
							else echo "$(3)";			\
							fi;							\
							rm -f "$$TMP" "$$TMPO"		\
						)