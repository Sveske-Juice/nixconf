{self, ...}: {
  flake.nixosModules.neovim = {pkgs, ...}: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.neovim
    ];

    environment.sessionVariables.EDITOR = "nvim";
  };

  flake.nixosModules.neovim-max = {pkgs, ...}: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.neovim-max
    ];

    environment.sessionVariables.EDITOR = "nvim";
  };
}
