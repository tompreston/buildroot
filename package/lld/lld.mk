################################################################################
#
# lld
#
################################################################################

LLD_VERSION = 6.0.0
LLD_SITE = https://llvm.org/releases/$(LLD_VERSION)
LLD_SOURCE = lld-$(LLD_VERSION).src.tar.xz
LLD_LICENSE = NCSA
LLD_LICENSE_FILES = LICENSE.TXT
LLD_SUPPORTS_IN_SOURCE_BUILD = NO
HOST_LLD_DEPENDENCIES = host-llvm

$(eval $(host-cmake-package))
