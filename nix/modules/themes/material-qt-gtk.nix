# This is a vibe coded mess, but i really dont want to spend time on figuring
# this out myself
{
  flake.nixosModules.theme-material-qt-gtk = {config, pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      # gtk
      materia-theme
      # kvantum
      materia-kde-theme

      libsForQt5.qtstyleplugin-kvantum
      libsForQt5.qt5ct
      qt6Packages.qt6ct

      # kvantum manager
      kdePackages.qtstyleplugin-kvantum

      papirus-icon-theme
    ];

    environment.sessionVariables.QT_QPA_PLATFORMTHEME = "qt5ct";

    hjem.users."${config.preferences.user.name}".files = {
      ".config/Kvantum/MateriaDark".source = "${pkgs.materia-kde-theme}/share/Kvantum/MateriaDark";

      ".config/qt5ct/qt5ct.conf".text = ''
        [Appearance]
        style=kvantum
        icon_theme=Papirus-Dark
      '';

      ".config/qt6ct/qt6ct.conf".text = ''
        [Appearance]
        style=kvantum
        icon_theme=Papirus-Dark
      '';

      ".config/Kvantum/kvantum.kvconfig".text = ''
        [General]
        theme=MateriaDark
      '';

      ".config/gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-theme-name=Materia-dark
        gtk-icon-theme-name=Papirus-Dark
        gtk-application-prefer-dark-theme=true
      '';

      ".config/gtk-4.0/settings.ini".text = ''
        [Settings]
        gtk-theme-name=Materia-dark
        gtk-icon-theme-name=Papirus-Dark
        gtk-application-prefer-dark-theme=true
      '';
    };
  };
}
