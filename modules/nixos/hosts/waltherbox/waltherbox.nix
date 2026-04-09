{self, ...}: {
  flake.nixosConfigurations = self.lib.mkHost "waltherbox" [
    self.nixosModules.host-waltherbox
  ];

  flake.nixosModules.host-waltherbox = {
    lib,
    isVM,
    ...
  }: {
    imports =
      [
        self.nixosModules.base
        self.nixosModules.general
        self.nixosModules.secrets
        self.nixosModules.user-walther
      ]
      ++ lib.optionals isVM [
        self.nixosModules.hardware-vm-waltherbox
        (self.lib.mkWaltherboxDisko {
          rootDisk = "/dev/vda";
          raidz1Disks = [
            "vdb"
            "vdc"
            "vdd"
          ];
          bootSize = "500M";
          swapSize = "500M";
          rootDiskSize = "10G";
          raidz1DisksSize = "4G";
        })
      ]
      ++ lib.optionals (!isVM) [
        self.nixosModules.hardware-metal-waltherbox
        (self.lib.mkWaltherboxDisko {
          rootDisk = "/dev/nvme0n1";
          raidz1Disks = [
            "sda"
            "sdb"
            "sdc"
          ];
          bootSize = "1G";
          swapSize = "64G";
        })
      ];

    preferences.host = {
      name = "waltherbox";
    };

    system.stateVersion = "26.05";
  };
}
