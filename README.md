# Installation

## VM with disko
```sh
just (run|build)-vm <hostname> [args to qemu]
```
This will build the nixosConfiguration with stub secrets.

## VM with disko + secrets
```sh
SOPS_AGE_KEY=<master-key> just (build|run)-vm-with-secrets <hostname> [args to qemu]
```
This will:
- Pass the master key to the VM with qemu_fw_cfg.
- The custom activationScript will extract the key before sops is run.
- Sops uses the extracted key as age key to extract secrets.

## Remote (`nixos-anywhere`) with disko + secrets
*Requirements:*
- The Host's private SSH key should be in `./secrets/hosts/<hostname>.yaml`.
  - `ssh/key`
- The User's private SSH key should be in `./secrets/users/<username>.yaml`.
  - `ssh/key`
- Disko config for host
- Target running NixOS installer
- Set password for nixos user

```sh
SOPS_AGE_KEY=<master-key> just install-remote <hostname> <username> (metal|vm) [nixos-anywhere args]
```
Example:
```sh
SOPS_AGE_KEY=<master-key> just install-remote themata dr3y vm --target-host nixos@192.168.67.67
```
This will:
- Extract the host and user's ssh keys into a tmp dir.
- Copy the ssh keys over to the target with nixos-anywhere --extra-files.
- Use nixos-anywhere to format disks (disko) and install the configuration.
- The custom activationScript will convert the host and user' ssh keys to age 
  keys for sops to extract secrets.
