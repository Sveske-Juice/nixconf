{
  flake.nixosModules.host-waltherbox = {
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
