# Generates a simple user defined in options.preferences.user
{
  flake.nixosModules.general = {config, ...}: {
    users.mutableUsers = false;

    users.users."${config.preferences.user.name}" = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
      ];
      password = "123";
    };
  };
}
