{self, ...}: {
  flake.nixosModules.host-larry = let
    name = "dhcp";
  in {
    containers."${name}" = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "br0";
      localAddress = "10.100.0.12/24";
      extraFlags = ["--resolv-conf=off"];
      config = {
        imports = [
          self.nixosModules.base
        ];
        networking = {
          useHostResolvConf = false;
          nameservers = ["10.100.0.11"];
          defaultGateway = "10.100.0.1";
        };

        services.kea.dhcp4 = {
          enable = true;
          settings = {
            interfaces-config.interfaces = [ "eth0" ];

            lease-database = {
              type = "memfile";
              persist = true;
              name = "/var/lib/kea/dhcp4.leases";
            };
            valid-lifetime = 3600;
            renew-timer = 900;
            rebind-timer = 1800;

            subnet4 = [
              # Client
              {
                id = 10;
                subnet = "10.10.0.0/24";
                relay.ip-addresses = [ "10.10.0.1" ];
                pools = [ { pool = "10.10.0.100 - 10.10.0.200"; } ];
                option-data = [
                  { name = "routers"; data = "10.10.0.1"; }
                  { name = "domain-name-servers"; data = "10.100.0.11"; }
                ];
              }
              # Management
              {
                id = 200;
                subnet = "10.200.0.0/24";
                relay.ip-addresses = [ "10.200.0.1" ];
                pools = [ { pool = "10.200.0.100 - 10.200.0.200"; } ];
                option-data = [
                  { name = "routers"; data = "10.200.0.1"; }
                  { name = "domain-name-servers"; data = "10.100.0.11"; }
                ];
              }
            ];
          };
        };

        networking.firewall.allowedUDPPorts = [ 67 ];

        preferences.host.name = "${name}";
        system.stateVersion = "26.05";
      };
    };

    systemd.network.networks."52-vb-${name}" = {
      matchConfig.Name = "vb-${name}";
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
  };
}
