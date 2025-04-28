{ config, pkgs, ... }:

{
  home.username = "yoichiroito";
  home.language.base = "en_US.UTF-8";
  fonts.fontconfig.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    extraConfig = ''
      set -g mouse on
      # Vim-like keybinding to move between panes
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      # Move to next pane by Ctrl-o
      bind -n C-o select-pane -t :.+
      bind-key -T copy-mode-vi v send-keys -X  begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
      bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "pbcopy"
      set -g mode-keys vi
      # Inherit color settings from zsh
      set-option -g default-command ${pkgs.zsh}/bin/zsh
      set -g default-terminal "xterm-256color"
      set-option -ga terminal-overrides ",*:Tc"
      # Utilities
      ## Status bar
      set-option -g status-position top
      set -g message-style fg=colour68,reverse,bg=brightwhite
      ## Window
      set-window-option -g window-status-current-style bright
      set-window-option -g window-status-style dim
      set-option -g renumber-windows on

      set -s escape-time 0
    '';
  };
  programs.bat.enable = true;
  programs.jq.enable = true;
  programs.java.enable = true;
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    syntaxHighlighting.enable = true;
    sessionVariables = { EDITOR = "vim"; };
    envExtra = ''
      if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
        . ~/.nix-profile/etc/profile.d/nix.sh
      fi
      export PATH=$PATH:/$HOME/bin:$HOME/.ghcup/bin
    '';
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
  };
  programs.gh = {
    enable = true;
    settings = { git_protocol = "ssh"; };
  };
  programs.git = {
    enable = true;
    ignores = [
      # vim
      "*~"
      "*.swp"
      # editor related
      ".DS_Store"
      ".vscode"
      # tools
      ".envrc"
      ".direnv"
      # security
      ".env"
      # scala
      ".bsp"
      ".log"
      ".metals"
      "target"
      "project/project"
      ".scala-build"
    ];
    userName = "i10416";
    userEmail = "ito.yo16uh90616@gmail.com";
    lfs.enable = true;
    extraConfig = {
      color = { ui = "auto"; };
      init = { defaultBranch = "main"; };
    };
  };
  programs.vim = {
    enable = true;
    settings = {
      ignorecase = true;
      number = true;
    };
    extraConfig = ''
      set encoding=utf8

      set autoindent  " better indent
      set smartindent " even better indent
      set expandtab " use spaces instead of tab
      set tabstop=4
      set shiftwidth=4
      set undofile " persist history

      set cursorline " highlight cursor line
      set list " show invisible chars
      set wrap " wrap lines
      set whichwrap=b,s,h,l,<,>,[,] " move to pre/next line when cursor is at the end of line

      set scrolloff=8

      set showmatch  " highlight matching parentheses/ brackets
      set hlsearch " highlight search text
      set incsearch " search incrementally
      set wrapscan " back to first match item after the last one
      set clipboard&
      set clipboard=unnamed,unnamedplus " reset clipboard to default and sync clipboard with OS

      set visualbell " blink cursor on error, instead of beeping

    '';
  };
  home.packages = [
    # base
    pkgs.openssh
    pkgs.darwin.binutils
    pkgs.git
    pkgs.git-lfs
    pkgs.nixfmt-rfc-style
    pkgs.nil
    pkgs.grpcurl
    pkgs.protobuf

    # tools
    # haskell
    pkgs.stack
    pkgs.pandoc
    # scala
    # pkgs.jdk17
    # scalajs
    # pkgs.nodejs_22
    # pkgs.jdk11
    (pkgs.sbt.override { jre = pkgs.jdk17; })
    # pkgs.coursier
    pkgs.ammonite
    # rust
    pkgs.rustup

    # native
    pkgs.ninja
    pkgs.cmake
    # infra
    pkgs.terraform
    pkgs.google-cloud-sdk
    # signing
    pkgs.gnupg
    # misc
    pkgs.imagemagick
    pkgs.tree
    pkgs.jq
    pkgs.bat
    # gnu compat for osx
    pkgs.coreutils
    pkgs.findutils
    pkgs.gnugrep
    pkgs.gnused
    ## apps
    pkgs.slack
    # go
    pkgs.go
    pkgs.gopls
    # ios
    pkgs.xcodes
  ];
  news.display = "silent";
}
