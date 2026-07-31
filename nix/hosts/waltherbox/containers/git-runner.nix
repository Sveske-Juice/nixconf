{ self, ... }: {
  flake.nixosModules.ct-git-runner = let
    name = "git-runner-${instanceName}";
    instanceName = "agurk";
    forgejoUrl = "http://192.168.1.78:8080";
    runnerUid = 8120;
    runnerGid = 8120;
  in { pkgs, config, ... }: {
    sops.secrets."forgejo/agurk-token" = {
      uid = runnerUid;
      gid = runnerGid;
      mode = "0400";
    };

    containers."${name}" = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "br-lan";
      localAddress = "192.168.1.79/24";
      extraFlags = [ "--resolv-conf=off" ];

      bindMounts = {
        # sops secret (token) — bind-mount just the resolved path directly
        "/run/secrets/forgejo-registration-token" = {
          hostPath = config.sops.secrets."forgejo/agurk-token".path;
          isReadOnly = true;
        };
      };

      config = { pkgs, lib, ... }: {
        imports = [ self.nixosModules.base ];

        networking = {
          useHostResolvConf = false;
          nameservers = [ "192.168.1.71" ];
          defaultGateway = "192.168.1.1";
        };

        services.gitea-actions-runner = {
          package = pkgs.forgejo-runner;

          instances.${instanceName} = {
            enable = true;
            name = instanceName;
            url = forgejoUrl;
            tokenFile = "/run/secrets/forgejo-registration-token";
            labels = [
              "native:host"
            ];

            hostPackages = lib.attrValues {
              inherit (pkgs)
              nix
              nodejs_22
              vite
              git
              bash
              ripgrep
              openssh
              curl
              gnutar
              gzip
              coreutils
              findutils
              ;
            };

            settings = {
              log.level = "info";
              runner = {
                file = ".runner";
                capacity = 2;
                timeout = "3h";
                insecure = false;
                fetch_timeout = "5s";
                fetch_interval = "2s";
              };
              cache = {
                enabled = true;
                dir = "/var/cache/forgejo-runner";
              };
            };
          };
        };

        systemd.tmpfiles.rules = [
          "d /var/cache/forgejo-runner 0755 gitea-runner gitea-runner"
        ];

        preferences.host.name = name;
        system.stateVersion = "26.05";
      };
    };
  };
}
