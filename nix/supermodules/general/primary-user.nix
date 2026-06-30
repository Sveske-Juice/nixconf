# Generates a simple user defined in options.preferences.user
{
  flake.nixosModules.general = {
    lib,
    config,
    ...
  }: {
    users.mutableUsers = false;

    sops.secrets."users/${config.preferences.user.name}" = lib.mkIf config.preferences.secrets {
      sopsFile = lib.path.append ../../../secrets/users "${config.preferences.user.name}.yaml";
      neededForUsers = true;
    };

    users.users."${config.preferences.user.name}" = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
      password = lib.mkIf (!config.preferences.secrets) config.preferences.user.name;
      hashedPasswordFile = lib.mkIf config.preferences.secrets config.sops.secrets."users/${config.preferences.user.name}".path;
    };
  };
}
