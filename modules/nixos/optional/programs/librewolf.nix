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
          "webgl.disabled" = false; # enable WebGL
          "privacy.resistFingerprinting" = false;
          "privacy.clearOnShutdown.history" = false; # Keep history
          "privacy.clearOnShutdown.cookies" = false; # Keep cookies (stay logged in)
          "network.cookie.lifetimePolicy" = 0;

          "cookiebanners.service.mode.privateBrowsing" = 2; # Block cookie banners in private browsing
          "cookiebanners.service.mode" = 2; # Block cookie banners
          "privacy.donottrackheader.enabled" = true;
          "privacy.fingerprintingProtection" = true;
          "privacy.trackingprotection.emailtracking.enabled" = true;
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.fingerprinting.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
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
        };
      };
    };
  };
}
