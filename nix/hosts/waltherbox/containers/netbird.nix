{self, config, ...}: {
  flake.nixosModules.ct-netbird = let
    name = "netbird";
    domain = "netbird.waltherbox.org";
    address = "192.168.1.85";
    proxyAddress = "192.168.1.72";
    publicIp = config.cloudflare.zones."waltherbox.org".records.netbirdIpv4.content;
    managementPort = 8011;
    signalPort = 8012;
    relayPort = 33080;
    stunPort = 3478;
    dataset = "/fast/apps/netbird";

    # Paths inside the container for the bind-mounted sops secrets.
    relaySecretPath = "/run/netbird-relay-secret";
    datastoreKeyPath = "/run/netbird-datastore-key";
    cookieKeyPath = "/run/netbird-cookie-key";
  in hostArgs: let
    # Dashboard is only static files, this gets built at build times with our settings
    dashboard = hostArgs.config.containers.${name}.config.services.netbird.server.dashboard.finalDrv;
  in {
    # https://docs.netbird.io/selfhosted/reverse-proxy
    containers.proxy.config.services.caddy.virtualHosts."${domain}".extraConfig = ''
      import cf_tls_waltherbox

      # All ips not LAN ips and our own public (support no NAT hairpin)
      @outside not remote_ip private_ranges ${publicIp}
 
      @signal_grpc path /signalexchange.SignalExchange/*
      handle @signal_grpc {
        reverse_proxy h2c://${address}:${toString signalPort}
      }
 
      @management_grpc path /management.ManagementService/* /management.ProxyService/*
      handle @management_grpc {
        reverse_proxy h2c://${address}:${toString managementPort}
      }
 
      @signal path /ws-proxy/signal*
      handle @signal {
        reverse_proxy http://${address}:${toString signalPort}
      }
 
      @relay path /relay*
      handle @relay {
        reverse_proxy http://${address}:${toString relayPort}
      }
 
      @management path /ws-proxy/management* /oauth2/*
      handle @management {
        reverse_proxy http://${address}:${toString managementPort}
      }
 
      @api path /api /api/*
      handle @api {
        abort @outside
        reverse_proxy http://${address}:${toString managementPort}
      }
 
      handle {
        abort @outside
        root * ${dashboard}
        try_files {path} {path}.html {path}/ /404.html
        file_server
      }
    '';

    sops.secrets = {
      "netbird/auth_secret" = {};
      "netbird/session_cookie_key" = {};
      "netbird/store_encryption_key" = {};
    };

    containers."${name}" = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "br-lan";
      localAddress = "${address}/24";
      extraFlags = ["--resolv-conf=off"];

      bindMounts = {
        "/var/lib/netbird-mgmt" = {
          hostPath = dataset;
          isReadOnly = false;
        };
        "${relaySecretPath}" = {
          hostPath = hostArgs.config.sops.secrets."netbird/auth_secret".path;
          isReadOnly = true;
        };
        "${datastoreKeyPath}" = {
          hostPath = hostArgs.config.sops.secrets."netbird/store_encryption_key".path;
          isReadOnly = true;
        };
        "${cookieKeyPath}" = {
          hostPath = hostArgs.config.sops.secrets."netbird/session_cookie_key".path;
          isReadOnly = true;
        };
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

        services.netbird.server = {
          enable = true;
          inherit domain;

          management = {
            port = managementPort;

            # STUN is served: stun:<turnDomain>:<stunPort>
            turnDomain = domain;

            # Required by the nix module, but unused when using builtin IdP
            oidcConfigEndpoint = "https://${domain}/oauth2/.well-known/openid-configuration";

            settings = {
              DataStoreEncryptionKey._secret = datastoreKeyPath;
 
              EmbeddedIdP = {
                Enabled = true;
                Issuer = "https://${domain}/oauth2";
                SignKeyRefreshEnabled = true;
                SessionCookieEncryptionKey._secret = cookieKeyPath;
                DashboardRedirectURIs = [
                  "https://${domain}/nb-auth"
                  "https://${domain}/nb-silent-auth"
                ];
                CLIRedirectURIs = ["http://localhost:53000/"];
              };

              Relay = {
                Addresses = ["rels://${domain}:443"];
                CredentialsTTL = "24h0m0s";
                Secret._secret = relaySecretPath;
              };

              TURNConfig = {
                Turns = [];
                Secret = null;
              };

              ReverseProxy = {
                TrustedHTTPProxies = ["${proxyAddress}/32"];
                TrustedPeers = ["${proxyAddress}/32"];
              };
            };
          };

          dashboard = {
            managementServer = "https://${domain}";
            settings = {
              AUTH_AUTHORITY = "https://${domain}/oauth2";
              AUTH_AUDIENCE = "netbird-dashboard";
              AUTH_CLIENT_ID = "netbird-dashboard";
              AUTH_SUPPORTED_SCOPES = "openid profile email groups";
              AUTH_REDIRECT_URI = "/nb-auth";
              AUTH_SILENT_REDIRECT_URI = "/nb-silent-auth";
            };
          };
        };

        services.netbird.relay = {
          enable = true;
          authSecretFile = relaySecretPath;
          openFirewall = true;
          settings = {
            listen-address = ":${toString relayPort}";
            exposed-address = "rels://${domain}:443";
            enable-stun = true;
            stun-ports = [stunPort];
          };
        };

        networking.firewall.allowedTCPPorts = [
          managementPort
          signalPort
          relayPort
        ];

        preferences.host.name = "${name}";
        system.stateVersion = "26.05";
      };
    };

    systemd.network.networks."vb-${name}" = {
      matchConfig.Name = "vb-${name}";
      networkConfig.Bridge = "br-lan";
      linkConfig.RequiredForOnline = "no";
    };
  };
}
