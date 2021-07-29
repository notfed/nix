# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ 
        # Include the results of the hardware scan.
      	./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev"; # E.g., "/dev/sdb"; # or "nodev" for efi only
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  # boot.loader.systemd-boot.enable = true;

  # Linux kernel version
  boot.kernelPackages = pkgs.linuxPackages_5_12;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "America/New_York";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.enp9s0.useDHCP = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable Nvidia drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  
  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
      gparted parted
      wget file
      vim vim_configurable
      dconf
      zsh
      dconf
  ];

  # GNOME Settings

  environment.gnome.excludePackages = [ pkgs.epiphany pkgs.gnome.totem pkgs.gnome-tour ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jay = {
      isNormalUser = true;
      home = "/home/jay";
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
  };

  ## Set default GNOME user
  #environment.etc = {
  #  "gdm/custom.conf".text = ''
  #  [greeter]
  #  IncludeAll=false
  #  Include=jay
  #  '';
  #};

  nixpkgs = {
    overlays = [
      (self: super: {
        gnome = super.gnome.overrideScope' (selfg: superg: {
          gnome-shell = superg.gnome-shell.overrideAttrs (old: {
            buildInputs = (old.buildInputs or []) ++ [
              # CHEEKY WALLPAPER DERIVATION HERE
            ];
            patches = (old.patches or []) ++ [
              (pkgs.substituteAll {
                backgroundColour = "#d94360";
                backgroundPath = "/etc/nixos/background.jpg";
                src = ./gnome-shell_3.38.3-3ubuntu1_3.38.3-3ubuntu2.patch;
              })
            ];
          });
        });
      })
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}
