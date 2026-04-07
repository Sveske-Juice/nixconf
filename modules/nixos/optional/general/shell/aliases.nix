{
  flake.nixosModules.general = _: {
    programs.fish.shellAbbrs = {
      "nrs" = "sudo nixos-rebuild switch --flake .#";
      "nrb" = "sudo nixos-rebuild build --flake .#";
      "nrv" = "sudo nixos-rebuild build-vm --flake .#";

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
