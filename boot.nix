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
  boot.initrd.luks.devices."enc-9505b3f2155c495eaa42f640941a0917" = { device = "/dev/disk/by-partuuid/9505b3f2-155c-495e-aa42-f640941a0917"; deviceDisplayName = "whatever"; preLVM = true; }; /* ENCRYPT-PLACEHOLDER */ 
}
