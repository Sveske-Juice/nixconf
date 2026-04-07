{
  self,
  inputs,
  ...
}: {
  flake.wrappersModules.niri = {
    lib,
    pkgs,
    ...
  }: {
    settings = {
      binds = {
        "Mod+Return".spawn = "${lib.getExe pkgs.kitty}";
      };
    };
  };

  perSystem = {pkgs, ...}: {
    packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      imports = [self.wrappersModules.niri];
    };
  };
}
