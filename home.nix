{ config, pkgs, ... }:
let
  settings = import ./config;
  editor = "vim";
in {
  imports = [ ./zsh.nix ];

  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [

    # dev tools
    git
    vscode jetbrains.clion jetbrains.idea-ultimate
    clang-tools automake autoconf gnutar gzip gnumake binutils-unwrapped coreutils gawk gnused gnugrep
    cmake
    ctags
    gdb
    gnumake
    rustup

    # Python
    pipenv
    python3

    # CLI
    alacritty xdotool
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
    byobu tmux screen coreutils-prefixed

    # desktop
    google-chrome
    redshift

  ];

  programs.autojump.enable = true;

  programs.direnv = { enable = true; };

  programs.git = {
    enable = true;
    userEmail = "jaysullivan@google.com";
    userName = "Jay Sullivan";

    extraConfig = {
      merge = { ff = "only"; };
    };

    ignores = [
      "*~"
      "*.swp"
      ".ccls-cache"
      "*.pdf"
      "compile_commands.json"
      "shell.nix"
    ];
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
    latitude = "48.853";
    longitude = "2.35";
    temperature.night = 3000;
    temperature.day = 5000;
  };

  home.file.".local/bin/show-terminal".source = ./files/show-terminal;
  home.file.".byobu/.tmux.conf".source = ./files/tmux.conf;

  # ?????? HOW DO WE DEPLOY A CUSTOM THEME ???????
  #file."$ZSH/themes/amuse-jay.zsh-theme".source = ./files/amuse-jay.zsh-theme;

  home.sessionVariables = {
    EDITOR = "${editor}";
    BYOBU_BACKEND = "tmux";
    PATH = "$HOME/.local/bin:$HOME/.cargo/bin:$PATH";
    NIX_PATH = "$HOME/.nix-defexpr/channels:$NIX_PATH";
  };
}