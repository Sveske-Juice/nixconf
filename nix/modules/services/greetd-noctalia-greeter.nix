{inputs, ...}: {
  flake.nixosModules.greetd-noctalia-greeter = {
    imports = [
      inputs.noctalia-greeter.nixosModules.default
    ];

    programs.noctalia-greeter = {
      enable = true;

      greeter-args = "";
    };
  };
}
