include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=qtcm
PKG_VERSION:=1.0.0
PKG_RELEASE:=$(AUTORELEASE)

PKG_MAINTAINER:=Shiva Aradi <developer.aradi@gmail.com>
PKG_LICENSE:=GNU GENERAL PUBLIC LICENSE

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

define KernelPackage/qtcm-kernel
  SUBMENU:=USB Support
  TITLE:=Quectel QMI WWAN driver 
  FILES:=$(PKG_BUILD_DIR)/qmi-wwan-q/src/qmi_wwan_q.ko
  AUTOLOAD:=$(call AutoLoad,50,qmi_wwan_q)
  DEPENDS:=@USB_SUPPORT +kmod-usb-core +kmod-usb-net +kmod-usb-wdm
endef

define KernelPackage/qtcm-kernel/description
  Quectel QMI WWAN driver for USB modems
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./quectel-CM/src/* $(PKG_BUILD_DIR)/
	$(INSTALL_DIR) $(PKG_BUILD_DIR)/qmi-wwan-q/src
	$(CP) ./qmi-wwan-q/src/* $(PKG_BUILD_DIR)/qmi-wwan-q/src/
endef

define Build/Configure
	(cd $(PKG_BUILD_DIR); \
		autoreconf -fiv; \
		./configure \
			--target=$(GNU_TARGET_NAME) \
			--host=$(GNU_TARGET_NAME) \
			--build=$(GNU_HOST_NAME) \
			--program-prefix="" \
			--program-suffix="" \
			--prefix=/usr \
			--exec-prefix=/usr \
			--bindir=/usr/bin \
			--datadir=/usr/share \
			--includedir=/usr/include \
			--infodir=/usr/share/info \
			--libdir=/usr/lib \
			--libexecdir=/usr/lib \
			--localstatedir=/var \
			--mandir=/usr/share/man \
			--sbindir=/usr/sbin \
			--sysconfdir=/etc \
			$(DISABLE_NLS) \
			$(DISABLE_LARGEFILE) \
	);
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)"
	$(KERNEL_MAKE) M=$(PKG_BUILD_DIR)/qmi-wwan-q/src modules
endef

define Package/qtcm/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./quectel-CM/files/etc/config/qtcm $(1)/etc/config/qtcm

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./quectel-CM/files/etc/init.d/qtcm $(1)/etc/init.d/qtcm

	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/quectel-CM $(1)/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/quectel-qmi-proxy $(1)/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/quectel-mbim-proxy $(1)/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/quectel-atc-proxy $(1)/sbin/
endef

$(eval $(call BuildPackage,qtcm))
$(eval $(call KernelPackage,qtcm-kernel))
