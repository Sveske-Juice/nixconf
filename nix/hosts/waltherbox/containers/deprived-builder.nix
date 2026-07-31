{ self, ... }: {
  flake.nixosModules.ct-deprived-builder = let
    name = "deprived-builder";
    mainBranch = "main";
    allowedBranches = [ "main" "dev" ];
    srcUrl = "ssh://forgejo@git.deprived.dev:2222/DeprivedDevs/deprived-main-website.git";
    builderUid = 8110;
    builderGid = 8110;
    wwwGid = 960;
    signallerAuthorizedKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHc4184ajSTTUyfi2BuXgd/iSM/ig6pkFFPWuzZo9dom forgejo-runner-signaller";
    sshPort = 22;
  in {config, lib, ... }: {
    sops.secrets."deprived-builder/builder-key" = {
      uid = builderUid;
      gid = builderGid;
      mode = "0400";
    };

    systemd.tmpfiles.rules = [
      "d /var/www 0755 root root -"
      "d /var/www/deprived 0775 ${toString builderUid} ${toString wwwGid} -"
    ] ++ (lib.forEach allowedBranches (branch:
      "d /var/www/deprived/${branch} 0775 ${toString builderUid} ${toString wwwGid} -"
    ));

    containers."${name}" = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "br-lan";
      localAddress = "192.168.1.80/24";
      extraFlags = [ "--resolv-conf=off" ];

      bindMounts = {
        "${config.containers."${name}".config.users.users.deprivedbuilder.home}/.ssh/id_ed25519" = {
          hostPath = config.sops.secrets."deprived-builder/builder-key".path;
          isReadOnly = true;
        };

        "/var/www/deprived" = {
          isReadOnly = false;
        };
      };

      config = { pkgs, lib, ... }: {
        imports = [ self.nixosModules.base ];

        networking = {
          useHostResolvConf = false;
          nameservers = [ "192.168.1.71" ];
          defaultGateway = "192.168.1.1";
          firewall.allowedTCPPorts = [sshPort];
        };

        users.groups.www.gid = wwwGid;

        users.users.deprivedbuilder = {
          uid = builderUid;
          isNormalUser = true;
          group = "deprivedbuilder";
          extraGroups = [ "www" "systemd-journal" ];
          shell = pkgs.bash;
          home = "/var/lib/deprivedbuilder";
          createHome = true;
          openssh.authorizedKeys.keys = [
            signallerAuthorizedKey
          ];
        };
        users.groups.deprivedbuilder.gid = builderGid;

        services.openssh = {
          enable = true;
          ports = [sshPort];
          settings = {
            PasswordAuthentication = false;
            PermitRootLogin = "no";
          };
        };

        # deprivedbuilder can start any of the build services without a password
        security.sudo.extraRules = [{
          users = [ "deprivedbuilder" ];
          commands = lib.forEach allowedBranches (branch: {
            command = "/run/current-system/sw/bin/systemctl * build-deprived-website-${branch}";
            options = [ "NOPASSWD" ];
          });
        }];


        # One systemd oneshot per branch
        systemd.services = builtins.listToAttrs (
          map (branch: {
            name = "build-deprived-website-${branch}";
            value = {
              description = "Build deprived.dev (${branch} branch)";
              wants = [ "network-online.target" ];
              after = [ "network-online.target" ];
              path = with pkgs; [ bash vite nodejs_22 git openssh coreutils ];

              serviceConfig = {
                Type = "oneshot";
                User = "deprivedbuilder";
                Group = "www";
                RemainAfterExit = false;
                TimeoutStartSec = "15min";
                UMask = "0022";
              };

              script = 
                # bash
                ''
                set -euox pipefail

                echo "Building branch: ${branch}"
                echo "Started at: $(date)"

                tmpdir=$(mktemp -d)
                trap "rm -rf $tmpdir" EXIT
                cd "$tmpdir"

                mkdir repo
                cd repo

                echo "Cloning repository..."
                GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=/dev/null -i /var/lib/deprivedbuilder/.ssh/id_ed25519" \
                  git clone --depth 1 --branch "${branch}" ${srcUrl} .

                echo "Installing dependencies..."
                export HOME=$(mktemp -d)
                npm ci --loglevel=info

                echo "Building..."
                npx vite build

                echo "Deploying..."
                # Atomic swap via .new + rm + mv
                rm -rf /var/www/deprived/${branch}.new
                cp -a build /var/www/deprived/${branch}.new
                chmod -R g+rX /var/www/deprived/${branch}.new
                rm -rf /var/www/deprived/${branch}
                mv /var/www/deprived/${branch}.new /var/www/deprived/${branch}

                echo "Build complete: ${branch}"
                echo "Finished at: $(date)"
              '';
            };
          }) allowedBranches
        );

        preferences.host.name = name;
        system.stateVersion = "26.05";
      };
    };

    containers.proxy.bindMounts."/var/www/deprived" = {
      isReadOnly = true;
    };

    containers.proxy.config.services.caddy.virtualHosts = {
      "deprived.dev".extraConfig = ''
        root * /var/www/deprived/${mainBranch}
        file_server
        encode gzip zstd
        try_files {path} {path}/ /index.html
      '';

      "www.deprived.dev".extraConfig = ''
        redir https://deprived.dev{uri} 301
      '';
    } // (builtins.listToAttrs (
      map (branch: {
        name = "${branch}.deprived.dev";
        value.extraConfig = ''
          import lan_only
          root * /var/www/deprived/${branch}
          file_server
          encode gzip zstd
          try_files {path} {path}/ /index.html
        '';
      }) (builtins.filter (b: b != mainBranch) allowedBranches)
    ));
  };
}
