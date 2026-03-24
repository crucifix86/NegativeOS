################################################################################
# negativeos-base — meta-package pulling in the full NegativeOS default install
################################################################################

NEGATIVEOS_BASE_VERSION = 1.0
NEGATIVEOS_BASE_SITE =
NEGATIVEOS_BASE_LICENSE = MIT

# Dependencies — everything that makes NegativeOS, NegativeOS
NEGATIVEOS_BASE_DEPENDENCIES = \
    busybox \
    runit \
    xorg7 \
    icewm \
    slim \
    pcmanfm \
    rxvt-unicode \
    mousepad \
    gpicview \
    xarchiver \
    palemoon \
    networkmanager \
    avahi \
    pipewire \
    linux-firmware \
    ndiswrapper \
    apk-tools

$(eval $(generic-package))
