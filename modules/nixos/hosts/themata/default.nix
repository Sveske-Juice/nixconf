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
      self.nixosModules.secrets
    ];

    preferences = {
      host = {
        name = "themata";
      };
      user = {
        name = "cvpl";
      };
    };

    system.stateVersion = "26.05";
  };
}
