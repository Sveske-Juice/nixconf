# Unlock the host secrets from it's host SSH key
{inputs, ...}: {
  flake.nixosModules.secrets = {lib, pkgs, config, ...}: {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    environment.systemPackages = with pkgs; [
      sops
      age
      ssh-to-age
    ];

    sops.defaultSopsFile = lib.path.append ./secrets/hosts "${config.preferences.host.name}";
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    sops.secrets.hello = {};
  };
}
