# NixOS - Custom Build - Install from scratch

## Note

Do all of this [Nixos live](https://nixos.org/download.html) as the `root` user.

# Instructions:

```
git clone https://github.com/notfed/nix
cd nix
setup/format <device-to-destroy>
setup/mount
setup/install
nixos-enter
passwd <your-username>
exit
setup/unmount
```

That's it. Reboot and log in.

# (Beta home-manager installation steps)

```
nixos-enter
passwd <your-username>
su <your-username>
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
exit
su <your-username>
cp /etc/nixos/home.nix ~/.config/nixpkgs/home.nix
nix-shell '<home-manager>' -A install
exit
exit
setup/unmount
```

# NixOS Home Manager

Installing:

```
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
# Log out, then log back in
cp /etc/nixos/home.nix ~/.config/nixpkgs/home.nix
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

