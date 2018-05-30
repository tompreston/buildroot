################################################################################
#
# at-spi2-core
#
################################################################################

AT_SPI2_CORE_VERSION_MAJOR = 2.28
AT_SPI2_CORE_VERSION = $(AT_SPI2_CORE_VERSION_MAJOR).0
AT_SPI2_CORE_SOURCE = at-spi2-core-$(AT_SPI2_CORE_VERSION).tar.xz
AT_SPI2_CORE_SITE = http://ftp.gnome.org/pub/gnome/sources/at-spi2-core/$(AT_SPI2_CORE_VERSION_MAJOR)
AT_SPI2_CORE_LICENSE = LGPL-2.0+
AT_SPI2_CORE_LICENSE_FILES = COPYING
AT_SPI2_CORE_INSTALL_STAGING = YES
AT_SPI2_CORE_DEPENDENCIES = host-meson host-pkgconf dbus libglib2 xlib_libXtst

AT_SPI2_CORE_MESON_OPTS += \
	--prefix=/usr \
	--libdir=/usr/lib \
	--sysconfdir=/etc \
	--buildtype=$(if $(BR2_ENABLE_DEBUG),debug,release) \
	--cross-file=$(HOST_DIR)/etc/meson/cross-compilation.conf

AT_SPI2_CORE_NINJA_OPTS = $(if $(VERBOSE),-v) -j$(PARALLEL_JOBS)

define AT_SPI2_CORE_CONFIGURE_CMDS
	rm -rf $(@D)/build
	mkdir -p $(@D)/build
	$(TARGET_MAKE_ENV) meson $(AT_SPI2_CORE_MESON_OPTS) $(@D) $(@D)/build
endef

define AT_SPI2_CORE_BUILD_CMDS
	$(TARGET_MAKE_ENV) ninja $(AT_SPI2_CORE_NINJA_OPTS) -C $(@D)/build
endef

define AT_SPI2_CORE_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) DESTDIR=$(STAGING_DIR) \
		ninja $(AT_SPI2_CORE_NINJA_OPTS) -C $(@D)/build install
endef

define AT_SPI2_CORE_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) DESTDIR=$(TARGET_DIR) \
		ninja $(AT_SPI2_CORE_NINJA_OPTS) -C $(@D)/build install
endef

$(eval $(generic-package))

