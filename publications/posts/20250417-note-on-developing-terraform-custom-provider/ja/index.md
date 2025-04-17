
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

次のような環境変数を指定しておくと楽。

```toml
WORKSPACE="$PWD"
GOBIN="${WORKSPACE}/bin"
TF_CLI_CONFIG_FILE="${WORKSPACE}/.terraform.tfrc"
TF_LOG="INFO"
```

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

