# Installing from scratch

## Create partitions

parted --script /dev/sdz \
    mklabel gpt \
    mkpart primary 1MiB 100MiB \
    mkpart primary 100MiB 200MiB \

## Log in as root and set user password

passwd jay

# NixOS

Configuring:

    sudo vi /etc/nixos/configuration.nix 

Updating:

    sudo nixos-rebuild switch

# NixOS Home Manager

Installing:

    nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
    nix-channel --update
    export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH

Configuring:

  vi ~/.config/nixpkgs/home.nix

Updating:

    home-manager switch

WTF HOW DO I DO THIS Post-install step:

    cp ./files/amuse-jay.zsh-theme $ZSH/themes/

# Other

https://github.com/Yumasi/nixos-home
