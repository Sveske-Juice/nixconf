_: {
  perSystem = {
    pkgs,
    ...
  }: {
    nvfModules = [
      ({lib, ...}: {
        vim = {
          theme = {
            enable = false;
            name = "tokyonight";
            style = "storm";
            transparent = true;
          };
          startPlugins = [pkgs.vimPlugins.lackluster-nvim];
          luaConfigRC.theme =
            lib.nvim.dag.entryBefore ["pluginConfigs" "lazyConfigs"]
            #lua
            ''
              local lackluster = require("lackluster");
              lackluster.setup({
                tweak_background = {
                  normal = 'none',
                  telescope = 'none',
                  menu = lackluster.color.gray3,
                  popup = 'default',
                },
                tweak_highlight = {
                  ["@keyword"] = {
                    bold = true,
                  },
                },
              });
              vim.cmd("colorscheme lackluster");
            '';
          luaConfigRC.colorcolumn =
            lib.nvim.dag.entryAfter ["theme"]
            # lua
            ''
              local lackluster = require("lackluster")
              vim.api.nvim_set_hl(0, "ColorColumn", { bg = lackluster.color.gray3 })
            '';
          options = {
            termguicolors = true;
            relativenumber = true;
            nu = true;
            colorcolumn = "80";

            # default tabs
            # gets overwritten if .editorconfig exists
            tabstop = 2;
            softtabstop = 2;
            shiftwidth = 2;
            expandtab = true;

            scrolloff = 8;

            updatetime = 50;
            wrap = false;

            hlsearch = false;
            incsearch = true;
          };
        };
      })
    ];
  };
}
