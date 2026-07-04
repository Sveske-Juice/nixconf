{inputs, ...}: {
  flake.nixosModules.general = {config, ...}: {
    imports = [
      inputs.hjem.nixosModules.default
    ];
    hjem = {
      extraModules = [
        inputs.hjem-rum.hjemModules.default
      ];
      clobberByDefault = true;

      users."${config.preferences.user.name}" = {
        enable = true;
        directory = "${config.preferences.user.home}";
        user = "${config.preferences.user.name}";
      };
    };
  };
}
