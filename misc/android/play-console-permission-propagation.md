# Play Console Permission Propagation

To programatically download Play Store reports(e.g. earnings, sales, etc.),
developers must create a service account in their GCP project and add the service account to Google Play users.
The service account needs several permissions to perform download(e.g. read permission to app info and sales report).

There is one undocumented catch here. It takes at least 24 hours for the change to take effect.

For example, if you add a service account to Play Console and try to fetch data from Play Store Google Cloud Storage(`pubsite_prod_***`) minutes or hours later, you will receive "Permission Denied" error even if your service account has sufficient permission both for app level permissions and account level permissions on Google Play.

This delay could be reduced by changing the product data(e.g. just adding spaces or period to product description).

## Reference
- https://github.com/googleapis/google-api-nodejs-client/issues/1382#issuecomment-466306678
