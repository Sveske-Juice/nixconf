{
  flake.nixosModules.host-waltherbox = let
    uplinkIf = "enp6s0";
  in {
    networking.useDHCP = false;
    services.resolved.enable = true;
    # TODO: NTP server

    systemd.network = {
      enable = true;

      netdevs."20-br-lan" = {
        netdevConfig = {
          Name = "br-lan";
          Kind = "bridge";
        };
      };

      networks."30-${uplinkIf}-slave" = {
        matchConfig.Name = uplinkIf;
        networkConfig = {
          Bridge = "br-lan";
        };
        linkConfig.RequiredForOnline = "enslaved";
      };

      networks."40-br-lan" = {
        matchConfig.Name = "br-lan";
        networkConfig = {
          IPv6AcceptRA = true;
          ConfigureWithoutCarrier = true;
        };
        linkConfig.RequiredForOnline = "routable";

        address = ["192.168.1.69/24"];
        routes = [{Gateway = "192.168.1.1";}];
      };
    };
  };
}
