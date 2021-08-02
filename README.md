# NixOS - Custom Build - Install from scratch

# Instructions:

Do all of this in a live USB of [Nixos](https://nixos.org/download.html), as the `root` user.


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

Reboot. Log in as <your-username>. Run:

```
/etc/nixos/files/install-home-manager
```

Log out. Log in. Run:

```
home-manager switch
```

That's it!

# Home Manager - Reconfiguring

Configuring:

```
vi ~/.config/nixpkgs/home.nix
```

Updating:

```
home-manager switch
```

# NixOS - Reconfiguring

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

