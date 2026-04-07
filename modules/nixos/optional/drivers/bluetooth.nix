_: {
  flake.nixosModules.driver-bluetooth = {pkgs, ...}: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;

      settings = {
        General.Experimental = true;
        Policy.AutoEnable = true;
      };
    };

    # Blueman
    services.blueman.enable = true;

    # Headset buttons with MPRIS proxy
    systemd.user.services.mpris-proxy = {
      description = "Mpris proxy";
      after = [
        "network.target"
        "sound.target"
      ];
      wantedBy = [ "default.target" ];
      serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
    };
  };
}
