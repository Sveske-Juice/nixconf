{
  flake.nixosModules.base = {lib, ...}: {
    options.preferences.host = lib.mkOption {
      type = lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
          };
        };
      };
    };
  };
}
