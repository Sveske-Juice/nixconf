_: {
  flake.nixosModules.driver-pipewire = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      pavucontrol
      pwvucontrol
      coppwr
      helvum
    ];

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };
}
