{
  # Bootloader, EFI
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.splashImage = ./files/background.jpg;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.grub.extraConfig = ''
    if keystatus --shift ; then
       set timeout=-1
    else
       set timeout=0
    fi
  '';

  # LUKS
  /* ENCRYPT-PLACEHOLDER */ 
}
