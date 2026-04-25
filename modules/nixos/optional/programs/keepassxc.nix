{
  flake.nixosModules.keepassxc = {config, ...}: {
    hjem.users."${config.preferences.user.name}".rum.programs.keepassxc = {
      enable = true;
      # https://github.com/keepassxreboot/keepassxc/blob/develop/src/core/Config.cpp
      settings = {
        GUI = {
          ColorPasswords = true;
          MinimizeOnClose = true;
          MinimizeOnStartup = true;
          MinimizeToTray = true;
          ShowTrayIcon = true;
          TrayIconAppearance = "colorful";
        };
        Security = {
          ClearClipboardTimeout = 60;
          LockDatabaseIdleSeconds = 60 * 15;
        };
        General = {
          BackupBeforeSave = true;
          ConfigVersion = 2;
        };
        Browser = {
          Enabled = true;
        };
      };
    };
  };
}
