MOD_NAME=bladeRF_mac80211_hwsim

ifneq ($(KERNELRELEASE),)
#################
# KBuild section
obj-m  := bladeRF_mac80211_hwsim.o
#
#################

else

#################
# Normal makefile
#
KERNEL_DIR := /lib/modules/$(shell uname -r)
KBUILD_DIR := $(KERNEL_DIR)/build
MOD_DIR    := $(KERNEL_DIR)/$(MOD_NAME)
CERTS_DIR  := $(KBUILD_DIR)/certs/

CERT_FILES := $(CERTS_DIR)/x509.genkey \
	$(CERTS_DIR)signing_key.x509 \
	$(CERTS_DIR)/signing_key.pem


default:
	$(MAKE) -C $(KBUILD_DIR) M=$$PWD

clean:
	$(MAKE) -C $(KBUILD_DIR) M=$$PWD clean

install: certs default 
	$(MAKE) MOD_NAME=$(MOD_NAME) -C $(KBUILD_DIR) M=$$PWD modules_install
	depmod -a
	install -v -D bladeRF_mac80211_hwsim.conf /etc/modprobe.d/bladeRF_mac80211_hwsim.conf

uninstall: 
	rm -rf /etc/modprobe.d/bladeRF_mac80211_hwsim.conf
	rm -rf /lib/modules/5.13.0-28-generic/bladeRF_mac80211_hwsim/bladeRF_mac80211_hwsim.ko

mod_list:
	-lsmod | grep 80211 

mod_info:
	-modinfo bladeRF_mac80211_hwsim

mod_load: mod_unload
	modprobe mac80211  
	modprobe cfg80211
	modprobe bladeRF_mac80211_hwsim

mod_unload:
	@lsmod | awk '{print $$1}' | grep 80211 | xargs -rt rmmod

certs: | $(CERT_FILES)

$(CERT_FILES) &: | x509.genkey
	install x509.genkey -D -v $(KBUILD_DIR)/certs/x509.genkey
	(
	cd $(CERTS_DIR) 
	sudo openssl req -new -nodes -utf8 -sha512 -days 36500 \
		-batch -x509 -config x509.genkey -outform DER \
		-out signing_key.x509 -keyout signing_key.pem
	)

#
#################

endif