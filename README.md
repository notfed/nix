# NixOS - Custom Build - Install from scratch

## Note

Do all of this [Nixos live](https://nixos.org/download.html) as the `root` user.

# Instructions:

```
git clone https://github.com/notfed/nix
cd nix
./install <device-to-destroy>
```

## Reboot, log in as root, then:

```
passwd jay
cp /home/jay/.nixpkgs/files/icon.png /var/lib/AccountsService/icons/jay # Set jay's login icon
```

# NixOS Home Manager

Installing:

```
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
# Log out, then log back in
nix-shell '<home-manager>' -A install
```

Configuring:

```
vi ~/.config/nixpkgs/home.nix
```

Updating:

```
home-manager switch
```

# NixOS - Re-configuring

Configuring:

```
sudo vi /etc/nixos/configuration.nix 
```

Updating:

```
sudo nixos-rebuild switch
```

# Reference

https://github.com/Yumasi/nixos-home

