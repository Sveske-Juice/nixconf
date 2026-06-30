{
  flake.nixosModules.base = {
    lib,
    config,
    ...
  }: {
    options.allowedUnfreePackages = lib.mkOption {
      default = [];
      type = lib.types.listOf lib.types.str;
    };

    config = {
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.allowedUnfreePackages;
    };
  };
}
