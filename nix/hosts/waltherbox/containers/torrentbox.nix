{self, ...}: {
  flake.nixosModules.ct-torrentbox = let
    name = "torrentbox";
    # mullvad dns
    dns = "10.64.0.1";
    qbitPort = 9091;
    jackettPort = 9117;
    sonarrPort = 8989;
    radarrPort = 8787;

    qbitConfigDir = "/var/lib/qbittorrent";
    qbitDataDir = "/data";
    hostQbitConfigDir = "/fast/apps/qbittorrent/config";
    hostQbitDataDir = "/fast/apps/qbittorrent/data";
  in
    {config, pkgs, ...}: {
      sops.secrets = {
        "mullvad/private-key" = {};
        "mullvad/address" = {};
        "mullvad/endpoint" = {};
      };

      sops.templates."wg0.conf" = {
        content = ''
          [Interface]
          PrivateKey = ${config.sops.placeholder."mullvad/private-key"}
          Address = ${config.sops.placeholder."mullvad/address"}
          DNS = ${dns}

          # Add kill switch to WAN destinations rules
          PostUp  = iptables  -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
          PostUp  = ip6tables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT

          # Add split tunnel allow rules
          PostUp  = iptables  -I OUTPUT -d 10.0.0.0/8       -j ACCEPT
          PostUp  = iptables  -I OUTPUT -d 172.16.0.0/12    -j ACCEPT
          PostUp  = iptables  -I OUTPUT -d 192.168.0.0/16   -j ACCEPT
          PostUp  = ip6tables -I OUTPUT -d fc00::/7         -j ACCEPT
          PostUp  = ip6tables -I OUTPUT -d fe80::/10        -j ACCEPT

          # Teardown split tunnel
          PreDown = ip6tables -D OUTPUT -d fe80::/10        -j ACCEPT
          PreDown = ip6tables -D OUTPUT -d fc00::/7         -j ACCEPT
          PreDown = iptables  -D OUTPUT -d 192.168.0.0/16   -j ACCEPT
          PreDown = iptables  -D OUTPUT -d 172.16.0.0/12    -j ACCEPT
          PreDown = iptables  -D OUTPUT -d 10.0.0.0/8       -j ACCEPT

          # Teardown kill switch
          PreDown = iptables  -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
          PreDown = ip6tables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT

          [Peer]
          PublicKey = egl+0TkpFU39F5O6r6+hIBMPQLOa8/t5CymOZV6CC3Y=
          AllowedIPs = 0.0.0.0/0, ::/0
          Endpoint = ${config.sops.placeholder."mullvad/endpoint"}
          PersistentKeepalive = 25
        '';
        mode = "0400";
      };

      containers.proxy.config.services.caddy.virtualHosts = {
        "torrent.lan.waltherbox.org".extraConfig = ''
          import cf_tls
          import lan_only
          reverse_proxy http://192.168.1.75:${toString qbitPort}
        '';
        "jackett.lan.waltherbox.org".extraConfig = ''
          import cf_tls
          import lan_only
          reverse_proxy http://192.168.1.75:${toString jackettPort}
        '';
        "sonarr.lan.waltherbox.org".extraConfig = ''
          import cf_tls
          import lan_only
          reverse_proxy http://192.168.1.75:${toString sonarrPort}
        '';
        "radarr.lan.waltherbox.org".extraConfig = ''
          import cf_tls
          import lan_only
          reverse_proxy http://192.168.1.75:${toString radarrPort}
        '';
      };


      containers."${name}" = {
        autoStart = true;
        privateNetwork = true;
        hostBridge = "br-lan";
        localAddress = "192.168.1.75/24";
        extraFlags = ["--resolv-conf=off"];

        # Allow container to access TUN device
        allowedDevices = [
          {
            node = "/dev/net/tun";
            modifier = "rw";
          }
        ];

        # Import rendered wg config to container
        bindMounts = {
          "/etc/wireguard/wg0.conf" = {
            hostPath = config.sops.templates."wg0.conf".path;
            isReadOnly = true;
          };
          ${qbitConfigDir} = { hostPath = hostQbitConfigDir; isReadOnly = false; };
          ${qbitDataDir} = { hostPath = hostQbitDataDir; isReadOnly = false; };
        };

        config = {
          imports = [
            self.nixosModules.base
          ];
          networking = {
            useHostResolvConf = false;
            nameservers = [dns];
            defaultGateway = "192.168.1.1";

            wg-quick.interfaces.wg0 = {
              configFile = "/etc/wireguard/wg0.conf";
              autostart = true;
            };
          };

          # Create container local group with matching gid of host group
          users.groups.media.gid = config.users.groups.media.gid;

          services.jackett = {
            enable = true;
            port = jackettPort;
            openFirewall = true;
            group = "media";
          };

          services.sonarr = {
            enable = true;
            openFirewall = true;
            group = "media";

            settings = {
              server.port = sonarrPort;
              log.analyticsEnabled = false;
            };
          };

          services.radarr = {
            enable = true;
            openFirewall = true;
            group = "media";

            settings = {
              server.port = radarrPort;
              log.analyticsEnabled = false;
            };
          };

          services.qbittorrent = {
            enable = true;
            webuiPort = qbitPort;
            torrentingPort = 6881;
            openFirewall = true;

            profileDir = qbitConfigDir;
            group = "media";

            serverConfig = {
              LegalNotice.Accepted = true;
              BitTorrent.Session = {
                IPv6Enabled = true;
                DefaultSavePath = qbitDataDir;
                TempPathEnabled = false;

                DHTEnabled = true;
                DHT = true;
                PeXEnabled = true;
                AnnounceToAllTrackers = true;
                AnnounceToAllTiers = true;
                # Won't do anything because we connect through vpn
                UseUPnP = false;

                GlobalMaxConnections = 500;
                GlobalMaxUploads = 50;
                MaxConnectionsPerTorrent = 100;
                MaxUploadsPerTorrent = 10;
              };
              Preferences = {
                General.Locale = "en";

                WebUI = {
                  Address = "*";
                  Port = qbitPort;
                  Username = "qbitadmin";
                  Password_PBKDF2 = "CMTz2RxO4FOFV/5MJfuF6A==:SK0skoW92U/vEzLyX5ovY2uM3KSbv80H8OSN56PhbmUdBHn6/g6QSVQBAPQgonYDRGer2SY5vpXf8x0TYkAuiw==";

                  # AuthSubnetWhitelistEnabled = true;
                  # AuthSubnetWhitelist = "192.168.1.0/24";
                  AlternativeUIEnabled = true;
                  RootFolder = "${pkgs.vuetorrent}/share/vuetorrent";
                };
              };
            };
            extraArgs = [ "--confirm-legal-notice" ];
          };

          preferences.host.name = "${name}";
          system.stateVersion = "26.05";
        };
      };
    };
}
