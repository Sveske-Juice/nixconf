{self, inputs, ...}: 
{
  flake.nixosConfigurations.themata = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.hostThemata
    ];
  };

  flake.nixosModules.hostThemata = {pkgs, ...}: {
    imports = [
      self.nixosModules.base
    ];

    preferences.user.name = "cvpl";

    system.stateVersion = "26.05";
  };
}
