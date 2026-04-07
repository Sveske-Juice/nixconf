_: {
  flake.nixosModules.user-dr3y = {config, ...}: {
    preferences.user = {
      name = "dr3y";
      email = "sveske_juice@tuta.com";
    };

    deploy-gpg.enable = config.preferences.secrets;
  };
}
