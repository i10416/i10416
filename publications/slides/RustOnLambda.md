---
marp: true
---


## Rust on AWS Lambda @ 2025/02/27 Osaki.rs

by [110416](https://github.com/i10416)

---


# WHO AM I
![bg right](../../assets/images/profile_image_padded.png)

- GitHub: https://github.com/i10416
- SpeakersDeck: https://speakerdeck.com/i10416


- Rust で gRPC サーバーを書いたり AWS Lambda を書いたりツールを書いたり社内勉強会を開催したり...

---

Scala も書いてます
最近だと toml-scala のマクロの Scala 3 対応をやっていました 🔨

https://github.com/indoorvivants/toml-scala/releases/tag/v0.3.0

---

## Rust on AWS Lambda: Motivation

- Rust で Lambda を書きたい
- Lambda をシンプルにデプロイしたい
- Lambda のアプリケーションとインフラを疎結合にしたい

---


## Solution
- [lambda runtime](https://crates.io/crates/lambda_runtime)
- [Cargo Lambda](https://www.cargo-lambda.info/)
- [Cargo Workspaces](https://doc.rust-lang.org/book/ch14-03-cargo-workspaces.html)
- [Lambda Extension](https://docs.aws.amazon.com/lambda/latest/dg/lambda-extensions.html)
---


### Rust で Lambda を書きたい: Why Rust on Lambda

- 画像変換処理などの CPU インテンシブで native の依存が入りがちな処理の開発体験を改善したい
  - e.g. 画像の avif への変換
- 複雑なデータの変換処理を型で安全にしたい
  - 生データ -> 中間データ群 -> 完全なデータ
- Lambda が増えると処理が散らばるので型で整合性を保証したい
- アプリケーションをマイクロライブラリ群として設計したい
  - Rust はそのツール・エコシステムが揃っている
    - Cargo Workspace & feature flags
    - git dependencies・AWS Code Artifact
---

### Rust で Lambda を書きたい: Lambda Runtime

`lambda_runtime` は [Lambda のカスタムランタイム](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-custom.html)の実装

内部的には以下のループ処理を実行している

1. エンドポイント(`runtime/invocation/next`)にアクセスして次のイベント情報(JSON)を得る
2. イベントをパースする
3. イベント情報をアプリケーションの実装に引き渡す
4. アプリケーションの処理の結果をエンドポイント(`runtime/invocation/{req id}/response`)に渡す

---

アプリケーションを開発するには他に
- `aws-config`
  - 認証情報や設定の読み込みなどをよしなにやってくれる crate
    GCP でいう [Application Default Credentials](https://google.aip.dev/auth/4110)
- `aws-sdk-*`
  - Lambda や S3 などの SDK
- `aws_lambda_events`
  - AWS Lambda 用の型がまとめられた crate
    AWS のリソース(s3, eventbridge, etc.)ごとに feature が切られている

などの crate が必要

---

## Lambda をシンプルにデプロイしたい: Cargo Lambda

Cargo Lambda で何ができるか

- Lambda アプリケーションのローカルデバッグ
- Lambda アプリケーション・Extensionのビルド
  - Arm <-> x86_64 のクロスビルド
- Lambda アプリケーション・Extensionのデプロイ

---

## Example

`cargo lambda init` でテンプレートを生成することもできるが、
Cargo Workspace を使いたいのでアウトラインを用意した

https://github.com/i10416/rust-on-lambda

![bg right width:450](./RustOnLambda/github.com-i10416-rust-on-lambda.png)

---

```
├── Cargo.lock
├── Cargo.toml
├── README.md
├── flake.lock
├── flake.nix
├── modules
│   ├── application: Lambda 関数の実装
│   ├── core: コアロジック
│   └── extension: Lambda Extension
├── rust-toolchain
```
---


`cargo lambda watch` で Lambda の関数をホットリロードしながら開発できる


関数を呼び出すには `cargo lambda invoke` コマンドを呼ぶ

```sh
cargo lambda invoke application --data-ascii '{}'
```

---

### Extension を追加する

`cargo lambda watch` でエミュレータを動かした上で extension を起動する

```sh
cargo run -p extension
```
---

#### Extension とは

- Lambda 関数の起動時・シャットダウン時の共通処理の実装
- ロギング・Tracing

など、Lambda の横断的な関心ごとをアドオン的に追加できる仕組み

---

## デプロイ

`cargo lambda build` コマンドや `cargo lambda build --extension` コマンドで、AWS Lambda で動作するアプリケーションがビルドできる

`cargo lambda deploy` コマンドでアプリケーションや Extension をデプロイできる

---


### Lambda の辛いポイント

アプリケーションとインフラの境界が曖昧になりがち


---

### Cargo Workspace を活用する

cargo workspace を活用して

- AWS Lambda に依存する部分
- アプリケーションのコア実装
  - I/O を伴わない変換処理
  - I/O を伴う処理
  - 横断的関心ごと
  - 初期化処理

を意識して sub-crate として分割します

---

## Rust の辛いポイント

ビルドが遅い

---

### Lambda のよくあるユースケース

1. s3 のイベントを検知して
2. ファイルを読み出して
3. 何らかの加工を施して
4. DynamoDB や S3 に書き込んで
5. ...

---
### インフラリソースのグルーコードとしてのLambda

Lambda と他の AWS のサービスを組み合わせて使う構成では、Lambda はインフラリソース間を繋ぐグルーコードの役割を果たすので、インフラ構成と同期させたい

---

ソースコードもterraform で管理し変更があったら Lambda を際デプロイ(`terraform apply`)するワークフローを組みたいが...

---


Rust のビルド速度改善(特に CI)で試していること

- crate の分割
- Swatinem/rust-cache@v2
- sccache + GCS
  - GitHub Actions の Runner は US にいるので US region に配置
- lld や mold
  - linker を変えたら速くなると思いきやほとんど変わらないか遅くなることも...

これをしたらビルドが爆速になったよ! というのがあれば懇親会で教えてください！

