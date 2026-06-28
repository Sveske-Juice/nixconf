_: {
  flake.nixosModules.driver-amdgpu = {pkgs, ...}: {
    nixpkgs.config.rocmSupport = true;
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
      pkgs.rocmPackages.clr 
    ];
  };
}
