{ config, pkgs, ... }:

let
  settings = import ./config;
  editor = "vim";
in {

  # -------- Packages --------

  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [

    # ---- Dev Tools ---- 
    git
    vscode jetbrains.clion jetbrains.idea-ultimate
    automake autoconf gnutar gzip gnumake binutils-unwrapped
    gawk gnused gnugrep cmake gdb gnumake coreutils-full
    rustup
    nodejs
    python39Full python39Packages.pylint

    # ---- CLI ---- 
    alacritty 
    xdotool
    exa
    fd
    file
    fzf
    ripgrep
    tree
    unzip
    xclip
    zip
    autojump
    oh-my-zsh zsh-autosuggestions zsh-syntax-highlighting
    byobu tmux screen
    hyperfine
    dos2unix
    bubblewrap

    # ---- Desktop ----
    dropbox-cli cryptomator
    google-chrome firefox-wayland
    redshift
    gimp imagemagick
    gnome.dconf-editor
    feh
    vlc
    # ---- Games ----
    steam
  ];
  programs.home-manager.enable = true;
  programs.autojump.enable = true;
  programs.direnv.enable = true;

  # ---- Neovim ----
  programs.neovim = {
    viAlias = true;
    vimAlias = true;
    enable = true;
    withPython3 = true;
    plugins = with pkgs.vimPlugins; [
    ];
    extraPackages = with pkgs; [
      (python3.withPackages (ps: with ps; [
        black
        flake8
      ]))
    ];
    extraPython3Packages = (ps: with ps; [
      jedi
    ]);
    extraConfig = ''
    set expandtab
    set shiftwidth=4
    set tabstop=4
    '';
  };
 #xdg.configFile."nvim/coc-settings.json".text = builtins.readFile ./my-coc-settings.json;

  # -------- Configuration  --------

  programs.git = {
    enable = true;
    userEmail = "jaysullivan@google.com";
    userName = "Jay Sullivan";

    extraConfig = {
      merge = { ff = "only"; };
    };
  };

  programs.vim = {
    enable = true;
    settings = { 
        tabstop = 4;
        shiftwidth = 4; 
        expandtab = true; 
    };
  };

  services.redshift = {
    enable = true;
    latitude = "40.4173";
    longitude = "-82.9071";
    temperature.night = 3000;
    temperature.day = 5000;
  };

  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    enableAutosuggestions = true;
    enableCompletion = true;
    shellAliases = {
      ls = "exa";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "amuse-jay";
      custom = "$HOME/.local/share/zsh-custom";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      extensions = with pkgs.vscode-extensions; [
          bbenoist.nix
      ];
      userSettings = {
          "editor.mouseWheelZoom" = "true";
          "files.saveConflictResolution" = "overwriteFileOnDisk";
      };
  };

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Primary><Alt>t";
      command = "/home/jay/.local/bin/show-terminal";
      name = "show-terminal";
    };
    "org/gnome/nautilus/preferences" = {
      "always-use-location-entry" = true;
    };
    "org/gnome/desktop/interface" = {
      "enable-hot-corners" = false;
    };
    "org/gnome/desktop/background" = {
      "picture-uri" = "/home/jay/.background-image";
    };
    "org/gnome/desktop/screensaver" = {
      "picture-uri" = "/home/jay/.background-image";
    };
    "org/gnome/shell" = {
      favorite-apps = [
        "google-chrome.desktop"
        "firefox.desktop"
        "code.desktop"
        "org.gnome.Nautilus.desktop"
      ];
    };
  };

  # -------- Custom Files  --------

  home.file.".local/bin/show-terminal".source = /etc/nixos/files/show-terminal;
  home.file.".byobu/.tmux.conf".source = /etc/nixos/files/tmux.conf;
  home.file.".local/share/zsh-custom/themes/amuse-jay.zsh-theme".source = /etc/nixos/files/amuse-jay.zsh-theme;
  home.file.".background-image".source = /etc/nixos/files/background.jpg;

  # -------- Environment Variables  --------
  home.sessionVariables = {
    EDITOR = "${editor}";
    BYOBU_BACKEND = "tmux";
    PATH = "$HOME/.local/bin:$HOME/.cargo/bin:$PATH";
    NIX_PATH = "$HOME/.nix-defexpr/channels:$NIX_PATH";
  };

}
