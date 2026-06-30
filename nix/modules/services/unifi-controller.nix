{
  flake.nixosModules.unifi-controller = {
    services.unifi = {
      enable = true;
      openFirewall = true;
    };

    networking.firewall.allowedTCPPorts = [
      8443
    ];

    allowedUnfreePackages = [
      "unifi-controller"
      "mongodb"
    ];
  };
}
