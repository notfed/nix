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

  # Bootloader, MBR
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev"; /* GRUB-DEVICE-PLACEHOLDER */
  boot.loader.grub.efiSupport = false;
  #boot.loader.grub.splashImage = "./files/grub_background.jpg";

  # Bootloader, EFI (https://blog.maximilianschulke.com/installing-nix-os-with-full-disk-encryption)
  /*
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev"; # NOTE: DANGEROUS: WE SHOULD DYNAMIC-IZE THIS
  boot.loader.grub.efiSupport = true;
  */
  #boot.loader.grub.enableCryptodisk = true;
  #boot.loader.efi.efiSysMountPoint = "/boot/efi";
  #boot.loader.grub.efiInstallAsRemovable = true;
  #boot.loader.efi.canTouchEfiVariables = false;
  #boot.loader.systemd-boot.enable = false;
  
  /* LUKS */
  /* ENCRYPT-PLACEHOLDER */

  # SSD Performance
  fileSystems."/".options = [ "noatime" "nodiratime" ];

  # Linux kernel
  boot.kernelPackages = pkgs.linuxPackages_5_12;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Time zone
  time.timeZone = "America/New_York";

  # Networking
  networking.hostName = "nixos";

  # Internationalisation
  i18n.defaultLocale = "en_US.UTF-8";
  
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable Nvidia drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Packages
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
      gparted parted cryptsetup
      wget file
      vim vim_configurable
      zsh
      dconf
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jay = {
      createHome = true;
      isNormalUser = true;
      isSystemUser = false;
      home = "/home/jay";
      extraGroups = [ "wheel" ];
  };
  users.defaultUserShell = pkgs.zsh;

  # Shells
  environment.shells = with pkgs; [ bashInteractive zsh ];

  # GNOME Exclusions
  environment.gnome.excludePackages = [ pkgs.epiphany pkgs.gnome.totem pkgs.gnome-tour ];

  # GNOME login screen patch
  nixpkgs = {
    overlays = [
      (self: super: {
        gnome = super.gnome.overrideScope' (selfg: superg: {
          gnome-shell = superg.gnome-shell.overrideAttrs (old: {
            patches = (old.patches or []) ++ [
              (pkgs.substituteAll {
                src = ./patches/gnome-shell_3.38.3-3ubuntu1_3.38.3-3ubuntu2.patch;
              })
            ];
          });
        });
      })
    ];
  };

  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
  [com.ubuntu.login-screen]
  background-repeat='no-repeat'
  background-size='cover'
  background-color='#777777'
  background-picture-uri='file:///etc/nixos/background.jpg'
  '';


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}
