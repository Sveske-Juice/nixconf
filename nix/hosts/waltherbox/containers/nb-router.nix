{self, ...}: {
  flake.nixosModules.ct-netbird-router = let
    name = "netbird-router";
    address = "192.168.1.86";
    wgPort = 51820;
    setupKeyPath = "/run/netbird-setup-key";
  in
    {config, ...}: {
      sops.secrets."netbird/router_setup_key" = {};
      boot.kernelModules = ["wireguard"];

      containers."${name}" = {
        autoStart = true;
        privateNetwork = true;
        hostBridge = "br-lan";
        localAddress = "${address}/24";
        extraFlags = ["--resolv-conf=off"];

        bindMounts."${setupKeyPath}" = {
          hostPath = config.sops.secrets."netbird/router_setup_key".path;
          isReadOnly = true;
        };

        config = {
          imports = [
            self.nixosModules.base
          ];
          networking = {
            useHostResolvConf = false;
            nameservers = ["192.168.1.71"];
            defaultGateway = "192.168.1.1";
          };

          services.netbird = {
            useRoutingFeatures = "server";

            clients.router = {
              port = wgPort;
              openFirewall = true;
              hardened = false;
              login = {
                enable = true;
                setupKeyFile = setupKeyPath;
              };
              environment.NB_MANAGEMENT_URL = "https://netbird.waltherbox.org";
            };
          };

          preferences.host.name = "${name}";
          system.stateVersion = "26.11";
        };
      };
    };
}
