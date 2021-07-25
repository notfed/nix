# NixOS - Installing from scratch

## Create partitions (do as root)

WIPE_DEVICE=/dev/sdc
wipefs -a $WIPE_DEVICE
parted -a optimal -s $WIPE_DEVICE -- mklabel gpt
parted -a optimal -s $WIPE_DEVICE -- mkpart "boot-new"     ext4         0%      256MiB
parted -a optimal -s $WIPE_DEVICE -- mkpart "boot-efi-new" fat32        256MiB  512MiB
parted -a optimal -s $WIPE_DEVICE -- mkpart "nixos-new"    btrfs        512MiB  20GiB   # << 20GiB
parted -a optimal -s $WIPE_DEVICE -- mkpart "swap-new"     linux-swap   20GiB   100%    # << 20GiB
parted -s $WIPE_DEVICE -- set 1 bios_grub on
parted -s $WIPE_DEVICE -- set 2 boot on
PARTITION_BOOT=${WIPE_DEVICE}1
PARTITION_BOOT_EFI=${WIPE_DEVICE}2
PARTITION_NIXOS=${WIPE_DEVICE}3
PARTITION_SWAP=${WIPE_DEVICE}4
mkfs.ext4 $PARTITION_BOOT
mkfs.vfat -F 32 $PARTITION_BOOT_EFI
mkfs.btrfs $PARTITION_NIXOS
mkswap $PARTITION_SWAP
parted $WIPE_DEVICE -- print

## Install NixOS

mount $PARTITION_NIXOS /mnt
mkdir -p /mnt/boot
mount $PARTITION_BOOT /mnt/boot
mkdir -p /mnt/etc/nixos
cp configuration.nix /mnt/etc/nixos/configuration.nix
nixos-install

## Log in as root and set user password

passwd jay

# NixOS - Configuring

Configuring:

    sudo vi /etc/nixos/configuration.nix 

Updating:

    sudo nixos-rebuild switch

# NixOS Home Manager

Installing:

    nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
    nix-channel --update
    export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH

Configuring:

  vi ~/.config/nixpkgs/home.nix

Updating:

    home-manager switch

WTF HOW DO I DO THIS Post-install step:

    cp ./files/amuse-jay.zsh-theme $ZSH/themes/

# Other

https://github.com/Yumasi/nixos-home
