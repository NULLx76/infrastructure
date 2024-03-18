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
        {
          mode = "n";
          key = "<C-Tab>";
          action = ":bn<CR>";
        }
        {
          mode = "n";
          key = "<S-C-Tab>";
          action = ":bp<CR>";
        }
        {
          mode = "n";
          key = "<S-Tab>";
          action = "<<_";
        }
        {
          mode = "v";
          key = "<Tab>";
          action = ">gv";
        }
        {
          mode = "v";
          key = "<S-Tab>";
          action = "<gv";
        }
      ];

      extraPlugins = with pkgs.vimPlugins; [
        FixCursorHold-nvim
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
        nix.enable = true;
        luasnip.enable = true;
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
            dockerls.enable = true;
            rust-analyzer = {
              installCargo = false;
              installRustc = false;
            };
            pyright.enable = true;
            pylsp = {
              enable = true;
              settings.plugins = {
                black = {
                  enabled = true;
                  cache_config = true;
                };
                pycodestyle = { maxLineLength = 100; };
              };
            };
            elixirls.enable = true;
            clangd.enable = true;
            yamlls.enable = true;
          };
        };
        trouble.enable = true;
        lspkind.enable = true;
        vimtex.enable = true;
        floaterm.enable = true;

        cmp = {
          enable = true;
          autoEnableSources = true;
          settings = {
            snippet.expand =
              "function(args) require('luasnip').lsp_expand(args.body) end";
            mapping = {
              "<S-Tab>" =
                "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
              "<Tab>" =
                "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
              "<CR>" = "cmp.mapping.confirm({ select = true })";
              "<C-Space>" = "cmp.mapping.complete()";
              "<C-e>" = "cmp.mapping.close()";
            };
            sources = [
              { name = "nvim_lsp_signature_help"; }
              { name = "path"; }
              { name = "nvim_lsp"; }
              { name = "luasnip"; }
              {
                name = "buffer";
                # Words from other open buffers can also be suggested.
                option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
              }
            ];
          };
        };
      };
    };
  };
}
