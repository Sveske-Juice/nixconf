{self, inputs, ...}: {
  flake.nixosModules.host-larry = let
    name = "auth";
    httpPort = 9000;
    httpsPort = 9443;
  in {config, ...}: {
    # For some reason authentik just returns blank pages on http port, 
    # so proxy https instead
    containers.proxy.config.services.caddy.virtualHosts."auth.evil.deprived.dev".extraConfig = ''
      tls { dns cloudflare {env.CF_API_TOKEN} }
      reverse_proxy https://10.100.0.16:${toString httpsPort} {
        transport http {
          tls_insecure_skip_verify
        }
        header_up Host {host}
        header_up X-Forwarded-Proto {scheme}
      }
    '';

    sops.secrets."authentik/secret_key" = { };
    sops.templates."authentik.env".content = ''
      AUTHENTIK_LISTEN__HTTP=0.0.0.0:${toString httpPort}
      AUTHENTIK_LISTEN__HTTPS=0.0.0.0:${toString httpsPort}
      AUTHENTIK_SECRET_KEY=${config.sops.placeholder."authentik/secret_key"}
    '';

    containers."${name}" = {
      bindMounts."/run/authentik.env" = {
        hostPath = config.sops.templates."authentik.env".path;
        isReadOnly = true;
      };

      autoStart = true;
      privateNetwork = true;
      hostBridge = "br0";
      localAddress = "10.100.0.16/24";
      extraFlags = ["--resolv-conf=off"];
      config = {
        imports = [
          self.nixosModules.base
          inputs.authentik-nix.nixosModules.default
        ];
        networking = {
          useHostResolvConf = false;
          nameservers = ["10.100.0.11"];
          defaultGateway = "10.100.0.1";
        };

        services.authentik = {
          enable = true;
          environmentFile = "/run/authentik.env";
          settings = {
            disable_startup_analytics = true;
            avatars = "initials";
          };
        };

        networking.firewall.allowedTCPPorts = [ httpsPort httpPort ]; 

        preferences.host.name = "${name}";
        system.stateVersion = "26.05";
      };
    };

    systemd.network.networks."56-vb-${name}" = {
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
