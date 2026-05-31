{
  flake.nixosModules.host-lateralus = {
    networking.networkmanager.enable = true;
  };
}
