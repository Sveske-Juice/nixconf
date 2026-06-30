_: {
  flake.nixosModules.user-larry = {config, ...}: {
    preferences.user = {
      name = "larry";
    };

    keyGroups.larry-ssh = with config.keys.ssh; [
      pixel9a
      dr3y
    ];

    users.users."${config.preferences.user.name}".openssh.authorizedKeys.keys = config.keyGroups.larry-ssh;
  };
}
