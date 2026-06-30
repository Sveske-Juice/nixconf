{
  flake.nixosModules.general = _: {
    programs.fish.shellAbbrs = {
      "nrs" = "nixos-rebuild switch --flake .# --sudo";
      "nrrs" = "nixos-rebuild switch --sudo --ask-sudo-password --flake .#host --target-host host@ip";
      "nrb" = "nixos-rebuild build --flake .# --sudo";
      "nrv" = "nixos-rebuild build-vm --flake .#";

      "gp" = "git push";
      "gu" = "git pull";
      "gc" = "git commit -m";
      "ga" = "git add";
      "gs" = "git status";
      "gd" = "git diff";

      "ta" = "tmux attach";
      "tns" = "tmux new -s";
    };
  };
}
