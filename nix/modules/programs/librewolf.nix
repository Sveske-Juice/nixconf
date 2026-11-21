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
        # use own password manager
        PasswordManagerEnabled = false;
        RequestedLocales = [
          "da"
          "en-US"
        ];
        ClearOnShutdown = {
          # Stay signed in
          CookiesAndStorage = false;
          # Dont clear history
          BrowsingHistoryAndDownloads = false;
          Cache = true;
        };
        SearchEngines = {
          Default = "DuckDuckGo";
        };
        Preferences = {
          "webgl.disabled" = false;
          "privacy.fingerprintingProtection" = true;

          "sidebar.revamp" = {
            Value = true;
            Status = "default";
          };
          "sidebar.verticalTabs" = {
            Value = true;
            Status = "default";
          };
          "sidebar.visibility" = {
            Value = "hide-sidebar";
            Status = "default";
          };
        };
        # Find the GUID of an extension to install new extensions:
        # curl -sfL https://addons.mozilla.org/api/v5/addons/addon/<slug>/ | jq -r .guid
        ExtensionSettings = {
          "*" = {
            installation_mode = "blocked";
            blocked_install_message = "Exensions managed by Nix";
          };
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
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
          # Vimium
          "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
            installation_mode = "normal_installed";
            private_browsing = true;
          };
          # Sidebery
          "{3c078156-979c-498b-8990-85f7987dd929}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/sidebery/latest.xpi";
            installation_mode = "normal_installed";
            private_browsing = true;
          };
        };
      };
    };
  };
}
