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
        self.nixosModules.unfree
        self.nixosModules.general
        self.nixosModules.secrets
        self.nixosModules.user-walther

        self.nixosModules.ct-ntp
        self.nixosModules.ct-dns
        self.nixosModules.ct-proxy

        self.nixosModules.ct-radicale
      ]
      ++ lib.optionals isVM [
        self.nixosModules.hardware-vm-waltherbox
        (self.lib.mkWaltherboxDisko {
          rootDisk = "/dev/vda";
          fastDisk = "/dev/vdb";
          raidz1Disks = [
            "vdc"
            "vdd"
            "vde"
          ];
          bootSize = "500M";
          swapSize = "500M";
          rootDiskSize = "10G";
          fastDiskSize = "8G";
          raidz1DisksSize = "4G";
        })
      ]
      ++ lib.optionals (!isVM) [
        self.nixosModules.hardware-metal-waltherbox
        (self.lib.mkWaltherboxDisko {
          rootDisk = "/dev/nvme0n1";
          fastDisk = "/dev/nvme1n1";
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
