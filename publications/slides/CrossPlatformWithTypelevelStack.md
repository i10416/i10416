---
marp: true
---

# Scala でクロスプラットフォームな SMTP クライアントを書く
Lightning Talk@[2025/03/14 Scalaわいわい勉強会](https://scala-tokyo.connpass.com/event/344598/)  /  [by110416](https://x.com/by110416)


---
# WHO AM I
![bg right](../../assets/images/profile_image_padded.png)

- GitHub: https://github.com/i10416
- SpeakersDeck: https://speakerdeck.com/i10416

---

## 本日の資料はこちら

https://speakerdeck.com/i10416/scala-dekurosupuratutohuomuna-smtp-kuraiantowoshu-ku

![bg right width:480](./CrossPlatformWithTypelevelStack/slide-link.png)

---

## SMTP とは

> SMTP（Simple Mail Transfer Protocol）とは、メールの送受信や転送を行う通信プロトコルです。インターネットなどのTCP/IPネットワークで標準的に利用されています。


例えば gmail では、`smtp.gmail.com` を使って SMTP クライアントからメールを送信できます。

---

SMTP のリクエストはコマンドとデータから構成されます。

```
HELO smtp.example.com
```

```
MAIL FROM:<sender@example.com>
```

```
RCPT TO: <recipient@example.com>
```

サーバーはリクエストに対して `250 OK` のようにステータスコードとメッセージを含むレスポンスで応答します。

---

## SMTP の実装

(TLSを使う) SMTP クライアントは次のような手順でサーバーに接続してメールを送信します。

1. サーバーとソケット通信を開始
2. `HELO` コマンドでサーバー側がサポートする機能を確認
3. `STARTTLS` コマンドを送信し upgrade
4. `HELO` コマンドでサーバー側がサポートする機能を確認
5. [optional] `AUTH LOGIN` コマンドで認証
6. SMTP の仕様に従ってメールをシリアライズして送信
7. `QUIT` コマンドで接続を切る

---

### NOTE
SMTP は 7 bits のプロトコルなので、7 bits で表現できない特殊文字、日本語やバイナリファイルなどのデータのシリアライゼーションには工夫が必要です。7 bits の制約を回避するには base64 でデータをエンコードする方法があります。

今回は時間の都合上この説明は省きます 😞


---


## Typelevel Stack でクロスプラットフォームなアプリケーションを書く

非同期ランタイム [cats-effect](https://github.com/typelevel/cats-effect) と関数型ストリーミングライブラリ fs2(https://github.com/typelevel/fs2) を使うと簡単にクロスプラットフォーム対応した Scala コードを書けます。
また、バイナリコーデックの[scodec](https://github.com/scodec/scodec) や [scodec-bits](https://github.com/scodec/scodec-bits) もクロスプラットフォームに対応しているのでバイナリ形式でデータをやり取りするプロトコルを簡単に実装できます。

---

## 利用例

SMTP は行単位でテキストをやり取りするプロトコルですが、生のソケットに対して文字列やバイナリ操作を行うと不正な操作の余地が生まれてしまうので、次の API でメールを送信できるようにインターフェースを設計します。

```scala
val conn = SMTPConnection[IO](
    host"smtp.gmail.com",
    Some(Credential(username, password))
)

conn.connect.use: mailer =>
    mailer.send(Message.text(...))
```
---


SMTPConnection.scala

```scala
object SMTPConnection:
    def apply[F[_]](...): SMTPConnection[F] = ???

trait SMTPConnection[F[_]]:
  def connect: Resource[F, Mailer[F]]
```

Mailer.scala
```scala
trait Mailer[F[_]]:
  def send(message: Message): F[Unit]
```
---

## 実装例

上のインターフェースの実装例です。`mkTransport` はメールを受け付ける準備ができたソケットを返します。

```scala
object SMTPConnection extends TLSParametersPlatform {
  def apply[F[_]: Network: Concurrent](
      smtpServer: Host,
      credential: Option[Credential] = None,
      port: Port = port"587"
  ): SMTPConnection[F] =
    new SMTPConnection[F] {
      def connect: Resource[F, Mailer[F]] =
        mkTransport(smtpServer, credential, port).flatMap(socket =>
          // ...
```

---

## mkTransport

`fs2.io.net.Network` インスタンスを使ってソケット通信をはじめます。 ネットワーク通信のように I/O を伴う処理はプラットフォーム依存になりがちですが、fs2 は JVM・JS・Native の違いをうまく吸収してくれます。

`SMTPSocket` は `Socket` 型を扱いやすくするヘルパーです。

```scala
for {
      socket <- Network[F]
        .client(SocketAddress(smtpServer, port))
      smtpSocket = SMTPSocket.from(socket)
      // ...

```
---

## SMTPSocket
`fs2.io.net.Socket` には `Byte` や `fs2.Chunk[Byte]` が書き込まれます。そのままでは扱いにくいのでより型安全なヘルパーとして `SMTPSocket` を定義しています。

```scala
trait SMTPSocket[F[_]] {

  def check: F[Unit]

  def helo(domain: Host): F[Unit]

  def startTLS: F[Unit]

  def authn(credential: Credential.Password): F[Unit]
  // ...
```

---

## mkTransport

まずTLS で SMTPでメールを送信するために、サーバーに接続し TLS へ upgrade するように要求します。

```scala
      // ...
      _ <- (
        // サーバーが SMTP をサポートしている場合は
        // グリーティング(code 220)を返します。
        smtpSocket.check
          // HELO コマンドをサーバーに送ります
          *> smtpSocket.helo(smtpServer)
          // サーバーにTLS 接続を要求します
          *> smtpSocket.startTLS
      ).toResource
      // ...

```
---
## mkTransport

TLS に upgrade します。
TLS には暗号処理が必要なのでプラットフォームごとに実装が変わりますが、ここでも fs2 がよしなに抽象化してくれます。

```scala
      // upgrade to TLS
      socket <- for {
        tlsCtx <- Network[F].tlsContext.system.toResource
        tlsSocket <- tlsCtx
          .clientBuilder(socket)
          .withParameters(startTLSParameters(smtpServer))
          .build
          .map(SMTPSocket.from[F])
```

---
## mkTransport

TLS 前後でサーバーがサポートする機能が変わることがあるので再度 `HELO` コマンドを送ります。また、必要に応じて認証をします。

```scala
        // greet again
        _ <- tlsSocket.helo(smtpServer).toResource
      } yield tlsSocket
      _ <- (credential match {
        case None => F.unit
        case Some(credential: Credential.Password) =>
          socket.authn(credential)
        case Some(credential: Credential.OAuth2Token) =>
          socket.xoauth2(credential)
      }).toResource
    } yield socket
```

---

呼び出し側から `send` が並列に呼び出された際にソケットに送るデータが混線しないよう `Mutex` でガードします。
メールを送り終えたら `QUIT` コマンドで接続を切ります。

```scala
mkTransport(smtpServer, credential, port).flatMap(socket =>
 Resource.make(
   for {
     mu <- Mutex[F]
   } yield new Mailer[F] {
     def send(message: Message): F[Unit] =
       mu.lock.surround {
        for {
          _ <- socket.mail(message.from.email)
          _ <- message.to.map(_.email).traverse(socket.rcpt)
          _ <- socket.data
          _ <- socket.send(message)
        } yield ()
      }
   }
 )(_ => socket.quit.as(()))
```
---

## Random Thought: クロスプラットフォームの何が嬉しいか

クラウド環境だと JVM の制約が色々と辛いが、JS ランタイムをサポートできれば全てのクラウドベンダーがサポートしていると言っても過言ではない。
小規模な API、Slack ボットやちょっとしたタスクの自動化など、小さなところから導入することができて嬉しい。

---

## Random Thought
Typelevel Stack を使うとクロスプラットフォームな実装を手軽にできるが、エコシステムはまだまだ発展途上

あるにはあるが...🙁

例
- [http4s-grpc](https://github.com/http4s/http4s-grpc)
- [http4s-googleapis](https://github.com/davenverse/googleapis-http4s)
- [Smithy-based AWS SDK](https://disneystreaming.github.io/smithy4s/docs/protocols/aws/aws/)
- [otel4s](https://github.com/typelevel/otel4s/)

---

## Key Takeaways

- Typelevel Stack(e.g. cats-effect, fs2, scodec) を使うとクロスプラットフォームなコードを(ほとんど)意識しないで書ける
- `F[_]` で 副作用を分離して書くとシグニチャに副作用が明示的に現れるので嬉しい
- Pure Scala でクロスプラットフォームなエコシステムはまだまだ発展途上
  - コントリビューションチャンス ❓

---
不完全ながら今回解説したコードは ↓ の gist にあります。
完全版はしばしお待ちを 🙏

https://gist.github.com/i10416/fbbb1c0ad47f9c87f0084e1c74cf7fa0
