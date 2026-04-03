{
  flake.nixosModules.general = {pkgs, ...}: {
    users.defaultUserShell = pkgs.fish;

    environment.systemPackages = with pkgs; [
      fishPlugins.z
    ];

    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
      '';
    };

    programs.starship = {
      enable = true;
    };
  };
}
