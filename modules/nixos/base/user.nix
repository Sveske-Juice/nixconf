{
  flake.nixosModules.base = {
    self',
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
          home = lib.mkOption {
            type = lib.types.str;
            description = "Home directory of user";
            default = let
              user = self'.config.preferences.user.name;
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
