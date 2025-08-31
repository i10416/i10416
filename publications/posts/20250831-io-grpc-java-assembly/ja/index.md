
## Address types of NameResolver 'unix' for '...' not supported by transport
生成された Fat Jar に META-INF/services/io.grpc.NameResolverProvider に `io.grpc.internal.UdsNameResolverProvider` しか含まれないとタイトルのエラーが発生する。
grpc-java を利用するライブラリで Fat Jar を作成した際にスキームを指定しない url が `NettyChannelBuilder#forAddress` に渡されると grpc-java は META-INF/services/io.grpc.NameResolverProvider を参照してデフォルトのスキームとして unix を推定するから。
これは grpc-java を推移的に含む複数のライブラリに依存しているプログラムの Fat Jar を作る際に発生する。

Fat Jar 作成時のオプションで META-INF/services/io.grpc.NameResolverProvider に `io.grpc.internal.DnsNameResolverProvider` が含まれるようにすることで解決可能。

sbt ならば `assemblyMergeStrategy`, mill ならば `assemblyRules` がそれに相当する。



https://github.com/grpc/grpc-java/issues/10853

## gRPC Server Initialization Error: Unable to get public no-arg constructor for NettyServerProvider
gRPC netty のバージョンによっては NettyServerProvider に引数を取らないコンストラクタが存在しない。明示的に `"io.grpc:grpc-netty:1.69.0"` 以上を指定すればエラーは解決される。