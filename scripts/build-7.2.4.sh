#!/bin/bash
set -e
set -o pipefail
V="7.2.4"
D="/home/etl-bi/kernel-dev/linux-$V"

cd "$D"
make distclean
rm -f .config
mkdir -p debian
touch debian/canonical-certs.pem debian/canonical-revoked-certs.pem
make defconfig

# Habilitar Intel, NVMe, TrackPoint, Câmera e Periféricos
for cfg in X86_INTEL_PSTATE CPU_FREQ_DEFAULT_GOV_PERFORMANCE PREEMPT_DYNAMIC BLK_DEV_NVME NVME_CORE SATA_AHCI BTRFS_FS EXT4_FS XFS_FS SERIO_I8042 KEYBOARD_ATKBD MOUSE_PS2 MOUSE_PS2_TRACKPOINT MOUSE_PS2_SYNAPTICS MOUSE_PS2_SMBUS I2C_I801 I2C_SMBUS HID_LOGITECH HID_LOGITECH_DJ THINKPAD_ACPI E1000E IWLWIFI IWLMVM RTL8XXXU BT BT_HCIBTUSB BT_INTEL USB_VIDEO_CLASS DRM_I915 MFD_RTSX_PCI MMC_REALTEK_PCI SND_HDA_INTEL SND_HDA_CODEC_REALTEK SND_HDA_CODEC_HDMI MEDIA_SUPPORT MEDIA_CAMERA_SUPPORT VIDEO_DEV; do
    scripts/config --enable $cfg
done

# Suprimir módulos de TV e Rádio que causam warnings no initramfs
for cfg in MEDIA_ANALOG_TV_SUPPORT MEDIA_DIGITAL_TV_SUPPORT MEDIA_RADIO_SUPPORT MEDIA_SDR_SUPPORT MEDIA_TUNER; do
    scripts/config --disable $cfg
done

yes "" | make olddefconfig
make bindeb-pkg -j$(nproc)

cd ..
sudo dpkg -i linux-image-${V}_*.deb linux-headers-${V}_*.deb
sudo update-initramfs -u -k "$V"
sudo kernelstub -v -k "/boot/vmlinuz-$V" -i "/boot/initrd.img-$V" || true
sudo reboot
