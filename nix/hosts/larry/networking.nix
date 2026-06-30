{
  flake.nixosModules.host-larry = {
    networking.useDHCP = false;
    systemd.network = {
      enable = true;

      networks."10-wan" = {
        matchConfig.Name = "enp0s31f6";

        address = [
          "10.200.0.2/24"
        ];

        routes = [
          {Gateway = "10.200.0.1";}
        ];

        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
}
