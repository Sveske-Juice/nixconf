# Configuration that is common for all desktop systems
# Except:
# Actual DE/WM
# XDG Desktop portal
{self, ...}: {
  flake.nixosModules.desktop = {pkgs, ...}: {
    imports = [
      self.nixosModules.driver-pipewire
      self.nixosModules.driver-bluetooth
    ];

    hardware.graphics.enable = true;
    security.polkit.enable = true;

    environment.systemPackages = with pkgs; [
      wl-clipboard
    ];

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      ubuntu-sans
      cm_unicode
      corefonts
      unifont
    ];

    allowedUnfreePackages = [
      "corefonts"
    ];
  };
}
