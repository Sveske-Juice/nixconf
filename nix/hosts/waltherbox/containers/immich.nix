{self, ...}: {
  flake.nixosModules.ct-immich = let
    name = "immich";
    domain = "immich.waltherbox.org";
    address = "192.168.1.84";
    webport = 2283;
    dataset = "/fast/apps/immich";
    immichUid = 8140;
    immichGid = 8140;
  in hostArgs: {
    containers.proxy.config.services.caddy.virtualHosts."${domain}".extraConfig = ''
      import cf_tls_waltherbox
      reverse_proxy http://${address}:${toString webport}
    '';

    containers."${name}" = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "br-lan";
      localAddress = "${address}/24";
      extraFlags = ["--resolv-conf=off"];

      # Pass rendering device to container
      allowedDevices = [
        {
          node = "/dev/dri/renderD128";
          modifier = "rw";
        }
        {
          node = "/dev/dri/card0";
          modifier = "rw";
        }
      ];

      bindMounts = {
        # GPU passthrough
        "/dev/dri" = {
          hostPath = "/dev/dri";
          isReadOnly = false;
        };
        "/var/lib/immich" = {
          hostPath = "${dataset}/library";
          isReadOnly = false;
        };
        "/var/cache/immich" = {
          hostPath = "${dataset}/model-cache";
          isReadOnly = false;
        };
        "/var/lib/postgresql" = {
          hostPath = "${dataset}/postgres";
          isReadOnly = false;
        };
        # syncthing external library
        "/mnt/syncthing-media" = {
          hostPath = "/fast/syncthing/media";
          isReadOnly = false;
        };
        # media photos
        "/mnt/photos-media" = {
          hostPath = "/data/media/photos";
          isReadOnly = false;
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

        users.users.immich.uid = immichUid;
        users.groups.immich.gid = immichGid;

        # Match container GID with host GID
        users.groups."media".gid = hostArgs.config.users.groups."media".gid;
        users.groups."photos".gid = hostArgs.config.users.groups."photos".gid;

        systemd.services.immich-server.serviceConfig.SupplementaryGroups = ["media" "photos"];

        services.immich = {
          enable = true;
          openFirewall = true;
          host = "";
          port = webport;
        };

        services.postgresql.settings = {
          # ZFS is CoW and never writes torn pages
          full_page_writes = false;
          # New WAL files get fresh blocks on ZFS anyway
          wal_init_zero = false;
          wal_recycle = false;
          # The dataset has primarycache=metadata, so the ARC won't cache
          # table data. Postgres has to do it, and its default is only 128MB.
          shared_buffers = "1GB";
        };

        preferences.host.name = "${name}";
        system.stateVersion = "26.05";
      };
    };
  };
}
