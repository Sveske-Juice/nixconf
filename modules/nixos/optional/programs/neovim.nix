{self, ...}: {
  flake.nixosModules.neovim = {pkgs, ...}: {
    # TODO: option for the neovim package to use: minimal/max
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.neovim
    ];
  };
}
