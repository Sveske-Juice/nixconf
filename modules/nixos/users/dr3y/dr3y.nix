{self, ...}: {
  flake.nixosModules.user-dr3y = {config, ...}: {
    preferences.user = {
      name = "dr3y";
      email = "sveske_juice@tuta.com";
      gpgKey = "44B31C98B111DF02";
      terminal = "kitty";
      browser = "librewolf";
      filemanager = "nautilus";
    };

    deploy-gpg.enable = config.preferences.secrets;

    imports = [
      self.nixosModules.desktop
      self.nixosModules.niri

      self.nixosModules.kitty
      self.nixosModules.librewolf
      self.nixosModules.nautilus
    ];
  };
}
