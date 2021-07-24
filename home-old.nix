{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "jay";
  home.homeDirectory = "/home/jay";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";

  # Zsh
  programs.zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      enableAutosuggestions = true;
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "amuse";
      };
  };

  # Vim
  programs.vim = {
    enable = true;
    settings = { 
        tabstop = 4;
        shiftwidth = 4; 
        expandtab = true; 
    };
  };

  # Git
  programs.git = {
    enable = true;
    userName = "Jay Sullivan";
    userEmail = "jaysullivan@google.com";
  };

  # Keyboard shortcuts

/*
"org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
  binding = "<Alt>t";
  command = "alacritty";
  name = "open-terminal";
};

dconf.settings = {
  "org/gnome/settings-daemon/plugins/media-keys" = {
    custom-keybindings = [
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
    ];
  };
};
*/



}
