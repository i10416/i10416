{ lib }:
{
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "vscode"
      "vscode-with-extensions"
      "slack"
      "google-chrome"
    ];
}
