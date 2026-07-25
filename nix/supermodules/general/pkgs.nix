{self, ...}: {
  flake.nixosModules.general = {pkgs, ...}: {
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
      ntp

      zip
      unzip
    ];
  };
}
