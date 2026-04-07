_: {
  perSystem = {pkgs, ...}: {
    nvfModules = [
      {
        # Unifys vim.ui* to use telescope etc.
        vim.lazy.plugins = {
          "dressing.nvim" = {
            package = pkgs.vimPlugins.dressing-nvim;
          };
        };
      }
    ];
  };
}
