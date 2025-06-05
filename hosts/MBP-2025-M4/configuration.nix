{ self, username }:
{ pkgs, lib, ... }:
let
  # configuration
  nix = import ../../foundation/nix.nix { inherit pkgs lib; };
  unfree-allow-list = import ../../foundation/unfree-allow-list.nix { inherit lib; };
  system = import ../../foundation/system.nix { inherit pkgs; };
  darwin-system = import ../../foundation/darwin/universal/system.nix {
    inherit self;
  };
  darwin-network = import ../../foundation/darwin/universal/network.nix;
  # tools
  universal-tools = import ../../tools/universal/default.nix { inherit pkgs; };
  vim = (import ../../tools/vim/system/-24.05/default.nix);
in
{
  imports = [
    nix
    unfree-allow-list
    system
    darwin-system
    darwin-network
    universal-tools
    vim
  ];
  system.primaryUser = username;

  nixpkgs.hostPlatform = "aarch64-darwin";
  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };
}
