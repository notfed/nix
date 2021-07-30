# NixOS - Installing from scratch

## Note

Do all of this as root. Must have `git`, `xxd`, `parted`, `wipefs`, `mkfs.{ext4,vfat}` installed.

## Format partitions/filesystems

```
WIPE_DEVICE=/dev/sdc
TAG=$(xxd -u -l 16 -p /dev/urandom)
wipefs -a $WIPE_DEVICE
parted -a optimal -s $WIPE_DEVICE -- \
  mklabel gpt \
  mkpart logical 0%      256MiB   set 1 bios_grub on \
  mkpart logical 256MiB  512MiB   set 2 esp on  \
  mkpart logical 512MiB  -9GB \
  mkpart logical -9GB    100% \
  name 1 $TAG-1 \
  name 2 $TAG-2 \
  name 3 $TAG-3 \
  name 4 $TAG-4

mkfs.ext4  -F    -L "boot"     /dev/disk/by-partlabel/$TAG-1
mkfs.vfat  -F 32 -n "BOOT-EFI" /dev/disk/by-partlabel/$TAG-2
mkfs.ext4  -f    -L "root"     /dev/disk/by-partlabel/$TAG-3
mkswap           -L "swap"     /dev/disk/by-partlabel/$TAG-4
```

## Mount

```
mount /dev/disk/by-partlabel/$TAG-3 /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-partlabel/$TAG-1 /mnt/boot
```

## Pull this code down

```
git clone https://github.com/notfed/nix
cd nix
```

## Install NixOS

```
mkdir -p /mnt/etc/nixos
nixos-generate-config --root /mnt
cp configuration.nix /mnt/etc/nixos/configuration.nix
cp files/background.jpg /mnt/etc/nixos/
cp patches/* /mnt/etc/nixos/
nixos-install
```

## Reboot, log in as root, set user password, then log in as user

passwd jay    # Change jay's password
cp /home/jay/.nixpkgs/files/icon.png /var/lib/AccountsService/icons/jay # Set jay's login icon

# NixOS Home Manager

Installing:

    nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
    nix-channel --update
    # Log out, then log back in
    nix-shell '<home-manager>' -A install

Configuring:

  vi ~/.config/nixpkgs/home.nix

Updating:

    home-manager switch

# NixOS - Re-configuring

Configuring:

    sudo vi /etc/nixos/configuration.nix 

Updating:

    sudo nixos-rebuild switch

# Reference

https://github.com/Yumasi/nixos-home

