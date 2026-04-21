#
# This software is licensed under the Public Domain.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=qtcm
PKG_VERSION:=1.0.0
PKG_RELEASE:=$(AUTORELEASE)

PKG_MAINTAINER:=Shiva Aradi <developer.aradi@gmail.com>
PKG_LICENSE:=GNU GENERAL PUBLIC LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/qtcm
	CATEGORY:=openwrt package
	SUBMENU:=Utils
	# Select package by default
	DEFAULT:=y
	TITLE:=Quectel QTCM application
	URL:=https://www.openwrt.com
endef

define Package/qtcm/description
	QTCM application for 4G/5G.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Package/qtcm/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/qtcm $(1)/etc/config/qtcm

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/qtcm $(1)/etc/init.d/qtcm

	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/quectel-CM $(1)/sbin/
endef

$(eval $(call BuildPackage,qtcm))
