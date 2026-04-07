{
  flake.nixosModules.base = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.preferences.user = lib.mkOption {
      type = lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
          };
          email = lib.mkOption {
            type = lib.types.str;
          };
          gpgKey = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
          };
          home = lib.mkOption {
            type = lib.types.str;
            description = "Home directory of user";
            default = let
              user = config.preferences.user.name;
            in
              if pkgs.stdenv.isLinux
              then "/home/${user}"
              else "/Users/${user}";
          };
        };
      };
    };
  };
}
