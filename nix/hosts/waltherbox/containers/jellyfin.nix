{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.ct-jellyfin = let
    name = "jellyfin";
    users = [
      "CasdAdmin"
      "Benjamin"
      "Stuen"
      "Alexander"
      "Christopher"
      "Kathrine"
      "gags5"
      "guacamole"
      "alex"
      "rams"
      "honore"
    ];
    webPort = 8096;

    uid = 8003;
    gid = 8003;
    secretsPath = "/run/secrets/jellyfin";

    # container dirs
    dataDir = "/var/lib/jellyfin";
    cacheDir = "/var/cache/jellyfin";
    metadataDir = "${dataDir}/metadata";
    transcodesDir = "${cacheDir}/transcodes";

    # host zfs datasets
    hostDataDir = "/fast/apps/jellyfin/config";
    hostCacheDir = "/fast/apps/jellyfin/cache";
    hostMetadataDir = "/fast/apps/jellyfin/metadata";
    hostTranscodesDir = "/fast/apps/jellyfin/transcodes";

    userOverrides = {
      CasdAdmin = {
        mutable = false;
        permissions.isAdministrator = true;
      };
      Benjamin = {
        mutable = false;
        permissions.isAdministrator = true;
      };
      gags5 = {
        permissions.enableAllFolders = false;
        preferences.enabledLibraries = ["Movies" "Shows"];
      };
      rams = {
        permissions.enableAllFolders = false;
        preferences.enabledLibraries = ["Movies" "Shows"];
      };
      guacamole = {
        permissions.enableAllFolders = false;
        preferences.enabledLibraries = ["Movies" "Shows"];
      };
      alex = {
        permissions.enableAllFolders = false;
        preferences.enabledLibraries = ["Movies" "Shows"];
      };
    };
  in
    hostArgs: {
      # Extract all user passwords on host
      sops.secrets = builtins.listToAttrs (
        map (user: {
          name = "jellyfin/${user}";
          value = {
            inherit uid gid;
            mode = "0400";
          };
        })
        users
      );

      containers.proxy.config.services.caddy.virtualHosts."jellyfin.waltherbox.org".extraConfig = ''
        import cf_tls_waltherbox
        reverse_proxy http://192.168.1.76:${toString webPort}
      '';

      containers."${name}" = {
        autoStart = true;
        privateNetwork = true;
        hostBridge = "br-lan";
        localAddress = "192.168.1.76/24";
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

          # Import user passwords to container
          "/run/secrets/jellyfin" = {
            hostPath = "/run/secrets/jellyfin";
            isReadOnly = true;
          };
          "/run/secrets.d" = {
            hostPath = "/run/secrets.d";
            isReadOnly = true;
          };

          # Bind mount host zfs datasets to jellyfin container
          "/data/media" = {isReadOnly = false;};
          ${dataDir} = {
            hostPath = hostDataDir;
            isReadOnly = false;
          };
          ${metadataDir} = {
            hostPath = hostMetadataDir;
            isReadOnly = false;
          };
          ${cacheDir} = {
            hostPath = hostCacheDir;
            isReadOnly = false;
          };
          ${transcodesDir} = {
            hostPath = hostTranscodesDir;
            isReadOnly = false;
          };
        };

        config = let
          # generate { hashedPasswordFile = "/run/secrets/jellyfin/<user>" } for each user
          userPasswords = builtins.listToAttrs (
            map (user: {
              name = user;
              value = {
                hashedPasswordFile = "${secretsPath}/${user}";
              };
            })
            users
          );
        in
          {
            config,
            lib,
            ...
          }: {
            imports = [
              self.nixosModules.base
              inputs.declarative-jellyfin.nixosModules.default
            ];
            networking = {
              useHostResolvConf = false;
              nameservers = ["192.168.1.71"];
              defaultGateway = "192.168.1.1";
            };

            # Create container local groups and match gid with host
            users.groups.media.gid = hostArgs.config.users.groups.media.gid;
            users.groups.photos.gid = hostArgs.config.users.groups.photos.gid;

            users.users.${config.services.jellyfin.user} = {
              inherit uid;
              extraGroups = ["video" "render" "media" "photos"];
            };
            users.groups.${config.services.jellyfin.group}.gid = gid;

            hardware.graphics.enable = true;
            services.jellyfin = {
              inherit dataDir cacheDir;
              openFirewall = true;
            };

            services.declarative-jellyfin = {
              enable = true;

              serverId = "50549af6c9344827a98a0dc85e0a1c97";
              backups = false;

              system = {
                isStartupWizardCompleted = true;
                serverName = "Waltherbox Jellyfin";
                trickplayOptions = {
                  enableHwAcceleration = true;
                  enableHwEncoding = true;
                };
              };

              network = {
                enableIPv6 = true;
                internalHttpPort = webPort;
                publicHttpPort = webPort;
              };

              # Merge user's hashedPasswordFile with their settings
              users = lib.recursiveUpdate userPasswords userOverrides;

              encoding = {
                enableHardwareEncoding = true;
                hardwareAccelerationType = "vaapi";
                enableDecodingColorDepth10Hevc = true;
                allowHevcEncoding = true;
                allowAv1Encoding = true;
                hardwareDecodingCodecs = [
                  "h264"
                  "hevc"
                  "mpeg2video"
                  "vc1"
                  "vp9"
                  "av1"
                ];
              };

              libraries = {
                "Movies" = {
                  enabled = true;
                  contentType = "movies";
                  pathInfos = ["/data/media/movies"];
                  enableChapterImageExtraction = true;
                  extractChapterImagesDuringLibraryScan = true;
                  enableTrickplayImageExtraction = true;
                  extractTrickplayImagesDuringLibraryScan = true;
                };
                "Shows" = {
                  enabled = true;
                  contentType = "tvshows";
                  pathInfos = ["/data/media/shows"];
                  enableChapterImageExtraction = true;
                  extractChapterImagesDuringLibraryScan = true;
                  enableTrickplayImageExtraction = true;
                  extractTrickplayImagesDuringLibraryScan = true;
                };
                "Photos" = {
                  # FIXME: fix photo libs
                  enabled = true;
                  contentType = "homevideos";
                  pathInfos = ["/data/media/photos"];
                  enableChapterImageExtraction = true;
                  extractChapterImagesDuringLibraryScan = true;
                  enableTrickplayImageExtraction = true;
                  extractTrickplayImagesDuringLibraryScan = true;
                };
              };
            };

            preferences.host.name = "${name}";
            system.stateVersion = "26.05";
          };
      };
    };
}
