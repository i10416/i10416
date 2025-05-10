{ pkgs, lib }:
let
  _ = null;
in
{
  nix = {
    gc.automatic = true;
    optimise.automatic = true;
    settings = {
      substituters = [ "https://cache.nixos.org/" ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
      trusted-users = [ "@admin" ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      max-jobs = 8;
    };
    extraOptions =
      ''
        auto-optimise-store = true

        extra-substituters = https://devenv.cachix.org
        extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
      ''
      + lib.optionalString (pkgs.system == "aarch64-darwin") ''
        extra-platforms = x86_64-darwin aarch64-darwin
      '';
  };
}
