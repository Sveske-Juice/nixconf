{inputs, ...}: {
  flake.nixosModules.noctalia = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      inputs.qtengine.nixosModules.default
    ];

    environment.variables.QT_QPA_PLATFORMTHEME = "qtengine";

    environment.systemPackages = with pkgs; [
      satty
      ddcutil

      adw-gtk3
      nwg-look
      papirus-icon-theme

      materia-kde-theme
      kdePackages.qtstyleplugin-kvantum
    ];

    programs.qtengine = {
      enable = true;

      config = {
        theme = {
          colorScheme = "${config.preferences.user.home}/.local/share/color-schemes/noctalia.colors";
          iconTheme = "Papirus-Dark";
          style = "kvantum";
        };

        misc = {
          singleClickActivate = false;
          menusHaveIcons = true;
          shortcutsForContextMenus = true;
        };
      };
    };

    hjem = {
      extraModules = [
        inputs.noctalia.hjemModules.default
      ];

      users."${config.preferences.user.name}" = {
        programs.noctalia = {
          enable = true;

          settings = fromTOML <| builtins.readFile ./noctalia.toml;
        };

        files = {
          # QT Style
          ".config/Kvantum/MateriaDark".source = "${pkgs.materia-kde-theme}/share/Kvantum/MateriaDark";
          ".config/Kvantum/kvantum.kvconfig".text = ''
            [General]
            theme=MateriaDark
          '';

          # adw-gtk3 and icon theme for GTK
          ".config/xsettingsd/xsettingsd.conf".text = ''
            Net/ThemeName "adw-gtk3"
            Net/IconThemeName "Papirus-Dark"
            Gtk/CursorThemeName "Adwaita"
            Net/EnableEventSounds 1
            EnableInputFeedbackSounds 0
            Xft/Antialias 1
            Xft/Hinting 1
            Xft/HintStyle "hintslight"
            Xft/RGBA "rgb"
          '';
          ".config/gtk-3.0/settings.ini".text = ''
            [Settings]
            gtk-theme-name=adw-gtk3
            gtk-icon-theme-name=Papirus-Dark
            gtk-application-prefer-dark-theme=true
          '';
          ".config/gtk-4.0/settings.ini".text = ''
            [Settings]
            gtk-theme-name=adw-gtk3
            gtk-icon-theme-name=Papirus-Dark
            gtk-application-prefer-dark-theme=true
          '';
        };
      };
    };
  };
}
