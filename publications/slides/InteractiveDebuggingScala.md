---
marp: true
---

# Scala をインタラクティブにデバッグする方法あれこれ

Lightning Talk@[2023/10/13 Scalaわいわい勉強会](https://scala-tokyo.connpass.com/event/297260/)


---


## WHOAMI

- GitHub: [i10416](https://github.com/i10416)
- X(Twitter): [@by110416](https://twitter.com/by110416)

Scala & Rust developer

最近の Scala OSS コントリビューション
- https://github.com/neotypes/neotypes/releases/tag/v1.0.0-M3


---


## 前提:次のようなパッケージをデバッグする想定で説明する.

```scala
// src/main/scala/Lib.scala
package com.example
object Lib {
  def doSomething(): Int = 42
}
```

```scala
// build.sbt
ThisBuild / organization := "com.example"

val lib = project.in(file("."))
  .settings(
    scalaVersion := "3.3.1",
    version := "0.1.0-SNAPSHOT",
    libraryDependencies ++= Seq(
      "org.scalameta" %% "munit" % "1.0.0-M7" % Test
    )
  )
```

---

## Table of Contents
- sbt console
- test
- publishLocal & import from local repository
- import from private maven repository

---

## 予習: sbt shell と sbt console

- sbt shell: 通常のシェル(zsh、fish や　bash)で sbt と入力したときに開始される sbt のインタラクティブなインターフェース.
- sbt console: sbt shell から呼び出せる Scala REPL 環境

以下の例ではコードブロックの行頭が sbt> と書かれている場合 sbt shell 内でのコマンド実行を、scala> と書かれている場合は Scala REPL 内でのコマンド実行を意味する.

---

## sbt console でデバッグ

```sh
sbt console
```

```scala
scala>import com.example.Lib
scala>Lib.doSomething()
res0: Int = 42
scala>
```
---

## sbt console でデバッグ

複数行の入力

```scala
scala>:paste
// Entering paste mode (ctrl-D to finish)

object DeepThought {
  val theAnswer = 42
}
// ctrl-D
```
---


## sbt console でデバッグ

ファイルの読み込み

```scala
// DeepThought.scala
object DeepThought {
  val theAnswer = 42
}
```

```scala
scala>:load DeepThought.scala
```
---

## sbt console でデバッグ: 初期化コマンドの設定

`console/initialCommands` を設定すれば sbt console の初期化処理を追加できる.
毎回特定のモジュールやライブラリやインポートする場合は設定しておくと楽.

```scala
// build.sbt
val lib = project.in(file("."))
  .settings(
    scalaVersion := "3.3.1",
    version := "0.1.0-SNAPSHOT",
    console / initialCommands := "import java.nio.file._",
    libraryDependencies ++= Seq(
      "org.scalameta" %% "munit" % "1.0.0-M7" % Test
    )
  )
```

---

## sbt console でデバッグ: multi modules

特定のサブプロジェクトのデバッグをしたい場合は sbt shell 内で projects コマンドを実行しサブプロジェクトの名前を確認し projectname/console(下の例では `sbt contrib/console`) とすればいい.

```
├── build.sbt
├── contrib/src/main/scala/...
└── core/src/main/scala/...
```

```scala
// build.sbt
lazy val core = project.in(file("core"))
  ...
lazy val contrib = project.in(file("contrib"))
  ...
```

---

## sbt console でデバッグ: Pros & Cons

### Pros
- 楽. セットアップや(ローカル)リリースが必要ない.
- 期待する動作がそこまで定まっていなくてもいい.
### Cons
- パッケージやアプリケーション全体をデバッグするのには向かない.
- JS や Native ではデバッグできない.
- コンパイルが通っている必要がある(consoleQuick を使えば回避できる)

---

## test(& sbt testOnly) でデバッグ

```scala
// src/test/scala/Test.scala
package com.example

class Test extends munit.FunSuite {
  test("Lib.doSomething returns 42") {
    assertEquals(Lib.doSomething, 42)
  }
}
```
test
```sh
sbt>test
```

testOnly
```sh
sbt>testOnly com.example.Test
```
---

## watch

`~` をコマンドの前につけるとソースコードの変更を監視して、変更があれば自動でコマンドを再実行してくれる.

```sh
sbt>~testOnly com.example.Test
```
---

## test でデバッグ: Pros & Cons


### Pros
- JS や Native でも動作確認できる.
- console より IDE のサポートを活用できる.
### Cons
- コンパイルを通さないといけない.
- テストを書かないといけない.
    - ユニットテストが書きにくいコードベースだと辛い.
- ある程度期待する動作が定まっている必要がある.
---

## sbt publishLocal でデバッグ

publishLocal コマンドを実行すると、~/.ivy2/local/com.example/lib/0.1.0-SNAPSHOT のようなローカルのファイルシステム上にパッケージを配布できる.

```sh
sbt>publishLocal
```

ローカルに配布した後は通常のパッケージのように sbt の libraryDependencies や Scala CLI の using dep ディレクティブ、ammonite のマジックインポートで利用できる.

---

## import from sbt project
ローカルに配布したパッケージは通常のパッケージと同じように利用できる.

```scala
// build.sbt
libraryDependencies ++= Seq(
  "com.example::lib:0.1.0-SNAPSHOT"
)
```

---

## import from [Scala CLI](https://scala-cli.virtuslab.org/)
Scala CLI では [`using dep`](https://scala-cli.virtuslab.org/docs/reference/directives#dependency) でパッケージを読み込める.  `using dep` はデフォルトで maven のレポジトリとローカルのレポジトリからパッケージを探す.

```scala
//> using dep "com.example::lib:0.1.0-SNAPSHOT"
import com.example.Lib

@main
def run = println(Lib.doSomething()) //=> 42
```

---

## import from [ammonite REPL](https://ammonite.io/)

ammonite REPL では [`$ivy.` のマジックインポート](https://ammonite.io/#import$ivy)を使ってパッケージを読み込める.
```scala
@ import $ivy.`com.example::lib:0.1.0-SNAPSHOT`
@ import com.example.Lib
@ Lib.doSomething()
res0: Int = 42
@
```

---

## sbt publishLocal でデバッグ: Pros & Cons

### Pros
- ライブラリ全体の動作確認をできる.
### Cons
- 配布+新しいプロジェクトを作成しないといけないのでやや手間.
- バージョンでキャッシュされるのでバージョンを上げるかコミットハッシュなどを付与する必要がある.
---


## Private な Maven レポジトリに配布されたパッケージをデバッグする


代表的なのは社内レポジトリから private パッケージを取得するユースケース.

ここでは GCP の __asia-northeast1__ の __example-project__ プロジェクトに __example__ という Artifact Registry がある想定で説明する.

GCP を例にするが基本的なアイディアは同じ(...なはず)

---

## sbt project から GCP Artifact Registry にアクセスする

[sbt gcs resolver](https://github.com/abdolence/sbt-gcs-resolver) を利用する.

この sbt plugin は GCS や Artifact Registry へのパッケージの配布・取得機能を提供する.

```scala
// project/plugins.sbt
addSbtPlugin("org.latestbit" % "sbt-gcs-plugin" % "1.8.0")
```

デフォルトの認証情報を設定しておけば plugin がよしなに読み取ってくれる.
```sh
gcloud auth application-default login
```

---

## sbt project から GCP Artifact Registry にアクセスする

```scala
// build.sbt
resolvers += "My Maven Artifact Registry" 
  at "artifactregistry://asia-northeast1-maven.pkg.dev/example-project/example"

libraryDependencies ++= Seq(
  "com.example::lib:0.1.0-SNAPSHOT"
)
```

---


## Scala CLI から GCP Artifact Registry にアクセスする

認証情報を設定する. repository のホストが asia-northeast1-maven.pkg.dev の時に指定した認証情報が使われる.

```sh
scala-cli --power config \
  repositories.credentials "asia-northeast1-maven.pkg.dev" \
  value:_json_key_base64 value:eyXXInR5cXXiOiXXc2.....
```

value::eyXXInR5cXXiOiXXc2..... の部分はサービスアカウント has-access-to-artifact-registry@example-project.iam.gserviceaccount.com のJSON鍵ファイルを base64 エンコードしたもの.

---

## Scala CLI から GCP Artifact Registry にアクセスする

`using repository` で maven やローカル以外のレポジトリを追加できる.

```scala
//> using repository "https://asia-northeast1-maven.pkg.dev/examle-project/example"
//> using dep "com.example::lib:0.1.0-SNAPSHOT"

import com.example._

@main
def run =
  println(Lib.doSomething())
```

---

## Scala CLI から認証付きレポジトリにアクセスする

```sh
scala-cli --power config \
  repositories.credentials <HOST> \
  <USERNAME> <PASSWORD>
```


[GitHub Packages](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-apache-maven-registry) などの認証付きレポジトリも同様に利用できる.

```sh
scala-cli --power config \
  repositories.credentials "maven.pkg.github.com" \
  value:PrivateToken env:GITHUB_TOKEN
```

```scala
/> using repository "https://maven.pkg.github.com/<org>/_"
```

---
## Misc

### remove/unset
```sh
scala-cli --power config --remove repositories.credentials
```

### coursier fetch

```sh
cs fetch -r https://asia-northeast1-maven.pkg.dev/example-project/example \
  --credentials "asia-northeast1-maven.pkg.dev _json_key_base64:eyXXInR5cXXiOiXXc2....."
```

### sbt help <cmd>

```
sbt> help help 
```

---

## Refs

- https://cloud.google.com/artifact-registry/docs/java/authentication?hl=ja#auth-password
- https://github.com/abdolence/sbt-gcs-resolver
- https://scala-cli.virtuslab.org/docs/commands/config/
- https://www.reddit.com/r/scala/comments/175cm36/looking_for_a_working_example_of_import_from/
