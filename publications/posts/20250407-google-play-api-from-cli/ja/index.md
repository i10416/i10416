google play publisher API にアクセスするには "https://www.googleapis.com/auth/cloud-platform" に加えて以下のスコープが必要 

- "https://www.googleapis.com/auth/androidpublisher"
- "https://www.googleapis.com/auth/userinfo.email"
- "openid"

`gcloud auth application-default login --scopes="..."` のコマンドでスコープを指定して認証する。


google publisher API を一回も使ったことがない場合は、
`https://console.developers.google.com/apis/api/androidpublisher.googleapis.com/overview?project=<your project id>`

から API の有効化が必要。

リクエストには `gcloud auth application-default print-access-token` で指定したトークンを `Authorization: Bearer` に付与する。
`gcloud auth print-access-token` ではないことに注意。`gcloud auth` コマンドではスコープを指定できない。このコマンドは主に Google Cloud SDK 用のコマンド。

ユーザーのアカウントのトークンでリクエストを送る場合は、 `-H "x-goog-user-project: {project id}"` が必要。


トークンの権限は `https://oauth2.googleapis.com/tokeninfo?access_token={token}` で検証できる。
