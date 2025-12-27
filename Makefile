TARGET := iphone:clang:16.5:16.0
INSTALL_TARGET_PROCESSES = SpringBoard
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = HiddenAlbumToggle

HiddenAlbumToggle_FILES = Tweak.x
HiddenAlbumToggle_FRAMEWORKS = UIKit CoreFoundation
HiddenAlbumToggle_PRIVATE_FRAMEWORKS = ControlCenterUIKit
HiddenAlbumToggle_INSTALL_PATH = /Library/ControlCenter/Bundles
HiddenAlbumToggle_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

