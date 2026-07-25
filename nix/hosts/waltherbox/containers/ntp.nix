{self, ...}: {
  flake.nixosModules.ct-ntp = let
    name = "ntp";
  in {
    containers."${name}" = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "br-lan";
      localAddress = "192.168.1.70/24";
      extraFlags = ["--resolv-conf=off"];
      additionalCapabilities = ["CAP_SYS_TIME"];
      config = {
        imports = [
          self.nixosModules.base
        ];
        networking = {
          useHostResolvConf = false;
          defaultGateway = "192.168.1.1";
        };

        services.timesyncd.enable = false;

        services.chrony = {
          enable = true;
          enableRTCTrimming = false;
          servers = [
            "0.pool.ntp.org"
            "1.pool.ntp.org"
            "2.pool.ntp.org"
          ];
          extraConfig = ''
            allow 10.0.0.0/8
            allow 192.168.0.0/16

            # keep serving a sane local clock even when upstream is unreachable
            local stratum 10

            # save drift/state so restarts and offline periods stay accurate
            driftfile /var/lib/chrony/chrony.drift
          '';
        };

        networking.firewall.allowedUDPPorts = [123];

        preferences.host.name = "${name}";
        system.stateVersion = "26.05";
      };
    };

    systemd.network.networks."51-vb-${name}" = {
      matchConfig.Name = "vb-${name}";
      networkConfig.Bridge = "br-lan";
      linkConfig.RequiredForOnline = "no";
    };
  };
}
