{inputs, ...} : let
  inherit (inputs.nixpkgs) lib;
in {
  flake.lib.mkLateralusDisko = {
    rootDisk,
    rootDiskSize ? null,
    bootSize ? "1G",
    swapSize ? "1G",
  }: {
    disko.devices = {
      disk = {
        main = {
          type = "disk";
          device = rootDisk;
          imageSize = lib.mkIf (rootDiskSize != null) rootDiskSize;
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = bootSize;
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = ["defaults" "umask=0077"];
                };
              };

              swap = {
                size = swapSize;
                content = {
                  type = "luks";
                  name = "cryptswap";

                  settings = {
                    allowDiscards = true;
                  };

                  content = {
                    type = "swap";
                    randomEncryption = true;
                  };
                };
              };

              root = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "cryptroot";

                  settings = {
                    allowDiscards = true;
                  };

                  content = {
                    type = "filesystem";
                    format = "ext4";
                    mountpoint = "/";
                    mountOptions = ["defaults" "noatime"];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
