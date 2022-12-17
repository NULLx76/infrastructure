{ inputs, pkgs, lib, ... }: {
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];
  programs.nixvim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    vimAlias = true;

    globals = { mapleader = " "; };

    maps.normal = {
      "<leader>ff" = "<cmd>lua require('telescope.builtin').find_files()<cr>";
      "<leader>fg" = "<cmd>lua require('telescope.builtin').live_grep()<cr>";
      "<C-_>" = "<cmd>lua require('Comment.api').toggle.linewise.current()<cr>"; # map ctrl+/ to commenting code
    };

    extraPlugins = with pkgs.vimPlugins; [ catppuccin-nvim luasnip ];

    colorscheme = "catppuccin-frappe";

    plugins = {
      barbar.enable = true;
      nix.enable = true;
      treesitter = {
        enable = true;
        nixGrammars = false;
        ensureInstalled = [ ];
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
        servers.rust-analyzer.enable = true;
        servers.rnix-lsp.enable = true;
        servers.pyright.enable = true;
        servers.elixirls.enable = true;
        servers.clangd.enable = true;
      };
      trouble.enable = true;
      lspkind.enable = true;
      nvim-cmp = {
        enable = true;
        auto_enable_sources = true;
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
        snippet.expand = ''
          function(args)
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
          end
        '';
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
}
