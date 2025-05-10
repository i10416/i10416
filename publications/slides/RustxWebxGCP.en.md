---
marp: true
---


# Rust x Web x GCP

Talk@[2023/09/29 人工衛星の開発現場でLT大会 〜Rust バックエンド開発特集〜](https://arkedgespace.connpass.com/event/292290/)

---


# WHOAMI

- GitHub: [i10416](https://github.com/i10416)
- X(Twitter): [@by110416](https://twitter.com/by110416)

Rust & Scala backend developer


---


# Rust@Work

I'm building a mobile backend for frontend server in Rust, which communicates with client apps over gRPC. The server is running on Cloud Run(dev) and internal GKE clusters(staging and production).

In addition, I'm developing a CLI for developers, markup parser and AST transformers in Rust.


---

# Rust x Web
Browsing several GitHub repositories and Reddit, the following libraries are the de-facto stack for backend development as of 2023.

- tower-service
- [tower](https://github.com/tower-rs/tower)
- [tower-http](https://github.com/tower-rs/tower-http)
- [hyper](https://github.com/hyperium/hyper)
- axum
- tonic
- reqwest
- warp
- etc.

---

# Rust x Web

Most of web ecosystem is built on top of tower and tower_service.

- __tower_service__
- __tower__
- __tower-http__
- __hyper__
- axum
- warp
- tonic
- reqwest
- etc.

---

# tower is the most abstract and fundamental layer.

tower is the most abstract and fundamental layer.

It has a signiture: `async fn(Request) -> Result<Response, Error>`.

It accepts inputs of type `Request` and returns either successful value of type `Response` or failed value of type `Error` in async context.

`Request`・`Response`・`Error` here are protocol agnostic generic types. In other words, they are not tied to HTTP.

tower has a concept of layer: `Request -> Request`, `Response -> Response`, which allows developers to share common concerns between tower services.

--- 

# tower: tower-http

tower-http is a crate that provides a set of HTTP utilities such as logging, compression and header manipulation.

Any service that implements tower service can use them as a layer.


--- 
# hyper

hyper is a (relatively low-level)crate that takes care of HTTP concerns.

> hyper is a relatively low-level library, meant to be a building block for libraries and applications.

Axum and Warp, well-known Rust web frameworks, and reqwest HTTP client are based on hyper.

[The latest hyper uses its own service interface instead of tower_service for simplicity](https://github.com/hyperium/hyper/commit/fee7d361c28c7eb42ef6bbfae0db14028d24bfee) through older hyper depends on tower_sercice.


---

# hyper http client example
Though it claims itself low-level, it is not hard to write a snippet for HTTP request using hyper.

```rust
let client: hyper::Client<HttpsConnector<HttpConnector>, Body> = todo!();
let payload = serde_json::to_vec(&payloadable).unwrap();
let req = Request::builder()
    .uri(endpoint)
    .method("POST")
    .header(CONTENT_TYPE, "application/json")
    .header(ACCEPT, "application/json")
    .body(Body::from(payload))
    .unwrap();
let res = client
    .request(req)
    .await
    .unwrap();
```
ref: https://github.com/i10416/firebase-messaging-rs/blob/57279c2bb2aed2782ab679eff98bf7ea813cffef/src/lib.rs#L83

---

# hyper is easy to share between async tasks

> `Client` is cheap to clone and cloning is the recommended way to share a `Client`.

In fact, the internal pool is wrapped inside `Arc<Mutex<_>>`.

```rust
pub(super) struct Pool<T> {
    // If the pool is disabled, this is None.
    inner: Option<Arc<Mutex<PoolInner<T>>>>,
}
```

ref: https://github.com/hyperium/hyper/blob/a22c5122e1d2d58e3f30d059978c3eed14cca082/src/client/pool.rs#L19

---

# Rust x gRPC
- [prost](https://github.com/tokio-rs/prost): Rust's Protocol Buffers implementation and codegen
- [tonic](https://github.com/hyperium/tonic): Rust's gRPC implementation and codegen based on tower and hyper

Prost reads and parses protobuf schema into Rust types. It delegates the rpc parts to respective implementations.

For example, tonic provides gRPC implementation.

---

# Rust x gRPC
tonic is based on tower too. Developers can use tower layers to add features to a server in a composable way.
The following example demonstrates how easy it is to support both gRPC and gRPC web with a few lines.
```rust
#[cfg(not(feature = "grpc-web"))]
let server = Server::builder()
.layer(TraceLayer::new_for_grpc());

#[cfg(feature = "grpc-web")]
let server = Server::builder()
    .accept_http1(true)
    .layer(TraceLayer::new_for_http())
    .layer(GrpcWebLayer::new());

server
    .layer(JWTVerificationLayer::new(..))
    .add_service(health_service)
    // ...
    .serve()
```

---

# Useful crates for Rust on GCP
There are some crates useful for developing gRPC web apps on GCP.
- [tonic-health](https://github.com/hyperium/tonic/tree/master/tonic-health)
- [gcloud-sdk-rs](https://github.com/abdolence/gcloud-sdk-rs)
  - types and RPCs generated from googleapis proto and REST api schema with
  Workload Identity Federation(OIDC) support
- [firestore-rs](https://github.com/abdolence/firestore-rs)
  - ergonomic gcloud-sdk-rs wapper with fluent syntax and serde.
- [tracing](https://github.com/tokio-rs/tracing)+[tracing-stackdriver](https://docs.rs/tracing-stackdriver/latest/tracing_stackdriver/)
  - Easy structured logging compatible with stackdriver logging format.


---

# Gotchas

gcloud-sdk-rs does not re-export tonic, which causes compile error due to tonic version mismatch when there are different versions of tonic.

参考: [公開APIのインターフェースで利用している外部クレートはRe-exportする（と良さそう）](https://qiita.com/tasshi/items/c6548fb38f842c769d85)


---

# Gotchas
In the following example, `generate_id_token` leaks `tonic::Request` type in public interface. When your application depends on tonic of a version different from one gcloud-sdk-rs depends on, it won't compile.

```rust
let client: GoogleApi<IamCredentialsClient<GoogleAuthMiddleware>> =
    GoogleApiClient::from_function(
        IamCredentialsClient::new,
        "https://iamcredentials.googleapis.com/v1",
        None,
    )
    .await
    .unwrap();

let req: GenerateIdTokenRequest = todo!();

match client
    .get()
    .generate_id_token(tonic::Request::new(req))
    .await
```

---

# Gotchas

It is a bit hard to implement a tonic layer which entails I/O operation such as JWT verification because tower middleware does not provide easy API to implement async layer.


[there is an async layer helper crate](https://github.com/plabayo/tower-async)...but it does not seem officially supported.


---

Without tower-async, you must implement this complex trait by yourself.

```rust
impl<S> Service<hyper::Request<Body>> for JWTVerification<S>
where
    S: Service<hyper::Request<Body>, Response = hyper::Response<BoxBody>> + Clone + Send + 'static,
    S::Future: Send + 'static,
{
    type Response = S::Response;
    type Error = S::Error;
    type Future = futures::future::BoxFuture<'static, Result<Self::Response, Self::Error>>;

    fn poll_ready(&mut self, cx: &mut Context<'_>) -> Poll<Result<(), Self::Error>> {
        self.inner.poll_ready(cx)
    }

    fn call(&mut self, mut req: hyper::Request<Body>) -> Self::Future {
        let clone = self.inner.clone();
        let mut inner = std::mem::replace(&mut self.inner, clone);
        // ...
        // ...
        todo!();
```


---

# Rust x Web: the good parts

- 😌  just be careful in service boundaries(e.g. rpc, file and db i/o) and you get strong type safety in the rest of codebase
- 📦 easy to build, easy to deploy with container
- 🧵 async runtime has define-and-run semantics
- 💪 powerful yet concise syntax with algebraic data types and pattern matching
---

# Rust x Web: the bad(?) parts

- 🕰 slow build
- 😢 hard( or intimidating) to some devs
- 🔰 more "managed" functional languages would fit better for some usecases

---

## 🕰  Slow Build

### remove unused crates
  - `nix-shell -p cargo-udeps -p iconv`
  - `cargo +nightly udeps`
### use [Swatinem/rust-cache](https://github.com/Swatinem/rust-cache) on CI
- setup cache generate action [as in this repository](https://github.com/libp2p/rust-libp2p/blob/master/.github/workflows/cache-factory.yml)
- ref: https://github.com/Swatinem/rust-cache/issues/95

※ GitHub Actions restrict users from sharing cache between branches. Make good use of cache from base branches on PRs to avoid cache miss.
https://docs.github.com/en/actions/using-workflows/caching-dependencies-to-speed-up-workflows#restrictions-for-accessing-a-cache


---

## 😢 hard( or intimidating)

In general, writing an application is different from writing a library. Developers use only a subset of language features, which is not so hard even for newcomers, for appliation development.


---


## 🔰 more "managed" languages would fit better for some usecases
Other functional languages, such as Scala, also give similar compile time safety and higher abstraction with less cognitive cost and less steep learning curve(at the cost of performance overhead).

In particular, Scala has a great ecosystem that corresponds to tokio and tower ecosystem. 
||Rust|Scala|
|---|---|---|
|`A => F[B]` + HTTP|tower, hyper| [http4s](https://http4s.org/v1/docs/service.html)|
|gRPC|tonic|[fs2-grpc](https://github.com/typelevel/fs2-grpc), http4s-grpc|
|Async Runtime(`F[_]`)| tokio| [cats-effect](https://typelevel.org/cats-effect/docs/concepts)|


Ad: [Rustacean のための Scala 3 入門](https://zenn.dev/110416/articles/ba9a2ed2154cd6)

---

# Anyway, Rust is great!

in terms of

- performance
- type safety
- dev ex & tooling

---


# Learning Resources
- tower-http・axum・tonic: https://github.com/tower-rs/tower-http/tree/master/examples
- hyper examples: https://github.com/hyperium/hyper/tree/master/examples
- prost examples: https://docs.rs/prost-build/latest/prost_build/
- tonic examples: https://github.com/hyperium/tonic/tree/master/examples

---

# bonus: nix flake for Rust

```nix
{
  description = "Flake to manage Rust workspace.";

  inputs.nixpkgs.url = "nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.rust-overlay.url = "github:oxalica/rust-overlay";
  outputs = { self, nixpkgs, rust-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
      in {
        devShell = pkgs.mkShell {
          name = "rust-shell";
          buildInputs = with pkgs; [
            rust-bin.beta.latest.default
            # or rust-bin.nightly.latest.default cargo-udeps iconv
            rust-analyzer
          ];
        };
      });
}
```


