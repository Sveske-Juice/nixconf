{self, ...}: {
  flake.nixosModules.kitty = {pkgs, ...}: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.kitty
    ];
  };

  flake.wrappersModules.kitty = {
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 15;
    };

    settings = {
      enable_audio_bell = "no";

      cursor_text_color = "background";

      allow_remote_control = "yes";
      shell_integration = "enabled";

      cursor_trail = 3;
    };
  };

  flake.wrappers.kitty = {wlib, ...}: {
    imports = [
      wlib.wrapperModules.kitty
      self.wrappersModules.kitty
    ];
  };
}
