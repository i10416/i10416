{ self, username }:
{ pkgs, lib, ... }:
let
  # configuration
  nix = import ../../foundation/nix.nix { inherit pkgs lib; };
  unfree-allow-list = import ../../foundation/unfree-allow-list.nix { inherit lib; };
  system = import ../../foundation/system.nix { inherit pkgs; };
  darwin-system = import ../../foundation/darwin/universal/system.nix {
    inherit self;
    stateVersion = 5;
  };
  darwin-network = import ../../foundation/darwin/universal/network.nix;
  # tools
  universal-tools = import ../../tools/universal/default.nix { inherit pkgs; };
  vim = (import ../../tools/vim/system/-24.05/default.nix);
  vscode = import ../../tools/vscode/default.nix { inherit pkgs; };
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
  environment.systemPackages = [
    vscode
  ];

  # Nix configuration ------------------------------------------------------------------------------

  # The default Nix build user group ID was changed from 30000 to 350.
  # You are currently managing Nix build users with nix-darwin, but your
  # nixbld group has GID 30000, whereas we expected 350.
  ids.gids.nixbld = 30000;
  nixpkgs.hostPlatform = "aarch64-darwin";
  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };
}
