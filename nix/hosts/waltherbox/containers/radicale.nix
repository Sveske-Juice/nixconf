{self, ...}: {
  flake.nixosModules.ct-radicale = let
    port = 5232;
    name = "radicale";
    dataPath = "/var/lib/radicale";
    radicaleUid = 8001;
    secretPath = "/run/secrets/radicale-htpasswd";
  in
    {config, ...}: {
      sops.secrets.radicale-htpasswd = {
        uid = radicaleUid;
      };

      containers."${name}" = {
        autoStart = true;
        privateNetwork = true;
        hostBridge = "br-lan";
        localAddress = "192.168.1.73/24";
        extraFlags = ["--resolv-conf=off"];

        bindMounts = {
          "${dataPath}" = {
            hostPath = "/fast/apps/radicale";
            isReadOnly = false;
          };
          "${secretPath}" = {
            hostPath = config.sops.secrets.radicale-htpasswd.path;
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

          users.users.radicale.uid = radicaleUid;

          services.radicale = {
            enable = true;
            settings = {
              server = {
                hosts = [
                  "0.0.0.0:${toString port}"
                  "[::]:${toString port}"
                ];
              };
              auth = {
                type = "htpasswd";
                htpasswd_filename = "${config.sops.secrets.radicale-htpasswd.path}";
                htpasswd_encryption = "autodetect";
              };
              storage = {
                filesystem_folder = "${dataPath}/collections";
              };
            };
          };
          preferences.host.name = "${name}";
          networking.firewall.allowedTCPPorts = [port];
          system.stateVersion = "26.11";
        };
      };
    };
}
