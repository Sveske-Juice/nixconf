{self, ...}: {
  flake.nixosModules.user-walther = {config, ...}: let
    name = "walther";
  in {
    imports = [
      self.nixosModules.neovim
    ];

    config = {
      preferences.user = {
        inherit name;
        email = "sveske_juice@tuta.com";
      };

      keyGroups.walther-ssh = with config.keys.ssh; [
        pixel9a
        dr3y
      ];

      users.users."${name}".openssh.authorizedKeys.keys = config.keyGroups.walther-ssh;
    };
  };
}
