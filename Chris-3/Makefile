# Makefile — Chris iOS App
# Builds Chris as a .ipa sideloadable with TrollStore or AltStore.
# Based on Nugget Mobile's Makefile by leminlimez.
#
# Requirements:
#   - Theos installed (https://theos.dev/docs/installation)
#   - run ./get_libraries.sh first
#   - Xcode command line tools

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = Chris

# ── Libraries ─────────────────────────────────────────────────────────────────

LIBRARY_NAME = libEMProxy libimobiledevice

# em_proxy — linked separately to avoid symbol conflicts with minimuxer
libEMProxy_FILES           = lib/empty.swift
libEMProxy_LDFLAGS         = -force_load lib/libem_proxy-ios.a \
                              -install_name @rpath/libEMProxy.dylib
libEMProxy_FRAMEWORKS      = Security
libEMProxy_INSTALL_PATH    = /Applications/$(APPLICATION_NAME).app/Frameworks

# libimobiledevice + minimuxer + SSL
libimobiledevice_FILES     = Chris/Restore/idevicebackup2.c
libimobiledevice_CFLAGS    = -Iinclude
libimobiledevice_LDFLAGS   = \
    -force_load lib/libimobiledevice-1.0.a    \
    -force_load lib/libimobiledevice-glue-1.0.a \
    -force_load lib/libplist-2.0.a            \
    -force_load lib/libusbmuxd-2.0.a          \
    -force_load lib/libcrypto.a               \
    -force_load lib/libssl.a                  \
    -force_load lib/libminimuxer-ios.a        \
    -Wl,-mllvm,--opaque-pointers             \
    -install_name @rpath/libimobiledevice.dylib
libimobiledevice_INSTALL_PATH = /Applications/$(APPLICATION_NAME).app/Frameworks

# ── App ───────────────────────────────────────────────────────────────────────

Chris_FILES = \
    Chris/ChrisApp.swift                       \
    Chris/Models/TweakModel.swift              \
    Chris/Models/TweakManager.swift            \
    Chris/Views/ContentView.swift              \
    Chris/Views/TweakListView.swift            \
    Chris/Restore/RestoreEngine.swift          \
    Chris/Restore/MinimuxerBridge.swift        \
    Chris/Restore/MobileGestaltPatcher.swift   \
    Chris/Helpers/ColorHelpers.swift           \
    include/minimuxer-helpers.swift            \
    include/minimuxer.swift                    \
    include/em_proxy.swift

Chris_CFLAGS              = -Iinclude
Chris_SWIFT_FLAGS         = -Iinclude
Chris_FRAMEWORKS          = UIKit SwiftUI Security
Chris_PRIVATE_FRAMEWORKS  =
Chris_LDFLAGS             = \
    -rpath @executable_path/Frameworks        \
    -framework SwiftUI

Chris_INSTALL_PATH        = /Applications
Chris_BUNDLE_ID           = com.yourname.chris

# ── Build flags ───────────────────────────────────────────────────────────────

ARCHS         = arm64
TARGET        = iphone:clang:16.0:14.0
THEOS_DEVICE_IP =

include $(THEOS_MAKE_PATH)/application.mk

# ── IPA packaging ─────────────────────────────────────────────────────────────

after-all::
	@echo "Packaging Chris.ipa..."
	@mkdir -p _ipa/Payload
	@cp -r $(THEOS_OBJ_DIR)/Chris.app _ipa/Payload/
	@cd _ipa && zip -r ../Chris.ipa Payload
	@rm -rf _ipa
	@echo "✅ Chris.ipa ready!"

clean::
	@rm -f Chris.ipa
