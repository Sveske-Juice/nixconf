{self, ...}: {
  flake.nixosModules.host-larry = let
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
        bindMounts."/run/caddy.env" = {
          hostPath = config.sops.templates."caddy.env".path;
          isReadOnly = true;
        };
        autoStart = true;
        privateNetwork = true;
        hostBridge = "br0";
        localAddress = "10.100.0.14/24";
        extraFlags = ["--resolv-conf=off"];
        config = {
          imports = [
            self.nixosModules.base
          ];
          networking = {
            useHostResolvConf = false;
            nameservers = ["10.100.0.11"];
            defaultGateway = "10.100.0.1";
          };

          services.caddy = {
            enable = true;
            environmentFile = "/run/caddy.env";
            package = pkgs.caddy.withPlugins {
              plugins = ["github.com/caddy-dns/cloudflare@v0.2.4"];
              hash = "sha256-bzMqxWTqrJ1skZmRTXyEMCKStXpljbqe5r0Ve2cnBfM=";
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

      systemd.network.networks."54-vb-${name}" = {
        matchConfig.Name = "vb-${name}";
        networkConfig.Bridge = "br0";
        bridgeVLANs = [
          {
            VLAN = 100;
            PVID = 100;
            EgressUntagged = 100;
          }
        ];
        linkConfig.RequiredForOnline = "no";
      };
    };
}
