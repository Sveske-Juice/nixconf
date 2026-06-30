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

        self.nixosModules.desktop
        self.nixosModules.niri
        self.nixosModules.greetd
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

    extraNiriModules = [
      {
        settings = {
          debug.wait-for-frame-completion-before-queueing = {};
          workspaces."w0".open-on-output = "HP Inc. HP E233 3CQ93400C2";
          workspaces."w1".open-on-output = "HP Inc. HP E233 3CQ93400BJ";
          workspaces."w2".open-on-output = "eDP-1";
          outputs = {
            "eDP-1" = {
              mode = "1920x1200@60.003";
              position = _: {
                props = {
                  x = 0;
                  y = 0;
                };
              };
            };
            "HP Inc. HP E233 3CQ93400C2" = {
              mode = "1920x1080@60.000";
              focus-at-startup = {};
              position = _: {
                props = {
                  x = 1920;
                  y = 0;
                };
              };
            };
            "HP Inc. HP E233 3CQ93400BJ" = {
              mode = "1920x1080@60.000";
              position = _: {
                props = {
                  x = 3840;
                  y = 0;
                };
              };
            };
          };
        };
      }
    ];

    system.stateVersion = "26.05";
  };
}
