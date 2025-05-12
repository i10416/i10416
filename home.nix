{ username, stateVersion }:
{
  config,
  pkgs,
  ...
}:
let
  _ = null;
in
{
  home.stateVersion = stateVersion;
  home.username = username;
  fonts.fontconfig.enable = true;
  home.language.base = "en_US.UTF-8";
  programs.home-manager.enable = true;
  programs.java.enable = true;
  programs.zsh = import ./home-manager/zsh/default.nix;
  programs.git = import ./home-manager/git/default.nix;
  programs.gh = import ./home-manager/gh/default.nix;
  programs.direnv = import ./home-manager/direnv/default.nix;
  programs.bat = import ./home-manager/bat/default.nix;
  programs.tmux = import ./home-manager/tmux/default.nix { inherit pkgs; };
  programs.vscode = import ./home-manager/vscode/default.nix;
  home.packages = [
    # nix
    pkgs.nil
    # tools
    pkgs.tree
    # rust
    pkgs.rustup
    # scala
    pkgs.scala-cli
    pkgs.mill
    # go
    pkgs.go
    pkgs.gopls
    # node
    pkgs.nodejs_22
    # native
    pkgs.ninja
    pkgs.cmake

    # Utilities
    pkgs.slack
    pkgs.google-chrome

  ];
  news.display = "silent";
}
