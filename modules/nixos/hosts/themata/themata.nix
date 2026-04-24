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
        self.nixosModules.secrets
      ]
      ++ lib.optionals isVM [
        self.nixosModules.hardware-vm-themata
        (self.lib.mkThemataDisko {
          rootDisk = "/dev/vda";
        })
      ]
      ++ lib.optionals (!isVM) [
        self.nixosModules.hardware-metal-themata
        (self.lib.mkThemataDisko {
          rootDisk = "/dev/nvme0n1";
        })
      ];

    preferences.host = {
      name = "themata";
    };

    hardware.graphics.enable = true;

    system.stateVersion = "26.05";
  };
}
