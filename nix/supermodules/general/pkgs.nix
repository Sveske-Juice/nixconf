{self, ...}: {
  flake.nixosModules.general = {pkgs, ...}: {
    imports = [
      self.nixosModules.neovim
    ];

    environment.systemPackages = with pkgs; [
      self.packages.${pkgs.stdenv.hostPlatform.system}.tmux
      fastfetch
      btop

      net-tools
      bind
      iputils
      traceroute
      nmap
      tcpdump

      zip
      unzip
    ];
  };
}
