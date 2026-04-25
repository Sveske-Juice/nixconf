{
  flake.nixosModules.gaming = {pkgs, ...}: {
    programs = {
      gamemode.enable = true;
      gamescope.enable = true;
      steam = {
        enable = true;
        protontricks.enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      gamescope

      steam-run
      prismlauncher
      mangohud
    ];

    allowedUnfreePackages = [
      "steam"
      "steam-original"
      "steam-unwrapped"
      "steam-run"
    ];
  };
}
