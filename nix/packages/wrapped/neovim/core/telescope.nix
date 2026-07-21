{
  flake.nvfModules.core = {pkgs, ...}: {
    vim.telescope = {
      enable = true;

      # https://github.com/NotAShelf/nvf/issues/746
      mappings = {
        findFiles = null;
        liveGrep = null;
        buffers = null;
        helpTags = null;
        open = null;
        resume = null;

        gitCommits = null;
        gitBufferCommits = null;
        gitBranches = null;
        gitStatus = null;
        gitStash = null;
        gitFiles = null;

        lspDocumentSymbols = null;
        lspWorkspaceSymbols = null;
        lspReferences = null;
        lspImplementations = null;
        lspDefinitions = null;
        lspTypeDefinitions = null;
        diagnostics = null;

        treesitter = null;
        findProjects = null;
      };

      setupOpts = {
        defaults = {
          path_display = ["smart"];
          pickers.find_command = ["${pkgs.fzf}/bin/fzf"];
        };
      };
    };

    vim.keymaps = [
      {
        key = "ep";
        mode = "n";
        silent = true;
        action = "<cmd>Telescope find_files<CR>";
        desc = "Find files";
      }
      {
        key = "ef";
        mode = "n";
        silent = true;
        action = "<cmd>Telescope live_grep<CR>";
        desc = "Live Grep";
      }
      {
        key = "egc";
        mode = "n";
        silent = true;
        action = "<cmd>Telescope git_commits<CR>";
        desc = "Git Commits";
      }
      {
        key = "egb";
        mode = "n";
        silent = true;
        action = "<cmd>Telescope git_branches<CR>";
        desc = "Git Branches";
      }
      {
        key = "egs";
        mode = "n";
        silent = true;
        action = "<cmd>Telescope git_status<CR>";
        desc = "Git Status";
      }
      {
        key = "es";
        mode = "n";
        silent = true;
        action = "<cmd>Telescope lsp_document_symbols<CR>";
        desc = "LSP Document Symbols";
      }
      {
        key = "eS";
        mode = "n";
        silent = true;
        action = "<cmd>Telescope lsp_workspace_symbols<CR>";
        desc = "LSP Workspace Symbols";
      }
      {
        key = "er";
        mode = "n";
        silent = true;
        action = "<cmd>Telescope lsp_references<CR>";
        desc = "LSP References";
      }
      {
        key = "ed";
        mode = "n";
        silent = true;
        action = "<cmd>Telescope diagnostics<CR>";
        desc = "Diagnostics";
      }
      {
        key = "es";
        mode = "n";
        silent = true;
        action = "<cmd>Telescope treesitter<CR>";
        desc = "Treesitter";
      }
      {
        key = "et";
        mode = "n";
        silent = true;
        action = "<cmd>TodoTelescope<CR>";
        desc = "Todos";
      }
    ];
  };
}
