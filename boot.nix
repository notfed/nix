{ config, ... }:

{
  # Bootloader, EFI
  boot = {

    kernelParams = [ "intel_iommu=on" "iommu=pt" "pcie_acs_override=downstream"];
    kernelModules = [ "vfio" "vfio-pci" "vfio_iommu_type1" "kvm-intel" "vhost-net" ];

    # Virtualization
    #intel_iommu=on

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
  /* ENCRYPT-PLACEHOLDER */
}
