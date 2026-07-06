{
  perSystem = {pkgs, ...}: let
    godotdev = pkgs.vimUtils.buildVimPlugin rec {
      pname = "godotdev.nvim";
      version = "0.8.2";
      src = pkgs.fetchFromGitHub {
        owner = "Mathijs-Bakker";
        repo = "godotdev.nvim";
        tag = version;
        hash = "sha256-XD6XddvCYjc6Sco7b6QBgfZ1xd9+aYpdsUuPH5HbZE8=";
      };
    };
  in {
    nvfModules = [
      {
        vim.extraPlugins.godotdev = {
          package = godotdev;
          setup =
            # lua
            ''
            require("godotdev").setup({})
            '';
        };
      }
    ];
  };
}
