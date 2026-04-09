masterKeyPath := '/tmp/sops-master-key'

build-vm-with-secrets host *args:
  #!/usr/bin/env bash
  # get master key
  if [ -z "$SOPS_AGE_KEY" ]; then
      echo "Sops master key (Ctrl+D):"
      TEMP_VAL=$(cat)
  else
      TEMP_VAL="$SOPS_AGE_KEY"
  fi

  echo "$TEMP_VAL" > "{{masterKeyPath}}"
  chmod 600 "{{masterKeyPath}}"

  nix build -L '.#nixosConfigurations.{{host}}-vm-secrets.config.system.build.vmWithDisko'

run-vm-with-secrets host *args:
  just build-vm-with-secrets {{host}}
  ./result/bin/disko-vm {{args}}
  rm -rf "{{masterKeyPath}}"

install-remote host user metal *args:
  #! /usr/bin/env nix-shell
  #! nix-shell -i bash -p sops yq nixos-anywhere
  umask 077
  temp=$(mktemp -d)
  cleanup() {
    rm -rf "$temp"
  }
  trap cleanup EXIT

  HOST="{{host}}"
  if [ "{{metal}}" == "metal" ]; then
    echo "Installing bare metal"
  elif [ "{{metal}}" == "vm" ]; then
    HOST="{{host}}-vm-secrets"
    echo "Installing host as vm: $HOST"
  else
    echo "error: Must be either metal or vm"
    exit 1
  fi

  # get master key
  if [ -z "$SOPS_AGE_KEY" ]; then
      echo "Sops master key (Ctrl+D):"
      TEMP_VAL=$(cat)
  else
      TEMP_VAL="$SOPS_AGE_KEY"
  fi

  echo "extracting '{{host}}' key..."
  sops -d "secrets/hosts/{{host}}.yaml" | yq -r ".ssh.key" > "$temp/host-ssh-key"

  echo "extracting '{{user}}' key..."
  sops -d "secrets/users/{{user}}.yaml" | yq -r ".ssh.key" > "$temp/user-ssh-key"

  # nixos-anywhere
  nixos-anywhere --extra-files "$temp" --flake ".#$HOST" {{args}} 
