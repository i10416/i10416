{ pkgs, ... }:
with pkgs;
vscode-with-extensions.override {
  vscodeExtensions =
    with vscode-extensions;
    [
      jnoortheen.nix-ide
      marp-team.marp-vscode
      shardulm94.trailing-spaces
      scalameta.metals
      mkhl.direnv
      tamasfe.even-better-toml
      arrterian.nix-env-selector
      redhat.vscode-yaml
      eamodio.gitlens
      hashicorp.terraform
    ]
    ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      #{
      #  name = "remote-ssh-edit";
      #  publisher = "ms-vscode-remote";
      # version = "0.47.2";
      #  sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
      #}
    ];
}
