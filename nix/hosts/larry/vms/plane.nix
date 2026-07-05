{self, ...}: {
  flake.nixosModules.host-larry = let
    name = "plane";
    tapName = "vm-${name}";
    mac = "02:00:00:00:02:20";
  in
    {config, ...}: {
      keyGroups.plane-ssh = with config.keys.ssh; [
        dr3y
        larry
      ];

      systemd.tmpfiles.rules = [
        "d /persist/plane 0750 microvm kvm - -"
        "d /persist/plane/app 0755 microvm kvm - -"
      ];

      systemd.network.networks."57-${tapName}" = {
        matchConfig.Name = tapName;
        networkConfig.Bridge = "br0";
        bridgeVLANs = [
          {
            VLAN = 100;
            PVID = 100;
            EgressUntagged = 100;
          }
        ];
        linkConfig.RequiredForOnline = "no";
      };

      containers.proxy.config.services.caddy.virtualHosts."plane.evil.deprived.dev".extraConfig = ''
        tls { dns cloudflare {env.CF_API_TOKEN} }
        reverse_proxy http://10.100.0.17:80
      '';

      microvm.vms."${name}" = {
        config = {
          microvm = {
            vsock.cid = 3;

            interfaces = [
              {
                type = "tap";
                id = tapName;
                inherit mac;
              }
            ];
            # Microvms are ephemeral, so persist the docker dir to persist
            # plane data
            volumes = [
              {
                image = "/persist/plane/docker.img";
                mountPoint = "/var/lib/docker";
                size = 1024 * 32;
              }
            ];
            shares = [
              {
                source = "/nix/store";
                mountPoint = "/nix/.ro-store";
                tag = "ro-store";
                proto = "virtiofs";
              }
              {
                source = "/persist/plane/app";
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
              address = ["10.100.0.17/24"];
              routes = [{Gateway = "10.100.0.1";}];
              networkConfig.DNS = "10.100.0.11";
            };
          };

          preferences.host.name = name;
          system.stateVersion = "26.05";
        };
      };
    };
}
