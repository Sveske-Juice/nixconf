# Generates a simple user defined in options.preferences.user
{
  flake.nixosModules.general = {lib, config, ...}: {
    users.mutableUsers = false;

    sops.secrets."passwords/${config.preferences.user.name}" = lib.mkIf config.preferences.secrets {};

    users.users."${config.preferences.user.name}" = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
      ];
      password = lib.mkIf (!config.preferences.secrets) config.preferences.user.name;
      hashedPasswordFile = lib.mkIf config.preferences.secrets config.sops.secrets."passwords/${config.preferences.user.name}".path;
    };
  };
}
