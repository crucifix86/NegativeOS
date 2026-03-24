################################################################################
# Pale Moon Browser
# Official Linux binaries — swap for custom build when developing
################################################################################

PALEMOON_VERSION = 33.5.0
PALEMOON_LICENSE = MPL-2.0

# Architecture-specific source tarballs
ifeq ($(BR2_x86_64),y)
PALEMOON_ARCH = x86_64
else
PALEMOON_ARCH = i686
endif

PALEMOON_SOURCE = palemoon-$(PALEMOON_VERSION).linux-$(PALEMOON_ARCH).tar.xz

# Update this URL when a new release is published:
# Check: https://www.palemoon.org/download.shtml
PALEMOON_SITE = https://github.com/MoonchildProductions/Pale-Moon/releases/download/$(PALEMOON_VERSION)_Release

PALEMOON_INSTALL_STAGING = NO
PALEMOON_INSTALL_TARGET  = YES

define PALEMOON_INSTALL_TARGET_CMDS
    # Install browser to /opt/palemoon
    $(INSTALL) -d $(TARGET_DIR)/opt/palemoon
    cp -r $(@D)/palemoon/* $(TARGET_DIR)/opt/palemoon/

    # Symlink binary to PATH
    $(INSTALL) -d $(TARGET_DIR)/usr/bin
    ln -sf /opt/palemoon/palemoon $(TARGET_DIR)/usr/bin/palemoon

    # Desktop entry
    $(INSTALL) -D -m 0644 $(BR2_EXTERNAL_NEGATIVEOS_PATH)/package/palemoon/palemoon.desktop \
        $(TARGET_DIR)/usr/share/applications/palemoon.desktop

    # Set as x-www-browser alternative
    $(INSTALL) -d $(TARGET_DIR)/etc/alternatives
    ln -sf /usr/bin/palemoon $(TARGET_DIR)/etc/alternatives/x-www-browser
endef

$(eval $(generic-package))
