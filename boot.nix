{
  # Bootloader, EFI
  boot = {
    loader = {
      grub = {
        enable = true;
        version = 2;
        device = "nodev";
        efiSupport = true;
        splashImage = ./files/background.jpg;
        extraConfig = ''
          if keystatus --shift ; then
            set timeout=-1
          else
            set timeout=0
          fi
        '';
      };
      efi = {
        efiInstallAsRemovable = true;
        canTouchEfiVariables = false;
      };
    };
  };

  # LUKS
  /* ENCRYPT-PLACEHOLDER */
}
