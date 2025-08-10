# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ 
        # Include the results of the hardware scan.
      	./hardware-configuration.nix
      	./boot.nix
        ./luksroot.nix
    ];

  disabledModules = [ "system/boot/luksroot.nix" ];

  # Packages
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-25.05/";
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
      gparted parted cryptsetup
      wget file
      vim vim_configurable
      zsh
      dconf
      firefox
  ];

  # Bug fix https://github.com/NixOS/nixpkgs/issues/43989
  environment.etc."libblockdev/conf.d/00-default.cfg".source = "${pkgs.libblockdev}/etc/libblockdev/conf.d/00-default.cfg";

  # SSD Performance
  fileSystems."/".options = [ "noatime" "nodiratime" ];

  # Linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest; #pkgs.linuxPackages_5_12;

  # Squelch pre-password boot messages
  boot.consoleLogLevel = 0;

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
  hardware.nvidia.open = false;
  
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jay = {
      createHome = true;
      isNormalUser = true;
      isSystemUser = false;
      home = "/home/jay";
      extraGroups = [ "wheel" ];
  };
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  # Pre-set user icon
  system.activationScripts = {
    gnomeSessionForJay = {
      text = ''
      mkdir -p /var/lib/AccountsService/icons/
      mkdir -p /var/lib/AccountsService/users/
      cp /etc/nixos/files/AccountsService-icons-jay /var/lib/AccountsService/icons/jay
      cp /etc/nixos/files/AccountsService-users-jay /var/lib/AccountsService/users/jay
      '';
    };
  };

  # Disable root user
  users.users.root.hashedPassword = "!";

  # Shells
  environment.shells = with pkgs; [ bashInteractive zsh ];

  # GNOME Exclusions
  environment.gnome.excludePackages = [ pkgs.totem pkgs.gnome-tour ];

  # GNOME login screen patch (TODO: fix this)
  #nixpkgs = {
  #  overlays = [
  #    (self: super: {
  #      gnome = super.gnome.overrideScope (selfg: superg: {
  #        gnome-shell = superg.gnome-shell.overrideAttrs (old: {
  #          patches = (old.patches or []) ++ [
  #            (pkgs.substituteAll {
  #              src = ./patches/gnome-shell_3.38.3-3ubuntu1_3.38.3-3ubuntu2.patch;
  #            })
  #          ];
  #        });
  #      });
  #    })
  #  ];
  #};

  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
  [com.ubuntu.login-screen]
  background-repeat='no-repeat'
  background-size='cover'
  background-color='#777777'
  background-picture-uri='file:///etc/nixos/files/background.jpg'
  '';


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}
