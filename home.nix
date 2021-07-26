{ config, pkgs, ... }:
let
  settings = import ./config;
  editor = "vim";
in {
  # -------- Imports --------

  imports = [ ./zsh.nix ];

  # -------- Packages --------

  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [

    # ---- Dev Tools ---- 
    git
    vscode jetbrains.clion jetbrains.idea-ultimate
    clang-tools automake autoconf gnutar gzip gnumake binutils-unwrapped
    gawk gnused gnugrep cmake gdb gnumake  coreutils-full
    rustup
    pipenv python3

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
    oh-my-zsh zsh-autosuggestions zsh-syntax-highlighting zsh-command-time
    byobu tmux screen
    hyperfine

    # ---- Desktop ----
    google-chrome
    redshift
    gimp imagemagick exiftool

  ];
  programs.home-manager.enable = true;
  programs.autojump.enable = true;
  programs.direnv.enable = true;

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

  # -------- Custom Files  --------

  home.file.".local/bin/show-terminal".source = ./files/show-terminal;
  home.file.".byobu/.tmux.conf".source = ./files/tmux.conf;
  home.file.".local/share/zsh-custom/themes/amuse-jay.zsh-theme".source = ./files/amuse-jay.zsh-theme;

  # -------- TODO  --------

  # - How to set GNOME key binding?

  # -------- Environment Variables  --------
  home.sessionVariables = {
    EDITOR = "${editor}";
    BYOBU_BACKEND = "tmux";
    PATH = "$HOME/.local/bin:$HOME/.cargo/bin:$PATH";
    NIX_PATH = "$HOME/.nix-defexpr/channels:$NIX_PATH";
  };
}