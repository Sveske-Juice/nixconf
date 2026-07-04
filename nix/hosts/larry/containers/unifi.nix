{self, ...}: {
  flake.nixosModules.host-larry = let
    name = "unifi";
  in {
    containers."${name}" = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "br0";
      localAddress = "10.200.0.11/24";
      extraFlags = ["--resolv-conf=off"];
      config = {
        imports = [
          self.nixosModules.base
          self.nixosModules.unifi-controller
        ];
        networking = {
          useHostResolvConf = false;
          nameservers = ["10.200.0.1"];
          defaultGateway = "10.200.0.1";
        };

        preferences.host.name = "${name}";
        system.stateVersion = "26.05";
      };
    };

    systemd.network.networks."50-vb-${name}" = {
      matchConfig.Name = "vb-${name}";
      networkConfig.Bridge = "br0";
      bridgeVLANs = [
        {
          VLAN = 200;
          PVID = 200;
          EgressUntagged = 200;
        }
      ];
      linkConfig.RequiredForOnline = "no";
    };
  };
}
