EMSCRIPTEN_VERSION = 1.38.11
EMSCRIPTEN_SITE = $(call github,emscripten,emscripten,$(EMSCRIPTEN_VERSION))
EMSCRIPTEN_DEPENDENCIES = clang llvm

$(eval $(host-generic-package))
