{
  flake.nixosModules.greetd-noctalia-greeter = {
    services.displayManager.noctalia-greeter = {
      enable = true;
    };
  };
}
