{ inputs, pkgs, lib, ... }: {
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];
  programs.nixvim = {
    enable = true;
    package = pkgs.neovim-unwrapped;

    extraPlugins = with pkgs.vimPlugins; [ catppuccin-nvim ];

    colorscheme = "catppuccin-frappe";

    plugins = {
      nix.enable = true;
      treesitter = { 
        enable = true;
        nixGrammars = false;
        ensureInstalled = [];
      };
      surround.enable = true;
      fugitive.enable = true;
      lualine = {
        enable = true;
        theme = "catppuccin";
      };
      telescope = {
        enable = true;
        extensions.fzf-native.enable = true;
      };
      lsp = {
        enable = true;
        servers.rust-analyzer.enable = true;
        servers.rnix-lsp.enable = true;
        servers.pyright.enable = true;
      };
      nvim-cmp = { enable = true; };
    };
  };
}
