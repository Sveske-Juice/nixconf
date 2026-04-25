{inputs, ...}: {
  flake.nixosModules.general = {config, ...}: {
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
