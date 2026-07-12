{self, ...}: {
  flake.nixosModules.host-larry = let
    name = "file";
    smbPort = 445;
    netbiosPort = 139;
  in {
    containers."${name}" = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "br0";
      localAddress = "10.100.0.18/24";
      extraFlags = ["--resolv-conf=off"];
      config = {
        imports = [
          self.nixosModules.base
        ];
        networking = {
          useHostResolvConf = false;
          nameservers = ["10.100.0.11"];
          defaultGateway = "10.100.0.1";
        };

        services.samba = {
          enable = true;
          openFirewall = true;

          settings = {
            global = {
              "workgroup" = "WORKGROUP";
              "server string" = "smb.evil.deprived.dev";
              "netbios name" = "SMB";
              "security" = "user";
              "map to guest" = "never";
              "server min protocol" = "SMB2";
              "server smb encrypt" = "desired";
              "hosts allow" = "10.0.0.0/8 127.0.0.1";
              "hosts deny" = "0.0.0.0/0";
            };

            shares = {
              path = "/srv/shares";
              browseable = "yes";
              "read only" = "no";
              "guest ok" = "no";
              "valid users" = "@smbusers";
              "create mask" = "0660";
              "directory mask" = "0770";
            };
          };
        };

        # Optional: WSDD for network browsing/discovery on Windows
        services.samba-wsdd = {
          enable = true;
          openFirewall = true;
        };

        users.groups.smbusers = {};

        systemd.tmpfiles.rules = [
          "d /srv/shares 0770 root smbusers -"
        ];

        networking.firewall.allowedTCPPorts = [smbPort netbiosPort];
        networking.firewall.allowedUDPPorts = [137 138];
        preferences.host.name = "${name}";
        system.stateVersion = "26.05";
      };
    };

    systemd.network.networks."58-vb-${name}" = {
      matchConfig.Name = "vb-${name}";
      networkConfig.Bridge = "br0";
      bridgeVLANs = [
        {
          VLAN = 100;
          PVID = 100;
          EgressUntagged = 100;
        }
      ];
      linkConfig.RequiredForOnline = "no";
    };
  };
}
