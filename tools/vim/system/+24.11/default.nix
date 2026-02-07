{ pkgs, ... }:
let
  vim = pkgs.vim-full.override { };
in
{
  programs.vim = {
    enable = true;
    defaultEditor = true;
    package = vim.customize {
      name = "vim";
      vimrcConfig.customRC = ''
        set encoding=utf8
        syntax on;
        set autoindent  " better indent
        set smartindent " even better indent
        set expandtab " use spaces instead of tab
        set tabstop=4
        set shiftwidth=4
        set cursorline " highlight cursor line
        set wrap " wrap lines
        set whichwrap=b,s,h,l,<,>,[,] " move to pre/next line when cursor is at the end of line
        set scrolloff=8
        set showmatch  " highlight matching parentheses/ brackets
        set hlsearch " highlight search text
        set incsearch " search incrementally
        set wrapscan " back to first match item after the last one
        set visualbell " blink cursor on error, instead of beeping
      '';

    };
  };
}
