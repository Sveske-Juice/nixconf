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
        self.diskoConfigurations.themata
        self.nixosModules.base
        self.nixosModules.general
        self.nixosModules.user-dr3y
        self.nixosModules.secrets
      ]
      ++ lib.optionals isVM [
        self.nixosModules.hardware-vm-themata
      ]
      ++ lib.optionals (!isVM) [
        self.nixosModules.hardware-metal-themata
      ];

    preferences.host = {
      name = "themata";
    };

    system.stateVersion = "26.05";
  };
}
