{self, ...}: {
  flake.nixosModules.general = {pkgs, ...}: {
    imports = [
      self.nixosModules.neovim
    ];

    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.tmux
      pkgs.fastfetch
      pkgs.btop
    ];
  };
}
