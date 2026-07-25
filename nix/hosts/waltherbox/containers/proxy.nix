{self, ...}: {
  flake.nixosModules.ct-proxy = let
    name = "proxy";
  in
    {
      pkgs,
      config,
      ...
    }: {
      sops.secrets."cloudflare/api_token" = {};
      sops.templates."caddy.env".content = ''
        CF_API_TOKEN=${config.sops.placeholder."cloudflare/api_token"}
      '';

      containers."${name}" = {
        # Mount secret to contianer
        bindMounts."/run/caddy.env" = {
          hostPath = config.sops.templates."caddy.env".path;
          isReadOnly = true;
        };

        autoStart = true;
        privateNetwork = true;
        hostBridge = "br-lan";
        localAddress = "192.168.1.72/24";
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

          services.caddy = {
            enable = true;
            environmentFile = "/run/caddy.env";
            package = pkgs.caddy.withPlugins {
              plugins = ["github.com/caddy-dns/cloudflare@v0.2.4"];
              hash = "sha256-hEHgAG0F0ozHRAPuxEqLyTATBrE+pajeXDiSNwniorg=";
            };
            globalConfig = ''
              acme_dns cloudflare {env.CF_API_TOKEN}
            '';
          };

          # QUIC
          networking.firewall.allowedUDPPorts = [443];

          networking.firewall.allowedTCPPorts = [80 443];

          preferences.host.name = "${name}";
          system.stateVersion = "26.05";
        };
      };

      systemd.network.networks."53-vb-${name}" = {
        matchConfig.Name = "vb-${name}";
        networkConfig.Bridge = "br-lan";
        linkConfig.RequiredForOnline = "no";
      };
    };
}
