{
  flake.nixosModules.godot-mono = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.godot-mono
    ];
  };
}
