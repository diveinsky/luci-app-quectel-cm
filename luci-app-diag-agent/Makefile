include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-diag-agent
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_LICENSE:=GPL-2.0-only
PKG_MAINTAINER:=OpenWrt Diagnostic Agent <noreply@example.com>

LUCI_TITLE:=LuCI Diagnostic Agent
LUCI_DEPENDS:=+luci-base +diagagent
LUCI_PKGARCH:=all

include $(TOPDIR)/feeds/luci/luci.mk

define Package/$(PKG_NAME)/description
	LuCI web interface for the diag-agent diagnostic collector.
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./root/usr/lib/lua/luci/controller/diag_agent.lua $(1)/usr/lib/lua/luci/controller/

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/diag_agent
	$(INSTALL_DATA) ./root/usr/lib/lua/luci/view/diag_agent/index.htm $(1)/usr/lib/lua/luci/view/diag_agent/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
