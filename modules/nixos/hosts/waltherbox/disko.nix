{inputs, ...}: let
  inherit (inputs.nixpkgs) lib;
in {
  flake.nixosModules.host-waltherbox = {pkgs, ...}: {
    # Required by ZFS
    networking.hostId = "ea92eebd";

    environment.systemPackages = with pkgs; [
      zfs
    ];

    boot.zfs.devNodes = "/dev/disk/by-path";
  };

  flake.lib.mkWaltherboxDisko = {
    rootDisk,
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
        // lib.attrsets.genAttrs raidz1Disks (name: {
          type = "disk";
          device = "/dev/${name}";
          content = {
            type = "gpt";
            partitions = {
              zfs = {
                size = "100%";
                content = {
                  type = "zfs";
                  pool = "storage";
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
            acltype = "posixacl";
            xattr = "sa";
            atime = "off"; # disable access time better performance
          };

          datasets = {
            root = {
              type = "zfs_fs";
              mountpoint = "/";
              options.canmount = "on";
            };
            nix = {
              type = "zfs_fs";
              mountpoint = "/nix";
              options.canmount = "on";
            };
            var = {
              type = "zfs_fs";
              mountpoint = "/var";
              options.canmount = "on";
            };
            home = {
              type = "zfs_fs";
              mountpoint = "/home";
              options.canmount = "on";
            };
          };
        };

        storage = lib.mkIf (builtins.length raidz1Disks > 0) {
          type = "zpool";
          mode = "raidz";

          rootFsOptions = {
            mountpoint = "none";
            acltype = "posixacl";
            xattr = "sa";
            atime = "off";
          };

          datasets = {
            data = {
              type = "zfs_fs";
              mountpoint = "/data";
              options.canmount = "on";
            };
          };
        };
      };
    };
  };
}
