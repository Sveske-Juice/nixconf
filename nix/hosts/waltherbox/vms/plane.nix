{ self, inputs, ... }: {
  flake.nixosModules.vm-plane = let
    name = "plane";
    tapName = "vm-${name}";
    mac = "02:00:00:00:02:20";
    baseDir = "/fast/apps/plane";
  in { config, ... }: {
    imports = [
      inputs.microvm.nixosModules.host
    ];
    keyGroups.plane-ssh = with config.keys.ssh; [ dr3y walther ];

    systemd.tmpfiles.rules = [
      "d ${baseDir} 0750 microvm kvm - -"
      "d ${baseDir}/app 0755 microvm kvm - -"
    ];

    systemd.network.networks."100-${tapName}" = {
      matchConfig.Name = tapName;
      networkConfig.Bridge = "br-lan";
      linkConfig.RequiredForOnline = "no";
    };

    containers.proxy.config.services.caddy.virtualHosts."plane.deprived.dev".extraConfig = ''
      import cf_tls_deprived
      reverse_proxy http://192.168.1.81:80
    '';

    microvm.vms."${name}" = {
      config = {
        microvm = {
          vsock.cid = 3;
          interfaces = [{
            type = "tap";
            id = tapName;
            inherit mac;
          }];

          volumes = [{
            image = "${baseDir}/docker.img";
            mountPoint = "/var/lib/docker";
            size = 1024 * 32;
          }];

          shares = [
            {
              source = "/nix/store";
              mountPoint = "/nix/.ro-store";
              tag = "ro-store";
              proto = "virtiofs";
            }
            {
              source = "${baseDir}/app";
              mountPoint = "/var/lib/plane";
              tag = "plane-app";
              proto = "virtiofs";
            }
          ];

          vcpu = 2;
          mem = 4096;
        };

        imports = [
          self.nixosModules.base
          self.nixosModules.docker
        ];

        services.openssh = {
          enable = true;
          settings = {
            PasswordAuthentication = false;
            PubkeyAuthentication = true;
          };
        };

        users.users.root.openssh.authorizedKeys.keys = config.keyGroups.plane-ssh;

        networking.useDHCP = false;
        systemd.network = {
          enable = true;
          networks."10-wan" = {
            matchConfig.MACAddress = mac;
            address = ["192.168.1.81/24"];
            routes = [{Gateway = "192.168.1.1";}];
            networkConfig.DNS = "192.168.1.71";
          };
        };

        preferences.host.name = name;
        system.stateVersion = "26.05";
      };
    };
  };
}
