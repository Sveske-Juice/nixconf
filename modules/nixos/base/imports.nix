{self, ...}: {
  flake.nixosModules.base = _: {
    imports = [
      # We need sops options always, but the actual deployment configuration
      # gets conditionally imported depending on whether or not secrets are on
      self.inputs.sops-nix.nixosModules.sops

      self.inputs.disko.nixosModules.default
    ];
  };
}
