{self, ...}: {
  flake.nixosModules.ct-seerr = let
    name = "seerr";
    webPort = 5055;
  in {
    containers.proxy.config.services.caddy.virtualHosts."seerr.waltherbox.org".extraConfig = ''
      import cf_tls_waltherbox
      reverse_proxy http://192.168.1.77:${toString webPort}
    '';

    containers."${name}" = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "br-lan";
      localAddress = "192.168.1.77/24";
      extraFlags = ["--resolv-conf=off"];

      config = {
        imports = [
          self.nixosModules.base
        ];
        networking = {
          useHostResolvConf = false;
          nameservers = ["192.168.1.71"];
          defaultGateway = "192.168.1.1";
        };

        services.seerr = {
          enable = true;
          port = webPort;
          openFirewall = true;
        };

        preferences.host.name = "${name}";
        system.stateVersion = "26.05";
      };
    };
  };
}
