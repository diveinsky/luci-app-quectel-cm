#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=qmi-wwan-q
PKG_RELEASE:=1

PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define KernelPackage/qmi-wwan-q
  CATEGORY:=OpenWrt package
  SUBMENU:=Kernel Modules
  TITLE:= Quectel QMI WWAN driver 
  FILES:=$(PKG_BUILD_DIR)/qmi_wwan_q.ko
  AUTOLOAD:=$(call AutoLoad,qmi_wwan_q)
  KCONFIG:=
  DEPENDS:= @USB_SUPPORT +kmod-usb-core +kmod-usb-net +kmod-usb-wdm @TARGET_mediatek
  DEFAULT:=y
endef

define KernelPackage/qmi-wwan-q/description
  some stupid nonsense of openwrt 
endef

define Build/Compile
	 $(KERNEL_MAKE)	M=$(PKG_BUILD_DIR) modules
endef

$(eval $(call KernelPackage,qmi-wwan-q))
