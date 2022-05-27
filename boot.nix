{
  # Bootloader, EFI
  boot = {

    # MBP 2018
    #extraModulePackages = with config.boot.kernelPackages; [ mbp2018-bridge-drv ];
    #extraModprobeConfig = ''
    #  options hid_apple iso_layout=0
    #'';
    #kernelModules = [ "mbp2018-bridge-drv" ];
    #kernelParams = [ "acpi_osi=" ];

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
            set timeout=10
          else
            set timeout=10
          fi
        '';

      };
      efi = {
        canTouchEfiVariables = false;
      };
    };
  };

  # LUKS
  boot.initrd.luks.devices.enc-64ee7fbd259f424f81e8e3e202c606c2 = { 
      deviceDisplayName = "/"; 
      device = "/dev/disk/by-partuuid/64ee7fbd-259f-424f-81e8-e3e202c606c2";
      preLVM = true; 
  }; 
}
