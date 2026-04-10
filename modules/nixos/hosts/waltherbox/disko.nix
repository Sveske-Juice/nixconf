{inputs, ...}: let
  inherit (inputs.nixpkgs) lib;
in {
  flake.nixosModules.host-waltherbox = {pkgs, ...}: {
    # Required by ZFS
    networking.hostId = "deadbeef"; # hehe

    environment.systemPackages = with pkgs; [
      zfs
    ];

    boot.zfs.devNodes = lib.mkDefault "/dev/disk/by-path";
  };

  flake.lib.mkWaltherboxDisko = {
    rootDisk,
    rootDiskSize ? "100%",
    raidz1DisksSize ? "100%",
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
            imageSize = rootDiskSize;
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
          imageSize = raidz1DisksSize;
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
            canmount = "off";
            acltype = "posixacl";
            xattr = "sa";
            atime = "off"; # disable access time better performance
          };

          options = {
            ashift = "12"; # 4K blocksize
            autotrim = "on";
          };

          datasets = {
            root = {
              type = "zfs_fs";
              mountpoint = "/";
            };
            nix = {
              type = "zfs_fs";
              mountpoint = "/nix";
            };
            var = {
              type = "zfs_fs";
              mountpoint = "/var";
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
            };
          };
        };
      };
    };
  };
}
