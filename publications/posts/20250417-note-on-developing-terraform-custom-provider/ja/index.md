
# About

https://developer.hashicorp.com/terraform/tutorials/providers-plugin-framework/providers-plugin-framework-provider に従って開発する。
ベーシックな REST をサポートするエンドポイントがあれば理論上なんでも terraform provider にできる。

## デバッグ

`.terraform.tfrc` で利用する実行可能ファイルの場所を指定できる。

```tf
provider_installation {

  dev_overrides {
      "hashicorp.com/i10416/<provider name>" = "$GOBIN"
  }

  direct {}
}

```

dev_overrides は provider 開発者向けの設定で、これを指定することでバージョンとチェックサムの検証をスキップし、LHS に設定した名前の provider を RHS に指定したディレクトリから読み込む

> This disables the version and checksum verifications for this provider and forces Terraform to look for the null provider plugin in the given directory.

設定ファイルの書き方は以下のページにまとまっている。

- https://developer.hashicorp.com/terraform/cli/config/config-file

次のような環境変数を指定しておくと楽。

```toml
WORKSPACE="$PWD"
GOBIN="${WORKSPACE}/bin"
TF_CLI_CONFIG_FILE="${WORKSPACE}/.terraform.tfrc"
TF_LOG="INFO"
```

TF_CLI_CONFIG_FILE 環境変数がないと terraform CLI はユーザーのホームディレクトリを読みにいく。

利用側からは以下のように provider を指定する。


```tf
terraform {
  required_providers {
    <provider name> = {
      source = "hashicorp.com/i10416/<provider name>"
    }
  }
}
```

## Terraform の構造体のバリデーション

https://github.com/elastic/terraform-provider-elasticstack/blob/42678a14a7c1e1a1dee192f82527e1139325e2fb/internal/schema/connection.go#L36

