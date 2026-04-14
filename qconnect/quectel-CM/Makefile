#
# This software is licensed under the Public Domain.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=qconnect
PKG_VERSION:=1.0.0
PKG_RELEASE:=$(AUTORELEASE)

PKG_MAINTAINER:=Shiva Aradi <developer.aradi@gmail.com>
PKG_LICENSE:=GNU GENERAL PUBLIC LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/qconnect
	CATEGORY:=qcwrt package
	SUBMENU:=Utils
	# Select package by default
	DEFAULT:=y
	TITLE:=Quectel QConnect application
	URL:=https://www.openwrt.com
endef

define Package/qconnect/description
	Qconnect Application for 4G/5G.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Package/qconnect/install
	$(CP) ./files/* $(1)/

	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/quectel-CM $(1)/sbin/
endef

$(eval $(call BuildPackage,qconnect))
