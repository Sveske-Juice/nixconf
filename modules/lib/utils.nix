# Helper/Utility functions
{inputs, ...}: let
  inherit (inputs.nixpkgs) lib;
in {
  flake.lib = {
    mkHost = host: modules: {
      ${host} = lib.nixosSystem {
        specialArgs = {
          isVM = false;
        };
        inherit modules;
      };

      "${host}-vm" = lib.nixosSystem {
        specialArgs = {
          isVM = true;
        };
        inherit modules;
      };

      "${host}-vm-secrets" = lib.nixosSystem {
        specialArgs = {
          isVM = true;
        };
        modules =
          modules
          ++ [
            {
              preferences.secrets = lib.mkForce true;
            }
          ];
      };
    };
  };
}
