{self, ...}: {
  flake.nixosConfigurations = self.lib.mkHost "lateralus" [
    self.nixosModules.host-lateralus
  ];

  flake.nixosModules.host-lateralus = {
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

        self.nixosModules.desktop
        self.nixosModules.niri
        self.nixosModules.greetd
      ]
      ++ lib.optionals isVM [
        self.nixosModules.hardware-vm-lateralus
        (self.lib.mkLateralusDisko {
          rootDisk = "/dev/vda";
          rootDiskSize = "8G";
        })
      ]
      ++ lib.optionals (!isVM) [
        self.nixosModules.hardware-metal-lateralus
        (self.lib.mkLateralusDisko {
          rootDisk = "/dev/nvme0n1";
          bootSize = "1G";
          swapSize = "32G";
        })
      ];

    preferences.host = {
      name = "lateralus";
    };

    system.stateVersion = "26.05";
  };
}
