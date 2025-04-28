{ pkgs, lib, ... }:
let
  nix = import ./nix.nix { inherit pkgs lib; };
  system = import ./system.nix;
  networking = import ./networking.nix;
  add-ons = import ./add-ons.nix { inherit pkgs; };
in
{
  imports = [
    nix
    system
    networking
    add-ons
  ];

  # Nix configuration ------------------------------------------------------------------------------

  # The default Nix build user group ID was changed from 30000 to 350.
  # You are currently managing Nix build users with nix-darwin, but your
  # nixbld group has GID 30000, whereas we expected 350.
  ids.gids.nixbld = 30000;

  users.users.yoichiroito.home = "/Users/yoichiroito";

  security.pam.services.sudo_local.touchIdAuth = true;

}
