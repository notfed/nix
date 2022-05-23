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
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-21.11/";
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
      gparted parted cryptsetup
      wget file
      vim vim_configurable
      zsh
      dconf
      firefox
      virtmanager libguestfs qemu_kvm busybox # Virtualization
  ];


  # Virtualization
  virtualisation.libvirtd = {
    enable = true;

    onShutdown = "suspend";
    onBoot = "ignore";

    qemu = {
      package = pkgs.qemu_kvm;
      ovmf.enable = true;
      swtpm.enable = true;
      runAsRoot = false;
    };
  };

  environment.etc."ovmf/edk2-x86_64-secure-code.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-x86_64-secure-code.fd";
  };
  environment.etc."ovmf/edk2-i386-vars.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-i386-vars.fd";
      mode = "0644";
      user = "libvirtd";
  };
  environment.etc."/etc/modprobe.d/local.conf".text = ''
  alias pci:v000010DEd00001401sv00001462sd00003201bc03sc00i00 vfio-pci
  alias pci:v000010DEd00000FBAsv00001462sd00003201bc04sc03i00 vfio-pci
  options vfio-pci ids=10de:1401,10de:0fba
  options vfio-pci disable_vga=1
  '';

  programs.dconf.enable = true;
  systemd.services.libvirtd = {
    path = let
             env = pkgs.buildEnv {
               name = "qemu-hook-env";
               paths = with pkgs; [
                 bash
                 libvirt
                 kmod
                 systemd
                 ripgrep
                 sd
               ];
             };
           in
           [ env ];
  
    preStart =
    ''
      mkdir -p /var/lib/libvirt/hooks
      mkdir -p /var/lib/libvirt/hooks/qemu.d/win10/prepare/begin
      mkdir -p /var/lib/libvirt/hooks/qemu.d/win10/release/end
      mkdir -p /var/lib/libvirt/vgabios
      
      ln -sf /etc/nixos/files/qemu /var/lib/libvirt/hooks/qemu
      ln -sf /etc/nixos/files/kvm.conf /var/lib/libvirt/hooks/kvm.conf
      ln -sf /etc/nixos/files/start.sh /var/lib/libvirt/hooks/qemu.d/win10/prepare/begin/start.sh
      ln -sf /etc/nixos/files/stop.sh /var/lib/libvirt/hooks/qemu.d/win10/release/end/stop.sh
      
      chmod +x /var/lib/libvirt/hooks/qemu
      chmod +x /var/lib/libvirt/hooks/kvm.conf
      chmod +x /var/lib/libvirt/hooks/qemu.d/win10/prepare/begin/start.sh
      chmod +x /var/lib/libvirt/hooks/qemu.d/win10/release/end/stop.sh
    '';
  };

  # ACS Override Patch: (already included in zen kernel)
  ##nixpkgs.config.packageOverrides = pkgs: {
  ##    linux_5_15 = pkgs.linux_5_15.override {
  ##      kernelPatches = pkgs.linux_5_15.kernelPatches ++ [
  ##        { name = "acs";
  ##          patch = pkgs.fetchurl {
  ##            url = "https://aur.archlinux.org/cgit/aur.git/plain/add-acs-overrides.patch?h=linux-vfio";
  ##            sha256 = "0xrzb1klz64dnrkjdvifvi0a4xccd87h1486spvn3gjjjsvyf2xr";
  ##          };
  ##        }
  ##      ];
  ##    };
  ##  };
  ## boot.kernel.sysctl = { "net.ipv4.ip_forward" = 1; };
 
  # Bug fix https://github.com/NixOS/nixpkgs/issues/43989
  environment.etc."libblockdev/conf.d/00-default.cfg".source = "${pkgs.libblockdev}/etc/libblockdev/conf.d/00-default.cfg";

  # SSD Performance
  fileSystems."/".options = [ "noatime" "nodiratime" ];

  # Linux kernel
  # boot.kernelPackages = pkgs.linuxPackages_latest; #pkgs.linuxPackages_5_12;
  boot.kernelPackages = pkgs.linuxPackages_zen; # Includes ACS Override patch, which allows iommu group separation, for gpu passthrough

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
  
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jay = {
      createHome = true;
      isNormalUser = true;
      isSystemUser = false;
      home = "/home/jay";
      extraGroups = [ "wheel" "libvirtd" ];
  };
  users.defaultUserShell = pkgs.zsh;

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
  environment.gnome.excludePackages = [ pkgs.gnome.totem pkgs.gnome-tour ];

  # GNOME login screen patch
  #nixpkgs = {
  #  overlays = [
  #    (self: super: {
  #      gnome = super.gnome.overrideScope' (selfg: superg: {
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
  #services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
  #[com.ubuntu.login-screen]
  #background-repeat='no-repeat'
  #background-size='cover'
  #background-color='#777777'
  #background-picture-uri='file:///etc/nixos/files/background.jpg'
  #'';


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
