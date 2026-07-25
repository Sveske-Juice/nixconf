{
  cloudflare.zones."waltherbox.org".zoneId = "f2cdfb161e8aeb17df45b402c91a43fa";
  cloudflare.zones."waltherbox.org".records = {
    mainIpv4 = {
      name = "@";
      type = "A";
      content = "87.54.92.68";
      comment = "Primary";
    };
  };
}
