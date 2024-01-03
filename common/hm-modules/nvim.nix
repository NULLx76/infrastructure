{ config, pkgs, lib, ... }:
let cfg = config.programs.v.nvim;
in with lib; {
  options.programs.v.nvim = { enable = mkEnableOption "nvim"; };
  config = mkIf cfg.enable {
    programs.nixvim = {
      enable = true;
      package = pkgs.neovim-unwrapped;
      vimAlias = true;
      luaLoader.enable = true;

      globals.mapleader = " ";

      options.number = true;

      clipboard = { providers.wl-copy.enable = true; };

      keymaps = [
        {
          mode = "n";
          key = "<leader>ff";
          action = "require('telescope.builtin').find_files";
          lua = true;
        }
        {
          mode = "n";
          key = "<leader>fg";
          action = "require('telescope.builtin').live_grep";
          lua = true;
        }
        {
          mode = "n";
          key = "<C-_>";
          action = "require('Comment.api').toggle.linewise.current";
          lua = true;
        }
        {
          mode = "x";
          key = "<C-_>";
          action = ''
            function()
              local esc = vim.api.nvim_replace_termcodes(
                '<ESC>', true, false, true
              )
              vim.api.nvim_feedkeys(esc, 'nx', false)
              require('Comment.api').toggle.linewise(vim.fn.visualmode())
            end
          '';
          lua = true;
        }
        {
          mode = "n";
          key = "g=";
          action = "vim.lsp.buf.format";
          lua = true;
        }
        {
          mode = "n";
          key = "t";
          action = ":FloatermToggle myfloat<CR>";
        }
        {
          mode = "t";
          key = "<ESC>";
          action = "function() vim.cmd(':FloatermToggle myfloat') end";
          lua = true;
        }
      ];

      extraPlugins = with pkgs.vimPlugins; [
        FixCursorHold-nvim
        luasnip
        plenary-nvim
        neotest
        neotest-plenary
        neotest-rust
      ];

      colorschemes.catppuccin = {
        enable = true;
        flavour = "frappe";
      };

      extraConfigLua = ''
        require("neotest").setup({
          adapters = {
            require("neotest-plenary"),
            require("neotest-rust") {
              args = { "--no-capture" },
            }
          },
        })
      '';

      plugins = {
        bufferline.enable = true;
        none-ls = {
          enable = true;
          sources = {
            formatting.nixpkgs_fmt.enable = true;
            code_actions.shellcheck.enable = true;
            code_actions.statix.enable = true;
            diagnostics = {
              statix.enable = true;
              deadnix.enable = true;
              shellcheck.enable = true;
            };
          };
        };
        nix.enable = true;
        treesitter = {
          enable = true;
          nixGrammars = true;
          disabledLanguages = [ "latex" ];
        };
        surround.enable = true;
        fugitive.enable = true;
        gitgutter.enable = true;
        lualine = {
          enable = true;
          theme = "catppuccin";
        };
        telescope = {
          enable = true;
          extensions.fzf-native.enable = true;
          extensions.fzf-native.fuzzy = true;
        };
        comment-nvim = { enable = true; };
        lsp = {
          enable = true;
          servers = {
            nil_ls.enable = true;
            rust-analyzer = {
              installCargo = false;
              installRustc = false;
            };
            pyright.enable = true;
            elixirls.enable = true;
            clangd.enable = true;
            yamlls.enable = true;
          };
        };
        trouble.enable = true;
        lspkind.enable = true;

        vimtex.enable = true;

        floaterm.enable = true;

        nvim-cmp = {
          enable = true;
          autoEnableSources = true;
          sources = [
            { name = "nvim_lsp"; }
            {
              name = "luasnip";
              option = { show_autosnippets = true; };
            }
            { name = "cmp-spell"; }
            { name = "cmp-rg"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
          snippet.expand = "luasnip";
          mappingPresets = [ "insert" "cmdline" ];
          mapping = {
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = {
              modes = [ "i" "s" ];
              action = ''
                function(fallback)
                  local luasnip = require('luasnip')
                  if cmp.visible() then
                    cmp.select_next_item()
                  elseif luasnip.expandable() then
                    luasnip.expand()
                  elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                  else
                    fallback()
                  end
                end
              '';
            };
          };
        };
      };
    };
  };
}
