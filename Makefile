MOD_NAME=bladeRF_mac80211_hwsim

ifneq ($(KERNELRELEASE),)
##
# KBuild section
obj-m  := mac80211_hwsim.o
#
##

else

##
# Normal makefile
KERNEL_DIR ?= /lib/modules/`uname -r`/
KBUILD_DIR ?= ${KERNEL_DIR}/build
MOD_DIR    ?= ${KERNEL_DIR}/${MOD_NAME}

default:
	$(MAKE) -C $(KBUILD_DIR) M=$$PWD

clean:
	$(MAKE) -C $(KBUILD_DIR) M=$$PWD clean

install: default
	$(MAKE) MOD_NAME=${MOD_NAME} -C $(KBUILD_DIR) M=$$PWD modules_install
	depmod -a
	install -v -D bladeRF_mac80211_hwsim.conf /etc/modprobe.d/bladeRF_mac80211_hwsim.conf

uninstall:
	rm -rf /etc/modprobe.d/bladeRF_mac80211_hwsim.conf
	rm -rf /lib/modules/5.13.0-28-generic/bladeRF_mac80211_hwsim/mac80211_hwsim.ko

mod_list:
	-lsmod | grep 80211 

mod_info:
	-modinfo bladeRF_mac80211_hwsim

mod_load: 
	-rmmod mac80211_hwsim
	-rmmod bladeRF_mac80211_hwsim
	modprobe mac80211  
	modprobe cfg80211
	modprobe bladeRF_mac80211_hwsim

mod_unload:
	@lsmod | awk '{print $$1}' | grep 80211 | xargs -rt rmmod

#
##

endif