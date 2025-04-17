
## local Backend

ローカルバックエンドを利用すると tfstate ファイルをローカルに置くので VCS にコミットできる

```sh
terraform {
  required_version = "~> 1.11.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.7.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

```

TODO: `backend=false` など他の方法の特長

## GCP へのユーザーの招待

```sh
gcloud projects add-iam-policy-binding <projectid> — member=user:<email> — role=<role>
```

## インフラ管理用 flake.nix のベースライン

```
{
  description = "Flake to manage my Terraform workspace.";
  inputs.nixpkgs.url = "nixpkgs/nixpkgs-unstable";
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        { pkgs, system, ... }:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfreePredicate =
              pkg:
              pkgs.lib.getName [
                # ssm-session-manager-plugin is marked as unfree
                pkgs.ssm-session-manager-plugin
              ];
          };
          google-cloud-sdk = pkgs.google-cloud-sdk.withExtraComponents [
            pkgs.google-cloud-sdk.components.beta
            pkgs.google-cloud-sdk.components.core
            pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin
          ];

          sharedBuildInputs = with pkgs; [
            trivy
            google-cloud-sdk
            awscli2
            ssm-session-manager-plugin
            git
            graphviz
            google-cloud-sql-proxy
            tflint
            terraform-docs
            tenv
          ];
        in
        {
          devShells = {
            default = pkgs.mkShell {
              shellHook = ''
                export PS1='\n\[\033[1;34m\][:\w]\$\[\033[0m\] '
                export TENV_AUTO_INSTALL=true;
              '';
              buildInputs = sharedBuildInputs;
            };
          };
        };
    };
}

```
