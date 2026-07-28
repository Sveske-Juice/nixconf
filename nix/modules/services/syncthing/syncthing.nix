{
  flake.nixosModules.syncthing = {
    config,
    lib,
    ...
  }: let
    allDevices = keys: builtins.attrNames keys.syncthing;
  in {
    sops.secrets = lib.mkIf config.preferences.secrets {
      "syncthing/certpem" = {
        owner = config.services.syncthing.user;
        inherit (config.services.syncthing) group;
      };

      "syncthing/keypem" = {
        owner = config.services.syncthing.user;
        inherit (config.services.syncthing) group;
      };

      "syncthing/passphrase" = {
        owner = config.services.syncthing.user;
        inherit (config.services.syncthing) group;
      };
    };

    keys.syncthing = {
      "waltherbox" = {
        id = "CFSOQNY-NLZ2S7O-DMDWYOG-RLMHLQI-2N36V56-GYEQHB3-CUHIDKJ-DSOVSAQ";
        introducer = true;
      };
      "solitubox" = {
        id = "OOHRI5F-LM7ZIHT-7NR2OYV-M63Q3YB-HPPT7MZ-ILCUFQI-MKDS3ZY-XDPVXQO";
      };
      "Pixel 9a" = {
        id = "ZW7BPJC-BIGKZ5G-7PVRC5X-CB4QUTN-UFH2SMP-7W4X4Q7-YVAW46S-2VELQAH";
      };
      "lateralus" = {
        id = "JKRSAY5-BZONGZW-2A4DUCM-KGBKJ6K-LKYJSCD-736OMPS-T2LOC4M-NQ3ARQW";
      };
      "themata" = {
        id = "4EJ2BB4-WTXP2P5-ISKZBAR-HFZSXLS-7AUW4TY-4AKEMDZ-OYLQQXA-MCCNJAZ";
      };
    };

    services.syncthing = {
      enable = true;
      openDefaultPorts = lib.mkDefault true;
      # Only open to localhost by default
      guiAddress = lib.mkDefault "127.0.0.1:8384";

      dataDir = lib.mkDefault config.preferences.user.home;
      user = config.preferences.user.name;
      inherit (config.users.users.${config.preferences.user.name}) group;
      cert = lib.mkIf config.preferences.secrets (lib.mkDefault config.sops.secrets."syncthing/certpem".path);
      key = lib.mkIf config.preferences.secrets (lib.mkDefault config.sops.secrets."syncthing/keypem".path);

      # Extracted in primary-user-nix
      guiPasswordFile = lib.mkIf config.preferences.secrets (lib.mkDefault config.sops.secrets."syncthing/passphrase".path);

      settings = {
        devices = config.keys.syncthing;
        gui = {
          user = config.preferences.user.name;
        };
        folders = {
          media = {
            path = "${config.services.syncthing.dataDir}/media";
            devices = [
              "solitubox"
              "lateralus"
              "waltherbox"
              "Pixel 9a"
            ];
          };
          commondocs = {
            path = "${config.services.syncthing.dataDir}/docs/common";
            devices = allDevices config.keys;
          };
          notes = {
            path = "${config.services.syncthing.dataDir}/notes";
            devices = allDevices config.keys;
          };
          secrets = {
            path = "${config.services.syncthing.dataDir}/secrets";
            devices = allDevices config.keys;
          };
        };
      };
    };
  };
}
