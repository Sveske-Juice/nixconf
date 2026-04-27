{
  flake.nixosModules.greetd = {lib, pkgs, ...}: {
    # TODO : make this agnostic of the DE/WM you use
    environment.etc."greetd/environments".text = ''
      niri-session
      niri
      fish
      bash
    '';

    services.greetd = let
      swayConfig = pkgs.writeText "greetd-sway-config" ''
        # Fixes timeout issue when launching
        # https://github.com/swaywm/sway/wiki#systemd-and-dbus-activation-environments
        exec ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP XDG_SESSION_TYPE

        # `-l` activates layer-shell mode. Notice that `swaymsg exit` will run after gtkgreet.
        exec "${pkgs.gtkgreet}/bin/gtkgreet -l; swaymsg exit"
        bindsym Mod4+shift+e exec swaynag \
          -t warning \
          -m 'What do you want to do?' \
          -b 'Poweroff' 'systemctl poweroff' \
          -b 'Reboot' 'systemctl reboot'
      '';
    in {
      enable = true;
      settings = {
        default_session = {
          command = "${lib.getExe pkgs.sway} --config ${swayConfig}";
        };
      };
    };
  };
}
