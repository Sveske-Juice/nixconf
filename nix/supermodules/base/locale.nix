_: {
  flake.nixosModules.base = _: {
    time.timeZone = "Europe/Copenhagen";
    i18n.defaultLocale = "en_DK.UTF-8";

    console.keyMap = "dk-latin1";
  };
}
