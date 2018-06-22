################################################################################
#
# Chromium
#
################################################################################

CHROMIUM_VERSION = 67.0.3396.79
CHROMIUM_SITE = https://commondatastorage.googleapis.com/chromium-browser-official
CHROMIUM_SOURCE = chromium-$(CHROMIUM_VERSION).tar.xz
CHROMIUM_LICENSE = BSD-Style
CHROMIUM_LICENSE_FILES = LICENSE
CHROMIUM_DEPENDENCIES = alsa-lib cairo cups dbus freetype harfbuzz \
			host-clang host-lld host-ninja host-nodejs host-python \
			jpeg libdrm libglib2 libkrb5 libnss libpng pango \
			xlib_libXcomposite xlib_libXScrnSaver xlib_libXcursor \
			xlib_libXrandr zlib

CHROMIUM_TOOLCHAIN_CONFIG_PATH = $(shell pwd)/package/chromium/toolchain

CHROMIUM_OPTS = \
	host_toolchain=\"$(CHROMIUM_TOOLCHAIN_CONFIG_PATH):host\" \
	custom_toolchain=\"$(CHROMIUM_TOOLCHAIN_CONFIG_PATH):target\" \
	use_lld=true \
	is_clang=true \
	clang_use_chrome_plugins=false \
	treat_warnings_as_errors=false \
	use_gnome_keyring=false \
	linux_use_bundled_binutils=false \
	use_sysroot=true \
	target_sysroot=\"$(STAGING_DIR)\" \
	target_cpu=\"$(BR2_PACKAGE_CHROMIUM_TARGET_ARCH)\" \
	enable_nacl=false \
	use_dbus=true \
	use_system_zlib=true \
	use_system_libjpeg=true \
	use_system_libpng=true \
	use_system_libdrm=true \
	use_system_harfbuzz=true \
	use_system_freetype=true

# tcmalloc has portability issues
CHROMIUM_OPTS += use_allocator=\"none\"

# V8 snapshots require compiling V8 with the same word size as the target
# architecture, which means the host needs to have that toolchain available.
CHROMIUM_OPTS += v8_use_snapshot=false

ifeq ($(BR2_ENABLE_DEBUG),y)
CHROMIUM_OPTS += is_debug=true
else
CHROMIUM_OPTS += is_debug=false
endif

ifeq ($(BR2_PACKAGE_CUPS),y)
CHROMIUM_DEPENDENCIES += cups
CHROMIUM_OPTS += use_cups=true
else
CHROMIUM_OPTS += use_cups=false
endif

ifeq ($(BR2_PACKAGE_CHROMIUM_PROPRIETARY_CODECS),y)
CHROMIUM_OPTS += proprietary_codecs=true ffmpeg_branding=\"Chrome\"
endif

ifeq ($(BR2_PACKAGE_DBUS),y)
CHROMIUM_OPTS += use_dbus=true
else
CHROMIUM_OPTS += use_dbus=false
endif

ifeq ($(BR2_PACKAGE_PCIUTILS),y)
CHROMIUM_DEPENDENCIES += pciutils
CHROMIUM_OPTS += use_libpci=true
else
CHROMIUM_OPTS += use_libpci=false
endif

ifeq ($(BR2_PACKAGE_PULSEAUDIO),y)
CHROMIUM_DEPENDENCIES += pulseaudio
CHROMIUM_OPTS += use_pulseaudio=true
else
CHROMIUM_OPTS += use_pulseaudio=false
endif

ifeq ($(BR2_PACKAGE_LIBGTK3_X11),y)
CHROMIUM_DEPENDENCIES += libgtk3
CHROMIUM_OPTS += use_gtk3=true
else
CHROMIUM_DEPENDENCIES += libgtk2 xlib_libXi xlib_libXtst
CHROMIUM_OPTS += use_gtk3=false
endif

ifeq ($(BR2_TOOLCHAIN_EXTERNAL),y)
CHROMIUM_TARGET_LDFLAGS += --gcc-toolchain=$(TOOLCHAIN_EXTERNAL_INSTALL_DIR)
else
CHROMIUM_TARGET_LDFLAGS += --gcc-toolchain=$(HOST_DIR)
endif

CHROMIUM_TARGET_CFLAGS += $(CHROMIUM_TARGET_LDFLAGS)
CHROMIUM_TARGET_CXXFLAGS += $(CHROMIUM_TARGET_CFLAGS)

define CHROMIUM_CONFIGURE_CMDS
	mkdir -p $(@D)/third_party/node/linux/node-linux-x64/bin
	ln -sf $(HOST_DIR)/bin/node $(@D)/third_party/node/linux/node-linux-x64/bin/

	( cd $(@D); \
		$(TARGET_MAKE_ENV) \
		$(HOST_DIR)/bin/python2 tools/gn/bootstrap/bootstrap.py -s --no-clean; \
		HOST_AR="$(HOSTAR)" \
		HOST_NM="$(HOSTNM)" \
		HOST_CC="$(HOSTCC)" \
		HOST_CXX="$(HOSTCXX)" \
		HOST_CFLAGS="$(HOST_CFLAGS)" \
		HOST_CXXFLAGS="$(HOST_CXXFLAGS)" \
		TARGET_AR="ar" \
		TARGET_NM="nm" \
		TARGET_CC="clang" \
		TARGET_CXX="clang++" \
		TARGET_CFLAGS="$(CHROMIUM_TARGET_CFLAGS)" \
		TARGET_CXXFLAGS="$(CHROMIUM_TARGET_CXXFLAGS)" \
		TARGET_LDFLAGS="$(CHROMIUM_TARGET_LDFLAGS)" \
		out/Release/gn gen out/Release --args="$(CHROMIUM_OPTS)" \
			--script-executable=$(HOST_DIR)/bin/python2 \
	)
endef

define CHROMIUM_BUILD_CMDS
	( cd $(@D); \
		$(TARGET_MAKE_ENV) \
		ninja -j$(PARALLEL_JOBS) -C out/Release chrome chrome_sandbox chromedriver \
	)
endef

define CHROMIUM_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(@D)/out/Release/chrome $(TARGET_DIR)/usr/lib/chromium/chromium
	$(INSTALL) -Dm4755 $(@D)/out/Release/chrome_sandbox \
		$(TARGET_DIR)/usr/lib/chromium/chrome-sandbox
	cp $(@D)/out/Release/{chrome_{100,200}_percent,resources}.pak \
		$(@D)/out/Release/chromedriver \
		$(TARGET_DIR)/usr/lib/chromium/
	$(INSTALL) -Dm644 -t $(TARGET_DIR)/usr/lib/chromium/locales \
		$(@D)/out/Release/locales/*.pak
	cp $(@D)/out/Release/icudtl.dat $(TARGET_DIR)/usr/lib/chromium/
endef

$(eval $(generic-package))
