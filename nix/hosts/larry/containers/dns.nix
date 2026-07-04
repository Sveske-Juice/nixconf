{self, ...}: {
  flake.nixosModules.host-larry = let
    name = "dns";
  in {
    containers."${name}" = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "br0";
      localAddress = "10.100.0.11/24";
      extraFlags = ["--resolv-conf=off"];
      config = {
        imports = [
          self.nixosModules.base
        ];
        networking = {
          useHostResolvConf = false;
          nameservers = ["127.0.0.1"];
          defaultGateway = "10.100.0.1";
        };

        services.unbound = {
          enable = true;
          settings.server = {
            interface = [ "127.0.0.1" ];
            port = 5335;
            access-control = [ "127.0.0.0/8 allow" ];

            local-zone = [
              ''"evil." static''
            ];
            local-data = [
              ''"gw.evil. IN A 10.200.0.1"''
              ''"switch.evil. IN A 10.200.0.3"''
              ''"unifi.evil. IN A 10.200.0.11"''
              ''"larry.evil. IN A 10.200.0.10"''

              ''"dns.evil. IN A 10.100.0.11"''
              ''"ntp.evil. IN A 10.100.0.13"''
            ];
            # PTR records
            local-data-ptr = [
              ''"10.200.0.10 larry.evil"''
              ''"10.200.0.11 unifi.evil"''
            ];
          };
        };

        services.blocky = {
          enable = true;
          settings = {
            ports.dns = 53;
            upstreams.groups.default = [ "127.0.0.1:5335" ];
            blocking.blackLists.ads = [
              "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            ];
            blocking.clientGroupsBlock.default = [ "ads" ];
          };
        };

        networking.firewall.allowedTCPPorts = [ 53 ];
        networking.firewall.allowedUDPPorts = [ 53 ];

        preferences.host.name = "${name}";
        system.stateVersion = "26.05";
      };
    };

    systemd.network.networks."51-vb-${name}" = {
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
