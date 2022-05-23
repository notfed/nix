#!/run/current-system/sw/bin/bash

# Debugging
# exec 19>/home/owner/Desktop/stoplogfile
# BASH_XTRACEFD=19
# set -x

# Load variables we defined
source "/var/lib/libvirt/hooks/kvm.conf"

# Unload vfio module
modprobe -r vfio-pci

# Attach GPU devices from host
virsh nodedev-reattach $VIRSH_GPU_VIDEO
virsh nodedev-reattach $VIRSH_GPU_AUDIO

# Read nvidia x config
nvidia-xconfig --query-gpu-info > /dev/null 2>&1

# Load NVIDIA kernel modules
modprobe nvidia_drm nvidia_modeset nvidia_uvm nvidia

# Avoid race condition
# sleep 5

# Bind EFI Framebuffer
echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/bind

# Bind VTconsoles
echo 1 > /sys/class/vtconsole/vtcon0/bind
echo 1 > /sys/class/vtconsole/vtcon1/bind

# Start display manager
systemctl start display-manager.service

# Return host to all cores
systemctl set-property --runtime -- user.slice AllowedCPUs=0-3
systemctl set-property --runtime -- system.slice AllowedCPUs=0-3
systemctl set-property --runtime -- init.scope AllowedCPUs=0-3

# Change to powersave governor
echo powersave | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
