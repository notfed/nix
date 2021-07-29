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
nixos-generate-config --root /mnt
cp configuration.nix /mnt/etc/nixos/configuration.nix
nixos-install

## Reboot, log in as root, set user password, then log in as user

passwd jay

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

# Other

https://github.com/Yumasi/nixos-home


# Question

I simply want to show a background image on the GNOME login screen.

I was able to change my background/wallpaper by placing this in my home manager configuration:

dconf.settings = {
    "org/gnome/desktop/background" = {
        "picture-uri" = "/home/me/.background-image";
    };
    "org/gnome/desktop/screensaver" = {
        "picture-uri" = "/home/me/.background-image";
    };
};
home.file.".background-image".source = /path/to/my/background.jpg;

But before I log in, the login background is just a blank color. How do I change it?

I found [1] but it didn't work, though I may be misunderstanding the post as it's quite confusing for a NixOS newbie (for example, `wallpaper.gnomeFilePath` is an undefined variable reference, and where do I put `./greeter-background.patch`?

[1] https://discourse.nixos.org/t/gdm-background-image-and-theme/12632


# -------------

Old: https://gitlab.gnome.org/GNOME/gnome-shell/-/blob/9eff9ada/data/theme/gnome-shell-sass/widgets/_screen-shield.scss
New: https://gitlab.gnome.org/GNOME/gnome-shell/-/blob/main/data/theme/gnome-shell-sass/widgets/_screen-shield.scss

The _ is out of date:

There is already a feature request open for this: https://gitlab.gnome.org/GNOME/gnome-shell/-/issues/3877


---

I made a little progress, but it still doesn't work.

The patch failed to apply, and I found why: `_screen-shield.scss` has changed:

- Old: https://gitlab.gnome.org/GNOME/gnome-shell/-/blob/9eff9ada/data/theme/gnome-shell-sass/widgets/_screen-shield.scss
- New: https://gitlab.gnome.org/GNOME/gnome-shell/-/blob/main/data/theme/gnome-shell-sass/widgets/_screen-shield.scss

So, theoretically here's the updated patch:

```
diff --git a/data/theme/gnome-shell-sass/widgets/_screen-shield.scss b/data/theme/gnome-shell-sass/widgets/_screen-shield.scss
index 00c549a53..b5c0be683 100644
--- a/data/theme/gnome-shell-sass/widgets/_screen-shield.scss
@@ -66,7 +66,10 @@
 }

 #lockDialogGroup {
-  background-color: $system_bg_color;
+  background: theme-color.$system url(file://@backgroundPath@); 
+  background-repeat: no-repeat; 
+  background-size: cover; 
+  background-position: center; 
 }

 #unlockDialogNotifications {
```

I applied this, and...nothing happens.  


There is already a feature request open for this: https://gitlab.gnome.org/GNOME/gnome-shell/-/issues/3877