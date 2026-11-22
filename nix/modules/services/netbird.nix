{
  flake.nixosModules.netbird = {
    services.netbird = {
      enable = true;
    };
  };
}
