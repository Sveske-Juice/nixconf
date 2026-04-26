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
      extraPackages = [
        pkgs.bibata-cursors
      ];
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

        cursor = {
          xcursor-theme = "Bibata-Modern-Classic";
          xcursor-size = 24;
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

          "Mod+Left".focus-column-left = {};
          "Mod+Right".focus-column-right = {};
          "Mod+Up".focus-window-or-workspace-up = {};
          "Mod+Down".focus-window-or-workspace-down = {};
          "Mod+H".focus-column-left = {};
          "Mod+L".focus-column-right = {};
          "Mod+K".focus-window-or-workspace-up = {};
          "Mod+J".focus-window-or-workspace-down = {};

          "Mod+Shift+H".move-column-left = {};
          "Mod+Shift+L".move-column-right = {};
          "Mod+Shift+K".move-window-up = {};
          "Mod+Shift+J".move-window-down = {};

          "Mod+O".toggle-overview = {};
          "XF86SelectiveScreenshot".spawn-sh = screenshotExe;
          "Print".spawn-sh = screenshotExe;
          "Mod+S".spawn-sh = screenshotExe;

          "Mod+Shift+S".spawn-sh = "${noctaliaExe} ipc call settings toggle";
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

          "Mod+1".focus-workspace = "w0";
          "Mod+2".focus-workspace = "w1";
          "Mod+3".focus-workspace = "w2";
          "Mod+4".focus-workspace = "w3";
          "Mod+5".focus-workspace = "w4";
          "Mod+6".focus-workspace = "w5";
          "Mod+7".focus-workspace = "w6";
          "Mod+8".focus-workspace = "w7";
          "Mod+9".focus-workspace = "w8";
          "Mod+0".focus-workspace = "w9";

          "Mod+Shift+1".move-column-to-workspace = "w0";
          "Mod+Shift+2".move-column-to-workspace = "w1";
          "Mod+Shift+3".move-column-to-workspace = "w2";
          "Mod+Shift+4".move-column-to-workspace = "w3";
          "Mod+Shift+5".move-column-to-workspace = "w4";
          "Mod+Shift+6".move-column-to-workspace = "w5";
          "Mod+Shift+7".move-column-to-workspace = "w6";
          "Mod+Shift+8".move-column-to-workspace = "w7";
          "Mod+Shift+9".move-column-to-workspace = "w8";
          "Mod+Shift+0".move-column-to-workspace = "w9";
        };
        layout = {
          gaps = 5;
          focus-ring = {
            width = 2;
          };
        };

        workspaces = let
          settings = {layout.gaps = 5;};
        in {
          "w0" = settings;
          "w1" = settings;
          "w2" = settings;
          "w3" = settings;
          "w4" = settings;
          "w5" = settings;
          "w6" = settings;
          "w7" = settings;
          "w8" = settings;
          "w9" = settings;
        };

        xwayland-satellite.path =
          lib.getExe config.pkgs.xwayland-satellite;

        spawn-at-startup = [
          noctaliaExe
        ];
      };
    };
  };

  flake.wrappers.niri = {wlib, ...}: {
    imports = [
      wlib.wrapperModules.niri
      self.wrappersModules.niri
    ];
  };
}
