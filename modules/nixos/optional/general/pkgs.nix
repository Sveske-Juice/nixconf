{self, ...}: {
  flake.nixosModules.general = {pkgs, ...}: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.tmux
      pkgs.fastfetch
    ];
  };
}
