{self, ...}: {
  flake.nixosConfigurations = self.lib.mkHost "themata" [
    self.nixosModules.hostThemata
  ];

  flake.nixosModules.hostThemata = {
    lib,
    isVM,
    ...
  }: {
    imports =
      [
        self.nixosModules.base
        self.nixosModules.general
      ]
      ++ lib.optionals (!isVM) [
        self.nixosModules.secrets
      ];

    preferences = {
      host = {
        name = "themata";
      };
      user = {
        name = "cvpl";
      };
    };

    system.stateVersion = "26.05";
  };
}
