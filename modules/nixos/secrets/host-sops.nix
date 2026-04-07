# Unlock the host secrets from it's host SSH key
{inputs, ...}: {
  flake.nixosModules.secrets = {
    lib,
    pkgs,
    config,
    ...
    }: let
      masterKeyPath = "/tmp/sops-master-key";
      sopsKeyPath = "/var/lib/sops-nix/key.txt";
    in {
      imports = [
        inputs.sops-nix.nixosModules.sops
      ];
      config = lib.mkIf config.preferences.secrets {
        environment.systemPackages = with pkgs; [
          sops
          age
          ssh-to-age
        ];

        sops = {
          defaultSopsFile = lib.path.append ../../../secrets/hosts "${config.preferences.host.name}.yaml";
          age.keyFile = sopsKeyPath;
        };
        virtualisation.vmVariant = {
          # NOTE: so that it gets loaded before ageKeyInjector script runs
          boot.initrd.kernelModules = [ "qemu_fw_cfg" ];

          # Bootstrap master key into vm
          virtualisation.qemu.options = [
            "-fw_cfg name=opt/masterKey,file=${masterKeyPath}"
          ];
        };

        # Generate age keys from potential bootstrapped ssh keys
        system.activationScripts.ageKeyInjector = {
          text = 
            # bash
            ''
          mkdir -p $(dirname "${sopsKeyPath}")
          : > "${sopsKeyPath}"
          chmod 600 "${sopsKeyPath}"

          priv_ssh_to_age() {
            local input_path=$1
            if [ -f "$input_path" ]; then
              ${lib.getExe pkgs.ssh-to-age} -private-key -i "$input_path"
            else
              echo "FATAL: Input SSH key: $input_path doesn't exist"
            fi
          }

          # QEMU: Copy bootstrapped master key to vm
          if [ -d /sys/firmware/qemu_fw_cfg/by_name ]; then
            cat "/sys/firmware/qemu_fw_cfg/by_name/opt/masterKey/raw" > "${sopsKeyPath}"

            echo "bootstrapped sops key to vm"
            cat "${sopsKeyPath}"
          fi

          # Existing keys (nixos-rebuild/nixos-anywhere --extra-files)
          # TODO: 
          '';
          deps = [ "specialfs" ];
        };
      };
    };
}
