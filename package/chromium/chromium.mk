###############################################################################
#
# Chromium
#
###############################################################################

CHROMIUM_VERSION = 66.0.3359.181
CHROMIUM_SITE = https://commondatastorage.googleapis.com/chromium-browser-official
CHROMIUM_SOURCE = chromium-$(CHROMIUM_VERSION).tar.xz
CHROMIUM_LICENSE = BSD-Style
CHROMIUM_LICENSE_FILES = LICENSE
CHROMIUM_DEPENDENCIES = host-python host-clang host-nodejs host-ninja libnss dbus alsa-lib pciutils xlib_libXScrnSaver libkrb5 cups libglib2 \
			zlib jpeg libpng libdrm harfbuzz freetype

CHROMIUM_OPTS = \
	host_toolchain=\"//build/toolchain/linux/unbundle:host\" \
	custom_toolchain=\"//build/toolchain/linux/unbundle:host\" \
	v8_snapshot_toolchain=\"//build/toolchain/linux/unbundle:host\" \
	clang_use_chrome_plugins=false \
	treat_warnings_as_errors=false \
	use_gnome_keyring=false \
	linux_use_bundled_binutils=false \
	use_sysroot=false \
	use_custom_libcxx=false \
	enable_nacl=false \
	use_dbus=true \
	use_cups=true \
	use_system_zlib=true \
	use_system_libjpeg=true \
	use_system_libpng=true \
	use_system_libdrm=true \
	use_system_harfbuzz=true \
	use_system_freetype=true

# tcmalloc has portability issues
CHROMIUM_OPTS += use_allocator=\"none\" \

ifeq ($(BR2_ENABLE_DEBUG),y)
	CHROMIUM_OPTS += is_debug=true
else
	CHROMIUM_OPTS += is_debug=false
endif

ifeq ($(BR2_PACKAGE_PULSEAUDIO),y)
	CHROMIUM_DEPENDENCIES += pulseaudio
	CHROMIUM_OPTS += use_pulseaudio=true
else
	CHROMIUM_OPTS += use_pulseaudio=false
endif

ifeq ($(BR2_PACKAGE_LIBGTK3),y)
	CHROMIUM_DEPENDENCIES += libgtk3
	CHROMIUM_OPTS += use_gtk3=true
else
	CHROMIUM_OPTS += use_gtk3=false
endif

CHROMIUM_MAKE_ENV += \
	PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)" \
	PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig"

define CHROMIUM_CONFIGURE_CMDS
	mkdir -p $(@D)/third_party/node/linux/node-linux-x64/bin
	ln -sf $(HOST_DIR)/bin/node $(@D)/third_party/node/linux/node-linux-x64/bin/
	ln -sf $(HOST_DIR)/bin/llvm-link $(HOST_DIR)/bin/lld

	( cd $(@D); \
		$(TARGET_MAKE_ENV) \
		$(HOST_DIR)/bin/python2 tools/gn/bootstrap/bootstrap.py -s --no-clean; \
		CC="$(HOSTCC)" \
		CXX=$(HOSTCXX) \
		CFLAGS="$(HOST_CFLAGS)" \
		BUILD_AR="ar" \
		BUILD_NM="nm" \
		CXXFLAGS="$(HOST_CXXFLAGS)" \
		BUILD_CC="$(HOST_DIR)/usr/bin/clang" \
		BUILD_CXX="$(HOST_DIR)/usr/bin/clang++" \
		out/Release/gn gen out/Release --args="$(CHROMIUM_OPTS)" \
			--script-executable=$(HOST_DIR)/bin/python2 \
	)
endef

define CHROMIUM_BUILD_CMDS
	( cd $(@D); \
		PATH="$(PATH):$(HOST_DIR)/bin/" \
		ninja -j$(PARALLEL_JOBS) -C out/Release chrome chrome_sandbox chromedriver \
	)
endef

define CHROMIUM_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(@D)/out/Release/chrome $(TARGET_DIR)/usr/lib/chromium/chromium
	$(INSTALL) -Dm4755 $(@D)/out/Release/chrome_sandbox \
		$(TARGET_DIR)/usr/lib/chromium/chrome-sandbox
	cp $(@D)/out/Release/{chrome_{100,200}_percent,resources}.pak \
		$(@D)/out/Release/{*.bin,chromedriver} \
		$(TARGET_DIR)/usr/lib/chromium/
	$(INSTALL) -Dm644 -t $(TARGET_DIR)/usr/lib/chromium/locales \
		$(@D)/out/Release/locales/*.pak
	cp $(@D)/out/Release/icudtl.dat $(TARGET_DIR)/usr/lib/chromium/	
endef

$(eval $(generic-package))
