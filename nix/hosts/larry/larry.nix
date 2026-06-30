{self, ...}: {
  flake.nixosConfigurations = self.lib.mkHost "larry" [
    self.nixosModules.host-larry
  ];

  flake.nixosModules.host-larry = {
    lib,
    isVM,
    ...
  }: {
    imports =
      [
        self.nixosModules.base
        self.nixosModules.general
        self.nixosModules.secrets
        self.nixosModules.user-larry

        self.nixosModules.unifi-controller
      ]
      ++ lib.optionals isVM [
        self.nixosModules.hardware-vm-larry
        (self.lib.mkLarryDisko {
          rootDisk = "/dev/vda";
          rootDiskSize = "4G";
          swapSize = "1G";
        })
      ]
      ++ lib.optionals (!isVM) [
        self.nixosModules.hardware-metal-larry
        (self.lib.mkLarryDisko {
          rootDisk = "/dev/nvme0n1";
          swapSize = "64G";
        })
      ];

    preferences.host = {
      name = "larry";
    };

    system.stateVersion = "26.05";
  };
}
