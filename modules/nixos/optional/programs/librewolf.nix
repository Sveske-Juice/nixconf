{
  flake.nixosModules.librewolf = {pkgs, ...}: {
    environment.etc."firefox/policies/policies.json".target = "librewolf/policies/policies.json";

    programs.firefox = {
      enable = true;
      package = pkgs.librewolf;
      nativeMessagingHosts.packages = [
        pkgs.keepassxc
      ];
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        PasswordManagerEnabled = false; # use own password manager
        RequestedLocales = [
          "da"
          "en-US"
        ];
        SearchEngines = {
          Default = "DuckDuckGo";
        };
        Preferences = {
          "webgl.disabled" = false;
          "privacy.resistFingerprinting" = true;
          "privacy.clearOnShutdown.history" = false;
          "privacy.clearOnShutdown.cookies" = false;
          "network.cookie.lifetimePolicy" = 0;
          "privacy.fingerprintingProtection" = true;
        };
        # To add new extensions:
        # 1. Install extension from GUI
        # go to about:debugging
        # This Librewolf->Extensions
        # find the extension ID
        # install_url = "https://addons.mozilla.org/firefox/downloads/latest/{extension name}/latest.xpi"
        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = true;
          };
          "addon@darkreader.org" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = true;
          };
          "{a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/user-agent-string-switcher/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = true;
          };
          "keepassxc-browser@keepassxc.org" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/keepassxc-browser/latest.xpi";
            installation_mode = "normal_installed";
            private_browsing = true;
          };
          "gdpr@cavi.au.dk" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/consent-o-matic/latest.xpi";
            installation_mode = "normal_installed";
            private_browsing = true;
          };
          "jid1-MnnxcxisBPnSXQ@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
            installation_mode = "normal_installed";
            private_browsing = true;
          };
          # vimium
          "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
            installation_mode = "normal_installed";
            private_browsing = true;
          };
        };
      };
    };
  };
}
