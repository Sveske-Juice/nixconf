{self, ...}: {
  flake.nixosModules.ct-syncthing = let
    name = "syncthing";
    syncthingUid = 8002;
    secretPath = "/run/secrets/syncthing";
    user = "syncuser";
    group = "media";
    guiPort = 8384;
  in
    hostArgs: {
      # Extract on host with permissions for container user
      sops.secrets = {
        "syncthing/certpem".uid = syncthingUid;
        "syncthing/keypem".uid = syncthingUid;
        "syncthing/passphrase".uid = syncthingUid;
      };

      containers.proxy.config.services.caddy.virtualHosts."syncthing.lan.waltherbox.org".extraConfig = ''
        import cf_tls_waltherbox
        import lan_only
        reverse_proxy http://192.168.1.74:${toString guiPort}
      '';

      containers."${name}" = {
        autoStart = true;
        privateNetwork = true;
        hostBridge = "br-lan";
        localAddress = "192.168.1.74/24";
        extraFlags = ["--resolv-conf=off"];

        bindMounts = {
          # Bind mount host dataset to contianer's syncthing data dir
          "${hostArgs.config.containers."${name}".config.services.syncthing.dataDir}" = {
            hostPath = "/fast/syncthing";
            isReadOnly = false;
          };
          # Import secrets to containter
          "${secretPath}/certpem" = {
            hostPath = hostArgs.config.sops.secrets."syncthing/certpem".path;
            isReadOnly = true;
          };
          "${secretPath}/keypem" = {
            hostPath = hostArgs.config.sops.secrets."syncthing/keypem".path;
            isReadOnly = true;
          };
          "${secretPath}/passphrase" = {
            hostPath = hostArgs.config.sops.secrets."syncthing/passphrase".path;
            isReadOnly = true;
          };
        };

        config = {
          imports = [
            self.nixosModules.base
            self.nixosModules.syncthing
          ];
          networking = {
            useHostResolvConf = false;
            nameservers = ["192.168.1.71"];
            defaultGateway = "192.168.1.1";
          };

          # Create the container user
          users.users."${user}" = {
            isNormalUser = true;
            uid = syncthingUid;
            inherit group;
          };
          # Match container GID with host GID
          users.groups.${group}.gid = hostArgs.config.users.groups.${group}.gid;

          networking.firewall.allowedTCPPorts = [guiPort];

          # New files 0660, new folders 0770
          systemd.services.syncthing.serviceConfig.UMask = "0007";

          services.syncthing = {
            openDefaultPorts = true;
            guiAddress = "[::]:${toString guiPort}";

            cert = "${secretPath}/certpem";
            key = "${secretPath}/keypem";
            guiPasswordFile = "${secretPath}/passphrase";
          };

          # syncthing module should not try extract secrets inside the container
          preferences.secrets = hostArgs.lib.mkForce false;

          preferences.host.name = "${name}";
          preferences.user.name = "${user}";
          system.stateVersion = "26.05";
        };
      };
    };
}
