{
  flake.nixosModules.host-larry = {
    networking.useDHCP = false;
    systemd.network = {
      enable = true;

      networks."10-wan" = {
        matchConfig.Name = "enp0s31f6";

        address = [
          "192.168.8.10/24"
        ];

        routes = [
          { Gateway = "192.168.8.1"; }
        ];

        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
}
