{
  flake.nixosModules.virt-manager = {
    pkgs,
    config,
    ...
  }: {
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          swtpm.enable = true; # tmp emulation
          vhostUserPackages = [pkgs.virtiofsd];
        };
      };
      spiceUSBRedirection.enable = true;
    };

    programs.virt-manager.enable = true;
    users.users.${config.preferences.user.name}.extraGroups = ["libvirtd" "video" "render"];

    environment.systemPackages = with pkgs; [
      spice
      spice-gtk
      spice-protocol
      virt-viewer
    ];
  };
}
