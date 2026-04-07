_: {
  perSystem = {pkgs, ...}: {
    nvfModules = [{
      vim.lazy.plugins = {
        "otter.nvim" = {
          package = pkgs.vimPlugins.otter-nvim;
          # TODO: this doesnt work
          after =
            # lua
            ''
          -- require("otter").activate(nil, true, true, nil);
          '';
        };
      };
    }];
  };
}
