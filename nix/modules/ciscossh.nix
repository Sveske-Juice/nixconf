{
  flake.nixosModules.cisco-ssh = {
    # cisco legacy stuff for ssh
    programs.ssh = {
      extraConfig = ''
        KexAlgorithms +diffie-hellman-group-exchange-sha1,diffie-hellman-group14-sha1
        HostKeyAlgorithms +ssh-rsa
        PubkeyAcceptedAlgorithms +ssh-rsa
      '';
    };
  };
}
