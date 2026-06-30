{
  flake.nixosModules.base = _: {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Allow remote rebuilds
    nix.settings.trusted-users = ["root" "@wheel"];

    # Takes forever on rebuild, don't need it
    documentation.man.cache.enable = false;
  };
}
