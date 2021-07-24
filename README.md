
# NixOS

Configuring:

    sudo code /etc/nixos/configuration.nix 

Updating:

    nixos-rebuild switch

# NixOS Home Manager

Installing:

    nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
    nix-channel --update
    export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH

Configuring:

  code ~/.config/nixpkgs/home.nix

Updating:

    home-manager switch

