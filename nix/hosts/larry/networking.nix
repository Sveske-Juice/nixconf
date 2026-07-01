{
  flake.nixosModules.host-larry = {
    networking.useDHCP = false;
    systemd.network = {
      enable = true;

      netdevs = {
        "20-br0" = {
          netdevConfig = {
            Name = "br0";
            Kind = "bridge";
          };
          bridgeConfig.VLANFiltering = true;
        };

        "21-vlan200" = {
          netdevConfig = {
            Name = "vlan200";
            Kind = "vlan";
          };
          vlanConfig.Id = 200;
        };
      };

      networks = {
        "30-uplink" = {
          matchConfig.Name = "enp0s31f6";
          networkConfig.Bridge = "br0";
          bridgeVLANs = [
            {
              VLAN = 99;
              PVID = 99;
              EgressUntagged = 99;
            } # native, untagged
            {VLAN = 10;} # tagged
            {VLAN = 100;} # tagged
            {VLAN = 200;} # tagged
          ];
        };

        "30-br0" = {
          matchConfig.Name = "br0";
          networkConfig.VLAN = ["vlan200"];
          bridgeVLANs = [
            {VLAN = 99;}
            {VLAN = 10;}
            {VLAN = 100;}
            {VLAN = 200;}
          ];
          linkConfig.RequiredForOnline = "no";
        };

        "40-vlan200" = {
          matchConfig.Name = "vlan200";
          address = ["10.200.0.10/24"];
          routes = [{Gateway = "10.200.0.1";}];
          linkConfig.RequiredForOnline = "routable";
        };
      };
    };
  };
}
