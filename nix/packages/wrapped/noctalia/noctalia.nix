{inputs, ...}: {
  flake.wrappers.noctalia-shell = {
    wlib,
    pkgs,
    ...
  }: {
    imports = [
      wlib.wrapperModules.noctalia-shell
    ];
    package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
}
