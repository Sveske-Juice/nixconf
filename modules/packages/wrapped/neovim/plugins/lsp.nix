_: {
  perSystem.nvfModules = [
    {
      vim.visuals.fidget-nvim = {
        enable = true;
      };
      vim.visuals.nvim-web-devicons = {
        enable = true;
      };
      vim = {
        languages = {
          enableTreesitter = true;

          # Languages
          nix = {
            enable = true;
            extraDiagnostics = {
              enable = true;
              types = ["deadnix" "statix"];
            };
            lsp = {
              enable = true;
              servers = ["nixd"];
            };
          };
          typst = {
            enable = true;
            lsp.enable = true;
            treesitter.enable = true;
            extensions.typst-preview-nvim = {
              enable = true;
              setupOpts = {
                open_cmd = "xdg-open %s";
              };
            };
          };
          bash.enable = true;
          svelte.enable = true;

          python.enable = true;
          typescript.enable = true;

          rust.enable = true;
          clang = {
            lsp.enable = true;
          };
          csharp = {
            enable = true;
            lsp.servers = ["omnisharp"]; # csharp_ls doesn't seem to work (dll problems)
          };

          css.enable = true;
          sql.enable = true;
          markdown = {
            enable = true;
          };
        };

        lsp = {
          servers.clangd = {
            enable = true;
            # Use clang from environment
            # this fixes alot of things from using the wrapped clangd,
            # so it will properly find stdlib and deps from compile_commands.json
            cmd = ["clangd"];
          };
          servers.nixd = {
            enable = true;
          };

          enable = true;
          lightbulb.enable = true;

          # Remove all default bindings
          mappings = {
            goToDeclaration = null;
            goToDefinition = null;
            goToType = null;
            listImplementations = null;
            listReferences = null;
            nextDiagnostic = null;
            previousDiagnostic = null;
            openDiagnosticFloat = null;
            documentHighlight = null;
            listDocumentSymbols = null;
            addWorkspaceFolder = null;
            removeWorkspaceFolder = null;
            listWorkspaceFolders = null;
            listWorkspaceSymbols = null;
            hover = null;
            signatureHelp = null;
            renameSymbol = null;
            codeAction = null;
            format = null;
            toggleFormatOnSave = null;
          };
        };

        # Define our own keymaps
        keymaps = [
          {
            mode = "n";
            key = "<leader>tp";
            action = "<cmd>TypstPreview<cr>";
            desc = "Preview Typst Document";
          }
          {
            key = "ga";
            mode = "n";
            silent = true;
            action = "vim.lsp.buf.code_action";
            lua = true;
            desc = "Code actions";
          }
          {
            key = "K";
            mode = "n";
            silent = true;
            action = "vim.lsp.buf.hover";
            lua = true;
            desc = "Hover";
          }
          # TODO: find keybind
          # {
          #   key = "<C-h>";
          #   mode = "i";
          #   silent = true;
          #   action = "vim.lsp.buf.signature_help";
          #   lua = true;
          #   desc = "Signature help";
          # }
          {
            key = "gd";
            mode = "n";
            silent = true;
            action = "vim.lsp.buf.definition";
            lua = true;
            desc = "Go to definition";
          }
          {
            key = "gh";
            mode = "n";
            silent = true;
            action = ":LspClangdSwitchSourceHeader<CR>";
            desc = "Clangd: Switch Source/Header file";
          }
          {
            key = "gD";
            mode = "n";
            silent = true;
            action = "vim.lsp.buf.declaration";
            lua = true;
            desc = "Go to declaration";
          }
          {
            key = "gR";
            mode = "n";
            silent = true;
            action = "vim.lsp.buf.rename";
            lua = true;
            desc = "Rename symbol";
          }
        ];
      };
    }
  ];
}
