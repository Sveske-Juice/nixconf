{
  pkgs,
  config,
  ...
}: {
  packages = with pkgs; [
    opentofu
    jq

    sops
    yq
    nixos-anywhere
  ];

  env = {
    CLOUDFLARE_API_TOKEN = config.secretspec.secrets.CLOUDFLARE_API_TOKEN;
    TF_STATE_DIR = "${config.env.DEVENV_ROOT}/.state/cloudflare";
  };

  enterShell =
    # bash
    ''
      export SOPS_MASTER_KEY_PATH="''${XDG_RUNTIME_DIR:-/tmp}/sops-master-key"
    '';

  scripts = {
    cf-prep.exec =
      # bash
      ''
        set -euo pipefail
        mkdir -p "$TF_STATE_DIR"
        CONFIG=$(nix build --print-out-paths --no-link .#cloudflare-tf-config)
        install -m 0644 "$CONFIG" "$TF_STATE_DIR/config.tf.json"
        cd "$TF_STATE_DIR"
        if [ ! -d .terraform ]; then
          tofu init
        else
          tofu init -upgrade >/dev/null
        fi
      '';

    cf-plan.exec =
      # bash
      ''
        set -euo pipefail
        cf-prep
        cd "$TF_STATE_DIR"
        exec tofu plan "$@"
      '';

    cf-apply.exec =
      # bash
      ''
        set -euo pipefail
        cf-prep
        cd "$TF_STATE_DIR"
        exec tofu apply "$@"
      '';

    cf-destroy.exec =
      # bash
      ''
        set -euo pipefail
        cf-prep
        cd "$TF_STATE_DIR"
        exec tofu destroy "$@"
      '';

    cf-config.exec =
      # bash
      ''
        nix build --print-out-paths --no-link .#cloudflare-tf-config | xargs jq .
      '';

    _load-sops-master-key.exec =
      # bash
      ''
        set -euo pipefail
        if [ -z "''${SOPS_AGE_KEY:-}" ]; then
          echo "Sops master key (Ctrl+D):" >&2
          MASTER_KEY=$(cat)
        else
          MASTER_KEY="$SOPS_AGE_KEY"
        fi
        umask 077
        printf '%s\n' "$MASTER_KEY" > "$SOPS_MASTER_KEY_PATH"
        chmod 600 "$SOPS_MASTER_KEY_PATH"
      '';

    build-vm.exec =
      # bash
      ''
        set -euo pipefail
        if [ $# -lt 1 ]; then
          echo "usage: build-vm HOST" >&2
          exit 2
        fi
        HOST="$1"; shift
        nix build -L ".#nixosConfigurations.$HOST-vm.config.system.build.vmWithDisko"
      '';

    run-vm.exec =
      # bash
      ''
        set -euo pipefail
        if [ $# -lt 1 ]; then
          echo "usage: run-vm HOST [qemu args...]" >&2
          exit 2
        fi
        HOST="$1"; shift
        build-vm "$HOST"
        ./result/bin/disko-vm "$@"
      '';

    build-vm-with-secrets.exec =
      # bash
      ''
        set -euo pipefail
        if [ $# -lt 1 ]; then
          echo "usage: build-vm-with-secrets <host>" >&2
          exit 2
        fi
        HOST="$1"; shift
        trap 'rm -f "$SOPS_MASTER_KEY_PATH"' EXIT
        _load-sops-master-key
        nix build -L ".#nixosConfigurations.$HOST-vm-secrets.config.system.build.vmWithDisko"
      '';

    run-vm-with-secrets.exec =
      # bash
      ''
        set -euo pipefail
        if [ $# -lt 1 ]; then
          echo "usage: run-vm-with-secrets <host> [qemu args...]" >&2
          exit 2
        fi
        HOST="$1"; shift
        trap 'rm -f "$SOPS_MASTER_KEY_PATH"' EXIT
        _load-sops-master-key
        nix build -L ".#nixosConfigurations.$HOST-vm-secrets.config.system.build.vmWithDisko"
        ./result/bin/disko-vm "$@"
      '';

    install-remote.exec =
      # bash
      ''
        set -euo pipefail
        if [ $# -lt 3 ]; then
          echo "usage: install-remote <host> <user> (metal|vm) [nixos-anywhere args...]" >&2
          exit 2
        fi
        HOST="$1"; USER_ARG="$2"; METAL="$3"
        shift 3

        case "$METAL" in
          metal) echo "Installing bare metal"; TARGET_HOST="$HOST" ;;
          vm) echo "Installing host as vm: $HOST-vm-secrets"; TARGET_HOST="$HOST-vm-secrets" ;;
          *) echo "error: third argument must be 'metal' or 'vm'" >&2; exit 2 ;;
        esac

        umask 077
        TEMP=$(mktemp -d)
        trap 'rm -rf "$TEMP"; rm -f "$SOPS_MASTER_KEY_PATH"' EXIT

        _load-sops-master-key
        export SOPS_AGE_KEY_FILE="$SOPS_MASTER_KEY_PATH"

        echo "extracting '$HOST' key..."
        sops -d "secrets/hosts/$HOST.yaml" | yq -r ".ssh.key" > "$TEMP/host-ssh-key"

        echo "extracting '$USER_ARG' key..."
        sops -d "secrets/users/$USER_ARG.yaml" | yq -r ".ssh.key" > "$TEMP/user-ssh-key"

        nixos-anywhere --extra-files "$TEMP" --flake ".#$TARGET_HOST" "$@"
      '';
  };
}
