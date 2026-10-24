{self, ...}: {
  flake.nixosModules.ct-firefly = let
    name = "firefly";
    domain = "firefly.lan.waltherbox.org";
    address = "192.168.1.83";
    webport = 80;
    appKeyPath = "/run/secrets/firefly-app-key";
    fireflyUid = 8130;
  in {config, ...}: {
    sops.secrets."firefly/app-key" = {
      uid = fireflyUid;
      mode = "0400";
    };
    
    containers.proxy.config.services.caddy.virtualHosts."${domain}".extraConfig = ''
      import cf_tls_waltherbox
      import lan_only
      reverse_proxy http://${address}:${toString webport}
    '';

    containers."${name}" = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "br-lan";
      localAddress = "${address}/24";
      extraFlags = ["--resolv-conf=off"];
      bindMounts = {
        "${appKeyPath}" = {
          hostPath = config.sops.secrets."firefly/app-key".path;
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

        users.users.firefly-iii.uid = fireflyUid;

        services.firefly-iii = {
          enable = true;
          enableNginx = true;
          virtualHost = domain;

          settings = {
            APP_KEY_FILE = appKeyPath;
            SITE_OWNER = "admin@waltherbox.org";
            TZ = "Europe/Copenhagen";
            DB_CONNECTION = "sqlite";
            TRUSTED_PROXIES = "127.0.0.0/8,192.168.0.0/16,10.0.0.0/8";
          };
        };

        networking.firewall.allowedTCPPorts = [webport];

        preferences.host.name = "${name}";
        system.stateVersion = "26.05";
      };
    };
  };
}
