{inputs, ...}: let
  inherit (inputs.nixpkgs) lib;
in {
  flake.lib.mkLarryDisko = {
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
                  type = "swap";
                  discardPolicy = "both";
                  resumeDevice = true;
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };
  };
}
