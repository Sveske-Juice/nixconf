{
self,
inputs,
...
}: {
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

  perSystem = {pkgs, ...}: {
    packages.kitty = inputs.wrapper-modules.wrappers.kitty.wrap {
      inherit pkgs;
      imports = [self.wrappersModules.kitty];
    };
  };
}
