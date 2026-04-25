{
  flake.nixosModules.base = {
    lib,
    config,
    ...
  }: {
    options = {
      keyGroups = lib.mkOption {
        default = {};
        description = "Attrs of named groups of keys";
        type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      };
      keys = lib.mkOption {
        default = {};
        type = lib.types.submodule {
          options = {
            ssh = lib.mkOption {
              default = {};
              description = "Named public ssh keys";
              type = lib.types.attrsOf lib.types.str;
              example = {
                "host1" = "pubkey1";
                "host2" = "pubkey2";
              };
            };
            syncthing = lib.mkOption {
              default = {};
              description = "Named syncthing IDs";
              type = lib.types.attrsOf (lib.types.submodule {
                options = {
                  id = lib.mkOption {
                    description = "Syncthing device ID";
                    type = lib.types.str;
                  };
                  introducer = lib.mkOption {
                    type = lib.types.bool;
                    default = false;
                  };
                };
              });
            };
          };
        };
      };
    };
    config = {
      keyGroups.allSsh = builtins.attrValues config.keys.ssh;

      keys.ssh = {
        "pixel9a" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKeDUjke9DCqWRgQy7UFiCiTeIid6pXyzSTqYWS7MDf9 u0_a254@localhost";
      };
    };
  };
}
