# NixOS - Custom Build - Install from scratch

## Note

Do all of this in a live USB of [Nixos](https://nixos.org/download.html), as the `root` user.

# Instructions:

```
git clone https://github.com/notfed/nix
cd nix
setup/format <device-to-destroy>
setup/mount
setup/install
cp /etc/nixos/files/face.png /mnt/var/lib/AccountsService/icons/<your-username>
nixos-enter
passwd <your-username>
exit
setup/unmount
```

Reboot and log in as <your-username>. Then run:

```
. /etc/nixos/files/install-home-manager
home-manager switch
```

That's it!

# NixOS Home Manager

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

