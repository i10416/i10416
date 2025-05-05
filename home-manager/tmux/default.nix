{ pkgs, ... }:
{
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
}
