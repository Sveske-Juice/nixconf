{self, ...}: {
  flake.nixosModules.host-larry = let
    name = "git";
    webport = 8080;
    sshport = 22;
    realsshport = 2222;
  in {
    containers.proxy.config.services.caddy.virtualHosts."git.evil.deprived.dev".extraConfig = ''
      tls { dns cloudflare {env.CF_API_TOKEN} }
      reverse_proxy http://10.100.0.15:${toString webport}
    '';

    containers."${name}" = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "br0";
      localAddress = "10.100.0.15/24";
      extraFlags = ["--resolv-conf=off"];
      config = {
        imports = [
          self.nixosModules.base
        ];
        networking = {
          useHostResolvConf = false;
          nameservers = ["10.100.0.11"];
          defaultGateway = "10.100.0.1";

          # DNAT re-write sshport to realsshport, since it's bad practice to 
          # bind to :22, but users shouldn't have to use custom port
          firewall.extraCommands = ''
            iptables -t nat -A PREROUTING -p tcp --dport ${toString sshport} -j REDIRECT --to-ports ${toString realsshport}
          '';
        };

        services.forgejo = {
          enable = true;
          lfs.enable = true;
          database.type = "postgres";

          settings = {
            DEFAULT = {
              APP_NAME = "Don't disappoint evil larry";
            };

            repository = {
              ENABLE_PUSH_CREATE_USER = true;
            };

            server = {
              DOMAIN = "git.evil.deprived.dev";
              HTTP_PORT = webport;
              ROOT_URL = "https://git.evil.deprived.dev";

              DISABLE_SSH = false;
              START_SSH_SERVER = true;
              # Since we use caddy for HTTPS git.evil.deprived.dev doesnt 
              # resolve to this container
              SSH_DOMAIN = "forgejo.evil.deprived.dev";
              # Advertise sshport
              SSH_PORT = sshport;
              # Actually use realsshport
              SSH_LISTEN_PORT = realsshport;
            };

            security.REVERSE_PROXY_TRUSTED_PROXIES = "127.0.0.0/8";

            # service.DISABLE_REGISTRATION = true;
            actions = {
              ENABLED = true;
              DEFAULT_ACTIONS_URL = "https://code.forgejo.org";
            };
            federation.ENABLED = false;
          };
        };

        networking.firewall.allowedTCPPorts = [ sshport realsshport webport ];

        preferences.host.name = "${name}";
        system.stateVersion = "26.05";
      };
    };

    systemd.network.networks."55-vb-${name}" = {
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
