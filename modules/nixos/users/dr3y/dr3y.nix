{self, ...}: {
  flake.nixosModules.user-dr3y = {
    lib,
    config,
    isVM,
    ...
  }: {
    preferences.user = {
      name = "dr3y";
      email = "sveske_juice@tuta.com";
      gpgKey = "44B31C98B111DF02";
      terminal = "kitty";
      browser = "librewolf";
      filemanager = "nautilus";
    };

    deploy-gpg.enable = config.preferences.secrets;

    imports =
      [
        self.nixosModules.desktop
        self.nixosModules.niri

        self.nixosModules.syncthing

        self.nixosModules.kitty
        self.nixosModules.librewolf
        self.nixosModules.nautilus
        self.nixosModules.keepassxc

        self.nixosModules.spotify
        self.nixosModules.vesktop
        self.nixosModules.obsidian
      ]
      ++ lib.optionals (!isVM) [
        # No need for these big packages to be included in vm tests
        self.nixosModules.gaming
        self.nixosModules.virt-manager
      ];
  };
}
