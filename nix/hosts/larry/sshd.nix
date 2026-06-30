{
  flake.nixosModules.host-larry = {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        AllowUsers = null;
        PermitRootLogin = "no";
      };

      allowSFTP = true;
    };
  };
}
