# inspiration: https://github.com/mateusauler/nixos-config
{
  flake.nixosModules.general = {
    lib,
    config,
    pkgs,
    ...
  }: let
    sopsKeyPath = "gpg/key";
    sopsPasswdPath = "gpg/passphrase";
    gnupgphome = "${config.preferences.user.home}/.gnupg";
    getSecretKeyIDs = "$(${pkgs.gnupg}/bin/gpg --list-secret-keys --keyid-format LONG | ${pkgs.gawk}/bin/awk '/sec/{if (match($0, /([0-9A-F]{16,})/, m)) print m[1]}')";
    cfg = config.deploy-gpg;
  in {
    options.deploy-gpg.enable = lib.mkOption {
      type = lib.types.bool;
      default = config.preferences.secrets;
    };

    config = lib.mkIf cfg.enable {
      sops.secrets."${sopsKeyPath}" = {
        owner = config.preferences.user.name;
        sopsFile = ../../../../secrets/users/${config.preferences.user.name}.yaml;
      };

      sops.secrets."${sopsPasswdPath}" = {
        owner = config.preferences.user.name;
        sopsFile = ../../../../secrets/users/${config.preferences.user.name}.yaml;
      };

      systemd.services.deploy-gpg = {
        description = "Deploy a user's PGP key";
        wantedBy = ["multi-user.target"];
        after = ["sops-nix.service"];
        serviceConfig = {
          Type = "oneshot";
          User = config.preferences.user.name;
          ExecStart = "${
            pkgs.writeShellScript "deploy-gpg.sh" # bash
            
            ''
              if [ -s ${config.sops.secrets."${sopsKeyPath}".path} ]; then
                mkdir -p ${gnupgphome} -m "0700"
                cat "${config.sops.secrets."${sopsPasswdPath}".path}" | ${pkgs.gnupg}/bin/gpg --passphrase-fd 0 --pinentry-mode loopback --import ${
                config.sops.secrets."${sopsKeyPath}".path
              }

                # Set passwd
                if [ -s ${config.sops.secrets."${sopsPasswdPath}".path} ]; then
                  secretKeyId=${getSecretKeyIDs}
                  for key in ''${secretKeyId[@]}
                  do
                    cat "${config.sops.secrets."${sopsPasswdPath}".path}" | ${pkgs.gnupg}/bin/gpg --batch --passphrase-fd 0 --pinentry-mode loopback --edit-key $key passwd quit
                  done
                fi
              fi
            ''
          }";
        };
      };

      services.pcscd.enable = true;
      programs.gnupg.agent = {
        enable = true;
        pinentryPackage = pkgs.pinentry-gtk2;
        enableSSHSupport = true;
      };
    };
  };
}
