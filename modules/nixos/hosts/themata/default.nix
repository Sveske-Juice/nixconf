{self, inputs, ...}: 
{
  flake.nixosConfigurations.themata = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.hostThemata
    ];
  };

  flake.nixosModules.hostThemata = _: {
    imports = [
      self.nixosModules.base
      self.nixosModules.general
    ];

    preferences.user.name = "cvpl";

    system.stateVersion = "26.05";
  };
}
