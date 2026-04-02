{self, ...}: {
  flake.nixosModules.base = _: {
    # We need sops options always, but the actual deployment configuration 
    # gets conditionally imported depending on whether or not secrets are on
    imports = [
      self.inputs.sops-nix.nixosModules.sops
    ];

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Takes forever on rebuild, don't need it
    documentation.man.cache.enable = false;
  };
}
