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
    gimp imagemagick

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
    
    plugins = with pkgs; [
      {
        name = "zsh-syntax-highlighting";
        src = fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.6.0";
          sha256 = "0zmq66dzasmr5pwribyh4kbkk23jxbpdw4rjxx0i7dx8jjp2lzl4";
        };
        file = "zsh-syntax-highlighting.zsh";
      }
    ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
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
  };

  # -------- Custom Files  --------

  home.file.".local/bin/show-terminal".source = ./files/show-terminal;
  home.file.".byobu/.tmux.conf".source = ./files/tmux.conf;
  home.file.".local/share/zsh-custom/themes/amuse-jay.zsh-theme".source = ./files/amuse-jay.zsh-theme;

  # -------- Environment Variables  --------
  home.sessionVariables = {
    EDITOR = "${editor}";
    BYOBU_BACKEND = "tmux";
    PATH = "$HOME/.local/bin:$HOME/.cargo/bin:$PATH";
    NIX_PATH = "$HOME/.nix-defexpr/channels:$NIX_PATH";
  };
}