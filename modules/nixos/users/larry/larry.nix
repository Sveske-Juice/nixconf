{self, ...}: {
  flake.nixosModules.user-larry = {
    lib,
    isVM,
    pkgs,
    config,
    ...
  }: {
    preferences.user = {
      name = "larry";
    };

    keyGroups.larry-ssh = with config.keys.ssh; [
      pixel9a
    ];
  };
}
