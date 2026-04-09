# Generates root user
{
  flake.nixosModules.general = {
    lib,
    config,
    ...
  }: {
    users.mutableUsers = false;

    sops.secrets."users/root" = lib.mkIf config.preferences.secrets {
      neededForUsers = true;
    };

    users.users.root = {
      password = "root";
      # password = lib.mkIf (!config.preferences.secrets) "root";
      # hashedPasswordFile = lib.mkIf config.preferences.secrets config.sops.secrets."users/root".path;
    };
  };
}
