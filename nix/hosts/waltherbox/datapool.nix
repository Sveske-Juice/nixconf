{
  flake.nixosModules.host-waltherbox = {config, ...}: {
    users.groups.media = {
      gid = 9000;
    };
    users.groups.photos = {
      gid = 9001;
    };

    users.users.${config.preferences.user.name}.extraGroups = ["media" "photos"];

    # Recursively set owner and use setgid bit so new files/dirs will be
    # created with parent group
    systemd.tmpfiles.rules = [
      "d /data/media 2770 root media - - "
      "Z /data/media/movies 2770 root media - -"
      "Z /data/media/shows 2770 root media - -"
      "Z /data/media/photos 2770 root photos - -"
    ];
  };
}
