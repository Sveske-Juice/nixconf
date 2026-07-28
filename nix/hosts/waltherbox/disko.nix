{inputs, ...}: let
  inherit (inputs.nixpkgs) lib;
in {
  flake.nixosModules.host-waltherbox = {pkgs, ...}: {
    # Required by ZFS
    networking.hostId = "deadbeef"; # hehe

    environment.systemPackages = with pkgs; [
      zfs
    ];

    boot.initrd.systemd.enable = true;
    boot.supportedFilesystems = ["zfs"];
    boot.initrd.kernelModules = ["zfs"];
    boot.zfs.forceImportRoot = false;

    services.zfs.autoScrub.enable = true;
    services.zfs.autoScrub.interval = "monthly";
    services.zfs.trim.enable = true;

    # Higher inotify limits for syncthing
    boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288;

    systemd.services.zfs-mount.enable = false;
  };

  flake.lib.mkWaltherboxDisko = {
    rootDisk,
    rootDiskSize ? null,
    fastDisk ? null,
    fastDiskSize ? null,
    raidz1DisksSize ? null,
    raidz1Disks,
    bootSize,
    swapSize,
  }: {
    disko.devices = {
      disk =
        {
          main = {
            type = "disk";
            device = rootDisk;
            imageSize = lib.mkIf (rootDiskSize != null) rootDiskSize;
            content = {
              type = "gpt";
              partitions = {
                boot = {
                  size = bootSize;
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = ["umask=0077"];
                  };
                };
                swap = {
                  size = swapSize;
                  content = {
                    type = "swap";
                    discardPolicy = "both";
                    resumeDevice = true;
                  };
                };
                root = {
                  size = "100%";
                  content = {
                    type = "zfs";
                    pool = "zroot";
                  };
                };
              };
            };
          };
        }
        // lib.optionalAttrs (fastDisk != null) {
          fast = {
            type = "disk";
            device = fastDisk;
            imageSize = lib.mkIf (fastDiskSize != null) fastDiskSize;
            content = {
              type = "gpt";
              partitions = {
                zfs = {
                  size = "100%";
                  content = {
                    type = "zfs";
                    pool = "fast";
                  };
                };
              };
            };
          };
        }
        // lib.attrsets.genAttrs raidz1Disks (disk: {
          type = "disk";
          device = disk;
          imageSize = lib.mkIf (raidz1DisksSize != null) raidz1DisksSize;
          content = {
            type = "gpt";
            partitions = {
              zfs = {
                size = "100%";
                content = {
                  type = "zfs";
                  pool = "data";
                };
              };
            };
          };
        });

      zpool = {
        zroot = {
          type = "zpool";
          rootFsOptions = {
            mountpoint = "none";
            canmount = "off";
            acltype = "posixacl";
            xattr = "sa";
            atime = "off";
            compression = "zstd";
          };

          options = {
            ashift = "12";
            autotrim = "on";
          };

          datasets = {
            root = {
              type = "zfs_fs";
              mountpoint = "/";
              options."com.sun:auto-snapshot" = "false";
            };
            nix = {
              type = "zfs_fs";
              mountpoint = "/nix";
              options."com.sun:auto-snapshot" = "false";
            };
            var = {
              type = "zfs_fs";
              mountpoint = "/var";
              options."com.sun:auto-snapshot" = "false";
            };
            "var/log" = {
              type = "zfs_fs";
              mountpoint = "/var/log";
              options."com.sun:auto-snapshot" = "false";
            };
            "var/lib" = {
              type = "zfs_fs";
              mountpoint = "/var/lib";
              options."com.sun:auto-snapshot" = "true";
            };
            # FIXME: https://discourse.nixos.org/t/zroot-home-not-mounted-in-stage-1-init-using-zfs-with-disko/76951
            #
            # home = {
            #   type = "zfs_fs";
            #   mountpoint = "/home";
            #   options."com.sun:auto-snapshot" = "true";
            # };
          };
        };

        fast = lib.mkIf (fastDisk != null) {
          type = "zpool";
          rootFsOptions = {
            mountpoint = "none";
            canmount = "off";
            acltype = "posixacl";
            xattr = "sa";
            atime = "off";
            compression = "zstd";
          };
          options = {
            ashift = "12";
            autotrim = "on";
          };

          datasets = {
            root = {
              type = "zfs_fs";
              mountpoint = "/fast";
              options.canmount = "off";
              options."com.sun:auto-snapshot" = "false";
            };

            syncthing = {
              type = "zfs_fs";
              mountpoint = "/fast/syncthing";
              options."com.sun:auto-snapshot" = "true";
            };

            apps = {
              type = "zfs_fs";
              mountpoint = "/fast/apps";
              options.canmount = "off";
              options."com.sun:auto-snapshot" = "false";
            };

            "apps/radicale" = {
              type = "zfs_fs";
              mountpoint = "/fast/apps/radicale";
              options."com.sun:auto-snapshot" = "true";
            };

            "apps/immich" = {
              type = "zfs_fs";
              mountpoint = "/fast/apps/immich";
              options.canmount = "off";
            };

            "apps/immich/library" = {
              type = "zfs_fs";
              mountpoint = "/fast/apps/immich/library";
              options."com.sun:auto-snapshot" = "true";
            };

            "apps/immich/postgres" = {
              type = "zfs_fs";
              mountpoint = "/fast/apps/immich/postgres";
              options = {
                recordsize = "16K";
                # postgres already has it's own memory cache
                primarycache = "metadata";
                logbias = "throughput";
                "com.sun:auto-snapshot" = "true";
              };
            };

            "apps/immich/model-cache" = {
              type = "zfs_fs";
              mountpoint = "/fast/apps/immich/model-cache";
              options."com.sun:auto-snapshot" = "false";
            };

            "apps/jellyfin" = {
              type = "zfs_fs";
              mountpoint = "/fast/apps/jellyfin";
              options.canmount = "off";
            };

            "apps/jellyfin/config" = {
              type = "zfs_fs";
              mountpoint = "/fast/apps/jellyfin/config";
              options = {
                # aligns with sqlite
                recordsize = "16K";
                compression = "zstd";
                "com.sun:auto-snapshot" = "true";
              };
            };

            "apps/jellyfin/metadata" = {
              type = "zfs_fs";
              mountpoint = "/fast/apps/jellyfin/metadata";
              options = {
                compression = "zstd";
              };
            };

            "apps/jellyfin/cache" = {
              type = "zfs_fs";
              mountpoint = "/fast/apps/jellyfin/cache";
              options = {
                compression = "off";
                recordsize = "1M";
              };
            };

            "apps/jellyfin/transcodes" = {
              type = "zfs_fs";
              mountpoint = "/fast/apps/jellyfin/transcodes";
              options = {
                compression = "off";
                recordsize = "1M";
                # temp dir so crash loss is fine
                sync = "disabled";
              };
            };

            "apps/qbittorrent" = {
              type = "zfs_fs";
              mountpoint = "/fast/apps/qbittorrent";
              options.canmount = "off";
              options."com.sun:auto-snapshot" = "false";
            };

            "apps/qbittorrent/config" = {
              type = "zfs_fs";
              mountpoint = "/fast/apps/qbittorrent/config";
              options = {
                compression = "zstd";
                "com.sun:auto-snapshot" = "true";
              };
            };

            "apps/qbittorrent/data" = {
              type = "zfs_fs";
              mountpoint = "/fast/apps/qbittorrent/data";
              options = {
                # Match bittorrent block size
                recordsize = "16K";
                compression = "off";
                # ignore fsync() calls - not that important for torrent files
                sync = "disabled";
                "com.sun:auto-snapshot" = "false";
              };
            };

            scratch = {
              type = "zfs_fs";
              mountpoint = "/fast/scratch";
              options."com.sun:auto-snapshot" = "false";
            };
          };
        };

        data = lib.mkIf (builtins.length raidz1Disks > 0) {
          type = "zpool";
          mode = "raidz";

          rootFsOptions = {
            mountpoint = "none";
            canmount = "off";
            acltype = "posixacl";
            xattr = "sa";
            atime = "off";
            compression = "zstd";
          };
          options = {
            ashift = "12";
            autotrim = "on";
          };

          datasets = {
            data = {
              type = "zfs_fs";
              mountpoint = "/data";
              options.canmount = "off";
              options."com.sun:auto-snapshot" = "false";
            };

            "data/media" = {
              type = "zfs_fs";
              mountpoint = "/data/media";
              options.canmount = "off";
              options."com.sun:auto-snapshot" = "false";
            };

            # For media we remove compression because the codec already
            # already do compression, and change recordsize for large
            # sequential reads
            "data/media/movies" = {
              type = "zfs_fs";
              mountpoint = "/data/media/movies";
              options = {
                compression = "off";
                recordsize = "1M";
                "com.sun:auto-snapshot" = "false";
              };
            };

            "data/media/shows" = {
              type = "zfs_fs";
              mountpoint = "/data/media/shows";
              options = {
                compression = "off";
                recordsize = "1M";
                "com.sun:auto-snapshot" = "false";
              };
            };

            "data/media/photos" = {
              type = "zfs_fs";
              mountpoint = "/data/media/photos";
              options = {
                compression = "off";
                recordsize = "1M";
                "com.sun:auto-snapshot" = "true";
              };
            };

            # syncoid replication target for fast/*
            "data/backups" = {
              type = "zfs_fs";
              mountpoint = "/data/backups";
              options.canmount = "off";
              options."com.sun:auto-snapshot" = "false";
            };

            "data/backups/fast" = {
              type = "zfs_fs";
              mountpoint = "/data/backups/fast";
              options.canmount = "off";
              options."com.sun:auto-snapshot" = "false";
            };
          };
        };
      };
    };
  };
}
