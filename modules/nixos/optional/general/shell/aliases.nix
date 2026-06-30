{
  flake.nixosModules.general = _: {
    programs.fish.shellAbbrs = {
      "nrs" = "nixos-rebuild switch --flake .# --sudo";
      "nrrs" = "nixos-rebuild switch --flake --sudo --ask-sudo-password --target-host host@ip .#host";
      "nrb" = "nixos-rebuild build --flake .# --sudo";
      "nrv" = "nixos-rebuild build-vm --flake .#";

      "gp" = "git push";
      "gu" = "git pull";
      "gc" = "git commit -m";
      "ga" = "git add";
      "gs" = "git status";
      "gd" = "git diff";

      "ta" = "tmux attach";
    };
  };
}
