{self, ...}: {
  flake.nixosConfigurations = self.lib.mkHost "themata" [
    self.nixosModules.host-themata
  ];

  flake.nixosModules.host-themata = {
    ...
  }: {
    imports =
      [
        self.nixosModules.base
        self.nixosModules.general
        self.nixosModules.user-dr3y
        self.nixosModules.secrets
      ];


    preferences.host = {
      name = "themata";
    };
    preferences.secrets = true;

    system.stateVersion = "26.05";
  };
}
