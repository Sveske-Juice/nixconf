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
    hostSSHKeyPath = "/host-ssh-key";
    userSSHKeyPath = "/user-ssh-key";
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
      virtualisation.vmVariantWithDisko = {
        # NOTE: so that it gets loaded before ageKeyInjector script runs
        boot.initrd.kernelModules = ["qemu_fw_cfg"];

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
            if [ -d /sys/firmware/qemu_fw_cfg/by_name/opt/masterKey ]; then
              cat "/sys/firmware/qemu_fw_cfg/by_name/opt/masterKey/raw" > "${sopsKeyPath}"
              echo "bootstrapped sops key to vm"
            elif [ -f "${hostSSHKeyPath}" ] && [ -f "${userSSHKeyPath}" ]; then
              # First time install
              echo "first time install"
              priv_ssh_to_age "${hostSSHKeyPath}" > "${sopsKeyPath}"
              priv_ssh_to_age "${userSSHKeyPath}" >> "${sopsKeyPath}"
              echo "Converted ssh keys to age keys"
            fi
          '';
        deps = ["specialfs"];
      };

      system.activationScripts.installSshKeys = {
        text =
          # bash
          ''
            if [ -f "${hostSSHKeyPath}" ] && [ -f "${userSSHKeyPath}" ]; then
              mv "${hostSSHKeyPath}" /etc/ssh/ssh_host_ed25519_key
              mv "${userSSHKeyPath}" "${config.preferences.user.home}/.ssh/id_ed25519"
            fi
          '';
        deps = ["ageKeyInjector" "users" "groups"];
      };
    };
  };
}
