build-vm-with-secrets *args:
  #!/usr/bin/env bash
  KEY_PATH="/tmp/sops-master-key"

  # 1. Get the key
  if [ -z "$SOPS_AGE_KEY" ]; then
      echo "Sops master key (Ctrl+D):"
      TEMP_VAL=$(cat)
  else
      TEMP_VAL="$SOPS_AGE_KEY"
  fi

  echo "$TEMP_VAL" > "$KEY_PATH"
  chmod 600 "$KEY_PATH"

  nixos-rebuild build-vm --flake . {{args}}

run-vm-with-secrets *args:
  just build-vm-with-secrets
  ./result/bin/run-*-vm {{args}}
