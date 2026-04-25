{self, ...}: {
  flake.nixosConfigurations = self.lib.mkHost "solitubox" [
    self.nixosModules.host-solitubox
  ];

  flake.nixosModules.host-solitubox = {
    lib,
    isVM,
    ...
  }: {
    imports =
      [
        self.nixosModules.base
        self.nixosModules.general
        self.nixosModules.user-dr3y
        self.nixosModules.secrets
      ]
      ++ lib.optionals isVM [
        self.nixosModules.hardware-vm-solitubox
        (self.lib.mkSolituboxDisko {
          rootDisk = "/dev/vda";
        })
      ]
      ++ lib.optionals (!isVM) [
        self.nixosModules.hardware-metal-solitubox
        (self.lib.mkSolituboxDisko {
          rootDisk = "/dev/nvme0n1";
        })
      ];

    preferences.host = {
      name = "solitubox";
    };

    system.stateVersion = "26.05";
  };
}
