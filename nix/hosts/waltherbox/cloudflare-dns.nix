let
  primaryIpv4 = "87.54.92.68";
in {
  cloudflare.zones."waltherbox.org".zoneId = "f2cdfb161e8aeb17df45b402c91a43fa";
  cloudflare.zones."waltherbox.org".records = {
    mainIpv4 = {
      name = "@";
      type = "A";
      content = primaryIpv4;
      comment = "Primary";
    };
    radicaleIpv4 = {
      name = "radicale";
      type = "A";
      content = primaryIpv4;
      comment = "Radicale";
    };
    jellyfinIpv4 = {
      name = "jellyfin";
      type = "A";
      content = primaryIpv4;
      comment = "Jellyfin";
    };
  };
}
