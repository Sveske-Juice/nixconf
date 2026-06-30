{
  flake.nixosModules.ocr = {
    lib,
    config,
    pkgs,
    ...
  }: {
    hjem.users."${config.preferences.user.name}".files.".local/share/applications/ocr.desktop".text = ''
      [Desktop Entry]
      Name=OCR tesseract
      Type=Application
      Exec=${lib.getExe (pkgs.writeScriptBin "ocr" ''
        ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - \
          | ${pkgs.tesseract}/bin/tesseract - - \
          | ${pkgs.wl-clipboard}/bin/wl-copy
      '')}
    '';
  };
}
