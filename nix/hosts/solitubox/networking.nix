{
  flake.nixosModules.host-solitubox = {
    networking.networkmanager.enable = true;

    networking.firewall.allowedTCPPorts = [6767];
    networking.firewall.allowedUDPPorts = [6767];
  };
}
