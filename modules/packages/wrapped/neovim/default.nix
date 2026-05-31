# A "hacky" way to integrate NVF so every file is at a toplevel definition
# (dentritic pattern). Every nvf file populates the options.nvfModules list
# which gets collected and evaulated by nvf to produce the neovim package.
{
  flake-parts-lib,
  inputs,
  ...
}: {
  # https://flake.parts/generate-documentation.html?highlight=mkPer#make-sure-to-use-mkpersystemoption
  options.perSystem = flake-parts-lib.mkPerSystemOption ({
    lib,
    config,
    pkgs,
    ...
  }: {
    options.nvfModules = lib.mkOption {
      type = lib.types.listOf lib.types.deferredModule;
      default = [];
      description = ''
        NVF modules to be merged into neovimConfiguration
      '';
    };
    config.packages.neovim =
      (inputs.nvf.lib.neovimConfiguration {
        inherit pkgs;
        modules = config.nvfModules;
      }).neovim;
  });

  config.perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  };
}
