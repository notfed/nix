{
  # Bootloader, MBR
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev"; /* GRUB-DEVICE-PLACEHOLDER */
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.splashImage = ./files/background.jpg;
  
  # LUKS
  /* ENCRYPT-PLACEHOLDER */
}
