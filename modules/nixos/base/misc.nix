_: {
  flake.nixosModules.base = _: {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Takes forever on rebuild, don't need it
    documentation.man.cache.enable = false;
  };
}
