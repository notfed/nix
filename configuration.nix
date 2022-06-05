# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let 
  gpu_passthrough_pci_ids = "10de:1b81,10de:10f0";
in {
  imports =
    [ 
        # Include the results of the hardware scan.
      	./hardware-configuration.nix
      	./boot.nix
        ./luksroot.nix
        (fetchTarball "https://github.com/msteen/nixos-vscode-server/tarball/master")
    ];

  services.vscode-server.enable = true; 

  boot.kernelParams = [ "intel_iommu=on" "iommu=pt" "pcie_acs_override=downstream" "vfio-pci.ids=${gpu_passthrough_pci_ids}" ];
  boot.kernelModules = [ "vfio" "vfio-pci" "vfio_iommu_type1" "kvm-intel" "vhost-net" ];

  disabledModules = [ "system/boot/luksroot.nix" ];

  # Packages
  #system.autoUpgrade.channel = "https://nixos.org/channels/nixos-22.05/";
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
      # Nix-specific
      nix-index nix-tree
      # Misc
      vim exa
      wget file
      zsh
      dconf
      usbutils pciutils
      # Gnome
      gnome.gnome-packagekit
      # Web
      firefox
      # Filesystems
      gparted parted cryptsetup
      # Virtualization
      virt-manager libvirt libguestfs qemu_kvm OVMFFull
      # Sound
      helvum pipewire
      bluez bluez-tools
      # Networking/Remoting
      wireguard-tools 
      xfce.xfce4-session xfce.xfdesktop
      x2goserver openssh
      # Python
      python38Full
  ];

  # ---- Remoting ----
  services.sshd.enable = true;
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "xfce4-session";
  services.x2goserver.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

  # ---- Virtualization: START ----
  
  # Assign GPU to vfio-pci driver
  boot.extraModprobeConfig = ''
  options vfio-pci ids=${gpu_passthrough_pci_ids}
  softdep radeon pre: vfio-pci
  softdep amdgpu pre: vfio-pci
  softdep nouveau pre: vfio-pci
  softdep nvidia pre: vfio-pci 
  softdep nvidia* pre: vfio-pci
  softdep drm pre: vfio-pci
  options kvm_amd avic=1
  options kvm ignore_msrs=1
  '';

  # Allow the virtualization user (qemu-libvirtd) to access /dev/input devices, and sound
  users.groups.input.members = [ "qemu-libvirtd" ];
  users.groups.pipewire.members = [ "jay" "qemu-libvirtd" ];

  # Set up 
  virtualisation.libvirtd = {
    enable = true;

    onShutdown = "suspend";
    onBoot = "ignore";

    qemu = {
      package = pkgs.qemu_kvm; ovmf.enable = true;
      swtpm.enable = true;
      runAsRoot = false;
      verbatimConfig = ''
      namespaces = []
      cgroup_device_acl = [
          "/dev/null", "/dev/full", "/dev/zero",
          "/dev/random", "/dev/urandom",
          "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
          "/dev/rtc","/dev/hpet",
          "/dev/input/by-id/usb-Generic_Virtual_HID_00000004-event-kbd",
          "/dev/input/by-id/usb-Generic_Virtual_HID_00000004-if01-event-mouse",
          "/dev/input/by-id/usb-Logitech_USB_Receiver-if02-event-mouse",
          "/dev/input/by-id/usb-Yiancar-Designs_NK65_0-event-kbd",
          "/dev/input/by-id/usb-Yiancar-Designs_NK65_0-if02-event-kbd",
          "/dev/input/by-id/usb-Yiancar-Designs_NK65_0-if02-event-mouse",
      ]
      security_default_confined = 0
      '';
      /*
      nvram = [ "/run/libvirt/nix-ovmf/OVMF_CODE.fd:/run/libvirt/nix-ovmf/OVMF_VARS.fd" ]
      user = "qemu-libvirtd"
      group = "qemu-libvirtd"
      */
    };
  };

  # (Raw qemu) Increase RAM usage limits
  security.pam.loginLimits = [
    { domain = "*"; type = "soft"; item = "memlock"; value = "1048576000"; }
    { domain = "*"; type = "hard"; item = "memlock"; value = "1048576000"; }
  ];

  # Place UEFI roms at a static location
  environment.etc."ovmf/edk2-x86_64-secure-code.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-x86_64-secure-code.fd";
  };
  
  environment.etc."ovmf/edk2-i386-vars.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-i386-vars.fd";
      mode = "0644";
      user = "qemu-libvirtd";
  };

  # (Raw qemu) Allow passthrough of certain USB devices to QEMU
  #services.udev.extraRules = ''
  #    SUBSYSTEM=="vfio", TAG+="uaccess"
  #    SUBSYSTEM=="usb", ATTRS{idVendor}=="8968", ATTR{idProduct}=="4e4b", TAG+="uaccess", GROUP="kvm"
  #    SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTR{idProduct}=="c539, TAG+="uaccess", GROUP="kvm"
  #'';

  programs.dconf.enable = true;

  ### ACS Override Patch (not needed, because already included in zen kernel)
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
  
  # ---- Virtualization: END ----
 
  # Bug fix https://github.com/NixOS/nixpkgs/issues/43989
  environment.etc."libblockdev/conf.d/00-default.cfg".source = "${pkgs.libblockdev}/etc/libblockdev/conf.d/00-default.cfg";

  # SSD Performance
  fileSystems."/".options = [ "noatime" "nodiratime" ];

  # Linux kernel
  # boot.kernelPackages = pkgs.linuxPackages_latest; #pkgs.linuxPackages_5_12;
  boot.kernelPackages = pkgs.linuxPackages_zen; # Includes ACS Override patch, which allows iommu group isolation, needed for gpu passthrough

  # Squelch pre-password boot messages
  boot.consoleLogLevel = 0;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Time zone
  time.timeZone = "America/Los_Angeles";

  # Networking
  networking.hostName = "nixos";
  networking.interfaces.enp0s31f6.wakeOnLan.enable = true;

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

  # Enable sound (pipewire)
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
    socketActivation = true;
    wireplumber.enable = false;
    media-session.enable = true;
    systemWide = true;
    # No idea if this works:
    #config.pipewire = {
    #    "context.properties" = {
    #      "default.clock.allowed-rates" = [ 44100 48000 ];
    #    };
    #};
  };
  hardware.pulseaudio.enable = false; # Or, set to true to use pulseaudio instead of pipewire

  # Bluetooth Headset
  hardware.bluetooth.enable = true;
  hardware.bluetooth.hsphfpd.enable = true;

  #hardware.bluetooth.settings = {
  #  General = {
  #    Enable = "Source,Sink,Media,Socket";
  #  };
  #};

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jay = {
      createHome = true;
      isNormalUser = true;
      isSystemUser = false;
      home = "/home/jay";
      extraGroups = [ "wheel" "libvirtd" "kvm" ];
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
