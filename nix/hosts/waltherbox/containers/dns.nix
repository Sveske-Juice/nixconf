{self, ...}: {
  flake.nixosModules.ct-dns = let
    name = "dns";
  in {
    containers."${name}" = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "br-lan";
      localAddress = "192.168.1.71/24";
      extraFlags = ["--resolv-conf=off"];
      config = {
        imports = [
          self.nixosModules.base
        ];
        networking = {
          useHostResolvConf = false;
          nameservers = ["127.0.0.1"];
          defaultGateway = "192.168.1.1";
        };

        services.unbound = {
          enable = true;
          settings.server = {
            interface = ["127.0.0.1"];
            port = 5335;
            access-control = ["127.0.0.0/8 allow"];

            local-zone = [
              ''"waltherbox.org" transparent''
            ];
            local-data = [
              ''"ntp.waltherbox.org IN A 192.168.1.70"''

              # Local Vhosts
              ''"syncthing.waltherbox.org IN A 192.168.1.72"''
            ];
            local-data-ptr = [
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

    systemd.network.networks."52-vb-${name}" = {
      matchConfig.Name = "vb-${name}";
      networkConfig.Bridge = "br-lan";
      linkConfig.RequiredForOnline = "no";
    };
  };
}
