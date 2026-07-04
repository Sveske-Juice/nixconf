{inputs, ...}: {
  flake.nixosModules.base = _: {
    imports = [
      # We need sops options always, but the actual deployment configuration
      # gets conditionally imported depending on whether or not secrets are on
      inputs.sops-nix.nixosModules.sops

      inputs.disko.nixosModules.default
    ];
  };
}
