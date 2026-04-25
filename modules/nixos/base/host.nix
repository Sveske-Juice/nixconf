{
  flake.nixosModules.base = {lib, config, ...}: {
    options.preferences.host = lib.mkOption {
      type = lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
          };
        };
      };
    };

    config = {
      networking.hostName = config.preferences.host.name;
    };
  };
}
