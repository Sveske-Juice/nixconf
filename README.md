# Features
* Dendritic pattern - each nix file is a top-level config
* Re-usable nixos modules - each common module gets defined as a nixosModule
  in the flake (see `nix flake show`)
* Wrapped packages that can be run with `nix run` for neovim, tmux, niri etc.
* Secret management with [sops-nix](https://github.com/Mic92/sops-nix) as 
  a git submodule
* Custom bootstrap scripts for building, running and installing NixOS
  configurations with secrets
* User home management with [hjem](https://github.com/feel-co/hjem) and 
  [hjem-rum](https://github.com/snugnug/hjem-rum)

## Packages
### Neovim
Uses [NVF](https://github.com/NotAShelf/nvf) to wrap neovim. Minimal (default)
has all my base configurations, while the max version `.#neovim-max` comes 
with a lot of bundled LSP servers that I use.

```sh
nix run github:Sveske-Juice/nixconf#neovim
nix run github:Sveske-Juice/nixconf#neovim-max
```
### Tmux
My tmux config wrapped with [nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules).

```sh
nix run github:Sveske-Juice/nixconf#tmux
```

### Niri
Niri with noctalia shell v5 wrapped with [nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules).

```sh
nix run github:Sveske-Juice/nixconf#niri
```

# Installation
Enter dev shell:

```sh
devenv shell
```

## VM with disko (no secrets)
```sh
(run|build)-vm <hostname> [qemu args...]
```
This will build the nixosConfiguration with stub secrets.

## VM with disko and secrets
```sh
(build|run)-vm-with-secrets <hostname> [qemu args...]
```

## Remote (`nixos-anywhere`) with disko and secrets
*Requirements:*
- The Host's private SSH key should be in `./secrets/hosts/<hostname>.yaml`.
  - `ssh/key`
- The User's private SSH key should be in `./secrets/users/<username>.yaml`.
  - `ssh/key`
- Disko config for host
- Target running NixOS installer
- Set password for nixos user

```sh
install-remote <hostname> <username> (metal|vm) [nixos-anywhere args...]
```
Example:
```sh
install-remote themata dr3y vm --target-host nixos@192.168.67.67
```
This will:
- Extract the host and user's ssh keys into a tmp dir.
- Copy the ssh keys over to the target with nixos-anywhere --extra-files.
- Use nixos-anywhere to format disks (disko) and install the configuration.
- The custom activationScript will convert the host and user' ssh keys to age 
  keys for sops to extract secrets.
