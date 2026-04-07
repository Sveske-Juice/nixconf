_: {
  flake.nixosModules.driver-amdgpu = {pkgs, ...}: {
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
      };

      amdgpu = {
        initrd.enable = true;
        opencl.enable = true;
      };
    };

    environment.systemPackages = [
      pkgs.clinfo # opencl cli helper
    ];
  };
}
