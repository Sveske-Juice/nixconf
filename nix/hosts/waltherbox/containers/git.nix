{self, ...}: {
  flake.nixosModules.ct-git = let
    name = "git";
    webport = 8080;
    sshport = 2222;
  in {
    containers.proxy.config.services.caddy.virtualHosts."git.deprived.dev".extraConfig = ''
      import cf_tls_deprived
      reverse_proxy http://192.168.1.78:${toString webport}
    '';

    containers."${name}" = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "br-lan";
      localAddress = "192.168.1.78/24";
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

        services.forgejo = {
          enable = true;
          lfs.enable = true;
          database.type = "postgres";

          settings = {
            DEFAULT = {
              APP_NAME = "Never be deprived of a monster";
            };

            repository = {
              ENABLE_PUSH_CREATE_USER = true;
            };

            service = {
              ENABLE_AUTO_REGISTRATION = true;
              DISABLE_REGISTRATION = true;
            };

            server = {
              DOMAIN = "git.deprived.dev";
              HTTP_PORT = webport;
              ROOT_URL = "https://git.deprived.dev";

              DISABLE_SSH = false;
              START_SSH_SERVER = true;
              SSH_DOMAIN = "git.deprived.dev";
              SSH_PORT = sshport;
              SSH_LISTEN_PORT = sshport;
            };

            security.REVERSE_PROXY_TRUSTED_PROXIES = "127.0.0.0/8,192.168.0.0/16,10.0.0.0/8";

            actions = {
              ENABLED = true;
              DEFAULT_ACTIONS_URL = "https://code.forgejo.org";
            };
            federation.ENABLED = false;
          };
        };

        networking.firewall.allowedTCPPorts = [sshport webport];

        preferences.host.name = "${name}";
        system.stateVersion = "26.05";
      };
    };
  };
}
