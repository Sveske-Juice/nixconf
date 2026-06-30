{
  flake.nixosModules.host-larry = {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        KbdInteractiveAuthentication = true;
        AllowUsers = null;
        PermitRootLogin = "no";
      };

      allowSFTP = true;
    };
  };
}
