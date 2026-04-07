_: {
  flake.nixosModules.general = {
    pkgs,
    lib,
    config,
    ...
  }: {
    programs.git = {
      enable = true;
      package = pkgs.gitFull;

      config = {
        user = {
          inherit (config.preferences.user) name email;
          signingkey = lib.mkIf (config.preferences.user.gpgKey != null) config.preferences.user.gpgKey;
        };
        safe.directory = ["/etc/nixos"];
        commit = {
          gpgsign = lib.mkIf (config.preferences.user.gpgKey != null) true;
        };
        core = {
          whitespace = "error";
        };
        status = {
          branch = true;
          short = true;
          showStash = true;
        };
        push = {
          autoSetupRemote = true;
          followTags = true;
        };
        pull = {
          rebase = true;
        };
        rebase = {
          autoStash = true;
        };
        url = {
          "https://github.com/" = {
            insteadOf = [
              "gh:"
              "github:"
            ];
          };
        };
      };
    };
  };
}
