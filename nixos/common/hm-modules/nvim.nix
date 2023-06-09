{ config, pkgs, lib, ... }:
with lib;
let cfg = config.programs.v.nvim;
in {
  options.programs.v.nvim = { enable = mkEnableOption "nvim"; };
  config = mkIf cfg.enable {
    programs.nixvim = {
      enable = true;
      package = pkgs.neovim-unwrapped;
      vimAlias = true;

      globals = { mapleader = " "; };

      options = { number = true; };

      maps.normal = {
        "<leader>ff" = "<cmd>lua require('telescope.builtin').find_files()<cr>";
        "<leader>fg" = "<cmd>lua require('telescope.builtin').live_grep()<cr>";

        "<C-_>" =
          "<cmd>lua require('Comment.api').toggle.linewise.current()<cr>"; # map ctrl+/ to commenting code

        "g=" = "<cmd>lua vim.lsp.buf.format{async=true}<cr>";
      };

      extraPlugins = with pkgs.vimPlugins; [ catppuccin-nvim luasnip ];

      colorscheme = "catppuccin-frappe";

      extraConfigLua = "";

      plugins = {
        bufferline.enable = true;
        null-ls = {
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
          # ensureInstalled = [ ];
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
          servers.nil_ls.enable = true;
          servers.rust-analyzer.enable = true;
          servers.pyright.enable = true;
          servers.elixirls.enable = true;
          servers.clangd.enable = true;
          servers.yamlls.enable = true;
        };
        trouble.enable = true;
        lspkind.enable = true;
        nvim-cmp = {
          enable = true;
          autoEnableSources = true;
          sources = [
            { name = "nvim_lsp"; }
            { name = "cmp-latex-symbols"; }
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
