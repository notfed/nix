#!/bin/sh
DIR="$(cd "$(dirname "$0")" && pwd)"

if ps -ef | grep qemu-system-x86_64 | grep -q multifunction=on; then
    echo "A passthrough VM is already running." &
    exit 1

else

# ---- TODO: Do these permission updates automatically ----
sudo chown jay /dev/vfio/19
sudo chown jay /dev/input/by-id/usb-Logitech_USB_Receiver-if02-event-mouse
sudo chown jay /dev/input/by-id/usb-Yiancar-Designs_NK65_0-event-kbd
sudo chown jay /sys/bus/pci/devices/0000:02:00.0/config
sudo chown jay /sys/bus/pci/devices/0000:02:00.1/config
sudo chown jay /dev/vfio/*

VM_NAME="win10"
OS_IMG=$DIR/win10.img
OS_ISO=$DIR/win10.iso
VIRTIO_ISO=$DIR/virtio-win-0.1.217.iso
OVMF_VARS=$DIR/OVMF_VARS.fd; cp /etc/ovmf/edk2-i386-vars.fd $OVMF_VARS
OVMF_CODE=/etc/ovmf/edk2-x86_64-secure-code.fd

KEYBOARD_EVDEV_DEVICE=/dev/input/by-id/usb-Yiancar-Designs_NK65_0-event-kbd
MOUSE_EVDEV_DEVICE=/dev/input/by-id/usb-Logitech_USB_Receiver-if02-event-mouse

#export PIPEWIRE_RUNTIME_DIR=/run/user/1000
#export PIPEWIRE_LATENCY="512/48000"

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/run/current-system/sw/lib/pipewire
qemu-system-x86_64 \
    -name $VM_NAME,process=$VM_NAME \
    -machine type=q35,accel=kvm \
    -cpu host \
    -smp 4,sockets=1,cores=2,threads=2 \
    -m 6G \
    -rtc clock=host,base=localtime \
    -vga none \
    -nographic \
    -serial none \
    -parallel none \
    -usb \
    -object input-linux,id=keyboard1,evdev=$KEYBOARD_EVDEV_DEVICE,grab_all=on,repeat=on \
    -object input-linux,id=mouse1,evdev=$MOUSE_EVDEV_DEVICE \
    -device vfio-pci,host=02:00.0,multifunction=on \
    -device vfio-pci,host=02:00.1 \
    -drive if=pflash,format=raw,readonly=on,file=$OVMF_CODE \
    -drive if=pflash,format=raw,file=$OVMF_VARS \
    -boot order=dc \
    -drive id=disk0,if=virtio,cache=none,format=raw,file=$OS_IMG \
    -drive file=$VIRTIO_ISO,index=2,media=cdrom \
    -audiodev pa,id=hda,server=unix:/run/user/1000/pulse/native,out.buffer-length=512,timer-period=1000 -device ich9-intel-hda -device hda-duplex,audiodev=hda
    #-device ich9-intel-hda,bus=pcie.0,addr=0x1b
    #-audiodev jack,id=ad0 -device ich9-intel-hda -device hda-duplex,audiodev=ad0
    #-drive file=$OS_ISO,index=1,media=cdrom \
fi


   # -device ich9-intel-hda \
    #-audiodev pa,id=hda,out.mixing-engine=off \

# ---- SOUND ENV VARS ----

# No sound?
#export QEMU_AUDIO_DRV=none

# Use pulseaudio?
#export QEMU_AUDIO_DRV=pa
#export QEMU_PA_SAMPLES=8192
#export QEMU_AUDIO_TIMER_PERIOD=99
#export QEMU_PA_SERVER=/run/user/1000/pulse/native

# ?
#export QEMU_AUDIO_DRV=pa
#export QEMU_PA_SERVER=unix:/run/user/1000/pulse/native

# 64BIT WINDOWS:
# -device hda \
# BUT NOW:
# ?

# PIPEWIRE:
# -device ich9-intel-hda,bus=pcie.0,addr=0x1b \

#-audiodev pa,id=hda,server=unix:/run/user/1000/pulse/native,out.buffer-length=512,timer-period=1000 
#-audiodev pa,id=hda,server=unix:/run/user/1000/pulse/native,out.buffer-length=512,timer-period=1000 

#-device intel-hda -device hda-duplex \
#-device virtio-net-pci,netdev=net0,mac=00:16:3e:00:01:07
#-object input-linux,id=keyboard1,evdev=/dev/input/by-id/usb-Yiancar-Designs_NK65_0-event-kbd,grab_all=on,repeat=on 
#-object input-linux,id=mouse1,evdev=/dev/input/by-id/usb-Logitech_USB_Receiver-if02-event-mouse 
#-device usb-host,vendorid=0x046d,productid=0xc539 
#-device usb-host,vendorid=0x8968,productid=0x4e4b 
#-netdev type=tap,id=net0,ifname=vmtap0,vhost=off 

#-device ich9-intel-hda,bus=pcie.0,addr=0x1b \
#-device hda-micro,audiodev=hda \
#-audiodev pa,id=hda,server=unix:/tmp/pulse-socket,out.buffer-length=512,timer-period=1000 \
#-device usb-audio,audiodev=usb,multi=on \
#-audiodev pa,id=usb,server=unix:/tmp/pulse-socket,out.mixing-engine=off,out.buffer-length=512,timer-period=1000 \



# -device ich9-intel-hda,bus=pcie.0,addr=0x1b \
# -device hda-micro,audiodev=hda \
# -device pa,id=hda,server=unix:/run/user/1000/pulse/native \



#-device ich9-intel-hda,bus=pcie.0,addr=0x1b \
#-device hda-micro,audiodev=hda \
#-audiodev pa,id=hda,server=unix:/run/user/1000/pulse/native,out.buffer-length=512,timer-period=1000 \
#-device usb-audio,audiodev=usb,multi=on \
#-audiodev pa,id=usb,server=unix:/run/user/1000/pulse/native,out.mixing-engine=off,out.buffer-length=512,timer-period=1000
