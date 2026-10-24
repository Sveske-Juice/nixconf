{inputs, ...}: {
  flake.nixosModules.greetd-noctalia-greeter = {
    imports = [
      inputs.noctalia-greeter.nixosModules.default
    ];

    services.displayManager.noctalia-greeter = {
      enable = true;

      greeter-args = "";
    };
  };
}
