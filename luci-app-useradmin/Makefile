include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-useradmin
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_LICENSE:=GPL-2.0-only
PKG_MAINTAINER:=OpenWrt User Admin <noreply@example.com>

LUCI_TITLE:=LuCI User Administration
LUCI_DEPENDS:=+luci-base +rpcd-mod-file +shadow-utils
LUCI_PKGARCH:=all

include $(TOPDIR)/feeds/luci/luci.mk

define Package/$(PKG_NAME)/description
	LuCI web interface for adding a LuCI login user and creating a system account with shell access disabled.
endef

define Package/$(PKG_NAME)/install
	$(CP) ./root/* $(1)/
	$(INSTALL_DIR) $(1)/www
	$(CP) ./htdocs/* $(1)/www/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
