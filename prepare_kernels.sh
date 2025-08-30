#!/usr/bin/env bash

apply_patches()
{
for patch_type in "base" "others" "chromeos" "all_devices" "surface_devices" "surface_go_devices" "surface_mwifiex_pcie_devices" "surface_np3_devices" "macbook"; do
	if [ -d "./kernel-patches/$1/$patch_type" ]; then
		for patch in ./kernel-patches/"$1/$patch_type"/*.patch; do
			echo "Applying patch: $patch"
			patch -d"./kernels/$1" -p1 --no-backup-if-mismatch -N < "$patch" || { echo "Kernel $1 patch failed"; exit 1; }
		done
	fi
done
}

make_config()
{
sed -i -z 's@# Detect buggy gcc and clang, fixed in gcc-11 clang-14.\n\tdef_bool@# Detect buggy gcc and clang, fixed in gcc-11 clang-14.\n\tdef_bool $(success,echo 0)\n\t#def_bool@g' ./kernels/$1/init/Kconfig
sed -i 's@#!/usr/bin/awk@#!/usr/bin/env -S awk@g' ./kernels/$1/scripts/ld-version.sh
echo "Creating $2 config for kernel $1"
sed '/CONFIG_ATH\|CONFIG_BUILD\|CONFIG_EXTRA_FIRMWARE\|CONFIG_DEBUG_INFO\|CONFIG_IWL\|CONFIG_LSM\|CONFIG_MODULE_COMPRESS/d' ./kernel-patches/flex_configs > ./kernels/$1/arch/x86/configs/chromeos_defconfig || { echo "Kernel $1 configuration failed"; exit 1; }
if [ "$2" == "generic" ]; then
	make -C ./kernels/$1 O=out allmodconfig || { echo "Kernel $1 configuration failed"; exit 1; }
	sed '/CONFIG_ACPI\|CONFIG_ATH\|CONFIG_AXP\|CONFIG_B4\|CONFIG_BACKLIGHT\|CONFIG_BATTERY\|CONFIG_BCM\|CONFIG_BN\|CONFIG_BRCM\|CONFIG_BT\|CONFIG_CEC\|CONFIG_CHARGER\|CONFIG_COMMON\|CONFIG_DW_DMAC\|CONFIG_EXTCON\|CONFIG_FIREWIRE\|CONFIG_FRAMEBUFFER_CONSOLE\|CONFIG_GENERIC\|CONFIG_GPIO\|CONFIG_HID\|CONFIG_I2C\|CONFIG_I4\|CONFIG_IC\|CONFIG_IG\|CONFIG_INPUT\|CONFIG_IWL\|CONFIG_IX\|CONFIG_JOYSTICK\|CONFIG_KEYBOARD\|CONFIG_LEDS\|CONFIG_MANAGER\|CONFIG_MEDIA_CONTROLLER\|CONFIG_MFD\|CONFIG_MMC\|CONFIG_MOUSE\|CONFIG_MT7\|CONFIG_MW\|CONFIG_NFC\|CONFIG_NVME\|CONFIG_PATA\|CONFIG_POWER\|CONFIG_PWM\|CONFIG_REGULATOR\|CONFIG_RMI\|CONFIG_RT\|CONFIG_SATA\|CONFIG_SCSI\|CONFIG_SENSORS\|CONFIG_SND\|CONFIG_SOUNDWIRE\|CONFIG_SPI\|CONFIG_SSB\|CONFIG_TABLET\|CONFIG_THUNDERBOLT\|CONFIG_TOUCHSCREEN\|CONFIG_TPS68470\|CONFIG_TYPEC\|CONFIG_UCSI\|CONFIG_USB\|CONFIG_VIDEO\|CONFIG_W1\|CONFIG_WL/!d' ./kernels/$1/out/.config >> ./kernels/$1/arch/x86/configs/chromeos_defconfig || { echo "Kernel $1 configuration failed"; exit 1; }
	make -C ./kernels/$1 O=out allyesconfig || { echo "Kernel $1 configuration failed"; exit 1; }
	sed '/CONFIG_ATA\|CONFIG_CROS\|CONFIG_HOTPLUG\|CONFIG_MDIO\|CONFIG_PERF\|CONFIG_PINCTRL\|CONFIG.*_PMIC\|CONFIG_.*_FF=\|CONFIG_SATA\|CONFIG_SERI\|CONFIG_USB_STORAGE\|CONFIG_USB_XHCI\|CONFIG_USB_OHCI\|CONFIG_USB_EHCI/!d' ./kernels/$1/out/.config >> ./kernels/$1/arch/x86/configs/chromeos_defconfig || { echo "Kernel $1 configuration failed"; exit 1; }
	sed -i '/_DBG\|_DEBUG\|_MOCKUP\|_NOCODEC\|_ONLY\|_WARNINGS\|TEST\|USB_OTG\|_PLTFM\|_PLATFORM\|_SELFTEST\|_TRACING/d' ./kernels/$1/arch/x86/configs/chromeos_defconfig || { echo "Kernel $1 configuration failed"; exit 1; }
fi
sed '/CONFIG_ATH\|CONFIG_DEBUG_INFO\|CONFIG_IWL\|CONFIG_MODULE_COMPRESS\|CONFIG_MOUSE/d' ./kernels/$1/chromeos/config/chromeos/base.config >> ./kernels/$1/arch/x86/configs/chromeos_defconfig || { echo "Kernel $1 configuration failed"; exit 1; }
sed '/CONFIG_ATH\|CONFIG_DEBUG_INFO\|CONFIG_IWL\|CONFIG_MODULE_COMPRESS\|CONFIG_MOUSE/d' ./kernels/$1/chromeos/config/chromeos/x86_64/common.config >> ./kernels/$1/arch/x86/configs/chromeos_defconfig || { echo "Kernel $1 configuration failed"; exit 1; }
cat ./kernels/$1/chromeos/config/chromeos/x86_64/chromeos-*.flavour.config | grep '^CONFIG_SND' >> ./kernels/$1/arch/x86/configs/chromeos_defconfig || { echo "Kernel $1 configuration failed"; exit 1; }
cat ./kernel-patches/brunch_configs >> ./kernels/$1/arch/x86/configs/chromeos_defconfig || { echo "Kernel $1 configuration failed"; exit 1; }
echo "CONFIG_LOCALVERSION=\"-$2-brunch-f2fs-netisack\"" >> ./kernels/$1/arch/x86/configs/chromeos_defconfig || { echo "Kernel $1 configuration failed"; exit 1; }
make -C ./kernels/$1 O=out chromeos_defconfig || { echo "Kernel $1 configuration failed"; exit 1; }
cp ./kernels/$1/out/.config ./kernels/$1/arch/x86/configs/chromeos_defconfig || { echo "Kernel $1 configuration failed"; exit 1; }
}

download_and_patch_kernels()
{
kernel_remote_path="$(git ls-remote https://chromium.googlesource.com/chromiumos/third_party/kernel/ | grep "refs/heads/release-$chromeos_version" | head -1 | sed -e 's#.*\t##' -e 's#chromeos-.*##' | sort -u)chromeos-"
[ ! "x$kernel_remote_path" == "x" ] || { echo "Remote path not found"; exit 1; }
echo "kernel_remote_path=$kernel_remote_path"
for kernel in $kernels; do
	kernel_version=$(curl -Ls "https://chromium.googlesource.com/chromiumos/third_party/kernel/+/$kernel_remote_path$kernel/Makefile?format=TEXT" | base64 --decode | sed -n -e 1,4p | sed -e '/^#/d' | cut -d'=' -f 2 | sed -z 's#\n##g' | sed 's#^ *##g' | sed 's# #.#g')
	echo "kernel_version=$kernel_version"
	[ ! "x$kernel_version" == "x" ] || { echo "Kernel version not found"; exit 1; }
	case "$kernel" in
		6.12|6.6|5.15)
			echo "Downloading ChromiumOS kernel source for kernel $kernel version $kernel_version from https://chromium.googlesource.com/chromiumos/third_party/kernel/+archive/$kernel_remote_path$kernel.tar.gz"
			curl -L "https://chromium.googlesource.com/chromiumos/third_party/kernel/+archive/$kernel_remote_path$kernel.tar.gz" -o "./kernels/chromiumos-$kernel.tar.gz" || { echo "Kernel source download failed"; exit 1; }
			mkdir "./kernels/chromebook-$kernel" "./kernels/$kernel"
			tar -C "./kernels/chromebook-$kernel" -zxf "./kernels/chromiumos-$kernel.tar.gz" || { echo "Kernel $kernel source extraction failed"; exit 1; }
			tar -C "./kernels/$kernel" -zxf "./kernels/chromiumos-$kernel.tar.gz" || { echo "Kernel $kernel source extraction failed"; exit 1; }
			rm -f "./kernels/chromiumos-$kernel.tar.gz"
			apply_patches "chromebook-$kernel"
			make_config "chromebook-$kernel" "chromebook"
			apply_patches "$kernel"
			make_config "$kernel" "generic"
		;;
		*)
			echo "Downloading ChromiumOS kernel source for kernel $kernel version $kernel_version from https://chromium.googlesource.com/chromiumos/third_party/kernel/+archive/$kernel_remote_path$kernel.tar.gz"
			curl -L "https://chromium.googlesource.com/chromiumos/third_party/kernel/+archive/$kernel_remote_path$kernel.tar.gz" -o "./kernels/chromiumos-$kernel.tar.gz" || { echo "Kernel source download failed"; exit 1; }
			mkdir "./kernels/chromebook-$kernel"
			tar -C "./kernels/chromebook-$kernel" -zxf "./kernels/chromiumos-$kernel.tar.gz" || { echo "Kernel $kernel source extraction failed"; exit 1; }
			rm -f "./kernels/chromiumos-$kernel.tar.gz"
			apply_patches "chromebook-$kernel"
			make_config "chromebook-$kernel" "chromebook"
		;;
	esac
done
}

rm -rf ./kernels
mkdir ./kernels

chromeos_version="R139"
kernels="5.15 6.6 6.12"
download_and_patch_kernels

