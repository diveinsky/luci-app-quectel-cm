include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/package.mk

PKG_NAME:=diagagent
PKG_VERSION:=1.0.0
PKG_RELEASE:=$(AUTORELEASE)

PKG_LICENSE:=GPL-2.0-only
PKG_MAINTAINER:=OpenWrt Diagnostic Agent <noreply@example.com>

define Package/$(PKG_NAME)
	CATEGORY:=Utilities
	SUBMENU:=utils
	DEFAULT:=y
	TITLE:=Diagnostic Agent for boot, storage, wifi, network and runtime checks
	DEPENDS:=+rpcd +ubus +lua +lua-cjson
	MAINTAINER:=OpenWrt Diagnostic Agent <noreply@example.com>
endef

define Package/$(PKG_NAME)/description
	Command-line package providing boot and overlay health diagnostics in JSON format.
endef

define Build/Prepare
	true
endef

define Build/Compile
	true
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./root/usr/bin/diagagent_json.sh $(1)/usr/bin/
	$(INSTALL_BIN) ./root/usr/bin/diagagent $(1)/usr/bin/
	$(INSTALL_BIN) ./root/usr/bin/diag_lib.sh $(1)/usr/bin/
	$(INSTALL_BIN) ./root/usr/bin/diag_boot_json.sh $(1)/usr/bin/
	$(INSTALL_BIN) ./root/usr/bin/diag_storage_json.sh $(1)/usr/bin/
	$(INSTALL_BIN) ./root/usr/bin/diag_wifi_json.sh $(1)/usr/bin/
	$(INSTALL_BIN) ./root/usr/bin/diag_network_json.sh $(1)/usr/bin/
	$(INSTALL_BIN) ./root/usr/bin/diag_runtime_json.sh $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/usr/lib/lua/rpcd
	$(INSTALL_DATA) ./root/usr/lib/lua/rpcd/diagagent.lua $(1)/usr/lib/lua/rpcd/

	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) ./root/usr/share/rpcd/acl.d/diagagent.json $(1)/usr/share/rpcd/acl.d/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
