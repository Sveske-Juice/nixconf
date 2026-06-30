{
  flake.nixosModules.base = {
    lib,
    isVM,
    ...
  }: {
    options.preferences.secrets = lib.mkOption {
      type = lib.types.bool;
      default = !isVM;
      description = ''
        Is sops secrets enabled?
      '';
    };
  };
}
