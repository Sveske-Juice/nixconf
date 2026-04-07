{self, ...}: {
  flake.nixosConfigurations = self.lib.mkHost "themata" [
    self.nixosModules.host-themata
  ];

  flake.nixosModules.host-themata = {
    lib,
    isVM,
    ...
  }: {
    imports =
      [
        self.nixosModules.base
        self.nixosModules.general
        self.nixosModules.user-dr3y
      ]
      ++ lib.optionals (!isVM) [
        self.nixosModules.secrets
      ];

    preferences.host = {
      name = "themata";
    };

    system.stateVersion = "26.05";
  };
}
