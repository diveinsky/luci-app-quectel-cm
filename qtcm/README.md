	$ make menuconfig
		OpenWrt packages  --->

			Kernel Modules  --->
				< > kmod-qmi-wwan-q

			Utils  --->
				< > Quectel-CM 


Build

For example:

	$ make package/qtcm/qmi-wwan-q/{clean,prepare,compile} V=s
