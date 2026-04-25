{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.niri = {pkgs, ...}: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
    };
  };

  flake.wrappersModules.niri = {
    lib,
    pkgs,
    config,
    ...
  }: {
    options = {
      terminal = lib.mkOption {
        type = lib.types.str;
        default = "xdg-terminal-exec || $TERMINAL";
        example = "kitty";
      };
      browser = lib.mkOption {
        type = lib.types.str;
        default = "xdg-open https://";
        example = "firefox";
      };
      filemanager = lib.mkOption {
        type = lib.types.str;
        default = ''xdg-open getenv("HOME")'';
        example = "thunar";
      };
    };

    config = {
      settings = let
        noctaliaExe = lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-shell;
      in {
        prefer-no-csd = {};

        input = {
          focus-follows-mouse = {};

          keyboard = {
            xkb = {
              layout = "dk";
            };
            repeat-rate = 40;
            repeat-delay = 250;
          };

          touchpad = {
            natural-scroll = {};
            tap = {};
          };

          mouse = {
            accel-profile = "flat";
          };
        };
        binds = let
          screenshotExe = "${pkgs.hyprshot}/bin/hyprshot -m region --raw | ${pkgs.satty}/bin/satty --filename - --early-exit --actions-on-enter save-to-clipboard --copy-command 'wl-copy'";
        in {
          "Mod+Return".spawn-sh = "${config.terminal}";
          "Mod+B".spawn-sh = "${config.browser}";
          "Mod+W".spawn = "${config.filemanager}";

          "Mod+Q".close-window = {};
          "Mod+F".maximize-column = {};
          "Mod+G".fullscreen-window = {};
          "Mod+Shift+F".toggle-window-floating = {};
          "Mod+E".center-column = {};

          "Mod+H".focus-column-left = {};
          "Mod+L".focus-column-right = {};
          "Mod+K".focus-window-up = {};
          "Mod+J".focus-window-down = {};

          "Mod+Left".focus-column-left = {};
          "Mod+Right".focus-column-right = {};
          "Mod+Up".focus-window-up = {};
          "Mod+Down".focus-window-down = {};

          "Mod+Shift+H".move-column-left = {};
          "Mod+Shift+L".move-column-right = {};
          "Mod+Shift+K".move-window-up = {};
          "Mod+Shift+J".move-window-down = {};

          "Mod+O".toggle-overview = {};
          "XF86SelectiveScreenshot".spawn-sh = screenshotExe;
          "Print".spawn-sh = screenshotExe;
          "Mod+S".spawn-sh = screenshotExe;

          "Mod+D".spawn-sh = "${noctaliaExe} ipc call launcher toggle";
          "Mod+C".spawn-sh = "${noctaliaExe} ipc call launcher clipboard";
          "Mod+U".spawn-sh = "${noctaliaExe} ipc call lockScreen lock";

          "Mod+Z".spawn-sh = "${noctaliaExe} ipc call volume muteInput";
          "XF86AudioMicMute".spawn-sh = "${noctaliaExe} ipc call volume muteInput";
          "XF86AudioRaiseVolume".spawn-sh = "${noctaliaExe} ipc call volume increase";
          "XF86AudioLowerVolume".spawn-sh = "${noctaliaExe} ipc call volume decrease";

          "XF86AudioPlay".spawn-sh = "${noctaliaExe} ipc call media playPause";
          "XF86AudioPrev".spawn-sh = "${noctaliaExe} ipc call media previous";
          "XF86AudioNext".spawn-sh = "${noctaliaExe} ipc call media next";

          "XF86MonBrightnessUp".spawn-sh = "${noctaliaExe} ipc call brightness increase";
          "XF86MonBrightnessDown".spawn-sh = "${noctaliaExe} ipc call brightness decrease";
        };
        layout = {
          gaps = 5;
          focus-ring = {
            width = 2;
          };
        };

        xwayland-satellite.path =
          lib.getExe config.pkgs.xwayland-satellite;

        spawn-at-startup = [
          noctaliaExe
        ];
      };
    };
  };

  perSystem = {pkgs, ...}: {
    packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      imports = [self.wrappersModules.niri];
    };
  };
}
