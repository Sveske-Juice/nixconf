{
  flake.nixosModules.nautilus = {lib, pkgs, config, ...}: {
    services.gvfs.enable = true;

    environment.systemPackages = [
      pkgs.nautilus
    ];

    xdg.mime.defaultApplications = lib.mkIf (config.preferences.user.filemanager == "nautilus") {
      "inode/directory" = "org.gnome.Nautilus.desktop";
    };
  };
}
