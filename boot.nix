{ config, ... }:

{
  # Bootloader, EFI
  boot = {
    loader = {
      grub = {
        enable = true;
        version = 2;
        device = "nodev";
        efiSupport = true;
        efiInstallAsRemovable = true;
        splashImage = ./files/background.jpg;
        extraConfig = ''
          if keystatus --shift ; then
            set timeout=-1
          else
            set timeout=0
          fi
        '';
        
        # MBP 2018
        #extraModulePackages = with config.boot.kernelPackages; [ mbp2018-bridge-drv ];
        #kernelModules = [ "mbp2018-bridge-drv" ];
        ## Divides power consumption by two.
        #kernelParams = [ "acpi_osi=" ];

      };
      efi = {
        canTouchEfiVariables = false;
      };
    };
  };

  # LUKS
  /* ENCRYPT-PLACEHOLDER */
}
