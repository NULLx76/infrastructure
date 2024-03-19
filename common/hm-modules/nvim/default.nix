{ config, pkgs, lib, ... }:
let cfg = config.programs.v.nvim;
in with lib; {
  options.programs.v.nvim = { enable = mkEnableOption "nvim"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ fd ];
    home.file.".config/nvim/lua/startup/themes/my_theme.lua" = {
      source = ./dashboard.lua;
    };
    programs.nixvim = {
      enable = true;
      package = pkgs.neovim-unwrapped;
      vimAlias = true;
      luaLoader.enable = true;

      globals.mapleader = " ";

      options = {
        number = true;
        conceallevel = 2;
      };

      clipboard.providers.wl-copy.enable = true;

      keymaps = [
        # Telescope
        {
          mode = "n";
          key = "<leader>ff";
          action = ":Telescope find_files<CR>";
        }
        {
          mode = "n";
          key = "<leader>fs";
          action = ":Telescope file_browser<CR>";
        }
        {
          mode = "n";
          key = "<leader>fg";
          action = "require('telescope.builtin').live_grep";
          lua = true;
        }
        {
          mode = "n";
          key = "<leader>fb";
          action = ":Telescope buffers<CR>";
        }
        {
          mode = "n";
          key = "<leader>fo";
          action = ":Telescope oldfiles<CR>";
        }
        {
          mode = "n";
          key = "<leader>fr";
          action = ":Telescope frecency<CR>";
        }
        # Commenting
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
        # Float Term
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
        # Switch buffers
        {
          mode = "n";
          key = "<leader>s";
          action = ":bn<CR>";
        }
        {
          mode = "n";
          key = "<leader>a";
          action = ":bp<CR>";
        }
        # Change Indenting
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
        # Neotest
        {
          mode = "n";
          key = "<leader>nr";
          lua = true;
          action = "require('neotest').run.run";
        }
        {
          mode = "n";
          key = "<leader>no";
          lua = true;
          action = "require('neotest').output.open";
        }
        {
          mode = "n";
          key = "<leader>ns";
          lua = true;
          action = "require('neotest').run.stop";
        }
        {
          mode = "n";
          key = "<leader>nf";
          lua = true;
          action =
            "function() require('neotest').run.run(vim.fn.expand('%')) end";
        }
        # LSP
        {
          mode = "n";
          key = "<M-CR>";
          action = ":Lspsaga code_action<CR>";
        }
      ];

      extraPlugins = with pkgs.vimPlugins; [
        FixCursorHold-nvim
        nvim-web-devicons
      ];

      colorschemes.catppuccin = {
        enable = true;
        flavour = "frappe";
      };

      extraConfigLua = "";

      plugins = {
        bufferline.enable = true;
        nix.enable = true;
        luasnip.enable = true;
        typst-vim.enable = true;
        startup = {
          enable = true;
          theme = "my_theme";
        };
        none-ls.enable = false;
        obsidian = {
          enable = true;
          settings = {
            new_notes_location = "notes_subdir";
            daily_notes = {
              folder = "daily";
            };
            workspaces = [
              {
                name = "notes";
                path = "~/src/notes";
              }
              {
                name = "uni";
                path = "~/cloud/Documents/CESE/notes";
              }
            ];
            completion = {
              min_chars = 2;
              nvim_cmp = true;
            };
            picker.name = "telescope.nvim";
            note_id_func = ''
              function(title)
                  -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
                  -- In this case a note with the title 'My new note' will be given an ID that looks
                  -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
                  local suffix = ""
                  if title ~= nil then
                    -- If title is given, transform it into valid file name.
                    suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
                  else
                    -- If title is nil, just add 4 random uppercase letters to the suffix.
                    for _ = 1, 4 do
                      suffix = suffix .. string.char(math.random(65, 90))
                    end
                  end
                  return tostring(os.time()) .. "-" .. suffix
                end
                '';
          };
        };
        fidget = {
          enable = true;
          progress = {
            ignoreDoneAlready = true;
            ignore = [ "ltex" ];
          };
          notification = { overrideVimNotify = true; };
        };
        neotest = {
          enable = true;
          adapters.plenary.enable = true;
          adapters.rust = {
            enable = true;
            settings.args = [ "--no-capture" ];
          };
        };
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
          defaults.preview.ls_short = true;
          extensions.file_browser = {
            enable = true;
            hijackNetrw = true;
            dirIcon = "";
          };
          extensions.fzf-native.enable = true;
          extensions.fzf-native.fuzzy = true;
          extensions.frecency.enable = true;
        };
        comment-nvim.enable = true;
        lsp = {
          enable = true;
          keymaps = {
            lspBuf = {
              K = "hover";
              gD = "references";
              gd = "definition";
              gi = "implementation";
              gt = "type_definition";
              "g=" = "format";
            };
            diagnostic = {
              "<leader>j" = "goto_next";
              "<leader>k" = "goto_prev";
            };
          };
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
        lspsaga = {
          enable = true;
          lightbulb.virtualText = false;
        };
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
