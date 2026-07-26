{self, ...}: {
  flake.nixosModules.ct-syncthing = let
    name = "syncthing";
    syncthingUid = 8002;
    secretPath = "/run/secrets/syncthing";
    user = "syncuser";
  in
    {
      config,
      lib,
      ...
    }: {
      # Extract on host with permissions for container user
      sops.secrets = {
        "syncthing/certpem".uid = syncthingUid;
        "syncthing/keypem".uid = syncthingUid;
        "syncthing/passphrase".uid = syncthingUid;
      };

      containers."${name}" = {
        autoStart = true;
        privateNetwork = true;
        hostBridge = "br-lan";
        localAddress = "192.168.1.74/24";
        extraFlags = ["--resolv-conf=off"];

        bindMounts = {
          # Bind mount host dataset to contianer's syncthing data dir
          "${config.containers."${name}".config.services.syncthing.dataDir}" = {
            hostPath = "/fast/syncthing";
            isReadOnly = false;
          };
          # Import secrets to containter
          "${secretPath}/certpem" = {
            hostPath = config.sops.secrets."syncthing/certpem".path;
            isReadOnly = true;
          };
          "${secretPath}/keypem" = {
            hostPath = config.sops.secrets."syncthing/keypem".path;
            isReadOnly = true;
          };
          "${secretPath}/passphrase" = {
            hostPath = config.sops.secrets."syncthing/passphrase".path;
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
            group = "${user}";
          };
          users.groups."${user}" = {};

          # Use the imported secrets instead of using sops in the container
          services.syncthing = {
            cert = lib.mkForce "${secretPath}/certpem";
            key = lib.mkForce "${secretPath}/keypem";
            guiPasswordFile = lib.mkForce "${secretPath}/passphrase";
          };

          # syncthing module should not try extract secrets inside the container
          preferences.secrets = lib.mkForce false;

          preferences.host.name = "${name}";
          preferences.user.name = "${user}";
          system.stateVersion = "26.11";
        };
      };
    };
}
