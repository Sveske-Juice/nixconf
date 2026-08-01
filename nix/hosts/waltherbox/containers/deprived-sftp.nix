{ self, ... }: {
  flake.nixosModules.ct-deprived-sftp = let
    name = "sftp-deprived";
    sftpUid = 8130;
    sftpGid = 8130;
    baseDir = "/fast/apps/sftp/deprived";
    sftpUser = "deprived";
    sshPort = 2244;
  in hostArgs: {
    systemd.tmpfiles.rules = [
      "d ${baseDir} 0755 root root -"
      "d ${baseDir}/deprived 0750 ${toString sftpUid} ${toString sftpGid} -"
      "d ${baseDir}/deprived/assets 0755 ${toString sftpUid} ${toString sftpGid} -"
    ];

    keyGroups.deprived-sftp = with hostArgs.config.keys.ssh; [
      pixel9a
      dr3y
      walther
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJw1ckvXz78ITeqANrWSkJl6PJo2AMA4myNrRMBAB7xW zhen"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAhiPhFbCi64NduuV794omgS8mctBLXtqxbaEJyUo6lg botalex@DESKTOP-ENDVV0V"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKhcUZbIMX0W27l/FMF5WijpdsJAK329/P008OEAfcyz botmain@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKFmg+pf1BMC0K1wCxxcc/3vovVbfazEQTyZwHlVuVjS root@nixos"
    ];

    containers."${name}" = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "br-lan";
      localAddress = "192.168.1.82/24";
      extraFlags = [ "--resolv-conf=off" ];

      bindMounts."${baseDir}" = {
        hostPath = "${baseDir}";
        isReadOnly = false;
      };

      config = { pkgs, ... }: {
        imports = [ self.nixosModules.base ];

        networking = {
          useHostResolvConf = false;
          nameservers = [ "192.168.1.71" ];
          defaultGateway = "192.168.1.1";
        };

        users.users.${sftpUser} = {
          uid = sftpUid;
          isNormalUser = true;
          group = sftpUser;
          home = "${baseDir}/deprived";
          shell = "${pkgs.shadow}/bin/nologin";
          openssh.authorizedKeys.keys = hostArgs.config.keyGroups.deprived-sftp;
        };
        users.groups.${sftpUser}.gid = sftpGid;

        services.openssh = {
          enable = true;
          ports = [sshPort];
          settings = {
            PasswordAuthentication = false;
            PubkeyAuthentication = true;
          };
          extraConfig = ''
            Match User ${sftpUser}
              ChrootDirectory ${baseDir}
              ForceCommand internal-sftp
              AllowTcpForwarding no
              X11Forwarding no
              PermitTunnel no
          '';
        };

        preferences.host.name = name;
        system.stateVersion = "26.05";
      };
    };
  };
}
