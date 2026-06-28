{self, ...}: {
  flake.nixosModules.user-larry = {
    lib,
    isVM,
    pkgs,
    ...
  }: {
    preferences.user = {
      name = "larry";
    };
  };
}
