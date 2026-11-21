{inputs, ...}: {
  flake.nixosModules.luciole = {config, ...}: {
    services.gvfs.enable = true;

    hjem = {
      extraModules = [ inputs.luciole.hjemModules.default ];
      users."${config.preferences.user.name}".programs.luciole = {
        enable = true;
      };
    };
  };
}
