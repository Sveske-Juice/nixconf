{self, ...}: {
  flake.nixosModules.ct-torrentbox = let
    name = "torrentbox";
    dns = "10.64.0.1";
  in {config, ...}: {
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

    containers."${name}" = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "br-lan";
      localAddress = "192.168.1.75/24";
      extraFlags = ["--resolv-conf=off"];

      allowedDevices = [{ node = "/dev/net/tun"; modifier = "rw"; }];

      # Import rendered wg config to container
      bindMounts."/etc/wireguard/wg0.conf" = {
        hostPath = config.sops.templates."wg0.conf".path;
        isReadOnly = true;
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

        preferences.host.name = "${name}";
        system.stateVersion = "26.05";
      };
    };
  };
}
