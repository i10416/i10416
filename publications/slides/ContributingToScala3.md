---
marp: true
---



# Scala 3 にコントリビュートしよう

Lightning Talk@[2024/02/27 Scalaわいわい勉強会](https://scala-tokyo.connpass.com/event/297260/)


---

## WHOAMI

- GitHub: [i10416](https://github.com/i10416)
- X(Twitter): [@by110416](https://twitter.com/by110416)

Scala & Rust developer

最近の Scala OSS コントリビューション
- https://github.com/lampepfl/dotty/pulls?q=+is%3Apr+author%3Ai10416+

前回の登壇資料
- Lightning Talk@2023/10/13 Scalaわいわい勉強会: [Scala をインタラクティブにデバッグする方法あれこれ
](https://speakerdeck.com/i10416/scala-wointarakuteibunidebatugusurufang-fa-arekore)
---


## なぜコンパイラに...?

> Prefer to push fixes upstream instead of working around problems downstream
>
> https://www.haskellforall.com/2020/07/the-golden-rule-of-software-quality.html



- アップストリームが修正・改善されることでより多くの開発者が恩恵を受けることができる
- 改善の余地が無限にある(Issue 1.3K+)
- コンパイラ、ドキュメンテーション、Dev Tools、JVM など広く深い学びがある
- JSON・Protobuf 詰め替えやクラウドピタゴラスイッチにはない複雑さ
---

## おことわり

デバッガを使ったりコンパイルオプションを駆使したりしてスマートに問題箇所を特定・対処する方法もあるが、話を複雑にしないためにそれらに踏み込むのはあえて避ける.


興味がある人は以下のページを見るといい.
- https://dotty.epfl.ch/docs/contributing/diagnosing-your-issue/cause.html
- https://dotty.epfl.ch/docs/contributing/debugging-the-compiler/ide-debugging.html
- https://dotty.epfl.ch/docs/contributing/debugging-the-compiler/inspection.html

また、今回はコンパイラのコア部分(※)を中心に説明する. Scaladoc やビルドの改善などは別の機会に...

※: https://dotty.epfl.ch/docs/internals/overall-structure.html でカバーされる範囲

---

## PR を送るまでのステップ

1. Issue を探す
2. `tests/{pos|neg|warn|run}/{issue number}.scala` ファイルにテストを書く
4. あたりをつけて `dotty/compiler/src/dotty/tools/dotc` 以下を修正する
5. `sbt testCompilation {issue number}` で特定のテストケースだけ実行する
6. テストが通ったら終わり. テストがコケたら 3 に戻る
7. `testCompilation` で他のテストがコケないかチェックする
8. コミットを整理 & 丁寧な PR のコメントを書く

---


## Issue の探し方: 初心者~中級者向け

以下のタグで検索すると初心者~中心者向けのタスクが見つかる.

- [spree](https://github.com/lampepfl/dotty/issues?q=is%3Aissue+is%3Aopen+label%3ASpree): spree 向けのタスク候補
- [good first issue](https://github.com/lampepfl/dotty/issues?q=is%3Aopen+is%3Aissue+label%3A%22good+first+issue%22): Subject Says It All!
- [exp:intermediate](https://github.com/lampepfl/dotty/issues?q=is%3Aopen+is%3Aissue+label%3Aexp%3Aintermediate): 中級者向けだがそこまで実装がこみいっていないものが多い.


※ [Spree](https://github.com/scalacenter/sprees) は Scala Center がオープンソースへのコントリビューションを奨励するイベント.

---

## Issue の探し方: 穴場

以下のタグがついているものは取り組みやすい.
バグやクラッシュは解くべき問題が明確なのでテストさえ書ければすぐに直せることが多い.
特に regression は過去に動いていたものが動かなくなるケースなので原因の調査もしやすい.

better-errors・area:reporting はコンパイラが既に持っている情報をユーザーに提示するだけで済むので比較的実装量が少なく済む.

- [itype:bug](https://github.com/lampepfl/dotty/issues?q=is%3Aopen+is%3Aissue+label%3Aitype%3Abug)
- [itype:crash](https://github.com/lampepfl/dotty/issues?q=is%3Aopen+is%3Aissue+label%3Aitype%3Acrash)
- [regression](https://github.com/lampepfl/dotty/issues?q=is%3Aopen+is%3Aissue+label%3Aregression)
- [better-errors](https://github.com/lampepfl/dotty/issues?q=is%3Aissue+is%3Aopen+label%3Abetter-errors)・[area:reporting](https://github.com/lampepfl/dotty/issues?q=is%3Aissue+is%3Aopen+label%3Aarea%3Areporting)
---


## Issue の探し方: 難しいもの

以下のタグがついているものは問題のスコープが絞れていなかったり、そもそもあるべき状態がわかっていなかったりするので難しいことが多い.

- stat:needs triage
- stat:needs minimization
- stat:needs spec
- itype:enhancement
- area:experimental:*

---

## あたりのつけ方

後から振り返ると簡単だが一番時間がかかるのがここ. 根気よくやろう.

- Issue からあたりをつける
- 過去の Issue や Pull Request からあたりをつける
- コンパイラのログ・トレースからあたりをつける

---

## あたりのつけ方: Issue や PR

Issue には `area:{area}` というラベルがついていることがある. `area:typer` であれば [compiler/src/dotty/tools/dotc/typer](https://github.com/lampepfl/dotty/tree/main/compiler/src/dotty/tools/dotc/typer) のコードをいじると修正ができそう、とあたりがつけられる.
また、Issue には関連する Issue や PR が紐づけられていることがある. これらを参考にすると問題箇所をシュッと特定できたりする(e.g. バックポート・フォワードポート)


---

## あたりのつけ方: ログ・トレース・Print デバッグ・Grep

scalac に `-Xprint:{PHASE}{,PHASE}*` を渡せば指定したコンパイラフェーズの後の AST を確認できる.
また、`-Ylog:{PHASE}{,PHASE}*` を渡せば指定したフェーズのログを有効化できる....がこれはあまりいい感じのログを出してくれないのでダメそうなら素直に `print` デバッグを仕込もう😇
`import dotty.tools.dotc.core.Decorators.*` で[ちょっとリッチな string interpolation が使える.](https://dotty.epfl.ch/docs/contributing/debugging-the-compiler/inspection.html#pretty-printing-with-a-string-interpolator-1)

ちなみに scalac をグローバルにインストールしていなくても大丈夫. [dotty のコードベースの sbt シェルから scalac を直接呼び出すことができる](https://dotty.epfl.ch/docs/contributing/diagnosing-your-issue/reproduce.html#compiling-files-with-scalac-1)

エラーメッセージで dotty のソースを grep するのも手.

---


## テストコードの書き方

- コンパイルが通るべきものが通っていない問題の時は [`tests/pos/{issue number}.scala`](https://github.com/lampepfl/dotty/tree/main/tests/pos) にファイルを追加
- コンパイルエラーになるべきものがならない、あるいは"間違った"エラーが出ている場合は [`tests/neg/{issue number}.scala`](https://github.com/lampepfl/dotty/tree/main/tests/neg) にコードを追加
- 警告の内容を検査したい場合は [`tests/warn/{issue number}.scala`](https://github.com/lampepfl/dotty/tree/main/tests/warn) にコードを追加
- コンパイルだけでなく実行時の結果も検査したい場合は `tests/run/{issue number}.scala` にコードを追加

---

## テストコードの書き方: コンパイルエラー・警告のマーク

エラーになるべきところに `// error` コメントを追加する

```scala
type Foo[A] = A match {
  case Int => String
}

type B = Foo[Boolean] // error
```

https://github.com/lampepfl/dotty/blob/8b8caa98d2f40c026e1022339942e3bbcf6c6578/tests/neg/10747.scala#L5

---

## テストコードの書き方: コンパイルエラー・警告のマーク

警告を出すべきところに `// warn` コメントを追加する

```scala
package +.* { // warn // warn
  class Bar
}
```
https://github.com/lampepfl/dotty/blob/8b8caa98d2f40c026e1022339942e3bbcf6c6578/tests/warn/symbolic-packages.scala#L7

複数のエラーや警告を期待する場合は `// warn // warn // warn // ...` と、期待する個数分コメントを書く

---

## コンパイル時オプションの指定

Scala CLI と同様に using directives でコンパイラオプションを指定できる.

```scala
//> using options  -Wnonunit-statement -Wvalue-discard -source:3.3
```
https://github.com/lampepfl/dotty/blob/26642043cded4bf3daba90b9e9f16013cb627ee9/tests/warn/nonunit-statement.scala#L4

---

## コンパイラの出力のチェック

1. 空の `tests/{pos|neg|warn|run}/{issue number}.check` ファイルを作成する
2. `testCompilation {issue number} --update-checkfiles` を実行する
3. 生成された `tests/{pos|neg|warn|run}/{issue number}.check` を期待する出力になるように調整する
4. コードを修正する
5. テストを実行しエラーがなくなるまで 4, 5 を繰り返す.

https://dotty.epfl.ch/docs/contributing/testing.html#checking-compilation-errors-1

---

## そのほか注意事項

Java のコードを含むテストケースを作る場合、

- tests/run で Scala.js のテストが通らないので `// scalajs: --skip` でスキップする必要があること
- pickling が壊れるので `compiler/test/dotc/pos-test-pickling.blacklist`や `compiler/test/dotc/run-test-pickling.blacklist` 除外する必要があること

に注意しよう.


---

## コミットを整理して PR を作る

- コンパイル・テストが通る単位にコミットをまとめる
- コミットが加える変更や修正するバグを説明する
- Issue や他の PR へのリンクを貼る(e.g. `close #42`, `scala/scala#43`)

---


## まとめ

最初は右も左もわからないはずなので、過去の Issue・PR に目を通したり `print` デバッグを仕込んだりしてコンパイラのメンタルモデルを作ろう.

実際に手を動かさないとはじまらないので、まずは fork & clone & compile!

```sh
gh repo fork lampepfl/dotty
```

```sh
sbt compile
```

---

## References

- Scala 3 コンパイラのアーキテクチャ: https://dotty.epfl.ch/docs/contributing/architecture/index.html
- コンパイラのコア部分の構造: https://dotty.epfl.ch/docs/internals/overall-structure.html
- 公式コントリビューションガイド: https://dotty.epfl.ch/docs/contributing/index.html
