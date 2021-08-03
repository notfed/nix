{
  # Bootloader, EFI
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev"; /* GRUB-DEVICE-PLACEHOLDER */
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.splashImage = ./files/background.jpg;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  # LUKS
  boot.initrd.luks.devices."D032934B84795D248DDC8255A80F3ADE" = { device = "/dev/disk/by-partlabel/D032934B84795D248DDC8255A80F3ADE-enc"; preLVM = true; };
}
