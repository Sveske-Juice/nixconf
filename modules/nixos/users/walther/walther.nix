_: {
  flake.nixosModules.user-walther = _: {
    preferences.user = {
      name = "walther";
      email = "sveske_juice@tuta.com";
    };
  };
}
