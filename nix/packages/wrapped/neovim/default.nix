{
  flake-parts-lib,
  inputs,
  lib,
  ...
} @ top: {
  options.flake = flake-parts-lib.mkSubmoduleOptions {
    nvfModules = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.deferredModule;
      default = {};
      description = "nvf module fragments";
    };
  };

  options.perSystem = flake-parts-lib.mkPerSystemOption ({
    pkgs,
    config,
    ...
  }: {
    config.packages = {
      neovim = config.packages.neovim-minimal;
      neovim-minimal =
        (inputs.nvf.lib.neovimConfiguration {
          inherit pkgs;
          modules = with top.config.flake.nvfModules; [core];
        }).neovim;
      neovim-max =
        (inputs.nvf.lib.neovimConfiguration {
          inherit pkgs;
          modules = with top.config.flake.nvfModules; [core lsp];
        }).neovim;
    };
  });

  config.perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  };
}
