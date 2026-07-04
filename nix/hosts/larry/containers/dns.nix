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
            interface = ["127.0.0.1"];
            port = 5335;
            access-control = ["127.0.0.0/8 allow"];

            local-zone = [
              ''"evil.deprived.dev." transparent''
            ];
            local-data = [
              ''"gw.evil.deprived.dev. IN A 10.200.0.1"''
              ''"switch.evil.deprived.dev. IN A 10.200.0.3"''
              ''"unifi.evil.deprived.dev. IN A 10.200.0.11"''
              ''"larry.evil.deprived.dev. IN A 10.200.0.10"''
              ''"dns.evil.deprived.dev. IN A 10.100.0.11"''
              ''"ntp.evil.deprived.dev. IN A 10.100.0.13"''
              ''"forgejo.evil.deprived.dev. IN A 10.100.0.15"''

              # Virtual Hosts
              ''"git.evil.deprived.dev. IN A 10.100.0.14"''
              ''"auth.evil.deprived.dev. IN A 10.100.0.14"''
            ];
            local-data-ptr = [
              ''"10.200.0.10 larry.evil.deprived.dev"''
              ''"10.200.0.11 unifi.evil.deprived.dev"''
            ];
          };
        };

        services.blocky = {
          enable = true;
          settings = {
            ports.dns = 53;
            upstreams.groups.default = ["127.0.0.1:5335"];
            blocking.blackLists.ads = [
              "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            ];
            blocking.clientGroupsBlock.default = ["ads"];
          };
        };

        networking.firewall.allowedTCPPorts = [53];
        networking.firewall.allowedUDPPorts = [53];

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
