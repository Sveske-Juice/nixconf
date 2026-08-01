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
        self.nixosModules.ct-syncthing
        self.nixosModules.ct-torrentbox
        self.nixosModules.ct-jellyfin
        self.nixosModules.ct-seerr

        # Deprived
        self.nixosModules.ct-git
        self.nixosModules.ct-git-runner
        self.nixosModules.ct-deprived-builder
        self.nixosModules.ct-deprived-sftp

        self.nixosModules.vm-plane
      ]
      ++ lib.optionals isVM [
        self.nixosModules.hardware-vm-waltherbox
        (self.lib.mkWaltherboxDisko {
          rootDisk = "/dev/vda";
          fastDisk = "/dev/vdb";
          raidz1Disks = [
            "/dev/vdc"
            "/dev/vdd"
            "/dev/vde"
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
          rootDisk = "/dev/disk/by-id/nvme-eui.00000000000000000026b73815c0a1b5";
          fastDisk = "/dev/disk/by-id/nvme-eui.00000000000000000026b728386c2675";
          raidz1Disks = [
            "/dev/disk/by-id/ata-WDC_WD161KFGX-68AFPN0_3HH24M2N"
            "/dev/disk/by-id/ata-WDC_WD161KFGX-68CMAN0_T1G0RU8N"
            "/dev/disk/by-id/ata-WDC_WD161KFGX-68CMAN0_T1G0RT5N"
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
